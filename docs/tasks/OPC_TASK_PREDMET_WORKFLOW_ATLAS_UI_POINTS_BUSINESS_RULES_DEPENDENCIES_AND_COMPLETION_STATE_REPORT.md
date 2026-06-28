# OPC TASK PREDMET WORKFLOW ATLAS - UI POINTS, BUSINESS RULES, DEPENDENCIES, AND COMPLETION STATE REPORT

Task: OPC PREDMET WORKFLOW ATLAS - UI POINTS, BUSINESS RULES, DEPENDENCIES, AND COMPLETION STATE
Branch: task/OPC-PREDMET-WORKFLOW-ATLAS
Base commit: 5347d64dcc8197d17000417d069289468e547dd1
Report status: PASS WITH OWNER REVIEW QUEUE

## OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: audit / documentation / workflow-atlas
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO
Windows/Android parity affected: NO
Future OPC Web affected: NO
Terminology drift risk: NO - current terminology was classified only; no rename performed
Implementation allowed: NO
Required gate before implementation: data ownership / JSON safety / repository identity / platform parity / product terminology / source-of-truth

## Scope Confirmation

This task was audit-only / docs-only / workflow-atlas-only. Source and tests were inspected as evidence only.

No source code, database/schema, migrations, Web runner, backend/API, sync, storage, payment/licensing/entitlement implementation, role implementation, UI behavior, PDF behavior, JSON behavior, filename generation, import behavior, backup/restore behavior, change-log behavior, or test behavior was changed.

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
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md`
- `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- `docs/tasks/OPC_TASK_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT_ALL_DOMAINS_FLOWS_RULES_AND_CONSISTENCY_MAP_REPORT.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_VERSION_CONFLICT_POLICY_AND_PREDMET_CHANGE_LOG_REQUIREMENT_REPORT.md`

Source/test evidence:

- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`
- `lib/features/predmeti/presentation/segments/narucilac_segment.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/presentation/segments/parte_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/presentation/segments/finansije_segment.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/data/kontakt_lica_repository.dart`
- `lib/core/database/tables/predmeti_table.dart`
- `lib/core/database/tables/iriu_table.dart`
- `lib/core/database/tables/kontakt_lica_table.dart`
- `lib/core/database/tables/log_izmena_table.dart`
- `lib/core/database/tables/firma_podaci_table.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart`
- `lib/features/predmeti/core_v2/services/financial_truth_service.dart`
- `lib/features/stanje_robe/application/stanje_robe_lifecycle_service.dart`
- `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`
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

- `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`
- `docs/OPC_PREDMET_DEPENDENCY_MAP.md`
- `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/tasks/OPC_TASK_PREDMET_WORKFLOW_ATLAS_UI_POINTS_BUSINESS_RULES_DEPENDENCIES_AND_COMPLETION_STATE_REPORT.md`

## PREDMET UI / Source Structure Found

Actual PREDMET navigation is defined in `lib/features/predmeti/presentation/predmet_screen.dart` by `_PredmetLogicalSection` and `_predmetSectionInfos`.

The source-confirmed PREDMET points are:

1. `Preminulo lice`
2. `Činjenice o smrti`
3. `Statusi`
4. `Platilac`
5. `Ceremonija`
6. `Parte`
7. `Roba i usluge`
8. `Finansije`
9. `Dokumenti`
10. `Pregled i potvrda`

Additional workflow relations documented:

- PREDMET opening/basic metadata from `ListaPredmetaScreen` and `PredmetiRepository.kreirajPredmet`;
- import/replace relation from single-PREDMET JSON flow;
- lifecycle actions save/close/reopen/anonymize/delete.

## PREDMET Points Identified

Each actual source point was documented with business purpose, user action, business-driving fields, derived fields, dependencies, outputs, evidence, completion state, gaps, owner decisions, and future Web/sync relevance.

## Workflow Atlas Created

Created: `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`

It reconstructs the user/business journey inside one PREDMET and contains structured `POINT-ID` entries.

## Dependency Map Created

Created: `docs/OPC_PREDMET_DEPENDENCY_MAP.md`

It maps source point, source field/choice, dependency type, target point/output, rule, evidence, and classification.

## Completion-State Matrix Created

Created: `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md`

It answers what is implemented, partially implemented, policy-only, not implemented, test-confirmed, runtime gap, technical-audit required, and owner-decision required.

## Source/Test Evidence Summary

Source-confirmed:

- actual PREDMET sections and navigation;
- PREDMET creation, save, close, reopen, delete, anonymize;
- PREDMET table fields;
- point widgets for deceased data, payer, ceremony, parte, IRiU, finance;
- document and JSON action section;
- review section;
- IRiU/STANJE ROBE/finance dependencies.

Test-confirmed:

- JSON transfer/replacement behavior;
- STANJE ROBE consequence behavior;
- IRiU business-policy scenarios;
- entitlement/license/package behavior;
- selected smoke tests.

Runtime gap:

- no fresh Windows/Android runtime workflow was run in this docs-only task.

## What The Previous Full Snapshot Missed

The previous full snapshot described domains and flows at product level. It did not provide a point-by-point user workflow for actual PREDMET UI sections, did not classify each PREDMET point, and did not show dependencies in the requested source-field to target-output format.

## What This Task Adds

- Actual PREDMET UI points from source.
- Workflow atlas from user/business perspective.
- Cross-point dependency map.
- Completion-state matrix answering what is achieved and what is waiting.
- Source/test evidence paths for each major point.

## Major Unresolved Gaps

- Full PREDMET workflow runtime smoke remains a runtime gap.
- Finance/PDF/parte/čitulje tests are incomplete or absent.
- PREDMET version/change-log overview is still not implemented.
- Duplicate `brojPredmeta` creation behavior requires owner/technical audit.
- Platilac/internal narucilac cleanup remains owner-review material.

## Known Technical Gaps Recorded But Not Centered

The following were recorded as dependencies/risks only, not made the center of this task:

- firm identity guard;
- JSON import identity gap;
- backup/restore mismatch guard;
- PIB / Matični broj guard;
- FirmaPodaci history;
- future Web/sync risks.

The center of this task remained the PREDMET workflow from the user/business perspective.

## Implementation Stop-List Confirmation

No implementation was performed. Still blocked without separate explicit tasks and gates:

- Web runner/backend/API/sync/storage;
- database/schema/migrations;
- JSON/import/export/backup/restore behavior changes;
- filename generation changes;
- UI/PDF behavior changes;
- payment/licensing/entitlement implementation;
- role implementation;
- version comparator/hard-block behavior;
- change-log DB/model/UI;
- terminology renames across source/database/PDF/JSON.

## Validation Results

Command:

- `python scripts\validate_opc_manifest_gate.py --base 5347d64dcc8197d17000417d069289468e547dd1`

Result:

- PASS - OPC manifest gate passed for 1 changed task report: `docs/tasks/OPC_TASK_PREDMET_WORKFLOW_ATLAS_UI_POINTS_BUSINESS_RULES_DEPENDENCIES_AND_COMPLETION_STATE_REPORT.md`

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
