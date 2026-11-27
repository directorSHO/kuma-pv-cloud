$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$concatList = Join-Path $root 'work\ai_no_koe_full_concat.txt'
$videoOnly = Join-Path $root 'work\ai_no_koe_full_video_only.mp4'
$audio = Join-Path $root 'filmora_editable\06_藍のこえ_原曲.mp3'
$output = Join-Path $root 'outputs\藍の声_全編_瞬き・歌詞同期調整版_3分20秒.mp4'
$filmoraCopy = Join-Path $root 'filmora_editable\52_藍の声_全編_瞬き・歌詞同期調整版_3分20秒.mp4'

$parts = @(
    (Join-Path $root 'outputs\藍の声_第1部_満月背景調和・瞬き・歌詞同期版_50秒.mp4'),
    (Join-Path $root 'outputs\藍の声_第2部_砕けた光を拾う・瞬き・歌詞同期版_51秒.mp4'),
    (Join-Path $root 'outputs\藍の声_第3部_声が光になる・瞬き・歌詞同期版_49秒.mp4'),
    (Join-Path $root 'outputs\藍の声_第4部_歌詞同期・終幕エフェクト版_51秒.mp4')
)

$concatLines = $parts | ForEach-Object { "file '$($_.Replace("'", "''"))'" }
Set-Content -LiteralPath $concatList -Value $concatLines -Encoding utf8

ffmpeg -y -hide_banner -f concat -safe 0 -i $concatList -map 0:v:0 -an -c:v copy -fflags +genpts $videoOnly
if ($LASTEXITCODE -ne 0) { throw 'Full video concatenation failed' }

$audioFilter = @"
[1:a]atrim=start=0:end=199.56,asetpts=PTS-STARTPTS,asplit=2[amain][awet];
[awet]atrim=start=174.98:end=199.56,asetpts=PTS-STARTPTS,
aecho=0.82:0.72:520|980:0.12|0.065,volume=0.30,adelay=174980|174980[echo];
anoisesrc=color=pink:amplitude=0.010:d=199.56:r=48000,
highpass=f=170,lowpass=f=2100,
afade=t=in:st=179.78:d=5.20,afade=t=out:st=196.36:d=3.20,volume=0.30[air];
[amain][echo][air]amix=inputs=3:duration=longest:normalize=0,
alimiter=limit=0.95,afade=t=out:st=196.98:d=2.58,atrim=start=0:end=199.56[a]
"@

ffmpeg -y -hide_banner -i $videoOnly -i $audio -filter_complex $audioFilter `
  -map 0:v:0 -map '[a]' -c:v copy -c:a aac -b:a 192k -movflags +faststart -t 199.56 $output
if ($LASTEXITCODE -ne 0) { throw 'Final mux failed' }

Copy-Item -LiteralPath $output -Destination $filmoraCopy -Force
Write-Output $output

