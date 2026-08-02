# OPC Phase 10 — SCENARIO reconciliation planning report

## Scope

This bounded slice adds a pure reconciliation planner for the selected
SCENARIO package. It accepts PREDMET facts, a selected scenario/version, the
SCENARIO OSNOVNI PAKET and existing STAVKE with optional provenance, then
produces a deterministic plan containing:

- additions for desired categories that are not materialized;
- removal of stale rows owned by the selected SCENARIO module;
- provenance updates when ownership, scenario version or rule identity changes;
- a user-notice flag whenever the plan changes material consequences.

The planner is read-only. It does not write Drift, JSON/full backup, stock
effects or runtime state. Applying the plan remains a separately gated
transactional task.

## Protection boundary

Only `OSNOVNI_PAKET` and `SCENARIO_PAKET` provenance for the selected module
are eligible for automatic reconciliation. `RUČNA_STAVKA`, `LEGACY`, missing
provenance and rows belonging to another module are never emitted for removal
or update. A suppressed scenario consequence can remove a module-owned base
category because it is an explicit scenario rule.

## Files

- `lib/features/predmeti/core_v2/scenario/scenario_reconciliation_contract.dart`
- `test/scenario_reconciliation_contract_test.dart`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_PROJECT_NAVIGATION_AND_DEPENDENCY_MAP.md`
- `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`

## Safety evidence

- Base SHA: `e69b3cc240fed76f90943de427808983acfb79a7`
- Task branch: `task/OPC-PHASE10-SCENARIO-RECONCILIATION`
- Backup: `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE10_SCENARIO_RECONCILIATION_20260802_V2.zip`
- Backup SHA-256: `09096415A2BC649170381C338BC0CF5ED37F4B2A658F4CC9A4832D4F0F79F2E2`
- Restore marker: `docs/tasks/OPC_RESTORE_POINT_PHASE10_SCENARIO_RECONCILIATION_20260802.md`

## Validation

- Focused planner tests: PASS — 4/4.
- Combined SCENARIO contract/UI regression set: PASS — 40/40.
- `flutter analyze --no-pub`: PASS — no issues found.
- .NET UTF-8/no-BOM validator: PASS for all changed Dart and documentation
  files.
- Windows/Android build: intentionally not run; reserved for cumulative
  runtime.
- Owner Windows/Android runtime acceptance: not performed.

## Residual boundary

The next task may apply this plan only after proving explicit eligible-PREDMET
confirmation, STANJE ROBE compensation, transaction retry/rollback, locked
PREDMET protection, and a user-facing notice. No carrier or reminder work is
opened by this report.
