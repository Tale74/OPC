# OPC TASK OWNER DECISION - VERSION CONFLICT POLICY AND PREDMET CHANGE-LOG REQUIREMENT REPORT

Task: OPC OWNER DECISION - VERSION CONFLICT POLICY AND PREDMET CHANGE LOG REQUIREMENT
Branch: task/OPC-OWNER-DECISION-VERSION-CONFLICT-POLICY-CHANGELOG
Base commit: 3fecc8d9f3cc4d79c2780c097ea98a73cd6ffe0e
Report status: PASS - OWNER DECISION RECORDED / IMPLEMENTATION REQUIRED

## OPC MANIFEST CHECK — TASK START

Manifest read: YES
Manifest path: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
Workflow arc read: YES
Workflow path: `docs/GIT_WORKFLOW_ARC.md`
Task template read: YES
Template path: `docs/templates/OPC_TASK_TEMPLATE.md`

This task is documentation-only. It records owner decisions for PREDMET version conflict policy and the missing PREDMET version/change-log overview requirement. It does not implement runtime behavior.

## Baseline

The task starts from commit `3fecc8d9f3cc4d79c2780c097ea98a73cd6ffe0e`, after the prior owner-decision report for PREDMET version semantics.

Existing baseline before this task:

- `verzija` is a PREDMET business-version signal.
- `exportDatum` is export metadata, not business freshness authority.
- Same-`brojPredmeta` import keep / replace / cancel is intentional business behavior.
- Firm-scoped identity remains separate from versioning.
- Filename `_vN` is not authoritative PREDMET `verzija`.

## Scope

In scope:

- record the owner-approved version conflict policy matrix;
- record missing/malformed version handling policy;
- record that a future PREDMET version/change-log overview is required;
- record `Pregled i potvrda` as the intended location for that overview;
- update public docs, rule inventory, extraction queue, stop-list, and current state.

Out of scope:

- source code changes;
- database/schema changes;
- JSON schema changes;
- import behavior changes;
- filename-generation changes;
- UI/PDF behavior changes;
- change-log model or behavior implementation;
- tests or runtime behavior changes;
- Web runner, backend, API, sync, storage, payment, licensing, entitlement, role, or package restructuring work.

## Files Inspected

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`

## Files Changed

- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_CONFLICT_POLICY_AND_PREDMET_CHANGE_LOG_REQUIREMENT_REPORT.md`

## Owner Decisions Recorded

1. `verzija` remains PREDMET business-version signal only.
2. `verzija` is not export timestamp, filename identity, firm identity, global identity, or replacement for explicit user/business choice.
3. `exportDatum` is not freshness authority.
4. Keep / replace / cancel remains intentional same-PREDMET import behavior.
5. Higher, lower, same, missing, and malformed `verzija` states may warn/classify, but must not silently overwrite local data.
6. Missing or malformed version data must be visible as unknown/invalid, not silently converted into newer/correct state.
7. A future PREDMET version/change-log overview is required.
8. The intended future location for that overview is `Pregled i potvrda` inside PREDMET.

## Version Conflict Policy Matrix

| Case | Required future policy |
| --- | --- |
| Imported `verzija` higher than local | Show both versions, warn imported version is higher, preserve keep / replace / cancel, no silent overwrite, no automatic replacement. |
| Imported `verzija` lower than local | Show both versions, warn imported version is lower, preserve keep / replace / cancel unless later owner decision creates a hard block, no silent overwrite. |
| Imported `verzija` same as local | Show equal-version state, preserve keep / replace / cancel, do not use `exportDatum`; secondary metadata may be displayed only as metadata. |
| Imported `verzija` missing | Classify as unknown, warn, preserve keep / replace / cancel unless later owner decision creates a hard block, do not silently treat as newer, do not use `exportDatum`. |
| Imported `verzija` malformed | Classify as invalid/unknown, warn, preserve keep / replace / cancel unless later owner decision creates a hard block, do not treat as newer, do not use `exportDatum`. |
| Local `verzija` missing or malformed | Classify local version as unknown, warn, preserve keep / replace / cancel, do not silently treat imported version as authoritative, do not use `exportDatum`. |

## Missing/Malformed Policy

Missing or malformed `verzija` is an unknown or invalid version state. It is not newer, not safer, not authoritative, and not eligible for `exportDatum` fallback. Future UI must make that state visible and preserve the explicit import decision unless a later owner decision authorizes a hard block.

## `exportDatum` Non-Authority

`exportDatum` may be shown as metadata, but it is not business freshness authority. Exporting an older PREDMET later must not make that PREDMET business-newer.

## Keep / Replace / Cancel

The explicit keep / replace / cancel choice remains owner-approved business behavior. Future warning, comparator, or classification logic must not remove that choice without a later owner decision.

## PREDMET Change-Log Overview Requirement

Owner decision: OPC needs a PREDMET document/versioning overview that can show version history or change-log information relevant to business review and confirmation.

Classification: OWNER DECISION / IMPLEMENTATION REQUIRED / TECHNICAL AUDIT REQUIRED.

This task records the requirement only. It does not add a change-log database model, event log, UI component, JSON field, import behavior, PDF content, or tests.

## Intended Location: `Pregled i potvrda`

Owner decision: the intended future location for the PREDMET version/change-log overview is `Pregled i potvrda` inside PREDMET.

Reason: that screen is where the user reviews and confirms business state. Version/change-log context belongs with business review, not in a technical/debug-only surface.

## Current Implementation State

Current public baseline says `verzija` is displayed/exported/imported and can be shown in conflict context, but current inspected import behavior does not apply an approved version comparator, warning matrix, automatic replacement, or hard block.

No implementation state was changed by this task.

## Technical Audits Still Required

- audit whether current `verzija` increments in all business-relevant changes;
- audit whether current `verzija` survives all import/export/replace flows;
- audit exact business changes that should create a new version;
- audit whether current logs/lifecycle decisions can support a future change-log overview;
- audit whether `Pregled i potvrda` currently has suitable structure for version/change-log display;
- audit Windows/Android parity for future version/change-log UI.

## Stop List Confirmed

Blocked until separate explicit implementation tasks:

- version comparator;
- import warning UI;
- hard-block logic;
- change-log DB/model;
- change-log UI in `Pregled i potvrda`;
- JSON schema changes;
- sync/Web version conflict logic;
- filename-generation changes;
- import behavior changes.

## Validation

Command:

- `python scripts\validate_opc_manifest_gate.py --base 3fecc8d9f3cc4d79c2780c097ea98a73cd6ffe0e`

Result:

- PASS - OPC manifest gate passed for 1 changed task report: `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_CONFLICT_POLICY_AND_PREDMET_CHANGE_LOG_REQUIREMENT_REPORT.md`

## Final Status

PASS - owner decisions recorded; implementation remains blocked pending technical audit and explicit implementation scope.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES
Documentation-only scope preserved: YES
Source code changed: NO
Database/schema changed: NO
JSON behavior changed: NO
Import behavior changed: NO
Filename-generation behavior changed: NO
UI/PDF behavior changed: NO
Change-log behavior implemented: NO
Web/backend/API/sync/storage/payment/licensing/entitlement/role/package restructuring changed: NO
PASS / NOT PASS: PASS
