# OPC authoritative plan reality reconciliation report

Date: 2026-08-12

Task branch: `task/OPC-AUTHORITATIVE-PLAN-REALITY-RECONCILIATION`

Verified source branch: `task/OPC-SCENARIO-CROSS-PLATFORM-GROBLJE-FORENSICS`

Base SHA: `78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9`

Origin source-branch SHA at task start: `78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9`

Final documentation SHA: recorded by the Git completion handoff for the commit
containing this report (a commit cannot contain its own SHA).

Scope: documentation only; no application source, test, schema, asset, build or
runtime behavior change.

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no; current authority and implemented scenario ownership were reconciled

Database ownership affected:
- no; database evidence was read only and no user database was opened

JSON transfer affected:
- no runtime change; incomplete SCENARIO carrier wiring was classified

Windows/Android parity affected:
- no runtime change; evidence was classified separately by platform

Future OPC Web affected:
- no

Terminology drift risk:
- yes; the old plan could be read as renaming OPC to `OPC Srbija`; corrected so
  the application name remains `OPC`

Implementation allowed:
- no

Required gate before implementation:
- product terminology and documentation semantic parity only

## A. Sources reviewed

### Authority, continuity and plan sources

Read and reconciled:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md` in full at the
  base SHA (1,619 lines);
- `docs/OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md`;
- `docs/OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md`;
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`;
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`;
- `docs/OPC_OWNER_DECISION_REPORT.md`;
- `docs/OPC_OWNER_DECISION_INDEX.md`;
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`;
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`;
- `docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md`;
- `docs/GIT_WORKFLOW_ARC.md`;
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`;
- `docs/OPC_POST_ZERO_ARCHITECTURE_DECISION_GATE_SYNTHESIS.md`;
- `docs/OPC_PHASE_1_ARCHITECTURE_DECISION_GATE_EVIDENCE_MATRIX.md`;
- `docs/OPC_DATABASE_REFERENTIAL_INTEGRITY_AND_PREDMET_DEPENDENCY_AUDIT.md`;
- `docs/OPC_POST_ZERO_PREDMET_LIFECYCLE_REFERENTIAL_DESIGN.md`;
- `docs/OPC_PREDMET_DEPENDENCY_MAP.md`;
- `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md`.

The authority inventory proves that no external/local parallel documentation
authority remains: repository `PROJECT_DOCS`, external `PROJECT_DOCS` and
`_IMPORT_TEST_INPUTS` are absent; `SOURCE/docs` is the single active Git working
copy. No local synchronization target was invented.

### Pseudocode and lifecycle/restore sources

Relevant contracts and control flows were checked in:

- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`;
- `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`;
- `docs/OPC_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_PSEUDOCODE.md`;
- `docs/OPC_PODSETNIK_CONTROL_FLOW_AND_USER_CONFIRMATION_PSEUDOCODE.md`;
- `docs/OPC_POST_ZERO_PREDMET_LIFECYCLE_REFERENTIAL_DESIGN.md`;
- `docs/OPC_CANONICAL_DATABASE_RECOVERY_PSEUDOCODE.md`;
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`;
- relevant Phase 4–11 restore-point/task reports under `docs/tasks/`.

### Material post-plan report chain

The complete recent SCENARIO/KATALOG/runtime chain was reviewed and its latest
Git commit was verified:

| Report | Latest report commit |
| --- | --- |
| `OPC_SCENARIO_FORENSIC_AUDIT_REPORT.md` | `19dcc68d580c086d9cc74921afa5af8381b9872d` |
| `OPC_SCENARIO_NOVA_IMPLEMENTACIJA_REPORT.md` | `edb34bf4965ba206e98df06e34cf296bfdb52ea9` |
| `OPC_SCENARIO_RUNTIME_INTEGRITY_UI_CORRECTIONS_REPORT.md` | `250edf26d19dc1f47a56e573e725e37a120f5692` |
| `OPC_SCENARIO_OPERATIONAL_RECOVERY_REPORT.md` | `f5b39f653c714a5ab9afce3b24bc0041470b6b87` |
| `OPC_SCENARIO_MAP_1008_GOLDEN_CONSISTENCY_GATE_REPORT.md` | `ba9a38631cac81e1d13dba90f5d7f91353ca1c15` |
| `OPC_KATALOG_FIKSNA_CENA_CRNINA_IRIU_IZNOS_REPORT.md` | `3b4442b76ef263eb68b1a6e688309cc650847329` |
| `OPC_SCENARIO_IRIU_CHANGE_DIFF_LIFECYCLE_REPORT.md` | `cc212bda8f8a44dc6d113a64270941c74ac860dd` |
| `OPC_CUMULATIVE_VALIDATION_BUILD_RUNTIME_PREPARATION_REPORT.md` | `176599177371de63d88d0bdaf1ae402c2462b61d` |
| `OPC_SCENARIO_CHARACTERIZATION_ZERO_FAIL_BUILD_REPORT.md` | `ae310d2dc16ca41b6b35f48ce3f700c00fb2f724` |
| `OPC_RUNTIME_RECONCILIATION_SCENARIO_PERSISTED_MAP_OSNOVNI_PRICE_REPORT.md` | `02c0dc3fe2c04f213094887f4914b4a0f4516911` |
| `OPC_SCENARIO_END_TO_END_RUNTIME_FORENSIC_STABILIZATION_REPORT.md` | `f012b0831d1dc4594061f32d17bd41915610197d` |
| `OPC_SCENARIO_RELEASE_RUNTIME_FORENSIC_RESOLUTION_REPORT.md` | `9ec34cbe62fe0405df581e1d64fe8c64eaa0113a` |
| `OPC_SCENARIO_HANDOFF_DB_FORENSICS_LIVE_PROOF_REPORT.md` | `c12663d6b2827491f4debf445153cf40d796d74d` |
| `OPC_ANDROID_RELEASE_BUILD_RESOLUTION_REPORT.md` | `4fd7ea27bd42704b05d52a53c7389af497ee1bc6` |
| `OPC_ANDROID_REAL_DEVICE_STARTUP_RUNTIME_ACCEPTANCE_REPORT.md` | `ecc2a73bd0368a607a5be98bb4a66f98a73010a6` |
| `OPC_SCENARIO_CROSS_PLATFORM_GROBLJE_FORENSICS_REPORT.md` | `78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9` |

Git history from 2026-08-01 onward was also inspected for omitted material
SCENARIO persistence, transfer-envelope, carrier-audit, UI, migration,
characterization and runtime commits.

### Source and test areas cross-checked

- SCENARIO contracts, repository, rule engine, production reconciliation
  service and operational UI under
  `lib/features/predmeti/core_v2/scenario/`;
- PREDMET and IRiU repositories and UI hand-off paths;
- scenario tables and schema migrations under `lib/core/database/`;
- JSON production serializers/importers in
  `lib/core/utils/json_export_import.dart` and pure transfer contracts;
- lifecycle implementation in `predmeti_repository.dart` and
  `test/predmet_completion_state_characterization_test.dart`;
- `ThemeMode.system` in `lib/app.dart`;
- Windows runner search for a native mutex/single-instance guard;
- current Android/package version facts in `pubspec.yaml`, Gradle and manifest;
- golden, E2E, lifecycle, KATALOG/IRiU, JSON and migration tests cited by the
  recent reports.

No private path, customer data, PIN, endpoint or runtime row content from local
forensic evidence was copied into the authoritative plan.

## B. Premise-verification findings

| Old premise | Finding | Evidence / correction |
| --- | --- | --- |
| Gate 0 activation is the current next dependency | `HISTORICAL ONLY` | Post-zero program and many implementation/runtime tasks advanced far beyond it. |
| Existing scenarios are still hard-coded | `SUPERSEDED` | Data-driven 1,008 MAP definitions, editable repository/UI, kernel and runtime path exist. |
| SCENARIO belongs under `PODEŠAVANJA` | `FALSE` | Owner-approved/current source path is operational `MODULI → SCENARIO`. |
| Phase 9/10/11 pure slices are the current endpoint | `SUPERSEDED` | Production reconciliation service, persistence, E2E and live runtime arrived later. |
| User must manually select/apply a scenario | `FALSE` | PREDMET facts derive the scenario; OPEN-PREDMET selection opens the controlled production hand-off, not a business override. |
| PREDMET snapshot/provenance is future work | `FALSE` for DB/runtime; `PARTIAL` for JSON | Snapshot/provenance tables and runtime are live; carrier serialization remains absent. |
| Future SCENARIO application wiring is next | `FALSE` | Windows and Android owner runtime PASS exist. |
| SCENARIO runtime is unproven | `FALSE` | Live Windows proof and physical Android proof exist; full eight-axis parity passed. |
| GRADSKO→LOKALNO is a source/DB defect | `FALSE` | Initial Android value was LOKALNO; controlled GRADSKO save remained GRADSKO across all eight axes. |
| Full SCENARIO carrier support is complete | `FALSE` | Pure envelope/adapter exist, but production roots remain Single-PREDMET 6/7 and backup 8 without SCENARIO blocks. |
| KATALOG FIKSNA/CRNINA/amount model is future | `SUPERSEDED` | Implemented and test-proven, including price snapshot and manual override. |
| Automatic `ZAVRŠEN` policy is unresolved | `SUPERSEDED` | Explicit-only immutable lifecycle is owner-decided and implemented; runtime acceptance remains owed. |
| A focused lifecycle test closes the phase everywhere | `FALSE` | Technical implementation and per-platform runtime acceptance must remain separate. |
| PODSETNIK finding requires an immediate isolated patch | `FALSE` | It belongs to the planned complete signal/lifecycle-aware PODSETNIK program. |
| Later runtime work proves Windows/Android performance acceptance | `FALSE` | Required current-tip measurements/profiling were not performed. |
| Successful restore incidents equal final release rehearsal | `FALSE` | They are partial evidence; final release-candidate rehearsal remains open. |
| RAČUN PDF is not implemented | `FALSE` | Exporter/action exists; FIRMA availability/default and scope remain open. |
| Windows system theme is absent | `FALSE` | Shared `ThemeMode.system` exists; runtime parity/contrast audit remains open. |
| Large progressive refactor is mandatory | `FALSE` | Architecture decision is retain + evidence-gated bounded refactor; significant bounded SCENARIO refactor already landed. |
| Stage 2 licensing cleanup blocks stable OPC v.1 | `FALSE` | It remains non-blocking unless new source evidence proves otherwise. |
| Dual currency belongs to international work | `FALSE` | Locked requirement places MODUL DVE VALUTE before stable OPC v.1 gate. |
| Product should be named `OPC Srbija` | `FALSE` | Product/app name remains `OPC`; phrase is internal gate shorthand only. |

## C. Reality matrix

| Dependency | Intended outcome | Current actual state | Windows | Android | Remaining work | Ordering verdict |
| --- | --- | --- | --- | --- | --- | --- |
| Governance/authority | One trustworthy control plane | Reconciled plan + report; Git docs remain sole local authority | N/A | N/A | Maintain semantic parity | First/current |
| Architecture decision | Choose correction/refactor/rewrite strategy | Retain + progressive evidence-gated refactor; full rewrite rejected | N/A | N/A | Reassess only on evidence | Complete; no longer predecessor |
| PREDMET authority | Sole business truth and protected dependencies | Preserved; SCENARIO applied state is PREDMET-owned | Proven in live scenario path | Proven in live scenario path | Referentials/carriers/final parity | Continues as invariant |
| Referential integrity | Coordinated dependent lifecycle | Hard-delete and scoped restore slices pass; FK remains off; some RI gates remain | Hard-delete PASS | Hard-delete persistence/isolation PASS; prior scoped restore PASS | Classify/close only release-required RI work | Before final gate where risk remains |
| Windows single-instance | Prevent concurrent canonical DB access | Audit complete, implementation absent | OPEN | N/A | Native mutex + installer coordination + runtime | Early blocker |
| Windows performance | Measurable acceptable startup/exit | Approx. 8–9 s login and slow exit observed; no current-tip acceptance | PARTIAL | N/A | Instrument, target, correct only if needed | Before release gate |
| Android PARTE performance | Smooth representative runtime | Source risk map exists; current focused profiler absent | N/A | PARTIAL | Profile representative devices | Evidence gate before any fix |
| IRiU/KATALOG performance | Acceptable picker/open behavior | Characterized but owner slowdown not decomposed | PARTIAL | PARTIAL | Timing trace | Evidence gate before any fix |
| Completion lifecycle | Explicit immutable final status | Implemented and focused-test proven | Runtime owed | Runtime owed | Include in final platform acceptance | No owner-policy blocker |
| SCENARIO core | Editable owner policy and safe reconciliation | Complete technical implementation | Build/technical PASS | Build/technical PASS | Regression protection | Complete |
| SCENARIO runtime | Production caller and platform proof | Owner/live PASS | PASS | PASS | None absent regression | Complete |
| 1,008 consistency | Exact owner map | Golden and E2E 1,008/1,008 | PASS | Shared core + live tuple PASS | Keep gate green | Complete |
| KATALOG/IRiU price | Fixed/catalog prices and amount rules | Implemented and test-proven | Technical PASS | Technical PASS | Final runtime parity | Complete technical |
| SCENARIO JSON | Portable snapshot/provenance | Pure contracts only; production carrier absent | OPEN | OPEN | Root/schema integration, rollback, round-trip | Required before final rehearsal |
| Signal model | Complete derived readiness/reminder facts | Incomplete | OPEN | OPEN | Owner-confirm meanings | Before PODSETNIK |
| PODSETNIK | Informed lifecycle-aware reminders | Partial architecture/restore corrections; full model absent | OPEN | OPEN; ZAVRŠEN notification finding retained | Full program | After signal model |
| Single-PREDMET JSON UI | Correct action ownership | Transfer exists; relocation remains | OPEN | OPEN | Move to PREDMET menu, preserve schema | Product completeness |
| Final backup/restore | Release confidence | Successful scoped evidence only | PARTIAL | PARTIAL | Current release-candidate rehearsal | Gate blocker |
| NALOG CVEĆARI | Owner-defined document | No standalone generator proven | OPEN | OPEN | Owner content/scope | Owner decision first |
| Standard PDFs | Readable consistent documents | Existing generators; refinement open | OPEN | Shared | Per-document typography acceptance | Product completeness |
| RAČUN policy | Firma-controlled availability within limited scope | Exporter exists; policy/default open | PARTIAL | PARTIAL | Owner decision + bounded implementation | Product completeness |
| Theme | Shared system rule | Source uses system theme; runtime audit open | PARTIAL | PARTIAL | Runtime parity/contrast | Before final UX parity |
| UI/UX | Coherent cross-platform experience | Short scenario impressions only | OPEN | OPEN | Full audit | Before final gate |
| Contextual help | Screen-specific guidance | Product direction only | DEFERRED | DEFERRED | Design after UX audit | Not automatic blocker |
| Dual currency | RSD/EUR runtime-capable OPC v.1 | Not implemented | OPEN | OPEN | Full locked contract | Required before gate |
| Refactor | Stabilize where needed | Several bounded refactors done | Evidence-gated | Evidence-gated | No roadmap rewrite | Not standalone predecessor |
| Stage 2 cleanup | Remove dead licensing code | Not done; restrictions remain retired | DEFERRED | DEFERRED | Optional cleanup | Non-blocking |
| Final parity | Same business result | SCENARIO proven, whole-product final pass absent | OPEN | OPEN | Release-candidate matrix | Gate blocker |
| Identity/update | Releasable product continuity | Current technical IDs exist; final owner policy absent | OPEN | OPEN | Owner decision; name OPC | Gate blocker |
| Stable OPC v.1 gate | Close Serbian-market baseline | OPEN | Required | Required | Actionable checklist in plan §9 | Before Int |
| OPC_v.1_Int | International product line | Not started | DEFERRED | DEFERRED | Starts post-gate | Correctly deferred |
| Signing/handover | Professional release continuity | Open | OPEN | OPEN | Identity/key custody/runbook | Post product decisions |

## D. Major plan corrections

1. Replaced accumulated append-only chronology with a current state section,
   one dependency line, a full reality matrix and actionable gate.
2. Protected all completed SCENARIO work from repetition and recorded exact
   Windows/Android runtime boundaries.
3. Corrected the opposite SCENARIO carrier error: database/runtime support is
   complete, production JSON carrier integration is not.
4. Separated technical lifecycle completion from missing platform runtime
   acceptance.
5. Attached the `ZAVRŠEN` notification finding to the future full PODSETNIK
   program instead of authorizing an isolated patch.
6. Retained evidence-first performance requirements; later runtime smoke was
   not promoted to performance acceptance.
7. Classified existing RAČUN exporter versus still-open availability/business
   policy and kept NALOG CVEĆARI owner-gated.
8. Reclassified theme work as runtime verification of existing shared system
   behavior.
9. Made MODUL DVE VALUTE an explicit stable-v1 predecessor.
10. Removed any plausible rename instruction: the application remains `OPC`.
11. Made refactor bounded and evidence-gated; Stage 2 cleanup remains
    non-blocking.
12. Converted the First Product-Line Gate into a concrete closure checklist.

## E. Completed work protected from repetition

- post-zero authority reset and architecture decision;
- broad code/architecture review and PREDMET dependency mapping;
- explicit-only `ZAVRŠEN` source implementation;
- SCENARIO MODULI placement and editable policy repository;
- OSNOVNI PAKET + scenario additional-package model;
- all 1,008 owner-map combinations and independent golden oracle;
- PREDMET-owned snapshot/provenance and controlled reconciliation;
- manual/legacy/other-module row protection and non-retroactivity;
- production caller hand-off through OPEN-PREDMET selection;
- Windows live SCENARIO proof;
- Android physical-device startup/navigation/SCENARIO proof;
- full eight-axis GRADSKO/LOKALNO parity correction;
- FIKSNA/CRNINA/price snapshot/amount/manual-override model;
- current 393-pass/7-skip/0-fail technical baseline and release builds;
- Android build-environment incident resolution and in-place upgrade proof.

## F. Remaining blockers for stable OPC v.1

Current dependency order:

1. Windows single-instance/installer running-app data-integrity contract.
2. Close or explicitly defer remaining referential/lifecycle items based on
   release risk; include explicit completion in platform runtime acceptance.
3. Current-tip performance measurement and bounded correction only where an
   owner-approved target fails.
4. Production SCENARIO integration in Single-PREDMET and full-backup JSON.
5. Complete signal model, then full lifecycle-aware PODSETNIK upgrade.
6. Remaining JSON relocation, documents/policies, system-theme verification and
   full cross-platform UI/UX audit.
7. MODUL DVE VALUTE with Windows/Android/JSON/document parity.
8. Final release-candidate business-semantic parity and backup/restore rehearsal.
9. Owner app identity/version/update-channel decision and release baseline.
10. Separate Windows and Android owner runtime acceptance; close the stable OPC
    v.1 gate.

## G. Non-blocking debt

- Stage 2 dead package/licensing code cleanup;
- broad RI-3/FK work not proven necessary for the release candidate;
- broad refactor/partial rewrite without a specific failing quality boundary;
- contextual Help/User Guide implementation beyond design evaluation;
- OPC Web and international product-line implementation;
- cosmetic improvements not required for business clarity or accessibility.

## H. Owner decision queue

Current unresolved decisions only:

- measurable Windows startup/exit and Android PARTE acceptance targets after
  profiling evidence;
- NALOG CVEĆARI content and output scope;
- RAČUN FIRMA availability/default policy;
- complete signal meanings for PODSETNIK;
- EUR activation timing and eligible open-PREDMET conversion treatment;
- final app identity/version/update channel, while name remains OPC;
- release branch/tag and publisher/signing-key custody.

Resolved/superseded queue items removed from current plan: lifecycle relation,
automatic completion, SCENARIO ownership/application/placement, product naming,
dual-currency position and Stage 2 blocking status.

## I. New findings

| Finding | Classification | Destination |
| --- | --- | --- |
| Production JSON roots do not yet carry the implemented SCENARIO snapshot/provenance | `BLOCKING FOR OPC v.1` | Existing SCENARIO carrier parity program |
| Android generated a new reminder for an already `ZAVRŠEN` PREDMET | `BELONGS TO EXISTING FUTURE PROGRAM` | Complete signal/lifecycle-aware PODSETNIK upgrade |
| GRADSKO/LOKALNO mismatch report was a selected-state reading error | `HISTORICAL / NO ACTION` | Acceptance discipline; require all eight axes |
| Shared `ThemeMode.system` already exists | `NON-BLOCKING BEFORE OPC v.1` as implementation; runtime parity remains gate evidence | Theme/UX verification program |
| Current technical package/version (`com.tale.opc_v4`, `4.0.0+1`) is not itself the final owner release policy | `OWNER DECISION REQUIRED` | App identity/version/update-channel gate |

## J. OPC v.1 → OPC_v.1_Int boundary

The plan now explicitly prevents international implementation before stable OPC
v.1 closes. MODUL DVE VALUTE remains on the Serbian-market side of the boundary.
`OPC_v.1_Int` later reuses its proven contract for language/country/document and
multicurrency profiles. It does not create an early source fork or duplicate
PREDMET/data core. The product is still named `OPC`.

## K. Documentation parity

Updated authorities:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md` — rewritten as
  the current operative map;
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md` — replaced stale Phase 11/runtime-
  pending state with the reconciled current summary;
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md` — points plan/status/report roles to current
  authority;
- `docs/OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md` — registers this
  reconciliation report as active continuity evidence and marks its original
  numeric inventory snapshot historical;
- this report — evidence matrix, corrections and Git closure record.

Not updated:

- historical reports and pre-zero owner indexes, because rewriting their past
  evidence would destroy provenance;
- application source, tests, schema, assets and runtime configuration;
- any external/local parallel docs target, because the authority inventory
  states none exists.

## Change matrix

| Change | Reason/evidence | Dependency | Owner status | PREDMET/migration/parity impact |
| --- | --- | --- | --- | --- |
| Plan rewrite | 2026-08-05–12 report chain and source cross-check | Whole program | Preserves locked decisions | Documentation only |
| SCENARIO marked runtime-complete | Windows + physical Android live reports | SCENARIO | Owner runtime PASS per platform | Protects PREDMET snapshot/provenance |
| JSON carrier marked partial | Production serializer constants/content | JSON/SCENARIO | Accepted carrier decisions; technical wiring open | Future schema/parity work required |
| PODSETNIK finding attached to full program | Android notification evidence | Signals/PODSETNIK | Signal meanings remain owner-gated | No runtime change |
| Product naming clarified | Explicit task/owner instruction | First gate/identity | Locked: app name OPC | No package/UI change |
| Dual currency retained pre-gate | Locked plan/task instruction | Currency | Owner decision locked; activation details open | Future migration/JSON/parity work |

## Validation record

Repository validation after the documentation edits:

- all referenced repository paths: PASS (wildcard classification patterns are
  intentionally patterns, not literal file references);
- report commits: PASS via `git log -1 -- <path>`;
- source/report baseline: PASS; local/origin both `78e04f4...` at task start;
- stale active plan phrase search: PASS; matches that remain are explicit
  negative rules or historical/superseded classifications;
- one-line dependency order versus detailed sections: PASS;
- active owner queue versus current decisions: PASS;
- private/sensitive path scan of added current docs: PASS;
- trailing-whitespace scan and `git diff --check`: PASS;
- intended-documents-only diff: PASS; five documentation files only;
- repository-wide `scripts/validate_opc_manifest_gate.py`: baseline NOT PASS on
  numerous untouched historical `docs/tasks/` reports that predate/omit the
  required blocks; this task adds no `docs/tasks/` report and this top-level
  report contains both required manifest blocks;
- no Flutter build/test: correct for documentation-only scope;
- remote SHA and clean worktree: confirmed by the Git completion handoff.

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
- yes; documentation only

Terminology preserved:
- yes; application name is explicitly `OPC`

OPC Web remains outside current implementation scope:
- yes

Source changes within scope:
- yes; documentation files only

If not compliant, classify:
- not applicable

## Final verdicts

- `AUTHORITATIVE PLAN READ IN FULL — PASS`
- `CURRENT REPORT CHAIN REVIEWED — PASS`
- `SOURCE/TEST REALITY CROSS-CHECK — PASS`
- `TECHNICAL PREMISE CHALLENGE — PASS`
- `OWNER DECISIONS PRESERVED — PASS`
- `STALE CURRENT-STATE CLAIMS REMOVED/RECLASSIFIED — PASS`
- `COMPLETED WORK PROTECTED FROM REPETITION — PASS`
- `SCENARIO CURRENT REALITY — RECONCILED`
- `PODSETNIK FINDINGS — ATTACHED TO FUTURE FULL PROGRAM`
- `MODUL DVE VALUTE BEFORE OPC_v.1_Int — CONFIRMED`
- `APPLICATION NAME REMAINS OPC — CONFIRMED`
- `STABLE OPC v.1 PREDECESSORS — EXPLICIT`
- `NON-BLOCKING DEBT — EXPLICIT`
- `OWNER DECISION QUEUE — CURRENT`
- `OPC_v.1_Int BOUNDARY — EXPLICIT`
- `DOCUMENTATION SEMANTIC PARITY — PASS`
- `APPLICATION SOURCE CHANGED — NO`
- `REMOTE SHA — CONFIRMED`
- `WORKING TREE — CLEAN`
