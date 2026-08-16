# OPC Software Engineering Standards, Repository Architecture & Documentation Fit/Gap Audit

**AUDIT / TECHNICAL RECOMMENDATION — NOT YET ADOPTED OPC STANDARD**

**Audit date:** 2026-08-16  
**Authorized scope:** read-only forensic, architecture, documentation, governance, pseudocode, roadmap, build/test/release, security/dependency and external-standards audit  
**Decision status:** Logos↔Codex technical consensus and owner clarifications incorporated; input to owner review of the later standardization program; not authorization to implement, reorganize, refactor, migrate, delete, unlock SCENARIO, or change business semantics

## 1. Executive Summary

OPC is a substantial, working local-first Flutter product with unusually strong business-authority discipline and regression evidence, but its repository does not yet present that product as a compact, professionally transferable engineering system. The code contains recognizable building blocks—PREDMET, SCENARIO, IRiU/KATALOG, PARTE, document generation, persistence, transfer/backup, reminders, stock, authentication, settings and platform adapters—but several boundaries are physically hidden, bidirectionally coupled, or concentrated in oversized files. The documentation contains much current knowledge, but 290 Markdown files are dominated by task chronology, correction reports and transitional governance. The only repository workflow is a task-report manifest gate; analysis, tests, builds, dependency/security checks and release provenance remain manual.

The Logos profile is directionally sound but requires material correction:

- ISO/IEC 29110 Basic Profile fits OPC's small-team/non-safety-critical context, but should be a **TAILOR / ADAPT process benchmark**, not OPC's branded primary daily operating system and not a conformance claim.
- arc42 is suitable if compressed into one current architecture home; C4 System Context and Container are useful defaults, but OPC also needs a small Deployment view because Windows, Android, SQLite, filesystem exports and local installation materially affect understanding.
- Flutter architecture principles should guide bounded extractions and dependency rules, not trigger an MVVM conversion or wholesale folder rewrite.
- ISO/IEC/IEEE 15289, 29148 and ISO/IEC 25010 are useful as information-purpose, traceability and quality vocabularies; 12207, 42010 and 24748-5 should remain references.
- NIST SSDF 1.1 should be a proportional security overlay. SPDX/SBOM, third-party license inventory, explicit IP/repository-use/distribution status and dependency automation should move earlier than Logos proposed: recommended now and required before commercial distribution or handover. Formal SLSA levels remain deferred, while simple artifact hashes and build records are proportionate prerequisites to distribution.
- Missing practices requiring explicit treatment are release/version governance, dependency and third-party license ownership, data/privacy and threat modeling, automated CI, default-branch authority, backup/restore assurance and technical-debt visibility.

The required sequence is documentation/authority reconciliation, pseudocode↔roadmap↔locked-source synchronization, target architecture and dependency/migration design, forensic dead-code review, an evidence-based retain/rename/move/split/merge/refactor/rewrite/reconstruct/remove decision for each block, controlled implementation at the appropriate scale, and full regression/data/interoperability/runtime acceptance. SCENARIO remains locked and PREDMET remains master business truth. No implementation has been performed.

**Overall finding:** OPC has a credible engineering foundation but is not yet acquisition/handover ready without material documentation, repository-control, release, dependency/IP-status and boundary-clarity work.

## 2. Verified Baseline

| Item | Verified state | Evidence |
|---|---|---|
| Repository | `C:\Projekti\OPC\OPC v.1\SOURCE` | `GIT EVIDENCE` local worktree and `.git` |
| Starting branch | `task/OPC-SCENARIO-MODULE-LOCK` | `GIT EVIDENCE` |
| Starting/local HEAD | `4615546e12a2b8dd8d23890fbb252abff0462838` | `GIT EVIDENCE` |
| Worktree before report | Clean | `GIT EVIDENCE` |
| Remote | `origin` → `https://github.com/Tale74/OPC.git` | `GIT EVIDENCE` |
| Matching public task branch | Same SHA as local HEAD | `GIT EVIDENCE` remote refs |
| Public default `main` | `80294ea9ec98d09b02a4c8876b752738eba0c933`; 257 commits behind the task branch | `GIT EVIDENCE` merge-base/rev-list |
| Branch/tag inventory | 163 local branches, 157 remote branches, no tags | `GIT EVIDENCE` |
| SCENARIO locked source | `a8218537c1aa85b61fe5c85c21dbd03672f6e77c` | `GIT` + `DOCUMENTATION EVIDENCE` |
| Lock publication | `4615546e12a2b8dd8d23890fbb252abff0462838` | `GIT` + `DOCUMENTATION EVIDENCE` |
| Runtime acceptance | Windows interactive PASS; Android narrow interactive PASS | `OWNER RUNTIME EVIDENCE`; not reproduced by this audit |
| Authority coherence | Local and matching remote task branch are coherent; public `main` is stale and is not present authority; the current maintenance model remains local + GitHub | `CODEX INFERENCE` from Git and authority documents |
| Newer authority | No newer public branch/HEAD was found that supersedes the lock publication | `GIT EVIDENCE`; public branch protection settings were not repository-verifiable |

The branch topology is itself a governance gap: current authoritative work is 257 commits away from the default branch and spread across many task branches. A new team could reasonably—but incorrectly—treat `main` as current. Authority must be consolidated before standard repository controls can safely target a canonical branch.

The SCENARIO lock evidence is coherent: the production lock SHA precedes the documentation publication SHA, and the latter is the current branch HEAD. The generic IRiU order invariant remains:

`ordered OSNOVNI PAKET → ordered applied SCENARIO PAKET → manual/unpredicted items`.

No continuity conflict makes this audit inconclusive. Local ignored artifacts (logs, build outputs and a runtime SQLite copy) clutter the working directory but are not tracked authority.

## 3. Sources Read

### Repository authority, current state and governance

The audit read, not merely inventoried, the relevant portions of:

- `README.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md`
- `docs/OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md`
- `docs/OPC_DOCUMENTATION_TRUTH_RECOVERY_REPORT.md`
- `docs/OPC_DOCUMENTATION_TRUTH_RECOVERY_CORRECTION_MATRIX.md`
- `docs/OPC_DOCUMENTATION_RECONCILIATION_AUDIT_AND_REMOVAL_MANIFEST.md`
- `docs/OPC_TECHNICAL_EXECUTION_STANDARD.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_OWNER_DECISION_INDEX.md`, owner decision guide/report/records
- `docs/PRODUCT_DIRECTION.md`

### Architecture, business/domain and roadmap

- `docs/ARCHITECTURE_OVERVIEW.md`
- `docs/OPC_MODULE_RELATIONSHIP_MAP.md`
- `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md`
- `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`
- `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`
- the draft/revised/final-candidate plan variants
- `docs/OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md`
- `docs/OPC_POST_ZERO_ARCHITECTURE_DECISION_GATE_SYNTHESIS.md`
- `docs/OPC_POST_ZERO_PREDMET_LIFECYCLE_REFERENTIAL_DESIGN.md`
- `docs/OPC_DOCUMENTATION_ARCHITECTURE_AND_DEVELOPMENT_PLAN_AUDIT.md` as historical, stale evidence

### SCENARIO and pseudocode

- `docs/OPC_SCENARIO_MODULE_LOCK.md`
- `docs/OPC_SCENARIO_MODULE_LOCK_REPORT.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- relevant SCENARIO task reports and test contract descriptions
- `C:\Projekti\OPC\OPC v.1\SCENARIO_MAP\Vlasnicka_definicija_logicke_SCENARIO_mape_KONACNA.md` and `SCENARIO_mapa_kontrolni_izvestaj.txt` outside Git

### Source/configuration/evidence

Production Dart under `lib/`, tests under `test/`, Android and Windows runners/configuration, `pubspec.yaml`, `pubspec.lock`, `.gitignore`, `analysis_options.yaml`, `.github/workflows/opc-manifest-gate.yml`, installer/packaging scripts, Git history/remotes, and relevant runtime/build reports were inspected. Generated `database.g.dart` was identified separately from hand-written source.

Local legacy root documents and the wider project documentation were classified as unreconciled/historical learning inputs unless a current authority document explicitly elevated them. Runtime evidence was used only for observed behavior. This classification does not abolish the active local + GitHub maintenance model: local project material remains relevant and current synchronization requirements remain in force until the owner defines a future transition, acquisition or distribution model.

The relevant runtime evidence area `C:\Projekti\OPC\OPC v.1\RUNTIME` was inventoried, including the 2026-08-16 SCENARIO machine test JSONL evidence and owner screenshots. Those artifacts corroborate recorded acceptance evidence but were not treated as source-code root-cause proof.

## 4. External Standards Sources Consulted

For ISO/IEC/IEEE standards below, Codex reviewed official public scope, edition/status and preview material only: **PUBLIC SCOPE/ABSTRACT REVIEW — NOT CLAUSE-LEVEL CONFORMANCE REVIEW**. This report claims alignment/tailoring only, never formal conformance.

| Source | Verified edition/status and use |
|---|---|
| [ISO/IEC 29110-5-1-2:2025](https://www.iso.org/standard/82669.html), ISO | Edition 1, Feb 2025; Basic Profile guidance through project-management and software-implementation processes for a non-safety-critical single product/single team. Public scope review only. |
| [ISO 29110 series overview](https://committee.iso.org/sites/jtc1sc7/home/projects/flagship-standards/isoiec-29110-series.html), ISO/IEC JTC 1/SC 7 | VSE profile context and staged Entry/Basic/Intermediate/Advanced intent. |
| [ISO/IEC/IEEE 12207:2026](https://www.iso.org/standard/90219.html), ISO/IEC/IEEE | Edition 2, Apr 2026; common lifecycle-process framework, method/lifecycle neutral. Public scope review only. |
| [ISO/IEC/IEEE 15289:2019](https://www.iso.org/standard/74909.html), ISO/IEC/IEEE | Edition 4; confirmed 2025 and marked for revision in 2026; information-item purpose/content and explicit allowance to combine/subdivide. Public scope review only. |
| [ISO/IEC/IEEE 42010:2022](https://www.iso.org/standard/74393.html), ISO/IEC/IEEE | Edition 2; architecture-description concepts/viewpoints/model kinds, without prescribing method or format. Public scope review only. |
| [ISO/IEC/IEEE 29148:2018](https://www.iso.org/standard/72089.html), ISO/IEC/IEEE | Edition 2; confirmed 2024, now marked for revision; requirements processes/information. Public scope review only. |
| [ISO/IEC 25010:2023](https://www.iso.org/standard/78176.html), ISO | Edition 2; product quality model. Public scope review only. |
| [ISO/IEC/IEEE 24748-5:2017](https://www.iso.org/standard/60062.html), ISO/IEC/IEEE | Software-development planning framework. Public scope review only. |
| [NIST SP 800-218 SSDF 1.1](https://csrc.nist.gov/pubs/sp/800/218/final) and [SSDF publications](https://csrc.nist.gov/Projects/ssdf/publications) | Final Feb 2022 outcome-based secure-development overlay. Version 1.2 remained draft as of audit date; use final 1.1 and monitor revision. |
| [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide) and [recommendations](https://docs.flutter.dev/app-architecture/recommendations) | Official guidance: UI/data separation, repositories/services, controlled responsibilities/dependencies, testability; domain/use cases only when complexity warrants; guidelines are adaptable, not steadfast rules. |
| [arc42 overview](https://arc42.org/overview) | Tailorable 12-part architecture communication structure, including building blocks, runtime/deployment, decisions, quality and risks. |
| [C4 diagrams](https://c4model.com/diagrams) | Context, container, component and code zooms plus dynamic/deployment views; explicitly says not all levels are required. |
| [Michael Nygard, Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | Original recognized lightweight ADR formulation: architecturally significant structure/NFR/dependency/interface/construction decisions; supersede rather than erase. |
| [GitHub rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets) | Official required-status-check, PR/review and code-owner control capabilities. |
| [SPDX specifications](https://spdx.dev/use/specifications/) | SPDX current version 3.0; international standard ISO/IEC 5962:2021; machine-readable software component information/SBOM basis. |
| [OpenSSF Scorecard](https://github.com/ossf/scorecard) | Repository-security heuristics; useful audit reference, not proof and not one-size-fits-all. |
| [SLSA 1.2](https://slsa.dev/spec/v1.2/) and [provenance](https://slsa.dev/spec/v1.2/provenance) | Approved incremental supply-chain framework; provenance records verifiable where/when/how artifacts were produced. |
| [sqlite3_flutter_libs package](https://pub.dev/packages/sqlite3_flutter_libs) | Current package metadata says `0.6.0+eol` is obsolete/no-op after sqlite3 3.x; direct evidence for dependency review, not an authorization to upgrade. |

## 5. Current Repository Architecture

### Architectural reconstruction

OPC is one Flutter application with manual composition in `lib/app.dart`, a Drift/SQLite local persistence core and platform runners for Windows and Android. It is not a collection of independently deployed services. The meaningful architecture is therefore a set of in-process business/application/data/presentation building blocks plus local platform/storage adapters.

`SOURCE EVIDENCE` shows 153 Dart files under `lib/` (one very large generated Drift file), 70 Dart test files, 290 Markdown documents and one GitHub workflow. Major current blocks are:

- **Composition/application shell:** `main.dart` creates `AppDatabase`; `app.dart` constructs repositories/services and routes. Clear but manual and increasingly central.
- **PREDMET business authority:** lifecycle, repository, policies and domain state under `features/predmeti`; the master business truth is explicit in documentation and behavior.
- **SCENARIO:** contracts, policy kernel, rule engine, reconciliation, persistence, transfer, PREDMET application and UI under `predmeti/core_v2/scenario`; conceptually strong and formally locked, though `core_v2` obscures its status.
- **IRiU/KATALOG:** IRiU editing, scenario snapshot/provenance, ordering, catalogue selection/prices and stock effects are concentrated across large repository/UI files; KATALOG ownership is dispersed among `core/catalog`, settings, database seed logic and consumers.
- **PARTE and documents:** PARTE has relatively coherent application/data/domain/docx/pdf/presentation substructure. Standard PDF/document generation is a PREDMET derivative.
- **Persistence:** `core/database/database.dart` combines schema declaration, migrations through schema version 27, seed/repair/recovery and database identity protection. It is robust but oversized and multi-responsibility.
- **JSON transfer/backup:** `core/utils/json_export_import.dart` is an integration/application service mislabeled as a generic core utility. It imports auth, PREDMET, SCENARIO, PARTE/reminder, stock and backup types, combining UI, filesystem, validation, serialization and mutation.
- **Reminders/PODSETNIK:** user-facing PODSETNIK is mostly presentation; reminder implementation is under `predmeti/reminders`. This hidden split cannot be finalized before the owner resolves signal/trigger semantics.
- **Authentication/settings/stock:** authentication is comparatively layered; settings and stock have mixed cross-feature composition.
- **Platform adapters:** Flutter runners are mostly standard. Android declares file/storage/reminder permissions; Windows packaging is scripted. Platform behavior differs at filesystem, notification, window and installation boundaries.

### Dependency findings

The main issue is not a proven runtime defect but boundary visibility and dependency direction:

- `core/utils/json_export_import.dart → multiple features` is an inappropriate inward-to-outward dependency for something called core. It belongs conceptually to an application/integration block.
- presentation screens compose several feature repositories directly; this is tolerable at composition boundaries but repeated cross-feature imports create hidden orchestration.
- `predmeti` and `podesavanja`, `podsetnik`, and `stanje_robe` have bidirectional package coupling. The audit does not claim a proven Dart import cycle; it identifies architectural coupling that complicates ownership and testing.
- repositories such as IRiU and the main database class carry lifecycle, policy and infrastructure responsibilities beyond a narrow data abstraction.
- very large screens (approximately 2,000–3,380 lines) mix interaction state, orchestration and rendering, materially raising cognitive load.

The correct response is bounded extraction behind preserved contracts, not a greenfield layered rewrite.

## 6. Current Documentation Architecture

`DOCUMENTATION EVIDENCE`: `docs/` contains 290 Markdown files: 131 task reports, many audit/correction/reconciliation reports, roughly 14 pseudocode artifacts, multiple roadmap variants and numerous maps/matrices/registers. More than half lack a readily identifiable status marker. Byte-identical duplication is not the principal issue; semantic overlap and chronology are.

Strengths:

- explicit source-of-truth and owner-decision discipline;
- unusually detailed business rules, invariants, incident evidence and lock contracts;
- current-state and dependency-plan documents exist;
- historical evidence is retained rather than silently overwritten;
- post-zero inventory provides a useful authority classification mechanism.

Gaps:

- a reader must traverse task history to reconstruct present truth;
- several plan/draft/reconciliation generations remain adjacent and similarly named;
- architecture, business authority, developer workflow and release information are split across many documents;
- current architecture maps are less current than the locked production state in places;
- repository root also contains ignored legacy reports and logs that impair local discoverability even though Git excludes them;
- the README is a useful but thin entry point and cannot lead a new team to one complete architecture/domain/development/release set.

The final repository should retain information because it is currently necessary, not because producing it was expensive. Unique knowledge must be migrated before historical material leaves the active product documentation.

## 7. Current Internal Governance/Pseudocode Layer

The owner-approved definition controls this audit:

> OPC pseudocode is strictly an internal Tale/Logos development-control artifact. It exists during active OPC and OPC Int development to give Logos an always-available logical-functional representation of OPC, including CORE, modules, derivatives, relationships, invariants and important flows, and to be continuously compared with the authoritative roadmap to detect progress, drift and regressions. It is not final product documentation, not a production specification, not part of the market-facing SOURCE package, and must not ship with the finished application or be presented as handover documentation to a future acquirer/development company. After OPC and OPC Int development is completed, the reusable obligation and method move into the team's general internal development/governance/jumpstart know-how.

That method remains justified through OPC and OPC Int. It is not redundant merely because architecture and domain documents exist.

Current fitness, however, is inadequate for reliable roadmap comparison. The principal index was last materially aligned around Phase 9 before the final SCENARIO application/runtime/lock work. Its text still describes PREDMET selection/application as a next step and retains earlier state that no persisted module registry exists. An indicative exact-path cross-check found 57 of 152 non-generated production Dart files referenced and 95 not referenced; glob-level descriptions make that an indicator rather than a completeness metric. Missing exact coverage includes much of current SCENARIO runtime/repository/contracts/UI, PARTE, PDF, reminders, stock and newer persistence structures.

Required maintenance rule through OPC/OPC Int:

1. Update the logical-functional map at every accepted business/architecture milestone and formal lock.
2. Record compared source SHA and authoritative-roadmap revision.
3. Cover CORE, modules, derivatives, dependency direction, invariants and critical success/failure flows—not every class.
4. Produce an explicit progress/drift/regression result and unresolved delta list.
5. Never let pseudocode override PREDMET/owner authority or act as production specification, market-facing documentation or handover documentation.

After OPC and OPC Int, the obligation, templates and comparison method move to internal development/governance/jumpstart know-how. Product truths discovered through it must already live in current product/domain/architecture documentation.

## 8. Current Build/Test/Release Practice

### Testing and quality

The 70 Dart test files contain broad unit, contract, characterization, forensic and widget coverage, including migrations, JSON import/export, backup/restore, PREDMET lifecycle, IRiU/KATALOG/stock, SCENARIO, PARTE/PDF and reminders. Tests are flat under `test/`, so categories and expected execution tiers are not discoverable from structure alone.

SCENARIO governance defines a sound impact model: targeted Tier 1, an exact locked Tier 2 regression contract, then full/deep Tier 3 where required. The latest lock report records analyzer, full suite, Windows and Android release-build evidence, with 507 completions, 0 failures and 10 skips. `DOCUMENTATION EVIDENCE`: those are historical task results; this audit did not reproduce or upgrade them to present runtime evidence. `OWNER RUNTIME EVIDENCE`: Windows and Android acceptance are observed product behavior, not proof of internal root cause.

Normal documented flow—targeted tests → `flutter analyze` → full suite → relevant platform builds → owner runtime acceptance—is strong. Its weakness is automation and discoverability: no CI workflow enforces analyze/test/build, and special governance documents carry rules that should ultimately live in a concise development/quality/release guide. Skips include environment-gated forensic tests and owner-database tests; these should remain explicitly categorized, not silently treated as ordinary green tests.

No expensive suite was run because no production behavior changed and existing source/doc evidence was sufficient for this audit.

### Build and release

Windows and Android release builds have documented task evidence. Windows has a packaging script and Inno Setup definition; Android's release Gradle configuration still uses a debug signing configuration marked by a TODO. Windows artifacts are unsigned, and there is no repository-visible signing-key custody, semantic version/release policy, tagged-release history, checksummed artifact manifest, reproducible-build definition or single canonical release runbook. The Windows runner does not visibly implement the documented single-instance protection at native level.

These are release-readiness gaps, not permission to modify platform configuration in this audit.

## 9. Current Repository/Security/Dependency Posture

### Repository controls

- One workflow, `.github/workflows/opc-manifest-gate.yml`, validates boilerplate in changed task reports; it is not a code quality gate.
- No repository-visible `CONTRIBUTING.md`, `SECURITY.md`, `CODEOWNERS`, explicit IP/repository-use/distribution status, changelog/release policy, Dependabot configuration or SBOM mechanism.
- No tags exist; public `main` is stale; branch/ruleset settings could not be proven from repository content.
- `.gitignore` appropriately excludes runtime databases, logs, secrets/signing material, exports/builds, restore points and local documentation areas.

### Dependencies and security

`pubspec.lock` pins 158 packages in total (22 direct runtime dependencies, five direct dev dependencies and approximately 131 transitives) and records hosted-package hashes. This makes dependency inventory and SBOM generation straightforward, but there is no automated update cadence, vulnerability review, third-party license inventory or SBOM.

The direct `sqlite3_flutter_libs ^0.6.0+eol` dependency is officially marked obsolete/no-op. This is a concrete dependency-governance signal; whether removal/upgrade is safe requires a separate authorized compatibility task.

Security-relevant observations include personal/business data in local SQLite and plaintext JSON backups, SHA-256 legacy PIN handling, stronger PBKDF2-SHA256 for recovery material, platform permissions, and ignored runtime artifacts. These observations justify a proportional threat/data/privacy review; they do not by themselves prove an exploitable vulnerability. No security policy, vulnerability-handling process, secret/dependency scan, threat model, or release-integrity control is repository-visible.

## 10. Acquisition/Handover Readiness

A competent external team would currently struggle most with:

1. **Canonical source state:** default `main` is 257 commits behind the current authority, with many task branches and no tags/releases.
2. **Current truth discovery:** 290 Markdown files make present architecture, business rules, decisions and workflow expensive to reconstruct.
3. **Boundary ownership:** PREDMET is clear conceptually, but KATALOG, reminders, JSON transfer and parts of IRiU/SCENARIO orchestration are physically dispersed or oversized.
4. **Build/release reproducibility:** platform builds exist, but signing, versioning, artifact identity, release criteria and provenance are incomplete or task-report dependent.
5. **Dependency/legal posture:** no explicit IP/repository-use/distribution status, third-party license inventory, vulnerability process or SBOM.
6. **Security/data posture:** no concise data-flow/threat/privacy summary or vulnerability response path.
7. **Quality verification:** strong tests exist, but taxonomy and locked tiers are not encoded in CI or a standard guide.
8. **Technical debt:** risks are distributed across audits rather than one current register.

What an external team should not assume: that `main` is authoritative; that task reports are current specifications; that derivative outputs are business truth; that owner runtime PASS proves an internal cause; that public GitHub visibility grants reuse, modification or distribution rights; or that historical build PASS makes a releasable signed artifact.

## 11. Standard-by-Standard Assessment

| Candidate | Codex class | OPC use | Exclusion/limit |
|---|---|---|---|
| ISO/IEC 29110 Basic | **TAILOR / ADAPT** | Small checklist for project management, implementation, verification and closure | No certification/conformance claim; no duplicate work-product bureaucracy |
| arc42 | **ADOPT (tailored)** | One concise current architecture home | Merge/omit empty sections; no document per section |
| C4 | **TAILOR / ADAPT** | Context + Container + small Deployment baseline; components/dynamics only for difficult areas | No whole-code class diagram catalogue |
| Flutter official architecture | **ADOPT as principles** | Explicit responsibilities, controlled dependencies, testable UI/data/application boundaries | No forced MVVM conversion or universal use-case layer |
| ADR | **ADOPT lightweight** | Significant technical structure/NFR/dependency/interface decisions | Not business authority, owner log, task report or routine choice |
| Docs-as-code/minimum viable docs | **ADOPT** | Current product, domain, architecture, development, quality/release and security information in Git | Historical chronology excluded after reconciliation |
| GitHub controls | **ADOPT proportionately** | Canonical branch, required analyze/test checks, PR/ruleset; reviews scale with team | CODEOWNERS only with meaningful ownership; no false solo-review theater |
| ISO/IEC/IEEE 15289 | **TAILOR / ADAPT** | Information-purpose checklist and consolidation discipline | No file per information item |
| ISO/IEC/IEEE 42010 | **REFERENCE ONLY** | Concepts: stakeholder concerns, viewpoints, model consistency | No conformance claim or parallel architecture framework |
| ISO/IEC/IEEE 29148 | **TAILOR / ADAPT** | Business rules, invariants, acceptance examples and proportional traceability | No artificial REQ identifier for every sentence |
| ISO/IEC 25010 | **TAILOR / ADAPT** | Shared quality vocabulary and risk/acceptance checklist | No separate document per quality characteristic |
| NIST SSDF 1.1 | **TAILOR / ADAPT** | Dependencies, vulnerabilities, secrets, review, release integrity, provenance | Risk-ranked subset; no enterprise control theatre; do not operationalize draft 1.2 yet |
| ISO/IEC/IEEE 12207:2026 | **REFERENCE ONLY** | Lifecycle completeness/backbone vocabulary | Too broad for daily OPC process; no duplicated lifecycle system |
| ISO/IEC/IEEE 24748-5 | **REFERENCE ONLY** | Planning completeness for the one authoritative roadmap | No parallel plan |
| OpenSSF Scorecard | **REFERENCE ONLY** | Due-diligence/security heuristic | Score is not proof; solo code-review checks may be inapplicable |
| SPDX/SBOM | **ADOPT staged** | Generate machine-readable release inventory; prepare now | Do not commit a manually maintained stale SBOM |
| SLSA 1.2 | **DEFER formal levels** | Use concepts for later provenance maturity | Start with hashes/build record; formal attestation only when distribution model warrants |

## 12. Critique of Logos Candidate Profile

| Candidate | Logos classification | Codex classification | Agreement/disagreement and reason | OPC evidence | Overhead / benefit / risks |
|---|---|---|---|---|---|
| ISO/IEC 29110 Basic | Primary/adopt | **TAILOR / ADAPT** | **Resolved Logos↔Codex consensus.** Use it as the OPC process/lifecycle baseline, not as the branded identity of the entire development method, with no formal conformance claim or ISO-named duplicate work products. | Single product/team; extensive custom task gates; 290 docs | Medium overhead; useful lifecycle checklist. Adoption risk: bureaucracy/duplication. Non-adoption risk: inconsistent process—mitigated by tailored checklist. |
| arc42 | Primary/adopt | **ADOPT, compressed** | Agreement with tailoring. It maps well to actual blocks and can consolidate current truth. | Architecture/maps exist but are dispersed/stale | Low–medium maintenance; high onboarding benefit. Risk is template completion theatre; non-adoption preserves archaeology. |
| C4 | Context + Container default | **TAILOR: Context + Container + Deployment** | **Resolved Logos↔Codex consensus.** Deployment is baseline-worthy because OPC has dual Windows/Android runtime, local SQLite, filesystem/export behavior, installation and platform-specific boundaries. | Windows/Android, local DB, exports, notifications | Low overhead. Too many diagrams go stale; too few hide platform/data reality. |
| Flutter guidance | Adopt principles | **ADOPT as principles** | Agreement. Apply to bounded debt, not to re-platforming. | Large screens, cross-feature imports, repositories/services already partly present | Medium gradual benefit. Rewrite risk is high; non-adoption leaves coupling. |
| ADR | Adopt | **ADOPT lightweight** | Agreement with a hard boundary. PREDMET authority and owner business decisions belong in domain truth, not ADRs. | Current decision history mixed with task reports | Low overhead if rare. Overuse recreates diary; omission loses rationale. |
| Docs-as-code/MVD | Adopt | **ADOPT** | Agreement. This is the highest-value documentation correction. | 290 Markdown files, 131 task reports | Initial reconciliation is substantial; steady-state overhead low. Premature deletion risks knowledge loss. |
| Git controls | Adopt | **ADOPT after canonical-branch decision** | Agreement, with sequencing. Rules cannot safely target a stale default until authority is consolidated. | `main` 257 behind; one manifest workflow | Moderate setup, low recurring overhead; high regression/transfer benefit. |
| ISO/IEC/IEEE 15289 | Tailor | **TAILOR / ADAPT** | Agreement. Use information purpose, combine items. | Duplicate/chronological docs | Low overhead if used as checklist; high if turned into files. |
| ISO/IEC/IEEE 42010 | Tailor/reference | **REFERENCE ONLY** | **Resolved Logos↔Codex consensus.** Use its architecture-description concepts as reference discipline only; tailored arc42/C4 provide the operational implementation without a parallel 42010 system. | One in-process product, small team | Reference overhead low; direct adoption risks duplication. |
| ISO/IEC/IEEE 29148 | Tailor | **TAILOR / ADAPT** | Agreement. Use named invariants and links from rule → code area → tests at business-critical boundaries. | Rich owner policy, PREDMET truth, regression contracts | Moderate initial mapping; high drift-detection benefit. IDs everywhere would be harmful. |
| ISO/IEC 25010 | Tailor | **TAILOR / ADAPT** | Agreement. Use as review vocabulary and prioritized quality scenarios. | Reliability/data integrity/maintainability/security/platform parity are material | Low overhead; improves shared language. Checklist theatre is avoidable. |
| NIST SSDF | Tailor | **TAILOR / ADAPT, final 1.1** | Agreement, with version precision and risk prioritization. | No policy/scanning/SBOM; local sensitive data; release gaps | Moderate staged overhead; strong handover/security benefit. Full framework over-adoption would be disproportionate. |
| ISO/IEC/IEEE 12207 | Reference | **REFERENCE ONLY** | Agreement. It is a broad common framework and explicitly method-neutral; daily adoption would duplicate the smaller profile. | Small single-team product | Low reference cost; high operationalization cost. |
| ISO/IEC/IEEE 24748-5 | Reference | **REFERENCE ONLY** | Agreement. Use to audit the one roadmap, not create another. | Existing dependency roadmap and variants | Low benefit/cost as checklist; parallel-plan risk otherwise. |
| OpenSSF | Reference/later | **REFERENCE ONLY** | Agreement. Useful heuristic, not a primary standard or definitive score. | Public repo but solo/AI workflow makes some checks context-dependent | Low audit cost; score optimization could distort priorities. |
| SPDX/SBOM | Later maturity | **ADOPT staged; earlier** | **Resolved Logos↔Codex consensus.** Dependency inventory, third-party license inventory, explicit IP/repository-use/distribution status and automated update visibility are early standardization concerns; prepare SPDX/SBOM during standardization, with a machine-readable release SBOM required before commercial distribution or formal external handover. | 158 locked packages; no explicit IP status/third-party license inventory; EOL direct package | Low–medium automation cost; high due-diligence value. A manually maintained static SBOM is not required. |
| SLSA/provenance | Later maturity | **DEFER formal levels; adopt simple evidence earlier** | Partial agreement. Enterprise attestations are premature; artifact SHA, source SHA, tool versions and build record are not. | No tags, signing or artifact manifest | Simple evidence low cost/high value; formal levels currently disproportionate. |

Direct answers to the mandated questions:

1. ISO/IEC 29110 is relevant as the tailored OPC process/lifecycle baseline, not as the branded identity of the entire OPC development method.
2. No replacement heavyweight process is needed. Use a small OPC engineering profile assembled from process, architecture, quality and security practices.
3. 12207 is correctly reference-only.
4. arc42 is suitable if condensed; replacing it would add little.
5. C4 Context + Container + a small Deployment view is the agreed OPC baseline; additional views remain evidence-driven.
6. ADRs are appropriate only for architecturally significant technical choices and their rationale.
7. 29148 is useful through proportional invariant/acceptance/trace links, without identifier proliferation.
8. 25010 is valuable as vocabulary and prioritization, not a documentation tree.
9. SSDF 1.1 is proportionate as a selected overlay.
10. SPDX/SBOM and dependency/third-party license discipline move earlier into standardization; formal SLSA remains later.
11. Logos underemphasized release/versioning, explicit IP/repository-use/distribution status, third-party license inventory, data/privacy/threat modeling, canonical branch governance and backup/restore assurance.
12. No candidate requires outright rejection, but 29110 and 42010 must not become parallel bureaucratic systems.

## 13. Codex Proposed OPC Engineering Profile

The following profile is the independent technical recommendation. It is deliberately composite: no single standard captures OPC's product, architecture, domain authority, repository and security needs at proportionate cost.

| Element | Role / adoption | Scope and tailoring | What it changes | What it must not change |
|---|---|---|---|---|
| Tailored ISO/IEC 29110 Basic checklist | Process baseline — **TAILOR / ADAPT** | Map its project-management and implementation outcomes onto one lightweight OPC task lifecycle: authorize, baseline, design/impact, implement, verify, accept, close | Makes lifecycle outcomes explicit and auditable | No formal conformance claim, duplicate plans, mandatory document per work product, or replacement of owner authority |
| Docs-as-code + ISO 15289 information-purpose discipline | Information architecture — **ADOPT/TAILOR** | Maintain a small current-state set; combine information where readers and change cadence align | Replaces task chronology as active product navigation | No deletion before unique-knowledge reconciliation |
| Tailored arc42 | Architecture communication — **ADOPT** | One architecture document with concise goals/constraints/context/strategy/blocks/runtime/deployment/crosscutting/decisions/quality/risks/glossary; merge sparse sections | Provides the canonical current architecture view | No template-filling, duplicate architecture frameworks or full class catalogue |
| C4 | Visual notation — **TAILOR** | System Context, Container and Deployment baseline; selective Component/Dynamic diagrams for PREDMET lifecycle, SCENARIO application and transfer/restore only if text is insufficient | Makes system/platform/data boundaries visible | No diagram-per-package rule |
| Flutter official architecture principles | Source design criteria — **ADOPT** | Explicit UI/application/domain/data/platform responsibilities, inward dependency control, testable orchestration and use cases only where complex/reused | Guides bounded extraction of oversized/misplaced responsibilities | No MVVM rewrite, universal use-case layer, or folder changes without value |
| ISO 29148 proportional traceability | Business-rule discipline — **TAILOR** | Stable named business invariants, acceptance examples and links to responsible code/test suites | Makes PREDMET rules and derivative constraints verifiable | No parallel requirement authority or ID for every statement |
| ISO 25010 | Quality vocabulary — **TAILOR** | Prioritize data integrity/reliability, maintainability, security, usability, performance and platform compatibility as quality scenarios | Makes acceptance/risk language consistent | No characteristic-specific document set |
| Lightweight ADRs | Technical rationale — **ADOPT** | Only expensive, structural, crosscutting, dependency/interface or NFR decisions; status and supersession | Preserves durable technical rationale | No business decisions, task narratives, implementation logs or retroactive ADR mass-conversion |
| NIST SSDF 1.1 subset | Secure-development overlay — **TAILOR** | Dependency and third-party license ownership, secrets, vulnerability handling, review, integrity, release evidence and response | Creates proportional security responsibilities and evidence | No unsupported compliance claim or indiscriminate enterprise controls |
| Standard Git/repository controls | Enforcement — **ADOPT** | First choose canonical branch; then CI analyze/test gates, ruleset, PRs and review proportional to team; later CODEOWNERS | Replaces error-prone human-only enforcement | No ruleset on the wrong branch; no self-approval theatre |
| SPDX SBOM | Release/transfer inventory — **ADOPT staged** | Automate from lock/build at releases; retain versioned release artifact or attestation | Establishes machine-readable component and third-party license inventory | No manually edited static SBOM presented as current |
| 12207 / 42010 / 24748-5 | Completeness references — **REFERENCE ONLY** | Periodic profile/architecture/plan audit | Prevents blind spots | No parallel lifecycle, architecture or roadmap bureaucracy |
| OpenSSF / SLSA | Maturity references — **REFERENCE / DEFER** | Use Scorecard as heuristic; adopt simple build record now; reconsider formal SLSA when distribution volume/risk warrants | Establishes an incremental maturity path | No score chasing or premature attestations |

## 14. Target Repository Principles

Future repository organization should satisfy these principles before anyone proposes a target tree:

1. **Business truth first.** PREDMET remains master truth; SCENARIO, PARTE, PDFs, stock effects, reminders and exports remain modules/derivatives or services, never parallel authorities.
2. **Boundaries follow responsibility.** Name and locate code by stable architectural responsibility—business/domain, application orchestration, data/persistence, presentation, integration/export and platform—not by incidental utility naming.
3. **Dependencies are explicit and predominantly inward.** Presentation calls application/domain abstractions; infrastructure implements required services. Generic `core` must not depend on feature internals.
4. **One composition boundary.** Cross-feature wiring belongs in the application shell or explicit application workflows, not repeatedly in screens and repositories.
5. **Local-first and dual-platform remain first-class constraints.** Windows and Android share business logic while platform filesystem, notifications, installation and lifecycle behavior remain adapters with explicit parity expectations.
6. **Persistence history is protected.** Schema identity, migrations, recovery behavior and user-data compatibility are architectural assets, not cleanup targets.
7. **Locked contracts remain locked.** SCENARIO production and its regression contract are `DO NOT TOUCH` until separately authorized. Standardization cannot unlock it by implication.
8. **Intervene by evidence, not by fashion.** For each block, a later authorized program may retain, rename, move, split, merge, refactor, partially rewrite, fully reconstruct or remove it when architecture evidence shows a material gain in clarity, responsibility separation, maintainability, onboarding, testability, dead-code removal or long-term quality. File size alone is a signal, not a move order; preserve authoritative truth, verified behavior, compatibility, migrations, interoperability contracts and required regression guarantees.
9. **Generated code is not hand-written debt.** `database.g.dart` follows Drift generation ownership.
10. **Current state is the entry point.** README links to the small authoritative documentation set, build/test/release procedures and known risks.
11. **Automation enforces repeatable gates.** Human gates remain only for semantic/owner acceptance where automation cannot decide.
12. **Release artifacts are traceable.** Every distributable maps to source SHA, version, platform/toolchain, checks, dependency inventory and hashes.
13. **Historical and internal knowledge are separated.** The active product repository is not a task diary; transitional archives remain until reconciled.
14. **No standards theatre.** A move, layer, file, diagram or control needs a reader, risk or measurable maintenance benefit.

These are target principles, not a prescribed folder tree. The correct physical layout should be selected later through an owner-supervised architecture decision after the building-block boundaries and PODSETNIK semantics are settled.

## 15. Target Documentation Information Model

A mature OPC repository can be served by a compact information model. Filenames below are illustrative target homes, not authorized creation instructions.

| Information home | Required content | Separate file? |
|---|---|---|
| `README.md` | Product purpose, supported platforms, local-first model, quick start, canonical branch/release, and links to all authoritative homes | **Required** entry point |
| `docs/PRODUCT_AND_DOMAIN.md` | Product scope, glossary, PREDMET authority, modules/derivatives, business invariants, lifecycle and owner-approved current decisions | **Required**; business authority must be distinct from technical ADRs |
| `docs/ARCHITECTURE.md` | Tailored arc42 content; C4 views; blocks/dependencies; persistence; critical runtime flows; platform/deployment; crosscutting concepts; current risks | **Required**; one document unless it becomes genuinely unwieldy |
| `docs/DEVELOPMENT.md` | Environment, bootstrap, run, data/dev-data rules, platform specifics, source boundaries, targeted/full test selection and contribution workflow | **Required**; can absorb `CONTRIBUTING.md` while one maintainer |
| `docs/QUALITY_RELEASE.md` | Analyze/test tiers, locked regression contracts, build matrix, runtime acceptance, versioning, signing, artifact identity, release/rollback/backup-restore criteria | **Required before distribution**; testing and release can share until size justifies split |
| `SECURITY.md` | Supported versions, vulnerability reporting/handling, secrets/signing, dependency review and high-level data/privacy posture | **Recommended now; required before handover/distribution** |
| `docs/adr/` | Only accepted/superseded architecturally significant technical decisions | **Conditional, sparse** |
| `docs/KNOWN_RISKS.md` | One current technical-debt/risk register if it cannot remain usable inside architecture/quality docs | **Conditional** |
| Explicit IP/repository-use/distribution status + generated SBOM/release manifest | Ownership/use/distribution statement; third-party license/component inventory; artifact/source hashes | Explicit IP/repository-use/distribution status **required now**; third-party license inventory is an early concern; machine-readable SBOM **required before commercial distribution/handover**. The future source/product licensing model remains an owner/legal decision. |
| `CONTRIBUTING.md` | Standalone contribution process | **Conditional now; required before multi-developer handover** if `DEVELOPMENT.md` is insufficient |
| User documentation | Installation/use/backup/recovery instructions for end users | **Required before product distribution**, but outside the engineering-doc minimum if delivered separately |

The following do not belong in the final market-facing OPC product/engineering package after reconciliation: routine task reports, Codex prompts/handoffs, correction chronology, continuity recovery narratives, obsolete roadmap variants, human-gate boilerplate, pseudocode and its maintenance instructions, and repeated acceptance reports. Pseudocode remains an internal Tale/Logos control artifact through OPC and OPC Int development; it must not ship with the finished application or be presented as acquirer/developer handover documentation. Permanent incident evidence may be retained in a clearly separated archive only where auditability or unique knowledge justifies it.

## 16. Source Building-Block Matrix

| Current path / area | Responsibility | Key dependencies | Proposed building block | Boundary quality | Location quality | Change class | Notes |
|---|---|---|---|---|---|---|---|
| `lib/main.dart`, `lib/app.dart` | Startup, repository/service construction, routing | database, auth, settings, PREDMET, reminders | Application composition shell | Clear but central/manual | Good | **RECOMMENDED** | Keep one wiring boundary; extract only when composition complexity warrants |
| `lib/core/database/` | Drift schema v27, migration, seed/repair/recovery, DB identity | Drift/sqlite, domain tables | Persistence platform | Strong behavior; oversized implementation | Mostly good | **RECOMMENDED** | Split schema/migration/seed responsibilities later without changing history; generated file `DO NOT TOUCH` manually |
| `lib/features/predmeti/domain/`, `application/`, repository areas | PREDMET lifecycle/master business truth | persistence, policies, derivatives | PREDMET business core + application | Conceptually strong; physically broad | Mixed | **DO NOT TOUCH** authority; **RECOMMENDED** boundary clarification | No derivative may become authority |
| `lib/features/predmeti/core_v2/business_policy/`, `models/`, `rules/` | Reusable business policy/models/rules | PREDMET, repositories | Business policy kernel | Useful domain seam | Name/location dated | **RECOMMENDED** | Rename/move only after dependency map and tests; not cosmetic wholesale cleanup |
| `lib/features/predmeti/core_v2/scenario/` | SCENARIO contracts, policy, rules, reconciliation, persistence, transfer/application/UI | PREDMET, DB, IRiU/KATALOG | SCENARIO module | Conceptually coherent and locked | Obscured by `core_v2` and some UI mixing | **DO NOT TOUCH** | Formal lock controls; document present boundary now, revisit only by explicit unlock task |
| IRiU repository and presentation segments | Ordered IRiU rows, provenance/snapshots, prices, stock effects, UI | PREDMET, SCENARIO, KATALOG, DB, stock | IRiU application/module | Oversized and cross-domain | Mixed | **RECOMMENDED** | Preserve ordering invariant; later separate orchestration from persistence/UI |
| `lib/core/catalog/`, settings catalogue code, database seed code | Catalogue identity, seed/update/configuration and selection | DB, settings, IRiU | KATALOG service/data block | Hidden/dispersed ownership | Poor | **REQUIRED** logical ownership decision; physical move later | Define one owner and interfaces before more catalogue evolution |
| `lib/core/utils/json_export_import.dart` and transfer models | Full backup, single-PREDMET transfer, validation, filesystem/UI, serialization and coordinated DB mutation | auth, PREDMET, SCENARIO, PARTE, reminders, stock, DB | Interoperability/backup application service | Monolithic; dependency inversion | Misleading | **REQUIRED** bounded separation before substantial evolution/handover | Do not refactor during audit; first define transfer contracts and regression seam |
| `lib/features/predmeti/parte/` | PARTE domain, preparation, persistence, DOCX/PDF/UI | PREDMET, DB, document libraries | PARTE derivative/module | Relatively clear | Good | **DO NOT TOUCH** except evidence-driven refinement | Useful model for explicit sub-boundaries |
| `lib/features/predmeti/pdf/` and document generators | Standard PREDMET-derived documents | PREDMET models, pdf/printing | Document-generation derivative | Clear purpose; many sizeable files | Acceptable | **RECOMMENDED** | Keep derivative boundary explicit; consolidate shared rendering only with tests |
| `lib/features/podsetnik/presentation/`, `predmeti/reminders/` | Reminder UI and PREDMET-related reminder logic | PREDMET, notifications, settings | PODSETNIK/reminder application block | Hidden/split | Poor | **DO NOT TOUCH pending owner decision** | Trigger/signal semantics materially determine future boundary |
| `lib/features/stanje_robe/` | Stock state, effects/consequences | IRiU/PREDMET, DB | Stock module/derivative | Partly explicit; cross-coupled | Acceptable/mixed | **RECOMMENDED** | Make authority and effect direction explicit; avoid parallel PREDMET truth |
| `lib/features/auth/` | Users, roles/session/PIN/recovery UI/data/domain | DB, crypto | Identity/access block | Comparatively layered | Good | **RECOMMENDED** security review, not restructure | Legacy SHA-256 PIN design needs threat review in separate task |
| `lib/features/podesavanja/` | Firm/user/settings/catalog configuration and broad UI composition | auth, PREDMET, reminders, stock | Settings/configuration | Presentation composes many features | Mixed | **RECOMMENDED** | Move cross-feature orchestration to application shell/workflows when touched |
| `lib/core/config/`, `constants/`, `format/`, `theme/`, focused utilities | Shared configuration, formatting, theming and genuinely cross-feature helpers | Flutter and stable platform-independent types | Shared technical kernel | Mostly cohesive; `utils` is a mixed label | Mixed | **RECOMMENDED** | Keep only genuinely generic, dependency-light code here; do not create a dumping ground |
| `lib/features/setup/` | Initial application setup/orchestration | settings, persistence, app shell | Setup application workflow | Thin/explicit | Good | **COSMETIC ONLY** | No evidence supports moving it now |
| finance/statistics under PREDMET | Derived totals, aggregations and reports | PREDMET/IRiU | Finance/statistics derivative | Conceptual derivative; dispersed | Mixed | **RECOMMENDED** | Document as derivative; do not promote to authority |
| `android/`, `windows/` | Native runners, permissions, packaging/install | Flutter, notifications, filesystem | Platform adapters/deployment | Mostly standard; release gaps | Good | **REQUIRED** release hardening before distribution; source layout `DO NOT TOUCH` | Android debug release signing and unsigned Windows installer are blockers |
| `assets/` | Fonts/images/catalog resources | app/document UI | Product assets | Clear | Good | **DO NOT TOUCH** | Add rights/provenance inventory later |
| `tools/`, `scripts/` | Packaging, checks and task support | Flutter/PowerShell/Inno | Engineering tooling | Useful but not unified | Acceptable | **RECOMMENDED** | Standardize entry commands/document ownership later |
| `test/` | Unit/widget/contract/characterization/forensic regression tests | production code, fixtures, owner env gates | Quality/test infrastructure | Broad coverage; flat taxonomy | Poor discoverability | **RECOMMENDED** | Categorize/document without weakening locked Tier 2 contract |

No mass source move is `REQUIRED`. Required items above are boundary/ownership or release outcomes; physical changes must wait for a later authorized plan and preserved contracts.

## 17. Documentation Migration Matrix

This matrix uses exact documents for authority-bearing material and explicit groups/globs for repetitive classes. Together the rows cover the 290 Markdown files; the future migration task must generate a machine-checked per-file manifest before deletion. Grouping here avoids reproducing the chronology problem inside the audit.

| Current document / group | Unique knowledge | Current authority? | Target information home | Action | Keep temporarily? | Final OPC? | Internal know-how? | Owner decision needed? |
|---|---|---|---|---|---|---|---|---|
| `README.md` | Product identity, local-first model, basic links/workflow | Yes, entry point | `README.md` | Retain and later update after target docs exist | Yes | Yes | No | No |
| `OPC_CURRENT_DEVELOPMENT_STATE.md` | Current phase/status, accepted/locked work | Yes | README + architecture/domain + roadmap status | Merge current facts; keep until reconciliation verified | Yes | No as separate chronology | Partly | No |
| `OPC_SOURCE_OF_TRUTH_MAP.md` | Authority precedence and truth homes | Yes | Product/domain + development governance | Merge product authority; migrate method internally | Yes | No as separate final file | Yes, method | No |
| `OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` | Anti-drift controls and purpose | Active governance | Product/domain + internal playbook | Split durable product truths from governance method | Yes | Only migrated facts | Yes | No |
| `OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md` | Zero-baseline and owner authority reconstruction | Current governance authority | Product/domain current decisions + archive | Reconcile, then historical evidence | Yes | No | Yes, selected method | Only unresolved semantic deltas |
| `OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md` | Document classification rules/register | Active transitional authority | Migration manifest + internal playbook | Use to drive cleanup; retire after completion | Yes | No | Yes | No |
| `OPC_DOCUMENTATION_TRUTH_RECOVERY_*` | Corrections, conflicts, recovered unique truth | Transitional forensic evidence | Product/domain/architecture/decision/risk homes | Extract all surviving truth, then archive/remove from active docs | Yes | No | Selected lessons | Only listed unresolved items |
| `OPC_DOCUMENTATION_RECONCILIATION_AUDIT_AND_REMOVAL_MANIFEST.md` | Removal safety and reconciliation evidence | Transitional | Final migration manifest/archive | Retain until cleanup proof closes | Yes | No | Yes, reusable pattern | No |
| `ARCHITECTURE_OVERVIEW.md`, `OPC_MODULE_RELATIONSHIP_MAP.md`, `OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md` | Current blocks, relationships, authorities | Partly current; some drift | `docs/ARCHITECTURE.md` + product/domain | Merge against source/lock; supersede old views | Yes | No as separate set | No | Only conflicts |
| `OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`, `OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md` | Domain vocabulary, flows, rules/invariants | High, subject to newer owner decisions/source | `docs/PRODUCT_AND_DOMAIN.md` | Reconcile and consolidate | Yes | No as duplicate pair | No | Conflicting/outstanding semantics only |
| `OPC_OWNER_DECISION_INDEX.md`, guide/report/records/queue | Owner decisions and unresolved semantics | Mixed current/historical | Product/domain current truth; ADR only for technical choices | Resolve current decisions, retain provenance only where justified | Yes | Only consolidated truth | Governance method | Yes for unresolved queue, not routine migration |
| `OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md` | Current dependency roadmap | Yes, but some post-lock drift | One authoritative roadmap outside final steady-state docs while development continues | Reconcile before execution; never create parallel plan | Yes | During active development | Planning method later | Yes for sequencing/semantics |
| plan drafts/revised/final-candidate variants | Evolution and rejected/changed planning choices | Historical/transitional | Roadmap archive | Archive after unique deltas checked | Yes until check | No | No | No unless unexplained conflict |
| `OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md` | Known plan/source deltas | Transitional | Updated authoritative roadmap + archive | Apply findings, then historical evidence | Yes | No | Reusable reconciliation method | No |
| `OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`, `OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`, other pseudocode files | Logical-functional continuity, decomposition, invariants and drift comparison | Strictly internal Tale/Logos development-control authority; not product or handover authority | Maintained internal pseudocode set through OPC/OPC Int; then general internal development/governance/jumpstart know-how | Refresh against lock/roadmap; do not prematurely delete; never ship with finished application | Yes | **No** market-facing OPC package | Yes, method/templates | No for meaning; owner approval for retirement timing |
| `OPC_SCENARIO_MODULE_LOCK.md`, `OPC_SCENARIO_MODULE_LOCK_REPORT.md` | Lock identity, invariant, test/runtime evidence | Current lock authority/evidence | Architecture/domain + quality contract; permanent lock evidence archive as justified | Retain while locked; migrate enduring facts without weakening contract | Yes | Selected current contract; report may archive | No | Explicit owner unlock only |
| `OPC_TECHNICAL_EXECUTION_STANDARD.md`, `GIT_WORKFLOW_ARC.md` | Current task/test/Git discipline | Active governance | `docs/DEVELOPMENT.md`, `QUALITY_RELEASE.md`, repository automation; internal playbook | Consolidate product workflow; move AI/gate method internally | Yes | Only product workflow | Yes | Canonical branch decision |
| `OPC_IMPLEMENTATION_STOP_LIST.md` | Current prohibitions/open semantic dependencies | Active governance | Roadmap/current risk/domain | Reconcile active stops; retire closed chronology | Yes | Only active constraints | Partly | Yes where business semantics remain open |
| `PRODUCT_DIRECTION.md` | Product scope/direction | Current owner authority | README + product/domain | Merge stable current direction | Yes | Information yes, file conditional | No | Only unresolved direction |
| `OPC_DOCUMENTATION_ARCHITECTURE_AND_DEVELOPMENT_PLAN_AUDIT.md` | Earlier architecture/schema-22 audit | Historical/stale | Archive | Preserve as evidence until unique deltas checked | Yes | No | No | No |
| `docs/tasks/*.md` (131 task reports) | Implementation/audit/acceptance chronology; occasional unique evidence | Mostly historical evidence, not current spec | Current docs, ADRs, risk register or archive according to unique content | Per-file extract; then archive/remove from active product docs | Yes until manifest proof | No, except legally/audit-justified archive | Some process lessons | Only unresolved business/acceptance conflicts |
| Other `*REPORT*.md`, `*AUDIT*.md`, correction/restore reports | Forensic findings, incidents, acceptance and recovery history | Mixed; first-match authority rules apply | Current architecture/domain/quality/risk or historical archive | Classify per post-zero rules; extract unique current facts | Yes | Usually no | Selected lessons | Only current conflict |
| Local ignored root `OPC_*.md` and restore-point text | Legacy locked summaries/restore chronology | Not automatically current | Reconciliation input/archive outside active repo | Compare to current authority, do not import wholesale | Yes until checked | No | No | Only unreconciled unique owner truth |
| Local `SCENARIO_MAP` owner map/control report | 1008-scenario owner map and validation evidence | Owner source/evidence; relation to product spec must be explicit | Domain/SCENARIO current spec or governed fixture/reference + archive | Reconcile map identity/version and durable invariants | Yes | Selected governed artifact may remain | Method no | Yes if map-vs-implemented semantics conflict |
| Templates/manifests not otherwise listed | Task/governance boilerplate | Transitional | Internal know-how or repository automation | Retain while active; remove from final product when replaced | Yes | No | Yes | No |

Required migration safety rule: no document is deleted until its current-authority status, unique knowledge, conflicts and target home are recorded in a reviewed per-file manifest and every `OWNER DECISION REQUIRED` item is resolved or explicitly preserved.

## 18. Standards Fit/Gap Matrix

| Area | Current state | Target principle | Evidence | Gap | Severity | Recommended action | Implementation risk | Dependency |
|---|---|---|---|---|---|---|---|---|
| Repository entry point | Thin README; stale default branch | One current entry point and canonical branch | Git/docs | Authority and navigation ambiguity | **Critical** | Reconcile branch authority, then update README links | Wrong branch promotion | Owner canonical-branch decision |
| Architecture documentation | Multiple maps/reports, some stale | One tailored arc42 current architecture with minimal C4 | Docs/source | No single source-aligned view | **High** | Consolidate after source block validation | Knowledge loss/oversimplification | Documentation manifest |
| SOURCE organization | Real blocks exist but predmeti is broad; core imports features; large screens/services | Responsibility-based blocks and controlled dependencies | Source/import map | Hidden/misleading boundaries | **High** | Define dependency rules; bounded extraction later | Regression, schema/lock damage | Architecture decision, tests |
| Business/domain documentation | Rich but dispersed; PREDMET authority explicit | One authoritative domain home, derivatives clearly subordinate | Owner/docs/source | Reader must reconstruct current truth | **Critical** | Reconcile current business rules/invariants | Redefining semantics | Owner conflict resolution |
| Requirements/traceability | Rules and tests exist without stable proportional map | Named critical invariants linked to code/test | Docs/tests | Drift detection manual | **High** | Create business-critical trace table during reconciliation | ID bureaucracy | Domain consolidation |
| ADR/decision history | Owner/technical/task decisions mixed | Sparse technical ADRs; business choices in domain truth | Docs | Rationale hard to distinguish | **Medium** | Classify significant technical decisions; no retroactive mass conversion | History-preservation bias | Architecture doc |
| Developer onboarding | Workflow spread across governance/task docs | One development guide | Docs | High archaeology cost | **High** | Consolidate environment/run/data/test/platform rules | Omitting special cases | Current workflow validation |
| Build | Manual documented commands and historical PASS | Automated repeatable builds/toolchain record | Config/reports | No CI build evidence or reproducibility statement | **High** | Start analyze/test CI; add platform build cadence later | CI platform cost | Canonical branch, secrets |
| Test | Broad suite; flat taxonomy; locked Tier 2 | Discoverable tiers/categories and required automated gates | 70 Dart tests/docs | Human-only selection/enforcement | **High** | Document taxonomy, preserve exact lock, automate baseline | Slow/flaky CI, weakened lock | Test inventory |
| Release | Installer/scripts; Android debug release signing; no tags/hashes/runbook | Signed/versioned traceable release | Platform/config/Git | Not commercially releasable | **Critical** | Define release/signing/version/artifact process before distribution | Key custody and platform variance | Owner distribution model |
| Windows/Android parity | Shared Flutter code; manual platform acceptance | Explicit parity matrix and platform adapters | Source/runtime docs | Differences not centrally documented | **Medium** | Add deployment/parity view and platform acceptance criteria | False equivalence | Architecture/quality docs |
| Persistence/data | Robust v27 migrations/recovery, huge DB file | Protected migration history and documented data lifecycle | Source/tests | Ownership/readability and data handling gaps | **High** | Document schema/data flows; split implementation only later | User-data loss | Backup/migration tests |
| JSON interoperability | Comprehensive but 2,792-line integration monolith | Explicit transfer contracts and application-service boundaries | Source/tests | Core inversion, coupled mutation/UI/filesystem | **Critical** | Define/extract bounded services before major evolution | Import/restore regression | Golden/contract tests, architecture decision |
| Dependency/IP status | Lockfile hashes; 158 packages; EOL direct package; no explicit IP/repository-use/distribution status, third-party license inventory or SBOM | Owned updates, explicit IP/repository-use/distribution status, third-party license inventory, SPDX release SBOM | Manifests/pub.dev | Legal/security/maintenance opacity | **Critical** | Document status without selecting a future source/product license; automate dependency and third-party license inventory/update review; SBOM before handover | Upgrade incompatibility, wrong rights/licensing assumption | Owner/legal authority; separate dependency task |
| Security | Ignore rules and recovery crypto exist; no policy/threat/vuln process | Tailored SSDF controls and data/threat model | Source/config | No discoverable posture/response | **High** | Create scoped security responsibilities and checks later | Overclaiming security | Data-flow and release model |
| Repository controls | One task manifest workflow | Ruleset and required status checks on canonical branch | `.github`, Git | Code quality human-only | **Critical** | CI first, ruleset second, review/CODEOWNERS as team grows | Lockout or wrong target branch | Canonical branch |
| Technical debt visibility | Debt distributed across audits | One current risk/debt view | Docs/source | Priorities hard to verify | **Medium** | Consolidate source-backed risks with owner/status | Turning archive into backlog | Architecture reconciliation |
| Current vs historical docs | 290 MD; 131 task reports | Small current set + separated archive/internal know-how | Docs inventory | Chronology dominates product | **Critical** | Per-file migration manifest, extract then archive | Destroying unique knowledge | Owner reconciliation |
| Pseudocode | Intentional system-visibility layer but stale after Phase 9 | SHA-based source↔pseudocode↔roadmap comparison at milestones | Pseudocode/source/roadmap | Current comparison unreliable | **High** | Refresh through lock; maintain through OPC/OPC Int | Treating it as spec or over-modeling | Roadmap reconciliation |
| Roadmap/governance | Dependency plan strong; variants and post-lock drift | One reconciled authoritative plan; product controls separated from internal method | Docs | Latest completion/carrier facts not uniformly reflected | **High** | Reconcile before new roadmap work; do not replace plan in this audit | Parallel roadmap | Owner decisions, pseudocode refresh |

## 19. Required vs Recommended vs Deferred Changes

### Standard repository files and controls classification

| File/control | Classification | Reason |
|---|---|---|
| `README.md` | **REQUIRED NOW** | Existing entry point must eventually identify canonical state and link to current product/domain/architecture/development/release information |
| Intellectual-property / repository-use / distribution status | **REQUIRED NOW** | Document who owns the source, what public GitHub visibility means, whether reuse/modification/distribution rights are granted, and that absence of an open-source license is not permission to reuse. The future model may be proprietary, source-visible/restricted, commercial, acquisition-based, open-source or contractual; Codex/Logos must not select it. |
| CI: automated analyze + baseline tests | **REQUIRED NOW** | Existing correctness rules are human-only; automation should precede protected-branch enforcement |
| Protected canonical branch/ruleset | **REQUIRED NOW**, after canonical-branch decision and CI | Current `main` is stale, so sequencing is essential |
| Architecture/domain docs discoverable from README | **REQUIRED NOW** through reconciliation | PREDMET authority and system boundaries must not require archaeology |
| `CONTRIBUTING.md` | **REQUIRED BEFORE MULTI-DEVELOPER HANDOVER**; optional as separate file now | `DEVELOPMENT.md` can carry the same information while the team is small |
| `CODEOWNERS` | **REQUIRED BEFORE MULTI-DEVELOPER HANDOVER** when real ownership exists | It adds value with multiple maintainers/areas; a sole-owner placeholder is control theatre |
| Pull-request review | **RECOMMENDED NOW**, **REQUIRED BEFORE MULTI-DEVELOPER HANDOVER** | Independent review is valuable when an independent reviewer exists; required checks provide the present minimum |
| `SECURITY.md` | **RECOMMENDED NOW**; **REQUIRED BEFORE HANDOVER/COMMERCIAL DISTRIBUTION** | A vulnerability path, supported versions and security ownership become essential to consumers/acquirers |
| Dependency/update automation | **RECOMMENDED NOW** | Controlled update PRs make EOL/vulnerability drift visible; merges still require compatibility verification |
| SBOM generation | **RECOMMENDED NOW**; **REQUIRED BEFORE COMMERCIAL DISTRIBUTION OR HANDOVER** | Lockfile data makes it tractable and it materially supports third-party license/security review |
| Release procedure, versioning, tags, signing and artifact hashes | **REQUIRED BEFORE COMMERCIAL DISTRIBUTION** | Current build evidence is not a traceable signed release process |
| Changelog/release notes | **RECOMMENDED**; required only once external releases need consumer-facing deltas | Git/task history is not an adequate product release narrative |

### Required now, before further substantive development

- Reconcile the canonical branch/default-branch authority and the post-lock roadmap/current-state record.
- Build a reviewed per-file documentation migration manifest; consolidate PREDMET/domain truth before cleanup.
- Define the target building blocks and allowed dependency directions before any source move.
- Restore pseudocode/roadmap comparison to the locked baseline.
- Establish automated `flutter analyze` and baseline test checks on the eventual canonical branch.
- Document explicit intellectual-property, repository-use and distribution status; defer the actual future licensing/distribution model to owner/legal decision.
- Record ownership of the JSON interoperability boundary and KATALOG block; do not yet move files.

### Required before multi-developer handover

- Current architecture/domain/development/quality documentation and one risk register.
- Protected canonical branch/ruleset, PR workflow and meaningful ownership/CODEOWNERS.
- Test taxonomy and CI evidence; environment/bootstrap reproducibility.
- Dependency update/vulnerability/third-party-license process and machine-readable inventory.
- Bounded remediation of the JSON integration monolith and other critical ownership ambiguities, with tests.
- A forensic dead-code and superseded-implementation audit before removing implementation residue. `Unused now ≠ proven dead`; migrations, backward compatibility, legacy JSON/PREDMET import, restore/recovery, old-version upgrade paths, platform compatibility and supported data formats require explicit evidence.

### Required before commercial distribution

- Correct Android/Windows release signing and key custody; version/tag/release policy.
- Release runbook, artifact/source hashes, toolchain/build record, rollback/backup-restore criteria.
- Explicit IP/repository-use/distribution status, third-party license inventory and generated SPDX SBOM; no particular source/product license is selected by this audit.
- Security/vulnerability handling, data/privacy/threat review and supported-version policy.
- Platform acceptance matrix and installation/update behavior.

### Recommended

- Tailored arc42+C4 documentation; selective ADRs; automated dependency PR cadence; technical-debt register; categorized tests; bounded extraction of oversized screens/repositories when next touched.

### Deferred

- Formal SLSA level/attestation, OpenSSF score optimization, exhaustive component/code diagrams, comprehensive retroactive ADRs, a universal use-case layer, wholesale `lib/` reorganization, and any SCENARIO move/unlock.

## 20. Risks of Standardization

| Risk | Control |
|---|---|
| Standards theatre creates more files than it removes | Require a reader, decision or control outcome for every artifact; combine 15289 information items |
| Evidence-based restructuring breaks imports, migrations, transfer formats or locked behavior | Agree blocks and dependency/migration analysis first; choose the appropriate retain/move/split/refactor/rewrite/reconstruct scale; preserve contracts and regression guarantees; explicit SCENARIO exclusion |
| Consolidation silently loses unique business truth | Per-file manifest, conflict queue, owner reconciliation and reversible archive before removal |
| arc42/C4/ADR go stale | Make current docs part of change acceptance; only model material views/decisions |
| ISO language produces false compliance claims | Use alignment/tailoring labels; normative audit only with licensed text and explicit scope |
| CI is too slow or brittle | Stage targeted/analyze/full gates by risk; preserve environment-gated forensic tests separately |
| Security controls become disproportionate | Prioritize data, dependencies, secrets, vulnerabilities and releases through SSDF outcomes |
| Canonical-branch changes lose authoritative history | Use non-destructive Git reconciliation and owner-approved promotion; never assume `main` |
| Pseudocode is mistaken for product specification | Preserve the owner-approved role and clear precedence labels |
| Premature PODSETNIK organization freezes wrong semantics | Keep PREDMET/reminder area deliberately open until trigger/signal decision |

## 21. Risks of Not Standardizing

- A new team begins from stale `main` or an obsolete plan and silently diverges.
- PREDMET authority is weakened by derivative logic or duplicated documentation.
- Unique knowledge remains trapped in task reports and individual continuity methods.
- JSON/restore and database changes become progressively harder to test and reason about.
- Release artifacts cannot be tied confidently to reviewed source, dependencies or signing authority.
- Unknown IP/distribution, third-party licensing or vulnerability posture blocks acquisition or commercial distribution.
- Human-only gates fail under team growth or owner unavailability.
- Pseudocode/roadmap drift loses its intended regression-detection value.
- Oversized screens/repositories and cross-feature coupling increase defect and onboarding cost.
- Security/data decisions remain implicit until an incident or due-diligence request forces rushed reconstruction.

## 22. Owner Decisions Still Required

These are decisions the audit cannot make on technical evidence alone:

1. Which branch/commit becomes the canonical default after preserving current task-branch authority and history?
2. What future IP/licensing/distribution model (private, source-visible/restricted, commercial binary, acquisition, open-source or another contractual model) is intended?
3. What are the authoritative PODSETNIK trigger/signal semantics, and which reminders are PREDMET-derived versus independently owned?
4. How should the local 1008-scenario owner map be versioned and related to implemented SCENARIO definitions/tests?
5. Which unresolved items in the owner decision queue remain live after the SCENARIO lock?
6. What signing identities/key-custody model and supported release channels will Windows and Android use?
7. Which historical incident/acceptance records require permanent retention for owner, legal or audit reasons after knowledge migration?

The owner should not be asked to choose among ISO frameworks. The technical recommendation is provided here; owner decisions concern product authority, distribution, semantics and risk acceptance.

## 23. Proposed Sequence for the Later Standardization Program

This is a sequencing recommendation, not a separate implementation roadmap and not permission to execute it.

1. **Authority and documentation reconciliation.** Preserve SCENARIO lock, branch/SHAs, database compatibility, test contracts and document inventory; reconcile current local + GitHub authority, current-state documents, owner decisions and historical knowledge before removing anything.
2. **Pseudocode↔roadmap↔locked-source synchronization.** Bring the strictly internal pseudocode to the same source/roadmap baselines and record progress, drift and regression results.
3. **Target architecture/building-block design.** Approve responsibilities, boundaries, dependency directions, deployment views, KATALOG ownership, JSON integration seam and the unresolved PODSETNIK boundary.
4. **Current→target dependency and migration analysis.** Identify data, imports, contracts, migrations, compatibility obligations, platform effects and regression seams before choosing physical changes.
5. **Forensic dead-code/superseded-implementation audit.** Distinguish `unused now ≠ proven dead`; explicitly check migrations, backward compatibility, legacy JSON/PREDMET import, restore/recovery, old-version upgrade logic, platform compatibility and supported data formats.
6. **Evidence-based intervention decision for each block.** Decide whether to retain, rename, move, split, merge, refactor, partially rewrite, fully reconstruct or remove as proven dead. The evidence determines the scale; the program must not prescribe that all changes are incremental or that all changes are large.
7. **Controlled implementation.** Execute the approved intervention with appropriate contracts, reviews, test updates and owner authorization. This audit authorizes none of these implementation steps.
8. **Full regression/data/interoperability/runtime acceptance.** Verify behavior, persistence and migration compatibility, JSON/restore contracts, Windows/Android acceptance, locked regression guarantees and release evidence before treating the restructuring as complete.
9. **Standard controls and roadmap resumption.** Establish CI, dependency/third-party license/SBOM, security and release controls, then resume the authoritative dependency roadmap only where the adopted profile or owner decisions alter dependencies.
10. **Internal/final-product separation.** After OPC and OPC Int completion, keep reusable governance and pseudocode methods in internal development/jumpstart know-how and retain only reconciled current product information in the market-facing package.

Substantial refactoring, partial rewrite, larger SOURCE restructuring or replacement is valid when the architecture evidence supports it. The invariant is preservation of authoritative business truth, verified behavior, compatibility, migrations, interoperability contracts and required regression guarantees—not preservation of every existing implementation.

PODSETNIK/PREDMET semantics are a genuine sequencing gate: reminder boundary finalization and related PREDMET organization should remain open until signal ownership and derivation rules are explicit. This does not prevent documentation reconciliation, CI, dependency governance or an evidence-based restructuring decision elsewhere.

## 24. Explicit Non-Implementation Statement

This audit changed no production Dart code, tests, database content/schema/migrations, Android or Windows configuration, dependencies, CI, scripts, assets, README, existing documentation, branch, tag, remote or SCENARIO lock. It did not run full tests, analyzer or builds because no behavior changed and the evidence needed was available through read-only source, Git, documentation and official-source inspection.

The only authorized file created is:

`docs/OPC_SOFTWARE_ENGINEERING_STANDARDS_REPOSITORY_DOCUMENTATION_FIT_GAP_AUDIT_REPORT.md`

Starting branch/HEAD: `task/OPC-SCENARIO-MODULE-LOCK` at `4615546e12a2b8dd8d23890fbb252abff0462838`.  
Final branch/HEAD: unchanged; the report is an uncommitted local working-tree addition at audit completion.  
Remote publication status: **not published**. No commit or push was authorized or performed.

The current project remains maintained as both the local project environment and the public GitHub repository until the owner defines the exact future transition, acquisition or distribution model. This correction changed only the Git worktree report; it did not create a second local synchronization copy. That fact does not mean local documentation ceased to matter: applicable local + GitHub synchronization requirements remain active. Earlier post-zero wording that could be read as permanently abolishing dual maintenance is superseded or ambiguous; the newer explicit owner clarification controls.

## 25. Final Codex Recommendation

Following the completed Logos↔Codex reconciliation, recommend a **small tailored OPC engineering profile**, not a single branded standard:

- ISO/IEC 29110 Basic as a tailored lifecycle/process checklist, not formal conformance or primary process bureaucracy;
- one docs-as-code current-state information model shaped by ISO 15289 purpose discipline;
- compressed arc42 architecture with C4 Context, Container and Deployment views;
- Flutter responsibility/dependency principles applied incrementally;
- PREDMET-centered business invariants and proportional 29148 traceability;
- ISO 25010 quality vocabulary and sparse technical ADRs;
- NIST SSDF 1.1 selected controls, standard Git/CI enforcement and early dependency/third-party license/SBOM readiness;
- 12207, 42010, 24748-5, OpenSSF and SLSA as references or later maturity paths.

Before further substantive development, reconcile current authority/documentation, refresh pseudocode against the locked source and roadmap, decide the canonical branch, agree actual building blocks/dependency rules, and automate the current analyze/test baseline. Before handover or commercial distribution, close release signing/version/provenance, explicit IP/repository-use/distribution status, third-party license inventory/SBOM, security/data and dependency-governance gaps.

Do not reorganize SOURCE for visual neatness. Preserve PREDMET authority, locked SCENARIO behavior and contracts, database/migration compatibility, dual-platform logic and existing verified seams. The future repository should become easier to understand because responsibilities and current truth are explicit—not because every historical artifact has been renamed or every Flutter example pattern has been imposed.

AUDIT PASS — LOGOS↔CODEX TECHNICAL CONSENSUS REACHED — OWNER CLARIFICATIONS INCORPORATED — READY FOR OWNER REVIEW OF STANDARDIZATION PROGRAM
