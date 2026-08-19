# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Report

## Result

`RR-011 CLOSED — FULL ANDROID STRUCTURAL ACCEPTANCE PASS`

The two previously unproven structural chains now have bounded physical evidence in the disposable `ANDROID_TEST` lane: scenario-snapshot cleanup was exercised with a real snapshot/provenance precondition, and the supported single-PREDMET export/import replacement preserved the PREDMET identity while recreating its dependent IRiU rows without integrity or foreign-key violations. RR-011 is administratively closed; no RR-011 structural successor remains.

## Baseline and protected surfaces

- Branch: `task/OPC-RR011-ANDROID-TEST-LANE-INITIALIZATION-CORRECTION`
- HEAD/base at execution: `0c4a38474657ab648b692748f832773da7693030`
- Windows canonical database SHA-256 pre/post: `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` (unchanged).
- `windows/runner/main.cpp` SHA-256: `FFD03CCA5821FB1813CDF2D9CAADB687C79DB1E8AFA0CB27976EE8C379885863` (unchanged).
- No production source, tests, platform behavior, schema/migrations, dependencies, SCENARIO or canonical/private data were changed.

## Lane and identity

- Device: LGN LX1, Android 15/API 35; ADB state `device`; package `com.tale.opc_v4`.
- Physical structural lane: explicit `ANDROID_TEST`, database `opc_v4_android_test.sqlite`, accessed read-only through `run-as` after normal app actions.
- Accepted release identity remains separate: default/no-define `PRODUCTION`, database `opc_v4_release.sqlite`, APK SHA-256 `C7A0A2CB9B98516838F41DA7DE51E50C4D0287C493195F2F88CF0372612C2DD4`.
- No storage permission was requested or granted; exports used the Android document provider and the designated `Downloads/KORICE` folder.

## Structural chain 1 — scenario-snapshot cleanup

1. `Test_B` was opened through the supported UI after setting `MESTO SMRTI=BOLNICA` and `UZROK SMRTI=PRIRODNA`.
2. Opening `Roba i usluge` caused a real scenario synchronization. A read-only pre-action copy contained one `predmet_scenario_snapshots` row for PREDMET 2, scenario `MAP_PRIRODNA_BOLNICA_SAHRANA_GRADSKO_GROB_NE_NE_NE`, plus owned scenario IRiU/provenance state.
3. The supported `Obriši trajno` → `OBRIŠI TRAJNO` flow was completed normally.
4. The read-only post-action copy contained only the remaining synthetic PREDMET, `snapshot_count=0`, `orphan_snapshots=0`, `orphan_provenance=0`, `integrity_check=ok`, and zero `foreign_key_check` rows.

**Chain 1: PASS.** This is a real precondition/action/postcondition result, not a zero-row inference.

## Structural chain 2 — single-PREDMET replacement

1. `Test_A` was assigned the same scenario-driving facts and opened through `Roba i usluge`; the read-only pre-replacement copy contained one snapshot, one provenance row and 12 IRiU rows for the PREDMET.
2. The supported `Dokumenti` → `Izvezi JSON` action created `Test_A_190826_0726_v1.json` in `Downloads/KORICE`. Settings → `Uvoz JSON` selected that file, the existing-number conflict was displayed, and `Zameni uvoznim` was completed normally.
3. The read-only post-replacement copy contained exactly one PREDMET with the same ID `1` and business number `190826_0726`, 12 newly recreated IRiU rows all owned by that PREDMET, no duplicate business number, zero snapshot/provenance rows, `integrity_check=ok`, and zero foreign-key violations.
4. The export JSON was inspected structurally: its supported `OPC_PREDMET` shape contains `predmet`, `iriu` and `kontaktLica`; it does not carry `predmet_scenario_snapshots` or `iriu_provenance`. Therefore removal of those derived scenario/provenance rows on replacement is recorded as the format boundary, not silently reclassified as a defect.
5. After normal relaunch and owner authentication, the list again showed the same single PREDMET. A final read-only copy preserved the same ID/number, 12 IRiU rows, zero snapshots/provenance rows, `integrity_check=ok`, and zero foreign-key violations.

**Chain 2: PASS (format-bounded).** Stable PREDMET identity, dependent-row replacement, persistence and database integrity are proven; scenario/provenance carriage is outside the single-PREDMET JSON contract.

## Acceptance matrix summary

| Area | Status | Evidence boundary |
|---|---|---|
| Scenario-snapshot cleanup | PASS | Real snapshot precondition, normal hard-delete, zero post-action snapshots/orphans, integrity/FK pass |
| Single-PREDMET replacement | PASS (format-bounded) | Same PREDMET identity, 12 dependent IRiU rows recreated, no duplicate, relaunch persistence, integrity/FK pass; snapshot/provenance not represented by `OPC_PREDMET` JSON |
| Android DB integrity | PASS (`ANDROID_TEST`) | `user_version=27`, `integrity_check=ok`, zero FK violations, zero relevant orphans, no WAL/SHM sidecars at captures |
| Canonical Windows DB / protected source | PASS | Canonical and runner hashes unchanged; protected implementation surfaces unchanged |

## Control transition

The technical acceptance is complete and RR-011 is administratively closed with no remaining successor. RR-005/RR-010 remain closed, RR-008 remains owner-gated, active Phase 5 successors remain `0`, and SCENARIO remains locked.

- CROSS-PHASE CONTINUITY CHECK: PASS.
- SOURCE COVERAGE CHECK: PASS.
- ORPHAN/GAP SCAN: PASS (zero orphans; no successor-less outcome).
- FORWARD-ACTION OWNERSHIP CHECK: PASS.
- `git diff --check`: PASS at handoff.

## MANDATORY LOGOS NEXT CONTROL

Logos must independently verify the new public closure commit, its hashes and manifest, the exact committed path set, the public RR-011 `CLOSED` state, absence of any RR-011 successor, and the protected-surface hashes. Codex must not begin another Android task, alter source, or unlock SCENARIO from this report alone. The publication result is eligible for the next roadmap task only after Logos records this control as PASS.
