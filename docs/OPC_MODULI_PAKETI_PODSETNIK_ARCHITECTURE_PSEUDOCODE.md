# OPC MODULI / PAKETI / PODSETNIK Architecture Pseudocode

Status: current Stage 1 module/reminder authority; TASK 040 package matrices are historical/superseded.

## Package and module boundary

```text
PAKETI are abandoned as native business/production policy
central owner policy makes every existing Windows/Android capability available
retained entitlement payload/parser/bootstrap data is diagnostic compatibility
Stage 2 physical removal waits for owner runtime validation

PODSETNIK and STANJE ROBE are available regardless of retained package data

MODULI catalog shows module identity and availability
only a module with a documented operational active-use decision gets ON/OFF
STANJE ROBE has that persisted switch
PODSETNIK has per-PREDMET reminder configuration, not a global active-use switch
```

## PODSETNIK truth and navigation

```text
PREDMET is master business truth
CEREMONIJA edits ceremony facts inside PREDMET

PODSETNIK reads those facts
PODSETNIK owns enabled state and delivery times per PREDMET
PODSETNIK reuses the existing reminder repository/coordinator/gateway
PODSETNIK does not copy ceremony facts or scheduling logic

PREDMET overview -> MODULI -> PODSETNIK:
    open module surface
    offer PREDMET only when status is not ZAVRŠEN and not ANONIMIZOVAN
    sort newest PREDMET first and show its name without #number prefix

PREDMET overflow -> Podsetnik:
    IF PREDMET is not ZAVRŠEN and not ANONIMIZOVAN:
        open MODULI / PODSETNIK with that PREDMET selected
    ELSE:
        keep action disabled

Changing reminder configuration:
    persist through existing CeremonyReminderRepository
    reschedule through existing CeremonyReminderCoordinator
    deliver through existing CeremonyNotificationGateway

Changing ceremony date/time:
    persist only as PREDMET/CEREMONIJA facts
    ask the same coordinator to reschedule from stored reminder configuration
```

Historical task reports remain evidence of what was implemented at their time;
they are not the current architecture authority when they describe PODSETNIK as
an `openCeremony` shortcut.
