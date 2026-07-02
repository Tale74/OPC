# OPC Task Report — IRiU Manual Amount Serbian Format

## Identity

- Required base: `a60503e85342d1691775a456c17a63b9e54a51c0`
- Branch: `task/OPC-IRIU-MANUAL-AMOUNT-SERBIAN-FORMAT`

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- yes, safely through the shared Flutter IRiU row widget

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes

Required gate before implementation:
- platform parity

Manifest read: YES

## Source learning and diagnosis before fix

Manual IRiU row controls are in `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`. The row contains editable `nazivPrikaz`, free-text informational `kom`, and one business numeric field, `iznos`. There are no separate manual price, discount, or total controls in this row. `kom` is explicitly free text and excluded from the formula by `lib/core/database/tables/iriu_table.dart`, so it was intentionally not changed.

Catalog selection in the same row receives `KatalogPickerArticleSummary.cena` as a `double`, writes it through `_primeniArtikl`, and renders it with `formatMoneyNumber`. Stored rows initialize the same controller with `formatMoneyNumber`. Catalog cards/detail also use that formatter. Manual text instead passed through `parseMoneyInput` from `lib/core/format/app_money_format.dart`. That parser did not accept ungrouped comma decimals such as `1234,56` or repeated mixed input such as `1.234.56`; existing `onEditingComplete` therefore produced an empty display, and the debounce update could persist `0` for rejected text.

Manual and catalog values share `IriuData.iznos` (`REAL`/Dart `double`) after successful selection or entry. `IriuRepository.azurirajStavku` persists the manual companion value; `azurirajKatalogIzborStavke` persists catalog selection. Downstream truth/finance reads the stored numeric value. The safe correction point was therefore a narrow manual-input parser plus controller normalization on commit/focus loss. Repository, schema, totals, and catalog callback behavior did not need modification.

## Implemented change

- Added `tryParseSerbianManualAmount` and `normalizeSerbianManualAmount` in `lib/core/format/app_money_format.dart` for the scoped IRiU convention.
- Updated manual `iznos` in `iriu_row_tile.dart` to normalize on editing completion and focus loss.
- Preserved the last valid numeric amount while invalid text is visible; invalid input shows `Neispravan iznos`, cancels pending autosave, and is not silently converted to zero.
- Kept empty input mapped to the existing zero/empty behavior.
- Added focused parser/normalization tests in `test/iriu_manual_amount_format_test.dart`.

Changed manual numeric fields: IRiU `iznos` only. Intentionally unchanged: `kom` (free informational text), catalog price, totals, discounts, and all finance-segment fields.

Owner examples are confirmed:

- `1234,56` -> `1.234,56`
- `1234.56` -> `1.234,56`
- `1.234.56` -> `1.234,56`
- `1.234,56` -> `1.234,56`

Catalog-entered formatting remains on the existing `formatMoneyNumber` path. Numeric calculations and IRiU business semantics remain based on the same `double` value. PDF, JSON, export/import, date input, reminders, GDPR, and statistics were not intentionally changed.

## Business meaning, risk, and safe boundary

Manual and catalog commercial amounts now communicate the same Serbian-formatted value. A blind parser change could turn ambiguous or invalid text into a plausible wrong price and affect totals. The safe boundary is manual IRiU `iznos` input/display normalization only; catalog pricing, quantity, calculation meaning, persistence schema, exports, and unrelated modules remain unchanged.

## Logos pseudocode learning layer

Added `OPC-PSEUDO-035 — IRiU manual amount Serbian display normalization`, `OPC-PSEUDO-INDEX-033`, and the corresponding safe-upgrade cross-reference using the required source behavior -> pseudocode -> business meaning -> risk -> safe boundary structure.

## Validation

- Focused amount parser/normalization test: PASS (`+6`).
- Focused catalog/date/reminder/statistics regressions plus amount tests: PASS (`+20`).
- Full `flutter test`: PASS (`+105`).
- `flutter analyze`: PASS WITH PRE-EXISTING ANALYZE INFO. The only item is the inherited `unnecessary_import` informational finding for `dart:typed_data` at `iriu_row_tile.dart:2`; that import line was not introduced or modified by this task. No new warning/error was introduced.
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
