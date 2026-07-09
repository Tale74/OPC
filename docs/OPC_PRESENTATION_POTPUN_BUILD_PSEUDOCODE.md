# OPC Presentation POTPUN Build Pseudocode

Status: Git-tracked presentation-build memory for an explicit owner/internal POTPUN build mode.

## Normal package/license flow

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

## Explicit presentation POTPUN override

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

IF OPC_PRESENTATION_POTPUN is absent or false:
    use normal package/license flow
```

## Why this is not production licensing

```text
presentation mode is explicit by name and build command
presentation mode is not the default
presentation mode reports a non-production/test environment
production local-license parser, bootstrap, repository and public-key registry remain intact
normal fail-closed package remains OSNOVNI
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

## Known unresolved runtime blockers after presentation build

```text
PODSETNIK app-open dialog entitlement bypass observed in OSNOVNI runtime remains separate
PODSETNIK Android notification delivery proof remains separate
STANJE ROBE runtime proof remains separate if not explicitly performed
Windows slow-exit timing audit remains separate
STATISTIKA improvements remain deferred
Point 4 smoke remains blocked
```
