# SCENARIO Applied-State Integrity + PREDMET Selector — Implementation Report

**Date:** 2026-09-30
**Status:** `IMPLEMENTATION / QA / WINDOWS RELEASE BUILD / ANDROID PRODUCTION BUILD — PASS`
**Logos post-implementation review:** `PENDING`
**OWNER runtime acceptance:** `PENDING`
**Publication:** no commit or push

## 1. Task boundary and continuity

This report covers the previously OWNER-authorized bounded implementation
`OPC v1.5 — SCENARIO APPLIED-STATE INTEGRITY + PREDMET SELECTOR STANDARDIZATION`.
It does not authorize or claim SCENARIO retroactivity, business-policy edits,
database/schema changes, broader selector redesign, or runtime acceptance.

- Repository: `C:\Projekti\OPC_v1.5\source`
- Branch: `codex/opc-v1.5-clean-baseline`
- HEAD remains: `f0bdcbcdb947fdbc72cc08b9e9951f545a8c3845`
- Active-source control package passed its required pre-edit checks.
- The worktree was already dirty before implementation from the separately
  approved Direction 2 effort. Those edits were preserved. In particular, the
  existing owner-approved `Broj otvorenih predmeta: N` and
  `SAHRANA U INOSTRANSTVU` literals in `scenario_module_screen.dart`, plus
  their test expectations, were retained. The selector regression was placed
  in its own file after an observed test-isolate/native-database interference
  when it shared the older screen test file.
- No staging, commit, push, source reset, or protected-baseline rebaseline.

The task started from the existing source-level design review and OWNER
implementation authorization. This report does not replace independent Logos
review or OWNER runtime acceptance.

## 2. Requirements and implementation

### Atomic applied-state reconciliation

`lib/features/predmeti/data/iriu_repository.dart` separates planning from
mutation. Planning returns the candidate diff and all rows needing a user
decision without writing rows, pending flags, provenance or snapshot state.
If any decision is missing, the plan remains non-mutating. The final apply
path performs lifecycle-aware removals, explicit keeps, additions/updates,
ordering rebuild, provenance maintenance and accepted snapshot persistence in
one database transaction. Nested repository lifecycle helpers remain within
that outer transaction through Drift nested transaction/savepoint behavior. A
provenance-trigger failure-injection test verifies that managed rows and the
snapshot roll back together.

`lib/features/predmeti/presentation/segments/iriu_segment.dart` gathers all
required keep/remove decisions first. Cancellation at any dialog leaves the
full persisted state untouched; it no longer commits one removal before
asking about the next row.

### Carrier compatibility and applied-state continuity

`scenario_transfer_envelope.dart` and
`single_predmet_scenario_carrier_contract.dart` write v2 and add explicit
`PARTIAL` coverage. V2 distinguishes no known references, a strict non-empty
known subset and complete provenance. V1 `COMPLETE`/`UNAVAILABLE` remains
readable; no v1 `PARTIAL` is accepted. Single-PREDMET and full-backup paths
restore only provenance references that were actually present. Missing
provenance is not inferred from `scenarioUpravlja`; transfer does not rewrite
snapshot content or hashes.

### PREDMET selector and stale-async protection

`scenario_module_screen.dart` replaces the active runtime card list with a
standard single-selection dropdown. Only eligible open PREDMETI are offered;
the identity includes full name and case number where available. Selection
switches key/reset the detail subtree, and asynchronous generation guards
prevent a late load for PREDMET A from appearing under PREDMET B. Refresh
clears a selected PREDMET that is no longer eligible and reports refresh
failure rather than retaining stale detail.

No database schema, PREDMET business fields, SCENARIO rule identity, package
meaning, lifecycle policy or OWNER business policy was changed.

## 3. Change inventory

Implementation-owned source files:

- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/core_v2/scenario/scenario_module_screen.dart`
- `lib/features/predmeti/core_v2/scenario/scenario_transfer_envelope.dart`
- `lib/features/predmeti/core_v2/scenario/single_predmet_scenario_carrier_contract.dart`
- `lib/core/utils/json_export_import.dart`

Implementation-owned test changes/additions:

- `test/scenario_iriu_repository_atomicity_test.dart`
- `test/scenario_open_predmet_selector_test.dart`
- `test/scenario_runtime_application_test.dart`
- `test/scenario_module_screen_test.dart`
- `test/scenario_open_predmet_bounded_detail_test.dart`
- `test/scenario_transfer_envelope_test.dart`
- `test/single_predmet_scenario_carrier_contract_test.dart`
- `test/json_transfer_regression_test.dart`

The pre-existing Direction 2 changes in overlapping dirty files are not
re-attributed to this task. The Logos handoff records the complete
baseline-to-worktree diff, overlap caveat and exact paths so Logos can compare
source and tests directly.

Documentation updated by this implementation:

- `docs/OPC_ARCHITECTURE.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_QUALITY_RELEASE.md`
- `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- this task report

## 4. Verification evidence

All commands completed sequentially; no Flutter/Dart/Gradle QA job overlapped
another.

| Command | Result |
|---|---|
| Focused SCENARIO/IRiU/selector/carrier/transfer test set | `89 passed / 0 failed`; 2 conditional skips |
| `flutter analyze --no-pub` | PASS — `No issues found` |
| `flutter test --no-pub --concurrency=1` | PASS — `600 passed / 9 skipped / 0 failed` |
| `flutter build windows --release --no-pub` | PASS — 231.0 s |
| `flutter build apk --release --no-pub` | PASS — `assembleProductionRelease`, 1110.9 s |

The nine full-suite skips were conditional forensic/copy tests whose required
external isolated evidence inputs were not configured. No skip represented a
test failure. The first analyzer attempt reported two `prefer_const` infos in
the new selector header; these were corrected, and the final analyzer run
passed with no issues.

Build outputs:

- Windows executable: `build/windows/x64/runner/Release/OPC.exe`, 89,600 bytes,
  SHA-256 `962DF83C2F07C51B6F142199F88DF14E6CD5ABA638FCF80F6699BF860AAE9F2C`.
  The native runner executable timestamp stayed at the previous native-runner
  build because runner sources did not change; the current-source Flutter
  build refreshed bundled `data/app.so`/Flutter assets around 2026-09-30 01:39
  local. The build command completed successfully.
- Android production APK:
  `build/app/outputs/flutter-apk/app-production-release.apk`, 79,436,327 bytes
  (75.8 MB), SHA-256
  `C7F4F5D7C1F35A8877C731EBBDAF5DBCF1CB38A6B3AF509F09FDCB92D949A49D`.

Artifact hashes identify these local build outputs. They do not prove a
particular installed runtime artifact or OWNER runtime behavior.

## 5. Engineering-profile impact

- **Business authority/traceability:** no policy changed; PREDMET remains the
  authoritative business source. Existing SCENARIO snapshot/provenance records
  applied presentation/history. Requirements remain traceable to the approved
  design and regression contracts.
- **Architecture/data contract:** reconciliation is a single atomic apply
  boundary; carrier v2 adds `PARTIAL` with v1 read compatibility. No SQL
  schema migration was needed. JSON transfer contract tests protect it.
- **Implementation/compatibility:** Windows and Android share the same Dart
  implementation. Existing base package, user-owned rows, lifecycle semantics,
  snapshot hashes, and known transfer references are preserved.
- **Verification/acceptance:** focused rollback/selector/transfer tests,
  analyzer, full suite and both release builds pass. Runtime observation is a
  distinct pending gate.
- **Quality/release:** no signing, provenance publication, runtime acceptance
  or release readiness is inferred. No commit/push occurred.
- **Current-state docs:** architecture, quality/release, current development
  state and local pseudocode were updated. The active high-risk baseline was
  intentionally not edited; these documentation changes may need a separately
  authorized protected-hash reconciliation.

`NOT APPLICABLE`: external dependency/API, platform adapter, database schema,
business rule and source migration links were not changed. Separate artifacts
for those unaffected links were not created.

## 6. Findings and remaining gates

- Incidental test-isolate interference was resolved by placing the new selector
  regression in its own file; it has no remaining product impact.
- No new unresolved OWNER business decision was discovered.
- **Logos post-implementation review:** pending; the handoff must verify actual
  source/test diffs against the bounded design and earlier dirty-worktree
  overlap.
- **OWNER runtime acceptance:** pending; exercise Android/Windows as
  separately authorized, especially A→B selector reset, open-only filtering,
  refresh invalidation, removal-dialog cancellation/no-mutation, and v1/v2/
  PARTIAL transfer continuity. Tests/builds are not runtime evidence.
- **Publication:** not authorized/performed. Protected active-source hashes
  were not silently reconciled.
