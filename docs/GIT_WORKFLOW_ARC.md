# Git Workflow and ARC Continuity

## Stable baseline

`main` is the stable baseline branch. It must remain buildable and reviewable. Direct functional work should not begin from a dirty working tree.

Every task starts with:

```powershell
git status
```

Every OPC task must also read [OPC Purpose and Anti-Drift Manifest](OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md) before work starts and must emit the manifest task-start check block defined there. If the manifest is not read, the task must not proceed.

Manifest checking is also tooling-enforced for changed task reports by `scripts/validate_opc_manifest_gate.py` and the `OPC Manifest Gate` GitHub Actions workflow. A task report missing the manifest start-check or end-compliance block must be treated as NOT PASS.

## Authoritative successive validation and build gate

This section is the single permanent workflow authority for OPC validation
before any Windows or Android build.

For every task that changes source, tests, generated source, schema/migrations,
assets, runtime configuration, or build configuration, run these gates strictly
one after the other:

1. Run `flutter analyze` and wait for its final summary and exit code.
2. Only after a conclusive analyzer PASS, run the complete `flutter test` suite.
3. Wait for the complete suite's final summary and exit code.
4. Only after both commands conclusively PASS is the build gate open.
5. Only then may an authorized Windows or Android build start.

`flutter analyze` and `flutter test` must never overlap, run concurrently, run
in parallel terminals, or run through overlapping tool calls. A timeout, hang,
interruption, incomplete log, or missing exit code is not PASS. Focused or
partial tests are useful diagnostics but never replace the complete
`flutter test` gate.

A build produced before both green gates is a `SUPERSEDED PRE-GATE BUILD
ARTIFACT` and is not accepted for runtime validation or final task evidence.
After any further source/test/generated/configuration change, both gates must be
run again in the same order before another build. Documentation-only tasks that
change none of those surfaces use documentation/repository checks and do not
need to repeat Flutter validation.

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

No OPC task may be marked PASS if the task report fails the manifest gate validation.

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
