# OPC Task Report - Manifest Automated Enforcement

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- tooling / process enforcement

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

Future Web Pristup affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes, tooling-only

Required gate before implementation:
- manifest enforcement

## Why Enforcement Was Needed

The purpose and anti-drift manifest was mandatory as process documentation, but it was not technically enforced.

The new gate adds a first automatic check so changed OPC task reports must contain both the task-start manifest check and task-end manifest compliance block before a task can be treated as passing.

## Files Added

- `docs/templates/OPC_TASK_TEMPLATE.md`
- `scripts/validate_opc_manifest_gate.py`
- `.github/workflows/opc-manifest-gate.yml`
- `docs/tasks/OPC_TASK_MANIFEST_AUTOMATED_ENFORCEMENT_REPORT.md`

## Files Updated

- `docs/GIT_WORKFLOW_ARC.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

## How The Script Works

`scripts/validate_opc_manifest_gate.py` compares the current branch against a base ref and validates changed Markdown task reports under `docs/tasks/`.

For every changed report, it requires:

- `OPC MANIFEST CHECK — TASK START`
- `OPC MANIFEST COMPLIANCE — TASK END`
- `Manifest read:`
- `Manifest compliance checked:`
- `PASS / NOT PASS:`

If any checked report is missing a required string, the script prints the failing file and missing strings, then exits with a non-zero code.

## How GitHub Actions Uses It

`.github/workflows/opc-manifest-gate.yml` runs on `push` and `pull_request`.

The workflow checks out full history and runs:

```bash
python scripts/validate_opc_manifest_gate.py
```

The workflow passes the event base through `OPC_MANIFEST_GATE_BASE` so the script validates reports changed by the branch/event.

## Legacy Reports

Historical reports created before manifest enforcement are not blindly failed.

The gate validates task reports changed in the current branch compared to the selected base ref. This keeps legacy reports readable while requiring all new or modified reports to carry the manifest blocks.

A documented legacy marker exists in the script for exceptional historical cases:

```text
OPC_MANIFEST_GATE_LEGACY_EXEMPTION
```

## Future Task Compliance

Future OPC tasks must start from `docs/templates/OPC_TASK_TEMPLATE.md` or include equivalent manifest blocks.

No OPC task may be marked PASS if the manifest start-check or manifest end-compliance block is missing from its task report.

## Not Changed

No application source logic was changed.

No database schema, migrations, web runner, backend/API, sync, storage adapter, payment/subscription implementation, package restructuring, or business terminology rename was added.

## Known Risks

The gate validates changed task reports only. It does not parse every handoff message outside the repository.

The workflow result is pending until GitHub Actions runs on the pushed branch.

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
- yes

If not compliant, classify:
- NOT PASS

## PASS / NOT PASS:

PASS WITH PENDING REMOTE CI
