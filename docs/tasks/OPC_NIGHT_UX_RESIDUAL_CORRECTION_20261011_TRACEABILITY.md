# NIGHT UX residual correction — 2026-10-11

## Authority and scope

OWNER continued the existing `OPC v1.5 – NIGHT UX RESIDUAL CORRECTION PACKAGE`
for UX-01A, UX-01B, UX-05 and UX-06 only. All four requirements apply across
Windows, Android Narrow and Android Wide; responsive presentation may differ.
Physical runtime, UX-02/03/04/07/08/09, DATA-01, rebaseline, commit and push
were not authorized. Existing mixed-worktree changes and control evidence were
preserved.

PREDMET remains the sole business truth. No business rule, persistence schema,
JSON/backup contract, KATALOG/IRiU data contract or SCENARIO behavior changed.
The change is presentation-only and introduces no new architecture or data
dependency. The source-of-truth map and protected active-source CSV were not
changed. The accepted pre-task active-source result was
`20/28 LITERAL MATCH – 8/8 PROVENANCE RESOLVED`; no post-change `28/28` claim or
rebaseline is made.

## Requirement traceability

| Requirement | Implemented behavior | Source and focused evidence | Result |
|---|---|---|---|
| UX-01A | Removed the redundant `PREDMET <broj>` AppBar subtitle from the PARTE composer. The name-based composer title and operational PREDMET identity elsewhere remain. | `lib/features/predmeti/parte/presentation/parte_composer_screen.dart`; `test/parte_module_screen_test.dart` asserts the title remains and the technical subtitle is absent. | PASS — source/test |
| UX-01B | ČITULJE preparation AppBar identifies the selected PREDMET by trimmed name and surname, uses one-line ellipsis, and falls back to `ČITULJE` when identity is blank. Existing selection flow re-fetches the selected PREDMET before opening preparation. | `lib/features/predmeti/citulje/presentation/citulje_module_screen.dart`; `test/citulje_module_screen_test.dart` covers selection changes, long identity and narrow/wide layout. | PASS — source/test |
| UX-05 | In the open-case exit dialog, `OSTANI`, `IZAĐI` and `ZATVORI PREDMET` now use equal TextButton emphasis. Their actions/results and lifecycle handlers are unchanged. | `lib/features/predmeti/presentation/predmet_screen.dart`; `test/predmet_compact_chrome_test.dart` asserts all three are TextButtons and `OSTANI` preserves `OTVOREN`. | PASS — source/test |
| UX-06 | Removed visible fraction counters and status words from segment hub cards, Wide sidebar tiles and open section headers. Existing value counting and coral/amber/green fill mapping remain. Screen-reader semantics retain state/count where already provided; navigation and business values are unchanged. | `lib/features/predmeti/presentation/predmet_screen.dart`, `lib/features/predmeti/presentation/predmet_segment_manual_fields.dart`; `test/night_ux_refinement_test.dart` covers empty/partial/filled colors, no visible counters, and Android Narrow, Android Wide and Windows Wide navigation/header presentation. | PASS — source/test |

UX-02 through UX-04 and UX-07/08/09 were not changed by this task. No physical
device behavior is inferred from widget tests or release builds.

## Source-learning and engineering-profile impact

- PARTE identity was already present in the primary AppBar title; only the
  duplicate number subtitle was removed.
- ČITULJE route selection already resolves current PREDMET data before route
  push. The display now uses that current data rather than the technical case
  number; the selected PREDMET and preparation behaviors remain intact.
- The close action's callback was preserved; only button visual hierarchy
  changed.
- Segment fill state was already computed from current user-editable fields.
  Visible text counters were removed while the count model and fill colors
  stayed intact.
- Windows, Android Narrow and Android Wide use the same business semantics.
  Focused coverage exercises narrow Android and both wide presentations.
- Domain invariants: unchanged. Architecture/deployment: no new dependency or
  platform behavior. Persistence/compatibility: unchanged. Verification:
  required focused tests, analyzer, full serial suite and both authorized
  release builds completed. Runtime and owner acceptance: explicitly deferred.
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md` is not changed: no authority home, domain
  ownership, architecture boundary or data-contract map changed. This report,
  current-development state and quality/release state carry the task delta.

## Verification

- Focused four-file regression set: `26 passed / 0 failed`, exit code `0`.
- Dedicated `night_ux_refinement_test.dart`: `11 passed / 0 failed`, exit code
  `0`.
- `flutter analyze --no-pub`: `No issues found!`, exit code `0`.
- Full serial `flutter test --no-pub --concurrency=1`:
  `651 passed / 9 skipped / 0 failed`, exit code `0`. Skips were existing
  legacy or explicit environment/copy-gated forensic cases; no result is
  inferred for them.
- Windows release build: PASS, exit code `0`, 199.8 seconds.
  - `build/windows/x64/runner/Release/OPC.exe`: 89,600 bytes,
    SHA-256 `E6C2805D1F99621DDA30260B916289AF8CF3A1115BD7B28C80B13A0C5F830BAD`.
  - `build/windows/x64/runner/Release/data/app.so`: 13,239,216 bytes,
    SHA-256 `62637680ECCB41A276EAB1E83340C67D21D32E3804956962CE2992CF7B29950C`.
- Android production release build: PASS, exit code `0`, 980.1 seconds.
  - `build/app/outputs/flutter-apk/app-production-release.apk`: 79,682,339
    bytes, SHA-256
    `958774004A3082D6A6C35560AA00C18BE2832CD4A820062A8B768A9584FBF110`.
- No install or physical runtime was performed. Build artifacts are not device
  acceptance.

## Incidental finding and disposition

During the first Narrow UX-06 widget-test attempt, opening Segment 2 at a 390
logical-pixel Android test viewport produced a Flutter `RenderFlex overflowed
by 45 pixels on the right` warning in the existing `DropdownButtonFormField`
for `mestoSmrti` at
`lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart:857`.
This field-layout issue is outside UX-01A/01B/05/06. The final UX-06 color test
uses pre-seeded synthetic test values and does not open that field. No
production-PREDMET data was used or changed and no correction was made.

Classification: `OUT_OF_SCOPE`; current-task impact: none to the four accepted
requirements; scope effect: `NO_SCOPE_CHANGE`; authority effect:
`DOES_NOT_CREATE_AUTHORITY`. It is preserved in the task-local incidental
findings record for the next separately authorized Narrow PREDMET responsive
layout review. It does not create a standalone implementation task or business
requirement.

## Active-source and review boundary

The protected control CSV/manifest remains unchanged. The pre-task
`20/28 LITERAL MATCH – 8/8 PROVENANCE RESOLVED` result is historical context
for this implementation, not a post-edit hash PASS. Source changes in the
already mixed worktree are task-authorized and remain attributable through
pre-edit snapshots and task-local diffs. No rebaseline was performed.

The external review package contains pre-edit provenance, scoped source/test
diffs, QA/build evidence, incidental finding disposition, and canonical ZIP
manifest/integrity results. Status after packaging:
`READY FOR LOGOS/OWNER REVIEW`. This is not physical runtime acceptance or
Logos/OWNER approval.
