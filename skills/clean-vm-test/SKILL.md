---
name: clean-vm-test
description: >-
  This skill should be used when the user asks to "test the installer in a VM", "test
  in a virtual machine", "test the release build on a clean Windows", "try the package
  on a fresh machine", "test in Hyper-V", "does it run without the dev tools
  installed", "does it still work after sleep" or "what breaks after the computer
  sleeps", or wants screenshots or a screen recording of a Windows app running in a
  guest. Also use when a Windows app works on the development machine and nothing
  proves it installs and starts where the compiler, runtime libraries, git and a
  graphics card are missing, or when the guest test is too slow ("the VM test is too
  slow", "speed up the guest test"). Windows host with Hyper-V.
---

# Clean VM Test

A development machine hides what a user's machine lacks: runtime libraries, a graphics
card, git, a relaxed script policy. Install the shipped package into a Windows guest
that has none of them, use it as a user would, and keep the evidence.

Everything is driven from the host with the bundled PowerShell scripts. Nobody clicks.

## Before starting

Run these checks first.

```
(Get-Command Get-VM -ErrorAction SilentlyContinue) -ne $null            # Hyper-V module
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.SecurityIdentifier]"S-1-5-32-578")
Get-VM | Select-Object Name, State, @{ n = "MemoryMb"; e = { $_.MemoryStartup / 1MB } }
Get-VMSnapshot -VMName * | Select-Object VMName, Name
[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024)   # MB free
(Get-Command ffmpeg -ErrorAction SilentlyContinue) -ne $null            # needed for the recording
```

- **No Hyper-V module or no rights**: stop. The user turns the feature on, or adds the
  account to "Hyper-V Administrators" from an elevated shell and logs on again (command
  in `references/hyperv-notes.md`). Do not look for a way around missing rights.
- **A VM with a `clean` checkpoint exists**: reuse it. The guest is the same for every
  project; ask for its account and password if they are not the script defaults.
- **Free memory below the VM's `MemoryMb`** (or below `-MemoryMb` when provisioning):
  Hyper-V will not start the guest. Tell the user what uses the memory and offer the two
  ways out in `references/hyperv-notes.md`: they close programs, or working sets are
  trimmed. Never close the user's programs.
- **No ffmpeg and the user wants a recording**: say so before the run, not after.

## Workflow

1. **Copy the rig into the project**, to `scripts\vm\`: everything in this skill's
   `scripts\` folder, with its `guest\` subfolder. Rename the template after what it tests. The project then holds
   its own test and needs no plugin to run it.
2. **Provision once per Windows image** (10 to 40 minutes; a disk of 10 to 20 GB, and
   6 GB of temporary space while it runs):
   `pwsh scripts\vm\provision.ps1 -Iso <windows.iso>`. Needs `oscdimg.exe` from the
   Windows ADK. It ends with a VM that is off and a checkpoint named `clean`.
   For an app that draws with Direct3D, also run `pwsh scripts\vm\provision-gpu.ps1`
   (10 minutes, or an hour when it must update Windows first; up to 20 GB more). It
   adds the checkpoint `clean-gpu`, a guest with a share of the host's graphics card.
3. **Write the cases** in the copied template. Read the project's README and install
   notes first: the first install case does exactly what they tell a user to do.
4. **Run it** in the background and follow its log, `logs\run.log` in the report folder.
   Every run restores `clean` first.
   With `-Gpu` it restores `clean-gpu` and attaches the card. Run both passes when the
   app draws with Direct3D: they are two different user machines.
   Keep the run short and timed: see "Keep the run fast" below.
5. **Read every screenshot** the run saved. The script judges exit codes, files and
   processes. Only a reader can tell that a page is blank.
6. **Write the report as a Claude Artifact**, summary first, as
   `references/report-template.md` lays out. It is required, not offered: a test run
   ends with a published report.
   - Before writing the page, take the steps the `Artifact` tool asks for a new page
     (its quickstart, the design guidance it loads).
   - Write the page to `report.html` in the report folder. Embed the screenshots that
     illustrate each case and the recording, with a button per case that plays the
     recording from where the case began.
   - Publish it with `Artifact`: `file_path` the page, `root` the report folder, and
     `files` mapping `screenshots/NN-<case>.png` and `recording/session.mp4` to
     themselves. Check the size limits in the template first.
   - Write the link file `report\vm-test-<date>.html` (the run folder's name), in the
     `report` folder at the project root. It sends the browser to the published URL:

     ```html
     <!doctype html>
     <meta charset="utf-8">
     <meta http-equiv="refresh" content="0; url=<artifact URL>">
     <title>VM test report <date></title>
     <a href="<artifact URL>">VM test report <date>: <verdict in a few words></a>
     ```

   - A later run into the same folder updates the same Artifact: read the URL from the
     link file and publish with `url`, so the link file stays valid.
   - When the `Artifact` tool is missing or refuses, write the report as `report.md`
     in the report folder instead, as the template's "Without an Artifact" section
     says. Write no `report.html` and no link file, and tell the user why nothing was
     published.

   Give the user the link at the end. The Artifact is private until they share it.
7. **Shut the guest down** (`Stop-Guest`) and leave the VM and its checkpoint in place.

## Cases to cover

| Group | What to prove |
|---|---|
| Package | the archive holds what the docs promise |
| Baseline | what the guest lacks before install: runtime DLLs, git, graphics adapter, script policy |
| Install | the documented command works as written; a second install duplicates nothing |
| Command line | a newly started process finds the program on `PATH` and it runs |
| First start | started from the Start menu, a window appears; note stray console windows |
| Idle cost | how busy the guest is with the app idle, against just before it started |
| Pages | each main page draws (screenshot each) |
| Keyboard, mouse | shortcuts and clicks do what the docs say |
| Restart | after a Windows restart nothing starts by itself and the app starts again |
| Sleep and wake | after the guest sleeps and wakes, the app draws, answers input, reaches its background processes and the network, and its timed work runs again |
| Uninstall | processes, files, `PATH` entry and shortcuts are gone; list what stays |
| Event log | no crash of the app was logged |

A case with no documented expected result is recorded, not passed. Run the restart, sleep, uninstall and event-log cases even when the docs are silent about them; drop a group only when it cannot apply (no command-line program, no shortcut, no program
that keeps running).

### Sleep and wake

What breaks after a sleep shows only after one: a window that stays black because the graphics
device was lost, a connection to a background process or a server that never comes back, timed
work (an update check, a refresh) that never runs again or runs many times at once, a tray icon
that is gone, a login that expired.

A Hyper-V guest usually has no standby. `powercfg /a` in the guest lists the states it has. Put
it to sleep from the host in one of two ways:

| Way | How | What the app sees |
|---|---|---|
| Hibernate inside the guest | elevated in the guest (`Invoke-InGuest`): `powercfg /hibernate on`, then `Start-Process shutdown.exe -ArgumentList '/h'`, which returns before Windows goes down. On the host: `Wait-VmState -State Off`, wait, `Start-Guest`, `Wait-Guest` | what a sleeping laptop sends: the suspend and resume notices (`WM_POWERBROADCAST`), devices started again, a jump of the clock |
| Save the VM | `Save-VM -Name <vm>`, `Wait-VmState -State Saved`, wait, `Start-Guest`, `Wait-Guest` | no notice at all: the clock jumps and network connections may be gone; devices are untouched |

Run the hibernation way. Add the saved VM for an app that holds network connections open. Neither
shows Modern Standby, where a laptop keeps running at low power; say so in the report.

1. Before the sleep, turn off sign-in on wake in the guest, or the lock screen may cover the app
   in every screenshot after it: `powercfg /setacvalueindex scheme_current sub_none consolelock 0`,
   the same with `/setdcvalueindex`, then `powercfg /setactive scheme_current`.
2. Leave the app as a user would: a page open, its background processes running, in the tray if
   it has one. Take a screenshot; note the IDs of its processes.
3. Sleep the guest for a few minutes, longer than the app's longest timer or login when its docs
   name one.
4. After `Wait-Guest`, wait a minute with no input: a click would hide a window that redraws only
   on input. Take a screenshot.
5. Check: the same process IDs still run, unless the docs say the app restarts them; the window
   draws; keys and clicks work; the background process answers; one action that needs the network
   works; timed work runs at its next time and not many times at once; the tray icon is there; the
   event log and the app's log show no new crash or repeated error.

The recording goes on across the sleep: `record.ps1` repeats the last picture while the guest is
off. With the graphics card attached, Hyper-V may refuse to save or hibernate the guest, as it
refuses a checkpoint; then run the case in the pass without the card and say so in the report.
This case has not yet run on a real guest. After its first run, write what happened into
`references/hyperv-notes.md`.

The same goes for the bundled `scripts\test-template.ps1` and `Vm.ps1` as they are now: their
waiting, timing and helper functions were proven in a project's rig that shares this code, and
the template itself has not been run since the port. Run it on a few cases with `-Only` first.

## Helpers in `Vm.ps1`

| Function | Does |
|---|---|
| `Initialize-Vm -Name -User -Password [-NoAgent]` | call once after dot-sourcing; `-NoAgent` runs every guest script the old way |
| `Initialize-Timing -Path -Pace` | call once after it: the timing log's path and the factor `-Pace` stands for |
| `Restore-Guest`, `Start-Guest`, `Wait-Guest`, `Stop-Guest`, `Restart-Guest` | checkpoint and power; `Wait-Guest` returns at the logged-in desktop |
| `Copy-ToGuest -Path -GuestDirectory [-MarkDownloaded]` | file or folder in, unpacked as the guest user; `-MarkDownloaded` marks it as a browser download |
| `Copy-FromGuest -GuestPath -Destination` | file or folder out |
| `Invoke-GuestScript -Script` | PowerShell 5.1 code on the user's desktop; returns `Output`, `ExitCode`, `Completed`. `-InProcess` runs a rig instrument that reads and starts nothing (window position, log read, process wait) in a runspace of the guest helper instead of a fresh process; it sees the helper's environment, not a fresh one |
| `Invoke-GuestExe -Exe -Arguments` | one program; returns `ExitCode`, `Stdout`, `Stderr` |
| `Start-GuestExe -Exe -Arguments` | a window program, not waited for |
| `Show-GuestWindow -ProcessName` | waits for the window, gives it the keyboard focus, returns its position |
| `Save-Screenshot -Path` | the guest's screen as PNG |
| `Send-Keys "ctrl+k", "enter"`, `Send-Text "words"` | real key presses |
| `Send-Click -X -Y`, `Send-Scroll` | real mouse input, in screen pixels |
| `Get-GuestProcessorLoad`, `Wait-GuestIdle` | how busy the guest is, measured by the host |
| `Wait-Until -What -TimeoutSec { condition }` | polls the condition (`-IntervalMs`, default 250); returns its value, or `$null` at the deadline, when the run goes on (`-Throw` throws instead); logs the wait, and whether it hit its deadline |
| `Hold-For -Seconds -Reason [-Exact]` | a deliberate pause that is part of a test; logged and named; `-Exact` is not stretched by `-Pace` |
| `Wait-ScreenChange -TimeoutSec [-Since frame]`, `Wait-ScreenStill -TimeoutSec [-QuietMs -MinSec]`, `Wait-ScreenSettled -TimeoutSec` | watch the guest's thumbnail from the host (`Get-ScreenFrame` takes the frame for `-Since`). Both take a `-Region` (left, top, right, bottom in thumbnail pixels, 480x270) and a `-Tolerance`: the share of pixels that may differ, 0.005, or 0.05 when `$script:Vm.Gpu` is set, because an animated backdrop never stands still. `Wait-ScreenSettled` is the usual wait after an input: it lets 40 percent of the deadline pass, then waits for stillness. They return a value only with `-PassThru` |
| `Wait-GuestProcessGone -Name -TimeoutSec` | waits until no process of that name (or names) runs in the guest; returns how many were left (`$null`: the guest did not answer) |
| `Measure-Step "name" { block }` | runs the block and logs how long it took, for the setup steps |
| `Start-GuestAgent`, `Stop-GuestAgent` | start or end the guest helper; `Invoke-GuestScript` starts it by itself, and `Start-Guest`, `Stop-Guest` and `Restore-Guest` forget it |
| `Write-TimingSummary -Report [-Previous]` | writes `logs\timing.md` from `logs\timing.jsonl` |
| `Enable-GuestGpu`, `Disable-GuestGpu` | attach the host's graphics card after a restore, or remove it; the VM must be off |
| `Test-GuestGpuDriver`, `Test-GuestDisplay`, `Get-GuestDisplayAdapters` | check the driver copy, the screen, and the adapters Windows started |
| `Update-GuestWindows`, `Get-GuestBuild` | install the monthly Windows update in the guest |
| `Start-Recording -Path`, `Stop-Recording` | MP4 of the whole run; needs ffmpeg |

`-Background` on the two `Invoke-` functions runs elevated and without a desktop. Keep
it for housekeeping.

`-NoGuestAgent` (a switch of the test script, passed on as `Initialize-Vm -NoAgent`) forces
the old way, one scheduled task per guest command. Use it as the A/B baseline, and to tell a
rig failure from an app failure. The test script's other switches for this: `-Only <ids>`,
`-Skip <patterns>`, `-Pace`, `-Previous <report folder>`.

## Keep the run fast

A full pass is long, and most of the time is waiting the rig chose, not waiting the app
needs. Measured costs and mechanisms: `references/hyperv-notes.md`, "What a run costs".

| Rule | Do |
|---|---|
| **Wait for a condition, not a time** | Never sleep a fixed time for what the rig can observe. `Wait-Until -What "<what>" -TimeoutSec n { condition }`; the old fixed time is a good deadline. At the deadline the script goes on, as the sleep did, and the case's own checks judge. The timing summary lists it as "hit its deadline", so a slow page shows up as a number |
| **Observe, cheapest first** | The VM's state and the guest's load (host). The screen changing or standing still (host thumbnail; `Wait-ScreenChange`, `Wait-ScreenStill`). A process, window, file, log line or HTTP answer (guest). UI Automation cannot read every window (a GPU-drawn one, for instance) |
| **Have the app say when a page is drawn** | When the app is yours: one log line after the frame that shows the page with its data, naming the kind of page and never user content. The project's rig waits for it (a `Wait-AppPage`-style helper that reads the log from a line mark taken before the action). With no such line, wait for the screen to stand still |
| **A deliberate pause is a test** | Keep it and mark it: `Hold-For -Seconds n -Reason "<why>"`, never a bare sleep. Examples: the pointer resting on a button before a click, an app started and left alone, an idle-load window, a check that something does NOT happen, input pacing that was measured as needed. A speed pass leaves every `Hold-For` alone |
| **One helper, not a task per guest command** | One helper process in the logged-in desktop session, fed scripts through a file queue over one persistent PowerShell Direct session. Each script still runs as a fresh process with a fresh environment, and its children die with it. A script that ends by itself leaves its children alone, as a scheduled task did; one that times out takes them with it. Fall back to the scheduled-task path when the helper cannot start or never takes the request, or says it did not start the script; a request the helper took is never run a second time |
| **Keep the checkpoint current** | A checkpoint that needs the same fix-up at the start of every run (a driver copy, an update, an install) is retaken once. Keep the old one under a dated name until the user says it can go |
| **Copy once** | Send what the run needs as one archive at setup, not a file per case |
| **Time everything** | `logs\timing.jsonl` holds one line for every case, step, wait, hold and guest call: when it ended, how many seconds it took, the case it ran in, and for a wait its deadline and whether it was met. `results.json` gives each case `started`, `ended`, `seconds`. `Write-TimingSummary` writes `logs\timing.md`: total, time before the film starts, slowest cases and waits, time by kind, waits that hit their deadline, fallbacks taken, guest calls by lane, difference to the previous run. Never log script text; it can hold a token |
| **The film stays real-time and uncut** | Do not cut still stretches: a real hang must stay visible, and the report's seek buttons depend on the film's clock |
| **Prove a rig change on a subset first** | A few cases with `-Only` (after the usual setup) take minutes; a full pass takes an hour. Compare each case's status with the last full run. Run the full pass once, at the end |
| **`-Pace`** | The template's switch that multiplies waits. It scales deadlines and deliberate pauses (`Hold-For`, unless it has `-Exact`), never poll intervals |

The helper's design and its fallback rules are in `references/hyperv-notes.md`.

## Rules

- **Test what ships.** Build the package with the project's own packaging step. Never
  copy programs out of the build folder into the guest.
- **Leave the guest as Windows ships it.** Provisioning does not touch the script
  execution policy, Defender or UAC. A test that loosens them proves nothing.
- **Follow the docs before helping them.** Run the documented install command unchanged
  first: the template's `Install` and `Uninstall` settings hold the commands as the
  README gives them, with no bypass. If the install fails, that is a finding, and the
  template then installs with `InstallBypass` (case C1b) and uninstalls with
  `UninstallBypass` so the later cases can run.
- **Deliver the package as a download.** The template marks the copied zip as downloaded
  from the internet, as a browser does, and `UnpackWithExplorer` marks the unpacked files
  as Explorer's "Extract All" does. Set it to `$false` when the README unpacks with
  `Expand-Archive`, which marks nothing.
- **Empty output is a failed probe.** A command that timed out prints nothing. Never
  read nothing as "no process is running" or "no file is left".
- **A harness failure is not an app failure.** Report it as inconclusive and rerun.
- **The guest `provision.ps1` builds has no graphics card.** Its only display adapter is
  "Microsoft Hyper-V Video", so Direct3D runs on the processor. That is a real case
  (virtual machines, remote desktop, broken drivers) but not the usual user's machine.
  The `-Gpu` pass covers that one; without it, say in the report that nothing was
  proven about a real graphics card. Measure idle
  processor use early, from the host (`Get-GuestProcessorLoad`): an app that animates
  can keep every core busy, and the guest then answers no command at all. Keys, clicks
  and screenshots still work; close the app with `Send-Keys "alt+f4"` to get it back.
  The template does that by itself once P1 measures 90 percent or more. If the app has
  a setting that stops the redrawing, add a second pass with it set, so that the
  keyboard, mouse and page cases can be judged.
- **A low idle load proves a graphics card only with a picture.** On some Windows builds
  a guest with the card attached draws nothing at all, and the load is then perfect.
  Check `Test-GuestDisplay`, look at a screenshot, and record which Direct3D DLL the app
  loaded (`d3d10warp.dll` is the processor). Details in `references/hyperv-notes.md`.
- **Sharing the card is outside Microsoft's supported setups** on a Windows 11 host with
  a desktop card. Say so in the report. After a graphics driver update on the host, run
  `provision-gpu.ps1 -Force`; a `-Gpu` run stops and says so when the copy is stale.
- **Check the focus before judging a keyboard case.** If the first screenshot after a
  shortcut shows no change, look for where the keys went before blaming the app.
- **An unactivated guest is fine.** Never run an activation tool that bypasses licensing.

## Mistakes that cost hours

| Mistake | What happens | Do instead |
|---|---|---|
| Starting a window program in the PowerShell Direct session | it runs in session 0; nothing appears on the desktop | `Start-GuestExe` |
| Looking for windows from that session | every `MainWindowHandle` is 0 | `Invoke-GuestScript` without `-Background` |
| Sending keys right after `Start-GuestExe` | the window has no focus; the keys open things on the desktop | `Show-GuestWindow` first |
| Running the guest code with `-ExecutionPolicy Bypass` and starting scripts from it | the bypass travels to child processes; a blocked install passes | `Invoke-GuestScript` clears it; keep it that way |
| Measuring processor use inside a busy guest | the command never answers | `Get-GuestProcessorLoad` on the host |
| Measuring right after boot or install | Windows itself is busy; the baseline is useless | `Wait-GuestIdle` |
| Typing a whole string at once | the guest loses characters | `Send-Text` (one character per 60 ms) |
| Naming a helper `Start-Vm` or `Stop-Vm` | it replaces the cmdlet and calls itself | the `-Guest` names |
| Attaching a second DVD with the answer file | the ISO's own `autounattend.xml` can win | `provision.ps1` rebuilds the ISO |
| Copying files with `Copy-Item -ToSession` from a cloud-synced folder | "Cannot convert value 524320 to FileAttributes" | `Copy-ToGuest` (sends a zip) |
| Marking a page case passed because the window exists | a blank page passes | read the screenshot |
| Trusting a click position after the layout changed | the click lands elsewhere | take a screenshot, read the position again |
| A fixed wait after every action | most of it is idle; one project lost 42 of 100 minutes to sleeps, while pages drew in under a second | `Wait-Until` with the old time as the deadline |
| A new scheduled task per guest command | 3 to 4 s each before the command runs; about 500 commands is 20 to 30 minutes | the one guest helper |
| Fixing up the checkpoint at the start of every run | the same 3 to 8 minutes of setup, every pass | retake the checkpoint once; keep the old one under a dated name |
| Cutting the still stretches out of the film | a real hang disappears and the seek buttons point at the wrong time | keep the film real-time and uncut |
| Logging no durations | slow spots are found only by watching the film | `logs\timing.jsonl`, `Write-TimingSummary`, durations in the report |
| Removing a pause because it looks like a sleep | a dead button or a late redraw goes unseen | a `Hold-For` with a reason stays; a speed pass touches bare sleeps only |
| Proving a rig change with a full pass | an hour per try | `-Only` on a few cases, then one full pass |

## Additional Resources

- **`references/hyperv-notes.md`**: links to Microsoft's page for every interface used,
  and beside each what that page does not say: rights, the two places to run code in
  the guest, typing, screenshot format, unattended install, memory, the graphics card,
  and what to do without Hyper-V. Also what a run costs, and how the guest helper works.
- **`references/report-template.md`**: report layout, verdicts, severities, embedding
  screenshots and the recording, and the Artifact size limits.
- **`scripts/`**: `Vm.ps1`, `record.ps1`, `provision.ps1`, `provision-gpu.ps1`,
  `autounattend.xml`, `guest/update-windows.ps1`, `guest/agent.ps1` (the guest helper),
  `test-template.ps1`. Run them with
  `pwsh`, never by bare path.
