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

Owner runtime evidence is authority for observed end-product behavior, not automatic proof of internal root cause. Windows and Android acceptance are not interchangeable.

### 5A. Android structural-acceptance lane

Release/runtime evidence remains PRODUCTION-specific. For shared database invariants, `ANDROID_TEST` is the dedicated synthetic, disposable and intentionally inspectable physical acceptance lane: its `opc_v4_android_test` database may be copied read-only through the debuggable test package for schema, integrity, referential-cleanup, replacement and backup/restore evidence. This lane does not relax PRODUCTION protection and must contain no owner production data, credentials, backups or private exports. ANDROID_TEST evidence is authoritative only for invariants whose implementation equivalence with PRODUCTION has been explicitly proven.

RR-011 current-fact status: `CLOSED — FULL ANDROID STRUCTURAL ACCEPTANCE PASS`. The final physical ANDROID_TEST wave completed PASS evidence for device connectivity, schema/integrity/FK, provenance cleanup, real scenario-snapshot cleanup and the separately scoped single-PREDMET replacement with stable identity and relaunch persistence. The single-PREDMET `OPC_PREDMET` JSON format does not carry scenario snapshot/provenance rows; that boundary is documented. The earlier ADB-offline/10060 attempt is historical. No RR-011 successor remains.

Current architecture/deployment concerns include repaired-state/canonical closure, Android transfer/runtime parity, notification lifecycle, filesystem/storage behavior and installer/signing readiness. Native Windows single-instance protection is closed by the accepted mutex/W1–W6 evidence; installer running-app protection is also closed by the accepted Inno Setup compile and I1/I2/I3 evidence. No RR-012 successor remains.

## 6. Backup, restore and interoperability

Single-PREDMET transfer and full-backup JSON remain distinct. Release acceptance must cover:

- schema/legacy readability;
- identity and compatibility checks;
- preservation of PREDMET/IRiU/SCENARIO snapshot boundaries;
- exact restore family and installation-local state rules;
- malformed/legacy input behavior;
- isolated-copy migration and restore evidence;
- Windows/Android artifact and runtime scope.

Release/data-integrity acceptance also protects the empty-business-KATALOG contract: a fresh database may create structural/auth singleton state, but must not invent user/business categories or articles. Existing KATALOG content must survive reopen and migration without automatic reseeding; tests must provide explicit catalogue fixtures when required.

Prior successful incidents are scoped evidence, not the final product-line rehearsal. A release-candidate backup/restore rehearsal remains open in the current development plan.

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
- unresolved PODSETNIK signal model;
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
