# OPC Project Docs Public Promotion Map

Status: public-safe summary of local `PROJECT_DOCS` promotion decisions.

This document classifies the two local documentation sources without copying private/control material into the public repo. The control folder `../PROJECT_DOCS` contains 11 files that are byte-identical to the matching files in `SOURCE/PROJECT_DOCS`. `SOURCE/PROJECT_DOCS` also contains three SOURCE-only audit reports.

| Local document | Folder source | Public-safe? | Classification | Promote? | Sanitization needed? | Reason | Proposed public path |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `00_README_KAKO_KORISTITI.md` | `SOURCE/PROJECT_DOCS` and control copy | YES AS SUMMARY | SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Local operating guide; useful rules are now covered by public workflow/manifest docs. | `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md` |
| `OPC_v1_PROJECT_SOUL.md` | `SOURCE/PROJECT_DOCS` and control copy | YES AS SUMMARY | MASTER / CURRENT, PARTLY SUPERSEDED | ALREADY COVERED BY PUBLIC DOC | YES | Core identity is now public in manifest, owner report, product direction, and current-state docs; SaaS wording is superseded. | `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` |
| `OPC_v1_ARCHITECTURE_DECISIONS.md` | `SOURCE/PROJECT_DOCS` and control copy | YES AS SUMMARY | SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Valuable architecture memory but contains stale SaaS/licensing/secret-handling detail and chronological noise. | Future `docs/archive/OPC_v1_ARCHITECTURE_DECISIONS_SUMMARY.md` |
| `OPC_v1_AUDIT_SUMMARY.md` | `SOURCE/PROJECT_DOCS` and control copy | YES AS SUMMARY | HISTORICAL / SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Useful historical audit memory, but not current source of truth. | Future `docs/archive/OPC_v1_AUDIT_SUMMARY_PUBLIC_SUMMARY.md` |
| `OPC_v1_BACKUP_AND_RESTORE_POLICY.md` | `SOURCE/PROJECT_DOCS` and control copy | YES AS SUMMARY | SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Process rules matter; paths/backup naming/local workflow need public-safe normalization. | Future `docs/OPC_BACKUP_AND_RESTORE_PUBLIC_POLICY.md` |
| `OPC_v1_CODEX_RULES.md` | `SOURCE/PROJECT_DOCS` and control copy | YES AS SUMMARY | SUPPORTING | SUPERSEDED BY PUBLIC DOC | YES | Public task template, manifest, and Git workflow now control Codex behavior. | `docs/GIT_WORKFLOW_ARC.md`, `docs/templates/OPC_TASK_TEMPLATE.md` |
| `OPC_v1_PROJECT_FLOW_AND_DELTA.md` | `SOURCE/PROJECT_DOCS` and control copy | NO RAW COPY | HISTORICAL / SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Large chronological development memory with stale terms, paths, release details, and secret/customer cautions. | Future `docs/archive/OPC_v1_PROJECT_FLOW_AND_DELTA_PUBLIC_SUMMARY.md` |
| `OPC_v1_ZAKLJUCANA_PRAVILA.md` | `SOURCE/PROJECT_DOCS` and control copy | NO RAW COPY | MASTER / CURRENT MIXED WITH HISTORY | PROMOTE SANITIZED SUMMARY | YES | Contains important locked rules but also old task-specific and licensing/key material. | Future `docs/OPC_LOCKED_RULES_PUBLIC_BASELINE.md` |
| `PROJECT_MAP_OPC_v1.json` | `SOURCE/PROJECT_DOCS` and control copy | YES AS SUMMARY ONLY | SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Structured status map is useful, but raw JSON is not the public authority. | Future `docs/OPC_PROJECT_MAP_PUBLIC_SUMMARY.md` |
| `PROJECT_MAP_OPC_v1_SUMMARY.md` | `SOURCE/PROJECT_DOCS` and control copy | YES AS SUMMARY | SUPPORTING | ALREADY COVERED BY PUBLIC DOC | YES | Current-state summary has been promoted at higher level. | `docs/OPC_CURRENT_DEVELOPMENT_STATE.md` |
| `OPC_v1_chat_transkript_TASK_001.md` | `SOURCE/PROJECT_DOCS` and control copy | NO | HISTORICAL | DO NOT PROMOTE | YES | Chat transcript is not a stable public source of truth. | N/A |
| `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md` | `SOURCE/PROJECT_DOCS` only | YES AS SUMMARY | SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Useful re-entry state audit; should not be raw-promoted. | Future `docs/archive/OPC_RE_ENTRY_AUDIT_PUBLIC_SUMMARY.md` |
| `OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md` | `SOURCE/PROJECT_DOCS` only | YES AS SUMMARY | SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Cross-platform baseline evidence; current public parity rules already cover the core. | Future `docs/archive/OPC_TASK_044_PUBLIC_SUMMARY.md` |
| `OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md` | `SOURCE/PROJECT_DOCS` only | YES AS SUMMARY | SUPPORTING | PROMOTE SANITIZED SUMMARY | YES | Operating-mode evidence; public workflow docs already supersede most process rules. | Future `docs/archive/OPC_TASK_045_PUBLIC_SUMMARY.md` |

## Promotion Result

No raw local `PROJECT_DOCS` file was copied. The safe promotion in this task is this classification map plus the terminology lineage report. Future promotion should create curated summaries, not direct mirrors, unless the owner explicitly approves a file as public master text.
