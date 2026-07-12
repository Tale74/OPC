# OPC Native Development POTPUN and Final-Package Licensing Pseudocode

Status: current owner-approved native development/runtime entitlement boundary, with historical presentation compatibility retained.

## Preserved final-package licence flow

```text
app starts
evaluate installed local license through bootstrap service

IF installed license is valid:
    active entitlement = signed license payload
ELSE:
    active entitlement = safe production fallback

safe production fallback:
    package = osnovni
    source = local license
    environment = production

central entitlement policy maps package/add-ons to modules
UI asks policy for availability
policy may lock modules
policy must not mutate PREDMET, IRiU, KATALOG, PDF, JSON or database truth
```

## Historical explicit presentation POTPUN compatibility

```text
build command may pass:
    --dart-define=OPC_PRESENTATION_POTPUN=true

IF OPC_PRESENTATION_POTPUN is true:
    active entitlement = presentation owner POTPUN
    source = presentationOwner
    environment = test
    package = potpun
    known add-ons = enabled for presentation
    installed local license bootstrap is not required

The flag remains compatible, but the current native-development default below
already selects POTPUN until final-package licensing is explicitly restored.
```

## Why development POTPUN is not final production licensing

```text
development mode is a temporary owner-approved native build default
development mode reports a non-production/test entitlement source
production local-license parser, bootstrap, repository and public-key registry remain intact
explicit final-package mode retains fail-closed OSNOVNI for missing/invalid licence
OSNOVNI / SREDNJI / POTPUN policy code remains live and tested
```

## Protected boundaries

```text
PREDMET remains master business truth
presentation package state controls availability only
package state does not rewrite saved PREDMET data
package state does not change PDF business content
package state does not change JSON transfer
package state does not change STANJE ROBE operational toggle persistence
package state does not repair PODSETNIK delivery or OS runtime behavior
```

## Historical runtime blockers recorded by the earlier presentation task

```text
PODSETNIK app-open dialog entitlement bypass observed in OSNOVNI runtime remains separate
PODSETNIK Android notification delivery proof remains separate
STANJE ROBE runtime proof remains separate if not explicitly performed
Windows slow-exit timing audit remains separate
STATISTIKA improvements remain deferred
Point 4 smoke remains blocked
```

## Current native development/runtime-validation rule

```text
DEFAULT while Windows and Android native apps are under development:
    developmentPotpunActive = true
    skip installed local licence bootstrap
    active package = POTPUN
    evaluate every module through unchanged central package policy

IF build has OPC_FINAL_PACKAGE_LICENSING=true:
    developmentPotpunActive = false
    evaluate installed local licence
    missing/invalid licence = existing fail-closed OSNOVNI
    valid licence = existing package/add-on payload

The same shared Dart resolver is used by Windows and Android.
Do not bypass advancedParte or any other individual module.
Revisit this temporary default after both native apps are final and before final
OPC Web OS-proof preparation.
```

## Reproducible build commands

Current approved native development/runtime-validation builds (POTPUN without
reading or rewriting a local licence):

```powershell
flutter build windows --release
flutter build apk --release
```

Future final-package/licensing verification builds:

```powershell
flutter build windows --release --dart-define=OPC_FINAL_PACKAGE_LICENSING=true
flutter build apk --release --dart-define=OPC_FINAL_PACKAGE_LICENSING=true
```

`OPC_FINAL_PACKAGE_LICENSING` accepts only `true` or `false`. An unknown value
is a configuration error; it must not silently select POTPUN or OSNOVNI.

Development mode changes only the effective runtime package. Installed licence
files and the persisted database are read-only with respect to this override,
so disabling the mode reveals the preserved licensed package again.
