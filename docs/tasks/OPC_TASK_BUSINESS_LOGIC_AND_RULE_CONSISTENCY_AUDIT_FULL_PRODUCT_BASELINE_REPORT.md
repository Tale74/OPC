# OPC TASK BUSINESS LOGIC AND RULE CONSISTENCY AUDIT - FULL PRODUCT BASELINE REPORT

Task: OPC BUSINESS LOGIC AND RULE CONSISTENCY AUDIT - FULL PRODUCT BASELINE

OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: audit-only / documentation / business logic extraction
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO - source/test read only, no behavior changed
Windows/Android parity affected: NO
Future OPC Web affected: NO
Terminology drift risk: NO - terminology documented only, no rename
Implementation allowed: NO
Required gate before implementation: data ownership / JSON safety / repository identity / platform parity / source-of-truth / payment-access

## Baseline

| Field | Value |
| --- | --- |
| Branch | `task/OPC-BUSINESS-LOGIC-RULE-CONSISTENCY-FULL-AUDIT` |
| Base commit | `a864e11fd71af539f8bf7c892c42e3717ab67293` |
| Verified previous task | `OPC BUSINESS LOGIC EXTRACTION - SINGLE-PREDMET JSON IMPORT FRESHNESS AND OVERWRITE GUARD` |
| Final commit | Recorded in final GitHub handoff after commit creation. |

## Scope Confirmation

This task was audit-only/docs-only. Source and tests were read as evidence only. No source code, database/schema, migrations, Web runner, backend/API, sync, storage, payment/licensing/entitlement behavior, role behavior, UI, PDF, JSON behavior, filename generation, or test behavior was changed.

## Files Inspected

Mandatory docs:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- prior task reports named by the task

Source/test evidence:

- `lib/core/database/tables/predmeti_table.dart`
- `lib/core/database/tables/firma_podaci_table.dart`
- `lib/core/database/tables/korisnici_table.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/core/format/app_filename_format.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/domain/session_service.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/core_v2/business_policy/*`
- `lib/features/predmeti/core_v2/services/*`
- `lib/features/predmeti/presentation/segments/*`
- `lib/features/predmeti/pdf/*`
- `lib/features/stanje_robe/application/*`
- `test/json_transfer_regression_test.dart`
- `test/business_policy_iriu_critical_scenarios_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/opc_local_license_parser_test.dart`
- `test/package_downgrade_migration_test.dart`
- smoke tests under `test/`

## Files Changed

- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_AND_RULE_CONSISTENCY_AUDIT_FULL_PRODUCT_BASELINE_REPORT.md`

## Business Domain Inventory

| Domain | Current rule state | Classification |
| --- | --- | --- |
| PREDMET | Central master truth; lifecycle and connected-data behavior source-confirmed. | DOCUMENTED POLICY / SOURCE-CONFIRMED |
| Deceased person data | Stored on PREDMET; UI requires at least name or surname before close paths. | SOURCE-CONFIRMED |
| Platilac / narucilac | Visible Platilac with internal legacy narucilac/naru fields. | PARTIALLY IMPLEMENTED / OWNER REVIEW REQUIRED |
| JKP/payment party data | Separate JKP payer block plus option to reuse Platilac data. | SOURCE-CONFIRMED |
| Ceremony / cemetery | PREDMET carries ceremony, cemetery, grave/urn, service and location fields. | SOURCE-CONFIRMED |
| Religious/ceremony options | Parte symbol/script and ceremony options are PREDMET fields. | SOURCE-CONFIRMED / TEST GAP |
| PIO/refund/posmrtna pomoc | UI/PDF calculate refund/payment display from PREDMET and settings. | SOURCE-CONFIRMED / TEST GAP |
| IRIU / articles/services | Initial rows, catalog snapshots, business policy and lifecycle services exist. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Price/cost/discount/payment | Finance segment and PDFs use PREDMET/IRiU values. | SOURCE-CONFIRMED / TEST GAP |
| STANJE ROBE | Licensed/operational consequence layer with covered categories. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Parte | Derived from PREDMET data. | SOURCE-CONFIRMED / TEST GAP |
| Citulje | JSON expectations tie them to PREDMET/IRiU source. | DOCUMENTED POLICY / SOURCE-CONFIRMED |
| Contacts | Imported/exported and replaced with PREDMET. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Logs/lifecycle decisions | Save/close writes logs; replacement/delete removes related logs/decisions. | SOURCE-CONFIRMED |
| Users/roles | Local ADMINISTRATOR/SAVETNIK with PIN and admin safeguards. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| FirmaPodaci | Singleton editable firm data with PIB/MB fields. | SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED |
| Import/export/backup/restore | Single-PREDMET and full backup are separate flows; identity guard incomplete. | PARTIALLY IMPLEMENTED |
| PDF generation | PREDMET-derived documents; terminology mixed in snapshot path. | SOURCE-CONFIRMED / OWNER REVIEW REQUIRED |
| Package/licensing | Entitlement policy and fail-closed tests exist; payment implementation blocked. | PARTIALLY IMPLEMENTED |
| Windows/Android parity | Shared Dart business logic; runtime smoke not run. | DOCUMENTED POLICY / RUNTIME GAP |
| Future Web/sync | Policy only; no implementation authorized. | NOT IMPLEMENTED |

## Business Rule Inventory Summary

Dedicated rule inventory created at:

`docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`

It includes stable IDs for PREDMET truth, lifecycle/versioning, import choice, filename UX, `exportDatum`, `verzija`, firm identity, Platilac/narucilac, JSON transfer, backup/restore, STANJE ROBE, IRIU, finance, users/roles, packages, PDFs, parte/citulje, parity, and future Web/sync.

## Rule Evidence Classification Summary

| Classification | Summary |
| --- | --- |
| DOCUMENTED POLICY | PREDMET truth, database ownership, Web boundary, parity, transfer boundaries. |
| OWNER DECISION | firm-scoped `brojPredmeta`, packages, `exportDatum` metadata-only, `verzija` intended future version signal. |
| OWNER CLARIFICATION | keep/replace/cancel is intentional; filename `Ime_Prezime`/`PREZIME_IME` is UX only; Platilac change-of-mind rationale. |
| SOURCE-CONFIRMED | lifecycle, import conflict UI, repository replacement, firm/user tables, entitlement policy, finance/PDF/IRiU/STANJE ROBE source paths. |
| TEST-CONFIRMED | JSON transfer/regression, STANJE ROBE operational behavior, entitlement/license fail-closed behavior, IRIU critical scenarios. |
| POLICY EXISTS / IMPLEMENTATION NOT FOUND | PIB/Maticni broj import/restore guard; firm-scoped conflict identity; Web/sync architecture. |
| TEST GAP | full lifecycle state machine, finance calculations, PDF/parte/citulje rules, runtime import dialog parity. |
| RUNTIME GAP | fresh Windows/Android smoke not run in this docs-only audit. |

## Consistency Matrix

| Area | Result | Notes |
| --- | --- | --- |
| Docs vs source: PREDMET truth | CONSISTENT | Source is organized around `predmeti` and derived layers. |
| Docs vs source: firm identity guard | POLICY EXISTS / IMPLEMENTATION NOT FOUND | Firm fields exist; guard not confirmed. |
| Source vs tests: JSON transfer | CONSISTENT | JSON regression tests cover serialization/import/replacement and stock consequence transfer. |
| Source vs tests: lifecycle | PARTIALLY CONSISTENT / TEST GAP | Source-confirmed lifecycle; no full lifecycle state-machine test found. |
| UI/PDF terminology vs internal code | PARTIALLY CONSISTENT | Visible Platilac, internal narucilac/naru compatibility remains. |
| JSON field names vs terminology | PARTIALLY CONSISTENT | JSON exports internal fields; no rename authorized. |
| Import/export vs backup/restore policy | PARTIALLY CONSISTENT | Distinction exists; mismatch guard policy not implemented. |
| PREDMET truth vs connected data | CONSISTENT | Replacement/delete reconcile related rows and stock consequences. |
| Package policy vs implementation | PARTIALLY CONSISTENT | Entitlement policy exists; payment/subscription not implemented. |
| Role policy vs implementation | PARTIALLY CONSISTENT | Local roles exist; stable firm/license roles not implemented. |
| Web assumptions vs local ownership | CONSISTENT AS POLICY | No Web implementation was found/authorized. |
| Import user choice vs freshness assumptions | PARTIALLY CONSISTENT | Explicit choice is source-confirmed and now owner-clarified; automatic freshness guard not found. |
| `verzija` decision vs code/test evidence | PARTIALLY CONSISTENT | Field exists and is used/displayed, but not compared for import decisions. |

## Terminology Consistency Findings

| Term | Finding | Classification |
| --- | --- | --- |
| `PREDMET` | Consistent as central entity. | DOCUMENTED POLICY / SOURCE-CONFIRMED |
| `Platilac` | Current visible UI/PDF display term. | SOURCE-CONFIRMED |
| `narucilac` / `naru*` | Internal code/database/JSON/template terminology remains. | SOURCE-CONFIRMED / OWNER REVIEW REQUIRED |
| `klijent` | Not canonical for PREDMET party. | DOCUMENTED POLICY |
| `FirmaPodaci` | Existing editable firm data, not stable identity alone. | SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED |
| `Administrator` / `Savetnik` | Local roles exist; future stable identity unresolved. | SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED |
| `OPC Web` | Canonical future term. | OWNER DECISION |
| `SaaS` / `saas` | Not primary product terminology; `saas` appears as internal entitlement source placeholder. | DOCUMENTED POLICY / CLEANUP CANDIDATE |
| `Osnovni`, `Srednji`, `Potpuni` | Package terms exist in policy and entitlement model. | OWNER DECISION / SOURCE-CONFIRMED |
| `verzija` | Business version field, owner-relevant for future reasoning. | OWNER DECISION / SOURCE-CONFIRMED |
| `exportDatum` | Export time metadata, not freshness authority. | OWNER DECISION / SOURCE-CONFIRMED |

## PREDMET Rule Consistency Findings

- Creation: source-confirmed, generated `brojPredmeta`, default `OTVOREN`, default `verzija = 1`, creator/adviser metadata.
- Save: source-confirmed working-state snapshot; UI text says business version forms on close.
- Close: source-confirmed `ZATVOREN`; increments `verzija` only when appropriate business change is detected.
- Reopen: source-confirmed; opens for edit without automatic new version.
- Auto-finish/anonymize/delete: source-confirmed; broader tests remain incomplete.
- Same `brojPredmeta`: current import conflict key is trimmed `brojPredmeta`; owner policy says future identity must be firm-scoped.
- Replacement: source/test-confirmed local technical id stays and imported business/related rows replace local rows.
- Logs/lifecycle decisions: source-confirmed replacement/delete removes known related rows.
- STANJE ROBE: source/test-confirmed reconciliation/consequence behavior around replacement.

## Single-PREDMET JSON / Import / Version Findings

| Topic | Finding | Classification |
| --- | --- | --- |
| Entry point | `uveziPredmetIzJson` delegates to shared import file flow. | SOURCE-CONFIRMED |
| Conflict key | Trimmed non-empty `predmet.brojPredmeta`. | SOURCE-CONFIRMED |
| Keep/replace/cancel | Explicit user choice is intentional business behavior, not a defect. | OWNER CLARIFICATION / SOURCE-CONFIRMED |
| Multiple local matches | Blocks replacement as unsafe. | SOURCE-CONFIRMED |
| `verzija` | Exported/imported/displayed; not compared for conflict. | SOURCE-CONFIRMED / NOT IMPLEMENTED |
| `exportDatum` | Generated at export; not compared; not authority. | OWNER DECISION / SOURCE-CONFIRMED |
| Filename | Human-readable recognition aid only. | OWNER CLARIFICATION / SOURCE-CONFIRMED |
| Automatic freshness block | Not found in inspected import path. | POLICY/OWNER-REPORTED GAP |

## Keep / Replace / Cancel Owner-Intent Finding

Finding: keep / replace / cancel during same-`brojPredmeta` single-PREDMET JSON import is intentional owner-approved business behavior.

Classification: OWNER CLARIFICATION / SOURCE-CONFIRMED.

Reason: business truth may depend on a later human/business decision, including a `Platilac` change of mind. This audit does not recommend removing explicit user choice. Future warnings or version checks must preserve owner-approved human arbitration unless a later owner decision changes it.

## Platilac Change-Of-Mind Business Rationale

Finding: same deceased person / same `brojPredmeta` does not guarantee that the newest exported file is automatically the correct business truth. `Platilac` may change decisions, and the local user must retain controlled choice.

Classification: OWNER CLARIFICATION.

## `Ime_Prezime` Filename UX Finding

Finding: `Ime_Prezime` / `PREZIME_IME` in exported filenames is a user recognition aid. It is not identity, freshness, or conflict authority.

Classification: OWNER CLARIFICATION / SOURCE-CONFIRMED.

## `exportDatum` Finding

Finding: `exportDatum` is generated during JSON export and records export time. It is not business freshness authority and must not be used as proof that exported content is newer or more correct.

Classification: OWNER DECISION / SOURCE-CONFIRMED.

## `verzija` Finding

Finding: `verzija` is defined on PREDMET, defaults to 1, is incremented on confirmed close with business change, is exported/imported, appears in conflict UI and PDFs, and is intended by owner as the relevant future version reasoning signal. It is not currently compared in the inspected import conflict flow and is not yet proven sufficient for future overwrite/version decisions.

Classification: OWNER DECISION / SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED.

## Firma / Identity Findings

- `FirmaPodaci` contains `pib` and `mb` fields and is a singleton editable table.
- Full backup includes `firmaPodaci`.
- Current public policy says PIB/Maticni broj mismatch must block restore/import.
- No source-confirmed single-PREDMET firm identity guard was found.
- Current single-PREDMET same-case conflict lookup uses `brojPredmeta` only.
- Future-safe identity `PIB + Maticni broj + brojPredmeta` remains policy/owner decision, not implementation-confirmed.

## Role / User Findings

- Local users exist with `ADMINISTRATOR` and `SAVETNIK`.
- First launch creates first admin.
- PIN login, PIN reset, forced PIN change, active/inactive users, and last-active-admin safeguards exist.
- PREDMET stores `savetnikId`, `createdByKorisnikId`, and `lastBusinessModifiedByKorisnikId`.
- Stable cross-device/user/license identity is not implemented.

## Package / Licensing Findings

- `OpcPackageLevel` has `osnovni`, `srednji`, `potpun`.
- Entitlement source and policy fail closed for unsupported/unsafe sources.
- Core PREDMET modules stay available; optional modules are gated by package/add-ons.
- Tests cover license parser and package downgrade compatibility.
- Payment/subscription implementation remains blocked.

## Import / Export / Backup / Restore Findings

- Single-PREDMET JSON and full backup JSON are separate.
- Single-PREDMET JSON includes `predmet`, `iriu`, `kontaktLica`, and approved unresolved stock consequence transfer block when applicable.
- Full backup includes broader database sections and destructive import confirmation.
- Schema version guard exists.
- Firm mismatch guard is policy-only in this audit.
- Filename is export UX only.
- `exportVerzija` increments on export and is separate from business `verzija`.

## Windows / Android Parity Findings

- Most audited business logic is shared Dart source under `lib/`.
- File picking/storage and dialog layout contain platform-specific adapters.
- Tests exercise shared Dart behavior, not separate Windows/Android runtime smoke.
- Runtime parity remains a gap for user-facing import dialogs and end-to-end workflows.

## Future Web / Sync Risk Map

| Risk area | Why critical |
| --- | --- |
| PREDMET identity | Web/sync must not confuse local id, `brojPredmeta`, filename, or firm-scoped identity. |
| Firm identity | PIB/Maticni broj guard and `FirmaPodaci` history must exist before trust decisions. |
| Local ownership | Server must not become implicit master database. |
| Conflict resolution | Keep/replace/cancel and human choice must survive where business truth requires it. |
| Versioning | `verzija` needs formal semantics before merge/overwrite logic. |
| `exportDatum` | Must remain metadata only. |
| Offline/local replica | Needs explicit equality/replacement rules. |
| Packages/roles | Must not change PREDMET truth or database ownership. |
| Connected replacement | IRIU/contact/log/lifecycle/STANJE ROBE side effects must be preserved or redesigned deliberately. |
| JSON compatibility | Single-PREDMET and full backup boundaries must remain distinct. |

## Contradictions Found

No blocking contradiction was found between the current public manifest and source evidence. Main inconsistencies are controlled gaps:

- policy requires firm identity guards, implementation not found;
- owner-reported older/newer automatic protection not source-confirmed;
- visible `Platilac` and internal `narucilac` terminology remain mixed by compatibility;
- `saas` exists as internal entitlement source kind while SaaS is not primary product terminology.

## Policy-Only Rules Not Implemented

- PIB/Maticni broj mismatch block for import/restore.
- Firm-scoped `PIB + Maticni broj + brojPredmeta` conflict identity.
- `FirmaPodaci` stable identity/history.
- Future Web/sync architecture.
- Payment/subscription implementation.
- Stable cross-device Administrator/Savetnik identity.

## Implementation-Only Rules Not Fully Documented

- Full finance calculation details.
- Detailed IRIU business policy condition matrix.
- STANJE ROBE lifecycle outcome matrix.
- Auth recovery/PIN security workflow.
- PDF snapshot field/label compatibility.

## Test Gaps

- Full PREDMET lifecycle state machine.
- Finance calculations and payment method semantics.
- PDF label/content regression.
- Parte/citulje rendering and data derivation.
- Firm identity import/restore guard once designed.
- Version conflict semantics once designed.

## Runtime Gaps

- Windows runtime smoke for import conflict dialog.
- Android runtime smoke for import conflict dialog.
- Platform end-to-end parity around file pick/import/export.
- Runtime confirmation of PDF/document output on supported platforms.

## Owner Decisions Required

- Final `verzija` conflict rules: compare direction, tie behavior, missing/malformed handling.
- Whether single-PREDMET JSON must include firm identity metadata.
- Final cleanup path for `Platilac`/`narucilac`.
- `FirmaPodaci` history model.
- Web/sync storage and replica architecture.
- Package/payment commercial rules.

## Technical Audits Required

- Repository/firma identity and import/restore guard design.
- `verzija` semantics and tests.
- `FirmaPodaci` history and migration plan.
- Stable user/role identity.
- Full backup/restore stock and destructive import safety.
- Finance/PDF/parte/citulje rule extraction.
- OPC Web local data architecture.

## Implementation Stop-List Confirmation

No implementation was performed. The following remain blocked: source changes, database migrations, firm identity guards, JSON schema/behavior changes, filename generation changes, Web runner, backend/API, sync, storage adapter, payment/licensing/subscription, role architecture, UI/PDF changes, package restructuring, and test behavior changes.

## Validation Results

| Check | Result |
| --- | --- |
| Docs-only diff | PASS - changed files are under `docs/` only. |
| Manifest gate | PASS - `python scripts\validate_opc_manifest_gate.py --base a864e11fd71af539f8bf7c892c42e3717ab67293`. |
| Source code untouched | PASS - source/tests were read only. |
| Flutter analyze/test/build | Not run; docs-only audit. |

## Final Status

PASS WITH OWNER REVIEW QUEUE

OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES
Core purpose preserved: YES
PREDMET meaning preserved: YES
Database ownership preserved: YES
Windows/Android parity preserved: YES
Existing JSON transfer preserved: YES
Terminology preserved: YES
Future Web Pristup not blocked: YES
Source changes within scope: YES - documentation only
PASS / NOT PASS: PASS WITH OWNER REVIEW QUEUE
