# OPC PREDMET Web Sync Identity Risk Register

Status: docs-only Web/sync readiness risk register.

Base commit: `7c24d6399077499f78f963a737cd95560493e49d`

This register records risks for future Web/sync readiness without choosing architecture or implementation. It does not authorize Web/backend/API/sync/storage/payment/licensing/entitlement/role changes.

## RISK-ID: OPC-PREDMET-WEB-ID-001

Risk: local database `id` is mistaken for cross-device PREDMET identity.
Current evidence: repository replacement preserves local `id`; new imports allocate a new local id; tests confirm both slices.
Boundary: local `id` remains technical and local.
Classification: `TEST-CONFIRMED PARTIAL / DOCUMENTED POLICY`.

## RISK-ID: OPC-PREDMET-WEB-ID-002

Risk: `brojPredmeta` alone is treated as global identity.
Current evidence: local import conflict searches by `brojPredmeta`; owner policy says future-safe identity is firm-scoped.
Boundary: `brojPredmeta` is not global identity.
Classification: `SOURCE-CONFIRMED / OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## RISK-ID: OPC-PREDMET-WEB-ID-003

Risk: filename becomes identity or freshness authority.
Current evidence: filename is generated from display/name, `brojPredmeta`, and `v${verzija}`; policy says filename is human-readable only.
Boundary: filename is metadata/display convenience only.
Classification: `SOURCE-CONFIRMED / OWNER DECISION`.

## RISK-ID: OPC-PREDMET-WEB-ID-004

Risk: `exportDatum` becomes conflict/freshness authority.
Current evidence: `exportDatum` is generated during export; public policy rejects export date as authoritative freshness.
Boundary: `exportDatum` is export metadata.
Classification: `SOURCE-CONFIRMED / OWNER DECISION`.

## RISK-ID: OPC-PREDMET-WEB-ID-005

Risk: business `verzija` is confused with `exportVerzija`.
Current evidence: `verzija` changes through lifecycle/version logic; `exportVerzija` increments on single-PREDMET JSON export.
Boundary: business version and export metadata remain separate.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL`.

## RISK-ID: OPC-PREDMET-WEB-ID-006

Risk: same-PREDMET replacement is treated as silent overwrite.
Current evidence: current UI offers keep/replace/cancel; tests confirm replacement keeps local id and imports business state.
Boundary: explicit user choice remains protected unless owner changes policy.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED PARTIAL / OWNER DECISION`.

## RISK-ID: OPC-PREDMET-WEB-ID-007

Risk: current change-log data is overclaimed as a complete sync audit trail.
Current evidence: log rows exist for snapshots, version changes, and working cycles; full review change-log overview is not implemented; replacement deletes local logs for replaced PREDMET.
Boundary: current logs are source-confirmed local behavior, not a complete Web/sync audit model.
Classification: `SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## RISK-ID: OPC-PREDMET-WEB-ID-008

Risk: future firm identity uses editable current FirmaPodaci without history/authority audit.
Current evidence: owner policy requires firm-scoped identity; current task did not audit firm identity history or authority.
Boundary: firm-scoped identity is policy, not implemented proof.
Classification: `DOCUMENTED POLICY / TECHNICAL AUDIT REQUIRED / IMPLEMENTATION BLOCKED`.

## RISK-ID: OPC-PREDMET-WEB-ID-009

Risk: Web architecture is inferred from local characterization.
Current evidence: this task is docs-only characterization.
Boundary: no Web/backend/API/sync/storage/payment/licensing/entitlement/role architecture is selected.
Classification: `IMPLEMENTATION BLOCKED`.
