$ErrorActionPreference = 'Stop'
$railwayRoot = $PSScriptRoot
$railwayGodot = Join-Path $railwayRoot 'Godot\Godot_v4.6-stable_win64.exe'
$railwayProject = Join-Path $railwayRoot 'FeedingABlackHoldGame'
Start-Process -FilePath $railwayGodot -ArgumentList '--path', ('"' + $railwayProject + '"') -WindowStyle Hidden
