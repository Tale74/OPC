# OPC Cumulative Validation + Build/Runtime Preparation Report

Date: 2026-08-08

## Baseline

- Branch: `task/OPC-SCENARIO-IRiU-CHANGE-DIFF-LIFECYCLE`
- Confirmed baseline/implementation commit: `cc212bda8f8a44dc6d113a64270941c74ac860dd`
- New task branch: `task/OPC-CUMULATIVE-VALIDATION-BUILD-RUNTIME-PREPARATION`
- Baseline remote: `https://github.com/Tale74/OPC.git`
- Baseline working tree: clean before branch creation.
- Previous lifecycle, 1008 golden, and KATALOG/IRiU reports were present.

All Flutter commands below used `--no-pub` and no shell timeout wrapper. Long
processes were allowed to finish naturally and their complete output was saved
under `C:\Projekti\OPC\OPC v.1\RUNTIME\validation_logs`.

## Validation evidence

| Gate | Command | Result | Evidence |
|---|---|---|---|
| Diff hygiene | `git diff --check` | PASS | terminal evidence |
| Targeted SCENARIO kernel/runtime family | `flutter test --no-pub test/owner_scenario_policy_kernel_test.dart test/scenario_default_policy_characterization_test.dart test/scenario_module_repository_test.dart test/scenario_package_contract_test.dart test/scenario_persistence_contract_test.dart test/scenario_reconciliation_contract_test.dart test/scenario_runtime_application_test.dart test/scenario_runtime_single_truth_test.dart test/scenario_owner_runtime_lifecycle_test.dart test/scenario_transfer_envelope_test.dart test/single_predmet_scenario_carrier_contract_test.dart test/predmet_scenario_application_contract_test.dart test/scenario_state_reset_runtime_contract_test.dart test/scenario_editable_business_policy_test.dart test/scenario_module_screen_test.dart` | **NOT PASS — 80 passed, 5 failed** | `20260808_211942_targeted_scenario.log` |
| Targeted KATALOG/IRiU family | `flutter test --no-pub test/katalog_fiksna_cena_iriu_iznos_test.dart test/iriu_catalog_basic_category_policy_test.dart test/iriu_catalog_display_name_resolution_test.dart test/iriu_citulje_catalog_picker_test.dart test/iriu_confirmed_business_alignment_test.dart test/iriu_manual_amount_format_test.dart test/katalog_picker_repository_characterization_test.dart test/business_policy_iriu_critical_scenarios_test.dart test/json_transfer_regression_test.dart` | PASS — 62 passed, 2 skipped | `20260808_212247_targeted_katalog_iriu.log` |
| Lifecycle | `flutter test --no-pub test/scenario_iriu_change_diff_lifecycle_test.dart` | PASS — 5 passed | `20260808_212414_lifecycle.log` |
| Migration recovery first run | complete relevant family | NOT PASS — 63 passed, 1 skipped, 1 stale fixture failure | `20260808_212524_migration_recovery_family.log` |
| Migration recovery rerun | same complete family after fixture correction | PASS — 64 passed, 1 skipped, exit 0; natural duration 15:30 | `20260808_214243_migration_recovery_family_rerun.log` |
| SCENARIO 1008 golden | `flutter test --no-pub test/scenario_map_1008_golden_consistency_test.dart` | PASS — 4 passed | `20260808_215857_scenario_1008_golden.log` |
| Analyzer | `flutter analyze --no-pub` | PASS — no issues found | `20260808_220002_flutter_analyze.log` |
| Full suite | `flutter test --no-pub` | **NOT PASS — 386 passed, 5 failed, 3 skipped, exit 1; natural duration 22:32** | `20260808_220209_full_flutter_test.log` |

### Failure analysis

The five SCENARIO/full-suite failures are pre-existing characterization
expectations around `LIMENI_ULOZAK`/`LEMOVANJE` for hospital/biohazard and
GROBNICA cases. They reproduce on the confirmed pre-task baseline and are not
caused by the lifecycle diff implementation. No business-rule source change
was made to hide these failures or create a false PASS.

The single migration failure on the first run was a stale test fixture that
simulated `27 -> 26` even though the current KATALOG baseline is schema 27.
The fixture was minimally corrected to simulate future `28 -> 27`; the full
family then passed naturally. This is a test-maintenance correction only.

## Build decision

The task explicitly permits release builds only after every targeted family,
migration family, golden gate, analyzer, and full suite pass. Because the
targeted SCENARIO family and full suite are NOT PASS, neither build was run.
There are therefore no release artifacts or hashes, and no ADB activity.

- Windows release build: NOT RUN (gate condition not met)
- Android release build: NOT RUN (gate condition not met)
- Windows artifact hashes: NOT AVAILABLE
- Android APK hash: NOT AVAILABLE

## Database and evidence safety

Canonical user database `C:\Users\Steva\Documents\opc_v4_release.sqlite` was
not opened or modified by the automated validation. SHA-256 before and after:

`B6AD1F7376564589AD6AF2506932DDC8DCB6AFC50FCA4F30F525C01AE9D1C12F`

Runtime evidence is in `C:\Projekti\OPC\OPC v.1\RUNTIME`, including the
timestamped validation logs above. No local documentation sync target outside
the Git documentation layer is defined.

Runtime checklist:

`docs/OPC_CUMULATIVE_VALIDATION_RUNTIME_ACCEPTANCE_CHECKLIST.md`

## Mandatory verdicts

- `BASELINE VERIFIED — PASS`
- `TARGETED SCENARIO TESTS — NOT PASS`
- `TARGETED KATALOG/IRiU TESTS — PASS`
- `LIFECYCLE TESTS — PASS`
- `MIGRATION RECOVERY FAMILY — PASS (after documented fixture correction)`
- `SCENARIO 1008 GOLDEN GATE — PASS`
- `FLUTTER ANALYZE — PASS`
- `FULL FLUTTER TEST — NOT PASS`
- `TEST TIMEOUT POLICY — NO TIMEOUT USED`
- `WINDOWS RELEASE BUILD — NOT RUN`
- `ANDROID RELEASE BUILD — NOT RUN`
- `WINDOWS ARTIFACT HASHES — NOT AVAILABLE`
- `ANDROID APK HASH — NOT AVAILABLE`
- `CANONICAL DB UNCHANGED — PASS`
- `RUNTIME CHECKLIST — READY`
- `WINDOWS RUNTIME — PENDING OWNER ACCEPTANCE`
- `ANDROID RUNTIME — PENDING OWNER ACCEPTANCE`
- `WORKING TREE — NOT CLEAN (this report, checklist, and fixture correction are pending commit)`
- `REMOTE SHA — NOT CONFIRMED FOR THIS NEW BRANCH`

This task is **not ready for owner runtime acceptance** until the SCENARIO
characterization failures are resolved or explicitly owner-accepted and the
full suite is rerun with exit 0; only then may Windows and Android release
builds be attempted.
