# OPC SCENARIO → IRiU change/diff lifecycle report

## Baseline and scope

- Baseline branch: `task/OPC-KATALOG-FIKSNA-CENA-CRNINA-IRiU-IZNOS`
- Baseline SHA: `3b4442b76ef263eb68b1a6e688309cc650847329`
- Task branch: `task/OPC-SCENARIO-IRiU-CHANGE-DIFF-LIFECYCLE`
- Final SHA: recorded by the Git handoff after commit
- Remote tracking and baseline remote SHA matched before edits; working tree was clean.
- No SCENARIO MAP definition or golden fixture was changed.

The previous KATALOG/IRiU report is `docs/OPC_KATALOG_FIKSNA_CENA_CRNINA_IRIU_IZNOS_REPORT.md`. The 1008 golden, legacy-path and operational-recovery reports were reviewed before editing.

## Source-learned call graph

```text
PREDMET editor change
  → IriuSegment._onPredmetChanged
  → _runScenarioSync(predmetId-scoped)
  → ScenarioModuleRepository.ensureModuleAndDefaults/getActiveDefinitions
  → IriuRepository.syncScenarioRows
  → OwnerScenarioPolicyKernel.evaluate(PREDMET)
  → selected persisted MAP_* ScenarioDefinition
  → ScenarioRuleEngine evaluation
  → PREDMET-scoped PredmetScenarioSnapshot comparison
  → identity-based scenario-managed IRiU diff
  → explicit confirmation
  → additions / pending removals / managed attribute + provenance updates
  → per-row keep/remove decision
  → new PREDMET-scoped snapshot
```

The snapshot lives in `predmet_scenario_snapshots` keyed by `predmet_id`; provenance lives in `iriu_provenance` keyed by `iriu_id`. Manual rows have no scenario module provenance and are therefore outside the delete/update set. Existing `Iriu.cena`, `kom` and `iznos` persistence from the preceding task is retained.

## Acceptance matrix before the correction

| Acceptance point | Baseline finding | Action |
|---|---|---|
| PREDMET conditions derive the scenario | ALREADY CORRECT | Preserved; regression covered |
| Applied snapshot is per PREDMET | ALREADY CORRECT | Preserved; reopen/isolation tests added |
| No IRiU mutation before confirmation | ALREADY CORRECT | Preserved; exact row/snapshot assertion added |
| ADD/REMOVE diff | ALREADY CORRECT | Preserved; labels now use resolved display names |
| CHANGE/status diff | PARTIAL | Added `changedCategories` and UI section |
| Scenario-managed-only mutation | PARTIAL | Same-row provenance is now updated with the candidate assignment |
| Manual IRiU preservation | ALREADY CORRECT | Regression added and existing test retained |
| Manual amount preservation | PARTIAL / NOT PROVEN | Added amount/KOM override assertions across transitions |
| New scenario-item pricing | PARTIAL | Scenario additions now exercise existing FIKSNA snapshot resolver |
| A→B→C before confirmation | NOT PROVEN | Added regression; candidate is recomputed from applied A |
| Reopen/restart | NOT PROVEN | Added file-backed reopen regression |
| Multiple PREDMET isolation | ALREADY CORRECT / NOT PROVEN | Added two-PREDMET regression |
| UI identity safety | PARTIAL | Diff dialog now shows PREDMET number and user-facing labels, not MAP/KATALOG IDs |

## Implemented changes

- Extended `ScenarioSyncResult` with identity lists and user-facing `addedCategoryLabels`, `removedCategoryLabels` and `changedCategoryLabels`.
- Added identity-based comparison of scenario-managed status, provider, warning, reason, section, order and financial flags.
- Updated same-category provenance (`scenarioId`, version, origin and rule identity) after confirmation without touching `CENA`, `KOM` or `IZNOS`.
- Kept preview read-only: no IRiU, provenance or snapshot write occurs before confirmation.
- Kept post-apply removals pending for explicit keep/remove decisions; legacy result semantics remain compatible.
- Updated the diff dialog to show the concrete PREDMET number and DODAJE SE / UKLANJA SE / MENJA SE sections using resolved display labels.
- Added deterministic coverage for FIKSNA price snapshot and `KOM × CENA` on newly added scenario rows.
- Added coverage for manual row preservation, manual amount override preservation, removal/re-add freshness, repeated unconfirmed changes, reopen and two-PREDMET isolation.
- Updated IRiU lifecycle pseudocode with the confirmed A→B→C and confirmation boundary.

## Representative transitions

| Transition | Expected diff / evidence | Result |
|---|---|---|
| PRIRODNA + STAN + GROB → GROBNICA | ADD `LIMENI ULOŽAK`, `LEMOVANJE`; same-row change list may include managed order/status; manual row and override stay | PASS |
| GRADSKO GROBNICA → LOKALNO GROBNICA | `LIMENI ULOŽAK` status REQUIRED → RECOMMENDED; same row identity, CENA/KOM/IZNOS preserved | PASS |
| Scenario-managed removal then re-add | Removed row is explicitly resolved, not retained; re-add gets a fresh row and current price snapshot | PASS |
| A → B pending → C pending | Latest candidate is derived against applied A; intermediate B is not persisted | PASS |
| PREDMET X pending + PREDMET Y applied | X pending state and confirmation do not alter Y snapshot or rows | PASS |
| Confirmed B → close/reopen | Snapshot and IRiU rows remain consistent after SQLite reopen | PASS |

## Evidence and commands

Passing commands:

- `flutter test --no-pub test/scenario_iriu_change_diff_lifecycle_test.dart` — exit 0, 5 tests.
- `flutter test --no-pub test/scenario_owner_runtime_lifecycle_test.dart test/scenario_runtime_application_test.dart` — exit 0, 4 tests.
- `flutter test --no-pub test/scenario_map_1008_golden_consistency_test.dart test/scenario_module_repository_test.dart` — exit 0.
- `flutter test --no-pub test/katalog_fiksna_cena_iriu_iznos_test.dart test/json_transfer_regression_test.dart test/business_policy_iriu_critical_scenarios_test.dart` — exit 0.
- `flutter analyze --no-pub` — exit 0, no issues.

The previous migration recovery family remains `INCOMPLETE` because its full suite exceeded the documented ten-minute execution window. This task did not relabel that status as PASS; the file-backed lifecycle reopen test passed. No app build, release packaging or runtime build was run.

## Mandatory verdicts

PREDMET → SCENARIO RE-DERIVATION — PASS

NO IRiU MUTATION BEFORE CONFIRMATION — PASS

DIFF ADD/REMOVE/CHANGE ACCURACY — PASS

SCENARIO-MANAGED ONLY MUTATION — PASS

MANUAL IRiU ITEM PRESERVATION — PASS

MANUAL AMOUNT OVERRIDE PRESERVATION — PASS

NEW ITEM PRICE SNAPSHOT — PASS

NEW ITEM KOM × CENA AMOUNT — PASS

UNCHANGED ITEM VALUE PRESERVATION — PASS

STATUS CHANGE PRESERVES USER VALUES — PASS

MULTIPLE UNCONFIRMED CHANGES A→C — PASS

REOPEN/RESTART CONSISTENCY — PASS

MULTI-PREDMET STATE ISOLATION — PASS

SCENARIO 1008 GOLDEN GATE — PASS

KATALOG/IRiU REGRESSION — PASS

MIGRATION RECOVERY FAMILY — INCOMPLETE

FLUTTER ANALYZE — PASS

TARGETED TESTS — PASS

FULL FLUTTER TEST — INCOMPLETE

BUILD — NOT RUN BY OWNER DECISION

WINDOWS/ANDROID RUNTIME — DEFERRED TO CUMULATIVE BUILD

LOCAL DOCUMENTATION SYNC — NOT DEFINED
