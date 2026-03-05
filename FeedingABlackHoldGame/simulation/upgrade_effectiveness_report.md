# Fishing Upgrade Effectiveness Report

Generated: 2026-03-05 14:25:08

Method:
- Source of upgrade keys/levels: `Data/FishingUpgradeData.json`.
- Effect formulas: `Fishing/BattleScene.gd` (`_apply_upgrade_key_modifiers`, `_apply_extra_skill_family_bonus`, and `_rebuild_battle_mods` tuning pass).
- Metrics are modeled as isolated impact of each key at L1 and at that key's max level in data.
- `run_coin_pct` is estimated as `(coin_mult * enemy_count_mult - 1)` because both increase expected coin per run.
- Unlock-only upgrades can have major practical impact that exceeds these scalar metrics; see `notes`.

## Top 15 by Global DPS (at max level)

| Key | Max Lvl | DPS % | Notes |
|---|---:|---:|---|
| core_knight_damage | 8 | 5.102 | knight direct damage stat +3 per level (from base 12 => +25.0% knight hit damage per level before multipliers). |
| core_knight_speed | 8 | 5.102 | knight attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| core_knight_active_cap | 8 | 5.102 | +10 max power per level via _max_power(). |
| core_archer_damage | 8 | 5.102 | archer direct damage stat +3 per level (from base 12 => +25.0% archer hit damage per level before multipliers). |
| core_archer_speed | 8 | 5.102 | archer attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| core_guardian_active_cap | 7 | 4.458 | +10 max power per level via _max_power(). |
| core_mage_damage | 7 | 4.458 | mage direct damage stat +3 per level (from base 12 => +25.0% mage hit damage per level before multipliers). |
| core_guardian_damage | 7 | 4.458 | guardian direct damage stat +3 per level (from base 12 => +25.0% guardian hit damage per level before multipliers). |
| core_guardian_speed | 7 | 4.458 | guardian attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| core_archer_active_cap | 7 | 4.458 | +10 max power per level via _max_power(). |
| core_mage_speed | 7 | 4.458 | mage attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| core_mage_active_cap | 6 | 3.815 | +10 max power per level via _max_power(). |
| mage_storm_unlock | 1 | 2.135 | Adds Mage active and +8% Mage damage from _hero_damage_mult(). |
| archer_pierce_unlock | 1 | 1.834 | Adds Archer active and +8% Archer damage from _hero_damage_mult(). |
| guardian_fortify_unlock | 1 | 0.631 | Adds Guardian shield window via shield_time. |

## Top 15 by Run Coin Gain (at max level)

| Key | Max Lvl | Run Coin % | Notes |
|---|---:|---:|---|
| core_drop | 8 | 36.96 | Repeatable: effects stack approximately linearly until internal clamps/caps. |
| core_density | 7 | 16.997 | Repeatable: effects stack approximately linearly until internal clamps/caps. |
| salvage_hooks | 1 | 1.26 |  |
| collector_drone | 1 | 1.26 |  |
| taxonomy_scanner | 1 | 1.26 |  |
| market_routing | 1 | 1.26 |  |
| salvage_hooks_2 | 1 | 1.26 |  |
| line_pressure_1 | 1 | 1.023 |  |
| encroaching_horde | 1 | 1.023 |  |
| crowd_ecology | 1 | 1.023 |  |
| pressure_ladder | 1 | 1.023 |  |
| wave_bringer_2 | 1 | 1.023 |  |
| wave_bringer_1 | 1 | 1.023 |  |
| boss_pattern_map | 1 | 0.84 |  |
| boss_fracture_study_60 | 1 | 0.84 |  |

## Top 15 by Incoming Damage Reduction (at max level)

| Key | Max Lvl | Incoming Damage Reduction % | Notes |
|---|---:|---:|---|
| core_armor | 8 | 2.56 | Direct incoming-damage factor improved by 3.5% per level (capped by 75% from core_armor path). |
| guardian_fortify_unlock | 1 | 2 | Adds Guardian shield window via shield_time. |
| knight_vamp_unlock | 1 | 1.2 | Adds Knight active life-steal sustain (18% of dealt damage while active). |
| reinforced_plates | 1 | 0.32 |  |
| hemostasis_mesh | 1 | 0.32 |  |
| shock_padding | 1 | 0.32 |  |
| boss_armor_mesh_60 | 1 | 0.32 |  |
| shock_sink | 1 | 0.32 |  |
| layered_carapace | 1 | 0.32 |  |
| extra_skill_067 | 1 | 0.12 |  |
| extra_skill_027 | 1 | 0.12 |  |
| extra_skill_083 | 1 | 0.12 |  |
| extra_skill_003 | 1 | 0.12 |  |
| extra_skill_075 | 1 | 0.12 |  |
| extra_skill_043 | 1 | 0.12 |  |

## Full Upgrade Table (all keys)

| Key | Max Lvl | DPS% L1 | DPS% Max | DamageTakenRed% L1 | DamageTakenRed% Max | RunCoin% L1 | RunCoin% Max | Notes |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| archer_drill_1_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| archer_drill_2_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| archer_pierce_unlock | 1 | 1.834 | 1.834 | 0 | 0 | 0 | 0 | Adds Archer active and +8% Archer damage from _hero_damage_mult(). |
| archer_piercing_geometry_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| auto_attack_unlock | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| battle_speed_unlock | 3 | 0 | 0 | 0 | 0 | 0 | 0 | QoL speed control only; no direct combat stat change. |
| boss_armor_mesh_60 | 1 | 0 | 0 | 0.32 | 0.32 | 0.84 | 0.84 |  |
| boss_bastion | 1 | 0 | 0 | 0 | 0 | 0.84 | 0.84 |  |
| boss_fracture_study_60 | 1 | 0 | 0 | 0 | 0 | 0.84 | 0.84 |  |
| boss_pattern_map | 1 | 0 | 0 | 0 | 0 | 0.84 | 0.84 |  |
| boss_readiness_60 | 1 | 0 | 0 | 0 | 0 | 0.84 | 0.84 |  |
| boss_rend_protocol | 1 | 0 | 0 | 0 | 0 | 0.84 | 0.84 |  |
| boss_stance_60 | 1 | 0 | 0 | 0 | 0 | 0.84 | 0.84 |  |
| cadence_lock | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| collector_drone | 1 | 0 | 0 | 0 | 0 | 1.26 | 1.26 |  |
| condensed_cores_2_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| condensed_cores_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| core_archer_active_cap | 7 | 0.631 | 4.458 | 0 | 0 | 0 | 0 | +10 max power per level via _max_power(). |
| core_archer_damage | 8 | 0.631 | 5.102 | 0 | 0 | 0 | 0 | archer direct damage stat +3 per level (from base 12 => +25.0% archer hit damage per level before multipliers). |
| core_archer_speed | 8 | 0.631 | 5.102 | 0 | 0 | 0 | 0 | archer attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| core_armor | 8 | 0 | 0 | 0.32 | 2.56 | 0 | 0 | Direct incoming-damage factor improved by 3.5% per level (capped by 75% from core_armor path). |
| core_density | 7 | 0 | 0 | 0 | 0 | 2.353 | 16.997 | Repeatable: effects stack approximately linearly until internal clamps/caps. |
| core_drop | 8 | 0 | 0 | 0 | 0 | 4.62 | 36.96 | Repeatable: effects stack approximately linearly until internal clamps/caps. |
| core_guardian_active_cap | 7 | 0.631 | 4.458 | 0 | 0 | 0 | 0 | +10 max power per level via _max_power(). |
| core_guardian_damage | 7 | 0.631 | 4.458 | 0 | 0 | 0 | 0 | guardian direct damage stat +3 per level (from base 12 => +25.0% guardian hit damage per level before multipliers). |
| core_guardian_speed | 7 | 0.631 | 4.458 | 0 | 0 | 0 | 0 | guardian attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| core_knight_active_cap | 8 | 0.631 | 5.102 | 0 | 0 | 0 | 0 | +10 max power per level via _max_power(). |
| core_knight_damage | 8 | 0.631 | 5.102 | 0 | 0 | 0 | 0 | knight direct damage stat +3 per level (from base 12 => +25.0% knight hit damage per level before multipliers). |
| core_knight_speed | 8 | 0.631 | 5.102 | 0 | 0 | 0 | 0 | knight attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| core_mage_active_cap | 6 | 0.631 | 3.815 | 0 | 0 | 0 | 0 | +10 max power per level via _max_power(). |
| core_mage_damage | 7 | 0.631 | 4.458 | 0 | 0 | 0 | 0 | mage direct damage stat +3 per level (from base 12 => +25.0% mage hit damage per level before multipliers). |
| core_mage_speed | 7 | 0.631 | 4.458 | 0 | 0 | 0 | 0 | mage attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| core_power | 7 | 0 | 0 | 0 | 0 | 0 | 0 | Repeatable: effects stack approximately linearly until internal clamps/caps. |
| crowd_ecology | 1 | 0 | 0 | 0 | 0 | 1.023 | 1.023 |  |
| cursor_pickup_unlock | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| dot_deflector | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| encroaching_horde | 1 | 0 | 0 | 0 | 0 | 1.023 | 1.023 |  |
| extended_channel_1_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extended_channel_2_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_001 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_002 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_003 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_004 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_005 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_006 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_007 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_008 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_009 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_010 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_011 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_012 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_013 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_014 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_015 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_016 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_017 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_018 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_019 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_020 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_021 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_022 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_023 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_024 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_025 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_026 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_027 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_028 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_029 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_030 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_031 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_032 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_033 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_034 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_035 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_036 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_037 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_038 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_039 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_040 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_041 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_042 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_043 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_044 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_045 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_046 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_047 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_048 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_049 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_050 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_051 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_052 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_053 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_054 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_055 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_056 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_057 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_058 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_059 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_060 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_061 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_062 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_063 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_064 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_065 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_066 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_067 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_068 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_069 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_070 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_071 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_072 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_073 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_074 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_075 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_076 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_077 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_078 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_079 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_080 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_081 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_082 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_083 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_084 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_085 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_086 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_087 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_088 | 1 | 0.21 | 0.21 | 0 | 0 | 0 | 0 |  |
| extra_skill_089 | 1 | 0 | 0 | 0 | 0 | 0.504 | 0.504 |  |
| extra_skill_090 | 1 | 0 | 0 | 0 | 0 | 0.493 | 0.493 |  |
| extra_skill_091 | 1 | 0 | 0 | 0.12 | 0.12 | 0 | 0 |  |
| extra_skill_092 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_093 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| extra_skill_094 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| field_magnet | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| focused_breathing_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| front_compression | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| guardian_bulwark_1_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| guardian_bulwark_2_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| guardian_fortify_unlock | 1 | 0.631 | 0.631 | 2 | 2 | 0 | 0 | Adds Guardian shield window via shield_time. |
| hemostasis_mesh | 1 | 0 | 0 | 0.32 | 0.32 | 0 | 0 |  |
| impact_weave | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| knight_bloodline_1_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| knight_bloodline_2_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| knight_vamp_unlock | 1 | 0.631 | 0.631 | 1.2 | 1.2 | 0 | 0 | Adds Knight active life-steal sustain (18% of dealt damage while active). |
| layered_carapace | 1 | 0 | 0 | 0.32 | 0.32 | 0 | 0 |  |
| line_pressure_1 | 1 | 0 | 0 | 0 | 0 | 1.023 | 1.023 |  |
| long_march | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| mage_sigil_1_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| mage_sigil_2_60 | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 |  |
| mage_storm_unlock | 1 | 2.135 | 2.135 | 0 | 0 | 0 | 0 | Adds Mage active and +8% Mage damage from _hero_damage_mult(). |
| market_routing | 1 | 0 | 0 | 0 | 0 | 1.26 | 1.26 |  |
| momentum_carry | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| overclock_window | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| overflow_capture | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| pathline_sprint | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| power_echo | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| power_harvest_unlock | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| power_reservoir_1_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| power_reservoir_2_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| power_reservoir_3_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| pressure_ladder | 1 | 0 | 0 | 0 | 0 | 1.023 | 1.023 |  |
| quick_invocation_1_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| quick_invocation_2_60 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| quickstep_chain | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| recruit_archer | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 | Unlocks Archer hero (major roster DPS increase). |
| recruit_guardian | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 | Unlocks Guardian hero (survivability + sustained DPS). |
| recruit_mage | 1 | 0.631 | 0.631 | 0 | 0 | 0 | 0 | Unlocks Mage hero (screen-wide tick damage active + marks). |
| reinforced_plates | 1 | 0 | 0 | 0.32 | 0.32 | 0 | 0 |  |
| route_memory | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| run_yield_matrix | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| salvage_hooks | 1 | 0 | 0 | 0 | 0 | 1.26 | 1.26 |  |
| salvage_hooks_2 | 1 | 0 | 0 | 0 | 0 | 1.26 | 1.26 |  |
| scrap_broker | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| shock_padding | 1 | 0 | 0 | 0.32 | 0.32 | 0 | 0 |  |
| shock_sink | 1 | 0 | 0 | 0.32 | 0.32 | 0 | 0 |  |
| stride_rhythm | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| supply_lenses | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| taxonomy_scanner | 1 | 0 | 0 | 0 | 0 | 1.26 | 1.26 |  |
| trail_boots | 1 | 0 | 0 | 0 | 0 | 0 | 0 |  |
| wave_bringer_1 | 1 | 0 | 0 | 0 | 0 | 1.023 | 1.023 |  |
| wave_bringer_2 | 1 | 0 | 0 | 0 | 0 | 1.023 | 1.023 |  |
