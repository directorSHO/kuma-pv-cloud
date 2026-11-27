$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$output = Join-Path $root 'filmora_editable\01_背景_30秒.mp4'

$filter = @"
[0:v]format=gbrp,eq=contrast=1.10:brightness=-0.105:saturation=0.62[base];
[1:v]format=gbrp,boxblur=110:3,eq=brightness=-0.25:saturation=0.58[light];
[base][light]blend=all_mode=screen:all_opacity=0.15,
drawbox=x='-560+t*82':y=-100:w=500:h=1280:color=0x5f99a0@0.020:t=fill,
gblur=sigma=1.2,noise=alls=1.15:allf=t+u,vignette=PI/5,
drawbox=x=0:y=0:w=iw:h=96:color=0x02040d@0.24:t=fill,
drawbox=x=0:y=ih-96:w=iw:h=96:color=0x02040d@0.24:t=fill,
drawbox=x=0:y=0:w=iw:h=ih:color=0x01030a@0.68:t=fill:enable='between(t,8.86,10.72)',
drawbox=x=0:y=110:w=1210:h=860:color=0x050713@0.13:t=fill:enable='gte(t,10.65)'[v]
"@

ffmpeg -y `
  -f lavfi -i "gradients=s=1920x1080:r=30:d=30:c0=0x02050e:c1=0x09262d:c2=0x211529:c3=0x0d1836:n=4:type=radial:speed=0.005" `
  -f lavfi -i "gradients=s=1920x1080:r=30:d=30:c0=0x08262e:c1=0x3b321f:c2=0x281a36:n=3:type=linear:x0=0:y0=1080:x1=1920:y1=0:speed=0.009" `
  -filter_complex $filter -map '[v]' -an `
  -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p -r 30 -movflags +faststart -t 30 $output

if ($LASTEXITCODE -ne 0) { throw 'Background render failed' }
Write-Output $output
