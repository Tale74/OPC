# OPC PREDMET Identity Version Change-Log Gap Register

Status: docs-only gap register.

Base commit: `7c24d6399077499f78f963a737cd95560493e49d`

This register records characterization gaps. Gaps are blockers/evidence categories, not recommended tasks, sequence, roadmap, or priority order.

## GAP-ID: OPC-PREDMET-LIV-GAP-001

Area: full lifecycle tests.
Current evidence: create/save/close/reopen/finish/anonymize/delete are source-confirmed; direct full lifecycle regression coverage was not found.
Risk if misunderstood: lifecycle status, version, or log semantics could change without protection.
Blocked behavior changes: any lifecycle behavior change.
Classification: `TEST GAP / CHARACTERIZATION REQUIRED`.

## GAP-ID: OPC-PREDMET-LIV-GAP-002

Area: business `verzija` increment matrix.
Current evidence: close path conditionally increments based on confirmed-close snapshot comparison; save/reopen behavior is source-confirmed but not fully test-confirmed.
Risk if misunderstood: `verzija` could be treated as export version or filename freshness.
Blocked behavior changes: version comparison, conflict warnings, review version interpretation.
Classification: `SOURCE-CONFIRMED / TEST GAP / TECHNICAL AUDIT REQUIRED`.

## GAP-ID: OPC-PREDMET-LIV-GAP-003

Area: `Pregled i potvrda` change-log overview.
Current evidence: current review UI shows status, version, and saved/unsaved state; full change-log overview is not present.
Risk if misunderstood: current UI could be overclaimed as complete audit trail.
Blocked behavior changes: review change-log display, conflict authority, sync/audit interpretation.
Classification: `IMPLEMENTATION GAP / OWNER DECISION EXISTS / TECHNICAL AUDIT REQUIRED`.

## GAP-ID: OPC-PREDMET-LIV-GAP-004

Area: replacement import log retention.
Current evidence: replacement import deletes local `logIzmena` and inserts imported business state under the preserved local id.
Risk if misunderstood: local pre-replacement audit history may be assumed retained when source deletes it.
Blocked behavior changes: replacement retention, audit history, Web/sync conflict history.
Classification: `SOURCE-CONFIRMED / OWNER REVIEW QUEUE`.

## GAP-ID: OPC-PREDMET-LIV-GAP-005

Area: firm-scoped PREDMET identity.
Current evidence: current import conflict lookup uses `brojPredmeta`; owner policy says future-safe identity is firm-scoped and `brojPredmeta` alone is not global identity.
Risk if misunderstood: wrong-firm conflict, restore, or sync collision.
Blocked behavior changes: identity guard, duplicate detection, sync identity, restore identity.
Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED / IMPLEMENTATION BLOCKED`.

## GAP-ID: OPC-PREDMET-LIV-GAP-006

Area: filename, `exportDatum`, and export metadata authority.
Current evidence: filename includes name, `brojPredmeta`, and business `verzija`; JSON root includes `exportDatum`; export increments `exportVerzija`.
Risk if misunderstood: filename or export date could be used as canonical identity/freshness authority.
Blocked behavior changes: JSON conflict policy, overwrite guard, import warning authority.
Classification: `OWNER DECISION / SOURCE-CONFIRMED / CHARACTERIZATION REQUIRED`.

## GAP-ID: OPC-PREDMET-LIV-GAP-007

Area: Android/Windows parity for lifecycle and JSON conflict.
Current evidence: shared source exists; current runtime parity was not executed in this characterization.
Risk if misunderstood: source inspection could be treated as runtime parity proof.
Blocked behavior changes: platform-sensitive lifecycle/import/export behavior.
Classification: `RUNTIME GAP / TECHNICAL AUDIT REQUIRED`.

## GAP-ID: OPC-PREDMET-LIV-GAP-008

Area: Web/sync PREDMET identity and conflict readiness.
Current evidence: Web guardrails are policy-only; no Web/sync implementation is selected.
Risk if misunderstood: local id or current local conflict key could be promoted into cross-device identity.
Blocked behavior changes: Web/backend/API/sync/storage/payment/licensing/entitlement/role identity behavior.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.
