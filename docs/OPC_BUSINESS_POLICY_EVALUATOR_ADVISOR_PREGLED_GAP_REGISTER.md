# OPC Business Policy Evaluator Advisor Pregled Gap Register

Status: docs-only gap register.

Base commit: `ea9ba1a96ba7c8f6db43921cb5421d71f3c82a03`

This register records characterization gaps. Gaps are blockers/evidence categories, not recommended tasks, sequence, roadmap, or priority order.

## GAP-ID: OPC-BPEAP-GAP-001

Area: direct evaluator snapshot tests.
Current evidence: evaluator source derives snapshot fields; selected downstream IRiU behavior is test-confirmed.
Missing evidence: direct tests for scenario fallback and every `PredmetBusinessPolicySnapshot` field.
Risk if misunderstood: evaluator field drift may be missed until downstream modules change.
Blocked behavior changes: evaluator snapshot, scenario resolution, condition flags.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## GAP-ID: OPC-BPEAP-GAP-002

Area: complete advisor/guidance engine.
Current evidence: evaluator, IRiU recommendation states, lifecycle conflicts, finance basis, and stock warning display exist.
Missing evidence: complete ceremony checklist, warning taxonomy, PIO/refund advisor, JKP/payer advisor, document requirement graph, and complete Pregled advisor.
Risk if misunderstood: partial rules may be presented as complete guidance.
Blocked behavior changes: advisor UI, warning wording, checklist outputs, guidance write-backs.
Classification: `POLICY EXISTS / IMPLEMENTATION NOT FOUND / OWNER REVIEW QUEUE`.

## GAP-ID: OPC-BPEAP-GAP-003

Area: `Pregled i potvrda` advisor/change-log completeness.
Current evidence: Pregled displays status, version, saved state, and lifecycle actions.
Missing evidence: full advisor checklist, full warning list, current evaluator snapshot display, and full change-log overview.
Risk if misunderstood: current review screen could be overclaimed as final business review authority.
Blocked behavior changes: Pregled advisor, review warnings, change-log overview, close-block behavior.
Classification: `SOURCE-CONFIRMED / IMPLEMENTATION GAP / TEST GAP`.

## GAP-ID: OPC-BPEAP-GAP-004

Area: death-place lifecycle test coverage.
Current evidence: death-place managed categories and lifecycle planning are source-confirmed.
Missing evidence: direct tests for current-state insert, condition-change conflict, dismissed-category behavior, hospital-only path, and non-hospital paths.
Risk if misunderstood: death-place service consequences may drift without test protection.
Blocked behavior changes: death-place IRiU lifecycle rules and UI guidance.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## GAP-ID: OPC-BPEAP-GAP-005

Area: international and reception consequence coverage.
Current evidence: source rules activate international transport/documentation/balsamovanje for international cases and cargo costs for reception of remains.
Missing evidence: direct tests and UI/PDF/finance consequence coverage for those paths.
Risk if misunderstood: international/reception services could become inconsistent across IRiU, finance, PDF, and review.
Blocked behavior changes: international/reception rule changes.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## GAP-ID: OPC-BPEAP-GAP-006

Area: biohazard guidance visibility.
Current evidence: evaluator and IRiU truth derive infectious non-hospital biohazard precondition and row biohazard state.
Missing evidence: complete user-facing warning taxonomy, Pregled visibility, close-block policy, and direct tests.
Risk if misunderstood: biohazard may be classified but not surfaced where users expect it.
Blocked behavior changes: biohazard warnings, advisor text, close-blocks.
Classification: `SOURCE-CONFIRMED / OWNER REVIEW QUEUE / TEST GAP`.

## GAP-ID: OPC-BPEAP-GAP-007

Area: finance matrix from IRiU truth.
Current evidence: finance resolves `robaIUsluge` through IRiU truth and financial truth service.
Missing evidence: full finance regression matrix for active/suppressed/non-positive rows plus refund, JKP, advance, discount, and PDF totals.
Risk if misunderstood: evaluator or IRiU rule changes can alter payable totals.
Blocked behavior changes: evaluator-driven finance, financial display, PDF totals.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## GAP-ID: OPC-BPEAP-GAP-008

Area: package/entitlement boundary for evaluator and advisor.
Current evidence: business policy scenario is core-available; surrounding modules have separate gates.
Missing evidence: full matrix proving evaluator/advisor visibility across Osnovni/Srednji/Potpuni/add-on combinations.
Risk if misunderstood: package gates may hide or alter derived guidance inconsistently.
Blocked behavior changes: entitlement gating for evaluator, advisor, Pregled warnings, document actions, JSON, STANJE ROBE.
Classification: `SOURCE-CONFIRMED / TEST GAP / OWNER REVIEW QUEUE`.

## GAP-ID: OPC-BPEAP-GAP-009

Area: persistence and sync boundary for derived outputs.
Current evidence: evaluator snapshot and IRiU truth reasons are derived in memory in inspected source.
Missing evidence: future sync/storage conflict model for derived advisor outputs.
Risk if misunderstood: derived warnings or truth rows could become parallel persistent PREDMET truth.
Blocked behavior changes: persistence of evaluator/advisor outputs, Web/sync/storage/API design.
Classification: `SOURCE-CONFIRMED / IMPLEMENTATION BLOCKED`.

## GAP-ID: OPC-BPEAP-GAP-010

Area: Windows/Android runtime parity.
Current evidence: shared Dart source was inspected.
Missing evidence: current Windows and Android runtime checks for evaluator-visible IRiU, finance, Pregled, and warnings.
Risk if misunderstood: source inspection may be treated as runtime parity proof.
Blocked behavior changes: platform-sensitive evaluator/advisor/Pregled behavior.
Classification: `RUNTIME GAP / TECHNICAL AUDIT REQUIRED`.

## GAP-ID: OPC-BPEAP-GAP-011

Area: Web/sync readiness for evaluator/advisor.
Current evidence: Web guardrails and stop-list block Web/backend/API/sync/storage/payment/licensing/role implementation.
Missing evidence: owner-approved architecture, identity, conflict, role, access, storage, and sync treatment for derived evaluator/advisor outputs.
Risk if misunderstood: current local derived outputs may be promoted into server truth.
Blocked behavior changes: Web/backend/API/sync/storage/payment/licensing/role behavior.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.
