# OPC SCENARIO MAP 1008 — Golden Consistency Gate

## Scope and provenance

This task adds a permanent, independent owner-map oracle for all canonical `MAP_*` definitions. The authoritative source is:

`C:\Projekti\OPC\OPC v.1\SCENARIO_MAP\Vlasnicka_definicija_logicke_SCENARIO_mape_KONACNA.md`

Source SHA-256: `663F104F01C8ABFABAF5DEDF8C82185AF03FDEF31B403DFB7D4E2EFBF0E061E4`.

The committed fixture is `test/fixtures/scenario/scenario_map_owner_golden.json`. It records the source name/hash, fixture format version, all eight normalized axes, ordered stable item IDs, item statuses, and BIOHAZARD markers. It contains exactly 1,008 scenarios. Fixture SHA-256: `EDFC581299EF5AA080D5426F4D490EAE359A9D2F9A40A1C194332AF5F8F291FB`.

Regenerate it with the independent Markdown extractor:

```text
dart run tool/generate_scenario_owner_golden_fixture.dart --source "C:\Projekti\OPC\OPC v.1\SCENARIO_MAP\Vlasnicka_definicija_logicke_SCENARIO_mape_KONACNA.md" --output "test/fixtures/scenario/scenario_map_owner_golden.json"
```

The extractor parses owner Markdown directly and never imports or calls the production scenario generator. This prevents circular validation.

Branch: `task/OPC-SCENARIO-MAP-1008-GOLDEN-CONSISTENCY-GATE`.

Baseline before this task: `1adb1ddb1849a73617fd676023d2e797aa6de93d` (legacy-path surgical-removal commit). The final commit SHA is the SHA reported by the git handoff for this report.

## Root causes corrected

The first independent exact run found 416 mismatching scenarios, all in the shared burial/international rule path. No owner-document conflict was found.

The kernel was corrected at the common rule point to match the owner map:

- international non-cremation cases receive `LIMENI_ULOZAK`; `LEMOVANJE` is omitted only for the BOLNICA JKP exception;
- ZARAZNA and NEDEFINISANA non-DOČEK cases receive the owner-required metal package even for `GROB`;
- local international `GROB` keeps `PREVOZ_SPROVODA` before the metal package where prescribed by the owner order, while biohazard ordering remains owner-specific;
- GROBNICA/local/GRADSKO status resolution remains distinct from GROB and BOLNICA, including required versus recommended status.

The stale critical-policy test was updated to preserve the NASILNA GROB guard while explicitly asserting the owner-required ZARAZNA/NEDEFINISANA package.

## Validation results

Commands were run with `--no-pub`; no build or packaging command was run.

| Gate | Result |
|---|---|
| Owner Markdown extractor | PASS — 1,008 parsed; duplicate/unknown-axis/item checks enabled |
| Fixture structure/provenance | PASS |
| Canonical kernel exact comparison | PASS — 1,008/1,008 |
| Seeded `ScenarioModuleRepository` comparison | PASS — 1,008/1,008 |
| Exact mismatches | 0 |
| Missing items | 0 |
| Extra items | 0 |
| Order mismatches | 0 |
| Status mismatches | 0 |
| Duplicate full keys | 0 |
| Unresolved KATALOG stable IDs | 0 |
| `flutter analyze --no-pub` | PASS — no issues found |
| Targeted tests | PASS — golden, critical IRIU, repository/migration tests |
| Full Flutter test | NOT RUN — targeted validation was sufficient for this task window |

The golden test also asserts the global restrictions: cremation axis normalization and international prohibition, DOČEK semantics, BOLNICA exclusions, local funeral transport, international transport replacement, OPELO terminal ordering, protective-equipment adjacency, unique item IDs, and BIOHAZARD markers.

The repository test covers realistic migration behavior: canonical records may be repaired when they match the known system fingerprint, while a user-edited MAP definition remains untouched and repeated migration is idempotent. The known NASILNA/GROBNICA regression is retained and is covered by both the exact 1,008 gate and the named repository regression.

## Verdicts

- `OWNER MAP PARSE — PASS`
- `OWNER SCENARIO COUNT 1008 — PASS`
- `UNIQUE FULL KEYS 1008 — PASS`
- `1008 EXACT GOLDEN CONTENT MATCH — PASS`
- `ITEM ORDER CONSISTENCY — PASS`
- `ITEM STATUS CONSISTENCY — PASS`
- `KATALOG ID RESOLUTION — PASS`
- `KNOWN NASILNA/GROBNICA REGRESSION — PASS`
- `GLOBAL SCENARIO INVARIANTS — PASS`
- `USER-EDITED MAP PRESERVATION — PASS`
- `REALISTIC MIGRATION CONSISTENCY — PASS`
- `FLUTTER ANALYZE — PASS`
- `TARGETED TESTS — PASS`
- `FULL FLUTTER TEST — NOT RUN`
- `BUILD — NOT RUN BY OWNER DECISION`
- `WINDOWS RUNTIME — DEFERRED TO CUMULATIVE BUILD`
