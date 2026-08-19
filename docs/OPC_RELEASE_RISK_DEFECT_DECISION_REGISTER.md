# Release-Risk Defect / No-Defect Decision Register

| ID | Decision | Evidence basis | Immediate correction? | Successor |
|---|---|---|---|---|
| RR-001 | WINDOWS SINGLETON DEFECT — FULL ACCEPTANCE PASS | `windows/runner/main.cpp` mutex acquisition and W1/W2/W3/W4/W5/W6 evidence; protected source hash unchanged | No | None — acceptance complete; remaining release/migration work is tracked separately |
| RR-002 | CONTRACT CONFIRMED — canonical path/name | `app_config.dart`, `database.dart` | No | Release-candidate path recheck |
| RR-003 | CONTRACT CONFIRMED — test lane rejects canonical aliases | Selector source + passing tests | No | Keep release gate |
| RR-004 | CONTRACT CONFIRMED — disposable-copy integrity | SHA/integrity check and unchanged canonical hash | No | Repeat before recovery rehearsal |
| RR-005 | CORRECTION CLOSED — FULL ACCEPTANCE PASS | Bounded hard-delete, replacement and startup cleanup; migration/recovery and full-suite evidence; canonical SHA unchanged | No | None — RR-005 correction closed |
| RR-006 | CONTRACT CONFIRMED — explicit PREDMET lifecycle | Passing completion tests | No | Windows/Android runtime acceptance |
| RR-007 | CONTRACT CONFIRMED — tested delete/restore referential flows | Passing delete/restore tests | No | Release acceptance with representative data |
| RR-008 | INCONCLUSIVE — replacement-derived-state semantics | Passing tests expose retention, but no release oracle | No | Business-meaning acceptance for derived reminder/PARTE state |
| RR-009 | WINDOWS SINGLETON DEFECT — FULL ACCEPTANCE PASS | Disposable-lane duplicate safety, normal release/reacquisition and integrity evidence | No | None — acceptance complete; remaining release/migration work is tracked separately |
| RR-010 | CURRENT-TIP WINDOWS STARTUP / LOGIN / EXIT ACCEPTANCE — FULL ACCEPTANCE PASS | Owner-authorized login transitions, normal exits, relaunch cycles, singleton regression and disposable DB integrity evidence | No | None — Windows timing acceptance complete |
| RR-011 | CORRECTION PASS — PHYSICAL ACCEPTANCE INCOMPLETE | Automatic business-KATALOG creation removed from fresh lifecycle paths; focused/migration/full-suite evidence passes; synthetic ANDROID_TEST lane reaches authenticated main state, persists records across relaunch, proves provenance cleanup with an 11-row precondition, passes direct schema/integrity/FK checks and completes supported full-backup delete/restore. Scenario-snapshot precondition and separate single-PREDMET replacement remain incomplete. | No | RR-011 Android scenario-snapshot precondition and single-PREDMET replacement structural acceptance completion |
