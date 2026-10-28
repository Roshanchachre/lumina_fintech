-- ============================================================================
-- LUMINA WEALTH (LUMINA_FINTECH) - PRODUCTION POSTGRESQL 16 LEDGER SCHEMA
-- Double-Entry Bookkeeping, Idempotency, and High-Performance Time-Series
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. USERS & KYC IDENTITY
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(32),
    tier VARCHAR(32) DEFAULT 'Titanium Sovereign',
    kyc_status VARCHAR(32) DEFAULT 'verified',
    biometric_enrolled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ACCOUNTS / WALLETS
CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    account_number VARCHAR(32) UNIQUE NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    balance NUMERIC(18, 4) NOT NULL DEFAULT 0.0000,
    locked_balance NUMERIC(18, 4) NOT NULL DEFAULT 0.0000,
    status VARCHAR(32) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT positive_balance CHECK (balance >= 0)
);

-- 3. CARDS VAULT (PCI-DSS ENCRYPTED STORAGE)
CREATE TABLE IF NOT EXISTS cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    card_holder VARCHAR(255) NOT NULL,
    masked_pan VARCHAR(19) NOT NULL, -- "4820 •••• •••• 8492"
    encrypted_pan BYTEA NOT NULL,
    expiry_month INT NOT NULL CHECK (expiry_month BETWEEN 1 AND 12),
    expiry_year INT NOT NULL CHECK (expiry_year >= 2026),
    encrypted_cvv BYTEA NOT NULL,
    balance NUMERIC(18, 4) NOT NULL DEFAULT 0.0000,
    daily_limit NUMERIC(12, 2) DEFAULT 25000.00,
    is_frozen BOOLEAN DEFAULT FALSE,
    is_online_enabled BOOLEAN DEFAULT TRUE,
    is_international_enabled BOOLEAN DEFAULT TRUE,
    tier_name VARCHAR(64) DEFAULT 'Titanium Executive',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TRANSACTIONS & DOUBLE-ENTRY LEDGER
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idempotency_key VARCHAR(64) UNIQUE NOT NULL,
    source_account_id UUID REFERENCES accounts(id),
    destination_account_id UUID REFERENCES accounts(id),
    recipient_label VARCHAR(255) NOT NULL,
    amount NUMERIC(18, 4) NOT NULL CHECK (amount > 0),
    fee NUMERIC(18, 4) DEFAULT 0.0000,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(32) NOT NULL DEFAULT 'settled', -- pending, settled, failed, reversed
    category VARCHAR(64) NOT NULL DEFAULT 'Instant Wire Transfer',
    reference_id VARCHAR(64) UNIQUE NOT NULL,
    blockchain_tx_hash VARCHAR(128),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PORTFOLIO SNAPSHOTS (FOR HISTORICAL SPLINE CHARTING)
CREATE TABLE IF NOT EXISTS portfolio_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    period VARCHAR(8) NOT NULL, -- '1D', '1W', '1M', '1Y', 'ALL'
    point_index INT NOT NULL,
    valuation_usd NUMERIC(18, 4) NOT NULL,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- PERFORMANCE INDEXES
CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(source_account_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_idempotency ON transactions(idempotency_key);
CREATE INDEX IF NOT EXISTS idx_cards_account ON cards(account_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_period ON portfolio_snapshots(user_id, period, point_index);

-- 6. ATOMIC WIRE TRANSFER STORED PROCEDURE (WITH ROW LOCKING & IDEMPOTENCY)
CREATE OR REPLACE FUNCTION execute_wire_transfer(
    p_idempotency_key VARCHAR(64),
    p_source_account_id UUID,
    p_destination_account_id UUID,
    p_recipient_label VARCHAR(255),
    p_amount NUMERIC(18, 4),
    p_category VARCHAR(64),
    p_tx_hash VARCHAR(128) DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_source_balance NUMERIC(18, 4);
    v_tx_id UUID;
    v_ref_id VARCHAR(64);
BEGIN
    -- Check if idempotency key already processed
    SELECT id INTO v_tx_id FROM transactions WHERE idempotency_key = p_idempotency_key;
    IF FOUND THEN
        RETURN v_tx_id; -- Return existing transaction ID safely without duplicate debit
    END IF;

    -- Lock source account row for update
    SELECT balance INTO v_source_balance FROM accounts WHERE id = p_source_account_id FOR UPDATE;

    IF v_source_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient cleared funds: balance is %, required %', v_source_balance, p_amount;
    END IF;

    -- Generate reference ID
    v_ref_id := 'WIRE-' || UPPER(SUBSTRING(gen_random_uuid()::text, 1, 8));

    -- Debit sender account
    UPDATE accounts SET balance = balance - p_amount WHERE id = p_source_account_id;

    -- Credit recipient account if internal
    IF p_destination_account_id IS NOT NULL THEN
        UPDATE accounts SET balance = balance + p_amount WHERE id = p_destination_account_id;
    END IF;

    -- Record transaction in immutable ledger
    INSERT INTO transactions (
        idempotency_key,
        source_account_id,
        destination_account_id,
        recipient_label,
        amount,
        category,
        reference_id,
        blockchain_tx_hash,
        status
    ) VALUES (
        p_idempotency_key,
        p_source_account_id,
        p_destination_account_id,
        p_recipient_label,
        p_amount,
        p_category,
        p_tx_hash,
        'settled'
    ) RETURNING id INTO v_tx_id;

    RETURN v_tx_id;
END;
$$ LANGUAGE plpgsql;

-- 7. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY account_owner_policy ON accounts
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY card_owner_policy ON cards
    FOR ALL USING (account_id IN (SELECT id FROM accounts WHERE user_id = auth.uid()));

CREATE POLICY tx_participant_policy ON transactions
    FOR SELECT USING (
        source_account_id IN (SELECT id FROM accounts WHERE user_id = auth.uid()) OR
        destination_account_id IN (SELECT id FROM accounts WHERE user_id = auth.uid())
    );
