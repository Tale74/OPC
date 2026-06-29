# OPC Source Learning Index For Logos

Status: ordered source/docs/test reading plan for Logos.

Base commit: `90c203947cd781d6bd837647485b10d72f181fe2`

This file teaches Logos what to read first, why, and what to learn. It is docs-only.

## LEARNING-STEP-001

Read:
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/GIT_WORKFLOW_ARC.md`

Purpose: learn the non-negotiable OPC boundaries.
What Logos must learn: PREDMET is master truth; firma owns database; Windows/Android parity; future Web is complementary; implementation gates.
Key concepts: PREDMET, firm ownership, local-first transfer, OPC Web, protected terminology.
Do not confuse with: implementation permission.
Related modules: all modules.
Questions to answer after reading: What must never become master truth? Which work is blocked?
Evidence strength: `DOCUMENTED POLICY / OWNER DECISION`.

## LEARNING-STEP-002

Read:
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md`
- `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`

Purpose: learn the current product map and open audit queue.
What Logos must learn: what exists, what is partial, what is blocked, and which gaps are owner/technical/test/runtime gaps.
Key concepts: functional current phase, partial implementation, policy-only, test gap.
Do not confuse with: next strategic task selection.
Related modules: all modules.
Questions to answer after reading: Which gaps are technical, which are owner decisions, and which are safe grouped upgrade candidates?
Evidence strength: `DOCUMENTED POLICY / SOURCE-CONFIRMED / TEST GAP`.

## LEARNING-STEP-003

Read:
- `lib/core/database/tables/predmeti_table.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/core/database/database.dart`
- `lib/core/database/tables/log_izmena_table.dart`

Purpose: learn PREDMET storage and lifecycle.
What Logos must learn: fields, status, version, creation, save, close, reopen, delete, anonymize, logs.
Key concepts: local technical id, `brojPredmeta`, `verzija`, snapshots, status.
Do not confuse with: firm-scoped identity policy, which is not fully implemented.
Related modules: PREDMET core, lifecycle/log/version, JSON, review.
Questions to answer after reading: Which fields are business truth, and which are local technical support?
Evidence strength: `SOURCE-CONFIRMED`.

## LEARNING-STEP-004

Read:
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`
- `lib/features/predmeti/presentation/segments/narucilac_segment.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/presentation/segments/parte_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/presentation/segments/finansije_segment.dart`

Purpose: learn the PREDMET user workflow.
What Logos must learn: actual UI points, section readiness, user choices, and dependencies.
Key concepts: Preminulo lice, Cinjenice o smrti, Statusi, Platilac, Ceremonija, Parte, Roba i usluge, Finansije, Dokumenti, Pregled i potvrda.
Do not confuse with: source-code permission to change UI.
Related modules: all PREDMET workflow modules.
Questions to answer after reading: Which fields drive later outputs?
Evidence strength: `SOURCE-CONFIRMED / RUNTIME GAP`.

## LEARNING-STEP-005

Read:
- `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`
- `docs/OPC_PREDMET_DEPENDENCY_MAP.md`
- `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md`

Purpose: learn PREDMET as product workflow, not just code.
What Logos must learn: how each user point feeds documents, JSON, IRiU, finance, stock, and review.
Key concepts: workflow point, dependency, completion state.
Do not confuse with: implementation spec.
Related modules: all PREDMET-derived modules.
Questions to answer after reading: Which modules derive from each workflow point?
Evidence strength: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## LEARNING-STEP-006

Read:
- `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart`
- `lib/features/predmeti/core_v2/business_policy/business_policy_models.dart`
- `lib/features/predmeti/core_v2/business_policy/business_scenario_id.dart`
- `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`
- `docs/OPC_BUSINESS_POLICY_SCENARIO_MATRIX.md`
- `docs/OPC_BUSINESS_POLICY_CONSEQUENCE_GRAPH.md`
- `docs/OPC_BUSINESS_POLICY_EVALUATOR_COMPLETION_MATRIX.md`

Purpose: learn evaluator scope and limits.
What Logos must learn: evaluator is a partial policy kernel, not a full advisor.
Key concepts: default scenario, condition flags, biohazard precondition, partial advisor.
Do not confuse with: complete ceremony guidance.
Related modules: evaluator, IRiU, finance, advisor, review.
Questions to answer after reading: What does evaluator output today, and what does it not output?
Evidence strength: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED`.

## LEARNING-STEP-007

Read:
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart`
- `lib/features/predmeti/core_v2/services/mesto_smrti_iriu_lifecycle_service.dart`
- `lib/features/predmeti/core_v2/services/blok2_iriu_lifecycle_service.dart`
- `lib/features/predmeti/core_v2/services/financial_truth_service.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/core/database/tables/iriu_table.dart`
- `test/business_policy_iriu_critical_scenarios_test.dart`

Purpose: learn IRiU truth rules.
What Logos must learn: active/suppressed/recommended categories, user resolution, financial inclusion, derivative exclusions.
Key concepts: managed category, operational state, recommendation, financial truth, biohazard.
Do not confuse with: catalog master truth.
Related modules: IRiU, evaluator, finance, STANJE ROBE.
Questions to answer after reading: Which PREDMET facts cause service consequences?
Evidence strength: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## LEARNING-STEP-008

Read:
- `lib/features/stanje_robe/application/stanje_robe_lifecycle_service.dart`
- `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`
- `lib/features/stanje_robe/data/stanje_robe_repository.dart`
- `lib/features/stanje_robe/data/stanje_robe_posledice_repository.dart`
- `lib/features/stanje_robe/data/stanje_robe_effects_repository.dart`
- `test/stanje_robe_operational_toggle_test.dart`

Purpose: learn stock consequence logic.
What Logos must learn: STANJE ROBE is operational consequence, not case truth.
Key concepts: operational availability, apply/restore, unresolved consequence, covered categories.
Do not confuse with: PREDMET truth or JSON warehouse transfer.
Related modules: IRiU, JSON, review, packages/licensing.
Questions to answer after reading: When does stock write a consequence, and when is it blocked?
Evidence strength: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## LEARNING-STEP-009

Read:
- `lib/features/predmeti/presentation/segments/finansije_segment.dart`
- `lib/features/predmeti/core_v2/services/financial_truth_service.dart`
- `lib/features/predmeti/pdf/lista_pdf_data_builder.dart`
- `lib/features/predmeti/pdf/racun_pdf_export.dart`
- `lib/features/predmeti/pdf/predracun_pdf_export.dart`
- `lib/features/predmeti/pdf/specifikacija_troskova_pdf_export.dart`

Purpose: learn finance/payment logic.
What Logos must learn: IRiU truth, PIO/refund, JKP, advance, discount, and payment fields combine into displayed finance.
Key concepts: `ROBA I USLUGE`, refund, JKP independent payment, active positive rows.
Do not confuse with: standalone accounting system.
Related modules: finance, IRiU, PIO/refund, JKP, PDF.
Questions to answer after reading: Which values reduce or exclude payable amount?
Evidence strength: `SOURCE-CONFIRMED / TEST GAP`.

## LEARNING-STEP-010

Read:
- `lib/features/predmeti/presentation/segments/parte_segment.dart`
- `lib/core/database/tables/predmeti_table.dart`
- `lib/core/constants/iriu_constants.dart`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`

Purpose: learn PARTA/CITULJE/document display composition.
What Logos must learn: display flags and document-scoped categories are derivatives of PREDMET/IRiU.
Key concepts: symbol, script, display name, mourners, CITULJE categories.
Do not confuse with: independent source of truth.
Related modules: PARTA, CITULJE, PDF, IRiU.
Questions to answer after reading: Which display flags belong to PREDMET, and which output is derivative?
Evidence strength: `SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## LEARNING-STEP-011

Read:
- `lib/features/predmeti/pdf/lista_pdf_data_builder.dart`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_data_builder.dart`
- `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart`
- `lib/features/predmeti/pdf/lista_pdf_export.dart`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_export.dart`
- `lib/features/predmeti/pdf/racun_pdf_export.dart`

Purpose: learn PDF generation.
What Logos must learn: PDFs are rendered derivatives from PREDMET, IRiU, finance, FirmaPodaci, and adviser data.
Key concepts: document derivative, terminology labels, preview/final consistency.
Do not confuse with: policy source of truth.
Related modules: PDF, finance, PREDMET, Platilac, PARTA.
Questions to answer after reading: Which rules are rendered only in PDFs and should be moved to documented policy?
Evidence strength: `SOURCE-CONFIRMED / TEST GAP`.

## LEARNING-STEP-012

Read:
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/core/format/app_filename_format.dart`
- `test/json_transfer_regression_test.dart`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`

Purpose: learn single-PREDMET JSON and backup/restore boundaries.
What Logos must learn: single-PREDMET JSON is case transfer; full backup is broader recovery; filename/export date are not identity/freshness authority.
Key concepts: `OPC_PREDMET`, `OPC_BACKUP`, keep/replace/cancel, replacement keeps local id, firm identity guard gap.
Do not confuse with: Web/sync architecture.
Related modules: JSON, backup/restore, PREDMET identity, STANJE ROBE.
Questions to answer after reading: What is transferred, what is not transferred, and what guard is missing?
Evidence strength: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## LEARNING-STEP-013

Read:
- `lib/core/database/tables/firma_podaci_table.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/features/podesavanja/presentation/podesavanja_screen.dart`
- `docs/OPC_OWNER_DECISION_REPORT.md`

Purpose: learn FirmaPodaci.
What Logos must learn: firm data exists and is important but editable/hybrid; stable identity history is missing.
Key concepts: PIB, Maticni broj, editable firm data, history requirement.
Do not confuse with: implemented repository identity guard.
Related modules: FirmaPodaci, backup/restore, JSON, Web/sync, documents.
Questions to answer after reading: Which firm fields can be used for display, and which require history before identity guard?
Evidence strength: `SOURCE-CONFIRMED / OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## LEARNING-STEP-014

Read:
- `lib/core/database/tables/korisnici_table.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/domain/session_service.dart`
- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/auth/presentation/korisnici_screen.dart`
- `test/login_screen_smoke_test.dart`

Purpose: learn users/advisers/roles.
What Logos must learn: local roles exist; future stable firm/license role identity needs audit.
Key concepts: Administrator, Savetnik, session, PIN, adviser metadata.
Do not confuse with: future Web/license identity.
Related modules: roles, PREDMET metadata, STANJE ROBE admin, licensing.
Questions to answer after reading: Which role behavior is local today, and which future identity is missing?
Evidence strength: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## LEARNING-STEP-015

Read:
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/core/entitlements/opc_local_license_parser.dart`
- `lib/core/entitlements/opc_local_license_model.dart`
- `lib/core/entitlements/opc_local_license_repository.dart`
- `test/opc_local_license_parser_test.dart`
- `test/package_downgrade_migration_test.dart`
- `test/podesavanja_screen_smoke_test.dart`

Purpose: learn packages/licensing.
What Logos must learn: packages gate modules/actions but must not change PREDMET truth.
Key concepts: Osnovni, Srednji, Potpuni, fail closed, add-ons, internal `saas` cleanup candidate.
Do not confuse with: implemented payment/subscription system.
Related modules: packages/licensing, STANJE ROBE, documents, future Web/access.
Questions to answer after reading: Which features are gated and which implementation is blocked?
Evidence strength: `OWNER DECISION / SOURCE-CONFIRMED / TEST-CONFIRMED`.

## LEARNING-STEP-016

Read:
- `test/business_policy_iriu_critical_scenarios_test.dart`
- `test/json_transfer_regression_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/opc_local_license_parser_test.dart`
- `test/package_downgrade_migration_test.dart`
- `test/login_screen_smoke_test.dart`
- `test/podesavanja_screen_smoke_test.dart`
- `test/lista_predmeta_screen_smoke_test.dart`

Purpose: learn what is test-confirmed and what is not.
What Logos must learn: tests are concentrated around JSON, IRiU, STANJE ROBE, license, migration, and smoke; finance/PDF/PARTA/full workflow have gaps.
Key concepts: test-confirmed vs test gap.
Do not confuse with: runtime parity confirmation.
Related modules: all.
Questions to answer after reading: Which business rules are protected by tests before upgrade work?
Evidence strength: `TEST-CONFIRMED / TEST GAP`.

## LEARNING-STEP-017

Read:
- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`

Purpose: learn business-critical source behavior through short pseudocode before reading implementation details.
What Logos must learn: trigger, inputs, decisions, outputs, side effects, boundaries, tests, gaps, and safe grouped upgrade findings for core OPC behavior.
Key concepts: source-faithful pseudocode, source remains implementation truth, grouped characterization before implementation.
Do not confuse with: source-code replacement or implementation authorization.
Related modules: all business-critical modules.
Questions to answer after reading: Which behavior needs characterization tests before any safe upgrade?
Evidence strength: `SOURCE-CONFIRMED / DOCUMENTED POLICY / TEST GAP`.
