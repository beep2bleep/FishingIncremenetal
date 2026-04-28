extends Node

var mods: Mods
var config: Config
var game_mode_data_manager: GameModeDataManager
var global_resoruce_manager: GlobalResourceManager

var main: Main
var black_hole: BlackHole
var player: Player
var current_game_mode_data: GameModeData
var session_stats: SessionStats
var tier_stats: TierStats
var run_stats: RunStats
var cached_upgrade_tech_tree: Node = null
var cached_upgrade_tree_locale: String = ""
var open_pit_upgrade_startup_started_msec: int = 0
var open_pit_upgrade_scene_resource_load_msec: int = 0
var open_pit_upgrade_scene_swap_msec: int = 0
var multi_game_run: Dictionary = {}
var multi_game_pending_summary: Dictionary = {}
var multi_game_step_config: Dictionary = {}


const G = 100000.0

var load_saved_run = false
var start_in_upgrade_scene = true

## Reel Into Darkness: if > 0, next run clamps meta max_depth to this (set from upgrade screen tier pick).
var reel_run_max_depth_cap: float = -1.0
## Effective max_depth band last played; restored for "Fish Again" (-1 = full chart, no clamp).
var reel_repeat_depth_cap: float = -1.0



var rng: RandomNumberGenerator


var game_state: Util.GAME_STATES:
    set(new_value):
        game_state = new_value
        SignalBus.game_state_changed.emit()

        update_mouse()

func _ready():
    ControllerIcons.input_type_changed.connect(_on_input_type_changed)
    game_mode_data_manager = GameModeDataManager.new()
    update_input_stuff(ControllerIcons.get_last_input_type())

    new_game()

func ensure_default_game_mode_data():
    if current_game_mode_data != null:
        return

    var mode_data := GameModeData.new()
    mode_data.name_key = "main"
    mode_data.game_mode = Util.GAME_MODES.MAIN
    mode_data.game_mode_type = Util.GAME_MODE_TYPE.NORMAL
    mode_data.description_key = "MAIN"
    mode_data.data_path = Util.PATH_JSON_DATA
    mode_data.disable_session_timer = false
    mode_data.end_run_disabled = false
    mode_data.on_more_time_disabled = false
    mode_data.upgrade_tree_grid_size = Vector2i(25, 25)
    current_game_mode_data = mode_data


func update_input_stuff(input_type: ControllerIcons.InputType):
    match input_type:
        ControllerIcons.InputType.KEYBOARD_MOUSE:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        ControllerIcons.InputType.CONTROLLER:
            Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    update_input_stuff(input_type)


func new_game():
    ensure_default_game_mode_data()
    clear_upgrade_tree_cache()
    reel_run_max_depth_cap = -1.0
    reel_repeat_depth_cap = -1.0
    multi_game_step_config = {}

    rng = RandomNumberGenerator.new()
    rng.randomize()

    mods = Mods.new()
    game_mode_data_manager = GameModeDataManager.new()
    global_resoruce_manager = GlobalResourceManager.new()

    session_stats = SessionStats.new()
    tier_stats = TierStats.new()
    run_stats = RunStats.new()

    config = Config.new()

    if current_game_mode_data != null:
        game_mode_data_manager.load_game_mode_data(current_game_mode_data)

func clear_upgrade_tree_cache() -> void:
    if cached_upgrade_tech_tree != null and is_instance_valid(cached_upgrade_tech_tree):
        cached_upgrade_tech_tree.queue_free()
    cached_upgrade_tech_tree = null
    cached_upgrade_tree_locale = ""
    FishingUpgradeDB.clear_cached_data()
    FishingUpgradeTreeAdapter.clear_cached_json_data()


func update_mouse():

    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        if Util.is_standalone_battle_mouse_managed() and game_state == Util.GAME_STATES.PLAYING:
            return
        if not Util.is_standalone_battle_mouse_managed():
            Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
            return

    if get_tree().paused == true:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    else:
        match game_state:
            Util.GAME_STATES.MAIN_MENU:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            Util.GAME_STATES.START_OF_SESSION:
                Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
            Util.GAME_STATES.PLAYING:
                if Util.is_standalone_battle_mouse_managed():
                    return
                Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
            Util.GAME_STATES.END_OF_SESSION:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            Util.GAME_STATES.END_OF_TEIR:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            Util.GAME_STATES.UPGRADES:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            Util.GAME_STATES.GAME_OVER:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
