# OPC Source-Of-Truth Map

Status: current Phase 1 authority/navigation baseline.

## Active current-state information homes

The compact current-state product/engineering surface is README navigation
plus five substantive homes. README is not a co-equal detailed authority:

| Information purpose | Current home |
|---|---|
| Product/domain/business authority | `docs/OPC_PRODUCT_AND_DOMAIN.md` |
| Current architecture and deployment | `docs/OPC_ARCHITECTURE.md` |
| Development, authority and validation workflow | `docs/OPC_DEVELOPMENT.md` |
| Quality, regression, runtime and release gaps | `docs/OPC_QUALITY_RELEASE.md` |
| Adopted OPC engineering profile | `docs/OPC_ENGINEERING_PROFILE.md` |

The manifest, archive classification, internal-control register and Phase 1
implementation report are transition/supporting records. They remain useful
and linked, but do not add current authority homes.

These five homes are the normal reading surface. Every detailed row below is
subordinate supporting authority/evidence, owner provenance, governance,
historical, internal or private material; none is a co-equal compact current
authority home.

## RR-005 closure reconciliation

The current correction authority is `RR-005 CORRECTION CLOSED — FULL
ACCEPTANCE PASS — NO RR-005-SPECIFIC SUCCESSOR` in the release-risk and
open/closed control records. Earlier disposable migration/recovery rehearsal
records that report `ACCEPTANCE INCONCLUSIVE` are historical/separately scoped
evidence only. They must not reopen RR-005 or become a second current fact.

| Area | Current source of truth | Supporting sources | Status / caution |
| --- | --- | --- | --- |
| Post-zero owner authority | `docs/OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md` | Later explicitly owner-confirmed Git records | OWNER AUTHORITY RECORD; interpreted through the compact Phase 1 homes. Pre-zero owner decisions are not current authority. |
| Incident and anti-drift evidence | `docs/OPC_INCIDENT_AND_ANTI_DRIFT_REGISTER.md` | Linked historical reports and Git history | PERMANENT EVIDENCE; does not revive pre-zero policy. |
| Documentation classification | `docs/OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md` | Git tree and history | CURRENT SUPPORTING EVIDENCE — classification register subordinate to the compact Phase 1 homes; separates active, technical, historical and future-scope documents. |
| Current development dependency order | `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md` | `docs/OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md`, current state, latest scoped reports, source/tests | CURRENT SUPPORTING EVIDENCE — operative dependency-map input subordinate to the compact homes. Historical chronology in the pre-reconciliation plan remains Git evidence, not current sequencing. |
| Plan reality evidence | `docs/OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md` | Exact reviewed reports, source/test cross-check and Git history | CURRENT SUPPORTING EVIDENCE — reconciliation provenance for completed work, blockers, debt, owner queue and product-line boundary. |
| Core purpose | `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` | Post-zero authority, `README.md`, `docs/PRODUCT_DIRECTION.md` | CURRENT SUPPORTING EVIDENCE — governance input subordinate to post-zero owner authority and the compact homes. |
| IRiU business composition and ordering | Owner-approved invariant recorded in `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` and surfaced in `docs/OPC_PRODUCT_AND_DOMAIN.md` | Applied SCENARIO snapshot, package configuration, technical projections and local internal development-control material | CURRENT SUPPORTING EVIDENCE — ordered OSNOVNI PAKET → ordered applied SCENARIO PAKET → manual/unpredicted items. Package contents are editable; concrete item lists, persisted `redosled`, provenance, source output and golden fixtures are not authority. |
| Pre-zero owner decisions | None | `docs/OPC_OWNER_DECISION_*.md`, pre-zero task reports | HISTORICAL EVIDENCE ONLY unless explicitly reconfirmed post-zero. |
| Terminology | `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md` | Manifest and source-code evidence | CURRENT SUPPORTING EVIDENCE — terminology/continuity reference subordinate to the compact product/domain home; business-policy changes require post-zero owner confirmation. |
| Source-of-truth hierarchy | This document | `docs/OPC_DEVELOPMENT.md`, task reports | CURRENT SUPPORTING EVIDENCE — hierarchy record; the compact homes are the normal reading surface. |
| Stop boundaries | `docs/OPC_IMPLEMENTATION_STOP_LIST.md` | Manifest special gates | CURRENT SUPPORTING EVIDENCE — stop/control record; the compact homes are the normal reading surface. |
| Locked-rule summary | `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md` | Manifest, current source/tests and Git history | PRE-ZERO/TECHNICAL EVIDENCE; not current owner authority. |
| Backup/restore policy | `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md` | Post-zero canonical-data boundary, current source/tests and Git history | TECHNICAL/RECOVERY EVIDENCE; normalized PIB/MB identity guard is source/test proven, while owner-facing runtime acceptance remains separate. |
| Business logic extraction queue | `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md` | Current source/tests, terminology lineage and current development state | TECHNICAL EVIDENCE QUEUE; not an implementation spec or current policy. |
| Business logic rule inventory | `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md` | Full product baseline audit, prior task reports, source/test evidence | CURRENT SUPPORTING EVIDENCE — audit inventory subordinate to the compact product/domain and architecture homes; not an implementation spec. |
| Full business policy and logic snapshot | `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md` | Rule inventory, public reports, source/test inspection | CURRENT SUPPORTING EVIDENCE — detailed business atlas subordinate to the compact product/domain home; not an implementation spec. |
| Business domain and flow map | `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md` | Full snapshot, source/test inspection | CURRENT SUPPORTING EVIDENCE — detailed domain/flow evidence subordinate to the compact product/domain and architecture homes; text diagrams only. |
| PREDMET workflow atlas | `docs/OPC_PREDMET_WORKFLOW_ATLAS.md` | PREDMET UI source, repository source, domain snapshot, tests | CURRENT SUPPORTING EVIDENCE — workflow detail subordinate to the compact product/domain home; not an implementation spec. |
| PREDMET dependency and completion maps | `docs/OPC_PREDMET_DEPENDENCY_MAP.md`, `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md` | PREDMET workflow atlas, source/test inspection | CURRENT SUPPORTING EVIDENCE — dependency/completion detail subordinate to the compact homes; not implementation authorization. |
| Business policy evaluator deep audit | `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md` | Scenario matrix, consequence graph, completion matrix, evaluator/IRiU/finance/lifecycle source and tests | CURRENT SUPPORTING EVIDENCE — evaluator detail subordinate to the compact homes; documents partial capability and missing ceremony guidance, not implementation authorization. |
| Logos knowledge transfer | `docs/OPC_LOGOS_KNOWLEDGE_BASE.md` | Module relationship map, source learning index, child-illness/register, public docs, source/test index | CURRENT SUPPORTING EVIDENCE — product/module/source learning subordinate to the compact homes; not implementation strategy. |
| Logos pseudocode development-control layer | Local-only `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/` recorded by `docs/OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md` | Source/test inspection, roadmap comparison and preserved Git history | STRICTLY INTERNAL TALE/LOGOS DEVELOPMENT-CONTROL MATERIAL; not final product documentation, production specification, market-facing SOURCE documentation or handover documentation. Closure Correction moves the unchanged artifacts out of `docs/`; the register is the public boundary record. |
| Modular foundation control plan | `docs/OPC_MODULAR_FOUNDATION_CONTROL_PLAN.md` | Module contracts, Web readiness guardrails, grouped safe upgrade plan, internal pseudocode development-control material | CURRENT SUPPORTING EVIDENCE — modular control plan subordinate to the compact architecture/development homes; not roadmap, priority order or implementation authorization. |
| Phase 1 full code/architecture review | `docs/OPC_PHASE_1_FULL_CODE_ARCHITECTURE_REVIEW.md`, `docs/OPC_PHASE_1_ARCHITECTURE_DECISION_GATE_EVIDENCE_MATRIX.md` | Current source, platform folders and tests | TECHNICAL EVIDENCE BASELINE; interpreted by the post-zero Architecture Decision Gate synthesis. |
| Post-zero Architecture Decision Gate | `docs/OPC_POST_ZERO_ARCHITECTURE_DECISION_GATE_SYNTHESIS.md` | Phase 1 evidence matrix, current source/tests and technical audits | CURRENT SUPPORTING EVIDENCE — technical decision record subordinate to the compact architecture home; evidence determines retain/move/split/merge/refactor/rewrite/reconstruct/remove decisions and affected implementation sub-gates remain closed. |
| Post-zero PREDMET lifecycle/referential design | `docs/OPC_POST_ZERO_PREDMET_LIFECYCLE_REFERENTIAL_DESIGN.md` | Referential audit, dependent-data matrix, current source/tests, later RI task reports and migration policy | CURRENT SUPPORTING EVIDENCE — design/referential detail subordinate to the compact architecture/product homes. RI-1 and bounded RI-2 hard-delete/full-restore work advanced; remaining RI owner gates and final release rehearsal stay separate. |
| Module contracts and truth boundaries | `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md` | Module relationship map, domain/flow map, owner decisions, legacy architecture docs | CURRENT SUPPORTING EVIDENCE — module contract detail subordinate to the compact architecture/product homes; documents read/write/output boundaries and blocked implementation areas. |
| Future OPC Web readiness guardrails | `docs/OPC_WEB_READINESS_GUARDRAILS.md` | Manifest, owner decisions, source-of-truth map, implementation stop-list | CURRENT SUPPORTING EVIDENCE — Web-readiness guardrails subordinate to the compact homes; no Web/backend/API/sync/storage/payment/licensing/role architecture selected. |
| Grouped safe upgrade families | `docs/OPC_GROUPED_SAFE_UPGRADE_PLAN.md` | Child-illness register, pseudocode map, safe-upgrade notes | CURRENT SUPPORTING EVIDENCE — grouped family register subordinate to the compact homes; evidence buckets only, not recommended next tasks, sequence or priority order. |
| Characterization evidence foundation | `docs/OPC_CHARACTERIZATION_EVIDENCE_FOUNDATION.md` | Coverage matrix, gap register, before-change rules, internal pseudocode development-control material | CURRENT SUPPORTING EVIDENCE — characterization foundation subordinate to the compact homes; evidence classification only, not implementation authorization. |
| Characterization coverage and gaps | `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`, `docs/OPC_CHARACTERIZATION_GAP_REGISTER.md`, `docs/OPC_CHARACTERIZATION_BEFORE_CHANGE_RULES.md` | Module contracts, grouped safe upgrade plan, current tests, source/docs evidence | CURRENT SUPPORTING EVIDENCE — characterization controls subordinate to the compact homes; gaps are blockers/evidence buckets, not roadmap or priority order. |
| PREDMET lifecycle identity version characterization | `docs/OPC_PREDMET_LIFECYCLE_IDENTITY_VERSION_CHARACTERIZATION.md` | PREDMET lifecycle coverage matrix, identity/version/change-log gap register, Web/sync identity risk register, source/test evidence | CURRENT SUPPORTING EVIDENCE — PREDMET characterization detail subordinate to the compact product/domain home; not implementation authorization. |
| Current development state | `docs/OPC_CURRENT_DEVELOPMENT_STATE.md` | Reconciled plan/report, current source/tests, post-zero reports and Git history | CURRENT SUPPORTING EVIDENCE — concise continuity detail subordinate to the compact homes; detailed ordering remains in the operative plan. |
| SCENARIO locked module baseline | `docs/OPC_SCENARIO_MODULE_LOCK.md` | `docs/OPC_SCENARIO_MODULE_LOCK_REPORT.md`, locked source SHA, predecessor runtime/build evidence and existing Tier 2 tests | CURRENT SUPPORTING EVIDENCE — SCENARIO lock governance evidence subordinate to the compact homes. SCENARIO is locked; production changes require explicit unlock or proven regression correction. |
| Cross-device continuity final closure | `docs/OPC_CROSS_DEVICE_CONTINUITY_FINAL_CLOSURE_REPORT.md` | Final-closure source/tests, fresh forensic-copy SQL proof and validation logs | CURRENT SUPPORTING EVIDENCE — scoped closure evidence subordinate to the compact homes; canonical DB mutation and Android physical acceptance remain separately gated. |
| Windows KATALOG→IRiU pipeline / runtime closure | `docs/OPC_CANONICAL_KATALOG_IRIU_PIPELINE_WINDOWS_CLOSURE_REPORT.md` (supersedes the prior Windows visual-closure report for this scope) | Source inventory, canonical snapshot repair, focused tests/analyzer/build, owner runtime evidence and deployment blocker | CURRENT SUPPORTING EVIDENCE — Windows gate evidence subordinate to the compact homes; repaired-build deployment and installed visual/SCENARIO/LISTA proof remain deferred. |
| Public task reports | `docs/tasks/*.md` | Git history | AUDIT EVIDENCE; latest report wins only inside its scope. |
| Legacy/parallel project-doc locations | None currently present in the known tree | Git history, protected backups, local Phase 1 inventory and surviving local evidence | Legacy `SOURCE/PROJECT_DOCS` and external `PROJECT_DOCS` locations are not automatically current authority; any surviving local material remains classified by the Phase 1 manifest and is not deleted or ignored merely because it is outside Git. |
| Promoted pre-zero summaries | Inventory-classified Git documents | Current source/tests and Git history | PRE-ZERO OR TECHNICAL EVIDENCE ONLY; no raw local source remains active. |
| Terminology lineage | `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md` | Source/UI/PDF evidence, Git documents and history | PRE-ZERO TECHNICAL EVIDENCE; implementation cleanup remains separately gated. |
| Source code under `lib/`, `test/`, platform folders | Runtime implementation evidence | Generated DB files, tests, build configs | Technical source of implementation truth, but not changed by this docs baseline. |
| Private databases, exports, backups, credentials | Private runtime data | None in public repo | PRIVATE / DO NOT PROMOTE. |

## LUNA recovery authority — 2026-08-13

`docs/OPC_CANONICAL_DATA_RECOVERY_AND_STABILIZATION_REPORT.md` is the current
execution report for canonical data recovery. Its committed ledger summary is
`docs/artifacts/OPC_LUNA_RECOVERY_LEDGER_SUMMARY.json`. The canonical DB and
clean backup remain private runtime artifacts; the original contaminated
backup is forensic evidence and was not overwritten.

## Hierarchy Rule

For future OPC tasks, `SOURCE/docs` and `README.md` are the Git-visible current
product/engineering documentation surface published through GitHub. The active
project remains a **local + GitHub** maintenance model until the owner defines
the future transition, acquisition or distribution model. Local material outside
Git remains relevant when the Phase 1 manifest classifies it as current/supporting
evidence, internal governance, runtime evidence, historical evidence or private
data; it is not silently deleted or made irrelevant merely because it is outside
Git. No uncontrolled mirror or automatic network synchronization mechanism is
implied. Source/tests prove implemented behavior; only post-zero owner records
approve business policy.
