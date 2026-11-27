$ErrorActionPreference = 'Stop'
$root = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$input = Join-Path $root 'outputs\藍の声_全編_フルスクリーン版_3分20秒.mp4'
$ass = (Join-Path $root 'work\ai_no_koe_old_photo_cracks.ass').Replace('\', '/').Replace(':', '\:')
$output = Join-Path $root 'outputs\藍の声_終幕5秒_古写真リアル燃焼・細縁版.mp4'

$start = 194.566667
$distance = "sqrt(pow(X-W/2,2)+pow(Y-H/2,2))+34*sin(X*0.021+Y*0.014)+17*sin(X*0.059-Y*0.027)+11*sin(X*0.011+Y*0.083+N*0.21)+8*sin(X*0.103+Y*0.041-N*0.17)+22*sin(X*0.009)*sin(Y*0.015)"
$radius = "max(0,(N/30-0.78))*120+pow(max(0,N/30-1.45),1.32)*58"
$burnMask = "255*if(gte(N/30,0.78),if(lt($distance,$radius),1,0),0)"
$scorchMask = "255*if(gte(N/30,0.78),if(between(($distance)-($radius),-3,30),0.72+0.16*sin(X*0.08+Y*0.05+N*0.21),0),0)"
$glowMask = "255*if(gte(N/30,0.78),if(between(abs(($distance)-($radius)),0,11),0.22+0.14*sin(N*0.81+X*0.11+Y*0.04),0),0)"
$edgeMask = "255*if(gte(N/30,0.78),if(between(abs(($distance)-($radius)),0,1.9),0.55+0.24*sin(N*1.03+X*0.15-Y*0.07),0),0)"
$smokeMask = "255*clip((N/30-1.05)/2.2,0,0.22)*exp(-pow((X-W/2)/(125+8*N/30),2)-pow((Y-(H/2-45-18*N/30))/68,2))*(0.65+0.22*sin(X*0.045+Y*0.039+N*0.18))"

$filter = @"
[0:v]trim=start=${start}:end=194.600000,setpts=PTS-STARTPTS,
scale=1820:1024:flags=lanczos,
eq=contrast=0.98:brightness=0.018:saturation=0.62,
colorbalance=rs=0.035:gs=0.018:bs=-0.045,
noise=alls=5:allf=u,vignette=PI/5.8,
tpad=stop_mode=clone:stop_duration=4.97,fps=30[still];

color=c=0x17110e:s=1920x1080:r=30:d=5,
drawbox=x=24:y=10:w=1872:h=1068:color=black@0.62:t=fill[desk];
color=c=0xeee5d1:s=1860x1064:r=30:d=5,
noise=alls=3:allf=u[paper];
[paper][still]overlay=x=20:y=20:eof_action=repeat[photo];
[desk][photo]overlay=x=30:y=8:eof_action=repeat,
subtitles='$ass',split=2[base][darksrc];

[darksrc]eq=contrast=1.08:brightness=-0.19:saturation=0.30[scorched];
nullsrc=s=960x540:r=30:d=5,format=gray,
geq=lum='$scorchMask',gblur=sigma=2:steps=1,scale=1920:1080:flags=bilinear[scorchmask];
[base][scorched][scorchmask]maskedmerge[singed];

color=c=0x0b0503:s=1920x1080:r=30:d=5,
noise=alls=9:allf=t+u[char];
nullsrc=s=960x540:r=30:d=5,format=gray,
geq=lum='$burnMask',scale=1920:1080:flags=bilinear[burnmask];
[singed][char][burnmask]maskedmerge[burned];

nullsrc=s=960x540:r=30:d=5,format=gray,
geq=lum='$glowMask',gblur=sigma=5:steps=2,scale=1920:1080:flags=bilinear[glowmask];
color=c=0x8f2508:s=1920x1080:r=30:d=5,format=rgba[orange];
[orange][glowmask]alphamerge[glow];
[burned][glow]overlay=eof_action=pass[withglow];

nullsrc=s=960x540:r=30:d=5,format=gray,
geq=lum='$edgeMask',gblur=sigma=1:steps=1,scale=1920:1080:flags=bilinear[edgemask];
color=c=0xffcf83:s=1920x1080:r=30:d=5,format=rgba[amber];
[amber][edgemask]alphamerge[hotedge];
[withglow][hotedge]overlay=eof_action=pass[withfire];

nullsrc=s=960x540:r=30:d=5,format=gray,
geq=lum='$smokeMask',gblur=sigma=16:steps=2,scale=1920:1080:flags=bilinear[smokemask];
color=c=0x5d5751:s=1920x1080:r=30:d=5,format=rgba[smokecolor];
[smokecolor][smokemask]alphamerge[smoke];
[withfire][smoke]overlay=eof_action=pass,
fade=t=out:st=4.55:d=0.45,format=yuv420p,setsar=1,setdar=16/9[v];

[0:a]atrim=start=${start}:end=199.566667,asetpts=PTS-STARTPTS[a]
"@

ffmpeg -y -hide_banner -i $input -filter_complex $filter `
  -map '[v]' -map '[a]' -c:v libx264 -preset veryfast -crf 18 `
  -maxrate 10000k -bufsize 20000k -r 30 -c:a aac -b:a 192k `
  -movflags +faststart -t 5 $output

if ($LASTEXITCODE -ne 0) { throw 'Old-photo burn preview render failed' }
Write-Output $output
