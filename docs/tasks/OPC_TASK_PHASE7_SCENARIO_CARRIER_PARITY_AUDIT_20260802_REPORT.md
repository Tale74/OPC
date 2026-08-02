# OPC Phase 7 task report — scenario carrier/parity audit

**Task branch:** `task/OPC-PHASE7-SCENARIO-CARRIER-PARITY-AUDIT`  
**Base SHA:** `a5fc05e731efb627fa1b11c362118914ac081072`  
**Application source baseline:** `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`  
**Scope:** read-only audit of future scenario-envelope carrier integration and
Windows/Android semantic parity.

## Protected rollback evidence

- Archive:
  `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE7_SCENARIO_CARRIER_PARITY_AUDIT_20260802.zip`
- SHA-256:
  `85BDA3743B681EE9215B719E01C2C147B59C142EC779169F5A0D8A49D8324719`
- Restore marker:
  `docs/tasks/OPC_RESTORE_POINT_PHASE7_SCENARIO_CARRIER_PARITY_AUDIT_20260802.md`

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — post-zero authority, Incident/Anti-Drift Register,
current development state, authoritative dependency plan, purpose/anti-drift
manifest, project map and Phase 6 report were read before the audit. The backup
was created before opening the task branch for audit work.

## Source-to-truth inventory

| Carrier | Current source anchor | Current state | Phase 7 finding |
|---|---|---|---|
| Single PREDMET JSON | `lib/core/utils/json_export_import.dart` `_serijalizujPredmet` (453), `_procitajPredmetTransferPayload` (1787), `_uvoziPredmetUBazu` (818), `_zameniPredmetUBazi` (838); `lib/core/json_transfer/predmet_json_transfer_core.dart` | Root schema 6, consequence extension 7; `predmet`, `iriu`, `kontaktLica` and optional stock block | Existing import regenerates destination PREDMET/IRIU identity. Envelope provenance cannot use source local `iriuId`; a future carrier needs an explicit transfer reference such as `iriuTransferIndex` and owner-approved reassociation rules. |
| Full backup/database JSON | `lib/core/utils/json_export_import.dart` `_serijalizujBackup` (570), `_uvoziBackupUBazu` (910) | Backup schema 8; aggregate tables, lifecycle, stock, reminders and installation data have separate policies | Full backup can preserve explicit database IDs but needs aggregate assignment/provenance records, parent/FK validation and a separate parity fixture. Reminder notification IDs remain device-local under accepted 3A/4A policy. |
| Pure scenario envelope | `lib/features/predmeti/core_v2/scenario/scenario_transfer_envelope.dart` | Envelope v1, schema-1 snapshot, explicit coverage, provenance hash/ownership | Correctly carrier-agnostic and intentionally not wired. It must be validated before any destination mutation. |

Existing carrier parsers tolerate unknown root keys and the single-transfer core
does not know the scenario envelope. Adding a block without a root schema bump
would permit an older parser to silently drop scenario data. The technical
candidate is therefore single root 7→8 and full backup 8→9, but this is not an
owner decision and was not implemented. The current single-transfer decoder
also casts decoded root keys directly; a future carrier parser must convert
non-string keys and malformed raw JSON into a typed validation failure before
the transaction rather than leaking a raw cast error.

## Required parity matrix (future implementation gate)

1. Legacy single roots v6/v7 and backup v8 round-trip unchanged with no
   scenario block.
2. New single root preserves the assignment snapshot/hash, maps provenance only
   through explicit destination-safe transfer references, and rejects missing or
   duplicate references atomically.
3. New full backup round-trips multiple PREDMET assignments, provenance and any
   approved module/scenario configuration while preserving the FK graph.
4. Replacement import keeps the destination PREDMET identity policy explicit,
   remaps IRIU references, and removes only covered scenario-owned rows; RUČNA
   STAVKA and LEGACY rows remain outside automatic scenario cleanup.
5. Tampered/unknown envelope versions, root blocks, nested hashes, coverage and
   ownership fail before destination mutation.
6. `UNAVAILABLE` never implies complete empty provenance; `COMPLETE` has an
   explicitly defined coverage meaning before reconciliation can be considered.
7. Old clients reject a future root version rather than silently losing the
   envelope; old payloads remain accepted according to the approved legacy rule.
8. Windows and Android produce identical pure semantic results; OS-specific
   file/notification mechanics remain outside business payload semantics.
9. Reminder settings contain no device-local notification IDs, and PARTE or
   other derivatives are not transferred unless separately approved.

## Atomic future carrier gate

Before a carrier opens a destination transaction it must: parse the raw carrier
with its duplicate-key policy; validate root kind/version/firm scope and the
entire envelope graph; validate snapshot/envelope hashes, coverage, provenance
ownership and stable-ID/user-FK scope; build an in-memory transfer plan with
explicit legacy/conflict/reassociation decisions; then perform one transaction
for all approved PREDMET/IRIU/snapshot/provenance writes. Any failure rolls back
all writes and produces structured evidence. Existing normalizer defaults must
not run before the envelope conflict gate.

## Owner decision queue — implementation blocked until answered

1. Carrier placement and exact root block names; root schema bump and old-client
   behavior for single JSON and full backup.
2. Whether the single-PREDMET carrier, full-backup carrier or both transfer the
   snapshot, OSNOVNI/SCENARIO provenance, RUČNA STAVKA and LEGACY rows.
3. Stable row identity and destination PREDMET conflict/reassociation policy;
   source `iriuId` and `assignedByKorisnikId` must not be reused as destination
   foreign keys without explicit approval.
4. Whether a snapshot is sufficient when the destination lacks the referenced
   module registry, and what unknown module/scenario behavior is allowed.
5. Meaning of `COMPLETE` coverage and behavior of `UNAVAILABLE` for future
   reconciliation/stale-row protection.
6. Atomic preflight, rollback, backup compatibility and dry-run evidence policy.
7. Signing/encryption/privacy and publisher custody policy.
8. Confirmation that reminder delivery IDs remain device-local and that PARTE
   and other derivatives stay outside this carrier scope.

## Boundary and validation

No application code, JSON/backup schema, repository, Drift, migration,
materialization, reconciliation, ordered rule, SCENARIO UI, PODSETNIK or runtime
behavior changed. This branch contains only the restore marker, audit report and
documentation updates. No build or runtime was run; the prior Phase 6 source
tree remains validated by full analyze and full test (319 passed, 1 skipped).

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES. Source inventory, parity matrix, owner-gated
decision queue, UTF-8/no-BOM and diff gates are recorded; implementation remains
blocked pending owner decisions.

PASS / NOT PASS: PASS — READ-ONLY AUDIT COMPLETE, NO CARRIER WIRING AUTHORIZED.
