# OPC task report — Gate 2A IRiU/KATALOG picker characterization

**Status:** `CHARACTERIZATION PASS; PERFORMANCE CORRECTION DEFERRED`

**Date:** 2026-08-01

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES

PASS / NOT PASS: PASS

## Scope and authority

- Branch: `task/OPC-GATE2-IRIU-KATALOG-PERFORMANCE-EVIDENCE`.
- Base SHA: `c08d47271e92fa4f9ea9d8f61765e87130c88135`.
- This is a test/documentation-only characterization. No production source,
  database schema, migration, catalog query, IRiU ordering or PREDMET truth was
  changed.
- Existing protected restore evidence remains available through
  `docs/tasks/OPC_RESTORE_POINT_PRE_EXPLICIT_ZAVRSEN_20260801.md` and the
  protected Gate 0 archives. Git rollback is sufficient for this test-only
  change.

## Source-confirmed route

The global picker awaits `getKatalogSaArtiklimaLightweight()`. The repository
loads visible categories and then one lightweight summary query per visible
KATALOSKA category. Summary queries select IDs, stable IDs, names, prices and
photo presence; photo bytes are read separately and lazily after the picker
route is shown. This identifies a measurement boundary, not a confirmed
performance cause.

## Characterization implemented

`test/katalog_picker_repository_characterization_test.dart` verifies:

- visible category order and article order;
- stable article identity, name and price;
- `hasPhoto` without loading photo bytes into the summary;
- separate photo-byte lookup;
- scoped loading excludes unrelated categories.

Focused result: `2/2 PASS`.

One representative synthetic in-memory run printed diagnostic values:

- global lightweight cold: `116 ms`;
- global lightweight warm: `37 ms`;
- `25` visible categories and `105` synthetic/seeded articles in that fixture.

These values have no threshold and are not Windows/Android runtime evidence.

## Deferred performance decision

Owner runtime must measure separately on the target Windows and Android
fixtures:

1. repository await;
2. dialog first frame;
3. first photo BLOB read;
4. image decode/paint.

Only after those measurements may a batched summary query, bounded cache,
index or schema change be considered. No root cause is claimed from this
characterization, and no artificial timeout or broad test suite was used.

## Git and runtime gate

Final status requires commit/push, report in Git, final/local and origin SHA
equality, and a clean worktree. Build and Windows/Android runtime remain
deferred to the cumulative owner gate.
