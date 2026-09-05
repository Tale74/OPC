# OPC Documentation Re-baseline Authority Manifest

**State:** `CURRENT ZERO-STATE PUBLISHED; NALOG CVEĆARI CLOSED; FINAL GUI ARTIFACT ACCEPTED; BROADER PHASE 2 OWNER REVIEW PENDING`

## Latest authorized Cvećari presentation state

The latest OWNER authorization supersedes the earlier botanical-ornament
proposal. `NALOG CVEĆARI` section labels retain the sage/ivory-green pastel
background, border, title, typography, dimensions and alignment, but the
botanical pattern is removed completely and no replacement decoration is
present. `P2-VIS-005` image framing and `P2-VIS-006` multi-item structure
are preserved. Focused tests, shared-PDF regressions, analyzer, full test
suite, Windows build and renderer evidence pass. The final accepted GUI
artifact is recorded in `REVIEW_EVIDENCE/NALOG_CVECARI_FINAL_DOCUMENTATION_AND_EVIDENCE_CLOSURE.md`.
This closes `NALOG CVEĆARI` only; broader Phase 2 OWNER review remains pending.

**Task:** `OPC DOCUMENTATION RE-BASELINE — SCENARIO LOCK → RECOVERED CURRENT BUILD ZERO-STATE CUTOVER`

**Cutover rule:** `SCENARIO LOCK` is the last previously trusted documentation baseline. Recovered current source/build is an as-built technical baseline only. Post-cut-line material is not current authority merely because it is newer, detailed, linked, or present in the repository.

## Authority hierarchy

1. Direct, later OWNER decisions and explicit task authorization.
2. The current documents in this `docs/current/` surface, insofar as each document is limited to its stated subject and backed by the evidence register.
3. Recovered implementation and tests for technical as-built behavior only.
4. Scoped runtime and build evidence for observed artifact/platform behavior only.
5. `SCENARIO LOCK` and its predecessor material for protected historical contract/provenance.
6. All other reports, task records, generated evidence and internal pseudocode as subordinate evidence or historical material.

Business authority is not inferred from source, tests, runtime, reports, task names, or internal pseudocode. An unresolved business conflict remains `OWNER DECISION REQUIRED`.

## Current reading surface

- [Product and domain boundary](OPC_PRODUCT_DOMAIN.md)
- [Recovered as-built architecture](OPC_AS_BUILT_ARCHITECTURE.md)
- [Current implementation state](OPC_CURRENT_IMPLEMENTATION_STATE.md)
- [PODSETNIK contract and status separation](OPC_PODSETNIK_CONTRACT_AND_STATUS.md)
- [Quality, release and evidence boundary](OPC_QUALITY_RELEASE_AND_EVIDENCE.md)
- [Development and engineering boundary](OPC_DEVELOPMENT_AND_ENGINEERING_BOUNDARY.md)
- [Documentation disposition manifest](OPC_DOCUMENTATION_DISPOSITION.md)
- [Logical system map](OPC_LOGICAL_SYSTEM_MAP.md)
- [Owner authority traceability](OPC_OWNER_AUTHORITY_TRACEABILITY.md)
- [Source traceability](OPC_SOURCE_TRACEABILITY.md)
- [Phase 2 defect ledger](OPC_PHASE2_DEFECT_LEDGER.md)
- [Phase 2 complete coverage audit](OPC_PHASE2_COVERAGE_AUDIT.md)
- [Phase 2 historical donor recovery audit](OPC_PHASE2_HISTORICAL_DONOR_RECOVERY_AUDIT.md)

The legacy five-home documents at `docs/OPC_*.md` and the legacy current-state
map remain compatibility surfaces only after their re-baseline banners; their
historical bodies are not competing current authority. Direct PODSETNIK
task/pseudocode surfaces are retired under
`docs/archive/documentation-rebaseline/podsetnik-lineage/`. The current
manifest is the only navigation root for this cutover.

## Protected boundaries

- Primary mixed `SOURCE` is forensic-only for this task.
- Canonical/private runtime databases are not documentation inputs to mutate.
- `REVIEW` is outside `SOURCE` and is non-authoritative review evidence.
- The Phase 2 authorization permits only the eight locked correction capabilities, their protecting tests, sequential QA/build and bounded Windows runtime evidence; no source/test/DB/build change outside that denominator is authorized.
- No commit, push or publication is authorized by the Phase 2 implementation task.
- `DOCUMENTATION ZERO-STATE PUBLISHED` remains a prior publication fact; current Phase 2 documentation/evidence changes remain uncommitted.

## Evidence identity

- Recovery worktree: `C:\Projekti\OPC\OPC v.1\RECOVERY\OPC-PODSETNIK-URNA-PEPEO-SECONDARY-CYCLE`
- Recovery HEAD: `74809d08136e5350d2b848a341fd0d1e6f598d09` (detached; documentation zero-state publication commit)
- Publication remote: `origin/recovery/OPC-TASK1-CLEAN-FA6FEDD`
- Windows executable SHA-256: `99ED7DB0A07DF74D6249B088DD0B3D63777A6DDE97CF2C14ABF83A107CBEB5E6`
- Historical Windows `data\app.so` SHA-256: `50D18CF0C8584CE88F321D344C207F0C40E947985E93CC760C2DC33A0F7E6A87`
- Current/final accepted Windows `data\app.so` SHA-256: `EB312C7574AEB2C07D66DBC24B702000BBB50C456B2EBE1F7E2EBD341AC99CC5`
- Superseded bounded-correction candidate Windows `data\app.so` SHA-256: `6B8ABF473309E9A14E254DAB09FFECE17FA9BBB584AD259769FF65C5803864EB` (historical evidence only)
- Android APK SHA-256: `3FC05CB7A2001EE9E6C6612A8FC0A100BA38B77DA04FE62BE64F76250C0BCE3B`
- Canonical DB path: `C:\Users\Steva\Documents\opc_v4_release.sqlite`
- Canonical DB latest read-only observation after normal runtime shutdown: SHA-256 `CE0FCEF14C33A088961D53E7C9096CC9ABCA1D61EDC0552774FCB459F5AFEA5E`, length `82829312`, schema/user_version `31`, `integrity_check = ok`.

The changing DB hash is recorded as an observed runtime/private-data evidence finding; it is not interpreted here as a migration defect and no repair or DB operation is authorized.

## Current-state synchronization addendum — 2026-09-04

See `REVIEW_EVIDENCE/P2_TOOLING_COMPUTER_USE_DESKTOP_BINDING.md` for the
separate tooling record. The observed P2-RUN-001 invisible-window incident is
resolved as Codex sandbox-desktop isolation. Fresh Computer Use binding still
returns `apps=[]`; this is a tooling-environment failure, not an OPC
source/build defect. The current owner-supplied Cvećari GUI evidence and
achieved implementation are recorded, while final OWNER visual acceptance
is closed for the accepted `NALOG CVEĆARI` scope; `P2-VIS-003` remains a
separate viewer-state classification and broader Phase 2 OWNER review remains
pending.
Earlier wording in this file that treated
the original invisible-window incident as an unresolved OPC/runtime blocker is
superseded by this addendum.

## Current bounded visual correction — 2026-09-04

`P2-VIS-003` remains `VIEWER-STATE CAUSE INDICATED — NO OPC ARTIFACT
CORRECTION AUTHORIZED`. `P2-VIS-004/005` are implemented with renderer
evidence PASS, and `P2-VIS-006` is corrected with renderer evidence PASS.
The evidence and current build hashes are recorded in
`REVIEW_EVIDENCE/P2_VIS_004_006_CORRECTION_EVIDENCE.md`. Final OWNER GUI
visual acceptance remains required; this does not change business authority,
release or publication status.

The preceding botanical-pattern refinement is historical and superseded by
the latest `P2-VIS-007` correction. Current evidence is recorded in
`REVIEW_EVIDENCE/P2_VIS_007_DECORATION_REMOVAL_EVIDENCE.md`: the section-label
right side is empty, the inset-protected image frame is preserved and ribbon
output contains values only. The later two-page OWNER-accepted GUI export and
its final identity are recorded in the closure evidence. This closure does not
accept the broader Phase 2.

## Final NALOG CVEĆARI documentation closure — 2026-09-05

`NALOG CVEĆARI` is `CLOSED — BROADER PHASE 2 OWNER REVIEW STILL PENDING`.
The final accepted artifact is the two-page GUI export
`C:\Users\Steva\Downloads\KORICE\PREDMET_PROBNI_040926_2318_NALOG_CVECARI_v1.pdf`
with SHA-256
`6257C3BB1E082EFA7CE043DED059753D5DD0725F8E8D0EF61D00250E3795551A`.
The later page count reflects additional CVEĆE items in the same PREDMET;
the earlier one-page export remains historical evidence.
