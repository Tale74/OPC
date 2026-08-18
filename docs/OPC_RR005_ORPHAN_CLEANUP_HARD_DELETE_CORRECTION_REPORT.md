# RR-005 Orphan Cleanup / Hard-Delete Contract Correction Report

**Status:** `RR-005 — FULL ACCEPTANCE PASS`

**Required Logos status:** `RR-005 CORRECTION QA COMPLETION FULL ACCEPTANCE PASS — REQUIRED VALIDATION AND BUILDS COMPLETE — RR-005 READY FOR LOGOS CLOSURE REVIEW`

## Scope and authority

This bounded correction addresses only the two proven invalid-current-data classes from RR-005: orphan `iriu_provenance` rows whose `iriu_id` has no parent, and orphan `predmet_scenario_snapshots` rows whose `predmet_id` has no parent. PREDMET remains the business/lifecycle authority; `PredmetiRepository` owns the database transaction, `PredmetHardDeleteCoordinator` remains orchestration, and `AppDatabase.beforeOpen` remains the single startup repair boundary. No parent reconstruction, relinking, ID rewriting, schema change, migration-history rewrite, global FK enablement or SCENARIO change was performed.

## Implemented correction

- `PredmetiRepository.obrisiPredmet` removes only provenance belonging to IRiU rows selected for deletion and snapshots belonging to the PREDMET, within the existing transaction.
- `PredmetiRepository.zameniPredmetSaPovezanimPodacima` removes provenance for the IRiU rows it replaces, within the existing transaction.
- Direct `IriuRepository` deletion paths (`obrisiStavku`, lifecycle-memory deletion and `obrisiPoNazivu`) remove only provenance for rows actually deleted, in the same transaction.
- `AppDatabase.beforeOpen` invokes a narrow, idempotent repair that deletes only orphan provenance and orphan snapshots using `NOT EXISTS` parent predicates.
- No competing repair authority was introduced; no generated Drift/schema file changed.

## Evidence

### Focused correction tests

`flutter test --no-pub --concurrency=1 test/rr005_orphan_cleanup_hard_delete_correction_test.dart` — **PASS, 3/3**.

The suite proves hard-delete provenance/snapshot cleanup, replacement-flow provenance cleanup, preservation of unrelated live rows, startup cleanup of both orphan classes and repeat-startup idempotency.

### Prior pre-QA timeout attempts (superseded historical evidence)

- Lifecycle/referential and hard-delete suites: **PASS, 9/9**.
- Full-backup/restore lifecycle coordination suite: **PASS, 8/8**.
- Combined affected-suite invocation: **INCONCLUSIVE — TOOLING/HANG** (240-second timeout with no result).
- Current-tip migration/recovery characterization: **INCONCLUSIVE — TOOLING/HANG** (300-second timeout with no result).
- `flutter analyze --no-pub`: **INCONCLUSIVE — TOOLING/HANG** (180-second timeout with no result).
- Full `flutter test --no-pub --concurrency=1`: **INCONCLUSIVE — TOOLING/HANG** (300-second timeout with no result).
- `flutter build windows --release --no-pub`: **PASS** (release artifact built).
- `flutter build apk --release --no-pub`: **INCONCLUSIVE — TOOLING/HANG** (300-second timeout with no result).

Timeouts are evidence gaps, not passes and not defect findings.

### Disposable canonical-copy acceptance

The canonical database was never opened mutably. Canonical pre/post SHA-256 remained:

`8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB`

The disposable copy began at schema/user_version 27, `integrity_check=ok`, FK enforcement mode `0`, and 36 targeted findings (34 provenance, 2 snapshots). Two corrected startup opens produced:

- targeted orphan findings: `36 → 0`;
- `integrity_check=ok`;
- FK check: `36 → 0` for the corrected classes;
- live provenance and snapshots preserved;
- PREDMET and IRiU parent counts preserved;
- representative live relationship IDs preserved;
- second startup idempotent for the corrected classes.

The disposable copy was deleted after evidence capture and is not in the review package.

## Acceptance decision

The source-level correction, disposable startup repair, migration/recovery validation, analyzer, full suite and Android release build are all proven. Windows release-build evidence is reused from the accepted correction execution because source/test hashes remained unchanged throughout QA. RR-005 is closed.

### QA completion evidence

- Migration/recovery validation: **40/40 PASS**, 6m51s.
- `flutter analyze --no-pub`: **PASS — No issues found**, 59.7s after temporarily moving the ignored review package out of the analyzer tree.
- Full `flutter test --no-pub --concurrency=1`: **422 passed, 10 skipped, 0 failed**, 21m50s.
- Windows release build: **PASS — reused from accepted correction execution; source/test hashes unchanged**.
- `flutter build apk --release --no-pub`: **PASS**, 19m30s; APK 78,403,503 bytes.

RR-008, RR-010 and RR-011 remain unchanged. No Phase 5 successor is introduced; SCENARIO remains locked.

## Changed implementation scope

- `lib/core/database/database.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `test/rr005_orphan_cleanup_hard_delete_correction_test.dart`

The SOURCE inventory and persistent controls were updated only for this factual correction and its evidence state. No database, schema, dependency, CI, platform configuration or private data was changed.
