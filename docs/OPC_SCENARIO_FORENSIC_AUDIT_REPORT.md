# OPC SCENARIO — FORENSIC AUDIT REPORT

**Audit type:** read-only forensic audit before any future SCENARIO logic-map reimplementation  
**Audit branch:** `task/OPC-SCENARIO-FORENSIC-AUDIT`  
**Verified base branch:** `task/OPC-SCENARIO-UI-RUNTIME-MIGRATION`  
**Verified base SHA:** `731a1433f5a215db6a65ce5774332ca71831fc81`  
**Source timestamp recorded:** `C:\Projekti\OPC\OPC v.1\SOURCE`, `5.8.2026. 14:10:45`  
**Audit date:** `5.8.2026`  

## 1. Executive verdict

The audit is complete for all safe source, test, owner-map and available-runtime streams. The canonical user/business database was not found at the owner-defined path and was not opened. Consequently, the named PREDMET `030826_2029`, the current canonical scenario policy, and database-vs-default consistency cannot be claimed as proven.

The current implementation has a working editable scenario repository and a working automatic `PREDMET → SCENARIO → IRiU` trigger, but it is not a single authoritative business-policy path. `ScenarioRuleEngine` evaluates editable definitions while `IriuTruthRules` still contains an independent hardcoded operational/recommendation/BIOHAZARD lane. The current implementation also allows arbitrary new scenario creation and allows visible `KORISNIK_*` KATALOG categories to be used as scenario consequences without a branch-authorization model. Existing condition changes can leave stale managed IRiU rows; this is explicitly captured by a passing characterization test and is therefore a proven defect, not an inference.

The owner-locked BIOHAZARD presentation for `Spremanje preminulog lica` is proven and must not be changed. The separate urn-cemetery restore commit is schema/data/PDF scoped; no SCENARIO, BIOHAZARD or KATALOG code appears in that commit's diff.

**Overall status:**

`AUDIT COMPLETE — IMPLEMENTATION BLOCKED BY IDENTIFIED OWNER/ARCHITECTURE DECISIONS`

No implementation task is authorized by this report. The next task must wait for owner review of the canonical-database evidence gap and the single-truth architecture decision.

## 2. Evidence, safety and baseline

### 2.1 Repository identity

- Public remote: `https://github.com/Tale74/OPC.git`.
- `git fetch origin task/OPC-SCENARIO-UI-RUNTIME-MIGRATION` completed successfully.
- Local active base and public remote both resolved to `731a1433f5a215db6a65ce5774332ca71831fc81`.
- The working tree was clean before the audit branch was created.
- Local source and the public base are therefore identity-matched by branch/SHA for this audit. No source or test file was changed during the audit.

### 2.2 Owner logical map

The owner map exists at:

`C:\Projekti\OPC\OPC v.1\SCENARIO_MAP\Vlasnicka_definicija_logicke_SCENARIO_mape_KONACNA.md`

Recorded metadata: length `583575` bytes, last write `5.8.2026. 15:58:30`, SHA-256 `663F104F01C8ABFABAF5DEDF8C82185AF03FDEF31B403DFB7D4E2EFBF0E061E4`.

The map contains the owner-defined OSNOVNI PAKET, place-of-death branches, ceremony/cemetery combinations, BIOHAZARD comments, international burial, reception of remains and the nested `PROMENA SANDUKA` rule. It is comparison authority only; it was not treated as current implementation or as authorization to modify code.

### 2.3 Canonical database safety

The policy names `<owner user Documents>\opc_v4_release.sqlite` as the only canonical database. No file with that exact name was found in the owner Documents location or under the searched OPC workspace. `SOURCE\runtime_data\opc_v4.sqlite` exists (`78,733,312` bytes, `8.4.2026. 13:22:32`) but is explicitly non-canonical runtime/test data and was not opened as evidence for the owner's PREDMET.

No runtime, migration, write-capable inspection, SQL update, repair, reseed, copy or canonical-database mutation was performed. The affected database streams were stopped at `NOT PROVEN`, as required by the task.

### 2.4 Runtime evidence inventory

Available files in `C:\Projekti\OPC\OPC v.1\RUNTIME`:

| Artifact | Recorded metadata | What it proves | Limitation |
|---|---:|---|---|
| `KATALOG.PNG` | 46,040 bytes; `4.8.2026. 17:49:37` | Windows KATALOG visual snapshot with category labels and edit/delete controls | No commit/database linkage; chronology not proven |
| `Bolnica.PNG` | 71,568 bytes; `4.8.2026. 18:01:54` | Windows SCENARIO BOLNICA editor snapshot | No commit/database linkage; screenshot is not current-SHA proof |
| `Capture.PNG` | 69,382 bytes; `5.8.2026. 10:08:52` | PREDMET/IRiU snapshot visibly showing `Spremanje preminulog lica`, `ZARAZNA BOLEST` and the warning text | No PREDMET identity or database linkage; cannot prove `030826_2029` |

Filenames and filesystem times were not used to infer before/after chronology.

### 2.5 Restore-commit scope

- `9b7608d0496e3820fe05fb4ac549094c3afea356`: KATALOG display-name resolution, `KORISNIK_1775943907013 → Slika`, removal of generic `Dodatna stavka`; BIOHAZARD and PDF paths are outside the change.
- `f50b6eba67cff18f2245fcc0c88ebe278ae3330d`: CEREMONIJA Segment 5 values and urn-placement choices.
- `731a1433f5a215db6a65ce5774332ca71831fc81`: separate `grobljePolaganjaUrne` schema/import/export/LISTA-PDF work. The diff contains no SCENARIO, BIOHAZARD or KATALOG business implementation file; its indirect scope is database schema, ceremony presentation, PDF data and tests.

## 3. Automatic application architecture

**Proof class:** `MULTI-SOURCE-PROVEN` for the trigger and evaluator; `SOURCE-PROVEN` for the competing truth lane and persistence limits.

Current path:

`PREDMET field change or segment initialization → IriuSegment._runScenarioSync → ScenarioModuleRepository.ensureModuleAndDefaults/getActiveDefinitions → ScenarioRuleEngine.evaluate → IriuRepository.syncScenarioRows → IRIU rows + IriuProvenance → PredmetIriuTruthService/IriuTruthRules → visible IRiU/PDF/business flags`.

Evidence:

- `lib/features/predmeti/presentation/segments/iriu_segment.dart`: `initState`, `didUpdateWidget` and `_runScenarioSync` (approximately lines 253–327). Initialization and relevant condition changes automatically run the sync; the user does not press an “apply scenario” button.
- `lib/features/predmeti/core_v2/scenario/scenario_rule_engine.dart`: all matching active definitions are cumulative. Consequences are merged by category; suppressed wins, then required, then recommended; order/section/warning/reason are merged. The result is the nine-category base package plus scenario categories minus suppressions.
- `lib/features/predmeti/data/iriu_repository.dart`: `syncScenarioRows` (approximately lines 47–218) inserts scenario rows, writes `IriuProvenance` with `OSNOVNI_PAKET` or `SCENARIO_PAKET`, updates business fields, marks no-longer-desired rows `cekaOdlukuKorisnika`, and invokes the user decision dialog from `IriuSegment`.
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`: independent hardcoded sets and predicates still determine death-place operational activity, Blok 2 activity/recommendation, financial activity and BIOHAZARD. This lane is not read from the editable `ScenarioDefinition` records.
- `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart`: stored-row truth is re-derived from `IriuTruthRules` and row flags. This means the editable evaluator and the truth service can disagree about the same category.

Consequences of the current architecture:

1. Matching is cumulative rather than first-match. A place branch and an additional-condition branch can both contribute consequences.
2. The current evaluator deduplicates categories within its result, but manually created rows and legacy rows are outside the scenario-owned collection and are not automatically removed.
3. A condition change is not a simple delete. The UI asks the user to retain or remove a stale row; the retained row is detached from scenario provenance. The characterization test named `condition change currently leaves stale managed rows for Phase 4 cleanup design` proves that stale managed rows can remain before the decision flow completes.
4. Re-opening/rebuilding the IRiU segment invokes the current active definitions again. The active path does not write a `PredmetScenarioSnapshots` record, so historical policy-at-application is not proven to be preserved.
5. `ScenarioDefinitions` stores id, version, status, name, condition and consequences, but no description column. The `description` argument passed by the editor is therefore not persisted in the shown table/insert path.

## 4. Predefined scenario editing

**Proof class:** `TEST-PROVEN` for repository persistence and branch identity; `PARTIAL` for full user-facing cross-platform editing because no owner-approved runtime write test was performed.

| Branch | Current evidence | Result |
|---|---|---|
| `STAN` | Isolated repository test edits its consequences, reinitializes defaults and verifies the edit remains | `PASS` for isolated persistence; UI/runtime end-to-end `NOT PROVEN` |
| `DOM_ZA_STARE` | Same test verifies DOM remains unchanged after STAN edit | `PASS` for tested independence; UI/runtime end-to-end `NOT PROVEN` |
| `PRIVATNA_BOLNICA` | Separate seeded definition and independent criterion; state-reset test matches its own id | `PASS` for tested identity; UI/runtime end-to-end `NOT PROVEN` |
| `DRUGO` | Separate seeded definition and independent criterion; state-reset test matches its own id | `PASS` for tested identity; UI/runtime end-to-end `NOT PROVEN` |
| `ULICA_JAVNO_MESTO` | Separate seeded definition and independent criterion; state-reset test verifies it does not match DOM | `PASS` for tested identity; UI/runtime end-to-end `NOT PROVEN` |
| `BOLNICA` | Isolated runtime test proves `BOLNICA` provenance and `PREVOZ_DO_GROBLJA`; screen test opens the BOLNICA editor | `PASS` for tested identity/opening; full edit/runtime lifecycle `NOT PROVEN` |

Operation-level result:

- open existing definition: `PASS` in widget test for BOLNICA and repository tests;
- view understandable category names: `PASS` where KATALOG rows are present;
- save/reopen persistence: `PASS` in isolated repository tests;
- add/remove consequence through the UI: `NOT PROVEN` end-to-end;
- status change: `NOT SUPPORTED` as a user-facing editor operation; the controller saves definitions as `PRIMENJEN`, but the dialog does not expose a status-choice control;
- cancel without save: dialog path exists, but no end-to-end persistence assertion was run;
- effect on already-open/existing PREDMET: `PARTIAL`; automatic re-sync is source-proven, but historical snapshot semantics are not proven;
- six-branch cross-platform parity: `NOT PROVEN` for Android.

Required final line:

`PREDEFINED SCENARIO EDITING — PARTIAL`

## 5. Branch independence

The repository migration test is named `legacy seven definitions migrate to thirteen independently editable scenarios`. It verifies removal of legacy ids `MESTO_SMRTI_BLOK`, `MESTO_SMRTI_BOLNICA` and `OPREMA_PREMA_USLOVU`, seven-to-thirteen migration, nine base items, separate `LIMENI_ULOZAK` and `LEMOVANJE`, and persistence of a STAN-only edit while DOM/PRIVATE/DRUGO retain their own definitions. The state-reset test additionally matches independent ids for DOM, PRIVATE, DRUGO, STAN and ULICA and verifies BOLNICA provenance.

This proves branch identity and the critical STAN→DOM/PRIVATE/DRUGO/ULICA non-mutation invariant in isolated test databases. It does not prove the owner-map hierarchy or current canonical database state.

Required final line:

`PREDEFINED BRANCH INDEPENDENCE — PASS`

## 6. KATALOG item identity and visibility

**Proof class:** `MULTI-SOURCE-PROVEN` for the resolver contract and isolated tests; `NOT PROVEN` for the named item in the canonical database.

`lib/features/predmeti/core_v2/services/iriu_display_name_resolver.dart` resolves in this order: current KATALOG category name, built-in name, non-technical stored row name, then an explicit KATALOG-integrity error. It never fabricates `Dodatna stavka` for an unresolved technical identity.

The focused tests prove:

- `KORISNIK_1775943907013` resolves to `Slika` when the KATALOG map contains that identity;
- the repository inserts the current KATALOG name into an isolated scenario-generated row;
- the widget renders `Slika` and not `Dodatna stavka`;
- unresolved `KORISNIK_*` is an integrity error, not a business item;
- BIOHAZARD display is unchanged.

The current editor lists visible KATALOG categories by stable internal identity and allows them to be selected as scenario consequences. `saveDefinition` validates that the category exists in KATALOG, but it does not prove that the category is authorized for the selected branch or that a user-created category may safely become an automatic consequence. A deleted/unavailable KATALOG identity causes scenario sync to throw a resolvability `StateError`; no user-facing recovery flow is proven.

For `KORISNIK_1775943907013` specifically, the source repository contains only tests and resolver references, not the owner's canonical KATALOG record. Its actual introduction (direct IRiU action, scenario edit, migration, seed or synchronization) and timestamp cannot be proven without the canonical database or an owner-approved forensic copy. No inventory of canonical `KORISNIK_*` consequences is therefore possible.

Required final line:

`ADDED KATALOG ITEM VISIBILITY AND IDENTITY — PARTIAL`

## 7. Completely new scenario creation

**Proof class:** `SOURCE-PROVEN` for capability exposure; safety proof is absent.

The SCENARIO screen exposes `DODAJ NOVI SCENARIO`. The dialog allows a user to enter a name, derive or enter an id, build nested condition nodes (`NADUSLOV`, `USLOV`, `PODUSLOV`), choose visible KATALOG consequences, edit required/recommended status, reason and warning, and save. The controller immediately writes the result with `status: 'PRIMENJEN'`.

The editor/repository do not provide the safety proof required for a PASS:

- no owner-role/access-control evidence;
- no authorization matrix for which KATALOG categories may be automatic consequences;
- no robust duplicate-condition/overlap policy across definitions;
- no proven precedence/conflict model for arbitrary new definitions against all owner-map branches;
- no proven cross-platform runtime lifecycle;
- no proven historical snapshot behavior;
- `description` is not persisted in the shown schema path;
- a new definition automatically participates in `PREDMET → IRiU` once active.

Required final line:

`NEW SCENARIO CREATION — NOT READY / SHOULD BE DISABLED`

## 8. Automatic PREDMET → SCENARIO → IRiU result

Automatic trigger and insertion are proven, but single-truth correctness is not. The current flow can re-evaluate on PREDMET changes, add scenario consequences, update status/provider/order/warning/reason, and record scenario provenance. It also preserves manual rows and presents a user decision when a previously desired scenario row is no longer desired.

The result is only partial because the second hardcoded truth lane can reclassify rows independently, condition changes can leave stale managed rows, and arbitrary active definitions can inject consequences. This is sufficient to affect the PREDMET business whole through IRiU even when the PREDMET form fields themselves are unchanged.

Required final line:

`AUTOMATIC PREDMET → SCENARIO → IRiU APPLICATION — PARTIAL`

## 9. PREDMET `030826_2029`

The requested conditions and redacted IRiU provenance table cannot be verified. The canonical database was not located, and the available screenshots have neither a PREDMET identifier nor a database/commit linkage. `Capture.PNG` visually shows `Spremanje preminulog lica`, a `ZARAZNA BOLEST` badge, the correct warning text, and `Dodatna stavka`, but it cannot establish which PREDMET produced those rows or whether they were automatic, user-added, migrated, legacy or stale.

No row was read, changed, repaired, re-evaluated or deleted. Blast radius across other PREDMET records is also not proven.

Required final line:

`PREDMET 030826_2029 — NOT PROVEN`

## 10. Defaults, database policy and migrations

### 10.1 Current bundled defaults

`assets/scenario_defaults.json` contains **13** definitions and the repository's default OSNOVNI PAKET contains **9** categories. The definitions are:

`STAN`, `DOM_ZA_STARE`, `PRIVATNA_BOLNICA`, `DRUGO`, `ULICA_JAVNO_MESTO`, `BOLNICA`, `LIMENI_ULOZAK`, `LEMOVANJE`, `LOKALNO_GROBLJE`, `OPELO`, `BIOHAZARD`, `SAHRANA_VAN_SRBIJE`, `DOCEK_POSMRTNIH_OSTATAKA`.

The empty-test-database test verifies these 13 definitions, nine basic categories, `CITULJA_POLITIKA` as a category with multiple catalog articles, and the `BIOHAZARD` seed name `ZARAZNA SMRT VAN BOLNICE`.

### 10.2 Migration and reset behavior

`ScenarioModuleRepository.ensureModuleAndDefaults` seeds an empty module, adds the nine-item base package only when the stored base is empty, splits the legacy seven definitions into 13, expands the collapsed DOM alias into independent DOM/PRIVATE/DRUGO criteria, splits the old equipment rule into separate LIMENI/LEMOVANJE definitions and deletes the legacy ids. If non-legacy definitions already exist, the early-return path preserves them. This is source- and test-proven for isolated databases, not for the canonical database.

### 10.3 Consistency verdict

The runtime consumes active definitions read from the database after `ensureModuleAndDefaults`; it does not evaluate the JSON asset directly on every PREDMET. The canonical database policy, user edits, migration history, current versions and all stored `KORISNIK_*` consequences could not be inspected. The JSON contains no `KORISNIK_*` consequence. The current default BIOHAZARD definition and the independent `IriuTruthRules.isBiohazard` path are materially different representations of related behavior.

Required final line:

`CANONICAL DEFAULTS ↔ DATABASE POLICY CONSISTENCY — NOT PROVEN`

## 11. BIOHAZARD locked-good behavior

**Proof class:** `MULTI-SOURCE-PROVEN` for source/tests/runtime visual evidence.

- `IriuTruthRules.isBiohazard` marks `SPREMANJE_POKOJNIKA` when cause is `ZARAZNA` and normalized place is non-empty and not `BOLNICA`.
- `PredmetIriuTruthService` carries the BIOHAZARD flag and warning into the truth row.
- `iriu_row_tile.dart` renders the `ZARAZNA BOLEST` chip and renders the persisted business warning below the row.
- The PDF NALOG path renders the BIOHAZARD badge; no PDF change was made or authorized by this audit.
- The focused resolver test `BIOHAZARD display and warning remain unchanged` passes with the exact warning `Postupati prema merama zaštite za zaraznu bolest.`.
- `Capture.PNG` visibly confirms the badge and warning on `Spremanje preminulog lica`.

The owner map's broader comment-placement rule is not fully represented by the current 13 defaults; that is a policy-gap finding for a future owner-approved implementation, not permission to alter the locked display path.

Required final lines:

`BIOHAZARD DISPLAY FOR SPREMANJE PREMINULOG LICA — PASS / DO NOT CHANGE`

`PDF DERIVATIVES — NO CHANGE AUTHORIZED WITHOUT EVIDENCE`

## 12. Current UI audit

### Automatic operational flow

Source proves that the user selects or changes PREDMET conditions and the IRiU segment automatically synchronizes. The UI can show a `PROMENJENE OKOLNOSTI` decision dialog and a synchronization SnackBar. However, the stale-row characterization test proves that the lifecycle is not yet a clean authoritative reconciliation.

### Policy-maintenance flow

The current SCENARIO screen is reachable as a policy-maintenance screen, displays an OSNOVNI PAKET and a grouped scenario tree, and has a visible new-scenario action. The widget test proves the six place branches and additional-package grouping are rendered and that the BOLNICA editor displays the hierarchy captions. The `Bolnica.PNG` artifact shows a Windows editor with repeated field captions and narrow dialog geometry; it is visual evidence only and has no current-SHA linkage. Android runtime parity is not proven.

The later UI must preserve: automatic application, review/edit entry from the appropriate PREDMET/MODULI context, clear KATALOG names, no internal ids/audit literals in normal user copy, explicit consequences and reasons, and the locked BIOHAZARD rendering.

## 13. Gap matrix against owner logical map

| Owner rule area | Current classification | Evidence and business consequence |
|---|---|---|
| OSNOVNI PAKET | `CURRENTLY CORRECT — LOCK` for empty isolated DB; canonical state `NOT PROVEN` | Nine-category seed and no-overlap validation pass tests; canonical package unavailable |
| UZROK SMRTI | `CURRENTLY PARTIAL` | Editable conditions support cause, but hardcoded override rules remain in `IriuTruthRules`; owner combinations are not fully represented |
| MESTO SMRTI | `CURRENTLY PARTIAL` | Six independent place definitions are proven; owner map requires richer branching and exclusions |
| VRSTA CEREMONIJE | `CURRENTLY PARTIAL` | Field exists and ceremony choices are separately tested, but defaults do not encode the full owner matrix |
| TIP GROBLJA / GROBNO MESTO | `CURRENTLY PARTIAL` | Local-cemetery and Blok 2 rules exist; full owner combination matrix and forbidden combinations are not encoded in the 13 defaults |
| OPELO | `CURRENTLY PARTIAL` | Simple `OPELO=DA` package exists; full interaction precedence is not proven |
| SAHRANA VAN SRBIJE | `CURRENTLY PARTIAL` | A boolean package exists; replacement/exclusion rules from the owner map are not fully represented |
| DOČEK POSMRTNIH OSTATAKA | `CURRENTLY PARTIAL` | A boolean package exists; reception and sanduk-change nesting are not fully represented |
| PROMENA SANDUKA | `NOT IMPLEMENTED` | Owner map places it inside DOČEK; no corresponding scenario field/default condition was found |
| Status priority | `CURRENTLY PARTIAL` | Engine merges required/recommended/suppressed, while truth rules also classify operational/recommended state |
| BIOHAZARD comments | `CURRENTLY PARTIAL` / display locked | Existing SPREMANJE display is proven; owner-map comment scope is broader than the current default definition |
| Consequence ordering | `CURRENTLY PARTIAL` | Scenario consequences sort by order; base package order derives from a set and is not a stable policy order |
| No-duplicate behavior | `CURRENTLY PARTIAL` | Engine deduplicates matching consequences; manual/legacy/stale rows remain outside that guarantee |
| Independent branches | `CURRENTLY CORRECT — LOCK` for tested identities | Seven-to-thirteen migration and STAN independence tests pass; canonical/runtime UI proof remains separate |
| Unsupported/forbidden combinations | `NOT IMPLEMENTED` | Arbitrary new definitions can be activated without a proven owner-map conflict matrix |

## 14. KORISNIK_* consequence integrity

`KORISNIK_*` display resolution is correct for the tested resolver path, but automatic-consequence integrity is incomplete. The repository accepts any existing KATALOG category id, including a user-generated stable id, as a scenario consequence. There is no source-proven branch authorization or owner-map allow-list for those categories. An unresolved identity fails loudly as a KATALOG-integrity error during scenario sync, which is preferable to fabricating an item name, but no recovery/repair UI is proven.

Required final line:

`KORISNIK_* CONSEQUENCE INTEGRITY — PARTIAL`

## 15. Preserved-good-behavior register

The following are locked by evidence and must not be regressed in a later task:

1. `Slika` resolution for `KORISNIK_1775943907013` when the KATALOG identity exists.
2. No generic `Dodatna stavka` fallback for unresolved technical identities.
3. Unresolved `KORISNIK_*` is an integrity error, not a fabricated business category.
4. BIOHAZARD badge and warning for `Spremanje preminulog lica`.
5. Seven-to-thirteen legacy scenario split, separate place identities, and separate LIMENI/LEMOVANJE definitions in isolated migration tests.
6. Nine-item empty-database OSNOVNI PAKET seed and non-overlap validation.
7. Separate urn-placement cemetery schema/import/export/LISTA-PDF behavior from `731a1433`; no PDF derivative change is authorized by this audit.

## 16. Implementation prerequisites and owner decisions

These are prerequisites and decisions, not an implementation proposal:

- provide an owner-approved read-only forensic copy/path of `opc_v4_release.sqlite` and its hash so PREDMET `030826_2029` can be proven;
- decide which lane is the single business authority: editable SCENARIO definitions or a reconciled policy kernel, including how owner-map nesting is represented;
- define historical policy/snapshot semantics for existing PREDMET records when a policy is edited;
- define branch-level authorization for user-created KATALOG categories and deleted/unavailable identities;
- decide whether arbitrary new scenario creation is allowed at all; until safe overlap, precedence, authorization and runtime isolation are proven, it should remain disabled;
- define stale-row reconciliation and the meaning of ZADRŽI/UKLONI as persisted business decisions;
- reconcile owner-map rules for BIOHAZARD, PROMENA SANDUKA, DOČEK, SAHRANA VAN SRBIJE and forbidden combinations;
- provide Android narrow runtime evidence after the architecture is approved.

Genuine unresolved owner questions:

1. Which exact canonical database copy is authoritative for the requested PREDMET, and may it be supplied as a read-only forensic copy?
2. Should an edited predefined scenario affect already-created PREDMET records, future records only, or a versioned snapshot of each application?
3. Are user-created KATALOG categories permitted as automatic scenario consequences, and if so, how are they authorized per branch?
4. Is completely new scenario creation a supported product capability or an administrator-only future capability?
5. What is the authoritative nesting/precedence model for the owner map's place, cause, ceremony, cemetery, reception and sanduk-change rules?

## 17. Test evidence

No source changes were made for these runs. No build was required.

1. `C:\flutter\bin\flutter.bat test --concurrency=1 test/scenario_module_repository_test.dart test/scenario_editable_business_policy_test.dart test/scenario_runtime_application_test.dart test/scenario_runtime_single_truth_test.dart test/scenario_state_reset_runtime_contract_test.dart test/iriu_catalog_display_name_resolution_test.dart test/business_policy_iriu_critical_scenarios_test.dart test/scenario_default_policy_characterization_test.dart test/phase3_scenario_iriu_mutation_characterization_test.dart test/ceremonija_segment_mini_task_test.dart`
   - exit code `0`;
   - `40` tests passed;
   - no timeout, hang or missing exit code;
   - includes migration, branch independence, editable-policy, automatic sync, KATALOG identity, BIOHAZARD, stale-row characterization, defaults, Blok 2 and CEREMONIJA coverage.

2. `C:\flutter\bin\flutter.bat test --concurrency=1 test/scenario_module_screen_test.dart`
   - exit code `0`;
   - `3` widget tests passed;
   - proves grouped screen, visible new-scenario action and existing BOLNICA hierarchy editor.

These tests use isolated test databases created by the test harness. They do not prove the canonical user database or Android runtime behavior.

## 18. Required final verdicts

`PREDEFINED SCENARIO EDITING — PARTIAL`

`PREDEFINED BRANCH INDEPENDENCE — PASS`

`ADDED KATALOG ITEM VISIBILITY AND IDENTITY — PARTIAL`

`NEW SCENARIO CREATION — NOT READY / SHOULD BE DISABLED`

`AUTOMATIC PREDMET → SCENARIO → IRiU APPLICATION — PARTIAL`

`PREDMET 030826_2029 — NOT PROVEN`

`CANONICAL DEFAULTS ↔ DATABASE POLICY CONSISTENCY — NOT PROVEN`

`KORISNIK_* CONSEQUENCE INTEGRITY — PARTIAL`

`BIOHAZARD DISPLAY FOR SPREMANJE PREMINULOG LICA — PASS / DO NOT CHANGE`

`PDF DERIVATIVES — NO CHANGE AUTHORIZED WITHOUT EVIDENCE`

`OWNER LOGICAL MAP IMPLEMENTATION READINESS — BLOCKED`

`AUDIT COMPLETE — IMPLEMENTATION BLOCKED BY IDENTIFIED OWNER/ARCHITECTURE DECISIONS`

**NO SCENARIO IMPLEMENTATION PERFORMED.**

