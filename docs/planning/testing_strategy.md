# Testing & Quality Assurance Strategy: Lumina Wealth (`lumina_fintech`)

This document defines the multi-layer testing matrix, test automation pipeline, and edge-case test specifications for Lumina Wealth.

---

## 1. Testing Pyramid & Layers

```
        / \
       / E2E \       --> 5% (Full User Journeys via Integration Test)
      /-------\
     / Golden  \     --> 15% (Pixel-Perfect Visual Regression Tests)
    /-----------\
   /   Widget    \   --> 30% (Gesture, State, Component Interaction Tests)
  /---------------\
 /      Unit       \ --> 50% (Blocs, Repositories, Math & Formatter Tests)
---------------------
```

---

## 2. Test Case Specifications

| Test Case ID | Feature / Component | Test Objective | Execution Steps | Expected Outcome | Status |
|---|---|---|---|---|---|
| **TC-001** | `main.dart` | App Smoke Test | Pump `LuminaFintechApp` | App renders Dashboard without exceptions; user name appears | **PASSED** |
| **TC-002** | `interactive_card.dart` | 3D Tilt Gesture | Pan finger across card by $(dx=50, dy=30)$ | `Matrix4` updates rotation within clamped $[-0.35, +0.35]$ rad | Planned |
| **TC-003** | `interactive_card.dart` | Card Flip | Tap center of card | Card rotates $180^\circ$ Y-axis; backside displays CVV and Freeze switch | Planned |
| **TC-004** | `interactive_card.dart` | Card Freeze Toggle | Flip card, toggle "Freeze Card" switch | Card state updates to `isFrozen=true`; frozen icy overlay appears | Planned |
| **TC-005** | `rolling_counter.dart` | Balance Period Switch | Tap '1Y' period chip | Numbers roll from previous balance to target balance over 900ms | Planned |
| **TC-006** | `glow_chart.dart` | Spline Touch Scrubbing | Drag horizontal finger at $x = 0.5 \times W$ | Vertical laser indicator and tooltip appear at midpoint point value | Planned |
| **TC-007** | `slide_to_send.dart` | Threshold Incomplete Snapback | Drag slider to 70% and release | Slider returns to 0% with `Curves.easeOutBack`; no transfer triggered | Planned |
| **TC-008** | `slide_to_send.dart` | Successful Transfer Lock | Drag slider to $\ge 88\%$ | Slider locks at max width; heavy haptic emits; `onConfirmed` fires | Planned |
| **TC-009** | `dashboard_screen.dart` | Modal Dismiss Unmounted | Trigger transfer; unmount widget before 1400ms delay | No `use_build_context_synchronously` crash occurs | Planned |
| **TC-010** | `transaction_item.dart` | Transaction Detail Modal | Tap 'Stripe SaaS Revenue' tile | Bottom sheet displays category, merchant, amount ($4,250.00) | Planned |
| **TC-011** | `auth` | Biometric Cold Start Gate | Launch app with biometric enabled | Biometric prompt shown; Dashboard hidden until authentication succeeds | Planned |
| **TC-012** | `api` | Idempotent Transfer Execution | Execute transfer twice with identical UUID | Second transfer is rejected by backend with 409 Conflict / Cached 200 | Planned |
| **TC-013** | `theme` | Extreme Text Scaling | Set device accessibility text scale to 2.0x | Dashboard layouts do not produce renderflex overflow errors | Planned |
| **TC-014** | `network` | Offline Mode Handling | Disconnect network during app use | Top amber offline banner displays; pull-to-refresh displays cache toast | Planned |
| **TC-015** | `security` | App Background Privacy Screen | Minimize app into OS multitasking switcher | Window is replaced with blurred dark shield; card details not visible | Planned |

---

## 3. Edge-Case Coverage Specifications

### 3.1 Gesture & Physics Stress Test
* **Scenario:** Rapid multi-touch collisions (e.g. user drags card while simultaneously tapping bottom dock with second finger).
* **Assertion:** `InteractiveCard` gesture detector must not crash or drop frames; `PointerDownEvent` must isolate single-finger pan.

### 3.2 Network Latency on Wire Transfer
* **Scenario:** User executes slide transfer on 3000ms latency connection.
* **Assertion:** Slider remains locked in "Processing" state with animated neon spinner; user cannot tap background to dismiss modal until API returns either success or failure.

---

## 4. Release Gate Quality Criteria
No code shall be merged to `main` or deployed to production unless:
1. `flutter analyze` passes with **0 errors, 0 warnings, 0 lints**.
2. Automated test suite passes with **100% success rate**.
3. Code coverage exceeds **80%** across domain and presentation layers.
4. Golden tests verify pixel parity on iOS (iPhone 16 Pro) and Android (Pixel 9).
