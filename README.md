# OPC — Organizator pogrebne ceremonije

OPC is a Flutter application for organizing funeral-ceremony business workflows. The same product is implemented for Windows and Android; neither platform is assigned a separate operational role.

This repository is the sanitized Git-visible source and engineering-documentation baseline used for controlled changes, review, and rollback. OPC is currently maintained through both this public GitHub repository and the local project environment; local runtime/evidence material is classified separately and is not automatically promoted or deleted. The repository intentionally excludes real case databases, customer or personal data, generated exports, credentials, local machine configuration, build artifacts, and other private runtime material.

Current OPC data is stored locally for each user/firma. A possible future OPC Web access model is documented as an additional runtime form for the same product logic, not as a replacement for Windows/Android parity and not as a server-master `PREDMET` database.

## Current documentation map

README is the repository entry point and navigation surface; it is not a
co-equal detailed content authority. The five substantive current OPC homes
are the only compact homes for live product meaning:

- [Product and domain authority](docs/OPC_PRODUCT_AND_DOMAIN.md)
- [Current architecture and deployment](docs/OPC_ARCHITECTURE.md)
- [Development and validation workflow](docs/OPC_DEVELOPMENT.md)
- [Quality and release guidance](docs/OPC_QUALITY_RELEASE.md)
- [Adopted OPC engineering profile](docs/OPC_ENGINEERING_PROFILE.md)

These five homes are authoritative by subject. Other documents below are
supporting evidence, transition records or historical provenance and must not
silently compete with them for materially mutable current state.

### Transition and supporting records
- [Phase 1 migration/authority manifest](docs/OPC_PHASE1_DOCUMENTATION_MIGRATION_AUTHORITY_MANIFEST.csv)
- [Phase 1 archive and internal-governance classification](docs/OPC_PHASE1_ARCHIVE_AND_INTERNAL_GOVERNANCE_CLASSIFICATION.md)
- [Internal development-control boundary register](docs/OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md) — boundary pointer only; local pseudocode remains outside the product documentation surface.
- [Phase 1 implementation report](docs/OPC_PHASE1_IMPLEMENTATION_REPORT.md) — transition evidence, not a competing current home.

Supporting authority and evidence:

- [Purpose and anti-drift manifest](docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md)
- [Product direction](docs/PRODUCT_DIRECTION.md)
- [Owner decision report](docs/OPC_OWNER_DECISION_REPORT.md)
- [Canonical terminology glossary](docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md)
- [Source-of-truth map](docs/OPC_SOURCE_OF_TRUTH_MAP.md)
- [Implementation stop-list](docs/OPC_IMPLEMENTATION_STOP_LIST.md)
- [Current development state](docs/OPC_CURRENT_DEVELOPMENT_STATE.md)
- [Architecture overview](docs/ARCHITECTURE_OVERVIEW.md)
- [Public visibility test](docs/LOGOS_ACCESS_TEST.md)

The authoritative pre-build rule is the successive validation and build
gate in [OPC Development](docs/OPC_DEVELOPMENT.md#6-validation-workflow):
`flutter analyze` must finish green before the complete `flutter test` starts,
and no Windows/Android build is accepted before both final green exits.

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
