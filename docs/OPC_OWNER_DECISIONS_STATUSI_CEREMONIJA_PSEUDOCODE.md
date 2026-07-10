# OPC Owner Decisions — STATUSI, CEREMONIJA and Cross-Segment Pseudocode

## 1. Contract

```text
DOCUMENT_KIND = OWNER_DECISION_PSEUDOCODE
IMPLEMENTATION_AUTHORIZATION = FALSE
BUSINESS_TRUTH_OWNER = PREDMET
REMINDER_OWNER = TECHNICAL_DELIVERY_STATE_ONLY

STATUS_LABELS = {
  CURRENTLY_IMPLEMENTED,
  OWNER_APPROVED_NOT_YET_IMPLEMENTED,
  PARTIALLY_IMPLEMENTED,
  KNOWN_CORRECTION_DEBT,
  OWNER_DECISION_STILL_REQUIRED,
  FUTURE_MODULE_POSSIBILITY,
  SUPERSEDED
}
```

## 2. Mandatory fallback protocol — `OPC-OD-GLOBAL-001`

```text
FOR_EACH owner_or_technical_decision:
  DEFINE fallback_for_missing_data
  DEFINE fallback_for_contradiction
  DEFINE fallback_for_invalid_input
  DEFINE fallback_for_partial_execution
  DEFINE fallback_for_source_change
  DEFINE fallback_for_timing_or_deadline
  DEFINE fallback_for_package_change
  DEFINE fallback_when_primary_action_unavailable
  DEFINE historical_evidence_policy

  IF any_fallback_is_not_owner_decided:
    MARK OWNER_DECISION_STILL_REQUIRED
    FORBID silent_inference
    FORBID false_completion
    FORBID history_deletion
```

## 3. Authority and module boundary — `OPC-OD-ARCH-001`

```text
PREDMET owns business_facts, rights, obligations, business_state, business_history
PODSETNIK may read, group, prioritize, display, schedule
PODSETNIK owns reminder_configuration and delivery_technical_state only

notification_opened OR dismissed OR snoozed OR acknowledged
  DOES_NOT_MEAN business_obligation_completed

business_completion REQUIRES explicit_confirmation(PREDMET_obligation)

FOR platform IN [Windows, Android, future_Web]:
  APPLY same_business_rules

ON package_or_entitlement_degradation:
  KEEP PREDMET facts, obligations, history
  NEVER move_only_copy_to_PODSETNIK
  DISPLAY unavailable_action_and_safe_recovery_path
```

## 4. STATUSI

### 4.1 POL and spouse initialization — `OPC-OD-STA-001`

```text
IF deceased.pol is valid_and_resolved:
  APPLY gender_appropriate_bracni_status_grammar
  INITIAL spouse.pol = opposite(deceased.pol)
ELSE:
  DO_NOT_INFER spouse.pol
  REQUIRE user_review

CURRENT_SOURCE_NOTE:
  unresolved deceased.pol may currently fall through to a default/opposite inference
  => CURRENT/FUTURE CONFLICT; NO SOURCE CHANGE IN THIS TASK
```

### 4.2 Work-status semantics — `OPC-OD-STA-002`

```text
SELECT_MULTIPLE status FROM {
  PENZIONER_SRBIJE,
  VOJNI_PENZIONER,
  INOSTRANI_PENZIONER,
  U_RADNOM_ODNOSU,
  DRUGO
}

IF PENZIONER_SRBIJE:
  POSSIBLE pio_refund
  POSSIBLE family_pension_right

IF VOJNI_PENZIONER:
  POSSIBLE family_pension_right
  POSSIBLE military_death_benefit_for_spouse
  ASK military_honors DA_OR_NE

IF PENZIONER_SRBIJE AND VOJNI_PENZIONER:
  INCLUDE pio_refund
  INCLUDE exactly_one_nonduplicated_family_pension_right
  INCLUDE military_death_benefit_for_spouse
  INCLUDE military_honors_choice
  ENABLE obligation_tracking

IF U_RADNOM_ODNOSU:
  INCLUDE family_pension_right_tri_state_only
  ENABLE independent_acceptance_and_execution

IF INOSTRANI_PENZIONER OR DRUGO:
  SHOW advisory_note ONLY_IF authoritative_advice_known
  DO_NOT_CREATE accepted_tracked_submission_for_FIRMA
  DO_NOT_INFER legal_conclusion

IF unknown_or_contradictory_combination:
  KEEP source_statuses
  REQUIRE review
```

### 4.3 One family-pension right — `OPC-OD-STA-003`

```text
family_pension = one_organizational_right
possible_beneficiaries = [spouse, minor_children, children_in_education]

OPC DOES_NOT:
  open_authority_cases
  manage_process_documents
  guarantee_entitlement
  manage_authority_decision

IF beneficiaries_or_conditions_unknown:
  family_pension.right = NIJE_UTVRDJENO

possible_future_postceremonial_services_module = FUTURE_MODULE_POSSIBILITY
```

### 4.4 Right tri-state — `OPC-OD-STA-004`

```text
right.state IN [NIJE_UTVRDJENO, DA, NE]
DEFAULT right.state = NIJE_UTVRDJENO

IF right.state == NIJE_UTVRDJENO:
  SHOW open_information_or_follow_up
  DO_NOT_BLOCK ZAVRSEN solely_for_this_reason

IF missing OR contradictory OR invalid:
  NORMALIZE_FOR_REVIEW_AS unresolved
  NEVER coerce_to_DA_or_NE
```

### 4.5 Independent right and obligation — `OPC-OD-STA-005`

```text
right.state IN [NIJE_UTVRDJENO, DA, NE]
firma_obligation.state IN [NIJE_PREUZETA, PREUZETA, IZVRSENA_ZAHTEV_PREDAT]

right.state == DA DOES_NOT_IMPLY firma_obligation.state == PREUZETA
right.state == NIJE_UTVRDJENO MAY_COEXIST_WITH firma_obligation.state == PREUZETA

ON partial_combination:
  DISPLAY actual_values
  DO_NOT_AUTOFILL missing_business_state
```

### 4.6 Submission evidence — `OPC-OD-STA-006`

```text
CONFIRM ZAHTEV_PREDAT REQUIRES:
  business_submission_date = mandatory_user_input
  opc_confirmation_timestamp = automatic_system_time

IF business_submission_date invalid_or_missing:
  REJECT completion_confirmation

NEVER manually_edit opc_confirmation_timestamp
NEVER substitute business_date_for_opc_timestamp
ON partial_persistence_failure:
  DO_NOT_SHOW executed
```

### 4.7 Completion blocker and correction window — `OPC-OD-STA-007`

```text
BLOCKS_ZAVRSEN(right, obligation, now):
  IF obligation == PREUZETA:
    RETURN TRUE
  IF obligation == IZVRSENA_ZAHTEV_PREDAT:
    IF evidence_invalid OR opc_confirmation_timestamp_missing:
      RETURN TRUE
    RETURN now < opc_confirmation_timestamp + 24h
  RETURN FALSE

NIJE_UTVRDJENO, NE, DA_without_accepted_obligation DO_NOT_BLOCK
business_submission_date DOES_NOT_START correction_window
```

### 4.8 Revocation — `OPC-OD-STA-008`

```text
MAY_REVOKE accepted_obligation

IF executed_confirmation AND now < opc_confirmation_timestamp + 24h:
  MAY_REVOKE confirmation
  IF obligation_not_revoked:
    obligation.state = PREUZETA
    RESET correction_timer

ON reconfirmation:
  SET new_opc_confirmation_timestamp
  START new_24h_window

IF now >= opc_confirmation_timestamp + 24h:
  CLOSE correction_action
  ALLOW ZAVRSEN IF no_other_blocker

ALWAYS_APPEND history; NEVER_OVERWRITE evidence
```

### 4.9 Military honors — `OPC-OD-STA-009`

```text
military_honors IN [DA, NE]

IF military_honors == DA:
  SEND authoritative_fact_to CEREMONIJA
  CEREMONIJA may_offer explicit_acceptance_and_execution
ELSE:
  DO_NOT_CREATE new_possible_obligation
  HANDLE existing_obligation_with_source_change_rules(OPC-OD-CER-007)
```

### 4.10 Remove free note — `OPC-OD-STA-010`

```text
AFTER structured_replacement_is_authorized_and_migrated:
  REMOVE field_ui NAPOMENA_RADNI_STATUS
  DO_NOT_ADD generic_replacement_note

legacy_note_migration = OWNER_DECISION_STILL_REQUIRED
UNTIL decided:
  NEVER_DELETE existing_note_content
```

### 4.11 POSTCEREMONIJALNI TOK — `OPC-OD-STA-011`

```text
POSTCEREMONIJALNI_TOK = overlapping_derived_category
ORDER items BY active_unfinished_first, completed_second
SHOW history

PREDMET remains_in SVE
PREDMET remains_in current_status_category
PREDMET MAY_ALSO_APPEAR_IN POSTCEREMONIJALNI_TOK
DO_NOT_CREATE new_status_or_new_predmet

IF membership_unresolved:
  KEEP authoritative_status_membership
  SHOW unresolved_reason_in_derived_category
```

## 5. CEREMONIJA

### 5.1 Facts — `OPC-OD-CER-001`

```text
CURRENT_FACTS include cemetery, cemetery_type, ceremony_type,
  ceremony_datetime, opelo, opelo_place, opelo_time, departure_time,
  grave_or_urn_facts, international_funeral, reception_place, reception_time

FUTURE_INPUT += military_honors_DA_NE from STATUSI

IF facts invalid_or_contradictory:
  DO_NOT_INFER completed_obligation
  ROUTE_TO CEREMONIJA_or_STATUSI_source
```

### 5.2 Possible obligations — `OPC-OD-CER-002`

```text
IF OPELO == DA:
  POSSIBLE obligation CONFIRM_SVESTENIK_JE_OBAVESTEN

IF VOJNE_POCASTI == DA:
  POSSIBLE obligation CONFIRM_VOJNE_POCASTI_SU_PRIJAVLJENE

IF OPELO_U_CRKVI == DA AND TIP_GROBLJA == GRADSKO:
  POSSIBLE obligation CONFIRM_CRKVA_JE_POTVRDILA_DA_JE_TERMIN_ZA_OPELO_SLOBODAN

IF either_source_condition_becomes_false:
  APPLY source_change_rules(OPC-OD-CER-007)
```

### 5.3 Possibility, acceptance, execution — `OPC-OD-CER-003`

```text
source_condition => obligation_is_possible_only
possible DOES_NOT_IMPLY accepted
accepted DOES_NOT_IMPLY executed

FIRMA must_explicitly_accept
USER must_explicitly_confirm_execution
partial_action remains_actual_partial_state
```

### 5.4 Execution time — `OPC-OD-CER-004`

```text
ON valid_execution_confirmation:
  SET opc_execution_timestamp = automatic_system_time
  DO_NOT_REQUEST manual_real_action_date

IF timestamp_missing_or_invalid:
  execution_confirmation = INVALID_INCOMPLETE
```

### 5.5 ZAVRŠEN effect — `OPC-OD-CER-005`

```text
IF preceremony_obligation.accepted AND NOT executed:
  BLOCK ZAVRSEN

preceremony_obligation alone DOES_NOT_ADD POSTCEREMONIJALNI_TOK membership
```

### 5.6 Option B cutoff — `OPC-OD-CER-006`

```text
IF obligation.executed:
  BLOCKS_ZAVRSEN UNTIL ceremony.datetime + 24h
  MAY_REVOKE execution_confirmation BEFORE cutoff
  ALWAYS_APPEND history

IF ceremony.datetime missing_or_invalid:
  KEEP_BLOCKING
  ROUTE_TO CEREMONIJA
```

### 5.7 Source-condition change — `OPC-OD-CER-007`

```text
ON source_condition_becomes_false:
  IF obligation.possible AND NOT accepted:
    REMOVE possible_obligation
  ELSE IF accepted AND NOT executed:
    CLOSE_AS cancelled_due_to_source_change
    APPEND history
  ELSE IF executed:
    CREATE cancellation_obligation
    PRESERVE original_history

IF change_is_contradictory_or_partial:
  PRESERVE all_records
  REQUIRE source_review
```

### 5.8 Cancellation evidence — `OPC-OD-CER-008`

```text
IF cancellation_succeeded:
  cancellation.result = OTKAZIVANJE_IZVRSENO_DA
  cancellation.timestamp = automatic_system_time

IF cancellation_failed:
  cancellation.result = POKUSANO_OTKAZIVANJE
  cancellation.attempt_timestamp = automatic_system_time
  REQUIRE mandatory_reason
  CLOSE cancellation_flow

IF mandatory_reason_missing OR persistence_failed:
  DO_NOT_SHOW successfully_closed_result

ALWAYS_PRESERVE history
```

### 5.9 Ceremony datetime change — `OPC-OD-CER-009`

```text
ON request_change(ceremony.datetime):
  REQUIRE event_choice IN [CEREMONY_CANCELLED, FAMILY_ABANDONED, NEW_DATE]

  IF no_choice:
    DO_NOT_FINALIZE change

  IF CEREMONY_CANCELLED OR FAMILY_ABANDONED:
    MARK old_event inactive
    CANCEL unexecuted_obligations
    CREATE cancellation_obligations_for executed_obligations

  IF NEW_DATE:
    VALIDATE new_datetime
    IF invalid: DO_NOT_MAKE_AUTHORITATIVE
    ELSE:
      REPLACE old_event_with_linked_new_authoritative_event
      REEVALUATE source_conditions
      LINK old_and_new_obligations_and_cancellations
      PRESERVE history
```

### 5.10 IRIU dependency correction debt — `OPC-OD-CER-010`

```text
OWNER_APPROVED_FUTURE_GROUPING:
  SAHRANA_VAN_SRBIJE -> [MEDJUNARODNI_PREVOZ, MEDJUNARODNA_DOKUMENTACIJA]
  DOCEK_POSMRTNIH_OSTATAKA -> [BALSAMOVANJE, CARGO_TROSKOVI]

CURRENT_SOURCE_GROUPING:
  SAHRANA_VAN_SRBIJE -> [MEDJUNARODNI_PREVOZ, MEDJUNARODNA_DOKUMENTACIJA, BALSAMOVANJE]
  DOCEK_POSMRTNIH_OSTATAKA -> [CARGO_TROSKOVI]
  disabled_source_rows remain stored_but_suppressed_or_inactive

CLASSIFY KNOWN_CORRECTION_DEBT
DO_NOT_FIX_IN_THIS_TASK

accepted_or_executed_IRIU_source_change_lifecycle
  = OWNER_DECISION_STILL_REQUIRED
```

### 5.11 PARTE — `OPC-OD-CER-011`

```text
PARTE reads ceremony facts as derivative_output
PARTE DOES_NOT_OWN ceremony facts
THIS_DECISION_SET DOES_NOT_CHANGE PARTE behavior

IF source_fact_missing_or_invalid:
  DO_NOT_INVENT value_in_PARTE
```

## 6. Cross-segment readiness

### 6.1 Derived final departure — `OPC-OD-XSG-001`

```text
final_vehicle_departure_readiness = DERIVE(all_authoritative_source_conditions)
NOT manual_checklist
NOT owned_by_one_segment
NOT owned_by_PODSETNIK
```

### 6.2 No override — `OPC-OD-XSG-002`

```text
IF any_condition missing OR unresolved OR contradictory OR invalid
   OR unexecuted OR invalidated:
  readiness = NIJE_SPREMNO
  SHOW concrete_blocker
  ROUTE user_to_authoritative_source

FORBID manual_override
```

### 6.3 Reception stage one — `OPC-OD-XSG-003`

```text
reception_readiness REQUIRES:
  valid reception.datetime
  reception.datetime < ceremony.datetime
  all_reception_conditions_and_obligations_closed

IF reception.datetime missing_or_invalid OR temporal_order_invalid:
  reception_readiness = NIJE_SPREMNO
  final_departure_readiness = NIJE_SPREMNO
```

### 6.4 Reception completion — `OPC-OD-XSG-004`

```text
ON explicit_manual_confirmation(reception_completed):
  SET opc_reception_completion_timestamp = automatic_system_time

notification_event DOES_NOT_COMPLETE reception
ON persistence_failure: DO_NOT_SHOW completed
```

### 6.5 Stage two — `OPC-OD-XSG-005`

```text
final_departure_readiness = SPREMNO ONLY_IF:
  stage_one_closed
  AND reception_explicitly_confirmed
  AND ceremony_conditions_closed
  AND IRIU_conditions_closed
  AND cross_segment_conditions_closed
  AND no_blocker
```

### 6.6 Deliberately unresolved matrix — `OPC-OD-XSG-006`

```text
NEXT_OWNER_PASS = ROBA_I_USLUGE_IRIU
MUST_DECIDE:
  complete_reception_and_departure_condition_set
  accepted_and_executed_IRIU_lifecycle_on_source_change
  IRIU_execution_confirmation_revocation_and_history
  blockers_for_ZAVRSEN_reception_and_departure
  timing_fallback_for_delay_partial_reception_and_reschedule
  package_degradation_behavior
  history_for_replaced_suppressed_cancelled_IRIU_rows
  international_transport_handling
  international_documentation_handling
  balsamovanje_handling
  cargo_costs_handling
  vehicle_and_equipment_readiness
  any_additional_source_segments_discovered_later

UNTIL_THEN:
  DO_NOT_INVENT full_readiness_matrix
```

## 7. Validation boundary

```text
THIS_TASK MAY:
  document
  classify current_vs_future
  create stable decision_ids
  record conflicts_and_unknowns

THIS_TASK MUST_NOT:
  edit production_Dart
  edit schema_or_JSON
  change status_transitions
  change STATUSI_CEREMONIJA_PODSETNIK_IRIU_behavior
  create future_behavior_tests
  build_or_run_runtime_smoke
```
