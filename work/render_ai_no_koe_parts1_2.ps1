$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$part1 = Join-Path $root 'outputs\藍の声_第1部_花びら時差・肌色調整版_50秒.mp4'
$part2 = Join-Path $root 'outputs\藍の声_第2部_砕けた光を拾う_51秒.mp4'
$audio = 'C:\Users\自分\Desktop\藍のこえ (Remastered).mp3'
$output = Join-Path $root 'outputs\藍の声_第1-2部_連結版_1分41秒.mp4'

ffmpeg -y -i $part1 -i $part2 -i $audio `
  -filter_complex "[0:v]setpts=PTS-STARTPTS[v0];[1:v]setpts=PTS-STARTPTS[v1];[v0][v1]concat=n=2:v=1:a=0,format=yuv420p[v];[2:a]atrim=start=0:end=100.78,asetpts=PTS-STARTPTS[a]" `
  -map '[v]' -map '[a]' `
  -c:v libx264 -preset veryfast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 100.78 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 1-2 combined render failed' }
Write-Output $output
