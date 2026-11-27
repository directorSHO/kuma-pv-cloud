$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$visualOpen = Join-Path $root 'work\part2_concept_shattered_light.png'
$eyesHalf = Join-Path $root 'work\part2_blink_half_patch.png'
$eyesClosed = Join-Path $root 'work\part2_blink_closed_patch.png'
$audio = Join-Path $root 'filmora_editable\06_藍のこえ_原曲.mp3'
$ass = (Join-Path $root 'work\ai_no_koe_part2_sync.ass').Replace('\', '/').Replace(':', '\:')
$output = Join-Path $root 'outputs\藍の声_第2部_砕けた光を拾う・瞬き・歌詞同期版_51秒.mp4'

$halfEnable = @(
  'between(t,10.32,10.38)', 'between(t,10.50,10.56)',
  'between(t,22.66,22.72)', 'between(t,22.84,22.90)',
  'between(t,36.36,36.42)', 'between(t,36.54,36.60)',
  'between(t,45.12,45.18)', 'between(t,45.30,45.36)'
) -join '+'
$closedEnable = @(
  'between(t,10.38,10.50)', 'between(t,22.72,22.84)',
  'between(t,36.42,36.54)', 'between(t,45.18,45.30)'
) -join '+'

$filter = @"
[0:v]format=gbrp[open];
[1:v]format=rgba[half];
[2:v]format=rgba[closed];
[open][half]overlay=x=880:y=75:enable='$halfEnable':eof_action=repeat[s1];
[s1][closed]overlay=x=880:y=75:enable='$closedEnable':eof_action=repeat[s2];
[s2]scale=1920:1080,format=gbrp,
eq=contrast=1.045:brightness=-0.018:saturation=0.88,
colorbalance=rs=-0.015:gm=0.010:bm=0.020:bs=0.015,
drawbox=x=0:y=0:w=iw:h=ih:color=0x1a2538@0.08:t=fill:enable='between(t,3.0,9.3)',
drawbox=x=0:y=0:w=iw:h=ih:color=0xd6b36a@0.035:t=fill:enable='between(t,10.0,14.0)',
drawbox=x=0:y=0:w=iw:h=ih:color=black@0.16:t=fill:enable='between(t,24.6,30.2)',
drawbox=x=0:y=0:w=iw:h=ih:color=0xe1bd72@0.035:t=fill:enable='between(t,29.8,35.1)',
format=yuv420p[graded];
[graded]zoompan=z='if(lt(on,420),1.025+0.00008*on,if(lt(on,900),1.0586+0.00010*(on-420),1.1066+0.00007*(on-900)))':x='iw/2-(iw/zoom/2)+38*sin(on/155)-24*cos(on/260)':y='ih/2-(ih/zoom/2)+15*sin(on/185)':d=1:s=1920x1080:fps=30[camera];
[camera]subtitles='$ass'[v]
"@

ffmpeg -y -loop 1 -framerate 30 -i $visualOpen -loop 1 -framerate 30 -i $eyesHalf -loop 1 -framerate 30 -i $eyesClosed -i $audio `
  -filter_complex $filter -map '[v]' -map 3:a:0 `
  -af "atrim=start=49.90:end=100.55,asetpts=PTS-STARTPTS" `
  -c:v libx264 -preset veryfast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 50.65 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 2 blink/sync render failed' }
Write-Output $output
