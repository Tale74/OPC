# OPC Phase 3 Target SOURCE Architecture Report

**Status:** TARGET DESIGN ONLY — NOT IMPLEMENTATION AUTHORITY
**Baseline:** `e57ac1531a1cc3c38993aecc978e9e2a81bd3a24` (Phase 2 published HEAD)
**SCENARIO lock:** `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`
**Phase 3 final status:** `PHASE 3 PASS — TARGET OPC SOURCE ARCHITECTURE AND BUILDING-BLOCK MODEL DEFINED — READY FOR LOGOS REVIEW`

## 1. Decision in one page

OPC should move toward a **hybrid feature-first architecture with explicit internal layers**. Product capabilities remain discoverable under `features/`, while cross-cutting infrastructure (database, interoperability adapters, platform, and composition) has dedicated homes. Transfer, full-backup and restore coordination are feature application workflows; serializers, filesystem bridges and persistence adapters are infrastructure implementations behind their ports. Each feature owns its domain contracts and presentation, and introduces an application/workflow layer only where orchestration is material. The application composition boundary is singular and explicit.

The target is not a clean-room rewrite and is not a preservation of historical folders. It is a responsibility model. Existing code can be retained when it already expresses a stable contract; it can be moved, split, recoded, partially rewritten, fully reconstructed, or removed only when evidence and characterization justify that intervention.

The protected boundary is business truth and compatibility, not file age: PREDMET remains the sole master business truth; applied SCENARIO state remains a PREDMET-owned, non-retroactive snapshot; IRiU ordering remains `OSNOVNI → applied SCENARIO → manual/unpredicted`; persistence, migrations, recovery, JSON contracts, Windows/Android parity, historical data, and the locked SCENARIO regression contract remain mandatory.

## 2. Current responsibility reconstruction

The current repository already contains useful feature seams, but responsibility is unevenly distributed. `lib/main.dart` and `lib/app.dart` compose runtime state and platform concerns; PREDMET lifecycle and repositories are split between `features/predmeti/data`, `domain`, `application`, and `core_v2`; SCENARIO contracts and implementation are colocated under `core_v2`; IRiU ordering/truth services and repositories are PREDMET-owned; KATALOG tables/configuration are in `core`; PARTE is comparatively coherent; PDF/DOCX exporters are PREDMET derivatives; reminders are split between `podsetnik` presentation and PREDMET reminder services; stock has an application/data/presentation slice; authentication and settings are feature slices; persistence and JSON remain concentrated hotspots.

The two most material concentration risks are the 86 KB `lib/core/database/database.dart` (schema, migration, seed, repair, and recovery responsibilities) and the 90 KB `lib/core/utils/json_export_import.dart` (transfer, backup, filesystem, validation, persistence mutation, and reporting responsibilities). Their size is evidence for decomposition, not an automatic rewrite authorization. Generated `database.g.dart` is a generated artifact and is not ordinary maintainability debt.

Current tests provide strong characterization around PREDMET lifecycle, SCENARIO contracts/runtime, IRiU ordering, migrations/recovery, JSON transfer, PARTE, PDF, reminders, and stock. The flat test root makes those contracts harder to discover than the implementation already does.

## 3. Target principles and dependency direction

```text
presentation
    ↓
feature application/workflows
    ↓
feature domain contracts and policies
    ↓
ports (repositories, clocks, filesystem, notifications, database lanes)
    ↓
data / persistence / platform implementations
```

The arrows are dependency arrows. Domain code does not import Flutter, Drift, filesystem packages, notification APIs, or another feature's data tables. A feature may depend on another feature's published contract, never on its private repository or tables. Cross-feature workflows are composed in an application coordinator or the app composition root. Persistence implements ports and never becomes a second business authority.

The rule is intentionally pragmatic: a layer exists only where it protects a real contract or removes material coupling. Small, pure transformations may remain beside the owning domain rather than being forced through empty use-case classes.

## 4. Target logical architecture

The authoritative block-by-block contract is in `OPC_PHASE3_TARGET_BUILDING_BLOCK_MATRIX.md`. In summary:

1. **App composition and runtime context** owns startup, dependency wiring, lifecycle, theme, and platform capability registration. It does not own business rules.
2. **PREDMET core** owns aggregate identity, lifecycle, state transitions, version/identity semantics, and the authoritative write boundary for PREDMET-owned data.
3. **SCENARIO module** owns definitions, rules, package editing, reconciliation and transfer contracts inside its locked boundary. It consumes catalog/policy inputs and emits candidate definitions/results; PREDMET alone applies and persists a snapshot. Any physical implementation change is `REQUIRES EXPLICIT SCENARIO UNLOCK TASK`.
4. **IRiU selection and ordering** owns selected-row composition, provenance, display/order projections, quantities/prices and manual-row semantics. It reads KATALOG and SCENARIO snapshots but does not become PREDMET authority.
5. **KATALOG** owns article identity, category, labels, configurable catalog values, current catalog price and lookup/selection. It supplies values for snapshots; it cannot retroactively rewrite applied PREDMET rows.
6. **Policy/finance feature** (`features/policy_finance`) owns deterministic policy evaluation, financial projections and statistics inputs. It is one explicit feature home with separate policy and finance sub-blocks; it consumes PREDMET/IRiU snapshots and emits derivatives.
7. **Operational effects / STANJE ROBE** owns stock availability, applied effects and consequences as operational projections. It never writes PREDMET truth directly.
8. **Derivative workflows** contain PARTE preparation, PDF/DOCX rendering and other PREDMET-derived exports. They accept immutable snapshots and return artifacts/status.
9. **Reminder scheduling / PODSETNIK** owns only derived scheduling, delivery and confirmation state around PREDMET-sourced facts. PREDMET remains the authority for lifecycle/business facts; signal taxonomy and business meaning remain provisional pending owner decision.
10. **Interoperability workflows and technical adapters** separate application-owned serialization/transfer/full-backup/restore coordination from infrastructure-owned format codecs, filesystem transport and persistence adapters. Workflow orchestration never depends directly on Drift or OS APIs.
11. **Persistence and recovery** owns tables, migrations, seed, repair, recovery lanes and generated Drift access. It implements ports and preserves compatibility/rollback obligations.
12. **Identity, users, FIRMA and settings** owns session/identity context, firm configuration and user preferences. It provides context to workflows and cannot redefine PREDMET, KATALOG or SCENARIO meaning.
13. **Platform adapters** isolate Windows/Android filesystem, lifecycle, notification, window, permission and release integration behind ports.
14. **Presentation** is feature-local UI and state binding. It calls application contracts and does not directly mutate tables or coordinate unrelated features.
15. **Test architecture** mirrors contracts and risk classes; locked SCENARIO tests remain a protected suite, not a generic feature test.

## 5. Preservation and open gates

The target explicitly preserves PREDMET authority, SCENARIO non-retroactivity and lock, IRiU order, catalog snapshot semantics, migrations/recovery/old JSON compatibility, full-backup rollback, document/stock/reminder derivative boundaries, Windows/Android parity, and existing regression guarantees. Reminder source facts remain PREDMET-owned while derived scheduling/delivery/confirmation state may be PODSETNIK-owned.

PODSETNIK is a provisional boundary: source lifecycle/business facts are read from PREDMET and derived scheduling/delivery/confirmation state can be isolated now, but signal taxonomy, escalation and business meaning require an owner decision. NALOG/RAČUN semantics, dual currency, app identity/distribution, Windows single-instance, performance, UI/UX and final backup/JSON release gates remain roadmap evidence, not architecture decisions. No open item requires Phase 3 to stop.

## 6. Quality attributes and trade-offs

| Attribute | Target response | Trade-off |
|---|---|---|
| Maintainability | Feature ownership, narrow ports, decomposition of integration/persistence hotspots, discoverable tests | More explicit interfaces and migration seams |
| Reliability | Preserve characterization and recovery contracts; isolate side effects and transactions | Temporary adapter duplication during migration |
| Functional suitability | PREDMET authority and explicit workflows prevent hidden cross-feature mutations | Some current shortcuts must be recoded |
| Security | Identity/session and filesystem permissions behind platform ports; transfer validation before mutation | More validation and audit data in transfer flows |
| Compatibility | Versioned transfer/backup contracts, migration lanes and old-format readers remain first-class | Compatibility code remains intentionally retained |
| Performance efficiency | Measure before extraction; keep bulk database operations and snapshots bounded | Extra mapping can cost allocations if unprofiled |
| Platform parity | Shared domain/application behavior with explicit Windows/Android adapters | Platform-specific acceptance remains necessary |
| Usability | Presentation receives stable workflow states and actionable errors | Requires consistent result models across exporters/backup |

## 7. Intervention policy

Retain or refactor when responsibility is already coherent and contracts are well characterized. Move or rename when only discoverability is wrong. Split when one unit owns unrelated protocols or side effects. Recode/partial rewrite when a stable contract can be implemented behind a new port while preserving compatibility. Full reconstruction is justified for inseparably mixed, high-risk concentration points only after characterization and migration rehearsal. Removal is permitted only after a forensic dead-code audit proves no migration, recovery, compatibility, platform, or historical-data path depends on the code.

The likely high-value candidates are decomposition or bounded reconstruction of the database and JSON integration hotspots, extraction of a single composition boundary, separation of interoperability workflow orchestration from technical adapters, and separation of reminder source facts from derived delivery state. PARTE is a retain-and-reuse pattern for explicit domain/application/data boundaries, not a template to copy blindly.

## 8. Implementation boundary

This report, its matrices and the review package define a target design only. No Dart file, import, database, test, dependency, CI, platform configuration, SCENARIO implementation, pseudocode body, or current-state authority home was changed. A later implementation phase must sequence characterization, contract adapters, migration/recovery rehearsal, and explicit SCENARIO unlock governance before physical movement.
