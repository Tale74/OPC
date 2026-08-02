# OPC module boundaries and authority audit — 2026-08-02

## Authority rule

`PREDMET` is the only business authority for one funeral case: identity,
lifecycle, ceremony facts, contacts, selected scenario snapshot and the
PREDMET-owned IRIU consequence set. Other modules may own their own technical
or operational storage, but they must not become a second truth for PREDMET
facts.

`SCENARIO` is a business-rule engine and configuration surface. Its module
definitions/defaults are stored in `scenario_modules` and
`scenario_definitions`; the selected version and applied consequence snapshot
belong to the PREDMET authority. SCENARIO must not call PARTE or STANJE ROBE.

## Source audit matrix

| Module / layer | Source boundary | Owned storage/output | Authority rule |
|---|---|---|---|
| PREDMET | `PredmetiRepository`, `predmeti` | PREDMET row and lifecycle/log coordination | Single business authority; owns child lifecycle and explicit cross-boundary cleanup. |
| SCENARIO | `ScenarioModuleScreen`, `ScenarioModuleRepository`, `core_v2/scenario/*` | Scenario definitions/defaults; future PREDMET snapshot/provenance | Rule engine only; module edits are prospective and do not rewrite PREDMETI. |
| IRIU | `IriuRepository`, `iriu` | PREDMET-owned selected STAVKE and their ordering | Derivative/operational consequence set; manual STAVKA remains a PREDMET-local exception. |
| PARTE | `PartePreparationRepository`, `ParteTemplateRepository`, `parte_pripreme` | Preparation draft, template snapshot and exported derivative | Reads PREDMET; never becomes authority for PREDMET facts. |
| PODSETNIK | `PredmetiRepository.getPodsetnikKandidate`, reminder repository/coordinator | Device-local reminder settings and notification IDs | Reads PREDMET ceremony facts; reminder state is not PREDMET completion truth. |
| STANJE ROBE | `StanjeRobeOperationalAvailability`, lifecycle/effects repositories | Stock quantities, applied effects and unresolved consequences | Owns stock ledger; operational toggle controls activation. It does not read SCENARIO. |
| KATALOG / PODEŠAVANJA | `PodesavanjaRepository` and catalog tables | Firm configuration and category/article dictionary | Configuration/master dictionary, not a PREDMET business-fact authority. |
| MODULI screen | `ModuliScreen` | Navigation/entry points | UI shell only; it does not own module business data. |

## Existing sanctioned bridge

The source has an existing PREDMET/IRIU-to-stock bridge: `IriuRepository`
invokes `StanjeRobeLifecycleService` for covered catalog selections, while
`StanjeRobeOperationalAvailability` checks entitlement and the STANJE ROBE
toggle. `PredmetiRepository` also performs stock-effect cleanup when a whole
PREDMET is deleted. This is an existing PREDMET/IRIU integration boundary, not
a SCENARIO-to-STANJE ROBE dependency.

The SCENARIO source audit confirms that the SCENARIO editor/repository imports
the catalog settings repository and scenario contracts only. It does not
import `IriuRepository`, `StanjeRobe*`, `Parte*` or `Podsetnik*`. The Phase 10
planner is pure and has no database or module side effects.

## Required future rules

1. Editing a SCENARIO definition changes only module configuration.
2. Applying a SCENARIO to an eligible PREDMET changes only PREDMET-owned
   scenario snapshot and IRIU consequence rows through a PREDMET transaction.
3. SCENARIO application must not call STANJE ROBE, PARTE or PODSETNIK directly.
4. Existing IRIU/PREDMET integrations remain unchanged and continue to honor
   their own module toggles and contracts.
5. PARTE, PODSETNIK and stock effects are derived/operational outputs and may
   not overwrite PREDMET facts or lifecycle authority.

## Evidence

- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/core_v2/scenario/scenario_module_repository.dart`
- `lib/features/predmeti/core_v2/scenario/scenario_module_screen.dart`
- `lib/features/predmeti/parte/data/parte_preparation_repository.dart`
- `lib/features/podsetnik/presentation/podsetnik_module_screen.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_repository.dart`
- `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`
- `lib/features/stanje_robe/application/stanje_robe_lifecycle_service.dart`
