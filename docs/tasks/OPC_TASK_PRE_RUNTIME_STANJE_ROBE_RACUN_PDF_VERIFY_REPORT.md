# OPC Task Report — Pre-Runtime STANJE ROBE And RAČUN PDF Verification

## Identity

- Required base: `6a7f7c52bffacf0e6097034df32ac5a778a9fe6c`
- Branch: `task/OPC-PRE-RUNTIME-STANJE-ROBE-RACUN-PDF-VERIFY`

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- audit / documentation with focused characterization test

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no behavior change; both use shared Dart policy/settings/document code

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- verification only; no correction was source-required

Required gate before implementation:
- entitlement/access, product terminology, platform parity

Manifest read: YES

## Source learning and diagnosis before correction

### STANJE ROBE

Package levels and module availability are defined in `lib/core/entitlements/opc_entitlement_policy.dart`. `OpcPackageLevel.potpun` makes `OpcModule.stanjeRobe` available; SREDNJI can also receive it through the explicit add-on. Availability does not activate tracking.

The independent active-use value is `AppPodesavanja.stanjeRobeOperativnoOmoguceno` in `lib/core/database/tables/app_podesavanja_table.dart`, with database default `false`. `lib/core/database/database.dart` seeds it as false and schema/open guards add a missing value as off. `PodesavanjaRepository` reads/writes that value. `StanjeRobeOperationalAvailability` first checks entitlement, then returns `disabled` or `active` from the persisted toggle. `PodesavanjaScreen` exposes `STANJE ROBE aktivno` to ADMINISTRATOR and supports both enable and disable; SAVETNIK cannot control it. Shared Dart paths apply to Windows and Android.

Existing `test/stanje_robe_operational_toggle_test.dart` proves default disabled, enable, disable, non-licensed status, preserved data, and initialization without activation. `test/package_downgrade_migration_test.dart` proves migrations/open repair default off and POTPUN availability.

Finding: STANJE ROBE is available in POTPUN, disabled by default, and remains the user's administrative choice. Availability and active use are separate. No source correction was needed and no stock behavior was changed.

### RAČUN PDF export

The standard PREDMET document action types and visibility rules are in `lib/core/entitlements/opc_entitlement_policy.dart`. `OpcDocumentAction.racunPdf` is visible under the same always-available `OpcModule.operationalDocuments` gate as the other standard PDF document actions. `lib/features/predmeti/presentation/predmet_screen.dart` includes `RAČUN PDF` in the DOKUMENTI action list and routes it to `izvoziRacunPdf`. The dedicated template/export implementation is `lib/features/predmeti/pdf/racun_pdf_export.dart`.

Required status: `RAČUN IS PART OF STANDARD PDF EXPORT`.

Source evidence is conclusive. RAČUN is not separately optional, manual-add-on gated, or excluded. No owner decision is required for this verification and no PDF export behavior, layout, content, or action set was changed. A focused policy test now protects the existing RAČUN visibility rule.

## Changes

- No production source change was required for STANJE ROBE.
- No production source/PDF change was made for RAČUN.
- Added a focused existing-policy assertion in `test/package_downgrade_migration_test.dart`.
- Added `OPC-PSEUDO-036`, `OPC-PSEUDO-037`, index entries 034/035, safe-upgrade cross-reference, and this report.

## Business meaning, risk, and safe boundary

POTPUN provides access to inventory tracking without forcing operational effects. RAČUN is known before runtime as an expected standard document. Blind changes could either force stock tracking, remove POTPUN capability, or mutate the expected PDF set. The safe boundary is source verification, documentation, and a visibility characterization test only.

PREDMET identity/lifecycle, package POTPUN semantics, stock calculations/data/movements, PDF output/set, JSON, IRiU/manual amount, date, reminder, GDPR, statistics, and catalog behavior were not changed. STANJE ROBE was not removed from POTPUN and user choice remains preserved.

## Validation

- Focused STANJE ROBE/package/RAČUN policy tests: PASS (`+30`).
- Recent IRiU amount/date/reminder/statistics/catalog regressions: PASS (`+20`).
- Full `flutter test`: PASS (`+106`).
- `flutter analyze`: PASS WITH PRE-EXISTING ANALYZE INFO. The only item is the inherited `unnecessary_import` informational finding for `dart:typed_data` at `iriu_row_tile.dart:2`; this task did not modify that source file. No new warning/error was introduced.
- `git diff --check`: PASS.
- Manifest gate: PASS.

Runtime/build: NOT REQUESTED / NOT PRODUCED

No unresolved placeholders.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

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

PASS / NOT PASS: PASS WITH PRE-EXISTING ANALYZE INFO.
