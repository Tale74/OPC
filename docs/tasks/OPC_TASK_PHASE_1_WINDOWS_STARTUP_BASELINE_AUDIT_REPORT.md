# OPC task report — Phase 1 Windows startup baseline audit

Status:
`SOURCE AUDIT COMPLETE — QUANTITATIVE CURRENT-HEAD BASELINE NOT COMPLETED — IMPLEMENTATION AND BUILD NOT AUTHORIZED`

Audit date: 2026-07-29

## Git baseline

- Base branch:
  `task/OPC-PHASE-1-WINDOWS-MULTIPLE-INSTANCE-CONCURRENT-DB-AUDIT`
- Base SHA: `f4616b2a77ac1f5bf0512948730f9fa964d828cb`
- Task branch: `task/OPC-PHASE-1-WINDOWS-STARTUP-BASELINE-AUDIT`
- Scope: source/runtime-evidence audit and documentation only

## Protected boundary

- The canonical owner database was not opened, copied or modified.
- The installed OPC application was not launched.
- Application source, tests, database schema, migrations, build configuration
  and runtime behavior were not changed.
- No build was started because the required owner build approval was not given.
- Local `PROJECT_DOCS` were not modified. Under the current documentation
  authority model they remain supporting/historical evidence pending separate
  owner-approved promotion/reconciliation.

## Reference machine

- OS: Microsoft Windows 10 Pro 64-bit, version `10.0.19045`;
- hardware: Apple MacBookPro8,1;
- CPU: Intel Core i5-2435M, 2 cores / 4 logical processors;
- memory: 8 GB class.

This is a relevant lower-performance owner machine, but no current-HEAD native
timing is claimed from it in this task.

## Existing artifact and historical evidence

The repository and installed release executable both had the same file size
and 2026-07-17 timestamp during this audit. The build output is ignored by Git
and cannot be tied by repository evidence to the current task HEAD.

The earlier grouped build report records only that a 2026-07-05 release opened
a titled main window and stayed alive. It contains no process-to-window,
process-to-usable-screen or database-open timings. It is historical startup
smoke evidence, not the required current-HEAD performance baseline.

Consequently, neither executable was used as current baseline evidence.

## Startup dependency map

### Native process and window

`windows/runner/main.cpp:8-45`:

1. attaches a console when applicable;
2. initializes COM;
3. creates `DartProject`;
4. creates the Flutter window and engine;
5. immediately calls `ShowWindow(..., SW_SHOWMAXIMIZED)`;
6. enters the Windows message loop.

`windows/runner/flutter_window.cpp:14-43` constructs the
`FlutterViewController`, registers plugins and also registers a next-frame
callback that shows the window.

The native shell can therefore become visible before Dart produces its first
usable Flutter screen. A visible blank or incomplete shell must not be confused
with a usable application.

### Pre-`runApp` Dart boundary

`lib/main.dart:10-22` awaits all of the following before `runApp`:

1. `windowManager.ensureInitialized()`;
2. `windowManager.setPreventClose(true)`;
3. `initializeDateFormatting('sr_Latn_RS')`.

Only after those awaits does it construct the lazy `AppDatabase` and call
`runApp`.

The Serbian date-symbol initialization is documented in source as PARTE
formatting support, but it currently blocks the first frame for every OPC
startup, including a startup that only needs the login screen.

### First Flutter route

`lib/app.dart:38-48` constructs repositories and starts entitlement
resolution. The current development default resolves the POTPUN entitlement
without installed-license file I/O.

`lib/app.dart:199-277` starts `AuthRepository.hasKorisnika()` in
`_StartRouter.initState`. The first usable first-launch/login route therefore
depends on the first real database query and on completion of the database-open
pipeline.

### Database-open pipeline

`lib/core/database/database.dart:182-204` runs the following serial
`beforeOpen` pipeline on every open, not only on a version transition:

- supported additive schema recovery;
- IRIU configuration and newspaper-price seeding;
- built-in basic-policy backfill;
- column, table and index ensure/validation;
- missing stable-ID backfill;
- full KATALOG stable-ID canonicalization scan;
- validation of all generated tables.

Source quantification:

- foundational existence checks cover 10 tables;
- recovery repeatedly performs table existence, `PRAGMA table_info`, column
  validation and table validation calls;
- `_seedIriuKatalog` makes 23 sequential `INSERT OR IGNORE` attempts into IRIU
  configuration on every open;
- it then makes 51 sequential `INSERT OR IGNORE` attempts for Politika and
  Novosti price rows on every open;
- `_backfillBuiltInIriuBasicPolicy` performs an unconditional policy `UPDATE`;
- index ensure/validation performs repeated `sqlite_master`,
  `PRAGMA index_list` and `PRAGMA index_info` reads;
- `canonicalizeSeedCatalogStableArticleIds` reads the complete
  `katalog_artikli` table on every open.

The photo-asset seed is disabled in the production-safe build variant, so full
photo decoding is not a production-startup candidate. The repeated
configuration/newspaper seed, schema recovery/validation and KATALOG scan are.

### Post-login first-list work

`lib/features/predmeti/presentation/lista_predmeta_screen.dart:102-132` starts
additional unawaited work when the list screen is reached:

- `PredmetiRepository.osveziAutomatskeStatuse`;
- sequential reminder reconciliation;
- setup-readiness evaluation;
- SAVETNIK/user loading.

Reminder reconciliation reads all PREDMET records and then obtains reminder
configuration and potentially schedules notifications per eligible PREDMET.

`osveziAutomatskeStatuse` can change PREDMET status after list first frame.
This is both a performance-side-effect candidate and already scheduled business
debt: the approved plan requires removal of automatic `ZAVRŠEN`. It must not be
optimized in isolation in this startup task.

## Evidence-based candidate ranking

| Candidate | Evidence | Likely phase | Current conclusion |
| --- | --- | --- | --- |
| native Flutter engine/plugin load | unavoidable process path; no current timing | process → window | measurement required |
| window-manager awaits before `runApp` | source-confirmed | window → first frame | measurement required |
| global locale initialization before `runApp` | source-confirmed and unrelated to login | window → first frame | strong deferral candidate |
| repeated DB recovery/validation | many serial queries on every first DB use | first frame → login | strong architecture/performance candidate |
| repeated 74 seed attempts and policy update | exact source-confirmed serial writes | first frame → login | strong migration-only/idempotent-fast-path candidate |
| full KATALOG stable-ID scan | source-confirmed and data-volume dependent | first frame → login | strong checkpointed-backfill candidate |
| entitlement resolution | current development path is in-memory | first route | low candidate in current development build |
| automatic status/reminder/setup/adviser work | source-confirmed after login/list frame | post-login responsiveness | separate lifecycle/reminder correction boundary |

This ranking is based on structural evidence. It is not a measured percentage
attribution and must not be represented as one.

## Interrupted measurement attempt

One temporary harness outside the repository was intended to use only
synthetic SQLite files under the system temp directory.

Attempt 1 failed at compile time because the temporary wrapper used `test`
instead of `testWidgets`. No test body ran.

After that wrapper was corrected, attempt 2 did not complete within nine
minutes and the owner correctly stopped it. Read-only inspection showed that
the harness temp directory existed but contained no SQLite file, so it had not
reached even the first synthetic DB-open phase. It therefore supplied no
database or OPC startup metric.

The remaining harness `dart.exe` and child `dartvm.exe` processes were
identified by their exact command line and stopped. No other process was
terminated.

The result is:

`NOT COMPLETED — NOT PASS — NOT FAIL — NO PERFORMANCE NUMBER`

The harness must not be repeated. Its behavior is test-environment evidence,
not evidence that OPC startup itself takes nine minutes.

## Correction architecture boundary

No correction is authorized by this audit. The smallest evidence-based future
design should evaluate, in order:

1. acquire the already-recommended Windows named mutex before Flutter/SQLite;
2. instrument process start, native window creation, Dart main, first Flutter
   frame, DB open and first usable route with monotonic timestamps;
3. allow a first Flutter shell/frame before PARTE-specific locale preparation,
   if locale tests prove semantic equivalence;
4. replace unconditional steady-state recovery work with a proven fast path
   keyed by schema/recovery checkpoints;
5. preserve fail-closed schema mismatch behavior and interrupted-migration
   recovery;
6. move one-time seeds/backfills to versioned migration or an explicit,
   persisted idempotence checkpoint;
7. never let that optimization replace, reinterpret or silently migrate the
   canonical database;
8. address automatic status changes and reminder scanning in their already
   scheduled business/lifecycle tasks.

The safety recovery introduced for canonical database protection must not
simply be deleted for speed. A fast path is acceptable only when migration-copy
tests prove that every supported older/interrupted schema still reaches the
same valid result.

## Required quantitative baseline gate

A valid next measurement requires explicit owner authorization for:

1. a current-HEAD `WINDOWS_TEST` release build;
2. only an explicit synthetic or verified isolated
   `MIGRATION_TEST_DATABASE_PATH`;
3. temporary monotonic phase instrumentation or an equally deterministic
   process/window/route observer;
4. no production/canonical database open;
5. at least five single-instance cold launches and five warm launches;
6. recorded process → native window, process → first frame, DB open and
   process → first usable login timings;
7. cleanup of only audit artifacts and processes;
8. owner approval of the proposed target before correction acceptance.

Because app-code instrumentation and a build are both currently unauthorized,
this task stops before that gate.

## Owner decision required

Does the owner authorize a separate, bounded current-HEAD `WINDOWS_TEST`
instrumentation-and-release-build measurement task under the gate above?

This decision authorizes measurement only. It does not authorize startup
optimization, schema changes, canonical migration or deployment.

## Final status

- Source startup map: COMPLETE.
- Structural bottleneck candidates: IDENTIFIED AND RANKED.
- Current-HEAD native cold/warm timing: NOT COMPLETED.
- Canonical database touched: NO.
- Application/source/test/schema/build change: NO.
- Flutter harness repeat allowed: NO.
- Implementation authorized: NO.
- Build authorized: NO.

`WINDOWS STARTUP SOURCE AUDIT COMPLETE — CURRENT-HEAD QUANTITATIVE BASELINE AWAITS OWNER-AUTHORIZED ISOLATED WINDOWS_TEST MEASUREMENT — CANONICAL DATABASE PROTECTED`
