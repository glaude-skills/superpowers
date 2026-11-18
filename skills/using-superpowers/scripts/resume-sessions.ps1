# Wake listed Claude sessions that are stuck on a usage limit.
# Scheduled task "claude-resume-sessions" runs this every hour at :07 (was 6 hours until 2026-11-19).
# List: %USERPROFILE%\.claude\resume-sessions.json (only these sessions are touched).
# A session is "stuck" when `claude agents --json` reports state=blocked for it, or when it is not
# running and the last assistant text in its transcript is a usage-limit message.
# Stuck -> stop the idle process (if listed) and `claude --bg --resume <id>` with the entry's prompt.
# If the resume fails, start a fresh background session in cwd with freshPromptFile.
param([string]$ListPath = (Join-Path $env:USERPROFILE '.claude\resume-sessions.json'), [switch]$DryRun)
$ErrorActionPreference = 'Continue'
$claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
if (-not $claude) { $claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe' }
$logDir = Join-Path $env:USERPROFILE '.claude\resume-logs'
$log    = Join-Path $logDir 'resume.log'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
function Say($m) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  sessions  $m" | Add-Content -Path $log -Encoding utf8 }

$list = Get-Content -Raw -Encoding UTF8 $ListPath | ConvertFrom-Json
$limitRe = 'hit your .*limit'

foreach ($s in $list) {
  $env:CLAUDE_SECURESTORAGE_CONFIG_DIR = $s.configDir
  $agents = @()
  try { $agents = & $claude agents --json 2>$null | Out-String | ConvertFrom-Json } catch { Say "$($s.name): agents --json failed: $_" }
  $row = $agents | Where-Object { $_.sessionId -eq $s.sessionId } | Select-Object -First 1

  # last assistant text in the transcript
  $tr = Get-ChildItem -Path (Join-Path $env:USERPROFILE '.claude\projects') -Filter "$($s.sessionId).jsonl" -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $lastText = ''
  if ($tr) {
    $tail = Get-Content -Path $tr.FullName -Tail 80 -Encoding UTF8
    for ($i = $tail.Count - 1; $i -ge 0; $i--) {
      try { $o = $tail[$i] | ConvertFrom-Json } catch { continue }
      if ($o.type -ne 'assistant') { continue }
      $txt = @($o.message.content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text }) -join ' '
      if ($txt) { $lastText = $txt; break }
    }
  }
  $limitHit = $lastText -match $limitRe
  $state = if ($row) { $row.state } else { 'not-running' }

  $stuck = ($state -eq 'blocked') -or (($state -eq 'not-running') -and $limitHit)
  if (-not $stuck) { Say "$($s.name): skip (state=$state, limitText=$limitHit)"; continue }

  # The limit message carries its reset time ("resets 3:40am", "resets at 3:40am (Asia/Seoul)").
  # Waking before that time only hits the limit again (2026-11-19 03:01 run, reset 03:40), so when the
  # reset is still ahead, register a one-shot retry of this script 3 minutes after it and skip for now.
  $reset = $null
  if ($tr) {
    $raw = (Get-Content -Path $tr.FullName -Tail 200 -Encoding UTF8) -join "`n"
    $ms = [regex]::Matches($raw, 'resets (?:at )?(\d{1,2})(?::(\d{2}))?\s*(am|pm)')
    if ($ms.Count -gt 0) {
      $m = $ms[$ms.Count - 1]
      $h = [int]$m.Groups[1].Value % 12; if ($m.Groups[3].Value -eq 'pm') { $h += 12 }
      $mi = if ($m.Groups[2].Success) { [int]$m.Groups[2].Value } else { 0 }
      $reset = (Get-Date).Date.AddHours($h).AddMinutes($mi)
      if ($reset -lt (Get-Date).AddHours(-6)) { $reset = $reset.AddDays(1) }
    }
  }
  # Only a reset within the 5-hour window counts; an older message read as "tomorrow" is ignored.
  if ($reset -and $reset -gt (Get-Date) -and $reset -lt (Get-Date).AddHours(5.5)) {
    $at = $reset.AddMinutes(3)
    if (-not $DryRun) {
      $act = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
      Register-ScheduledTask -TaskName 'claude-resume-retry' -Action $act -Trigger (New-ScheduledTaskTrigger -Once -At $at) -Force | Out-Null
    }
    Say "$($s.name): limit resets $($reset.ToString('HH:mm')), retry scheduled at $($at.ToString('yyyy-MM-dd HH:mm')) (state=$state)"
    continue
  }

  if ($DryRun) { Say "$($s.name): DRYRUN would resume (state=$state, limitText=$limitHit)"; continue }
  Say "$($s.name): stuck (state=$state, limitText=$limitHit) -> resume"
  if ($row) { & $claude stop $row.id *>> (Join-Path $logDir "$($s.name)-stop.log"); Start-Sleep -Seconds 5 }
  Set-Location $s.cwd
  $out = Join-Path $logDir ("$($s.name)-resume-" + (Get-Date -Format 'yyyyMMdd-HHmm') + '.log')
  # No extra flags: a background session keeps its own saved options, and passing flags
  # with --resume starts a copy under a new id instead of continuing the same session.
  & $claude --bg --resume $s.sessionId $s.prompt *> $out
  if ($LASTEXITCODE -eq 0) {
    $txt = Get-Content -Raw -Path $out -ErrorAction SilentlyContinue
    if ($txt -match 'copy as ([0-9a-f]{8})') {
      # A copy was started anyway: point the list entry at the copy so the next run follows it.
      $short = $Matches[1]
      $agents2 = & $claude agents --json 2>$null | Out-String | ConvertFrom-Json
      $copy = $agents2 | Where-Object { $_.id -eq $short } | Select-Object -First 1
      if ($copy) {
        $all = Get-Content -Raw -Encoding UTF8 $ListPath | ConvertFrom-Json
        foreach ($e in $all) { if ($e.sessionId -eq $s.sessionId) { $e.sessionId = $copy.sessionId } }
        $all | ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 $ListPath
        Say "$($s.name): resume started a copy $($copy.sessionId), list updated"
      }
    }
    Say "$($s.name): resumed in background -> $out"
    # Check that the woken session is actually working; a wake that hits the limit again stays blocked
    # and the next hourly run (or the reset retry) tries again.
    Start-Sleep -Seconds 90
    $after = & $claude agents --json 2>$null | Out-String | ConvertFrom-Json
    $r2 = $after | Where-Object { $_.sessionId -eq $s.sessionId } | Select-Object -First 1
    Say "$($s.name): 90s after wake state=$(if ($r2) { $r2.state } else { 'not-running' })"
    continue
  }

  Say "$($s.name): resume failed (exit $LASTEXITCODE), starting a fresh session"
  $fresh = Get-Content -Raw -Encoding UTF8 $s.freshPromptFile
  & $claude --bg --dangerously-skip-permissions -n "$($s.name)-resume" $fresh *>> $out
  Say "$($s.name): fresh session exit $LASTEXITCODE -> $out"
}
