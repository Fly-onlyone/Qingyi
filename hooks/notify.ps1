param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$Message
)

# Escape special XML characters to prevent parse failures
function Escape-Xml([string]$text)
{
    return $text `
             -replace '&', '&amp;' `
             -replace '<', '&lt;' `
             -replace '>', '&gt;' `
             -replace '"', '&quot;' `
             -replace "'", '&apos;'
}

try
{
    # --- Custom AUMID registration ---
    $AppId = 'Qingyi.ClaudeCode'
    $AppName = 'Claude Code'

    # Resolve icon path relative to this script
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $IconPath = Join-Path $scriptDir 'Qingyi02.png'
    $iconExists = Test-Path $IconPath

    $RegPath = "HKCU:\SOFTWARE\Classes\AppUserModelId\$AppId"

    # Always update AUMID registration to ensure DisplayName and IconUri are current
    if (-not (Test-Path $RegPath))
    {
        New-Item -Path "HKCU:\SOFTWARE\Classes\AppUserModelId" -Name $AppId -Force | Out-Null
    }
    New-ItemProperty -Path $RegPath -Name 'DisplayName'       -Value $AppName  -PropertyType String       -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name 'ShowInSettings'     -Value 0         -PropertyType DWord        -Force | Out-Null

    # Set or clear IconUri based on icon file existence
    if ($iconExists)
    {
        New-ItemProperty -Path $RegPath -Name 'IconUri' -Value $IconPath -PropertyType ExpandString -Force | Out-Null
    }
    else
    {
        Remove-ItemProperty -Path $RegPath -Name 'IconUri' -ErrorAction SilentlyContinue
    }

    # Load WinRT toast notification API
    [void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime]

    # Escape values for safe XML embedding
    $safeTitle = Escape-Xml $Title
    $safeMessage = Escape-Xml $Message

    # Build toast XML with optional inline app icon
    if ($iconExists)
    {
    $safeIconPath = Escape-Xml $IconPath
    $toastXml = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <image placement="appLogoOverride" src="$safeIconPath" hint-crop="circle" />
      <text>$safeTitle</text>
      <text>$safeMessage</text>
    </binding>
  </visual>
  <audio src="ms-winsoundevent:Notification.Default" />
</toast>
"@
    }
    else
    {
    $toastXml = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>$safeTitle</text>
      <text>$safeMessage</text>
    </binding>
  </visual>
  <audio src="ms-winsoundevent:Notification.Default" />
</toast>
"@
    }

    $xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
    $xml.LoadXml($toastXml)

    # Show notification using custom AUMID
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($toast)
}
catch
{
    # Non-blocking -- silently exit on error
    exit 0
}
