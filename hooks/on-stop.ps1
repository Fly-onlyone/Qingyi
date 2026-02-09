# Force UTF-8 encoding for stdin (Claude Code sends UTF-8 JSON)
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Read stdin JSON for the Stop event
$input = [Console]::In.ReadToEnd()

try {
    $data   = $input | ConvertFrom-Json
    $reason = $data.reason
}
catch {
    $reason = $null
}

# Map reason to friendly message
switch ($reason) {
    'end_turn'       { $message = 'Work completed -- check Claude Code' }
    'max_tokens'     { $message = 'Stopped -- max tokens reached' }
    'stop_sequence'  { $message = 'Stopped -- stop sequence hit' }
    default          { $message = 'Work completed -- check Claude Code' }
}

# Call notify.ps1 from the same directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& powershell -NoProfile -ExecutionPolicy Bypass -File "$scriptDir\notify.ps1" -Title 'Claude Code' -Message $message

# Output valid JSON and exit cleanly
Write-Output '{}'
exit 0
