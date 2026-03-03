Add-Type -AssemblyName System.Drawing

$OutDir = "FeedingABlackHoldGame/Art/CombatSprites"

function New-Bitmap([int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    return $bmp
}

function C([string]$hex) {
    $hex = $hex.TrimStart('#')
    return [System.Drawing.Color]::FromArgb(255, [Convert]::ToInt32($hex.Substring(0,2),16), [Convert]::ToInt32($hex.Substring(2,2),16), [Convert]::ToInt32($hex.Substring(4,2),16))
}

function FillRect($bmp, [int]$x, [int]$y, [int]$w, [int]$h, $color) {
    for ($yy = $y; $yy -lt ($y + $h); $yy++) {
        if ($yy -lt 0 -or $yy -ge $bmp.Height) { continue }
        for ($xx = $x; $xx -lt ($x + $w); $xx++) {
            if ($xx -lt 0 -or $xx -ge $bmp.Width) { continue }
            $bmp.SetPixel($xx, $yy, $color)
        }
    }
}

function Dot($bmp, [int]$x, [int]$y, $color) {
    if ($x -ge 0 -and $x -lt $bmp.Width -and $y -ge 0 -and $y -lt $bmp.Height) {
        $bmp.SetPixel($x, $y, $color)
    }
}

function Draw-Humanoid($bmp, [int]$ox, [int]$step, [bool]$attack, $body, $trim, $face, $outline, [string]$role) {
    $dx = if ($step -lt 0) { -1 } elseif ($step -gt 0) { 1 } else { 0 }

    FillRect $bmp ($ox+7) 5 10 10 $outline
    FillRect $bmp ($ox+8) 6 8 8 $body
    FillRect $bmp ($ox+7) 14 10 6 $outline
    FillRect $bmp ($ox+8) 15 8 4 $body

    FillRect $bmp ($ox+8) 6 8 2 $trim

    FillRect $bmp ($ox+8+$dx) 19 3 4 $outline
    FillRect $bmp ($ox+9+$dx) 20 1 3 $trim
    FillRect $bmp ($ox+13-$dx) 19 3 4 $outline
    FillRect $bmp ($ox+14-$dx) 20 1 3 $trim

    Dot $bmp ($ox+13) 9 $face
    Dot $bmp ($ox+14) 9 $face

    if ($attack) {
        FillRect $bmp ($ox+16) 14 5 2 $outline
        FillRect $bmp ($ox+17) 14 6 1 $trim
    } else {
        FillRect $bmp ($ox+15) 14 3 2 $outline
        FillRect $bmp ($ox+16) 14 2 2 $trim
    }

    switch ($role) {
        'knight' {
            if ($attack) {
                FillRect $bmp ($ox+22) 10 2 7 (C '#d6e2ff')
                Dot $bmp ($ox+21) 16 (C '#c79b4d')
                Dot $bmp ($ox+22) 16 (C '#c79b4d')
            } else {
                FillRect $bmp ($ox+18) 12 2 6 (C '#d6e2ff')
            }
        }
        'archer' {
            FillRect $bmp ($ox+18) 10 1 8 (C '#a86e3a')
            Dot $bmp ($ox+17) 11 (C '#a86e3a')
            Dot $bmp ($ox+17) 16 (C '#a86e3a')
            if ($attack) {
                FillRect $bmp ($ox+19) 13 5 1 (C '#ffe37a')
            }
        }
        'guardian' {
            FillRect $bmp ($ox+4) 12 3 6 (C '#5db6ff')
            FillRect $bmp ($ox+5) 13 1 4 (C '#c8f4ff')
            if ($attack) {
                FillRect $bmp ($ox+16) 12 5 3 (C '#7de0ff')
            }
        }
        'mage' {
            FillRect $bmp ($ox+18) 10 1 9 (C '#92623e')
            FillRect $bmp ($ox+17) 8 3 2 (C '#dd74ff')
            if ($attack) {
                FillRect $bmp ($ox+20) 8 3 3 (C '#79f8ff')
                Dot $bmp ($ox+23) 9 (C '#e5fbff')
            }
        }
    }
}

function Draw-Goblin($bmp, [int]$ox, [int]$step, [bool]$attack) {
    $o = C '#0b1020'; $b = C '#2bc06f'; $a = C '#8ff9c4'; $e = C '#e9ff7a'
    FillRect $bmp ($ox+6) 11 12 8 $o
    FillRect $bmp ($ox+7) 12 10 6 $b
    FillRect $bmp ($ox+9) 10 6 2 $a
    Dot $bmp ($ox+14) 13 $e
    Dot $bmp ($ox+15) 13 $e
    $legShift = if ($step -lt 0) { -1 } elseif ($step -gt 0) { 1 } else { 0 }
    FillRect $bmp ($ox+8+$legShift) 18 3 3 $o
    FillRect $bmp ($ox+13-$legShift) 18 3 3 $o
    if ($attack) {
        FillRect $bmp ($ox+17) 12 6 2 $a
    }
}

function Draw-Brute($bmp, [int]$ox, [int]$step, [bool]$attack) {
    $o = C '#130a1c'; $b = C '#d3446f'; $a = C '#ff9ab7'; $e = C '#ffe579'
    FillRect $bmp ($ox+4) 8 16 12 $o
    FillRect $bmp ($ox+5) 9 14 10 $b
    FillRect $bmp ($ox+7) 10 10 2 $a
    Dot $bmp ($ox+12) 13 $e
    Dot $bmp ($ox+15) 13 $e
    FillRect $bmp ($ox+6) 19 4 3 $o
    FillRect $bmp ($ox+14) 19 4 3 $o
    if ($attack) {
        FillRect $bmp ($ox+18) 12 5 5 $a
        FillRect $bmp ($ox+22) 13 2 3 $e
    }
}

function Draw-Flyer($bmp, [int]$ox, [int]$step, [bool]$attack) {
    $o = C '#0a1320'; $b = C '#ffd34e'; $a = C '#fff2a3'; $w = C '#4f9cff'; $e = C '#ff4f7a'
    $lift = if ($step -lt 0) { -1 } elseif ($step -gt 0) { 1 } else { 0 }
    FillRect $bmp ($ox+9) (12+$lift) 7 6 $o
    FillRect $bmp ($ox+10) (13+$lift) 5 4 $b
    FillRect $bmp ($ox+7) (12-$lift) 2 5 $w
    FillRect $bmp ($ox+16) (12+$lift) 2 5 $w
    Dot $bmp ($ox+13) (14+$lift) $e
    if ($attack) {
        FillRect $bmp ($ox+16) (14+$lift) 6 2 $a
    }
}

function Draw-Boss($bmp, [int]$ox, [int]$step, [bool]$attack) {
    $o = C '#070c19'; $b = C '#4f6bff'; $a = C '#79f7ff'; $c = C '#f6ff8f'; $m = C '#ff5f8a'
    $wiggle = if ($step -lt 0) { -2 } elseif ($step -gt 0) { 2 } else { 0 }

    FillRect $bmp ($ox+6) 14 34 20 $o
    FillRect $bmp ($ox+8) 16 30 16 $b
    for ($sx = 10; $sx -lt 36; $sx += 6) {
        FillRect $bmp ($ox+$sx) 16 1 16 $a
    }

    FillRect $bmp ($ox+30+$wiggle) 19 10 8 $m
    FillRect $bmp ($ox+33+$wiggle) 22 4 2 $c
    FillRect $bmp ($ox+20) 20 4 4 $a
    Dot $bmp ($ox+21) 21 $c

    FillRect $bmp ($ox+12) 12 3 2 $a
    FillRect $bmp ($ox+18) 11 3 3 $a
    FillRect $bmp ($ox+25) 11 3 3 $a

    if ($attack) {
        FillRect $bmp ($ox+39) 19 8 7 $m
        FillRect $bmp ($ox+44) 21 3 3 $c
    }
}

function Make-Sheet([string]$name, [int]$frameW, [int]$frameH, [scriptblock]$drawer) {
    $bmp = New-Bitmap ($frameW * 3) $frameH

    & $drawer $bmp 0 -1 $false
    & $drawer $bmp $frameW 1 $false
    & $drawer $bmp ($frameW * 2) 0 $true

    $path = Join-Path $OutDir $name
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

Make-Sheet 'hero_knight.png' 24 24 { param($bmp,$ox,$step,$attack) Draw-Humanoid $bmp $ox $step $attack (C '#3f9bff') (C '#9be0ff') (C '#efffff') (C '#061323') 'knight' }
Make-Sheet 'hero_archer.png' 24 24 { param($bmp,$ox,$step,$attack) Draw-Humanoid $bmp $ox $step $attack (C '#30bf6d') (C '#8ef7b6') (C '#f4fff4') (C '#051a13') 'archer' }
Make-Sheet 'hero_guardian.png' 24 24 { param($bmp,$ox,$step,$attack) Draw-Humanoid $bmp $ox $step $attack (C '#2d8cff') (C '#9ad2ff') (C '#f1f8ff') (C '#051325') 'guardian' }
Make-Sheet 'hero_mage.png' 24 24 { param($bmp,$ox,$step,$attack) Draw-Humanoid $bmp $ox $step $attack (C '#6f65ff') (C '#b7a8ff') (C '#f7f2ff') (C '#110a24') 'mage' }

Make-Sheet 'enemy_goblin.png' 24 24 { param($bmp,$ox,$step,$attack) Draw-Goblin $bmp $ox $step $attack }
Make-Sheet 'enemy_brute.png' 24 24 { param($bmp,$ox,$step,$attack) Draw-Brute $bmp $ox $step $attack }
Make-Sheet 'enemy_flyer.png' 24 24 { param($bmp,$ox,$step,$attack) Draw-Flyer $bmp $ox $step $attack }
Make-Sheet 'enemy_boss.png' 48 48 { param($bmp,$ox,$step,$attack) Draw-Boss $bmp $ox $step $attack }
