param([ValidateSet('Full','Demo')][string[]]$Edition = @('Full','Demo'))
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskOverride = Join-Path $taskRoot 'FeedingABlackHoldGame/override.cfg'
$taskProjectFile = Join-Path $taskRoot 'FeedingABlackHoldGame/project.godot'
$taskOriginalProject = [System.IO.File]::ReadAllBytes($taskProjectFile)
if (Test-Path -LiteralPath $taskOverride) { throw 'Preserve the existing override.cfg before preparing controller QA.' }
& python (Join-Path $PSScriptRoot 'prepare_controller_qa.py')
if ($LASTEXITCODE -ne 0) { throw 'Preparing controller QA presets failed.' }
try {
    # Override both the base and demo-specific value. Godot gives the demo
    # feature precedence over a separate single-feature QA override.
    Set-Content -LiteralPath $taskOverride -Encoding utf8NoBOM -Value @'
[application]
config/custom_user_dir_name="RailwayFuryControllerQA"
config/custom_user_dir_name.railway_demo="RailwayFuryControllerQA"
'@
    # The exporter serializes project.godot's feature overrides, rather than
    # override.cfg's values. Patch only save-folder keys and restore exact bytes.
    $taskProjectText = [System.IO.File]::ReadAllText($taskProjectFile)
    $taskQaProject = [regex]::Replace($taskProjectText, '(?m)^(config/custom_user_dir_name(?:\.[^=\r\n]+)?)=.*$', '$1="RailwayFuryControllerQA"')
    [System.IO.File]::WriteAllText($taskProjectFile, $taskQaProject, [System.Text.UTF8Encoding]::new($false))
    foreach ($taskEdition in $Edition) {
        & (Join-Path $taskRoot 'Godot/Godot_v4.6-stable_win64_console.exe') --headless --path (Join-Path $taskRoot 'FeedingABlackHoldGame') --export-release "Railway Fury Controller QA $taskEdition" *> (Join-Path $PSScriptRoot "export-controller-qa-$taskEdition.log")
        if ($LASTEXITCODE -ne 0) { throw "Controller QA export failed: $taskEdition" }
    }
} finally {
    [System.IO.File]::WriteAllBytes($taskProjectFile, $taskOriginalProject)
    if (Test-Path -LiteralPath $taskOverride) { Remove-Item -LiteralPath $taskOverride }
}
