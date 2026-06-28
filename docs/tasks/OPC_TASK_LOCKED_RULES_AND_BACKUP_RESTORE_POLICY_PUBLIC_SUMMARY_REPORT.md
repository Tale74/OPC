# OPC TASK LOCKED RULES AND BACKUP/RESTORE POLICY PUBLIC SUMMARY REPORT

Task: OPC LOCKED RULES AND BACKUP/RESTORE POLICY PUBLIC SUMMARY

OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: documentation / public-safe summary
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO
Windows/Android parity affected: NO
Future OPC Web affected: NO
Terminology drift risk: YES - old local SaaS/narucilac wording summarized as superseded or owner-review
Implementation allowed: NO
Required gate before implementation: data ownership / JSON safety / product terminology / source-of-truth

## Executive Conclusion

PASS WITH OWNER REVIEW QUEUE.

This task created public-safe summaries for locked rules and backup/restore policy without raw-copying local `PROJECT_DOCS`. It also created a business logic extraction queue for future identity, Web, sync, import/export, and restore work.

No source code, database schema, UI label, PDF label, JSON key, Web runner, backend/API, sync, storage adapter, migration, role, payment/licensing/entitlement implementation, package restructuring, private data, customer data, export data, runtime data, or raw local backup material was changed or added.

## Branch And Commit

| Field | Value |
| --- | --- |
| Branch | `task/OPC-LOCKED-RULES-BACKUP-RESTORE-PUBLIC-SUMMARY` |
| Base commit | `6557346` |
| Final commit | Recorded in final GitHub handoff after commit creation. |

## Documents Inspected

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/tasks/OPC_TASK_PROJECT_DOCS_PROMOTION_AND_TERMINOLOGY_LINEAGE_FACT_CHECK_REPORT.md`
- `SOURCE/PROJECT_DOCS`
- `../PROJECT_DOCS`
- read-only source evidence for JSON format names and identity evidence where needed

## Local Docs Summarized

| Local document | Folder source | Classification | Public summary target | Raw copied? | Private data excluded? | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `OPC_v1_ZAKLJUCANA_PRAVILA.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | MASTER / CURRENT MIXED WITH HISTORY | `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`, `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md` | NO | YES | Summarized locked rules only; stale/task-specific/licensing details not copied. |
| `OPC_v1_BACKUP_AND_RESTORE_POLICY.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | SUPPORTING | `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md` | NO | YES | Summarized process and exclusions; local paths/commands not promoted. |
| `OPC_v1_ARCHITECTURE_DECISIONS.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | SUPPORTING | locked rules summary | NO | YES | Used for PREDMET truth, platform parity, JSON, and module boundaries. |
| `OPC_v1_PROJECT_SOUL.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | MASTER / CURRENT, PARTLY SUPERSEDED | locked rules summary | NO | YES | Core identity retained; SaaS wording superseded. |
| `OPC_v1_PROJECT_FLOW_AND_DELTA.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | HISTORICAL / SUPPORTING | locked rules and backup summaries | NO | YES | Used as chronological evidence only. |
| `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md` | `SOURCE/PROJECT_DOCS` only | SUPPORTING | locked rules and backup summaries | NO | YES | Used for current-state evidence of JSON transfer and local app baseline. |

## Local Docs Not Summarized

| Local document | Reason |
| --- | --- |
| `OPC_v1_AUDIT_SUMMARY.md` | Large historical audit memory; not needed for this focused locked-rules/backup summary. |
| `OPC_v1_CODEX_RULES.md` | Public manifest, Git workflow, and task template already supersede it. |
| `PROJECT_MAP_OPC_v1.json` | Structured state map; not needed for this focused policy summary. |
| `PROJECT_MAP_OPC_v1_SUMMARY.md` | Current state already public-summarized. |
| `OPC_v1_chat_transkript_TASK_001.md` | Chat transcript; not public source-of-truth material. |
| SOURCE-only task 044/045 reports | Useful process/platform evidence but not necessary for this focused summary. |

## Public Docs Created / Updated

Created:

- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/tasks/OPC_TASK_LOCKED_RULES_AND_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY_REPORT.md`

Updated:

- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`

## Consistency Checks

| Check | Result |
| --- | --- |
| Old SaaS wording | SUPERSEDED by public `OPC Web` / not-primary-SaaS owner decision. |
| Central-master database wording | Not promoted; public summary states no automatic/server-master `PREDMET` database. |
| Windows/Android role split | Not promoted; public summary keeps parity. |
| `naručilac` as current user-facing canonical term | Not promoted; owner-review queue preserved because current evidence is mixed with `Platilac`. |
| Import/restore exception to PIB/Matični broj mismatch | No exception promoted; owner decision says mismatch must block. |
| Implementation before audits | Not promoted; stop-list and queue preserve audit gates. |

## Private Data Exclusion Confirmation

No private/customer/runtime/export JSON, local database, backup archive, restore point marker, credential, signing key, license file, local machine config, build output, or raw chat transcript was added.

## Validation Results

| Check | Result |
| --- | --- |
| Docs-only diff | PASS - changed files are under `docs/` only. |
| Manifest gate | PASS - `python scripts\validate_opc_manifest_gate.py --base 6557346775066714aaf2764874a877b2bfb2ad00`. |
| Source code untouched | PASS - no `lib/`, `test/`, platform, database, migration, backend, Web runner, sync, payment/licensing/entitlement implementation, or package files changed. |
| Flutter analyze/test/build | Not run; docs-only task. |

## Changed Files

- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/tasks/OPC_TASK_LOCKED_RULES_AND_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY_REPORT.md`

## Diff Stat

Final diff stat is recorded in the GitHub handoff after commit creation.

## Open Owner-Review Queue

OWNER REVIEW REQUIRED:

- which local docs should eventually be fully promoted;
- any conflicts between local docs and public docs;
- final canonical implementation terminology for `Platilac`/`narucilac`;
- PDF snapshot label cleanup decision.

TECHNICAL AUDIT REQUIRED:

- Administrator/Savetnik stable internal ID;
- PREDMET opener signature model;
- JSON single `PREDMET` vs full database backup distinction;
- identity/import/restore guard design;
- `FirmaPodaci` history implementation;
- `narucilac` internal compatibility cleanup.

TECHNICAL ARCHITECTURE AUDIT REQUIRED:

- OPC Web local data architecture;
- browser storage vs database outside browser;
- offline/local-replica behavior;
- current internet technical research for OPC Web implementation options.

EXISTING BUSINESS LOGIC EXTRACTION REQUIRED:

- same `PREDMET` conflict rules;
- full PREDMET lifecycle rules;
- local app rules OPC Web must preserve.

## Safe Next Task Recommendation

Safe next task: technical audit of identity/import/restore guard design covering PIB/Matični broj, `FirmaPodaci` history, single `PREDMET` JSON vs full backup JSON, and current implementation gaps.

Unsafe next task: implementation of Web, sync, backend/API, migrations, storage adapter, role/package/payment/licensing changes, or terminology/source cleanup without the required audits.

## Final Git Status

Expected clean after commit/push; final handoff records actual `git status`.

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
