# Lumina Fintech • Sovereign Wealth & Multi-Asset Neo-Banking Suite

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.11.5%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Express.js](https://img.shields.io/badge/Express.js-4.21-000000?style=for-the-badge&logo=express&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-3-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Tests Passing](https://img.shields.io/badge/Tests-83%2F83%20Passing-brightgreen?style=for-the-badge&logo=checkmarx&logoColor=white)
![License](https://img.shields.io/badge/License-Proprietary-D4FF24?style=for-the-badge)

**Next-generation sovereign wealth management and neo-banking platform engineered for mobile and tablet form factors.**

[Visual Showcase](#-visual-showcase) • [Architecture](#-system-architecture) • [Features](#-key-features) • [Installation & Setup](#-how-to-run) • [Testing](#-testing--quality-assurance)

</div>

---

## 🌟 Overview

**Lumina Fintech** is a cyber-aesthetic neo-banking client and enclave backend built for modern sovereign wealth management. Designed from the ground up using **Flutter & BLoC state management**, Lumina pairs real-time multi-asset portfolio tracking (Fiat USD/USDC, Arbitrum L2 Staked ETH, Sovereign Tokenized Gold, and Tech Equities) with bank-grade security protocols.

The user experience features interactive **3D accelerometer tilt physics**, seamless **Biometric Face ID / Touch ID direct vault unlock**, dynamic single-use **rolling CVVs**, a multi-tier **Physical & Virtual Card Issuance suite**, and real-time **notification badge synchronization**. Lumina features an adaptive layout engine that delivers an optimized, responsive experience across compact smartphones (320px–430px) and wide-canvas tablets (768px+ iPad).

---

## 📸 Visual Showcase

### Adaptive Experience • Mobile & Tablet Side-by-Side

<div align="center">
  <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/responsive_showcase.png" alt="Lumina Responsive Showcase - Mobile & Tablet" width="100%" />
</div>

<br/>

### Form Factor Comparison Matrix

Lumina's layout engine dynamically scales and restructures views based on viewport constraints, ensuring high data density and comfortable touch targets on both mobile handsets and tablets.

<table>
  <thead>
    <tr>
      <th width="32%" align="center">📱 Mobile View (iPhone 16 Pro)</th>
      <th width="68%" align="center">📟 Tablet View (iPad Mini)</th>
    </tr>
  </thead>
  <tbody>
    <!-- Row 1: Dashboard -->
    <tr>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/mobile_dashboard.png" width="280" alt="Mobile Dashboard" /><br/>
        <b>Master Net Worth & 1D/1W/1M Spend Chart</b>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/tablet_dashboard.png" width="580" alt="Tablet Dashboard" /><br/>
        <b>Expanded Multi-Asset Overview & Live Activity Stream</b>
      </td>
    </tr>
    <!-- Row 2: Cards Management -->
    <tr>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/mobile_cards.png" width="280" alt="Mobile Cards" /><br/>
        <b>3D Accelerometer Tilt Cards & Security Controls</b>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/tablet_cards.png" width="580" alt="Tablet Cards" /><br/>
        <b>Dual-Pane Card Vault with Instant Spend Limit Controls</b>
      </td>
    </tr>
    <!-- Row 3: Portfolio & Wealth Allocation -->
    <tr>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/mobile_portfolio.png" width="280" alt="Mobile Portfolio" /><br/>
        <b>Holdings & Compounding Yield Distribution</b>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/tablet_portfolio.png" width="580" alt="Tablet Portfolio" /><br/>
        <b>High-Density Multi-Asset Allocation Grid</b>
      </td>
    </tr>
    <!-- Row 4: Settings & Security Vault -->
    <tr>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/mobile_settings.png" width="280" alt="Mobile Settings" /><br/>
        <b>Biometric Enclave & Discrete Privacy Controls</b>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/tablet_settings.png" width="580" alt="Tablet Settings" /><br/>
        <b>Settlement Network Routing & Vault Access Locks</b>
      </td>
    </tr>
  </tbody>
</table>

<br/>

### Dedicated Workflows & Mobile Capabilities

Lumina replaces standard modal bottom sheets with dedicated, full-screen interactive journeys:

<div align="center">
<table>
  <thead>
    <tr>
      <th width="33%" align="center">💳 Card Issuance Flow</th>
      <th width="33%" align="center">🔔 Real-Time Notifications</th>
      <th width="33%" align="center">📈 Comprehensive Activities</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/mobile_card_issuance.png" width="260" alt="Card Issuance Flow" /><br/>
        <em>4-tier issuance (Obsidian, Cosmic, Gold, Stealth) with PIN config & limits</em>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/mobile_notifications.png" width="260" alt="Notifications Inbox" /><br/>
        <em>Live badge sync, category filters, and swipe-to-mark actions</em>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/Roshanchachre/lumina_fintech/main/docs/screenshots/mobile_activities.png" width="260" alt="Activities Timeline" /><br/>
        <em>Full-ledger search, transaction filtering, and audit trail breakdown</em>
      </td>
    </tr>
  </tbody>
</table>
</div>

---

## ⚡ Key Features

### 💳 Physical & Virtual Card Vault
- **Multi-Tier Card Architecture:**
  - `Obsidian Black Metal`: High-durability titanium physical card with 1% cashback on all L2 settlements.
  - `Cosmic Neon Aura`: Holographic finish card for international travel and frictionless FX conversions.
  - `Cyber Liquid Gold`: Premium 24K gold-plated card with dedicated concierge and lounge access.
  - `Phantom Stealth Virtual`: Disposable virtual card with dynamic CVV renewal for secure online commerce.
- **3D Tilt Interaction:** Gyroscopic hardware sensors (`sensors_plus`) drive real-time 3D rotation, metallic reflection shaders, and holographic glares.
- **Dedicated Issuance Flow:** Complete multi-step issuance pipeline (Tier selection $\rightarrow$ Limit configuration $\rightarrow$ Review & biometric confirmation $\rightarrow$ Instant activation) without cluttered bottom sheets.
- **Instant Freeze & Limits:** One-tap toggle to freeze card rails, configure daily spend ceilings, or re-encrypt the ATM PIN.

### 🔒 Bank-Grade Security & Biometric Enclave
- **Direct Biometric Unlock:** Face ID / Touch ID hardware integration (`local_auth`) with zero redundant password prompts on successful verification.
- **Graceful Fallback:** Secure PIN/Password authentication path automatically surfaces if biometrics fail or device sensors are unavailable.
- **Discrete Gaze Privacy Shield:** Double-tap balance or shake handset to immediately mask sensitive net worth and transaction values.
- **Secure Key Storage:** Access tokens and session keys encrypted in device hardware keychains via `flutter_secure_storage`.

### 📊 Dynamic Wealth Allocation & Real-Time Charts
- **Multi-Asset Portfolio:** Track liquid fiat (USD/USDC), staking yields (Arbitrum wstETH 4.8% APY), tokenized commodities (PAXG Gold 1.5% APY), and equities (TECH-INDEX 14.2% APY).
- **Interactive Spending Graphs:** Custom cubic spline chart painters supporting dynamic `1D`, `1W`, and `1M` time horizons with smooth touch scrubbing.
- **Wire Transfers & Settlements:** Instant multi-currency transfers with validation and sound design.

### 🎨 Midnight Neo Visual & Acoustic Identity
- **Design Tokens:** Deep obsidian black canvas (`#030407`), electric cobalt (`#1558C9`), and acid lime accents (`#D4FF24`).
- **Tactile Sound Design:** Spatial acoustic feedback (`audioplayers`) on vault unlock, wire transfers, and card issuance.
- **Lumi Fox Mascot:** 3-screen animated onboarding tour guiding users through sovereign custody features.

---

## 🏗️ System Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                        LUMINA CLIENT (FLUTTER)                         │
├────────────────────────────────────────────────────────────────────────┤
│  Presentation Layer (lib/screens/ & lib/widgets/)                      │
│  ├── MainShellScreen (Adaptive Navigation Rail / Dock)                 │
│  ├── DashboardScreen, CardsScreen, PortfolioScreen, SettingsScreen     │
│  ├── Dedicated Flows: IssueCardScreen, NotificationsScreen, Activities │
│  └── Custom Graphics: ChartPainter, InteractiveCard (3D Sensor Tilt)   │
├────────────────────────────────────────────────────────────────────────┤
│  State Management (lib/bloc/)                                          │
│  ├── AccountBloc (Net Worth, Cards, Activities, Notifications Sync)    │
│  └── AuthBloc (Biometrics, Credentials, OTP, Profile State Machine)    │
├────────────────────────────────────────────────────────────────────────┤
│  Data & Domain Layer (lib/repositories/ & lib/models/)                 │
│  ├── AccountRepository (Cached state & HTTP sync)                      │
│  ├── AuthRepository (Session lifecycle & profile sync)                 │
│  ├── ApiClient (Dio HTTP interceptors, timeouts, token injection)      │
│  └── TransferRepository (Wire transfer execution & validation)         │
├────────────────────────────────────────────────────────────────────────┤
│  Device Hardware Bridge (lib/services/)                                │
│  ├── BiometricService (LocalAuth Face ID / Touch ID)                   │
│  ├── SoundService (Spatial acoustic feedback)                          │
│  └── SensorsPlus (Accelerometer & Gyroscope hardware listeners)        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTPS / REST (JSON + Bearer JWT)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   ENCLAVE BACKEND SERVICE (NODE.JS)                    │
├────────────────────────────────────────────────────────────────────────┤
│  Express API Gateway (server/src/index.js)                             │
│  ├── Auth Router: /auth/register, /auth/login, /auth/verify-otp        │
│  ├── Profile Router: /profile, /profile/avatar                         │
│  ├── Vault Router: /vault/cards, /vault/transfer, /vault/activities    │
│  └── Notification Router: /notifications, /notifications/mark-read     │
├────────────────────────────────────────────────────────────────────────┤
│  Security & Persistence Engine                                         │
│  ├── Password Hashing: Bcrypt (12 rounds)                              │
│  ├── Session Security: RS256 / HS256 JWT Signature Engine             │
│  ├── Verification: Nodemailer automated OTP dispatch                   │
│  └── Embedded Database: SQLite3 with relational foreign key integrity   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
lumina_fintech/
├── assets/
│   ├── avatars/              # 8 custom male & female cyberpunk avatars
│   └── sounds/               # Haptic & spatial acoustic audio cues
├── docs/
│   └── screenshots/          # High-resolution mobile & tablet visual assets
├── lib/
│   ├── bloc/                 # BLoC state machines (AccountBloc, AuthBloc)
│   ├── models/               # Domain models (User, Card, Activity, Notification)
│   ├── repositories/         # ApiClient, AuthRepository, AccountRepository
│   ├── screens/              # 21 feature screens & dedicated flow destinations
│   ├── services/             # Biometrics, Hardware Sensors, Sound engine
│   ├── theme/                # Midnight Neo design tokens, typography, colors
│   └── widgets/              # Reusable UI components & custom painters
├── server/
│   ├── src/
│   │   ├── db/               # SQLite schema, migrations, seed generators
│   │   └── index.js          # Express microservice & authentication endpoints
│   ├── .env.example          # Environment variables template
│   └── package.json          # Node.js dependencies & scripts
├── test/
│   ├── unit/                 # Unit tests (BLoCs, Repositories, Biometrics, API)
│   └── widget/               # Widget tests & responsive multi-device audits
├── tool/
│   └── capture_screenshots.dart # Headless retina screenshot generator
├── pubspec.yaml              # Flutter package manifest & assets
└── README.md                 # Project documentation & run guide
```

---

## 🚀 How to Run

### 📋 Prerequisites

Ensure you have the following installed on your machine:
- **Flutter SDK** (v3.11.5 or newer) $\rightarrow$ [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (v3.0.0 or newer)
- **Node.js** (v18.0.0 or newer) & **npm** $\rightarrow$ [Install Node.js](https://nodejs.org/)
- **Xcode** (for iOS simulator & macOS desktop) or **Android Studio** (for Android emulator)

---

### Step 1: Clone the Repository

```bash
git clone https://github.com/Roshanchachre/lumina_fintech.git
cd lumina_fintech
```

---

### Step 2: Start the Enclave Backend Service

The Flutter client connects to an Express + SQLite microservice providing authentication, session tokens, OTP generation, and ledger endpoints:

```bash
# Navigate to the backend directory
cd server

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env

# Start the server (runs on port 4040 by default)
npm start
```

> **Tip:** If running on a physical mobile device, replace `localhost` with your machine's local Wi-Fi IP address (e.g. `192.168.1.4`) in `lib/repositories/api_client.dart`.

---

### Step 3: Run the Flutter Client

Open a new terminal window in the root directory:

```bash
# Fetch Flutter dependencies
flutter pub get

# Check connected devices
flutter devices

# Run on an iPhone Simulator / Device
flutter run -d ios

# Run on an iPad Simulator (to test Tablet View)
flutter run -d "iPad mini (6th generation)"

# Run on Android Emulator / Device
flutter run -d android

# Run as native macOS Desktop application
flutter run -d macos
```

---

### Step 4: Demo Credentials & Instant Login

You can create a new account directly in the app (with avatar selection, profile setup, and OTP verification), or sign in immediately using the pre-seeded account:

| Field | Demo Credential |
| :--- | :--- |
| **Email** | `demo@lumina.vault` |
| **Password** | `Password@123` |
| **PIN Code** | `1337` |
| **Biometric Auth** | Enrolled device biometric (Face ID / Touch ID / Fingerprint) |

---

## 🧪 Testing & Quality Assurance

Lumina features a comprehensive automated test suite with **83 unit and widget tests** covering authentication, biometric edge cases, financial calculations, card issuance validation, and responsive overflow checks across 5 device viewports.

### Run All Tests

```bash
flutter test
```

### Run Static Analysis

```bash
flutter analyze
```

### Viewport & Responsive Breakpoint Coverage

The test suite validates responsive behavior across:
- **iPhone SE (1st gen)**: 320 × 568 pt (Narrow compact layout check)
- **iPhone 8**: 375 × 667 pt (Standard compact)
- **iPhone 16 Pro**: 393 × 852 pt (Modern flagship mobile)
- **iPhone 16 Pro Max**: 430 × 932 pt (Large mobile display)
- **iPad Mini (6th gen)**: 768 × 1024 pt (Tablet view with dual-column layout)

### Regenerate Showcase Screenshots

To re-capture all retina mobile and tablet screenshots:

```bash
flutter test tool/capture_screenshots.dart
```

---

## 🔐 Environment Configuration

The backend service uses the following environment variables (`server/.env`):

```ini
PORT=4040
JWT_SECRET=lumina_vault_production_secure_token_secret_key_2026
REFRESH_TOKEN_SECRET=lumina_vault_refresh_token_ultra_secure_key_2026
ENCRYPTION_KEY=lumina_enclave_32_byte_secret_key_hex_2026
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=notifications@luminavault.com
EMAIL_PASS=your_app_specific_password_here
```

---

## 🛠️ Tech Stack & Key Libraries

- **Framework:** [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management:** [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (Event-driven reactive streams)
- **Networking:** [`dio`](https://pub.dev/packages/dio) (HTTP client with JWT authorization interceptors)
- **Biometrics:** [`local_auth`](https://pub.dev/packages/local_auth) (Hardware Face ID & Touch ID integration)
- **Sensors:** [`sensors_plus`](https://pub.dev/packages/sensors_plus) (Accelerometer-driven 3D card tilt)
- **Audio Engine:** [`audioplayers`](https://pub.dev/packages/audioplayers) (Spatial sound design & haptic audio cues)
- **Secure Vault:** [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) (Hardware Keychain & Keystore encryption)
- **Typography & Polish:** [`google_fonts`](https://pub.dev/packages/google_fonts), [`flutter_animate`](https://pub.dev/packages/flutter_animate)
- **Backend:** Node.js, Express.js, SQLite3, Bcrypt.js, JSON Web Tokens

---

## 👤 Author

**Roshan Chachre**  
- GitHub: [@Roshanchachre](https://github.com/Roshanchachre)  
- Project Repository: [lumina_fintech](https://github.com/Roshanchachre/lumina_fintech)

---

## 📄 License

This project is proprietary and confidential. All rights reserved.
