[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskReviewRoot,

    [Parameter(Mandatory=$true)]
    [ValidateSet("REQUIRED", "NOT_APPLICABLE")]
    [string]$FlutterQaMode,

    [switch]$RequireBuild,

    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

function Invoke-Git([string[]]$GitArgs) {
    $out = & git @GitArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArgs -join ' ') failed: $out"
    }
    return ($out | Out-String).TrimEnd()
}

function Read-EvidenceJson([string]$Path, [string]$Name, [System.Collections.Generic.List[string]]$Errors) {
    if (-not (Test-Path -LiteralPath $Path)) {
        $Errors.Add("Missing $Name evidence: $Path")
        return $null
    }
    try {
        return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
    } catch {
        $Errors.Add("Invalid JSON for $Name evidence: $Path")
        return $null
    }
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Invoke-Git @("rev-parse", "--show-toplevel")
}
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

if (Test-Path (Join-Path $RepoRoot "REVIEW")) {
    Write-Host "OPC COMPLETION VALIDATION - FAIL"
    Write-Host " - SOURCE/REVIEW exists."
    exit 2
}

$TaskReviewRoot = (Resolve-Path -LiteralPath $TaskReviewRoot).Path
$qaRoot = Join-Path $TaskReviewRoot "qa"
$errors = New-Object System.Collections.Generic.List[string]

$modeEvidence = Read-EvidenceJson (Join-Path $qaRoot "flutter_qa_mode.json") "Flutter QA mode" $errors
$analyze = $null
$test = $null
if ($FlutterQaMode -eq "REQUIRED") {
    $analyze = Read-EvidenceJson (Join-Path $qaRoot "flutter_analyze.json") "flutter analyze" $errors
    $test = Read-EvidenceJson (Join-Path $qaRoot "flutter_test_full.json") "full flutter test" $errors
}
$build = $null
if ($RequireBuild) {
    $build = Read-EvidenceJson (Join-Path $qaRoot "build.json") "build" $errors
}

if ($null -ne $modeEvidence) {
    if ($modeEvidence.mode -ne $FlutterQaMode) {
        $errors.Add("Flutter QA mode evidence does not match -FlutterQaMode.")
    }
    if ([string]::IsNullOrWhiteSpace($modeEvidence.reason)) {
        $errors.Add("Flutter QA mode evidence requires an explicit reason.")
    }
}

$qaPairs = @()
if ($FlutterQaMode -eq "REQUIRED") {
    $qaPairs = @(
        [pscustomobject]@{ name = "flutter analyze"; evidence = $analyze },
        [pscustomobject]@{ name = "full flutter test"; evidence = $test }
    )
}
foreach ($pair in $qaPairs) {
    $name = $pair.name
    $e = $pair.evidence
    if ($null -ne $e) {
        if ($e.status -ne "PASS") { $errors.Add("$name status is not PASS.") }
        if ($e.exitCode -ne 0) { $errors.Add("$name exitCode is not 0.") }
        if ([string]::IsNullOrWhiteSpace($e.command)) { $errors.Add("$name command missing.") }
        if ([string]::IsNullOrWhiteSpace($e.startedAt) -or [string]::IsNullOrWhiteSpace($e.endedAt)) {
            $errors.Add("$name start/end timestamps missing.")
        }
    }
}

if ($null -ne $analyze -and $null -ne $test) {
    try {
        $analyzeEnd = [DateTimeOffset]::Parse($analyze.endedAt)
        $testStart = [DateTimeOffset]::Parse($test.startedAt)
        if ($testStart -lt $analyzeEnd) {
            $errors.Add("QA ordering violation: full test started before flutter analyze ended.")
        }
    } catch {
        $errors.Add("Could not parse QA timestamps for ordering validation.")
    }
}

if ($RequireBuild -and $null -ne $build) {
    if ($build.status -ne "PASS") { $errors.Add("Build status is not PASS.") }
    if ($build.exitCode -ne 0) { $errors.Add("Build exitCode is not 0.") }

    if ($null -ne $test) {
        try {
            $testEnd = [DateTimeOffset]::Parse($test.endedAt)
            $buildStart = [DateTimeOffset]::Parse($build.startedAt)
            if ($buildStart -lt $testEnd) {
                $errors.Add("QA ordering violation: build started before full flutter test ended.")
            }
        } catch {
            $errors.Add("Could not parse build/test timestamps for ordering validation.")
        }
    }
}

$contextManifests = Get-ChildItem -LiteralPath $TaskReviewRoot -Filter "CONTEXT_MANIFEST.json" -File -Recurse -ErrorAction SilentlyContinue
if ($contextManifests.Count -eq 0) {
    $errors.Add("No CONTEXT_MANIFEST.json found under task review root.")
}

$reviewIndex = Join-Path $TaskReviewRoot "REVIEW_INDEX.md"
if (-not (Test-Path -LiteralPath $reviewIndex)) {
    $errors.Add("Missing REVIEW_INDEX.md.")
}

$currentBranch = Invoke-Git @("-C", $RepoRoot, "branch", "--show-current")
$currentHead = Invoke-Git @("-C", $RepoRoot, "rev-parse", "HEAD")
$currentStatus = Invoke-Git @("-C", $RepoRoot, "status", "--porcelain=v1", "--untracked-files=all")

$finalState = [ordered]@{
    generatedAt = (Get-Date).ToString("o")
    branch = $currentBranch
    head = $currentHead
    worktreeDirty = -not [string]::IsNullOrWhiteSpace($currentStatus)
    worktreeStatus = $currentStatus
}
$finalState | ConvertTo-Json -Depth 4 |
    Set-Content -LiteralPath (Join-Path $TaskReviewRoot "FINAL_REPOSITORY_STATE.json") -Encoding UTF8

# Every JSON evidence artifact under the task review root must be parseable;
# a package cannot be reported PASS when any expected JSON is malformed.
$jsonEvidence = Get-ChildItem -LiteralPath $TaskReviewRoot -Filter "*.json" -File -Recurse -ErrorAction SilentlyContinue
foreach ($jsonFile in $jsonEvidence) {
    [void](Read-EvidenceJson $jsonFile.FullName $jsonFile.FullName $errors)
}

if ($errors.Count -gt 0) {
    Write-Host "OPC COMPLETION VALIDATION - FAIL"
    $errors | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "OPC COMPLETION VALIDATION - PASS"
Write-Host "Repository final state captured."
Write-Host "This PASS validates evidence structure/order, not owner business acceptance or Logos independent review."
exit 0
