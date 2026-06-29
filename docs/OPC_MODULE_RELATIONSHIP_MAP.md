# OPC Module Relationship Map

Status: public PREDMET-centered module map for Logos.

Base commit: `90c203947cd781d6bd837647485b10d72f181fe2`

This map classifies modules by relationship to `PREDMET`. It is docs-only and does not authorize implementation changes.

## Module Type Legend

- master
- derivative
- operational
- render/document
- transfer
- finance
- stock
- advisor/guidance
- system/support
- future/access

## MODULE-ID: OPC-MODULE-001

Module name: PREDMET core
Module type: master
Business purpose: central case container, workflow state, and master business truth.
Reads from PREDMET: all PREDMET fields.
Applies rules: creation, save, close, reopen, finish, anonymize, delete, version/log snapshots.
Writes back to PREDMET or related tables: PREDMET row, logs, related-row cleanup.
Outputs: workflow state, review state, source for all derivatives.
Depends on: local DB, session/adviser, settings defaults, IRiU initialization.
Affects: all modules.
Source files: `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/predmeti/presentation/lista_predmeta_screen.dart`.
Tests: `test/lista_predmeta_screen_smoke_test.dart`; related JSON/stock tests.
Current implementation state: `FUNCTIONAL CURRENT PHASE / TEST GAP`.
Known bugs/symptoms: duplicate `brojPredmeta` and full lifecycle runtime parity need audit.
Upgrade risks: redefining PREDMET through document, transfer, Web, or package work.
Safe upgrade options: grouped lifecycle tests and runtime smoke.
Future Web/sync relevance: critical.
Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## MODULE-ID: OPC-MODULE-002

Module name: Preminulo lice
Module type: derivative
Business purpose: deceased-person identity and death facts used by documents, review, JSON, evaluator, and display modules.
Reads from PREDMET: name, surname, JMBG, birth/death facts, address, parents, spouse, profession/title/rank/nickname/display flags.
Applies rules: minimum identity readiness, display flags, anonymization relationships, death facts for evaluator.
Writes back to PREDMET or related tables: PREDMET fields.
Outputs: identity/document/display facts.
Depends on: PREDMET core.
Affects: PDF, PARTA, CITULJE, JSON, evaluator, review.
Source files: `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`; `lib/core/database/tables/predmeti_table.dart`.
Tests: no dedicated full segment test found.
Current implementation state: `SOURCE-CONFIRMED / TEST GAP`.
Known bugs/symptoms: display composition flags need grouped audit.
Upgrade risks: treating person name as system identity.
Safe upgrade options: display-composition regression group.
Future Web/sync relevance: high.
Classification: `SOURCE-CONFIRMED`.

## MODULE-ID: OPC-MODULE-003

Module name: Platilac / legacy narucilac
Module type: finance / derivative
Business purpose: identify payer of goods/services while preserving internal legacy compatibility names.
Reads from PREDMET: `naru*`, `narucilacRefundira`, payer physical/legal fields.
Applies rules: visible `Platilac` display, physical/legal variants, spouse shortcut, refund responsibility.
Writes back to PREDMET or related tables: payer fields and contact rows.
Outputs: payer document/finance/JSON data.
Depends on: Preminulo lice spouse data, FirmaPodaci for representative shortcuts, contacts.
Affects: finance, PDF, JSON, import conflict business meaning.
Source files: `lib/features/predmeti/presentation/segments/narucilac_segment.dart`; `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/pdf/*`; `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`.
Tests: contacts covered in `test/json_transfer_regression_test.dart`; no full payer UI test found.
Current implementation state: `FUNCTIONAL BUT ROUGH`.
Known bugs/symptoms: mixed Platilac/narucilac terminology.
Upgrade risks: breaking database/JSON/template compatibility.
Safe upgrade options: owner-approved terminology compatibility cleanup.
Future Web/sync relevance: high.
Classification: `SOURCE-CONFIRMED / OWNER REVIEW REQUIRED`.

## MODULE-ID: OPC-MODULE-004

Module name: JKP payer/responsibility
Module type: finance / derivative
Business purpose: record whether primary payer also handles JKP and whether JKP pays independently.
Reads from PREDMET: `naruIstiZaJkp`, `jkp*`, `jkpPlacaSamostalno`, `troskoviJkp`.
Applies rules: same-payer copy/clear, JKP independent payment effect.
Writes back to PREDMET or related tables: JKP fields.
Outputs: finance and PDF responsibility display.
Depends on: Platilac module.
Affects: finance totals, documents, JSON.
Source files: `narucilac_segment.dart`; `finansije_segment.dart`; `lista_pdf_data_builder.dart`; `predmeti_table.dart`.
Tests: no dedicated JKP test found.
Current implementation state: `SOURCE-CONFIRMED / TEST GAP`.
Known bugs/symptoms: JKP/Platilac consistency gaps.
Upgrade risks: changing totals or document responsibility by display cleanup.
Safe upgrade options: finance/document consistency test group.
Future Web/sync relevance: medium.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-ID: OPC-MODULE-005

Module name: Ceremony/groblje/grobno mesto/opelo/docek
Module type: derivative / advisor input
Business purpose: capture operational ceremony facts.
Reads from PREDMET: ceremony type/date/time, cemetery, grob, opelo, ispracaj, out-of-country, reception fields.
Applies rules: opelo availability, cremation/cemetery/grob conditions, international/reception conditions.
Writes back to PREDMET or related tables: ceremony fields.
Outputs: document facts, evaluator inputs, review/lifecycle dates.
Depends on: PREDMET core and death facts.
Affects: IRiU, evaluator, PDF, PARTA, review, STANJE ROBE indirectly.
Source files: `ceremonija_segment.dart`; `business_policy_evaluator.dart`; `lista_pdf_data_builder.dart`; `nalog_za_opremanje_pdf_data_builder.dart`.
Tests: `test/business_policy_iriu_critical_scenarios_test.dart` covers policy consequences.
Current implementation state: `SOURCE-CONFIRMED / TEST GAP`.
Known bugs/symptoms: full ceremony guidance missing.
Upgrade risks: invalid service/document consequences.
Safe upgrade options: evaluator/advisor scenario matrix tests.
Future Web/sync relevance: high.
Classification: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED`.

## MODULE-ID: OPC-MODULE-006

Module name: PIO/refund/posmrtna pomoc
Module type: finance / derivative
Business purpose: apply pension/refund context to case finance and documents.
Reads from PREDMET: status, pensioner/refund fields, spouse-right fields, `narucilacRefundira`.
Applies rules: refund visibility/application, payer self-refund effect.
Writes back to PREDMET or related tables: finance/status fields.
Outputs: finance and PDF/refund display.
Depends on: Statusi, Platilac, settings refund amount.
Affects: finance totals, documents, review.
Source files: `preminulo_lice_segment.dart`; `finansije_segment.dart`; `podesavanja_screen.dart`; `lista_pdf_data_builder.dart`; `predmet_pdf_snapshot_export.dart`.
Tests: `test/package_downgrade_migration_test.dart` touches refund fields; no full refund test found.
Current implementation state: `SOURCE-CONFIRMED / TEST GAP`.
Known bugs/symptoms: PIO/refund guidance gap.
Upgrade risks: wrong payable amount or wrong document instruction.
Safe upgrade options: grouped finance/refund rule tests after owner confirmation.
Future Web/sync relevance: medium.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-ID: OPC-MODULE-007

Module name: IRiU / articles / services
Module type: operational / finance
Business purpose: selected goods/services attached to PREDMET.
Reads from PREDMET: case id, death/ceremony/cemetery conditions.
Applies rules: initial rows, managed categories, active/suppressed/recommended state, order, financial truth.
Writes back to PREDMET or related tables: `Iriu` rows and lifecycle decisions.
Outputs: service list, finance inputs, stock consequences, documents.
Depends on: PREDMET, KATALOG, evaluator, IRiU truth rules.
Affects: finance, STANJE ROBE, PDF, JSON, review.
Source files: `iriu_table.dart`; `iriu_repository.dart`; `iriu_segment.dart`; `iriu_truth_rules.dart`; `predmet_iriu_truth_service.dart`.
Tests: `test/business_policy_iriu_critical_scenarios_test.dart`.
Current implementation state: `SOURCE-CONFIRMED / TEST-CONFIRMED`.
Known bugs/symptoms: full category map and finance/document regression gaps.
Upgrade risks: hidden finance/stock/document changes.
Safe upgrade options: scenario tests before rule changes.
Future Web/sync relevance: high.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## MODULE-ID: OPC-MODULE-008

Module name: STANJE ROBE
Module type: stock / operational
Business purpose: inventory consequences from covered IRiU categories.
Reads from PREDMET: case status and selected IRiU rows.
Applies rules: operational availability, apply/restore effects, unresolved consequences.
Writes back to PREDMET or related tables: stock consequence/effect tables.
Outputs: inventory state and unresolved consequence records.
Depends on: IRiU, entitlements/settings, stock repositories.
Affects: close behavior, JSON unresolved consequence transfer, operational warnings.
Source files: `lib/features/stanje_robe/application/*.dart`; `lib/features/stanje_robe/data/*.dart`; stock tables.
Tests: `test/stanje_robe_operational_toggle_test.dart`; `test/json_transfer_regression_test.dart`.
Current implementation state: `PARTIALLY IMPLEMENTED / TEST-CONFIRMED`.
Known bugs/symptoms: import/restore stock policy incomplete.
Upgrade risks: inventory becoming parallel PREDMET truth.
Safe upgrade options: stock consequence audit and tests.
Future Web/sync relevance: high.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## MODULE-ID: OPC-MODULE-009

Module name: Finance/payment
Module type: finance
Business purpose: calculate and display case financial state.
Reads from PREDMET: advance, discount, JKP, payment method/notes, refund fields, payer fields; reads IRiU financial truth.
Applies rules: active positive IRiU rows count; suppressed/non-positive excluded; refund/JKP/advance/discount affect payable display.
Writes back to PREDMET or related tables: finance fields.
Outputs: payment UI and financial PDFs.
Depends on: IRiU, PIO/refund, JKP/Platilac.
Affects: PDF, review, user payment decisions.
Source files: `finansije_segment.dart`; `financial_truth_service.dart`; `lista_pdf_data_builder.dart`; `racun_pdf_export.dart`; `predracun_pdf_export.dart`; `specifikacija_troskova_pdf_export.dart`.
Tests: no dedicated finance regression suite found.
Current implementation state: `SOURCE-CONFIRMED / TEST GAP`.
Known bugs/symptoms: financial consistency gaps.
Upgrade risks: totals changing without tests.
Safe upgrade options: grouped finance regression tests.
Future Web/sync relevance: medium.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-ID: OPC-MODULE-010

Module name: PARTA
Module type: derivative / render/document
Business purpose: public/display composition from PREDMET identity, ceremony, symbol, script, and mourners.
Reads from PREDMET: `simbol`, `pismo`, `parteIme`, `ozaloseni`, identity/display flags, ceremony fields.
Applies rules: display composition and flags.
Writes back to PREDMET or related tables: PARTA display fields on PREDMET.
Outputs: PARTA/document display.
Depends on: Preminulo lice and Ceremony.
Affects: documents and user-visible display.
Source files: `parte_segment.dart`; `predmeti_table.dart`; PDF/document sources.
Tests: no dedicated PARTA tests found.
Current implementation state: `PARTIALLY IMPLEMENTED / TEST GAP`.
Known bugs/symptoms: nickname/title/rank/profession/middle-name display flags; preview/final consistency.
Upgrade risks: changing PREDMET truth to fix display symptom.
Safe upgrade options: display-composition test group.
Future Web/sync relevance: medium.
Classification: `PARTIALLY IMPLEMENTED`.

## MODULE-ID: OPC-MODULE-011

Module name: CITULJE
Module type: derivative / render/document
Business purpose: obituary/document derivative area linked to PREDMET and IRiU categories.
Reads from PREDMET: identity/display/ceremony fields; IRiU categories such as `CITULJA_POLITIKA` and `CITULJA_NOVOSTI`.
Applies rules: document-scoped derivative exclusions; package/add-on visibility may apply.
Writes back to PREDMET or related tables: unclear beyond PREDMET/IRiU fields.
Outputs: obituary-related document/display outputs where implemented.
Depends on: PREDMET, IRiU, entitlements.
Affects: documents and possibly finance/display.
Source files: `iriu_table.dart`; `predmeti_repository.dart`; `opc_entitlement_policy.dart`; `parte_segment.dart`; `iriu_truth_rules.dart`.
Tests: no dedicated CITULJE tests found.
Current implementation state: `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED`.
Known bugs/symptoms: exact workflow not fully extracted.
Upgrade risks: making CITULJE independent truth.
Safe upgrade options: owner-reviewed CITULJE workflow audit.
Future Web/sync relevance: medium.
Classification: `PARTIALLY IMPLEMENTED / TEST GAP`.

## MODULE-ID: OPC-MODULE-012

Module name: PDF/document generation
Module type: render/document
Business purpose: produce PREDMET-derived documents.
Reads from PREDMET: identity, death, payer, JKP, ceremony, opelo, IRiU, finance, firm, adviser, version/status.
Applies rules: document-specific rendering, labels, totals, conditional sections.
Writes back to PREDMET or related tables: no; output action only.
Outputs: PDFs and document snapshots.
Depends on: PREDMET, IRiU, finance, FirmaPodaci, entitlements.
Affects: user documents and business communication.
Source files: `lib/features/predmeti/pdf/*.dart`; document actions in `predmet_screen.dart`.
Tests: no PDF render regression suite found.
Current implementation state: `SOURCE-CONFIRMED / TEST GAP`.
Known bugs/symptoms: preview vs final PDF consistency and terminology mismatch.
Upgrade risks: PDF becoming hidden source of policy truth.
Safe upgrade options: document-render regression tests and terminology review.
Future Web/sync relevance: medium.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-ID: OPC-MODULE-013

Module name: JSON single-PREDMET transfer
Module type: transfer
Business purpose: transfer one PREDMET boundary with approved related rows.
Reads from PREDMET: PREDMET row, IRiU, contacts, metadata, unresolved stock transfer block.
Applies rules: format marker, conflict lookup, keep/replace/cancel, local id preservation on replacement.
Writes back to PREDMET or related tables: imports/replaces PREDMET, IRiU, contacts, related logs/lifecycle as designed.
Outputs: `.json` case transfer file.
Depends on: PREDMET, related repositories.
Affects: identity, related data, continuity.
Source files: `json_export_import.dart`; `predmet_json_transfer_core.dart`; `app_filename_format.dart`.
Tests: `test/json_transfer_regression_test.dart`.
Current implementation state: `SOURCE-CONFIRMED / TEST-CONFIRMED / PARTIALLY IMPLEMENTED`.
Known bugs/symptoms: firm/version/freshness guard gaps.
Upgrade risks: treating filename/export date as authority.
Safe upgrade options: JSON safety design after owner decision.
Future Web/sync relevance: critical.
Classification: `SOURCE-CONFIRMED / OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## MODULE-ID: OPC-MODULE-014

Module name: Backup/restore
Module type: transfer / system/support
Business purpose: broad database backup/recovery.
Reads from PREDMET: broad local database sections.
Applies rules: `OPC_BACKUP` format and destructive confirmation.
Writes back to PREDMET or related tables: broad import/restore.
Outputs: backup JSON.
Depends on: database, repositories, user confirmation.
Affects: entire local data state.
Source files: `json_export_import.dart`; backup policy docs.
Tests: backup/stock safety partly covered by JSON tests.
Current implementation state: `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED`.
Known bugs/symptoms: PIB/MB mismatch guard not implemented/proven.
Upgrade risks: destructive restore across wrong firm.
Safe upgrade options: repository identity guard audit.
Future Web/sync relevance: critical.
Classification: `DOCUMENTED POLICY / POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## MODULE-ID: OPC-MODULE-015

Module name: Pregled i potvrda
Module type: advisor/guidance / lifecycle
Business purpose: final review, saved state, status, version, and lifecycle actions.
Reads from PREDMET: status, version, saved/dirty state, fields from all sections.
Applies rules: save, close, edit/reopen, warnings/readiness.
Writes back to PREDMET or related tables: lifecycle/status/log changes through repository actions.
Outputs: user confirmation point.
Depends on: all workflow sections.
Affects: lifecycle, version, logs, future change-log.
Source files: `predmet_screen.dart`; `predmeti_repository.dart`; `log_izmena_table.dart`.
Tests: partial related tests only.
Current implementation state: `SOURCE-CONFIRMED / IMPLEMENTATION REQUIRED`.
Known bugs/symptoms: version/change-log overview missing.
Upgrade risks: adding dense warnings without owner taxonomy.
Safe upgrade options: review UI suitability audit.
Future Web/sync relevance: high.
Classification: `SOURCE-CONFIRMED / OWNER DECISION`.

## MODULE-ID: OPC-MODULE-016

Module name: Lifecycle/log/version/change-log
Module type: system/support / lifecycle
Business purpose: record status transitions, snapshots, and future business change history.
Reads from PREDMET: current/prior snapshots and lifecycle status.
Applies rules: version starts at 1; close may increment after confirmed business change; export/import carries version.
Writes back to PREDMET or related tables: status, version, logs.
Outputs: status/version/log data.
Depends on: repository lifecycle.
Affects: review, JSON conflict reasoning, future sync.
Source files: `predmeti_repository.dart`; `log_izmena_table.dart`; `json_export_import.dart`; `predmet_pdf_snapshot_export.dart`.
Tests: no full version/change-log test suite found.
Current implementation state: `PARTIALLY IMPLEMENTED / TEST GAP`.
Known bugs/symptoms: change-log visibility gap.
Upgrade risks: treating `exportDatum` or filename as version truth.
Safe upgrade options: version/log audit before implementation.
Future Web/sync relevance: critical.
Classification: `OWNER DECISION / SOURCE-CONFIRMED / IMPLEMENTATION REQUIRED`.

## MODULE-ID: OPC-MODULE-017

Module name: Business policy evaluator
Module type: advisor/guidance
Business purpose: derive condition flags and drive IRiU/finance consequences.
Reads from PREDMET: death place/cause, ceremony type, cemetery/grob, international/reception fields, scenario id.
Applies rules: cremation, hospital, cemetery, override cause, biohazard, international/reception flags.
Writes back to PREDMET or related tables: no direct write; services may plan row consequences.
Outputs: policy snapshot.
Depends on: PREDMET facts and scenario id.
Affects: IRiU, finance, future advisor.
Source files: `business_policy_evaluator.dart`; `business_policy_models.dart`; `business_scenario_id.dart`; `iriu_truth_rules.dart`.
Tests: `test/business_policy_iriu_critical_scenarios_test.dart` indirectly covers consequences.
Current implementation state: `PARTIALLY IMPLEMENTED`.
Known bugs/symptoms: missing complete ceremony guidance.
Upgrade risks: finance/stock/document drift from rule changes.
Safe upgrade options: scenario tests and owner-approved advisor scope.
Future Web/sync relevance: high.
Classification: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED`.

## MODULE-ID: OPC-MODULE-018

Module name: Advisor/guidance future layer
Module type: advisor/guidance
Business purpose: future consolidated guidance, warnings, checklist, and next-action explanation.
Reads from PREDMET: all relevant case facts plus evaluator output.
Applies rules: not yet defined as stable contract.
Writes back to PREDMET or related tables: not implemented.
Outputs: future user-facing guidance.
Depends on: owner decision and evaluator contract.
Affects: review, ceremony, finance, documents, stock.
Source files: no complete source found; related evaluator/review sources.
Tests: none found.
Current implementation state: `POLICY EXISTS / IMPLEMENTATION NOT FOUND`.
Known bugs/symptoms: incomplete ceremony advisor.
Upgrade risks: Codex inventing strategic direction.
Safe upgrade options: owner decision + technical design audit.
Future Web/sync relevance: high.
Classification: `OWNER DECISION REQUIRED / TECHNICAL AUDIT REQUIRED`.

## MODULE-ID: OPC-MODULE-019

Module name: FirmaPodaci
Module type: system/support
Business purpose: firm display/settings data and future identity input.
Reads from PREDMET: not primarily; PREDMET/documents read firm data.
Applies rules: editable singleton-like firm settings.
Writes back to PREDMET or related tables: firm table/settings.
Outputs: firm information for documents/settings.
Depends on: settings repository.
Affects: documents, future identity guards.
Source files: `firma_podaci_table.dart`; `podesavanja_repository.dart`; `podesavanja_screen.dart`.
Tests: settings smoke tests; no identity-history tests.
Current implementation state: `PARTIALLY IMPLEMENTED`.
Known bugs/symptoms: editable/hybrid identity gap.
Upgrade risks: treating editable firm data as stable identity.
Safe upgrade options: firm identity/history audit.
Future Web/sync relevance: critical.
Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## MODULE-ID: OPC-MODULE-020

Module name: Users/advisers/admin roles
Module type: system/support
Business purpose: local user, PIN, role, session, adviser context.
Reads from PREDMET: PREDMET stores adviser/user references.
Applies rules: local admin/adviser roles, active users, sessions, administrator-only controls.
Writes back to PREDMET or related tables: user tables and PREDMET adviser/user fields.
Outputs: authentication/session context.
Depends on: local auth repository/session service.
Affects: PREDMET creation/modification metadata, STANJE ROBE admin controls.
Source files: `korisnici_table.dart`; `auth_repository.dart`; `session_service.dart`; auth screens.
Tests: `test/login_screen_smoke_test.dart`; stock toggle tests touch admin.
Current implementation state: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.
Known bugs/symptoms: stable cross-device role identity missing.
Upgrade risks: implementing firm/license role architecture prematurely.
Safe upgrade options: identity audit before role work.
Future Web/sync relevance: high.
Classification: `SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## MODULE-ID: OPC-MODULE-021

Module name: Packages/licensing
Module type: system/support / future/access
Business purpose: package/add-on/entitlement gating without changing PREDMET truth.
Reads from PREDMET: may control module visibility/actions; does not own case truth.
Applies rules: Osnovni/Srednji/Potpuni, fail-closed entitlements, add-ons.
Writes back to PREDMET or related tables: local license/settings, not PREDMET truth.
Outputs: enabled/disabled features.
Depends on: license parser/repository, entitlement policy.
Affects: documents, STANJE ROBE, settings, future access.
Source files: `opc_entitlement_policy.dart`; `opc_local_license_parser.dart`; `opc_local_license_model.dart`; `opc_local_license_repository.dart`.
Tests: `test/opc_local_license_parser_test.dart`; `test/package_downgrade_migration_test.dart`; `test/podesavanja_screen_smoke_test.dart`.
Current implementation state: `SOURCE-CONFIRMED / TEST-CONFIRMED`.
Known bugs/symptoms: payment/subscription implementation blocked.
Upgrade risks: package gating changing PREDMET truth.
Safe upgrade options: payment/access audit before implementation.
Future Web/sync relevance: high.
Classification: `OWNER DECISION / SOURCE-CONFIRMED`.

## MODULE-ID: OPC-MODULE-022

Module name: Future OPC Web/sync
Module type: future/access
Business purpose: future complementary browser access/runtime and possible sync/mediation support.
Reads from PREDMET: future architecture must preserve PREDMET truth and local ownership.
Applies rules: not implemented; must not assume server-master.
Writes back to PREDMET or related tables: not implemented.
Outputs: future access/runtime only.
Depends on: owner-approved architecture, identity, sync, storage, security, payment gates.
Affects: whole product.
Source files: policy docs only; no Web runner authorized.
Tests: none.
Current implementation state: `DOCUMENTED POLICY / NOT IMPLEMENTED`.
Known bugs/symptoms: architecture risk if misunderstood.
Upgrade risks: server-master database drift, browser-storage data loss, platform divergence.
Safe upgrade options: technical architecture audit only.
Future Web/sync relevance: primary.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.

