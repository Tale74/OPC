# OPC TASK GH-001 — Public GitHub Foundation Report

Status: **BLOCKED — GITHUB AUTHENTICATION REQUIRED**

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

- Preferred repository URL: `https://github.com/Tale74/OPC`
- Preferred name availability check: no public repository was found at the preferred URL on June 20, 2026
- Visibility: intended public; repository creation is pending authenticated owner action
- First baseline commit: `520b189`
- First commit message: `chore: establish OPC public repository baseline`
- Current branch: `main`
- Remote: not configured
- Git status after baseline and validation: clean
- GitHub CLI: not installed
- In-app GitHub session: not authenticated

The repository was not created or pushed because the owner account could not be authenticated. No visibility setting was changed.

## Validation

- Candidate public-file review: 184 files accepted for the baseline
- Staged-file review: passed; no database, runtime-data, import-backup, log, local-properties, build, executable, installer, archive, secret-key, or excluded catalog-photo path was staged
- Staged secret-pattern scan: no match
- Staged user-profile/project absolute-path scan: no match
- `flutter analyze --no-pub`: passed, no issues found
- `flutter test --no-pub`: passed, 85 tests
- Build/package/signing checks: not run; outside this continuity task and may require release credentials or generated output
- Harmless rollback verification: passed
  - temporary branch: `verify/rollback-gh-001`
  - temporary commit: `1c0f59c`
  - switched back to `main`
  - confirmed clean `main`
  - deleted temporary branch

Tracked baseline summary:

- 184 files
- 66,446 inserted lines in the root baseline commit
- application source, Windows and Android runners, tests, safe assets, tools, and sanitized public documentation

## Logos links and access

Prepared links, not yet live:

- Repository: `https://github.com/Tale74/OPC`
- First commit: `https://github.com/Tale74/OPC/commit/520b189`
- First commit diff: `https://github.com/Tale74/OPC/commit/520b189`
- README: `https://github.com/Tale74/OPC/blob/main/README.md`
- Product direction: `https://github.com/Tale74/OPC/blob/main/docs/PRODUCT_DIRECTION.md`
- Architecture overview: `https://github.com/Tale74/OPC/blob/main/docs/ARCHITECTURE_OVERVIEW.md`
- Git/ARC workflow: `https://github.com/Tale74/OPC/blob/main/docs/GIT_WORKFLOW_ARC.md`
- Logos access test: `https://github.com/Tale74/OPC/blob/main/docs/LOGOS_ACCESS_TEST.md`

Logos access confirmation: cannot begin until repository creation and push are complete.

## Required owner action

1. Sign in to GitHub as `Tale74`.
2. Create a new repository named `OPC`.
3. Set visibility to **Public**.
4. Do not initialize it with a README, `.gitignore`, or license.
5. From this repository root run:

```powershell
git remote add origin https://github.com/Tale74/OPC.git
git push -u origin main
```

After the push, open the prepared links above and send the repository and `docs/LOGOS_ACCESS_TEST.md` links to Logos.

## Risks and unresolved decisions

- The catalog-photo files remain local because public redistribution rights were not established.
- Legacy continuity documents remain local because they contain machine-specific paths and historical local-environment details. The sanitized public continuity documents are under `docs/`.
- Public visibility cannot be considered complete until the repository is created, pushed, and Logos confirms direct access.
- This task must not be marked `PASS` in the current state.
