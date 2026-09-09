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
| RR-008 | CLOSED — CURRENT PREDMET TRUTH → CURRENT DERIVED STATE | Owner oracle; focused replacement and post-commit failure-injection tests; analyzer PASS; full suite PASS; Windows release build PASS | No | None — bounded replacement correction and auxiliary-failure recovery accepted; later PARTE/notification characterization remains separate |
| RR-009 | WINDOWS SINGLETON DEFECT — FULL ACCEPTANCE PASS | Disposable-lane duplicate safety, normal release/reacquisition and integrity evidence | No | None — acceptance complete; remaining release/migration work is tracked separately |
| RR-010 | CURRENT-TIP WINDOWS STARTUP / LOGIN / EXIT ACCEPTANCE — FULL ACCEPTANCE PASS | Owner-authorized login transitions, normal exits, relaunch cycles, singleton regression and disposable DB integrity evidence | No | None — Windows timing acceptance complete |
| RR-011 | CLOSED — FULL ANDROID STRUCTURAL ACCEPTANCE PASS | Automatic business-KATALOG correction and prior QA evidence remain valid; disposable ANDROID_TEST lane proves real scenario-snapshot cleanup and supported single-PREDMET replacement with stable PREDMET identity, recreated IRiU dependents, relaunch persistence, `integrity_check=ok`, zero FK violations and zero relevant orphans. The current single-PREDMET `OPC_PREDMET` JSON format carries scenario snapshot/provenance context and PREDMET-scoped lifecycle decisions without local IDs; intentional absence is preserved. | No | None — RR-011 closed |
| RR-012 | CLOSED — INSTALLER/UPDATE RUNNING-APP PROTECTION FULL ACCEPTANCE PASS | Inno Setup 6.7.3 compile PASS; installer SHA `C8FA778D67DAB7B4EE51E2CF54D025F2A76CB98D55489B0E4C8334BB60479404`; I1/I2/I3 PASS; `AppMutex` matches native identity and `CloseApplications=no`; no installation completed | No | None — RR-012 closed |

## Current documentation and release boundary — 2026-09-09

This register is current supporting risk evidence. The compact authority homes
remain the source of current product, architecture, development,
quality/release and engineering meaning; this register does not replace them.

- The current documented database baseline is schema 35.
- R1–R5 and the recovered PODSETNIK milestones are implementation/source/test
  evidence with the separately recorded runtime, release and publication gates;
  they are not silently promoted to `RELEASE COMPLETE` here.
- The latest invisible Windows launch observed from the Codex private desktop
  is classified as the known desktop-binding recurrence. OWNER-visible desktop
  acceptance is still required; this observation is not by itself an OPC
  startup defect.
- A mixed dirty implementation SOURCE and deferred supporting-documentation
  backlog remain local/unpublished until their separately authorized gates.

These boundary statements preserve the distinction between source/test proof,
runtime observation, documentation publication and release acceptance.
