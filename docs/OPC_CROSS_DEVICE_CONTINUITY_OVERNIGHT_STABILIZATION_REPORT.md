# OPC Cross-Device Continuity — Overnight Stabilization Report

Date: 2026-08-12/13  
Branch: `task/OPC-CROSS-DEVICE-CONTINUITY-OVERNIGHT-STABILIZATION`  
Baseline: `26840fe38489b4fbf4cac6cf441c694d11322405`

## Overall status

**OVERNIGHT PARTIAL — SAFE OWNER-INDEPENDENT WORK EXHAUSTED**

The production Single-PREDMET carrier, IRiU order partition, replacement
snapshot lifecycle, KATALOG continuity tests, owner-independent LISTA urn
labels, concrete-article editor projection, and citation-row PDF presentation
are implemented and targeted tests pass. Historical duplicate survivor choice
is now deterministic and proven on a fresh copy; canonical mutation remains
deferred until the final release/startup gate. Android physical-device
acceptance remains explicitly outside the owner-independent boundary.

## Runtime/database provenance

Production source resolves Windows `kDatabaseName = opc_v4_release` through
`driftDatabase(name: kDatabaseName)`. The active record used by the installed
Windows runtime is proven as:

`C:\Users\Steva\Documents\opc_v4_release.sqlite`

Metadata before SQL: 82,829,312 bytes; last write
`2026-08-12T21:17:16.2701837+02:00`; SHA-256
`A5A5C4CF880C2D5116EE42D171CAB03EC8523003DBFB1B910D7D9FFDC26762C1`.

A fresh forensic copy was created at:

`C:\Projekti\OPC\OPC v.1\RUNTIME\forensic_db\overnight_active_windows_20260812_224403\opc_v4_release_active_windows_forensic_copy.sqlite`

The copy is byte-for-byte hash-identical. All SQL inspection was read-only on
the copy; the canonical database was not mutated. The copy reports SQLite
`user_version=27`, `integrity_check=ok`, and contains target PREDMET
`120826_1949` (id 113, OPEN), 18 IRiU rows, one applied scenario snapshot, and
provenance split between `OSNOVNI_PAKET` and `SCENARIO_PAKET`.

The target database also confirms the historical KATALOG condition: 2,924
`CITULJA_POLITIKA` rows across 34 business tuples, 1,459 `CITULJA_NOVOSTI`
rows across 17 tuples, and 13 unresolved historical IRiU stable-article
references. No canonical cleanup was attempted; survivor selection remains
owner-dependent where references/media differ.

## Implemented owner-independent work

### Single-PREDMET SCENARIO carrier

`json_export_import.dart` now emits an optional `singlePredmetScenario` block
using the existing `SinglePredmetScenarioCarrierBlock`. It carries the applied
assignment snapshot, provenance coverage, and transfer-index references; hashes
and ownership are validated. Import resolves destination IDs only after rows
are inserted, restores the snapshot/provenance, and keeps legacy schema-6/7
files readable without falsely labelling reconstructed state as imported.
Full backups now carry scenario snapshots and provenance. Replacement import
clears the preserved local PREDMET snapshot before restoring an incoming valid
carrier; absent carrier remains legacy behavior and is documented as pending
UX/policy rather than silently upgraded.

### IRiU order integrity

`IriuOrderingService` and repository rebuilds now use provenance to enforce
`OSNOVNI_PAKET → SCENARIO_PAKET → unclassified managed → manual/other`.
The existing business order remains the tie-breaker within each partition.

### LISTA PDF

Urn labels now use established document terminology: `Parcela`, `Broj`, `Red`,
`NPK`. The shared LISTA item projection no longer removes
`documentScopedOut` rows, so financially included citation rows remain visible
and reconcile with `ROBA I USLUGE`. Shared itemized derivatives inherit this
prepared data; NALOG's intentionally narrower seven-category scope is
unchanged.

### Concrete KATALOG article projection

The shared IRiU display resolver now gives a non-technical stored concrete
article name precedence over the current category label. This applies to all
KATALOG-backed categories, preserves category identity in `interniNaziv`, and
keeps an imported row readable when the receiver has no matching KATALOG row.

### KATALOG continuity/repair preparation

The tuple-idempotent citation seed path is source-confirmed and covered by the
existing KATALOG tests. A fresh-copy repair proved deterministic `MIN(id)`
survivors for 51 exact citation tuples, removed 4,332 duplicate rows, preserved
the full target PREDMET/IRiU truth, and left the repaired copy integral and
idempotent. The canonical database was not mutated because final startup and
release validation are not yet complete.

## Validation

Passing targeted suites:

- `test/single_predmet_scenario_carrier_contract_test.dart` — 13 passed.
- `test/json_transfer_regression_test.dart` — 22 passed.
- `test/iriu_ordering_partition_test.dart`, KATALOG policy, scenario policy,
  and ceremony/PDF label suites — 16 passed, 2 documented legacy skips.

The Windows release build passed (`build\\windows\\x64\\runner\\Release\\OPC.exe`).
The full analyzer and complete Flutter suite exceeded the local environment
timeout without a result; the Android release build also exceeded the timeout.
Real Windows startup acceptance was not completed, and Android
physical/wireless transfer and install acceptance remain explicitly deferred
by the task boundary.

## Deferred decisions and next safe step

Remaining gates are validation of the final release artifacts, real Windows
startup (if computer-use becomes available), and canonical repair authorization
after those gates. Concrete selected-article labels and citation-row
visibility are locked implementation decisions, not owner-dependent work.
