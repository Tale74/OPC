# OPC task report - post-zero Architecture Decision Gate synthesis

**Status:** `TECHNICAL ARCHITECTURE DECISION PASS - IMPLEMENTATION NOT AUTHORIZED`
**Date:** 2026-07-30

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- audit / design / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no - analyzed and protected

Future OPC Web affected:
- no

Terminology drift risk:
- controlled

Implementation allowed:
- no

Required gate before implementation:
- exact affected-boundary design, data ownership, migration/rollback, platform
  parity and post-zero business gate where applicable

## 1. Git baseline

- Base branch:
  `task/OPC-POST-ZERO-DOCUMENTATION-AUTHORITY-INVENTORY-AND-ALIGNMENT`
- Base SHA: `1c83724977374477e9d8c969e64ee8c1c958e0f6`
- Task branch:
  `task/OPC-POST-ZERO-ARCHITECTURE-DECISION-GATE-SYNTHESIS`
- Final SHA: pushed task-branch tip containing this report; exact SHA is
  recorded in the Git completion handoff.

## 2. Evidence method

The task:

- read the post-zero authority, incident and documentation classification;
- read the prospective plan and latest task report;
- read the Phase 1 architecture, Windows concurrency/startup, Android PARTE,
  SCENARIO/IRiU, module-contract, referential and migration evidence;
- verified directly that application source/tests/platform files remain
  unchanged from
  `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`;
- inspected current source for Windows process startup, pre-`runApp` work,
  database `beforeOpen`, shutdown, PARTE rebuild/media/reload paths,
  SCENARIO identity/fallback, responsive branches, localization/currency and
  platform adapters.

No hypothesis was promoted to confirmed root cause without evidence.

## 3. Architecture decision

Selected:

`RETAIN + PROGRESSIVE REFACTOR + BOUNDED SUBSYSTEM CHANGE ONLY WHERE PROVEN`

Rejected:

`FULL REWRITE`

Primary order:

1. protect PREDMET and canonical-data boundaries;
2. progressive lifecycle/referential refactor;
3. controlled `core_v2` convergence;
4. bounded scenario/configuration or JSON subsystem work only behind
   characterized contracts;
5. PARTE presentation/render performance work only after profiling.

The decision preserves the functional Windows/Android zero baseline.

## 4. Deferred sub-gates

Current-HEAD Windows startup/shutdown phase timing is deferred for the
whole-codebase choice, but remains mandatory before any affected performance
code or target.

Latest-HEAD Android PARTE profiling is deferred for the whole-codebase choice,
but remains mandatory before any PARTE performance correction or partial
rewrite.

Neither deferral is PASS, runtime acceptance or implementation authorization.

## 5. Business-authority separation

The synthesis makes technical architecture decisions only.

It does not approve:

- PREDMET lifecycle/status meaning;
- automatic SCENARIO/IRiU reconciliation policy;
- user-facing SCENARIO meaning;
- a new PREDMET business field;
- currency activation;
- document-content policy;
- OPC Web or `OPC_v.1_Int`.

Those items return to a post-zero owner gate only when their technical evidence
and exact consequence are ready.

The permanent IRiU incident invariant remains protected: `SANDUK` and the
complete applicable basic block precede scenario-dependent rows. A changed
test or technical PASS cannot authorize a different business order.

## 6. Next dependency

The next dependency is:

`PREDMET LIFECYCLE / REFERENTIAL INTEGRITY CORRECTION DESIGN AND MIGRATION-PROOF PACKAGE (RI-1 THROUGH RI-5)`

It begins as audit/design, not implementation. It must define:

- exact dependent-data inventory;
- lifecycle orchestrator boundaries;
- explicit cleanup while foreign keys remain off;
- orphan-recovery migration;
- later enforcement activation;
- full restore/import and Windows/Android parity proof;
- isolated fixtures, readable backup, restore rehearsal and rollback/forward
  fix;
- stop conditions preventing canonical database use.

## 7. Validation

- application/source/test/configuration change: none;
- application tree unchanged from `e9ea4a9...`: PASS;
- `flutter analyze`: not repeated; no application change;
- complete `flutter test`: not repeated; existing conclusive PASS remains
  applicable to the identical tree;
- build: not started;
- manifest gate against exact base SHA: PASS;
- repository diff check: PASS;
- .NET UTF-8/no-BOM validation: PASS for all changed documents;
- technical PASS and owner runtime acceptance: separate.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

OPC Web remains outside current implementation scope:
- yes

Source changes within scope:
- yes - documentation only

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS subject to repository checks, commit, push, origin equality and clean
  worktree completion
