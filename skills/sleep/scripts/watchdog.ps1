# Put the computer to sleep or into hibernation when this Claude Code session
# stops working, whatever made it stop: the work is done, the usage limit was
# reached, the session crashed or was closed. For "sleep when you finish or run
# out of usage", where the session may not be there any more to do it itself.
#
#   pwsh -NoProfile -File <skill>/scripts/watchdog.ps1 -Start -Action Sleep
#   pwsh -NoProfile -File <skill>/scripts/watchdog.ps1 -Status
#   pwsh -NoProfile -File <skill>/scripts/watchdog.ps1 -Stop
#
# -Start leaves a hidden process behind that looks at the session's record in
# <config>/sessions every 20 seconds. Once the session has not been "busy" for
# -IdleMinutes in a row, or is no longer running, it calls power.ps1, which
# warns on the screen and waits -DelaySeconds before it acts. Other sessions
# are not waited for: sleep and hibernation only pause them.
#
# It cannot tell "finished" from "stopped to ask a question": both are a
# session that is not busy. One watchdog at a time, shared with the shutdown
# skill's watchdog: both use the same state file, so -Status and -Stop here see
# a shutdown watchdog too, and -Start replaces one. Windows only.
param(
    [switch]$Start,
    [switch]$Stop,
    [switch]$Status,
    # Internal: the watching loop itself. -Start runs it in a process of its own.
    [switch]$Run,
    [ValidateSet("Sleep", "Hibernate")][string]$Action,
    # The session to watch. Default: the one that calls this script.
    [string]$SessionId = $env:CLAUDE_CODE_SESSION_ID,
    # Longer than the longest pause between two tool calls is not needed: a
    # session is "busy" for the whole of a turn, also while a tool runs.
    [ValidateRange(1, 240)][int]$IdleMinutes = 10,
    [ValidateRange(30, 540)][int]$DelaySeconds = 120,
    [ValidateLength(1, 120)][string]$Reason = "The Claude Code session stopped working.",
    # Pass -DryRun on to power.ps1: everything runs, nothing happens to the machine.
    [switch]$DryRun
)
$ErrorActionPreference = "Stop"

# Keep the state file, the log and the functions down to Get-LiveSession the same
# as in the shutdown skill's watchdog.ps1.
$config = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }
$stateFile = Join-Path $config "qingyi-power-watchdog.json"
$logFile = Join-Path $config "qingyi-power-watchdog.log"
$power = Join-Path $PSScriptRoot "power.ps1"

function Add-LogEntry {
    param([string]$Text)
    Add-Content -Path $logFile -Value "$([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss')) $Text"
}

# The watchdog on record, or $null. A record whose process is gone, or is some
# other program that got the same process id, is cleared.
function Get-Watchdog {
    if (-not (Test-Path $stateFile)) { return $null }
    try { $state = Get-Content $stateFile -Raw | ConvertFrom-Json } catch { Remove-Item $stateFile -Force; return $null }
    $process = Get-CimInstance Win32_Process -Filter "ProcessId = $([int]$state.pid)" -ErrorAction SilentlyContinue
    if (-not $process -or $process.CommandLine -notlike "*watchdog.ps1*") {
        Remove-Item $stateFile -Force
        return $null
    }
    $state
}

function Clear-Watchdog {
    $state = Get-Watchdog
    if (-not $state) { return $false }
    Stop-Process -Id $state.pid -Force -ErrorAction SilentlyContinue
    Remove-Item $stateFile -Force -ErrorAction SilentlyContinue
    Add-LogEntry "stopped (was: $($state.action) for session $($state.sessionId))"
    $true
}

# Every running session's record: one file per session, written by Claude Code.
function Get-LiveSession {
    foreach ($file in Get-ChildItem (Join-Path $config "sessions") -Filter *.json -ErrorAction SilentlyContinue) {
        try { $record = Get-Content $file.FullName -Raw | ConvertFrom-Json } catch { continue }
        if ($record.pid -and (Get-Process -Id $record.pid -ErrorAction SilentlyContinue)) { $record }
    }
}

if ($Status) {
    $state = Get-Watchdog
    if (-not $state) { "no watchdog is running"; return }
    "watchdog running (process $($state.pid)): $($state.action) once session $($state.sessionId) has not been busy for $($state.idleMinutes) minutes$(if ($state.dryRun) { ' (dry run)' }); started $($state.startedAt)"
    return
}

if ($Stop) {
    if (Clear-Watchdog) { "watchdog stopped" } else { "no watchdog was running" }
    return
}

if (-not $Action) { throw "-Action is required: Sleep or Hibernate" }
if (-not $SessionId) { throw "no session to watch: pass -SessionId (CLAUDE_CODE_SESSION_ID is not set)" }

if ($Start) {
    # Fail now, in front of the session, not in an hour with nobody there:
    # hibernation that is turned off, a guest that is running.
    & pwsh -NoProfile -File $power -Action $Action -DelaySeconds $DelaySeconds -DryRun | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "power.ps1 refused '$Action'; run it with -DryRun to see why" }

    [void](Clear-Watchdog)
    $arguments = @("-NoProfile", "-File", "`"$PSCommandPath`"", "-Run", "-Action", $Action, "-SessionId", $SessionId,
        "-IdleMinutes", $IdleMinutes, "-DelaySeconds", $DelaySeconds, "-Reason", "`"$($Reason.Replace('"', "'"))`"")
    if ($DryRun) { $arguments += "-DryRun" }
    $process = Start-Process pwsh -ArgumentList $arguments -WindowStyle Hidden -PassThru
    [ordered]@{
        pid         = $process.Id
        action      = $Action
        sessionId   = $SessionId
        idleMinutes = $IdleMinutes
        dryRun      = [bool]$DryRun
        startedAt   = [DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
    } | ConvertTo-Json | Set-Content $stateFile
    Add-LogEntry "started (process $($process.Id)): $Action once session $SessionId has not been busy for $IdleMinutes minutes$(if ($DryRun) { ' (dry run)' })"
    "watchdog started (process $($process.Id)): $($Action.ToLowerInvariant()) once this session has not been busy for $IdleMinutes minutes. Stop it with -Stop. Log: $logFile"
    return
}

if (-not $Run) { throw "say what to do: -Start, -Stop or -Status" }

# The loop. Its own clock, not the record's: the record's time stamp also moves
# when the session only changes its name.
$idleSince = $null
while ($true) {
    $mine = @(Get-LiveSession) | Where-Object { $_.sessionId -eq $SessionId } | Select-Object -First 1
    if ($mine -and $mine.status -eq "busy") {
        $idleSince = $null
    } elseif (-not $idleSince) {
        $idleSince = [DateTime]::UtcNow
        Add-LogEntry "session is $(if ($mine) { $mine.status } else { 'not running' }); counting $IdleMinutes minutes"
    }

    if ($idleSince -and ([DateTime]::UtcNow - $idleSince).TotalMinutes -ge $IdleMinutes) {
        Add-LogEntry "running power.ps1 -Action $Action$(if ($DryRun) { ' -DryRun' })"
        $powerArguments = @("-NoProfile", "-File", $power, "-Action", $Action, "-DelaySeconds", $DelaySeconds, "-Reason", $Reason)
        if ($DryRun) { $powerArguments += "-DryRun" }
        $output = & pwsh @powerArguments 2>&1 | Out-String
        Add-LogEntry "power.ps1 ended with $LASTEXITCODE`: $($output.Trim())"
        Remove-Item $stateFile -Force -ErrorAction SilentlyContinue
        return
    }

    Start-Sleep -Seconds 20
}
