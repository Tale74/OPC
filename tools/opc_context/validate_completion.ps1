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
$script:Utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)

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
        $text = [System.IO.File]::ReadAllText($Path, $script:Utf8Strict)
        return ($text | ConvertFrom-Json)
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

$incidental = Read-EvidenceJson (Join-Path $TaskReviewRoot "INCIDENTAL_FINDINGS.json") "incidental findings" $errors
if ($null -ne $incidental) {
    if ($incidental.schema -ne "opc-incidental-findings-v1") {
        $errors.Add("Unsupported incidental findings schema.")
    }
    if ($incidental.unattendedCaptureEnabled -ne $true) {
        $errors.Add("Incidental finding unattended capture must be enabled.")
    }

    $validClassifications = @("IN_SCOPE", "OUT_OF_SCOPE", "AUTHORITY_GAP", "EVIDENCE_INCOMPLETE", "OBSERVATION")
    $validScopeEffects = @("WITHIN_APPROVED_SCOPE", "NO_SCOPE_CHANGE", "NEW_AUTHORIZATION_REQUIRED")
    $validDispositions = @("RESOLVED_CURRENT_TASK", "PRESERVED_EXISTING_CONTROL", "NO_FUTURE_ACTION", "OWNER_GATE_REQUIRED", "BLOCKED")
    foreach ($finding in @($incidental.findings)) {
        $id = [string]$finding.id
        if ([string]::IsNullOrWhiteSpace($id)) { $errors.Add("Incidental finding id is missing.") }
        if ([string]::IsNullOrWhiteSpace([string]$finding.summary)) { $errors.Add("Incidental finding '$id' summary is missing.") }
        if ($validClassifications -notcontains [string]$finding.classification) { $errors.Add("Incidental finding '$id' classification is invalid.") }
        if ([string]::IsNullOrWhiteSpace([string]$finding.currentTaskImpact)) { $errors.Add("Incidental finding '$id' current-task impact is missing.") }
        if ($validScopeEffects -notcontains [string]$finding.scopeEffect) { $errors.Add("Incidental finding '$id' scope effect is invalid.") }
        if ($validDispositions -notcontains [string]$finding.disposition) { $errors.Add("Incidental finding '$id' disposition is invalid.") }
        if ([string]$finding.authorityEffect -ne "DOES_NOT_CREATE_AUTHORITY") { $errors.Add("Incidental finding '$id' must not create business authority.") }
        if ([string]$finding.orphanStatus -ne "NOT_ORPHANED") { $errors.Add("Incidental finding '$id' is orphaned or lacks an explicit orphan check.") }
        if (@($finding.evidence).Count -eq 0) { $errors.Add("Incidental finding '$id' has no concrete evidence.") }
        foreach ($evidence in @($finding.evidence)) {
            if ([string]::IsNullOrWhiteSpace([string]$evidence.path) -or [string]::IsNullOrWhiteSpace([string]$evidence.detail)) {
                $errors.Add("Incidental finding '$id' evidence requires path and detail.")
            }
        }

        switch ([string]$finding.disposition) {
            "RESOLVED_CURRENT_TASK" {
                if ([string]::IsNullOrWhiteSpace([string]$finding.resolution)) { $errors.Add("Incidental finding '$id' resolution is missing.") }
            }
            "PRESERVED_EXISTING_CONTROL" {
                if ([string]::IsNullOrWhiteSpace([string]$finding.destination) -or [string]::IsNullOrWhiteSpace([string]$finding.successor)) {
                    $errors.Add("Incidental finding '$id' requires an existing-control destination and successor.")
                }
            }
            "NO_FUTURE_ACTION" {
                if ([string]::IsNullOrWhiteSpace([string]$finding.reason)) { $errors.Add("Incidental finding '$id' requires a no-action reason.") }
            }
            "OWNER_GATE_REQUIRED" {
                if ([string]::IsNullOrWhiteSpace([string]$finding.ownerGateReason)) { $errors.Add("Incidental finding '$id' owner-gate reason is missing.") }
                $errors.Add("Incidental finding '$id' requires an explicit owner HUMAN GATE.")
            }
            "BLOCKED" { $errors.Add("Incidental finding '$id' is blocking completion.") }
        }
        if ([string]$finding.scopeEffect -eq "NEW_AUTHORIZATION_REQUIRED") {
            $errors.Add("Incidental finding '$id' requires a new authorization boundary.")
        }
    }
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
$finalStateJson = $finalState | ConvertTo-Json -Depth 4
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText(
    (Join-Path $TaskReviewRoot "FINAL_REPOSITORY_STATE.json"),
    ($finalStateJson + [Environment]::NewLine),
    $utf8NoBom
)

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
