# OPC Task Report — Android STATISTIKA Filter Space UX Fix

## Task identity

- Required base commit: `cccf0ffcecc94fcb333937cf29fc629168d0c2ac`
- Branch: `task/OPC-ANDROID-STATISTIKA-FILTER-SPACE-UX-FIX`
- Task class: implementation

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- yes, safely: Android uses a compact filter presentation appropriate to limited screen space while calculations and desktop behavior remain shared/preserved

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes

Required gate before implementation:
- platform parity

Manifest read: YES

Required files read before changes:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`
- `docs/tasks/OPC_TASK_CATALOG_ARTICLE_DETAIL_FULLSIZE_NAVIGATION_UX_REPORT.md`

## Source-learning summary and diagnosis before fix

- Screen and route: `StatistikaScreen` is defined in `lib/features/predmeti/presentation/izvestaji_screen.dart` and is pushed from two entitled entry points in `lib/features/predmeti/presentation/lista_predmeta_screen.dart`.
- Filter area: `_FilterCard` in `izvestaji_screen.dart` contains the required period title/explanation, all five preset `ChoiceChip` controls, optional custom-date buttons, and the active-period pill. A second explanatory line follows it.
- Data area: the same screen builds a five-tab `TabBar`; the only `Expanded` child is its `TabBarView`, whose `_StatistikaTabBody` pages render summary, adviser, ceremony, death-place, and top-article data.
- Cause: the top-level `Column` permanently lays out the full intrinsic-height filter form before allocating remaining height to `TabBarView`. On narrow portrait screens the five chips wrap across rows; on short landscape screens that same card, padding, explanatory line, app bar, and tab bar consume nearly all vertical space.
- Fixed/unbounded behavior: there is no fixed filter height and no scroll nesting defect in the primary screen. The source-confirmed cause is a permanently expanded, wrapping filter form placed before the only expanded data region.
- Platform/orientation behavior before fix: Android and desktop shared the same widget tree with no `MediaQuery`, orientation, constraint, or platform branch.
- Filter requirements/state: all preset and custom-date controls are functional. `_preset`, `_customDateFrom`, and `_customDateTo` are local screen state. No filter state is persisted to a provider or repository.
- Calculations/data: `_resolveRange` derives dates; `StatistikaSnapshotService` builds PREDMET-derived period input; `StatistikaAggregator` calculates display data. These paths are separate from filter layout.
- Tests discovered: no existing statistics-specific test existed. The repository contained general Flutter tests and the required catalog regression test.
- Chosen fix: Android-specific compact summary plus temporary scrollable bottom sheet is the smallest safe change. It removes the permanent multi-row form in both orientations, retains all controls/state, preserves normal back dismissal, and leaves desktop rendering unchanged.

## Implemented changes

- `lib/features/predmeti/presentation/izvestaji_screen.dart`
  - Added an Android-only layout-policy function.
  - Android permanently shows one dense active-period `ListTile` with a `FILTERI` action.
  - `FILTERI` opens the existing `_FilterCard` in a 90%-height, safe-area-aware, scrollable modal bottom sheet.
  - Preset and custom-date callbacks update the existing parent screen state and refresh the open sheet without recreating/resetting statistics context.
  - Android back closes the standard modal sheet; no orientation lock or custom navigation interception was added.
  - Windows/desktop retains the original filter card and explanatory text.
- `test/statistika_filter_layout_test.dart`
  - Verifies compact presentation is selected for Android and not Windows/Linux/macOS.
- Pseudocode documentation
  - Added `OPC-PSEUDO-031` and index/safe-upgrade cross-references.

No statistical calculation, filter meaning/default, repository, model, or schema code changed.

## Business meaning

STATISTIKA exists to expose business insight derived from PREDMET data. Filters remain accessible controls, but the statistics tabs now receive the majority of permanent Android screen space instead of being squeezed below a multi-row form.

## Risk if changed blindly

Moving filter controls can reset local dates, change period semantics, detach the visible period from aggregation input, break modal back behavior, create landscape overflow, or regress the desktop form. The implementation reuses the existing controls, state, range resolution, snapshot service, and aggregator to avoid those risks.

## Safe upgrade boundary

The change is limited to Android presentation and local filter visibility interaction. Statistics calculations, defaults, date normalization, PREDMET data/model, database schema, persistence, IRiU, PARTA, catalog, finance, PDF, JSON, Web, sync, package/add-on, backend, payment, licensing, and entitlements remain unchanged.

## Pseudocode update

- Added: `OPC-PSEUDO-031 — STATISTIKA screen filter/data layout priority`
- Updated: `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- Updated: `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- Updated: `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`

The entry records `source paths → source behavior → pseudocode → business meaning → risk if changed blindly → safe upgrade boundary` and protects filter/calculation semantics across presentation changes.

## Validation

- `flutter test test/statistika_filter_layout_test.dart --reporter expanded`
  - PASS: `+1: All tests passed!`
- `flutter test test/iriu_citulje_catalog_picker_test.dart --reporter expanded`
  - PASS: `+4: All tests passed!`
- `flutter test --reporter compact`
  - PASS: `+90: All tests passed!`
- `flutter analyze`
  - COMPLETED with one informational issue: unnecessary `dart:typed_data` import in `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`.
  - The issue exists unchanged in required base `cccf0ffcecc94fcb333937cf29fc629168d0c2ac`; no statistics source issue was reported. It was not modified because catalog code is outside this task.
  - Validation is therefore not described as fully analysis-clean.
- `git diff --check`
  - PASS; line-ending conversion warnings only, no whitespace errors.
- `python scripts\validate_opc_manifest_gate.py --base cccf0ffcecc94fcb333937cf29fc629168d0c2ac`
  - PASS for `docs/tasks/OPC_TASK_ANDROID_STATISTIKA_FILTER_SPACE_UX_FIX_REPORT.md`.

## Runtime/build status

Runtime evidence: NOT REQUESTED / NOT PRODUCED — build/runtime test requires Tale approval after validation prerequisites.

No Windows or Android build/runtime artifact was created or requested.

## Scope confirmations

- Statistics calculations were not changed.
- Filter semantics, defaults, date ranges, and grouping were not changed.
- Android statistics data visibility was improved by replacing the permanently expanded form with one compact row; full controls remain available in a temporary sheet.
- Desktop/Windows behavior was not intentionally degraded; it remains on the original full filter-card branch.
- Android back behavior remains the framework-standard modal-sheet dismissal behavior.
- No unrelated PREDMET, IRiU, PARTA, catalog, finance, PDF, JSON, Web, sync, package/add-on, backend, payment, licensing, or entitlement behavior changed.
- No unresolved placeholders remain after final validation results are recorded.

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
- yes

If not compliant, classify:
- not applicable

Manifest compliance checked: YES

PASS / NOT PASS: PASS WITH PRE-EXISTING ANALYZE INFO — implementation and all 90 tests pass; analysis completed with one inherited out-of-scope informational issue.
