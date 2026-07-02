# OPC Task Report — Ceremony Reminder Notification Text Correction

## Identity

- Base: `b2e7e967c184afbaf262e0b8b5ae0033b8e32ac1`
- Branch: `task/OPC-CEREMONY-REMINDER-NOTIFICATION-TEXT-CORRECTION`

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no; existing identity fields are now rendered correctly

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- yes, safely: all reminder surfaces share one formula

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes

Required gate before implementation:
- platform parity

Manifest read: YES

## Source learning and diagnosis

- Android local notification text was composed in `lib/features/predmeti/reminders/ceremony_reminder_coordinator.dart` as case number plus term.
- Active Windows/Android dialog text was independently composed in `lib/features/predmeti/presentation/lista_predmeta_screen.dart` as case number plus date/time.
- Windows banner content came from `ReminderMvpEntry` in `reminder_mvp_service.dart` and `_WindowsReminderLine` in `lista_predmeta_screen.dart`.
- Authoritative PREDMET fields are `vrstaCeremonije`, `ime`, `prezime`, `datumCeremonije`, and `vremeCeremonije`, declared in `lib/core/database/tables/predmeti_table.dart` and available as `PredmetiData`.
- The unauthorized omission rule appeared in the coordinator test, `OPC-PSEUDO-033`, safe-upgrade notes, and the preceding task report.
- Scheduling windows, frequency, persistence, cancellation, permissions, and GDPR behavior required no change.

## Changes

- Added `lib/features/predmeti/reminders/ceremony_reminder_text.dart` as the single text builder.
- Android local notifications, active Windows/Android dialogs, and Windows banner details now use that builder.
- `ReminderMvpEntry` carries source `ime`, `prezime`, and `vrstaCeremonije` directly rather than reconstructing identity.
- Coordinator inputs now carry the five authoritative source fields.
- Focused tests assert the complete formula and remove the revoked omission assertion.
- Corrected `OPC-PSEUDO-033`, its index/safe-upgrade learning layer, and the preceding report language.

Exact formula:

Superseded formula correction: reminder text now starts directly with `vrstaCeremonije`; the literal `CEREMONIJA` prefix is removed by the owner follow-up task.

PREMINULO LICE full name is explicitly included as owner-required PREDMET business identity. No implementation-invented privacy filtering remains.

Scheduling remains unchanged: 2/1/0-day window, hourly frequency choices, future-only occurrences, cancellation/replacement dedupe, persistence, Android permissions/configuration, and session dialog dedupe. GDPR startup retirement and manual GDPR preservation are unchanged.

## Business meaning, risk, and boundary

The user must know which ceremony/PREDMET a reminder concerns. Omitting PREMINULO LICE identity makes the operational reminder ambiguous.

Blind changes could retain unauthorized filtering, use the wrong identity/type fields, diverge Windows and Android text, or accidentally alter scheduling/GDPR behavior.

The safe boundary is text composition, direct source-field plumbing, focused tests, and documentation correction only. No reminder architecture, PREDMET semantics, GDPR flow, or unrelated module changed.

## Pseudocode

- Corrected `OPC-PSEUDO-033 — Ceremony reminder model for Windows dialogs and Android local notifications`.
- Corrected all three required Logos learning-layer documents.

## Validation

- Focused reminder tests: PASS, `+8`.
- Catalog/statistics regressions: PASS, `+5`.
- Full Flutter suite: PASS, `+98`.
- Static analysis: completed with only the inherited `iriu_row_tile.dart` unnecessary-import info; no new issue.
- `git diff --check`: PASS.
- Manifest gate: PASS.

## Runtime/build

Runtime/build: NOT REQUESTED / NOT PRODUCED

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
