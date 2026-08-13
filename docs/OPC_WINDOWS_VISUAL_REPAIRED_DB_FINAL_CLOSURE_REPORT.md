# OPC Windows Visual + Repaired-DB Final Closure Report

> Superseded for the KATALOG→IRiU pipeline defect and source repair by
> `docs/OPC_CANONICAL_KATALOG_IRIU_PIPELINE_WINDOWS_CLOSURE_REPORT.md`.

Date: 2026-08-13  
Branch: `task/OPC-WINDOWS-VISUAL-REPAIRED-DB-FINAL-CLOSURE`  
Baseline commit / remote SHA: `3d00f4fd6f37f0b48edb9affb25f159c2240340f`

## A. Baseline / SHAs

The worktree was clean at the required Windows canonical-closure commit. A
new branch was created from that exact SHA. The previous report and the
authoritative/current-state documents were reviewed. No application source
change was required.

## B. Computer Use and observation method

Computer Use was available and used against the installed executable
`C:\Program Files\OPC\OPC.exe`. The real advisor selection, PIN entry,
reminder dismissal, home/PREDMET navigation and process shutdown were driven
with `sky`. The installed runtime reached the live window
`OPC ORGANIZATOR POGREBNE CEREMONIJE`, the `JOVIĆ ŽIVKO` target and the
`ROBA I USLUGE` editor.

`get_window_state(... include_screenshot:true)` failed for this Flutter window
with the exact capture error `SetIsBorderRequired failed: No such interface
supported (0x80004002)`. Accessibility-tree observation remained available,
so startup, login, reminder and editor-surface state were observed directly;
rendered field values, screenshots and PDF pixels were not exposed. No
focus-index guessing was used for a destructive action. PowerShell process
inspection and exact-PID stop were used; no watchdog or subagent was used.

## C. Active canonical DB safety baseline

The expected runtime path was re-proven as:

`C:\Users\Steva\Documents\opc_v4_release.sqlite`

Before the repaired-state test it was 82,829,312 bytes with SHA-256
`A09A2D1EF8B9D7B62FA1B699637273F912A4164CFFC1C58C916FE36DCD37BB39`,
`user_version=27`, journal mode `delete` and `integrity_check=ok`.

Fresh repaired-state safety backups were created under
`C:\Projekti\OPC\OPC v.1\RUNTIME\canonical_backups\windows_visual_closure_20260813_165909`.
Both independent backups had the exact canonical SHA above. No `-wal` or
`-shm` sidecars were present and free disk space was sufficient. The repaired
copy was independently verified as 82,829,312 bytes, SHA-256
`000562EC940BA608CD5064B98C0018DFF684B42733EBE091A185E135D386FD93`,
journal `delete`, integrity `ok`, Politics 34 unique rows, Novosti 17 unique
rows and zero repaired duplicate groups.

## D. CRNINA / concrete article visual proof

The installed runtime opened the real `ROBA I USLUGE` editor, and the repaired
copy contains concrete catalog-backed `Flor`/`Ešarpa` values in the database.
However, the accessibility provider did not expose editable field values and
the Windows screenshot path failed. Therefore the required rendered proof
that CRNINA rows visibly say `Flor` and `Ešarpa` (rather than `Crnina`) was not
available. No canonical row was edited to manufacture evidence.

Verdict: **NOT PROVEN**.

## E. IRiU order visual proof

The editor surface and repeated `NAZIV KOM IZNOS (RSD)` rows were exposed, but
the rendered row values and ordering could not be inspected without pixels.
Database-level `redosled` and provenance evidence remained unchanged; this is
not a visual PASS.

Verdict: **NOT PROVEN**.

## F. SCENARIO real-view proof

The target PREDMET opened in the installed runtime. The accessibility focus
cache was not reliable for safely reaching `MODULI → SCENARIO`, and no
alternate database injection exists. Before/after database checks showed no
business-row or snapshot mutation during the repaired-runtime session, but a
SCENARIO view, conditions and applied snapshot were not directly observed.

Verdict: **NOT PROVEN**; silent mutation was not detected in the observed
database comparison.

## G. LISTA PDF visual proof

The PREDMET editor loaded, but the document generator could not be driven
reliably with the available accessibility-only surface. No PDF screenshot or
rendered page was captured. Consequently citation-row visibility, concrete
article names, amounts, duplicate rendering and layout fidelity remain
unproven in the real installed runtime.

Verdict: **NOT PROVEN**.

## H. ČITULJE recurrence lifecycle proof

The prior installed-runtime cold/reopen cycle remained stable at Politics
2,924 rows / 34 unique tuples, Novosti 1,459 rows / 17 unique tuples and 51
duplicate groups, with no growth. The repaired copy was independently reduced
to 34 / 17 and zero repaired duplicate groups. The repaired-runtime startup,
login and target PREDMET open did not produce a new citation recurrence before
the process was closed.

## I. Repaired-copy swap safety procedure

All authorized preconditions passed: OPC was closed; no `OPC.exe` process was
running; the canonical hash was recorded; two same-hash backups existed; the
repaired copy passed integrity/hash checks; exact rollback path
`C:\Users\Steva\Documents\opc_v4_release.sqlite.windows_visual_closure_20260813_165909.rollback`
was prepared; DELETE journal mode had no sidecars; and disk capacity was
adequate. The original was moved to that rollback path, the repaired copy was
placed at the exact canonical path and its placed hash was verified.

After the runtime check, the repaired path was removed and the rollback file
was moved back. The canonical path now again has SHA-256
`A09A2D1EF8B9D7B62FA1B699637273F912A4164CFFC1C58C916FE36DCD37BB39`,
integrity `ok`, journal `delete`; the temporary swap did not remain active.

## J. Repaired-state real runtime

The installed executable cold-started against the repaired database. Real
Computer Use completed advisor selection, PIN `1234`, reminder dismissal and
opening of `JOVIĆ ŽIVKO` / `120826_1949` with status `OTVOREN`. The PREDMET
editor and `ROBA I USLUGE` surface loaded. No crash, lock dialog or startup
failure occurred. Concrete-name, order, SCENARIO, picker, JSON and LISTA
rendered gates were not observable with the available capture/control path.

Verdict: **PASS for startup/login/PREDMET load; NOT PROVEN for the complete
repaired-state gate**.

## K. OPEN PREDMET dedup runtime safety

The repaired copy preserved the target PREDMET/IRiU truth at copy level and
the installed runtime opened that target successfully. No business-row,
snapshot or provenance mutation was detected. Because catalog picker,
SCENARIO, JSON and LISTA behavior were not visually/runtime-observed, the
application-level dedup safety gate is only partial.

## L. Canonical dedup gate

Canonical dedup was **DEFERRED**. The repaired-state runtime did not prove all
required visual/document gates, so the deterministic copy repair was not
applied to the live canonical database.

## M. Canonical repair execution

Not performed by design. The original canonical DB was restored from the
verified rollback backup, and the repaired copy remains disposable forensic
evidence under `RUNTIME`.

## N. Post-repair installed-runtime proof

Not applicable: canonical repair was deferred. The temporary repaired-state
startup/PREDMET observation is recorded in section J; no post-canonical-repair
cold-start or reopen claim is made.

## O. DB before/after comparison

The canonical before/after hash is intentionally identical after rollback:
`A09A2D1EF8B9D7B62FA1B699637273F912A4164CFFC1C58C916FE36DCD37BB39`.
The repaired forensic copy is `000562EC...D386FD93` and has integrity `ok`,
34 Politics rows, 17 Novosti rows and zero duplicate groups. Target PREDMET
names, prices, quantities, amounts, snapshot and provenance were preserved in
the copy-level repair proof. No canonical mutation was retained.

## P. Source/test/build validation if changed

No application source changed. No new build or test result is substituted for
the required real-runtime evidence.

## Q. Incidental findings

The Windows Flutter accessibility tree is useful for state confirmation but
does not expose rendered edit values. Its element indices are regenerated
between observations, and the screenshot interface reports
`0x80004002`. These limitations explain the narrow NOT PROVEN verdicts.

## R. Documentation reconciliation

This report is the superseding evidence for the repaired-copy swap attempt.
The authoritative plan, current state, owner decision index, source-of-truth
map and prior Windows report are updated to state that repaired startup was
observed, canonical dedup remains deferred, and concrete visual/SCENARIO/LISTA
gates remain open.

## S. Deferred items

Deferred: rendered CRNINA `Flor`/`Ešarpa` proof, IRiU order pixels, SCENARIO
view, LISTA PDF visual/citation-row proof, and canonical dedup/post-repair
startup. Android physical acceptance remains out of scope.

## T. Git completion

The report and authoritative-document reconciliation are committed on
`task/OPC-WINDOWS-VISUAL-REPAIRED-DB-FINAL-CLOSURE`, pushed to
`https://github.com/Tale74/OPC.git`, and the remote SHA plus clean worktree are
recorded below.

## U. Final verdict

- `COMPUTER USE — AVAILABLE AND USED`
- `ACTIVE CANONICAL DB — PROVEN`
- `CONCRETE KATALOG ARTICLE VISUAL — NOT PROVEN`
- `CRNINA FLOR/EŠARPA VISUAL — NOT PROVEN`
- `IRiU ORDER VISUAL — NOT PROVEN`
- `SCENARIO REAL VIEW — NOT PROVEN`
- `SCENARIO VIEW SILENT MUTATION — NOT PROVEN`
- `LISTA PDF REAL VISUAL — NOT PROVEN`
- `LISTA PDF CITATION ROW — NOT PROVEN`
- `ČITULJE RUNTIME RECURRENCE — CLOSED`
- `REPAIRED-STATE REAL RUNTIME — NOT PROVEN`
- `OPEN PREDMET DEDUP RUNTIME SAFETY — PARTIAL`
- `CANONICAL DEDUP — DEFERRED`
- `POST-REPAIR COLD START — NOT APPLICABLE`
- `POST-REPAIR REOPEN — NOT APPLICABLE`
- `CANONICAL PREDMET BUSINESS TRUTH — PRESERVED`
- `WINDOWS CLOSURE — PARTIAL`
- `ANDROID PHYSICAL ACCEPTANCE — NOT RUN BY DESIGN`
- `REMOTE SHA — CONFIRMED`
- `WORKING TREE — CLEAN`

Overall status: `WINDOWS CLOSURE PARTIAL — SPECIFIC VISUAL/DATA GATE REMAINS`
