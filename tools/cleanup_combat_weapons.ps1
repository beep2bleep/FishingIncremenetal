Add-Type -AssemblyName System.Drawing

function Get-ColorDistanceSq {
    param(
        [System.Drawing.Color]$A,
        [System.Drawing.Color]$B
    )

    $dr = [int]$A.R - [int]$B.R
    $dg = [int]$A.G - [int]$B.G
    $db = [int]$A.B - [int]$B.B
    return ($dr * $dr) + ($dg * $dg) + ($db * $db)
}

function Get-ColorKey {
    param([System.Drawing.Color]$Color)

    return '{0},{1},{2},{3}' -f $Color.A, $Color.R, $Color.G, $Color.B
}

function Test-LikelyBackground {
    param(
        [System.Drawing.Color]$Color,
        [hashtable]$BorderColorSet
    )

    if ($Color.A -lt 8) {
        return $true
    }

    return $BorderColorSet.ContainsKey((Get-ColorKey -Color $Color))
}

function Get-NeighborIndices {
    param(
        [int]$Index,
        [int]$Width,
        [int]$Height
    )

    $x = $Index % $Width
    $y = [Math]::Floor($Index / $Width)
    $neighbors = New-Object System.Collections.Generic.List[int]

    if ($x -gt 0) { $neighbors.Add($Index - 1) }
    if ($x + 1 -lt $Width) { $neighbors.Add($Index + 1) }
    if ($y -gt 0) { $neighbors.Add($Index - $Width) }
    if ($y + 1 -lt $Height) { $neighbors.Add($Index + $Width) }

    return $neighbors
}

function Test-TouchesBackground {
    param(
        [bool[]]$Background,
        [int]$Index,
        [int]$Width,
        [int]$Height
    )

    foreach ($neighbor in Get-NeighborIndices -Index $Index -Width $Width -Height $Height) {
        if ($Background[$neighbor]) {
            return $true
        }
    }

    return $false
}

function Get-InteriorAverageColor {
    param(
        [System.Drawing.Color[]]$Colors,
        [bool[]]$Background,
        [int]$Index,
        [int]$Width,
        [int]$Height
    )

    $x = $Index % $Width
    $y = [Math]::Floor($Index / $Width)
    $sumR = 0
    $sumG = 0
    $sumB = 0
    $count = 0

    for ($dy = -2; $dy -le 2; $dy++) {
        for ($dx = -2; $dx -le 2; $dx++) {
            if ($dx -eq 0 -and $dy -eq 0) {
                continue
            }

            $nx = $x + $dx
            $ny = $y + $dy
            if ($nx -lt 0 -or $ny -lt 0 -or $nx -ge $Width -or $ny -ge $Height) {
                continue
            }

            $neighborIndex = ($ny * $Width) + $nx
            if ($Background[$neighborIndex]) {
                continue
            }

            if (Test-TouchesBackground -Background $Background -Index $neighborIndex -Width $Width -Height $Height) {
                continue
            }

            $c = $Colors[$neighborIndex]
            $sumR += $c.R
            $sumG += $c.G
            $sumB += $c.B
            $count++
        }
    }

    if ($count -eq 0) {
        return $null
    }

    return [System.Drawing.Color]::FromArgb(
        255,
        [int][Math]::Round($sumR / $count),
        [int][Math]::Round($sumG / $count),
        [int][Math]::Round($sumB / $count)
    )
}

function Cleanup-WeaponImage {
    param([string]$Path)

    $source = [System.Drawing.Bitmap]::FromFile($Path)
    $bmp = New-Object System.Drawing.Bitmap($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.DrawImage($source, 0, 0, $source.Width, $source.Height)
    $graphics.Dispose()
    $source.Dispose()

    $width = $bmp.Width
    $height = $bmp.Height
    $size = $width * $height

    $colors = New-Object 'System.Drawing.Color[]' $size
    $background = New-Object 'System.Boolean[]' $size
    $queue = New-Object 'System.Collections.Generic.Queue[int]'
    $borderColorSet = @{}

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $index = ($y * $width) + $x
            $colors[$index] = $bmp.GetPixel($x, $y)
        }
    }

    for ($x = 0; $x -lt $width; $x++) {
        foreach ($y in @([int]0, [int]($height - 1))) {
            $index = ($y * $width) + $x
            $borderColorSet[(Get-ColorKey -Color $colors[$index])] = $true
        }
    }

    for ($y = 1; $y -lt ($height - 1); $y++) {
        foreach ($x in @([int]0, [int]($width - 1))) {
            $index = ($y * $width) + $x
            $borderColorSet[(Get-ColorKey -Color $colors[$index])] = $true
        }
    }

    for ($x = 0; $x -lt $width; $x++) {
        foreach ($y in @([int]0, [int]($height - 1))) {
            $index = ($y * $width) + $x
            if (-not $background[$index] -and (Test-LikelyBackground -Color $colors[$index] -BorderColorSet $borderColorSet)) {
                $background[$index] = $true
                $queue.Enqueue($index)
            }
        }
    }

    for ($y = 1; $y -lt ($height - 1); $y++) {
        foreach ($x in @([int]0, [int]($width - 1))) {
            $index = ($y * $width) + $x
            if (-not $background[$index] -and (Test-LikelyBackground -Color $colors[$index] -BorderColorSet $borderColorSet)) {
                $background[$index] = $true
                $queue.Enqueue($index)
            }
        }
    }

    while ($queue.Count -gt 0) {
        $index = $queue.Dequeue()
        foreach ($neighbor in Get-NeighborIndices -Index $index -Width $width -Height $height) {
            if ($background[$neighbor]) {
                continue
            }

            if (Test-LikelyBackground -Color $colors[$neighbor] -BorderColorSet $borderColorSet) {
                $background[$neighbor] = $true
                $queue.Enqueue($neighbor)
            }
        }
    }

    $transparent = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
    for ($index = 0; $index -lt $size; $index++) {
        if ($background[$index]) {
            $colors[$index] = $transparent
        }
    }

    for ($index = 0; $index -lt $size; $index++) {
        if ($background[$index]) {
            continue
        }

        if (-not (Test-TouchesBackground -Background $background -Index $index -Width $width -Height $height)) {
            continue
        }

        $current = $colors[$index]
        $replacement = Get-InteriorAverageColor -Colors $colors -Background $background -Index $index -Width $width -Height $height
        if ($null -eq $replacement) {
            continue
        }

        $max = [Math]::Max($current.R, [Math]::Max($current.G, $current.B))
        $min = [Math]::Min($current.R, [Math]::Min($current.G, $current.B))
        $spread = $max - $min
        $avg = ($current.R + $current.G + $current.B) / 3.0
        $replacementDistance = Get-ColorDistanceSq -A $current -B $replacement

        if ($spread -le 30 -or $avg -ge 220 -or $avg -le 35 -or $replacementDistance -le 2600) {
            $colors[$index] = [System.Drawing.Color]::FromArgb(255, $replacement.R, $replacement.G, $replacement.B)
        }
    }

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $index = ($y * $width) + $x
            $bmp.SetPixel($x, $y, $colors[$index])
        }
    }

    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

$targetDir = Join-Path $PSScriptRoot "..\\FeedingABlackHoldGame\\Art\\CombatWeapons"
Get-ChildItem $targetDir -Filter *.png | ForEach-Object {
    Cleanup-WeaponImage -Path $_.FullName
}
