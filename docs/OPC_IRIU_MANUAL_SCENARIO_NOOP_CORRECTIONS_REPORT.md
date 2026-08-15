# OPC IRiU Manual Row, OSNOVNI Future-Effect and SCENARIO No-op Corrections Report

Date: 2026-08-15  
Branch: `task/OPC-IRIU-MANUAL-SCENARIO-NOOP-CORRECTIONS`  
Base: `502fc8e75893b9df6bbbf88411ea60c1b4cb69d7`

## OWNER RUNTIME EVIDENCE

The owner evidence set `C:\Projekti\OPC\OPC v.1\RUNTIME\IRIU1.PNG` through
`IRIU32.PNG` was reviewed. It is classified as current owner runtime evidence
for the observed behavior of the predecessor build, not as root-cause proof.

- `IRIU1`–`IRIU2`: accepted ordered OSNOVNI → applied SCENARIO → manual layout.
- `IRIU3`, `IRIU27`, and `IRIU28`–`IRIU32`: manual row is in the final
  manual/unpredicted partition, but is visibly suppressed/invalid.
- `IRIU4`: the manual amount is absent from the observed FINANSIJE result.
- `IRIU5`–`IRIU16`: SCENARIO change workflow observed as accepted.
- `IRIU17`–`IRIU21`, `IRIU28`–`IRIU32`: existing PREDMET remains unchanged after
  OSNOVNI editing.
- `IRIU22`–`IRIU26`: a newly created PREDMET receives the current OSNOVNI
  package.
- `IRIU17`–`IRIU18`: no prospective-effect notice was visible in the previous
  editor.

These observations establish the runtime acceptance/failure boundary. They do
not identify a source method, flag, query or introducing commit.

## FORENSIC ROOT-CAUSE EVIDENCE

### Manual row

The production path is:

`IriuSegment._dodajRucno` → `IriuRepository.dodajStavku` → `_insertStavka` →
`PredmetIriuTruthService.evaluate` → `FinancialTruthService.buildRobaIUsluge`.

Manual insertion is generic: it creates a `RUCNO_<tip>_<timestamp>` internal
name, ordinary `AKTIVNO` state, `finansijskiUkljuceno=true`,
`scenarioUpravlja=false`, and no SCENARIO provenance. `IriuOrderingService`
already classifies rows outside both package memberships as the final
manual/unpredicted partition; that accepted ordering path was not changed.

The proven defect was in
`OwnerScenarioPolicyKernel.isOperationallyActiveForTruth`. For a complete
PREDMET it returned only `effectiveCategories.contains(internalName)`. An
arbitrary valid manual `RUCNO_*` category is intentionally outside package
membership, so the method returned false. The truth service then rendered the
row suppressed and excluded it from FINANSIJE. A controlled regression test
with `RUCNO_REGRESSION` reproduces and verifies the correction; it is not
hardcoded to `Obrada dokumentacije`.

Git history was inspected (`git log -S` for the manual path and truth policy),
but an exact regression-introducing commit is not provable from the available
history:

`REGRESSION INTRODUCING COMMIT — NOT PROVEN`

### SCENARIO no-op write

The production startup chain is:

`IriuSegment.initState` → `_runScenarioSync` →
`ScenarioModuleRepository.ensureModuleAndDefaults` →
`_ensureOwnerMapDefinitions` → `_repairKnownOwnerMapProtectiveEquipmentGap`.

The old repair selected version-1 default `MAP_NASILNA_*` rows, compared only
category/action pairs against a protective-equipment-excluded shape, and then
unconditionally wrote the owner consequence JSON and a fresh `updated_at`.
For the 36 legitimate `MAP_NASILNA_BOLNICA_*` rows the stored business payload
already equals the owner payload; the write was timestamp-only.

The correction first canonical-compares the complete persisted consequence
payload with the expected owner payload and skips an exact semantic no-op.
The existing narrow legacy fingerprint remains available for a genuinely
defective version-1 default (a disposable `MAP_NASILNA_STAN...` fixture proves
one repair), while `jePodrazumevani=false` user-edited definitions remain
untouched. A second initialization after repair is a true no-op.

## IMPLEMENTED CORRECTION

- `owner_scenario_policy_kernel.dart`: unknown/manual categories remain active
  for complete PREDMETs; known condition-managed categories still follow owner
  policy.
- `scenario_module_repository.dart`: full canonical payload equality guard
  prevents no-op writes and preserves `updated_at`.
- `scenario_module_screen.dart`: OSNOVNI editor now persistently displays:
  `Izmene OSNOVNOG PAKETA primenjuju se samo na nove PREDMETE. Postojeći PREDMETI ostaju nepromenjeni.`
- Added focused manual-row, no-op/legacy-repair and notice regression tests.
- Added the runtime-observation/root-cause evidence rule to
  `docs/OPC_TECHNICAL_EXECUTION_STANDARD.md` and
  `docs/templates/OPC_TASK_TEMPLATE.md`.

No package-ordering logic, owner kernel definitions, PREDMET snapshots,
canonical database or unrelated business data was changed.

## POST-CORRECTION ACCEPTANCE

### Focused tests

- `test/iriu_manual_row_regression_test.dart` — PASS.
- `test/scenario_startup_noop_timestamp_mutation_characterization_test.dart` —
  PASS (correct-state no-op; genuine legacy repair once and stable).
- `test/scenario_module_screen_test.dart` — PASS (notice visible).
- `test/owner_scenario_policy_kernel_test.dart` — PASS.
- `test/iriu_catalog_basic_category_policy_test.dart` — PASS.

### Full validation

- `flutter analyze` — PASS, no issues (ran 322.7 seconds).
- Full machine-readable `flutter test --machine --concurrency=1` — PASS;
  `done.success=true`, 503 `testDone` events, 0 failures, 9 skips (final run
  after all source/test edits).
- Windows release build — PASS: `build/windows/x64/runner/Release/OPC.exe`.
- Android release build — PASS: `build/app/outputs/flutter-apk/app-release.apk`
  (74.7 MB).

### Disposable Windows startup lane

The release artifact was built with `BUILD_VARIANT=WINDOWS_TEST` and an
isolated `OPC_MIGRATION_TEST_IRIU_MANUAL_SCENARIO_NOOP_20260815.sqlite` copy.
The real Windows application opened that copy. After a second normal startup,
the disposable database contained 1,021 scenario definitions and an external
SQLite comparison proved:

`business payload before == business payload after`  
`updated_at before == updated_at after`

for every definition. The raw SQLite file hash changed because the runtime
performed ordinary file-level SQLite bookkeeping, but no scenario business
row or timestamp changed.

Computer Use exposed the release app's login accessibility tree, but the
Flutter window did not expose screenshot geometry, so UI automation could not
reliably perform the login/manual-row/notice clicks. Those real-product UI
claims are therefore **NOT PROVEN by this run**; the focused widget tests,
source path and disposable startup evidence remain valid evidence, but are not
reported as a fabricated Windows UI PASS.

## VERDICTS

| Claim | Verdict |
|---|---|
| IRiU package ordering | PASS (predecessor runtime accepted; preserved) |
| Manual partition placement | PASS |
| Manual row business validity | PASS in controlled production-path tests; Windows UI replay NOT PROVEN |
| Manual row financial participation | PASS in controlled production-path tests; Windows UI replay NOT PROVEN |
| SCENARIO change workflow | PASS (preserved predecessor behavior/tests) |
| Existing PREDMET non-retroactivity | PASS (preserved) |
| New PREDMET current-package application | PASS (preserved) |
| OSNOVNI future-effect notice | PASS in widget test; Windows UI replay NOT PROVEN |
| SCENARIO initialization idempotency | PASS |
| Legacy repair behavior | PASS — one supported repair, then stable no-op |
| Runtime-evidence methodology documented | PASS |
| Canonical DB | UNCHANGED by this task; only a disposable copy was opened by runtime |
| Windows runtime acceptance | PARTIAL — startup/idempotency PASS; UI interaction replay NOT PROVEN due capture limitation |

The implementation is source/test/build complete. A strict final product PASS
for the Windows UI acceptance gate requires a later runtime session with a
working screenshot/input geometry channel; no unsupported claim is made here.
