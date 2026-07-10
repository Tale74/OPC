# OPC PODSETNIK Control Flow And User Confirmation Pseudocode

Status: audit-only architecture memory. No expanded PODSETNIK behavior, data
model, schema, UI, notification rule, role rule, JSON rule, or lifecycle rule is
implemented by this document.

## Current source-confirmed state

```text
PREDMET is the authoritative business truth

PREDMET currently owns:
    lifecycle status
    assigned savetnikId
    ceremony facts
    one general free-text napomena
    one payment note
    business version and modification metadata
    IRiU, contact, finance, identity, document and JSON inputs

CURRENT UI FACT:
    there is no standalone PREDMET segment named NAPOMENE
    general NAPOMENA is one free-text field inside ROBA I USLUGE
    NAPOMENA PLAĆANJA is a different free-text field inside FINANSIJE

PODSETNIK currently reads:
    PREDMET identity
    ceremony type, date, time and place
    PREDMET lifecycle eligibility

PODSETNIK currently persists:
    reminder enabled state per local PREDMET id
    selected delivery clock times
    scheduled platform notification identifiers
    technical update timestamp

PODSETNIK currently does not persist:
    organizational steps
    responsible person per step
    due date per step
    business completion
    confirmation history
    acknowledgement/postponement/dismissal state
```

## Current lifecycle boundary

```text
manual work cycle:
    OTVOREN -> ZATVOREN -> OTVOREN

automatic completion:
    IF ceremony date is before today
       AND status is not ZAVRŠEN or ANONIMIZOVAN:
        PREDMET repository sets status = ZAVRŠEN

PODSETNIK due-event eligibility:
    OTVOREN or ZATVOREN only

WHEN PREDMET becomes ZAVRŠEN:
    new due-event collection stops
    startup reminder reconciliation skips the PREDMET
    current source does not execute an explicit status-transition cancellation
    stored reminder configuration is not deleted

PODSETNIK must never set or independently determine PREDMET status
```

## Four state categories that must remain separate

```text
AUTHORITATIVE BUSINESS FACTS
    belong to the PREDMET domain
    candidate examples only, not approved fields:
        required step exists
        responsible user
        due time
        business state
        confirmed-by user and confirmed-at time
        relation to a PREDMET section

DERIVED CONTROL OBSERVATIONS
    calculated from current PREDMET facts and approved policy rules
    candidate examples only:
        ceremony approaching
        required data missing
        deadline overdue
        source ceremony term changed
    must not silently become an independent business record

TECHNICAL NOTIFICATION STATE
    belongs to PODSETNIK delivery infrastructure
    examples:
        platform notification id
        scheduled-at time
        cancellation/reschedule result
        permission state
        delivery attempt
    never proves business completion

USER INTERACTION STATE
    requires explicit semantic classification
    read != acknowledged != postponed != dismissed != confirmed complete
```

## Candidate user-confirmed completion path

```text
PROPOSED ARCHITECTURE - NOT IMPLEMENTED - OWNER DECISION REQUIRED

user selects CONFIRM COMPLETE from a PREDMET-level or PODSETNIK surface
    -> route command to the PREDMET application/domain boundary
    -> load authoritative PREDMET and structured control item
    -> validate current item state and owner-approved role rule
    -> record approved business completion facts and history in PREDMET domain
    -> apply approved PREDMET version/change-log semantics
    -> commit transaction
    -> refresh PODSETNIK projection from committed PREDMET truth
    -> cancel/reschedule only the related technical notification state

IF authoritative commit fails:
    do not mark the PODSETNIK item complete
    do not treat notification acknowledgement as completion
```

## Automatically derived warnings

```text
approved validation/rule reads current PREDMET
    -> derive warning key and explanation
    -> display through PODSETNIK

IF source fact becomes valid:
    warning disappears by derivation

IF user only acknowledges or dismisses warning:
    source business problem remains unresolved
    acknowledgement may suppress presentation only if owner approves
    acknowledgement must not change authoritative PREDMET facts

IF an exception/override has business meaning:
    it must be an explicit PREDMET-owned fact with history
    it must not live only in PODSETNIK notification metadata
```

## Manually created control steps

```text
PROPOSED TERM - NOT IMPLEMENTED - OWNER DECISION REQUIRED

manual organizational step is a business fact linked to one PREDMET
therefore its only authoritative copy belongs to the PREDMET domain

PODSETNIK may:
    list it
    filter and prioritize it
    group it by PREDMET or responsible user
    open its authoritative PREDMET location
    initiate a PREDMET-domain command
    deliver notifications

PODSETNIK may not:
    keep the only copy of the step
    keep the only completion status
    silently mutate PREDMET status
```

## Architecture options

```text
OPTION A - structured subsection under current note concept
    keeps free text and structured items visibly near one another
    risks overloading NAPOMENA meaning
    current source has no standalone NAPOMENE segment
    owner must first decide intended information architecture

OPTION B - new structured PREDMET segment
    keeps commentary separate from actionable business facts
    requires explicit schema, migration, JSON, version and UI decisions
    final segment name is not selected

OPTION C - PODSETNIK-owned operational tasks
    enables independent module iteration
    creates a high risk of a second business truth
    safe PODSETNIK ownership is limited to technical delivery/presentation state

OPTION D - hybrid
    PREDMET owns structured business-control steps and confirmation history
    PODSETNIK reads, derives, presents and delivers
    technical notification state remains PODSETNIK-owned
    audit recommendation only; owner approval is still required
```

## Package degradation

```text
POTPUN or SREDNJI:
    PODSETNIK module may be available

degrade to OSNOVNI:
    preserve every authoritative PREDMET control fact and history
    lock/hide PODSETNIK operational surfaces according to approved UX
    never delete PREDMET control data
    preserve user reminder configuration unless owner approves another policy
    decide whether technical notifications are cancelled or suspended

upgrade from OSNOVNI:
    re-read authoritative PREDMET facts
    re-derive current warnings
    restore module visibility
    reschedule only under an owner-approved technical policy

CURRENT SOURCE CONFLICT:
    module and PREDMET shortcut are entitlement-gated
    startup/resume reminder reconciliation and due dialog are not entitlement-gated
    this audit records the conflict and does not correct it
```

## UI responsibility map

```text
MODULI / PODSETNIK DASHBOARD
    may show today, overdue, upcoming, missing-data and confirmation views
    may group by PREDMET or responsible user
    must route business edits to PREDMET-domain commands

PREDMET-LEVEL TRACKING VIEW
    authoritative place for structured business steps
    may show source facts, manual obligations and completion history

CURRENT NAPOMENA OR FUTURE REPLACEMENT SEGMENT
    free text remains commentary
    structured actionable facts require a visually and semantically separate model
    final name and location require owner decision

NOTIFICATION ACTION
    tap may open OPC or an authoritative PREDMET view
    dismissal is not completion
    completion requires an explicit business action
```

## Smallest safe first phase

```text
RECOMMENDATION - NOT IMPLEMENTED - OWNER DECISION REQUIRED

after owner decisions are locked:
    introduce only PREDMET-owned manual structured steps
    provide explicit complete and reopen commands with history
    include approved version and JSON behavior
    expose a PREDMET-level editing surface
    allow PODSETNIK a read-only projection/open action

defer:
    automatic policy warnings
    status ZAVRSEN coupling
    notification completion actions
    postponement/escalation
    package-transition automation
    cross-device/Web behavior
```

## Unresolved owner decisions

```text
location and final name of structured steps
automatic versus manual step catalog
create/edit/confirm/reopen/override role matrix
responsible-user semantics
confirmation history and version semantics
JSON import/export behavior
relationship to ZAVRŠEN
notification action semantics
package downgrade scheduling behavior
meaning of the current NAPOMENA field
administrator notification content-control requirement
first implementation phase boundary
```
