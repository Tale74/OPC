# OPC task report — explicit ZAVRŠEN and immutable completion

**Status:** `IMPLEMENTATION PASS; OWNER RUNTIME ACCEPTANCE DEFERRED`

**Date:** 2026-08-01

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES

PASS / NOT PASS: PASS

## Owner decision and scope

The owner confirmed the lifecycle rule:

`OTVOREN → ZATVOREN → ZAVRŠEN`

Automatic completion based on the ceremony date is retired. `ZAVRŠEN` is set
only by an explicit user action after `ZATVOREN`, and no direct edit or reopen
is allowed afterwards. Ceremony date, reminder state and derivative output do
not infer completion. GDPR anonymization remains a separate controlled
lifecycle operation.

## Protection and Git boundary

- Branch: `task/OPC-PHASE3-LIFECYCLE-COMPLETION-CHARACTERIZATION`
- Pre-change source/documentation SHA: `df9ed68229401a4cd6829a31ab1e1f5a957f2d50`
- Implementation commit: `8b60fc7`
- Protected backup:
  `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_EXPLICIT_ZAVRSEN_20260801_1600.zip`
- Backup SHA-256:
  `E7A9D66ED3224CF24AFF8770368F01E1F1FBF3826A62A21C9795710234E2524D`
- Restore marker: `docs/tasks/OPC_RESTORE_POINT_PRE_EXPLICIT_ZAVRSEN_20260801.md`
- No canonical database, live backup, migration or Git history rewrite was used.

## Implemented source contract

- Removed the automatic date-based status rule and both startup/open invocations.
- Retained compatibility methods as no-ops so stale callers cannot mutate
  status.
- Added `PredmetiRepository.zavrsiPredmet`, allowed only from `ZATVOREN`.
- Added one lifecycle audit event for explicit completion.
- Guarded `ZAVRŠEN` against direct update, save, close and reopen paths.
- Added confirmation and explicit actions in the PREDMET screen; the final
  state is visibly locked.
- Preserved existing/imported `ZAVRŠEN` and `ANONIMIZOVAN` rows.

## Focused evidence

- `test/predmet_completion_state_characterization_test.dart`: 5/5 PASS.
- Combined restore/lifecycle/JSON/PARTE/UI regression run: 82/82 PASS.
- `flutter analyze --no-pub`: PASS, no issues.
- Build was intentionally deferred to the cumulative Windows/Android runtime
  gate requested by the owner.

## Completion gate

Final status is complete only after the implementation commit is pushed, the
task report is in Git, final/local and origin SHAs are recorded, and the
worktree is clean. Technical PASS and owner Windows/Android runtime acceptance
remain separate.
