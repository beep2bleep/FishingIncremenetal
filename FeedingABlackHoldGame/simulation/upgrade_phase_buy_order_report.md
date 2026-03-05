# Upgrade Buy Order (Early / Mid / Late)

Method: phase-weighted ranking on L1 efficiency, then dependency-chain expansion so the sequence is actually purchasable.

Weights:
- Early: 45% DPS efficiency, 40% coin efficiency, 15% tank efficiency, + unlock bonus.
- Mid: 55% DPS efficiency, 30% coin efficiency, 15% tank efficiency, + smaller unlock bonus.
- Late: 50% DPS efficiency, 35% coin efficiency, 15% tank efficiency, + absolute effect size bonus.

## Early Phase

Budget target: $20000. Planned spend: 10503.2. Picks: 30.

| # | Upgrade key | Cost (L1) | DPS % | Coin % | Tank % | Type | Why |
|---:|---|---:|---:|---:|---:|---|---|
| 1 | cursor_pickup_unlock | 10 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 2 | recruit_archer | 100 | 0.631 | 0 | 0 | Impact | Unlocks Archer hero (major roster DPS increase). |
| 3 | auto_attack_unlock | 70 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 4 | knight_vamp_unlock | 320 | 0.631 | 0 | 1.2 | Impact | Adds Knight active life-steal sustain (18% of dealt damage while active). |
| 5 | salvage_hooks | 182.4 | 0 | 1.26 | 0 | Impact | - |
| 6 | archer_pierce_unlock | 360 | 1.834 | 0 | 0 | Impact | Adds Archer active and +8% Archer damage from _hero_damage_mult(). |
| 7 | power_harvest_unlock | 390 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 8 | trail_boots | 190 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 9 | encroaching_horde | 197.6 | 0 | 1.023 | 0 | Impact | - |
| 10 | reinforced_plates | 212.8 | 0 | 0 | 0.32 | Impact | - |
| 11 | recruit_guardian | 680 | 0.631 | 0 | 0 | Impact | Unlocks Guardian hero (survivability + sustained DPS). |
| 12 | guardian_fortify_unlock | 620 | 0.631 | 0 | 2 | Impact | Adds Guardian shield window via shield_time. |
| 13 | field_magnet | 220.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 14 | condensed_cores_60 | 243.2 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 15 | focused_breathing_60 | 258.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 16 | supply_lenses | 288.8 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 17 | knight_bloodline_1_60 | 319.2 | 0.631 | 0 | 0 | Impact | - |
| 18 | recruit_mage | 980 | 0.631 | 0 | 0 | Impact | Unlocks Mage hero (screen-wide tick damage active + marks). |
| 19 | mage_storm_unlock | 880 | 2.135 | 0 | 0 | Impact | Adds Mage active and +8% Mage damage from _hero_damage_mult(). |
| 20 | stride_rhythm | 319.2 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 21 | wave_bringer_1 | 326.8 | 0 | 1.023 | 0 | Impact | - |
| 22 | impact_weave | 349.6 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 23 | core_knight_speed | 350 | 0.631 | 0 | 0 | Impact | knight attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| 24 | core_knight_damage | 360 | 0.631 | 0 | 0 | Impact | knight direct damage stat +3 per level (from base 12 => +25.0% knight hit damage per level before multipliers). |
| 25 | power_reservoir_1_60 | 364.8 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 26 | core_armor | 370 | 0 | 0 | 0.32 | Impact | Direct incoming-damage factor improved by 3.5% per level (capped by 75% from core_armor path). |
| 27 | core_knight_active_cap | 380 | 0.631 | 0 | 0 | Impact | +10 max power per level via _max_power(). |
| 28 | quick_invocation_1_60 | 380 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 29 | core_archer_speed | 390 | 0.631 | 0 | 0 | Impact | archer attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| 30 | core_drop | 390 | 0 | 4.62 | 0 | Impact | Repeatable: effects stack approximately linearly until internal clamps/caps. |

## Mid Phase

Budget target: $150000. Planned spend: 15513.8. Picks: 32.

| # | Upgrade key | Cost (L1) | DPS % | Coin % | Tank % | Type | Why |
|---:|---|---:|---:|---:|---:|---|---|
| 1 | boss_stance_60 | 334.4 | 0 | 0.84 | 0 | Impact | - |
| 2 | core_archer_damage | 400 | 0.631 | 0 | 0 | Impact | archer direct damage stat +3 per level (from base 12 => +25.0% archer hit damage per level before multipliers). |
| 3 | core_density | 400 | 0 | 2.353 | 0 | Impact | Repeatable: effects stack approximately linearly until internal clamps/caps. |
| 4 | core_power | 410 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 5 | scrap_broker | 410.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 6 | core_archer_active_cap | 420 | 0.631 | 0 | 0 | Impact | +10 max power per level via _max_power(). |
| 7 | extra_skill_001 | 424.1 | 0 | 0.504 | 0 | Impact | - |
| 8 | line_pressure_1 | 433.2 | 0 | 1.023 | 0 | Impact | - |
| 9 | core_guardian_speed | 440 | 0.631 | 0 | 0 | Impact | guardian attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| 10 | boss_readiness_60 | 440.8 | 0 | 0.84 | 0 | Impact | - |
| 11 | momentum_carry | 448.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 12 | core_guardian_damage | 450 | 0.631 | 0 | 0 | Impact | guardian direct damage stat +3 per level (from base 12 => +25.0% guardian hit damage per level before multipliers). |
| 13 | extra_skill_002 | 453.1 | 0 | 0.493 | 0 | Impact | - |
| 14 | hemostasis_mesh | 456 | 0 | 0 | 0.32 | Impact | - |
| 15 | core_guardian_active_cap | 470 | 0.631 | 0 | 0 | Impact | +10 max power per level via _max_power(). |
| 16 | core_mage_speed | 480 | 0.631 | 0 | 0 | Impact | mage attack speed +0.16 per level (from base 1.2 => +13.33% APS per level before multipliers). |
| 17 | extra_skill_003 | 482.3 | 0 | 0 | 0.12 | Impact | - |
| 18 | extended_channel_1_60 | 486.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 19 | core_mage_damage | 490 | 0.631 | 0 | 0 | Impact | mage direct damage stat +3 per level (from base 12 => +25.0% mage hit damage per level before multipliers). |
| 20 | overflow_capture | 501.6 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 21 | core_mage_active_cap | 510 | 0.631 | 0 | 0 | Impact | +10 max power per level via _max_power(). |
| 22 | extra_skill_004 | 511.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 23 | taxonomy_scanner | 516.8 | 0 | 1.26 | 0 | Impact | - |
| 24 | extra_skill_005 | 540.6 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 25 | archer_drill_1_60 | 547.2 | 0.631 | 0 | 0 | Impact | - |
| 26 | route_memory | 547.2 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 27 | boss_fracture_study_60 | 562.4 | 0 | 0.84 | 0 | Impact | - |
| 28 | shock_padding | 562.4 | 0 | 0 | 0.32 | Impact | - |
| 29 | extra_skill_006 | 569.9 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 30 | crowd_ecology | 592.8 | 0 | 1.023 | 0 | Impact | - |
| 31 | extra_skill_007 | 599.2 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 32 | archer_piercing_geometry_60 | 623.2 | 0.631 | 0 | 0 | Impact | - |

## Late Phase

Budget target: No hard budget cap in this pass. Planned spend: 47429.6. Picks: 48.

| # | Upgrade key | Cost (L1) | DPS % | Coin % | Tank % | Type | Why |
|---:|---|---:|---:|---:|---:|---|---|
| 1 | power_reservoir_2_60 | 623.2 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 2 | extra_skill_008 | 628.4 | 0.21 | 0 | 0 | Impact | - |
| 3 | quick_invocation_2_60 | 653.6 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 4 | extra_skill_009 | 657.7 | 0 | 0.504 | 0 | Impact | - |
| 5 | collector_drone | 684 | 0 | 1.26 | 0 | Impact | - |
| 6 | extra_skill_010 | 687.1 | 0 | 0.493 | 0 | Impact | - |
| 7 | boss_armor_mesh_60 | 714.4 | 0 | 0.84 | 0.32 | Impact | - |
| 8 | extra_skill_011 | 716.4 | 0 | 0 | 0.12 | Impact | - |
| 9 | extra_skill_012 | 745.8 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 10 | wave_bringer_2 | 760 | 0 | 1.023 | 0 | Impact | - |
| 11 | extra_skill_013 | 775.1 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 12 | guardian_bulwark_1_60 | 790.4 | 0.631 | 0 | 0 | Impact | - |
| 13 | layered_carapace | 790.4 | 0 | 0 | 0.32 | Impact | - |
| 14 | quickstep_chain | 790.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 15 | extra_skill_014 | 804.5 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 16 | extra_skill_015 | 833.9 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 17 | condensed_cores_2_60 | 851.2 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 18 | extra_skill_016 | 863.3 | 0.21 | 0 | 0 | Impact | - |
| 19 | extra_skill_017 | 892.7 | 0 | 0.504 | 0 | Impact | - |
| 20 | extended_channel_2_60 | 896.8 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 21 | extra_skill_018 | 922.2 | 0 | 0.493 | 0 | Impact | - |
| 22 | salvage_hooks_2 | 942.4 | 0 | 1.26 | 0 | Impact | - |
| 23 | extra_skill_019 | 951.6 | 0 | 0 | 0.12 | Impact | - |
| 24 | extra_skill_020 | 981 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 25 | boss_pattern_map | 988 | 0 | 0.84 | 0 | Impact | - |
| 26 | extra_skill_021 | 1010.5 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 27 | front_compression | 1018.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 28 | extra_skill_022 | 1039.9 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 29 | knight_bloodline_2_60 | 1064 | 0.631 | 0 | 0 | Impact | - |
| 30 | extra_skill_023 | 1069.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 31 | extra_skill_024 | 1098.9 | 0.21 | 0 | 0 | Impact | - |
| 32 | dot_deflector | 1109.6 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 33 | pathline_sprint | 1124.8 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 34 | extra_skill_025 | 1128.4 | 0 | 0.504 | 0 | Impact | - |
| 35 | mage_sigil_1_60 | 1155.2 | 0.631 | 0 | 0 | Impact | - |
| 36 | extra_skill_026 | 1157.8 | 0 | 0.493 | 0 | Impact | - |
| 37 | power_echo | 1185.6 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 38 | extra_skill_027 | 1187.3 | 0 | 0 | 0.12 | Impact | - |
| 39 | extra_skill_028 | 1216.8 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 40 | extra_skill_029 | 1246.3 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 41 | cadence_lock | 1246.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 42 | extra_skill_030 | 1275.9 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 43 | extra_skill_031 | 1305.4 | 0 | 0 | 0 | Bridge | Dependency bridge (pathing/QoL/utility prerequisite). |
| 44 | extra_skill_032 | 1334.9 | 0.21 | 0 | 0 | Impact | - |
| 45 | boss_bastion | 1337.6 | 0 | 0.84 | 0 | Impact | - |
| 46 | extra_skill_033 | 1364.4 | 0 | 0.504 | 0 | Impact | - |
| 47 | extra_skill_034 | 1394 | 0 | 0.493 | 0 | Impact | - |
| 48 | market_routing | 1413.6 | 0 | 1.26 | 0 | Impact | - |

## Practical usage
- Buy in order within each phase; stop a phase early if your run already reaches your target comfortably.
- If dying before wave clear, pull `guardian_fortify_unlock`, `core_armor`, and `reinforced_plates` earlier by several slots.
- If clears are stable but run value is low, pull coin upgrades (`core_drop`, `core_density`, `salvage_hooks`) earlier.
