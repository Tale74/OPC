# OPC Task Template

## Task

`OPC TASK TITLE`

## OWNER CONFIRMATION GATE - PHASE 0

### TASK UNDERSTANDING CONFIRMATION

Restate the intended outcome, scope, non-goals, locked owner decisions,
required evidence and stop conditions in the model's own words.

Verdict:

`TASK UNDERSTANDING - CONFIRMED / NOT CONFIRMED`

### CONTINUITY ESTABLISHMENT CONFIRMATION

Record the public branch/HEAD, predecessor task/report chain, relevant incident
lineage, zero-baseline transition, current business model, technical debt and
unresolved gates. Do not reason from the latest report alone.

The current generic IRiU business invariant is:

```text
IRiU = ordered OSNOVNI PAKET
       -> ordered applied SCENARIO PAKET
       -> manual/unpredicted items
```

Package contents are editable. Concrete item names, persisted order,
provenance, source output and golden fixtures are not business authority.

Verdict:

`PROJECT CONTINUITY - ESTABLISHED / NOT ESTABLISHED`

### DOCUMENTATION READING CONFIRMATION

List every relevant document actually read and classify it as current owner
authority, permanent incident evidence, active governance/continuity,
historical task evidence, pre-zero evidence, technical source-learning
evidence or future-scope evidence. Record conflicts plainly.

Verdict:

`AUTHORITATIVE DOCUMENTATION READ - CONFIRMED / NOT CONFIRMED`

### Required stop

After the three confirmations, output exactly:

`OWNER CONFIRMATION GATE - WAITING FOR EXPLICIT CONTINUE`

Do not edit, implement, test, build, commit or push until the owner explicitly
responds with `CONTINUE`, `APPROVED - CONTINUE`, `NASTAVI` or an equivalent
unambiguous authorization. If the owner corrects any confirmation, revise it
and stop again.

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

## Successive Validation / Build Gate

Follow the authoritative procedure in
[`docs/GIT_WORKFLOW_ARC.md`](../GIT_WORKFLOW_ARC.md#authoritative-successive-validation-and-build-gate).

- `flutter analyze` final PASS: yes / no / not applicable
- complete `flutter test` started only after analyze PASS: yes / no / not applicable
- complete `flutter test` final PASS: yes / no / not applicable
- build started only after both final PASS results: yes / no / not applicable
- any timeout/hang/incomplete result honestly classified as NOT PASS: yes / no / not applicable

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
