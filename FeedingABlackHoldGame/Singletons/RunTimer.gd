extends MarginContainer
class_name RunTimer

func _ready():
    SignalBus.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed():
    match Global.game_state:
        Util.GAME_STATES.GAME_OVER:
            set_process(false)
        _:
            set_process(true)

func _process(delta: float) -> void :
    Global.run_stats.run_time += delta
    %"Run Timer".text = Util.format_time(Global.run_stats.run_time)
