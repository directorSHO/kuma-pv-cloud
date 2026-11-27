$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$ass = (Join-Path $root 'work\ai_no_koe_part1_sync.ass').Replace('\', '/').Replace(':', '\:')
$background = Join-Path $root 'work\gothic_moon_city_background.png'
$normal = Join-Path $root 'work\gothic_girl_indigo.png'
$eyesHalf = Join-Path $root 'work\part1_v5_patch_eyes_half.png'
$eyesClosed = Join-Path $root 'work\part1_v5_patch_eyes_closed.png'
$rain = Join-Path $root 'work\gothic_rain_30s.mp4'
$audio = Join-Path $root 'filmora_editable\06_藍のこえ_原曲.mp3'
$output = Join-Path $root 'outputs\藍の声_第1部_満月背景調和・瞬き・歌詞同期版_50秒.mp4'

$eyesClosedEnable = @(
    'between(t,9.55,10.45)',
    'between(t,17.12,17.24)',
    'between(t,25.06,25.18)',
    'between(t,33.18,33.30)',
    'between(t,41.04,41.16)',
    'between(t,47.62,47.74)'
) -join '+'
$eyesHalfEnable = @(
    'between(t,10.45,10.55)',
    'between(t,17.06,17.12)', 'between(t,17.24,17.30)',
    'between(t,25.00,25.06)', 'between(t,25.18,25.24)',
    'between(t,33.12,33.18)', 'between(t,33.30,33.36)',
    'between(t,40.98,41.04)', 'between(t,41.16,41.22)',
    'between(t,47.56,47.62)', 'between(t,47.74,47.80)'
) -join '+'

# Color and background grading are copied unchanged from the selected
# "満月背景調和版". Only character-state scheduling differs.
$filter = @"
[0:v]scale=1920:1080,format=gbrp,
eq=contrast=1.04:brightness=-0.025:saturation=0.82,
colorbalance=rs=-0.02:gm=0.015:bm=0.025:bs=0.02,
drawbox=x=0:y=0:w=iw:h=ih:color=0x030510@0.46:t=fill:enable='between(t,8.65,10.35)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x14263c@0.10:t=fill:enable='between(t,31.4,43.3)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x3b3025@0.08:t=fill:enable='between(t,43.3,49.9)'[bg];

[1:v]scale=-1:1030,format=gbrap,colorchannelmixer=aa=0.96,
fade=t=in:st=9.55:d=0.55:alpha=1[girl];
[2:v]scale=-1:1030,format=gbrap[eyeshalf];
[3:v]scale=-1:1030,format=gbrap[eyesclosed];

[bg][girl]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s0];
[s0][eyeshalf]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':enable='$eyesHalfEnable':eof_action=repeat[s1];
[s1][eyesclosed]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':enable='$eyesClosedEnable':eof_action=repeat[s2];

[4:v]scale=1920:1080,format=gbrp,eq=contrast=1.10:brightness=-0.055:saturation=0[rainfx];
[s2][rainfx]blend=all_mode=screen:all_opacity=0.24,format=yuv420p,
hue=h=-34:s=0.58,eq=contrast=1.04:brightness=0.012[precam];
[precam]zoompan=z='if(lt(on,285),1.0,if(lt(on,900),1+0.00011*(on-285),if(lt(on,1299),1.06765+0.00010*(on-900),1.10755+0.00016*(on-1299))))':x='iw/2-(iw/zoom/2)+28*sin(on/65)':y='ih/2-(ih/zoom/2)+14*sin(on/83)':d=1:s=1920x1080:fps=30[camera];
[camera]subtitles='$ass'[v]
"@

ffmpeg -y `
  -loop 1 -framerate 30 -i $background `
  -loop 1 -framerate 30 -i $normal `
  -loop 1 -framerate 30 -i $eyesHalf `
  -loop 1 -framerate 30 -i $eyesClosed `
  -stream_loop -1 -i $rain -i $audio `
  -filter_complex $filter -map '[v]' -map 5:a:0 `
  -af "atrim=0:49.90,asetpts=PTS-STARTPTS,afade=t=out:st=49.65:d=0.25" `
  -c:v libx264 -preset veryfast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 49.90 $output

if ($LASTEXITCODE -ne 0) { throw 'Moon harmony blink render failed' }
Write-Output $output

