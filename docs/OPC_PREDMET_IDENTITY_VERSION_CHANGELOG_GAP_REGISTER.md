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
Current evidence: close path conditionally increments based on a raw PREDMET-row snapshot comparison; ordinary save/reopen do not increment. SCENARIO is explicitly excluded, and IRiU/contact rows are outside the snapshot.
Risk if misunderstood: changed PREDMET aggregate truth can retain the same `verzija`, while UI/PDF/JSON present it as business revision.
Blocked behavior changes: canonical aggregate fingerprint, version comparison, conflict warnings, review interpretation and lifecycle/version coupling.
Owner decision: business `verzija` is confirmed on close; ordinary save is a working checkpoint, reopen alone does not increment, and close increments only after canonical aggregate change.
Classification: `SOURCE-CONFIRMED / COVERAGE DEFECT / TEST GAP / OWNER DECISION EXISTS / TECHNICAL DESIGN REQUIRED`.

Technical audit closure reference: `docs/OPC_PREDMET_BUSINESS_VERSION_MATRIX_AUDIT.md`.

## GAP-ID: OPC-PREDMET-LIV-GAP-003

Area: `Pregled i potvrda` change-log overview.
Current evidence: current review UI shows status, version, and saved/unsaved state; full change-log overview is not present.
Risk if misunderstood: current UI could be overclaimed as complete audit trail.
Blocked behavior changes: review change-log display, conflict authority, sync/audit interpretation.
Classification: `IMPLEMENTATION GAP / OWNER DECISION EXISTS / TECHNICAL DESIGN COMPLETE`.

Owner visibility decision: future `Pregled i potvrda` shows significant lifecycle/import events and changed business segments without raw previous/new PREDMET values or per-keystroke history. Technical checkpoint remains hidden and separate.

Technical closure reference:
`docs/OPC_PREDMET_LIFECYCLE_LOG_RETENTION_AND_EVENT_TAXONOMY_AUDIT.md`.

Source audit confirms the existing `Pregled i potvrda` segment is suitable.
Remaining work is authorized implementation, migration/test proof and runtime
parity, not a new owner decision.

## GAP-ID: OPC-PREDMET-LIV-GAP-004

Area: replacement import log retention.
Current evidence: replacement import preserves destination-local `logIzmena` and inserts imported business state under the preserved local id; one local `IMPORT_REPLACE` event is appended transactionally.
Owner decision: individual PREDMET JSON does not transfer `logIzmena`; replacement must preserve the local log and append a local replacement event with local actor/time authority.
Risk if misunderstood: foreign history may be imported as local audit authority, or retained raw checkpoint rows may be mistaken for a complete user-facing change log.
Blocked behavior changes: new-import event coverage, snapshot privacy/retention correction, checkpoint migration and broader audit UI remain separately scoped.
Classification: `SOURCE-CONFIRMED / OWNER DECISION / REPLACEMENT IMPLEMENTATION CLOSED / BROADER AUDIT MODEL OPEN`.

Technical audit closure reference: `docs/OPC_LOGIZMENA_TECHNICAL_AUDIT.md`.

Additional finding: current `logIzmena` mixes raw business-state checkpoints with future user-facing audit responsibility. The checkpoint is required by current save/unsaved/version comparison behavior, while the log has no current event-list UI. Implementation remains blocked until checkpoint migration, privacy, event metadata and test strategy are proven.

Lifecycle/retention closure reference:
`docs/OPC_PREDMET_LIFECYCLE_LOG_RETENTION_AND_EVENT_TAXONOMY_AUDIT.md`.

The closure defines separate stores, destination-local replacement retention,
minimum events, anonymization/delete behavior and safe legacy coverage handling.
No new owner business decision remains.

## GAP-ID: OPC-PREDMET-LIV-GAP-005

Area: firm-scoped PREDMET identity.
Current evidence: corrected firm audit and dedicated local-user audit confirm the existing `PREDMET -> savetnikId/creator -> local user -> local database -> singleton FIRMA` ownership boundary. The bounded local-identity/recovery correction now binds individual new import and replacement to an active destination-local actor, preserves destination ownership/history, covers all four deletion-reference classes, applies four-state full-backup identity preflight before destructive confirmation/write, allocates collision suffixes transactionally without renumbering legacy duplicates, and provides a selective Case-2 fallback for only new/unambiguous PREDMET families. Focused acceptance is 44/44 PASS plus 13/13 Case-2 proof; Case 3 fresh recovery is supported.
Risk if misunderstood: a source-local user ID may be attributed to the wrong destination user, restore may replace another FIRMA database, or duplicate numbers may be created.
Blocked behavior changes: identity guard, duplicate detection, sync identity, restore identity.
Classification: `OWNER POLICY EXISTS / TECHNICAL DESIGN COMPLETE / IMPLEMENTED — FULL ACCEPTANCE PASS`.

Technical audit closure reference: `docs/OPC_FIRM_SCOPED_PREDMET_IDENTITY_TECHNICAL_AUDIT.md`.

Local-user transfer closure reference: `docs/OPC_LOCAL_USER_IDENTITY_AND_PREDMET_TRANSFER_REBIND_AUDIT.md`.

Correction: a new single-PREDMET FIRMA identity block and same-firm owner attestation are not required. The bounded local-user rebinding, four-state full-backup preflight, collision handling and selective Case-2 fallback are implemented. Broader Web/sync identity, migration/recovery and runtime parity remain separate successors.

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
