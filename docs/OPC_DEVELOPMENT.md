# OPC Development Guide

**Status:** `CURRENT AUTHORITATIVE DEVELOPMENT INFORMATION HOME`
**Baseline:** branch `task/OPC-SCENARIO-MODULE-LOCK`, commit `4e74772f72da921a2c94207a48c5530bfcc59e61`
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
- Current Phase 1 baseline is `task/OPC-SCENARIO-MODULE-LOCK` at `4e74772f72da921a2c94207a48c5530bfcc59e61`.
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

Analyzer and full test commands are sequential, never parallel. A timeout, hang, incomplete output or missing final exit code is not PASS. Flutter tests on the current Windows machine use `--concurrency=1` when the workflow requires it.

Documentation-only changes that do not affect source/tests/configuration/build behavior use documentation/repository validation rather than an automatic expensive Flutter suite. Phase 1 therefore validates links, references, manifest coverage and protected-state integrity.

## 7. Generated code and data rules

- Treat Drift-generated `database.g.dart` as generated output; do not edit it as hand-written architecture.
- Protect schema/migration history, runtime data compatibility and backup/restore contracts.
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

The HUMAN GATE, Logos↔Codex role separation, anti-drift method, forensic evidence discipline and pseudocode/roadmap comparison are internal development/governance know-how. They support active OPC/OPC Int development but are not required market-facing product documentation.

## 9. Contribution and documentation rules

Current-state documentation is maintained as docs-as-code:

- update the appropriate information home rather than append another task narrative;
- link source/test/runtime evidence with scope and platform stated;
- state future gaps as gaps, never as implemented controls;
- preserve historical documents until the migration manifest proves safe disposition;
- use ADRs only for durable technical structure, interfaces, dependencies, construction or NFR decisions;
- keep business authority in the product/domain home, not in ADRs or task reports;
- for a substantial task with multiple review artifacts, create one task-scoped review handoff index in the local review area. It must identify each artifact, authoritative path, state, hashes where useful, changed-file scope, validation and unresolved decisions. The index is a non-authoritative convenience layer, is not a current product-documentation home and is not added to README/current-state navigation.

## 10. Current protected/open areas

The following remain visible and are not silently closed by this guide:

- stale/default-branch authority;
- missing automated analyze/test gates;
- Windows single-instance and release-risk closure;
- signing/version/provenance gaps;
- explicit IP/repository-use/distribution status and third-party license inventory;
- JSON interoperability hotspot;
- KATALOG ownership ambiguity;
- PODSETNIK signal model;
- pseudocode drift and later Phase 2 synchronization;
- forensic dead-code/superseded-implementation audit;
- future Web/`OPC_v.1_Int`/multicurrency scope.
