# OPC SCENARIO end-to-end runtime forensic stabilization report

Date: 2026-08-09  
Branch: `task/OPC-SCENARIO-END-TO-END-RUNTIME-FORENSIC-STABILIZATION`  
Baseline: `02c0dc3fe2c04f213094887f4914b4a0f4516911` on the requested reconciliation branch

## Scope and premise

The requested premise was audited against source, tests, persistence, and the
production repository/apply path. The actual owner-approved entry is now
`MODULI → SCENARIO`; PREDMET has no direct SCENARIO action. SCENARIO loads only
`OTVOREN` PREDMETI, exposes one checkbox per row, and keeps the global editor
visible only when no PREDMET is selected. The selected view is PREDMET-scoped and
shows derived conditions, the persisted snapshot distinction, scenario-added
items, and the global/default edit action. Internal `MAP_*`, JSON, and internal
KATALOG identifiers are not rendered as business text.

The previous card's visible `MAP_*` assignment and direct PREDMET route were
therefore not owner-compliant; they are corrected in this branch. The runtime
root cause was the entry/state boundary, not a missing owner-map record: the
persisted scenario apply path already reconciled through `IriuRepository` and
the existing stale generated protective-equipment repair remains bounded to its
known fingerprint.

## Independent oracle and E2E gate

The independent oracle is
`test/fixtures/scenario/scenario_map_owner_golden.json`, 1,008 records,
source SHA-256
`663f104f01c8abfabaf5deddf8c82185af03fdef31b403dfb7d4e2efbf0e061e4`, fixture
SHA-256
`EDFC581299EF5AA080D5426F4D490EAE359A9D2F9A40A1C194332AF5F8F291FB`.

`test/scenario_end_to_end_runtime_forensic_stabilization_test.dart` exercises,
for every golden record, `kreirajPredmet` → `azurirajPredmet` →
`inicijalizujIriu` → persisted `syncScenarioRows` → snapshot/provenance/final
IRiU inspection. It compares scenario key, snapshot key, scenario-added item
order, business status, and provenance against the independent fixture.

The first current-DB run completed all 1,008 iterations with zero key, item,
status, or order mismatches. Golden-derived family counts are 252 records per
cause. Protective equipment is present in 216 NASILNA, 216 ZARAZNA, and 216
NEDEFINISANA records; the 36 hospital combinations in each family are the
owner-defined exception. No silent family drift was observed.

The canonical user database was copied before opening it for the forensic gate:

```text
Original: C:\Users\Steva\Documents\opc_v4_release.sqlite
Copy:     C:\Projekti\OPC\OPC v.1\RUNTIME\forensic_db\opc_v4_release_copy.sqlite
Original SHA-256 before: 8E6FF9717318CC9AC1CE36099670E0EA92F92FCCA45EC386FC54FAFD5E455BE2
Copy SHA-256 after copy: 8E6FF9717318CC9AC1CE36099670E0EA92F92FCCA45EC386FC54FAFD5E455BE2
Copy SHA-256 after migration/reconciliation: 8D293AE7EAEF183BAEC0E6BA7528D3BB502E3C817F5D7F5D71838DAF97C9D750
```

The copy gate used the same 1,008 production iterations and never opened the
original. Existing user-edited consequences were preserved; copy reopen hash
idempotency passed after the legitimate migration/reconciliation write.

## UI and safety evidence

- `MODULI → SCENARIO` is the only production entry path.
- The selector filters exactly `status == OTVOREN`; a stale closed selection is
  cleared on refresh.
- Checkbox selection is single-valued and tested by switching between two open
  PREDMETI.
- Snapshot data is loaded from `predmet_scenario_snapshots`; final scenario
  rows are distinguished from derived current conditions and provenance.
- Editing the selected relevant definition remains a global/default edit;
  persisted snapshots are not rewritten retroactively.
- New PREDMET NASILNA coverage asserts the protective item through the persisted
  repository/apply path with `SCENARIO_PAKET` provenance.
- Fixed-price OSNOVNI rows retain the established `CENA`/`IZNOS` materialization.

No external continuity/source-of-truth synchronization target is documented
outside Git; no competing local authority was invented.

## Validation record

Targeted UI selector tests and the independent current 1008 gate were run. The
The serial full Flutter suite completed 392 passed, 7 skipped, 0 failed. Flutter
analyze completed with no issues. Windows and Android release builds completed;
runtime Windows/Android acceptance remains an owner action.

## Final verdicts

TECHNICAL PREMISE VERIFICATION — PASS  
SCENARIO ENTRY PATH — MODULI ONLY  
OPEN-PREDMET SELECTOR UI — PASS  
ONE-CHECKBOX INVARIANT — PASS  
SELECTED PREDMET SCENARIO DISPLAY — PASS  
DERIVED VS APPLIED DISTINCTION — PASS  
SCENARIO EDIT FROM SELECTED PREDMET — PASS  
NON-RETROACTIVITY — PASS  
SCENARIO MOJIBAKE — 0  
1008 CANONICAL GOLDEN — PASS  
1008 E2E CURRENT DB — 1008/1008  
1008 E2E REAL DB COPY — 1008/1008  
E2E KEY MISMATCHES — 0  
E2E ITEM MISMATCHES — 0  
E2E STATUS MISMATCHES — 0  
E2E ORDER MISMATCHES — 0  
NASILNA FAMILY — PASS  
ZARAZNA FAMILY — PASS  
NEDEFINISANA FAMILY — PASS  
USER-EDITED MAP PRESERVATION — PASS  
MIGRATION IDEMPOTENCY — PASS  
OSNOVNI PRICING REGRESSION — PASS  
LIFECYCLE — PASS  
KATALOG/IRiU — PASS  
FLUTTER ANALYZE — PASS  
FULL FLUTTER TEST — PASS  
FULL TEST FAILED COUNT — 0  
TEST TIMEOUT POLICY — NO TIMEOUT USED  
WINDOWS BUILD — PASS (OPC.exe SHA-256 EB2DB87A10379AB9325DBFDC04EEBFF011C97A0B59C2CB24FA94B6A5D84A1E92)  
ANDROID BUILD — PASS (app-release.apk SHA-256 070EDD4F35FC43F1ACE48F17E476DAB6AA98FF933F23279D99279A159245570A)  
CANONICAL DB UNCHANGED — PASS (original hash protected)  
RUNTIME — PENDING OWNER ACCEPTANCE  
REMOTE SHA — CONFIRMED (remote branch verified after push)  
WORKING TREE — CLEAN
