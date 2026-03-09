$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outPath = Join-Path $PSScriptRoot "650x500 cap.png"
$screenshotPath = Join-Path $PSScriptRoot "Screenshot 2026-03-06 220538.png"
$combatArt = Join-Path $root "FeedingABlackHoldGame\Art\CombatSprites"

function New-ArgbColor([int]$a, [int]$r, [int]$g, [int]$b) {
    return [System.Drawing.Color]::FromArgb($a, $r, $g, $b)
}

function Get-FrameBitmap {
    param(
        [string]$Path,
        [int]$FrameWidth,
        [int]$FrameHeight,
        [int]$FrameIndex
    )
    $sheet = [System.Drawing.Bitmap]::FromFile($Path)
    $srcRect = [System.Drawing.Rectangle]::new($FrameIndex * $FrameWidth, 0, $FrameWidth, $FrameHeight)
    $frame = [System.Drawing.Bitmap]::new($FrameWidth, $FrameHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($frame)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $g.DrawImage($sheet, [System.Drawing.Rectangle]::new(0, 0, $FrameWidth, $FrameHeight), $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $sheet.Dispose()
    return $frame
}

function Draw-ImageAlpha {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.Image]$Image,
        [System.Drawing.Rectangle]$DestRect,
        [float]$Opacity = 1.0,
        [switch]$FlipX
    )
    $attrs = [System.Drawing.Imaging.ImageAttributes]::new()
    $matrix = [System.Drawing.Imaging.ColorMatrix]::new()
    $matrix.Matrix00 = 1.0
    $matrix.Matrix11 = 1.0
    $matrix.Matrix22 = 1.0
    $matrix.Matrix33 = $Opacity
    $matrix.Matrix44 = 1.0
    $attrs.SetColorMatrix($matrix)
    if ($FlipX) {
        $Graphics.TranslateTransform($DestRect.X + $DestRect.Width, $DestRect.Y)
        $Graphics.ScaleTransform(-1, 1)
        $Graphics.DrawImage($Image, [System.Drawing.Rectangle]::new(0, 0, $DestRect.Width, $DestRect.Height), 0, 0, $Image.Width, $Image.Height, [System.Drawing.GraphicsUnit]::Pixel, $attrs)
        $Graphics.ResetTransform()
    } else {
        $Graphics.DrawImage($Image, $DestRect, 0, 0, $Image.Width, $Image.Height, [System.Drawing.GraphicsUnit]::Pixel, $attrs)
    }
    $attrs.Dispose()
}

function Draw-EllipseGlow {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.Rectangle]$Rect,
        [System.Drawing.Color]$Color
    )
    $brush = [System.Drawing.Drawing2D.PathGradientBrush]::new([System.Drawing.Drawing2D.GraphicsPath]::new())
}

$width = 650
$height = 500
$canvas = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($canvas)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear((New-ArgbColor 255 6 12 24))

$bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Rectangle]::new(0, 0, $width, $height),
    (New-ArgbColor 255 9 16 38),
    (New-ArgbColor 255 6 48 42),
    90.0
)
$g.FillRectangle($bgBrush, 0, 0, $width, $height)
$bgBrush.Dispose()

$haloBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Rectangle]::new(360, -40, 240, 220),
    (New-ArgbColor 120 255 230 140),
    (New-ArgbColor 0 255 230 140),
    90.0
)
$g.FillEllipse($haloBrush, 360, -50, 250, 220)
$haloBrush.Dispose()

$leftGlow = [System.Drawing.SolidBrush]::new((New-ArgbColor 60 60 190 255))
$rightGlow = [System.Drawing.SolidBrush]::new((New-ArgbColor 70 255 96 64))
$g.FillEllipse($leftGlow, 20, 170, 300, 220)
$g.FillEllipse($rightGlow, 360, 150, 250, 220)
$leftGlow.Dispose()
$rightGlow.Dispose()

$screenshot = [System.Drawing.Bitmap]::FromFile($screenshotPath)
$sceneAttrs = [System.Drawing.Imaging.ImageAttributes]::new()
$sceneMatrix = [System.Drawing.Imaging.ColorMatrix]::new()
$sceneMatrix.Matrix00 = 0.92
$sceneMatrix.Matrix11 = 0.98
$sceneMatrix.Matrix22 = 1.05
$sceneMatrix.Matrix33 = 0.28
$sceneMatrix.Matrix44 = 1.0
$sceneAttrs.SetColorMatrix($sceneMatrix)
$sceneSrc = [System.Drawing.Rectangle]::new(110, 145, 1080, 560)
$sceneDst = [System.Drawing.Rectangle]::new(0, 35, $width, 390)
$g.DrawImage($screenshot, $sceneDst, $sceneSrc.X, $sceneSrc.Y, $sceneSrc.Width, $sceneSrc.Height, [System.Drawing.GraphicsUnit]::Pixel, $sceneAttrs)
$sceneAttrs.Dispose()

$groundAttrs = [System.Drawing.Imaging.ImageAttributes]::new()
$groundMatrix = [System.Drawing.Imaging.ColorMatrix]::new()
$groundMatrix.Matrix00 = 0.92
$groundMatrix.Matrix11 = 0.95
$groundMatrix.Matrix22 = 0.95
$groundMatrix.Matrix33 = 0.90
$groundMatrix.Matrix44 = 1.0
$groundAttrs.SetColorMatrix($groundMatrix)
$groundSrc = [System.Drawing.Rectangle]::new(0, 470, $screenshot.Width, 298)
$groundDst = [System.Drawing.Rectangle]::new(0, 300, $width, 200)
$g.DrawImage($screenshot, $groundDst, $groundSrc.X, $groundSrc.Y, $groundSrc.Width, $groundSrc.Height, [System.Drawing.GraphicsUnit]::Pixel, $groundAttrs)
$groundAttrs.Dispose()
$screenshot.Dispose()

$uiMaskTop = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Rectangle]::new(0, 0, $width, 210),
    (New-ArgbColor 250 5 10 22),
    (New-ArgbColor 60 5 10 22),
    90.0
)
$g.FillRectangle($uiMaskTop, 0, 0, $width, 210)
$uiMaskTop.Dispose()

$uiMaskLeft = [System.Drawing.SolidBrush]::new((New-ArgbColor 165 6 12 24))
$uiMaskRight = [System.Drawing.SolidBrush]::new((New-ArgbColor 150 6 12 24))
$g.FillRectangle($uiMaskLeft, 0, 0, 190, 250)
$g.FillRectangle($uiMaskRight, 470, 0, 180, 170)
$uiMaskLeft.Dispose()
$uiMaskRight.Dispose()

$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

$heroMage = Get-FrameBitmap -Path (Join-Path $combatArt "hero_mage.png") -FrameWidth 24 -FrameHeight 24 -FrameIndex 2
$heroKnight = Get-FrameBitmap -Path (Join-Path $combatArt "hero_knight.png") -FrameWidth 24 -FrameHeight 24 -FrameIndex 1
$heroGuardian = Get-FrameBitmap -Path (Join-Path $combatArt "hero_guardian.png") -FrameWidth 24 -FrameHeight 24 -FrameIndex 1
$heroArcher = Get-FrameBitmap -Path (Join-Path $combatArt "hero_archer.png") -FrameWidth 24 -FrameHeight 24 -FrameIndex 2
$enemyGoblin = Get-FrameBitmap -Path (Join-Path $combatArt "enemy_goblin.png") -FrameWidth 24 -FrameHeight 24 -FrameIndex 2
$enemyBrute = Get-FrameBitmap -Path (Join-Path $combatArt "enemy_brute.png") -FrameWidth 24 -FrameHeight 24 -FrameIndex 2
$enemyFlyer = Get-FrameBitmap -Path (Join-Path $combatArt "enemy_flyer.png") -FrameWidth 24 -FrameHeight 24 -FrameIndex 2

$shadowBrush = [System.Drawing.SolidBrush]::new((New-ArgbColor 90 0 0 0))
foreach ($shadow in @(
    [System.Drawing.Rectangle]::new(52, 382, 86, 18),
    [System.Drawing.Rectangle]::new(118, 382, 94, 18),
    [System.Drawing.Rectangle]::new(186, 382, 104, 20),
    [System.Drawing.Rectangle]::new(250, 382, 98, 20),
    [System.Drawing.Rectangle]::new(408, 384, 86, 18),
    [System.Drawing.Rectangle]::new(482, 384, 96, 20),
    [System.Drawing.Rectangle]::new(544, 382, 92, 18),
    [System.Drawing.Rectangle]::new(398, 312, 78, 14)
)) {
    $g.FillEllipse($shadowBrush, $shadow)
}
$shadowBrush.Dispose()

Draw-ImageAlpha $g $heroMage ([System.Drawing.Rectangle]::new(38, 240, 96, 96)) 1.0
Draw-ImageAlpha $g $heroKnight ([System.Drawing.Rectangle]::new(102, 224, 114, 114)) 1.0
Draw-ImageAlpha $g $heroGuardian ([System.Drawing.Rectangle]::new(168, 228, 120, 120)) 1.0
Draw-ImageAlpha $g $heroArcher ([System.Drawing.Rectangle]::new(242, 212, 114, 114)) 1.0

Draw-ImageAlpha $g $enemyFlyer ([System.Drawing.Rectangle]::new(408, 170, 86, 86)) 1.0 -FlipX
Draw-ImageAlpha $g $enemyGoblin ([System.Drawing.Rectangle]::new(410, 236, 102, 102)) 1.0 -FlipX
Draw-ImageAlpha $g $enemyBrute ([System.Drawing.Rectangle]::new(500, 228, 116, 116)) 1.0 -FlipX
Draw-ImageAlpha $g $enemyGoblin ([System.Drawing.Rectangle]::new(554, 262, 84, 84)) 0.95 -FlipX

$slashPen = [System.Drawing.Pen]::new((New-ArgbColor 220 255 246 232), 8)
$slashPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$slashPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($slashPen, 286, 255, 432, 236)
$slashPen.Color = (New-ArgbColor 190 143 213 255)
$slashPen.Width = 6
$g.DrawLine($slashPen, 90, 240, 420, 204)
$slashPen.Color = (New-ArgbColor 210 255 201 105)
$slashPen.Width = 5
$g.DrawLine($slashPen, 290, 250, 536, 288)
$slashPen.Dispose()

$sparkBrushA = [System.Drawing.SolidBrush]::new((New-ArgbColor 210 255 255 255))
$sparkBrushB = [System.Drawing.SolidBrush]::new((New-ArgbColor 180 255 180 72))
$sparkBrushC = [System.Drawing.SolidBrush]::new((New-ArgbColor 170 162 244 255))
foreach ($spark in @(
    @{ Brush = $sparkBrushA; Rect = [System.Drawing.Rectangle]::new(420, 226, 8, 8) },
    @{ Brush = $sparkBrushA; Rect = [System.Drawing.Rectangle]::new(436, 232, 6, 6) },
    @{ Brush = $sparkBrushB; Rect = [System.Drawing.Rectangle]::new(530, 285, 8, 8) },
    @{ Brush = $sparkBrushB; Rect = [System.Drawing.Rectangle]::new(545, 276, 6, 6) },
    @{ Brush = $sparkBrushC; Rect = [System.Drawing.Rectangle]::new(400, 200, 8, 8) },
    @{ Brush = $sparkBrushC; Rect = [System.Drawing.Rectangle]::new(388, 214, 5, 5) }
)) {
    $g.FillEllipse($spark.Brush, $spark.Rect)
}
$sparkBrushA.Dispose()
$sparkBrushB.Dispose()
$sparkBrushC.Dispose()

$barBackBrush = [System.Drawing.SolidBrush]::new((New-ArgbColor 180 20 28 36))
$barFillBrush = [System.Drawing.SolidBrush]::new((New-ArgbColor 230 240 72 72))
$g.FillRectangle($barBackBrush, 424, 140, 74, 8)
$g.FillRectangle($barBackBrush, 512, 156, 86, 8)
$g.FillRectangle($barFillBrush, 426, 141, 58, 6)
$g.FillRectangle($barFillBrush, 514, 157, 44, 6)
$barBackBrush.Dispose()
$barFillBrush.Dispose()

$vignetteTop = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Rectangle]::new(0, 0, $width, 120),
    (New-ArgbColor 170 0 0 0),
    (New-ArgbColor 0 0 0 0),
    90.0
)
$g.FillRectangle($vignetteTop, 0, 0, $width, 120)
$vignetteTop.Dispose()

$vignetteSides = [System.Drawing.SolidBrush]::new((New-ArgbColor 55 0 0 0))
$g.FillRectangle($vignetteSides, 0, 0, 26, $height)
$g.FillRectangle($vignetteSides, $width - 26, 0, 26, $height)
$vignetteSides.Dispose()

foreach ($bmp in @($heroMage, $heroKnight, $heroGuardian, $heroArcher, $enemyGoblin, $enemyBrute, $enemyFlyer)) {
    $bmp.Dispose()
}

$g.Dispose()
$canvas.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$canvas.Dispose()
