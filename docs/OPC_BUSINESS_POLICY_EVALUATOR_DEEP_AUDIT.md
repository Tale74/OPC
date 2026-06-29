# OPC Business Policy Evaluator Deep Audit

Status: public docs-only audit baseline.

Base commit: `a86907a2264ddf68e27812cbbd49a3fad985e5a7`

Scope: conditions, scenarios, consequences, and ceremony-guidance logic around the current business policy evaluator. This document is evidence and risk mapping only. It is not an implementation specification and does not authorize source, database, Web, API, sync, storage, PDF, JSON, finance, import, backup/restore, role, entitlement, licensing, UI, or test behavior changes.

## 1. Purpose and Scope

This audit answers one narrow question: what business policy intelligence exists today around `PREDMET`, which conditions feed it, which consequences are produced, and where the current implementation stops before a complete ceremony guidance evaluator.

The audit does not redo the full PREDMET workflow atlas. It uses that atlas as upstream context and focuses on the evaluator family:

| Area | Included | Excluded |
| --- | --- | --- |
| Evaluator facts | `BusinessPolicyEvaluator`, policy snapshot, scenario id, IRiU truth services, finance truth consequences, lifecycle services, related tests | New implementation design |
| Scenario mapping | Death place, cause of death, ceremony type, cemetery/grob type, international case, reception of remains, IRiU categories | New UI wizard, new rule engine, package restructuring |
| Consequence mapping | Insert/suppress/recommend/confirm/exclude/count/biohazard flags | Changing any consequence |
| Ceremony guidance | Current implemented evidence and missing guidance areas | Creating warning text, assistant flow, or business decisions |

## 2. Evidence Legend

| Label | Meaning |
| --- | --- |
| SOURCE-CONFIRMED | Found in inspected source or tests. |
| PARTIALLY IMPLEMENTED | Some runtime consequence exists, but not the full business-policy capability implied by product direction. |
| POLICY EXISTS / IMPLEMENTATION NOT FOUND | Policy is known from public continuity docs or workflow context, but this audit did not find matching evaluator implementation. |
| UNCLEAR | Evidence is insufficient or needs owner/technical audit. |
| NOT EVALUATOR INPUT | Field exists elsewhere, but is not consumed by the current `BusinessPolicyEvaluator`. |

## 3. Evaluator Role in OPC

The intended product role is larger than validation. The evaluator should eventually support operational intelligence: what a funeral case requires, what is recommended, what must be reviewed, what becomes financially active, and what downstream documents or inventory consequences follow.

The current implementation is narrower:

| Capability | Current state |
| --- | --- |
| Normalize selected PREDMET facts into policy snapshot | SOURCE-CONFIRMED |
| Derive key condition flags | SOURCE-CONFIRMED |
| Drive IRiU operational/recommendation/financial truth through services | SOURCE-CONFIRMED |
| Preserve user-resolution requirements on condition changes | SOURCE-CONFIRMED |
| Produce a complete ceremony guidance checklist or advisor flow | POLICY EXISTS / IMPLEMENTATION NOT FOUND |
| Produce direct PIO/refund, JKP/payer, document, or review warnings | POLICY EXISTS / IMPLEMENTATION NOT FOUND |

Conclusion: current evaluator logic is a partial business-policy kernel. It is useful and important, but it is not yet the full ceremony guidance evaluator the product needs before larger Web/sync or automation work.

## 4. Evaluator Source Map

| Source | Role | Evidence status |
| --- | --- | --- |
| `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart` | Converts `PredmetiData` into `PredmetBusinessPolicyInput` and `PredmetBusinessPolicySnapshot`. | SOURCE-CONFIRMED |
| `lib/features/predmeti/core_v2/business_policy/business_policy_models.dart` | Defines evaluator input, snapshot, and derived flags. | SOURCE-CONFIRMED |
| `lib/features/predmeti/core_v2/business_policy/business_scenario_id.dart` | Defines named scenario ids; currently only default funeral ceremony policy. | SOURCE-CONFIRMED |
| `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart` | Encodes IRiU managed categories, active/suppressed rules, recommendations, financial inclusion, derivative exclusions, and biohazard flag. | SOURCE-CONFIRMED |
| `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart` | Combines evaluator snapshot and stored IRiU rows into row-level truth. | SOURCE-CONFIRMED |
| `lib/features/predmeti/core_v2/services/mesto_smrti_iriu_lifecycle_service.dart` | Plans death-place IRiU inserts and condition-change conflicts. | SOURCE-CONFIRMED |
| `lib/features/predmeti/core_v2/services/blok2_iriu_lifecycle_service.dart` | Plans Blok 2 inserts, additions requiring confirmation, and conflicts. | SOURCE-CONFIRMED |
| `lib/features/predmeti/core_v2/services/financial_truth_service.dart` | Converts IRiU truth rows into financial truth inclusion/exclusion. | SOURCE-CONFIRMED |
| `test/business_policy_iriu_critical_scenarios_test.dart` | Tests core Blok 2 policy consequences and confirmation behavior. | SOURCE-CONFIRMED |
| PREDMET UI segments and PDF builders | Store/display/export related facts; not all are evaluator inputs. | PARTIALLY IMPLEMENTED / NOT EVALUATOR INPUT |

## 5. Evaluator Input Facts

| Fact group | Current facts | Current evaluator use |
| --- | --- | --- |
| PREDMET identity | `predmetId`, `brojPredmeta`, `businessScenarioId` | Used for reference and scenario resolution. Unknown or empty scenario resolves to default. |
| Death facts | `mestoSmrti`, `uzrokSmrti` | Used for normalized death place, hospital flag, override-cause flag, biohazard precondition, and death-place IRiU rules. |
| Ceremony facts | `vrstaCeremonije` | Used to derive cremation flag. |
| Cemetery/grob facts | `groblje`, `tipGroblja`, `tipGrobnogMesta` | Used for local/city cemetery flags and Blok 2 recommendations such as `LIMENI_ULOZAK`, `LEMOVANJE`, and `PREVOZ_SPROVODA`. |
| International/reception facts | `sahranaVanSrbije`, `docekPosmrtnihOstataka` | Used for international categories and cargo costs activity through IRiU truth rules. |
| IRiU stored rows | Internal name, amount, order, manual rows | Not raw evaluator input, but consumed by `PredmetIriuTruthService` using evaluator snapshot. |
| PIO/refund facts | Pension/refund-related fields outside evaluator | NOT EVALUATOR INPUT. Finance/document policy relation exists, but evaluator guidance implementation was not found in this audit. |
| Payer/JKP facts | `PLATILAC`/payer and JKP-related business context | NOT EVALUATOR INPUT. Financial and document consequences may exist elsewhere, but not in the evaluator kernel. |
| Opelo/ispracaj facts | Ceremony UI/PDF-related details | NOT EVALUATOR INPUT for `BusinessPolicyEvaluator`; UI/PDF relation is separate. |
| Review/checklist facts | Pregled i potvrda state, warnings, owner review | POLICY EXISTS / IMPLEMENTATION NOT FOUND as evaluator output. |

## 6. Evaluator Outputs and Consequences

| Output / consequence | Current state |
| --- | --- |
| `normalizedMestoSmrti` | SOURCE-CONFIRMED. Maps `ULICA` and `JAVNO MESTO` to `ULICA / JAVNO MESTO`; trims other values. |
| `isKremacija` | SOURCE-CONFIRMED for `KREMACIJA` and `KREMACIJA_EKSPRES`. |
| `isHospitalDeath` | SOURCE-CONFIRMED when normalized death place is `BOLNICA`. |
| `isLocalCemetery` / `isGradskoCemetery` | SOURCE-CONFIRMED from `tipGroblja`. |
| `isInternationalCase` | SOURCE-CONFIRMED from `sahranaVanSrbije`. |
| `hasReceptionOfRemains` | SOURCE-CONFIRMED from `docekPosmrtnihOstataka`. |
| `hasUzrokSmrtiOverride` | SOURCE-CONFIRMED for `NASILNA`, `ZARAZNA`, `NEDEFINISANA`. |
| `requiresBiohazardPrecautions` | SOURCE-CONFIRMED when cause is `ZARAZNA` and death place is known and not hospital. |
| IRiU operational active/suppressed state | SOURCE-CONFIRMED through `IriuTruthRules.isOperationallyActive`. |
| IRiU recommendation state | SOURCE-CONFIRMED for managed categories. |
| User-resolution requirement | SOURCE-CONFIRMED for inactive condition-managed rows whose policy requires resolution on condition change. |
| Financial inclusion/exclusion | SOURCE-CONFIRMED through `FinancialTruthService` and `IriuTruthRules.countsForFinancialTruth`. |
| Derivative exclusions | SOURCE-CONFIRMED for inactive rows and document-scoped `CITULJA_POLITIKA` / `CITULJA_NOVOSTI`. |
| STANJE ROBE consequences | PARTIALLY IMPLEMENTED through downstream lifecycle/stock services, not direct evaluator output. |
| Ceremony guidance warnings/checklist | POLICY EXISTS / IMPLEMENTATION NOT FOUND as a complete evaluator output. |
| PIO/refund guidance | POLICY EXISTS / IMPLEMENTATION NOT FOUND as evaluator output. |
| JKP/payer guidance | POLICY EXISTS / IMPLEMENTATION NOT FOUND as evaluator output. |
| Document/PDF requirement guidance | PARTIALLY IMPLEMENTED downstream; no complete evaluator guidance graph found. |

## 7. Static Storage vs Evaluator Logic

Static storage holds facts and selected rows. Evaluator logic interprets only a subset of those facts.

| Storage / source | What it owns | Evaluator relation |
| --- | --- | --- |
| `PredmetiData` | Case facts and selected ceremony/cemetery/death fields | Primary evaluator input. |
| IRiU rows | Selected goods/services and stored amounts | Evaluated by `PredmetIriuTruthService`, not by static storage alone. |
| KATALOG / item tables | Catalog truth | Not evaluator-owned; selected IRiU snapshots remain case-visible. |
| STANJE ROBE | Inventory quantities and consequences | Downstream consequence, not alternate PREDMET truth. |
| PDF/export builders | Snapshot/document outputs | Consume case facts and rows; not source of policy truth. |
| JSON transfer | Transfer format | Must not redefine policy truth. |

## 8. Scenario Families

The code contains one named business scenario id: `default_funeral_ceremony_policy`. The practical scenario matrix is therefore condition-driven, not a set of multiple implemented scenario ids.

| Family | Implemented condition evidence | Current evaluator state |
| --- | --- | --- |
| Default funeral ceremony policy | `BusinessScenarioId.defaultFuneralCeremonyPolicy` | SOURCE-CONFIRMED |
| Death place | `STAN`, `DOM ZA STARE`, `ULICA / JAVNO MESTO`, `DRUGO`, `BOLNICA` | SOURCE-CONFIRMED through IRiU rules. |
| Cremation vs non-cremation | `KREMACIJA`, `KREMACIJA_EKSPRES` | SOURCE-CONFIRMED. |
| Grobnica/grob | `tipGrobnogMesta` | SOURCE-CONFIRMED for Blok 2 recommendations. |
| Override cause | `NASILNA`, `ZARAZNA`, `NEDEFINISANA` | SOURCE-CONFIRMED. |
| Local/city cemetery | `tipGroblja` | SOURCE-CONFIRMED for `PREVOZ_SPROVODA` and flags. |
| International burial | `sahranaVanSrbije` | SOURCE-CONFIRMED through international IRiU categories. |
| Reception of remains | `docekPosmrtnihOstataka` | SOURCE-CONFIRMED through `CARGO_TROSKOVI`. |
| Serbian pensioner/refund | Finance/document context | POLICY EXISTS / IMPLEMENTATION NOT FOUND in evaluator. |
| JKP/payer relationship | Finance/document context | POLICY EXISTS / IMPLEMENTATION NOT FOUND in evaluator. |
| Opelo/ispracaj | UI/PDF context | PARTIALLY IMPLEMENTED outside evaluator. |

## 9. Ceremony Guidance Capability

Current state: PARTIALLY IMPLEMENTED.

Implemented:

| Guidance area | Evidence |
| --- | --- |
| Condition-derived IRiU recommendations | `IriuTruthRules.autoManagedMestoSmrtiCategories` and `autoManagedBlok2Categories`. |
| Condition-change conflicts | Mesto smrti and Blok 2 lifecycle services. |
| Biohazard signal | `requiresBiohazardPrecautions` and IRiU row biohazard flag. |
| Financial active/suppressed consequences | `FinancialTruthService`. |

Missing or incomplete:

| Guidance area | Gap |
| --- | --- |
| Full ceremony advisor | No single evaluator output enumerates "what the office must do next". |
| User-facing warnings | No complete evaluator-owned warning checklist found. |
| Document requirement graph | PDF/export outputs exist, but no evaluator-owned requirement model was found. |
| PIO/refund guidance | Not evaluator input/output. |
| JKP/payer guidance | Not evaluator input/output. |
| Review checklist | `Pregled i potvrda` is not yet confirmed as evaluator-backed checklist. |

## 10. IRiU and Service Policy Logic

IRiU is where most implemented evaluator consequences become operational.

| Category family | Trigger | Consequence |
| --- | --- | --- |
| Death-place managed categories | `STAN`, `DOM ZA STARE`, `ULICA / JAVNO MESTO`, `DRUGO` | `HLADNJACA`, `SPREMANJE_POKOJNIKA`, `IZNOSENJE`, `PREVOZ_DO_HLADNJACE`, `TRANSPORTNA_VRECA`, `PREVOZ_DO_GROBLJA`. |
| Hospital death | `BOLNICA` | `PREVOZ_DO_GROBLJA`. |
| Blok 2 limeni/lemovanje | Non-cremation and override cause or `GROBNICA` | `LIMENI_ULOZAK`, `LEMOVANJE`. |
| Local cemetery | `LOKALNO` | `PREVOZ_SPROVODA`. |
| International case | `sahranaVanSrbije` | `MEDJUNARODNI_PREVOZ`, `MEDJUNARODNA_DOKUMENTACIJA`, `BALSAMOVANJE`. |
| Reception of remains | `docekPosmrtnihOstataka` | `CARGO_TROSKOVI`. |
| Inactive managed row | Current condition no longer supports row | Suppressed, excluded from finance, may require user resolution. |
| Positive active row | Active and amount > 0 | Counts for financial truth. |

## 11. STANJE ROBE Relation

STANJE ROBE is downstream of selected goods/services and must not become parallel PREDMET truth.

Current audit conclusion:

| Relation | Current state |
| --- | --- |
| IRiU rows can create stock consequences | SOURCE-CONFIRMED in broader PREDMET workflow baseline. |
| Evaluator directly owns stock reconciliation | IMPLEMENTATION NOT FOUND. |
| Stock close-block/unresolved consequence relation | PARTIALLY IMPLEMENTED outside evaluator. |
| Future Web/sync stock behavior | TECHNICAL AUDIT REQUIRED before implementation. |

## 12. PIO and Refund Relation

PIO/refund policy is business-relevant, but this audit did not find it as a direct `BusinessPolicyEvaluator` input or output.

| Area | State |
| --- | --- |
| PIO/refund facts in broader product | POLICY EXISTS |
| Evaluator derives refund eligibility/warnings | IMPLEMENTATION NOT FOUND |
| Finance/document consequences | PARTIALLY IMPLEMENTED / requires dedicated audit |
| Owner decision need | Define whether evaluator must own refund guidance or only expose supporting facts. |

## 13. JKP and Platilac Relation

Payer and JKP logic affects finance and documents, but is not currently part of the evaluator kernel.

| Area | State |
| --- | --- |
| `PLATILAC` as canonical term in main PDFs | SOURCE-CONFIRMED from prior public baseline. |
| Evaluator uses payer/JKP facts | IMPLEMENTATION NOT FOUND |
| Consequence guidance for same/different payer, JKP coverage, or collection | POLICY EXISTS / TECHNICAL AUDIT REQUIRED |

## 14. Documents, PDF, Parte, and Citulje Relation

Document outputs consume PREDMET facts and selected rows, but they should not be treated as source of evaluator truth.

| Area | Current relation |
| --- | --- |
| PDF builders | Downstream outputs. |
| `CITULJA_POLITIKA` / `CITULJA_NOVOSTI` | Document-scoped IRiU exclusions from derivative/financial truth. |
| Parte/citulje selection | Business-visible selected rows; not full evaluator guidance. |
| Missing guidance | No complete evaluator-owned document-requirement graph was found. |

## 15. Review and Confirmation Relation

The strongest implemented review behavior is condition-change confirmation around managed IRiU rows.

| Trigger | Current behavior |
| --- | --- |
| Previously active managed row becomes inactive | Conflict/user-resolution path exists. |
| New managed category becomes required after condition change | Blok 2 can list additions requiring confirmation. |
| User dismissed managed category | Not silently re-added in tested Blok 2 flow. |
| Complete "Pregled i potvrda" checklist | IMPLEMENTATION NOT FOUND as evaluator-backed review model. |

## 16. Lifecycle, Version, and Log Relation

The evaluator is condition-sensitive, but this audit did not find a complete version/change-log integration where policy changes produce a business review summary.

| Area | State |
| --- | --- |
| Condition-change conflict planning | SOURCE-CONFIRMED for managed IRiU categories. |
| `verzija` conflict semantics | Covered by prior owner decision docs, not implemented here. |
| Business change-log overview | POLICY EXISTS / IMPLEMENTATION REQUIRED by prior baseline, not evaluator-owned today. |
| Audit risk | Future evaluator changes can silently affect finance, documents, and stock if not paired with scenario tests. |

## 17. Test Coverage

| Test area | Evidence |
| --- | --- |
| Blok 2 critical scenarios | `test/business_policy_iriu_critical_scenarios_test.dart` covers grobnica/grob, cremation exclusion, override causes, condition-change confirmations, and dismissed categories. |
| Death-place managed services | Source exists; dedicated scenario coverage needs review. |
| International/reception categories | Source exists; dedicated scenario coverage needs review. |
| Financial truth inclusion/exclusion | Source exists; dedicated scenario coverage needs review. |
| Ceremony guidance checklist | No direct evaluator checklist tests found. |
| PIO/refund, JKP/payer guidance | No evaluator tests found. |

## 18. Completion State

| Component | Completion state |
| --- | --- |
| Evaluator kernel | PARTIALLY IMPLEMENTED |
| Scenario id model | MINIMAL IMPLEMENTED: only default scenario |
| IRiU operational/recommendation truth | IMPLEMENTED for audited categories |
| Blok 2 lifecycle consequences | IMPLEMENTED / TEST-CONFIRMED |
| Death-place lifecycle consequences | IMPLEMENTED / TEST COVERAGE NEEDS REVIEW |
| Financial truth relation | PARTIALLY IMPLEMENTED |
| Ceremony advisor/checklist | MISSING |
| PIO/refund guidance | MISSING FROM EVALUATOR |
| JKP/payer guidance | MISSING FROM EVALUATOR |
| Document requirement graph | PARTIALLY IMPLEMENTED downstream, not evaluator-owned |
| Web/sync deterministic policy packaging | NOT AUTHORIZED / TECHNICAL AUDIT REQUIRED |

## 19. Gaps and Risks

| Risk | Why it matters |
| --- | --- |
| Evaluator name may imply more than it currently does | Future tasks may assume a complete policy advisor exists. |
| Only one named scenario id exists | Condition families are real, but not separated into formal scenario ids. |
| Ceremony guidance is fragmented | UI, IRiU, finance, PDF, and stock consequences are not exposed as one review model. |
| Finance/PDF/STANJE ROBE effects depend on IRiU consequences | Small evaluator changes can alter totals, documents, or inventory side effects. |
| PIO/refund and JKP/payer gaps are not evaluator-owned | Future automation could miss financially important office guidance. |
| Test coverage is concentrated around Blok 2 | Other condition families need dedicated scenario tests before behavior changes. |

## 20. Owner Decisions Required

| Decision | Needed before |
| --- | --- |
| Should the evaluator become the single ceremony guidance source, or only a low-level policy snapshot? | Any advisor/checklist implementation. |
| Which warnings must be mandatory vs advisory? | User-facing warning or review UI work. |
| Should PIO/refund and JKP/payer rules enter evaluator inputs? | Finance/document guidance automation. |
| How should document requirements be represented: evaluator output, PDF builder logic, or separate document policy model? | Document guidance implementation. |
| Which scenario names should become stable public IDs? | Web/sync/API or cross-platform deterministic behavior. |

## 21. Technical Audits Required

| Audit | Purpose |
| --- | --- |
| Death-place scenario tests | Confirm all insert/suppress/conflict combinations. |
| International and reception scenario tests | Confirm active/suppressed/finance/document outcomes. |
| Financial truth regression tests | Protect totals and excluded rows when evaluator changes. |
| STANJE ROBE consequence audit | Map stock effects from IRiU categories without redefining PREDMET truth. |
| PIO/refund and JKP/payer audit | Decide whether these become evaluator rules. |
| Ceremony checklist design audit | Define user-visible review output and platform parity. |

## 22. Future Web and Sync Notes

No Web, backend, API, sync, browser storage adapter, migration, or server-master behavior is authorized by this audit.

Before any Web/sync implementation, the evaluator needs a deterministic contract:

| Contract item | Current state |
| --- | --- |
| Stable scenario ids | Minimal default only. |
| Stable input schema | Partial, source-confirmed for current fields only. |
| Stable output schema | Not formalized as public API. |
| Cross-platform scenario tests | Incomplete. |
| Ownership of finance/document/stock consequences | Needs explicit boundary. |

## 23. Recommended Next Actions

1. Treat this audit as a public baseline before evaluator or IRiU behavior changes.
2. Add a dedicated evaluator scenario test suite before changing rules.
3. Decide whether ceremony guidance belongs inside `BusinessPolicyEvaluator` or in a separate advisor layer.
4. Audit PIO/refund and JKP/payer logic before any automation.
5. Keep Web/sync work blocked until evaluator input/output contracts and scenario tests are stable.

