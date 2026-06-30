# OPC Module Contracts And Truth Boundaries

Status: docs-only contract matrix.

Base commit: `9bea04a6411c92a045a39f8b8a522dafa9dbcf98`

This document records module contracts and truth boundaries. It does not authorize source, database, schema, migration, UI, PDF, JSON, import/export, backup/restore, evaluator, IRiU, STANJE ROBE, finance, entitlement, role, Web, sync, storage, payment, or test behavior changes.

Classification labels follow the current OPC public docs.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-001

Module name: PREDMET core
Module class: PREDMET core
Business purpose: central case container, workflow state, lifecycle, version, and master business truth.
Reads from PREDMET: all PREDMET fields.
Reads from other modules: local user/session defaults, settings defaults, IRiU initialization rules.
May write to: PREDMET row, logs, lifecycle rows, related cleanup through repository flows.
Must not write to: derivative outputs as independent truth.
Outputs: source data for all modules and derivatives.
Allowed side effects: create/save/close/reopen/finish/anonymize/delete according to current repository behavior.
Forbidden side effects: redefining PREDMET meaning through Web, PDF, JSON, package, finance, or stock work.
Truth boundary: only master business truth.
Pseudocode sections: `OPC-PSEUDO-001`, `OPC-PSEUDO-002`, `OPC-PSEUDO-018`, `OPC-PSEUDO-019`.
Characterization evidence needed: lifecycle/version/log coverage and runtime parity.
Web readiness relevance: critical.
Upgrade risk: all modules depend on it.
Implementation blocked until: behavior change has characterization and owner-approved rule change.
Evidence: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`.
Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-002

Module name: Preminulo lice
Module class: PREDMET-consuming
Business purpose: deceased-person identity and death facts for documents, display, evaluator, JSON, and review.
Reads from PREDMET: name, surname, JMBG, birth/death facts, address, parents, spouse, profession/title/rank/nickname/display flags.
Reads from other modules: none as master truth.
May write to: PREDMET person/death/display fields.
Must not write to: canonical system identity outside PREDMET.
Outputs: identity and death facts for derivatives.
Allowed side effects: field updates inside PREDMET.
Forbidden side effects: treating name or filename as global identity.
Truth boundary: PREDMET fields remain truth; displays are derivatives.
Pseudocode sections: `OPC-PSEUDO-010`, `OPC-PSEUDO-018`.
Characterization evidence needed: display flag and identity composition matrix.
Web readiness relevance: high.
Upgrade risk: identity/display drift.
Implementation blocked until: owner-approved display rules exist.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-003

Module name: Platilac / legacy narucilac terminology area
Module class: finance / PREDMET-consuming
Business purpose: payer identity and responsibility while preserving legacy internal compatibility.
Reads from PREDMET: `naru*`, payer physical/legal fields, `narucilacRefundira`.
Reads from other modules: spouse data, FirmaPodaci shortcuts, contacts.
May write to: payer fields and contact rows.
Must not write to: DB/JSON terminology migration without owner-approved plan.
Outputs: payer data for finance, PDF, JSON, and conflict meaning.
Allowed side effects: payer field/contact updates.
Forbidden side effects: global rename that breaks compatibility.
Truth boundary: visible Platilac is business display; legacy names remain compatibility area.
Pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-012`, `OPC-PSEUDO-018`.
Characterization evidence needed: payer/JKP/finance/PDF/JSON cases.
Web readiness relevance: high.
Upgrade risk: payer responsibility and compatibility break.
Implementation blocked until: terminology compatibility plan and owner decision.
Evidence: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`.
Classification: `FUNCTIONAL BUT ROUGH / OWNER DECISION REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-004

Module name: JKP payer/responsibility
Module class: finance / PREDMET-consuming
Business purpose: record JKP payment responsibility and relationship to primary payer.
Reads from PREDMET: `naruIstiZaJkp`, `jkp*`, `jkpPlacaSamostalno`, `troskoviJkp`.
Reads from other modules: Platilac.
May write to: JKP PREDMET fields.
Must not write to: finance totals without characterized rule path.
Outputs: JKP responsibility for finance/PDF/JSON.
Allowed side effects: copy/clear JKP fields according to current behavior.
Forbidden side effects: changing payer responsibility by label cleanup.
Truth boundary: PREDMET stores responsibility; documents render it.
Pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-018`.
Characterization evidence needed: same/separate/self-pay scenarios.
Web readiness relevance: medium.
Upgrade risk: wrong costs or payer display.
Implementation blocked until: payer/JKP scenario coverage exists.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-005

Module name: Ceremony / groblje / grobno mesto / opelo / docek
Module class: PREDMET-consuming
Business purpose: ceremony facts used by documents, evaluator, IRiU, PARTA, and review.
Reads from PREDMET: ceremony type/date/time, cemetery, grave, opelo, ispracaj, out-of-country, reception fields.
Reads from other modules: death facts for evaluator context.
May write to: ceremony PREDMET fields.
Must not write to: evaluator policy as hidden UI state.
Outputs: ceremony facts and evaluator inputs.
Allowed side effects: field updates inside PREDMET.
Forbidden side effects: incomplete guidance becoming authoritative policy.
Truth boundary: PREDMET ceremony fields are truth; evaluator/advisor outputs are derived.
Pseudocode sections: `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-016`, `OPC-PSEUDO-018`.
Characterization evidence needed: ceremony/evaluator scenario matrix.
Web readiness relevance: high.
Upgrade risk: wrong service/document consequences.
Implementation blocked until: guidance scope and scenario behavior are characterized.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`.
Classification: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-006

Module name: PIO / refund / posmrtna pomoc
Module class: finance / PREDMET-consuming
Business purpose: pension/refund context for finance and documents.
Reads from PREDMET: status, pensioner/refund fields, spouse-right fields, payer refund choice.
Reads from other modules: settings refund amount, Platilac, finance.
May write to: finance/status PREDMET fields.
Must not write to: automatic refund policy without owner decision.
Outputs: refund display and finance/PDF inputs.
Allowed side effects: updating refund-related fields.
Forbidden side effects: hidden automatic guidance with unapproved policy.
Truth boundary: refund facts are PREDMET/setting-derived; guidance is derivative.
Pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-016`, `OPC-PSEUDO-018`.
Characterization evidence needed: refund scenarios and document outputs.
Web readiness relevance: medium.
Upgrade risk: wrong payable amount or instruction.
Implementation blocked until: owner-approved refund guidance rules.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-007

Module name: Business policy evaluator
Module class: advisor/guidance
Business purpose: derive policy/consequence snapshot from PREDMET facts.
Reads from PREDMET: death, ceremony, cemetery/grave, international/reception, scenario facts.
Reads from other modules: business scenario id/rules.
May write to: no direct PREDMET write; services may apply planned IRiU consequences.
Must not write to: hidden PREDMET truth.
Outputs: evaluator snapshot and consequence inputs.
Allowed side effects: none directly.
Forbidden side effects: nondeterministic or UI-only policy.
Truth boundary: derived policy layer; PREDMET facts remain truth.
Pseudocode sections: `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Characterization evidence needed: scenario matrix and missing guidance list.
Web readiness relevance: high.
Upgrade risk: finance/IRiU/document drift.
Implementation blocked until: characterization and owner-approved rule change for behavior changes.
Evidence: `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`.
Classification: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-008

Module name: Advisor/guidance future layer
Module class: advisor/guidance
Business purpose: future consolidated warnings, checklist, and explanation.
Reads from PREDMET: all relevant facts.
Reads from other modules: evaluator, IRiU, finance, STANJE ROBE, review.
May write to: not implemented.
Must not write to: PREDMET truth or module truth without explicit design.
Outputs: future user-facing guidance.
Allowed side effects: none until implemented.
Forbidden side effects: Codex-created strategy or hidden business policy.
Truth boundary: derivative guidance only.
Pseudocode sections: `OPC-PSEUDO-016`, `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Characterization evidence needed: warning taxonomy and source of authority.
Web readiness relevance: high.
Upgrade risk: invented policy.
Implementation blocked until: owner decision and technical audit.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_MODULAR_FOUNDATION_CONTROL_PLAN.md`.
Classification: `POLICY EXISTS / IMPLEMENTATION NOT FOUND / OWNER DECISION REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-009

Module name: IRiU
Module class: operational / finance / PREDMET-consuming
Business purpose: selected goods/services attached to a PREDMET.
Reads from PREDMET: case id and policy-relevant facts.
Reads from other modules: KATALOG, evaluator, IRiU truth rules.
May write to: IRiU rows and lifecycle decisions.
Must not write to: PREDMET truth except through explicit PREDMET workflow.
Outputs: service rows, finance inputs, stock consequences, documents, JSON rows.
Allowed side effects: managed row state changes under current rules.
Forbidden side effects: retroactive overwrite from current KATALOG or hidden finance changes.
Truth boundary: selected case rows are PREDMET-scoped operational/business snapshot; KATALOG owns catalog truth.
Pseudocode sections: `OPC-PSEUDO-006`, `OPC-PSEUDO-007`, `OPC-PSEUDO-018`.
Characterization evidence needed: full category/rule map.
Web readiness relevance: high.
Upgrade risk: finance/stock/document drift.
Implementation blocked until: category behavior is characterized.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-010

Module name: STANJE ROBE
Module class: stock / operational
Business purpose: inventory state and consequences for covered IRiU categories.
Reads from PREDMET: case status and selected IRiU rows.
Reads from other modules: KATALOG stable article identity, entitlements/settings, stock repositories.
May write to: stock rows, effect rows, consequence records.
Must not write to: PREDMET truth or KATALOG truth.
Outputs: stock state, applied/restored/unresolved consequences, operational warnings.
Allowed side effects: stock decrement/restore and consequence lifecycle under current rules.
Forbidden side effects: guessed relinking, local DB id binding, parallel case truth.
Truth boundary: operational layer over KATALOG and selected PREDMET/IRiU consequences.
Pseudocode sections: `OPC-PSEUDO-008`, `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Characterization evidence needed: consequence transfer/restore/sync audit.
Web readiness relevance: high.
Upgrade risk: data loss or parallel truth.
Implementation blocked until: stock lifecycle contract and Web/sync risk are audited.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-011

Module name: Finance/payment
Module class: finance
Business purpose: calculate and display PREDMET financial state.
Reads from PREDMET: advance, discount, JKP, payment method/notes, refund, payer fields.
Reads from other modules: IRiU financial truth, settings.
May write to: finance PREDMET fields.
Must not write to: IRiU/KATALOG/PREDMET identity truth.
Outputs: finance UI and financial PDFs.
Allowed side effects: updating finance fields.
Forbidden side effects: changing totals without characterized rules.
Truth boundary: calculated from PREDMET and IRiU; not independent truth.
Pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-018`.
Characterization evidence needed: finance matrix and PDF consistency.
Web readiness relevance: medium.
Upgrade risk: wrong payable amount.
Implementation blocked until: finance edge cases are characterized.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-012

Module name: PARTA
Module class: derivative/render
Business purpose: public/display composition from PREDMET fields.
Reads from PREDMET: symbol, script, parte name, mourners, identity/display flags, ceremony fields.
Reads from other modules: PDF/documents, entitlement where applicable.
May write to: PARTA display fields on PREDMET.
Must not write to: independent identity truth.
Outputs: PARTA display/document output.
Allowed side effects: update PREDMET-scoped display fields.
Forbidden side effects: using PARTA as master person/case identity.
Truth boundary: derivative display.
Pseudocode sections: `OPC-PSEUDO-010`, `OPC-PSEUDO-018`.
Characterization evidence needed: display flag matrix.
Web readiness relevance: medium.
Upgrade risk: public display drift.
Implementation blocked until: owner-approved display rules.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_CHILD_ILLNESS_AND_SAFE_UPGRADE_CANDIDATE_REGISTER.md`.
Classification: `PARTIALLY IMPLEMENTED / TEST GAP`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-013

Module name: CITULJE
Module class: derivative/render / add-on/package
Business purpose: obituary-related document/output area linked to PREDMET and IRiU categories.
Reads from PREDMET: identity, display, ceremony fields.
Reads from other modules: IRiU categories, entitlement/packages, PDF/documents.
May write to: unclear beyond PREDMET/IRiU fields already documented.
Must not write to: independent obituary truth.
Outputs: obituary-related output where implemented.
Allowed side effects: none beyond documented PREDMET/IRiU updates.
Forbidden side effects: placeholder narrative becoming truth.
Truth boundary: derivative/add-on output.
Pseudocode sections: `OPC-PSEUDO-010`, `OPC-PSEUDO-011`, `OPC-PSEUDO-018`.
Characterization evidence needed: CITULJE workflow extraction.
Web readiness relevance: medium.
Upgrade risk: independent document truth.
Implementation blocked until: workflow and package boundary audit.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`.
Classification: `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-014

Module name: PDF/document generation
Module class: derivative/render
Business purpose: produce PREDMET-derived documents.
Reads from PREDMET: identity, death, payer, JKP, ceremony, opelo, IRiU, finance, firm, adviser, version/status.
Reads from other modules: IRiU, finance, FirmaPodaci, entitlement.
May write to: output files only; no PREDMET truth.
Must not write to: source data as a side effect of rendering.
Outputs: PDFs and document snapshots.
Allowed side effects: generate document artifacts.
Forbidden side effects: document output becoming hidden policy source.
Truth boundary: derivative output.
Pseudocode sections: `OPC-PSEUDO-011`, `OPC-PSEUDO-018`.
Characterization evidence needed: document data contracts and render tests.
Web readiness relevance: medium.
Upgrade risk: output drift or terminology mismatch.
Implementation blocked until: document contract tests/audit exist.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-015

Module name: JSON single-PREDMET transfer
Module class: transfer
Business purpose: transfer one PREDMET and approved related rows.
Reads from PREDMET: PREDMET row, IRiU, contacts, metadata, unresolved stock consequence context.
Reads from other modules: repositories and transfer core.
May write to: imported/replaced PREDMET and related rows through explicit import path.
Must not write to: local state through silent overwrite.
Outputs: single-PREDMET JSON file and import result.
Allowed side effects: create/replace by user choice.
Forbidden side effects: filename/export date authority; automatic overwrite.
Truth boundary: transfer layer; not identity authority.
Pseudocode sections: `OPC-PSEUDO-004`, `OPC-PSEUDO-012`, `OPC-PSEUDO-019`, `OPC-PSEUDO-021`.
Characterization evidence needed: version/freshness/conflict matrix.
Web readiness relevance: critical.
Upgrade risk: wrong-case or wrong-firm conflict.
Implementation blocked until: owner-approved conflict guard policy.
Evidence: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`.
Classification: `SOURCE-CONFIRMED / OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-016

Module name: Backup/restore
Module class: transfer / support/access
Business purpose: full local database backup and recovery.
Reads from PREDMET: broad local database sections.
Reads from other modules: DB/repositories and backup payload.
May write to: broad local data during restore.
Must not write to: wrong firm database without guard; no behavior change in this task.
Outputs: backup JSON and restore result.
Allowed side effects: destructive restore only through authorized current flow.
Forbidden side effects: hidden cross-firm restore or sync substitute.
Truth boundary: recovery layer; not product center.
Pseudocode sections: `OPC-PSEUDO-013`, `OPC-PSEUDO-019`, `OPC-PSEUDO-021`.
Characterization evidence needed: PIB/MB guard and destructive restore behavior.
Web readiness relevance: critical.
Upgrade risk: data loss/wrong-firm restore.
Implementation blocked until: repository identity guard audit.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`.
Classification: `DOCUMENTED POLICY / POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-017

Module name: Pregled i potvrda
Module class: advisor/guidance / support
Business purpose: review state, saved state, lifecycle actions, version visibility, and future guidance location.
Reads from PREDMET: all section states, status, version, dirty/saved state.
Reads from other modules: evaluator, IRiU, finance, STANJE ROBE consequences.
May write to: lifecycle/status/log changes through repository actions.
Must not write to: hidden advisor truth.
Outputs: review/confirmation state.
Allowed side effects: save/close/reopen lifecycle actions.
Forbidden side effects: dense warnings without owner-approved taxonomy.
Truth boundary: review surface over PREDMET truth and module consequences.
Pseudocode sections: `OPC-PSEUDO-016`, `OPC-PSEUDO-019`, `OPC-PSEUDO-021`.
Characterization evidence needed: review structure and change-log suitability audit.
Web readiness relevance: high.
Upgrade risk: confusing confirmation or conflict context.
Implementation blocked until: owner-approved overview and warning policy.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_OWNER_DECISION_REPORT.md`.
Classification: `SOURCE-CONFIRMED / OWNER DECISION`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-018

Module name: Lifecycle/log/version/change-log
Module class: core support
Business purpose: record lifecycle transitions, version signal, logs, and future change history.
Reads from PREDMET: current/prior snapshots and lifecycle status.
Reads from other modules: JSON, review, repository logs.
May write to: status, version, logs.
Must not write to: conflict authority based on filename/export date.
Outputs: version/log data.
Allowed side effects: lifecycle/log writes under current repository behavior.
Forbidden side effects: treating export metadata as business freshness.
Truth boundary: PREDMET business-version support.
Pseudocode sections: `OPC-PSEUDO-002`, `OPC-PSEUDO-004`, `OPC-PSEUDO-016`, `OPC-PSEUDO-019`.
Characterization evidence needed: increment/log coverage.
Web readiness relevance: critical.
Upgrade risk: conflict reasoning without reliable history.
Implementation blocked until: lifecycle/version/log audit.
Evidence: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`.
Classification: `OWNER DECISION / SOURCE-CONFIRMED / IMPLEMENTATION REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-019

Module name: KATALOG
Module class: core support
Business purpose: catalog article truth for article identity, categories, prices, photos, and display data.
Reads from PREDMET: not as master; IRiU reads KATALOG.
Reads from other modules: settings/admin catalog data.
May write to: KATALOG article rows and stable article identity.
Must not write to: selected PREDMET/IRiU snapshots retroactively.
Outputs: catalog choices and stable article ids.
Allowed side effects: catalog admin changes.
Forbidden side effects: guessed relinking/backfill from names/prices/categories/local ids.
Truth boundary: catalog truth, not PREDMET truth.
Pseudocode sections: `OPC-PSEUDO-006`, `OPC-PSEUDO-008`, `OPC-PSEUDO-018`.
Characterization evidence needed: KATALOG/IRiU/STANJE ROBE binding scenarios.
Web readiness relevance: high.
Upgrade risk: wrong stock or selected-row identity.
Implementation blocked until: stable identity and transfer behavior are characterized.
Evidence: `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`; `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`.
Classification: `SOURCE-CONFIRMED / DOCUMENTED POLICY`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-020

Module name: FirmaPodaci
Module class: support/access
Business purpose: firm display/settings data and future identity input.
Reads from PREDMET: not primarily.
Reads from other modules: settings repository.
May write to: firm/settings tables.
Must not write to: immutable firm identity assumptions without audit.
Outputs: firm data for documents/settings and future guard input.
Allowed side effects: editable firm settings changes.
Forbidden side effects: treating mutable display fields as stable Web/sync identity.
Truth boundary: firm display/settings data; stable identity not proven.
Pseudocode sections: `OPC-PSEUDO-013`, `OPC-PSEUDO-019`, `OPC-PSEUDO-021`.
Characterization evidence needed: firm identity/history audit.
Web readiness relevance: critical.
Upgrade risk: wrong-firm import/restore/sync.
Implementation blocked until: owner-approved firm identity model.
Evidence: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`.
Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-021

Module name: Users/auth/recovery
Module class: support/access
Business purpose: local login, PIN, recovery, and session context.
Reads from PREDMET: PREDMET stores adviser/user references.
Reads from other modules: auth repository/session service.
May write to: user/session/PIN state and PREDMET actor metadata.
Must not write to: cross-device role/license identity without audit.
Outputs: authenticated local session.
Allowed side effects: login, reset, recovery, role-local controls.
Forbidden side effects: changing case truth through access state.
Truth boundary: actor/access context only.
Pseudocode sections: `OPC-PSEUDO-015`, `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Characterization evidence needed: role identity and Web/access audit.
Web readiness relevance: high.
Upgrade risk: premature role architecture.
Implementation blocked until: role/access identity model is approved.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-022

Module name: Users/advisers/admin roles
Module class: support/access
Business purpose: distinguish Administrator/Savetnik responsibilities and local controls.
Reads from PREDMET: adviser/user metadata where stored.
Reads from other modules: users/auth/session.
May write to: role/user configuration and allowed admin actions.
Must not write to: package/payment/access model as hidden role truth.
Outputs: role-gated local controls.
Allowed side effects: admin-only management according to current behavior.
Forbidden side effects: SAVETNIK stock/admin controls where forbidden by docs.
Truth boundary: local role layer, not firm/license identity.
Pseudocode sections: `OPC-PSEUDO-015`, `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Characterization evidence needed: cross-device role identity audit.
Web readiness relevance: high.
Upgrade risk: access drift.
Implementation blocked until: owner-approved role model.
Evidence: `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`.
Classification: `SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-023

Module name: Entitlement/packages/licensing
Module class: add-on/package / support/access
Business purpose: package/add-on availability without changing PREDMET truth.
Reads from PREDMET: may control visibility/actions; does not own case truth.
Reads from other modules: license payload/parser/repository, entitlement policy.
May write to: local license/settings/access state.
Must not write to: PREDMET business truth.
Outputs: enabled/disabled modules, documents, settings, diagnostics.
Allowed side effects: hide/lock features; fail closed.
Forbidden side effects: data deletion or truth mutation due to package state.
Truth boundary: availability layer only.
Pseudocode sections: `OPC-PSEUDO-014`, `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Characterization evidence needed: commercial/payment/access gate.
Web readiness relevance: high.
Upgrade risk: over-unlock or data corruption.
Implementation blocked until: payment/access model approved.
Evidence: `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`.
Classification: `OWNER DECISION / SOURCE-CONFIRMED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-024

Module name: PODSETNIK
Module class: operational / add-on/package
Business purpose: local in-app reminder UX around PREDMET-related work.
Reads from PREDMET: future/reminder-relevant case facts if implemented.
Reads from other modules: package entitlement and local notification/reminder support if approved.
May write to: reminder state only where implemented/approved.
Must not write to: PREDMET truth or lifecycle truth.
Outputs: reminders/signals.
Allowed side effects: local reminder notification state if separately implemented.
Forbidden side effects: OS/background/sync behavior without architecture approval.
Truth boundary: operational derivative.
Pseudocode sections: `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Characterization evidence needed: current implementation status and notification architecture.
Web readiness relevance: medium.
Upgrade risk: runtime/platform drift.
Implementation blocked until: explicit task and notification architecture decision.
Evidence: `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`; `PROJECT_DOCS/OPC_v1_ZAKLJUCANA_PRAVILA.md`.
Classification: `POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-025

Module name: NALOG CVECARI
Module class: derivative/render / add-on/package
Business purpose: document/PDF export item, not standalone operational module.
Reads from PREDMET: document-relevant case facts.
Reads from other modules: PDF/document generation, entitlement/packages.
May write to: output artifact only.
Must not write to: PREDMET truth or operational workflow truth.
Outputs: document/PDF export.
Allowed side effects: generate approved document output.
Forbidden side effects: independent module truth or operational stock/procurement behavior.
Truth boundary: document derivative.
Pseudocode sections: `OPC-PSEUDO-011`, `OPC-PSEUDO-014`, `OPC-PSEUDO-018`.
Characterization evidence needed: document/add-on boundary and data contract.
Web readiness relevance: low/medium.
Upgrade risk: document output becoming policy source.
Implementation blocked until: document boundary audit.
Evidence: `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`; `PROJECT_DOCS/OPC_v1_ZAKLJUCANA_PRAVILA.md`.
Classification: `DOCUMENTED POLICY / TECHNICAL AUDIT REQUIRED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-026

Module name: Future OPC Web/sync
Module class: future/Web seam
Business purpose: future complementary browser-access runtime and possible sync/mediation support.
Reads from PREDMET: future architecture must preserve PREDMET truth.
Reads from other modules: all module contracts, identity, access, storage, conflict, evaluator, JSON, backup.
May write to: not implemented.
Must not write to: server-master PREDMET assumption or sync behavior without owner-approved architecture.
Outputs: future access/runtime only.
Allowed side effects: none in current repo.
Forbidden side effects: backend/API/sync/storage/payment/role implementation from this plan.
Truth boundary: future seam; no implementation chosen.
Pseudocode sections: `OPC-PSEUDO-019`, `OPC-PSEUDO-021`.
Characterization evidence needed: Web/sync architecture audit.
Web readiness relevance: primary.
Upgrade risk: product ownership and identity drift.
Implementation blocked until: owner-approved architecture and technical audit.
Evidence: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`; `docs/OPC_WEB_READINESS_GUARDRAILS.md`.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.

## MODULE-CONTRACT-ID: OPC-MODULE-CONTRACT-027

Module name: Future LK/OCR seam
Module class: future/Web seam / add-on/package
Business purpose: future ID-card/OCR input seam for populating appropriate PREDMET fields.
Reads from PREDMET: future target fields only after approval.
Reads from other modules: future OCR/chip reader source and entitlement/packages.
May write to: not implemented in v1.
Must not write to: PREDMET fields automatically without explicit owner-approved input/confirmation rules.
Outputs: future populated field candidates.
Allowed side effects: none in current repo.
Forbidden side effects: OCR/chip reading behavior in this task or unconfirmed data writes.
Truth boundary: future input seam only; PREDMET remains truth after confirmed entry.
Pseudocode sections: `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Characterization evidence needed: feasibility, privacy, platform, and confirmation audit.
Web readiness relevance: medium.
Upgrade risk: personal-data and identity corruption.
Implementation blocked until: explicit v2/future owner-approved task.
Evidence: `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`; `PROJECT_DOCS/OPC_v1_ZAKLJUCANA_PRAVILA.md`.
Classification: `DOCUMENTED POLICY / NOT IMPLEMENTED / IMPLEMENTATION BLOCKED`.

## Contract Summary

All listed modules are bounded around PREDMET master truth. Contract gaps are characterization, owner-decision, or technical-audit blockers, not implementation authorization.
