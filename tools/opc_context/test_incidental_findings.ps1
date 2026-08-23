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

function New-TaskFixture([string]$Root, [System.Collections.IDictionary]$Finding) {
    [void][System.IO.Directory]::CreateDirectory($Root)
    Write-Text (Join-Path $Root "REVIEW_INDEX.md") "# Synthetic completion fixture`r`n"
    Write-Text (Join-Path $Root "context\CONTEXT_MANIFEST.json") '{"schema":"opc-context-harness-v1"}'
    Write-Text (Join-Path $Root "qa\flutter_qa_mode.json") '{"mode":"NOT_APPLICABLE","reason":"Synthetic harness-only fixture."}'
    $document = [ordered]@{
        schema = "opc-incidental-findings-v1"
        task = "synthetic"
        unattendedCaptureEnabled = $true
        findings = @($Finding)
    }
    Write-Text (Join-Path $Root "INCIDENTAL_FINDINGS.json") (($document | ConvertTo-Json -Depth 8) + [Environment]::NewLine)
}

function Invoke-Expected([string]$Name, [string]$Root, [bool]$ShouldPass) {
    $powershell = Join-Path $PSHOME "powershell.exe"
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $powershell -NoProfile -ExecutionPolicy Bypass -File $validator `
            -TaskReviewRoot $Root -FlutterQaMode NOT_APPLICABLE -RepoRoot $RepoRoot 2>&1
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

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Invoke-Git @("rev-parse", "--show-toplevel")
}
$RepoRoot = [System.IO.Path]::GetFullPath($RepoRoot)
$validator = Join-Path $RepoRoot "tools\opc_context\validate_completion.ps1"
$projectRoot = Split-Path -Parent $RepoRoot
$fixtureParent = Join-Path $projectRoot "REVIEW\CURRENT_TASK\OPC-INCIDENTAL-FINDING-SYNTHETIC-FIXTURES"
$runRoot = Join-Path $fixtureParent ([Guid]::NewGuid().ToString("N"))
[void][System.IO.Directory]::CreateDirectory($runRoot)

$baseFinding = @{
    id = "SYN-001"
    summary = "Synthetic material observation"
    evidence = @([ordered]@{ path = "evidence/example.txt"; detail = "Concrete fixture evidence." })
    classification = "OUT_OF_SCOPE"
    currentTaskImpact = "No impact on the approved task result."
    scopeEffect = "NO_SCOPE_CHANGE"
    disposition = "PRESERVED_EXISTING_CONTROL"
    destination = "existing/current-control"
    successor = "named-successor-task"
    authorityEffect = "DOES_NOT_CREATE_AUTHORITY"
    orphanStatus = "NOT_ORPHANED"
}

$results = @()
try {
    $cleanRoot = Join-Path $runRoot "preserved"
    New-TaskFixture $cleanRoot $baseFinding
    $results += Invoke-Expected "preserved-successor-unattended" $cleanRoot $true

    $orphan = $baseFinding.Clone()
    $orphan["orphanStatus"] = "ORPHANED"
    $orphanRoot = Join-Path $runRoot "orphan"
    New-TaskFixture $orphanRoot $orphan
    $results += Invoke-Expected "orphan-fails-closed" $orphanRoot $false

    $authorization = $baseFinding.Clone()
    $authorization["scopeEffect"] = "NEW_AUTHORIZATION_REQUIRED"
    $authorization["disposition"] = "OWNER_GATE_REQUIRED"
    $authorization["ownerGateReason"] = "Synthetic new authorization boundary."
    $authorizationRoot = Join-Path $runRoot "authorization"
    New-TaskFixture $authorizationRoot $authorization
    $results += Invoke-Expected "new-authorization-owner-gate" $authorizationRoot $false

    [ordered]@{
        schema = "opc-incidental-finding-fixtures-v1"
        status = "PASS"
        fixtureCount = $results.Count
        results = $results
    } | ConvertTo-Json -Depth 6
} finally {
    if ([System.IO.Directory]::Exists($runRoot)) {
        [System.IO.Directory]::Delete($runRoot, $true)
    }
}
