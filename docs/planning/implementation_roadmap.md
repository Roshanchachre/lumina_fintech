# Implementation Roadmap: Lumina Wealth (`lumina_fintech`)

This roadmap defines the structured phase-by-phase execution plan to transition Lumina Wealth from an interactive prototype to a production-grade institutional fintech application.

---

## 1. Roadmap Overview & Milestones Timeline

```mermaid
gantt
    title Lumina Wealth Production Delivery Roadmap
    dateFormat  YYYY-MM-DD
    section Phase 1: Stabilization
    M1: Code Quality & Zero-Debt Remediation       :m1, 2026-11-01, 3d
    section Phase 2: Architecture
    M2: Clean Architecture & BLoC Infrastructure    :m2, after m1, 5d
    section Phase 3: UI Completion
    M3: Navigation Shell & Missing Screen Suite   :m3, after m2, 7d
    section Phase 4: Backend
    M4: Backend Gateway & Live Ledger Sync         :m4, after m3, 7d
    section Phase 5: Security
    M5: Biometric Vault & Institutional Hardening :m5, after m4, 4d
    section Phase 6: Release
    M6: Comprehensive QA, CI/CD & Production Ship :m6, after m5, 4d
```

---

## 2. Milestone Breakdown & Objectives

### Milestone 1: Zero-Debt Stabilization & Static Quality (Target: Days 1–3)
* **Goal:** Eliminate all 45 analyzer warnings, fix async build context bugs, and establish baseline code hygiene.
* **Key Deliverables:**
  * Resolve `use_build_context_synchronously` in `dashboard_screen.dart:594`.
  * Refactor 44 instances of deprecated `.withOpacity()` to `.withValues()`.
  * Establish strict static analysis rules in `analysis_options.yaml`.
* **Exit Gate:** `flutter analyze` passes with **0 errors, 0 warnings, 0 infos**.

---

### Milestone 2: Clean Architectural Foundation & State Management (Target: Days 4–8)
* **Goal:** Introduce Domain-Driven Design (DDD) with `flutter_bloc` and dependency injection via `get_it`.
* **Key Deliverables:**
  * Configure service locator (`get_it` + `injectable`).
  * Scaffold Domain, Data, and Presentation layers.
  * Implement `AuthBloc`, `AccountBloc`, `CardBloc`, and `TransferBloc`.
  * Setup `flutter_secure_storage` abstraction.
* **Exit Gate:** Full state isolation; widgets receive immutable state from Blocs; 100% unit test pass rate on Blocs.

---

### Milestone 3: Complete Navigation Shell & Missing Screen Suite (Target: Days 9–15)
* **Goal:** Eliminate all UI dead ends and connect the floating dock to dedicated screens.
* **Key Deliverables:**
  * Implement `go_router` with `StatefulShellRoute.indexedStack`.
  * Build **CardsScreen:** Carousel of physical/virtual cards, spend limits, freeze control, and transaction filtering.
  * Build **PortfolioScreen:** Multi-asset breakdown (Fiat, Crypto, Yield Staking, Equities) with allocation donut chart.
  * Build **SettingsScreen:** Security controls, biometric toggles, KYC tier verification, and currency preferences.
  * Implement **Deposit & Invest Modals** for the Quick Action deck.
* **Exit Gate:** All bottom dock tabs and quick action buttons navigate to functional views with zero dead clicks.

---

### Milestone 4: Backend Gateway & Live Financial Ledger (Target: Days 16–22)
* **Goal:** Connect mobile frontend to a secure PostgreSQL backend (Supabase or NestJS) with atomic transactions.
* **Key Deliverables:**
  * Implement REST client with `Dio` (JWT injection, retry interceptors, SSL verification).
  * Integrate double-entry accounting ledger tables.
  * Wire `POST /api/v1/transfers` with client-generated UUID v4 idempotency keys.
  * Connect `GlowChart` and `RollingBalanceHeader` to real historical snapshot streams via WebSockets.
* **Exit Gate:** End-to-end slide-to-send transfer updates the backend balance in real time and appears in the transaction activity stream.

---

### Milestone 5: Biometric Vault & Institutional Hardening (Target: Days 23–26)
* **Goal:** Enforce bank-grade client security and privacy standards.
* **Key Deliverables:**
  * Integrate `local_auth` for FaceID / TouchID / Biometric PIN challenge.
  * Implement App Switcher privacy veil (blurring window when app is backgrounded).
  * Implement PAN & CVV masking with on-demand decryption.
  * Configure release code obfuscation and ProGuard/R8 rules.
* **Exit Gate:** App requires biometric unlock on cold start; multitasking switcher does not leak balances.

---

### Milestone 6: Quality Assurance, Load Testing & Production Ship (Target: Days 27–30)
* **Goal:** Verify reliability, performance, and cross-platform compatibility before store submission.
* **Key Deliverables:**
  * Write Widget & Golden tests for all custom animated components (80%+ code coverage).
  * Conduct integration test on slow 3G network simulation.
  * Build signed Android App Bundle (AAB) and iOS IPA.
  * Setup GitHub Actions CI/CD pipeline.
* **Exit Gate:** Release builds signed, zero memory leaks, and store deployment readiness verified.
