# OPC — SCENARIO Card-Based UI, Open-PREDMET Semantics and Protection Report

## Status

Implementation completed on branch `task/OPC-SCENARIO-CARD-UI-SEMANTICS-CORRECTION`, based on predecessor baseline `66ae20a9a1b005c0d7d66e8c6cf760ee7d5d4421`. No production database was created or replaced, and no canonical business kernel or IRiU ordering service was changed.

## Owner protection sequence

The owner-approved sequence was followed exactly:

`APPROVED — CONTINUE` → exact `BACKUPS` path and inventory verification → permanent deletion of obsolete backup and restore-point artifacts → fresh current SOURCE backup → fresh restore-point files → protection-point verification → production source changes.

The verified destination was `C:\Projekti\OPC\OPC v.1\BACKUPS`. Its pre-change inventory contained 15 ZIP and 5 SQLite direct-child artifacts, with no subdirectories or path escapes. All 20 obsolete artifacts were removed before creating the new protection point.

Fresh protection point:

- archive: `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_SCENARIO_CARD_UI_SEMANTICS_CORRECTION_20260815_153734.zip`
- SHA-256: `D3776BB28C4CFA533E2FFD8BE8BE0D3B8304C981809CB7940F6C914E0E5C7FEF`
- size: 228,867,183 bytes; 879 entries
- verified contents: `lib/`, `test/`, `docs/`, and `assets/`; excluded `.git`, `build`, `RUNTIME`, `runtime_data`, and caches
- restore marker: `RESTORE_POINTS/RESTORE_POINT_20260815_1537_PRE_SCENARIO_CARD_UI_SEMANTICS_CORRECTION.md`
- marker SHA-256: `C407F352F753BEBE25B9BD9E4F107419270F9F63EEA379639241367ECB3A9E07`

## Implemented owner semantics

- SCENARIO policy is presented as ordered cards: `OSNOVNI PAKET`, `SCENARIJI`, and first-class `NOVI SCENARIO`.
- `NOVI SCENARIO` is the only creation entry point in the card layout; the old isolated add control is not rendered in the policy tree.
- Open PREDMETs are a separate section after the policy cards.
- The selected PREDMET shows `PRIMENJENO NA PREDMET`, `OSNOVNI PAKET`, and `PRIMENJENI SCENARIO PAKET`, followed by manual correction guidance through IRiU.
- `UREDI RELEVANTNI SCENARIO` and technical snapshot/provenance labels are not active primary UI for the selected PREDMET.
- Existing ordered IRiU projection and provenance are consumed; no replacement ordering, hardcoded item list, or package-content golden order was introduced.
- Scenario preview now uses business headings `USLOVI PRIMENE` and `DODATNE STAVKE SCENARIJA`, with consequences displayed in their defined order.
- Existing definitions remain reusable policy/editor objects; corrections to a concrete PREDMET remain IRiU manual add/remove operations.
- OSNOVNI and SCENARIO definition changes remain future-only. No persistent notice was enlarged and no contextual `Pomoć` mechanism was added.
- Active terminology remains `preminulo lice` / `preminulog lica`; no blind global replacement was performed.

## Evidence and validation

- Focused SCENARIO screen tests: passed; two legacy assertions remain explicit opt-in skips.
- Relevant regression set: 21 passed, 5 expected skips, 0 failures.
- Full serial machine suite: `flutter test --machine --concurrency=1`, `success=true`, exit 0; 666 visible tests completed. Log: `C:\Projekti\OPC\OPC v.1\RUNTIME\validation_logs\full_suite_scenario_card_ui_20260815.json`.
- Static analysis: `flutter analyze --no-pub` — `No issues found!`.
- Windows release: `flutter build windows --release` — exit 0. `build/windows/x64/runner/Release/data/app.so` SHA-256 `31AB8BB1A186E94FD494D57EDFF648C2AFBBB82BD8A917B9582D8327321B0622` (12,764,080 bytes).
- Android release: `flutter build apk --release` — exit 0. `build/app/outputs/flutter-apk/app-release.apk` SHA-256 `7453CCA06247A9713EC7FB3006F9883EAD3898676ADE057F56217E4E53098DD6` (78,337,911 bytes).

## Runtime acceptance boundary

The Windows Computer Use Sky runtime was unavailable in this environment. Therefore interactive Windows runtime acceptance is **NOT PROVEN** here; the successful release build is build evidence only. Existing owner screenshots remain runtime-behavior evidence, not root-cause or authority evidence. No PASS claim is made for unobserved geometry, click targets, persistence, or Android device parity.

## Final classification

Source implementation, tests, analysis, protection point, Windows release build, and Android release build are complete and verified. Interactive Windows/Android device acceptance remains a separately bounded evidence item because the required Computer Use runtime was unavailable.
