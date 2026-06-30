# OPC Business-Critical Pseudocode Map

Status: public Logos learning layer.

Base commit: `78f88228bb55526ae7c168c2aac0140ec3cb620c`

This document translates business-critical OPC source behavior into short pseudocode and product explanations. It is not source code, not an implementation spec, and not a behavior-change authorization.

OPC is a functional local-first product on an upgrade path. This task does not search for random bugs. It builds a Logos learning layer so future bug finding and safe upgrade planning are based on deep product understanding. `PREDMET` remains the master business truth. Modules around PREDMET are derivative, operational, document, transfer, finance, stock, advisor, or support layers. A module-specific rule, such as PARTA nickname display, is one derivative rule that reads from PREDMET and produces output; it is not the center of OPC. Classification: `OWNER CLARIFICATION`.

## PSEUDO-ID: OPC-PSEUDO-001

Business area: PREDMET create/open lifecycle
Source files: `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/lista_predmeta_screen.dart`; `lib/core/database/tables/predmeti_table.dart`
Related modules: PREDMET core, IRiU, users/advisers, review
Business purpose: create a local PREDMET container and initial business working state.
Inputs: current adviser/user id, current timestamp, default scenario, local source identity.
Decision points: user chooses new PREDMET or opens existing; creation initializes only metadata and initial rows.
Pseudocode:

```text
WHEN user creates new PREDMET:
    generate brojPredmeta from current date/time
    set status = OTVOREN
    set verzija = 1
    set businessScenarioId = default_funeral_ceremony_policy
    set sourceIdentity = local_opc
    set createdByKorisnikId = current adviser/user
    set pismo = CIRILICA
    insert PREDMET
    initialize starting IRiU rows from catalog configuration

WHEN user opens existing PREDMET:
    load PREDMET by local database id
    show workflow sections for that local case
```

Outputs: new local PREDMET id, initial IRiU rows, workflow screen.
Side effects: inserts PREDMET row and initial IRiU rows.
What this must not change: must not make `brojPredmeta` global identity; must not create Web/server master truth.
Evidence: source-confirmed creation metadata and initial IRiU initialization.
Tests: partial smoke coverage in `test/lista_predmeta_screen_smoke_test.dart`; broader lifecycle remains `TEST GAP`.
Known gaps: duplicate generated `brojPredmeta` handling and firm-scoped identity guard are not fully proven.
Bug/nedoslednost candidates: duplicate case number protection and runtime create/open parity need audit.
Safe upgrade notes: characterize creation/open behavior before identity or sync changes.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## PSEUDO-ID: OPC-PSEUDO-002

Business area: PREDMET save, confirmed close, reopen/edit, version, snapshots
Source files: `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/core/database/tables/log_izmena_table.dart`
Related modules: lifecycle/log/version, review, JSON
Business purpose: preserve working state, confirmed business state, and version/log evidence.
Inputs: current PREDMET, current user id, current business snapshot.
Decision points: whether there is a prior confirmed snapshot; whether current business snapshot differs; whether status is already closed.
Pseudocode:

```text
WHEN user saves working state:
    build save snapshot from business fields
    compare with last save snapshot
    IF no prior save snapshot:
        write first-save log
    ELSE IF snapshot changed:
        write new-save log and modified metadata
    ELSE:
        report no business changes

WHEN user confirms close:
    IF status already ZATVOREN:
        do nothing
    build current business snapshot
    read last confirmed-close snapshot
    IF prior confirmed snapshot exists AND current snapshot differs:
        increment verzija
        mark lastBusinessModifiedBy/At
        log version change
    ELSE:
        keep current verzija
    set status = ZATVOREN
    write confirmed-close snapshot log
    write save snapshot log
    write work-cycle log

WHEN user reopens for edit:
    ensure there is a confirmed snapshot baseline if missing
    set status = OTVOREN
    write save/work-cycle logs
```

Outputs: status, version, logs, saved/unsaved state.
Side effects: updates PREDMET, writes `logIzmena`.
What this must not change: `verzija` must not become export time, filename identity, or automatic overwrite authority.
Evidence: source-confirmed repository lifecycle and owner version decisions.
Tests: no full version/change-log test suite found.
Known gaps: exact increment coverage and future change-log data source need audit.
Bug/nedoslednost candidates: version visibility and change-log overview remain incomplete.
Safe upgrade notes: add characterization tests before version/import UI changes.
Classification: `SOURCE-CONFIRMED / OWNER DECISION / TEST GAP`.

## PSEUDO-ID: OPC-PSEUDO-003

Business area: Finish, anonymize, delete, exit/back decisions
Source files: `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
Related modules: lifecycle, STANJE ROBE, contacts, IRiU, logs
Business purpose: complete or remove local case state while protecting related consequences.
Inputs: PREDMET status, ceremony date, user actions, related rows.
Decision points: whether ceremony is past; whether status allows anonymization; whether user confirms close/delete/exit.
Pseudocode:

```text
FOR automatic finish:
    IF status is not ZAVRSEN or ANONIMIZOVAN
       AND ceremony date is in the past:
        mark case as finished

FOR anonymization:
    IF status == ZAVRSEN:
        allow GDPR anonymization action
        redact configured personal/contact data

FOR delete:
    IF user confirms delete:
        reconcile STANJE ROBE full PREDMET delete
        delete logs for PREDMET
        delete contacts for PREDMET
        delete IRiU rows for PREDMET
        delete IRiU lifecycle decisions for PREDMET
        delete PREDMET row

FOR exit/back:
    IF local workflow has unsaved or risky state:
        require explicit user decision before leaving
```

Outputs: finished/anonymized/deleted state or protected navigation decision.
Side effects: delete path removes/reconciles related rows.
What this must not change: must not silently lose stock consequences or related rows.
Evidence: source-confirmed repository delete/reconcile and UI actions; exit/back behavior source-inspected at high level.
Tests: partial related JSON/stock tests; full runtime workflow is `RUNTIME GAP`.
Known gaps: full close/delete/anonymize runtime parity.
Bug/nedoslednost candidates: close-block/exit decision visibility needs runtime smoke.
Safe upgrade notes: test as a grouped lifecycle scenario, not separate button tasks.
Classification: `SOURCE-CONFIRMED / RUNTIME GAP`.

## PSEUDO-ID: OPC-PSEUDO-004

Business area: PREDMET identity and metadata
Source files: `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/core/utils/json_export_import.dart`; `lib/core/json_transfer/predmet_json_transfer_core.dart`
Related modules: JSON, backup/restore, future Web/sync, version/log
Business purpose: distinguish local technical identity, current business number, scenario/source metadata, and future firm scope.
Inputs: local DB id, `brojPredmeta`, `businessScenarioId`, `sourceIdentity`, user ids, `verzija`, `exportVerzija`.
Decision points: current import conflict uses `brojPredmeta`; future policy requires firm-scoped identity.
Pseudocode:

```text
local id:
    use as local database primary key only

brojPredmeta:
    use as current case number and current single-PREDMET conflict lookup key
    do not treat as global identity

businessScenarioId:
    if empty or unknown, resolve to default funeral ceremony policy

sourceIdentity:
    if empty, default to local_opc

createdByKorisnikId:
    store creator/adviser context when available

lastBusinessModifiedBy/At:
    update only when confirmed business snapshot changes

verzija:
    business version signal
    increment only under confirmed-close business-change rule

exportVerzija:
    JSON export metadata carried in transfer
```

Outputs: identity metadata used by UI, JSON, logs, future audits.
Side effects: metadata updates on creation/close/export/import.
What this must not change: filename and `exportDatum` must not become identity/freshness authority.
Evidence: table/source/test evidence plus owner decisions.
Tests: `test/json_transfer_regression_test.dart` covers locked metadata and `exportVerzija` transfer.
Known gaps: firm-scoped PIB + MB + brojPredmeta guard is policy, not implemented/proven.
Bug/nedoslednost candidates: current same-case conflict is narrower than future policy.
Safe upgrade notes: identity guard requires repository identity audit and migration/review plan.
Classification: `SOURCE-CONFIRMED / OWNER DECISION / POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## PSEUDO-ID: OPC-PSEUDO-005

Business area: Business policy evaluator
Source files: `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart`; `business_policy_models.dart`; `business_scenario_id.dart`
Related modules: evaluator, advisor, IRiU, finance
Business purpose: convert selected PREDMET facts into a policy snapshot.
Inputs: PREDMET id, `brojPredmeta`, death place/cause, ceremony type, cemetery/grob facts, international/reception flags, scenario id.
Decision points: scenario resolution, normalization, flag derivation.
Pseudocode:

```text
resolve scenario:
    IF PREDMET.businessScenarioId is empty or unknown:
        use default funeral ceremony policy

normalize inputs:
    normalize mestoSmrti
    preserve ceremony, cemetery, grob, international, reception facts

derive flags:
    isKremacija = ceremony is cremation type
    isHospitalDeath = normalized death place is BOLNICA
    isLocalCemetery = cemetery type is LOKALNO
    isGradskoCemetery = cemetery type is GRADSKO
    isInternationalCase = sahranaVanSrbije
    hasReceptionOfRemains = docekPosmrtnihOstataka
    hasUzrokSmrtiOverride = cause in NASILNA, ZARAZNA, NEDEFINISANA
    requiresBiohazardPrecautions =
        cause is ZARAZNA
        and death place is known
        and death place is not BOLNICA

return policy snapshot
```

Outputs: `PredmetBusinessPolicySnapshot`.
Side effects: none directly.
What this must not change: evaluator does not own complete ceremony advisor, PIO/refund guidance, JKP/payer guidance, document requirement graph, or stock contract.
Evidence: source-confirmed evaluator and deep audit.
Tests: IRiU critical scenario tests indirectly cover downstream consequences.
Known gaps: full advisor/checklist output is not implemented.
Bug/nedoslednost candidates: evaluator name may be misunderstood as complete advisor.
Safe upgrade notes: define advisor scope before adding warnings.
Classification: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED`.

## PSEUDO-ID: OPC-PSEUDO-006

Business area: IRiU truth engine
Source files: `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`; `predmet_iriu_truth_service.dart`; `iriu_truth_models.dart`
Related modules: IRiU, evaluator, finance, documents
Business purpose: classify selected goods/services according to current PREDMET conditions.
Inputs: PREDMET, evaluator snapshot, stored IRiU rows.
Decision points: operational activity, recommendation, biohazard, financial inclusion, derivative exclusion.
Pseudocode:

```text
FOR each stored IRiU row:
    read managed policy for internal category
    active = category is operationally active under current PREDMET conditions
    recommended = category is recommended under current PREDMET conditions
    biohazard = category is SPREMANJE_POKOJNIKA and infectious non-hospital case

    IF active:
        operational state = active
    ELSE:
        operational state = suppressed

    IF row is inactive and managed policy requires user resolution:
        requiresUserResolution = true

    IF active and amount > 0:
        financial state = counts
    ELSE IF inactive:
        financial state = excluded suppressed
    ELSE:
        financial state = excluded non-positive

    IF category is document-scoped citulja or inactive:
        add derivative exclusion reason
```

Outputs: IRiU truth rows with state, reasons, ordering, financial/derivative decisions.
Side effects: none by truth service; lifecycle services can plan changes.
What this must not change: must not make catalog or finance a separate PREDMET truth.
Evidence: source-confirmed rules/service.
Tests: `test/business_policy_iriu_critical_scenarios_test.dart`.
Known gaps: broader death-place/international/finance tests needed.
Bug/nedoslednost candidates: finance/document consequences can drift if rules change without tests.
Safe upgrade notes: characterize each scenario before changing category rules.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## PSEUDO-ID: OPC-PSEUDO-007

Business area: Business scenarios and consequences
Source files: `iriu_truth_rules.dart`; `mesto_smrti_iriu_lifecycle_service.dart`; `blok2_iriu_lifecycle_service.dart`; `business_policy_evaluator.dart`
Related modules: evaluator, IRiU, advisor
Business purpose: express source-confirmed condition scenarios as business consequences.
Inputs: death place, cause, ceremony type, cemetery type, grob type, international/reception flags, stored/dismissed rows.
Decision points: hospital/non-hospital, cremation, grobnica/grob, local cemetery, international, reception, condition changes.
Pseudocode:

```text
IF death place is STAN, DOM ZA STARE, ULICA/JAVNO MESTO, or DRUGO:
    activate death-place service categories
ELSE IF death place is BOLNICA:
    activate PREVOZ_DO_GROBLJA only from death-place managed group

IF cause is ZARAZNA and death place is non-hospital:
    mark SPREMANJE_POKOJNIKA as biohazard

IF ceremony is cremation:
    do not recommend LIMENI_ULOZAK or LEMOVANJE
ELSE IF grob type is GROBNICA or cause override is active:
    recommend LIMENI_ULOZAK
    recommend LEMOVANJE

IF cemetery type is LOKALNO:
    recommend PREVOZ_SPROVODA

IF sahranaVanSrbije:
    activate international transport/documentation/balsamovanje categories

IF docekPosmrtnihOstataka:
    activate CARGO_TROSKOVI

ON condition change:
    IF previously active managed row becomes inactive:
        require user resolution
    IF newly required managed row is missing and not dismissed:
        plan add confirmation
```

Outputs: active/recommended/suppressed categories and confirmation plans.
Side effects: lifecycle services can insert/confirm/remove after user flow.
What this must not change: do not invent scenarios beyond source-confirmed rules.
Evidence: source-confirmed rules and scenario matrix.
Tests: Blok 2 grobnica/cremation/override/transition tests exist.
Known gaps: death-place, international, reception and finance tests are incomplete.
Bug/nedoslednost candidates: non-tested scenarios may regress silently.
Safe upgrade notes: add scenario matrix tests before advisor expansion.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TEST GAP`.

## PSEUDO-ID: OPC-PSEUDO-008

Business area: STANJE ROBE lifecycle consequences
Source files: `lib/features/stanje_robe/application/stanje_robe_lifecycle_service.dart`; `stanje_robe_operational_availability.dart`; `stanje_robe_repository.dart`; `stanje_robe_effects_repository.dart`; `stanje_robe_posledice_repository.dart`; `lib/core/catalog/stock_catalog_identity.dart`
Related modules: STANJE ROBE, IRiU, JSON, review, entitlements
Business purpose: apply, restore, replace, or record unresolved stock effects for covered selected IRiU categories.
Inputs: PREDMET id, IRiU row id, covered category, `stableArticleId`, selected name/amount snapshot, operational toggle/entitlement, current stock.
Decision points: operationally active, covered category, stable article id exists, sufficient stock, existing effect status.
Pseudocode:

```text
IF STANJE ROBE is not operationally active:
    return operationally disabled

IF selected category is not covered or stableArticleId is empty:
    do not apply stock effect

WHEN selection is applied:
    IF stock is missing or insufficient:
        record unresolved consequence for PREDMET + IRiU row
        do not decrement stock
    ELSE:
        decrement stock by covered effect quantity
        insert applied effect memory
        resolve active unresolved consequence for row

WHEN selection is removed:
    IF current effect is applied:
        restore stock quantity
        mark effect restored
    ELSE IF current effect is unresolved:
        clear unresolved consequence

WHEN selected article is replaced:
    IF same article and current effect is applied:
        keep existing applied effect
        resolve unresolved row
    ELSE:
        restore or supersede old effect
        apply new article effect or record new unresolved consequence

ON full PREDMET delete:
    reconcile all stock effects and unresolved consequences for that PREDMET
```

Outputs: applied/restored/replaced/unresolved lifecycle outcomes.
Side effects: stock quantity changes, effect records, unresolved consequence records.
What this must not change: STANJE ROBE must not become parallel PREDMET truth or transfer warehouse quantities in single-PREDMET JSON.
Evidence: source-confirmed service logic.
Tests: `test/stanje_robe_operational_toggle_test.dart`; JSON transfer tests cover consequence transfer boundaries.
Known gaps: close-block visibility and import/replace stock policy need audit.
Bug/nedoslednost candidates: unresolved consequence visibility and replacement edge cases need characterization.
Safe upgrade notes: group stock consequence tests by available/insufficient replacement paths.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / PARTIALLY IMPLEMENTED`.

## PSEUDO-ID: OPC-PSEUDO-009

Business area: Finance / financial truth
Source files: `lib/features/predmeti/core_v2/services/financial_truth_service.dart`; `iriu_truth_rules.dart`; `finansije_segment.dart`; `lista_pdf_data_builder.dart`
Related modules: finance, IRiU, Platilac, JKP, PIO/refund, PDF
Business purpose: derive money rows from active IRiU truth and PREDMET finance fields.
Inputs: IRiU truth rows, row amounts, refund fields, JKP fields, advance, discount, payment notes.
Decision points: active vs suppressed, positive amount, refund active, payer self-refund, JKP self-pay.
Pseudocode:

```text
FOR each IRiU truth row:
    IF row is active and amount > 0:
        include in ROBA I USLUGE
    ELSE:
        exclude with reason

financial display:
    start from ROBA I USLUGE total
    IF PIO refund applies and payer does not refund independently:
        subtract refund
    IF advance exists:
        subtract advance
    IF JKP is payer obligation:
        add JKP costs
    IF discount exists:
        subtract discount
    show final ZA NAPLATU
```

Outputs: finance UI/PDF totals and included/excluded row basis.
Side effects: finance fields can be saved to PREDMET; financial truth service itself classifies/calculates.
What this must not change: finance does not own PREDMET identity, evaluator policy, or stock truth.
Evidence: source-confirmed financial truth and PDF rows.
Tests: no full finance regression suite found.
Known gaps: PIO/refund and JKP guidance are not evaluator-owned.
Bug/nedoslednost candidates: money formatting/rounding and payer/refund edge cases need characterization.
Safe upgrade notes: group finance tests by IRiU inclusion, refund, JKP, advance, discount.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## PSEUDO-ID: OPC-PSEUDO-010

Business area: PARTA and CITULJE display composition
Source files: `lib/features/predmeti/presentation/segments/parte_segment.dart`; `lib/core/database/tables/predmeti_table.dart`; `lib/core/constants/iriu_constants.dart`; PDF builders
Related modules: PARTA, CITULJE, Preminulo lice, PDF, IRiU
Business purpose: compose derivative public text from PREDMET fields and display flags.
Inputs: name, surname, middle name, title, profession, rank, nickname, nickname flags, script, symbol, mourners, ceremony data.
Decision points: title before/after, middle name flag, nickname shown or hidden, nickname placement, profession flag, rank flag, script transliteration.
Pseudocode:

```text
build PARTA preview:
    start with base line for deceased person
    nameParts = []
    IF title is marked before name:
        add title
    add first name
    IF middle-name-on-parta flag and middle name exists:
        add middle name
    IF nickname-on-parta and nickname-placement is between:
        add quoted nickname
    add surname
    IF nickname-on-parta and nickname-placement is after surname:
        add dash + nickname
    IF title is not before name:
        add title
    add nameParts as display name line
    IF profession-on-parta:
        add profession line
    IF rank-on-parta and military pensioner condition applies:
        add rank line
    add ceremony/mourner text where present
    IF script is CIRILICA:
        transliterate generated text to Cyrillic
```

Outputs: PARTA preview/display text and PREDMET-stored display fields.
Side effects: saving segment writes PARTA/display fields to PREDMET.
What this must not change: PARTA display does not change PREDMET identity.
Evidence: source-confirmed segment preview and save fields.
Tests: no dedicated PARTA/CITULJE display tests found.
Known gaps: final PDF/render parity and CITULJE workflow are incomplete.
Bug/nedoslednost candidates: nickname/title/rank/profession/middle-name combinations may be inconsistent across preview/PDF/JSON.
Safe upgrade notes: create display composition matrix before changing labels or formatting.
Classification: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED / TEST GAP`.

## PSEUDO-ID: OPC-PSEUDO-011

Business area: PDF/document derivation
Source files: `lib/features/predmeti/pdf/*.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `opc_entitlement_policy.dart`
Related modules: PDF, PREDMET, IRiU, finance, FirmaPodaci, PARTA
Business purpose: render PREDMET-derived operational and financial documents.
Inputs: PREDMET, firm data, app settings, adviser, IRiU truth, financial truth, PARTA preview, version/status metadata.
Decision points: document action availability, ceremony type, payer/JKP relation, refund/finance rows, active IRiU rows.
Pseudocode:

```text
WHEN building a document:
    read PREDMET facts
    read FirmaPodaci and app settings
    read adviser/user display name
    evaluate IRiU truth
    build financial truth
    render sections:
        deceased person
        payer / JKP
        ceremony
        IRiU goods/services
        finance
        notes
        PARTA preview when relevant
        version/status/export metadata where supported

IF entitlement/package hides document action:
    do not offer that action
```

Outputs: PDFs/document data.
Side effects: document generation outputs a file/share action; should not rewrite business truth.
What this must not change: PDF is not policy source and must not become PREDMET master truth.
Evidence: source-confirmed PDF builders/exporters and entitlement policy.
Tests: no full PDF render regression suite found.
Known gaps: preview/final PDF consistency, terminology labels, demo/internal document boundaries need audit.
Bug/nedoslednost candidates: document labels can drift from UI/source terms.
Safe upgrade notes: document data-builder tests before rendering changes.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## PSEUDO-ID: OPC-PSEUDO-012

Business area: JSON single-PREDMET transfer
Source files: `lib/core/utils/json_export_import.dart`; `lib/core/json_transfer/predmet_json_transfer_core.dart`; `lib/core/format/app_filename_format.dart`
Related modules: JSON, PREDMET identity, IRiU, contacts, STANJE ROBE, version
Business purpose: export/import one PREDMET boundary with approved related data.
Inputs: PREDMET, IRiU rows, contacts, unresolved stock consequences, root metadata.
Decision points: schema support, format, same `brojPredmeta` conflict, user choice, replacement vs new import.
Pseudocode:

```text
EXPORT single PREDMET:
    create root with format OPC_PREDMET
    set schema version
    include exportVerzija and exportDatum as metadata
    include source expectations
    include PREDMET fields
    include IRiU rows
    include contact rows
    IF unresolved stock consequences are transferable:
        include consequence transfer block only
    do not include warehouse ownership tables
    generate human-readable filename from name + brojPredmeta + version

IMPORT single PREDMET:
    validate format/schema
    normalize PREDMET map and default missing metadata
    read imported brojPredmeta
    IF local PREDMET with same non-empty brojPredmeta exists:
        show keep local / replace imported / cancel
        IF keep local or cancel:
            do not import replacement
        IF replace:
            keep local technical id
            replace imported business state into local id
            rebuild IRiU and contacts under local id
            clean stale related lifecycle/log data as designed
    ELSE:
        insert as new local PREDMET
```

Outputs: JSON file or imported local case.
Side effects: replacement can rewrite local PREDMET business state and related child rows.
What this must not change: JSON must not decide business correctness from filename or `exportDatum`; must not remove explicit user choice without owner decision.
Evidence: source-confirmed transfer code and tests.
Tests: `test/json_transfer_regression_test.dart`.
Known gaps: firm-scoped identity guard and version/freshness warnings are not implemented/proven.
Bug/nedoslednost candidates: current conflict key narrower than future policy; `verzija` warning matrix missing.
Safe upgrade notes: add characterization around identity/version before guard implementation.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / OWNER DECISION`.

## PSEUDO-ID: OPC-PSEUDO-013

Business area: Full backup/restore
Source files: `lib/core/utils/json_export_import.dart`; `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
Related modules: backup/restore, database ownership, FirmaPodaci, STANJE ROBE
Business purpose: export/import broader local database state, distinct from single-PREDMET transfer.
Inputs: broad database tables, backup format, stock backup payload, user confirmation.
Decision points: backup format, schema support, destructive confirmation, stock backup compatibility.
Pseudocode:

```text
EXPORT full backup:
    collect broad database sections
    include PREDMET, IRiU, contacts, users, firm, catalog, settings, documents, logs
    include STANJE ROBE backup sections when supported
    write format OPC_BACKUP

IMPORT full backup:
    require supported JSON schema
    show destructive import confirmation
    IF user confirms:
        restore database sections
        IF supported stock backup payload exists:
            restore stock sections
        ELSE:
            import without stock restore and report that limitation
```

Outputs: backup JSON or restored local database.
Side effects: broad local data replacement.
What this must not change: must not silently reinterpret single-PREDMET transfer as full backup; must not bypass future firm identity guard.
Evidence: source-confirmed backup flow and policy summary.
Tests: JSON regression tests cover selected backup stock/toggle behavior.
Known gaps: PIB/MB mismatch guard is policy but not proven implemented.
Bug/nedoslednost candidates: destructive restore safety and firm identity validation.
Safe upgrade notes: repository identity audit before restore guard implementation.
Classification: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED`.

## PSEUDO-ID: OPC-PSEUDO-014

Business area: Entitlement, packages, add-ons, roles overlay
Source files: `lib/core/entitlements/opc_entitlement_policy.dart`; `opc_local_license_parser.dart`; `opc_local_license_bootstrap_service.dart`; `test/opc_local_license_parser_test.dart`; `test/package_downgrade_migration_test.dart`
Related modules: packages/licensing, STANJE ROBE, documents, users/roles, future access
Business purpose: decide which modules/actions are available without changing PREDMET truth.
Inputs: package level, add-ons, source kind, environment, local license payload, platform/installation.
Decision points: safe fallback, package availability, add-on enablement, production unsafe source.
Pseudocode:

```text
load entitlement:
    IF installed local license is missing or invalid:
        fall back to Osnovni safe production package
    ELSE:
        parse and verify license
        validate platform, installation, validity dates, signature
        map package and add-ons to entitlement payload

evaluate feature/module:
    IF package includes module:
        allow module
    ELSE IF add-on explicitly enables module:
        allow module
    ELSE:
        hide or lock module/action

role overlay:
    local Administrator/Savetnik can affect access to some controls
    entitlement still must not mutate PREDMET truth
```

Outputs: active package/add-on/module availability.
Side effects: may hide/disable UI actions; should not rewrite case data.
What this must not change: package/licensing must never change PREDMET business truth.
Evidence: source-confirmed policy/parser/bootstrap tests.
Tests: license parser, package downgrade migration, settings smoke.
Known gaps: payment/subscription and stable firm/license roles are blocked.
Bug/nedoslednost candidates: internal `saas` source kind is cleanup candidate, not product terminology.
Safe upgrade notes: payment/access gate before any commercial implementation.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / OWNER DECISION`.

## PSEUDO-ID: OPC-PSEUDO-015

Business area: Users/auth/recovery
Source files: `lib/core/database/tables/korisnici_table.dart`; `lib/features/auth/data/auth_repository.dart`; `session_service.dart`; auth presentation files
Related modules: users/advisers/admin, PREDMET metadata, settings, roles
Business purpose: local user authentication, session, and role separation.
Inputs: user, role, PIN, temporary PIN/recovery flows, active flag.
Decision points: first admin, login PIN, forced PIN change, admin reset, recovery material.
Pseudocode:

```text
first launch:
    IF no administrator exists:
        require creation of first administrator

login:
    find active user
    verify PIN
    IF PIN requires forced change:
        route to forced PIN change
    ELSE:
        start session

admin/user management:
    Administrator can manage users and resets
    Savetnik has limited operational role

forgotten PIN / recovery:
    use recovery/service reset material where available
    restore access without changing PREDMET truth
```

Outputs: authenticated session and role context.
Side effects: user records/session state/PIN state; PREDMET metadata can store adviser/user ids during case work.
What this must not change: auth must not rewrite PREDMET business truth or become future firm/license identity without audit.
Evidence: source-confirmed auth table/repository/screens.
Tests: `test/login_screen_smoke_test.dart`; settings/user smoke tests.
Known gaps: stable cross-device Administrator/Savetnik identity is not implemented.
Bug/nedoslednost candidates: role identity vs future licensing/firma model.
Safe upgrade notes: identity audit before Web/roles/payment work.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## PSEUDO-ID: OPC-PSEUDO-016

Business area: Pregled i potvrda and future advisor
Source files: `lib/features/predmeti/presentation/predmet_screen.dart`; `predmeti_repository.dart`; evaluator docs/source
Related modules: review, lifecycle, evaluator/advisor, version/log
Business purpose: review case state, show lifecycle actions, and future guidance/checklist location.
Inputs: all PREDMET sections, saved state, status, version, evaluator/IRiU/finance consequences.
Decision points: save/close/edit availability, dirty state, current status, future warning taxonomy.
Pseudocode:

```text
current review:
    show PREDMET status
    show verzija
    show saved/unsaved state
    offer save / close / edit lifecycle actions according to status

future advisor concept:
    read PREDMET and module consequences
    read evaluator snapshot and IRiU/finance/stock states
    show warnings/checklist as derivative guidance
    do not become master truth
    do not change rules without owner-approved taxonomy
```

Outputs: review screen state and lifecycle actions; future checklist is not implemented.
Side effects: current actions call repository lifecycle methods.
What this must not change: future checklist must read module consequences without becoming PREDMET truth.
Evidence: source-confirmed current review; owner decision for future change-log location.
Tests: partial related tests; no full review/change-log test.
Known gaps: version/change-log overview and complete advisor checklist missing.
Bug/nedoslednost candidates: review can be too thin for future business confirmation.
Safe upgrade notes: audit current review structure before adding guidance.
Classification: `SOURCE-CONFIRMED / POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## PSEUDO-ID: OPC-PSEUDO-017

Business area: Local legacy PROJECT_DOCS context
Source files: `PROJECT_DOCS/*`; public promotion docs
Related modules: continuity, source of truth
Business purpose: preserve local historical rules while keeping public docs as current source of truth.
Inputs: local project docs, public docs, source-of-truth map.
Decision points: whether legacy docs are present in repo; whether public docs supersede old wording.
Pseudocode:

```text
IF PROJECT_DOCS is present:
    use as supporting/historical local context
    do not raw-promote private or stale text
    preserve public docs as active source of truth
ELSE:
    record legacy docs not present in repo
```

Outputs: evidence context only.
Side effects: none.
What this must not change: old SaaS/server-master wording must not override manifest/owner decisions.
Evidence: `PROJECT_DOCS` is present locally; public docs define source-of-truth hierarchy.
Tests: not applicable.
Known gaps: owner review still required for any future raw promotion.
Bug/nedoslednost candidates: stale local wording can mislead future tasks.
Safe upgrade notes: use sanitized summaries only.
Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## PSEUDO-ID: OPC-PSEUDO-018

Business area: Modular truth-boundary rule
Source/docs files: `docs/OPC_MODULAR_FOUNDATION_CONTROL_PLAN.md`; `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
Related modules: all modules around PREDMET
Business purpose: classify every module by how it relates to PREDMET truth before any grouped upgrade or implementation work.
Inputs: module name, module class, read sources, write targets, outputs, side effects, evidence classification.
Decision points: whether module is PREDMET core, core support, PREDMET-consuming, derivative/render, operational, finance, stock, transfer, advisor/guidance, support/access, add-on/package, or future/Web seam.
Pseudocode:

```text
FOR each module:
    classify module by relationship to PREDMET
    identify what the module reads
    identify what the module may write
    identify outputs and allowed side effects
    identify forbidden side effects

    IF module attempts to own PREDMET meaning:
        mark implementation blocked
        require owner decision or technical audit

    IF module changes or clarifies business/logical behavior:
        require pseudocode update in the same task

    forbid parallel PREDMET truth
```

Outputs: module contract and truth-boundary classification.
Side effects: documentation-only; no source, schema, runtime, test, UI, PDF, JSON, import/export, backup/restore, Web, sync, storage, payment, entitlement, role, evaluator, IRiU, STANJE ROBE, or finance behavior changes.
What this must not change: real source remains implementation truth; pseudocode must not become a second source of truth.
Evidence: current manifest, module relationship map, new module contracts document.
Tests: not applicable for this docs-only control rule.
Known gaps: module behavior gaps remain technical-audit or characterization items.
Bug/nedoslednost candidates: module outputs can be mistaken for master truth.
Safe upgrade notes: module classification is required before grouped behavior changes.
Classification: `DOCUMENTED POLICY / CHARACTERIZATION REQUIRED`.

## PSEUDO-ID: OPC-PSEUDO-019

Business area: Characterization-before-change rule
Source/docs files: `docs/OPC_MODULAR_FOUNDATION_CONTROL_PLAN.md`; `docs/OPC_GROUPED_SAFE_UPGRADE_PLAN.md`; `docs/OPC_SOURCE_OF_TRUTH_MAP.md`; `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
Related modules: all business/logical modules
Business purpose: prevent uncharacterized behavior changes and keep owner policy separate from Codex implementation.
Inputs: task scope, affected behavior, existing source/test/runtime evidence, owner-approved rule text, pseudocode sections.
Decision points: whether current task changes existing business/logical behavior or only documents boundaries.
Pseudocode:

```text
IF a task changes existing business/logical behavior:
    require characterization evidence first
    require owner-approved rule change
    update pseudocode in the same task
    document module truth boundary
ELSE:
    document no-behavior-change boundary
    record evidence, gaps, risks, decisions required, and blockers
```

Outputs: characterization requirement, owner-decision requirement, no-behavior-change boundary, or implementation blocker.
Side effects: documentation-only unless a later approved implementation task exists.
What this must not change: this rule does not authorize behavior changes.
Evidence: manifest special gates, stop-list, source-of-truth map, control plan.
Tests: not applicable for this docs-only rule; later implementation tasks must define tests according to risk.
Known gaps: current business areas have uneven test coverage.
Bug/nedoslednost candidates: a symptom may look like a bug before characterization proves it.
Safe upgrade notes: source/test/runtime characterization must precede rule-changing implementation.
Classification: `DOCUMENTED POLICY / CHARACTERIZATION REQUIRED`.

## PSEUDO-ID: OPC-PSEUDO-020

Business area: Safe upgrade family grouping rule
Source/docs files: `docs/OPC_GROUPED_SAFE_UPGRADE_PLAN.md`; `docs/OPC_CHILD_ILLNESS_AND_SAFE_UPGRADE_CANDIDATE_REGISTER.md`; `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`
Related modules: all modules with child-illness symptoms
Business purpose: group symptoms into owner-reviewable upgrade families without creating nano-tasks or Codex strategy.
Inputs: symptom, affected modules, affected pseudocode sections, evidence, business risk, current protection, blockers.
Decision points: whether symptom has source/test/runtime proof, whether owner decision or technical audit is required, whether implementation is blocked.
Pseudocode:

```text
IF a symptom is found:
    group it into an upgrade family
    record affected modules and pseudocode sections
    record evidence/gap/blocker
    do not create nano-task
    do not recommend next task
    do not assign priority order or sequence
```

Outputs: upgrade-family classification, characterization evidence needed, owner decisions, technical audits, implementation blockers.
Side effects: documentation-only grouping.
What this must not change: no implementation task, roadmap, priority order, or recommended next step is produced by this rule.
Evidence: grouped safe upgrade plan and existing child-illness register.
Tests: not applicable for grouping; future tasks define characterization tests if authorized.
Known gaps: families remain evidence buckets until owner/Logos select strategy.
Bug/nedoslednost candidates: symptoms remain candidates unless source/test/runtime proof confirms a bug.
Safe upgrade notes: grouped families must stay goal-level and non-sequential.
Classification: `DOCUMENTED POLICY / OWNER DECISION REQUIRED`.

## PSEUDO-ID: OPC-PSEUDO-021

Business area: Web-readiness guardrail rule
Source/docs files: `docs/OPC_WEB_READINESS_GUARDRAILS.md`; `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`; `docs/OPC_MODULAR_FOUNDATION_CONTROL_PLAN.md`
Related modules: PREDMET, JSON, backup/restore, FirmaPodaci, users/roles, entitlement, evaluator, advisor, IRiU, STANJE ROBE, finance, PDF/documents, future OPC Web/sync
Business purpose: keep current local-first OPC changes from blocking future OPC Web/access readiness while avoiding premature Web implementation.
Inputs: current decision, affected identity/sync/module/evaluator/JSON/finance/stock/entitlement area, evidence, uncertainty.
Decision points: whether a current decision affects identity, sync, module boundary, evaluator, JSON, finance, stock, entitlement, role, storage, or access.
Pseudocode:

```text
IF a current decision affects identity, sync, module boundary,
   evaluator, JSON, finance, stock, entitlement, role, storage, or access:
    check future OPC Web/access guardrails

    IF the effect is uncertain:
        mark owner decision required or technical audit required

    IF implementation would choose Web architecture:
        mark implementation blocked

    do not implement Web solution in current task
```

Outputs: Web-readiness classification, guardrail finding, owner decision, technical audit, or implementation blocker.
Side effects: documentation-only guardrail.
What this must not change: no Web runner, backend, API, sync, storage, payment, licensing, role, or architecture selection.
Evidence: Web guardrails document, manifest, owner decisions.
Tests: not applicable for docs-only guardrail.
Known gaps: final Web architecture, conflict model, firm identity, role identity, storage, payment/access, and sync remain unresolved.
Bug/nedoslednost candidates: future Web assumptions may conflict with local-first ownership if not audited.
Safe upgrade notes: Web-readiness is a guardrail layer, not an implementation layer.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.
