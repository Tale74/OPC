# OPC Task — GitHub Visibility Recovery Report

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Task class:
- documentation / repository continuity

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes, limited to GitHub visibility recovery and this report

Required gate before implementation:
- repository identity; passed

## Purpose and recovery identity

This task restores official GitHub visibility for two locally completed OPC
tasks. It validates repository continuity only; it does not validate or change
product behavior.

- Recovery branch: `task/OPC-GITHUB-VISIBILITY-RECOVERY`
- Recovery base: `f222a0981c07c6534ad3438834604ada6303dc65`
- Recovery final commit: `HEAD` — immutable hash is recorded in the final handoff
- Local repository: `C:\Projekti\OPC\OPC v.1\SOURCE`

## Remote identity

`git remote -v` returned:

```text
origin  https://github.com/Tale74/OPC.git (fetch)
origin  https://github.com/Tale74/OPC.git (push)
```

The configured Git transport URL with conventional `.git` suffix is the same
official repository as `https://github.com/Tale74/OPC`. Result: remote identity
PASS; no mismatch.

## Local investigation results

Starting branch:
`task/OPC-WINDOWS-RUNTIME-FAIL-CORRECTIONS-BEFORE-SMOKE`.

Starting `git status --short`: no output; clean.

| Check | Result |
|---|---|
| Grouped commit exists | PASS — type `commit` |
| Correction commit exists | PASS — type `commit` |
| Grouped local branch tip | `9b9f233e3e18a8bb13875a1fb03905651913193a` |
| Correction local branch tip | `f222a0981c07c6534ad3438834604ada6303dc65` |
| Grouped report tracked | PASS |
| Correction report tracked | PASS |
| Grouped commit contains grouped report | PASS |
| Correction commit contains correction report | PASS |
| Grouped branch existed on origin before recovery | no |
| Correction branch existed on origin before recovery | no |
| Unrelated uncommitted changes | none |

`git show --name-status --stat` confirmed that `9b9f233…` adds exactly the
grouped validation report. It confirmed that `f222a09…` contains the correction
report plus the intended reminder presentation/test/pseudocode changes.

## Recovery actions and push results

Executed without force:

```text
git push origin task/OPC-GROUPED-BUILD-WINDOWS-RUNTIME-VALIDATION
git push origin task/OPC-WINDOWS-RUNTIME-FAIL-CORRECTIONS-BEFORE-SMOKE
```

Both commands succeeded and created new remote branches.

Read-only remote verification:

```text
git ls-remote --heads origin task/OPC-GROUPED-BUILD-WINDOWS-RUNTIME-VALIDATION task/OPC-WINDOWS-RUNTIME-FAIL-CORRECTIONS-BEFORE-SMOKE
```

returned exact expected tips:

```text
9b9f233e3e18a8bb13875a1fb03905651913193a  refs/heads/task/OPC-GROUPED-BUILD-WINDOWS-RUNTIME-VALIDATION
f222a0981c07c6534ad3438834604ada6303dc65  refs/heads/task/OPC-WINDOWS-RUNTIME-FAIL-CORRECTIONS-BEFORE-SMOKE
```

## GitHub URLs

### Grouped build/runtime validation

- Branch: `https://github.com/Tale74/OPC/tree/task/OPC-GROUPED-BUILD-WINDOWS-RUNTIME-VALIDATION`
- Final commit: `https://github.com/Tale74/OPC/commit/9b9f233e3e18a8bb13875a1fb03905651913193a`
- Report: `https://github.com/Tale74/OPC/blob/task/OPC-GROUPED-BUILD-WINDOWS-RUNTIME-VALIDATION/docs/tasks/OPC_TASK_GROUPED_BUILD_WINDOWS_RUNTIME_VALIDATION_REPORT.md`

### Windows runtime FAIL corrections before smoke

- Branch: `https://github.com/Tale74/OPC/tree/task/OPC-WINDOWS-RUNTIME-FAIL-CORRECTIONS-BEFORE-SMOKE`
- Final commit: `https://github.com/Tale74/OPC/commit/f222a0981c07c6534ad3438834604ada6303dc65`
- Report: `https://github.com/Tale74/OPC/blob/task/OPC-WINDOWS-RUNTIME-FAIL-CORRECTIONS-BEFORE-SMOKE/docs/tasks/OPC_TASK_WINDOWS_RUNTIME_FAIL_CORRECTIONS_BEFORE_SMOKE_REPORT.md`

### Recovery report

- Recovery branch: `https://github.com/Tale74/OPC/tree/task/OPC-GITHUB-VISIBILITY-RECOVERY`
- Recovery report: `https://github.com/Tale74/OPC/blob/task/OPC-GITHUB-VISIBILITY-RECOVERY/docs/tasks/OPC_TASK_GITHUB_VISIBILITY_RECOVERY_REPORT.md`

The recovery branch/report URLs become verifiable after this report commit is
pushed. The final handoff records the resulting commit URL and verification.

## Commands run

Required investigation commands:

- `git status --short`
- `git branch --show-current`
- `git remote -v`
- `git branch --list`
- `git branch -r`
- `git cat-file -t 9b9f233e3e18a8bb13875a1fb03905651913193a`
- `git cat-file -t f222a0981c07c6534ad3438834604ada6303dc65`
- `git branch --contains 9b9f233e3e18a8bb13875a1fb03905651913193a`
- `git branch --contains f222a0981c07c6534ad3438834604ada6303dc65`
- `git ls-files docs/tasks/OPC_TASK_GROUPED_BUILD_WINDOWS_RUNTIME_VALIDATION_REPORT.md`
- `git ls-files docs/tasks/OPC_TASK_WINDOWS_RUNTIME_FAIL_CORRECTIONS_BEFORE_SMOKE_REPORT.md`
- `git show --name-status --stat 9b9f233e3e18a8bb13875a1fb03905651913193a`
- `git show --name-status --stat f222a0981c07c6534ad3438834604ada6303dc65`

Additional identity/verification commands:

- `git rev-parse` for both local and remote branch tips
- `git cat-file -e <commit>:<report-path>` for both reports
- both required non-force `git push origin <branch>` commands
- `git ls-remote --heads origin <both-branches>`

No destructive Git command, force push, merge, main update, PR, build, test,
analyzer, or runtime command was used.

## Scope confirmation

- Product source changes: none.
- Application test changes: none.
- Build/runtime/smoke: not performed.
- Previous task reports: not rewritten.
- Official documentation change: this Git-tracked recovery report only.
- Generated artifacts/private files: none added.

## Final classification

`GITHUB VISIBILITY RECOVERED — TWO PREVIOUS TASKS OFFICIALLY VERIFIABLE`

This classification requires successful push and visibility of this recovery
report too; final remote verification is recorded after its commit/push.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes; recovery report only

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS
