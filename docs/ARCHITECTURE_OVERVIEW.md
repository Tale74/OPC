# OPC Architecture Overview

This document describes the source as observed at the public baseline. It does not prescribe architecture that is not present.

## Runtime and platforms

OPC is one Flutter/Dart project with checked-in platform runners for:

- Windows under `windows/`;
- Android under `android/`.

The application entry point is `lib/main.dart`. It initializes Flutter, desktop window handling where applicable, Serbian date formatting, and a Drift-backed `AppDatabase`, then starts `OpcApp`.

## Application structure

The Dart source is organized under `lib/`:

- `core/` contains shared catalog identity, configuration, constants, Drift database code, entitlements, formatting, installation identity, JSON transfer, theme, and utilities.
- `features/auth/` contains authentication, session, PIN/recovery, and user-management code.
- `features/predmeti/` contains case workflows, repositories, business-policy/core rules, IRiU logic, reminders, statistics, presentation, and PDF exports.
- `features/podesavanja/` contains settings, company/catalog configuration, and payment QR support.
- `features/stanje_robe/` contains inventory state and consequence handling.
- `features/setup/` contains setup-readiness logic.

The UI uses Flutter Material components. `lib/app.dart` composes repositories and session services and routes between first-run, authentication, forced-PIN-change, and case-list flows.

## Persistence

Persistence uses Drift over SQLite. The schema is declared in `lib/core/database/` and feature table files, with generated Drift code checked into the source baseline. At baseline inspection the application reports schema version 17 and contains incremental migration/compatibility logic.

Runtime SQLite files are local user data and are explicitly excluded from Git.

## Documents, exports, and assets

The source contains PDF export implementations for case-related documents and JSON import/export logic. Generated documents and import/export payloads are not repository source and are excluded.

The production `pubspec.yaml` bundles symbols and fonts. A larger local catalog-photo set exists but is excluded from the public baseline because its public redistribution status is uncertain.

## Tests and tools

The `test/` directory contains unit, regression, migration, and widget smoke tests. `tools/` contains variant-workspace and Windows-installer preparation utilities. Generated installer output is excluded.

## Current boundaries and uncertainty

Most domain, persistence, and presentation code currently lives in the same Flutter package. There is no observed separate shared package or web service. Future extraction may be possible, but its exact boundary is not yet established and should not be invented in this baseline.

Licensing/entitlement code is present under `lib/core/entitlements/`; no private signing material or customer license data is part of the public baseline.
