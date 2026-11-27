Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$workspace = 'C:\Users\自分\Documents\Codex\2026-07-31\new-chat'
$basePath = Join-Path $workspace 'projects\maji-love-i\assets\title-card\クマファミリー_文字なしベース.png'
$logoOutputDir = Join-Path $workspace 'outputs\クマPVロゴ素材'
$posterOutputDir = Join-Path $workspace 'outputs\クマPVタイトルカード'
New-Item -ItemType Directory -Path $logoOutputDir -Force | Out-Null
New-Item -ItemType Directory -Path $posterOutputDir -Force | Out-Null

function New-Canvas([int]$width, [int]$height) {
    $bmp = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
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

function Draw-ShadowedGradientPath(
    [System.Drawing.Graphics]$graphics,
    [System.Drawing.Drawing2D.GraphicsPath]$path,
    [System.Drawing.Color]$topColor,
    [System.Drawing.Color]$bottomColor,
    [float]$outerWidth,
    [float]$innerWidth,
    [float]$shadowX,
    [float]$shadowY
) {
    $shadowPath = $path.Clone()
    $matrix = [System.Drawing.Drawing2D.Matrix]::new()
    $matrix.Translate($shadowX, $shadowY)
    $shadowPath.Transform($matrix)
    $shadowPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(215, 4, 12, 34), $outerWidth)
    $shadowPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $graphics.DrawPath($shadowPen, $shadowPath)
    $shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(205, 4, 12, 34))
    $graphics.FillPath($shadowBrush, $shadowPath)
    $shadowBrush.Dispose()
    $shadowPen.Dispose()
    $shadowPath.Dispose()
    $matrix.Dispose()

    $outerPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(8, 20, 48), $outerWidth)
    $outerPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $graphics.DrawPath($outerPen, $path)
    $outerPen.Dispose()

    if ($innerWidth -gt 0) {
        $innerPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(247, 251, 255), $innerWidth)
        $innerPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $graphics.DrawPath($innerPen, $path)
        $innerPen.Dispose()
    }

    $bounds = $path.GetBounds()
    $gradient = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $bounds,
        $topColor,
        $bottomColor,
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $graphics.FillPath($gradient, $path)
    $gradient.Dispose()
}

# ---------- Unit logo V3 ----------
$logoCanvas = New-Canvas 2400 800
$logoBitmap = $logoCanvas[0]
$logoGraphics = $logoCanvas[1]

$kanji = @('風', '光', '明', '媚')
$topColors = @(
    [System.Drawing.Color]::FromArgb(78, 128, 194),
    [System.Drawing.Color]::FromArgb(255, 139, 178),
    [System.Drawing.Color]::FromArgb(101, 170, 255),
    [System.Drawing.Color]::FromArgb(130, 235, 210)
)
$bottomColors = @(
    [System.Drawing.Color]::FromArgb(15, 43, 87),
    [System.Drawing.Color]::FromArgb(193, 41, 103),
    [System.Drawing.Color]::FromArgb(31, 83, 196),
    [System.Drawing.Color]::FromArgb(33, 161, 138)
)

$charWidth = 525
$gap = 25
$totalWidth = ($charWidth * 4) + ($gap * 3)
$startX = [float]((2400 - $totalWidth) / 2)
for ($i = 0; $i -lt 4; $i++) {
    $rect = [System.Drawing.RectangleF]::new($startX + ($i * ($charWidth + $gap)), 45, $charWidth, 500)
    $path = New-TextPath $kanji[$i] 'Noto Sans JP Black' ([System.Drawing.FontStyle]::Bold) 400 $rect
    Draw-ShadowedGradientPath $logoGraphics $path $topColors[$i] $bottomColors[$i] 27 11 13 17
    $path.Dispose()
}

# The English line is intentionally larger and shifted down while remaining centered horizontally.
$englishRect = [System.Drawing.RectangleF]::new(105, 395, 2190, 315)
$englishPath = New-TextPath 'FULL GLOW BABY' 'Bahnschrift SemiBold Condensed' ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic) 218 $englishRect
Draw-ShadowedGradientPath $logoGraphics $englishPath `
    ([System.Drawing.Color]::White) `
    ([System.Drawing.Color]::FromArgb(213, 226, 242)) `
    31 5 17 20
$englishPath.Dispose()
$logoGraphics.Dispose()

$logoPath = Join-Path $logoOutputDir '01_ユニットロゴ_V3_風光明媚_FULL-GLOW-BABY_硬質中央重ね_透過.png'
$logoBitmap.Save($logoPath, [System.Drawing.Imaging.ImageFormat]::Png)

# ---------- Title-card composite ----------
$baseImage = [System.Drawing.Image]::FromFile($basePath)
$posterBitmap = [System.Drawing.Bitmap]::new($baseImage.Width, $baseImage.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$posterGraphics = [System.Drawing.Graphics]::FromImage($posterBitmap)
$posterGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$posterGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$posterGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$posterGraphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$posterGraphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$posterGraphics.DrawImage($baseImage, 0, 0, $baseImage.Width, $baseImage.Height)

# Replace the old top label with the new unit logo.
$logoDestination = [System.Drawing.Rectangle]::new(266, -35, 1140, 380)
$posterGraphics.DrawImage($logoBitmap, $logoDestination)

# Song title at the bottom, drawn deterministically for exact spelling.
$titleTopRect = [System.Drawing.RectangleF]::new(95, 742, 1482, 112)
$titleTopPath = New-TextPath '真剣に愛してる！' 'Noto Sans JP Black' ([System.Drawing.FontStyle]::Bold) 76 $titleTopRect
Draw-ShadowedGradientPath $posterGraphics $titleTopPath `
    ([System.Drawing.Color]::White) `
    ([System.Drawing.Color]::FromArgb(225, 234, 244)) `
    16 3 8 10
$titleTopPath.Dispose()

$titleBottomRect = [System.Drawing.RectangleF]::new(125, 823, 1422, 112)
$titleBottomPath = New-TextPath '― マジLoveィ ―' 'Noto Sans JP Black' ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic) 82 $titleBottomRect
Draw-ShadowedGradientPath $posterGraphics $titleBottomPath `
    ([System.Drawing.Color]::FromArgb(255, 112, 151)) `
    ([System.Drawing.Color]::FromArgb(203, 39, 97)) `
    17 4 9 11
$titleBottomPath.Dispose()

$posterGraphics.Dispose()
$baseImage.Dispose()
$logoBitmap.Dispose()

$posterPath = Join-Path $posterOutputDir '01_風光明媚_真剣に愛してる_マジLoveィ_タイトルカード.png'
$posterBitmap.Save($posterPath, [System.Drawing.Imaging.ImageFormat]::Png)
$posterBitmap.Dispose()

Write-Output $logoPath
Write-Output $posterPath
