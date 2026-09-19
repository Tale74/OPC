# OPC Internal Development-Control Register

**Status:** `CURRENT INTERNAL-DEVELOPMENT BOUNDARY POINTER`
**Publication boundary:** This register is a public boundary record only. The internal artifacts listed here are not market-facing SOURCE documentation, handover documentation or production specifications.

## Purpose and authority boundary

OPC PSEUDOCODE is continuity/source-learning material describing observed
implementation causality. EXPERIENCE records evidence-backed engineering
lessons about safe work with the current system. Both are internal
development-control layers only. Current OWNER authority and current source,
tests and runtime evidence retain their respective authority; neither layer is
product, business, requirements, implementation or roadmap authority.

During Phase 1 Closure Correction, the then-existing pseudocode set was
physically separated from the Git-visible `docs/` surface. The table below is
the historical inventory/hash record for that predecessor set; it is not a
current inventory of the v1.5 local controls. The current v1.5 layers are:

- `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/` — current source-learning map.
- `INTERNAL_DEVELOPMENT_CONTROL/EXPERIENCE/` — evidence-based engineering
  experience.

Both directories are explicitly ignored by the repository and are not public
Git/GitHub publication targets. Original Git paths remain historical boundary
pointers; they do not imply that the full local artifacts are published.

## Current v1.5 control pointers — 2026-09-19

- Active development SOURCE: `C:\Projekti\OPC_v1.5\source`.
- Current local-only active-source package:
  `INTERNAL_DEVELOPMENT_CONTROL/ACTIVE_SOURCE_CONTROL/OPC-V1.5-ACTIVE-SOURCE-CONTROLLED-REBASELINE-20260919/`.
  This is current-target control/evidence, not implementation authority or a
  donor.
- Current PSEUDOCODE:
  `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`.
  It is rebuilt from current v1.5 source-learning and remains continuity
  material, not a second source of truth.
- Current EXPERIENCE:
  `INTERNAL_DEVELOPMENT_CONTROL/EXPERIENCE/OPC_ENGINEERING_EXPERIENCE.md`.
  It preserves evidence-bound engineering lessons; it creates no product
  requirement, business rule or roadmap priority.
- The predecessor SOURCE at `C:\Projekti\OPC\OPC v.1\SOURCE` and its
  recovery-era active-source package are frozen provenance only and
  donor-prohibited. Historical hashes/inventory below do not define the
  current v1.5 control set.
- PREDMET remains the sole business truth. The normal OWNER roadmap is active;
  this register selects no roadmap member or implementation work.

The durable active-source and donor boundary is also governed by
[`docs/OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`](OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md).
That document governs implementation/evidence classification and donor-use
prechecks; this register continues to govern local control-layer boundaries.

## Historical artifact inventory — predecessor separation record

| Original Git path | Local internal artifact | SHA-256 recorded at separation | Historical content action | Authority role |
|---|---|---|---|---|
| `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md` | `A13F5D6D703AB397BB37EA4303F82271DEC2D8EE836C092170DE6AE16E8BEE3C` | Predecessor map record; superseded locally by the rebuilt v1.5 map above | Historical internal development control |
| `docs/OPC_CANONICAL_DATABASE_RECOVERY_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_CANONICAL_DATABASE_RECOVERY_PSEUDOCODE.md` | `4C80F1A398D84702AC56CDA60E27611691856D2FB5DA8981D9BF2094F9125209` | Phase 2 synchronization header; body current with explicit recovery/release deltas | Internal development control |
| `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md` | `B2B9E970DEE28C8911B489496E45AFF68208DF17F1C8D386AAB43E1D902E12BE` | Phase 2 synchronization header; body current with explicit package/carrier deltas | Internal development control |
| `docs/OPC_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_PSEUDOCODE.md` | `18581B1B6083E04893BAEBE74C10075E4B9D34FC35848704DEB4B886C76EBF25` | Phase 2 synchronization header; body current with explicit package/reminder deltas | Internal development control |
| `docs/OPC_OWNER_DECISIONS_STATUSI_CEREMONIJA_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_OWNER_DECISIONS_STATUSI_CEREMONIJA_PSEUDOCODE.md` | `62F5F76AC780F0D96C6F77D2C4FCB7BBB45DF2E371D2C763D6C5CEFC8F9061BD` | Phase 2 synchronization header; body current with explicit owner deltas | Internal development control |
| `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md` | `56217CC4C1F6537C288F8F7BCEFCB960C56A04B303E289F888566EAA32EACBBC` | Phase 2 synchronization header; body current with explicit document/release deltas | Internal development control |
| `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md` | `FA469B9D64B0F85C3C8996395EBD67E6D5DBC52106D88D130E04EBCF0D79ADD8` | Phase 2 synchronization header; body current with explicit visual-acceptance deltas | Internal development control |
| `docs/OPC_PODSETNIK_CONTROL_FLOW_AND_USER_CONFIRMATION_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_PODSETNIK_CONTROL_FLOW_AND_USER_CONFIRMATION_PSEUDOCODE.md` | `093C4611333D163506E8EF3586A18EAE64744EA36D2ABA2882F26B662F2447F9` | Phase 2 synchronization header; body current with explicit owner-signal deltas | Internal development control |
| `docs/OPC_PRE_POINT_4_CORRECTIONS_AUDIT_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_PRE_POINT_4_CORRECTIONS_AUDIT_PSEUDOCODE.md` | `FABCA1187EDAD73118A834D50A21D843B261F94E9CC24CB5A676044312CC1681` | Historical/evidence-only boundary added; preserved audit content | Internal development control |
| `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md` | `D981495FB7A927FD6AA912550D15DBF6A87F67E9D3A996EDE797B430848FBFF6` | Historical/evidence-only boundary added; preserved pre-build content | Internal development control |
| `docs/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md` | `16EAB15F26216C0E21777CDB374A94A07BDF4E4B49ED853EE1020D5A0B08E167` | Historical/evidence-only boundary added; preserved superseded policy content | Internal development control |
| `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md` | `F5CBC9EB30DC5A7718DD41A306EB0D760D773F7EC69DA230DB8E49DB9E44F3FB` | Phase 2 synchronized master overlay; historical index body preserved | Internal development control |
| `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md` | `6E871A1AEFAE8F9A0B43CA94ED8239E2B1CB9C70E7B0893550C69EDC2C3D62AA` | Phase 2 synchronization header; body current with historical sections and explicit deltas | Internal development control |
| `docs/OPC_WINDOWS_IDENTITY_PERSISTENCE_AUDIT_PSEUDOCODE.md` | `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/OPC_WINDOWS_IDENTITY_PERSISTENCE_AUDIT_PSEUDOCODE.md` | `DDC1128827C5B83EC97C5717797FA61EB9746D7C5B2FA041E8CF9435872C970D` | Phase 2 synchronization header and entitlement supersession; body current with explicit Windows deltas | Internal development control |

The separate task report `docs/tasks/OPC_TASK_BUSINESS_CRITICAL_SOURCE_TO_PSEUDOCODE_MAP_LOGOS_LEARNING_LAYER_REPORT.md` remains historical task evidence; it is not part of the moved pseudocode content.

## Why this SOURCE-side pointer remains

This short register is retained only to preserve discoverability, local-path
boundaries and byte/hash verification for the already separated pseudocode
artifacts during active OPC maintenance. It is not a reusable operating manual,
product specification or co-equal current authority. If the local continuity
set is formally retired, this pointer may be archived with the same no-loss
controls; no methodology depends on keeping it in the product documentation
surface.

## Operating rule

Future tasks may update local PSEUDOCODE or EXPERIENCE only when their scope
explicitly requires that continuity/evidence work. Any product/current-state
truth needed by public documentation must be represented independently in the
current authority homes. No public navigation depends on the internal
directory, and neither local layer authorizes implementation or roadmap work.
