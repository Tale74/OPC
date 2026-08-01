# OPC Current Development State

Status: functional and usable post-zero baseline.

Current owner authority:
`docs/OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md`.

Permanent incident evidence:
`docs/OPC_INCIDENT_AND_ANTI_DRIFT_REGISTER.md`.

Active documentation classification:
`docs/OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md`.

This document is a continuity summary, not a new technical audit and not a build certification.

| Area | Current public state | Risk / next action |
| --- | --- | --- |
| Product runtime | Flutter/Dart app with Windows and Android lanes. | Preserve platform parity. |
| Web runtime | No Web runner is authorized by this baseline. | OPC Web architecture audit required before implementation. |
| Backend/API | No backend/API is authorized by this baseline. | Server role must be owner-approved and not presumed master `PREDMET` DB. |
| Database | Local Drift/SQLite model; schema version evidence exists in prior audits. | Identity/history guard audit required before changing database behavior. |
| PREDMET | Central master business truth. | Do not redefine through Web, sync, package, PDF, JSON, or UI work. |
| PREDMET versioning | Current implementation displays/exports/imports `verzija` but does not compare it for import conflicts. Pre-zero owner-decision records about future comparison behavior are evidence inputs, not current owner authority. | Use source/tests first. Any future business meaning or warning policy requires post-zero owner confirmation before implementation. |
| PREDMET change-log overview | Pre-zero records describe a prospective version/change-log overview for `Pregled i potvrda`; no implementation is authorized by this baseline. | Audit current logs/lifecycle records, `verzija` increment coverage, import/export/replace survival, and Windows/Android UI parity before returning any business-policy choice to the owner. |
| Firma identity | `FirmaPodaci` exists and is important but editable/hybrid. | Stable identity cannot rely only on editable fields. |
| JSON transfer | Single `PREDMET` JSON and full backup/database JSON remain baseline transfer/backup forms. | Distinction and guards require technical audit. |
| Import/restore | PIB/Matični broj mismatch must block in future guard design. | Implementation details unresolved. |
| Roles | Administrator/Savetnik terms exist. | Stable role identity and firm/license relationship require audit. |
| Packages | `Osnovni`/`Srednji`/`Potpuni` remain historical compatibility terms only. They do not restrict current native functionality. | Do not reintroduce package restrictions; physical legacy-code cleanup is a separate prospective task. |
| Terminology | OPC Web is canonical; SaaS is not primary product terminology. | Existing `saas` labels are cleanup candidates, not current task changes. |
| Documentation authority | `SOURCE/docs` is the single active local Git working copy. Both parallel `PROJECT_DOCS` folders and `_IMPORT_TEST_INPUTS` are removed; `BACKUPS` remains protected. The post-zero inventory classifies all 195 tracked Markdown documents without bulk deletion. | Reconcile or remove pre-zero Git documents only through exact-path cleanup with successor/link/evidence checks. |
| Tests/build | Historical final/report SHA `a1ec31fcd4b2113740a9e118a29c94a556f4243c` retains the owner-provided cumulative PASS: analyze clean; 258 passed, 1 skipped; Windows and Android release builds PASS. On the INC-003 correction tree, `flutter analyze` is clean, the complete suite passes 264 tests with 1 skipped and 0 failed, and owner-provided Windows and Android release builds PASS on the final correction SHA. Windows hard-delete runtime is PASS; Android hard-delete UI/database persistence and isolation are PASS, while its notification non-arrival observation remains owed. Android full restore remains runtime FAIL pending correction retest. | Keep build evidence tied to its SHA. INC-003 has technical/pre-runtime and build PASS but no owner Android full-restore runtime PASS. |
| Phase 1 architecture | Post-zero technical Architecture Decision Gate: PASS. Retain the current codebase; use progressive PREDMET/lifecycle/referential refactor and bounded subsystem change only where proven. Full rewrite is rejected by current evidence. | Windows timing remains mandatory before startup/shutdown performance work; Android profiling remains mandatory before PARTE performance work. Next dependency is the RI-1 through RI-5 PREDMET lifecycle/referential design and migration-proof package. |
| PREDMET lifecycle/referential design | RI-1 inventory and RI-2 hard-delete are Git-closed. Owner-approved 3A/4A full restore has historical cumulative analyze/test/build PASS, but Android full-restore runtime is FAIL. INC-003 correction filters reminder/history export by the captured PREDMET set, safely skips only fully valid parentless rows in already-produced schema-8 backups, prevents reused-ID reassociation, scoped-cancels all destination IDs and preserves 3A/4A. Supplied-backup preflight proves reminders 9→7, history 230→224, active trigger 0, three future platform slots rebuilt, and clean referential state. FK enforcement remains off. | Repeat Android owner full-restore runtime on the correction artifact. Anonymization/replacement remain closed at owner gates 1/2; broad RI-3 recovery remains separate. |
| Windows multiple instance | No native process guard exists; every production process opens the same `opc_v4_release` lane and performs write-capable `beforeOpen`. Isolated synthetic probes confirmed blocking during concurrent open/write. | Use a named mutex before Flutter/SQLite initialization; coordinate installer/update with the same running-app boundary. Implementation is not yet authorized. |
| Windows installation/update | Existing Inno Setup lane is the preferred foundation. Owner requires install/update/uninstall to preserve canonical database identity, path and content. | Harden running-app detection, atomic program-file update/rollback and database-preservation acceptance; do not adopt MSIX before storage/identity audit. |
| Windows startup | Real installed owner-version runtime reaches login in approximately 8–9 s. The unauthenticated startup changed canonical DB size by +8,192 bytes/hash while post-exit `integrity_check` remained `ok`. Source maps pre-`runApp` waits, first-query DB open, repeated steady-state recovery/validation and seed/backfill/KATALOG scans. | Do not repeat the failed synthetic harness. Current-HEAD attribution still requires separately owner-authorized isolated WINDOWS_TEST instrumentation/build; implementation remains closed. |
| Windows exit | Owner confirms visibly slow normal exit; prior runtime report recorded 12.8 s. Source awaits `windowManager.destroy()` but has no explicit production `AppDatabase.close()` or coordinated DB/background/plugin shutdown. | Instrument shutdown phases separately; do not force-kill during a database transaction. |
| Android lifecycle comparison | Owner reports immediate Android open/close with no perceptible delay. This argues against uniform whole-codebase slowness but is not a same-fixture/process-lifecycle benchmark. | Compare device class, DB scale, installed commit and cold-process versus warm/activity-resume behavior before attributing cause. |
| Android PARTE performance | Source audit confirms four performance-risk boundaries: sequential per-PREDMET preparation queries; full viewport rebuild during every pan/zoom update; repeated media reads plus synchronous image decode/effects; and draft persistence followed by full plan reload after many editor actions. Local drag movement itself remains widget-local until commit. | No Android device was connected during the audit. Perform one targeted latest-HEAD profiler run on the owner-provided device before choosing or accepting a correction. Preserve PREDMET/IRiU authority, editor behavior and accepted PDF/DOCX output. |
| Windows/Android PARTE runtime findings | Both platforms show two source-confirmed UI defects: the missing-content blocker contains mojibake and exposes internal ID `mourners`; the font-size field reads draft `initialFontSize` while preview renders fitted `ParteRenderBlock.fontSize`, and preview selection does not synchronize the field. Owner clarified that defined PARTE blocks remain mandatory structural elements, but their individual content may be empty; empty content is omitted and must not block preparation. Current `requiredTextBlockIds` logic incorrectly tests required structure through content-bearing render output. Windows PARTE preparation felt slower, but no measurement proves regression or cause. | Use a separate notified task branch for terminology/encoding, actual font-size state and structure-versus-content policy implementation with focused characterization. Measure/profile performance before choosing a correction. |
| SCENARIO/IRiU | Complete source audit confirms one stored scenario ID over hard-coded condition families, no FIRMA scenario-template persistence/UI, no IRiU row provenance, a confirmed scenario-first ordering incident, and current suppress/dialog lifecycle behavior. Pre-zero owner-gate records are prospective evidence only. | Preserve the post-zero incident invariant: `SANDUK` and the complete applicable basic block precede scenario-dependent rows. Any broader reconciliation, scenario contract or new PREDMET field remains prospective design requiring the applicable post-zero business gate. |
| Static/test validation snapshot | A redundant Phase 1 complete-test attempt was stopped without a result, but it does not invalidate the earlier conclusive PASS on the identical application/test/configuration tree at `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`: 247 passed, 1 skipped, 0 failed. | Treat the stopped attempt as no new evidence, not as a missing application-baseline result. Preserve the owner-approved no-artificial-short-timeout rule for future long suites. |
| Business policy snapshot | Full business-policy and domain/flow atlas now exists for public learning and future audit continuity. | Use `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md` and `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md` before future Web/sync/identity/JSON/version implementation tasks. |
| PREDMET workflow atlas | User/business workflow atlas, dependency map, and completion-state matrix now document actual PREDMET UI points and waiting items. | Use `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`, `docs/OPC_PREDMET_DEPENDENCY_MAP.md`, and `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md` before changing PREDMET UI, documents, JSON, finance, IRiU, STANJE ROBE, or lifecycle behavior. |
| Business policy evaluator | Current evaluator is a partial business-policy kernel: it derives condition flags and drives IRiU/finance consequences, but it is not yet a complete ceremony guidance advisor. | Use `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`, `docs/OPC_BUSINESS_POLICY_SCENARIO_MATRIX.md`, `docs/OPC_BUSINESS_POLICY_CONSEQUENCE_GRAPH.md`, and `docs/OPC_BUSINESS_POLICY_EVALUATOR_COMPLETION_MATRIX.md` before changing evaluator, IRiU, finance, document, STANJE ROBE, review, or Web/sync behavior. |
| Logos knowledge transfer | Logos now has a PREDMET-centered product/module/source learning package. | Use `docs/OPC_LOGOS_KNOWLEDGE_BASE.md`, `docs/OPC_MODULE_RELATIONSHIP_MAP.md`, `docs/OPC_SOURCE_LEARNING_INDEX_FOR_LOGOS.md`, and `docs/OPC_CHILD_ILLNESS_AND_SAFE_UPGRADE_CANDIDATE_REGISTER.md` before orchestrating future OPC upgrade tasks; treat recommendations as findings only, not strategy. |
| Logos pseudocode learning layer | Business-critical source behavior is now translated into public pseudocode for Logos learning. | Use `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`, `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`, and `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md` to understand source behavior before planning characterization tests or safe upgrades; pseudocode is not source replacement. |

## Current Prohibitions

This baseline does not authorize source changes, Web runner, backend/API, sync, browser storage adapter, migrations, payment/subscription work, role implementation, or package restructuring.

## Current post-zero stabilization update - 2026-08-01

The current stabilization branch is `task/OPC-POSTZERO-STABILIZATION-AND-PERFORMANCE`.
Gate 1 is technically complete at commit
`7485ad94e5cc15dfe637f2cab207c2f3bd9aca34`: PARTE structural required-block
validation is separated from content presence, empty text is omitted without
blocking preparation or export, the Ožalošćeni warning uses a user-facing label,
and the font-size field follows the fitted render value. Focused domain,
PDF/DOCX, widget, restore and lifecycle tests pass; analyze is clean.

The owner has reported a scoped Android full-restore runtime PASS after the
INC-003 correction (no unsafe reminder-section error, PREDMETI/PARTE loaded,
observed completed data/history intact). Other data and security coverage was
not tested. This is not acceptance of the current Gate-1 tip.

IRiU/KATALOG opening remains an owner-observed slowdown without a measured
cause. Source shows sequential lightweight category queries and lazy photo
reads; no performance code or schema/index change is authorized until a timing
trace separates repository load, dialog first frame and photo decode.

## Current Phase 3 explicit completion update - 2026-08-01

The owner has now approved the lifecycle correction on
`task/OPC-PHASE3-LIFECYCLE-COMPLETION-CHARACTERIZATION`: automatic completion
is retired, and the only business transition to `ZAVRŠEN` is an explicit user
action after `ZATVOREN` (`OTVOREN → ZATVOREN → ZAVRŠEN`). Ceremony date is not a
completion trigger. `ZAVRŠEN` is immutable for direct edits and reopening;
GDPR anonymization remains a separate controlled operation. Focused repository
tests cover no-auto behavior, explicit completion, idempotency and immutable
guards. Runtime/build acceptance remains deferred to the cumulative owner gate.

## Current Gate 2A KATALOG characterization update - 2026-08-01

The next dependency is now characterized on
`task/OPC-GATE2-IRIU-KATALOG-PERFORMANCE-EVIDENCE`. The lightweight repository
path preserves visible category/article order, stable article IDs, prices,
`hasPhoto`, scoped category selection and separate photo-byte lookup. A local
synthetic in-memory run printed cold/warm repository timings only as diagnostic
evidence; it does not identify the owner-observed slowdown or authorize a
batch query, cache, index or schema change. Owner Windows/Android measurement
must separate repository wait, first dialog frame, photo read and image decode.

## Current Phase 3 SCENARIO/IRiU mutation characterization update - 2026-08-01

The owner clarified the scenario rule: every scenario owns an IRiU consequence
set. When a scenario criterion changes, the application must inform the user,
create newly applicable consequences and remove every no-longer-applicable
scenario-owned row and value. Stale scenario consequences are not acceptable.

The characterization branch
`task/OPC-PHASE3-SCENARIO-IRIU-MUTATION-CHARACTERIZATION` records 4 focused
isolated-database tests: MESTO SMRTI and BLOK 2 sync idempotency, dismissal
memory, manual-row preservation and the current stale-row retention gap. No
production source or ordering behavior changed. The existing per-row
`ZADRŽI/UKLONI` UI is compatibility evidence only; it does not satisfy the
owner rule because `ZADRŽI` can leave a stale scenario row.

The next dependency is the controlled ODQ-SCENARIO-001 reconciliation program:
scenario-owned provenance/snapshot, one confirmation for eligible `OTVOREN`
PREDMETI, stale-row/value removal, STANJE ROBE compensation, retry/rollback and
locked-PREDMET protection. INC-001 scenario-first ordering remains preserved as
incident evidence until its separate owner-gated correction.

The owner also clarified that SCENARIO remains part of PREDMET authority: no
PREDMET exists without a scenario. MODULI own scenario definitions/defaults and
their UI configuration, but the selected scenario and applied consequence
snapshot remain PREDMET-owned. Existing hard-coded scenarios are to become
module defaults first and then UI-upgradeable; a module-default edit must not
silently rewrite an existing PREDMET.
