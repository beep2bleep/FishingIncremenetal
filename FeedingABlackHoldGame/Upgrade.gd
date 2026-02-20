extends Resource
class_name Upgrade

var id: int
var cell: Vector2
var mod: Util.MODS
var value
var max_tier: int = 1
var base_cost: int
var cost_scale: float
var forced_cell
var demo_locked: int = 0
var section: int = 0
var act: int = 0
var epilogue: int = 0

var type: Util.NODE_TYPES = Util.NODE_TYPES.NORMAL

var current_tier: int = 0:
    set(new_tier):
        var old_tier = current_tier
        current_tier = min(new_tier, max_tier)
        if old_tier < current_tier:
            Global.mods.change_mod(mod, value)

        if current_tier > 0:
            Global.game_mode_data_manager.unlocked_upgrades[cell] = to_dict()

func has_tiers():
    return max_tier > 1

func get_cost():
    if has_tiers():
        return base_cost + (current_tier * base_cost * cost_scale)
    else:
        return base_cost

func is_at_max():
    return current_tier >= max_tier

func get_current_teir_value():
    return value

func get_next_tier():
    if is_at_max() == false:
        return value
    return null

func to_dict() -> Dictionary:
    return {
        "id": id, 
        "cell": cell, 
        "mod": mod, 
        "value": value, 
        "max_tier": max_tier, 
        "base_cost": base_cost, 
        "cost_scale": cost_scale, 
        "forced_cell": forced_cell, 
        "demo_locked": demo_locked, 
        "section": section, 
        "act": act, 
        "epilogue": epilogue, 
        "type": type, 
        "teir": current_tier
}

func from_dict(cell_param: Vector2, data: Dictionary):
    if data.has("id"):
        id = data["id"]
    cell = cell_param
    if data.has("mod"):
        mod = data["mod"]
    if data.has("value"):
        value = data["value"]
    if data.has("max_tier"):
        max_tier = data["max_tier"]
    if data.has("base_cost"):
        base_cost = data["base_cost"]
    if data.has("cost_scale"):
        cost_scale = data["cost_scale"]
    if data.has("forced_cell"):
        forced_cell = data["forced_cell"]
    if data.has("demo_locked"):
        demo_locked = data["demo_locked"]
    if data.has("section"):
        section = data["section"]
    if data.has("act"):
        act = data["act"]
    if data.has("epilogue"):
        epilogue = data["epilogue"]
    if data.has("type"):
        type = data["type"]
    if data.has("teir"):
        current_tier = data["teir"]
