# OPC Phase 5 — scenario persistence schema-1 invariant closure

**Task branch:** `task/OPC-PHASE5-SCENARIO-PERSISTENCE-INVARIANTS`
**Base SHA:** `6985b8afc3ce65905f0d39fd489361aa3d2fa751`
**Application source baseline:** `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`
**Scope:** bounded schema-1 persistence contract hardening only.

Protected rollback evidence:

- Archive:
  `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE5_SCENARIO_PERSISTENCE_INVARIANTS_20260802.zip`
- SHA-256:
  `9EBF5F350ACDEC5EC9F789CB871CAD09B885962E37AEC6E0BCD1C3A6D501FDC3`
- Restore marker:
  `docs/tasks/OPC_RESTORE_POINT_PHASE5_SCENARIO_PERSISTENCE_INVARIANTS_20260802.md`

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — post-zero authority, Incident/Anti-Drift Register,
current development state, authoritative dependency plan, purpose/anti-drift
manifest, project map and latest autoreview were read before implementation.

## Owner and anti-drift boundary

This task does not create a new business rule and does not change accepted
scenario behavior. PREDMET remains the only business truth. The existing
hard-coded evaluator, scenario ordering and current IRiU lifecycle remain
authoritative. A technical PASS does not authorize scenario migration,
reconciliation or UI policy.

The task is restricted to:

- preventing future callers from bypassing `ScenarioAssignmentSnapshot`
  invariants;
- making schema-1 create and decode paths use the same canonical text rules;
- preserving wire keys, enum names, schema version and golden hash;
- proving the boundary with focused tests.

Explicitly untouched: Drift tables/migrations/generated code, JSON and full
backup lanes, repository/materialization, stale-row reconciliation, STANJE
ROBE compensation, SCENARIO UI, reminders/PODSETNIK, runtime data and build
artifacts.

## Implemented correction

`ScenarioAssignmentSnapshot` now exposes only validated `create` and
`fromJsonMap` construction paths; its internal constructor is private.
Scenario consequence category IDs and criterion values are trimmed and reject
empty input before the immutable graph is hashed. Optional provenance
identities are normalized and reject whitespace-only input at the public
constructor boundary. No hash algorithm or schema-1 wire representation was
changed.

## Evidence

- Focused persistence test:
  **19 passed, 0 failed**.
- Combined scenario/package/default/mutation/persistence tests:
  **30 passed, 0 failed**.
- Targeted analyze:
  **PASS**, no issues (24.7 s).
- Full `flutter analyze --no-pub`:
  **PASS**, no issues (44.1 s).
- Full `flutter test --no-pub`:
  **307 passed, 1 skipped, 0 failed** (20:32).
- Golden schema-1 payload/hash remains:
  `33eaaf8fa7007b90d9c4f8ee6fd5021038b9d5b1136a402ab4b51861c29b2797`.
- No build was run; runtime acceptance remains a separate cumulative owner
  gate.

## Gate review

The watchdog review confirmed:

1. no direct production callers bypass the public factories;
2. no ordered-rule field or v2 serializer was introduced;
3. no JSON/backup/repository/Drift/runtime path changed;
4. the existing schema-1 golden payload/hash is byte-stable;
5. the next safe dependency is a versioned transfer envelope and parity suite.

## Remaining dependency sequence

1. Version the scenario/JSON/full-backup envelope while preserving schema-1
   legacy snapshots and rejecting malformed input atomically.
2. Add repository materialization and migration/recovery fixtures only after
   the envelope is proven.
3. Add provenance/backfill and ODQ-SCENARIO-001 reconciliation with stale-row
   removal, value-loss handling, retry/rollback, STANJE ROBE compensation and
   completed/locked PREDMET guards.
4. Prove Windows/Android single-PREDMET and full-backup semantic parity.
5. Only then implement SCENARIO UI/default editing and subsequently inventory
   PODSETNIK signals with owner-confirmed business meaning.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES. UTF-8/no-BOM, diff, focused/full test and
analyze gates are recorded; scope remained within the approved Phase 5 slice.

PASS / NOT PASS: PASS.

**Implementation result:** `TECHNICAL PASS — SCHEMA-1 PERSISTENCE INVARIANTS
CLOSED; NO RUNTIME DATA PATH OPENED.`
