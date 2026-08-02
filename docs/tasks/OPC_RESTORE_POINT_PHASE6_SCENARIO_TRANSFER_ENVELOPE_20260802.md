# OPC restore point — Phase 6 scenario transfer envelope

**Task branch:** `task/OPC-PHASE6-SCENARIO-TRANSFER-ENVELOPE`

**Base SHA:** `8cbaa879d699efbdab966eaadac2cdf23edf2275`

**Protected backup:**
`C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE6_SCENARIO_TRANSFER_ENVELOPE_20260802.zip`

**Backup SHA-256:**
`5A0C964100DE1BABA0A53DEA10E55456D09F0872F769709995746E367E0DD81E`

## Scope

This restore point protects the functional post-zero source before a pure
versioned scenario transfer-envelope contract and parity tests. The planned
slice may define a self-contained envelope over the proven schema-1 scenario
snapshot/provenance contract, but must not wire it into existing JSON, full
backup, repository, Drift, runtime, UI or reminder paths.

No canonical database or live user data was opened or changed while creating
the archive. Git metadata and generated build/tool caches are excluded.

## Rollback rule

If envelope validation, legacy compatibility, hash preservation or parity
tests show an unexplained regression, stop and restore only after verifying the
backup SHA-256. Do not reset Git history or replace a canonical database.

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — post-zero authority, Incident/Anti-Drift Register,
current development state, dependency plan, purpose/anti-drift manifest,
Phase 5 report and project map were read before source work.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: pending task closure.

PASS / NOT PASS: pending task closure.
