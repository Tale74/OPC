# OPC Phase 11 — PREDMET SCENARIO application contract report

## Scope

This bounded slice adds a pure PREDMET-side gate for applying a selected
SCENARIO assignment. It validates:

- only `OTVOREN` PREDMET may receive an assignment;
- assignment module/scenario/version must match the reconciliation plan;
- a new or changed assignment requires explicit user confirmation;
- an unchanged snapshot with no reconciliation changes is a no-op.

The contract does not write the PREDMET snapshot, IRIU rows, PARTE,
PODSETNIK, STANJE ROBE or any carrier. SCENARIO remains a rule engine; PREDMET
remains the authority that will later commit the assignment.

## Files

- `lib/features/predmeti/core_v2/scenario/predmet_scenario_application_contract.dart`
- `test/predmet_scenario_application_contract_test.dart`
- `docs/OPC_MODULE_BOUNDARIES_AND_AUTHORITY_AUDIT.md`

## Validation

- Focused tests: PASS — 4/4.
- Combined SCENARIO/PREDMET contract regression set: PASS — 41/41.
- `flutter analyze --no-pub`: PASS — no issues found.
- Windows/Android build and runtime: intentionally not run.
- No database/carrier/runtime write was performed.

## Safety evidence

- Base SHA: `52fc45039dea403a09ae5e393951724e880988e3`
- Task branch: `task/OPC-PHASE11-PREDMET-SCENARIO-APPLICATION-CONTRACT`
- Backup: `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE11_PREDMET_SCENARIO_APPLICATION_CONTRACT_20260802.zip`
- Backup SHA-256: `F49280A5DA9A02FC3CA372CB2EBEF1CFFFA5536AD5F946D3FB4BABB5122790DF`
- Restore marker: `docs/tasks/OPC_RESTORE_POINT_PHASE11_PREDMET_SCENARIO_APPLICATION_CONTRACT_20260802.md`

## Residual boundary

The next task may add the explicit PREDMET transaction only after proving
snapshot persistence, deterministic IRIU materialization, stale scenario-row
removal, user notice and rollback. It must preserve module boundaries and the
existing PREDMET → IRIU flow.
