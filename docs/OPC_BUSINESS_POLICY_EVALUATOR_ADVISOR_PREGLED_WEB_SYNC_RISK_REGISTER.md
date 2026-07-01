# OPC Business Policy Evaluator Advisor Pregled Web Sync Risk Register

Status: docs-only Web/sync readiness risk register.

Base commit: `ea9ba1a96ba7c8f6db43921cb5421d71f3c82a03`

This register records risks for future Web/sync readiness without choosing architecture or implementation. It does not authorize Web/backend/API/sync/storage/payment/licensing/entitlement/role changes.

## RISK-ID: OPC-BPEAP-WEB-001

Risk: evaluator snapshot is treated as persistent master truth.
Current evidence: evaluator snapshot is derived in source from PREDMET facts and not directly persisted by `BusinessPolicyEvaluator`.
Boundary: PREDMET remains master truth; evaluator output remains derived.
Classification: `SOURCE-CONFIRMED / DOCUMENTED POLICY`.

## RISK-ID: OPC-BPEAP-WEB-002

Risk: IRiU truth rows or reason strings become sync authority.
Current evidence: `PredmetIriuTruthService` derives truth rows and reasons from stored IRiU rows plus current PREDMET facts.
Boundary: stored PREDMET and IRiU rows are source data; derived truth classifications are not independent authority.
Classification: `SOURCE-CONFIRMED`.

## RISK-ID: OPC-BPEAP-WEB-003

Risk: advisor/guidance is assumed implemented during Web design.
Current evidence: no complete advisor engine, consolidated checklist, or warning taxonomy was found.
Boundary: advisor remains partial/policy gap until owner-approved implementation exists.
Classification: `POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## RISK-ID: OPC-BPEAP-WEB-004

Risk: package or payment gates alter business truth.
Current evidence: `OpcModule.businessPolicyScenario` is core-available; STANJE ROBE, advanced PARTA, CITULJE, documents, and JSON have separate availability gates.
Boundary: entitlement may control feature availability, but must not mutate PREDMET truth or redefine evaluator facts.
Classification: `SOURCE-CONFIRMED / OWNER REVIEW QUEUE`.

## RISK-ID: OPC-BPEAP-WEB-005

Risk: `Pregled i potvrda` becomes Web conflict authority without full evidence.
Current evidence: current Pregled displays status, version, saved state, and lifecycle actions only.
Boundary: current Pregled is not a full advisor, change-log overview, or sync conflict review model.
Classification: `SOURCE-CONFIRMED / IMPLEMENTATION GAP`.

## RISK-ID: OPC-BPEAP-WEB-006

Risk: local lifecycle plans are synced as mandatory remote actions.
Current evidence: Blok 2 and death-place lifecycle services produce plans, conflicts, and confirmation lists from current local state.
Boundary: lifecycle plans are derived from source state and user-resolution context; future sync must not replay them as independent commands without architecture approval.
Classification: `SOURCE-CONFIRMED / IMPLEMENTATION BLOCKED`.

## RISK-ID: OPC-BPEAP-WEB-007

Risk: finance totals drift from stale evaluator/IRiU truth in a synced environment.
Current evidence: finance derives `robaIUsluge` from current IRiU truth snapshot.
Boundary: future sync must preserve source row freshness before deriving totals; current local characterization does not define sync freshness.
Classification: `SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## RISK-ID: OPC-BPEAP-WEB-008

Risk: platform-specific advisor behavior appears between Windows, Android, and future Web.
Current evidence: source is shared Dart for current Windows/Android lanes, but runtime parity was not executed.
Boundary: source inspection is not runtime parity evidence, and Web behavior is not implemented.
Classification: `RUNTIME GAP / IMPLEMENTATION BLOCKED`.

## RISK-ID: OPC-BPEAP-WEB-009

Risk: Web/backend/API/sync/storage/payment/licensing/role architecture is inferred from evaluator characterization.
Current evidence: this task is docs-only characterization; implementation stop-list blocks those areas.
Boundary: no Web/backend/API/sync/storage/payment/licensing/role architecture is selected.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.
