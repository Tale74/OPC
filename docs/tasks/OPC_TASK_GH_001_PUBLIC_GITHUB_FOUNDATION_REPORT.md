# OPC TASK GH-001 — Public GitHub Foundation Report

Status: **IN PROGRESS — LOCAL SAFETY BASELINE PREPARED**

## Scope

- Public repository root: `.`
- Local absolute workspace path is intentionally not committed; it is recorded in the private task handoff.
- Project: OPC only
- Functional application changes: none
- Database schema changes: none
- UI changes: none

## Inventory

Observed public-source areas:

- Flutter/Dart application source under `lib/`
- Windows runner under `windows/`
- Android runner under `android/`
- tests under `test/`
- safe application icons, fonts, and symbols under `assets/`
- packaging/preparation utilities under `tools/`
- Flutter manifests and dependency lock files

Observed local, generated, private, or ambiguous areas excluded from Git:

- `runtime_data/opc_v4.sqlite`
- `_IMPORT_TEST_INPUTS/` local backup/import JSON files
- `build/`
- `.dart_tool/`
- `windows/flutter/ephemeral/`
- `android/.gradle/`
- `android/local.properties`
- `android/hs_err_pid9816.log`
- root `flutter_*.log` files
- generated executables, APKs, installers, archives, and exports
- legacy `PROJECT_DOCS/`, root audit/restore Markdown, and restore markers containing machine-specific paths
- `assets/katalog_foto/`, whose public redistribution status is not established

## Repository hygiene

`.gitignore` was expanded for the actual OPC tree and for generic protection against runtime databases, secrets, signing files, local configuration, generated business documents, build products, IDE state, logs, crash dumps, and distributable packages.

Required candidate-file, staged-file, tracked-file, secret-pattern, and machine-path checks will be recorded after Git initialization.

## Documentation

Created or updated:

- `README.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/ARCHITECTURE_OVERVIEW.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/LOGOS_ACCESS_TEST.md`
- `docs/tasks/OPC_TASK_GH_001_PUBLIC_GITHUB_FOUNDATION_REPORT.md`

## Git and GitHub

- Repository URL: pending
- Visibility: intended public; pending creation
- First baseline commit: pending
- Current branch: pending
- Remote: pending
- Git status: pending

## Validation

- Candidate public-file review: pending
- Staged-file review: pending
- `flutter analyze`: pending
- `flutter test`: pending
- Harmless rollback verification: pending

## Logos links and access

Direct GitHub links: pending repository push.

Logos access confirmation: pending.

## Risks and unresolved decisions

- The catalog-photo files remain local because public redistribution rights were not established.
- Legacy continuity documents remain local because they contain machine-specific paths and historical local-environment details. The sanitized public continuity documents are under `docs/`.
- Public visibility cannot be considered complete until the repository is pushed and Logos confirms direct access.
