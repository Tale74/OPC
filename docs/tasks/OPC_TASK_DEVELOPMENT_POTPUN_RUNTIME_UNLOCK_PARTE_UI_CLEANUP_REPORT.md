# OPC Task — Development POTPUN Runtime Unlock and PARTE UI Cleanup

## 1. Task identity

`OPC-DEVELOPMENT-POTPUN-RUNTIME-UNLOCK-PARTE-UI-CLEANUP`

Qualified status: `IMPLEMENTATION PASS — RUNTIME VALIDATION PARTIAL — ANDROID RUNTIME VALIDATION PENDING`

## 2. Branch

`task/OPC-DEVELOPMENT-POTPUN-RUNTIME-UNLOCK-PARTE-UI-CLEANUP`

## 3. Exact base SHA

`15511723c3e1781496612c17eabb001243080bc8`

The task continues directly from the final public PARTE implementation branch SHA.

## 4. Final implementation SHA

`5f0a796f14296e654dfab373b0deb44e4580d937`

## 5. Previous PARTE task context

The parent task implemented the complete PARTE preparation workflow and ended as `IMPLEMENTATION PASS — RUNTIME VALIDATION PENDING`. Static analysis, 159 tests and both release builds passed. Windows smoke could not start because the ordinary no-license path safely resolved OSNOVNI and therefore locked `advancedParte`.

## 6. OPC MANIFEST CHECK — TASK START

Manifest read:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_OWNER_DECISION_GUIDE.md`
- `docs/OPC_OWNER_DECISION_INDEX.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`
- `docs/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md`
- `docs/tasks/OPC_TASK_PARTE_PRINT_PREPARATION_IMPLEMENTATION_REPORT.md`
- relevant licensing, runtime resolver and diagnostics source/tests

Manifest compliance checked:

- PREDMET remains the sole authoritative business truth.
- Package policy remains part of OPC business policy.
- Licensing enforcement is suspended only through the explicit native development/runtime-validation build boundary.
- OSNOVNI is not redefined and PARTE receives no special bypass.
- Windows and Android use the same shared resolver.
- PARTE composer, WYSIWYG render plan and PDF behavior remain unchanged.

PASS / NOT PASS: `PASS`

## 7. Source-learning evidence map

| Path / symbol | Responsibility | Discovered cause / correction | Preserved behavior / risk |
|---|---|---|---|
| `lib/main.dart`, Windows/Android runners, `lib/app.dart` / `OpcApp.initState` | Both native targets enter one Flutter bootstrap and resolve one runtime policy | No platform fork; retain shared bootstrap | Prevents Windows-only unlock |
| `lib/core/entitlements/opc_runtime_entitlement_resolver.dart` / `OpcRuntimeEntitlementResolver` | Chooses presentation override or installed-license bootstrap | Centralize temporary development POTPUN before licence evaluation; reject invalid config | No module-level bypass |
| `lib/core/entitlements/opc_entitlement_policy.dart` / build modes, payloads and package policy | Maps package/add-ons to modules | Add explicit validated native-development boundary; feed existing POTPUN payload into unchanged policy | OSNOVNI/SREDNJI/POTPUN semantics remain intact |
| `lib/core/entitlements/opc_local_license_bootstrap_service.dart` | Reads and verifies installed local licence; missing/invalid is fail-closed OSNOVNI | Skip at active-development startup; retain unchanged for final-package mode | No fake licence and no persisted mutation |
| `lib/features/podesavanja/presentation/podesavanja_screen.dart` | Shows installed licence evidence and effective runtime entitlement | Distinguish effective POTPUN development source from inactive stored licence evidence | Production diagnostics remain conditional and truthful |
| `lib/features/predmeti/presentation/segments/parte_segment.dart` | Ordinary PARTE segment UI | Remove only internal render-plan information card and exclusive spacing | Composer/PDF/warnings/actions remain |
| `test/presentation_potpun_entitlement_test.dart` | Package/runtime resolver characterization | Cover default development, final-package restoration, invalid config and platform equality | Prevents regression into OSNOVNI or module bypass |
| `test/podesavanja_screen_smoke_test.dart`, `test/parte_segment_ui_test.dart` | Diagnostics and responsive PARTE UI | Assert truthful conditional label and absent technical card | Covers wide/narrow ordinary UI |

## 8. Root cause of OSNOVNI runtime

The delivered normal release omitted the earlier opt-in `OPC_PRESENTATION_POTPUN=true` define. The shared resolver therefore evaluated the local licence. With no usable installed licence, `OpcLocalLicenseBootstrapResult.missing` returned `safeProductionFallback`, whose effective package is OSNOVNI. Central package policy then correctly locked `advancedParte`. The defect was the build-mode default for the owner-approved development phase, not the entitlement rule.

## 9. Existing presentation/development mechanism findings

The existing presentation override was compile-time, shared Dart code, non-persistent and platform-neutral. It already selected a complete POTPUN payload without writing a licence. It failed only because ordinary development builds had to remember an opt-in flag. The correction consolidates that mechanism rather than creating another licence or a PARTE-specific switch. The legacy presentation flag remains compatible.

## 10. Chosen architecture

`OpcNativeDevelopmentBuildMode` reads validated `OPC_FINAL_PACKAGE_LICENSING` configuration. Default `false` represents the current development phase and selects the existing POTPUN payload. Explicit `true` restores installed-license evaluation. Any other value throws a configuration error before a package is chosen.

The relationship is:

`development build mode → effective POTPUN payload → existing entitlement policy → module access`

## 11. Effective package versus persisted package

Development mode changes only the in-memory effective package. It does not create, update, delete or mask a licence file on disk and does not mutate database state. The diagnostic screen may read stored licence evidence separately. Switching to final-package mode reveals the preserved licence/package result again.

## 12. Windows / Android parity

Windows and Android share `lib/main.dart`, `OpcApp`, `OpcNativeDevelopmentBuildMode`, the runtime resolver and package policy. There is no platform parameter or platform-specific entitlement constant. Only native packaging commands differ.

## 13. APPDATA safety

The development resolver returns before installed-license evaluation and exposes no persistence operation. Existing administrator, FIRMA, PREDMET, PARTE preparation, template and licence data are not reset or rewritten. Runtime against real owner APPDATA is not claimed until safely executed and backed up.

## 14. Diagnostics changes

Development mode displays effective runtime package POTPUN, source `razvojni POTPUN režim`, and explains that local licence evidence is inactive for current rights. Final-package mode retains the original installed-licence labels and status/reason messages. Unknown configuration is an explicit error rather than a misleading OSNOVNI/POTPUN diagnostic.

## 15. PARTE UI cleanup

The sentence `WYSIWYG preview i PARTA PDF koriste isti merljivi render-plan u pripremi za štampu.`, its `_ParteInfoCard` instance and its exclusive preceding spacing are removed. Actionable warnings, controls, preview entry, PDF logic and shared render-plan source are untouched.

## 16. Tests added / changed

- characterization of final-package missing-license OSNOVNI behavior;
- default native-development POTPUN without licence bootstrap;
- `advancedParte` and unrelated modules through ordinary POTPUN policy;
- OSNOVNI/SREDNJI/POTPUN and SREDNJI add-on behavior;
- invalid configuration safe failure;
- platform-neutral resolver equality;
- user/admin persistence non-mutation characterization;
- conditional development/final diagnostics;
- wide/narrow PARTE UI without technical text/icon/container.

## 17. Complete test result

`PASS` — `flutter test --no-pub`: all 165 tests passed.

Additional configuration evidence:

- default development-POTPUN targeted entitlement/diagnostics/PARTE UI suite: PASS;
- `--dart-define=OPC_FINAL_PACKAGE_LICENSING=true` targeted suite: PASS;
- `--dart-define=OPC_FINAL_PACKAGE_LICENSING=unknown` safe-failure suite: PASS;
- `flutter analyze --no-pub`: PASS, no findings.

## 18. Windows build result

Command:

```powershell
flutter build windows --release
```

Result: `PASS` — produced `build/windows/x64/runner/Release/OPC.exe`.

## 19. Android build result

Command:

```powershell
flutter build apk --release
```

Result: `PASS` — produced `build/app/outputs/flutter-apk/app-release.apk` (66.2 MB). Gradle emitted only existing Java 8 source/target deprecation warnings.

## 20. Windows runtime smoke

`RUNTIME VALIDATION PARTIAL`

The release executable remained alive for two controlled 10-second startup/restart cycles and was then stopped. An attempted synthetic APPDATA/LOCALAPPDATA root under ignored `build/runtime_smoke` remained empty, so Windows Known Folder isolation was not proven. Consequently this is startup evidence only: existing owner APPDATA preservation, visible POTPUN diagnostics, MODULI/PARTE navigation, absence of the card in the native window and restart data checks are not claimed as runtime PASS. Automated tests cover those source/UI/persistence boundaries. No licence was fabricated or manually installed.

## 21. Android runtime smoke

`ANDROID RUNTIME VALIDATION PENDING` — `flutter devices` found Windows and Edge only; no Android device/emulator was available.

## 22. Documentation updates

- architecture overview records the temporary native phase and future checkpoint;
- presentation/POTPUN build document records exact current and final-package commands, persisted/effective boundary and invalid-config rule;
- task report records exact source evidence and qualified validation.

## 23. Pseudocode updates

`docs/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md` and `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md` describe persisted licence, effective development package, production restoration, Windows/Android equality and the future licensing checkpoint. PARTE architecture pseudocode was inspected; its shared composer fact remains correct and no longer implies a required technical UI card.

## 24. Owner guide / index updates

Closed decisions `OPC-OD-NATIVE-DEV-POTPUN-001` and `OPC-OD-PARTE-002` record temporary full native development access and removal of internal render-plan explanations from ordinary UI. They explicitly preserve package policy, roles and business blockers.

## 25. Privacy / public-repository verification

`PASS`. No real APPDATA, database, licence, activation code, machine identifier, screenshot, generated PDF, credential or private path is tracked. Tests use synthetic/in-memory evidence; build/runtime outputs remain under ignored `build/`.

## 26. Changed-file list

Scoped to shared entitlement build/resolver policy, diagnostics, one PARTE UI deletion, related tests, owner/architecture/pseudocode documents and this report. Exact final list is obtained from the implementation commit.

## 27. Known limitations

- Development mode intentionally remains the native default until the stated owner checkpoint.
- Real Windows existing-APPDATA and Android device smoke remain separate from build/static evidence until actually run.
- This task does not redesign or finalize licensing.

## 28. Future licensing reintroduction boundary

After standalone Windows and Android are technically complete, and before final OPC Web OS-proof preparation/decision, final licensing must be reconsidered. Verification builds explicitly use:

```powershell
--dart-define=OPC_FINAL_PACKAGE_LICENSING=true
```

That re-enables the preserved local-license/package path without architectural redesign.

## 29. Rollback instructions

Revert the task commits to restore the earlier opt-in presentation behavior and technical PARTE card. Do not delete APPDATA or licence/database files. For future licensing verification, use the explicit final-package define rather than editing stored state.

## 30. GitHub visibility

`PASS` — first finalization push produced matching local/remote SHA `9c8b8a0acce8c94e312962c9924392b9994d8080`; public raw HTTP checks returned 200 for this report and the shared runtime resolver. This verification note is pushed in the subsequent final documentation commit.

## 31. Working tree status

`PASS` before this verification-note commit; final local/remote equality and clean status are rechecked after its push.

## 32. OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:

- Core purpose and PREDMET meaning preserved.
- Database ownership and JSON transfer unchanged.
- Package/licensing architecture preserved behind an explicit mode boundary.
- Windows/Android parity preserved.
- PARTE composer/PDF/business lifecycle unchanged.
- No permanent OSNOVNI expansion or module-specific bypass introduced.

PASS / NOT PASS: `PASS`
