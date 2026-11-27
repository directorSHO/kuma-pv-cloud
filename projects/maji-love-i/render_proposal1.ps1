$ErrorActionPreference = 'Stop'

$workspace = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$sourceRoot = 'C:\Users\自分\Desktop\完成フォルダ\クマPV'
$deliverables = Join-Path $workspace 'projects\maji-love-i\deliverables'
$output = Join-Path $deliverables '提案1_真面目すぎる導入_18秒試作.mp4'

New-Item -ItemType Directory -Path $deliverables -Force | Out-Null
Set-Location -LiteralPath $workspace

$posing = Join-Path $sourceRoot 'Flow動画\Four_bear_family_members_posing_20261018021519.mp4'
$dolly = Join-Path $sourceRoot 'Flow動画\Bear_family_portrait_dolly-in_20261018021544.mp4'
$whisper = Join-Path $sourceRoot 'Flow動画\Father_bear_whispering_to_camera_20261018021548.mp4'
$loveAppear = Join-Path $sourceRoot '04_0015_LOVEぃ出現.png'
$loveDrop = Join-Path $sourceRoot '05_0017_LOVEぃ床へ落下.png'
$song = Join-Path $sourceRoot '真剣に愛してる!― マジLoveィ ―.mp3'

$filter = @'
[0:v]trim=start=0:end=6,setpts=PTS-STARTPTS,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,setsar=1,fps=30,fade=t=in:st=0:d=0.25[v0];
[1:v]trim=start=0:end=6,setpts=PTS-STARTPTS,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,setsar=1,fps=30[v1];
[2:v]trim=start=0:end=3,setpts=PTS-STARTPTS,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,setsar=1,fps=30[v2];
[3:v]scale=1920:1080,zoompan=z='min(zoom+0.0015,1.09)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=60:s=1920x1080:fps=30,trim=duration=2,setpts=PTS-STARTPTS[v3];
[4:v]scale=2016:1134,crop=1920:1080:x='48+10*sin(n*2.1)':y='27+8*sin(n*2.9)',fps=30,trim=duration=1,setpts=PTS-STARTPTS[v4];
[v0][v1][v2][v3][v4]concat=n=5:v=1:a=0,subtitles='projects/maji-love-i/development/subtitle.ass',format=yuv420p[vout];
[5:a]atrim=start=0:end=18,asetpts=PTS-STARTPTS,volume=0.90,afade=t=in:st=0:d=0.25[a_song];
anoisesrc=color=brown:duration=0.65:sample_rate=48000,lowpass=f=170,highpass=f=35,volume=0.70,adelay=17000|17000[a_noise];
sine=frequency=55:duration=0.55:sample_rate=48000,volume=0.30,adelay=17000|17000[a_boom];
[a_song][a_noise][a_boom]amix=inputs=3:duration=first:normalize=0,alimiter=limit=0.95[aout]
'@

$args = @(
    '-hide_banner', '-y',
    '-i', $posing,
    '-i', $dolly,
    '-i', $whisper,
    '-loop', '1', '-t', '2', '-i', $loveAppear,
    '-loop', '1', '-t', '1', '-i', $loveDrop,
    '-i', $song,
    '-filter_complex', $filter,
    '-map', '[vout]', '-map', '[aout]',
    '-t', '18',
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
