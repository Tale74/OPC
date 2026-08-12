# OPC current development state

**Status:** `CURRENT RECONCILED CONTINUITY SUMMARY`

**Baseline:** `78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9`

**Reconciled:** 2026-08-12

This is the concise current-state entry point. Detailed dependency ordering is
in `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`; forensic
evidence and the full reality matrix are in
`docs/OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md`.

The application/product name is `OPC`. `OPC Srbija` is internal shorthand only
for the stable Serbian-market product-line gate and is not a rename.

## Current proven baseline

- OPC is a functional Windows/Android Flutter application with local
  Drift/SQLite and user-controlled JSON transfer.
- `PREDMET` remains the sole business truth.
- Architecture decision: retain the codebase; use progressive/bounded refactor
  only where evidence proves a need. Full rewrite is not supported.
- Automatic `ZAVRŠEN` is retired. The implemented transition is explicit
  `OTVOREN → ZATVOREN → ZAVRŠEN`; final state is immutable for direct edits and
  reopening. Focused tests pass; separate final platform runtime acceptance is
  still required.
- SCENARIO is an operational module under `MODULI`, not `PODEŠAVANJA`.
- SCENARIO implements user-editable OSNOVNI PAKET + additional scenario package,
  1,008 owner-map combinations, PREDMET-derived conditions, PREDMET-owned
  snapshot/provenance, controlled reconciliation, manual/legacy row protection
  and non-retroactivity.
- Windows live release runtime and a physical Android 15 device both passed the
  production `MODULI → SCENARIO` OPEN-PREDMET selector, derived/current versus
  applied snapshot and required IRiU behavior.
- Full eight-axis GRADSKO/LOKALNO consistency passed cross-platform. The earlier
  mismatch report was a selected-state reading error, not a source/DB defect.
- Independent 1,008 golden and production E2E gates pass 1,008/1,008 with zero
  key, item, status or ordering mismatches.
- KATALOG/IRiU FIKSNA pricing, CRNINA as KATALOŠKA, applied price snapshot,
  `KOM × CENA = IZNOS`, manual amount override and OSNOVNI pricing are
  technically implemented and tested.
- Latest inherited technical baseline: analyzer PASS; complete suite 393
  passed, 7 skipped, 0 failed; Windows and Android release builds PASS.

## Important partial/open state

| Area | Current state | Next evidence/action |
| --- | --- | --- |
| SCENARIO JSON | Pure envelope and Single-PREDMET adapter contracts exist, but production `OPC_PREDMET` schema 6/7 and `OPC_BACKUP` schema 8 do not serialize SCENARIO snapshot/provenance. | Integrate both carriers with schema/fail-closed/legacy/rollback and Windows/Android round-trip proof. |
| PREDMET/referential lifecycle | Hard-delete and scoped restore work have technical/runtime evidence; FK remains off and some RI owner gates remain. | Close only release-required risks; classify deferred RI work explicitly. |
| Windows single-instance | Audit proved concurrent canonical DB risk; no native process guard exists. | Implement the locked named-mutex and installer running-app contract; runtime accept. |
| Windows startup/exit | Installed baseline reached login in about 8–9 s and slow exit was observed. | Current-tip instrumented measurement and owner target before any correction. |
| Android PARTE performance | Source risks are mapped; focused current-device profiling acceptance is absent. | Reproduce/profile before choosing a correction. |
| IRiU/KATALOG performance | Repository behavior is characterized; owner-observed slowdown is not decomposed. | Time repository, first frame, photo read and decode separately. |
| PODSETNIK | Prior orphan/restore corrections exist; complete signal/informed-reminder model does not. | Full lifecycle-aware program after owner-confirmed signal model. The Android notification for a `ZAVRŠEN` PREDMET belongs here, not in an isolated patch. |
| Backup/restore release gate | Prior successful incidents are scoped evidence. | Repeat final rehearsal on release-candidate artifacts after SCENARIO carrier integration. |
| Documents | RAČUN PDF exists; NALOG CVEĆARI standalone generator is not proven; standard PDF typography refinement remains. | Owner decisions for RAČUN availability/default and NALOG content/scope; bounded document work. |
| Theme/UI/UX | Shared source uses `ThemeMode.system`; only bounded runtime/UI impressions exist. | Verify theme parity and perform full Windows/Android UI/UX audit. Contextual help is a later design direction. |
| MODUL DVE VALUTE | Not implemented. | Mandatory before stable OPC v.1 and before `OPC_v.1_Int`. |
| App identity/release | Current technical Android identity is `com.tale.opc_v4`, version `4.0.0+1`; this is not a final owner release decision. | Decide version/update channel/release baseline; visible name remains OPC. |

## Current dependency order

Documentation reconciliation → Windows single-instance and remaining
release-risk integrity closure → evidence-first performance closure → SCENARIO
JSON carrier parity → complete signal model and full PODSETNIK upgrade →
remaining JSON/document/theme/UI work → MODUL DVE VALUTE → final
Windows/Android semantic parity and backup/restore rehearsal → app
identity/version/update channel → stable OPC v.1 product-line gate → optional
non-blocking debt → `OPC_v.1_Int` → signing/professional handover.

## Active owner decisions

- performance acceptance targets after measurement;
- complete signal meanings for PODSETNIK;
- NALOG CVEĆARI content and PDF/DOCX scope;
- RAČUN FIRMA availability/default;
- EUR activation timing and eligible open-PREDMET treatment;
- final app version/update channel and release baseline;
- publisher/signing-key custody.

Already decided and not returned to the active queue: explicit completion
lifecycle, SCENARIO ownership/placement/application, application name `OPC`,
dual currency before `OPC_v.1_Int`, and non-blocking Stage 2 cleanup.

## Prohibitions

No current authority permits application renaming, Web implementation,
international localization, automatic exchange rates, tax/VAT/fiscalization,
package restriction restoration, isolated PODSETNIK status patching, broad
rewrite, or canonical database replacement.
