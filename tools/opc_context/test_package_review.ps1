[CmdletBinding()]
param(
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Invoke-Git([string[]]$GitArgs) {
    $out = & git @GitArgs 2>&1
    if ($LASTEXITCODE -ne 0) { throw "git failed: $out" }
    return ($out | Out-String).TrimEnd()
}

function Write-Text([string]$Path, [string]$Text) {
    $parent = Split-Path -Parent $Path
    if (-not [System.IO.Directory]::Exists($parent)) {
        [void][System.IO.Directory]::CreateDirectory($parent)
    }
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}

function Invoke-Expected([string]$Name, [string[]]$Arguments, [bool]$ShouldPass) {
    $powershell = Join-Path $PSHOME "powershell.exe"
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $powershell -NoProfile -ExecutionPolicy Bypass -File $packageScript @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }
    $passed = ($exitCode -eq 0)
    if ($passed -ne $ShouldPass) {
        throw "Fixture '$Name' unexpected result. Exit=$exitCode Output=$($output | Out-String)"
    }
    return [ordered]@{
        name = $Name
        expected = $(if ($ShouldPass) { "PASS" } else { "FAIL" })
        actual = $(if ($passed) { "PASS" } else { "FAIL" })
        detected = $true
    }
}

function New-RawZip([string]$Path, [hashtable]$Entries) {
    Add-Type -AssemblyName System.IO.Compression
    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create)
    $archive = New-Object System.IO.Compression.ZipArchive(
        $stream,
        [System.IO.Compression.ZipArchiveMode]::Create,
        $false
    )
    try {
        foreach ($name in $Entries.Keys) {
            $entry = $archive.CreateEntry($name)
            $writer = New-Object System.IO.StreamWriter($entry.Open(), $utf8)
            try { $writer.Write([string]$Entries[$name]) } finally { $writer.Dispose() }
        }
    } finally {
        $archive.Dispose()
        $stream.Dispose()
    }
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Invoke-Git @("rev-parse", "--show-toplevel")
}
$RepoRoot = [System.IO.Path]::GetFullPath($RepoRoot)
$packageScript = Join-Path $RepoRoot "tools\opc_context\package_review.ps1"
$projectRoot = Split-Path -Parent $RepoRoot
$fixtureParent = Join-Path $projectRoot "REVIEW\CURRENT_TASK\OPC-PACKAGE-RELIABILITY-SYNTHETIC-FIXTURES"
$runRoot = Join-Path $fixtureParent ([Guid]::NewGuid().ToString("N"))
[void][System.IO.Directory]::CreateDirectory($runRoot)

$results = @()
try {
    $clean = Join-Path $runRoot "clean"
    [void][System.IO.Directory]::CreateDirectory($clean)
    Write-Text (Join-Path $clean "REVIEW_INDEX.md") "# Clean fixture`r`n`r`nEvidence is valid.`r`n"
    Write-Text (Join-Path $clean "evidence.json") '{"status":"PASS"}'
    $cleanZip = Join-Path $runRoot "clean.zip"
    $results += Invoke-Expected "clean-package" @(
        "-TaskReviewRoot", $clean, "-OutputZipPath", $cleanZip, "-RepoRoot", $RepoRoot
    ) $true

    $placeholder = Join-Path $runRoot "unresolved-placeholder"
    [void][System.IO.Directory]::CreateDirectory($placeholder)
    Write-Text (Join-Path $placeholder "REVIEW_INDEX.md") ('Unresolved: ' + [char]36 + 'head')
    $results += Invoke-Expected "unresolved-placeholder" @(
        "-TaskReviewRoot", $placeholder, "-OutputZipPath", (Join-Path $runRoot "placeholder.zip"), "-RepoRoot", $RepoRoot
    ) $false

    $control = Join-Path $runRoot "control-character"
    [void][System.IO.Directory]::CreateDirectory($control)
    Write-Text (Join-Path $control "REVIEW_INDEX.md") ("Before" + [char]0x000B + "After")
    $results += Invoke-Expected "control-character-u000b" @(
        "-TaskReviewRoot", $control, "-OutputZipPath", (Join-Path $runRoot "control.zip"), "-RepoRoot", $RepoRoot
    ) $false

    $invalidJson = Join-Path $runRoot "invalid-json"
    [void][System.IO.Directory]::CreateDirectory($invalidJson)
    Write-Text (Join-Path $invalidJson "evidence.json") '{"status":}'
    $results += Invoke-Expected "invalid-json" @(
        "-TaskReviewRoot", $invalidJson, "-OutputZipPath", (Join-Path $runRoot "invalid-json.zip"), "-RepoRoot", $RepoRoot
    ) $false

    $forbidden = Join-Path $runRoot "forbidden-artifact"
    [void][System.IO.Directory]::CreateDirectory($forbidden)
    Write-Text (Join-Path $forbidden "canonical.sqlite") "not-a-real-database"
    $results += Invoke-Expected "forbidden-artifact" @(
        "-TaskReviewRoot", $forbidden, "-OutputZipPath", (Join-Path $runRoot "forbidden.zip"), "-RepoRoot", $RepoRoot
    ) $false

    $separatorZip = Join-Path $runRoot "separator.zip"
    $separatorManifest = '{"schema":"opc-review-package-v1","manifestHashConvention":"manifest-excluded-from-own-hash-set","entries":[]}'
    New-RawZip $separatorZip @{ "PACKAGE_MANIFEST.json" = $separatorManifest; "folder\evidence.txt" = "x" }
    $results += Invoke-Expected "zip-separator-mismatch" @("-ValidateZipPath", $separatorZip) $false

    $hashZip = Join-Path $runRoot "hash.zip"
    $hashManifest = '{"schema":"opc-review-package-v1","manifestHashConvention":"manifest-excluded-from-own-hash-set","entries":[{"path":"evidence.txt","sha256":"0000000000000000000000000000000000000000000000000000000000000000","length":1}]}'
    New-RawZip $hashZip @{ "PACKAGE_MANIFEST.json" = $hashManifest; "evidence.txt" = "x" }
    $results += Invoke-Expected "manifest-hash-mismatch" @("-ValidateZipPath", $hashZip) $false

    [ordered]@{
        schema = "opc-review-package-fixtures-v1"
        status = "PASS"
        fixtureCount = $results.Count
        results = $results
    } | ConvertTo-Json -Depth 6
} finally {
    if ([System.IO.Directory]::Exists($runRoot)) {
        [System.IO.Directory]::Delete($runRoot, $true)
    }
}
