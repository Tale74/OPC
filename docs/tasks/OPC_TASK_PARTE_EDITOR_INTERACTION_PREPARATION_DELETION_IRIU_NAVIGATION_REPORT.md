# OPC TASK — PARTE EDITOR INTERACTION, PREPARATION DELETION AND IRiU NAVIGATION REPORT

## Status

`PARTE EDITOR/DELETION/IRIU REFINEMENT IMPLEMENTATION PASS – WINDOWS/ANDROID RUNTIME VALIDATION PENDING`

Automated validation and both release builds pass. The new interaction,
deletion and navigation flows still require runtime confirmation on Windows and
Android before runtime acceptance can be claimed.

## Git identity

- Branch: `task/OPC-PARTE-EDITOR-GESTURES-PREPARATION-DELETION-IRIU-SHORTCUT`
- Base SHA: `ce4575f84a4f815098755d263ce352ba2eba71af`
- Implementation commit: `b309846c02ff7cd29b56c606c05818d03a58ec21`
- Final branch SHA: pending documentation-verification commit
- Merge to `main`: not performed

## OPC MANIFEST CHECK — TASK START

- Manifest read: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- Manifest compliance checked: PREDMET/IRiU truth, derivative PARTE state,
  platform equality, privacy and protected render/export boundaries.
- PASS / NOT PASS: PASS for source, automated validation and build boundaries;
  runtime validation remains pending.

## Source-learning evidence

| Source | Responsibility | Finding / correction |
|---|---|---|
| `parte_composer_screen.dart` | editor preview and block drag | Parent `InteractiveViewer` and child block `GestureDetector` competed in Flutter's gesture arena. Added explicit edit versus `POMERI PRIKAZ` ownership and session-only controls. |
| `parte_module_screen.dart` | same-PREDMET preparation list | Added discoverable IRiU shortcut and contextual completed-preparation deletion. Successful deletion reloads the authoritative list. |
| `parte_preparation_service.dart` | preparation/media lifecycle | Completed deletion now protects shared media, stages exclusive media, restores on DB failure and purges only after DB success. |
| `parte_preparation_repository.dart` | persisted derivative state | Added cross-preparation media-reference check; deletion remains restricted to completed preparation and one DB row. |
| `parte_media_store.dart` | app-owned media copies | Added reversible staging batch; external originals and exported PDF/DOCX are never targets. |
| `predmet_screen.dart` / `iriu_segment.dart` | existing PREDMET/IRiU UI | Reused the existing route, selected `Roba i usluge`, and focused `POSMRTNE_PARTE` for the same PREDMET. |

## UX audit and selected interaction model

Official Flutter guidance confirms that parent and child recognizers compete in
the gesture arena. Android guidance warns about parent interception and
multi-pointer ownership; Windows guidance favors discoverable viewport controls.

Selected shared model:

- default edit mode: one-pointer drag on a block moves only that block;
- explicit `POMERI PRIKAZ` mode: block movement is disabled and the viewport
  owns pan/pinch gestures;
- visible `−`, percentage, `+`, `UKLOPI`, and `CENTRIRAJ` controls work without
  hidden gestures;
- precise block movement controls remain available as accessibility fallback;
- transform state exists only for the current widget session.

Rejected alternatives:

- sensitivity/hit-area patch: does not resolve gesture ownership;
- hidden two-finger-only contract: insufficiently discoverable and harder to test;
- pan only when no block selected: selection state would unexpectedly change
  the meaning of the same gesture;
- desktop-only scrollbars: would not provide one shared Android/Windows model.

## Deletion lifecycle and authority boundary

Deletion is available only in the context of a completed retained preparation.
The confirmation identifies the PREDMET and states that the operation is
irreversible inside OPC.

Deletion removes:

- the selected `parte_pripreme` derivative row;
- only app-owned media not referenced by another preparation.

Deletion explicitly preserves:

- PREDMET and all its business facts;
- the authoritative IRiU `POSMRTNE_PARTE` row and all other IRiU data;
- every other PARTE preparation;
- reusable templates and portable template JSON;
- external originals and previously exported PDF/DOCX files.

Exclusive files are renamed into an app-owned deletion staging directory before
the DB delete. A failed DB delete restores them. After DB success the staged
files are purged; an exceptional purge failure can leave only isolated app trash,
not an active dangling reference or a partially deleted preparation.

## IRiU shortcut and reverse-shortcut decision

`MODUL PARTE -> same PREDMET ID -> existing PredmetScreen -> Roba i usluge -> POSMRTNE_PARTE`

The route performs no write. If the category is absent, the existing screen
explains that it must be added through the current catalog flow rather than
opening an unexplained generic destination.

A reverse shortcut was intentionally not added. Normal Back already returns to
the same MODUL PARTE instance; pushing another module route from IRiU would
duplicate the stack and risk navigation loops.

## Focused tests prepared

- edit mode disables viewport pan/scale recognizers;
- explicit pan mode enables them and disables block movement;
- block drag changes block coordinates, while viewport pan does not;
- viewport controls remain outside render/output state;
- same-PREDMET shortcut opens `Roba i usluge`;
- completed deletion preserves PREDMET and IRiU `POSMRTNE_PARTE`;
- shared app media is not physically deleted;
- existing PDF/DOCX and preparation regression coverage remains present.

The owner executed Flutter validation and both release builds after
implementation; exact results are recorded below.

## Changed source scope

- PARTE composer viewport UI
- PARTE module list/actions
- preparation lifecycle service/repository
- app-owned media store
- existing PREDMET/IRiU navigation focus
- focused tests and authoritative documentation

Canonical render, PDF, DOCX, templates, printer profile, PREDMET schema and IRiU
business rules were not changed.

## Validation and builds

- Formatter: completed for all changed Dart files; source formatting succeeded,
  followed by a non-code telemetry-file access warning outside the workspace.
- `git diff --check`: PASS (line-ending conversion notices only)
- UTF-8 strict decode: PASS
- Privacy scan of added diff: PASS
- Manifest gate: PASS for this changed task report
- `flutter analyze --no-pub`: PASS — owner final run, 0 issues in 37.7 s
- `flutter test --no-pub`: NOT PASS on first owner run. The new module shortcut
  test mounted the existing PREDMET/IRiU route with long-lived Drift streams,
  and the delete test asserted a transient status label instead of the stable
  refreshed-list identity. The shortcut test now verifies the exact PREDMET id
  at the module navigation boundary without mounting the unrelated heavy target
  screen; the delete assertion checks that the PREDMET card remains while the
  completed-preparation action disappears.
- Focused-test validation history: Flutter 3.41.7 first crashed before test execution
  because a stale generated `build/native_assets/windows/sqlite3.dll` already
  existed (`PathExistsException`, errno 183). The stale `flutter_tester` process
  and only that generated destination file were removed. This is a Flutter-tool
  artifact failure, not a test result. The next owner reruns executed all three
  focused tests: navigation passed, while increasing the synthetic drag and
  merely waiting longer did not stabilize the two remaining UI assertions. The
  gesture assertion is now isolated at the `ParteEditorViewport` callback
  boundary. Repository deletion and PREDMET/IRiU preservation were already
  proven; the production module now also suppresses the deleted preparation's
  action immediately by its unique preparation id during asynchronous list
  refresh. A later preparation receives a different id and is unaffected.
- `flutter test --no-pub test/parte_module_screen_test.dart --reporter expanded`:
  PASS on final owner rerun — 3 passed, 0 failed. This proves module filtering
  and IRiU shortcut targeting, explicit editor/viewport gesture ownership, and
  completed derivative-preparation deletion with PREDMET and IRiU
  `POSMRTNE_PARTE` preservation.
- `flutter test --no-pub`: PASS — 247 passed, 1 skipped, 0 failed
- Windows release build: PASS — `build/windows/x64/runner/Release/OPC.exe`
  (315.3 s)
- Android release APK build: PASS —
  `build/app/outputs/flutter-apk/app-release.apk`, 73.3 MB (844.0 s)
- `git diff --check`: final owner run PASS; line-ending notices only
- OPC manifest gate against base `ce4575f84a4f815098755d263ce352ba2eba71af`:
  PASS for this changed task report
- Strict UTF-8 decode: PASS for all 17 changed/untracked task files before commit
- Privacy scan of added diff lines: PASS; no private runtime evidence added

Commands were executed strictly sequentially:

1. `flutter analyze --no-pub`
2. `flutter test --no-pub`
3. `flutter build windows --release --no-pub`
4. `flutter build apk --release --no-pub`

## Risks and runtime acceptance plan

- Verify mouse/touch block drag and explicit viewport mode on Windows.
- Verify one-finger block drag, pan mode, pinch zoom and narrow wrapping on Android.
- Verify completed deletion cancellation/success/failure and list refresh.
- Verify the same PREDMET and focused `POSMRTNE_PARTE` destination, including Back.
- No physical-print revalidation is required unless protected render/export
  behavior changes during later validation fixes.

## OPC MANIFEST COMPLIANCE — TASK END

- PREDMET remains the sole case authority.
- IRiU `POSMRTNE_PARTE` remains authoritative and is never a deletion target.
- MODUL PARTE remains a derivative technical workflow.
- Windows and Android share the same source policy.
- Private runtime evidence is excluded from Git.
- Automated implementation validation is PASS; Windows and Android runtime
  acceptance for the new flows remains pending.
