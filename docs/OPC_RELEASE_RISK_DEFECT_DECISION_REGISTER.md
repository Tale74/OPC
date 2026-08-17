# Release-Risk Defect / No-Defect Decision Register

| ID | Decision | Evidence basis | Immediate correction? | Successor |
|---|---|---|---|---|
| RR-001 | DEFECT PROVEN — Windows singleton guard absent | `windows/runner/main.cpp`, `win32_window.cpp` contain no mutex/second-launch coordination | No | Windows singleton implementation plus runtime second-launch/installer acceptance |
| RR-002 | CONTRACT CONFIRMED — canonical path/name | `app_config.dart`, `database.dart` | No | Release-candidate path recheck |
| RR-003 | CONTRACT CONFIRMED — test lane rejects canonical aliases | Selector source + 9 passing tests | No | Keep release gate |
| RR-004 | CONTRACT CONFIRMED — disposable-copy integrity | SHA/integrity check and unchanged canonical hash | No | Repeat before recovery rehearsal |
| RR-005 | INCONCLUSIVE — current-tip unauthorized migration risk | Migration-recovery suite timed out; production lane intentionally not opened | No | Disposable current-tip migration/recovery rehearsal |
| RR-006 | CONTRACT CONFIRMED — explicit PREDMET lifecycle | 5 passing completion tests | No | Windows/Android runtime acceptance |
| RR-007 | CONTRACT CONFIRMED — tested delete/restore referential flows | 5 + 4 + 8 passing tests | No | Release acceptance with representative data |
| RR-008 | INCONCLUSIVE — replacement-derived-state semantics | 5 passing tests expose retention, but no release oracle | No | Business-meaning acceptance for derived reminder/PARTE state |
| RR-009 | DEFECT PROVEN at contract level — second-launch race protection absent | Same source-level singleton absence; duplicate production launch not attempted | No | Disposable-lane concurrent-launch acceptance after RR-001 |
| RR-010 | INCONCLUSIVE — current-tip Windows runtime timings | Historical baseline only | No | Reproducible current-tip startup/exit measurement |
| RR-011 | INCONCLUSIVE — Android physical parity | Shared Dart evidence only | No | Android device/emulator lifecycle/referential acceptance |

