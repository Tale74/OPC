# OPC Task — PARTE Print Preparation Implementation Report

> HISTORICAL IMPLEMENTATION CHECKPOINT — PARTIALLY `SUPERSEDED`. Fixed
> `224 × 170 mm`, one `5 mm` margin, automatic completion cleanup, and completed
> preparation unavailability are not current policy and must not be used as
> implementation authority. They were superseded by
> `OPC-OD-STAGE1-UNRESTRICTED-PARTE-003` and sections 22 onward of
> `OPC_TASK_PARTE_RUNTIME_CORRECTIONS_MODULE_WORKFLOW_COMPOSER_DOCX_REPORT.md`.
> Current preparation dimensions are configurable, margins are separate,
> completed preparation/state/media are retained and reopenable/editable until
> explicit user deletion, PDF remains authoritative, and DOCX is an additional
> editable derivative. This report otherwise remains unchanged audit evidence.

## 1. Task identity

- Task: `OPC-PARTE-PRINT-PREPARATION-IMPLEMENTATION`
- Product: OPC — Organizator pogrebne ceremonije
- Qualified status: `IMPLEMENTATION PASS — RUNTIME VALIDATION PENDING`

## 2. Branch

`task/OPC-PARTE-PRINT-PREPARATION-IMPLEMENTATION`

## 3. Exact base SHA

`36a56d54c98b71bddb29eba83108c6f4a03419ba`

The branch was created directly from the required owner-approved PARTE audit baseline. No unrelated newer branch replaced that baseline.

## 4. Final implementation commit SHA

`2084ba04c90937be15210f71827abee1465ef0b9`

## 5. OPC MANIFEST CHECK — TASK START

Manifest read:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_OWNER_DECISION_GUIDE.md`
- `docs/OPC_OWNER_DECISION_INDEX.md`
- `docs/OPC_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md`
- `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`
- `docs/tasks/OPC_TASK_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- relevant owner-approved local project documentation used only as source-learning evidence

Manifest compliance checked:

- PREDMET remains the sole authoritative business truth.
- PARTE is a derived technical print-preparation module.
- Temporary wording, layout, templates and media do not become PREDMET facts.
- No private example DOCX, real photograph, real client filename, personal data or external local path enters public Git.
- Windows and Android share one OPC business implementation.
- Existing OPC business policy is preserved and extended only inside authorized scope.

PASS / NOT PASS: `PASS`

## 6. Source-learning evidence map

| Source | Responsibility observed | Safe reuse/extension | Risk addressed |
|---|---|---|---|
| `lib/core/database/tables/predmeti_table.dart` / `Predmeti` | Authoritative PREDMET facts and existing PARTE display fields | Added only authoritative `partePotrebna`; retained legacy `parteIme` | Avoided a parallel business model |
| `lib/features/predmeti/presentation/segments/parte_segment.dart` / `ParteSegment` | Existing PARTE decisions and text preview | Preserved fields/terms and replaced visible text-only entry with controlled composer entry | Avoided policy drift and duplicate symbol selection |
| `lib/features/predmeti/data/predmeti_repository.dart` / completion and anonymization methods | PREDMET lifecycle authority | Added repository-level unfinished-preparation blocker | UI bypass cannot close/anonymize incorrectly |
| `lib/core/database/database.dart` / `migration` | Drift schema, migration and singleton conventions | Schema 21 conditionally adds columns/tables | Partial/legacy database upgrade safety |
| `lib/core/utils/json_export_import.dart` | Full backup and restore transaction | Version 7 includes content-free FIRMA templates only | Temporary state/media cannot leak into backup |
| `lib/core/json_transfer/predmet_json_transfer_core.dart` | Single-PREDMET compatibility normalization | Missing `partePotrebna` defaults to `false` | Old JSON remains importable |
| `lib/core/utils/export_utils.dart` | KORICE path, filename/version and snackbar conventions | Reused by PARTE PDF renderer/UI | No competing output convention |
| `lib/features/predmeti/pdf/` | PDF font/image/composition patterns | Reused Noto Sans and physical-unit conventions | Unicode and platform parity |
| `lib/core/entitlements/opc_entitlement_policy.dart` | Package/add-on truth | Reused `advancedParte` | No new licensing truth |
| Existing responsive PREDMET/settings screens | Windows wide and Android narrow patterns | Scrollable narrow composer and wrapped actions | Avoided hidden narrow-screen actions |
| Local owner documentation outside Git | Package/module and PREDMET-authority decisions | Used for learning only; no private content copied | Public-repository hygiene maintained |

## 7. `parteIme` fact-check

Result: `FACT CHECK INCONCLUSIVE — PRESERVED, NOT REUSED`.

The field is declared in PREDMET, persisted, included in snapshot/raw display and transferred through existing JSON paths. Source and Git history did not establish an active editor, rendered PARTE meaning, filename role or completion role. The implementation therefore preserves compatibility and does not bind PDF naming or new workflow behavior to it.

## 8. Implemented architecture

The implemented chain is:

`PREDMET → restart-safe technical PARTE preparation → shared render plan → preview/PDF → user`

Responsibilities are separated into domain models/initial composition, measured composer, preparation repository, FIRMA template repository, owned media store/service, PDF renderer and UI. Preview and PDF consume the same immutable render plan.

## 9. Schema and migrations

- Schema version: `20 → 21`.
- `predmeti.parte_potrebna`: authoritative opt-in fact, default `false`.
- `firma_podaci.parte_default_template_id`: one active FIRMA default, built-in fallback.
- `parte_pripreme`: one restart-safe technical row per PREDMET, with template snapshot, draft, owned media keys and preview/export/completion evidence.
- `parte_predlosci`: FIRMA user technical templates only.
- Migration conditionally checks tables/columns and creates no preparation for old PREDMET rows.
- Targeted file-backed migration test proves an existing PREDMET row survives and both PARTE tables start empty.

## 10. Temporary storage

Preparation state persists across restart but is not business truth. It is created only on an entitled open when `partePotrebna` is true. It retains its template snapshot and does not silently refresh from later PREDMET/default-template changes. Source fingerprint differences produce an explicit rebuild choice.

## 11. Media lifecycle

- External originals are read-only and never moved, modified or deleted.
- Imported photograph/custom symbol is decoded, orientation-normalized, bounded, encoded as PNG and atomically stored under OPC application-support storage.
- Only traversal-safe app-owned media keys are persisted.
- Invalid replacement leaves the previous owned copy and reference usable.
- Low-resolution use requires acknowledgement.
- Completion/manual removal deletes only app-owned copies.

Five owner-supplied project assets were added as sanitized canonical catalog resources; the existing Svetosavski resource was byte-identical to the supplied project copy and was reused. No private source path or filename is stored in source/documentation.

## 12. Templates

The immutable built-in `224 × 170 mm`, landscape, `5 mm` margin template is always available. ADMINISTRATOR can create/duplicate/rename/edit/delete/import/export content-free FIRMA user templates. Built-in mutation/deletion is rejected. Deleting an active user default selects the documented built-in fallback. Import conflicts support replace, import-as-copy and cancel.

## 13. JSON behavior

- Single-PREDMET JSON: includes only authoritative `partePotrebna`; excludes preparation, templates and media; old missing key defaults to `false`.
- Full backup schema 7: includes content-free FIRMA user templates/default identity; excludes preparation/media; old backups remain supported; invalid optional templates are skipped with built-in fallback.
- Dedicated template transfer is schema-versioned, size-bounded, validated and content/path free.

## 14. Composer / WYSIWYG design

Initial blocks derive current identity, grammar, death and ceremony facts, including OPELO/ISPRAĆAJ and `časova`. Unknown gender does not default to male and blocks final confirmation until reviewed. Layout uses measured wrapping, bounded drag/precision movement and configured font reduction. Full text is preserved; unresolved overflow blocks PDF. No silent clipping, ellipsis or truncation is allowed.

Symbol terms are exactly:

- `Standardni simbol iz PARTE kataloga`
- `BEZ SIMBOLA`
- `SLOBODAN IZBOR`

The standard catalog maps six embedded project assets. No-photo/no-symbol choices recompose the plan; free choice without an imported custom symbol requires explicit acknowledgement.

## 15. PDF / output behavior

`PartePdfRenderer` renders the same measured plan used by preview, with Noto Sans Unicode support and physical custom dimensions. Export reuses the existing KORICE path and filename/version helper, using the PREDMET number rather than `parteIme`. Successful export evidence stores the current render fingerprint, filename and location.

## 16. Roles and entitlement

- SAVETNIK and ADMINISTRATOR may use an entitled composer.
- Only ADMINISTRATOR may manage FIRMA templates; checks live below UI.
- POTPUN includes `advancedParte`.
- SREDNJI requires the `advancedParte` add-on.
- OSNOVNI and SREDNJI without add-on are locked.
- Downgrade retains preparation/templates/media and denies mutation; re-entitlement resumes the same state.

## 17. Completion blocker

An `IN_PROGRESS` preparation blocks manual close, automatic completion (including bulk evaluation) and anonymization at repository level. `PRIPREMA ZAVRŠENA` requires the confirmed current preview and successful current PDF export. Cleanup-pending/completed state releases the business blocker while retaining retry evidence.

## 18. Windows / Android parity

Both platforms use the same database, repositories, policy, composer, media lifecycle and PDF renderer. Platform behavior differs only in adaptive presentation and existing output/storage abstraction.

## 19. Narrow UI

The composer scrolls vertically, wraps controls and exposes precision controls alongside bounded drag. The PARTE segment has narrow-layout coverage and no longer exposes the old inline `PREVIEW PARTE` action as the advanced workflow.

## 20. Fallback matrix

| Condition | Implemented fallback |
|---|---|
| Photo/custom-symbol import fails or media is corrupt/unsupported/too large | Reject; keep current draft/reference/previous copy |
| Photo is low resolution | Warn and require acknowledgement |
| No photograph | Require explicit acknowledgement and recompose without photo block |
| Free choice without custom symbol | Block unless explicitly accepted as no symbol |
| Unknown/conflicting gender | Leave affected generated wording for review; block until verified |
| Long name/mourners/content | Wrap and reduce only to minimum; unresolved overflow blocks preview/PDF |
| Drag outside page | Clamp to usable surface |
| PDF generation/export/disk/permission failure | Do not record successful current export or allow completion |
| Crash/restart | Resume durable preparation and owned media |
| Entitlement downgrade | Lock mutation; retain all state; resume after restoration |
| Template conflict | Replace, copy or cancel |
| Missing/invalid default template | Visible technical fallback to immutable built-in |
| Cleanup fails after completion | Persist cleanup-pending state and allow retry; exported PDF remains |
| `parteIme` unclear | Preserve, do not reuse |

## 21. Tests

- `flutter test --no-pub`: `PASS`, 159 tests.
- New coverage: composition/grammar/mixed script/overflow; symbol policy; restart-safe preparation; source change and immutable snapshot; role/package/add-on/downgrade; completion/anonymization blockers; owned media safety; FIRMA template lifecycle/import conflicts; single/full JSON boundaries; PDF/export/completion/cleanup; schema 20 migration; wide/narrow PARTE segment behavior.
- Existing tests were not weakened.

## 22. Builds

- Windows release: `PASS` — `flutter build windows --release --no-pub`; produced `build/windows/x64/runner/Release/OPC.exe`.
- Android APK release: `PASS` — `flutter build apk --release --no-pub`; produced `build/app/outputs/flutter-apk/app-release.apk` (71.1 MB).

## 23. Runtime validation

`RUNTIME VALIDATION PENDING`

Automated/static validation covers the shared business and composition paths. Manual Windows and real/narrow Android smoke still must confirm picker interaction, drag/edit ergonomics, visual preview fidelity, KORICE file visibility, snackbar, interruption/restart and completion/cleanup on actual platform storage.

`flutter devices` found Windows desktop and Edge only; no Android device/emulator was connected. The Windows release executable was not launched against the owner's existing APPDATA because that would not be a clean synthetic runtime and could touch live local state. No runtime PASS is claimed.

## 24. Privacy / public-repository checks

No real DOCX, personal photograph, generated client PDF, private filename, real person name or external local path is included. Tests use synthetic identities/data. Catalog assets are project-owned inputs stored under canonical public-safe names. Final changed/new-source scan found none of the private reference paths/names or `.docx` references. Strict UTF-8 validation found zero invalid files and zero BOM files in new/updated PARTE source, tests and task documentation. `git diff --check` passed.

## 25. Changed-file list

Production changes are scoped to:

- Drift database/tables/generated schema and migration;
- PREDMET/FIRMA fields and JSON compatibility;
- PREDMET lifecycle blocker and PARTE UI integration;
- `lib/features/predmeti/parte/` domain, data, application, PDF and presentation;
- five canonical symbol assets and `image` dependency;
- targeted PARTE/migration tests;
- PARTE pseudocode, Logos index, owner guide/index and this report.

The exact final list is available from the final commit diff.

## 26. Known limitations

- Real-device/runtime smoke is pending.
- Direct printing, image output, cloud sync, unrestricted graphics editing and artifact history are intentionally outside scope.
- `parteIme` remains compatibility-preserved without confirmed business meaning.
- Completion cleanup clears temporary database payload rather than deleting the technical lifecycle evidence row; this preserves retry/audit state without retaining case draft/media.

## 27. Rollback / recovery notes

Schema 21 is additive. Before installing it over production data, retain a normal OPC backup/restore point. Older binaries do not understand the new schema and should not be used as a database downgrade strategy. If media cleanup fails, retry through the persisted cleanup-pending path; never delete external originals or the exported PDF. Built-in template fallback recovers missing/invalid optional user template configuration.

## 28. Pseudocode updates

`docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md` now distinguishes historical audit material and documents implemented initialization, media, shared composer, output, completion, roles, entitlement, JSON and fallback flows. `OPC-PSEUDO-INDEX-049` maps the implementation for Logos.

## 29. Owner guide / index updates

Guide section 8 records the implemented policy lock while preserving audit history. Decision index entry `OPC-OD-PARTE-001` records current implementation with real-device runtime smoke pending.

## 30. GitHub verification

`PASS`

The first finalization push produced matching local/remote branch SHA `e891bbe6df5bf345c63264251553c03365c6aafb`. Read-only public HTTP checks returned `200` for this task report, the shared composer source and a new canonical symbol asset at that commit. The report-verification update is pushed in the subsequent final documentation commit; final remote equality is reported in the task handoff.

## 31. Clean working tree result

`PASS` after the implementation/finalization commits and before this verification-note commit. Final clean/tracking equality is rechecked after its push.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:

- The implementation preserves the PREDMET authority boundary.
- Temporary output state and media remain technical derivatives.
- Role/entitlement checks are below UI.
- JSON, cleanup and repository blockers preserve data/privacy invariants.
- No unrelated business policy or platform fork was introduced.

PASS / NOT PASS: `PASS`
