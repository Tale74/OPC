# OPC PREDMET dependent-data lifecycle matrix

Status: `AUTHORITATIVE TECHNICAL AUDIT MAP — IMPLEMENTATION NOT AUTHORIZED`

Audit reference:
`docs/OPC_DATABASE_REFERENTIAL_INTEGRITY_AND_PREDMET_DEPENDENCY_AUDIT.md`

Post-zero controlling design:
`docs/OPC_POST_ZERO_PREDMET_LIFECYCLE_REFERENTIAL_DESIGN.md`.

Pre-zero owner-policy statements in this matrix are historical/prospective
evidence only. The post-zero design identifies the business/privacy/transfer
choices that must be reconfirmed before affected implementation.

## 1. Dependency classes

| Dependency | Authority class | Physical FK declared | Current hard delete | Required future behavior |
| --- | --- | ---: | --- | --- |
| PREDMET row | sole business truth | parent | deleted | authoritative lifecycle command |
| Kontakt lica | PREDMET child truth | yes | explicitly deleted | delete/redact with PREDMET policy |
| IRiU | PREDMET child truth | yes | explicitly deleted | delete/reconcile atomically |
| IRiU lifecycle decisions | PREDMET child control state | yes | explicitly deleted | delete with PREDMET |
| log/checkpoints | local audit/technical support | yes | explicitly deleted | privacy-safe separation; delete with hard-deleted PREDMET |
| PARTE preparation | technical derivative | yes | currently orphaned | media-aware delete/invalidate |
| ceremony reminder config | operational derivative | yes | currently orphaned | cancel OS state then explicit delete |
| stock consequence | operational current exception | yes to PREDMET/IRiU | explicitly deleted through service | reconcile/delete |
| stock applied effect | operational reconciliation history | no | status becomes restored/cleared and row remains | retain only explicit non-PII history classification |
| adviser/creator/modifier IDs | local authorship metadata | no | parent PREDMET deleted | user guard/rebind policy |
| PARTE template snapshot/reference | technical provenance | no | preparation currently remains | snapshot allows safe template independence |
| catalog stable IDs | portable knowledge/stock identity | no numeric FK | PREDMET rows removed | no guessed relinking |
| auth audit | installation security history | no | retained | explicit installation-local privacy contract |

## 2. Lifecycle outcome

| Action | PREDMET | Child truth | Audit/checkpoint | PARTE | PODSETNIK | Stock |
| --- | --- | --- | --- | --- | --- | --- |
| Save | update | update as user actions require | hidden checkpoint | source may become stale | reschedule on ceremony change | reconcile selection changes |
| Close/reopen | retain/status | retain | lifecycle event/checkpoint | blocking rules apply | lifecycle policy applies | retain |
| Manual finish | retain/status | retain/historical | lifecycle event | historical derivative rules | informed-reminder policy later | retain |
| Anonymize | retain/redact | redact/retain per policy | event + privacy-safe hashes only | purge PII draft/media | cancel/delete active reminder state | retain non-PII business/operational state |
| Hard delete | delete | delete | delete | delete app-owned preparation/media | cancel OS then delete config | compensate; delete consequences; classified effect history only |
| Individual replacement | replace local truth | replace imported child truth | retain local audit + replacement event | invalidate/delete stale preparation | preserve logical preference, cancel/reschedule from new truth | compensate old then apply imported consequences |
| Full restore | replace complete portable family | exact clear/import | restore defined local DB family | clear non-portable preparation | cancel current device; import preference only; reschedule | exact supported stock restore |

## 3. Referential enforcement gate

`PRAGMA foreign_keys = ON` may be enabled only after:

1. exact orphan inventory;
2. lifecycle correction;
3. full-restore exact-table correction;
4. recovery migration;
5. zero unexpected `PRAGMA foreign_key_check` results;
6. historical schema and Windows/Android proof.

Declared cascade never replaces external filesystem/OS or stock-compensation
logic.

## 4. PODSETNIK revisit gate

PODSETNIK integrity correction precedes business expansion.

PODSETNIK informed-reminder design resumes only after the complete signal
inventory is established and the owner confirms which signals have business
meaning. Completion colors alone are not the whole signal model.

## Recovery lifecycle rule — 2026-08-13

Current state is authoritative and deletion is final. A dependent row whose
business parent no longer exists is technical orphan state and is removed;
existing PREDMET-owned snapshots and current business relations are preserved.
Later KATALOG edits never rewrite a formed PREDMET/IRiU snapshot.
