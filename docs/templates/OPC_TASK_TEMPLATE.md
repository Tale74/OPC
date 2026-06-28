# OPC Task Template

## Task

`OPC TASK TITLE`

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes / no

Task class:
- audit / design / spike / implementation / documentation / release / cleanup / tooling / process enforcement

Core purpose preserved:
- yes / no / risk

PREDMET meaning affected:
- no / yes, explain

Database ownership affected:
- no / yes, explain

JSON transfer affected:
- no / yes, explain

Windows/Android parity affected:
- no / yes, explain

Future Web Pristup affected:
- no / yes, explain

Terminology drift risk:
- no / yes, explain

Implementation allowed:
- yes / no

Required gate before implementation:
- none / manifest enforcement / repository identity / JSON safety / data ownership / platform parity / security / payment/legal / other

## Affected Boundary Checklist

- Application source logic: yes / no
- Database schema or migrations: yes / no
- JSON import/export or backup/restore: yes / no
- Web runner, backend, API, sync, or hosting: yes / no
- Storage adapter or browser storage: yes / no
- Payment, licence, entitlement, or package access: yes / no
- Product terminology or protected business terms: yes / no
- Documentation, workflow, or tooling only: yes / no

## GitHub-Aware Handoff Requirements

Every task handoff must include public GitHub links for:

- branch;
- final commit;
- relevant changed files;
- task report.

If GitHub visibility is required and public links are missing, the handoff is provisional and must not be marked PASS.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes / no

Core purpose preserved:
- yes / no

PREDMET meaning preserved:
- yes / no

Database ownership preserved:
- yes / no

Windows/Android parity preserved:
- yes / no

Existing JSON transfer preserved:
- yes / no

Terminology preserved:
- yes / no

Future Web Pristup not blocked:
- yes / no

Source changes within scope:
- yes / no

If not compliant, classify:
- NOT PASS

## PASS / NOT PASS Rule

PASS / NOT PASS:
- PASS / NOT PASS / PASS WITH PENDING REMOTE CI

No OPC task may be marked PASS if the start-check or end-compliance block is missing.

