# OPC Task — Grouped Build and Windows Runtime Validation Report

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Task class:
- release / validation / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no; builds validate shared source, and no platform behavior was changed

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- no product implementation; validation/report only

Required gate before implementation:
- platform parity / repository identity / product terminology; passed

## Task identity

- Branch: `task/OPC-GROUPED-BUILD-WINDOWS-RUNTIME-VALIDATION`
- Base commit: `59b22a930c4e558cafa37dae3d5725bda9926f2b`
- Final commit: `HEAD` — immutable hash is recorded in the Codex handoff because a commit cannot contain its own hash

## Learning layer reviewed before conclusions

The updated pseudocode/docs learning layer was reviewed before validation and
before writing runtime conclusions. Inspected paths:

- `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md`
- `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/tasks/OPC_TASK_PDF_LOGO_MAX_LAYOUT_REPORT.md`
- `docs/tasks/OPC_TASK_PREBUILD_STANJE_ROBE_PODSETNIK_CORRECTIONS_REPORT.md`
- `docs/tasks/OPC_TASK_BACKUP_RESTORE_EVIDENCE_CHECK_REPORT.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

These establish the intended validation targets: a shared `192 × 120 pt`
contain-fit PDF logo box; visible MODULI information under all packages with
stock control restricted by entitlement and ADMINISTRATOR role; Podsetnik as an
entitlement-aware shortcut to existing CEREMONIJA settings; no change to
PREDMET, finance, stock consequences, or reminder scheduling.

## Source validation

Commands were run from `<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\SOURCE` in the required order.

1. `flutter analyze`
   - Result: `PASS`
   - Output: `No issues found!`
   - Analyzer time: 31.4 seconds
   - Errors/warnings/lints/info findings: 0
2. `flutter test`
   - Result: `PASS`
   - Test count: 112
   - Output: `All tests passed!`
   - Wall time: 94.8 seconds

The expected count was 112 and the actual count was 112. No repair or repeated
analyze/test cycle was required.

## Windows release build

- Command: `flutter build windows --release`
- Result: `PASS`
- Flutter build output: `Built build\windows\x64\runner\Release\OPC.exe`
- Build-reported duration: 229.6 seconds
- Executable path: `<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\SOURCE\build\windows\x64\runner\Release\OPC.exe`
- Executable size: 89,088 bytes
- Executable creation time: `2026-05-25 21:38:17 +02:00`
- Executable last-write time: `2026-07-02 20:30:20 +02:00`
- SHA-256: `BAF79FCE42C591F0CF449789860DFD711C72061744E316AD8F83A55995114A50`

The launcher timestamp did not change because recent work did not alter the
native runner; Flutter still rebuilt and reported the complete Windows release
bundle successfully. The executable alone is not the whole distributable; its
adjacent release data/libraries are required.

## Android release build

- Command: `flutter build apk --release`
- First attempt: `PARTIAL` — command reached the 600-second timeout without a
  final Flutter result, although it produced a refreshed APK. This was not
  counted as PASS.
- Repeated command: `flutter build apk --release`
- Final result: `PASS`
- Flutter build output: `Built build\app\outputs\flutter-apk\app-release.apk (69.6MB)`
- Gradle-reported duration: 250.1 seconds
- APK path: `<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-release.apk`
- APK size: 72,963,856 bytes
- APK creation time: `2026-05-25 21:30:05 +02:00`
- APK last-write time: `2026-07-05 07:24:49 +02:00`
- SHA-256: `0B805E64D39561E9ABAFC7F61EF0C934EA6A7C584DEE4F80C21B8448C6957611`

## Windows runtime validation

Overall status: `PARTIAL / OWNER RUNTIME REVIEW REQUIRED`.

Codex performed one bounded non-destructive native startup/close smoke against
the built release executable:

- process started successfully at `2026-07-05 07:25:28 +02:00`;
- a main window was observed;
- title: `OPC ORGANIZATOR POGREBNE CEREMONIJE`;
- process remained alive during the startup check;
- observed working set: 90,185,728 bytes;
- normal `CloseMainWindow` request was accepted;
- process exited normally without force-stop;
- close elapsed time: 12.8 seconds.

This proves release startup, main-window creation, process health during the
check, and normal-close completion. It does not prove login, persisted data,
package contexts, feature workflows, exports, or visual correctness.

## Runtime status by area

| Area | Status | Evidence |
|---|---|---|
| Windows release startup/window | `PASS` | Built executable opened expected titled main window and stayed alive. |
| Windows normal close | `PASS` for completion | Close accepted; exited without force-stop. |
| PDF visual review | `NOT TESTED` | No PREDMET interaction or PDF export was performed. |
| STANJE ROBE runtime | `OWNER RUNTIME REVIEW REQUIRED` | Source/tests/build pass; Osnovni and entitled POTPUN UI contexts were not manually exercised. |
| Podsetnik runtime | `OWNER RUNTIME REVIEW REQUIRED` | Source/tests/build pass; native overflow navigation was not manually exercised. |
| Regression spot checks | `NOT TESTED` | No authenticated in-app workflow was operated. |
| Slow Windows exit | `TECHNICAL AUDIT REQUIRED` | Normal close completed but took 12.8 seconds. |
| Android build | `PASS` | Release APK built successfully. |
| Android runtime | `NOT TESTED` | Prohibited pending Windows owner review. |

## Owner Windows runtime checklist

### A. PDF export and visual review

Using a test PREDMET with a configured logo, export LISTA, NALOG ZA OPREMANJE,
PREDMET, PREDRAČUN, RAČUN, and SPECIFIKACIJA TROŠKOVA. Confirm:

1. logo is materially larger than the old `96 × 60 pt` allocation;
2. aspect ratio is preserved and logo is neither stretched nor clipped;
3. logo remains inside the memorandum/header;
4. header height is acceptable and body begins below it without overlap;
5. `Broj predmeta` remains present and semantically unchanged;
6. RAČUN/PREDRAČUN financial sections remain readable;
7. IPS QR remains intact where applicable;
8. all six expected PDFs remain exportable.

Record one of: `PASS`, `FAIL`, `PARTIAL / OWNER REVIEW REQUIRED`, or
`NOT TESTED`. Current status is `NOT TESTED`.

### B. STANJE ROBE

In `Osnovni`, verify `PODEŠAVANJA → MODULI` is visible; STANJE ROBE shows a
locked explanation; no switch or active stock action is exposed.

In an entitled `POTPUN` ADMINISTRATOR context, verify MODULI and the ON/OFF
switch are visible; default is OFF unless already persisted; toggling persists;
entitlement does not force ON. If runtime package switching is unavailable,
record that limitation rather than inferring results.

### C. Podsetnik

From the PREDMET-list overflow menu, verify an entitled non-anonymized PREDMET
has enabled Podsetnik; selecting it opens existing CEREMONIJA reminder settings;
incomplete ceremony data is handled safely; anonymized PREDMET does not expose
an unsafe shortcut; no second reminder model/settings flow appears.

### D. Regression spots

Verify catalog detail aspect ratio; catalog previous/next and IZABERI; IRiU and
FINANSIJE amount formatting; BRAČNO STANJE filtering by POL; no automatic GDPR
startup dialog; manual GDPR action; save/reopen persistence; RAČUN in the
standard export set.

### E. Slow Windows exit

Observe only. Do not close the issue from runtime timing alone. Current result:
normal exit completed in 12.8 seconds; classification remains
`TECHNICAL AUDIT REQUIRED`.

## Source and pseudocode update status

- Source changes during validation: none.
- Test changes during validation: none.
- Existing pseudocode/Logos learning layer: unchanged because validation found
  no source correction requirement.
- Documentation change: this validation report only.
- Generated Windows/Android build artifacts remain ignored/untracked and are not
  committed.

## Business meaning, risks, and safe boundary

The grouped validation establishes that current source is statically clean,
tests preserve 112 expected behaviors, both release targets build, and the
Windows release starts and closes. It does not convert automated/build evidence
into visual or workflow runtime evidence.

Primary remaining risks are PDF layout issues visible only in rendered outputs,
package-context UI differences, native reminder navigation behavior, persisted
toggle behavior in a real installation, and slow Windows shutdown. These remain
explicitly classified rather than hidden behind build PASS.

No product feature, business logic, PREDMET truth, PDF layout, reminder engine,
stock behavior, package policy, platform runner, or slow-exit implementation was
changed. Android runtime remained outside scope.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes; no source change, validation report only

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS for source validation, builds, and bounded Windows startup/close smoke;
  owner runtime review remains required for product workflows and PDF visuals
