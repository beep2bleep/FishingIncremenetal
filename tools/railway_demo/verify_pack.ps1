$ErrorActionPreference = 'Stop'
$railwayRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$railwayRuntime = Join-Path $PSScriptRoot 'pack_runtime'
$railwaySdk = Join-Path $railwayRoot 'FeedingABlackHoldGame/addons/godotsteam/win64'
$railwaySdkRuntime = Join-Path $railwayRuntime 'addons/godotsteam/win64'
New-Item -ItemType Directory -Force $railwaySdkRuntime | Out-Null
if (Get-ChildItem -LiteralPath $railwayRuntime -Recurse -File -Filter '*.gd') {
    throw 'The pack verification directory must contain no fallback source scripts.'
}
foreach ($railwayDll in @('libgodotsteam.windows.template_debug.x86_64.dll','libgodotsteam.windows.template_release.x86_64.dll','steam_api64.dll')) {
    Copy-Item -LiteralPath (Join-Path $railwaySdk $railwayDll) -Destination $railwayRuntime -Force
    Copy-Item -LiteralPath (Join-Path $railwaySdk $railwayDll) -Destination $railwaySdkRuntime -Force
}
$railwayProbeLog = Join-Path $PSScriptRoot 'packed_windows_probe.log'
& (Join-Path $railwayRoot 'Godot/Godot_v4.6-stable_win64_console.exe') --headless --path $railwayRuntime --main-pack (Join-Path $railwayRoot 'Build - RailwayFury/Demo/Windows/RailwayFuryDemo.pck') --script (Join-Path $railwayRoot 'FeedingABlackHoldGame/Games/RowDivers/Tools/ProbeDemoPack.gd') *> $railwayProbeLog
if ($LASTEXITCODE -ne 0) { throw 'Exported demo probe failed.' }
$railwayProbeText = Get-Content -LiteralPath $railwayProbeLog -Raw
if ($railwayProbeText -match 'SCRIPT ERROR|Cannot open file|No loader found|Failed loading resource|Failed to load script' -or $railwayProbeText -notmatch 'DEMO PACK: 22 checks; 0 failures') {
    throw "Exported demo has missing dependencies or failed checks. See $railwayProbeLog"
}
Write-Output 'Exported demo passed 22 checks without source fallback.'
