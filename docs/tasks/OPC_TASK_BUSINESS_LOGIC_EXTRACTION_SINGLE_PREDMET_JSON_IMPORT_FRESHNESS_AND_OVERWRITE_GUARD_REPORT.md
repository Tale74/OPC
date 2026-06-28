# OPC TASK BUSINESS LOGIC EXTRACTION - SINGLE-PREDMET JSON IMPORT FRESHNESS AND OVERWRITE GUARD REPORT

Task: OPC BUSINESS LOGIC EXTRACTION - SINGLE-PREDMET JSON IMPORT FRESHNESS AND OVERWRITE GUARD

OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: audit-only / documentation / business logic extraction
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO - source/test read only, no behavior changed
Windows/Android parity affected: NO
Future OPC Web affected: NO
Terminology drift risk: NO
Implementation allowed: NO
Required gate before implementation: data ownership / JSON safety / repository identity / platform parity / source-of-truth

## Baseline

| Field | Value |
| --- | --- |
| Branch | `task/OPC-BUSINESS-LOGIC-SINGLE-PREDMET-JSON-FRESHNESS-AUDIT` |
| Base commit | `d1e5b30b1f84e4daecadec5881ba6b16ac82379f` |
| Verified previous task | `OPC OWNER DECISION PATCH - FIRM-SCOPED BROJPREDMETA AND SINGLE-PREDMET JSON FILENAME SEMANTICS` |
| Final commit | Recorded in final GitHub handoff after commit creation. |

## Scope Confirmation

This was an audit-only/docs-only extraction. Source and tests were read as evidence only. No source code, database/schema, migration, Web runner, backend/API, sync, storage, payment/licensing/entitlement, role, UI, PDF, JSON behavior, filename generation, or test behavior was changed.

## Files Inspected

Public docs:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_EXTRACTION_PREDMET_LIFECYCLE_AND_SAME_PREDMET_CONFLICT_RULES_REPORT.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_PATCH_FIRM_SCOPED_BROJPREDMETA_AND_SINGLE_PREDMET_JSON_FILENAME_SEMANTICS_REPORT.md`

Source/test evidence:

- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/core/format/app_filename_format.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `test/json_transfer_regression_test.dart`

## Files Changed

- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_EXTRACTION_SINGLE_PREDMET_JSON_IMPORT_FRESHNESS_AND_OVERWRITE_GUARD_REPORT.md`

## Single-PREDMET JSON Import Entry Points

| Finding | Classification | Evidence |
| --- | --- | --- |
| UI import entry point for a single PREDMET is `uveziPredmetIzJson`, which calls `uvoziIzFajla` with backup import disabled. | SOURCE-CONFIRMED | `lib/core/utils/json_export_import.dart`. |
| Shared import logic accepts `OPC_PREDMET` and legacy `OPC_BELEZNICA` formats. | SOURCE-CONFIRMED | `uvoziIzFajla`; `PredmetJsonTransferCore` constants. |
| File selection is platform-aware only at file-read boundary: Android prefers disk path, other platforms can use bytes. | SOURCE-CONFIRMED | `_izaberiJsonMapu`, `_ucitajJsonMapuIzRezultata`. |
| Test helper `importPredmetJsonMapForTest` imports or replaces directly and does not exercise the UI conflict dialog. | TEST-CONFIRMED | `test/json_transfer_regression_test.dart` uses the visible-for-testing helper. |

## Current Matching / Conflict Key Findings

| Question | Finding | Classification |
| --- | --- | --- |
| Matching key | Current single-PREDMET import conflict lookup uses trimmed imported `predmet.brojPredmeta` and compares it to local `predmeti.brojPredmeta`. | SOURCE-CONFIRMED |
| Empty key | If imported trimmed `brojPredmeta` is empty, the conflict lookup is skipped and the PREDMET is imported as new. | SOURCE-CONFIRMED |
| Multiple local matches | If more than one local row has the same `brojPredmeta`, import stops because replacement is not safe. | SOURCE-CONFIRMED |
| Filename | Import reads JSON content from the selected file; no evidence was found that filename, `PREZIME_IME`, or `_vN` is used as an identity/conflict key. | SOURCE-CONFIRMED |
| Internal id | Imported `id` is not used as identity for conflict lookup; replacement keeps the local technical id. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Firm identity | No source evidence was found that single-PREDMET import currently scopes conflict lookup by PIB/Maticni broj/firma identity. | NOT IMPLEMENTED |

Important policy boundary: future-safe identity remains `PIB + Maticni broj + brojPredmeta`. The current `brojPredmeta`-only lookup is implementation evidence, not a future identity policy.

## Older/Newer Freshness Guard Findings

| Question | Finding | Classification |
| --- | --- | --- |
| Does current source automatically prevent an older JSON from overwriting newer local PREDMET data? | No automatic older/newer block was found in the inspected source path. A user can choose `Zameni uvoznim` after the conflict dialog. | NOT IMPLEMENTED / SOURCE-CONFIRMED |
| Owner-reported protection | Prior owner decision says OPC currently protects against older JSON overwriting newer local PREDMET. This audit did not find source/test/runtime proof of an automatic guard. | OWNER-REPORTED BEHAVIOR / UNCLEAR / NEEDS OWNER REVIEW |
| Freshness fields | Conflict dialog displays `verzija`, `exportVerzija`, `lastBusinessModifiedByKorisnikId`, `lastBusinessModifiedAt`, `businessScenarioId`, `sourceIdentity`, `datumKreiranja`, and `savetnikId`. | SOURCE-CONFIRMED |
| Comparison logic | No source evidence was found for comparing `exportDatum`, `lastBusinessModifiedAt`, `datumKreiranja`, `verzija`, `exportVerzija`, or filename suffix `_vN` to block replacement. | NOT IMPLEMENTED |
| Test coverage | Existing tests confirm direct replacement behavior and metadata normalization, but no test proves older JSON is blocked when local data is newer. | TEST-CONFIRMED / NOT IMPLEMENTED |

## Fields Used For Freshness / Version Comparison

| Field | Current use | Classification |
| --- | --- | --- |
| `exportDatum` | Written in single-PREDMET export root; decoded as optional metadata by candidate core; no import freshness comparison found. | SOURCE-CONFIRMED / NOT IMPLEMENTED |
| `lastBusinessModifiedAt` | Normalized into imported `predmet` when missing and displayed in conflict dialog; no ordering/date parsing comparison found. | SOURCE-CONFIRMED / NOT IMPLEMENTED |
| `datumKreiranja` | Displayed in conflict dialog; no freshness comparison found. | SOURCE-CONFIRMED / NOT IMPLEMENTED |
| `verzija` | Displayed in conflict dialog; no replacement block based on lower/higher version found. | SOURCE-CONFIRMED / NOT IMPLEMENTED |
| `exportVerzija` | Incremented on export, stored in JSON root/predmet normalization, displayed in conflict dialog; no replacement block based on lower/higher export version found. | SOURCE-CONFIRMED / NOT IMPLEMENTED |
| Filename `_vN` | Used only in export filename semantics; no import-time version semantics found. | SOURCE-CONFIRMED / NOT IMPLEMENTED |

## Missing / Malformed Field Behavior

| Scenario | Finding | Classification |
| --- | --- | --- |
| Missing root `exportVerzija` | Import normalization defaults `exportVerzija` to `0` if root value is absent or not an int and the predmet map lacks it. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Missing business metadata | `businessScenarioId`, `sourceIdentity`, `createdByKorisnikId`, `lastBusinessModifiedByKorisnikId`, and `lastBusinessModifiedAt` get default/null values during import normalization. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Newer unsupported schema | Import blocks JSON whose schema version is newer than supported. This is schema compatibility, not PREDMET freshness comparison. | SOURCE-CONFIRMED |
| Malformed freshness values | No separate malformed freshness comparison behavior was found because no automatic freshness comparator was found. | NOT IMPLEMENTED |

## Same-Age / Older / Newer Import Behavior

| Scenario | Current observed behavior | Classification |
| --- | --- | --- |
| Same `brojPredmeta`, local and imported same age | Conflict dialog offers cancel, keep local, or replace imported; no automatic age result found. | SOURCE-CONFIRMED |
| Imported JSON older than local PREDMET | No automatic block found; if user chooses replace, repository replacement path applies imported state. | NOT IMPLEMENTED / SOURCE-CONFIRMED |
| Imported JSON newer than local PREDMET | No automatic allow rule found; user still chooses in conflict dialog. | SOURCE-CONFIRMED |
| Comparison cannot be made | No comparator was found; missing metadata defaults are applied and user-facing conflict choice remains. | NOT IMPLEMENTED / SOURCE-CONFIRMED |

## Keep / Replace / Cancel Findings

| Flow | Current behavior | Classification |
| --- | --- | --- |
| Cancel | Dialog returns cancel/null and import stops. | SOURCE-CONFIRMED |
| Keep local | Dialog keeps the local PREDMET and import stops. | SOURCE-CONFIRMED |
| Replace imported | Dialog can trigger replacement with imported data; no freshness block was found before `_zameniPredmetUBazi`. | SOURCE-CONFIRMED |
| Create duplicate | If no local `brojPredmeta` match is found, import creates a new local PREDMET. | SOURCE-CONFIRMED |
| Block import | Multiple local matches block replacement; newer unsupported schema blocks import. Older/newer business freshness does not appear to block import. | SOURCE-CONFIRMED / NOT IMPLEMENTED |
| Silent overwrite | No silent overwrite on same `brojPredmeta` was found in the UI path; user must choose replacement. | SOURCE-CONFIRMED |

## Replacement Side-Effect Findings

| Area | Finding | Classification |
| --- | --- | --- |
| Main `predmet` row | Replacement keeps local technical `id` and replaces row data with imported PREDMET data. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| IRIU | Local IRIU rows are deleted and imported IRIU rows are inserted under the local id. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Kontakt lica | Local contacts are deleted and imported contacts are inserted under the local id. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Logs | Local `logIzmena` rows for that PREDMET are deleted during replacement. | SOURCE-CONFIRMED |
| Lifecycle decisions | `iriu_lifecycle_decisions` for that PREDMET are deleted during replacement. | SOURCE-CONFIRMED |
| STANJE ROBE consequences | Replacement calls lifecycle reconciliation before applying imported consequence transfer items. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Created/modified metadata | Imported row metadata is applied as part of the replacement row unless local technical id is explicitly preserved. | SOURCE-CONFIRMED |
| Orphan risk | Known related rows are explicitly cleared/reinserted, but no full foreign-key/cascade audit was performed in this task. | TECHNICAL AUDIT REQUIRED |

## Single-PREDMET JSON Expected Content Findings

| Expected field/block | Finding | Classification |
| --- | --- | --- |
| `format` | Current format is `OPC_PREDMET`; legacy `OPC_BELEZNICA` is also accepted. | SOURCE-CONFIRMED |
| `schemaVersion` | Root schema version is checked against supported maximum. | SOURCE-CONFIRMED |
| `entityType` | Export writes `PREDMET`; candidate core defaults to `PREDMET` if absent. | SOURCE-CONFIRMED |
| `documentSourceIdentity` | Export writes `PREDMET`; candidate core defaults to `PREDMET` if absent. | SOURCE-CONFIRMED |
| `exportDatum` | Export writes an ISO timestamp; no freshness comparison found. | SOURCE-CONFIRMED |
| `sourceExpectations` | Export writes expectations including `jsonTransfer.identity: single-PREDMET` and included blocks. | SOURCE-CONFIRMED |
| `predmet` | Required object for import; `predmet.brojPredmeta` is the current conflict key after trim. | SOURCE-CONFIRMED |
| `iriu` | Optional/empty list accepted and imported when present. | SOURCE-CONFIRMED |
| `kontaktLica` | Optional/empty list accepted and imported when present. | SOURCE-CONFIRMED |
| Firm identity metadata | No proof found that single-PREDMET JSON currently contains enough firm identity metadata to independently enforce `PIB + Maticni broj + brojPredmeta`. | TECHNICAL AUDIT REQUIRED |

TECHNICAL AUDIT FINDING: single-PREDMET JSON import currently cannot independently prove firm identity from the file itself unless future design adds firm identity to the file or uses target database identity as scope.

## Filename Role Findings

| Area | Finding | Classification |
| --- | --- | --- |
| Export filename | Export uses filename-format helpers for human-readable file naming. | SOURCE-CONFIRMED |
| Import identity | Import uses decoded JSON content and current conflict lookup; no filename identity use found. | SOURCE-CONFIRMED |
| `PREZIME_IME` | No evidence found that person name from filename is used as conflict key. | SOURCE-CONFIRMED |
| `_vN` suffix | No evidence found that filename version suffix is parsed for import freshness. | NOT IMPLEMENTED |
| Policy | Filename remains UX only and must not become canonical system identity. | OWNER CLARIFICATION / DOCUMENTED POLICY |

## Windows / Android Parity Findings

| Area | Finding | Classification |
| --- | --- | --- |
| Shared logic | JSON parser, conflict decision path, repository replacement, and test helper are shared Dart logic. | SOURCE-CONFIRMED |
| Platform-specific file read | Android uses disk path preference; non-Android can read bytes from picker result. | SOURCE-CONFIRMED |
| Conflict dialog layout | Dialog adjusts narrow Android layout but exposes the same cancel/keep/replace choices. | SOURCE-CONFIRMED |
| Runtime parity | No Windows or Android runtime smoke was run in this docs-only task. | RUNTIME NOT CONFIRMED / FACT CHECK REQUIRED |

## Future OPC Web / Sync / Import Preservation Notes

Future design must preserve these boundaries:

- `PREDMET` remains master business truth.
- Conflict identity must be firm-scoped: `PIB + Maticni broj + brojPredmeta`.
- No global `brojPredmeta` conflict assumption.
- Filename and `PREZIME_IME` stay user-facing UX only.
- No filename-based identity or `_vN`-based import authority without a separate design.
- No silent overwrite of newer local business truth.
- Local database ownership remains user/firma-owned.
- Keep/replace/cancel behavior or an owner-approved equivalent must remain explicit.
- Replacement side effects for related PREDMET data must be deliberately preserved or redesigned with tests.

## Open Questions With Statuses

| Question | Status | Notes |
| --- | --- | --- |
| Should automatic older/newer protection be implemented as a hard block, warning, or owner override? | OWNER DECISION REQUIRED | Current source shows user choice, not automatic block. |
| Which field is authoritative for freshness: `lastBusinessModifiedAt`, `verzija`, `exportVerzija`, `exportDatum`, or a new monotonic field? | OWNER DECISION REQUIRED / TECHNICAL AUDIT REQUIRED | No current comparator found. |
| How should missing or malformed freshness metadata behave? | OWNER DECISION REQUIRED | Current normalization defaults missing metadata but does not compare freshness. |
| Should single-PREDMET JSON include firma identity metadata? | OWNER DECISION REQUIRED / TECHNICAL AUDIT REQUIRED | Required if file itself must prove firm identity. |
| Should runtime Windows/Android import dialog be smoke-tested? | FACT CHECK REQUIRED | Source is shared, runtime not run here. |

## Stop-List Confirmation

No implementation was performed. The following remain blocked until separate explicit tasks and gates: freshness guard implementation, JSON schema changes, filename generation changes, firm identity guard implementation, source cleanup, database constraints/migrations, Web runner, backend/API, sync, storage adapter, payment/licensing/entitlement, role implementation, UI/PDF changes, and package restructuring.

## Validation Results

| Check | Result |
| --- | --- |
| Docs-only diff | PASS - changed files are under `docs/` only. |
| Manifest gate | PASS - `python scripts\validate_opc_manifest_gate.py --base d1e5b30b1f84e4daecadec5881ba6b16ac82379f`. |
| Source code untouched | PASS - source/tests were read only; no `lib/`, `test/`, platform, database, migration, Web runner, backend/API, sync, storage, payment/licensing/entitlement, role, UI, PDF, JSON behavior, or filename-generation files changed. |
| Flutter analyze/test/build | Not run; docs-only audit. |

## Final Status

PASS WITH OWNER REVIEW QUEUE

OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES
Core purpose preserved: YES
PREDMET meaning preserved: YES
Database ownership preserved: YES
Windows/Android parity preserved: YES
Existing JSON transfer preserved: YES
Terminology preserved: YES
Future Web Pristup not blocked: YES
Source changes within scope: YES - documentation only
PASS / NOT PASS: PASS WITH OWNER REVIEW QUEUE
