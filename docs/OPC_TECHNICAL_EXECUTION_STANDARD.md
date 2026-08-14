# OPC Technical Execution Standard

**Status:** active post-zero technical/governance standard

**Scope:** all OPC audit, documentation, design, implementation, release and
cleanup tasks

This standard is subordinate to current post-zero owner authority. It governs
how technical work is prepared, evidenced and handed off; it does not create
business policy.

## 1. Authority and task control

- Luna is currently used because the Sol token budget is exhausted; model
  selection does not change owner authority.
- Owner business decisions are locked. A technical premise must be
  source-verified before it is used.
- No patchwork, speculative refactor or broad rewrite is allowed. Prove the
  production caller path and the smallest evidence-backed change first.
- Current-state documents and the post-zero authority hierarchy outrank a
  latest-report-only interpretation.
- Every task must complete the Logos/Codex owner confirmation gate before
  substantive execution.
- Logos reviews the actual report, source and evidence links, not a completion
  summary alone.
- A task that discovers an authority conflict stops implementation and records
  the conflict instead of averaging incompatible sources.

## 2. Business truth boundaries

- `PREDMET` is the single business truth.
- IRiU presentation follows the generic invariant:

  ```text
  ordered OSNOVNI PAKET
    -> ordered applied SCENARIO PAKET
    -> manual/unpredicted items
  ```

- Package contents are editable. Package membership and configured order inside
  each package are authoritative; concrete names, counts, persisted order,
  provenance, source output and golden fixtures are not.
- User deletion is final within its authorized scope. Do not preserve an
  ownerless orphan merely because it is technically convenient.
- Historical PREDMET snapshots, applied prices and other protected business
  snapshots are immune to later KATALOG edits.
- A display defect is not automatically historical business truth. Verify the
  authority level and the actual artifact before changing stored data.
- The canonical database is protected. Risky data work is repaired/forensic-
  copy-first, with hashes, counts, integrity checks and explicit promotion.

## 3. Production-path proof

Before an implementation change, identify the real production caller path,
database lane, platform and artifact. A unit or repository test that bypasses
the production caller is evidence of that test path only.

## 4. Validation sequence

Use the following order for source/test/generated/configuration work:

```text
targeted tests
  -> analyzer
  -> complete machine-readable test suite
  -> final Windows/Android builds
  -> disposable runtime checks
```

- Only one heavy Flutter/Dart/Gradle/Java process runs at a time.
- Use `--concurrency=1` where applicable.
- Child processes must exit before the next heavy process begins.
- No final build before complete-suite PASS.
- A diagnostic build is not a final acceptance build.
- A timeout, hang, interruption, missing final summary or artificial timeout is
  not PASS.
- For Flutter JSON output, the final machine-readable `done.success` and
  failed-test count are authoritative over a misleading shell exit code.
- Never treat a focused suite as a replacement for the complete suite.
- Documentation-only tasks must not run Flutter tests or builds unless their
  scope explicitly changes executable artifacts.

## 5. Artifact, runtime and Git evidence

- Installed artifact identity must be proven against the release artifact by
  hash or equivalent byte identity.
- Runtime evidence must record artifact identity, date/time, branch/SHA and DB
  lane where relevant.
- Every runtime artifact is classified as `CURRENT BUILD EVIDENCE`,
  `HISTORICAL EVIDENCE` or `UNVERIFIED AGE / ARTIFACT IDENTITY` before use.
  Presence in `RUNTIME` does not imply currentness.
- Clean backup and clean restore are separate evidence claims.
- Git public visibility must be independently verified, including
  `git ls-remote` proof where network access is available.
- A local-only handoff is provisional until the public branch, commit and
  report are reachable.
- Never include canonical databases, customer data, credentials, exports,
  logs, signing material or machine-local configuration in the public tree.

## 6. Test authority

> A test may prove that code matches an expected result. A test must never
> establish or retroactively authorize the business expected result.

Every business-facing golden fixture must identify the exact owner/business
authority, package/rule/version and reason its expectation is valid. If the
expectation comes only from code, a technical report, a screenshot without
authority, a model inference or an inherited fixture, classify it as:

```text
CHARACTERIZATION ONLY — NOT BUSINESS ACCEPTANCE
```

## 7. Known technical debt (recorded, not implemented here)

`SCENARIO no-op repair/write defect` follows:

```text
IriuSegment.initState
  -> _runScenarioSync
  -> ScenarioModuleRepository.ensureModuleAndDefaults()
  -> _ensureOwnerMapDefinitions()
  -> _repairKnownOwnerMapProtectiveEquipmentGap()
```

Thirty-six legitimate `MAP_NASILNA_BOLNICA_*` definitions are treated as
repair candidates. Their business payload is unchanged while only
`scenario_definitions.updated_at` is rewritten. A future correction must
compare the full persisted business-relevant payload, skip semantic no-ops,
preserve genuine legacy repair and protect user-edited definitions.

## 8. Public engineering backlog (documentation only)

These are external practices to evaluate later, not current implementation
authorization:

- Use Flutter's unit/widget/integration test layering and keep end-to-end tests
  tied to real production flows: <https://docs.flutter.dev/testing/overview>.
- Use Flutter integration-test guidance for device/desktop runtime evidence:
  <https://docs.flutter.dev/testing/integration-tests>.
- Treat Dart isolates as separate-state concurrency boundaries and avoid
  unnecessary shared mutable state: <https://dart.dev/language/concurrency>.
- Use SQLite transaction and atomic-commit semantics explicitly when designing
  future migrations or recovery work:
  <https://sqlite.org/lang_transaction.html>.
- Review Drift's transaction/migration guidance before any future schema or
  persistence change: <https://drift.simonbinder.eu/dart_api/transactions/>.

The backlog is separate from OPC owner rules. No source refactor, migration or
dependency change is authorized by this section.

## 9. Mandatory handoff

Every task handoff records:

```text
Task
Branch
Base commit
Final commit
Public GitHub branch/commit/report links
Changed files
Diff stat
Tests/checks/builds and honest skipped results
Not touched
Known risks
PASS / NOT PASS
```

The manifest end-compliance block, owner-gate end check and implementation
resume gate are mandatory. A task is not PASS if those records are missing.
