#!/usr/bin/env bash
set -euo pipefail
apk='build/app/outputs/flutter-apk/app-production-release.apk'
test -s "$apk"
stage="$RUNNER_TEMP/opc-android-production"
mkdir -p "$stage"
cp "$apk" "$stage/"
{
  echo 'artifact=Android production release APK'
  echo 'flutter=3.41.7'
  echo "source_commit=$GITHUB_SHA"
  echo 'distribution=build artifact only; no store publication'
} > "$stage/BUILD_INFO.txt"