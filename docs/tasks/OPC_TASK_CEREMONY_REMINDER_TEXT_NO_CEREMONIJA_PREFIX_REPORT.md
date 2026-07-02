# OPC Task Report — Ceremony Reminder Text Without CEREMONIJA Prefix

## Identity

- Base: `315829918d2bb05accc0ae8bbb93cbcb5d5003ad`
- Branch: `task/OPC-CEREMONY-REMINDER-TEXT-NO-CEREMONIJA-PREFIX`

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
- yes, safely through the existing shared builder

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

The shared builder is `lib/features/predmeti/reminders/ceremony_reminder_text.dart`. It previously emitted `CEREMONIJA (vrstaCeremonije) ZA ...`. Expectations were in `test/ceremony_reminder_system_test.dart`. Android notification scheduling calls the builder through `ceremony_reminder_coordinator.dart`; active Windows/Android dialogs and the Windows banner call it from `lista_predmeta_screen.dart`. Therefore one builder correction applies consistently and no scheduling change is needed. Old formula wording existed in `OPC-PSEUDO-033`, its index/safe-upgrade notes, and the prior correction report.

## Change

- Shared text now starts directly with exact `vrstaCeremonije`.
- Correct formula: `vrstaCeremonije ZA ime prezime PREMINULO LICE JE datumCeremonije U vremeCeremonije. DOVRŠITE NEOPHODNE PRIPREME.`
- Literal `CEREMONIJA` prefix is removed.
- Ceremony type, deceased full name, date, time, and preparation instruction remain.
- Windows and Android continue using the same builder.
- Focused expectations and all three required pseudocode documents were corrected under `OPC-PSEUDO-033`.
- The preceding task report was marked superseded for this formula only.

Scheduling windows, frequency, cancellation/replacement, past-time skip, persistence, permissions, Android configuration, Windows reminder behavior, GDPR startup retirement, and manual GDPR behavior are unchanged.

## Business meaning, risk, and boundary

The direct operational wording is `SAHRANA ZA...`, not `CEREMONIJA SAHRANA ZA...`. Blind changes could remove the actual type or diverge platforms. The safe boundary is builder text, tests, and documentation only.

## Validation

- Focused reminder tests: PASS, `+8`.
- Catalog/statistics regressions: PASS, `+5`.
- Full suite: PASS, `+98`.
- Static analysis: completed with only the inherited catalog unnecessary-import info; no new issue.
- Diff check and manifest gate: PASS.

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
