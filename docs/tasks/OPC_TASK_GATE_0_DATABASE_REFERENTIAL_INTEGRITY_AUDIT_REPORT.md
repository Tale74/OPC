# OPC Task Report — Gate 0 database referential-integrity audit

Status: `DOCS-ONLY CODE/FIXTURE AUDIT COMPLETE — IMPLEMENTATION NOT AUTHORIZED`

Date: 2026-07-26

Base branch: `task/OPC-GATE-0-PODSETNIK-ORPHAN-REFERENCE-AUDIT`

Base SHA: `86687c53dec1d0ccf0b2a89b1c23d54f9140c804`

Task branch: `task/OPC-GATE-0-DATABASE-REFERENTIAL-INTEGRITY-AUDIT`

Final SHA: supplied by the Git completion response after commit and push.

## Scope

One complete foundational audit unit:

- SQLite FK enforcement;
- PREDMET dependency inventory;
- delete/anonymize/replacement/full-restore lifecycle;
- orphan/privacy evidence;
- safe progressive-refactor sequence;
- PODSETNIK post-signal revisit gate.

## Executed evidence

External synthetic fixture, outside Git:

```text
flutter test --no-pub <external-audit-fixture>
```

PASS evidence:

```text
foreign_keys=0
remaining_reminder_rows=1
remaining_parte_rows=1
foreign_key_violations=2
reminder_ids=[201,202]
parte_contains_jmbg=true
log_contains_jmbg=true
```

No real PREDMET/person data was used.

## Result

- actual FK-off runtime confirmed;
- declared FK and logical-reference map completed;
- hard-delete orphan PARTE/reminder defects confirmed;
- anonymization PII retention in reminder/PARTE/raw log confirmed;
- replacement stale-derivative gaps identified;
- full-restore stale contact/IRiU/reminder reassociation risk identified;
- staged lifecycle/recovery/FK-enforcement order defined;
- current codebase retention plus progressive refactor recommended;
- full rewrite not supported by this evidence;
- PODSETNIK informed-reminder work explicitly deferred until complete signal
  inventory and owner business confirmation.

## Published files

New:

- `docs/OPC_DATABASE_REFERENTIAL_INTEGRITY_AND_PREDMET_DEPENDENCY_AUDIT.md`
- `docs/OPC_PREDMET_DEPENDENT_DATA_LIFECYCLE_MATRIX.md`
- `docs/tasks/OPC_TASK_GATE_0_DATABASE_REFERENTIAL_INTEGRITY_AUDIT_REPORT.md`

Updated:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`
- `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`
- `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`
- `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md`

## Controls

Pre-commit controls:

- docs-only Git diff: PASS;
- no application/test/schema/migration/runtime change: PASS;
- external fixture absent from Git diff: PASS;
- `git diff --check`: PASS;
- .NET UTF-8/no-BOM verification for all seven documents: PASS;
- privacy/sensitive-data scan: PASS;
- no private absolute local path or synthetic probe identifier/value in public
  documents: PASS;
- relative Markdown reference verification: PASS.

The Git completion response records commit/push/origin parity, clean worktree
and public Git retrieval.

## Stop boundary

No implementation is authorized. The external fixture remains outside the Git
repository and is not application/test-source modification.
