# OPC PARTE Print-Preparation and Media-Lifecycle Pseudocode

## 1. Contract

```text
DOCUMENT_KIND = IMPLEMENTED_ARCHITECTURE_PSEUDOCODE
IMPLEMENTATION_AUTHORIZATION = OWNER_TASK_OPC_PARTE_PRINT_PREPARATION_IMPLEMENTATION
IMPLEMENTATION_STATUS = ALIGNED_WITH_SOURCE_ON_TASK_BRANCH

MASTER_TRUTH = PREDMET
PARTE_ROLE = DERIVATIVE_PUBLIC_PRINT_PREPARATION
PREVIEW_ROLE = DERIVATIVE
GENERATED_PDF_OR_IMAGE_ROLE = DERIVATIVE_ARTIFACT
EXPORTED_OR_PRINTED_COPY_ROLE = DERIVATIVE_ARTIFACT

FORBID:
  parallel_PREDMET_truth
  silent_personal_value_truncation
  silent_grammar_default
  silent_symbol_substitution
  machine_absolute_path_as_only_media_identity
  deletion_of_user_external_original
  biometric_identification
```

## Runtime-recovery addendum (2026-07-16)

```text
ACCESS
  resolve package/license compatibility diagnostics without mutation
  effective native access = ALL EXISTING FUNCTIONALITY
  then apply role permissions and PREDMET business prerequisites

COMPLETION
  PRIPREMA ZAVRŠENA clears PREDMET blocker
  retain draft + template snapshot + app-owned reproducibility media
  completed preparation -> open / inspect / edit / confirm new preview / re-export
  only explicit OBRIŠI SAČUVANU PRIPREMU removes retained app-owned state/media
  never remove PREDMET, external originals, PDF or DOCX exports

PHYSICAL LAYOUT
  draft owns page width/height + horizontal/vertical margins
  any physical change transforms every block from old usable rectangle to new
  rebuild one shared render plan for preview and PDF
  show usable-area boundary; reject out-of-bound output
  calibration PDF declares millimetres and requires Actual size / 100%

DOCX
  each OPC text block -> independent positioned editable text box
  photo/symbol -> independent page-anchored image
  preserve page/margins/geometry/style as an honest editable approximation

ANDROID OUTPUT
  API 29+ -> MediaStore Downloads/KORICE, no broad permission
  API <= 28 -> request WRITE_EXTERNAL_STORAGE limited to API 28
  denial/direct failure -> ACTION_CREATE_DOCUMENT fallback and retry
  report success only after output stream write completes
```

## 2. Current source truth

```text
CURRENT_PREDMET_INPUTS:
  ime, prezime, srednje
  pol
  datumRodjenja, datumSmrti
  zanimanje, zanimanjeNaParti
  titula, titulaIspred
  cin, cinNaParti, vojniPenzioner
  nadimak, nadimakNaParti, nadimakCrtica
  groblje
  vrstaCeremonije, datumCeremonije, vremeCeremonije
  opelo, opeloMesto, vremeOpela, vremeIspracaja
  simbol, pismo, ozaloseni

CURRENT_ORPHANED_FIELD:
  parteIme = STORED_AND_JSON_TRANSFERRED
  parteIme = NOT_EDITED_OR_CONSUMED_BY_CURRENT_PARTE_COMPOSER

CURRENT_PARTE_OUTPUT:
  inline_text_preview
  LISTA_PDF_page_two_text_panel
  PREDMET_PDF_raw_field_rows

CURRENTLY_ABSENT:
  deceased_photo
  crop_metadata
  real_symbol_rendering_in_PARTE
  template_id_and_version
  standalone_PARTE_PDF_or_image
  PARTE_print_preview
  direct_print_action
  generated_artifact_reference
```

## 3. Proposed future data boundary — owner decision required

```text
FUTURE_PARTE_INPUT_MODEL CANDIDATES:
  authoritative_references_to_existing_PREDMET_facts
  selectedSymbolId
  photoMediaId
  photoMimeType
  normalizedPixelWidth
  normalizedPixelHeight
  photoContentHash
  cropAspectRatio
  cropRectNormalized
  templateId
  templateVersion
  optional_generation_metadata

DO_NOT_DUPLICATE:
  deceased_identity
  death_date
  ceremony_datetime
  cemetery
  opelo_state

DO_NOT_ADD without owner approval:
  sentence_override
  print_status
  finalization_state
  artifact_retention_state
```

## 4. Composition and grammar

```text
FUNCTION composeParte(PREDMET, parte_choices):
  validation = validateAuthoritativeInputs(PREDMET, parte_choices)
  IF validation has blocking_issue:
    RETURN no_final_output + explicit_issues

  IF PREDMET.pol == Z AND owner-approved grammar mapping exists:
    intro = feminine_intro
    deathVerb = feminine_death_verb
  ELSE IF PREDMET.pol == M AND owner-approved grammar mapping exists:
    intro = masculine_intro
    deathVerb = masculine_death_verb
  ELSE:
    RETURN REVIEW_REQUIRED_MISSING_OR_CONFLICTING_GRAMMAR

  displayName = ordered non-empty parts:
    optional title_before
    first_name
    optional middle_name
    optional quoted_nickname_between
    surname
    optional dash_nickname_after
    optional title_after

  IF displayName is empty:
    BLOCK final_generation

  optional profession_line = profession IF explicitly_enabled
  optional rank_line = rank IF explicitly_enabled AND valid_source_condition

  lifeYears = owner-approved policy:
    both years OR one year OR omitted OR blocked
  NEVER invent year

  deathSentence = deathVerb + strictly_valid Serbian death date

  ceremonySentence = derive from current:
    ceremony_type
    strict weekday/date
    normalized time
    reviewed cemetery wording
  INCLUDE "časova" only according to approved public wording

  IF opelo == DA:
    include OPELO sentence from current place/time
    DO_NOT include stale send-off sentence
  ELSE:
    include ISPRAĆAJ only if current send-off data is valid
    DO_NOT include stale OPELO sentence

  mourners = normalized multiline free text
  IF too_long:
    RETURN CONTENT_REVIEW_REQUIRED

  IF pismo == CIRILICA:
    transliterate only according to approved user-review policy
  ELSE IF pismo == LATINICA:
    preserve Latin output
  ELSE:
    RETURN SCRIPT_REVIEW_REQUIRED

  RETURN structured_lines + warnings + provenance_to_PREDMET_fields
```

The future composer should be shared by UI preview and every artifact. Current duplicated UI/LISTA composition must not be extended as two independent authorities.

## 5. Strict date/time fallback

```text
FUNCTION validatePublicDate(raw):
  parsed = strict_parse(raw)
  IF parsed is null:
    RETURN INVALID
  IF reconstructed_date != raw_calendar_components:
    RETURN INVALID
  RETURN parsed

IF death_date missing_or_invalid:
  BLOCK death_sentence_and_final_output according to owner policy

IF ceremony_date_or_time missing_or_invalid:
  DO_NOT generate malformed sentence
  SHOW exact source field blocker

IF ceremony rescheduled:
  invalidate current preview cache
  invalidate generated artifact freshness
  regenerate only from new authoritative PREDMET facts
```

## 6. Symbol catalog

```text
SYMBOL_CATALOG_ENTRY CANDIDATE:
  stableId
  displayLabel
  assetPath
  assetFormat
  assetVersion
  printDimensions
  transparencyMode
  colorMode
  provenance
  licenseNote
  active

ON symbol_selection:
  store stableId on PREDMET
  NEVER derive from sex

IF selectedSymbolId == BEZ_SIMBOLA:
  use explicit no-symbol layout only if owner allows

IF selectedSymbolId missing:
  owner decision: BLOCK OR explicit no-symbol review

IF selectedSymbolId unknown_or_asset_deleted:
  preserve stored ID
  SHOW persistent warning
  BLOCK symbol-dependent final generation
  NEVER substitute default

IF asset fails on one platform:
  preserve PREDMET state
  fail generation safely
```

## 7. Photograph import ownership boundary

```text
EXTERNAL_ORIGINAL.owner = USER_OUTSIDE_OPC
OPC_NORMALIZED_COPY.owner = OPC_APPLICATION
IMPORT_TEMP.owner = OPC_APPLICATION

HARD_RULE:
  NEVER modify_or_delete EXTERNAL_ORIGINAL

ON user_selects_photo:
  read external original only
  validate file bytes and decoded image

  IF unsupported OR corrupt:
    retain existing valid OPC copy
    delete only newly-created OPC temp
    RETURN actionable error

  IF decoded pixel count OR input bytes exceed approved limit:
    fail before unbounded memory/storage use

  apply orientation metadata
  present user-controlled crop
  DO_NOT run face recognition_or_identification

  IF user cancels crop:
    delete OPC temp
    do not change PREDMET

  normalize to approved format, dimensions and quality
  compute effective print DPI

  IF below minimum quality:
    SHOW visible warning
    owner decision: BLOCK OR explicitly_confirmed_override

  write app-owned copy to temporary destination
  verify copy can decode
  atomically persist media identity + crop + PREDMET relation
  atomically publish app-owned copy

  IF persistence fails:
    retain old valid PREDMET media
    delete only new OPC temp/copy
```

## 8. Storage models under owner review

```text
MODEL_A = store_original_inside_OPC
MODEL_B = store_normalized_app_owned_copy
MODEL_C = temporary_only_delete_after_artifact
MODEL_D = retain_until_explicit_user_delete
MODEL_E = hybrid_B_plus_D_plus_optional_finalization

AUDIT_RECOMMENDATION_OWNER_DECISION_REQUIRED = MODEL_E built on MODEL_B

MODEL_C RISK:
  generated_artifact becomes only photo representation
  future edit/regeneration/new template impossible
  missing artifact cannot be rebuilt

NO_MODEL may use external_absolute_path as sole source
```

## 9. Preview and print artifact

```text
FUNCTION preparePreview(PREDMET, media, symbol, template):
  composition = composeParte(...)
  IF blocking_issue:
    show issue list and source navigation
    no final artifact

  render same shared layout model used for PDF
  show photo/symbol/media-state warnings
  show one-page overflow preflight

FUNCTION generatePdf(...):
  require current PREDMET version/snapshot
  require valid composition
  require owner-approved template version
  require available symbol asset OR explicit no-symbol policy
  require valid photo OR explicit no-photo policy

  render to OPC-owned temporary PDF
  embed fonts, photo and symbol
  enforce page size, margins and one-page invariant

  IF any personal value truncated OR ellipsized OR fit-compressed:
    FAIL generation

  verify PDF bytes, page count and embedded media
  atomically publish to KORICE

  IF publish fails:
    keep PREDMET and media unchanged
    remove only OPC temp

  generated PDF remains derivative, never PREDMET truth
```

## 10. Long-content policy

```text
IF name exceeds approved line/size profile:
  SHOW preview warning
  require user review or approved alternate template
  NEVER horizontal_fit_squeeze
  NEVER ellipsis

IF mourners exceeds approved measured area:
  SHOW exact overflow
  allow edit or owner-approved alternate layout
  NEVER truncate

IF title_or_profession overflows:
  allow approved wrap/size profile
  otherwise BLOCK
```

## 11. Photo deletion paths

```text
ON user_requests_delete_app_owned_photo:
  display exact ownership and regeneration consequences
  require explicit confirmation

  IF user declines:
    do nothing

  IF confirmed:
    delete only OPC-owned copy
    atomically update PREDMET media state

  IF file delete fails:
    do not claim deleted
    preserve/reconcile metadata
    show retry/support path

  IF metadata update fails after file deletion:
    set explicit MISSING_MEDIA_REVIEW_REQUIRED
    never point silently to another file

ON optional_auto_delete_after_finalization:
  FORBIDDEN until owner approves policy
  require verified published artifact
  require explicit acceptance of non-regeneration
  target only OPC-owned copy
  never target external original
```

## 12. Missing media and regeneration

```text
IF app_owned_photo missing AND artifact exists:
  artifact may be opened as derivative
  mark regeneration unavailable
  do not claim source is complete

IF artifact missing AND app_owned_photo exists:
  allow regeneration from current PREDMET

IF artifact missing AND app_owned_photo missing:
  require new user-selected photo or explicit no-photo layout

IF symbol asset missing:
  preserve stable ID and require review
```

## 13. JSON and backup

```text
SINGLE_PREDMET_TRANSFER future candidate MUST include atomically:
  PREDMET fields
  PARTE media metadata
  photo bytes_or_portable_sidecar IF regeneration is promised
  crop metadata
  template ID/version

FULL_BACKUP MUST include same recoverable state

FORBID:
  Windows absolute path as portable identity
  Android content URI as portable identity
  missing binary with "photo present" success state

ON import_other_device:
  restore app-owned media to local owned storage
  assign local physical path behind stable media identity
  verify decode/hash

  IF media absent_or_invalid:
    import non-media PREDMET state only according to approved atomicity policy
    mark PHOTO_MISSING_REVIEW_REQUIRED
    never substitute local file by filename guess
```

## 14. Anonymization

```text
CURRENT_ANONYMIZATION:
  keeps names
  keeps mourners
  keeps symbol
  has no photo/artifact rule

FUTURE owner policy MUST decide:
  photo delete_or_retain
  mourners redact_or_retain
  app-owned artifact delete_or_retain
  exported KORICE artifact responsibility
  temp/cache cleanup

ON anonymize:
  execute approved DB + media policy as one recoverable operation

  IF media deletion fails:
    do not claim full anonymization success
    show explicit partial-failure state

  NEVER log personal file path, original filename or photo bytes
```

## 15. Historical package downgrade — SUPERSEDED BY STAGE 1

```text
PAKETI = ABANDONED_AS_NATIVE_PRODUCT_POLICY
CURRENT_PARTE = AVAILABLE_REGARDLESS_OF_RETAINED_PACKAGE_OR_ADDON_DATA
RETAINED_ENTITLEMENT_ARCHITECTURE = COMPATIBILITY_AND_DIAGNOSTICS_ONLY

ON retained_package_or_license_change:
  MUST NOT hide_or_disable PARTE
  MUST NOT mutate PREDMET or technical preparation
  role/business/lifecycle rules remain active

STAGE_2 physical removal:
  separate task after owner runtime validation
```

## 16. Windows and Android parity

```text
SHARED:
  PREDMET fields
  composer/grammar
  validation
  symbol catalog identity
  crop coordinates
  layout model
  PDF bytes
  retention/anonymization/package rules

PLATFORM_DELIVERY_MAY_DIFFER:
  external picker API
  app-owned physical storage
  KORICE path_or_contentUri
  viewer/direct-print availability

ANDROID_NARROW:
  vertical stack
  scroll
  wrapping symbol gallery
  compact actions
  no hidden controls
  no overflow

IF direct_print unavailable:
  save/open PDF
  keep business state unchanged
```

## 17. Output format audit

```text
AUDIT_RECOMMENDATION_OWNER_DECISION_REQUIRED:
  primary artifact = deterministic one-page PDF
  preview = derived from same layout model
  optional image = secondary derivative
  direct print = separate later delivery capability

DO_NOT use DOCX floating-object filling as shared Windows/Android engine
DO_NOT use generated artifact as only authoritative PREDMET state
```

## 18. Safe future sequence

```text
PHASE_1:
  owner decisions
  authoritative data/media/template contracts
  JSON/backup/anonymization/package policy
  shared structured composer

PHASE_2:
  atomic app-owned photo import
  crop/normalize/quality warnings
  symbol catalog and provenance
  explicit deletion states

PHASE_3:
  one approved layout
  font/photo/symbol embedding
  one-page/no-truncation PDF
  stale-artifact invalidation

PHASE_4:
  Windows and Android UI
  narrow Android behavior
  preview/export/open/delete/regenerate

PHASE_5:
  synthetic fidelity tests
  transfer/anonymization/downgrade/restart
  platform parity
  separately authorized printer test
```

## 19. Historical audit stop boundary

The audit stop applied before the owner-authorized implementation task. The
following source-aligned flow supersedes that stop for the implemented scope.

> `SUPERSEDED` POLICY NOTICE: sections 20-27 preserve the first implementation
> checkpoint. Their fixed `224 x 170 mm` page, one `5 mm` margin, completion
> cleanup, and package-entitlement rules were superseded by the Runtime-recovery
> addendum dated 2026-07-16 and `OPC-OD-STAGE1-UNRESTRICTED-PARTE-003`. Current
> implementation authority is user-configurable width/height, separate
> horizontal/vertical margins, retained reopenable/editable/reproducible
> completion state/media, explicit user-only deletion, unrestricted native
> functionality subject to role/business rules, authoritative WYSIWYG PDF, and
> optional editable DOCX. Sections 20-27 remain historical evidence only where
> they conflict and must not drive new implementation.

## 20. Implemented truth and persistence boundary

```text
AUTHORITATIVE_INPUT = PREDMET
AUTHORITATIVE_PARTE_REQUIRED_FACT = PREDMET.partePotrebna

TEMPORARY_PREPARATION:
  one restart-safe row per PREDMET
  technical template snapshot + editable output-only draft
  media keys point only to app-owned normalized copies
  preview/export/completion evidence
  NEVER writes temporary text or layout back to PREDMET

FIRMA_TEMPLATE:
  reusable technical layout/style only
  NEVER case text, photograph, path or personal data

PARTE_IME_FACT_CHECK:
  declaration_and_transfer_confirmed = TRUE
  editing_or_rendering_business_meaning_confirmed = FALSE
  result = FACT_CHECK_INCONCLUSIVE_PRESERVED_NOT_REUSED
```

## 21. Entry, initialization and reconciliation

```text
OPEN_ADVANCED_PARTE(predmet, actor, entitlement):
  REQUIRE predmet.partePotrebna == TRUE
  REQUIRE actor.role IN {ADMINISTRATOR, SAVETNIK}
  REQUIRE entitlement.advancedParte == AVAILABLE

  IF unfinished preparation exists:
    RETURN same preparation

  template = FIRMA default OR immutable built-in fallback
  initial = compose current PREDMET facts into separate editable blocks
  SAVE atomically:
    source fingerprint
    immutable template snapshot
    draft
    grammar-review state
  RETURN preparation

ON_REOPEN:
  restore draft/layout/media/evidence
  do not silently refresh from PREDMET

IF current PREDMET fingerprint differs:
  show source-changed warning
  preserve draft until user explicitly requests rebuild
  explicit rebuild uses the preparation-time template snapshot
```

## 22. Text, grammar, symbols and layout

```text
COMPOSE_INITIAL_TEXT:
  preserve Unicode and mixed scripts
  derive current identity, life/death and ceremony facts
  include OPELO or ISPRACAJ wording and "časova" where applicable
  IF POL == M: use male grammar
  ELSE IF POL == Z: use female grammar
  ELSE: leave affected generated wording for review and block confirmation

SYMBOL_POLICY:
  Standardni simbol iz PARTE kataloga -> resolve one of six embedded assets
  BEZ SIMBOLA -> remove symbol block and recompose available space
  SLOBODAN IZBOR -> require app-owned custom-symbol copy OR explicit no-symbol acknowledgement
  never silently substitute an unknown symbol

LAYOUT_POLICY:
  format = custom 224 x 170 mm landscape
  margin = 5 mm
  clamp drag and precision movement to usable surface
  wrap full text
  reduce font only to configured minimum
  IF content still does not fit: block preview confirmation and PDF
  never clip, truncate or add ellipsis
```

## 23. Media lifecycle

```text
IMPORT_MEDIA(external_original):
  read only; never modify, move or delete original
  reject empty, oversized, corrupt, unsupported or excessive-pixel input
  decode and bake orientation
  resize within safe maximum
  atomically write normalized PNG under app-owned support directory
  store portable owned media key, never external absolute path
  retain old owned copy until replacement reference is durable
  warn and require acknowledgement for low-resolution photograph

REMOVE_MEDIA_MANUALLY:
  clear durable reference
  delete only the referenced app-owned copy

CRASH_OR_RESTART:
  durable row and owned copies remain resumable
```

## 24. One composer for preview and PDF

```text
BUILD_RENDER_PLAN(draft, template_snapshot, owned_media, acknowledgements):
  measure text and produce bounded positioned blocks
  produce warnings, blockers and deterministic fingerprint

UI_PREVIEW = render(BUILD_RENDER_PLAN(...))
PDF_OUTPUT = render_same_plan(BUILD_RENDER_PLAN(...))

CONFIRM_FINAL_PREVIEW only when plan has no blocker
GENERATE_PDF only when current plan fingerprint is confirmed
EXPORT using existing filename/version helper to Downloads/KORICE
record successful filename, location and render fingerprint
```

## 25. Completion, blockers and recovery

```text
WHILE preparation.status == IN_PROGRESS:
  block manual PREDMET close
  block automatic completion
  block anonymization

PRIPREMA_ZAVRSENA:
  REQUIRE confirmed current preview
  REQUIRE successful current PDF export
  mark completion/cleanup pending durably
  delete only app-owned photo/custom-symbol copies
  clear temporary draft/template snapshot/media references
  retain exported PDF
  release PREDMET blocker

IF cleanup fails after completion:
  keep CLEANUP_PENDING evidence
  do not report cleanup success
  allow explicit retry
```

## 26. Templates, roles, entitlement and JSON

```text
ADMINISTRATOR:
  use composer
  create/duplicate/rename/edit/delete/import/export FIRMA templates
  cannot mutate or delete built-in template

SAVETNIK:
  use composer when entitled
  cannot administer templates

ENTITLEMENT:
  POTPUN -> advancedParte available
  SREDNJI + advancedParte add-on -> available
  OSNOVNI or SREDNJI without add-on -> locked
  downgrade -> retain preparation/templates/media; deny mutation
  re-entitlement -> resume same preparation

SINGLE_PREDMET_JSON:
  include only authoritative partePotrebna fact
  exclude preparation, FIRMA templates and media
  legacy missing partePotrebna -> FALSE

FULL_BACKUP_JSON:
  include content-free user FIRMA templates and default identity
  exclude temporary preparation and media
  invalid optional template -> skip and use built-in fallback

DEDICATED_TEMPLATE_TRANSFER:
  versioned content-free JSON
  conflict -> replace, import as copy, or cancel
```

## 27. Platform parity and validation boundary

```text
WINDOWS_AND_ANDROID:
  same database, repository, composer, PDF, policy and lifecycle
  UI adapts width only; narrow screen scrolls and keeps actions reachable

AUTOMATED_ALIGNMENT:
  migration 20 -> 21
  composition/grammar/overflow
  media safety
  template lifecycle and transfer
  JSON boundaries
  PDF/completion evidence
  role/entitlement and blockers

REAL_DEVICE_RUNTIME:
  remains a separate smoke-validation obligation
```
# Current printable-zone and export correction (2026-07-17)

```text
OUTER_PAGE = widthMm × heightMm
PRINTABLE_ZONE = (xMm, yMm, widthMm, heightMm)
SAFE_RECT = PRINTABLE_ZONE inset(horizontalSafeMarginMm, verticalSafeMarginMm)

VALIDATE:
  printable zone is positive and wholly inside outer page
  safe margins leave a positive safe rectangle
  every block rectangle is wholly inside SAFE_RECT

COMPOSE:
  retain absolute millimetre block coordinates
  fit text once, with the selected embedded font
  create one immutable render plan and fingerprint

PREVIEW and PDF:
  use page origin (0, 0), scale millimetres only at the adapter boundary
  consume identical block rectangles; never implicitly center or globally shrink

CALIBRATION:
  draw outer border, zone border, safe border and known measure
  print X/Y and require Actual size / 100%; warn against Fit/Shrink

LEGACY schema 1..3:
  zone = (0, 0, legacyPageWidth, legacyPageHeight)
  preserve block coordinates and legacy safe margins

DOCX:
  use page-relative independent shapes
  text = editable VML rect/textbox; media = valid DrawingML anchor
  keep PDF authoritative; require real Word open/save/reopen acceptance

UI:
  label preview PREGLED PRIPREME
  use en dash for life years
  text and format ExpansionTiles alter UI state only
  designer remains outside both collapsible sections
```

# Historical runtime-corrected PARTE workflow (2026-07-12) — `SUPERSEDED` in format/margins/retention

This chronological checkpoint predates the 2026-07-16 Runtime-recovery
addendum. Its one `5 mm` margin and any completed-preparation dead-end are not
current authority; use the addendum at the top of this document.

```text
PREDMET PARTE segment
  owns only authoritative business inputs
  saves required flag, script, symbol, title/occupation, name modifiers,
  mourners and ceremony grammar inputs

MODUL PARTE
  require PARTE entitlement and permitted user
  list PREDMET where status == OTVOREN and partePotrebna == true
  select one PREDMET
  recheck eligibility
  create or resume one temporary preparation

INITIAL COMPOSITION
  read PREDMET snapshot
  generate every initial/copied text block in selected LATINICA/ĆIRILICA
  after initialization preserve manual text exactly, including deliberate mixed script
  use built-in reference layout: photo upper-right, symbol above the name,
  intro/name central, mourners low

COMPOSER
  tap/click preview element -> select it (editor-only outline)
  drag within 5 mm usable margin
  resize photo/symbol with aspect ratio locked by default
  text block -> left/center/right, embedded font, size, bold
  deceased name -> one line; keep size, then horizontal compression;
  unsafe result -> actionable blocker, never silent wrap/truncation
  photo -> non-destructive brightness/contrast/sharpness/grayscale/shape/border
  save only technical temporary draft

RESET
  explicit confirmation
  delete app-owned temporary media and unfinished preparation
  never delete external originals, PREDMET or exported KORICE files
  initialize a fresh preparation from current PREDMET and active template

ŠABLONI PARTE
  show one immutable built-in standard plus contextual custom templates
  apply selected layout to current draft
  save current layout as new; custom only: save changes, rename, export, delete

OUTPUT
  confirm current render-plan preview
  PDF -> authoritative deterministic WYSIWYG KORICE output and completion evidence
  DOCX -> optional local editable derivative; approximate Word flow; never completion evidence
  complete only after current confirmed preview and successful current PDF export

RUNTIME GATE
  Windows owner acceptance first
  Android shared-flow acceptance only after Windows PASS
```
