$ErrorActionPreference = 'Stop'
$script:COST_SCALE = 0.35

function New-Upgrade($key, $name, $family, $cost, $reqs, $effects, $source) {
  [pscustomobject]@{
    key = $key
    name = $name
    family = $family
    cost = [double]$cost * $script:COST_SCALE
    reqs = $reqs
    effects = $effects
    source = $source
    purchased = $false
  }
}

function Add-Effect($mods, $k, $v) {
  if (-not $mods.ContainsKey($k)) { $mods[$k] = 0.0 }
  $mods[$k] = [double]$mods[$k] + [double]$v
}

function Get-Mod($mods, $k, $defaultValue) {
  if ($mods.ContainsKey($k)) { return [double]$mods[$k] }
  return [double]$defaultValue
}

function Has-AnyUpgrade($state, $key) {
  return ($state.purchased.Contains($key) -or $state.milestones.Contains($key))
}

function Req-Satisfied($state, $req) {
  if ($req.StartsWith('flag:')) {
    $flag = $req.Substring(5)
    if (-not $state.flags.ContainsKey($flag)) { return $false }
    return [bool]$state.flags[$flag]
  }
  return Has-AnyUpgrade $state $req
}

function Upgrade-Available($state, $up) {
  if ($up.purchased) { return $false }
  foreach ($r in $up.reqs) {
    if (-not (Req-Satisfied $state $r)) { return $false }
  }
  return $true
}

function Apply-Upgrade($state, $up) {
  foreach ($k in $up.effects.Keys) { Add-Effect $state.mods $k $up.effects[$k] }
  $up.purchased = $true
  $state.purchased.Add($up.key) | Out-Null
}

function Build-Base60Upgrades {
  $defs = @(
    @{k='salvage_hooks';f='ECON';c=120;r=@();e=@{drop_mult=0.05}},
    @{k='field_magnet';f='ECON';c=145;r=@('salvage_hooks');e=@{hero_collect_bonus=0.02}},
    @{k='encroaching_horde';f='DENS';c=130;r=@();e=@{enemy_count_mult=0.04}},
    @{k='trail_boots';f='MOVE';c=125;r=@();e=@{move_speed_mult=0.04}},
    @{k='reinforced_plates';f='SURV';c=140;r=@();e=@{armor_general=0.03}},
    @{k='condensed_cores_60';f='POWR';c=160;r=@();e=@{power_gain_mult=0.10}},
    @{k='focused_breathing_60';f='ACTV';c=170;r=@();e=@{active_duration_all=0.35}},
    @{k='boss_stance_60';f='BOSS';c=220;r=@('flag:boss_seen');e=@{boss_armor=0.04}},
    @{k='knight_bloodline_1_60';f='TEAM';c=210;r=@();e=@{knight_vamp_bonus=0.06}},
    @{k='supply_lenses';f='ECON';c=190;r=@('field_magnet');e=@{cursor_share_bonus=0.02}},
    @{k='wave_bringer_1';f='DENS';c=215;r=@('encroaching_horde');e=@{elite_count=1}},
    @{k='archer_drill_1_60';f='TEAM';c=360;r=@('flag:archer_unlocked');e=@{archer_speed_mult=0.08}},
    @{k='impact_weave';f='SURV';c=230;r=@('reinforced_plates');e=@{contact_taken_reduction=0.06}},
    @{k='stride_rhythm';f='MOVE';c=210;r=@('trail_boots');e=@{move_speed_mult=0.03;target_swap_speed=0.04}},
    @{k='power_reservoir_1_60';f='POWR';c=240;r=@('condensed_cores_60');e=@{power_cap_flat=12}},
    @{k='quick_invocation_1_60';f='ACTV';c=250;r=@('focused_breathing_60');e=@{cooldown_mult=-0.04}},
    @{k='boss_readiness_60';f='BOSS';c=290;r=@('boss_stance_60');e=@{boss_contact_reduction=0.08}},
    @{k='scrap_broker';f='ECON';c=270;r=@('supply_lenses');e=@{cursor_value_mult=0.07}},
    @{k='line_pressure_1';f='DENS';c=285;r=@('wave_bringer_1');e=@{enemy_count_mult=0.05;drop_mult=0.02}},
    @{k='guardian_bulwark_1_60';f='TEAM';c=520;r=@('flag:guardian_unlocked');e=@{max_hp_mult=0.04}},
    @{k='hemostasis_mesh';f='SURV';c=300;r=@('impact_weave');e=@{dot_taken_reduction=0.10}},
    @{k='momentum_carry';f='MOVE';c=295;r=@('stride_rhythm');e=@{no_contact_speed_mult=0.05}},
    @{k='overflow_capture';f='POWR';c=330;r=@('power_reservoir_1_60');e=@{overflow_drop=0.02}},
    @{k='extended_channel_1_60';f='ACTV';c=320;r=@('quick_invocation_1_60');e=@{active_duration_all=0.45}},
    @{k='boss_fracture_study_60';f='BOSS';c=370;r=@('boss_readiness_60');e=@{boss_hp_reduction=0.05}},
    @{k='taxonomy_scanner';f='ECON';c=340;r=@('scrap_broker');e=@{elite_value_mult=0.06}},
    @{k='archer_piercing_geometry_60';f='TEAM';c=410;r=@('flag:archer_unlocked');e=@{archer_pierce=0.18}},
    @{k='crowd_ecology';f='DENS';c=390;r=@('line_pressure_1');e=@{enemy_count_mult=0.06;enemy_contact_mult=0.02}},
    @{k='shock_padding';f='SURV';c=370;r=@('hemostasis_mesh');e=@{early_mitigation=0.08}},
    @{k='route_memory';f='MOVE';c=360;r=@('momentum_carry');e=@{kill_speed_mult=0.06}},
    @{k='power_reservoir_2_60';f='POWR';c=410;r=@('power_reservoir_1_60');e=@{power_cap_flat=20}},
    @{k='quick_invocation_2_60';f='ACTV';c=430;r=@('quick_invocation_1_60');e=@{cooldown_mult=-0.05}},
    @{k='boss_armor_mesh_60';f='BOSS';c=470;r=@('boss_fracture_study_60');e=@{boss_armor=0.05}},
    @{k='collector_drone';f='ECON';c=450;r=@('taxonomy_scanner');e=@{missed_share_bonus=-0.02}},
    @{k='wave_bringer_2';f='DENS';c=500;r=@('wave_bringer_1');e=@{elite_count=1}},
    @{k='mage_sigil_1_60';f='TEAM';c=760;r=@('flag:mage_unlocked');e=@{mage_damage_mult=0.10}},
    @{k='layered_carapace';f='SURV';c=520;r=@('shock_padding');e=@{armor_general=0.03}},
    @{k='quickstep_chain';f='MOVE';c=520;r=@('route_memory');e=@{move_speed_mult=0.04;target_swap_speed=0.04}},
    @{k='condensed_cores_2_60';f='POWR';c=560;r=@('condensed_cores_60');e=@{power_gain_mult=0.12}},
    @{k='extended_channel_2_60';f='ACTV';c=590;r=@('extended_channel_1_60');e=@{active_duration_all=0.55}},
    @{k='boss_pattern_map';f='BOSS';c=650;r=@('boss_armor_mesh_60');e=@{boss_damage_mult=0.06}},
    @{k='salvage_hooks_2';f='ECON';c=620;r=@('salvage_hooks');e=@{drop_mult=0.06}},
    @{k='front_compression';f='DENS';c=670;r=@('crowd_ecology');e=@{enemy_count_mult=0.07;drop_mult=0.03}},
    @{k='knight_bloodline_2_60';f='TEAM';c=700;r=@('knight_bloodline_1_60');e=@{knight_active_armor=0.06}},
    @{k='dot_deflector';f='SURV';c=730;r=@('hemostasis_mesh');e=@{dot_taken_reduction=0.12}},
    @{k='pathline_sprint';f='MOVE';c=740;r=@('quickstep_chain');e=@{high_hp_speed_mult=0.08}},
    @{k='power_echo';f='POWR';c=780;r=@('condensed_cores_2_60');e=@{power_refund=0.25}},
    @{k='cadence_lock';f='ACTV';c=820;r=@('quick_invocation_2_60');e=@{cooldown_tick_bonus=0.10}},
    @{k='boss_bastion';f='BOSS';c=880;r=@('boss_pattern_map');e=@{boss_armor=0.06}},
    @{k='market_routing';f='ECON';c=930;r=@('collector_drone');e=@{wallet_interest=0.015}},
    @{k='pressure_ladder';f='DENS';c=980;r=@('front_compression');e=@{enemy_count_mult=0.08;drop_per_10kills=0.01}},
    @{k='guardian_bulwark_2_60';f='TEAM';c=1020;r=@('guardian_bulwark_1_60');e=@{boss_ally_armor=0.05}},
    @{k='shock_sink';f='SURV';c=1060;r=@('dot_deflector');e=@{contact_taken_reduction=0.10}},
    @{k='long_march';f='MOVE';c=1120;r=@('pathline_sprint');e=@{move_speed_mult=0.05;hero_collect_bonus=0.08}},
    @{k='power_reservoir_3_60';f='POWR';c=1180;r=@('power_reservoir_2_60');e=@{power_cap_flat=30}},
    @{k='overclock_window';f='ACTV';c=1240;r=@('cadence_lock');e=@{active_duration_all=0.70;cooldown_mult=-0.03}},
    @{k='boss_rend_protocol';f='BOSS';c=1320;r=@('boss_bastion');e=@{boss_hp_reduction=0.08}},
    @{k='archer_drill_2_60';f='TEAM';c=1380;r=@('archer_drill_1_60');e=@{archer_speed_mult=0.10;archer_active_duration=0.50}},
    @{k='mage_sigil_2_60';f='TEAM';c=1460;r=@('mage_sigil_1_60');e=@{mage_damage_mult=0.12;boss_drop_mult=0.05}},
    @{k='run_yield_matrix';f='ECON';c=1540;r=@('market_routing');e=@{reach_reward_mult=0.04;boss_reward_mult=0.08}}
  )

  $res = New-Object System.Collections.Generic.List[object]
  foreach ($d in $defs) {
    $name = ($d.k -replace '_',' ')
    $res.Add((New-Upgrade $d.k $name $d.f $d.c $d.r $d.e 'base60'))
  }
  return $res
}
function Get-ExtraEffect($family, $i) {
  switch ($family) {
    'ECON' {
      switch ($i % 5) {
        0 { return @{ drop_mult=0.018; cursor_value_mult=0.01 } }
        1 { return @{ hero_collect_bonus=0.015; cursor_share_bonus=0.008 } }
        2 { return @{ elite_value_mult=0.018; missed_share_bonus=-0.006 } }
        3 { return @{ drop_mult=0.012; wallet_interest=0.002 } }
        default { return @{ reach_reward_mult=0.01; boss_reward_mult=0.012 } }
      }
    }
    'DENS' {
      switch ($i % 5) {
        0 { return @{ enemy_count_mult=0.018; drop_mult=0.006 } }
        1 { return @{ enemy_count_mult=0.015; elite_count=1 } }
        2 { return @{ enemy_count_mult=0.02 } }
        3 { return @{ enemy_count_mult=0.014; drop_per_10kills=0.003 } }
        default { return @{ enemy_count_mult=0.016; enemy_contact_mult=0.004 } }
      }
    }
    'SURV' {
      switch ($i % 5) {
        0 { return @{ armor_general=0.012 } }
        1 { return @{ dot_taken_reduction=0.016 } }
        2 { return @{ contact_taken_reduction=0.014 } }
        3 { return @{ max_hp_mult=0.015 } }
        default { return @{ early_mitigation=0.02 } }
      }
    }
    'MOVE' {
      switch ($i % 5) {
        0 { return @{ move_speed_mult=0.014 } }
        1 { return @{ target_swap_speed=0.02 } }
        2 { return @{ no_contact_speed_mult=0.02 } }
        3 { return @{ kill_speed_mult=0.02 } }
        default { return @{ high_hp_speed_mult=0.02 } }
      }
    }
    'POWR' {
      switch ($i % 5) {
        0 { return @{ power_gain_mult=0.02 } }
        1 { return @{ power_cap_flat=4 } }
        2 { return @{ power_refund=0.05 } }
        3 { return @{ overflow_drop=0.008 } }
        default { return @{ active_power_eff=0.02 } }
      }
    }
    'ACTV' {
      switch ($i % 5) {
        0 { return @{ active_duration_all=0.18 } }
        1 { return @{ cooldown_mult=-0.015 } }
        2 { return @{ cooldown_tick_bonus=0.03 } }
        3 { return @{ knight_active_duration=0.15; archer_active_duration=0.15 } }
        default { return @{ guardian_active_duration=0.15; mage_active_duration=0.15 } }
      }
    }
    'BOSS' {
      switch ($i % 5) {
        0 { return @{ boss_armor=0.012 } }
        1 { return @{ boss_hp_reduction=0.012 } }
        2 { return @{ boss_contact_reduction=0.015 } }
        3 { return @{ boss_damage_mult=0.015 } }
        default { return @{ boss_drop_mult=0.02 } }
      }
    }
    default {
      switch ($i % 6) {
        0 { return @{ knight_damage_mult=0.018 } }
        1 { return @{ archer_damage_mult=0.02 } }
        2 { return @{ guardian_damage_mult=0.022 } }
        3 { return @{ mage_damage_mult=0.02 } }
        4 { return @{ knight_active_cap=0.03; archer_active_cap=0.03 } }
        default { return @{ guardian_active_cap=0.03; mage_active_cap=0.03 } }
      }
    }
  }
}

function Build-Extra100Upgrades {
  $families = @('ECON','DENS','SURV','MOVE','POWR','ACTV','BOSS','TEAM')
  $a = @('Adaptive','Fractal','Iron','Solar','Echo','Rift','Pulse','Aegis','Vector','Nova')
  $b = @('Circuit','Relay','Ledger','Spine','Burst','Anchor','Lattice','Compass','Engine','Matrix')

  $lastByFamily = @{}
  $res = New-Object System.Collections.Generic.List[object]
  for ($i = 1; $i -le 100; $i++) {
    $family = $families[($i - 1) % $families.Count]
    $key = ('extra_skill_{0:D3}' -f $i)
    $name = ('{0} {1} {2}' -f $a[($i - 1) % $a.Count], $b[($i - 1) % $b.Count], $i)
    $cost = 260.0 + (18.0 * $i) + [math]::Pow($i, 1.08)
    $reqs = New-Object System.Collections.Generic.List[string]
    if ($i -gt 4) { $reqs.Add(('extra_skill_{0:D3}' -f ($i - 3))) | Out-Null }
    if ($lastByFamily.ContainsKey($family)) { $reqs.Add([string]$lastByFamily[$family]) | Out-Null }
    if ($family -eq 'TEAM') {
      if ($i % 3 -eq 0) { $reqs.Add('flag:archer_unlocked') | Out-Null }
      if ($i % 4 -eq 0) { $reqs.Add('flag:guardian_unlocked') | Out-Null }
      if ($i % 5 -eq 0) { $reqs.Add('flag:mage_unlocked') | Out-Null }
    }
    if ($family -eq 'BOSS') { $reqs.Add('flag:boss_seen') | Out-Null }

    $eff = Get-ExtraEffect $family $i
    $res.Add((New-Upgrade $key $name $family $cost $reqs $eff 'extra100'))
    $lastByFamily[$family] = $key
  }
  return $res
}

function Build-Milestones {
  $items = @(
    [pscustomobject]@{ key='cursor_pickup_unlock'; cost=115.0; reqs=@(); effects=@{ cursor_share_bonus=0.03; cursor_value_mult=0.08 } },
    [pscustomobject]@{ key='recruit_archer'; cost=100.0; reqs=@('cursor_pickup_unlock'); effects=@{} },
    [pscustomobject]@{ key='auto_attack_unlock'; cost=70.0; reqs=@('recruit_archer'); effects=@{ auto_attack_flat=5.0 } },
    [pscustomobject]@{ key='knight_vamp_unlock'; cost=320.0; reqs=@('auto_attack_unlock'); effects=@{ knight_vamp_bonus=0.05 } },
    [pscustomobject]@{ key='archer_pierce_unlock'; cost=360.0; reqs=@('recruit_archer'); effects=@{ archer_pierce=0.12 } },
    [pscustomobject]@{ key='power_harvest_unlock'; cost=390.0; reqs=@('recruit_archer'); effects=@{ power_gain_mult=0.08 } },
    [pscustomobject]@{ key='recruit_guardian'; cost=680.0; reqs=@('archer_pierce_unlock'); effects=@{} },
    [pscustomobject]@{ key='guardian_fortify_unlock'; cost=620.0; reqs=@('recruit_guardian'); effects=@{ guardian_active_cap=0.05 } },
    [pscustomobject]@{ key='recruit_mage'; cost=980.0; reqs=@('recruit_guardian','power_harvest_unlock'); effects=@{} },
    [pscustomobject]@{ key='mage_storm_unlock'; cost=880.0; reqs=@('recruit_mage'); effects=@{ mage_active_cap=0.06; mage_damage_mult=0.08 } }
  )
  foreach ($m in $items) { $m.cost = Scale-Cost $m.cost }
  return $items
}

function Build-CoreDefs {
  $items = @(
    [pscustomobject]@{ key='core_knight_damage'; base=68.0; growth=1.11; effect=@{ knight_damage_flat=0.9 } },
    [pscustomobject]@{ key='core_knight_speed'; base=64.0; growth=1.11; effect=@{ knight_speed_mult=0.02 } },
    [pscustomobject]@{ key='core_knight_active_cap'; base=72.0; growth=1.12; effect=@{ knight_active_cap=0.03 } },
    [pscustomobject]@{ key='core_archer_damage'; base=74.0; growth=1.11; effect=@{ archer_damage_flat=0.8 } },
    [pscustomobject]@{ key='core_archer_speed'; base=70.0; growth=1.11; effect=@{ archer_speed_mult=0.02 } },
    [pscustomobject]@{ key='core_archer_active_cap'; base=76.0; growth=1.12; effect=@{ archer_active_cap=0.03 } },
    [pscustomobject]@{ key='core_guardian_damage'; base=84.0; growth=1.12; effect=@{ guardian_damage_flat=0.9 } },
    [pscustomobject]@{ key='core_guardian_speed'; base=82.0; growth=1.12; effect=@{ guardian_speed_mult=0.02 } },
    [pscustomobject]@{ key='core_guardian_active_cap'; base=90.0; growth=1.13; effect=@{ guardian_active_cap=0.03 } },
    [pscustomobject]@{ key='core_mage_damage'; base=92.0; growth=1.12; effect=@{ mage_damage_flat=1.1 } },
    [pscustomobject]@{ key='core_mage_speed'; base=88.0; growth=1.12; effect=@{ mage_speed_mult=0.02 } },
    [pscustomobject]@{ key='core_mage_active_cap'; base=96.0; growth=1.13; effect=@{ mage_active_cap=0.03 } },
    [pscustomobject]@{ key='core_armor'; base=72.0; growth=1.11; effect=@{ armor_general=0.008 } },
    [pscustomobject]@{ key='core_density'; base=80.0; growth=1.12; effect=@{ enemy_count_mult=0.008 } },
    [pscustomobject]@{ key='core_drop'; base=78.0; growth=1.11; effect=@{ drop_mult=0.01 } },
    [pscustomobject]@{ key='core_power'; base=82.0; growth=1.12; effect=@{ power_gain_mult=0.012; power_cap_flat=1.5 } }
  )
  foreach ($c in $items) { $c.base = Scale-Cost $c.base }
  return $items
}
function Milestone-Available($state, $m) {
  if ($state.milestones.Contains($m.key)) { return $false }
  if ($m.cost -gt $state.wallet) { return $false }
  foreach ($r in $m.reqs) {
    if (-not (Has-AnyUpgrade $state $r)) { return $false }
  }
  return $true
}

function Buy-Milestone($state, $milestones) {
  foreach ($m in $milestones) {
    if (-not (Milestone-Available $state $m)) { continue }
    $state.wallet -= [double]$m.cost
    $state.milestones.Add($m.key) | Out-Null
    foreach ($k in $m.effects.Keys) { Add-Effect $state.mods $k $m.effects[$k] }

    if ($m.key -eq 'recruit_archer') { $state.flags.archer_unlocked = $true }
    if ($m.key -eq 'auto_attack_unlock') { $state.flags.auto_attack_unlocked = $true }
    if ($m.key -eq 'recruit_guardian') { $state.flags.guardian_unlocked = $true }
    if ($m.key -eq 'recruit_mage') { $state.flags.mage_unlocked = $true }
    if ($m.key -eq 'knight_vamp_unlock') { $state.flags.knight_active_unlocked = $true }
    if ($m.key -eq 'archer_pierce_unlock') { $state.flags.archer_active_unlocked = $true }
    if ($m.key -eq 'guardian_fortify_unlock') { $state.flags.guardian_active_unlocked = $true }
    if ($m.key -eq 'mage_storm_unlock') { $state.flags.mage_active_unlocked = $true }

    return [pscustomobject]@{ key=$m.key; cost=[double]$m.cost; family='MILESTONE' }
  }
  return $null
}

function Get-CoreCost($def, $level) {
  [double]$def.base * [math]::Pow([double]$def.growth, [double]$level)
}

function Buy-Core($state, $coreDefs) {
  $cands = New-Object System.Collections.Generic.List[object]
  foreach ($d in $coreDefs) {
    $lvl = [int]$state.coreLevels[$d.key]
    $cost = Get-CoreCost $d $lvl
    if ($cost -le $state.wallet) {
      $cands.Add([pscustomobject]@{ def=$d; lvl=$lvl; cost=$cost })
    }
  }
  if ($cands.Count -eq 0) { return $null }
  $pick = $cands | Sort-Object cost, lvl | Select-Object -First 1
  $state.wallet -= [double]$pick.cost
  $state.coreLevels[$pick.def.key] = [int]$state.coreLevels[$pick.def.key] + 1
  foreach ($k in $pick.def.effect.Keys) { Add-Effect $state.mods $k $pick.def.effect[$k] }
  return [pscustomobject]@{ key=$pick.def.key; cost=[double]$pick.cost; family='CORE' }
}

function Buy-FromPool($state, $pool) {
  $avail = @()
  foreach ($u in $pool) {
    if ((Upgrade-Available $state $u) -and ($u.cost -le $state.wallet)) { $avail += $u }
  }
  if ($avail.Count -eq 0) { return $null }
  $pick = $avail | Sort-Object cost, key | Select-Object -First 1
  $state.wallet -= [double]$pick.cost
  Apply-Upgrade $state $pick
  return [pscustomobject]@{ key=$pick.key; cost=[double]$pick.cost; family=$pick.family }
}

function Get-CheapestPoolCandidate($state, $pool) {
  $avail = @()
  foreach ($u in $pool) {
    if ((Upgrade-Available $state $u) -and ($u.cost -le $state.wallet)) { $avail += $u }
  }
  if ($avail.Count -eq 0) { return $null }
  return ($avail | Sort-Object cost, key | Select-Object -First 1)
}

function Get-CheapestCoreCandidate($state, $coreDefs) {
  $cands = New-Object System.Collections.Generic.List[object]
  foreach ($d in $coreDefs) {
    $lvl = [int]$state.coreLevels[$d.key]
    $cost = Get-CoreCost $d $lvl
    if ($cost -le $state.wallet) {
      $cands.Add([pscustomobject]@{ def=$d; lvl=$lvl; cost=$cost })
    }
  }
  if ($cands.Count -eq 0) { return $null }
  return ($cands | Sort-Object cost, lvl | Select-Object -First 1)
}

function Get-LevelParams($level) {
  $i = [math]::Max(0, [int]$level - 1)
  $enemyHp = 52.0 * [math]::Pow(1.18, $i)
  $enemyContact = 8.6 * [math]::Pow(1.19, $i)
  $dot = 2.6 * [math]::Pow(1.14, $i)
  $drop = 26.0 * [math]::Pow(1.35, $i)
  $power = 8.0 * [math]::Pow(1.12, $i)
  $regular = if ($level -eq 1) { 36 } elseif ($level -eq 2) { 40 } elseif ($level -eq 3) { 132 } else { 152 + (28 * ($level - 4)) }
  $bossHp = if ($level -eq 1) { $enemyHp * 22.0 } elseif ($level -eq 2) { $enemyHp * 22.0 } elseif ($level -eq 3) { $enemyHp * 62.0 } else { $enemyHp * (128.0 + 14.0 * ($level - 4)) }
  $bossDps = $enemyContact * 2.7
  $bossDrop = $drop * (90.0 + 16.0 * $level)
  @{
    enemy_hp = $enemyHp
    enemy_contact = $enemyContact
    dot_dps = $dot
    drop = $drop
    power = $power
    regular_count = $regular
    boss_hp = $bossHp
    boss_dps = $bossDps
    boss_drop = $bossDrop
    gap = 2.6
  }
}

function Get-CombatStats($state) {
  $m = $state.mods

  $knightBaseDmg = 8.6 + (Get-Mod $m 'knight_damage_flat' 0)
  $knightAtk = 1.05 * (1.0 + (Get-Mod $m 'knight_speed_mult' 0))
  $knightDps = $knightBaseDmg * $knightAtk * (1.0 + (Get-Mod $m 'knight_damage_mult' 0))

  $archerDps = 0.0
  if ($state.flags.archer_unlocked) {
    $aDmg = 7.8 + (Get-Mod $m 'archer_damage_flat' 0)
    $aAtk = 0.95 * (1.0 + (Get-Mod $m 'archer_speed_mult' 0))
    $archerDps = $aDmg * $aAtk * (1.0 + (Get-Mod $m 'archer_damage_mult' 0))
  }

  $guardianDps = 0.0
  if ($state.flags.guardian_unlocked) {
    $gDmg = 10.2 + (Get-Mod $m 'guardian_damage_flat' 0)
    $gAtk = 0.74 * (1.0 + (Get-Mod $m 'guardian_speed_mult' 0))
    $guardianDps = $gDmg * $gAtk * (1.0 + (Get-Mod $m 'guardian_damage_mult' 0))
  }

  $mageDps = 0.0
  if ($state.flags.mage_unlocked) {
    $mDmg = 11.0 + (Get-Mod $m 'mage_damage_flat' 0)
    $mAtk = 0.80 * (1.0 + (Get-Mod $m 'mage_speed_mult' 0))
    $mageDps = $mDmg * $mAtk * (1.0 + (Get-Mod $m 'mage_damage_mult' 0))
  }

  if ($state.flags.auto_attack_unlocked) {
    $knightDps += (4.0 + (Get-Mod $m 'auto_attack_flat' 0))
  }

  $moveSpeed = 2.35 * (1.0 + (Get-Mod $m 'move_speed_mult' 0))
  $maxHp = 112.0 * (1.0 + (Get-Mod $m 'max_hp_mult' 0))
  $armor = [math]::Min(0.88, (Get-Mod $m 'armor_general' 0))

  $cursorShare = 0.60 + (Get-Mod $m 'cursor_share_bonus' 0)
  $heroShare = 0.30 + (Get-Mod $m 'hero_collect_bonus' 0)
  $missShare = 0.10 + (Get-Mod $m 'missed_share_bonus' 0)
  $sum = $cursorShare + $heroShare + $missShare
  if ($sum -ne 1.0) {
    $cursorShare /= $sum
    $heroShare /= $sum
    $missShare /= $sum
  }

  @{
    knight_dps=$knightDps; archer_dps=$archerDps; guardian_dps=$guardianDps; mage_dps=$mageDps
    total_dps=($knightDps + $archerDps + $guardianDps + $mageDps)
    move_speed=$moveSpeed; max_hp=$maxHp; armor=$armor
    dot_reduction=(Get-Mod $m 'dot_taken_reduction' 0)
    contact_reduction=(Get-Mod $m 'contact_taken_reduction' 0)
    enemy_contact_mult=(1.0 + (Get-Mod $m 'enemy_contact_mult' 0)); enemy_count_mult=(1.0 + (Get-Mod $m 'enemy_count_mult' 0))
    drop_mult=(1.0 + (Get-Mod $m 'drop_mult' 0)); cursor_share=$cursorShare; hero_share=$heroShare; miss_share=$missShare
    cursor_value_mult=(1.0 + (Get-Mod $m 'cursor_value_mult' 0)); elite_count=[int](Get-Mod $m 'elite_count' 0); elite_value_mult=(1.0 + (Get-Mod $m 'elite_value_mult' 0))
    power_gain_mult=(1.0 + (Get-Mod $m 'power_gain_mult' 0)); power_cap=(50.0 + (Get-Mod $m 'power_cap_flat' 0))
    cooldown_mult=[math]::Max(0.55, (1.0 + (Get-Mod $m 'cooldown_mult' 0))); active_duration_all=(1.0 + (Get-Mod $m 'active_duration_all' 0))
    knight_vamp_bonus=(Get-Mod $m 'knight_vamp_bonus' 0); knight_active_armor=(Get-Mod $m 'knight_active_armor' 0)
    archer_pierce=(Get-Mod $m 'archer_pierce' 0); power_refund=(Get-Mod $m 'power_refund' 0); overflow_drop=(Get-Mod $m 'overflow_drop' 0)
    cooldown_tick_bonus=(Get-Mod $m 'cooldown_tick_bonus' 0); boss_armor=(Get-Mod $m 'boss_armor' 0); boss_hp_reduction=(Get-Mod $m 'boss_hp_reduction' 0)
    boss_contact_reduction=(Get-Mod $m 'boss_contact_reduction' 0); boss_damage_mult=(Get-Mod $m 'boss_damage_mult' 0)
    boss_drop_mult=(1.0 + (Get-Mod $m 'boss_drop_mult' 0)); wallet_interest=(Get-Mod $m 'wallet_interest' 0)
    reach_reward_mult=(Get-Mod $m 'reach_reward_mult' 0); boss_reward_mult=(Get-Mod $m 'boss_reward_mult' 0); drop_per_10kills=(Get-Mod $m 'drop_per_10kills' 0)
    target_swap_speed=(Get-Mod $m 'target_swap_speed' 0); no_contact_speed_mult=(Get-Mod $m 'no_contact_speed_mult' 0)
    kill_speed_mult=(Get-Mod $m 'kill_speed_mult' 0); high_hp_speed_mult=(Get-Mod $m 'high_hp_speed_mult' 0); early_mitigation=(Get-Mod $m 'early_mitigation' 0)
    knight_active_cap=(Get-Mod $m 'knight_active_cap' 0); archer_active_cap=(Get-Mod $m 'archer_active_cap' 0); guardian_active_cap=(Get-Mod $m 'guardian_active_cap' 0); mage_active_cap=(Get-Mod $m 'mage_active_cap' 0)
    knight_active_duration=(Get-Mod $m 'knight_active_duration' 0); archer_active_duration=(Get-Mod $m 'archer_active_duration' 0)
    guardian_active_duration=(Get-Mod $m 'guardian_active_duration' 0); mage_active_duration=(Get-Mod $m 'mage_active_duration' 0)
    active_power_eff=(Get-Mod $m 'active_power_eff' 0)
  }
}
function Try-ActivateAbilities($state, $stats, [ref]$abilityUses) {
  $defs = @(
    @{ name='knight'; flag='knight_active_unlocked'; cost=18.0; cd=13.0; dur=4.0 },
    @{ name='archer'; flag='archer_active_unlocked'; cost=22.0; cd=15.0; dur=4.5 },
    @{ name='guardian'; flag='guardian_active_unlocked'; cost=26.0; cd=17.0; dur=5.0 },
    @{ name='mage'; flag='mage_active_unlocked'; cost=30.0; cd=19.0; dur=5.5 }
  )

  foreach ($d in $defs) {
    if (-not $state.flags[$d.flag]) { continue }
    $cdKey = "cd_$($d.name)"
    $actKey = "act_$($d.name)"
    $cap = 1.0 + (Get-Mod $stats "$($d.name)_active_cap" 0)
    $cost = [math]::Max(5.0, $d.cost * (1.0 - $stats.active_power_eff * 0.5))
    if ($state.cooldowns[$cdKey] -le 0.0 -and $state.power -ge $cost) {
      $state.power -= $cost
      $extraDur = Get-Mod $stats "$($d.name)_active_duration" 0
      $state.actives[$actKey] = ($d.dur + $extraDur) * $stats.active_duration_all * (1.0 + 0.5 * $cap)
      $state.cooldowns[$cdKey] = $d.cd * $stats.cooldown_mult
      $abilityUses.Value[$d.name] += 1
      $state.totalActiveCasts += 1
      if ($stats.power_refund -gt 0 -and ($state.totalActiveCasts % 4 -eq 0)) {
        $state.power += $cost * $stats.power_refund
      }
    }
  }
}

function Tick-AbilityTimers($state, $dt, $stats) {
  foreach ($k in @('act_knight','act_archer','act_guardian','act_mage')) {
    $state.actives[$k] = [math]::Max(0.0, $state.actives[$k] - $dt)
  }

  $cdTick = $dt
  $anyActive = ($state.actives['act_knight'] -gt 0 -or $state.actives['act_archer'] -gt 0 -or $state.actives['act_guardian'] -gt 0 -or $state.actives['act_mage'] -gt 0)
  if ($anyActive) { $cdTick *= (1.0 + $stats.cooldown_tick_bonus) }

  foreach ($k in @('cd_knight','cd_archer','cd_guardian','cd_mage')) {
    $state.cooldowns[$k] = [math]::Max(0.0, $state.cooldowns[$k] - $cdTick)
  }
}

function Simulate-CombatCore($state, $level, $runIndex, $difficultyScalar) {
  $lp = Get-LevelParams $level
  $stats = Get-CombatStats $state

  $hp = $stats.max_hp
  $runTime = 8.0
  $maxRunTime = if ($level -ge 3) { 165.0 } else { 145.0 }
  $regularKills = 0
  $bossSegKills = 0
  $currency = 0.0
  $cursor = 0.0
  $hero = 0.0
  $missed = 0.0

  $abilityUses = @{ knight=0; archer=0; guardian=0; mage=0 }

  # Path length to boss is level-defined; density should increase pressure/reward, not move the boss farther away.
  $regularCount = [math]::Max(12, [int][math]::Round($lp.regular_count))
  $densityPressureMult = 1.0 + (($stats.enemy_count_mult - 1.0) * 0.30)
  $densityRewardMult = 1.0 + (($stats.enemy_count_mult - 1.0) * 0.65)
  $eliteCount = [math]::Min($regularCount, $stats.elite_count)

  for ($i = 1; $i -le $regularCount; $i++) {
    if ($runTime -ge $maxRunTime) { break }

    Try-ActivateAbilities $state $stats ([ref]$abilityUses)

    $depthHpMult = (1.0 + 0.028 * $i)
    $depthDmgMult = (1.0 + 0.022 * $i)
    $enemyHp = $lp.enemy_hp * $difficultyScalar * $depthHpMult
    $enemyDps = $lp.enemy_contact * $difficultyScalar * $depthDmgMult * $stats.enemy_contact_mult * $densityPressureMult
    $drop = $lp.drop * (1.0 + 0.012 * $i) * $densityRewardMult

    if ($i -le $eliteCount) {
      $enemyHp *= 1.45
      $enemyDps *= 1.18
      $drop *= (2.2 * $stats.elite_value_mult)
    }

    $speed = $stats.move_speed * (1.0 + $stats.target_swap_speed)
    if ($hp / $stats.max_hp -gt 0.70) { $speed *= (1.0 + $stats.high_hp_speed_mult) }
    $timeToContact = $lp.gap / [math]::Max(0.1, $speed)

    $dps = $stats.total_dps
    if ($state.actives['act_archer'] -gt 0) { $dps += $stats.archer_dps * (0.45 + $stats.archer_pierce) }
    if ($state.actives['act_mage'] -gt 0) { $dps += $stats.mage_dps * 0.90 }
    if ($state.actives['act_guardian'] -gt 0) { $dps += $stats.guardian_dps * 0.35 }

    $ttk = $enemyHp / [math]::Max(0.1, $dps)
    $contactTime = [math]::Max(0.0, $ttk - (0.22 + $stats.no_contact_speed_mult))
    $encTime = $timeToContact + $ttk

    if ($runTime + $encTime -gt $maxRunTime) {
      $encTime = $maxRunTime - $runTime
      if ($encTime -le 0) { break }
      $contactTime = [math]::Min($contactTime, $encTime)
    }

    $armor = $stats.armor
    if ($runTime -lt 8.0) { $armor = [math]::Min(0.92, $armor + $stats.early_mitigation) }
    if ($state.actives['act_guardian'] -gt 0) { $armor = [math]::Min(0.92, $armor + 0.20) }
    if ($state.actives['act_knight'] -gt 0) { $armor = [math]::Min(0.92, $armor + $stats.knight_active_armor) }

    $dotTaken = $lp.dot_dps * $difficultyScalar * $encTime * (1.0 - $armor) * (1.0 - $stats.dot_reduction)
    $contactTaken = $enemyDps * $contactTime * (1.0 - $armor) * (1.0 - $stats.contact_reduction)
    $incoming = $dotTaken + $contactTaken

    $heal = 0.0
    if ($state.actives['act_knight'] -gt 0) {
      $heal = [math]::Min(24.0, $stats.knight_dps * $encTime * (0.17 + $stats.knight_vamp_bonus))
    }

    if ($incoming -ge $hp) {
      $deathFrac = $hp / [math]::Max(0.1, $incoming)
      $partial = $encTime * $deathFrac
      $runTime += $partial
      Tick-AbilityTimers $state $partial $stats
      $hp = 0
      break
    }

    $hp = [math]::Min($stats.max_hp, $hp - $incoming + $heal)
    $runTime += $encTime
    Tick-AbilityTimers $state $encTime $stats

    $regularKills += 1
    $dropMultRuntime = $stats.drop_mult + ($stats.drop_per_10kills * [math]::Floor($regularKills / 10.0)) + $state.runOverflowDrop
    $dropVal = $drop * $dropMultRuntime

    $cursorGain = $dropVal * $stats.cursor_share * $stats.cursor_value_mult
    $heroGain = $dropVal * $stats.hero_share
    $missGain = $dropVal * $stats.miss_share
    $cursor += $cursorGain
    $hero += $heroGain
    $missed += $missGain
    $currency += ($cursorGain + $heroGain)

    $powerGain = $lp.power * $stats.power_gain_mult
    $newPower = $state.power + $powerGain
    if ($newPower -gt $stats.power_cap -and $stats.overflow_drop -gt 0) {
      $overflow = $newPower - $stats.power_cap
      $state.runOverflowDrop = [math]::Min(0.25, $state.runOverflowDrop + ($overflow / 100.0) * $stats.overflow_drop)
    }
    $state.power = [math]::Min($stats.power_cap, $newPower)
  }
  $reachedBoss = ($regularKills -ge $regularCount)
  $bossDefeated = $false

  if ($reachedBoss -and $hp -gt 0 -and $runTime -lt $maxRunTime) {
    $state.flags.boss_seen = $true
    $bossHpTotal = $lp.boss_hp * $difficultyScalar * (1.0 - $stats.boss_hp_reduction)
    $bossSegHp = $bossHpTotal / 8.0
    $bossDps = $lp.boss_dps * $difficultyScalar

    for ($seg = 1; $seg -le 8; $seg++) {
      if ($hp -le 0 -or $runTime -ge $maxRunTime) { break }

      Try-ActivateAbilities $state $stats ([ref]$abilityUses)

      $segRamp = if ($level -ge 3) { 0.07 } else { 0.12 }
      $segHp = $bossSegHp * (1.0 + $segRamp * ($seg - 1))
      $dps = $stats.total_dps * (1.0 + $stats.boss_damage_mult)
      if ($state.actives['act_archer'] -gt 0) { $dps += $stats.archer_dps * (0.55 + $stats.archer_pierce) }
      if ($state.actives['act_mage'] -gt 0) { $dps += $stats.mage_dps * 1.10 }

      $ttk = $segHp / [math]::Max(0.1, $dps)
      if ($runTime + $ttk -gt $maxRunTime) {
        $ttk = $maxRunTime - $runTime
        if ($ttk -le 0) { break }
      }

      $armor = [math]::Min(0.95, $stats.armor + $stats.boss_armor + (Get-Mod $state.mods 'boss_ally_armor' 0))
      if ($state.actives['act_guardian'] -gt 0) { $armor = [math]::Min(0.95, $armor + 0.16) }
      if ($state.actives['act_knight'] -gt 0) { $armor = [math]::Min(0.95, $armor + $stats.knight_active_armor) }

      $incoming = $bossDps * $ttk * (1.0 - $armor) * (1.0 - $stats.boss_contact_reduction)
      if ($incoming -ge $hp) {
        $frac = $hp / [math]::Max(0.1, $incoming)
        $partial = $ttk * $frac
        $runTime += $partial
        Tick-AbilityTimers $state $partial $stats
        $hp = 0
        break
      }

      $runTime += $ttk
      Tick-AbilityTimers $state $ttk $stats

      $bossSegKills += 1
      $portion = ($lp.boss_drop * $stats.boss_drop_mult) / 10.0
      $segReward = if ($seg -lt 8) { $portion } else { $portion * 3.0 }
      $segDrop = $segReward * $stats.drop_mult
      $currency += $segDrop * ($stats.cursor_share + $stats.hero_share)

      $state.power = [math]::Min($stats.power_cap, $state.power + ($lp.power * 2.2))
    }

    if ($bossSegKills -eq 8) { $bossDefeated = $true }
  }

  if ($reachedBoss) { $currency *= (1.0 + $stats.reach_reward_mult) }
  if ($bossDefeated) { $currency *= (1.0 + $stats.boss_reward_mult) }

  [pscustomobject]@{
    level = $level; run_time_s = [math]::Round($runTime, 1); regular_kills = $regularKills; boss_segment_kills = $bossSegKills
    total_kills = ($regularKills + $bossSegKills); reached_boss = $reachedBoss; boss_defeated = $bossDefeated
    earned = [math]::Round($currency, 1); cursor_gain = [math]::Round($cursor, 1); hero_gain = [math]::Round($hero, 1); missed_gain = [math]::Round($missed, 1)
    uses_knight = $abilityUses.knight; uses_archer = $abilityUses.archer; uses_guardian = $abilityUses.guardian; uses_mage = $abilityUses.mage
    dps_knight = [math]::Round($stats.knight_dps, 1); dps_archer = [math]::Round($stats.archer_dps, 1); dps_guardian = [math]::Round($stats.guardian_dps, 1); dps_mage = [math]::Round($stats.mage_dps, 1)
    regular_target = $regularCount; difficulty = [math]::Round($difficultyScalar, 3)
  }
}

function Simulate-RunSmoothed($state, $level, $runIndex, $prevKills) {
  if (-not $state.levelDifficulty.ContainsKey($level)) {
    $state.levelDifficulty[$level] = if ($level -eq 1) { 0.82 } elseif ($level -eq 2) { 0.75 } elseif ($level -eq 3) { 2.72 } else { 3.80 + 0.25 * ($level - 4) }
  }

  $difficulty = [double]$state.levelDifficulty[$level]
  $best = $null
  $bestDifficulty = $difficulty
  $bestScore = 1e9
  $minDelta = 1
  $maxDelta = 3
  $minDifficulty = if ($level -le 2) { 0.25 } elseif ($level -eq 3) { 1.85 } else { 2.40 }
  $maxDifficulty = if ($level -le 2) { 2.50 } else { 6.00 }

  # Snapshot mutable combat state so tuning iterations are apples-to-apples.
  $savedPower = [double]$state.power
  $savedOverflow = [double]$state.runOverflowDrop
  $savedCasts = [int]$state.totalActiveCasts
  $savedBossSeen = [bool]$state.flags.boss_seen
  $savedActives = @{}
  foreach ($k in $state.actives.Keys) { $savedActives[$k] = [double]$state.actives[$k] }
  $savedCooldowns = @{}
  foreach ($k in $state.cooldowns.Keys) { $savedCooldowns[$k] = [double]$state.cooldowns[$k] }

  for ($iter = 1; $iter -le 40; $iter++) {
    $state.power = $savedPower
    $state.runOverflowDrop = $savedOverflow
    $state.totalActiveCasts = $savedCasts
    $state.flags.boss_seen = $savedBossSeen
    foreach ($k in $savedActives.Keys) { $state.actives[$k] = [double]$savedActives[$k] }
    foreach ($k in $savedCooldowns.Keys) { $state.cooldowns[$k] = [double]$savedCooldowns[$k] }

    $trial = Simulate-CombatCore $state $level $runIndex $difficulty
    $score = if ($null -eq $prevKills) { 0.0 } else {
      $d = $trial.total_kills - $prevKills
      if ($d -lt $minDelta) { [math]::Abs($minDelta - $d) + 0.15 } elseif ($d -gt $maxDelta) { [math]::Abs($d - $maxDelta) + 0.15 } else { 0.0 }
    }

    if ($score -lt $bestScore) { $bestScore = $score; $best = $trial; $bestDifficulty = $difficulty }

    if ($null -eq $prevKills) { $best = $trial; $bestDifficulty = $difficulty; break }

    $delta = $trial.total_kills - $prevKills
    if ($delta -ge $minDelta -and $delta -le $maxDelta) { $best = $trial; $bestDifficulty = $difficulty; break }

    if ($delta -lt $minDelta) { $difficulty *= 0.82 } elseif ($delta -gt $maxDelta) { $difficulty *= 1.14 }
    $difficulty = [math]::Max($minDifficulty, [math]::Min($maxDifficulty, $difficulty))
  }

  # Apply the chosen difficulty exactly once to persist only one real run.
  $state.power = $savedPower
  $state.runOverflowDrop = $savedOverflow
  $state.totalActiveCasts = $savedCasts
  $state.flags.boss_seen = $savedBossSeen
  foreach ($k in $savedActives.Keys) { $state.actives[$k] = [double]$savedActives[$k] }
  foreach ($k in $savedCooldowns.Keys) { $state.cooldowns[$k] = [double]$savedCooldowns[$k] }

  $final = Simulate-CombatCore $state $level $runIndex $bestDifficulty
  $state.levelDifficulty[$level] = $bestDifficulty
  return $final
}

function Scale-Cost($cost) {
  return [math]::Round(([double]$cost * $script:COST_SCALE), 1)
}

function Buy-UpgradesForRun($state, $runIndex, $milestones, $baseUpgrades, $extraUpgrades, $coreDefs) {
  $purchases = New-Object System.Collections.Generic.List[object]
  $guard = 0
  while ($guard -lt 200) {
    $guard += 1
    $p = Buy-Milestone $state $milestones
    if ($null -eq $p) {
      $basePick = Get-CheapestPoolCandidate $state $baseUpgrades
      $extraPick = Get-CheapestPoolCandidate $state $extraUpgrades
      $corePick = Get-CheapestCoreCandidate $state $coreDefs
      $cands = @()
      if ($null -ne $basePick) { $cands += [pscustomobject]@{ kind='base'; cost=[double]$basePick.cost } }
      if ($null -ne $extraPick) { $cands += [pscustomobject]@{ kind='extra'; cost=[double]$extraPick.cost } }
      if ($null -ne $corePick) { $cands += [pscustomobject]@{ kind='core'; cost=[double]$corePick.cost } }

      if ($cands.Count -gt 0) {
        $kind = ($cands | Sort-Object cost | Select-Object -First 1).kind
        if ($kind -eq 'base') { $p = Buy-FromPool $state $baseUpgrades }
        elseif ($kind -eq 'extra') { $p = Buy-FromPool $state $extraUpgrades }
        else { $p = Buy-Core $state $coreDefs }
      }
    }

    if ($null -eq $p) { break }

    $purchases.Add($p) | Out-Null
  }

  return $purchases
}
# ------------------- Setup -------------------
$baseUpgrades = Build-Base60Upgrades
$extraUpgrades = Build-Extra100Upgrades
$milestones = Build-Milestones
$coreDefs = Build-CoreDefs

$state = [pscustomobject]@{
  wallet = 0.0
  mods = @{}
  purchased = (New-Object 'System.Collections.Generic.HashSet[string]')
  milestones = (New-Object 'System.Collections.Generic.HashSet[string]')
  coreLevels = @{}
  flags = @{
    archer_unlocked = $false
    guardian_unlocked = $false
    mage_unlocked = $false
    auto_attack_unlocked = $false
    boss_seen = $false
    knight_active_unlocked = $true
    archer_active_unlocked = $false
    guardian_active_unlocked = $false
    mage_active_unlocked = $false
  }
  power = 0.0
  runOverflowDrop = 0.0
  actives = @{ act_knight=0.0; act_archer=0.0; act_guardian=0.0; act_mage=0.0 }
  cooldowns = @{ cd_knight=0.0; cd_archer=0.0; cd_guardian=0.0; cd_mage=0.0 }
  totalActiveCasts = 0
  levelDifficulty = @{}
  purchaseModes = @('base','extra','core','extra','base','core','extra')
  purchaseCursor = 0
  fallbackCost = 10.0
}
foreach ($c in $coreDefs) { $state.coreLevels[$c.key] = 0 }

$runs = New-Object System.Collections.Generic.List[object]
$totalTime = 0.0
$targetTime = 7200.0
$runIndex = 0
$currentLevel = 1
$maxLevel = 1
$prevKills = $null

while ($totalTime -lt $targetTime -and $runIndex -lt 400) {
  $runIndex += 1
  $state.runOverflowDrop = 0.0

  $res = Simulate-RunSmoothed $state $currentLevel $runIndex $prevKills

  $walletBefore = $state.wallet
  $state.wallet += $res.earned

  $purchases = Buy-UpgradesForRun $state $runIndex $milestones $baseUpgrades $extraUpgrades $coreDefs
  $purchaseCost = ($purchases | Measure-Object -Property cost -Sum).Sum
  if ($null -eq $purchaseCost) { $purchaseCost = 0.0 }
  $purchaseNames = [string]::Join('; ', @($purchases | ForEach-Object { $_.key }))

  if ((Get-Mod $state.mods 'wallet_interest' 0) -gt 0) {
    $interest = [math]::Min(1200.0, $state.wallet * (Get-Mod $state.mods 'wallet_interest' 0))
    $state.wallet += $interest
  }

  $deltaKills = if ($null -eq $prevKills) { 0 } else { $res.total_kills - $prevKills }
  $prevKills = $res.total_kills

  $row = [pscustomobject]@{
    run = $runIndex; level = $currentLevel; run_time_s = $res.run_time_s
    total_kills = $res.total_kills; regular_kills = $res.regular_kills; boss_segment_kills = $res.boss_segment_kills; kill_delta = $deltaKills
    reached_boss = $res.reached_boss; boss_defeated = $res.boss_defeated; earned = $res.earned
    wallet_before = [math]::Round($walletBefore, 1); wallet_after_earn = [math]::Round($walletBefore + $res.earned, 1)
    upgrades_bought = $purchaseNames; upgrades_bought_count = $purchases.Count; upgrade_cost = [math]::Round($purchaseCost, 1)
    wallet_after_spend = [math]::Round($state.wallet, 1)
    dps_knight = $res.dps_knight; dps_archer = $res.dps_archer; dps_guardian = $res.dps_guardian; dps_mage = $res.dps_mage
    uses_knight = $res.uses_knight; uses_archer = $res.uses_archer; uses_guardian = $res.uses_guardian; uses_mage = $res.uses_mage
    difficulty = $res.difficulty
  }

  $runs.Add($row) | Out-Null
  $totalTime += $res.run_time_s

  if ($res.boss_defeated) {
    $currentLevel += 1
    $maxLevel = [math]::Max($maxLevel, $currentLevel)
  }
}

$noPurchase = @($runs | Where-Object { $_.upgrades_bought_count -eq 0 }).Count
$bossDefeats = @($runs | Where-Object { $_.boss_defeated }).Count
$minRun = ($runs | Measure-Object -Property run_time_s -Minimum).Minimum
$maxRun = ($runs | Measure-Object -Property run_time_s -Maximum).Maximum

Write-Host '2h Smoothed Simulation Summary'
Write-Host ('total_runs={0}' -f $runs.Count)
Write-Host ('total_time_s={0}' -f [math]::Round($totalTime,1))
Write-Host ('runs_without_purchase={0}' -f $noPurchase)
Write-Host ('min_run_s={0}' -f $minRun)
Write-Host ('max_run_s={0}' -f $maxRun)
Write-Host ('max_level_reached={0}' -f $maxLevel)
Write-Host ('boss_defeats={0}' -f $bossDefeats)

$out = [pscustomobject]@{
  total_time_seconds = [math]::Round($totalTime, 1)
  total_runs = $runs.Count
  runs_without_purchase = $noPurchase
  min_run_seconds = $minRun
  max_run_seconds = $maxRun
  max_level_reached = $maxLevel
  boss_defeats = $bossDefeats
  runs = $runs
}

$jsonPath = 'c:\Godot Projects\FishingIncremental\simulation\simulation_results_2h_60upgrades.json'
($out | ConvertTo-Json -Depth 8) | Set-Content -Path $jsonPath

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# 2-Hour Simulation Run Report (Rebalanced 160 Skills)') | Out-Null
$md.Add('') | Out-Null
$md.Add("Total time: $([math]::Round($totalTime,1)) sec") | Out-Null
$md.Add("Total runs: $($runs.Count)") | Out-Null
$md.Add("Runs without purchase: $noPurchase") | Out-Null
$md.Add("Run time range: $([math]::Round($minRun,1))s to $([math]::Round($maxRun,1))s") | Out-Null
$md.Add("Max level reached: $maxLevel") | Out-Null
$md.Add("Boss defeats: $bossDefeats") | Out-Null
$md.Add('') | Out-Null
$md.Add('| Run | Level | Time (s) | Kills | Delta | Reg Kills | Boss Seg Kills | Reached Boss | Boss Defeated | Earned | Wallet Before | Wallet After Earn | Upgrades Bought | Count | Cost | Wallet After Spend | DPS K/A/G/M | Uses K/A/G/M | Diff |') | Out-Null
$md.Add('|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---|---|---:|') | Out-Null
foreach ($r in $runs) {
  $dps = "$($r.dps_knight)/$($r.dps_archer)/$($r.dps_guardian)/$($r.dps_mage)"
  $uses = "$($r.uses_knight)/$($r.uses_archer)/$($r.uses_guardian)/$($r.uses_mage)"
  $md.Add("| $($r.run) | $($r.level) | $($r.run_time_s) | $($r.total_kills) | $($r.kill_delta) | $($r.regular_kills) | $($r.boss_segment_kills) | $($r.reached_boss) | $($r.boss_defeated) | $($r.earned) | $($r.wallet_before) | $($r.wallet_after_earn) | $($r.upgrades_bought) | $($r.upgrades_bought_count) | $($r.upgrade_cost) | $($r.wallet_after_spend) | $dps | $uses | $($r.difficulty) |") | Out-Null
}
$mdPath = 'c:\Godot Projects\FishingIncremental\simulation\simulation_run_report_2h_60upgrades.md'
$md | Set-Content -Path $mdPath
$price = New-Object System.Collections.Generic.List[string]
$price.Add('# Upgrade Prices In Order (Milestone + Base 60 + Extra 100 + Core)') | Out-Null
$price.Add('') | Out-Null
$price.Add('## Milestones') | Out-Null
$price.Add('| Order | Key | Cost |') | Out-Null
$price.Add('|---:|---|---:|') | Out-Null
for ($i=0; $i -lt $milestones.Count; $i++) {
  $m = $milestones[$i]
  $price.Add("| $($i+1) | $($m.key) | $([math]::Round($m.cost,1)) |") | Out-Null
}

$price.Add('') | Out-Null
$price.Add('## Base 60 Concept Upgrades') | Out-Null
$price.Add('| Order | Key | Family | Cost |') | Out-Null
$price.Add('|---:|---|---|---:|') | Out-Null
for ($i=0; $i -lt $baseUpgrades.Count; $i++) {
  $u = $baseUpgrades[$i]
  $price.Add("| $($i+1) | $($u.key) | $($u.family) | $([math]::Round($u.cost,1)) |") | Out-Null
}

$price.Add('') | Out-Null
$price.Add('## Extra 100 Unique Upgrades') | Out-Null
$price.Add('| Order | Key | Name | Family | Cost |') | Out-Null
$price.Add('|---:|---|---|---|---:|') | Out-Null
for ($i=0; $i -lt $extraUpgrades.Count; $i++) {
  $u = $extraUpgrades[$i]
  $price.Add("| $($i+1) | $($u.key) | $($u.name) | $($u.family) | $([math]::Round($u.cost,1)) |") | Out-Null
}

$price.Add('') | Out-Null
$price.Add('## Core Repeatables') | Out-Null
$price.Add('| Key | Cost Formula |') | Out-Null
$price.Add('|---|---|') | Out-Null
foreach ($c in $coreDefs) {
  $price.Add("| $($c.key) | $([math]::Round($c.base,2)) * ($([math]::Round($c.growth,4)) ^ level) |") | Out-Null
}

$pricePath = 'c:\Godot Projects\FishingIncremental\simulation\upgrade_prices_in_order.md'
$price | Set-Content -Path $pricePath

$ideas = New-Object System.Collections.Generic.List[string]
$ideas.Add('# 100 Additional Unique Upgrade Skills') | Out-Null
$ideas.Add('') | Out-Null
$ideas.Add('| # | Key | Name | Family | Cost | Effect Keys |') | Out-Null
$ideas.Add('|---:|---|---|---|---:|---|') | Out-Null
for ($i=0; $i -lt $extraUpgrades.Count; $i++) {
  $u = $extraUpgrades[$i]
  $effKeys = [string]::Join(', ', @($u.effects.Keys))
  $ideas.Add("| $($i+1) | $($u.key) | $($u.name) | $($u.family) | $([math]::Round($u.cost,1)) | $effKeys |") | Out-Null
}

$ideasPath = 'c:\Godot Projects\FishingIncremental\upgrade_ideas_100.md'
$ideas | Set-Content -Path $ideasPath

Write-Host ('Wrote {0}' -f $jsonPath)
Write-Host ('Wrote {0}' -f $mdPath)
Write-Host ('Wrote {0}' -f $pricePath)
Write-Host ('Wrote {0}' -f $ideasPath)
