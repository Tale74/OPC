# OPC Incident and Anti-Drift Register

**Status:** `ACTIVE PERMANENT EVIDENCE`
**Baseline:** OPC post-zero authority established 2026-07-29

This register preserves confirmed or materially relevant incidents without
reviving pre-zero owner decisions as current business authority.

## INC-001 — unauthorized IRiU basic/scenario ordering change

- Date introduced: 2026-07-17.
- Confirmed regression commit:
  `c6fae079482097231f4513f683367d30f4e13f58`.
- Detection/owner classification: 2026-07-28.
- Status at zero baseline: present in the functional baseline; correction is
  deliberately assigned to the future configurable-SCENARIO upgrade.
- Incident: an authorized KATALOG capability allowing user-defined basic IRiU
  categories was expanded into an unauthorized change that moved
  scenario-dependent rows before the existing basic block.
- Protected boundary: a technical implementation or test cannot change
  PREDMET-owned business behavior without owner authority.
- Required future invariant: `SANDUK` and the complete applicable basic IRiU
  block precede scenario-dependent IRiU rows.
- Prevention:
  - keep KATALOG basic-category policy separate from SCENARIO predicates and
    lifecycle;
  - require source-to-business impact review before changing ordering;
  - never treat a changed test and technical PASS as retroactive owner
    approval;
  - preserve the incident in migration and SCENARIO acceptance coverage.
- Historical evidence remains in Git history under
  `docs/tasks/OPC_TASK_IRIU_BASIC_SCENARIO_ORDER_REGRESSION_AUDIT_REPORT.md`.

## INC-002 — reported Windows Administrator persistence/identity anomaly

- Reported symptom: an expected Administrator was not visible and a `TEST`
  user appeared in an affected Windows runtime.
- Audit result: client symptom was not locally reproduced.
- Confirmed facts:
  - file-backed close/reopen preserved an Administrator in audit fixtures;
  - no production source path creating `TEST` was found;
  - `TEST` can appear if it already exists as an active row in the opened DB;
  - multiple plausible Windows database lanes/profiles can exist.
- Root cause: unproven.
- Status: evidence warning, not an authorized correction.
- Prevention:
  - identify the exact opened database lane before identity recovery;
  - collect copy-only path/build/database evidence;
  - never replace or merge canonical data based on schema/version assumptions;
  - do not attribute identity loss to presentation/licensing mode without
    evidence.
- Historical evidence remains in Git history under
  `docs/tasks/OPC_TASK_WINDOWS_ADMIN_PERSISTENCE_INCIDENT_AUDIT_REPORT.md`.

## Permanent anti-drift rules

- A task report, test or technical PASS does not authorize a business change.
- PREDMET authority and derivative boundaries are checked before every change.
- Existing functional zero-baseline behavior is preserved unless an approved
  prospective upgrade explicitly changes it.
- Incident correction records the source commit, migration effect, validation
  and owner runtime acceptance separately.
- Public incident records contain no private local path, credentials, personal
  data or canonical database content.

