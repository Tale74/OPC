# OPC Phase 8 task report — Single-PREDMET carrier adapter contract

**Task branch:** `task/OPC-PHASE8-SINGLE-PREDMET-CARRIER-ADAPTER`  
**Base SHA:** `12dc941`  
**Implementation SHA:** `7916ba125907d55ec800b36910dff89cc1dc0c82`  
**Application source baseline:** `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`  
**Scope:** pure Single-PREDMET scenario carrier adapter; no root JSON wiring.

## Protected rollback evidence

- Archive:
  `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE8_SINGLE_PREDMET_CARRIER_ADAPTER_20260802.zip`
- SHA-256:
  `2FA4A5D343165F974E456FFC8E05E7CEA4BBCB318E7939D5855DC7453693F84F`
- Restore marker:
  `docs/tasks/OPC_RESTORE_POINT_PHASE8_SINGLE_PREDMET_CARRIER_ADAPTER_20260802.md`

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — post-zero authority, Incident/Anti-Drift Register,
current development state, authoritative dependency plan, purpose/anti-drift
manifest, project map, Phase 7 report and accepted five-decision carrier gate
were read before source work. Backup was created before source changes.

## Boundary

This task adds a pure adapter over the proven `ScenarioTransferEnvelope`:

- source-local `iriuId` values become deterministic `iriuTransferIndex`
  references scoped to the exported IRIU list;
- destination IDs are supplied explicitly during preflight resolution and are
  never inferred from source IDs;
- snapshot/hash, provenance origin, ownership, duplicate-index, coverage,
  malformed-input and carrier-hash invariants are enforced;
- `COMPLETE` coverage must identify every transferred IRIU row;
- `UNAVAILABLE` carries no provenance references;
- RUČNA STAVKA and LEGACY provenance remain outside automatic scenario cleanup.

The adapter is not a destination reassociation authority. The future carrier
must supply a deterministic canonical IRIU order, validate row identity/content,
and build the complete transfer plan before any repository transaction.

Explicitly untouched: existing Single-PREDMET JSON export/import, root schema
7→8 wiring, full-backup JSON, repository, Drift, migrations, materialization,
reconciliation, ordered rules, UI, PODSETNIK, runtime and canonical data.

## Implemented files

- `lib/features/predmeti/core_v2/scenario/single_predmet_scenario_carrier_contract.dart`
- `test/single_predmet_scenario_carrier_contract_test.dart`

## Validation evidence

- Focused adapter tests: **13 passed, 0 failed**.
- Combined persistence/envelope/adapter set: **44 passed, 0 failed**.
- Full `flutter analyze --no-pub`: **PASS, no issues (58.5 s)** after the
  adapter ownership/coverage corrections.
- Full `flutter test --no-pub`: **332 passed, 1 skipped, 0 failed (22:03)**.
- No build or runtime was run.

## Next dependency

The next bounded task is a pure Full-backup aggregate adapter. Only after both
carrier contracts and parity fixtures pass may a separate task wire root schema
8/9 export/import with strict preflight and rollback. This task does not change
accepted behavior or authorize runtime data mutation.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: pending closure commit; full test and analyze are
now complete.

PASS / NOT PASS: PASS.

**Implementation result:** `TECHNICAL PASS — SINGLE-PREDMET CARRIER ADAPTER
CONTRACT CLOSED; NO ROOT JSON OR RUNTIME DATA PATH OPENED.`
