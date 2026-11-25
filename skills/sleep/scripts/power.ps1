# Put the computer to sleep or into hibernation, as the user chose:
#   pwsh -NoProfile -File <skill>/scripts/power.ps1 -Action Sleep
#   pwsh -NoProfile -File <skill>/scripts/power.ps1 -Action Hibernate -DryRun
# where <skill> is the sleep skill's base directory. Windows only. A shutdown
# is the shutdown skill's script, not this one.
#
# Run it only when the user asked for that action in the current session, and
# as the last thing the session does. It waits -DelaySeconds first, so that
# somebody at the machine can stop it by ending this script. The wait is inside
# the call, so give the call a timeout well above it (300 seconds for the
# default delay). A tool call ends after 600 seconds at most, hence the cap of
# 540.
param(
    [Parameter(Mandatory)][ValidateSet("Sleep", "Hibernate")][string]$Action,
    # Never less than half a minute: the wait is the only way to stop it.
    [ValidateRange(30, 540)][int]$DelaySeconds = 120,
    # Why, in one short sentence, for the notice on the screen.
    [ValidateLength(1, 120)][string]$Reason = "The work is finished.",
    # Say what would happen and change nothing.
    [switch]$DryRun
)
$ErrorActionPreference = "Stop"

# Keep Assert-NoGuest the same as in the shutdown skill's power.ps1.
# A guest that runs into a sleep is paused in the middle of a test. Starting,
# saving and paused guests count too: only "Off" is safe.
function Assert-NoGuest {
    if (-not (Get-Command Get-VM -ErrorAction SilentlyContinue)) { return }
    # Get-VM fails without "Hyper-V Administrators" or with the Hyper-V service
    # stopped. An account that cannot list guests cannot have started one.
    try { $guests = @(Get-VM -ErrorAction Stop) } catch {
        "note: Hyper-V guests not checked ($($_.Exception.Message))"
        return
    }
    $busy = @($guests | Where-Object { $_.State -ne "Off" })
    if ($busy) { throw "a Hyper-V guest is not off ($(($busy | ForEach-Object { "$($_.Name): $($_.State)" }) -join ', ')); stop it first" }
}

# Tell whoever sits at the machine. Windows shows nothing of its own before a
# sleep or a hibernation.
function Send-Notice {
    param([string]$Text)
    $msg = Join-Path $env:SystemRoot "System32\msg.exe"
    if (Test-Path $msg) { & $msg * /TIME:$DelaySeconds $Text 2>$null }
}

Assert-NoGuest

if ($Action -eq "Hibernate") {
    $power = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -ErrorAction SilentlyContinue
    # Without a value of its own the setting follows its default.
    $enabled = if ($null -ne $power.HibernateEnabled) { $power.HibernateEnabled } else { $power.HibernateEnabledDefault }
    if ($enabled -ne 1) {
        throw "hibernation is turned off on this machine ('powercfg /hibernate on' from an elevated prompt turns it on); choose Sleep"
    }
}

if ($DryRun) {
    "dry run: would $($Action.ToLowerInvariant()) after $DelaySeconds seconds; nothing was changed"
    return
}

switch ($Action) {
    "Hibernate" {
        "hibernating in $DelaySeconds seconds; end this script to stop it"
        Send-Notice "$Reason This computer hibernates in $DelaySeconds seconds."
        Start-Sleep -Seconds $DelaySeconds
        Assert-NoGuest
        & shutdown.exe /h
        if ($LASTEXITCODE -ne 0) { throw "shutdown.exe failed with $LASTEXITCODE" }
    }
    "Sleep" {
        "going to sleep in $DelaySeconds seconds; end this script to stop it"
        Send-Notice "$Reason This computer goes to sleep in $DelaySeconds seconds."
        Start-Sleep -Seconds $DelaySeconds
        Assert-NoGuest
        # Not "rundll32 powrprof.dll,SetSuspendState": with hibernation turned
        # on, that hibernates instead.
        Add-Type -AssemblyName System.Windows.Forms
        $asleep = [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)
        if (-not $asleep) { throw "Windows refused to sleep" }
    }
}
