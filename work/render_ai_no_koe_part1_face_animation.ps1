$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$ass = (Join-Path $root 'work\ai_no_koe_part1_v4.ass').Replace('\', '/').Replace(':', '\:')
$background = Join-Path $root 'work\gothic_moon_city_background.png'
$normal = Join-Path $root 'work\part1_girl_bright_normal.png'
$mouthHalf = Join-Path $root 'work\part1_patch_mouth_half.png'
$mouthOpen = Join-Path $root 'work\part1_patch_mouth_open.png'
$eyesHalf = Join-Path $root 'work\part1_patch_eyes_half.png'
$eyesClosed = Join-Path $root 'work\part1_patch_eyes_closed.png'
$petals = Join-Path $root 'work\petal_wind_50s.mp4'
$audio = Join-Path $root 'filmora_editable\06_藍のこえ_原曲.mp3'
$output = Join-Path $root 'outputs\藍の声_第1部_表情アニメ・明るい肌版_50秒.mp4'

function To-EnableExpression($intervals) {
    return (($intervals | ForEach-Object {
        $parts = $_ -split ','
        "between(t,$($parts[0]),$($parts[1]))"
    }) -join '+')
}

# Short, irregular syllable-sized openings. The half-mouth patch surrounds each
# opening by two frames to soften the transition.
$mouthIntervals = @(
    '10.98,11.24', '11.43,11.66', '12.01,12.21', '12.55,12.74',
    '13.30,13.52', '13.78,13.98', '14.24,14.50',
    '15.20,15.46', '15.73,15.94', '16.25,16.46',
    '17.10,17.36', '17.72,17.98', '18.22,18.44',
    '19.35,19.56', '19.88,20.14',
    '21.10,21.36', '21.70,21.95', '22.45,22.67',
    '23.30,23.58', '24.05,24.32',
    '25.15,25.42', '25.86,26.08', '26.65,26.90',
    '28.00,28.30', '28.66,28.94', '29.40,29.66',
    '30.55,30.78', '31.10,31.38', '31.78,32.02',
    '33.15,33.42', '33.75,33.98', '34.42,34.68',
    '35.55,35.82', '36.20,36.45', '36.80,37.02',
    '38.30,38.58', '39.00,39.25', '39.70,39.95',
    '41.00,41.28', '41.72,41.98', '42.40,42.62',
    '43.50,43.76', '44.15,44.42', '44.85,45.10',
    '46.05,46.32', '46.72,46.95', '47.40,47.68',
    '48.30,48.56', '48.90,49.16'
)
$mouthHalfIntervals = $mouthIntervals | ForEach-Object {
    $parts = $_ -split ','
    "$(($parts[0] -as [double]) - 0.07),$(($parts[1] -as [double]) + 0.07)"
}
$mouthOpenEnable = To-EnableExpression $mouthIntervals
$mouthHalfEnable = To-EnableExpression $mouthHalfIntervals

# Natural irregular blinks plus one longer melancholy eye-close near 32 seconds.
$closedIntervals = @(
    '12.94,13.05', '17.72,17.84', '22.86,22.98',
    '28.90,29.00', '29.16,29.25', '31.62,32.12',
    '35.10,35.22', '40.66,40.78', '46.80,46.92'
)
$halfIntervals = @(
    '12.88,12.94', '13.05,13.11', '17.66,17.72', '17.84,17.90',
    '22.80,22.86', '22.98,23.04', '28.84,28.90', '29.00,29.06',
    '29.10,29.16', '29.25,29.31', '31.54,31.62', '32.12,32.20',
    '35.04,35.10', '35.22,35.28', '40.60,40.66', '40.78,40.84',
    '46.74,46.80', '46.92,46.98'
)
$eyesClosedEnable = To-EnableExpression $closedIntervals
$eyesHalfEnable = To-EnableExpression $halfIntervals

$filter = @"
[0:v]scale=1920:1080,format=gbrp,
eq=contrast=1.04:brightness=-0.025:saturation=0.82,
colorbalance=rs=-0.02:gm=0.015:bm=0.025:bs=0.02,
drawbox=x=0:y=0:w=iw:h=ih:color=0x030510@0.46:t=fill:enable='between(t,8.65,10.35)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x14263c@0.10:t=fill:enable='between(t,31.4,43.3)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x3b3025@0.08:t=fill:enable='between(t,43.3,49.9)'[bg];
[6:v]scale=1920:1080,format=gbrp,eq=contrast=1.08:brightness=-0.055:saturation=0[petalfx];
[bg][petalfx]blend=all_mode=screen:all_opacity=0.90,format=yuv420p,
hue=h=-58:s=0.46,eq=contrast=1.04:brightness=0.012[gradedbg];

[1:v]scale=-1:1030,format=gbrap,eq=brightness=0.010:saturation=0.98,
colorchannelmixer=aa=0.97,fade=t=in:st=9.55:d=0.60:alpha=1[basegirl];
[2:v]scale=-1:1030,format=gbrap[mouthhalf];
[3:v]scale=-1:1030,format=gbrap[mouthopen];
[4:v]scale=-1:1030,format=gbrap[eyeshalf];
[5:v]scale=-1:1030,format=gbrap[eyesclosed];

[gradedbg][basegirl]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':eof_action=repeat:shortest=1[s0];
[s0][mouthhalf]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':enable='$mouthHalfEnable':eof_action=repeat[s1];
[s1][mouthopen]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':enable='$mouthOpenEnable':eof_action=repeat[s2];
[s2][eyeshalf]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':enable='$eyesHalfEnable':eof_action=repeat[s3];
[s3][eyesclosed]overlay=x='700-26*max(0,min((t-35)/8,1))+7*sin(t*0.43)':y='50+5*sin(t*0.30)':enable='$eyesClosedEnable':eof_action=repeat,format=yuv420p[precam];

[precam]zoompan=z='if(lt(on,285),1.0,if(lt(on,900),1+0.00011*(on-285),if(lt(on,1299),1.06765+0.00010*(on-900),1.10755+0.00016*(on-1299))))':x='iw/2-(iw/zoom/2)+28*sin(on/65)':y='ih/2-(ih/zoom/2)+14*sin(on/83)':d=1:s=1920x1080:fps=30[camera];
[camera]subtitles='$ass'[v]
"@

ffmpeg -y `
  -loop 1 -framerate 30 -i $background `
  -loop 1 -framerate 30 -i $normal `
  -loop 1 -framerate 30 -i $mouthHalf `
  -loop 1 -framerate 30 -i $mouthOpen `
  -loop 1 -framerate 30 -i $eyesHalf `
  -loop 1 -framerate 30 -i $eyesClosed `
  -i $petals -i $audio `
  -filter_complex $filter -map '[v]' -map 7:a:0 `
  -af "atrim=0:49.90,asetpts=PTS-STARTPTS,afade=t=out:st=49.65:d=0.25" `
  -c:v libx264 -preset veryfast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 49.90 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 1 facial animation render failed' }
Write-Output $output
