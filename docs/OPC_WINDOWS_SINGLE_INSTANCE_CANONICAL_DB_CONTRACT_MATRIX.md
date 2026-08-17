# Windows Single-Instance / Canonical Database Contract Matrix

| Contract | Source evidence | Test/runtime evidence | Decision | Successor |
|---|---|---|---|---|
| One process owns the Windows UI/database lane | `windows/runner/main.cpp` has no mutex, named pipe, lock, or second-launch branch | No duplicate production launch attempted; historical plan records implementation absent | **DEFECT PROVEN** | Implement and runtime-accept named singleton, second-launch behavior, and installer coordination in a successor task |
| Production path is canonical | `app_config.dart`: Windows/production `opc_v4_release`; `database.dart`: `driftDatabase(name: kDatabaseName)` | Canonical path recorded by prior runtime evidence | **CONTRACT CONFIRMED** | Reverify on each release candidate |
| Test lane cannot select canonical file | `migration_test_database_selector.dart` requires absolute `MIGRATION_TEST` `.sqlite`, rejects canonical filename and aliases, validates header | 9 selector tests passed | **CONTRACT CONFIRMED** | Keep selector suite release-gated |
| Disposable-copy identity and integrity | Read-only copy SHA matched source; SQLite integrity check `ok`, schema user version 27 | Copy removed after check; canonical SHA unchanged | **CONTRACT CONFIRMED** | Repeat before migration/recovery rehearsal |
| No unauthorized current-tip migration/write | Production app was not opened in this wave; canonical mutation forensic report records prior timestamp-only scenario repair | Current-tip migration-recovery test timed out/tooling-inconclusive | **INCONCLUSIVE** | Run disposable current-tip migration/recovery rehearsal and compare canonical pre/post hash |
| Second-launch safety / no DB race | No source-level ownership guard | Runtime duplicate launch not attempted to protect canonical DB | **DEFECT PROVEN at contract level; runtime race unmeasured** | Execute two-launch disposable-lane acceptance after singleton successor exists |

