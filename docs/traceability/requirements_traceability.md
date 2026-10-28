# Requirements Traceability Matrix (RTM): Lumina Wealth (`lumina_fintech`)

This matrix maps every business requirement to its implementing feature, code component, API endpoint, database table, test case, and acceptance criteria.

---

## 1. Traceability Matrix Table

| Req ID | Business Requirement | Feature ID | Screen / Component | API Endpoint | Database Table | Test Case ID | Acceptance Criteria |
|---|---|---|---|---|---|---|---|
| **REQ-01** | Display aggregate net worth with rolling digit animation | FEAT-02 | `RollingBalanceHeader` (`rolling_counter.dart`) | `GET /api/v1/accounts/me` | `accounts` | TC-001, TC-005 | Balance numbers animate smoothly over 900ms when switching timeframes (`1D` to `ALL`). |
| **REQ-02** | Interactive 3D physical card inspection with realistic sheen | FEAT-01 | `InteractiveCard` (`interactive_card.dart`) | N/A (Client Physics) | `cards` | TC-002 | Card tilts on X/Y axes proportional to finger drag; snaps back on release. |
| **REQ-03** | Immediate card locking/freezing to prevent unauthorized charges | FEAT-01 | `InteractiveCard` flip backside | `PATCH /api/v1/cards/{id}/freeze` | `cards.is_frozen` | TC-003, TC-004 | Card flips $180^\circ$; toggling switch locks card and shows icy blue overlay. |
| **REQ-04** | Historical portfolio trajectory visualization with scrub cursor | FEAT-03 | `GlowChart` (`glow_chart.dart`) | `GET /api/v1/portfolio/history` | `portfolio_snapshots` | TC-006 | Dragging finger across chart displays neon vertical laser line and point valuation. |
| **REQ-05** | Slide-to-confirm instant wire transfer with zero double-debit | FEAT-04 | `SlideToSendButton` (`slide_to_send.dart`) | `POST /api/v1/transfers` | `transactions`, `accounts` | TC-007, TC-008, TC-012 | Slider locks at 88% threshold; emits heavy haptic; backend verifies idempotency key. |
| **REQ-06** | Real-time transaction ledger inspection and receipt modal | FEAT-05 | `TransactionItemTile` (`transaction_item.dart`) | `GET /api/v1/transactions` | `transactions` | TC-010 | Tapping transaction opens detail sheet showing merchant, category, and reference ID. |
| **REQ-07** | Biometric unlock on application cold start and backgrounding | FEAT-10 | `LockScreen` (`local_auth`) | `POST /api/v1/auth/verify` | `users` | TC-011 | App prompts FaceID/Fingerprint before revealing balances or card details. |
| **REQ-08** | Multi-tab navigation across Cards, Portfolio, and Settings | FEAT-07 | `_buildFloatingDock` (`app_router.dart`) | N/A (Client Route) | N/A | TC-004 | Tapping dock pills swaps views seamlessly without state loss. |
| **REQ-09** | App switcher privacy veil to prevent multitasking balance leaks | FEAT-10 | Native Lifecycle Veil | N/A (OS Level) | N/A | TC-015 | Minimizing app into switcher renders blurred black shield over financial data. |
| **REQ-10** | Offline detection and network disconnection banner | FEAT-11 | `NetworkStatusBar` | N/A (Connectivity) | Local SQLite | TC-014 | App displays ambient amber alert when offline; serves cached balances. |
