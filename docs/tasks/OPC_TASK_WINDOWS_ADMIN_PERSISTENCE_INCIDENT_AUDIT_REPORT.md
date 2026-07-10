# OPC Task — Windows Administrator Persistence Incident Audit Only

## Task identity

- Branch: `task/OPC-WINDOWS-ADMIN-PERSISTENCE-INCIDENT-AUDIT`
- Base commit: `701477f3abca57effee9ceb0bab006afa25ee6cf`
- Base branch context: `task/OPC-PRESENTATION-POTPUN-BUILD-NO-DEMO-LICENSE-BLOCK`
- Final commit: final commit containing this report; exact SHA is reported in final handoff after push verification
- GitHub branch URL: `https://github.com/Tale74/OPC/tree/task/OPC-WINDOWS-ADMIN-PERSISTENCE-INCIDENT-AUDIT`
- GitHub commit URL: exact final commit URL is reported in final handoff after push verification
- GitHub report URL: `https://github.com/Tale74/OPC/blob/task/OPC-WINDOWS-ADMIN-PERSISTENCE-INCIDENT-AUDIT/docs/tasks/OPC_TASK_WINDOWS_ADMIN_PERSISTENCE_INCIDENT_AUDIT_REPORT.md`
- Task scope: audit-only; no correction, no recovery, no production source behavior change.

## Reported incident

Client-reported Windows runtime symptom:

- client originally entered or used Administrator data;
- after close/reopen, PIN screen displayed `TEST (ADMINISTRATOR)`;
- adviser/user-selection screen displayed only `TEST`;
- expected Administrator was not selectable;
- `Zaboravljen PIN` action was visible;
- application was effectively unusable for the client.

Screenshot evidence proves only the visible symptom. It does not prove deletion,
database corruption, opened database identity, migration failure, licensing cause,
or data-level recovery impossibility.

## Confirmed affected build provenance

The affected client build must be treated as the presentation POTPUN build:

- commit: `701477f3abca57effee9ceb0bab006afa25ee6cf`
- build flag: `--dart-define=OPC_PRESENTATION_POTPUN=true`

Audit rule: do not assume presentation mode caused the incident. Normal-build-only
reproduction is insufficient; presentation-mode startup must be checked first.

## OPC MANIFEST CHECK — TASK START

Manifest read: yes

Task class: audit / documentation / characterization test

Core purpose preserved: yes

PREDMET meaning affected: no

Database ownership affected: audit only. No database ownership behavior was changed.

JSON transfer affected: no

Windows/Android parity affected: audit only. Incident is Windows-reported, but no platform behavior was changed.

Future OPC Web affected: no

Terminology drift risk: no

Identity impact: audit of local users/auth identity only

Database impact: read/characterization only; no schema or production DB mutation

Licensing separation impact: audit verifies presentation entitlement separation from identity persistence

Implementation allowed: AUDIT ONLY — NO CORRECTION

Required gate before implementation: data ownership / identity / security / payment-access separation

## Evidence preservation instructions

Evidence needed from the affected installation must be copied, not moved.

Do not:

- delete files;
- reinstall;
- overwrite the installation;
- create a new Administrator;
- reset PINs;
- remove TEST;
- open or modify the live client database;
- expose personal data in Git, reports, screenshots, or prompts.

Expected evidence locations/classes:

- SQLite database: platform app documents directory resolved by `getApplicationDocumentsDirectory()`, active release lane expected as `opc_v4_release.sqlite`.
- SQLite sidecar files: `opc_v4_release.sqlite-wal`, `opc_v4_release.sqlite-shm`, `opc_v4_release.sqlite-journal` if present.
- Alternate database lanes: `opc_v4_windows_test.sqlite`, `opc_v4_android_test.sqlite` and sidecars if present.
- Application settings/auth state: inside the SQLite file, including `korisnici`, `security_settings`, and `auth_audit_log`.
- Selected-user state: no persistent selected-user source found; current login selection is in-memory UI state.
- Local-license/bootstrap state: local license file managed by `OpcLocalLicenseRepository`; diagnostics should be copied only if non-secret and sanitized.
- Logs: any local app, Windows Event Viewer, crash, or support logs if they exist; no client personal data should be committed.
- Executable/build provenance: release folder containing `OPC.exe`, `data/flutter_assets`, and build delivery metadata such as local `BUILD_README.txt` if present.
- Version/build metadata visible in app: `kAppVerzija = 4.0.0`, `BUILD_VARIANT`, active database lane diagnostics if the app can be opened safely on a copied environment.

## Source-learning paths inspected

Source:

- `lib/main.dart`
- `lib/app.dart`
- `lib/core/config/app_config.dart`
- `lib/core/database/database.dart`
- `lib/core/database/database_lane_diagnostics.dart`
- `lib/core/database/tables/korisnici_table.dart`
- `lib/core/entitlements/opc_runtime_entitlement_resolver.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/data/auth_security_repository.dart`
- `lib/features/auth/domain/session_service.dart`
- `lib/features/auth/presentation/first_launch_screen.dart`
- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/auth/presentation/forgot_pin_recovery_dialog.dart`
- `lib/features/auth/presentation/korisnici_screen.dart`
- Windows runner/build configuration under `windows/`

Tests:

- `test/login_screen_smoke_test.dart`
- `test/podesavanja_screen_smoke_test.dart`
- `test/presentation_potpun_entitlement_test.dart`
- auth/user usages in `test/stanje_robe_operational_toggle_test.dart`
- `test/windows_admin_persistence_incident_audit_test.dart` added as audit-only characterization

Docs/local docs:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md`
- `PROJECT_DOCS`
- `RESTORE_POINTS`
- `BACKUPS` search paths

## Local documentation findings

- `PROJECT_DOCS\OPC_v1_ZAKLJUCANA_PRAVILA.md` contains relevant auth/recovery decisions: service recovery is local-first, does not create/delete/recreate users, no universal hardcoded production PIN exists, and existing installations without recovery material are not blocked for normal work. Classification: historical but aligned with current source.
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1.json` classifies Auth / Users / Roles / Recovery as implemented foundation with audit/support workflow remaining future. Classification: already migrated/supporting context.
- Local architecture decision docs confirm entitlement/demo/test separation from business/database truth and production fail-closed licensing. Classification: aligned with current source and Git-tracked pseudocode.
- No local documentation found authorizes production bootstrap creation of a `TEST` Administrator. Classification: no conflicting local authority found.

## Source audit findings

### Administrator storage

- Administrator records are stored in `korisnici`.
- Columns are `id`, `imePrezime`, `uloga`, `pinHash`, `aktivan`, `datumKreiranja`; migration/open guards add PIN security metadata columns.
- `AuthRepository.kreirajPrvogAdmina` inserts an `ADMINISTRATOR` row and stores the hashed PIN in the same table.
- Roles are persisted in `korisnici.uloga`.
- Visibility in login uses `sviKorisnici(samoAktivni: true)`, so inactive users are omitted.

### TEST behavior

- No production source path was found that seeds a `TEST` user.
- `TEST`, `Test Administrator`, and `Test Savetnik` appear in tests and test/demo terminology, not as production user bootstrap.
- Database `onCreate` seeds catalog/templates/singletons/security settings, but not `korisnici`.

### Windows database path

- Database name comes from `kDatabaseName` in `app_config.dart`.
- With absent/unknown `BUILD_VARIANT`, database name is `opc_v4_release`.
- `BUILD_VARIANT=WINDOWS` also uses `opc_v4_release`.
- `BUILD_VARIANT=WINDOWS_TEST` uses `opc_v4_windows_test`.
- Database open is `driftDatabase(name: kDatabaseName)`, which uses platform application documents storage through Drift/Flutter path-provider integration.
- Presentation flag `OPC_PRESENTATION_POTPUN=true` does not set `BUILD_VARIANT` and does not change `kDatabaseName`.
- A missing database can silently create a new empty database; this would route to FirstLaunch if there are no active users, unless that new/other database already contains TEST.

### Startup/bootstrap

- `main.dart` creates `AppDatabase()` before `OpcApp`.
- `OpcApp.initState` creates auth/settings/predmet repositories against that same database and resolves entitlement.
- `StartRouter` waits for entitlement, then checks session, then `authRepo.hasKorisnika()`.
- If there are no active users, app shows `FirstLaunchScreen`.
- If active users exist, app shows `LoginScreen`.
- No source path found where entitlement selects a user, seeds a user, deletes a user, or changes database name.

### Identity selection

- Session is in-memory only via `SessionService`.
- No persistent last-selected-user state was found.
- `Promeni savetnika` clears only local `_selektovan` UI state and returns to the active-user list already loaded by login.
- Login list is active users sorted by `imePrezime`; no role/package/license filter found.

### Forgotten PIN / recovery

- `Zaboravljen PIN` opens `ForgotPinRecoveryDialog`.
- Dialog loads `hasRecoveryCode` and `aktivniAdministratori()` independently of current selected user.
- Recovery can reset an existing active Administrator when installation-level recovery material exists and the security code is valid.
- If recovery material is not configured, UI reports recovery unavailable.
- Recovery cannot recover an Administrator that is absent from the opened database or inactive.

### Build provenance / presentation mode

- `OpcRuntimeEntitlementResolver` bypasses local-license bootstrap only when `presentationPotpunRequested` is true.
- Presentation mode returns `presentationOwner` / POTPUN entitlement.
- The resolver has no `AppDatabase` dependency and no auth repository dependency.
- Existing and new tests prove presentation resolver does not require license bootstrap and does not mutate audit test user rows.

## Audit-only characterization test

Added:

- `test/windows_admin_persistence_incident_audit_test.dart`

What it does:

- uses a temporary file-backed SQLite database;
- creates real synthetic `AUDIT ADMINISTRATOR`, not `TEST`;
- closes and reopens the database three times;
- verifies the Administrator row remains active and login works;
- verifies no `TEST` user is created by database open;
- verifies presentation resolver does not mutate user rows.

What it does not do:

- it does not use client data;
- it does not run the GUI Windows release executable;
- it does not prove what happened on the client machine;
- it does not correct behavior.

## Controlled reproduction result

Controlled source-level reproduction did not reproduce the reported symptom.

Focused normal command:

```powershell
flutter test test\windows_admin_persistence_incident_audit_test.dart
```

Result: PASS, 2 tests.

Focused presentation-mode command:

```powershell
flutter test --dart-define=OPC_PRESENTATION_POTPUN=true test\windows_admin_persistence_incident_audit_test.dart
```

Result: PASS, 2 tests.

Runtime limitation:

- Full GUI Windows release close/reopen reproduction from the delivered executable was not performed in this audit turn.
- Therefore client build/data-path evidence remains required before any root-cause claim.

## Hypothesis matrix

| Hypothesis | Source evidence | Test evidence | Runtime/client evidence needed | Status |
|---|---|---|---|---|
| Administrator row was deleted | No source path found that deletes last active Administrator during startup; destructive auth operations are explicit | Not reproduced in file-backed reopen test | Copied affected SQLite `korisnici` rows and audit log | UNRESOLVED |
| Administrator exists but is filtered/hidden | Login filters only `aktivan = true`; recovery filters active administrators | Tests show active admin visible/persistent | Check `aktivan`, `uloga`, and login list in copied DB | UNRESOLVED |
| Application opened another database | Multiple lanes exist; missing DB can create a fresh lane | Not reproduced in controlled same-path file DB | Actual resolved documents path and all `opc_v4*.sqlite*` files | SUPPORTED |
| Database path changed after restart | Source path is platform documents + DB name, not exe folder; Windows profile/context may matter | Same file path persists | Client shortcut/user/profile/path evidence | UNRESOLVED |
| Release folder or shortcut changed execution context | Source DB path should not depend on exe folder directly | Not tested with GUI shortcut | Shortcut properties, working directory, copied release folder behavior | UNRESOLVED |
| Windows user profile changed | Path-provider documents dir is user-profile dependent | Not tested | Windows username/profile and documents path | UNRESOLVED |
| Missing database caused silent new DB creation | Drift create path would create schema on missing DB | Test confirms new DB starts with no users, not TEST | Whether expected DB file was absent and another DB had TEST | SUPPORTED |
| Migration/bootstrap created TEST | No source seed for TEST user found | Audit test confirms DB open does not create TEST | Affected DB rows showing TEST provenance unknown | CONTRADICTED |
| TEST existed already and became selected/only user | Login displays active users from DB; if only TEST active, UI matches report | Tests can display created test users | Copied DB user rows | SUPPORTED |
| Last-selected-user state was lost | No persistent last-selected-user state found | Not applicable | None unless external state exists outside source | CONTRADICTED |
| Adviser-selection query excludes real Administrator | Query lists all active users, not only advisers and not entitlement-filtered | Login smoke shows created user appears | Affected DB active flag/role | UNRESOLVED |
| PIN state was lost but identity row remains | PIN hash stored in same user row; metadata separate | Not reproduced | Copied user row and PIN metadata; no PIN secret in report | UNRESOLVED |
| Forgotten-PIN cannot access non-visible users | It queries active administrators independently; absent/inactive admin is unavailable | Source-level only | Recovery material and administrator rows in copied DB | SUPPORTED for absent/inactive only |
| Release update/copy replaced/bypassed prior data location | DB path should be app documents, but build variant/profile can change lane | Not tested via GUI copied folder | Copied folders, path diagnostics, DB files | UNRESOLVED |
| License/bootstrap failure affected startup routing | Normal license bootstrap affects entitlement only; presentation skips license bootstrap | Presentation resolver test does not mutate rows | Logs/diagnostics if startup failed before auth route | CONTRADICTED for direct user-row mutation; UNRESOLVED for broader startup failure |
| Presentation POTPUN mode affected initialization | Presentation resolver changes entitlement only by source | Existing and audit tests show no DB/user mutation | Exact GUI presentation build runtime evidence | CONTRADICTED at source/test level; UNRESOLVED at client runtime level |
| Client used different build than expected | Reported provenance says affected build is 701477f presentation POTPUN; still needs executable evidence | Not testable | Hash/build README/exe folder evidence | UNRESOLVED |
| Initial Administrator was never persisted successfully | Insert path is immediate; no client proof available | File-backed test persists correctly | Affected DB timeline/audit log/client observation | UNRESOLVED |

## Required audit conclusions

Is Administrator persistence source-covered?

- Partly. Source path for inserting active Administrator and reading active users is clear.

Is Administrator persistence test-covered?

- Now partly covered by audit-only file-backed reopen test.

Is close/reopen persistence reproduced locally?

- Source-level file-backed close/reopen was reproduced successfully without losing Administrator.
- Client symptom was not reproduced.

Is the TEST creation path understood?

- Production source creation path for TEST was not found.
- TEST appears in tests/synthetic data vocabulary.

Can TEST appear in normal production usage?

- Yes if it exists as an active row in the opened database, regardless of how it got there.
- No source evidence shows production startup creates it automatically.

Can multiple databases exist under plausible Windows paths?

- Yes. Release/test lanes can exist in the app documents directory, and different Windows profiles can have different documents directories.

Can copying/moving the release folder change the selected database?

- Source suggests executable folder alone should not change `kDatabaseName`; actual Windows profile/shortcut/path-provider behavior still needs client-side evidence.

Can licensing or presentation mode affect identity data?

- Source/test evidence says presentation mode affects entitlement only and has no direct database/auth dependency.
- Client runtime remains unproven.

Does the real Administrator likely still exist, based on current evidence?

- Unknown. Current evidence cannot distinguish “opened another DB” from “row absent/inactive in the opened DB.”

Is safe client-side evidence collection required?

- Yes. Copy-only database/path/build evidence is required.

Is a correction justified now?

- No. Root cause is not proven.

Is a recovery task justified now?

- Not yet as a corrective implementation. A separate safe evidence/recovery planning task may be justified after copied evidence proves whether the Administrator row exists.

What remains unknown?

- Which SQLite file the affected runtime opened.
- Whether the expected Administrator row exists in any copied DB.
- Whether TEST was manually created, imported, or came from another DB/build.
- Whether recovery material exists.
- Whether the delivered executable/folder exactly matches the reported provenance.

## Validation

Focused audit-only characterization:

- `flutter test test\windows_admin_persistence_incident_audit_test.dart`: PASS, 2 tests.
- `flutter test --dart-define=OPC_PRESENTATION_POTPUN=true test\windows_admin_persistence_incident_audit_test.dart`: PASS, 2 tests.

Required validation:

- `flutter analyze`: PASS, no issues found.
- `flutter test`: PASS, all 126 tests.
- Manifest gate: PASS.

## Changed files

Docs/pseudocode:

- `docs/OPC_WINDOWS_IDENTITY_PERSISTENCE_AUDIT_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/tasks/OPC_TASK_WINDOWS_ADMIN_PERSISTENCE_INCIDENT_AUDIT_REPORT.md`

Audit-only tests:

- `test/windows_admin_persistence_incident_audit_test.dart`

Production source files changed:

- none

Audit-only diagnostic files:

- none beyond the audit-only characterization test.

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

AUDIT PASS — CLIENT INCIDENT NOT LOCALLY REPRODUCED — CLIENT BUILD/DATA-PATH EVIDENCE REQUIRED
