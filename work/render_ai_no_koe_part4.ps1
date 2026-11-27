$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$visual = Join-Path $root 'work\part4_concept_world_regains_color.png'
$audio = Join-Path $root 'filmora_editable\06_藍のこえ_原曲.mp3'
$ass = (Join-Path $root 'work\ai_no_koe_part4.ass').Replace('\', '/').Replace(':', '\:')
$output = Join-Path $root 'outputs\藍の声_第4部_世界が色を取り戻す_51秒.mp4'

$filter = @"
[0:v]scale=2304:1296,format=gbrp,
eq=contrast='1.035+0.0012*min(t,25)':brightness='-0.035+0.0021*min(t,24)':saturation='0.88+0.013*min(t,25)':eval=frame,
colorbalance=rs=0.010:gs=0.004:bm=0.032:bs=0.018,
drawbox=x=0:y=0:w=iw:h=ih:color=0x16102c@0.10:t=fill:enable='between(t,0,7.5)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x725db5@0.025:t=fill:enable='between(t,7.5,15.8)',
drawbox=x=0:y=0:w=iw:h=ih:color=0xe8b872@0.035:t=fill:enable='between(t,15.8,31.7)',
drawbox=x=0:y=0:w=iw:h=ih:color=0xffd9a2@0.045:t=fill:enable='between(t,31.7,50.8)',
format=yuv420p[graded];
[graded]zoompan=z='if(lt(on,324),1.015+0.00014*on,if(lt(on,951),1.06036+0.000052*(on-324),1.09296+0.000095*(on-951)))':x='iw/2-(iw/zoom/2)+if(lt(on,324),-55+0.20*on,if(lt(on,951),10+34*sin((on-324)/250),44-0.10*(on-951)))':y='ih/2-(ih/zoom/2)+if(lt(on,951),-25+28*cos(on/270),18+0.035*(on-951))':d=1:s=1920x1080:fps=30[camera];
[camera]vignette=PI/7.2:eval=frame,fade=t=in:st=0:d=0.45,fade=t=out:st=49.65:d=1.10,subtitles='$ass'[v]
"@

ffmpeg -y -loop 1 -framerate 30 -i $visual -i $audio `
  -filter_complex $filter -map '[v]' -map 1:a:0 `
  -af "atrim=start=148.78:end=199.56,asetpts=PTS-STARTPTS" `
  -c:v libx264 -preset veryfast -crf 18 -maxrate 9000k -bufsize 18000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart -t 50.78 $output

if ($LASTEXITCODE -ne 0) { throw 'Part 4 render failed' }
Write-Output $output
