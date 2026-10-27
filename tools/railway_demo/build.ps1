$ErrorActionPreference = 'Stop'
$railwayRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$railwayEngine = Join-Path $railwayRoot 'Godot/Godot_v4.6-stable_win64_console.exe'
Push-Location $railwayRoot
try {
    if (-not (Test-Path -LiteralPath 'FeedingABlackHoldGame/.godot/global_script_class_cache.cfg')) {
        & $railwayEngine --headless --editor --path FeedingABlackHoldGame --import --quit *> (Join-Path $PSScriptRoot 'import.log')
        if ($LASTEXITCODE -ne 0) { throw 'Initial resource import failed.' }
    }
    & python tools/railway_demo/prepare_exports.py
    if ($LASTEXITCODE -ne 0) { throw 'Preparing export presets failed.' }
    foreach ($railwayPlatform in @('Windows', 'Web')) {
        $railwayLog = Join-Path $PSScriptRoot ('export_' + $railwayPlatform.ToLowerInvariant() + '.log')
        & $railwayEngine --headless --path FeedingABlackHoldGame --export-release "Railway Fury Demo $railwayPlatform" *> $railwayLog
        if ($LASTEXITCODE -ne 0) { throw "Export failed: $railwayPlatform. See $railwayLog" }
    }
    & (Join-Path $PSScriptRoot 'verify_pack.ps1')
    & python tools/railway_demo/package.py
    if ($LASTEXITCODE -ne 0) { throw 'Packaging or HTML hosting size validation failed.' }
} finally {
    Pop-Location
}
