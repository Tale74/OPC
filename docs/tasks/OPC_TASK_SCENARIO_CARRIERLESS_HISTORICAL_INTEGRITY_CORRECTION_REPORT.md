# SCENARIO Carrierless Historical-Integrity Correction — Report

**Date:** 2026-09-30
**Authorized scope:** bounded correction to the existing SCENARIO applied-state
integrity + PREDMET selector implementation
**Source QA / release builds:** PASS
**Logos independent correction review:** PENDING
**OWNER runtime acceptance:** PENDING
**Publication:** no staging, commit or push

## 1. Continuity and evidence boundary

- Repository: `C:\Projekti\OPC_v1.5\source`
- Branch / HEAD: `codex/opc-v1.5-clean-baseline` /
  `f0bdcbcdb947fdbc72cc08b9e9951f545a8c3845`
- The branch was already dirty at correction intake from the separately
  authorized Direction 2 work and the SCENARIO implementation. That original
  work was preserved; the prior implementation report/package remains
  historical evidence and is not rewritten.
- The Logos FAIL being corrected was specifically
  `LEGACY/CARRIERLESS NON-FABRICATION — FAIL / NOT YET PROVEN`: no trustworthy
  snapshot had been presented as categorical proof that no SCENARIO was ever
  applied, while open-time reconciliation/provenance logic could use today's
  configuration to make legacy history look known.
- The original implementation package had SHA-256
  `4FAB891605A1410953331807966AC85A06C98557AB0EE514702F832A6AC4851F`.
- The active-source package was not edited or rebaselined. At completion, the
  28-row hash file has four current mismatches: two control-document/pseudocode
  divergences already present at intake, plus the `predmeti_repository.dart`
  and `lista_predmeta_screen.dart` rows. These are disclosed, not normalized
  into the protected baseline. No other row differs.
- No canonical/private runtime database, schema, generated database file,
  JSON carrier contract, historical SCENARIO payload, or business rule was
  changed by this correction.

## 2. Source-causal result

### Legitimate current application vs. historical reconstruction

The new-PREDMET path is distinguishable in existing application control flow:
`ListaPredmetaScreen._noviPredmet` calls `kreirajPredmet` and
`inicijalizujIriu`, then opens `PredmetScreen` with the transient
`isNewPredmetCreationFlow` signal. That signal is forwarded to `IriuSegment`,
where it authorizes the first current SCENARIO application. Ordinary opening
does not carry that signal. Actual later changes to relevant PREDMET facts are
still recognized by `didUpdateWidget` as current events.

For an ordinary open, `IriuSegment` now reconciles only when a stored
assignment snapshot exists and every current IRiU occurrence has durable
provenance. Snapshot absence, missing provenance, or partial carrier evidence
does not qualify. This uses existing durable state and a route-lifecycle
signal; no new database fact or schema state was invented.

The production `MODULI → SCENARIO` selected-PREDMET path remains a read-only
preview. It does not materialize a first assignment. It then displays only
persisted snapshot/provenance evidence.

### OSNOVNI_PAKET provenance backfill

The old generic backfill assigned `OSNOVNI_PAKET` to any untagged row whose
current `interniNaziv` matched today's evaluated basic-package category set.
Because this loop could run against historical/carrierless PREDMETI, it could
not prove original row ownership. The loop was removed. Instead, the
new-PREDMET initialization transaction writes provenance at the point where
it itself creates each basic-package row. This records source-proven origin
without retroactively classifying matching legacy rows.

### Presentation

The null-snapshot branch now says `Istorijski SCENARIO snapshot nije dostupan.`
It does not infer an applied scenario/package and no longer claims
`SCENARIO paket nije primenjen.` Absence of snapshot is treated as unavailable
historical evidence, not proof of non-application.

## 3. Correction file set

Correction-specific source files:

- `lib/features/predmeti/core_v2/scenario/scenario_module_screen.dart`
- `lib/features/predmeti/core_v2/scenario/scenario_runtime_reconciliation_service.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`

Correction-specific tests:

- new `test/scenario_carrierless_historical_integrity_test.dart`;
- `test/scenario_open_predmet_bounded_detail_test.dart` now verifies the
  truthful fallback and proves that selected carrierless rows gain neither a
  snapshot nor provenance.

Some listed source files already contained pre-existing Direction 2 or
SCENARIO selector work at intake. The correction handoff includes the intake
status, a HEAD-to-candidate before/after diff, and the predecessor
implementation package so Logos can distinguish earlier hunks from the new
correction. The diff is cumulative where files were already dirty at intake;
the notes classify those overlaps rather than mislabeling that diff as
correction-only.

## 4. Regression coverage

The new focused tests establish:

1. New-PREDMET base rows receive provenance inside the initialization
   transaction, and no SCENARIO snapshot is written prematurely.
2. A carrierless existing PREDMET with a category matching today's rule is
   unchanged by read-only preview; it receives no inferred provenance or
   snapshot.
3. Transferred `PARTIAL` and `UNAVAILABLE` records with missing per-row
   provenance do not satisfy the automatic-open evidence gate.
4. Existing IRiU row identity/business content remains present.

The bounded-detail widget regression verifies the user-facing fallback and
database state after selecting the existing PREDMET through the SCENARIO
module's production selection path. Existing current-application,
valid-applied-state, transfer-v1/v2, full-Backup and failure-atomicity tests
were retained and included in focused/full QA.

## 5. Verification

Focused tests (serial):

- carrierless, atomicity, runtime application and bounded-detail group:
  `5 passed / 0 failed`;
- lifecycle, JSON transfer, carrier, selector and module group:
  `57 passed / 2 skipped / 0 failed`;
- standalone carrierless file rerun after removing one analyzer warning:
  `2 passed / 0 failed`.

Final technical sequence, serial and with exit status:

- `flutter analyze --no-pub`: PASS, `No issues found`, exit 0;
- `flutter test --no-pub --concurrency=1`: PASS,
  `602 passed / 9 skipped / 0 failed`, exit 0;
- `flutter build windows --release --no-pub`: PASS, exit 0,
  `build\\windows\\x64\\runner\\Release\\OPC.exe`;
- `flutter build apk --release --no-pub`: PASS, exit 0,
  production output `build\\app\\outputs\\flutter-apk\\app-production-release.apk`
  (75.8 MB).

The nine full-suite skips are opt-in forensic or isolated-owner-database
tests; none is reported as a pass. `git diff --check` passed. QA/build is
technical evidence only, not runtime acceptance.

Build artifact identity:

- Windows launcher executable SHA-256:
  `962DF83C2F07C51B6F142199F88DF14E6CD5ABA638FCF80F6699BF860AAE9F2C`
- Android production APK SHA-256:
  `29C0B93716FB2375D69B66A28B4B284AFDE5FE9A3CD98B7220D2B8D3969D8E58`

The APK is identified by hash only and is not included in the review ZIP.
Build success does not prove installed-artifact attribution or runtime
behavior.

## 6. Requirement and architecture impact

- PREDMET remains the sole business source of truth; current SCENARIO rules
  consume PREDMET facts.
- Legitimate first application and current fact-change reconciliation remain
  available; unsupported historical reconstruction is blocked.
- The existing single-transaction IRiU/provenance/snapshot apply boundary and
  rollback tests remain in place.
- Transfer v2 `COMPLETE` / `PARTIAL` / `UNAVAILABLE`, v1 compatibility,
  full-Backup behavior, and selector behavior are unchanged by the correction.
- Database schema, JSON contract, business policy and SCENARIO definitions:
  `NOT APPLICABLE / UNCHANGED`.
- External dependency/API and native platform adapters:
  `NOT APPLICABLE / UNCHANGED`.
- Verification/acceptance: focused + full QA and both platform builds rerun;
  Logos review and OWNER runtime remain separate pending gates.
- Current-state documentation is updated in architecture, quality/release,
  and development-state records. No historical report was edited to erase its
  earlier result.

## 7. Completion status

- `CARRIERLESS SOURCE-CAUSAL ANALYSIS — PASS`
- `HISTORICAL NON-FABRICATION — PASS` (source/test evidence; runtime pending)
- `FALSE NO-SCENARIO PRESENTATION — CORRECTED`
- `LEGITIMATE CURRENT SCENARIO APPLICATION — PRESERVED`
- `ATOMIC APPLIED-STATE PATH — PRESERVED`
- `PARTIAL / UNAVAILABLE TRANSFER SEMANTICS — PRESERVED`
- `SCENARIO DROPDOWN — PRESERVED`
- `FOCUSED REGRESSION TESTS — PASS`
- `FULL TECHNICAL QA — PASS (602/9/0)`
- `WINDOWS RELEASE BUILD — PASS`
- `ANDROID PRODUCTION RELEASE BUILD — PASS`
- `PREDMET SOLE-BUSINESS-TRUTH INVARIANT — PRESERVED`
- `LOGOS INDEPENDENT CORRECTION REVIEW — PENDING`
- `OWNER RUNTIME ACCEPTANCE — PENDING`

This is not final SCENARIO correction closure. No staging, commit, push,
protected-hash rebaseline, publication or OWNER runtime claim was made.
