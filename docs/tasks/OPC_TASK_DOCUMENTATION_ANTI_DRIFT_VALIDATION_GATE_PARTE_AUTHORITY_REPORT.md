# OPC TASK — Documentation Anti-Drift Validation Gate and PARTE Authority Reconciliation

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no

Future Web Pristup affected:
- no

Terminology drift risk:
- yes, resolved by explicit current/historical/superseded classification

Implementation allowed:
- documentation only

Required gate before implementation:
- manifest enforcement / product terminology / documentation authority identity

## Identity and reason

- Branch: `task/OPC-KATALOG-OSNOVNE-KATEGORIJE-IRiU-AUDIT-IMPLEMENTATION`.
- Base: `c6fae079482097231f4513f683367d30f4e13f58`.
- Starting worktree: clean and tracking the same-named `origin` branch.
- Reason: prevent pre-validation builds and inconclusive command outcomes from
  being treated as PASS, and prevent earlier PARTE format/margin/completion
  cleanup rules from competing with the later locked retention policy.
- Boundary: documentation only; no Dart/Flutter source, test, generated source,
  schema/migration, build configuration, environment, signing, flavor, asset,
  or runtime behavior change.

## Validation/build gate authority

The single durable authority is
[`docs/GIT_WORKFLOW_ARC.md`](../GIT_WORKFLOW_ARC.md#authoritative-successive-validation-and-build-gate).
It requires the non-overlapping order `flutter analyze` -> complete
`flutter test` -> authorized build, with final successful exit evidence at each
gate. Timeout, hang, interruption, incomplete log, missing exit code and
focused-only testing do not open the build gate. Any governed source/config
change closes the gate and requires both checks again.

Short mandatory references were added to:

- `README.md`;
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`;
- `docs/templates/OPC_TASK_TEMPLATE.md`;
- `tools/windows_installer/README.md`;
- `tools/variant_packaging/README.md`;
- the existing local six-document authority member
  `PROJECT_DOCS/OPC_v1_CODEX_RULES.md`.

The rule is intentionally not duplicated in full outside the workflow master.

## PARTE authority reconciliation

The active locked authority remains `OPC-OD-STAGE1-UNRESTRICTED-PARTE-003`:

- page width and height are user-configurable physical inputs;
- horizontal and vertical margins are separate;
- completed preparation remains retained, reopenable, editable and
  reproducible;
- only explicit user action deletes retained preparation/app-owned
  reproducibility media;
- PDF remains the authoritative WYSIWYG output;
- DOCX remains an additional editable derivative;
- runtime, physical print and external-editor acceptance remain separate
  evidence and are not claimed here.

Contradictions found and reconciled without deleting history:

- owner guide section 8.5 fixed `224 × 170 mm`, one `5 mm` margin and completion
  cleanup: marked partially `SUPERSEDED` and linked to the later lock;
- owner decision index row `OPC-OD-PARTE-001`: changed from apparently current
  cleanup authority to partially superseded historical checkpoint;
- PARTE pseudocode sections 20-27 and the 2026-07-12 runtime checkpoint: retained
  but explicitly barred from current implementation authority for
  format/margins/retention;
- PARTE media audit measurements and unresolved options: retained as historical
  evidence with a superseding-policy banner;
- first PARTE implementation report: retained with a partial-supersession
  banner pointing to the later runtime-corrections report.

The later runtime-corrections report already separated its interrupted early
narrative from sections 22 onward and remains the implementation evidence for
the current policy.

## Pre-gate build wording correction

The KATALOG/IRiU report now calls the first Windows/Android outputs:

`SUPERSEDED PRE-GATE BUILD ARTIFACTS — NOT ACCEPTED FOR RUNTIME VALIDATION`

It preserves the historical event order and separately records the accepted
post-gate sequence: analyzer PASS, complete test PASS, Windows release PASS,
then Android release PASS.

## Consistency search classification

Searched terms include `224 × 170`, `224x170`, `5 mm`, completion cleanup,
temporary/app-owned deletion, completed-preparation availability, parallel
analyze/test, build before tests, `usable build outputs`, PAKETI, and parallel
business/test database wording.

- Current authority: configurable dimensions, separate margins, retained
  completion/reproducibility media, explicit deletion, PDF authority, optional
  DOCX, abandoned PAKETI production policy, and one PREDMET/canonical-database
  truth.
- Historical evidence: observed owner-reference DOCX dimensions; chronological
  build/task reports; old implementation details.
- Superseded: fixed production format/margin, automatic completion cleanup,
  completed-preparation dead end, native PAKETI production restrictions, and
  pre-gate artifact acceptance.
- Unrelated context: image pixel dimensions, temporary atomic-write cleanup,
  explicit reset of an unfinished preparation, and historical test-database
  diagnostics that do not claim parallel business authority.

Historical references are intentionally retained only where their status and
replacement authority are explicit. No unresolved authoritative contradiction
or new owner decision was found.

## Local/Git authority identity

The defined local six-document set was not expanded. Only its existing workflow
member `OPC_v1_CODEX_RULES.md` required the short current-gate notice. The
`SOURCE/PROJECT_DOCS` working copy and external local master copy are synchronized
byte-for-byte; final SHA-256 identity evidence is recorded in validation below.

## Documentation validation

- Manifest gate: PASS for every changed task report against base `c6fae079`.
- Documentation/reference and index check: PASS; all local Markdown targets in
  the changed Git documentation surface resolve.
- Contradiction search: PASS; remaining fixed-format/cleanup hits are directly
  classified as superseded or historical/unrelated evidence.
- PAKETI/database authority search: PASS; active hits state that PAKETI are
  abandoned and no test database is presented as parallel business truth.
- Privacy scan: PASS; no owner path, attachment path, credential, secret,
  private key, personal fixture, runtime media, or generated artifact entered
  the Git diff.
- `git diff --check`: PASS; CRLF conversion notices are not whitespace errors.
- Local/master SHA-256 identity: PASS, 6/6 defined authority pairs identical.
  Updated `OPC_v1_CODEX_RULES.md` SHA-256 in both locations:
  `42DAA9233B1467F124E94D98D08B27FC136F502A004BD7760255A1C6D6B6BB7B`.
- Changed production source/tests/build configuration: NO.
- Flutter analyze/test/build/runtime/print execution: NOT RUN; documentation-only
  boundary preserved.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes, documentation-only

If not compliant, classify:
- not applicable

## Final status

DOCUMENTATION ANTI-DRIFT CORRECTION PASS — VALIDATION GATE AND PARTE AUTHORITY ALIGNED.

PASS / NOT PASS:
- PASS

Commit/push identity and clean-worktree confirmation are recorded in the final
task handoff; merge to `main` is not performed.
