# OPC Pre-Build STANJE ROBE / Podsetnik Pseudocode

Status: Logos learning layer for the source-confirmed settings and shortcut flow.

## STANJE ROBE availability and active use

```text
STANJE ROBE belongs to POTPUN
OR to SREDNJI only when its explicit add-on entitlement is present

PODEŠAVANJA always shows the MODULI section:
    IF current package/context does not entitle STANJE ROBE:
        show STANJE ROBE as locked/not licensed
        show no ON/OFF switch
        expose no stock-management action
    ELSE IF current user is not ADMINISTRATOR:
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
    package/context entitles STANJE ROBE
    AND persisted active-use value is ON
```

The visible locked state explains why an `Osnovni` runtime has no active toggle
without exposing stock functionality outside its package. Availability and
active use remain separate decisions.

## PREDMET-list Podsetnik shortcut

```text
WHEN user opens one PREDMET overflow menu:
    IF current package/context entitles Podsetnik
       AND PREDMET is not anonymized:
        enable Podsetnik
    ELSE:
        keep Podsetnik disabled

WHEN enabled Podsetnik is selected:
    open the existing PREDMET screen
    select its existing CEREMONIJA section initially
    do not create or mutate reminder configuration during navigation
```

An `Osnovni` runtime is not entitled to Podsetnik, so its visible grey shortcut
is expected. `Srednji` and `POTPUN` are entitled; their non-anonymized PREDMET
shortcut is enabled even when optional ceremony fields are incomplete or
reminder events already exist. Anonymized PREDMET remains disabled.

CEREMONIJA remains the only settings surface for enabling reminders and choosing
delivery times. Its existing repository, coordinator, validation, scheduling,
and notification gateway remain unchanged.

Incomplete ceremony data is safe: the shortcut only navigates. CEREMONIJA shows
its existing fields and reminder controls, while the existing coordinator
produces no scheduled occurrences without a valid ceremony date/time.

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
