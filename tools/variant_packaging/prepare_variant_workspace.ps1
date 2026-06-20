[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('ANDROID_TEST', 'WINDOWS_TEST')]
    [string]$Variant,

    [string]$StageRoot = ""
)

$ErrorActionPreference = "Stop"

function Resolve-NormalizedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.Path]::GetFullPath($Path)
}

function New-CleanDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Test-ExcludedRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $normalized = $RelativePath -replace '/', '\'
    $segments = $normalized -split '\\'

    if ($segments -contains 'build' -or
        $segments -contains '.dart_tool' -or
        $segments -contains '.gradle' -or
        $segments -contains 'BACKUPS' -or
        $segments -contains 'RESTORE_POINTS') {
        return $true
    }

    if ($normalized.StartsWith('windows\flutter\ephemeral\', [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    if ($normalized.StartsWith('tools\windows_installer\_work\', [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    $leaf = [System.IO.Path]::GetFileName($normalized)
    if ($leaf -in @('flutter_01.log', 'flutter_02.log')) {
        return $true
    }

    if ([System.IO.Path]::GetExtension($leaf).Equals('.zip', [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    return $false
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRoot = Resolve-NormalizedPath (Join-Path $scriptDir '..\..')
$projectRoot = Resolve-NormalizedPath (Join-Path $sourceRoot '..')
$testPubspecPath = Join-Path $sourceRoot 'pubspec.full_catalog_test.yaml'
$productionPubspecPath = Join-Path $sourceRoot 'pubspec.yaml'
$assetDir = Join-Path $sourceRoot 'assets\katalog_foto'

if (-not (Test-Path -LiteralPath $productionPubspecPath)) {
    throw "Main pubspec.yaml was not found: $productionPubspecPath"
}

if (-not (Test-Path -LiteralPath $testPubspecPath)) {
    throw "Test-only pubspec variant was not found: $testPubspecPath"
}

if (-not (Test-Path -LiteralPath $assetDir)) {
    throw "Catalog photo asset folder was not found: $assetDir"
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
if ([string]::IsNullOrWhiteSpace($StageRoot)) {
    $StageRoot = Join-Path $projectRoot "_variant_stage_${Variant}_$timestamp"
}

$stageRootFull = Resolve-NormalizedPath $StageRoot
New-CleanDirectory -Path $stageRootFull

Get-ChildItem -LiteralPath $sourceRoot -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($sourceRoot.Length).TrimStart('\')
    if (Test-ExcludedRelativePath -RelativePath $relativePath) {
        return
    }

    $destinationPath = Join-Path $stageRootFull $relativePath
    $destinationDir = Split-Path -Parent $destinationPath
    if (-not (Test-Path -LiteralPath $destinationDir)) {
        New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
    }

    Copy-Item -LiteralPath $_.FullName -Destination $destinationPath -Force
}

Copy-Item -LiteralPath $testPubspecPath -Destination (Join-Path $stageRootFull 'pubspec.yaml') -Force

$manifestPath = Join-Path $stageRootFull 'VARIANT_WORKSPACE_INFO.txt'
$manifestLines = @(
    "Prepared variant workspace: $Variant",
    "Source root: $sourceRoot",
    "Staged workspace: $stageRootFull",
    "Main repo pubspec.yaml remains production-safe and was not modified by this script.",
    "This script prepares a staged workspace only.",
    "It does not run Flutter, Dart, Gradle, analyze, test, build, pub get, format, or codegen commands.",
    "Use this staged workspace only for explicit full-photo test packaging with BUILD_VARIANT=$Variant."
)
[System.IO.File]::WriteAllLines(
    $manifestPath,
    $manifestLines,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Variant workspace prepared."
Write-Host "Variant        : $Variant"
Write-Host "Source root    : $sourceRoot"
Write-Host "Stage root     : $stageRootFull"
Write-Host "Overlay pubspec: $testPubspecPath -> pubspec.yaml"
Write-Host ""
Write-Host "Main repo note : build production/default from the main source root."
Write-Host "Test repo note : build explicit full-photo test variants from the staged workspace only."
Write-Host "Next step      : run your manual Flutter build command from the staged workspace with --dart-define=BUILD_VARIANT=$Variant"
