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
| Business logic rule inventory | `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md` | Full product baseline audit, prior task reports, source/test evidence | CURRENT AUDIT BASELINE; not an implementation spec. |
| Full business policy and logic snapshot | `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md` | Rule inventory, public reports, source/test inspection | CURRENT PUBLIC BUSINESS ATLAS; not an implementation spec. |
| Business domain and flow map | `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md` | Full snapshot, source/test inspection | CURRENT PUBLIC DOMAIN/FLOW MAP; text diagrams only, not implementation design. |
| PREDMET workflow atlas | `docs/OPC_PREDMET_WORKFLOW_ATLAS.md` | PREDMET UI source, repository source, domain snapshot, tests | CURRENT PUBLIC PREDMET WORKFLOW ATLAS; user/business workflow evidence, not implementation spec. |
| PREDMET dependency and completion maps | `docs/OPC_PREDMET_DEPENDENCY_MAP.md`, `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md` | PREDMET workflow atlas, source/test inspection | CURRENT PUBLIC DEPENDENCY / COMPLETION BASELINE; not implementation authorization. |
| Business policy evaluator deep audit | `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md` | Scenario matrix, consequence graph, completion matrix, evaluator/IRiU/finance/lifecycle source and tests | CURRENT PUBLIC EVALUATOR BASELINE; documents current partial evaluator capability and missing ceremony guidance, not implementation authorization. |
| Logos knowledge transfer | `docs/OPC_LOGOS_KNOWLEDGE_BASE.md` | Module relationship map, source learning index, child-illness/register, public docs, source/test index | CURRENT PUBLIC LOGOS LEARNING BASELINE; product/module/source understanding only, not implementation strategy. |
| Logos pseudocode learning layer | `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md` | Pseudocode index, safe upgrade notes, business-critical source/test inspection | CURRENT PUBLIC SOURCE-TO-PSEUDOCODE BASELINE; learning layer only, not source replacement or implementation authorization. |
| Modular foundation control plan | `docs/OPC_MODULAR_FOUNDATION_CONTROL_PLAN.md` | Module contracts, Web readiness guardrails, grouped safe upgrade plan, pseudocode learning layer | CURRENT PUBLIC MODULAR CONTROL BASELINE; evidence/control plan only, not roadmap, priority order, or implementation authorization. |
| Module contracts and truth boundaries | `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md` | Module relationship map, domain/flow map, owner decisions, legacy architecture docs | CURRENT PUBLIC MODULE CONTRACT BASELINE; documents read/write/output boundaries and blocked implementation areas. |
| Future OPC Web readiness guardrails | `docs/OPC_WEB_READINESS_GUARDRAILS.md` | Manifest, owner decisions, source-of-truth map, implementation stop-list | CURRENT PUBLIC WEB-READINESS GUARDRAILS; no Web/backend/API/sync/storage/payment/licensing/role architecture selected. |
| Grouped safe upgrade families | `docs/OPC_GROUPED_SAFE_UPGRADE_PLAN.md` | Child-illness register, pseudocode map, safe-upgrade notes | CURRENT PUBLIC GROUPED FAMILY REGISTER; evidence buckets only, not recommended next tasks, sequence, or priority order. |
| Characterization evidence foundation | `docs/OPC_CHARACTERIZATION_EVIDENCE_FOUNDATION.md` | Coverage matrix, gap register, before-change rules, pseudocode learning layer | CURRENT PUBLIC CHARACTERIZATION BASELINE; evidence classification only, not implementation authorization. |
| Characterization coverage and gaps | `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`, `docs/OPC_CHARACTERIZATION_GAP_REGISTER.md`, `docs/OPC_CHARACTERIZATION_BEFORE_CHANGE_RULES.md` | Module contracts, grouped safe upgrade plan, current tests, source/docs evidence | CURRENT PUBLIC CHARACTERIZATION CONTROL SET; gaps are blockers/evidence buckets, not roadmap or priority order. |
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
