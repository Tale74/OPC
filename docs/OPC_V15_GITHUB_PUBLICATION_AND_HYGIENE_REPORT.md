# OPC v1.5 GitHub publication and hygiene report — 2026-10-13

## Status

`PASS — NORMAL FAST-FORWARD PUSH VERIFIED`.

- Branch: `codex/opc-v1.5-clean-baseline`
- Commit: `a4f48ac5f6add623f66b3b422f93aaacf6a78527`
- Tree: `b65440468fb177b4aaf609a90e48908c3bd82750`
- Parent and pre-push remote HEAD: `c37b7d23541408414b6061e6cdb257039762ce43`
- Post-push `git ls-remote` returned the exact commit above.
- The commit contains exactly 85 reviewed allowlisted paths. No other
  pre-existing or unclassified worktree path was staged.
- Final local index is clean. Previously classified mixed-worktree paths
  remain preserved outside the commit.

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

The initial staging attempt was blocked by a zero-byte `.git/index.lock` with
last-write time 2026-10-04T19:02:03.2093758Z. No Git process held it and an
exclusive open check succeeded. After the failed staging attempt was verified
to have staged zero paths, the exact stale lock was removed to unblock the
authorized operation. It was not part of the baseline; no other lock or file
was removed as cleanup.

The active-source control remains `20/28 LITERAL MATCH – 8/8 PROVENANCE
RESOLVED`; no manifest change or rebaseline is allowed by this closure.
