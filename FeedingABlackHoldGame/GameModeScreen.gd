extends Control
class_name GameModeScreen

@export var game_mode_datas: Array[GameModeData] = []
@export var game_mode_panel_packed: PackedScene
@export var is_game_over_screen: bool = false
@export var mode_spacing: float = 400.0
var mode_spacing_scaled: float = mode_spacing
@export var transition_duration: float = 0.35
@export var center_scale: float = 1.0
@export var side_scale: float = 0.65
@export var scale_falloff_distance: float = 500.0
@export_group("Alpha Fading")
@export var alpha_center: float = 1.0
@export var alpha_adjacent: float = 0.6
@export var alpha_far: float = 0.2



signal back
signal play_new_game_mode(game_mode_data: GameModeData)
signal continue_game_mode(game_mode_data: GameModeData)

enum STATES{HIDDEN, ACTIVE, CONFIRM_NEW_GAME}
var state = STATES.HIDDEN:
    set(new_value):
        if state != new_value:
            state = new_value
            match state:
                STATES.HIDDEN:
                    pass
                STATES.ACTIVE:
                    %"New Game Popup".hide()
                    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
                        update_input(ControllerIcons.InputType.CONTROLLER)
                STATES.CONFIRM_NEW_GAME:
                    %"New Game Popup".show()
                    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
                        %"No  New Game".grab_focus()

var mode_panels: Array[GameModePanel] = []
var current_mode_index: int = -1

var target_mode_index: int = -1:
    set(new_value):
        target_mode_index = new_value

        if state == STATES.ACTIVE:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.GAME_MODE_HOVER)


var is_transitioning: bool = false
var current_tween: Tween = null

@onready var modes_container: Control = %Modes

var current_mode_data: GameModeData:
    get:
        if target_mode_index >= 0 and target_mode_index < game_mode_datas.size():
            return game_mode_datas[target_mode_index]
        elif current_mode_index >= 0 and current_mode_index < game_mode_datas.size():
            return game_mode_datas[current_mode_index]
        return null

func _ready():

    _setup_modes()

    update_ui()

    ControllerIcons.input_type_changed.connect(_on_input_type_changed)


    SignalBus.settings_updated.connect(_on_settings_updated_changed)
    _on_settings_updated_changed()



func _setup_modes() -> void :
    "Create a panel for each game mode"

    for child in modes_container.get_children():
        child.queue_free()
    mode_panels.clear()


    for i in range(game_mode_datas.size()):
        if ProjectSettings.get_setting("global/Demo") == true and game_mode_datas[i].hide_in_demo == true:
            continue

        if ProjectSettings.get_setting("global/Demo") == false and game_mode_datas[i].is_for_demo == true:
            continue

        var panel = _create_mode_panel(i)
        modes_container.add_child(panel)
        mode_panels.append(panel)

    _scroll_to_mode(0)

    _update_all_positions(0.0)

func _create_mode_panel(index: int) -> GameModePanel:
    "Create a single mode panel"
    var panel = game_mode_panel_packed.instantiate() as GameModePanel
    panel.name = "ModePanel_" + str(index)
    panel.index = index
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.setup(game_mode_datas[index])
    panel.selected.connect(_on_panel_selected)
    return panel


func _on_panel_selected(index = 0):
    _scroll_to_mode(index)

func _on_settings_updated_changed():
    mode_spacing_scaled = mode_spacing * SaveHandler.text_scale



func _input(event: InputEvent) -> void :
    if state == STATES.ACTIVE:
        if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed) or event.is_action_pressed("game_mode_left"):
            _scroll_to_mode(target_mode_index - 1)
            accept_event()
        elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed) or event.is_action_pressed("game_mode_right"):
            _scroll_to_mode(target_mode_index + 1)
            accept_event()








var new_game_enabled = false:
    set(new_value):
        new_game_enabled = new_value

        %"New Game".visible = new_value
        %"Play HBoxContainer2".visible = new_value


        if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER and %"New Game".has_focus():
            %"Back to Menu".grab_focus()

        %"Continue Glyph".update()
        %"Play Glyph".update()

var continue_game_enabled = false:
    set(new_value):
        continue_game_enabled = new_value


        %Continue.visible = new_value
        %"Continue HBoxContainer".visible = new_value



        if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER and %Continue.has_focus():
            %"Back to Menu".grab_focus()

        %"Continue Glyph".update()
        %"Play Glyph".update()


func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    update_input(input_type)


func update_input(input_type):
    if input_type == ControllerIcons.InputType.CONTROLLER and state == STATES.ACTIVE:
        if %"Prev Mode".has_focus() or %"Next Mode".has_focus():
            return

        if continue_game_enabled == true:
            if not %"New Game".has_focus() and not %"Back to Menu".has_focus():
                %Continue.grab_focus()

        elif new_game_enabled == true:
            if not %"Back to Menu".has_focus():
                %"New Game".grab_focus()
        else:
            %"Back to Menu".grab_focus()

    %"Continue Glyph".update()
    %"Play Glyph".update()

func _scroll_to_mode(new_index: int) -> void :
    "Scroll to a specific mode index"

    new_index = clampi(new_index, 0, game_mode_datas.size() - 1)





    if new_index == target_mode_index:
        return

    target_mode_index = new_index
    update_ui()






    _animate_to_target()

func _animate_to_target() -> void :
    "Animate all panels to the target mode index"
    if mode_panels.is_empty():
        return


    if current_tween and current_tween.is_running():
        current_tween.kill()

    is_transitioning = true


    if current_mode_index >= 0 and current_mode_index < mode_panels.size():
        mode_panels[current_mode_index].is_active = false


    current_tween = create_tween()
    current_tween.set_parallel(true)
    current_tween.set_ease(Tween.EASE_OUT)
    current_tween.set_trans(Tween.TRANS_CUBIC)


    for i in range(mode_panels.size()):
        var panel = mode_panels[i]
        var target_pos = _calculate_position(i, target_mode_index)
        var target_scale = _calculate_scale(i, target_mode_index)
        var target_alpha = _calculate_alpha(i, target_mode_index)

        current_tween.tween_property(panel, "position", target_pos, transition_duration)
        current_tween.tween_property(panel, "scale", Vector2.ONE * target_scale, transition_duration)
        current_tween.tween_property(panel, "modulate:a", target_alpha, transition_duration)








    current_tween.finished.connect(_on_transition_finished)

func _on_transition_finished() -> void :
    is_transitioning = false

    if current_mode_index != target_mode_index:
        current_mode_index = target_mode_index

        update_ui()

func _update_all_positions(duration: float = 0.0) -> void :
    "Update all panel positions (instant if duration = 0)"
    for i in range(mode_panels.size()):
        var panel = mode_panels[i]
        var pos = _calculate_position(i, current_mode_index)
        var scale_value = _calculate_scale(i, current_mode_index)
        var alpha = _calculate_alpha(i, current_mode_index)

        if duration <= 0.0:
            panel.position = pos
            panel.scale = Vector2.ONE * scale_value
            panel.modulate.a = alpha
        else:
            var tween = create_tween()
            tween.set_parallel(true)
            tween.tween_property(panel, "position", pos, duration)
            tween.tween_property(panel, "scale", Vector2.ONE * scale_value, duration)
            tween.tween_property(panel, "modulate:a", alpha, duration)

func _calculate_position(panel_index: int, center_index: int) -> Vector2:
    "Calculate the position of a panel relative to the center"
    var offset_from_center = panel_index - center_index


    var center_x = modes_container.size.x / 2.0
    var center_y = modes_container.size.y / 2.0


    var x_pos = center_x


    if offset_from_center != 0:
        var direction = sign(offset_from_center)
        var steps = abs(offset_from_center)

        for i in range(steps):
            var current_index = center_index + (direction * i)
            var next_index = center_index + (direction * (i + 1))

            if current_index >= 0 and current_index < mode_panels.size():
                var current_panel = mode_panels[current_index]
                x_pos += direction * (current_panel.size.x / 2.0)


            x_pos += direction * mode_spacing_scaled

            if next_index >= 0 and next_index < mode_panels.size():
                var next_panel = mode_panels[next_index]
                x_pos += direction * (next_panel.size.x / 2.0)


    var panel = mode_panels[panel_index]
    x_pos -= panel.size.x / 2.0

    return Vector2(x_pos, center_y - panel.size.y / 2.0)

func _calculate_scale(panel_index: int, center_index: int) -> float:
    "Calculate scale based on distance from center"
    var distance = abs(panel_index - center_index) * mode_spacing
    var t = clamp(distance / scale_falloff_distance, 0.0, 1.0)
    return lerp(center_scale, side_scale, t)

func _calculate_alpha(panel_index: int, center_index: int) -> float:
    "Calculate alpha based on distance from center"
    var distance = abs(panel_index - center_index)


    if distance == 0:
        return alpha_center
    elif distance == 1:
        return alpha_adjacent
    else:
        return alpha_far



func update_ui():

    if is_game_over_screen:
        %ColorRect.hide()
        %"Back MarginContainer2".hide()

    else:
        %ColorRect.show()
        %"Back MarginContainer2".show()


    "Update the UI based on current mode data"

    var mode_data = current_mode_data

    if mode_data != null:
        new_game_enabled = true
        continue_game_enabled = false

        if ProjectSettings.get_setting("global/Demo") == true:
            if mode_data.is_for_demo == false:
                new_game_enabled = false
            else:
                new_game_enabled = true
                continue_game_enabled = SaveHandler.has_save_data_for_game_mode_data(mode_data)



        elif mode_data.coming_soon == true:
            new_game_enabled = false

        elif mode_data.game_mode != Util.GAME_MODES.MAIN and SaveHandler.has_beated_main_mode() == false:
            new_game_enabled = false

        else:
            continue_game_enabled = SaveHandler.has_save_data_for_game_mode_data(mode_data)

    else:
        new_game_enabled = false
        continue_game_enabled = false

    %"New Game".text = tr("NEW_GAME") if continue_game_enabled else tr("PLAY")

    update_input(ControllerIcons.get_last_input_type())

    %"Continue Glyph".update()
    %"Play Glyph".update()


func show_screen():
    state = STATES.ACTIVE

    update_ui()
    _update_all_positions(0.5)

    %"Modes MarginContainer".add_theme_constant_override("margin_bottom", %"Bottom Bar MC".size.y + 10)






func _on_prev_mode_button_pressed() -> void :
    _scroll_to_mode(target_mode_index - 1)

func _on_next_mode_button_pressed() -> void :
    _scroll_to_mode(target_mode_index + 1)

func _on_back_to_menu_pressed() -> void :
    state = STATES.HIDDEN
    back.emit()

func _on_new_game_pressed() -> void :
    if continue_game_enabled == false:
        state = STATES.HIDDEN
        play_new_game_mode.emit(current_mode_data)
    else:
        state = STATES.CONFIRM_NEW_GAME

func _on_continue_pressed() -> void :
    state = STATES.HIDDEN
    continue_game_mode.emit(current_mode_data)


func _on_prev_mode_pressed() -> void :
    _scroll_to_mode(target_mode_index - 1)


func _on_next_mode_pressed() -> void :
    _scroll_to_mode(target_mode_index + 1)


func _on_yes_new_game_pressed() -> void :
    state = STATES.HIDDEN
    play_new_game_mode.emit(current_mode_data)

func _on_no__new_game_pressed() -> void :
    state = STATES.ACTIVE
