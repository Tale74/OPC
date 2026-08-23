[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ManifestPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "FAIL: context manifest not found: $ManifestPath"
}

$m = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json

$errors = New-Object System.Collections.Generic.List[string]

if ($m.schema -ne "opc-context-harness-v1") {
    $errors.Add("Unexpected manifest schema: $($m.schema)")
}
if ([string]::IsNullOrWhiteSpace($m.branch)) { $errors.Add("Missing branch.") }
if ([string]::IsNullOrWhiteSpace($m.head)) { $errors.Add("Missing HEAD.") }

$requiredAuthority = @(
    "docs/OPC_PRODUCT_AND_DOMAIN.md",
    "docs/OPC_ARCHITECTURE.md",
    "docs/OPC_DEVELOPMENT.md",
    "docs/OPC_QUALITY_RELEASE.md",
    "docs/OPC_ENGINEERING_PROFILE.md"
)

foreach ($required in $requiredAuthority) {
    $entry = @($m.authority | Where-Object { $_.path -eq $required }) | Select-Object -First 1
    if (-not $entry -or $entry.status -ne "FOUND") {
        $errors.Add("Required authoritative home missing: $required")
    }
}

if (-not $m.boundaries.sourceReviewAbsent) {
    $errors.Add("SOURCE/REVIEW exists. REVIEW must remain outside SOURCE.")
}
if ($m.boundaries.canonicalDbIncluded) {
    $errors.Add("Canonical DB must not be included in automated context.")
}
if ($m.boundaries.privateRuntimeIncluded) {
    $errors.Add("Private runtime must not be automatically included in context.")
}

if ([string]::IsNullOrWhiteSpace($m.pseudocodeRoot)) {
    $errors.Add("Pseudocode boundary was not resolved.")
} elseif (-not (Test-Path -LiteralPath $m.pseudocodeRoot)) {
    $errors.Add("Pseudocode boundary does not exist: $($m.pseudocodeRoot)")
}

if ($errors.Count -gt 0) {
    Write-Host "OPC CONTEXT VALIDATION - FAIL"
    $errors | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "OPC CONTEXT VALIDATION - PASS"
Write-Host "TASK CONTROL INTEGRITY PRECHECK - PASS"
Write-Host ""
Write-Host "Context evidence is structurally present."
Write-Host "This validator does NOT certify that a human/agent actually read and understood every authority."
Write-Host "The HUMAN GATE confirmations must still be produced by Codex and accepted by the owner."
exit 0
