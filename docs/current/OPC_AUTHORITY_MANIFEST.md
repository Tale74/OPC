# OPC Documentation Re-baseline Authority Manifest

**State:** `CURRENT ZERO-STATE CANDIDATE — OWNER/LOGOS REVIEW REQUIRED`

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
- No source, test, migration, DB, build, commit, push or publication action is authorized by this documentation candidate.
- `DOCUMENTATION ZERO-STATE CANDIDATE` is not runtime acceptance, release acceptance or publication acceptance.

## Evidence identity

- Recovery worktree: `C:\Projekti\OPC\OPC v.1\RECOVERY\OPC-PODSETNIK-URNA-PEPEO-SECONDARY-CYCLE`
- Recovery HEAD: `39bde964d26a9cf7f0eb57939fd52fde9662be37` (detached, pre-existing recovery delta)
- Windows executable SHA-256: `99ED7DB0A07DF74D6249B088DD0B3D63777A6DDE97CF2C14ABF83A107CBEB5E6`
- Windows `data\app.so` SHA-256: `7548E1B1C02B5F6EF11525BE2510F01D08A2C70C249408AD8725AD477A44666B`
- Android APK SHA-256: `3FC05CB7A2001EE9E6C6612A8FC0A100BA38B77DA04FE62BE64F76250C0BCE3B`
- Canonical DB path: `C:\Users\Steva\Documents\opc_v4_release.sqlite`
- Canonical DB SHA-256 observations: earlier post-runtime `DF422DA0124A15A57E8211D372898B84CCB23560A7BFB6A5082C416E32062832`; latest read-only observation `EC63CC8110E4AA610806A015D3FD27FDCEF7E7D14BEC3C3C1DDD177166CFC0FA`

The changing DB hash is recorded as an observed runtime/private-data evidence finding; it is not interpreted here as a migration defect and no repair or DB operation is authorized.
