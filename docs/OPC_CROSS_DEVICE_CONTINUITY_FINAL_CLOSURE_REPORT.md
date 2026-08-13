# OPC Cross-Device Continuity — Final Closure Report

Date: 2026-08-13  
Branch: `task/OPC-CROSS-DEVICE-CONTINUITY-FINAL-CLOSURE`  
Baseline/current starting SHA: `e9d2684166386c8ff60f2ea496599cd07beb785a`

## A. Baseline / branch / SHAs

The branch was created from the clean overnight branch at `e9d2684`; the
origin overnight ref was verified at the same SHA before changes. The active
Windows database remains `C:\Users\Steva\Documents\opc_v4_release.sqlite`.
All forensic SQL and repair work used timestamped copies; the canonical file
was never mutated.

## B. Resources actually available and used

Main Codex performed final integration. Two subagents were available and used:
`catalog_immunity_reviewer` reviewed KATALOG projection, PREDMET snapshot
immunity, references and copy-dedup scope; `pdf_fidelity_reviewer` reviewed
LISTA/shared derivative filters and NALOG's intentional scope. No recurring
watchdog automation was available or used. No callable computer-use tool was
available in this desktop session, so real Windows startup is deferred.

Long jobs used `Start-Process` with redirected logs, `Get-Process` CPU/memory
polling, timestamped output files, and exact-PID cleanup only for stale or
explicitly launched processes. Android physical/wireless acceptance was not
attempted.

## C. Prior timeout diagnosis

The overnight “local timeout” was imposed by the Codex `functions.exec` shell
wrapper: the prior full validation command ended after approximately 604.1 s
without a Flutter exit code. Child `flutter_tester` processes remained alive,
which then caused a native-assets collision (`sqlite3.dll`, errno 183) on the
next run. The stale PIDs were stopped, `flutter clean` and `flutter pub get`
completed, and validation was retried cleanly. A first analyzer retry also
stalled at `Analyzing SOURCE...` (PID 12748) and was stopped only after a
documented no-progress observation; a second monitored run completed normally.
No project script or CI watchdog imposed the original limit.

## D. Concrete KATALOG article projection fix

`IriuDisplayNameResolver` now treats a non-technical stored `nazivPrikaz` as
the concrete selected-article snapshot before falling back to the current
category or built-in label. This is shared by all KATALOG categories; category
identity remains in `interniNaziv`. Missing receiver KATALOG rows therefore do
not erase the stored concrete name. Regression coverage proves CRNINA/Ešarpa,
another category/SANDUK V-4, category metadata retention, and missing-local-
catalog behavior.

## E. LISTA PDF / PDF derivative fidelity fix

LISTA's `_buildListaIriuItems` no longer excludes
`IriuDerivativeExclusion.documentScopedOut`; it still excludes only rows that
are not operationally active. LISTA, PREDRAČUN, RAČUN and SPECIFIKACIJA share
this prepared itemized data, so financially included citation rows are visible
in each. PREDMET snapshot export already renders raw IRiU rows. NALOG's
document-specific seven-category projection was audited and intentionally left
unchanged. `Parcela`, `Broj`, `Red`, and `NPK` labels remain unchanged.

## F. Historical PREDMET KATALOG-immunity matrix

| State | Live KATALOG name can alter display? | Live price can alter amount? | Deleted KATALOG row breaks display/edit? | Dedup safe? |
|---|---|---|---|---|
| OTVOREN | No: stored `nazivPrikaz` wins | No: stored `cena`/`iznos` are row truth | No for display; picker may show no current option | Proven on repaired copy; runtime smoke still deferred |
| ZATVOREN | No | No | No | Yes, with reference remap |
| ZAVRŠEN/final | No; immutable row snapshot | No | No | Yes, with reference remap |
| ANONIMIZOVAN/history | No | No | No | Yes, with reference remap |

The source table stores stable article ID, display name, quantity, price and
amount on IRiU. Repository/KATALOG policy changes materialize only future
PREDMET rows; they do not rewrite existing rows. SCENARIO provenance is a
separate PREDMET-owned snapshot and is unaffected by catalogue tuple cleanup.

## G. OTVOREN PREDMET special-case findings

Target PREDMET id 113 (`120826_1949`, status `OTVOREN`) was present in the
fresh copy and in the repaired copy. Its citation row already referenced the
deterministic minimum-ID survivor. Copy repair preserved its name, price,
amount, quantity, status, IRiU order, scenario snapshot and provenance; the
copy passed integrity and idempotency checks. Full UI reopen, picker edit,
scenario reconciliation, JSON round-trip and PDF generation against the
repaired external copy were not run because the application database path is
not redirected in this session. Therefore copy-level safety is proven while
real runtime acceptance remains deferred with Windows startup.

## H. ČITULJE multiplication historical/root-cause investigation

The concentration is consistent with repeated historical initialization of the
two citation distributions: the production seed lists contain the citation
tuples and use `insertOrIgnore`, while the forensic copy contains 2,924
Politics rows and 1,459 News rows but only 34 and 17 distinct business tuples.
No equivalent multiplication was found in the other KATALOG categories. Git,
seed/migration and repository inspection found no PREDMET business path that
rewrites historical IRiU rows from live KATALOG data. Exact historical build-
era invocation counts cannot be reconstructed from row IDs alone, so the old
release/init trigger is classified as a bounded inference, not as a proven
single event.

## I. Current recurrence-path status

The current seed path is tuple-idempotent: the exact category/name/price tuple
guard prevents another insertion when the same distribution is initialized.
The recurrence path is therefore closed by source and existing KATALOG tests;
the historical rows remain a separate repair concern.

## J. SQLite WAL reset bug informational assessment

The forensic copy reports `journal_mode=delete`, not WAL, and
`PRAGMA integrity_check` is `ok`. SQLite's official WAL documentation describes
the reset race as a narrow WAL-mode, multi-connection checkpoint/write issue
(fixed in current SQLite releases), not as a generator of thousands of exact
business tuples. See [SQLite WAL documentation](https://www2.sqlite.org/wal.html)
and the [current SQLite release log](https://sqlite.org/releaselog/current.html).
The Dart `sqlite3` package version is not itself proof of the bundled native
engine version, so no dependency upgrade was made. Classification: **NOT
APPLICABLE** to the observed DELETE-journal, tuple-repetition incident.

## K. Duplicate equivalence/reference inventory

Uniqueness tuple is exactly `(interni_naziv_kategorije, naziv, cena)`; no
cross-category merge is permitted. The copy contains 51 duplicate groups and
4,332 removable rows (Politics 2,890; News 1,442). Eight IRiU references exist;
stock, applied-effect and consequence references are zero; citation media BLOB
references are absent. Thirteen unresolved historical IRiU stable IDs are
unrelated to these duplicate groups and remain unchanged.

## L. Dedup survivor strategy

For every exact tuple group, survivor is deterministic `MIN(katalog_artikli.id)`.
Before deletion, all references in IRiU, stock, applied effects and
consequences are remapped; conflicting simultaneous references would defer the
group. No metadata or media variants were found, and no cross-category merging
was attempted.

## M. Copy-based repair proof

Repair ran only on:
`C:\Projekti\OPC\OPC v.1\RUNTIME\forensic_db\final_closure_20260813\opc_v4_release_citation_dedup_repair_copy.sqlite`.
Counts changed 2,924/1,459 to 34/17; 4,332 rows were deleted. Full target
PREDMET/IRiU truth comparison was equal before/after; integrity was `ok`,
remaining duplicate groups were zero, and a reopen/idempotency pass found 51
existing tuple matches and no new inserts. Repaired-copy SHA-256:
`515E88055F8AE8533BED3FF4622A11D7BF2D9B0E36D21F884DE90EE99FC15480`.

## N. Canonical repair status

Canonical repair is **DEFERRED**. The copy proof is complete, but real startup,
picker and release-lifecycle acceptance against a repaired canonical artifact
was not available in this session. No production database mutation occurred.

## O. Targeted tests

Changed-scope run: `flutter test --no-pub test/iriu_catalog_display_name_resolution_test.dart test/lista_pdf_fidelity_test.dart` — **10 passed**. Prior focused carrier/transfer/order/KATALOG/scenario/ceremony suites also passed (13, 22, and 16 passed with 2 documented legacy skips).

## P. Full analyzer

`flutter analyze --no-pub` was launched at 12:46:01 with redirected logs and
completed in 28.5 s: **No issues found**.

## Q. Full Flutter suite

`flutter test --no-pub` was monitored as a background process from 12:46:56;
it ran naturally through the migration corpus and completed with **398 passed,
7 skipped, 0 failed**. No artificial timeout or forced termination was used.

## R. Windows release build

`flutter build windows --release --no-pub` started at 13:00:07, remained active
through native CMake/MSBuild compilation, and completed at approximately 553 s
with exit 0. Artifact: `build\windows\x64\runner\Release\OPC.exe`.

## S. Android release build

`flutter build apk --release --no-pub` started at 13:11:35. Gradle/Java was
monitored under the machine's memory constraints and completed naturally after
1,418.1 s: **PASS**, artifact `build\app\outputs\flutter-apk\app-release.apk`
(74.5 MB). A polling shell command hit its own 151-second limit while the
Gradle process continued; the build itself was not terminated.

## T. Windows real startup lifecycle

`WINDOWS REAL STARTUP LIFECYCLE — DEFERRED: COMPUTER-USE UNAVAILABLE`.
No installed-app launch, DB reopen, PDF visual check or relaunch claim is made.

## U. Android physical-device deferral

`ANDROID PHYSICAL-DEVICE / WIRELESS-DEBUGGING ACCEPTANCE — DEFERRED BY OWNER`.

## V. Incidental findings

The first post-clean targeted run exposed a Flutter native-assets collision
caused by stale `flutter_tester` children; cleaning after stopping those exact
PIDs resolved it. Dart telemetry also attempted an unauthorized timestamp
update outside the workspace during formatting; it did not affect source or
tests. Neither finding changes application business behavior.

## W. Documentation reconciliation

Updated the overnight report, authoritative dependency plan, current
development state, source-of-truth map and owner decision index. Concrete
article labels and citation-row visibility are now recorded as locked/current,
while canonical repair, startup and Android physical acceptance remain clearly
gated. The report itself is this document.

## X. Deferred owner items

Only exact unresolved gates remain: real Windows startup if computer-use is
enabled, canonical repair authorization after that gate, and owner-deferred
Android physical/wireless acceptance. No owner decision is required for the
concrete-label or LISTA citation-row rules; those are locked.

## Y. Final Git state

Final changes are limited to the resolver, LISTA projection, regression tests,
and continuity documentation. Generated validation logs/build outputs are not
part of the source change. `git diff --check` passed before commit preparation.

## Z. Final verdict

- `CONCRETE KATALOG ARTICLE DISPLAY — PASS`
- `LISTA PDF PREDMET FIDELITY — PASS`
- `OTHER PDF DERIVATIVE FILTER AUDIT — PASS`
- `HISTORICAL PREDMET KATALOG IMMUNITY — PROVEN`
- `OPEN PREDMET DEDUP SAFETY — PROVEN`
- `ČITULJE MULTIPLICATION ROOT CAUSE — PARTIAL`
- `CITATION RECURRENCE PATH — CLOSED`
- `SQLITE WAL RESET BUG RELEVANCE — NOT APPLICABLE`
- `SAFE DUPLICATE SURVIVOR STRATEGY — READY`
- `COPY-BASED DEDUP REPAIR — PASS`
- `CANONICAL DEDUP REPAIR — DEFERRED`
- `CANONICAL DB BUSINESS TRUTH PRESERVED — PASS`
- `flutter analyze — PASS`
- `flutter test — PASS`
- `WINDOWS RELEASE BUILD — PASS`
- `ANDROID RELEASE BUILD — PASS`
- `WINDOWS REAL STARTUP LIFECYCLE — DEFERRED`
- `ANDROID PHYSICAL-DEVICE ACCEPTANCE — DEFERRED BY OWNER`
- `SUBAGENT/WATCHDOG RESOURCE USE — DOCUMENTED`
- `OWNER-INDEPENDENT CLOSURE SCOPE — COMPLETE`
- `AUTHORITATIVE DOCUMENTATION — UPDATED`
- `REMOTE SHA — NOT YET CONFIRMED`
- `WORKING TREE — NOT CLEAN`

Overall status: `CLOSURE PARTIAL — SAFE OWNER-INDEPENDENT WORK EXHAUSTED`
