# OPC TASK BUSINESS LOGIC EXTRACTION - PREDMET LIFECYCLE AND SAME-PREDMET CONFLICT RULES REPORT

Task: OPC BUSINESS LOGIC EXTRACTION - PREDMET LIFECYCLE AND SAME-PREDMET CONFLICT RULES

OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: audit-only / documentation / business logic extraction
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO
Windows/Android parity affected: NO
Future OPC Web affected: NO
Terminology drift risk: NO - terminology findings only, no renames
Implementation allowed: NO
Required gate before implementation: data ownership / JSON safety / platform parity / product terminology / source-of-truth

## Baseline

| Field | Value |
| --- | --- |
| Branch | `task/OPC-BUSINESS-LOGIC-PREDMET-LIFECYCLE-CONFLICT-AUDIT` |
| Base commit | `00a1628` |
| Verified previous task | `OPC LOCKED RULES AND BACKUP/RESTORE POLICY PUBLIC SUMMARY` |
| Final commit | Recorded in final GitHub handoff after commit creation. |

## Scope Confirmation

This was an audit-only/docs-only extraction. Source and tests were read as evidence only. No source code, database/schema, migration, Web runner, backend/API, sync, storage, payment/licensing/entitlement, role, UI, PDF, JSON behavior, or architecture implementation was changed.

## Files Inspected

Public docs:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`

Source/test evidence:

- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/core/database/tables/predmeti_table.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/core/format/app_format.dart`
- `test/json_transfer_regression_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/business_policy_iriu_critical_scenarios_test.dart`

## Existing Documented Rules Found

| Finding | Classification | Evidence |
| --- | --- | --- |
| `PREDMET` is the only master business truth. | DOCUMENTED POLICY | Manifest and locked rules public summary. |
| Windows and Android are equal OPC runtime forms. | DOCUMENTED POLICY | Manifest and locked rules public summary. |
| Single `PREDMET` JSON is distinct from full backup/database JSON. | DOCUMENTED POLICY / SOURCE-CONFIRMED | Public backup/restore summary; `_kPredmetTransferFormat = OPC_PREDMET`, `_kBackupTransferFormat = OPC_BACKUP`. |
| Import/restore must block PIB/Maticni broj mismatch. | DOCUMENTED POLICY / NOT IMPLEMENTED | Owner decision and backup policy summary say this is required but not confirmed implemented. |
| OPC Web must preserve local ownership and must not become server-master `PREDMET` DB. | DOCUMENTED POLICY | Manifest, owner report, source-of-truth map. |

## Source/Test Evidence Found

| Finding | Classification | Evidence |
| --- | --- | --- |
| New UI-created `PREDMET` gets generated `brojPredmeta`, default `OTVOREN`, `verzija = 1`, default business scenario/source identity, creator/savetnik metadata. | SOURCE-CONFIRMED | `PredmetiRepository.kreirajPredmet`, `Predmeti` table defaults. |
| `brojPredmeta` is a plain text column with default empty string; no unique constraint was found in `predmeti_table.dart`. | SOURCE-CONFIRMED | `TextColumn get brojPredmeta => text().withDefault(...)`. |
| UI creation immediately initializes IRIU rows and opens `PredmetScreen`. | SOURCE-CONFIRMED | `ListaPredmetaScreen._noviPredmet`, `PredmetiRepository.inicijalizujIriu`. |
| Replacement import keeps local technical `id` and applies imported business/child state. | TEST-CONFIRMED | `json_transfer_regression_test.dart` replacement import test. |
| Conflict replacement clears stale local STANJE ROBE consequences and imports incoming unresolved consequence. | TEST-CONFIRMED | `json_transfer_regression_test.dart` conflict replacement stock consequence test. |
| Full backup import validates supported STANJE ROBE backup payload and blocks unsafe stock payload cases. | SOURCE-CONFIRMED / TEST-CONFIRMED | `_procitajStanjeRobeBackupPayload`, related JSON regression tests. |

## PREDMET Lifecycle Findings

| Lifecycle area | Current behavior | Classification | Evidence |
| --- | --- | --- | --- |
| Creation | UI creates a new row with generated time-based `brojPredmeta`, `OTVOREN` default, adviser/user metadata, default business scenario, and `local_opc` source identity. | SOURCE-CONFIRMED | `kreirajPredmet`, `kreirajBrojPredmeta`, table defaults. |
| Required fields for creation | Repository creation requires `savetnikId`; core row defaults allow many business fields empty. UI close path requires at least first or last name before closing. | SOURCE-CONFIRMED | `kreirajPredmet`, `_zatvori`, `_zatvoriPredmetSaListe`. |
| Initial connected data | New UI-created PREDMET gets initial IRIU rows from catalog config. | SOURCE-CONFIRMED | `inicijalizujIriu`, `_noviPredmet`. |
| Edit/update | Segment saves call repository update paths through `PredmetiCompanion`; no full history of every field change was found. Save commit writes snapshot to `logIzmena`. | SOURCE-CONFIRMED | `azurirajPredmet`, `sacuvajPredmet`, `snapshotZaSaveCommit`. |
| Save | `SAČUVAJ` records a save snapshot and business modified metadata if data changed; no business version increment on ordinary save. | SOURCE-CONFIRMED | `sacuvajPredmet`. |
| Close | `ZATVORI` sets status `ZATVOREN`; it confirms business state and increments `verzija` only when there are business changes compared to the last confirmed-close snapshot. | SOURCE-CONFIRMED | `zatvoriPredmet`. |
| Reopen/edit | `IZMENI` / open-for-edit sets status back to `OTVOREN` and preserves baseline snapshots if missing; new version is created only after later close with business changes. | SOURCE-CONFIRMED | `otvoriPredmet`, `_otkljucajZaIzmenu`. |
| Exit/back guard | Open valid PREDMET intercepts navigation and offers stay, leave open, or close PREDMET. | SOURCE-CONFIRMED | `PopScope`, `_potvrdiIzlazakIzOtvorenogPredmeta`. |
| Auto-finish | Repository can mark past-ceremony non-final statuses as `ZAVRŠEN`. | SOURCE-CONFIRMED | `_trebaAutomatskiZavrsiti`, `osveziAutomatskeStatuse`. |
| Anonymize | Only `ZAVRŠEN` PREDMET may be anonymized; protected IDs/contact fields are redacted and status becomes `ANONIMIZOVAN`. | SOURCE-CONFIRMED | `mozeAnonimizacija`, `anonimizujPredmet`, UI guards. |
| Delete | UI asks for irreversible deletion; repository deletes log, contacts, IRIU, lifecycle decisions, reconciles STANJE ROBE, then deletes PREDMET. | SOURCE-CONFIRMED | `_obrisi`, `obrisiPredmet`. |
| Cancellation/archive | No separate cancellation or archive status was found. | NOT IMPLEMENTED | Status evidence found: `OTVOREN`, `ZATVOREN`, `ZAVRŠEN`, `ANONIMIZOVAN`. |

## Same-`brojPredmeta` Findings

| Question | Finding | Classification |
| --- | --- | --- |
| Is `brojPredmeta` required? | UI-created PREDMET receives a generated value; database column itself defaults to empty string. Import conflict logic only runs when imported trimmed `brojPredmeta` is non-empty. | SOURCE-CONFIRMED |
| Is `brojPredmeta` generated? | UI creation uses `kreirajBrojPredmeta(DateTime)` in `ddMMyy_HHmm` form. | SOURCE-CONFIRMED |
| Is it normalized? | Conflict import trims imported `brojPredmeta`; no broader normalization/canonicalization was found. | SOURCE-CONFIRMED |
| Is it unique? | No table-level unique constraint was found. | SOURCE-CONFIRMED |
| What if UI creates duplicate number? | No explicit UI duplicate check was found in `kreirajPredmet`; time-to-minute generation makes collision possible in principle if two creations occur within the same minute. | UNCLEAR / NEEDS OWNER REVIEW |
| What if imported single PREDMET has same number? | If exactly one local match exists, user chooses cancel / keep local / replace imported. | SOURCE-CONFIRMED |
| What if multiple local matches exist? | Import is stopped as unsafe and no replacement is offered. | SOURCE-CONFIRMED |

## Same/Related PREDMET Conflict Findings

| Conflict basis | Finding | Classification |
| --- | --- | --- |
| Same case detection | Single-PREDMET import conflict detection uses `brojPredmeta` equality only, after trimming imported number. | SOURCE-CONFIRMED |
| Other fields | Conflict dialog displays deceased name, version, export version, business modified metadata, scenario/source identity, creation date, and adviser id, but those fields do not drive automatic conflict detection. | SOURCE-CONFIRMED |
| Connected parties/dates/payer fields | No evidence found that parties, ceremony dates, `Platilac`/`narucilac`, or contact data influence same/related PREDMET conflict detection. | SOURCE-CONFIRMED |
| Related PREDMET concept | No separate related-case detection model was found. | NOT IMPLEMENTED |
| Firm identity guard | PIB/Matični broj mismatch block is an owner decision, not confirmed in current import/restore source. | DOCUMENTED POLICY / NOT IMPLEMENTED |

## Replace / Keep / Cancel Flow Findings

| Flow | Current behavior | Classification |
| --- | --- | --- |
| Cancel | Dialog cancel/null returns without importing. | SOURCE-CONFIRMED |
| Keep local | Dialog keeps existing local PREDMET and returns without importing. | SOURCE-CONFIRMED |
| Replace imported | Repository keeps local technical `id`, deletes local related rows/logs/lifecycle decisions, reconciles STANJE ROBE replacement, replaces PREDMET row with imported business state, and inserts imported IRIU/contact rows against the local id. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| New import | If no local `brojPredmeta` match or imported number is empty, import creates a new local PREDMET row and connected data. | SOURCE-CONFIRMED |
| Multiple local duplicates | Import blocks replacement when more than one local row has the same `brojPredmeta`. | SOURCE-CONFIRMED |

## Connected Data Findings

| Connected data | Behavior | Classification |
| --- | --- | --- |
| IRIU rows | Created on new UI PREDMET; imported with single PREDMET; deleted/replaced during PREDMET delete/replacement. | SOURCE-CONFIRMED |
| Kontakt lica | Imported with single PREDMET; deleted/replaced during PREDMET delete/replacement. | SOURCE-CONFIRMED |
| Log izmena | Save/close/reopen writes snapshots/logs; delete/replacement removes local logs for that PREDMET. | SOURCE-CONFIRMED |
| IRIU lifecycle decisions | Deleted during PREDMET delete/replacement. | SOURCE-CONFIRMED |
| STANJE ROBE effects/consequences | Delete/replacement calls lifecycle reconciliation; test confirms stale local consequence clears and incoming consequence attaches. | SOURCE-CONFIRMED / TEST-CONFIRMED |
| Full backup sections | Full backup includes predmeti, IRIU, kontakt lica, users, firmaPodaci, katalog, settings, templates, logs, STANJE ROBE sections, and lifecycle decisions. | SOURCE-CONFIRMED |
| Orphan risk | Repository delete/replacement explicitly clears known connected rows, but no database-level foreign-key/cascade audit was completed in this task. | TECHNICAL AUDIT REQUIRED |

## Windows/Android Parity Findings

| Area | Finding | Classification |
| --- | --- | --- |
| Shared business code | PREDMET repository, JSON import/export, and core model/database code are shared Dart code used by both platforms. | SOURCE-CONFIRMED |
| Platform differences | JSON file save/read paths differ for Android vs non-Android; business format and repository operations are shared. | SOURCE-CONFIRMED |
| Conflict dialog | Dialog has Android narrow layout handling but same keep/replace/cancel choices. | SOURCE-CONFIRMED |
| Tests | JSON repository/import behavior is tested in Dart tests, not separately per Windows/Android runtime. | TEST-CONFIRMED / RUNTIME NOT CONFIRMED |
| Runtime parity | No fresh Windows/Android runtime smoke was run in this docs-only task. | NOT IMPLEMENTED |

## Import/Export/Backup/Restore Relationship Findings

| Area | Finding | Classification |
| --- | --- | --- |
| Single PREDMET export | `OPC_PREDMET` exports one PREDMET, IRIU rows, contact rows, and approved unresolved STANJE ROBE consequence transfer block when present. | SOURCE-CONFIRMED |
| Single PREDMET import | `OPC_PREDMET` or legacy `OPC_BELEZNICA` import creates new local PREDMET or enters `brojPredmeta` conflict flow. | SOURCE-CONFIRMED |
| Full backup export | `OPC_BACKUP` exports full database sections and `databaseIdentity: OPC`. | SOURCE-CONFIRMED |
| Full backup import | Full backup import requires destructive confirmation `ZAMENI SVE`, deletes existing tables, then inserts backup sections using insert/replace flows. | SOURCE-CONFIRMED |
| Identity guard | No source evidence found here for PIB/Matični broj mismatch guard before single-PREDMET or full backup import. | NOT IMPLEMENTED |
| Stock backup guard | Backup with unsupported/unsafe stock payload is blocked if local STANJE ROBE exists or payload is incomplete/invalid. | SOURCE-CONFIRMED / TEST-CONFIRMED |

## OPC Web Preservation Notes

Future OPC Web must preserve these current rules without becoming the master PREDMET database:

- `PREDMET` remains master business truth.
- Same `brojPredmeta` conflict behavior must be explicit; automatic silent merge/overwrite is not acceptable.
- Keep/replace/cancel semantics must be represented if single-PREDMET import/sync exists.
- Local technical id and business `brojPredmeta` must not be confused.
- Connected IRIU/contact/log/lifecycle/STANJE ROBE data must be reconciled consistently on replace/delete.
- Single `PREDMET` JSON semantics must remain distinct from full database/backup semantics.
- PIB/Matični broj and firm/database identity guard must be designed before Web/sync import/restore.
- Platform parity must be preserved; browser runtime cannot weaken Windows/Android business behavior.

These are preservation requirements only, not a Web architecture design.

## Open Questions And Statuses

| Question | Status | Notes |
| --- | --- | --- |
| Should UI-created duplicate `brojPredmeta` be blocked, regenerated, or owner-reviewed? | TECHNICAL AUDIT REQUIRED | No unique DB constraint or explicit creation duplicate check was found. |
| Should `brojPredmeta` be globally unique per firm/database? | OWNER DECISION REQUIRED | Current import behavior treats it as conflict key, but DB permits duplicates. |
| Should same/related PREDMET detection use deceased identity, dates, payer, or ceremony fields? | OWNER DECISION REQUIRED | Current import detection uses only `brojPredmeta`. |
| Full lifecycle state diagram accepted by owner. | OWNER DECISION REQUIRED | Source-confirmed states exist, but owner should approve formal model before Web/sync. |
| PIB/Matični broj guard implementation. | IMPLEMENTATION REQUIRED | Policy exists, implementation not confirmed. |
| `FirmaPodaci` history. | IMPLEMENTATION REQUIRED | Required by owner decision, not confirmed implemented. |
| Runtime Windows/Android confirmation for conflict and lifecycle dialogs. | FACT CHECK REQUIRED | Source is shared; runtime smoke not run. |
| Broader test coverage for save/close/reopen/exit/delete lifecycle. | TECHNICAL AUDIT REQUIRED | Tests seen focus on JSON/STANJE ROBE, not full lifecycle UI. |

## Stop-List Confirmation

No implementation was performed. The following remain blocked until separate explicit tasks and gates: source cleanup, DB constraints/migrations, JSON behavior changes, import/restore guard implementation, Web runner, backend/API, sync, storage adapter, payment/licensing/entitlement, role implementation, UI/PDF label changes, and `narucilac`/`Platilac` compatibility cleanup.

## Validation Results

| Check | Result |
| --- | --- |
| Docs-only diff | PASS - changed files are under `docs/` only. |
| Manifest gate | PASS - `python scripts\validate_opc_manifest_gate.py --base 00a162805f27dd3f860ee567ecbf204ff801ca75`. |
| Source code untouched | PASS - source/tests were read only; no `lib/`, `test/`, platform, database, migration, Web runner, backend, sync, payment/licensing/entitlement, role, UI, PDF, or JSON behavior files changed. |
| Flutter analyze/test/build | Not run; docs-only audit. |

## Changed Files

- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/tasks/OPC_TASK_BUSINESS_LOGIC_EXTRACTION_PREDMET_LIFECYCLE_AND_SAME_PREDMET_CONFLICT_RULES_REPORT.md`

## Final Status

PASS WITH OWNER REVIEW QUEUE

OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES
Core purpose preserved: YES
PREDMET meaning preserved: YES
Database ownership preserved: YES
Windows/Android parity preserved: YES
Existing local JSON transfer preserved: YES
OPC Web not implemented: YES
OPC Web not described as SaaS: YES
No source implementation: YES
Changed files within scope: YES - documentation only
PASS / NOT PASS: PASS WITH OWNER REVIEW QUEUE
