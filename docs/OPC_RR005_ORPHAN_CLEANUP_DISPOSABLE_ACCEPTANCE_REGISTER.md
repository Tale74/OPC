# RR-005 Disposable Acceptance Register

## Canonical protection

Canonical path: `C:\Users\Steva\Documents\opc_v4_release.sqlite`

Canonical SHA-256 before and after: `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB`.

The canonical file was read-only for this task. No database copy is included in this package.

## Disposable copy evidence

The disposable copy started as a byte-identical copy of the canonical database:

- schema/user_version: `27`;
- `integrity_check`: `ok`;
- FK enforcement mode: `0`;
- targeted FK findings: `36` (`34` orphan provenance, `2` orphan snapshots);
- live provenance and snapshot rows, PREDMET rows and IRiU rows were recorded before startup repair.

Two corrected `AppDatabase.beforeOpen` opens were executed against the disposable copy. After the first open and clean reopen:

- provenance orphans: `34 → 0`;
- snapshot orphans: `2 → 0`;
- targeted FK findings: `36 → 0`;
- `integrity_check`: `ok`;
- user_version remained `27`;
- valid representative provenance IDs `[455,456,457,458,459,460,462,1714,1715,1716]` remained;
- valid representative snapshot IDs `[30,113]` remained;
- PREDMET and IRiU parent counts remained unchanged;
- repeat startup was a no-op for the corrected orphan classes.

The disposable copy was removed after evidence capture. Its post-repair hash was recorded as disposable evidence only and is not a canonical value.

## Boundary confirmation

No parent was synthesized, no orphan payload was interpreted as business truth, no row was relinked, no ID was rewritten, and no schema/migration/generated Drift artifact was changed. The correction remains bounded to the two proven orphan classes.

## QA completion

- Migration/recovery validation: **40/40 PASS**, 6m51s.
- `flutter analyze --no-pub`: **PASS — No issues found**, 59.7s.
- Full `flutter test --no-pub --concurrency=1`: **422 passed, 10 skipped, 0 failed**, 21m50s.
- Windows release build: **PASS — reused from accepted correction execution; source/test hashes unchanged**.
- `flutter build apk --release --no-pub`: **PASS**, 19m30s; APK 78,403,503 bytes.
- Canonical SHA pre/post: `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB`.

Final state: `RR-005 — FULL ACCEPTANCE PASS`.
