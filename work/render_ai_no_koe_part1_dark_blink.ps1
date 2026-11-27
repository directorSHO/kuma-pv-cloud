$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$ass = (Join-Path $root 'work\ai_no_koe_part1_v4.ass').Replace('\', '/').Replace(':', '\:')
$background = Join-Path $root 'work\gothic_moon_city_background.png'
$petals = Join-Path $root 'work\petal_wind_50s.mp4'
$normal = Join-Path $root 'work\gothic_girl_indigo_skin.png'
$eyesHalf = Join-Path $root 'work\part1_original_patch_eyes_half.png'
$eyesClosed = Join-Path $root 'work\part1_original_patch_eyes_closed.png'
$audio = Join-Path $root 'filmora_editable\06_藍のこえ_原曲.mp3'
$output = Join-Path $root 'outputs\藍の声_第1部_黒背景・自然な瞬き版_50秒.mp4'

# The character first appears with her eyes closed, then blinks only occasionally.
$eyesClosedEnable = @(
    'between(t,9.55,10.48)',
    'between(t,16.72,16.84)',
    'between(t,24.36,24.48)',
    'between(t,32.48,32.60)',
    'between(t,40.32,40.44)',
    'between(t,47.26,47.38)'
) -join '+'
$eyesHalfEnable = @(
    'between(t,10.48,10.58)',
    'between(t,16.66,16.72)', 'between(t,16.84,16.90)',
    'between(t,24.30,24.36)', 'between(t,24.48,24.54)',
    'between(t,32.42,32.48)', 'between(t,32.60,32.66)',
    'between(t,40.26,40.32)', 'between(t,40.44,40.50)',
    'between(t,47.20,47.26)', 'between(t,47.38,47.44)'
) -join '+'

$filter = @"
[0:v]scale=1920:1080,format=gbrp,
eq=contrast=1.05:brightness=-0.040:saturation=0.74,
colorbalance=rs=-0.025:gm=0.012:bm=0.032:bs=0.025,
drawbox=x=0:y=0:w=iw:h=ih:color=black@0.18:t=fill:enable='between(t,0,8.40)',
drawbox=x=0:y=0:w=iw:h=ih:color=black@0.72:t=fill:enable='between(t,8.40,10.80)',
drawbox=x=0:y=0:w=iw:h=ih:color=black@0.38:t=fill:enable='between(t,10.80,13.20)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x14263c@0.11:t=fill:enable='between(t,31.4,43.3)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x3b3025@0.08:t=fill:enable='between(t,43.3,49.9)'[bg];
[1:v]scale=1920:1080,format=gbrp,eq=contrast=1.08:brightness=-0.055:saturation=0[petalfx];
[bg][petalfx]blend=all_mode=screen:all_opacity=0.90,format=yuv420p,
hue=h=-58:s=0.46,eq=contrast=1.04:brightness=0.012[scene];

[2:v]scale=-1:1030,format=gbrap,colorchannelmixer=aa=0.96,
fade=t=in:st=9.55:d=0.60:alpha=1[girl];
[3:v]scale=-1:1030,format=gbrap[eyeshalf];
[4:v]scale=-1:1030,format=gbrap[eyesclosed];

[scene][girl]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s0];
[s0][eyeshalf]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':enable='$eyesHalfEnable':eof_action=repeat[s1];
[s1][eyesclosed]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':enable='$eyesClosedEnable':eof_action=repeat,format=yuv420p[precam];

[precam]zoompan=z='if(lt(on,285),1.0,if(lt(on,900),1+0.00011*(on-285),if(lt(on,1299),1.06765+0.00010*(on-900),1.10755+0.00016*(on-1299))))':x='iw/2-(iw/zoom/2)+28*sin(on/65)':y='ih/2-(ih/zoom/2)+14*sin(on/83)':d=1:s=1920x1080:fps=30[camera];
[camera]subtitles='$ass'[v]
"@

ffmpeg -y `
  -loop 1 -framerate 30 -i $background `
  -i $petals `
  -loop 1 -framerate 30 -i $normal `
  -loop 1 -framerate 30 -i $eyesHalf `
  -loop 1 -framerate 30 -i $eyesClosed `
  -i $audio `
  -filter_complex $filter -map '[v]' -map 5:a:0 `
  -af "atrim=0:49.90,asetpts=PTS-STARTPTS,afade=t=out:st=49.65:d=0.25" `
  -c:v libx264 -preset veryfast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 49.90 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 1 dark background blink render failed' }
Write-Output $output
