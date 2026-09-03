# OPC — Organizator pogrebne ceremonije

> **Documentation re-baseline boundary:** The active current documentation candidate is [`docs/current/OPC_AUTHORITY_MANIFEST.md`](docs/current/OPC_AUTHORITY_MANIFEST.md). This README and the legacy five-home documents below are retained for provenance/compatibility; their pre-cutover text must not override the re-baselined current surface.

OPC is a Flutter application for organizing funeral-ceremony business workflows. The same product is implemented for Windows and Android; neither platform is assigned a separate operational role.

This repository is the sanitized Git-visible source and engineering-documentation baseline used for controlled changes, review, and rollback. OPC is currently maintained through both this public GitHub repository and the local project environment; local runtime/evidence material is classified separately and is not automatically promoted or deleted. The repository intentionally excludes real case databases, customer or personal data, generated exports, credentials, local machine configuration, build artifacts, and other private runtime material.

Current OPC data is stored locally for each user/firma. A possible future OPC Web access model is documented as an additional runtime form for the same product logic, not as a replacement for Windows/Android parity and not as a server-master `PREDMET` database.

## Documentation map

The only active navigation path is:

`README` → `docs/current/OPC_AUTHORITY_MANIFEST.md` → `docs/current/*`

Read the current manifest first. It points to the current product/domain,
as-built architecture, development/engineering boundary, quality/evidence,
PODSETNIK contract, logical map, traceability and disposition documents.

The current validation boundary is recorded in
`docs/current/OPC_DEVELOPMENT_AND_ENGINEERING_BOUNDARY.md` and
`docs/current/OPC_QUALITY_RELEASE_AND_EVIDENCE.md`; no legacy document is
required to establish a current rule.

### Historical / provenance / compatibility — NOT CURRENT AUTHORITY

The former root five-home documents, the legacy source-of-truth map and the
legacy current-development report are retained only for historical/provenance
comparison. Their active copies carry explicit non-authority banners and their
pre-cutover snapshots are isolated under
`docs/archive/documentation-rebaseline/legacy-homes/`. They must not be used
to obtain current business, technical, runtime or release rules.

Direct OWNER decision records and historical reports remain evidence only
unless an applicable direct decision is identified by the current authority
traceability document. Internal pseudocode remains forensic technical
evidence, not product/business authority.

## Development

The project uses Flutter and Dart. From a configured Flutter environment:

```powershell
flutter pub get
flutter analyze
flutter test
```

These validation commands are successive, never parallel. Timeout, hang,
incomplete output, or a missing exit code is not PASS.

Platform packaging, signing, publishing, and installer generation require separate release procedures and are not part of the public baseline task.
