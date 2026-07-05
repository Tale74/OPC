# OPC Pre-Point-4 Corrections Audit Pseudocode

Status: source/test/documentation map only. No A–G correction is implemented here.

```text
PREDMET remains master business truth

A STANJE ROBE (operational module):
    entitlement = POTPUN OR SREDNJI + explicit add-on
    effective active = entitlement AND persisted ADMIN switch
    persisted default = OFF
    source/tests prove policy, roles, OFF and locked Osnovni
    runtime must prove real licensed POTPUN presentation and interaction

B PODSETNIK shortcut (operational/package module):
    enable only when Srednji/Potpun entitlement AND PREDMET not anonymized
    navigate to MODULI / PODSETNIK, never directly to CEREMONIJA
    source/widget tests prove route; native interaction remains runtime-only

C PODSETNIK readability (presentation only):
    app-open event list supports multiple rows
    explicit spacing + alternating theme-safe surfaces already exist and are tested
    any future polish stays inside event-list presentation
    do not touch reminder engine

D PODSETNIK delivery (Android platform boundary):
    configuration persists selected clock times per PREDMET
    model derives occurrences at 2 days, 1 day and ceremony day
    coordinator cancels/replaces scheduled IDs
    Android gateway uses zonedSchedule with inexactAllowWhileIdle
    app startup/resume also reschedules and may show due dialog
    unit tests prove model/coordinator contracts through fake gateway
    only Android device runtime can prove permission, OS scheduling and closed-app delivery
    owner correction requires system notification as primary delivery

E STATISTIKA (PREDMET-consuming informational module):
    one selected date range applies to all tabs and recomputes immediately
    presets = 7 days, 30 days, current month, current year, custom
    no previous-month or same-month-last-year comparison exists
    current tests cover only Android compact-filter selection
    future correction needs UI/report models plus characterization/regression tests

F PDF memorandum/header (PREDMET-derived output):
    six standard exporters each own a header
    only logo sizing is shared
    shared identity-row builder emits PIB, MB and Račun separately
    all six headers render those entries as separate text rows
    LISTA "Racun" drift is corrected to "Račun"
    do not reopen logo acceptance, finance, invoice legality or document body logic

G Windows slow exit (technical/platform support):
    Dart intercepts close, asks confirmation, then awaits windowManager.destroy
    runner releases Flutter controller in OnDestroy
    source shows no explicit DB close/export/notification cleanup in close handler
    prior runtime measured 12.8 seconds but supplied no phase timing
    later Windows runtime task must instrument confirmation-to-destroy, engine/plugin teardown and process exit

H POINT 4 / smoke boundary:
    smoke remains blocked while A–G debt is open or not explicitly separated by owner
    source-only corrections must be validated before platform runtime tasks
    Android delivery proof and Windows exit profiling must be separate runtime lanes
```

Safe sequence: characterize and implement E separately; implement F narrowly;
audit/correct D then run Android device proof; run isolated G Windows profiling;
group A–C only for final runtime verification after their source state is stable;
then authorize Point 4 smoke.
