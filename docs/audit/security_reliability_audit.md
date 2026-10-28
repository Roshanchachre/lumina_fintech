# Security, Reliability & Compliance Audit: Lumina Wealth (`lumina_fintech`)

This document performs an institutional-grade security, compliance, and reliability assessment on Lumina Wealth.

---

## 1. OWASP Mobile Top 10 Security Audit

| OWASP Risk ID | Category | Current Status in Lumina Wealth | Risk Level | Required Remediation |
|---|---|---|---|---|
| **M1: Improper Platform Usage** | OS & Hardware Features | No biometric authentication configured; no keystore / keychain usage. | **HIGH** | Integrate `local_auth` for FaceID/TouchID and hardware-backed key generation. |
| **M2: Insecure Data Storage** | Client Storage | Card PANs (`4820 8391 0294 8492`), CVVs, and balances are kept in unencrypted plaintext memory. | **CRITICAL** | Store all session tokens and cached sensitive data using `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android). |
| **M3: Insecure Communication** | Network Transport | No network layer currently implemented. | **HIGH** | When connecting to backend, enforce TLS 1.3 with Certificate Pinning (`dio_smart_retry` + `http_certificate_pinning`). |
| **M4: Insecure Authentication** | Session & Auth | Direct app launch into Dashboard with zero password, PIN, or biometric gate. | **CRITICAL** | Introduce initial Biometric Lock Screen and 15-minute inactivity auto-lock. |
| **M5: Insufficient Cryptography** | Encryption | No cryptographic signing of transactions or payload verification. | **HIGH** | Client must sign transfer intents with asymmetric private keys stored in the device Secure Enclave. |
| **M7: Client Code Quality** | Bugs & Memory Safety | 1x `use_build_context_synchronously` warning in modal dismissal; 44 deprecation lints. | **MEDIUM** | Fix async gaps with `if (!context.mounted) return;` and migrate to `.withValues()`. |
| **M9: Reverse Engineering** | Obfuscation | App builds without ProGuard/R8 obfuscation rules configured. | **MEDIUM** | Enable code obfuscation in release builds: `flutter build appbundle --obfuscate --split-debug-info=...`. |

---

## 2. Fintech & PCI-DSS Compliance Audit

### 2.1 Cardholder Data Security (PCI-DSS Requirement 3)
* **Rule:** Primary Account Numbers (PAN) must be masked when displayed (showing maximum first 6 and last 4 digits). The Full PAN and CVV must never be stored on client device storage unencrypted.
* **Current Violation:** `InteractiveCard` contains full 16-digit PAN (`4820 8391 0294 8492`) hardcoded as a public string parameter.
* **Remediation:** 
  1. Default state must display `•••• •••• •••• 8492`.
  2. Full PAN and CVV can only be fetched on-demand from the backend via an ephemeral one-time token after biometric confirmation.
  3. The unmasked values must be purged from device RAM after 60 seconds.

### 2.2 App Switcher Screen Capture Privacy
* **Vulnerability:** When a user switches apps or enters the recent apps switcher, iOS and Android take a snapshot of the screen. In a banking app, this leaks account balances and card numbers to anyone viewing the multitasker.
* **Remediation:** Implement a native privacy veil (`FLAG_SECURE` on Android, `UIWindow` blur overlay on iOS `applicationWillResignActive`).

---

## 3. Reliability, Concurrency & Idempotency Audit

### 3.1 Slide-to-Confirm Wire Transfer Reliability
* **Race Condition Risk:** A user swiping the transfer slider twice in quick succession during network latency could trigger double-debiting.
* **Remediation:**
  * Lock the slider UI immediately upon hitting 88% drag threshold.
  * Generate an `Idempotency-Key` (UUID v4) on initial drag initiation:
    ```dart
    final idempotencyKey = const Uuid().v4();
    ```
  * Backend must reject duplicate requests sharing the same key within a 24-hour window.

### 3.2 AnimationController Resource Cleanup
* **Audit Check:** All `AnimationController` instances across `interactive_card.dart`, `glow_chart.dart`, `rolling_counter.dart`, and `slide_to_send.dart` were audited for `.dispose()` calls.
* **Result:** **PASSED.** All controllers are correctly disposed in their respective `State.dispose()` lifecycle methods, preventing memory leaks during widget rebuilding.
