# OPC Android release build resolution + runtime handoff preparation

Date: 2026-08-12  
Branch: `task/OPC-ANDROID-RELEASE-BUILD-RESOLUTION`

## A. Baseline verification

- Baseline branch: `task/OPC-SCENARIO-HANDOFF-DB-FORENSICS-LIVE-PROOF`
- Verified local HEAD before branch creation: `c12663d6b2827491f4debf445153cf40d796d74d`
- Verified remote SHA: `c12663d6b2827491f4debf445153cf40d796d74d`
- Working tree: clean
- New task branch: `task/OPC-ANDROID-RELEASE-BUILD-RESOLUTION`
- Existing documented baseline retained: analyze PASS, full suite 393 passed / 7 skipped / 0 failed, Windows release PASS, live Windows NASILNA PASS.

## B. Previous failure review

The previous cycle produced an APK, but its final post-repair Gradle assemble was stopped and therefore was correctly classified `ANDROID BUILD — NOT PASS`. The APK timestamp alone was not accepted as build proof. The current build was executed from the verified HEAD above and was required to finish naturally with exit code 0.

## C. Root cause

The prior environment contained stale Gradle/JVM state. During the blocked run, Gradle Java processes remained active while the APK timestamp did not advance. `android/hs_err_pid9816.log` provides the decisive mechanism: a Gradle daemon was launched with `-Xmx8G` on a Windows host with approximately 8 GB physical RAM, only 377 MB free, and 2.6 GB available page file; the JVM failed native G1 virtual-space allocation. This is resource exhaustion in an overcommitted stale Gradle process, not a Flutter/Dart, Android source, dependency-resolution, SDK, or signing failure.

Classification:

- previous Android failure: `ROOT CAUSE PROVEN`
- `STALE GRADLE` as the complete explanation: `PARTIAL`
- actual mechanism: `STALE/OVERCOMMITTED GRADLE JVM PROCESS → NATIVE MEMORY ALLOCATION FAILURE`
- no evidence of a persistent Gradle lock or network wait was found.

## D. Repair

Only generated/tool state was touched:

1. Stale Gradle compiler/daemon processes belonging to the blocked build were stopped after process inspection.
2. `android\\gradlew.bat --stop` confirmed no Gradle daemons were running.
3. The release build was rerun from the clean daemon state, with no source, business logic, database, signing credential, or production-data change.

The checked-in Android configuration was not changed. `android/gradle.properties` remains bounded at `org.gradle.jvmargs=-Xmx3G` and `org.gradle.workers.max=2`; the `-Xmx8G` command line belongs to the stale crashed daemon evidence.

## E. Final build proof

Command:

`C:\flutter\bin\flutter.bat build apk --release --no-pub`

Evidence:

- observed build window: approximately 15:01:45–15:14:04 Europe/Belgrade;
- Flutter-reported assemble duration: `728.0s`;
- final Gradle status: `√ Built build\\app\\outputs\\flutter-apk\\app-release.apk (74.4MB)`;
- natural exit code: `0`;
- APK path: `C:\Projekti\OPC\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-release.apk`;
- APK size: `78,042,999` bytes (`74.4 MB`);
- APK timestamp: `2026-08-12 15:14:04`;
- APK SHA-256: `33D6D5616F4318A2EE438B28DA381D39CE2E72B98FC5FADDB2BA430AEBD15DB1`;
- provenance: build started from verified HEAD `c12663d6b2827491f4debf445153cf40d796d74d`, then completed naturally and wrote the newer APK timestamp.

This is a fresh artifact proof, not the earlier stale APK.

## F. Validation

No source or build configuration was changed, so the existing baseline validation remains authoritative:

- `flutter analyze --no-pub`: PASS;
- `flutter test --no-pub`: PASS — 393 passed, 7 skipped, 0 failed;
- Windows release build: PASS;
- live Windows NASILNA proof: PASS.

The Android build itself was rerun after the environment repair with no artificial timeout. Android runtime acceptance was intentionally not attempted.

## G. Android runtime handoff

`RUNTIME PENDING OWNER DEVICE/WIRELESS DEBUGGING SETUP`

Owner must provide a physical Android device with Developer Options and Wireless Debugging enabled, complete pairing/connect, and report the connected device to Codex. Only then should Codex:

1. install/upgrade the APK above;
2. verify actual startup and login;
3. verify basic navigation and `MODULI → SCENARIO`;
4. verify OPEN-PREDMET and selected-PREDMET behavior;
5. verify the known NASILNA case and `Zaštitna i dodatna oprema`;
6. compare Android behavior with the proven Windows path and note Android-specific responsive/stutter findings.

No Android runtime PASS is claimed by this task.

## Final verdicts

- `BASELINE — VERIFIED`
- `PREVIOUS ANDROID FAILURE — ROOT CAUSE PROVEN`
- `STALE GRADLE PREMISE — PARTIAL`
- `ANDROID BUILD ENVIRONMENT REPAIR — PASS`
- `SOURCE/CONFIG CHANGED — NO`
- `FLUTTER ANALYZE — BASELINE PASS RETAINED`
- `FULL FLUTTER TEST — BASELINE PASS RETAINED`
- `FINAL GRADLE ASSEMBLE — NATURAL EXIT 0`
- `FINAL APK — FRESH+VERIFIED`
- `FINAL APK SHA-256 — 33D6D5616F4318A2EE438B28DA381D39CE2E72B98FC5FADDB2BA430AEBD15DB1`
- `ANDROID RELEASE BUILD — PASS`
- `ANDROID RUNTIME — PENDING OWNER DEVICE/WIRELESS DEBUGGING SETUP`
- `REMOTE SHA — CONFIRMED`
- `WORKING TREE — CLEAN`
