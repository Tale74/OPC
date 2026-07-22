# OPC TASK — PARTE MODULE SHORTCUT TO PREDMET PARTE SEGMENT CORRECTION REPORT

## Status

`IMPLEMENTATION PASS — AUTOMATED VALIDATION AND RELEASE BUILDS PASS — RUNTIME CONFIRMATION PENDING`

## Git identity

- Branch: `task/OPC-PARTE-MODULE-SHORTCUT-PREDMET-PARTE-SEGMENT`
- Base SHA: `8984b9702d7b69f7f4179d7b84563dca1433e787`
- Implementation SHA: `d55532a2293f23a14e52362b478d94a79959c4c9`
- Merge to `main`: not performed

## OPC MANIFEST CHECK — TASK START

- Manifest read: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- Manifest compliance checked: same-PREDMET navigation, PREDMET authority,
  derivative MODUL PARTE boundary, IRiU preservation and platform equality.
- PASS / NOT PASS: PASS.

## Runtime finding

The MODUL PARTE shortcut opened PREDMET segment 7 `Roba i usluge` and focused
IRiU `POSMRTNE_PARTE`. Owner runtime evidence established that the required
destination is PREDMET segment 6 `PARTE`.

No deletion, persistence, render, PDF, DOCX, template or printer behavior is in
scope for this correction.

## Root cause

`ParteModuleScreen` passed `openIriuParte: true` to `PredmetScreen`.
`PredmetScreen.initState` explicitly resolved that flag to
`_PredmetLogicalSection.robaIUsluge`, and `IriuSegment` received
`POSMRTNE_PARTE` as its initial focus.

The earlier test asserted only the PREDMET id at an injected callback boundary;
it did not assert the constructed destination section. That allowed the wrong
segment mapping to pass.

## Correction

- Replace the IRiU-specific navigation intent with `openParte`.
- Resolve `openParte` to `_PredmetLogicalSection.parte`.
- Remove the IRiU `POSMRTNE_PARTE` focus from this shortcut.
- Rename the module action, callback, widget key and tooltip so their semantics
  explicitly identify PREDMET segment `PARTE`.
- Make the focused test inspect the constructed `PredmetScreen` destination and
  assert both the same PREDMET id and `openParte == true`.

The resulting navigation is:

`MODUL PARTE -> same PREDMET -> segment 6 PARTE`

It must never resolve to:

`MODUL PARTE -> segment 7 Roba i usluge -> POSMRTNE_PARTE`

## Protected boundaries

- PREDMET remains authoritative.
- `POSMRTNE_PARTE` in IRiU remains untouched.
- Deleting a MODUL PARTE derivative still deletes no PREDMET/IRiU data.
- Canonical render, PDF, DOCX, media, templates and printer profiles are
  unchanged.
- Normal Back returns to the existing MODUL PARTE route.
- Windows and Android use the same shared navigation source.

## Validation

- `flutter analyze --no-pub`: PASS — no issues found.
- Focused `parte_module_screen_test.dart`: PASS — 3 tests.
- Complete `flutter test --no-pub`: PASS — 247 passed, 1 skipped, 0 failed.
- `git diff --check`: PASS; line-ending notices are non-failing Git warnings.
- Manifest gate: PASS.
- UTF-8 strict decode: PASS for every changed documentation file.
- Added-line privacy scan: PASS; no private runtime path or artifact was added.
- Windows release build: PASS — `build/windows/x64/runner/Release/OPC.exe`.
- Android release APK build: PASS —
  `build/app/outputs/flutter-apk/app-release.apk` (`73.3 MB`).
- Both builds were run manually by the owner after automated validation passed.
- Runtime: confirmation of segment 6 opening remains pending in the next
  available application runtime.

## Documentation alignment

Updated current authority:

- `docs/OPC_OWNER_DECISION_GUIDE.md`
- `docs/OPC_OWNER_DECISION_INDEX.md`
- `docs/OPC_MODULE_RELATIONSHIP_MAP.md`
- `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`

The previous task report contains an explicit supersession note so its original
runtime-disproven IRiU destination is not mistaken for current authority.

## OPC MANIFEST COMPLIANCE — TASK END

- PREDMET remains the sole case authority.
- MODUL PARTE remains a derivative technical workflow.
- IRiU data is neither opened nor modified by the corrected shortcut.
- No private runtime evidence is included.
- Automated validation is PASS; only runtime navigation confirmation remains.
