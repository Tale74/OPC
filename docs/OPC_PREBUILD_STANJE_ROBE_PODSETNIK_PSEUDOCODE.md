# OPC Pre-Build STANJE ROBE / Podsetnik Pseudocode

Status: Logos learning layer for the source-confirmed settings and shortcut flow.

## STANJE ROBE availability and active use

```text
STANJE ROBE is available to every native user under the Stage 1 owner policy
retained package/add-on/license data does not restrict availability

MODULI catalog shows STANJE ROBE:
    IF current user is not ADMINISTRATOR:
        show module status
        show no ON/OFF switch
        expose no stock-management action
    ELSE:
        show the persisted ON/OFF switch
        allow ADMINISTRATOR to open existing stock management

Persisted active-use value defaults to OFF
Entitlement does not change that value to ON
Stock initialization does not change that value to ON

Operational stock consumers proceed only when:
    persisted active-use value is ON
    AND role/business rules allow the requested operation
```

Availability and active use remain separate decisions. There is no current
native package-locked state; SAVETNIK role restrictions and the persisted
ADMINISTRATOR operational toggle remain active.

## PREDMET-list Podsetnik shortcut

```text
WHEN user opens one PREDMET overflow menu:
    IF PREDMET status is not ZAVRŠEN
       AND PREDMET is not ANONIMIZOVAN:
        enable Podsetnik
    ELSE:
        keep Podsetnik disabled

WHEN enabled Podsetnik is selected:
    open the MODULI / PODSETNIK surface for that PREDMET
    show CEREMONIJA facts as read-only reminder inputs
    keep CEREMONIJA as the place where those facts are edited
    do not create or mutate reminder configuration during navigation
```

Every native runtime may open PODSETNIK. Its selector includes every PREDMET
except ZAVRŠEN and ANONIMIZOVAN, sorts newest first and shows the deceased name
without a `#<redni_broj>` prefix. Optional ceremony fields may remain incomplete
and existing reminder events do not affect candidate visibility. PODSETNIK
reuses the existing reminder repository, coordinator and notification gateway;
it does not own a second copy of ceremony or PREDMET truth.

MODULI / PODSETNIK is the current settings surface for enabling reminders and
choosing delivery times. CEREMONIJA remains the authoritative editor of ceremony
facts and reschedules through the same repository, coordinator, validation,
scheduling, and notification gateway when those facts change.

Incomplete ceremony data is safe: the shortcut only navigates. CEREMONIJA shows
its existing source fields, MODULI / PODSETNIK shows reminder controls, and the
existing coordinator produces no scheduled occurrences without a valid
ceremony date/time.

## Reminder dialog readability

```text
WHEN multiple reminder events are due:
    render one bounded row per event
    keep visible vertical space between rows
    alternate between theme-provided low/high surface colors
    keep the existing reminder text unchanged
```

The list is scroll-bounded for many events and uses the active theme's surface
and outline colors, so light/dark readability does not depend on hard-coded
colors. This is presentation only; event identity, text, timing, persistence,
scheduling, and delivery remain unchanged.

## Protected boundary

This flow changes settings visibility and navigation only. It does not change
package ownership, default OFF behavior, stock consequences, reminder data,
reminder scheduling/delivery logic, ceremony truth, PREDMET truth, platform
rules, PDF, JSON, finance, IRiU, catalog items, or runtime runners.
