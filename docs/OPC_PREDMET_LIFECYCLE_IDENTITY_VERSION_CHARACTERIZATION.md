# OPC PREDMET Lifecycle Identity Version Characterization

Status: docs-only characterization.

Base commit: `7c24d6399077499f78f963a737cd95560493e49d`

This document records current PREDMET lifecycle, identity, version, export metadata, import conflict, and change-log evidence. It does not authorize source, test, database, schema, migration, UI, PDF, JSON, import/export, backup/restore, evaluator, IRiU, STANJE ROBE, finance, entitlement, role, Web, sync, storage, payment, or runtime behavior changes.

## 1. Evidence Basis

Primary source evidence:

- `lib/core/database/tables/predmeti_table.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `test/json_transfer_regression_test.dart`

Supporting documentation evidence:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_CHARACTERIZATION_EVIDENCE_FOUNDATION.md`
- `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`
- `docs/OPC_CHARACTERIZATION_GAP_REGISTER.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_WEB_READINESS_GUARDRAILS.md`

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL / DOCUMENTED POLICY`.

## 2. PREDMET Table Identity And Version Fields

`Predmeti` stores a local auto-increment `id`, `brojPredmeta`, `status`, `datumKreiranja`, `savetnikId`, business `verzija`, `businessScenarioId`, `sourceIdentity`, creator/modifier metadata, and `exportVerzija`.

Current source boundary:

- `id` is a local technical database identifier.
- `brojPredmeta` is a business-facing number, but public policy says it is not globally unique.
- `verzija` is the PREDMET business-version signal.
- `exportVerzija` is single-PREDMET JSON export metadata.
- `exportDatum` exists in the exported JSON root, not as PREDMET identity authority.

Classification: `SOURCE-CONFIRMED / OWNER DECISION`.

## 3. Create

`PredmetiRepository.kreirajPredmet` inserts a new PREDMET with generated `brojPredmeta`, current `datumKreiranja`, `savetnikId`, default business scenario, `sourceIdentity = local_opc`, `createdByKorisnikId`, and default Cyrillic script. The table default keeps initial `status = OTVOREN`, `verzija = 1`, and `exportVerzija = 0` unless overridden.

`inicijalizujIriu` is called as the follow-up initializer for new PREDMET IRiU rows.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 4. Save / Working Commit

`sacuvajPredmet` compares the current business snapshot with the latest saved snapshot in `logIzmena`. If nothing changed after a prior save snapshot, it returns `bezIzmena`. Otherwise it normalizes missing `businessScenarioId` and `sourceIdentity`, writes last-business-modified metadata, and logs `__save_commit_snapshot__`.

The snapshot deliberately removes status, business version, export version, business scenario, source identity, creator, and last-business-modified metadata before comparing business content.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 5. Close / Reopen / Finish

`zatvoriPredmet` changes status to `ZATVOREN`. It increments `verzija` only when a previous confirmed-close snapshot exists and the current business snapshot differs from that confirmed snapshot. It logs version changes, confirmed-close snapshots, save snapshots, and `radni_ciklus`.

`otvoriPredmet` records missing baseline snapshots, sets status back to `OTVOREN`, and logs `radni_ciklus`. It logs a `verzija` row only if repository update behavior results in a changed version.

Automatic finish is source-confirmed by `osveziAutomatskiStatusPredmeta` and `osveziAutomatskeStatuse`: if ceremony date is before the current day and status is not `ZAVRŠEN` or `ANONIMIZOVAN`, status is set to `ZAVRŠEN`.

Classification: `SOURCE-CONFIRMED / TEST GAP / RUNTIME GAP`.

## 6. Anonymize / Delete

`anonimizujPredmet` redacts selected protected identification/contact fields, keeps names visible in OPC v1, and changes status to `ANONIMIZOVAN`.

`obrisiPredmet` deletes related stock lifecycle effects, `logIzmena`, contacts, IRiU rows, IRiU lifecycle decisions, and the PREDMET row.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 7. Pregled I Potvrda / Change-Log Visibility

Current `Pregled i potvrda` UI displays status, `Verzija predmeta`, saved/unsaved working state, and lifecycle actions. It does not display a full change-log overview.

`logIzmena` is currently used for save snapshots, confirmed-close snapshots, version changes, and working-cycle logs. Replacement import deletes local `logIzmena` for the replaced local PREDMET before inserting imported business state.

Classification: `SOURCE-CONFIRMED / IMPLEMENTATION GAP / OWNER DECISION EXISTS`.

## 8. Single-PREDMET JSON Export

Single-PREDMET JSON export increments `exportVerzija`, serializes PREDMET, IRiU, contacts, and optional STANJE ROBE consequence-transfer data, writes `exportDatum`, and generates a human-readable filename from name, `brojPredmeta`, and `v${verzija}`.

Current boundary:

- filename is not canonical identity;
- `exportDatum` is not freshness authority;
- `exportVerzija` is export metadata;
- business `verzija` is separate from export timestamp and filename authority.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL / OWNER DECISION`.

## 9. Single-PREDMET JSON Import / Conflict

Current import reads current or legacy single-PREDMET JSON. If imported `brojPredmeta` is non-empty, local rows are searched by `brojPredmeta` alone. If more than one local row matches, import is stopped as unsafe. If one local row matches, the UI offers `Odustani`, `Zadrži lokalni`, or `Zameni uvoznim`.

Current replacement behavior preserves the local technical PREDMET `id`, replaces imported business state into that id, deletes local related log/contact/IRiU/lifecycle rows, reinserts imported related rows under the local id, and reconciles STANJE ROBE replacement effects.

Existing JSON regression tests confirm:

- single-PREDMET import does not reuse the imported technical `id` for new local imports;
- replacement import keeps the local PREDMET `id`;
- imported business fields and `sourceIdentity` can replace local business state;
- current JSON transfer preserves locked identity metadata slices.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL / OWNER DECISION`.

## 10. Identity Boundary For Future Web/Sync

The current runtime conflict key is `brojPredmeta` only. Public policy states future-safe PREDMET identity is firm-scoped and must not rely on local DB `id`, filename, export date, or global `brojPredmeta` alone.

This characterization records current behavior only. It does not choose Web architecture, sync strategy, server authority, storage, payment, licensing, entitlement, role, or API behavior.

Classification: `DOCUMENTED POLICY / TECHNICAL AUDIT REQUIRED / IMPLEMENTATION BLOCKED`.

## 11. Control Summary

PREDMET lifecycle and JSON identity/version behavior are source-confirmed with partial JSON test protection. Full lifecycle, version increment, change-log visibility, runtime parity, firm-scoped identity, and Web/sync identity behavior remain characterization or audit gaps. No implementation or behavior change is authorized by this document.

Classification: `PASS WITH OWNER REVIEW QUEUE`.
