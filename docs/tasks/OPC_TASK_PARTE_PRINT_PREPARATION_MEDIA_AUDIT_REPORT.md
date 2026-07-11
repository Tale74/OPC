# OPC Task Report — PARTE Print-Preparation Business, Data, Template and Media-Lifecycle Audit

## 1. Task identity

- Branch: `task/OPC-PARTE-PRINT-PREPARATION-MEDIA-AUDIT`
- Verified base: `de9b41abbc6c0adce5a82d9b69cfd484134f7589`
- Task class: `AUDIT / SOURCE LEARNING / TEMPLATE AND MEDIA ANALYSIS`
- Production source implementation: none
- Database/schema changes: none
- JSON behavior changes: none
- Asset changes: none
- Build/runtime/print test: not performed

## OPC MANIFEST CHECK — TASK START

Manifest read: yes

Manifest path:
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Task class:
- `AUDIT / SOURCE LEARNING / TEMPLATE AND MEDIA ANALYSIS`

Core purpose preserved:
- yes

PREDMET impact:
- `AUDIT OF FUTURE AUTHORITATIVE INPUTS`

PARTE impact:
- `AUDIT ONLY`

Photograph impact:
- `AUDIT ONLY — NO IMPORT OR DELETION IMPLEMENTED`

Symbol impact:
- `AUDIT ONLY — NO ASSETS ADDED`

Database/schema impact:
- `NONE`

JSON impact:
- `NONE`

Production behavior impact:
- `NONE`

Database ownership affected:
- no

Windows/Android parity affected:
- audit only; shared future truth and platform delivery boundary documented

Future OPC Web affected:
- audit only; portable media identity requirement documented

Terminology drift risk:
- controlled; PREDMET and PARTE boundaries preserved

Implementation allowance:
- `AUDIT ONLY — NO IMPLEMENTATION`

Required gate before implementation:
- owner decisions for fields, grammar, template, symbol, photo storage/deletion, output, JSON/backup, anonymization, package and platform delivery

Decision:
- proceed with source/template audit and Git-tracked documentation only

## 2. Baseline verification

- Local HEAD matched the expected base.
- Local branch context matched the requested prior task branch.
- Remote prior branch resolved to the same full SHA.
- Working tree was clean before branch creation.
- No differing local/remote baseline was detected.

## 3. Owner-reference forms

Both required local DOCX references were found and directly inspected. Public evidence is sanitized:

- one male and one female form;
- one custom landscape page each;
- same visual skeleton, floating shapes and symbol;
- content/grammar variants for introductory phrase and death verb;
- OPELO versus ISPRAĆAJ branch;
- conditional profession line;
- photo, symbol, life years, ceremony/cemetery and mourners present;
- Word Choice/Fallback compatibility content physically duplicates logical text in OOXML but is rendered as one branch;
- name uses 58-pt bold Times New Roman in a no-wrap/fit cell;
- photographs have materially different source resolution;
- shared cross is byte-identical to an existing OPC symbol asset.

The DOCX files, extracted text, photographs and personal details were not added to Git. No real personal-data fixture was created.

## 4. Current PARTE behavior

Current source implements:

- persisted symbol ID and script;
- title, profession, rank, middle-name and nickname display choices;
- free-text mourners;
- gender/date/ceremony/OPELO/send-off-derived text;
- inline text preview;
- text-only PARTE panel in LISTA PDF;
- raw PARTE fields in PREDMET PDF snapshot;
- shared Windows/Android source and a limited narrow stacking rule.

Current source does not implement:

- deceased photograph or crop;
- real symbol rendering in PARTE;
- standalone print-ready PARTE PDF/image;
- page/template selection;
- print preview/direct printing;
- media ownership, retention, deletion or regeneration;
- media JSON/backup/anonymization behavior.

Additional gaps recorded:

- UI and LISTA duplicate composition logic;
- current public sentences omit `časova`;
- `parteIme` is stored/transferred but not edited/consumed by current PARTE;
- symbol IDs/options do not map to a complete individual asset catalog;
- `advancedParte` entitlement exists but does not gate current PARTE UI;
- current anonymization retains mourners and has no photo/artifact rule.

## 5. Field-to-template summary

Already available from PREDMET:

- first/surname, middle name, nickname;
- binary `M/Z` field;
- birth/death dates and derived years;
- title/profession/rank and display flags;
- ceremony type/date/time and cemetery;
- OPELO state/place/time and send-off time;
- mourners, script and symbol ID.

Absent:

- deceased photo/media identity and bytes;
- crop/orientation/quality metadata;
- template ID/version;
- real symbol catalog resolution;
- standalone artifact reference/generation metadata;
- approved public grammar fallback and long-content policy.

## 6. Symbol findings

- Existing assets: individual Svetosavski cross, individual David star and a multi-symbol strip.
- Current UI lists more symbol concepts than there are individual assets.
- Current preview/LISTA shows only symbol labels.
- Reference cross equals the current Svetosavski file, but is not approved as universal default.
- Future catalog needs stable IDs, asset/version, dimensions, transparency/color, provenance/license, active/deprecated state and missing-ID warning.
- Symbol must never be inferred only from sex and must never be silently substituted.

## 7. Photograph and deletion findings

Five models were compared. Audit recommendation, still requiring owner decision: hybrid retention based on an app-owned normalized copy.

Hard boundary:

```text
OPC must not silently modify or delete the user's original external photograph.
```

Deleting an OPC-owned prepared copy after generation is technically possible but loses future editing, crop/reflow, new template/size generation and recovery if the artifact disappears. Automatic deletion is not safe to approve without a finalization/regeneration/anonymization decision.

No photograph was imported, copied to Git, altered or deleted by this task.

## 8. Output-format finding

Compared:

- generated PDF;
- generated image;
- HTML/print surface;
- DOCX filling;
- direct printer canvas.

`AUDIT RECOMMENDATION — OWNER DECISION REQUIRED`: a deterministic one-page PDF generated from a shared layout model is the safest first cross-platform artifact. Existing KORICE delivery can save/open it. Direct printing should remain a separate later delivery capability.

## 9. JSON, backup, anonymization and package findings

- Current PARTE fields already travel through PREDMET JSON.
- Full backup already has a BLOB/base64 precedent for logo/catalog photos, but single-PREDMET transfer has no media block.
- A future media model cannot rely on a Windows absolute path, Android content URI or external gallery file.
- Current anonymization does not cover mourners, future photo or generated artifacts.
- Package downgrade must never delete PREDMET-owned media; future entitlement ownership requires owner decision.

## 10. Windows/Android parity

Shared future state must include the same PREDMET fields, grammar, validation, symbol ID, crop coordinates, layout model, PDF bytes and retention policy.

Only delivery may differ:

- picker API;
- physical app-owned storage path/URI;
- KORICE path/content URI;
- viewer/direct-printer availability.

Android narrow UI must stack, wrap and scroll photo/symbol/preview/actions without hidden controls or overflow.

## 11. Owner-decision queue

Created audit navigation queue `OPC-PARTE-ODQ-001` through `OPC-PARTE-ODQ-015` covering:

- required fields and grammar;
- template/page/font/public wording;
- orphaned `parteIme`;
- symbol catalog/default/fallback/provenance;
- photo formats/crop/DPI/storage;
- retention/deletion/regeneration;
- JSON/full backup/anonymization;
- output/direct print;
- long-content behavior;
- package downgrade;
- artifact metadata/print meaning.

These are not owner-approved decisions.

## 12. Recommended implementation sequence

1. Authoritative PARTE/media/template/transfer/anonymization/package decisions and shared composer.
2. Atomic app-owned media import, crop/normalize/quality, symbol catalog and deletion states.
3. One approved deterministic PDF layout with no-truncation preflight.
4. Equal Windows/Android UI with narrow behavior and viewer/export delivery.
5. Synthetic fidelity, restart, JSON/backup, anonymization, downgrade and parity validation.

Explicitly outside the first implementation:

- direct printer integration;
- automatic photo deletion;
- biometric/face processing;
- broad multi-template editor;
- PODSETNIK/workflow/completion semantics;
- unapproved package changes.

## 13. Documentation artifacts

Created:

- `docs/OPC_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md`
- `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`
- `docs/tasks/OPC_TASK_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md`

Updated:

- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_OWNER_DECISION_GUIDE.md`

No production source, schema, test fixture, asset, platform or package file was changed.

## 14. Validation

- `flutter analyze --no-pub`: PASS — no issues found
- `flutter test --no-pub`: PASS — all 132 tests passed
- manifest gate: PASS — task report accepted against base `de9b41abbc6c0adce5a82d9b69cfd484134f7589`
- UTF-8/BOM/mojibake: PASS — all five changed documentation files are strict UTF-8, without BOM or detected mojibake
- documentation paths: PASS — all five required documentation artifacts exist
- production-source unchanged gate: PASS — every changed path is under `docs/`; no DOCX, source, asset, schema, fixture, package or platform file is included
- personal-data documentation scan: PASS — no supplied person name or supplied external path is present in the changed documentation
- `git diff --check`: PASS
- GitHub visibility: PASS — branch and required documentation were published; remote branch SHA matched audit commit `c8071fcd8e37b6173e54ef41091ed83cec8cc17d`
- clean working tree: PASS after the audit commit/push; to be rechecked after this verification-note commit

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
- yes — audit documents one shared model and technical delivery differences only

Existing JSON transfer preserved:
- yes — no source behavior changed

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes — portable media identity and no absolute-path dependency required

Source changes within scope:
- yes — documentation only

Photograph imported or deleted:
- no

Symbol asset added:
- no

Build/runtime/print test run:
- no

Special gates satisfied:
- yes — reference documents were inspected read-only, no photograph was imported or deleted, no symbol asset was added, and no build/runtime/print execution was performed

GitHub verification status:
- PASS
- branch: `https://github.com/Tale74/OPC/tree/task/OPC-PARTE-PRINT-PREPARATION-MEDIA-AUDIT`
- audit commit: `https://github.com/Tale74/OPC/commit/c8071fcd8e37b6173e54ef41091ed83cec8cc17d`
- audit report: `https://github.com/Tale74/OPC/blob/task/OPC-PARTE-PRINT-PREPARATION-MEDIA-AUDIT/docs/OPC_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md`
- task report: `https://github.com/Tale74/OPC/blob/task/OPC-PARTE-PRINT-PREPARATION-MEDIA-AUDIT/docs/tasks/OPC_TASK_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md`
- pseudocode: `https://github.com/Tale74/OPC/blob/task/OPC-PARTE-PRINT-PREPARATION-MEDIA-AUDIT/docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`

If not compliant, classify:
- NOT PASS

PASS / NOT PASS:
- PASS

## 15. Final status

`AUDIT PASS — PHOTOGRAPH RETENTION/DELETION POLICY REQUIRES OWNER DECISION — NO IMPLEMENTATION AUTHORIZED`
