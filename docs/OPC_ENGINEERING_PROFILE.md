# OPC Engineering Profile

**Status:** `CURRENT AUTHORITATIVE PROJECT POLICY`
**Adoption:** Logos↔Codex technical consensus, owner-approved for the Phase 1 documentation baseline
**Conformance statement:** OPC claims no formal ISO/IEC/IEEE, NIST, C4, arc42, SPDX, OpenSSF or SLSA certification/conformance by publishing this profile.

This profile is a pragmatic composite. It improves clarity, traceability, maintainability, security and handover readiness without creating standards-named bureaucracy or overriding OPC business authority.

## Adopted profile

| Element | OPC adoption | Tailoring and exclusions |
|---|---|---|
| ISO/IEC 29110 Basic | **TAILOR / ADAPT as process baseline** | Lightweight lifecycle checklist for authorize/baseline/design/implement/verify/accept/close; no branded identity, formal conformance claim or duplicate ISO work products |
| Docs-as-Code | **ADOPT** | Current information homes maintained with code in the active local + GitHub model; history is migrated before retirement |
| ISO/IEC/IEEE 15289 | **TAILOR / ADAPT** | Organize around information purpose and combine items where useful; no file per information item |
| arc42 | **ADOPT, compressed/tailored** | One current architecture home covering goals, constraints, context, blocks, runtime, deployment, crosscutting concepts, decisions, quality, risks and glossary |
| C4 | **TAILOR / ADAPT** | System Context, Container and small Deployment baseline; Component/Dynamic/Code only where materially useful |
| Flutter architecture guidance | **ADOPT principles only** | Explicit responsibilities, controlled dependencies, testability and bounded extraction; no automatic MVVM or universal use-case layer |
| ISO/IEC/IEEE 29148 | **TAILOR / ADAPT** | Named business invariants and proportional rule→source→test traceability; no artificial identifier for every sentence |
| ISO/IEC 25010 | **TAILOR / ADAPT** | Quality vocabulary and scenarios for suitability, reliability/data integrity, maintainability, security, usability, performance and compatibility |
| Lightweight ADRs | **ADOPT selectively** | Durable technical structure, dependency, interface, NFR and construction decisions only; business authority remains in product/domain docs |
| NIST SSDF 1.1 | **TAILOR / ADAPT** | Dependency, vulnerability, secrets, review, release-integrity and response practices proportional to local product risk |
| SPDX/SBOM | **STAGED ADOPTION** | Early dependency/third-party license inventory and preparation; machine-readable release SBOM before commercial distribution/formal handover; no manual static SBOM |
| ISO/IEC/IEEE 12207, 42010, 24748-5 | **REFERENCE ONLY** | Vocabulary/completeness checks; no parallel lifecycle, architecture-description or roadmap bureaucracy |
| OpenSSF / SLSA | **REFERENCE / LATER MATURITY** | Heuristic and incremental provenance references; simple build records/hashes before formal levels where justified |

## Permanent cross-cutting application

This adopted engineering profile is a permanent cross-cutting development
control for the remainder of OPC development, not a temporary documentation
cleanup phase. Every substantive change is interpreted, implemented, verified
and closed through the parts of the profile relevant to its scope and risk:

`business/domain authority → requirements/traceability → architecture/data contract → implementation → verification → runtime/acceptance where applicable → quality/release → authoritative current-state documentation`

Applicability must be explicit and proportional. A task records which links in
this chain are material, the evidence or acceptance needed for them, and why a
link is not applicable when it is omitted. The profile does not require an
artifact for every link, a standards-named document per activity, or work that
does not improve task truth, safety or reviewability.

The Context Harness, HUMAN GATE, internal pseudocode and task-local `REVIEW`
evidence support application of this profile; they are internal control and
evidence mechanisms, not replacements for engineering standards, product
authority or current-state documentation. Task-local review evidence remains
non-authoritative until relevant current facts are reconciled into the
appropriate information home.

This permanent use reduces dependence on chronology archaeology, chat/session
memory and manual reconstruction so OPC remains current-state understandable,
traceable, architecturally explicit, verifiable, maintainable, handover-ready,
progressively release/distribution-ready and finishable in reasonable time. It
does not create a formal certification or conformance claim.

## Operating principles

1. Current documentation describes current OPC, not the chronology of how it was built.
2. PREDMET remains master business truth and derivatives remain subordinate.
3. Source architecture is documented honestly before a later target-tree decision.
4. Evidence determines whether a later block is retained, moved, split, merged, refactored, rewritten, reconstructed or removed as proven dead.
5. `Unused now ≠ proven dead`; compatibility, migrations, legacy formats, recovery and supported platforms require evidence before removal.
6. Human/owner controls remain for semantics and acceptance that automation cannot decide.
7. Future gaps are stated as gaps and are not represented as implemented controls.
8. Internal Tale/Logos/Codex development-control methods remain separate from final market-facing product documentation.

## Required information homes

- [`README.md`](../README.md): concise entry point and documentation map.
- [`OPC_PRODUCT_AND_DOMAIN.md`](OPC_PRODUCT_AND_DOMAIN.md): product/domain authority and invariants.
- [`OPC_ARCHITECTURE.md`](OPC_ARCHITECTURE.md): current architecture and deployment.
- [`OPC_DEVELOPMENT.md`](OPC_DEVELOPMENT.md): environment, workflow, source authority and validation process.
- [`OPC_QUALITY_RELEASE.md`](OPC_QUALITY_RELEASE.md): quality, regression, builds, runtime and release gaps.
- sparse `docs/adr/` only when a durable technical decision needs a standalone rationale.
- [`OPC_PHASE1_DOCUMENTATION_MIGRATION_AUTHORITY_MANIFEST.csv`](OPC_PHASE1_DOCUMENTATION_MIGRATION_AUTHORITY_MANIFEST.csv): per-file authority/disposition evidence.
- [`OPC_PHASE1_ARCHIVE_AND_INTERNAL_GOVERNANCE_CLASSIFICATION.md`](OPC_PHASE1_ARCHIVE_AND_INTERNAL_GOVERNANCE_CLASSIFICATION.md): transitional archive and internal-method separation.
- [`OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md`](OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md): public boundary record for local-only pseudocode control.

This profile governs documentation and code evolution throughout the remainder
of OPC development after the applicable task scope, owner authority, tests,
data compatibility and release gates are established. It does not itself
authorize pseudocode refresh, SOURCE restructuring, dead-code removal,
CI/security/release implementation or SCENARIO unlock.
