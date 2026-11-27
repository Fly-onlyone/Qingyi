# Install a packaged Windows app into a clean Hyper-V guest, use it the way a
# user would, uninstall it, and keep the evidence.
#
# This is a working example for an app that ships as a zip with install.ps1
# and uninstall.ps1. Copy it next to Vm.ps1, rename it, and change the
# settings block and the cases to what your project's README promises.
#   pwsh scripts\vm\test-myapp.ps1
#
# Every run starts from the VM's "clean" checkpoint (see provision.ps1).
# Results go to report\vm-test-<date>\: screenshots\, recording\session.mp4
# with session.start.txt (when the film began; each result in results.json has
# started, ended and seconds), logs\results.json, logs\facts-*.json,
# logs\timing.jsonl and logs\timing.md (what took the time), and logs\run.log, a
# transcript of everything the run prints. The script decides only what a
# program can decide (exit codes, files, processes). Whether a page was drawn
# correctly is for whoever reads the screenshots.
#
# This script has no fixed sleep. A step waits for what it needs (Wait-Until,
# Wait-ScreenChange, Wait-ScreenStill, Wait-ScreenSettled, Wait-GuestProcessGone),
# with the time a sleep used to have as its deadline: at the deadline the case
# goes on and its own checks judge, and logs\timing.md lists the wait as one that
# hit its deadline. A pause that is itself a test is Hold-For with its reason.
# The helpers are in Vm.ps1. They were proven in a project's rig that shares
# this code; this template itself has not been run since it was ported.
param(
    [string]$VmName = "Software Tester",
    # Package to test. Default: the newest match of $app.Package in dist\.
    [string]$Zip,
    # Folder for the evidence. Default: report\vm-test-<yyyy-MM-dd>.
    [string]$Report,
    [string]$User = "tester",
    [string]$Password = "vmtest",
    [string]$Snapshot = "clean",
    # Give the guest a share of the host's graphics card. Needs the checkpoint
    # "clean-gpu" from provision-gpu.ps1, which is then the default.
    [switch]$Gpu,
    # Leave the VM running at the end, for a look by hand.
    [switch]$KeepRunning,
    # Multiplies every deadline and every Hold-For; raise it on a slow host. It
    # never changes how often a wait polls.
    [double]$Pace = 1.0,
    # Run only these cases (their IDs), after the usual setup of the guest. For
    # a case that can stand alone; most cases build on the ones before them.
    # Use it to prove a change to this script on a few cases before a full pass.
    [string[]]$Only,
    # Leave these cases out (their IDs; wildcards allowed, as "G*").
    [string[]]$Skip,
    # The report folder of an earlier run: logs\timing.md then compares this
    # run's total, setup and cases with it.
    [string]$Previous,
    # Run every guest script the old way, as a scheduled task of its own, and
    # not through the helper in the guest (guest\agent.ps1). For telling a fault
    # of the helper from a fault of the app, and as the baseline when timing it.
    [switch]$NoGuestAgent
)
$ErrorActionPreference = "Stop"
# "pwsh -File ... -Only A1,C1" hands the list over as one text.
if ($Only) { $Only = @($Only | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
if ($Skip) { $Skip = @($Skip | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
. (Join-Path $PSScriptRoot "Vm.ps1")
Initialize-Vm -Name $VmName -User $User -Password $Password -NoAgent:$NoGuestAgent
# Widens the screen compare's tolerance: with a graphics card the backdrop drifts.
$script:Vm.Gpu = [bool]$Gpu

# ---------------------------------------------------------------- settings
$guestHome = "C:\Users\$User"
$app = @{
    # What a user types into the Start menu to find the app.
    Name      = "MyApp"
    # Process name of the window program, without .exe.
    Process   = "myapp"
    # Package file name in dist\, with wildcards.
    Package   = "MyApp-*-windows-x64.zip"
    # Where the installer puts the app in the guest.
    Target    = "$guestHome\AppData\Local\Programs\MyApp"
    # How the README tells a user to unpack the download. Explorer's "Extract
    # All" marks every extracted file as downloaded, as the zip is; Expand-Archive
    # marks none (measured). $false when the README says Expand-Archive.
    UnpackWithExplorer = $true
    # The install command exactly as the README gives it, as a user types it
    # into a PowerShell window opened in the unpacked folder. No bypass here:
    # whether the documented command works is what case C1 finds out.
    Install   = ".\install.ps1"
    # Used only when C1 fails, to reach the later cases. Runs through cmd.exe
    # in the unpacked folder.
    InstallBypass = "powershell -ExecutionPolicy Bypass -File install.ps1"
    # The uninstall command exactly as the README gives it, typed into a
    # PowerShell window; {0} is the install folder. No bypass, as for Install.
    Uninstall = "& '{0}\uninstall.ps1'"
    # Used only when C1 needed the bypass. Runs through cmd.exe; {0} is the
    # install folder.
    UninstallBypass = "powershell -ExecutionPolicy Bypass -File `"{0}\uninstall.ps1`""
}

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $Zip) {
    $newest = Get-ChildItem (Join-Path $root "dist") -Filter $app.Package -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $newest) { throw "no package matching $($app.Package) in dist\; build it first" }
    $Zip = $newest.FullName
}
$Zip = (Resolve-Path $Zip).Path
if (-not $Report) { $Report = Join-Path $root ("report\vm-test-" + (Get-Date -Format "yyyy-MM-dd")) }
$shots = Join-Path $Report "screenshots"
$logs = Join-Path $Report "logs"
New-Item -ItemType Directory -Force $shots, $logs, (Join-Path $Report "recording") | Out-Null
$Report = (Resolve-Path $Report).Path
# Evidence of an earlier run into the same folder would mix with this one's.
Get-ChildItem $shots -Filter "*.png" | Remove-Item -Force
Get-ChildItem $logs -Filter "facts-*.json" | Remove-Item -Force
Remove-Item (Join-Path $logs "timing.md") -Force -ErrorAction SilentlyContinue
# What takes the time, event by event (Write-Timing in Vm.ps1); summarized at the end.
Initialize-Timing -Path (Join-Path $logs "timing.jsonl") -Pace $Pace
# Everything this run prints, for the report and for following a background run.
Start-Transcript -Path (Join-Path $logs "run.log") -Force | Out-Null
$guestUnpacked = "$guestHome\Downloads\$($app.Name)"

# ---------------------------------------------------------------- harness
$results = [System.Collections.Generic.List[object]]::new()
$shotCount = 0

# Take a screenshot named after the case and return its file name.
function Shot {
    param([string]$Name)
    $script:shotCount += 1
    $file = "{0:d2}-{1}.png" -f $script:shotCount, $Name
    Save-Screenshot (Join-Path $shots $file) | Out-Null
    $file
}

# "note" is for a case whose result only a reader of the screenshots can
# judge; "error" means the harness failed, which says nothing about the app.
function Add-Result {
    param(
        [string]$Id, [string]$Title, [string]$Expect,
        [ValidateSet("pass", "fail", "note", "error")][string]$Status,
        [string]$Observed, [string[]]$Shots = @(), [string]$Output = ""
    )
    $results.Add([pscustomobject]@{
            id = $Id; title = $Title; expect = $Expect; status = $Status
            observed = $Observed; screenshots = $Shots; output = $Output
        })
    "{0,-5} {1,-4} {2}" -f $Status, $Id, $Observed
    Save-Results
}

# Written to a file beside it first and moved over, so that a reader who
# follows the run through results.json never sees half of it.
function Save-Results {
    $file = Join-Path $logs "results.json"
    $results | ConvertTo-Json -Depth 5 | Set-Content "$file.tmp"
    Move-Item "$file.tmp" $file -Force
}

# Run one case; a thrown error becomes an "error" result and the run goes on.
# Every result the case added gets started (so the report can jump the
# recording to it: recording\session.start.txt holds when the film began),
# ended and seconds. -Only and -Skip leave a case out.
function Test-Case {
    param([string]$Id, [string]$Title, [string]$Expect, [scriptblock]$Body)
    if ($Only -and $Only -notcontains $Id) { return }
    if ($Skip | Where-Object { $Id -like $_ }) { return }
    $first = $results.Count
    $began = Get-Date
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    $script:Timing.Case = $Id
    try {
        & $Body
    } catch {
        $shot = try { Shot "$Id-error" } catch { $null }
        Add-Result -Id $Id -Title $Title -Expect $Expect -Status error `
            -Observed "the harness failed: $($_.Exception.Message)" -Shots @($shot | Where-Object { $_ })
    } finally {
        $seconds = [math]::Round($clock.Elapsed.TotalSeconds, 1)
        for ($i = $first; $i -lt $results.Count; $i++) {
            $results[$i] | Add-Member -NotePropertyName started -NotePropertyValue $began.ToString("o") -Force
            $results[$i] | Add-Member -NotePropertyName ended -NotePropertyValue (Get-Date).ToString("o") -Force
            $results[$i] | Add-Member -NotePropertyName seconds -NotePropertyValue $seconds -Force
        }
        if ($results.Count -gt $first) { Save-Results }
        Write-Timing -Kind case -What $Id -Sec $seconds
        $script:Timing.Case = ""
    }
}

# Facts about the guest and about what the app left on it, as an object.
# Runs on the user's desktop, so it can see windows. Throws when the guest
# prints nothing: a command that timed out must never read as "nothing there".
function Get-Facts {
    param([string]$Name, [int]$TimeoutSec = 300)
    $run = Invoke-GuestScript -TimeoutSec $TimeoutSec -Script @"
`$target = '$($app.Target)'
`$system32 = Join-Path `$env:WINDIR 'System32'
`$path = @([Environment]::GetEnvironmentVariable('Path', 'User') -split ';' | Where-Object { `$_ })
`$crashes = @(Get-WinEvent -FilterHashtable @{ LogName = 'Application'; ProviderName = 'Application Error', 'Application Hang'; StartTime = (Get-Date).AddHours(-12) } -ErrorAction SilentlyContinue |
        Where-Object { `$_.Message -match '$($app.Process)' } | Select-Object -First 10 | ForEach-Object { `$_.TimeCreated.ToString('o') + ' ' + `$_.Message.Substring(0, [Math]::Min(400, `$_.Message.Length)) })
[ordered]@{
    build      = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild
    policy     = "`$(Get-ExecutionPolicy)"
    git        = [bool](Get-Command git -ErrorAction SilentlyContinue)
    adapters   = @(Get-CimInstance Win32_VideoController | ForEach-Object { `$_.Name })
    missingDll = @('vcruntime140.dll', 'vcruntime140_1.dll', 'msvcp140.dll' | Where-Object { -not (Test-Path (Join-Path `$system32 `$_)) })
    installed  = @(Get-ChildItem `$target -ErrorAction SilentlyContinue | ForEach-Object { `$_.Name })
    onUserPath = @(`$path | Where-Object { `$_.TrimEnd('\') -eq `$target.TrimEnd('\') }).Count
    shortcuts  = @(Get-ChildItem "`$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Recurse -Filter '*.lnk' | Where-Object { `$_.BaseName -like '*$($app.Name)*' } | ForEach-Object { `$_.Name })
    processes  = @(Get-Process | Where-Object { `$_.ProcessName -like '$($app.Process)*' } | ForEach-Object {
            [ordered]@{ name = `$_.ProcessName; id = `$_.Id; window = (`$_.MainWindowHandle -ne 0); title = `$_.MainWindowTitle }
        })
    crashes    = `$crashes
} | ConvertTo-Json -Depth 5
"@
    Set-Content (Join-Path $logs "facts-$Name.json") $run.Output
    if (-not $run.Completed -or -not $run.Output.Trim()) { throw "the guest gave no facts for '$Name': $($run.Stderr)" }
    $run.Output | ConvertFrom-Json
}

# Open the Start menu, type the app's name and press Enter, as a user does.
function Start-FromStartMenu {
    Send-Keys "win"
    Wait-ScreenSettled -TimeoutSec 4 -MinSec 1 -What "the Start menu opens"
    Send-Text $app.Name
    Wait-ScreenSettled -TimeoutSec 6 -MinSec 2 -QuietMs 800 -What "the Start menu lists the app"
    $found = Shot "start-menu-search"
    $before = Get-ScreenFrame
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    Send-Keys "enter"
    # The old fixed wait was 20 s; that stays the deadline for both steps. This
    # watches the host's thumbnail, not the guest: a guest that the app keeps too
    # busy to answer (see P1) still shows its window, and no input is sent.
    # The window opens: the screen differs from what it showed before Enter.
    Wait-ScreenChange -TimeoutSec 20 -Since $before -What "the app's window opens"
    # The page is drawn: the screen stands still. A project whose app writes a
    # ready line to its log would wait for that line here instead: take a line
    # mark of the log in the guest before the Enter above, then poll the log from
    # that mark in one guest-side loop (a 200 ms poll, the old 20 s as its
    # deadline) and log it with Write-Timing -Kind wait. A wait for a window of
    # a given process is Show-GuestWindow, which also clicks the window.
    $left = [math]::Max(2, 20 - $clock.Elapsed.TotalSeconds / $Pace)
    Wait-ScreenStill -TimeoutSec $left -MinSec 1 -QuietMs 1500 -What "the app's page is drawn (the screen stands still)"
    $found
}

# True once P1 has found that the idle app keeps the guest too busy to answer
# commands. Keys, clicks and screenshots still work then, so later cases
# close the app by keyboard before they ask the guest anything.
$starved = $false

# Close the app without asking the guest, and wait until the guest answers again.
function Close-AppByKeyboard {
    $before = Get-ScreenFrame
    Send-Keys "alt+f4"
    # The window goes: the screen changes. Not a question to the guest, which may
    # be too busy to answer. The old fixed wait, 5 s, is the deadline.
    Wait-ScreenChange -TimeoutSec 5 -Since $before -What "the app's window closes"
    Wait-Guest -TimeoutSec 300
}

function Stop-App {
    Invoke-GuestScript -Script "Get-Process '$($app.Process)' -ErrorAction SilentlyContinue | Stop-Process -Force" | Out-Null
    # The old fixed wait, 2 s, is the deadline.
    [void](Wait-GuestProcessGone -Name $app.Process -TimeoutSec 2 -What "the app's processes end")
}

# Run an install command in the unpacked folder and say whether the app is there.
function Install-InGuest {
    param([string]$Name, [string]$Line)
    $run = Invoke-GuestScript -TimeoutSec 600 -Script @"
Set-Location '$guestUnpacked'
$Line 2>&1
"install exit: `$LASTEXITCODE"
`$global:LASTEXITCODE = 0
"@
    $facts = Get-Facts $Name
    [pscustomobject]@{ Run = $run; Facts = $facts; Installed = $facts.installed.Count -gt 0 }
}

# ---------------------------------------------------------------- A, host
Test-Case "A1" "Package contents" "the archive holds what the README lists" {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($Zip)
    try { $entries = @($archive.Entries | ForEach-Object { $_.FullName -replace "\\", "/" }) } finally { $archive.Dispose() }
    # CHANGE: the files your package must hold (yours may be setup.ps1, an .msi, ...).
    $needed = "install.ps1", "uninstall.ps1"
    $missing = @($needed | Where-Object { $entries -notcontains $_ })
    Add-Result -Id "A1" -Title "Package contents" -Expect "the archive holds what the README lists" `
        -Status $(if ($missing) { "fail" } else { "pass" }) -Output ($entries -join "`n") `
        -Observed "$(Split-Path -Leaf $Zip), $([math]::Round((Get-Item $Zip).Length / 1MB, 1)) MB, $($entries.Count) entries, missing: $(if ($missing) { $missing -join ', ' } else { 'none' })"
}

# ---------------------------------------------------------------- guest up
if ($Gpu -and -not $PSBoundParameters.ContainsKey("Snapshot")) { $Snapshot = "clean-gpu" }
"restoring checkpoint '$Snapshot'"
# The finally block at the end runs also when the run stops early, so that no
# recorder and no guest is left running.
try {
    Measure-Step "restore checkpoint" { Restore-Guest -Snapshot $Snapshot }
    # A checkpoint does not keep the card, so it is attached after every restore.
    if ($Gpu) { Enable-GuestGpu }
    Measure-Step "start guest and wait for the desktop" {
        Start-Guest
        Wait-Guest -TimeoutSec 900
    }
    if ($Gpu) {
        $driver = Measure-Step "check the graphics driver" { Test-GuestGpuDriver }
        if (-not $driver.Match) { throw "the guest holds the graphics driver '$($driver.GuestDrivers -join ', ')' and the host now has '$($driver.HostDriver)'; run provision-gpu.ps1 -Force" }
        if (-not (Measure-Step "check the guest's display" { Test-GuestDisplay })) { throw "the guest's desktop has no screen with the graphics card attached; see Test-GuestDisplay in Vm.ps1" }
    }
    # Right after the sign-in Windows is busy by itself for a while; the film
    # and the first measurements should not start in the middle of it. The old
    # fixed 30 s is the deadline.
    Measure-Step "wait for the guest to be quiet" {
        $quiet = Wait-GuestIdle -BelowPercent 20 -TimeoutSec (30 * $Pace)
        Write-Timing -Kind wait -What "the guest's processors are quiet before the film" -Sec 0 -Deadline (30 * $Pace) -Met ($quiet -lt 20)
    }
    Start-Recording -Path (Join-Path $Report "recording\session.mp4") | Out-Null
    # Marked as downloaded from the internet, as a browser marks it.
    Measure-Step "copy the package" { Copy-ToGuest -Path $Zip -GuestDirectory "$guestHome\Downloads" -MarkDownloaded }
    $guestZip = "$guestHome\Downloads\$(Split-Path -Leaf $Zip)"

    Test-Case "B1" "Guest before install" "recorded only" {
        $facts = Get-Facts "before"
        Add-Result -Id "B1" -Title "Guest before install" -Expect "recorded only" -Status note -Shots @(Shot "desktop") `
            -Observed "Windows build $($facts.build); script policy $($facts.policy); git $(if ($facts.git) { 'present' } else { 'absent' }); adapters: $($facts.adapters -join ', '); runtime DLLs missing: $(if ($facts.missingDll) { $facts.missingDll -join ', ' } else { 'none' })"
    }

    # ---------------------------------------------------------------- C, install
    $documentedWorks = $false
    Test-Case "C1" "Unpack and install as the README says" "the documented command installs the app" {
        $unpack = "Expand-Archive -Path '$guestZip' -DestinationPath '$guestUnpacked' -Force"
        if ($app.UnpackWithExplorer) {
            $unpack += "; Get-ChildItem '$guestUnpacked' -Recurse -File | ForEach-Object { Set-Content -LiteralPath `$_.FullName -Stream Zone.Identifier -Value '[ZoneTransfer]', 'ZoneId=3' }"
        }
        Invoke-GuestScript -TimeoutSec 600 -Script $unpack | Out-Null
        # A new PowerShell without a bypass, as the user's terminal is.
        $line = "& powershell.exe -NoProfile -Command `"$($app.Install)`""
        $result = Install-InGuest "installed-as-documented" $line
        $script:documentedWorks = $result.Installed
        Add-Result -Id "C1" -Title "Unpack and install as the README says" -Expect "the documented command installs the app" `
            -Status $(if ($result.Installed) { "pass" } else { "fail" }) -Shots @(Shot "after-install") -Output $result.Run.Output `
            -Observed "command: $($app.Install); files in the install folder: $($result.Facts.installed.Count); on the user's PATH: $($result.Facts.onUserPath) times; Start menu shortcuts: $($result.Facts.shortcuts -join ', ')"
    }

    # The command the remaining install cases use: the documented one if it
    # works, the bypass otherwise.
    $installLine = if ($documentedWorks) { "& powershell.exe -NoProfile -Command `"$($app.Install)`"" } else { "& cmd.exe /c '$($app.InstallBypass)'" }

    if (-not $documentedWorks) {
        Test-Case "C1b" "Install with the script policy bypassed" "installs, so the later cases can run" {
            $result = Install-InGuest "installed-with-bypass" $installLine
            Add-Result -Id "C1b" -Title "Install with the script policy bypassed" -Expect "installs, so the later cases can run" `
                -Status $(if ($result.Installed) { "pass" } else { "fail" }) -Output $result.Run.Output `
                -Observed "command: $($app.InstallBypass); files in the install folder: $($result.Facts.installed.Count)"
        }
    }

    Test-Case "C2" "Install a second time" "nothing is duplicated" {
        $result = Install-InGuest "installed-twice" $installLine
        $ok = $result.Installed -and $result.Facts.onUserPath -le 1 -and $result.Facts.shortcuts.Count -le 1
        Add-Result -Id "C2" -Title "Install a second time" -Expect "nothing is duplicated" -Status $(if ($ok) { "pass" } else { "fail" }) -Output $result.Run.Output `
            -Observed "on the user's PATH: $($result.Facts.onUserPath) times; Start menu shortcuts: $($result.Facts.shortcuts.Count)"
    }
    # ---------------------------------------------------------------- E, first start
    $idleLoad = $null
    Test-Case "E1" "Start the app from the Start menu" "a window of the app opens" {
        $script:idleLoad = Wait-GuestIdle
        $search = Start-FromStartMenu
        $shot = Shot "first-start"
        # A guest whose processors the app keeps fully busy answers no command.
        # That is P1's finding; here the screenshot has to say whether a window opened.
        $facts = try { Get-Facts "first-start" -TimeoutSec 120 } catch { $null }
        if (-not $facts) {
            Add-Result -Id "E1" -Title "Start the app from the Start menu" -Expect "a window of the app opens" -Status note -Shots @($search, $shot) `
                -Observed "the guest answered no command while the app was open (see P1); read the screenshot"
            return
        }
        $windows = @($facts.processes | Where-Object { $_.window })
        Add-Result -Id "E1" -Title "Start the app from the Start menu" -Expect "a window of the app opens" `
            -Status $(if ($windows) { "pass" } else { "fail" }) -Shots @($search, $shot) `
            -Observed "processes: $($facts.processes.Count), with a window: $($windows.Count), title '$($windows.title -join ',')'"
    }

    Test-Case "P1" "Idle processor use" "an idle window leaves the processors idle" {
        # Measured by the host. A guest has no graphics processor, and an app that
        # animates there can keep every core busy and the guest too busy to answer.
        # The 20 s are the measurement itself, not a wait: a shorter window
        # would average out an app that animates now and then. Logged as a hold.
        $window20 = [System.Diagnostics.Stopwatch]::StartNew()
        $load = Get-GuestProcessorLoad -Seconds 20
        Write-Timing -Kind hold -What "P1: the idle app's processor load is measured over 20 s" -Sec $window20.Elapsed.TotalSeconds -Deadline 20
        $script:starved = $load -ge 90
        # Which Direct3D driver the app loaded: d3d10warp.dll draws on the
        # processor, a vendor's DLL (nv*, ati*, amd*, ig*) on a graphics card.
        $modules = "not asked, the guest is too busy"
        if (-not $starved) {
            $modules = (Invoke-GuestScript -TimeoutSec 60 -Script "((Get-Process '$($app.Process)').Modules | Where-Object { `$_.ModuleName -match '^(d3d10warp|nv|ati|amd|ig)' } | ForEach-Object ModuleName) -join ', '").Output
        }
        Add-Result -Id "P1" -Title "Idle processor use" -Expect "an idle window leaves the processors idle" `
            -Status $(if ($load -le $idleLoad + 15) { "pass" } else { "fail" }) -Shots @(Shot "idle") `
            -Observed "the guest's processors were $load percent busy over 20 s with the app idle; $idleLoad percent before it started; graphics drivers loaded by the app: $modules$(if ($starved) { '; the guest answers no command in this state, so later cases close the app by keyboard first and judge its windows from screenshots' })"
    }

    # ---------------------------------------------------------------- G, input
    # CHANGE: the shortcuts and click targets your app documents. Keys and
    # clicks are real input, so the result is in the screenshots: status "note".
    $window = $null
    Test-Case "G1" "Keyboard" "the documented shortcut does what the README says" {
        # Clicks the window's top edge, so the keys below go to the app, and
        # returns where the window is. Needed after Start-GuestExe, which opens a
        # window without the keyboard focus; harmless after a Start menu launch.
        # It asks the guest, so it is left out when the guest is too busy; the
        # Start menu launch gave the window the focus anyway.
        if (-not $starved) { $script:window = Show-GuestWindow -ProcessName $app.Process }
        $a = Shot "keys-before"
        # Each wait ends when the screen has reacted and stands still; the old
        # fixed time (2, 2 and 4 s) is its deadline.
        Send-Keys "ctrl+k"
        Wait-ScreenSettled -TimeoutSec 2 -What "the shortcut is answered"
        $b = Shot "keys-after-shortcut"
        Send-Text "settings"
        Wait-ScreenSettled -TimeoutSec 2 -What "the typed text is shown"
        Send-Keys "enter"
        Wait-ScreenSettled -TimeoutSec 4 -What "Enter is answered"
        $c = Shot "keys-after-enter"
        Add-Result -Id "G1" -Title "Keyboard" -Expect "the documented shortcut works" -Status note -Shots @($a, $b, $c) `
            -Observed "keys sent: Ctrl+K, 'settings', Enter; read the screenshots"
    }

    Test-Case "N1" "Mouse" "a click on a control presses it" {
        # CHANGE: the control's distance from a corner of the window, read off the
        # screenshot "keys-before" of an earlier run. Measuring from the window
        # keeps the click right when the window opens somewhere else.
        if (-not $window) { throw "no window position to measure from: the guest was too busy to give one (see P1)" }
        $x = $window.Right - 40; $y = $window.Top + 60
        Send-Click -X $x -Y $y
        Wait-ScreenSettled -TimeoutSec 3 -What "the click is answered"
        Add-Result -Id "N1" -Title "Mouse" -Expect "a click on a control presses it" -Status note -Shots @(Shot "after-click") `
            -Observed "clicked ($x,$y); read the screenshot"
    }

    Test-Case "H1" "Close the app" "Alt+F4 ends it" {
        Close-AppByKeyboard
        $facts = Get-Facts "closed"
        Add-Result -Id "H1" -Title "Close the app" -Expect "Alt+F4 ends it" -Status $(if ($facts.processes.Count) { "fail" } else { "pass" }) -Shots @(Shot "after-close") `
            -Observed "processes left: $(($facts.processes | ForEach-Object { $_.name }) -join ', ')"
        Stop-App
    }

    # ---------------------------------------------------------------- I, restart
    Test-Case "I1" "Restart Windows" "nothing of the app starts by itself; it starts again from the Start menu" {
        Restart-Guest
        Wait-Guest -TimeoutSec 900
        # The watch is the test: that nothing starts by itself shows only in a
        # window of this length in which the guest is looked at. Not shortened.
        Hold-For 40 -Reason "I1: nothing of the app may start by itself after a restart, which only a window of this length that is watched can show"
        $a = Shot "after-restart"
        $facts = Get-Facts "after-restart"
        $search = Start-FromStartMenu
        $b = Shot "start-after-restart"
        if ($starved) {
            Close-AppByKeyboard
            Add-Result -Id "I1" -Title "Restart Windows" -Expect "no autostart; the app starts again" -Status $(if ($facts.processes.Count) { "fail" } else { "note" }) -Shots @($a, $search, $b) `
                -Observed "processes right after the restart: $($facts.processes.Count); whether the app started again is read from the screenshot, as the guest was too busy to ask (see P1); the app was then closed"
            return
        }
        $facts2 = Get-Facts "start-after-restart" -TimeoutSec 120
        $windows = @($facts2.processes | Where-Object { $_.window })
        $ok = $facts.processes.Count -eq 0 -and $windows.Count -ge 1
        Add-Result -Id "I1" -Title "Restart Windows" -Expect "no autostart; the app starts again" -Status $(if ($ok) { "pass" } else { "fail" }) -Shots @($a, $search, $b) `
            -Observed "processes right after the restart: $($facts.processes.Count); windows after starting it again: $($windows.Count)"
    }

    # ---------------------------------------------------------------- K, uninstall
    Test-Case "K1" "Uninstall while the app runs" "processes stopped; files, PATH entry and shortcuts removed" {
        # With a starved guest the app was closed in I1, and this is a plain uninstall.
        # The documented command when C1 proved the documented install works; the
        # bypass otherwise, since C1 already reported that.
        if ($documentedWorks) {
            $command = $app.Uninstall -f $app.Target
            $line = "& powershell.exe -NoProfile -Command `"$command`""
        } else {
            $command = $app.UninstallBypass -f $app.Target
            $line = "& cmd.exe /c '$command'"
        }
        $run = Invoke-GuestScript -TimeoutSec 600 -Script "$line 2>&1; `"uninstall exit: `$LASTEXITCODE`"; `$global:LASTEXITCODE = 0"
        # An uninstaller may return while a copy of itself goes on deleting. Wait
        # until no process of the app runs and the install folder is gone; the old
        # fixed 3 s is the deadline (a folder the uninstall leaves behind, which
        # the case reports, holds this to it).
        [void](Wait-Until -What "the app's processes and install folder are gone" -TimeoutSec 3 -IntervalMs 500 {
                $check = Invoke-GuestScript -InProcess -TimeoutSec 30 -Script "`"left=`$(@(Get-Process '$($app.Process)*' -ErrorAction SilentlyContinue).Count + [int](Test-Path '$($app.Target)'))`""
                $check.Output -match 'left=0'
            })
        $facts = Get-Facts "uninstalled"
        $problems = @()
        if ($run.Output -notmatch "uninstall exit: 0") { $problems += "the uninstall command failed" }
        if ($facts.processes.Count) { $problems += "$($facts.processes.Count) processes still run" }
        if ($facts.onUserPath) { $problems += "PATH entry left" }
        if ($facts.shortcuts.Count) { $problems += "shortcut left" }
        Add-Result -Id "K1" -Title "Uninstall while the app runs" -Expect "processes stopped; files, PATH entry and shortcuts removed" `
            -Status $(if ($problems) { "fail" } else { "pass" }) -Shots @(Shot "after-uninstall") -Output $run.Output `
            -Observed "command: $command; $(if ($problems) { $problems -join '; ' } else { 'removed' }); left in the install folder: $(if ($facts.installed) { $facts.installed -join ', ' } else { 'nothing' })"
    }

    Test-Case "M1" "Windows event log" "no crash of the app was logged" {
        $facts = Get-Facts "final"
        Add-Result -Id "M1" -Title "Windows event log" -Expect "no crash of the app was logged" `
            -Status $(if ($facts.crashes.Count) { "fail" } else { "pass" }) -Shots @(Shot "final") `
            -Observed "$($facts.crashes.Count) crash entries name the app" -Output ($facts.crashes -join "`n`n")
    }
} finally {
    # ------------------------------------------------------------ wrap up
    Stop-Recording
    if (-not $KeepRunning) { Stop-Guest } else { Stop-GuestAgent }
}
Get-VM -Name $VmName | Select-Object Name, Generation, ProcessorCount, @{ n = "MemoryMb"; e = { $_.MemoryStartup / 1MB } }, Version |
    ConvertTo-Json | Set-Content (Join-Path $logs "vm.json")

Write-TimingSummary -Report $Report -Previous $Previous
$total = Get-TimingTotal (Read-TimingLog $Report)
if ($total) { "total: {0:n1} min ({1} min of setup before the film); timing in {2}" -f $total.Total, $(if ($null -ne $total.Setup) { "{0:n1}" -f $total.Setup } else { "n/a" }), (Join-Path $logs "timing.md") }

$counts = $results | Group-Object status | ForEach-Object { "$($_.Count) $($_.Name)" }
"done: $($counts -join ', '); evidence in $Report"
"next: read every screenshot, then write the report (the clean-vm-test skill says how)"
Stop-Transcript | Out-Null
