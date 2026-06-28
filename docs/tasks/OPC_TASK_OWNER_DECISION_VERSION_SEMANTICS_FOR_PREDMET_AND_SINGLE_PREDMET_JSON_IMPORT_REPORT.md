# OPC TASK OWNER DECISION - VERSION SEMANTICS FOR PREDMET AND SINGLE-PREDMET JSON IMPORT REPORT

Task: OPC OWNER DECISION - VERSION SEMANTICS FOR PREDMET AND SINGLE-PREDMET JSON IMPORT

OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: owner-decision / documentation
Core purpose preserved: YES
PREDMET meaning affected: NO - PREDMET version semantics documented only
Database ownership affected: NO
JSON transfer affected: NO - no JSON behavior changed
Windows/Android parity affected: NO
Future OPC Web affected: NO - risks documented only
Terminology drift risk: NO
Implementation allowed: NO
Required gate before implementation: JSON safety / repository identity / data ownership / platform parity

## Baseline

| Field | Value |
| --- | --- |
| Branch | `task/OPC-OWNER-DECISION-VERSION-SEMANTICS` |
| Base commit | `acbe10ad297092d785b237f85cde97c74ecbe848` |
| Verified previous task | `OPC BUSINESS LOGIC AND RULE CONSISTENCY AUDIT - FULL PRODUCT BASELINE` |
| Final commit | Recorded in final GitHub handoff after commit creation. |

## Scope Confirmation

This task is owner-decision/docs-only. It records version semantics and implementation stop boundaries. It does not change source code, database/schema, migrations, Web runner, backend/API, sync, storage, payment/licensing/entitlement, role behavior, UI, PDF, JSON behavior, filename generation, import/replace behavior, version comparator behavior, automatic overwrite blocking, or tests.

## Files Inspected

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_EXTRACTION_PREDMET_LIFECYCLE_AND_SAME_PREDMET_CONFLICT_RULES_REPORT.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_PATCH_FIRM_SCOPED_BROJPREDMETA_AND_SINGLE_PREDMET_JSON_FILENAME_SEMANTICS_REPORT.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_EXTRACTION_SINGLE_PREDMET_JSON_IMPORT_FRESHNESS_AND_OVERWRITE_GUARD_REPORT.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_AND_RULE_CONSISTENCY_AUDIT_FULL_PRODUCT_BASELINE_REPORT.md`
- Source evidence read-only: `lib/core/database/tables/predmeti_table.dart`, `lib/features/predmeti/data/predmeti_repository.dart`, `lib/core/utils/json_export_import.dart`, `lib/core/json_transfer/predmet_json_transfer_core.dart`, `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart`, `test/json_transfer_regression_test.dart`

## Files Changed

- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_SEMANTICS_FOR_PREDMET_AND_SINGLE_PREDMET_JSON_IMPORT_REPORT.md`

## Current Verified `verzija` Evidence Recap

| Question | Current verified evidence | Classification |
| --- | --- | --- |
| Where defined | `Predmeti.verzija` integer column. | SOURCE-CONFIRMED |
| Default value | Default is `1`. | SOURCE-CONFIRMED |
| Increment behavior | Repository close flow may increment on confirmed close with business change. | SOURCE-CONFIRMED |
| Exported | PREDMET row is serialized in single-PREDMET JSON; `verzija` is included in row JSON. | SOURCE-CONFIRMED |
| Imported | Imported PREDMET row data includes `verzija` through row deserialization/replacement. | SOURCE-CONFIRMED |
| Displayed | Conflict dialog displays `verzija`; PDF snapshot displays `VERZIJA PREDMETA`. | SOURCE-CONFIRMED |
| Compared | No current import comparator or hard block using `verzija` was found. | NOT IMPLEMENTED |
| Tests | JSON regression tests cover export/import/replacement paths and `exportVerzija`; focused `verzija` conflict comparison tests were not found. | TEST GAP |
| Conflict UI | Local/imported `verzija` is displayed as metadata, but keep / replace / cancel remains user choice. | SOURCE-CONFIRMED |

## Owner Decisions Recorded

| Decision | Classification |
| --- | --- |
| `verzija` is the PREDMET business-version/revision signal for future version reasoning. | OWNER DECISION |
| `exportDatum` is export metadata only and is not business freshness authority. | OWNER DECISION |
| Keep / replace / cancel during same-`brojPredmeta` import must remain explicit user choice unless a later owner decision authorizes a hard block. | OWNER DECISION |
| `verzija` may inform future conflict UI by warning, comparing, highlighting, or classifying records, but must not blindly override user choice. | OWNER DECISION |
| `verzija` is not identity; firm-scoped identity remains `PIB + Matični broj + brojPredmeta`. | OWNER DECISION |
| Filename `_vN` is not authoritative PREDMET `verzija` unless source/test evidence proves mapping and owner approves it. | OWNER DECISION |

## `verzija` Versus `exportDatum`

`exportDatum` means when the JSON file was exported. A newer `exportDatum` can describe a later file export of an older business state, so it must not decide business freshness.

`verzija` means the PREDMET business version/revision state. It is the intended stronger future signal for version reasoning, subject to later implementation design and tests.

Classification: OWNER DECISION / SOURCE-CONFIRMED.

## `verzija` Versus Filename `_vN`

Filename `_vN` is user-facing filename text. It must not be treated as authoritative `predmet.verzija` without source/test proof and later owner approval. Import must reason from JSON content and future approved identity/version rules, not from the filename.

Classification: OWNER DECISION.

## `verzija` Versus Firm-Scoped Identity

`verzija` is not a matching key. Future-safe identity/conflict matching remains:

```text
PIB + Matični broj + brojPredmeta
```

Only after the same firm-scoped PREDMET is identified may `verzija` inform conflict/version reasoning.

Classification: OWNER DECISION.

## Keep / Replace / Cancel Preservation Rule

Same-`brojPredmeta` single-PREDMET JSON import must preserve explicit user control where business truth may depend on human choice. `Platilac` may change their mind, and the app must not silently overwrite local data. Future `verzija` warnings can support the choice, but current owner decision does not authorize removing that choice.

Classification: OWNER DECISION / SOURCE-CONFIRMED.

## Missing / Malformed `verzija` Status

No final owner rule was found for missing or malformed imported `verzija`.

Evaluated options:

- block import;
- allow import with warning;
- treat as unknown version;
- treat as version `1`;
- require explicit user confirmation;
- preserve current behavior until a later implementation task.

Current status: OWNER DECISION REQUIRED.

Recommendation without implementation: treat missing/malformed version as unknown in future design, show warning/metadata to the user, and preserve explicit keep / replace / cancel until owner approves a stricter rule.

## Same-Version Conflict Status

No final owner rule was found for local and imported same-`brojPredmeta` PREDMETs with the same `verzija`.

Required future decision points:

- keep explicit keep / replace / cancel choice;
- show metadata comparison;
- warn that versions are equal;
- use `lastBusinessModifiedAt` only as secondary display metadata;
- never use `exportDatum` as deciding authority.

Current status: OWNER DECISION REQUIRED.

Recommendation without implementation: preserve keep / replace / cancel and show same-version warning/metadata in a later UI design task.

## Higher / Lower Version Conflict Status

No final owner rule was found for higher/lower `verzija` conflict outcomes.

Required future distinctions:

- imported version higher than local;
- imported version lower than local;
- same version;
- missing local version;
- missing imported version;
- malformed version.

Current status: OWNER DECISION REQUIRED.

Recommendation without implementation: higher/lower version should inform warning severity and comparison text, not automatically replace or block, unless a later owner decision authorizes hard-block behavior.

## Future Import UI Notes

Future import UI may display local/imported `verzija`, warn on lower imported version, warn on equal versions, and mark unknown/malformed values. It must keep explicit user choice unless later owner decision changes that rule. Silent overwrite remains forbidden.

No UI was changed in this task.

## Future Web / Sync Risk Notes

Future Web/sync/offline replica work must handle concurrent edits, same firm-scoped PREDMET on multiple devices, user choice versus automatic merge, version comparison versus business truth, and local database ownership. This task does not design a sync algorithm or revision system.

## Owner Decisions Still Required

- Missing or malformed imported `verzija`.
- Missing local `verzija`.
- Same-version conflict behavior.
- Imported `verzija` higher than local.
- Imported `verzija` lower than local.
- Whether any hard block is ever allowed and under what conditions.
- Whether filename `_vN` should ever intentionally mirror business `verzija`.

## Technical Audits Still Required

- Version comparator design and tests.
- Import conflict UI warning design.
- Firm-scoped identity guard design before version comparison.
- JSON compatibility handling for legacy/malformed version fields.
- Windows/Android runtime parity smoke for future import UI changes.
- Future Web/sync conflict-resolution design.

## Implementation Stop-List Confirmation

No implementation was performed. Version comparator implementation, automatic overwrite blocking, import/replace behavior changes, JSON schema/behavior changes, filename generation changes, source changes, database changes, UI/PDF changes, Web/backend/API/sync/storage work, payment/licensing/entitlement work, role implementation, and test behavior changes remain blocked.

## Validation Results

| Check | Result |
| --- | --- |
| Docs-only diff | PASS - changed files are under `docs/` only. |
| Manifest gate | PASS - `python scripts\validate_opc_manifest_gate.py --base acbe10ad297092d785b237f85cde97c74ecbe848`. |
| Source code untouched | PASS - source/tests were read only. |
| Flutter analyze/test/build | Not run; docs-only owner-decision task. |

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
