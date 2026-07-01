# OPC Business Policy Evaluator Advisor Pregled Coverage Matrix

Status: docs-only characterization coverage matrix.

Base commit: `ea9ba1a96ba7c8f6db43921cb5421d71f3c82a03`

This matrix records evidence for current business policy evaluator, advisor-like outputs, IRiU truth bridge, finance use, package boundary, and `Pregled i potvrda` behavior. It does not authorize implementation or test changes.

## COVERAGE-ID: OPC-BPEAP-001

Behavior: evaluator scenario resolution.
Source files: `business_policy_evaluator.dart`; `business_scenario_id.dart`.
Existing tests: no direct evaluator scenario test found.
Evidence: empty or unknown `businessScenarioId` resolves to `default_funeral_ceremony_policy`; only one scenario id is currently listed.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: scenario fallback must not be overclaimed as a multi-scenario advisor.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-002

Behavior: evaluator input extraction from PREDMET.
Source files: `business_policy_models.dart`; `business_policy_evaluator.dart`.
Existing tests: indirect Blok 2 tests.
Evidence: evaluator reads death place/cause, ceremony, cemetery/grob, international and reception flags, plus PREDMET id and number.
Current evidence level: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL`.
Protected boundary: evaluator reads PREDMET facts; it does not read package/payment/Web state.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-003

Behavior: evaluator snapshot derivation.
Source files: `business_policy_evaluator.dart`; `business_policy_models.dart`.
Existing tests: indirect Blok 2 tests.
Evidence: snapshot derives normalized death place, cremation, hospital death, cemetery flags, international case, reception of remains, cause override, and biohazard precondition.
Current evidence level: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL`.
Protected boundary: snapshot is derived; no direct persistence or mutation.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-004

Behavior: IRiU truth service uses evaluator.
Source files: `predmet_iriu_truth_service.dart`; `iriu_truth_models.dart`; `iriu_truth_rules.dart`.
Existing tests: `test/business_policy_iriu_critical_scenarios_test.dart` for selected downstream consequences.
Evidence: truth service evaluates each stored IRiU row into active/suppressed, recommended, biohazard, financial, derivative, manual-deletion, user-resolution, and reasons.
Current evidence level: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL`.
Protected boundary: truth service classifies; lifecycle services or repositories own later writes.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-005

Behavior: hard-coded IRiU rule source.
Source files: `iriu_truth_rules.dart`.
Existing tests: selected Blok 2 tests.
Evidence: managed policies, death-place groups, Blok 2 groups, operational state, recommendation, biohazard, financial inclusion, derivative exclusions, and normalization are source-coded.
Current evidence level: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL`.
Protected boundary: source rules are not external package, payment, or Web rules.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-006

Behavior: Blok 2 lifecycle planning.
Source files: `blok2_iriu_lifecycle_service.dart`; `iriu_truth_rules.dart`.
Existing tests: `test/business_policy_iriu_critical_scenarios_test.dart`.
Evidence: current-state inserts and condition-change conflicts/add confirmations are planned from truth service and dismissed categories.
Current evidence level: `SOURCE-CONFIRMED / TEST-CONFIRMED`.
Protected boundary: user-dismissed categories must not be silently re-added by condition-change planning.
Web/sync relevance: medium.

## COVERAGE-ID: OPC-BPEAP-007

Behavior: death-place lifecycle planning.
Source files: `mesto_smrti_iriu_lifecycle_service.dart`; `iriu_truth_rules.dart`.
Existing tests: no direct death-place lifecycle test found in this characterization.
Evidence: current-state and condition-change plans use death-place managed categories and user-resolution conflicts.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: death-place service rows must remain PREDMET-condition derived and user-resolution aware.
Web/sync relevance: medium.

## COVERAGE-ID: OPC-BPEAP-008

Behavior: UI visibility of IRiU recommendations and stock warnings.
Source files: `iriu_segment.dart`; `iriu_row_tile.dart`.
Existing tests: no direct UI test for IRiU recommendation labels found.
Evidence: IRiU truth rows are passed to row tiles, recommendation labels are supplied, and STANJE ROBE warning display exists for unresolved stock consequences.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: current labels/warnings are not a complete advisor taxonomy.
Web/sync relevance: medium.

## COVERAGE-ID: OPC-BPEAP-009

Behavior: finance uses IRiU truth basis.
Source files: `finansije_segment.dart`; `financial_truth_service.dart`; `iriu_truth_models.dart`.
Existing tests: no full finance regression suite found.
Evidence: finance resolves `robaIUsluge` through `PredmetIriuTruthService` and `FinancialTruthService`.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: finance total must stay derived from active positive IRiU truth, not visual check state alone.
Web/sync relevance: medium.

## COVERAGE-ID: OPC-BPEAP-010

Behavior: `Pregled i potvrda` current display and actions.
Source files: `predmet_screen.dart`; `predmeti_repository.dart`.
Existing tests: no direct Pregled review/advisor test found.
Evidence: review displays status, version, saved/unsaved state, and save/close/edit actions.
Current evidence level: `SOURCE-CONFIRMED / IMPLEMENTATION GAP / TEST GAP`.
Protected boundary: current Pregled is not a full advisor, warning taxonomy, or change-log overview.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-011

Behavior: entitlement/package boundary for evaluator.
Source files: `opc_entitlement_policy.dart`.
Existing tests: local license/parser tests exist, but no direct evaluator entitlement test found.
Evidence: `OpcModule.businessPolicyScenario` is always available with core modules; surrounding document, JSON, STANJE ROBE, PARTA, and CITULJE capabilities have separate gates.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: evaluator must not become premium-only or payment-owned by accidental gating.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-012

Behavior: complete advisor/guidance engine.
Source files: no complete advisor source found; related evaluator, IRiU, finance, stock, and Pregled files inspected.
Existing tests: none found.
Evidence: source contains partial evaluator and IRiU recommendation/conflict behavior, but not a consolidated advisor checklist or warning taxonomy.
Current evidence level: `POLICY EXISTS / IMPLEMENTATION NOT FOUND`.
Protected boundary: do not represent current partial rules as a complete advisor.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-013

Behavior: Windows/Android runtime parity.
Source files: shared Dart source.
Existing tests: no current runtime parity execution in this characterization.
Evidence: source is shared; runtime parity was not executed.
Current evidence level: `SOURCE-CONFIRMED / RUNTIME GAP`.
Protected boundary: source inspection is not runtime parity proof.
Web/sync relevance: high.

## COVERAGE-ID: OPC-BPEAP-014

Behavior: Web/sync readiness for evaluator/advisor outputs.
Source files/docs: current local source plus Web readiness guardrails and stop-list.
Existing tests: no Web/sync tests.
Evidence: no Web runner/backend/API/sync/storage/payment/licensing/role architecture is implemented or selected.
Current evidence level: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.
Protected boundary: evaluator/advisor outputs remain local derived facts until owner-approved architecture exists.
Web/sync relevance: critical.
