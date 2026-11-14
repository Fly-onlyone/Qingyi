---
name: clean-vm-test
description: >-
  This skill should be used when the user asks to "test the installer in a VM", "test
  in a virtual machine", "test the release build on a clean Windows", "try the package
  on a fresh machine", "test in Hyper-V" or "does it run without the dev tools
  installed", or wants screenshots or a screen recording of a Windows app running in a
  guest. Also use when a Windows app works on the development
  machine and nothing proves it installs and starts where the compiler, runtime
  libraries, git and a graphics card are missing. Windows host with Hyper-V.
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
5. **Read every screenshot** the run saved. The script judges exit codes, files and
   processes. Only a reader can tell that a page is blank.
6. **Write the report**, summary first, as `references/report-template.md` lays out.
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
| Uninstall | processes, files, `PATH` entry and shortcuts are gone; list what stays |
| Event log | no crash of the app was logged |

A case with no documented expected result is recorded, not passed. Run the restart, uninstall and event-log cases even when the docs are silent about them; drop a group only when it cannot apply (no command-line program, no shortcut).

## Helpers in `Vm.ps1`

| Function | Does |
|---|---|
| `Initialize-Vm -Name -User -Password` | call once after dot-sourcing |
| `Restore-Guest`, `Start-Guest`, `Wait-Guest`, `Stop-Guest`, `Restart-Guest` | checkpoint and power; `Wait-Guest` returns at the logged-in desktop |
| `Copy-ToGuest -Path -GuestDirectory [-MarkDownloaded]` | file or folder in, unpacked as the guest user; `-MarkDownloaded` marks it as a browser download |
| `Copy-FromGuest -GuestPath -Destination` | file or folder out |
| `Invoke-GuestScript -Script` | PowerShell 5.1 code on the user's desktop; returns `Output`, `ExitCode`, `Completed` |
| `Invoke-GuestExe -Exe -Arguments` | one program; returns `ExitCode`, `Stdout`, `Stderr` |
| `Start-GuestExe -Exe -Arguments` | a window program, not waited for |
| `Show-GuestWindow -ProcessName` | waits for the window, gives it the keyboard focus, returns its position |
| `Save-Screenshot -Path` | the guest's screen as PNG |
| `Send-Keys "ctrl+k", "enter"`, `Send-Text "words"` | real key presses |
| `Send-Click -X -Y`, `Send-Scroll` | real mouse input, in screen pixels |
| `Get-GuestProcessorLoad`, `Wait-GuestIdle` | how busy the guest is, measured by the host |
| `Enable-GuestGpu`, `Disable-GuestGpu` | attach the host's graphics card after a restore, or remove it; the VM must be off |
| `Test-GuestGpuDriver`, `Test-GuestDisplay`, `Get-GuestDisplayAdapters` | check the driver copy, the screen, and the adapters Windows started |
| `Update-GuestWindows`, `Get-GuestBuild` | install the monthly Windows update in the guest |
| `Start-Recording -Path`, `Stop-Recording` | MP4 of the whole run; needs ffmpeg |

`-Background` on the two `Invoke-` functions runs elevated and without a desktop. Keep
it for housekeeping.

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

## Additional Resources

- **`references/hyperv-notes.md`**: links to Microsoft's page for every interface used,
  and beside each what that page does not say: rights, the two places to run code in
  the guest, typing, screenshot format, unattended install, memory, the graphics card,
  and what to do without Hyper-V.
- **`references/report-template.md`**: report layout, verdicts, severities.
- **`scripts/`**: `Vm.ps1`, `record.ps1`, `provision.ps1`, `provision-gpu.ps1`,
  `autounattend.xml`, `guest/update-windows.ps1`, `test-template.ps1`. Run them with
  `pwsh`, never by bare path.
