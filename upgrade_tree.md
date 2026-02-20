# Upgrade Tree (All Upgrades With Prices And Prerequisites)

This tree matches the current simulator definitions and pricing in `simulation/simulation_60upgrades_2h.ps1` and `simulation/upgrade_prices_in_order.md`.

## Visual Tree
```mermaid
graph TD
  START([Run Start])
  FLAG_BOSS([flag:boss_seen])
  FLAG_ARCHER([flag:archer_unlocked])
  FLAG_GUARDIAN([flag:guardian_unlocked])
  FLAG_MAGE([flag:mage_unlocked])
  n_recruit_archer["recruit_archer\\n$98"]
  n_auto_attack_unlock["auto_attack_unlock\\n$105"]
  n_knight_vamp_unlock["knight_vamp_unlock\\n$112"]
  n_archer_pierce_unlock["archer_pierce_unlock\\n$126"]
  n_power_harvest_unlock["power_harvest_unlock\\n$136.5"]
  n_recruit_guardian["recruit_guardian\\n$238"]
  n_guardian_fortify_unlock["guardian_fortify_unlock\\n$217"]
  n_recruit_mage["recruit_mage\\n$343"]
  n_mage_storm_unlock["mage_storm_unlock\\n$308"]
  n_salvage_hooks["salvage_hooks\\n$42"]
  n_field_magnet["field_magnet\\n$50.8"]
  n_encroaching_horde["encroaching_horde\\n$45.5"]
  n_trail_boots["trail_boots\\n$43.8"]
  n_reinforced_plates["reinforced_plates\\n$49"]
  n_condensed_cores_60["condensed_cores_60\\n$56"]
  n_focused_breathing_60["focused_breathing_60\\n$59.5"]
  n_boss_stance_60["boss_stance_60\\n$77"]
  n_knight_bloodline_1_60["knight_bloodline_1_60\\n$73.5"]
  n_supply_lenses["supply_lenses\\n$66.5"]
  n_wave_bringer_1["wave_bringer_1\\n$75.2"]
  n_archer_drill_1_60["archer_drill_1_60\\n$126"]
  n_impact_weave["impact_weave\\n$80.5"]
  n_stride_rhythm["stride_rhythm\\n$73.5"]
  n_power_reservoir_1_60["power_reservoir_1_60\\n$84"]
  n_quick_invocation_1_60["quick_invocation_1_60\\n$87.5"]
  n_boss_readiness_60["boss_readiness_60\\n$101.5"]
  n_scrap_broker["scrap_broker\\n$94.5"]
  n_line_pressure_1["line_pressure_1\\n$99.8"]
  n_guardian_bulwark_1_60["guardian_bulwark_1_60\\n$182"]
  n_hemostasis_mesh["hemostasis_mesh\\n$105"]
  n_momentum_carry["momentum_carry\\n$103.2"]
  n_overflow_capture["overflow_capture\\n$115.5"]
  n_extended_channel_1_60["extended_channel_1_60\\n$112"]
  n_boss_fracture_study_60["boss_fracture_study_60\\n$129.5"]
  n_taxonomy_scanner["taxonomy_scanner\\n$119"]
  n_archer_piercing_geometry_60["archer_piercing_geometry_60\\n$143.5"]
  n_crowd_ecology["crowd_ecology\\n$136.5"]
  n_shock_padding["shock_padding\\n$129.5"]
  n_route_memory["route_memory\\n$126"]
  n_power_reservoir_2_60["power_reservoir_2_60\\n$143.5"]
  n_quick_invocation_2_60["quick_invocation_2_60\\n$150.5"]
  n_boss_armor_mesh_60["boss_armor_mesh_60\\n$164.5"]
  n_collector_drone["collector_drone\\n$157.5"]
  n_wave_bringer_2["wave_bringer_2\\n$175"]
  n_mage_sigil_1_60["mage_sigil_1_60\\n$266"]
  n_layered_carapace["layered_carapace\\n$182"]
  n_quickstep_chain["quickstep_chain\\n$182"]
  n_condensed_cores_2_60["condensed_cores_2_60\\n$196"]
  n_extended_channel_2_60["extended_channel_2_60\\n$206.5"]
  n_boss_pattern_map["boss_pattern_map\\n$227.5"]
  n_salvage_hooks_2["salvage_hooks_2\\n$217"]
  n_front_compression["front_compression\\n$234.5"]
  n_knight_bloodline_2_60["knight_bloodline_2_60\\n$245"]
  n_dot_deflector["dot_deflector\\n$255.5"]
  n_pathline_sprint["pathline_sprint\\n$259"]
  n_power_echo["power_echo\\n$273"]
  n_cadence_lock["cadence_lock\\n$287"]
  n_boss_bastion["boss_bastion\\n$308"]
  n_market_routing["market_routing\\n$325.5"]
  n_pressure_ladder["pressure_ladder\\n$343"]
  n_guardian_bulwark_2_60["guardian_bulwark_2_60\\n$357"]
  n_shock_sink["shock_sink\\n$371"]
  n_long_march["long_march\\n$392"]
  n_power_reservoir_3_60["power_reservoir_3_60\\n$413"]
  n_overclock_window["overclock_window\\n$434"]
  n_boss_rend_protocol["boss_rend_protocol\\n$462"]
  n_archer_drill_2_60["archer_drill_2_60\\n$483"]
  n_mage_sigil_2_60["mage_sigil_2_60\\n$511"]
  n_run_yield_matrix["run_yield_matrix\\n$539"]
  n_extra_skill_001["extra_skill_001\\n$97.6"]
  n_extra_skill_002["extra_skill_002\\n$104.3"]
  n_extra_skill_003["extra_skill_003\\n$111"]
  n_extra_skill_004["extra_skill_004\\n$117.8"]
  n_extra_skill_005["extra_skill_005\\n$124.5"]
  n_extra_skill_006["extra_skill_006\\n$131.2"]
  n_extra_skill_007["extra_skill_007\\n$138"]
  n_extra_skill_008["extra_skill_008\\n$144.7"]
  n_extra_skill_009["extra_skill_009\\n$151.5"]
  n_extra_skill_010["extra_skill_010\\n$158.2"]
  n_extra_skill_011["extra_skill_011\\n$165"]
  n_extra_skill_012["extra_skill_012\\n$171.7"]
  n_extra_skill_013["extra_skill_013\\n$178.5"]
  n_extra_skill_014["extra_skill_014\\n$185.3"]
  n_extra_skill_015["extra_skill_015\\n$192"]
  n_extra_skill_016["extra_skill_016\\n$198.8"]
  n_extra_skill_017["extra_skill_017\\n$205.6"]
  n_extra_skill_018["extra_skill_018\\n$212.3"]
  n_extra_skill_019["extra_skill_019\\n$219.1"]
  n_extra_skill_020["extra_skill_020\\n$225.9"]
  n_extra_skill_021["extra_skill_021\\n$232.7"]
  n_extra_skill_022["extra_skill_022\\n$239.5"]
  n_extra_skill_023["extra_skill_023\\n$246.2"]
  n_extra_skill_024["extra_skill_024\\n$253"]
  n_extra_skill_025["extra_skill_025\\n$259.8"]
  n_extra_skill_026["extra_skill_026\\n$266.6"]
  n_extra_skill_027["extra_skill_027\\n$273.4"]
  n_extra_skill_028["extra_skill_028\\n$280.2"]
  n_extra_skill_029["extra_skill_029\\n$287"]
  n_extra_skill_030["extra_skill_030\\n$293.8"]
  n_extra_skill_031["extra_skill_031\\n$300.6"]
  n_extra_skill_032["extra_skill_032\\n$307.4"]
  n_extra_skill_033["extra_skill_033\\n$314.2"]
  n_extra_skill_034["extra_skill_034\\n$321"]
  n_extra_skill_035["extra_skill_035\\n$327.8"]
  n_extra_skill_036["extra_skill_036\\n$334.6"]
  n_extra_skill_037["extra_skill_037\\n$341.4"]
  n_extra_skill_038["extra_skill_038\\n$348.2"]
  n_extra_skill_039["extra_skill_039\\n$355"]
  n_extra_skill_040["extra_skill_040\\n$361.8"]
  n_extra_skill_041["extra_skill_041\\n$368.6"]
  n_extra_skill_042["extra_skill_042\\n$375.4"]
  n_extra_skill_043["extra_skill_043\\n$382.2"]
  n_extra_skill_044["extra_skill_044\\n$389"]
  n_extra_skill_045["extra_skill_045\\n$395.9"]
  n_extra_skill_046["extra_skill_046\\n$402.7"]
  n_extra_skill_047["extra_skill_047\\n$409.5"]
  n_extra_skill_048["extra_skill_048\\n$416.3"]
  n_extra_skill_049["extra_skill_049\\n$423.1"]
  n_extra_skill_050["extra_skill_050\\n$429.9"]
  n_extra_skill_051["extra_skill_051\\n$436.7"]
  n_extra_skill_052["extra_skill_052\\n$443.6"]
  n_extra_skill_053["extra_skill_053\\n$450.4"]
  n_extra_skill_054["extra_skill_054\\n$457.2"]
  n_extra_skill_055["extra_skill_055\\n$464"]
  n_extra_skill_056["extra_skill_056\\n$470.8"]
  n_extra_skill_057["extra_skill_057\\n$477.7"]
  n_extra_skill_058["extra_skill_058\\n$484.5"]
  n_extra_skill_059["extra_skill_059\\n$491.3"]
  n_extra_skill_060["extra_skill_060\\n$498.1"]
  n_extra_skill_061["extra_skill_061\\n$505"]
  n_extra_skill_062["extra_skill_062\\n$511.8"]
  n_extra_skill_063["extra_skill_063\\n$518.6"]
  n_extra_skill_064["extra_skill_064\\n$525.4"]
  n_extra_skill_065["extra_skill_065\\n$532.3"]
  n_extra_skill_066["extra_skill_066\\n$539.1"]
  n_extra_skill_067["extra_skill_067\\n$545.9"]
  n_extra_skill_068["extra_skill_068\\n$552.8"]
  n_extra_skill_069["extra_skill_069\\n$559.6"]
  n_extra_skill_070["extra_skill_070\\n$566.4"]
  n_extra_skill_071["extra_skill_071\\n$573.2"]
  n_extra_skill_072["extra_skill_072\\n$580.1"]
  n_extra_skill_073["extra_skill_073\\n$586.9"]
  n_extra_skill_074["extra_skill_074\\n$593.7"]
  n_extra_skill_075["extra_skill_075\\n$600.6"]
  n_extra_skill_076["extra_skill_076\\n$607.4"]
  n_extra_skill_077["extra_skill_077\\n$614.2"]
  n_extra_skill_078["extra_skill_078\\n$621.1"]
  n_extra_skill_079["extra_skill_079\\n$627.9"]
  n_extra_skill_080["extra_skill_080\\n$634.8"]
  n_extra_skill_081["extra_skill_081\\n$641.6"]
  n_extra_skill_082["extra_skill_082\\n$648.4"]
  n_extra_skill_083["extra_skill_083\\n$655.3"]
  n_extra_skill_084["extra_skill_084\\n$662.1"]
  n_extra_skill_085["extra_skill_085\\n$668.9"]
  n_extra_skill_086["extra_skill_086\\n$675.8"]
  n_extra_skill_087["extra_skill_087\\n$682.6"]
  n_extra_skill_088["extra_skill_088\\n$689.5"]
  n_extra_skill_089["extra_skill_089\\n$696.3"]
  n_extra_skill_090["extra_skill_090\\n$703.1"]
  n_extra_skill_091["extra_skill_091\\n$710"]
  n_extra_skill_092["extra_skill_092\\n$716.8"]
  n_extra_skill_093["extra_skill_093\\n$723.7"]
  n_extra_skill_094["extra_skill_094\\n$730.5"]
  n_extra_skill_095["extra_skill_095\\n$737.4"]
  n_extra_skill_096["extra_skill_096\\n$744.2"]
  n_extra_skill_097["extra_skill_097\\n$751.1"]
  n_extra_skill_098["extra_skill_098\\n$757.9"]
  n_extra_skill_099["extra_skill_099\\n$764.7"]
  n_extra_skill_100["extra_skill_100\\n$771.6"]
  n_core_archer_active_cap["core_archer_active_cap\\n26.6 * (1.12 ^ level)"]
  n_core_archer_damage["core_archer_damage\\n25.9 * (1.11 ^ level)"]
  n_core_archer_speed["core_archer_speed\\n24.5 * (1.11 ^ level)"]
  n_core_armor["core_armor\\n25.2 * (1.11 ^ level)"]
  n_core_density["core_density\\n28 * (1.12 ^ level)"]
  n_core_drop["core_drop\\n27.3 * (1.11 ^ level)"]
  n_core_guardian_active_cap["core_guardian_active_cap\\n31.5 * (1.13 ^ level)"]
  n_core_guardian_damage["core_guardian_damage\\n29.4 * (1.12 ^ level)"]
  n_core_guardian_speed["core_guardian_speed\\n28.7 * (1.12 ^ level)"]
  n_core_knight_active_cap["core_knight_active_cap\\n25.2 * (1.12 ^ level)"]
  n_core_knight_damage["core_knight_damage\\n23.8 * (1.11 ^ level)"]
  n_core_knight_speed["core_knight_speed\\n22.4 * (1.11 ^ level)"]
  n_core_mage_active_cap["core_mage_active_cap\\n33.6 * (1.13 ^ level)"]
  n_core_mage_damage["core_mage_damage\\n32.2 * (1.12 ^ level)"]
  n_core_mage_speed["core_mage_speed\\n30.8 * (1.12 ^ level)"]
  n_core_power["core_power\\n28.7 * (1.12 ^ level)"]
  START --> n_recruit_archer
  n_recruit_archer --> n_auto_attack_unlock
  n_auto_attack_unlock --> n_knight_vamp_unlock
  n_recruit_archer --> n_archer_pierce_unlock
  n_recruit_archer --> n_power_harvest_unlock
  n_archer_pierce_unlock --> n_recruit_guardian
  n_recruit_guardian --> n_guardian_fortify_unlock
  n_recruit_guardian --> n_recruit_mage
  n_power_harvest_unlock --> n_recruit_mage
  n_recruit_mage --> n_mage_storm_unlock
  START --> n_salvage_hooks
  n_salvage_hooks --> n_field_magnet
  START --> n_encroaching_horde
  START --> n_trail_boots
  START --> n_reinforced_plates
  START --> n_condensed_cores_60
  START --> n_focused_breathing_60
  FLAG_BOSS --> n_boss_stance_60
  START --> n_knight_bloodline_1_60
  n_field_magnet --> n_supply_lenses
  n_encroaching_horde --> n_wave_bringer_1
  FLAG_ARCHER --> n_archer_drill_1_60
  n_reinforced_plates --> n_impact_weave
  n_trail_boots --> n_stride_rhythm
  n_condensed_cores_60 --> n_power_reservoir_1_60
  n_focused_breathing_60 --> n_quick_invocation_1_60
  n_boss_stance_60 --> n_boss_readiness_60
  n_supply_lenses --> n_scrap_broker
  n_wave_bringer_1 --> n_line_pressure_1
  FLAG_GUARDIAN --> n_guardian_bulwark_1_60
  n_impact_weave --> n_hemostasis_mesh
  n_stride_rhythm --> n_momentum_carry
  n_power_reservoir_1_60 --> n_overflow_capture
  n_quick_invocation_1_60 --> n_extended_channel_1_60
  n_boss_readiness_60 --> n_boss_fracture_study_60
  n_scrap_broker --> n_taxonomy_scanner
  FLAG_ARCHER --> n_archer_piercing_geometry_60
  n_line_pressure_1 --> n_crowd_ecology
  n_hemostasis_mesh --> n_shock_padding
  n_momentum_carry --> n_route_memory
  n_power_reservoir_1_60 --> n_power_reservoir_2_60
  n_quick_invocation_1_60 --> n_quick_invocation_2_60
  n_boss_fracture_study_60 --> n_boss_armor_mesh_60
  n_taxonomy_scanner --> n_collector_drone
  n_wave_bringer_1 --> n_wave_bringer_2
  FLAG_MAGE --> n_mage_sigil_1_60
  n_shock_padding --> n_layered_carapace
  n_route_memory --> n_quickstep_chain
  n_condensed_cores_60 --> n_condensed_cores_2_60
  n_extended_channel_1_60 --> n_extended_channel_2_60
  n_boss_armor_mesh_60 --> n_boss_pattern_map
  n_salvage_hooks --> n_salvage_hooks_2
  n_crowd_ecology --> n_front_compression
  n_knight_bloodline_1_60 --> n_knight_bloodline_2_60
  n_hemostasis_mesh --> n_dot_deflector
  n_quickstep_chain --> n_pathline_sprint
  n_condensed_cores_2_60 --> n_power_echo
  n_quick_invocation_2_60 --> n_cadence_lock
  n_boss_pattern_map --> n_boss_bastion
  n_collector_drone --> n_market_routing
  n_front_compression --> n_pressure_ladder
  n_guardian_bulwark_1_60 --> n_guardian_bulwark_2_60
  n_dot_deflector --> n_shock_sink
  n_pathline_sprint --> n_long_march
  n_power_reservoir_2_60 --> n_power_reservoir_3_60
  n_cadence_lock --> n_overclock_window
  n_boss_bastion --> n_boss_rend_protocol
  n_archer_drill_1_60 --> n_archer_drill_2_60
  n_mage_sigil_1_60 --> n_mage_sigil_2_60
  n_market_routing --> n_run_yield_matrix
  START --> n_extra_skill_001
  START --> n_extra_skill_002
  START --> n_extra_skill_003
  START --> n_extra_skill_004
  n_extra_skill_002 --> n_extra_skill_005
  n_extra_skill_003 --> n_extra_skill_006
  n_extra_skill_004 --> n_extra_skill_007
  FLAG_BOSS --> n_extra_skill_007
  n_extra_skill_005 --> n_extra_skill_008
  FLAG_GUARDIAN --> n_extra_skill_008
  n_extra_skill_006 --> n_extra_skill_009
  n_extra_skill_001 --> n_extra_skill_009
  n_extra_skill_007 --> n_extra_skill_010
  n_extra_skill_002 --> n_extra_skill_010
  n_extra_skill_008 --> n_extra_skill_011
  n_extra_skill_003 --> n_extra_skill_011
  n_extra_skill_009 --> n_extra_skill_012
  n_extra_skill_004 --> n_extra_skill_012
  n_extra_skill_010 --> n_extra_skill_013
  n_extra_skill_005 --> n_extra_skill_013
  n_extra_skill_011 --> n_extra_skill_014
  n_extra_skill_006 --> n_extra_skill_014
  n_extra_skill_012 --> n_extra_skill_015
  n_extra_skill_007 --> n_extra_skill_015
  FLAG_BOSS --> n_extra_skill_015
  n_extra_skill_013 --> n_extra_skill_016
  n_extra_skill_008 --> n_extra_skill_016
  FLAG_GUARDIAN --> n_extra_skill_016
  n_extra_skill_014 --> n_extra_skill_017
  n_extra_skill_009 --> n_extra_skill_017
  n_extra_skill_015 --> n_extra_skill_018
  n_extra_skill_010 --> n_extra_skill_018
  n_extra_skill_016 --> n_extra_skill_019
  n_extra_skill_011 --> n_extra_skill_019
  n_extra_skill_017 --> n_extra_skill_020
  n_extra_skill_012 --> n_extra_skill_020
  n_extra_skill_018 --> n_extra_skill_021
  n_extra_skill_013 --> n_extra_skill_021
  n_extra_skill_019 --> n_extra_skill_022
  n_extra_skill_014 --> n_extra_skill_022
  n_extra_skill_020 --> n_extra_skill_023
  n_extra_skill_015 --> n_extra_skill_023
  FLAG_BOSS --> n_extra_skill_023
  n_extra_skill_021 --> n_extra_skill_024
  n_extra_skill_016 --> n_extra_skill_024
  FLAG_ARCHER --> n_extra_skill_024
  FLAG_GUARDIAN --> n_extra_skill_024
  n_extra_skill_022 --> n_extra_skill_025
  n_extra_skill_017 --> n_extra_skill_025
  n_extra_skill_023 --> n_extra_skill_026
  n_extra_skill_018 --> n_extra_skill_026
  n_extra_skill_024 --> n_extra_skill_027
  n_extra_skill_019 --> n_extra_skill_027
  n_extra_skill_025 --> n_extra_skill_028
  n_extra_skill_020 --> n_extra_skill_028
  n_extra_skill_026 --> n_extra_skill_029
  n_extra_skill_021 --> n_extra_skill_029
  n_extra_skill_027 --> n_extra_skill_030
  n_extra_skill_022 --> n_extra_skill_030
  n_extra_skill_028 --> n_extra_skill_031
  n_extra_skill_023 --> n_extra_skill_031
  FLAG_BOSS --> n_extra_skill_031
  n_extra_skill_029 --> n_extra_skill_032
  n_extra_skill_024 --> n_extra_skill_032
  FLAG_GUARDIAN --> n_extra_skill_032
  n_extra_skill_030 --> n_extra_skill_033
  n_extra_skill_025 --> n_extra_skill_033
  n_extra_skill_031 --> n_extra_skill_034
  n_extra_skill_026 --> n_extra_skill_034
  n_extra_skill_032 --> n_extra_skill_035
  n_extra_skill_027 --> n_extra_skill_035
  n_extra_skill_033 --> n_extra_skill_036
  n_extra_skill_028 --> n_extra_skill_036
  n_extra_skill_034 --> n_extra_skill_037
  n_extra_skill_029 --> n_extra_skill_037
  n_extra_skill_035 --> n_extra_skill_038
  n_extra_skill_030 --> n_extra_skill_038
  n_extra_skill_036 --> n_extra_skill_039
  n_extra_skill_031 --> n_extra_skill_039
  FLAG_BOSS --> n_extra_skill_039
  n_extra_skill_037 --> n_extra_skill_040
  n_extra_skill_032 --> n_extra_skill_040
  FLAG_GUARDIAN --> n_extra_skill_040
  FLAG_MAGE --> n_extra_skill_040
  n_extra_skill_038 --> n_extra_skill_041
  n_extra_skill_033 --> n_extra_skill_041
  n_extra_skill_039 --> n_extra_skill_042
  n_extra_skill_034 --> n_extra_skill_042
  n_extra_skill_040 --> n_extra_skill_043
  n_extra_skill_035 --> n_extra_skill_043
  n_extra_skill_041 --> n_extra_skill_044
  n_extra_skill_036 --> n_extra_skill_044
  n_extra_skill_042 --> n_extra_skill_045
  n_extra_skill_037 --> n_extra_skill_045
  n_extra_skill_043 --> n_extra_skill_046
  n_extra_skill_038 --> n_extra_skill_046
  n_extra_skill_044 --> n_extra_skill_047
  n_extra_skill_039 --> n_extra_skill_047
  FLAG_BOSS --> n_extra_skill_047
  n_extra_skill_045 --> n_extra_skill_048
  n_extra_skill_040 --> n_extra_skill_048
  FLAG_ARCHER --> n_extra_skill_048
  FLAG_GUARDIAN --> n_extra_skill_048
  n_extra_skill_046 --> n_extra_skill_049
  n_extra_skill_041 --> n_extra_skill_049
  n_extra_skill_047 --> n_extra_skill_050
  n_extra_skill_042 --> n_extra_skill_050
  n_extra_skill_048 --> n_extra_skill_051
  n_extra_skill_043 --> n_extra_skill_051
  n_extra_skill_049 --> n_extra_skill_052
  n_extra_skill_044 --> n_extra_skill_052
  n_extra_skill_050 --> n_extra_skill_053
  n_extra_skill_045 --> n_extra_skill_053
  n_extra_skill_051 --> n_extra_skill_054
  n_extra_skill_046 --> n_extra_skill_054
  n_extra_skill_052 --> n_extra_skill_055
  n_extra_skill_047 --> n_extra_skill_055
  FLAG_BOSS --> n_extra_skill_055
  n_extra_skill_053 --> n_extra_skill_056
  n_extra_skill_048 --> n_extra_skill_056
  FLAG_GUARDIAN --> n_extra_skill_056
  n_extra_skill_054 --> n_extra_skill_057
  n_extra_skill_049 --> n_extra_skill_057
  n_extra_skill_055 --> n_extra_skill_058
  n_extra_skill_050 --> n_extra_skill_058
  n_extra_skill_056 --> n_extra_skill_059
  n_extra_skill_051 --> n_extra_skill_059
  n_extra_skill_057 --> n_extra_skill_060
  n_extra_skill_052 --> n_extra_skill_060
  n_extra_skill_058 --> n_extra_skill_061
  n_extra_skill_053 --> n_extra_skill_061
  n_extra_skill_059 --> n_extra_skill_062
  n_extra_skill_054 --> n_extra_skill_062
  n_extra_skill_060 --> n_extra_skill_063
  n_extra_skill_055 --> n_extra_skill_063
  FLAG_BOSS --> n_extra_skill_063
  n_extra_skill_061 --> n_extra_skill_064
  n_extra_skill_056 --> n_extra_skill_064
  FLAG_GUARDIAN --> n_extra_skill_064
  n_extra_skill_062 --> n_extra_skill_065
  n_extra_skill_057 --> n_extra_skill_065
  n_extra_skill_063 --> n_extra_skill_066
  n_extra_skill_058 --> n_extra_skill_066
  n_extra_skill_064 --> n_extra_skill_067
  n_extra_skill_059 --> n_extra_skill_067
  n_extra_skill_065 --> n_extra_skill_068
  n_extra_skill_060 --> n_extra_skill_068
  n_extra_skill_066 --> n_extra_skill_069
  n_extra_skill_061 --> n_extra_skill_069
  n_extra_skill_067 --> n_extra_skill_070
  n_extra_skill_062 --> n_extra_skill_070
  n_extra_skill_068 --> n_extra_skill_071
  n_extra_skill_063 --> n_extra_skill_071
  FLAG_BOSS --> n_extra_skill_071
  n_extra_skill_069 --> n_extra_skill_072
  n_extra_skill_064 --> n_extra_skill_072
  FLAG_ARCHER --> n_extra_skill_072
  FLAG_GUARDIAN --> n_extra_skill_072
  n_extra_skill_070 --> n_extra_skill_073
  n_extra_skill_065 --> n_extra_skill_073
  n_extra_skill_071 --> n_extra_skill_074
  n_extra_skill_066 --> n_extra_skill_074
  n_extra_skill_072 --> n_extra_skill_075
  n_extra_skill_067 --> n_extra_skill_075
  n_extra_skill_073 --> n_extra_skill_076
  n_extra_skill_068 --> n_extra_skill_076
  n_extra_skill_074 --> n_extra_skill_077
  n_extra_skill_069 --> n_extra_skill_077
  n_extra_skill_075 --> n_extra_skill_078
  n_extra_skill_070 --> n_extra_skill_078
  n_extra_skill_076 --> n_extra_skill_079
  n_extra_skill_071 --> n_extra_skill_079
  FLAG_BOSS --> n_extra_skill_079
  n_extra_skill_077 --> n_extra_skill_080
  n_extra_skill_072 --> n_extra_skill_080
  FLAG_GUARDIAN --> n_extra_skill_080
  FLAG_MAGE --> n_extra_skill_080
  n_extra_skill_078 --> n_extra_skill_081
  n_extra_skill_073 --> n_extra_skill_081
  n_extra_skill_079 --> n_extra_skill_082
  n_extra_skill_074 --> n_extra_skill_082
  n_extra_skill_080 --> n_extra_skill_083
  n_extra_skill_075 --> n_extra_skill_083
  n_extra_skill_081 --> n_extra_skill_084
  n_extra_skill_076 --> n_extra_skill_084
  n_extra_skill_082 --> n_extra_skill_085
  n_extra_skill_077 --> n_extra_skill_085
  n_extra_skill_083 --> n_extra_skill_086
  n_extra_skill_078 --> n_extra_skill_086
  n_extra_skill_084 --> n_extra_skill_087
  n_extra_skill_079 --> n_extra_skill_087
  FLAG_BOSS --> n_extra_skill_087
  n_extra_skill_085 --> n_extra_skill_088
  n_extra_skill_080 --> n_extra_skill_088
  FLAG_GUARDIAN --> n_extra_skill_088
  n_extra_skill_086 --> n_extra_skill_089
  n_extra_skill_081 --> n_extra_skill_089
  n_extra_skill_087 --> n_extra_skill_090
  n_extra_skill_082 --> n_extra_skill_090
  n_extra_skill_088 --> n_extra_skill_091
  n_extra_skill_083 --> n_extra_skill_091
  n_extra_skill_089 --> n_extra_skill_092
  n_extra_skill_084 --> n_extra_skill_092
  n_extra_skill_090 --> n_extra_skill_093
  n_extra_skill_085 --> n_extra_skill_093
  n_extra_skill_091 --> n_extra_skill_094
  n_extra_skill_086 --> n_extra_skill_094
  n_extra_skill_092 --> n_extra_skill_095
  n_extra_skill_087 --> n_extra_skill_095
  FLAG_BOSS --> n_extra_skill_095
  n_extra_skill_093 --> n_extra_skill_096
  n_extra_skill_088 --> n_extra_skill_096
  FLAG_ARCHER --> n_extra_skill_096
  FLAG_GUARDIAN --> n_extra_skill_096
  n_extra_skill_094 --> n_extra_skill_097
  n_extra_skill_089 --> n_extra_skill_097
  n_extra_skill_095 --> n_extra_skill_098
  n_extra_skill_090 --> n_extra_skill_098
  n_extra_skill_096 --> n_extra_skill_099
  n_extra_skill_091 --> n_extra_skill_099
  n_extra_skill_097 --> n_extra_skill_100
  n_extra_skill_092 --> n_extra_skill_100
  START --> n_core_archer_active_cap
  START --> n_core_archer_damage
  START --> n_core_archer_speed
  START --> n_core_armor
  START --> n_core_density
  START --> n_core_drop
  START --> n_core_guardian_active_cap
  START --> n_core_guardian_damage
  START --> n_core_guardian_speed
  START --> n_core_knight_active_cap
  START --> n_core_knight_damage
  START --> n_core_knight_speed
  START --> n_core_mage_active_cap
  START --> n_core_mage_damage
  START --> n_core_mage_speed
  START --> n_core_power
  n_recruit_archer --> FLAG_ARCHER
  n_recruit_guardian --> FLAG_GUARDIAN
  n_recruit_mage --> FLAG_MAGE
```

## Upgrade Nodes (Price + Prerequisites)
| Upgrade | Family | Expected Price | Prerequisites |
|---|---|---:|---|
| cadence_lock | ACTV | 287 | quick_invocation_2_60 |
| extended_channel_1_60 | ACTV | 112 | quick_invocation_1_60 |
| extended_channel_2_60 | ACTV | 206.5 | extended_channel_1_60 |
| extra_skill_006 | ACTV | 131.2 | extra_skill_003 |
| extra_skill_014 | ACTV | 185.3 | extra_skill_011, extra_skill_006 |
| extra_skill_022 | ACTV | 239.5 | extra_skill_019, extra_skill_014 |
| extra_skill_030 | ACTV | 293.8 | extra_skill_027, extra_skill_022 |
| extra_skill_038 | ACTV | 348.2 | extra_skill_035, extra_skill_030 |
| extra_skill_046 | ACTV | 402.7 | extra_skill_043, extra_skill_038 |
| extra_skill_054 | ACTV | 457.2 | extra_skill_051, extra_skill_046 |
| extra_skill_062 | ACTV | 511.8 | extra_skill_059, extra_skill_054 |
| extra_skill_070 | ACTV | 566.4 | extra_skill_067, extra_skill_062 |
| extra_skill_078 | ACTV | 621.1 | extra_skill_075, extra_skill_070 |
| extra_skill_086 | ACTV | 675.8 | extra_skill_083, extra_skill_078 |
| extra_skill_094 | ACTV | 730.5 | extra_skill_091, extra_skill_086 |
| focused_breathing_60 | ACTV | 59.5 | - |
| overclock_window | ACTV | 434 | cadence_lock |
| quick_invocation_1_60 | ACTV | 87.5 | focused_breathing_60 |
| quick_invocation_2_60 | ACTV | 150.5 | quick_invocation_1_60 |
| boss_armor_mesh_60 | BOSS | 164.5 | boss_fracture_study_60 |
| boss_bastion | BOSS | 308 | boss_pattern_map |
| boss_fracture_study_60 | BOSS | 129.5 | boss_readiness_60 |
| boss_pattern_map | BOSS | 227.5 | boss_armor_mesh_60 |
| boss_readiness_60 | BOSS | 101.5 | boss_stance_60 |
| boss_rend_protocol | BOSS | 462 | boss_bastion |
| boss_stance_60 | BOSS | 77 | flag:boss_seen |
| extra_skill_007 | BOSS | 138 | extra_skill_004, flag:boss_seen |
| extra_skill_015 | BOSS | 192 | extra_skill_012, extra_skill_007, flag:boss_seen |
| extra_skill_023 | BOSS | 246.2 | extra_skill_020, extra_skill_015, flag:boss_seen |
| extra_skill_031 | BOSS | 300.6 | extra_skill_028, extra_skill_023, flag:boss_seen |
| extra_skill_039 | BOSS | 355 | extra_skill_036, extra_skill_031, flag:boss_seen |
| extra_skill_047 | BOSS | 409.5 | extra_skill_044, extra_skill_039, flag:boss_seen |
| extra_skill_055 | BOSS | 464 | extra_skill_052, extra_skill_047, flag:boss_seen |
| extra_skill_063 | BOSS | 518.6 | extra_skill_060, extra_skill_055, flag:boss_seen |
| extra_skill_071 | BOSS | 573.2 | extra_skill_068, extra_skill_063, flag:boss_seen |
| extra_skill_079 | BOSS | 627.9 | extra_skill_076, extra_skill_071, flag:boss_seen |
| extra_skill_087 | BOSS | 682.6 | extra_skill_084, extra_skill_079, flag:boss_seen |
| extra_skill_095 | BOSS | 737.4 | extra_skill_092, extra_skill_087, flag:boss_seen |
| core_archer_active_cap | CORE | 26.6 * (1.12 ^ level) | - |
| core_archer_damage | CORE | 25.9 * (1.11 ^ level) | - |
| core_archer_speed | CORE | 24.5 * (1.11 ^ level) | - |
| core_armor | CORE | 25.2 * (1.11 ^ level) | - |
| core_density | CORE | 28 * (1.12 ^ level) | - |
| core_drop | CORE | 27.3 * (1.11 ^ level) | - |
| core_guardian_active_cap | CORE | 31.5 * (1.13 ^ level) | - |
| core_guardian_damage | CORE | 29.4 * (1.12 ^ level) | - |
| core_guardian_speed | CORE | 28.7 * (1.12 ^ level) | - |
| core_knight_active_cap | CORE | 25.2 * (1.12 ^ level) | - |
| core_knight_damage | CORE | 23.8 * (1.11 ^ level) | - |
| core_knight_speed | CORE | 22.4 * (1.11 ^ level) | - |
| core_mage_active_cap | CORE | 33.6 * (1.13 ^ level) | - |
| core_mage_damage | CORE | 32.2 * (1.12 ^ level) | - |
| core_mage_speed | CORE | 30.8 * (1.12 ^ level) | - |
| core_power | CORE | 28.7 * (1.12 ^ level) | - |
| crowd_ecology | DENS | 136.5 | line_pressure_1 |
| encroaching_horde | DENS | 45.5 | - |
| extra_skill_002 | DENS | 104.3 | - |
| extra_skill_010 | DENS | 158.2 | extra_skill_007, extra_skill_002 |
| extra_skill_018 | DENS | 212.3 | extra_skill_015, extra_skill_010 |
| extra_skill_026 | DENS | 266.6 | extra_skill_023, extra_skill_018 |
| extra_skill_034 | DENS | 321 | extra_skill_031, extra_skill_026 |
| extra_skill_042 | DENS | 375.4 | extra_skill_039, extra_skill_034 |
| extra_skill_050 | DENS | 429.9 | extra_skill_047, extra_skill_042 |
| extra_skill_058 | DENS | 484.5 | extra_skill_055, extra_skill_050 |
| extra_skill_066 | DENS | 539.1 | extra_skill_063, extra_skill_058 |
| extra_skill_074 | DENS | 593.7 | extra_skill_071, extra_skill_066 |
| extra_skill_082 | DENS | 648.4 | extra_skill_079, extra_skill_074 |
| extra_skill_090 | DENS | 703.1 | extra_skill_087, extra_skill_082 |
| extra_skill_098 | DENS | 757.9 | extra_skill_095, extra_skill_090 |
| front_compression | DENS | 234.5 | crowd_ecology |
| line_pressure_1 | DENS | 99.8 | wave_bringer_1 |
| pressure_ladder | DENS | 343 | front_compression |
| wave_bringer_1 | DENS | 75.2 | encroaching_horde |
| wave_bringer_2 | DENS | 175 | wave_bringer_1 |
| collector_drone | ECON | 157.5 | taxonomy_scanner |
| extra_skill_001 | ECON | 97.6 | - |
| extra_skill_009 | ECON | 151.5 | extra_skill_006, extra_skill_001 |
| extra_skill_017 | ECON | 205.6 | extra_skill_014, extra_skill_009 |
| extra_skill_025 | ECON | 259.8 | extra_skill_022, extra_skill_017 |
| extra_skill_033 | ECON | 314.2 | extra_skill_030, extra_skill_025 |
| extra_skill_041 | ECON | 368.6 | extra_skill_038, extra_skill_033 |
| extra_skill_049 | ECON | 423.1 | extra_skill_046, extra_skill_041 |
| extra_skill_057 | ECON | 477.7 | extra_skill_054, extra_skill_049 |
| extra_skill_065 | ECON | 532.3 | extra_skill_062, extra_skill_057 |
| extra_skill_073 | ECON | 586.9 | extra_skill_070, extra_skill_065 |
| extra_skill_081 | ECON | 641.6 | extra_skill_078, extra_skill_073 |
| extra_skill_089 | ECON | 696.3 | extra_skill_086, extra_skill_081 |
| extra_skill_097 | ECON | 751.1 | extra_skill_094, extra_skill_089 |
| field_magnet | ECON | 50.8 | salvage_hooks |
| market_routing | ECON | 325.5 | collector_drone |
| run_yield_matrix | ECON | 539 | market_routing |
| salvage_hooks | ECON | 42 | - |
| salvage_hooks_2 | ECON | 217 | salvage_hooks |
| scrap_broker | ECON | 94.5 | supply_lenses |
| supply_lenses | ECON | 66.5 | field_magnet |
| taxonomy_scanner | ECON | 119 | scrap_broker |
| archer_pierce_unlock | MILESTONE | 126 | recruit_archer |
| auto_attack_unlock | MILESTONE | 105 | recruit_archer |
| guardian_fortify_unlock | MILESTONE | 217 | recruit_guardian |
| knight_vamp_unlock | MILESTONE | 112 | auto_attack_unlock |
| mage_storm_unlock | MILESTONE | 308 | recruit_mage |
| power_harvest_unlock | MILESTONE | 136.5 | recruit_archer |
| recruit_archer | MILESTONE | 98 | - |
| recruit_guardian | MILESTONE | 238 | archer_pierce_unlock |
| recruit_mage | MILESTONE | 343 | recruit_guardian, power_harvest_unlock |
| extra_skill_004 | MOVE | 117.8 | - |
| extra_skill_012 | MOVE | 171.7 | extra_skill_009, extra_skill_004 |
| extra_skill_020 | MOVE | 225.9 | extra_skill_017, extra_skill_012 |
| extra_skill_028 | MOVE | 280.2 | extra_skill_025, extra_skill_020 |
| extra_skill_036 | MOVE | 334.6 | extra_skill_033, extra_skill_028 |
| extra_skill_044 | MOVE | 389 | extra_skill_041, extra_skill_036 |
| extra_skill_052 | MOVE | 443.6 | extra_skill_049, extra_skill_044 |
| extra_skill_060 | MOVE | 498.1 | extra_skill_057, extra_skill_052 |
| extra_skill_068 | MOVE | 552.8 | extra_skill_065, extra_skill_060 |
| extra_skill_076 | MOVE | 607.4 | extra_skill_073, extra_skill_068 |
| extra_skill_084 | MOVE | 662.1 | extra_skill_081, extra_skill_076 |
| extra_skill_092 | MOVE | 716.8 | extra_skill_089, extra_skill_084 |
| extra_skill_100 | MOVE | 771.6 | extra_skill_097, extra_skill_092 |
| long_march | MOVE | 392 | pathline_sprint |
| momentum_carry | MOVE | 103.2 | stride_rhythm |
| pathline_sprint | MOVE | 259 | quickstep_chain |
| quickstep_chain | MOVE | 182 | route_memory |
| route_memory | MOVE | 126 | momentum_carry |
| stride_rhythm | MOVE | 73.5 | trail_boots |
| trail_boots | MOVE | 43.8 | - |
| condensed_cores_2_60 | POWR | 196 | condensed_cores_60 |
| condensed_cores_60 | POWR | 56 | - |
| extra_skill_005 | POWR | 124.5 | extra_skill_002 |
| extra_skill_013 | POWR | 178.5 | extra_skill_010, extra_skill_005 |
| extra_skill_021 | POWR | 232.7 | extra_skill_018, extra_skill_013 |
| extra_skill_029 | POWR | 287 | extra_skill_026, extra_skill_021 |
| extra_skill_037 | POWR | 341.4 | extra_skill_034, extra_skill_029 |
| extra_skill_045 | POWR | 395.9 | extra_skill_042, extra_skill_037 |
| extra_skill_053 | POWR | 450.4 | extra_skill_050, extra_skill_045 |
| extra_skill_061 | POWR | 505 | extra_skill_058, extra_skill_053 |
| extra_skill_069 | POWR | 559.6 | extra_skill_066, extra_skill_061 |
| extra_skill_077 | POWR | 614.2 | extra_skill_074, extra_skill_069 |
| extra_skill_085 | POWR | 668.9 | extra_skill_082, extra_skill_077 |
| extra_skill_093 | POWR | 723.7 | extra_skill_090, extra_skill_085 |
| overflow_capture | POWR | 115.5 | power_reservoir_1_60 |
| power_echo | POWR | 273 | condensed_cores_2_60 |
| power_reservoir_1_60 | POWR | 84 | condensed_cores_60 |
| power_reservoir_2_60 | POWR | 143.5 | power_reservoir_1_60 |
| power_reservoir_3_60 | POWR | 413 | power_reservoir_2_60 |
| dot_deflector | SURV | 255.5 | hemostasis_mesh |
| extra_skill_003 | SURV | 111 | - |
| extra_skill_011 | SURV | 165 | extra_skill_008, extra_skill_003 |
| extra_skill_019 | SURV | 219.1 | extra_skill_016, extra_skill_011 |
| extra_skill_027 | SURV | 273.4 | extra_skill_024, extra_skill_019 |
| extra_skill_035 | SURV | 327.8 | extra_skill_032, extra_skill_027 |
| extra_skill_043 | SURV | 382.2 | extra_skill_040, extra_skill_035 |
| extra_skill_051 | SURV | 436.7 | extra_skill_048, extra_skill_043 |
| extra_skill_059 | SURV | 491.3 | extra_skill_056, extra_skill_051 |
| extra_skill_067 | SURV | 545.9 | extra_skill_064, extra_skill_059 |
| extra_skill_075 | SURV | 600.6 | extra_skill_072, extra_skill_067 |
| extra_skill_083 | SURV | 655.3 | extra_skill_080, extra_skill_075 |
| extra_skill_091 | SURV | 710 | extra_skill_088, extra_skill_083 |
| extra_skill_099 | SURV | 764.7 | extra_skill_096, extra_skill_091 |
| hemostasis_mesh | SURV | 105 | impact_weave |
| impact_weave | SURV | 80.5 | reinforced_plates |
| layered_carapace | SURV | 182 | shock_padding |
| reinforced_plates | SURV | 49 | - |
| shock_padding | SURV | 129.5 | hemostasis_mesh |
| shock_sink | SURV | 371 | dot_deflector |
| archer_drill_1_60 | TEAM | 126 | flag:archer_unlocked |
| archer_drill_2_60 | TEAM | 483 | archer_drill_1_60 |
| archer_piercing_geometry_60 | TEAM | 143.5 | flag:archer_unlocked |
| extra_skill_008 | TEAM | 144.7 | extra_skill_005, flag:guardian_unlocked |
| extra_skill_016 | TEAM | 198.8 | extra_skill_013, extra_skill_008, flag:guardian_unlocked |
| extra_skill_024 | TEAM | 253 | extra_skill_021, extra_skill_016, flag:archer_unlocked, flag:guardian_unlocked |
| extra_skill_032 | TEAM | 307.4 | extra_skill_029, extra_skill_024, flag:guardian_unlocked |
| extra_skill_040 | TEAM | 361.8 | extra_skill_037, extra_skill_032, flag:guardian_unlocked, flag:mage_unlocked |
| extra_skill_048 | TEAM | 416.3 | extra_skill_045, extra_skill_040, flag:archer_unlocked, flag:guardian_unlocked |
| extra_skill_056 | TEAM | 470.8 | extra_skill_053, extra_skill_048, flag:guardian_unlocked |
| extra_skill_064 | TEAM | 525.4 | extra_skill_061, extra_skill_056, flag:guardian_unlocked |
| extra_skill_072 | TEAM | 580.1 | extra_skill_069, extra_skill_064, flag:archer_unlocked, flag:guardian_unlocked |
| extra_skill_080 | TEAM | 634.8 | extra_skill_077, extra_skill_072, flag:guardian_unlocked, flag:mage_unlocked |
| extra_skill_088 | TEAM | 689.5 | extra_skill_085, extra_skill_080, flag:guardian_unlocked |
| extra_skill_096 | TEAM | 744.2 | extra_skill_093, extra_skill_088, flag:archer_unlocked, flag:guardian_unlocked |
| guardian_bulwark_1_60 | TEAM | 182 | flag:guardian_unlocked |
| guardian_bulwark_2_60 | TEAM | 357 | guardian_bulwark_1_60 |
| knight_bloodline_1_60 | TEAM | 73.5 | - |
| knight_bloodline_2_60 | TEAM | 245 | knight_bloodline_1_60 |
| mage_sigil_1_60 | TEAM | 266 | flag:mage_unlocked |
| mage_sigil_2_60 | TEAM | 511 | mage_sigil_1_60 |
