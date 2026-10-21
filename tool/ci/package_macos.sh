#!/usr/bin/env bash
set -euo pipefail
products='build/macos/Build/Build/Products/Release'
shopt -s nullglob
apps=("$products"/*.app)
test "${#apps[@]}" -eq 1
test -d "${apps[0]}"
stage="$RUNNER_TEMP/opc-macos-technical"
test ! -e "$stage/OPC_v1.5_macos_unsigned_technical.dmg"
mkdir -p "$stage"
hdiutil create \
  -volname 'OPC v1.5 Technical Review' \
  -srcfolder "${apps[0]}" \
  -format UDZO \
  "$stage/OPC_v1.5_macos_unsigned_technical.dmg"
{
  echo 'artifact=macOS DMG containing app bundle for technical review only'
  echo 'flutter=3.41.7'
  echo "source_commit=$GITHUB_SHA"
  echo 'distribution=code signing disabled; not notarized; not a release publication'
  echo 'note=technical compile artifact only; not installable for ordinary user distribution'
} > "$stage/BUILD_INFO.txt"
