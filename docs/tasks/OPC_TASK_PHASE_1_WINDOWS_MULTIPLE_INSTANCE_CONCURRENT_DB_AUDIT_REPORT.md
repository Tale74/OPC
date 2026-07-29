# OPC task report — Phase 1 Windows multiple-instance and concurrent SQLite audit

Status: `AUDIT COMPLETE — CONCURRENCY RISK CONFIRMED — IMPLEMENTATION NOT AUTHORIZED`

Audit date: 2026-07-29

## Git baseline

- Base branch: `task/OPC-IRIU-BASIC-SCENARIO-ORDER-REGRESSION-AUDIT`
- Base SHA: `f2ee78d68b6a8398a51729b6e46c748f5c39c26a`
- Task branch:
  `task/OPC-PHASE-1-WINDOWS-MULTIPLE-INSTANCE-CONCURRENT-DB-AUDIT`
- Scope: source/runtime audit and documentation only

## Owner/runtime input

The owner observed that more than one OPC Windows instance can be started.
The owner also approved the installation direction:

- use and harden the existing Inno Setup lane instead of manual release-folder
  copying;
- install/update/uninstall may change program files only;
- canonical user database identity, location and content must not be changed by
  installation or update;
- a pre-update SQLite-consistent backup is permitted as protection, but an
  application rollback must not overwrite newer canonical database state.

## Source findings

### No single-instance guard

`windows/runner/main.cpp:8-45` initializes COM, creates the Flutter project and
window, and enters the message loop. It has no named mutex, existing-window
lookup, IPC handoff or other cross-process guard.

`windows/runner/win32_window.cpp:19` uses a process-local window class name.
Its `g_active_window_count` is also process-local and cannot prevent another
OPC process.

### Every production instance selects the same database lane

`lib/main.dart:10-22` constructs a new `AppDatabase` for every process.

`lib/core/config/app_config.dart:55-61` maps both `PRODUCTION` and `WINDOWS` to
`opc_v4_release`.

`lib/core/database/database.dart:2076-2083` opens that lane through
`driftDatabase` unless an explicitly isolated WINDOWS_TEST migration file is
used. A normal installed release therefore gives every process an independent
SQLite connection to the same canonical file.

### Opening is not read-only

`lib/core/database/database.dart:182-204` performs additive recovery, seeds,
backfills, column/index/table ensure operations, stable-ID canonicalization and
schema validation during `beforeOpen`.

Consequently, two processes starting together can contend before the user
reaches login or opens a PREDMET.

### High-risk concurrent operations

| Operation | Current coordination | Risk |
|---|---|---|
| ordinary writes to different rows | SQLite file locking only | blocking / busy failure; UI has no cross-process coordinator |
| same-PREDMET edit | no cross-process optimistic version predicate | stale second writer can overwrite a newer value |
| schema recovery / seed / backfill | each process runs `beforeOpen` | DDL/DML contention and startup hang/failure |
| individual PREDMET import/replace | one-connection transaction only | other process may read/write stale related rows |
| full backup import | destructive multi-table transaction in `json_export_import.dart:839+` | another live process can hold stale state or contend with delete/reinsert |
| PREDMET delete / IRiU / stock effects | local transaction/service only | another process is unaware of lifecycle effects |
| document/export | may read while another process changes truth | inconsistent user-visible snapshot timing |

SQLite transactions protect atomicity within the database connection, but they
do not supply OPC-level same-PREDMET conflict semantics or coordinate two
independent UI processes.

## Isolated runtime evidence

No canonical owner database was opened, copied or modified.

A temporary harness used only synthetic SQLite files under the system temp
directory and two independent `AppDatabase.forTesting(NativeDatabase(file))`
connections.

Results:

1. a lock-contention probe left the second native write blocked beyond the
   three-minute command boundary and required termination of only the audit
   processes;
2. a reduced simultaneous-fresh-open probe did not return a final result
   within two minutes and also required termination;
3. neither result is reported as a Flutter test PASS or FAIL;
4. the observed blocking is consistent with the source-confirmed absence of
   process coordination and write-capable `beforeOpen`;
5. no corruption claim is made because the synthetic probes were terminated
   before a final database comparison.

Repeating the same blocked probe would add cost without changing the
architectural conclusion and is not recommended.

## Root cause and severity

Root cause:

`NO PROCESS-LEVEL SINGLE-INSTANCE OWNERSHIP BEFORE FLUTTER AND SQLITE OPEN`

Severity:

`P1 DATA-INTEGRITY / RUNTIME-AVAILABILITY RISK`

The application currently relies on SQLite locking after both processes have
already opened the same canonical lane. That is too late for OPC's local,
single-user, PREDMET-authoritative product model.

## Recommended correction boundary

The primary correction is a Windows named mutex acquired in `wWinMain` before:

- Flutter engine creation;
- plugin registration;
- `AppDatabase` construction;
- SQLite open, migration, recovery or seed work.

If the mutex already exists, the second process should:

1. locate and foreground the existing OPC window where reliable;
2. otherwise show one short localized message;
3. exit without initializing Flutter or SQLite.

The mutex identity must be stable for the OPC v.1 Serbia product line and must
not be derived from database content, user data, package/licensing state or a
private local path.

SQLite busy handling, WAL review and future optimistic PREDMET conflict guards
may improve resilience, but none is a substitute for single-instance ownership
in the current standalone Windows product.

## Installer/update contract — owner locked

The existing lane:

- `tools/windows_installer/opc_installer.iss`
- `tools/windows_installer/prepare_windows_installer.ps1`

is the preferred current packaging foundation.

Required hardening:

- stable Inno `AppId`;
- installer/application mutex coordination;
- refuse install/update/uninstall file replacement while OPC is running;
- atomic program-file replacement and application-file rollback;
- canonical database stored outside the installation directory;
- no database file in installer payload;
- no database deletion during uninstall;
- no database-location or database-name change during ordinary update;
- optional verified SQLite-consistent pre-update backup;
- application rollback must not overwrite the current canonical database;
- executable/installer signing remains a later signing-gate decision.

MSIX is not recommended for OPC v.1 at this stage because app identity and
storage virtualization could introduce a new canonical-database path and
migration boundary.

## Acceptance gate for future implementation

1. focused native mutex tests or deterministic process harness;
2. second launch never reaches Dart/SQLite initialization;
3. first instance remains foregroundable and fully functional;
4. install/update is blocked while OPC runs;
5. update and uninstall preserve canonical database hash/path/identity where
   no application migration is separately authorized;
6. isolated migration-copy proof for every separately authorized schema change;
7. Windows cold/warm startup measurements after the guard;
8. `flutter analyze --no-pub` final PASS;
9. complete `flutter test --no-pub` final PASS without a short artificial
   timeout;
10. build only after owner authorization;
11. technical PASS remains separate from owner runtime acceptance.

## Final status

- Multiple process launch: source-confirmed possible.
- Shared canonical lane: source-confirmed.
- Concurrent open/write blocking: isolated runtime-confirmed.
- Canonical owner database touched: NO.
- Application/source/test/schema/build change: NO.
- Correction implemented: NO.
- Physical owner intervention required: NO.

`WINDOWS MULTIPLE-INSTANCE / CONCURRENT SQLITE RISK CONFIRMED — SINGLE-INSTANCE AND INSTALLER UPDATE CONTRACT DEFINED — CANONICAL DATABASE PROTECTED — IMPLEMENTATION NOT STARTED`
