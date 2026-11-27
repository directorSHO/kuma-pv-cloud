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
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return @($bmp, $g)
}

function Draw-TintedRegion(
    [System.Drawing.Graphics]$graphics,
    [System.Drawing.Image]$image,
    [System.Drawing.Rectangle]$destination,
    [System.Drawing.Rectangle]$source,
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
        $source.X, $source.Y, $source.Width, $source.Height,
        [System.Drawing.GraphicsUnit]::Pixel,
        $attrs
    )
    $attrs.Dispose()
}

function Draw-TintedImage(
    [System.Drawing.Graphics]$graphics,
    [System.Drawing.Image]$image,
    [System.Drawing.Rectangle]$destination,
    [System.Drawing.Color]$color,
    [float]$opacity
) {
    $source = [System.Drawing.Rectangle]::new(0, 0, $image.Width, $image.Height)
    Draw-TintedRegion $graphics $image $destination $source $color $opacity
}

function Mix-Color([System.Drawing.Color]$a, [System.Drawing.Color]$b, [double]$t) {
    $r = [int]([Math]::Round($a.R + (($b.R - $a.R) * $t)))
    $g = [int]([Math]::Round($a.G + (($b.G - $a.G) * $t)))
    $bl = [int]([Math]::Round($a.B + (($b.B - $a.B) * $t)))
    return [System.Drawing.Color]::FromArgb($r, $g, $bl)
}

function Draw-GradientGlyph(
    [System.Drawing.Graphics]$graphics,
    [System.Drawing.Image]$image,
    [System.Drawing.Rectangle]$rect,
    [System.Drawing.Color]$topColor,
    [System.Drawing.Color]$bottomColor
) {
    $shadowRect = [System.Drawing.Rectangle]::new($rect.X + 15, $rect.Y + 20, $rect.Width, $rect.Height)
    Draw-TintedImage $graphics $image $shadowRect ([System.Drawing.Color]::FromArgb(9, 18, 42)) 0.82

    $outlineColor = [System.Drawing.Color]::FromArgb(245, 248, 255)
    $offsets = @(
        @(-7,0), @(7,0), @(0,-7), @(0,7),
        @(-5,-5), @(5,-5), @(-5,5), @(5,5)
    )
    foreach ($offset in $offsets) {
        $outlineRect = [System.Drawing.Rectangle]::new(
            $rect.X + $offset[0], $rect.Y + $offset[1], $rect.Width, $rect.Height
        )
        Draw-TintedImage $graphics $image $outlineRect $outlineColor 0.96
    }

    $bands = 12
    for ($band = 0; $band -lt $bands; $band++) {
        $sourceY = [int]([Math]::Floor($image.Height * $band / $bands))
        $sourceNextY = [int]([Math]::Floor($image.Height * ($band + 1) / $bands))
        $sourceH = [Math]::Max(1, $sourceNextY - $sourceY)
        $destY = [int]([Math]::Floor($rect.Height * $band / $bands))
        $destNextY = [int]([Math]::Floor($rect.Height * ($band + 1) / $bands))
        $destH = [Math]::Max(1, $destNextY - $destY)
        $color = Mix-Color $topColor $bottomColor (($band + 0.5) / $bands)
        $source = [System.Drawing.Rectangle]::new(0, $sourceY, $image.Width, $sourceH)
        $dest = [System.Drawing.Rectangle]::new($rect.X, $rect.Y + $destY, $rect.Width, $destH)
        Draw-TintedRegion $graphics $image $dest $source $color 1.0
    }

    $highlightRect = [System.Drawing.Rectangle]::new($rect.X - 2, $rect.Y - 4, $rect.Width, $rect.Height)
    Draw-TintedImage $graphics $image $highlightRect ([System.Drawing.Color]::White) 0.14
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

$canvas = New-Canvas 2400 900
$bitmap = $canvas[0]
$graphics = $canvas[1]

$glyphFiles = @(
    '01_風_白筆文字_透過.png',
    '02_光_白筆文字_透過.png',
    '03_明_白筆文字_透過.png',
    '04_媚_白筆文字_透過.png'
)

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

$glyphSize = 515
$glyphGap = 20
$totalWidth = ($glyphSize * 4) + ($glyphGap * 3)
$startX = [int]((2400 - $totalWidth) / 2)
$glyphY = 178

for ($i = 0; $i -lt 4; $i++) {
    $image = [System.Drawing.Image]::FromFile((Join-Path $glyphDir $glyphFiles[$i]))
    $rect = [System.Drawing.Rectangle]::new($startX + ($i * ($glyphSize + $glyphGap)), $glyphY, $glyphSize, $glyphSize)
    Draw-GradientGlyph $graphics $image $rect $topColors[$i] $bottomColors[$i]
    $image.Dispose()
}

# English text shares the exact horizontal and vertical center of the four-kanji group.
$groupCenterX = 1200.0
$groupCenterY = $glyphY + ($glyphSize / 2.0)
$englishWidth = 2100.0
$englishHeight = 300.0
$englishRect = [System.Drawing.RectangleF]::new(
    [float]($groupCenterX - ($englishWidth / 2.0)),
    [float]($groupCenterY - ($englishHeight / 2.0)),
    [float]$englishWidth,
    [float]$englishHeight
)
$englishPath = New-TextPath 'FULL GLOW BABY' 'Bahnschrift SemiBold Condensed' ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic) 186 $englishRect

$shadowPath = $englishPath.Clone()
$shadowMatrix = [System.Drawing.Drawing2D.Matrix]::new()
$shadowMatrix.Translate(16, 18)
$shadowPath.Transform($shadowMatrix)
$shadowPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(210, 4, 12, 34), 27)
$shadowPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$graphics.DrawPath($shadowPen, $shadowPath)
$shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 4, 12, 34))
$graphics.FillPath($shadowBrush, $shadowPath)
$shadowBrush.Dispose()
$shadowPen.Dispose()
$shadowPath.Dispose()
$shadowMatrix.Dispose()

$outlinePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(12, 23, 52), 24)
$outlinePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$graphics.DrawPath($outlinePen, $englishPath)
$outlinePen.Dispose()

$englishBounds = $englishPath.GetBounds()
$englishGradient = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $englishBounds,
    [System.Drawing.Color]::White,
    [System.Drawing.Color]::FromArgb(218, 230, 244),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$graphics.FillPath($englishGradient, $englishPath)
$englishGradient.Dispose()

$innerPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(250, 255, 255, 255), 3)
$innerPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$graphics.DrawPath($innerPen, $englishPath)
$innerPen.Dispose()

$englishPath.Dispose()
$graphics.Dispose()

$outputPath = Join-Path $outputDir '01_ユニットロゴ_V2_風光明媚_FULL-GLOW-BABY_中央重ね_透過.png'
$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()

Write-Output $outputPath
