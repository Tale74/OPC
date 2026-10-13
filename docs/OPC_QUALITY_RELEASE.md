# OPC Quality and Release Guide

**Status:** `CURRENT AUTHORITATIVE QUALITY/RELEASE INFORMATION HOME`
**Scope:** current validation practice, regression contracts, platform evidence and release gaps. This document records controls and gaps; it does not claim that unimplemented release controls already exist.

## 1. Quality vocabulary

Quality review uses ISO/IEC 25010 vocabulary proportionately. The most relevant concerns are functional suitability, data integrity/reliability, maintainability, security, usability, performance efficiency and Windows/Android compatibility. A quality concern belongs in a test, acceptance criterion, architecture risk or release gate when it materially affects OPC; no separate document per characteristic is required.

## 2. Successive validation gate

For any authorized task changing source, tests, generated source, schema/migrations, assets, runtime configuration or build configuration:

1. Run targeted tests when the change has a narrow impact model.
2. Run `flutter analyze` and wait for its conclusive final summary and exit code.
3. Only after analyzer PASS, run complete `flutter test` and wait for its final summary and exit code.
4. Only after both green gates, run an authorized Windows or Android release build.
5. Only after the relevant build, perform disposable/runtime acceptance when authorized.

Analyzer and full tests must be sequential, with one Flutter/Dart/Gradle process chain active at a time. They are allowed to run to natural completion on the OPC Windows environment; elapsed time alone is not evidence of a hang. Only affirmative technical evidence (such as a demonstrated deadlock, permanently blocked child process, unrecoverable tooling/file lock or explicit tooling failure) may classify a genuine hang. A command without a conclusive final summary and exit code is not PASS. Focused tests are useful evidence but do not replace the complete suite when the task requires it.

Documentation-only Phase 1 changes do not change Flutter behavior, so no full Flutter suite is required solely to validate this documentation implementation. Validation for this phase is documented in the Phase 1 report.

## 3. Test layers and interpretation

The current test inventory is broad but physically flat. It includes unit, contract, characterization, migration, JSON/backup/restore, PREDMET lifecycle, IRiU/KATALOG/stock, SCENARIO, PARTE/PDF, reminders and smoke/widget tests.

| Layer | Purpose | Interpretation |
|---|---|---|
| Targeted | Fast evidence for an affected contract or boundary | Does not establish whole-product PASS |
| Analyzer | Static correctness and type/lint gate | Must finish conclusively before full suite |
| Full suite | Regression across current source/test inventory | Required by task scope when production surfaces change |
| SCENARIO Tier 2 | Exact locked regression contract for the formally locked module | Must not be weakened or silently replaced |
| Deep/forensic | Migrations, recovery, compatibility, owner/runtime or environment-gated evidence | Scope and evidence type must be named |
| Widget/smoke | UI routing/rendering and narrow behavior | Owner runtime evidence remains separate |

Environment-gated, owner-database and forensic tests must remain visibly categorized. A skip is not a product failure, but it is not equivalent to executing the omitted evidence.

## 4. SCENARIO regression contract

SCENARIO remains formally locked. The lock references production source SHA `a8218537c1aa85b61fe5c85c21dbd03672f6e77c` and the lock publication lineage ending at the Phase 1 baseline. The contract protects:

- editable/default and applied scenario package behavior;
- 1,008 owner-map combinations and production-path consistency evidence;
- package ordering and IRiU order;
- applied snapshot/provenance and non-retroactivity;
- manual/unpredicted row protection;
- Windows and Android runtime acceptance already recorded by named artifacts.

No Phase 1 documentation change modifies this contract. Future source work must cite the lock and run the exact relevant contract before claiming a regression result.

## 5. Platform and runtime acceptance

| Evidence | Meaning |
|---|---|
| Technical source/test PASS | The inspected code/tests satisfy the stated scope |
| Windows owner runtime PASS | Observed behavior on the named Windows artifact |
| Android owner runtime PASS | Observed behavior on the named physical/device artifact |
| Build PASS | Artifact built successfully after required analyzer/test gates |
| Forensic evidence | Database/transfer/migration/recovery fact for a named copy and scope |
| Combined release acceptance | Requires the applicable technical, build, platform and data/runtime evidence together |

Classify runtime outcomes explicitly as `REPRODUCED`, `NOT REPRODUCED`,
`NOT TESTED`, or `INCONCLUSIVE`. `NOT TESTED` means the applicable test did
not execute and must never be converted to `NOT REPRODUCED`. A missing runtime
surface, authentication handoff, device pairing/authorization, physical
orientation confirmation, or usable Computer Use input/capture capability
leaves the affected matrix case unexecuted unless the test itself actually
ran. OWNER-only prerequisites are explicit handoff gates, not test failures.
For Android narrow/wide coverage, verify the rendered OPC layout; device
portrait/landscape alone is not sufficient evidence of the layout class.

Computer Use runtime tasks must follow the OWNER interaction and evidence
capture controls in [`OPC_DEVELOPMENT.md`](OPC_DEVELOPMENT.md#computer-use-runtime-owner-handoffs).

Owner runtime evidence is authority for observed end-product behavior, not automatic proof of internal root cause. Windows and Android acceptance are not interchangeable.

**Android Direction 1 Compact Chrome — technical candidate (2026-10-03).**
The bounded shared-chrome/PARTE-disclosure/PODSETNIK timestamp implementation
passes focused regressions (`49/49`, including Android-wide and long-value /
1.5× text-scale coverage), `flutter analyze --no-pub`, the full serial suite
(`609 passed / 9 skipped / 0 failed`), Windows release build and
Android production APK build. A prior full-suite attempt had one timeout in an
unrelated migration test; isolated verification and a complete serial rerun
passed. The active-source package integrity is `7/7 PASS`; the protected source
comparison is `26/28` because the two authorized D1 source edits have not been
rebaselined. `git diff --check` passes. Logos post-implementation review
remains pending; Windows and Android OWNER runtime acceptance has not been performed.
No runtime/release acceptance is inferred from technical QA or builds. See
[`OPC_TASK_ANDROID_DIRECTION_1_COMPACT_CHROME_IMPLEMENTATION_REPORT.md`](tasks/OPC_TASK_ANDROID_DIRECTION_1_COMPACT_CHROME_IMPLEMENTATION_REPORT.md).

**REFUNDACIJA PIO text-only correction — formally closed (2026-10-01).** The
accepted instruction is “Unesite iznos naknade pogrebnih troškova preko
Republičkog fonda za penzijsko i invalidsko osiguranje (PIO fond) za tekući
period.” The old explanatory block is removed; amount input, formatting,
SAČUVAJ, persistence, eligibility and FINANSIJE behavior are unchanged.
Evidence: focused test `6 passed / 0 failed`; analyzer PASS; full suite
`602 passed / 9 skipped / 0 failed`; Windows release build PASS; Android
production APK build PASS (debug-signing configuration, not store-signed). The
APK SHA-256 is
`AD43E7114BF65A4C22B69D6FB68F2BEF91A355B8370ABF9ADC06BDA7A14BBC6`. Logos
independent review and OWNER runtime acceptance are PASS. Product QA was not
rerun for this documentation-only closure. See
[`OPC_TASK_REFUNDACIJA_PIO_TEXT_CORRECTION_CLOSURE_REPORT.md`](tasks/OPC_TASK_REFUNDACIJA_PIO_TEXT_CORRECTION_CLOSURE_REPORT.md).

### 5A. Android structural-acceptance lane

Release/runtime evidence remains PRODUCTION-specific. For shared database invariants, `ANDROID_TEST` is the dedicated synthetic, disposable and intentionally inspectable physical acceptance lane: its `opc_v4_android_test` database may be copied read-only through the debuggable test package for schema, integrity, referential-cleanup, replacement and backup/restore evidence. This lane does not relax PRODUCTION protection and must contain no owner production data, credentials, backups or private exports. ANDROID_TEST evidence is authoritative only for invariants whose implementation equivalence with PRODUCTION has been explicitly proven.

RR-011 current-fact status: `CLOSED — FULL ANDROID STRUCTURAL ACCEPTANCE PASS`. The final physical ANDROID_TEST wave completed PASS evidence for device connectivity, schema/integrity/FK, provenance cleanup, real scenario-snapshot cleanup and the separately scoped single-PREDMET replacement with stable identity and relaunch persistence. The single-PREDMET `OPC_PREDMET` JSON format carries current SCENARIO snapshot/provenance and PREDMET-scoped lifecycle decisions without local database IDs; intentionally absent dependent state is preserved. The earlier ADB-offline/10060 attempt is historical. No RR-011 successor remains.

Current architecture/deployment concerns include repaired-state/canonical closure, Android transfer/runtime parity outside the bounded responsibility-transfer acceptance below, notification lifecycle, filesystem/storage behavior and installer/signing readiness. Native Windows single-instance protection is closed by the accepted mutex/W1–W6 evidence; installer running-app protection is also closed by the accepted Inno Setup compile and I1/I2/I3 evidence. No RR-012 successor remains.

### 5B. PREDMET responsibility peer-transfer acceptance

Current bounded status:

`PHYSICAL SAME-FIRMA WINDOWS ↔ ANDROID PEER RESPONSIBILITY TRANSFER ACCEPTANCE — PASS`

The traceability chain is closed for this scope: the owner business rule makes
portable PREDMET responsibility a name+role snapshot; schema 28 and individual
PREDMET JSON schema 9 implement it without legacy local-ID backfill; automated
responsibility/migration tests, analyzer, the serialized full suite and both
release builds pass; Android → Windows and Windows → Android normal-product
physical transfers both pass.

Android → Windows proved preservation with a missing local binding. Windows
→ Android proved the unique exact name+role binding path. In both cases the
importer remained distinct from the responsible SAVETNIK, and PREDMET/detail
UI, LISTA PDF, PREDMET PDF and relevant STATISTIKA remained consistent. There
is no separate business derivative named `LISTA`.

Transfer fidelity requires preservation of both presence and intentional
absence. Schema-9 lifecycle-decision transfer data is restored against the
destination PREDMET identity and does not authorize reconstruction from live
SCENARIO defaults.

This closes only the same-FIRMA peer responsibility-transfer acceptance
condition. It does not close unrelated transfer, backup/restore, notification,
storage, signing, provenance or general release-readiness gaps. It also does
not establish broader identity or database semantics:

- `DATABASE OWNERSHIP — NOT EXPLICITLY MODELED`
- `FIRMA BUSINESS-NAMESPACE HYPOTHESIS — PARTIALLY SUPPORTED`

### 5C. PODSETNIK active-eligibility invariant

The bounded PODSETNIK correction is source- and test-confirmed: active
PODSETNIK candidates and scheduling are fail-closed to the exact status
allow-list `OTVOREN || ZATVOREN`. `ZAVRŠEN`, `ANONIMIZOVAN`, `U_OBRADI` and
unknown statuses are not active candidates; any stored delivery IDs for those
statuses are cancelled while logical reminder configuration is retained as
history. The invariant is applied through selector, shortcut, coordinator,
detail re-entry, startup, restore and import/replacement paths. This is a
bounded technical eligibility result, not closure of the broader PODSETNIK
signal model or a release-readiness claim.

### 5D. Current-state restoration technical gate

The 2026-09-08 bounded restoration has source/test evidence for the restored
document, ČITULJE, URNA/PEPEO, contextual PODSETNIK, REVIEW BAR and
compatibility boundaries. The relevant serial evidence is `217 PASS / 0 FAIL`
for targeted/regression checks, `flutter analyze --no-pub` PASS and the full
serial suite `528 PASS / 10 SKIP / 0 FAIL`. Existing environment-gated skips
remain explicitly categorized and are not equivalent to execution.

This is not runtime or release acceptance. Windows and Android runtime,
release build/signing/version/provenance, cross-device acceptance and Git
publication remain pending and separately authorized. No canonical production
database write is implied by this technical result.

The latest Windows observation is classified as
`CODEX SANDBOX DESKTOP BINDING RECURRENCE – OWNER-DESKTOP RUNTIME ACCEPTANCE
REQUIRED`: a running process without an OWNER-visible window is not, by
itself, an OPC startup defect when the process is bound to the Codex sandbox
desktop. Domains 1–5 therefore remain OWNER evidence required. Build/source
identity remains separate from runtime acceptance.

This paragraph records the 2026-09-08 recovery-era publication boundary; its
mixed-local-SOURCE description is historical, not the current v1.5 baseline.
See
[`OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`](OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md).

### 5E. Current v1.5 source and F-09 status — 2026-09-20

The published v1.5 product-source baseline and local-only active-source control
package are identified in `OPC_CURRENT_DEVELOPMENT_STATE.md`. The high-risk
baseline retains 28 logical protected rows. OWNER-selected normal-roadmap
Member 1 has implemented the bounded F-09 source change; technical validation
does not equal OWNER runtime acceptance, release readiness, publication or a
new roadmap authorization.

FINANSIJE is the OWNER-confirmed PRE-CEREMONY parent of sibling PRE-CEREMONY
children PLATITI RAČUN and NAPLATITI OBAVEZE, with no child-to-child sequence.
The locked JKP predicate is
`TROŠKOVI JKP > 0 AND jkpPlacaSamostalno == false`; the receivables child exists
when `ZA NAPLATU > 0`. Both use generic manual completion and REVIEW BAR
semantics. Focused F-09 tests (7), relevant regression tests (75), the
serialized full suite (556 passed, 10 skipped, 0 failed), and
`flutter analyze --no-pub` passed. Windows and Android production release
builds passed; these are build evidence only, not owner-observed runtime
acceptance. Broader unspecified FINANSIJE reminder scope remains deferred.

### 5F. RAČUN toggle, shared PDF/DOCX model and snapshot retirement — 2026-09-21

Normal-roadmap Member 3 adds the OWNER-locked FIRMA `RAČUN` toggle (default
`DA`; legacy full Backup omission defaults to `DA`) as the sole machine
availability condition for both RAČUN PDF and DOCX. Both outputs consume one
canonical RAČUN data model; Article 33 is retained; full Backup carries the
setting and Single-PREDMET JSON is unchanged. The obsolete PREDMET PDF SNAPSHOT
offer/exporter is retired. The six-output standard PDF set and the exact
exporter-by-exporter helper dispositions are recorded in the current-state
home; no full-helper normalization was performed for the five candidates whose
semantic equivalence could not be proven.

Focused RAČUN tests (9), focused DOKUMENTI regression (1), relevant
migration/Backup/JSON/settings/PDF regressions, analyzer and the serial complete
suite (575 passed, 10 skipped, 0 failed) passed. Windows release and Android
production release builds passed. OWNER accepted Word 2019 direct open,
one-page render and print/layout parity. The proven defect was a nested table
in the signature-labels cell without the required trailing paragraph;
`_requiredTrailingParagraph()` is the minimal correction. This acceptance is
bounded to the RAČUN/DOCX package and does not broaden to unrelated documents.

### 5G. Android UX Direction 2 residual runtime and formal closure — 2026-10-03

`ANDROID UX DIRECTION 2 — MICROCOPY / LITERAL CLEANUP — FORMALLY CLOSED`.
The residuals are R-1 PASS, R-2 PASS, R-3 PASS and A-13 PASS, within the
specific criteria and evidence recorded in the closure report. The original
R-1 runtime observation established absence of the raw PIO predicates on the
then-tested surface; that surface was later superseded by the separately
approved PIO text correction. The current PIO state is supported by its own
tests, Logos PASS and OWNER runtime PASS. The R-1 screenshot is not represented
as a capture of the later PIO text. R-2 covers the PREDMET/CEREMONIJA label;
R-3 covers the LISTA PDF label and retained destination values; A-13 covers the
protected-category dialog and its cancel/deactivate choices.

The recorded residual-runtime captures are Windows desktop evidence. They do
not establish physical Android-device runtime or general release readiness.
Original Direction 2 QA was 16 focused tests PASS, analyzer PASS, full suite
593 passed / 10 skipped / 0 failed, and Windows/Android production release
builds PASS. Later PIO-candidate QA on the evolved worktree was 602 passed / 9
skipped / 0 failed, analyzer PASS and Windows/Android release builds PASS; it
is supplementary evidence, not a replacement claim about the original D2 QA
run. No product QA was rerun for this documentation-only formal closure.

The SCENARIO inconsistency recorded during the earlier D2 runtime work was
subsequently split into a separate historical-integrity task, corrected,
reviewed by Logos (PASS), accepted at OWNER runtime (PASS), and formally
closed by commit `c6cafa3a3172eb911ef3002a0533632e315d4f7d`. It is historical
context, not an open Direction 2 finding. The separate continuity item remains
`PREVIOUS PENDING FINDING — NOT IDENTIFIABLE FROM CURRENT AUTHORITY`; its
identity is not guessed or merged with SCENARIO or UX-PARTE. `UX-PARTE-001`
remains `OPEN / NOT TESTED / ROOT CAUSE NOT PROVEN`; `UX-PARTE-002` remains a
separate hierarchy/density concern and `UX-PARTE-003` remains closed. Direction
2 closure makes no broader UX-program or release-readiness claim.


## 6. Backup, restore and interoperability

Single-PREDMET transfer and full-backup JSON remain distinct. Release acceptance must cover:

- schema/legacy readability;
- identity and compatibility checks;
- preservation of PREDMET/IRiU/SCENARIO snapshot boundaries;
- exact restore family and installation-local state rules;
- malformed/legacy input behavior;
- isolated-copy migration and restore evidence;
- Windows/Android artifact and runtime scope.

Release/data-integrity acceptance also protects the clean-start KATALOG contract: a fresh database seeds the exact 29 system-required category configurations but no business articles or starter pack. Existing KATALOG rows and user edits must survive reopen and migration; user categories remain extensible, and any persisted SCENARIO reference blocks physical category deletion. Tests may provide explicit business fixtures when required. The bounded Scenario ↔ KATALOG package has OWNER implementation acceptance and Windows/Android semantic parity for this scope; broader release gates remain separate.

Prior successful incidents are scoped evidence, not the final product-line rehearsal. The Windows owner-facing backup/restore acceptance is now `PASS — BOUNDED DISPOSABLE LANE`; the direct post-restore back/logout observation remains an evidence-incomplete, non-blocking successor. A release-candidate backup/restore rehearsal remains open in the current development plan.

## 7. Build and release matrix

| Release concern | Windows | Android | Current status |
|---|---|---|---|
| Shared Dart/application code | Yes | Yes | Current implementation |
| Native runner and filesystem | Windows runner, installer and local storage | Android runner, storage and permissions | Platform-specific |
| Notifications/lifecycle | Windows integration varies by packaging/runtime | Android notification/lifecycle path | Runtime evidence must be platform-specific |
| Build | Windows release build path exists | Android release build path exists | Historical/current task evidence; rerun when source/configuration changes |
| Signing | Installer/artifact signing and custody incomplete | Release signing/custody incomplete or not final | Open gap; do not claim release readiness |
| Version/tags/provenance | No complete canonical release record | No complete canonical release record | Open gap |
| Artifact identity | Requires source SHA, version, toolchain, checks and hash | Same | Required before formal distribution |

The current repository has no complete signing/custody, semantic version/tag, artifact provenance or rollback runbook. These remain visible gaps.

## 8. Dependency, IP and security release concerns

The lockfile provides a useful package inventory and hosted hashes, but the current repository lacks automated update/vulnerability visibility, third-party license inventory, explicit IP/repository-use/distribution status, SBOM generation and a concise vulnerability process. The future source/product licensing model is an owner/legal decision and is not selected by this document.

Before commercial distribution or formal external handover, the release should include:

- explicit IP/repository-use/distribution status;
- third-party dependency/license inventory;
- machine-readable release SBOM;
- security/data/threat review and vulnerability path;
- source/artifact hashes and build record;
- signing/version/channel decisions.

RR-008 same-identity replacement is accepted for the implemented seam: focused
replacement integration tests, `flutter analyze --no-pub`, the serialized full
`flutter test --no-pub --concurrency=1` suite, and a Windows release build all
pass. Runtime device/platform acceptance and broader notification taxonomy are
not silently inferred from this technical evidence.

## 9. Current quality/release risks

- stale/default-branch authority;
- no automated analyzer/test CI gate;
- no final signing/version/provenance process;
- incomplete Windows/Android release parity proof;
- JSON/restore and migration complexity;
- URNA/PEPEO business contract is locked; implementation, runtime acceptance, release and publication status must be tracked separately according to the actually completed state and do not establish release readiness by implication;
- KATALOG/IRiU runtime closure and performance evidence;
- dead-code/superseded-implementation audit not yet performed;
- internal pseudocode drift, which is a development-control gap rather than a product-documentation requirement.

## 10. Evidence navigation

- [`OPC_DEVELOPMENT.md`](OPC_DEVELOPMENT.md#6-validation-workflow)
- [`OPC_SCENARIO_MODULE_LOCK.md`](OPC_SCENARIO_MODULE_LOCK.md)
- [`OPC_SCENARIO_MODULE_LOCK_REPORT.md`](OPC_SCENARIO_MODULE_LOCK_REPORT.md)
- [`OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`](OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md)
- [`OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md`](OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md)
- [`OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`](OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md)
- [`OPC_PHASE1_IMPLEMENTATION_REPORT.md`](OPC_PHASE1_IMPLEMENTATION_REPORT.md)

## 11. SCENARIO applied-state integrity and selector implementation — 2026-09-30

The bounded implementation passes the current technical validation sequence:

- focused SCENARIO/IRiU/selector/carrier/transfer regressions: `89 passed / 0 failed`;
- `flutter analyze --no-pub`: PASS, `No issues found`;
- `flutter test --no-pub --concurrency=1`: PASS, `600 passed / 9 skipped / 0 failed`;
- `flutter build windows --release --no-pub`: PASS;
- `flutter build apk --release --no-pub`: PASS, production flavor.

The exact commands, output paths, artifact hashes, changed-file boundaries and
known evidence limitations are recorded in
[`OPC_TASK_SCENARIO_APPLIED_STATE_INTEGRITY_AND_SELECTOR_IMPLEMENTATION_REPORT.md`](tasks/OPC_TASK_SCENARIO_APPLIED_STATE_INTEGRITY_AND_SELECTOR_IMPLEMENTATION_REPORT.md).
This technical result does not claim owner runtime acceptance, signing/custody,
publication, or complete release readiness. Logos post-implementation review
and OWNER runtime acceptance remain pending. Protected active-source hashes
were not rebaselined by this task.

## 12. SCENARIO carrierless historical-integrity correction — 2026-09-30

The bounded correction to the implementation above was validated separately:

- focused correction/regression groups passed; the standalone carrierless
  test rerun passed `2/2`;
- `flutter analyze --no-pub`: PASS;
- `flutter test --no-pub --concurrency=1`: PASS, `602 passed / 9 skipped / 0 failed`;
- `flutter build windows --release --no-pub`: PASS;
- `flutter build apk --release --no-pub`: PASS, production release.

The correction prevents an ordinary open from inferring historical applied
state from current rules and records new base-row provenance at creation. The
missing-snapshot presentation is explicitly evidence-unavailable, not
categorical non-application. No schema, JSON contract, business policy or
active-source baseline was changed. This is technical/build evidence only;
Logos independent correction review and OWNER runtime acceptance remain
pending. Details and artifact hashes are in
[`OPC_TASK_SCENARIO_CARRIERLESS_HISTORICAL_INTEGRITY_CORRECTION_REPORT.md`](tasks/OPC_TASK_SCENARIO_CARRIERLESS_HISTORICAL_INTEGRITY_CORRECTION_REPORT.md).

## 13. SCENARIO historical-integrity formal closure — 2026-09-30

The later closure supersedes the pending review/runtime statements in §§11–12:

- `SCENARIO CARRIERLESS / HISTORICAL-INTEGRITY CORRECTION — PASS`;
- `LOGOS INDEPENDENT CORRECTION REVIEW — PASS`;
- `OWNER RUNTIME ACCEPTANCE — PASS`;
- PREDMET sole-business-truth, manual IRiU correction persistence after
  reopen, and historical-SCENARIO non-overwrite of current PREDMET/IRiU are
  confirmed.

The concrete OWNER runtime case used carrier v1, with provenance coverage
`UNAVAILABLE` and an assignment snapshot present. That case is not independent
runtime proof for v2 `COMPLETE` or `PARTIAL` transfer; those are supported by
automated QA. The accepted correction's technical evidence remains
`602 passed / 9 skipped / 0 failed`, analyzer PASS, Windows release PASS and
Android production APK PASS. No product QA was rerun for this
documentation/control-only closure.

The separate continuity item is recorded exactly as
`PREVIOUS PENDING FINDING — NOT IDENTIFIABLE FROM CURRENT AUTHORITY`. It is
not guessed or merged with the SCENARIO issue closed here, `UX-PARTE-001`, or
another open item. `UX-PARTE-001` remains `OPEN / NOT TESTED / ROOT CAUSE NOT
PROVEN`. See
[`OPC_TASK_SCENARIO_HISTORICAL_INTEGRITY_FORMAL_CLOSURE_REPORT.md`](tasks/OPC_TASK_SCENARIO_HISTORICAL_INTEGRITY_FORMAL_CLOSURE_REPORT.md).

## 14. SCENARIO later-reopen and bounded UX correction candidate — 2026-10-06

The latest candidate passed `flutter analyze --no-pub` and the full serial test
suite (`629 passed / 9 skipped / 0 failed`). The nine skips remain explicitly
skips; in particular, optional environment-gated forensic copy runs are not
represented as executed. The independent golden consistency test for all
1,008 SCENARIO records passed. The prior photo-slider preview work now debounces
and dispatches image processing to a worker isolate; real-photo interaction
performance remains runtime evidence debt.

Sequential release builds completed successfully: Android production APK,
79,633,175 bytes, SHA-256
`51146613B171B59EB59CACC4C9406712BCF4CFC06BD53FCA84B9B09D03FAEB75`; and
Windows release, with fresh `data/app.so` (13,190,064 bytes, SHA-256
`84343801CA4754519F1DD79067651494A70D13F2FDED48F1BC151959CC78F7BC`). The
Windows native runner executable was unchanged because no native runner source
changed. These are build artifacts, not installed-runtime proof.

`git diff --check` passed. The pre-write active-source package was `7/7 PASS`
and the protected comparison was `26/28` with the two previously documented
D1 divergences. A post-change read-only comparison against the local 28-row
baseline copy is `24/28`: those two D1 paths, the newly changed protected
`predmeti_repository.dart`, and the local-only pseudocode map. The control
package and baseline file were not changed. A controlled rebaseline is
required but deferred until Logos review/OWNER runtime acceptance and separate
authorization. No staging, commit or push occurred. Logos post-implementation
review is pending; OWNER runtime testing is intentionally deferred until that
review. Detailed causal analysis, corrected findings, verification boundaries
and package contents are recorded in
[`OPC_SCENARIO_HISTORICAL_WORKING_KERNEL_DIFFERENTIAL_RECOVERY_REPORT.md`](tasks/OPC_SCENARIO_HISTORICAL_WORKING_KERNEL_DIFFERENTIAL_RECOVERY_REPORT.md).

## 15. SCENARIO + BIOHAZARD correction — physical closure — 2026-10-09

The accepted physical Android closure passed the original authorized targets:

- fresh `OPELO NE→DA→NE`: `Komplet za opelo` was added once, survived save and
  restart, was removed on reverse change, and remained absent after the second
  save/restart/reopen without a repeated KIT proposal;
- fresh incomplete→complete SCENARIO facts established current applied state;
  that state remained durable after save/restart/reopen without repeating the
  bootstrap proposal;
- a fresh valid `NEDEFINISANA` case reconciled and rendered IRiU, including the
  expected `ZARAZNA BOLEST` labels and safety instruction, without
  assertion/render failure.

These are scoped runtime results, not a broad SCENARIO map revalidation. The
incomplete first evaluation does not establish partial applied ownership;
eligible mutable `OTVOREN` / `ZATVOREN` cases may establish current state from
complete present facts, while historical reconstruction and `ZAVRŠEN` /
`ANONIMIZOVAN` recovery remain excluded. Manual/unrelated IRiU rows remain
protected. BIOHAZARD continues to use the canonical conditional policy; a
`NEDEFINISANA` cause alone does not imply a blanket consequence.

The accepted technical chain remains `flutter analyze — PASS`, full serialized
suite `636 PASS / 9 SKIP / 0 FAIL`, Windows release `PASS`, and Android
production release `PASS`. This documentation update does not rerun those
commands. Physical screenshots, the expected/observed matrix, the historical
PREDMET `NOT FOUND` result, and the OWNER-directed exclusion of the incidental
Lemovanje observation are preserved in the external package
[`OPC_SCENARIO_BIOHAZARD_DEFECT_CLOSURE_20261009_PHYSICAL_COMPLETE.zip`](../../REVIEW/OPC_SCENARIO_BIOHAZARD_DEFECT_CLOSURE_20261009_PHYSICAL_COMPLETE.zip)
(SHA-256 `350FC182999FADCF48A701FEF2CFBECE2AFF4EBD6F27708DC7BFA7ADB8C85195`).
The prior §§14 and earlier candidate/runtime-pending wording are historical and
are superseded for these correction targets by this closure record.

## 16. PARTE / CEREMONIJA Narrow UX and synchronization corrections — 2026-10-10

The bounded UX corrections have focused widget coverage and passed the full
serialized suite:

- `UX-01` PARTE text/content block disclosure collapsed by default and remains
  expandable — PASS;
- `UX-02` text size uses integrated 0.5 pt increment/decrement actions in the
  `Veličina` field, displays the fitted preview value and disables at bounds —
  PASS;
- `UX-03` compact semantic `DIMENZIJE` icon actions fit one Narrow row — PASS;
- `UX-04` cemetery name field width is responsive and an enabled empty manual
  field is visibly inviting, returning to normal treatment when populated —
  PASS. Global font size was not reduced.

The source investigation did not prove a database update on every keystroke.
CEREMONIJA autosave is debounced by 800 ms, the PREDMET repository skips the
SQL update for an unchanged row, and reminder refresh previously could reread
the row for unchanged reminder inputs and was not awaited after the save. The
bounded correction compares a key of all reminder-output inputs, skips that
unchanged reminder-path read, and awaits PREDMET persistence before reminder
refresh. This addresses the source-proven redundant read/order issue; the
broader perceived-latency cause and physical fluidity are not established
without device observation.

Verification, in sequence:

- focused PARTE/CEREMONIJA tests:
  `14 passed / 0 failed`;
- `flutter analyze --no-pub`: PASS, `No issues found!`;
- first full serial suite attempt: `636 passed / 9 skipped / 1 failed`; the
  existing `scenario_katalog_clean_start_delete_protection_test.dart` case
  `clean-start bootstrap is idempotent and preserves a renamed label` reached
  its fixed 30-second test timeout;
- focused rerun of that test file: `5 passed / 0 failed`;
- final full serial suite:
  `637 passed / 9 skipped / 0 failed`, exit code `0`;
- `flutter build windows --release --no-pub`: PASS, exit code `0`; fresh
  `data/app.so` is 13,190,064 bytes, SHA-256
  `ABE75452B99D3CDBF18FC9C403F2631D600F0FED7DD3669287512C91A4664A80`;
- `flutter build apk --release --flavor production --no-pub`: PASS, exit code
  `0`; production APK is 79,633,103 bytes, SHA-256
  `CDE7D0FCF164FB4C66194798D5560A44168D4BA65738CA8E2BAFC60866260876`.

The isolated timeout did not recur in the focused rerun or the final complete
suite. The nine skips are preserved as skips, including environment-gated
forensic tests; no result is inferred for them. This task did not perform
physical-device PARTE gesture/persistence or real-photo fluidity acceptance;
those remain runtime evidence debt. The artifacts are build evidence, not
installed-runtime proof. Full task continuity, source/test evidence, backup
integrity and finding disposition are indexed in the external review package
`REVIEW/CURRENT_TASK/OPC_NIGHT_UI_UX_CORRECTION_20261009`.

## 17. Current implementation and acceptance state — 2026-10-10

OWNER supplied the final review outcome:

`IMPLEMENTATION COMPLETE – AUTOMATED QA GREEN – LOGOS REVIEW ACCEPTED – PHYSICAL RUNTIME PENDING OWNER VERIFICATION`

For the NIGHT UI/UX correction, the latest recorded technical chain is focused
tests 14/14 PASS, analyzer PASS, full serial suite 637 PASS / 9 SKIP / 0 FAIL,
Windows release PASS and Android production release PASS. The final package
was reported internally consistent and Logos review accepted it. During the
2026-10-10 documentation reconciliation the ZIP was independently reopened
and all 15 manifest-listed hashes matched. None of the tests, analyzer or
builds were repeated for this documentation update. The older §14 candidate
and its Logos-pending statement remain historical intermediate status and are
superseded for the accepted correction package by this section and §16.

Physical NIGHT runtime remains pending OWNER verification for PARTE Narrow
gesture/scroll arbitration, element move/resize persistence through reopen,
real-photo effect fluidity, observed application responsiveness and actual
PREDMET/PODSETNIK save-refresh synchronization. Automated tests and build
artifacts do not establish these device outcomes. The bounded SCENARIO /
BIOHAZARD physical acceptance is separately recorded in §15 and its
integrity-checked evidence package; it does not close the NIGHT UI runtime
matrix. No new runtime defect is inferred from these outstanding checks.

## 18. NIGHT UX refinement continuation — 2026-10-11

Final automated verification for the authorized nine-requirement NIGHT UX
continuation:

- focused UX/regression set: `52 passed / 0 failed`;
- `flutter analyze --no-pub`: PASS, `No issues found!`;
- first full serial-suite attempt: `643 passed / 9 skipped / 5 failed`;
  three STANJE ROBE assertions still expected the removed redundant status
  sentence, the former section-navigation test assumed the old initial
  section, and the new `ZATVORI` OutlinedButton exposed a `TextStyle.lerp`
  assertion. The source style was corrected and only the stale presentation
  expectations were updated; business handlers were unchanged;
- focused rerun after correction: `52 passed / 0 failed`;
- final full serial suite: `648 passed / 9 skipped / 0 failed`, exit code `0`;
- `flutter build windows --release --no-pub`: PASS, exit code `0`; `OPC.exe`
  89,600 bytes (SHA-256
  `E6C2805D1F99621DDA30260B916289AF8CF3A1115BD7B28C80B13A0C5F830BAD`),
  `data/app.so` 13,239,216 bytes (SHA-256
  `86579248E59B09693E459DD0A686ED360A96D4CA2006548DA72D80EE422DC933`);
- `flutter build apk --release --flavor production --no-pub`: PASS, exit code
  `0`; `app-production-release.apk` 79,682,339 bytes (SHA-256
  `850AE74FF0A700A43F2026FC98639F03675F350AD15196F0387B17A8ECEF274D`).

Nine environment/legacy-gated tests remain reported as skips. These tests and
release builds do not establish physical runtime or owner acceptance. UX-08
remains deferred because no source-proven scroll-jump cause was established.
Active-source precheck remains `20/28 LITERAL MATCH – 8/8 PROVENANCE
RESOLVED`; its protected CSV was not changed or rebaselined. Physical runtime
is deferred until Logos/OWNER review. The task-local review package is the
navigation record for scope, documentation delta, source-learning, QA/build
evidence and incidental-finding disposition.

## 19. NIGHT UX residual correction — UX-01A/01B/05/06 — 2026-10-11

The bounded OWNER-authorized residual correction passed its focused regression
set (26/26), `flutter analyze --no-pub`, the full serialized Flutter suite
(651 PASS / 9 SKIP / 0 FAIL), Windows release build and Android production
release build. Nine existing legacy/environment/copy-gated tests remain
reported as skips; they are not treated as passes.

Windows release outputs:

- `OPC.exe`: 89,600 bytes; SHA-256
  `E6C2805D1F99621DDA30260B916289AF8CF3A1115BD7B28C80B13A0C5F830BAD`.
- `data/app.so`: 13,239,216 bytes; SHA-256
  `62637680ECCB41A276EAB1E83340C67D21D32E3804956962CE2992CF7B29950C`.

Android production output:

- `app-production-release.apk`: 79,682,339 bytes; SHA-256
  `958774004A3082D6A6C35560AA00C18BE2832CD4A820062A8B768A9584FBF110`.

These release builds do not establish installed-device behavior. No physical
runtime was performed. The protected active-source control was not changed or
rebaselined; its accepted pre-task 20/28 literal-match result is not a current
post-edit PASS claim. A separate UX-06 test attempt observed a 45 px Narrow
Segment 2 dropdown overflow; it is recorded out of scope for this task and
deferred to a separately authorized responsive-layout review. Full
requirement/source/test traceability and task-local package integrity evidence
are in
[`OPC_NIGHT_UX_RESIDUAL_CORRECTION_20261011_TRACEABILITY.md`](tasks/OPC_NIGHT_UX_RESIDUAL_CORRECTION_20261011_TRACEABILITY.md)
and the external review package. Status:
`READY FOR LOGOS/OWNER REVIEW`.

## 20. Residual UX and user-facing text reconciliation — 2026-10-11

For the OWNER-authorized COR-01..COR-05 and AUD-01 scope, focused regressions
passed `28/28`, `flutter analyze --no-pub` passed with `No issues found!`, and
the full serial suite passed `655 / 9 skipped / 0 failed` (exit 0). The nine
skips are existing environment-, copy- or forensic-gated cases and are not
counted as executed passes. Windows release build passed (exit 0; 147.5 s).
Android production release build passed (exit 0; 916.4 s). The generated
release outputs are recorded in the task traceability report and QA evidence;
their existence does not establish installed-device behavior.

No physical runtime was authorized. AUD-01 is source-diagnosed but retains the
runtime evidence gap: the Android Wide screenshot shows the Segment 7
`+9 / −0 STAVKI` toast during segment opening, but there is no post-event DB
snapshot or interaction trace to prove its exact trigger or resulting durable
rows. No SCENARIO/IRiU implementation was changed. The active-source control
CSV remains unchanged; the accepted historical pre-task result remains
`20/28 LITERAL MATCH – 8/8 PROVENANCE RESOLVED`, with no rebaseline.

The QA runner did not preserve absolute CLI start/end clock times. Evidence
records the verified run date, observed execution sequence, terminal exit
codes, summaries and build durations; no missing wall-clock time is inferred.
The final handoff is `READY FOR LOGOS/OWNER REVIEW`, pending independent Logos
review and OWNER acceptance.

## 21. COR-04 / COR-05 bounded correction evidence — 2026-10-11

The final bounded COR-04/COR-05 correction completed the required sequence:
focused responsive and settings tests `16/16` passed; `flutter analyze
--no-pub` passed with no issues; the serialized full suite passed `656`, with
`9` gated skips and `0` failures; Windows release and Android production
release builds both exited 0. The responsive regression checks Wide geometry
for Android and Windows and retains Narrow coverage. Exact command timestamps,
exit codes, summaries and artifact SHA-256 values are recorded in the
task-local QA JSON and report. No physical runtime was authorized or run.

## 22. Extended COR-05 guide and contextual help — 2026-10-12

The focused guide/settings/chrome regressions passed `24/24`, including an
edge tap inside the 48×48 POMOĆ target. The final serialized
`flutter test --no-pub --concurrency=1` run exited 0 with `662` passed, `9`
gated skips and `0` failures (1,701.9 s). `flutter analyze --no-pub` exited 0
with no issues (345.3 s). Sequential Windows release and Android production
APK builds both exited 0 (234.3 s and 803.7 s). The APK is 79,360,017 bytes,
SHA-256
`541DADBE326E7C9E616DA62D3C01C7EB4AC1EA570609817F6C705917B0369E51`; Windows
`data/app.so` is 13,140,912 bytes, SHA-256
`435F687502EA1E38A43D9ACDEFBC5FEB4F73FB26009CFB2ADDE9284950D3E16A`; the
unchanged-size 89,600-byte runner SHA-256 is
`E6C2805D1F99621DDA30260B916289AF8CF3A1115BD7B28C80B13A0C5F830BAD`. The
guide resource (18,739 bytes; SHA-256
`01F2920F1F49C0186419D959B4EE1564401BA828D2B4B4E45B3E7F1D0DB7C70E`) is
present in the Android APK and Windows Flutter assets. Build
outputs do not prove installation or physical runtime behavior. No physical
runtime was authorized. Exact commands, outputs and review limitations are in
the linked task traceability report and external review package.

## 23. OWNER-approved final guide content — 2026-10-12

Focused guide regressions passed `7/7`. `flutter analyze --no-pub` exited 0
with no issues in 14.9 s. The first complete serial suite had two existing
migration tests exceed the default 30-second per-test timeout; isolated
retries passed in 55 s and 46 s. The complete serial rerun
`flutter test --no-pub --concurrency=1 --timeout 2m` exited 0 with
`663 PASS / 9 SKIP / 0 FAIL` in 26:07. The nine skips are existing
environment-, forensic- or copy-gated cases. The per-test threshold was
raised based on measured isolated runtimes; no command-level timeout was used.

`flutter build windows --release --no-pub` exited 0 in 179.6 s;
`data/app.so` is 13,140,912 bytes, SHA-256
`F7A1FD9A0634523E105C6EF3C306CAFD5AA8F18D3B6FB92C962251A4CDC70C04`.
The unchanged 89,600-byte Windows runner SHA-256 remains
`E6C2805D1F99621DDA30260B916289AF8CF3A1115BD7B28C80B13A0C5F830BAD`.
`flutter build apk --release --flavor production --no-pub` exited 0 in
890.8 s; the APK is 79,364,113 bytes, SHA-256
`2C98AFF3CFB3A37A3C0412DE8DC3AC2DC63D8AEF85EBB3F4E28CE4CA6CCF8489`.
The packaged JSON resource in both platform outputs matches the source at
36,424 bytes, SHA-256
`53F24B8525DF09C251CD550AF113EB260CA55582D920E88953F13BBCAF42FBF7`.

QA wall-clock start/end values were not captured when commands started;
reported durations are tool-reported elapsed times and no absolute timestamps
are inferred. These builds do not establish physical runtime behavior. No
physical runtime, commit, push or rebaseline was performed; the protected
active-source CSV remains unchanged. Full evidence is in
[`OPC_FINAL_USER_GUIDE_CONTENT_INTEGRATION_20261012_TRACEABILITY.md`](tasks/OPC_FINAL_USER_GUIDE_CONTENT_INTEGRATION_20261012_TRACEABILITY.md)
and the external canonical review package.

The timestamped final closure rerun supersedes the untimestamped durations
above for this task's completion ordering. `flutter analyze --no-pub` passed
with no issues, exit 0, from `2026-10-12T22:07:04.0677909Z` to
`2026-10-12T22:07:23.5539217Z`. The full serial suite
`flutter test --no-pub --concurrency=1 --timeout 2m` passed with
`663 PASS / 9 SKIP / 0 FAIL`, exit 0, from `2026-10-12T22:07:35.0970405Z` to
`2026-10-12T22:30:25.0152830Z`. The Windows release build passed, exit 0,
from `2026-10-12T22:30:32.0263118Z` to `2026-10-12T22:31:36.3943827Z`; the
Android production APK build passed, exit 0, from `2026-10-12T22:31:41.5987500Z`
to `2026-10-12T22:32:29.1275400Z`. See the task traceability report and
canonical external QA JSON for commands, artifact hashes and full chronology.
# OPC v1.5 final development closure — 2026-10-13

OWNER accepted the current OPC v1.5 product as stable, functionally correct
and final. The OWNER-approved final guide integration on 2026-10-12 was the
last v1.5 development/correction task. The scoped Android Narrow/Wide
delta-runtime on 2026-10-13 was accepted only for the cases it executed; its
report remains `PARTIAL` for comprehensive guide/chapter-route coverage.
Windows physical runtime, signing, distribution and formal release handover
are separate states and are not claimed complete here.

The source, tests, guide asset, QA and release-build evidence retained for this
closure is indexed by `OPC_V15_FINAL_CLOSURE_REPORT.md` and its external review
package. The historical active-source control remains at its accepted
`20/28 LITERAL MATCH – 8/8 PROVENANCE RESOLVED` result; it was not rebaselined.
No new QA/build was necessary for this documentation-only closure record.
