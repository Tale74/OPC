# OPC Purpose and Anti-Drift Manifest

This manifest is a mandatory project rule. Every OPC task must read it at task start and check compliance at task end.

Changed task reports are automatically checked by `scripts/validate_opc_manifest_gate.py` and the `OPC Manifest Gate` GitHub Actions workflow.

## 1. OPC Core Purpose

OPC is a simple, stable, reliable tool for organizing funeral ceremony cases through `PREDMET` as the central business truth, for a firm/user that owns its own OPC database.

## 2. Product Identity

OPC Windows, OPC Android, and future OPC Web Pristup are runtime forms of the same OPC product logic.

Forbidden drift:

```text
Windows = admin app
Android = field app
```

Platform differences may exist only because of OS, UI form, screen size, input model, packaging, platform APIs, or platform-specific implementation.

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

## 6. Future OPC Web Pristup Model

OPC Web Pristup means the same local-replica OPC model through browser access, without locally installed OPC apps.

The browser loads the hosted OPC Web app.

The local OS is not decisive for functional operability.

The Web server hosts the app/access layer and may support licence/package/access/backup/transfer functions, but must not be assumed to be the master `PREDMET` database unless a future explicit owner-approved architecture changes that.

Do not describe the current or future product primarily as SaaS.

## 7. Terminology Protection

Existing OPC terminology must be preserved.

Protected terms include:

```text
PREDMET
narucilac
firma
ADMINISTRATOR
SAVETNIK
osnovni
srednji
potpun
```

New terms may only be used if marked:

```text
PROPOSED TERM - NOT IMPLEMENTED - OWNER DECISION REQUIRED
```

Do not introduce `klijent` as a replacement for `narucilac`.

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

Future Web Pristup affected:
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

Future Web Pristup not blocked:
- yes / no

Source changes within scope:
- yes / no

If not compliant, classify:
- NOT PASS
```

PASS is not allowed unless this block is completed.

## 10. Mandatory Special Gates

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

## 12. GitHub-Aware Verification

Future OPC handoffs must include public GitHub branch, commit, and report/document links unless explicitly exempted.

A local-only handoff is provisional and not Logos-verified PASS.

The GitHub handoff must also expose the manifest gate result when the task changes reports under `docs/tasks/`.
