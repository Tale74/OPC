# OPC KATALOG — FIKSNA cena, CRNINA KATALOŠKA, IRiU IZNOS

## Scope and baseline

Implemented on `task/OPC-KATALOG-FIKSNA-CENA-CRNINA-IRiU-IZNOS`, branched from the confirmed SCENARIO baseline `ba9a38631cac81e1d13dba90f5d7f91353ca1c15`.

SCENARIO definitions, keys and golden fixtures were not changed.

## Source-learning findings

- `KATALOSKA` price already lives on `KatalogArtikli.cena`; the existing article editor, Serbian number parser and RSD formatter are reused.
- `FIKSNA` had no physical price field. A category-level `IriuKatalogConfig.cena` was therefore added; no parallel article/photo model was introduced.
- Existing IRiU rows stored `kom` and `iznos`, but not the applied unit price. `Iriu.cena` now stores the applied price snapshot so later KATALOG edits do not rewrite historical PREDMET rows.
- A new row with a price uses `IZNOS = parsed KOM × CENA`. Quantity changes recompute only while the amount still equals the previous automatic result; a manually edited amount remains untouched.
- Completed/anonymized status enablement was not broadened. Existing editable/open-row behavior remains the authority for manual amount override.
- Backup JSON already serializes Drift data classes, so the new price snapshot fields round-trip through the existing contract without a format fork.
- Legacy JSON without the new fields is normalized to `cena = 0.0` before the existing Drift compatibility import.

## Implementation

- Database schema version `26 → 27`; additive `cena REAL NOT NULL DEFAULT 0` columns on `iriu_katalog_config` and `iriu` with recovery-safe `ensureColumn` handling.
- Canonical `CRNINA` seed is `KATALOSKA`. `repairKnownCatalogIntegrity()` applies the smallest idempotent correction by stable internal identity and does not reseed or replace user data.
- FIKSNA KATALOG dialog now supports localized CENA input/display and deliberately has no photography controls, image area, placeholder or media helper text.
- KATALOSKA article UI and snapshot behavior remain unchanged.
- IRiU picker/repository/row tile share the existing monetary parsing/formatting behavior and preserve manual amount edits.
- Business pseudocode was updated in `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`.

## Evidence

Passing focused tests:

- `test/katalog_fiksna_cena_iriu_iznos_test.dart` — FIKSNA save/reopen, CRNINA idempotence/stable identity, KOM×CENA, KATALOŠKA snapshot and picker boundary.
- `test/scenario_map_1008_golden_consistency_test.dart`.
- `test/scenario_module_repository_test.dart`.
- `test/json_transfer_regression_test.dart`.
- `test/business_policy_iriu_critical_scenarios_test.dart`.
- `flutter analyze --no-pub` — exit 0.

The full migration recovery suite is deliberately slow in this environment. Its isolated first-test case passed, while the complete suite exceeded the extended ten-minute execution window and was stopped as incomplete. No build was run. The known `scenario_default_policy_characterization_test.dart` matrix failures predate this branch's SCENARIO-neutral change and are outside the 1008 golden gate; the dedicated 1008 gate remains PASS.

## Mandatory verdicts

FIKSNA PRICE MODEL — PASS

FIKSNA PRICE UI — PASS

FIKSNA PHOTO/PLACEHOLDER ABSENT — PASS

CRNINA CATALOG TYPE — KATALOŠKA

CRNINA STABLE ID PRESERVED — PASS

CRNINA DUPLICATION — 0

IRiU KOM × CENA AUTO AMOUNT — PASS

IRiU MANUAL AMOUNT OVERRIDE FOR OTVOREN — PASS

IRiU MANUAL OVERRIDE PERSISTENCE — PASS

EXISTING KATALOŠKA PRICE BEHAVIOR — PRESERVED

BACKUP/RESTORE PRICE AND AMOUNT — PASS

SCENARIO 1008 GOLDEN GATE — PASS

11-ITEM OSNOVNI PAKET — PASS

FLUTTER ANALYZE — PASS

TARGETED TESTS — PASS

FULL FLUTTER TEST — INCOMPLETE

BUILD — NOT RUN BY OWNER DECISION

WINDOWS/ANDROID RUNTIME — DEFERRED TO CUMULATIVE BUILD

LOCAL DOCUMENTATION SYNC — NOT DEFINED
