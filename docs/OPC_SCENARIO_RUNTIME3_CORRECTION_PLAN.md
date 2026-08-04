# OPC SCENARIO runtime 3 correction and validation report

## Outcome

The Runtime 1, Runtime 2 and Runtime 3 findings were implemented in the
single authoritative SCENARIO path. The KATALOG tab no longer presents a
parallel OSNOVNI PAKET policy. Scenario policy is edited through the scenario
overview and editor, while catalog items remain the reusable item source.

## Implemented corrections

- Scenario overview is a compact business view with place/condition hierarchy,
  exclusions, consequences, warnings and actions.
- Existing conditions are editable as a hierarchy; selected consequences stay
  visible, removable and re-addable.
- Consequence editing exposes only business status, reason and warning.
  Provider and ordering metadata remain persisted but are not user-facing.
- `NE PRIMENJUJE SE`, internal provider/order text and diagnostic paragraphs are
  absent from the scenario UI.
- PREDMET display resolves persisted catalog names and falls back to
  `Dodatna stavka`; generated `KORISNIK_*` identifiers never render.
- BOLNICA + ZARAZNA with a non-cremation ceremony retains LIMENI ULOZAK and
  LEMOVANJE as separate consequences; cremation variants exclude them.
- Legacy compatibility data is preserved for migration tests, but active basic
  package policy is owned by SCENARIO.

## Validation evidence

Validation was run in the required order after the final source changes:

- `flutter analyze` — PASS, `No issues found!`, exit code 0.
- Complete `flutter test` — PASS, 350 passed, 3 skipped, no failures or
  timeouts, exit code 0.

The complete suite includes scenario UI contracts, single-truth and migration
invariants, legacy schema migrations, PREDMET display protection, and the
BOLNICA/ZARAZNA consequence path.

The owner's decision authorizing Windows and Android builds after clean
analyze/test results was applied. Builds are evidence of packaging only and do
not replace manual runtime acceptance over a verified copy of the canonical
database.

Build evidence from this validation run:

- Windows release — PASS, exit code 0. Artifact:
  `build/windows/x64/runner/Release/OPC.exe`, 89,088 bytes,
  SHA-256 `32172CD5C2760D5A222A949A0F03C8BCE431D76E7F42A9155B6C2312A84B8F39`.
- Android universal APK — NOT CERTIFIED. Two Gradle attempts produced no
  completion output; the build workers were stopped and the final attempt
  returned `ANDROID_BUILD_EXIT=-1`. The existing APK was not used as evidence.

## Acceptance boundary

Windows and Android runtime acceptance remains pending. The owner must perform
the smoke flow against a canonical database copy: migration of existing policy,
base package presence, scenario editing and persistence, BOLNICA/ZARAZNA
business result, and preservation of user decisions after reinitialization.
