Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$workspace = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$glyphDir = Join-Path $workspace 'outputs\風光明媚_白筆文字_透過'
$outputDir = Join-Path $workspace 'outputs\クマPVロゴ素材'
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

function New-Canvas([int]$width, [int]$height) {
    $bmp = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return @($bmp, $g)
}

function New-TextPath(
    [string]$text,
    [string]$fontName,
    [System.Drawing.FontStyle]$style,
    [float]$fontSize,
    [System.Drawing.RectangleF]$rect
) {
    $family = [System.Drawing.FontFamily]::new($fontName)
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddString($text, $family, [int]$style, $fontSize, $rect, $format)
    $family.Dispose()
    $format.Dispose()
    return $path
}

function Draw-OutlinedGradientText(
    [System.Drawing.Graphics]$graphics,
    [System.Drawing.Drawing2D.GraphicsPath]$path,
    [System.Drawing.Color]$topColor,
    [System.Drawing.Color]$bottomColor,
    [System.Drawing.Color]$outlineColor,
    [float]$outlineWidth,
    [System.Drawing.Color]$shadowColor,
    [float]$shadowX,
    [float]$shadowY
) {
    $shadowPath = $path.Clone()
    $matrix = [System.Drawing.Drawing2D.Matrix]::new()
    $matrix.Translate($shadowX, $shadowY)
    $shadowPath.Transform($matrix)
    $shadowBrush = [System.Drawing.SolidBrush]::new($shadowColor)
    $graphics.FillPath($shadowBrush, $shadowPath)
    $shadowBrush.Dispose()
    $shadowPath.Dispose()
    $matrix.Dispose()

    $bounds = $path.GetBounds()
    $gradient = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $bounds,
        $topColor,
        $bottomColor,
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $outlinePen = [System.Drawing.Pen]::new($outlineColor, $outlineWidth)
    $outlinePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $graphics.DrawPath($outlinePen, $path)
    $graphics.FillPath($gradient, $path)
    $outlinePen.Dispose()
    $gradient.Dispose()
}

function Draw-TintedImage(
    [System.Drawing.Graphics]$graphics,
    [System.Drawing.Image]$image,
    [System.Drawing.Rectangle]$destination,
    [System.Drawing.Color]$color,
    [float]$opacity
) {
    $attrs = [System.Drawing.Imaging.ImageAttributes]::new()
    $matrix = [System.Drawing.Imaging.ColorMatrix]::new()
    $matrix.Matrix00 = 0
    $matrix.Matrix11 = 0
    $matrix.Matrix22 = 0
    $matrix.Matrix33 = $opacity
    $matrix.Matrix40 = $color.R / 255.0
    $matrix.Matrix41 = $color.G / 255.0
    $matrix.Matrix42 = $color.B / 255.0
    $attrs.SetColorMatrix($matrix)
    $graphics.DrawImage(
        $image,
        $destination,
        0, 0, $image.Width, $image.Height,
        [System.Drawing.GraphicsUnit]::Pixel,
        $attrs
    )
    $attrs.Dispose()
}

# 1. Unit logo: white brush characters behind, FULL GLOW BABY in front.
$canvas = New-Canvas 2400 900
$unitBitmap = $canvas[0]
$unitGraphics = $canvas[1]
$glyphFiles = @(
    '01_風_白筆文字_透過.png',
    '02_光_白筆文字_透過.png',
    '03_明_白筆文字_透過.png',
    '04_媚_白筆文字_透過.png'
)
$glyphSize = 490
$glyphGap = 40
$totalGlyphWidth = ($glyphSize * 4) + ($glyphGap * 3)
$glyphStartX = [int]((2400 - $totalGlyphWidth) / 2)
for ($i = 0; $i -lt $glyphFiles.Count; $i++) {
    $img = [System.Drawing.Image]::FromFile((Join-Path $glyphDir $glyphFiles[$i]))
    $x = $glyphStartX + ($i * ($glyphSize + $glyphGap))
    $shadowRect = [System.Drawing.Rectangle]::new($x + 13, 63, $glyphSize, $glyphSize)
    $mainRect = [System.Drawing.Rectangle]::new($x, 48, $glyphSize, $glyphSize)
    Draw-TintedImage $unitGraphics $img $shadowRect ([System.Drawing.Color]::FromArgb(12, 20, 44)) 0.82
    $unitGraphics.DrawImage($img, $mainRect)
    $img.Dispose()
}

$englishRect = [System.Drawing.RectangleF]::new(90, 440, 2220, 370)
$englishPath = New-TextPath 'FULL GLOW BABY' 'Bahnschrift SemiBold Condensed' ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic) 235 $englishRect
Draw-OutlinedGradientText $unitGraphics $englishPath `
    ([System.Drawing.Color]::FromArgb(255, 67, 96)) `
    ([System.Drawing.Color]::FromArgb(172, 0, 100)) `
    ([System.Drawing.Color]::White) 18 `
    ([System.Drawing.Color]::FromArgb(190, 4, 10, 28)) 20 24

$englishPath.Dispose()
$unitGraphics.Dispose()
$unitPath = Join-Path $outputDir '01_ユニットロゴ_風光明媚_FULL-GLOW-BABY_透過.png'
$unitBitmap.Save($unitPath, [System.Drawing.Imaging.ImageFormat]::Png)
$unitBitmap.Dispose()

# 2. Song title logo.
$canvas = New-Canvas 2400 1050
$titleBitmap = $canvas[0]
$titleGraphics = $canvas[1]

$topRect = [System.Drawing.RectangleF]::new(120, 80, 2160, 320)
$topPath = New-TextPath '真剣に愛してる！' 'Noto Serif JP Black' ([System.Drawing.FontStyle]::Bold) 205 $topRect
Draw-OutlinedGradientText $titleGraphics $topPath `
    ([System.Drawing.Color]::FromArgb(36, 48, 82)) `
    ([System.Drawing.Color]::FromArgb(10, 14, 34)) `
    ([System.Drawing.Color]::White) 13 `
    ([System.Drawing.Color]::FromArgb(165, 0, 0, 0)) 15 18

$bottomRect = [System.Drawing.RectangleF]::new(80, 350, 2240, 540)
$bottomPath = New-TextPath '― マジLoveィ ―' 'Noto Sans JP Black' ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic) 250 $bottomRect
Draw-OutlinedGradientText $titleGraphics $bottomPath `
    ([System.Drawing.Color]::FromArgb(255, 63, 77)) `
    ([System.Drawing.Color]::FromArgb(187, 0, 72)) `
    ([System.Drawing.Color]::White) 20 `
    ([System.Drawing.Color]::FromArgb(190, 18, 6, 35)) 22 28

$underlinePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(230, 255, 67, 95), 18)
$underlinePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$underlinePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$titleGraphics.DrawLine($underlinePen, 630, 900, 1780, 900)
$underlinePen.Dispose()
$topPath.Dispose()
$bottomPath.Dispose()
$titleGraphics.Dispose()
$titlePath = Join-Path $outputDir '02_曲名ロゴ_真剣に愛してる_マジLoveィ_透過.png'
$titleBitmap.Save($titlePath, [System.Drawing.Imaging.ImageFormat]::Png)
$titleBitmap.Dispose()

Get-ChildItem -LiteralPath $outputDir -Filter '*.png' | Select-Object FullName, Length
