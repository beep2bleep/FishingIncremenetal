extends Node2D
class_name BlackHole

var gravity_radius_squared = 0
var gravity_radius = 0
var core_radius = 0

@onready var level_manager: LevelManager = %LevelManager
@onready var black_hole_art: BlackHoleArt = %"Black Hole Art"

@export var size_curve: Curve


var min_radius: = 10.0
var max_radius: = 256.0















func get_size_name(size = null):
    return str("BLACK_HOLE_NAME_", size if size else level_manager.level)








func reset():
    level_manager.reset()
    update_size()
    %"Black Hole Art".update(true)

func _ready() -> void :
    Global.black_hole = self



    update_size()

    %"Black Hole Art".update()















func update_size():

    core_radius = level_manager.get_black_hole_radius()
    gravity_radius = core_radius * (1.0 + level_manager.current_black_hole_tier_data.zoom)

    gravity_radius_squared = pow(gravity_radius, 2.0)




func on_tier_end():
    on_level_up()



func _on_level_manager_updated(data: LevelManagerUpdatedData) -> void :


    if data.was_level_up == true and Global.game_state == Util.GAME_STATES.PLAYING:
        on_level_up()

        Global.main.session_timer += Global.mods.get_mod(Util.MODS.RUN_TIMER_AMOUNT_ON_BLACK_HOLE_GROW)
        Global.session_stats.time_added_during_session += Global.mods.get_mod(Util.MODS.RUN_TIMER_AMOUNT_ON_BLACK_HOLE_GROW)


        SignalBus.black_hole_grew.emit()

        %"Black Hole Art".animate_grow(gravity_radius)





    %"Black Hole Art".update_progress(data.percent)

func on_level_up():
    update_size()
