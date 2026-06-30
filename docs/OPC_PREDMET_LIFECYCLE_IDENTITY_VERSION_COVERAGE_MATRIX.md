# OPC PREDMET Lifecycle Identity Version Coverage Matrix

Status: docs-only characterization coverage matrix.

Base commit: `7c24d6399077499f78f963a737cd95560493e49d`

This matrix records evidence for PREDMET lifecycle, identity, version, JSON conflict, and change-log behavior. It does not authorize implementation or test changes.

## COVERAGE-ID: OPC-PREDMET-LIV-001

Behavior: create new PREDMET.
Source files: `predmeti_repository.dart`; `predmeti_table.dart`; `lista_predmeta_screen.dart`.
Existing tests: no direct full create lifecycle test found.
Evidence: `kreirajPredmet` generates `brojPredmeta`, writes creation metadata, default business scenario, source identity, creator id, and relies on table defaults for status/version/export version.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: create must not change identity/version defaults without characterization.
Web/sync relevance: high.

## COVERAGE-ID: OPC-PREDMET-LIV-002

Behavior: save current business state.
Source files: `predmeti_repository.dart`; `predmet_screen.dart`.
Existing tests: no direct save snapshot/version test found.
Evidence: `sacuvajPredmet` compares snapshots and logs `__save_commit_snapshot__`; no-change saves return `bezIzmena`.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: save snapshot meaning must not drift into export or filename authority.
Web/sync relevance: high.

## COVERAGE-ID: OPC-PREDMET-LIV-003

Behavior: close / reopen / lifecycle status transitions.
Source files: `predmeti_repository.dart`; `predmet_screen.dart`; `lista_predmeta_screen.dart`.
Existing tests: partial UI smoke only; no full lifecycle matrix found.
Evidence: close sets `ZATVOREN`, records snapshots/logs, and conditionally increments `verzija`; reopen sets `OTVOREN` and logs cycle; automatic finish can set `ZAVRŠEN`.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP / RUNTIME GAP`.
Protected boundary: version increment and status semantics must not change without characterization.
Web/sync relevance: high.

## COVERAGE-ID: OPC-PREDMET-LIV-004

Behavior: anonymize.
Source files: `predmeti_repository.dart`; `lista_predmeta_screen.dart`; `predmet_screen.dart`.
Existing tests: no direct anonymization regression test found.
Evidence: selected protected fields are redacted and status becomes `ANONIMIZOVAN`; names remain visible.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: retention/redaction meaning must not change without owner-approved policy and characterization.
Web/sync relevance: medium.

## COVERAGE-ID: OPC-PREDMET-LIV-005

Behavior: delete.
Source files: `predmeti_repository.dart`; `lista_predmeta_screen.dart`; `predmet_screen.dart`.
Existing tests: no full delete lifecycle regression test found.
Evidence: delete removes stock lifecycle effects, logs, contacts, IRiU rows, IRiU lifecycle decisions, and the PREDMET row.
Current evidence level: `SOURCE-CONFIRMED / TEST GAP`.
Protected boundary: delete side effects must not change without characterization.
Web/sync relevance: high.

## COVERAGE-ID: OPC-PREDMET-LIV-006

Behavior: PREDMET table identity/version fields.
Source files: `predmeti_table.dart`.
Existing tests: partial JSON metadata tests.
Evidence: local `id`, `brojPredmeta`, `status`, `verzija`, `businessScenarioId`, `sourceIdentity`, modifier metadata, and `exportVerzija` are stored on PREDMET.
Current evidence level: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL / OWNER DECISION`.
Protected boundary: local `id` is technical; `brojPredmeta` is not global identity; `verzija` is business-version signal.
Web/sync relevance: critical.

## COVERAGE-ID: OPC-PREDMET-LIV-007

Behavior: single-PREDMET JSON export.
Source files: `json_export_import.dart`; `predmet_json_transfer_core.dart`.
Existing tests: `test/json_transfer_regression_test.dart`.
Evidence: export increments `exportVerzija`, emits `exportDatum`, serializes PREDMET and related data, and uses human-readable filename pieces.
Current evidence level: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL / OWNER DECISION`.
Protected boundary: filename and `exportDatum` are not identity or freshness authority.
Web/sync relevance: critical.

## COVERAGE-ID: OPC-PREDMET-LIV-008

Behavior: same-`brojPredmeta` single-PREDMET JSON import conflict.
Source files: `json_export_import.dart`; `predmeti_repository.dart`; `test/json_transfer_regression_test.dart`.
Existing tests: replacement/new-import identity tests exist.
Evidence: same `brojPredmeta` triggers keep/replace/cancel; replacement keeps local `id` and replaces imported business state.
Current evidence level: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL / OWNER DECISION`.
Protected boundary: no silent overwrite and no removal of explicit user choice without owner decision.
Web/sync relevance: critical.

## COVERAGE-ID: OPC-PREDMET-LIV-009

Behavior: version/change-log visibility in `Pregled i potvrda`.
Source files: `predmet_screen.dart`; `predmeti_repository.dart`; `log_izmena_table.dart`.
Existing tests: no direct review/change-log overview test found.
Evidence: review displays status, business version, and saved/unsaved state; full change-log overview is not implemented in current review UI.
Current evidence level: `SOURCE-CONFIRMED / IMPLEMENTATION GAP / TEST GAP`.
Protected boundary: visible review/version meaning must not be overclaimed as full change log.
Web/sync relevance: high.

## COVERAGE-ID: OPC-PREDMET-LIV-010

Behavior: future Web/sync identity risk boundary.
Source files: current local source plus policy docs.
Existing tests: no Web/sync tests.
Evidence: current local import conflict uses `brojPredmeta`; policy requires firm-scoped future-safe identity and local DB id boundary.
Current evidence level: `DOCUMENTED POLICY / TECHNICAL AUDIT REQUIRED / IMPLEMENTATION BLOCKED`.
Protected boundary: no Web/backend/API/sync/storage/payment/licensing/entitlement/role implementation is selected.
Web/sync relevance: critical.
