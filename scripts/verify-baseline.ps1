# Reproducible baseline checks (read-only toward live state)
# Run from anywhere: powershell -File scripts/verify-baseline.ps1
$ErrorActionPreference = 'Stop'

function Check($Name, [scriptblock]$Body) {
  try { & $Body; Write-Output "PASS: $Name" }
  catch { Write-Output ("FAIL: " + $Name + " - " + $_.Exception.Message); $global:Failed = $true }
}

$global:Failed = $false
if ([string]::IsNullOrWhiteSpace($env:TEMP)) { Write-Output 'FAIL: TEMP not set'; exit 1 }
$runStart = Get-Date
$Speedy = 'D:\Projects\speedy-keeper'
$MattsPI = 'D:\Projects\mattsPI'

Check 'pi version' { pi --version | Out-Null }
Check 'speedy repo present' { if (!(Test-Path "$Speedy\package.json")) { throw 'missing' } }
Check 'speedy tree clean' {
  $s = git -C $Speedy status --short
  if ($LASTEXITCODE -ne 0) { throw 'git status failed' }
  if ($s) { throw "dirty: $s" }
}
Check 'mattsPI tree clean' {
  $s = git -C $MattsPI status --short
  if ($LASTEXITCODE -ne 0) { throw 'git status failed' }
  if ($s) { throw "dirty: $s" }
}
Check 'keeper help (no DB writes)' { node "$Speedy\dist\src\cli.js" help | Out-Null }
Check 'disposable save/search/export roundtrip' {
  $tmp = Join-Path $env:TEMP ('keeper-baseline-' + [guid]::NewGuid().ToString('N') + '.sqlite')
  try {
    $save = node "$Speedy\dist\src\cli.js" --db $tmp save --kind decision --title 'baseline probe' --body 'verify-baseline.ps1' | ConvertFrom-Json
    if (!$save.ok) { throw 'save not ok' }
    $hits = node "$Speedy\dist\src\cli.js" --db $tmp search --query 'baseline probe' --limit 5 | ConvertFrom-Json
    if (!$hits.ok -or @($hits.data).Count -lt 1) { throw 'search empty' }
    $exp = node "$Speedy\dist\src\cli.js" --db $tmp export | ConvertFrom-Json
    if (@($exp).Count -lt 1) { throw 'export empty' }
  } finally { Remove-Item ($tmp + '*') -Force -ErrorAction SilentlyContinue }
}
Check 'project memory.sqlite untouched' {
  # Workshop holds no DBs; speedy project DB (if any) must predate this run.
  $db = git -C $Speedy rev-parse --git-common-dir 2>$null
  if ($LASTEXITCODE -ne 0) { throw 'git rev-parse failed' }
  if ($db) {
    $common = if ([IO.Path]::IsPathRooted($db)) { $db } else { Join-Path $Speedy $db }
    $p = Join-Path $common 'speedy-keeper\memory.sqlite'
    if (Test-Path $p) {
      if ((Get-Item $p).LastWriteTime -gt $runStart) { throw ('project DB modified during run: ' + $p) }
      Write-Output ('project DB exists, left untouched: ' + $p)
    }
  }
}

if ($global:Failed) { Write-Output 'BASELINE: FAIL'; exit 1 }
Write-Output 'BASELINE: PASS'
