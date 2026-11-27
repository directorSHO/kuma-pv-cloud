$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$petal = Join-Path $root 'work\moonlit_petal.png'
$output = Join-Path $root 'work\petal_wind_50s.mp4'

$filter = @"
color=c=black:s=1920x1080:r=30:d=49.90[base];
[0:v]split=3[p1s][p2s][p3s];
[p1s]scale=78:-1,format=rgba,rotate='0.65*sin(t*1.45)':c=none:ow=rotw(iw):oh=roth(ih)[p1];
[p2s]scale=58:-1,format=rgba,rotate='-0.85*sin(t*1.15+1.2)':c=none:ow=rotw(iw):oh=roth(ih)[p2];
[p3s]scale=68:-1,format=rgba,rotate='1.05*sin(t*1.75+2.0)':c=none:ow=rotw(iw):oh=roth(ih)[p3];
[base][p1]overlay=x='mod(-220+t*128,2380)-220':y='190+92*sin(t*0.82)':shortest=1[o1];
[o1][p2]overlay=x='mod(-860+t*104,2520)-220':y='500+118*sin(t*0.66+1.4)':shortest=1[o2];
[o2][p3]overlay=x='mod(-1460+t*154,2760)-220':y='760+82*sin(t*0.92+2.3)':shortest=1,
fade=t=in:st=10.20:d=0.75,format=yuv420p[v]
"@

ffmpeg -y -loop 1 -framerate 30 -i $petal `
  -filter_complex $filter -map '[v]' -an -t 49.90 `
  -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p -r 30 -movflags +faststart $output

if ($LASTEXITCODE -ne 0) { throw 'Petal wind overlay render failed' }
Write-Output $output
