# OPC SCENARIO MODULE LOCK REPORT

## Handoff identity

- Task: `OPC — SCENARIO MODULE LOCK AND LOCKED REGRESSION CONTRACT`
- Branch: `task/OPC-SCENARIO-MODULE-LOCK`
- Base SHA: `c8d5f6d45acc8ec4363e9075dd0a5e25d534ae36`
- Locked production source SHA: `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`
- Final documentation SHA: recorded by the publication commit of this report
- Predecessor report: `docs/OPC_SCENARIO_FINAL_SPACING_CORRECTION_REPORT.md`
- No production source or test file was changed.

## Lock prerequisites verified

The predecessor report and public branch were independently verified at
`c8d5f6d45acc8ec4363e9075dd0a5e25d534ae36`. Its evidence records:

- focused SCENARIO test PASS;
- full `flutter analyze` PASS, `No issues found!`;
- full machine-readable Flutter suite PASS with `done.success=true`;
- 507 test completions, 0 failures and 10 skips;
- final Windows release PASS and clean 37-file distributive bundle;
- final Android release APK PASS;
- Windows `OPC.exe`, `data/app.so` and `sqlite3.dll` hashes;
- Android APK hash, size and timestamp.

Owner additionally confirmed the final interactive gates:

```text
WINDOWS INTERACTIVE RUNTIME ACCEPTANCE — PASS
ANDROID NARROW INTERACTIVE ACCEPTANCE — PASS
```

The predecessor spacing finding is therefore accepted as resolved. Runtime
acceptance is recorded as owner product evidence; it is not used as root-cause
evidence.

## Source safety

The lock branch starts from the verified predecessor documentation HEAD. The
locked source content is exactly the predecessor source SHA
`a8218537c1aa85b61fe5c85c21dbd03672f6e77c`. This task changes governance and
continuity documents only. Existing tests, including explicit historical skips,
remain intact. No backup, restore point, canonical database, build artifact,
business policy or test semantic was modified.

## Locked contract established

`docs/OPC_SCENARIO_MODULE_LOCK.md` is the authoritative lock document. It
records the accepted business/data contract, PREDMET non-retroactivity,
package-authority IRiU ordering, manual-row protection, reusable definitions,
bounded card/detail UI, accepted terminology, final spacing and Windows/Android
parity.

The change-control rule is:

```text
SCENARIO LOCKED — NO PRODUCTION CHANGE WITHOUT OWNER-AUTHORIZED UNLOCK OR PROVEN REGRESSION CORRECTION
```

## Test inventory and classification

Read-only inventory identified 33 SCENARIO-relevant executable test files and
one owner-map golden fixture. The classification is:

- `LOCKED CONTRACT — REQUIRED`: the 12 existing Tier 2 files listed in the
  lock document, covering derivation, package behavior, reconciliation,
  snapshots/non-retroactivity, ordering, manual rows, repository persistence,
  entry UI, bounded selected-PREDMET semantics, terminology and narrow layout.
- `DEEP SCENARIO REGRESSION`: 1008-map golden consistency, end-to-end runtime
  forensic stabilization, owner policy-kernel breadth, transfer/persistence
  envelope contracts, state-reset/lifecycle characterization, default-policy
  characterization, migration/legacy repair and startup no-op characterization.
- `CROSS-MODULE / FULL SUITE`: business-policy/IRiU critical scenarios,
  KATALOG stable-ID/display-resolution and pricing paths, database/migration,
  JSON transfer and other shared PREDMET infrastructure tests when their
  dependency path is affected.
- `HISTORICAL / CHARACTERIZATION`: production-ordering discrepancy evidence,
  phase-3 mutation characterization and explicit opt-in UI forensic tests.

No tests were deleted. The Tier 2 set is selected from actual existing coverage;
it is not a new business golden list and does not make concrete package content
authoritative.

### Complete file inventory

The 33 executable files were classified as follows:

| Classification | Existing files |
| --- | --- |
| LOCKED CONTRACT — REQUIRED (12) | `scenario_package_contract_test.dart`; `scenario_runtime_single_truth_test.dart`; `scenario_reconciliation_contract_test.dart`; `scenario_runtime_application_test.dart`; `predmet_scenario_application_contract_test.dart`; `iriu_ordering_partition_test.dart`; `iriu_shared_derived_ordering_test.dart`; `iriu_manual_row_regression_test.dart`; `scenario_module_repository_test.dart`; `scenario_module_screen_test.dart`; `scenario_module_narrow_responsive_test.dart`; `scenario_open_predmet_bounded_detail_test.dart` |
| DEEP SCENARIO REGRESSION (10) | `owner_scenario_policy_kernel_test.dart`; `scenario_default_policy_characterization_test.dart`; `scenario_end_to_end_runtime_forensic_stabilization_test.dart`; `scenario_iriu_change_diff_lifecycle_test.dart`; `scenario_map_1008_golden_consistency_test.dart`; `scenario_owner_runtime_lifecycle_test.dart`; `scenario_persistence_contract_test.dart`; `scenario_state_reset_runtime_contract_test.dart`; `scenario_transfer_envelope_test.dart`; `single_predmet_scenario_carrier_contract_test.dart` |
| CROSS-MODULE / FULL SUITE (8) | `business_policy_iriu_critical_scenarios_test.dart`; `iriu_catalog_basic_category_policy_test.dart`; `iriu_catalog_display_name_resolution_test.dart`; `iriu_citulje_catalog_picker_test.dart`; `iriu_confirmed_business_alignment_test.dart`; `iriu_manual_amount_format_test.dart`; `katalog_fiksna_cena_iriu_iznos_test.dart`; `scenario_editable_business_policy_test.dart` |
| HISTORICAL / CHARACTERIZATION (3) | `iriu_production_test_ordering_discrepancy_characterization_test.dart`; `phase3_scenario_iriu_mutation_characterization_test.dart`; `scenario_startup_noop_timestamp_mutation_characterization_test.dart` |

The separate `test/fixtures/scenario/scenario_map_owner_golden.json` file is a
deep-regression fixture, not a business-authority source.

## Impact-based regression policy

Tier 1 runs only task-targeted tests for changed code. Tier 2 runs when SCENARIO
or a credible dependency path is affected. Tier 3/full regression is required
for unlocks, PREDMET/IRiU/KATALOG/database/JSON/shared-infrastructure changes,
broad refactors, milestones, release candidates, uncertain impact or owner
request. Uncertainty defaults upward to broader regression.

The dependency boundary and exact invariant-to-test mapping are in
`docs/OPC_SCENARIO_MODULE_LOCK.md`.

## Continuity updates

The following current documents were updated so future Logos/Codex sessions can
discover the lock without relying on this report alone:

- `docs/OPC_SCENARIO_MODULE_LOCK.md` — authoritative lock and regression contract;
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md` — current locked-module entry;
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md` — lock authority and report mapping.

No historical report was rewritten as current authority.

## Backup boundary

Backup and restore-point creation was **NOT PERFORMED**. The current inventory
remains two existing backup ZIPs and 53 existing restore-point files. The next
authorized step is a separate fresh verified post-lock backup/restore-point
task, after owner/Logos verification of this lock.

## Final verdict

`SCENARIO MODULE — LOCKED`

`READY FOR POST-LOCK BACKUP — YES, as the next separate owner-approved task`

## OPC MANIFEST CHECK — TASK START

- Manifest read: yes
- Task class: documentation / governance / process enforcement
- Core purpose preserved: yes
- PREDMET meaning affected: no
- Database ownership affected: no
- JSON transfer affected: no
- Windows/Android parity affected: no production behavior change
- Future OPC Web affected: no
- Terminology drift risk: no
- Implementation allowed: no production implementation
- Required gate before implementation: owner confirmation gate / repository identity

## OPC MANIFEST COMPLIANCE — TASK END

- Manifest compliance checked: yes
- Core purpose preserved: yes
- PREDMET meaning preserved: yes
- Database ownership preserved: yes
- Windows/Android parity preserved: yes
- Existing JSON transfer preserved: yes
- Terminology preserved: yes
- Future OPC Web not blocked: yes
- Source changes within scope: yes — documentation/governance only
- If not compliant: not applicable

PASS / NOT PASS: `PASS`
