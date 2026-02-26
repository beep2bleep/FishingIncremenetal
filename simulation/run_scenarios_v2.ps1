$ErrorActionPreference = 'Stop'

$simScript = Join-Path $PSScriptRoot 'simulation_60upgrades_2h.ps1'

$scenarios = @(
  @{ name='v2_baseline'; suffix='v2_baseline'; wave_size='3'; wave_gap_mult='0.35'; archer_dps_mult='0.90'; archer_delay='0.35' },
  @{ name='v2_archer_slower'; suffix='v2_archer_slower'; wave_size='3'; wave_gap_mult='0.35'; archer_dps_mult='0.82'; archer_delay='0.45' },
  @{ name='v2_archer_faster'; suffix='v2_archer_faster'; wave_size='3'; wave_gap_mult='0.40'; archer_dps_mult='0.98'; archer_delay='0.25' }
)

$targetRuns = 86
$targetBoss = 4
$targetMaxLevel = 5

$summary = @()

foreach ($s in $scenarios) {
  $env:SIM_SCENARIO = $s.name
  $env:SIM_OUTPUT_SUFFIX = $s.suffix
  $env:SIM_WAVE_SIZE = $s.wave_size
  $env:SIM_WAVE_FOLLOWUP_GAP_MULT = $s.wave_gap_mult
  $env:SIM_ARCHER_PROJECTILE_DPS_MULT = $s.archer_dps_mult
  $env:SIM_ARCHER_PROJECTILE_HIT_DELAY = $s.archer_delay

  & $simScript

  $jsonPath = Join-Path $PSScriptRoot ("simulation_results_2h_60upgrades_{0}.json" -f $s.suffix)
  $obj = Get-Content -Raw $jsonPath | ConvertFrom-Json

  $runs = [int]$obj.total_runs
  $boss = [int]$obj.boss_defeats
  $maxLevel = [int]$obj.max_level_reached
  $time = [double]$obj.total_time_seconds

  $score = [math]::Abs($runs - $targetRuns) + (2.0 * [math]::Abs($boss - $targetBoss)) + (4.0 * [math]::Abs($maxLevel - $targetMaxLevel))

  $summary += [pscustomobject]@{
    scenario = $s.name
    suffix = $s.suffix
    total_time_seconds = [math]::Round($time, 1)
    total_runs = $runs
    boss_defeats = $boss
    max_level_reached = $maxLevel
    score = [math]::Round($score, 2)
  }
}

$best = $summary | Sort-Object score, scenario | Select-Object -First 1

$bestSuffix = $best.suffix
$bestReport = Join-Path $PSScriptRoot ("simulation_run_report_2h_60upgrades_{0}.md" -f $bestSuffix)
$bestJson = Join-Path $PSScriptRoot ("simulation_results_2h_60upgrades_{0}.json" -f $bestSuffix)
$bestPrices = Join-Path $PSScriptRoot ("upgrade_prices_in_order_{0}.md" -f $bestSuffix)

Copy-Item $bestReport (Join-Path $PSScriptRoot 'simulation_run_report_2h_60upgrades.md') -Force
Copy-Item $bestJson (Join-Path $PSScriptRoot 'simulation_results_2h_60upgrades.json') -Force
Copy-Item $bestPrices (Join-Path $PSScriptRoot 'upgrade_prices_in_order.md') -Force

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Simulation V2 Scenario Comparison') | Out-Null
$md.Add('') | Out-Null
$md.Add('Prices unchanged; only combat-rule parameters varied.') | Out-Null
$md.Add('') | Out-Null
$md.Add('| Scenario | Time (s) | Runs | Boss Defeats | Max Level | Fit Score |') | Out-Null
$md.Add('|---|---:|---:|---:|---:|---:|') | Out-Null
foreach ($r in ($summary | Sort-Object score, scenario)) {
  $md.Add("| $($r.scenario) | $($r.total_time_seconds) | $($r.total_runs) | $($r.boss_defeats) | $($r.max_level_reached) | $($r.score) |") | Out-Null
}
$md.Add('') | Out-Null
$md.Add("Selected standard report scenario: **$($best.scenario)**") | Out-Null
$md.Add('Standard report path: `simulation/simulation_run_report_2h_60upgrades.md`') | Out-Null

$md | Set-Content -Path (Join-Path $PSScriptRoot 'simulation_scenario_comparison_v2.md')

Write-Host ('Selected scenario: {0}' -f $best.scenario)
