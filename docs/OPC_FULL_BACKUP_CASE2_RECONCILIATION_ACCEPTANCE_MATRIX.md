# Full-backup Case-2 Reconciliation Acceptance Matrix

| ID | Acceptance obligation | Evidence | Result |
|---|---|---|---|
| C2-1 | Complete incoming PIB+MB still uses ordinary restore | Existing full-backup identity regression | PASS / unchanged |
| C2-2 | Mismatching PIB or MB blocks before destructive write | Existing non-destructive mismatch regression | PASS / unchanged |
| C2-3 | Fresh local state accepts complete backup identity | Existing Case-3 regression | PASS / unchanged |
| C2-4 | Incomplete backup identity with existing local state is detected explicitly | Four-state preflight source and regression | PASS |
| C2-5 | New, unambiguous PREDMET is importable | Case-2 focused test | PASS |
| C2-6 | Same-identity destination conflict remains local | Case-2 focused test | PASS |
| C2-7 | Duplicate/blank identity is ambiguous and not imported | Case-2 focused test | PASS |
| C2-8 | Foreign numeric users are not imported | Existing local-actor rebinding tests | PASS |
| C2-9 | Imported attribution uses the active destination-local actor | Case-2 focused test | PASS |
| C2-10 | FIRMA and local users remain unchanged | Case-2 focused test and selective source path | PASS |
| C2-11 | Global catalog/config/templates remain destination-local | Source boundary and selective path review | PASS |
| C2-12 | PARTE, reminders, history and SCENARIO global state remain destination-local | Source boundary review | PASS |
| C2-13 | Selected imports are atomic | One outer transaction; repository transactionless seam | PASS |
| C2-14 | Cancel/no import leaves local state unchanged | Plan is read-only; apply is explicit | PASS |
| C2-15 | No future PODSETNIK/anonymization/global identity policy is introduced | Diff and authority review | PASS |

Focused execution: `flutter test --no-pub --concurrency=1
test/predmet_local_identity_recovery_acceptance_test.dart` — 13/13 PASS,
including the two Case-2 tests. Full QA then reached natural completion with
445 tests passed and 10 expected skips; analyzer PASS; Windows and Android
release builds PASS. Existing protected transfer/lifecycle and full-backup
tests remained green.
