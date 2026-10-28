# Granular Task Breakdown: Lumina Wealth (`lumina_fintech`)

This document details the engineering tasks required to execute the Lumina Wealth Implementation Roadmap.

---

### TASK-001: Async Context & BuildContext Gap Fix

* **Task ID:** TASK-001  
* **Task Name:** Guard Async Gap in `_QuickSendModal` Dismissal  
* **Description:** Fix the lint warning and potential crash caused by calling `Navigator.of(context).pop()` across an asynchronous gap (`Future.delayed`) without checking widget mount state.  
* **Reason:** Calling context methods on an unmounted element throws runtime exceptions if the user dismisses the bottom sheet before the timer completes.  
* **Files Affected:** `lib/screens/dashboard_screen.dart` (Line 594).  
* **Prerequisites:** None.  
* **Dependencies:** None.  
* **Implementation Approach:** Replace `Future.delayed(..., () { Navigator.of(context).pop(); })` with:
  ```dart
  Future.delayed(const Duration(milliseconds: 1400), () {
    if (!mounted) return;
    Navigator.of(context).pop();
  });
  ```
* **Expected Output:** Modal dismisses cleanly; zero lint warnings on line 594.  
* **Acceptance Criteria:** `flutter analyze` reports no `use_build_context_synchronously` warnings.  
* **Test Requirements:** Automated widget test that pumps `_QuickSendModal`, triggers transfer, and unmounts before 1400ms without error.  
* **Estimated Effort:** 0.5 hours.  
* **Priority:** P0 (Critical).  
* **Risks:** Negligible.  
* **Rollback Approach:** Revert git commit.

---

### TASK-002: Modern Color Alpha API Migration (`withValues`)

* **Task ID:** TASK-002  
* **Task Name:** Migrate 44 Deprecated `.withOpacity()` Usages to `.withValues()`  
* **Description:** Replace all calls to `.withOpacity(double)` with `.withValues(alpha: double)` to comply with Dart 3.11 / Flutter 3.27+ standards.  
* **Reason:** `.withOpacity()` performs integer channel rounding that causes precision loss in animation frames and will be removed in future Flutter releases.  
* **Files Affected:**
  * `lib/screens/dashboard_screen.dart` (6 instances)
  * `lib/widgets/glow_chart.dart` (5 instances)
  * `lib/widgets/interactive_card.dart` (13 instances)
  * `lib/widgets/rolling_counter.dart` (6 instances)
  * `lib/widgets/slide_to_send.dart` (5 instances)
  * `lib/widgets/transaction_item.dart` (9 instances)  
* **Prerequisites:** TASK-001.  
* **Dependencies:** Flutter SDK 3.27+.  
* **Implementation Approach:** Search and replace `color.withOpacity(alpha)` with `color.withValues(alpha: alpha)`.  
* **Expected Output:** All 44 static analysis warnings resolved.  
* **Acceptance Criteria:** `flutter analyze` reports 0 issues across the entire project.  
* **Test Requirements:** Run `flutter test` to ensure visual rendering parity.  
* **Estimated Effort:** 1.5 hours.  
* **Priority:** P1 (High).  
* **Risks:** Typo in alpha argument.  
* **Rollback Approach:** `git checkout lib/`.

---

### TASK-003: Core State Management Scaffold (BLoC + Service Locator)

* **Task ID:** TASK-003  
* **Task Name:** Scaffold BLoC Architecture and Dependency Injection  
* **Description:** Add `flutter_bloc` and `get_it` packages; set up domain/data/presentation directory structure.  
* **Reason:** De-couple UI presentation from data models and prepare for multi-screen navigation.  
* **Files Affected:**
  * `pubspec.yaml`
  * `lib/core/di/injection.dart`
  * `lib/features/account/presentation/bloc/account_bloc.dart`
  * `lib/features/transfers/presentation/bloc/transfer_bloc.dart`  
* **Prerequisites:** TASK-001, TASK-002.  
* **Dependencies:** `flutter_bloc: ^8.1.6`, `get_it: ^7.7.0`.  
* **Implementation Approach:** Create `AccountState` (Initial, Loading, Loaded, Error), `AccountEvent` (FetchAccount, RefreshAccount, SelectPeriod). Wrap `LuminaFintechApp` with `MultiBlocProvider`.  
* **Expected Output:** Dashboard consumes state from `AccountBloc` rather than internal local variables.  
* **Acceptance Criteria:** Dashboard balance updates dynamically when `AccountBloc` emits `AccountLoaded`.  
* **Test Requirements:** Unit tests for `AccountBloc` using `bloc_test`.  
* **Estimated Effort:** 4 hours.  
* **Priority:** P1 (High).  
* **Risks:** Breaking existing animations during widget refactoring.  
* **Rollback Approach:** Git revert.

---

### TASK-004: Declarative Routing & Multi-Screen Shell (`go_router`)

* **Task ID:** TASK-004  
* **Task Name:** Implement GoRouter Shell with Cards, Portfolio & Settings Views  
* **Description:** Replace flat `DashboardScreen` root with `GoRouter` `StatefulShellRoute.indexedStack`. Implement placeholder screens for Cards, Portfolio, and Settings.  
* **Reason:** Tapping bottom dock items currently results in dead clicks.  
* **Files Affected:**
  * `lib/core/router/app_router.dart`
  * `lib/features/cards/presentation/cards_screen.dart`
  * `lib/features/portfolio/presentation/portfolio_screen.dart`
  * `lib/features/settings/presentation/settings_screen.dart`
  * `lib/widgets/floating_dock.dart`  
* **Prerequisites:** TASK-003.  
* **Dependencies:** `go_router: ^14.3.0`.  
* **Implementation Approach:** Connect `_dockItem(index)` tap events to `navigationShell.goBranch(index)`. Maintain scroll positions across tabs via `StatefulShellBranch`.  
* **Expected Output:** Seamless tab switching across all 4 bottom dock items without re-rendering or losing card tilt state.  
* **Acceptance Criteria:** Tapping "Cards" displays the full Cards view; tapping "Home" returns to Dashboard with animated transition.  
* **Test Requirements:** Widget test verifying branch navigation on tap.  
* **Estimated Effort:** 6 hours.  
* **Priority:** P1 (High).  
* **Risks:** Bottom dock clipping on devices with gesture navigation bars.  
* **Rollback Approach:** Git branch revert.

---

### TASK-005: Biometric Vault & Local Authentication Integration

* **Task ID:** TASK-005  
* **Task Name:** Integrate `local_auth` and Secure Storage Gate  
* **Description:** Protect app cold starts and sensitive actions (card CVV unmasking, wire transfers) with FaceID/TouchID.  
* **Reason:** Unrestricted access to financial data violates basic banking compliance.  
* **Files Affected:**
  * `pubspec.yaml`
  * `ios/Runner/Info.plist` (NSFaceIDUsageDescription)
  * `android/app/src/main/AndroidManifest.xml` (USE_BIOMETRIC)
  * `lib/core/security/biometric_service.dart`
  * `lib/features/auth/presentation/lock_screen.dart`  
* **Prerequisites:** TASK-003.  
* **Dependencies:** `local_auth: ^2.3.0`, `flutter_secure_storage: ^9.2.2`.  
* **Implementation Approach:** Create `BiometricService.authenticate(reason: '...')`. Display an animated dark-glass `LockScreen` on startup that calls `authenticate()`.  
* **Expected Output:** App requires FaceID or device PIN to access account.  
* **Acceptance Criteria:** Successful biometric match reveals Dashboard; failed attempt shows retry button; unauthorized user blocked.  
* **Test Requirements:** Mock biometric responses in unit tests.  
* **Estimated Effort:** 4 hours.  
* **Priority:** P0 (Critical).  
* **Risks:** Permission rejections on older Android versions.  
* **Rollback Approach:** Fallback to device PIN.
