# OPC SCENARIO MODULE LOCK

Status: current governance baseline. This document locks the accepted SCENARIO
module; it does not authorize a production implementation change.

## Lock identity

- Locked module: `SCENARIO`
- Locked production source SHA: `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`
- Lock branch: `task/OPC-SCENARIO-MODULE-LOCK`
- Lock documentation SHA: recorded by the publication commit of this document
- Lock date: `2026-08-16`
- Predecessor: `task/OPC-SCENARIO-FINAL-SPACING-CORRECTION-BEFORE-LOCK`
- Predecessor report: `docs/OPC_SCENARIO_FINAL_SPACING_CORRECTION_REPORT.md`
- Predecessor documentation HEAD: `c8d5f6d45acc8ec4363e9075dd0a5e25d534ae36`
- Owner runtime: `WINDOWS INTERACTIVE RUNTIME ACCEPTANCE — PASS`; `ANDROID NARROW INTERACTIVE ACCEPTANCE — PASS`

The locked source SHA is distinct from the later documentation SHA. No source,
test or business-logic file is changed by this lock task.

## Locked business and data contract

- `PREDMET` remains the master business truth and SCENARIO remains a derivative,
  operational module reached through `MODULI → SCENARIO`.
- SCENARIO derives from current PREDMET conditions and applies reusable,
  editable definitions. An applied scenario is PREDMET-scoped.
- The generic IRiU invariant remains:

  ```text
  ordered OSNOVNI PAKET
    -> ordered applied SCENARIO PAKET
    -> manual/unpredicted items
  ```

- `OSNOVNI PAKET` here is an editable goods/services composition block, not the
  abandoned native licensing terms `Osnovni/Srednji/Potpuni`.
- Package membership and configured order within each package are authoritative;
  package contents may change by user, scenario and time. Concrete item names,
  counts, persisted `redosled`, provenance sequence, current output and golden
  fixtures are not business ordering authority.
- Existing PREDMET snapshots and historical/current non-retroactivity remain
  protected. Later SCENARIO definition edits do not rewrite an existing PREDMET
  snapshot without the explicit application flow.
- Manual/unpredicted IRiU rows remain protected from SCENARIO synchronization.
- Existing item/status semantics, stable KATALOG identity resolution, and the
  PREDMET → IRiU → downstream projections remain unchanged.

## Locked UI and terminology contract

- Four compact entry cards remain present: `OSNOVNI PAKET`, `SCENARIJI`,
  `NOVI SCENARIO`, `OTVORENI PREDMETI`.
- SCENARIJI management and OTVORENI PREDMETI detail remain bounded contexts.
- Selected-PREDMET view remains PREDMET-scoped and exposes applied package
  information; reusable scenario editing is not exposed from that context.
- Accepted preview headings are `USLOVI SCENARIJA` and `PRIMENJENE STAVKE`.
- The false wizard-like chip sequence (`1 USLOVI / 2 STAVKE / 3 PREGLED /
  4 ČUVANJE`) remains absent.
- Selected-PREDMET correction wording remains:
  `Korekcije ovog PREDMETA vrše se izmenom njegovih stavki.`
- Official terminology remains `preminulo lice`, `preminulog lica` and
  `Spremanje preminulog lica`.
- The accepted final spacing between the new-scenario `USLOVI` heading and the
  first `UZROK SMRTI` field remains protected.
- Windows wide and Android narrow responsive behavior are owner-accepted and
  must remain behaviorally equivalent.

## Change control

```text
SCENARIO LOCKED — NO PRODUCTION CHANGE WITHOUT OWNER-AUTHORIZED UNLOCK OR PROVEN REGRESSION CORRECTION
```

A future task crosses the lock boundary only when it explicitly records one of:

1. an owner-authorized unlock for a defined defect or change;
2. a proven regression caused by another authorized change; or
3. an authoritative new business-policy decision affecting SCENARIO.

Silent SCENARIO drift is forbidden. This lock does not authorize backup or
restore-point creation; that is the next separate task after owner acceptance.

## Regression contract

The repository contains 33 SCENARIO-relevant executable test files plus the
`scenario_map_owner_golden.json` fixture. No test is deleted or rewritten.

### Tier 1 — task-targeted

Run tests for the code actually changed. SCENARIO tests are not automatically
required when an unrelated task has no credible SCENARIO dependency.

### Tier 2 — SCENARIO locked regression contract

This is the smallest defensible file-level set covering the locked public
contract. Run these existing files when SCENARIO or a listed dependency is
affected:

| Existing test | Locked invariant protected |
| --- | --- |
| `test/scenario_package_contract_test.dart` | PREDMET-condition matching, base-package preservation and scenario suppression boundary |
| `test/scenario_runtime_single_truth_test.dart` | one SCENARIO source for the base package, package disjointness and applied price snapshot |
| `test/scenario_reconciliation_contract_test.dart` | deterministic add/remove reconciliation, provenance ownership and manual-row protection |
| `test/scenario_runtime_application_test.dart` | stale scenario changes wait for explicit user confirmation |
| `test/predmet_scenario_application_contract_test.dart` | PREDMET open-state/application identity gate and no-op/non-retroactive application |
| `test/iriu_ordering_partition_test.dart` | package partitions, configured OSNOVNI order and manual final partition |
| `test/iriu_shared_derived_ordering_test.dart` | production-shaped shared projection and configured package order independent of stale persisted rank |
| `test/iriu_manual_row_regression_test.dart` | manual IRiU activity/financial semantics and final partition |
| `test/scenario_module_repository_test.dart` | editable package persistence, reusable definitions and repository ownership boundary |
| `test/scenario_module_screen_test.dart` | principal SCENARIO entry, accepted headings and official display terminology |
| `test/scenario_module_narrow_responsive_test.dart` | compact cards, preview headings, no wizard chips and final new-scenario spacing |
| `test/scenario_open_predmet_bounded_detail_test.dart` | bounded selected-PREDMET context, protected correction wording and package semantics |

These 12 files are a regression contract, not a new golden business policy.
Tests in `scenario_module_screen_test.dart` that are explicit opt-in skips
remain skips; they are not deleted and are not silently promoted to mandatory
runtime acceptance.

### Tier 3 — full/deep regression

All existing tests remain available. Use the full OPC suite, and where useful
the deeper SCENARIO groups, for:

- explicit SCENARIO unlock or production SCENARIO change;
- shared infrastructure with credible SCENARIO impact;
- PREDMET truth, snapshot, lifecycle or reconciliation changes;
- KATALOG stable-ID/display-resolution changes;
- database schema/migration or JSON transfer changes;
- broad cross-module refactors;
- release candidates, major milestones, uncertain impact or owner request.

Uncertainty defaults upward to Tier 3. Locking does not change the project rule
into “never run full flutter test”.

## Dependency trigger matrix

| Future area changed | Minimum tier | Reason |
| --- | --- | --- |
| SCENARIO screen, repository, evaluator, definitions or reconciliation | Tier 2; Tier 3 for broad changes | Direct contract path |
| PREDMET conditions, snapshots, lifecycle or application confirmation | Tier 2; Tier 3 for architecture changes | Derivation and non-retroactivity |
| IRiU synchronization, ordering or manual-row ownership | Tier 2; Tier 3 for shared pipeline changes | Downstream projection and package invariant |
| KATALOG stable IDs, display-name resolution or selection snapshots | Tier 2; Tier 3 for schema/identity changes | Scenario consequences resolve through KATALOG |
| Shared responsive UI infrastructure | Tier 2 | Windows/Android SCENARIO structural parity |
| Database/migrations, JSON transfer, backup/restore or identity | Tier 3 | Cross-module data continuity risk |
| Unrelated module with no credible dependency path | Tier 1 | SCENARIO lock is not a blanket test tax |

## Status

`SCENARIO MODULE — LOCKED`

The next authorized project stage is a separate owner-approved fresh verified
backup and restore-point task. It is not performed here.
