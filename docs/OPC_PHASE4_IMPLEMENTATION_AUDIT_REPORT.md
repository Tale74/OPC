# OPC Phase 4 Implementation / Audit Report

**Baseline:** `336552ff40eaa72321670cb554ebd1d6d784d30c`
**SCENARIO lock:** `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`
**Task:** forensic current→target migration and dead-code/superseded-implementation audit
**Final status:** `PHASE 4 PASS — CURRENT→TARGET MIGRATION PATH AND FORENSIC IMPLEMENTATION CLASSIFICATION DEFINED — READY FOR LOGOS REVIEW`

## Files and methods read

The audit read the eight Phase 3 target documents, current authority/roadmap/quality documents, SCENARIO lock/report, 14 synchronized pseudocode views, 234 relevant SOURCE/test/platform/configuration/script artifacts, migration/recovery fixtures, JSON/backup tests and Git history for concentrated files. Methods were read-only repository inventory, import aggregation, reference search, symbol/size inspection, compatibility-keyword inspection, test taxonomy counting and `git log --follow` lineage review.

## Classification counts

| Measure | Count |
|---|---:|
| Decision-matrix classification rows | 23 |
| `PROVEN DEAD` | 1 |
| Compatibility/migration protected rows | 11 |
| Recode candidates | 1 |
| Partial rewrite candidates | 2 |
| Full reconstruction candidates | 0 |
| Characterization sufficient for bounded contracts | 2 |
| Characterization partial or mixed overall | 9 |
| Characterization insufficient | 0 for a current block; critical rewrite seams remain partial |

## Main findings

- Current dependency direction has proven direct cycles between PREDMET and settings, PREDMET and PODSETNIK, and `core/utils` with database/PREDMET.
- PREDMET is the correct authority but currently carries too much application/presentation/infrastructure orchestration.
- The JSON/backup monolith and database concentration are the two CRITICAL migration targets; both have meaningful tests but incomplete characterization for rewrite.
- The Phase 3 policy/finance home is viable; current code should be moved/refactored without creating a second business authority.
- Reminder MVP code is active; ambiguous signal semantics are owner-gated, not dead.
- One tracked placeholder, `export_utils_replacement.dart`, is proven dead by complete reference/history/compatibility checks. It was not removed.

## Owner and protected gates

- SCENARIO remains locked. Any physical restructuring is `REQUIRES EXPLICIT SCENARIO UNLOCK TASK`.
- PODSETNIK source facts remain PREDMET-owned; derived schedule/delivery/confirmation state may be PODSETNIK-owned; signal taxonomy/business meaning remains owner-gated.
- Database migration history, recovery, legacy JSON, backup/restore, platform branches, generated code and historical data are protected.
- No business roadmap reprioritization was made.

## Explicit no-implementation confirmation

No SOURCE, test, schema/migration, dependency, configuration, CI, platform, runtime/private-data, database, SCENARIO or pseudocode content changed. No file was moved, deleted, refactored, recoded or rewritten. No commit or push occurred. The review ZIP is local, ignored and non-authoritative.
