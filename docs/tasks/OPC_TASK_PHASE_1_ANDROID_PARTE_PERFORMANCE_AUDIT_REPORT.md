# OPC task report — Phase 1 Android PARTE performance audit

Status:
`SOURCE ROOT-CAUSE CANDIDATES CONFIRMED — LIVE ANDROID PROFILING PENDING — IMPLEMENTATION NOT STARTED`

Audit date: 2026-07-29

## Git baseline

- Base branch: `task/OPC-PHASE-1-WINDOWS-STARTUP-BASELINE-AUDIT`
- Base SHA: `d9e6ecbf84134124ed5214fdb647f3013f33d5f0`
- Task branch: `task/OPC-PHASE-1-ANDROID-PARTE-PERFORMANCE-AUDIT`
- Scope: source/performance-risk audit and documentation only

The base worktree was clean and the base branch was synchronized with origin
before this task branch was created.

## Protected boundary

- Application source, tests, database, migrations, build configuration and
  runtime behavior were not changed.
- No Flutter analyze/test command was required or run because there was no
  application-code change.
- No build was started.
- No canonical owner database was opened or changed.
- PREDMET remains the sole authoritative business truth.
- PARTE remains a derivative preparation/rendering function.
- Accepted PDF/DOCX formation and visual output were not changed.
- Local `PROJECT_DOCS` were not changed.

## Runtime availability

`flutter devices` exposed Windows and Edge only. No Android device or emulator
was connected, so a live latest-HEAD Android profiler run was not possible in
this audit.

The owner confirmed that an Android device can be made available on request.
It is intentionally not requested until a precise profiler scenario is ready.
This report therefore distinguishes a completed source audit from pending
runtime reproduction and measurement.

## Source evidence

### 1. Module-open N+1 query pattern

`lib/features/predmeti/parte/presentation/parte_module_screen.dart:51`

`_load()` first loads all PREDMET records and then sequentially awaits
`findForPredmet(predmet.id)` for every record. Module-open latency therefore
scales with the number of PREDMET records and round trips instead of using one
batched/joined preparation query.

### 2. Whole viewport rebuild on every pan/zoom update

`lib/features/predmeti/parte/presentation/parte_composer_screen.dart:1800`

`InteractiveViewer.onInteractionUpdate` calls `setState(() {})`. That rebuild
scope includes `PartePlanPreview`, although the transformation controller
already owns the changing transform. This creates an avoidable frame-by-frame
rebuild path during canvas pan and zoom.

### 3. Repeated media I/O and synchronous image processing

`lib/features/predmeti/parte/presentation/parte_composer_screen.dart:2059`

The media branch creates a fresh
`FutureBuilder<Uint8List>(future: mediaStore.read(...))` when its parent
rebuilds. When bytes arrive, it synchronously invokes
`applyParteImageEffects`.

`lib/features/predmeti/parte/domain/parte_image_effects.dart:8`

The effects function uses the image package to decode, adjust/filter and encode
PNG bytes. This is CPU work on the UI isolate and is especially relevant when
the preview is rebuilt repeatedly.

### 4. Persistence and complete plan reload after editor actions

`lib/features/predmeti/parte/presentation/parte_composer_screen.dart:157`

`_reload()` re-queries the preparation and PREDMET, decodes the draft, invokes
`buildPlan`, checks source changes, replaces controllers and performs a broad
state update.

`lib/features/predmeti/parte/presentation/parte_composer_screen.dart:343`

`_modifySelected()` persists the complete changed draft and then awaits
`_reload()`. It is used by position, size, typography and image-effect
controls. The file contains 14 `_reload()` call sites and 22 `setState` call
sites in a 2,024-line, 72,394-byte stateful presentation unit.

`lib/features/predmeti/parte/application/parte_preparation_service.dart:87`

`buildPlan()` checks media existence, reads photo bytes, synchronously decodes
the photo for resolution assessment, re-queries the PREDMET and composes the
render plan. Repeated reloads therefore cross DB, file/media and composition
boundaries.

### 5. Important drag-path distinction

`lib/features/predmeti/parte/presentation/parte_composer_screen.dart:1998`

Block movement during `onPanUpdate` changes only the draggable block's local
offset. The durable update is sent on `onPanEnd`. Therefore block drag is not
confirmed as a per-frame database-write problem. Jank may still occur through
preview/media rebuilding, but the audit must not incorrectly replace the
already accepted drag behavior.

### 6. Current tests are functional, not performance gates

`test/parte_module_screen_test.dart`

Existing focused tests verify narrow layout, block-drag versus viewport-pan
mode, controls and deletion behavior. They do not record `FrameTiming`,
timeline data, missed frames, rebuild/repaint counts or a media-heavy
performance fixture. No current performance regression gate was found.

## Ranked root-cause candidates

1. **Highest:** per-frame viewport `setState` combined with a preview subtree
   that can recreate media reads and synchronously process images.
2. **High:** synchronous media decode/effects and uncached effect result on the
   UI isolate.
3. **Medium-high:** persistence followed by full `buildPlan/_reload` after many
   editor actions.
4. **Medium:** module-open sequential N+1 preparation lookup.
5. **Structural amplifier:** the monolithic presentation unit broadens state,
   controller and rebuild coupling; file size alone is not treated as proof.

## Architecture assessment

The owner hypothesis that complex code contributes to the symptom is supported
by concrete coupling evidence, not merely by line count. The evidence supports:

`RETAIN CURRENT PARTE DOMAIN/OUTPUT + PROGRESSIVELY REFACTOR THE PRESENTATION/RENDER STATE BOUNDARY`

It does not support a PARTE partial rewrite or whole-project rewrite at this
gate. Those options remain closed unless profiling shows that a smaller
boundary correction cannot meet an owner-approved target.

## Future correction boundary — not authorized here

A future technical proposal may compare:

- one batched/joined preparation lookup for module opening;
- a transformation-controller listener or narrowly scoped listenable widget
  for zoom indicators, without rebuilding the complete preview per frame;
- caching media reads and effected image results by media key plus effect
  fingerprint;
- off-UI-isolate image processing where ordering and cancellation are safe;
- isolating editor shell, controls and preview with explicit repaint/rebuild
  boundaries;
- local preview state with controlled commit/debounce only where no accepted
  editor behavior, persistence guarantee or crash-recovery property is lost.

Every option must preserve:

- PREDMET and IRiU authority;
- the existing PARTE preparation lifecycle;
- block-drag and viewport-mode semantics;
- exact PDF/DOCX formation rules and owner-accepted output;
- Windows/Android business-result parity.

## Required targeted Android profiler scenario

Before selecting or accepting a correction, use an owner-provided device and
record:

- exact commit and release/profile build variant;
- Android version and hardware class;
- module-open latency with a representative PREDMET database;
- editor open with no media and with representative photo/symbol media;
- block drag, viewport pan and zoom separately;
- image brightness/contrast/sharpness interaction;
- frame timing, jank/missed frames and timeline evidence;
- narrow and wide orientation/layout;
- repeated runs sufficient to distinguish cold setup from steady state.

If practical, use one weaker and one middle hardware class as required by the
authoritative plan. Numeric acceptance targets are proposed from measured
baseline and approved by the owner; they are not invented in this report.

## Decision and next dependency

- Source audit: complete.
- Live Android reproduction/profiling: pending precise device session.
- Application correction: not authorized and not started.
- Architecture direction: retain current codebase; targeted progressive PARTE
  presentation/render refactor remains the leading option.
- Next plan dependency may proceed to the complete SCENARIO/IRiU audit because
  this source finding does not require immediate code mutation.
- Before any PARTE code change, Codex must stop, notify the owner and continue
  implementation only in a new chat within Projects.

## Documentation updates

- `docs/tasks/OPC_TASK_PHASE_1_ANDROID_PARTE_PERFORMANCE_AUDIT_REPORT.md`
- `docs/OPC_PHASE_1_ARCHITECTURE_DECISION_GATE_EVIDENCE_MATRIX.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`

Final commit SHA and remote synchronization evidence are added during the Git
completion gate.
