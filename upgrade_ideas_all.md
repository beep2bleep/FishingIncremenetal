# All Upgrade Ideas And Expected Prices

Naming note: extra skills are renamed from `extra_skill_xxx` to snake_case variable names. Numeric suffix appears only for repeated variants (`name_2`, `name_3`, etc.).

## Milestones
| var_name | source_key | family | expected_price | prereqs | description | effect |
|---|---|---|---:|---|---|---|
| archer_pierce_unlock | archer_pierce_unlock | MILESTONE | 126 | recruit_archer | Unlocks major systems, heroes, or active abilities. | archer_pierce=0.12 |
| auto_attack_unlock | auto_attack_unlock | MILESTONE | 105 | recruit_archer | Unlocks major systems, heroes, or active abilities. | auto_attack_flat=5 |
| guardian_fortify_unlock | guardian_fortify_unlock | MILESTONE | 217 | recruit_guardian | Unlocks major systems, heroes, or active abilities. | guardian_active_cap=0.05 |
| knight_vamp_unlock | knight_vamp_unlock | MILESTONE | 112 | auto_attack_unlock | Unlocks major systems, heroes, or active abilities. | knight_vamp_bonus=0.05 |
| mage_storm_unlock | mage_storm_unlock | MILESTONE | 308 | recruit_mage | Unlocks major systems, heroes, or active abilities. | mage_active_cap=0.06; mage_damage_mult=0.08 |
| power_harvest_unlock | power_harvest_unlock | MILESTONE | 136.5 | recruit_archer | Unlocks major systems, heroes, or active abilities. | power_gain_mult=0.08 |
| recruit_archer | recruit_archer | MILESTONE | 98 | - | Unlocks major systems, heroes, or active abilities. | No direct stat modifier; unlocks system progression. |
| recruit_guardian | recruit_guardian | MILESTONE | 238 | archer_pierce_unlock | Unlocks major systems, heroes, or active abilities. | No direct stat modifier; unlocks system progression. |
| recruit_mage | recruit_mage | MILESTONE | 343 | recruit_guardian, power_harvest_unlock | Unlocks major systems, heroes, or active abilities. | No direct stat modifier; unlocks system progression. |

## Core
| var_name | source_key | family | expected_price | prereqs | description | effect |
|---|---|---|---:|---|---|---|
| core_archer_active_cap | core_archer_active_cap | CORE | 26.6 * (1.12 ^ level) | - | Repeatable baseline scaling upgrades. | archer_active_cap=0.03 |
| core_archer_damage | core_archer_damage | CORE | 25.9 * (1.11 ^ level) | - | Repeatable baseline scaling upgrades. | archer_damage_flat=0.8 |
| core_archer_speed | core_archer_speed | CORE | 24.5 * (1.11 ^ level) | - | Repeatable baseline scaling upgrades. | archer_speed_mult=0.02 |
| core_armor | core_armor | CORE | 25.2 * (1.11 ^ level) | - | Repeatable baseline scaling upgrades. | armor_general=0.008 |
| core_density | core_density | CORE | 28 * (1.12 ^ level) | - | Repeatable baseline scaling upgrades. | enemy_count_mult=0.008 |
| core_drop | core_drop | CORE | 27.3 * (1.11 ^ level) | - | Repeatable baseline scaling upgrades. | drop_mult=0.01 |
| core_guardian_active_cap | core_guardian_active_cap | CORE | 31.5 * (1.13 ^ level) | - | Repeatable baseline scaling upgrades. | guardian_active_cap=0.03 |
| core_guardian_damage | core_guardian_damage | CORE | 29.4 * (1.12 ^ level) | - | Repeatable baseline scaling upgrades. | guardian_damage_flat=0.9 |
| core_guardian_speed | core_guardian_speed | CORE | 28.7 * (1.12 ^ level) | - | Repeatable baseline scaling upgrades. | guardian_speed_mult=0.02 |
| core_knight_active_cap | core_knight_active_cap | CORE | 25.2 * (1.12 ^ level) | - | Repeatable baseline scaling upgrades. | knight_active_cap=0.03 |
| core_knight_damage | core_knight_damage | CORE | 23.8 * (1.11 ^ level) | - | Repeatable baseline scaling upgrades. | knight_damage_flat=0.9 |
| core_knight_speed | core_knight_speed | CORE | 22.4 * (1.11 ^ level) | - | Repeatable baseline scaling upgrades. | knight_speed_mult=0.02 |
| core_mage_active_cap | core_mage_active_cap | CORE | 33.6 * (1.13 ^ level) | - | Repeatable baseline scaling upgrades. | mage_active_cap=0.03 |
| core_mage_damage | core_mage_damage | CORE | 32.2 * (1.12 ^ level) | - | Repeatable baseline scaling upgrades. | mage_damage_flat=1.1 |
| core_mage_speed | core_mage_speed | CORE | 30.8 * (1.12 ^ level) | - | Repeatable baseline scaling upgrades. | mage_speed_mult=0.02 |
| core_power | core_power | CORE | 28.7 * (1.12 ^ level) | - | Repeatable baseline scaling upgrades. | power_cap_flat=1.5; power_gain_mult=0.012 |

## Base 60
| var_name | source_key | family | expected_price | prereqs | description | effect |
|---|---|---|---:|---|---|---|
| archer_drill_1_60 | archer_drill_1_60 | TEAM | 126 | flag:archer_unlocked | Improves hero-specific combat synergy. | archer_speed_mult=0.08 |
| archer_drill_2_60 | archer_drill_2_60 | TEAM | 483 | archer_drill_1_60 | Improves hero-specific combat synergy. | archer_active_duration=0.5; archer_speed_mult=0.1 |
| archer_piercing_geometry_60 | archer_piercing_geometry_60 | TEAM | 143.5 | flag:archer_unlocked | Improves hero-specific combat synergy. | archer_pierce=0.18 |
| boss_armor_mesh_60 | boss_armor_mesh_60 | BOSS | 164.5 | boss_fracture_study_60 | Improves boss phase output/safety/reward. | boss_armor=0.05 |
| boss_bastion | boss_bastion | BOSS | 308 | boss_pattern_map | Improves boss phase output/safety/reward. | boss_armor=0.06 |
| boss_fracture_study_60 | boss_fracture_study_60 | BOSS | 129.5 | boss_readiness_60 | Improves boss phase output/safety/reward. | boss_hp_reduction=0.05 |
| boss_pattern_map | boss_pattern_map | BOSS | 227.5 | boss_armor_mesh_60 | Improves boss phase output/safety/reward. | boss_damage_mult=0.06 |
| boss_readiness_60 | boss_readiness_60 | BOSS | 101.5 | boss_stance_60 | Improves boss phase output/safety/reward. | boss_contact_reduction=0.08 |
| boss_rend_protocol | boss_rend_protocol | BOSS | 462 | boss_bastion | Improves boss phase output/safety/reward. | boss_hp_reduction=0.08 |
| boss_stance_60 | boss_stance_60 | BOSS | 77 | flag:boss_seen | Improves boss phase output/safety/reward. | boss_armor=0.04 |
| cadence_lock | cadence_lock | ACTV | 287 | quick_invocation_2_60 | Improves active ability uptime. | cooldown_tick_bonus=0.1 |
| collector_drone | collector_drone | ECON | 157.5 | taxonomy_scanner | Improves income conversion and pickup efficiency. | missed_share_bonus=-0.02 |
| condensed_cores_2_60 | condensed_cores_2_60 | POWR | 196 | condensed_cores_60 | Improves power economy for actives. | power_gain_mult=0.12 |
| condensed_cores_60 | condensed_cores_60 | POWR | 56 | - | Improves power economy for actives. | power_gain_mult=0.1 |
| crowd_ecology | crowd_ecology | DENS | 136.5 | line_pressure_1 | Increases enemy pressure to raise total reward ceiling. | enemy_contact_mult=0.02; enemy_count_mult=0.06 |
| dot_deflector | dot_deflector | SURV | 255.5 | hemostasis_mesh | Improves survivability and run depth. | dot_taken_reduction=0.12 |
| encroaching_horde | encroaching_horde | DENS | 45.5 | - | Increases enemy pressure to raise total reward ceiling. | enemy_count_mult=0.04 |
| extended_channel_1_60 | extended_channel_1_60 | ACTV | 112 | quick_invocation_1_60 | Improves active ability uptime. | active_duration_all=0.45 |
| extended_channel_2_60 | extended_channel_2_60 | ACTV | 206.5 | extended_channel_1_60 | Improves active ability uptime. | active_duration_all=0.55 |
| field_magnet | field_magnet | ECON | 50.8 | salvage_hooks | Improves income conversion and pickup efficiency. | hero_collect_bonus=0.02 |
| focused_breathing_60 | focused_breathing_60 | ACTV | 59.5 | - | Improves active ability uptime. | active_duration_all=0.35 |
| front_compression | front_compression | DENS | 234.5 | crowd_ecology | Increases enemy pressure to raise total reward ceiling. | drop_mult=0.03; enemy_count_mult=0.07 |
| guardian_bulwark_1_60 | guardian_bulwark_1_60 | TEAM | 182 | flag:guardian_unlocked | Improves hero-specific combat synergy. | max_hp_mult=0.04 |
| guardian_bulwark_2_60 | guardian_bulwark_2_60 | TEAM | 357 | guardian_bulwark_1_60 | Improves hero-specific combat synergy. | boss_ally_armor=0.05 |
| hemostasis_mesh | hemostasis_mesh | SURV | 105 | impact_weave | Improves survivability and run depth. | dot_taken_reduction=0.1 |
| impact_weave | impact_weave | SURV | 80.5 | reinforced_plates | Improves survivability and run depth. | contact_taken_reduction=0.06 |
| knight_bloodline_1_60 | knight_bloodline_1_60 | TEAM | 73.5 | - | Improves hero-specific combat synergy. | knight_vamp_bonus=0.06 |
| knight_bloodline_2_60 | knight_bloodline_2_60 | TEAM | 245 | knight_bloodline_1_60 | Improves hero-specific combat synergy. | knight_active_armor=0.06 |
| layered_carapace | layered_carapace | SURV | 182 | shock_padding | Improves survivability and run depth. | armor_general=0.03 |
| line_pressure_1 | line_pressure_1 | DENS | 99.8 | wave_bringer_1 | Increases enemy pressure to raise total reward ceiling. | drop_mult=0.02; enemy_count_mult=0.05 |
| long_march | long_march | MOVE | 392 | pathline_sprint | Improves traversal tempo. | hero_collect_bonus=0.08; move_speed_mult=0.05 |
| mage_sigil_1_60 | mage_sigil_1_60 | TEAM | 266 | flag:mage_unlocked | Improves hero-specific combat synergy. | mage_damage_mult=0.1 |
| mage_sigil_2_60 | mage_sigil_2_60 | TEAM | 511 | mage_sigil_1_60 | Improves hero-specific combat synergy. | boss_drop_mult=0.05; mage_damage_mult=0.12 |
| market_routing | market_routing | ECON | 325.5 | collector_drone | Improves income conversion and pickup efficiency. | wallet_interest=0.015 |
| momentum_carry | momentum_carry | MOVE | 103.2 | stride_rhythm | Improves traversal tempo. | no_contact_speed_mult=0.05 |
| overclock_window | overclock_window | ACTV | 434 | cadence_lock | Improves active ability uptime. | active_duration_all=0.7; cooldown_mult=-0.03 |
| overflow_capture | overflow_capture | POWR | 115.5 | power_reservoir_1_60 | Improves power economy for actives. | overflow_drop=0.02 |
| pathline_sprint | pathline_sprint | MOVE | 259 | quickstep_chain | Improves traversal tempo. | high_hp_speed_mult=0.08 |
| power_echo | power_echo | POWR | 273 | condensed_cores_2_60 | Improves power economy for actives. | power_refund=0.25 |
| power_reservoir_1_60 | power_reservoir_1_60 | POWR | 84 | condensed_cores_60 | Improves power economy for actives. | power_cap_flat=12 |
| power_reservoir_2_60 | power_reservoir_2_60 | POWR | 143.5 | power_reservoir_1_60 | Improves power economy for actives. | power_cap_flat=20 |
| power_reservoir_3_60 | power_reservoir_3_60 | POWR | 413 | power_reservoir_2_60 | Improves power economy for actives. | power_cap_flat=30 |
| pressure_ladder | pressure_ladder | DENS | 343 | front_compression | Increases enemy pressure to raise total reward ceiling. | drop_per_10kills=0.01; enemy_count_mult=0.08 |
| quick_invocation_1_60 | quick_invocation_1_60 | ACTV | 87.5 | focused_breathing_60 | Improves active ability uptime. | cooldown_mult=-0.04 |
| quick_invocation_2_60 | quick_invocation_2_60 | ACTV | 150.5 | quick_invocation_1_60 | Improves active ability uptime. | cooldown_mult=-0.05 |
| quickstep_chain | quickstep_chain | MOVE | 182 | route_memory | Improves traversal tempo. | move_speed_mult=0.04; target_swap_speed=0.04 |
| reinforced_plates | reinforced_plates | SURV | 49 | - | Improves survivability and run depth. | armor_general=0.03 |
| route_memory | route_memory | MOVE | 126 | momentum_carry | Improves traversal tempo. | kill_speed_mult=0.06 |
| run_yield_matrix | run_yield_matrix | ECON | 539 | market_routing | Improves income conversion and pickup efficiency. | boss_reward_mult=0.08; reach_reward_mult=0.04 |
| salvage_hooks | salvage_hooks | ECON | 42 | - | Improves income conversion and pickup efficiency. | drop_mult=0.05 |
| salvage_hooks_2 | salvage_hooks_2 | ECON | 217 | salvage_hooks | Improves income conversion and pickup efficiency. | drop_mult=0.06 |
| scrap_broker | scrap_broker | ECON | 94.5 | supply_lenses | Improves income conversion and pickup efficiency. | cursor_value_mult=0.07 |
| shock_padding | shock_padding | SURV | 129.5 | hemostasis_mesh | Improves survivability and run depth. | early_mitigation=0.08 |
| shock_sink | shock_sink | SURV | 371 | dot_deflector | Improves survivability and run depth. | contact_taken_reduction=0.1 |
| stride_rhythm | stride_rhythm | MOVE | 73.5 | trail_boots | Improves traversal tempo. | move_speed_mult=0.03; target_swap_speed=0.04 |
| supply_lenses | supply_lenses | ECON | 66.5 | field_magnet | Improves income conversion and pickup efficiency. | cursor_share_bonus=0.02 |
| taxonomy_scanner | taxonomy_scanner | ECON | 119 | scrap_broker | Improves income conversion and pickup efficiency. | elite_value_mult=0.06 |
| trail_boots | trail_boots | MOVE | 43.8 | - | Improves traversal tempo. | move_speed_mult=0.04 |
| wave_bringer_1 | wave_bringer_1 | DENS | 75.2 | encroaching_horde | Increases enemy pressure to raise total reward ceiling. | elite_count=1 |
| wave_bringer_2 | wave_bringer_2 | DENS | 175 | wave_bringer_1 | Increases enemy pressure to raise total reward ceiling. | elite_count=1 |

## Extra 100
| var_name | source_key | family | expected_price | prereqs | description | effect |
|---|---|---|---:|---|---|---|
| adaptive_circuit | extra_skill_001 | ECON | 97.6 | - | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_10 | extra_skill_091 | SURV | 710 | extra_skill_088, extra_skill_083 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_2 | extra_skill_011 | SURV | 165 | extra_skill_008, extra_skill_003 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_3 | extra_skill_021 | POWR | 232.7 | extra_skill_018, extra_skill_013 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_4 | extra_skill_031 | BOSS | 300.6 | extra_skill_028, extra_skill_023, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_5 | extra_skill_041 | ECON | 368.6 | extra_skill_038, extra_skill_033 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_6 | extra_skill_051 | SURV | 436.7 | extra_skill_048, extra_skill_043 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_7 | extra_skill_061 | POWR | 505 | extra_skill_058, extra_skill_053 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_8 | extra_skill_071 | BOSS | 573.2 | extra_skill_068, extra_skill_063, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| adaptive_circuit_9 | extra_skill_081 | ECON | 641.6 | extra_skill_078, extra_skill_073 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| aegis_compass | extra_skill_008 | TEAM | 144.7 | extra_skill_005, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_10 | extra_skill_098 | DENS | 757.9 | extra_skill_095, extra_skill_090 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_2 | extra_skill_018 | DENS | 212.3 | extra_skill_015, extra_skill_010 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_3 | extra_skill_028 | MOVE | 280.2 | extra_skill_025, extra_skill_020 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_4 | extra_skill_038 | ACTV | 348.2 | extra_skill_035, extra_skill_030 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_5 | extra_skill_048 | TEAM | 416.3 | extra_skill_045, extra_skill_040, flag:archer_unlocked, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_6 | extra_skill_058 | DENS | 484.5 | extra_skill_055, extra_skill_050 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_7 | extra_skill_068 | MOVE | 552.8 | extra_skill_065, extra_skill_060 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_8 | extra_skill_078 | ACTV | 621.1 | extra_skill_075, extra_skill_070 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| aegis_compass_9 | extra_skill_088 | TEAM | 689.5 | extra_skill_085, extra_skill_080, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| echo_burst | extra_skill_005 | POWR | 124.5 | extra_skill_002 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| echo_burst_10 | extra_skill_095 | BOSS | 737.4 | extra_skill_092, extra_skill_087, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| echo_burst_2 | extra_skill_015 | BOSS | 192 | extra_skill_012, extra_skill_007, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| echo_burst_3 | extra_skill_025 | ECON | 259.8 | extra_skill_022, extra_skill_017 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| echo_burst_4 | extra_skill_035 | SURV | 327.8 | extra_skill_032, extra_skill_027 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| echo_burst_5 | extra_skill_045 | POWR | 395.9 | extra_skill_042, extra_skill_037 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| echo_burst_6 | extra_skill_055 | BOSS | 464 | extra_skill_052, extra_skill_047, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| echo_burst_7 | extra_skill_065 | ECON | 532.3 | extra_skill_062, extra_skill_057 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| echo_burst_8 | extra_skill_075 | SURV | 600.6 | extra_skill_072, extra_skill_067 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| echo_burst_9 | extra_skill_085 | POWR | 668.9 | extra_skill_082, extra_skill_077 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| fractal_relay | extra_skill_002 | DENS | 104.3 | - | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_10 | extra_skill_092 | MOVE | 716.8 | extra_skill_089, extra_skill_084 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_2 | extra_skill_012 | MOVE | 171.7 | extra_skill_009, extra_skill_004 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_3 | extra_skill_022 | ACTV | 239.5 | extra_skill_019, extra_skill_014 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_4 | extra_skill_032 | TEAM | 307.4 | extra_skill_029, extra_skill_024, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_5 | extra_skill_042 | DENS | 375.4 | extra_skill_039, extra_skill_034 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_6 | extra_skill_052 | MOVE | 443.6 | extra_skill_049, extra_skill_044 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_7 | extra_skill_062 | ACTV | 511.8 | extra_skill_059, extra_skill_054 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_8 | extra_skill_072 | TEAM | 580.1 | extra_skill_069, extra_skill_064, flag:archer_unlocked, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| fractal_relay_9 | extra_skill_082 | DENS | 648.4 | extra_skill_079, extra_skill_074 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| iron_ledger | extra_skill_003 | SURV | 111 | - | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_10 | extra_skill_093 | POWR | 723.7 | extra_skill_090, extra_skill_085 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_2 | extra_skill_013 | POWR | 178.5 | extra_skill_010, extra_skill_005 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_3 | extra_skill_023 | BOSS | 246.2 | extra_skill_020, extra_skill_015, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_4 | extra_skill_033 | ECON | 314.2 | extra_skill_030, extra_skill_025 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_5 | extra_skill_043 | SURV | 382.2 | extra_skill_040, extra_skill_035 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_6 | extra_skill_053 | POWR | 450.4 | extra_skill_050, extra_skill_045 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_7 | extra_skill_063 | BOSS | 518.6 | extra_skill_060, extra_skill_055, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_8 | extra_skill_073 | ECON | 586.9 | extra_skill_070, extra_skill_065 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| iron_ledger_9 | extra_skill_083 | SURV | 655.3 | extra_skill_080, extra_skill_075 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| nova_matrix | extra_skill_010 | DENS | 158.2 | extra_skill_007, extra_skill_002 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_10 | extra_skill_100 | MOVE | 771.6 | extra_skill_097, extra_skill_092 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_2 | extra_skill_020 | MOVE | 225.9 | extra_skill_017, extra_skill_012 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_3 | extra_skill_030 | ACTV | 293.8 | extra_skill_027, extra_skill_022 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_4 | extra_skill_040 | TEAM | 361.8 | extra_skill_037, extra_skill_032, flag:guardian_unlocked, flag:mage_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_5 | extra_skill_050 | DENS | 429.9 | extra_skill_047, extra_skill_042 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_6 | extra_skill_060 | MOVE | 498.1 | extra_skill_057, extra_skill_052 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_7 | extra_skill_070 | ACTV | 566.4 | extra_skill_067, extra_skill_062 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_8 | extra_skill_080 | TEAM | 634.8 | extra_skill_077, extra_skill_072, flag:guardian_unlocked, flag:mage_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| nova_matrix_9 | extra_skill_090 | DENS | 703.1 | extra_skill_087, extra_skill_082 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice | extra_skill_007 | BOSS | 138 | extra_skill_004, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_10 | extra_skill_097 | ECON | 751.1 | extra_skill_094, extra_skill_089 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_2 | extra_skill_017 | ECON | 205.6 | extra_skill_014, extra_skill_009 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_3 | extra_skill_027 | SURV | 273.4 | extra_skill_024, extra_skill_019 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_4 | extra_skill_037 | POWR | 341.4 | extra_skill_034, extra_skill_029 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_5 | extra_skill_047 | BOSS | 409.5 | extra_skill_044, extra_skill_039, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_6 | extra_skill_057 | ECON | 477.7 | extra_skill_054, extra_skill_049 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_7 | extra_skill_067 | SURV | 545.9 | extra_skill_064, extra_skill_059 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_8 | extra_skill_077 | POWR | 614.2 | extra_skill_074, extra_skill_069 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| pulse_lattice_9 | extra_skill_087 | BOSS | 682.6 | extra_skill_084, extra_skill_079, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| rift_anchor | extra_skill_006 | ACTV | 131.2 | extra_skill_003 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_10 | extra_skill_096 | TEAM | 744.2 | extra_skill_093, extra_skill_088, flag:archer_unlocked, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_2 | extra_skill_016 | TEAM | 198.8 | extra_skill_013, extra_skill_008, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_3 | extra_skill_026 | DENS | 266.6 | extra_skill_023, extra_skill_018 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_4 | extra_skill_036 | MOVE | 334.6 | extra_skill_033, extra_skill_028 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_5 | extra_skill_046 | ACTV | 402.7 | extra_skill_043, extra_skill_038 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_6 | extra_skill_056 | TEAM | 470.8 | extra_skill_053, extra_skill_048, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_7 | extra_skill_066 | DENS | 539.1 | extra_skill_063, extra_skill_058 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_8 | extra_skill_076 | MOVE | 607.4 | extra_skill_073, extra_skill_068 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| rift_anchor_9 | extra_skill_086 | ACTV | 675.8 | extra_skill_083, extra_skill_078 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| solar_spine | extra_skill_004 | MOVE | 117.8 | - | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| solar_spine_10 | extra_skill_094 | ACTV | 730.5 | extra_skill_091, extra_skill_086 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| solar_spine_2 | extra_skill_014 | ACTV | 185.3 | extra_skill_011, extra_skill_006 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| solar_spine_3 | extra_skill_024 | TEAM | 253 | extra_skill_021, extra_skill_016, flag:archer_unlocked, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| solar_spine_4 | extra_skill_034 | DENS | 321 | extra_skill_031, extra_skill_026 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| solar_spine_5 | extra_skill_044 | MOVE | 389 | extra_skill_041, extra_skill_036 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| solar_spine_6 | extra_skill_054 | ACTV | 457.2 | extra_skill_051, extra_skill_046 | Improves active ability uptime. | Pattern-generated family effect (see simulation rules). |
| solar_spine_7 | extra_skill_064 | TEAM | 525.4 | extra_skill_061, extra_skill_056, flag:guardian_unlocked | Improves hero-specific combat synergy. | Pattern-generated family effect (see simulation rules). |
| solar_spine_8 | extra_skill_074 | DENS | 593.7 | extra_skill_071, extra_skill_066 | Increases enemy pressure to raise total reward ceiling. | Pattern-generated family effect (see simulation rules). |
| solar_spine_9 | extra_skill_084 | MOVE | 662.1 | extra_skill_081, extra_skill_076 | Improves traversal tempo. | Pattern-generated family effect (see simulation rules). |
| vector_engine | extra_skill_009 | ECON | 151.5 | extra_skill_006, extra_skill_001 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| vector_engine_10 | extra_skill_099 | SURV | 764.7 | extra_skill_096, extra_skill_091 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| vector_engine_2 | extra_skill_019 | SURV | 219.1 | extra_skill_016, extra_skill_011 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| vector_engine_3 | extra_skill_029 | POWR | 287 | extra_skill_026, extra_skill_021 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| vector_engine_4 | extra_skill_039 | BOSS | 355 | extra_skill_036, extra_skill_031, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| vector_engine_5 | extra_skill_049 | ECON | 423.1 | extra_skill_046, extra_skill_041 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |
| vector_engine_6 | extra_skill_059 | SURV | 491.3 | extra_skill_056, extra_skill_051 | Improves survivability and run depth. | Pattern-generated family effect (see simulation rules). |
| vector_engine_7 | extra_skill_069 | POWR | 559.6 | extra_skill_066, extra_skill_061 | Improves power economy for actives. | Pattern-generated family effect (see simulation rules). |
| vector_engine_8 | extra_skill_079 | BOSS | 627.9 | extra_skill_076, extra_skill_071, flag:boss_seen | Improves boss phase output/safety/reward. | Pattern-generated family effect (see simulation rules). |
| vector_engine_9 | extra_skill_089 | ECON | 696.3 | extra_skill_086, extra_skill_081 | Improves income conversion and pickup efficiency. | Pattern-generated family effect (see simulation rules). |

