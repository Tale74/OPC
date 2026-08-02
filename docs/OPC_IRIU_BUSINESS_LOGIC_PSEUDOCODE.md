# OPC IRIU Business Logic Pseudocode

## 1. Contract

```text
DOCUMENT_KIND = SOURCE_RECONSTRUCTION_AND_CONFIRMED_ALIGNMENT
CONFIRMED_ALIGNMENT_IMPLEMENTED = TRUE
PODSETNIK_OR_NEW_LIFECYCLE_IMPLEMENTATION_AUTHORIZATION = FALSE

MASTER_TRUTH = PREDMET
IRIU_ROLE = PREDMET_CHILD_BUSINESS_STATE_AND_DERIVATION_INPUT
CURRENT_OPERATIONAL_DOCUMENT = NALOG_ZA_OPREMANJE
NALOG_ZA_PRIPREMU = TASK_TEXT_TYPO_CONFIRMED_BY_OWNER

FOR_EACH finding:
  classify CURRENT_SOURCE_BEHAVIOR
  classify EXISTING_BUSINESS_MEANING
  record OWNER_DECISION_REQUIRED
  map IMPLEMENTATION_IMPACT
  record FALLBACK_REQUIREMENT
```

## 2. Stored row model

```text
IRIU_ROW = {
  id: local_row_identity,
  predmetId: authoritative_parent,
  katalogStableArticleId: nullable_catalog_metadata_reference,
  interniNaziv: stable_category_discriminator,
  nazivPrikaz: editable_visible_snapshot,
  kom: informational_document_text,
  iznos: stored_row_amount,
  cekiran: legacy_boolean_without_current_business_state_consumption,
  redosled: presentation/business_order
}

ON PREDMET_DELETE:
  reconcile_current_stock_effects
  delete IRIU rows
  delete IRIU lifecycle decisions

NEVER_INTERPRET IRIU_ROW.cekiran AS accepted_or_completed
NEVER_INTERPRET IRIU_ROW.kom AS inventory_quantity
```

## 3. Mixed row meanings

```text
possible_current_row_origin =
  INITIAL_CATEGORY_SLOT
  OR CATALOG_ARTICLE_SNAPSHOT
  OR MANUAL_FIXED_ITEM
  OR USER_CATALOG_CATEGORY_ITEM
  OR CONDITION_DERIVED_ROW
  OR RECOMMENDED_ROW

CURRENT_SCHEMA DOES_NOT_STORE explicit_origin_or_business_type

IRIU_SCREEN_NAPOMENA:
  storage_owner = PREDMET.napomena
  document_meaning = OPSTA_NAPOMENA
  NOT an IRIU_row_or_execution_history

safe_common_meaning =
  "stored goods/services row belonging to PREDMET with visible snapshot data"

DO_NOT_INFER:
  obligation
  acceptance
  execution
  cancellation
  readiness
```

## 4. New PREDMET initialization

```text
ON create_new_PREDMET:
  insert PREDMET
  FOR category IN [
    SANDUK,
    OBELEZJE,
    POKROV_GARNITURA,
    PESKIR_ZA_KRST,
    POSMRTNE_PARTE,
    CRNINA,
    AGENCIJSKE_USLUGE,
    CVECE,
    CITULJA_POLITIKA,
    all_user_catalog_categories
  ]:
    IF category_config_exists:
      insert IRIU row(
        generic_display_name,
        kom = "1",
        iznos = 0,
        no_selected_catalog_article_unless_later_selected
      )
    ELSE:
      skip category

INITIAL_ROW DOES_NOT_PROVE selected_article_or_executed_service
```

## 5. Truth evaluation

```text
INPUTS = PREDMET + STORED_IRIU_ROWS

policySnapshot = BusinessPolicyEvaluator(PREDMET)

FOR EACH stored_row:
  active = IriuTruthRules.isOperationallyActive(PREDMET, row)
  recommended = IriuTruthRules.isRecommended(PREDMET, row)
  biohazard = IriuTruthRules.isBiohazard(PREDMET, row)

  IF active:
    operationalState = ACTIVE
  ELSE:
    operationalState = SUPPRESSED

  IF active AND row.iznos > 0:
    financialState = COUNTS
  ELSE IF NOT active:
    financialState = EXCLUDED_SUPPRESSED
  ELSE:
    financialState = EXCLUDED_NON_POSITIVE_AMOUNT

  derivativeExclusions = {}
  IF NOT active:
    add NOT_OPERATIONALLY_ACTIVE
  IF row.category IN [CITULJA_POLITIKA, CITULJA_NOVOSTI]:
    add DOCUMENT_SCOPED_OUT

NO accepted_completed_cancelled_state_is_created
```

## 6. Death-place rules

```text
normalizedMestoSmrti = normalize(
  ULICA OR JAVNO_MESTO OR ULICA_JAVNO_MESTO
  => ULICA_JAVNO_MESTO
)

IF normalizedMestoSmrti IN [STAN, DOM_ZA_STARE, ULICA_JAVNO_MESTO, DRUGO]:
  desiredMestoSmrtiCategories = [
    HLADNJACA,
    SPREMANJE_POKOJNIKA,
    IZNOSENJE,
    PREVOZ_DO_HLADNJACE,
    TRANSPORTNA_VRECA,
    PREVOZ_DO_GROBLJA
  ]
ELSE IF normalizedMestoSmrti == BOLNICA:
  desiredMestoSmrtiCategories = [PREVOZ_DO_GROBLJA]
ELSE:
  desiredMestoSmrtiCategories = []

ON current_state_sync:
  insert each missing desired category
    UNLESS category has stored MANUAL_DELETE decision

ON condition_change:
  FOR previously_active managed_row now_suppressed:
    ask ZADRZI_OR_UKLONI
    IF ZADRZI OR dialog_unresolved:
      keep stored_suppressed
    IF UKLONI:
      physically_delete
      do_not_remember_dismissal_for_this_conflict_removal

  insert newly desired missing categories
    UNLESS dismissed

IF source missing_or_unknown:
  desired = []
  DO_NOT_INFER operational_action
```

## 7. Biohazard signal

```text
requiresBiohazard =
  PREDMET.uzrokSmrti == ZARAZNA
  AND normalizedMestoSmrti is not empty
  AND normalizedMestoSmrti != BOLNICA

row.biohazard =
  row.category == SPREMANJE_POKOJNIKA
  AND requiresBiohazard

IF row.biohazard:
  IRIU_UI shows ZARAZNA_BOLEST
  NALOG_ZA_OPREMANJE shows ZARAZNA_BOLEST

biohazard_signal DOES_NOT_MEAN action_completed
```

## 8. Blok 2 rules

```text
isKremacija = vrstaCeremonije IN [KREMACIJA, KREMACIJA_EKSPRES]
hasCauseOverride = uzrokSmrti IN [NASILNA, ZARAZNA, NEDEFINISANA]

IF isKremacija:
  recommend LIMENI_ULOZAK = FALSE
  recommend LEMOVANJE = FALSE
ELSE IF hasCauseOverride:
  recommend LIMENI_ULOZAK = TRUE
  recommend LEMOVANJE = TRUE
ELSE IF tipGrobnogMesta == GROBNICA:
  recommend LIMENI_ULOZAK = TRUE
  recommend LEMOVANJE = TRUE
ELSE:
  recommend both = FALSE

recommend PREVOZ_SPROVODA = (tipGroblja == LOKALNO)

ON initial_widget_sync:
  insert missing recommended rows unless dismissed

ON live_condition_change_to_recommended:
  ask DODAJ_OR_NE_DODAJ
  IF DODAJ:
    insert row
    clear prior dismissal if normal add path applies
  IF NE_DODAJ OR dialog_returns_non_add:
    store MANUAL_DELETE dismissal

ON live_condition_change_to_not_recommended:
  ask ZADRZI_OR_UKLONI for previously active rows
  IF ZADRZI:
    keep stored_suppressed
  IF UKLONI:
    physically_delete without new dismissal memory

OWNER_REVIEW_REQUIRED:
  current dialog says "requires item" but permits NE_DODAJ
  initial-sync and live-change paths do not have identical confirmation semantics
```

## 9. CEREMONIJA direct insert rules

```text
ON OPELO changes NE_TO_DA:
  insert KOMPLET_ZA_OPELO if absent

ON OPELO changes DA_TO_NE:
  keep KOMPLET_ZA_OPELO stored
  mark row operationally SUPPRESSED
  preserve visible-name, price and other manual edits
  IF OPELO later returns to DA:
    activate the same stored row

ON SAHRANA_VAN_SRBIJE changes FALSE_TO_TRUE:
  insert if absent:
    MEDJUNARODNI_PREVOZ
    MEDJUNARODNA_DOKUMENTACIJA
    BALSAMOVANJE

active(MEDJUNARODNI_PREVOZ) = SAHRANA_VAN_SRBIJE
active(MEDJUNARODNA_DOKUMENTACIJA) = SAHRANA_VAN_SRBIJE
active(BALSAMOVANJE) = SAHRANA_VAN_SRBIJE

ON SAHRANA_VAN_SRBIJE changes TRUE_TO_FALSE:
  keep rows stored
  mark operationally SUPPRESSED
  no user conflict dialog
  no business cancellation history

ON DOCEK_POSMRTNIH_OSTATAKA changes FALSE_TO_TRUE:
  insert CARGO_TROSKOVI if absent
  expose first-class PREDMET parameters:
    MESTO_DOCEKA
    DATUM_DOCEKA
    VREME_DOCEKA

active(CARGO_TROSKOVI) = DOCEK_POSMRTNIH_OSTATAKA

ON DOCEK changes TRUE_TO_FALSE:
  keep row stored
  mark operationally SUPPRESSED
  no user conflict dialog
  no business cancellation history
  preserve MESTO_DOCEKA, DATUM_DOCEKA and VREME_DOCEKA
  IF DOCEK later returns to TRUE:
    restore the stored parameter values

OWNER_CONFIRMED_GROUPING:
  SAHRANA_VAN_SRBIJE mandatory rows:
    MEDJUNARODNI_PREVOZ
    MEDJUNARODNA_DOKUMENTACIJA
  SAHRANA_VAN_SRBIJE conditional removable row:
    BALSAMOVANJE
  DOCEK_POSMRTNIH_OSTATAKA row:
    CARGO_TROSKOVI
  BALSAMOVANJE has no DOCEK dependency

DATUM_DOCEKA_FALLBACK:
  missing value remains EMPTY
  DO_NOT invent current date
  DO_NOT block save, closing or readiness in this correction
  preserve JSON compatibility by normalizing older payloads to EMPTY
```

## 10. Catalog availability and manual rows

```text
IF SAHRANA_VAN_SRBIJE OR DOCEK:
  catalog_picker shows all four international categories

NOTE:
  picker_visibility_condition != per_row_active_condition
  user may select a row that evaluates immediately as suppressed

ADD_FROM_CATALOG:
  allowed on current supported UIs
  preserve selected visible name and price snapshot
  preserve nullable catalogStableArticleId
  allow multiple rows of same category

ADD_MANUALLY:
  IF Windows_build:
    action unavailable
  ELSE:
    IF FIKSNA:
      create unique RUCNO_timestamp category row
    IF KATALOSKA:
      create global user category
      create PREDMET row

OWNER_REVIEW_REQUIRED = Windows_Android_manual_add_parity

## KATALOG basic-category policy (legacy schema-22 behavior; current DB schema 23)

```text
KATALOG create/edit eligible category:
  read category type independently from basic policy
  basic policy default = NE
  persist osnovna_u_svakom_predmetu
  keep persistent category redosled unchanged across rename/toggle

new PREDMET:
  evaluate built-in business scenario through existing rules
  materialize existing scenario rows through existing lifecycle services
  append existing built-in basic rows in established relative order
  append AGENCIJSKE_USLUGE
  append visible enabled user/configurable basic categories
    ordered by persistent KATALOG redosled
    deduplicated by stable interni_naziv
  calculate all stored rows through existing IRiU truth/financial model

KATALOG policy toggle:
  affects future PREDMET initialization only
  never reconcile already stored PREDMET IRIU rows

manual IRiU add:
  create RUCNO_* row in current PREDMET only
  do not create/update iriu_katalog_config
  do not expose or change basic policy
  do not affect future PREDMETI
```

Protected boundary: scenario predicates and composition remain unchanged.
`Agencijske usluge` is a built-in basic boundary row, not a scenario row.
```

## 11. Edit, delete, ordering and dismissal memory

```text
ON edit(row.name, row.kom, row.amount):
  debounce
  update row directly

ON catalog_reselection:
  update category, stable_article_metadata, name, kom, amount
  IF covered_stock_category:
    execute stock_replacement_lifecycle

ON user_delete:
  ask confirmation
  IF covered catalog selection:
    restore_or_clear stock effect
  physically_delete row
  IF category managed by MESTO_SMRTI or BLOK2:
    remember MANUAL_DELETE dismissal

ON explicit_add_of_managed_category:
  clear matching MANUAL_DELETE dismissal

ORDER:
  known system categories by fixed category sequence
  unknown/manual categories afterward in current order
  SANDUK truth anchor first

DATABASE permits duplicate (predmetId, interniNaziv)

IF duplicate_category_rows:
  finance counts every active positive row
  NALOG category map retains last row in truth iteration
  OWNER_DECISION_REQUIRED
```

## 12. STANJE ROBE coupling

```text
coveredCategories = [SANDUK, OBELEZJE, POKROV_GARNITURA]
inventoryEffectQuantity = 1

IF IRIU selection has stableArticleId
   AND category is covered
   AND STANJE_ROBE operationally active:
  IF stock >= 1:
    decrement 1
    record APPLIED effect
  ELSE:
    record UNRESOLVED effect_and_consequence
    show NIJE_NA_STANJU
    block PREDMET close while operational module active

ON replace:
  restore_or_clear old effect
  apply new selection effect

ON delete:
  restore APPLIED effect OR clear UNRESOLVED effect

ON package_downgrade_or_toggle_off:
  preserve stock, effects, consequences, IRIU and PREDMET data
  suppress operational effects and current close blocker

IRIU.kom DOES_NOT_CHANGE inventory_effect
```

## 13. Financial and derivative outputs

```text
ROBA_I_USLUGE_TOTAL = 0
FOR EACH truth_row:
  IF row.active AND row.iznos > 0:
    ROBA_I_USLUGE_TOTAL += row.iznos

NEVER multiply by row.kom

LISTA_ITEM_ROWS = rows excluding:
  NOT_OPERATIONALLY_ACTIVE
  DOCUMENT_SCOPED_OUT

CITULJE:
  excluded from selected document item lists
  NOT automatically excluded from financial total

PREDMET_RAW_SNAPSHOT_PDF:
  prints raw stored IRIU rows including cekiran

STATISTIKA:
  derives active rows and financial total
  top-item occurrence is not quantity from kom
```

## 14. NALOG ZA OPREMANJE

```text
OWNER_CONFIRMED_TERM = NALOG_ZA_OPREMANJE

INPUT PREDMET:
  ime, prezime
  datumRodjenja -> display_year_or_raw_fallback
  datumSmrti -> display_year_or_raw_fallback
  mestoSmrti
  vrstaCeremonije
  groblje ELSE opeloMesto ELSE dash
  datumCeremonije
  vremeCeremonije
  brojPredmeta, status, verzija, savetnik

INPUT IRIU EQUIPMENT:
  SANDUK -> display_name_or_dash
  POKROV_GARNITURA -> display_name_or_dash
  OBELEZJE -> display_name_or_dash
  PESKIR_ZA_KRST -> display_name_or_dash

INPUT IRIU SERVICES:
  SPREMANJE_POKOJNIKA -> DA if row_exists_and_active ELSE NE
  LIMENI_ULOZAK -> DA if row_exists_and_active ELSE NE
  LEMOVANJE -> DA if row_exists_and_active ELSE NE

IF SPREMANJE_POKOJNIKA.biohazard:
  print ZARAZNA_BOLEST

PRINT blank_signature_lines:
  NALOG_IZDAO
  OPREMANJE_IZVRSIO

NALOG DOES_NOT_STORE:
  checklist_state
  sequence
  deadline
  assignee
  digital_signature
  accepted_state
  completed_state
  cancellation_history
  readiness
  vehicle_departure

PDF_generation_or_signature_line DOES_NOT_COMPLETE business_action

IF row_missing_or_suppressed:
  service prints NE
  NOTE: current output does not distinguish absent, not_applicable, suppressed

IF required display fact missing:
  print dash_or_raw_tolerant_value
  do not block export
```

## 15. JSON transfer

```text
SINGLE_PREDMET_JSON includes:
  PREDMET row
  IRIU rows with row snapshot fields
  contacts
  safe eligible unresolved stock consequence transfer

SINGLE_PREDMET_JSON excludes:
  iriu_lifecycle_decisions
  full inventory ledger/effects
  derived active/suppressed/recommended state
  nonexistent business execution history

ON single_import_new:
  create new local PREDMET id
  rebuild IRIU rows with new parent id

ON single_import_replace:
  reconcile old stock effects
  delete old contacts, IRIU, logs, lifecycle decisions
  preserve local PREDMET id
  insert incoming PREDMET/IRIU/contacts

CONSEQUENCE:
  prior dismissal memory may be absent after single transfer
  managed categories may be proposed_or_inserted_again

FULL_BACKUP includes iriu_lifecycle_decisions and broader database state
```

## 16. PREDMET lifecycle and completion

```text
CURRENT_CLOSE_BLOCKERS_RELATED_TO_IRIU:
  only active unresolved STANJE_ROBE consequence
  while STANJE_ROBE operationally active

CURRENT_ZAVRSEN_RULE:
  IF ceremony_date < today:
    auto_set ZAVRSEN

CURRENT_ZAVRSEN_RULE DOES_NOT_READ:
  IRIU missing_rows
  IRIU suppressed_rows
  IRIU recommended_rows
  IRIU cekiran
  NALOG output
  IRIU execution

SAVE_AND_CONFIRMED_CLOSE_SNAPSHOT = JSON(PredmetiData fields only)
IRIU child rows NOT included

THEREFORE:
  IRIU writes persist immediately
  only_IRIU_change is not represented in current PREDMET field snapshot comparison
  status_or_version DOES_NOT_PROVE unchanged_IRIU
```

## 17. Readiness and future PODSETNIK boundary

```text
CURRENT_IRIU_CAN_SUPPLY_CANDIDATE_INPUTS:
  stored_and_active_categories
  suppressed_categories
  death_place_and_cause consequences
  ceremony_and_international consequences
  biohazard flag
  stock unresolved consequence

CURRENT_IRIU_CANNOT_PROVE:
  accepted
  executed
  cancelled
  reception_completed
  vehicle_equipment_ready
  final_departure_ready

CURRENT_NALOG_ZA_OPREMANJE = derivative_stateless_PDF
CURRENT_PODSETNIK has no IRIU obligation integration

FUTURE_PODSETNIK MAY_ONLY:
  read PREDMET_owned facts_and_obligations
  display blockers
  navigate to source segment
  store technical reminder state

FUTURE_PODSETNIK MUST_NOT:
  treat notification interaction as completion
  use PDF as only business truth
  invent readiness from row presence
  reinterpret PREDMET.napomena as structured IRIU completion history
```

## 18. SCENARIO consequence reconciliation boundary (Phase 10)

```text
INPUT:
  PREDMET facts
  selected SCENARIO id/version and immutable snapshot
  SCENARIO OSNOVNI_PAKET categories
  existing STAVKE + optional provenance rows

RESOLVE:
  package = ScenarioPackageResolver(scenario, PREDMET, OSNOVNI_PAKET)
  desired = base categories not suppressed
           + active scenario consequences not suppressed

CLASSIFY:
  managed = provenance.origin in {OSNOVNI_PAKET, SCENARIO_PAKET}
            AND provenance.module_id == selected module
  protected = RUČNA_STAVKA, LEGACY, missing provenance,
              or another module

PLAN:
  add each desired category absent from managed rows
  remove each managed category not in desired
  update provenance when desired ownership/version/rule identity changed
  keep protected rows untouched
  require user notice if any add/remove/update exists

GUARDRAIL:
  planner is pure and read-only
  no database write, carrier write or runtime trigger occurs here
  application requires a separate PREDMET transaction and rollback
  SCENARIO never calls STANJE ROBE directly
  existing PREDMET → IRIU → STANJE ROBE flow remains unchanged
  STANJE ROBE reacts only when its own operational toggle is enabled
```

## 19. PREDMET-side SCENARIO application gate (Phase 11)

```text
PREPARE_SCENARIO_APPLICATION:
  require PREDMET.status == OTVOREN
  require assignment.module_id == reconciliation.module_id
  require assignment.scenario_id == reconciliation.scenario_id
  require assignment.scenario_version == reconciliation.scenario_version

  IF current_snapshot_hash == assignment.snapshot_hash
     AND reconciliation has no changes:
       return NO_OP
  ELSE:
       return PLAN_REQUIRING_EXPLICIT_USER_CONFIRMATION

DO_NOT_WRITE here:
  PREDMET snapshot
  IRIU rows
  PARTE, PODSETNIK or STANJE ROBE state

FUTURE_COMMIT_OWNER:
  PREDMET transaction commits snapshot and IRIU consequences
  existing PREDMET → IRIU integration remains the only downstream path
```

## 20. Unresolved owner queue

```text
OWNER_PASS_REQUIRED:
  classify each IRIU category business meaning
  mandatory_vs_recommended_vs_optional
  source_change lifecycle beyond current stored/suppressed behavior
  accepted_completed_cancelled_replaced states where needed
  deletion_vs_historical_closure
  duplicate category authority
  IRIU version/change-log semantics
  lifecycle decision single-JSON transfer scope
  Windows/Android manual-add parity
  PDF item scope versus financial total transparency
  full reception/final-departure readiness matrix
  future PODSETNIK inputs only after authoritative states exist

DO_NOT_IMPLEMENT before owner decisions are complete
```

## 21. SCENARIO runtime migration (implemented vertical slice)

```text
SCENARIO_DEFAULTS = editable data asset
  seed only when SCENARIO module has no definitions
  never overwrite later user changes

SCENARIO_MODULE:
  OSNOVNI_PAKET = user-selected KATALOG categories
  ACTIVE_RULES = definitions marked as podrazumevani and not inactive
  each rule contains condition tree + consequence STAVKE

WHEN IRIU opens or a scenario criterion changes:
  load ACTIVE_RULES from SCENARIO module
  evaluate all matching rules against current PREDMET
  desired = OSNOVNI_PAKET + matching consequence categories
  remove suppressed categories

RECONCILE through existing IriuRepository:
  add missing desired categories and record provenance as SCENARIO module
  remove only rows owned by SCENARIO module whose category is stale
  preserve RUČNA, LEGACY, unknown and other-module rows
  keep existing PREDMET → IRIU → STANJE ROBE bridge unchanged
  show user notice when additions or stale removals occurred

NO_SCENARIO_RUNTIME_RULES:
  IRIU segment does not invoke the former hardcoded lifecycle triggers
  defaults are data, not active business policy in Dart code
```
