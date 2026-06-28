# OPC Task Report - Purpose and Anti-Drift Manifest Repo Integration

## Task

OPC PURPOSE AND ANTI-DRIFT MANIFEST REPO INTEGRATION

## Base

Base branch: `origin/main`

Base commit: `80294ea`

## Initial Local Checks

`git status --short --branch`:

```text
## task/OPC-DATABASE-FIRM-IDENTITY-AND-JSON-SAFETY-AUDIT...origin/task/OPC-DATABASE-FIRM-IDENTITY-AND-JSON-SAFETY-AUDIT
```

`git fetch origin`:

```text
Completed successfully.
```

`git log --oneline -5`:

```text
3018b09 docs: add OPC database identity safety audit
80294ea docs: confirm Logos GitHub visibility
f74638d docs: record OPC GitHub push verification
07c61c1 docs: finalize GH-001 local foundation report
520b189 chore: establish OPC public repository baseline
```

`git log --oneline -5 origin/main`:

```text
80294ea docs: confirm Logos GitHub visibility
f74638d docs: record OPC GitHub push verification
07c61c1 docs: finalize GH-001 local foundation report
520b189 chore: establish OPC public repository baseline
```

## Manifest Added

Added `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`.

The manifest defines mandatory project rules for:

- OPC core purpose.
- Product identity.
- `PREDMET` as master business truth.
- User/firma ownership of the database.
- Local Windows/Android model.
- Future OPC Web Pristup model.
- Terminology protection.
- Mandatory task-start manifest invocation block.
- Mandatory task-end manifest compliance block.
- Mandatory special gates.
- Codex and Logos responsibility.
- GitHub-aware verification.

## Docs Updated

Updated `docs/GIT_WORKFLOW_ARC.md` so every OPC task must:

- Read the manifest before work starts.
- Emit the manifest task-start check block.
- Include the manifest end-compliance block in the final handoff.
- Avoid PASS unless manifest compliance is checked and reported.

Updated `README.md` with:

- A manifest link.
- A Web Pristup description aligned with the manifest.

Updated `docs/ARCHITECTURE_OVERVIEW.md` with:

- A requirement that architecture work comply with the manifest.

Updated `docs/PRODUCT_DIRECTION.md` with:

- Web Pristup wording that avoids treating Windows/Android as subordinate products.

## Future Invocation

Every future OPC task must start by reading `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` and must include this block:

```text
OPC MANIFEST CHECK - TASK START
Manifest read: YES / NO
Manifest path:
Core purpose preserved: YES / NO / N/A
Product identity preserved: YES / NO / N/A
PREDMET master truth preserved: YES / NO / N/A
User/firma database ownership preserved: YES / NO / N/A
Local Windows/Android parity preserved: YES / NO / N/A
Future Web Pristup constraints respected: YES / NO / N/A
Terminology protected: YES / NO / N/A
Special gates triggered:
Decision:
```

## Future Handoffs

Every future OPC task handoff must include the manifest compliance block:

```text
OPC MANIFEST COMPLIANCE - TASK END
Manifest read at start: YES / NO
Manifest path:
Files changed:
Core purpose preserved: YES / NO / N/A
Product identity preserved: YES / NO / N/A
PREDMET master truth preserved: YES / NO / N/A
User/firma database ownership preserved: YES / NO / N/A
Local Windows/Android parity preserved: YES / NO / N/A
Future Web Pristup constraints respected: YES / NO / N/A
Terminology protected: YES / NO / N/A
Special gates triggered:
Special gates satisfied: YES / NO / N/A
GitHub verification status:
PASS allowed: YES / NO
```

## Not Changed

No source code was changed.

No web runner, backend, API, sync, storage adapter, migrations, payment/subscription system, or package restructuring was added.

No architecture migration was opened.

No build, runtime, database, or business logic files were changed.

## Known Risks

The manifest is a documentation/process guard. It does not technically enforce task-start or task-end checks by itself.

Some existing public documentation may still contain legacy wording outside the files touched in this task.

## Tests/checks

Not run - documentation-only task; no source/test/build files changed.

## Build

Not run - documentation-only task; no source/test/build files changed.

## PASS / NOT PASS

PASS
