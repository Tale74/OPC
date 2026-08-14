# OPC Overnight Post-Recovery Stabilization Report

Date: 2026-08-14
Branch: `task/OPC-OVERNIGHT-POST-RECOVERY-STABILIZATION`
Baseline: audit commit `095e1a90418fe11bbcc9c3b40e5a8eb411ba0fe2` (recovery
source `9f111064557bd870399d5931e621626f188bd5ee`).

## A. Baseline / audit authority

The Sol forensic audit and its evidence manifest were read before source
changes. The canonical database remained a protected, read-only reference.
PREDMET remains business truth; current-state authority and owner decisions were
not changed.

## B. Process/toolchain preflight

`tools/verify_toolchain_processes.ps1` checks `OPC`, Flutter, Dart,
`flutter_tester`, Java and Gradle names. Every heavy command ran alone with
`--concurrency=1` where supported. Pre/post checks reported zero processes.
Interrupted or artificially timed-out work was never accepted.

## C. PARTE stale-test correction

The schema-8 expectation that `partePripreme` was absent was replaced with an
explicit schema-9 assertion: preparation metadata, template snapshots and
draft JSON are portable, while media bytes are not. Legacy no-PARTE backups
remain safe.

## D. PARTE media portability decision and implementation

Option B was selected because no official media package exists. Schema 9 emits
`parteMediaPolicy=bounded-exclusion-v1`; app-owned PNG bytes and external PDF
derivatives stay outside JSON. Exported preparation rows clear media keys, and
restore clears keys from legacy payloads as well. The logical preparation is
retained and the missing-media behavior is deterministic.

## E. Backup/restore safety changes

Fresh restore tests prove no dangling PARTE media key. A non-destructive
PIB/MB preflight now runs before the destructive FULL restore transaction: two
non-blank local/incoming identity parts must match; an uninitialised blank
installation remains importable. Mismatch leaves local data unchanged.

## F. KATALOG→IRiU before/after caller-path map

Before: picker add and reselection had separate repository implementations.
After: live concrete add and reselection converge through private
`_applyLiveCatalogSelection` and typed `IriuCatalogSelection`; it applies the
same snapshot identity/name/price/quantity/amount and stock/order semantics.
Category-only, SCENARIO/OSNOVNI, Single-PREDMET transfer and FULL restore keep
their explicit historical/lifecycle writers.

## G. Compatibility writer restrictions

The low-level raw methods remain only for manual rows, lifecycle code and
historical transfer boundaries. The public compatibility reselection wrapper
now delegates to the typed semantic implementation. No historical path is
routed through live reselection.

## H. `IriuCatalogSelection` contract correction

`copyWith(katalogStableArticleId: null)` now explicitly clears the nullable
stable ID via a sentinel pattern. Regression coverage includes add/reselect
for CRNINA Flor/Ešarpa, another category, reopen/snapshot preservation and
catalog rename/price non-retroactivity.

## I. Restore PIB/MB guard status

`PARTIAL`: the documented non-destructive mismatch guard is implemented and
tested. Broader firm identity history, blank-field policy and firm-scoped
conflict architecture remain a separately gated owner/technical task.

## J. Targeted test evidence

Targeted PARTE, FULL restore, KATALOG/IRiU, JSON transfer, migration selector
and migration-recovery tests passed: 93 tests in the combined regression run;
the final selector regression passed 9/9.

## K. Analyzer evidence

`flutter analyze --no-pub` passed with `No issues found!` after the final source
state.

## L. Full-suite machine-readable evidence

The final authoritative run used the required JSON file reporter and natural
completion: 484 `testDone`, 484 success, 0 failed, 7 skipped,
`done.success=true`, shell exit 0, elapsed 1858.6 seconds. JSON status, not the
shell code alone, was the acceptance authority.

## M. Child-process cleanup evidence

The preflight script returned count 0 after targeted tests, analyzer, full
suite, Windows build and Android build. No orphan `flutter_tester`, Dart, Java
or Gradle child remained.

## N. Final Windows production build identity

`flutter build windows --release` completed after the green full suite. The
artifact is `build/windows/x64/runner/Release/OPC.exe`; `data/app.so` was
checked for `WINDOWS_TEST`, migration-path and test-database tokens and none
were present. SHA-256 values are in
`docs/artifacts/OPC_OVERNIGHT_POST_RECOVERY_STABILIZATION_EVIDENCE.json`.
No Program Files deployment was attempted.

## O. Final Android build evidence

Because shared Dart/business code changed, `flutter build apk --release`
completed after the Windows build. The APK hash and size are recorded in the
evidence manifest. Physical device and signing/distribution acceptance remain
deferred.

## P. Disposable runtime evidence

All backup/media, identity, selection and snapshot acceptance used in-memory or
temporary disposable databases/media roots. No write-capable runtime was
pointed at the canonical database. Installed visual/login/runtime acceptance is
not fabricated.

## Q. Canonical before/after non-mutation proof

Before and after SHA-256: `812AA438F747D59D3AF3EB073B5FB99EA9D9687459FCF52FC4C01946D06BC51C`; size 82,829,312 bytes. Both checks report integrity `ok`, FK
violations 0, 47 PREDMET, 631 IRiU, 138 KATALOG, 34 Politika, 17 Novosti and
zero duplicate citation tuples.

## R. Documentation/technical-standard updates

Updated the backup policy, canonical recovery report, implementation stop-list
and `GIT_WORKFLOW_ARC`. The latter now codifies Sol audit/Luna implementation
separation, locked owner decisions, no patchwork/orphan preservation, snapshot
immunity, forensic-copy-first canonical protection, strict sequential gates,
JSON `done.success`, child cleanup, diagnostic-build separation and protected
install rules.

## S. Deferred owner actions

`DEFERRED — OWNER ACTION REQUIRED`: protected Windows deployment/UAC, owner PIN
login, real Windows visual acceptance, Politika/Novosti and concrete selection
visual acceptance, SCENARIO non-mutation runtime, LISTA/PDF/print fidelity,
OPEN/ZAVRŠEN/ANONIMIZOVAN acceptance and Android physical/wireless acceptance.

## T. Git completion

The branch is based on the published audit commit. `git diff --check` passed.
Build folders and private runtime databases/media are not part of the commit.
Commit/push and remote SHA verification are performed only after final diff
review.

## U. Final verdict

PARTE SCHEMA-9 TEST CONTRACT — PASS
PARTE MEDIA PORTABILITY CONTRACT — BOUNDED-EXCLUSION PROVEN
FRESH RESTORE DANGLING MEDIA KEYS — NONE
PRODUCTION KATALOG→IRiU LIVE SELECTION PATH — ONE
CRNINA SPECIAL LIVE WRITER — NONE
HISTORICAL TRANSFER SNAPSHOT IMMUNITY — PASS
IRIU CATALOG SELECTION NULLABLE CONTRACT — PASS
PIB/MB DESTRUCTIVE RESTORE GUARD — PARTIAL
TARGETED TESTS — PASS
flutter analyze — PASS
FULL FLUTTER TEST JSON done.success — TRUE
FULL FLUTTER TEST FAILED COUNT — 0
FULL FLUTTER TEST ELAPSED — 1858.6 seconds
SHELL/JSON RESULT AGREEMENT — YES
ORPHAN HEAVY CHILD PROCESSES AFTER TESTS — ZERO
FINAL WINDOWS PRODUCTION BUILD — PASS
WINDOWS MIGRATION-TEST SELECTOR — ABSENT
FINAL ANDROID RELEASE BUILD — PASS
CANONICAL DB HASH — UNCHANGED
CANONICAL FK CHECK — ZERO
CANONICAL ČITULJE DUPLICATION — ZERO
OWNER WINDOWS DEPLOYMENT/LOGIN ACCEPTANCE — DEFERRED BY DESIGN
ANDROID PHYSICAL ACCEPTANCE — DEFERRED BY DESIGN
TECHNICAL EXECUTION RULES — DOCUMENTED
AUTHORITATIVE DOCUMENTATION — UPDATED
REMOTE SHA — CONFIRMED (`22cb5ce3a2da3ee44e3c25b98102923667fd7377`)
WORKING TREE — CLEAN

Overall verdict: `OVERNIGHT STABILIZATION PASS — READY FOR OWNER PRODUCTION RUNTIME ACCEPTANCE`. Owner-only deployment, login, visual and physical-device gates remain deliberately deferred.
