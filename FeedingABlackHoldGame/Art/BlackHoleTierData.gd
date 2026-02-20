extends Node
class_name BlackHoleTierData

var starting_level = 0:
    set(new_value):
        starting_level = new_value
        max_level = starting_level + xp_per_level.size() - 1

var max_level = 0

var number_of_levels = 0

var set_money_to_this_amount_on_finishing_tier = -1
var zoom
var radius_start: float
var radius_end: float
var xp_per_level = []
var level_name_keys = []

var forced_objects_to_spawn
var forced_session_timer

var epilogue = false

func _init(_xp_per_level, _level_name_keys, _zoom, _set_money_to_this_amount_on_finishing_tier = -1, _radius_start = 100.0, _radius_end = 200.0, _epilogue = false, _forced_objects_to_spawn = null, _forced_session_timer = null):
    xp_per_level = _xp_per_level
    zoom = _zoom
    set_money_to_this_amount_on_finishing_tier = _set_money_to_this_amount_on_finishing_tier
    level_name_keys = _level_name_keys
    radius_start = _radius_start
    radius_end = _radius_end
    epilogue = _epilogue
    forced_objects_to_spawn = _forced_objects_to_spawn
    forced_session_timer = _forced_session_timer

    number_of_levels = xp_per_level.size()
