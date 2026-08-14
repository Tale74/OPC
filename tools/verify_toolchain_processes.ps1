param(
  [switch]$AllowOpc
)

$names = @(
  'flutter', 'dart', 'dartvm', 'dartaotruntime', 'flutter_tester',
  'java', 'gradle', 'gradlew'
)
if (-not $AllowOpc) { $names += 'OPC' }

$processes = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
  $names -contains $_.ProcessName
} | Select-Object Id, ProcessName, Path, StartTime)

[pscustomobject]@{
  checkedAtUtc = [DateTime]::UtcNow.ToString('o')
  processNames = $names
  count = $processes.Count
  processes = $processes
} | ConvertTo-Json -Depth 4

if ($processes.Count -ne 0) { exit 1 }
exit 0
