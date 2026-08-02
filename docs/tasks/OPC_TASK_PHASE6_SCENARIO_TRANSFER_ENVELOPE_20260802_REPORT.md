# OPC Phase 6 task report — scenario transfer envelope

**Task branch:** `task/OPC-PHASE6-SCENARIO-TRANSFER-ENVELOPE`  
**Base SHA:** `8cbaa879d699efbdab966eaadac2cdf23edf2275`  
**Implementation SHA:** `f8476b0c`  
**Application source baseline:** `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`  
**Scope:** pure versioned scenario transfer-envelope contract and parity tests.

## Protected rollback evidence

- Archive:
  `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE6_SCENARIO_TRANSFER_ENVELOPE_20260802.zip`
- SHA-256:
  `5A0C964100DE1BABA0A53DEA10E55456D09F0872F769709995746E367E0DD81E`
- Restore marker:
  `docs/tasks/OPC_RESTORE_POINT_PHASE6_SCENARIO_TRANSFER_ENVELOPE_20260802.md`

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — post-zero authority, Incident/Anti-Drift Register,
current development state, authoritative dependency plan, purpose/anti-drift
manifest, project map, Phase 5 report and latest autoreview were read before
source work. The Phase 6 backup was created before source changes.

## Owner and anti-drift boundary

PREDMET remains the only business truth. This task adds no business rule,
scenario selection behavior, ordering change or owner approval. Technical PASS
does not authorize runtime data migration or a business-policy change.

The contract is limited to a self-contained envelope around the proven schema-1
`ScenarioAssignmentSnapshot` and `ScenarioIriuProvenance` records. It preserves
the inner snapshot map/hash verbatim, declares `envelopeVersion`, SHA-256 and
canonical payload scope, sorts provenance deterministically, rejects duplicate
IDs, enforces scenario ownership and distinguishes `UNAVAILABLE` from
`COMPLETE` provenance coverage. Unknown/future fields and versions, malformed
nested values and tampered hashes fail closed. Legacy schema-1 input enters only
through an explicit adapter; no implicit upgrade is performed.

Explicitly untouched: existing single-PREDMET JSON and full-backup schemas and
parsers, repository/materialization, Drift tables/migrations, reconciliation or
stale-row deletion, ordered rules, UI, PODSETNIK/reminder behavior, signing or
encryption, ID remapping, destination conflict policy, manual STAVKA transfer
policy and all Windows/Android runtime paths. `jsonDecode` cannot detect
duplicate raw JSON keys; a future carrier must add a raw-parser gate if that
guarantee is required.

## Implemented result

Added:

- `lib/features/predmeti/core_v2/scenario/scenario_transfer_envelope.dart`
- `test/scenario_transfer_envelope_test.dart`

The envelope has strict root/payload keys, fixed version/kind/hash metadata,
deterministic provenance ordering, duplicate-ID and ownership guards, explicit
coverage semantics, schema-1 hash preservation, explicit legacy adaptation,
typed malformed-JSON rejection and round-trip encoding.

## Validation evidence

- Focused envelope test:
  **12 passed, 0 failed**.
- Combined scenario contract set:
  **43 passed, 0 failed**.
- Full `flutter analyze --no-pub`:
  **PASS, no issues (59.5 s)**.
- Full `flutter test --no-pub`:
  **319 passed, 1 skipped, 0 failed (20:41).**
- No build was run; Windows/Android runtime acceptance remains a separate
  cumulative owner gate.

## Future dependency gates

The next task must decide, with owner approval, carrier placement and root schema
bump (single PREDMET and full backup), legacy parity matrix, atomic destination
validation, PREDMET conflict/ID reassociation, manual STAVKA transfer scope and
security/signing policy. Existing roots must not silently drop a future scenario
block; no carrier wiring is part of Phase 6.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES. UTF-8/no-BOM, diff, focused/combined/full
test and analyze gates are recorded; scope remained within the approved Phase 6
pure-contract slice.

PASS / NOT PASS: PASS.

**Implementation result:** `TECHNICAL PASS — VERSIONED SCENARIO TRANSFER
ENVELOPE CONTRACT CLOSED; NO RUNTIME DATA PATH OPENED.`
