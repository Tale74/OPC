# OPC task report — SCENARIO runtime migration (2026-08-02)

## Scope

- Move active scenario consequence selection from the IRIU widget trigger path
  to the existing SCENARIO module.
- Store former default rules as editable data in
  `assets/scenario_defaults.json`, seeded only into an empty module.
- Evaluate all active user-editable rules and reconcile STAVKE through
  `IriuRepository`.
- Remove only SCENARIO-owned stale rows; preserve RUČNA, LEGACY, unknown and
  other-module rows.
- Preserve the existing PREDMET → IRIU → STANJE ROBE bridge.

## Implementation

- Added `ScenarioRuleEngine` for composition of all matching rules.
- Added default-data loading in `ScenarioModuleRepository`.
- Added provenance-aware `syncScenarioRows` in `IriuRepository`.
- Replaced IRIU segment scenario-trigger calls with one SCENARIO sync path.
- Added focused runtime reconciliation and default-seeding tests.
- Updated pseudocode, navigation map and current development state.

## Evidence

- Focused tests: PASS, 3 test files / 7 tests in the focused invocation before
  the final removal
  of the now-unused legacy lifecycle helpers. The helper removal is compile
  neutral; the immediate rerun was blocked by a stale Flutter native-assets
  cache after the intentionally stopped broad suite (`sqlite3.dll` missing).
- `flutter analyze --no-pub`: PASS with no errors; one style info and legacy
  private helper suppressions were removed; final analyze reports no issues.
- Build/runtime: deliberately not run; reserved for cumulative runtime.

## Safety

- Base SHA: `97d6b99a07f754f7c5ee42c0f851720c91bfca6e`
- Result SHA (pre-push): `8a43bc5a4d14ff4c61adeaceef3e69e23f9e3aed`
- Pre-task backup:
  `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE12_PREDMET_SCENARIO_APPLY_20260802.zip`
- Backup SHA256:
  `7B9C3A77509411173A78BE5C69DA93BE56C0E76AC00F09F4692CC8B8CCDFBF62`
- Restore marker: this report plus the backup above.

## Residual boundary

The existing pure Phase 10/11 contracts remain as compatibility/test
contracts; no new carrier or module was introduced. Full Windows/Android
runtime acceptance is still required in the cumulative runtime gate.
