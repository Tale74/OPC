# OPC Full Post-Scenario Continuity Intake

**Document classification:** `HISTORICAL / PRE-RR012 INTAKE SNAPSHOT — NOT CURRENT RR-012 AUTHORITY`
Current RR-012 authority is `CLOSED — INSTALLER/UPDATE RUNNING-APP PROTECTION FULL ACCEPTANCE PASS` with successor `NONE`; later closure evidence supersedes the intake-era release-risk recommendations below.

**Status:** `FULL POST-SCENARIO CONTINUITY INTAKE — ANALYSIS / READINESS ONLY`  
**Baseline HEAD:** `0aada93c8090e6dd075a656b7ea60cad7376e986`  
**Parent:** `336552ff40eaa72321670cb554ebd1d6d784d30c`  
**Branch:** `task/OPC-SCENARIO-MODULE-LOCK`  
**Remote parity:** confirmed  
**SCENARIO protected production SHA:** `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`  
**Scope:** cross-phase continuity, dependency/readiness and next-action selection; no implementation authorization.

## 1. Intake decision

The complete published state does not justify beginning physical architecture migration, broad refactoring, or a product implementation wave. The earliest unresolved dependency is a **release-risk integrity characterization and acceptance wave**. It must establish the current-tip Windows single-instance/canonical-database contract and the remaining PREDMET/referential/lifecycle acceptance evidence before any correction or migration is selected.

This is one **CHARACTERIZATION WAVE**, not Phase 5 and not an implementation task. It may collect source, fixture, test and runtime evidence without changing production code, tests, schema, dependencies, platform behavior or SCENARIO.

The wave is the first dependency in the current authoritative plan. It protects the later interoperability/database characterization required by the Phase 4 migration sequence and avoids choosing a refactor from an unmeasured release-risk premise.

## 2. Complete active-state reconstruction

The ledger contains 37 controls: 17 `CLOSED — EVIDENCE VERIFIED`, 1 `CLOSED — CONTROL PRESERVED`, 19 `OPEN — FORWARD ACTION`, and 1 active installed governance control. The Phase 4 publication/closure gate (PSC-036) was factually closed by the accepted Logos package and publication commit; its ledger row now records that transition. No concern was dropped.

The relevant active or protected set is 21 rows: 19 open forward-action rows, the protected SCENARIO contract (PSC-009), and the proven-dead-but-not-removed candidate (PSC-025). Three rows are classified `OWNER GATE` (PSC-012, PSC-015 and PSC-028), covering two semantic decision clusters: package/entitlement meaning and PODSETNIK signal meaning.

| Control(s) | Current concern | Evidence / authority | Dependency role | Immediate treatment | Successor / unlock |
|---|---|---|---|---|---|
| PSC-006 | Transfer, full-backup and restore coordination | Compatibility register; JSON/restore source and tests | FOUNDATIONAL BLOCKER | Characterize round-trip, rollback and release-artifact boundaries | Interoperability and restore contract evidence |
| PSC-008 | PREDMET lifecycle and business-source facts | PREDMET rows, contracts, DB tables and tests | PREREQUISITE | Characterize transactions, ordering and runtime lifecycle | Safe orchestration and referential acceptance |
| PSC-009 | SCENARIO lock and contracts | Lock SHA and regression evidence | DEFERRED BY SCENARIO LOCK | Preserve lock; diff-exclude at every task boundary | Separate explicit SCENARIO unlock task only if required |
| PSC-010 | IRiU truth, ordering and lifecycle | Ordering/manual-row/scenario tests | PREREQUISITE | Complete ownership and mixed-path characterization | IRiU/KATALOG boundary migration |
| PSC-011 | KATALOG ownership and pipeline | Depth check, seed/picker/source rows | PREREQUISITE | Characterize provenance, mutation and price edge cases | KATALOG acceptance matrix |
| PSC-012 | OSNOVNI PAKET and entitlement policy | Ownership matrix and entitlement rows | DEFERRED BY OWNER GATE | Preserve current technical behavior; do not invent policy | Owner package/entitlement decision |
| PSC-013 | PARTE state, media, PDF/DOCX, print, JSON, DB and platform | PARTE depth evidence and source/test inventory | PREREQUISITE | Build artifact and renderer acceptance characterization | Documents/PARTE migration seam |
| PSC-014 | STANJE ROBE derived state and effects | Depth check, operational toggle, delete/restore and JSON tests | PREREQUISITE | Characterize effect/rebuild/recovery boundaries | Stock projection/effect contract |
| PSC-015, PSC-028 | Reminder scheduling and PODSETNIK signal taxonomy | Phase 3 boundary, current reminder evidence | DEFERRED BY OWNER GATE | Characterize technical derived state only; await signal meaning | Owner decision, then one lifecycle-aware reminder program |
| PSC-016 | Authentication, users and recovery | Auth/recovery source and tests | RELEASE-GATE | Run recovery/security acceptance characterization | Identity/recovery release evidence |
| PSC-018 | DB schema, migrations, seed, repair and recovery | DB forensic report; v1–27 evidence | FOUNDATIONAL BLOCKER | Inventory transitions, malformed cases, idempotency and restore interruption | Persistence migration/recovery wave |
| PSC-019 | JSON export/import and interoperability | JSON forensic report, contract matrix and tests | FOUNDATIONAL BLOCKER | Build versioned fixtures and round-trip parity evidence | Interoperability split/migration |
| PSC-020 | Test characterization and acceptance obligations | 70-row test inventory and gap register | PREREQUISITE | Map each intervention to executable evidence | Characterization suites and closure proof |
| PSC-025 | `export_utils_replacement.dart` | Global no-reference search and dead-code register | LATE CLEANUP | Retain; no deletion in this intake | Separate authorized removal task |
| PSC-031 | Controlled coverage gaps | Inventory, functional matrix and ledger | PREREQUISITE | Close only with sub-responsibility evidence | Phase-boundary coverage recheck |
| PSC-032 | Runtime dependency-edge gaps | Dependency and contract matrices | PREREQUISITE | Validate edges during rehearsal | Migration prerequisite evidence |
| PSC-033 | Closure-proof gaps | Ledger proof column and Phase 4 registers | PREREQUISITE | Attach executable/runtime proof before closure | Evidence-backed closure transition |
| PSC-034 | Migration prerequisite gaps | Phase 4 sequence and restore/release gates | PREREQUISITE | Run rehearsal prerequisites after characterization | Migration Wave 0 evidence |
| PSC-035 | Test gaps | Characterization register and test inventory | PREREQUISITE | Add seam-specific fixtures/suites in a later authorized task | Executable regression evidence |
| PSC-037 | Runtime/release acceptance | Platform inventory and acceptance reports | RELEASE-GATE | Keep technical, build, platform and data evidence distinct | Release-candidate acceptance matrix |

The active installed completeness control (PSC-001) is **PARALLEL-SAFE** governance: it continues to run at every boundary and does not block evidence collection.

## 3. Current authority and roadmap reconciliation

The first bullet below preserves historical intake state; it is not a current RR-012 status claim. Current RR-012 authority is CLOSED with no successor.

RR-012 current-state reconciliation: the intake-era installer acceptance blocker was closed by the later Inno Setup compile and I1/I2/I3 evidence. The current RR-012 fact is `CLOSED — INSTALLER/UPDATE RUNNING-APP PROTECTION FULL ACCEPTANCE PASS`; successor `NONE`.

The current development state and authoritative dependency plan remain the operative sequencing authority. They preserve the following product-roadmap work even though it is not the immediate characterization wave:

- At intake, Windows single-instance ownership and installer coordination were recorded as open and blocking. The native singleton is now closed by the published W1-W6 evidence; installer running-app protection was subsequently closed by the bounded RR-012 I1/I2/I3 acceptance. Canonical-database safety remains protected.
- Current-tip Windows startup/exit and Android PARTE/IRiU performance require measurement before correction; no presumed refactor is justified.
- SCENARIO carrier parity, KATALOG/IRiU rendered/runtime proof, final JSON/backup/restore rehearsal and document fidelity remain release or migration obligations.
- Complete signal semantics and the full PODSETNIK program remain owner-gated; the existing Android notification is evidence for that program, not an isolated patch target.
- NALOG CVEĆARI scope, RAČUN FIRMA availability/default, EUR activation, app identity/version/update channel, signing custody, IP/repository-use/distribution status, dependency/license inventory, SBOM and vulnerability process remain explicit owner or release decisions.
- MODUL DVE VALUTE remains product-roadmap work before the stable OPC v.1 gate; `OPC_v.1_Int` remains deferred.
- Windows light/dark is closed and is not reopened as an active item.

These concerns map to the ledger successors above; none is converted into an unowned `later` or generic future item.

The current roadmap also contains active concerns that are not separate ledger controls. They remain visible here with an explicit class and successor:

| Authority-reported concern | Class | Successor |
|---|---|---|
| Windows single-instance and installer/canonical-DB contract | CLOSED — EVIDENCE VERIFIED | Native singleton W1–W6 and RR-012 installer I1/I2/I3 evidence are accepted; no successor |
| Windows startup/exit, Android PARTE and IRiU/KATALOG performance | PREREQUISITE | Evidence-first measurement, owner target where required, then correction only if measured gate fails |
| Broader Windows/Android UI/UX and document typography | PRODUCT-ROADMAP WORK | Full cross-platform UX audit and document artifact/print acceptance |
| NALOG CVEĆARI scope and RAČUN FIRMA availability/default | DEFERRED BY OWNER GATE | Owner scope/availability decision, then bounded document implementation/acceptance if required |
| MODUL DVE VALUTE | PRODUCT-ROADMAP WORK | Product-line implementation and parity proof before the First Product-Line Gate |
| App identity, version, update channel and signing custody | RELEASE-GATE | Owner release decision followed by provenance/signing/release acceptance |
| IP/repository-use/distribution status, dependency/license inventory, SBOM and vulnerability process | RELEASE-GATE | Release-governance evidence before commercial distribution or external handover |

## 4. Characterization readiness

The Phase 4 conclusion remains **READY WITH PRE-IMPLEMENTATION CHARACTERIZATION**. The published source inventory proves 152 handwritten production Dart files were directly analyzed, one generated source row, 70 test rows and 113 platform/build/script/tool rows. That proves coverage, not closure of the following partial contracts.

| Area | Existing evidence | Exact missing evidence | Evidence type | Production change required for characterization? | Later unlock |
|---|---|---|---|---|---|
| JSON / interoperability | Typed carriers, legacy readers, JSON/backup tests | Format/version inventory; section golden set; failure/rollback matrix; caller migration proof; platform file/share behavior | Source contract + migration fixtures + Windows/Android round-trip | No | Interoperability ports and split |
| Database / recovery | v19–v26 recovery states, seed/repair and restore tests | Full v1–v27 transition table; malformed-schema cases; idempotent repair/backfill; interrupted restore/reopen; generated-schema parity | Source characterization + migration fixtures + restore rehearsal | No | Persistence decomposition |
| PREDMET orchestration | Lifecycle, referential, completion, save/close and scenario tests | Cross-feature transaction inventory; event/order traces; UI-to-workflow contract; rollback boundaries | Source contract + runtime lifecycle acceptance | No | Aggregate ports and orchestration cleanup |
| IRiU / KATALOG | Ordering, manual-row, picker, fixed-price and scenario tests | Snapshot provenance/mutation matrix; UI selection contract; measured repository/first-frame/photo timing | Source contract + runtime/performance acceptance | No | Boundary extraction |
| Policy / finance | Policy tests and statistics service | Golden input/output matrix; owner-approved finance semantics; presentation-calculation inventory | Source characterization + owner semantic decision | No | Bounded policy/finance recode candidate |
| PODSETNIK | Reminder runtime/UI and restore evidence | Owner signal taxonomy; clock/time-zone/cancel/restore/reboot/platform cases | Owner semantics + runtime acceptance | No | One lifecycle-aware reminder program |
| Documents / PARTE | PDF identity/fidelity, print and storage tests | Per-document golden artifacts; renderer/platform matrix; external DOCX editing and physical print proof | Artifact/physical acceptance | No | Documents/PARTE seam |
| STANJE ROBE | Toggle, delete/restore and JSON boundary tests | Full effect lifecycle across IRiU/KATALOG/PREDMET and restore conflicts | Source contract + recovery characterization | No | Derived-state boundary |
| Auth / recovery / entitlements | Auth, recovery and parser tests | Recovery acceptance matrix and owner distribution/retention policy | Security/runtime acceptance + owner decision | No | Identity/release work |

Source characterization, migration fixtures, runtime acceptance, physical print/DOCX acceptance and backup/restore rehearsal are separate evidence classes. A source PASS does not replace a platform or physical acceptance; a runtime PASS does not prove an internal root cause.

## 5. Owner gates

The three semantic owner-gate rows remain visible and are not technical blockers for evidence collection when existing meaning is preserved:

1. PSC-012: package/entitlement policy meaning.
2. PSC-015 and PSC-028: PODSETNIK signal taxonomy and business meaning.

Owner input becomes unavoidable when a task changes package meaning, introduces new signal semantics, selects distribution/retention policy, accepts external interchange semantics, or grants release/signing authority. Codex/Logos may choose architecture, characterization scope, dependency order, test structure and migration strategy without asking the owner to make those technical decisions.

## 6. SCENARIO and proven-dead boundaries

The recommended characterization wave does not require SCENARIO source changes or physical movement. The lock remains `DEFERRED BY SCENARIO LOCK`; any later physical migration would require a separate explicit unlock task. The proven-dead `export_utils_replacement.dart` candidate is **LATE CLEANUP**, not a prerequisite, and remains untouched.

## 7. Recommended next-action acceptance contract

**Recommended action:** one release-risk integrity characterization and acceptance wave.

**Objective:** establish current-tip evidence for Windows single-instance/canonical-database safety and the remaining PREDMET/referential/explicit-lifecycle release obligations.

**Scope:** process/installer second-launch behavior; canonical DB identity/content protection; cold/warm start and exit measurements needed to separate release-risk from performance; PREDMET lifecycle (`OTVOREN → ZATVOREN → ZAVRŠEN`) on Windows and Android; referential/restore boundaries already identified as release-required; owner-gate dependencies recorded without inventing semantics.

**Protected surfaces:** production Dart, tests, schema/migrations, dependencies, platform behavior, CI, runtime/private data, SCENARIO and internal pseudocode bodies remain unchanged during this intake and its characterization-only execution unless separately authorized.

**Required evidence:** current-tip source/contract inventory; disposable test/fixture evidence; named Windows and Android artifacts; second-launch/installer observation; canonical DB non-replacement proof; lifecycle and referential acceptance matrix; analyzer/test/build/runtime results where a later authorized task changes a protected surface.

**Expected artifacts:** characterization matrix, runtime acceptance record, measured baseline, explicit unresolved owner/release gates, and a successor map. No production implementation is part of this intake.

**Stop conditions:** unreconstructable compatibility evidence; a protected-contract conflict; a required SCENARIO unlock; an unresolved business semantic needed to define the test oracle; or a runtime/data result that contradicts the published authority.

**Downstream unlocks:** safe bounded single-instance/installer implementation if the measured contract requires it; final PREDMET/referential release acceptance; evidence-first performance work; then JSON/backup/restore and database characterization required for architecture migration. It does not itself authorize migration or Phase 5.

## 8. Why alternatives are not first

- **Architecture migration first:** critical JSON, restore and database contracts remain partial; moving blocks before those fixtures exist risks creating a second authority or breaking compatibility.
- **Broad rewrite/refactor:** the Phase 3/4 evidence supports only bounded, evidence-gated intervention; no broad rewrite is justified.
- **Owner decision first:** current technical characterization can preserve existing meaning. Owner gates become blocking only when semantics, distribution policy or release authority would change.
- **Performance-only work:** measurement is required, but release-risk integrity and canonical DB safety precede performance correction in the operative plan.
- **PODSETNIK patch:** the signal model is unresolved; an isolated status notification would bypass the owner-gated semantic program.
- **Dead-code removal:** the candidate is not a prerequisite and remains reserved for a separately authorized cleanup task.
- **Signing/release handover:** release evidence is required, but it depends on product/runtime/compatibility acceptance first.

## 9. Mandatory completeness checks

### CROSS-PHASE CONTINUITY CHECK

Phase 1 authority homes, Phase 2 current-reality synchronization, Phase 3 target architecture, Phase 4 forensic classifications, and the published completeness control reconcile to HEAD `0aada93c8090e6dd075a656b7ea60cad7376e986`. PSC-036 publication closure is recorded as a factual transition. No Phase 4 technical conclusion changed.

### SOURCE COVERAGE CHECK

The inventory remains 336 rows / 38 columns: 152 directly analyzed handwritten production files, 1 generated source row, 70 individually traced tests and 113 platform/build/script/tool rows. No handwritten file is generic scan-only or invariant-only; all required responsibility, target, disposition, compatibility, characterization, action and successor fields are populated.

### ORPHAN/GAP SCAN

ORPHAN: 0; SUPERSESSION GAP: 0; AUTHORITY conflicts: 0; OWNER-GATE LEAK: 0; OWNER-GATE LOSS: 0. Controlled gaps remain explicit: coverage 5, dependency 1, closure 4, migration 1 and test 1. These are not orphans and each retains a named successor.

### FORWARD-ACTION OWNERSHIP CHECK

All 19 open ledger rows have non-empty next action, future task and closure proof fields. The three semantic owner gates remain named. No open item disappears from the forward program, and the forward-action map contains no generic `later`, `future work`, blank or unowned TODO successor.

## 10. Intake result

The repository is ready for a bounded **release-risk integrity characterization and acceptance wave**, with interoperability/database characterization next in dependency order. The result is analysis/readiness only. No production code, tests, schema, dependencies, configuration, platform behavior, runtime/private data, SCENARIO implementation or internal pseudocode was changed by this intake. No Phase 5 work began.

**FULL POST-SCENARIO CONTINUITY INTAKE PASS — NEXT PROGRAM ACTION DERIVED FROM COMPLETE AUTHORITY AND DEPENDENCY STATE — READY FOR LOGOS REVIEW**
