# OPC Phase 9 — SCENARIO UI v1 report

## Scope

This bounded slice adds the first usable SCENARIO editor to the operational
`PREDMETI → MODULI` screen. It provides:

- OSNOVNI PAKET selected from existing KATALOG category IDs;
- scenario name and internal ID;
- one configurable criterion with comparison and one or more values;
- additional STAVKE selected from KATALOG;
- local persistence through the existing scenario wire contract and tables.

The screen does not apply a scenario to an existing PREDMET, does not add or
remove existing STAVKE, does not reconcile stale rows, and does not change
JSON/full-backup carriers. RUČNA/LEGACY protection and PREDMET ownership remain
for the next separately gated task.

## Navigation fact correction

The first implementation was briefly attached to the hidden
`OpcSettingsSection.moduli`. Source and tests confirmed that this section is not
visible in PODEŠAVANJA. The card was removed from that path and is now attached
to `ModuliScreen`, opened by the MODULI action in the PREDMET list.

## Safety evidence

- Base SHA: `6cb90b8b1d4b5f7f7337cebc3a760294e0fbc723`
- Task branch: `task/OPC-PHASE9-SCENARIO-UI-V1`
- Backup: `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE9_SCENARIO_UI_20260802.zip`
- Backup SHA-256: `CB1F6BDFCADC1FBFEDE70AF2DE0AA4D4062C7518E5041A8A75CBDEE2590570C2`
- Restore marker: `docs/tasks/OPC_RESTORE_POINT_PHASE9_SCENARIO_UI_20260802.md`

## Validation

- `flutter analyze --no-pub`: PASS — no issues found.
- Focused SCENARIO tests: PASS — 2/2.
- Full suite: PASS — 334 tests, 1 skipped, 0 failures.
- Windows/Android build: intentionally not run; reserved for cumulative runtime.
- Runtime acceptance: not performed; owner acceptance remains separate.

## Residual boundary

The next dependency is PREDMET-side explicit scenario selection/application,
user notice on changed consequences, and safe removal of scenario-owned stale
STAVKE while preserving RUČNA/LEGACY rows. Carrier/envelope wiring remains
paused until that business flow is proven.
