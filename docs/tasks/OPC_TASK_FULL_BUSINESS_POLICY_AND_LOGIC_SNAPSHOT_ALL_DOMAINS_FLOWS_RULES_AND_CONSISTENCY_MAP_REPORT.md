# OPC TASK FULL BUSINESS POLICY AND LOGIC SNAPSHOT - ALL DOMAINS, FLOWS, RULES, AND CONSISTENCY MAP REPORT

Task: OPC FULL BUSINESS POLICY AND LOGIC SNAPSHOT - ALL DOMAINS, FLOWS, RULES, AND CONSISTENCY MAP
Branch: task/OPC-FULL-BUSINESS-POLICY-LOGIC-SNAPSHOT
Base commit: c73f02629816e47d7a5aa62106254a1db15adca4
Report status: PASS WITH OWNER REVIEW QUEUE

## OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: audit / documentation / snapshot
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO
Windows/Android parity affected: NO
Future OPC Web affected: NO
Terminology drift risk: NO - terminology is classified only; no rename performed
Implementation allowed: NO
Required gate before implementation: data ownership / JSON safety / repository identity / platform parity / product terminology / payment/legal where relevant

## Scope Confirmation

This task was audit-only / docs-only / snapshot-only. Source and tests were inspected as evidence only. No implementation was performed.

Forbidden areas remained untouched: source code, database/schema, migrations, Web runner, backend/API, sync, storage, payment/licensing/entitlement implementation, role implementation, UI behavior, PDF behavior, JSON behavior, filename generation, import behavior, change-log behavior, and test behavior.

## Files Inspected

Mandatory docs and task reports:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_EXTRACTION_PREDMET_LIFECYCLE_AND_SAME_PREDMET_CONFLICT_RULES_REPORT.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_PATCH_FIRM_SCOPED_BROJPREDMETA_AND_SINGLE_PREDMET_JSON_FILENAME_SEMANTICS_REPORT.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_EXTRACTION_SINGLE_PREDMET_JSON_IMPORT_FRESHNESS_AND_OVERWRITE_GUARD_REPORT.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_AND_RULE_CONSISTENCY_AUDIT_FULL_PRODUCT_BASELINE_REPORT.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_SEMANTICS_FOR_PREDMET_AND_SINGLE_PREDMET_JSON_IMPORT_REPORT.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_CONFLICT_POLICY_AND_PREDMET_CHANGE_LOG_REQUIREMENT_REPORT.md`

Source/test evidence:

- `lib/core/database/tables/predmeti_table.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`
- `lib/features/predmeti/presentation/segments/narucilac_segment.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/presentation/segments/parte_segment.dart`
- `lib/features/predmeti/presentation/segments/finansije_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/core/database/tables/iriu_table.dart`
- `lib/core/database/tables/kontakt_lica_table.dart`
- `lib/core/database/tables/firma_podaci_table.dart`
- `lib/core/database/tables/korisnici_table.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/data/kontakt_lica_repository.dart`
- `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart`
- `lib/features/predmeti/core_v2/services/financial_truth_service.dart`
- `lib/features/stanje_robe/application/stanje_robe_lifecycle_service.dart`
- `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`
- `lib/features/stanje_robe/data/stanje_robe_repository.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/core/format/app_filename_format.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/domain/session_service.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/features/podesavanja/presentation/podesavanja_screen.dart`
- `lib/features/predmeti/pdf/*`
- `test/json_transfer_regression_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/business_policy_iriu_critical_scenarios_test.dart`
- `test/opc_local_license_parser_test.dart`
- `test/package_downgrade_migration_test.dart`
- `test/podesavanja_screen_smoke_test.dart`
- `test/login_screen_smoke_test.dart`
- `test/lista_predmeta_screen_smoke_test.dart`

## Files Changed

- `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md`
- `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/tasks/OPC_TASK_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT_ALL_DOMAINS_FLOWS_RULES_AND_CONSISTENCY_MAP_REPORT.md`

## Source/Test Inspection Summary

Inspection built a source/test map around PREDMET table/repository, PREDMET UI segments, IRIU services, STANJE ROBE lifecycle, JSON transfer, PDF builders, auth/users, FirmaPodaci, entitlement policy, and the current test suite.

The snapshot separates documented policy from source-confirmed implementation and test-confirmed behavior. It does not treat prior reports alone as source proof.

## Main Snapshot Created

Created: `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md`

Content includes purpose/scope, evidence legend, product summary, master truth model, domain inventory, domain-by-domain business logic, future Web/sync preservation map, consistency findings, contradictions/gaps, policy-only rules, source-confirmed rules, test-confirmed rules, runtime gaps, owner-decision gaps, technical audit queue, stop-list summary, and recommended next task.

## Domain/Flow Map Created

Created: `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`

Content includes domain list, ownership, inputs, outputs, dependencies, source modules, tests, document/PDF/JSON effects, Web/sync sensitivity, and text flow diagrams for PREDMET creation, review/confirmation, JSON export, JSON import, replace, backup/restore, stock consequence flow, and future version/change-log flow.

## Rule Inventory Updates

No new rule IDs were added. Existing rule inventory already contains the relevant baseline rules. This task created a higher-level atlas and flow map instead of duplicating rule IDs.

## Full Domain Coverage Checklist

| Required domain | Covered |
| --- | --- |
| PREDMET core | YES |
| Deceased person data | YES |
| Platilac / legacy narucilac | YES |
| JKP and payment-party logic | YES |
| Ceremony data | YES |
| Religious, symbolic, and document-display logic | YES |
| PIO / refund / pensioner logic | YES |
| Financial fields and payment logic | YES |
| IRIU / articles / services | YES |
| STANJE ROBE / stock consequences | YES |
| Parte | YES |
| Citulje | YES, with audit gap |
| Contacts / kontakt lica | YES |
| Users / advisers / administrators | YES |
| Firma / FirmaPodaci | YES |
| Packages / licensing / paid options | YES |
| JSON transfer | YES |
| Backup / restore | YES |
| PDF/document output | YES |
| Windows / Android parity | YES |
| Future OPC Web / sync-sensitive areas | YES |

## Evidence Classification Summary

- `DOCUMENTED POLICY`: manifest, locked rules, source-of-truth map, owner report.
- `OWNER DECISION`: firm scope, Web boundary, version policy, package terms, import/restore guard requirement.
- `SOURCE-CONFIRMED`: PREDMET table/repository, IRIU, contacts, JSON, PDFs, auth, entitlement, FirmaPodaci.
- `TEST-CONFIRMED`: JSON transfer/regression, STANJE ROBE, IRIU critical scenarios, licensing/package tests, smoke tests.
- `POLICY EXISTS / IMPLEMENTATION NOT FOUND`: PIB/MB mismatch guard, firm-scoped import conflict identity, version comparator/hard-block behavior.
- `TECHNICAL AUDIT REQUIRED`: FirmaPodaci history, stable user identity, version/change-log source, Web/sync architecture, citulje full rules.
- `TEST GAP`: finance, PDFs, parte/citulje, full PREDMET lifecycle UI.
- `RUNTIME GAP`: Windows/Android runtime parity smoke not run in this task.

## Consistency Summary

The public baseline is consistent on core OPC identity: PREDMET is master truth, Windows/Android parity is required, OPC Web is future complementary access, and server-master drift is forbidden.

Source structure supports a PREDMET-centered local product. JSON and PDF are derivative/transfer layers. STANJE ROBE is consequence logic, not a second master truth.

## Major Contradictions/Gaps

No new contradiction was introduced or resolved. Existing gaps remain:

- firm-scoped identity is policy but current conflict lookup is `brojPredmeta` only;
- PIB/MB mismatch block is policy but not source-confirmed;
- FirmaPodaci is editable/hybrid and lacks history model;
- Platilac visible term and internal narucilac names remain mixed;
- PREDMET change-log overview is required but not implemented;
- runtime Windows/Android parity was not freshly smoke-tested.

## Policy-Only Rule Summary

- Future OPC Web is not a server-master PREDMET database.
- Firm-scoped PREDMET identity is `PIB + Matični broj + brojPredmeta`.
- `exportDatum` is metadata only.
- Version conflict matrix preserves keep / replace / cancel.
- PREDMET version/change-log overview belongs in future `Pregled i potvrda`.
- PIB/MB import/restore mismatch must block.

## Source-Confirmed Rule Summary

- PREDMET stores the central case model.
- PREDMET repository implements create/save/close/reopen/finish/anonymize/delete/import/replace.
- IRIU and contacts are PREDMET child data.
- JSON transfer includes single-PREDMET and full backup formats.
- PDFs derive from PREDMET/IRiU/firma/user data.
- Entitlement policy controls modules/actions and fails closed.

## Test-Confirmed Rule Summary

- JSON transfer and replacement behavior: `test/json_transfer_regression_test.dart`
- STANJE ROBE operational/consequence behavior: `test/stanje_robe_operational_toggle_test.dart`
- IRIU critical business policy: `test/business_policy_iriu_critical_scenarios_test.dart`
- Licensing/package behavior: `test/opc_local_license_parser_test.dart`; `test/package_downgrade_migration_test.dart`
- Smoke coverage: login, settings, PREDMET list tests.

## Runtime Gaps

- No fresh Windows smoke.
- No fresh Android smoke.
- No fresh PDF render check.
- No full UI lifecycle runtime pass.

## Owner Decisions Still Required

- final cleanup strategy for internal `narucilac` / visible `Platilac`;
- duplicate UI-created `brojPredmeta` policy;
- exact version warning wording and whether future hard-blocks are ever desired;
- exact change-log content, source, retention, and display density;
- owner-approved Web/sync architecture when that task begins.

## Technical Audits Still Required

- firm identity metadata and PIB/MB guard design;
- FirmaPodaci history;
- stable Administrator/Savetnik identity;
- PREDMET version increment/survival audit;
- `Pregled i potvrda` suitability for version/change-log overview;
- finance/PDF/parte/citulje test expansion;
- Windows/Android runtime parity smoke.

## Implementation Stop-List Confirmation

Still blocked: Web runner, backend/API, sync, browser storage, DB migrations, import/restore guard implementation, firm-scoped identity constraint, version comparator/hard-block logic, change-log DB/UI, JSON schema changes, filename-generation changes, payment/subscription/licensing implementation, role architecture, and source/database/PDF/JSON terminology renames.

## Recommended Next Task

Recommended next task: `OPC TECHNICAL AUDIT - FIRM IDENTITY GUARD AND JSON/BACKUP RESTORE IMPLEMENTATION GAP`.

Reason: owner policy requires firm-scoped identity and PIB/MB mismatch blocking, but current public evidence does not prove implementation. This is the highest-risk prerequisite before Web/sync, stronger transfer rules, or version comparator implementation.

## Validation Results

Command:

- `python scripts\validate_opc_manifest_gate.py --base c73f02629816e47d7a5aa62106254a1db15adca4`

Result:

- PASS - OPC manifest gate passed for 1 changed task report: `docs/tasks/OPC_TASK_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT_ALL_DOMAINS_FLOWS_RULES_AND_CONSISTENCY_MAP_REPORT.md`

## Final Status

PASS WITH OWNER REVIEW QUEUE

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES
Core purpose preserved: YES
PREDMET meaning preserved: YES
Database ownership preserved: YES
Windows/Android parity preserved: YES
Existing JSON transfer preserved: YES
Terminology preserved: YES
Future Web Pristup not blocked: YES
Source changes within scope: YES - no source changes; documentation only
If not compliant, classify: N/A
PASS / NOT PASS: PASS WITH OWNER REVIEW QUEUE
