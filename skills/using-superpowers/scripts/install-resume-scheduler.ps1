# Install the usage-limit wake scheduler on this Windows machine (fork policy, 2026-11-19).
# Copies resume-sessions.ps1 into %USERPROFILE%\.claude, creates an empty list file if none exists,
# and registers the scheduled task "claude-resume-sessions" to run it every hour at :07.
# Run again after a skill update to refresh the copied script; the list file is never overwritten.
$ErrorActionPreference = 'Stop'
$dest = Join-Path $env:USERPROFILE '.claude'
$script = Join-Path $dest 'resume-sessions.ps1'
$list = Join-Path $dest 'resume-sessions.json'
if (Test-Path $script) { Copy-Item $script "$script.bak-$(Get-Date -Format yyyyMMdd-HHmm)" }
Copy-Item (Join-Path $PSScriptRoot 'resume-sessions.ps1') $script -Force
if (-not (Test-Path $list)) { '[]' | Out-File -Encoding utf8 $list }
$start = (Get-Date).Date.AddHours((Get-Date).Hour + 1).AddMinutes(7)
$trigger = New-ScheduledTaskTrigger -Once -At $start -RepetitionInterval (New-TimeSpan -Hours 1)
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
Register-ScheduledTask -TaskName 'claude-resume-sessions' -Action $action -Trigger $trigger -Force | Out-Null
"installed: $script, list $list, task claude-resume-sessions hourly from $($start.ToString('yyyy-MM-dd HH:mm'))"
