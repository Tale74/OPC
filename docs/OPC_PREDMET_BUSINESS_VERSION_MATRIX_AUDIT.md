# OPC PREDMET business-version matrix audit

**Status:** SOURCE-CONFIRMED TECHNICAL AUDIT — COVERAGE DEFECTS IDENTIFIED — NO IMPLEMENTATION
**Datum:** 26. jul 2026.
**Base SHA:** `4bde702f30149a8a01033728b1ad40da29f287ee`
**Task branch:** `task/OPC-GATE-0-PREDMET-BUSINESS-VERSION-MATRIX-AUDIT`

## 1. Scope

Read-only audit obuhvatio je:

- `PREDMET.verzija` schema/default;
- create, edit, save, close, reopen, finish, anonymize and delete;
- SCENARIO, IRiU and contact-related business data;
- single-PREDMET JSON new import/replacement/export;
- full backup/restore;
- PDF/UI use;
- test and migration evidence.

## 2. Authority boundary

Current owner authority:

- PREDMET is the sole authoritative business truth;
- SCENARIO belongs to each PREDMET;
- IRiU and contact rows belong to one PREDMET business context;
- derivatives must not become parallel truth;
- `verzija` is a PREDMET business revision signal;
- `exportVerzija` and `exportDatum` are transfer metadata, not business freshness authority.

## 3. Source-confirmed current model

- `verzija` is a non-null integer with default `1`.
- `exportVerzija` is a separate integer with default `0`.
- ordinary edit/update writes to the database without changing `verzija`;
- explicit save creates a save checkpoint but does not change `verzija`;
- confirmed close may change `verzija`;
- reopen does not change `verzija`;
- single-PREDMET export increments only `exportVerzija`;
- import adopts the imported `verzija`;
- replacement adopts the imported `verzija`;
- full backup restores stored values.

## 4. Lifecycle matrix

| Operation | Current `verzija` behavior | Evidence classification |
| --- | --- | --- |
| Create local PREDMET | Starts at `1`. | SOURCE-CONFIRMED |
| Edit PREDMET fields | No increment. | SOURCE-CONFIRMED |
| Explicit `SAČUVAJ` | No increment; writes save snapshot. | SOURCE-CONFIRMED |
| First confirmed close | Remains at `1`; establishes first confirmed snapshot. | SOURCE-CONFIRMED |
| Reopen | No increment; records work-cycle metadata. | SOURCE-CONFIRMED |
| Later close without detected change | No increment. | SOURCE-CONFIRMED |
| Later close with detected PREDMET-row snapshot change | Increments by `1`. | SOURCE-CONFIRMED |
| IRiU-only change | Not included in comparison; no proven increment. | SOURCE-CONFIRMED COVERAGE GAP |
| Contact-only change | Not included in comparison; no proven increment. | SOURCE-CONFIRMED COVERAGE GAP |
| `businessScenarioId`-only change | Explicitly removed from snapshot; no detected increment. | SOURCE-CONFIRMED DEFECT AGAINST OWNER AUTHORITY |
| Automatic `ZAVRŠEN` | No increment and no complete version event. | SOURCE-CONFIRMED |
| Anonymization | Redacts many PREDMET fields without increment. | SOURCE-CONFIRMED |
| New individual JSON import | Uses imported `verzija`; no local increment. | SOURCE-CONFIRMED |
| Replacement JSON import | Replaces local value with imported `verzija`; no local increment. | SOURCE-CONFIRMED |
| Individual JSON export | Business `verzija` unchanged; `exportVerzija + 1`. | SOURCE-CONFIRMED / TEST-PARTIAL |
| Full backup/restore | Stored `verzija` is transferred/restored. | SOURCE-CONFIRMED |
| Delete | PREDMET and local log are removed. | SOURCE-CONFIRMED |

## 5. How close decides whether to increment

`zatvoriPredmet` compares the current `snapshotZaSaveCommit` string with the latest `__confirmed_close_snapshot__`.

- no earlier confirmed snapshot: current version remains unchanged;
- earlier snapshot exists and strings differ: `verzija + 1`;
- earlier snapshot exists and strings match: version remains unchanged.

The comparison is exact serialized JSON-string equality, not a versioned aggregate/domain comparator.

## 6. Snapshot coverage

The checkpoint starts from `PredmetiData.toJson()` but removes:

- `status`;
- `verzija`;
- `exportVerzija`;
- `businessScenarioId`;
- `sourceIdentity`;
- creator/modifier metadata.

It does not include related tables:

- `iriu`;
- `kontaktLica`;
- `iriu_lifecycle_decisions`;
- local import/replacement events;
- PARTE preparation data;
- reminder/support state.

## 7. Confirmed technical defects/gaps

### 7.1. SCENARIO exclusion

SCENARIO belongs to PREDMET under current owner authority. `businessScenarioId` is explicitly excluded from the version comparison. A future controlled SCENARIO change could therefore alter PREDMET business truth without changing `verzija`.

This is a technical coverage defect, not a new owner-policy question.

### 7.2. IRiU exclusion

IRiU rows influence selected goods/services, finance and derivatives, but are outside the compared snapshot. IRiU-only changes are invisible to current version increment logic.

The exact canonical IRiU fingerprint is technical design work, but omission from business-version evidence is a confirmed gap.

### 7.3. Contact exclusion

Contact rows belong to a PREDMET but are stored separately and excluded from the snapshot. Contact-only changes are invisible to current version increment logic.

### 7.4. Lifecycle/redaction ambiguity

Status is excluded from the snapshot. Reopen, automatic finish and anonymization do not increment version through current paths. Lifecycle events can be recorded separately, but source does not prove an owner-approved boundary between:

- business-content revision; and
- lifecycle/status event.

### 7.5. String snapshot and privacy coupling

Version comparison depends on raw JSON snapshot rows characterized in `docs/OPC_LOGIZMENA_TECHNICAL_AUDIT.md`. Version correctness is therefore coupled to duplicated sensitive data and log retention.

Checkpoint/audit separation must preserve exact version behavior while removing that coupling.

## 8. JSON and replacement semantics

- Official single-PREDMET JSON carries typed business `verzija`.
- Export does not change business `verzija`.
- New import preserves the imported business version.
- Replacement uses imported business state and imported version.
- Current conflict dialog displays versions but does not compare them.
- Keep/replace/cancel remains owner-approved.

Import/replacement event logging is separate from whether imported business `verzija` is adopted.

## 9. PDF and UI

- `Pregled i potvrda` displays `Verzija predmeta`.
- UI text explicitly states that ordinary save is working state and a new business version arises on close.
- PREDMET snapshot PDF, Nalog za opremanje and list-related PDF data use/display business `verzija`.

An incomplete version fingerprint can therefore be externally visible and may misdescribe changed business content.

## 10. Test evidence

Partial JSON tests cover identity/import/replacement/export metadata behavior.

No focused test matrix was found for:

- first close;
- repeated close without change;
- reopen then close without change;
- reopen, core-field change and close;
- IRiU-only change and close;
- contact-only change and close;
- SCENARIO-only change and close;
- anonymization/finish relationship to version;
- imported version survival across new import/replacement;
- version/log/UI parity on Windows and Android.

## 11. Codex technical recommendation

Without changing owner business meaning:

- retain `verzija` as PREDMET business-revision signal;
- retain `exportVerzija` as separate transfer metadata;
- replace raw single-row snapshot comparison with a canonical PREDMET business-aggregate fingerprint/checkpoint;
- include SCENARIO and all business-owned PREDMET data needed to reproduce business meaning;
- include canonical IRiU/contact projections while excluding technical local ids and derivative/runtime-only state;
- keep lifecycle events in local audit log;
- preserve imported business `verzija` on new/replacement import and record local import events separately;
- add migration/compatibility proof before transforming legacy snapshots;
- add the complete regression matrix before enabling comparison warnings or change-log UI;
- preserve Windows/Android result parity.

Exact aggregate fields and canonicalization are Codex technical/architecture responsibility constrained by PREDMET authority.

## 12. Remaining owner boundary

Source and current UI implement a close-confirmed revision model, but current authority does not prove that owner explicitly selected it over save-based versioning.

The next owner decision is:

> Does business `verzija` identify only a user-confirmed business state created by closing PREDMET, while ordinary save remains a working checkpoint?

Under the recommended model:

- create starts at `v1`;
- ordinary save does not increment;
- reopen alone does not increment;
- closing after an aggregate business change increments;
- closing without aggregate change does not increment;
- lifecycle/import events are logged separately;
- replacement adopts the explicitly selected imported version.

## 13. Status

`PREDMET BUSINESS VERSION MATRIX AUDIT PASS — AGGREGATE COVERAGE DEFECTS CONFIRMED — CLOSE-CONFIRMED VERSION OWNER DECISION REQUIRED`

## 14. Owner closure

Owner je prihvatio close-confirmed model iz odeljka 12:

- novi PREDMET počinje kao `v1`;
- ordinary save je radni checkpoint;
- reopen sam ne povećava verziju;
- zatvaranje posle canonical aggregate promene povećava verziju;
- zatvaranje bez aggregate promene ne povećava verziju;
- lifecycle/import događaji ostaju odvojeni;
- replacement preuzima izabranu uvoznu verziju.

Status owner pitanja:

`CLOSED — OWNER DECISION RECORDED — TECHNICAL COVERAGE DEFECTS REMAIN — IMPLEMENTATION NOT AUTHORIZED`
