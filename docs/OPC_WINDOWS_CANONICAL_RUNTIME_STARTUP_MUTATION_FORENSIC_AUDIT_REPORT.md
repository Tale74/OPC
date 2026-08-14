# OPC Windows canonical runtime + startup mutation forensic audit

## A. Baseline

This was a forensic-only audit. No production fix, IRiU ordering change, PREDMET save, historical-data rewrite, or canonical rollback was performed.

The clean starting point was `bbbea6b35b3a5728feee2a4f0cfb775eda0febef` on `audit/OPC-WINDOWS-RUNTIME-STARTUP-MUTATION-FORENSIC`; the tracked remote resolved to the same SHA. The intended final tested/built commit was `f265231e36eb11f68963d226182eaed8b788bd06`. The preceding IRiU forensic report/evidence, shared-ordering implementation report, final-build report/evidence, current repository, scenario kernel, UI consumer, row widget, database selectors, and characterization tests were inspected.

The machine-readable authority for this report is [OPC_WINDOWS_CANONICAL_RUNTIME_STARTUP_MUTATION_EVIDENCE.json](artifacts/OPC_WINDOWS_CANONICAL_RUNTIME_STARTUP_MUTATION_EVIDENCE.json).

Evidence identity clarification: the lifecycle verdicts below use only the nine files in `RUNTIME\OPC_WINDOWS_STARTUP_MUTATION_20260814` captured during this audit (16:49–17:09 local time). The separate root-level `RUNTIME\IRIU1.PNG` and `RUNTIME\IRIU2.PNG` were created later at 17:43:39 and 17:44:03, respectively, and were not viewed or used by the original Computer Use run. They are recorded as supplemental, provenance-unattributed evidence only; `IRIU2.PNG` visibly contains a “Full-screen Snip” overlay. Their visible rows are consistent with the expected order, but they do not establish the three lifecycle verdicts in this report.

## B. Installed artifact identity

The installed and release artifacts are byte-identical:

| Artifact | Installed SHA-256 | Release SHA-256 |
|---|---|---|
| `OPC.exe` | `DCB784346DA415ED19FE6AD458E5917A1E83F5F58F2363A8400E68F1F5115A7C` | same |
| `data\app.so` | `031B3075BE289521823811B39AD4399C9429CBAA5D0F84D94C4237139CD067C5` | same |

The final evidence records `flutter build windows --release --no-pub`. Byte searches of the installed executable/runtime found none of `WINDOWS_TEST`, `LUNA_MIGRATION_TEST.sqlite`, `MIGRATION_TEST_DB_PATH`, or `OPC_MIGRATION_TEST_DB`. Source defaults to the production `opc_v4_release` database; migration-test selection is compile-time guarded by `kIsWindowsTestBuild`.

**INSTALLED WINDOWS ARTIFACT — EXACT FINAL BUILD**

## C. Owner-authorized login lifecycle

`OWNER-AUTHORIZED OPC LOGIN USED` for the initial and post-cold-restart sessions. Authentication was performed manually by the owner; no credential was entered by automation or persisted in a tracked file, log, filename, or screenshot.

Computer Use targeted exactly one installed OPC window. Its standard bounded screenshot path failed consistently with `SetIsBorderRequired failed: No such interface supported (0x80004002)`. Navigation continued through Computer Use accessibility/input, while visible-pixel evidence was captured with local full-screen PNGs. No authentication screen is part of the nine IRiU evidence screenshots.

**OWNER-AUTHORIZED LOGIN — COMPLETED**

## D. First-open IRiU order

After the first login, PREDMET `113`, `JOVIĆ ŽIVKO / 120826_1949`, was opened without editing or saving. `Roba i usluge` visibly showed:

1. Agencijske usluge
2. ČITULJA POLITIKA I/90 mm — Cela zemlja
3. Crnina
4. Ešarpa
5. Cveće SUZA SU 1/1
6. SVETOSAVSKI KRST Topola/Hrast
7. Peškir za krst
8. Pokrov garnitura BORDO
9. Posmrtne parte
10. Sanduk V-4
11. Slika
12. Transportna vreća
13. Iznošenje
14. Prevoz do hladnjače
15. Hladnjača
16. Spremanje pokojnika
17. Prevoz do groblja
18. Komplet 80

Top, middle, and bottom screenshots collectively expose every row and are hash-addressed in the evidence JSON.

**REAL WINDOWS IRiU ORDER FIRST OPEN — PASS**

## E. Reopen IRiU order

The PREDMET was exited without business close or save, reopened in the same OPC process, and `Roba i usluge` was opened again. The second complete top/middle/bottom capture has the same 18-row sequence.

**REAL WINDOWS IRiU ORDER REOPEN — PASS**

## F. Cold-restart IRiU order

OPC was fully closed and its window/process disappearance was confirmed. The installed executable was launched again, the owner completed a second manual login, and the same PREDMET/section was reopened. The third complete capture again has the same 18-row sequence. OPC was then exited without saving and full process exit was confirmed.

**REAL WINDOWS IRiU ORDER COLD RESTART — PASS**

All three visible sequences are identical.

## G. Repository/provider/widget/pixel comparison

On an isolated canonical-shaped copy, `IriuRepository(db).getIriu(113)` returned IDs:

`1724, 1721, 1732, 1733, 1720, 1715, 1717, 1716, 1718, 1714, 1723, 1731, 1727, 1729, 1726, 1730, 1728, 1725`

Those IDs map exactly to the 18 names above. The production stream is not an alternative ordering implementation: `watchIriu` reads raw rows and applies the same `_orderedProjection` as `getIriu`; `_orderedProjection` creates the ordering context and calls `IriuOrderingService.orderedRows`.

`IriuSegment` consumes the stream at `iriu_segment.dart:554-557`, assigns `snap.data` directly to `stavke`, and maps `stavke` directly to `IriuRowTile` at lines 613-623. There is no provider-to-widget reorder. The three visible Windows sequences equal the repository sequence.

- **REPOSITORY OUTPUT — CORRECT**
- **PROVIDER OUTPUT — CORRECT**
- **WIDGET INPUT ORDER — CORRECT**
- **PIXEL/VISIBLE ORDER — CORRECT**
- **FIRST IRiU RUNTIME DIVERGENCE — NOT IDENTIFIED**

## H. UI state/cache/key analysis

No stale index-key path was found. Every ordinary row uses `ValueKey('${s.id}:${s.interniNaziv}:${s.redosled}')`; the optional initial-focus row uses one unique `GlobalKey`. `IriuRowTile.didUpdateWidget` refreshes its display-name controller when row identity or resolved display name changes. No post-service sort, row-index identity collision, or memoized pre-service order exists in this path.

The in-session reopen and process-cold-restart pixel results independently reject a retained-child/cache explanation for the current final artifact.

## I. IRiU discrepancy root cause

The two historical `RUNTIME\IRIU1.PNG` / `IRIU2.PNG` images were created at `06:37:14` and `06:37:45` local time. Their SHA-256 values are recorded in the JSON. The exact final installed/release `app.so` was built at `13:52:18`, more than seven hours later. The historical “wrong” images therefore cannot be evidence of the final installed runtime that was audited here.

The apparent contradiction was a temporal evidence mismatch: pre-final-build screenshots were compared with post-final-build source/repository results. The current exact final build shows no repository → stream → widget → pixel divergence across three lifecycle points.

**IRiU ROOT CAUSE — PROVEN**

No Luna IRiU implementation handoff is needed because there is no current IRiU defect to patch.

## J. Canonical before/after hashes

Canonical path: `C:\Users\Steva\Documents\opc_v4_release.sqlite`.

The control boundary is decisive. A cold process launch through the login screen followed by exit left both the closed physical SHA and the logical scenario-row hash unchanged:

- physical: `0C3515CA4FA69041E8E52AF2AEC29035D84A3640E2C4C4C09746081D0A4526DF`
- logical row hash: `A646A2607BB5F7C4D26665A96A469241EA118E06B141CA29ACEF763EB75611F9`

Therefore bare process startup/login-screen display does not perform the write.

Forensic copies/dumps were kept outside Git. Their hashes are in the JSON. The SQLite online-backup hash differs from a closed physical-file hash because online backup normalizes the database/WAL representation; logical row comparison, not cross-method physical hash equality, is authoritative.

## K. `scenario_definitions` logical diff

The before dump contained 1,021 rows. After first open plus reopen:

- row count remained 1,021;
- exactly 36 rows differed;
- every ID began `MAP_NASILNA_BOLNICA_`;
- the only differing column was `updated_at`;
- all 36 timestamps moved from `2026-08-14T13:18:43.394232Z` to `2026-08-14T14:54:43.200455Z`.

After the full cold restart and third IRiU open, the same 36 rows changed again, only in `updated_at`, from `2026-08-14T14:54:43.200455Z` to `2026-08-14T15:07:50.852142Z`.

No ID, module, version, status, name, condition JSON, consequence JSON, default flag, or creation timestamp changed.

- **STARTUP scenario_definitions WRITE — REPRODUCED**
- **scenario_definitions BUSINESS PAYLOAD CHANGE — NONE**
- **scenario_definitions updated_at CHANGE — 36**

## L. Startup caller/write trace

The task called this a startup write, but the proven boundary is narrower: it occurs when `Roba i usluge` initializes after login, not merely when `OPC.exe` starts.

```text
PredmetScreen selects RobaIUsluge
  → IriuSegment.initState (iriu_segment.dart:259-264)
  → unawaited(_runScenarioSync(widget.predmetData))
  → _runScenarioSync (iriu_segment.dart:299-300)
  → ScenarioModuleRepository.ensureModuleAndDefaults()
  → _ensureOwnerMapDefinitions() (scenario_module_repository.dart:150,185,195-198)
  → _repairKnownOwnerMapProtectiveEquipmentGap() (241-317)
  → Drift UPDATE scenario_definitions
       SET consequences_json = expected JSON,
           updated_at = fresh transaction timestamp
```

`ensureModuleAndDefaults` calls the owner-map ensure path even when definitions already exist and no legacy package/default migration is required. `_ensureOwnerMapDefinitions` always calls the protective-equipment repair before it checks whether any owner keys are missing.

**STARTUP NO-OP WRITE CALLER — IDENTIFIED**

## M. No-op write root cause

The repair examines every version-1 default `MAP_NASILNA_*` row. It creates an expected consequence list with protective equipment removed, then compares the actual row using only consequence category and action.

The policy kernel intentionally omits protective equipment for hospital cases: `isHospital` is true for `BOLNICA`, and the normal protective-equipment branch is inside `if (!isHospital)` (`owner_scenario_policy_kernel.dart:218,251-268`). Removing protective equipment from the already-correct hospital expectation changes nothing. Consequently, the 36 legitimate `MAP_NASILNA_BOLNICA_*` rows all falsely match the “legacy missing protective equipment” fingerprint.

For every match, the repository unconditionally rewrites the expected consequence JSON and sets a fresh `updated_at` (`scenario_module_repository.dart:303-315`). There is no complete persisted-payload equality check and no “skip identical UPDATE” guard.

That explains both the exact count and the identical business payload.

**STARTUP MUTATION ROOT CAUSE — PROVEN**

## N. Android/shared-code blast radius

The repository, kernel, and IRiU initialization path are shared Dart code. Any Windows or Android route that opens this IRiU path and invokes `ensureModuleAndDefaults` can execute the same repair.

The `jePodrazumevani == false` filter protects explicitly non-default records. It does not fully protect edits made to a default record that retains `jePodrazumevani=true`. Because the fingerprint ignores order, section, provider, warning, reason, financially-included metadata, and condition-change behavior, edits limited to those consequence fields can be overwritten if category/action still matches. The live 36 rows did not suffer such a business change during this audit, but the code shape exposes that class of user-edit risk.

Every transaction invalidates `scenario_definitions` watchers. Full backup/export/diff material also includes `updated_at`, so timestamp-only churn changes hashes and produces false technical differences.

## O. Startup performance observation

Each IRiU opening reads all scenario definitions more than once, generates the finite owner key space, filters/parses/compares 252 `MAP_NASILNA_*` rows, and issues 36 UPDATE statements in one transaction despite identical persisted JSON. This is unnecessary database I/O, JSON work, watcher invalidation, and backup churn on a user-visible opening path.

## P. Characterization tests

Added `test/scenario_startup_noop_timestamp_mutation_characterization_test.dart` with two characterization cases:

1. a memory/current-default case freezes timestamps, invokes `ensureModuleAndDefaults`, and proves exactly 36 `MAP_NASILNA_BOLNICA_*` timestamps change while every business field remains identical;
2. an environment-gated isolated canonical-shaped-copy case proves the same 36 timestamp-only writes against real data shape.

The existing production-shaped PREDMET 113 repository test and the new characterization ran together, serially:

```text
flutter test --no-pub --concurrency=1 --reporter=expanded \
  test/iriu_production_test_ordering_discrepancy_characterization_test.dart \
  test/scenario_startup_noop_timestamp_mutation_characterization_test.dart
```

Result: **PASS**, 3 tests, 110.1 s wall time. The new test also passed targeted `flutter analyze --no-pub` with no issues. No timeout was treated as PASS.

## Q. Safe repair layers

No repair was implemented. A safe implementation should remain narrow:

1. compare the complete intended persisted business payload before issuing the repair UPDATE;
2. skip the UPDATE entirely when `consequences_json` is semantically/persistently identical, preserving `updated_at`;
3. retain the existing protection for genuine user-owned definitions and strengthen protection for edits that remain marked default;
4. test both legitimate migration and no-op hospital paths on shared Windows/Android code;
5. keep canonical cleanup/rollback outside the code change unless separately authorized.

IRiU display ordering needs no repair in the audited final artifact.

## R. Luna implementation handoff(s)

**LUNA IRiU HANDOFF — NOT NEEDED**

**LUNA STARTUP-MUTATION HANDOFF — READY**

Narrow handoff:

- primary function: `ScenarioModuleRepository._repairKnownOwnerMapProtectiveEquipmentGap`;
- callers: `_ensureOwnerMapDefinitions` and `IriuSegment._runScenarioSync`;
- policy reason for 36: hospital branch in `OwnerScenarioPolicyKernel.definitionForKey`;
- required behavior: no UPDATE and no `updated_at` change when the complete persisted business payload is identical;
- preserve legitimate user-edit timestamps and protect metadata-only edits;
- retain the new characterization test, then add positive migration and shared-platform coverage;
- do not rewrite PREDMET history or clean the canonical database without separate authorization.

## S. Canonical business-data safety

- **CANONICAL BUSINESS DATA MUTATED — NO**
- **CANONICAL TECHNICAL TIMESTAMP MUTATED — YES**

The audit intentionally reproduced the timestamp-only mutation needed for proof. It did not roll timestamps back because the task explicitly prohibited automatic canonical rollback.

## T. Git completion

The tracked audit delta is limited to this report, the evidence JSON, and the characterization test. Runtime screenshots, full database copies, and raw dumps are preserved in the external `RUNTIME\OPC_WINDOWS_STARTUP_MUTATION_20260814` directory and are not committed. Final commit/push, remote-SHA equality, and clean-worktree results are necessarily verified after this report is committed and are delivered in the Codex completion response.

## U. Final verdict

- **INSTALLED WINDOWS ARTIFACT — EXACT FINAL BUILD**
- **OWNER-AUTHORIZED LOGIN — COMPLETED**
- **REAL WINDOWS IRiU ORDER FIRST OPEN — PASS**
- **REAL WINDOWS IRiU ORDER REOPEN — PASS**
- **REAL WINDOWS IRiU ORDER COLD RESTART — PASS**
- **REPOSITORY OUTPUT — CORRECT**
- **PROVIDER OUTPUT — CORRECT**
- **WIDGET INPUT ORDER — CORRECT**
- **PIXEL/VISIBLE ORDER — CORRECT**
- **FIRST IRiU RUNTIME DIVERGENCE — NOT IDENTIFIED**
- **IRiU ROOT CAUSE — PROVEN**
- **STARTUP scenario_definitions WRITE — REPRODUCED**
- **scenario_definitions BUSINESS PAYLOAD CHANGE — NONE**
- **scenario_definitions updated_at CHANGE — 36**
- **STARTUP NO-OP WRITE CALLER — IDENTIFIED**
- **STARTUP MUTATION ROOT CAUSE — PROVEN**
- **CANONICAL BUSINESS DATA MUTATED — NO**
- **CANONICAL TECHNICAL TIMESTAMP MUTATED — YES**
- **LUNA IRiU HANDOFF — NOT NEEDED**
- **LUNA STARTUP-MUTATION HANDOFF — READY**

Overall: **AUDIT PASS — IRiU RUNTIME DISCREPANCY AND STARTUP MUTATION ROOT CAUSES PROVEN**.

Here, the IRiU verdict means the apparent historical discrepancy is conclusively resolved as pre-final-build evidence, while the current exact final artifact has no runtime divergence.
