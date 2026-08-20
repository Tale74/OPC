# OPC Current Architecture

**Status:** `CURRENT AUTHORITATIVE ARCHITECTURE INFORMATION HOME`
**Architecture baseline:** `4e74772f72da921a2c94207a48c5530bfcc59e61`
**Description type:** current-state architecture description, not a target SOURCE tree and not authorization for restructuring.

This is a compressed/tailored arc42-style description using C4 Context, Container and a small Deployment view. It records what exists now, including poor or provisional boundaries. It does not claim formal ISO/IEC/IEEE 42010 conformance.

## 1. Goals and constraints

The architecture must support a local-first funeral-ceremony workflow product on Windows and Android; preserve PREDMET as master business truth; protect user data and migrations; allow controlled JSON transfer/backup; preserve SCENARIO's locked contract; and remain understandable to a future development team.

Principal constraints:

- One Flutter/Dart product with shared business behavior and native platform runners.
- Local Drift/SQLite persistence; runtime databases and case data are not repository artifacts.
- User-controlled JSON transfer and full backup have different compatibility contracts.
- Windows and Android are equal product platforms, but filesystem, notifications, installation, lifecycle and window behavior differ.
- PREDMET is the sole business truth; all modules/derivatives consume it through explicit or currently imperfect seams.
- SCENARIO production source and its regression contract are formally locked.
- Existing migrations and backward compatibility are protected assets.

## 2. C4 System Context

```text
OPC user / administrator / adviser
        │
        ▼
OPC local-first application (Windows or Android)
        │
        ├── local Drift/SQLite database
        ├── user-selected JSON single-PREDMET transfer or full backup files
        ├── generated PDF/DOCX and print/export outputs
        ├── platform notifications, filesystem and installation services
        └── optional owner/runtime evidence and external operational acceptance
```

There is no current server-master PREDMET system. Future Web/sync/API concepts remain outside current implementation scope and must not be inferred from the local application.

## 3. C4 Container view

OPC is one in-process Flutter application. “Containers” here are logical runtime responsibilities, not separately deployed services.

| Logical container | Current source areas | Responsibility | Main dependencies |
|---|---|---|---|
| Application shell/composition | `lib/main.dart`, `lib/app.dart`, `features/setup` | Startup, database construction, repository/service wiring and routing | All top-level application services |
| PREDMET business core | `features/predmeti/domain`, `application`, repository and lifecycle UI | Master case truth, lifecycle, version, logs and dependent-data orchestration | Persistence, users/session, policy inputs |
| SCENARIO module | `features/predmeti/core_v2/scenario`, scenario tables and presentation | Definitions, package evaluation, applied snapshots/provenance, reconciliation and locked UI contract | PREDMET, IRiU/KATALOG, persistence |
| IRiU/KATALOG operational block | IRiU repository/segments, `core/catalog`, settings/catalog tables | Catalogue identity/configuration, selected rows, ordering, price snapshots and operational effects | PREDMET, SCENARIO, persistence, stock |
| Business policy/derived projections | `core_v2/business_policy`, rules/services, finance/statistics areas | Derived policy/evaluator outputs, finance/statistics projections | PREDMET, IRiU and owner rules |
| PARTE derivative | `features/predmeti/parte/**` | Technical preparation, templates, rendering and export | PREDMET, media, PDF/DOCX libraries, persistence |
| Document generation | `features/predmeti/pdf/**`, document builders | PREDMET/IRiU/Firma/user-derived PDF and document outputs | Domain snapshots, printing/PDF/DOCX libraries |
| Reminders/PODSETNIK | `features/podsetnik/presentation`, `features/predmeti/reminders` | Reminder UI, scheduling and notification integration | PREDMET lifecycle, settings, platform notifications |
| Stock/effects | `features/stanje_robe/**`, stock tables | Inventory and consequence/effect lifecycle | PREDMET/IRiU, KATALOG identity, settings/entitlements |
| Identity/settings/access | `features/auth/**`, `features/podesavanja/**`, `core/entitlements/**` | Session, users, firm/settings and technical access context | Persistence, crypto, platform/runtime context |
| Persistence/data platform | `core/database/**`, Drift generated code | Schema, migrations, repair, recovery, database identity and tables; fresh databases contain no user/business KATALOG content | Drift/SQLite, filesystem/test selectors |
| Interoperability/backup | `core/json_transfer/**`, `core/utils/json_export_import.dart`, format utilities | Single-PREDMET transfer, full backup, validation, serialization and mutation coordination | Nearly every feature and persistence |
| Platform/deployment adapters | `android/**`, `windows/**`, Flutter plugins | Native runner, permissions, notifications, filesystem, packaging and installation | Flutter SDK, OS APIs, installer/build tools |

## 4. Current building-block quality

The logical blocks above are real but not equally visible in the tree:

- PREDMET authority and SCENARIO responsibility are conceptually explicit and protected.
- PARTE is comparatively well-factored into application/data/domain/docx/pdf/presentation areas.
- Auth is comparatively layered.
- `core/database/database.dart` combines schema, migration, seed, repair and recovery concerns and is oversized.
- `core/utils/json_export_import.dart` is a 2,792-line integration/application monolith under a generic utility path. It depends back into auth, PREDMET, SCENARIO, PARTE/reminder, stock and persistence.
- IRiU/KATALOG responsibility is split among database seed/configuration, core catalogue identity, settings and feature consumers.
- PODSETNIK presentation and reminder implementation are separated while signal semantics remain unresolved.
- Many presentation screens are composition-heavy and import multiple feature areas. The audit identified large screens/repositories as maintainability hotspots, not as permission for an automatic rewrite.

These are current architecture facts and risks. The later Target SOURCE Architecture phase must decide whether each block is retained, renamed, moved, split, merged, refactored, partially rewritten, reconstructed or removed as proven dead.

## 5. Dependency directions and current violations

Desired logical direction:

```text
presentation → application/domain → data/persistence/platform adapters
                                  ↘ integration/export services
shared technical kernel → stable primitives only
```

Current evidence shows:

- composition screens often coordinate several feature repositories directly;
- `core/utils/json_export_import.dart` imports feature-specific classes, so its physical location misrepresents its application/integration responsibility;
- PREDMET, settings, reminders, stock and IRiU are coupled through screens/repositories;
- repository classes sometimes combine persistence, lifecycle, policy, snapshot and orchestration responsibilities.

No complete file-level circular import claim is made here. The relevant finding is bidirectional package coupling and hidden orchestration that increases onboarding and change risk.

## 6. Persistence and data architecture

`AppDatabase` is created at startup. Drift tables cover PREDMET, users/firma/settings, IRiU/KATALOG/provenance, SCENARIO definitions/modules/snapshots, PARTE, stock/effects/consequences, logs, contacts and document-related state. Schema migrations are versioned through the current schema version 27 with recovery/repair/identity protections documented in source and tests. A fresh database creates structural singleton/auth state only: user/business KATALOG rows are not automatically created. Existing KATALOG rows remain authoritative across reopen and migration; repair and legacy normalization remain explicit integrity operations.

The generated `database.g.dart` is generated output and is not hand-written architecture debt. Database schema/migration history, user data compatibility and recovery behavior must remain protected during any later restructuring.

## 7. Deployment view

| Deployment element | Windows | Android |
|---|---|---|
| Application | Flutter desktop executable/installer | Flutter APK/release application |
| Business/runtime logic | Shared Dart/PREDMET/IRiU/SCENARIO code | Shared Dart/PREDMET/IRiU/SCENARIO code |
| Persistence | Local SQLite/Drift files; filesystem/install path behavior differs | Local SQLite/Drift files; Android storage/runtime behavior differs |
| Platform services | Window lifecycle, filesystem, installer, notifications and single-instance concern | Notifications, storage permissions, lifecycle and device runtime |
| Acceptance | Owner/technical Windows runtime evidence by named artifact | Owner/technical physical-device evidence by named artifact |
| Open release risks | Signing, repaired-state closure | Signing/transfer/runtime parity and physical transfer/release rehearsal |

The Deployment view is necessary because platform behavior is part of the current architecture, not an implementation detail hidden from documentation.

## 8. Important runtime flows

### PREDMET and derivatives

```text
User/session → application shell → PredmetiRepository → PREDMET/SQLite
                                      ├→ IRiU/KATALOG selection and snapshots
                                      ├→ SCENARIO applied package/reconciliation
                                      ├→ finance/statistics and stock consequences
                                      ├→ PARTE/PDF/DOCX derivatives
                                      ├→ reminder signals/scheduling
                                      └→ JSON single-PREDMET/full-backup representations
```

### SCENARIO

```text
PREDMET facts + editable module definitions
        → package evaluation/order
        → applied package/snapshot/provenance
        → controlled reconciliation
        → ordered IRiU rows
        → locked regression/runtime contract
```

### Backup/restore

```text
user action → validation/format detection → transfer/backup serialization
           → compatibility/identity checks → controlled persistence mutation
           → restore evidence and runtime acceptance
```

## 9. Crosscutting concepts and significant technical decisions

- PREDMET master truth and derivative boundaries.
- Local-first storage and explicit database/migration compatibility.
- Package-based IRiU ordering and SCENARIO non-retroactivity.
- Stored KATALOG article/price snapshots rather than retroactive current-label rewriting.
- Separate single-PREDMET and full-backup JSON formats.
- Shared Windows/Android business logic with platform adapters.
- Sequential analyzer → full test → build gate for source/test/configuration changes.
- Human/owner runtime evidence is distinct from forensic root-cause evidence.
- SCENARIO lock and Tier 2 regression contract.

Durable technical decisions should be recorded as sparse ADRs only where their structure, dependency, interface, NFR or construction rationale would otherwise be lost. Owner business decisions belong in [`OPC_PRODUCT_AND_DOMAIN.md`](OPC_PRODUCT_AND_DOMAIN.md), not in ADRs.

## 10. Quality, risks and technical debt

Current quality concerns are functional suitability/data integrity, reliability, maintainability, security, usability, performance efficiency and Windows/Android compatibility. The important open risks are:

- stale public default branch versus current task authority;
- no automated analyze/test CI gate;
- release signing/version/provenance gaps;
- absent explicit IP/repository-use/distribution status and third-party license inventory;
- JSON interoperability monolith and cross-feature coupling;
- KATALOG ownership ambiguity;
- Repaired-state closure (installer running-app protection is closed by RR-012);
- incomplete PODSETNIK signal model;
- pseudocode drift (internal control concern, not product-doc gap alone);
- technical debt and dead-code/superseded-implementation audit still required.

This document describes current architecture. It does not select a target folder tree, authorize refactoring, change business meaning, unlock SCENARIO or imply that future controls are already implemented.

## 11. Source evidence index

- [`OPC_SOURCE_OF_TRUTH_MAP.md`](OPC_SOURCE_OF_TRUTH_MAP.md)
- [`OPC_MODULE_RELATIONSHIP_MAP.md`](OPC_MODULE_RELATIONSHIP_MAP.md)
- [`OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md`](OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md)
- [`OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`](OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md)
- [`OPC_CURRENT_DEVELOPMENT_STATE.md`](OPC_CURRENT_DEVELOPMENT_STATE.md)
- [`OPC_SCENARIO_MODULE_LOCK.md`](OPC_SCENARIO_MODULE_LOCK.md)
- [`OPC_SCENARIO_MODULE_LOCK_REPORT.md`](OPC_SCENARIO_MODULE_LOCK_REPORT.md)
- [`OPC_PHASE_1_FULL_CODE_ARCHITECTURE_REVIEW.md`](OPC_PHASE_1_FULL_CODE_ARCHITECTURE_REVIEW.md)
- [`OPC_POST_ZERO_ARCHITECTURE_DECISION_GATE_SYNTHESIS.md`](OPC_POST_ZERO_ARCHITECTURE_DECISION_GATE_SYNTHESIS.md)
