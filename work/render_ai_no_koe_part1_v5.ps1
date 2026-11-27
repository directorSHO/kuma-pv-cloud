$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$ass = (Join-Path $root 'work\ai_no_koe_part1_v4.ass').Replace('\', '/').Replace(':', '\:')
$background = Join-Path $root 'work\gothic_moon_city_background.png'
$closed = Join-Path $root 'work\gothic_girl_eyes_closed.png'
$normal = Join-Path $root 'work\gothic_girl_indigo.png'
$wet = Join-Path $root 'work\gothic_girl_indigo_wet.png'
$smile = Join-Path $root 'work\gothic_girl_wet_smile.png'
$rain = Join-Path $root 'work\gothic_rain_30s.mp4'
$audio = 'C:\Users\自分\Desktop\藍のこえ (Remastered).mp3'
$output = Join-Path $root 'outputs\藍の声_第1部_満月背景調和版_50秒.mp4'

$charGrade = "null"

$filter = @"
[0:v]scale=1920:1080,format=gbrp,
eq=contrast=1.04:brightness=-0.025:saturation=0.82,
colorbalance=rs=-0.02:gm=0.015:bm=0.025:bs=0.02,
drawbox=x=0:y=0:w=iw:h=ih:color=0x030510@0.46:t=fill:enable='between(t,8.65,10.35)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x14263c@0.10:t=fill:enable='between(t,31.4,43.3)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x3b3025@0.08:t=fill:enable='between(t,43.3,49.9)'[bg];
[1:v]scale=-1:1030,format=gbrap,$charGrade,colorchannelmixer=aa=0.96,fade=t=in:st=9.55:d=0.55:alpha=1,fade=t=out:st=11.05:d=0.55:alpha=1[closed];
[2:v]scale=-1:1030,format=gbrap,$charGrade,colorchannelmixer=aa=0.96,fade=t=in:st=10.90:d=0.50:alpha=1,fade=t=out:st=20.20:d=5.0:alpha=1[normal];
[3:v]scale=-1:1030,format=gbrap,$charGrade,colorchannelmixer=aa=0.96,fade=t=in:st=19.20:d=5.0:alpha=1,fade=t=out:st=42.00:d=3.5:alpha=1[wet];
[4:v]scale=-1:1030,format=gbrap,$charGrade,colorchannelmixer=aa=0.96,fade=t=in:st=41.60:d=3.5:alpha=1[smile];
[bg][closed]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s1];
[s1][normal]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s2];
[s2][wet]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s3];
[s3][smile]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[scene];
[5:v]scale=1920:1080,format=gbrp,eq=contrast=1.10:brightness=-0.055:saturation=0[rainfx];
[scene][rainfx]blend=all_mode=screen:all_opacity=0.24,format=yuv420p,
hue=h=-34:s=0.58,eq=contrast=1.04:brightness=0.012[precam];
[precam]zoompan=z='if(lt(on,285),1.0,if(lt(on,900),1+0.00011*(on-285),if(lt(on,1299),1.06765+0.00010*(on-900),1.10755+0.00016*(on-1299))))':x='iw/2-(iw/zoom/2)+28*sin(on/65)':y='ih/2-(ih/zoom/2)+14*sin(on/83)':d=1:s=1920x1080:fps=30[camera];
[camera]subtitles='$ass'[v]
"@

ffmpeg -y `
  -loop 1 -framerate 30 -i $background `
  -loop 1 -i $closed -loop 1 -i $normal -loop 1 -i $wet -loop 1 -i $smile `
  -stream_loop -1 -i $rain -i $audio `
  -filter_complex $filter -map '[v]' -map 6:a:0 `
  -af "atrim=0:49.90,asetpts=PTS-STARTPTS,afade=t=out:st=49.65:d=0.25" `
  -c:v libx264 -preset veryfast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 49.90 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 1 v5 render failed' }
Write-Output $output
