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

## INC-003 — schema-8 backup rejects exported orphan reminder rows

- Detected: 2026-07-30 during owner Android full-restore acceptance.
- Introduced compatibility boundary:
  `1adbb05260e245dbac7c72dfb6cb0db133e0110e`.
- Runtime result: Android full restore `FAIL`; import stopped before destination
  mutation with a reminder-section safety error.
- Confirmed backup metadata:
  - format `OPC_BACKUP`, schema 8;
  - 46 PREDMET rows and 9 logical reminder rows;
  - 2 reminder rows reference no exported PREDMET;
  - 0 invalid row/type/time/duplicate/device-ID-key findings.
- Additional isolated-preflight finding:
  - after reminder compatibility was corrected, referential validation exposed
    6 of 230 `logIzmena` rows without a PREDMET carried by the same backup;
  - this is a second transfer-ownership manifestation inside INC-003, not a
    confirmed live-database repair or migration requirement;
  - the supplied backup contains 224 PREDMET-owned log rows that remain
    transferable.
- Confirmed root cause:
  - schema-8 export selects every row from FK-off
    `ceremony_reminder_settings`, including pre-existing orphans;
  - schema-8 import correctly requires every reminder to reference a transferred
    PREDMET and therefore rejects the same application-produced backup.
- Protected boundary: PREDMET remains authoritative. An orphan derivative must
  not make a valid PREDMET backup unrestorable and must not be silently attached
  to a reused local ID.
- Current safety result: destination data was not changed because validation
  stopped before the restore transaction.
- Implemented bounded correction:
  - export filters reminder and change-history derivatives against the exact
    captured set of exported PREDMET IDs;
  - import fully validates each row before skipping only a row whose parent is
    absent from the backup; malformed rows remain blocking;
  - destination IDs cannot validate or reattach a backup orphan through local
    ID reuse;
  - destination platform IDs, including IDs held by an orphan row, are
    scoped-cancelled; rollback compensation rebuilds only configured reminders
    owned by an existing old PREDMET;
  - there is no live cleanup, relinking, FK enablement, migration or canonical
    database mutation.
- Correction evidence on 2026-07-31:
  - supplied-backup isolated preflight: 46 PREDMETI; reminders 9 total, 7
    PREDMET-owned, 2 skipped; history 230 total, 224 PREDMET-owned, 6 skipped;
    referential check clean;
  - active reminder trigger at the recorded preflight moment: 0;
  - 3 future platform delivery slots were correctly rebuilt under policy 3A;
    future scheduling is not a claim that a trigger is active now;
  - focused, failure/rollback, reused-ID, schema-7 and 4A evidence passes;
  - final analyze and complete tests pass;
  - owner-provided Windows and Android release builds pass on the final
    correction SHA; artifact presence was verified in the expected output paths.
- Status at correction close: technical correction PASS. The owner subsequently
  reported a scoped Android full-restore runtime PASS: the unsafe reminder
  section error did not recur, PREDMETI/PARTE loaded, and observed completed
  PREDMET data/history remained intact. Other data/security coverage was not
  tested. This runtime evidence is separate from technical PASS and does not
  pre-accept the later PARTE Gate-1 tip.
- No private backup content, identifiers, local path or screenshot is retained
  in Git.

## Permanent anti-drift rules

- A task report, test or technical PASS does not authorize a business change.
- PREDMET authority and derivative boundaries are checked before every change.
- Existing functional zero-baseline behavior is preserved unless an approved
  prospective upgrade explicitly changes it.
- Incident correction records the source commit, migration effect, validation
  and owner runtime acceptance separately.
- Public incident records contain no private local path, credentials, personal
  data or canonical database content.
