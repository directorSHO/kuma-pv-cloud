$ErrorActionPreference = 'Stop'

$workspace = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$sourceRoot = 'C:\Users\自分\Desktop\完成フォルダ\クマPV'
$assetRoot = Join-Path $workspace 'projects\maji-love-i\assets\proposal1-revision'
$deliverables = Join-Path $workspace 'projects\maji-love-i\deliverables'
$output = Join-Path $deliverables '15-18秒差し替え_LOVEぃ水色落下_効果音付き.mp4'

New-Item -ItemType Directory -Path $deliverables -Force | Out-Null
Set-Location -LiteralPath $workspace

$background = Join-Path $sourceRoot '01_0000_無表情の家族写真.png'
$object = Join-Path $assetRoot 'LOVEぃ_水色_透過オブジェクト.png'
$landed = Join-Path $assetRoot 'LOVEぃ_水色_着地.png'

$filter = @'
[0:v]scale=1920:1080,setsar=1,fps=30,trim=duration=1.28,setpts=PTS-STARTPTS[base];
[1:v]format=rgba,crop=1672:560:0:210,scale=1680:-1,rotate='0.018*sin(8*t)':ow=rotw(iw):oh=roth(ih):c=none,fps=30[obj];
[base][obj]overlay=x='(W-w)/2':y='-650+910*pow(min(t/1.28,1),2)':shortest=1,trim=duration=1.28,setpts=PTS-STARTPTS[fall];
[2:v]scale=1980:1114,crop=1920:1080:x='30+12*sin(n*2.8)*exp(-n/18)':y='17+9*sin(n*3.7)*exp(-n/18)',setsar=1,fps=30,trim=duration=1.72,setpts=PTS-STARTPTS[land];
[fall][land]concat=n=2:v=1:a=0,drawbox=x=0:y=0:w=iw:h=ih:color=white@0.28:t=fill:enable='between(t,1.28,1.34)',format=yuv420p[vout];
anoisesrc=color=white:duration=1.28:sample_rate=48000,highpass=f=550,lowpass=f=4200,volume='if(isnan(t),0.025,0.025+0.17*t/1.28)':eval=frame,afade=t=in:st=0:d=0.12,afade=t=out:st=1.12:d=0.16[whoosh];
anoisesrc=color=white:duration=0.11:sample_rate=48000,highpass=f=1700,lowpass=f=7600,volume=0.34,adelay=1280|1280[crack];
anoisesrc=color=brown:duration=0.62:sample_rate=48000,highpass=f=30,lowpass=f=230,volume=0.88,afade=t=out:st=0.16:d=0.46,adelay=1280|1280[hit];
sine=frequency=48:duration=0.92:sample_rate=48000,volume=0.46,afade=t=out:st=0.18:d=0.74,adelay=1280|1280[boom];
anoisesrc=color=brown:duration=1.12:sample_rate=48000,highpass=f=130,lowpass=f=950,volume=0.18,afade=t=out:st=0.20:d=0.92,adelay=1360|1360[debris];
[whoosh][crack][hit][boom][debris]amix=inputs=5:duration=longest:normalize=0,aecho=0.8:0.25:55|110:0.20|0.10,volume=8.0,alimiter=limit=0.94,apad=pad_dur=3,atrim=duration=3[aout]
'@

$args = @(
    '-hide_banner', '-y',
    '-loop', '1', '-t', '1.28', '-i', $background,
    '-loop', '1', '-t', '1.28', '-i', $object,
    '-loop', '1', '-t', '1.72', '-i', $landed,
    '-filter_complex', $filter,
    '-map', '[vout]', '-map', '[aout]',
    '-t', '3',
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '18',
    '-pix_fmt', 'yuv420p', '-r', '30',
    '-c:a', 'aac', '-b:a', '256k', '-ar', '48000', '-ac', '2',
    '-movflags', '+faststart',
    $output
)

& ffmpeg @args
if ($LASTEXITCODE -ne 0) {
    throw "ffmpeg failed with exit code $LASTEXITCODE"
}

Write-Output $output
