$ErrorActionPreference = 'Stop'

# Deterministic progression model with pricing-driven unlock availability.
# Money not spent is carried forward between runs.

$upgrades = [ordered]@{
  auto_unlock = @{ key='auto_unlock'; base_cost=120.0; growth=1.0; cap=$null; one_time=$true; reqs=@() }
  cursor_unlock = @{ key='cursor_unlock'; base_cost=170.0; growth=1.0; cap=$null; one_time=$true; reqs=@() }

  damage = @{ key='damage'; base_cost=70.0; growth=1.20; cap=14; one_time=$false; reqs=@() }
  resource = @{ key='resource'; base_cost=80.0; growth=1.22; cap=12; one_time=$false; reqs=@() }
  armor = @{ key='armor'; base_cost=90.0; growth=1.23; cap=10; one_time=$false; reqs=@() }
  range = @{ key='range'; base_cost=85.0; growth=1.21; cap=12; one_time=$false; reqs=@() }

  # Density now increases enemy count (risk + reward), not decreases it.
  density = @{ key='density'; base_cost=95.0; growth=1.24; cap=14; one_time=$false; reqs=@() }

  auto_rate = @{ key='auto_rate'; base_cost=110.0; growth=1.25; cap=14; one_time=$false; reqs=@(@{ key='auto_unlock'; min=1 }) }
  cursor_bonus = @{ key='cursor_bonus'; base_cost=130.0; growth=1.26; cap=14; one_time=$false; reqs=@(@{ key='cursor_unlock'; min=1 }) }

  power_capture = @{ key='power_capture'; base_cost=210.0; growth=1.24; cap=16; one_time=$false; reqs=@() }
  active_duration = @{ key='active_duration'; base_cost=240.0; growth=1.25; cap=14; one_time=$false; reqs=@() }
  power_capacity = @{ key='power_capacity'; base_cost=230.0; growth=1.24; cap=14; one_time=$false; reqs=@() }

  unlock_archer = @{ key='unlock_archer'; base_cost=4500.0; growth=1.0; cap=$null; one_time=$true; reqs=@(@{ key='damage'; min=6 }, @{ key='resource'; min=5 }) }
  archer_damage = @{ key='archer_damage'; base_cost=280.0; growth=1.25; cap=18; one_time=$false; reqs=@(@{ key='unlock_archer'; min=1 }) }
  archer_rate = @{ key='archer_rate'; base_cost=270.0; growth=1.24; cap=18; one_time=$false; reqs=@(@{ key='unlock_archer'; min=1 }) }

  # Boss-only mitigation because boss contact hits much harder than regular enemies.
  boss_armor = @{ key='boss_armor'; base_cost=340.0; growth=1.27; cap=16; one_time=$false; reqs=@() }

  unlock_guardian = @{ key='unlock_guardian'; base_cost=12000.0; growth=1.0; cap=$null; one_time=$true; reqs=@(@{ key='unlock_archer'; min=1 }, @{ key='archer_damage'; min=2 }, @{ key='archer_rate'; min=2 }, @{ key='boss_armor'; min=1 }) }
  guardian_vitality = @{ key='guardian_vitality'; base_cost=480.0; growth=1.28; cap=18; one_time=$false; reqs=@(@{ key='unlock_guardian'; min=1 }) }

  unlock_mage = @{ key='unlock_mage'; base_cost=56000.0; growth=1.0; cap=$null; one_time=$true; reqs=@(@{ key='unlock_guardian'; min=1 }, @{ key='guardian_vitality'; min=4 }, @{ key='boss_armor'; min=5 }, @{ key='power_capture'; min=8 }) }
  mage_focus = @{ key='mage_focus'; base_cost=780.0; growth=1.30; cap=16; one_time=$false; reqs=@(@{ key='unlock_mage'; min=1 }) }

  # Fallback repeatable sink to guarantee at least one purchase per run.
  efficiency = @{ key='efficiency'; base_cost=60.0; growth=1.06; cap=400; one_time=$false; reqs=@() }
}

# Alternating categories keeps unlocking path feeling varied, but actual availability is pricing+prereq driven.
$purchasePriority = @(
  'auto_unlock',
  'cursor_unlock',
  'damage',
  'resource',
  'armor',
  'density',
  'range',
  'auto_rate',
  'cursor_bonus',
  'boss_armor',
  'unlock_archer',
  'archer_damage',
  'archer_rate',
  'power_capture',
  'active_duration',
  'power_capacity',
  'unlock_guardian',
  'guardian_vitality',
  'unlock_mage',
  'mage_focus',
  'efficiency'
)

$abilityDefs = [ordered]@{
  knight_vamp = @{ cost=20.0; cooldown=2.2; requires=$null }
  archer_pierce = @{ cost=25.0; cooldown=2.8; requires='has_archer' }
  guardian_fortify = @{ cost=30.0; cooldown=3.4; requires='has_guardian' }
  mage_storm = @{ cost=35.0; cooldown=4.0; requires='has_mage' }
}
$abilityPriority = @('knight_vamp', 'archer_pierce', 'guardian_fortify', 'mage_storm')

function Get-CostAt($upgrade, [int]$level) {
  if ($upgrade.one_time) { return [double]$upgrade.base_cost }
  return [double]$upgrade.base_cost * [math]::Pow([double]$upgrade.growth, $level)
}

function Get-LevelParams([int]$levelIdx) {
  $lv = $levelIdx - 1
  $enemyHp = 65.0 * [math]::Pow(1.48, $lv)
  $enemyContact = 8.5 * [math]::Pow(1.40, $lv)
  $enemyDrop = 16.0 * [math]::Pow(1.36, $lv)
  return @{
    regular_count = 24 + 8 * $lv
    enemy_hp = $enemyHp
    enemy_contact_dps = $enemyContact
    dot_dps = 1.8 * [math]::Pow(1.24, $lv)
    enemy_drop = $enemyDrop
    enemy_power = 6.0 * [math]::Pow(1.08, $lv)

    boss_hp = $enemyHp * (28.0 + 4.0 * $levelIdx)
    boss_contact_dps = $enemyContact * 3.3
    boss_drop = $enemyDrop * (60.0 + 10.0 * $levelIdx)
    boss_power = (6.0 * [math]::Pow(1.08, $lv)) * 10.0

    gap_regular = 3.2
    gap_boss = 4.8
  }
}

function Get-DerivedStats($state) {
  $lv = $state.levels

  $clickRate = 4.5
  $autoRate = 0.0
  if ($lv.auto_unlock -gt 0) { $autoRate = 1.2 + $lv.auto_rate * 0.45 }

  $baseDamage = 7.5 + $lv.damage * 1.45
  $knightDps = $baseDamage * ($clickRate + $autoRate)

  $archerDps = 0.0
  if ($lv.unlock_archer -gt 0) {
    $archerDps = (5.5 + $lv.archer_damage * 1.15) * (1.9 + $lv.archer_rate * 0.28)
  }

  $guardianDps = 0.0
  if ($lv.unlock_guardian -gt 0) { $guardianDps = 8.0 + $lv.guardian_vitality * 0.8 }

  $mageDps = 0.0
  if ($lv.unlock_mage -gt 0) { $mageDps = 11.0 + $lv.mage_focus * 1.7 }

  $baseArmor = [math]::Min(0.72, $lv.armor * 0.026)
  $guardianArmor = 0.0
  if ($lv.unlock_guardian -gt 0) {
    $guardianArmor = [math]::Min(0.14, 0.03 + $lv.guardian_vitality * 0.0035)
  }

  $bossArmor = [math]::Min(0.65, $lv.boss_armor * 0.030)

  $maxHp = 240.0
  if ($lv.unlock_guardian -gt 0) { $maxHp += 90.0 + $lv.guardian_vitality * 18.0 }
  if ($lv.unlock_mage -gt 0) { $maxHp += 40.0 }

  $resourceMult = 1.0 + $lv.resource * 0.08 + $lv.efficiency * 0.005
  # Density now increases enemy count and reward opportunity.
  $densityFactor = [math]::Min(2.4, 1.0 + $lv.density * 0.07)

  $cursorBonus = 0.0
  if ($lv.cursor_unlock -gt 0) { $cursorBonus = 1.0 + $lv.cursor_bonus * 1.0 }

  $baseRange = 0.5 + $lv.range * 0.12
  $knightRange = [math]::Min(2.1, $baseRange)
  $archerRange = 0.0
  if ($lv.unlock_archer -gt 0) { $archerRange = 4.6 + $lv.range * 0.14 }
  $guardianRange = 0.0
  if ($lv.unlock_guardian -gt 0) { $guardianRange = 1.4 + $lv.range * 0.05 }
  $mageRange = 0.0
  if ($lv.unlock_mage -gt 0) { $mageRange = 5.3 + $lv.range * 0.12 }

  $powerCapacity = 40.0 + $lv.power_capacity * 11.0
  $powerCaptureMult = 1.0 + $lv.power_capture * 0.20
  $activeDuration = 5.0 + $lv.active_duration * 0.55

  return @{
    max_hp = $maxHp
    move_speed = 2.35
    resource_mult = $resourceMult
    density_factor = $densityFactor
    cursor_bonus = $cursorBonus

    knight_dps = $knightDps
    archer_dps = $archerDps
    guardian_dps = $guardianDps
    mage_dps = $mageDps

    knight_range = $knightRange
    archer_range = $archerRange
    guardian_range = $guardianRange
    mage_range = $mageRange

    armor = [math]::Min(0.86, $baseArmor + $guardianArmor)
    boss_armor = $bossArmor

    power_capacity = $powerCapacity
    power_capture_mult = $powerCaptureMult
    active_duration = $activeDuration

    has_archer = ($lv.unlock_archer -gt 0)
    has_guardian = ($lv.unlock_guardian -gt 0)
    has_mage = ($lv.unlock_mage -gt 0)
  }
}

function Upgrade-IsAvailable($state, $up) {
  $lvl = [int]$state.levels[$up.key]
  if ($up.one_time -and $lvl -gt 0) { return $false }
  if ($null -ne $up.cap -and $lvl -ge [int]$up.cap) { return $false }

  foreach ($r in $up.reqs) {
    $reqLevel = [int]$state.levels[$r.key]
    if ($reqLevel -lt [int]$r.min) { return $false }
  }

  return $true
}

function Try-ActivateAbilities($powerRef, $activeRef, $cooldownRef, $stats, $abilityDefs, $abilityPriority, [ref]$uses) {
  $guard = 0
  while ($guard -lt 10) {
    $guard += 1
    $castSomething = $false

    foreach ($ability in $abilityPriority) {
      $def = $abilityDefs[$ability]
      if ($null -ne $def.requires -and -not [bool]$stats[$def.requires]) { continue }
      if ($cooldownRef.Value[$ability] -gt 0.0) { continue }
      if ($powerRef.Value -lt [double]$def.cost) { continue }

      $powerRef.Value -= [double]$def.cost
      $activeRef.Value[$ability] = $stats.active_duration
      $cooldownRef.Value[$ability] = [double]$def.cooldown
      $uses.Value[$ability] += 1
      $castSomething = $true
      break
    }

    if (-not $castSomething) { break }
  }
}

function Resolve-Encounter(
  [double]$hpLeft,
  [double]$runPower,
  $activeTimers,
  $activeCooldowns,
  [double]$enemyHp,
  [double]$enemyContactDps,
  [double]$dotDps,
  [double]$gap,
  [double]$drop,
  [double]$powerDrop,
  [bool]$isBoss,
  $stats,
  $abilityDefs,
  $abilityPriority
) {
  $dt = 0.05
  $distance = $gap
  $enemy = $enemyHp
  $hp = $hpLeft
  $power = $runPower

  $time = 0.0
  $dotTaken = 0.0
  $contactTaken = 0.0

  $cursor = 0.0
  $hero = 0.0
  $missed = 0.0

  $abilityUses = @{ knight_vamp=0; archer_pierce=0; guardian_fortify=0; mage_storm=0 }
  $powerCappedNoTargetTicks = 0

  while ($enemy -gt 0.0 -and $hp -gt 0.0 -and $time -lt 300.0) {
    $activeRef = [ref]$activeTimers
    $cooldownRef = [ref]$activeCooldowns
    $powerRef = [ref]$power
    $usesRef = [ref]$abilityUses
    Try-ActivateAbilities $powerRef $activeRef $cooldownRef $stats $abilityDefs $abilityPriority $usesRef

    $knightDps = 0.0
    if ($distance -le $stats.knight_range) { $knightDps = $stats.knight_dps }

    $archerDps = 0.0
    if ($stats.has_archer -and $distance -le ($stats.archer_range + ($(if ($activeTimers.archer_pierce -gt 0.0) { 2.0 } else { 0.0 })))) {
      $archerDps = $stats.archer_dps * ($(if ($activeTimers.archer_pierce -gt 0.0) { 2.2 } else { 1.0 }))
    }

    $guardianDps = 0.0
    if ($stats.has_guardian -and $distance -le $stats.guardian_range) { $guardianDps = $stats.guardian_dps }

    $mageDps = 0.0
    if ($stats.has_mage -and $distance -le $stats.mage_range) {
      $mageDps = $stats.mage_dps
      if ($activeTimers.mage_storm -gt 0.0) { $mageDps += 46.0 + ($stats.mage_dps * 0.5) }
    }

    $totalDps = $knightDps + $archerDps + $guardianDps + $mageDps
    $damage = $totalDps * $dt
    if ($damage -gt $enemy) { $damage = $enemy }
    $enemy -= $damage

    if ($activeTimers.knight_vamp -gt 0.0 -and $knightDps -gt 0.0 -and $damage -gt 0.0) {
      $knightShare = [math]::Min(1.0, $knightDps / [math]::Max(1.0, $totalDps))
      $heal = $damage * $knightShare * 0.52
      $hp = [math]::Min($stats.max_hp, $hp + $heal)
    }

    if ($distance -gt 0.0) { $distance = [math]::Max(0.0, $distance - $stats.move_speed * $dt) }

    $armorTotal = $stats.armor
    if ($isBoss) { $armorTotal = [math]::Min(0.92, $armorTotal + $stats.boss_armor) }
    if ($activeTimers.guardian_fortify -gt 0.0) { $armorTotal = [math]::Min(0.94, $armorTotal + 0.22) }

    $incomingMult = 1.0 - $armorTotal
    $dotHit = $dotDps * $dt * $incomingMult
    $contactHit = 0.0
    if ($distance -le 0.0 -and $enemy -gt 0.0) { $contactHit = $enemyContactDps * $dt * $incomingMult }

    $hp -= ($dotHit + $contactHit)
    $dotTaken += $dotHit
    $contactTaken += $contactHit

    foreach ($k in @('knight_vamp', 'archer_pierce', 'guardian_fortify', 'mage_storm')) {
      if ($activeTimers[$k] -gt 0.0) { $activeTimers[$k] = [math]::Max(0.0, $activeTimers[$k] - $dt) }
      if ($activeCooldowns[$k] -gt 0.0) { $activeCooldowns[$k] = [math]::Max(0.0, $activeCooldowns[$k] - $dt) }
    }

    $hasAvailableSpendTarget = $false
    foreach ($ability in $abilityPriority) {
      $def = $abilityDefs[$ability]
      if ($null -ne $def.requires -and -not [bool]$stats[$def.requires]) { continue }
      if ($activeCooldowns[$ability] -gt 0.0) { continue }
      if ($power -lt [double]$def.cost) { continue }
      $hasAvailableSpendTarget = $true
      break
    }
    if ($power -ge ($stats.power_capacity - 0.0001) -and -not $hasAvailableSpendTarget) { $powerCappedNoTargetTicks += 1 }

    $time += $dt
  }

  $killed = ($enemy -le 0.0) -and ($hp -gt 0.0)
  if ($killed) {
    $cursor = 0.60 * $drop + $stats.cursor_bonus
    $hero = 0.30 * $drop
    $missed = 0.10 * $drop

    $powerGain = $powerDrop * $stats.power_capture_mult
    $power = [math]::Min($stats.power_capacity, $power + $powerGain)
  }

  return [pscustomobject]@{
    enemy_killed = $killed
    hp_after = [math]::Max(0.0, $hp)
    power_after = $power
    time_spent = $time
    dot_damage = $dotTaken
    contact_damage = $contactTaken
    currency_cursor = $cursor
    currency_hero = $hero
    currency_missed = $missed
    uses_knight_vamp = $abilityUses.knight_vamp
    uses_archer_pierce = $abilityUses.archer_pierce
    uses_guardian_fortify = $abilityUses.guardian_fortify
    uses_mage_storm = $abilityUses.mage_storm
    power_capped_no_target_ticks = $powerCappedNoTargetTicks
  }
}

function Buy-OneUpgrade($state, $upgrades, $purchasePriority) {
  # Milestone unlocks are attempted first when affordable.
  foreach ($mKey in @('unlock_archer', 'unlock_guardian', 'unlock_mage')) {
    if ([int]$state.levels[$mKey] -gt 0) { continue }
    $mUp = $upgrades[$mKey]
    if (-not (Upgrade-IsAvailable $state $mUp)) { break }

    $mLvl = [int]$state.levels[$mKey]
    $mCost = Get-CostAt $mUp $mLvl
    if ([double]$state.currency -ge $mCost) {
      $state.currency = [double]$state.currency - $mCost
      $state.levels[$mKey] = $mLvl + 1
      return @{ key=$mKey; cost=$mCost }
    }
  }

  # If a character is unlocked, bias spending toward prerequisites for the next character.
  $prepKeys = @()
  if ([int]$state.levels['unlock_archer'] -gt 0 -and [int]$state.levels['unlock_guardian'] -eq 0) {
    $prepKeys = @('archer_damage', 'archer_rate', 'boss_armor')
  } elseif ([int]$state.levels['unlock_guardian'] -gt 0 -and [int]$state.levels['unlock_mage'] -eq 0) {
    $prepKeys = @('guardian_vitality', 'boss_armor', 'power_capture')
  }

  if ($prepKeys.Count -gt 0) {
    $prepCandidates = @()
    foreach ($pk in $prepKeys) {
      $pu = $upgrades[$pk]
      if (-not (Upgrade-IsAvailable $state $pu)) { continue }
      $pl = [int]$state.levels[$pk]
      $pc = Get-CostAt $pu $pl
      if ([double]$state.currency -lt $pc) { continue }
      $prepCandidates += [pscustomobject]@{ key=$pk; lvl=$pl; cost=$pc }
    }

    if ($prepCandidates.Count -gt 0) {
      $pick = $prepCandidates | Sort-Object lvl, cost | Select-Object -First 1
      $state.currency = [double]$state.currency - [double]$pick.cost
      $state.levels[$pick.key] = [int]$state.levels[$pick.key] + 1
      return @{ key=$pick.key; cost=[double]$pick.cost }
    }
  }

  foreach ($key in $purchasePriority) {
    $up = $upgrades[$key]
    if (-not (Upgrade-IsAvailable $state $up)) { continue }

    $lvl = [int]$state.levels[$key]
    $cost = Get-CostAt $up $lvl
    if ([double]$state.currency -ge $cost) {
      $state.currency = [double]$state.currency - $cost
      $state.levels[$key] = $lvl + 1
      return @{ key=$key; cost=$cost }
    }
  }

  return @{ key=$null; cost=0.0 }
}

function Run-Single([int]$levelIdx, [int]$globalRunIdx, [int]$runIdxInLevel, $state, $upgrades, $purchasePriority, $abilityDefs, $abilityPriority) {
  $lp = Get-LevelParams $levelIdx
  $stats = Get-DerivedStats $state

  $hp = [double]$stats.max_hp
  $power = 0.0

  $activeTimers = @{ knight_vamp=0.0; archer_pierce=0.0; guardian_fortify=0.0; mage_storm=0.0 }
  $activeCooldowns = @{ knight_vamp=0.0; archer_pierce=0.0; guardian_fortify=0.0; mage_storm=0.0 }

  $time = 0.0
  $dotTaken = 0.0
  $contactTaken = 0.0

  $regularCount = [math]::Max(8, [int][math]::Round($lp.regular_count * $stats.density_factor))
  $killedCount = 0

  $cursor = 0.0
  $hero = 0.0
  $missed = 0.0

  $usesKnight = 0
  $usesArcher = 0
  $usesGuardian = 0
  $usesMage = 0
  $powerNoTargetTicks = 0

  for ($i = 0; $i -lt $regularCount; $i++) {
    $enc = Resolve-Encounter $hp $power $activeTimers $activeCooldowns $lp.enemy_hp $lp.enemy_contact_dps $lp.dot_dps $lp.gap_regular ($lp.enemy_drop * $stats.resource_mult) $lp.enemy_power $false $stats $abilityDefs $abilityPriority

    $hp = [double]$enc.hp_after
    $power = [double]$enc.power_after
    $time += [double]$enc.time_spent
    $dotTaken += [double]$enc.dot_damage
    $contactTaken += [double]$enc.contact_damage

    $cursor += [double]$enc.currency_cursor
    $hero += [double]$enc.currency_hero
    $missed += [double]$enc.currency_missed

    $usesKnight += $enc.uses_knight_vamp
    $usesArcher += $enc.uses_archer_pierce
    $usesGuardian += $enc.uses_guardian_fortify
    $usesMage += $enc.uses_mage_storm
    $powerNoTargetTicks += $enc.power_capped_no_target_ticks

    if (-not $enc.enemy_killed) { break }
    $killedCount += 1
  }

  $reachedBoss = ($killedCount -eq $regularCount) -and ($hp -gt 0)
  $bossDefeated = $false

  if ($reachedBoss) {
    $encBoss = Resolve-Encounter $hp $power $activeTimers $activeCooldowns $lp.boss_hp $lp.boss_contact_dps $lp.dot_dps $lp.gap_boss ($lp.boss_drop * $stats.resource_mult) $lp.boss_power $true $stats $abilityDefs $abilityPriority

    $hp = [double]$encBoss.hp_after
    $power = [double]$encBoss.power_after
    $time += [double]$encBoss.time_spent
    $dotTaken += [double]$encBoss.dot_damage
    $contactTaken += [double]$encBoss.contact_damage

    $cursor += [double]$encBoss.currency_cursor
    $hero += [double]$encBoss.currency_hero
    $missed += [double]$encBoss.currency_missed

    $usesKnight += $encBoss.uses_knight_vamp
    $usesArcher += $encBoss.uses_archer_pierce
    $usesGuardian += $encBoss.uses_guardian_fortify
    $usesMage += $encBoss.uses_mage_storm
    $powerNoTargetTicks += $encBoss.power_capped_no_target_ticks

    if ($encBoss.enemy_killed) { $bossDefeated = $true }
  }

  $earned = $cursor + $hero
  $walletBefore = [double]$state.currency
  $state.currency = [double]$state.currency + $earned
  $walletAfterEarn = [double]$state.currency

  $buy = Buy-OneUpgrade $state $upgrades $purchasePriority

  return [pscustomobject][ordered]@{
    global_run_index = $globalRunIdx
    level = $levelIdx
    run_index_in_level = $runIdxInLevel

    boss_defeated = $bossDefeated
    enemies_killed = $killedCount
    reached_boss = $reachedBoss

    time_seconds = $time
    damage_taken_dot = $dotTaken
    damage_taken_contact = $contactTaken

    currency_cursor = $cursor
    currency_hero = $hero
    currency_missed = $missed
    currency_earned = $earned

    wallet_before = $walletBefore
    wallet_after_earn = $walletAfterEarn
    upgrade_bought = $buy.key
    upgrade_cost = [double]$buy.cost
    wallet_after_spend = [double]$state.currency

    power_left = $power
    uses_knight_vamp = $usesKnight
    uses_archer_pierce = $usesArcher
    uses_guardian_fortify = $usesGuardian
    uses_mage_storm = $usesMage
    power_capped_no_target_ticks = $powerNoTargetTicks
  }
}

function Format-Time([double]$seconds) {
  $m = [math]::Floor($seconds / 60.0)
  $s = $seconds - ($m * 60.0)
  return ('{0:00}:{1:00.0}' -f $m, $s)
}

$state = @{ currency = 0.0; levels = [ordered]@{} }
foreach ($k in $upgrades.Keys) { $state.levels[$k] = 0 }

$runs = New-Object System.Collections.Generic.List[object]
$cycles = New-Object System.Collections.Generic.List[object]

$maxLevels = 8
$maxRunsPerLevel = 70
$targetPlaySeconds = 3600.0

$totalTime = 0.0
$globalRun = 0
$currentLevel = 1

while ($currentLevel -le $maxLevels -and $totalTime -lt $targetPlaySeconds) {
  $cycleRuns = New-Object System.Collections.Generic.List[object]
  $cleared = $false

  for ($runIdx = 1; $runIdx -le $maxRunsPerLevel; $runIdx++) {
    $globalRun += 1
    $res = Run-Single $currentLevel $globalRun $runIdx $state $upgrades $purchasePriority $abilityDefs $abilityPriority
    $runs.Add($res)
    $cycleRuns.Add($res)
    $totalTime += [double]$res.time_seconds

    if ($res.boss_defeated) {
      $cleared = $true
      break
    }

    if ($totalTime -ge $targetPlaySeconds) { break }
  }

  $cycleTime = ($cycleRuns | Measure-Object -Property time_seconds -Sum).Sum
  $avgCurrency = (($cycleRuns | Measure-Object -Property currency_earned -Sum).Sum) / [math]::Max(1, $cycleRuns.Count)
  $upgradesBought = ($cycleRuns | Where-Object { $_.upgrade_bought -ne $null }).Count
  $avgPowerNoTargetTicks = (($cycleRuns | Measure-Object -Property power_capped_no_target_ticks -Sum).Sum / [math]::Max(1, $cycleRuns.Count))

  $summary = [pscustomobject][ordered]@{
    level = $currentLevel
    runs_in_cycle = $cycleRuns.Count
    boss_cleared = $cleared
    cycle_time_seconds = $cycleTime
    avg_run_seconds = $cycleTime / [math]::Max(1, $cycleRuns.Count)
    avg_currency_per_run = $avgCurrency
    upgrades_bought = $upgradesBought
    upgrades_per_run = $upgradesBought / [math]::Max(1, $cycleRuns.Count)
    avg_power_capped_no_target_ticks_per_run = $avgPowerNoTargetTicks
  }
  $cycles.Add($summary)

  if ($cleared) {
    $currentLevel += 1
  } else {
    if ($currentLevel -lt $maxLevels) { $currentLevel += 1 }
    else { break }
  }
}

Write-Host 'Cycle Summary'
Write-Host 'level | runs | cleared | upgrades/run | avg_currency/run | avg_run_time | cycle_time | cap_no_target_ticks'
foreach ($c in $cycles) {
  $line = '{0,5} | {1,4} | {2,7} | {3,12:N2} | {4,16:N1} | {5,12} | {6,9} | {7,19:N1}' -f `
    $c.level, $c.runs_in_cycle, $c.boss_cleared, $c.upgrades_per_run, $c.avg_currency_per_run, (Format-Time $c.avg_run_seconds), (Format-Time $c.cycle_time_seconds), $c.avg_power_capped_no_target_ticks_per_run
  Write-Host $line
}

$noUpgradeRuns = @($runs | Where-Object { $_.upgrade_bought -eq $null })
Write-Host ''
Write-Host 'Run Validation'
Write-Host ('total_runs={0}' -f $runs.Count)
Write-Host ('total_play_time={0} ({1:N1} sec)' -f (Format-Time $totalTime), $totalTime)
Write-Host ('runs_without_upgrade={0}' -f $noUpgradeRuns.Count)
$purchaseRate = 1.0 - ($noUpgradeRuns.Count / [math]::Max(1.0, [double]$runs.Count))
Write-Host ('upgrade_purchase_rate={0:N3}' -f $purchaseRate)

Write-Host ''
Write-Host 'Character Unlock Runs'
$charUnlocks = @('unlock_archer', 'unlock_guardian', 'unlock_mage')
foreach ($u in $charUnlocks) {
  $first = $runs | Where-Object { $_.upgrade_bought -eq $u } | Select-Object -First 1
  if ($null -ne $first) {
    Write-Host ('{0}: run {1}' -f $u, $first.global_run_index)
  } else {
    Write-Host ('{0}: not unlocked in window' -f $u)
  }
}

Write-Host ''
Write-Host 'Final Upgrade Levels'
foreach ($k in $purchasePriority) {
  if ($state.levels.Contains($k)) { Write-Host ('{0}: {1}' -f $k, $state.levels[$k]) }
}

$levelsOut = @{}
foreach ($k in $state.levels.Keys) { $levelsOut[$k] = [int]$state.levels[$k] }

$cycleOut = foreach ($c in $cycles) { [pscustomobject]$c }
$runOut = foreach ($r in $runs) { [pscustomobject]$r }
$out = New-Object PSObject
$out | Add-Member -MemberType NoteProperty -Name cycle_summary -Value $cycleOut
$out | Add-Member -MemberType NoteProperty -Name runs -Value $runOut
$out | Add-Member -MemberType NoteProperty -Name final_upgrade_levels -Value ([pscustomobject]$levelsOut)
$out | Add-Member -MemberType NoteProperty -Name final_wallet -Value ([double]$state.currency)
$out | Add-Member -MemberType NoteProperty -Name total_play_seconds -Value ([double]$totalTime)

$outPath = 'c:\Godot Projects\FishingIncremental\simulation\simulation_results_no_skips.json'
($out | ConvertTo-Json -Depth 9) | Set-Content -Path $outPath

$reportPath = 'c:\Godot Projects\FishingIncremental\simulation\simulation_run_report_no_skips.md'
$report = New-Object System.Collections.Generic.List[string]
$report.Add('# Simulation Run Report') | Out-Null
$report.Add('') | Out-Null
$report.Add("Total play time: $(Format-Time $totalTime) ($([math]::Round($totalTime,1)) seconds)") | Out-Null
$report.Add('') | Out-Null
$report.Add('## Per-Run Purchases') | Out-Null
$report.Add('') | Out-Null
$report.Add('| Run | Level | Run In Level | Time (s) | Earned | Wallet Before | Wallet After Earn | Upgrade Bought | Cost | Wallet After Spend |') | Out-Null
$report.Add('|---:|---:|---:|---:|---:|---:|---:|---|---:|---:|') | Out-Null
foreach ($r in $runs) {
  $report.Add("| $($r.global_run_index) | $($r.level) | $($r.run_index_in_level) | $([math]::Round($r.time_seconds,1)) | $([math]::Round($r.currency_earned,1)) | $([math]::Round($r.wallet_before,1)) | $([math]::Round($r.wallet_after_earn,1)) | $($r.upgrade_bought) | $([math]::Round($r.upgrade_cost,1)) | $([math]::Round($r.wallet_after_spend,1)) |") | Out-Null
}
$report | Set-Content -Path $reportPath

Write-Host ''
Write-Host ('Wrote {0}' -f $outPath)
Write-Host ('Wrote {0}' -f $reportPath)
