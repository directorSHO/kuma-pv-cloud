$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$sourceScript = Join-Path $root 'work\render_ai_no_koe_part1_moon_harmony_blink.ps1'
$scriptText = Get-Content -LiteralPath $sourceScript -Raw
$scriptText = $scriptText.Replace('work\ai_no_koe_part1_v4.ass', 'work\ai_no_koe_part1_sync.ass')
$scriptText = $scriptText.Replace('outputs\藍の声_第1部_満月背景調和・瞬きのみ版_50秒.mp4', 'outputs\藍の声_第1部_満月背景調和・瞬き・歌詞同期版_50秒.mp4')
$temporaryScript = Join-Path $root 'work\_run_part1_sync.ps1'
Set-Content -LiteralPath $temporaryScript -Value $scriptText -Encoding utf8
& $temporaryScript
if ($LASTEXITCODE -ne 0) { throw 'Part 1 synchronized render failed' }

