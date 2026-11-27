$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$input = Join-Path $root 'outputs\藍の声_全編_瞬き・歌詞同期調整版_3分20秒.mp4'
$output = Join-Path $root 'outputs\藍の声_全編_フルスクリーン版_3分20秒.mp4'
$filmoraCopy = Join-Path $root 'filmora_editable\61_藍の声_全編_フルスクリーン版_3分20秒.mp4'

# Every frame is enlarged to cover 1920x1080, center-cropped, and tagged as
# square-pixel 16:9 so players cannot interpret it as an unspecified aspect ratio.
ffmpeg -y -hide_banner -i $input `
  -vf "scale=1920:1080:force_original_aspect_ratio=increase:flags=lanczos,crop=1920:1080,setsar=1,setdar=16/9,format=yuv420p" `
  -c:v libx264 -preset veryfast -crf 18 -maxrate 10000k -bufsize 20000k -r 30 `
  -c:a copy -movflags +faststart -metadata:s:v:0 rotate=0 $output

if ($LASTEXITCODE -ne 0) { throw 'Fullscreen render failed' }
Copy-Item -LiteralPath $output -Destination $filmoraCopy -Force
Write-Output $output

