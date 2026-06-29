# OPC Business Policy Scenario Matrix

Status: public docs-only scenario matrix.

Base commit: `a86907a2264ddf68e27812cbbd49a3fad985e5a7`

This matrix records implemented, partial, and missing business-policy scenarios found during the evaluator deep audit. It is evidence only and does not authorize behavior changes.

## State Legend

| Label | Meaning |
| --- | --- |
| IMPLEMENTED | Source-confirmed runtime consequence exists. |
| PARTIAL | Some consequence exists, but not a complete evaluator/advisor scenario. |
| POLICY-ONLY | Business policy exists in baseline context, but evaluator implementation was not found. |
| TEST-CONFIRMED | Dedicated test evidence was found. |
| TEST GAP | Dedicated scenario coverage was not confirmed. |

## Matrix

| Scenario ID | Scenario | Inputs / trigger | Evaluator snapshot | Consequence targets | Runtime state | Test state | Risk / gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| OPC-SCENARIO-001 | Default funeral ceremony policy | Empty, unknown, or default `businessScenarioId` | Resolves to `default_funeral_ceremony_policy` | All current evaluator condition families | IMPLEMENTED | TEST GAP for scenario resolution | Only one named scenario exists; practical scenarios are condition-driven. |
| OPC-SCENARIO-002 | Non-cremation grobnica | `tipGrobnogMesta == GROBNICA` and not cremation | `isKremacija == false` | `LIMENI_ULOZAK`, `LEMOVANJE` | IMPLEMENTED | TEST-CONFIRMED | Must preserve confirmation and dismissed-category behavior. |
| OPC-SCENARIO-003 | Cremation excludes limeni/lemovanje | `vrstaCeremonije == KREMACIJA` or `KREMACIJA_EKSPRES` | `isKremacija == true` | `LIMENI_ULOZAK`, `LEMOVANJE` suppressed/not recommended | IMPLEMENTED | TEST-CONFIRMED | Future rules must not add coffin-related services silently. |
| OPC-SCENARIO-004 | Override cause of death | `uzrokSmrti` in `NASILNA`, `ZARAZNA`, `NEDEFINISANA` | `hasUzrokSmrtiOverride == true` | `LIMENI_ULOZAK`, `LEMOVANJE`; biohazard when infectious and non-hospital | IMPLEMENTED | TEST-CONFIRMED for Blok 2; TEST GAP for full biohazard flow | Infectious non-hospital guidance needs explicit checklist coverage. |
| OPC-SCENARIO-005 | Death outside hospital | `mestoSmrti` in `STAN`, `DOM ZA STARE`, `ULICA`, `JAVNO MESTO`, `DRUGO` | Normalized death place; hospital false | `HLADNJACA`, `SPREMANJE_POKOJNIKA`, `IZNOSENJE`, `PREVOZ_DO_HLADNJACE`, `TRANSPORTNA_VRECA`, `PREVOZ_DO_GROBLJA` | IMPLEMENTED | TEST GAP | Needs comprehensive transition tests across death-place changes. |
| OPC-SCENARIO-006 | Hospital death | `mestoSmrti == BOLNICA` | `isHospitalDeath == true` | `PREVOZ_DO_GROBLJA` from death-place managed set | IMPLEMENTED | TEST GAP | Suppression of non-hospital services needs regression tests. |
| OPC-SCENARIO-007 | Local cemetery | `tipGroblja == LOKALNO` | `isLocalCemetery == true` | `PREVOZ_SPROVODA` recommended/active | IMPLEMENTED | TEST GAP | Financial/PDF/stock consequences need coverage. |
| OPC-SCENARIO-008 | City cemetery | `tipGroblja == GRADSKO` | `isGradskoCemetery == true` | No local `PREVOZ_SPROVODA` recommendation by current rule | IMPLEMENTED | TEST GAP | Needs explicit city-vs-local scenario test. |
| OPC-SCENARIO-009 | International burial | `sahranaVanSrbije == true` | `isInternationalCase == true` | `MEDJUNARODNI_PREVOZ`, `MEDJUNARODNA_DOKUMENTACIJA`, `BALSAMOVANJE` active | IMPLEMENTED | TEST GAP | Document and financial guidance should be tested before automation. |
| OPC-SCENARIO-010 | Reception of remains | `docekPosmrtnihOstataka == true` | `hasReceptionOfRemains == true` | `CARGO_TROSKOVI` active | IMPLEMENTED | TEST GAP | Needs finance/document consequence tests. |
| OPC-SCENARIO-011 | Serbian pensioner / refund | PIO/refund-related facts | Not evaluator input | Refund/finance/document guidance | POLICY-ONLY | TEST GAP | Missing from evaluator; owner decision needed. |
| OPC-SCENARIO-012 | Platilac / JKP relation | Payer and JKP business facts | Not evaluator input | Finance, collection, document labels | POLICY-ONLY | TEST GAP | Missing from evaluator; needs dedicated finance/payer audit. |
| OPC-SCENARIO-013 | Opelo / ispracaj ceremony details | Ceremony UI/PDF facts | Not evaluator input except ceremony type | UI/PDF visibility and document details | PARTIAL | TEST GAP | No complete evaluator-owned ceremony guidance found. |
| OPC-SCENARIO-014 | Citulje and derivative-only rows | `CITULJA_POLITIKA`, `CITULJA_NOVOSTI` IRiU rows | Evaluated through row truth | Derivative/document-scoped exclusions | IMPLEMENTED | TEST GAP | Must not be counted as ordinary financial/service truth without explicit rule. |
| OPC-SCENARIO-015 | Grobnica to grob condition change | Previous active Blok 2 row becomes inactive | Current snapshot no longer supports row | User-resolution conflict | IMPLEMENTED | TEST-CONFIRMED | User confirmation must remain explicit. |
| OPC-SCENARIO-016 | Grob to grobnica condition change | Current condition newly requires Blok 2 categories | Current snapshot supports row | Additions requiring confirmation | IMPLEMENTED | TEST-CONFIRMED | Dismissed categories must not be silently re-added. |
| OPC-SCENARIO-017 | Inactive managed row with amount | Condition no longer supports row | Row suppressed | Financial exclusion and user-resolution state | IMPLEMENTED | TEST GAP | Finance regression tests needed. |
| OPC-SCENARIO-018 | Active row with positive amount | Active row and amount > 0 | Row active | Counts for financial truth | IMPLEMENTED | TEST GAP | Totals need scenario regression coverage. |

## Summary

The current scenario model is not a multi-scenario rule engine. It is a default scenario with several condition families. Before Web/sync/API or broad advisor work, these condition families should be converted into stable, tested scenario contracts.

