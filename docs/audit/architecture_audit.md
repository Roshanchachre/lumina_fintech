# Technical Architecture Audit: Lumina Wealth (`lumina_fintech`)

This document assesses the current architectural state of Lumina Wealth and provides a blueprint for a scalable, production-grade fintech system.

---

## 1. Frontend Architecture Audit

### 1.1 Current Architecture Analysis
The current application is organized as a flat Flutter widget tree:

```
lib/
├── main.dart                 --> Direct root mounting (MaterialApp)
├── screens/
│   └── dashboard_screen.dart --> God Widget (632 lines) holding state, layout, modals, dock
├── theme/
│   └── lumina_theme.dart     --> Static token dictionary
└── widgets/                  --> 5 self-contained animated UI widgets
```

### 1.2 Identified Architectural Anti-Patterns:
1. **God Widget (`dashboard_screen.dart`):**  
   Contains UI rendering, bottom sheet logic, mock data declarations, navigation indices, and layout definitions all in a single file. This breaks the Single Responsibility Principle (SRP).
2. **Ephemerality of State (`setState` only):**  
   State cannot survive app restarts, navigation transitions, or backgrounding. If a user switches tabs, `DashboardScreen` state would be lost if rebuilt without `AutomaticKeepAliveClientMixin`.
3. **Tight Coupling:**  
   Widgets like `RollingBalanceHeader` and `InteractiveCard` hold hardcoded financial data directly in their internal state maps (`_periodData`).

---

## 2. Target Production Architecture: Layered Clean Architecture

To support real banking operations, the application must transition to a 4-tier Clean Architecture / Domain-Driven Design (DDD) pattern:

```mermaid
graph TD
    subgraph Presentation Layer
        UI[Flutter Screens & Widgets]
        BLOC[Blocs & Cubits State Management]
    end

    subgraph Domain Layer
        USECASE[Use Cases / Interactors]
        ENTITY[Pure Domain Entities]
        REPO_INTERFACE[Repository Interfaces]
    end

    subgraph Data & Infrastructure Layer
        REPO_IMPL[Repository Implementations]
        REMOTE_DS[REST / WebSocket Remote Data Source]
        LOCAL_DS[Secure Storage & SQLite / Drift Cache]
    end

    subgraph External
        API[NestJS / Supabase Gateway]
        SECURE_ENCLAVE[Hardware Biometrics]
    end

    UI --> BLOC
    BLOC --> USECASE
    USECASE --> REPO_INTERFACE
    USECASE --> ENTITY
    REPO_IMPL ..|> REPO_INTERFACE
    REPO_IMPL --> REMOTE_DS
    REPO_IMPL --> LOCAL_DS
    REMOTE_DS --> API
    LOCAL_DS --> SECURE_ENCLAVE
```

---

## 3. Backend & Database Architecture Blueprint

### 3.1 Recommended Backend Stack
* **Runtime:** Node.js / TypeScript with **NestJS** (or direct **Supabase** Managed PostgreSQL + Edge Functions).
* **Database:** PostgreSQL 16+ with Row-Level Security (RLS) enabled on all tables.
* **Caching & Real-Time:** Redis for rate limiting and session tokens; WebSockets / SSE for live balance & ticker streaming.

### 3.2 Relational Database Schema Design (PostgreSQL)

```sql
-- 1. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(32),
    kyc_status VARCHAR(32) DEFAULT 'pending', -- pending, verified, rejected
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Accounts / Wallets Table
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    account_number VARCHAR(32) UNIQUE NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    balance NUMERIC(18, 4) NOT NULL DEFAULT 0.0000,
    locked_balance NUMERIC(18, 4) NOT NULL DEFAULT 0.0000,
    status VARCHAR(32) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Cards Table
CREATE TABLE cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    card_holder VARCHAR(255) NOT NULL,
    masked_pan VARCHAR(19) NOT NULL, -- e.g. "4820 •••• •••• 8492"
    encrypted_pan BYTEA NOT NULL,    -- AES-256-GCM encrypted
    expiry_month INT NOT NULL,
    expiry_year INT NOT NULL,
    encrypted_cvv BYTEA NOT NULL,
    is_frozen BOOLEAN DEFAULT FALSE,
    card_tier VARCHAR(32) DEFAULT 'titanium',
    spending_limit_daily NUMERIC(12, 2) DEFAULT 10000.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Transactions / Ledger Table (Double-Entry Bookkeeping)
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idempotency_key VARCHAR(64) UNIQUE NOT NULL,
    source_account_id UUID REFERENCES accounts(id),
    destination_account_id UUID REFERENCES accounts(id),
    amount NUMERIC(18, 4) NOT NULL,
    fee NUMERIC(18, 4) DEFAULT 0.0000,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(32) NOT NULL, -- pending, settled, failed, reversed
    category VARCHAR(64) NOT NULL,
    title VARCHAR(255) NOT NULL,
    blockchain_tx_hash VARCHAR(128),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for ultra-fast query execution
CREATE INDEX idx_transactions_account ON transactions(source_account_id, created_at DESC);
CREATE INDEX idx_transactions_dest ON transactions(destination_account_id, created_at DESC);
CREATE INDEX idx_cards_account ON cards(account_id);
```

---

## 4. API Specification Blueprint

| Endpoint | Method | Purpose | Auth |
|---|---|---|---|
| `/api/v1/auth/login` | `POST` | Exchange biometric signature / passkey for JWT | Public |
| `/api/v1/auth/refresh` | `POST` | Rotate refresh token | Refresh Token |
| `/api/v1/accounts/me` | `GET` | Fetch aggregate net worth & balance | Bearer JWT |
| `/api/v1/cards` | `GET` | List active cards with masked PANs | Bearer JWT |
| `/api/v1/cards/{id}/freeze` | `PATCH` | Lock / unlock card instantly | Bearer JWT + Biometric |
| `/api/v1/cards/{id}/details` | `GET` | Decrypt and reveal raw PAN & CVV | Biometric Re-Auth |
| `/api/v1/transfers` | `POST` | Execute slide-to-confirm wire transfer | Bearer JWT + Idempotency |
| `/api/v1/transactions` | `GET` | Paginated transaction activity stream | Bearer JWT |
| `/api/v1/portfolio/history` | `GET` | Historical datapoints for GlowChart | Bearer JWT |
