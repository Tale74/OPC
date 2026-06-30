# OPC Task Report — PREDMET Lifecycle Identity Version Change-Log Characterization

OPC MANIFEST CHECK — TASK START

Manifest read: YES

Manifest compliance checked: YES

PASS / NOT PASS: PASS

## Task Scope

Branch: `task/OPC-PREDMET-LIFECYCLE-IDENTITY-VERSION-CHARACTERIZATION`

Base commit: `7c24d6399077499f78f963a737cd95560493e49d`

Original characterization commit: `1374d9dbeda761cabf28f277e449980e5dd4b1df`

Report completion correction commit: `05ee8cd4a44ab85e4895edc9d34fb81dfd4114bd`

Report closing commit: the branch-head commit containing this report line records the correction chain and keeps the report self-contained.

Final corrected status: `PASS WITH OWNER REVIEW QUEUE — PUBLIC REPORT COMPLETION CORRECTED`

This was a docs-only characterization task for current PREDMET lifecycle, identity, version, export metadata, same-PREDMET import conflict, change-log visibility, and Web/sync identity risk boundaries.

## Files Created

- `docs/OPC_PREDMET_LIFECYCLE_IDENTITY_VERSION_CHARACTERIZATION.md`
- `docs/OPC_PREDMET_LIFECYCLE_IDENTITY_VERSION_COVERAGE_MATRIX.md`
- `docs/OPC_PREDMET_IDENTITY_VERSION_CHANGELOG_GAP_REGISTER.md`
- `docs/OPC_PREDMET_WEB_SYNC_IDENTITY_RISK_REGISTER.md`
- `docs/tasks/OPC_TASK_PREDMET_LIFECYCLE_IDENTITY_VERSION_CHANGELOG_CHARACTERIZATION_REPORT.md`

## Files Updated

- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`

## Source Evidence Reviewed

- `lib/core/database/tables/predmeti_table.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `test/json_transfer_regression_test.dart`

## Current Behavior Characterized

- PREDMET table stores local technical `id`, `brojPredmeta`, `status`, business `verzija`, `businessScenarioId`, `sourceIdentity`, modifier metadata, and `exportVerzija`.
- Create inserts a generated `brojPredmeta`, default business scenario, local source identity, creator metadata, and relies on table defaults for initial status/version/export version.
- Save records `__save_commit_snapshot__` after business snapshot comparison and normalizes missing business scenario/source identity metadata.
- Close sets `ZATVOREN`, logs snapshots/cycle, and conditionally increments business `verzija` based on confirmed-close snapshot comparison.
- Reopen sets `OTVOREN` and logs lifecycle cycle.
- Automatic finish can set `ZAVRŠEN` when the ceremony date is before the current date.
- Anonymization redacts selected protected fields and sets `ANONIMIZOVAN`, while names remain visible in OPC v1.
- Delete removes related stock lifecycle effects, logs, contacts, IRiU rows, IRiU lifecycle decisions, and the PREDMET row.
- Single-PREDMET JSON export increments `exportVerzija`, emits `exportDatum`, serializes PREDMET/related data, and generates a human-readable filename.
- Current same-PREDMET import conflict detection uses non-empty `brojPredmeta`; one match offers keep/replace/cancel; multiple matches stop replacement as unsafe.
- Replacement import preserves the local technical PREDMET `id`, replaces imported business state into that id, and rebuilds related imported rows under the local id.
- `Pregled i potvrda` currently shows status, business version, saved/unsaved state, and lifecycle actions, but not a full change-log overview.

## Evidence Classifications

- Lifecycle create/save/close/reopen/finish/anonymize/delete: `SOURCE-CONFIRMED / TEST GAP`.
- Single-PREDMET JSON replacement/local-id behavior: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL`.
- Business `verzija` and export metadata boundary: `SOURCE-CONFIRMED / OWNER DECISION / TEST GAP`.
- `brojPredmeta` identity boundary: `SOURCE-CONFIRMED CURRENT LOCAL BEHAVIOR / OWNER DECISION FOR FIRM-SCOPED FUTURE IDENTITY`.
- Change-log review visibility: `SOURCE-CONFIRMED / IMPLEMENTATION GAP / OWNER REVIEW QUEUE`.
- Web/sync identity readiness: `DOCUMENTED POLICY / TECHNICAL AUDIT REQUIRED / IMPLEMENTATION BLOCKED`.

## Pseudocode Updates

Added PREDMET lifecycle/identity/version characterization pseudocode to:

- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`

Indexed the new pseudocode section in:

- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`

Added safe-upgrade cross-reference in:

- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`

## Manifest And Guardrail Compliance

No implementation/content behavior changes were made. No source code, tests, database/schema, UI, PDF, JSON runtime behavior, filename-generation behavior, import/export behavior, backup/restore behavior, evaluator behavior, IRiU behavior, STANJE ROBE behavior, finance behavior, Web/backend/API/sync/storage/payment/licensing/entitlement/role behavior, or test behavior was changed.

No next task, next step, roadmap, priority order, or implementation sequence was recommended.

## Report Completion Correction

This correction was needed because the previous external handoff contained final public values, but this repository report still contained post-commit placeholders for the final commit and manifest validation result.

This correction makes the repository report self-contained by recording the original characterization commit, the report-completion correction chain, the validation command and PASS result, the manifest gate result, and the final corrected status.

This correction only completes the report metadata/status. It does not re-characterize PREDMET behavior and does not alter characterization content.

No behavior, source, test, database/schema, UI, PDF, JSON, import/export, backup/restore, evaluator, IRiU, STANJE ROBE, finance, Web/backend/API/sync/storage/payment/licensing/entitlement/role, runtime, or test behavior was changed.

No next task, roadmap, priority order, or implementation sequence was recommended.

Pseudocode docs unchanged; previous pseudocode updates remain intact.

Final branch status: same task branch, public report completion corrected.

Unresolved post-commit placeholders: NONE

## Validation

Validation command:

`python scripts\validate_opc_manifest_gate.py --base 7c24d6399077499f78f963a737cd95560493e49d`

Result: PASS - `OPC manifest gate passed for 1 changed task report(s).`

Manifest gate result: PASS for `docs\tasks\OPC_TASK_PREDMET_LIFECYCLE_IDENTITY_VERSION_CHANGELOG_CHARACTERIZATION_REPORT.md`.

OPC MANIFEST COMPLIANCE — TASK END

Manifest read: YES

Manifest compliance checked: YES

PASS / NOT PASS: PASS
