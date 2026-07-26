# OPC Task — Canonical Database Recovery and Legacy Migration Compatibility

## Task identity

- Date: 2026-07-16
- Repository: `https://github.com/Tale74/OPC`
- Branch: `task/OPC-CANONICAL-DATABASE-RECOVERY-LEGACY-MIGRATION-COMPATIBILITY`
- Base and starting HEAD: `a797f1118f38d39b36dc4ddfaa2fb9758482e3cb`
- Starting working tree: clean
- Scope: database recovery, historical migration compatibility, tests,
  authoritative documentation and Windows release evidence

## OPC MANIFEST CHECK — TASK START

- Manifest read: YES — complete
  `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- Applicable repository rules read: YES —
  `PROJECT_DOCS/OPC_v1_CODEX_RULES.md` and
  `PROJECT_DOCS/OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- PREDMET ownership: preserved.
- Database authority: affected only through the explicit owner decision naming
  the release database as canonical; schema version does not establish business
  authority.
- Windows/Android parity: migration implementation is shared Dart/Drift logic.
- JSON contract: not changed.
- Stage 2 package/licensing architecture: not changed.
- Conflict with manifest: none. The manifest's general rule that no database is
  automatically master remains intact; this database is canonical because the
  owner explicitly designated it.

## Owner decisions and database policy

The single owner canonical business database is:

`<OWNER_USER_HOME>\Documents\opc_v4_release.sqlite`

Its records remain authoritative even when physical schema and
`PRAGMA user_version` disagree. Test lanes, temporary copies and a newer schema
version never make another database more authoritative. Existing external users
retain their own databases, which must be backed up and upgraded in place; no
deletion, reset, prepared replacement or manual merge is permitted.

The active policy is documented in
`docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md` and locked in the owner
decision guide/index and anti-drift manifest.

## Confirmed incident and source evidence

The incident database has `user_version = 19`, while its physical schema
already includes valid `predmeti.docek_datum` and v21 PARTE objects. The former
v19-to-v20 Drift step used unconditional `m.addColumn`, so it attempted the same
`ALTER TABLE` after earlier DDL had already committed but the version checkpoint
had remained stale. SQLite correctly rejected the duplicate column.

This is earlier migration debt exposed by the current build, not a regression
introduced by the PARTE runtime-corrections task. The broader risk was general:
other historical additive column/table/index operations could be repeated after
committed DDL and a later failed open.

Source path:

`lib/core/database/database.dart` → Drift `onUpgrade` → v19/v20/v21 steps →
bounded `beforeOpen` recovery and full validation.

Drift owns checkpoint sequencing. The application does not catch and ignore
SQLite exceptions and does not manually stamp `user_version`.

## Historical schema inventory and deployment classification

| Version | Evidence and major transition | Classification | Support |
| --- | --- | --- | --- |
| 1–13 | Surviving source migration chain; incomplete distribution evidence | INSUFFICIENT EVIDENCE → safer support classification | PASS |
| 14 | STANJE ROBE state table; documented historical transition | POSSIBLY/KNOWN DEPLOYED — MUST SUPPORT | PASS |
| 15 | applied-effects table/indexes | POSSIBLY/KNOWN DEPLOYED — MUST SUPPORT | PASS |
| 16 | stock-consequence table/indexes | POSSIBLY/KNOWN DEPLOYED — MUST SUPPORT | PASS |
| 17 | public repository baseline, commit `520b189` | DEPLOYED — MUST SUPPORT | PASS |
| 18 | reminder table, commit `b2e7e96` | DEPLOYED/POSSIBLY DEPLOYED — MUST SUPPORT | PASS |
| 19 | reminder delivery times, commit `5e833a2`; confirmed owner checkpoint | DEPLOYED — MUST SUPPORT | PASS |
| 20 | `predmeti.docek_datum`, commit `bd713eb` | DEPLOYED/POSSIBLY DEPLOYED — MUST SUPPORT | PASS |
| 21 | PARTE schema, commit `2084ba0` | CURRENT — MUST SUPPORT | PASS |

No surviving evidence proves that versions 1–13 were distributed, but all are
supported and tested rather than excluded. Version 0 with existing tables is
unknown and rejected. Versions newer than 21 are rejected without downgrade.

## Supported migration matrix

Populated synthetic fixtures for every checkpoint 1 through 21 run through the
actual `AppDatabase` migration path, reach 21, preserve applicable FIRMA,
KORISNIK, PREDMET, relationship, IRiU, reminder, stock and PARTE records, close
and reopen successfully.

Confirmed partial states:

| State | Result |
| --- | --- |
| v19, `docek_datum` missing | Correct definition added; reaches v21 — PASS |
| v19, valid `docek_datum` present | Validated, no duplicate DDL — PASS |
| physical v21, stale checkpoint v19 | Validated and checkpoint completed — PASS |
| v20, missing v21 objects | Only missing v21 objects added — PASS |
| valid v21, repeated open | No schema drift — PASS |
| DDL committed, later open failure, retry | Existing object reused; retry completes — PASS |

Malformed definitions for `docek_datum`, a missing foundational `predmeti`
table, malformed PARTE table, conflicting index, non-empty v0 database and
newer-than-supported checkpoint all stop with `OpcSchemaMismatch`. No table is
dropped or recreated.

## Idempotent migration and startup recovery design

`lib/core/database/schema_recovery.dart` provides bounded table/column/index
inspection and validation. It validates SQLite type, nullability, default,
primary-key position, index table, uniqueness, ordered columns and partial
predicate before accepting a same-named object.

`onUpgrade` uses these primitives for the supported additive sequence.
`beforeOpen` retries only the known additive object set, validates all generated
and manual tables and indexes, performs established schema-owned deterministic
backfills, and completes only when the target schema is coherent. Foundational
missing tables or contradictory definitions stop precisely.

An owner-copy validation initially exposed an unintended generic auth backfill
of existing empty `pin_updated_at` and `pin_hash_version` values. The recovery
path was narrowed so that this historical backfill runs only during the actual
pre-v10 migration; later stale-checkpoint recovery preserves existing values.
A dedicated regression test covers this exact case. The fresh final copy then
showed identical content hashes for every table.

## Legacy migration risk review

| Operation family | Historical risk | Current protection | Remaining action |
| --- | --- | --- | --- |
| Additive columns v2–13 | DDL can exist with stale checkpoint | existence plus full definition validation | none for supported shapes |
| Auth/security v10 | columns/tables may partially exist | bounded ensure/validate; semantic backfill only on actual pre-v10 upgrade | none |
| STANJE ROBE tables/indexes v14–17 | partial table/index creation | table and exact index validation | historical defaults 0/1 explicitly documented |
| PODSETNIK v18–19 | table/column can pre-exist | manual table and column definition validation | none |
| `docek_datum` v20 | confirmed duplicate-column failure | guarded creation plus exact validation | resolved |
| PARTE v21 | columns/tables can partially exist | guarded generated objects plus complete table validation | resolved |

Arbitrary corruption, unknown v0 user schemas, destructive transforms and
future/newer schemas remain intentionally outside automatic recovery.

## Tests and static validation

- `dart format`: PASS.
- `flutter analyze --no-pub`: PASS, no issues.
- Final focused selector/reminder/migration suite: PASS, 56 tests.
- Complete `flutter test --no-pub`: PASS, `226` passed and one gated copy test
  skipped by default.
- Gated real-copy-path test: PASS; migrated and reopened twice through
  `AppDatabase`.
- Drift generated schema: unchanged because no Drift table declaration or
  schema version changed; runtime validation uses the existing schema-21
  generated model.
- Cross-platform rule: PASS; no Windows condition exists in schema semantics.

## Owner backup evidence

OPC was closed and neither release `-wal` nor `-shm` sidecar existed. A direct
offline copy was therefore consistent.

| Evidence | Value |
| --- | --- |
| Source | `<OWNER_USER_HOME>\Documents\opc_v4_release.sqlite` |
| Source size | 81,125,376 bytes |
| Source modified | 2026-07-16 18:04:26 local |
| Source SHA-256 | `277E23AF37A3B1A275148AE3D1A88B4FE47662B00CDAA3972FB91128C19B5361` |
| Backup | `<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\BACKUPS\opc_v4_release_PRE_SCHEMA_RECOVERY_20260716_183812.sqlite` |
| Backup size/hash | identical to source |
| Integrity / checkpoint | `ok` / 19 |
| Canonicalized structural signature | `A88B286520E194A31574445AA5C523E99A6B9E4ACA737BC0C7111E78BB81B2AA` |
| Raw ordered `sqlite_master.sql` signature | `A67718E877DB306C82F8C43C82291C816830ED3F04CF45B6D4C85852D54BC03D` |

Filtered project backup:

`<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\BACKUPS\OPC_v1_backup_20260716_183812_pre_canonical_schema_recovery.zip`

- SHA-256:
  `DE9F97BE777090B3CB5C372619057AD740DA1D09B444FEF3BC704C2B9575C339`
- 673 entries; build, `.dart_tool` and `.git` excluded.

## Owner-copy migration evidence

Copy:

`<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\BACKUPS\opc_v4_release_MIGRATION_TEST_20260716_183812.sqlite`

The final validation copy was freshly restored from the pristine backup before
the final run.

| Check | Before | After |
| --- | --- | --- |
| SHA-256 | `277E23AF37A3B1A275148AE3D1A88B4FE47662B00CDAA3972FB91128C19B5361` | `8E6FF9C86832846B62358345F45DA9D1D41C6FB44D69B63B99E2520DC4525FBC` |
| `user_version` | 19 | 21 |
| `integrity_check` | ok | ok |
| Physical schema signature | unchanged | unchanged |
| User tables | 19 | 19 |
| Every table row count | baseline | identical |
| Every table content fingerprint | baseline | identical |
| AppDatabase opens | not applicable | migration open plus repeated open PASS |

No private row value was printed, logged or committed. At that copy-validation
stage, the real canonical file was checked again and remained byte-identical to
the then-current pristine backup at version 19. Its later explicitly authorized
live upgrade is recorded below.

## Runtime database selection and copy smoke

Source tracing proves:

`BUILD_VARIANT` absent → `PRODUCTION` fallback → `opc_v4_release` →
`driftDatabase(name: kDatabaseName)` → Windows Documents →
`<OWNER_USER_HOME>\Documents\opc_v4_release.sqlite`.

After explicit owner approval, the smallest selector was implemented as
`MIGRATION_TEST_DATABASE_PATH`. It is compile-time only and active exclusively
for `BUILD_VARIANT=WINDOWS_TEST`. It requires an absolute, existing regular
`.sqlite` file with `MIGRATION_TEST` in its filename and a valid SQLite 3 header.
It rejects the canonical filename and a filesystem alias of the canonical file.
Missing or invalid input fails before database open. `PRODUCTION`, `WINDOWS`
and Android behavior are unchanged and ignore the hook. No path is persisted
and there is no general database picker.

Final GUI-smoke copy:

`<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\BACKUPS\opc_v4_release_MIGRATION_TEST_GUI_SMOKE_FINAL_20260716_210633.sqlite`

It was freshly copied from the pristine v19 backup and initially had size
81,125,376 bytes and SHA-256
`277E23AF37A3B1A275148AE3D1A88B4FE47662B00CDAA3972FB91128C19B5361`.

Runtime evidence:

- first launch initialized without migration error and opened the PREDMET list;
- owner entered the private PIN directly in the application and confirmed login;
- one representative existing PREDMET opened;
- its PARTE segment opened;
- MODULI, PODSETNIK and MODUL PARTE opened;
- the application closed through its built-in exit confirmation;
- second launch and owner-confirmed login succeeded;
- second built-in close completed cleanly.

No private row value or screenshot is committed or included in this report.

The first exploratory smoke copy exposed an existing no-op reminder reschedule
that changed only `ceremony_reminder_settings.updated_at` for three rows while
notification IDs were unchanged. That copy was retained as failed audit
evidence and was not manually repaired. `saveScheduledIds` was made idempotent:
it now updates the row only when the ID list actually changes. A focused test
proves both unchanged and changed-ID behavior. The complete validation/build/
smoke sequence was then repeated against the fresh final copy above.

After both final starts:

- `user_version = 21`;
- `integrity_check = ok`;
- schema SHA-256:
  `A67718E877DB306C82F8C43C82291C816830ED3F04CF45B6D4C85852D54BC03D`;
- all row counts and content fingerprints for all 19 user tables equal the
  pristine pre-migration baseline;
- no copy WAL/SHM remains;
- final copy SHA-256:
  `8E6FF9C86832846B62358345F45DA9D1D41C6FB44D69B63B99E2520DC4525FBC`.

## Windows build evidence

The isolated-copy smoke release was built with the repository-approved Windows command
and the two explicit defines `BUILD_VARIANT=WINDOWS_TEST` and
`MIGRATION_TEST_DATABASE_PATH=<final copy>`. The production artifact/database
lane had not yet been launched at that stage.

- Artifact: `build\windows\x64\runner\Release\OPC.exe`
- Artifact size/SHA-256: 89,088 bytes /
  `0527315E5BEE146AD41656DC161B31CB7D5FDBCC4515C37D31F259579B865D44`.
- AOT payload: `build\windows\x64\runner\Release\data\app.so`.
- AOT size/SHA-256: 12,125,104 bytes /
  `0425D635B2C52DFCF9118102E5E1D3BE39E0A08DCC01C36F8306408928F1F64C`.
- Build and two copy-only launches: PASS.

### Approved PRODUCTION canonical-upgrade build

After the owner explicitly authorized the live upgrade, the repository was
confirmed clean at exactly
`0368bd83a57efd03df8ef6e398555e35aec8bf85`. The build command was exactly
`flutter build windows --release`, with no `dart-define`. It completed with
exit code 0, so the established fallback selected `PRODUCTION` and
`<OWNER_USER_HOME>\Documents\opc_v4_release.sqlite`.

- Artifact: `build\windows\x64\runner\Release\OPC.exe`.
- Artifact size/SHA-256: 89,088 bytes /
  `0527315E5BEE146AD41656DC161B31CB7D5FDBCC4515C37D31F259579B865D44`.
- AOT payload: `build\windows\x64\runner\Release\data\app.so`.
- AOT size/SHA-256: 12,125,104 bytes /
  `157BCA5E515C3520012875273F20F286505ABC407F31E5040A4666DE90E4B6E4`.

## Live canonical migration evidence

Before the live launch, OPC was closed and both canonical WAL/SHM files were
absent. At the owner's instruction, the canonical state modified at
2026-07-16 21:22:08 local became the new pre-migration baseline. A plain
byte-for-byte offline copy was made to:

`<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\BACKUPS\opc_v4_release_PRE_CANONICAL_UPGRADE_20260716_212208.sqlite`

| Check | Canonical source before migration | New offline backup |
| --- | --- | --- |
| Size | 81,125,376 bytes | 81,125,376 bytes |
| SHA-256 | `639EF6449564D91D933A43C5F74308D3ACAA48CE59FCE682C67F35E0AC73C023` | identical |
| `user_version` | 19 | 19 |
| `integrity_check` | ok | ok |
| Raw ordered schema signature | `A67718E877DB306C82F8C43C82291C816830ED3F04CF45B6D4C85852D54BC03D` | identical |
| User tables | 19 | 19 |
| All row counts/fingerprints | baseline below | identical |

The earlier audit backup
`opc_v4_release_PRE_SCHEMA_RECOVERY_20260716_183812.sqlite` was not modified;
its SHA-256 remained
`277E23AF37A3B1A275148AE3D1A88B4FE47662B00CDAA3972FB91128C19B5361`.

The metadata-only pre-migration baseline and final comparison are:

| Table | Rows | Content SHA-256 | Final match |
| --- | ---: | --- | --- |
| `app_podesavanja` | 1 | `1DD80C3544B9BD5D1E52BCB58B493C957168BACB8935C4F02FE17C290E4206BC` | YES |
| `auth_audit_log` | 1 | `84B4C87340418E63721E51A8C82E0300C20593DCBBA71476BE0A449D720E2595` | YES |
| `ceremony_reminder_settings` | 18 | `01C736A1B6CFDEFF5D1F24BC5C396CDA4585ABA6A5C1A6D7AC1ECB023624AB80` | YES |
| `firma_podaci` | 1 | `6431FF1F9DF27E4BE14F2D3ACA42335961838B201FE117BE7D145951A5C1F689` | YES |
| `iriu` | 529 | `C5C5370ACB6C0A4355D64BBD80EB6D4C77346A7ED47633D54EF32213DA44B5F4` | YES |
| `iriu_katalog_config` | 21 | `630CC8D82754F804902CCEE92567A516CF86786D493F6F425DCAD3F55EC063F4` | YES |
| `iriu_lifecycle_decisions` | 30 | `3E9E2DADDCE5DF16286E7BE75921520417CA6B10F7D950CF291F71A73A34EDD9` | YES |
| `katalog_artikli` | 126 | `E112978B7BF7FF6D52E585D79B08126725ECBD9E8DD09526FE7D3E92E61CC18E` | YES |
| `kontakt_lica` | 1 | `83BFEC5ED255D965DC595AAB32240300F805557EF8D15341C73C727B505C8BB7` | YES |
| `korisnici` | 1 | `A474977D270A9EF14DB3E1CF79A45C1A08F40CBC8012FB9E8A16D98507798888` | YES |
| `log_izmena` | 208 | `648008D0588D5CBBE68497D84957B954817817A59DC0A5171DF12BD70CEA4ED8` | YES |
| `parte_predlosci` | 0 | `EC02826EE7D7940A636F234FB6E072D9D4D7111D66AAAB7F97D37856AB065187` | YES |
| `parte_pripreme` | 1 | `6920D83AC17468678ACDB14DA82E3E4D0BC86F861E168AA4D123C47D8A4D1620` | YES |
| `predlosci_dokumenata` | 5 | `76CCD40DFF4D79C92932A7E5CDA0BEBE230DA26C9DA6F1D2A3FE4B58B82EA004` | YES |
| `predmeti` | 40 | `7D36386842638CF89C56A0F4F8D444194193D231926D0E63C0BB961035B5FDFA` | YES |
| `security_settings` | 1 | `66711D9ABEFCF6C220013EE69047433A95AC80465BA8D7B8FD456EA4F21BDA8E` | YES |
| `stanje_robe_applied_effects` | 61 | `9737927621FF2F6C803465ABCB98F9829E877DF8C027C5D862259D7FB82664E1` | YES |
| `stanje_robe_posledice` | 45 | `DC6329A01F4DB61C8CCF42970FEC47DBDA7D86011F6197AADEFB9D0FB8FED8A4` | YES |
| `stanje_robe_stavke` | 33 | `A0CD9427D784F338D13676DD7A422B02C165530AE706141303E2E22614FACE7B` | YES |

The PRODUCTION build opened the existing canonical file in place. No test
database was copied over it and neither SQL data nor `user_version` was changed
manually. First startup completed without a migration error; owner PIN/login,
the PREDMET list and one representative PREDMET passed. The app returned to the
list and closed through its built-in confirmation. The second startup,
owner-confirmed PIN/login, PREDMET list and built-in close also passed.

Final read-only state after the second close:

- OPC process count: 0;
- `user_version = 21`;
- `integrity_check = ok`;
- user tables: 19;
- every row count and every content fingerprint: identical to the new baseline;
- expected schema change: checkpoint 19 → 21 only; the already-v21-equivalent
  physical schema signature remained
  `A67718E877DB306C82F8C43C82291C816830ED3F04CF45B6D4C85852D54BC03D`;
- canonical WAL/SHM: absent;
- final canonical size: 81,125,376 bytes;
- final canonical SHA-256:
  `4117FF21EDDF6099F03FB391B1A94A60319C12FC8DC8B50D0654BA12ADE9E8C6`.

No private PREDMET value, screenshot, credential or database file is included
in repository evidence.

## External-user rollout procedure

1. Identify that user's canonical database path and the build/database variant.
2. Close OPC and inspect WAL/SHM state.
3. Make a SQLite-consistent backup and verify readability/hash.
4. Record `user_version`, schema signature and table row counts without private
   values.
5. Use the accepted migration-capable build through its established lane.
6. Confirm clean startup, schema 21 and `integrity_check = ok`.
7. Compare core business row counts and representative records with the user's
   assistance.
8. Close and launch again; confirm no further schema drift.
9. Retain the verified backup until user acceptance.
10. If the schema is unsupported or malformed, stop on the diagnostic and
    preserve both database and backup; do not replace or merge databases.

## Unresolved risks and exact owner decision

- Distribution evidence for versions 1–13 is incomplete, mitigated by full
  populated-fixture support for all of them.
- Automated migration, owner-derived copy validation and Windows GUI copy smoke
  pass.
- The owner explicitly authorized the separately guarded live canonical
  upgrade. It completed with all approved checks passing.
- Further PARTE runtime, physical print, DOCX acceptance and Android runtime
  remain outside this authorization and were not started.

## Stop-after-canonical confirmation

`CANONICAL DATABASE MIGRATION COMPLETE — DOUBLE-START PRODUCTION SMOKE PASS`

The canonical database was upgraded in place only through the explicitly
approved PRODUCTION application path. It was not renamed, replaced, deleted,
copied over or manually altered. Work stopped immediately after the approved
double-start smoke and final read-only verification.

## GitHub visibility and clean working tree

- Implementation commit:
  `e6a0c42c8df59ebe1415d91c1e795082d4bfd283` —
  `https://github.com/Tale74/OPC/commit/e6a0c42c8df59ebe1415d91c1e795082d4bfd283`.
- Approved GUI-smoke continuation commit:
  `bc7dceca6d512961003f8aa9627978a587833c39` —
  `https://github.com/Tale74/OPC/commit/bc7dceca6d512961003f8aa9627978a587833c39`.
- Public task branch:
  `https://github.com/Tale74/OPC/tree/task/OPC-CANONICAL-DATABASE-RECOVERY-LEGACY-MIGRATION-COMPATIBILITY`.
- Push: PASS; upstream branch configured.
- Final evidence-only report update is the branch head following the
  implementation commit.
- Working tree: clean after the evidence commit.
- The branch is not merged to `main`.

## OPC MANIFEST COMPLIANCE — TASK END

- Manifest compliance checked: YES.
- PREDMET remains the product center: YES.
- User/firma owns PREDMET data: YES.
- Shared Windows/Android migration semantics: YES.
- JSON contracts changed: NO.
- Stage 2/package/licensing expansion: NO.
- Canonical database replacement: NO. Explicitly authorized in-place migration:
  YES.
- Privacy scan: PASS; no database, private row value, credential, runtime log or
  build output is tracked.
- PASS / NOT PASS: PASS — supported historical schemas, isolated-copy smoke and
  authorized canonical double-start PRODUCTION smoke all pass.

## Created

- Idempotent schema recovery helper.
- Populated historical migration fixtures and full compatibility tests.
- Gated owner-copy path test.
- Fail-closed WINDOWS_TEST-only migration-copy selector and tests.
- Canonical migration policy and Logos pseudocode.
- This task report.

## Updated

- Drift migration/startup validation path.
- Idempotent no-op reminder rescheduling persistence.
- Existing package-downgrade tests.
- Manifest, owner decision, architecture, relationship and pseudocode indexes.

## Syntax check

Formatter and analyzer: PASS. Selector tests: 9/9 PASS. Final focused suite:
56/56 PASS. Final complete suite: 226 passed with one expected gated skip.

## Scope status

Implementation, historical compatibility, automated copy validation, GUI copy
runtime evidence and authorized canonical migration are complete. Work is
stopped before every unapproved downstream runtime/print/DOCX/Android phase.

## Notes

No database file, private row content, build output or machine secret is tracked.
