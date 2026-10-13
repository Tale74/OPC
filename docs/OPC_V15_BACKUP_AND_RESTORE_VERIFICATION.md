# OPC v1.5 closure backup and restore verification — 2026-10-13

## Result

`BACKUP VERIFIED — FULL RESTORE FIDELITY PASS`.
Backup creation and verification preceded documentation, worktree, index or
Git changes for this closure.

The complete project/worktree backup is on the owner-controlled local system,
outside SOURCE and the public repository, under a protected sibling directory
named `OPC_v1.5_OWNER_CLOSURE_BACKUP_20261013`. The full path and recovery
procedure are retained in the local-only backup evidence, not published here.
The backup includes the project including Git metadata, modified and
untracked worktree content, and two external task/guide inputs.

## Inventory and integrity

- Pre-backup inventory: 5,825 directories, 15,202 regular files, 12 symlinks;
  regular-file total 2,555,016,389 bytes.
- Inventory SHA-256:
  `176A2142F0D216F81669B9C69DF192742E93D11DBF1C03E0E5255399369C193C`.
- Backup verification at `2026-10-13T04:56:36.9837639Z`: 15,202/15,202
  regular files matched; zero project mismatches.
- Initial restore test at `2026-10-13T05:09:20.1526494Z`: 15,202/15,202
  original regular files restored and hash-matched; zero project mismatches.
  The restored project byte total was 2,624,443,872.
- The 12 Windows Flutter plugin symlinks point into the local Pub cache.
  Windows error 1314 initially prevented recreating symlink objects. Their
  target directories were materialized as regular directories in the backup
  and initial restore test; all 3,285 target files matched recorded hashes,
  with zero mismatch. The original link/target mapping is recorded in the local-only
  materialization manifest (SHA-256
  `5691B73D4C38CAF20FDF84C2A755A440FB0B334C65C9ECAF3848F3AAA04D0CB3`).
- Supplemental isolated restore-fidelity test at
  `2026-10-13T06:04:19.8820864Z` copied the verified restore to a separate
  temporary location, preserved all 3,285 materialized target files, and
  recreated all 12 symlink objects using their exact recorded target paths.
  The complete comparison matched 18,487/18,487 regular files
  (15,202 project files plus 3,285 target files), 12/12 symlink object types
  and target mappings, with zero missing files or mismatches. The exact
  temporary path and machine-readable result are retained in the protected
  local backup evidence. The initial limitation is resolved by this test.
- Both external OWNER inputs were copied and hash-verified in the backup:
  closure task 12,677 bytes, SHA-256
  `BAD10EE0F62837E571534F55C77136E1C06253AA47CA6A98C79AE6C784EB51F6`; 33
  chapter guide proposal 27,409 bytes, SHA-256
  `36DE4EE1C17B132D97D7D8EEB344D69E7EA6C37C6A4D3CDEA53D4E1D5F3A6508`.
- Backup root ACL is limited to the owner account, SYSTEM and Administrators.

No backup bytes, runtime database, credential or private record is included in
the public source baseline or external review ZIP. Detailed per-file evidence
remains in the protected local backup.
