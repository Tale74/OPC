#!/usr/bin/env bash
set -euo pipefail

test -s web/drift_worker.dart
test -s web/sqlite3.wasm

expected_sqlite3_wasm='3c616bf0d51380daaed7871b3110a634a17c703c22d82cba7a2a73216769e680'
actual_sqlite3_wasm="$(sha256sum web/sqlite3.wasm | cut -d ' ' -f 1)"
test "$actual_sqlite3_wasm" = "$expected_sqlite3_wasm"

dart --suppress-analytics compile js \
  -O4 \
  web/drift_worker.dart \
  -o web/drift_worker.dart.js

test -s web/drift_worker.dart.js
