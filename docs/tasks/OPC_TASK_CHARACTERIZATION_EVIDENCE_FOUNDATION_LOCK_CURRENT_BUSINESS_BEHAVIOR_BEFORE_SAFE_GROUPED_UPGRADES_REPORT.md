# OPC Task Report - Characterization Evidence Foundation

## OPC MANIFEST CHECK — TASK START

Manifest read: REQUIRED and completed.

Manifest compliance checked: REQUIRED and completed.

PASS / NOT PASS: `PASS`

## 2. Task Metadata

Task name: `OPC CHARACTERIZATION EVIDENCE FOUNDATION - LOCK CURRENT BUSINESS BEHAVIOR BEFORE SAFE GROUPED UPGRADES`

Task type: docs-only / audit-only / evidence-mapping-only.

Branch: `task/OPC-CHARACTERIZATION-EVIDENCE-FOUNDATION`

Date: 2026-06-30

## 3. Baseline Branch/Commit

Baseline branch: `task/OPC-MODULAR-FOUNDATION-CONTROL-PLAN`

Base commit: `0f82e144a16bd40e1482fd67dd2346233991a623`

Working tree at task start: clean.

## 4. Manifest Start Confirmation

Required manifest, workflow, and task template files were present and read:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`

Legacy `PROJECT_DOCS` files were present and read as supporting/historical context.

## 5. Scope Confirmation

Scope was docs-only / audit-only / evidence-mapping-only.

No source code, tests, database/schema, migrations, UI, PDF, JSON behavior, import/export behavior, backup/restore behavior, evaluator behavior, IRiU behavior, STANJE ROBE behavior, finance behavior, entitlement/licensing behavior, Web/backend/API/sync/storage/payment/role implementation, bug fixes, formatting fixes, refactors, cleanup, or runtime behavior changes were made.

## 6. Files Inspected

Required public docs inspected:

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
- `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`
- `docs/OPC_PREDMET_DEPENDENCY_MAP.md`
- `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md`
- `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`
- `docs/OPC_BUSINESS_POLICY_SCENARIO_MATRIX.md`
- `docs/OPC_BUSINESS_POLICY_CONSEQUENCE_GRAPH.md`
- `docs/OPC_BUSINESS_POLICY_EVALUATOR_COMPLETION_MATRIX.md`
- `docs/OPC_LOGOS_KNOWLEDGE_BASE.md`
- `docs/OPC_MODULE_RELATIONSHIP_MAP.md`
- `docs/OPC_SOURCE_LEARNING_INDEX_FOR_LOGOS.md`
- `docs/OPC_CHILD_ILLNESS_AND_SAFE_UPGRADE_CANDIDATE_REGISTER.md`
- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`
- `docs/OPC_MODULAR_FOUNDATION_CONTROL_PLAN.md`
- `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md`
- `docs/OPC_WEB_READINESS_GUARDRAILS.md`
- `docs/OPC_GROUPED_SAFE_UPGRADE_PLAN.md`
- `docs/tasks/OPC_TASK_MODULAR_FOUNDATION_CONTROL_PLAN_PREDMET_CORE_MODULE_CONTRACTS_SAFE_UPGRADE_GROUPS_AND_WEB_READINESS_GUARDRAILS_REPORT.md`

Legacy/supporting docs inspected:

- `PROJECT_DOCS/00_README_KAKO_KORISTITI.md`
- `PROJECT_DOCS/OPC_v1_PROJECT_SOUL.md`
- `PROJECT_DOCS/OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`
- `PROJECT_DOCS/OPC_v1_CODEX_RULES.md`
- `PROJECT_DOCS/OPC_v1_AUDIT_SUMMARY.md`
- `PROJECT_DOCS/PROJECT_MAP_OPC_v1_SUMMARY.md`

Existing test names inspected without running or editing tests:

- `test/business_policy_iriu_critical_scenarios_test.dart`
- `test/json_transfer_regression_test.dart`
- `test/lista_predmeta_screen_smoke_test.dart`
- `test/login_screen_smoke_test.dart`
- `test/opc_local_license_parser_test.dart`
- `test/package_downgrade_migration_test.dart`
- `test/podesavanja_screen_smoke_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`

## 7. Files Changed

Created:

- `docs/OPC_CHARACTERIZATION_EVIDENCE_FOUNDATION.md`
- `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`
- `docs/OPC_CHARACTERIZATION_GAP_REGISTER.md`
- `docs/OPC_CHARACTERIZATION_BEFORE_CHANGE_RULES.md`
- `docs/tasks/OPC_TASK_CHARACTERIZATION_EVIDENCE_FOUNDATION_LOCK_CURRENT_BUSINESS_BEHAVIOR_BEFORE_SAFE_GROUPED_UPGRADES_REPORT.md`

Updated:

- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`

## 8. Characterization Foundation Created

Created `docs/OPC_CHARACTERIZATION_EVIDENCE_FOUNDATION.md` with evidence legend, owner framing, characterization-before-change rule, evidence categories, module behavior summaries, gaps, blockers, pseudocode relationship, Web readiness characterization, and final control summary.

## 9. Coverage Matrix Created

Created `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md` with 31 characterization entries covering all requested behavior areas.

## 10. Gap Register Created

Created `docs/OPC_CHARACTERIZATION_GAP_REGISTER.md` with 16 grouped gap entries matching the required safe-upgrade families.

## 11. Before-Change Rules Created

Created `docs/OPC_CHARACTERIZATION_BEFORE_CHANGE_RULES.md` with behavior-change, docs-only, pseudocode, evidence, owner decision, technical audit, runtime, parity, Web readiness, blocked wording, report wording, forbidden recommendation wording, and PASS/NOT PASS rules.

## 12. Pseudocode Updates Completed

Updated `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md` with:

- `OPC-PSEUDO-022` - Characterization evidence classification rule
- `OPC-PSEUDO-023` - Pseudocode-to-test coverage rule
- `OPC-PSEUDO-024` - Behavior-change blocking rule
- `OPC-PSEUDO-025` - Existing-test vs source-confirmed vs runtime-confirmed distinction
- `OPC-PSEUDO-026` - Web-readiness characterization guardrail

Updated `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md` and `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md` with matching references.

## 13. Key Evidence Levels Found

- Some evaluator/IRiU behavior is `TEST-CONFIRMED`.
- JSON transfer behavior is partly `TEST-CONFIRMED`.
- STANJE ROBE operational behavior is partly `TEST-CONFIRMED` and historically `RUNTIME-CONFIRMED`.
- Entitlement and auth have focused test evidence.
- PREDMET lifecycle, finance, PDF, PARTA/CITULJE, backup/restore, firm identity, runtime parity, and Web readiness retain significant characterization gaps.

## 14. Key Characterization Gaps Found

Key gaps include lifecycle/version/log coverage, display composition, finance matrix, PDF data contract, backup/restore safety, firm-scoped identity, JSON version/freshness warnings, Windows/Android parity, role/access identity, and future Web/sync readiness.

## 15. Owner Decisions Required

Owner decisions remain required for policy changes around display composition, advisor guidance, refund guidance, payer terminology compatibility, JSON version conflict policy, firm identity handling, version/change-log overview, payment/access model, cross-device roles, document add-on packaging, and future Web architecture.

## 16. Technical Audits Required

Technical audits remain required for full lifecycle characterization, finance, PDF, PARTA/CITULJE, backup/restore, firm identity, JSON warnings, STANJE ROBE transfer/restore/sync, runtime parity, entitlement/access boundaries, and Web/sync identity/conflict/storage/access.

## 17. Implementation Blocked Areas

Implementation is blocked for all behavior changes until characterization, owner decisions, pseudocode alignment, and tests or audit status exist.

## 18. No Strategy / Sequence / Priority Confirmation

No recommended next task, recommended next step, suggested sequence, roadmap, priority order, or implementation sequence was produced.

## 19. No Implementation / Source / Test / Behavior Changes Confirmation

No implementation, source, test, database/schema, UI, PDF, JSON, import/export, backup/restore, evaluator, IRiU, STANJE ROBE, finance, entitlement/licensing, Web/backend/API/sync/storage/payment/role, filename-generation, or runtime behavior changes were made.

## 20. Validation Results

Validation commands required after completion:

- `git diff --cached --check`
- `git diff --cached --stat`
- `python scripts\validate_opc_manifest_gate.py --base 0f82e144a16bd40e1482fd67dd2346233991a623`
- `git status --short`

Results:

- `git diff --cached --check`: PASS, no whitespace errors reported.
- `git diff --cached --stat`: 9 docs files changed, 1647 insertions.
- `python scripts\validate_opc_manifest_gate.py --base 0f82e144a16bd40e1482fd67dd2346233991a623`: PASS, 1 changed task report validated.
- `git status --short`: staged docs-only changes only.

## 21. Final Status

Final status: `PASS WITH OWNER REVIEW QUEUE`

## OPC MANIFEST COMPLIANCE — TASK END

Manifest read: REQUIRED and completed.

Manifest compliance checked: REQUIRED and completed.

PASS / NOT PASS: `PASS`
