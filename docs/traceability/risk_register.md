# Risk Register: Lumina Wealth (`lumina_fintech`)

This register tracks identified project risks, evaluates their likelihood and impact, and specifies proactive mitigation and contingency strategies.

---

## 1. Risk Evaluation Matrix

```
       Impact
        High   |   RSK-01, RSK-02   |      RSK-03     |
        Med    |   RSK-04, RSK-05   |      RSK-06     |
        Low    |   RSK-07           |      RSK-08     |
               ----------------------------------------
                   Low                   High
                                Likelihood
```

---

## 2. Risk Register Details

| Risk ID | Category | Risk Description | Likelihood | Impact | Severity | Mitigation Strategy | Contingency Plan |
|---|---|---|---|---|---|---|---|
| **RSK-01** | Security / Compliance | Accidental leak of unmasked card PAN/CVV in client logs or storage | Low | High | **CRITICAL** | Enforce PCI-DSS card masking; encrypt all credentials with AES-GCM; redact sensitive keys in logs. | Immediate card invalidation and remote token revocation. |
| **RSK-02** | Financial / Reliability | Duplicate fund transfer caused by user swiping slider during network drop | Med | High | **CRITICAL** | Client-generated UUID v4 idempotency keys; lock slider UI immediately upon drag threshold. | Automatic reconciliation job to detect and reverse duplicate ledger entries. |
| **RSK-03** | Schedule / External | Delays in Apple Developer Account enrollment or App Store banking approval | High | High | **HIGH** | Initiate Dun & Bradstreet (D-U-N-S) number verification immediately; submit staging build to TestFlight early. | Distribute internal enterprise builds or PWA version for early testing. |
| **RSK-04** | Performance | Frame drops and rendering jank during 3D card tilt on low-end Android GPUs | Med | Med | **MEDIUM** | Use hardware-accelerated `Transform` with `matrix4`; clamp max tilt angles to $\pm 0.35$ radians. | Add low-power mode toggle in settings to disable 3D tilt and render static card. |
| **RSK-05** | Technical Debt | Flutter 3.27+ deprecation of `.withOpacity()` causing color precision loss | High | Low | **MEDIUM** | Execute TASK-002 immediately to migrate all 44 occurrences to `.withValues()`. | Revert to pinned Flutter version until refactoring is complete. |
| **RSK-06** | Usability / Adoption | Users confused by lack of navigation when tapping bottom dock tabs | High | Med | **HIGH** | Execute Milestone 3 to connect `GoRouter` shell routes and populate Cards/Portfolio screens. | Add temporary "Coming Soon" snackbar on unlinked tabs. |
| **RSK-07** | Operational | Third-party crypto RPC or fiat gateway downtime causing transfer timeouts | Med | Med | **MEDIUM** | Multi-RPC provider failover (Infura + Alchemy); exponential retry backoff. | Display clear "Network Congested" banner; queue transfer for asynchronous execution. |
| **RSK-08** | Accessibility | High text scaling causing layout overflow in rolling balance header | Med | Low | **LOW** | Wrap text widgets in `FittedBox` or set `textScaler: TextScaler.linear(...)` upper bounds. | Graceful text truncation with ellipsis. |
