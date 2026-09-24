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

Active-source authority and donor classification are governed by
`docs/OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`. It is a durable
control document, not a sixth product/domain authority home and not a source
of new business meaning.

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
| Owner roadmap provenance and reverse coverage | `docs/tasks/OPC_TASK_ROADMAP_PROVENANCE_RECONCILIATION_OWNER_ROADMAP_RESTORATION_REPORT.md` | Original post-zero plan drafts/candidate, owner-review findings, current authority, Git history and accepted closures | CURRENT SUPPORTING EVIDENCE — provenance matrix and zero-orphan reverse check; not a competing roadmap authority. |
| Recovered PODSETNIK owner authority | Recovery baseline and traceability ledger supplied in the recovered-owner restoration review package | `docs/OPC_OWNER_DECISION_GUIDE.md` section 9, `docs/OPC_OWNER_DECISION_INDEX.md`, current source/audit evidence | OWNER TARGET AUTHORITY — restored decisions POD-001…POD-074; no re-decision. Current source remains separate; foundation, bounded UI/primary-notification work, R5 ČITULJA integration, URNA/PEPEO lifecycle and F-06 manual obligations are implemented at source/test/documentation level; runtime/release acceptance remains pending. The 2026-09-19 F-09 owner clarification is a separate dated addendum, not a new ID or pseudocode authority. |
| F-09 FINANSIJE owner clarification and Member 1 implementation — 2026-09-20 | `docs/OPC_PRODUCT_AND_DOMAIN.md` §6 and `docs/OPC_OWNER_DECISION_GUIDE.md` §9.6 | Owner-provided predicate and PRE-CEREMONY placement decisions; implementation continuation; current-state and quality/release homes; focused source/tests/build evidence | OWNER AUTHORITY — FINANSIJE is the PRE-CEREMONY parent with sibling PRE-CEREMONY children PLATITI RAČUN and NAPLATITI OBAVEZE. PLATITI RAČUN iff `TROŠKOVI JKP > 0 AND jkpPlacaSamostalno == false`; NAPLATITI OBAVEZE iff `ZA NAPLATU > 0`. Member 1 is source/test/QA/build complete; runtime/release remains separate. Broader reminder scope is deferred; no child sequencing is created. |
| PREDMET unified three-dot menu and `ZAVRŠEN` presentation consolidation — 2026-09-20 | `docs/OPC_PRODUCT_AND_DOMAIN.md` §6 (OWNER-authorized same-PREDMET menu-equality invariant); current Member 2 task authorization | `lib/features/predmeti/presentation/predmet_overflow_menu.dart`, `lista_predmeta_screen.dart`, `predmet_screen.dart`, `test/predmet_overflow_menu_unification_test.dart`, relocation/regression tests, current development state and dependency plan | TECHNICAL STATUS — list-row and opened/expanded detail menus consume one canonical action definition and expose identical action identities/labels/enabled states for the same PREDMET state; no valid action is lost. JSON EXPORT appears in both menus and not in `DOKUMENTI`; JSON IMPORT remains exclusively in unchanged `PODEŠAVANJA`. Existing navigation, GDPR and permanent-delete actions are preserved; `ZAVRŠEN` follows the same lifecycle path, with Segment 10/narrow Android duplicates absent. Transfer contract and lifecycle business rules are unchanged. Full tests, analyzer and Windows/Android release builds pass; OWNER runtime acceptance remains separate and unclaimed. |
| Normal-roadmap Member 3 — RAČUN toggle, shared PDF/DOCX model and snapshot retirement — 2026-09-21 | OWNER authority: `docs/OPC_PRODUCT_AND_DOMAIN.md` §6 and `docs/OPC_OWNER_DECISION_GUIDE.md` §9.7 | `docs/OPC_ARCHITECTURE.md`, current development state, quality/release and dependency-plan records; `firma_podaci_table.dart`, database/migration, Backup, settings, RAČUN data/PDF/DOCX adapters and focused tests | PUBLISHED — one FIRMA toggle (default DA, legacy Backup omission DA) solely gates both RAČUN formats; both use a shared canonical data model; Article 33 is retained; Single-PREDMET JSON is unchanged; PREDMET PDF SNAPSHOT is retired. Published in commit `d5ec4350b143607068f430f9ae3d352aa578f0a0`. Full suite 575 PASS / 10 SKIP / 0 FAIL, analyzer and Windows/Android release builds pass. OWNER accepted Word 2019 direct open, one-page render and print/layout parity. The proven defect was a missing trailing paragraph after the nested signature-label table; `_requiredTrailingParagraph()` corrected it. Five nonconformant PDF exporters were left unchanged because equivalence was not proven; NALOG CVEĆARI remains unchanged and conformant. |
| Normal-roadmap Scenario ↔ KATALOG clean-start baseline and category-delete protection — 2026-09-22 | `docs/OPC_PRODUCT_AND_DOMAIN.md` §4 and `§6` | `docs/OPC_ARCHITECTURE.md`, current development state, `lib/core/catalog/katalog_category_baseline.dart`, `AppDatabase`, KATALOG/SCENARIO repositories and focused source/tests | PUBLISHED / OWNER IMPLEMENTATION ACCEPTANCE — fresh databases seed the exact 29 system-required category configurations and no business articles or starter pack; `interniNaziv` is stable while `nazivPrikaz` is editable; user categories remain valid SCENARIO references; any persisted built-in or custom SCENARIO reference blocks physical category deletion and preserves existing deactivate/hide behavior. Windows Scenario delete protection PASS; Android clean-start category bootstrap PASS; Windows/Android semantic parity PASS for this package scope. No schema/JSON contract or unrelated scenario policy change is introduced. Broader release gates remain separate. |
| PODSETNIK implementation readiness | `docs/OPC_PODSETNIK_IMPLEMENTATION_READINESS_CONTRACT.md` | Recovered owner baseline, source/audit evidence, internal pseudocode | SUBORDINATE TECHNICAL DESIGN — its exact three-task order applies only to its established scope; it cannot create F-09 business semantics, select a current roadmap member, or claim implementation. |
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
| Backup/restore policy | `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md` | Post-zero canonical-data boundary, current source/tests, Windows owner runtime evidence and Git history | TECHNICAL/RECOVERY EVIDENCE; normalized PIB/MB identity guard is source/test proven and Windows owner acceptance is PASS in a bounded disposable lane; direct post-restore back/logout observation remains evidence-incomplete. |
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
| Completed post-drift recovery record | `docs/OPC_POST_DRIFT_RECOVERY_PLAN.md` | Accepted recovery handoffs, current development state, dependency plan, protected residual ledger and matrix | HISTORICAL CONTINUITY EVIDENCE — formally closed 2026-09-18; preserves recovery lineage and closure evidence, but is no longer current roadmap sequencing authority and creates no product requirements. |
| R1–R5 current-state reconciliation | `docs/OPC_R1_R5_CURRENT_STATE_RECONCILIATION.md` | Accepted R1–R5 review packages, current source/tests and the compact current-state homes | CURRENT SUPPORTING EVIDENCE — consolidated implementation/review/runtime classification and next-work roadmap; not a new owner authority or implementation plan. |
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

Active-source and donor classification, including `UNRESOLVED – DO NOT USE`,
is governed by `OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`.

## Active-source authority hygiene and publication boundary

The accepted hygiene evidence records the active SOURCE/document roots,
generated roots, evidence-only roots, historical donors, quarantined obsolete
roots and unresolved roots. The prior hygiene package remains preserved as
historical evidence. The active package identity and hash are recorded by the
current-state and final handoff records; this map does not duplicate that
mutable package identity. The active-source high-risk baseline and package
integrity must be verified from the current package before substantive work.

This map distinguishes documentation authority from implementation
publication. The published v1.5 product-source target remains the clean
baseline identified in the current-state home; this task's local documentation
delta remains unpublished until a separate owner-gated Docs-as-Code action.
Earlier mixed/dirty SOURCE descriptions are historical state snapshots and
must not be presented as current. A documentation update does not itself claim
product implementation, runtime acceptance, or release publication. Review
and quarantine material remains evidence, not implementation authority.

| Area | Current source of truth | Supporting sources | Status / caution |
| --- | --- | --- | --- |
| Active-source authority and donor control | `docs/OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md` | Current external/local-only package containing the logical inputs `ACTIVE_SOURCE_AUTHORITY_MANIFEST.json`, `STALE_DONOR_DENYLIST.json`, `HIGH_RISK_ACTIVE_HASH_BASELINE.csv`, `DONOR_USE_GATE.md` and `OPC_ACTIVE_SOURCE_PRECHECK.md`, plus the current hygiene handoff | CURRENT AUTHORITATIVE CONTROL – the task must resolve the package location, physically read and individually report all five inputs before source-learning or modification; donor reuse requires bounded reconciliation and explicit OWNER authorization; unresolved roots remain `UNRESOLVED – DO NOT USE`. |

## R2 implementation traceability

The current R2/R2B/R3/R4 implementation evidence is `lib/core/database/tables/citulje_pripreme_table.dart`, `lib/features/predmeti/citulje/**`, `lib/features/predmeti/presentation/moduli_screen.dart`, `lib/core/json_transfer/predmet_json_transfer_core.dart`, `lib/core/utils/json_export_import.dart`, `test/citulje_domain_persistence_test.dart`, `test/citulje_finalized_write_guard_test.dart`, `test/citulje_module_screen_test.dart` and `test/citulje_pdf_export_test.dart`. These sources establish the bounded ČITULJE persistence/transfer foundation plus the dedicated current-occurrence UI, locally editable DA proposal, valid-text finalization guard, atomic current-form-state finalization, repository write guard, derived word count and canonical per-occurrence PDF output from persisted state. They do not supersede owner authority or claim ČITULJE PODSETNIK completion, final visual design, F-06 or F-09 work.

## R5 implementation traceability

R5 implementation evidence is `lib/features/podsetnik/domain/podsetnik_obligation.dart`, `lib/features/podsetnik/data/podsetnik_obligation_repository.dart`, `lib/features/podsetnik/presentation/podsetnik_module_screen.dart`, `lib/features/predmeti/pdf/lista_pdf_data_builder.dart`, `lib/features/predmeti/presentation/lista_predmeta_screen.dart`, `test/r5_podsetnik_citulja_integration_test.dart` and the adjusted `test/lista_predmeta_screen_smoke_test.dart`. These sources establish current-occurrence grouped parent/atomic-child derivation, portable child completion preservation across temporary membership absence, per-occurrence PDF routing, shared LISTA labels and the bounded general-parent overview-bar correction. The MODULI responsive presentation and STANJE ROBE test-recovery evidence additionally use `lib/features/predmeti/presentation/moduli_screen.dart`, `test/moduli_screen_responsive_test.dart` and `test/stanje_robe_operational_toggle_test.dart`; the correction is presentation/test-interaction only. The later milestone evidence additionally covers URNA/PEPEO and F-06 in `lib/features/predmeti/reminders/urna_ashes_reminder_model.dart`, the reminder coordinator/repository, `lib/features/podsetnik/**`, `lib/core/database/database.dart`, `lib/core/utils/json_export_import.dart` and `test/podsetnik_urna_f06_milestone_test.dart`.

The OWNER-selected F-09 Member 1 implementation additionally uses
`lib/features/predmeti/core_v2/services/financial_truth_service.dart`,
`lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart`,
`lib/features/predmeti/presentation/segments/finansije_segment.dart` and
`test/f09_finansije_podsetnik_test.dart`. The shared receivable calculation
keeps the FINANSIJE display and `NAPLATITI OBAVEZE` threshold aligned; the
generic obligation watch refreshes from PREDMET/IRiU/stock/completion inputs.
F-09 has no schema or JSON contract change and adds no `ZAVRŠEN` blocker.

## LISTA PDF / canonical NAPOMENA / CVEĆE ribbon — 2026-09-23

Current implementation evidence is `lib/features/predmeti/pdf/lista_pdf_data_builder.dart`,
`lib/features/predmeti/pdf/lista_pdf_export.dart`,
`lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`,
`lib/features/predmeti/presentation/segments/finansije_segment.dart`,
`lib/features/predmeti/citulje/presentation/citulje_module_screen.dart`,
`lib/features/podsetnik/presentation/podsetnik_module_screen.dart`,
`test/lista_pdf_obligations_notes_test.dart`,
`test/podsetnik_task2_ui_integration_test.dart` and
`test/citulje_module_screen_test.dart`. LISTA renders human-readable shared
PODSETNIK labels with parent/child linkage and empty actionable paper boxes;
the notes section projects only canonical `Predmeti.napomena`; each non-empty
CVEĆE IRiU ribbon is associated with its row. Concise family-specific
operational context and user-entered manual obligations are projected under
the relevant action. URNA/PEPEO use the shared short business parent/child
presentation. Whole groups flow across columns when needed, with a two-page
maximum and no permission to discard required content. Obsolete note inputs
are removed from current Statusi, Finansije and ČITULJE editing, while their
schema, serialization and backup fields remain intact. No database schema or
JSON contract change is made. Final focused/full QA and fresh release builds
are recorded in the task review handoff. OWNER accepted the corrected Windows
LISTA runtime output on 2026-09-24: OBAVEZE, NAPOMENE, CVEĆE occurrence/ribbon
context, post-ceremony hierarchy and the two-page maximum are PASS. The earlier
pre-correction OBAVEZE failure remains historical evidence and is superseded
by this current acceptance; publication/Git synchronization is recorded
separately.

## PREDMET unified three-dot menu implementation traceability — 2026-09-20

The bounded Member 2 correction is implemented by the shared action
construction in `lib/features/predmeti/presentation/predmet_overflow_menu.dart`,
consumed from `lista_predmeta_screen.dart` and `predmet_screen.dart`. For the
same concrete PREDMET and business state, both surfaces expose matching action
identities, labels and enabled states. The canonical action union preserves
edit/open, close, documents, PODSETNIK, Single-PREDMET JSON export, `ZAVRŠEN`,
GDPR anonymization and permanent delete under their existing predicates.
JSON export uses the selected/current PREDMET identity from either menu and is
not a `DOKUMENTI` action; JSON import remains exclusively in
`PODEŠAVANJA`. Import UI, serializer, transfer contract, lifecycle repository,
schema and JSON behavior are unchanged. `ZAVRŠEN` retains its existing
repository lifecycle path and blockers; duplicate Segment 10 and narrow
Android triggers remain absent. The focused equality/navigation/lifecycle/
JSON/GDPR/delete tests, relevant regressions, full serialized tests, analyzer,
Windows release and Android production release all pass. OWNER runtime
acceptance is not inferred or claimed.

## Current-state restoration implementation traceability — 2026-09-08

The restoration source truth is the current `lib/` and `test/` tree. Domain 1
uses `lib/features/predmeti/pdf/opc_pdf_shared.dart`,
`lib/features/predmeti/pdf/nalog_cvecari_pdf_export.dart`,
`lib/features/predmeti/presentation/predmet_screen.dart` and the entitlement
policy; Domain 2 uses the ČITULJE repository/module sources and
`test/citulje_domain_persistence_test.dart`; Domain 3 uses the URNA/PEPEO
model, reminder coordinator and LISTA adapter; Domain 4 uses the contextual
PODSETNIK screen; Domain 5 uses the shared obligation roots and LISTA
overview-bar; Domain 6 is protected by the existing database recovery,
transfer and full-backup contracts. Added/affected tests include the Cvećari
PDF/entitlement tests, ČITULJE race coverage, URNA secondary-cycle coverage
and PODSETNIK root coverage.

The implementation evidence is technical only: targeted/regression checks
`217 PASS / 0 FAIL`, analyzer PASS and full serial suite
`528 PASS / 10 SKIP / 0 FAIL`. Build/runtime/device acceptance and GitHub
publication are not inferred from these results. `SOURCE/REVIEW` remains
prohibited; review evidence belongs under the external `REVIEW` layer.
