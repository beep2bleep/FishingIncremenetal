extends RefCounted
class_name OpenPitEmpireBalance

const MAX_DEPTH_LEVEL := 5
const MIN_START_DEPTH_LEVEL := 1
const PLANET_LAYOUT_VERSION := 3
const XP_PREFIX := "xp:"
const CORE_PREFIX := "core:"
const XP_ORDER := [
    "packet_sniffer", "trace_scrubber", "heap_climber", "cache_warmers",
    "deep_scan", "sidechannel", "zero_day", "crash_cartography",
    "kernel_rehearsal", "deep_manifest", "thermal_mapping", "vault_heuristics",
    "graveyard_index", "mirror_daemons", "inversion_ledger", "fault_oracles",
    "null_archive", "ash_scriptures"
]
const XP_LAYOUT := {
    "xp:packet_sniffer": Vector2(-24, 2),
    "xp:trace_scrubber": Vector2(-22, 2),
    "xp:heap_climber": Vector2(-20, 2),
    "xp:cache_warmers": Vector2(-24, 6),
    "xp:deep_scan": Vector2(-22, 6),
    "xp:sidechannel": Vector2(-20, 6),
    "xp:zero_day": Vector2(-24, 10),
    "xp:crash_cartography": Vector2(-22, 10),
    "xp:kernel_rehearsal": Vector2(-20, 10),
    "xp:deep_manifest": Vector2(-24, 14),
    "xp:thermal_mapping": Vector2(-22, 14),
    "xp:vault_heuristics": Vector2(-20, 14),
    "xp:graveyard_index": Vector2(-24, 18),
    "xp:mirror_daemons": Vector2(-22, 18),
    "xp:inversion_ledger": Vector2(-20, 18),
    "xp:fault_oracles": Vector2(-24, 22),
    "xp:null_archive": Vector2(-22, 22),
    "xp:ash_scriptures": Vector2(-20, 22),
}
const XP_CONNECTIONS := {
    "xp:packet_sniffer": [],
    "xp:trace_scrubber": ["xp:packet_sniffer"],
    "xp:heap_climber": ["xp:trace_scrubber"],
    "xp:cache_warmers": ["xp:heap_climber"],
    "xp:deep_scan": ["xp:cache_warmers"],
    "xp:sidechannel": ["xp:deep_scan"],
    "xp:zero_day": ["xp:sidechannel"],
    "xp:crash_cartography": ["xp:zero_day"],
    "xp:kernel_rehearsal": ["xp:crash_cartography"],
    "xp:deep_manifest": ["xp:kernel_rehearsal"],
    "xp:thermal_mapping": ["xp:deep_manifest"],
    "xp:vault_heuristics": ["xp:thermal_mapping"],
    "xp:graveyard_index": ["xp:vault_heuristics"],
    "xp:mirror_daemons": ["xp:graveyard_index"],
    "xp:inversion_ledger": ["xp:mirror_daemons"],
    "xp:fault_oracles": ["xp:inversion_ledger"],
    "xp:null_archive": ["xp:fault_oracles"],
    "xp:ash_scriptures": ["xp:null_archive"],
}
const XP_UPGRADES := {
    "packet_sniffer": {"base_cost": 24, "cost_mult": 1.75, "max_level": 4, "label": "Packet Sniffer", "summary": "+28% XP from mined blocks per level.", "icon": "X", "effects": {"xp_gain_mult": 0.28}},
    "trace_scrubber": {"base_cost": 36, "cost_mult": 1.75, "max_level": 4, "label": "Trace Scrubber", "summary": "+5 seconds of run time per level.", "icon": "T", "effects": {"fuel_expand": 5.0}},
    "heap_climber": {"base_cost": 42, "cost_mult": 1.80, "max_level": 4, "label": "Heap Climber", "summary": "+18 cargo capacity per level.", "icon": "H", "effects": {"cargo_expand": 18.0}},
    "cache_warmers": {"base_cost": 34, "cost_mult": 1.75, "max_level": 4, "label": "Cache Warmers", "summary": "+30 move speed per level.", "icon": "C", "effects": {"speed": 30.0}},
    "deep_scan": {"base_cost": 54, "cost_mult": 1.85, "max_level": 4, "label": "Deep Scan", "summary": "+14 range and pickup radius per level.", "icon": "D", "effects": {"range": 14.0, "magnet": 14.0}},
    "sidechannel": {"base_cost": 70, "cost_mult": 1.90, "max_level": 4, "label": "Sidechannel", "summary": "+4 payout per block per level.", "icon": "S", "effects": {"resource_flat": 4.0}},
    "zero_day": {"base_cost": 120, "cost_mult": 2.00, "max_level": 3, "label": "Zero-Day", "summary": "+32% XP from mined blocks per level.", "icon": "Z", "effects": {"xp_gain_mult": 0.32}},
    "crash_cartography": {"base_cost": 150, "cost_mult": 2.00, "max_level": 3, "label": "Crash Cartography", "summary": "+8% global damage per level.", "icon": "M", "effects": {"global_damage_mult": 0.08}},
    "kernel_rehearsal": {"base_cost": 180, "cost_mult": 2.05, "max_level": 3, "label": "Kernel Rehearsal", "summary": "+12% damage to daemon cores per level.", "icon": "K", "effects": {"core_damage_mult": 0.12}},
    "deep_manifest": {"base_cost": 260, "cost_mult": 2.00, "max_level": 4, "label": "Deep Manifest", "summary": "+6 payout and +5% global damage per level.", "icon": "M", "effects": {"resource_flat": 6.0, "global_damage_mult": 0.05}},
    "thermal_mapping": {"base_cost": 520, "cost_mult": 2.05, "max_level": 4, "label": "Thermal Mapping", "summary": "+16 range and +20 move speed per level.", "icon": "T", "effects": {"range": 16.0, "speed": 20.0}},
    "vault_heuristics": {"base_cost": 340, "cost_mult": 2.05, "max_level": 4, "label": "Vault Heuristics", "summary": "+5 damage and +10 range per level.", "icon": "V", "effects": {"damage_flat": 5.0, "range": 10.0}},
    "graveyard_index": {"base_cost": 750, "cost_mult": 2.05, "max_level": 4, "label": "Graveyard Index", "summary": "+14% XP and +6 payout per level.", "icon": "G", "effects": {"xp_gain_mult": 0.14, "resource_flat": 6.0}},
    "mirror_daemons": {"base_cost": 1100, "cost_mult": 2.10, "max_level": 4, "label": "Mirror Daemons", "summary": "Unlocks deeper electric chaining and +1 range step per level.", "icon": "M", "effects": {"electric_unlock": true, "electric_range": 1}},
    "inversion_ledger": {"base_cost": 1850, "cost_mult": 2.10, "max_level": 4, "label": "Inversion Ledger", "summary": "+16% XP and +8 payout per level.", "icon": "I", "effects": {"xp_gain_mult": 0.16, "resource_flat": 8.0}},
    "fault_oracles": {"base_cost": 2800, "cost_mult": 2.12, "max_level": 4, "label": "Fault Oracles", "summary": "Unlock chain lightning and add +1 chain depth per level.", "icon": "F", "effects": {"chain_lightning_unlock": true, "electric_chain": 1}},
    "null_archive": {"base_cost": 4300, "cost_mult": 2.12, "max_level": 4, "label": "Null Archive", "summary": "Boost resonance and chain depth per level.", "icon": "N", "effects": {"resonance_enhance": 0.25, "electric_chain": 1}},
    "ash_scriptures": {"base_cost": 6800, "cost_mult": 2.14, "max_level": 4, "label": "Ash Scriptures", "summary": "Late inversion scripture: more XP and resonance per level.", "icon": "A", "effects": {"xp_gain_mult": 0.18, "resonance_enhance": 0.2}},
}
const CORE_ORDER := [
    "core_detect", "spawn_direction", "brake",
    "barrier_regen", "return_shortcut", "emergency_return",
    "core_focus", "kernel_breach", "center_unlock",
    "core_siphon", "salvage_limiter", "mantle_permits",
    "inversion_tether", "voidfire_brakes", "mirror_keys",
    "fault_insulation", "null_anchor", "ash_ward",
    "planet_mastery"
]
const CORE_LAYOUT := {
    "core:core_detect": Vector2(24, 2),
    "core:spawn_direction": Vector2(26, 2),
    "core:brake": Vector2(28, 2),
    "core:barrier_regen": Vector2(24, 6),
    "core:return_shortcut": Vector2(26, 6),
    "core:emergency_return": Vector2(28, 6),
    "core:core_focus": Vector2(24, 10),
    "core:kernel_breach": Vector2(26, 10),
    "core:center_unlock": Vector2(28, 10),
    "core:core_siphon": Vector2(24, 14),
    "core:salvage_limiter": Vector2(26, 14),
    "core:mantle_permits": Vector2(28, 14),
    "core:inversion_tether": Vector2(24, 18),
    "core:voidfire_brakes": Vector2(26, 18),
    "core:mirror_keys": Vector2(28, 18),
    "core:fault_insulation": Vector2(24, 22),
    "core:null_anchor": Vector2(26, 22),
    "core:ash_ward": Vector2(28, 22),
    "core:planet_mastery": Vector2(26, 26),
}
const CORE_CONNECTIONS := {
    "core:core_detect": [],
    "core:spawn_direction": ["core:core_detect"],
    "core:brake": ["core:spawn_direction"],
    "core:barrier_regen": ["core:brake"],
    "core:return_shortcut": ["core:barrier_regen"],
    "core:emergency_return": ["core:return_shortcut"],
    "core:core_focus": ["core:emergency_return"],
    "core:kernel_breach": ["core:core_focus"],
    "core:center_unlock": ["core:kernel_breach"],
    "core:core_siphon": ["core:center_unlock"],
    "core:salvage_limiter": ["core:core_siphon"],
    "core:mantle_permits": ["core:salvage_limiter"],
    "core:inversion_tether": ["core:mantle_permits"],
    "core:voidfire_brakes": ["core:inversion_tether"],
    "core:mirror_keys": ["core:voidfire_brakes"],
    "core:fault_insulation": ["core:mirror_keys"],
    "core:null_anchor": ["core:fault_insulation"],
    "core:ash_ward": ["core:null_anchor"],
    "core:planet_mastery": ["core:ash_ward"],
}
const CORE_UPGRADES := {
    "core_detect": {"base_cost": 1, "cost_mult": 1.0, "max_level": 1, "label": "Signal Sniffer", "summary": "Shows daemon weak points and adds +10% core damage.", "icon": "C", "effects": {"core_damage_mult": 0.10}},
    "spawn_direction": {"base_cost": 1, "cost_mult": 1.0, "max_level": 1, "label": "Ghost Entry", "summary": "Unlock alternate insertion vectors when starting a run.", "icon": "G", "effects": {}},
    "brake": {"base_cost": 1, "cost_mult": 1.0, "max_level": 1, "label": "Pressure Vent", "summary": "Improves steering response and adds +35 move speed.", "icon": "P", "effects": {"speed": 35.0}},
    "barrier_regen": {"base_cost": 2, "cost_mult": 1.0, "max_level": 1, "label": "Barrier Patch", "summary": "Restore 1 barrier after each successful extraction.", "icon": "B", "effects": {"barrier": 1}},
    "return_shortcut": {"base_cost": 2, "cost_mult": 1.0, "max_level": 1, "label": "Backdoor Exit", "summary": "Makes the extraction zone larger and easier to reach.", "icon": "E", "effects": {}},
    "emergency_return": {"base_cost": 2, "cost_mult": 1.0, "max_level": 1, "label": "Panic Tunnel", "summary": "Fuel failure triggers an emergency extraction instead of losing the run.", "icon": "P", "effects": {}},
    "core_focus": {"base_cost": 3, "cost_mult": 1.0, "max_level": 1, "label": "Daemon Focus", "summary": "Improves lock-on against daemon cores and adds +25% core damage.", "icon": "D", "effects": {"core_damage_mult": 0.25}},
    "kernel_breach": {"base_cost": 3, "cost_mult": 1.0, "max_level": 1, "label": "Kernel Breach", "summary": "Breach the kernel tier and add +12% core damage.", "icon": "K", "effects": {"core_damage_mult": 0.12}},
    "center_unlock": {"base_cost": 4, "cost_mult": 1.0, "max_level": 1, "label": "Root Access", "summary": "Unlock attacks against the deepest root kernel at the center.", "icon": "R", "effects": {}},
    "core_siphon": {"base_cost": 4, "cost_mult": 1.0, "max_level": 1, "label": "Core Siphon", "summary": "Add +10 payout per block after each daemon breach.", "icon": "S", "effects": {"resource_flat": 10.0}},
    "salvage_limiter": {"base_cost": 5, "cost_mult": 1.0, "max_level": 1, "label": "Salvage Limiter", "summary": "Keep 50% of your haul even on a failed run.", "icon": "L", "effects": {"fuel_loss_reduce": 0.5}},
    "mantle_permits": {"base_cost": 7, "cost_mult": 1.0, "max_level": 1, "label": "Mantle Permits", "summary": "Deep permit layer breaker. Adds +12% global damage.", "icon": "M", "effects": {"global_damage_mult": 0.12}},
    "inversion_tether": {"base_cost": 6, "cost_mult": 1.0, "max_level": 1, "label": "Inversion Tether", "summary": "Unlock deeper resonance control and add +0.3 resonance power.", "icon": "I", "effects": {"resonance_unlock": true, "resonance_enhance": 0.3}},
    "voidfire_brakes": {"base_cost": 8, "cost_mult": 1.0, "max_level": 1, "label": "Voidfire Brakes", "summary": "Stabilize late pits and add +45 move speed.", "icon": "V", "effects": {"speed": 45.0}},
    "mirror_keys": {"base_cost": 9, "cost_mult": 1.0, "max_level": 1, "label": "Mirror Keys", "summary": "Unlock crit routing and add +12 damage.", "icon": "M", "effects": {"critical_unlock": true, "damage_flat": 12.0}},
    "fault_insulation": {"base_cost": 10, "cost_mult": 1.0, "max_level": 1, "label": "Fault Insulation", "summary": "Adds 1 barrier for late inversion routes.", "icon": "F", "effects": {"barrier": 1}},
    "null_anchor": {"base_cost": 12, "cost_mult": 1.0, "max_level": 1, "label": "Null Anchor", "summary": "Anchors extra targeting lanes for one more multi-target beam.", "icon": "N", "effects": {"multi_laser": 1}},
    "ash_ward": {"base_cost": 14, "cost_mult": 1.0, "max_level": 1, "label": "Ash Ward", "summary": "Adds 1 barrier and empowers overdrive.", "icon": "A", "effects": {"barrier": 1, "overdrive_enhance": true}},
    "planet_mastery": {"base_cost": 14, "cost_mult": 1.0, "max_level": 1, "label": "Demo Lock Override", "summary": "After clearing the pit, unlock full regeneration control.", "icon": "O", "effects": {"global_resource_mult": 0.15}},
}

const PHASE_BRIDGES := {
    2: {"gate": "ore_appraisal", "entry": "barrier_mesh"},
    3: {"gate": "daemon_lances", "entry": "root_breaker"},
    4: {"gate": "fault_charges", "entry": "void_cutters"},
    5: {"gate": "abyssal_rigs", "entry": "mirror_saws"},
}

const PHASE_NODE_ORDER := {
    1: ["start", "laser_cutter", "cargo_racks", "fuel_cells", "auto_salvage", "minimap", "rapid_cycle", "ore_appraisal"],
    2: ["barrier_mesh", "shock_bits", "breach_drones", "salvage_contract", "funnel_resonance", "daemon_lances"],
    3: ["root_breaker", "overburn_reactors", "seismic_lattice", "mantle_drills", "fault_charges"],
    4: ["void_cutters", "inversion_drives", "vault_pulsers", "gravity_wells", "abyssal_rigs"],
    5: ["mirror_saws", "fault_harpoons", "null_borers", "ash_crowns"],
}

const PHASE_COLS := 3
const PHASE_OFFSETS := {
    1: Vector2(2, 2),
    2: Vector2(12, 2),
    3: Vector2(12, 12),
    4: Vector2(2, 12),
    5: Vector2(2, 22),
}

const RAW_NODE_DATA := {
    "laser_cutter": {"base_cost": 60, "cost_mult": 1.55, "max_level": 8, "phase": 1, "label": "Laser Cutter", "summary": "+2 laser damage per level.", "icon": "L", "effects": {"damage_flat": 2.0}},
    "cargo_racks": {"base_cost": 65, "cost_mult": 1.52, "max_level": 7, "phase": 1, "label": "Cargo Racks", "summary": "+20 cargo capacity per level.", "icon": "C", "effects": {"cargo_expand": 20.0}},
    "fuel_cells": {"base_cost": 60, "cost_mult": 1.55, "max_level": 6, "phase": 1, "label": "Fuel Cells", "summary": "+3 seconds of run time and +20 move speed per level.", "icon": "F", "effects": {"fuel_expand": 3.0, "speed": 20.0}},
    "auto_salvage": {"base_cost": 95, "cost_mult": 1.0, "max_level": 1, "phase": 1, "label": "Auto Salvage", "summary": "Automatically collects mined cash instantly with no world pickups.", "icon": "A", "effects": {"instant_collect": true}},
    "minimap": {"base_cost": 85, "cost_mult": 1.0, "max_level": 1, "phase": 1, "label": "Minimap", "summary": "Unlock the pit minimap during runs.", "icon": "M", "effects": {"minimap_unlock": true}},
    "rapid_cycle": {"base_cost": 70, "cost_mult": 1.58, "max_level": 7, "phase": 1, "label": "Rapid Cycle", "summary": "-0.04 attack interval per level.", "icon": "R", "effects": {"fire_rate": -0.04}},
    "ore_appraisal": {"base_cost": 80, "cost_mult": 1.60, "max_level": 6, "phase": 1, "label": "Ore Appraisal", "summary": "+3 payout per mined block per level.", "icon": "$", "effects": {"resource_flat": 3.0}},
    "barrier_mesh": {"base_cost": 140, "cost_mult": 1.90, "max_level": 3, "phase": 2, "label": "Barrier Mesh", "summary": "+1 barrier per level. Buying any phase-2 node unlocks Empire Layer 2 runs after clearing the first layer.", "icon": "B", "effects": {"barrier": 1}},
    "shock_bits": {"base_cost": 190, "cost_mult": 1.75, "max_level": 4, "phase": 2, "label": "Shock Bits", "summary": "+3 damage per level, unlock electric shots, and extend electric reach.", "icon": "E", "effects": {"damage_flat": 3.0, "electric_unlock": true, "electric_range": 1}},
    "breach_drones": {"base_cost": 260, "cost_mult": 1.80, "max_level": 4, "phase": 2, "label": "Breach Drones", "summary": "Unlock drones; each level adds a drone and improves drone damage.", "icon": "D", "effects": {"drone_unlock": true, "drone_add": 1, "drone_damage_up": 4.0}},
    "salvage_contract": {"base_cost": 220, "cost_mult": 1.75, "max_level": 4, "phase": 2, "label": "Salvage Contract", "summary": "Keep 8% of your haul on failed runs per level.", "icon": "S", "effects": {"fuel_loss_reduce": 0.08}},
    "funnel_resonance": {"base_cost": 420, "cost_mult": 1.90, "max_level": 4, "phase": 2, "label": "Funnel Resonance", "summary": "Unlock resonance and add +0.25 resonance power per level.", "icon": "N", "effects": {"resonance_unlock": true, "resonance_enhance": 0.25}},
    "daemon_lances": {"base_cost": 520, "cost_mult": 1.85, "max_level": 4, "phase": 2, "label": "Daemon Lances", "summary": "+6 damage per level focused into daemon cores.", "icon": "K", "effects": {"damage_flat": 6.0, "core_damage_mult": 0.06}},
    "root_breaker": {"base_cost": 980, "cost_mult": 2.00, "max_level": 3, "phase": 3, "label": "Root Breaker", "summary": "Unlock 3x damage against daemon cores. Buying any phase-3 node unlocks Empire Layer 3 runs after clearing the second layer.", "icon": "X", "effects": {"core_breaker_unlock": true}},
    "overburn_reactors": {"base_cost": 1800, "cost_mult": 1.85, "max_level": 4, "phase": 3, "label": "Overburn Reactors", "summary": "Unlock shockwaves and reduce kill requirements per level.", "icon": "O", "effects": {"shockwave_unlock": true, "shockwave_enhance": true}},
    "seismic_lattice": {"base_cost": 2600, "cost_mult": 1.85, "max_level": 4, "phase": 3, "label": "Seismic Lattice", "summary": "Unlock splash mining and further improve shockwaves.", "icon": "S", "effects": {"aoe_mining_unlock": true, "shockwave_enhance": true}},
    "mantle_drills": {"base_cost": 9000, "cost_mult": 1.92, "max_level": 4, "phase": 3, "label": "Mantle Drills", "summary": "+8 damage and +10 range per level.", "icon": "M", "effects": {"damage_flat": 8.0, "range": 10.0}},
    "fault_charges": {"base_cost": 11000, "cost_mult": 1.95, "max_level": 4, "phase": 3, "label": "Fault Charges", "summary": "Unlock charged shots and add +6 damage per level.", "icon": "F", "effects": {"charged_shot_unlock": true, "damage_flat": 6.0}},
    "void_cutters": {"base_cost": 4200, "cost_mult": 1.95, "max_level": 5, "phase": 4, "label": "Void Cutters", "summary": "+16 range and +6 damage per level. Buying any phase-4 node unlocks Empire Layer 4 runs after clearing the third layer.", "icon": "V", "effects": {"range": 16.0, "damage_flat": 6.0}},
    "inversion_drives": {"base_cost": 5800, "cost_mult": 1.90, "max_level": 4, "phase": 4, "label": "Inversion Drives", "summary": "+40 move speed per level and unlock overdrive.", "icon": "I", "effects": {"speed": 40.0, "overdrive_unlock": true}},
    "vault_pulsers": {"base_cost": 18000, "cost_mult": 1.95, "max_level": 5, "phase": 4, "label": "Vault Pulsers", "summary": "Unlock mega laser and improve its charge rate per level.", "icon": "P", "effects": {"mega_laser_unlock": true, "mega_enhance": true}},
    "gravity_wells": {"base_cost": 26000, "cost_mult": 1.90, "max_level": 4, "phase": 4, "label": "Gravity Wells", "summary": "+18 pickup radius and +0.2 resonance power per level.", "icon": "G", "effects": {"magnet": 18.0, "resonance_enhance": 0.2}},
    "abyssal_rigs": {"base_cost": 42000, "cost_mult": 1.92, "max_level": 5, "phase": 4, "label": "Abyssal Rigs", "summary": "+40 cargo capacity and +8 payout per level.", "icon": "A", "effects": {"cargo_expand": 40.0, "resource_flat": 8.0}},
    "mirror_saws": {"base_cost": 62000, "cost_mult": 1.94, "max_level": 4, "phase": 5, "label": "Mirror Saws", "summary": "Unlock crits and add +12 damage per level. Buying any phase-5 node unlocks Empire Layer 5 runs after clearing the fourth layer.", "icon": "M", "effects": {"critical_unlock": true, "damage_flat": 12.0}},
    "fault_harpoons": {"base_cost": 92000, "cost_mult": 1.95, "max_level": 4, "phase": 5, "label": "Fault Harpoons", "summary": "Unlock chain lightning and add +1 chain depth per level.", "icon": "H", "effects": {"chain_lightning_unlock": true, "electric_chain": 1}},
    "null_borers": {"base_cost": 138000, "cost_mult": 1.96, "max_level": 4, "phase": 5, "label": "Null Borers", "summary": "+14 damage, +1 multi-target, and deeper electric chains per level.", "icon": "N", "effects": {"damage_flat": 14.0, "multi_laser": 1, "electric_chain": 1}},
    "ash_crowns": {"base_cost": 220000, "cost_mult": 1.98, "max_level": 5, "phase": 5, "label": "Ash Crowns", "summary": "Late inversion crown: boosts payout and empowers mega and overdrive.", "icon": "A", "effects": {"resource_flat": 12.0, "mega_enhance": true, "overdrive_enhance": true}},
}

const LAYER_DATA := [
    {"name": "Proxy Cache", "value": 4, "health": 24.0, "color": Color(0.16, 0.21, 0.29, 1.0), "accent": Color(0.52, 0.74, 0.98, 1.0)},
    {"name": "Cipher Depths", "value": 14, "health": 68.0, "color": Color(0.22, 0.28, 0.24, 1.0), "accent": Color(0.25, 0.9, 0.72, 1.0)},
    {"name": "Ghost Sector", "value": 42, "health": 168.0, "color": Color(0.3, 0.18, 0.12, 1.0), "accent": Color(0.96, 0.64, 0.24, 1.0)},
    {"name": "Kernel Vault", "value": 110, "health": 360.0, "color": Color(0.2, 0.14, 0.28, 1.0), "accent": Color(0.84, 0.5, 1.0, 1.0)},
    {"name": "Root Well", "value": 320, "health": 920.0, "color": Color(0.32, 0.06, 0.08, 1.0), "accent": Color(1.0, 0.36, 0.28, 1.0)},
]

static func get_upgrade_catalog() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for phase in PHASE_NODE_ORDER.keys():
        for upgrade_id in PHASE_NODE_ORDER[phase]:
            if upgrade_id == "start":
                continue
            var raw: Dictionary = RAW_NODE_DATA.get(upgrade_id, {})
            if raw.is_empty():
                continue
            result.append({
                "id": upgrade_id,
                "label": str(raw.get("label", _get_label(upgrade_id))),
                "summary": str(raw.get("summary", _get_summary(upgrade_id, raw.get("effects", {})))),
                "base_cost": int(raw.get("base_cost", 0)),
                "cost_mult": float(raw.get("cost_mult", 1.0)),
                "max_level": int(raw.get("max_level", 1)),
                "phase": int(raw.get("phase", phase)),
                "icon": str(raw.get("icon", _get_icon(upgrade_id))),
            })
    return result

static func get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
    var raw: Dictionary = RAW_NODE_DATA.get(upgrade_id, {})
    if raw.is_empty():
        return 0
    return int(round(float(raw.get("base_cost", 0)) * pow(float(raw.get("cost_mult", 1.0)), current_level)))

static func get_core_upgrade_catalog() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for upgrade_id in CORE_ORDER:
        var raw: Dictionary = CORE_UPGRADES.get(upgrade_id, {})
        if raw.is_empty():
            continue
        result.append({
            "id": CORE_PREFIX + upgrade_id,
            "label": str(raw.get("label", upgrade_id)),
            "summary": str(raw.get("summary", "Core upgrade.")),
            "base_cost": int(raw.get("base_cost", 0)),
            "cost_mult": float(raw.get("cost_mult", 1.0)),
            "max_level": int(raw.get("max_level", 1)),
            "phase": 1,
            "icon": "C",
        })
    return result

static func get_xp_upgrade_catalog() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for upgrade_id in XP_ORDER:
        var raw: Dictionary = XP_UPGRADES.get(upgrade_id, {})
        if raw.is_empty():
            continue
        result.append({
            "id": XP_PREFIX + upgrade_id,
            "label": str(raw.get("label", upgrade_id)),
            "summary": str(raw.get("summary", "XP upgrade.")),
            "base_cost": int(raw.get("base_cost", 0)),
            "cost_mult": float(raw.get("cost_mult", 1.0)),
            "max_level": int(raw.get("max_level", 1)),
            "phase": 1,
            "icon": str(raw.get("icon", "X")),
        })
    return result

static func get_xp_upgrade_cost(prefixed_upgrade_id: String, current_level: int) -> int:
    var upgrade_id: String = prefixed_upgrade_id.trim_prefix(XP_PREFIX)
    var raw: Dictionary = XP_UPGRADES.get(upgrade_id, {})
    if raw.is_empty():
        return 0
    return int(round(float(raw.get("base_cost", 0)) * pow(float(raw.get("cost_mult", 1.0)), current_level)))

static func get_xp_upgrade_cell(prefixed_upgrade_id: String) -> Vector2:
    return Vector2(XP_LAYOUT.get(prefixed_upgrade_id, Vector2(-16, 2)))

static func get_xp_upgrade_dependency(prefixed_upgrade_id: String) -> String:
    var deps: Array = XP_CONNECTIONS.get(prefixed_upgrade_id, [])
    return str(deps[0]) if not deps.is_empty() else ""

static func get_core_upgrade_cost(prefixed_upgrade_id: String, current_level: int) -> int:
    var upgrade_id: String = prefixed_upgrade_id.trim_prefix(CORE_PREFIX)
    var raw: Dictionary = CORE_UPGRADES.get(upgrade_id, {})
    if raw.is_empty():
        return 0
    return int(round(float(raw.get("base_cost", 0)) * pow(float(raw.get("cost_mult", 1.0)), current_level)))

static func get_core_upgrade_cell(prefixed_upgrade_id: String) -> Vector2:
    return Vector2(CORE_LAYOUT.get(prefixed_upgrade_id, Vector2(-10, 4)))

static func get_core_upgrade_dependency(prefixed_upgrade_id: String) -> String:
    var deps: Array = CORE_CONNECTIONS.get(prefixed_upgrade_id, [])
    return str(deps[0]) if not deps.is_empty() else ""

static func is_core_upgrade(upgrade_id: String) -> bool:
    return upgrade_id.begins_with(CORE_PREFIX)

static func is_xp_upgrade(upgrade_id: String) -> bool:
    return upgrade_id.begins_with(XP_PREFIX)

static func get_upgrade_cell(upgrade_id: String) -> Vector2:
    for phase in PHASE_NODE_ORDER.keys():
        var order: Array = PHASE_NODE_ORDER[phase]
        var idx: int = order.find(upgrade_id)
        if idx < 0:
            continue
        return Vector2(PHASE_OFFSETS.get(phase, Vector2.ZERO)) + Vector2((idx % PHASE_COLS) * 2, (idx / PHASE_COLS) * 2)
    return Vector2.ZERO

static func get_upgrade_dependency(upgrade_id: String) -> String:
    for phase in PHASE_NODE_ORDER.keys():
        var order: Array = PHASE_NODE_ORDER[phase]
        var idx: int = order.find(upgrade_id)
        if idx < 0:
            continue
        var bridge: Dictionary = PHASE_BRIDGES.get(phase, {})
        if str(bridge.get("entry", "")) == upgrade_id:
            return str(bridge.get("gate", ""))
        if idx % PHASE_COLS > 0:
            return str(order[idx - 1])
        if idx - PHASE_COLS >= 0:
            return str(order[idx - PHASE_COLS])
        if phase > 1:
            return str(PHASE_BRIDGES.get(phase, {}).get("gate", ""))
        return ""
    return ""

static func refresh_depth_unlocks(data: Dictionary) -> void:
    var upgrades: Dictionary = data.get("upgrades", {})
    var unlocked_phase := MIN_START_DEPTH_LEVEL
    for upgrade_id in upgrades.keys():
        if int(upgrades.get(upgrade_id, 0)) <= 0:
            continue
        unlocked_phase = max(unlocked_phase, int(RAW_NODE_DATA.get(str(upgrade_id), {}).get("phase", 1)))
    data["deepest_level_unlocked"] = clampi(max(int(data.get("deepest_level_unlocked", MIN_START_DEPTH_LEVEL)), unlocked_phase), MIN_START_DEPTH_LEVEL, MAX_DEPTH_LEVEL)
    data["selected_depth_level"] = clampi(int(data.get("selected_depth_level", data["deepest_level_unlocked"])), MIN_START_DEPTH_LEVEL, int(data["deepest_level_unlocked"]))

static func get_layer_for_depth(depth_level: int) -> Dictionary:
    return LAYER_DATA[clampi(depth_level - 1, 0, LAYER_DATA.size() - 1)].duplicate(true)

static func build_runtime_stats(upgrades: Dictionary, xp_upgrades: Dictionary = {}, core_upgrades: Dictionary = {}) -> Dictionary:
    var damage_flat := 0.0
    var fire_rate_mod := 0.0
    var speed_bonus := 0.0
    var range_bonus := 0.0
    var cargo_bonus := 0.0
    var fuel_bonus := 0.0
    var fuel_efficiency := 1.0
    var salvage_keep := 0.0
    var resource_flat := 0.0
    var gold_bonus_flat := 0.0
    var multi_laser_bonus := 0
    var magnet_bonus := 0.0
    var barrier_bonus := 0
    var combo_bonus := 0.0
    var xp_gain_mult := 1.0
    var electric_range_bonus := 0
    var electric_chain_bonus := 0
    var drone_damage_bonus := 0.0
    var drone_count_bonus := 0
    var drone_fire_bonus := 0.0
    var drone_pierce_bonus := 0
    var resonance_bonus := 0.0
    var mega_enhance_count := 0
    var shockwave_enhance_count := 0
    var global_damage_mult := 1.0
    var global_resource_mult := 1.0
    var core_damage_mult := 1.0
    var zone_dmg := [1.0, 1.0, 1.0, 1.0]
    var zone_res := [1.0, 1.0, 1.0, 1.0]
    var flags := {
        "critical_unlock": false, "charged_shot_unlock": false, "electric_unlock": false, "gold_unlock": false,
        "drone_unlock": false, "chain_lightning_unlock": false, "resonance_unlock": false, "shockwave_unlock": false,
        "overdrive_unlock": false, "core_breaker_unlock": false, "aoe_mining_unlock": false, "combo_unlock": false,
        "minimap_unlock": false, "instant_collect": false, "drone_sync_unlock": false, "drone_crit_unlock": false,
        "drone_overclock": false, "mega_laser_unlock": false, "overdrive_enhance": false,
    }
    for upgrade_id in upgrades.keys():
        var level: int = int(upgrades.get(upgrade_id, 0))
        if level <= 0:
            continue
        var effects: Dictionary = RAW_NODE_DATA.get(str(upgrade_id), {}).get("effects", {})
        for effect_key in effects.keys():
            var effect_id: String = str(effect_key)
            var effect_value: Variant = effects[effect_key]
            match effect_id:
                "damage_flat": damage_flat += float(effect_value) * level
                "fire_rate": fire_rate_mod += float(effect_value) * level
                "speed": speed_bonus += float(effect_value) * level
                "range": range_bonus += float(effect_value) * level
                "cargo_expand": cargo_bonus += float(effect_value) * level
                "fuel_expand": fuel_bonus += float(effect_value) * level
                "fuel_efficiency": fuel_efficiency *= pow(float(effect_value), level)
                "fuel_loss_reduce": salvage_keep = maxf(salvage_keep, float(effect_value))
                "resource_flat": resource_flat += float(effect_value) * level
                "gold_bonus_flat": gold_bonus_flat += float(effect_value) * level
                "multi_laser": multi_laser_bonus += int(effect_value) * level
                "magnet": magnet_bonus += float(effect_value) * level
                "barrier": barrier_bonus += int(effect_value) * level
                "combo_bonus": combo_bonus += float(effect_value) * level
                "electric_range": electric_range_bonus += int(effect_value) * level
                "electric_chain": electric_chain_bonus += int(effect_value) * level
                "drone_damage_up": drone_damage_bonus += float(effect_value) * level
                "drone_add": drone_count_bonus += int(effect_value) * level
                "drone_fire_rate": drone_fire_bonus += float(effect_value) * level
                "drone_pierce_up": drone_pierce_bonus += int(effect_value) * level
                "resonance_enhance": resonance_bonus += float(effect_value) * level
                "mega_enhance": mega_enhance_count += level
                "shockwave_enhance": shockwave_enhance_count += level
                "global_damage_mult": global_damage_mult *= pow(1.0 + float(effect_value), level)
                "global_resource_mult": global_resource_mult *= pow(1.0 + float(effect_value), level)
                "core_damage_mult": core_damage_mult *= pow(1.0 + float(effect_value), level)
                "season_dmg_mult":
                    var zone_idx: int = int(effects.get("boost_zone", -1))
                    if zone_idx >= 0 and zone_idx < zone_dmg.size():
                        zone_dmg[zone_idx] = maxf(zone_dmg[zone_idx], float(effect_value))
                "season_res_mult":
                    var zone_res_idx: int = int(effects.get("boost_zone", -1))
                    if zone_res_idx >= 0 and zone_res_idx < zone_res.size():
                        zone_res[zone_res_idx] = maxf(zone_res[zone_res_idx], float(effect_value))
                _:
                    if effect_value is bool and bool(effect_value):
                        flags[effect_id] = true
    for upgrade_id in xp_upgrades.keys():
        var xp_level: int = int(xp_upgrades.get(upgrade_id, 0))
        if xp_level <= 0:
            continue
        var xp_effects: Dictionary = XP_UPGRADES.get(str(upgrade_id).trim_prefix(XP_PREFIX), {}).get("effects", {})
        for xp_effect_key in xp_effects.keys():
            var xp_effect_id: String = str(xp_effect_key)
            var xp_effect_value: Variant = xp_effects[xp_effect_key]
            match xp_effect_id:
                "damage_flat": damage_flat += float(xp_effect_value) * xp_level
                "speed": speed_bonus += float(xp_effect_value) * xp_level
                "range": range_bonus += float(xp_effect_value) * xp_level
                "cargo_expand": cargo_bonus += float(xp_effect_value) * xp_level
                "fuel_expand": fuel_bonus += float(xp_effect_value) * xp_level
                "resource_flat": resource_flat += float(xp_effect_value) * xp_level
                "magnet": magnet_bonus += float(xp_effect_value) * xp_level
                "xp_gain_mult": xp_gain_mult += float(xp_effect_value) * xp_level
                "electric_range": electric_range_bonus += int(xp_effect_value) * xp_level
                "electric_chain": electric_chain_bonus += int(xp_effect_value) * xp_level
                "resonance_enhance": resonance_bonus += float(xp_effect_value) * xp_level
                "global_damage_mult": global_damage_mult *= pow(1.0 + float(xp_effect_value), xp_level)
                "global_resource_mult": global_resource_mult *= pow(1.0 + float(xp_effect_value), xp_level)
                "core_damage_mult": core_damage_mult *= pow(1.0 + float(xp_effect_value), xp_level)
                _:
                    if xp_effect_value is bool and bool(xp_effect_value):
                        flags[xp_effect_id] = true
    for upgrade_id in core_upgrades.keys():
        var core_level: int = int(core_upgrades.get(upgrade_id, 0))
        if core_level <= 0:
            continue
        var core_effects: Dictionary = CORE_UPGRADES.get(str(upgrade_id).trim_prefix(CORE_PREFIX), {}).get("effects", {})
        for core_effect_key in core_effects.keys():
            var core_effect_id: String = str(core_effect_key)
            var core_effect_value: Variant = core_effects[core_effect_key]
            match core_effect_id:
                "damage_flat": damage_flat += float(core_effect_value) * core_level
                "speed": speed_bonus += float(core_effect_value) * core_level
                "range": range_bonus += float(core_effect_value) * core_level
                "cargo_expand": cargo_bonus += float(core_effect_value) * core_level
                "fuel_expand": fuel_bonus += float(core_effect_value) * core_level
                "resource_flat": resource_flat += float(core_effect_value) * core_level
                "magnet": magnet_bonus += float(core_effect_value) * core_level
                "fuel_loss_reduce": salvage_keep = maxf(salvage_keep, float(core_effect_value) * core_level)
                "barrier": barrier_bonus += int(core_effect_value) * core_level
                "multi_laser": multi_laser_bonus += int(core_effect_value) * core_level
                "resonance_enhance": resonance_bonus += float(core_effect_value) * core_level
                "global_damage_mult": global_damage_mult *= pow(1.0 + float(core_effect_value), core_level)
                "global_resource_mult": global_resource_mult *= pow(1.0 + float(core_effect_value), core_level)
                "core_damage_mult": core_damage_mult *= pow(1.0 + float(core_effect_value), core_level)
                _:
                    if core_effect_value is bool and bool(core_effect_value):
                        flags[core_effect_id] = true
    if flags["drone_overclock"]:
        flags["drone_sync_unlock"] = true
        flags["drone_crit_unlock"] = true
    return {
        "attack_damage": 8.0 + damage_flat,
        "attack_interval": clampf(0.8 + fire_rate_mod, 0.06, 1.2),
        "move_speed": 580.0 + speed_bonus,
        "attack_radius": 96.0 + range_bonus,
        "cargo_capacity": int(15 + cargo_bonus),
        "run_time": (30.0 + fuel_bonus) / maxf(0.2, fuel_efficiency),
        "pickup_radius": 64.0 + magnet_bonus,
        "salvage_keep": salvage_keep,
        "resource_flat": resource_flat,
        "gold_bonus_flat": gold_bonus_flat,
        "multi_target": 1 + multi_laser_bonus,
        "barriers": barrier_bonus,
        "combo_bonus_per_stack": combo_bonus,
        "crit_chance": 0.2 if flags["critical_unlock"] else 0.0,
        "crit_bonus": 2.0,
        "charged_interval": 5,
        "charged_bonus": 2.0,
        "charged_enabled": flags["charged_shot_unlock"],
        "electric_enabled": flags["electric_unlock"],
        "electric_range": 2 + electric_range_bonus,
        "electric_chain_depth": 1 + electric_chain_bonus,
        "gold_enabled": flags["gold_unlock"],
        "drone_enabled": flags["drone_unlock"],
        "drone_count": (1 + drone_count_bonus) if flags["drone_unlock"] else 0,
        "drone_damage": 8.0 + drone_damage_bonus,
        "drone_fire_interval": maxf(0.18, 0.9 - drone_fire_bonus),
        "drone_pierce": 1 + drone_pierce_bonus,
        "drone_sync_unlock": flags["drone_sync_unlock"],
        "drone_sync_ratio": 0.3 if flags["drone_overclock"] else 0.15,
        "drone_crit_chance": 0.25 if flags["drone_overclock"] else (0.15 if flags["drone_crit_unlock"] else 0.0),
        "drone_crit_bonus": 2.0,
        "chain_lightning_enabled": flags["chain_lightning_unlock"],
        "chain_lightning_jumps": 3 + int(upgrades.get("chain_jump", 0)) * 2,
        "resonance_enabled": flags["resonance_unlock"],
        "resonance_bonus": 1.0 + resonance_bonus,
        "shockwave_enabled": flags["shockwave_unlock"],
        "shockwave_trigger_kills": max(5, 15 - shockwave_enhance_count * 2),
        "shockwave_radius_cells": 6 + shockwave_enhance_count * 2,
        "mega_enabled": flags["mega_laser_unlock"],
        "mega_gauge_need": max(10, 30 - mega_enhance_count * 5),
        "mega_duration": 5.0 + float(mega_enhance_count),
        "overdrive_enabled": flags["overdrive_unlock"],
        "overdrive_kill_need": 40 if flags["overdrive_enhance"] else 50,
        "overdrive_duration": 4.5 if flags["overdrive_enhance"] else 3.0,
        "overdrive_speed_bonus": 0.0,
        "overdrive_fire_mult": 3.0,
        "core_breaker_mult": 3.0 if flags["core_breaker_unlock"] else 1.0,
        "aoe_enabled": flags["aoe_mining_unlock"],
        "combo_enabled": flags["combo_unlock"],
        "minimap_enabled": flags["minimap_unlock"],
        "instant_collect": flags["instant_collect"],
        "xp_gain_mult": xp_gain_mult,
        "global_damage_mult": global_damage_mult,
        "global_resource_mult": global_resource_mult,
        "core_damage_mult": core_damage_mult,
        "zone_damage_mults": zone_dmg,
        "zone_resource_mults": zone_res,
    }

static func get_damage_multiplier_for_depth(stats: Dictionary, depth_level: int) -> float:
    var idx: int = clampi(depth_level - 1, 0, 3)
    var mults: Array = stats.get("zone_damage_mults", [1.0, 1.0, 1.0, 1.0])
    return float(mults[idx]) if idx < mults.size() and depth_level <= 4 else 1.0

static func get_resource_multiplier_for_depth(stats: Dictionary, depth_level: int) -> float:
    var idx: int = clampi(depth_level - 1, 0, 3)
    var mults: Array = stats.get("zone_resource_mults", [1.0, 1.0, 1.0, 1.0])
    return float(mults[idx]) if idx < mults.size() and depth_level <= 4 else 1.0

static func _get_label(upgrade_id: String) -> String:
    var labels := {
        "critical_hit": "Critical Hits", "charged_shot": "Charged Shot", "drone_proto": "Drone Prototype",
        "chain_unlock": "Chain Lightning", "resonance_unlock": "Resonance", "shockwave_unlock": "Shockwave",
        "overdrive1": "Overdrive", "mega_laser_unlock": "Mega Laser", "core_breaker": "Core Breaker",
        "aoe_mining": "Splash Laser", "combo_unlock": "Combo Counter", "combo_enhance": "Combo Boost",
        "minimap": "Minimap", "fuel_safe": "Failsafe Recovery", "electric_unlock": "Conductive Ore",
        "electric_chain": "Electric Depth", "gold_unlock": "Gold Blocks",
    }
    return str(labels.get(upgrade_id, upgrade_id.replace("_", " ").capitalize()))

static func _get_summary(upgrade_id: String, effects: Dictionary) -> String:
    var summaries := {
        "critical_hit": "Unlock 20% crit chance with 2x damage.",
        "charged_shot": "Every 5th shot deals 2x damage.",
        "drone_proto": "Unlock 1 helper drone.",
        "chain_unlock": "Unlock chain lightning with 3 jumps.",
        "resonance_unlock": "Unlock resonance damage scaling in deeper layers.",
        "shockwave_unlock": "Unlock shockwaves every 15 kills in a 6-cell radius.",
        "overdrive1": "Unlock overdrive after 50 kills for 3 seconds of rapid fire.",
        "mega_laser_unlock": "Unlock Mega Laser after charging 30 kills.",
        "core_breaker": "Deal 3x damage to daemon cores.",
        "aoe_mining": "Shots splash into nearby blocks.",
        "combo_unlock": "Unlock combo payouts at +2% per stack.",
        "minimap": "Show the pit map and your ship position.",
        "fuel_safe": "Keep 100% of payout if the run fails.",
    }
    if summaries.has(upgrade_id):
        return summaries[upgrade_id]
    if effects.has("season_dmg_mult"):
        var zone_idx: int = int(effects.get("boost_zone", -1))
        var pct: int = int(round((float(effects.get("season_dmg_mult", 1.0)) - 1.0) * 100.0))
        return "+%d%% mining damage in the %s layer." % [pct, _get_zone_label(zone_idx)]
    if effects.has("season_res_mult"):
        var res_zone_idx: int = int(effects.get("boost_zone", -1))
        var res_pct: int = int(round((float(effects.get("season_res_mult", 1.0)) - 1.0) * 100.0))
        return "+%d%% payout in the %s layer." % [res_pct, _get_zone_label(res_zone_idx)]
    if effects.has("damage_flat"):
        return "+%s laser damage per level." % _format_effect_number(float(effects.get("damage_flat", 0.0)))
    if effects.has("fire_rate"):
        return "-%ss shot interval per level." % _format_effect_number(absf(float(effects.get("fire_rate", 0.0))))
    if effects.has("speed"):
        return "+%s move speed per level." % _format_effect_number(float(effects.get("speed", 0.0)))
    if effects.has("cargo_expand"):
        return "+%s cargo capacity per level." % _format_effect_number(float(effects.get("cargo_expand", 0.0)))
    if effects.has("fuel_expand"):
        return "+%s seconds of run time per level." % _format_effect_number(float(effects.get("fuel_expand", 0.0)))
    if effects.has("fuel_efficiency"):
        var efficiency_pct: int = int(round((1.0 - float(effects.get("fuel_efficiency", 1.0))) * 100.0))
        return "%d%% less fuel drain." % efficiency_pct
    if effects.has("fuel_loss_reduce"):
        var keep_pct: int = int(round(float(effects.get("fuel_loss_reduce", 0.0)) * 100.0))
        return "Keep %d%% of payout after a failed run." % keep_pct
    if effects.has("resource_flat"):
        return "+%s payout per mined block per level." % _format_effect_number(float(effects.get("resource_flat", 0.0)))
    if effects.has("gold_bonus_flat"):
        return "+%s bonus value on gold blocks per level." % _format_effect_number(float(effects.get("gold_bonus_flat", 0.0)))
    if effects.has("range") and effects.has("magnet"):
        return "+%s mining range and pickup radius per level." % _format_effect_number(float(effects.get("range", 0.0)))
    if effects.has("range"):
        return "+%s mining range per level." % _format_effect_number(float(effects.get("range", 0.0)))
    if effects.has("magnet"):
        return "+%s pickup radius per level." % _format_effect_number(float(effects.get("magnet", 0.0)))
    if effects.has("barrier"):
        return "+%d barrier." % int(effects.get("barrier", 0))
    if effects.has("multi_laser"):
        return "+%d extra target per shot." % int(effects.get("multi_laser", 0))
    if effects.has("combo_bonus"):
        var combo_pct: int = int(round(float(effects.get("combo_bonus", 0.0)) * 100.0))
        return "+%d%% payout per combo stack." % combo_pct
    if effects.has("electric_range"):
        return "Electric arcs reach %d extra cells per level." % int(effects.get("electric_range", 0))
    if effects.has("electric_chain"):
        return "Electric shots gain %d extra chain depth per level." % int(effects.get("electric_chain", 0))
    if effects.has("drone_damage_up"):
        return "+%s drone damage per level." % _format_effect_number(float(effects.get("drone_damage_up", 0.0)))
    if effects.has("drone_add"):
        return "+%d drone per level." % int(effects.get("drone_add", 0))
    if effects.has("drone_fire_rate"):
        return "-%ss drone shot interval per level." % _format_effect_number(float(effects.get("drone_fire_rate", 0.0)))
    if effects.has("drone_pierce_up"):
        return "+%d drone pierce." % int(effects.get("drone_pierce_up", 0))
    if effects.has("resonance_enhance"):
        return "+%s resonance multiplier per level." % _format_effect_number(float(effects.get("resonance_enhance", 0.0)))
    if effects.has("mega_enhance"):
        return "Mega Laser charges 5 kills sooner and lasts 1 second longer per level."
    if effects.has("shockwave_enhance"):
        return "Shockwave triggers 2 kills sooner and reaches 2 more cells per level."
    return "Open Pit Empire upgrade."

static func _format_effect_number(value: float) -> String:
    if is_equal_approx(value, round(value)):
        return str(int(round(value)))
    return str(snappedf(value, 0.01))

static func _get_zone_label(zone_idx: int) -> String:
    match zone_idx:
        0:
            return "Proxy Cache"
        1:
            return "Cipher Depths"
        2:
            return "Ghost Sector"
        3:
            return "Root Well"
        _:
            return "Kernel Vault"

static func _get_icon(upgrade_id: String) -> String:
    if upgrade_id.contains("drone"):
        return "D"
    if upgrade_id.contains("laser") or upgrade_id.begins_with("dmg"):
        return "L"
    if upgrade_id.contains("fuel"):
        return "F"
    if upgrade_id.contains("cargo"):
        return "C"
    if upgrade_id.contains("electric") or upgrade_id.contains("chain"):
        return "E"
    if upgrade_id.contains("shockwave"):
        return "W"
    if upgrade_id.contains("overdrive"):
        return "O"
    return "U"
