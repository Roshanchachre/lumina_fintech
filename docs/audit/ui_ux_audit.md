# UI/UX & Visual Design Audit: Lumina Wealth (`lumina_fintech`)

This document audits the user experience, motion design, visual ergonomics, and accessibility of Lumina Wealth.

---

## 1. Visual Hierarchy & Aesthetic Excellence

### 1.1 The Lumina Aesthetic
The visual language is modern, dark-mode luxury fintech ("Neo-Brutalist Luxury"). It draws inspiration from Apple Card, Linear, and high-end Web3 platforms.
* **Palette:** Deep Space Obsidian (`#07090E`), Surface Charcoal (`#10141E`), Elevated Blue-Black (`#161C2A`).
* **Accents:** Neon Green (`#00FFA3`), Neon Cyan (`#00E5FF`), Neon Purple (`#8B5CF6`).
* **Typography:**
  * **Headlines & Figures:** `GoogleFonts.spaceGrotesk` (Monospaced, high-tech, numerical clarity).
  * **Body & UI Controls:** `GoogleFonts.plusJakartaSans` (Clean geometric sans-serif for readability).
* **Lighting & Glass:**
  * Ambient radial glow backgrounds (`RadialGradient` with 8–9% opacity).
  * Frosted glass capsules (`Border.all(color: LuminaColors.surfaceBorder, width: 1.2)`).

---

## 2. Interaction & Motion Design Audit

| Interaction / Widget | Implemented Curve | Frame Budget / Performance | Audit Verdict |
|---|---|---|---|
| **Card Pan & Tilt** | 3D Transform (`Matrix4`) | 60 FPS (Hardware Accelerated) | **Exceptional.** Clamped to $\pm 0.35$ rad, prevents extreme distortion. |
| **Card Flip (Front to Back)** | `Curves.easeInOutBack` (700ms) | 60 FPS | **Exceptional.** Backside flips correctly without mirror reflection inversion. |
| **Card Snap-Back** | `Curves.elasticOut` (600ms) | 60 FPS | **Smooth.** Natural physical spring return. |
| **Rolling Balance Ticker** | `Curves.easeOutExpo` (900ms) | 60 FPS | **High Quality.** Number values roll smoothly without layout jank. |
| **Spline Glow Chart** | `CustomPainter` + `Curves.easeOutCubic` | 60 FPS | **High Quality.** Antialiased spline with dual-pass neon glow. |
| **Slide-to-Send Gesture** | Elastic snap-back / 88% threshold | 60 FPS | **Intuitive.** Haptic tick at 50% provides tactile anticipation before commitment. |

---

## 3. UI/UX Deficiencies & Missing States

### 3.1 Missing Screens & Dead-End Touch Targets
1. **Dock Navigation Tabs (Cards, Portfolio, Settings):**
   * *Finding:* Tapping "Cards", "Portfolio", or "Settings" highlights the pill but keeps the user on the same Dashboard screen.
   * *Severity:* Critical UX Blocker.
2. **Quick Action Deck ("Deposit", "Invest", "More"):**
   * *Finding:* Tapping Deposit or Invest only emits `HapticFeedback.lightImpact()`. No sheet or modal appears.
   * *Severity:* High.
3. **"View All" Activity Link:**
   * *Finding:* The "VIEW ALL" button next to RECENT ACTIVITY is completely non-functional.
   * *Severity:* Medium.
4. **Notification Bell:**
   * *Finding:* Displays a static neon green unread indicator dot, but tapping it does nothing.
   * *Severity:* Medium.

### 3.2 Loading, Empty & Error States Audit
* **Dashboard Data Loading:** Currently absent. If data is fetching, there is no shimmer or skeleton loader.
* **Empty Transaction List:** There is no empty state illustration or text for accounts with zero transactions.
* **Offline / Network Loss Banner:** App does not notify the user when the internet connection drops.

### 3.3 Accessibility & Text Scaling (WCAG 2.1 AA)
* **Contrast Ratios:** Neon Green (`#00FFA3`) on Dark Space (`#07090E`) exceeds 12:1 contrast ratio (AAA compliant).
* **Muted Text Contrast:** `LuminaColors.textMuted` (`#64748B`) on `#07090E` provides a ~4.2:1 contrast ratio, falling slightly below the 4.5:1 AA standard for small 11pt labels.
* **Text Scaling:** Hardcoded font sizes (`fontSize: 38`, `fontSize: 42`) without `maxScaleFactor` can cause overflow on devices with accessibility font scaling set to > 1.3x.
