param(
    [string]$Modes = "normal,fast_render,no_render",
    [int]$MaxSorties = 160,
    [double]$TimeoutSeconds = 1800,
    [string]$ResumeCheckpoint = ""
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$RepoRoot = Resolve-Path (Join-Path $ProjectRoot "..")
$GodotExe = Resolve-Path (Join-Path $RepoRoot "Godot\Godot_v4.6-stable_win64_console.exe")
$OutputRoot = Join-Path $ProjectRoot ".validation\open_pit_empire"
$ReportDir = (Join-Path $OutputRoot "reports").Replace("\", "/")
$LogFile = (Join-Path $OutputRoot "godot-validation.log").Replace("\", "/")

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

Write-Host "Open Pit Empire validation"
Write-Host "Project: $ProjectRoot"
Write-Host "Modes: $Modes"
Write-Host "Report directory: $ReportDir"
if ($ResumeCheckpoint -ne "") {
    Write-Host "Resume checkpoint: $ResumeCheckpoint"
}
Write-Host "Your current Open Pit Empire save is backed up and restored by the validation runner."

$GodotArgs = @(
    "--headless",
    "--path", $ProjectRoot,
    "--log-file", $LogFile,
    "res://Games/OpenPitEmpire/Tools/OpenPitEmpireValidationRunner.tscn",
    "--",
    "--modes=$Modes",
    "--max-sorties=$MaxSorties",
    "--timeout-seconds=$TimeoutSeconds",
    "--report-dir=$ReportDir"
)
if ($ResumeCheckpoint -ne "") {
    $GodotArgs += "--resume-checkpoint=$ResumeCheckpoint"
}

& $GodotExe @GodotArgs

$ExitCode = $LASTEXITCODE
$ReportPath = Join-Path $ReportDir "summary.md"
Write-Host "Report: $ReportPath"
Write-Host "Appended frame/perf data: $(Join-Path $ReportDir 'frame_rate_data.jsonl')"
Write-Host "Appended run summaries: $(Join-Path $ReportDir 'run_summaries.jsonl')"
exit $ExitCode
