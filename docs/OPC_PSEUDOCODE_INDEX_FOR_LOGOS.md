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
Read after: document tests when added.

## INDEX-ID: OPC-PSEUDO-INDEX-012

Source file: `lib/core/utils/json_export_import.dart`
Related pseudocode sections: `OPC-PSEUDO-012`, `OPC-PSEUDO-013`, `OPC-PSEUDO-004`
Business meaning: single-PREDMET JSON and full backup import/export behavior.
Module: JSON transfer / backup restore
Truth boundary: transfer/recovery layer; not product center and not identity authority.
Why Logos must know it: import/replace can rewrite local business state.
Risk if misunderstood: filename/export date or backup becomes master truth.
Read before: identity owner decisions.
Read after: JSON regression tests.

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
Business meaning: packages/add-ons/module availability and fail-closed fallback.
Module: entitlement/packages
Truth boundary: can hide/lock features; must not mutate PREDMET truth.
Why Logos must know it: package access and product capability are separate from business truth.
Risk if misunderstood: licensing changes alter case data.
Read before: owner package decisions.
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
Truth boundary: local reminder settings/IDs are operational state; PREDMET ceremony date/time remains master truth and local id is not cross-device identity.
Risk if misunderstood: scheduled state can become parallel ceremony truth or imply remote push infrastructure.
Read after: reminder model/repository/gateway, CEREMONIJA segment, Android manifest, and focused tests.
