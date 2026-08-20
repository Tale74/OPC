# OPC Development Guide

**Status:** `CURRENT AUTHORITATIVE DEVELOPMENT INFORMATION HOME`
**Baseline:** branch `task/OPC-SCENARIO-MODULE-LOCK`, published Phase 3 baseline `336552ff40eaa72321670cb554ebd1d6d784d30c`
**Scope:** how to understand, validate and document current OPC work. This guide does not authorize production changes outside an explicitly scoped task.

## 1. Product and authority entry points

Start with:

1. [`OPC_PRODUCT_AND_DOMAIN.md`](OPC_PRODUCT_AND_DOMAIN.md) for product meaning and PREDMET authority.
2. [`OPC_ARCHITECTURE.md`](OPC_ARCHITECTURE.md) for current source/deployment responsibilities.
3. This document for development workflow and protected boundaries.
4. [`OPC_QUALITY_RELEASE.md`](OPC_QUALITY_RELEASE.md) for validation, runtime evidence and release gaps.
5. [`OPC_ENGINEERING_PROFILE.md`](OPC_ENGINEERING_PROFILE.md) for the adopted standards profile.

Detailed current evidence remains linked from [`OPC_SOURCE_OF_TRUTH_MAP.md`](OPC_SOURCE_OF_TRUTH_MAP.md). Task reports are scoped evidence, not a substitute for current-state navigation.

## 2. Environment and bootstrap

OPC is a Flutter/Dart application. From a configured Flutter environment:

```powershell
flutter pub get
flutter analyze
flutter test
```

Windows and Android platform tooling, SDK versions, signing and installer prerequisites are platform-specific and must be recorded with a release artifact when distribution work is authorized. Do not commit real databases, case/customer data, credentials, exports, logs, signing material, machine-local configuration, caches or build products.

## 3. Local + GitHub working model

OPC remains maintained through both:

- the local project environment, which contains supporting/current learning material, runtime evidence, restore points and private data outside Git; and
- the public GitHub repository, which contains the sanitized source and current product/engineering documentation intended for controlled review.

This is a transitional local + GitHub model. It is not a Git-only authority model and it is not permission to create uncontrolled duplicate copies. The Phase 1 migration manifest records which local materials remain supporting/current, internal, historical or private. Future synchronization/distribution rules remain owner-controlled.

For documentation changes, update the Git current-state home and record any required local counterpart or local evidence relationship in the manifest. Do not promote private databases, backups, credentials or raw runtime artifacts.

## 4. Branch and task discipline

- Do not infer the active operational baseline from public `main`; use the exact branch and SHA named by the current handover/task.
- The published Phase 3 baseline is `task/OPC-SCENARIO-MODULE-LOCK` at `336552ff40eaa72321670cb554ebd1d6d784d30c`; use the exact handover/task SHA for later work.
- Start from a clean worktree and keep unrelated work out of the branch.
- Use descriptive focused commits and review status, staged names and staged diff before commit.
- Do not change canonical/default branch in documentation work.
- A task report must contain the required manifest start/end compliance blocks when the repository gate applies.

## 5. Source and business-authority rules

- PREDMET remains the master business truth.
- SCENARIO production source and its regression contract remain formally locked.
- Derivatives (IRiU projections, PARTE, PDFs/DOCX, finance/statistics, reminders, stock effects and JSON representations) must not become parallel authorities.
- Current source/tests prove implemented technical behavior; they do not silently change owner business meaning.
- If current documents conflict on business meaning, preserve the evidence and mark `OWNER DECISION REQUIRED`.
- This Phase 1 task does not redesign the SOURCE tree, remove dead code, refresh pseudocode content, resolve PODSETNIK semantics or redesign the roadmap. Closure Correction may classify/separate pseudocode physically without changing its content.

## 6. Validation workflow

For tasks changing source, tests, generated source, schema/migrations, assets, runtime configuration or build configuration, the permanent sequence is:

1. targeted tests where relevant;
2. `flutter analyze`, with conclusive final summary and exit code;
3. complete `flutter test` with conclusive final summary and exit code;
4. only after both green gates, authorized Windows/Android builds;
5. only after builds, disposable/runtime evidence where authorized.

Analyzer and full test commands are sequential, never parallel, with one Flutter/Dart/Gradle process chain active at a time. On the OPC Windows environment, `flutter analyze` and the complete `flutter test` suite must be allowed to reach natural completion; elapsed time alone is not evidence of a hang. Only affirmative technical evidence such as a demonstrated deadlock, permanently blocked child process, unrecoverable tooling/file lock or explicit tooling failure may classify a genuine hang. A command without a conclusive final summary and exit code is not PASS. Flutter tests on the current Windows machine use `--concurrency=1` when the workflow requires it.

Documentation-only changes that do not affect source/tests/configuration/build behavior use documentation/repository validation rather than an automatic expensive Flutter suite. Phase 1 therefore validates links, references, manifest coverage and protected-state integrity.

## 6A. Permanent post-scenario completeness control

Every future phase starts with a **FULL POST-SCENARIO CONTINUITY INTAKE**. Before Logos review or phase closure, run the **CROSS-PHASE CONTINUITY CHECK**, **SOURCE COVERAGE CHECK** and **ORPHAN/GAP SCAN** against actual file-level evidence. Closure requires both a phase-specific pass and a **POST-SCENARIO COMPLETENESS PASS**. The persistent ledger and inventories in `OPC_POST_SCENARIO_REVIEW_COMPLETENESS_LEDGER.csv` and `OPC_POST_SCENARIO_SOURCE_COVERAGE_INVENTORY.csv` are the canonical control/index for this process. A review index remains a local non-authoritative convenience layer; it cannot replace source, test, platform or closure proof.

## 7. Generated code and data rules

### 7A. Android physical structural-acceptance lane

`ANDROID_TEST` is the dedicated synthetic, disposable and inspectable physical structural-acceptance environment during OPC development. It uses the shared database, migration, repair, lifecycle, referential-cleanup and backup/restore implementation authority with a separate `opc_v4_android_test` database identity. Direct read-only inspection of that disposable database is permitted through the debuggable test package. PRODUCTION remains the authority for release packaging, end-user behavior, authentication and production data protection. The dedicated test device must not contain owner production data, credentials, owner backups or private owner exports; structural evidence may be reused only where shared implementation authority has been proven.

RR-011 current fact after the final physical Android wave is `CLOSED — FULL ANDROID STRUCTURAL ACCEPTANCE PASS`: connectivity, scenario-snapshot cleanup, single-PREDMET replacement, stable identity, dependent-row recreation, relaunch persistence and integrity/FK evidence pass in the disposable `ANDROID_TEST` lane. The single-PREDMET `OPC_PREDMET` JSON format does not carry scenario snapshot/provenance rows; that boundary is documented. RR-011 has no remaining successor; the earlier ADB-offline attempt is historical.

Windows native singleton authority is `CLOSED — FULL ACCEPTANCE PASS` from the published `070ea5e476441cb44ad9cac424c6b90a73da5a72` implementation and W1–W6 evidence. Installer/update running-app protection is a separate control: the actual Inno Setup script uses the accepted mutex through `AppMutex` and sets `CloseApplications=no`; Inno Setup 6.7.3 compile and I1/I2/I3 runtime acceptance are `PASS`, with no installation completed. RR-012 is closed with no successor.

- Treat Drift-generated `database.g.dart` as generated output; do not edit it as hand-written architecture.
- Protect schema/migration history, runtime data compatibility and backup/restore contracts.
- Treat a fresh test/runtime database as empty of user/business KATALOG content. Tests that need catalogue data must insert an explicit fixture; production startup, reopen and migrations must not hide business bootstrap.
- Use isolated/forensic copies for risky data work; never replace a designated user database with a prepared/test database.
- Keep single-PREDMET JSON and full-backup JSON distinct.
- Do not commit runtime databases, customer data, exports, private backups, credentials or machine-local configuration.

## 8. Human and owner controls

Ordinary technical decisions may follow the evidence and adopted profile. Owner/HUMAN GATE confirmation remains required when a task would:

- change PREDMET business meaning or owner-approved semantics;
- unlock or reinterpret SCENARIO;
- decide PODSETNIK signal meaning, licensing/distribution model or canonical branch;
- resolve a conflict between current business authorities;
- change protected database/data ownership or release acceptance.

The owner confirmation gate is an OPC project control for protected decisions;
it does not delegate business meaning to a tool or report. Protected decisions
include PREDMET semantics, SCENARIO unlocks, database ownership, release
acceptance and other gates listed above. The reusable mechanics for task
framing, evidence packaging and human/AI collaboration are maintained outside
the product documentation surface; this home retains only the OPC-specific
constraints and required evidence outcomes.

## 9. Contribution and documentation rules

Current-state documentation is maintained as docs-as-code:

- update the appropriate information home rather than append another task narrative;
- link source/test/runtime evidence with scope and platform stated;
- state future gaps as gaps, never as implemented controls;
- preserve historical documents until the migration manifest proves safe disposition;
- use ADRs only for durable technical structure, interfaces, dependencies, construction or NFR decisions;
- keep business authority in the product/domain home, not in ADRs or task reports;
- for a substantial task with multiple review artifacts, create one task-scoped review handoff index in the local review area. It must identify each artifact, authoritative path, state, hashes where useful, changed-file scope, validation and unresolved decisions. The index is a non-authoritative convenience layer, is not a current product-documentation home and is not added to README/current-state navigation.

Every OPC task records the project manifest start/end compliance fields,
branch/base identity, changed paths, validation results, protected surfaces and
known risks. These are project evidence requirements; reusable task-writing and
collaboration method is not a SOURCE authority.

## RR-008 replacement invariant

Same-identity replacement is governed by `CURRENT PREDMET TRUTH → CURRENT
DERIVED STATE`. The replacement seam invalidates stale PARTE preparation/media
and reconciles stale reminder state against current PREDMET truth while
preserving the user's reminder configuration. RR-008 does not define future
PODSETNIK trigger, scheduling or recreation semantics. The focused integration
contract and full serialized QA suite are the current implementation evidence.

## 10. Current protected/open areas

The following remain visible and are not silently closed by this guide:

- stale/default-branch authority;
- missing automated analyze/test gates;
- remaining release-risk closure outside the closed native singleton and installer controls;
- signing/version/provenance gaps;
- explicit IP/repository-use/distribution status and third-party license inventory;
- JSON interoperability hotspot;
- KATALOG edge-case characterization;
- PODSETNIK signal model (owner-gated);
- pseudocode drift (continuously compared with current authority and roadmap);
- Phase 4 forensic dead-code/superseded-implementation closure review;
- future Web/`OPC_v.1_Int`/multicurrency scope.
