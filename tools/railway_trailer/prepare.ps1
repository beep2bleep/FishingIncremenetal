$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$source = Join-Path $root 'FeedingABlackHoldGame'
$capture = Join-Path $root 'Build - RailwayFury/TrailerReview/project'
$output = Join-Path $root 'Build - RailwayFury/TrailerReview'
New-Item -ItemType Directory -Force -Path $capture | Out-Null
Get-ChildItem -LiteralPath $source -Force | ForEach-Object {
    $destination = Join-Path $capture $_.Name
    if ($_.Name -eq 'project.godot') { return }
    if (Test-Path -LiteralPath $destination) { return }
    if ($_.PSIsContainer) {
        New-Item -ItemType Junction -Path $destination -Target $_.FullName | Out-Null
    } else {
        New-Item -ItemType HardLink -Path $destination -Target $_.FullName | Out-Null
    }
}
$config = Get-Content -LiteralPath (Join-Path $source 'project.godot') -Raw
$config = $config.Replace('config/custom_user_dir_name="RailwayFury"','config/custom_user_dir_name="RailwayFuryTrailerReview"')
[IO.File]::WriteAllText((Join-Path $capture 'project.godot'), $config)
& (Join-Path $root 'Godot/Godot_v4.6-stable_win64_console.exe') --path $capture --resolution 1920x1080 --write-movie (Join-Path $output 'source.avi') --fixed-fps 30 --disable-vsync --script res://Games/RowDivers/Tools/CaptureReviewTrailer.gd -- $output *> (Join-Path $output 'capture.log')
exit $LASTEXITCODE
