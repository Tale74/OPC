[CmdletBinding()]
param(
    [string]$InstallerRoot = "",
    [string]$ReleaseBuildPath = "",
    [string]$IssPath = "",
    [string]$IsccPath = "",
    [switch]$CompileInstaller
)

$ErrorActionPreference = "Stop"

function Resolve-NormalizedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.Path]::GetFullPath($Path)
}

function Get-PubspecVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PubspecPath
    )

    $match = Select-String -Path $PubspecPath -Pattern '^version:\s*([^\s]+)' | Select-Object -First 1
    if (-not $match) {
        throw "Unable to resolve version from pubspec.yaml."
    }

    $rawVersion = $match.Matches[0].Groups[1].Value.Trim()
    $plusIndex = $rawVersion.IndexOf('+')
    if ($plusIndex -ge 0) {
        return $rawVersion.Substring(0, $plusIndex)
    }

    return $rawVersion
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-NormalizedPath (Join-Path $scriptDir "..\..")

if ([string]::IsNullOrWhiteSpace($InstallerRoot)) {
    $InstallerRoot = Join-Path $scriptDir "_work"
}
if ([string]::IsNullOrWhiteSpace($ReleaseBuildPath)) {
    $ReleaseBuildPath = Join-Path $repoRoot "build\windows\x64\runner\Release"
}
if ([string]::IsNullOrWhiteSpace($IssPath)) {
    $IssPath = Join-Path $scriptDir "opc_installer.iss"
}

$installerRootFull = Resolve-NormalizedPath $InstallerRoot
$releaseBuildPathFull = Resolve-NormalizedPath $ReleaseBuildPath
$issPathFull = Resolve-NormalizedPath $IssPath

if (-not (Test-Path -LiteralPath $releaseBuildPathFull)) {
    throw "Release build folder not found: $releaseBuildPathFull"
}

if (-not (Test-Path -LiteralPath $issPathFull)) {
    throw "Inno Setup script not found: $issPathFull"
}

$pubspecPath = Join-Path $repoRoot "pubspec.yaml"
$appVersion = Get-PubspecVersion -PubspecPath $pubspecPath
$buildInputDir = Join-Path $installerRootFull "build_input"
$outputDir = Join-Path $installerRootFull "output"
$appExeName = "OPC.exe"
$appExePath = Join-Path $releaseBuildPathFull $appExeName

if (-not (Test-Path -LiteralPath $appExePath)) {
    throw "Expected application executable was not found: $appExePath"
}

New-Item -ItemType Directory -Force -Path $installerRootFull | Out-Null
New-Item -ItemType Directory -Force -Path $buildInputDir | Out-Null
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Get-ChildItem -LiteralPath $buildInputDir -Force | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $releaseBuildPathFull "*") -Destination $buildInputDir -Recurse -Force

$manifest = [ordered]@{
    InstallerRoot    = $installerRootFull
    BuildInputDir    = $buildInputDir
    OutputDir        = $outputDir
    ReleaseBuildPath = $releaseBuildPathFull
    IssPath          = $issPathFull
    AppVersion       = $appVersion
    AppExeName       = $appExeName
}

$manifestPath = Join-Path $installerRootFull "installer_manifest.txt"
$manifest.GetEnumerator() | ForEach-Object { "{0}={1}" -f $_.Key, $_.Value } | Set-Content -Path $manifestPath -Encoding utf8

Write-Host "Installer workspace prepared."
Write-Host "InstallerRoot : $installerRootFull"
Write-Host "BuildInputDir : $buildInputDir"
Write-Host "OutputDir     : $outputDir"
Write-Host "IssPath       : $issPathFull"
Write-Host "AppVersion    : $appVersion"
Write-Host "AppExeName    : $appExeName"

if ($CompileInstaller) {
    if ([string]::IsNullOrWhiteSpace($IsccPath)) {
        throw "CompileInstaller was requested, but IsccPath was not provided."
    }

    $isccPathFull = Resolve-NormalizedPath $IsccPath
    if (-not (Test-Path -LiteralPath $isccPathFull)) {
        throw "Inno Setup Compiler not found: $isccPathFull"
    }

    & $isccPathFull `
        "/DMyBuildInputDir=$buildInputDir" `
        "/DMyOutputDir=$outputDir" `
        "/DMyAppVersion=$appVersion" `
        "/DMyAppExeName=$appExeName" `
        $issPathFull
}
