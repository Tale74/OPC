# OPC Development Guide

**Status:** `CURRENT AUTHORITATIVE DEVELOPMENT INFORMATION HOME`
**Baseline reference:** historical Phase 3 branch `task/OPC-SCENARIO-MODULE-LOCK`, published Phase 3 SHA `336552ff40eaa72321670cb554ebd1d6d784d30c`; this is not the current operational task baseline. Current work must use the exact branch/SHA established by the current handoff and recovery plan; this guide does not invent a replacement baseline.
**Scope:** how to understand, validate and document current OPC work. This guide does not authorize production changes outside an explicitly scoped task.

## 1. Product and authority entry points

Start with:

1. [`OPC_PRODUCT_AND_DOMAIN.md`](OPC_PRODUCT_AND_DOMAIN.md) for product meaning and PREDMET authority.
2. [`OPC_ARCHITECTURE.md`](OPC_ARCHITECTURE.md) for current source/deployment responsibilities.
3. This document for development workflow and protected boundaries.
4. [`OPC_QUALITY_RELEASE.md`](OPC_QUALITY_RELEASE.md) for validation, runtime evidence and release gaps.
5. [`OPC_ENGINEERING_PROFILE.md`](OPC_ENGINEERING_PROFILE.md) for the adopted standards profile.
6. [`OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`](OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md) for active-source, evidence and donor boundaries.

Detailed current evidence remains linked from [`OPC_SOURCE_OF_TRUTH_MAP.md`](OPC_SOURCE_OF_TRUTH_MAP.md). Task reports are scoped evidence, not a substitute for current-state navigation.

### 1A. Permanent engineering-profile application

The adopted [`OPC_ENGINEERING_PROFILE.md`](OPC_ENGINEERING_PROFILE.md) applies
to every substantive OPC task for the remainder of development. At task intake
and closure, determine proportionately:

- the applicable business/domain authority and requirements/traceability impact;
- architecture, dependency, persistence and data-contract impact;
- implementation boundaries and protected compatibility surfaces;
- verification and platform/runtime acceptance obligations;
- quality, security, release and distribution implications; and
- current-state documentation that must be reconciled when the task evidence changes current truth.

An implication may be `NOT_APPLICABLE` when the reason is explicit and
evidence-backed. Do not manufacture an artifact or standards activity merely
to fill a checklist. The Context Harness, HUMAN GATE, internal pseudocode and
external task `REVIEW` handoff help establish and evidence applicability; they
do not replace the engineering profile or any authoritative information home.

### 1B. Owner-roadmap supremacy

The owner-planned OPC roadmap is the primary control for product scope. The
dependency plan organizes work only after provenance and necessity are
established; it cannot create a new owner product requirement.

Additional technical work must be demonstrably necessary, safe and
proportionate for a named owner-planned item, its verification or its release,
or for the later owner decision to standardize OPC engineering and
documentation. Such work records its parent and class. Build/test/runtime,
parity, backup, signing, version and handover items are release controls
attached to their parent, not standalone product features. Valid but
non-blocking debt stays outside the critical path.

During the current post-drift recovery phase, this existing owner-roadmap
control also requires every substantive task to identify its current residual
ID/group, classification, predecessor authority and plan authorization. The
task must confirm that it does not skip, reorder, reinterpret or silently
extend the canonical recovery plan, and that no historical readiness or
dependency sequence is being promoted to current sequencing authority. This
is the recovery plan's task-to-plan conformance rule, not a parallel
governance regime. If current authority does not establish one next residual
correction, the result is `OWNER SEQUENCING DECISION REQUIRED`.

If a finding changes business meaning or introduces new product scope, stop at
`OWNER DECISION REQUIRED`; observation alone never creates authority. Avoid
speculative or recursively generated successor chains. Apply standards
proportionately and optimize owner time, execution time and token/rework cost
without weakening correctness, traceability or evidence retention.

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

The current local implementation may be a protected mixed dirty working state.
Synchronizing documentation to GitHub does not publish that implementation as
a coherent source baseline. The active-source and donor rules in
[`OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`](OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md)
are mandatory for future corrective work.

### 3A. Post-drift recovery-plan continuity

While the post-drift recovery phase remains open, every substantive OPC task
must physically read [`OPC_POST_DRIFT_RECOVERY_PLAN.md`](OPC_POST_DRIFT_RECOVERY_PLAN.md)
before task planning or substantive source-learning. The task report must
state the resolved path, `READ = YES`, the current recovery phase, the
immediately preceding accepted phase or handoff, the single next
plan-authorized action relevant to the task, and that the task does not skip,
reorder, reinterpret or silently extend the recovery plan. If any item cannot
be established, stop with `STOP — RECOVERY PLAN CONTINUITY NOT ESTABLISHED`.

The plan governs continuity and ordering only. It does not create product
requirements or replace the detailed residual/deferred/evidence ledger and
matrix. Existing engineering-profile, HUMAN GATE, Docs-as-Code, active-source,
donor-control and anti-drift controls remain in force.

### 3B. Active-source precheck

Every future substantive task must first apply the permanent mandatory gate in
[`OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`](OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md).
At task start, resolve the current physical location of the current external
control package from current authority; do not treat the present
`CURRENT_TASK` path as an eternal invariant. Physically open and read, and
individually report, all five logical inputs: the active-source manifest, stale
donor denylist, high-risk active hash baseline, donor-use gate and active-source
precheck. Verify current provenance/package integrity, check relevant hashes,
verify write targets are authorized active roots, and confirm no donor or
`UNRESOLVED – DO NOT USE` material is being used. A valid report must include
`READ = YES` and `current provenance/integrity: PASS` for every input before
`ACTIVE SOURCE AUTHORITY PRECHECK — PASS` may be stated. Missing, ambiguous,
unread, unverified or hash-inconsistent inputs require
`ACTIVE SOURCE AUTHORITY PRECHECK — STOP — <reason>` and stop source-learning
or implementation. Prior memory, filename recognition, existence-only checks
and earlier PASS statements do not count. The package remains current
local-only control evidence, never implementation authority or a donor. Donor
reuse requires a separate bounded reconciliation and explicit OWNER
authorization. This is a control boundary, not an implementation or cleanup
authorization.

### 3C. High-risk active-baseline closure

At closure of every substantive task, determine whether any file protected by
`HIGH_RISK_ACTIVE_HASH_BASELINE.csv` changed. Report
`HIGH-RISK BASELINE — STILL MATCHED` when none changed. When an authorized
protected file changed, report
`HIGH-RISK BASELINE — CONTROLLED REBASELINE REQUIRED` and do not treat the
task as control-complete until the authorized final state is represented by a
valid current baseline or an explicit OWNER decision defers rebaseline while
blocking subsequent substantive implementation.

Controlled rebaseline may occur only after the protected change is accepted
and authorized. It must hash the actual final protected state, provide
provenance evidence for every changed protected row, preserve unchanged rows
unless mechanical regeneration produces the same verified value, regenerate
dependent package/integrity metadata as required, and complete verification
against current SOURCE. An unexplained mismatch must be reconciled before it
can be included in a new baseline. Rebaseline is control maintenance, not an
implementation donor mechanism.

## 4. Branch and task discipline

- Do not infer the active operational baseline from public `main`; use the exact branch and SHA named by the current handover/task.
- The published Phase 3 baseline is `task/OPC-SCENARIO-MODULE-LOCK` at `336552ff40eaa72321670cb554ebd1d6d784d30c`; use the exact handover/task SHA for later work.
- For ordinary development outside the open post-drift recovery phase, start from
  a clean worktree and keep unrelated work out of the branch. During the
  current recovery phase, the protected mixed SOURCE is the continuation
  baseline: do not clean, reset, stash, restore, move or normalize it. Preserve
  its unrelated delta and follow the canonical recovery plan and current
  handoff instead.
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

### 6B. Positive/negative business-state reasoning

For every transfer, restore, migration, default, repair, synchronization or
derived-state change, source-learning and review must record both sides of the
business invariant: what must exist or be propagated, and what must remain
absent, deleted, unchanged, local or forbidden. An absent dependent row is not
automatically corruption; its business meaning must be established before
ensure/rebuild logic can recreate it. Individual PREDMET JSON is an
authoritative current-state restoration boundary: lifecycle decisions travel
without database-local IDs, while new-PREDMET initialization remains separate.

Documentation-only changes that do not affect source/tests/configuration/build behavior use documentation/repository validation rather than an automatic expensive Flutter suite. Phase 1 therefore validates links, references, manifest coverage and protected-state integrity.

## 6A. Permanent post-scenario completeness control

Every future phase starts with a **FULL POST-SCENARIO CONTINUITY INTAKE**. Before Logos review or phase closure, run the **CROSS-PHASE CONTINUITY CHECK**, **SOURCE COVERAGE CHECK** and **ORPHAN/GAP SCAN** against actual file-level evidence. Closure requires both a phase-specific pass and a **POST-SCENARIO COMPLETENESS PASS**. The persistent ledger and inventories in `OPC_POST_SCENARIO_REVIEW_COMPLETENESS_LEDGER.csv` and `OPC_POST_SCENARIO_SOURCE_COVERAGE_INVENTORY.csv` are the canonical control/index for this process. A review index remains a local non-authoritative convenience layer; it cannot replace source, test, platform or closure proof.

## 7. Generated code and data rules

### 7A. Android physical structural-acceptance lane

`ANDROID_TEST` is the dedicated synthetic, disposable and inspectable physical structural-acceptance environment during OPC development. It uses the shared database, migration, repair, lifecycle, referential-cleanup and backup/restore implementation authority with a separate `opc_v4_android_test` database identity. Direct read-only inspection of that disposable database is permitted through the debuggable test package. PRODUCTION remains the authority for release packaging, end-user behavior, authentication and production data protection. The dedicated test device must not contain owner production data, credentials, owner backups or private owner exports; structural evidence may be reused only where shared implementation authority has been proven.

RR-011 current fact after the final physical Android wave is `CLOSED — FULL ANDROID STRUCTURAL ACCEPTANCE PASS`: connectivity, scenario-snapshot cleanup, single-PREDMET replacement, stable identity, dependent-row recreation, relaunch persistence and integrity/FK evidence pass in the disposable `ANDROID_TEST` lane. The current single-PREDMET `OPC_PREDMET` JSON format carries the scenario carrier and PREDMET-scoped lifecycle decisions without local database IDs; intentionally absent state is preserved. RR-011 has no remaining successor; the earlier ADB-offline attempt is historical.

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

Task closure records both the local authoritative-documentation state and its
public Git synchronization state. Local reconciliation is not
documentation-complete publication until the authorized public Git update is
also synchronized.

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
