# OPC WEB ACCESS RELEASE-READY FEASIBILITY AND RISK AUDIT

Base inspected: `main` at `80294ea`.

Initial validation:

```text
git status --short --branch
## main...origin/main

git log --oneline -5
80294ea docs: confirm Logos GitHub visibility
f74638d docs: record OPC GitHub push verification
07c61c1 docs: finalize GH-001 local foundation report
520b189 chore: establish OPC public repository baseline
```

Scope: documentation-only senior audit. No source code, migration, web runner, backend, API, sync, storage adapter, package restructuring, or payment/subscription implementation was performed.

## 1. Current repo constraints

Claim: `CONFIRMED IN REPO` OPC is currently a Flutter/Dart local application with Windows and Android runners, not a web/backend product.

Repo evidence: `README.md:3` says the same product is implemented for Windows and Android. `docs/ARCHITECTURE_OVERVIEW.md:8-12` lists Windows and Android runners and `lib/main.dart` as entry point. `Test-Path web` returned `False`; top-level directories are `android`, `windows`, `lib`, `test`, `docs`, assets/build/runtime folders, and no `web` directory.

Technical implication: Web/OS-proof browser access is feasible only as future architecture work. It is not a runner switch in the current repo.

Risk: Treating the repo as already web-ready would hide the need to extract platform-dependent code (`dart:io`, `window_manager`, file picker/export paths) and persistence boundaries.

Recommendation: Keep the release baseline as OPC Windows plus OPC Android with local Drift/SQLite and JSON transfer. Plan OPC Web Pristup as a third runtime form of the same business core, not as a replacement.

Claim: `CONFIRMED IN REPO` Current persistence is Drift over local SQLite, schema version 17.

Repo evidence: `pubspec.yaml:14-16` depends on `drift`, `drift_flutter`, and `sqlite3_flutter_libs`. `lib/core/database/database.dart:53` reports `schemaVersion => 17`; `lib/core/database/database.dart:56-132` contains migration and before-open compatibility logic. `docs/ARCHITECTURE_OVERVIEW.md:29-31` records Drift/SQLite and local runtime database files.

Technical implication: The current source is coupled to a local Drift database and generated Drift code. A browser runtime needs a deliberate storage adapter decision.

Risk: Adding web storage directly under existing UI/repositories would spread platform conditionals across the app.

Recommendation: Extract storage-facing business contracts before any web runner or storage adapter is added.

Claim: `CONFIRMED IN REPO WITH TERMINOLOGY CONTRADICTION` Docs mention a future "web/SaaS" model, but the task baseline says not to use SaaS as the primary future description.

Repo evidence: `README.md:7` and `docs/PRODUCT_DIRECTION.md:13` say "web/SaaS". `lib/features/podesavanja/presentation/podesavanja_screen.dart:1866` maps `OpcEntitlementSourceKind.saas` to label `SaaS`. No backend, tenant, API, hosting, or sync implementation was found.

Technical implication: This is terminology drift, not implemented architecture.

Risk: Keeping "SaaS" as primary language can force cloud tenancy/payment assumptions before the data, privacy, and sync model is decided.

Recommendation: Use `OPC Web Pristup` for planning. If more precision is needed, proposed term only: `PROPOSED TERM - NOT IMPLEMENTED - OWNER DECISION REQUIRED: OPC Web Pristup sopstvenoj bazi / firmnom OPC repozitorijumu`.

## 2. Existing local transfer model: PREDMET JSON and full backup JSON

Claim: `CONFIRMED IN REPO` Single-`PREDMET` JSON transfer is a real contract, not just a UI idea.

Repo evidence: `lib/core/json_transfer/predmet_json_transfer_core.dart:3-10` declares schema constants, `OPC_PREDMET`, max supported schema 7, and the `stanjeRobeConsequenceTransfer` block. `lib/core/utils/json_export_import.dart:397-450` serializes a `Predmet` transfer payload with `format`, `schemaVersion`, `entityType`, `predmet`, `iriu`, `kontaktLica`, and optional consequence transfer. `lib/features/predmeti/presentation/predmet_screen.dart:804-805` wires export from the `PREDMET` screen.

Technical implication: This contract can become the basis for future boundary extraction and validation.

Risk: Calling it an API would be wrong. It is a file transfer/export contract with local conflict handling and UI decisions.

Recommendation: Preserve it for Windows/Android release and extract its pure validation/serialization boundary before any web sync design.

Claim: `CONFIRMED IN REPO` Full database backup JSON is also implemented.

Repo evidence: `lib/core/utils/json_export_import.dart:514-568` serializes backup sections including `korisnici`, `firmaPodaci`, `appPodesavanja`, `predmeti`, `iriu`, `kontaktLica`, `logIzmena`, catalog, templates, and stock tables. `lib/features/podesavanja/presentation/podesavanja_screen.dart:81-86` exposes backup export/import from settings.

Technical implication: Whole-app transfer already has a local JSON mechanism separate from single-`PREDMET` transfer.

Risk: Replacing this with whole-SQLite sync would create cross-platform locking, migration, corruption, and conflict risks.

Recommendation: Keep full backup JSON as the official local database transfer/restore mechanism for Windows/Android.

Claim: `CONFIRMED IN REPO` Regression tests lock important JSON transfer behavior.

Repo evidence: `test/json_transfer_regression_test.dart:17` starts JSON transfer regression coverage. Tests cover locked metadata, import replacement, old JSON import, candidate reserialization, backup compatibility, stock consequence transfer, forbidden fields, invalid indices, and unsupported future schema rejection. `test/json_transfer_regression_test.dart:1213-1219` asserts single-`PREDMET` JSON does not carry stock ownership payloads.

Technical implication: JSON transfer is one of the strongest existing boundaries.

Risk: Web work that bypasses these tests will regress release-critical Windows/Android transfer.

Recommendation: Treat these tests as mandatory guardrails for any future boundary extraction.

## 3. What must remain unchanged for Windows/Android release

Claim: `CONFIRMED IN REPO` Windows and Android are equal versions of the same product.

Repo evidence: `README.md:3` and `docs/PRODUCT_DIRECTION.md:5-10` state no role separation between Windows and Android.

Technical implication: Do not model Windows as admin and Android as field runtime.

Risk: Role-based platform split would corrupt product semantics and permission design.

Recommendation: Keep platform parity. Platform differences may exist only for OS, screen, input, packaging, or APIs.

Claim: `CONFIRMED IN REPO` Local users and PIN roles are local app/session concepts, not network identity.

Repo evidence: `lib/core/database/tables/korisnici_table.dart:1-7` stores local `Korisnici` with `uloga` and `pinHash`; comment says `ADMINISTRATOR / SAVETNIK`. `lib/features/auth/domain/session_service.dart:5-12` keeps an in-memory active user and admin check. `lib/features/auth/data/auth_repository.dart:28-40` hashes PINs locally and verifies against local DB.

Technical implication: Network multi-user auth cannot reuse this as-is.

Risk: Treating local PIN users as web accounts would create broken security, audit, and tenancy assumptions.

Recommendation: Preserve local `ADMINISTRATOR` and `SAVETNIK` meanings for Windows/Android. Define web identity separately later and map roles deliberately.

Claim: `CONFIRMED IN REPO` Local firm configuration is a singleton, not a tenant/organization model.

Repo evidence: `lib/core/database/tables/firma_podaci_table.dart:3-14` is a singleton table, "uvek id = 1". `lib/core/database/database.dart:266-274` seeds singleton `FirmaPodaci` and `AppPodesavanja`.

Technical implication: It cannot be treated as implemented firm membership or multi-tenant ownership.

Risk: Using it as a tenant id would break backups, imports, permissions, and migration assumptions.

Recommendation: Keep it as local firm settings. Any firm repository / organization model is future work and owner decision.

## 4. What must be harmonized across Windows/Android/Web

Claim: `FEASIBLE WITH BOUNDARY EXTRACTION` The business core can be shared if domain rules are separated from Flutter UI and local persistence details.

Repo evidence: Business-ish logic exists under `lib/features/predmeti/core_v2/`, repositories under `lib/features/predmeti/data/`, and UI under `lib/features/predmeti/presentation/`. `docs/ARCHITECTURE_OVERVIEW.md:45` says most domain, persistence, and presentation code lives in the same Flutter package and no shared package/service boundary exists.

Technical implication: Some boundaries already exist by folder, but not enough for a browser/network runtime.

Risk: Reusing current repositories directly in web mode will pull in Drift/local DB assumptions.

Recommendation: Lock a small pure Dart boundary first: `PREDMET` transfer document, business scenario ids, IRIU truth rules, financial truth rules, role vocabulary, status lifecycle, and entitlement policy vocabulary.

Claim: `OWNER DECISION REQUIRED` The product-family language should be OPC Windows, OPC Android, OPC Web Pristup.

Repo evidence: Current docs confirm Windows/Android equality but use "web/SaaS" wording.

Technical implication: Architecture documents should avoid cloud business-model assumptions before implementation.

Risk: Terminology drift can leak into code names, license source enums, and user-facing screens.

Recommendation: Create a follow-up terminology-only doc/code audit before any web implementation. Do not rename business terms inside this task.

## 5. Business/logical rules requiring final decision

Claim: `OWNER DECISION REQUIRED` The following rules must be frozen before parallel release planning: what defines a firm/user in business terms; whether one firm can have one or more logical users; exact mapping of `ADMINISTRATOR` and `SAVETNIK`; whether `naručilac` remains canonical and `klijent` is avoided; `PREDMET` lifecycle statuses; close/reopen/version semantics; GDPR/anonymization timing; inventory consequence ownership; entitlement behavior by `osnovni`, `srednji`, `potpun`; and whether web local copies are allowed to diverge offline.

Repo evidence: `lib/core/database/tables/predmeti_table.dart` defines broad `PREDMET` fields including status, `savetnikId`, `verzija`, source identity, `naru*` fields, and business scenario metadata. `lib/features/predmeti/data/predmeti_repository.dart:177-300` controls close/open/version snapshots and automatic finished status. `lib/features/predmeti/data/predmeti_repository.dart:334-371` performs anonymization. Entitlements are defined in `lib/core/entitlements/opc_entitlement_policy.dart:1-4` and document/module gates around `:459-469`.

Technical implication: Parallel runtimes need identical rule outcomes for the same `PREDMET`.

Risk: If web logic is reimplemented independently, the same case can produce different documents, statuses, stock effects, or entitlement visibility.

Recommendation: Add contract tests around these rules before implementation. Do not start sync or backend first.

## 6. Web runtime feasibility

Claim: `FEASIBLE WITH BOUNDARY EXTRACTION` Flutter Web / browser UI is technically plausible, but not from the current package without serious cleanup.

Repo evidence: `lib/main.dart:1` and `lib/app.dart:1` import `dart:io` `Platform`; `lib/main.dart:5` and `lib/app.dart:4` use `window_manager`; file import/export uses `dart:io`, `file_picker`, `path_provider`, and `share_plus` in `lib/core/utils/json_export_import.dart:1-13`; no `web/` runner exists.

Technical implication: Web runtime requires platform facades for window behavior, local file import/export/share, database opening, and possibly PDF handling.

Risk: Adding web conditionals directly to current files would increase architectural debt.

Recommendation: First extract interfaces for app environment, file transfer, database executor creation, and export/share operations. Then evaluate a browser runner.

Claim: `FEASIBLE WITHOUT LARGE REWRITE ONLY FOR PURE BOUNDARIES` The existing `PredmetJsonTransferCore` is already a pure candidate.

Repo evidence: `lib/core/json_transfer/predmet_json_transfer_core.dart:32-35` explicitly says it is intentionally not wired into runtime and models validation seams for future work.

Technical implication: This is the best starting boundary for Web Pristup planning.

Risk: Ignoring it and designing a new transfer model would duplicate contracts.

Recommendation: Promote this candidate into a runtime-used pure contract only after tests confirm byte/shape compatibility with current runtime JSON.

## 7. Browser-local storage options: OPFS / IndexedDB / Drift web / SQLite WASM

Claim: `FEASIBLE WITH BOUNDARY EXTRACTION` Drift web with SQLite WASM backed by browser storage is the most compatible direction to evaluate first, because the app already uses Drift and generated table models.

Repo evidence: `pubspec.yaml:14-16` uses Drift and SQLite libs. `lib/core/database/database.dart:1449-1450` opens the current DB with `driftDatabase(name: kDatabaseName)`, which is native/mobile/desktop oriented through `drift_flutter`.

Technical implication: A web adapter should preserve Drift query/repository shape where possible, but database opening must be abstracted.

Risk: A direct `IndexedDB` key-value rewrite would bypass current relational schema, migrations, generated models, and tests.

Recommendation: Evaluate Drift web + SQLite WASM first in a spike, after extracting `AppDatabase` executor construction. Do not implement in release branch yet.

Claim: `FEASIBLE BUT NOT PROVEN IN REPO` OPFS is a realistic candidate for browser-local SQLite durability, but the repo has no OPFS implementation or dependency.

Repo evidence: Required search found no OPFS, IndexedDB, WASM, or browser storage code. No `web/` runner exists.

Technical implication: OPFS must be validated with the exact Flutter/Drift version, browser support, backup/export UX, and persistence prompts.

Risk: OPFS availability differs by browser and context; assuming it is universal would create data-loss and support issues.

Recommendation: Treat OPFS as candidate storage for browser-local working copies, not as decided architecture.

Claim: `RISKY / NOT RECOMMENDED` Syncing whole SQLite databases is the wrong model.

Repo evidence: Current local DB includes app-wide tables, logs, users, firm settings, catalog, templates, stock, and `PREDMET` data in one schema (`lib/core/database/database.dart:18-36`). Full backup JSON already filters/validates cross-table payloads.

Technical implication: Whole DB sync cannot handle concurrent browser edits, migrations, conflict semantics, or per-entity encryption cleanly.

Risk: Database-level sync can corrupt business truth or leak full readable payloads to a coordinator.

Recommendation: If sync exists later, sync business commands/events or entity-level documents, not SQLite files.

## 8. Persisted storage and backup risk

Claim: `FEASIBLE WITH LIMITS` Browser persisted storage can reduce eviction risk, but cannot be the only data safety mechanism.

Repo evidence: The repo has no browser persisted storage logic. Existing safety mechanism is explicit JSON export/backup through `lib/core/utils/json_export_import.dart` and settings/predmet UI.

Technical implication: Browser storage health should be modeled as runtime diagnostics and user-visible backup status, not as a guarantee.

Risk: Browser data can still be lost by user clearing site data, browser profile removal, private mode, enterprise policies, or unsupported browsers.

Recommendation: For Web Pristup, design storage health: persistent-storage granted/denied, last successful `.json` or future repo export, DB open/migration status, quota estimate, and restore test. Keep manual backups mandatory.

## 9. `.opcrepo` or existing JSON transfer contract assessment

Claim: `DO NOT IMPLEMENT YET` `.opcrepo` should not replace current JSON contracts now.

Repo evidence: Single `PREDMET` and full backup JSON are already implemented and tested. No `.opcrepo` was found in repo search.

Technical implication: A new container format would add migration, versioning, UI, test, and support burden.

Risk: Introducing `.opcrepo` prematurely can fork transfer semantics from existing JSON.

Recommendation: Keep JSON as the basis. Consider `.opcrepo` later only as a packaging/container layer around versioned JSON manifests, attachments, checksums, and optional encryption, not as a new business contract.

## 10. Sync coordinator feasibility

Claim: `FEASIBLE WITH SERIOUS BOUNDARY EXTRACTION` OPC could become a sync coordinator for web/network mode, but not from current local user/database assumptions.

Repo evidence: No network sync, tenant, server, API, backend, or cloud database implementation was found. Occurrences of `sync` in app code are local method names such as `syncMestoSmrtiManagedRows` in `lib/features/predmeti/data/iriu_repository.dart:350` and `syncBlok2ManagedRows` around `:380`, not network synchronization.

Technical implication: A coordinator requires new identity, device, authorization, conflict, command ordering, and cryptographic envelope boundaries.

Risk: Adding coordinator behavior before extracting domain events will make the server a readable central database by default.

Recommendation: Do not build sync yet. First define deterministic local command/event shapes for `PREDMET` mutations and prove replay into local Drift produces current results.

## 11. Command journal feasibility

Claim: `DO NOT IMPLEMENT YET` A command journal is a good future concept, but too large a jump for this phase.

Repo evidence: Current `log_izmena` exists as a local audit/history table and `PredmetiRepository` writes snapshots/log entries around saves and close/reopen. There is no command journal abstraction or replay engine.

Technical implication: A real command journal needs stable command schema, idempotency, causality, actor/device identity, replay tests, conflict handling, and migration policy.

Risk: Turning `log_izmena` into sync commands would be wrong; it records local changes, not a complete replayable business command stream.

Recommendation: Use a read-only design spike later: define 3-5 candidate commands for `PREDMET` create/save/close/reopen/IRiU mutation and compare replay output against current repository behavior.

## 12. Encryption / non-readable server payload feasibility

Claim: `FEASIBLE WITH CONSTRAINTS` A non-readable central coordinator is possible only if the client owns encryption and the server stores opaque envelopes.

Repo evidence: `pubspec.yaml:27-29` includes `crypto` and `cryptography` for PIN/license-related work. License signature verification uses `cryptography` in `lib/core/entitlements/opc_license_signature_verifier.dart`. No data-at-rest encryption, key management, encrypted sync payload, or server envelope code was found.

Technical implication: This is greenfield security architecture, not a small extension.

Risk: If encryption is added late, server-side readable data models, search/reporting, support tooling, and migrations may already depend on plaintext.

Recommendation: If non-readable server payloads are a requirement, decide before backend design. For this phase, document constraints only.

## 13. Hosting architecture recommendation: PaaS/IaaS/hybrid

Claim: `OWNER DECISION REQUIRED` Hosting cannot be finalized from current repo evidence because no backend shape exists.

Repo evidence: No server code, API routes, database migrations for server Postgres, cloud config, auth provider, payment provider, or deployment files were found.

Technical implication: Hosting follows architecture, not the other way around.

Risk: Choosing Supabase/Cloudflare/VPS/etc. now may force readable central database assumptions or incompatible browser storage/sync trade-offs.

Recommendation: Minimum realistic recommendation for release-ready future planning is hybrid: static Flutter Web hosting plus a small PaaS-managed coordinator API only after encrypted envelope/sync decisions. Managed Postgres is appropriate only for metadata, accounts, devices, license/subscription state, sync envelopes, and audit metadata if readable `PREDMET` content is not allowed. IaaS/VPS is realistic for full control but increases ops burden. Supabase is attractive for auth/Postgres but risky if it pushes readable row-level `PREDMET` storage. Cloudflare is strong for static/app-edge and object storage, but SQLite/OPFS remains client-side and coordinator state must be deliberately designed.

## 14. Minimum viable release-ready architecture

Claim: `FEASIBLE WITH CONSTRAINTS` Minimum viable release-ready architecture is local-first Windows/Android plus a protected Web Pristup research track.

Repo evidence: Current repo supports Windows/Android parity, local Drift/SQLite, JSON transfer, PDF derivatives, local roles, firm settings, and entitlement packages. It lacks web runner/backend/sync/storage adapter.

Technical implication: The release path should not block Windows/Android on web/network design.

Risk: Forcing all runtimes into network sync now can delay release and destabilize local transfer.

Recommendation:

1. Keep Windows/Android release local-first with single-`PREDMET` JSON and full backup JSON.
2. Extract pure contracts: `PredmetJsonTransferCore`, business scenario ids, IRIU/financial truth rules, entitlement policy vocabulary.
3. Add contract tests proving pure core and current repositories produce identical JSON/rule outcomes.
4. Only then spike a separate web branch with database executor abstraction and Drift web/SQLite WASM storage.

## 15. Major risks and hidden issues

Claim: `RISKY / NOT RECOMMENDED` Hidden risks are mostly boundary and terminology risks, not missing code that can be added quickly.

Repo evidence: `docs/ARCHITECTURE_OVERVIEW.md:45` states boundaries are not established. `README.md:7` and `docs/PRODUCT_DIRECTION.md:13` use web/SaaS wording. Current UI imports platform APIs directly. Current auth is local PIN. Current firm settings singleton is not tenancy. Current JSON transfer is file contract, not API.

Technical implication: The biggest mistake would be to implement web/backend before extracting contracts.

Risk: Architectural debt: duplicate business logic, broken role semantics, unsafe sync, unreadable conflict behavior, and product terminology drift.

Recommendation: Treat web/network work as a separate runtime architecture track with a hard rule: no changes that weaken Windows/Android local JSON transfer.

## 16. Recommended next technical step

Claim: `FEASIBLE WITHOUT REWRITE` The smallest correct next technical step is contract extraction and validation, not web implementation.

Repo evidence: `lib/core/json_transfer/predmet_json_transfer_core.dart` is already a pure candidate; `test/json_transfer_regression_test.dart` already compares candidate and runtime serialization in multiple cases.

Technical implication: The repo already points to the next safe seam.

Risk: Starting with `web/`, backend, or OPFS would force decisions before contracts are stable.

Recommendation: If I were the senior developer responsible for the codebase and future release, the smallest correct next step that does not create architectural debt is:

1. Keep `lib/core/json_transfer/predmet_json_transfer_core.dart` pure and make it the explicit transfer-contract boundary.
2. Move only pure validation/normalization needed by `lib/core/utils/json_export_import.dart` behind that boundary, without changing payload shape.
3. Add tests in `test/json_transfer_regression_test.dart` that assert current runtime single-`PREDMET` export/import and the pure boundary produce identical maps for legacy schema 6, current schema 7, replacement import, and stock consequence cases.
4. Add no web runner and no new dependency in that step.

## 17. Explicit do-not-implement-yet list

`DO NOT IMPLEMENT YET`:

- `web/` runner.
- Backend/API.
- Network sync.
- Whole-SQLite sync.
- OPFS/IndexedDB/SQLite WASM adapter.
- Payment/subscription system.
- Tenant/organization membership model.
- Network user identity using current local PIN users.
- `.opcrepo` container.
- Encrypted command journal.
- Server-readable central `PREDMET` database.
- Business term rename from `naručilac` to `klijent`.

## 18. Final senior recommendation: feasible / feasible with constraints / not recommended

Final classification: `FEASIBLE WITH CONSTRAINTS`.

Claim: OPC Web Pristup is feasible as a future third runtime form, but not release-ready from the current repo without boundary extraction.

Repo evidence: Current repo has strong local Windows/Android foundations, Drift/SQLite schema, JSON transfer contracts, local roles, entitlements, and tests. It has no web runner, backend, network sync, browser storage, tenant model, or network identity model.

Technical implication: The correct path is contract extraction first, web storage/runtime second, sync/coordinator last.

Risk: A premature web/backend implementation would create architectural debt and could damage Windows/Android release readiness.

Recommendation: Release Windows/Android on the existing local model. Preserve JSON transfer. Create a dedicated follow-up task for pure transfer/business-boundary extraction before any OPC Web Pristup implementation.

## Required term search summary

`CONFIRMED IN REPO`: `PREDMET`, `Predmet`, `ADMINISTRATOR`, `SAVETNIK`, `osnovni`, `srednji`, `potpun`, `entitlement`, `license`, `licenca`, `json`, `backup`, `export`, `import`, `firma`, `naručilac`/`narucilac`, `drift`, `sqlite`, `schemaVersion`, `migration`, `web`.

`NOT FOUND IN REPO AS IMPLEMENTED ARCHITECTURE`: web runner, OPFS, IndexedDB, SQLite WASM adapter, backend, API, hosting, Postgres, Supabase, Cloudflare, VPS, network tenant model, network sync.

`FOUND ONLY AS LOCAL/UNRELATED TERMS`: `sync` appears in local method names such as IRIU row synchronization, not network sync. `web` appears in docs and catalog item text, not as a runner. `SaaS` appears as terminology/entitlement source label, not an implemented product model.

`TERM CAUTION`: `klijent` search did not establish it as a replacement for `naručilac`; do not introduce it as canonical without owner decision.

## Validation

Flutter checks were attempted after the report was created:

- `flutter analyze`: failed immediately through the PowerShell profile because it pointed Dart at missing `C:\Projekti\flutter_sdk\bin\cache\dart-sdk\bin\dart.exe`.
- `flutter test`: failed immediately for the same PowerShell profile path issue.
- `C:\flutter\bin\flutter.bat analyze` with profile loading disabled: timed out after 124 seconds with no useful diagnostic output.
- `C:\flutter\bin\flutter.bat test` with profile loading disabled: timed out after 244 seconds with no useful diagnostic output.

These checks are not marked PASS. Because no source code changed, the primary validation remains repo inspection, documentation diff review, and final Git cleanliness.

## Handoff

```text
Task: OPC WEB ACCESS RELEASE-READY FEASIBILITY AND RISK AUDIT
Branch: task/OPC-WEB-ACCESS-RELEASE-READY-AUDIT
Base commit: 80294ea
Final commit: see final Codex handoff for exact amended commit hash
GitHub commit/PR link: not created
Changed files: docs/tasks/OPC_TASK_WEB_ACCESS_RELEASE_READY_FEASIBILITY_AND_RISK_AUDIT_REPORT.md
Diff stat: 1 file changed, documentation-only report
Tests/checks: git status and git log run; Flutter analyze/test attempted but not passed because profile Flutter path was invalid and explicit Flutter commands timed out
Build: Not run - audit-only documentation task
Report path: docs/tasks/OPC_TASK_WEB_ACCESS_RELEASE_READY_FEASIBILITY_AND_RISK_AUDIT_REPORT.md
Not touched: source code, migrations, Flutter web runner, backend, API, sync, storage adapter, package restructuring, payment/subscription implementation
Known risks: Web/storage/sync recommendations are architecture-level and require follow-up validation; no web runtime was implemented
PASS / NOT PASS: PASS if final Git status is clean
```
