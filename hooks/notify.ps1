param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$Message
)

try {
    # --- Custom AUMID registration ---
    $AppId   = 'Qingyi.ClaudeCode'
    $AppName = 'Qingyi'

    # Resolve icon path relative to this script (plugins/qingyi/hooks/icon.png)
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $IconPath  = Join-Path $scriptDir 'Qingyi02.png'

    $RegPath = "HKCU:\SOFTWARE\Classes\AppUserModelId\$AppId"

    # Register AUMID if not already present or if icon path changed
    $needsUpdate = -not (Test-Path $RegPath)
    if (-not $needsUpdate) {
        $current = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
        if ($current.DisplayName -ne $AppName -or $current.IconUri -ne $IconPath) {
            $needsUpdate = $true
        }
    }

    if ($needsUpdate) {
        if (-not (Test-Path $RegPath)) {
            New-Item -Path "HKCU:\SOFTWARE\Classes\AppUserModelId" -Name $AppId -Force | Out-Null
        }
        New-ItemProperty -Path $RegPath -Name 'DisplayName'       -Value $AppName  -PropertyType String       -Force | Out-Null
        New-ItemProperty -Path $RegPath -Name 'ShowInSettings'     -Value 0         -PropertyType DWord        -Force | Out-Null

        # Only set IconUri if the icon file exists
        if (Test-Path $IconPath) {
            New-ItemProperty -Path $RegPath -Name 'IconUri' -Value $IconPath -PropertyType ExpandString -Force | Out-Null
        }
    }

    # --- Build and show toast ---
    # Sanitize common Unicode characters that garble on Windows
    $Title   = $Title   -replace [char]0x2014, '--' -replace [char]0x2013, '-' -replace [char]0x2018, "'" -replace [char]0x2019, "'" -replace [char]0x201C, '"' -replace [char]0x201D, '"'
    $Message = $Message -replace [char]0x2014, '--' -replace [char]0x2013, '-' -replace [char]0x2018, "'" -replace [char]0x2019, "'" -replace [char]0x201C, '"' -replace [char]0x201D, '"'

    # Escape XML special characters
    $Title   = $Title   -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
    $Message = $Message -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'

    # Load WinRT toast notification API
    [void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime]

    # Build toast XML with sound and inline icon
    $toastXml = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <image placement="appLogoOverride" src="$IconPath" hint-crop="circle" />
      <text>$Title</text>
      <text>$Message</text>
    </binding>
  </visual>
  <audio src="ms-winsoundevent:Notification.Default" />
</toast>
"@

    $xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
    $xml.LoadXml($toastXml)

    # Show notification using custom AUMID
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($toast)
}
catch {
    # Non-blocking -- silently exit on error
    exit 0
}
