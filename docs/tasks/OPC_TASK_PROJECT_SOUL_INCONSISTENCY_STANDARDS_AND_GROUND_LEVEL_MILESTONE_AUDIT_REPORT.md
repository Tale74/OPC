# OPC Task Report - Project Soul, Inconsistency, Standards and Ground-Level Milestone Audit

## Executive conclusion

OPC is a local-first business application for organizing funeral ceremony cases around `PREDMET` as the only master business truth. Its practical value is not "many screens" or "PDF generation"; it is fast, reliable, controlled work for a funeral-service firm/user that owns its own local database.

The current manifest captures the core soul correctly, but it is thinner than the local `PROJECT_DOCS` continuity set. The local docs add important operational rules around locked business truth, Android/Windows UX parity, JSON transfer, backup/restore discipline, package/add-on boundaries, encoding safety, and Codex operating discipline. Future architecture work must not proceed from GitHub-visible docs alone until the local continuity set is either sanitized into the repo or explicitly superseded.

Main finding: the project is coherent if "SaaS-ready" in old docs is treated as historical future-readiness language, and "OPC Web Pristup" is treated as a future third runtime/access form that must preserve local-first/user-owned database principles. It becomes inconsistent if old SaaS/multi-device wording is interpreted as a central-master database roadmap.

This audit recommends a new owner-reviewed ground-level milestone before any Web, hosting, sync, payment, or broad architecture implementation.

PASS classification: PASS WITH OWNER DECISION QUEUE.

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- project-continuity audit / architecture consistency audit / standards gap audit

Core purpose preserved:
- yes

PREDMET meaning affected:
- no, audit only

Database ownership affected:
- no, audit only

JSON transfer affected:
- no, audit only

Windows/Android parity affected:
- no, audit only

Future Web Pristup affected:
- yes, concept clarification only

Terminology drift risk:
- yes, this task exists to detect and stop drift

Implementation allowed:
- no

Required gate before implementation:
- project soul / locked rules / local docs continuity / standards gap / owner decision gate

## Documents inspected

Mandatory manifest/workflow/template:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`

GitHub-visible docs:

- `README.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/ARCHITECTURE_OVERVIEW.md`
- `docs/tasks/OPC_TASK_LOCAL_PROJECT_DOCUMENTATION_INVENTORY_AND_CONTINUITY_AUDIT_REPORT.md`
- `docs/tasks/OPC_TASK_WEB_ACCESS_RELEASE_READY_FEASIBILITY_AND_RISK_AUDIT_REPORT.md` from `origin/task/OPC-WEB-ACCESS-RELEASE-READY-AUDIT`
- `docs/tasks/OPC_TASK_DATABASE_FIRM_IDENTITY_AND_JSON_TRANSFER_SAFETY_AUDIT_REPORT.md` from `origin/task/OPC-DATABASE-FIRM-IDENTITY-AND-JSON-SAFETY-AUDIT`

Local `PROJECT_DOCS` inspected:

- `PROJECT_DOCS\00_README_KAKO_KORISTITI.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_SOUL.md`
- `PROJECT_DOCS\OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `PROJECT_DOCS\OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS\OPC_v1_ARCHITECTURE_DECISIONS.md`
- `PROJECT_DOCS\OPC_v1_CODEX_RULES.md`
- `PROJECT_DOCS\OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1_SUMMARY.md`
- `PROJECT_DOCS\PROJECT_MAP_OPC_v1.json`
- `PROJECT_DOCS\OPC_v1_AUDIT_SUMMARY.md`
- `PROJECT_DOCS\OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md`
- `PROJECT_DOCS\OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md`
- `PROJECT_DOCS\OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md`

Code-level inspection areas:

- `lib/core/database/`
- `lib/core/json_transfer/`
- `lib/core/utils/json_export_import.dart`
- `lib/core/entitlements/`
- `lib/core/installation/`
- `lib/features/predmeti/`
- `lib/features/podesavanja/`
- `lib/features/auth/`
- `test/`
- `pubspec.yaml`

Private/export data was not opened.

## Local PROJECT_DOCS continuity summary

`SOURCE\PROJECT_DOCS` contains 14 files. `C:\Projekti\OPC\OPC v.1\PROJECT_DOCS` contains 11 files. The common core files have matching size and timestamp. `SOURCE\PROJECT_DOCS` also contains three newer task reports not present in the master folder:

- `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md`
- `OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md`
- `OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md`

Authority assessment:

- For the original core set, master and SOURCE copies appear equivalent by metadata.
- For the three newer reports, `SOURCE\PROJECT_DOCS` is the only inspected local copy and should be treated as the available continuity source unless the owner provides a newer master copy.
- `PROJECT_MAP_OPC_v1.json` is a maintained audit map, not business truth and not release approval evidence.
- `PROJECT_MAP_OPC_v1_SUMMARY.md` estimates current v1 architecture/project-map completeness around 67%, not sales readiness.

## OPC project soul

What OPC is at its core:

- OPC is `Organizator pogrebne ceremonije`.
- It is a local-first operational business tool, not a generic CRM and not a cloud-first SaaS product.
- It organizes work around one central business object: `PREDMET`.

Who OPC is for:

- A funeral-service firm/user that owns and operates its own database.
- Local `ADMINISTRATOR` and `SAVETNIK` users working on Windows and Android runtimes.

What problem OPC solves:

- Keeping funeral ceremony case data, documents, operational choices, JSON transfer, and supporting modules coherent around `PREDMET`.
- Allowing practical field/office work without losing business truth or relying on hidden central infrastructure.

What must remain simple:

- Creating, editing, closing, exporting, importing, and restoring cases.
- Backup/restore and JSON transfer mental model.
- Platform roles: Windows and Android are the same product, not two different business roles.

What must remain stable:

- `PREDMET` meaning.
- `brojPredmeta` conflict behavior until a future owner-approved identity model exists.
- Existing local JSON transfer and full backup JSON behavior.
- Local role vocabulary and protected terms.
- Windows/Android functional parity.

Soul from local docs:

- "PREDMET is the only source of truth."
- Derivatives may render, transfer, analyze, or warn, but they must not own truth.
- Broad rewrite is not the default path; narrow extraction and proof-preserving cleanup are preferred.
- The owner orchestrates business decisions; Codex executes bounded tasks and reports risks.

Does the manifest capture the soul?

- Yes, for the core purpose and anti-drift boundaries.
- Missing or thinner areas: backup/restore cadence, encoding/mojibake discipline, project-map authority limits, detailed package/add-on boundaries, and local docs continuity rules.

## Locked rules extracted from local docs

### PRODUCT IDENTITY

Rule: OPC is one product across Windows and Android, with future Web Pristup only as another runtime/access form.

Source document: `OPC_v1_PROJECT_SOUL.md`, `docs/PRODUCT_DIRECTION.md`, manifest.

Still valid:
- yes

Conflict:
- older local docs say "SaaS-ready"; current public docs prefer "OPC Web Pristup".

Recommendation: keep Web Pristup wording and treat SaaS as historical/future-seam language.

### PREDMET BUSINESS TRUTH

Rule: `PREDMET` is CORE and the only master business truth. UI, PDF, JSON, statistics, operational warnings, modules, and entitlements must not become parallel truth.

Source document: `OPC_v1_ZAKLJUCANA_PRAVILA.md`, `OPC_v1_PROJECT_SOUL.md`, manifest.

Still valid:
- yes

Conflict:
- none if all future Web/storage work preserves local PREDMET truth.

Recommendation: all implementation tasks touching case logic must include a PREDMET truth gate.

### WINDOWS/ANDROID PARITY

Rule: Windows and Android versions develop in parallel; UX may differ for screen/OS/input, but business meaning must not diverge.

Source document: `OPC_v1_PROJECT_SOUL.md`, `PRODUCT_DIRECTION.md`, README.

Still valid:
- yes

Conflict:
- no direct conflict.

Recommendation: keep platform-specific acceptance criteria for meaningful UI work.

### LOCAL DATABASE OWNERSHIP

Rule: current databases are local and owned by user/firma; no automatic central/master database exists.

Source document: manifest, README, database identity audit.

Still valid:
- yes

Conflict:
- old SaaS/multi-device wording can be misread as centralization.

Recommendation: require owner decision before any central/server database is described as truth owner.

### JSON TRANSFER

Rule: single-`PREDMET` JSON and full backup JSON are central local transfer mechanisms.

Source document: `OPC_v1_ZAKLJUCANA_PRAVILA.md`, Web audit, database identity audit, code.

Still valid:
- yes

Conflict:
- current JSON has no firm/repository identity guard.

Recommendation: preserve current formats; design backward-compatible identity metadata before Web/local-replica work.

### BACKUP/RESTORE

Rule: backup/restore point discipline is milestone-based and required before risky structural work, not reflexive after every small docs task.

Source document: `OPC_v1_BACKUP_AND_RESTORE_POLICY.md`.

Still valid:
- yes

Conflict:
- Git workflow now adds public branch/commit verification, but does not replace local backup policy.

Recommendation: promote a sanitized backup/restore policy summary into public docs.

### ROLES / USERS

Rule: local roles are `ADMINISTRATOR` and `SAVETNIK`; local PIN/session model is not network identity.

Source document: `OPC_v1_ZAKLJUCANA_PRAVILA.md`, auth code, Web audit.

Still valid:
- yes

Conflict:
- future Web identity is undefined.

Recommendation: do not reuse local PIN users as Web accounts without a separate identity design.

### FIRMA SETTINGS

Rule: `FirmaPodaci` is local editable firm settings, singleton `id = 1`.

Source document: database identity audit, `firma_podaci_table.dart`.

Still valid:
- yes

Conflict:
- it is not a stable repository/firma identity.

Recommendation: owner must approve a separate repository/database-family identity model.

### ENTITLEMENTS / PACKAGES

Rule: packages are `osnovni`, `srednji`, `potpun`; package, role, build variant, and platform overlay must stay separate.

Source document: `OPC_v1_ZAKLJUCANA_PRAVILA.md`, `OPC_v1_PROJECT_FLOW_AND_DELTA.md`, entitlement code.

Still valid:
- yes

Conflict:
- code has `OpcEntitlementSourceKind.saas` as a future/source label while current product docs avoid SaaS as primary product model.

Recommendation: keep source enum as implementation detail; avoid product-level SaaS wording until owner decides.

### PDF / DERIVATIVES

Rule: PDFs are derivatives of PREDMET, not decision owners.

Source document: `OPC_v1_PROJECT_SOUL.md`, `OPC_v1_ZAKLJUCANA_PRAVILA.md`.

Still valid:
- yes

Conflict:
- RAČUN/PDF legal-production readiness is not final.

Recommendation: keep PDF output separate from legal/release readiness decisions.

### STANJE ROBE / STOCK

Rule: STANJE ROBE is operational, package/add-on gated, and must not become parallel PREDMET truth.

Source document: `OPC_v1_ZAKLJUCANA_PRAVILA.md`, project map, tests.

Still valid:
- yes

Conflict:
- full productization, procurement, movement history, and some JSON consequences remain incomplete/future.

Recommendation: treat current STANJE ROBE as reference operational layer, not finished stock product.

### CODEX OPERATING RULES

Rule: Codex must read applicable docs, keep scope narrow, avoid broad rewrite, report conflicts, and validate honestly.

Source document: `OPC_v1_CODEX_RULES.md`, `GIT_WORKFLOW_ARC.md`, manifest.

Still valid:
- yes

Conflict:
- public GitHub verification is newer and should be added to sanitized local rules.

Recommendation: merge the two process systems into one public continuity rule set.

### DO-NOT-TOUCH AREAS

Rule: do not alter PREDMET truth, JSON shape, schema/migrations, package/licence, auth/security, PDFs, or platform semantics without explicit task/gate.

Source document: repeated locked-rule entries in `OPC_v1_ZAKLJUCANA_PRAVILA.md`.

Still valid:
- yes

Conflict:
- none.

Recommendation: keep as standard pre-implementation gate.

### FUTURE WEB PRISTUP

Rule: future Web Pristup must preserve product identity, local-first ownership, and JSON/backup principles unless owner explicitly changes architecture.

Source document: manifest, Web audit, database identity audit, old SaaS-ready local docs.

Still valid:
- owner decision required for exact runtime/storage/sync model.

Conflict:
- old SaaS/multi-device wording is broader than current Web Pristup constraints.

Recommendation: no Web implementation before identity, storage, and data-ownership design are approved.

## Current source-of-truth hierarchy

Recommended hierarchy until owner revises it:

1. Owner decisions in current task/session.
2. `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`.
3. `docs/PRODUCT_DIRECTION.md` and `docs/ARCHITECTURE_OVERVIEW.md`.
4. `docs/GIT_WORKFLOW_ARC.md` and `docs/templates/OPC_TASK_TEMPLATE.md`.
5. Sanitized/public task reports after GH-aware handoff.
6. Local `SOURCE\PROJECT_DOCS` core set where not contradictory.
7. `PROJECT_MAP_OPC_v1.json` and summary as audit map only.
8. Restore point markers as history/evidence, not architecture specification.
9. Old root docs and old `C:\Projekti\OPC\SOURCE` docs as historical only.
10. Python-era docs as historical only.

## Inconsistencies and contradictions

Inconsistency 1: SaaS-ready vs Web Pristup wording.

Documents involved: local `PROJECT_DOCS`, manifest, `PRODUCT_DIRECTION.md`, Web audit.

Why it matters: SaaS implies business/hosting/payment/tenant assumptions that are not implemented.

Risk: premature central backend or central master database design.

Owner question: Should all future public docs replace primary "SaaS-ready" wording with "OPC Web Pristup-ready" while preserving old SaaS mentions as historical notes?

Recommended resolution: yes, unless owner explicitly wants SaaS as a business model term.

Inconsistency 2: "future multi-device sync" wording vs current no-sync local model.

Documents involved: local docs, manifest, Web audit.

Why it matters: sync is a major architecture, not a minor runtime feature.

Risk: whole-SQLite sync or silent conflict behavior.

Owner question: Is future sync required, or is manual JSON/backup transfer enough for the next local release?

Recommended resolution: keep sync out of scope until repository identity and command/event design are approved.

Inconsistency 3: local project docs are authoritative locally but hidden from GitHub.

Documents involved: local inventory report, `PROJECT_DOCS\00_README_KAKO_KORISTITI.md`, public docs.

Why it matters: Logos cannot verify rules it cannot see.

Risk: future tasks miss locked rules.

Owner question: Which local `PROJECT_DOCS` files may be sanitized and promoted to `docs/project/`?

Recommended resolution: promote core set after private/sensitive review.

Inconsistency 4: master `PROJECT_DOCS` vs `SOURCE\PROJECT_DOCS`.

Documents involved: both local folders.

Why it matters: three newer reports exist only under `SOURCE\PROJECT_DOCS`.

Risk: tasks may use stale master context.

Owner question: Should `SOURCE\PROJECT_DOCS` become the operational master for current Codex work, or should master be synchronized first?

Recommended resolution: synchronize through a dedicated docs task.

Inconsistency 5: `PROJECT_MAP_OPC_v1.json` is maintained but not public.

Documents involved: project map, local inventory report.

Why it matters: it contains module status and next-step claims.

Risk: map estimates can be misread as release readiness.

Owner question: Should the map be public as sanitized audit metadata, or remain local?

Recommended resolution: publish summary first; publish JSON only after owner review.

Inconsistency 6: database/firma identity is required conceptually but absent in code.

Documents involved: manifest, database identity audit, code.

Why it matters: local replica and Web Pristup plans need a stable database family identity.

Risk: cross-firm import/restore.

Owner question: Should `opcRepositoryId` identify one firm's database family across Windows/Android/Web replicas, while `installationId` identifies one device/browser instance?

Recommended resolution: yes, as next design task.

Inconsistency 7: `sourceIdentity = local_opc` sounds identity-like but is not unique.

Documents involved: code, database identity audit.

Why it matters: it can be mistaken for repository identity.

Risk: false safety in import/restore decisions.

Owner question: Should `sourceIdentity` remain legacy/source metadata and never be used as hard repository identity?

Recommended resolution: yes.

Inconsistency 8: full backup restore is destructive but not identity-aware.

Documents involved: code, database identity audit, backup policy.

Why it matters: user confirmation is generic, not source/current comparison.

Risk: wrong-firm restore.

Owner question: Should future full restore block mismatched repository identity by default?

Recommended resolution: yes, with owner-approved recovery exception.

Inconsistency 9: local PIN users are strong local access controls but not Web/network identity.

Documents involved: auth code, Web audit, local docs.

Why it matters: Web accounts require different security model.

Risk: unsafe mapping of local `ADMINISTRATOR`/`SAVETNIK` to remote accounts.

Owner question: Should Web Pristup identity be designed separately while preserving local role names?

Recommended resolution: yes.

Inconsistency 10: entitlement source enum contains `saas`.

Documents involved: entitlement code, product direction.

Why it matters: code label may leak into product language.

Risk: premature SaaS product semantics.

Owner question: Should code keep `saas` as internal future source label or later rename to `webPristup`/similar?

Recommended resolution: owner decision; no rename now.

Inconsistency 11: old Python-era docs and old source tree exist.

Documents involved: local inventory report.

Why it matters: they are historical but can confuse architecture.

Risk: obsolete assumptions entering current tasks.

Owner question: Should old Python-era and old-source docs be explicitly archived as non-authoritative?

Recommended resolution: yes.

Inconsistency 12: manifest does not include all standards from local locked docs.

Documents involved: manifest, `OPC_v1_ZAKLJUCANA_PRAVILA.md`, backup policy.

Why it matters: manifest is now the public gate.

Risk: public tasks pass while missing encoding, backup, or map-authority rules.

Owner question: Should the manifest be extended after sanitization to include backup, encoding, and map authority limits?

Recommended resolution: yes, in a docs-only follow-up.

## Terminology risks

- `SaaS-ready`: historical/future-readiness language; risky as primary product identity.
- `OPC Web Pristup`: preferred current future-access term.
- `sync`: should mean network synchronization only when explicitly scoped; local method names using "sync" are not network sync.
- `firma`: protected business concept; not equal to implemented tenant model.
- `databaseIdentity: OPC`: static product marker, not unique database identity.
- `sourceIdentity`: source metadata, not repository identity.
- `installationId`: per installation/device identity, not firm database family identity.
- `naručilac`/`narucilac`: protected; do not replace with `klijent`.
- `ADMINISTRATOR`/`SAVETNIK`: local role terms; future Web mapping requires design.

## OWNER DECISION QUEUE

### Product identity

1. Should public docs standardize future wording on `OPC Web Pristup` and avoid primary `SaaS` wording?
2. Is OPC Web Pristup a third runtime/access form of the same product, not a replacement for Windows/Android?
3. Should current local-first Windows/Android release work proceed independently of Web design?

### Terminology

4. Is `naručilac` the permanent canonical business term, with `klijent` forbidden as replacement?
5. Should internal code label `saas` remain as an entitlement source placeholder or be renamed later?
6. Should "repository/database family" be named `opcRepositoryId`, `databaseFamilyId`, or another owner-approved term?

### PREDMET and business flow

7. Does `PREDMET` remain the only master business truth in all future runtimes?
8. Should `brojPredmeta` remain the current business conflict key until a stable `predmetUid` is designed?
9. Should future `predmetUid` exist for cross-replica identity, separate from local DB `id`?

### Firma/database/repository identity

10. Should `opcRepositoryId` identify one firm's database family across all Windows/Android/Web replicas?
11. Should `installationId` remain per device/browser installation only?
12. Should editable `FirmaPodaci` fields be forbidden as hard import/restore identity guards?

### JSON import/export/restore

13. Should single-`PREDMET` JSON add backward-compatible repository metadata before Web work?
14. Should full backup JSON add repository id, export installation id, export time, record counts, and checksum?
15. Should mismatched repository restore be blocked by default?
16. Should same-firm/different-repository import be warning-only or blocked?

### Windows/Android parity

17. Must every future business-rule change have evidence that Windows and Android behavior stay equivalent?
18. Should platform-specific UX differences be documented per task when they affect workflow?

### Future OPC Web Pristup

19. Is browser-local database a required principle for Web Pristup?
20. Is a server allowed to store readable `PREDMET` data, or only opaque/metadata/sync envelopes?
21. Is offline browser operation required, optional, or out of scope for first Web spike?

### Packages/licence/entitlements

22. Are `osnovni`, `srednji`, and `potpun` final package names?
23. Should package entitlement be installation-level, firm-repository-level, or both?
24. Should Web Pristup package rules reuse current `OpcEntitlementPolicy` vocabulary?

### Backup/restore policy

25. Should local milestone backup/restore rules be promoted into public docs?
26. Should docs-only audit tasks require no backup unless explicitly requested?
27. Should every implementation milestone require a restore point marker?

### Security/privacy

28. Should data-at-rest encryption be considered for local Windows/Android databases?
29. Should Web Pristup require client-side encryption before any hosted coordinator stores data?
30. Should auth/security events get a separate audit log before release?

### Hosting/future access

31. Should hosting be limited initially to static app delivery plus licence/access metadata?
32. Should managed Postgres/Supabase/other PaaS be excluded from storing readable `PREDMET` until owner approves?
33. Should Cloud/VPS choice wait until identity and encryption decisions are complete?

### Release readiness

34. What is the minimum local Windows/Android release definition?
35. Must RAČUN/legal document readiness be separated from app technical readiness?
36. Which local `PROJECT_DOCS` files must be public before Logos can write the next architecture task?

## Standards and similar-project gap analysis

Gap 1: Repository/database-family identity.

Current evidence: no `repositoryId`, `databaseId`, or `firmaId`; `FirmaPodaci` is editable singleton; static `databaseIdentity: OPC`.

Standard expectation: stable immutable database-family id.

Risk: cross-firm import/restore.

Minimum acceptable correction: design and later implement repository identity table and JSON metadata.

Must fix before:
- Web spike

Gap 2: Installation/device/browser identity separation.

Current evidence: `OpcInstallationIdRepository` exists outside Drift.

Standard expectation: separate device identity from database family identity.

Risk: confusing licence device identity with business database identity.

Minimum acceptable correction: document semantics and guard against reuse.

Must fix before:
- Web spike

Gap 3: Import/export ownership metadata.

Current evidence: JSON has format/schema/source markers but no repository/firma guard.

Standard expectation: export origin metadata, source repository id, app/schema version, counts/checks.

Risk: wrong-source imports.

Minimum acceptable correction: identity metadata design with backward compatibility.

Must fix before:
- next local release if release includes broad customer transfer; otherwise Web spike

Gap 4: Destructive restore safety.

Current evidence: `ZAMENI SVE` confirmation exists, but no identity comparison.

Standard expectation: show current/incoming identity, firm display fields, counts, timestamp, and mismatch policy.

Risk: data loss.

Minimum acceptable correction: identity-aware restore UX.

Must fix before:
- next local release

Gap 5: Backup verification.

Current evidence: JSON tests exist; no checksum/signature for backup payload.

Standard expectation: integrity check and restore dry-run/validation path.

Risk: corrupt backup accepted or late failure.

Minimum acceptable correction: backup manifest/checksum design.

Must fix before:
- hosting/payment; preferably local release

Gap 6: Schema/version migration safety.

Current evidence: Drift schema version 17, migration tests exist.

Standard expectation: explicit migration matrix and destructive restore compatibility policy.

Risk: older backups or future schema imports fail incorrectly.

Minimum acceptable correction: release checklist with migration/backup compatibility cases.

Must fix before:
- next local release

Gap 7: Duplicate PREDMET handling.

Current evidence: duplicate handling by `brojPredmeta`; no stable cross-replica `predmetUid`.

Standard expectation: stable entity identity plus business-number conflict handling.

Risk: same number from different firm or different case causes wrong prompt.

Minimum acceptable correction: design stable `predmetUid` and repository id before sync/Web replicas.

Must fix before:
- Web spike

Gap 8: Audit log / local operation history.

Current evidence: `log_izmena` exists, but auth docs say auth/security events need separate audit log.

Standard expectation: separate business audit, auth/security audit, and possible future command journal.

Risk: incomplete accountability.

Minimum acceptable correction: audit-log scope decision.

Must fix before:
- payment/hosting

Gap 9: Role/session boundaries.

Current evidence: local session service, PIN hash, `ADMINISTRATOR`/`SAVETNIK`.

Standard expectation: documented role matrix and session/security policy.

Risk: Web/network account confusion.

Minimum acceptable correction: role matrix and Web identity separation.

Must fix before:
- Web spike

Gap 10: Package/entitlement integrity.

Current evidence: entitlement policy and local licence parser exist; production activation path still foundation.

Standard expectation: signed licences, fail-closed runtime, release checklist, no private keys in repo.

Risk: package boundaries not enforceable.

Minimum acceptable correction: production licence activation and key custody checklist.

Must fix before:
- payment/local release with packages

Gap 11: Privacy/security documentation.

Current evidence: public docs exclude real data; local docs mention secrets and recovery material.

Standard expectation: explicit privacy/security model for personal data, backups, exports, and support.

Risk: mishandled sensitive personal/business data.

Minimum acceptable correction: public privacy/security architecture note.

Must fix before:
- release readiness

Gap 12: Release readiness checklist.

Current evidence: project map says release/signing is not release approval evidence.

Standard expectation: build/signing/install/restore/smoke/release gate.

Risk: confusing green tests with release-ready product.

Minimum acceptable correction: release-readiness checklist doc.

Must fix before:
- next local release

Gap 13: Restore-point discipline.

Current evidence: strong local policy but not public.

Standard expectation: documented baseline for when backup/restore is required.

Risk: inconsistent future task requirements.

Minimum acceptable correction: sanitized public backup/restore workflow doc.

Must fix before:
- next implementation milestone

Gap 14: Test coverage risks.

Current evidence: JSON, entitlement, package downgrade, auth/widget smoke, STANJE ROBE tests exist.

Standard expectation: contract tests around extracted pure rules and release-critical import/restore cases.

Risk: refactor breaks behavior.

Minimum acceptable correction: contract-test plan before code extraction.

Must fix before:
- Web spike

Gap 15: Future Web browser storage risk.

Current evidence: no web runner, OPFS, IndexedDB, SQLite WASM, or storage adapter.

Standard expectation: browser persistence capability checks, backup prompts, quota/eviction diagnostics.

Risk: invisible data loss.

Minimum acceptable correction: Web storage risk design before any web runner implementation.

Must fix before:
- Web spike

## Technical/logical deficiencies

- No stable repository/database-family identity.
- No identity-aware JSON import/restore policy.
- No stable cross-database `PREDMET` uid.
- `sourceIdentity` and `databaseIdentity` can be misunderstood as stronger than they are.
- `FirmaPodaci` is editable settings, not tenant identity.
- Web/local-replica model is conceptually documented but not technically designed.
- Package/licence production path remains foundation.
- Large mixed-responsibility UI and JSON utility files remain a refactor risk.
- Local project continuity docs are not yet public/GitHub-verifiable.
- Mojibake appears in some displayed local/attachment text and should remain an encoding gate risk.

## Do-not-implement-yet list

- Web runner.
- Backend/API.
- Network sync.
- Hosting architecture.
- OPFS/IndexedDB/SQLite WASM adapter.
- Storage adapter.
- Payment/subscription.
- Central/master `PREDMET` database.
- Whole-SQLite sync.
- Tenant/organization membership.
- Network identity using current local PIN users.
- Business terminology rename.
- JSON shape change.
- Database migration.
- Package restructuring.
- Importing local `PROJECT_DOCS` wholesale without sanitization.

## Proposed ground-level milestone — owner review required

Milestone name:

- `OPC GROUND-LEVEL CONTINUITY AND IDENTITY BASELINE`

Purpose:

- Restore one coherent public/private source-of-truth set before any new architecture or implementation wave.

Non-negotiable rules:

- `PREDMET` remains the only master business truth.
- Windows/Android parity remains product identity.
- Current local database ownership remains intact.
- JSON transfer and full backup JSON are preserved.
- Web Pristup is future access/runtime work, not current implementation.
- No private/export/customer data is committed.

Required documents to promote into repo:

- sanitized `PROJECT_DOCS\00_README_KAKO_KORISTITI.md`
- sanitized `OPC_v1_PROJECT_SOUL.md`
- sanitized `OPC_v1_ZAKLJUCANA_PRAVILA.md`
- sanitized `OPC_v1_ARCHITECTURE_DECISIONS.md`
- sanitized `OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- sanitized `OPC_v1_CODEX_RULES.md`
- sanitized `OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- sanitized `PROJECT_MAP_OPC_v1_SUMMARY.md`

Required owner decisions:

- Web Pristup vs SaaS wording.
- repository/database-family identity term.
- identity mismatch restore/import policy.
- package/licence release scope.
- minimum local release readiness scope.

Required technical audits:

- repository identity and JSON metadata design audit.
- release readiness checklist audit.
- privacy/security and backup/restore public documentation audit.
- package/licence production path audit.

Required implementation blockers:

- no Web implementation until identity model is approved.
- no sync until repository identity and command/event strategy are approved.
- no payment until licence/package and privacy/security docs are approved.

Explicitly out of scope:

- code changes.
- migrations.
- Web runner/backend/sync.
- payment/subscription.
- source restructuring.

PASS conditions:

- owner approves source-of-truth hierarchy.
- local docs promotion list is accepted or revised.
- owner answers minimum identity/Web/package questions.
- next Codex task can be written from public GitHub-visible docs plus approved local exceptions.

NOT PASS conditions:

- unresolved SaaS/Web terminology controls architecture.
- future task starts from GitHub docs while ignoring local `PROJECT_DOCS`.
- implementation begins before repository identity/JSON safety decisions.
- private data is proposed for commit.

## Recommended next owner review session

Agenda:

1. Confirm project soul wording.
2. Decide Web Pristup vs SaaS terminology.
3. Decide repository/database-family identity term and purpose.
4. Decide whether `SOURCE\PROJECT_DOCS` or master `PROJECT_DOCS` is the current continuity source.
5. Approve which local docs may be sanitized into public repo.
6. Confirm that next technical work is identity/continuity design, not Web implementation.

## Recommended next Codex task after owner answers

Recommended next task:

- `OPC PROJECT_DOCS SANITIZED PUBLIC CONTINUITY INTEGRATION`

Task type:

- documentation/process integration only.

Scope:

- add owner-approved sanitized local continuity docs to public repo.
- add a public source-of-truth hierarchy.
- add explicit "historical/superseded" labels.
- do not change source code.

Second task after that:

- `OPC REPOSITORY IDENTITY AND JSON TRANSFER GUARD DESIGN AUDIT`

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes

If not compliant, classify:
- NOT PASS

## Final senior recommendation

Do not start Web, hosting, sync, payment, database migration, or broad refactor next.

The next safe step is owner review plus sanitized public continuity integration. After that, the next technical design should be repository/database-family identity and JSON transfer guard design. That path preserves the OPC soul while making future Web Pristup possible without turning OPC into a different product.

## PASS / NOT PASS:

PASS WITH OWNER DECISION QUEUE
