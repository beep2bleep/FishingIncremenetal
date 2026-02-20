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


const G = 100000.0

var load_saved_run = true



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


func update_input_stuff(input_type: ControllerIcons.InputType):
    match input_type:
        ControllerIcons.InputType.KEYBOARD_MOUSE:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        ControllerIcons.InputType.CONTROLLER:
            Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    update_input_stuff(input_type)


func new_game():
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


func update_mouse():

    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
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
                Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
            Util.GAME_STATES.END_OF_SESSION:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            Util.GAME_STATES.END_OF_TEIR:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            Util.GAME_STATES.UPGRADES:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            Util.GAME_STATES.GAME_OVER:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
