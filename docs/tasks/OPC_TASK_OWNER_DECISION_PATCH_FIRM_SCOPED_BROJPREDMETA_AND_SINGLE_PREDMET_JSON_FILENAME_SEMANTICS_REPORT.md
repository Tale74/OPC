# OPC TASK OWNER DECISION PATCH - FIRM-SCOPED BROJPREDMETA AND SINGLE-PREDMET JSON FILENAME SEMANTICS REPORT

Task: OPC OWNER DECISION PATCH - FIRM-SCOPED BROJPREDMETA AND SINGLE-PREDMET JSON FILENAME SEMANTICS

OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: documentation / owner-decision patch
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO
Windows/Android parity affected: NO
Future OPC Web affected: NO
Terminology drift risk: NO - owner terminology clarified only
Implementation allowed: NO
Required gate before implementation: data ownership / JSON safety / repository identity / source-of-truth

## Baseline

| Field | Value |
| --- | --- |
| Branch | `task/OPC-OWNER-DECISION-FIRM-SCOPED-BROJPREDMETA-FILENAME-SEMANTICS` |
| Base commit | `659ebe6` |
| Verified previous task | `OPC BUSINESS LOGIC EXTRACTION - PREDMET LIFECYCLE AND SAME-PREDMET CONFLICT RULES` |
| Final commit | Recorded in final GitHub handoff after commit creation. |

## Scope Confirmation

This task is docs-only / owner-decision patch only. It records owner clarification and updates public continuity docs. It does not implement identity guards, uniqueness constraints, JSON schema changes, filename generation changes, UI/PDF changes, source changes, tests, migrations, Web, sync, backend/API, storage, payment/licensing/entitlement, role, or package behavior.

## Files Inspected

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

## Files Changed

- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_PATCH_FIRM_SCOPED_BROJPREDMETA_AND_SINGLE_PREDMET_JSON_FILENAME_SEMANTICS_REPORT.md`

## Owner Decisions Recorded

| Decision | Classification | Public effect |
| --- | --- | --- |
| `brojPredmeta` is unique within the same firm only. | OWNER DECISION | Future conflict identity must not treat `brojPredmeta` as globally unique. |
| Two different firms may theoretically have the same `brojPredmeta`. | OWNER DECISION | Firm identity must scope future import/restore/sync/Web conflict logic. |
| Future-safe identity scope is `PIB + Matični broj + brojPredmeta`. | OWNER DECISION | Required future audit/implementation target, not implemented here. |
| Single-PREDMET JSON filename is human-readable and user-facing. | OWNER CLARIFICATION | Filename must not become canonical system identity. |
| Existing older/newer overwrite protection must be preserved and audited separately. | OWNER-REPORTED BEHAVIOR | Added future audit queue item without upgrading proof status. |

## Firm-Scoped `brojPredmeta` Rule

`brojPredmeta` is not globally unique across all OPC users/firms. It is unique only inside the same firm.

Canonical future-safe PREDMET identity/conflict scope:

```text
PIB + Matični broj + brojPredmeta
```

Classification: OWNER DECISION.

Implementation status: NOT IMPLEMENTED in this task.

## Single-PREDMET JSON Filename Semantics

Typical user-facing filename pattern:

```text
PREZIME_IME_brojPredmeta_vN.json
```

Example:

```text
GRBAC_IVAN_250626_1539_v1.json
```

Classification: OWNER CLARIFICATION.

Meaning:

- user first recognizes the file by `PREZIME_IME`;
- user then uses date/time-like `brojPredmeta` and version as differentiators;
- `PREZIME_IME` is not a conflict key;
- filename is not source of truth;
- system identity must not rely on filename alone.

## Filename Versus JSON Content Separation

Required wording recorded:

- `PREZIME_IME_brojPredmeta_vN` is a human-readable filename pattern.
- `brojPredmeta` is the actual case number inside the JSON.
- Safe future identity scope is firm identity plus `brojPredmeta`.

Forbidden wording:

```text
Ime_Prezime_Datum_Vreme is the canonical PREDMET identity.
```

Classification: OWNER CLARIFICATION / DOCUMENTED POLICY.

## Existing Older/Newer JSON Overwrite Protection Classification

Owner clarification says OPC currently checks JSON import conflicts and prevents an older JSON from overwriting a newer local PREDMET.

Classification in this task: OWNER-REPORTED BEHAVIOR.

This task does not mark that behavior as `SOURCE-CONFIRMED`, `TEST-CONFIRMED`, or `RUNTIME-CONFIRMED`. The previous extraction audit confirmed same-`brojPredmeta` conflict flow, but did not prove a freshness/older-newer overwrite guard.

## Required Future Audit Queue Update

Added / recorded future audit:

```text
OPC BUSINESS LOGIC EXTRACTION - SINGLE-PREDMET JSON IMPORT FRESHNESS AND OVERWRITE GUARD
```

Required audit target:

- prove whether freshness comparison exists;
- identify compared fields, for example version/export version/modified timestamps if used;
- verify Windows/Android parity;
- distinguish owner-reported behavior from source/test/runtime evidence;
- preserve firm-scoped identity rule.

## Stop-List Confirmation

No implementation was performed. The following remain blocked: uniqueness constraints, DB migrations, firm identity guard, JSON schema changes, filename generation changes, import/export behavior changes, Web/sync/backend/API/storage work, payment/licensing/entitlement, role implementation, UI/PDF changes, source/test changes, and speculative architecture.

## Validation Results

| Check | Result |
| --- | --- |
| Docs-only diff | PASS - changed files are under `docs/` only. |
| Manifest gate | PASS - `python scripts\validate_opc_manifest_gate.py --base 659ebe60f49868fc2b8c4f0a746987e94fa410a9`. |
| Source code untouched | PASS - no `lib/`, `test/`, platform, database, migration, Web runner, backend/API, sync, storage, payment/licensing/entitlement, role, UI, PDF, JSON behavior, or filename generation files changed. |
| Flutter analyze/test/build | Not run; docs-only owner-decision patch. |

## Final Status

PASS WITH OWNER REVIEW QUEUE

OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES
Core purpose preserved: YES
PREDMET meaning preserved: YES
Database ownership preserved: YES
Windows/Android parity preserved: YES
Existing local JSON transfer preserved: YES
OPC Web not implemented: YES
OPC Web not described as SaaS: YES
No source implementation: YES
Changed files within scope: YES - documentation only
PASS / NOT PASS: PASS WITH OWNER REVIEW QUEUE
