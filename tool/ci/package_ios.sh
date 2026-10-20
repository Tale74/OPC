#!/usr/bin/env bash
set -euo pipefail
app='build/ios/iphoneos/Runner.app'
test -d "$app"
stage="$RUNNER_TEMP/opc-ios-compile-validation"
mkdir -p "$stage"
tar -czf "$stage/Runner-ios-no-codesign.tar.gz" -C build/ios/iphoneos Runner.app
{
  echo 'artifact=iOS compile-validation output only'
  echo 'flutter=3.41.7'
  echo "source_commit=$GITHUB_SHA"
  echo 'distribution=--no-codesign output; not installable user distribution; no IPA'
} > "$stage/BUILD_INFO.txt"