# IRiU Package-Authority Display Ordering Implementation Report

## Task and authority

This bounded implementation follows the approved generic invariant:

```text
ordered OSNOVNI PAKET
  -> ordered applied SCENARIO PAKET
  -> manual/unpredicted items
```

Package membership and the configured order inside the applicable package are
the only business ordering authority. Package contents and sizes remain
editable. Concrete item names, counts, persisted `redosled`, row IDs,
provenance sequence, current output and historical/golden fixtures are not
business authority.

`OSNOVNI PAKET` in this report is the editable SCENARIO composition block. It
is unrelated to the abandoned licensing/entitlement labels
`Osnovni/Srednji/Potpuni`.

## Proven production path and root cause

The Windows and Android table share the repository projection:

```text
PredmetScreen -> IriuSegment -> IriuRepository.watchIriu/getIriu
  -> _orderedProjection -> _orderingContext
  -> IriuOrderingService.orderedRows -> IriuRowTile
```

The old service first partitioned rows using hard-coded category knowledge and
technical metadata, then allowed persisted `redosled`/business fallbacks to
decide relative order. The repository also read the ordered OSNOVNI JSON as a
`Set`, losing configured order. This made stale historical rank and concrete
category lists capable of overriding editable package configuration.

## Implemented projection

- `ScenarioModuleRepository` preserves the caller-provided ordered OSNOVNI
  package JSON and exposes `readOsnovniPaketOrder`; the former universal
  concrete-category sequence was removed.
- `IriuRepository._orderingContext` maps the current ordered OSNOVNI module
  package to configured ordinal values. For an applied snapshot it takes
  SCENARIO membership and configured section/order metadata from the active,
  unsuppressed consequences. Snapshot membership remains historical input; no
  snapshot or canonical row is rewritten.
- `IriuOrderingService` creates exactly three display partitions. A row is in
  OSNOVNI or SCENARIO only when current package membership (or an equivalent
  package set supplied by the context) says so. A row outside both packages is
  manual/unpredicted, even when `scenarioUpravlja` or provenance metadata is
  present. Package rows sort by configured package order; duplicate/missing
  ordinals use deterministic ID tie handling and never promote `redosled`.
  Manual rows retain their existing deterministic relative `redosled`/ID order
  only inside the final partition.
- No KATALOG, price, quantity, status, package membership, assignment,
  provenance, snapshot, schema, or canonical database data was changed by this
  display correction.

The existing lifecycle method that can persist `redosled` after an explicit
row mutation remains outside the read projection; opening/displaying IRiU does
not rewrite historical rows.

## Tests and authority classification

Ordering fixtures that encoded the old concrete list or persisted-rank output
are characterization evidence only. They were adjusted so configured package
maps, rather than the fixture list, establish acceptance.

Focused owner-authority tests now cover:

1. arbitrary OSNOVNI/SCENARIO membership and configured orders overriding stale
   persisted rank;
2. changing OSNOVNI order without code changes;
3. changing SCENARIO order without code changes;
4. different package sizes;
5. manual/unpredicted final partition, including a scenario-flagged row outside
   both packages;
6. ordered OSNOVNI package persistence/readback without concrete universal
   ordering.

## Validation

- Targeted ordering/repository tests: PASS.
- `flutter analyze`: PASS, no issues.
- Complete machine-readable Flutter suite, `--concurrency=1`: PASS;
  `done.success=True`, 499 tests completed, 0 failures, 9 skipped.
- Final Windows release: PASS — `build/windows/x64/runner/Release/OPC.exe`.
- Final Android release: PASS — `build/app/outputs/flutter-apk/app-release.apk`.
- Disposable Windows-test runtime: PASS — the `WINDOWS_TEST` debug executable
  started and remained alive for 10 seconds, then was explicitly stopped. It
  uses the separate `opc_v4_windows_test` lane; no production database was
  opened for this smoke check. SHA-256 of the test executable:
  `548734577CC3C651907D83FD92D90172830F9E5874D31C3C391C69EAFC883F3E`.
- Final release artifact SHA-256: Windows `OPC.exe`
  `DCB784346DA415ED19FE6AD458E5917A1E83F5F58F2363A8400E68F1F5115A7C`;
  Android `app-release.apk`
  `DCE63565CB1761BE4CD266A3A3D8465B9F4EDEEBADE89B120FAB6FA882CBA96F`.
- No customer/canonical database or runtime payload is committed.

## Deliberately not touched

No SCENARIO no-op repair, derivative document ordering expansion, canonical
database migration/rewrite, historical row normalization, UI package editor
redesign, licensing/entitlement policy, or concrete item golden order was
introduced. The known startup mutation debt remains separate and deferred.
