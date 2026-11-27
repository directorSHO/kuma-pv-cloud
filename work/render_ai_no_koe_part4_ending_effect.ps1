$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$inputVideo = Join-Path $root 'outputs\藍の声_第4部_世界が色を取り戻す_51秒.mp4'
$output = Join-Path $root 'outputs\藍の声_第4部_終幕アンニュイエフェクト_25秒.mp4'

# 第4部の26.20秒地点から終端まで。
# 「いつか 伝えたかったんだよ」の直前から、ハーモニーと余韻を収録する。
$filter = @"
[0:v]trim=start=26.20:end=50.78,setpts=PTS-STARTPTS,split=2[base][dream];
[dream]gblur=sigma=13:steps=2,eq=saturation=0.72:brightness=0.018[dreamblur];
[base][dreamblur]blend=all_mode=screen:all_opacity=0.13,
drawbox=x=0:y=0:w=iw:h=ih:color=0xd7c5ff@0.055:t=fill:enable='between(t,5.05,5.75)',
drawbox=x=0:y=0:w=iw:h=ih:color=0x251d48@0.065:t=fill:enable='gte(t,5.5)',
hue=s='if(lt(t,5.2),1,max(0.32,1-0.041*(t-5.2)))',
eq=contrast='if(lt(t,5.2),1,1+0.007*(t-5.2))':brightness='if(lt(t,5.2),0,-0.0085*(t-5.2))':eval=frame,
vignette=angle='if(lt(t,5.2),PI/7.2,max(PI/12,PI/7.2-0.010*(t-5.2)))':eval=frame,
fade=t=out:st=21.45:d=3.13[v];

[0:a]atrim=start=26.20:end=50.78,asetpts=PTS-STARTPTS,asplit=2[amain][awet];
[awet]aecho=0.82:0.72:520|980:0.12|0.065,volume=0.30[echo];
anoisesrc=color=pink:amplitude=0.010:d=24.58:r=48000,
highpass=f=170,lowpass=f=2100,
afade=t=in:st=4.8:d=5.2,afade=t=out:st=21.2:d=3.2,volume=0.30[air];
[amain][echo][air]amix=inputs=3:duration=longest:normalize=0,
alimiter=limit=0.95,afade=t=out:st=22.00:d=2.58[a]
"@

ffmpeg -y -i $inputVideo -filter_complex $filter `
  -map '[v]' -map '[a]' -t 24.58 `
  -c:v libx264 -preset veryfast -crf 18 -maxrate 9000k -bufsize 18000k -pix_fmt yuv420p -r 30 `
  -c:a aac -b:a 192k -movflags +faststart $output

if ($LASTEXITCODE -ne 0) { throw 'Part 4 ending effect render failed' }
Write-Output $output
