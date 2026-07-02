# OPC Task Report — Date Input Calendar Picker Dialog

## Identity

- Base: `930a3ad0ea43668cc233b065f4109acebd4331bf`
- Branch: `task/OPC-DATE-INPUT-CALENDAR-PICKER-DIALOG`

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- yes, safely through shared Flutter fields and picker

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes

Required gate before implementation:
- platform parity

Manifest read: YES

## Source learning, diagnosis, and implementation

Manual fields were `DATUM ROĐENJA` and `DATUM SMRTI` in `preminulo_lice_segment.dart`, plus `DATUM CEREMONIJE` in `ceremonija_segment.dart`. They were controller-backed `TextFormField`s accepting typed text and normalizing through `parseDateInput`/`normalizeCeremonyDateInput`. Statistics custom dates in `izvestaji_screen.dart` already used `showDatePicker` and were intentionally unchanged. Technical/database timestamps and non-UI date values were also excluded.

The three scoped fields are now read-only for typing and open `showDatePicker` on tap. Cancel returns without mutation. Selection uses `formatCalendarPickerSelection` in `app_date_format.dart`, producing `DD.MM.YYYY` for birth/death and preserving ceremony's existing `DD.MM.YYYY.` representation. Existing controllers and autosave receive the same text type. Clear actions remain available. Windows and Android share the behavior.

Changed files: `app_date_format.dart`, `preminulo_lice_segment.dart`, `ceremonija_segment.dart`, focused test, and required pseudocode/docs.

No storage model, PDF, JSON, validation policy, business logic, reminder scheduling/text, or GDPR behavior changed.

## Business meaning, risk, and boundary

Calendar selection is faster and less error-prone. Blind changes could mutate stored/output format or reminder inputs. The safe boundary is UI input method and existing formatting only.

## Pseudocode

- Added `OPC-PSEUDO-034 — Calendar picker date input with preserved Serbian date format` and all required cross-references.

## Validation

- Focused date test: PASS, `+1`.
- Focused regressions: PASS, `+14` total including date/reminder/catalog/statistics.
- Full suite: PASS, `+99`.
- Analysis: inherited catalog info only; no new issue.
- Diff/manifest: PASS.

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
