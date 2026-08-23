---
name: opc-qa
description: Execute and evidence the locked OPC validation sequence without parallel Flutter/Dart/Gradle QA or arbitrary elapsed-time timeouts.
---

# OPC QA

Apply to code, tests, generated source, schema/migration, assets, runtime configuration or build-configuration changes.

## Sequence
1. Relevant targeted tests where useful.
2. `flutter analyze` to natural completion.
3. Only after analyzer PASS: full `flutter test` to natural completion.
4. Only after both PASS: authorized platform build(s).
5. Runtime/device evidence only when separately authorized.

## Hard rules
- Only one Flutter/Dart/Gradle QA process chain at a time.
- Never run analyzer and full tests in parallel.
- Do not impose arbitrary elapsed-time timeouts on analyzer/full suite.
- A command without conclusive terminal result and exit code is not PASS.
- Long runtime alone is not evidence of a hang.
- Genuine hang requires affirmative technical evidence (deadlock, permanently blocked child, unrecoverable lock/tool failure, etc.).
- Preserve exact commands, start/end times, exit codes and final summaries for review handoff.

Run `tools/opc_context/validate_completion.ps1` before declaring completion when the harness is installed.
