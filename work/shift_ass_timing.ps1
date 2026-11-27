param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$OutputPath,
    [double]$ShiftSeconds = -0.18,
    [double]$ApplyFromSeconds = 0.0
)

$ErrorActionPreference = 'Stop'

function Convert-AssTimeToSeconds([string]$value) {
    if ($value -notmatch '^(\d+):(\d{2}):(\d{2})\.(\d{2})$') {
        throw "Unsupported ASS time: $value"
    }
    return ([double]$Matches[1] * 3600) + ([double]$Matches[2] * 60) + [double]$Matches[3] + ([double]$Matches[4] / 100)
}

function Convert-SecondsToAssTime([double]$value) {
    $value = [Math]::Max(0, $value)
    $centiseconds = [int][Math]::Round($value * 100)
    $hours = [Math]::Floor($centiseconds / 360000)
    $centiseconds %= 360000
    $minutes = [Math]::Floor($centiseconds / 6000)
    $centiseconds %= 6000
    $seconds = [Math]::Floor($centiseconds / 100)
    $centiseconds %= 100
    return '{0}:{1:00}:{2:00}.{3:00}' -f $hours, $minutes, $seconds, $centiseconds
}

$lines = Get-Content -LiteralPath $InputPath
$adjusted = foreach ($line in $lines) {
    if ($line -match '^Dialogue: ([^,]+),([^,]+),([^,]+),(.*)$') {
        $start = Convert-AssTimeToSeconds $Matches[2]
        $end = Convert-AssTimeToSeconds $Matches[3]
        if ($start -ge $ApplyFromSeconds) {
            $start = [Math]::Max(0, $start + $ShiftSeconds)
            $end = [Math]::Max($start + 0.01, $end + $ShiftSeconds)
        }
        'Dialogue: {0},{1},{2},{3}' -f $Matches[1], (Convert-SecondsToAssTime $start), (Convert-SecondsToAssTime $end), $Matches[4]
    } else {
        $line
    }
}

Set-Content -LiteralPath $OutputPath -Value $adjusted -Encoding utf8

