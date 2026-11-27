$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$ass = (Join-Path $root 'work\ai_no_koe_part1_v2.ass').Replace('\', '/').Replace(':', '\:')
$closed = Join-Path $root 'work\gothic_girl_eyes_closed.png'
$normal = Join-Path $root 'work\gothic_girl_indigo.png'
$wet = Join-Path $root 'work\gothic_girl_indigo_wet.png'
$smile = Join-Path $root 'work\gothic_girl_wet_smile.png'
$rain = Join-Path $root 'work\gothic_rain_30s.mp4'
$audio = 'C:\Users\自分\Desktop\藍のこえ (Remastered).mp3'
$output = Join-Path $root 'outputs\藍の声_第1部_作り込み版_50秒.mp4'

$filter = @"
[0:v]format=gbrp,eq=contrast=1.12:brightness=-0.115:saturation=0.58[base];
[1:v]format=gbrp,boxblur=120:3,eq=brightness=-0.24:saturation=0.62[light];
[base][light]blend=all_mode=screen:all_opacity=0.17,
drawbox=x='-620+t*88':y=-120:w=460:h=1320:color=0x5f99a0@0.025:t=fill,
drawbox=x='2100-t*68':y=-100:w=330:h=1280:color=0x7a527e@0.018:t=fill,
gblur=sigma=1.15,noise=alls=1.0:allf=t+u,vignette=PI/5,
drawbox=x=0:y=0:w=iw:h=96:color=0x02040d@0.28:t=fill,
drawbox=x=0:y=ih-96:w=iw:h=96:color=0x02040d@0.28:t=fill,
drawbox=x=0:y=0:w=iw:h=ih:color=0x050713@0.54:t=fill:enable='between(t,8.65,10.35)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x24142f@0.11:t=fill:enable='between(t,20.5,30.1)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x0b3034@0.12:t=fill:enable='between(t,31.4,43.3)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x493441@0.15:t=fill:enable='between(t,43.3,49.9)'[bg];
[2:v]scale=-1:1030,format=rgba,colorchannelmixer=aa=0.96,fade=t=in:st=9.55:d=0.55:alpha=1,fade=t=out:st=11.05:d=0.55:alpha=1[closed];
[3:v]scale=-1:1030,format=rgba,colorchannelmixer=aa=0.96,fade=t=in:st=10.90:d=0.50:alpha=1,fade=t=out:st=20.20:d=5.0:alpha=1[normal];
[4:v]scale=-1:1030,format=rgba,colorchannelmixer=aa=0.96,fade=t=in:st=19.20:d=5.0:alpha=1,fade=t=out:st=42.00:d=3.5:alpha=1[wet];
[5:v]scale=-1:1030,format=rgba,colorchannelmixer=aa=0.96,fade=t=in:st=41.60:d=3.5:alpha=1[smile];
[bg][closed]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s1];
[s1][normal]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s2];
[s2][wet]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s3];
[s3][smile]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[scene];
[6:v]scale=1920:1080,format=gbrp,eq=contrast=1.10:brightness=-0.02:saturation=0.72[rainfx];
[scene][rainfx]blend=all_mode=screen:all_opacity=0.50,
colorbalance=rs=-0.11:rm=-0.18:gm=0.075:bm=0.065:bs=0.05,
drawbox=x=0:y=105:w=1200:h=870:color=0x050713@0.14:t=fill:enable='gte(t,10.2)',
subtitles='$ass'[v]
"@

ffmpeg -y `
  -f lavfi -i "gradients=s=1920x1080:r=30:d=49.90:c0=0x02050e:c1=0x09262d:c2=0x211529:c3=0x0d1836:n=4:type=radial:speed=0.006" `
  -f lavfi -i "gradients=s=1920x1080:r=30:d=49.90:c0=0x08262e:c1=0x3b321f:c2=0x281a36:n=3:type=linear:x0=0:y0=1080:x1=1920:y1=0:speed=0.010" `
  -loop 1 -i $closed -loop 1 -i $normal -loop 1 -i $wet -loop 1 -i $smile `
  -stream_loop -1 -i $rain -i $audio `
  -filter_complex $filter -map '[v]' -map 7:a:0 `
  -af "atrim=0:49.90,asetpts=PTS-STARTPTS,afade=t=out:st=49.65:d=0.25" `
  -c:v libx264 -preset fast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 49.90 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 1 render failed' }
Write-Output $output
