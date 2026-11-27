$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$ass = (Join-Path $root 'work\ai_no_koe_half.ass').Replace('\', '/').Replace(':', '\:')
$audio = 'C:\Users\自分\Desktop\藍のこえ (Remastered).mp3'
$visual = Join-Path $root 'work\藍の声_文字PV_前半映像のみ.mp4'
$preview = Join-Path $root 'outputs\藍の声_文字PV_前半プレビュー.mp4'

ffmpeg -y -f lavfi -i "gradients=s=1920x1080:r=30:d=100:c0=0x03040d:c1=0x101844:c2=0x32136b:c3=0x0b5d75:n=4:type=radial:speed=0.003" `
  -vf "noise=alls=7:allf=t+u,eq=contrast=1.08:saturation=1.18,vignette=PI/4,subtitles='$ass'" `
  -an -c:v libx264 -preset medium -crf 17 -pix_fmt yuv420p -r 30 -movflags +faststart -t 100 $visual
if ($LASTEXITCODE -ne 0) { throw 'visual render failed' }

ffmpeg -y -i $visual -i $audio -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 256k -af "afade=t=out:st=98.5:d=1.5" -t 100 -movflags +faststart $preview
if ($LASTEXITCODE -ne 0) { throw 'preview mux failed' }

Write-Output $visual
Write-Output $preview
