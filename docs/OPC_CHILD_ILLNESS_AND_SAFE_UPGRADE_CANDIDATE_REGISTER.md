# OPC Child-Illness And Safe Upgrade Candidate Register

Status: public grouped symptom and safe-upgrade register.

Base commit: `90c203947cd781d6bd837647485b10d72f181fe2`

This register groups unresolved symptoms. It does not turn symptoms into nano-tasks and does not authorize implementation.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-001

Group name: UI number formatting and numeric validation consistency
Symptoms: manual amount/number formatting, inconsistent parse/display risk, possible text-field edge cases.
Examples: finance amounts, IRiU amounts, JKP costs, refund/advance/discount fields.
Affected modules: Finance/payment, IRiU, PDF, JSON.
Business risk: wrong or confusing displayed money values.
User-facing risk: user may misread totals or exported documents.
Source evidence: `finansije_segment.dart`; `iriu_segment.dart`; `financial_truth_service.dart`; PDF builders.
Test evidence: no dedicated finance formatting regression suite found.
Likely cause category:
- formatting
- validation
- financial consistency
Safe upgrade strategy: group all numeric formatting/validation under one finance-display stabilization task with tests.
Unsafe approach to avoid: changing PREDMET storage semantics to fix display formatting.
Suggested goal-task grouping: Finance and numeric display consistency audit/test package.
Priority: medium/high.
Owner decision needed: no for audit; yes for any changed business rounding/display policy.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-002

Group name: PARTA/PDF display composition rules
Symptoms: display composition is spread across PREDMET fields, segment state, and PDF builders.
Examples: PARTA name display, mourners, symbol, script, ceremony time, document labels.
Affected modules: PARTA, PDF, Preminulo lice, Ceremony, CITULJE.
Business risk: public-facing document mismatch.
User-facing risk: preview/final output may not match user expectation.
Source evidence: `parte_segment.dart`; `predmeti_table.dart`; `lib/features/predmeti/pdf/*.dart`.
Test evidence: no dedicated PARTA/PDF render tests found.
Likely cause category:
- display composition
- document derivative mismatch
- UX clarity
Safe upgrade strategy: define expected composition matrix and add render/data-builder tests before UI/PDF changes.
Unsafe approach to avoid: making PARTA an independent case truth.
Suggested goal-task grouping: PARTA/PDF display composition consistency audit.
Priority: high.
Owner decision needed: yes for final display wording/ordering.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-003

Group name: Nickname/title/rank/profession/middle-name display flags
Symptoms: many personal fields and flags affect display; expected combinations are not fully documented/tested.
Examples: nickname, title before name, rank on parta, profession on parta, middle name display.
Affected modules: Preminulo lice, PARTA, PDF, JSON.
Business risk: sensitive or incorrect public identity display.
User-facing risk: document output may omit or include undesired identity details.
Source evidence: `predmeti_table.dart`; `preminulo_lice_segment.dart`; `parte_segment.dart`; PDF builders.
Test evidence: no dedicated display-flag tests found.
Likely cause category:
- display composition
- UX clarity
Safe upgrade strategy: group flags into one identity-display rules matrix.
Unsafe approach to avoid: fixing each flag as a separate nano-task.
Suggested goal-task grouping: PREDMET identity display flags matrix and tests.
Priority: high.
Owner decision needed: yes for expected public display policy.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-004

Group name: Document preview versus final PDF consistency
Symptoms: document data builders, preview sections, and final PDF exporters may not share one tested contract.
Examples: payer labels, refund rows, JKP rows, ceremony/opelo fields, version/status snapshot labels.
Affected modules: PDF/documents, Finance, Payer, Ceremony, Review.
Business risk: office user may approve one view and produce another.
User-facing risk: wrong document content.
Source evidence: `predmet_screen.dart`; `lista_pdf_data_builder.dart`; `predmet_pdf_snapshot_export.dart`; PDF exporters.
Test evidence: no complete PDF render/preview parity tests found.
Likely cause category:
- document derivative mismatch
- UX clarity
- financial consistency
Safe upgrade strategy: create document data-contract tests before changing rendering.
Unsafe approach to avoid: patching one PDF label without checking related outputs.
Suggested goal-task grouping: Document preview/final PDF parity audit.
Priority: high.
Owner decision needed: yes for terminology/display choices.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-005

Group name: Evaluator/advisor missing guidance
Symptoms: current evaluator derives flags and IRiU consequences but does not produce complete ceremony guidance/checklist.
Examples: no unified warning taxonomy, no complete PIO/JKP/document/stock advisor output.
Affected modules: Business policy evaluator, IRiU, Finance, PDF, STANJE ROBE, Pregled i potvrda.
Business risk: user may miss operational consequences.
User-facing risk: guidance appears fragmented across modules.
Source evidence: `business_policy_evaluator.dart`; `iriu_truth_rules.dart`; `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`.
Test evidence: Blok 2 scenarios test-confirmed; broader guidance tests missing.
Likely cause category:
- evaluator/advisor gap
Safe upgrade strategy: owner decision on advisor scope, then scenario tests and output contract.
Unsafe approach to avoid: adding scattered warnings in UI/PDF without central policy.
Suggested goal-task grouping: Ceremony advisor scope and scenario-contract audit.
Priority: high.
Owner decision needed: yes.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-006

Group name: PIO/refund guidance gaps
Symptoms: refund fields exist and finance/PDF use them, but evaluator/advisor ownership is incomplete.
Examples: Serbian pensioner, payer self-refund, spouse rights, refund amount settings.
Affected modules: Statusi, Finance, PDF, PIO/refund, Advisor.
Business risk: payable amount or refund instruction may be misunderstood.
User-facing risk: incorrect payment guidance.
Source evidence: `preminulo_lice_segment.dart`; `finansije_segment.dart`; `podesavanja_screen.dart`; `lista_pdf_data_builder.dart`.
Test evidence: refund migration evidence only; no full refund scenario tests found.
Likely cause category:
- financial consistency
- evaluator/advisor gap
Safe upgrade strategy: map PIO/refund scenarios and finance/PDF outputs before implementation.
Unsafe approach to avoid: adding refund automation without owner-approved rule matrix.
Suggested goal-task grouping: PIO/refund rule and output consistency audit.
Priority: high.
Owner decision needed: yes for guidance wording/authority.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-007

Group name: JKP/Platilac consistency gaps
Symptoms: payer/JKP logic is implemented but terminology and responsibility paths need stronger tests.
Examples: `naruIstiZaJkp`, `jkpPlacaSamostalno`, legal/physical payer variants, `narucilac` internal naming.
Affected modules: Platilac, JKP, Finance, PDF, JSON.
Business risk: wrong payer or wrong JKP cost responsibility.
User-facing risk: confusing labels and totals.
Source evidence: `narucilac_segment.dart`; `finansije_segment.dart`; `lista_pdf_data_builder.dart`; terminology lineage docs.
Test evidence: contact JSON tests; no full payer/JKP finance tests found.
Likely cause category:
- financial consistency
- UX clarity
- display composition
Safe upgrade strategy: preserve compatibility names until owner-approved cleanup; add payer/JKP scenario tests.
Unsafe approach to avoid: global rename of `narucilac` without migration/JSON/template plan.
Suggested goal-task grouping: Platilac/JKP compatibility and finance-output audit.
Priority: high.
Owner decision needed: yes for terminology cleanup.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-008

Group name: Firm identity guard gaps
Symptoms: owner-approved future firm-scoped identity guard is not implemented/proven.
Examples: PIB + MB + brojPredmeta policy; editable FirmaPodaci; missing history.
Affected modules: FirmaPodaci, JSON, backup/restore, Web/sync, PREDMET identity.
Business risk: wrong-firm import/restore or future sync conflict.
User-facing risk: data corruption or unsafe replacement.
Source evidence: `firma_podaci_table.dart`; `json_export_import.dart`; owner decision report; stop-list.
Test evidence: no full firm identity guard tests found.
Likely cause category:
- identity/firm scope
- import/export transfer
Safe upgrade strategy: identity/history technical audit before any guard implementation.
Unsafe approach to avoid: relying only on editable firm display fields.
Suggested goal-task grouping: Firma identity/history and import/restore guard design.
Priority: critical.
Owner decision needed: partly already decided; more needed for UX/history.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-009

Group name: Version/change-log visibility gaps
Symptoms: `verzija` exists and owner decision defines future conflict policy, but no complete change-log overview exists.
Examples: higher/lower/same/missing/malformed version warnings not implemented; change-log overview intended for Pregled i potvrda.
Affected modules: PREDMET lifecycle, JSON, Pregled i potvrda, future sync.
Business risk: user cannot review business-version history reliably.
User-facing risk: uncertain import/review decisions.
Source evidence: `predmeti_repository.dart`; `log_izmena_table.dart`; `json_export_import.dart`; version owner decision docs.
Test evidence: no full version/change-log tests found.
Likely cause category:
- data model limitation
- UX clarity
- import/export transfer
Safe upgrade strategy: audit version increments, log data source, and review UI before implementation.
Unsafe approach to avoid: using `exportDatum` or filename `_vN` as authority.
Suggested goal-task grouping: PREDMET version/change-log suitability audit.
Priority: high.
Owner decision needed: yes for display content/retention.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-010

Group name: Windows/Android runtime parity gaps
Symptoms: shared code suggests parity, but fresh full runtime smoke was not performed in these docs-only audits.
Examples: dialogs, file pickers, PDF actions, import conflict UI, full PREDMET flow.
Affected modules: all user workflows.
Business risk: same product logic may behave differently by platform.
User-facing risk: platform-specific confusion.
Source evidence: shared Dart source and manifest parity policy.
Test evidence: selected smoke tests; no full parity run.
Likely cause category:
- runtime parity
Safe upgrade strategy: explicit parity validation task with fixed scenarios.
Unsafe approach to avoid: assuming parity from source alone for release decisions.
Suggested goal-task grouping: Windows/Android OPC workflow parity smoke.
Priority: medium/high.
Owner decision needed: no for validation; yes for product behavior differences.
Technical audit needed: yes.

## ISSUE-GROUP-ID: OPC-UPGRADE-GROUP-011

Group name: JSON/backup/restore safety gaps
Symptoms: transfer works, but firm identity guard, backup/restore guard, version warnings, and full stock restore policy remain incomplete.
Examples: single-PREDMET same-case conflict, full backup destructive import, unresolved stock transfer blocks, PIB/MB mismatch policy.
Affected modules: JSON transfer, backup/restore, FirmaPodaci, STANJE ROBE, PREDMET identity.
Business risk: unsafe import/restore, wrong-firm data, confusing freshness decisions.
User-facing risk: accidental data replacement.
Source evidence: `json_export_import.dart`; `predmet_json_transfer_core.dart`; backup policy summary; stop-list.
Test evidence: `test/json_transfer_regression_test.dart`; no full identity guard tests.
Likely cause category:
- import/export transfer
- identity/firm scope
- data model limitation
Safe upgrade strategy: keep JSON/backup as one grouped safety program, not product center.
Unsafe approach to avoid: making JSON/backup/restore the strategic center of OPC understanding.
Suggested goal-task grouping: Transfer safety and repository identity audit.
Priority: critical.
Owner decision needed: yes for guard UX and hard-block details.
Technical audit needed: yes.

## Register Summary

The safe pattern is grouped stabilization:

- display composition as a group;
- finance/refund/JKP as a group;
- evaluator/advisor as a group;
- identity/transfer/version as a group;
- runtime parity as a validation group.

The unsafe pattern is nano-tasking symptoms or using one symptom to redefine PREDMET truth.

