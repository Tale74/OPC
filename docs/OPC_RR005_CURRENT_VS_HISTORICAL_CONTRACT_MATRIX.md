# RR-005 Current-vs-Historical Contract Matrix

| Boundary | Current evidence | Historical evidence | Classification consequence |
|---|---|---|---|
| DDL/schema | v23 tables declare `ON DELETE CASCADE` from provenance→IRiU and snapshots→PREDMET | Tables introduced after the original hard-delete path | Declared cascade is intent, not proof that existing rows were cleaned |
| Runtime FK mode | Current connections report `PRAGMA foreign_keys=0` | No historical evidence of enforced runtime cleanup | Application-owned cleanup is authoritative for current behavior |
| PREDMET hard delete | Explicitly deletes contacts, logs, IRiU and lifecycle decisions, then PREDMET; omits provenance and snapshots | Hard-delete code predates v23 and was not amended for the new tables | Valid current flow can create equivalent orphan rows |
| Provenance purpose | Operational ordering/export/transfer metadata attached to live IRiU | No authority establishes ownerless provenance as retained audit history | 34 orphan provenance rows are invalid current data |
| Snapshot purpose | Current PREDMET scenario assignment used by scenario/export paths | Historical snapshot immunity protects values, not ownerless rows | 2 orphan snapshots are invalid current data |
| Migration | v23 creates the tables; no backfill or preservation rule for missing parents found | Earlier schema versions had no equivalent child tables | Migration history does not justify retaining current orphans |
| Restore/import | Full backup filters provenance to exported live IRiU and snapshots to exported live PREDMET; restore clears/reimports child tables | Clean-room restore evidence expects zero unexpected FK rows | Orphans are excluded from the supported current transfer boundary |
| Business authority | PREDMET remains sole lifecycle/business truth; user deletion is final | Deleted entities are not reconstructed from technical residue | No parent reconstruction authorized |
| Forensic-copy cleanup | Earlier repair evidence deleted orphan dependents only and preserved live business rows | Repair copy is evidence, not canonical mutation authority | Correction successor must operate only on disposable data first |

## Required successor proof

1. Add/verify explicit cleanup for provenance and snapshots in the bounded hard-delete contract.
2. Prove current valid deletion leaves no unexpected FK rows on disposable data.
3. Revalidate restore/import filtering and retry behavior.
4. Preserve canonical SHA and do not reconstruct PREDMET or IRiU rows.
