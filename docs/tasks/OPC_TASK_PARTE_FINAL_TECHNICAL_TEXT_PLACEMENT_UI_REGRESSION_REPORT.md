# OPC task — PARTE final technical-text placement UI regression

Date: 2026-07-19

Branch: `task/OPC-PARTE-FINAL-TECHNICAL-TEXT-PLACEMENT-UI-REGRESSION`

Base SHA: `19be7d2485ad0b3cf2ed02bc87c70fa078149dde`

Implementation SHA: `de708deb81d85d789b2b088a0f706ef4da77bcbb`

Owner-tested final correction HEAD: `805ad18865fddb3181bf27e6cfc82d7cfffd5b53`

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation / documentation / runtime correction

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no; portable PARTE template JSON remains printer-independent

Windows/Android parity affected:
- responsive shared UI only; behavior remains equal

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes

Required gate before implementation:
- platform parity and non-printing UI boundary

## Runtime evidence and root cause

The owner evidence in the private, non-Git `SMOKE_LOGS/PARTE NALAZI` folder
confirms that physical print is acceptable for the tested printer with the
local per-template `+25/+4 mm` profile. PDF and Word-rendered DOCX retain the
complete one-line name, en-dash, media fidelity and mourners blocks.

The remaining blocker was a UI placement regression introduced at base commit
`19be7d2`: `_ParteEditorTechnicalGuide` was removed from the preview side while
printer explanation remained attached to the command-area heading. The narrow
widget test explicitly required `Actual size / 100%` to be absent, thereby
locking the wrong behavior. The format `ExpansionTile` also lacked the top
clearance already used by the text section, leaving first-row floating labels
vulnerable to clipping.

## Correction

- The command-area printer heading contains controls only, without explanatory
  prose or tooltip.
- A compact `POMOĆ ZA PREGLED I ŠTAMPU` card is displayed under the
  `PREGLED PRIPREME` heading and before `PartePlanPreview`.
- The card explains editor-only guides, the active-template whole-PDF offset and
  `Actual size / 100%` printing.
- The card is outside the printable canvas and is not represented in
  `ParteRenderPlan`; exporters and portable JSON are untouched.
- The format expansion receives explicit top padding so `Strana – širina` and
  the remaining floating labels clear the expansion boundary.

## Protected behavior

Unchanged:

- canonical render plan and preview/PDF/DOCX parity;
- one-line name fit and `74 pt` maximum;
- en-dash normalization;
- DOCX Behind Text media;
- selected/active/default template state;
- machine-local per-template printer profiles and legacy migration;
- portable template JSON;
- safe margins and derived X/Y;
- PREDMET and retained preparation behavior.

## Tests and validation

- Focused narrow composer test: PASS, 2 tests.
- Formatter: PASS.
- `flutter analyze --no-pub`: PASS — no issues, 186.9 s.
- Complete `flutter test --no-pub`: PASS — 242 passed + 1 skipped, 0 failed,
  18:30.
- Owner manual `flutter analyze`: PASS / final green completion. Exact duration
  and analyzer count are not asserted because no reliable retained log was
  available during this documentation closure.
- Owner manual complete `flutter test`: PASS / final green completion. Exact
  test total and duration are not asserted here.
- Windows release build: PASS, executed manually only after both green gates.
- Android release build: PASS, executed manually after the Windows build.
- Windows owner runtime: `PRINUĐENI PASS` — completed and accepted sufficiently
  to proceed, without claiming that every UX/refinement issue is ideal.
- Android owner runtime: `FUNCTIONALLY SATISFACTORY`.
- Android follow-up: `REFINEMENT FINDINGS MATERIAL IN PREPARATION`.

Owner manual build commands, after the complete test suite passes:

```powershell
Set-Location -LiteralPath '<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\SOURCE'
C:\flutter\bin\flutter.bat build windows --release --no-pub
C:\flutter\bin\flutter.bat build apk --release --no-pub
```

## Privacy and repository hygiene

Private runtime PDF, DOCX, JSON and photographs remain outside Git. No build
output, user database, printer profile file or personal data is added.

## Physical print status

`PASS FOR TESTED PRINTER PROFILE` — Letter / Actual size with the local
per-template `+25/+4 mm` correction. This is not a global default and is not
portable template data.

## Owner Windows/Android runtime closure

Closure recorded: 2026-07-22. The exact runtime execution date was not retained
in repository evidence and is therefore not invented.

- Tested branch lineage culminates in
  `task/OPC-PARTE-MULTILINE-PDF-FORMAT-OFFSET-REGRESSION` at
  `805ad18865fddb3181bf27e6cfc82d7cfffd5b53`.
- Windows: `PRINUĐENI PASS`.
- Android: `FUNCTIONALLY SATISFACTORY`.
- Android follow-up: `REFINEMENT FINDINGS MATERIAL IN PREPARATION`.
- The defined technical-text UI correction objective is closed.
- The former private evidence folder was intentionally removed by the owner
  because its findings were stale and irrelevant. It is not a missing-evidence
  blocker. Any future evidence at that path is authoritative only after prior
  owner notice.
- No follow-up requirement is authorized or inferred from this closure.

`DO NOT START PARTE FOLLOW-UP IMPLEMENTATION UNTIL OWNER FINDINGS PACKAGE IS DELIVERED AND REVIEWED.`

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes — owner manually completed both release builds after green validation and
  executed runtime on both native platforms

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes

PASS / NOT PASS:
- `PARTE FINAL TECHNICAL-TEXT UI CORRECTION CLOSED – WINDOWS PRINUĐENI PASS – ANDROID FUNCTIONAL RUNTIME SATISFACTORY – FOLLOW-UP REFINEMENT FINDINGS PENDING`
