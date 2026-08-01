# OPC Pseudocode Index For Logos

Status: public index from source files to pseudocode learning sections.

Base commit: `78f88228bb55526ae7c168c2aac0140ec3cb620c`

## INDEX-ID: OPC-PSEUDO-INDEX-001

Source file: `lib/features/predmeti/data/predmeti_repository.dart`
Related pseudocode sections: `OPC-PSEUDO-001`, `OPC-PSEUDO-002`, `OPC-PSEUDO-003`, `OPC-PSEUDO-016`
Business meaning: PREDMET lifecycle, version, snapshots, delete/reconcile, anonymize/finish decisions.
Module: PREDMET core / lifecycle
Truth boundary: owns PREDMET persistence but not future firm identity policy by itself.
Why Logos must know it: most modules depend on repository lifecycle semantics.
Risk if misunderstood: version or delete behavior may be changed without protecting related rows.
Read before: `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`
Read after: `lib/core/utils/json_export_import.dart`

## INDEX-ID: OPC-PSEUDO-INDEX-002

Source file: `lib/core/database/tables/predmeti_table.dart`
Related pseudocode sections: `OPC-PSEUDO-001`, `OPC-PSEUDO-004`, `OPC-PSEUDO-010`
Business meaning: field surface for PREDMET identity, metadata, person, ceremony, finance, PARTA, JSON.
Module: PREDMET core
Truth boundary: table stores case truth; not all fields are globally authoritative.
Why Logos must know it: it reveals which modules read PREDMET facts.
Risk if misunderstood: local id or filename-related fields may be promoted to business identity.
Read before: manifest and owner decision docs.
Read after: repository and UI segments.

## INDEX-ID: OPC-PSEUDO-INDEX-003

Source file: `lib/features/predmeti/presentation/predmet_screen.dart`
Related pseudocode sections: `OPC-PSEUDO-003`, `OPC-PSEUDO-011`, `OPC-PSEUDO-016`
Business meaning: PREDMET workflow shell, document actions, review actions.
Module: PREDMET UI / review
Truth boundary: UI reads/writes via PREDMET; it is not separate truth.
Why Logos must know it: shows user-facing orchestration points.
Risk if misunderstood: review UI may be overloaded with strategy instead of derivative guidance.
Read before: workflow atlas.
Read after: segment files and repository.

## INDEX-ID: OPC-PSEUDO-INDEX-004

Source file: `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart`
Related pseudocode sections: `OPC-PSEUDO-005`, `OPC-PSEUDO-007`, `OPC-PSEUDO-016`
Business meaning: converts selected PREDMET facts into a partial business policy snapshot.
Module: business policy evaluator
Truth boundary: evaluator classifies; it does not own full advisor guidance.
Why Logos must know it: future advisor work depends on not overestimating current evaluator scope.
Risk if misunderstood: missing guidance may be assumed implemented.
Read before: evaluator deep audit.
Read after: IRiU truth rules.

## INDEX-ID: OPC-PSEUDO-INDEX-005

Source file: `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
Related pseudocode sections: `OPC-PSEUDO-006`, `OPC-PSEUDO-007`, `OPC-PSEUDO-009`
Business meaning: operational, recommendation, biohazard, derivative, and financial rules for IRiU rows.
Module: IRiU truth
Truth boundary: governs row truth; does not own catalog master truth or PREDMET identity.
Why Logos must know it: small changes can affect finance, documents, and stock.
Risk if misunderstood: service changes can create hidden financial/document drift.
Read before: evaluator source.
Read after: lifecycle services and tests.

## INDEX-ID: OPC-PSEUDO-INDEX-006

Source file: `lib/features/predmeti/core_v2/services/mesto_smrti_iriu_lifecycle_service.dart`
Related pseudocode sections: `OPC-PSEUDO-006`, `OPC-PSEUDO-007`
Business meaning: plans death-place service inserts and conflicts.
Module: IRiU lifecycle
Truth boundary: plans consequences; user resolution remains important.
Why Logos must know it: death-place changes affect operational services.
Risk if misunderstood: rows may be added/removed without confirmation design.
Read before: `iriu_truth_rules.dart`
Read after: scenario tests.

## INDEX-ID: OPC-PSEUDO-INDEX-007

Source file: `lib/features/predmeti/core_v2/services/blok2_iriu_lifecycle_service.dart`
Related pseudocode sections: `OPC-PSEUDO-006`, `OPC-PSEUDO-007`
Business meaning: plans limeni/lemovanje/prevoz sprovoda additions and conflicts.
Module: IRiU lifecycle
Truth boundary: respects dismissed categories and confirmation.
Why Logos must know it: this is one of the best test-confirmed policy areas.
Risk if misunderstood: dismissed user decisions may be overwritten.
Read before: IRiU truth rules.
Read after: `test/business_policy_iriu_critical_scenarios_test.dart`

## INDEX-ID: OPC-PSEUDO-INDEX-008

Source file: `lib/features/stanje_robe/application/stanje_robe_lifecycle_service.dart`
Related pseudocode sections: `OPC-PSEUDO-008`
Business meaning: stock apply/restore/replace/unresolved consequences.
Module: STANJE ROBE
Truth boundary: operational consequence only; not PREDMET truth.
Why Logos must know it: stock side effects are sensitive and easy to duplicate.
Risk if misunderstood: inventory may become parallel case truth.
Read before: IRiU truth sections.
Read after: stock tests and JSON transfer tests.

## INDEX-ID: OPC-PSEUDO-INDEX-009

Source file: `lib/features/predmeti/core_v2/services/financial_truth_service.dart`
Related pseudocode sections: `OPC-PSEUDO-009`
Business meaning: turns active positive IRiU truth into financial basis.
Module: finance
Truth boundary: calculates from IRiU/PREDMET; does not own case truth.
Why Logos must know it: finance depends on evaluator/IRiU rules.
Risk if misunderstood: hidden total changes.
Read before: IRiU truth rules.
Read after: finance segment and PDF builders.

## INDEX-ID: OPC-PSEUDO-INDEX-010

Source file: `lib/features/predmeti/presentation/segments/parte_segment.dart`
Related pseudocode sections: `OPC-PSEUDO-010`
Business meaning: PARTA display composition from PREDMET fields and flags.
Module: PARTA
Truth boundary: derivative display; does not define identity.
Why Logos must know it: many child-illness symptoms are display composition symptoms.
Risk if misunderstood: display fix may corrupt PREDMET identity.
Read before: PREDMET table.
Read after: PDF builders.

## INDEX-ID: OPC-PSEUDO-INDEX-011

Source file: `lib/features/predmeti/pdf/*.dart`
Related pseudocode sections: `OPC-PSEUDO-011`, `OPC-PSEUDO-009`, `OPC-PSEUDO-010`
Business meaning: renders PREDMET/IRiU/finance/Firma data into documents.
Module: PDF/documents
Truth boundary: output derivative.
Why Logos must know it: documents reveal business-visible expectations but are not source of truth.
Risk if misunderstood: PDF rules become hidden policy.
Read before: PREDMET and finance sections.
Read after: `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md` and document tests.

## INDEX-ID: OPC-PSEUDO-INDEX-012

Source file: `lib/core/utils/json_export_import.dart`
Related pseudocode sections: `OPC-PSEUDO-012`, `OPC-PSEUDO-013`, `OPC-PSEUDO-004`
Business meaning: single-PREDMET JSON and full backup import/export behavior.
Module: JSON transfer / backup restore
Truth boundary: transfer/recovery layer; not product center and not identity authority.
Why Logos must know it: import/replace can rewrite local business state; INC-003
requires reminder and history derivatives to follow the exact transferred
PREDMET ownership set without destination-ID reassociation.
Risk if misunderstood: filename/export date or backup becomes master truth, or
an orphan derivative is silently attached to a reused local ID.
Read before: identity owner decisions.
Read after: `lib/features/predmeti/application/full_backup_restore_coordinator.dart`,
`test/full_backup_restore_lifecycle_coordination_test.dart`, JSON regression
tests and `docs/OPC_INCIDENT_AND_ANTI_DRIFT_REGISTER.md`.

## INDEX-ID: OPC-PSEUDO-INDEX-013

Source file: `lib/core/json_transfer/predmet_json_transfer_core.dart`
Related pseudocode sections: `OPC-PSEUDO-012`
Business meaning: pure JSON transfer validation/normalization boundary.
Module: JSON transfer
Truth boundary: validates format/schema and normalizes metadata; does not decide business correctness.
Why Logos must know it: good place to learn transfer contract without UI dialog noise.
Risk if misunderstood: schema support may be confused with business safety.
Read before: `json_export_import.dart`
Read after: transfer tests.

## INDEX-ID: OPC-PSEUDO-INDEX-014

Source file: `lib/core/entitlements/opc_entitlement_policy.dart`
Related pseudocode sections: `OPC-PSEUDO-014`
Business meaning: Stage 1 makes every existing native capability available; retained package/add-on/license data is compatibility diagnostics only.
Module: native access / retained entitlement architecture
Truth boundary: access does not bypass roles/business prerequisites and never mutates PREDMET truth.
Why Logos must know it: PAKETI are permanently abandoned as native product policy, while Stage 2 physical code removal is deliberately deferred.
Risk if misunderstood: historical package matrices could be reactivated or compatibility code deleted before owner runtime validation.
Read before: current owner Stage 1/Stage 2 decision.
Read after: license parser tests.

## INDEX-ID: OPC-PSEUDO-INDEX-015

Source file: `lib/features/auth/**/*.dart`; `lib/core/database/tables/korisnici_table.dart`
Related pseudocode sections: `OPC-PSEUDO-015`
Business meaning: local login, role, session, recovery.
Module: users/auth/roles
Truth boundary: supplies actor context; not cross-device firm/license identity.
Why Logos must know it: future roles must not be assumed stable from local source alone.
Risk if misunderstood: premature role architecture.
Read before: owner role decisions.
Read after: login/settings smoke tests.

## INDEX-ID: OPC-PSEUDO-INDEX-016

Source file: `PROJECT_DOCS/*`
Related pseudocode sections: `OPC-PSEUDO-017`
Business meaning: legacy/local continuity context.
Module: documentation continuity
Truth boundary: supporting/historical; public docs are current source of truth.
Why Logos must know it: local docs preserve history but may contain stale wording.
Risk if misunderstood: old SaaS/server-master wording overrides manifest.
Read before: public promotion map.
Read after: current public source-of-truth docs.

## INDEX-ID: OPC-PSEUDO-INDEX-017

Source file: `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md`
Related pseudocode sections: `OPC-PSEUDO-018`
Business meaning: classifies each module by read/write/output/side-effect boundary around PREDMET.
Module: modular contracts
Truth boundary: modules may consume, render, transfer, analyze, warn, or operationally react to PREDMET truth, but must not become parallel truth.
Why Logos must know it: future grouped work needs module boundaries before implementation.
Risk if misunderstood: derivative or operational outputs become master PREDMET truth.
Read before: manifest and module relationship map.
Read after: grouped safe upgrade plan.

## INDEX-ID: OPC-PSEUDO-INDEX-018

Source file: `docs/OPC_MODULAR_FOUNDATION_CONTROL_PLAN.md`
Related pseudocode sections: `OPC-PSEUDO-019`
Business meaning: requires characterization evidence and owner-approved rule changes before behavior changes.
Module: all business/logical modules
Truth boundary: documentation can record evidence and blockers; it does not authorize behavior changes.
Why Logos must know it: source/test/runtime characterization prevents accidental rule drift.
Risk if misunderstood: symptom fixes can change business meaning without proof.
Read before: implementation stop-list.
Read after: affected module pseudocode.

## INDEX-ID: OPC-PSEUDO-INDEX-019

Source file: `docs/OPC_GROUPED_SAFE_UPGRADE_PLAN.md`
Related pseudocode sections: `OPC-PSEUDO-020`
Business meaning: groups symptoms into upgrade families without nano-tasks, roadmap, priority order, or recommended next task.
Module: safe upgrade planning
Truth boundary: groups are evidence buckets only.
Why Logos must know it: Logos/owner decide strategy after reviewing evidence.
Risk if misunderstood: Codex output becomes unintended strategy.
Read before: child-illness register.
Read after: source/test characterization material when selected by owner.

## INDEX-ID: OPC-PSEUDO-INDEX-020

Source file: `docs/OPC_WEB_READINESS_GUARDRAILS.md`
Related pseudocode sections: `OPC-PSEUDO-021`
Business meaning: checks whether current decisions preserve future OPC Web/access readiness without choosing architecture.
Module: future OPC Web/sync
Truth boundary: no Web/backend/API/sync/storage/payment/licensing/role implementation is authorized.
Why Logos must know it: future Web must preserve PREDMET truth, local/firma ownership, and explicit transfer/conflict rules.
Risk if misunderstood: server-master or premature sync assumptions can override current OPC truth.
Read before: owner decision report and manifest.
Read after: technical architecture audit material if owner authorizes it.

## INDEX-ID: OPC-PSEUDO-INDEX-021

Source file: `docs/OPC_CHARACTERIZATION_EVIDENCE_FOUNDATION.md`
Related pseudocode sections: `OPC-PSEUDO-022`, `OPC-PSEUDO-025`
Business meaning: classifies current behavior evidence without inflating source, test, runtime, or policy proof.
Module: characterization evidence
Truth boundary: evidence classification is documentation only.
Why Logos must know it: future behavior changes require proof of current behavior first.
Risk if misunderstood: source-confirmed behavior may be treated as test-confirmed.
Read before: coverage matrix.
Read after: gap register.

## INDEX-ID: OPC-PSEUDO-INDEX-022

Source file: `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`
Related pseudocode sections: `OPC-PSEUDO-023`, `OPC-PSEUDO-025`
Business meaning: maps behaviors to pseudocode, source files, existing tests, runtime evidence, docs, and gaps.
Module: characterization coverage
Truth boundary: matrix records evidence; it does not authorize implementation.
Why Logos must know it: gaps and protected behavior need module-level evidence.
Risk if misunderstood: a coverage gap can be mistaken for a task recommendation.
Read before: module contracts.
Read after: before-change rules.

## INDEX-ID: OPC-PSEUDO-INDEX-023

Source file: `docs/OPC_CHARACTERIZATION_BEFORE_CHANGE_RULES.md`
Related pseudocode sections: `OPC-PSEUDO-024`
Business meaning: blocks behavior changes until current behavior, owner intent, pseudocode, and test/audit status are clear.
Module: before-change governance
Truth boundary: blocking rule only; no behavior change.
Why Logos must know it: implementation must not begin from uncharacterized symptoms.
Risk if misunderstood: gaps become nano-tasks or unapproved implementation.
Read before: implementation stop-list.
Read after: affected behavior coverage entry.

## INDEX-ID: OPC-PSEUDO-INDEX-024

Source file: `docs/OPC_CHARACTERIZATION_GAP_REGISTER.md`
Related pseudocode sections: `OPC-PSEUDO-024`, `OPC-PSEUDO-026`
Business meaning: groups characterization gaps by module and safe-upgrade family.
Module: characterization gaps
Truth boundary: gaps are blockers/evidence buckets, not recommendations.
Why Logos must know it: future owner review can see what is unprotected.
Risk if misunderstood: gap register becomes roadmap or priority order.
Read before: grouped safe upgrade plan.
Read after: owner/technical audit material when authorized.

## INDEX-ID: OPC-PSEUDO-INDEX-025

Source file: `docs/OPC_PREDMET_LIFECYCLE_IDENTITY_VERSION_CHARACTERIZATION.md`
Related pseudocode sections: `OPC-PSEUDO-027`
Business meaning: characterizes current PREDMET lifecycle, identity, business version, export metadata, same-PREDMET JSON conflict, replacement, and change-log visibility behavior.
Module: PREDMET lifecycle/identity/version
Truth boundary: local PREDMET `id` is technical; `brojPredmeta` is not global identity; `verzija` is business-version signal; filename/export date are not authority.
Why Logos must know it: future behavior changes need current PREDMET identity/version evidence without treating gaps as implementation instructions.
Risk if misunderstood: local ids, filenames, export dates, or incomplete logs become unintended Web/sync authority.
Read before: Web readiness guardrails and owner decisions.
Read after: JSON regression evidence and source audit material.

## INDEX-ID: OPC-PSEUDO-INDEX-026

Source file: `docs/OPC_BUSINESS_POLICY_EVALUATOR_ADVISOR_PREGLED_CHARACTERIZATION.md`
Related pseudocode sections: `OPC-PSEUDO-028`
Business meaning: characterizes current business policy evaluator, advisor/guidance status, IRiU truth bridge, finance use, entitlement boundary, and `Pregled i potvrda`.
Module: evaluator/advisor/Pregled
Truth boundary: evaluator/advisor/Pregled outputs are derived from PREDMET and related rows; current Pregled is not full advisor or change-log authority.
Why Logos must know it: future evaluator, advisor, finance, IRiU, Pregled, entitlement, and Web/sync work must not overclaim partial source behavior.
Risk if misunderstood: partial evaluator flags or IRiU recommendations can be promoted into complete advisor truth or Web/sync authority.
Read before: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`
Read after: evaluator, IRiU truth, Pregled, finance, and entitlement source files.

## INDEX-ID: OPC-PSEUDO-INDEX-027

Source file: `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
Related pseudocode sections: `OPC-PSEUDO-029`
Business meaning: IRiU table row catalog picker resolves source categories for row-level article selection; CITULJE rows must expose both Politika and Novosti catalog sources.
Module: IRiU table / KATALOG picker
Truth boundary: row-level picker source selection updates only the selected IRiU row catalog-backed fields; it is not a catalog seed, manual KATALOSKA, document output, finance formula, JSON, evaluator, or entitlement rule.
Why Logos must know it: one display label (`CITULJE`) maps to two source catalog categories, so UI grouping must not erase source identity.
Risk if misunderstood: Novosti CITULJE can become unreachable or a Novosti article can be stored under the Politika internal category.
Read before: `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
Read after: `lib/features/podesavanja/data/podesavanja_repository.dart`, `lib/features/predmeti/data/iriu_repository.dart`, and `test/iriu_citulje_catalog_picker_test.dart`.

## INDEX-ID: OPC-PSEUDO-INDEX-028

Source file: `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
Related pseudocode sections: `OPC-PSEUDO-030`
Business meaning: the category-scoped catalog grid opens a near-window-size detail viewer; previous/next changes only the displayed list index, and `IZABERI` returns that displayed article through the existing callback.
Module: IRiU table / KATALOG picker detail UX
Truth boundary: responsive image layout and local navigation do not own catalog filtering, catalog master data, or IRiU persistence semantics.
Why Logos must know it: the displayed photograph and returned `stableArticleId` must remain synchronized while browsing adjacent articles.
Risk if misunderstood: navigation can show one article and select another, or a nested picker constraint can make full-size layout ineffective.
Read before: `OPC-PSEUDO-029` and `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`.
Read after: `lib/features/podesavanja/presentation/katalog_photo_policy.dart` and `test/iriu_citulje_catalog_picker_test.dart`.

## INDEX-ID: OPC-PSEUDO-INDEX-029

Source file: `lib/features/predmeti/presentation/izvestaji_screen.dart`
Related pseudocode sections: `OPC-PSEUDO-031`
Business meaning: Android STATISTIKA permanently shows only the active-period summary and keeps the full period controls in a temporary sheet so statistical data remains primary.
Module: PREDMET-derived statistics UI
Truth boundary: filter presentation does not change date-range semantics, snapshot inputs, calculations, or PREDMET truth.
Why Logos must know it: the filter is a control surface, not the primary business output of STATISTIKA.
Risk if misunderstood: compact presentation can be mistaken for permission to remove filters or change statistical meaning.
Read before: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`.
Read after: `lib/features/predmeti/statistika_v1/statistika_snapshot_service.dart`, `lib/features/predmeti/presentation/statistika_aggregator.dart`, and `test/statistika_filter_layout_test.dart`.

## INDEX-ID: OPC-PSEUDO-INDEX-030

Source file: `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
Related pseudocode sections: `OPC-PSEUDO-032`
Business meaning: automatic GDPR startup dialogs are retired while manual per-PREDMET GDPR anonymization remains available.
Truth boundary: startup presentation does not own GDPR eligibility, data, legal behavior, or PREDMET lifecycle.
Risk if misunderstood: startup-dialog removal can be mistaken for permission to delete GDPR behavior.
Read after: `lib/features/predmeti/data/predmeti_repository.dart` and manual GDPR actions in `predmet_screen.dart`.

## INDEX-ID: OPC-PSEUDO-INDEX-031

Source file: `lib/features/predmeti/reminders/ceremony_reminder_coordinator.dart`
Related pseudocode sections: `OPC-PSEUDO-033`
Business meaning: Windows in-app reminders and Android local notifications derive from the same PREDMET ceremony term and local frequency configuration.
Reminder content: exact `vrstaCeremonije`, PREMINULO LICE `ime + prezime`, `datumCeremonije`, `vremeCeremonije`, and the preparation instruction are required PREDMET business identity.
Formula starts directly with `vrstaCeremonije`; literal `CEREMONIJA` is not prefixed.
Current-trigger and platform-scheduling semantics are separate:
`activeCeremonyReminderSlot` answers whether a configured slot is active now,
while `buildCeremonyReminderOccurrences` may prepare future -2/-1/0 delivery
slots earlier. Full restore rebuilds only transferred, PREDMET-owned logical
configs and must not turn future scheduling into an active-trigger claim.

## INDEX-ID: OPC-PSEUDO-INDEX-032

Source files: `preminulo_lice_segment.dart`; `ceremonija_segment.dart`; `app_date_format.dart`
Related pseudocode sections: `OPC-PSEUDO-034`
Business meaning: birth, death, and ceremony dates use calendar dialogs while preserving existing Serbian field text and autosave behavior.
Truth boundary: input method does not redefine date facts, storage, outputs, or reminder semantics.
Risk if misunderstood: a UI convenience change can be mistaken for date-model migration.
Truth boundary: local reminder settings/IDs are operational state; PREDMET ceremony date/time remains master truth and local id is not cross-device identity.
Risk if misunderstood: scheduled state can become parallel ceremony truth or imply remote push infrastructure.
Read after: reminder model/repository/gateway, CEREMONIJA segment, Android manifest, and focused tests.

## INDEX-ID: OPC-PSEUDO-INDEX-033

Source files: `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`; `lib/core/format/app_money_format.dart`
Related pseudocode sections: `OPC-PSEUDO-035`
Business meaning: manual IRiU `iznos` accepts practical comma/dot input and commits the same numeric value in Serbian display format.
Module: IRiU table / manual amount input
Truth boundary: controller parsing and display do not redefine catalog prices, quantity, totals, storage, PDF, or JSON.
Why Logos must know it: `1.234.56` deliberately uses the last separator as decimal, while invalid text must not silently overwrite a business amount.
Risk if misunderstood: a presentation fix can accidentally become a finance or persistence policy change.
Read before: `OPC-PSEUDO-009` and `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`.
Read after: `lib/core/database/tables/iriu_table.dart`, `lib/features/predmeti/data/iriu_repository.dart`, and `test/iriu_manual_amount_format_test.dart`.

## INDEX-ID: OPC-PSEUDO-INDEX-034

Source files: `lib/core/entitlements/opc_entitlement_policy.dart`; `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`; `lib/core/database/tables/app_podesavanja_table.dart`; `lib/features/podesavanja/presentation/podesavanja_screen.dart`
Related pseudocode sections: `OPC-PSEUDO-036`
Business meaning: POTPUN availability and active stock tracking are separate; active use defaults off and remains an ADMINISTRATOR choice.
Module: STANJE ROBE / entitlement / settings
Truth boundary: entitlement exposes capability; the persisted toggle controls operational effects without owning PREDMET truth.
Why Logos must know it: package inclusion must not be interpreted as automatic inventory tracking.
Risk if misunderstood: runtime validation may expect stock movement before the user enables it.
Read after: `test/stanje_robe_operational_toggle_test.dart` and `test/package_downgrade_migration_test.dart`.

## INDEX-ID: OPC-PSEUDO-INDEX-035

Source files: `lib/core/entitlements/opc_entitlement_policy.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/predmeti/pdf/racun_pdf_export.dart`
Related pseudocode sections: `OPC-PSEUDO-037`
Business meaning: RAČUN is a standard visible PDF action in the PREDMET DOKUMENTI section.
Module: PREDMET documents / PDF
Truth boundary: RAČUN is a PREDMET-derived output, not independent business truth.
Why Logos must know it: runtime document expectations must include the source-confirmed RAČUN action.
Risk if misunderstood: a verification task could accidentally alter the document set.
Read after: `test/package_downgrade_migration_test.dart`.

## INDEX-ID: OPC-PSEUDO-INDEX-036

Source files: catalog photo policy, reminder model/repository/UI, date formatting/PREMINULO LICE, FINANSIJE, and app entitlement routing
Related pseudocode sections: `OPC-PSEUDO-038` through `OPC-PSEUDO-043`
Business meaning: shared runtime corrections preserve catalog proportions, use explicit reminder clock times, retain Serbian historical-date formatting, validate financial input, propagate the installed package, and keep marital vocabulary consistent with POL.
Truth boundary: presentation, local operational configuration, validation, and entitlement routing do not redefine PREDMET facts.
Risk if misunderstood: these corrections could be expanded into unauthorized catalog, package, finance, date, stock, PDF, JSON, or GDPR policy changes.
Read after: `docs/tasks/OPC_TASK_SHARED_RUNTIME_FAIL_CORRECTIONS_BUILD_REPORT.md` and its focused tests.

## INDEX-ID: OPC-PSEUDO-INDEX-037

Source files: `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/predmeti/pdf/memorandum_logo.dart`; the six document export files under `lib/features/predmeti/pdf/`; `lib/core/database/tables/firma_podaci_table.dart`
Related pseudocode: `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md`
Business meaning: PREDMET-derived PDFs use document-specific headers but share proportional rendering of the optional FirmaPodaci logo.
Module: PREDMET documents / PDF memorandum
Truth boundary: the shared 192 x 120 point maximum logo box changes presentation only; document set, text, metadata, dates, calculations, QR, JSON, and export behavior remain protected.
Why Logos must know it: a shared logo helper does not mean the complete headers are shared; title, date, and `Broj predmeta` placement deliberately diverge.
Risk if misunderstood: blindly consolidating or rearranging headers can alter RAČUN wording, crowd long company data, or damage document-specific legal/financial readability.
Read after: `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md` and the six exporter header builders.

## INDEX-ID: OPC-PSEUDO-INDEX-038

Source files: `lib/core/entitlements/opc_entitlement_policy.dart`; `lib/features/podesavanja/presentation/podesavanja_screen.dart`; `lib/features/predmeti/presentation/lista_predmeta_screen.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`
Related pseudocode: `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md`
Business meaning: STANJE ROBE and PODSETNIK are available to every native user; ADMINISTRATOR-controlled stock activation, roles and CEREMONIJA/PREDMET truth remain separate.
Module: settings / STANJE ROBE / MODULI / PODSETNIK
Truth boundary: unrestricted module visibility/navigation does not change stock effects, reminder configuration/scheduling, ceremony facts, roles or PREDMET truth.
Why Logos must know it: PODSETNIK uses the module-owned surface and existing reminder engine without any current package lock.
Risk if misunderstood: CEREMONIJA could again become the module identity, or relocation could create duplicate reminder/PREDMET truth.
Read after: `test/stanje_robe_operational_toggle_test.dart`, `test/lista_predmeta_screen_smoke_test.dart`, and the existing reminder model/repository/coordinator.

## INDEX-ID: OPC-PSEUDO-INDEX-039

Source files: `lib/core/entitlements/opc_entitlement_policy.dart`; `lib/features/podesavanja/presentation/podesavanja_screen.dart`; `lib/features/podsetnik/presentation/podsetnik_module_screen.dart`; `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
Related pseudocode: `docs/OPC_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_PSEUDOCODE.md`
Business meaning: the central Stage 1 owner policy grants all existing native capabilities; MODULI gives operational capabilities a clear identity around, but never above, PREDMET.
Module: PAKETI / MODULI / PODSETNIK
Truth boundary: PODSETNIK owns reminder configuration only; PREDMET/CEREMONIJA own ceremony facts and the existing reminder engine owns persistence/scheduling/delivery.
Why Logos must know it: UI ownership and data ownership are distinct and must not drift together.
Risk if misunderstood: obsolete package checks could return or module settings could become parallel business truth.

## INDEX-ID: OPC-PSEUDO-INDEX-040

Source files: `lib/features/predmeti/presentation/lista_predmeta_screen.dart`; `lib/features/predmeti/reminders/`; `lib/features/predmeti/presentation/izvestaji_screen.dart`; `lib/features/predmeti/pdf/`; `lib/app.dart`; `windows/runner/`
Related pseudocode: `docs/OPC_PRE_POINT_4_CORRECTIONS_AUDIT_PSEUDOCODE.md`
Business meaning: A–H pre-implementation map separates source-proven module behavior, presentation debt, Android delivery proof, narrow PDF polish, and Windows exit profiling before Point 4 smoke.
Module: STANJE ROBE / PODSETNIK / STATISTIKA / PDF / platform support
Truth boundary: all areas consume or present PREDMET facts; none may replace PREDMET or alter unrelated business logic.
Why Logos must know it: source/test confidence must not be reported as native notification, PDF visual, licensed-runtime, or shutdown-timing proof.
Risk if misunderstood: unrelated corrections could be grouped into a broad refactor or smoke could start before platform-specific unknowns are measured.

## INDEX-ID: OPC-PSEUDO-INDEX-041

Source files: `lib/features/predmeti/pdf/memorandum_logo.dart` and the six standard PDF exporters
Related pseudocode: `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md`
Business meaning: memorandum identity information renders PIB, MB and Račun as three independent optional rows with the canonical Serbian label.
Module: PDF / DOKUMENTI derivative presentation
Truth boundary: the helper formats existing values only; it does not own or change PREDMET, settings, finance, IRiU or catalog truth.
Why Logos must know it: complete headers remain duplicated/exporter-owned while only the narrow identity-row contract is shared.
Risk if misunderstood: this presentation polish could be expanded into a broad PDF layout or business-content rewrite.

## INDEX-ID: OPC-PSEUDO-INDEX-042

Source files: `lib/core/entitlements/opc_entitlement_policy.dart`; `lib/core/entitlements/opc_runtime_entitlement_resolver.dart`; `lib/app.dart`
Related pseudocode: `docs/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md`
Business meaning: historical explicit owner/internal presentation builds could run as POTPUN through `OPC_PRESENTATION_POTPUN=true`; this is audit evidence superseded by the 2026-07-16 unrestricted-native Stage 1 decision.
Module: entitlement/packages / presentation build
Truth boundary: the override controls runtime availability only; it does not redefine PREDMET, database ownership, PDF/JSON output, STANJE ROBE operational state, or real production licensing.
Why Logos must know it: this compatibility flag remains available, but it no longer describes the complete current development-build default.
Risk if misunderstood: presentation evidence could be mistaken for production license readiness or Point 4 smoke clearance.

## INDEX-ID: OPC-PSEUDO-INDEX-043

Source files: `lib/main.dart`; `lib/app.dart`; `lib/core/config/app_config.dart`; `lib/core/database/database.dart`; `lib/core/database/database_lane_diagnostics.dart`; `lib/features/auth/**`; `lib/core/entitlements/opc_runtime_entitlement_resolver.dart`
Related pseudocode: `docs/OPC_WINDOWS_IDENTITY_PERSISTENCE_AUDIT_PSEUDOCODE.md`
Business meaning: Windows identity persistence depends on the active SQLite lane, `korisnici` rows, auth/recovery flow, and startup routing; presentation POTPUN entitlement is a separate startup branch that must be audited without assuming root cause.
Module: Windows identity/auth/database lane audit
Truth boundary: audit evidence may classify hypotheses but must not mutate client data, create replacement administrators, reset PINs, or change production source behavior.
Why Logos must know it: the visible TEST/ADMINISTRATOR symptom can be caused by several unresolved branches, especially opened database mismatch versus actual user-row loss.
Risk if misunderstood: a recovery or correction task could be launched before proving whether the real Administrator row still exists and which database was opened.

## INDEX-ID: OPC-PSEUDO-INDEX-044

Source files: `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/podsetnik/presentation/podsetnik_module_screen.dart`; `lib/features/predmeti/reminders/`; `lib/core/utils/json_export_import.dart`; role and entitlement source
Related pseudocode: `docs/OPC_PODSETNIK_CONTROL_FLOW_AND_USER_CONFIRMATION_PSEUDOCODE.md`
Business meaning: a future PODSETNIK control surface may present and initiate confirmation of organizational steps only when their authoritative existence, responsibility, business state and completion history remain owned by the PREDMET domain.
Module: PREDMET / NAPOMENA audit / MODULI / PODSETNIK / notifications
Truth boundary: derived warnings and technical delivery state may belong to PODSETNIK infrastructure; the only copy of a business obligation or completion fact may not.
Why Logos must know it: read, acknowledgement, postponement, dismissal and explicit business completion are different states, and current source has no standalone PREDMET segment named NAPOMENE.
Risk if misunderstood: PODSETNIK could become a second case-management database, notification dismissal could be mistaken for completion, or structured tasks could be hidden inside the current free-text note without version/JSON/migration discipline.
Read after: `docs/tasks/OPC_TASK_PODSETNIK_CONTROL_FLOW_USER_CONFIRMATION_AUDIT_REPORT.md` and the owner-decision queue in that report.

## INDEX-ID: OPC-PSEUDO-INDEX-045

Source files: `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`; `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`; `lib/features/predmeti/presentation/segments/iriu_segment.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/lista_predmeta_screen.dart`; `lib/features/predmeti/presentation/segments/parte_segment.dart`; `lib/core/utils/json_export_import.dart`; PODSETNIK/reminder/entitlement source
Related pseudocode: `docs/OPC_OWNER_DECISIONS_STATUSI_CEREMONIJA_PSEUDOCODE.md`
Business meaning: owner-approved STATUSI, CEREMONIJA and partial cross-segment decisions define possible, accepted, executed, revoked and cancelled obligations, explicit fallbacks, ZAVRŠEN gates and derived readiness without claiming that future behavior already exists.
Module: PREDMET / STATUSI / CEREMONIJA / IRIU / PARTE / PODSETNIK / LISTA
Truth boundary: PREDMET owns business facts, obligations, state and history; PODSETNIK may present and schedule but owns only technical reminder state; PARTE remains derivative.
Why Logos must know it: every future design must distinguish current source, owner-confirmed implemented rules and unresolved IRIU/readiness decisions by stable owner-decision ID.
Risk if misunderstood: documentation could be mistaken for implementation, notification interaction could become business completion, BALSAMOVANJE could be incorrectly moved away from SAHRANA VAN SRBIJE, or missing cross-segment conditions could be silently overridden.
Read after: `docs/OPC_OWNER_DECISION_GUIDE.md`; `docs/OPC_OWNER_DECISION_INDEX.md`; `docs/tasks/OPC_TASK_OWNER_DECISIONS_STATUSI_CEREMONIJA_DOCUMENTATION_REPORT.md`.

## INDEX-ID: OPC-PSEUDO-INDEX-046

Source files: `lib/core/database/tables/iriu_table.dart`; `lib/core/constants/iriu_constants.dart`; `lib/features/predmeti/data/iriu_repository.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/core_v2/business_policy/`; `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`; `lib/features/predmeti/core_v2/services/`; `lib/features/predmeti/presentation/segments/iriu_segment.dart`; `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`; `lib/features/predmeti/pdf/`; `lib/core/utils/json_export_import.dart`; STANJE ROBE and entitlement source
Related pseudocode: `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`
Business meaning: current ROBA I USLUGE rows are mixed stored PREDMET child snapshots whose active, suppressed, recommended, financial, stock and document consequences are derived from PREDMET facts; they are not a general accepted/completed obligation model.
Module: PREDMET / ČINJENICE O SMRTI / CEREMONIJA / IRIU / FINANSIJE / STANJE ROBE / STATISTIKA / NALOG ZA OPREMANJE / PDF / JSON / future PODSETNIK
Truth boundary: PREDMET remains authoritative; `IriuTruthRules` is current row-rule authority; NALOG ZA OPREMANJE and other outputs are derivatives; PODSETNIK cannot infer completion or readiness from row presence or a generated PDF.
Why Logos must know it: source rules are split across initialization, presentation triggers, truth/lifecycle services, finance, stock, JSON and document builders, with different reversal/history behavior by category.
Risk if misunderstood: a stored or active row could be mistaken for an executed obligation, `cekiran` or a paper signature line could be mistaken for completion, suppressed rows/history could disappear, IRIU-only changes could be overclaimed as version evidence, or owner-confirmed BALSAMOVANJE/DOČEK ownership could regress.
Read after: `docs/OPC_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md`; `docs/tasks/OPC_TASK_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md`; `docs/OPC_OWNER_DECISION_GUIDE.md`.

## INDEX-ID: OPC-PSEUDO-INDEX-047

Source files: `lib/core/database/tables/predmeti_table.dart`; `lib/core/database/database.dart`; `lib/core/utils/json_export_import.dart`; `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`; `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`; focused JSON, IRIU truth and Windows/Android widget tests
Related pseudocode: `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`
Business meaning: DOČEK POSMRTNIH OSTATAKA now carries first-class MESTO/DATUM/VREME parameters; owner-confirmed IRIU ownership keeps conditional removable BALSAMOVANJE under SAHRANA VAN SRBIJE and CARGO under DOČEK; KOMPLET ZA OPELO is suppressed rather than deleted when OPELO becomes NE.
Module: PREDMET / CEREMONIJA / IRIU / JSON / Windows / Android
Truth boundary: PREDMET stores DOČEK facts and source conditions; IRIU truth derives row activity without inventing acceptance, execution, completion or PODSETNIK state.
Why Logos must know it: old JSON receives an empty DATUM DOČEKA fallback, manually changed generated rows remain stored while suppressed, and narrow Android grows vertically while Windows retains the horizontal layout.
Risk if misunderstood: missing dates could be silently invented, source-invalid rows could remain financially active, user edits could be deleted, or PODSETNIK/readiness behavior could be inferred from this narrow correction.
Read after: `docs/tasks/OPC_TASK_IRIU_CONFIRMED_BUSINESS_LOGIC_ALIGNMENT_REPORT.md`; `docs/OPC_OWNER_DECISION_GUIDE.md`; `docs/OPC_OWNER_DECISION_INDEX.md`.

## INDEX-ID: OPC-PSEUDO-INDEX-048

Source files: `lib/features/predmeti/presentation/segments/parte_segment.dart`; `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`; `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/core/database/tables/predmeti_table.dart`; `lib/core/utils/json_export_import.dart`; `lib/core/utils/export_utils.dart`; `lib/features/predmeti/pdf/`; `lib/features/podesavanja/`; `lib/core/entitlements/opc_entitlement_policy.dart`; Android/Windows delivery source; existing symbol assets; two owner-supplied local DOCX references
Related pseudocode: `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`
Business meaning: current PARTE persists PREDMET-scoped public-display choices and derives text, while future print preparation would add reviewed grammar, a real symbol, an app-owned prepared photograph and a deterministic derivative artifact without making the artifact a second PREDMET truth.
Module: PREDMET / PREMINULO LICE / CEREMONIJA / PARTE / PDF / media / JSON / backup / anonymization / packages / Windows / Android
Truth boundary: external original photographs remain user-owned and untouched; an OPC-normalized copy may be OPC-owned; preview/PDF/image/print remain derivatives; photo retention/deletion, symbol fallback and anonymization follow current owner decisions, while historical package behavior is superseded by Stage 1 unrestricted native access.
Why Logos must know it: the two references share one floating-object layout with grammatical variants, but current source has no standalone PARTE artifact or photo lifecycle, current symbol output is label-only, `parteIme` is orphaned, and current anonymization does not cover mourners/media/artifacts.
Risk if misunderstood: OPC could delete an external original, make a PDF the only surviving truth, publish wrong grammar, silently replace a religious symbol, truncate personal text, break cross-device restore or wrongly revive package-based media behavior.
Read after: `docs/OPC_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md`; `docs/tasks/OPC_TASK_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md`; `docs/OPC_OWNER_DECISION_GUIDE.md` section 8.

## INDEX-ID: OPC-PSEUDO-INDEX-049

Document path: `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`, sections 20-27
Source paths represented: `lib/features/predmeti/parte/`; `lib/features/predmeti/presentation/segments/parte_segment.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/core/database/tables/parte_pripreme_table.dart`; `lib/core/database/tables/parte_predlosci_table.dart`; `lib/core/database/tables/predmeti_table.dart`; `lib/core/database/tables/firma_podaci_table.dart`; `lib/core/utils/json_export_import.dart`; `lib/core/json_transfer/predmet_json_transfer_core.dart`; `assets/simboli/parte_*.png`
Scope: implemented PREDMET-derived PARTE initialization, restart-safe technical preparation, FIRMA templates, owned media lifecycle, one WYSIWYG render plan, KORICE PDF, completion blocker/cleanup, roles, entitlement, JSON boundaries and platform parity.
Business meaning: PARTE is a controlled derivative print-preparation workflow. PREDMET remains the sole business truth; temporary edits and media never become PREDMET facts.
Truth boundary: the external original is read-only; the app owns only normalized copies; templates are content-free; exported PDF is a derivative retained after cleanup.
Last task: `OPC-PARTE-PRINT-PREPARATION-IMPLEMENTATION` (final commit recorded in its report after commit creation).
Alignment: implementation and pseudocode are aligned for the task branch; real Windows/Android runtime smoke remains separately reported.
Why Logos must know it: closing or anonymizing a PREDMET is blocked by an unfinished started preparation, while retained package/license data never hides or destroys preparation state.
Risk if misunderstood: a temporary draft could be promoted to business truth, external media could be deleted, preview and PDF could drift, or cleanup could destroy the exported artifact.
Read before: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`; `docs/OPC_OWNER_DECISION_GUIDE.md` section 8.
Read after: `docs/tasks/OPC_TASK_PARTE_PRINT_PREPARATION_IMPLEMENTATION_REPORT.md`.

## Historical native development POTPUN runtime boundary — SUPERSEDED

Document: `docs/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md`

Scope: historical shared Windows/Android development POTPUN default and explicit
`OPC_FINAL_PACKAGE_LICENSING=true` restoration path; superseded as current product policy,
diagnostics and no module-specific bypass.

Source represented: `lib/core/entitlements/opc_entitlement_policy.dart`;
`lib/core/entitlements/opc_runtime_entitlement_resolver.dart`;
`lib/features/podesavanja/presentation/podesavanja_screen.dart`.

Last task: `OPC-DEVELOPMENT-POTPUN-RUNTIME-UNLOCK-PARTE-UI-CLEANUP`.
Implementation/pseudocode aligned: yes.
# PARTE runtime-corrected learning entry (2026-07-12)

- `OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md` is authoritative for the split between PREDMET business truth and MODUL PARTE technical preparation.
- It includes eligible-PREDMET selection, full initial-script normalization, manual mixed-script preservation, reference layout, one-line name compression, preview selection, drag/resize, photo adjustments, reset, contextual templates, authoritative PDF and optional DOCX.
- Runtime order is Windows first and Android second; a build is not runtime evidence.

## OPC-PSEUDO-INDEX-050 — Stage 1 unrestricted native runtime and retained PARTE

- Source of logic: central `OpcNativeAccessPolicy`, PREDMET overview `ModuliScreen`, retained preparation repository/service, schema-3 PARTE geometry, shared render plan, positioned OOXML exporter and Android KORICE platform channel.
- Learning rule: package/license data is compatibility diagnostics, never current functional gating and never rewritten as a fake POTPUN license.
- PARTE rule: completion and retained technical revision are separate; edit invalidates preview/export evidence but does not recreate the business blocker.
- Output rule: PDF owns physical WYSIWYG; DOCX owns editable independent blocks; Android uses MediaStore or a system destination picker according to OS capability.
- Runtime gate: Windows owner physical print/DOCX acceptance precedes Android runtime. Build success alone is not runtime acceptance.

## OPC-PSEUDO-INDEX-051 — PARTE printable zone, PDF and Word derivative

- Source: PARTE schema-5 draft/template, composer, preview, PDF renderer, calibration renderer and DOCX exporter.
- Geometry: outer page is separate from configurable printable-zone X/Y/width/height; safe margins are inside the zone; blocks retain absolute page millimetres.
- Shared-plan rule: preview and PDF consume the same origin, scale, bounds, fitted lines and overflow decision. No implicit centering or global shrink exists.
- Migration: schema 1–3 becomes a full-page zone with unchanged block coordinates; schema 4 persists the explicit zone.
- UI/font rule: `PREGLED PRIPREME`, en-dash years, embedded Noto Sans/Noto Serif, collapsible text/format, persistent designer.
- Output boundary: PDF is authoritative; DOCX is a Word-validated editable positioned-block derivative; physical print remains owner acceptance.
- Schema: `docs/OPC_PARTE_TEMPLATE_SCHEMA.md`.
- Report: `docs/tasks/OPC_TASK_PARTE_PRINTABLE_ZONE_PDF_DOCX_UX_CORRECTION_REPORT.md`.
- Final runtime correction source: centred format input, machine-local PDF-only printer profile, editor guides/snap, schema-5 media ratio repair, Noto Serif fallback, state-aware template actions and Word Behind Text anchors.
- Acceptance boundary: custom-page electronic geometry and Word smoke can pass while physical print remains pending owner confirmation on the real printer/form.

## OPC-PSEUDO-INDEX-051 — Canonical database recovery and legacy migrations

- Document: `docs/OPC_CANONICAL_DATABASE_RECOVERY_PSEUDOCODE.md`.
- Source: `lib/core/database/database.dart`; `lib/core/database/schema_recovery.dart`.
- Business rule: an explicitly designated user database remains canonical regardless of a stale checkpoint; test databases never gain business authority from a higher schema version.
- Migration rule: Drift owns sequencing, while bounded idempotent primitives validate existing columns/tables/indexes and create only supported missing objects.
- Safety rule: malformed, unknown or newer schemas stop; user databases are never deleted, replaced, merged with test lanes or manually version-stamped.
- Evidence: populated schema 1–21 fixtures, confirmed v19 partial states, malformed-state tests, interruption/retry test and gated owner-copy migration test.
- Read with: `docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md` and the current task report.

## OPC-PSEUDO-INDEX-052 — KATALOG basic categories and future IRiU materialization

- Document: `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`, section “KATALOG basic-category policy (schema 22)”.
- Source: KATALOG presentation/repository, `iriu_katalog_config`, `PredmetiRepository.inicijalizujIriu`, `IriuOrderingService`, and the existing truth/finance services.
- Business rule: default `NE`; policy changes affect future PREDMETI only; scenario rows are unchanged; `Agencijske usluge` precedes enabled user basics.
- Identity/order: deduplicate by stable `interni_naziv`; user-basic order follows persistent category creation order, not rename or toggle time.
- Manual boundary: a manual IRiU row remains PREDMET-local and never creates or changes KATALOG policy.
- Read after: `docs/tasks/OPC_TASK_KATALOG_OSNOVNE_KATEGORIJE_IRIU_AUDIT_IMPLEMENTATION_REPORT.md`.

## OPC-PSEUDO-INDEX-053 — PARTE canonical render and runtime acceptance

- Document: `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`, section “Canonical render pipeline correction (2026-07-19)”.
- Source: PARTE composer/models, preview, PDF renderer, DOCX exporter, preparation repository and template dialog.
- Pipeline: `PreparationState -> CanonicalRenderPlan -> PreviewAdapter/PdfAdapter/DocxAdapter`; adapters consume and never reinterpret resolved business/layout state.
- Required-block rule: name, years, ceremony and both mourners blocks remain mandatory in the structural draft/template contract; empty content is omitted from the render/export plan and does not block preparation or export. Duplicated, failed or structurally absent blocks remain blockers.
- Typography rule: complete one-line name, maximum `74 pt`, bounded canonical fit and source-level en-dash normalization.
- Template rule: dialog selected, preparation active and persisted default are separate identities and actions.
- Calibration rule: machine-local correction translates the PDF layer only; physical print remains owner evidence.
- UI boundary: compact technical help belongs on `PREGLED PRIPREME` outside
  the printable canvas, never in the command panel or any export/render state.
- Report: `docs/tasks/OPC_TASK_PARTE_ROOT_CAUSE_RENDER_PIPELINE_CORRECTION_RUNTIME_ACCEPTANCE_REPORT.md`.

## OPC-PSEUDO-INDEX-054 — PARTE final technical-help placement

- Document: `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`, `EDITOR CHROME`.
- Source: `lib/features/predmeti/parte/presentation/parte_composer_screen.dart`;
  `test/parte_module_screen_test.dart`.
- Rule: the preview-side help card is ordinary responsive application UI above
  the `PartePlanPreview`; it is not a render block and never reaches PDF, DOCX,
  calibration PDF or portable template JSON.
- Layout rule: technical prose is absent from command controls and expanded
  format fields retain top clearance for complete floating labels.
- Acceptance boundary: tested local printer offset and electronic render parity
  remain protected; Android runtime follows this final UI correction.
- Report: `docs/tasks/OPC_TASK_PARTE_FINAL_TECHNICAL_TEXT_PLACEMENT_UI_REGRESSION_REPORT.md`.

## OPC-PSEUDO-INDEX-055A - Phase 3 PREDMET completion lifecycle

- Source: `lib/features/predmeti/data/predmeti_repository.dart`,
  `lib/features/predmeti/presentation/predmet_screen.dart`.
- Test: `test/predmet_completion_state_characterization_test.dart`.
- Current source behavior: automatic status refresh is retired and has no
  write effect. Opening a PREDMET or starting the list no longer changes its
  status based on the ceremony date.
- Explicit lifecycle rule: `OTVOREN` may first become `ZATVOREN`; only an
  explicit user action from `ZATVOREN` may set `ZAVRŠEN`. The completion action
  writes one lifecycle audit event and leaves the PREDMET immutable for direct
  edits or reopening. Existing/imported `ZAVRŠEN` and `ANONIMIZOVAN` rows remain
  compatible; GDPR anonymization is a separate controlled lifecycle operation.
- Boundary: ceremony date is not a completion trigger. Reminder eligibility,
  PARTE preparation state and derivative outputs must not infer completion.
  Technical PASS and the explicit owner decision remain separate from runtime
  acceptance.

## OPC-PSEUDO-INDEX-055B - Gate 2A IRiU/KATALOG picker characterization

- Source: `lib/features/podesavanja/data/podesavanja_repository.dart`,
  `lib/features/predmeti/presentation/segments/iriu_segment.dart`,
  `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`.
- Test: `test/katalog_picker_repository_characterization_test.dart`.
- Current contract: the lightweight picker returns visible categories in
  configured order and article summaries in stable ID/order sequence, with
  price, stable article identity and `hasPhoto`; scoped loading excludes
  unrelated categories. Photo bytes are a separate lazy repository read.
- Measurement boundary: synthetic cold/warm Stopwatch output is diagnostic
  only. Owner Windows/Android timing must separately measure repository wait,
  first dialog frame, photo read and image decode before any batch query, cache
  or index change is authorized.
- Truth boundary: KATALOG supplies article knowledge; PREDMET and IRiU remain
  authoritative for business rows, ordering and selected snapshots.

## OPC-PSEUDO-INDEX-055 — PARTE editor/lifecycle/PREDMET PARTE navigation refinement

- Document: `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`, `EDITOR VIEWPORT REFINEMENT`, `COMPLETED PREPARATION DELETION`, and `PARTE / PREDMET SEGMENT NAVIGATION`.
- Source: PARTE composer viewport, module screen, preparation service/repository,
  app-owned media store, `PredmetScreen`, and `IriuSegment`.
- Truth boundary: PREDMET and IRiU `POSMRTNE_PARTE` are authoritative; deleting
  MODUL PARTE removes only one derivative preparation and exclusively owned media.
- Interaction rule: block drag and viewport pan have explicit mutually exclusive
  ownership; viewport state cannot enter canonical render or export state.
- Navigation rule: reuse the existing same-PREDMET segment 6 `PARTE` route and
  normal Back stack; never redirect the shortcut to segment 7 `Roba i usluge`.
- Validation boundary: prior automated validation/builds passed; runtime exposed
  the segment-7 regression and the focused correction requires fresh validation.
- Report: `docs/tasks/OPC_TASK_PARTE_EDITOR_INTERACTION_PREPARATION_DELETION_IRIU_NAVIGATION_REPORT.md`.

## OPC-PSEUDO-INDEX-055D - Phase 4 MODULI/SCENARIO contract audit

- Source route: static `ModuliScreen`/settings module tab,
  `OpcModule.businessPolicyScenario`, `predmeti.businessScenarioId`,
  `BusinessPolicyEvaluator` and `IriuTruthRules`.
- Current fact: MODULI are presentation/entitlement vocabulary; the source has
  no persisted module registry, scenario version store, criteria DSL,
  consequence definition or IRiU provenance.
- Authority rule: module definitions/defaults are configuration; selected
  scenario and applied snapshot are PREDMET authority. A PREDMET is not valid
  without a scenario snapshot.
- Future evaluation rule: declarative criteria may read only whitelisted,
  normalized PREDMET facts. Scenario consequences may target stable IRiU/KATALOG
  identities but may not own PREDMET facts, prices or stock truth.
- Reconciliation rule: explicit eligible-PREDMET confirmation removes stale
  scenario-owned rows/values, creates new empty rows, compensates operational
  effects and protects completed/locked PREDMETI.
- Boundary: this is a contract audit, not a schema/UI implementation. The
  owner decision gates and migration order are in
  `docs/tasks/OPC_TASK_PHASE4_MODULE_SCENARIO_CONTRACT_AUDIT_20260801_REPORT.md`.

## OPC-PSEUDO-INDEX-055C - Phase 3 SCENARIO/IRiU mutation characterization

- Source: `lib/features/predmeti/presentation/segments/iriu_segment.dart`,
  `lib/features/predmeti/data/iriu_repository.dart`,
  `lib/features/predmeti/core_v2/services/*iriu_lifecycle_service.dart`.
- Test: `test/phase3_scenario_iriu_mutation_characterization_test.dart`.
- Current behavior: opening a PREDMET can sync missing MESTO SMRTI and BLOK 2
  rows; repeated sync is idempotent, manual dismissal suppresses automatic
  re-addition, and explicit insertion remains user-owned.
- Confirmed gap: when a condition becomes non-applicable, current storage keeps
  the managed row while truth evaluation marks it inactive. This is stale
  data, not an owner-approved retention policy.
- Future rule: ODQ-SCENARIO-001 removes no-longer-applicable scenario-owned
  rows and their values for eligible `OTVOREN` PREDMETI after one business
  confirmation, with operational compensation and recovery. Completed/locked
  PREDMET truth is never rewritten.
- Boundary: this characterization does not change ordering, provenance,
  reconciliation, schema or STANJE ROBE behavior. INC-001 scenario-first
  ordering remains preserved as incident evidence until the controlled Phase 4
  contract is implemented.
- Report: `docs/tasks/OPC_TASK_PHASE3_SCENARIO_IRIU_MUTATION_CHARACTERIZATION_20260801_REPORT.md`.
