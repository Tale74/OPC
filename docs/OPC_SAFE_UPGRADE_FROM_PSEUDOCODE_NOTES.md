# OPC Safe Upgrade From Pseudocode Notes

Status: grouped findings from business-critical pseudocode.

Base commit: `78f88228bb55526ae7c168c2aac0140ec3cb620c`

These notes are findings only. They are not strategic instruction and do not authorize implementation.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-001

Group name: UI manual number formatting / validation
Symptoms / child illnesses: amount fields and finance rows rely on parsing/display conventions spread across UI, service and PDF layers.
Affected pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-011`
Affected modules: Finance, IRiU, PDF, JSON
Business risk: wrong displayed totals or unclear money values.
Current protection: financial truth excludes inactive/non-positive rows; PDF formats final rows.
Unsafe approach to avoid: changing stored PREDMET numeric meaning to fix display.
Safe upgrade boundary: finance display and parsing require characterization before behavior changes.
Characterization tests needed: IRiU amount, refund, advance, discount, JKP, final payable.
Owner decision needed: only for changed rounding/display policy.
Implementation blocked until: finance rule expectations are documented.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-002

Group name: Display composition consistency across preview/PDF/JSON
Symptoms / child illnesses: PARTA preview, PDF builders and JSON fields may expose different composition expectations.
Affected pseudocode sections: `OPC-PSEUDO-010`, `OPC-PSEUDO-011`, `OPC-PSEUDO-012`
Affected modules: PARTA, PDF, JSON, Preminulo lice
Business risk: user sees one composition and exports/renders another.
Current protection: source stores display flags in PREDMET and preview is source-confirmed.
Unsafe approach to avoid: one-off label/field fixes.
Safe upgrade boundary: preview/PDF/JSON consistency requires an owner-reviewed display matrix before behavior changes.
Characterization tests needed: title, middle name, nickname placement, rank, profession, script.
Owner decision needed: yes for final business display policy.
Implementation blocked until: display matrix is approved.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-003

Group name: PARTA/CITULJE display flags
Symptoms / child illnesses: nickname/title/rank/profession/middle-name flags are source-confirmed, while CITULJE workflow is only partial.
Affected pseudocode sections: `OPC-PSEUDO-010`
Affected modules: PARTA, CITULJE, PDF, IRiU
Business risk: public-facing text can be wrong or inconsistent.
Current protection: flags are stored on PREDMET; CITULJE document-scoped exclusions exist through IRiU truth.
Unsafe approach to avoid: making PARTA/CITULJE independent truth.
Safe upgrade boundary: display flags and CITULJE workflow remain coupled characterization evidence.
Characterization tests needed: PARTA preview and document outputs.
Owner decision needed: yes.
Implementation blocked until: CITULJE product workflow is owner-reviewed.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-004

Group name: Evaluator/advisor guidance strengthening
Symptoms / child illnesses: evaluator flags exist, but complete ceremony guidance/checklist does not.
Affected pseudocode sections: `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-007`, `OPC-PSEUDO-016`
Affected modules: evaluator, advisor, IRiU, finance, review
Business risk: user may miss operational consequences.
Current protection: IRiU truth and Blok 2 tests protect some rules.
Unsafe approach to avoid: scattered UI warnings without central owner taxonomy.
Safe upgrade boundary: advisor scope and scenario output contract require owner approval before behavior changes.
Characterization tests needed: death place, cremation, grobnica/grob, biohazard, international, reception.
Owner decision needed: yes.
Implementation blocked until: advisor/warning taxonomy is approved.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-005

Group name: IRiU truth engine stabilization
Symptoms / child illnesses: implemented truth rules drive multiple downstream modules.
Affected pseudocode sections: `OPC-PSEUDO-006`, `OPC-PSEUDO-007`, `OPC-PSEUDO-009`, `OPC-PSEUDO-008`
Affected modules: IRiU, finance, STANJE ROBE, PDF
Business risk: rule change can alter totals, stock, and documents.
Current protection: critical Blok 2 scenario tests.
Unsafe approach to avoid: changing category rules without downstream tests.
Safe upgrade boundary: condition matrix characterization is required before rule changes.
Characterization tests needed: active/suppressed/recommended/financial/derivative states.
Owner decision needed: only where business rule changes.
Implementation blocked until: scenario tests exist.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-006

Group name: STANJE ROBE consequence visibility
Symptoms / child illnesses: applied/restored/unresolved effects exist; close-block and user-visible unresolved paths need stronger confirmation.
Affected pseudocode sections: `OPC-PSEUDO-008`, `OPC-PSEUDO-012`, `OPC-PSEUDO-013`
Affected modules: STANJE ROBE, IRiU, JSON, review
Business risk: inventory consequences may be missed or duplicated.
Current protection: operational toggle and selected JSON transfer tests.
Unsafe approach to avoid: transferring warehouse quantities in single-PREDMET JSON.
Safe upgrade boundary: replacement paths and unresolved visibility require characterization before behavior changes.
Characterization tests needed: available->available, available->insufficient, insufficient->available, delete/remove.
Owner decision needed: yes for close-block/review UX.
Implementation blocked until: stock consequence audit is complete.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-007

Group name: Finance/payment consistency
Symptoms / child illnesses: finance combines IRiU, PIO/refund, JKP, advance, discount and PDF rows.
Affected pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-011`
Affected modules: finance, PDF, Platilac, JKP, PIO/refund
Business risk: wrong payable amount.
Current protection: source-confirmed calculation path; no full regression suite.
Unsafe approach to avoid: fixing one PDF total without service-level basis.
Safe upgrade boundary: financial truth basis requires characterization before presentation changes.
Characterization tests needed: included/excluded IRiU, refund, JKP self-pay, advance, discount.
Owner decision needed: yes for business edge cases.
Implementation blocked until: expected finance matrix is documented.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-008

Group name: PIO/refund guidance
Symptoms / child illnesses: refund logic exists in finance/PDF, but not as complete advisor guidance.
Affected pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-016`
Affected modules: PIO/refund, finance, advisor, PDF
Business risk: refund may be misunderstood.
Current protection: fields and PDF rows exist.
Unsafe approach to avoid: adding automatic guidance without owner policy.
Safe upgrade boundary: PIO/refund scenarios and expected text/finance results require owner approval before behavior changes.
Characterization tests needed: Serbian pensioner, payer self-refund, refund amount, spouse-right cases.
Owner decision needed: yes.
Implementation blocked until: refund guidance authority is defined.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-009

Group name: JKP/Platilac consistency
Symptoms / child illnesses: visible Platilac and internal narucilac coexist; JKP payer logic affects finance/PDF.
Affected pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-012`
Affected modules: Platilac, JKP, finance, PDF, JSON
Business risk: wrong payer responsibility or compatibility break.
Current protection: public terminology lineage and source-confirmed fields.
Unsafe approach to avoid: global rename without DB/JSON/template plan.
Safe upgrade boundary: compatibility and payer/JKP scenario characterization are required before behavior changes.
Characterization tests needed: same payer, separate payer, legal/physical, JKP self-pay.
Owner decision needed: yes.
Implementation blocked until: terminology compatibility plan exists.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-010

Group name: JSON import/version/freshness warnings
Symptoms / child illnesses: keep/replace/cancel is implemented; version warning matrix is owner-approved but not implemented.
Affected pseudocode sections: `OPC-PSEUDO-004`, `OPC-PSEUDO-012`
Affected modules: JSON transfer, PREDMET identity, version
Business risk: user may make conflict decision without enough version context.
Current protection: explicit user choice and tests for replacement/local id preservation.
Unsafe approach to avoid: silent overwrite or `exportDatum` authority.
Safe upgrade boundary: current conflict UI and version warning behavior require characterization before behavior changes.
Characterization tests needed: higher/lower/same/missing/malformed `verzija`.
Owner decision needed: yes for hard blocks, if any.
Implementation blocked until: JSON safety and platform parity gates.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-011

Group name: Firm-scoped identity guard
Symptoms / child illnesses: future-safe PIB + MB + brojPredmeta identity is policy, current implementation is narrower.
Affected pseudocode sections: `OPC-PSEUDO-004`, `OPC-PSEUDO-012`, `OPC-PSEUDO-013`
Affected modules: PREDMET identity, FirmaPodaci, JSON, backup/restore, Web/sync
Business risk: wrong-firm import/restore/sync conflict.
Current protection: owner decision and stop-list.
Unsafe approach to avoid: relying only on editable FirmaPodaci fields.
Safe upgrade boundary: firm identity/history audit is required before guard implementation.
Characterization tests needed: same/different PIB/MB, missing/malformed firm identity, backup restore mismatch.
Owner decision needed: yes for UX/history.
Implementation blocked until: repository identity gate and migration review.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-012

Group name: Version/change-log visibility
Symptoms / child illnesses: `verzija` exists; complete review change-log overview is missing.
Affected pseudocode sections: `OPC-PSEUDO-002`, `OPC-PSEUDO-004`, `OPC-PSEUDO-016`
Affected modules: lifecycle, review, JSON, future sync
Business risk: business changes are not reviewable enough for future conflict reasoning.
Current protection: confirmed-close snapshots and version logs.
Unsafe approach to avoid: treating export filename `_vN` as authoritative.
Safe upgrade boundary: increment coverage and review UI suitability require audit before behavior changes.
Characterization tests needed: save/no-change/close/change/reopen/replace flows.
Owner decision needed: yes for overview content and retention.
Implementation blocked until: version/change-log technical audit.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-013

Group name: Windows/Android runtime parity
Symptoms / child illnesses: shared Dart source exists, but fresh full parity smoke was not run.
Affected pseudocode sections: all
Affected modules: all user workflows
Business risk: platform behavior drift.
Current protection: shared source and manifest rule.
Unsafe approach to avoid: assuming release parity from source inspection only.
Safe upgrade boundary: parity-sensitive behavior requires explicit runtime characterization.
Characterization tests needed: create/open/save/close, PDF, JSON import, stock, auth, settings.
Owner decision needed: only if behavior differences are intentional.
Implementation blocked until: platform parity gate for behavior changes.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-014

Group name: Entitlement/package enforcement
Symptoms / child illnesses: package/add-on gating exists; payment/access implementation is blocked.
Affected pseudocode sections: `OPC-PSEUDO-014`, `OPC-PSEUDO-015`
Affected modules: packages/licensing, roles, settings, documents, STANJE ROBE
Business risk: disabled module still changes data, or invalid license over-unlocks.
Current protection: safe fallback to Osnovni and parser tests.
Unsafe approach to avoid: package gates that mutate PREDMET truth.
Safe upgrade boundary: entitlement behavior requires characterization before payment/access implementation.
Characterization tests needed: missing/invalid license, package levels, add-ons, production unsafe sources.
Owner decision needed: yes for commercial/payment model.
Implementation blocked until: payment/access gate.

## UPGRADE-GROUP-ID: OPC-SAFE-UPGRADE-015

Group name: Document engine/add-on boundary
Symptoms / child illnesses: documents are entitlement-gated outputs; future document engine/add-ons are not full architecture.
Affected pseudocode sections: `OPC-PSEUDO-011`, `OPC-PSEUDO-014`
Affected modules: PDF/documents, packages/licensing, PARTA/CITULJE
Business risk: document output becomes hidden policy source.
Current protection: PREDMET truth manifest and source-of-truth map.
Unsafe approach to avoid: implementing document add-ons as independent data owners.
Safe upgrade boundary: document data contract and entitlement boundary require audit before behavior changes.
Characterization tests needed: visible actions, data builder outputs, package/add-on combinations.
Owner decision needed: yes for document product packaging.
Implementation blocked until: document engine boundary is approved.

## Control-Plan Grouped Families Cross-Reference

Source document: `docs/OPC_GROUPED_SAFE_UPGRADE_PLAN.md`

This cross-reference records the grouped families created by the modular foundation control-plan task. It is not a roadmap, sequence, priority order, or recommended next task list.

| Upgrade family | Related pseudocode sections | Boundary |
| --- | --- | --- |
| Manual number formatting / UI validation | `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-020` | Characterize display/validation before behavior changes. |
| Display composition consistency across preview/PDF/JSON | `OPC-PSEUDO-010`, `OPC-PSEUDO-011`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020` | Outputs remain PREDMET-derived. |
| PARTA/CITULJE display flags | `OPC-PSEUDO-010`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020` | Display flags must not rewrite identity truth. |
| Evaluator/advisor guidance strengthening | `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-016`, `OPC-PSEUDO-020` | Advisor must stay derivative and owner-scoped. |
| IRiU truth engine stabilization | `OPC-PSEUDO-006`, `OPC-PSEUDO-007`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020` | Preserve selected-row truth and KATALOG separation. |
| STANJE ROBE consequence visibility | `OPC-PSEUDO-008`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020`, `OPC-PSEUDO-021` | Operational consequence only; no parallel PREDMET/KATALOG truth. |
| Finance/payment consistency | `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-020` | Finance remains PREDMET/IRiU-derived. |
| PIO/refund guidance | `OPC-PSEUDO-009`, `OPC-PSEUDO-016`, `OPC-PSEUDO-020` | Guidance requires owner-approved policy. |
| JKP/Platilac consistency | `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-012`, `OPC-PSEUDO-020` | Preserve compatibility until owner-approved cleanup. |
| JSON import/version/freshness warnings | `OPC-PSEUDO-004`, `OPC-PSEUDO-012`, `OPC-PSEUDO-019`, `OPC-PSEUDO-020`, `OPC-PSEUDO-021` | Keep explicit user choice unless owner changes rule. |
| Firm-scoped identity guard | `OPC-PSEUDO-004`, `OPC-PSEUDO-012`, `OPC-PSEUDO-013`, `OPC-PSEUDO-019`, `OPC-PSEUDO-021` | `PIB + Maticni broj + brojPredmeta` remains future-safe identity scope. |
| Version/change-log visibility | `OPC-PSEUDO-002`, `OPC-PSEUDO-004`, `OPC-PSEUDO-016`, `OPC-PSEUDO-019`, `OPC-PSEUDO-021` | `verzija` is a business-version signal; export metadata is not authority. |
| Windows/Android runtime parity | all pseudocode sections | Runtime parity requires characterization. |
| Entitlement/package enforcement | `OPC-PSEUDO-014`, `OPC-PSEUDO-015`, `OPC-PSEUDO-018`, `OPC-PSEUDO-021` | Access controls availability, not PREDMET truth. |
| Document engine/add-on boundary | `OPC-PSEUDO-011`, `OPC-PSEUDO-014`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020` | Documents remain derivative outputs. |
| Future OPC Web/sync readiness | `OPC-PSEUDO-018`, `OPC-PSEUDO-019`, `OPC-PSEUDO-020`, `OPC-PSEUDO-021` | Guardrail/audit only; no Web architecture implementation. |

Safe upgrade note: these families require characterization evidence, owner decisions, or technical audits where listed in `docs/OPC_GROUPED_SAFE_UPGRADE_PLAN.md`. They do not authorize implementation.

## Characterization Evidence Foundation Cross-Reference

Source documents:

- `docs/OPC_CHARACTERIZATION_EVIDENCE_FOUNDATION.md`
- `docs/OPC_CHARACTERIZATION_COVERAGE_MATRIX.md`
- `docs/OPC_CHARACTERIZATION_GAP_REGISTER.md`
- `docs/OPC_CHARACTERIZATION_BEFORE_CHANGE_RULES.md`

Related pseudocode sections: `OPC-PSEUDO-022`, `OPC-PSEUDO-023`, `OPC-PSEUDO-024`, `OPC-PSEUDO-025`, `OPC-PSEUDO-026`

Safe upgrade note: before any future behavior change, current behavior evidence must be classified without promoting source-confirmed behavior into test-confirmed behavior, documented policy into implementation proof, or runtime history into current parity proof.

Gap handling rule: if a characterization gap is found, classify the gap, link it to module contract and pseudocode, and do not create a task recommendation, sequence, roadmap, or priority order.
