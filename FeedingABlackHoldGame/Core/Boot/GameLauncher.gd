extends Control

const TITLE_TEXT := "CHOOSE A GAME"
const VANGUARD_BUTTON_TEXT := "VANGUARD"
const MINING_BUTTON_TEXT := "MINING"

@onready var title_label: Label = %TitleLabel
@onready var vanguard_button: Button = %VanguardButton
@onready var mining_button: Button = %MiningButton

func _ready() -> void:
    Global.game_state = Util.GAME_STATES.MAIN_MENU
    title_label.text = TITLE_TEXT
    vanguard_button.text = VANGUARD_BUTTON_TEXT
    mining_button.text = MINING_BUTTON_TEXT
    if not vanguard_button.pressed.is_connected(_on_vanguard_button_pressed):
        vanguard_button.pressed.connect(_on_vanguard_button_pressed)
    if not mining_button.pressed.is_connected(_on_mining_button_pressed):
        mining_button.pressed.connect(_on_mining_button_pressed)
    vanguard_button.grab_focus()

func _on_vanguard_button_pressed() -> void:
    _start_game(Util.ACTIVE_GAME_VANGUARD)

func _on_mining_button_pressed() -> void:
    _start_game(Util.ACTIVE_GAME_MINING)

func _start_game(game_id: String) -> void:
    Util.set_active_game_id(game_id)
    SaveHandler.load_fishing_progress()
    Global.ensure_default_game_mode_data()
    Global.new_game()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = false
    SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)
