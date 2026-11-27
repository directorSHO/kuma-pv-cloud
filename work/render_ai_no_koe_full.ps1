$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$ass = (Join-Path $root 'work\ai_no_koe_15s.ass').Replace('\', '/').Replace(':', '\:')
$audio = 'C:\Users\自分\Desktop\藍のこえ (Remastered).mp3'
$dry = Join-Path $root 'work\gothic_girl_indigo.png'
$wet = Join-Path $root 'work\gothic_girl_indigo_wet.png'
$rain = Join-Path $root 'work\gothic_rain_30s.mp4'
$output = Join-Path $root 'outputs\藍の声_文字PV_全編_完成版.mp4'

$filter = @"
[0:v]format=gbrp,eq=contrast=1.10:brightness=-0.105:saturation=0.62[base];
[1:v]format=gbrp,boxblur=110:3,eq=brightness=-0.25:saturation=0.58[light];
[base][light]blend=all_mode=screen:all_opacity=0.15,
drawbox=x='-560+mod(t*82\,2480)':y=-100:w=500:h=1280:color=0x5f99a0@0.020:t=fill,
gblur=sigma=1.2,noise=alls=1.05:allf=t+u,vignette=PI/5,
drawbox=x=0:y=0:w=iw:h=96:color=0x02040d@0.24:t=fill,
drawbox=x=0:y=ih-96:w=iw:h=96:color=0x02040d@0.24:t=fill,
drawbox=x=0:y=0:w=iw:h=ih:color=0x01030a@0.66:t=fill:enable='between(t,8.86,10.72)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x291a38@0.12:t=fill:enable='between(t,43.6,63.8)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x102d31@0.12:t=fill:enable='between(t,95.5,117.5)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x3a2841@0.16:t=fill:enable='between(t,148.6,180.2)'[bg];
[2:v]scale=-1:1030,format=rgba,colorchannelmixer=aa=0.94,fade=t=in:st=10.65:d=0.55:alpha=1[drychar];
[3:v]scale=-1:1030,format=rgba,colorchannelmixer=aa=0.94,fade=t=in:st=10.65:d=0.55:alpha=1[wetchar];
[bg]split=2[bgdry][bgwet];
[bgdry][drychar]overlay=x='680+8*sin(t*0.38)':y='50+5*sin(t*0.29)':eof_action=repeat:shortest=1[scenedry];
[bgwet][wetchar]overlay=x='680+8*sin(t*0.38)':y='50+5*sin(t*0.29)':eof_action=repeat:shortest=1[scenewet];
[scenedry][scenewet]xfade=transition=fade:duration=11:offset=14[scene];
[4:v]scale=1920:1080,format=gbrp,eq=contrast=1.08:brightness=-0.025:saturation=0.72[rainfx];
[scene][rainfx]blend=all_mode=screen:all_opacity=0.48,
colorbalance=rs=-0.10:rm=-0.18:gm=0.07:bm=0.06:bs=0.05,
drawbox=x=0:y=110:w=1210:h=860:color=0x050713@0.13:t=fill:enable='gte(t,10.65)',
subtitles='$ass'[v]
"@

ffmpeg -y `
  -f lavfi -i "gradients=s=1920x1080:r=30:d=199.56:c0=0x02050e:c1=0x09262d:c2=0x211529:c3=0x0d1836:n=4:type=radial:speed=0.005" `
  -f lavfi -i "gradients=s=1920x1080:r=30:d=199.56:c0=0x08262e:c1=0x3b321f:c2=0x281a36:n=3:type=linear:x0=0:y0=1080:x1=1920:y1=0:speed=0.009" `
  -loop 1 -i $dry -loop 1 -i $wet -stream_loop -1 -i $rain -i $audio `
  -filter_complex $filter -map '[v]' -map 5:a:0 `
  -af "atrim=0:199.56,asetpts=PTS-STARTPTS,afade=t=out:st=198.30:d=1.20" `
  -c:v libx264 -preset fast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 199.56 $output

if ($LASTEXITCODE -ne 0) { throw 'Full render failed' }
Write-Output $output
