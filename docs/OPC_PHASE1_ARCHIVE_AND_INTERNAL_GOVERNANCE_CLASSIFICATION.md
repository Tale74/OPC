# OPC Phase 1 Archive and Internal Governance Classification

**Status:** `CURRENT CONSOLIDATION EXECUTION CLASSIFICATION`
**Purpose:** separate final market-facing product/engineering information from internal development/governance know-how and historical evidence. Closure Correction physically separates only the byte-preserved internal pseudocode set; it does not refresh content or retire historical evidence.

## 1. Final market-facing OPC product/engineering package

The final product package may contain, where justified:

- README and navigation;
- current product/domain authority;
- current architecture and deployment views;
- development/build/test/quality/release guidance;
- appropriate security/data/dependency/IP-status information;
- sparse technical ADRs;
- tests, CI/repository configuration and necessary source/assets/tooling;
- machine-readable release dependency/license inventory when distribution requires it.

It must not require a future developer or acquirer to reconstruct current OPC from Tale/Logos/Codex task chronology.

## 2. Internal Tale/Logos/Codex development/governance know-how

These methods remain available during active OPC and OPC Int development but are not final product documentation:

- HUMAN GATE and continuity-reading method;
- Logos↔Codex role separation and reconciliation method;
- source-of-truth/anti-drift operating method;
- forensic evidence and owner-runtime-versus-root-cause discipline;
- task-writing, handoff and manifest-gate method;
- documentation reconciliation and migration method;
- pseudocode maintenance method;
- pseudocode↔roadmap comparison method;
- reusable jumpstart/onboarding governance patterns.

Pseudocode itself is strictly internal Tale/Logos development-control material. It remains available locally under `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/`, is not product documentation or a production specification, must not ship with the finished application and must not be presented as acquirer/developer handover documentation. The original `docs/` paths retain boundary pointers and Git history; content was moved byte-for-byte and not refreshed. See `docs/OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md`.

## 3. Historical evidence/archive

Historical evidence may remain temporarily or permanently where it preserves unique migration, compatibility, lock, incident, acceptance or audit knowledge. It must be clearly labelled as historical/evidence and must not compete with current product/domain/architecture authority.

Typical classes:

- task implementation and audit reports;
- pre-zero authority/recovery chronology;
- restore-point notes and incident reports;
- old roadmap variants and superseded decisions;
- major SCENARIO lock/runtime evidence;
- migration/recovery/compatibility evidence;
- owner decision history whose current truth has been migrated elsewhere.

Routine chronology is not retained as active product specification merely because it exists. No historical item is retired until the Phase 1 manifest records disposition and the safety conditions in the Phase 1 report are satisfied.

## 4. Current supporting evidence

Current supporting maps and inventories remain useful where they provide detail not duplicated in the compact information homes:

- module contracts and relationship maps;
- business rule inventories and full policy snapshots;
- PREDMET workflow/dependency/completion maps;
- characterization evidence and gap registers;
- platform/runtime closure reports;
- lock reports and scoped recovery evidence.

Their status is current supporting evidence, not automatic permission to implement an open recommendation. The Phase 1 manifest points each artifact to its target information home and records whether it is retained, merged, archived or requires owner reconciliation.

## 5. Local + GitHub model

OPC currently remains maintained through both the local project environment and public GitHub. Local material is not made irrelevant merely because it is outside Git, and Git is not converted into an exclusive authority model by Phase 1.

| Location | Information class | Phase 1 treatment |
|---|---|---|
| `SOURCE/docs` and `README.md` | Current product/engineering documentation and Git-visible evidence | Current homes and public review surface |
| `C:\Projekti\OPC\OPC v.1\SCENARIO_MAP` | Owner map, control report, implementation/history inputs | Supporting/current owner evidence; reconcile before promoting or retiring |
| `C:\Projekti\OPC\OPC v.1\RUNTIME` | Named runtime JSONL and owner evidence | Runtime evidence, not root-cause authority |
| `C:\Projekti\OPC\OPC v.1\RESTORE_POINTS` | Restore-point/history notes | Historical evidence; retain until migration/retention decision |
| `C:\Projekti\OPC\OPC v.1\BACKUPS` | Private backup archives | Private runtime/backup material; never promote to product docs |
| `C:\Projekti\OPC\OPC v.1\SMOKE_LOGS` | Local smoke/log evidence | Supporting runtime evidence; not current product specification |

No uncontrolled mirror or automatic network synchronization mechanism is introduced. The manifest records relationships and required parity manually until the owner defines the future transition/distribution model.

## 6. Safe disposition rule

A document may move from active documentation only when all are proven:

1. it is not current authority;
2. it contains no unique current knowledge;
3. useful current knowledge is migrated;
4. no unresolved owner decision depends on it;
5. legal/audit/historical retention is not required;
6. the manifest records the disposition;
7. a replacement information home exists and is verified.

If any condition is incomplete, keep it temporarily.

## 7. Bounded consolidation execution rule

The active reading surface is README navigation plus five substantive homes:
Product/Domain, Architecture, Development, Quality/Release and Engineering
Profile. Historical and supporting rows remain in place until a wave proves
replacement coverage, link safety, hash preservation and no-loss. This
classification does not authorize blind bulk movement or deletion. RR-005
correction is closed; older inconclusive migration/recovery rehearsal records
remain evidence only and do not reopen that fact.
