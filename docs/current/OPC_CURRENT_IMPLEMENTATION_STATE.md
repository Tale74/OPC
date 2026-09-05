# OPC Current Implementation State

## Current Stage C overlay

`P2-VIS-001/002` remain closed by final GUI artifact evidence. The latest
authorized `P2-VIS-004` correction removes the botanical section-label pattern
with no replacement decoration; `P2-VIS-005/006` remain preserved and
renderer-verified. `P2-VIS-003` remains viewer-state-only. The final OWNER GUI
artifact is accepted for the NALOG CVEĆARI scope; broader Phase 2 remains
pending separate OWNER review.

**Status:** `RECOVERED AS-BUILT / NALOG CVEĆARI GUI ACCEPTED / QA-RENDER-BUILD PASS / BROADER PHASE 2 OWNER REVIEW PENDING`

## Latest bounded correction — botanical pattern removal

`buildOpcPastelSectionLabel()` now returns the existing pastel section-label
container directly. The former botanical `CustomPaint` ornament and its helper
are absent. No business content, shared memorandum/footer path, item tuple,
image frame, ribbon value, page-break behavior or ceremony wording changed.

## Identity

- Recovery worktree: `C:\Projekti\OPC\OPC v.1\RECOVERY\OPC-PODSETNIK-URNA-PEPEO-SECONDARY-CYCLE`.
- Recovery HEAD: `74809d08136e5350d2b848a341fd0d1e6f598d09`, detached; this is the last documentation zero-state publication commit.
- Recovery worktree evidence at final documentation closure: `0 staged / 43 unstaged / 50 untracked` (historical snapshot retained for provenance; no worktree normalization was performed). The snapshot includes pre-existing implementation delta plus this bounded correction's test/artifact/documentation evidence.
- Current read-only Recovery worktree observation during publication reconciliation (2026-09-05): `0 staged / 46 unstaged / 50 untracked`; this is the live continuity value for this reconciliation and no worktree normalization was performed.
- Windows executable: `build/windows/x64/runner/Release/OPC.exe`, SHA-256 `99ED7DB0A07DF74D6249B088DD0B3D63777A6DDE97CF2C14ABF83A107CBEB5E6`.
- Previous Stage B Windows `data/app.so`: `build/windows/x64/runner/Release/data/app.so`, SHA-256 `2078406D0E8FD737C074CED4A0C5112A0A491CEB4AE8E786A4AF35EC0317E425`.
- Previous pre-visual-correction Stage C Windows `data/app.so`: `build/windows/x64/runner/Release/data/app.so`, SHA-256 `9E90B61C8223922EA2CA5F06962FB072A3C4F66CECF4ECFB8D01E3FE00B62EF0`.
- Current/final accepted Windows `data/app.so`: `build/windows/x64/runner/Release/data/app.so`, SHA-256 `EB312C7574AEB2C07D66DBC24B702000BBB50C456B2EBE1F7E2EBD341AC99CC5`.
- Superseded bounded-correction candidate Windows `data/app.so`: `build/windows/x64/runner/Release/data/app.so`, SHA-256 `6B8ABF473309E9A14E254DAB09FFECE17FA9BBB584AD259769FF65C5803864EB` (historical evidence only).
- Android APK identity retained from the earlier authorized build evidence: `3FC05CB7A2001EE9E6C6612A8FC0A100BA38B77DA04FE62BE64F76250C0BCE3B`. No Android physical acceptance is claimed.

## Verification state

- Targeted Cvećari/multi-item/Stage B artifact tests: PASS; shared PDF regressions: PASS — 4 tests.
- `flutter analyze --no-pub`: PASS — no issues found.
- Full `flutter test --no-pub`: PASS — `482` passed, `10` skipped.
- Windows release build: PASS; the exact artifact identity is recorded above.
- Windows Phase 1 vitality: startup, login, LISTA PREDMETA, existing PREDMET opening and segment navigation 1–10 were observed PASS.
- Phase 2 runtime observations: the test PREDMET `TEST URNA PHASE2` displayed the URNA obligation, manual completion remained checked after reopening, and LISTA PREDMETA displayed `OBAVEZE ISPUNJENE`.
- Phase 2 document observations: `NALOG ZA OPREMANJE` and `NALOG CVEĆARI` were generated and visually reviewed; the latter was reviewed both with blank and non-empty `TEKST TRAKE`.
- Windows secondary delivery: the existing in-app startup/login modal was observed for `PREDOJEVIĆ LJUBOMIR`; its exact title/body are recorded in the Phase 2 evidence package. Return to the list is not treated as the modal trigger.

## Current correction state

The eight authorized capabilities are implemented in the recovery worktree:

1. `P2-DEF-001` — UI completion persists the current URNA/PEPEO completion signal and invokes the existing reminder cancellation/deactivation path. The `ZAVRŠEN` blocker remains repository-derived and is not UI-owned.
2. `P2-GAP-002A/B/C` — LISTA overview derives relevant parent obligations, uses the exact zero state `OBAVEZE ISPUNJENE`, and exposes the contracted placement/interaction/rotation behavior.
3. `P2-GAP-003` — `CVEĆE → Nalog cvećari` is available through the bounded PDF
action path; the technical PDF findings and the authorized `P2-VIS-004/005/006`
correction are implemented and evidence-verified. Final OWNER/Logos visual
acceptance is closed for the NALOG CVEĆARI scope by the accepted two-page GUI
artifact; broader Phase 2 acceptance is not implied.
4. `P2-GAP-004A/B` — current-item `TEKST TRAKE` is stored, editable, blank-valid, remove/re-add safe and available to the Cvećari output.
5. `P2-GAP-005` — LISTA/PDF uses the shared `OBAVEZE I NAPOMENE` projection with empty checkboxes.

These are implementation and verification facts only. They do not change the locked business contract.

## Status separation

| Layer | Current status |
|---|---|
| BUSINESS CONTRACT | Confirmed and unchanged by direct OWNER decisions |
| IMPLEMENTATION | Recovery worktree dirty delta; eight authorized capabilities implemented |
| AUTOMATED QA | Targeted, analyzer and full-suite PASS as recorded above |
| WINDOWS RUNTIME | Phase 1 PASS; bounded Phase 2 UI/document evidence recorded; NALOG CVEĆARI scope accepted; broader Phase 2 review remains pending |
| WINDOWS SECONDARY DELIVERY | Startup/login in-app modal observed; no claim that Android scheduling proves Windows behavior |
| ANDROID RUNTIME | Earlier APK/build identity only; no physical runtime acceptance |
| RELEASE | Separate gate; build output does not imply release acceptance |
| PUBLICATION | Last documentation publication commit `74809d08136e5350d2b848a341fd0d1e6f598d09` on `origin/recovery/OPC-TASK1-CLEAN-FA6FEDD`; current Phase 2 changes are uncommitted and unpublished |

## OWNER/LOGOS artifact review status

The earlier `OWNER/LOGOS ARTIFACT REVIEW — FAIL` is historical and bounded to
the pre-correction generated `NALOG CVEĆARI` PDF. Current technical artifact
evidence and final OWNER GUI visual acceptance are PASS for the NALOG CVEĆARI
scope. The stable historical findings are:

- `P2-PDF-001 — SHARED PDF TYPOGRAPHY NONCONFORMITY`;
- `P2-PDF-002 — SHARED MEMORANDUM/HEADER/FOOTER OUTPUT NONCONFORMITY`;
- `P2-PDF-003 — PASTEL LABEL / FLORAL MOTIF NONCONFORMITY`;
- `P2-PDF-004 — CEREMONY HEADING GRAMMAR NONCONFORMITY` (`PODACI O KREMACIJA`
  must be `PODACI O KREMACIJI` in presentation only).

The `NALOG CVEĆARI` implementation path remains an as-built fact. Current
automated QA, renderer evidence and final GUI evidence are PASS for the
bounded correction. The broader Phase 2 is not accepted by this closure. The
other seven capabilities are not reopened.

## Database boundary

The canonical runtime database is `C:\Users\Steva\Documents\opc_v4_release.sqlite`. Phase 2 runtime used the OWNER-authorized canonical target through normal OPC UI actions and disposable test PREDMET data. No direct SQL business write, repair, migration correction or cleanup was performed. A normal runtime byte/hash change is not itself a defect. The file was locked while the application was active; final read-only identity verification belongs after normal application shutdown.

## Authority boundary

PREDMET remains the sole business truth. Source and tests describe technical behavior; runtime records observation; neither creates business policy. Historical donor material and internal pseudocode remain subordinate forensic/technical evidence. The locked status wording remains:

`URNA/PEPEO business contract je zaključan; implementation, runtime acceptance, release i publication status moraju se voditi zasebno prema stvarno završenom stanju.`

## Historical Stage B state — bounded NALOG CVEĆARI correction

Stage B changed only the authorized PDF surface: the new shared helper
`lib/features/predmeti/pdf/opc_pdf_shared.dart`, the Cvećari renderer, the
Opremanje shared-header/footer call path, and bounded PDF tests/artifact
evidence. No business contract, source-of-truth meaning, database schema or
unrelated Phase 2 capability changed.

The four Stage B artifact findings are resolved by current source, protecting
tests and rendered artifact evidence. `KREMACIJA` is presented as
`PODACI O KREMACIJI`; ribbon text remains `TEKST TRAKE`; the shared memorandum
and footer are common to Cvećari and Opremanje; and the pastel label treatment
is visible in the corrected render.

Stage B verification below is historical. Current bounded correction
verification is focused Cvećari/multi-item tests PASS, shared PDF regressions
`4` tests PASS, analyzer PASS, full suite `482 passed / 10 skipped`, and
Windows release build PASS. Final
Windows `OPC.exe` SHA-256 is
`99ED7DB0A07DF74D6249B088DD0B3D63777A6DDE97CF2C14ABF83A107CBEB5E6`; final
`data/app.so` SHA-256 is
`EB312C7574AEB2C07D66DBC24B702000BBB50C456B2EBE1F7E2EBD341AC99CC5`.

The corrected PDFs were produced by the bounded post-correction renderer
artifact test and visually inspected. At that historical stage, this was not
represented as a fresh independent GUI re-export from the final Windows binary
because native Computer Use did not expose the app target in that session. The
later accepted two-page GUI artifact and final bounded acceptance below
supersede that evidence limitation; broader Phase 2, release and publication
status remain separate.

## Historical pre-closure synchronization addendum — 2026-09-04

This addendum is historical pre-closure evidence. The original invisible-window
evidence is classified as Codex sandbox desktop isolation, resolved for the
observed incident by the OWNER manual launch on `WinSta0\Default`. The
Computer Use bridge remained unavailable after a fresh binding reset
(`apps=[]`).

The achieved Cvećari implementation includes the shared memorandum/header/
footer and typography paths, ceremony grammar presentation, sage/ivory-green
labels, removed three-dot treatment, no botanical ornament, current flower
images and row ribbon values without the literal `TEKST TRAKE`. The prior
owner-supplied GUI export hash is
`E36E027266B7BA5E758E13C227C36287E280A2C5A8AE0CF0170F09A93620F151`.
The current OWNER-visible Stage C `data/app.so` hash is
`9E90B61C8223922EA2CA5F06962FB072A3C4F66CECF4ECFB8D01E3FE00B62EF0` (historical pre-refinement identity).

Current status is `P2-GAP-003 — IMPLEMENTED / AUTOMATED QA PASS / TECHNICAL
ARTIFACT PASS / FINAL OWNER VISUAL ACCEPTANCE PASS — NALOG CVEĆARI SCOPE`.
`P2-VIS-003` remains
`VIEWER-STATE CAUSE INDICATED — NO OPC ARTIFACT CORRECTION AUTHORIZED`;
`P2-VIS-004/005` are implemented with renderer evidence and `P2-VIS-006` is
corrected with renderer evidence. Broader Phase 2 remains pending separate
OWNER review. Earlier
Stage B and pre-correction wording is historical and superseded.

## Latest bounded presentation refinement — 2026-09-04

The current candidate supersedes earlier P2-VIS-004/005 wording: the shared
section-label helper now returns the bordered pastel label with no decoration;
the Cvećari image frame keeps its border outside a 2pt-padded centered
`BoxFit.contain` image; and PDF ribbon output is the normalized value only,
without the literal `TEKST TRAKE`. `P2-VIS-006` structure and tuple mapping
remain preserved. Current evidence is in
`REVIEW_EVIDENCE/P2_VIS_007_DECORATION_REMOVAL_EVIDENCE.md`; final GUI identity
and acceptance are recorded in
`REVIEW_EVIDENCE/NALOG_CVECARI_FINAL_DOCUMENTATION_AND_EVIDENCE_CLOSURE.md`.

## Final NALOG CVEĆARI closure — 2026-09-05

The accepted final GUI artifact is
`C:\Users\Steva\Downloads\KORICE\PREDMET_PROBNI_040926_2318_NALOG_CVECARI_v1.pdf`,
SHA-256
`6257C3BB1E082EFA7CE043DED059753D5DD0725F8E8D0EF61D00250E3795551A`,
two pages. The later two-page export is the same PREDMET context after
additional CVEĆE items were added; the earlier one-page export is historical.
`NALOG CVEĆARI CLOSED — BROADER PHASE 2 OWNER REVIEW STILL PENDING`.
