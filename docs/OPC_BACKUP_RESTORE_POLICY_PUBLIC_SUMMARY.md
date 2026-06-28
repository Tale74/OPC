# OPC Backup/Restore Policy Public Summary

Status: public-safe summary of backup/restore and JSON transfer policy.

This document summarizes policy only. It does not implement backup, restore, import, export, identity guards, migrations, Web sync, or storage adapters.

## Public-Safe Policy

| Area | Summary | Status |
| --- | --- | --- |
| Local backup discipline | Backup and restore points protect source, docs, and project continuity around meaningful milestones and risky structural changes. They are not required after every small green subtask. | PUBLIC SUMMARY |
| Restore point role | A restore point marker documents a known state; it is not a replacement for a backup archive. | PUBLIC SUMMARY |
| Backup contents | Milestone backups should include source and project documentation needed for restore while excluding volatile/generated/output/private material. | PUBLIC SUMMARY |
| Exclusions | Build/cache folders, generated outputs not needed for restore, secrets, private/customer/runtime/export data, signing material, and local machine-only artifacts must not be public-promoted. | PUBLIC SUMMARY |
| Docs-only tasks | Small docs-only tasks usually do not require a new local backup unless they touch core truth lanes or the task explicitly requires a backup milestone. | PUBLIC SUMMARY |
| User-controlled local app transfer | Current local model includes user-controlled single `PREDMET` JSON transfer and full database/backup JSON transfer. | CURRENT BASELINE |
| Single `PREDMET` JSON | Transfers one case/business state boundary and remains distinct from full database backup/import. | CURRENT BASELINE / TECHNICAL AUDIT REQUIRED |
| Full database/backup JSON | Represents broader local backup/import recovery behavior. Current public evidence says destructive restore confirmation exists, but firm identity mismatch guard is not yet implemented. | PARTIALLY REALIZED / NEEDS GUARD |
| Firm identity guard | Owner decision: PIB/Matični broj mismatch must block restore/import with no exception inside the import/restore guard. | OWNER DECISION / NOT YET IMPLEMENTED |
| Web/sync future | Any Web/sync/offline-replica use of backup/restore or JSON transfer requires identity, repository, conflict, and data-ownership audits first. | TECHNICAL AUDIT REQUIRED |

## Current Mismatch To Track

| Decision / policy | Current implementation evidence | Required future action |
| --- | --- | --- |
| PIB/Matični broj mismatch must block restore/import. | Public owner report says full backup/database JSON is realized/partially guarded and lacks firm identity mismatch guard. | Design and implement guarded identity comparison in a separate task. |
| `FirmaPodaci` changes must preserve credible history. | `FirmaPodaci` exists as editable local firm data; history is not public-baseline implemented. | Technical identity/history audit before implementation. |
| Single `PREDMET` JSON and full database/backup JSON must remain distinct. | Evidence supports separate `OPC_PREDMET` and `OPC_BACKUP` formats. | Keep distinction explicit in all future Web/sync/restore tasks. |
| Full backup/import stock handling and broader consequence transfer must be explicit. | Local locked rules mark parts of STANJE ROBE/JSON/full backup behavior as future/audit-sensitive. | Extract current rules before changing import/restore. |

## Public-Safe Known Risks

- Identity guard is conceptually decided but not implemented.
- Editable `FirmaPodaci` cannot be treated as a stable identity mechanism by itself.
- Same-`PREDMET` conflict rules and related-data reconciliation need extraction before Web/sync.
- Old local docs contain stale SaaS and local process wording; public manifest/owner decisions supersede them.
- Raw local backup paths, archive names, and task-specific records are local operational evidence, not public source of truth.

## Provenance

| Local document | Folder source | Classification | Public summary target | Raw copied? | Private data excluded? | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `OPC_v1_BACKUP_AND_RESTORE_POLICY.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | SUPPORTING | This document | NO | YES | Summarized process and exclusions; local paths and command snippets not promoted as public truth. |
| `OPC_v1_ZAKLJUCANA_PRAVILA.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | MASTER / CURRENT MIXED WITH HISTORY | This document | NO | YES | Used for JSON/full-backup and STANJE ROBE boundary evidence. |
| `OPC_v1_PROJECT_FLOW_AND_DELTA.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | HISTORICAL / SUPPORTING | This document | NO | YES | Used for chronological evidence of JSON and backup boundaries. |
| `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md` | `SOURCE/PROJECT_DOCS` only | SUPPORTING | This document | NO | YES | Used for current-state summary of single-PREDMET and full-database JSON transfer. |

## Technical-Audit Required

- repository/firma identity model;
- PIB/Matični broj comparison and failure UX;
- `FirmaPodaci` history model;
- single `PREDMET` JSON vs full backup/database JSON compatibility matrix;
- same-`PREDMET` conflict and related-data reconciliation;
- Web/sync/offline replica import/restore semantics.
