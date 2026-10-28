# Architecture Decision Register (ADR): Lumina Wealth (`lumina_fintech`)

This register records the key technical and architectural decisions made for Lumina Wealth, including context, alternatives considered, and consequences.

---

### ADR-001: Selection of BLoC as Primary State Management Pattern
* **Status:** APPROVED  
* **Context:** The application currently relies entirely on `setState()` inside StatefulWidgets, making cross-screen state sharing impossible and creating tight coupling between UI and data logic.  
* **Alternatives Considered:**
  1. *Riverpod:* Modern and lightweight, but looser separation between business events and presentation.
  2. *Provider:* Older, lacks event-driven architectural rigor needed in institutional fintech.
  3. *BLoC (Business Logic Component):* Strict event-driven architecture; stream-based; easily auditable state transitions.  
* **Decision:** Adopt `flutter_bloc` with `freezed` state unions.  
* **Consequences:** Predictable unidirectional data flow; high testability with `bloc_test`; slightly higher initial boilerplate.

---

### ADR-002: Navigation via GoRouter StatefulShellRoute
* **Status:** APPROVED  
* **Context:** The floating glass capsule dock needs to switch between 4 primary application pillars (Dashboard, Cards, Portfolio, Settings) without destroying screen scroll positions or 3D card tilt states.  
* **Alternatives Considered:**
  1. *Imperative Navigator 1.0 (`Navigator.push`):* Causes route stacking and re-builds screens on tab switch.
  2. *IndexedStack in a single Widget:* Feasible, but does not support deep linking or URL routing on web/tablet.
  3. *GoRouter `StatefulShellRoute.indexedStack`:* Modern declarative routing that maintains independent navigation stacks per tab.  
* **Decision:** Adopt `go_router` with `StatefulShellRoute`.  
* **Consequences:** Persistent state across tab switches; deep-link ready; clean URL mapping.

---

### ADR-003: Double-Entry Ledger & UUID v4 Idempotency for Transfers
* **Status:** APPROVED  
* **Context:** Wire transfers triggered via the slide-to-send gesture must be mathematically immune to race conditions, double submissions, or partial network failures.  
* **Decision:** 
  1. Client generates a UUID v4 `idempotency_key` on drag initiation.
  2. Backend processes transactions within an atomic SQL transaction block (debit sender, credit recipient, record ledger entry).
  3. Backend stores processed keys in Redis / PostgreSQL with a 24-hour expiration.  
* **Consequences:** Guarantees zero duplicate debiting under network retries; auditable double-entry accounting.

---

### ADR-004: Lightweight CustomPainter vs. Heavy Chart Libraries
* **Status:** APPROVED  
* **Context:** Financial charts in Lumina require glowing neon Bezier curves, custom touch scrubbing, and glass styling.  
* **Alternatives Considered:**
  1. *`fl_chart`:* Widely used, but styling custom blur filters, glowing gradients, and specific haptic scrubbing behavior is cumbersome and adds heavy package overhead.
  2. *Native `CustomPainter` (Current Implementation):* Already implemented in `glow_chart.dart` with dual-pass blur and hardware-accelerated Bezier paths.  
* **Decision:** Retain and optimize the existing `CustomPainter` implementation in `glow_chart.dart`.  
* **Consequences:** Zero external chart dependencies; 60 FPS performance; complete design control over neon aesthetics.
