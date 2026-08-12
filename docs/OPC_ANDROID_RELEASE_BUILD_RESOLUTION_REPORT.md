# OPC Android release build resolution

Date: 2026-08-12  
Branch: `task/OPC-SCENARIO-HANDOFF-DB-FORENSICS-LIVE-PROOF`

## Result

`C:\flutter\bin\flutter.bat build apk --release --no-pub` completed successfully with natural exit code 0.

Artifact:

`C:\Projekti\OPC\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-release.apk`

- size: 78,042,999 bytes (74.4 MB)
- SHA-256: `33D6D5616F4318A2EE438B28DA381D39CE2E72B98FC5FADDB2BA430AEBD15DB1`
- build output: `√ Built build\\app\\outputs\\flutter-apk\\app-release.apk (74.4MB)`

## Root cause of the previous non-completion

The previous run left stale Gradle/JVM processes behind and did not produce a final APK. The local JVM crash evidence in `android/hs_err_pid9816.log` records native-memory allocation failure while starting a Gradle daemon with `-Xmx8G` on a host with approximately 8 GB physical RAM and only 377 MB free at the time. This is an environment/process-memory failure, not an Android source or Flutter compilation error.

## Resolution

1. Stopped stale Gradle daemon/compiler processes after verifying they belonged to the blocked Android build.
2. Ran `android\\gradlew.bat --stop` and confirmed no Gradle daemons were running.
3. Re-ran the release build from a clean daemon state with no artificial build timeout.
4. The clean build completed naturally and produced the APK above.

No Dart, Android source, business logic, database, or build-configuration change was required for this resolution. The existing project `android/gradle.properties` remains bounded at `org.gradle.jvmargs=-Xmx3G` and `org.gradle.workers.max=2`; the stale `-Xmx8G` daemon came from the prior process state, not the current checked-in project setting.

## Final verdict

- Android release build: `PASS`
- Natural exit: `PASS`
- APK artifact and SHA-256: `PROVEN`
- Root cause: `STALE/OVERCOMMITTED GRADLE JVM PROCESS`
- Source fix required: `NO`
