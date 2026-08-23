[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskName,

    [string[]]$Keywords = @(),

    [string[]]$SourcePaths = @(),

    [switch]$UseRepomix,

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

function Get-Sha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Write-Utf8NoBom([string]$Path, [string]$Text) {
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Get-RelativePathCompat([string]$BasePath, [string]$TargetPath) {
    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = New-Object System.Uri($baseFull)
    $targetUri = New-Object System.Uri($targetFull)
    $rel = $baseUri.MakeRelativeUri($targetUri).ToString()
    return [System.Uri]::UnescapeDataString($rel).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Invoke-Git @("rev-parse", "--show-toplevel")
}
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$ProjectRoot = Split-Path -Parent $RepoRoot
$ReviewRoot = Join-Path $ProjectRoot "REVIEW"
$InternalRoot = Join-Path $RepoRoot "INTERNAL_DEVELOPMENT_CONTROL"
$PseudocodeRoot = Join-Path $InternalRoot "PSEUDOCODE"

if (Test-Path (Join-Path $RepoRoot "REVIEW")) {
    throw "FAIL CLOSED: SOURCE/REVIEW exists at $RepoRoot\REVIEW"
}

$SafeTask = ($TaskName -replace '[^A-Za-z0-9._-]+', '_').Trim('_')
if ([string]::IsNullOrWhiteSpace($SafeTask)) { $SafeTask = "TASK" }

$TaskReview = Join-Path $ReviewRoot ("CURRENT_TASK\" + $SafeTask)
$ContextRoot = Join-Path $TaskReview "context"
New-Item -ItemType Directory -Force -Path $ContextRoot | Out-Null

# This task-local evidence file is not a new ledger. It is initialized by the
# existing harness so material incidental findings can be retained without the
# owner continuously monitoring an already approved task. Completion validation
# fails closed if a recorded finding has no evidence or durable disposition.
$incidentalPath = Join-Path $TaskReview "INCIDENTAL_FINDINGS.json"
if (-not (Test-Path -LiteralPath $incidentalPath)) {
    $incidental = [ordered]@{
        schema = "opc-incidental-findings-v1"
        task = $TaskName
        unattendedCaptureEnabled = $true
        findings = @()
    }
    Write-Utf8NoBom $incidentalPath (($incidental | ConvertTo-Json -Depth 8) + [Environment]::NewLine)
}

$branch = Invoke-Git @("-C", $RepoRoot, "branch", "--show-current")
$head = Invoke-Git @("-C", $RepoRoot, "rev-parse", "HEAD")
$status = Invoke-Git @("-C", $RepoRoot, "status", "--porcelain=v1", "--untracked-files=all")
$statusPath = Join-Path $ContextRoot "BASELINE_WORKTREE_STATUS.txt"
Set-Content -LiteralPath $statusPath -Value $status -Encoding UTF8

$authorityRelative = @(
    "docs/OPC_PRODUCT_AND_DOMAIN.md",
    "docs/OPC_ARCHITECTURE.md",
    "docs/OPC_DEVELOPMENT.md",
    "docs/OPC_QUALITY_RELEASE.md",
    "docs/OPC_ENGINEERING_PROFILE.md",
    "docs/OPC_SOURCE_OF_TRUTH_MAP.md",
    "docs/OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md"
)

$authority = @()
foreach ($rel in $authorityRelative) {
    $p = Join-Path $RepoRoot $rel
    if (Test-Path -LiteralPath $p) {
        $authority += [pscustomobject]@{
            path = $rel
            sha256 = Get-Sha256 $p
            status = "FOUND"
        }
    } else {
        $authority += [pscustomobject]@{
            path = $rel
            sha256 = $null
            status = "MISSING"
        }
    }
}

$termList = @($Keywords | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($termList.Count -eq 0) {
    $termList = @($TaskName)
}

$pseudocode = @()
if (Test-Path -LiteralPath $PseudocodeRoot) {
    $pseudoFiles = Get-ChildItem -LiteralPath $PseudocodeRoot -File -Recurse -ErrorAction Stop |
        Where-Object { $_.Extension -in @(".md", ".txt", ".csv", ".json") }

    foreach ($f in $pseudoFiles) {
        $matched = $false
        foreach ($term in $termList) {
            if (Select-String -LiteralPath $f.FullName -SimpleMatch -Pattern $term -Quiet -ErrorAction SilentlyContinue) {
                $matched = $true
                break
            }
        }
        if ($matched) {
            $pseudocode += [pscustomobject]@{
                path = $f.FullName
                sha256 = Get-Sha256 $f.FullName
            }
        }
    }
}

$sourceCandidates = @()
foreach ($sp in $SourcePaths) {
    $candidate = if ([System.IO.Path]::IsPathRooted($sp)) { $sp } else { Join-Path $RepoRoot $sp }
    if (Test-Path -LiteralPath $candidate) {
        $item = Get-Item -LiteralPath $candidate
        if ($item.PSIsContainer) {
            $sourceCandidates += Get-ChildItem -LiteralPath $item.FullName -File -Recurse |
                Where-Object { $_.Extension -in @(".dart", ".yaml", ".json", ".md", ".sql") }
        } else {
            $sourceCandidates += $item
        }
    }
}

if ($sourceCandidates.Count -eq 0) {
    $searchRoots = @("lib", "test", "tool", "tools", "scripts") |
        ForEach-Object { Join-Path $RepoRoot $_ } |
        Where-Object { Test-Path -LiteralPath $_ }

    foreach ($sr in $searchRoots) {
        $candidateFiles = Get-ChildItem -LiteralPath $sr -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Extension -in @(".dart", ".yaml", ".json", ".md", ".sql", ".ps1", ".py") -and
                $_.FullName -notmatch '(?i)[\\/]tools[\\/]opc_context[\\/]'
            }

        foreach ($f in $candidateFiles) {
            $sourceCandidates += $f
        }
    }
}

$sourceCandidates = @($sourceCandidates | Sort-Object FullName -Unique)
$sourceCandidateCountBeforePrecision = $sourceCandidates.Count

# Match terms once, then apply a generic precision gate.  High-frequency,
# short entity words (for example a broad domain noun) are not sufficient on
# their own; a candidate must also have a low-frequency/high-signal term or a
# task-relevant path context.  This keeps recall for transfer/user/JSON work
# without hard-coding a particular product scenario.
$termFrequency = @{}
$matchesByPath = @{}
foreach ($f in $sourceCandidates) {
    $matches = @($termList | Where-Object {
        Select-String -LiteralPath $f.FullName -SimpleMatch -Pattern $_ -Quiet -ErrorAction SilentlyContinue
    })
    if ($matches.Count -gt 0) {
        $matchesByPath[$f.FullName] = $matches
        foreach ($term in $matches) {
            $key = $term.ToLowerInvariant()
            if (-not $termFrequency.ContainsKey($key)) { $termFrequency[$key] = 0 }
            $termFrequency[$key]++
        }
    }
}

$frequencyThreshold = [Math]::Max(8, [int]([Math]::Max(1, $sourceCandidates.Count) * 0.12))
$contextPattern = '(?i)(predmet|json|transfer|import|export|user|koris|auth|log|statistik|backup|responsib|actor|creator|modifier)'
$filteredCandidates = @()
$candidateRelevance = @{}
foreach ($f in $sourceCandidates) {
    if (-not $matchesByPath.ContainsKey($f.FullName)) { continue }
    $matches = @($matchesByPath[$f.FullName])
    $highSignal = @($matches | Where-Object {
        $termFrequency[$_.ToLowerInvariant()] -le $frequencyThreshold -or $_.Length -ge 14
    })
    $pathContext = [regex]::IsMatch($f.FullName, $contextPattern)
    $direct = ($highSignal.Count -gt 0) -or $pathContext
    if ($direct) {
        $filteredCandidates += $f
        $candidateRelevance[$f.FullName] = [pscustomobject]@{
            matchTerms = $matches
            direct = $direct
        }
    }
}

$sourceCandidates = @($filteredCandidates | Sort-Object FullName -Unique | Select-Object -First 250)

$sourceIndex = @()
foreach ($f in $sourceCandidates) {
    $rel = Get-RelativePathCompat $RepoRoot $f.FullName
    $sourceIndex += [pscustomobject]@{
        path = $rel
        sha256 = Get-Sha256 $f.FullName
        matchTerms = @($candidateRelevance[$f.FullName].matchTerms)
        direct = [bool]$candidateRelevance[$f.FullName].direct
    }
}

$manifest = [ordered]@{
    schema = "opc-context-harness-v1"
    generatedAt = (Get-Date).ToString("o")
    task = $TaskName
    keywords = $termList
    repoRoot = $RepoRoot
    projectRoot = $ProjectRoot
    branch = $branch
    head = $head
    baselineWorktreeDirty = -not [string]::IsNullOrWhiteSpace($status)
    baselineWorktreeStatusFile = $statusPath
    authority = $authority
    pseudocodeRoot = $PseudocodeRoot
    pseudocodeMatches = $pseudocode
    sourceCandidates = $sourceIndex
    sourcePrecision = [ordered]@{
        rule = "Retain low-frequency/high-signal matches or candidates in generic transfer/user/JSON context paths; broad-only unrelated matches are excluded."
        beforeCandidateCount = $matchesByPath.Count
        afterCandidateCount = $sourceCandidates.Count
        frequencyThreshold = $frequencyThreshold
    }
    boundaries = [ordered]@{
        reviewOutsideSource = $true
        sourceReviewAbsent = -not (Test-Path (Join-Path $RepoRoot "REVIEW"))
        canonicalDbIncluded = $false
        privateRuntimeIncluded = $false
    }
}

$manifestPath = Join-Path $ContextRoot "CONTEXT_MANIFEST.json"
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

$authorityIndexPath = Join-Path $ContextRoot "AUTHORITY_INDEX.txt"
$authority | ForEach-Object { "$($_.status)`t$($_.path)`t$($_.sha256)" } |
    Set-Content -LiteralPath $authorityIndexPath -Encoding UTF8

$sourceIndexPath = Join-Path $ContextRoot "SOURCE_INDEX.txt"
$sourceIndex | ForEach-Object { "$($_.path)`t$($_.sha256)" } |
    Set-Content -LiteralPath $sourceIndexPath -Encoding UTF8

$pseudoIndexPath = Join-Path $ContextRoot "PSEUDOCODE_INDEX.txt"
$pseudocode | ForEach-Object { "$($_.path)`t$($_.sha256)" } |
    Set-Content -LiteralPath $pseudoIndexPath -Encoding UTF8

if ($UseRepomix) {
    $repomixCmd = Get-Command repomix -ErrorAction SilentlyContinue
    if (-not $repomixCmd) {
        throw "Repomix requested but 'repomix' is not available on PATH."
    }

    if ($sourceIndex.Count -eq 0) {
        throw "Repomix requested but no bounded source candidates were discovered."
    }

    $includeCsv = ($sourceIndex.path -join ",")
    $repomixOut = Join-Path $ContextRoot "bounded-repomix.xml"
    & repomix $RepoRoot --include $includeCsv --output $repomixOut --style xml
    if ($LASTEXITCODE -ne 0) { throw "Repomix failed with exit code $LASTEXITCODE" }
}

Write-Host "OPC context built:"
Write-Host "  Task:    $TaskName"
Write-Host "  Branch:  $branch"
Write-Host "  HEAD:    $head"
Write-Host "  Dirty:   $($manifest.baselineWorktreeDirty)"
Write-Host "  Manifest $manifestPath"
