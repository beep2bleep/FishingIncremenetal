extends Resource
class_name GameModeData

@export var name_key: String
@export var game_mode: Util.GAME_MODES
@export var game_mode_type: Util.GAME_MODE_TYPE
@export var description_key: String
@export var data_path: String
@export var icon: Texture2D

@export var coming_soon: bool = false
@export var coming_soon_date = 0

@export var is_beta: bool = false
@export var is_for_demo: bool = false
@export var hide_in_demo: bool = false

@export var accent_color: Color

@export_group("Game Settings")
@export var disable_session_timer: bool = false
@export var end_run_disabled: bool = false
@export var on_more_time_disabled: bool = false


@export_group("Upgare Tree Settings")
@export var upgrade_tree_grid_size: Vector2i = Vector2.ZERO
@export var node_cost_setting_enabled: bool = false
@export var node_cost_base: float = 0.0
@export var node_cost_pow_scale_per_node_bought: float = 1.0
@export var node_cost_scale_per_distance_from_center: float = 1.0



func get_save_file_name():
    return str(name_key, "_cloud_file.save")


func _to_string() -> String:
    return "[GameModeData name_key='%s', description_key='%s', data_path='%s', icon=%s, coming_soon=%s]" % [
        name_key, 
        description_key, 
        data_path, 
        icon if icon != null else "null", 
        str(coming_soon)
    ]


func get_coming_soon_text() -> String:
    var month_keys = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", 
                  "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]


    return str(tr("COMING_SOON"))

    if coming_soon_date <= 0:
        pass


    var local_time = Time.get_datetime_dict_from_unix_time(coming_soon_date)

    var day_keys = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]


    return tr("COMING_SOON_DATE").format({
        "day_of_week": tr(day_keys[local_time.weekday]), 
        "month": tr(month_keys[local_time.month - 1]), 
        "day": local_time.day, 
        "year": local_time.year
    })


func get_coming_soon_text_short() -> String:
    if coming_soon_date <= 0:
        return tr("COMING_SOON")

    var local_time = Time.get_datetime_dict_from_unix_time(coming_soon_date)
    var month_short_keys = ["JANUARY_SHORT", "FEBRUARY_SHORT", "MARCH_SHORT", "APRIL_SHORT", 
                            "MAY_SHORT", "JUNE_SHORT", "JULY_SHORT", "AUGUST_SHORT", 
                            "SEPTEMBER_SHORT", "OCTOBER_SHORT", "NOVEMBER_SHORT", "DECEMBER_SHORT"]
    var day_short_keys = ["SUNDAY_SHORT", "MONDAY_SHORT", "TUESDAY_SHORT", "WEDNESDAY_SHORT", 
                          "THURSDAY_SHORT", "FRIDAY_SHORT", "SATURDAY_SHORT"]

    return tr("COMING_SOON_DATE_SHORT").format({
        "day_of_week": tr(day_short_keys[local_time.weekday]), 
        "month": tr(month_short_keys[local_time.month - 1]), 
        "day": local_time.day
    })


func get_node_cost(nodes_unlocked: int) -> int:
    var raw_cost = node_cost_base * pow(node_cost_pow_scale_per_node_bought, nodes_unlocked - 1)

    if raw_cost < 100:
        return int(round(raw_cost))
    elif raw_cost < 1000:
        return int(round(raw_cost / 10.0) * 10)
    elif raw_cost < 100000:
        return int(round(raw_cost / 100.0) * 100)
    elif raw_cost < 1000000:
        return int(round(raw_cost / 1000.0) * 1000)
    elif raw_cost < 1000000000:
        return int(round(raw_cost / 10000.0) * 10000)
    else:
        return int(round(raw_cost / 100000.0) * 100000)
