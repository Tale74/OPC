# OPC Task Report — IRIU Confirmed Business Logic Alignment and Missing Parameters Correction

## 1. Task identity

- Branch: `task/OPC-IRIU-CONFIRMED-BUSINESS-LOGIC-ALIGNMENT`
- Base commit: `c0bac9e67fbe2de499fd4e67243066eed4899a53`
- Task class: source correction / business alignment / documentation / Windows-Android parity
- Release or presentation build: not run and not authorized
- Runtime smoke: not run and not required

## OPC MANIFEST CHECK — TASK START

Manifest read:
- YES

Manifest path:
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Core purpose preserved:
- YES

Product identity preserved:
- YES

PREDMET master truth preserved:
- YES — DOČEK date is stored on PREDMET; IRIU remains derived operational truth

User/firma database ownership preserved:
- YES — only the existing local Drift schema advances from 19 to 20

Local Windows/Android parity preserved:
- YES — identical model, persistence and IRIU truth; responsive layout only

Future Web Pristup constraints respected:
- YES — JSON compatibility and shared source model are preserved

Terminology protected:
- YES — `NALOG ZA OPREMANJE` remains the canonical term

Special gates triggered:
- schema migration, JSON transfer, Windows/Android UI, manifest, UTF-8/BOM

Decision:
- PROCEED WITH CONFIRMED NARROW CORRECTIONS ONLY

## 2. Result by requested category

### Confirmed bugs corrected

- A stored `KOMPLET ZA OPELO` no longer remains operationally or financially active after `OPELO` changes to `NE`.
- The row is suppressed, not deleted. Its visible name, price and any manual edits remain stored and become active again if the source condition returns to `DA`.
- The implementation deliberately does not claim whether a row was generated or manually created because the current schema has no reliable row-origin discriminator.

### Missing business parameter added

- Added first-class PREDMET field `docekDatum` / UI label `DATUM DOČEKA`.
- The complete DOČEK parameter set is now `MESTO DOČEKA`, `DATUM DOČEKA`, `VREME DOČEKA`.
- Drift schema version advanced from 19 to 20 with an additive empty-string column migration.
- Single-PREDMET and full-backup JSON normalization accept older payloads without the field and use an empty value.
- New JSON exports preserve the date value.

### Preserved owner decisions

- `SAHRANA VAN SRBIJE` owns mandatory `MEĐUNARODNI PREVOZ` and `MEĐUNARODNA DOKUMENTACIJA`.
- `BALSAMOVANJE` remains under `SAHRANA VAN SRBIJE`; it is conditional, not mandatory and removable.
- `BALSAMOVANJE` has no DOČEK dependency.
- `DOČEK POSMRTNIH OSTATAKA` owns `CARGO TROŠKOVI`.
- PREDMET remains authoritative; IRIU row presence is not execution, completion or a PODSETNIK item.
- STATUSI/CEREMONIJA completion principles were not changed.

### Future work intentionally excluded

- PODSETNIK implementation or architecture
- new IRIU lifecycle/history/origin model
- accepted/executed/cancelled obligation states
- readiness or automatic completion tracking
- PREDMET workflow redesign
- release/presentation builds and unrelated runtime validation

## 3. Fallback behavior

1. Source condition changes: DOČEK rows and OPELO complete rows stay stored but become suppressed when their condition is false.
2. Required data is missing: `DATUM DOČEKA` remains empty; no current date is invented and this correction adds no save/close/readiness blocker.
3. User changes a value: the existing normalized date and autosave path stores the new value.
4. Generated row was manually changed: the row and edits remain stored; only operational/financial activity is suppressed while `OPELO = NE`.
5. Android narrow content grows: MESTO, DATUM and VREME use the existing vertical narrow-layout pattern inside the existing scrollable form. Windows retains the compact horizontal group.

Turning DOČEK off hides but does not clear its MESTO/DATUM/VREME values. Turning it on restores them. There is no silent data loss.

## 4. Source and continuity paths inspected

- PREDMET Drift table, database migration and generated model
- CEREMONIJA state, autosave, date picker and responsive layout
- IRIU repository, direct generation triggers and core truth rules/service
- business-policy snapshot used by IRIU truth
- JSON export/import normalization and regression suite
- NALOG ZA OPREMANJE/PDF derivative boundaries
- narrow Android layout patterns already present in CEREMONIJA
- owner guide, owner decision index and STATUSI/CEREMONIJA pseudocode
- prior IRIU audit, IRIU pseudocode, Logos index and manifest

## 5. Changed artifacts

Source/model:
- `lib/core/database/tables/predmeti_table.dart`
- `lib/core/database/database.dart`
- `lib/core/database/database.g.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`

Tests:
- `test/json_transfer_regression_test.dart`
- `test/iriu_confirmed_business_alignment_test.dart`
- `test/ceremonija_docek_parameters_layout_test.dart`
- `test/package_downgrade_migration_test.dart`

Documentation:
- `docs/OPC_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md`
- `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`
- `docs/OPC_OWNER_DECISION_GUIDE.md`
- `docs/OPC_OWNER_DECISION_INDEX.md`
- `docs/OPC_OWNER_DECISIONS_STATUSI_CEREMONIJA_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- this report

## 6. Windows and Android parity verification

- Shared data model and truth rules: PASS
- Windows widget verification at 1200 px: PASS — all three DOČEK controls visible and populated
- Narrow Android widget verification at 412 px: PASS — controls visible, vertical and without overflow
- Existing date picker/clear control pattern reused: PASS
- No platform-specific business rule introduced: PASS

## 7. Validation

- Drift generation: PASS
- Focused IRIU truth tests: PASS
- Focused JSON transfer regression suite: PASS
- Windows/narrow Android widget tests: PASS
- `flutter analyze --no-pub`: PASS — no issues found
- full `flutter test --no-pub`: PASS — all 132 tests
- OPC manifest gate: PASS — one changed task report validated against base `c0bac9e67fbe2de499fd4e67243066eed4899a53`
- UTF-8/BOM validation: PASS — 17 changed files are valid UTF-8 without BOM
- `git diff --check`: PASS
- GitHub visibility: PENDING COMMIT/PUSH VERIFICATION

## OPC MANIFEST COMPLIANCE — TASK END

Manifest read at start:
- YES

Manifest path:
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Files changed:
- narrow PREDMET schema/JSON/CEREMONIJA/IRIU truth corrections, focused tests and aligned documentation listed above

Core purpose preserved:
- YES

Product identity preserved:
- YES

PREDMET master truth preserved:
- YES

User/firma database ownership preserved:
- YES

Local Windows/Android parity preserved:
- YES

Future Web Pristup constraints respected:
- YES

Terminology protected:
- YES

Special gates triggered:
- schema, JSON transfer, responsive UI, manifest, UTF-8/BOM

Special gates satisfied:
- YES — source/test/manifest/encoding/UI gates passed

GitHub verification status:
- PENDING COMMIT AND PUSH

Manifest compliance checked:
- YES

PASS allowed:
- YES, subject only to commit/push visibility verification

## PASS / NOT PASS

PASS / NOT PASS:
- PASS

## 8. Final status

`IRIU BUSINESS LOGIC ALIGNMENT PASS — CONFIRMED FINDINGS CORRECTED — WINDOWS AND ANDROID PARITY PRESERVED — PODSETNIK DESIGN REMAINS FUTURE OWNER PASS`
