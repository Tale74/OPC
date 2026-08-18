# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Matrix

| Area | Evidence required | Current evidence | Status | Successor / boundary |
|---|---|---|---|---|
| Device readiness | Physical Android target, ADB and Flutter visibility | LGN LX1, Android 15/API 35, ADB `device`, Flutter target visible | PASS | None |
| Build identity | Current-tip Android test artifact | `ANDROID_TEST` release APK built and installed; SHA recorded in report | PASS | None |
| Disposable lane | Test package/database isolation | Existing supported lane selected `opc_v4_android_test`; package `com.tale.opc_v4`; no production DB touched | PASS for selection | Preserve isolation in successor |
| Startup / first-launch | App starts and expected setup state appears | First-launch administrator flow displayed | PASS (partial) | None |
| Database initialization | Setup creates/opens schema coherently | Reproduced UI error: `user_version 0` with existing `app_podesavanja`; automatic creation refused | DEFECT PROVEN | Android test-lane database initialization/schema-version correction |
| Authenticated main state | Owner login reaches `OPC — LISTA PREDMETA` | Not reached because setup was blocked; PIN remained private | BLOCKED | Same bounded successor |
| PREDMET lifecycle | Create/open/status/reopen/hard-delete | Not safely executable before setup completion | NOT EXECUTED | Re-run after correction |
| Provenance cleanup | Delete/replacement leaves no orphan provenance | Not safely executable | NOT EXECUTED | Re-run after correction |
| Snapshot cleanup | Hard-delete leaves no orphan snapshots | Not safely executable | NOT EXECUTED | Re-run after correction |
| Replacement regression | RR-005 orphan contract only | Not safely executable | NOT EXECUTED | Re-run after correction; RR-008 remains owner-gated |
| Backup/restore | Bounded disposable Android restore | Not safely executable | NOT EXECUTED | Re-run after correction |
| Background/relaunch | Foreground/background/reopen integrity | Not safely executable | NOT EXECUTED | Re-run after correction |
| Android DB integrity | `user_version=27`, integrity and FK evidence | Blocked before safe DB inspection; no direct mutation attempted | INCONCLUSIVE / BLOCKED BY DEFECT | Same bounded successor |
| Canonical Windows DB | Pre/post SHA equality | Expected SHA before and after: `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` | PASS | None |
| Protected implementation surfaces | Source/SCENARIO/tests/config unchanged | Runner hash unchanged; no implementation paths edited | PASS | None |
