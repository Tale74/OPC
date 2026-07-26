# OPC Task Report — Gate 0 PODSETNIK orphan reference audit

Status: `DOCS-ONLY ROOT-CAUSE AUDIT COMPLETE — IMPLEMENTATION NOT AUTHORIZED`

Date: 2026-07-26

Base branch: `task/OPC-GATE-0-PREDMET-LIFECYCLE-LOG-RETENTION-AUDIT`

Base SHA: `3a893b2b868036128f9b71f01086753a0a989bc0`

Task branch: `task/OPC-GATE-0-PODSETNIK-ORPHAN-REFERENCE-AUDIT`

Final SHA: supplied by the Git completion response after commit and push.

## Scope

Code-first diagnosis and technical correction boundary for a PODSETNIK
reference/notification that survives deletion of its authoritative PREDMET.

## Source inspected

- `lib/core/database/database.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_repository.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_coordinator.dart`
- `lib/features/predmeti/reminders/ceremony_notification_gateway.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/core/utils/json_export_import.dart`
- relevant PODSETNIK, migration and backup tests
- resolved local dependency source for Drift, `drift_flutter` and
  `flutter_local_notifications` 22.0.1

## Result

- confirmed that foreign-key cascade is declared but runtime enforcement is
  not enabled/proven;
- confirmed explicit PREDMET deletion omits reminder settings;
- confirmed Android pending notifications are never cancelled on deletion;
- confirmed startup/resume cannot discover existing OS or SQLite orphans;
- confirmed full restore neither transfers nor clears/rebuilds reminder state;
- defined one deletion orchestrator, idempotent recovery, payload guard and
  logical-config-only backup behavior;
- separated this technical integrity correction from later PODSETNIK business
  tracking decisions.

## Published files

New:

- `docs/OPC_PODSETNIK_ORPHAN_REFERENCE_ROOT_CAUSE_AND_RECOVERY_AUDIT.md`
- `docs/tasks/OPC_TASK_GATE_0_PODSETNIK_ORPHAN_REFERENCE_AUDIT_REPORT.md`

Updated:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`
- `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`
- `docs/OPC_DOCUMENTATION_SEMANTIC_OWNER_DECISION_QUEUE.md`
- `docs/OPC_PODSETNIK_CONTROL_FLOW_AND_USER_CONFIRMATION_PSEUDOCODE.md`

## Controls

Pre-commit controls:

- docs-only diff: PASS;
- no deletion and no application/source/test/schema/migration/build diff: PASS;
- `git diff --check`: PASS;
- .NET UTF-8/no-BOM verification for all six documents: PASS;
- privacy/sensitive-data scan: PASS;
- no private absolute local path in the published diff: PASS;
- relative Markdown reference verification: PASS.

The Git completion response records commit/push/origin parity, clean worktree
and public Git retrieval.

## Stop boundary

No application source, schema, migration, test, JSON, backup, build or runtime
behavior was changed. Implementation requires a separate owner-approved task.
