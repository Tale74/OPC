# OPC Context Harness V1

Minimal, removable development harness. It is not an OPC runtime dependency and does not define business policy.

## Build bounded context

```powershell
.\tools\opc_context\build_context.ps1 `
  -TaskName "OPC-example-task" `
  -Keywords "PREDMET","SAVETNIK","json import"
```

Optional bounded Repomix pack:

```powershell
.\tools\opc_context\build_context.ps1 `
  -TaskName "OPC-example-task" `
  -Keywords "PREDMET","SAVETNIK" `
  -UseRepomix
```

The script records the current dirty/clean worktree as baseline; it does not require or manufacture a clean tree.

## Validate context

```powershell
.\tools\opc_context\validate_context.ps1 `
  -ManifestPath "..\REVIEW\CURRENT_TASK\OPC-example-task\context\CONTEXT_MANIFEST.json"
```

## QA evidence format

Completion validation requires an explicit mode on every task:

`REQUIRED` means Flutter analyzer and full-test evidence are mandatory (and
serialized ordering is enforced). `NOT_APPLICABLE` is permitted only for
development-control/documentation/harness-only work and requires a written
reason in `qa/flutter_qa_mode.json`.

`qa/flutter_qa_mode.json`:

```json
{
  "mode": "NOT_APPLICABLE",
  "reason": "Harness-only evidence correction; no Flutter/product/build surface changed."
}
```

Create these outside SOURCE under the task review root:

`qa/flutter_analyze.json`

```json
{
  "command": "flutter analyze",
  "startedAt": "2026-08-23T10:00:00+02:00",
  "endedAt": "2026-08-23T10:20:00+02:00",
  "exitCode": 0,
  "status": "PASS",
  "summary": "No issues found."
}
```

`qa/flutter_test_full.json` uses the same structure. `qa/build.json` is needed when completion validation is called with `-RequireBuild`.

## Validate completion

```powershell
.\tools\opc_context\validate_completion.ps1 `
  -TaskReviewRoot "..\REVIEW\CURRENT_TASK\OPC-example-task" `
  -FlutterQaMode "REQUIRED" `
  -RequireBuild
```

For a bounded harness/documentation-only task:

```powershell
.\tools\opc_context\validate_completion.ps1 `
  -TaskReviewRoot "..\REVIEW\CURRENT_TASK\OPC-example-task" `
  -FlutterQaMode "NOT_APPLICABLE"
```

This validates the explicit mode/reason, context manifest, review index, JSON
evidence, Git state and boundaries. In `REQUIRED` mode it also requires
`flutter_analyze.json` and `flutter_test_full.json`, preserves their serialized
ordering checks, and requires `build.json` when `-RequireBuild` is supplied.
It does not replace HUMAN GATE, owner authority or Logos review.
