# Git Workflow and ARC Continuity

## Stable baseline

`main` is the stable baseline branch. It must remain buildable and reviewable. Direct functional work should not begin from a dirty working tree.

Every task starts with:

```powershell
git status
```

Every OPC task must also read [OPC Purpose and Anti-Drift Manifest](OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md) before work starts and must emit the manifest task-start check block defined there. If the manifest is not read, the task must not proceed.

## Task branches

Use one branch per future task:

```text
task/OPC-XXX-short-description
```

Branch from the current approved `main`. Keep unrelated work out of the branch.

## Commit discipline

- Make focused commits with descriptive imperative messages.
- Do not commit real databases, case/customer data, exports, logs, secrets, signing material, machine-local configuration, caches, or build products.
- Review `git status`, staged names, and the staged diff before every commit.
- Do not mix functional refactoring with infrastructure or documentation tasks.
- Record validation honestly; a skipped or unavailable check is not a pass.

## Codex handoff

Every future OPC Codex task ends with:

```text
Task:
Branch:
Base commit:
Final commit:
GitHub commit/PR link:
Changed files:
Diff stat:
Tests/checks:
Build:
Report path:
Not touched:
Known risks:
PASS / NOT PASS:
```

The handoff must also include the manifest end-compliance block defined in [OPC Purpose and Anti-Drift Manifest](OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md). PASS is not allowed unless manifest compliance is checked and reported.

Before handoff run:

```powershell
git status
git diff --stat <base>..<final>
git diff --name-only <base>..<final>
git log --oneline -5
```

## Logos review

Logos reviews through direct public GitHub links to the repository, commit or pull request, relevant source files, and task report. A task that requires Logos visibility is not complete until direct access is confirmed.

## Rollback

For an unmerged task branch, switch to `main` and delete the task branch only after confirming no required uncommitted work remains.

For an already merged or pushed change, prefer a new revert commit:

```powershell
git switch main
git pull --ff-only
git revert <commit>
git push
```

Do not rewrite shared `main` history. Before rollback, record the target commit and verify the resulting diff and application checks.
