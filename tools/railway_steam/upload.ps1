param(
    [string]$SteamUsername = 'Beep2Bleep',
    [string]$SteamCmd = 'C:/Users/stick/Downloads/steamworks_sdk_165/sdk/tools/ContentBuilder/builder/steamcmd.exe'
)
$ErrorActionPreference = 'Stop'
$railwayRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$railwayStaging = Join-Path $railwayRoot 'Build - RailwayFury/Steam'
$railwayScripts = Join-Path $railwayStaging 'UploadScripts'
New-Item -ItemType Directory -Force $railwayScripts | Out-Null
foreach ($railwayEdition in @(@('Full','5520300','5520301'),@('Demo','5520330','5520331'))) {
    $railwayContent = (Join-Path $railwayStaging $railwayEdition[0]).Replace('\','/')
    $railwayOutput = (Join-Path $railwayStaging ('SteamPipeOutput/'+$railwayEdition[0])).Replace('\','/')
    $railwayVdf = @"
"AppBuild"
{
    "AppID" "$($railwayEdition[1])"
    "Desc" "Railway Fury $($railwayEdition[0]) Windows 0.1 - unpublished preparation"
    "BuildOutput" "$railwayOutput"
    "ContentRoot" "$railwayContent"
    "Preview" "0"
    "Depots"
    {
        "$($railwayEdition[2])"
        {
            "FileMapping" { "LocalPath" "*" "DepotPath" "." "recursive" "1" }
            "FileExclusion" "*.log"
            "FileExclusion" "steam_appid.txt"
        }
    }
}
"@
    Set-Content -LiteralPath (Join-Path $railwayScripts ($railwayEdition[0]+'.vdf')) -Value $railwayVdf -Encoding utf8NoBOM
}
# No SetLive key: both uploads remain unassigned builds. No publishing command.
& $SteamCmd +login $SteamUsername +run_app_build (Join-Path $railwayScripts 'Full.vdf') +run_app_build (Join-Path $railwayScripts 'Demo.vdf') +quit
if ($LASTEXITCODE -ne 0) { throw 'SteamPipe did not complete. Review its local console/logs.' }
Write-Host 'Upload commands finished. Verify both build IDs in Steamworks; do not set live.'
