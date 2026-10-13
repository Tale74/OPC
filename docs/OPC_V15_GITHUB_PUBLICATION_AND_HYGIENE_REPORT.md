# OPC v1.5 GitHub publication and hygiene report — 2026-10-13

## Status

Final commit, push and remote verification status is recorded in the external
review handoff and must be updated here before closure publication. This file
does not treat historical HEAD/upstream equality as a push result.

## Publication controls

- Authoritative remote and branch must be verified from the live repository.
- Only an exact reviewed allowlist may be staged. `git add .`, reset, force
  push, history rewriting and deletion of uncertain files are forbidden.
- Private PREDMET/runtime evidence, local controls and full backup remain out
  of GitHub and the external review ZIP.
- Inspect staged names/diffs and scan for credentials/private records before
  committing. Push only if the remote can accept a normal fast-forward.
- If the remote is unavailable or divergent, report `LOCAL BASELINE COMPLETE /
  REMOTE PENDING` or `READY FOR OWNER DECISION`, with exact evidence.

The active-source control remains `20/28 LITERAL MATCH – 8/8 PROVENANCE
RESOLVED`; no manifest change or rebaseline is allowed by this closure.
