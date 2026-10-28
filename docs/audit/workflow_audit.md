# User Journey & Workflow Audit: Lumina Wealth (`lumina_fintech`)

This document audits the critical user journeys, maps system interactions, and specifies failure recovery workflows.

---

## 1. Journey 1: First Launch & Authentication Flow

### Current vs. Target Reality
* **Current State:** The app directly launches into `DashboardScreen` with a hardcoded user identity (`Roshan Chachre`) and zero authentication barrier.
* **Target State:** Production-grade security requires a biometric vault with passkey / local auth and backend session verification.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant App as Lumina Mobile App
    participant OS as Secure Enclave (FaceID/Biometrics)
    participant AuthAPI as Auth Service / Backend
    participant DB as Postgres (Supabase/NestJS)

    User->>App: Launch App
    App->>App: Check Local Token in Secure Storage
    alt Token Missing or Expired
        App->>User: Display Onboarding / Login Screen
        User->>App: Enter Credentials / Passkey
        App->>AuthAPI: Authenticate Request
        AuthAPI->>DB: Verify User Hash
        DB-->>AuthAPI: User Confirmed
        AuthAPI-->>App: Return JWT & Refresh Token
        App->>App: Store in FlutterSecureStorage
    else Token Present & Valid
        App->>OS: Request Biometric Prompt ("Unlock Lumina Wealth")
        OS-->>App: Biometric Match Confirmed
    end
    App->>AuthAPI: Fetch Account Snapshot (Balance, Cards, Txs)
    AuthAPI-->>App: Return Decrypted Dashboard Payload
    App->>User: Mount Animated DashboardScreen
```

---

## 2. Journey 2: 3D Card Interaction & Card Freeze Workflow

The virtual/physical card acts as a high-security hardware proxy.

```mermaid
stateDiagram-v2
    [*] --> FrontView: Dashboard Loaded
    FrontView --> Tilting3D: Pan Gesture Detected
    Tilting3D --> FrontView: Pan Released (Spring Snap-Back)
    FrontView --> FlippingToBack: Tap Card (700ms 3D Rotation)
    FlippingToBack --> BackView: Display CVV, PAN, Controls
    BackView --> FlippingToFront: Tap Card / Background
    FlippingToFront --> FrontView: Reset to Front
    
    state BackView {
        [*] --> ActiveState
        ActiveState --> FreezeRequested: Toggle Freeze Switch
        FreezeRequested --> BiometricAuth: Request Biometric Confirmation
        BiometricAuth --> FreezeConfirmed: Auth Success
        FreezeConfirmed --> FrozenOverlay: Update State & API Call
        FrozenOverlay --> ActiveState: Toggle Unfreeze Switch
    }
```

### Detailed Interaction Breakdown:
1. **Initiation:** User drags finger across the card.
2. **Physics & Transform:** `_InteractiveCardState._onPanUpdate` computes normalized delta offsets:
   $$\theta_x = \text{clamp}(\theta_x + \Delta y \times 0.0012, -0.35, +0.35)$$
   $$\theta_y = \text{clamp}(\theta_y - \Delta x \times 0.0012, -0.35, +0.35)$$
3. **Card Sheen:** A moving diagonal gradient (`LuminaColors.glassSheen`) translates across the titanium surface proportionally to $\theta_x, \theta_y$.
4. **Flipping:** On single tap, `_flipController.forward()` executes a $180^\circ$ Y-axis rotation using `Curves.easeInOutBack`.
5. **Freeze Action:** When the user flips to the back and hits "Freeze Card", a local state change currently disables the card. In production, this must invoke an atomic API call: `PATCH /api/v1/cards/{id}/status`.

---

## 3. Journey 3: Slide-to-Confirm Instant Wire Transfer

This journey is the primary financial movement within Lumina Wealth.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Screen as DashboardScreen
    participant Modal as _QuickSendModal
    participant Slider as SlideToSendButton
    participant Backend as Fintech API Gateway
    participant Ledger as Immutable Ledger / Blockchain L2

    User->>Screen: Tap "Transfer" Action Button
    Screen->>Modal: Open BottomSheet (Haptic Heavy Impact)
    Modal->>User: Display Recipient, Amount ($1,250), Gas Fee ($0.00)
    User->>Slider: Drag Glowing Thumb to the Right
    Slider-->>User: Light Haptic Tick at 50% Drag
    alt Released before 88%
        Slider->>Slider: Elastic Snap-back to Origin (Curves.easeOutBack)
    else Dragged $\ge$ 88%
        Slider->>Slider: Lock Thumb at Maximum Width
        Slider->>Modal: Trigger onConfirmed()
        Modal->>Modal: Haptic Heavy Impact
        Modal->>Backend: POST /api/v1/transfers (with Idempotency Key)
        Backend->>Ledger: Atomic Balance Debit & Credit
        Ledger-->>Backend: Block / DB Confirmation
        Backend-->>Modal: HTTP 200 OK (Tx Hash: 0x8a9f...)
        Modal->>Modal: Display "TRANSFER SUCCESSFUL" Badge
        Modal-->>User: Auto-dismiss Modal after 1400ms
        Screen->>Screen: Trigger Balance Decrement & Append Transaction
    end
```

### Edge Cases & Failure Scenarios:
1. **Network Drop During Slide Completion:**
   * *Problem:* User drags past 88%, slider locks, but network request fails.
   * *Current Behavior:* Unchecked `Future.delayed` closes the modal regardless, showing fake success.
   * *Required Behavior:* Display retry dialog with exponential backoff; never show "TRANSFER SUCCESSFUL" without verified 200 OK response from API.
2. **Duplicate Submissions:**
   * *Protection:* The slider thumb locks immediately upon hitting 88%, preventing double-drag. A client-generated UUID v4 idempotency key must accompany the API request to prevent duplicate debiting on network retries.

---

## 4. Journey 4: Touch-Scrubbing Historical Wealth Spline

1. **Initiation:** User places finger on `GlowChart`.
2. **Gesture Capture:** `_onPanUpdate(details, width)` clamps the touch position:
   $$x_{scrub} = \text{clamp}(\text{localPosition.dx}, 0, W)$$
3. **Coordinate Mapping:** The widget calculates the closest historical data slice:
   $$\text{index} = \text{round}\left( \frac{x_{scrub}}{W} \times (N - 1) \right)$$
4. **Drawing Output:**
   * Vertical cyan laser line drawn with `Color(0x8000E5FF)`.
   * Glow cursor drawn with solid white center and neon cyan halo.
   * Dynamic valuation tooltip displays current price at that exact hour/day.
5. **Release:** On `onPanEnd`, the scrub line smoothly fades out over 300ms.
