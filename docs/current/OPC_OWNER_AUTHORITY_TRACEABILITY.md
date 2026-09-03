# OPC Owner Authority Traceability — Current Candidate

**Status:** `AUTHORITY INDEX — OWNER DECISIONS PREVAIL`

This index identifies the direct OWNER/locked continuity surfaces used for the
current candidate. It does not promote reports or source into business
authority. Where a row is not directly confirmed, it remains open.

| Business assertion | Direct authority/provenance | Current destination | Status |
|---|---|---|---|
| PREDMET is sole case truth | `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md` | `OPC_PRODUCT_DOMAIN.md` | Locked/current |
| Windows and Android are equal peers | `OPC_OWNER_DECISION_REPORT.md` and OWNER gate | product/domain + architecture | Locked/current |
| SCENARIO production protection | `docs/OPC_SCENARIO_MODULE_LOCK.md`, lock hash `a8218537c1aa85b61fe5c85c21dbd03672f6e77c` | product/domain + architecture | Locked/protected |
| URNA/PEPEO applicability, +3, NAKNADNO and deliveryTimes | latest OWNER authorization/task instructions in this task lineage | `OPC_PODSETNIK_CONTRACT_AND_STATUS.md` | Locked/current contract |
| Exact cemetery fallback, labels and semantic wording | latest OWNER correction/acceptance instructions in this task lineage | PODSETNIK contract + gap matrix | Locked/current contract |
| ZAVRŠEN contract separate from implementation/runtime status | latest OWNER correction | product/domain + implementation state | Locked/current boundary |
| `Predati zahtev` wording | latest OWNER decision surface referenced by the task | PODSETNIK contract | Confirmed wording |
| NALOG CVEĆARI contract | latest OWNER task authority | PODSETNIK contract | Contract present; implementation open |
| Overview bar/presentation cadence | latest OWNER decision surface referenced by the task | PODSETNIK contract | Current-authoritative per owner instruction |
| Historical task naming | OWNER correction: not active current-state language | all current docs | Retired as authority |

## Conflict rule

The direct OWNER decision is authoritative when identifiable and applicable.
`OPC_OWNER_DECISION_INDEX.md`, guide, reports and internal pseudocode are
supporting/historical unless a specific direct decision is identified. Source,
tests and runtime can prove behavior or observation only. Any unresolved
business conflict is reported as `OWNER DECISION REQUIRED` with no inference.
