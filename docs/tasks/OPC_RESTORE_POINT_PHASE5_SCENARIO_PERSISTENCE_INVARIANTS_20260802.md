# OPC restore point — Phase 5 scenario persistence invariants

**Task branch:** `task/OPC-PHASE5-SCENARIO-PERSISTENCE-INVARIANTS`

**Base SHA:** `6985b8afc3ce65905f0d39fd489361aa3d2fa751`

**Protected backup:**
`C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE5_SCENARIO_PERSISTENCE_INVARIANTS_20260802.zip`

**Backup SHA-256:**
`9EBF5F350ACDEC5EC9F789CB871CAD09B885962E37AEC6E0BCD1C3A6D501FDC3`

## Scope

This restore point protects the functional post-zero source before the bounded
schema-1 scenario persistence invariant correction. The planned slice is
limited to constructor validation, canonical normalization and round-trip
tests. It does not authorize Drift materialization, JSON/backup changes,
repository wiring, stale-row reconciliation, SCENARIO UI or PODSETNIK work.

The archive excludes Git metadata and generated build/tool caches. No canonical
database or live user data was opened or changed while creating the archive.

## Rollback rule

If the focused contract tests, analyze, diff review or parity review show an
unexplained regression, stop and restore the source tree from this archive only
after verifying its SHA-256. Do not reset Git history and do not replace a
canonical runtime database.

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — post-zero authority, Incident/Anti-Drift Register,
current state, dependency plan, purpose/anti-drift manifest and latest sanity
review report were read before source work.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES. The bounded source/test slice remained within
constructor validation, canonical normalization and round-trip evidence.

PASS / NOT PASS: PASS.
