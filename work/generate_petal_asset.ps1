$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$out = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat\work\moonlit_petal.png'
$bitmap = New-Object System.Drawing.Bitmap 180, 120, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.Clear([System.Drawing.Color]::Transparent)

$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.StartFigure()
$path.AddBezier(18, 58, 45, 2, 128, 4, 164, 52)
$path.AddBezier(164, 52, 126, 112, 48, 110, 18, 58)
$path.CloseFigure()

$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point 25, 20),
    (New-Object System.Drawing.Point 155, 100),
    ([System.Drawing.Color]::FromArgb(238, 242, 246, 255)),
    ([System.Drawing.Color]::FromArgb(210, 154, 176, 220))
)
$graphics.FillPath($brush, $path)

$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(145, 210, 226, 248)), 2
$graphics.DrawPath($pen, $path)
$vein = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(85, 116, 142, 186)), 1.2
$graphics.DrawBezier($vein, 25, 60, 75, 55, 120, 58, 157, 52)

$bitmap.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$vein.Dispose()
$pen.Dispose()
$brush.Dispose()
$path.Dispose()
$graphics.Dispose()
$bitmap.Dispose()
Write-Output $out
