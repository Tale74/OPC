# OPC Windows Singleton / Second-Launch Integrity

## Scope and baseline

Bounded implementation branch `task/OPC-WINDOWS-SINGLETON-SECOND-LAUNCH-INTEGRITY`, parent `db6c05be6f91c695c78f8cd0df36357123c70599`. This task addresses only the proven Windows process-ownership defect. The canonical database is never used as a mutable runtime target.

## Startup order reconstructed before implementation

1. `windows/runner/main.cpp:wWinMain` is the native process entry.
2. **Singleton ownership acquisition** is inserted immediately at the first executable statement, before console attachment, COM, Flutter project creation, window creation, engine/plugin initialization, or Dart execution.
3. `FlutterWindow::OnCreate` creates the Win32 host and `FlutterViewController`.
4. The Flutter engine starts Dart `lib/main.dart`; `WidgetsFlutterBinding`, `window_manager`, locale initialization and `AppDatabase()` are created there.
5. `AppDatabase` resolves production/Windows `kDatabaseName` as `opc_v4_release`; the disposable acceptance lane uses `BUILD_VARIANT=WINDOWS_TEST` with an explicit `OPC_MIGRATION_COPY_PATH` copy.
6. `driftDatabase(name: kDatabaseName)` opens the selected database lazily after Dart bootstrap.
7. The first frame is shown/maximized by `FlutterWindow` after engine startup.
8. The native mutex handle remains owned for the process lifetime; normal shutdown releases/closes it, while Windows releases it automatically on abnormal process termination.

## Selected mechanism and rationale

The runner acquires a named Windows mutex with an OPC-specific `Local\\` identity. A first process owns it. A second process receives `ERROR_ALREADY_EXISTS`, closes its handle and exits before COM, Flutter, Dart or database initialization. No existing-instance activation is attempted; this keeps the safety invariant independent of optional focus/IPC behavior. The mutex is not a generic global identifier and is stable across installed and development executable paths within the interactive user session.

## Acceptance state

### Changed production surface

- `windows/runner/main.cpp`: named `Local\\OPC_ORGANIZATOR_POGREBNE_CEREMONIJE_SINGLE_INSTANCE` mutex, fail-closed acquisition, early duplicate exit, and explicit normal/error release.
- No Dart, SCENARIO, database schema, dependency, Android, installer or unrelated Windows files changed.
- No tests were added; the native contract is covered by source-order assertions and controlled runtime evidence rather than a new native test framework.

### QA evidence

| Check | Result |
|---|---|
| Native source-order regression assertions | PASS — 6/6 assertions, 0 failures |
| Disposable database selector regression | PASS — 9 tests |
| `flutter analyze --no-pub` | PASS — exact required command completed in approximately 50.4 s; `No issues found!` |
| Full `flutter test --no-pub --concurrency=1` | PASS — exact required command completed in approximately 17 min 19 s; 419 tests passed, 10 skips reported by the suite |
| `flutter build windows --release --no-pub` | PASS |
| `WINDOWS_TEST` disposable build with explicit `MIGRATION_TEST` copy | PASS |

### W1–W6 disposable-lane runtime acceptance

Disposable lane: `%TEMP%\\opc_singleton_acceptance\\opc_singleton_MIGRATION_TEST.sqlite`. The canonical database was never used as the mutable runtime target.

| Case | Objective evidence | Result |
|---|---|---|
| W1 first launch | PID 20184; one `OPC` process; title `OPC ORGANIZATOR POGREBNE CEREMONIJE`; first instance remained running | PASS |
| W2 second launch | second PID 4220 exited code 0; process count remained 1 | PASS |
| W3 repeated second launches | PIDs 7740, 23248, 18904 all exited; process count remained 1 | PASS |
| W4 normal exit/relaunch | First PID 12848; normal `Alt+F4` → `Izlaz iz aplikacije` → `IZAĐI` confirmation exited the process with count 0; relaunch PID 18840 established the expected window; final instance closed through the same normal flow | PASS |
| W5 early/fast second launch | first PID 17452; second PID 22184 exited; process count remained 1 | PASS |
| W6 database integrity | disposable copy `PRAGMA integrity_check=ok`, `user_version=27`, `predmeti=47`; canonical pre/post SHA unchanged | PASS |

Canonical SHA-256 before/after: `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB`.

### Defect closure state

`WINDOWS SINGLETON DEFECT — FULL ACCEPTANCE PASS`

The source guard is proven early enough to precede Flutter/Dart/database ownership, W1/W2/W3/W4/W5/W6 pass, the exact required analyzer reports no issues, and the exact required full suite passes 419 tests (with 10 suite-reported skips). The earlier apparent hang was characterized as slow historical-schema migration work; the isolated migration suite passed all 40 tests in approximately 6 min 12 s. No canonical or private database was packaged. Remaining release and migration work is tracked independently of this closed singleton defect.
