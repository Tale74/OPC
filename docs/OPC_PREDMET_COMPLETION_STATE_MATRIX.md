# OPC PREDMET Completion State Matrix

Status: public completion-state matrix / audit-only documentation.

## 1. Purpose

This matrix answers what is implemented, test-confirmed, runtime-confirmed, policy-only, incomplete, and waiting across the PREDMET workflow.

## 2. State Legend

States: `IMPLEMENTED`, `PARTIALLY IMPLEMENTED`, `POLICY-ONLY`, `OWNER-DECISION ONLY`, `NOT IMPLEMENTED`, `TEST-CONFIRMED`, `RUNTIME GAP`, `TECHNICAL AUDIT REQUIRED`, `OWNER DECISION REQUIRED`.

## 3. Matrix By PREDMET Point

| Workflow point | Implementation state | Evidence | Tests | Runtime status | Open gaps | Recommended next action |
| --- | --- | --- | --- | --- | --- | --- |
| Opening/basic metadata | `PARTIALLY IMPLEMENTED` | `predmeti_repository.dart`; `lista_predmeta_screen.dart`; `predmeti_table.dart` | `lista_predmeta_screen_smoke_test.dart` partial | `RUNTIME GAP` | duplicate `brojPredmeta`; firm identity scope | audit duplicate/identity behavior |
| Preminulo lice | `IMPLEMENTED / TEST GAP` | `preminulo_lice_segment.dart`; `predmeti_table.dart` | none dedicated | `RUNTIME GAP` | field validation matrix | UI workflow smoke |
| Činjenice o smrti | `IMPLEMENTED / PARTIALLY TEST-CONFIRMED` | `preminulo_lice_segment.dart`; `business_policy_evaluator.dart` | `business_policy_iriu_critical_scenarios_test.dart` | `RUNTIME GAP` | full UI validation | scenario/UI tests |
| Statusi / PIO preconditions | `IMPLEMENTED / TEST GAP` | `preminulo_lice_segment.dart`; `finansije_segment.dart` | refund migration only | `RUNTIME GAP` | refund edge cases | finance/refund tests |
| Platilac / JKP payer | `IMPLEMENTED / TEST GAP` | `narucilac_segment.dart`; `kontakt_lica_table.dart`; PDF builders | contacts via JSON tests | `RUNTIME GAP` | terminology cleanup; requiredness | payer UI tests and owner cleanup decision |
| Ceremonija | `IMPLEMENTED / PARTIALLY TEST-CONFIRMED` | `ceremonija_segment.dart`; `business_policy_evaluator.dart` | IRiU policy scenarios | `RUNTIME GAP` | full ceremony UI matrix | runtime smoke and tests |
| Parte | `PARTIALLY IMPLEMENTED` | `parte_segment.dart`; `predmeti_table.dart` | none dedicated | `RUNTIME GAP` | advanced parte/outputs | parte rule audit/tests |
| Čitulje | `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED` | `predmeti_repository.dart`; `iriu_table.dart`; entitlement policy | none dedicated | `RUNTIME GAP` | exact workflow/source | owner/product rule audit |
| Roba i usluge / IRiU | `IMPLEMENTED / TEST-CONFIRMED` | `iriu_segment.dart`; `iriu_table.dart`; core_v2 services | `business_policy_iriu_critical_scenarios_test.dart` | `RUNTIME GAP` | full owner-reviewed rule map | expand IRiU atlas/tests |
| STANJE ROBE consequences | `PARTIALLY IMPLEMENTED / TEST-CONFIRMED` | `stanje_robe_lifecycle_service.dart`; stock repositories | `stanje_robe_operational_toggle_test.dart`; JSON tests | `RUNTIME GAP` | full backup/import stock policy | stock import/restore audit |
| Finansije | `IMPLEMENTED / TEST GAP` | `finansije_segment.dart`; `financial_truth_service.dart`; PDF builders | no dedicated finance test found | `RUNTIME GAP` | edge-case totals | finance regression tests |
| Dokumenti/PDF | `IMPLEMENTED / TEST GAP` | `predmet_screen.dart`; `lib/features/predmeti/pdf/*` | no PDF render tests found | `RUNTIME GAP` | PDF terminology/render coverage | PDF regression/terminology task |
| JSON export/import relation | `IMPLEMENTED / TEST-CONFIRMED` | `json_export_import.dart`; `predmet_json_transfer_core.dart` | `json_transfer_regression_test.dart` | `RUNTIME GAP` | firm/version guards | separate JSON safety implementation design |
| Pregled i potvrda | `IMPLEMENTED / IMPLEMENTATION REQUIRED` | `predmet_screen.dart`; `predmeti_repository.dart` | partial related tests only | `RUNTIME GAP` | future change-log overview | audit review UI suitability |
| Lifecycle actions | `IMPLEMENTED / TEST GAP` | `predmeti_repository.dart`; `lista_predmeta_screen.dart`; `predmet_screen.dart` | partial related tests | `RUNTIME GAP` | full lifecycle UI tests | lifecycle smoke/tests |
| Version/log/change-log | `PARTIALLY IMPLEMENTED / POLICY-ONLY FUTURE` | `predmeti_repository.dart`; `log_izmena_table.dart`; owner report | no full version tests found | `RUNTIME GAP` | change-log overview missing | version/log audit |

## 4. Implemented Points

Source implementation exists for actual PREDMET sections, repository lifecycle, IRiU, contacts, finance, documents, JSON, and entitlement-controlled visibility.

## 5. Partially Implemented Points

Opening identity scope, STANJE ROBE import/restore relationship, čitulje, future version/change-log overview, and firm-scoped JSON/backup guard remain partial.

## 6. Policy-Only Points

Firm-scoped identity, PIB/MB mismatch block, `exportDatum` non-authority, version conflict matrix, and future `Pregled i potvrda` change-log overview are policy/owner decisions, not current implementation proof.

## 7. Not Implemented Points

Not implemented/proven: firm-scoped conflict guard, PIB/MB import/restore mismatch guard, automatic version conflict warning UI, hard-block logic, PREDMET change-log overview, Web/sync logic.

## 8. Test-Confirmed Points

Test-confirmed: JSON transfer/replacement, STANJE ROBE consequences, IRiU critical scenarios, entitlement/license parser and package migration, selected smoke tests.

## 9. Runtime Gaps

No fresh Windows/Android runtime pass was run. Full PREDMET workflow, dialogs, PDFs, document generation, import UI conflict dialog, and review/close flow remain runtime gaps in this task.

## 10. Technical Audit Required

- PREDMET workflow runtime smoke;
- finance/PDF regression tests;
- parte/čitulje workflow audit;
- firm identity guard;
- version/log/change-log audit;
- platform parity checks.

## 11. Owner Decision Required

- duplicate `brojPredmeta` creation behavior;
- final `Platilac`/`narucilac` cleanup path;
- čitulje expected workflow;
- change-log content/retention;
- future version hard-block policy if any.

## 12. Recommended Sequencing

Findings-only sequence:

1. Runtime-confirm PREDMET workflow on Windows/Android.
2. Audit `Pregled i potvrda` version/change-log suitability.
3. Add targeted finance/PDF/parte/čitulje tests.
4. Handle firm identity/JSON guard in a separate implementation-design task.
