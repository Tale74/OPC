# OPC Phase 4 Current Dependency Graph / Matrix

**Evidence:** static Dart import analysis at Phase 4 baseline. Edges are file-level imports aggregated by current architectural area; a count is the number of observed import edges, not runtime call volume.

## Graph

```text
main/app
  → database, auth, settings, PREDMET, reminders, theme
PREDMET presentation/application/data
  → database, core utils/format, auth, settings, stock, reminders, PARTE/PDF, SCENARIO
settings
  ↔ PREDMET presentation/data
  → database, auth, stock, entitlements, installation, utilities
PODSETNIK
  ↔ PREDMET reminders/data
  → database
core/utils JSON/export
  ↔ database and PREDMET/SCENARIO/PARTE/stock/auth/reminders
SCENARIO/IRiU
  → database, KATALOG/settings, policy, stock and PREDMET repositories
stock
  → database, auth/settings/entitlements
auth
  → database and recovery/security infrastructure
```

## Aggregated import edges

| Current source area | Imported area | Evidence / implication |
|---|---|---|
| `lib/app.dart` | database, auth, settings, PREDMET, theme, reminders | Composition owns too many concrete implementations |
| `feature:predmeti` | database (54 observed), core/utils (18), settings (11), stock (18), auth (6), entitlements (9), constants/format | PREDMET is central but presentation/data has infrastructure leakage |
| `feature:podesavanja` | database (5), auth (4), stock (4), PREDMET (2), utilities/entitlements/installation | Settings and feature composition participate in a direct cycle with PREDMET |
| `feature:podsetnik` | PREDMET (5), database | Reminder UI reaches directly into PREDMET data and reminder internals |
| SCENARIO / IRiU implementation | database, KATALOG/settings, policy, stock and PREDMET repositories | Locked business contracts are active, but current placement exposes cross-feature and persistence edges |
| KATALOG/settings repositories and screens | database, auth, stock, entitlements, PREDMET | Catalog/configuration and UI composition are mixed with identity and PREDMET navigation |
| Policy/finance/statistics | PREDMET/IRiU models and database-backed snapshots | Derived policy/finance logic is PREDMET-adjacent and lacks an independent physical boundary |
| PARTE and document generators | PREDMET snapshots, database/media, shared rendering utilities | Derivative workflows are active but exporters and presentation call technical helpers directly |
| JSON/interoperability and backup | database, PREDMET/SCENARIO/PARTE/stock/reminders/auth, filesystem/share APIs | Integration monolith owns both application orchestration and technical adapters |
| `core:utils` | PREDMET (9), database (2), JSON transfer, auth, stock | JSON utility is an integration hub, not a utility boundary |
| `core:database` | catalog/config/constants/utils | Database implementation reaches seed/catalog/utility concerns |
| `feature:auth` | database (6) | Auth is data-backed and should remain behind identity ports |
| `feature:stanje_robe` | database (5), settings/auth/entitlements | Stock is a projection but has direct infrastructure/context coupling |
| Windows/Android platform branches | filesystem, notification, lifecycle, permissions, packaging APIs | Platform-specific behavior is a real adapter obligation; no deadness inferred from one-platform use |

## Proven direct cycles

| Cycle | Source proof | Target correction |
|---|---|---|
| PREDMET ↔ settings | `scenario_module_screen.dart`, `iriu_repository.dart`, PREDMET screens import settings; `podesavanja_screen.dart` imports PREDMET repository/PARTE screen | Published settings/catalog ports and app composition; no screen-to-screen feature imports |
| PREDMET ↔ PODSETNIK | PREDMET list/module screens import PODSETNIK screen; PODSETNIK screen imports PREDMET repository and reminder services | Reminder workflow consumes PREDMET facts through a port; navigation/composition owns wiring |
| `core/utils` ↔ database | `json_export_import.dart`/`export_utils.dart` import database; `database.dart` imports `stable_id_generator.dart` under utils | Move codecs/adapters to infrastructure and make persistence ports explicit |
| `core/utils` ↔ PREDMET | JSON monolith imports PREDMET/SCENARIO/PARTE/reminder/stock; PREDMET screens import JSON/export utilities | Feature interoperability workflow owns orchestration; presentation calls workflow contract |

## No unsupported cycle claims

The import scan did not prove a reverse `stanje_robe → predmeti` import; stock receives PREDMET/IRiU-derived inputs from callers. Runtime/event cycles may still exist and require later tracing, but are not asserted here.
