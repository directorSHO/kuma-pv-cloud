$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$ass = (Join-Path $root 'work\ai_no_koe_15s.ass').Replace('\', '/').Replace(':', '\:')
$audio = 'C:\Users\自分\Desktop\藍のこえ (Remastered).mp3'
$character = Join-Path $root 'work\gothic_girl_indigo.png'
$output = Join-Path $root 'outputs\藍の声_文字PV_15秒_女の子版.mp4'

$filter = @"
[0:v]format=gbrp,eq=contrast=1.06:brightness=-0.035:saturation=0.82[base];
[1:v]format=gbrp,boxblur=80:3,eq=brightness=-0.20:saturation=0.75[light];
[base][light]blend=all_mode=screen:all_opacity=0.22,
drawbox=x='-500+t*105':y=-100:w=460:h=1280:color=0x8aa0df@0.035:t=fill,
gblur=sigma=1.4,noise=alls=1.25:allf=t+u,vignette=PI/5,
drawbox=x=0:y=0:w=iw:h=96:color=0x02040d@0.22:t=fill,
drawbox=x=0:y=ih-96:w=iw:h=96:color=0x02040d@0.22:t=fill,
drawbox=x=0:y=0:w=iw:h=ih:color=0x01030a@0.68:t=fill:enable='between(t,8.86,10.72)'[bg];
[2:v]scale=-1:1030,format=rgba,colorchannelmixer=aa=0.82,fade=t=in:st=10.65:d=0.55:alpha=1[girl];
[bg][girl]overlay=x=680:y=50:eof_action=repeat:shortest=1,
drawbox=x=0:y=0:w=1220:h=ih:color=0x070817@0.12:t=fill:enable='gte(t,10.65)',
subtitles='$ass'[v]
"@

ffmpeg -y `
  -f lavfi -i "gradients=s=1920x1080:r=30:d=15:c0=0x02040d:c1=0x11162f:c2=0x182448:c3=0x251936:n=4:type=radial:speed=0.006" `
  -f lavfi -i "gradients=s=1920x1080:r=30:d=15:c0=0x050712:c1=0x223d66:n=2:type=linear:x0=0:y0=1080:x1=1920:y1=0:speed=0.012" `
  -loop 1 -i $character -i $audio -filter_complex $filter -map '[v]' -map 3:a:0 `
  -af "atrim=0:15,asetpts=PTS-STARTPTS,afade=t=out:st=14.82:d=0.18" `
  -c:v libx264 -preset medium -crf 19 -maxrate 6500k -bufsize 13000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 15 $output

if ($LASTEXITCODE -ne 0) { throw '15-second revised render failed' }
Write-Output $output
