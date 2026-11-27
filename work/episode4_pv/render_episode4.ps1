$ErrorActionPreference = 'Stop'

$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$assets = Join-Path $root 'work\episode4_pv\assets'
$ass = (Join-Path $root 'work\episode4_pv\episode4.ass').Replace('\', '/').Replace(':', '\:')
$output = Join-Path $root 'outputs\クマのDIY奇譚_第四怪_床下PV_30秒.mp4'
$source = 'C:\Users\自分\Desktop\完成フォルダ\クマ'

$filter = @"
[0:v]scale=2048:1152:force_original_aspect_ratio=increase,crop=2048:1152,zoompan=z='min(zoom+0.00035,1.035)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=135:s=1920x1080:fps=30,trim=duration=4.5,setpts=PTS-STARTPTS,fade=t=in:st=0:d=0.35,fade=t=out:st=4.15:d=0.35,setsar=1[v0];
[1:v]scale=2048:1152:force_original_aspect_ratio=increase,crop=2048:1152,zoompan=z='min(zoom+0.00025,1.04)':x='iw/2-(iw/zoom/2)-55':y='ih/2-(ih/zoom/2)':d=195:s=1920x1080:fps=30,trim=duration=6.5,setpts=PTS-STARTPTS,fade=t=in:st=0:d=0.28,fade=t=out:st=6.15:d=0.35,setsar=1[v1];
[2:v]scale=2048:1152:force_original_aspect_ratio=increase,crop=2048:1152,zoompan=z='min(zoom+0.00045,1.055)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)+15':d=195:s=1920x1080:fps=30,trim=duration=6.5,setpts=PTS-STARTPTS,fade=t=in:st=0:d=0.25,fade=t=out:st=6.15:d=0.35,setsar=1[v2];
[3:v]scale=2048:1152:force_original_aspect_ratio=increase,crop=2048:1152,zoompan=z='min(zoom+0.0003,1.045)':x='iw/2-(iw/zoom/2)-70':y='ih/2-(ih/zoom/2)':d=195:s=1920x1080:fps=30,trim=duration=6.5,setpts=PTS-STARTPTS,fade=t=in:st=0:d=0.20,fade=t=out:st=6.15:d=0.35,setsar=1[v3];
[2:v]scale=2048:1152:force_original_aspect_ratio=increase,crop=2048:1152,zoompan=z='min(zoom+0.0002,1.025)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=180:s=1920x1080:fps=30,trim=duration=6,setpts=PTS-STARTPTS,eq=brightness=-0.28:saturation=0.55,boxblur=2:1,setsar=1[bg];
[4:v]scale=940:-1,format=rgba,colorchannelmixer=aa=0.94[logo];
[bg][logo]overlay=(W-w)/2:(H-h)/2-50:shortest=1,fade=t=in:st=0:d=0.4,fade=t=out:st=5.65:d=0.35[v4];
[v0][v1][v2][v3][v4]concat=n=5:v=1:a=0,noise=alls=2.2:allf=t+u,vignette=PI/5,subtitles='$ass'[video];
[5:a]atrim=0:30,asetpts=PTS-STARTPTS,volume=0.42,afade=t=in:st=0:d=1.2,afade=t=out:st=27.5:d=2.5[base];
[6:a]atrim=0:11.5,volume=0.16,adelay=10500|10500[rumble];
[7:a]aloop=loop=4:size=170758,atrim=0:15,volume=0.30,adelay=11500|11500[heart];
[8:a]volume=0.42,adelay=4400|4400[s1];
[8:a]volume=0.36,adelay=10800|10800[s2];
[8:a]volume=0.38,adelay=17300|17300[s3];
[9:a]volume=0.72,adelay=23800|23800[title];
[10:a]volume=0.46,adelay=23250|23250[hit];
[11:a]volume=0.30,adelay=28200|28200[bell];
[base][rumble][heart][s1][s2][s3][title][hit][bell]amix=inputs=9:duration=longest:dropout_transition=0:normalize=0,alimiter=limit=0.92,atrim=0:30[audio]
"@

ffmpeg -y `
  -loop 1 -framerate 30 -i (Join-Path $assets '01_floor_gap.png') `
  -loop 1 -framerate 30 -i (Join-Path $assets '02_bear_pry.png') `
  -loop 1 -framerate 30 -i (Join-Path $assets '03_underfloor_mirror.png') `
  -loop 1 -framerate 30 -i (Join-Path $assets '04_bear_turn.png') `
  -loop 1 -framerate 30 -i (Join-Path $assets 'logo.png') `
  -i (Join-Path $source '不安の種.mp3') `
  -i (Join-Path $source 'ゴゴゴゴ.mp3') `
  -i (Join-Path $source '心臓の鼓動1.mp3') `
  -i (Join-Path $source 'ホラー文字表示音.mp3') `
  -i (Join-Path $source 'ホラータイトル表示音.mp3') `
  -i (Join-Path $source 'ドーン.mp3') `
  -i (Join-Path $source 'チリン.mp3') `
  -filter_complex $filter `
  -map '[video]' -map '[audio]' `
  -c:v libx264 -preset medium -crf 17 -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 256k -movflags +faststart -t 30 $output

if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed with exit code $LASTEXITCODE" }
Write-Output $output
