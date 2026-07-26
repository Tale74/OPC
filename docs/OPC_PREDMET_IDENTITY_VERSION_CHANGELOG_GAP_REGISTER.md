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
Classification: `IMPLEMENTATION GAP / OWNER DECISION EXISTS / TECHNICAL AUDIT REQUIRED`.

Owner visibility decision: future `Pregled i potvrda` shows significant lifecycle/import events and changed business segments without raw previous/new PREDMET values or per-keystroke history. Technical checkpoint remains hidden and separate.

## GAP-ID: OPC-PREDMET-LIV-GAP-004

Area: replacement import log retention.
Current evidence: replacement import deletes local `logIzmena` and inserts imported business state under the preserved local id.
Owner decision: individual PREDMET JSON does not transfer `logIzmena`; replacement must preserve the local log and append a local replacement event with local actor/time authority.
Risk if misunderstood: current runtime deletion may be mistaken for approved behavior, or foreign history may be imported as local audit authority.
Blocked behavior changes: implementation of local import/replacement event logging, snapshot privacy/retention correction, tests and migration safety.
Classification: `SOURCE-CONFIRMED CURRENT CONFLICT / OWNER DECISION / IMPLEMENTATION GAP / TECHNICAL AUDIT REQUIRED`.

Technical audit closure reference: `docs/OPC_LOGIZMENA_TECHNICAL_AUDIT.md`.

Additional finding: current `logIzmena` mixes raw business-state checkpoints with future user-facing audit responsibility. The checkpoint is required by current save/unsaved/version comparison behavior, while the log has no current event-list UI. Implementation remains blocked until checkpoint migration, privacy, event metadata and test strategy are proven.

## GAP-ID: OPC-PREDMET-LIV-GAP-005

Area: firm-scoped PREDMET identity.
Current evidence: code-first audit confirms that current import conflict lookup uses `brojPredmeta` only; single-PREDMET JSON carries no FIRMA identity; full-backup import has no PIB/MB preflight; `FirmaPodaci` is mutable without identity history; minute-level local number generation has no unique guard. Owner policy says future-safe identity is firm-scoped and `brojPredmeta` alone is not global identity.
Risk if misunderstood: wrong-firm conflict, restore, or sync collision.
Blocked behavior changes: identity guard, duplicate detection, sync identity, restore identity.
Classification: `OWNER POLICY EXISTS / TECHNICAL AUDIT COMPLETE / TWO OWNER DECISIONS REMAIN / IMPLEMENTATION BLOCKED`.

Technical audit closure reference: `docs/OPC_FIRM_SCOPED_PREDMET_IDENTITY_TECHNICAL_AUDIT.md`.

Remaining decisions: legacy single-PREDMET JSON without FIRMA identity and PIB/MB correction versus transition to a new FIRMA/database family.

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
