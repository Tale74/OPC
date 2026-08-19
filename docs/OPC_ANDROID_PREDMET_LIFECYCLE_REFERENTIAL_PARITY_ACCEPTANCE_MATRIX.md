# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Matrix

| Area | Evidence required | Current evidence | Status | Successor / boundary |
|---|---|---|---|---|
| Device readiness | Physical Android target, ADB and Flutter visibility | LGN LX1, Android 15/API 35, ADB `device`, package `com.tale.opc_v4` | PASS | None |
| Acceptance-lane identity | Shared implementation with inspectable disposable database | Explicit `ANDROID_TEST` lane, `opc_v4_android_test.sqlite`, schema 27 and `run-as` read-only captures | PASS (bounded physical) | None — RR-011 closed |
| Build identity | Accepted release artifact and database identity | Default/no-define `PRODUCTION`, `opc_v4_release.sqlite`, accepted APK SHA `C7A0A2CB9B98516838F41DA7DE51E50C4D0287C493195F2F88CF0372612C2DD4`; not conflated with disposable `ANDROID_TEST` data | PASS | None |
| Fresh business KATALOG | Fresh DB has no business KATALOG rows | Existing accepted focused/physical evidence remains valid | PASS | None |
| Existing KATALOG preservation | Existing rows survive reopen and repair/index paths | Existing accepted focused evidence remains valid | PASS | None |
| Database initialization | Setup creates/opens schema coherently | Fresh lane reaches authenticated main state; accepted correction evidence remains valid | PASS | None |
| Authenticated main state | Owner login reaches main list | Owner authentication returned to `OPC — LISTA PREDMETA` | PASS | None |
| PREDMET lifecycle | Create/close/reopen/relaunch | Synthetic records created; normal exit and relaunch returned to list; post-replacement relaunch preserved the same PREDMET | PASS (bounded) | None — RR-011 closed |
| Provenance cleanup | Delete leaves no orphan provenance | Real prior 11-row precondition and normal hard-delete produced zero provenance orphans | PASS (bounded) | None |
| Snapshot cleanup | Hard-delete removes a real snapshot | Real pre-action snapshot for PREDMET 2; normal hard-delete produced zero snapshots and zero snapshot orphans; integrity/FK pass | PASS | None |
| Single-PREDMET replacement | Replacement preserves identity and owned dependents | Export/import conflict path with `Zameni uvoznim`: same PREDMET ID/number, 12 IRiU rows recreated, no duplicate, relaunch persistence, integrity/FK pass | PASS (format-bounded) | `OPC_PREDMET` JSON does not carry scenario snapshot/provenance; this is the documented format boundary |
| Backup/restore | Bounded disposable Android restore | Previously accepted supported full-backup delete/restore evidence remains valid | PASS (bounded) | None |
| Android DB integrity | `user_version=27`, integrity and FK evidence | Pre/post replacement and relaunch copies: schema 27, `integrity_check=ok`, zero FK violations and zero relevant orphans | PASS (`ANDROID_TEST`) | None |
| Canonical Windows DB | Pre/post SHA equality | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` pre/post | PASS | None |
| Protected implementation surfaces | Source/SCENARIO/tests/config unchanged | Runner SHA `FFD03CCA5821FB1813CDF2D9CAADB687C79DB1E8AFA0CB27976EE8C379885863`; no protected surface changed | PASS | None |

RR-011 technical evidence is complete and RR-011 is administratively closed with no remaining Android correction or structural successor.
