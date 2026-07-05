# OPC Task — Windows Runtime FAIL Corrections Before Smoke Report

## OPC MANIFEST CHECK — TASK START

Manifest read: yes

Task class:
- implementation / test / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no; shared Flutter presentation and existing shared policies only

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes, limited to shortcut proof/readability presentation and tests

Required gate before implementation:
- platform parity / product terminology / entitlement-access; passed

## Task identity

- Branch: `task/OPC-WINDOWS-RUNTIME-FAIL-CORRECTIONS-BEFORE-SMOKE`
- Base commit: `9b9f233e3e18a8bb13875a1fb03905651913193a`
- Final commit: `HEAD` — immutable hash is recorded in the Codex handoff because a commit cannot contain its own hash

## Source-learning paths inspected

- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/core/database/tables/app_podesavanja_table.dart`
- `lib/core/database/database.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/features/podesavanja/presentation/podesavanja_screen.dart`
- `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`
- `lib/features/stanje_robe/presentation/stanje_robe_admin_screen.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_model.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_repository.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_coordinator.dart`
- `lib/features/predmeti/reminders/ceremony_notification_gateway.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/lista_predmeta_screen_smoke_test.dart`
- `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md`
- `docs/tasks/OPC_TASK_PREBUILD_STANJE_ROBE_PODSETNIK_CORRECTIONS_REPORT.md`
- `docs/tasks/OPC_TASK_GROUPED_BUILD_WINDOWS_RUNTIME_VALIDATION_REPORT.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

## Diagnosis before correction

### STANJE ROBE

Package entitlement is decided by `OpcEntitlementPolicy.isModuleAvailable`:
`POTPUN` is eligible, and `SREDNJI` is eligible only with the explicit add-on.
`Osnovni` is not eligible. MODULI visibility is separately always true.

`PodesavanjaScreen._ModuliTab` checks `session.jeAdmin`. The switch is rendered
only when the user is ADMINISTRATOR and operational status is not
`notLicensed`. The stock-management action uses the same role/licence boundary.
Osnovni receives `notLicensed`, the locked status/explanation, no switch, and no
action.

The persisted setting is a Drift boolean defaulting to `false`; repository
watch/read/write methods preserve the explicit choice. Entitlement does not
write or force the setting. Existing tests already prove default OFF, persisted
ON/OFF, Osnovni lock, POTPUN ADMINISTRATOR switch/action, and SAVETNIK
restriction.

Conclusion: there is no STANJE ROBE source bug or missing source-test path. The
owner's Osnovni evidence is PASS. POTPUN remains missing owner runtime proof,
not source behavior. No product source change was invented.

### Podsetnik shortcut

The overflow menu is built by `_TileActions` in
`lista_predmeta_screen.dart`. Its visible Podsetnik item receives
`canOpenPodsetnik`. That value requires `OpcModule.podsetnik` entitlement and a
status other than `ANONIMIZOVAN`.

`OpcModule.podsetnik` is available to `SREDNJI` and `POTPUN`, not `Osnovni`.
Therefore the owner-observed grey item under active package Osnovni is expected,
not a stale disable flag. Ceremony completeness, existing reminder events,
role, and optional ceremony fields are not shortcut eligibility conditions.

The callback opens the existing `PredmetScreen` with `openCeremony: true`,
selecting the existing CEREMONIJA section. CEREMONIJA remains the only reminder
settings flow and continues to use the existing repository/coordinator/gateway.
No second flow exists or was introduced.

## Corrections and proof

### STANJE ROBE

No STANJE ROBE product source changed. Existing focused tests were rerun and
continue to prove:

- MODULI/locked explanation with no switch/action under Osnovni;
- POTPUN ADMINISTRATOR active and disabled states both render the switch;
- default OFF and persisted ON/OFF behavior;
- entitlement does not force ON;
- SAVETNIK receives no switch/action;
- stock business consequences remain unchanged.

### Podsetnik shortcut

The existing eligibility expression was extracted into
`podsetnikShortcutEnabled` and reused by the overflow menu, making the business
condition directly testable without changing it.

Coverage now proves:

- POTPUN non-anonymized PREDMET has an enabled item;
- selecting it opens existing CEREMONIJA reminder settings;
- the test PREDMET has incomplete ceremony data, proving safe navigation;
- Osnovni is disabled by entitlement;
- anonymized PREDMET is disabled even under POTPUN;
- existing reminder events are not an eligibility input;
- no duplicate settings/model/scheduling flow was added.

### Reminder dialog readability

The existing `Podsetnik za ceremoniju` dialog now renders due events through a
bounded `CeremonyReminderEventList` instead of joining all text with newlines.
Each event has:

- 10-point separation from the next event;
- its own padded, rounded, outlined row;
- alternating `surfaceContainerLow` / `surfaceContainerHigh` theme colors;
- scroll-bounded height for larger event sets.

Reminder text and ordering are unchanged. Scheduling, persistence,
notification, delivery, event identity, and ceremony facts are unchanged. A
widget test verifies distinct alternating theme surfaces without brittle pixel
or golden assertions.

## Exact changed files

Source:

- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`

Tests:

- `test/lista_predmeta_screen_smoke_test.dart`

Pseudocode/docs:

- `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/tasks/OPC_TASK_WINDOWS_RUNTIME_FAIL_CORRECTIONS_BEFORE_SMOKE_REPORT.md`

## Business meaning, risks, and safe boundary

STANJE ROBE remains a POTPUN-controlled operational feature whose entitlement
does not imply active use. Podsetnik remains an operational shortcut to
CEREMONIJA rather than a second reminder truth. PREDMET remains master truth for
ceremony data.

Risks addressed are false package leakage, forced stock activation, unsafe
anonymized access, over-strict ceremony completeness checks, duplicate reminder
architecture, and unreadable multiple-event dialog text. Controls remain the
existing package policy, role checks, persisted default OFF, anonymized status
check, existing CEREMONIJA route, and theme-provided surfaces.

No PDF polish, package policy, stock consequences, reminder scheduling,
delivery, persistence, business logic, PREDMET truth, JSON, finance, Android
runtime, Windows runtime, build, slow-exit work, or regression Tačka 4 was
performed.

## Commands and results

Targeted validation:

- Initial focused runs exposed test-only pending Drift timer cleanup; product
  assertions reached the expected states. Cleanup was made explicit inside the
  navigation test.
- `flutter test test/lista_predmeta_screen_smoke_test.dart test/stanje_robe_operational_toggle_test.dart`
  — `PASS`, all 31 focused tests.

Required final validation:

- `flutter analyze` — `PASS`, `No issues found!`, zero errors/warnings/lints/info
  findings (283.9 seconds).
- `flutter test` — `PASS`, all 115 tests (previous count 112 plus three focused
  shortcut/readability cases).
- Windows/Android builds: not run by task instruction.
- Windows/Android runtime: not launched by task instruction.

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

## Final status

`SOURCE/TEST PASS — READY FOR OWNER-AUTHORIZED RUNTIME SMOKE`

Runtime PASS is not claimed.
