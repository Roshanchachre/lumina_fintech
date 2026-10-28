# Feature Inventory: Lumina Wealth (`lumina_fintech`)

This document outlines every current and planned feature of Lumina Wealth, documented across 22 architectural parameters.

---

### FEAT-01: 3D Interactive Titanium Card

1. **Feature ID:** FEAT-01  
2. **Feature Name:** 3D Interactive Titanium Virtual/Physical Card  
3. **Business Purpose:** Provide a tangible, luxury feel to digital banking cards, enhancing brand prestige and security control.  
4. **Intended User:** High-net-worth individual, corporate account holder.  
5. **User Problem Solved:** Cards in digital banking feel flat and boring; finding CVV/details or freezing a lost card is clunky.  
6. **Entry Point:** Center card carousel on `DashboardScreen`.  
7. **Preconditions:** User is logged in and possesses an active issued card.  
8. **Main Workflow:** User pans finger on card -> Card rotates on 3D X/Y axes via `Matrix4` showing metallic sheen -> User taps card -> Card flips 180 degrees showing CVV, billing address, and "Freeze Card" switch -> User toggles switch to freeze/unfreeze.  
9. **Alternative Workflows:** Card flick/release snaps back to level orientation via spring physics (`Curves.elasticOut`).  
10. **Inputs & Validations:** Pan drag coordinates (clamped between -0.35 and +0.35 radians). Toggle switch boolean.  
11. **Expected Outputs:** Real-time 3D rendered card transformation with lighting reflection; haptic clicks on interaction.  
12. **UI & UX Requirements:** Dark titanium gradient, micro-dot pattern, neon chip accent, glass sheen gradient reflection, 60fps rendering without jank.  
13. **Backend & API Requirements:** `POST /api/v1/cards/{id}/freeze`, `GET /api/v1/cards/{id}/credentials` (requires token auth).  
14. **Database Requirements:** `cards` table with columns: `id`, `user_id`, `pan_encrypted`, `expiry_month`, `expiry_year`, `cvv_encrypted`, `is_frozen`, `card_type`.  
15. **Auth & AuthZ Requirements:** Viewing sensitive CVV requires local biometric re-authentication (FaceID/PIN).  
16. **States Covered:**  
    * *Loading:* Skeleton card shimmer.  
    * *Success:* Interactive 3D tilt.  
    * *Frozen:* Frosted cyan ice overlay with lock icon.  
    * *Error:* "Unable to update card status" toast.  
17. **Edge Cases:** Rapid pan-and-tap collisions; device orientation changes; low-end GPU rendering slowdowns.  
18. **Dependencies:** Flutter rendering engine, `Matrix4`, `HapticFeedback`.  
19. **Acceptance Criteria:** Card flips within 700ms; PAN copy button copies unmasked number to clipboard with 30s auto-clear.  
20. **Current Implementation Status:** UI Implemented (Mock data, in-memory toggle, no backend link).  
21. **Required Changes:** Hook freeze toggle to API; encrypt sensitive card credentials; add biometric prompt on flip.  
22. **Testing Requirements:** Golden widget tests for front/back; gesture hit-test unit tests.

---

### FEAT-02: Real-time Wealth Balance & Rolling Periodical Ticker

1. **Feature ID:** FEAT-02  
2. **Feature Name:** Real-time Wealth Balance & Rolling Counter  
3. **Business Purpose:** Show aggregated net worth with dynamic time-window gains/losses to build investor confidence.  
4. **Intended User:** Active retail investor, wealth management client.  
5. **User Problem Solved:** Static balance numbers make fintech apps feel stale and disconnected from real-time markets.  
6. **Entry Point:** Top header of `DashboardScreen`.  
7. **Preconditions:** Account loaded with portfolio assets.  
8. **Main Workflow:** User views current balance -> User taps period pill (`1D`, `1W`, `1M`, `1Y`, `ALL`) -> Numbers smoothly roll and interpolate to historical balance -> Percentage badge updates color (neon green / crimson).  
9. **Alternative Workflows:** Balance privacy toggle (tap eye icon to blur/mask balance as `••••••••`).  
10. **Inputs & Validations:** Selected period string.  
11. **Expected Outputs:** Formatted currency string with rolling digit animations via `Curves.easeOutExpo`.  
12. **UI & UX Requirements:** Space Grotesk typography, 38pt display font, neon cyan/green period indicator chips.  
13. **Backend & API Requirements:** `GET /api/v1/portfolio/summary?period=1M`.  
14. **Database Requirements:** `portfolio_snapshots` table with timestamped valuation balances.  
15. **Auth & AuthZ Requirements:** Bearer JWT token with user read scope.  
16. **States Covered:** Loading placeholder, active rolling, network disconnected indicator.  
17. **Edge Cases:** Large balances (> $100M) causing layout text overflow; currency formatting across locales (INR, USD, EUR).  
18. **Dependencies:** `intl` package (`NumberFormat`), `AnimationController`.  
19. **Acceptance Criteria:** Number animation completes within 900ms; period change emits callback to chart.  
20. **Current Implementation Status:** UI Implemented with mock numbers.  
21. **Required Changes:** Connect period selection to real portfolio snapshot stream; add currency switcher and hide-balance toggle.  
22. **Testing Requirements:** Unit test currency formatting across currencies; verify controller disposal on unmount.

---

### FEAT-03: Dynamic Glow Spline Chart & Touch Scrubbing

1. **Feature ID:** FEAT-03  
2. **Feature Name:** Interactive Spline Glow Chart with Touch Scrubbing  
3. **Business Purpose:** Provide immediate visual feedback on portfolio trendline and granular day-by-day valuation.  
4. **Intended User:** Investor tracking portfolio volatility.  
5. **User Problem Solved:** Cluttered, jagged finance charts with confusing axes that obscure the overall growth trend.  
6. **Entry Point:** Sub-header on `DashboardScreen`.  
7. **Preconditions:** Historical price points available for selected timeframe.  
8. **Main Workflow:** Chart bezier curve animates in on mount -> User touches or drags horizontal thumb across chart -> Vertical neon laser line appears at cursor -> Indicator dot follows spline curve with haptic ticks -> Point valuation displays in tooltip.  
9. **Alternative Workflows:** Release touch -> Indicator smoothly fades out and returns to latest current price.  
10. **Inputs & Validations:** `GestureDetector` touch coordinates ($x, y$), clamped to canvas width.  
11. **Expected Outputs:** Dual-pass neon blur stroke painted via `dart:ui` `MaskFilter.blur(BlurStyle.solid, 8)` and gradient fill under curve.  
12. **UI & UX Requirements:** Hardware-accelerated 60fps custom painter, antialiased cubic Bezier curves.  
13. **Backend & API Requirements:** `GET /api/v1/portfolio/history?period={period}&granularity=hourly`.  
14. **Database Requirements:** Time-series database or TimescaleDB / Postgres partitioning for portfolio ticks.  
15. **Auth & AuthZ Requirements:** User authorization.  
16. **States Covered:** Initial stroke draw animation, scrub active state, empty historical data state.  
17. **Edge Cases:** Single data point or zero volatility (flat line); screen resize during scrub.  
18. **Dependencies:** `CustomPainter`, `dart:ui`, `HapticFeedback`.  
19. **Acceptance Criteria:** Touch scrubbing responds with < 16ms latency; Bezier curves never clip top/bottom bounding box.  
20. **Current Implementation Status:** Complete in CustomPainter with hardcoded mock points.  
21. **Required Changes:** Normalize dynamic price ranges ($y_{min}, y_{max}$); replace mock array with API data provider.  
22. **Testing Requirements:** CustomPainter render tests; touch scrub coordinate math unit tests.

---

### FEAT-04: Slide-to-Confirm Instant Wire Transfer

1. **Feature ID:** FEAT-04  
2. **Feature Name:** Slide-to-Confirm Wire Transfer Modal  
3. **Business Purpose:** Eliminate accidental multi-thousand-dollar fund transfers while maintaining frictionless UX.  
4. **Intended User:** Account holder sending funds to contacts or crypto wallets.  
5. **User Problem Solved:** Traditional "Are you sure?" pop-ups cause cognitive fatigue; standard buttons lead to accidental double taps.  
6. **Entry Point:** "Transfer" action button on `DashboardScreen`.  
7. **Preconditions:** Verified account balance $\ge$ transfer amount + fees.  
8. **Main Workflow:** Bottom sheet opens -> Displays recipient and amount -> User drags glowing slider thumb to the right -> Haptic tick occurs at 50% -> At 88% threshold, slider locks -> Heavy impact haptic triggers -> Success badge animates with elastic scale -> Sheet auto-dismisses after 1400ms.  
9. **Alternative Workflows:** User releases thumb before 88% -> Thumb springs back with elastic curve (`Curves.easeOutBack`).  
10. **Inputs & Validations:** Horizontal drag offset; recipient validation; balance availability check.  
11. **Expected Outputs:** Execution of transaction payload; modal state transition to `_isSent = true`.  
12. **UI & UX Requirements:** Neon cyan track with gradient fill; animated arrows; success checkmark with green pulse.  
13. **Backend & API Requirements:** `POST /api/v1/transfers` with body `{ recipient_id, amount, currency, idempotency_key }`.  
14. **Database Requirements:** Atomic Postgres transaction across `balances` and `ledger_entries` with row-level locks.  
15. **Auth & AuthZ Requirements:** High-value transfer requires secondary PIN / Biometric prompt or 2FA OTP.  
16. **States Covered:** Default sliding, snap-back, processing, success, failure (insufficient funds/rejected).  
17. **Edge Cases:** Network timeout during transfer execution; user dismissing sheet mid-transfer; double-slide race conditions.  
18. **Dependencies:** `SlideToSendButton`, `HapticFeedback`.  
19. **Acceptance Criteria:** Slider requires deliberate drag; double submission impossible due to state lock; idempotency key generated per transfer attempt.  
20. **Current Implementation Status:** UI and gesture complete with fixed `$1,250.00` mock transfer.  
21. **Required Changes:** Dynamic amount and recipient input; integrate real API call with error handling; fix `use_build_context_synchronously` lint.  
22. **Testing Requirements:** Drag threshold unit tests; network failure rollback integration tests.

---

### FEAT-05: Transaction Activity Stream & Ledger Inspection

1. **Feature ID:** FEAT-05  
2. **Feature Name:** Transaction Activity Stream & Detail Sheet  
3. **Business Purpose:** Provide transparent auditing of all account debits, credits, staking yields, and subscriptions.  
4. **Intended User:** Account holder monitoring expenses and payouts.  
5. **User Problem Solved:** Confusing bank statements with ambiguous merchant codes.  
6. **Entry Point:** "Recent Activity" section on `DashboardScreen`.  
7. **Preconditions:** User has transaction records.  
8. **Main Workflow:** User scrolls down activity list -> Taps any transaction tile -> Bottom sheet smoothly slides up showing full ledger breakdown (merchant, timestamp, category, reference ID, fee, blockchain explorer link, receipt download).  
9. **Alternative Workflows:** User taps "View All" -> Navigates to full paginated filterable transaction history.  
10. **Inputs & Validations:** Tap event; pagination offset and filters (Date range, Category, In/Out).  
11. **Expected Outputs:** Formatted currency with positive (green) / negative indicators; detailed receipt modal.  
12. **UI & UX Requirements:** Staggered cascade entrance animation (`.animate().fadeIn().slideX()`); glowing category icons.  
13. **Backend & API Requirements:** `GET /api/v1/transactions?limit=20&cursor=...`.  
14. **Database Requirements:** `transactions` table with foreign key to `accounts`, indexed on `(account_id, created_at DESC)`.  
15. **Auth & AuthZ Requirements:** User can only query transactions belonging to their authenticated account.  
16. **States Covered:** Skeleton loader, populated list, empty state ("No transactions yet"), error retry state.  
17. **Edge Cases:** Pending transactions transitioning to failed/settled; crypto transactions awaiting block confirmations.  
18. **Dependencies:** `TransactionItemTile`, `_TransactionDetailModal`.  
19. **Acceptance Criteria:** Tapping item opens sheet under 150ms; "View All" navigates to full history screen.  
20. **Current Implementation Status:** 4 mock items rendered; detail modal works; "View All" is unlinked.  
21. **Required Changes:** Implement full Transactions screen with search and filter; connect to backend repository.  
22. **Testing Requirements:** Widget test for detail modal; unit test for transaction list serialization.

---

### FEAT-06: Quick Action Command Deck

1. **Feature ID:** FEAT-06  
2. **Feature Name:** Quick Action Deck (Transfer, Deposit, Invest, More)  
3. **Business Purpose:** 1-tap shortcuts to the 4 primary money movements.  
4. **Intended User:** Daily active banking user.  
5. **User Problem Solved:** Hiding deposit and transfer options inside buried sub-menus.  
6. **Entry Point:** Action deck beneath card section on `DashboardScreen`.  
7. **Current Implementation Status:** "Transfer" opens Quick Send Modal. "Deposit", "Invest", and "More" only trigger haptic clicks with zero navigation.  
8. **Required Changes:** Implement Deposit (Fiat On-Ramp / QR Code), Invest (Asset Swaps / Yield Staking), and More (Statements, Help, Limits) modals.

---

### FEAT-07: Floating Glass Capsule Navigation Dock

1. **Feature ID:** FEAT-07  
2. **Feature Name:** Floating Glass Capsule Bottom Navigation Bar  
3. **Business Purpose:** Modern, accessible navigation across core product pillars without cluttering screen real estate.  
4. **Intended User:** All app users.  
5. **User Problem Solved:** Heavy, opaque bottom tab bars that waste vertical space.  
6. **Entry Point:** Persistent bottom dock on `DashboardScreen`.  
7. **Current Implementation Status:** UI widget `_buildFloatingDock()` toggles active index (0: Home, 1: Cards, 2: Portfolio, 3: Settings), but only updates local pill highlight. No view pager or navigation occurs.  
8. **Required Changes:** Replace single-screen scaffold with indexed stack or GoRouter shell routes connecting dedicated `CardsScreen`, `PortfolioScreen`, and `SettingsScreen`.
