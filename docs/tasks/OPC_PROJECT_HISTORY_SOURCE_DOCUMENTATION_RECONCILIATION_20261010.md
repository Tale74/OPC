# OPC v1.5 Project History, Source and Documentation Reconciliation

**Classification:** current supporting engineering evidence; it is not product, business, roadmap or implementation authority.

**Scope cutoff:** the accepted SCENARIO/BIOHAZARD physical closure and the OPC NIGHT UI/UX correction package, reported through 2026-10-10.

**Current product state:** implementation complete for the reported bounded corrections; automated QA green; Logos review acceptance is OWNER-reported; physical runtime for the NIGHT UI/UX changes remains pending OWNER verification.

## 1. Purpose and evidence boundary

This record connects the existing information homes, current source, protecting tests, available review evidence and historical milestones. It does not create product requirements, change source behavior, select a roadmap item or claim new runtime/QA execution.

Evidence is classified as follows:

| Class | Meaning in this record |
|---|---|
| SOURCE CONFIRMED | Directly checked in the current active source tree; describes implementation only. |
| OWNER AUTHORITY CONFIRMED | Already established in the current product/domain home or explicit OWNER task instruction. |
| QA EVIDENCE CONFIRMED | Existing task evidence was physically inspected or its containing review ZIP manifest was independently re-hashed. QA was not rerun. |
| RUNTIME EVIDENCE CONFIRMED | Existing named physical evidence package was integrity-checked; the package's bounded acceptance claim was not replayed. |
| DOCUMENTATION ALIGNED | Current authority or supporting documentation expresses the checked boundary. |
| HISTORICAL ONLY / SUPERSEDED | Accurate at its dated checkpoint, but not the current product/runtime state. |
| PARTIALLY VERIFIED | The source or evidence supports only the named slice. |
| RUNTIME VERIFICATION DEBT | No physical runtime claim is made for the identified behavior. |
| EVIDENCE GAP / AUTHORITY GAP | Available source/evidence cannot settle the stated question; no assumption is promoted to policy. |

Current source establishes current implemented technical behavior. OWNER authority establishes required business meaning. Existing tests and reports establish only their named scope. The two accepted task packages listed in §3 were re-hashed in this reconciliation; their contained QA/runtime execution was not repeated.

## 2. Historical chronology and provenance

The current local branch history, current-state authority, dated task records and the two accessible closure packages establish this bounded chronology. The dates in older reports remain historical evidence rather than newly reproduced events.

| Period | Evidence-backed milestone | Classification and current interpretation |
|---|---|---|
| 2026-09-18 | Post-drift recovery formally closed; clean-baseline transition published. | Current recovery plan is formally closed and no longer roadmap sequencing authority. The normal OWNER roadmap governs future selection. Git history includes baseline commit d98d277 and subsequent closure publications. |
| 2026-09-19–25 | Current v1.5 active-source control, F-09, PREDMET actions, RAČUN, Scenario/KATALOG baseline, LISTA, PARTE and DVE VALUTE preparation/deferral were recorded in the current homes and dated task evidence. | Current source/docs and named tests support bounded implementation claims; DVE VALUTE implementation remains deferred to finalization. Detailed authority is in OPC_PRODUCT_AND_DOMAIN.md, OPC_ARCHITECTURE.md, OPC_CURRENT_DEVELOPMENT_STATE.md and linked task records. |
| 2026-09-26–30 | Editing-integrity work, PARTE runtime blocker documentation, SCENARIO applied-state and carrierless historical-integrity correction were separately closed/published. | Keep their acceptance scope separate. Earlier runtime-pending statements are not evidence against the later SCENARIO physical closure. The accepted SCENARIO correction does not authorize a general kernel unlock. |
| 2026-10-01 | REFUNDACIJA PIO text-only correction closed. | Current-state and quality homes describe it as a bounded text correction with its recorded QA/runtime scope. |
| 2026-10-03 | Android UX Direction 2 microcopy/literal cleanup published at commit c37b7d2. | This is the current branch HEAD and upstream-tracking ref at task intake. The task's later source candidate is uncommitted and mixed. |
| 2026-10-06 | SCENARIO later-reopen and bounded UI correction candidate was documented with automated evidence. | Historical intermediate candidate; later Oct 9 SCENARIO physical closure supersedes the relevant SCENARIO pending status, while other UI runtime debt remains. |
| 2026-10-09 | SCENARIO/BIOHAZARD correction received a bounded physical Android closure; NIGHT UI/UX correction work completed focused/full QA and Windows/Android builds. | SCENARIO closure is accepted for its named disposable scenarios. NIGHT implementation/build/test evidence does not establish physical PARTE Narrow gesture, persistence, photo-fluidity or save/refresh behavior. |
| 2026-10-10 | OWNER supplied the Logos final QA/review acceptance and instructed this project-wide documentation reconciliation. | This task records that OWNER-supplied acceptance; it did not independently conduct a Logos review or repeat product QA/runtime. |

Git inventory at intake: local branch codex/opc-v1.5-clean-baseline at c37b7d23541408414b6061e6cdb257039762ce43, tracking origin/codex/opc-v1.5-clean-baseline with local tracking counts 0/0. The local repository has two local branches, 174 remote-tracking branches and no tags. origin/HEAD points to the historical task/OPC-RR011-ANDROID-TEST-LANE-INITIALIZATION-CORRECTION ref at ec19ded; origin/main is at 80294ea. The configured origin URL is https://github.com/Tale74/OPC.git. A fresh ls-remote request was attempted but the environment could not connect to github.com; the displayed tracking-ref equality is therefore local cached evidence, not a fresh remote verification.

The remote branch names were inventoried, not treated as current implementation authority. This report does not claim an exhaustive source review of every historical remote task branch. Historical predecessor SOURCE, BACKUPS, RECOVERY, QUARANTINE and REVIEW remain provenance/evidence only; no donor material was used.

## 3. Reproduced artifact integrity checks

The following read-only checks were performed during this reconciliation:

| Artifact | Reproduced result | What this does not mean |
|---|---|---|
| REVIEW/OPC_SCENARIO_BIOHAZARD_DEFECT_CLOSURE_20261009_PHYSICAL_COMPLETE.zip | 768,650 bytes; SHA-256 350FC182999FADCF48A701FEF2CFBECE2AFF4EBD6F27708DC7BFA7ADB8C85195; ZIP opened; 19/19 manifest-listed hashes and lengths matched. | No SCENARIO runtime, build or QA was rerun. Package evidence remains bounded to its physical closure matrix. |
| REVIEW/CURRENT_TASK/OPC_NIGHT_UI_UX_CORRECTION_20261009.zip | 29,068 bytes; SHA-256 DA791C3A31886DABE3EFAC025B42D9202A86B06E2FA1C0EE55CBE285726646F6; ZIP opened; 15/15 manifest-listed hashes and lengths matched. | No NIGHT runtime, build or QA was rerun. This review package is not regenerated or modified by this task. |

The NIGHT package records focused UI tests 14/14 PASS, Flutter analyzer PASS, final full serial suite 637 PASS / 9 SKIP / 0 FAIL, Windows release PASS and Android production release PASS. These are accepted carried-forward results, not executions from this documentation task. The package records a first full-suite timeout, a focused 5/5 rerun and subsequent full serial passes; the timeout is retained as an intermediate attempt, not the final state. The reported app.so hash is ABE75452B99D3CDBF18FC9C403F2631D600F0FED7DD3669287512C91A4664A80. The reported APK hash is CDE7D0FCF164FB4C66194798D5560A44168D4BA65738CA8E2BAFC60866260876.

OWNER's task instruction reports that Logos accepted the correction package and its internal consistency. That review outcome is recorded as supplied authority; it is not presented as a newly retrieved review artifact.

## 4. Current system inventory and traceability

The table is a source/documentation navigation map, not a claim that each feature received a new full audit. Existing MODULE CONTRACTS remain the detailed truth-boundary authority. Source entry points below were checked against current implementation; protecting tests are named where present.

| Area | Required behavior / truth boundary | Current implementation and persistence | Protecting evidence and limit |
|---|---|---|---|
| App and platform foundations | One local-first Flutter product on Windows and Android; shared Dart business logic with platform adapters. | main.dart initializes Flutter/locale and AppDatabase before OpcApp; app.dart builds the application/session flow. Native runners and plugins provide platform services. | OPC_ARCHITECTURE.md §§2–3, 7; deployment/build records are platform/artifact-specific. No new platform runtime was executed. |
| Users, PIN, roles and FIRMA | Local session/access context must not replace PREDMET business truth or invent cross-device authority. | features/auth contains login, session, recovery and security repositories; PODEŠAVANJA holds firm/settings and role-gated controls. | session_router_user_state_refresh_test.dart and current module contracts. No new security audit or independent roles acceptance was run. |
| PREDMET lifecycle and contacts | PREDMET is the sole case truth; lifecycle and related cleanup are explicit; derivatives consume it. | PredmetiRepository applies updates transactionally, rejects immutable terminal states and skips an update when the durable row is equal. KontaktLica rows are PREDMET-associated and surfaced in NARUČILAC. | PREDMET lifecycle, hard-delete, transfer and contact coverage; see OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md contracts 001–006, 017–018. No PREDMET data was read or changed in this task. |
| SQLite / Drift | Schema and migrations preserve supported local data and compatibility. | AppDatabase currently declares schemaVersion 36; creation seeds required KATALOG categories and support rows, while upgrades run explicit migrations/repairs. | canonical_database_migration_recovery_test.dart, migration fixtures, database_catalog_seed_idempotency_test.dart and recovery tests. No DB/schema change or migration run occurred. |
| SCENARIO | Current PREDMET facts govern evaluation; applied snapshot/provenance are durable derivation evidence; manual/unrelated rows stay protected; uncertain history remains fail-closed. | OwnerScenarioInput normalizes the nine inputs; the kernel requires completeness; IriuRepository gates open-time intent using status, completeness, snapshot and trusted evidence, then plans/commits managed-row changes. | owner_scenario_policy_kernel_test.dart, scenario persistence/reconciliation/atomicity/current-change tests, and the integrity-checked physical closure ZIP. The physical PASS is limited to the closure's named OPELO/bootstrap/BIOHAZARD cases; no map-wide runtime claim is made. |
| KATALOG | KATALOG owns stable article/category identity and current configuration; selected IRiU snapshots are not retroactively rewritten by labels. | KatalogCategoryBaseline defines the system-required category baseline; AppDatabase seeds configuration, while article selection and display-name resolution remain separate paths. | scenario_katalog_clean_start_delete_protection_test.dart, catalog picker and fixed-price tests. No catalog data was mutated. |
| IRiU | PREDMET-scoped selected rows are current operational/financial truth; ordering is OSNOVNI package, ordered applied SCENARIO package, then manual/unpredicted rows. | IriuRepository stores occurrences and lifecycle decisions; IriuOrderingService derives projection; display-name resolver reads canonical current KATALOG presentation without changing the selected snapshot identity. | iriu_ordering_partition_test.dart, shared-derived-ordering, manual-row, occurrence-identity and scenario lifecycle tests. Test evidence is automated; no new physical IRiU inspection occurred. |
| PODSETNIK / reminders | Obligations and completion are PREDMET-scoped; delivery is derived from relevant facts/settings; completion does not become a second truth. | PodsetnikObligationRepository reconciles stable rule IDs and preserves applicable completed child state; reminder coordinator/model and platform gateway schedule notifications. | podsetnik foundation, URNA/F-06, F-09, ČITULJE integration and reminder tests. NIGHT save/refresh source change is automated evidence only; real-device responsiveness remains pending. |
| LISTA and LISTA PDF | Checklist projection follows current obligations and preserves parent/child grouping, operational context and the two-page limit. | lista_predmeta_screen.dart presents current case/obligation state; lista_pdf_data_builder.dart and lista_pdf_export.dart build the PDF derivative. | lista_pdf_fidelity_test.dart, lista_pdf_obligations_notes_test.dart, screen smoke tests and dated OWNER Windows acceptance. No new PDF export/runtime was performed. |
| PARTE | PARTE is a PREDMET-derived technical preparation, not independent case truth; completion follows valid current render plan and confirmed preview. | PartePreparationRepository and PartePreparationService persist template/preparation state; ParteComposerScreen edits blocks and renders preview/PDF/DOCX. Image effects use a bounded worker/debounce path. | PARTE domain, PDF completion, module, direct-manipulation, image-effects and template tests. Physical Narrow drag/scroll arbitration, resize/move persistence and real-photo fluidity remain runtime debt. |
| ČITULJE | Each current applicable ČITULJA occurrence has its own PREDMET-owned editable/finalized preparation; confirmed PARTE text is only a proposal snapshot. | CituljePreparationRepository persists by PREDMET plus portable occurrence identity; finalized-write guard protects state; PDF projects persisted preparation. | citulje domain persistence, finalized guard, module, concrete-format and PDF tests; R5 PODSETNIK integration test. No new ČITULJE runtime was performed. |
| IMENIK / contact records | The requested label was checked as a potential standalone subsystem. | No independently named IMENIK production feature, route or test was found. Actual contact data is KontaktLica scoped to PREDMET and edited inside NARUČILAC. | kontakt_lica table/repository, narucilac_segment.dart and transfer/lifecycle coverage. Whether a separate general address book is intended is not established; this is not classified as a defect or implemented requirement. Finding DOC-OBS-001 is retained in task review evidence. |
| FINANSIJE | Financial output derives from PREDMET, IRiU and current owner-approved predicates; no hidden payer or module state should become master truth. | FinancialTruthService and FINANSIJE segment calculate shared amounts; F-09 obligations use the same bounded finance inputs. | finansije manual-format and f09_finansije_podsetnik_test.dart; owner predicates are in OPC_PRODUCT_AND_DOMAIN.md. Broad unspecified reminder scope remains deferred. |
| Documents and shared PDF | Documents are derivatives; stored PREDMET/IRiU/FIRMA values supply output and renderers must not mutate source truth. | Shared PDF helpers and format-specific exporters cover LISTA, PREDRAČUN, SPECIFIKACIJA, NALOG ZA OPREMANJE, NALOG CVEĆARI and RAČUN; PARTE/ČITULJE have separate renderers; RAČUN PDF/DOCX share a canonical model. | Current product/architecture homes and PDF/contract tests. Output layout/runtime acceptance is item- and platform-specific. |
| Single-PREDMET JSON and full Backup JSON | The formats are distinct contracts; transfer preserves portable occurrence identity and intentionally absent dependent state. | PredmetJsonTransferCore validates bounded single-case envelopes; json_export_import.dart coordinates broad backup serialization/restore and compatibility guards. FullBackupRestoreCoordinator owns lifecycle orchestration. | json_transfer_regression_test.dart, predmet_transfer_state_fidelity_test.dart, full_backup_restore_lifecycle_coordination_test.dart, migration/recovery tests. No import/export/restore was executed. |
| Settings, entitlement and configuration | Settings/session/entitlement may gate UI availability, but do not redefine PREDMET meaning; future Web/OCR remain future seams. | PODEŠAVANJA repository, runtime entitlement resolver and module policy feed presentation; current product remains local-first. | presentation entitlement and configuration tests; OPC_MODULE_CONTRACTS contracts 020–027. No new license, installation or threat-model review was run. |
| Dependencies, QA and release | Reproducible evidence must distinguish source/tests, builds, runtime and publication. | pubspec/pubspec.lock and platform build configuration define current dependencies/build inputs; repository workflow specifies analyzer → full serialized tests → authorized build for code-affecting tasks. | Existing NIGHT QA/build package was hash-verified. This documentation-only task did not rerun Flutter QA/build. SBOM and commercial-release signing/version policy remain staged/open items in current engineering/quality authority. |

## 5. Source/documentation reconciliation register

| Finding | Evidence | Disposition | Status |
|---|---|---|---|
| Historical SCENARIO boundary in OPC_ARCHITECTURE.md §12 could be read as forbidding later establishment where no applied snapshot exists. | §12 is dated 2026-09-30. Current source IriuRepository.scenarioOpenReconciliationIntent accepts trusted explicit OSNOVNI bootstrap evidence when current inputs are complete; the Oct 9 current-state/physical closure documents incomplete-to-complete establishment. | Preserve §12 as dated historical boundary, label its supersession narrowly, and add current behavior in architecture. Do not weaken other fail-closed/provenance guards. | DOCUMENTATION CORRECTED; source behavior unchanged. |
| Current status header in OPC_CURRENT_DEVELOPMENT_STATE.md predates the Oct 9 corrections. | Existing dated sections and accepted task package extend through 2026-10-10. | Update the state header and append one current status summary, preserving dated historical sections. | DOCUMENTATION CORRECTED. |
| Quality/status material contains earlier candidate/pending labels. | §§14–16 form a dated chain; the accepted correction result supplied by OWNER is later than the earlier candidate wording. | Preserve history; add one later current-status section, mark which earlier status is superseded and leave Narrow physical runtime pending. | DOCUMENTATION CORRECTED. |
| “External” control-package wording is ambiguous against the actual ignored package location. | Current source-of-truth/current-state identify INTERNAL_DEVELOPMENT_CONTROL/ACTIVE_SOURCE_CONTROL/OPC-V1.5-ACTIVE-SOURCE-CONTROLLED-REBASELINE-20260919. Git ignore rule excludes INTERNAL_DEVELOPMENT_CONTROL from tracked publication. | Clarify that local-only means outside the tracked/public package boundary; the control directory is physically inside the local SOURCE checkout and ignored. Do not change the package or baseline. | DOCUMENTATION CORRECTED. |
| No standalone IMENIK feature found. | Targeted search returned no IMENIK route/symbol/test; contact repository/table and NARUČILAC UI are PREDMET-scoped. | Document actual boundary; do not build a directory. If OWNER intends a separate address book, that is a future authority/scope question. | SOURCE CONFIRMED; no defect assigned. |
| Current four protected hash mismatches. | The active 28-row CSV compares to current files as 24/28; the four paths are the documented PREDMET repository, PODSETNIK repository, LISTA screen and local pseudocode map divergences. | Preserve the intentionally mixed worktree. Do not rebaseline or normalize in this task. Exact actual hashes and initial status are in the external task context/evidence. | KNOWN CONTROL STATE; no new discrepancy classified. |
| User-reported slowness versus “write on every keystroke.” | Source shows CEREMONIJA 800 ms debounce; PREDMET repository skips equal-row SQL UPDATE; refresh waits for save and avoids an unchanged-input reread after the bounded correction. | Document the source-proven path only. Broader perceived latency and physical fluidity are not proven and remain runtime/deeper investigation evidence, not a new defect diagnosis. | PARTIALLY VERIFIED. |

No mismatch was found between the established PREDMET master-truth rule and the inspected core flows. No new business policy was needed to complete this documentation scope. Source behavior and requirements remain separate if a future discrepancy appears.

## 6. Pseudocode continuity and information-home changes

The existing local-only business-critical pseudocode map already contains source-backed sections 16 and 17 for the Oct 9 SCENARIO/BIOHAZARD closure and PARTE/CEREMONIJA Narrow/save behavior. Those sections name the relevant source/test evidence and correctly keep physical Narrow gesture/photo fluidity separate. No pseudocode edit was needed; this prevents an unnecessary write to the known mismatching local-only map.

The current authority homes remain OPC_PRODUCT_AND_DOMAIN.md, OPC_ARCHITECTURE.md, OPC_DEVELOPMENT.md, OPC_QUALITY_RELEASE.md and OPC_ENGINEERING_PROFILE.md. This task updates architecture/current state/quality/source navigation only; product/domain decisions, workflow controls and the adopted profile remain unchanged. OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md remains the subsystem truth-boundary inventory. The current source-of-truth map links this reconciliation as supporting evidence, not a new authority home.

## 7. Engineering-profile applicability

| Chain element | Applicability / outcome |
|---|---|
| Business/domain authority and traceability | Applicable: PREDMET master truth and existing owner decisions are retained; no new business rule is introduced. Traceability appears in §4 and linked contracts. |
| Architecture and data contracts | Applicable: current architecture, schema 36, PREDMET/IRiU and distinct JSON contracts are documented; no contract changes were made. |
| Implementation boundary | Applicable: implementation facts were read from current active source; no product source, tests, generated code, database or build inputs were edited. |
| Verification and acceptance | Applicable: current review ZIP manifests, source links and documentation links are checked. Full Flutter QA is not applicable because no product/test/build surface was changed; exact reason is recorded in task QA evidence. |
| Runtime/OWNER acceptance | Applicable as a boundary: existing SCENARIO physical closure is carried forward; the NIGHT Narrow runtime is still pending OWNER physical verification. No runtime was started. |
| Quality/release | Applicable: previous accepted QA/build evidence is referenced with explicit artifact hashes; no release-readiness or store-signing claim is added. |
| Current documentation reconciliation | Applicable: architecture historical wording, current project status, quality status and source-of-truth navigation are reconciled without replacing past evidence. |

## 8. Current status and residual evidence

The task cutoff is:

IMPLEMENTATION COMPLETE – AUTOMATED QA GREEN – LOGOS REVIEW ACCEPTED – PHYSICAL RUNTIME PENDING OWNER VERIFICATION

This does not mean all historical or future product requirements are complete. Physical NIGHT runtime remains outstanding for PARTE Narrow gesture/scroll arbitration, move/resize persistence through reopen, real-photo preview fluidity, perceived app responsiveness and real PREDMET/PODSETNIK save-refresh synchronization. These are evidence gaps, not confirmed source defects. The accepted SCENARIO/BIOHAZARD physical package closes only its named authorized cases. No subsequent development or runtime task is started here.

Other independently documented open/future items remain in the normal OWNER roadmap and quality/release ledger, including deferred DVE VALUTE implementation, release signing/version/distribution decisions, SBOM maturity, security/dependency follow-up and any future standalone address-book requirement. No next roadmap member is selected by this report.

## 9. Task-local validation and publication record

This was documentation-only. No Flutter analyzer, Flutter tests, release builds, device runtime, APK install, database read/write, schema/JSON/Backup mutation, rebaseline, reset, cleanup or source correction was performed.

Validation performed or required for the handoff:

- Initial Git state captured at branch c37b7d23541408414b6061e6cdb257039762ce43; staged paths 0, modified tracked paths 30, untracked paths 102; initial git diff --check passed with line-ending warnings only.
- Active-source control package manifest and all five logical input hashes: 7/7 PASS. Protected hash comparison: 24/28, exactly four already documented differences; no rebaseline performed.
- Both prior review ZIPs: readable and manifest hashes passed as §3 records.
- Context harness and context/control-integrity validation: PASS; no private database/runtime data was included.
- The final task package carries its exact changed-file list, docs diff, final Git state, validation output, manifest, archive size and SHA-256. Publication status and commit identity are stated only after actual verification.

The authoritative successor for current project status is OPC_CURRENT_DEVELOPMENT_STATE.md. The OWNER-selected future runtime action remains physical verification of the NIGHT Narrow evidence debt after Logos/OWNER handoff; this report does not launch it.

## 10. Controlled publication outcome

The documentation changes are not committed or pushed. At intake, `OPC_CURRENT_DEVELOPMENT_STATE.md` and `OPC_QUALITY_RELEASE.md` were already modified. Their exact intake file bytes are not retained, so this task cannot reliably separate its edits from the existing OWNER/Codex hunks. Per the explicit safeguard in the task, those files remain unstaged and uncommitted; no partial commit was made that would leave the authoritative status update incoherent. The task-local review package contains the actual documentation worktree diff and identifies the mixed-file limitation.

The attempted fresh remote query could not connect to `github.com` via the configured proxy. Cached tracking refs matched at intake but do not prove current remote synchronization. No push was attempted. The public repository therefore remains at the verified local HEAD as far as this task can establish; no successful publication is claimed.
