# RR-005 Orphan Cleanup / Hard-Delete Correction Acceptance Matrix

| Contract | Evidence | Result | Remaining successor |
|---|---|---|---|
| PREDMET hard delete removes owned IRiU provenance | Focused test; direct transaction assertions | PASS | None — RR-005 closed |
| PREDMET hard delete removes owned snapshots | Focused test; survivor snapshot preserved | PASS | None — RR-005 closed |
| Replacement removes old IRiU provenance | Focused replacement-flow test | PASS | None — RR-005 closed |
| Direct IRiU delete paths remain bounded | Repository inspection plus focused regression coverage | PASS | IRiU seam characterization remains separate |
| Existing startup repair removes only 34 provenance + 2 snapshot orphans | Disposable canonical-copy before/after evidence | PASS | None — RR-005 closed |
| Valid live parents and child rows survive | Disposable representative IDs/counts and integrity checks | PASS | None — RR-005 closed |
| Repair is idempotent and clean reopen succeeds | Two startup opens on disposable copy | PASS | None — RR-005 closed |
| Canonical DB immutability | SHA pre/post, size and metadata evidence | PASS | None |
| Migration/recovery compatibility | `canonical_database_migration_recovery_test.dart`, 40/40 PASS in 6m51s | PASS | None — RR-005 closed |
| Analyzer and full Flutter suite | Analyzer: no issues; full suite: 422 passed, 10 skipped, 0 failed | PASS | None — RR-005 closed |
| Windows release build | `flutter build windows --release --no-pub` | PASS | Current-tip Windows timing remains separate |
| Android release build/compile | APK built successfully in 19m30s | PASS | None — RR-005 closed |

**Decision:** `RR-005 — FULL ACCEPTANCE PASS`. All required correction, compatibility, analyzer, full-suite, Windows and Android build gates passed; canonical SHA remained unchanged.
