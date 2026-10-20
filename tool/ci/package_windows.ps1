$ErrorActionPreference = 'Stop'
$release = Join-Path $env:GITHUB_WORKSPACE 'build/windows/x64/runner/Release'
$exe = Join-Path $release 'OPC.exe'
$data = Join-Path $release 'data'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw 'Missing Windows release executable.' }
if (-not (Test-Path -LiteralPath $data -PathType Container)) { throw 'Missing Windows release data directory.' }
$stage = Join-Path $env:RUNNER_TEMP 'opc-windows-release'
New-Item -ItemType Directory -Path $stage -Force | Out-Null
Copy-Item -Path (Join-Path $release '*') -Destination $stage -Recurse -Force
@(
  'artifact=Windows release directory (OPC.exe plus data and runtime DLLs)'
  'flutter=3.41.7'
  "source_commit=$env:GITHUB_SHA"
  'signing=not configured by this workflow'
) | Set-Content -LiteralPath (Join-Path $stage 'BUILD_INFO.txt') -Encoding utf8