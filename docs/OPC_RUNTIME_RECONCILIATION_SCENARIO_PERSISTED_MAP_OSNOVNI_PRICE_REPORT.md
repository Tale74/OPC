# OPC runtime reconciliation: PREDMET, persisted MAP and OSNOVNI PAKET price

Status: implementation, automated gates and release builds complete. Manual
runtime acceptance remains owner-controlled in the cumulative checklist.

## Scope and immutable inputs

- Baseline branch: `task/OPC-SCENARIO-CHARACTERIZATION-ZERO-FAIL-BUILD`
- Baseline SHA: `ae310d2dc16ca41b6b35f48ce3f700c00fb2f724`
- Task branch: `task/OPC-RUNTIME-RECONCILIATION-SCENARIO-PERSISTED-MAP-OSNOVNI-PRICE`
- Owner-map source SHA-256: `663F104F01C8ABFABAF5DEDF8C82185AF03FDEF31B403DFB7D4E2EFBF0E061E4`
- Canonical SQLite was not written by this task. Observed forensic input hash
  at the start of this run:
  `CCAB35A27334F33B3212B4AA7AE7608BE97CC77C5ED9F457242390C579C3E19C`.

## Runtime call graphs and findings

### A. PREDMET context and persisted assignment

```text
PredmetScreen popup "Scenario predmeta"
  -> ScenarioModuleScreen(predmet: current PredmetiData)
     -> ScenarioModuleRepository.ensureModuleAndDefaults()
     -> AppDatabase.predmetScenarioSnapshots[predmetId]
     -> ScenarioAssignmentSnapshot.fromJsonMap(snapshot_json)
     -> PredmetAppliedScenarioCard
        -> "Scenario za PREDMET <broj>"
        -> business summary + "PRIMENJEN MAP_<stable-id>"
```

The separate `ModuliScreen -> ScenarioModuleScreen` route remains the global
module editor and intentionally has no active PREDMET. The concrete PREDMET
route already passed the record, but the card previously recomputed only the
live kernel result and did not expose the persisted assignment. The card now
reads the same snapshot written by `IriuRepository.syncScenarioRows`, while a
missing snapshot still renders a live preview for an incomplete/new PREDMET.

The summary separator and `DOČEK` label were corrected in both the UI helper
and `OwnerScenarioKey.businessSummary`; the affected paths contain no
mojibake.

### B. NASILNA protective equipment

```text
ScenarioModuleRepository.ensureModuleAndDefaults()
  -> _ensureOwnerMapDefinitions()
     -> _repairKnownOwnerMapProtectiveEquipmentGap()
        -> exact generated MAP_NASILNA_* fingerprint only
        -> restore ZAŠTITNA_I_DODATNA_OPREMA
Predmet IriuSegment
  -> IriuRepository.syncScenarioRows()
     -> OwnerScenarioPolicyKernel.evaluate(predmet)
     -> active complete MAP definition
     -> scenario-owned IRiU row + provenance
```

The forensic distinction is important: the 1008 golden map is complete; the
reported runtime omission is a stale version-1 generated `MAP_NASILNA_*` row,
not a missing owner-policy rule. The repair is deliberately fingerprinted so a
user-edited MAP record is not overwritten. Automated coverage proves both the
repair and the runtime result for
`NASILNA / STAN / SAHRANA / GRADSKO / GROBNICA / OPELO NE`, including isolation
from a second PREDMET.

### C. OSNOVNI PAKET price hand-off

```text
PredmetiRepository.inicijalizujIriu(predmetId)
  -> ScenarioModuleRepository.readOsnovniPaket(module)
  -> IriuKatalogConfig row
  -> INSERT iriu(cena, iznos)
IriuRepository.syncScenarioRows()
  -> _insertStavka()
  -> _resolveAppliedUnitPrice()
```

The old materializer inserted OSNOVNI rows with only identity, display name,
quantity and ordering, leaving fixed-price `CENA/IZNOS` at zero. Scenario-added
rows already used `_resolveAppliedUnitPrice`, which explains the asymmetric
runtime observation. The materializer now snapshots a fixed KATALOG price and
initial `KOM=1` amount at the same boundary; KATALOŠKA categories remain zero
until an article is explicitly selected.

## Regression evidence

The following tests pass on this branch:

- Full `flutter test --no-pub`: **393 passed, 3 skipped, 0 failed**.
- `scenario_map_1008_golden_consistency_test.dart`: 4 passed, 0 failed;
  independent 1008 oracle and seeded definitions agree.
- `scenario_owner_runtime_lifecycle_test.dart`: owner snapshot, NASILNA
  protective equipment, and multi-PREDMET isolation pass.
- `scenario_module_repository_test.dart`: stale NASILNA repair and custom MAP
  preservation pass.
- `scenario_runtime_single_truth_test.dart`: fixed-price OSNOVNI row stores
  `CENA=42.5`, `IZNOS=42.5` for `KOM=1`.
- `scenario_module_screen_test.dart`: PREDMET card, persisted `MAP_` identity,
  independent cards, and mojibake-free summary pass.
- `scenario_iriu_change_diff_lifecycle_test.dart`,
  `scenario_state_reset_runtime_contract_test.dart`, and
  `katalog_fiksna_cena_iriu_iznos_test.dart`: all pass, including price
  snapshot, manual override, diff and reopen behavior.
- Flutter analyzer: `No issues found!`.

Evidence logs are stored under
`C:\Projekti\OPC\OPC v.1\RUNTIME\validation_logs`, including
`20260809_181500_scenario_1008_golden_reconciliation.log` and
`20260809_181530_scenario_runtime_reconciliation_targeted.log`, plus the full
suite log `20260809_182000_full_flutter_test_reconciliation_zero_fail.log`.

## Release artifacts

- Windows `OPC.exe`: 89,088 bytes,
  SHA-256 `EB2DB87A10379AB9325DBFDC04EEBFF011C97A0B59C2CB24FA94B6A5D84A1E92`.
- Windows `data/app.so`: 12,633,008 bytes,
  SHA-256 `A5CA5084BDEE0BA25DABB9DADFDA8EFDC246D48D44956216D9D00E5FEDE297B0`.
- Android `app-release.apk`: 77,961,079 bytes,
  SHA-256 `8F9E127ED6DA8D521E45E484B2859119D97CED26DF8049E55C91FB006CF7805C`.
- Build logs: `20260809_203000_windows_release_reconciliation.log` and
  `20260809_203500_android_release_reconciliation.log`; both end with
  `EXIT_CODE=0`.
- Analyzer log: `20260809_204500_flutter_analyze_reconciliation.log`, ending
  with `No issues found!` and `EXIT_CODE=0`.
- Canonical SQLite post-build hash is unchanged at
  `CCAB35A27334F33B3212B4AA7AE7608BE97CC77C5ED9F457242390C579C3E19C`.

## Owner acceptance

The expanded manual checks (concrete PREDMET entry, NASILNA protective item,
OSNOVNI price, `KOM>1`, manual override, A→B→C, multi-PREDMET, reopen and
Windows/Android parity) are recorded in section K of
`docs/OPC_CUMULATIVE_VALIDATION_RUNTIME_ACCEPTANCE_CHECKLIST.md` and remain
`PENDING OWNER ACCEPTANCE` until exercised on the target runtime devices.
