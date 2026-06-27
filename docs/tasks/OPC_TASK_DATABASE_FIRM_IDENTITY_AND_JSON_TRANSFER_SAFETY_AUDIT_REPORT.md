# OPC DATABASE / FIRM IDENTITY AND JSON TRANSFER SAFETY AUDIT

Base inspected: `80294ea`.

Initial validation:

```text
git status --short --branch
## task/OPC-WEB-ACCESS-RELEASE-READY-AUDIT...origin/task/OPC-WEB-ACCESS-RELEASE-READY-AUDIT

git log --oneline -5
662c1ef docs: add OPC web access feasibility audit
80294ea docs: confirm Logos GitHub visibility
f74638d docs: record OPC GitHub push verification
07c61c1 docs: finalize GH-001 local foundation report
520b189 chore: establish OPC public repository baseline
```

The audit branch for this report was created from `80294ea`:

```text
task/OPC-DATABASE-FIRM-IDENTITY-AND-JSON-SAFETY-AUDIT
```

Scope: read-only senior audit with one documentation-only report. No source code, migrations, schema changes, web runner, backend, API, sync, storage adapter, payment/subscription work, package restructuring, or terminology rename was performed.

## 1. Executive conclusion

Claim: OPC currently does not have a stable technical database/firma/repository identity inside the local SQLite database.

Repo evidence: Searches for `databaseId`, `repositoryId`, and `firmaId` found no implemented database identity fields. `lib/core/database/tables/firma_podaci_table.dart` contains editable business firm fields only. `lib/core/database/database.dart:53` has schema version 17, and `lib/core/config/app_config.dart` defines lane names through `kDatabaseName`, but neither is a per-database identity.

Technical implication: The current system can identify a database lane/file name and app schema, but not a stable database family owned by a firm.

Risk: JSON from another firm or another unrelated local database can be imported if the user chooses it. Single `PREDMET` import can create or replace a local case based on `brojPredmeta`, and full backup import can replace all local content.

Recommendation: Before OPC Web browser-local database work, add a minimal identity contract design for a shared repository/database-family id plus per-device installation id. Do not implement it in this audit.

Classification: `NEEDS GUARD`

Claim: Existing JSON transfer is real and useful, but it is not a cross-firm safety boundary.

Repo evidence: `lib/core/utils/json_export_import.dart:397-450` serializes single `PREDMET` JSON. `lib/core/utils/json_export_import.dart:514-568` serializes full backup JSON. Import paths are in `lib/core/utils/json_export_import.dart:710-747`, `:802-1126`, and `:2075-2181`.

Technical implication: JSON contracts should remain central for Windows/Android and future browser-local OPC, but they need repository identity metadata and import policy.

Risk: Treating the current JSON shape as sufficient for Web local replicas would allow accidental cross-firm import/restore.

Recommendation: Preserve JSON transfer, add identity guard planning around it, and validate with regression tests before any Web storage/hosting implementation.

Classification: `NEEDS GUARD`

## 2. Current database identity

Claim: `databaseId`, `repositoryId`, `firmaId`, and equivalent internal database identity table are `NOT FOUND IN REPO`.

Repo evidence: Required search found `databaseIdentity: 'OPC'` in `lib/core/utils/json_export_import.dart:551`, but that is a static product marker in backup JSON, not a unique id. `lib/core/database/database.dart` declares tables but no metadata/identity table. `lib/core/database/tables/` has app settings, firm data, users, predmeti, logs, catalog, stock, and templates, but no repository identity table.

Technical implication: Two unrelated OPC databases can both export backup JSON with the same static `databaseIdentity: 'OPC'`.

Risk: Import code cannot distinguish same firm/same repository from different firm or cloned database.

Recommendation: Add a future `opc_repository_identity` or equivalent singleton identity table only after an explicit identity design task.

Classification: `NOT FOUND IN REPO`

Claim: `installationId` exists, but it identifies the app installation for licence handling, not the database/firma/repository.

Repo evidence: `lib/core/installation/opc_installation_id_repository.dart` creates `opc_install_<timestamp>_<32hex>` and stores it in `opc_installation_id.txt` under `getApplicationSupportDirectory()`. `lib/features/podesavanja/presentation/podesavanja_screen.dart` displays and copies this installation id around licence diagnostics. `lib/core/entitlements/opc_local_license_parser.dart:60-63` checks whether a licence allows the current installation id.

Technical implication: It is stable across app restarts on the same installation if the support file remains, but it is outside the SQLite database and not the shared identity of a database family.

Risk: It cannot prove that JSON belongs to the same firm database, and full backup/restore does not preserve it as database identity.

Recommendation: Keep `installationId` as device/app-installation identity. Do not reuse it as firm repository identity.

Classification: `CONFIRMED IN REPO`

Claim: Schema version and database lane name are not identity.

Repo evidence: `lib/core/database/database.dart:53` returns `schemaVersion => 17`. `lib/core/config/app_config.dart` maps build variants to lane names such as `opc_v4_release`, and `lib/core/database/database_lane_diagnostics.dart` reports active and alternate `.sqlite` files.

Technical implication: Schema version is compatibility metadata; lane name is runtime file selection.

Risk: Using either as identity would cause false positives across unrelated firms.

Recommendation: Treat them as diagnostics only.

Classification: `CONFIRMED IN REPO`

## 3. Current firm identity

Claim: Firm data is represented as a singleton editable business-descriptive record.

Repo evidence: `lib/core/database/tables/firma_podaci_table.dart` defines `FirmaPodaci` with `id`, `naziv`, `adresa`, `pib`, `mb`, `sifraDelatnosti`, `telefon`, `odgovornoLice`, `email`, `sajt`, and `logo`. Comment says singleton table, always `id = 1`. `lib/core/database/database.dart:266-274` seeds the singleton. `lib/features/podesavanja/data/podesavanja_repository.dart:81-88` reads/watches/saves row `id = 1`.

Technical implication: Firm data is content/settings, not hard identity.

Risk: Editable firm fields can change over time, so they cannot safely guard import/restore.

Recommendation: Keep these fields as business display/config data. Add separate repository identity if cross-instance safety is required.

Classification: `CONFIRMED IN REPO`

Claim: PIB/MB are not used as import validation guards.

Repo evidence: `pib` and `mb` are fields in `FirmaPodaci` and are exported in full backup through `_firmaPodaciToMap` in `lib/core/utils/json_export_import.dart:379-383`. Import decodes and inserts `firmaPodaci` in `lib/core/utils/json_export_import.dart:843-858`. No check compares imported PIB/MB against current local PIB/MB before import.

Technical implication: PIB/MB are restored as content, not enforced as identity.

Risk: Backup from Firm A can replace Firm B data after user confirmation.

Recommendation: Do not use PIB/MB alone as hard identity. They may be shown as soft warning metadata, but technical repository id is still needed.

Classification: `NEEDS GUARD`

Claim: Firm data can be edited after database creation.

Repo evidence: `lib/features/podesavanja/presentation/podesavanja_screen.dart:711-723` loads firm fields into controllers. `lib/features/podesavanja/presentation/podesavanja_screen.dart:758-767` saves edited `naziv`, `adresa`, `pib`, `mb`, and related fields through `saveFirmaPodaci`.

Technical implication: Changing firm business data does not change any stable identity because no such identity exists.

Risk: JSON exported before and after firm edits cannot be related by stable firm identity.

Recommendation: Future identity must be immutable or guarded separately from editable business fields.

Classification: `CONFIRMED IN REPO`

## 4. Single PREDMET JSON transfer safety

Claim: Single `PREDMET` export is implemented in `lib/core/utils/json_export_import.dart` and exposed from the `PREDMET` screen.

Repo evidence: `lib/core/utils/json_export_import.dart:397-450` builds the single `PREDMET` JSON document. `lib/core/utils/json_export_import.dart:1913-1930` exposes `serializePredmetJsonForTest`. `lib/core/utils/json_export_import.dart:2030-2036` exposes `izvoziPredmetJson`. `lib/features/predmeti/presentation/predmet_screen.dart:804-811` calls `izvoziPredmetJson`.

Technical implication: The export includes one `PredmetiData` row plus related IRIU/contact rows and optional stock consequence transfer block.

Risk: It does not include firm/repository identity.

Recommendation: Keep the format and add a future backward-compatible identity metadata block.

Classification: `CONFIRMED IN REPO`

Claim: Single `PREDMET` import validates schema/newer-version and stock consequence consistency, but not firm/repository identity.

Repo evidence: `lib/core/utils/json_export_import.dart:1489-1498` rejects newer unsupported schema versions. `lib/core/utils/json_export_import.dart:1501-1525` reads `predmet`, `iriu`, `kontaktLica`, and consequence transfer. `lib/core/utils/json_export_import.dart:1527-1676` validates consequence transfer schema/policy/indices/forbidden fields. No code compares imported firm/repository/database identity against local state.

Technical implication: Import safety is structural and business-subpayload oriented, not ownership oriented.

Risk: Cross-firm single `PREDMET` import is possible.

Recommendation: Future import should distinguish same repository, same firm/different repository, and different firm before allowing create/replace.

Classification: `NEEDS GUARD`

Claim: Exported single `PREDMET` metadata includes format, schema, entity type, document source marker, encoding, export version, timestamp, source expectations, and `PredmetiData` fields including `sourceIdentity`.

Repo evidence: `lib/core/utils/json_export_import.dart:415-440` writes `format: OPC_PREDMET`, `schemaVersion`, `entityType: PREDMET`, `documentSourceIdentity: PREDMET`, `encoding`, `exportVerzija`, `exportDatum`, and `sourceExpectations`. `lib/core/database/tables/predmeti_table.dart:13-18` defines `businessScenarioId`, `sourceIdentity`, created/modified user ids and timestamp.

Technical implication: This is enough for format compatibility and derivative-document expectations, not firm ownership.

Risk: `sourceIdentity` defaults to `local_opc` and is not a unique source repository.

Recommendation: Do not treat `sourceIdentity` as repository identity. Add explicit identity metadata later.

Classification: `CONFIRMED IN REPO`

## 5. Full database / backup JSON transfer safety

Claim: Full backup export is implemented and contains full local content, including firm data, users, predmeti, catalog, settings, templates, logs, and stock sections.

Repo evidence: `lib/core/utils/json_export_import.dart:514-568` selects all key tables and writes backup sections. `lib/features/podesavanja/presentation/podesavanja_screen.dart:81-86` exposes backup export/import from settings.

Technical implication: Backup JSON is a local database replacement payload.

Risk: It can carry another firm's full business content without technical identity guard.

Recommendation: Keep full backup JSON as official local transfer, but add repository identity and visible source/current comparison before destructive restore in future work.

Classification: `CONFIRMED IN REPO`

Claim: Full backup metadata includes static product markers but not unique database/repository/firma identity.

Repo evidence: `lib/core/utils/json_export_import.dart:547-552` writes `format: OPC_BACKUP`, `schemaVersion`, `exportDatum`, `entityType: FULL_DATABASE_BACKUP`, `databaseIdentity: OPC`, and `stockBackupPolicy`. It does not write repository id, database family id, origin installation id, app version, package/licence metadata, record counts, checksum, signature, or origin platform.

Technical implication: Backup can be recognized as OPC backup, but not as belonging to the current database family.

Risk: `databaseIdentity: OPC` may look stronger than it is; it is not unique.

Recommendation: Rename nothing now, but document that `databaseIdentity` is a static product marker.

Classification: `NEEDS GUARD`

Claim: Full backup import replaces current local state after a destructive confirmation.

Repo evidence: `lib/core/utils/json_export_import.dart:2142-2165` displays "Uvoz cele baze" and warns it will replace all existing data, with `ZAMENI SVE`. `lib/core/utils/json_export_import.dart:802-1126` deletes stock, logs, predmeti, korisnici, firmaPodaci, catalog, settings, templates, then inserts rows from JSON.

Technical implication: Restore is not a merge. It is a content replacement inside the active local database.

Risk: A backup from a different firm can replace the current database if the user confirms.

Recommendation: Future restore confirmation should include repository/firma identity comparison and block or hard-warn cross-identity restores.

Classification: `HIGH RISK`

## 6. Cross-firm import risk

Claim: Cross-firm single `PREDMET` import is currently possible.

Repo evidence: `lib/core/utils/json_export_import.dart:2085-2136` detects `OPC_PREDMET`, reads payload, checks duplicate `brojPredmeta`, shows conflict dialog if needed, and otherwise imports as a new local predmet. No firm/repository check exists.

Technical implication: Firm A's `PREDMET` JSON can be imported into Firm B's database if the user selects it.

Risk: Data ownership, reporting, documents, and audit history can be polluted across firms.

Recommendation: Minimum future guard: source repository identity in single `PREDMET` JSON, local repository identity in DB, and import policy around mismatch.

Classification: `HIGH RISK`

Claim: Cross-firm full backup restore is currently possible after confirmation.

Repo evidence: Backup import checks format/schema and stock-transfer safety, then deletes local tables and inserts imported firm/content rows. No comparison of current and incoming firm or repository identity exists.

Technical implication: Firm B can be overwritten by Firm A backup.

Risk: This is acceptable only as a manual full restore tool when user intentionally replaces the database; it is not safe as replica transfer without identity guard.

Recommendation: For Web/browser-local equal databases, block by default unless repository identity matches, with an explicit "replace local database with different repository" recovery flow if owner approves.

Classification: `HIGH RISK`

## 7. Database replacement / restore behavior

Claim: Restore replaces table contents, not the installation id or licence file.

Repo evidence: `_uvoziBackupUBazu` deletes and inserts SQLite tables in `lib/core/utils/json_export_import.dart:802-1126`. `OpcInstallationIdRepository` and `OpcLocalLicenseRepository` store files under application support, outside the Drift tables.

Technical implication: Restored business database and device/licence identity can become unrelated.

Risk: A restored backup may contain different firm/user data while the same app installation and licence remain active.

Recommendation: Future restore should show current installation id separately and not confuse it with repository identity.

Classification: `CONFIRMED IN REPO`

Claim: Existing destructive restore confirmation is necessary but not sufficient.

Repo evidence: `lib/core/utils/json_export_import.dart:2142-2165` requires user confirmation. It does not show source firm/current firm comparison except through no identity metadata.

Technical implication: User intent is captured only at a generic "replace all" level.

Risk: Users can select the wrong file.

Recommendation: Add identity-aware confirmation in future: current repository id, incoming repository id, firm display fields, export time, and backup type.

Classification: `NEEDS GUARD`

## 8. Equality of local databases

Claim: The current code does not support a formal concept that multiple local databases of the same firm are equal replicas.

Repo evidence: No database-family id, repository id, clone lineage, origin id, replica id, or device id exists in SQLite or JSON. Existing transfer is manual JSON import/export.

Technical implication: Databases can be manually copied/restored, but the app cannot know whether two databases belong to the same firm repository.

Risk: Web browser-local model needs equality/replaceability semantics that current identity layer cannot express.

Recommendation: Introduce a future `opcRepositoryId` / `databaseFamilyId` concept and separate per-device `installationId`.

Classification: `NOT FOUND IN REPO`

Claim: Duplicate single `PREDMET` handling is based on business-visible `brojPredmeta`.

Repo evidence: `lib/core/utils/json_export_import.dart:2089-2118` finds local predmeti with matching `brojPredmeta`; multiple local matches block replacement as unsafe; one match opens conflict dialog with keep/replace/cancel choices.

Technical implication: Duplicate handling exists, but it is business-key based, not repository/entity-id based.

Risk: Same `brojPredmeta` from another firm can trigger replacement prompt, and different `brojPredmeta` from another firm can import silently as new.

Recommendation: Future `PREDMET` transfer needs stable case identity plus repository identity; business number remains display/business key.

Classification: `NEEDS GUARD`

## 9. PREDMET identifier stability

Claim: `Predmeti.id` is local technical identity, but it is not stable across single `PREDMET` import as a cross-database identifier.

Repo evidence: `lib/core/database/tables/predmeti_table.dart:5` defines auto-increment `id`. `PredmetiRepository.uveziPredmetSaPovezanimPodacima` inserts imported predmet with `id: Value.absent()` in `lib/features/predmeti/data/predmeti_repository.dart:493-522`, creating a new local id. Replacement preserves the local id with `predmet.copyWith(id: lokalniPredmetId)` in `:524-559`.

Technical implication: The same business case can have different local ids in different databases.

Risk: Id cannot be used for cross-replica equality or sync.

Recommendation: Future identity model needs stable `predmetUid` or equivalent if repeat imports and equal replicas must be reasoned about.

Classification: `CONFIRMED IN REPO`

Claim: `sourceIdentity` is not a sufficient `PREDMET` identity.

Repo evidence: `lib/core/database/tables/predmeti_table.dart:14-15` defaults `sourceIdentity` to `local_opc`. `lib/features/predmeti/data/predmeti_repository.dart:92-97` creates new predmeti with `_localSourceIdentity`. Tests in `test/json_transfer_regression_test.dart` assert preservation/defaulting of `sourceIdentity`, but not uniqueness.

Technical implication: It is source metadata, not a stable source repository or entity id.

Risk: All local databases can produce `sourceIdentity = local_opc`.

Recommendation: Keep `sourceIdentity` for current meaning. Add explicit repository/entity ids separately if needed.

Classification: `NEEDS GUARD`

## 10. Package/licence/entitlement interaction

Claim: Packages `osnovni`, `srednji`, `potpun` are code/licence entitlement concepts, not stored as local database content.

Repo evidence: `lib/core/entitlements/opc_entitlement_policy.dart:1-4` defines `OpcPackageLevel`. `lib/core/entitlements/opc_local_license_parser.dart:225-229` parses package strings. `lib/core/entitlements/opc_local_license_repository.dart` stores licence text in `opc_license.opc-license` under application support.

Technical implication: Full database backup import does not directly change the installed licence file.

Risk: Restored data may contain modules/settings not available under current installation entitlement, but the package itself is app-level.

Recommendation: Package/licence should remain app/installation-level unless owner decides otherwise. Do not tie package to editable firm data.

Classification: `CONFIRMED IN REPO`

Claim: JSON backup does not include licence/package metadata.

Repo evidence: `_serijalizujBackup` sections in `lib/core/utils/json_export_import.dart:547-568` include database content, not licence payload or entitlement diagnostics. Single `PREDMET` export likewise does not include package/licence metadata.

Technical implication: Importing backup cannot install a licence or unlock package level.

Risk: Good for licence safety, but restore UX may need to warn if imported data uses unavailable modules.

Recommendation: Keep licence out of business database backup. Future metadata may include non-authoritative export-time package diagnostics for warnings only.

Classification: `SAFE AS-IS`

## 11. Current safeguards confirmed in repo

Claim: Current JSON safeguards cover format/schema, destructive confirmation, duplicate `brojPredmeta`, and stock consistency.

Repo evidence: Unsupported newer JSON schema is rejected in `lib/core/utils/json_export_import.dart:1489-1498`. Single `PREDMET` duplicate handling and conflict UI are in `:2089-2135` and `:1774-1824`. Full backup destructive confirmation is in `:2142-2165`. Stock backup/consequence validation is in `:1073-1126`, `:1186-1344`, and `:1527-1676`. Tests in `test/json_transfer_regression_test.dart` cover current/legacy JSON, backup operational toggle, stock consequence transfer, forbidden fields, invalid indices, and unsupported future schemas.

Technical implication: Existing safeguards are meaningful and should not be weakened.

Risk: They do not solve cross-firm identity.

Recommendation: Preserve all current safeguards and add identity guard as a separate layer.

Classification: `CONFIRMED IN REPO`

## 12. Missing safeguards / not found in repo

Claim: The following safeguards are `NOT FOUND IN REPO`: stable `databaseFamilyId`/`opcRepositoryId`, immutable firm repository identity, per-export origin repository id, backup checksum/signature, source/current identity comparison, cross-firm import block, same-firm different-repository distinction, clone/restored lineage, stable cross-database `PREDMET` uid, and Web/browser replica identity.

Repo evidence: Required search did not find implemented `databaseId`, `repositoryId`, or `firmaId`. Current JSON metadata lacks unique identity fields. Current import paths do not compare source/current identity.

Technical implication: The clarified OPC Web local-replica model needs a new identity layer before browser storage.

Risk: Without it, browser-local databases are just isolated databases with manual JSON import and no safety boundary.

Recommendation: Create an identity/transfer design task before Web implementation.

Classification: `NOT FOUND IN REPO`

## 13. Implications for OPC Web browser-local database model

Claim: The current JSON transfer mechanisms can be reused conceptually for OPC Web, but not safely for equal browser-local replicas without identity metadata.

Repo evidence: JSON import/export is pure file-oriented and current app is local Drift/SQLite. `README.md` and `docs/PRODUCT_DIRECTION.md` confirm current local data and Windows/Android parity. No central backend/API/sync exists in repo.

Technical implication: OPC Web can follow the local-replica principle if it uses equivalent local database and JSON transfer contracts, but must know whether an import/restore belongs to the same repository.

Risk: Browser restore/import UX has higher accidental-loss risk because browser storage is less visible than a local installed app database.

Recommendation: Treat server as app host/licence helper only in this concept; do not design central master `PREDMET` database. Add local identity and transfer guard first.

Classification: `NEEDS GUARD`

Claim: A shared `firmRepositoryId` / `opcRepositoryId` / `databaseFamilyId` is needed.

Repo evidence: Current firm data is editable content; current `installationId` is per installation; no shared repository id exists.

Technical implication: The id should identify one firm's OPC database family/repository, not one device and not one editable display name.

Risk: Without it, "same firm same repository", "same firm different repository", "different firm", "cloned database", and "restored database" cannot be distinguished.

Recommendation: Prefer a generated immutable `opcRepositoryId` stored in the database and exported in single `PREDMET` JSON and full backup JSON. Keep per-device/browser `installationId` separately.

Classification: `OWNER DECISION REQUIRED`

## 14. Minimum safe identity model before Web implementation

Claim: Minimum safe identity model requires two identities: shared repository identity and per-installation identity.

Repo evidence: Existing `OpcInstallationIdRepository` already covers per-installation identity outside the DB. Missing piece is a shared DB/repository identity table and transfer metadata.

Technical implication: Same firm/same repository can be allowed; same firm/different repository can warn; different firm can block or require explicit recovery import; cloned database can preserve repository id but get its own installation id; full restore can replace repository id only through an explicit database replacement path.

Risk: Adding Web storage before this creates unguarded browser-local replicas.

Recommendation: Design, then implement in a future task: singleton DB identity row, JSON metadata fields, import comparison policy, and regression tests.

Classification: `NEEDS GUARD`

## 15. Recommended smallest next technical step

Claim: The smallest correct next technical step is not Web storage; it is a read-only design plus tests for identity metadata compatibility.

Repo evidence: Current boundaries to touch later would be `lib/core/database/database.dart`, a new table under `lib/core/database/tables/`, `lib/core/utils/json_export_import.dart`, `lib/core/json_transfer/predmet_json_transfer_core.dart`, and `test/json_transfer_regression_test.dart`. This audit did not edit them.

Technical implication: The first implementation step must be narrow and backward-compatible.

Risk: A premature migration or Web runner would combine identity, storage, and runtime risk.

Recommendation: Next task should define an identity contract document first. Then implement a DB identity singleton and JSON metadata guard with migration/tests in a separate implementation task.

Classification: `DO NOT IMPLEMENT YET`

Special senior-developer answer:

If OPC Web must preserve the same model as local Windows/Android, where every browser/device can have a full equal database and the user/firma remains sole owner, the smallest correct identity/transfer safeguard before Web work starts is a stable, generated repository/database-family identity stored inside the local Drift database and exported in both single `PREDMET` JSON and full backup JSON, plus a separate per-device/browser `installationId`. Technically, the future implementation boundary is `lib/core/database/` for identity storage, `lib/core/utils/json_export_import.dart` and `lib/core/json_transfer/predmet_json_transfer_core.dart` for export/import metadata and validation, and `test/json_transfer_regression_test.dart` for backward compatibility and mismatch behavior. It must not reuse editable `FirmaPodaci.pib/mb/naziv` or current `sourceIdentity` as the hard guard.

## 16. Do-not-implement-yet list

`DO NOT IMPLEMENT YET`:

- Web runner.
- Backend/API.
- Sync.
- OPFS/IndexedDB/SQLite WASM adapter.
- Storage adapter.
- Migration/schema change in this audit.
- Payment/subscription implementation.
- Package restructuring.
- Whole-SQLite sync.
- Central master `PREDMET` database.
- Treating server as owner of user/firma data.
- Treating current PIN/local users as network identity.
- Treating `FirmaPodaci` as tenant model.
- Replacing `naručilac` with `klijent`.
- Weakening current JSON transfer safeguards.

## 17. Final senior recommendation

Claim: Current OPC local JSON transfer is usable for Windows/Android and conceptually central for future OPC Web local replicas, but it is not safe enough for multi-device/browser database equality until repository identity exists.

Repo evidence: Windows/Android/local-first facts are in `README.md`, `docs/PRODUCT_DIRECTION.md`, and `docs/ARCHITECTURE_OVERVIEW.md`. JSON contracts are in `lib/core/utils/json_export_import.dart` and `lib/core/json_transfer/predmet_json_transfer_core.dart`. Firm data is editable singleton content in `lib/core/database/tables/firma_podaci_table.dart`. Installation/licence identity is file-based in `lib/core/installation/` and `lib/core/entitlements/`.

Technical implication: The correct direction is local-replica identity hardening, not central master database design.

Risk: If OPC Web starts with storage/hosting before identity, it will reproduce current cross-firm import/restore risk in a more fragile browser context.

Recommendation: `FEASIBLE WITH GUARD`: preserve current Windows/Android JSON transfer; add a future repository identity layer before Web; do not implement Web/storage/sync until identity and transfer guard behavior are specified and tested.

Classification: `NEEDS GUARD`

## Required search summary

Confirmed terms found in repo: `firma`, `Firma`, `installationId`, `sourceIdentity`, `documentSourceIdentity`, `schemaVersion`, `backup`, `restore`, `export`, `import`, `json`, `PredmetJson`, `PREDMET`, `Predmet`, `PIB`, `MB`, `ADMINISTRATOR`, `SAVETNIK`, `osnovni`, `srednji`, `potpun`, `entitlement`, `licenca`, `license`.

Not found as implemented database/repository identity: `firmaId`, `databaseId`, `repositoryId`.

## Validation

Flutter checks:

```text
Not run - audit-only / environment not confirmed / would require dependency mutation
```

No skipped Flutter check is marked as PASS evidence.

## Handoff

```text
Task: OPC DATABASE / FIRM IDENTITY AND JSON TRANSFER SAFETY AUDIT
Branch: task/OPC-DATABASE-FIRM-IDENTITY-AND-JSON-SAFETY-AUDIT
Base commit: 80294ea
Final commit: see final Codex handoff for exact amended commit hash
GitHub branch link: see final Codex handoff
GitHub commit link: see final Codex handoff
GitHub report link: see final Codex handoff
Changed files: docs/tasks/OPC_TASK_DATABASE_FIRM_IDENTITY_AND_JSON_TRANSFER_SAFETY_AUDIT_REPORT.md
Diff stat: 1 file changed, documentation-only report
Tests/checks: git status and git log run at start; final Git checks run after commit
Build: Not run - audit-only / environment not confirmed / would require dependency mutation
Report path: docs/tasks/OPC_TASK_DATABASE_FIRM_IDENTITY_AND_JSON_TRANSFER_SAFETY_AUDIT_REPORT.md
Not touched: source code, migrations, schema, web runner, backend, API, sync, storage adapter, payment/subscription, package restructuring, terminology rename
Known risks: Current repo lacks repository/database-family identity; cross-firm JSON import/restore remains possible by user action
Final git status: see final Codex handoff
PASS / NOT PASS: PASS if final git status is clean and GitHub links are public
```
