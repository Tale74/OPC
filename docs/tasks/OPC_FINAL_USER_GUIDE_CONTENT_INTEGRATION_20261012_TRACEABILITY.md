# Final user-guide content integration — 2026-10-12

## Authority and scope

The OWNER-approved editorial input is the consolidated 33-chapter document
`OPC_RAD_U_APLIKACIJI_KONSOLIDOVANI_PREDLOG_33_POGLAVLJA.md`. The offline
resource remains `assets/opc_user_guide.json`; the full-screen and contextual
help continue to use this single resource and all existing stable chapter IDs
and routes. The later OWNER decision applies italic styling to all guide text,
including chapter and section headings.

The task adds no database, schema, authentication, transfer, business-rule,
SCENARIO execution, PREDMET lifecycle, route or chapter-ID change. It performs
no physical runtime.

## Bounded content/source reconciliation

- The inappropriate phrase `naloge ljudi` is replaced by `naloge osoba` in
  the `settings.users` chapter; no global replacement is used.
- The first-launch text retains the security-code recovery explanation but
  removes the unsupported claim that the database must be deleted if the
  code is unavailable. Current `ForgotPinRecoveryDialog._buildContent` directs
  the user to an administrator or service support when recovery is not
  configured; `AuthRepository.oporaviAdministratorPristup` requires configured
  installation recovery material and a valid code before issuing a temporary
  PIN.
- The OWNER's eight-segment description is scoped to eight business-data
  entry segments. The current `PredmetScreen._predmetSectionInfos` has ten
  numbered sections; the last two are `DOKUMENTI` and `PREGLED I POTVRDA`,
  described separately as document-preparation and final-review sections.
- The `predmet.roba_i_usluge` chapter explains the OSNOVNI PAKET, condition-
  dependent additional SCENARIO packages, selection of concrete catalog
  articles by the user, and manual/unrelated row preservation. It notes that
  changed SCENARIO inputs can present a reconciliation preview and individual
  keep/remove decisions. The implementation remains unchanged.

The source basis includes `PredmetiRepository.inicijalizujIriu`,
`IriuSegment._reconcileOnOpen` / `_runScenarioSync`,
`PredmetScreen._predmetSectionInfos`,
`ForgotPinRecoveryDialog._buildContent`, `AuthRepository`
`imaPodesenSigurnosniKod` / `oporaviAdministratorPristup`, and current
SCENARIO/IRiU lifecycle and manual-row regression tests.

## Presentation

All rendered text in `OpcGuideScreen`, including the title, chapter navigation,
chapter/section headings, paragraph text, picker entries and labels, and
chapter chips, uses italic styling. App-level contextual help actions and
underlying screens retain their existing routing and behavior.

## Requirements and engineering-profile impact

- Product/domain meaning: no new business policy; owner-approved prose is
  reconciled to the existing PREDMET, KATALOG and SCENARIO boundaries.
- Requirements/traceability: chapter IDs/order and existing contextual
  mappings are preserved; terminology, PIN, segment-count and SCENARIO facts
  are explicitly covered in guide tests.
- Architecture/data contracts: one bundled offline JSON resource; no contract,
  schema, persistence, dependency or platform responsibility change.
- Implementation/compatibility: rendering-only italic style and the bounded
  content corrections apply across Windows, Android Narrow and Android Wide;
  no layout or route change is intended.
- Verification/acceptance: focused guide regressions, serial analyzer, serial
  full suite and Windows/Android production release builds are required by the
  task. These do not constitute physical runtime acceptance.
- Quality/release: external review evidence is canonical and excludes private
  PREDMET data, credentials, operational databases and release binaries.
- Current-state reconciliation: this record, `OPC_ARCHITECTURE.md`,
  `OPC_SOURCE_OF_TRUTH_MAP.md` and `OPC_CURRENT_DEVELOPMENT_STATE.md` record the
  final authority, implementation and verified QA/build state.

## Validation and package

## QA and build evidence — 2026-10-12

The focused guide test passed `7/7` after correcting its own nullable style
inspection and removing an unnecessary import. The timestamped final serial
analyzer command `flutter analyze --no-pub` exited `0` with `No issues found!`
in 15.8 seconds; exact UTC interval: `2026-10-12T22:07:04.0677909Z` to
`2026-10-12T22:07:23.5539217Z`.

The first full-suite run with Flutter's default 30-second per-test timeout
completed `661 PASS / 9 SKIP / 2 FAIL`; both failures were test-framework
timeouts in existing migration setup paths, not assertion failures. Isolated
runs passed the RAČUN schema-35 migration case in 55 seconds and the SCENARIO
clean-start idempotency case in 46 seconds. The complete suite was then rerun
serially as
`flutter test --no-pub --concurrency=1 --timeout 2m` and exited `0`:
`663 PASS / 9 SKIP / 0 FAIL` in 22:49.9. Exact UTC interval:
`2026-10-12T22:07:35.0970405Z` to `2026-10-12T22:30:25.0152830Z`. The
two-minute value is the per-test threshold selected from those isolated
observations, not a process timeout. The nine skips are existing explicitly
environment-, forensic- or copy-gated tests; none was counted as passed.

The final timestamped Windows command `flutter build windows --release --no-pub`
exited `0` in 64.4 seconds; exact UTC interval:
`2026-10-12T22:30:32.0263118Z` to `2026-10-12T22:31:36.3943827Z`.
`build/windows/x64/runner/Release/data/app.so` is 13,140,912
bytes, SHA-256
`F7A1FD9A0634523E105C6EF3C306CAFD5AA8F18D3B6FB92C962251A4CDC70C04`.
`OPC.exe` is 89,600 bytes, SHA-256
`E6C2805D1F99621DDA30260B916289AF8CF3A1115BD7B28C80B13A0C5F830BAD`; the
runner binary is unchanged while Flutter application payload was rebuilt.

The final timestamped Android command
`flutter build apk --release --flavor production --no-pub` exited `0` in
47.5 seconds; exact UTC interval: `2026-10-12T22:31:41.5987500Z` to
`2026-10-12T22:32:29.1275400Z`. `build/app/outputs/flutter-apk/app-production-release.apk` is
79,364,113 bytes, SHA-256
`2C98AFF3CFB3A37A3C0412DE8DC3AC2DC63D8AEF85EBB3F4E28CE4CA6CCF8489`.

The source guide asset and both built platform payloads contain the same
36,424-byte JSON resource, SHA-256
`53F24B8525DF09C251CD550AF113EB260CA55582D920E88953F13BBCAF42FBF7`.
The APK entry was read directly from the archive and hashed; the Windows
bundle resource was hashed in place. No physical runtime was performed.

Earlier untimestamped QA/build results remain historical evidence; the
timestamped final sequence above is the completion record and produced the
same verified artifact hashes. During timestamp capture, one analyzer launch
continued beyond the observed window. Process inspection found no PID 3256 and
no formatter lock-holder; the analyzer server showed increasing CPU and I/O,
so this was not classified as a lock deadlock. Its execution session handle
was not retained, therefore no result was inferred from that run. The
analyzer was rerun and its complete terminal output, exact UTC timestamps and
exit code were captured above. The earlier formatter issue was separate: a
restricted sandbox call could not access the Flutter SDK under `C:\\flutter`;
after diagnosis, formatter/analyzer/tests/builds used the approved SDK access
path with analytics suppressed. An initial analyzer attempt from the earlier
QA cycle was also stopped prematurely; only the subsequent complete analyzer
pass is counted.

## Final status

All required guide content, italic presentation, focused regression, analyzer,
complete serial Flutter suite and Windows/Android production builds completed.
The task-local review package is external to SOURCE; its canonical validation
and final integrity checks are recorded in the handoff index. No source business behavior,
database/schema, authentication, SCENARIO, transfer contract, manifest,
baseline, commit, push or physical runtime was changed or performed.

`READY FOR LOGOS/OWNER REVIEW`.
