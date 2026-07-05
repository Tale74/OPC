# OPC MODULI / PAKETI / PODSETNIK Architecture Pseudocode

Status: Git-tracked architecture memory distilled from current source and local TASK 040 product documentation.

## Package and module boundary

```text
PAKET is one of osnovni, srednji, potpun
central entitlement policy maps package/add-ons to capabilities
UI consumers ask that policy; they do not invent package rights

PODSETNIK belongs to srednji and potpun
STANJE ROBE belongs to potpun or an allowed srednji add-on

MODULI settings shows module identity and availability
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

PODEŠAVANJA -> MODULI -> PODSETNIK:
    IF entitled: open module surface and allow a non-anonymized PREDMET choice
    ELSE: show locked package-safe identity

PREDMET overflow -> Podsetnik:
    IF entitled AND PREDMET is not anonymized:
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
