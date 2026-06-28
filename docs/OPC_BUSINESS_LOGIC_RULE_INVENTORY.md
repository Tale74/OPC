# OPC Business Logic Rule Inventory

Status: public audit baseline for current OPC business rules.

This inventory is documentation only. It records policy, owner decisions, source evidence, test evidence, gaps, and future-risk boundaries. It does not authorize source, database, JSON behavior, PDF, UI, Web, sync, storage, payment, role, package, or migration changes.

## RULE-ID: OPC-RULE-PREDMET-001

Name: PREDMET master business truth
Status: MASTER / CURRENT
Domain: PREDMET
Rule statement: `PREDMET` is the central and only master business truth for OPC case work. PDFs, JSON transfers, lists, statistics, reminders, inventory consequences, and operational documents are derived from or organized around PREDMET.
Evidence classification: DOCUMENTED POLICY
Evidence locations: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`; `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`; `docs/OPC_OWNER_DECISION_REPORT.md`
Current implementation state: Supported by broad source organization around `PredmetiData` and `predmeti` table; not a single code assertion.
Windows/Android parity: Same product logic must be preserved.
JSON/PDF/UI relevance: JSON and PDF must stay faithful derivatives.
Future Web/sync relevance: Critical; Web/sync must not create another master PREDMET database by implication.
Risk if changed: Loss of business identity, inconsistent case truth, unsafe transfer/sync design.
Open questions: None for policy; implementation details remain per-domain.
Recommended next action: Preserve as invariant in all future tasks.

## RULE-ID: OPC-RULE-PREDMET-002

Name: PREDMET lifecycle and versioning
Status: PARTIALLY IMPLEMENTED / TEST GAP
Domain: PREDMET lifecycle
Rule statement: A new PREDMET starts as `OTVOREN`, can be saved as working state, can be confirmed closed as `ZATVOREN`, can be reopened for edit, can become `ZAVRŠEN`, and can be `ANONIMIZOVAN`. Business `verzija` starts at 1 and increments on confirmed close only when a prior confirmed snapshot exists and business data changed.
Evidence classification: SOURCE-CONFIRMED / TEST GAP
Evidence locations: `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; prior lifecycle task report
Current implementation state: Source-confirmed. Tests cover related JSON/STANJE ROBE areas but not the full lifecycle state machine end to end.
Windows/Android parity: Shared Dart source; runtime parity not freshly confirmed.
JSON/PDF/UI relevance: `verzija` is exported/imported in PREDMET JSON and displayed in PDF snapshot/UI review.
Future Web/sync relevance: Critical for version reasoning, conflict UI, and replica behavior.
Risk if changed: Incorrect overwrite decisions, false version history, unsafe Web/sync merge assumptions.
Open questions: Whether `verzija` alone is sufficient for future conflict/version reasoning.
Recommended next action: Dedicated version model audit and tests before implementation changes.

## RULE-ID: OPC-RULE-IMPORT-001

Name: Same-brojPredmeta keep / replace / cancel
Status: OWNER CLARIFICATION / SOURCE-CONFIRMED
Domain: Single-PREDMET JSON import
Rule statement: When a single-PREDMET JSON has the same non-empty trimmed `brojPredmeta` as exactly one local PREDMET, explicit keep / replace / cancel user choice is intentional business behavior, not a defect. It exists because real business truth may change when `Platilac` or other parties change their mind.
Evidence classification: OWNER CLARIFICATION / SOURCE-CONFIRMED
Evidence locations: `lib/core/utils/json_export_import.dart`; `docs/tasks/OPC_TASK_BUSINESS_LOGIC_EXTRACTION_SINGLE_PREDMET_JSON_IMPORT_FRESHNESS_AND_OVERWRITE_GUARD_REPORT.md`
Current implementation state: UI conflict dialog offers cancel, keep local, or replace imported. Multiple local matches block replacement.
Windows/Android parity: Shared import code; Android layout differs only by dialog sizing/file-read adapter.
JSON/PDF/UI relevance: Conflict UI displays local/imported metadata and deceased name.
Future Web/sync relevance: Critical; automatic hard-blocking must not remove owner-approved user choice unless a future owner decision changes the rule.
Risk if changed: User may be unable to select the correct business version after a legitimate case change.
Open questions: Which future version warning or guard should accompany the choice.
Recommended next action: Preserve user choice; design any future freshness warnings under separate owner-approved task.

## RULE-ID: OPC-RULE-FILENAME-001

Name: Single-PREDMET JSON filename is UX only
Status: OWNER CLARIFICATION
Domain: Filename / JSON transfer
Rule statement: `Ime_Prezime`, `PREZIME_IME`, and the single-PREDMET JSON filename are user-facing recognition aids. They are not system identity, conflict key, freshness key, or canonical PREDMET identity.
Evidence classification: OWNER CLARIFICATION / SOURCE-CONFIRMED
Evidence locations: `docs/OPC_OWNER_DECISION_REPORT.md`; `lib/core/format/app_filename_format.dart`; `lib/core/utils/json_export_import.dart`
Current implementation state: Export filename helpers sanitize/display names. Import reads JSON content and does not use filename as conflict key.
Windows/Android parity: Shared filename/export logic; platform file storage differs.
JSON/PDF/UI relevance: Filename helps users recognize files; JSON content carries business data.
Future Web/sync relevance: Critical; do not design identity around filenames.
Risk if changed: False conflicts, privacy/name ambiguity, unsafe identity matching.
Open questions: None for policy.
Recommended next action: Preserve distinction in future import/export docs.

## RULE-ID: OPC-RULE-VERSION-001

Name: `verzija` is PREDMET business-version signal
Status: OWNER DECISION / TECHNICAL AUDIT REQUIRED
Domain: Versioning
Rule statement: `verzija` is the relevant future version/revision signal for PREDMET business-state reasoning. It is not export time, filename identity, firm identity, global identity, or proof by itself that automatic overwrite is safe.
Evidence classification: OWNER DECISION / SOURCE-CONFIRMED / TEST GAP
Evidence locations: `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/core/utils/json_export_import.dart`; `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart`
Current implementation state: Defined on PREDMET with default 1; incremented on confirmed close with business change; exported/imported with PREDMET; displayed in conflict dialog and PDFs; not compared in current import conflict logic.
Windows/Android parity: Shared source.
JSON/PDF/UI relevance: JSON, conflict UI, and PDF snapshot include it.
Future Web/sync relevance: Critical candidate for conflict reasoning.
Risk if changed: Wrong freshness/overwrite behavior.
Open questions: Missing/malformed version policy, same-version behavior, higher/lower-version warnings, and whether business snapshots should be part of version authority.
Recommended next action: Separate version semantics design before implementation; preserve explicit user choice meanwhile.

## RULE-ID: OPC-RULE-VERSION-002

Name: `exportDatum` is export metadata only
Status: OWNER DECISION / SOURCE-CONFIRMED
Domain: JSON export metadata
Rule statement: `exportDatum` records when a JSON file was exported. It is not business freshness authority and must not be treated as proof that the exported PREDMET is newer or more correct.
Evidence classification: OWNER DECISION / SOURCE-CONFIRMED
Evidence locations: `lib/core/utils/json_export_import.dart`; `lib/core/json_transfer/predmet_json_transfer_core.dart`; freshness audit report
Current implementation state: Generated during single-PREDMET and full backup JSON export; decoded as optional metadata by candidate core; not compared in import conflict logic.
Windows/Android parity: Shared source.
JSON/PDF/UI relevance: JSON metadata only.
Future Web/sync relevance: Must not become conflict authority.
Risk if changed: Exporting an old business state later could falsely appear newer.
Open questions: Whether future UI should display it only as export time.
Recommended next action: Keep as metadata; use `verzija`/business model design for future freshness reasoning.

## RULE-ID: OPC-RULE-VERSION-003

Name: Import conflict user choice must be preserved
Status: OWNER DECISION / SOURCE-CONFIRMED
Domain: Versioning / single-PREDMET JSON import
Rule statement: Future use of `verzija` may warn, compare, highlight, or classify local/imported PREDMET versions, but `verzija` alone must not remove keep / replace / cancel user choice unless a later owner decision explicitly authorizes a hard block.
Evidence classification: OWNER DECISION / SOURCE-CONFIRMED
Evidence locations: `docs/OPC_OWNER_DECISION_REPORT.md`; `lib/core/utils/json_export_import.dart`; freshness audit report
Current implementation state: Current same-`brojPredmeta` import UI shows local/imported metadata and offers `Odustani`, `Zadrži lokalni`, and `Zameni uvoznim`; no version comparator or hard block was found.
Windows/Android parity: Shared import source; runtime parity not freshly confirmed.
JSON/PDF/UI relevance: Import conflict UI and JSON transfer.
Future Web/sync relevance: Critical for conflict-resolution design.
Risk if changed: The app could incorrectly remove human business arbitration when `Platilac` or other facts change.
Open questions: Exact warning text and comparison thresholds.
Recommended next action: Design warning/comparison UI under a future JSON safety task without changing current behavior here.

## RULE-ID: OPC-RULE-VERSION-004

Name: `verzija` is not identity
Status: OWNER DECISION
Domain: Versioning / identity
Rule statement: `verzija` is not an identity key. Future-safe PREDMET identity/conflict scope remains `PIB + Matični broj + brojPredmeta`; `verzija` is only a version signal after the same firm-scoped case has been identified.
Evidence classification: OWNER DECISION / DOCUMENTED POLICY
Evidence locations: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`; `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_SEMANTICS_FOR_PREDMET_AND_SINGLE_PREDMET_JSON_IMPORT_REPORT.md`
Current implementation state: Current import matching still uses `brojPredmeta` only; firm-scoped identity guard is not implemented.
Windows/Android parity: Shared source; policy applies to all runtimes.
JSON/PDF/UI relevance: JSON import/export and future conflict UI.
Future Web/sync relevance: Critical for replica identity and merge safety.
Risk if changed: Version values could be used to match wrong firm/case.
Open questions: How firm identity should be encoded and verified in single-PREDMET JSON.
Recommended next action: Keep identity and versioning separate in future design.

## RULE-ID: OPC-RULE-VERSION-005

Name: Filename `_vN` is not authoritative PREDMET version
Status: OWNER DECISION / POLICY EXISTS / IMPLEMENTATION NOT FOUND
Domain: Filename / versioning
Rule statement: Filename `_vN` in names such as `PREZIME_IME_brojPredmeta_vN.json` is not authoritative `predmet.verzija` unless source/test evidence proves exact mapping and a later owner decision approves that interpretation.
Evidence classification: OWNER DECISION / SOURCE-CONFIRMED
Evidence locations: `docs/OPC_OWNER_DECISION_REPORT.md`; `lib/core/format/app_filename_format.dart`; `lib/core/utils/json_export_import.dart`; freshness audit report
Current implementation state: Filename is generated for UX recognition; import reads JSON content and no filename `_vN` import authority was found.
Windows/Android parity: Shared source; platform file adapters differ.
JSON/PDF/UI relevance: Export filenames and user recognition only.
Future Web/sync relevance: Prevents filename-based version/identity drift.
Risk if changed: Wrong version inference from editable or user-renamed files.
Open questions: Whether filename suffix should ever mirror business `verzija`; no approval exists now.
Recommended next action: Use JSON content and owner-approved version design, not filename suffix, for future reasoning.

## RULE-ID: OPC-RULE-VERSION-006

Name: Version conflict policy matrix
Status: OWNER DECISION / IMPLEMENTATION REQUIRED
Domain: Versioning / single-PREDMET JSON import
Rule statement: Future same-PREDMET import conflict handling must classify imported higher, imported lower, same version, imported missing, imported malformed, and local missing/malformed `verzija` cases. The UI must show or warn about the relevant state, preserve explicit keep / replace / cancel choice unless a later owner decision authorizes a hard block, prevent silent overwrite, and must not use `exportDatum` as freshness authority.
Evidence classification: OWNER DECISION
Evidence locations: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_CONFLICT_POLICY_AND_PREDMET_CHANGE_LOG_REQUIREMENT_REPORT.md`
Current implementation state: Policy recorded only. Current inspected import behavior displays version metadata but has no approved comparator, warning matrix, automatic replacement, or hard block.
Windows/Android parity: Policy applies to all runtimes; runtime parity must be audited during implementation.
JSON/PDF/UI relevance: Single-PREDMET JSON import conflict UI.
Future Web/sync relevance: Critical for future conflict resolution and replica behavior.
Risk if changed: Silent overwrite, false freshness decisions, or removal of owner-approved business choice.
Open questions: Exact warning copy, UI placement, and whether any later hard block is required.
Recommended next action: Design and implement only under a separate JSON/version conflict task with tests and platform parity checks.

## RULE-ID: OPC-RULE-VERSION-007

Name: Missing/malformed version handling
Status: OWNER DECISION / IMPLEMENTATION REQUIRED
Domain: Versioning / JSON compatibility
Rule statement: Missing or malformed imported `verzija`, and missing or malformed local `verzija`, must be treated as unknown or invalid version state. Future UI must warn or classify this state, preserve keep / replace / cancel unless a later owner decision authorizes a hard block, must not silently treat either side as newer, and must not fall back to `exportDatum` as authority.
Evidence classification: OWNER DECISION
Evidence locations: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_CONFLICT_POLICY_AND_PREDMET_CHANGE_LOG_REQUIREMENT_REPORT.md`
Current implementation state: Policy recorded only. No source, schema, or import behavior changes were made by this rule entry.
Windows/Android parity: Policy applies equally to Windows and Android.
JSON/PDF/UI relevance: JSON import conflict and compatibility handling.
Future Web/sync relevance: Critical for defensive conflict handling with older, damaged, or externally edited transfer files.
Risk if changed: Unknown or invalid version data could be mistaken for authoritative business freshness.
Open questions: Exact validation boundary and user-facing Serbian wording.
Recommended next action: Add comparator/validation design and tests in a future implementation task.

## RULE-ID: OPC-RULE-PREDMET-CHANGELOG-001

Name: PREDMET version/change-log overview requirement
Status: OWNER DECISION / IMPLEMENTATION REQUIRED / TECHNICAL AUDIT REQUIRED
Domain: PREDMET review / version history
Rule statement: PREDMET should have a document/versioning overview that shows version history or change-log information relevant to business review and confirmation.
Evidence classification: OWNER DECISION
Evidence locations: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_CONFLICT_POLICY_AND_PREDMET_CHANGE_LOG_REQUIREMENT_REPORT.md`
Current implementation state: Requirement recorded only. No change-log database model, UI, JSON schema, import behavior, or source behavior is implemented by this task.
Windows/Android parity: Future overview must preserve equivalent business meaning on both platforms.
JSON/PDF/UI relevance: Intended as PREDMET UI review behavior; JSON/PDF implications require later design.
Future Web/sync relevance: Important for explaining version history and conflict choices.
Risk if changed: Users may lack business context for confirming or replacing a PREDMET version.
Open questions: Source of change-log data, exact business events to include, retention, and migration requirements.
Recommended next action: Audit current lifecycle/version/log data before adding any model or UI.

## RULE-ID: OPC-RULE-PREDMET-REVIEW-001

Name: `Pregled i potvrda` is intended location for version/change-log overview
Status: OWNER DECISION / IMPLEMENTATION REQUIRED / TECHNICAL AUDIT REQUIRED
Domain: PREDMET review UI
Rule statement: The intended future location for the PREDMET version/change-log overview is `Pregled i potvrda` inside PREDMET, because that is where business state is reviewed and confirmed. The overview must not be hidden in a technical/debug-only screen.
Evidence classification: OWNER DECISION
Evidence locations: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_CONFLICT_POLICY_AND_PREDMET_CHANGE_LOG_REQUIREMENT_REPORT.md`
Current implementation state: Location decision recorded only. Current `Pregled i potvrda` suitability still requires technical/UI audit.
Windows/Android parity: Future UI must remain business-equivalent across Windows and Android.
JSON/PDF/UI relevance: PREDMET review UI.
Future Web/sync relevance: Future Web must preserve the same review meaning if implemented.
Risk if changed: Version/change-log context could be separated from the confirmation workflow where it matters.
Open questions: Layout, information density, and exact change-log source.
Recommended next action: Audit current `Pregled i potvrda` structure before UI implementation.

## RULE-ID: OPC-RULE-FIRMA-001

Name: Firm-owned local database
Status: DOCUMENTED POLICY / PARTIALLY IMPLEMENTED
Domain: Firma / database ownership
Rule statement: The firm/user owns and controls the local OPC database. No server or other database is automatically master.
Evidence classification: DOCUMENTED POLICY / SOURCE-CONFIRMED
Evidence locations: manifest; `lib/core/database/tables/firma_podaci_table.dart`; `lib/features/podesavanja/data/podesavanja_repository.dart`
Current implementation state: Local Drift/SQLite database and singleton `FirmaPodaci` exist. Stable history model is not implemented.
Windows/Android parity: Shared database model.
JSON/PDF/UI relevance: Firm data appears in settings, PDFs, and full backup.
Future Web/sync relevance: Critical.
Risk if changed: Server-master drift and unsafe restore/sync assumptions.
Open questions: Firm identity history and immutable identity model.
Recommended next action: Technical audit for `FirmaPodaci` history.

## RULE-ID: OPC-RULE-FIRMA-002

Name: Firm-scoped PREDMET identity
Status: OWNER DECISION / POLICY EXISTS / IMPLEMENTATION NOT FOUND
Domain: Identity / conflict
Rule statement: `brojPredmeta` is unique only within the same firm. Future-safe identity/conflict scope is `PIB + Matični broj + brojPredmeta`; `brojPredmeta` alone is not global identity.
Evidence classification: OWNER DECISION / POLICY EXISTS / IMPLEMENTATION NOT FOUND
Evidence locations: owner decision report; locked rules summary; import reports; `lib/core/utils/json_export_import.dart`
Current implementation state: Current single-PREDMET conflict lookup uses trimmed `brojPredmeta` only. No firm-scoped conflict guard or unique constraint was found in inspected source.
Windows/Android parity: Shared source; not implemented.
JSON/PDF/UI relevance: JSON import/export and backup/restore.
Future Web/sync relevance: Critical.
Risk if changed: Cross-firm false match or unsafe overwrite.
Open questions: Whether single-PREDMET JSON must carry firm identity metadata.
Recommended next action: JSON safety / repository identity design task.

## RULE-ID: OPC-RULE-PLATILAC-001

Name: Platilac current visible display term
Status: PARTIALLY IMPLEMENTED / OWNER REVIEW REQUIRED
Domain: Payer / terminology
Rule statement: `Platilac` is the current visible UI/PDF/business display term, while `narucilac` remains internal/mixed legacy code/database/JSON/template terminology.
Evidence classification: SOURCE-CONFIRMED / DOCUMENTED POLICY
Evidence locations: terminology glossary; terminology lineage report; `lib/features/predmeti/presentation/segments/narucilac_segment.dart`; `lib/features/predmeti/pdf/*`
Current implementation state: Visible UI/PDF mostly says PLATILAC; source/DB/JSON fields keep `naru*` and `narucilac*`.
Windows/Android parity: Shared UI/source where used.
JSON/PDF/UI relevance: High; UI, PDF, JSON compatibility.
Future Web/sync relevance: Terminology compatibility must be preserved.
Risk if changed: Migration/JSON/PDF breakage and business confusion.
Open questions: Owner decision on cleanup path.
Recommended next action: Separate terminology compatibility plan before any rename.

## RULE-ID: OPC-RULE-PLATILAC-002

Name: Platilac change-of-mind rationale
Status: OWNER CLARIFICATION
Domain: Import conflict / business truth
Rule statement: `Platilac` or other parties may change their mind after a JSON export, so the app must not automatically decide which same-PREDMET version is correct when human business choice is required.
Evidence classification: OWNER CLARIFICATION
Evidence locations: current task instructions; same-PREDMET import reports
Current implementation state: Current keep/replace/cancel flow aligns with this clarification.
Windows/Android parity: Shared import flow.
JSON/PDF/UI relevance: Conflict UI and future warning text.
Future Web/sync relevance: Critical for replica conflict handling.
Risk if changed: Loss of owner-approved human arbitration.
Open questions: Future warning metadata design.
Recommended next action: Preserve explicit choice.

## RULE-ID: OPC-RULE-JSON-001

Name: Single-PREDMET JSON transfer boundary
Status: PARTIALLY IMPLEMENTED
Domain: JSON transfer
Rule statement: Single-PREDMET JSON transfers one PREDMET plus approved connected data and is distinct from full database backup/restore.
Evidence classification: SOURCE-CONFIRMED / TEST-CONFIRMED / DOCUMENTED POLICY
Evidence locations: `lib/core/utils/json_export_import.dart`; `lib/core/json_transfer/predmet_json_transfer_core.dart`; `test/json_transfer_regression_test.dart`
Current implementation state: Current `OPC_PREDMET` exports `predmet`, `iriu`, `kontaktLica`, and approved unresolved stock consequence transfer block when applicable.
Windows/Android parity: Shared source.
JSON/PDF/UI relevance: High.
Future Web/sync relevance: Critical; do not merge with full backup semantics.
Risk if changed: Unsafe transfer of unrelated database truth.
Open questions: Compatibility matrix and firm identity metadata.
Recommended next action: Keep transfer boundary explicit.

## RULE-ID: OPC-RULE-JSON-002

Name: Full backup / restore boundary
Status: PARTIALLY IMPLEMENTED / POLICY EXISTS / IMPLEMENTATION NOT FOUND
Domain: Backup / restore
Rule statement: Full backup JSON is broader recovery behavior and is destructive on import; PIB/Matični broj mismatch must block import/restore by owner decision.
Evidence classification: SOURCE-CONFIRMED / DOCUMENTED POLICY / POLICY EXISTS / IMPLEMENTATION NOT FOUND
Evidence locations: backup/restore public summary; `lib/core/utils/json_export_import.dart`; JSON regression tests
Current implementation state: Full backup contains broad database sections and destructive import confirmation; firm identity mismatch guard is not confirmed implemented.
Windows/Android parity: Shared source; runtime not freshly confirmed.
JSON/PDF/UI relevance: Full backup only, not single-PREDMET transfer.
Future Web/sync relevance: Critical.
Risk if changed: Destructive wrong-firm restore.
Open questions: Guard source fields and history model.
Recommended next action: Repository/firma identity guard design.

## RULE-ID: OPC-RULE-STOCK-001

Name: STANJE ROBE operational consequences
Status: PARTIALLY IMPLEMENTED / TEST-CONFIRMED
Domain: STANJE ROBE
Rule statement: STANJE ROBE is operational consequence logic, not a parallel PREDMET truth. Covered categories affect stock when licensed and operationally enabled; unresolved consequences are recorded when stock is insufficient.
Evidence classification: SOURCE-CONFIRMED / TEST-CONFIRMED / DOCUMENTED POLICY
Evidence locations: `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`; `lib/features/stanje_robe/application/stanje_robe_lifecycle_service.dart`; `test/stanje_robe_operational_toggle_test.dart`
Current implementation state: Entitlement plus settings control operational status; lifecycle service applies/restores/records effects for covered categories.
Windows/Android parity: Shared source; UI runtime parity not freshly confirmed.
JSON/PDF/UI relevance: Single-PREDMET JSON may carry approved unresolved consequence transfer, not warehouse quantities.
Future Web/sync relevance: Critical consequence boundary.
Risk if changed: Inventory could become inconsistent or falsely master.
Open questions: Full backup/import stock handling.
Recommended next action: Complete STANJE ROBE import/restore audit.

## RULE-ID: OPC-RULE-IRiU-001

Name: IRIU selected item and business policy
Status: PARTIALLY IMPLEMENTED / TEST-CONFIRMED
Domain: IRIU / articles / services
Rule statement: PREDMET/IRiU selected snapshot rows remain business-visible while catalog owns catalog truth. Business policy can auto-manage required categories such as limeni ulozak and lemovanje based on ceremony/death/cemetery conditions.
Evidence classification: SOURCE-CONFIRMED / TEST-CONFIRMED
Evidence locations: `lib/features/predmeti/core_v2/business_policy/*`; `lib/features/predmeti/core_v2/services/*`; `test/business_policy_iriu_critical_scenarios_test.dart`
Current implementation state: Core evaluator and lifecycle services exist; tests cover critical scenarios.
Windows/Android parity: Shared source.
JSON/PDF/UI relevance: IRIU appears in UI, PDFs, JSON transfer, stock consequences.
Future Web/sync relevance: Must preserve selected snapshots and catalog identity separation.
Risk if changed: Wrong operational document and inventory consequences.
Open questions: Owner-reviewed full rule map.
Recommended next action: Expand public IRIU rule documentation.

## RULE-ID: OPC-RULE-FINANCE-001

Name: Finance/refund/payment calculation
Status: SOURCE-CONFIRMED / TEST GAP
Domain: Finance / PIO / payment
Rule statement: Finance UI/PDF use IRIU totals, PIO refund setting, `narucilacRefundira`/Platilac refund choice, advance, JKP costs, discount, and payment-method fields to calculate displayed payment state.
Evidence classification: SOURCE-CONFIRMED / TEST GAP
Evidence locations: `lib/features/predmeti/presentation/segments/finansije_segment.dart`; `lib/features/predmeti/pdf/lista_pdf_data_builder.dart`; `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart`
Current implementation state: Source-confirmed calculation paths; dedicated finance calculation tests were not found in this audit.
Windows/Android parity: Shared source.
JSON/PDF/UI relevance: UI, PDF, JSON fields.
Future Web/sync relevance: Preserve as PREDMET-derived financial truth.
Risk if changed: Incorrect charge/refund documents.
Open questions: Full finance test coverage.
Recommended next action: Add focused finance rule tests in a future implementation/testing task.

## RULE-ID: OPC-RULE-USER-001

Name: Local users, administrators, and advisers
Status: PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED
Domain: Users / roles
Rule statement: Current app has local users with `ADMINISTRATOR` and `SAVETNIK` roles, PIN login, first-admin creation, active/inactive status, and safeguards against removing the last active administrator.
Evidence classification: SOURCE-CONFIRMED / TEST-CONFIRMED
Evidence locations: `lib/core/database/tables/korisnici_table.dart`; `lib/features/auth/data/auth_repository.dart`; `lib/features/auth/domain/session_service.dart`; auth and STANJE ROBE tests
Current implementation state: Local user/role behavior exists. Stable firm/license role architecture is not implemented.
Windows/Android parity: Shared source.
JSON/PDF/UI relevance: `savetnikId`, `createdByKorisnikId`, and `lastBusinessModifiedByKorisnikId` are PREDMET metadata and backup data.
Future Web/sync relevance: Critical; local IDs are not enough for cross-device stable identity.
Risk if changed: Loss of audit/history continuity.
Open questions: Stable user identity and historical signatures.
Recommended next action: Administrator/Savetnik stable ID audit.

## RULE-ID: OPC-RULE-PACKAGE-001

Name: Package and entitlement fail-closed policy
Status: PARTIALLY IMPLEMENTED / OWNER DECISION
Domain: Packages / licensing
Rule statement: Canonical packages are `Osnovni`, `Srednji`, `Potpuni`; OPC is built as full product and functions/services can be disabled according to paid package without changing PREDMET truth. Unknown/unsafe entitlement must fail closed.
Evidence classification: OWNER DECISION / SOURCE-CONFIRMED / TEST-CONFIRMED
Evidence locations: owner decision report; `lib/core/entitlements/opc_entitlement_policy.dart`; `test/opc_local_license_parser_test.dart`; `test/package_downgrade_migration_test.dart`
Current implementation state: Entitlement policy and tests exist; payment/subscription implementation is blocked.
Windows/Android parity: Shared source.
JSON/PDF/UI relevance: Module/document/settings visibility.
Future Web/sync relevance: Must not change PREDMET truth or ownership.
Risk if changed: Paid package logic could corrupt core business data.
Open questions: Final commercial/payment model.
Recommended next action: Payment/access gate before implementation.

## RULE-ID: OPC-RULE-PDF-001

Name: PDFs are derivatives of PREDMET
Status: SOURCE-CONFIRMED / DOCUMENTED POLICY
Domain: PDF / documents
Rule statement: PDFs render PREDMET-derived data and must not become independent business truth.
Evidence classification: DOCUMENTED POLICY / SOURCE-CONFIRMED
Evidence locations: manifest; `lib/features/predmeti/pdf/*`
Current implementation state: PDF builders read PREDMET, IRIU, firm, and display snapshots. Snapshot PDF includes legacy `NARUČILAC` labels under a `PLATILAC` section.
Windows/Android parity: Shared source where available.
JSON/PDF/UI relevance: PDF output.
Future Web/sync relevance: Preserve derivative status.
Risk if changed: Document output could diverge from PREDMET.
Open questions: PDF terminology cleanup.
Recommended next action: Separate PDF terminology/compatibility task.

## RULE-ID: OPC-RULE-PARTE-001

Name: Parte and citulje are PREDMET/IRiU derivatives
Status: SOURCE-CONFIRMED / TEST GAP
Domain: Parte / citulje
Rule statement: Parte content derives from PREDMET fields such as symbol, script, display name, ceremony time, and mourners; citulje-related transfer expectations require PREDMET/IRiU source and must not use placeholder narrative as truth.
Evidence classification: SOURCE-CONFIRMED / DOCUMENTED POLICY / TEST GAP
Evidence locations: `lib/features/predmeti/presentation/segments/parte_segment.dart`; `lib/core/utils/json_export_import.dart`
Current implementation state: Source-confirmed UI and JSON source expectations; dedicated tests not found in this audit.
Windows/Android parity: Shared source.
JSON/PDF/UI relevance: UI and JSON transfer metadata.
Future Web/sync relevance: Preserve derivative relationship.
Risk if changed: Public ceremony outputs could diverge from PREDMET.
Open questions: Full parte/citulje rule test coverage.
Recommended next action: Audit and test document-generation rules separately.

## RULE-ID: OPC-RULE-PARITY-001

Name: Windows/Android product parity
Status: DOCUMENTED POLICY / RUNTIME GAP
Domain: Platform parity
Rule statement: Windows and Android are equal runtime forms of the same OPC product logic; differences may only come from platform/UI/file APIs, not business meaning.
Evidence classification: DOCUMENTED POLICY / SOURCE-CONFIRMED / RUNTIME GAP
Evidence locations: manifest; shared `lib/` source; tests
Current implementation state: Most business logic is shared Dart source; some file picker/storage and layout decisions are platform-specific.
Windows/Android parity: Policy required; runtime smoke not run in this task.
JSON/PDF/UI relevance: All user-visible behavior.
Future Web/sync relevance: OPC Web must become another runtime of same logic, not a replacement.
Risk if changed: Platform split and business drift.
Open questions: Runtime parity smoke coverage.
Recommended next action: Add platform parity acceptance checks for implementation tasks.

## RULE-ID: OPC-RULE-WEB-001

Name: Future OPC Web must preserve local ownership and explicit transfer rules
Status: DOCUMENTED POLICY / NOT IMPLEMENTED
Domain: Future Web / sync
Rule statement: OPC Web is a future complementary browser-access runtime. It must not imply server-master PREDMET ownership and must preserve firm ownership, explicit transfer/restore rules, and PREDMET master truth.
Evidence classification: DOCUMENTED POLICY / NOT IMPLEMENTED
Evidence locations: manifest; owner decision report; current development state; stop-list
Current implementation state: No Web runner/backend/API/sync/storage adapter is authorized or implemented by these audits.
Windows/Android parity: Future Web parity requirement.
JSON/PDF/UI relevance: Future architecture only.
Future Web/sync relevance: Primary rule.
Risk if changed: Core OPC product identity drift.
Open questions: Browser storage/local DB/sync architecture.
Recommended next action: Technical architecture audit before implementation.

## Open Inventory Summary

Highest-risk policy-only or partially implemented areas:

- firm-scoped identity and PIB/Maticni broj import/restore guards;
- `FirmaPodaci` history;
- `verzija` future conflict semantics;
- stable user/role identity;
- full backup/restore guard behavior;
- runtime Windows/Android parity evidence;
- finance/PDF/parte/citulje test coverage;
- Web/sync architecture.
