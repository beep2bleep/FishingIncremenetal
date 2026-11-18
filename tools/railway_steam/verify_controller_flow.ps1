param([switch]$Capture, [switch]$QuitChecks, [switch]$Quick, [switch]$Small, [string]$Pack)
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskProject = Join-Path $taskRoot 'FeedingABlackHoldGame'
$taskOverride = Join-Path $taskProject 'override.cfg'
if (-not $Pack -and (Test-Path -LiteralPath $taskOverride)) { throw 'An override.cfg already exists; preserve it before running this isolated fixture.' }
$taskEngine = Join-Path $taskRoot 'Godot/Godot_v4.6-stable_win64_console.exe'
try {
    # Godot applies this before initializing autoloads or the user-data folder.
    if (-not $Pack) { Set-Content -LiteralPath $taskOverride -Encoding utf8NoBOM -Value @'
[application]
config/custom_user_dir_name="RailwayFuryControllerQA"
config/custom_user_dir_name.railway_demo="RailwayFuryControllerQA"
'@
    }
    $taskModes = @('flow')
    if ($QuitChecks) { $taskModes += @('quit-main','quit-pause','quit-results','quit-upgrades','quit-credits','quit-ending') }
    if ($Pack -and (Split-Path (Split-Path $Pack -Parent) -Leaf) -eq 'Demo') { $taskModes = $taskModes | Where-Object { $_ -ne 'quit-ending' } }
    foreach ($taskMode in $taskModes) {
        $taskArgs = @('--headless','--path',$taskProject,'--script','res://Games/RowDivers/Tools/VerifyControllerFlow.gd','--',$taskMode)
        if ($Pack) {
            $taskPackPath = (Resolve-Path -LiteralPath $Pack).Path
            $taskArgs = @('--headless','--path',(Join-Path $PSScriptRoot 'pack_runtime'),'--main-pack',$taskPackPath,'--script',(Join-Path $taskProject 'Games/RowDivers/Tools/VerifyControllerFlow.gd'),'--',$taskMode)
        }
        if ($Capture -and $taskMode -eq 'flow') { $taskArgs = $taskArgs | Where-Object { $_ -ne '--headless' }; $taskArgs += '--capture' }
        if ($Quick) { $taskArgs += '--quick' }
        if ($Small) { $taskArgs += '--small' }
        $taskPrefix = if ($Pack) { 'packed-controller-' + (Split-Path (Split-Path $taskPackPath) -Leaf) + '-' } else { 'controller-' }
        $taskLog = Join-Path $PSScriptRoot ($taskPrefix + $taskMode + '.log')
        & $taskEngine @taskArgs *> $taskLog
        if ($LASTEXITCODE -ne 0) { throw "Controller fixture failed: $taskLog" }
        $taskText = Get-Content -LiteralPath $taskLog -Raw
        if ($taskText -match 'SCRIPT ERROR|CONTROLLER FLOW FAILED|Controller Quit did not exit') { throw "Controller fixture reported an error: $taskLog" }
        if ($taskMode -eq 'flow' -and $taskText -notmatch 'CONTROLLER FLOW PASSED') { throw "Missing flow receipt: $taskLog" }
        if ($taskMode -ne 'flow' -and $taskText -notmatch 'CONTROLLER QUIT ACTIVATED') { throw "Missing Quit activation receipt: $taskLog" }
        Select-String -LiteralPath $taskLog -Pattern 'CONTROLLER FLOW PASSED|CONTROLLER QUIT ACTIVATED' | ForEach-Object { $_.Line }
    }
} finally {
    # This is one explicitly named temporary file inside the checked workspace.
    if (-not $Pack -and (Test-Path -LiteralPath $taskOverride)) { Remove-Item -LiteralPath $taskOverride }
}
