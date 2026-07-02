# OPC Task Report — Ceremony Reminder System And GDPR Startup Dialog Off

## Identity

- Base: `6673ebe2ef0fcd7a76a5a3148c5f75edac1f24aa`
- Branch: `task/OPC-CEREMONY-REMINDER-SYSTEM-GDPR-STARTUP-DIALOG-OFF`
- Class: implementation

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no; reminders derive from existing ceremony facts

Database ownership affected:
- no; reminder state remains in the same local OPC database

JSON transfer affected:
- no; operational reminder settings are intentionally not transferred

Windows/Android parity affected:
- yes, safely: both receive the shared reminder model; Android additionally uses OS-local notifications

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes, explicitly owner-approved after the preceding blocker

Required gate before implementation:
- platform parity and local persistence boundary

Manifest read: YES

Required manifest, workflow, pseudocode documents, and the two latest task reports were read before changes.

## Source learning and diagnosis before fix

- GDPR startup source: `_runStartupSideEffects` called `_gdprCheck` in `lib/features/predmeti/presentation/lista_predmeta_screen.dart`. `_gdprCheck` queried `PredmetiRepository.getZavrseneZaGdpr` and displayed two route-level `AlertDialog`s for tomorrow/available eligibility.
- Manual GDPR sources: `_anonimizuj` in `lista_predmeta_screen.dart` and `_anonimizuj` in `lib/features/predmeti/presentation/predmet_screen.dart`, backed by `PredmetiRepository.anonimizujPredmet`. These manual paths, confirmations, text, export choice, eligibility, and data remain.
- GDPR retirement method: the startup call and private startup-dialog method were removed. `automaticGdprStartupDialogEnabled == false` and the manual status helper are focused-test assertions.
- Existing reminder source: `lib/features/predmeti/reminders/reminder_mvp_service.dart` derived eligible `OTVOREN`/`ZATVOREN` cases from `datumCeremonije` and returned entries for 2, 1, or 0 days. `lista_predmeta_screen.dart` showed them only in `_WindowsReminderBanner`; Android received an empty list.
- Existing behavior was an in-app Windows banner, not push/local notification. No Android notification package, permission, initialization, scheduler, cancellation, or persistence existed.
- Ceremony UI/source: `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`; fields are `PredmetiData.datumCeremonije` and `vremeCeremonije`, saved through `PredmetiCompanion` and `PredmetiRepository.azurirajPredmet`.
- Persistence decision: reminder enabled/frequency/scheduled IDs use local `ceremony_reminder_settings`, keyed by local `predmet_id`. This is operational state linked to PREDMET, not ceremony truth. PREDMET remains authoritative for the term.
- JSON impact: none. The raw operational table is not part of PREDMET JSON/export/import and does not change transfer identity or conflict behavior.
- Android capability: newly added `flutter_local_notifications`, `flutter_timezone`, and `timezone`; Android boot receiver configuration reschedules plugin alarms after reboot/package replacement. There is no Firebase or remote push.
- Duplicate policy: coordinator reads stored IDs, cancels all, computes replacement future occurrences, schedules them, and stores replacement IDs. Local notification IDs deterministically hash local PREDMET id plus scheduled instant and have local-only meaning.
- Change policy: ceremony date/time autosave and reminder configuration changes call the same rescheduler; list startup/resume also reconciles all eligible cases.
- Past policy: occurrences at or before `now` are skipped; expired ceremonies schedule nothing. In-app dialog uses the current frequency slot and a session key, so reopening/rebuilding does not repeat that slot.

## Implementation

- `lib/core/database/database.dart`: schema 18; creates local `ceremony_reminder_settings` on create/upgrade/before-open.
- `lib/features/predmeti/reminders/ceremony_reminder_model.dart`: enabled/frequency configuration, allowed frequencies `1, 2, 3, 4, 6, 8, 12, 24`, 48-hour occurrence calculation, past filtering, local IDs, and active dialog slot.
- `ceremony_reminder_repository.dart`: local configuration and scheduled-ID persistence.
- `ceremony_reminder_coordinator.dart`: cancel/replace scheduling, owner-approved PREDMET identity content, and ceremony date/time parsing.
- `ceremony_notification_gateway.dart`: Android-only local plugin initialization, device timezone, notification permission, inexact idle scheduling, private lock-screen visibility, cancellation, and local channel.
- `ceremonija_segment.dart`: compact enable switch and frequency dropdown adjacent to ceremony date/time; configuration changes and date/time changes reschedule.
- `lista_predmeta_screen.dart`: removes automatic GDPR dialogs; preserves manual GDPR; reconciles notifications on startup/resume; shows one session-deduped Windows/Android in-app reminder dialog for active slots. Existing Windows banner remains.
- `android/app/src/main/AndroidManifest.xml`: boot permission and scheduled-notification receivers. Exact-alarm permission is not requested because scheduling uses `inexactAllowWhileIdle`.
- `pubspec.yaml`, `pubspec.lock`, generated Windows plugin registration: maintained local-notification/timezone dependencies.
- `test/ceremony_reminder_system_test.dart`: 2/1/0 default, multiple hourly deliveries, past skip, disabled state, cancel/replace dedupe, owner-approved identity content, and GDPR startup/manual preservation.

Default 24-hour frequency exactly represents 2 days before, 1 day before, and ceremony time. The minimum 1-hour choice caps one case at 49 occurrences across the 48-hour window, avoiding unbounded scheduling.

Corrected by the owner follow-up task: notification content uses exact ceremony type, PREMINULO LICE full name, ceremony date/time, and the preparation instruction. The earlier omission of deceased identity was unauthorized and is revoked.

## Business meaning, risk, and boundary

Ceremony reminders are operational helpers for time-critical work. They never replace PREDMET/CEREMONIJA facts. Automatic GDPR interruption is retired while explicit legal/data handling remains available.

Blind changes could delete manual GDPR, create duplicate/stale alarms, spam past reminders, expose personal data, misuse local IDs as cross-device identity, or add backend drift.

The safe boundary is local reminder configuration, local scheduling/cancellation, and in-app presentation. PREDMET identity/lifecycle, ceremony meaning, GDPR legal/data behavior, IRiU, PARTA, catalog, statistics, finance, PDF, JSON, Web, sync, package, payment, and licensing are unchanged.

## Pseudocode

- `OPC-PSEUDO-032 — GDPR startup dialog retirement and manual GDPR preservation`
- `OPC-PSEUDO-033 — Ceremony reminder model for Windows dialogs and Android local notifications`
- Updated all three required pseudocode learning-layer documents.

## Validation

- `flutter test test/ceremony_reminder_system_test.dart`: PASS, `+7`, including real in-memory persistence.
- Catalog/statistics focused regressions: PASS, `+5`.
- `flutter test --reporter compact`: PASS, `+97`.
- `flutter analyze`: completed with exactly one inherited informational item in unchanged `iriu_row_tile.dart` (`dart:typed_data` unnecessary); no new warning/error.
- `git diff --check`: PASS; line-ending conversion warnings only.
- `python scripts\validate_opc_manifest_gate.py --base 6673ebe2ef0fcd7a76a5a3148c5f75edac1f24aa`: PASS.

## Runtime/build

Runtime/build: NOT REQUESTED / NOT PRODUCED

No Windows or Android artifact was built.

## Confirmations

- PREDMET remains master business truth and ceremony facts were not redefined.
- Manual GDPR remains; only automatic startup dialogs are disabled.
- Android notifications are local OS notifications, not remote push.
- Windows/Android in-app dialogs use the same frequency-slot model.
- Duplicate replacement and past-time skip are deterministic and tested.
- Reminder content includes the owner-required PREMINULO LICE identity and ceremony facts without adding fields outside the approved formula.
- No remote push/backend dependency or unrelated module behavior was introduced.
- No unresolved placeholders remain.

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

Manifest compliance checked: YES

PASS / NOT PASS: PASS WITH PRE-EXISTING ANALYZE INFO.
