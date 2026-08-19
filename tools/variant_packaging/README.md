# Variant Packaging Lane

Any manual build that follows workspace preparation is blocked until the
authoritative [successive validation gate](../../docs/OPC_DEVELOPMENT.md#6-validation-workflow)
has conclusively passed. Analyze and the complete test suite are successive,
never parallel; a timeout or incomplete result does not open the build gate.

Main [`pubspec.yaml`](../../pubspec.yaml) is production-safe by default and excludes full catalog photo assets from normal packaging.

Full-photo test packaging must use:

- `pubspec.full_catalog_test.yaml`
- [`prepare_variant_workspace.ps1`](prepare_variant_workspace.ps1)

Intended variants:

- production: `PRODUCTION`
- production Windows: `WINDOWS`
- test Android: `ANDROID_TEST`
- test Windows: `WINDOWS_TEST`

The helper script only prepares a staged workspace for explicit test packaging.

It does not run Flutter, Dart, Gradle, analyze, test, build, pub get, format, or codegen commands.

Manual build commands must be run by the user from the correct workspace:

- main source root for production/default packaging
- staged workspace for explicit full-photo test packaging
