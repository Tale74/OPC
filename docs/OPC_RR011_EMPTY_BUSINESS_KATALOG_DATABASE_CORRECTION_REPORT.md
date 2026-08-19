# RR-011 Empty-Business-KATALOG Database Correction Report

## Outcome

`RR-011 EMPTY-BUSINESS-KATALOG CORRECTION PASS — PHYSICAL RE-ACCEPTANCE INCOMPLETE — BOUNDED RR-011 SUCCESSOR RETAINED — READY FOR LOGOS REVIEW`

The accepted architectural correction is implemented: a fresh OPC database contains structural/authentication state only and does not receive business KATALOG content implicitly. Existing KATALOG data remains authoritative and is preserved through reopen/repair paths. Android first-run setup now completes on the disposable `ANDROID_TEST` lane, proving that the prior initialization mismatch was removed. Full physical RR-011 acceptance remains bounded by referential/replacement, backup/restore and direct Android database-integrity evidence not completed in this wave.

## Authorized change boundary

Production change is limited to `lib/core/database/database.dart`: automatic business-KATALOG writes were removed from `onCreate`, pre-v22 migration and `beforeOpen`; existing repair/normalization and the stable-ID unique index remain. The seed helper is retained only as unused legacy forensic code. No schema, migration version, dependency, platform, SCENARIO or canonical database change was made.

Test changes establish explicit fixtures for tests that require business KATALOG. `createTestDatabase()` remains empty. Documentation records the fresh-database invariant and fixture rule.

## Evidence summary

| Evidence | Result |
|---|---|
| Fresh/reopen/existing/unique-index contract tests | PASS — 4 focused tests |
| KATALOG/stock affected tests | PASS — 45 tests |
| Migration/recovery suite | PASS — 41 tests |
| JSON/full-backup/RR-005 group | PASS — 33 tests |
| Scenario targeted groups | PASS |
| Full Flutter suite | PASS — 426 passed, 10 skipped |
| Earlier `flutter analyze --no-pub lib test` attempt | HISTORICAL / SUPERSEDED — terminated before natural completion; no source change in response |
| Authoritative `flutter analyze --no-pub` after REVIEW relocation | PASS — natural completion, exit code `0`, `No issues found!`; no analyzer exclusion or configuration workaround |
| Full `flutter test --no-pub --concurrency=1` | PASS — natural completion, 426 passed, 10 skipped, 0 failed |
| Windows release build `flutter build windows --release` | PASS — executed serially after analyzer and full-test PASS |
| Android release build `flutter build apk --release` | PASS — executed serially after Windows PASS; APK SHA `C7A0A2CB9B98516838F41DA7DE51E50C4D0287C493195F2F88CF0372612C2DD4` |
| Physical fresh setup/authentication | PASS — `Korak 1`, `Korak 2`, owner `POTVRDI`, authenticated `OPC — LISTA PREDMETA` |
| Physical disposable PREDMET | PASS (bounded) — create, close, reopen, relaunch, hard-delete; list empty afterward |
| Physical referential/replacement/backup/restore/direct DB integrity | INCOMPLETE/INCONCLUSIVE — retained bounded successor |

## Protected-surface verification

- Canonical Windows DB pre/post SHA-256: `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB`.
- Windows runner SHA-256: `FFD03CCA5821FB1813CDF2D9CAADB687C79DB1E8AFA0CB27976EE8C379885863`.
- SCENARIO changes: `0`.
- Database files, private data, APKs and build artifacts are excluded from the review package.
- The local REVIEW handoff was relocated from `C:\Projekti\OPC\OPC v.1\SOURCE\REVIEW` to `C:\Projekti\OPC\OPC v.1\REVIEW`; the old path was removed after file/hash equivalence verification. `analysis_options.yaml` remained unchanged and no analyzer exclusion was introduced.
- QA stages ran naturally and strictly serially; the earlier 845 REVIEW-snapshot diagnostics remain historical root-cause evidence only and are not the current QA state.
- `git diff --check`: PASS.

## Successor and controls

Exactly one RR-011 successor remains:

`Android physical RR-011 referential/backup/DB-integrity acceptance completion`

This successor is disposable-lane only and must not mutate the canonical Windows database. RR-005 and RR-010 remain closed; RR-008 remains owner-gated; active Phase 5 successors remain `0`.

No commit or push was performed. No Phase 5 work began.
