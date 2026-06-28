# OPC Source-Of-Truth Map

Status: public continuity baseline.

| Area | Current source of truth | Supporting sources | Status / caution |
| --- | --- | --- | --- |
| Core purpose | `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` | `README.md`, `docs/PRODUCT_DIRECTION.md` | MASTER / CURRENT. |
| Owner decisions | `docs/OPC_OWNER_DECISION_REPORT.md` | Latest task reports under `docs/tasks/` | MASTER / CURRENT for confirmed decisions; open queues remain unresolved. |
| Terminology | `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md` | Manifest, source code evidence, local `PROJECT_DOCS` | MASTER / CURRENT with fact-check queue. |
| Source-of-truth hierarchy | This document | `docs/GIT_WORKFLOW_ARC.md`, task reports | MASTER / CURRENT. |
| Stop boundaries | `docs/OPC_IMPLEMENTATION_STOP_LIST.md` | Manifest special gates | MASTER / CURRENT. |
| Locked rules | `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md` | Manifest, owner report, local locked rules docs | PUBLIC-SAFE SUMMARY; local raw docs remain supporting evidence only. |
| Backup/restore policy | `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md` | Owner report, local backup/restore policy, JSON transfer evidence | PUBLIC-SAFE SUMMARY; identity guard remains technical-audit item. |
| Business logic extraction queue | `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md` | Local locked rules, terminology lineage, current development state | ACTIVE QUEUE; not an implementation spec. |
| Current development state | `docs/OPC_CURRENT_DEVELOPMENT_STATE.md` | Local `PROJECT_MAP_OPC_v1.json`, prior reports | PUBLIC BASELINE; not a replacement for a full technical audit. |
| Git workflow | `docs/GIT_WORKFLOW_ARC.md` | GitHub branch/commit/report handoffs | MASTER / CURRENT. |
| Task report format | `docs/templates/OPC_TASK_TEMPLATE.md` | Manifest gate script | MASTER / CURRENT. |
| Public task reports | `docs/tasks/*.md` | Git history | AUDIT EVIDENCE; latest report wins only inside its scope. |
| Local project docs in `SOURCE/PROJECT_DOCS` | Not public master yet | See main task report inventory | SUPPORTING / NEEDS OWNER REVIEW before promotion. |
| Control copy `../PROJECT_DOCS` | Not public master | Local filesystem only | BACKUP / CONTROL COPY; do not promote directly without owner review. |
| Promoted local-doc summaries | `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`, `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`, `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md` | `SOURCE/PROJECT_DOCS`, `../PROJECT_DOCS` | PUBLIC-SAFE SUMMARY; raw local docs remain local/control evidence. |
| Terminology lineage | `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md` | Source/UI/PDF evidence and public/local docs | CURRENT EVIDENCE REPORT; implementation cleanup remains blocked. |
| Source code under `lib/`, `test/`, platform folders | Runtime implementation evidence | Generated DB files, tests, build configs | Technical source of implementation truth, but not changed by this docs baseline. |
| Private databases, exports, backups, credentials | Private runtime data | None in public repo | PRIVATE / DO NOT PROMOTE. |

## Hierarchy Rule

For future OPC tasks, public repository docs in `docs/` define the active continuity baseline. Local `PROJECT_DOCS` may provide historical context and implementation memory, but owner review is required before any local document is promoted as public master text.
