# OPC Windows Real Runtime / Canonical Closure Report

Date: 2026-08-13  
Branch: `task/OPC-WINDOWS-REAL-RUNTIME-CANONICAL-CLOSURE`  
Starting SHA: `1d71dc5cab9df0d8091bdeb27bc4029e0b96dfb5`

## A. Baseline / branch / SHAs

The branch was created from the pushed final-closure SHA. The starting branch
and remote both resolved to `1d71dc5cab9df0d8091bdeb27bc4029e0b96dfb5`.
Android remained out of scope.

## B. Computer-use/resource availability and actual use

Computer Use was available through the installed Windows Computer Use skill and
was used with `sky` against the installed executable
`C:\Program Files\OPC\OPC.exe`. It launched, logged into the local
administrator session, opened the home list and target PREDMET, entered the
`ROBA I USLUGE` workspace, and was relaunched for a second startup. No
screenshot evidence was captured: `get_window_state(... include_screenshot:true)`
returned `SetIsBorderRequired failed: No such interface supported (0x80004002)`
for this Flutter window; accessibility-tree evidence remained available.

No subagent was needed for this Windows-only pass. Process/database monitoring
used `sky.list_apps/list_windows/get_window_state`, redirected process state,
PowerShell `Get-Process`, exact-PID stop only for the launched OPC process, and
read-only SQLite/Python inspection. No watchdog automation was available or
used. Owner-side enablement and Codex exposure matched for Computer Use.

## C. Active Windows DB re-verification

Source resolves the Windows production name `opc_v4_release` through
`kDatabaseName` and `driftDatabase(name: kDatabaseName)`. The active runtime DB
was proven as:

`C:\Users\Steva\Documents\opc_v4_release.sqlite`

Before runtime: 82,829,312 bytes, SHA-256
`A5A5C4CF880C2D5116EE42D171CAB03EC8523003DBFB1B910D7D9FFDC26762C1`,
`user_version=27`, journal mode `delete`, `integrity_check=ok`.

Fresh pre-start copy:
`C:\Projekti\OPC\OPC v.1\RUNTIME\forensic_db\windows_runtime_closure_20260813_145730\opc_v4_release_active_windows_forensic_copy.sqlite`

Source and copy hashes matched exactly.

## D. Pre-start DB evidence

Target PREDMET id 113, `120826_1949`, was `OTVOREN`, version 1, with
`default_funeral_ceremony_policy`, 18 IRiU rows, one applied snapshot and
provenance split between `OSNOVNI_PAKET` and `SCENARIO_PAKET`. Stored values
included `ČITULJA POLITIKA I/90 mm — Cela zemlja` at 3,500 RSD and `Ešarpa` in
the CRNINA category at 400 RSD.

Pre-start citation state was Politics 2,924 rows / 34 tuples, News 1,459 rows /
17 tuples, 51 duplicate groups, and 13 unrelated unresolved historical IRiU
stable references.

## E. Cold-start lifecycle

The installed OPC executable launched successfully and exposed the expected
window title `OPC ORGANIZATOR POGREBNE CEREMONIJE` within the monitored startup
observation. The administrator selector, PIN screen, reminder dialog and home
list were usable. No crash, stale-lock dialog or startup hang was observed.

## F. PREDMET runtime validation

The home list showed `JOVIĆ ŽIVKO / 120826_1949`, status `OTVOREN`, ceremony
`KREMACIJA - NOVO`, and adviser `SAŠA ANDONOV`. Opening the row reached the
editable PREDMET screen with status `OTVOREN`; the PREDMET itself opened normally.

## G. IRiU concrete-article display / ordering

The real PREDMET entered the `ROBA I USLUGE` workspace. The accessibility tree
exposed the full itemized editor with repeated `NAZIV KOM IZNOS (RSD)` rows and
catalog actions. The pre-start database snapshot independently confirmed the
concrete stored names and the `redosled` partition. A visual screenshot could
not be captured because of the Computer Use capture limitation above, and the
accessibility provider did not expose editable field values. Therefore the
runtime tree proves the editor surface loaded, while concrete-name visual
acceptance remains partial rather than being overstated.

## H. SCENARIO runtime validation

The target PREDMET's snapshot and provenance were preserved before and after
the real open/reopen cycle. The installed runtime was not safely navigated to
the SCENARIO module: the Flutter accessibility focus cache activated adjacent
top-level buttons (e.g. Moduli opened the preceding module), and no supported
alternate-database injection exists. No SCENARIO mutation was observed in the
database, but a dedicated SCENARIO-view PASS is not claimed.

## I. LISTA PDF runtime validation

The real PREDMET editor loaded its itemized `ROBA I USLUGE` surface, but the
installed UI could not be driven reliably to the document generator while the
Computer Use screenshot path was unavailable. The source-level LISTA fidelity
fix and targeted regression remain valid; real Windows LISTA visual acceptance
is deferred.

## J. Close/reopen lifecycle

The first runtime was closed after the PREDMET/IRiU observation and relaunched
successfully. The second startup again reached the advisor/PIN flow, reminder
dialog and `OPC — LISTA PREDMETA` home list, with the target row present. This
proves startup/reopen at the installed-runtime level, but not every requested
module/document interaction.

## K. Pre/post DB mutation analysis

After the first close, canonical size remained 82,829,312 bytes. Logical
PREDMET, IRiU, target snapshot, target provenance, catalog counts and duplicate
counts were unchanged. The hash changed to
`A09A2D1EF8B9D7B62FA1B699637273F912A4164CFFC1C58C916FE36DCD37BB39`.

The only logical table changes were:

- `ceremony_reminder_settings` for PREDMET 113: scheduled notification IDs
  were refreshed and `updated_at` advanced;
- all 1,021 `scenario_definitions` rows retained identical IDs, status,
  conditions and consequences while `updated_at` advanced to the current
  initialization time.

These are expected derived scheduling/initialization metadata mutations. No
business PREDMET/IRiU mutation, citation growth or duplicate growth occurred.

## L. ČITULJE recurrence runtime proof

Across cold start, login, PREDMET open, IRiU open, close and relaunch, counts
remained Politics 2,924, News 1,459, and 51 duplicate groups. Unique tuple
counts remained 34 and 17; no new unresolved reference appeared. The current
recurrence path is closed for the observed installed runtime.

## M. Repaired-copy validation

A fresh disposable copy of the post-runtime canonical DB was repaired with the
proven exact tuple `(category, name, price)` and deterministic `MIN(id)`
survivors. The repair removed 4,332 rows across 51 groups, remapped all safe
references before deletion, preserved the complete target PREDMET/IRiU truth,
and produced:

- Politics: 34 rows / 34 tuples;
- News: 17 rows / 17 tuples;
- duplicate groups: 0;
- `integrity_check`: `ok`;
- repaired-copy SHA-256:
  `000562EC940BA608CD5064B98C0018DFF684B42733EBE091A185E135D386FD93`.

## N. OPEN PREDMET dedup safety

Database-level OPEN safety is proven: target row 113 remained `OTVOREN`, and
stored name, quantity, price, amount, order, status, snapshot and provenance
were byte/value-equal before and after copy repair. Installed-runtime OPEN
safety before repair is also proven for startup and editor opening. Runtime
picker edit, JSON export, SCENARIO view and LISTA generation against the repaired
copy were not run because the installed runtime has no supported alternate DB
path. Verdict is therefore **PARTIAL**, not a false full runtime PASS.

## O. Canonical dedup gate decision

Canonical dedup is **DEFERRED**. The startup recurrence gate, copy integrity,
duplicate equivalence, deterministic remap and business-truth preservation pass.
The remaining technical gate is repaired-copy application-runtime proof: the
installed executable resolves the fixed canonical path and no supported,
risk-free database override was exposed. Hacking the path would violate the
canonical protection rule. A verified rollback backup therefore was not created
and no canonical transaction was attempted.

## P. Canonical repair execution

Not executed. Canonical DB remains at the post-runtime, non-deduplicated state:
Politics 2,924, News 1,459, 51 duplicate groups, `integrity_check=ok`.

## Q. Post-repair real startup lifecycle

Not applicable: canonical repair was deferred and the repaired copy cannot be
injected into the installed runtime through a supported configuration.

## R. Technical validation if source changed

No source or test files changed in this Windows-only pass. Prior source
validation remains inherited: analyzer PASS, 398 tests passed / 7 skipped,
Windows release build PASS and Android release build PASS.

## S. Incidental findings

Computer Use accessibility indexes for this Flutter window were unstable across
refreshes and sometimes activated the adjacent top-level button. Screenshot
capture failed with the documented Windows.Graphics Capture interface error.
These are tooling/runtime-observation limitations, not evidence of an OPC data
defect. The installed app process was closed explicitly by its exact PID after
each observation; no canonical repair or destructive database operation was
performed.

## T. Documentation reconciliation

This report supersedes the Windows-startup-deferred wording in the final
closure report for the scope it proves. The final-closure report, authoritative
plan, current development state, source-of-truth map and owner index were
updated to point to this report and retain canonical dedup/SCENARIO/LISTA
runtime gates as explicit deferred items.

## U. Deferred items

- repaired-copy UI/runtime proof through a supported alternate DB path;
- canonical dedup transaction and post-repair real startup;
- real SCENARIO view without the Computer Use focus-cache mismatch;
- real Windows LISTA PDF visual acceptance;
- Android physical-device acceptance, intentionally out of scope.

## V. Final Git state

This report and documentation reconciliation are the only intended changes.
Generated runtime-copy path markers are temporary and excluded. The branch will
be committed and pushed after `git diff --check`.

## W. Final verdict

- `COMPUTER USE — AVAILABLE AND USED`
- `ACTIVE WINDOWS DB PATH — PROVEN`
- `PRE-START DB INTEGRITY — PASS`
- `WINDOWS COLD START — PASS`
- `WINDOWS REOPEN LIFECYCLE — PASS`
- `PREDMET 120826_1949 RUNTIME — PASS`
- `CONCRETE KATALOG ARTICLE DISPLAY — FAIL` (runtime value not exposed by the available accessibility/screenshot surfaces)
- `IRiU BUSINESS ORDER — FAIL` (runtime order was not independently observable)
- `SCENARIO VIEW WITHOUT SILENT MUTATION — FAIL` (module navigation was not safely completed)
- `LISTA PDF PREDMET FIDELITY — FAIL` (real Windows generator interaction was not completed)
- `ČITULJE STARTUP RECURRENCE — CLOSED`
- `REPAIRED-COPY DEDUP — PASS`
- `OPEN PREDMET DEDUP RUNTIME SAFETY — PARTIAL`
- `CANONICAL DEDUP — DEFERRED`
- `POST-REPAIR STARTUP — NOT APPLICABLE`
- `CANONICAL PREDMET BUSINESS TRUTH — PRESERVED`
- `WINDOWS SOURCE VALIDATION — NOT REQUIRED`
- `ANDROID PHYSICAL-DEVICE ACCEPTANCE — NOT RUN BY DESIGN`
- `WINDOWS CLOSURE — PARTIAL`
- `REMOTE SHA — NOT YET CONFIRMED`
- `WORKING TREE — NOT CLEAN`

Overall status: `WINDOWS CLOSURE PARTIAL — SPECIFIC RUNTIME/DATA GATE REMAINS`
