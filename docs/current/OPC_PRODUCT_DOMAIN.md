# OPC Product and Domain — Re-baselined Current Boundary

**Status:** `CURRENT ZERO-STATE CANDIDATE — BUSINESS AUTHORITY REMAINS OWNER-BASED`

This document records the bounded domain frame for the recovered current build. It does not promote implementation into business authority.

## Product invariants

- `PREDMET` is the sole authoritative business truth for a concrete case.
- Windows and Android are equal functional peers; platform differences are technical delivery differences, not separate business policy.
- The lifecycle is `OTVOREN → ZATVOREN → ZAVRŠEN`; `ZAVRŠEN` is terminal for ordinary business editing.
- SCENARIO production behavior remains protected by the locked scenario contract.
- User-controlled JSON transfer, full backup/restore, local persistence and notification delivery are separate technical contracts.

## URNA/PEPEO contract boundary

The OWNER contract is treated as locked for review: the applicable ceremony types are `KREMACIJA` and `KREMACIJA_EKSPRES`; `NAKNADNO` is excluded; the post-ceremony cycle activates at `+3` calendar days; configured `deliveryTimes` govern delivery slots; completion stops the cycle; visible wording is semantic and must not expose raw rule keys.

The implementation/release/runtime/publication state is separate from that business contract. In particular, the business contract being locked does not mean that Windows delivery, runtime acceptance, release or publication is accepted.

## Authority warning

Historical task naming is provenance only. The correct current-state formulation is: **URNA/PEPEO business contract je zaključan; implementation, runtime acceptance, release i publication status moraju se voditi zasebno prema stvarno završenom stanju.**

Direct OWNER decisions prevail over conflicting reports. Source, tests and runtime evidence can establish technical behavior or observation, but cannot invent or amend business policy.

## Complete system contract coverage

| Contract surface | Current boundary |
|---|---|
| FIRMA / FirmaPodaci | Local firm identity/context used by cases and documents; editable data is not a server identity |
| ADMINISTRATOR / SAVETNIK | Local access and responsibility context; portable responsibility must remain distinct from importer/creator |
| PREDMET lifecycle | `OTVOREN → ZATVOREN → ZAVRŠEN`; PREDMET remains the only concrete-case truth |
| KATALOG / IRiU | Catalogue truth supplies selected case snapshots; IRiU is PREDMET-scoped operational/financial truth |
| OSNOVNI PAKET / SCENARIO | Applied package state is a PREDMET snapshot; protected scenario behavior is not silently rewritten |
| PARTE / documents / PDF | Derived preparation and rendered outputs; generation does not change business completion |
| STANJE ROBE | Operational stock consequences derived from selected case rows |
| NAPOMENA / BIOHAZARD | Case-scoped notes/presentation inputs; no hidden authority is inferred from labels |
| Backup/restore / PREDMET transfer | Separate full-backup and single-case representations with explicit compatibility boundaries |

## Product-level traceability boundary

Direct OWNER authority is indexed in `OPC_OWNER_AUTHORITY_TRACEABILITY.md`.
Recovered implementation paths are indexed in `OPC_SOURCE_TRACEABILITY.md` and
`OPC_AS_BUILT_ARCHITECTURE.md`. The current documentation set does not claim
that a source path, test, runtime capture, release artifact or historical task
name is a business decision.
