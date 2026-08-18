# OPC Current-Tip Windows Startup / Login / Exit Acceptance Report

## Verdict

`CURRENT-TIP WINDOWS STARTUP / LOGIN / EXIT ACCEPTANCE PASS`

The current published Windows runtime reached the usable login UI on all five
startup runs, completed five owner-authorized login transitions to the usable
authenticated `OPC — LISTA PREDMETA` state, completed five normal
close/confirmation/process-disappearance flows, completed three exit-to-relaunch
cycles, and passed the singleton regression check. The login transitions were
measured without automating, observing or recording the PIN: T2 is the owner
`DONE` acknowledgement boundary proxy and T3 is the first external observation
of the usable authenticated main state.

## Scope and identity

- Branch: `task/OPC-WINDOWS-CURRENT-TIP-STARTUP-LOGIN-EXIT-ACCEPTANCE`
- Parent/current source SHA: `78624eed96f510304a3ecbfd8c3475efcbf70bec`
- Parent branch: `task/OPC-RR005-ORPHAN-CLEANUP-HARD-DELETE-CORRECTION`
- No production, test, configuration, dependency, database-schema, platform,
  CI or SCENARIO source changed.
- No optimization, singleton correction, database repair or Phase 5 work was
  performed.

## Build identity

The exact current-tip source was built with:

```text
flutter build windows --release --no-pub --dart-define=BUILD_VARIANT=WINDOWS_TEST --dart-define=OPC_MIGRATION_COPY_PATH=C:\Projekti\OPC\OPC v.1\RUNTIME\OPC_WINDOWS_CURRENT_TIP_STARTUP_LOGIN_EXIT_20260818\opc_current_tip_STARTUP_LOGIN_EXIT_MIGRATION_TEST.sqlite
```

The successful recorded build invocation completed in 50.795 seconds.

- Executable: `build/windows/x64/runner/Release/OPC.exe`
- Executable SHA-256: `5C9F6F37AEF4E3455795E520E24B49E15453BC49B8094B40F8B9CB2A10252223`
- `data/app.so` SHA-256: `A07435A28F567DBD557AF3EE29F76902392EB06B10D413BE4F9F7294241DA734`
- The compiled `app.so` contains the explicit disposable database path,
  proving the `WINDOWS_TEST` lane was selected.

## Runtime database safety

The canonical database was never launched by the measured executable.

- Canonical path: `C:\Users\Steva\Documents\opc_v4_release.sqlite`
- Canonical pre SHA-256:
  `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB`
- Canonical post SHA-256:
  `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB`
- Canonical pre/post invariant: **PASS**
- Canonical `user_version`: `27`
- Canonical read-only `integrity_check`: `ok`

Disposable lane:

`C:\Projekti\OPC\OPC v.1\RUNTIME\OPC_WINDOWS_CURRENT_TIP_STARTUP_LOGIN_EXIT_20260818\opc_current_tip_STARTUP_LOGIN_EXIT_MIGRATION_TEST.sqlite`

The copy ended with `user_version=27`, `integrity_check=ok`, and
`foreign_key_check=0`. The bounded RR-005 startup cleanup had already been
completed on this disposable lane. The database file is not included in the
review package.

## Measurement boundaries

- `T0_START`: process creation/start command.
- `T1_USABLE_LOGIN`: accessibility tree exposed `Izaberite savetnika` and an
  active user, proving the login surface was rendered and observable.
- `T2_LOGIN_SUBMIT`: owner `DONE` acknowledgement immediately after the owner
  entered and submitted the authorized PIN directly in OPC; the acknowledgement
  timestamp is the protected submission-boundary proxy.
- `T3_MAIN_USABLE`: first external observation of `OPC — LISTA PREDMETA` in the
  accessibility tree after T2.
- `T4_EXIT_REQUEST`: normal `Alt+F4` close request.
- `T5_DIALOG_VISIBLE`: accessibility tree exposed `Izlaz iz aplikacije`.
- `T6_EXIT_CONFIRM`: `IZAĐI` selected through normal supported interaction.
- `T7_PROCESS_GONE`: no OPC process remained, verified through process listing
  and refreshed app state.

The PIN value was never observed, captured, transmitted or included in any
artifact.

## Startup, login and exit results

Detailed values are in
`OPC_WINDOWS_CURRENT_TIP_STARTUP_LOGIN_EXIT_TIMING_REGISTER.md`.

- Startup runs: `5/5` reached usable login UI; values ranged from 11,945 ms to
  71,417 ms, median 15,218 ms. The first run is labelled first-run/session
  initialization; no cold-cache claim is made.
- Owner-authorized login transitions: `5/5` reached the usable authenticated
  main state. Elapsed values were `2,372`, `1,693`, `1,236`, `1,771` and
  `1,614 ms`; minimum `1,236 ms`, median `1,693 ms`, maximum `2,372 ms`.
- Normal exits: `5/5` dialog and process-gone flows completed without forced
  termination. Close-request-to-dialog ranged 678–1,521 ms (median 881 ms);
  confirmation-to-gone ranged 3,212–3,642 ms (median 3,483 ms).
- Relaunch: `3/3` cycles produced distinct new PIDs and a usable login state
  after the prior PID disappeared.

No subjective performance threshold was applied. The timing evidence is
descriptive and reproducible on the disposable current-tip lane.

## Singleton regression

With first PID `19404` running and showing the usable login state, a second
launch PID `23292` exited with code `0`; the active process count remained `1`
and the first window remained valid. The first instance then closed normally and
the active process count became `0`. Singleton regression: **PASS**.

## Control disposition

RR-010/current-tip Windows startup-login-exit acceptance is **CLOSED — FULL
ACCEPTANCE PASS — NO WINDOWS-TIMING-SPECIFIC SUCCESSOR**. The five owner-
authorized login observations close the prior evidence gap. Android physical
parity, replacement-derived-state semantics, JSON/backup/database and all other
unrelated successors remain unchanged. Active Phase 5 successors remain `0`;
SCENARIO remains locked.

## Final classification

`CURRENT-TIP WINDOWS STARTUP / LOGIN / EXIT ACCEPTANCE PASS — OWNER-AUTHORIZED LOGIN TRANSITION MEASURED AND WINDOWS TIMING SUCCESSOR CLOSED — READY FOR LOGOS REVIEW`
