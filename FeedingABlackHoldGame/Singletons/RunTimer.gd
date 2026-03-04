extends MarginContainer
class_name RunTimer

func _ready():
    SignalBus.game_state_changed.connect(_on_game_state_changed)
    _refresh_timer_text()

func _on_game_state_changed():
    match Global.game_state:
        Util.GAME_STATES.GAME_OVER:
            set_process(false)
        _:
            set_process(true)

func _process(delta: float) -> void :
    if _use_fishing_battle_clock():
        %"Run Timer".text = Util.format_time(SaveHandler.fishing_run_clock_seconds)
        return
    Global.run_stats.run_time += delta
    %"Run Timer".text = Util.format_time(Global.run_stats.run_time)

func _refresh_timer_text() -> void:
    if _use_fishing_battle_clock():
        %"Run Timer".text = Util.format_time(SaveHandler.fishing_run_clock_seconds)
    else:
        %"Run Timer".text = Util.format_time(Global.run_stats.run_time)

func _use_fishing_battle_clock() -> bool:
    if Global.main == null:
        return false
    var screen: UpgradeScreen = Global.main.upgrade_screen
    if screen == null:
        return false
    if not screen.is_active:
        return false
    if not screen.has_method("_is_simulation_upgrade_tree"):
        return false
    return bool(screen.call("_is_simulation_upgrade_tree"))
