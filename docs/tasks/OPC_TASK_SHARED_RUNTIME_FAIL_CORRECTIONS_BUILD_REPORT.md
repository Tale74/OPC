# OPC Task Report — Shared Runtime FAIL Corrections And Build

## Identity

- Required base: `a3b6b0df427a6ef2e1ca4673fb4325203fc79664`
- Branch: `task/OPC-SHARED-RUNTIME-FAIL-CORRECTIONS-BUILD`

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation / release preparation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- yes, safely through shared Flutter behavior and platform-specific notification/build gateways only

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes

Required gate before implementation:
- platform parity, reminder persistence migration, entitlement/access visibility, product terminology

Manifest read: YES

## Diagnosis before implementation

1. Catalog detail image: `lib/features/predmeti/presentation/segments/iriu_row_tile.dart` uses `BoxFit.contain`, but passes the same square target as both `cacheWidth` and `cacheHeight` through `KatalogPhotoPolicy.memoryImage`. The decoder can produce a square raster before contain-fit, deforming non-square products; the square-like CVEĆE example masks this. Safe fix: constrain only the long decode edge and retain contain-fit/layout/navigation.
2. Ceremony reminders: `ceremony_reminder_model.dart`, `ceremony_reminder_repository.dart`, `ceremony_reminder_coordinator.dart`, custom DB table creation, and `ceremonija_segment.dart` all implement `frequency_hours`. The UI card adds a long subtitle/helper and interval dropdown. Owner intent is selected clock times on fixed 2/1/0 days. A new JSON clock-times column with a safe default/migration can preserve local settings-table ownership while legacy interval remains compatibility-only.
3. Date final dot: `preminulo_lice_segment.dart` calls `formatCalendarPickerSelection` without `trailingDot`, then `parseDateInput`/`normalizeDateInput` strips a dot again during save. Ceremony already requests a trailing dot. Birth/death selection and persistence therefore lose the OPC format.
4. Historical birth-year UX: the shared `_pickDate` starts in calendar mode at today/parsed date for both birth and death. Birth can safely use `DatePickerMode.year`, historical bounds, and today as the upper bound; death/ceremony keep their current calendar behavior.
5. FINANSIJE: `finansije_segment.dart` formats AVANS/TROŠKOVI JKP/POPUST only on `onEditingComplete` using the older `parseMoneyInput`; it does not normalize ordinary focus loss and invalid input can parse as zero. The existing IRiU manual amount parser/formatter is the narrow reusable convention.
6. STANJE ROBE: the toggle already exists in `_ModuliTab`, defaults off, and is role/package gated. However the main runtime constructs `OpcEntitlementPolicy.current()`, whose local-license source is a static OSNOVNI fallback; installed-license evaluation is only diagnostic in O APLIKACIJI. Thus a real POTPUN license does not reach settings visibility. Safe correction is to bootstrap the installed local entitlement once and pass its evaluated policy through the app/list/settings route without changing package rules or stock logic.
7. Slow exit: `lib/app.dart` confirms root close, then calls `windowManager.destroy`. Inspected source has no synchronous PREDMET save, notification reschedule, export, cache cleanup, or explicit database-close sequence in this handler. Runtime supplied no timing trace and source alone does not prove the delay location. Status before implementation: `NOT CHANGED / TECHNICAL AUDIT REQUIRED`; no speculative shutdown refactor is authorized.
8. POL/BRAČNO STANJE: `preminulo_lice_segment.dart` defines one combined `_bracnaStanjaOpcije` list and renders it for both sexes. `_polSelector` changes sex without clearing a now-invalid marital status. Safe fix is exact owner lists plus explicit clear on invalid sex transition.

## Implementation and per-finding status

1. `FIXED` — catalog detail decoding now constrains one edge and preserves non-square photo proportions; navigation and selection are unchanged.
2. `FIXED` — reminder frequency is replaced by normalized, selectable clock times on fixed 2/1/0-day windows; schema 19 adds local JSON `delivery_times`, defaulting safely to `09:00`.
3. `FIXED` — birth/death picker and save normalization retain the final dot in `DD.MM.YYYY.`.
4. `FIXED` — birth date opens in year-selection mode with historical bounds and no future date.
5. `FIXED` — AVANS, TROSKOVI JKP, and POPUST share Serbian manual-amount parsing/formatting, normalize on commit/focus loss, and reject invalid text without replacing the last valid value with zero.
6. `FIXED` — installed local entitlement is evaluated once and propagated through the active routes; licensed STANJE ROBE visibility now uses the real policy while its independent operational toggle remains default-off.
7. `NOT CHANGED / TECHNICAL AUDIT REQUIRED` — no source-confirmed blocking shutdown stage was found; no speculative exit refactor was made. Renewed Windows runtime timing must identify dialog, destroy, database, plugin, or OS stage before changing behavior.
8. `FIXED` — exact M/Z marital-status lists are used and a now-invalid value is cleared when POL changes.

## Learning layer and tests

- Added `OPC-PSEUDO-038` through `OPC-PSEUDO-043`, index entry 036, and the matching safe-upgrade cross-reference.
- Added focused FINANSIJE and POL/status tests; updated reminder, date, and catalog tests.
- Focused run: `54/54` passed.
- Full run: `110/110` passed.

## Clean validation and release builds

- `flutter analyze`: PASS, `No issues found`.
- `flutter test`: PASS, `110` tests.
- `flutter build windows --release`: PASS; `build/windows/x64/runner/Release/OPC.exe`, 89,088 bytes.
- `flutter build apk --release`: PASS; `build/app/outputs/flutter-apk/app-release.apk`, 72,963,856 bytes (Flutter display: 69.6 MB).
- `git diff --check`: PASS; line-ending conversion notices are repository/Windows warnings, not whitespace errors.

## Renewed runtime checklist

- Windows: verify non-square catalog photos, reminder time controls/dialog delivery, historical year-first date selection/final dot, all three FINANSIJE fields, real POTPUN STANJE ROBE visibility/default-off choice, exact marital lists/transitions, and measure exit stages separately.
- Android remains blocked from renewed runtime acceptance until the shared findings above are rechecked on Windows. After that gate, verify the same shared behaviors plus local notification delivery at each selected time.
- Logos must review the updated pseudocode/docs learning layer and this build report before instructing Tale on renewed Windows runtime testing.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes; reminder delivery times remain local operational configuration

Windows/Android parity preserved:
- yes; shared behavior is common and notification delivery remains platform-gated

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes

If not compliant, classify:
- not applicable

Manifest compliance checked: YES

PASS / NOT PASS: PASS.
