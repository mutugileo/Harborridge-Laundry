# Harborridge Laundry Service — Design System (`DESIGN.md`)

This document defines the canonical visual language, token architecture, harmonized typography scale, spacing grid, and motion rules for **Harborridge Laundry Service** (`Laundry Ridge`).

---

## 1. Brand Identity & Color Tokens ([`lib/app/theme/app_colors.dart`](lib/app/theme/app_colors.dart))

All surfaces, text, badges, and charts consume semantic tokens via `context.colors` (`AppColors` `ThemeExtension`). Hardcoded unthemed colors are forbidden in feature widgets.

| Token Name | Light Mode Hex | Dark Mode Hex | Role & Surface Usage |
| :--- | :--- | :--- | :--- |
| `harborNavy` / `brandPrimary` | `#152042` | `#2DA1E7` | Primary brand header banner, primary CTAs, active filter pills, sidebar brand accents |
| `freshSkyBlue` / `brandSecondary` | `#2DA1E7` | `#2DA1E7` | Basket logo, active states, secondary action buttons, chart primary bars |
| `harborGold` | `#DCA842` | `#DCA842` | Brand wordmark accent, VIP badges, chart spline curves, security PIN highlights |
| `accentGreen` / `statusSuccess` | `#1E9E6A` | `#10B981` | Paid badges, completed SLA indicators, restock confirmations |
| `statusError` | `#DC2626` | `#EF4444` | Low-stock reorder alerts, excepted menu badges, auth validation banners |
| `background` | `#EEF3F8` | `#0E162B` | App-wide canvas background and subtle input fills |
| `surface` | `#F5F8FC` | `#152244` | Nested row containers, secondary panels, table headers |
| `cardBackground` | `#FFFFFF` | `#162347` | Elevated module cards, sidebar container, dialogs, invoice sheet |
| `borderSubtle` | `#DCE5F0` | `#253864` | 1px card, input, and table row dividers |
| `textPrimary` | `#152042` | `#F8FAFC` | Headings, KPI figures, primary row labels |
| `textSecondary` | `#52637A` | `#9FB0C7` | Subtitles, metadata captions, table secondary columns |
| `textTertiary` | `#8798AD` | `#6E829E` | Input hints, disabled controls, axis labels |

---

## 2. Harmonized 8-Step Typography Scale ([`lib/app/theme/app_typography.dart`](lib/app/theme/app_typography.dart))

The application uses **`Lexend`** across all 13 feature modules. Every text element in `lib/` adheres to the **8-Step Harmonized Type Scale** (no fractional `.5` sizes or off-scale integers):

| Scale Token | Size (`px`) | Weight(s) | Material `TextTheme` Slot | Canonical Usage Across Modules |
| :--- | :--- | :--- | :--- | :--- |
| `AppTypography.microSize` | **`10.0`** | `w700` – `w800` | Micro Badge | Compact status pills, SKU codes (`INV-01`), menu count pills (`13/13 Menus`) |
| `AppTypography.captionSize` | **`11.0`** | `w600` – `w700` | `labelSmall` | Table column headers, filter chips, form field labels, secondary metadata |
| `AppTypography.bodySmallSize` | **`12.0`** | `w400` – `w700` | `bodySmall` / `labelMedium` | Sidebar navigation items, table cells, card descriptions, secondary buttons |
| `AppTypography.bodySize` | **`13.0`** | `w500` – `w700` | `bodyMedium` / `labelLarge` | Primary row titles, form text inputs, primary CTA button labels |
| `AppTypography.subtitleSize` | **`14.0`** | `w700` | `titleSmall` / `bodyLarge` | List card titles (SKU name, customer name, vendor branch name) |
| `AppTypography.sectionTitleSize` | **`16.0`** | `w700` | `titleMedium` | Section card headers (`Order Statistics`, `Supplier Reorder Queue`, `Service Addons`) |
| `AppTypography.pageTitleSize` | **`18.0`** | `w700` – `w800` | `titleLarge` | Top module banner titles (`Operations Overview`, `All Laundry Orders`, `Staff Roster`) |
| `AppTypography.kpiDisplaySize` | **`22.0`** | `w800` – `w900` | `headlineSmall` / `displayMedium` | Primary KPI figures (`$48,574`, `2,152`, `KES 184,600`, `96.4%`) |

> **Exception**: Only [`HarborridgeLogo`](lib/core/widgets/harborridge_logo.dart) uses fixed vector badge micro-labels (`6.8px` and `8.5px`) locked to the custom-painted laundry basket geometry.

---

## 3. Spacing, Radius & Elevation Scale ([`lib/app/theme/app_spacing.dart`](lib/app/theme/app_spacing.dart))

Accessed via `context.spacing`:

- **Spacing Grid**:
  - `xs`: `4.0px` (inline icon-to-label gap)
  - `sm`: `8.0px` (chip spacing, compact vertical stack)
  - `md`: `16.0px` (standard card grid gap & inner padding)
  - `lg`: `24.0px` (module card outer padding)
  - `xl`: `32.0px` (split-screen column separation)
  - `xxl`: `48.0px` (major layout section rhythm)
- **Corner Radii**:
  - Primary Module Cards: `14.0px` – `16.0px` (`spacing.cardRadius`)
  - Interactive Rows & Inputs: `8.0px` – `10.0px`
  - Status & Filter Pills: `99.0px` (full capsule)
- **Elevation Shadow**:
  - Standard Card Shadow: `BoxShadow(color: Color(0x140F172A), blurRadius: 24.0, offset: Offset(0, 8))`
  - KPI Card Shadow: `BoxShadow(color: Color(0x120F172A), blurRadius: 18.0, offset: Offset(0, 6))`

---

## 4. Motion & Micro-Interaction Tokens ([`lib/app/theme/app_motion.dart`](lib/app/theme/app_motion.dart))

Accessed via `context.motion`:

- `shortDuration`: `150ms` (`Curves.easeInOutCubic`) — filter pill active state, button press scale ([`InteractivePressScale`](lib/core/widgets/interactive_press_scale.dart)), hover highlights, feedback banners.
- `mediumDuration`: `300ms` (`Curves.easeInOutCubic`) — module tab transitions (`AnimatedSwitcher`), skeleton-to-content crossfades.
- `emphasizedDuration`: `500ms` (`Curves.easeOutCubic`) — Kanban stage movement and chart transitions.

---

## 5. Verification Commands

Run the following checks to verify typography and design token compliance:

```sh
# 1. Audit all fontSize values across lib/ (must only return canonical scale values)
grep -rn "fontSize:" lib/ | awk -F'fontSize:' '{print $2}' | tr -d ' ,)' | sort -n | uniq -c

# 2. Format, static analysis, and end-to-end test suite
dart format .
flutter analyze
flutter test
```

