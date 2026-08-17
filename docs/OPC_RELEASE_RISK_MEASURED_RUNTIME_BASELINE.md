# Measured Runtime Baseline

This wave did not launch the production executable against the canonical database. The only current-tip runtime-equivalent measurement performed was the safe, read-only disposable-copy integrity procedure. Existing runtime evidence is preserved as historical baseline, not relabelled as a new measurement.

| Measurement | Evidence | Status |
|---|---|---|
| Canonical file size | 82,829,312 bytes before and after disposable-copy check | PASS |
| Canonical SHA-256 | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` before and after | PASS |
| Disposable copy SQLite integrity | `PRAGMA integrity_check=ok`; `user_version=27` | PASS |
| Historical Windows login | Approximately 8–9 seconds in prior runtime evidence | HISTORICAL BASELINE |
| Historical Windows exit | Slow exit observed in prior runtime evidence | HISTORICAL BASELINE |
| Current-tip Windows startup/exit | Not run because production launch would touch canonical DB and no disposable runtime lane was available | INCONCLUSIVE |
| Android physical startup/lifecycle | Not run in this wave | INCONCLUSIVE |

Required successor: measure current-tip startup, login, second-launch, and exit on a disposable/copy-safe runtime lane, then repeat the shared PREDMET acceptance on Android hardware or an equivalent controlled emulator.

