# OPC Task — Pre-Implementation Audit Before Point 4 / Smoke

## Identity

- Branch: `task/OPC-PREIMPLEMENTATION-AUDIT-BEFORE-POINT-4-SMOKE`
- Base commit: `1bea4e11335f2dd91302688bbef7f1c571fa056d`
- Final commit: commit containing this report; immutable SHA is recorded after creation in the final handoff.
- GitHub branch: `https://github.com/Tale74/OPC/tree/task/OPC-PREIMPLEMENTATION-AUDIT-BEFORE-POINT-4-SMOKE`
- GitHub commit: `https://github.com/Tale74/OPC/commit/<final-commit-sha>`
- GitHub report: `https://github.com/Tale74/OPC/blob/task/OPC-PREIMPLEMENTATION-AUDIT-BEFORE-POINT-4-SMOKE/docs/tasks/OPC_TASK_PREIMPLEMENTATION_AUDIT_BEFORE_POINT_4_SMOKE_REPORT.md`

## OPC MANIFEST CHECK — TASK START

Manifest read: yes.

- Task class: audit + documentation.
- Core purpose preserved: yes.
- PREDMET impact classification: none; all audited outputs remain derived from PREDMET.
- MODULI/PAKETI impact classification: read-only verification of existing entitlement and operational boundaries.
- PODSETNIK delivery-risk classification: high runtime uncertainty; source exists but device delivery is not test-proven.
- PDF business-logic impact classification: none; audit isolates header presentation only.
- Windows technical-audit classification: runtime profiling required; no speculative source change allowed.
- Database ownership, JSON transfer, platform parity and Future OPC Web: unaffected.
- Implementation allowance: documentation only; A–G functional changes forbidden.
- Required gate: terminology/payment-access/platform boundaries inspected; no implementation gate opened.

## Source-learning scope

Inspected Git paths include the manifest; entitlement policy; settings repository/table/UI; all STANJE ROBE application/data/UI files and tests; PREDMET list/screen/CEREMONIJA; PODSETNIK module surface; reminder model/repository/coordinator/gateway and tests; STATISTIKA UI/snapshot/aggregator and tests; six standard PDF exporters, shared logo helper and PDF reports/pseudocode; `main.dart`, `app.dart`, Windows runner; pseudocode index and relevant prior task reports.

Inspected local non-Git folders: `PROJECT_DOCS`, `RESTORE_POINTS`, `BACKUPS`, and `SMOKE_LOGS` under `C:\Projekti\OPC\OPC v.1`.

### Local documentation findings

| Evidence | Fact | Classification/action |
|---|---|---|
| `OPC_v1_ZAKLJUCANA_PRAVILA.md`, architecture decisions, flow/delta | PREDMET is core; STANJE ROBE/PODSETNIK are operational/package modules; PODSETNIK is Srednji/Potpun | authoritative, already substantially migrated; summarized in new Git pseudocode |
| same documents | STATISTIKA is truth-aware, all-package, one `datumKreiranja` range for all tabs | authoritative and consistent with source; summarized here |
| older notification decision notes | full notification architecture once required a separate decision; some notes call PODSETNIK planned/local in-app UX | historical, partially superseded by current gateway implementation; not copied as current status |
| restore points | historical checkpoints for STATISTIKA, STANJE ROBE and PDF | obsolete as current authority; used only to locate history |
| backup archives | preservation artifacts | not product authority; no extraction required |
| Git runtime report | Windows close completed in 12.8 seconds | already migrated to Git and retained as runtime evidence |

No unreconciled authoritative local fact requires owner review. Official A–H audit knowledge is now Git-tracked.

## A — STANJE ROBE

Source-proven: `OpcModule.stanjeRobe` is Potpun or Srednji with explicit add-on. `AppPodesavanja.stanjeRobeOperativnoOmoguceno` defaults false. Effective status combines entitlement and persisted switch. `_ModuliTab` exposes the switch only to ADMINISTRATOR and shows locked/not-licensed state otherwise.

Test-proven: default OFF, persistence, suppression of effects while OFF, active/disabled ADMIN states, Osnovni locked explanation, SAVETNIK non-control, initialization not enabling the switch, and stock consequence behavior.

Runtime-only unknown: real installed POTPUN entitlement, ADMIN interaction, persisted OFF→ON→OFF presentation and downstream behavior in packaged Windows/Android runtime. No runtime was run here.

## B — PODSETNIK shortcut/navigation

The overflow item is rendered in `lista_predmeta_screen.dart`. `podsetnikShortcutEnabled` requires centralized `OpcModule.podsetnik` entitlement and status other than `ANONIMIZOVAN`. Srednji/Potpun are entitled; Osnovni is not. `_otvoriPodsetnik` now pushes `PodsetnikModuleScreen` with the selected PREDMET and contains no `openCeremony` route.

Tests prove Potpun navigation reaches `MODULI / PODSETNIK`, settings render, the former CEREMONIJA reminder key is absent, Osnovni is disabled, Srednji/Potpun entitlement is true and anonymized PREDMET is disabled. Missing: a direct Srednji widget-route case and native mouse/touch overflow proof. Runtime must verify actual menu enablement and navigation in packaged UI.

## C — PODSETNIK readability

The app-open dialog uses `CeremonyReminderEventList`, which accepts multiple strings. Each row has an explicit key, padding/margin and alternating theme-derived color. A widget test checks two rows have different colors and spacing widgets exist. Therefore the stated readability debt appears already source/test-corrected; only owner runtime visual acceptance remains. Any future narrow polish can stay in `lista_predmeta_screen.dart` and its smoke test without touching model, repository, coordinator or gateway.

## D — PODSETNIK Android delivery model

Persistence lives in `ceremony_reminder_settings` through `CeremonyReminderRepository`: enabled state, selected delivery times and scheduled IDs. `buildCeremonyReminderOccurrences` creates selected-time occurrences 2 days before, 1 day before and on ceremony day, skipping past/after-ceremony times. The coordinator cancels old IDs, schedules replacements and persists new IDs.

`AndroidCeremonyNotificationGateway` is not a stub: it initializes timezone data, requests Android notification permission when asked, and calls `flutter_local_notifications.zonedSchedule` with `inexactAllowWhileIdle`. That API is designed for OS delivery without the app being open. However current automated tests use `_FakeGateway`; they prove schedule contracts and model timing, not Android permission, alarm registration or actual closed-app delivery.

Separately, list startup and every app resume call `_refreshCeremonyRemindersAndDialog`, reschedule records and use `activeCeremonyReminderSlot` to show a due dialog. Thus system scheduling exists, but the visible app-open dialog remains a parallel delivery path. Owner correction requires system notification to be primary and dialog only an explicitly accepted secondary/fallback path. Future likely files: gateway, coordinator/startup orchestration, list dialog path, Android manifest/config if runtime proves needed, and reminder tests. Do not create a second engine.

Required later Android proof: permission denied/granted, selected-time registration, notification with app backgrounded/terminated, 2/1/0-day behavior, reboot/timezone considerations, cancellation/reschedule, multiple times and no duplicate app-open delivery.

## E — STATISTIKA

UI is `izvestaji_screen.dart`; data comes from `StatistikaSnapshotService` and `StatistikaAggregator`. Selecting a preset or custom date calls `setState`, so results recalculate automatically—there is no separate Apply/Show action. One range applies to all five tabs. Current presets are last 7 days, last 30 days, current month, current year and custom.

There is no current/previous-month comparison and no same-month-last-year comparison model or UI. Summary and breakdown cards put several metrics into a card/row, so the requested “one data point per row” needs a precise presentation change. Only compact-filter platform selection has a direct test; comparison ranges, automatic refresh and row structure lack tests. A future task likely touches `izvestaji_screen.dart`, comparison/range models and aggregator/snapshot tests, without changing PREDMET/IRiU truth.

## F — PDF memorandum/header polish

Six exporters—PREDMET, LISTA, NALOG ZA OPREMANJE, PREDRAČUN, RAČUN and SPECIFIKACIJA TROŠKOVA—each build their own complete header; only logo rendering is shared. All currently build PIB, MB and account strings and join them with ` | ` into one identity line. LISTA uses `Racun`; the other five use `Račun` (literal or Unicode escape).

No test directly locks label spelling or structural row separation. Minimal future correction must update the six header identity blocks and add text/structure characterization, while retaining the passed logo maximum-layout, title/date/case-number positions and all document body/business/legal/finance logic. Existing broad PDF review remains PASS and is not reopened.

## G — Windows slow exit

`main.dart` enables prevent-close. `OpcApp.onWindowClose` either pops a nested route or confirms at root, then awaits `windowManager.destroy()`. It performs no explicit database close, PREDMET save, export cleanup, notification cleanup or repository disposal. Native `FlutterWindow::OnDestroy` resets the Flutter controller, then delegates to `Win32Window`; `main.cpp` exits after the Windows message loop and COM teardown. No obvious deliberate 12.8-second wait is present.

Prior Git runtime evidence measured normal close at 12.8 seconds and classified it `TECHNICAL AUDIT REQUIRED`; it did not include phase timing. Later Windows-only work should measure click→dialog, confirmation→destroy return, engine/plugin teardown and process exit; capture CPU/I/O and repeated debug/release timings; then localize database/plugin/window-manager involvement before any code change.

## H — Point 4 / smoke boundary

Prior reports define smoke as deferred and explicitly leave STANJE ROBE/PODSETNIK owner runtime review and slow exit unresolved. A–C can be verified together in a final functional runtime pass after source is stable. D requires a separate Android notification implementation/audit and device proof. E is a separate STATISTIKA implementation. F is a narrow PDF task and representative export review. G is a separate Windows profiling task. Point 4 smoke must not start until these debts are closed or Tale explicitly separates non-blockers.

## Evidence classification

- Source-proven: A entitlement/default/role gates; B route/guards; C row structure; D persistence/model/coordinator/real gateway call; E current filters and absence of comparisons; F six independent joined headers; G shutdown call graph.
- Test-proven: A extensive behavior; B navigation/guards; C alternating rows; D model/coordinator/persistence with fake gateway; E compact Android filter selection only.
- Docs-proven: package/module classification, STATISTIKA one-range truth boundary, PDF six-exporter layout, 12.8-second exit observation and deferred smoke.
- Runtime-only: licensed STANJE ROBE interaction, native overflow/visual readability, Android permission/closed-app delivery, PDF rendered row polish, Windows exit phase timing.
- Owner-decision-required: whether the app-open reminder dialog remains as fallback and which A–G debts Tale explicitly permits outside the Point 4 blocker set. No decision is required to complete this audit.

## Proposed safe implementation sequence

1. STATISTIKA requirements/characterization and implementation as an isolated truth-preserving task.
2. PDF identity rows + `Račun` as a narrow six-exporter task with focused tests/review.
3. PODSETNIK delivery correction/audit, followed by separately authorized Android device proof.
4. Windows exit instrumentation/profiling in its own authorized runtime task before any fix.
5. Consolidated A–C source recheck and packaged runtime verification.
6. Owner gate on remaining blockers, then separately authorized Point 4 smoke.

## Changes and validation

- Production source changed: none.
- Behavioral tests changed/added: none.
- Docs changed: this report, `docs/OPC_PRE_POINT_4_CORRECTIONS_AUDIT_PSEUDOCODE.md`, and `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`.
- `flutter analyze`: PASS, zero findings.
- `flutter test`: PASS, all 117 tests.
- Build/runtime/smoke: not run, as required.
- Manifest gate: PASS against base `1bea4e11335f2dd91302688bbef7f1c571fa056d`.
- GitHub verification: pending commit/push.

Business meaning: the map prevents source confidence from being confused with device/runtime proof and keeps unrelated module, document and platform debts out of a broad refactor.

Risk: D and G cannot be closed from source/tests; E requirements need focused acceptance criteria; F duplicates header composition across six exporters.

Safe boundary: documentation only; no production behavior, test contract, schema, runner, package, PREDMET, JSON, finance, IRiU, PDF or reminder implementation changed.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: yes.

- Core purpose preserved: yes.
- PREDMET meaning preserved: yes.
- Database ownership preserved: yes.
- Windows/Android parity preserved: yes.
- Existing JSON transfer preserved: yes.
- Terminology preserved: yes.
- Future Web Pristup not blocked: yes.
- Source changes within scope: yes, documentation only.
- PASS / NOT PASS: PASS, subject to the mandatory GitHub visibility gate.
