# Force UTF-8 encoding for stdin (Claude Code sends UTF-8 JSON)
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Read stdin JSON for the Notification event
$input = [Console]::In.ReadToEnd()

try {
    $data    = $input | ConvertFrom-Json
    $message = $data.message
}
catch {
    $message = $null
}

if (-not $message) {
    $message = 'Action required -- check Claude Code'
}

# Sanitize common Unicode characters that garble on Windows
$message = $message -replace [char]0x2014, '--' -replace [char]0x2013, '-' -replace [char]0x2018, "'" -replace [char]0x2019, "'" -replace [char]0x201C, '"' -replace [char]0x201D, '"'

# Call notify.ps1 from the same directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& powershell -NoProfile -ExecutionPolicy Bypass -File "$scriptDir\notify.ps1" -Title 'Claude Code' -Message $message

# Output valid JSON and exit cleanly
Write-Output '{}'
exit 0
