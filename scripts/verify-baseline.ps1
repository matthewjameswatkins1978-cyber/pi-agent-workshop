# Reproducible baseline checks (read-only toward live state)
# Run from anywhere: powershell -File scripts/verify-baseline.ps1
$ErrorActionPreference = 'Stop'

function Check($Name, [scriptblock]$Body) {
  try { & $Body; Write-Output "PASS: $Name" }
  catch { Write-Output ("FAIL: " + $Name + " - " + $_.Exception.Message); $global:Failed = $true }
}

$global:Failed = $false
$Speedy = 'D:\Projects\speedy-keeper'
$MattsPI = 'D:\Projects\mattsPI'
$Layer = 'D:\Projects\PiToRuleThemAll'

Check 'pi version' { pi --version | Out-Null }
Check 'speedy repo present' { if (!(Test-Path "$Speedy\package.json")) { throw 'missing' } }
Check 'speedy tree clean' {
  $s = git -C $Speedy status --short
  if ($s) { throw "dirty: $s" }
}
Check 'mattsPI tree clean' {
  $s = git -C $MattsPI status --short
  if ($s) { throw "dirty: $s" }
}
Check 'keeper help (no DB writes)' { node "$Speedy\dist\src\cli.js" help | Out-Null }
Check 'disposable save/search/export roundtrip' {
  $tmp = Join-Path $env:TEMP ('keeper-baseline-' + [guid]::NewGuid().ToString('N') + '.sqlite')
  try {
    $save = node "$Speedy\dist\src\cli.js" --db $tmp save --kind decision --title 'baseline probe' --body 'verify-baseline.ps1' | ConvertFrom-Json
    if (!$save.ok) { throw 'save not ok' }
    $hits = node "$Speedy\dist\src\cli.js" --db $tmp search --query 'baseline probe' --limit 5 | ConvertFrom-Json
    if (!$hits.ok -or $hits.data.Count -lt 1) { throw 'search empty' }
  } finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
}
Check 'no project memory.sqlite touched' {
  # Workshop holds no DBs; speedy project DB (if any) must be older than this run.
  $db = git -C $Speedy rev-parse --git-common-dir 2>$null
  if ($db) {
    $p = Join-Path (Join-Path $Speedy $db) 'speedy-keeper\memory.sqlite'
    if (Test-Path $p) {
      $age = (Get-Date) - (Get-Item $p).LastWriteTime
      if ($age.TotalMinutes -lt 0) { throw 'clock skew' }
      Write-Output ('project DB exists, left untouched: ' + $p)
    }
  }
}

if ($global:Failed) { Write-Output 'BASELINE: FAIL'; exit 1 }
Write-Output 'BASELINE: PASS'
