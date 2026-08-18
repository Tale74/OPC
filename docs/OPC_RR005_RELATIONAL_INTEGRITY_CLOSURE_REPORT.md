# RR-005 Relational-Integrity Closure Report

## Decision

**RR-005 — DEFECT PROVEN — BOUNDED CORRECTION REQUIRED.**

All 36 findings are invalid current technical data under the published authority. They are not classified as valid historical residue, and no parent reconstruction or child-row repair was performed.

## Protected baseline

| Measure | Result |
|---|---|
| Branch | `task/OPC-RR005-RELATIONAL-INTEGRITY-CLOSURE` |
| Parent / HEAD | `6e909ff6c8aba25a7f7f255f4451e2bc8e3e07fa` |
| Canonical database | `C:\Users\Steva\Documents\opc_v4_release.sqlite` |
| Canonical SHA-256 pre/post | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` / unchanged |
| user_version | 27 |
| `integrity_check` | `ok` |
| `foreign_key_check` | 36 rows: 34 provenance, 2 snapshots |
| Canonical mutation | None |
| Repair authorization | `NO` for every finding |

## Authority and source reconstruction

`iriu_provenance` and `predmet_scenario_snapshots` were introduced in schema v23 (commit `89228d9`, 2026-08-01) with declared `ON DELETE CASCADE` relationships. The PREDMET hard-delete coordinator/repository predates that addition (commit `d27fa76`, 2026-07-30) and remains unchanged in the relevant deletion list: it explicitly deletes contacts, logs, IRiU and lifecycle decisions, then deletes PREDMET, but does not explicitly delete either provenance or scenario-snapshot rows. Current connections report `PRAGMA foreign_keys=0`; therefore the declared cascades are schema intent, not effective runtime cleanup.

Current provenance is operational, not an ownerless audit store: it is written for live IRiU rows, read for ordering and transfer/export coverage, and exported only when its IRiU parent is in the live export set. Current snapshots represent a PREDMET's scenario assignment and are read by current scenario/export paths; full backup filters snapshots to live PREDMET IDs. No current authority permits an orphan technical row to keep a deleted business entity alive.

The canonical recovery/stabilization authority states that current state is authoritative, user deletion is final, technical rows without a live owner are removed, and deleted PREDMET/IRiU entities are not reconstructed. Historical source contains no migration/backfill that authorizes preserving these ownerless rows. The earlier forensic-copy cleanup deleted orphan dependents and explicitly did not remove current PREDMET truth; that evidence supports correction of the dependent rows, not reconstruction of parents.

## Disposable current-tip reproduction

A temporary characterization test used the actual current `PredmetiRepository.obrisiPredmet` implementation on an in-memory disposable database. It inserted one valid PREDMET, one IRiU row, its provenance row and its scenario snapshot, then invoked the normal hard-delete path. Result: **1/1 PASS** proving the current path leaves exactly one orphan provenance row and one orphan snapshot row with `foreign_key_check` enabled for inspection. The temporary test was removed; no test artifact remains.

Existing focused evidence remains valid: hard-delete coordinator **4/4 PASS**; scenario reconciliation and application contracts **8/8 PASS**. Those tests do not assert the two omitted child tables, which is the characterization gap closed by the temporary reproduction.

## Group A — 34 `iriu_provenance → iriu`

All 34 rows reference absent IRiU parents. Their origins are operational (`OSNOVNI_PAKET` or `SCENARIO_PAKET`); current code creates provenance together with live IRiU rows and later reads it only through live IRiU joins/ID sets. The current hard-delete path deletes IRiU directly without deleting provenance, and the disposable reproduction proves equivalent orphan provenance can be created by valid current behavior. Historical parent deletion events are not individually logged in the child table, so no deleted IRiU may be reconstructed. Classification for every row: **`INVALID CURRENT DATA — DEFECT PROVEN`**, confidence high.

## Group B — 2 `predmet_scenario_snapshots → predmeti`

Rows for technical PREDMET IDs 114 and 115 have no current PREDMET parent. Snapshot existence proves those IDs were once used as PREDMET owners, but the deletion event is not retained in the snapshot row. The current hard-delete path does not delete snapshots, and the disposable reproduction proves an equivalent orphan snapshot can be created by valid current behavior. Snapshots are not an independent business authority; recreating either PREDMET would violate the owner rule. Classification for both rows: **`INVALID CURRENT DATA — DEFECT PROVEN`**, confidence high.

## Closure boundary and successor

No row was deleted, relinked, synthesized, reconstructed or repaired. The bounded successor is **`RR-005 provenance/snapshot orphan cleanup and hard-delete contract correction with disposable acceptance`**. That successor must decide and implement the safe dependent cleanup, preserve PREDMET authority, and prove canonical pre/post identity; it is not executed by this task.

RR-008, RR-010, RR-011, JSON/interoperability work, SCENARIO, Phase 5 and unrelated successors remain unchanged.
