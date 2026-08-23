[CmdletBinding()]
param(
    [string]$TaskReviewRoot = "",
    [string]$OutputZipPath = "",
    [string]$ValidateZipPath = "",
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Web.Extensions

$script:Utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:TextExtensions = @(
    ".md", ".txt", ".json", ".csv", ".tsv", ".xml", ".html", ".htm",
    ".log", ".yaml", ".yml", ".ps1", ".psm1", ".psd1", ".cs", ".dart"
)
$script:CodeExtensions = @(".ps1", ".psm1", ".psd1", ".cs", ".dart")
$script:ForbiddenExtensions = @(
    ".db", ".sqlite", ".sqlite3", ".db-wal", ".db-shm", ".apk", ".aab"
)
$script:ManifestName = "PACKAGE_MANIFEST.json"

function Invoke-Git([string[]]$GitArgs) {
    $out = & git @GitArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArgs -join ' ') failed: $out"
    }
    return ($out | Out-String).TrimEnd()
}

function Get-FullPath([string]$Path) {
    return [System.IO.Path]::GetFullPath($Path).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
}

function Test-PathWithin([string]$Candidate, [string]$Parent) {
    $candidateFull = Get-FullPath $Candidate
    $parentFull = Get-FullPath $Parent
    if ($candidateFull.Equals($parentFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }
    $prefix = $parentFull + [System.IO.Path]::DirectorySeparatorChar
    return $candidateFull.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-RelativeZipPath([string]$BasePath, [string]$TargetPath) {
    $baseFull = Get-FullPath $BasePath
    $baseUri = New-Object System.Uri(($baseFull + [System.IO.Path]::DirectorySeparatorChar))
    $targetUri = New-Object System.Uri((Get-FullPath $TargetPath))
    $relative = [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString())
    return $relative.Replace('\', '/')
}

function Get-Sha256Bytes([byte[]]$Bytes) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($Bytes)
        return ([System.BitConverter]::ToString($hash)).Replace("-", "")
    } finally {
        $sha.Dispose()
    }
}

function Get-Sha256File([string]$Path) {
    $stream = [System.IO.File]::OpenRead($Path)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($stream)
        return ([System.BitConverter]::ToString($hash)).Replace("-", "")
    } finally {
        $sha.Dispose()
        $stream.Dispose()
    }
}

function Read-StrictUtf8([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, $script:Utf8Strict)
}

function Write-Utf8NoBom([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $script:Utf8NoBom)
}

function ConvertFrom-StrictUtf8Bytes([byte[]]$Bytes) {
    $text = $script:Utf8Strict.GetString($Bytes)
    if ($text.Length -gt 0 -and [int]$text[0] -eq 0xFEFF) {
        return $text.Substring(1)
    }
    return $text
}

function Assert-Json([string]$Text, [string]$DisplayPath) {
    try {
        $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        $serializer.MaxJsonLength = [int]::MaxValue
        [void]$serializer.DeserializeObject($Text)
    } catch {
        throw "Invalid JSON: $DisplayPath ($($_.Exception.Message))"
    }
}

function Assert-NormalizedEntryPath([string]$EntryPath) {
    if ([string]::IsNullOrWhiteSpace($EntryPath)) {
        throw "ZIP entry path is empty."
    }
    if ($EntryPath.Contains('\')) {
        throw "ZIP entry path is not normalized to '/': $EntryPath"
    }
    if ($EntryPath.StartsWith('/') -or $EntryPath -match '(^|/)\.\.(/|$)') {
        throw "ZIP entry path is unsafe: $EntryPath"
    }
}

function Assert-NotForbidden([string]$DisplayPath) {
    $normalized = $DisplayPath.Replace('\', '/')
    $lower = $normalized.ToLowerInvariant()
    foreach ($extension in $script:ForbiddenExtensions) {
        if ($lower.EndsWith($extension)) {
            throw "Forbidden/private runtime artifact: $DisplayPath"
        }
    }
    if ($lower -match '(^|/)(device-artifacts?|private-runtime|canonical-database)(/|$)') {
        throw "Forbidden/private runtime artifact path: $DisplayPath"
    }
}

function Remove-MarkdownCode([string]$Text) {
    $withoutFences = [System.Text.RegularExpressions.Regex]::Replace(
        $Text,
        '(?s)```.*?```',
        '',
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    )
    return [System.Text.RegularExpressions.Regex]::Replace(
        $withoutFences,
        '`[^`\r\n]+`',
        '',
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    )
}

function Assert-TextEvidence([string]$Text, [string]$DisplayPath, [string]$Extension) {
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $character = $Text[$i]
        if ([System.Char]::IsControl($character) -and
            $character -ne [char]9 -and
            $character -ne [char]10 -and
            $character -ne [char]13) {
            throw ("Unexpected control character U+{0:X4} in {1} at character {2}." -f [int]$character, $DisplayPath, $i)
        }
    }

    $replacementCharacter = [string][char]0xFFFD
    $commonMojibake1 = ([string][char]0x00E2) + ([string][char]0x20AC)
    $commonMojibake2 = [string][char]0x00C3
    $commonMojibake3 = [string][char]0x00C2
    if ($Text.Contains($replacementCharacter) -or $Text.Contains($commonMojibake1) -or
        $Text.Contains($commonMojibake2) -or $Text.Contains($commonMojibake3)) {
        throw "Unexpected encoding/mojibake marker in $DisplayPath."
    }

    if ($script:CodeExtensions -contains $Extension.ToLowerInvariant()) {
        return
    }

    $placeholderSurface = $Text
    if ($Extension.Equals(".md", [System.StringComparison]::OrdinalIgnoreCase)) {
        $placeholderSurface = Remove-MarkdownCode $Text
    }
    $placeholderPattern = '(?<![A-Za-z0-9_`])\$[A-Za-z_][A-Za-z0-9_]*'
    $match = [System.Text.RegularExpressions.Regex]::Match(
        $placeholderSurface,
        $placeholderPattern,
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    )
    if ($match.Success) {
        throw "Unexpected unresolved PowerShell placeholder $($match.Value) in $DisplayPath."
    }
}

function Assert-FileContent([string]$Path, [string]$DisplayPath) {
    Assert-NotForbidden $DisplayPath
    $extension = [System.IO.Path]::GetExtension($DisplayPath).ToLowerInvariant()
    if ($script:TextExtensions -notcontains $extension) {
        return
    }
    $text = Read-StrictUtf8 $Path
    Assert-TextEvidence $text $DisplayPath $extension
    if ($extension -eq ".json") {
        Assert-Json $text $DisplayPath
    }
}

function Read-ZipEntryBytes([System.IO.Compression.ZipArchiveEntry]$Entry) {
    $input = $Entry.Open()
    $memory = New-Object System.IO.MemoryStream
    try {
        $input.CopyTo($memory)
        return $memory.ToArray()
    } finally {
        $memory.Dispose()
        $input.Dispose()
    }
}

function Validate-Zip([string]$ZipPath) {
    $zipFull = Get-FullPath $ZipPath
    if (-not [System.IO.File]::Exists($zipFull)) {
        throw "ZIP does not exist: $zipFull"
    }

    $stream = [System.IO.File]::OpenRead($zipFull)
    $archive = New-Object System.IO.Compression.ZipArchive(
        $stream,
        [System.IO.Compression.ZipArchiveMode]::Read,
        $false
    )
    try {
        $entryMap = @{}
        foreach ($entry in $archive.Entries) {
            Assert-NormalizedEntryPath $entry.FullName
            if ($entryMap.ContainsKey($entry.FullName)) {
                throw "Duplicate ZIP entry: $($entry.FullName)"
            }
            Assert-NotForbidden $entry.FullName
            $entryMap[$entry.FullName] = $entry
        }

        if (-not $entryMap.ContainsKey($script:ManifestName)) {
            throw "ZIP is missing $($script:ManifestName)."
        }

        $manifestBytes = Read-ZipEntryBytes $entryMap[$script:ManifestName]
        $manifestText = ConvertFrom-StrictUtf8Bytes $manifestBytes
        Assert-TextEvidence $manifestText $script:ManifestName ".json"
        Assert-Json $manifestText $script:ManifestName
        $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        $serializer.MaxJsonLength = [int]::MaxValue
        $manifest = $serializer.DeserializeObject($manifestText)
        if ($manifest["schema"] -ne "opc-review-package-v1") {
            throw "Unsupported package manifest schema."
        }
        if ($manifest["manifestHashConvention"] -ne "manifest-excluded-from-own-hash-set") {
            throw "Unsupported manifest hash convention."
        }

        $expected = @{}
        foreach ($item in @($manifest["entries"])) {
            $path = [string]$item["path"]
            Assert-NormalizedEntryPath $path
            if ($path -eq $script:ManifestName) {
                throw "Manifest must be excluded from its own hash set."
            }
            if ($expected.ContainsKey($path)) {
                throw "Duplicate manifest path: $path"
            }
            $expected[$path] = [string]$item["sha256"]
        }

        $actualArtifactPaths = @($entryMap.Keys | Where-Object { $_ -ne $script:ManifestName })
        if ($actualArtifactPaths.Count -ne $expected.Count) {
            throw "Manifest/ZIP entry count mismatch: manifest=$($expected.Count), ZIP artifacts=$($actualArtifactPaths.Count)."
        }
        foreach ($path in $actualArtifactPaths) {
            if (-not $expected.ContainsKey($path)) {
                throw "ZIP entry absent from manifest: $path"
            }
            $bytes = Read-ZipEntryBytes $entryMap[$path]
            $actualHash = Get-Sha256Bytes $bytes
            if ($actualHash -ne $expected[$path]) {
                throw "Manifest/hash mismatch for $path."
            }
            $extension = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
            if ($script:TextExtensions -contains $extension) {
                $text = ConvertFrom-StrictUtf8Bytes $bytes
                Assert-TextEvidence $text $path $extension
                if ($extension -eq ".json") {
                    Assert-Json $text $path
                }
            }
        }

        return [ordered]@{
            status = "PASS"
            zipPath = $zipFull
            zipEntryCount = $archive.Entries.Count
            manifestEntryCount = $expected.Count
            manifestHashConvention = "manifest-excluded-from-own-hash-set"
            sha256 = Get-Sha256File $zipFull
            forbiddenPrivateArtifactCount = 0
            unexpectedEncodingMojibakeDefectCount = 0
            integrity = "MANIFEST_PATHS_AND_HASHES_VERIFIED"
        }
    } finally {
        $archive.Dispose()
        $stream.Dispose()
    }
}

if (-not [string]::IsNullOrWhiteSpace($ValidateZipPath)) {
    $validation = Validate-Zip $ValidateZipPath
    $validation | ConvertTo-Json -Depth 5
    exit 0
}

if ([string]::IsNullOrWhiteSpace($TaskReviewRoot)) {
    throw "TaskReviewRoot is required when creating a package."
}
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = Invoke-Git @("rev-parse", "--show-toplevel")
}
$repoFull = Get-FullPath $RepoRoot
$projectRoot = Get-FullPath (Split-Path -Parent $repoFull)
$reviewRoot = Get-FullPath (Join-Path $projectRoot "REVIEW")
$sourceReview = Get-FullPath (Join-Path $repoFull "REVIEW")
$taskFull = Get-FullPath $TaskReviewRoot

if (-not [System.IO.Directory]::Exists($taskFull)) {
    throw "Task review root does not exist: $taskFull"
}
if (Test-PathWithin $taskFull $sourceReview) {
    throw "FAIL CLOSED: SOURCE/REVIEW is forbidden."
}
if (-not (Test-PathWithin $taskFull $reviewRoot)) {
    throw "FAIL CLOSED: task review root must be inside the external project REVIEW layer: $reviewRoot"
}

if ([string]::IsNullOrWhiteSpace($OutputZipPath)) {
    $OutputZipPath = Join-Path (Split-Path -Parent $taskFull) ((Split-Path -Leaf $taskFull) + ".zip")
}
$outputFull = Get-FullPath $OutputZipPath
if (Test-PathWithin $outputFull $repoFull) {
    throw "FAIL CLOSED: package output cannot be inside SOURCE."
}
$temporaryZip = $outputFull + ".tmp"
if ([System.IO.File]::Exists($temporaryZip)) {
    [System.IO.File]::Delete($temporaryZip)
}

$manifestPath = Join-Path $taskFull $script:ManifestName
$files = @(Get-ChildItem -LiteralPath $taskFull -File -Recurse | Where-Object {
    (Get-FullPath $_.FullName) -ne $outputFull -and
    (Get-FullPath $_.FullName) -ne $temporaryZip -and
    $_.FullName -ne $manifestPath
} | Sort-Object FullName)

$manifestEntries = @()
foreach ($file in $files) {
    $relative = Get-RelativeZipPath $taskFull $file.FullName
    Assert-NormalizedEntryPath $relative
    Assert-FileContent $file.FullName $relative
    $manifestEntries += [ordered]@{
        path = $relative
        sha256 = Get-Sha256File $file.FullName
        length = $file.Length
    }
}

$manifest = [ordered]@{
    schema = "opc-review-package-v1"
    root = Split-Path -Leaf $taskFull
    pathConvention = "forward-slash"
    manifestHashConvention = "manifest-excluded-from-own-hash-set"
    entries = $manifestEntries
}
$manifestJson = $manifest | ConvertTo-Json -Depth 8
Write-Utf8NoBom $manifestPath ($manifestJson + [Environment]::NewLine)

$outputDirectory = Split-Path -Parent $outputFull
if (-not [System.IO.Directory]::Exists($outputDirectory)) {
    [void][System.IO.Directory]::CreateDirectory($outputDirectory)
}
$zipStream = [System.IO.File]::Open($temporaryZip, [System.IO.FileMode]::CreateNew)
$zipArchive = New-Object System.IO.Compression.ZipArchive(
    $zipStream,
    [System.IO.Compression.ZipArchiveMode]::Create,
    $false
)
try {
    $packageFiles = @($files) + @(Get-Item -LiteralPath $manifestPath)
    foreach ($file in @($packageFiles | Sort-Object FullName)) {
        $relative = Get-RelativeZipPath $taskFull $file.FullName
        Assert-NormalizedEntryPath $relative
        $entry = $zipArchive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
        $entry.LastWriteTime = New-Object System.DateTimeOffset(1980, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
        $input = [System.IO.File]::OpenRead($file.FullName)
        $output = $entry.Open()
        try {
            $input.CopyTo($output)
        } finally {
            $output.Dispose()
            $input.Dispose()
        }
    }
} finally {
    $zipArchive.Dispose()
    $zipStream.Dispose()
}

$validated = Validate-Zip $temporaryZip
if ([System.IO.File]::Exists($outputFull)) {
    [System.IO.File]::Delete($outputFull)
}
[System.IO.File]::Move($temporaryZip, $outputFull)
$validated["zipPath"] = $outputFull
$validated["sha256"] = Get-Sha256File $outputFull
$validated | ConvertTo-Json -Depth 5
exit 0
