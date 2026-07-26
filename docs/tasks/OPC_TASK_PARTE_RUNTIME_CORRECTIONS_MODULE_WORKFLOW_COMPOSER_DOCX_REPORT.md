# OPC TASK — PARTE RUNTIME CORRECTIONS, MODULE WORKFLOW, COMPOSER UX AND DOCX EXPORT

> Recovery note (2026-07-16): the interrupted narrative in sections 5–18 is retained only as historical audit evidence and is superseded by sections 22 onward. In particular, its claims about settings-owned MODULI, completed preparations being non-editable, one 5 mm margin and sequential DOCX flow are no longer current.

## 1. Task identity

- Task: `OPC-PARTE-RUNTIME-CORRECTIONS-MODULE-WORKFLOW-COMPOSER-DOCX`
- Branch: `task/OPC-PARTE-RUNTIME-CORRECTIONS-MODULE-WORKFLOW-COMPOSER-DOCX`
- Verified base SHA: `8864862e163e0788cbbb70c100b3b27c3047a650`
- Implementation commit: PENDING
- Final branch SHA: PENDING

## 2. Previous runtime status

Windows reached the advanced PARTE composer and produced preview/PDF, but owner acceptance was `NOT PASS`. The shared architecture, script, layout, interaction and template defects in the task were therefore treated as confirmed implementation corrections.

`ANDROID RUNTIME SMOKE NOT CONDUCTED — WINDOWS RUNTIME ACCEPTANCE WAS NOT PASS`

## 3. OPC MANIFEST CHECK — TASK START

- Manifest read: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- Decision sources read: `docs/OPC_OWNER_DECISION_GUIDE.md`, `docs/OPC_OWNER_DECISION_INDEX.md`, `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`, PARTE pseudocode/audit/implementation/runtime-unlock reports and relevant module/output/font/platform sources.
- Manifest compliance checked: PREDMET truth boundary, temporary-preparation boundary, local-first operation, PDF authority, Windows/Android product parity and privacy boundary.
- PASS / NOT PASS: `PASS`

## 4. Source evidence map

| Concern | Evidence / implementation path |
|---|---|
| PREDMET business truth | `lib/features/predmeti/presentation/segments/parte_segment.dart`, `lib/features/predmeti/presentation/predmet_screen.dart` |
| MODULI registration/navigation | `lib/features/podesavanja/presentation/podesavanja_screen.dart` |
| Eligible-PREDMET selection | `lib/features/predmeti/parte/presentation/parte_module_screen.dart` |
| Create/resume/draft/reset | `lib/features/predmeti/parte/data/parte_preparation_repository.dart`, `lib/features/predmeti/parte/application/parte_preparation_service.dart` |
| Initial script composition | `lib/features/predmeti/parte/domain/parte_initial_composer.dart`, `lib/core/format/app_text_format.dart` |
| Geometry/fit/render plan | `lib/features/predmeti/parte/domain/parte_models.dart`, `lib/features/predmeti/parte/domain/parte_composer.dart` |
| Composer interaction | `lib/features/predmeti/parte/presentation/parte_composer_screen.dart` |
| Media/effects lifecycle | `lib/features/predmeti/parte/data/parte_media_store.dart`, `lib/features/predmeti/parte/domain/parte_image_effects.dart` |
| Templates | `lib/features/predmeti/parte/data/parte_template_repository.dart`, `lib/features/predmeti/parte/presentation/parte_template_management_dialog.dart` |
| PDF | `lib/features/predmeti/parte/pdf/parte_pdf_renderer.dart` |
| DOCX | `lib/features/predmeti/parte/docx/parte_docx_exporter.dart` |
| KORICE filenames/save | `lib/core/utils/export_utils.dart` |

Owner-provided local reference documents and symbol media were inspected read-only. No personal content or local source path was copied into Git.

## 5. Architecture and MODUL PARTE flow

The technical composer entry was removed from PREDMET. The PREDMET segment continues to own and save only the PARTE business decision and inputs, and explicitly points the user to MODUL PARTE.

MODULI now contains PARTE behind the existing entitlement/user boundary. `MODUL PARTE` lists only `OTVOREN` PREDMET rows with `partePotrebna == true`, shows preparation progress, rechecks eligibility before opening, and creates/resumes the one temporary preparation. The composer title is `PARTE — IME PREZIME`; PREDMET number is secondary context.

## 6. Terminology and script

The catalog displays the canonical owner labels without technical prefixes: Svetosavski, Običan krst, Katolički, Polumesec, Davidova zvezda, Petokraka, BEZ SIMBOLA and SLOBODAN IZBOR.

Initial composition now normalizes both generated phrases and values copied from PREDMET into the selected LATINICA/ĆIRILICA script. After initialization, manual composer text is persisted verbatim, so deliberate mixed script remains possible. Script changes in PREDMET never silently overwrite a started temporary draft.

## 7. Reference layout and one-line name

The built-in reference layout is landscape `224 × 170 mm`, with 5 mm usable margin, photograph upper-right, symbol above the name, intro/name in the central area and mourners low. All positions remain user-adjustable.

The deceased name uses exactly one render line. The algorithm preserves the selected headline size and progressively applies bounded horizontal compression; it never wraps, truncates or silently changes the text. A result below the safe threshold becomes a visible composition blocker.

## 8. Alignment, fonts, selection, drag and resize

Every text block persists left/center/right alignment, font family, size and bold state. The limited cross-platform catalog currently contains the already embedded Noto Sans family; unknown imported font identifiers fall back deterministically to Noto Sans. No unrestricted system-font dependency was introduced.

Click/tap on text, photo or symbol selects it and shows an editor-only outline. Drag starts from the persisted current rectangle and is constrained only by page bounds and the 5 mm margin. Photo and symbol provide precise width/height controls and aspect ratio is locked by default.

## 9. Photograph adjustments

Brightness, contrast, sharpness, grayscale, border and rectangle/rounded/oval presentation are persisted as technical parameters. The source and external original are never overwritten. Preview and PDF use the same effect function and render plan.

DOCX embeds a normalized PNG derivative. Shape/border fidelity is best-effort in DOCX and does not alter PDF authority.

## 10. Reset preparation

`OBRIŠI PRIPREMU I POČNI PONOVO` requires explicit confirmation. It removes only app-owned temporary media and the unfinished preparation row, then initializes a fresh preparation from current PREDMET and active template. It does not delete PREDMET, external originals or exported KORICE files. Completed preparations remain non-editable.

## 11. Template UX

The title is `ŠABLONI PARTE`. One immutable built-in template is shown. Applying a selected template changes the current technical draft only. Saving the current layout as a new template is a single action; rename/save changes/export/delete are available only for custom templates. Import accepts transfer schema 1 and 2; exports use schema 2.

## 12. PDF result

PDF remains the deterministic WYSIWYG output, uses the shared render plan, requires the current confirmed preview, records successful KORICE evidence and remains mandatory for explicit completion. Selection outlines are UI-only and never exported.

## 13. DOCX architecture and limitations

DOCX is generated locally as a minimal OOXML ZIP with content types, package/document relationships, styles, text and embedded media. It uses the current render-plan content, page dimensions, landscape orientation, 5 mm margins, per-block alignment/size/bold and one-line name compression. It is saved through the cross-platform KORICE document path.

DOCX is intentionally editable and approximate: Word reflow, installed Word fonts, image shape/border fidelity and exact absolute placement may differ from PDF. DOCX is not imported back, is not a source of truth, does not record PDF export evidence, and is never required for completion. A DOCX failure therefore cannot invalidate a successful current PDF path.

Dependency review: `archive 4.0.9` was already transitive and is now direct. Official pub.dev metadata reports current 4.0.9, Windows/Android support and MIT license. `vector_math 2.2.0` is direct because the PDF horizontal-scale transform imports it. No network service is used at runtime.

## 14. Schema, migration and JSON boundaries

Technical draft/template payload schema moves from 1 to 2 for font, horizontal compression, aspect lock, photo adjustments, border and shape. Readers accept schema 1 with safe defaults and schema 2. No Drift table change or database migration is required because these parameters remain inside the already versioned technical JSON payloads.

Single-PREDMET business JSON remains free of temporary preparation and media. Template exports remain content-free and reject unknown structure. Full backup behavior remains governed by the existing technical backup contract.

## 15. Validation

- Formatter: PENDING FINAL
- `flutter analyze`: PENDING FINAL
- Complete `flutter test`: PENDING FINAL
- Migration/schema tests: PENDING FINAL
- JSON tests: PENDING FINAL
- PDF tests: PENDING FINAL
- DOCX structural tests: PENDING FINAL
- Windows development-POTPUN release build: PENDING
- Android development-POTPUN release build: PENDING
- Manifest gate / repository scripts: PENDING FINAL
- `git diff --check`: PENDING FINAL
- Privacy scan: PENDING FINAL

## 16. Runtime results

- Windows owner runtime acceptance: `NOT PASS` (new corrected build still requires owner execution and acceptance).
- Android runtime: `ANDROID RUNTIME SMOKE NOT CONDUCTED — WINDOWS RUNTIME ACCEPTANCE WAS NOT PASS`.
- Android build success, if obtained, will not be presented as runtime validation.

## 17. Changed surface and privacy

Changes are confined to PARTE models/composition/repositories/screens/renderers/tests/docs plus direct dependencies and the generic KORICE derivative filename helper. PREDMET business policy, unrelated modules, production licensing, Web/cloud and external media originals are unchanged.

Privacy check uses synthetic fixtures only. Owner runtime screenshots, real PDF, real photograph, real names, APPDATA and local project media are not committed.

## 18. Known limitations and rollback

- DOCX is an editable approximation, not a pixel-identical replacement for PDF.
- The embedded font catalog is deliberately limited to the existing Noto Sans assets; adding another family requires a separately licensed embedded asset and cross-platform validation.
- Owner Windows interaction acceptance and subsequent Android runtime remain external manual gates.

Rollback is branch-level. Technical JSON readers remain backward compatible with schema 1. Reverting this branch restores the previous PREDMET composer entry and removes DOCX without changing business PREDMET JSON.

## 19. Pseudocode and owner documentation

Updated: PARTE print-preparation pseudocode, LOGOS pseudocode index, module relationship map, owner decision guide and owner decision index. The decisions are recorded as closed, not reopened questions.

## 20. GitHub visibility and working tree

- Push: PENDING
- Public commit visibility: PENDING
- Public report visibility: PENDING
- Local/remote SHA equality: PENDING
- Clean working tree: PENDING

## 21. OPC MANIFEST COMPLIANCE — TASK END

- PREDMET remains the only authoritative business truth: PASS.
- Technical edits remain temporary and do not write back: PASS.
- PDF remains authoritative; DOCX is optional: PASS.
- Windows/Android share one implementation and entitlement policy: PASS.
- No real personal data/runtime media enters Git: PENDING FINAL PRIVACY SCAN.
- Final result: PENDING VALIDATION.

## 22. Interrupted working-tree recovery — authoritative continuation

- Recorded branch: `task/OPC-PARTE-RUNTIME-CORRECTIONS-MODULE-WORKFLOW-COMPOSER-DOCX`.
- Recorded HEAD/base: `8864862e163e0788cbbb70c100b3b27c3047a650`.
- No destructive Git operation, checkout, reset or clean was used.
- Preserved correct work: PARTE truth split, composer seed, repository/model evolution, PDF, image effects, DOCX seed, module list, synthetic tests and task docs.
- Corrected partial/unintegrated work: destructive completion, completed dead end, absolute stale geometry, one fixed margin, hidden font limits, combined mourners block, flat DOCX paragraphs, settings-owned MODULI, package locks and incomplete Android access handling.
- Safe shared helpers were retained. Files marked modified but absent from `git diff --name-status` were working-copy/line-ending metadata only, not classified as functional drift.
- No unrelated source change required destructive separation; stop conditions 1 and 2 were not reached.

## 23. Stage 1 unrestricted native access

`OpcNativeAccessPolicy` is the single effective access boundary:

`owner unrestricted-native policy -> role rules -> business prerequisites -> functionality`

Every existing `OpcModule` and `OpcAddOn` is effectively available on Windows/Android. Package level, enabled-add-on data, license parser/bootstrap, migrations, build defines and diagnostic payloads remain intact for Stage 2 compatibility and are not rewritten to POTPUN. Diagnostics explicitly report the owner policy and the retained compatibility payload. ADMINISTRATOR/SAVETNIK and PREDMET lifecycle/business blockers remain active.

Stage 2 physical package/licensing deletion was not started. OPC Web/cloud/sync was not started.

## 24. MODULI relocation

Operational MODULI is a responsive catalog beside STATISTIKA on the PREDMET overview. It exposes PODSETNIK, PARTE and STANJE ROBE and preserves navigation. The MODULI settings section is no longer visible, so PODEŠAVANJA does not duplicate module launching. STANJE ROBE keeps its independent operational toggle and administrator-only management rule.

## 25. Retained completed preparation

`PRIPREMA ZAVRŠENA` now marks completion directly without deleting draft, template snapshot or app-owned reproducibility media. Completed rows remain listed even if PREDMET later closes or `partePotrebna` changes. They can be opened, edited, preview-confirmed and re-exported. Editing clears revision preview/export evidence but does not recreate the business blocker.

`OBRIŠI SAČUVANU PRIPREMU` identifies PREDMET/deceased, requires confirmation and removes only retained app-owned preparation/media. PREDMET, external originals and exported files remain. The unfinished-only `OBRIŠI PRIPREMU I POČNI NOVU` path stays separate.

## 26. Physical layout, refresh and typography

Draft/template schema 3 owns page width/height plus independent horizontal/vertical margins. Schema 1/2 single-margin data migrates the legacy value to both axes. A physical change maps every block from the old usable rectangle to the new usable rectangle, scales bounded font size and rebuilds the shared plan. Preview draws the usable boundary. Text blocks expose x/y movement, width/height controls, family, numeric size and min/max boundary state. Locked-ratio media exposes UMANJI/POVEĆAJ plus movement, displayed size and template-size reset.

Uvodna fraza, Obaveštenje o smrti, Ceremonija and OPELO/ISPRAĆAJ default to the same 14 pt content size. The legally redistributable embedded font remains Noto Sans with Serbian Latin/Cyrillic support. DOCX requests Noto Sans; external editors may substitute installed fonts, and no proprietary Times New Roman file is redistributed.

Generated name casing handles Serbian components, hyphens, middle components/initials and nicknames without mutating PREDMET. Weekday-after-`u` forms are context-specific: ponedeljak, utorak, sredu, četvrtak, petak, subotu, nedelju. Ožalošćeni heading/content are separate stable blocks.

## 27. PDF and physical print classification

PDF uses the same immutable render plan as preview and declares exact physical page dimensions. A calibration PDF includes page dimensions, usable boundary, a known-size rectangle, 10 mm marks and `Actual size / 100%` instructions with Fit/Shrink warning.

- `PREVIEW LAYOUT`: implementation/test validation performed; owner runtime pending.
- `PDF PHYSICAL PAGE`: source/structural test validation performed; owner measurement pending.
- `PHYSICAL PRINT AT 100%`: **NOT TESTED / NOT PASS** until the owner prints and measures.

No physical-print PASS is claimed.

## 28. DOCX architecture

DOCX is transitional OOXML with one independent positioned editable VML text box (`w:txbxContent`) per OPC text block and page-anchored DrawingML (`wp:anchor`) for symbol/photo. It preserves page size, separate margins, block geometry, alignment, font request, size, bold and one-line name intent. Structural tests reject a flat paragraph-only result. PDF remains authoritative. External-editor open-smoke, page count and manual editability acceptance remain pending before build/runtime continuation.

## 29. Android KORICE access

Flutter tooling resolves compile/target SDK 36. API 29+ uses MediaStore public `Downloads/KORICE` with pending/finalized writes and no broad storage permission. API 28 and lower request only `WRITE_EXTERNAL_STORAGE` limited by `maxSdkVersion=28`. `READ_EXTERNAL_STORAGE` and `MANAGE_EXTERNAL_STORAGE` are absent.

Denied, permanently denied and direct-write failure paths use `ACTION_CREATE_DOCUMENT` as safe fallback. Cancellation/write failure is reported as failure; preparation state remains and retry buttons remain available. PDF and DOCX share this path, return MIME/location metadata and cannot show success without write completion.

## 30. Recovery validation and owner-requested pause

The previous 168-test claim is not reused as final evidence. Validation performed during recovery:

- formatter: PASS for the corrected source/test surface; unrelated pre-existing line-ending-only files remain classified as recovery metadata;
- `flutter analyze`: PASS, `No issues found`;
- focused PARTE/PDF/DOCX/layout/lifecycle/MODULI/STANJE ROBE/entitlement/Android-storage suite: PASS, 75 tests;
- complete test run: the recovery rerun first exposed stale STANJE ROBE settings-navigation/package-lock expectations and then one stale package-downgrade entitlement expectation; each was corrected to the owner unrestricted-native policy;
- final complete test rerun: PASS, 176 tests, `All tests passed!`;
- manifest gate: PASS for this changed report against base `8864862e163e0788cbbb70c100b3b27c3047a650`;
- `git diff --check`: PASS (line-ending conversion notices are warnings, not whitespace errors);
- privacy scan: PASS for changed/untracked task surface; only synthetic fixtures and explanatory words such as `APPDATA` were found, with no local owner path, attachment, credential, real runtime media or binary export;
- Android manifest/storage contract: PASS by static contract test and source inspection; runtime/build proof remains pending;
- Windows build: **NOT STARTED — owner requested pause before build**;
- Android build: **NOT STARTED — owner requested pause before build**.

Windows owner runtime remains `NOT PASS` from the supplied prior evidence. Therefore:

`ANDROID RUNTIME SMOKE NOT CONDUCTED — WINDOWS RUNTIME ACCEPTANCE WAS NOT PASS`

Corrections and pre-build validation are complete. Build/runtime acceptance is deliberately not started, so no build PASS, physical-print PASS or runtime PASS status is claimed at this pause point.

## 31. Accepted pre-build report and final pre-build additions

The owner accepted the section 30 pre-build report and authorized these final
pre-build additions plus continuation to repository-approved builds only after
all gates pass.

### Permanent package-policy decision

- PAKETI are permanently abandoned as native business and production policy.
- Every existing Windows/Android function is available to every native user.
- ADMINISTRATOR/SAVETNIK permissions, PREDMET lifecycle, business prerequisites,
  validation blockers and operational toggles remain active.
- Stage 1 functionally removes package-based restrictions while preserving real
  package/license/add-on payload, parser, bootstrap, build-define and diagnostic
  architecture as non-mutating compatibility/audit evidence.
- Stage 2 physical removal was not started. It is a separate future task only
  after owner runtime validation.
- Historical package matrices and development-POTPUN restoration plans remain
  in the audit trail but are explicitly marked superseded as current policy.
- OPC Web remains future-only and does not condition native Stage 1.

Public authority updates include the manifest, owner decision report/guide/index,
architecture overview, module map, business-rule inventory, critical pseudocode,
Logos index, PARTE/PODSETNIK/STANJE ROBE pseudocode and related active planning
notes. Local `PROJECT_DOCS` master-copy authorities carry the same current-policy
notice; their chronological historical package entries remain unchanged evidence.

### PODSETNIK candidate correction

`PredmetiRepository.getPodsetnikKandidate` now uses canonical PREDMET lifecycle
values. A candidate is exactly `status != ZAVRŠEN AND status != ANONIMIZOVAN`,
ordered by descending `datumKreiranja` and descending id as a deterministic tie
breaker. The selector shows the deceased name without `#<redni_broj>`; an empty
result is safe. Reminder model, configuration persistence, scheduling,
rescheduling and notification delivery were not changed.

### Repeated pre-build validation

- formatter: PASS for the changed Dart/test surface;
- `flutter analyze`: PASS, `No issues found`;
- focused PODSETNIK/reminder/list/entitlement suite: PASS, 27 tests;
- complete `flutter test`: PASS, 179 tests, `All tests passed!`;
- manifest gate: PASS for this report against base `8864862e163e0788cbbb70c100b3b27c3047a650`;
- `git diff --check`: PASS; CRLF conversion notices are not whitespace errors;
- privacy scan: PASS; no owner path, attachment path, credential, secret, real
  personal fixture, runtime screenshot/media, generated PDF/DOCX or build output
  is included in the Git surface;
- six Git-ignored `SOURCE/PROJECT_DOCS` authority copies were synchronized to
  the local master `<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\PROJECT_DOCS`; SHA-256 equality is
  confirmed for every synchronized file;
- Git commit/push/SHA handoff: recorded below after execution;
- no signing, secrets, IDE settings, flavors, machine paths or local build
  configuration were changed by these additions.

Builds remain pending until the final manifest/diff/privacy and GitHub SHA gates
below are PASS. Runtime and physical-print status remain unchanged.

## 32. GitHub handoff and repository-approved release builds

Pre-build implementation/documentation commit:

- branch: `task/OPC-PARTE-RUNTIME-CORRECTIONS-MODULE-WORKFLOW-COMPOSER-DOCX`;
- commit: `c6224e69da8184dfa26dd4ba649449ee384e1946`;
- push: PASS;
- public remote branch visibility: PASS;
- local/remote SHA equality at the build gate: PASS;
- merge to `main`: NOT PERFORMED.

Repository-approved commands were used without new defines, flavors, signing,
IDE settings, secrets or machine-specific configuration:

- `C:\flutter\bin\flutter.bat build windows --release`: PASS; Flutter reported
  `Built build\windows\x64\runner\Release\OPC.exe`. The current compiled Dart
  payload is `data\app.so`, 12,075,952 bytes, SHA-256
  `070BA38F3CA3D711F8652617146AE0E648B39E2E0D185FE2EF563C6A61213DFB`.
- `C:\flutter\bin\flutter.bat build apk --release`: the first identical attempt
  reached the command timeout without a final Flutter result and was not counted
  as PASS. The one project-permitted timeout retry used the unchanged command
  and passed: `Built build\app\outputs\flutter-apk\app-release.apk (66.9MB)`.
  APK size is 70,194,709 bytes; SHA-256 is
  `B284D3389B94170E7BBB09B6891758707FEA5397E6A273ACD0D64ED1FDC81971`.

Build PASS proves artifact creation only. Windows owner runtime, DOCX external
editor acceptance, physical-print measurement and Android runtime remain
unexecuted. Therefore no runtime or physical-print PASS is claimed, and the
runtime sequence remains Windows-owner validation before Android smoke.
