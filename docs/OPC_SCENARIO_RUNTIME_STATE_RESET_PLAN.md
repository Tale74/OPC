# OPC SCENARIO runtime state reset — plan and source finding

## Starting evidence

This reset starts from branch `task/OPC-SCENARIO-UI-RUNTIME-MIGRATION`, commit
`1e86c9f24e687c600c2d9518a80daab37a35a5e4`. The primary evidence is the local
runtime folder, not a ZIP:

- `C:\Projekti\OPC\OPC v.1\RUNTIME\Runtime posle korekcije.txt`
- `C:\Projekti\OPC\OPC v.1\RUNTIME\RUNTIME_1_ (OLD)\Runtime nalazi.txt`
- the scenario, PREDMET and KATALOG screenshots in those folders;
- the active source and tests in this checkout.

The latest runtime evidence records KATALOG as PASS but SCENARIO as FAIL. It
specifically reports the wrong module description fields, a one-option
three-dot menu, `+ DODAJ` at the top, a generic scenario form instead of a
business overview, non-editable `PREPORUČENO` items, disappearing checked
items, and a non-functional `PRIKAŽI SAŽETAK ODLUKE`. It also reports that
only OSNOVNI PAKET reaches PREDMET/IRiU.

## What was not actually implemented

The previous correction migrated and persisted scenario definitions, but it
did not complete the runtime state reset. The active screen still presents a
definition editor as the primary experience. More importantly, the scenario
editor is not the application boundary for an existing PREDMET, and the
runtime application path has not been proven from an initially materialized
PREDMET.

The source explains the apparent contradiction: `PredmetiRepository.inicijalizujIriu`
materializes the basic package, while `IriuRepository.syncScenarioRows` is
called later from the IRIU segment. In the current implementation the list of
scenario-owned rows is created with `toList(growable: false)` and then base
rows without provenance are appended to it. That throws before scenario
additions are inserted. The segment starts this synchronization without
awaiting it, so the failure is not visible as a blocking UI error and the
basic package remains the only visible result.

## What remains from the older runtime findings

The older findings remain relevant because the current UI still contains the
same structural defects: a generic form for existing scenarios, insufficient
business explanation, no explicit impact-on-PREDMET section, and actions that
do not provide a real consequence. The reset must address those findings in
the current source rather than treating the repository migration as a UI
acceptance.

## Current SCENARIO UI flow

1. `ScenarioModuleScreen` loads the module, catalog and definitions.
2. It displays two explanatory cards, then OSNOVNI PAKET and SCENARIJI.
3. SCENARIJI exposes `+ DODAJ` in the header and each row hides its only
   action behind a `PopupMenuButton`.
4. Opening an existing scenario enters the same `_ScenarioDialog` used for a
   new scenario. The dialog edits criteria and consequences but does not first
   show a business overview.
5. Selected consequences are mixed with available catalog entries through a
   filter, and the dialog still exposes the non-functional summary action.
6. PREDMET starts with the basic package. The IRIU segment attempts a later
   scenario synchronization, but the fixed-length-list exception above
   prevents it from completing for a newly initialized PREDMET.

## Target SCENARIO UI flow

The main screen will be ordered as module description, OSNOVNI PAKET, existing
business scenarios, and only then an optional `DODAJ NOVI SCENARIO` action.
The first description field will contain exactly:

> Modul SCENARIO uređuje listu osnovnih i dodatnih stavki robe i usluga za automatski pregled i obračun prema mestu smrti i drugim uslovima.

The second explanatory field will be removed; the third is retained only if
source/runtime verification shows it has a working business purpose. Existing
scenarios open a business overview first. The overview will show when it is
used, what it adds, item status, special conditions, exclusions, warnings,
impact on PREDMET/IRiU, and the editable actions. `UREDI`, `SAČUVAJ IZMENE`
and `ODUSTANI` are the only scenario editing actions.

The editor will keep selected items visible in a dedicated selected list and
available catalog items in a separate list. A selected item can be removed,
its status can be changed, and cancellation restores the persisted state.
No technical rule vocabulary is displayed to the user.

## Scenario → PREDMET → IRiU connection

The runtime connection is `IriuSegment._runScenarioSync` →
`IriuRepository.syncScenarioRows` → `ScenarioRuleEngine.evaluate`. The engine
matches `ScenarioDefinition.condition` against `PredmetiData`, combines the
basic package with scenario consequences, and writes scenario-owned IRIU rows
with provenance. Condition changes are reconciled through
`resolveScenarioConditionChange`, preserving a row until the user explicitly
decides what to do.

The missing runtime behavior is therefore not a new business policy: it is the
broken application hand-off caused by the non-growable list and an unawaited
UI task. The reset will make this path deterministic, observable in tests, and
safe for an initially initialized PREDMET.

## Why individual scenarios did not affect PREDMET

OSNOVNI PAKET was inserted synchronously by `PredmetiRepository.inicijalizujIriu`.
Scenario definitions were only read by the later synchronization call. That
call attempted to append unprovenanced basic rows to a fixed-length list and
failed before inserting BOLNICA, DOM ZA STARE, STAN or ULICA additions. The
existing focused test exercised synchronization without those pre-materialized
basic rows, so it did not cover the actual runtime sequence.

## Existing actions and removals

The reset removes the one-option three-dot menu, `PRIKAŽI SAŽETAK ODLUKE`,
`PROVERI NA PRIMERU`, `NAPRAVI KOPIJU`, and `STAVI SCENARIO VAN UPOTREBE` from
the user-facing scenario flow. No replacement action is added unless it has a
persisted, tested consequence. Existing scenario rows use a direct visible
`PREGLED`/`UREDI` action.

## Concrete BOLNICA flow

The BOLNICA overview states that it applies when mesto smrti is BOLNICA and
adds only PREVOZ DO GROBLJA; unrelated handling items are explicitly shown as
not added. `UREDI` changes the persisted consequence/status and reopening the
overview shows the saved state. In a PREDMET, selecting BOLNICA causes the
awaited scenario synchronization to match `BOLNICA`, add the scenario-owned
PREVOZ_DO_GROBLJA row with its reason/provenance, and leave the nine basic rows
untouched. When the condition changes, the row remains visible as pending
until the user chooses keep or remove through the existing decision boundary.

The same integration tests cover DOM_ZA_STARE, PRIVATNA BOLNICA and DRUGO
(the shared DOM policy), STAN, ULICA_JAVNO_MESTO, BIOHAZARD warning behavior,
LIMENI_ULOZAK/LEMOVANJE separation, OPELO, LOKALNO_GROBLJE and international
and cargo conditions without reopening KATALOG policy.

## Implementation and validation boundaries

Implementation is limited to the SCENARIO screen/state model, scenario
application hand-off, and regression tests. KATALOG business logic is not
changed unless a direct regression is found. The order of validation is
`flutter analyze`, focused tests, then the complete `flutter test`; each must
return an explicit exit code 0. Per the owner's follow-up instruction,
Windows and Android release builds are authorized only after both full
analysis and full test suites are clean. Runtime acceptance remains pending
until the owner runs the supplied Windows smoke checklist against a verified
copy of the canonical database.
