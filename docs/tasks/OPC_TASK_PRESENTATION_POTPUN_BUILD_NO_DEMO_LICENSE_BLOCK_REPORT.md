# OPC Task — Presentation POTPUN Build Without Demo/License Blocking

## Task identity

- Branch: `task/OPC-PRESENTATION-POTPUN-BUILD-NO-DEMO-LICENSE-BLOCK`
- Base commit: `5793d23607754f453451a068ce91c941d2376139`
- Final commit: final commit containing this report; exact SHA is reported in final handoff after push verification
- GitHub branch URL: `https://github.com/Tale74/OPC/tree/task/OPC-PRESENTATION-POTPUN-BUILD-NO-DEMO-LICENSE-BLOCK`
- GitHub commit URL: exact final commit URL is reported in final handoff after push verification
- GitHub report URL: `https://github.com/Tale74/OPC/blob/task/OPC-PRESENTATION-POTPUN-BUILD-NO-DEMO-LICENSE-BLOCK/docs/tasks/OPC_TASK_PRESENTATION_POTPUN_BUILD_NO_DEMO_LICENSE_BLOCK_REPORT.md`
- Owner urgency context: Tale needs Windows and Android presentation builds for the scheduled presentation, with effective POTPUN package behavior and without demo/license blocking.
- Manual owner context: PDF memorandum/header polish was already accepted as `SOURCE/TEST/BUILD/PUSH PASS — PDF MEMORANDUM IDENTITY ROWS POLISHED — OWNER VISUAL REVIEW PASS`.

## OPC MANIFEST CHECK — TASK START

Manifest read: yes

Task class: implementation / release-support

Core purpose preserved: yes

PREDMET meaning affected: no

Database ownership affected: no

JSON transfer affected: no

Windows/Android parity affected: yes, narrowly. This task produces both Windows and Android presentation builds from the same shared Dart entitlement mechanism.

Future OPC Web affected: no

Terminology drift risk: no. Existing `osnovni`, `srednji`, `potpun`, `PREDMET`, `PODSETNIK`, `STANJE ROBE` terms are preserved.

Package/license impact classification: explicit presentation-only entitlement override; production local-license architecture must remain intact.

Presentation-build classification: owner/internal non-production build mode.

Production-license boundary classification: production default must remain fail-closed/local-license based.

Implementation allowed: yes

Required gate before implementation: payment/legal access gate and platform parity gate, satisfied by documenting and testing that the override is explicit and presentation-only.

## Source-learning paths inspected

### Git-tracked source and tests

- `lib/app.dart`
- `lib/main.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/core/entitlements/opc_local_license_bootstrap_service.dart`
- `lib/core/entitlements/opc_local_license_parser.dart`
- `lib/core/entitlements/opc_local_license_model.dart`
- `lib/core/entitlements/opc_local_license_repository.dart`
- `lib/core/entitlements/opc_license_public_key_registry.dart`
- `lib/features/podesavanja/presentation/podesavanja_screen.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/core/database/tables/app_podesavanja_table.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/stanje_robe/application/stanje_robe_operational_availability.dart`
- `lib/features/stanje_robe/presentation/stanje_robe_admin_screen.dart`
- `test/opc_local_license_parser_test.dart`
- `test/podesavanja_screen_smoke_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/package_downgrade_migration_test.dart`
- Android build files under `android/`
- Windows build files under `windows/`

### Git-tracked documentation

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_PSEUDOCODE.md`
- `docs/OPC_PRE_POINT_4_CORRECTIONS_AUDIT_PSEUDOCODE.md`
- relevant reports under `docs/tasks/`

### Local non-Git documentation folders inspected

- `C:\Projekti\OPC\OPC v.1\PROJECT_DOCS`
- `C:\Projekti\OPC\OPC v.1\RESTORE_POINTS`
- `C:\Projekti\OPC\OPC v.1\BACKUPS`
- `C:\Projekti\OPC\OPC v.1\SMOKE_LOGS`

## Local documentation findings

- `PROJECT_DOCS\PROJECT_MAP_OPC_v1_SUMMARY.md` and `PROJECT_MAP_OPC_v1.json` are historical/supporting continuity maps. They confirm that licensing persistence was a foundation area, package enforcement was incomplete in older maps, STANJE ROBE belongs to POTPUN or SREDNJI add-on, and package/access must not mutate PREDMET truth. Classification: already migrated/superseded by current Git-tracked source and pseudocode where relevant.
- `RESTORE_POINT_20260519_1546_AFTER_TASK_030_ENTITLEMENT_OFFLINE_LICENSE_DECISION_GREEN.md` records the authoritative historical decision that package/add-ons are unlocked by an offline signed local license payload and fail-closed default remains OSNOVNI. Classification: authoritative historical note now represented by current source/tests and useful as source-learning evidence.
- `RESTORE_POINT_20260519_1746...`, `20260519_1835...`, and `20260519_2039...` confirm the local-license skeleton/verifier/bootstrap path and that production/default behavior remains safe OSNOVNI. Classification: historical notes aligned with current source.
- `RESTORE_POINT_20260520...` through `20260527...` confirm STANJE ROBE entitlement/operational-toggle separation and the package/add-on boundary. Classification: historical notes aligned with current Git-tracked source and docs.
- No local document inspected authorizes silently converting normal production builds into unlicensed POTPUN builds. Classification: no conflicting local authority found.

## Diagnosis before implementation

Where is current package state determined?

- Runtime package state is determined in `lib/app.dart` by `OpcLocalLicenseBootstrapService().evaluateInstalledLicense()`, then converted to `OpcEntitlementPolicy.fromPayload(result.payload)`.
- The package/add-on/module rules are centralized in `lib/core/entitlements/opc_entitlement_policy.dart`.
- A compile-time/test/dev selector already exists in `OpcSelectedEntitlementSource`, but the main app bootstrap currently uses installed-license evaluation directly.

What is the current default package?

- The safe default is `OpcPackageLevel.osnovni`.
- Missing, invalid, unreadable, mismatched, or unverified local license evaluation returns `OpcEntitlementPayload.safeProductionFallback`, which is OSNOVNI.

Where is POTPUN recognized?

- `OpcPackageLevel.potpun` exists in `opc_entitlement_policy.dart`.
- POTPUN unlocks package-level modules through `OpcEntitlementPolicy.isModuleAvailable`, including STANJE ROBE and PODSETNIK according to current policy.
- License parser accepts normalized package value `potpun` from a valid signed local license payload.

Where is OSNOVNI recognized?

- `OpcPackageLevel.osnovni` is the fallback/default in the entitlement payload, license parser and bootstrap failure paths.
- OSNOVNI leaves core modules visible but blocks package modules such as PODSETNIK and STANJE ROBE.

Where is SREDNJI recognized?

- `OpcPackageLevel.srednji` is recognized by the entitlement policy and local license parser.
- SREDNJI enables PODSETNIK/nalog cvećari and can enable selected add-ons such as STANJE ROBE by explicit add-on.

Where is license state checked?

- Installed local license state is checked by `OpcLocalLicenseBootstrapService`.
- Parsing and validation are performed by `OpcLocalLicenseParser`, `OpcLicenseSignatureVerifier`, `OpcLicensePublicKeyRegistry`, and the local repository.
- `PODEŠAVANJA -> O APLIKACIJI` separately displays installed local license diagnostics and active runtime entitlement diagnostics.

Where are demo limitations enforced, if present?

- No separate “demo limitation” business subsystem was found.
- `OpcDemoTestEntitlementSource` exists for test/demo simulated entitlements, but production-unsafe demo/developer sources fail closed if marked production.
- Current blocking in normal runtime is license/package gating, not a separate demo timer or record limit.

Does current source already have a test/dev/presentation override?

- It has test/dev flags: `OPC_ENTITLEMENT_SOURCE`, `OPC_ENTITLEMENT_ENVIRONMENT`, `OPC_ENTITLEMENT_DEMO_PACKAGE`, `OPC_ENTITLEMENT_DEMO_ADDONS`, and `OPC_DEVELOPER_ALL_UNLOCKED`.
- It does not have a clearly named owner presentation override.

Does current source use build-time flags, runtime settings, database settings, or hardcoded defaults for package/license?

- Build-time flags exist in `OpcSelectedEntitlementSource`.
- Runtime app startup primarily uses installed local license bootstrap.
- Database settings control STANJE ROBE operational active state, not package entitlement.
- Hardcoded fail-closed default is OSNOVNI.

What is the minimal safe way to produce a POTPUN presentation build?

- Add an explicit build-time flag `OPC_PRESENTATION_POTPUN=true`.
- When set, app startup should resolve the effective entitlement as a named presentation/owner POTPUN entitlement without evaluating mandatory installed local license activation.
- When absent, the current local-license bootstrap and OSNOVNI fail-closed behavior must remain unchanged.

How will this avoid corrupting production licensing architecture?

- The normal build default stays unchanged.
- The presentation mode is opt-in by exact dart-define flag and reports a non-production/test presentation source.
- Local-license parser, repository, bootstrap, production public-key registry and package policy remain intact.
- OSNOVNI/SREDNJI/POTPUN policy remains live and tested.

What source/test/docs files must be changed?

- Source: entitlement policy plus app startup entitlement resolver path.
- Tests: source-level entitlement/resolver tests proving default remains OSNOVNI and presentation mode becomes POTPUN without license bootstrap.
- Docs/pseudocode: add Git-tracked presentation POTPUN build pseudocode and index entry; update this report.

What risks exist?

- If the flag is named unclearly, it can be mistaken for production licensing.
- If the app startup bypass is too broad, future normal builds could become unlicensed POTPUN.
- If the presentation source is treated as demo/test, the owner requirement “no demo limitations” could be ambiguous.
- Build commands must include the dart-define explicitly for both Windows and Android.

What must remain explicitly separate for later real licensing architecture?

- Production key registry and signed customer license issuance.
- Activation/import UX beyond current diagnostics.
- Real payment/subscription/web licensing.
- PODSETNIK entitlement/delivery correction and Android delivery proof.
- Point 4 smoke and broader runtime blockers.

## Implementation log

- Added explicit build-time presentation flag handling through `OPC_PRESENTATION_POTPUN=true`.
- Added `OpcEntitlementSourceKind.presentationOwner`.
- Added `OpcEntitlementPayload.presentationPotpun`, with:
  - source: `presentationOwner`;
  - environment: `test`;
  - package: `potpun`;
  - presentation-safe diagnostics label: `presentation_potpun_owner_build`.
- Added `OpcRuntimeEntitlementResolver`.
  - If presentation flag is enabled, it returns presentation POTPUN entitlement and does not evaluate installed local license bootstrap.
  - If presentation flag is absent/false, it keeps the existing installed local-license bootstrap flow.
- Updated `lib/app.dart` to use the resolver instead of directly calling license bootstrap.
- Updated `PODEŠAVANJA -> O APLIKACIJI` source label for presentation owner mode.
- Added source-level tests for normal/default behavior, presentation behavior, license-bootstrap bypass in presentation mode, and OSNOVNI/SREDNJI/POTPUN policy preservation.
- Added Git-tracked pseudocode for the presentation build mechanism and index entry for Logos.

## Exact source files changed

- `lib/app.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/core/entitlements/opc_runtime_entitlement_resolver.dart`
- `lib/features/podesavanja/presentation/podesavanja_screen.dart`

## Exact test files changed

- `test/presentation_potpun_entitlement_test.dart`

## Exact docs/pseudocode files changed

- `docs/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/tasks/OPC_TASK_PRESENTATION_POTPUN_BUILD_NO_DEMO_LICENSE_BLOCK_REPORT.md`

## Package/license/demo mechanism summary

- Normal startup still uses installed local license evaluation through `OpcLocalLicenseBootstrapService`.
- Missing/invalid/unreadable/unverified license still fails closed to OSNOVNI.
- Existing production key registry, parser, repository, bootstrap service and local license model were not removed.
- No separate demo timer/record-limit subsystem was found or changed.
- Presentation mode is not `demoTest`; it is a named `presentationOwner` source in test/non-production environment.

## Presentation POTPUN mechanism summary

Use this explicit build flag:

```powershell
--dart-define=OPC_PRESENTATION_POTPUN=true
```

With that flag:

- effective runtime package is POTPUN;
- known add-ons are available for the presentation build;
- installed local-license activation is not mandatory;
- diagnostics identify the source as `presentation_potpun_owner_build`;
- normal builds are unaffected.

## Proof that normal package policy was not destroyed

- `test/presentation_potpun_entitlement_test.dart` proves normal selected entitlement remains OSNOVNI when no presentation flag is active.
- The same test proves OSNOVNI, SREDNJI and POTPUN remain distinct:
  - OSNOVNI does not expose PODSETNIK or STANJE ROBE;
  - SREDNJI exposes PODSETNIK but not STANJE ROBE without add-on;
  - POTPUN exposes PODSETNIK and STANJE ROBE.
- Existing package/license tests still pass in the full suite.

## Proof that presentation build evaluates as POTPUN

- Focused test with explicit define passed:

```powershell
flutter test --dart-define=OPC_PRESENTATION_POTPUN=true test\presentation_potpun_entitlement_test.dart
```

- The test verifies that `OpcEntitlementPolicy.current()` follows the compile-time flag and resolves to `presentationOwner` / POTPUN.

## Proof that mandatory license blocker is bypassed only for presentation mode

- `OpcRuntimeEntitlementResolver` test injects a failing license bootstrap callback and verifies it is not called when `presentationPotpunRequested: true`.
- The normal resolver test verifies bootstrap is still called when `presentationPotpunRequested: false`.

## Validation

- Focused normal test:

```powershell
flutter test test\presentation_potpun_entitlement_test.dart
```

Result: PASS, 5 tests.

- Focused presentation-flag test:

```powershell
flutter test --dart-define=OPC_PRESENTATION_POTPUN=true test\presentation_potpun_entitlement_test.dart
```

Result: PASS, 5 tests.

- Analyze:

```powershell
flutter analyze
```

Result: PASS, no issues found.

- Full test:

```powershell
flutter test
```

Result: PASS, all 124 tests.

## Build commands and results

Windows presentation build command:

```powershell
flutter build windows --release --dart-define=OPC_PRESENTATION_POTPUN=true
```

Result: PASS.

Windows build output:

- `C:\Projekti\OPC\OPC v.1\SOURCE\build\windows\x64\runner\Release\OPC.exe`

Android presentation APK build command:

```powershell
flutter build apk --release --dart-define=OPC_PRESENTATION_POTPUN=true
```

Result: PASS.

Android build output:

- `C:\Projekti\OPC\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-release.apk`

## Output artifacts

- Presentation output folder: `C:\Tale\OPC\PREZENTACIJA_POTPUN`
- Windows release folder: `C:\Tale\OPC\PREZENTACIJA_POTPUN\windows_release`
- Windows release ZIP: `C:\Tale\OPC\PREZENTACIJA_POTPUN\opc-presentation-potpun-windows-release.zip`
- Android APK: `C:\Tale\OPC\PREZENTACIJA_POTPUN\opc-presentation-potpun-release.apk`

## Runtime verification

Runtime not performed in this task; builds produced only.

## Post-delivery incident audit note

This section was added after the original presentation build handoff as an
audit-only provenance clarification. It does not change the delivered affected
build identity and does not conclude that presentation mode caused the incident.

### CONFIRMED BUILD PROVENANCE

The affected client build was the OPC presentation POTPUN build created from commit:

`701477f3abca57effee9ceb0bab006afa25ee6cf`

with:

```powershell
--dart-define=OPC_PRESENTATION_POTPUN=true
```

Therefore, the audit must specifically verify whether presentation-mode startup
bypasses, skips, changes, races with, or reorders any of the following:

- local Administrator bootstrap;
- persisted user loading;
- current-user restoration;
- local-license bootstrap;
- database initialization;
- TEST seed/fallback logic;
- login/user-selection routing.

Do not assume presentation mode caused the incident.

However, normal-build-only reproduction is insufficient. Controlled reproduction
must first use the exact presentation POTPUN build mode that was delivered.

### Required controlled reproduction order

1. Build exact presentation POTPUN Windows release from commit `701477f`.
2. Start with clean synthetic data.
3. Create a real synthetic Administrator, not TEST.
4. Close and reopen three times.
5. Verify database path and user rows after every cycle.
6. Test `Promeni savetnika`.
7. Test `Zaboravljen PIN`.
8. Copy/move the release folder and repeat, if database-path logic makes this relevant.
9. Only afterward compare with a normal build from the same commit.

### Central audit question

Does `OPC_PRESENTATION_POTPUN=true` change only entitlement, as this task
claimed, or does the real startup flow indirectly change bootstrap/identity
behavior?

Incident status remains audit-only. There is not yet proof that presentation
mode caused the incident, nor proof that Administrator data was deleted.

## GitHub completion verification

- GitHub branch visibility: PASS
- GitHub report visibility: PASS
- Local and remote branch SHA equality: PASS after final push verification
- Exact final SHA is reported in final handoff because the commit hash cannot be self-embedded in the report without changing itself.

## Known unresolved blockers after this task

- PODSETNIK app-open dialog entitlement bypass observed in OSNOVNI runtime remains a separate task.
- PODSETNIK Android delivery proof remains incomplete.
- STANJE ROBE runtime proof remains pending unless separately checked.
- Windows slow-exit technical audit remains pending.
- STATISTIKA improvements remain deferred.
- Point 4 smoke remains blocked.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: yes

Core purpose preserved: yes

PREDMET meaning preserved: yes

Database ownership preserved: yes

Windows/Android parity preserved: yes

Existing JSON transfer preserved: yes

Terminology preserved: yes

Future Web Pristup not blocked: yes

Source changes within scope: yes

PASS / NOT PASS: PASS

## Final status

SOURCE/TEST/BUILD PASS — PRESENTATION POTPUN BUILDS READY — POINT 4 SMOKE STILL BLOCKED
