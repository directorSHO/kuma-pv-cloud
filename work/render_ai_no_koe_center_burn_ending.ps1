$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$input = Join-Path $root 'outputs\藍の声_全編_フルスクリーン版_3分20秒.mp4'
$ass = (Join-Path $root 'work\ai_no_koe_ending_cracks.ass').Replace('\', '/').Replace(':', '\:')
$output = Join-Path $root 'outputs\藍の声_全編_フルスクリーン・中央燃焼エンド版_3分20秒.mp4'
$filmoraCopy = Join-Path $root 'filmora_editable\62_藍の声_全編_中央燃焼エンド版_3分20秒.mp4'

# Effect begins exactly five seconds before the 199.566667-second ending.
$tailStart = 194.566667
$distance = "sqrt(pow(X-W/2,2)+pow(Y-H/2,2))+18*sin(X*0.031+Y*0.017)+11*sin(X*0.071-Y*0.029)+7*sin(X*0.013+Y*0.089+N*0.23)"
$radius = "max(0,(N/30-0.86))*178"
$burnMask = "255*if(lt($distance,$radius),1,0)"
$glowMask = "255*if(between(abs(($distance)-($radius)),0,19),0.48+0.30*sin(N*0.72+X*0.09+Y*0.04),0)"
$edgeMask = "255*if(between(abs(($distance)-($radius)),0,7),0.70+0.25*sin(N*0.93+X*0.13-Y*0.05),0)"

$filter = @"
[0:v]split=2[headsrc][tailsrc];
[headsrc]trim=start=0:end=${tailStart},setpts=PTS-STARTPTS[head];
[tailsrc]trim=start=${tailStart}:end=199.566667,setpts=PTS-STARTPTS,
subtitles='$ass'[cracked];

nullsrc=s=960x540:r=30:d=5,format=gray,
geq=lum='$burnMask',scale=1920:1080:flags=bilinear[burnmask];
color=c=black:s=1920x1080:r=30:d=5[black];
[cracked][black][burnmask]maskedmerge[burned];

nullsrc=s=960x540:r=30:d=5,format=gray,
geq=lum='$glowMask',gblur=sigma=8:steps=2,scale=1920:1080:flags=bilinear[glowmask];
color=c=0xff3d08:s=1920x1080:r=30:d=5,format=rgba[orange];
[orange][glowmask]alphamerge[fireglow];
[burned][fireglow]overlay=eof_action=pass[withglow];

nullsrc=s=960x540:r=30:d=5,format=gray,
geq=lum='$edgeMask',gblur=sigma=2:steps=1,scale=1920:1080:flags=bilinear[edgemask];
color=c=0xffc45b:s=1920x1080:r=30:d=5,format=rgba[yellow];
[yellow][edgemask]alphamerge[hotedge];
[withglow][hotedge]overlay=eof_action=pass,
drawbox=x=0:y=0:w=iw:h=ih:color=0x120500@0.16:t=fill:enable='gte(t,1.0)',
fade=t=out:st=4.45:d=0.55,setsar=1,setdar=16/9[tail];

[head][tail]concat=n=2:v=1:a=0,format=yuv420p,setsar=1,setdar=16/9[v]
"@

ffmpeg -y -hide_banner -i $input -filter_complex $filter `
  -map '[v]' -map 0:a:0 -c:v libx264 -preset veryfast -crf 18 `
  -maxrate 10000k -bufsize 20000k -r 30 -c:a copy -movflags +faststart -t 199.566667 $output

if ($LASTEXITCODE -ne 0) { throw 'Center burn ending render failed' }
Copy-Item -LiteralPath $output -Destination $filmoraCopy -Force
Write-Output $output
