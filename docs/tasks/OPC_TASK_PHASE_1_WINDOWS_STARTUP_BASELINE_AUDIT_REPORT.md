# OPC task report — Phase 1 Windows startup baseline audit

Status:
`INSTALLED OWNER-VERSION RUNTIME BASELINE CONFIRMED — CURRENT-HEAD QUANTITATIVE BASELINE STILL PENDING — IMPLEMENTATION AND BUILD NOT AUTHORIZED`

Audit date: 2026-07-29

## Git baseline

- Base branch:
  `task/OPC-PHASE-1-WINDOWS-MULTIPLE-INSTANCE-CONCURRENT-DB-AUDIT`
- Base SHA: `f4616b2a77ac1f5bf0512948730f9fa964d828cb`
- Task branch: `task/OPC-PHASE-1-WINDOWS-STARTUP-BASELINE-AUDIT`
- Scope: source/runtime-evidence audit and documentation only

## Protected boundary

- The initial source/harness phase did not open the canonical owner database.
- After the first report commit, the owner explicitly requested direct
  measurement of the installed OPC application. That authorized one normal
  installed-runtime launch against its established canonical lane.
- The installed application opened and changed the canonical database through
  its normal startup path. Exact before/after evidence is recorded below.
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

This is the actual lower-performance owner machine on which the reported
startup and exit symptoms occur.

## Existing artifact and historical evidence

The repository and installed release executable both had the same file size
and 2026-07-17 timestamp during this audit. The build output is ignored by Git
and cannot be tied by repository evidence to the current task HEAD.

The earlier grouped build report records only that a 2026-07-05 release opened
a titled main window and stayed alive. It contains no process-to-window,
process-to-usable-screen or database-open timings. It is historical startup
smoke evidence, not the required current-HEAD performance baseline.

Consequently, the installed executable is used only as the real
owner-installed-version baseline. It is not represented as current-HEAD
evidence.

## Real installed-version runtime measurement

The owner authorized and observed one normal launch of:

`<PROGRAM_FILES>\OPC\OPC.exe`

Results:

- owner stopwatch, process launch → visible login screen: approximately
  `8.0 s`;
- independent automation, process launch → titled OPC native window:
  `8.921 s`;
- the Computer Use accessibility layer did not expose the login text during
  polling, so it supplied no independent text-detection timestamp;
- the owner visually confirmed that the measured destination was the login
  screen;
- no PIN was entered and no user logged in.

The two independent observations agree that the actual installed startup to
login is approximately eight to nine seconds on the reference machine.

This is:

`REAL INSTALLED OWNER-VERSION BASELINE — NOT CURRENT-HEAD BASELINE`

### Canonical database before/after

Before launch:

- size: `80,187,392` bytes;
- SHA-256:
  `B746628B934C2B0EBAE10D994C648DB03BA922F06B7AF37F16AB317B5FD906A4`;
- no SQLite sidecar file was present.

After normal startup to login and normal application exit:

- size: `80,195,584` bytes;
- delta: `+8,192` bytes, exactly two `4,096`-byte SQLite pages;
- SHA-256:
  `C0F0F2A84F5DC0A0EF4F60AA557949F16219AA21C21628FB5179F51C652485C1`;
- no SQLite sidecar file remained.

Strict read-only post-exit SQLite checks used `mode=ro&immutable=1` and returned:

- `PRAGMA integrity_check = ok`;
- `PRAGMA user_version = 22`;
- page size `4,096`;
- page count `19,579`;
- freelist count `0`;
- journal mode `delete`.

No restore or overwrite was attempted. The business database is structurally
healthy, but the byte/size change proves that an unauthenticated startup is not
read-only.

This behavior is consistent with the source-confirmed unconditional
`beforeOpen` seed/backfill/update pipeline. Without a pre-launch row-level
snapshot, this task does not claim which exact rows or B-tree pages changed.

The pre-login database change is not attributed to reminder-time
reconciliation:

- a new `SessionService` starts without an authenticated user;
- `_StartRouter` keeps the application on `LoginScreen` until authentication;
- `_refreshCeremonyRemindersAndDialog` starts from
  `ListaPredmetaScreen`, which was never reached in this measurement;
- `beforeOpen` ensures the reminder table/column definitions but contains no
  per-PREDMET reminder-time rescheduling.

PODSETNIK can update scheduling state after login/list startup, but source
ordering excludes that path from this measured launch-to-login change.

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

## Slow normal exit — owner runtime finding

The owner also confirmed that normal application exit is visibly slow. This is
consistent with the earlier grouped-build report, which recorded `12.8 s` for
one normal close. The present run did not have a reliable click timestamp, so
it does not invent a second numeric exit duration.

Source evidence:

- `lib/app.dart:63-77` awaits the Flutter confirmation dialog and then awaits
  `windowManager.destroy()`;
- `lib/app.dart:53-57` removes the window listener during widget disposal;
- no production source call to `AppDatabase.close()` exists;
- no explicit shutdown coordinator stops outstanding DB/reminder work and
  closes owned resources before native-window destruction.

This is a source-supported root-cause candidate, not a proven percentage
attribution. Exit timing requires its own monotonic instrumentation.

Future correction design should evaluate:

1. reject duplicate close requests while shutdown is in progress;
2. stop accepting new background work;
3. await or cancel owned startup/reminder operations;
4. explicitly close the single application-owned `AppDatabase`;
5. dispose plugin/window listeners in a deterministic order;
6. destroy the native window only after resource closure;
7. record phase timings and preserve a bounded fail-safe exit.

The correction must never force-kill OPC while a database transaction is
active.

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

- Source startup/exit map: COMPLETE.
- Structural bottleneck candidates: IDENTIFIED AND RANKED.
- Installed owner-version startup to login: CONFIRMED AT APPROXIMATELY
  `8–9 s`.
- Installed owner-version slow exit: OWNER CONFIRMED; historical `12.8 s`
  evidence exists.
- Current-HEAD native cold/warm timing: NOT COMPLETED.
- Canonical database opened by installed runtime: YES, OWNER AUTHORIZED.
- Canonical database byte/size changed during normal unauthenticated startup:
  YES.
- Post-exit SQLite integrity: `ok`.
- Canonical restore/overwrite: NO.
- Application/source/test/schema/build change: NO.
- Flutter harness repeat allowed: NO.
- Implementation authorized: NO.
- Build authorized: NO.

`WINDOWS INSTALLED-VERSION STARTUP BASELINE CONFIRMED AT APPROXIMATELY 8–9 SECONDS — SLOW EXIT CONFIRMED — STARTUP WRITES TO CANONICAL DATABASE — INTEGRITY OK — CURRENT-HEAD ISOLATED BASELINE AND CORRECTION REMAIN GATED`
