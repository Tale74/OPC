# Current-Tip Windows Startup / Login / Exit Timing Register

All timestamps are local Europe/Belgrade time on 2026-08-18. Process starts
come from Windows process metadata; usable-login, login and process-gone
boundaries come from external Computer Use accessibility/process observation.
For login runs, T2 is the owner `DONE` acknowledgement boundary proxy after
the owner entered and submitted the authorized PIN directly in OPC. No PIN
value was observed, captured or recorded. The executable SHA for every run was
`5C9F6F37AEF4E3455795E520E24B49E15453BC49B8094B40F8B9CB2A10252223`.

## Startup runs

| Run | Label | PID | Process start | Usable login observed | Startup→usable login |
|---|---|---:|---|---|---:|
| S1 | first run in measurement session | 12176 | 14:00:59 | 14:02:10.417 | 71,417 ms |
| S2 | subsequent process restart | 13496 | 14:05:09 | 14:05:20.945 | 11,945 ms |
| S3 | subsequent process restart | 16992 | 14:05:48 | 14:06:06.255 | 18,162 ms |
| S4 | subsequent process restart | 6216 | 14:06:20 | 14:06:34.481 | 14,325 ms |
| S5 | subsequent process restart | 17572 | 14:06:48 | 14:07:03.368 | 15,218 ms |

Startup distribution: minimum `11,945 ms`; median `15,218 ms`; maximum
`71,417 ms`. The first-run initialization value is retained as an observed
outlier rather than discarded.

## Owner-authorized login transitions

| Run | PID | Process start | T2 owner boundary | T3 main usable | T3−T2 | Main usable | Process count |
|---|---:|---|---|---|---:|---|---:|
| L1 | 8116 | 14:43:36.6759479 | 14:44:30.237 | 14:44:32.609 | 2,372 ms | PASS | 1 |
| L2 | 22836 | 14:45:00.6317592 | 14:45:49.846 | 14:45:51.539 | 1,693 ms | PASS | 1 |
| L3 | 13384 | 14:46:19.7282055 | 14:48:50.257 | 14:48:51.493 | 1,236 ms | PASS | 1 |
| L4 | 16888 | 14:50:32.3530566 | 14:51:34.185 | 14:51:35.956 | 1,771 ms | PASS | 1 |
| L5 | 22788 | 14:52:20.6605306 | 14:53:11.059 | 14:53:12.673 | 1,614 ms | PASS | 1 |

Login result: `5/5` owner-authorized transitions reached
`OPC — LISTA PREDMETA`. Distribution: minimum `1,236 ms`; median `1,693 ms`;
maximum `2,372 ms`. No duplicate process was observed in any login run. Each
run was followed by normal close and process disappearance before the next
launch.

## Normal exit runs

| Run | PID | Close request | Dialog visible | Request→dialog | `IZAĐI` confirmation | Process gone | Confirm→gone |
|---|---:|---|---|---:|---|---|---:|
| E1 | 12176 | 14:04:26.350 | 14:04:27.211 | 861 ms | 14:04:41.033 | 14:04:44.650 | 3,617 ms |
| E2 | 13496 | 14:05:34.181 | 14:05:34.859 | 678 ms | 14:05:35.595 | 14:05:38.807 | 3,212 ms |
| E3 | 16992 | 14:06:06.255 | 14:06:07.776 | 1,521 ms | 14:06:08.736 | 14:06:12.046 | 3,310 ms |
| E4 | 6216 | 14:06:34.481 | 14:06:35.535 | 1,054 ms | 14:06:36.125 | 14:06:39.608 | 3,483 ms |
| E5 | 17572 | 14:07:03.368 | 14:07:04.249 | 881 ms | 14:07:05.104 | 14:07:08.746 | 3,642 ms |

Request→dialog distribution: minimum `678 ms`; median `881 ms`; maximum
`1,521 ms`. Confirm→gone distribution: minimum `3,212 ms`; median `3,483 ms`;
maximum `3,642 ms`. Every run used normal close and no forced termination.

## Relaunch cycles

| Cycle | Old PID gone | New PID | New usable-login observation | Result |
|---|---:|---:|---|---|
| R1 | 12176 at 14:04:44.650 | 13496 | 14:05:20.945 | PASS |
| R2 | 13496 at 14:05:38.807 | 16992 | 14:06:06.255 | PASS |
| R3 | 16992 at 14:06:12.046 | 6216 | 14:06:34.481 | PASS |

## Singleton regression

First instance PID `19404` remained active and usable. Second launch PID
`23292` exited with code `0`; active process count remained `1`. The first
instance subsequently completed normal close and process count became `0`.

## Integrity and scope

The disposable lane ended at `user_version=27`, `integrity_check=ok`, and
`foreign_key_check=0`. Canonical pre/post SHA remained
`8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB`.

No production/test/configuration/dependency/platform/SCENARIO content changed.
RR-010 is closed with full acceptance and has no Windows-timing-specific
successor; Android parity and all unrelated successors remain open as previously
defined.
