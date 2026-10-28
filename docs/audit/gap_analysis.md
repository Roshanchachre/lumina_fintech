# Gap Analysis & Prioritization Matrix: Lumina Wealth (`lumina_fintech`)

This document compares the intended production fintech requirements against the verified implementation state, categorizing every gap by severity (P0 to P3).

---

## 1. Prioritization Framework
* **P0 — Critical Blocker:** Security vulnerabilities, compliance breaches, data loss risks, or crashes. Must be resolved before any deployment.
* **P1 — High Priority:** Core user flows broken, essential screens missing, or fundamental architectural bottlenecks.
* **P2 — Medium Priority:** Usability gaps, unlinked secondary actions, missing empty/error states, or test deficiencies.
* **P3 — Low Priority:** Cosmetic enhancements, micro-optimizations, and non-essential animations.

---

## 2. Comprehensive Gap Analysis Table

| Gap ID | Category | Gap or Issue Description | Concrete Evidence | Impact | Priority | Dependencies | Proposed Resolution | Verification Method |
|---|---|---|---|---|---|---|---|---|
| **GAP-01** | Security | Unrestricted App Access & No Biometric Gate | `main.dart:28` launches directly to `DashboardScreen()` | Anyone possessing the device can view balances and trigger transfers | **P0** | None | Implement `local_auth` biometric challenge on cold start and resume | Automated test with mocked local_auth + manual FaceID test |
| **GAP-02** | Security / PCI | Plaintext Sensitive Cardholder Data (PAN/CVV) | `interactive_card.dart:17` hardcodes unmasked PAN | Direct violation of PCI-DSS Requirement 3 | **P0** | Backend API | Mask PAN by default; fetch encrypted credentials only after biometric challenge | Code audit & memory dump inspection |
| **GAP-03** | Code Quality | Async Gap in Modal Dismissal (`BuildContext`) | `dashboard_screen.dart:594:34` | Potential crash or memory leak if widget unmounts during delay | **P0** | None | Check `if (!context.mounted) return;` before `Navigator.of(context).pop()` | `flutter analyze` returns 0 issues on file |
| **GAP-04** | Architecture | Lack of Scalable State Management & Architecture | All logic in `_DashboardScreenState` via `setState()` | Unable to share balance across screens or persist state | **P1** | `flutter_bloc` or `riverpod` | Implement Feature-first BLoC architecture (AuthBloc, BalanceBloc, CardBloc) | Unit test state transitions with `bloc_test` |
| **GAP-05** | Backend | Absence of Live Backend API & Networking Layer | Hardcoded mock objects in all files | App cannot display real balances or execute real transfers | **P1** | Backend Gateway | Integrate `Dio` with interceptors, JWT refresh, and Supabase/NestJS REST endpoints | MockWebServer integration tests |
| **GAP-06** | Navigation | Bottom Dock Tabs Are Completely Dead Ends | `dashboard_screen.dart:451` only sets integer index | User cannot access Cards, Portfolio, or Settings views | **P1** | `go_router` | Implement `StatefulShellRoute` with `CardsScreen`, `PortfolioScreen`, `SettingsScreen` | Widget test tapping tabs swaps active child view |
| **GAP-07** | Transactions | Wire Transfer Uses Hardcoded Mock & No Idempotency | `dashboard_screen.dart:497` has fixed `$1250` amount | Cannot transfer arbitrary amounts or different recipients | **P1** | GAP-05 | Add recipient selector and numeric keypad sheet; pass UUID v4 idempotency key | End-to-end transfer execution test |
| **GAP-08** | Code Quality | 44 Deprecated `.withOpacity()` Member Usages | `flutter analyze` reports 44 deprecations | Degraded alpha precision and future compile failure | **P2** | Flutter 3.27+ | Replace all `.withOpacity(val)` with `.withValues(alpha: (val * 255).round().toDouble())` or hex alphas | `flutter analyze` passes with zero deprecation warnings |
| **GAP-09** | Feature | Quick Action Deck ("Deposit", "Invest", "More") Inactive | `dashboard_screen.dart:343-361` only emit haptics | Key financial functionalities advertised but unavailable | **P2** | GAP-06 | Implement Deposit Modal (Fiat on-ramp & Crypto QR) and Invest Asset Picker | Manual QA click-through |
| **GAP-10** | Testing | Test Suite Inadequate (< 5% Code Coverage) | Only 1 smoke test in `test/widget_test.dart` | High regression risk during feature additions | **P2** | None | Add comprehensive unit, widget, and golden tests for all 5 custom widgets | CI coverage report exceeding 80% |
| **GAP-11** | UX / Error | Missing Network Disconnection & Empty States | CustomScrollView assumes perpetual offline data | App appears frozen if network drops | **P2** | Connectivity Plus | Add global connectivity banner and pull-to-refresh (`RefreshIndicator`) | Offline mode simulation test |
| **GAP-12** | Privacy | No App Switcher Privacy Screen Overlay | Screen contents visible in multitasking drawer | Sensitive balances exposed to bystanders | **P3** | Native iOS/Android | Add native lifecycle hooks to blur window on pause/inactive | Manual app switcher inspection |
