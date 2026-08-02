# Phase 10 module-boundary correction and source audit

## Owner clarification recorded

STANJE ROBE is an independent module like PARTE and SCENARIO. SCENARIO is
only a business-rule engine. `PREDMET` remains the sole business authority;
other modules are derivatives or own their narrowly scoped technical/operational
state. A module must not directly mutate another module's state.

## Audit result

The source audit found the existing stock bridge in `IriuRepository` and
PREDMET-delete cleanup in `PredmetiRepository`. Both are pre-existing
PREDMET/IRIU integration paths and are controlled by the STANJE ROBE module's
own entitlement/toggle. The SCENARIO editor, repository and pure planner do not
import or call STANJE ROBE, PARTE or PODSETNIK.

The previous Phase 10 residual wording that named “STANJE ROBE compensation”
as a SCENARIO application prerequisite was too broad. It is corrected here:
future SCENARIO application must use the PREDMET transaction and preserve the
existing PREDMET → IRIU path; it must not call STANJE ROBE directly.

## Updated documentation

- `docs/OPC_MODULE_BOUNDARIES_AND_AUTHORITY_AUDIT.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_PROJECT_NAVIGATION_AND_DEPENDENCY_MAP.md`
- `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`

No application source or runtime behavior was changed.

## Safety and validation

- Base SHA: `f03deaa2af661913f98af535fe8cabdebd39b21f`
- Task branch: `task/OPC-PHASE10-DOC-MODULE-BOUNDARIES`
- Reference backup: `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_PHASE10_SCENARIO_RECONCILIATION_20260802_V2.zip`
- Reference backup SHA-256: `09096415A2BC649170381C338BC0CF5ED37F4B2A658F4CC9A4832D4F0F79F2E2`
- No build or runtime was run; no application tree changed.
