# OPC Business Policy Evaluator Completion Matrix

Status: public docs-only completion matrix.

Base commit: `a86907a2264ddf68e27812cbbd49a3fad985e5a7`

This matrix records what is implemented, partial, policy-only, missing, and test-confirmed for the business policy evaluator family.

## State Legend

| State | Meaning |
| --- | --- |
| IMPLEMENTED | Source-confirmed behavior exists. |
| PARTIAL | Some behavior exists, but the full expected business capability is not complete. |
| POLICY-ONLY | Business need exists in baseline context, but evaluator implementation was not found. |
| MISSING | No matching evaluator implementation found. |
| TEST-CONFIRMED | Dedicated test evidence found. |
| TEST GAP | No dedicated scenario test found during this audit. |

## Evaluator Source Areas

| Area | Primary source | State | Test state | Notes |
| --- | --- | --- | --- | --- |
| Evaluator input/snapshot | `business_policy_evaluator.dart`, `business_policy_models.dart` | IMPLEMENTED | TEST GAP | Core flags exist, but not a complete advisor contract. |
| Scenario id | `business_scenario_id.dart` | IMPLEMENTED | TEST GAP | Only default funeral ceremony policy exists. |
| IRiU truth | `iriu_truth_rules.dart`, `predmet_iriu_truth_service.dart` | IMPLEMENTED | PARTIAL | Strong policy engine for IRiU categories. |
| Blok 2 lifecycle | `blok2_iriu_lifecycle_service.dart` | IMPLEMENTED | TEST-CONFIRMED | Critical grobnica/grob/cremation/override flows are tested. |
| Death-place lifecycle | `mesto_smrti_iriu_lifecycle_service.dart` | IMPLEMENTED | TEST GAP | Needs dedicated transition matrix. |
| Financial truth | `financial_truth_service.dart` | PARTIAL | TEST GAP | Counts/excludes rows, but not full finance guidance. |
| STANJE ROBE relation | Inventory/lifecycle services | PARTIAL | TEST GAP | Downstream consequence, not evaluator-owned. |
| Ceremony UI guidance | PREDMET UI segments | PARTIAL | TEST GAP | UI has fields/conditionals; no unified advisor output. |
| PIO/refund | Finance/PREDMET context | POLICY-ONLY | TEST GAP | Not evaluator input/output. |
| JKP/Platilac | Finance/document context | POLICY-ONLY | TEST GAP | Not evaluator input/output. |
| PDF/document requirements | PDF builders and derivative row rules | PARTIAL | TEST GAP | Outputs exist, no complete evaluator requirement graph. |
| Review checklist | Review/Pregled context | MISSING | TEST GAP | No evaluator-owned warnings/checklist found. |
| Version/log/change summary | Prior version owner decision docs | POLICY-ONLY | TEST GAP | Not integrated into evaluator. |
| Web/sync deterministic contract | Future architecture area | MISSING | TEST GAP | Not authorized. |

## Implemented Evaluator Areas

| Area | Implemented facts |
| --- | --- |
| Input extraction | Converts PREDMET fields into policy input. |
| Death-place normalization | Trims and maps `ULICA` / `JAVNO MESTO` to `ULICA / JAVNO MESTO`. |
| Key flags | Cremation, hospital death, local/city cemetery, international case, reception of remains, override cause, biohazard precondition. |
| IRiU active/suppressed state | Uses evaluator snapshot to classify rows. |
| IRiU recommendation state | Adds/recommends managed categories under current conditions. |
| User-resolution state | Marks condition-managed rows that require user resolution after condition changes. |
| Financial inclusion/exclusion | Counts only active positive rows; excludes suppressed and non-positive rows. |

## Partially Implemented Areas

| Area | Why partial |
| --- | --- |
| Ceremony guidance | Current logic drives some IRiU consequences, but not a complete ceremony advisor. |
| Financial policy | IRiU financial truth exists, but payer/refund/JKP guidance is not evaluator-owned. |
| Document policy | PDF outputs and document-scoped row exclusions exist, but not a complete document requirement model. |
| STANJE ROBE policy | Inventory effects exist downstream, but not as evaluator outputs. |
| Review/confirmation | Managed-row conflicts exist, but no full case-review checklist exists. |

## Policy-Only or Missing Areas

| Area | State | Required before implementation |
| --- | --- | --- |
| PIO/refund evaluator guidance | POLICY-ONLY | Owner decision and technical audit. |
| JKP/payer evaluator guidance | POLICY-ONLY | Owner decision and finance/document audit. |
| Complete ceremony advisor | MISSING | Business wording, mandatory/advisory classification, tests. |
| Document requirement graph | MISSING as evaluator output | Decide ownership between evaluator, PDF, or separate document policy model. |
| Web/sync policy contract | MISSING | Stable input/output schema and scenario tests. |

## Test-Confirmed Areas

| Area | Test evidence |
| --- | --- |
| Non-cremation grobnica requires `LIMENI_ULOZAK` and `LEMOVANJE` | `business_policy_iriu_critical_scenarios_test.dart` |
| Override causes keep Blok 2 requirements for grob | `business_policy_iriu_critical_scenarios_test.dart` |
| Cremation excludes Blok 2 limeni/lemovanje for grobnica | `business_policy_iriu_critical_scenarios_test.dart` |
| Grobnica to grob transition requires removal confirmation | `business_policy_iriu_critical_scenarios_test.dart` |
| Grob to grobnica transition requires add confirmation | `business_policy_iriu_critical_scenarios_test.dart` |
| Dismissed Blok 2 categories are not silently re-added | `business_policy_iriu_critical_scenarios_test.dart` |

## Runtime Gaps

| Gap | Consequence |
| --- | --- |
| No complete evaluator-owned warning checklist | Users may not receive one consolidated "what must be reviewed" output. |
| No stable public scenario contract beyond default id | Future Web/API/sync work lacks deterministic rule boundary. |
| Finance/document/stock consequences are spread across services | Rule changes can have broad effects unless scenario tests are expanded. |
| PIO/refund and JKP/payer are not evaluator inputs | Financially important guidance may remain outside policy automation. |

## Owner Decision Gaps

| Decision | Why needed |
| --- | --- |
| Evaluator scope: low-level snapshot or full advisor | Determines architecture and test contracts. |
| Mandatory vs advisory warnings | Required for UI wording and user-resolution behavior. |
| PIO/refund and JKP/payer ownership | Determines input schema and finance/document impact. |
| Document requirement ownership | Prevents PDF builders from becoming hidden policy engines. |
| Public scenario ids | Needed before Web/sync/API parity. |

## Recommended Sequencing

1. Freeze this matrix as the public baseline for evaluator work.
2. Add scenario tests for death-place, international/reception, finance truth, and derivative exclusions.
3. Obtain owner decision on evaluator scope and mandatory/advisory warning taxonomy.
4. Audit PIO/refund and JKP/payer logic before adding them to evaluator inputs.
5. Only after that, design a ceremony guidance output contract.

