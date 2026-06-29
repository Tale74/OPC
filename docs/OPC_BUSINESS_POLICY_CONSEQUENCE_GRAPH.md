# OPC Business Policy Consequence Graph

Status: public docs-only consequence graph.

Base commit: `a86907a2264ddf68e27812cbbd49a3fad985e5a7`

This graph maps current policy triggers to known consequences and gaps. It is not an implementation design and does not authorize behavior changes.

## Legend

| Label | Meaning |
| --- | --- |
| SOURCE-CONFIRMED | Source inspection confirms the edge. |
| PARTIAL | Consequence exists outside a complete evaluator-owned graph. |
| MISSING | Required or expected guidance was not found as implemented evaluator output. |
| TECHNICAL AUDIT REQUIRED | Needs separate technical review before implementation. |

## Graph Table

| Trigger | Policy condition | Immediate evaluator / rule result | Downstream consequence | Target area | Status |
| --- | --- | --- | --- | --- | --- |
| `businessScenarioId` empty/unknown | Scenario resolution | Default funeral ceremony policy | Current condition families apply | Evaluator | SOURCE-CONFIRMED |
| `mestoSmrti == STAN` | Non-hospital death place | Normalized death place; hospital false | Death-place managed services active | IRiU | SOURCE-CONFIRMED |
| `mestoSmrti == DOM ZA STARE` | Non-hospital death place | Normalized death place; hospital false | Death-place managed services active | IRiU | SOURCE-CONFIRMED |
| `mestoSmrti == ULICA` or `JAVNO MESTO` | Public-place death | Normalized to `ULICA / JAVNO MESTO` | Death-place managed services active | IRiU | SOURCE-CONFIRMED |
| `mestoSmrti == DRUGO` | Other non-hospital death place | Normalized death place; hospital false | Death-place managed services active | IRiU | SOURCE-CONFIRMED |
| `mestoSmrti == BOLNICA` | Hospital death | `isHospitalDeath == true` | `PREVOZ_DO_GROBLJA` active; other non-hospital death-place services not active | IRiU | SOURCE-CONFIRMED |
| `vrstaCeremonije == KREMACIJA` / `KREMACIJA_EKSPRES` | Cremation | `isKremacija == true` | `LIMENI_ULOZAK` and `LEMOVANJE` not recommended by current Blok 2 rule | IRiU | SOURCE-CONFIRMED |
| Non-cremation + `GROBNICA` | Existing tomb/grobnica | `isKremacija == false` | `LIMENI_ULOZAK`, `LEMOVANJE` recommended/inserted/confirmed | IRiU / lifecycle | SOURCE-CONFIRMED |
| `uzrokSmrti` override | `NASILNA`, `ZARAZNA`, `NEDEFINISANA` | `hasUzrokSmrtiOverride == true` | `LIMENI_ULOZAK`, `LEMOVANJE` recommended when non-cremation | IRiU | SOURCE-CONFIRMED |
| `uzrokSmrti == ZARAZNA` + non-hospital known death place | Infectious non-hospital case | `requiresBiohazardPrecautions == true` | `SPREMANJE_POKOJNIKA` row marked biohazard | IRiU | SOURCE-CONFIRMED |
| `tipGroblja == LOKALNO` | Local cemetery | `isLocalCemetery == true` | `PREVOZ_SPROVODA` recommended/active | IRiU | SOURCE-CONFIRMED |
| `tipGroblja == GRADSKO` | City cemetery | `isGradskoCemetery == true` | No local `PREVOZ_SPROVODA` recommendation by current rule | IRiU | SOURCE-CONFIRMED |
| `sahranaVanSrbije == true` | International case | `isInternationalCase == true` | International transport, documentation, embalming active | IRiU / finance / documents | SOURCE-CONFIRMED / PARTIAL |
| `docekPosmrtnihOstataka == true` | Reception of remains | `hasReceptionOfRemains == true` | `CARGO_TROSKOVI` active | IRiU / finance | SOURCE-CONFIRMED |
| Managed row inactive under current condition | Condition changed | Row suppressed; may require resolution | Excluded from finance and may require user decision | IRiU / finance / review | SOURCE-CONFIRMED |
| Active row amount > 0 | Financial inclusion | Counts for financial truth | Included in `ROBA I USLUGE` total | Finance | SOURCE-CONFIRMED |
| Active row amount <= 0 | Non-positive amount | Excluded non-positive amount | Not counted in financial truth | Finance | SOURCE-CONFIRMED |
| `CITULJA_POLITIKA` / `CITULJA_NOVOSTI` | Document-scoped categories | Derivative exclusion | Not treated as ordinary derivative financial/service truth | Documents / finance | SOURCE-CONFIRMED |
| Selected IRiU item with stock relevance | Goods/service chosen | Not direct evaluator output | STANJE ROBE consequence / unresolved stock relation | Inventory | PARTIAL |
| PIO/refund facts | Pension/refund policy | Not evaluator input | Potential refund/finance guidance | Finance / documents | MISSING |
| Payer / JKP facts | Payer/municipality policy | Not evaluator input | Potential payment/document guidance | Finance / documents | MISSING |
| Opelo/ispracaj facts | Ceremony detail policy | Not evaluator input except ceremony type | UI/PDF details, possible ceremony guidance | UI / documents | PARTIAL |
| Review checklist | Case-review policy | Not evaluator output | User-facing warnings and next actions | Review UI | MISSING |

## Consequences by Trigger Family

| Family | Implemented consequence | Missing / unclear consequence |
| --- | --- | --- |
| Death place | Auto-managed service categories and condition-change conflicts. | Complete user-facing guidance and full scenario tests. |
| Ceremony type | Cremation flag and Blok 2 exclusion. | Full ceremony advisor and opelo/ispracaj guidance. |
| Cause of death | Override cause and infectious biohazard signal. | Mandatory warning/checklist definition. |
| Cemetery/grob | Blok 2 and local cemetery service rules. | Full financial/document/stock regression matrix. |
| International/reception | Active international/cargo categories. | Document requirements and advisor guidance. |
| PIO/refund | None in evaluator. | Owner decision and technical audit. |
| JKP/payer | None in evaluator. | Owner decision and technical audit. |

## Consequences by Target

| Target | Current evaluator relation |
| --- | --- |
| IRiU | Strongest implemented target. |
| Finance | Implemented through IRiU truth inclusion/exclusion, not a standalone evaluator domain. |
| STANJE ROBE | Downstream partial relation; not evaluator-owned. |
| PDF/documents | Downstream relation; no complete evaluator document graph found. |
| Review/checklist | Missing as evaluator-owned output. |
| Web/sync/API | Not authorized and not contract-ready. |

## Highest-Risk Missing Guidance

1. Infectious non-hospital cases need explicit user-facing warning/checklist design.
2. PIO/refund and JKP/payer financial guidance are not evaluator-owned.
3. Document requirements are fragmented between UI/PDF/output logic.
4. Stock consequences are downstream and must not silently become parallel PREDMET truth.
5. Scenario tests do not yet cover all condition families.

