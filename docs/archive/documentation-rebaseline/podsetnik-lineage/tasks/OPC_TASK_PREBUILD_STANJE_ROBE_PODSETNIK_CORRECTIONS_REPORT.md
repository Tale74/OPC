# OPC Task — Pre-Build STANJE ROBE / Podsetnik Corrections Report

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Task class:
- implementation / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no; shared settings/navigation behavior only

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes, limited to entitlement-aware module visibility and reminder navigation

Required gate before implementation:
- platform parity / product terminology / payment-access-entitlement; passed

## Task identity

- Branch: `task/OPC-PREBUILD-STANJE-ROBE-PODSETNIK-CORRECTIONS`
- Base commit: `7b8f864fb7cfdec13522a6800a076b2b62421490`
- Final commit: `HEAD` — immutable hash is recorded in the Codex handoff because a commit cannot contain its own hash

## Source-learning summary

### STANJE ROBE

- `lib/core/entitlements/opc_entitlement_policy.dart` defines package/module
  availability. STANJE ROBE belongs to `POTPUN`; `SREDNJI` can receive it only
  through the explicit STANJE ROBE add-on. `Osnovni` is not entitled.
- `lib/core/database/tables/app_podesavanja_table.dart` persists
  `stanjeRobeOperativnoOmoguceno` with database default `false`.
- `lib/core/database/database.dart` also seeds/migrates that setting to `false`.
- `lib/features/podesavanja/data/podesavanja_repository.dart` watches, reads,
  and writes the persisted active-use choice.
- `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`
  combines entitlement with the persisted choice and produces `notLicensed`,
  `disabled`, or `active`.
- `lib/features/podesavanja/presentation/podesavanja_screen.dart` already owns
  an ADMINISTRATOR switch and stock-management action under `PODEŠAVANJA → MODULI`.
  Non-admin users see status but cannot control it.
- `lib/features/stanje_robe/presentation/stanje_robe_admin_screen.dart`, PREDMET
  list/screen, IRiU segment/rows/repository, and lifecycle services consume the
  combined availability rather than package presence alone.

### Podsetnik

- `lib/features/predmeti/presentation/lista_predmeta_screen.dart` owned the
  overflow item, which was unconditionally `enabled: false` and had no value,
  callback, or route. This was a stale/unfinished presentation placeholder.
- `lib/features/predmeti/presentation/predmet_screen.dart` owns the logical
  CEREMONIJA section and already supported analogous initial navigation to
  DOKUMENTI.
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart` is the
  existing reminder settings entry point. It owns enablement and delivery-time
  controls and delegates to the existing repository/coordinator.
- `lib/features/predmeti/reminders/ceremony_reminder_model.dart`,
  `ceremony_reminder_repository.dart`, `ceremony_reminder_coordinator.dart`,
  `ceremony_notification_gateway.dart`, and `ceremony_reminder_text.dart`
  preserve reminder data, occurrence calculation, delivery, and text.

## Exact source paths inspected

- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/core/database/tables/app_podesavanja_table.dart`
- `lib/core/database/database.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/features/podesavanja/presentation/podesavanja_screen.dart`
- `lib/features/podesavanja/presentation/katalog_tab.dart`
- `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`
- `lib/features/stanje_robe/application/stanje_robe_lifecycle_service.dart`
- `lib/features/stanje_robe/presentation/stanje_robe_admin_screen.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_model.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_repository.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_coordinator.dart`
- `lib/features/predmeti/reminders/ceremony_notification_gateway.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/lista_predmeta_screen_smoke_test.dart`
- existing reminder and package tests and related pseudocode/index entries

## Diagnosis before fix

### STANJE ROBE

The missing runtime toggle under active package `Osnovni` was caused by
entitlement: source exposes STANJE ROBE only for `POTPUN` or the explicit
`SREDNJI` add-on. The existing ADMINISTRATOR switch was correct but lived under
the `MODULI` settings tab, and that complete tab was hidden when unentitled.
Therefore source entitlement and active-use behavior agreed, but the UI gave an
Osnovni ADMINISTRATOR no visible explanation of the locked feature.

Default active use is OFF in schema, migration/seed behavior, repository tests,
and operational availability. Entitlement never forces it ON. An entitled
ADMINISTRATOR can control it; a SAVETNIK cannot. The exact UI path is
`PODEŠAVANJA → MODULI → STANJE ROBE`.

### Podsetnik

The menu item was disabled by a literal hard-coded flag, not by ceremony data,
status validation, or reminder architecture. The existing safe target is the
CEREMONIJA section, where reminder settings already live. A shortcut can open
that section without changing reminder configuration or scheduling.

Incomplete ceremony data remains safe: navigation succeeds, existing fields
remain available for completion, and existing reminder occurrence logic does
not schedule without valid ceremony date/time. Reminder enablement and delivery
times remain exclusively in CEREMONIJA. Anonymized PREDMET records keep the
shortcut disabled, and the existing Podsetnik entitlement remains required.

## Implemented corrections

### STANJE ROBE result

`MODULI` is now always visible as a settings information/control surface.

- `Osnovni`/unentitled context: STANJE ROBE appears as locked/not licensed;
  there is no ON/OFF switch and no stock-management action.
- entitled non-admin context: status is visible, but no switch/action is shown.
- entitled ADMINISTRATOR context: the existing persisted ON/OFF switch and
  existing stock-management action are visible.
- default and stored active-use behavior remain OFF unless explicitly enabled.

No package definition, stock effect, catalog item, or persistence semantics
changed.

### Podsetnik shortcut result

The PREDMET-list overflow item now:

- is enabled only when `OpcModule.podsetnik` is entitled and the PREDMET is not
  anonymized;
- opens the existing PREDMET screen with CEREMONIJA initially selected;
- performs no reminder mutation during navigation;
- reuses existing CEREMONIJA settings, validation, repository, coordinator,
  scheduling, and notification delivery.

## Exact source paths changed

- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/lista_predmeta_screen_smoke_test.dart`

## Business meaning and risk control

STANJE ROBE remains a package-controlled operational feature whose availability
does not imply active use. The explicit ADMINISTRATOR choice remains persisted
and defaults OFF. Podsetnik becomes only a faster route to the formal CEREMONIJA
settings surface; it does not become parallel reminder truth. PREDMET remains
master business truth for ceremony facts.

Risks of package leakage, forced activation, non-admin control, duplicate
reminder logic, invalid scheduling, and anonymized-data access are controlled by
the existing entitlement/role/availability layers, locked-state presentation,
entitlement-aware shortcut condition, anonymized-state exclusion, and direct
reuse of CEREMONIJA.

## Safe upgrade boundary

The task changes only settings-section visibility, existing module locked-state
exposure, PREDMET-list shortcut enablement/navigation, focused tests, and
learning-layer documentation. It does not change PDF, JSON, PREDMET facts,
reminder scheduling/delivery/business logic, stock consequences, catalog items,
packages, roles, Android-specific code, Windows runner, or exit behavior.

## Pseudocode / Logos learning layer

- `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md` describes package
  availability, default OFF, visible locked state, ADMINISTRATOR control,
  operational consumption, shortcut enablement, CEREMONIJA target, incomplete
  data behavior, and protected reminder logic.
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md` adds the focused source-to-learning
  entry and corrects the existing PDF logo index dimension to the already
  completed `192 × 120 pt` baseline.
- This task report records diagnosis, implementation, and validation evidence.

## Validation

- First focused test attempt: NOT PASS due solely to the new test importing
  `flutter/widgets.dart` while referencing `Icons`; corrected to
  `flutter/material.dart`.
- Repeated focused command:
  `flutter test test/lista_predmeta_screen_smoke_test.dart test/stanje_robe_operational_toggle_test.dart`
  — PASS, all 28 focused tests.
- `flutter analyze` — PASS, `No issues found!` in 32.0 seconds; zero errors,
  warnings, lints, or info findings.
- `flutter test` — PASS, all 112 tests.
- Manifest gate: PASS — one changed task report validated against base commit
  `7b8f864fb7cfdec13522a6800a076b2b62421490`.

## Build/runtime status

- Windows build: not run.
- Android build: not run.
- Runtime validation: not run.
- STANJE ROBE runtime PASS: not claimed.
- Podsetnik runtime PASS: not claimed.
- Runtime review is still required.

Status:

`SOURCE/TEST PASS — BUILD DEFERRED BY OWNER DECISION — RUNTIME REVIEW REQUIRED LATER`

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS
