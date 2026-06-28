# OPC — Organizator pogrebne ceremonije

OPC is a Flutter application for organizing funeral-ceremony business workflows. The same product is implemented for Windows and Android; neither platform is assigned a separate operational role.

This repository is the sanitized public source baseline used for project continuity, controlled changes, review, and rollback. It intentionally excludes real case databases, customer or personal data, generated exports, credentials, local machine configuration, build artifacts, and other private runtime material.

Current OPC data is stored locally for each user/firma. A possible future OPC Web access model is documented as an additional runtime form for the same product logic, not as a replacement for Windows/Android parity and not as a server-master `PREDMET` database.

See:

- [Purpose and anti-drift manifest](docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md)
- [Product direction](docs/PRODUCT_DIRECTION.md)
- [Owner decision report](docs/OPC_OWNER_DECISION_REPORT.md)
- [Canonical terminology glossary](docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md)
- [Source-of-truth map](docs/OPC_SOURCE_OF_TRUTH_MAP.md)
- [Implementation stop-list](docs/OPC_IMPLEMENTATION_STOP_LIST.md)
- [Current development state](docs/OPC_CURRENT_DEVELOPMENT_STATE.md)
- [Architecture overview](docs/ARCHITECTURE_OVERVIEW.md)
- [Git and ARC workflow](docs/GIT_WORKFLOW_ARC.md)
- [Public visibility test](docs/LOGOS_ACCESS_TEST.md)

## Development

The project uses Flutter and Dart. From a configured Flutter environment:

```powershell
flutter pub get
flutter analyze
flutter test
```

Platform packaging, signing, publishing, and installer generation require separate release procedures and are not part of the public baseline task.
