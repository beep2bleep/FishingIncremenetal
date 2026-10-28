$ErrorActionPreference = 'Stop'
$railwayRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$railwayRuntime = Join-Path $PSScriptRoot 'pack_runtime'
$railwaySdk = Join-Path $railwayRoot 'FeedingABlackHoldGame/addons/godotsteam/win64'
$railwayNested = Join-Path $railwayRuntime 'addons/godotsteam/win64'
New-Item -ItemType Directory -Force $railwayNested | Out-Null
if (Get-ChildItem -LiteralPath $railwayRuntime -Recurse -File -Filter '*.gd') { throw 'No source fallback may exist in the probe directory.' }
foreach ($railwayDll in @('libgodotsteam.windows.template_debug.x86_64.dll','libgodotsteam.windows.template_release.x86_64.dll','steam_api64.dll')) {
    Copy-Item -LiteralPath (Join-Path $railwaySdk $railwayDll) -Destination $railwayRuntime -Force
    Copy-Item -LiteralPath (Join-Path $railwaySdk $railwayDll) -Destination $railwayNested -Force
}
foreach ($railwayEdition in @('Full','Demo')) {
    $railwayExe = if ($railwayEdition -eq 'Full') { 'RailwayFury' } else { 'RailwayFuryDemo' }
    $railwayPack = Join-Path $railwayRoot "Build - RailwayFury/Steam/$railwayEdition/$railwayExe.pck"
    $railwayLog = Join-Path $PSScriptRoot "probe_$railwayEdition.log"
    & (Join-Path $railwayRoot 'Godot/Godot_v4.6-stable_win64_console.exe') --headless --path $railwayRuntime --main-pack $railwayPack --script (Join-Path $railwayRoot 'FeedingABlackHoldGame/Games/RowDivers/Tools/ProbeSteamPack.gd') *> $railwayLog
    if ($LASTEXITCODE -ne 0) { throw "$railwayEdition pack probe failed." }
    $railwayText = Get-Content -LiteralPath $railwayLog -Raw
    if ($railwayText -notmatch 'STEAM PACK: 11 checks; 0 failures' -or $railwayText -match 'SCRIPT ERROR|No loader found|Failed loading resource|Failed to load script') { throw "$railwayEdition pack is incomplete. See $railwayLog" }
    Write-Output "$railwayEdition passed 11 independent packaged-runtime checks."
}
