# OPC restore point — Phase 7 scenario carrier/parity audit

**Task branch:** `task/OPC-PHASE7-SCENARIO-CARRIER-PARITY-AUDIT`

**Base SHA:** `a5fc05e731efb627fa1b11c362118914ac081072`

**Protected backup:**
`C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE7_SCENARIO_CARRIER_PARITY_AUDIT_20260802.zip`

**Backup SHA-256:**
`85BDA3743B681EE9215B719E01C2C147B59C142EC779169F5A0D8A49D8324719`

## Scope

This restore point protects the post-zero functional source before a read-only
audit of future scenario-envelope carrier placement and Windows/Android parity.
The audit may inspect existing single-PREDMET JSON, full-backup JSON, source
tests and current documentation, but must not modify application code, JSON
schemas, backup/restore paths, Drift, repository, runtime, UI, reminders or
canonical data. Owner-gated carrier, conflict and reassociation decisions are
not inferred from technical evidence.

## Rollback rule

If the audit produces unexplained source drift or invalid documentation, stop
and restore only after verifying the backup SHA-256. Do not rewrite Git history,
replace the canonical database or treat technical parity as owner approval.

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — post-zero authority, Incident/Anti-Drift Register,
current development state, authoritative dependency plan, purpose/anti-drift
manifest, project map and Phase 6 report were read before the audit.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: pending audit closure.

PASS / NOT PASS: pending audit closure.
