# RR-005 FK Finding Classification Matrix

The complete row-level register is review-only at `REVIEW/OPC_RR005_RELATIONAL_INTEGRITY_CLOSURE_PACKAGE/ROW_LEVEL_FORENSIC_REGISTER.csv`; it contains technical IDs, field hashes and aggregates only.

| Group | Count | Child → parent | Current parent state | Current-flow reproduction | Classification | Confidence | Successor | Repair authorization |
|---|---:|---|---|---|---|---|---|---|
| A | 34 | `iriu_provenance.iriu_id → iriu.id` | All 34 parents absent | 1/1 disposable reproduction proves equivalent provenance orphan | INVALID CURRENT DATA — DEFECT PROVEN | HIGH | RR-005 provenance/snapshot orphan cleanup and hard-delete contract correction with disposable acceptance | NO |
| B | 2 | `predmet_scenario_snapshots.predmet_id → predmeti.id` | IDs 114 and 115 absent | 1/1 disposable reproduction proves equivalent snapshot orphan | INVALID CURRENT DATA — DEFECT PROVEN | HIGH | RR-005 provenance/snapshot orphan cleanup and hard-delete contract correction with disposable acceptance | NO |
| Total | 36 | Both protected relationships | No current parent for any finding | Current valid hard delete reproduces both classes | INVALID CURRENT DATA — DEFECT PROVEN | HIGH | RR-005 provenance/snapshot orphan cleanup and hard-delete contract correction with disposable acceptance | NO |

Historical parent existence is technically inferred for rows created by current insertion contracts, but individual deletion events are not recoverable from these child rows. That uncertainty does not authorize reconstruction; it is covered by the bounded correction successor.
