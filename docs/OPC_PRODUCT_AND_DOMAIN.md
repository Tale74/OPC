# OPC Product and Domain Authority

**Status:** `CURRENT AUTHORITATIVE PRODUCT/DOMAIN INFORMATION HOME`
**Phase 1 baseline:** `4e74772f72da921a2c94207a48c5530bfcc59e61`
**Scope:** current product meaning, business truth, derivatives, invariants and owner decisions. This document is not an implementation plan and does not authorize source, schema, UI, runtime or business-policy changes.

## 1. Product purpose and scope

OPC is a Flutter application for organizing funeral-ceremony business workflows. The same product runs on Windows and Android as standalone local applications. Each user/firma works with local Drift/SQLite data and user-controlled JSON transfer. The public GitHub repository is a sanitized source/documentation baseline; real case databases, customer/personal data, credentials, generated exports and machine-local artifacts remain outside Git.

The current product scope is the local OPC v.1 product line. A possible future Web or `OPC_v.1_Int` form is a later product-line concern, not a current server-master architecture. No future Web/backend/API/sync/storage/payment/role model is selected by this document.

## 2. Authority and evidence precedence

When current documents differ, use this order:

1. later explicit owner decisions and owner instructions;
2. current source and tests for implemented technical behavior;
3. latest scoped runtime/acceptance evidence, with platform and artifact stated;
4. the authoritative dependency-based development plan for sequencing;
5. older reports and pre-reconciliation material as historical evidence.

An owner runtime PASS proves observed end-product behavior for its platform/artifact. It does not by itself prove internal root cause. A technical contract or report does not override owner business authority.

The active maintenance model is **local project environment + public GitHub** until the owner defines a future transition, acquisition or distribution model. Local material outside Git remains relevant when this document or the Phase 1 manifest identifies it as current/supporting evidence; no uncontrolled duplicate authority is created.

## 3. PREDMET is the master business truth

`PREDMET` is the central case entity, workflow state, lifecycle and master business truth. It owns the facts from which operational rows, reminders, documents, statistics, stock consequences and transfer representations are derived.

No derivative may silently become a parallel business authority:

| Area | Current role | Truth boundary |
|---|---|---|
| PREDMET lifecycle and fields | Master case, person, payer, ceremony, status, version and history | Only master business truth |
| SCENARIO | User-editable module definitions and applied package behavior | Definitions/defaults are module data; selected/applied snapshot and provenance are PREDMET-owned; locked production contract remains protected |
| IRiU | Selected goods/services attached to a PREDMET; operational and financial case snapshot | PREDMET-scoped rows are the selected case truth; KATALOG owns catalogue truth |
| KATALOG | Stable article identity, catalogue labels/configuration and prices | Catalogue truth only; a current label must not overwrite a stored selected-article snapshot |
| PARTE | Technical preparation/print derivative | Derived from PREDMET; never a second case authority |
| PDF/DOCX and other documents | Rendered derivatives | Render PREDMET/IRiU/FirmaPodaci/user data; do not define business meaning |
| Finance/statistics | Calculations and projections over PREDMET/IRiU | Derived outputs; no independent totals authority |
| PODSETNIK/reminders | Operational reminders and notification scheduling | Derived/operational layer; final signal/trigger semantics remain an owner decision |
| STANJE ROBE | Inventory and effect/consequence lifecycle | Operational consequences over selected PREDMET/IRiU rows; must not rewrite PREDMET truth or KATALOG truth |
| JSON single-PREDMET transfer and full backup | Interoperability representations | Preserve master/derivative boundaries; single-PREDMET and full-backup formats remain distinct |
| Auth, users, settings and entitlements | Session, firm/user/configuration and technical access context | May supply context; must not redefine PREDMET meaning |

## 4. Current business invariants

These are current documented invariants. They are not a new policy proposal.

| Invariant | Meaning | Current source/evidence | Protecting tests or evidence |
|---|---|---|---|
| PREDMET authority | All derivatives consume PREDMET truth; derivatives do not become masters | `lib/features/predmeti/**`, `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md` | PREDMET lifecycle and module-contract tests |
| Explicit lifecycle | Current implemented transition is `OTVOREN → ZATVOREN → ZAVRŠEN`; direct editing/reopening of final state is constrained by current rules | `PredmetiRepository`, current-state and owner decision records | Lifecycle-focused tests; final platform runtime acceptance remains separately scoped |
| IRiU order | `ordered OSNOVNI PAKET → ordered applied SCENARIO PAKET → manual/unpredicted items` | `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`, `docs/OPC_DEVELOPMENT.md` | SCENARIO/Tier 2 contract and ordering tests |
| SCENARIO non-retroactivity | Current module definitions do not silently rewrite an already applied PREDMET snapshot | SCENARIO lock docs, scenario repository/contracts | SCENARIO snapshot/provenance and reconciliation tests |
| SCENARIO lock | Production source SHA `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`; lock publication is the Phase 1 baseline lineage | `docs/OPC_SCENARIO_MODULE_LOCK.md`, lock report | Locked regression contract and owner runtime evidence |
| Catalogue snapshot | Selected concrete article/price snapshots remain stable when current KATALOG labels/prices change | IRiU/KATALOG source and owner decision `OPC-OD-IRIU-KATALOG-LABEL-010` | KATALOG/IRiU contract and malformed-row tests |
| Fresh KATALOG boundary | A fresh database contains no user/business KATALOG categories or articles; existing KATALOG rows are preserved across reopen and migration | `AppDatabase` lifecycle, migration and explicit catalog-fixture tests | Empty-database, reopen, preservation and migration tests |
| Financial reconciliation | For included rows, displayed amount follows `KOM × CENA = IZNOS`, with current manual-override rules | Business/domain maps and current IRiU implementation | Business-policy and pricing tests |
| Backup distinction | Single-PREDMET transfer and broad full-backup JSON are separate formats and contracts | `core/json_transfer`, `json_export_import`, backup/restore policy docs | JSON transfer regression and restore evidence |
| Local data boundary | Runtime databases, customer data, exports and secrets are not repository authority | `.gitignore`, README, architecture/runtime evidence | Repository hygiene and restore policies |

## 5. Domain flow in current product terms

1. A user creates or opens a PREDMET through the application shell and PREDMET repository.
2. PREDMET fields capture person, payer, ceremony, status and related business facts.
3. IRiU rows are selected/edited using KATALOG and policy inputs; selected rows and snapshots are PREDMET-scoped.
4. SCENARIO definitions and applied package state contribute controlled derived selections while preserving PREDMET ownership and non-retroactivity.
5. Finance, stock consequences, reminders, PARTE, PDF/DOCX and statistics consume current PREDMET/IRiU truth.
6. Save/close/reopen/finish flows persist current truth and lifecycle metadata through the repository/database boundary.
7. JSON transfer/backup exports representations subject to compatibility and restore contracts.

## 6. Current owner decisions and open meaning

The following materially define the current product or remain explicitly open:

- SCENARIO is an operational module under `MODULI`, not `PODEŠAVANJA`, and remains locked.
- PAKETI restrictions are retired for the current native product; retained entitlement/licensing payloads are compatibility/diagnostic material, not current business restriction authority.
- Windows and Android remain equal standalone local applications; no mandatory network sync is introduced.
- PODSETNIK's complete signal/informed-reminder model is open. The Android notification for a `ZAVRŠEN` PREDMET belongs to the lifecycle-aware program, not an isolated patch.
- Windows single-instance protection, current release-risk integrity and final backup/restore rehearsal remain open technical gates.
- NALOG CVEĆARI scope, RAČUN availability/default, performance acceptance targets, app identity/version/update channel and future distribution/IP model remain owner decisions or owner/legal decisions as applicable.
- `MODUL DVE VALUTE`, Web, `OPC_v.1_Int` and broader synchronization are future scope.

If two documents assign different business meaning, retain both as evidence, record the conflict in the Phase 1 manifest/report and mark `OWNER DECISION REQUIRED` unless newer explicit owner authority already resolves it.

## 7. Product glossary

| Term | Current meaning |
|---|---|
| PREDMET | Master business case and truth container |
| IRiU | Selected goods/services operational and financial rows attached to a PREDMET |
| KATALOG | Catalogue identity/configuration/price source |
| SCENARIO | Locked operational module for editable/default and applied package behavior |
| PARTE | PREDMET-derived technical preparation/print workflow |
| PODSETNIK | Reminder/notification operational area; complete signal semantics remain open |
| STANJE ROBE | Inventory and effect/consequence operational layer |
| Derivative | Any document, projection, reminder, stock effect or transfer representation derived from master truth |
| Owner runtime evidence | Observed behavior acceptance for a named platform/artifact; not automatic root-cause proof |
| Internal pseudocode | Strictly internal Tale/Logos development-control material; not product or handover documentation |

## 8. Navigation and evidence

- Current architecture: [`OPC_ARCHITECTURE.md`](OPC_ARCHITECTURE.md)
- Development and authority workflow: [`OPC_DEVELOPMENT.md`](OPC_DEVELOPMENT.md)
- Quality and release: [`OPC_QUALITY_RELEASE.md`](OPC_QUALITY_RELEASE.md)
- Adopted engineering profile: [`OPC_ENGINEERING_PROFILE.md`](OPC_ENGINEERING_PROFILE.md)
- Migration/authority manifest: [`OPC_PHASE1_DOCUMENTATION_MIGRATION_AUTHORITY_MANIFEST.csv`](OPC_PHASE1_DOCUMENTATION_MIGRATION_AUTHORITY_MANIFEST.csv)
- Internal/archive classification: [`OPC_PHASE1_ARCHIVE_AND_INTERNAL_GOVERNANCE_CLASSIFICATION.md`](OPC_PHASE1_ARCHIVE_AND_INTERNAL_GOVERNANCE_CLASSIFICATION.md)
- Internal development-control boundary: [`OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md`](OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md)
- Existing detailed evidence remains linked through [`OPC_SOURCE_OF_TRUTH_MAP.md`](OPC_SOURCE_OF_TRUTH_MAP.md), the owner decision index and the authoritative dependency plan.
