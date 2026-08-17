# OPC Phase 4 Migration Prerequisite / Sequencing Map

This is a dependency-ordered analysis program, not an implementation authorization. Waves may overlap only where their protected contracts are independently characterized.

## Dependency graph

```text
inventory callers and compatibility formats
    ↓
characterize contract boundaries and golden fixtures
    ↓
publish ports/adapters and transaction/error contracts
    ↓
extract application orchestration behind ports
    ↓
introduce infrastructure codecs/repositories/platform adapters
    ↓
run parity, migration, restore and platform evidence
    ↓
switch callers in bounded waves
    ↓
forensic re-audit old paths
    ↓
remove only PROVEN DEAD residue
```

## Ordered waves

| Wave | Scope | Prerequisites | Exit evidence | Risk |
|---|---|---|---|---|
| 0 | Freeze authority and capture baseline | Phase 3 target, SCENARIO lock, clean branch | Baseline SHA, contract inventory, no protected-surface drift | LOW |
| 1 | Low-risk composition and test taxonomy seams | Startup/UI characterization; no behavior change | App composition contract and test ownership map | MEDIUM |
| 2 | Interoperability contract inventory | JSON format/version list, backup section inventory, restore/rollback matrix | Golden transfer/backup fixtures and validation result model | CRITICAL |
| 3 | Interoperability application extraction | Ports for filesystem, codecs, repository transaction, media and notifications | Workflow parity on single-PREDMET and full backup/restore | CRITICAL |
| 4 | Infrastructure codecs/adapters | Wave 3 ports; legacy format readers and storage/platform tests | Adapter contract tests and no direct workflow Drift/OS dependencies | HIGH |
| 5 | Database decomposition | Full v1–27 matrix; recovery/repair idempotency; copy/restore rehearsal | Migration/recovery parity and generated schema validation | CRITICAL |
| 6 | KATALOG/IRiU boundary extraction | Snapshot/provenance and ordering characterization | `OSNOVNI → applied SCENARIO → manual/unpredicted` parity | HIGH |
| 7 | PREDMET orchestration cleanup | Lifecycle/transaction/cross-feature call inventory | Aggregate contract, UI workflow and rollback parity | CRITICAL |
| 8 | Policy/finance and documents | Owner finance semantics; document golden artifacts | Policy outputs and document artifacts unchanged | MEDIUM/HIGH |
| 9 | PODSETNIK and stock boundaries | Owner signal taxonomy; effect lifecycle matrix; platform clock tests | Derived state and operational effects parity | HIGH |
| 10 | Auth/settings/platform normalization | Identity/recovery/distribution decisions; Windows/Android matrix | Recovery, entitlement and platform parity | HIGH |
| 11 | Re-audit and conditional removal | All prior parity evidence and history/packaging scan | Only explicitly proven-dead residue eligible for later deletion | CRITICAL |

## Critical sequencing constraints

- SCENARIO physical restructuring is never implied by a wave; it remains `REQUIRES EXPLICIT SCENARIO UNLOCK TASK`.
- Database decomposition must not precede interoperability restore/rollback characterization because backup paths depend on schema and repair behavior.
- PREDMET orchestration cleanup must follow IRiU/KATALOG and interoperability ports so PREDMET does not temporarily acquire a new parallel authority.
- Dead-code removal is the final wave and is conditional per candidate, not a global cleanup step.

