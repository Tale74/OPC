# OPC Web Readiness Guardrails

Status: docs-only guardrails for future OPC Web/access readiness.

Base commit: `9bea04a6411c92a045a39f8b8a522dafa9dbcf98`

This document does not design or select Web architecture. It does not choose server, database, sync, backend, API, browser storage, external storage, licensing, payment, or role implementation.

## 1. Purpose

Preserve future OPC Web possibility while keeping current OPC local-first, PREDMET-centered, and implementation-blocked until owner-approved architecture and technical audits exist.

## 2. Current Decision State: No Final Web Implementation Chosen

Current public docs define `OPC Web` as the canonical future browser-access runtime term. They do not authorize a Web runner, backend, API, sync engine, cloud database, server-master PREDMET store, storage adapter, payment, licensing server, or role implementation.

Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.

## 3. Local-First Current Rule

Current OPC is local-first. The firm/user owns its own OPC database. Single-PREDMET JSON and full backup JSON remain current transfer/backup forms. No mandatory network sync is assumed.

Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## 4. Future Web/Access Rule

Future OPC Web may provide browser access and may support access, licensing, package, backup, transfer, signaling, or mediation functions, but must not be assumed to own master PREDMET truth unless a later explicit owner-approved architecture changes that rule.

Classification: `OWNER DECISION / IMPLEMENTATION BLOCKED`.

## 5. PREDMET Identity Guardrails

`brojPredmeta` is not global identity. Future-safe PREDMET identity/conflict scope is firm-scoped: `PIB + Maticni broj + brojPredmeta`. Filename person names and `_vN` text are recognition aids only unless later source/test evidence and owner decision prove otherwise.

Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## 6. Local DB Id Boundary

Local database ids are technical ids. They must not be used as cross-device, cross-firm, Web, sync, conflict, KATALOG, inventory, user, or license identity without explicit audit and owner approval.

Classification: `DOCUMENTED POLICY / TECHNICAL AUDIT REQUIRED`.

## 7. Firm-Scoped Identity Guardrail

Future conflict/import/restore/sync logic must distinguish editable firm display data from stable firm identity history. `FirmaPodaci` currently feeds documents/settings and is not proven sufficient as immutable identity history.

Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## 8. PREDMET Version/Change-Log Guardrail

`verzija` is a PREDMET business-version signal. `exportDatum` is export metadata, not freshness authority. Future version/change-log UI belongs conceptually in `Pregled i potvrda`, but implementation requires lifecycle/version/log audit.

Classification: `OWNER DECISION / IMPLEMENTATION REQUIRED / TECHNICAL AUDIT REQUIRED`.

## 9. JSON/Conflict Guardrail

Single-PREDMET JSON import currently preserves explicit user choice semantics: keep local, replace, or cancel for same-case conflicts. Future Web/sync conflict support must not silently overwrite local PREDMET data and must not use filename or export date as authority.

Classification: `OWNER DECISION / SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## 10. Evaluator/Advisor Determinism Guardrail

For the same PREDMET facts and business scenario, evaluator outputs must remain deterministic across runtime forms. Advisor/guidance must read PREDMET/evaluator/module consequences and must not invent hidden policy or mutate truth.

Classification: `SOURCE-CONFIRMED / OWNER DECISION REQUIRED`.

## 11. Module Contract Guardrail

Each module must have a truth boundary before Web/sync work can safely include it. Unknown read/write contracts are Web blockers, not implementation invitations.

Classification: `CHARACTERIZATION REQUIRED / IMPLEMENTATION BLOCKED`.

## 12. Derivative-Output Guardrail

PDFs, PARTA, CITULJE, JSON filenames, statistics, reminders, lists, and Web displays are derivative outputs. They may expose or transfer PREDMET-derived state, but must not define master truth.

Classification: `DOCUMENTED POLICY`.

## 13. STANJE ROBE/Inventory Guardrail

STANJE ROBE is operational inventory over KATALOG and selected PREDMET/IRiU consequences. It must not become PREDMET truth or KATALOG truth. KATALOG binding uses `stableArticleId`, not local DB id or guessed relinking.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## 14. Finance/Payment Guardrail

Finance/payment uses PREDMET, IRiU financial truth, JKP, refund, advance, discount, and payment fields. Payment/subscription implementation is blocked. Finance outputs must not be silently redefined by Web/payment access work.

Classification: `SOURCE-CONFIRMED / TEST GAP / IMPLEMENTATION BLOCKED`.

## 15. Entitlement/Package/Role Guardrail

Packages and add-ons can control availability, not PREDMET truth. Roles/auth supply local actor context and admin/adviser controls, but stable cross-device role identity is not established. Package, role, build variant, platform overlay, and payment/access model remain separate concerns.

Classification: `OWNER DECISION / SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## 16. FirmaPodaci/Firma Ownership Guardrail

Firm data may be displayed in documents and used by settings, but future Web/sync identity must not rely on mutable display fields alone. Wrong-firm import/restore/sync risk remains an audit blocker.

Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## 17. Sync-Conflict Risk List

- same `brojPredmeta` in different firms;
- missing or malformed PIB/Maticni broj;
- local DB ids reused across devices;
- imported lower/higher/same/missing `verzija`;
- unresolved STANJE ROBE consequences;
- KATALOG stable article ids unknown to a receiving firm;
- finance totals changing from IRiU or refund rule differences;
- user/adviser ids not stable across devices;
- package/access state hiding modules but not deleting data;
- backup restore into wrong firm database.

Classification: `TECHNICAL AUDIT REQUIRED`.

## 18. What Must Not Be Implemented Prematurely

Do not implement Web runner, backend, API, sync, cloud database, browser storage choice, local agent, payment, subscription, licensing server, role architecture, migration, data adapter, automatic conflict resolver, or server-master PREDMET model from this document.

Classification: `IMPLEMENTATION BLOCKED`.

## 19. Technical Unknowns

- Web data location and offline behavior.
- Conflict model and replica ownership.
- Stable firm identity history.
- Stable user/adviser identity.
- Version/change-log completeness.
- JSON and backup semantics under Web.
- KATALOG/STANJE ROBE transfer/sync semantics.
- Package/license/payment access enforcement.
- Security, privacy, and recovery model.

Classification: `TECHNICAL AUDIT REQUIRED`.

## 20. Owner Decisions Required

- Whether future Web has server-master, local replica, mediated transfer, or another architecture.
- Whether version conflicts only warn or may hard-block.
- How firm identity is established and recovered.
- How roles map across devices/firms.
- How package/payment/access is commercially enforced.
- Which advisor warnings are policy-authoritative.

Classification: `OWNER DECISION REQUIRED`.

## 21. Final Web-Readiness Summary

OPC Web remains possible only if PREDMET truth, firm ownership, identity scope, module contracts, deterministic evaluator behavior, explicit transfer/restore choices, and derivative-output boundaries are preserved. This document intentionally stops before architecture selection.

Classification: `PASS WITH OWNER REVIEW QUEUE`.
