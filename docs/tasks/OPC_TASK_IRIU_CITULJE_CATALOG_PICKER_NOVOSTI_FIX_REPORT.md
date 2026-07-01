## OPC MANIFEST CHECK — TASK START

Manifest read: YES

Manifest compliance checked: YES

PASS / NOT PASS: PASS

# OPC TASK IRIU CITULJE CATALOG PICKER NOVOSTI FIX REPORT

Branch: `task/OPC-IRIU-CITULJE-CATALOG-PICKER-NOVOSTI-FIX`

Base commit: `5b41bca43093485f55349d5a697a061cd2bc08fa`

Task status: `PASS WITH OWNER REVIEW QUEUE`

## Diagnosis

Classification: `CATALOG PICKER SOURCE FILTER BUG`

Exact diagnosed cause: the IRiU table row catalog picker loaded articles only for `widget.stavka.interniNaziv`. The default CITULJE row is `CITULJA_POLITIKA`, so the table picker could not show `CITULJA_NOVOSTI` articles even though Novosti catalog data and constants already existed.

Source evidence:

- `lib/core/constants/iriu_constants.dart` defines both `IriuK.cituljaP` and `IriuK.cituljaNo`.
- `lib/core/database/database.dart` seeds catalog articles for both `CITULJA_POLITIKA` and `CITULJA_NOVOSTI`.
- `lib/features/podesavanja/data/podesavanja_repository.dart` exposes `KatalogPickerArticleSummary.interniNazivKategorije`.
- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart` previously queried only `getArtikliZaKategorijuLightweight(widget.stavka.interniNaziv)`.

## Correction

Changed the row-level IRiU catalog picker only:

- added `resolveIriuCatalogPickerCategoryKeys`;
- resolved `CITULJA_POLITIKA` and `CITULJA_NOVOSTI` rows to both source categories;
- kept all non-CITULJE rows scoped to their original single source category;
- passed the selected article source category through the row picker callback;
- allowed `IriuRepository.azurirajKatalogIzborStavke` to persist the selected source category when it differs from the current row category.

This preserves one visible CITULJE row while allowing the selected article source to remain truthful as Politika or Novosti.

## Files Changed

Source files changed:

- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
- `lib/features/predmeti/data/iriu_repository.dart`

Test files changed:

- `test/iriu_citulje_catalog_picker_test.dart`

Docs changed:

- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`
- `docs/tasks/OPC_TASK_IRIU_CITULJE_CATALOG_PICKER_NOVOSTI_FIX_REPORT.md`

## Source Files Inspected

- `lib/core/constants/iriu_constants.dart`
- `lib/core/database/database.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
- `lib/features/predmeti/presentation/statistika_aggregator.dart`
- `lib/core/config/app_config.dart`

## Pseudocode Docs Updated

- Added `OPC-PSEUDO-029` for the IRiU CITULJE table catalog picker.
- Added `OPC-PSEUDO-INDEX-027` for the row tile picker source boundary.
- Added IRiU CITULJE catalog picker cross-reference to safe-upgrade notes.
- Added Dart Flutter validation runner note for direct Flutter tool snapshot validation.

## Validation

Validation command that passed:

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' --packages='C:\flutter\packages\flutter_tools\.dart_tool\package_config.json' 'C:\flutter\bin\cache\flutter_tools.snapshot' test test\iriu_citulje_catalog_picker_test.dart
```

Result: `+2: All tests passed!`

Runner diagnosis recorded for future project work:

- PowerShell profile `dart` and `flutter` functions point to missing `C:\Projekti\flutter_sdk`.
- `C:\flutter\bin\dart.bat` and `C:\flutter\bin\flutter.bat` can hang and leave `cmd.exe` wrapper processes.
- Plain `dart test` is not valid for Flutter tests that import `flutter_test`.
- Sandbox blocks Flutter cache lock writes at `C:\flutter\bin\cache\lockfile`.
- Direct Flutter tool snapshot outside sandbox was confirmed as the working focused-test command shape.
- Full Flutter analyze through the direct tool snapshot remained running in `analysis_server.dart.snapshot` child processes and was stopped; it was not used as a passing validation.

Post-repair validation recorded after local toolchain correction:

- PowerShell profile and user `FLUTTER_ROOT` now target `C:\flutter`.
- Stale Flutter cache lock files were removed after process checks.
- `flutter --version` completed in this OPC repo and reported Flutter `3.41.7` with Dart `3.11.5`.
- `flutter analyze --no-pub` completed in this OPC repo with `No issues found!`.
- `flutter test --no-pub test\iriu_citulje_catalog_picker_test.dart` completed in this OPC repo with `+2: All tests passed!`.

Manual/runtime verification status: focused automated Flutter test passed; no manual UI runtime click-through was executed.

## Behavior Boundaries

Confirmed unchanged:

- manual KATALOSKA row creation behavior was not changed;
- generic `IZ KATALOGA` add flow was not changed;
- catalog seed data was not changed;
- source constants for Politika and Novosti were not changed;
- PDF behavior was not changed;
- JSON behavior was not changed;
- filename-generation behavior was not changed;
- import/export/backup/restore behavior was not changed;
- evaluator behavior was not changed;
- STANJE ROBE behavior was not changed;
- finance behavior was not changed;
- Web/backend/API/sync/storage/payment/licensing/entitlement/role behavior was not changed.

Confirmed availability:

- `POLITIKA čitulje` remains available.
- `NOVOSTI čitulje` is available from the IRiU table ČITULJE picker source resolution.

No next task, next step, roadmap, priority order, or implementation sequence is recommended by this report.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest read: YES

Manifest compliance checked: YES

PASS / NOT PASS: PASS
