# OPC KATALOG osnovne kategorije / IRiU audit i implementacija

## Task identity and Git baseline

- Task: `OPC-KATALOG-OSNOVNE-KATEGORIJE-IRiU-AUDIT-IMPLEMENTATION`
- Branch: `task/OPC-KATALOG-OSNOVNE-KATEGORIJE-IRiU-AUDIT-IMPLEMENTATION`
- Base SHA / starting HEAD: `4f8eaa8421f27ef387e3f62866000e396572786c`
- Starting branch: `task/OPC-CANONICAL-DATABASE-RECOVERY-LEGACY-MIGRATION-COMPATIBILITY`
- Starting worktree: clean
- Merge to `main`: not performed

## OPC MANIFEST CHECK — TASK START

- Manifest read: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` reviewed during the task audit and before final validation.
- PREDMET remains central business truth; KATALOG stores only future materialization policy.
- Windows and Android continue to use the same Drift database and shared repositories.
- No canonical owner database was opened or manually changed.
- PASS / NOT PASS: PASS.

## Mandatory pre-implementation audit

### Current behavior found

1. `+ DODAJ KATEGORIJU` persisted an `iriu_katalog_config` row with timestamp-derived stable `interni_naziv`, display name, `tip`, `je_korisnicka = true`, and the next persistent `redosled`.
2. Every user-created category was automatically appended to every new PREDMET because `PredmetiRepository.inicijalizujIriu` selected all `jeKorisnicka` rows. There was no DA/NE policy.
3. No field equivalent to `Osnovna u svakom PREDMETU` existed.
4. Initial non-scenario rows were materialized by `PredmetiRepository.inicijalizujIriu` immediately after `kreirajPredmet`.
5. Conditional scenario rows were assembled without KATALOG policy changes by `MestoSmrtiIriuLifecycleService`, `Blok2IriuLifecycleService`, `IriuTruthRules`, and the existing CEREMONIJA triggers.
6. `Agencijske usluge` was hardcoded in the initial Blok 0 list and seeded as `AGENCIJSKE_USLUGE`; it was not scenario-derived.
7. Stored IRIU order was `iriu.redosled`; `IriuOrderingService` rebuilt known system category order, with unknown/user/manual rows retaining stored relative order.
8. KATALOG order was persistent `iriu_katalog_config.redosled`, assigned from the current maximum plus one. It survives restart, rename and backup/restore.
9. IRiU rows are stored child rows of a PREDMET. They are not recomputed from KATALOG on read.
10. A later KATALOG name/policy change did not rewrite existing IRIU rows; existing rows retain snapshots.
11. `FIKSNA` has no article sublist; `KATALOSKA` uses `katalog_artikli`. Both use the same PREDMET IRIU row and financial model after materialization.
12. Manual IRIU rows are `iriu` records with generated `RUCNO_*` identity and no stable catalog article ID unless selected through the catalog picker.
13. The old Android/manual `KATALOSKA` branch also created a global user category. This contradicted the locked owner decision and was the separation defect corrected here.
14. Windows and Android share repositories, schema, ordering, truth and calculation logic. Only UI form/capability differs.
15. The safe boundary is one additive category-policy column plus new-PREDMET initialization filtering. No scenario predicate, existing IRIU record, or canonical database replacement is required.

### Source trace

`KatalogTab` → `PodesavanjaRepository` → `iriu_katalog_config` → `PredmetiRepository.inicijalizujIriu` → persistent `iriu` rows → existing lifecycle services / `IriuOrderingService` → `PredmetIriuTruthService` → `FinancialTruthService`.

Primary evidence:

- `lib/features/podesavanja/presentation/katalog_tab.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/core/database/tables/iriu_katalog_config_table.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/core_v2/services/iriu_ordering_service.dart`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`

### Gap, migration impact and compatibility risk

The requested behavior partially existed: stable category identity, persistent category order, per-PREDMET materialization and future-only snapshot behavior were already present. The missing piece was an explicit policy; the prior implicit policy was `all user categories = basic`. The migration is additive schema 21 → 22, defaults existing ordinary user categories to `NE`, restores the known built-in basic set to `DA`, keeps `Agencijske usluge = DA`, and does not update `iriu` rows. Risk is bounded to new-PREDMET composition and backup normalization.

No stop condition was triggered: scenario/basic separation and stable identity exist, `Agencijske usluge` is not scenario-derived, manual rows can be separated, and migration needs no table recreation.

## Owner decisions implemented

- Scenario predicates, factors, branching and lifecycle services are unchanged.
- `osnovna_u_svakom_predmetu` belongs to KATALOG and defaults to `false`.
- Built-in basics remain automatic; `Agencijske usluge` is their final boundary row.
- Eligible user/new fixed categories with `DA` follow `Agencijske usluge` in persistent KATALOG creation order.
- Toggling keeps the original category `redosled`; order follows category creation, not toggle time.
- Stable `interni_naziv` identity drives deduplication; visible names are not used.
- Existing PREDMETI are never reconciled from current KATALOG policy.
- Manual IRIU addition is PREDMET-only and never calls `dodajKorisnickaKategoriju`.

## Data model and migration

- Schema checkpoint: `21 → 22`.
- New column: `iriu_katalog_config.osnovna_u_svakom_predmetu INTEGER NOT NULL DEFAULT 0` with Drift boolean validation.
- Existing ordinary user categories: `NE`.
- Existing built-in basic rows and `AGENCIJSKE_USLUGE`: idempotently backfilled `DA`.
- Recovery path also ensures the column for supported partial/stale checkpoints.
- Old full-backup rows missing the JSON property are normalized safely; known built-in basics receive `DA`, others `NE`.
- Existing `iriu` rows are not modified.

## New fixed production categories

Idempotent stable seeds, all `FIKSNA`, all initially `NE`:

- `DORADA_POGREBNE_OPREME` — Dorada pogrebne opreme
- `KUCANJE_OBELEZJA` — Kucanje obeležja
- `SLOVA_I_BROJEVI` — Slova i brojevi

They are policy-editable in KATALOG and are inserted in future PREDMETI only after explicit `DA`.

## Row order

1. existing scenario-dependent system rows in their established relative order;
2. existing built-in basic rows in their established relative order;
3. `Agencijske usluge`;
4. enabled user/configurable fixed basics by persistent KATALOG `redosled`;
5. later manual/unknown rows by stored PREDMET order.

## Cost and manual separation

Automatic basics are ordinary `iriu` rows with existing `kom`, `iznos`, `cekiran`, selection and `redosled` fields. They enter `PredmetIriuTruthService` and `FinancialTruthService`; no price or checked state is invented. A manual row uses the same calculation model only in its current PREDMET and creates no KATALOG row or policy.

## Tests and validation

- Focused policy suite: PASS, 6 tests.
- Covered: seed uniqueness/type/default, create default NE, explicit DA, NE→DA, DA→NE, future-only behavior, stable order, `Agencijske usluge` boundary, no duplicates, manual locality, existing cost model, and KATALOG/manual source separation.
- Existing protected scenario suites: PASS, 11 tests; production scenario predicates remain unchanged.
- Targeted populated-schema-21 migration/reopen test: PASS.
- Historical migration suite was updated for schema 22 and legacy-user default assertions.
- Full `flutter test -r compact` was attempted, but the Flutter process did not produce a final result and had to be terminated. This report does not claim a full-suite PASS.
- `flutter analyze --no-pub` initially completed with only three `prefer_single_quotes` info findings; those findings were corrected. The post-fix rerun stalled past five minutes without a final result, so no clean post-fix analyzer result is claimed.
- `git diff --check`: PASS (line-ending conversion warnings only).
- OPC manifest gate: PASS.

## Successive final-validation rule and result

Permanent owner rule: run `flutter analyze` to a conclusive green exit first;
only then run the complete `flutter test` to a conclusive green exit; only
after both gates pass may a build begin. A timeout, interrupted log, missing
exit code, failure, or unaccepted skip is not PASS. The commands must never
overlap.

The Windows and Android artefacts produced earlier in this task preceded a
conclusive complete-suite result. They remain usable build outputs, but they
are not sufficient final validation evidence and no new build was started in
this successive-validation run.

- Pre-validation branch: `task/OPC-KATALOG-OSNOVNE-KATEGORIJE-IRiU-AUDIT-IMPLEMENTATION`.
- Pre-validation HEAD: `4f8eaa8421f27ef387e3f62866000e396572786c`.
- Existing implementation changes were present; validation introduced no
  source/configuration change.
- Process cleanup: no `OPC.exe`, Flutter, Dart, analyzer, or test process was
  active. One Gradle daemon from the earlier successful Android build was
  present; it was not an interrupted validation process and was not stopped.
- Analyze command: `flutter analyze`.
- Analyze result: PASS, exit code 0, 64.5 seconds tool wall time; analyzer
  summary `No issues found! (ran in 50.1s)`.
- Complete test command: `flutter test`, started only after analyze completed.
- Complete test result: FAIL, exit code 1, 1,256.6 seconds tool wall time;
  runner summary `+232 ~1 -1: Some tests failed.`
- Passed: 232. Failed: 1. Skipped: 1.
- The skip is the repository-controlled owner-copy migration test, disabled
  unless `OPC_OWNER_MIGRATION_COPY` identifies a verified isolated copy.
- Failure: `canonical_database_migration_recovery_test.dart` expected the
  future-schema error text to contain `newer than supported version 22`, while
  the actual safe rejection was `unsupported migration checkpoint 23 -> 22;
  supported existing database versions are 1 through 22`.
- No production/business-logic failure was observed in this assertion. The
  owner subsequently authorized the minimal test-only correction: the stale
  expected substring was aligned with the actual safe future-checkpoint
  rejection. Production and protected business logic were not changed.
- Repeated analyze command: `flutter analyze`.
- Repeated analyze result: PASS, exit code 0, 189.2 seconds tool wall time;
  analyzer summary `No issues found! (ran in 149.5s)`.
- Repeated complete test command: `flutter test`, started only after the
  repeated analyze completed.
- Repeated complete test result: PASS, exit code 0, 1,242.7 seconds tool wall
  time; runner summary `+233 ~1: All tests passed!`.
- Repeated suite totals: 233 passed, 0 failed, 1 accepted conditional
  owner-copy skip.
- Build gate: OPEN.
- Post-validation Windows release build: PASS, exit code 0, 81.0 seconds;
  `build/windows/x64/runner/Release/OPC.exe`.
- Post-validation Android release build: PASS, exit code 0, 197.7 seconds;
  `build/app/outputs/flutter-apk/app-release.apk` (67.1 MB).

## Cross-platform behavior

All semantics are below the platform UI boundary in shared Dart/Drift code. Windows and Android use the same policy, initialization, ordering, truth and finance implementations. No platform-specific category meaning was added.

## Known limitations

- There is no reorder UI; stable order intentionally follows category creation order.
- Existing PREDMETI intentionally do not inherit later policy changes.
- Build success is not owner runtime acceptance.

## Build / GitHub / worktree status

- Build authorization: owner authorized both Windows and Android builds during this task.
- Windows release build: PASS after conclusive successive validation —
  `build/windows/x64/runner/Release/OPC.exe`.
- Android release build: PASS after conclusive successive validation —
  `build/app/outputs/flutter-apk/app-release.apk` (67.1 MB).
- GitHub visibility: the current task branch is the owner-authorized commit and
  push target; the final Git result is recorded in the task handoff.
- Worktree policy: only task changes are included; no unrelated files are
  reverted, cleaned, or stashed.

## OPC MANIFEST COMPLIANCE — TASK END

- Manifest compliance checked: implementation preserves PREDMET authority, local user database ownership, shared Windows/Android product logic, explicit migrations and protected terminology.
- No unrelated PARTE/PODSETNIK/licensing policy was changed.
- No private owner/user database or data was committed.
- PASS / NOT PASS: PASS.

## Final status

SUCCESSIVE VALIDATION PASS — FLUTTER ANALYZE PASS — COMPLETE FLUTTER TEST PASS — BUILD GATE OPEN.

IMPLEMENTATION AND POST-VALIDATION WINDOWS/ANDROID RELEASE BUILDS PASS — OWNER RUNTIME PENDING.
