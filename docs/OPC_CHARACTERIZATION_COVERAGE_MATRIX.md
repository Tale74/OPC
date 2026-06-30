# OPC Characterization Coverage Matrix

Status: docs-only coverage matrix.

Base commit: `0f82e144a16bd40e1482fd67dd2346233991a623`

This matrix records current evidence levels. It does not authorize implementation or test changes.

## CHARACTERIZATION-ID: OPC-CHAR-001

Business behavior: PREDMET create/open/save/close/reopen/finish/anonymize/delete
Module: PREDMET core
Module class: PREDMET core
Related pseudocode ID: `OPC-PSEUDO-001`, `OPC-PSEUDO-002`, `OPC-PSEUDO-019`, `OPC-PSEUDO-022`
Source files: `predmeti_repository.dart`; `predmet_screen.dart`; `lista_predmeta_screen.dart`; `predmeti_table.dart`
Existing tests: `test/lista_predmeta_screen_smoke_test.dart`; partial related JSON/STANJE ROBE tests
Runtime evidence: not fully current for all lifecycle actions
Documentation evidence: PREDMET workflow atlas; module contracts; domain flow map
Current evidence level: SOURCE-CONFIRMED / TEST GAP / RUNTIME GAP / CHARACTERIZATION REQUIRED
Protected behavior: lifecycle actions must preserve PREDMET as master truth.
What must not change: status/version/log semantics without characterization.
Future upgrade risk: lifecycle drift affects JSON, review, Web/sync, documents.
Characterization needed before change: full lifecycle matrix and parity evidence.
Owner decision required: yes for lifecycle policy changes.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `SOURCE-CONFIRMED / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-002

Business behavior: `brojPredmeta` generation and identity boundary
Module: PREDMET identity
Module class: PREDMET core
Related pseudocode ID: `OPC-PSEUDO-004`, `OPC-PSEUDO-019`, `OPC-PSEUDO-022`, `OPC-PSEUDO-026`
Source files: `predmeti_repository.dart`; `json_export_import.dart`; `predmeti_table.dart`
Existing tests: partial JSON transfer regression
Runtime evidence: not current in this task
Documentation evidence: owner decision report; Web guardrails; module contracts
Current evidence level: OWNER DECISION / SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED
Protected behavior: `brojPredmeta` is not global identity; future-safe identity is firm-scoped.
What must not change: do not use `brojPredmeta` alone as global identity.
Future upgrade risk: wrong-firm conflict or Web/sync collision.
Characterization needed before change: generation, duplicate guard, firm scope.
Owner decision required: yes for identity policy changes.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-003

Business behavior: `verzija` and export metadata
Module: lifecycle/log/version
Module class: core support
Related pseudocode ID: `OPC-PSEUDO-002`, `OPC-PSEUDO-004`, `OPC-PSEUDO-019`, `OPC-PSEUDO-022`, `OPC-PSEUDO-026`
Source files: `predmeti_repository.dart`; `json_export_import.dart`; `app_filename_format.dart`
Existing tests: partial JSON transfer regression
Runtime evidence: not fully current
Documentation evidence: owner decision report; implementation stop-list
Current evidence level: OWNER DECISION / SOURCE-CONFIRMED / TEST GAP / TECHNICAL AUDIT REQUIRED
Protected behavior: `verzija` is business-version signal; `exportDatum` is metadata.
What must not change: filename/export date must not become freshness authority.
Future upgrade risk: unsafe conflict warnings or overwrite decisions.
Characterization needed before change: increment and import/export version matrix.
Owner decision required: yes for conflict policy changes.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `OWNER DECISION / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-004

Business behavior: same-PREDMET import keep/replace/cancel
Module: JSON single-PREDMET transfer
Module class: transfer
Related pseudocode ID: `OPC-PSEUDO-012`, `OPC-PSEUDO-019`, `OPC-PSEUDO-022`
Source files: `json_export_import.dart`; `predmet_json_transfer_core.dart`
Existing tests: `test/json_transfer_regression_test.dart`
Runtime evidence: not current in this task
Documentation evidence: owner decision report; workflow atlas; module contracts
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED / OWNER DECISION
Protected behavior: explicit user choice remains intentional behavior.
What must not change: no silent overwrite or removal of choice without owner decision.
Future upgrade risk: data loss or wrong case replacement.
Characterization needed before change: full conflict UI/version matrix.
Owner decision required: yes for hard blocks.
Technical audit required: yes for parity and identity.
Web readiness relevance: critical.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / OWNER DECISION`.

## CHARACTERIZATION-ID: OPC-CHAR-005

Business behavior: conflict warnings / overwrite guard
Module: JSON transfer / version
Module class: transfer
Related pseudocode ID: `OPC-PSEUDO-004`, `OPC-PSEUDO-012`, `OPC-PSEUDO-019`, `OPC-PSEUDO-026`
Source files: `json_export_import.dart`; `predmet_json_transfer_core.dart`
Existing tests: partial JSON tests
Runtime evidence: not current
Documentation evidence: owner decision report; stop-list
Current evidence level: OWNER-REPORTED BEHAVIOR / TECHNICAL AUDIT REQUIRED / OWNER DECISION REQUIRED
Protected behavior: warning behavior must be characterized before change.
What must not change: no silent overwrite; no `exportDatum` authority.
Future upgrade risk: false freshness decisions.
Characterization needed before change: same/higher/lower/missing/malformed version behavior.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `CHARACTERIZATION REQUIRED / IMPLEMENTATION BLOCKED`.

## CHARACTERIZATION-ID: OPC-CHAR-006

Business behavior: PREDMET change-log / Pregled visibility
Module: Pregled i potvrda / lifecycle
Module class: advisor/guidance / lifecycle
Related pseudocode ID: `OPC-PSEUDO-016`, `OPC-PSEUDO-019`, `OPC-PSEUDO-022`
Source files: `predmet_screen.dart`; `predmeti_repository.dart`; `log_izmena_table.dart`
Existing tests: partial related tests only
Runtime evidence: not current
Documentation evidence: owner decision report; workflow atlas; module contracts
Current evidence level: OWNER DECISION / SOURCE-CONFIRMED / TEST GAP / IMPLEMENTATION REQUIRED
Protected behavior: current review/lifecycle must not be overwritten by uncharacterized overview.
What must not change: version/log meaning.
Future upgrade risk: review becomes misleading conflict authority.
Characterization needed before change: current logs, increments, review suitability.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-007

Business behavior: preminulo lice identity fields
Module: Preminulo lice
Module class: PREDMET-consuming
Related pseudocode ID: `OPC-PSEUDO-010`, `OPC-PSEUDO-018`, `OPC-PSEUDO-022`
Source files: `preminulo_lice_segment.dart`; `predmeti_table.dart`; PDF builders
Existing tests: no dedicated full segment test found
Runtime evidence: not current
Documentation evidence: workflow atlas; module relationship map
Current evidence level: SOURCE-CONFIRMED / TEST GAP
Protected behavior: person facts and display flags feed documents/JSON/display.
What must not change: person name must not become global identity.
Future upgrade risk: display or filename identity drift.
Characterization needed before change: field/display matrix.
Owner decision required: yes for display policy changes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## CHARACTERIZATION-ID: OPC-CHAR-008

Business behavior: Platilac / JKP responsibility
Module: Platilac and JKP
Module class: finance / PREDMET-consuming
Related pseudocode ID: `OPC-PSEUDO-009`, `OPC-PSEUDO-012`, `OPC-PSEUDO-018`, `OPC-PSEUDO-022`
Source files: `narucilac_segment.dart`; `finansije_segment.dart`; PDF builders
Existing tests: JSON contacts partial coverage; no full payer/JKP tests found
Runtime evidence: not current
Documentation evidence: owner decision report; terminology lineage; module contracts
Current evidence level: SOURCE-CONFIRMED / FUNCTIONAL BUT ROUGH / TEST GAP
Protected behavior: payer responsibility and legacy compatibility.
What must not change: no global rename without compatibility plan.
Future upgrade risk: wrong payer or document responsibility.
Characterization needed before change: legal/physical/same/separate/self-pay cases.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-009

Business behavior: PIO/refund/posmrtna pomoc
Module: PIO/refund
Module class: finance / PREDMET-consuming
Related pseudocode ID: `OPC-PSEUDO-009`, `OPC-PSEUDO-016`, `OPC-PSEUDO-022`
Source files: `preminulo_lice_segment.dart`; `finansije_segment.dart`; `podesavanja_screen.dart`; PDF builders
Existing tests: `test/package_downgrade_migration_test.dart` touches refund fields; no full refund test
Runtime evidence: not current
Documentation evidence: module relationship map; grouped safe upgrade plan
Current evidence level: SOURCE-CONFIRMED / TEST GAP / OWNER DECISION REQUIRED
Protected behavior: refund affects finance/PDF and guidance.
What must not change: no automatic guidance without owner policy.
Future upgrade risk: wrong payable/refund instruction.
Characterization needed before change: pensioner/spouse/self-refund cases.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## CHARACTERIZATION-ID: OPC-CHAR-010

Business behavior: ceremony/groblje/grobno mesto/opelo/docek
Module: Ceremony
Module class: PREDMET-consuming
Related pseudocode ID: `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-022`
Source files: `ceremonija_segment.dart`; `business_policy_evaluator.dart`; PDF data builders
Existing tests: `test/business_policy_iriu_critical_scenarios_test.dart` partially covers consequences
Runtime evidence: not current
Documentation evidence: evaluator audit; workflow atlas
Current evidence level: SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED / TEST GAP
Protected behavior: ceremony facts feed evaluator/documents/review.
What must not change: opelo/ceremony policy without characterization.
Future upgrade risk: wrong IRiU/document consequences.
Characterization needed before change: ceremony scenario matrix.
Owner decision required: yes for guidance policy.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-011

Business behavior: business policy evaluator snapshot
Module: Business policy evaluator
Module class: advisor/guidance
Related pseudocode ID: `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-023`
Source files: `business_policy_evaluator.dart`; `business_policy_models.dart`; `business_scenario_id.dart`
Existing tests: `test/business_policy_iriu_critical_scenarios_test.dart`
Runtime evidence: not current
Documentation evidence: evaluator deep audit; scenario matrix; consequence graph
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED / PARTIALLY IMPLEMENTED
Protected behavior: deterministic snapshot from PREDMET facts.
What must not change: evaluator output semantics without scenario evidence.
Future upgrade risk: finance/IRiU/document drift.
Characterization needed before change: affected scenarios and outputs.
Owner decision required: yes for new policy.
Technical audit required: yes for gaps.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## CHARACTERIZATION-ID: OPC-CHAR-012

Business behavior: business scenario id
Module: Business policy/scenario
Module class: core support
Related pseudocode ID: `OPC-PSEUDO-005`, `OPC-PSEUDO-023`
Source files: `business_scenario_id.dart`; `predmeti_table.dart`; repository metadata
Existing tests: partial policy/IRiU tests
Runtime evidence: not current
Documentation evidence: business logic inventory; legacy locked rules
Current evidence level: SOURCE-CONFIRMED / TEST GAP
Protected behavior: PREDMET stores scenario identity.
What must not change: scenario id meaning without policy decision.
Future upgrade risk: wrong evaluator baseline.
Characterization needed before change: scenario persistence and outputs.
Owner decision required: yes for scenario additions.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## CHARACTERIZATION-ID: OPC-CHAR-013

Business behavior: IRiU active/suppressed/recommended/confirmed/dismissed
Module: IRiU
Module class: operational / finance
Related pseudocode ID: `OPC-PSEUDO-006`, `OPC-PSEUDO-007`, `OPC-PSEUDO-023`
Source files: `iriu_table.dart`; `iriu_repository.dart`; `iriu_truth_rules.dart`; `predmet_iriu_truth_service.dart`
Existing tests: `test/business_policy_iriu_critical_scenarios_test.dart`
Runtime evidence: not current
Documentation evidence: module relationship map; pseudocode map
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED
Protected behavior: managed states and user decisions must be preserved.
What must not change: dismissed/confirmed decisions without characterization.
Future upgrade risk: hidden finance/stock/document changes.
Characterization needed before change: full category state matrix.
Owner decision required: yes for rule changes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## CHARACTERIZATION-ID: OPC-CHAR-014

Business behavior: grob/grobnica / cremation / limeni ulozak / lemovanje
Module: evaluator / IRiU
Module class: advisor/guidance / operational
Related pseudocode ID: `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-023`
Source files: evaluator and IRiU truth service files
Existing tests: `test/business_policy_iriu_critical_scenarios_test.dart`
Runtime evidence: not current
Documentation evidence: evaluator scenario docs
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED
Protected behavior: critical consequence rules.
What must not change: required/suppressed categories without tests.
Future upgrade risk: wrong service rows and totals.
Characterization needed before change: downstream finance/PDF/stock effects.
Owner decision required: yes for policy changes.
Technical audit required: yes for downstream gaps.
Web readiness relevance: high.
Classification: `TEST-CONFIRMED / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-015

Business behavior: infectious/biohazard / override cause handling
Module: evaluator / IRiU
Module class: advisor/guidance / operational
Related pseudocode ID: `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-023`
Source files: `business_policy_evaluator.dart`; `iriu_truth_rules.dart`
Existing tests: `test/business_policy_iriu_critical_scenarios_test.dart`
Runtime evidence: not current
Documentation evidence: evaluator deep audit
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED
Protected behavior: biohazard and override conditions.
What must not change: safety-related policy without characterization.
Future upgrade risk: missed operational precautions.
Characterization needed before change: evaluator and visible guidance outputs.
Owner decision required: yes for guidance text.
Technical audit required: yes.
Web readiness relevance: medium/high.
Classification: `TEST-CONFIRMED / OWNER DECISION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-016

Business behavior: STANJE ROBE stock consequence logic
Module: STANJE ROBE
Module class: stock / operational
Related pseudocode ID: `OPC-PSEUDO-008`, `OPC-PSEUDO-023`, `OPC-PSEUDO-026`
Source files: `features/stanje_robe/application/*`; stock repositories/tables
Existing tests: `test/stanje_robe_operational_toggle_test.dart`; `test/json_transfer_regression_test.dart`
Runtime evidence: legacy runtime evidence recorded for selected flows
Documentation evidence: module relationship map; legacy audit summaries
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED / RUNTIME-CONFIRMED / TECHNICAL AUDIT REQUIRED
Protected behavior: operational consequences remain bounded.
What must not change: no parallel PREDMET/KATALOG truth.
Future upgrade risk: inventory data loss or double effects.
Characterization needed before change: transfer/restore/sync and full visibility flows.
Owner decision required: yes for UX policy.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-017

Business behavior: finance/payment truth
Module: Finance/payment
Module class: finance
Related pseudocode ID: `OPC-PSEUDO-009`, `OPC-PSEUDO-024`
Source files: `finansije_segment.dart`; `financial_truth_service.dart`; PDF builders
Existing tests: no dedicated full finance suite found
Runtime evidence: not current
Documentation evidence: module relationship map; business rule inventory
Current evidence level: SOURCE-CONFIRMED / TEST GAP / CHARACTERIZATION REQUIRED
Protected behavior: totals derive from PREDMET and IRiU.
What must not change: totals, refund, JKP, advance, discount behavior.
Future upgrade risk: wrong payable amount.
Characterization needed before change: finance matrix.
Owner decision required: yes for edge cases.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## CHARACTERIZATION-ID: OPC-CHAR-018

Business behavior: PARTA display composition including nadimak flags
Module: PARTA
Module class: derivative/render
Related pseudocode ID: `OPC-PSEUDO-010`, `OPC-PSEUDO-024`
Source files: `parte_segment.dart`; `predmeti_table.dart`; PDF/document sources
Existing tests: no dedicated PARTA tests found
Runtime evidence: not current
Documentation evidence: module contracts; grouped safe upgrade plan
Current evidence level: PARTIALLY IMPLEMENTED / TEST GAP / OWNER DECISION REQUIRED
Protected behavior: display remains derivative of PREDMET.
What must not change: identity truth to fix display.
Future upgrade risk: public-facing inconsistency.
Characterization needed before change: flag/output matrix.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `PARTIALLY IMPLEMENTED / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-019

Business behavior: CITULJE display composition
Module: CITULJE
Module class: derivative/render / add-on
Related pseudocode ID: `OPC-PSEUDO-010`, `OPC-PSEUDO-011`, `OPC-PSEUDO-024`
Source files: `iriu_table.dart`; `parte_segment.dart`; `iriu_truth_rules.dart`; entitlement policy
Existing tests: no dedicated CITULJE tests found
Runtime evidence: not current
Documentation evidence: module contracts; legacy package rules
Current evidence level: PARTIALLY IMPLEMENTED / TEST GAP / TECHNICAL AUDIT REQUIRED
Protected behavior: CITULJE remains derivative/add-on output.
What must not change: do not create independent obituary truth.
Future upgrade risk: display/product boundary drift.
Characterization needed before change: workflow and output contract.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-020

Business behavior: PDF/document generation derivation
Module: PDF/document generation
Module class: derivative/render
Related pseudocode ID: `OPC-PSEUDO-011`, `OPC-PSEUDO-024`
Source files: `lib/features/predmeti/pdf/*.dart`; document actions in `predmet_screen.dart`
Existing tests: no PDF render regression suite found
Runtime evidence: not current
Documentation evidence: business rule inventory; module contracts
Current evidence level: SOURCE-CONFIRMED / TEST GAP
Protected behavior: PDFs render PREDMET-derived data.
What must not change: PDF must not become policy source.
Future upgrade risk: output drift.
Characterization needed before change: PDF data contract and render checks.
Owner decision required: yes for product packaging/labels.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## CHARACTERIZATION-ID: OPC-CHAR-021

Business behavior: JSON export/import schema/version
Module: JSON transfer
Module class: transfer
Related pseudocode ID: `OPC-PSEUDO-012`, `OPC-PSEUDO-013`, `OPC-PSEUDO-025`
Source files: `json_export_import.dart`; `predmet_json_transfer_core.dart`; `app_filename_format.dart`
Existing tests: `test/json_transfer_regression_test.dart`
Runtime evidence: not current
Documentation evidence: workflow atlas; owner decisions; module contracts
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED
Protected behavior: JSON is transfer layer, not master truth.
What must not change: schema/identity/freshness behavior without characterization.
Future upgrade risk: transfer incompatibility or wrong conflict handling.
Characterization needed before change: schema/version/freshness/firm identity.
Owner decision required: yes for conflict policy.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `TEST-CONFIRMED / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-022

Business behavior: backup/restore safety behavior
Module: Backup/restore
Module class: transfer / support
Related pseudocode ID: `OPC-PSEUDO-013`, `OPC-PSEUDO-025`, `OPC-PSEUDO-026`
Source files: `json_export_import.dart`; backup docs
Existing tests: partial JSON/stock safety tests
Runtime evidence: not current
Documentation evidence: backup public summary; stop-list; owner decisions
Current evidence level: DOCUMENTED POLICY / POLICY EXISTS / IMPLEMENTATION NOT FOUND / TECHNICAL AUDIT REQUIRED
Protected behavior: broad restore must be safe and explicit.
What must not change: no wrong-firm destructive restore.
Future upgrade risk: data loss.
Characterization needed before change: PIB/MB guard and destructive restore flows.
Owner decision required: yes for exceptions.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `TECHNICAL AUDIT REQUIRED / IMPLEMENTATION BLOCKED`.

## CHARACTERIZATION-ID: OPC-CHAR-023

Business behavior: FirmaPodaci
Module: FirmaPodaci
Module class: support/access
Related pseudocode ID: `OPC-PSEUDO-013`, `OPC-PSEUDO-026`
Source files: `firma_podaci_table.dart`; `podesavanja_repository.dart`; `podesavanja_screen.dart`
Existing tests: settings smoke tests; no identity-history tests found
Runtime evidence: not current
Documentation evidence: owner decisions; module contracts
Current evidence level: PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED
Protected behavior: firm display/settings data must not be mistaken for immutable identity.
What must not change: no Web/sync identity from mutable fields alone.
Future upgrade risk: wrong-firm transfer/sync.
Characterization needed before change: identity/history model.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-024

Business behavior: user/auth/recovery
Module: Users/auth/recovery
Module class: support/access
Related pseudocode ID: `OPC-PSEUDO-015`, `OPC-PSEUDO-026`
Source files: `korisnici_table.dart`; `auth_repository.dart`; `session_service.dart`; auth screens
Existing tests: `test/login_screen_smoke_test.dart`; settings smoke tests
Runtime evidence: not current
Documentation evidence: module contracts; business rule inventory
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED
Protected behavior: local login/session/recovery.
What must not change: auth must not mutate PREDMET truth.
Future upgrade risk: role/access identity drift.
Characterization needed before change: cross-device identity and recovery.
Owner decision required: yes for Web roles.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## CHARACTERIZATION-ID: OPC-CHAR-025

Business behavior: advisers/admin roles
Module: Users/advisers/admin roles
Module class: support/access
Related pseudocode ID: `OPC-PSEUDO-015`, `OPC-PSEUDO-026`
Source files: auth/session/user sources; STANJE ROBE admin controls
Existing tests: login/settings/STANJE ROBE tests partially touch roles
Runtime evidence: legacy runtime evidence for STANJE ROBE admin flows
Documentation evidence: module contracts; legacy architecture rules
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED / RUNTIME-CONFIRMED / TECHNICAL AUDIT REQUIRED
Protected behavior: admin/adviser separation and no SAVETNIK stock controls where forbidden.
What must not change: roles must not become license/payment truth.
Future upgrade risk: access control drift.
Characterization needed before change: role matrix and Web identity.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-026

Business behavior: entitlement/packages/licensing
Module: entitlement/packages/licensing
Module class: add-on/package / support/access
Related pseudocode ID: `OPC-PSEUDO-014`, `OPC-PSEUDO-026`
Source files: `opc_entitlement_policy.dart`; local license parser/model/repository
Existing tests: `test/opc_local_license_parser_test.dart`; `test/package_downgrade_migration_test.dart`; `test/podesavanja_screen_smoke_test.dart`
Runtime evidence: not current
Documentation evidence: owner decisions; module contracts
Current evidence level: SOURCE-CONFIRMED / TEST-CONFIRMED / IMPLEMENTATION BLOCKED
Protected behavior: package gates availability, not PREDMET truth.
What must not change: no data deletion or truth mutation from package state.
Future upgrade risk: over-unlock or commercial/access drift.
Characterization needed before change: payment/access and role interactions.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / IMPLEMENTATION BLOCKED`.

## CHARACTERIZATION-ID: OPC-CHAR-027

Business behavior: KATALOG
Module: KATALOG
Module class: core support
Related pseudocode ID: `OPC-PSEUDO-006`, `OPC-PSEUDO-008`, `OPC-PSEUDO-026`
Source files: KATALOG table/repository/screen sources cited in legacy docs
Existing tests: package/STANJE ROBE/JSON tests partly cover KATALOG-linked behavior
Runtime evidence: legacy KATALOG/STANJE ROBE runtime notes
Documentation evidence: legacy architecture decisions; module contracts
Current evidence level: SOURCE-CONFIRMED / RUNTIME-CONFIRMED / CHARACTERIZATION REQUIRED
Protected behavior: KATALOG is catalog article truth; `stableArticleId` is binding seam.
What must not change: no guessed relinking or retroactive IRiU snapshot overwrite.
Future upgrade risk: stock/IRiU identity drift.
Characterization needed before change: catalog identity and transfer behavior.
Owner decision required: yes for identity policy changes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-028

Business behavior: PODSETNIK
Module: PODSETNIK
Module class: operational / add-on
Related pseudocode ID: `OPC-PSEUDO-018`, `OPC-PSEUDO-026`
Source files: not fully characterized in current public docs
Existing tests: none found
Runtime evidence: none current
Documentation evidence: legacy package/add-on rules; module contracts
Current evidence level: POLICY EXISTS / IMPLEMENTATION NOT FOUND / NOT IMPLEMENTED
Protected behavior: reminder UX must remain derivative/operational if implemented.
What must not change: no hidden PREDMET truth or OS notification architecture without audit.
Future upgrade risk: platform/runtime drift.
Characterization needed before change: implementation status and notification architecture.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## CHARACTERIZATION-ID: OPC-CHAR-029

Business behavior: NALOG CVECARI
Module: NALOG CVECARI
Module class: derivative/render / add-on
Related pseudocode ID: `OPC-PSEUDO-011`, `OPC-PSEUDO-024`
Source files: PDF/document sources if implemented; not standalone operational module
Existing tests: no dedicated tests found
Runtime evidence: not current
Documentation evidence: legacy package/add-on rules; module contracts
Current evidence level: DOCUMENTED POLICY / TEST GAP
Protected behavior: document/PDF export item only.
What must not change: no standalone operational truth.
Future upgrade risk: document output becomes module truth.
Characterization needed before change: document data contract.
Owner decision required: yes for packaging/output.
Technical audit required: yes.
Web readiness relevance: low/medium.
Classification: `DOCUMENTED POLICY / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-030

Business behavior: Windows/Android parity
Module: platform parity
Module class: support/access
Related pseudocode ID: `OPC-PSEUDO-022`, `OPC-PSEUDO-026`
Source files: shared Dart source plus platform folders
Existing tests: no current full platform parity suite
Runtime evidence: legacy selected runtime notes only
Documentation evidence: manifest; domain flow map; control plan
Current evidence level: RUNTIME GAP / TECHNICAL AUDIT REQUIRED
Protected behavior: shared business truth across platforms.
What must not change: no platform-specific business truth divergence.
Future upgrade risk: Windows/Android workflow drift.
Characterization needed before change: fixed parity scenarios.
Owner decision required: only for intentional differences.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `RUNTIME GAP / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-ID: OPC-CHAR-031

Business behavior: future Web/sync identity and conflict readiness
Module: Future OPC Web/sync
Module class: future/Web seam
Related pseudocode ID: `OPC-PSEUDO-021`, `OPC-PSEUDO-026`
Source files: policy docs only; no Web runner authorized
Existing tests: none
Runtime evidence: none
Documentation evidence: Web guardrails; owner decision report; stop-list
Current evidence level: DOCUMENTED POLICY / NOT IMPLEMENTED / IMPLEMENTATION BLOCKED
Protected behavior: Web must preserve PREDMET truth, firm ownership, and explicit conflict choices.
What must not change: no server-master assumption or premature sync.
Future upgrade risk: identity collision, data loss, parallel truth.
Characterization needed before change: identity, conflict, storage, role, access audit.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: primary.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.
