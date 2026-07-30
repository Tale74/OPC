# OPC post-zero Architecture Decision Gate synthesis

**Status:** `TECHNICAL ARCHITECTURE DECISION PASS - IMPLEMENTATION NOT AUTHORIZED`
**Evidence baseline:** application tree
`e9ea4a9679f0a9f80521fc3aa362e78b7993d073`
**Documentation base:** `1c83724977374477e9d8c969e64ee8c1c958e0f6`
**Date:** 2026-07-30

## 1. Scope

This synthesis closes the technical architecture-choice gate. It does not
approve application code, schema, migration, canonical-data, build, runtime or
business-policy changes.

The application, test and platform tree is byte-identical to the established
functional zero baseline. Existing complete validation evidence therefore
remains applicable: analyzer PASS and complete Flutter test PASS with 247
passed, one skipped and zero failed.

Pre-zero owner decisions referenced by technical audits are treated as
historical or prospective inputs. Current business authority comes only from
the post-zero owner record.

## 2. Evidence used

The decision uses:

- complete source/architecture review;
- PREDMET dependency and module-contract maps;
- referential-integrity and dependent-data audit;
- Windows multiple-instance/source/concurrency evidence;
- Windows startup/exit source and installed-version evidence;
- Android PARTE source audit;
- SCENARIO/IRiU source audit and permanent ordering incident;
- current source and tests at the unchanged application baseline;
- canonical migration and backup/restore technical evidence;
- the post-zero authority, incident register and documentation inventory.

No incomplete runtime attempt is treated as PASS, FAIL or root-cause proof.

## 3. Technical architecture decision

The selected direction is:

```text
RETAIN CURRENT OPC CODEBASE
-> PROTECT PREDMET AND CANONICAL DATA BOUNDARIES
-> PROGRESSIVE LIFECYCLE / REFERENTIAL REFACTOR
-> CONTROLLED CORE_V2 CONVERGENCE
-> BOUNDED SUBSYSTEM REFACTOR OR PARTIAL REWRITE ONLY WHERE PROVEN
```

Full rewrite is rejected by current evidence.

The existing codebase contains working Windows/Android behavior, schema and
migration knowledge, JSON compatibility, document formation, PREDMET/IRiU
business behavior and regression tests. Recreating those assets would increase
canonical-data, parity and regression risk without a demonstrated compensating
benefit.

## 4. Boundary decisions

### 4.1 PREDMET lifecycle and referential integrity

This is the first architecture predecessor after the gate.

The current database declares dependent relationships but does not enable
runtime foreign-key enforcement. PREDMET deletion, anonymization, full restore,
PARTE media, PODSETNIK OS state, stock consequences and logs do not yet share
one explicit lifecycle orchestrator.

Decision:

- retain the Drift/SQLite and PREDMET data core;
- implement no isolated orphan/UI patch;
- use the audited `RI-1` through `RI-5` sequence;
- keep foreign keys off until inventory, explicit lifecycle correction and
  orphan recovery are proven;
- require isolated copies, readable backup proof, restore rehearsal,
  idempotency and rollback/forward-fix evidence before data mutation;
- never use the canonical database for experiments.

### 4.2 Windows process ownership

Source confirms that the runner creates Flutter directly and has no
process-level guard before each process can open the shared production lane.
Isolated probes confirmed blocking risk.

Decision:

- retain the Windows runner and Inno Setup foundation;
- use a pre-Flutter/pre-SQLite named-mutex boundary in a later authorized task;
- coordinate installer/update running-app detection with the same ownership
  boundary;
- preserve canonical database identity, path and content;
- do not treat SQLite busy handling as a substitute for single-instance
  ownership.

This is a bounded integrity correction, not a rewrite.

### 4.3 Startup and shutdown

Source confirms pre-`runApp` Windows/plugin/locale awaits, write-capable
`beforeOpen`, repeated recovery/seeding/backfill work and no explicit
production `AppDatabase.close()` before window destruction.

Decision:

- architecture remains retain/progressive-refactor regardless of exact timing;
- current-HEAD phase measurement is deferred for the architecture choice only;
- no startup, shutdown or `beforeOpen` performance correction may start before
  isolated current-HEAD monotonic phase evidence;
- the failed synthetic harness is not repeated;
- no correction may weaken recovery or force-kill during a database
  transaction.

### 4.4 Android PARTE

Source confirms whole-preview rebuilds during pan/zoom, repeated media reads,
synchronous image effects and broad reloads after editor actions. It does not
prove the measured contribution of each candidate.

Decision:

- retain PARTE domain, persistence contract and accepted PDF/DOCX output;
- retain current block-drag and viewport business behavior;
- defer live profiling for the architecture choice only;
- do not authorize PARTE partial rewrite or performance correction before a
  targeted latest-HEAD Android profiler run;
- profiling may select the smallest presentation/render-state refactor, but it
  cannot reopen the full-codebase decision without materially new evidence.

### 4.5 SCENARIO/IRiU

Source confirms one scenario ID over hard-coded conditions, silent fallback for
unknown IDs, no FIRMA template persistence, no PREDMET-owned definition
snapshot and no reliable IRiU row provenance.

Decision:

- retain PREDMET/IRiU core and existing source behavior until an authorized
  upgrade;
- treat scenario/configuration persistence and evaluation as a bounded
  subsystem refactor/partial-rewrite candidate;
- do not implement isolated row deletion or reorder patches;
- preserve the permanent incident invariant: `SANDUK` and the complete
  applicable basic block precede scenario-dependent rows;
- return lifecycle, reconciliation, user-facing scenario meaning and any new
  PREDMET business field to a post-zero owner business gate;
- never infer legacy row provenance from category text alone.

### 4.6 JSON, backup and restore

The existing transfer core is reusable, while the large UI/file/validation/
restore orchestration shell is highly coupled.

Decision:

- preserve all current single-PREDMET and full-backup formats;
- retain the transfer core;
- progressively separate UI, file I/O, validation, conflict classification,
  transaction and restore orchestration;
- permit bounded subsystem replacement only behind characterized compatibility
  contracts;
- do not introduce sync, Web storage or server-master authority.

## 5. UI/UX and platform parity synthesis

Windows and Android remain equal standalone local applications using shared
business logic. Platform code may differ for files, notifications, windowing,
keyboard/mouse/touch and layout, but the PREDMET, IRiU, JSON, finance and
document result must remain equivalent.

Before any shared UI/business change, use the same representative fixture
across:

1. Android narrow portrait;
2. Android wide/landscape or tablet-class layout;
3. Windows desktop with keyboard and mouse.

The parity matrix must check:

- PREDMET create/save/reopen/lifecycle result;
- IRiU visibility, ordering, values and consequences;
- single-PREDMET JSON round trip;
- full backup/restore where touched;
- PDF/DOCX content and accepted formation;
- error/confirmation meaning;
- no platform-only business capability.

Existing responsive branches are useful implementation seams, but their
different width thresholds are not themselves a product-profile architecture.

## 6. Migration and product-profile synthesis

Current product profile:

- OPC v.1 Serbia only;
- Windows and Android;
- standalone local SQLite/Drift;
- manual JSON/backup transfer;
- no mandatory network;
- no OPC Web implementation;
- no `OPC_v.1_Int` source fork;
- package/licensing compatibility code cannot restrict native functionality.

The source currently has fixed Serbian Latin date/money/text behavior and fixed
RSD output points. It has no localization delegate/profile registry and no
implemented country/currency profile boundary.

Decision:

- finish and stabilize OPC v.1 Serbia before international work;
- keep Serbian Cyrillic as a required future localization capability, not a
  current implementation task;
- prepare future language, script, country policy, documents, KATALOG,
  SCENARIO and currency as separate profiles over a shared PREDMET/data core;
- do not open OPC Web, backend, sync, payment, tax or fiscalization scope.

## 7. Deferred evidence sub-gates

The following evidence is safely deferred without reopening the technical
whole-codebase decision:

| Deferred evidence | Why architecture can close | Mandatory before |
| --- | --- | --- |
| Current-HEAD Windows cold/warm startup and shutdown phase timing | Timing selects the smallest correction and target; source already rules out full rewrite | Any startup/shutdown/`beforeOpen` performance code or acceptance target |
| Latest-HEAD Android PARTE profiling | Profiling selects the smallest presentation/render correction; PARTE domain/output is retained | Any PARTE performance correction or partial-rewrite decision |
| Signing/release custody | Packaging readiness does not alter PREDMET/data architecture | Release/signing task |
| International profile design | Serbia remains the only current product line | Second Product-Line Gate |

Deferral is not evidence of PASS and does not authorize implementation.

## 8. Gate result

Technical Architecture Decision Gate:

`PASS`

Selected strategy:

`RETAIN + PROGRESSIVE REFACTOR + BOUNDED SUBSYSTEM CHANGE ONLY WHERE PROVEN`

Application implementation:

`NOT AUTHORIZED BY THIS DOCUMENT`

Next dependency:

`PREDMET LIFECYCLE / REFERENTIAL INTEGRITY CORRECTION DESIGN AND MIGRATION-PROOF PACKAGE (RI-1 THROUGH RI-5)`

That next task remains audit/design until its exact mutation scope, isolated
fixtures, backup/restore proof, platform parity and rollback gates are complete.
