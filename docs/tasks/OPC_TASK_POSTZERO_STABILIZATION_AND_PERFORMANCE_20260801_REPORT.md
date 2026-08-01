# OPC task report - post-zero stabilization and performance handover

**Status:** `GATE 1 TECHNICAL PASS; GATE 2 PERFORMANCE AUDIT DEFERRED; OWNER RUNTIME OWED FOR CURRENT TIP`

**Date:** 2026-08-01

## 1. Authority, branch and protection

- Current task branch: `task/OPC-POSTZERO-STABILIZATION-AND-PERFORMANCE`.
- Baseline before this task: `644b8b8c68ef9f9591fcc919fe217c1caa68d8c0`.
- Gate 0 documentation commit: `5ed540258d55d09c72ed5444ca8f862f7341fd24`.
- Gate 1 implementation commit: `7485ad94e5cc15dfe637f2cab207c2f3bd9aca34`.
- Application/source zero baseline remains
  `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`.
- Protected pre-task backup:
  `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_POSTZERO_STABILIZATION_20260801_1300.zip`.
- Backup SHA-256:
  `7aebf100602b0d4513864ea08c434219157e667cbe4c134d4bd6c3d64c72a82e`.
- Protected restore-point marker:
  `C:\Projekti\OPC\OPC v.1\RESTORE_POINTS\RESTORE_POINT_20260801_PRE_POSTZERO_STABILIZATION.md`.

The backup excludes only Git metadata and generated build/tool caches. No
canonical/live database was opened or changed. Git history rewrite, migration,
RI-3 recovery, anonymization/replacement, Web and `OPC_v.1_Int` work remain
outside this task.

## 2. Owner runtime evidence carried into this task

Before the Gate 1 correction, the owner reported the following Android
full-restore runtime result:

- full restore completed without the previous unsafe reminder-section error;
- PREDMETI and PARTE were loaded;
- observed existing data and history on completed PREDMETI remained intact;
- other data and security coverage was not tested;
- reminder delivery/configuration was observed as device-local and not carried
  as a device notification through the JSON backup.

This is scoped owner evidence for the correction artifact tested at that time,
not acceptance of the new Gate 1 application tip. Logical reminder settings,
future platform slots and device-local notification IDs remain separate facts;
no reminder implementation change is made here.

The same runtime cycle reported three separate findings: the empty Ožalošćeni
warning exposed mojibake and a technical block ID, the font-size field did not
show the fitted preview size, and opening the IRIU catalog felt slower. The
first two are addressed below. The catalog observation remains unmeasured and
is not treated as a confirmed cause.

## 3. Gate 1 implementation

The notified, owner-authorized application correction is bounded to PARTE
composition, presentation state and export smoke coverage:

- structural required-block validation now uses the draft/template block set,
  not only content-bearing rendered blocks;
- empty content is omitted from the render plan and from PDF/DOCX output and
  does not block preparation, preview confirmation or export;
- the Ožalošćeni heading is omitted when its content is empty;
- blocker and validation messages use Serbian business labels rather than raw
  IDs or mojibake;
- the selected block's font field follows the fitted
  `ParteRenderBlock.fontSize` after reload, save and selection changes;
- fingerprints include structural block identity so omission of content does
  not erase the structural contract.

No accepted IRiU ordering, reminder policy, PREDMET authority or cross-platform
business behavior was changed.

## 4. Automated evidence

- PARTE domain suite: `28/28 PASS`.
- PDF/DOCX completion suite including empty-content omission: `12/12 PASS`.
- PARTE module/widget suite including fitted-font state smoke: `4/4 PASS`.
- Existing restore/reminder/hard-delete/lifecycle regression selection:
  `27/27 PASS`.
- `flutter analyze --no-pub`: `PASS`, no issues (`70.6 s`).
- .NET `validate_utf8_bom.cs`: `PASS UTF8_NO_BOM` for all five changed source
  and test files.
- `git diff --check`: `PASS`.

The first widget-suite attempt hit a Flutter native-assets cache/concurrency
failure (`sqlite3.dll` duplicate); no assertion or product failure was
reported. Stale Flutter processes were stopped and the same suite was rerun
serially with `4/4 PASS`. No `flutter clean` was required.

The complete Flutter suite and release builds were intentionally not repeated
in this task because the owner explicitly deferred builds/runtime and the
application change is covered by focused tests plus the unchanged prior full
suite/build evidence. Current-tip Windows/Android runtime acceptance remains
owner work.

## 5. Gate 2 IRIU/KATALOG performance disposition

Source audit confirms that the global picker waits for lightweight article data
and currently performs one lightweight article query per visible catalog
category. Article photos are lazy and are not awaited before the picker opens.
This identifies a measurable query boundary, not a proven runtime cause.

No index, schema change, query rewrite or startup change is introduced without
timing/query-plan evidence. The next safe dependency is an owner-run timing
trace on the same Windows fixture (and, if relevant, Android) separating:
catalog button-to-dialog time, repository query time, first frame, and first
photo decode. Until that evidence exists, the slowdown remains a hypothesis.

## 6. Runtime handoff and next dependency

Owner must perform current-tip runtime acceptance separately for Windows and
Android. At minimum, repeat the PARTE empty-content/export path, selected-block
font display, the warning wording, and the existing hard-delete/full-restore
smoke relevant to the built artifact. Record any catalog timing with the
fixture and device class.

This report does not authorize reminder-policy reinterpretation, catalog
performance implementation, migrations, canonical data work or any new
business scope.

## 7. Git completion

The task is complete only when this report and the implementation are
committed and pushed, the final SHA and base SHA are recorded, `HEAD` equals
the upstream tip, and the worktree is clean. Owner runtime acceptance remains
a distinct gate and must not be inferred from technical PASS.
