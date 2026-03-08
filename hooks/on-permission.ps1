# Force UTF-8 encoding for stdin (Claude Code sends UTF-8 JSON)
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Read stdin JSON for the PermissionRequest event
$input = [Console]::In.ReadToEnd()

try
{
    $data = $input | ConvertFrom-Json
    $toolName = $data.tool_name
}
catch
{
    $toolName = $null
}

if ($toolName)
{
    $message = "Permission needed for $toolName -- check Claude Code"
}
else
{
    $message = 'Permission needed -- check Claude Code'
}

# Call notify.ps1 from the same directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$scriptDir\notify.ps1" -Title 'Claude Code' -Message $message

# Output empty decision — notify only, does not auto-allow or auto-deny
Write-Output '{}'
exit 0
