extends RefCounted
class_name OpenPitOrbitBalance

const MAX_DEPTH_LEVEL := 5
const MIN_START_DEPTH_LEVEL := 1
const CORE_PREFIX := "core:"
const CORE_ORDER := [
    "core_detect", "brake", "barrier_regen", "spawn_direction",
    "return_shortcut", "core_focus", "emergency_return", "center_unlock",
    "planet_mastery"
]
const CORE_LAYOUT := {
    "core:core_detect": Vector2(-10, 4),
    "core:brake": Vector2(-8, 2),
    "core:barrier_regen": Vector2(-6, 2),
    "core:spawn_direction": Vector2(-4, 4),
    "core:return_shortcut": Vector2(-4, 6),
    "core:core_focus": Vector2(-6, 8),
    "core:emergency_return": Vector2(-8, 8),
    "core:center_unlock": Vector2(-10, 6),
    "core:planet_mastery": Vector2(-12, 5),
}
const CORE_CONNECTIONS := {
    "core:core_detect": [],
    "core:brake": ["core:core_detect"],
    "core:barrier_regen": ["core:brake"],
    "core:spawn_direction": ["core:barrier_regen"],
    "core:return_shortcut": ["core:spawn_direction"],
    "core:core_focus": ["core:return_shortcut"],
    "core:emergency_return": ["core:core_focus"],
    "core:center_unlock": ["core:emergency_return"],
    "core:planet_mastery": ["core:center_unlock"],
}
const CORE_UPGRADES := {
    "core_detect": {"base_cost": 1, "cost_mult": 1.0, "max_level": 1, "label": "Core Detect", "summary": "Shows core health and weak points."},
    "brake": {"base_cost": 1, "cost_mult": 1.0, "max_level": 1, "label": "Brake", "summary": "Improves return control near dense shell."},
    "barrier_regen": {"base_cost": 2, "cost_mult": 1.0, "max_level": 1, "label": "Barrier Regen", "summary": "Restores one barrier between successful returns."},
    "spawn_direction": {"base_cost": 2, "cost_mult": 1.0, "max_level": 1, "label": "Spawn Direction", "summary": "Unlocks more favorable insertion vectors."},
    "return_shortcut": {"base_cost": 2, "cost_mult": 1.0, "max_level": 1, "label": "Return Shortcut", "summary": "Return zone is easier to secure."},
    "core_focus": {"base_cost": 3, "cost_mult": 1.0, "max_level": 1, "label": "Core Focus", "summary": "Core-targeting systems lock faster."},
    "emergency_return": {"base_cost": 3, "cost_mult": 1.0, "max_level": 1, "label": "Emergency Return", "summary": "Emergency extraction preserves the run."},
    "center_unlock": {"base_cost": 2, "cost_mult": 1.0, "max_level": 1, "label": "Center Unlock", "summary": "Unlocks attacks against the planet center."},
    "planet_mastery": {"base_cost": 1, "cost_mult": 1.0, "max_level": 1, "label": "Planet Mastery", "summary": "Allows a full planet regeneration once cleared."},
}

const PHASE_BRIDGES := {
    2: {"gate": "multi1", "entry": "electric_unlock"},
    3: {"gate": "fuel_save1", "entry": "chain_unlock"},
    4: {"gate": "fuel_save2", "entry": "shockwave_unlock"},
    5: {"gate": "overdrive1", "entry": "mega_laser_unlock"},
}

const PHASE_NODE_ORDER := {
    1: ["start", "dmg1", "fuel_tank1", "resource1", "fire_rate1", "cargo_expand1", "speed1", "minimap", "combo_unlock", "aoe_mining", "critical_hit", "multi1"],
    2: ["electric_unlock", "cargo_expand2", "dmg2", "fuel_tank2", "drone_proto", "combo_enhance", "range1", "value1", "dmg_boost1", "gold_unlock", "pickup_expand", "drone_dmg", "res_boost1", "charged_shot", "fire_rate2", "gold_value", "fuel_save1"],
    3: ["chain_unlock", "cargo_expand3", "dmg3", "fuel_tank3", "drone_deploy", "resource2", "fire_rate3", "drone_speed", "chain_jump", "dmg_boost2", "electric_range", "value2", "res_boost2", "drone_pierce", "magnet1", "range2", "fuel_save2", "multi2", "barrier1", "overheat_shield"],
    4: ["drone_sync", "speed2", "resonance_unlock", "shockwave_unlock", "dmg4", "dmg_boost3", "shockwave_enhance", "cargo_expand4", "drone_crit", "electric_range2", "gold_enhance", "resonance_enhance", "drone_overclock", "barrier2", "fuel_efficiency1", "fuel_tank4", "overdrive1", "res_boost3"],
    5: ["mega_laser_unlock", "dmg5", "mega_enhance", "electric_chain", "resource3", "cargo_expand5", "dmg_boost4", "final_resonance", "overdrive_enhance", "fire_rate4", "multi3", "res_boost4", "dmg6", "core_breaker", "barrier3", "fuel_safe"],
}

const PHASE_COLS := 4
const PHASE_OFFSETS := {
    1: Vector2(2, 2),
    2: Vector2(12, 2),
    3: Vector2(12, 14),
    4: Vector2(2, 14),
    5: Vector2(2, 26),
}

const RAW_NODE_DATA := {
    "dmg1": {"base_cost": 20, "cost_mult": 2.0, "max_level": 3, "phase": 1, "effects": {"damage_flat": 1.0}},
    "fire_rate1": {"base_cost": 30, "cost_mult": 1.8, "max_level": 3, "phase": 1, "effects": {"fire_rate": -0.12}},
    "critical_hit": {"base_cost": 150, "cost_mult": 1.0, "max_level": 1, "phase": 1, "effects": {"critical_unlock": true}},
    "resource1": {"base_cost": 25, "cost_mult": 2.0, "max_level": 2, "phase": 1, "effects": {"resource_flat": 2.0}},
    "value1": {"base_cost": 800, "cost_mult": 2.0, "max_level": 2, "phase": 2, "effects": {"gold_bonus_flat": 5.0}},
    "speed1": {"base_cost": 30, "cost_mult": 2.0, "max_level": 2, "phase": 1, "effects": {"speed": 60.0}},
    "multi1": {"base_cost": 200, "cost_mult": 1.0, "max_level": 1, "phase": 1, "effects": {"multi_laser": 1}},
    "dmg_boost1": {"base_cost": 1300, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"season_dmg_mult": 2.0, "boost_zone": 0}},
    "res_boost1": {"base_cost": 2000, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"season_res_mult": 2.0, "boost_zone": 0}},
    "electric_unlock": {"base_cost": 500, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"electric_unlock": true}},
    "electric_range": {"base_cost": 30000, "cost_mult": 1.5, "max_level": 2, "phase": 3, "effects": {"electric_range": 1}},
    "electric_range2": {"base_cost": 1000000, "cost_mult": 1.5, "max_level": 2, "phase": 4, "effects": {"electric_range": 1}},
    "gold_unlock": {"base_cost": 1300, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"gold_unlock": true}},
    "gold_value": {"base_cost": 3000, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"resource_flat": 5.0}},
    "pickup_expand": {"base_cost": 1300, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"magnet": 128.0}},
    "dmg2": {"base_cost": 500, "cost_mult": 1.5, "max_level": 3, "phase": 2, "effects": {"damage_flat": 3.0}},
    "range1": {"base_cost": 800, "cost_mult": 1.5, "max_level": 2, "phase": 2, "effects": {"range": 45.0}},
    "fire_rate2": {"base_cost": 2000, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"fire_rate": -0.12}},
    "charged_shot": {"base_cost": 2000, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"charged_shot_unlock": true}},
    "dmg_boost2": {"base_cost": 30000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"season_dmg_mult": 2.5, "boost_zone": 1}},
    "res_boost2": {"base_cost": 80000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"season_res_mult": 2.0, "boost_zone": 1}},
    "drone_proto": {"base_cost": 800, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"drone_unlock": true}},
    "drone_dmg": {"base_cost": 1300, "cost_mult": 1.6, "max_level": 3, "phase": 2, "effects": {"drone_damage_up": 5.0}},
    "drone_deploy": {"base_cost": 15000, "cost_mult": 2.0, "max_level": 2, "phase": 3, "effects": {"drone_add": 1}},
    "drone_speed": {"base_cost": 15000, "cost_mult": 1.8, "max_level": 2, "phase": 3, "effects": {"drone_fire_rate": 0.2}},
    "drone_pierce": {"base_cost": 80000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"drone_pierce_up": 1}},
    "chain_unlock": {"base_cost": 8000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"chain_lightning_unlock": true}},
    "chain_jump": {"base_cost": 30000, "cost_mult": 2.0, "max_level": 2, "phase": 3, "effects": {"chain_jump": 2}},
    "dmg3": {"base_cost": 8000, "cost_mult": 2.0, "max_level": 4, "phase": 3, "effects": {"damage_flat": 8.0}},
    "resource2": {"base_cost": 15000, "cost_mult": 2.0, "max_level": 3, "phase": 3, "effects": {"resource_flat": 8.0}},
    "value2": {"base_cost": 30000, "cost_mult": 2.0, "max_level": 2, "phase": 3, "effects": {"gold_bonus_flat": 12.0}},
    "multi2": {"base_cost": 200000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"multi_laser": 1}},
    "magnet1": {"base_cost": 80000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"instant_collect": true}},
    "range2": {"base_cost": 80000, "cost_mult": 2.0, "max_level": 2, "phase": 3, "effects": {"range": 30.0}},
    "barrier1": {"base_cost": 200000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"barrier": 1}},
    "overheat_shield": {"base_cost": 200000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"overheat_resist": 0.3}},
    "dmg_boost3": {"base_cost": 500000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"season_dmg_mult": 2.5, "boost_zone": 2}},
    "res_boost3": {"base_cost": 2000000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"season_res_mult": 2.5, "boost_zone": 2}},
    "speed2": {"base_cost": 250000, "cost_mult": 2.0, "max_level": 2, "phase": 4, "effects": {"speed": 60.0}},
    "drone_sync": {"base_cost": 250000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"drone_sync_unlock": true}},
    "drone_crit": {"base_cost": 500000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"drone_crit_unlock": true}},
    "drone_overclock": {"base_cost": 1000000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"drone_overclock": true}},
    "resonance_unlock": {"base_cost": 250000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"resonance_unlock": true}},
    "shockwave_unlock": {"base_cost": 250000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"shockwave_unlock": true}},
    "overdrive1": {"base_cost": 5000000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"overdrive_unlock": true}},
    "dmg4": {"base_cost": 250000, "cost_mult": 2.0, "max_level": 4, "phase": 4, "effects": {"damage_flat": 15.0}},
    "fire_rate3": {"base_cost": 15000, "cost_mult": 2.0, "max_level": 2, "phase": 3, "effects": {"fire_rate": -0.04}},
    "resonance_enhance": {"base_cost": 1000000, "cost_mult": 2.0, "max_level": 2, "phase": 4, "effects": {"resonance_enhance": 1.0}},
    "shockwave_enhance": {"base_cost": 500000, "cost_mult": 2.0, "max_level": 2, "phase": 4, "effects": {"shockwave_enhance": true}},
    "gold_enhance": {"base_cost": 1000000, "cost_mult": 2.0, "max_level": 2, "phase": 4, "effects": {"resource_flat": 12.0}},
    "barrier2": {"base_cost": 2000000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"barrier": 1}},
    "dmg_boost4": {"base_cost": 100000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"season_dmg_mult": 3.0, "boost_zone": 3}},
    "res_boost4": {"base_cost": 200000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"season_res_mult": 3.0, "boost_zone": 3}},
    "mega_laser_unlock": {"base_cost": 30000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"mega_laser_unlock": true}},
    "mega_enhance": {"base_cost": 40000000, "cost_mult": 2.0, "max_level": 3, "phase": 5, "effects": {"mega_enhance": true}},
    "multi3": {"base_cost": 150000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"multi_laser": 1}},
    "core_breaker": {"base_cost": 300000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"core_breaker_unlock": true}},
    "dmg5": {"base_cost": 30000000, "cost_mult": 2.0, "max_level": 4, "phase": 5, "effects": {"damage_flat": 25.0}},
    "electric_chain": {"base_cost": 50000000, "cost_mult": 2.0, "max_level": 2, "phase": 5, "effects": {"electric_chain": 1}},
    "final_resonance": {"base_cost": 120000000, "cost_mult": 2.0, "max_level": 2, "phase": 5, "effects": {"resonance_enhance": 1.0}},
    "overdrive_enhance": {"base_cost": 200000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"overdrive_enhance": true}},
    "fire_rate4": {"base_cost": 150000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"fire_rate": -0.02}},
    "barrier3": {"base_cost": 350000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"barrier": 10}},
    "dmg6": {"base_cost": 200000000, "cost_mult": 2.0, "max_level": 3, "phase": 5, "effects": {"damage_flat": 40.0}},
    "resource3": {"base_cost": 80000000, "cost_mult": 2.5, "max_level": 2, "phase": 5, "effects": {"resource_flat": 20.0}},
    "aoe_mining": {"base_cost": 120, "cost_mult": 1.0, "max_level": 1, "phase": 1, "effects": {"aoe_mining_unlock": true}},
    "combo_unlock": {"base_cost": 80, "cost_mult": 1.0, "max_level": 1, "phase": 1, "effects": {"combo_unlock": true, "combo_bonus": 0.02}},
    "combo_enhance": {"base_cost": 800, "cost_mult": 1.5, "max_level": 3, "phase": 2, "effects": {"combo_bonus": 0.02}},
    "minimap": {"base_cost": 60, "cost_mult": 1.0, "max_level": 1, "phase": 1, "effects": {"minimap_unlock": true}},
    "fuel_tank1": {"base_cost": 25, "cost_mult": 2.0, "max_level": 3, "phase": 1, "effects": {"fuel_expand": 2.0}},
    "fuel_tank2": {"base_cost": 500, "cost_mult": 1.8, "max_level": 3, "phase": 2, "effects": {"fuel_expand": 3.0}},
    "fuel_tank3": {"base_cost": 8000, "cost_mult": 1.8, "max_level": 3, "phase": 3, "effects": {"fuel_expand": 5.0}},
    "fuel_tank4": {"base_cost": 2000000, "cost_mult": 1.8, "max_level": 3, "phase": 4, "effects": {"fuel_expand": 12.0}},
    "fuel_save1": {"base_cost": 3000, "cost_mult": 1.0, "max_level": 1, "phase": 2, "effects": {"fuel_loss_reduce": 0.3}},
    "fuel_save2": {"base_cost": 200000, "cost_mult": 1.0, "max_level": 1, "phase": 3, "effects": {"fuel_loss_reduce": 0.6}},
    "fuel_efficiency1": {"base_cost": 2000000, "cost_mult": 1.0, "max_level": 1, "phase": 4, "effects": {"fuel_efficiency": 0.8}},
    "fuel_safe": {"base_cost": 250000000, "cost_mult": 1.0, "max_level": 1, "phase": 5, "effects": {"fuel_loss_reduce": 1.0}},
    "cargo_expand1": {"base_cost": 30, "cost_mult": 2.0, "max_level": 3, "phase": 1, "effects": {"cargo_expand": 10.0}},
    "cargo_expand2": {"base_cost": 500, "cost_mult": 1.8, "max_level": 3, "phase": 2, "effects": {"cargo_expand": 50.0}},
    "cargo_expand3": {"base_cost": 8000, "cost_mult": 1.8, "max_level": 3, "phase": 3, "effects": {"cargo_expand": 200.0}},
    "cargo_expand4": {"base_cost": 500000, "cost_mult": 1.8, "max_level": 3, "phase": 4, "effects": {"cargo_expand": 1000.0}},
    "cargo_expand5": {"base_cost": 80000000, "cost_mult": 1.8, "max_level": 3, "phase": 5, "effects": {"cargo_expand": 5000.0}},
}

const LAYER_DATA := [
    {"name": "Surface Ring", "value": 4, "health": 24.0, "color": Color(0.16, 0.21, 0.29, 1.0), "accent": Color(0.52, 0.74, 0.98, 1.0)},
    {"name": "Solar Shelf", "value": 14, "health": 68.0, "color": Color(0.22, 0.28, 0.24, 1.0), "accent": Color(0.25, 0.9, 0.72, 1.0)},
    {"name": "Storm Mantle", "value": 42, "health": 168.0, "color": Color(0.3, 0.18, 0.12, 1.0), "accent": Color(0.96, 0.64, 0.24, 1.0)},
    {"name": "Night Belt", "value": 110, "health": 360.0, "color": Color(0.2, 0.14, 0.28, 1.0), "accent": Color(0.84, 0.5, 1.0, 1.0)},
    {"name": "Core Vault", "value": 320, "health": 920.0, "color": Color(0.32, 0.06, 0.08, 1.0), "accent": Color(1.0, 0.36, 0.28, 1.0)},
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
                "label": _get_label(upgrade_id),
                "summary": _get_summary(upgrade_id, raw.get("effects", {})),
                "base_cost": int(raw.get("base_cost", 0)),
                "cost_mult": float(raw.get("cost_mult", 1.0)),
                "max_level": int(raw.get("max_level", 1)),
                "phase": int(raw.get("phase", phase)),
                "icon": _get_icon(upgrade_id),
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

static func build_runtime_stats(upgrades: Dictionary) -> Dictionary:
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
    var electric_range_bonus := 0
    var electric_chain_bonus := 0
    var drone_damage_bonus := 0.0
    var drone_count_bonus := 0
    var drone_fire_bonus := 0.0
    var drone_pierce_bonus := 0
    var resonance_bonus := 0.0
    var mega_enhance_count := 0
    var shockwave_enhance_count := 0
    var season_dmg := [1.0, 1.0, 1.0, 1.0]
    var season_res := [1.0, 1.0, 1.0, 1.0]
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
                "season_dmg_mult":
                    var zone_idx: int = int(effects.get("boost_zone", -1))
                    if zone_idx >= 0 and zone_idx < season_dmg.size():
                        season_dmg[zone_idx] = maxf(season_dmg[zone_idx], float(effect_value))
                "season_res_mult":
                    var zone_res_idx: int = int(effects.get("boost_zone", -1))
                    if zone_res_idx >= 0 and zone_res_idx < season_res.size():
                        season_res[zone_res_idx] = maxf(season_res[zone_res_idx], float(effect_value))
                _:
                    if effect_value is bool and bool(effect_value):
                        flags[effect_id] = true
    if flags["drone_overclock"]:
        flags["drone_sync_unlock"] = true
        flags["drone_crit_unlock"] = true
    return {
        "attack_damage": 8.0 + damage_flat,
        "attack_interval": clampf(0.8 + fire_rate_mod, 0.06, 1.2),
        "move_speed": 280.0 + speed_bonus,
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
        "overdrive_speed_bonus": 300.0,
        "overdrive_fire_mult": 3.0,
        "core_breaker_mult": 3.0 if flags["core_breaker_unlock"] else 1.0,
        "aoe_enabled": flags["aoe_mining_unlock"],
        "combo_enabled": flags["combo_unlock"],
        "minimap_enabled": flags["minimap_unlock"],
        "instant_collect": flags["instant_collect"],
        "season_damage_mults": season_dmg,
        "season_resource_mults": season_res,
    }

static func get_damage_multiplier_for_depth(stats: Dictionary, depth_level: int) -> float:
    var idx: int = clampi(depth_level - 1, 0, 3)
    var mults: Array = stats.get("season_damage_mults", [1.0, 1.0, 1.0, 1.0])
    return float(mults[idx]) if idx < mults.size() and depth_level <= 4 else 1.0

static func get_resource_multiplier_for_depth(stats: Dictionary, depth_level: int) -> float:
    var idx: int = clampi(depth_level - 1, 0, 3)
    var mults: Array = stats.get("season_resource_mults", [1.0, 1.0, 1.0, 1.0])
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
        "critical_hit": "Unlocks crits for your mining laser.",
        "charged_shot": "Every fifth shot lands hard.",
        "drone_proto": "Deploys a helper drone.",
        "chain_unlock": "Laser hits jump between blocks.",
        "resonance_unlock": "Damage rises deeper in the orbit pit.",
        "shockwave_unlock": "Burst nearby ore after enough kills.",
        "overdrive1": "Kills can trigger a short combat spike.",
        "mega_laser_unlock": "Charge a piercing beam.",
        "core_breaker": "Deals huge bonus damage to the core vault.",
        "aoe_mining": "Laser splashes nearby blocks.",
        "combo_unlock": "Fast breaks add payout bonus.",
        "minimap": "Shows the pit layout and ship position.",
        "fuel_safe": "Lose nothing if the rig breaks.",
    }
    if summaries.has(upgrade_id):
        return summaries[upgrade_id]
    if effects.has("damage_flat"):
        return "Raises direct mining damage."
    if effects.has("fire_rate"):
        return "Fires the laser faster."
    if effects.has("speed"):
        return "Moves the rig faster."
    if effects.has("cargo_expand"):
        return "Lets each sortie carry more ore."
    if effects.has("fuel_expand"):
        return "Extends sortie time."
    if effects.has("resource_flat"):
        return "Adds more payout to each mined block."
    if effects.has("gold_bonus_flat"):
        return "Makes rich nodes worth more."
    if effects.has("range") or effects.has("magnet"):
        return "Improves range and collection control."
    if effects.has("barrier"):
        return "Adds impact shields."
    return "Orbit mining upgrade."

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
