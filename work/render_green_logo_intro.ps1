$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root='C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$out=Join-Path $root 'projects\maji-love-i\deliverables\green-logo-intro-mic-v2'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$code=@'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
public class GreenIntro {
static double E(double t) { t=Math.Max(0,Math.Min(1,t)); return t*t*(3-2*t); }
static GraphicsPath Text(string s,string font,float size,RectangleF target) {
var p=new GraphicsPath(); using(var f=new FontFamily(font)) p.AddString(s,f,1,size,new PointF(0,0),StringFormat.GenericTypographic);
var b=p.GetBounds(); var m=new Matrix(); m.Translate(-b.X,-b.Y); p.Transform(m); m.Dispose();
float k=Math.Min(target.Width/b.Width,target.Height/b.Height); m=new Matrix(); m.Scale(k,k); p.Transform(m); m.Dispose();
m=new Matrix(); m.Translate(target.X+(target.Width-b.Width*k)/2,target.Y+(target.Height-b.Height*k)/2); p.Transform(m); m.Dispose(); p.Flatten(null,1); return p;
}
public static void Render(string poster,string folder) {
using(var photo=Image.FromFile(poster)) using(var singer=Image.FromFile(@"C:\Users\自分\Desktop\完成フォルダ\クマPV\01_父クマ_口元・大型ポップガード.png")) {
var glyphs=new GraphicsPath[4]; string s="風光明媚";
Color[] colors={Color.FromArgb(50,85,139),Color.FromArgb(228,99,151),Color.FromArgb(65,134,231),Color.FromArgb(76,190,165)};
for(int c=0;c<4;c++) glyphs[c]=Text(s[c].ToString(),"Yu Gothic",300,new RectangleF(310+c*330,315,300,300));
using(var en=Text("FULL GLOW BABY","Arial",110,new RectangleF(380,628,1160,100))) {
for(int n=0;n<150;n++) { double t=n/30.0;
using(var bm=new Bitmap(1920,1080)) using(var g=Graphics.FromImage(bm)) {
g.SmoothingMode=SmoothingMode.AntiAlias; g.InterpolationMode=InterpolationMode.HighQualityBicubic;
g.Clear(Color.FromArgb(245,246,246)); g.DrawImage(photo,0,0,1920,1080);
double veil=E((t-.35)/.65); using(var brush=new SolidBrush(Color.FromArgb((int)(255*veil),245,246,246))) g.FillRectangle(brush,0,0,1920,1080);
double appear=E((t-.65)/1.0);
if(appear>0) {
using(var ia=new ImageAttributes()) { var cm=new ColorMatrix(); cm.Matrix33=(float)appear; ia.SetColorMatrix(cm);
float zoom=(float)(1+0.025*Math.Max(0,t-.65)/4.35); int w=(int)(1920*zoom), h=(int)(1080*zoom);
g.DrawImage(singer,new Rectangle((1920-w)/2,(1080-h)/2,w,h),0,0,singer.Width,singer.Height,GraphicsUnit.Pixel,ia); }
using(var wash=new SolidBrush(Color.FromArgb((int)(255*.62*appear),245,246,246))) g.FillRectangle(wash,0,0,1920,1080);
}
double p=E((t-1.05)/1.85); double col=E((t-2.7)/.55);
if(t>=.35 && t<2.9) { double a=E((t-.35)/.3)*(1-E((t-1.05)/.65)); float w=(float)(118-104*E((t-.5)/.55)); using(var br=new SolidBrush(Color.FromArgb((int)(255*a),38,128,93))) g.FillRectangle(br,960-w/2,0,w,1080); }
if(t>=1.05) for(int c=0;c<4;c++) {
var pts=glyphs[c].PathPoints; var types=glyphs[c].PathTypes;
for(int j=0;j<pts.Length;j++) { float x=pts[j].X,y=pts[j].Y; float sx=960+(x-960)*.009f; float sy=(y-315)*3.6f;
pts[j]=new PointF((float)(sx+(x-sx)*p),(float)(sy+(y-sy)*p)); }
using(var path=new GraphicsPath(pts,types)) { Color z=colors[c]; var fill=Color.FromArgb((int)(38+(z.R-38)*col),(int)(128+(z.G-128)*col),(int)(93+(z.B-93)*col)); using(var br=new SolidBrush(fill)) g.FillPath(br,path); }
}
if(t>3) { float q=(float)E((t-3)/.55); var state=g.Save(); g.TranslateTransform(0,18*(1-q)); using(var br=new SolidBrush(Color.FromArgb((int)(255*q),26,43,58))) g.FillPath(br,en); g.Restore(state); }
bm.Save(System.IO.Path.Combine(folder,String.Format("frame_{0:D4}.png",n)),ImageFormat.Png);
}
}
} foreach(var p in glyphs)p.Dispose();
}
}
}
'@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing
[GreenIntro]::Render((Join-Path $root 'outputs\クマPVタイトルカード\01_風光明媚_真剣に愛してる_マジLoveィ_タイトルカード.png'),$out)
& ffmpeg -hide_banner -loglevel error -y -framerate 30 -i (Join-Path $out 'frame_%04d.png') -c:v libx264 -crf 18 -pix_fmt yuv420p -movflags +faststart (Join-Path $out '風光明媚_緑ライン変形_風マイク背景_5秒.mp4')
if($LASTEXITCODE -ne 0){throw 'Render failed'}
