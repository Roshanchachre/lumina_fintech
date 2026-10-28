# Dependency Map & Execution Graph: Lumina Wealth (`lumina_fintech`)

This document visualizes the hard prerequisites, parallel execution tracks, and external dependencies governing the implementation of Lumina Wealth.

---

## 1. Task Dependency & Critical Path Graph

```mermaid
flowchart TD
    subgraph Milestone 1: Stabilization
        T001["TASK-001: Fix Async Context Gap"]
        T002["TASK-002: Migrate Color .withValues()"]
    end

    subgraph Milestone 2: Architecture
        T003["TASK-003: Scaffold BLoC & DI Injection"]
        T006["TASK-006: Abstract Secure Storage Repository"]
    end

    subgraph Milestone 3: Navigation & UI
        T004["TASK-004: GoRouter Stateful Shell"]
        T007["TASK-007: Implement Cards Screen"]
        T008["TASK-008: Implement Portfolio Screen"]
        T009["TASK-009: Implement Settings Screen"]
        T010["TASK-010: Quick Action Modals (Deposit/Invest)"]
    end

    subgraph Milestone 4: Backend & Ledger
        T011["TASK-011: Setup Supabase/NestJS Backend"]
        T012["TASK-012: Dio API Client & Interceptors"]
        T013["TASK-013: Double-Entry Postgres Ledger"]
        T014["TASK-014: Idempotent Transfer Gateway"]
    end

    subgraph Milestone 5: Security Hardening
        T005["TASK-005: Biometric Vault & LocalAuth"]
        T015["TASK-015: PAN/CVV Ephemeral Masking"]
        T016["TASK-016: App Switcher Privacy Veil"]
        T017["TASK-017: Obfuscation & R8 Release Build"]
    end

    subgraph Milestone 6: Release & QA
        T018["TASK-018: Golden & Widget Test Suite"]
        T019["TASK-019: CI/CD Pipeline (GitHub Actions)"]
        T020["TASK-020: Production Store Submission"]
    end

    %% Dependency Connections
    T001 --> T002
    T002 --> T003
    T003 --> T006
    T003 --> T004
    
    %% Parallel UI tracks
    T004 --> T007
    T004 --> T008
    T004 --> T009
    T004 --> T010

    %% Backend Tracks
    T003 --> T011
    T011 --> T012
    T011 --> T013
    T012 --> T014
    T013 --> T014
    T010 --> T014

    %% Security Tracks
    T006 --> T005
    T005 --> T015
    T007 --> T015
    T005 --> T016
    T016 --> T017

    %% Final Release Gates
    T007 & T008 & T009 & T014 & T015 --> T018
    T018 --> T019
    T017 & T019 --> T020

    classDef critical fill:#ff3366,stroke:#fff,stroke-width:2px,color:#fff;
    classDef high fill:#00ffa3,stroke:#111,stroke-width:1px,color:#000;
    classDef medium fill:#00e5ff,stroke:#111,stroke-width:1px,color:#000;

    class T001,T002,T003,T005,T014,T020 critical;
    class T004,T007,T011,T012,T015,T018 high;
    class T006,T008,T009,T010,T013,T016,T017,T019 medium;
```

---

## 2. Critical Path Analysis
The **Critical Path** (the longest sequence of dependent activities that determines project duration) is:
$$\text{TASK-001} \rightarrow \text{TASK-002} \rightarrow \text{TASK-003} \rightarrow \text{TASK-011} \rightarrow \text{TASK-012} \rightarrow \text{TASK-014} \rightarrow \text{TASK-018} \rightarrow \text{TASK-020}$$

* **Minimum Duration to Production:** 26 business days with 1 full-time senior developer.
* **Bottleneck Risk:** Backend deployment and database schema finalization (TASK-011) directly gates live ledger syncing and transfer execution.

---

## 3. External Dependencies & Blockers Table

| Dependency Name | Type | Purpose | Risk if Delayed | Mitigation Plan |
|---|---|---|---|---|
| **Apple Developer Account** | Institutional | iOS Signing, TestFlight, FaceID entitlement | Cannot distribute to iPhone users | Enroll immediately under corporate entity |
| **Google Play Console** | Institutional | Android production release | Delays Android rollout | Create developer account and complete 14-day tester requirements |
| **Supabase / PostgreSQL Server** | Infrastructure | Real-time database, Auth, RLS | Blocks Milestone 4 | Develop locally first using Docker PostgreSQL container |
| **Payment / Ramp Gateway** | External Partner | Processing real fiat wire transfers (Stripe/Plaid) | Live money transfer remains in sandbox | Use mock sandbox API credentials during development |
| **Hardware Devices** | Physical Testing | Testing 3D tilt gyro, biometric FaceID, haptics | Visual bugs on real OLED/Retina screens | Test on user's local iPhone and Android physical devices |
