# OPC Phase 3 SCENARIO/IRiU Mutation Characterization Report

**Task branch:** `task/OPC-PHASE3-SCENARIO-IRIU-MUTATION-CHARACTERIZATION`

**Base SHA:** `d544f074f88da25f23b4a750d0d9742e2eb5727c`

**Scope:** source/test characterization only; no production behavior, schema,
migration, canonical database or runtime artifact was changed.

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

The Incident/Anti-Drift Register and the authoritative dependency plan were
read before the audit. INC-001 is preserved as an active incident. Its
scenario-first ordering remains current baseline evidence, not owner-approved
business behavior.

## Owner policy boundary recorded in this task

The owner clarified during this task:

- every scenario (currently hard-coded, later UI-defined) owns a defined set
  of IRiU consequences;
- SCENARIO remains part of PREDMET authority: a PREDMET is not valid without
  its scenario snapshot;
- scenarios belong to MODULI for configuration/default presentation, while the
  selected scenario and its applied snapshot remain PREDMET-owned;
- existing hard-coded scenarios are first offered as module defaults and then
  become upgradeable through the UI; changing a module default must not
  rewrite an existing PREDMET implicitly;
- changing a scenario criterion changes that consequence set: new applicable
  rows are created and no-longer-applicable scenario-owned rows are removed;
- the user must be informed about the scenario consequence change, but stale
  rows must not remain in the PREDMET;
- this does not authorize an isolated delete patch. The post-zero
  `ODQ-SCENARIO-001` contract still requires one business confirmation,
  lifecycle eligibility (`OTVOREN` only), removal of the scenario-owned row and
  its user value, no inactive/archive copy, no automatic restoration on a
  return to an old scenario, operational compensation and safe recovery.

The current UI's per-row `ZADRŽI/UKLONI` dialog therefore remains a
characterized compatibility behavior and is not treated as the final owner
contract: `ZADRŽI` allows exactly the stale state the owner now rejects.

## Source findings

The current mutation paths are:

1. `IriuSegment.initState` starts MESTO SMRTI and BLOK 2 syncs when a PREDMET
   opens. Both are `unawaited`.
2. Each repository sync reads stored rows, inserts missing managed categories,
   and calls `_rebuildBusinessOrdering`.
3. Add/delete paths and several automatic proposal paths also call the global
   ordering rebuild.
4. `PredmetIriuTruthService` can mark an existing managed row inactive, but
   the repository does not remove that stale row when the condition changes.
5. Manual deletion memory suppresses a later automatic re-add until the user
   explicitly inserts the category again.
6. `_rebuildBusinessOrdering` persists the current fixed scenario-first order;
   this is the INC-001 ordering incident and is not corrected here.

Additional deferred risks are recorded rather than changed: sync insertion is
not one enclosing reconciliation transaction; concurrent lifecycle calls can
race; catalog category edits do not rebuild ordering; and duplicate stored
`redosled` values have no deterministic secondary order.

## Characterization evidence

Focused command:

```text
C:\flutter\bin\flutter.bat test --no-pub test/phase3_scenario_iriu_mutation_characterization_test.dart
```

Result: **4 passed, 0 failed**.

Static validation command: `C:\flutter\bin\flutter.bat analyze --no-pub`.

Result: **PASS — no issues found**.

The isolated in-memory database tests prove:

- MESTO SMRTI sync is idempotent and preserves a manual IRiU row;
- manual dismissal suppresses re-addition, while explicit user insertion is
  still retained;
- after a condition change, current code stores the formerly managed rows but
  truth evaluation marks them inactive (confirmed stale-row gap);
- BLOK 2 sync is idempotent and remembers an explicit dismissal.

No test treats the current scenario-first order as the desired future order.
The existing inverse-order test and INC-001 report remain historical/current
baseline evidence until the owner-approved Phase 4 contract replaces them.

## Decision and next dependency

Phase 3 characterization is complete for this bounded mutation boundary. No
production source change is included because safe stale-row removal requires
scenario-owned provenance/snapshot, lifecycle guard, one confirmation,
STANJE ROBE compensation and rollback/retry evidence. The next implementation
task is a separately reviewed Phase 4 SCENARIO reconciliation program; it must
replace the current suppress/keep behavior without touching completed/locked
PREDMET truth and must preserve the INC-001 ordering gate.

No Windows/Android build or owner runtime was run for this test-only task.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES

PASS / NOT PASS: PASS

No canonical database, backup, restore point, Git history or protected
`BACKUPS` content was modified.
