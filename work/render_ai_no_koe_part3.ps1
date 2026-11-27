$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$visual = Join-Path $root 'work\part3_concept_voice_becomes_light_v2.png'
$audio = 'C:\Users\自分\Desktop\藍のこえ (Remastered).mp3'
$ass = (Join-Path $root 'work\ai_no_koe_part3.ass').Replace('\', '/').Replace(':', '\:')
$output = Join-Path $root 'outputs\藍の声_第3部_声が光になる_49秒.mp4'

$filter = @"
[0:v]scale=2304:1296,format=gbrp,
eq=contrast=1.06:brightness=-0.025:saturation=0.94,
colorbalance=rs=0.012:gs=0.006:bm=0.025:bs=0.012,
drawbox=x=0:y=0:w=iw:h=ih:color=0xb7dcff@0.035:t=fill:enable='between(t,0.0,6.2)',
drawbox=x=0:y=0:w=iw:h=ih:color=0xe7c77a@0.045:t=fill:enable='between(t,11.0,17.2)',
drawbox=x=0:y=0:w=iw:h=ih:color=black@0.10:t=fill:enable='between(t,17.0,26.8)',
drawbox=x=0:y=0:w=iw:h=ih:color=0xf2cf82@0.045:t=fill:enable='between(t,26.8,33.2)',
format=yuv420p[graded];
[graded]zoompan=z='if(lt(on,510),1.02+0.00014*on,if(lt(on,810),1.0914+0.000035*(on-510),1.1019+0.00012*(on-810)))':x='iw/2-(iw/zoom/2)+72*sin(on/185)+if(lt(on,510),42,-28)':y='ih/2-(ih/zoom/2)+38*cos(on/230)+if(lt(on,810),-18,26)':d=1:s=1920x1080:fps=30[camera];
[camera]vignette=PI/6.3:eval=frame,fade=t=in:st=0:d=0.42,fade=t=out:st=47.75:d=0.75,subtitles='$ass'[v]
"@

ffmpeg -y -loop 1 -framerate 30 -i $visual -i $audio `
  -filter_complex $filter -map '[v]' -map 1:a:0 `
  -af "atrim=start=100.55:end=149.05,asetpts=PTS-STARTPTS" `
  -c:v libx264 -preset veryfast -crf 18 -maxrate 9000k -bufsize 18000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 48.50 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 3 render failed' }
Write-Output $output
