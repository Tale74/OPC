# OPC Business Policy Evaluator Advisor Pregled Characterization

Status: docs-only characterization.

Base commit: `ea9ba1a96ba7c8f6db43921cb5421d71f3c82a03`

This document records current source-confirmed behavior for the business policy evaluator, related IRiU truth/advisor-like outputs, and `Pregled i potvrda`. It does not authorize source, test, database, schema, migration, UI, PDF, JSON, import/export, backup/restore, evaluator, IRiU, STANJE ROBE, finance, entitlement, role, Web, sync, storage, payment, licensing, runtime, or behavior changes.

## 1. Evidence Basis

Primary source evidence:

- `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart`
- `lib/features/predmeti/core_v2/business_policy/business_policy_models.dart`
- `lib/features/predmeti/core_v2/business_policy/business_scenario_id.dart`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/core_v2/models/iriu_truth_models.dart`
- `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart`
- `lib/features/predmeti/core_v2/services/blok2_iriu_lifecycle_service.dart`
- `lib/features/predmeti/core_v2/services/mesto_smrti_iriu_lifecycle_service.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
- `lib/features/predmeti/presentation/segments/finansije_segment.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `test/business_policy_iriu_critical_scenarios_test.dart`

Supporting documentation evidence:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_CHARACTERIZATION_EVIDENCE_FOUNDATION.md`
- `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`
- `docs/OPC_CHARACTERIZATION_GAP_REGISTER.md`
- `docs/OPC_CHARACTERIZATION_BEFORE_CHANGE_RULES.md`
- `docs/OPC_PREDMET_LIFECYCLE_IDENTITY_VERSION_CHARACTERIZATION.md`
- `docs/OPC_PREDMET_OWNER_REVIEW_QUEUE.md`
- `docs/OPC_LOGOS_KNOWLEDGE_BASE.md`
- `docs/OPC_MODULE_RELATIONSHIP_MAP.md`
- `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL / DOCUMENTED POLICY`.

## 2. Current Evaluator Object

`BusinessPolicyEvaluator` is the current evaluator class. It resolves a scenario from `PredmetiData.businessScenarioId`, falls back to `BusinessScenarioId.defaultFuneralCeremonyPolicy`, builds `PredmetBusinessPolicyInput.fromPredmet`, and returns a `PredmetBusinessPolicySnapshot`.

The only current scenario id in `BusinessScenarioId.values` is `default_funeral_ceremony_policy`. Unknown scenario strings fall back to the default scenario.

Classification: `SOURCE-CONFIRMED`.

## 3. Evaluator Inputs

The evaluator reads these PREDMET facts through `PredmetBusinessPolicyInput`:

- local PREDMET id;
- `brojPredmeta`;
- `mestoSmrti`;
- `uzrokSmrti`;
- `vrstaCeremonije`;
- `groblje`;
- `tipGroblja`;
- `tipGrobnogMesta`;
- `sahranaVanSrbije`;
- `docekPosmrtnihOstataka`.

The evaluator does not read package level, license state, payment status, PDF state, JSON transfer state, STANJE ROBE state, Web state, or role policy.

Classification: `SOURCE-CONFIRMED`.

## 4. Evaluator Outputs

The evaluator returns a `PredmetBusinessPolicySnapshot` with:

- resolved policy descriptor;
- normalized death place;
- cremation flag;
- hospital-death flag;
- local-cemetery flag;
- city-cemetery flag;
- international-case flag;
- reception-of-remains flag;
- cause-of-death override flag;
- biohazard-precondition flag.

The evaluator output is a derived snapshot. It is not persisted by the evaluator and does not directly mutate PREDMET, IRiU, finance, STANJE ROBE, PDF, JSON, entitlement, role, Web, sync, storage, payment, or licensing state.

Classification: `SOURCE-CONFIRMED`.

## 5. Rule Source And Rule Type

Current evaluator and IRiU consequence rules are hard-coded Dart source rules, not external rule documents, database-loaded rule tables, package-tier rules, or Web/backend rules.

`IriuTruthRules` hard-codes managed categories, managed policy kinds, death-place categories, Blok 2 categories, derivative-only document-scoped categories, operational activation, recommendation, biohazard, financial inclusion, derivative exclusions, and death-place normalization.

Classification: `SOURCE-CONFIRMED`.

## 6. IRiU Truth Service Bridge

`PredmetIriuTruthService` composes `BusinessPolicyEvaluator`. It evaluates a PREDMET and stored IRiU rows, asserts alignment between the policy snapshot and legacy IRiU conditions, and returns `PredmetIriuTruthSnapshot`.

For each row it derives:

- stored row status;
- active or suppressed operational state;
- recommendation state;
- biohazard flag;
- financial state;
- derivative exclusions;
- manual deletion permission;
- user-resolution requirement;
- explanatory reasons.

The service is a classifier. It does not directly persist row changes.

Classification: `SOURCE-CONFIRMED`.

## 7. IRiU Lifecycle Planning

`Blok2IriuLifecycleService` and `MestoSmrtiIriuLifecycleService` use `PredmetIriuTruthService` to build plans.

Current source behavior:

- current-state plans list categories to insert when source rules require a category that is not already present and has not been dismissed;
- condition-change plans identify conflicts when a previously active managed row becomes inactive and requires user resolution;
- Blok 2 condition changes separate additions requiring confirmation from immediate current-state inserts;
- dismissed categories are respected for auto-managed additions.

The lifecycle services plan consequences; the plan itself is not a complete human advisor.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL`.

## 8. Source-Confirmed Scenario Rules

Current source rules include:

- death place `STAN`, `DOM ZA STARE`, `ULICA / JAVNO MESTO`, or `DRUGO` activates death-place service categories;
- death place `BOLNICA` activates `prevozDoGroblja` from the death-place managed group;
- cremation suppresses Blok 2 `limeniUlozak` and `lemovanje` recommendation;
- non-cremation with `GROBNICA` recommends `limeniUlozak` and `lemovanje`;
- cause override `NASILNA`, `ZARAZNA`, or `NEDEFINISANA` recommends `limeniUlozak` and `lemovanje`;
- local cemetery type recommends `prevozSprovoda`;
- international case activates international transport/documentation/balsamovanje rows;
- reception of remains activates cargo costs;
- infectious non-hospital death activates the biohazard precondition for `spremanjePokojnika`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL`.

## 9. Current UI Visibility

IRiU UI receives truth rows in `iriu_segment.dart` and passes recommendation labeling to `IriuRowTile`. `IriuRowTile` also displays STANJE ROBE unresolved-consequence warning text when the stock consequence path provides it.

Finance UI uses `PredmetIriuTruthService` through `finansije_segment.dart` to derive the active positive IRiU basis used by `FinancialTruthService.buildRobaIUsluge`.

Current `Pregled i potvrda` does not display the evaluator snapshot, complete advisor checklist, full warning taxonomy, IRiU truth matrix, or full business change-log overview. It displays status, `Verzija predmeta`, saved/unsaved working state, and lifecycle action buttons.

Classification: `SOURCE-CONFIRMED / IMPLEMENTATION GAP`.

## 10. Pregled I Potvrda Boundary

`Pregled i potvrda` is a review and lifecycle action point. Current source displays:

- `Status`;
- `Verzija predmeta`;
- `Radno stanje`;
- save action when open;
- close action when open;
- edit/reopen action when closed.

It writes back only through lifecycle action handlers such as save, close, and reopen. It is not a separate evaluator, advisor, finance, IRiU, Web, sync, PDF, JSON, entitlement, payment, licensing, role, or STANJE ROBE authority.

Classification: `SOURCE-CONFIRMED`.

## 11. Advisor / Guidance Status

A separate complete advisor engine was not found in source. The current source contains:

- evaluator condition flags;
- IRiU row truth states;
- recommendation states for selected managed categories;
- lifecycle plan conflicts and confirmation lists;
- finance derivation from IRiU truth;
- STANJE ROBE warnings in IRiU row display when stock consequences exist.

The following complete advisor outputs were not found as current implemented behavior:

- consolidated ceremony checklist;
- owner-approved warning taxonomy;
- PIO/refund advisor;
- JKP/payer advisor;
- complete document requirement graph;
- complete STANJE ROBE consequence contract in `Pregled i potvrda`;
- full review advisor in `Pregled i potvrda`.

Classification: `PARTIALLY IMPLEMENTED / POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## 12. Entitlement / Package Boundary

`OpcEntitlementPolicy.isModuleAvailable` treats `OpcModule.businessPolicyScenario` as always available together with core modules. STANJE ROBE, advanced PARTA, and CITULJE add-ons are separately gated. Document actions and JSON transfer are gated through document/action availability checks.

Current source evidence does not show the evaluator or business policy scenario being premium-only, luxury-only, Web-only, payment-only, or role-only. Package gates can affect surrounding modules, but they do not make evaluator output a package-owned truth source.

Classification: `SOURCE-CONFIRMED`.

## 13. Persistence Boundary

The evaluator snapshot is derived in memory. `Predmeti.businessScenarioId` is persisted as PREDMET metadata, and IRiU rows are persisted separately as related rows. Downstream services may plan or apply row consequences, but evaluator snapshot fields and IRiU truth-row reasons are not persisted as independent business-truth tables in the inspected source.

Classification: `SOURCE-CONFIRMED`.

## 14. Tests

`test/business_policy_iriu_critical_scenarios_test.dart` confirms selected Blok 2 policy consequences:

- `DOM ZA STARE` / natural death / city cemetery / existing `GROBNICA` requires `limeniUlozak` and `lemovanje`;
- non-cremation `GROBNICA` requires `limeniUlozak` and `lemovanje`;
- `NASILNA`, `ZARAZNA`, and `NEDEFINISANA` keep `limeniUlozak` and `lemovanje` required for `GROB`;
- cremation excludes `limeniUlozak` and `lemovanje`;
- `GROBNICA` to `GROB` transition requires removal confirmation;
- `GROB` to `GROBNICA` transition requires add confirmation;
- dismissed Blok 2 categories are not silently re-added on transition.

The tests cover critical downstream IRiU lifecycle behavior, not the whole evaluator snapshot, advisor UI, Pregled UI, finance matrix, package matrix, or runtime parity.

Classification: `TEST-CONFIRMED PARTIAL / TEST GAP`.

## 15. Windows / Android / Web Boundary

The inspected evaluator, IRiU truth, finance, and Pregled logic is shared Dart source. This characterization did not execute Windows or Android runtime parity checks.

No Web runner, backend, API, sync, storage, payment, licensing, or role implementation is selected or authorized by this characterization.

Classification: `SOURCE-CONFIRMED / RUNTIME GAP / IMPLEMENTATION BLOCKED`.

## 16. Control Summary

Current evaluator behavior is a partial deterministic policy kernel that derives flags from PREDMET facts and feeds IRiU truth, lifecycle planning, finance basis, and selected UI labels/warnings. Current `Pregled i potvrda` remains a lifecycle/review surface, not a complete advisor. Complete advisor guidance remains an implementation gap and owner-review area.

Classification: `PASS WITH OWNER REVIEW QUEUE`.
