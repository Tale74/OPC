# OPC Task Report - Local Project Documentation Inventory and Continuity Audit

## Executive conclusion

Local OPC documentation is materially larger than the GitHub-visible documentation set.

The GitHub-visible repo currently contains the new manifest/workflow baseline, but important continuity material still exists only locally in ignored or outside-repo folders. The highest-value local sources are `PROJECT_DOCS`, especially architecture decisions, locked rules, project flow/delta, backup/restore policy, Codex rules, and project map files.

No local private/export JSON was opened or committed. This report is a metadata and continuity audit only.

Overall classification: PASS WITH PRIVATE DOCS EXCLUDED.

## Manifest check

OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- documentation inventory / continuity audit

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
- yes, documentation continuity only

Terminology drift risk:
- yes, if local docs are ignored or superseded incorrectly

Implementation allowed:
- no; audit/report only

Required gate before implementation:
- local documentation continuity gate

## Search roots inspected

Required roots were inspected:

- `C:\Projekti\OPC\OPC v.1\SOURCE`
- `C:\Projekti\OPC\OPC v.1`
- `C:\Projekti\OPC`

Commands run:

```text
git status --short
git ls-files
git ls-files --others --exclude-standard
git status --short --ignored
Get-ChildItem -Path "C:\Projekti\OPC" -Recurse -File
```

The first full recursive listing timed out because `C:\Projekti\OPC` contains build/cache/generated trees. Follow-up listings excluded `.git`, `.dart_tool`, `build`, `runtime_data`, Flutter ephemeral/plugin symlink trees, backup archives, and similar generated folders where needed.

Safe metadata counts from filtered listing:

- `C:\Projekti\OPC\OPC v.1\SOURCE`: 57 documentation/config-like files before privacy filtering.
- `C:\Projekti\OPC\OPC v.1`: 116 documentation/config-like files before privacy filtering.
- `C:\Projekti\OPC`: 746 documentation/config-like files before stronger generated/build exclusions.

## Git-tracked documentation

`git ls-files` found 19 tracked files with documentation/config extensions:

- `.github/workflows/opc-manifest-gate.yml`
- `README.md`
- `analysis_options.yaml`
- `docs/ARCHITECTURE_OVERVIEW.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/LOGOS_ACCESS_TEST.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/tasks/OPC_TASK_GH_001_PUBLIC_GITHUB_FOUNDATION_REPORT.md`
- `docs/tasks/OPC_TASK_MANIFEST_AUTOMATED_ENFORCEMENT_REPORT.md`
- `docs/tasks/OPC_TASK_PURPOSE_AND_ANTI_DRIFT_MANIFEST_REPO_INTEGRATION_REPORT.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `pubspec.full_catalog_test.yaml`
- `pubspec.yaml`
- `tools/variant_packaging/README.md`
- `tools/windows_installer/README.md`
- `windows/CMakeLists.txt`
- `windows/flutter/CMakeLists.txt`
- `windows/runner/CMakeLists.txt`

GitHub-visible current source-of-truth documents:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/ARCHITECTURE_OVERVIEW.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`

## Untracked documentation inside repo

`git ls-files --others --exclude-standard` returned no files.

However, `git status --short --ignored` showed intentionally ignored local continuity documents inside `SOURCE`.

Ignored local root docs inside repo: 19 files:

- `OPC_Arhitektura_sistema_zakljucano.md`
- `OPC_AUDIT_PRIJAVA_ULOGE_SESIJA.md`
- `OPC_CORE_COMPLETION_AUDIT_PRE_DERIVATA.md`
- `OPC_CORE_LOCK_RESTORE_POINT_PRE_PDF_LANE.md`
- `OPC_derivati_pdf_specifikacija.md`
- `OPC_IMPLEMENTACIONI_LOGICKO_POSLOVNI_PLAN_RESTORE_TACKA.md`
- `OPC_IRIU_zakljucani_plan_i_poslovna_logika.md`
- `OPC_KONTROLNA_MAPA_STANJA_POSLE_STABILIZACIJE.md`
- `OPC_PRIJAVA_ULOGE_SESIJA_ZAKLJUCANO.md`
- `OPC_RESTORE_POINT_POST_STABILIZATION.md`
- `OPC_RESTORE_POINT_PRE_ANDROID_IRIU_BATCH.md`
- `OPC_RESTORE_POINT_PRE_JSON_PDF_SESSION.md`
- `OPC_RESTORE_TACKA_CORE_STABILNO.md`
- `OPC_zakljucana_poslovna_logika_core_sazetak_v2.md`
- `RESTORE_POINT_CORE_STABLE.txt`
- `RESTORE_POINT_POST_STABILIZATION.txt`
- `RESTORE_POINT_PRE_ANDROID_IRIU_BATCH.txt`
- `RESTORE_POINT_PRE_JSON_PDF_SESSION.txt`
- `RESTORE_POINT_PRE_PDF_LANE.txt`

Ignored local `SOURCE\PROJECT_DOCS` docs: 14 files:

- `00_README_KAKO_KORISTITI.md`
- `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md`
- `OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md`
- `OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md`
- `OPC_v1_ARCHITECTURE_DECISIONS.md`
- `OPC_v1_AUDIT_SUMMARY.md`
- `OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- `OPC_v1_chat_transkript_TASK_001.md`
- `OPC_v1_CODEX_RULES.md`
- `OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `OPC_v1_PROJECT_SOUL.md`
- `OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_MAP_OPC_v1.json`
- `PROJECT_MAP_OPC_v1_SUMMARY.md`

Ignored local private import JSON inside repo: 5 files under `_IMPORT_TEST_INPUTS`. These were treated as private/generated transfer test inputs and not opened.

## Local documentation outside repo

Local docs outside the active Git repo but inside the requested project roots:

- `C:\Projekti\OPC\OPC v.1\PROJECT_DOCS`: 11 files.
- `C:\Projekti\OPC\OPC v.1\RESTORE_POINTS`: 48 restore point marker files.
- `C:\Projekti\OPC\SOURCE`: 22 old-source root docs/config files.
- `C:\Projekti\OPC\OPC Python`: 4 legacy Python-era/generated documentation files.

The `C:\Projekti\OPC\OPC v.1\PROJECT_DOCS` folder appears to be the historical master copy referenced by `SOURCE\PROJECT_DOCS\00_README_KAKO_KORISTITI.md`.

The `C:\Projekti\OPC\SOURCE` folder appears to be an older source-tree copy with duplicated early OPC root docs and should not drive current decisions without owner confirmation.

The `OPC Python` files are legacy product/user-facing artifacts and should not drive current Flutter architecture.

## Private/sensitive/generated files excluded

Excluded from content inspection and commit:

- `_IMPORT_TEST_INPUTS\OPC_backup_*.json`
- `runtime_data\`
- `BACKUPS\`
- build/cache/generated folders
- Flutter `.dart_tool`, `build`, and `windows\flutter\ephemeral`
- old plugin symlink documentation under generated Flutter ephemeral trees
- installer/distribution outputs
- any possible customer/export/private data

Private/sensitive docs excluded count for handoff: 5 known import JSON files, plus generated/build/runtime folders excluded by class.

## Current source-of-truth candidates

GitHub-visible current rules:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/ARCHITECTURE_OVERVIEW.md`

Local continuity source-of-truth candidates requiring owner decision for sanitized GitHub publication:

- `PROJECT_DOCS\OPC_v1_PROJECT_SOUL.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `PROJECT_DOCS\OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS\OPC_v1_ARCHITECTURE_DECISIONS.md`
- `PROJECT_DOCS\OPC_v1_CODEX_RULES.md`
- `PROJECT_DOCS\OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1_SUMMARY.md`
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1.json`

`PROJECT_DOCS\00_README_KAKO_KORISTITI.md` explicitly says these local documents must be read at the start of new sessions/major blocks.

## Historical/superseded documents

Historical or superseded unless revalidated:

- root `OPC_*.md` files from April 2026;
- root `RESTORE_POINT_*.txt` files from April 2026;
- `C:\Projekti\OPC\SOURCE` duplicate/old source root docs;
- `C:\Projekti\OPC\OPC Python` PDF/text artifacts;
- individual `RESTORE_POINTS\RESTORE_POINT_*.md` markers, except as milestone evidence.

These files are useful as history but must not override the manifest, `PRODUCT_DIRECTION.md`, `ARCHITECTURE_OVERVIEW.md`, or the newer `PROJECT_DOCS` locked rules without owner review.

## Documents affecting OPC Web Pristup

GitHub-visible:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/ARCHITECTURE_OVERVIEW.md`

Local:

- `PROJECT_DOCS\00_README_KAKO_KORISTITI.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `PROJECT_DOCS\OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1_SUMMARY.md`
- `PROJECT_DOCS\OPC_v1_chat_transkript_TASK_001.md`

Drift risk found: several local docs use older `SaaS-ready`, `future SaaS`, or `multi-device sync` wording. That wording is acceptable only as historical/future seam language. It conflicts with the current manifest if interpreted as current product identity, mandatory central backend, or replacement for Windows/Android local parity.

## Documents affecting database/repository identity

GitHub-visible:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/ARCHITECTURE_OVERVIEW.md`

Local:

- `PROJECT_DOCS\OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS\OPC_v1_ARCHITECTURE_DECISIONS.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `PROJECT_DOCS\OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- `PROJECT_DOCS\OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md`
- `PROJECT_DOCS\OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md`

Key continuity point: local docs repeatedly state that `PREDMET` is the only master business truth, local database IDs are not cross-device business identity, and JSON/backup flows must preserve explicit user-controlled transfer/restore boundaries.

## Documents affecting JSON transfer/backup/restore

GitHub-visible:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/ARCHITECTURE_OVERVIEW.md`

Local:

- `PROJECT_DOCS\OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- `PROJECT_DOCS\OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1_SUMMARY.md`
- `PROJECT_DOCS\OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md`
- `PROJECT_DOCS\OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md`
- restore point markers under `C:\Projekti\OPC\OPC v.1\RESTORE_POINTS`

Important local continuity points:

- single-`PREDMET` JSON remains a user-controlled transfer path;
- full database backup/import is distinct from single-`PREDMET` JSON;
- local technical IDs are not cross-device business identity;
- future JSON shape changes require explicit compatibility and restore safety review;
- backup/restore is milestone-based, not an automatic reaction to every small docs edit.

## Conflicts or drift risks found

No direct conflict was found with the current manifest when local docs are treated as historical context plus continuity sources.

Risks if local docs are ignored:

- Logos may miss locked rules around `PREDMET` as sole truth.
- Older `PROJECT_DOCS` contain JSON transfer, backup/restore, local ID, and STANJE ROBE boundaries not fully mirrored in GitHub docs.
- Architecture work may incorrectly treat `PROJECT_MAP_OPC_v1.json` as a source of truth rather than a maintained audit map.

Risks if local docs are applied blindly:

- Older `SaaS-ready` wording may conflict with the manifest's current Web Pristup model.
- Old root docs and old `C:\Projekti\OPC\SOURCE` docs may duplicate or predate newer locked decisions.
- Restore point markers prove history but are not themselves current architecture specifications.

## Recommended documents to add to repo

Recommended for sanitized GitHub publication after owner approval:

- `PROJECT_DOCS\00_README_KAKO_KORISTITI.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_SOUL.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `PROJECT_DOCS\OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS\OPC_v1_ARCHITECTURE_DECISIONS.md`
- `PROJECT_DOCS\OPC_v1_CODEX_RULES.md`
- `PROJECT_DOCS\OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1_SUMMARY.md`

Recommended only after additional sanitization/owner decision:

- `PROJECT_DOCS\PROJECT_MAP_OPC_v1.json`
- `PROJECT_DOCS\OPC_v1_AUDIT_SUMMARY.md`
- `PROJECT_DOCS\OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md`
- `PROJECT_DOCS\OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md`
- `PROJECT_DOCS\OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md`

Do not add raw private import/export JSON.

## Recommended documents to keep local/private

Keep local/private:

- `_IMPORT_TEST_INPUTS\OPC_backup_*.json`
- `runtime_data\`
- `BACKUPS\`
- customer/export/generated outputs
- private key/license issuer materials if present outside this inspected set
- `C:\Projekti\OPC\OPC v.1\RESTORE_POINTS` as local operational history unless selected markers are sanitized
- `C:\Projekti\OPC\OPC Python` legacy artifacts unless the owner requests a historical migration appendix

Keep historical but not authoritative:

- root `OPC_*.md` early docs;
- root `RESTORE_POINT_*.txt` early markers;
- old `C:\Projekti\OPC\SOURCE` duplicate tree docs.

## What Logos must read before the next architecture task

Minimum required set:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/ARCHITECTURE_OVERVIEW.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `PROJECT_DOCS\00_README_KAKO_KORISTITI.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_SOUL.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `PROJECT_DOCS\OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS\OPC_v1_ARCHITECTURE_DECISIONS.md`
- `PROJECT_DOCS\OPC_v1_CODEX_RULES.md`
- `PROJECT_DOCS\OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1_SUMMARY.md`

If the next architecture task touches JSON transfer, database identity, backup/restore, Web Pristup, sync, hosting, STANJE ROBE, or package/licence logic, Logos must also read the relevant later reports:

- `PROJECT_DOCS\OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md`
- `PROJECT_DOCS\OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md`
- `PROJECT_DOCS\OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md`

## Do-not-implement-yet list

Do not implement from this audit:

- no web runner;
- no backend/API;
- no sync;
- no storage adapter;
- no database centralization;
- no migration;
- no JSON transfer behavior change;
- no package restructuring;
- no payment/subscription implementation;
- no terminology rewrite;
- no moving/deleting local documents;
- no committing private/import/export data.

## Final senior recommendation

Treat GitHub-visible docs as the current public baseline, but do not let future architecture work proceed from GitHub docs alone until the local `PROJECT_DOCS` continuity set is either sanitized into the repo or explicitly superseded by owner-approved public docs.

The next documentation task should be a separate owner-approved sanitization task for `PROJECT_DOCS`, not an implementation task.

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

PASS WITH PRIVATE DOCS EXCLUDED
