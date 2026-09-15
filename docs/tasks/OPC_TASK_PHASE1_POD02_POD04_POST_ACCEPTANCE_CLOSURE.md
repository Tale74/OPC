# Phase 1 POD-02 + POD-04 post-acceptance closure

**Status:** `PHASE 1 POD-02+POD-04 POST-ACCEPTANCE CONTROL CLOSURE — COMPLETE`

This is a task-evidence summary subordinate to the five current OPC authority
homes and the canonical recovery plan. It records the OWNER-accepted closure
and its control identities; it does not create product requirements, authorize
implementation, or replace the detailed current residual ledger/matrix held in
external REVIEW.

## Continuity and next governed state

The recovery plan was physically read before closure work. The immediately
preceding accepted phase was
`PHASE 1 POD-03 POST-ACCEPTANCE CONTROL CLOSURE — COMPLETE`. Phase 1 remains the
current recovery sequence; this closure does not reorder it. The next process
marker remains:

`NEXT: PHASE 1 BATCH-ADMISSIBILITY REVIEW`

The marker selects no batch or residual and authorizes no implementation. The
current detailed REVIEW ledger and matrix were updated to close POD-02 and
POD-04 only. This public summary reproduces that closure delta; the external
REVIEW records remain the sole detailed residual authority.

## OWNER runtime acceptance

- `POD-02 — WINDOWS OWNER RUNTIME ACCEPTED`
- `POD-04 — WINDOWS OWNER RUNTIME ACCEPTED`
- `PHASE 1 POD-02+POD-04 — OWNER WINDOWS RUNTIME ACCEPTANCE PASS`

POD-02 acceptance covers the responsive PARENT-to-CHILD master/detail
presentation, roots first, selected-parent detail, same-parent collapse/reopen,
different-parent switching, matching selected parent/detail tint,
presentation-only selection, and completion controls that remain independent
and use existing completion semantics. The accepted obligation order, grouping,
labels and action placement remain preserved. POD-04 keeps `PARTE` as the
parent/master label and `Spremiti parte` as the child/detail obligation, without
changing underlying business identity or completion semantics.

No Android runtime acceptance is claimed. Android release build success is
technical build-parity evidence only.

## Final QA and release evidence

- Same-parent toggle/collapse targeted test: PASS.
- Bounded PODSETNIK regression: 4 passed.
- R5 ČITULJA regression: 12 passed.
- Relevant PODSETNIK regression: 30 passed.
- `flutter analyze --no-pub`: PASS, no issues.
- `flutter test --no-pub --concurrency=1`: 547 passed, 10 skipped, 0 failures.
- `flutter build windows --release`: PASS. Executable:
  `C:\Projekti\OPC\OPC v.1\SOURCE\build\windows\x64\runner\Release\OPC.exe`.
  Executable SHA-256:
  `960FF97FD5D5E6AF778EDCB0FC12C380073665D307E4963A6A594ECB552DD26D`.
  This is the executable hash, not a hash of every Windows release component.
- `flutter build apk --release`: PASS. APK:
  `C:\Projekti\OPC\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-production-release.apk`.
  SHA-256:
  `998634EDD95939E879AC20FEC59CCA14FB5AFFDF8302866A24C32FD35229EAB3`.
  Recorded timestamp: `2026-09-15T00:16:40`.

## Controlled active-source successor

Current local-only control package:

`C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-HIGH-RISK-ACTIVE-BASELINE-CONTROLLED-REBASELINE-20260915-PHASE1-POD02-POD04-CLOSURE\`

- 27-row baseline SHA-256: `7BDDA86623930EF6392EB3A10E08F374066FB2A3D88C9223DC90070860630C5F`
- `04_ACTIVE_SOURCE_AUTHORITY_MANIFEST.json` SHA-256: `0284F30EB4D1AB19A776FF9DEE01D34EB7E1154F3963C7CA155F6469EE8C2827`
- `PACKAGE_MANIFEST.json` SHA-256: `3CB9316905942CE0BB8AE15740789E9C633B3295270A8182D42ED466D2E901BD`
- Successor ZIP SHA-256: `680D3989AF3C3421DB4820CA96D07E24DE6A245BC331E027DB6E07BE5667FD72`
- Protected comparison: 27 rows, 26 unchanged, one accepted PODSETNIK source row updated, zero mismatches.
- Accepted source row: `lib\features\podsetnik\presentation\podsetnik_module_screen.dart`, SHA-256 `16DB226604859956AF4AD347627A22F5A35A8726652F4BA935B969E0BC0C9654`.

The immediate predecessor was the POD-03 successor package, baseline
`767DEEF601CA80292C71C8D43B40E2CC0F19EC49D0F03F802F1555B3F2664FB5`,
`PACKAGE_MANIFEST.json` SHA-256
`45E51244A20886615794D6DFA4C1FECCAA548BB23A2345EE947426491F26CEFD`, and ZIP
SHA-256 `0865CADEE3C865FB46DFE914462DFBAD52BA246BD56223821C209422F675B127`.
Its predecessor provenance includes baseline
`82F6E66060079C3E8150A74B88617DB2ECC418EB3E29B8000D1BAD111A89C7FA`,
`PACKAGE_MANIFEST.json` SHA-256
`0515F7D4C82ED752FD5D41F9E77DB5B8059D88E4B51B75F3AF3A8E69CDAC0284`, and ZIP
SHA-256 `FA04FD16DEEAF1D170168C364EA27339365A9CC18646B72A330F178CF2471A73`.
Predecessor ZIP status remains exactly:

`PREDECESSOR ZIP PHYSICAL RE-VERIFICATION — NOT AVAILABLE`

## Public residual-status closure delta

The following summary reflects the updated current REVIEW ledger/matrix. It is
not a replacement for those detailed records.

| Item | Publicly recorded current status |
|---|---|
| POD-01 | NOT IMPLEMENTED — unchanged |
| POD-02 | WINDOWS OWNER RUNTIME ACCEPTED — implementation residual closed |
| POD-03 | WINDOWS OWNER RUNTIME ACCEPTED — unchanged, protected |
| POD-04 | WINDOWS OWNER RUNTIME ACCEPTED — implementation residual closed |
| POD-05 | PARTIAL — PROTECT GOOD PART / CORRECT RESIDUAL |
| PDF-05 | NOT IMPLEMENTED — unchanged |
| CIT-04 | FUTURE DIRECTION — unchanged |
| PDF-04 | FUTURE DIRECTION — unchanged |
| EVID-01–03 | EVIDENCE GAP — unchanged |
| PODSETNIK fine-tuning/polish | DEFERRED — unchanged |

No other residual, deferred, authority-gap, evidence-only or protected
classification changed. The successor package and this documentation do not
select the next implementation member.

## Accepted paths and publication boundary

The accepted production path is
`lib/features/podsetnik/presentation/podsetnik_module_screen.dart`. The
targeted-test paths are `test/podsetnik_task2_ui_integration_test.dart`,
`test/podsetnik_task2_bounded_correction_test.dart`, and
`test/r5_podsetnik_citulja_integration_test.dart`. The R5 test's current file
is untracked in the mixed worktree; comparison with its preserved earlier R5
snapshot confirms the bounded parent-first expectation addition. The pre-existing
mixed-worktree change in `test/podsetnik_module_screen_test.dart` was outside
the accepted path set and remained untouched. No source or test implementation
path is included in the documentation commit or was published by this closure.

The mixed SOURCE worktree remains otherwise protected. This closure publishes
only current documentation and this bounded closure record; it does not publish
the accepted implementation or unrelated mixed-worktree content.
