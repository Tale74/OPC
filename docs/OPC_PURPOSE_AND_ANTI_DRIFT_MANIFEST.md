# OPC Purpose and Anti-Drift Manifest

This manifest is a mandatory project rule. Every OPC task must read it at task start and check compliance at task end.

Current owner authority begins with
`docs/OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md`. Pre-zero documents
are not current owner authority. Confirmed incidents remain permanent
anti-drift evidence in `docs/OPC_INCIDENT_AND_ANTI_DRIFT_REGISTER.md`.

Changed task reports are automatically checked by `scripts/validate_opc_manifest_gate.py` and the `OPC Manifest Gate` GitHub Actions workflow.

## 1. OPC Core Purpose

OPC is a simple, stable, reliable tool for organizing funeral ceremony cases through `PREDMET` as the central business truth, for a firm/user that owns its own OPC database.

## 2. Product Identity

OPC Windows, OPC Android, and future OPC Web are runtime forms of the same OPC product logic.

Forbidden drift:

```text
Windows = admin app
Android = field app
```

Platform differences may exist only because of OS, UI form, screen size, input model, packaging, platform APIs, or platform-specific implementation.

## 2.1 Current Native Access Policy — Owner Decision 2026-07-16

OPC permanently abandons `Osnovni` / `Srednji` / `Potpuni` packages as a
business and production policy. Every existing function and capability of the
native Windows and Android product is available to every native OPC user.

This is Stage 1 of a safe two-stage transition. Existing package, local-license
and entitlement payload/parser/bootstrap code remains temporarily present only
for compatibility, diagnostics and audit continuity. It must not restrict
native functionality and must not be rewritten to manufacture a false
`Potpuni` license. Stage 2 physical deletion is a separate future task, allowed
only after owner runtime validation.

Unrestricted native functionality does not bypass `ADMINISTRATOR` / `SAVETNIK`
permissions, PREDMET lifecycle rules, business prerequisites, operational
toggles, validation blockers or data-ownership rules. OPC Web remains a future
option; it is not implemented here and does not condition native architecture.

Earlier package matrices and licensing plans are historical evidence. They are
superseded as current product policy by this section.

## 3. PREDMET As Master Business Truth

`PREDMET` is the central business entity and master business truth.

Its meaning must not be changed by task scope, UI changes, export/import changes, Web planning, hosting, sync, payment, refactoring, or package/licence work.

PDF documents, JSON transfers, lists, statistics, reminders, and operational modules are derived from or organized around `PREDMET`. They must not replace it as the source of business truth.

## 4. User/Firma Ownership Of Database

The user/firma is the owner of its own OPC database.

Current and future principle:

```text
Each valid OPC instance may have a complete database.
No database is automatically central/master.
Valid databases of the same firm may be equal replicas and may replace one another through explicit user-controlled transfer/restore rules.
```

### 4.1 Canonical local database and migration policy — Owner Decision 2026-07-16

A database becomes canonical only through explicit user/owner designation, not
because it has a higher schema version. The current owner Windows runtime has
one explicitly designated canonical business database whose private local path
is recorded only in the controlled local runtime record, never in public
documentation. Test and migration-test copies are validation lanes and must
never replace or be merged into it automatically.

Every existing user's designated database remains that user's business truth
and is upgraded in place through supported, idempotent application migrations.
Deleting, resetting, or distributing a prepared replacement database is
forbidden. Backup-first copy validation and explicit owner authorization are
required before the current owner's live canonical upgrade. Active detail is in
`docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md`.

Server-side or hosted components must not be treated as owners of user/firma `PREDMET` data unless a future explicit owner-approved architecture changes that.

## 5. Local Windows/Android Model

The current Windows/Android local model must be preserved:

```text
- local Drift/SQLite database;
- single PREDMET JSON transfer;
- full database / backup JSON transfer;
- manual/user-controlled transfer;
- no mandatory network sync.
```

Future tasks must not weaken this model unless the owner explicitly approves a new release architecture.

## 6. Future OPC Web Model

OPC Web means the same OPC product logic through browser access, without locally installed OPC apps.

The browser loads the hosted OPC Web app.

The local OS is not decisive for functional operability.

The Web server hosts the app/access layer and may support licence/package/access/backup/transfer/signaling/mediation functions, but must not be assumed to be the master `PREDMET` database unless a future explicit owner-approved architecture changes that.

Do not describe the current or future product primarily as SaaS.

`OPC Web Pristup` is historical/supporting wording. The current canonical future runtime term is `OPC Web`.

## 7. Terminology Protection

Existing OPC terminology must be preserved.

Protected terms include:

```text
PREDMET
PLATILAC
FIRMA
ADMINISTRATOR
SAVETNIK
```

`NARUČILAC`/`narucilac` is a legacy name for the same business concept now
canonically presented as `PLATILAC`. Legacy DB/JSON compatibility may retain an
internal identifier, but new UI, PDF/DOCX and user documentation use
`PLATILAC`.

`Osnovni` / `Srednji` / `Potpuni` package terms are historical compatibility
evidence, not active current-product policy. Section 2.1 governs them.

`OSNOVNI PAKET` in the SCENARIO business model is a different concept. It is
an editable goods/services composition block applied by SCENARIO and is not a
licensing or entitlement package. Do not collapse these concepts because of
terminological similarity.

### 7.1 IRiU package-ordering invariant

The current business ordering invariant is:

```text
IRiU = ordered OSNOVNI PAKET
       -> ordered applied SCENARIO PAKET
       -> manual/unpredicted items
```

Package membership and the configured order inside each package are the
business authority. Package contents are editable and may differ by user,
scenario and time. Concrete item names, item counts, persisted `redosled`,
provenance, current source output and golden fixtures must not become a
replacement business authority. They may be technical evidence only.

Other new business terms may only be used if marked:

```text
PROPOSED TERM - NOT IMPLEMENTED - OWNER DECISION REQUIRED
```

Do not introduce `klijent` as a replacement for `PLATILAC`.

## 8. Mandatory Task-Start Manifest Invocation

Every future OPC task must begin with this block:

```text
OPC MANIFEST CHECK - TASK START

Manifest read:
- yes / no

Task class:
- audit / design / spike / implementation / documentation / release / cleanup

Core purpose preserved:
- yes / no / risk

PREDMET meaning affected:
- no / yes, explain

Database ownership affected:
- no / yes, explain

JSON transfer affected:
- no / yes, explain

Windows/Android parity affected:
- no / yes, explain

Future OPC Web affected:
- no / yes, explain

Terminology drift risk:
- no / yes, explain

Implementation allowed:
- yes / no

Required gate before implementation:
- none / repository identity / JSON safety / data ownership / platform parity / security / payment/legal / other
```

If `Manifest read` is `no`, the task must not proceed.

If any line is `risk` or `yes`, the task must either remain audit/design/spike or explicitly justify why implementation is safe.

## 9. Mandatory Task-End Manifest Compliance

Every future OPC task must end with this block:

```text
OPC MANIFEST COMPLIANCE - TASK END

Manifest compliance checked:
- yes / no

Core purpose preserved:
- yes / no

PREDMET meaning preserved:
- yes / no

Database ownership preserved:
- yes / no

Windows/Android parity preserved:
- yes / no

Existing JSON transfer preserved:
- yes / no

Terminology preserved:
- yes / no

OPC Web remains outside current implementation scope:
- yes / no

Source changes within scope:
- yes / no

If not compliant, classify:
- NOT PASS
```

PASS is not allowed unless this block is completed.

## 10. Mandatory Special Gates

### Successive Validation / Build Gate

Every source/test/generated/configuration change is governed by the single
authoritative procedure in
[`GIT_WORKFLOW_ARC.md`](GIT_WORKFLOW_ARC.md#authoritative-successive-validation-and-build-gate).
Analyze must conclusively PASS before the complete test suite starts; both must
conclusively PASS before any Windows or Android build. Parallel execution,
timeouts, hangs, incomplete logs, missing exit codes, and focused-only suites
cannot open the build gate.

### Data Ownership / Repository Identity Gate

Required when task scope touches:

```text
database
backup
restore
JSON import/export
Web
sync
hosting
browser storage
identity
firm membership
multi-device model
```

### Platform Parity Gate

Required when task scope touches:

```text
Windows/Android behavior
shared business logic
UI behavior that changes product meaning
platform-specific implementation
```

### Product Terminology Gate

Required when task scope touches:

```text
new screens
PDF/JSON labels
documentation
settings
roles
packages
business entities
```

### Payment / Access Gate

Required when task scope touches:

```text
licence
entitlements
osnovni/srednji/potpun
registration
subscription
payment
access activation
```

## 11. Codex And Logos Responsibility

Logos must write tasks with the manifest check included.

Codex must execute tasks with the manifest check included.

Neither Logos nor Codex may rely on memory instead of the manifest.

If the manifest conflicts with a task instruction, the conflict must be reported before implementation.

### 11.1 Mandatory owner confirmation gate

Before any OPC task proceeds beyond read-only preparation, both Logos and Codex
must record:

```text
TASK UNDERSTANDING CONFIRMATION
CONTINUITY ESTABLISHMENT CONFIRMATION
DOCUMENTATION READING CONFIRMATION
OWNER CONFIRMATION GATE - WAITING FOR EXPLICIT CONTINUE
```

The owner must explicitly approve continuation. Silence, model confidence,
task size, audit-only scope, documentation-only scope or a technical PASS is
not authorization. If Logos or Codex finds a misunderstanding, missing
continuity, authority conflict or technical premise promoted to business
truth, execution remains stopped until corrected and re-approved.

The same protocol applies to implementation, audit, documentation, release,
cleanup and tooling tasks. The protocol is a project control, not an optional
conversation convention.

## 12. GitHub-Aware Verification

Future OPC handoffs must include public GitHub branch, commit, and report/document links unless explicitly exempted.

A local-only handoff is provisional and not Logos-verified PASS.

The GitHub handoff must also expose the manifest gate result when the task changes reports under `docs/tasks/`.
