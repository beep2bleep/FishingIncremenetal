$ErrorActionPreference = 'Stop'
$railwayRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$railwayEngine = Join-Path $railwayRoot 'Godot/Godot_v4.6-stable_win64_console.exe'
Push-Location $railwayRoot
try {
    & python tools/railway_steam/prepare_exports.py
    if ($LASTEXITCODE -ne 0) { throw 'Steam export preparation failed.' }
    foreach ($railwayEdition in @('Full', 'Demo')) {
        $railwayLog = Join-Path $PSScriptRoot ('export_' + $railwayEdition + '.log')
        & $railwayEngine --headless --path FeedingABlackHoldGame --export-release "Railway Fury Steam $railwayEdition" *> $railwayLog
        if ($LASTEXITCODE -ne 0) { throw "Export failed for $railwayEdition. See $railwayLog" }
    }
    & (Join-Path $PSScriptRoot 'verify.ps1')
} finally { Pop-Location }
