$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$base = Join-Path $root 'outputs\藍の声_全編_フルスクリーン版_3分20秒.mp4'
$ending = Join-Path $root 'outputs\藍の声_終幕5秒_古写真リアル燃焼・細縁版.mp4'
$output = Join-Path $root 'outputs\藍の声_最終完成版_それはきっと追加_3分20秒.mp4'
$filmoraCopy = Join-Path $root 'filmora_editable\64_藍の声_最終完成版_それはきっと追加_3分20秒.mp4'
$joinAt = 194.566667

$filter = @"
[0:v]trim=start=0:end=${joinAt},setpts=PTS-STARTPTS,
scale=1920:1080:flags=lanczos,setsar=1,setdar=16/9[head];
[1:v]trim=start=0:end=5,setpts=PTS-STARTPTS,
scale=1920:1080:flags=lanczos,setsar=1,setdar=16/9[tail];
[head][tail]concat=n=2:v=1:a=0,format=yuv420p,setsar=1,setdar=16/9[v]
"@

# The full-length audio from the base is kept intact. Only the final five
# seconds of video are replaced, avoiding an AAC splice at the join point.
ffmpeg -y -hide_banner -i $base -i $ending -filter_complex $filter `
  -map '[v]' -map 0:a:0 -c:v libx264 -preset veryfast -crf 18 `
  -maxrate 10000k -bufsize 20000k -r 30 -c:a copy `
  -movflags +faststart -t 199.566667 $output

if ($LASTEXITCODE -ne 0) { throw 'Final master render failed' }
Copy-Item -LiteralPath $output -Destination $filmoraCopy -Force
Write-Output $output
