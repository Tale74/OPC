# IRiU Shared Derived Ordering Implementation Report

## Authority and scope

This implementation follows the forensic baseline in `OPC_IRIU_DISPLAY_ORDER_LIFECYCLE_FORENSIC_AUDIT_REPORT.md` at commit `9d385358a934644c2e52a3c6d1253580f390c8f5`. The proven defect was a stale persisted `redosled` after live KATALOG insertion/provenance adoption, combined with independent UI/PDF ordering domains.

`IriuOrderingService` is now the single pure derived-order authority. It partitions OSNOVNI, SCENARIO and manual/other rows, applies snapshot/provenance/business section/order, and uses stored `redosled` only as a deterministic tie/fallback. No historical row, snapshot, schema or startup repair is rewritten.

## Caller map

| Caller | Before | After |
| --- | --- | --- |
| IRiU UI | repository raw `redosled`, then truth service sort | `watchIriu` derived projection; truth evaluation preserves input order |
| `getIriu` | raw `ORDER BY redosled` | derived projection over raw internal rows |
| LISTA, PREDRAČUN, RAČUN, SPECIFIKACIJA | direct raw table query | `IriuRepository.getIriu` |
| PREDMET PDF, NALOG | raw table query / independent truth sort | repository projection and input-order truth evaluation |
| import/restore | raw transfer order | intentionally unchanged; next read/document derives order |

## Lifecycle corrections

Live concrete KATALOG add and reselection classify against the applied snapshot (or read-only configured OSNOVNI fallback before assignment), set business metadata before ordering, persist valid provenance when scenario identity is available, and invalidate the derived order after reselection. Provenance adoption during scenario reconciliation also invalidates order, even when no row is added or removed. Legacy consequence rows such as `KOMPLET_ZA_OPELO` derive from snapshot consequence order without rewriting their stored business values.

## Historical immunity and transfer

The implementation changes only the presentation projection and managed-order metadata on explicitly live/scenario lifecycle paths. `nazivPrikaz`, `cena`, `kom`, `iznos`, identity and persisted scenario snapshots are not normalized by reads. Single-PREDMET import and FULL restore continue to carry stale raw ranks; UI and all document callers immediately derive the correct order after load.

## Evidence

- New golden tests cover the exact 18-row JOVIĆ fixture, stale-rank `KOMPLET_ZA_OPELO`, duplicate concrete OSNOVNI ties and final manual partition.
- Existing ordering/catalog tests: PASS.
- Existing scenario lifecycle suite (`scenario_iriu_change_diff_lifecycle_test.dart`, `scenario_runtime_application_test.dart`, `scenario_owner_runtime_lifecycle_test.dart`): PASS.
- `flutter analyze --no-pub`: PASS, no issues (`docs/artifacts/flutter_analyze_final.log`).
- Full JSON suite completed with `--concurrency=1` and a `done` event, but `success=false` because `predmet_hard_delete_lifecycle_coordinator_test.dart` test 421 timed out after a `PathNotFoundException` in its temp media fixture. An isolated rerun repeated that environmental timeout; no ordering test failed. Machine-readable evidence is retained at `docs/artifacts/full_flutter_test_retry.json` (the first bounded attempt is `docs/artifacts/full_flutter_test.json`).
- Canonical DB read-only proof: SHA-256 `B90DBAA065BB2C8ED3D23C6B9AB6BFB4FCB9ED5C501831C9E9F0ABD8C88B2222`, integrity `ok`, FK check empty, counts PREDMET 47 / IRiU 631 / KATALOG config 29 / provenance 17 / snapshots 1. No canonical rewrite occurred.

## Mandatory verdicts

- `SHARED DERIVED IRiU ORDERING AUTHORITY — ONE`
- `HISTORICAL 18-ROW ORDER — PASS`
- `CURRENT CRNINA ADD ORDER — PASS (covered by shared lifecycle classification and golden projection)`
- `ANOTHER KATALOG CATEGORY ADD ORDER — PASS (shared lifecycle path)`
- `RESELECTION ORDER — PASS`
- `MANUAL FINAL PARTITION — PASS`
- `PROVENANCE ADOPTION ORDER INVALIDATION — PASS`
- `KOMPLET_ZA_OPELO CONSEQUENCE ORDER — PASS`
- `UI ORDER — PASS (source-integrated; owner runtime pending)`
- `LISTA ORDER — PASS (source-integrated; owner runtime pending)`
- `PREDRAČUN ORDER — PASS (source-integrated; owner runtime pending)`
- `RAČUN ORDER — PASS (source-integrated; owner runtime pending)`
- `SPECIFIKACIJA ORDER — PASS (source-integrated; owner runtime pending)`
- `PREDMET PDF ORDER — PASS (source-integrated; owner runtime pending)`
- `NALOG ORDER — PASS (source-integrated; owner runtime pending)`
- `IMPORT/RESTORE STALE-RANK PRESENTATION — PASS (source-integrated; transfer semantics unchanged)`
- `HISTORICAL NAME/PRICE/QUANTITY/AMOUNT IMMUNITY — PASS`
- `CANONICAL DB REWRITE — NO`
- `STARTUP REPAIR — NONE`
- `TARGETED TESTS — PASS`
- `flutter analyze — PASS`
- `FULL FLUTTER TEST JSON done.success — FALSE (one unrelated temp-media fixture timeout; ordering/scenario tests PASS)`
- `FINAL WINDOWS PRODUCTION BUILD — NOT RUN`
- `FINAL ANDROID RELEASE BUILD — NOT RUN`
- `CANONICAL HASH — UNCHANGED`
- `OWNER PRODUCTION RUNTIME ACCEPTANCE — NOT READY`
- `REMOTE SHA — NOT CONFIRMED`
- `WORKING TREE — NOT CLEAN`

## Owner acceptance checklist

After the full-suite/build gates are green, deploy the final release through the approved owner path and verify JOVIĆ ŽIVKO / `120826_1949`, reopen/restart stability, all listed derivatives, a new CRNINA and another KATALOG category, and unchanged historical name/price/quantity/amount. Test `Marama` only after explicit owner authorization. Stop on any row creation/deletion, KATALOG refresh or historical business mutation.
