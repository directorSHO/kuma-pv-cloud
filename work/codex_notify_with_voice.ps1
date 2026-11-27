param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Payload
)

$ErrorActionPreference = 'SilentlyContinue'

$runtimeRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\runtimes\cua_node'
$petNotifier = Get-ChildItem -LiteralPath $runtimeRoot -Filter 'codex-computer-use.exe' -File -Recurse -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($petNotifier) {
    & $petNotifier.FullName 'turn-ended' @Payload | Out-Null
}

$audioPath = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat\終わったよ.mp3'
$player = Get-Command 'ffplay.exe' -ErrorAction SilentlyContinue
if ($player -and (Test-Path -LiteralPath $audioPath)) {
    Start-Process -FilePath $player.Source -ArgumentList @('-nodisp', '-autoexit', '-loglevel', 'quiet', $audioPath) -WindowStyle Hidden
}
