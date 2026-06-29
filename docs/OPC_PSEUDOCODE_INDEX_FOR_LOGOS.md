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

