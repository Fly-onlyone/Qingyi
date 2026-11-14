# Hyper-V reference

Each section names the Microsoft page that documents the interface, then what that page
does not say and was measured here. The measurements are from Windows 11 Pro (host build
26300, PowerShell 7.7, guest Windows 11 25H2), from a shell that was not elevated, with
the account in "Hyper-V Administrators". When a call fails, read the Microsoft page
first: it is the authority, the measurements are one machine's.

## Microsoft documentation

| Topic | Page |
|---|---|
| PowerShell Direct | https://learn.microsoft.com/windows-server/virtualization/hyper-v/powershell-direct |
| Keyboard: `Msvm_Keyboard` | https://learn.microsoft.com/windows/win32/hyperv_v2/msvm-keyboard |
| `PressKey`, `TypeKey`, `TypeText` | https://learn.microsoft.com/windows/win32/hyperv_v2/presskey-msvm-keyboard, https://learn.microsoft.com/windows/win32/hyperv_v2/typekey-msvm-keyboard, https://learn.microsoft.com/windows/win32/hyperv_v2/typetext-msvm-keyboard |
| Virtual-key codes | https://learn.microsoft.com/windows/win32/inputdev/virtual-key-codes |
| Mouse: `Msvm_SyntheticMouse` | https://learn.microsoft.com/windows/win32/hyperv_v2/msvm-syntheticmouse |
| `SetAbsolutePosition`, `ClickButton` | https://learn.microsoft.com/windows/win32/hyperv_v2/setabsoluteposition-msvm-syntheticmouse, https://learn.microsoft.com/windows/win32/hyperv_v2/clickbutton-msvm-syntheticmouse |
| Screenshot: `GetVirtualSystemThumbnailImage` | https://learn.microsoft.com/windows/win32/hyperv_v2/getvirtualsystemthumbnailimage-msvm-virtualsystemmanagementservice |
| Answer files and where Setup looks for them | https://learn.microsoft.com/windows-hardware/manufacture/desktop/windows-setup-automation-overview?view=windows-11 |
| `oscdimg` options | https://learn.microsoft.com/windows-hardware/manufacture/desktop/oscdimg-command-line-options?view=windows-11 |
| GPU partitioning: requirements | https://learn.microsoft.com/windows-server/virtualization/hyper-v/gpu-partitioning |
| GPU partitioning: assigning a partition | https://learn.microsoft.com/windows-server/virtualization/hyper-v/partition-assign-vm-gpu |
| `Add-VMGpuPartitionAdapter` | https://learn.microsoft.com/powershell/module/hyper-v/add-vmgpupartitionadapter |
| GPU paravirtualization (driver side) | https://learn.microsoft.com/windows-hardware/drivers/display/gpu-paravirtualization |

## Rights

| Needs | Why |
|---|---|
| Windows feature "Hyper-V" (Pro, Enterprise, Education) | cmdlets, `vmms`, the WMI namespace `root\virtualization\v2` |
| Account in "Hyper-V Administrators" | PowerShell Direct asks for it ("You must be logged into the host computer as a Hyper-V administrator"); everything else here worked with it, without elevation |
| `oscdimg.exe` (Windows ADK, Deployment Tools) | builds the install ISO; once per image |
| `ffmpeg` on PATH | screen recording only; screenshots work without it |

Adding the account to the group needs one elevated command and a new logon. It is the
user's step, never something to work around:

```
Add-LocalGroupMember -Group "Hyper-V Administrators" -Member $env:USERNAME
```

## Commands in the guest: PowerShell Direct

Microsoft: host and guest Windows 10 or Server 2016 or later, the VM running locally with
at least one user profile, valid guest credentials.

Not in the docs, measured:

| | PowerShell Direct session | Desktop session (scheduled task) |
|---|---|---|
| Windows session | 0 | 1, the logged-in user's |
| Rights | elevated | the user's everyday rights |
| Sees windows | no; `MainWindowHandle` is 0 for every process | yes |
| A dialog it raises | invisible | shows in a screenshot |
| Use for | waiting for boot, housekeeping, writing to System32 | everything a user would do |

`Invoke-GuestScript` and `Invoke-GuestExe` use the desktop session unless `-Background` is
given. `Start-GuestExe` starts a window program there and does not wait.

- A scheduled task runs at below-normal priority. The helpers set `-Priority 4`; without
  it every timing and processor measurement is wrong.
- A console program started by a task opens a window that takes the keyboard focus from
  the program under test. The helpers start it under `conhost.exe --headless`.
- Each call opens a session of its own, so the code sees the environment a newly started
  program sees. A session kept open keeps its old `PATH`.
- `powershell -ExecutionPolicy Bypass` stores the bypass in the environment variable
  `PSExecutionPolicyPreference`, and every child process inherits it. A test of "does
  the install script run under the default policy" then passes when it should fail.
  `Invoke-GuestScript` removes the variable before it runs the test's code.
- A window opened by a scheduled task does not get the keyboard focus. `Show-GuestWindow`
  clicks the window's top edge, which is real input and does give it the focus. A program
  started through the Start menu with `Send-Keys` has the focus already.
- A session fails while Windows starts, and after about 30 seconds ("An error has
  occurred which PowerShell cannot handle. A remote session might have ended.", once
  "The credential is invalid.") when the guest's processors are fully busy. The second
  is a finding about the guest's load, not a rig fault.
- `Copy-Item -ToSession` fails on files from a cloud-synced folder ("Cannot convert value
  524320 to FileAttributes"). `Copy-ToGuest` sends one zip instead.
- A copied file carries no Mark of the Web, unlike a browser download, so a script from
  it runs under `RemoteSigned` where the user's download would not.
  `Copy-ToGuest -MarkDownloaded` adds the mark: the `Zone.Identifier` stream with
  `ZoneId=3`. `Expand-Archive` in PowerShell 5.1 and 7.7 does not copy the mark onto the
  files it extracts (measured on the host).

## Keyboard and mouse

Microsoft: `PressKey`, `ReleaseKey` and `TypeKey` take a virtual-key code.
`SetAbsolutePosition` takes the position "in pixels". `ClickButton` takes "the 1-based
index of the button".

Not in the docs, measured:

- Buttons: 1 left, 2 right, 3 middle. Positions are pixels of the guest's screen from the
  top left.
- `TypeText` with a whole string loses characters in the guest. So does one character at
  a time with no pause. One character every 60 ms arrived complete. `Send-Text` does that.
- A chord is `PressKey` for each key in order, then `ReleaseKey` in reverse.
- Click positions are read off a screenshot and measured from the window position that
  `Show-GuestWindow` returns. That position includes an unseen border of 8 pixels.
- Much writing about Hyper-V says the host cannot move the guest's mouse. It can.

## Screenshots and film

Microsoft: the picture is "in raw RGB 565 format", at the width and height asked for.

Not in the docs, measured:

- Read through `Invoke-CimMethod`, the array has four extra bytes in front (its own
  length). `Get-GuestScreenBytes` drops them.
- Time per picture grows fast with size: 0.65 s at 1600x900, 0.2 s at 1280x720, 0.06 s at
  960x540. Screenshots are taken full size, the film at 1280 wide, 4 pictures a second.
- 16-bit color shows faint bands in gradients. Do not report those as a defect of the app.
- The picture needs no open VM window and no one at the host console.
- Hyper-V has no recorder. `record.ps1` pipes the pictures to ffmpeg as fragmented MP4,
  which stays playable if the recorder is killed. While the VM restarts the last picture
  repeats, so one file covers a restart.
- The screen size is fixed with `Set-VMVideo -ResolutionType Single` while the VM is off,
  and read back from `Msvm_VideoHead`.

## Unattended install

Microsoft: Setup searches for an answer file in a fixed order; "removable read/write
media", then "removable read-only media in order of drive letter, at the root of the
drive", come before the Windows distribution itself.

What follows from that, and what was measured:

- An ISO can carry an `autounattend.xml` already (tiny11 does). A second DVD with another
  file is the same kind of media, so which one wins depends on drive letters.
  `provision.ps1` copies the ISO's content, replaces the file and builds a new ISO.
- Building with `efisys_noprompt.bin` as the boot image removes "Press any key to boot
  from CD or DVD", which nobody is there to press:
  `oscdimg -m -o -u2 -udfver102 "-bootdata:1#pEF,e,b<media>\efi\microsoft\boot\efisys_noprompt.bin" <media> <out.iso>`
- No network adapter is connected during Setup. The first-run screens then finish with
  the local account and fetch no updates. The adapter is connected before the checkpoint.
- `net accounts /maxpwage:unlimited` runs at first logon. Without it the password expires
  weeks after the checkpoint and the automatic logon stops.
- A stock multi-edition ISO needs `-ProductKey` to choose the edition. Use a key the user
  owns or Microsoft's published generic install key for that edition. An unactivated
  guest is fine for testing. Never run an activation tool that bypasses licensing.
- The checkpoint is taken with the VM off, after one cold start proved that it reaches
  the desktop.

Measured: Windows installed in 5 minutes, the whole provisioning took 8, a cold start
reached the desktop in 38 seconds.

## Memory

Hyper-V gives a guest with fixed memory all of it at start and refuses to start it
otherwise (`Unable to allocate 2048 MB of RAM ... 0x800705AA`). `provision.ps1` checks
first.

- 2048 MB is enough for a stripped image, 4096 MB for stock Windows 11.
- Free memory is `(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory` in KB.
- When it is short, tell the user what is using it and let them close programs. Trimming
  working sets (`EmptyWorkingSet` from `psapi.dll`) frees memory without closing
  anything, at the cost of a slow minute in those programs. Never close the user's
  programs.

## Measuring the guest from the host

The counter `\Hyper-V Hypervisor Virtual Processor(*)\% Guest Run Time` has one
instance per virtual processor, named `<vm name>:hv vp <n>`. It needs no answer from
the guest. `Get-GuestProcessorLoad` averages it over all of the VM's processors. Reading
it worked without elevation for an account in both "Hyper-V Administrators" and
"Performance Log Users"; which of the two it needs was not tested.

## Graphics card in the guest

A guest made by `provision.ps1` has one display adapter, "Microsoft Hyper-V Video". It
has no 3D hardware, so Direct3D and the desktop compositor draw on the processor
(`d3d10warp.dll`). An app that redraws all the time can fill every virtual processor
that way while it sits idle. Test that case; it is what a user on a remote desktop or
with a broken driver gets.

`provision-gpu.ps1` adds the other case: a share of the host's graphics card, through GPU
paravirtualization, the mechanism Windows Sandbox and WSL use. It makes a second
checkpoint, `clean-gpu`; a test restores that and calls `Enable-GuestGpu` before
`Start-Guest`.

Microsoft: GPU partitioning is documented for Windows Server 2025 hosts and a list of
data-center cards. The driver-side page describes the guest's two adapters, the
`HostDriverStore` folder and the registry values used below. **A Windows 11 host with a
desktop card is not a supported setup.** It works where `Get-VMHostPartitionableGpu`
lists the card. Say so in the report.

Not in the docs, measured (Windows 11 Pro host, NVIDIA RTX 4070, driver 32.0.16.2114):

- `Add-VMGpuPartitionAdapter` and `Set-VM -GuestControlledCacheTypes $true
  -LowMemoryMappedIoSpace 1GB -HighMemoryMappedIoSpace 16GB` (the values of Microsoft's
  sample) worked without elevation, with the VM off.
- The guest loads the driver's user-mode half from
  `System32\HostDriverStore\FileRepository\<folder>`, where `<folder>` is the driver's
  folder name in the host's `System32\DriverStore\FileRepository`. Without it the card
  is in Device Manager with problem code 43.
- **Copying that folder is the only way for a full VM.** Microsoft's page describes an
  automatic copy and says "This feature is disabled in the released version of the OS".
  Its registry value `DriverStoreCopyMode`, set to 2 in the guest, did nothing. Hyper-V
  maps the host's driver store only into containers.
- **After a graphics driver update on the host** the folder name changes and the guest's
  copy is stale. `Test-GuestGpuDriver` compares the two names; the fix is
  `provision-gpu.ps1 -Force`, about 10 minutes. What a stale copy does was not tested;
  expect problem code 43 or drawing on the processor.
- A checkpoint does not keep the adapter (Microsoft's sample turns checkpoints off for
  such a VM). So the checkpoint is taken without it and `Enable-GuestGpu` adds it after
  every restore.
- With the card working, the guest lists "NVIDIA GeForce RTX 4070" as a render-only
  device with driver `vrd.sys`, and an app loads the vendor's Direct3D DLL
  (`nvwgf2umx.dll`) where it loaded `d3d10warp.dll` before. The picture still leaves
  through "Microsoft Hyper-V Video", so screenshots and film work as before.
- **Display fault in some builds.** Windows 11 builds 26100 and 26200 with a revision
  from 4484 to 7170 lose the desktop's screen once the card is attached: the session's
  display device is "WinDisc", the host's screenshots stay on the Hyper-V boot logo, and
  nothing is drawn. Microsoft fixed it in KB5068861 (revision 7171). **An idle-load
  measurement looks perfect in that state, because nothing is drawn.** `Test-GuestDisplay`
  catches it; `provision-gpu.ps1` updates Windows first when the build is in that range.
- The registry value `GpuVirtualizationFlags` set to 0 in the guest (Microsoft: bit 0x8
  pairs the card with the display adapter) brings the screen back on a faulty build, but
  apps then draw on the processor unless they pick the card themselves. Not a fix.
- `Update-GuestWindows` installs the monthly update through the Windows Update Agent. It
  runs as a SYSTEM task, because the agent refuses to download or install from a remote
  session. The update's title changed over time ("... Cumulative Update for Windows 11
  ...", later "2026-11 Security Update (KB...)"); the default filter takes both. One
  update took 11 minutes to download and 11 to install, and the checkpoint that holds it
  and the driver is 20 GB. Give the shutdown after it plenty of time; pulling the plug undoes it.

## Naming trap

PowerShell ignores case in command names. A helper called `Start-Vm` or `Stop-Vm`
replaces the cmdlet `Start-VM` or `Stop-VM` and then calls itself. The helpers are named
`Start-Guest`, `Stop-Guest`, `Restore-Guest`. Do not add a function whose name differs
from a Hyper-V cmdlet only in case.

## When Hyper-V is not available

On a host where Hyper-V is on (Windows 11 turns it on for Memory Integrity, WSL 2 and
Docker Desktop), VirtualBox runs on the Windows Hypervisor Platform. One test series
there had the guest hang on its own restarts until it was started cold, needed several
attempts to install Windows, and VBoxManage has no mouse input. Prefer Hyper-V on such a
host. On Windows Home, which has no Hyper-V, say so and ask the user how to proceed.
