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
# a started time), logs\results.json, logs\facts-*.json and logs\run.log, a transcript of
# everything the run prints. The script decides only what a program can decide
# (exit codes, files, processes). Whether a page was drawn correctly is for
# whoever reads the screenshots.
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
    # Multiplies every wait; raise it on a slow host.
    [double]$Pace = 1.0
)
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "Vm.ps1")
Initialize-Vm -Name $VmName -User $User -Password $Password

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
# Everything this run prints, for the report and for following a background run.
Start-Transcript -Path (Join-Path $logs "run.log") -Force | Out-Null
$guestUnpacked = "$guestHome\Downloads\$($app.Name)"

# ---------------------------------------------------------------- harness
$results = [System.Collections.Generic.List[object]]::new()
$shotCount = 0

function Wait-For { param([double]$Seconds) Start-Sleep -Milliseconds ([int]($Seconds * 1000 * $Pace)) }

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
    # When the case began, so the report can jump the recording to it
    # (recording\session.start.txt holds when the film began).
    $started = if ($script:caseStarted) { $script:caseStarted } else { Get-Date }
    $results.Add([pscustomobject]@{
            id = $Id; title = $Title; expect = $Expect; status = $Status
            observed = $Observed; screenshots = $Shots; output = $Output
            started = $started.ToString("o")
        })
    "{0,-5} {1,-4} {2}" -f $Status, $Id, $Observed
    $results | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $logs "results.json")
}

# Run one case; a thrown error becomes an "error" result and the run goes on.
function Test-Case {
    param([string]$Id, [string]$Title, [string]$Expect, [scriptblock]$Body)
    $script:caseStarted = Get-Date
    try {
        & $Body
    } catch {
        $shot = try { Shot "$Id-error" } catch { $null }
        Add-Result -Id $Id -Title $Title -Expect $Expect -Status error `
            -Observed "the harness failed: $($_.Exception.Message)" -Shots @($shot | Where-Object { $_ })
    } finally {
        $script:caseStarted = $null
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
    Wait-For 4
    Send-Text $app.Name
    Wait-For 6
    $found = Shot "start-menu-search"
    Send-Keys "enter"
    Wait-For 20
    $found
}

# True once P1 has found that the idle app keeps the guest too busy to answer
# commands. Keys, clicks and screenshots still work then, so later cases
# close the app by keyboard before they ask the guest anything.
$starved = $false

# Close the app without asking the guest, and wait until the guest answers again.
function Close-AppByKeyboard {
    Send-Keys "alt+f4"
    Wait-For 5
    Wait-Guest -TimeoutSec 300
}

function Stop-App {
    Invoke-GuestScript -Script "Get-Process '$($app.Process)' -ErrorAction SilentlyContinue | Stop-Process -Force" | Out-Null
    Wait-For 2
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
    Restore-Guest -Snapshot $Snapshot
    # A checkpoint does not keep the card, so it is attached after every restore.
    if ($Gpu) { Enable-GuestGpu }
    Start-Guest
    Wait-Guest -TimeoutSec 900
    if ($Gpu) {
        $driver = Test-GuestGpuDriver
        if (-not $driver.Match) { throw "the guest holds the graphics driver '$($driver.GuestDrivers -join ', ')' and the host now has '$($driver.HostDriver)'; run provision-gpu.ps1 -Force" }
        if (-not (Test-GuestDisplay)) { throw "the guest's desktop has no screen with the graphics card attached; see Test-GuestDisplay in Vm.ps1" }
    }
    Wait-For 30
    Start-Recording -Path (Join-Path $Report "recording\session.mp4") | Out-Null
    # Marked as downloaded from the internet, as a browser marks it.
    Copy-ToGuest -Path $Zip -GuestDirectory "$guestHome\Downloads" -MarkDownloaded
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
        $load = Get-GuestProcessorLoad -Seconds 20
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
        Send-Keys "ctrl+k"; Wait-For 2
        $b = Shot "keys-after-shortcut"
        Send-Text "settings"; Wait-For 2
        Send-Keys "enter"; Wait-For 4
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
        Send-Click -X $x -Y $y; Wait-For 3
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
        Wait-For 40
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
        Wait-For 3
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
    if (-not $KeepRunning) { Stop-Guest }
}
Get-VM -Name $VmName | Select-Object Name, Generation, ProcessorCount, @{ n = "MemoryMb"; e = { $_.MemoryStartup / 1MB } }, Version |
    ConvertTo-Json | Set-Content (Join-Path $logs "vm.json")

$counts = $results | Group-Object status | ForEach-Object { "$($_.Count) $($_.Name)" }
"done: $($counts -join ', '); evidence in $Report"
"next: read every screenshot, then write report.md"
Stop-Transcript | Out-Null
