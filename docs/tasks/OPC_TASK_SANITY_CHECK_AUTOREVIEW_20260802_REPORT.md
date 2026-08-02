# OPC post-zero sanity-check and autoreview — 2026-08-02

**Branch:** `task/OPC-PHASE4-MODULE-SCENARIO-CONTRACT-AND-UI`
**Review start SHA:** `7c5ef6f6310ee1a5e1261826f660ea474f8b11b0`
**Scope:** read-only source/test/documentation stability review; no application
source or runtime behavior was changed by this review.

The protected rollback evidence for the preceding schema-23 persistence slice
remains `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_SCENARIO_PERSISTENCE_V2_20260802_0900.zip`
(SHA-256 `9FFD8F3E36BABFB0B9CBC117719774F6DB865078FF64DF1FEA229CA38997B3C2`)
with marker `docs/tasks/OPC_RESTORE_POINT_SCENARIO_PERSISTENCE_V2_20260802.md`.
This review adds no application mutation and therefore creates no second
application backup.

## Git and technical evidence

- Branch was confirmed before review.
- `HEAD == origin/HEAD` at review start.
- Worktree was clean before review.
- `flutter analyze --no-pub`: **PASS**, no issues (164.8 s).
- Complete `flutter test --no-pub`: **304 passed, 1 skipped, 0 failed** (22:37).
- Focused persistence suite: **16 passed, 0 failed**.
- Focused scenario characterization suite: **33 passed, 0 failed**.
- Focused JSON/persistence audit set: **37 passed, 0 failed**.
- No build was run, by owner instruction.

The complete suite reached the schema-23 migration, restore, PARTE, scenario,
JSON and Windows persistence tests without a failure. This is technical
evidence only; it is not Windows/Android runtime acceptance.

## Stability conclusion

The current source tree is technically stable under the available automated
evidence. Schema 23 is additive: `scenario_modules`,
`scenario_definitions`, `predmet_scenario_snapshots` and `iriu_provenance` are
present, but no repository, JSON, runtime materialization or UI consumes them.
That isolation is currently a safety property and must be preserved until the
transfer and reconciliation contracts are complete.

The owner-reported scoped Android full-restore PASS after INC-003 is retained:
the unsafe reminder-section error did not recur, PREDMETI/PARTE loaded and
observed completed data/history remained intact. Other data and security
coverage was not tested. This result is separate from cumulative runtime
acceptance on the current schema-23 tip.

## Anti-drift rules reaffirmed

1. PREDMET remains the only business truth; SCENARIO configuration is a module
   definition, while the selected scenario snapshot is PREDMET-owned.
2. Technical diff, test PASS or build PASS never authorizes a business-policy
   change. Owner decisions after the post-zero baseline are the only current
   owner authority.
3. Existing hard-coded scenario behavior remains authoritative until exact
   parity, versioned persistence and rollback evidence exist. No partial
   published default may be seeded.
4. Scenario criterion changes must inform the user and reconcile all
   scenario-owned rows/values; stale rows are not accepted. Manual STAVKA
   additions remain PREDMET-local exceptions.
5. INC-001 ordering evidence is preserved. No ordering or accepted behavior is
   changed under a refactor label.
6. Backup-first, isolated migration, explicit retry/rollback and Windows/
   Android parity are required before data materialization.
7. PODSETNIK signals/UI remain downstream of scenario reconciliation,
   lifecycle, provenance, JSON parity and restore evidence.
8. “Drift” means an unwanted deviation from the approved project flow,
   authority or behavior; it is not a substitute for a source-level fact.

## Findings that block the next implementation slice

These are not current runtime regressions, but must be closed before wiring
the additive schema into production paths:

- `ScenarioAssignmentSnapshot` still exposes a public construction path that
  can bypass some factory invariants. Future repository code must not use it
  until the boundary is private/validated.
- `create()` and `fromJsonMap()` do not normalize every consequence and
  criterion value identically. Whitespace-bearing values can therefore produce
  a hash that fails its own round-trip; normalization/rejection needs a focused
  contract correction.
- Full backup and single-PREDMET JSON currently transfer only scalar
  `businessScenarioId`. They do not transfer schema-23 scenario definitions,
  snapshots or provenance. Materialization before a versioned backup/JSON
  contract could lose data or leave stale module definitions on restore.
- `snapshotZaSaveCommit()` still excludes `businessScenarioId`; future scenario
  assignment changes must participate in unsaved-change identity.
- Existing lifecycle-decision backup rows lack an explicit exported-PREDMET
  filter/parent validation. This remains a parity hardening item.
- The current runtime retains stale scenario rows when criteria become
  inapplicable. ODQ-SCENARIO-001 reconciliation, provenance/backfill,
  STANJE ROBE compensation, retry/rollback and completed/locked guards remain
  the blocking dependency.

## Ordered remaining steps

1. Close the schema-1 constructor/normalization invariants without changing
   accepted behavior; add round-trip regression tests.
2. Define a versioned scenario/backup/JSON envelope that preserves the schema-1
   golden payload/hash and supports the future rule-set without silent loss.
3. Add repository materialization, migration/recovery fixtures and explicit
   provenance classification/backfill for existing rows.
4. Implement one-confirmation ODQ-SCENARIO-001 reconciliation with stale-row
   removal, value-loss handling, STANJE ROBE compensation, retry/rollback and
   completed/locked PREDMET protection.
5. Prove Windows/Android single-PREDMET and full-backup parity on isolated
   fixtures, then implement the SCENARIO UI and user-defined defaults.
6. Only after those gates, inventory PODSETNIK signals and obtain owner
   confirmation of their business meaning before UI/notification work.
7. Separately obtain measured Windows/Android timing evidence for the
   IRIU/KATALOG slowdown and PARTE observations; do not optimize by hypothesis.

## Documentation corrections made by this review

- Current schema references were corrected from schema 22 to schema 23, while
  legacy schema-22 KATALOG behavior is explicitly labeled historical.
- Current-state documentation now records the owner-reported scoped Android
  full-restore PASS and distinguishes it from current-tip runtime acceptance.
- The Phase 4 report now uses only supported provenance origins:
  `OSNOVNI_PAKET`, `SCENARIO_PAKET`, `RUČNA_STAVKA` and legacy.

**Review conclusion:** `TECHNICAL STABILITY PASS — IMPLEMENTATION GATES OPEN
ONLY IN THE ORDER ABOVE; NO PODSETNIK OR SCENARIO RUNTIME WIRING AUTHORIZED BY
THIS REVIEW.`

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` and the
post-zero authority/register documents were reviewed before this autoreview.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES. No application source or runtime behavior was
changed by this review; only current-state, map, pseudocode-index and report
wording was corrected.

PASS / NOT PASS: PASS
