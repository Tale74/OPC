# OPC Product and Domain Authority

**Status:** `CURRENT AUTHORITATIVE PRODUCT/DOMAIN INFORMATION HOME`
**Phase 1 baseline:** `4e74772f72da921a2c94207a48c5530bfcc59e61`
**Scope:** current product meaning, business truth, derivatives, invariants and owner decisions. This document is not an implementation plan and does not authorize source, schema, UI, runtime or business-policy changes.

## 1. Product purpose and scope

OPC is a Flutter application for organizing funeral-ceremony business workflows. The same product runs on Windows and Android as standalone local applications. Each user/firma works with local Drift/SQLite data and user-controlled JSON transfer. The public GitHub repository is a sanitized source/documentation baseline; real case databases, customer/personal data, credentials, generated exports and machine-local artifacts remain outside Git.

The current product scope is the local OPC v.1 product line, developed on the
active OPC v1.5 line. A possible future Web or `OPC_v.1_Int` form is a later
product-line concern, not a current server-master architecture. No future
Web/backend/API/sync/storage/payment/role model is selected by this document.

## 2. Authority and evidence precedence

When current documents differ, use this order:

1. later explicit owner decisions and owner instructions;
2. current source and tests for implemented technical behavior;
3. latest scoped runtime/acceptance evidence, with platform and artifact stated;
4. the authoritative dependency-based development plan for sequencing;
5. older reports and pre-reconciliation material as historical evidence.

An owner runtime PASS proves observed end-product behavior for its platform/artifact. It does not by itself prove internal root cause. A technical contract or report does not override owner business authority.

The active maintenance model is **local project environment + public GitHub** until the owner defines a future transition, acquisition or distribution model. Local material outside Git remains relevant when this document or the Phase 1 manifest identifies it as current/supporting evidence; no uncontrolled duplicate authority is created. Active-source and donor classification is governed by [`OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`](OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md); documentation synchronization does not imply publication of a coherent implementation SOURCE baseline.

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
| ČITULJE | PREDMET-scoped article preparation for current ČITULJA IRiU occurrences | Persistent mode/date/text/note/finalization state is PREDMET business state; confirmed PARTE iterations may refresh the proposal until ČITULJE finalization, after which PARTE may no longer auto-refresh or overwrite it; authorized human correction/removal remains distinct from PARTE influence |
| PDF/DOCX and other documents | Rendered derivatives | Render PREDMET/IRiU/FirmaPodaci/user data; do not define business meaning |
| Finance/statistics | Calculations and projections over PREDMET/IRiU | Derived outputs; no independent totals authority |
| PODSETNIK/reminders | Operational reminders and notification scheduling | Derived/operational layer; recovered owner signal/trigger semantics are defined, while implementation, runtime acceptance, release and publication status are tracked separately by proven state |
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
| Fresh KATALOG boundary | A fresh database contains the 29 system-required KATALOG categories with zero business articles; existing KATALOG rows and user edits are preserved across reopen and migration | `AppDatabase` lifecycle, `KatalogCategoryBaseline`, migration and explicit catalog-fixture tests | Clean-start baseline, reopen, preservation and migration tests |
| KATALOG/SCENARIO identity and deletion boundary | `interniNaziv` is the stable category identity and `nazivPrikaz` is editable display text; user categories remain usable in SCENARIO definitions, and any persisted scenario reference blocks physical category deletion while preserving the existing deactivate/hide behavior | KATALOG baseline, SCENARIO persistence/reference check and settings repository | Clean-start identity, rename, custom/built-in reference protection and post-reference-delete tests |
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
- For transfer and restore, current PREDMET state includes intentional absence:
  scenario/package defaults may initialize a new PREDMET, but must not recreate
  a dependent row removed by a later SAVETNIK decision.
- PAKETI restrictions are retired for the current native product; retained entitlement/licensing payloads are compatibility/diagnostic material, not current business restriction authority.
- Windows and Android remain equal standalone local applications; no mandatory network sync is introduced.
- PODSETNIK's recovered owner contract, including the URNA/PEPEO contract, is
  locked. Current source includes the bounded URNA/PEPEO cycle and F-06 manual
  obligation integration; implementation/source evidence, runtime acceptance,
  release and publication status must be tracked separately. The scoped URNA
  completion blocker is not generalized to other obligations.
- The owner-authorized F-09 FINANSIJE target consists of two sibling child
  obligations under the FINANSIJE parent. OWNER-confirmed phase placement is:
  FINANSIJE — PRE-CEREMONY PARENT; PLATITI RAČUN and NAPLATITI OBAVEZE are
  sibling children, each PRE-CEREMONY. PLATITI RAČUN exists exactly when
  `TROŠKOVI JKP > 0 AND jkpPlacaSamostalno == false`; no additional payer
  identity/type field or other finance signal participates in that trigger.
  NAPLATITI OBAVEZE exists when `ZA NAPLATU > 0`. Both are manually completable
  and participate in the general REVIEW BAR while relevant and unfinished.
  Neither child depends on, precedes, or orders completion of the other. Both
  exact rules are implemented in current source; broader unspecified FINANSIJE
   reminder scope remains deferred.
- DVE VALUTE preparation, source-learning and implementation design are
  complete. Product implementation is deliberately deferred to the final OPC
  v1.5 finalization step. The accepted preparation model is one durable
  operative currency per PREDMET, preserved historical PREDMET currency,
  controlled first EUR activation with parallel KATALOG price layers, and
  stored-PREDMET currency for later documents. The remaining rounding,
  provenance, KATALOG UI, QR/payment and mixed-currency reporting decisions
  remain attached to that deferred finalization package and are not current
  product behavior.
- The canonical general PREDMET note is `Predmeti.napomena`, edited in
  `PREDMET → Segment 7: Roba i usluge → NAPOMENA`. PODSETNIK may present and
  edit that same field; it is not a second durable source. LISTA PDF projects
  the same content in a separate `NAPOMENE` section. Historical values in the
  retired Statusi, Finansije and per-ČITULJA note fields remain preserved in
  their existing storage/transfer contracts; those fields are no longer
  current editing inputs and are not automatically merged into the canonical
  note.
- LISTA PDF is a two-page maximum working checklist. Its `OBAVEZE` section
  projects current PODSETNIK business labels and visible parent/child groups
  with empty paper checkboxes; when useful, complete groups flow into a second
  column without separating children from their parent. Concise, source-backed
  operational context is attached to the obligation it explains, including
  selected articles and quantity, occurrence-matched CVEĆE article/ribbon,
  relevant OPELO/FINANSIJE/URNA details, ČITULJE occurrence context and
  human-entered manual obligation text. `URNA` and `PEPEO` keep the short
  business parent and actionable child labels used by PODSETNIK, not the full
  notification sentence. Generated financial note prose is retired from LISTA;
  financial values remain in the financial summary and user-entered canonical
  NAPOMENA remains unchanged. The two-page limit is not permission to omit,
  truncate or make required checklist content unreadable. OWNER accepted the
  corrected Windows LISTA runtime output on 2026-09-24, including OBAVEZE,
  NAPOMENE, CVEĆE occurrence/ribbon context, post-ceremony hierarchy and the
  two-page maximum; the earlier pre-correction runtime failure is historical.
- OWNER-authorized PREDMET action boundary: `PREDMET → DOKUMENTI` contains
  actual documents and document derivatives. Single-PREDMET JSON export is an
  operational transfer action, not a document, and belongs in the PREDMET
  three-dot menu. For one concrete PREDMET, that menu exposes the same option
  set from the overview/list row and opened/expanded detail view, subject to
  the same existing business/status conditions; no currently valid option is
  lost. Both surfaces consume one canonical action definition. JSON export is
  present in both menus and absent from `DOKUMENTI`; Single-PREDMET JSON import
  remains exclusively in `PODEŠAVANJA`. This presentation rule does not alter
  the Single-PREDMET or full Backup JSON transfer contracts.
- Native Windows single-instance protection and installer/update running-app protection are closed by full acceptance; remaining release-risk integrity and final backup/restore work remain separately controlled.
- NALOG CVEĆARI is an accepted/protected PDF-only unit; DOCX is not an open option.
- OWNER-authorized RAČUN availability is controlled solely by the FIRMA
  `RAČUN` toggle in `PODEŠAVANJA → PODACI FIRME`. Its label is `RAČUN`, fresh
  and migrated defaults are `DA`, and legacy full Backup without the field
  resolves to `DA`. The adjacent information text is exactly `Račun može da se
  formira ukoliko je pravno lice preduzetnik i nije u sistemu PDV`. The text is
  guidance for the user's toggle decision; OPC does not evaluate preduzetnik or
  PDV status and must not add either as a FIRMA model field. No other FIRMA
  value controls availability.
- RAČUN's existing Article 33 sentence is OWNER-approved `KEEP` content in both
  PDF and DOCX. `PREDMET → DOKUMENTI` offers separate `RAČUN PDF` and `RAČUN
  DOCX` actions under the same toggle. Both adapters consume one canonical
  RAČUN data model; full Backup preserves the FIRMA toggle, while
  Single-PREDMET JSON remains unchanged and excludes this FIRMA setting.
- `PREDMET PDF SNAPSHOT` is an obsolete document and is retired from the
  user-facing DOKUMENTI offer; its historical evidence is retained separately.
- The active standard PREDMET PDF set is SPECIFIKACIJA TROŠKOVA, PREDRAČUN,
  LISTA, NALOG ZA OPREMANJE, NALOG CVEĆARI and RAČUN. PARTE and ČITULJE remain
  separate modules outside this common DOKUMENTI/helper scope.
- Performance acceptance targets, app identity/version/update channel and
  future distribution/IP model remain owner decisions or owner/legal decisions
  as applicable.
- DVE VALUTE preparation is `DESIGN/PREPARATION COMPLETE` and its product
  implementation is deferred to the final OPC v1.5 finalization step. The
  finalized product is targeted as version `2.0`, with an explicit `SRB`
  distinction for the Serbian product line. Future `OPC Int` is a later
  product-line evolution based on that SRB foundation; it is not current
  implementation scope. The current running line remains OPC v1.5.

If two documents assign different business meaning, retain both as evidence, record the conflict in the Phase 1 manifest/report and mark `OWNER DECISION REQUIRED` unless newer explicit owner authority already resolves it.

## 7. Product glossary

| Term | Current meaning |
|---|---|
| PREDMET | Master business case and truth container |
| IRiU | Selected goods/services operational and financial rows attached to a PREDMET |
| KATALOG | Catalogue identity/configuration/price source |
| SCENARIO | Locked operational module for editable/default and applied package behavior |
| PARTE | PREDMET-derived technical preparation/print workflow |
| PODSETNIK | Reminder/notification operational area derived from PREDMET; current implementation, runtime acceptance, release and publication status are separate state claims. The exact owner-authorized F-09 targets and implementation evidence are recorded in §6 and the current-state home. |
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
