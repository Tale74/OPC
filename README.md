# OPC — Organizator pogrebne ceremonije

OPC is a Flutter application for organizing funeral-ceremony business workflows. The same product is implemented for Windows and Android; neither platform is assigned a separate operational role.

This repository is the sanitized public source baseline used for project continuity, controlled changes, review, and rollback. It intentionally excludes real case databases, customer or personal data, generated exports, credentials, local machine configuration, build artifacts, and other private runtime material.

Current OPC data is stored locally for each user. A possible future web/SaaS access model is documented as an additional access model for the same product logic, not as a replacement for Windows/Android parity.

See:

- [Product direction](docs/PRODUCT_DIRECTION.md)
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
