$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$visual = Join-Path $root 'work\part2_concept_shattered_light.png'
$audio = 'C:\Users\自分\Desktop\藍のこえ (Remastered).mp3'
$ass = (Join-Path $root 'work\ai_no_koe_part2.ass').Replace('\', '/').Replace(':', '\:')
$output = Join-Path $root 'outputs\藍の声_第2部_砕けた光を拾う_51秒.mp4'

$filter = @"
[0:v]scale=1920:1080,format=gbrp,
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

ffmpeg -y -loop 1 -framerate 30 -i $visual -i $audio `
  -filter_complex $filter -map '[v]' -map 1:a:0 `
  -af "atrim=start=49.90:end=100.78,asetpts=PTS-STARTPTS" `
  -c:v libx264 -preset veryfast -crf 19 -maxrate 8000k -bufsize 16000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 50.88 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 2 render failed' }
Write-Output $output
