# OPC TASK PUBLIC CONTINUITY BASELINE, TERMINOLOGY GLOSSARY AND SOURCE-OF-TRUTH MAP REPORT

Task: OPC PUBLIC CONTINUITY BASELINE, TERMINOLOGY GLOSSARY AND SOURCE-OF-TRUTH MAP

OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: documentation / continuity baseline / terminology audit
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO
Windows/Android parity affected: NO
Future Web affected: YES - terminology and stop-boundary only
Terminology drift risk: YES - audited and contained
Implementation allowed: NO
Required gate before implementation: source-of-truth / terminology / continuity baseline

## Summary

This task promotes the latest owner-decision baseline into public repository documentation and creates public source-of-truth documents for future OPC work. It is intentionally documentation-only.

No source code, database schema, runtime, Web runner, backend/API, sync, storage adapter, payment/subscription, role implementation, migration, package restructuring, private data, export data, or customer data was changed.

## Branch And Commit

| Field | Value |
| --- | --- |
| Branch | `task/OPC-PUBLIC-CONTINUITY-BASELINE-TERMINOLOGY-SOT` |
| Base commit | `62a684c` |
| Final commit | Recorded in GitHub handoff after commit creation. |

## Created / Updated Public Docs

| Document | Purpose |
| --- | --- |
| `docs/OPC_OWNER_DECISION_REPORT.md` | Public owner-decision baseline. |
| `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md` | Canonical terminology and unresolved terminology queue. |
| `docs/OPC_SOURCE_OF_TRUTH_MAP.md` | Public hierarchy of current truth sources. |
| `docs/OPC_IMPLEMENTATION_STOP_LIST.md` | Explicit blocked implementation areas. |
| `docs/OPC_CURRENT_DEVELOPMENT_STATE.md` | Public current-state continuity snapshot. |
| `README.md` | Public links and `OPC Web`/server-master wording. |
| `docs/PRODUCT_DIRECTION.md` | Canonical `OPC Web` direction and server boundary. |
| `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` | Canonical `OPC Web` term and updated Web stop boundary. |

## Local Document Inventory

| Local document | Folder source | Public-safe? | Classification | Promote? | Sanitization needed? | Reason |
| --- | --- | --- | --- | --- | --- | --- |
| `00_README_KAKO_KORISTITI.md` | `SOURCE/PROJECT_DOCS` | YES AFTER REVIEW | MASTER / CURRENT | YES | YES | Operational continuity entry point; must be normalized to public terminology. |
| `OPC_v1_PROJECT_SOUL.md` | `SOURCE/PROJECT_DOCS` | YES AFTER REVIEW | MASTER / CURRENT | YES | YES | Captures project identity and anti-drift memory. |
| `OPC_v1_PROJECT_FLOW_AND_DELTA.md` | `SOURCE/PROJECT_DOCS` | NEEDS OWNER REVIEW | MASTER / CURRENT | PARTIAL | YES | Large chronological delta; useful but needs curated public extraction. |
| `OPC_v1_ZAKLJUCANA_PRAVILA.md` | `SOURCE/PROJECT_DOCS` | NEEDS OWNER REVIEW | MASTER / CURRENT | PARTIAL | YES | Locked rules may become public baseline after owner confirmation. |
| `OPC_v1_ARCHITECTURE_DECISIONS.md` | `SOURCE/PROJECT_DOCS` | NEEDS OWNER REVIEW | SUPPORTING | PARTIAL | YES | Architecture memory may include superseded or too-local detail. |
| `OPC_v1_CODEX_RULES.md` | `SOURCE/PROJECT_DOCS` | YES AFTER REVIEW | SUPPORTING | PARTIAL | YES | Should be reconciled with public `docs/GIT_WORKFLOW_ARC.md` and task template. |
| `OPC_v1_BACKUP_AND_RESTORE_POLICY.md` | `SOURCE/PROJECT_DOCS` | YES AFTER REVIEW | SUPPORTING | YES | YES | Relevant to JSON/backup safety but needs guard audit alignment. |
| `PROJECT_MAP_OPC_v1_SUMMARY.md` | `SOURCE/PROJECT_DOCS` | YES AFTER REVIEW | SUPPORTING | YES | YES | Useful public milestone summary if owner confirms current values. |
| `PROJECT_MAP_OPC_v1.json` | `SOURCE/PROJECT_DOCS` | NEEDS OWNER REVIEW | SUPPORTING | PARTIAL | YES | Structured state map; should be curated before public master use. |
| `OPC_v1_AUDIT_SUMMARY.md` | `SOURCE/PROJECT_DOCS` | NEEDS OWNER REVIEW | HISTORICAL / SUPPORTING | PARTIAL | YES | Mixed audit memory, may contain stale wording. |
| `OPC_v1_chat_transkript_TASK_001.md` | `SOURCE/PROJECT_DOCS` | NO | HISTORICAL | NO | YES | Chat transcript is not suitable as public master documentation. |
| `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md` | `SOURCE/PROJECT_DOCS` | NEEDS OWNER REVIEW | SUPPORTING | PARTIAL | YES | SOURCE-only report; can inform public docs after review. |
| `OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md` | `SOURCE/PROJECT_DOCS` | NEEDS OWNER REVIEW | SUPPORTING | PARTIAL | YES | SOURCE-only report; relevant to platform parity. |
| `OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md` | `SOURCE/PROJECT_DOCS` | NEEDS OWNER REVIEW | SUPPORTING | PARTIAL | YES | SOURCE-only report; relevant to operating mode. |
| Shared files in `../PROJECT_DOCS` | Control folder | NO DIRECT PROMOTION | BACKUP / CONTROL COPY | NO | YES | Control copy only; compare against `SOURCE/PROJECT_DOCS` before use. |
| Private databases, exports, backups, credentials, runtime files | Any local/private folder | NO | PRIVATE / DO NOT PROMOTE | NO | N/A | Public repository must remain sanitized. |

## Terminology Audit Result

| Term | Result |
| --- | --- |
| `OPC Web` | Canonical future runtime term. |
| `OPC Web Pristup` | Historical/supporting wording; superseded for new public docs. |
| `SaaS` / `saas` | Not primary OPC product terminology; existing internal placeholders need future controlled cleanup only. |
| `narucilac` / `naručilac` | Evidence exists in current source/docs; lineage remains owner-review queue. |
| `klijent` | Not established as replacement for `narucilac`; do not introduce as replacement. |
| `Platilac` / `platilac` | Evidence exists in current UI/PDF/source; exact relationship to `narucilac` remains fact-check queue. |
| `Firma`, `FirmaPodaci`, `PIB`, `Matični broj` | Canonical identity vocabulary; stable identity implementation remains technical audit queue. |
| `Administrator`, `Savetnik` | Canonical role terms; stable role identity remains technical audit queue. |
| `Osnovni`, `Srednji`, `Potpuni` | Canonical package terms; payment/package implementation remains blocked. |

## Open Owner-Review Queue

| Queue | Status |
| --- | --- |
| naručilac/narucilac/klijent/Platilac terminology lineage | FACT CHECK REQUIRED |
| Which `PROJECT_DOCS` files are true master/current | FACT CHECK REQUIRED |
| Administrator/Savetnik stable ID | TECHNICAL AUDIT REQUIRED |
| PREDMET opener signature model | TECHNICAL AUDIT REQUIRED |
| Single `PREDMET` JSON vs full DB/backup JSON distinction | TECHNICAL AUDIT REQUIRED |
| Identity/import/restore guard details | TECHNICAL AUDIT REQUIRED |
| OPC Web local data architecture | TECHNICAL ARCHITECTURE AUDIT REQUIRED |
| Browser storage vs DB outside browser vs OPFS/IndexedDB/SQLite WASM/local agent/hybrid/offline replica | TECHNICAL ARCHITECTURE AUDIT REQUIRED |
| Conflict rules when two replicas/flows affect the same `PREDMET` or related data | EXISTING BUSINESS LOGIC EXTRACTION REQUIRED |
| Existing `PREDMET` lifecycle and local business logic OPC Web must preserve | EXISTING BUSINESS LOGIC EXTRACTION REQUIRED |

## Safe Next Task

Safe next task: owner-reviewed promotion plan for selected `SOURCE/PROJECT_DOCS` files, plus terminology lineage fact-check for `narucilac`, `klijent`, and `Platilac`.

Unsafe next task: Web runner, backend/API, sync, browser storage implementation, database migrations, role implementation, package restructuring, or payment/subscription implementation.

## Validation

| Check | Result |
| --- | --- |
| Docs-only scope | PASS |
| Source code untouched | PASS |
| Public docs created | PASS |
| Both `PROJECT_DOCS` folders addressed | PASS |
| Open questions preserved instead of guessed | PASS |
| Manifest gate | PASS - `python scripts\validate_opc_manifest_gate.py --base 62a684c08b072b942e163c260d27e0d6e50b048f` |

## Changed Files

- `README.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/tasks/OPC_TASK_PUBLIC_CONTINUITY_BASELINE_TERMINOLOGY_AND_SOURCE_OF_TRUTH_MAP_REPORT.md`

## Diff Stat

Final diff stat is recorded in the GitHub handoff after commit creation.

OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES
Core purpose preserved: YES
PREDMET meaning preserved: YES
Database ownership preserved: YES
Windows/Android parity preserved: YES
Existing JSON transfer preserved: YES
Terminology preserved: YES
Future OPC Web not blocked: YES
Source changes within scope: YES - documentation only
PASS / NOT PASS: PASS WITH OWNER REVIEW QUEUE
