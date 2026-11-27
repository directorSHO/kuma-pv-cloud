$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$visualOpen = Join-Path $root 'work\part3_concept_voice_becomes_light_v2.png'
$eyesHalf = Join-Path $root 'work\part3_blink_half_patch.png'
$eyesClosed = Join-Path $root 'work\part3_blink_closed_patch.png'
$audio = Join-Path $root 'filmora_editable\06_藍のこえ_原曲.mp3'
$ass = (Join-Path $root 'work\ai_no_koe_part3_sync.ass').Replace('\', '/').Replace(':', '\:')
$output = Join-Path $root 'outputs\藍の声_第3部_声が光になる・瞬き・歌詞同期版_49秒.mp4'

$halfEnable = @(
  'between(t,6.22,6.28)', 'between(t,6.40,6.46)',
  'between(t,19.16,19.22)', 'between(t,19.34,19.40)',
  'between(t,33.72,33.78)', 'between(t,33.90,33.96)',
  'between(t,43.36,43.42)', 'between(t,43.54,43.60)'
) -join '+'
$closedEnable = @(
  'between(t,6.28,6.40)', 'between(t,19.22,19.34)',
  'between(t,33.78,33.90)', 'between(t,43.42,43.54)'
) -join '+'

$filter = @"
[0:v]format=gbrp[open];
[1:v]format=rgba[half];
[2:v]format=rgba[closed];
[open][half]overlay=x=700:y=170:enable='$halfEnable':eof_action=repeat[s1];
[s1][closed]overlay=x=700:y=170:enable='$closedEnable':eof_action=repeat[s2];
[s2]scale=2304:1296,format=gbrp,
eq=contrast=1.06:brightness=-0.025:saturation=0.94,
colorbalance=rs=0.012:gs=0.006:bm=0.025:bs=0.012,
drawbox=x=0:y=0:w=iw:h=ih:color=0xb7dcff@0.035:t=fill:enable='between(t,0.0,6.2)',
drawbox=x=0:y=0:w=iw:h=ih:color=0xe7c77a@0.045:t=fill:enable='between(t,11.0,17.2)',
drawbox=x=0:y=0:w=iw:h=ih:color=black@0.10:t=fill:enable='between(t,17.0,26.8)',
drawbox=x=0:y=0:w=iw:h=ih:color=0xf2cf82@0.045:t=fill:enable='between(t,26.8,33.2)',
format=yuv420p[graded];
[graded]zoompan=z='if(lt(on,510),1.02+0.00014*on,if(lt(on,810),1.0914+0.000035*(on-510),1.1019+0.00012*(on-810)))':x='iw/2-(iw/zoom/2)+72*sin(on/185)+if(lt(on,510),42,-28)':y='ih/2-(ih/zoom/2)+38*cos(on/230)+if(lt(on,810),-18,26)':d=1:s=1920x1080:fps=30[camera];
[camera]vignette=PI/6.3:eval=frame,fade=t=in:st=0:d=0.42,fade=t=out:st=47.48:d=0.75,subtitles='$ass'[v]
"@

ffmpeg -y -loop 1 -framerate 30 -i $visualOpen -loop 1 -framerate 30 -i $eyesHalf -loop 1 -framerate 30 -i $eyesClosed -i $audio `
  -filter_complex $filter -map '[v]' -map 3:a:0 `
  -af "atrim=start=100.55:end=148.78,asetpts=PTS-STARTPTS" `
  -c:v libx264 -preset veryfast -crf 18 -maxrate 9000k -bufsize 18000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 48.23 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 3 blink/sync render failed' }
Write-Output $output
