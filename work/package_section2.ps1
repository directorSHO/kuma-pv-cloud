$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root='C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$out=Join-Path $root 'projects\maji-love-i\第二構成素材'
$src='C:\Users\自分\Desktop\完成フォルダ\クマPV'
$gen='C:\Users\自分\.codex\generated_images\01a16e8e-920e-7613-8d7d-906ede1c0eec'
Copy-Item -LiteralPath (Join-Path $src '01_父クマ_A_襟元ポーズ.png') -Destination (Join-Path $out '01_父ソロ.png')
Copy-Item -LiteralPath (Join-Path $gen 'exec-31b89feb-b0b1-42d6-a2fb-7a3519bca694.png') -Destination (Join-Path $out '02_父と子ども.png')
Copy-Item -LiteralPath (Join-Path $src '03_母クマ_A_胸に手.png') -Destination (Join-Path $out '03_母ソロ.png')
Copy-Item -LiteralPath (Join-Path $gen 'exec-3647235c-eea3-44b4-bf22-f6edfb55c73c.png') -Destination (Join-Path $out '04_母と子ども.png')
foreach($item in @(@('05_父プロフィール_透過.png','家族愛耐久値：測定不能',65,139,220),@('06_母プロフィール_透過.png','笑顔バフ＋999',230,105,150))){
 $b=New-Object Drawing.Bitmap 1200,230
 $g=[Drawing.Graphics]::FromImage($b); $g.Clear([Drawing.Color]::Transparent);$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='AntiAliasGridFit'
 $bg=New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(235,14,24,44));$g.FillRectangle($bg,14,14,1172,202)
 $c=[Drawing.Color]::FromArgb($item[2],$item[3],$item[4]);$pen=New-Object Drawing.Pen $c,5;$g.DrawRectangle($pen,14,14,1172,202)
 $accent=New-Object Drawing.SolidBrush $c;$g.FillRectangle($accent,14,14,16,202)
 $font=New-Object Drawing.Font 'Yu Gothic',45,([Drawing.FontStyle]::Bold),([Drawing.GraphicsUnit]::Pixel)
 $format=New-Object Drawing.StringFormat;$format.Alignment='Center';$format.LineAlignment='Center'
 $g.DrawString($item[1],$font,[Drawing.Brushes]::White,([Drawing.RectangleF]::new(45,30,1110,165)),$format)
 $b.Save((Join-Path $out $item[0]),[Drawing.Imaging.ImageFormat]::Png)
 $format.Dispose();$font.Dispose();$accent.Dispose();$pen.Dispose();$bg.Dispose();$g.Dispose();$b.Dispose()
}
