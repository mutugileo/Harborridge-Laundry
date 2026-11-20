# HARBOR RIDGE LAUNDRY — Agent Guide

Single-branch Flutter Web POS & operations portal (`Harbor Ridge Main`, Getathuru Road, opp. NG-CDF Kabete Plaza), backed by Supabase (`cyjigxszbseqbchqfmuf`) and deployed on Vercel (`https://laundry-ridge.vercel.app`).

## Architecture & Module Boundaries
- **State & Architecture**: Riverpod (`flutter_riverpod`) feature-first modules under `lib/features/` + shared primitives in `lib/core/` (`auth`, `errors`, `permissions`, `supabase`, `utilities`, `widgets`).
- **11 Active Modules** (`AdminNavTab` / `AppModuleKey`): `dashboard`, `orders`, `orderStatus`, `dispatch`, `customers`, `services` (POS Intake), `payments`, `inventory`, `staff`, `reports`, `settings`. *(Multi-vendor `vendors` & `settlements` were removed; do not re-add.)*
- **Single Registered Branch**: Always **`Harbor Ridge Main`** — never add dummy branches or branch selector dropdowns.
- **UI Listings**: Paginate all listings at max **6 items per page** via [`AppPaginationBar`](lib/core/widgets/app_pagination_bar.dart).

## Design & Motion Tokens
- **Font**: `Lexend` via `AppTypography` (`10, 11, 12, 13, 14, 16, 18, 22` px).
- **Colors (`context.colors`)**: `harborNavy` (`#152042`), `freshSkyBlue` (`#2DA1E7`), `harborGold` (`#DCA842`), `accentGreen` (`#1E9E6A`), `statusError` (`#DC2626`), `background` (`#EEF3F8`), `surface` (`#F5F8FC`), `cardBackground` (`#FFFFFF`), `borderSubtle` (`#DCE5F0`).
- **Motion (`context.motion`)**: `shortDuration` (`150ms`), `mediumDuration` (`300ms`), `emphasizedDuration` (`500ms`), `InteractivePressScale`, `SharedAxisPageTransition` (`peerFeature`, `verticalSubflow`, `componentSwitch`, `portal`).

## Auth, POS & Exports
- **Auth**: Initial login requires email + password; subsequent unlocks on the same device use a 4-digit PIN. Admin worker provisioning/password resets run server-side in the `staff-admin` Edge Function.
- **POS Validation**: Customer full name (≥2 chars), phone number (≥9 digits), and M-Pesa ref (≥4 chars when `M-Pesa (Paid)`) are strictly required; `OrderAddon` is optional and hidden when empty.
- **Exports & Printing**: Conditional web/stub [`file_saver.dart`](lib/core/utilities/file_saver.dart) (`package:web`) + [`DocumentTemplates`](lib/core/utilities/document_templates.dart) (embeds inline SVG Harbor Ridge logo on A4 invoices and 80mm thermal receipts).

## Supabase Backend & RLS
- All writes to orders/items/payments go through `SECURITY DEFINER` RPCs (`create_order`, `record_order_payment`, `replace_order_items`) with `client_ref` idempotency.
- RLS (`rls_enabled = true`) scopes `SELECT`/`UPDATE`/`DELETE` to `{authenticated}` + `staff_can(...)` / `created_by = auth.uid()` / `is_admin()`.

## Verification Commands
```sh
export PATH="$PATH:/opt/homebrew/bin"
dart format .
flutter analyze
flutter test
flutter build web --release
```
