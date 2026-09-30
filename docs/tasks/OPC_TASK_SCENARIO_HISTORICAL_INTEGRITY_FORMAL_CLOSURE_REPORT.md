# SCENARIO carrierless historical-integrity correction — formal closure

**Date:** 2026-09-30
**Status:** `SCENARIO HISTORICAL-INTEGRITY TASK — FORMALLY CLOSED`

## Accepted outcome

This documentation/control closure records the already accepted implementation
and correction without changing product behavior. Accepted state:

- `SCENARIO CARRIERLESS / HISTORICAL-INTEGRITY CORRECTION — PASS`
- `LOGOS INDEPENDENT CORRECTION REVIEW — PASS`
- `OWNER RUNTIME ACCEPTANCE — PASS`
- `PREDMET SOLE-BUSINESS-TRUTH INVARIANT — CONFIRMED`
- `MANUAL IRiU CORRECTIONS SURVIVE REOPEN — CONFIRMED`
- `HISTORICAL SCENARIO STATE DOES NOT OVERRIDE CURRENT PREDMET/IRiU — CONFIRMED`

The source correction distinguishes new-PREDMET creation from ordinary open,
persists creation-origin provenance for newly created base IRiU rows, prevents
category-based reconstruction of carrierless history, and presents absent
historical snapshots as unavailable evidence. No product source behavior,
schema, JSON/carrier contract, database contract, or business rule was changed
for this formal closure. The accepted implementation/correction reports and
ZIPs are preserved unchanged.

## Runtime evidence boundary

The concrete OWNER runtime case used carrier v1. Provenance coverage was
`UNAVAILABLE`, while an assignment snapshot existed. Consequently this runtime
case is not independent runtime evidence for v2 `COMPLETE` or `PARTIAL`
transfer behavior. Those transfer behaviors remain supported by automated QA,
not by this specific runtime case. Runtime acceptance is recorded as the
OWNER's accepted observation of the tested scenario, without broadening what
that observation proves.

The correction report records final technical validation: focused tests PASS,
`flutter analyze --no-pub` PASS, full suite `602 passed / 9 skipped / 0 failed`,
Windows release build PASS, and Android production APK build PASS. Product QA
was not rerun for this documentation/control-only closure.

## Continuity and finding separation

`PREVIOUS PENDING FINDING — NOT IDENTIFIABLE FROM CURRENT AUTHORITY`

Its identity has not been reconstructed in this closure. It is not renamed,
guessed, reinterpreted, or merged with the SCENARIO inconsistency now being
closed, `UX-PARTE-001`, or any other known open item. This closure does not
investigate it. The SCENARIO → `PRIMENJENO NA PREDMET` inconsistency is the
issue closed here and must not be carried forward as the previous pending
finding. `UX-PARTE-001` remains a separate `OPEN / NOT TESTED / ROOT CAUSE NOT
PROVEN` item.

## Protected active-source control

The controlled rebaseline is limited to four provenance-backed protected
rows, with no changes to the other 24 rows:

| Protected path | Previous recorded hash | Final source hash | Accepted provenance |
|---|---|---|---|
| `lib/features/predmeti/data/predmeti_repository.dart` | `00C3C00FA4B1D89432CFAA509E76F96A786358F497435B5999E780F380404A24` | `0897D23509BE8B2A93DD5480DD682C718383CE2D144914277725E38C372A5B70` | SCENARIO carrierless correction; authorized implementation/correction evidence |
| `lib/features/predmeti/presentation/lista_predmeta_screen.dart` | `39DC0FFDD89043EBB3F9B3EC1A2EADAF2EB7A5C976B89D7E9689C5A2E2D659C1` | `96CB5E630CD0879AB6052C43D6FEB3F985FA99248ADE5EC7B21A826CB8E3551A` | Previously accepted Direction 2 baseline plus separately authorized SCENARIO creation-intent plumbing; D2 hunk excluded from this closure commit |
| `docs/OPC_ARCHITECTURE.md` | `21A320CD2F78EED6F9C9E2F5E93F0567C96953F0309B18E9EAB0FD7CBCE4E9C1` | `2C6DF180C0426980A6E63B72B1965D457B70357C89A3FD1335F7E2A703557D32` | SCENARIO applied-state/source-boundary documentation and prior recorded provenance |
| `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md` | `F5C6757C69C220FBB45F8A720A067ADA0AFA83AD9E2CABD30AE987DDF8AC30D6` | `E359ADF1087D28CC76E274F44E7FA27C670E7F971451E4A17F19D06C3A8CA02B` | Local-only SCENARIO causal continuity update; non-authoritative |

At task intake these four were the only active protected-hash mismatches
(24/28 matched). Their provenance was checked against the prior accepted task
records before rebaseline. The final recorded values are the SHA-256 of the
exact final files. The baseline CSV changed only these four rows; the other 24
logical rows were preserved. Dependent active-package integrity metadata was
regenerated and the final package and 28-row baseline were verified. This
control update does not turn a hash into implementation or business authority.

## Repository/publication record

The commit contains only the SCENARIO implementation/correction and tests and
required tracked closure documentation. The active-source control package and
PSEUDOCODE are local-only ignored control material; their authorized
four-row rebaseline and dependent integrity metadata are maintained there, not
promoted into tracked SOURCE. Direction 2 source/tests/reports and unrelated
open findings are excluded. Mixed changes in
`scenario_module_screen.dart`, `lista_predmeta_screen.dart`, related tests,
and current-state/quality documentation were selectively staged by hunk and
the staged diff was inspected against the approved closure boundary.

The active-source pointer records the published commit after publication.
The final local `HEAD` and `origin/codex/opc-v1.5-clean-baseline` are required
to be identical; exact values and the final dirty-path/task-provenance
inventory are recorded in the external closure review handoff. No claim of a
clean worktree is made while unrelated Direction 2 work remains local.

## Evidence lineage

- Implementation report: [`OPC_TASK_SCENARIO_APPLIED_STATE_INTEGRITY_AND_SELECTOR_IMPLEMENTATION_REPORT.md`](OPC_TASK_SCENARIO_APPLIED_STATE_INTEGRITY_AND_SELECTOR_IMPLEMENTATION_REPORT.md)
- Correction report: [`OPC_TASK_SCENARIO_CARRIERLESS_HISTORICAL_INTEGRITY_CORRECTION_REPORT.md`](OPC_TASK_SCENARIO_CARRIERLESS_HISTORICAL_INTEGRITY_CORRECTION_REPORT.md)
- Accepted correction ZIP SHA-256: `4EA40B302190668C5FA71E743C302E7AFF5A5109DE62A3BAA4E1A3EDC6919259`
- Accepted implementation package SHA-256: `4FAB891605A1410953331807966AC85A06C98557AB0EE514702F832A6AC4851F`

These packages are preserved as accepted evidence and were not modified by
closure. This report records closure status; it does not reopen implementation
or begin the separate previous-finding reconstruction.

**Next action — reconstruct and review the previously pending finding as a
separate task.**
