# OPC Quality, Release and Evidence Boundary

**Status:** `NALOG CVEĆARI CLOSED; QA/RENDER/BUILD PASS; BROADER PHASE 2 OWNER REVIEW PENDING; RELEASE/PUBLICATION SEPARATE`

The locked sequence for the authorized Phase 2 correction was: targeted
protecting tests, relevant regressions, `flutter analyze --no-pub`, full
`flutter test --no-pub`, Windows release build and bounded Windows runtime
acceptance. These statuses remain separate from business authority, release,
commit, push and publication.

## Exact build evidence

- Recovery worktree: `C:\Projekti\OPC\OPC v.1\RECOVERY\OPC-PODSETNIK-URNA-PEPEO-SECONDARY-CYCLE`.
- Windows executable: `build/windows/x64/runner/Release/OPC.exe`.
- Windows `OPC.exe` SHA-256: `99ED7DB0A07DF74D6249B088DD0B3D63777A6DDE97CF2C14ABF83A107CBEB5E6`.
- Current Windows `data/app.so` SHA-256: `EB312C7574AEB2C07D66DBC24B702000BBB50C456B2EBE1F7E2EBD341AC99CC5`.
- `flutter analyze --no-pub`: PASS — no issues found.
- Full `flutter test --no-pub`: PASS — `482` passed, `10` skipped.

## Latest final-decoration-removal evidence

The latest authorized Cvećari correction removes the botanical section-label
pattern completely and leaves the right side of each label empty. Renderer
evidence was generated from the corrected source for 1, 2, 3 and 10 items;
the 10-item artifact remains 3 pages. The final GUI export is now accepted as
the two-page artifact recorded in the closure evidence. Evidence and hashes are recorded in
`REVIEW_EVIDENCE/P2_VIS_007_DECORATION_REMOVAL_EVIDENCE.md`.
- Windows release build: PASS.
- Earlier Android release APK evidence is retained as `3FC05CB7A2001EE9E6C6612A8FC0A100BA38B77DA04FE62BE64F76250C0BCE3B`; no Android physical acceptance is claimed.

## Windows runtime evidence

- Phase 1 vitality: startup, login, LISTA PREDMETA, existing PREDMET opening and segment navigation 1–10 PASS.
- `TEST URNA PHASE2` (case `030926_1820`) displayed the active URNA obligation. After manual completion, the checkbox remained checked after reopening and LISTA displayed `OBAVEZE ISPUNJENE`.
- Reminder toggle was observed OFF and ON through the normal UI.
- `NALOG ZA OPREMANJE` was generated as a one-page A4 PDF and visually reviewed; SHA-256 `6745E70D4F4552BAC746427499A0D222E0CB0363638D4867DF14690EB4CDFC3B`.
- `NALOG CVEĆARI` was generated and visually reviewed with blank ribbon text, SHA-256 `D86EFF01F946B4FD64FCBEB25C185BFA34C7979E18BF795FFF4FE2E7E4AE0718`, and with non-empty ribbon text, SHA-256 `8C6F9E166D5B953856BFBB487B6F0A0FCDEF86D6749EE2A7A1195DC102EE0558`.

## OWNER/LOGOS artifact review

The earlier `OWNER/LOGOS ARTIFACT REVIEW — FAIL` is historical and bounded to
the pre-correction `NALOG CVEĆARI` artifact. The current bounded renderer and
final OWNER GUI evidence are PASS for the NALOG CVEĆARI scope. The historical
findings are:

- `P2-PDF-001 — SHARED PDF TYPOGRAPHY NONCONFORMITY`;
- `P2-PDF-002 — SHARED MEMORANDUM/HEADER/FOOTER OUTPUT NONCONFORMITY`;
- `P2-PDF-003 — PASTEL LABEL / FLORAL MOTIF NONCONFORMITY`;
- `P2-PDF-004 — CEREMONY HEADING GRAMMAR NONCONFORMITY`; present
  `PODACI O KREMACIJA` as `PODACI O KREMACIJI` without mutating canonical
  business values.

For `P2-GAP-003`, implementation is `IMPLEMENTED`, automated QA is `PASS`,
the four technical PDF findings are closed by GUI evidence, and the technical
portion of `P2-PDF-003` is closed. `P2-VIS-004/005/006` and `P2-GAP-003` have
final OWNER visual acceptance PASS for the NALOG CVEĆARI scope; `P2-VIS-003`
remains a separate viewer-state classification. Broader Phase 2 acceptance is
`NOT ACCEPTED`.
The other seven capabilities are not reopened.
- Windows secondary delivery was observed after startup and successful login for `PREDOJEVIĆ LJUBOMIR`: modal title `Podsetnik za ceremoniju`; body `ZA LJUBOMIR PREDOJEVIĆ ZAKAZATI POLAGANJE URNE U GROB NA NOVO.`. Returning to LISTA is not the trigger.

## Database boundary

Canonical DB: `C:\Users\Steva\Documents\opc_v4_release.sqlite`.

After normal application shutdown, read-only identity was:

- SHA-256: `CE0FCEF14C33A088961D53E7C9096CC9ABCA1D61EDC0552774FCB459F5AFEA5E`;
- length: `82829312` bytes;
- schema/user_version: `31`;
- `integrity_check`: `ok`.

Phase 2 runtime writes were performed only by normal OPC UI actions on
disposable test PREDMET data within the OWNER-authorized canonical runtime
target. No direct SQL business write, migration repair, reset, import/restore
or direct SQL cleanup was performed. Normal runtime hash change is not itself a
defect.

## Release/publication separation

The current published documentation baseline is commit
`18099d448e7b71d2bfb875a671c1f9d9e845b187` on
`origin/recovery/OPC-TASK1-CLEAN-FA6FEDD`, a clean fast-forward from previous
baseline `74809d08136e5350d2b848a341fd0d1e6f598d09`. It contains exactly the
11-file documentation/evidence publication set. Remaining local Phase 2
implementation/source/test/evidence dirty state was not included and remains
uncommitted/unpublished. No release acceptance or broader Phase 2 acceptance is
implied.

## Stage B bounded evidence update (historical)

Stage B corrected only `P2-GAP-003` PDF artifact findings
`P2-PDF-001/002/003/004`. The final source uses the shared PDF theme,
memorandum header, footer and pastel section-label helpers for the bounded
Cvećari/Opremanje surface. The corrected Cvećari render visibly contains
`PODACI O KREMACIJI`, the observed ribbon text and the common footer; the
Opremanje comparison render confirms the shared path without changing its
business content.

Stage B evidence is: targeted Cvećari/shared PDF tests `17` PASS; analyzer
PASS; full suite `481` passed and `10` skipped; Windows release build PASS;
`OPC.exe` SHA-256
`99ED7DB0A07DF74D6249B088DD0B3D63777A6DDE97CF2C14ABF83A107CBEB5E6`; and
`data/app.so` SHA-256
`2078406D0E8FD737C074CED4A0C5112A0A491CEB4AE8E786A4AF35EC0317E425`.

The two post-correction PDF artifacts and their visual review are recorded
under `REVIEW_EVIDENCE/qa/`. They were generated through the shared renderer
test with the observed `TEST URNA PHASE2` values and no database write. A
fresh final Windows GUI export is now additionally recorded in
`REVIEW_EVIDENCE/STAGE_B_GUI_REEXPORT_EVIDENCE.md` using the two
owner-supplied PDFs. Their hashes, extracted text and Poppler renders were
checked read-only; the four bounded PDF findings are `CLOSED — GUI EVIDENCE
PASS`. Renderer evidence remains distinguished from runtime acceptance.

## Historical pre-closure synchronization addendum — 2026-09-04

This section preserves earlier GUI/build identities as historical evidence only;
the final accepted two-page GUI artifact and final current status are recorded
below. The earlier owner-supplied GUI Cvećari artifact had SHA-256
`E36E027266B7BA5E758E13C227C36287E280A2C5A8AE0CF0170F09A93620F151`; the
Opremanje comparison artifact is SHA-256
`494A2ACD46AB2CB2EF888701FD41D72FDF0E9DCFD8A0CA0902EE060E7CBEAC8B`.
The previous pre-visual-correction OWNER-visible Stage C `data/app.so` identity was
`9E90B61C8223922EA2CA5F06962FB072A3C4F66CECF4ECFB8D01E3FE00B62EF0`.
Read-only render review confirms the current neutral sage/ivory-green labels,
absence of three-dot markers and botanical ornament, current images and row
ribbon values without the literal `TEKST TRAKE`.

`P2-PDF-001/002/004` and the technical portion of `P2-PDF-003` are
`CLOSED — GUI EVIDENCE PASS`. `P2-GAP-003` and `P2-VIS-004/005/006` have
final OWNER/Logos visual acceptance PASS for NALOG CVEĆARI. `P2-VIS-003`
remains a separate viewer-state classification; broader Phase 2 is not
accepted by this closure. The original invisible-window incident is resolved as Codex
sandbox desktop isolation; fresh Computer Use still returns `apps=[]` and is
documented separately as a tooling state.

## Current bounded visual correction — P2-VIS-007

The latest OWNER-authorized correction changed only the local Cvećari section
label decoration. `P2-VIS-003` was not changed, and `P2-VIS-005/006` were
preserved. Current evidence is recorded in
`REVIEW_EVIDENCE/P2_VIS_007_DECORATION_REMOVAL_EVIDENCE.md`.

- `P2-VIS-004`: `FINAL OWNER/LOGOS VISUAL ACCEPTANCE PASS`.
- `P2-VIS-005`: `PRESERVED / REGRESSION PASS / NOT REOPENED`.
- `P2-VIS-006`: `PRESERVED / REGRESSION PASS / NOT REOPENED`.
- `P2-VIS-003`: `VIEWER-STATE CAUSE INDICATED — NO OPC ARTIFACT CORRECTION AUTHORIZED`.

The focused 1/2/3/10-item renderer artifacts, full test result (`482 passed /
10 skipped`), analyzer PASS, Windows build PASS and current build hashes are
listed in that evidence file. The final GUI export is closed for NALOG
CVEĆARI; broader Phase 2 remains pending separate OWNER review.

Latest `P2-VIS-007` evidence supersedes earlier artifact details for this
candidate: `P2-VIS-004` has no decoration, `P2-VIS-005` retains the inset-safe
image frame, ribbon PDF text omits the literal `TEKST TRAKE`, and
`P2-VIS-006` is preserved. Refreshed artifact hashes, Poppler render/text
results, `482 passed / 10 skipped`, analyzer PASS, Windows build PASS and
current hashes are in
`REVIEW_EVIDENCE/P2_VIS_007_DECORATION_REMOVAL_EVIDENCE.md`.
## Final NALOG CVEĆARI closure — 2026-09-05

Accepted artifact: `C:\Users\Steva\Downloads\KORICE\PREDMET_PROBNI_040926_2318_NALOG_CVECARI_v1.pdf`;
SHA-256 `6257C3BB1E082EFA7CE043DED059753D5DD0725F8E8D0EF61D00250E3795551A`;
two pages. The later two-page export reflects additional CVEĆE items in the
same PREDMET. No QA, build or runtime was rerun by this documentation task.

`NALOG CVEĆARI CLOSED — BROADER PHASE 2 OWNER REVIEW STILL PENDING`.
