# OPC R1–R5 Current-State Reconciliation

**Date:** 2026-09-06
**Purpose:** bounded current-state record for the accepted R1–R5 and recovered
restoration state. This is current supporting documentation, not a new product
authority or implementation plan.

## 1. Reconciliation conclusion

R1–R5 establish an accepted implementation/source/test/documentation baseline
for portable IRiU identity, ČITULJE preparation and finalization, canonical
ČITULJA PDF output, and bounded PODSETNIK ČITULJA parent/child integration.
The technical evidence is green for the bounded scopes. This does not mean
integrated release completion: full-suite, final integrated build, Windows and
Android runtime acceptance, and cross-device transfer acceptance remain
separately pending.

PREDMET remains the sole business truth. Windows and Android remain equal
standalone OPC peers, and business state belonging to a PREDMET remains
transferable through both Single-PREDMET JSON and OPC Backup JSON.

The review layers are kept separate:

- R1 has an explicitly recorded independent Logos review PASS.
- R2–R4 have the accepted implementation/source/test/documentation evidence
  identified below. R5 additionally has an accepted independent Logos review
  PASS; its remaining boundary is runtime/device and release acceptance.
- No R1–R5 item is classified as release complete on bounded evidence alone.

## 2. Accepted R1–R5 evidence baseline

| Work layer | Accepted implementation/evidence result | Review reference | Current status |
| --- | --- | --- | --- |
| R1 | Portable per-occurrence IRiU identity, JSON/Backup preservation, same-type separation, reorder/membership protection | `OPC-R1-PORTABLE-IRIU-IDENTITY-TRANSFER-FOUNDATION.zip`; SHA-256 `9FB00C747FE55C0660CC7FD5A4CAC4D4B7811E97073130673CB4912758034FFB` | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` — independent Logos review PASS recorded |
| R2 | `CituljePripreme`, POLITIKA/NOVOSTI, DA/NE mode, date/text/note, confirmed PARTE proposal, JSON/Backup state | `OPC-R2-CITULJE-DOMAIN-PERSISTENCE-PARTE-SNAPSHOT-FOUNDATION.zip`; SHA-256 `908705BB8AADCFE1184198F8898178F6826379FFE536319C0B2774B4B1AF1454` | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` |
| R2B | Per-occurrence finalization, `finalized`/`finalizedAt`, repository/SQL guards, transfer preservation | `OPC-R2B-CITULJE-FINALIZATION-STATE-TRANSFER-GUARD.zip`; SHA-256 `AB601F335ABFAD622947A926EBC0EA07727D89770415F3F9E4AE279BF8C9DE15` | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` |
| R3 | Dedicated ČITULJE UI, DA/NE editing, date/note, derived word count, valid-text finalization, current-form atomic finalization | `OPC-R3-CITULJE-MODULE-UI.zip`; SHA-256 `E8928041697E983E1B8018C13441B0EF257B483A287C39474D8416AEF2E4AED3` | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` |
| R4 | Canonical persisted-state, per-occurrence ČITULJA PDF with multipage support and no unrelated data | `OPC-R4-CITULJA-PDF-GENERATION.zip`; SHA-256 `31D5E97CC61FD52136281D00D8875C4CCFA1DB09886F20422E7B1C3D1136B298` | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` |
| R5 | Grouped ČITULJA parent/children, generic OPELO semantics, portable completion retention/minimization, LISTA, REVIEW BAR and R4 PDF reuse | `OPC-R5-PODSETNIK-CITULJA-INTEGRATION.zip`; SHA-256 `2E24E0025844102CEA0EB4AB3845DF1928F9C4613D32CA9EB393C0B5DBC1EB44` | `IMPLEMENTED + INDEPENDENT LOGOS REVIEW PASS + RUNTIME ACCEPTANCE PENDING` |

## 3. ČITULJE capability matrix

| Capability | Status | Evidence / boundary |
| --- | --- | --- |
| Portable occurrence identity | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R1 identity package; R2–R5 bind concrete preparations/children to `portableOccurrenceId`. |
| Persistence/domain | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | `CituljePripreme`; R2 package and current `OPC_ARCHITECTURE.md`. |
| PARTE confirmed-text integration | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | Confirmed `ParteRenderPlan` plain text; valid confirmed iterations refresh until ČITULJA finalization; no reverse sync. |
| Finalization and write guards | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R2B/R3 evidence: `finalized`/`finalizedAt`, non-empty text guard, repository boundary and atomic current-form persistence. |
| Dedicated module/UI | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R3 source/tests; current occurrences only, editable DA proposal, independent NE text, date/note and derived word count. |
| Canonical ČITULJA PDF | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R4 generator reads persisted preparation state and produces one PDF per occurrence. |
| PODSETNIK parent/child integration | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R5 source/tests; parent derived from relevant children, child identity portable, no independent parent truth. |
| REVIEW BAR participation | `IMPLEMENTED + OWNER RUNTIME ACCEPTANCE PASS — scoped REVIEW BAR behavior protected` | Current REVIEW BAR coverage, cadence, contrast, wording and live-refresh behavior are accepted for the scoped correction; broader integrated R1–R5 runtime/device and release acceptance remains separate. |
| LISTA integration | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R5 source/tests; shared human-facing projection and empty paper checkboxes. |
| Single-PREDMET JSON transfer | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R2/R2B/R5 transfer evidence; legacy omission remains importable. |
| OPC Backup transfer | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R2/R2B/R5 backup evidence; minimal valid state only. |
| Runtime/device acceptance | `OPEN` | Windows runtime, Android physical/runtime parity and cross-device transfer acceptance are not closed for integrated R1–R5. |

## 4. Broader PODSETNIK capability matrix

These classifications describe the bounded current implementation, not a
claim that every owner-planned future surface is complete.

| Capability | Status | Evidence / next boundary |
| --- | --- | --- |
| F-01 NALOG ZA OPREMANJE placement/action | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | Current PODSETNIK screen exposes the equipment action; bounded callback/output tests pass. Full owner runtime placement acceptance remains pending. |
| F-02 NAPOMENA separation | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | Current screen has a separate general note field below the checklist; integrated visual/runtime acceptance remains pending. |
| F-03 completed/incomplete distinction | `PARTIALLY IMPLEMENTED` | `lib/features/podsetnik/presentation/podsetnik_module_screen.dart` renders `completed` through checked/unchecked `CheckboxListTile` values for groups, children and standalone items. Current tests (`test/podsetnik_task2_ui_integration_test.dart`, `test/podsetnik_module_screen_test.dart`, `test/podsetnik_task2_bounded_correction_test.dart` and `test/podsetnik_obligation_foundation_test.dart`) cover checklist/state behavior but do not prove an explicit completed-vs-incomplete visual treatment beyond checkbox state; that evidence/runtime gap remains open. |
| F-04 REVIEW BAR semantics | `IMPLEMENTED + OWNER RUNTIME ACCEPTANCE PASS — scoped REVIEW BAR behavior protected` | General relevant unfinished-parent projection, cadence, placement/style, zero-state and live completion refresh are accepted for the scoped REVIEW BAR correction; broader integrated runtime/release boundary remains. |
| F-05 ČITULJA | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | R1–R5 baseline; see the ČITULJE matrix. |
| F-06 manual / `POSEBNE OBAVEZE` | `IMPLEMENTED + OWNER RUNTIME ACCEPTANCE PASS — scoped REVIEW BAR participation protected` | The accepted REVIEW BAR correction covers active `POSEBNE OBAVEZE`; broader F-06 manual-child/transfer/runtime/release scope remains governed by the current residual authority. |
| F-07 PODSETNIK transfer | `IMPLEMENTED + RUNTIME ACCEPTANCE PENDING` | PREDMET-owned obligation rows and R5 minimal ČITULJA state use existing JSON/Backup paths; physical cross-device acceptance remains pending. |
| F-08 IMENIK | `DEFERRED` | Outside the R1–R5 dependency chain; no new implementation is authorized by this reconciliation. |
| F-09 FINANSIJE | `DEFERRED` | Existing FINANSIJE segment and focused formatting behavior are separate; broader owner-planned F-09 work is outside R1–R5 and not implemented here. |
| URNA/PEPEO obligation/notification lifecycle | `IMPLEMENTED + SOURCE/TEST/DOCUMENTATION COMPLETE — RUNTIME/EVIDENCE/RELEASE BOUNDARY OPEN` | Specialization, scoped `ZAVRŠEN` blocker, transfer paths and source/test/documentation behavior are current; remaining runtime/device evidence and integrated release acceptance are separate gates. |
| PODSETNIK UI/PDF/LISTA consistency | `PARTIALLY IMPLEMENTED` | R5 ČITULJA/LISTA/PDF route is implemented; broader PODSETNIK visual redesign and full runtime consistency remain open. |
| Windows/Android runtime acceptance | `OPEN` | Integrated R1–R5 runtime/device evidence is still pending. |

## 5. Data and truth boundaries

- PREDMET is the master case truth; PODSETNIK is a derived/operational layer.
- Current IRiU membership controls current ČITULJA visibility.
- `portableOccurrenceId` protects concrete same-type occurrence identity.
- Parent completion is derived from relevant atomic children; parent mark-all is
  a command over children.
- Valid completed concrete ČITULJA child state may remain durable through
  temporary non-current membership. Incomplete, invalid, orphaned, redundant
  and parent-only state is not retained merely as history.
- PREDMET JSON and OPC Backup JSON carry only the minimal attributable business
  state. No historical PODSETNIK subsystem exists.
- PARTE remains upstream of ČITULJE; ČITULJE never writes back to PARTE.

## 6. Runtime and release classification

Bounded targeted/regression/analyzer evidence was recorded by the individual
R1–R5 tasks. The bounded evidence does not equal integrated release acceptance.
The following remain pending:

- full integrated Flutter test/analyzer/build gates when authorized for the
  accumulated implementation state;
- Windows runtime acceptance for the integrated R1–R5 state;
- Android physical/runtime acceptance for the integrated state;
- cross-device Single-PREDMET JSON and Backup transfer acceptance;
- final signing/version/publication and Git synchronization gates.

No R1–R5 item is marked `RELEASE COMPLETE`.

## 7. Open items and current sequencing consequence

### Open items

1. `EVIDENCE GAP`: broader F-06 manual-child, grouped-state, reopen/transfer
   and runtime evidence remains governed by the current residual authority.
2. `EVIDENCE GAP`: broader URNA/PEPEO Windows secondary-cycle and integrated
   runtime evidence remains governed by the current residual authority.
3. `DEFERRED / feature`: broader F-09 FINANSIJE work.
4. `DEFERRED / feature`: IMENIK when its dependency position is selected.
5. `PARTIALLY IMPLEMENTED / UI-UX`: F-03 explicit completed/incomplete visual
   distinction evidence and broader PODSETNIK visual/presentation corrections
   beyond the accepted R5 ČITULJA/LISTA scope.
6. `OPEN / runtime acceptance`: integrated Windows, Android and cross-device
   acceptance.
7. `OPEN / release`: final full QA/build/signing/version/Git/publication gates.

No unique next residual implementation is established by this supporting
record. Current recovery sequencing is governed by the canonical recovery plan
and the current successor residual authority:

`OWNER SEQUENCING DECISION REQUIRED`

The predecessor recommendation to select F-06 or URNA/PEPEO as the next feature
is historical and non-authoritative for current recovery ordering. This record
does not authorize the next task automatically.

## 8. Documentation reconciliation record

Updated current documentation must distinguish historical task reports from
the accepted current implementation state and pending runtime acceptance. The
R5-specific current sections remain evidence-backed; old reports remain useful
provenance and are not rewritten as if they had always described R1–R5.

No source implementation, test, schema or transfer-format change is part of
this record.

## 9. Recovered baseline and authority-hygiene overlay – 2026-09-09

The recovered implementation state is protected by the accepted baseline
package SHA-256
`5241576752D8F3954D741A3AC0CEEF089863F5AAC2E30F72354264C4FE9ABE5A`.
The subsequent active-source authority hygiene and stale implementation
quarantine is `PASS`, with package SHA-256
`2A637C0629D863F56D358E8CAFD99EEFA16E0D463F5D93ACBEBA61970085DD9C`.
It preserved active implementation content, quarantined only proven obsolete
staging/evidence roots and leaves `runtime_data` and `.audit_tmp` as
`UNRESOLVED – DO NOT USE`.

The restoration source/test/documentation result remains distinct from
runtime/release acceptance. The latest Windows process/window event is the
known Codex sandbox desktop-binding recurrence, so integrated Domains 1–5
remain `OWNER EVIDENCE REQUIRED`; it is not classified as an OPC startup
defect without OWNER launch on `WinSta0\\Default`. The current local SOURCE is
still a mixed dirty working state and is not represented as a coherent
published implementation baseline. Future corrective work must load the
active-source manifest and donor denylist before any source action.

F-03 remains `PARTIALLY IMPLEMENTED`: checkbox state evidence exists, but the
OWNER-required explicit completed/incomplete visual distinction is not closed
by this documentation task.
