# OPC task — PARTE final technical-text placement UI regression

Date: 2026-07-19

Branch: `task/OPC-PARTE-FINAL-TECHNICAL-TEXT-PLACEMENT-UI-REGRESSION`

Base SHA: `19be7d2485ad0b3cf2ed02bc87c70fa078149dde`

Final SHA: assigned by Git when this report and the verified correction are committed

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
- Windows release build: OWNER MANUAL VALIDATION PENDING — intentionally not
  started because the owner reported only 9% weekly usage remaining.
- Android release build: OWNER MANUAL VALIDATION PENDING — intentionally not
  started; it must follow a successful Windows build and must not run in
  parallel.
- Windows runtime visual smoke: PENDING.
- Android runtime: PENDING — requires a connected device or emulator.

Owner manual build commands, after the complete test suite passes:

```powershell
Set-Location -LiteralPath 'C:\Projekti\OPC\OPC v.1\SOURCE'
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
- yes — shared responsive source and narrow widget coverage pass; owner manual
  release builds remain pending by explicit instruction

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes

PASS / NOT PASS:
- IMPLEMENTATION PASS — OWNER MANUAL WINDOWS/ANDROID BUILDS PENDING
