Add-Type -AssemblyName System.Drawing

$OutDir = Join-Path $PSScriptRoot 'CombatSprites'
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$NormalFrameW = 24
$NormalFrameH = 24
$BossFrameW = 48
$BossFrameH = 48
$Frames = 3

function C([int]$r,[int]$g,[int]$b,[int]$a=255){ [System.Drawing.Color]::FromArgb($a,$r,$g,$b) }

function Set-Pixel($bmp, [int]$x, [int]$y, $color) {
  if ($x -ge 0 -and $y -ge 0 -and $x -lt $bmp.Width -and $y -lt $bmp.Height) { $bmp.SetPixel($x, $y, $color) }
}

function PRect($bmp, [int]$x, [int]$y, [int]$w, [int]$h, $color) {
  for ($py = $y; $py -lt ($y + $h); $py++) {
    for ($px = $x; $px -lt ($x + $w); $px++) { Set-Pixel $bmp $px $py $color }
  }
}

function HLine($bmp, [int]$x, [int]$y, [int]$len, $color) {
  for ($i = 0; $i -lt $len; $i++) { Set-Pixel $bmp ($x + $i) $y $color }
}

function VLine($bmp, [int]$x, [int]$y, [int]$len, $color) {
  for ($i = 0; $i -lt $len; $i++) { Set-Pixel $bmp $x ($y + $i) $color }
}

function Draw-HeroBase($bmp, [int]$ox, $p, [int]$pose) {
  $ol = $p.outline; $body = $p.main; $trim = $p.trim; $skin = $p.skin

  # head + face
  PRect $bmp ($ox+9) 3 6 1 $ol
  PRect $bmp ($ox+8) 4 8 1 $ol
  PRect $bmp ($ox+8) 5 1 4 $ol
  PRect $bmp ($ox+15) 5 1 4 $ol
  PRect $bmp ($ox+9) 8 6 1 $ol
  PRect $bmp ($ox+9) 5 6 3 $skin
  PRect $bmp ($ox+13) 6 1 1 $ol

  # torso + shoulders
  PRect $bmp ($ox+8) 9 9 1 $ol
  PRect $bmp ($ox+8) 10 1 6 $ol
  PRect $bmp ($ox+16) 10 1 6 $ol
  PRect $bmp ($ox+9) 10 7 6 $body
  PRect $bmp ($ox+10) 11 5 1 $trim

  # back arm
  PRect $bmp ($ox+7) 11 1 4 $ol
  PRect $bmp ($ox+6) 12 1 2 $ol

  # front arm
  PRect $bmp ($ox+17) 11 1 4 $ol
  PRect $bmp ($ox+18) 12 1 2 $ol

  # belt
  PRect $bmp ($ox+9) 16 7 1 $ol
  PRect $bmp ($ox+10) 16 5 1 $trim

  # legs walk
  if ($pose -eq 0) {
    PRect $bmp ($ox+10) 17 2 5 $ol
    PRect $bmp ($ox+13) 18 2 4 $ol
  } else {
    PRect $bmp ($ox+10) 18 2 4 $ol
    PRect $bmp ($ox+13) 17 2 5 $ol
  }
  PRect $bmp ($ox+10) 21 2 1 $trim
  PRect $bmp ($ox+13) 21 2 1 $trim
}

function Draw-HeroWeapon($bmp, [int]$ox, $p, [string]$weapon, [switch]$Attack) {
  $ol = $p.outline; $trim = $p.trim

  if ($weapon -eq 'sword') {
    if ($Attack) {
      HLine $bmp ($ox+18) 10 5 $ol
      HLine $bmp ($ox+19) 9 4 $trim
      PRect $bmp ($ox+17) 10 1 2 $trim
    } else {
      HLine $bmp ($ox+18) 12 4 $ol
      HLine $bmp ($ox+19) 11 3 $trim
    }
  }
  elseif ($weapon -eq 'bow') {
    if ($Attack) {
      VLine $bmp ($ox+20) 8 8 $trim
      VLine $bmp ($ox+19) 8 8 $ol
      HLine $bmp ($ox+14) 12 6 $ol
      Set-Pixel $bmp ($ox+21) 10 $ol
      Set-Pixel $bmp ($ox+21) 14 $ol
    } else {
      VLine $bmp ($ox+19) 9 7 $trim
      VLine $bmp ($ox+18) 9 7 $ol
    }
  }
  elseif ($weapon -eq 'shield') {
    if ($Attack) {
      PRect $bmp ($ox+17) 9 5 7 $trim
      PRect $bmp ($ox+18) 10 3 5 $ol
    } else {
      PRect $bmp ($ox+17) 10 4 6 $trim
      PRect $bmp ($ox+18) 11 2 4 $ol
    }
  }
  elseif ($weapon -eq 'staff') {
    if ($Attack) {
      VLine $bmp ($ox+19) 6 11 $ol
      PRect $bmp ($ox+17) 4 4 3 $trim
      PRect $bmp ($ox+18) 5 2 1 $ol
    } else {
      VLine $bmp ($ox+18) 8 9 $ol
      PRect $bmp ($ox+17) 7 3 2 $trim
    }
  }
}

function Draw-Hero($bmp, [int]$ox, $palette, [int]$pose, [switch]$Attack, [string]$Weapon) {
  Draw-HeroBase $bmp $ox $palette $pose

  if ($Attack) {
    PRect $bmp ($ox+17) 10 2 1 $palette.outline
    PRect $bmp ($ox+18) 9 1 1 $palette.outline
  }

  Draw-HeroWeapon -bmp $bmp -ox $ox -p $palette -weapon $Weapon -Attack:$Attack
}

function Draw-Goblin($bmp, [int]$ox, $p, [int]$pose, [switch]$Attack) {
  $ol = $p.outline; $main = $p.main; $trim = $p.trim

  PRect $bmp ($ox+8) 7 7 1 $ol
  PRect $bmp ($ox+7) 8 9 1 $ol
  PRect $bmp ($ox+7) 9 1 4 $ol
  PRect $bmp ($ox+15) 9 1 4 $ol
  PRect $bmp ($ox+8) 13 7 1 $ol
  PRect $bmp ($ox+8) 9 7 4 $main
  Set-Pixel $bmp ($ox+8) 7 $trim
  Set-Pixel $bmp ($ox+14) 7 $trim

  PRect $bmp ($ox+8) 14 7 4 $main
  PRect $bmp ($ox+8) 18 7 1 $ol

  if ($pose -eq 0) {
    PRect $bmp ($ox+9) 19 2 3 $ol
    PRect $bmp ($ox+12) 20 2 2 $ol
  } else {
    PRect $bmp ($ox+9) 20 2 2 $ol
    PRect $bmp ($ox+12) 19 2 3 $ol
  }

  if ($Attack) {
    HLine $bmp ($ox+16) 12 4 $ol
    HLine $bmp ($ox+17) 11 3 $trim
  } else {
    HLine $bmp ($ox+15) 13 3 $ol
  }
}

function Draw-Brute($bmp, [int]$ox, $p, [int]$pose, [switch]$Attack) {
  $ol = $p.outline; $main = $p.main; $trim = $p.trim

  PRect $bmp ($ox+6) 6 12 1 $ol
  PRect $bmp ($ox+5) 7 14 1 $ol
  PRect $bmp ($ox+5) 8 1 10 $ol
  PRect $bmp ($ox+18) 8 1 10 $ol
  PRect $bmp ($ox+6) 18 12 1 $ol
  PRect $bmp ($ox+6) 8 12 10 $main

  PRect $bmp ($ox+8) 4 8 3 $ol
  PRect $bmp ($ox+9) 5 6 2 $trim

  if ($pose -eq 0) {
    PRect $bmp ($ox+8) 19 3 3 $ol
    PRect $bmp ($ox+13) 20 3 2 $ol
  } else {
    PRect $bmp ($ox+8) 20 3 2 $ol
    PRect $bmp ($ox+13) 19 3 3 $ol
  }

  if ($Attack) {
    VLine $bmp ($ox+20) 8 7 $ol
    PRect $bmp ($ox+19) 6 3 3 $trim
  } else {
    VLine $bmp ($ox+19) 10 6 $ol
  }
}

function Draw-Flyer($bmp, [int]$ox, $p, [int]$pose, [switch]$Attack) {
  $ol = $p.outline; $main = $p.main; $trim = $p.trim

  PRect $bmp ($ox+9) 10 6 1 $ol
  PRect $bmp ($ox+8) 11 8 1 $ol
  PRect $bmp ($ox+8) 12 1 4 $ol
  PRect $bmp ($ox+15) 12 1 4 $ol
  PRect $bmp ($ox+9) 16 6 1 $ol
  PRect $bmp ($ox+9) 12 6 4 $main

  if ($pose -eq 0) {
    PRect $bmp ($ox+3) 10 5 3 $trim
    PRect $bmp ($ox+15) 9 6 4 $trim
  } else {
    PRect $bmp ($ox+2) 12 6 2 $trim
    PRect $bmp ($ox+16) 12 6 2 $trim
  }

  if ($Attack) {
    HLine $bmp ($ox+16) 13 5 $ol
    Set-Pixel $bmp ($ox+21) 13 $trim
  }
}

function Draw-Boss($bmp, [int]$ox, $p, [int]$pose, [switch]$Attack) {
  $ol = $p.outline; $main = $p.main; $trim = $p.trim

  PRect $bmp ($ox+10) 10 24 1 $ol
  PRect $bmp ($ox+9) 11 26 1 $ol
  PRect $bmp ($ox+8) 12 1 24 $ol
  PRect $bmp ($ox+35) 12 1 24 $ol
  PRect $bmp ($ox+9) 35 26 1 $ol
  PRect $bmp ($ox+9) 12 26 24 $main

  PRect $bmp ($ox+14) 4 16 5 $ol
  PRect $bmp ($ox+15) 5 14 4 $main
  PRect $bmp ($ox+12) 4 2 3 $trim
  PRect $bmp ($ox+30) 4 2 3 $trim

  PRect $bmp ($ox+18) 8 2 1 $trim
  PRect $bmp ($ox+24) 8 2 1 $trim

  if ($pose -eq 0) {
    PRect $bmp ($ox+14) 36 6 9 $ol
    PRect $bmp ($ox+24) 38 6 7 $ol
  } else {
    PRect $bmp ($ox+14) 38 6 7 $ol
    PRect $bmp ($ox+24) 36 6 9 $ol
  }

  if ($Attack) {
    PRect $bmp ($ox+34) 18 8 4 $ol
    PRect $bmp ($ox+40) 15 6 10 $trim
    PRect $bmp ($ox+42) 16 2 8 $ol
  } else {
    PRect $bmp ($ox+34) 20 6 4 $ol
  }
}

function New-Sheet([int]$frameW, [int]$frameH) {
  $bmp = New-Object System.Drawing.Bitmap ($frameW * $Frames), $frameH, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $clear = [System.Drawing.Color]::FromArgb(0,0,0,0)
  for ($y=0; $y -lt $bmp.Height; $y++) { for ($x=0; $x -lt $bmp.Width; $x++) { $bmp.SetPixel($x,$y,$clear) } }
  return $bmp
}

$units = @(
  @{ key='hero_knight'; type='hero'; weapon='sword'; palette=@{ outline=(C 28 34 52); main=(C 96 126 174); trim=(C 236 218 118); skin=(C 229 189 148) } },
  @{ key='hero_archer'; type='hero'; weapon='bow'; palette=@{ outline=(C 24 40 30); main=(C 86 146 82); trim=(C 180 126 76); skin=(C 225 186 142) } },
  @{ key='hero_guardian'; type='hero'; weapon='shield'; palette=@{ outline=(C 24 30 42); main=(C 88 112 140); trim=(C 206 174 98); skin=(C 216 176 136) } },
  @{ key='hero_mage'; type='hero'; weapon='staff'; palette=@{ outline=(C 34 18 50); main=(C 110 80 166); trim=(C 118 220 248); skin=(C 229 183 145) } },
  @{ key='enemy_goblin'; type='enemy'; enemy='goblin'; palette=@{ outline=(C 20 40 22); main=(C 78 154 72); trim=(C 192 78 72) } },
  @{ key='enemy_brute'; type='enemy'; enemy='brute'; palette=@{ outline=(C 46 18 18); main=(C 148 74 72); trim=(C 220 174 116) } },
  @{ key='enemy_flyer'; type='enemy'; enemy='flyer'; palette=@{ outline=(C 26 22 48); main=(C 94 88 170); trim=(C 154 142 226) } },
  @{ key='enemy_boss'; type='boss'; enemy='boss'; palette=@{ outline=(C 36 14 18); main=(C 124 46 54); trim=(C 248 114 74) } }
)

foreach ($u in $units) {
  $frameW = if ($u.type -eq 'boss') { $BossFrameW } else { $NormalFrameW }
  $frameH = if ($u.type -eq 'boss') { $BossFrameH } else { $NormalFrameH }
  $bmp = New-Sheet $frameW $frameH

  for ($f=0; $f -lt $Frames; $f++) {
    $ox = $f * $frameW
    $isAtk = ($f -eq 2)

    if ($u.type -eq 'hero') {
      Draw-Hero -bmp $bmp -ox $ox -palette $u.palette -pose ($f % 2) -Attack:$isAtk -Weapon $u.weapon
    }
    elseif ($u.type -eq 'enemy') {
      if ($u.enemy -eq 'goblin') { Draw-Goblin -bmp $bmp -ox $ox -p $u.palette -pose ($f % 2) -Attack:$isAtk }
      elseif ($u.enemy -eq 'brute') { Draw-Brute -bmp $bmp -ox $ox -p $u.palette -pose ($f % 2) -Attack:$isAtk }
      elseif ($u.enemy -eq 'flyer') { Draw-Flyer -bmp $bmp -ox $ox -p $u.palette -pose ($f % 2) -Attack:$isAtk }
    }
    else {
      Draw-Boss -bmp $bmp -ox $ox -p $u.palette -pose ($f % 2) -Attack:$isAtk
    }
  }

  $outFile = Join-Path $OutDir ($u.key + '.png')
  $bmp.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

$readme = @'
# Combat Sprite Set (NES/SNES Chunky Style)

- Normal frame size: 24x24 pixels
- Boss frame size: 48x48 pixels (2x in X/Y)
- Layout: 3 horizontal frames per sprite sheet
- Frame order: `walk_1`, `walk_2`, `attack`
- Transparent background

## Included
- `hero_knight.png` (24x24)
- `hero_archer.png` (24x24)
- `hero_guardian.png` (24x24)
- `hero_mage.png` (24x24)
- `enemy_goblin.png` (24x24)
- `enemy_brute.png` (24x24)
- `enemy_flyer.png` (24x24)
- `enemy_boss.png` (48x48)

Notes:
- Heroes are right-facing with identifiable weapons.
- Enemy silhouettes match the same pixel-art language.
'@
Set-Content -Path (Join-Path $OutDir 'README.md') -Value $readme

Write-Host "Generated sprites in $OutDir"
