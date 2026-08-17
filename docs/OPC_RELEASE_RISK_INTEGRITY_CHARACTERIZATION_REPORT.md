# OPC Release-Risk Integrity Characterization Report

## Scope and disposition

This is a characterization-first, read-only release-risk wave at baseline `a468591412a9703f1cc2d9b11fb4eb6336d757ba` on `task/OPC-SCENARIO-MODULE-LOCK`. No production behavior, schema, dependency, platform behavior, SCENARIO, canonical database, or pseudocode body was changed. No defect was fixed. A failing or inconclusive command is recorded as evidence, never as authorization to repair.

The required contract areas were separated into source/test evidence, runtime evidence, and owner-observed evidence. The targeted lifecycle and database-lane suites passed. Current source proves that the Windows runner has no process-singleton guard, so the required single-instance contract is a proven defect at source level. Current-tip analyzer and canonical migration-recovery execution were tooling-inconclusive; those gaps have bounded successors.

## Evidence baseline

| Evidence | Result |
|---|---|
| Branch / HEAD / origin | `task/OPC-SCENARIO-MODULE-LOCK` / `a468591412a9703f1cc2d9b11fb4eb6336d757ba` / same remote SHA |
| Targeted migration selector | 9 passed (`test/migration_test_database_selector_test.dart`) |
| PREDMET completion | 5 passed (`test/predmet_completion_state_characterization_test.dart`) |
| PREDMET lifecycle/referential | 5 passed (`test/predmet_lifecycle_referential_characterization_test.dart`) |
| PREDMET hard-delete coordinator | 4 passed (`test/predmet_hard_delete_lifecycle_coordinator_test.dart`) |
| Full backup/restore coordinator | 8 passed (`test/full_backup_restore_lifecycle_coordination_test.dart`) |
| Analyzer | `INCONCLUSIVE — timed out after 184 s`; no source change; timeout is not PASS |
| Canonical migration-recovery suite | `INCONCLUSIVE — timed out/tooling native-asset instability`; no canonical access was performed |
| Canonical disposable-copy check | PASS: copy SHA equals source SHA; SQLite `integrity_check=ok`; `user_version=27`; source SHA unchanged after check |
| Historical Windows runtime | Existing reports record canonical path, cold/reopen behavior, and approximately 8–9 s login / slow exit; no new production launch was performed in this wave |

## Primary decisions

1. **Windows single-instance guard — DEFECT PROVEN.** `windows/runner/main.cpp` enters `wWinMain`, creates a `FlutterWindow`, and runs the message loop without a named mutex, lock, second-launch handoff/rejection, or installer-running-app coordination. `win32_window.cpp` likewise contains no guard. The required release contract therefore is not implemented in the current source. A duplicate-process runtime launch was not attempted because production launch would touch the canonical database.
2. **Canonical production database path — CONTRACT CONFIRMED.** Production and Windows variants resolve `kDatabaseName` to `opc_v4_release`; normal `_openConnection()` calls `driftDatabase(name: kDatabaseName)`.
3. **Test-lane canonical protection — CONTRACT CONFIRMED.** The Windows test selector requires an absolute existing `.sqlite` copy labelled `MIGRATION_TEST`, rejects `opc_v4_release.sqlite`, rejects filesystem aliases of the canonical file, and validates the SQLite header. Nine selector tests passed.
4. **Canonical content preservation in this wave — CONTRACT CONFIRMED for the disposable-copy procedure; current-tip production no-op migration remains unexercised.** The canonical file was not opened by the application. A read-only disposable copy passed integrity and matched the pre/post canonical SHA.
5. **PREDMET lifecycle — CONTRACT CONFIRMED for tested repository behavior.** Explicit `OTVOREN→ZATVOREN→ZAVRŠEN` behavior, invalid-transition rejection, and final-state immutability passed the focused suite. Automatic completion remains absent as required by current authority.
6. **Referential behavior — CONTRACT CONFIRMED for tested synthetic flows, with semantic acceptance still bounded.** Explicit child cleanup, anonymization retention, hard-delete coordination, and full-restore stale-state cleanup passed. SQLite `foreign_keys` is currently `0`; referential safety is implemented through explicit coordination and must remain protected by acceptance evidence.
7. **Replacement-derived-state policy — INCONCLUSIVE.** Current tests demonstrate that replacement on a local ID retains stale reminder/PARTE state. The behavior is observable; its release acceptance depends on an explicit business meaning for derived state and therefore receives a successor rather than an invented oracle.
8. **Windows current-tip startup/exit and Android physical parity — INCONCLUSIVE.** Existing runtime evidence is retained as historical baseline; current-tip Windows launch and Android device evidence were not run in this wave.

## Required status

`RELEASE-RISK INTEGRITY CHARACTERIZATION PASS WITH DEFECTS — CONTRACT VIOLATIONS PROVEN AND BOUNDED SUCCESSORS DEFINED — READY FOR LOGOS REVIEW`

