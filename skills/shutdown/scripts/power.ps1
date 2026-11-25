# Shut the computer down, because the user asked for that:
#   pwsh -NoProfile -File <skill>/scripts/power.ps1
#   pwsh -NoProfile -File <skill>/scripts/power.ps1 -DryRun
# where <skill> is the shutdown skill's base directory. Windows only. Sleep and
# hibernation are the sleep skill's script, not this one.
#
# Run it only when the user asked for a shutdown in the current session, and
# as the last thing the session does. Windows counts down -DelaySeconds first
# and shows a notice, so that somebody at the machine can stop it with
# "shutdown /a". The call returns at once; the countdown runs in Windows.
param(
    # Never less than half a minute: the countdown is the only way to stop it.
    # The cap of 540 matches the sleep skill's script.
    [ValidateRange(30, 540)][int]$DelaySeconds = 120,
    # Why, in one short sentence, for the notice on the screen.
    [ValidateLength(1, 120)][string]$Reason = "The work is finished.",
    # Say what would happen and change nothing.
    [switch]$DryRun
)
$ErrorActionPreference = "Stop"

# Keep Assert-NoGuest the same as in the sleep skill's power.ps1.
# A guest that runs through a shutdown loses its work. Starting, saving and
# paused guests count too: only "Off" is safe.
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

# The notice goes to shutdown.exe in quotes; a quote inside would end it early.
$Reason = $Reason.Replace('"', "'")

Assert-NoGuest

if ($DryRun) {
    "dry run: would shut down after $DelaySeconds seconds; nothing was changed"
    return
}

# Windows counts down itself and shows the notice. With a delay it closes every
# open program without asking: unsaved work is lost.
& shutdown.exe /s /t $DelaySeconds /c "$Reason 'shutdown /a' stops this."
if ($LASTEXITCODE -ne 0) { throw "shutdown.exe failed with $LASTEXITCODE" }
"shutting down in $DelaySeconds seconds; 'shutdown /a' stops it"
