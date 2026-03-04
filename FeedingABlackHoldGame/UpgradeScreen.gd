extends CanvasLayer

class_name UpgradeScreen

const CURSOR_PICKUP_UNLOCK_KEY := "cursor_pickup_unlock"
const SETTINGS_SCENE: PackedScene = preload("res://Settings.tscn")
const GO_AGAIN_DISABLED_HINT := "You must unlock an upgrade before starting."

var is_active = false
var editor_add_cash_amount: int = 1000
var editor_cash_controls: HBoxContainer
var editor_add_cash_button: Button
var editor_reset_add_button: Button
var editor_unlock_all_button: Button
var battle_level_choice_dialog: ConfirmationDialog
var reset_progress_confirm_dialog: ConfirmationDialog
var mute_button: Button
var settings_button: Button
var settings_panel: PanelContainer
var settings_content: Settings
var reset_progress_button: Button
var go_again_button: Button
var continue_locked_panel: PanelContainer
var continue_locked_label: Label
var speaker_icon_on: Texture2D
var speaker_icon_off: Texture2D


var dragging = false
var scroll_speed = 500

var zoom

@onready var tech_tree: TechTree = %"Tech Tree"


enum STATES{SHOWING_TREE, ROGULIKE}

var _state: int = STATES.SHOWING_TREE
var state: int:
    get:
        return _state
    set(new_value):
        if _state == new_value:
            return
        _state = new_value

        match _state:
            STATES.SHOWING_TREE:
                %"Bottom Bar".show()
            STATES.ROGULIKE:
                %"Bottom Bar".hide()



func _ready() -> void :
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    SignalBus.global_resource_changed.connect(_on_global_resource_changed)

    ControllerIcons.input_type_changed.connect(_on_input_type_changed)




    %CanvasLayer.hide()
    %CanvasLayer2.hide()

    set_process_input(false)
    set_process(false)

    update_colors()
    _setup_editor_cash_controls()
    _setup_battle_level_choice_dialog()
    _setup_reset_progress_controls()
    _setup_mute_button()
    _setup_settings_controls()
    go_again_button = get_node_or_null("%Go Again")
    _setup_continue_locked_dialog()
    _update_go_again_button_state()
    hide()

func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    if is_active == true:
        update_input(input_type)

func _input(event: InputEvent) -> void :
    if Global.game_state == Util.GAME_STATES.UPGRADES:
        if _is_continue_locked_open():
            if event.is_action_pressed("escape") or event.is_action_pressed("back") or event.is_action_pressed("ui_accept"):
                _hide_continue_locked_panel()
            return
        if _is_settings_open():
            if event.is_action_pressed("escape") or event.is_action_pressed("back"):
                _hide_settings_panel()
            return
        if event.is_action_pressed("go again"):
            _on_go_again_pressed()











func setup():
    %"Tech Tree".setup()


func _on_global_resource_changed(event_data: GlobalResourceChangedEventData):
    if event_data.type == Util.RESOURCE_TYPES.MONEY:
        update()

func update():
    %"Tech Tree".update_active()


func _on_pallet_updated():
    update_colors()


func update_colors():
    %"Click Mask".color = Refs.pallet.background

    var color_light = Refs.pallet.background
    color_light.v *= 1.05
    %"GPUParticles2D Light".modulate = color_light

    var color_dark = Refs.pallet.background
    color_dark.v *= 0.95
    %"GPUParticles2D2 Dark".modulate = color_dark


func _process(delta: float) -> void :
    if is_active == true and state == STATES.SHOWING_TREE:

        match ControllerIcons.get_last_input_type():
            ControllerIcons.InputType.KEYBOARD_MOUSE:
                var direction = Vector2(Input.get_axis("right", "left"), Input.get_axis("down", "up")).normalized()

                if direction != Vector2.ZERO:
                    %"Tech Tree".move_tech_tree(direction * scroll_speed * delta)

            ControllerIcons.InputType.CONTROLLER:

                if Input.is_action_just_pressed("ui_left"):
                    %"Tech Tree".select_node_in_direction(Vector2.LEFT)
                elif Input.is_action_just_pressed("ui_right"):
                    %"Tech Tree".select_node_in_direction(Vector2.RIGHT)
                elif Input.is_action_just_pressed("ui_up"):
                    %"Tech Tree".select_node_in_direction(Vector2.UP)
                elif Input.is_action_just_pressed("ui_down"):
                    %"Tech Tree".select_node_in_direction(Vector2.DOWN)






func _on_color_rect_gui_input(event: InputEvent) -> void :
    if event.is_action_pressed("Grab"):
        dragging = true
    elif event.is_action_released("Grab"):
        dragging = false

    if dragging and event is InputEventMouseMotion:
        %"Tech Tree".move_tech_tree(event.relative)



var nodes_unlocked_this_session = 0


func on_node_unlocked(node: TechTreeNode):
    if Global.game_state == Util.GAME_STATES.UPGRADES:

        match nodes_unlocked_this_session:
            0:
                %AudioStreamPlayer.play()
            1:
                %AudioStreamPlayer2.play()
            2:
                %AudioStreamPlayer3.play()
            _:
                AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_CLICK)


        nodes_unlocked_this_session += 1

    if node.upgrade and node.upgrade.type == Util.NODE_TYPES.ROGUELIKE_DUMMY:
        match state:
            STATES.SHOWING_TREE:
                var new_screen: UpgradesRoguelike = Refs.roguelike_screen_packed.instantiate()
                %"Popup Layer".add_child(new_screen)
                new_screen.setup(node)

                state = STATES.ROGULIKE
            STATES.ROGULIKE:
                pass

    check_upgrade_tree_achivements()
    _update_go_again_button_state()


func update_input(input_type):
    if is_active == true:
        match input_type:
            ControllerIcons.InputType.KEYBOARD_MOUSE:
                %"Pan Tree".show()
                %"Navigate DPAD".hide()
                %"Mouse Drag Tree".show()
            ControllerIcons.InputType.CONTROLLER:
                %"Pan Tree".hide()
                %"Navigate DPAD".show()
                %"Mouse Drag Tree".hide()

                if tech_tree.selected_node != null:
                    %"Tech Tree".selected_node.click_mask.grab_focus()
                    _on_tech_tree_selected_node_changed( %"Tech Tree".selected_node)



func show_screen():
    is_active = true

    %CanvasLayer.show()
    %CanvasLayer2.show()
    _hide_settings_panel()



    update_input(ControllerIcons.get_last_input_type())
    _refresh_mute_button_icon()
    _update_go_again_button_state()

    nodes_unlocked_this_session = 0

    Global.main.camera_2d.target_zoom = Global.main.camera_2d.target_zoom
    set_process_input(true)
    set_process(true)
    show()


func check_upgrade_tree_achivements():
    var send_data = false
    if Global.current_game_mode_data.game_mode != Util.GAME_MODES.MAIN:
        return

    if tech_tree.next_completed_index >= 50:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.HAVE_50_UPGRADES, false)
        if need_to_update == true:
            send_data = true

    if tech_tree.next_completed_index >= 100:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.HAVE_100_UPGRADES, false)
        if need_to_update == true:
            send_data = true

    if tech_tree.next_completed_index >= 150:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.HAVE_150_UPGRADES, false)
        if need_to_update == true:
            send_data = true

    if tech_tree.next_completed_index >= 200:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.HAVE_200_UPGRADES, false)
        if need_to_update == true:
            send_data = true

    if send_data == true:
        SteamHandler.store_steam_data()


func hide_screen():
    set_process_input(false)
    set_process(false)
    SceneChanger.do_transition(self, Global.main)
    is_active = false
    %CanvasLayer.hide()
    %CanvasLayer2.hide()
    _hide_continue_locked_panel()


func _on_go_again_pressed() -> void :
    if not _can_continue_to_battle():
        _show_continue_locked_dialog()
        _update_go_again_button_state()
        return
    if _is_simulation_upgrade_tree():
        var max_level: int = clamp(int(SaveHandler.fishing_max_unlocked_battle_level), 1, 3)
        if max_level <= 1:
            _launch_battle_at_level(1)
        else:
            _show_battle_level_choice_dialog(max_level)
        return
    hide_screen()


func _on_tech_tree_selected_node_changed(new_selected_node: TechTreeNode) -> void :
    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        if new_selected_node != null:
            %"Tech Tree".tween_to_pos( - new_selected_node.position)
        else:
            %"Tech Tree".tween_to_pos(Vector2.ZERO)

func _is_simulation_upgrade_tree() -> bool:
    for upgrade_variant: Variant in Global.game_mode_data_manager.upgrades.values():
        if upgrade_variant is Upgrade:
            var upgrade: Upgrade = upgrade_variant
            if upgrade.sim_name != "":
                return true
    return false

func _setup_battle_level_choice_dialog() -> void:
    var parent_layer: CanvasLayer = %CanvasLayer2
    if parent_layer == null:
        return
    battle_level_choice_dialog = parent_layer.get_node_or_null("BattleLevelChoiceDialog")
    if battle_level_choice_dialog == null:
        battle_level_choice_dialog = ConfirmationDialog.new()
        battle_level_choice_dialog.name = "BattleLevelChoiceDialog"
        battle_level_choice_dialog.title = "Choose Battle Level"
        battle_level_choice_dialog.get_ok_button().hide()
        parent_layer.add_child(battle_level_choice_dialog)
    if not battle_level_choice_dialog.custom_action.is_connected(_on_battle_level_choice_action):
        battle_level_choice_dialog.custom_action.connect(_on_battle_level_choice_action)

func _show_battle_level_choice_dialog(max_level: int) -> void:
    if battle_level_choice_dialog == null:
        _launch_battle_at_level(clamp(SaveHandler.fishing_next_battle_level, 1, max_level))
        return

    battle_level_choice_dialog.dialog_text = "Select the battle level to run."
    for child in battle_level_choice_dialog.get_children():
        if child is Button and child.name.begins_with("BattleLevelChoiceButton"):
            child.queue_free()

    for level in range(1, max_level + 1):
        var button: Button = battle_level_choice_dialog.add_button("Level %d" % level, true, "level_%d" % level)
        button.name = "BattleLevelChoiceButton%d" % level

    battle_level_choice_dialog.popup_centered()

func _on_battle_level_choice_action(action: StringName) -> void:
    var action_text: String = str(action)
    if not action_text.begins_with("level_"):
        return
    var level: int = int(action_text.trim_prefix("level_"))
    _launch_battle_at_level(level)

func _launch_battle_at_level(level: int) -> void:
    var max_level: int = clamp(int(SaveHandler.fishing_max_unlocked_battle_level), 1, 3)
    SaveHandler.fishing_next_battle_level = clamp(level, 1, max_level)
    SaveHandler.save_fishing_progress()
    SceneChanger.change_to_new_scene(Util.PATH_FISHING_BATTLE)

func _setup_editor_cash_controls() -> void:
    if not OS.has_feature("editor"):
        return
    if editor_cash_controls != null and is_instance_valid(editor_cash_controls):
        return

    editor_cash_controls = HBoxContainer.new()
    editor_cash_controls.name = "EditorCashControls"
    editor_cash_controls.anchor_left = 1.0
    editor_cash_controls.anchor_top = 0.0
    editor_cash_controls.anchor_right = 1.0
    editor_cash_controls.anchor_bottom = 0.0
    editor_cash_controls.offset_left = -520.0
    editor_cash_controls.offset_top = 12.0
    editor_cash_controls.offset_right = -12.0
    editor_cash_controls.offset_bottom = 56.0
    editor_cash_controls.alignment = BoxContainer.ALIGNMENT_END
    editor_cash_controls.z_index = 200
    editor_cash_controls.mouse_filter = Control.MOUSE_FILTER_STOP

    editor_add_cash_button = Button.new()
    editor_add_cash_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_add_cash_button.pressed.connect(_on_editor_add_cash_pressed)
    editor_cash_controls.add_child(editor_add_cash_button)

    editor_reset_add_button = Button.new()
    editor_reset_add_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_reset_add_button.text = "Reset Add"
    editor_reset_add_button.pressed.connect(_on_editor_reset_add_pressed)
    editor_cash_controls.add_child(editor_reset_add_button)

    editor_unlock_all_button = Button.new()
    editor_unlock_all_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_unlock_all_button.text = "Unlock All (Editor)"
    editor_unlock_all_button.pressed.connect(_on_editor_unlock_all_pressed)
    editor_cash_controls.add_child(editor_unlock_all_button)

    %CanvasLayer2.add_child(editor_cash_controls)
    _refresh_editor_cash_button_text()

func _refresh_editor_cash_button_text() -> void:
    if editor_add_cash_button == null:
        return
    editor_add_cash_button.text = "Add $%d (Editor)" % editor_add_cash_amount

func _on_editor_add_cash_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, editor_add_cash_amount)
    editor_add_cash_amount *= 2
    _refresh_editor_cash_button_text()
    update()

func _on_editor_reset_add_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    editor_add_cash_amount = 1000
    _refresh_editor_cash_button_text()

func _setup_reset_progress_controls() -> void:
    if reset_progress_button != null and is_instance_valid(reset_progress_button):
        return
    reset_progress_button = Button.new()
    reset_progress_button.name = "ResetProgressButton"
    reset_progress_button.anchor_left = 0.0
    reset_progress_button.anchor_top = 0.0
    reset_progress_button.anchor_right = 0.0
    reset_progress_button.anchor_bottom = 0.0
    reset_progress_button.offset_left = 16.0
    reset_progress_button.offset_top = 16.0
    reset_progress_button.offset_right = 296.0
    reset_progress_button.offset_bottom = 60.0
    reset_progress_button.z_index = 210
    reset_progress_button.focus_mode = Control.FOCUS_NONE
    reset_progress_button.text = "Reset Progress"
    reset_progress_button.pressed.connect(_on_reset_progress_button_pressed)
    %CanvasLayer2.add_child(reset_progress_button)

    reset_progress_confirm_dialog = ConfirmationDialog.new()
    reset_progress_confirm_dialog.name = "ResetProgressConfirmDialog"
    reset_progress_confirm_dialog.title = "Confirm Reset"
    reset_progress_confirm_dialog.dialog_text = "You will reset your time, currency, and upgrades. Would you like to continue?"
    reset_progress_confirm_dialog.confirmed.connect(_on_reset_progress_confirmed)
    var ok_button: Button = reset_progress_confirm_dialog.get_ok_button()
    if ok_button != null:
        ok_button.text = "Yes"
    var cancel_button: Button = reset_progress_confirm_dialog.get_cancel_button()
    if cancel_button != null:
        cancel_button.text = "No"
    %CanvasLayer2.add_child(reset_progress_confirm_dialog)

func _on_reset_progress_button_pressed() -> void:
    if reset_progress_confirm_dialog == null:
        return
    reset_progress_confirm_dialog.popup_centered()

func _on_reset_progress_confirmed() -> void:
    _perform_progress_reset()

func _perform_progress_reset() -> void:
    SaveHandler.reset_fishing_progress()
    SaveHandler.save_fishing_progress()
    editor_add_cash_amount = 1000
    _refresh_editor_cash_button_text()

    if Global.global_resoruce_manager != null:
        Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.MONEY)

    _reload_simulation_upgrade_tree_from_save()
    update()
    _update_go_again_button_state()

func _on_editor_unlock_all_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    if not _is_simulation_upgrade_tree():
        return

    var max_level_by_key: Dictionary = {}
    for upgrade_variant: Variant in Global.game_mode_data_manager.upgrades.values():
        if not (upgrade_variant is Upgrade):
            continue
        var upgrade: Upgrade = upgrade_variant
        if upgrade.sim_key == "":
            continue
        var max_level: int = int(upgrade.sim_level) + int(upgrade.max_tier) - 1
        var prev_level: int = int(max_level_by_key.get(upgrade.sim_key, 0))
        if max_level > prev_level:
            max_level_by_key[upgrade.sim_key] = max_level

    SaveHandler.fishing_unlocked_upgrades = {}
    SaveHandler.fishing_active_upgrades = {}
    for key_variant: Variant in max_level_by_key.keys():
        var key: String = str(key_variant)
        var level: int = int(max_level_by_key[key])
        SaveHandler.fishing_unlocked_upgrades[key] = level
        SaveHandler.fishing_active_upgrades[key] = true
    SaveHandler.fishing_max_unlocked_battle_level = 3
    SaveHandler.fishing_next_battle_level = 3
    SaveHandler.save_fishing_progress()

    _reload_simulation_upgrade_tree_from_save()
    update()

func _reload_simulation_upgrade_tree_from_save() -> void:
    if tech_tree == null:
        return
    if not _is_simulation_upgrade_tree():
        return

    FishingUpgradeTreeAdapter.apply_simulation_upgrades()

    var current_money: int = int(Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY))
    var target_money: int = int(SaveHandler.fishing_currency)
    if current_money != target_money:
        Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, target_money - current_money)

    _clear_tech_tree_runtime()
    tech_tree.setup()
    tech_tree.update_active()
    _update_go_again_button_state()

func _clear_tech_tree_runtime() -> void:
    if tech_tree.has_method("kill_tween"):
        tech_tree.call("kill_tween")
    tech_tree.pivot.position = Vector2.ZERO
    tech_tree.node_dict = {}
    tech_tree.active_nodes = []
    tech_tree.forced_connections_to_from = {}
    tech_tree.next_completed_index = 0
    tech_tree.selected_node = null
    tech_tree.center_node = null
    tech_tree.requirement_hint_node = null
    tech_tree.min_x = 0
    tech_tree.max_x = 0
    tech_tree.min_y = 0
    tech_tree.max_y = 0

    var lines_container: Node = tech_tree.get_node_or_null("Pivot/Tech Lines")
    if lines_container != null:
        for child in lines_container.get_children():
            child.queue_free()

    var nodes_container: Node = tech_tree.get_node_or_null("Pivot/Tech Nodes")
    if nodes_container != null:
        for child in nodes_container.get_children():
            child.queue_free()

func _setup_mute_button() -> void:
    mute_button = get_node_or_null("%MuteButton")
    if mute_button == null:
        return
    speaker_icon_on = _make_speaker_icon_texture(false)
    speaker_icon_off = _make_speaker_icon_texture(true)
    mute_button.text = ""
    mute_button.focus_mode = Control.FOCUS_NONE
    mute_button.custom_minimum_size = Vector2(56, 44)
    _style_utility_button(mute_button)
    _refresh_mute_button_icon()

func _setup_settings_controls() -> void:
    if settings_button != null and is_instance_valid(settings_button):
        return
    settings_button = Button.new()
    settings_button.name = "SettingsButton"
    settings_button.anchor_left = 1.0
    settings_button.anchor_top = 0.0
    settings_button.anchor_right = 1.0
    settings_button.anchor_bottom = 0.0
    settings_button.offset_left = -156.0
    settings_button.offset_top = 48.0
    settings_button.offset_right = -72.0
    settings_button.offset_bottom = 92.0
    settings_button.z_index = 210
    settings_button.focus_mode = Control.FOCUS_NONE
    settings_button.text = "Settings"
    settings_button.pressed.connect(_on_settings_button_pressed)
    _style_utility_button(settings_button)
    %CanvasLayer2.add_child(settings_button)

    settings_panel = PanelContainer.new()
    settings_panel.name = "UpgradeSettingsPanel"
    settings_panel.anchor_left = 0.5
    settings_panel.anchor_top = 0.5
    settings_panel.anchor_right = 0.5
    settings_panel.anchor_bottom = 0.5
    settings_panel.offset_left = -280.0
    settings_panel.offset_top = -320.0
    settings_panel.offset_right = 280.0
    settings_panel.offset_bottom = 320.0
    settings_panel.z_index = 220
    settings_panel.visible = false
    settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _style_utility_button_panel(settings_panel)
    %CanvasLayer2.add_child(settings_panel)

    var margin: MarginContainer = MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 12)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_right", 12)
    margin.add_theme_constant_override("margin_bottom", 12)
    settings_panel.add_child(margin)

    var vbox: VBoxContainer = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 12)
    margin.add_child(vbox)

    var title: Label = Label.new()
    title.text = "SETTINGS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    settings_content = SETTINGS_SCENE.instantiate() as Settings
    if settings_content != null:
        settings_content.name = "SettingsContent"
        vbox.add_child(settings_content)

    var close_button: Button = Button.new()
    close_button.name = "SettingsCloseButton"
    close_button.text = "BACK"
    close_button.focus_mode = Control.FOCUS_NONE
    close_button.pressed.connect(_on_settings_close_pressed)
    vbox.add_child(close_button)

func _is_settings_open() -> bool:
    return settings_panel != null and is_instance_valid(settings_panel) and settings_panel.visible

func _on_settings_button_pressed() -> void:
    if settings_content != null:
        settings_content.show_screen()
    if settings_panel != null:
        settings_panel.show()

func _on_settings_close_pressed() -> void:
    _hide_settings_panel()

func _hide_settings_panel() -> void:
    if settings_panel != null and is_instance_valid(settings_panel):
        settings_panel.hide()

func _can_continue_to_battle() -> bool:
    if not _is_simulation_upgrade_tree():
        return true
    return SaveHandler.has_fishing_upgrade(CURSOR_PICKUP_UNLOCK_KEY)

func _update_go_again_button_state() -> void:
    if go_again_button == null:
        return
    var can_continue: bool = _can_continue_to_battle()
    go_again_button.disabled = false
    go_again_button.tooltip_text = "" if can_continue else GO_AGAIN_DISABLED_HINT
    go_again_button.modulate = Color(1.0, 1.0, 1.0, 1.0) if can_continue else Color(0.7, 0.7, 0.7, 1.0)

func _setup_continue_locked_dialog() -> void:
    var parent_layer: CanvasLayer = %CanvasLayer2
    if parent_layer == null:
        return
    continue_locked_panel = PanelContainer.new()
    continue_locked_panel.name = "ContinueLockedPanel"
    continue_locked_panel.anchor_left = 0.5
    continue_locked_panel.anchor_top = 0.5
    continue_locked_panel.anchor_right = 0.5
    continue_locked_panel.anchor_bottom = 0.5
    continue_locked_panel.offset_left = -290.0
    continue_locked_panel.offset_top = -120.0
    continue_locked_panel.offset_right = 290.0
    continue_locked_panel.offset_bottom = 120.0
    continue_locked_panel.z_index = 230
    continue_locked_panel.visible = false
    continue_locked_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _style_utility_button_panel(continue_locked_panel)
    parent_layer.add_child(continue_locked_panel)

    var margin: MarginContainer = MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 16)
    margin.add_theme_constant_override("margin_top", 16)
    margin.add_theme_constant_override("margin_right", 16)
    margin.add_theme_constant_override("margin_bottom", 16)
    continue_locked_panel.add_child(margin)

    var vbox: VBoxContainer = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 14)
    margin.add_child(vbox)

    var title: Label = Label.new()
    title.text = "CONTINUE LOCKED"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    continue_locked_label = Label.new()
    continue_locked_label.text = GO_AGAIN_DISABLED_HINT
    continue_locked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    continue_locked_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    continue_locked_label.custom_minimum_size = Vector2(500, 0)
    vbox.add_child(continue_locked_label)

    var ok_button: Button = Button.new()
    ok_button.name = "ContinueLockedOkButton"
    ok_button.text = "OK"
    ok_button.focus_mode = Control.FOCUS_ALL
    ok_button.pressed.connect(_hide_continue_locked_panel)
    _style_utility_button(ok_button)
    vbox.add_child(ok_button)

func _show_continue_locked_dialog() -> void:
    if continue_locked_panel == null:
        return
    if _is_settings_open():
        _hide_settings_panel()
    if continue_locked_panel.visible:
        return
    continue_locked_panel.show()
    var ok_button: Button = continue_locked_panel.get_node_or_null("MarginContainer/VBoxContainer/ContinueLockedOkButton")
    if ok_button != null:
        ok_button.grab_focus()

func _hide_continue_locked_panel() -> void:
    if continue_locked_panel != null and is_instance_valid(continue_locked_panel):
        continue_locked_panel.hide()

func _is_continue_locked_open() -> bool:
    return continue_locked_panel != null and is_instance_valid(continue_locked_panel) and continue_locked_panel.visible

func _style_utility_button(button: Button) -> void:
    if button == null:
        return
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.08, 0.1, 0.16, 0.96)
    normal.border_color = Color(0.88, 0.92, 1.0, 1.0)
    normal.border_width_left = 2
    normal.border_width_top = 2
    normal.border_width_right = 2
    normal.border_width_bottom = 2
    normal.corner_radius_top_left = 4
    normal.corner_radius_top_right = 4
    normal.corner_radius_bottom_left = 4
    normal.corner_radius_bottom_right = 4
    var hover := normal.duplicate(true)
    hover.bg_color = Color(0.14, 0.18, 0.26, 0.98)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)

func _style_utility_button_panel(panel: PanelContainer) -> void:
    if panel == null:
        return
    var box := StyleBoxFlat.new()
    box.bg_color = Color(0.04, 0.06, 0.1, 0.98)
    box.border_color = Color(0.88, 0.92, 1.0, 1.0)
    box.border_width_left = 2
    box.border_width_top = 2
    box.border_width_right = 2
    box.border_width_bottom = 2
    box.corner_radius_top_left = 6
    box.corner_radius_top_right = 6
    box.corner_radius_bottom_left = 6
    box.corner_radius_bottom_right = 6
    panel.add_theme_stylebox_override("panel", box)

func _refresh_mute_button_icon() -> void:
    if mute_button == null:
        return
    mute_button.icon = speaker_icon_off if SaveHandler.audio_muted else speaker_icon_on
    mute_button.tooltip_text = "Unmute all audio" if SaveHandler.audio_muted else "Mute all audio"

func _on_mute_button_pressed() -> void:
    SaveHandler.update_audio_muted(not SaveHandler.audio_muted)
    _refresh_mute_button_icon()

func _make_speaker_icon_texture(is_muted: bool) -> ImageTexture:
    var image := Image.create(40, 40, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))
    var speaker_color := Color(0.93, 0.97, 1.0, 1.0)
    _draw_rect_pixels(image, Rect2i(7, 14, 7, 12), speaker_color)
    _draw_triangle_right(image, Vector2i(14, 20), 11, 9, speaker_color)
    if is_muted:
        _draw_thick_line(image, Vector2i(21, 10), Vector2i(34, 30), Color(1.0, 0.2, 0.2, 1.0), 2)
        _draw_thick_line(image, Vector2i(34, 10), Vector2i(21, 30), Color(1.0, 0.2, 0.2, 1.0), 2)
    else:
        _draw_arc_ring(image, Vector2i(20, 20), 8, 11, PI * -0.42, PI * 0.42, speaker_color)
        _draw_arc_ring(image, Vector2i(20, 20), 12, 15, PI * -0.42, PI * 0.42, speaker_color)
    return ImageTexture.create_from_image(image)

func _draw_rect_pixels(image: Image, rect: Rect2i, color: Color) -> void:
    for x in range(rect.position.x, rect.position.x + rect.size.x):
        for y in range(rect.position.y, rect.position.y + rect.size.y):
            image.set_pixel(x, y, color)

func _draw_triangle_right(image: Image, center: Vector2i, width: int, half_height: int, color: Color) -> void:
    for i in range(width):
        var x: int = center.x + i
        var y_top: int = center.y - int(round(float(half_height) * (1.0 - float(i) / float(width))))
        var y_bottom: int = center.y + int(round(float(half_height) * (1.0 - float(i) / float(width))))
        for y in range(y_top, y_bottom + 1):
            image.set_pixel(x, y, color)

func _draw_thick_line(image: Image, start: Vector2i, finish: Vector2i, color: Color, thickness: int) -> void:
    var steps: int = maxi(abs(finish.x - start.x), abs(finish.y - start.y))
    if steps <= 0:
        image.set_pixel(start.x, start.y, color)
        return
    for i in range(steps + 1):
        var t: float = float(i) / float(steps)
        var x: int = int(round(lerpf(float(start.x), float(finish.x), t)))
        var y: int = int(round(lerpf(float(start.y), float(finish.y), t)))
        for ox in range(-thickness, thickness + 1):
            for oy in range(-thickness, thickness + 1):
                if abs(ox) + abs(oy) <= thickness + 1:
                    image.set_pixel(x + ox, y + oy, color)

func _draw_arc_ring(image: Image, center: Vector2i, inner_radius: int, outer_radius: int, start_angle: float, end_angle: float, color: Color) -> void:
    for x in range(image.get_width()):
        for y in range(image.get_height()):
            var px: float = float(x - center.x)
            var py: float = float(y - center.y)
            var angle: float = atan2(py, px)
            if angle < start_angle or angle > end_angle:
                continue
            var dist_sq: float = px * px + py * py
            if dist_sq >= float(inner_radius * inner_radius) and dist_sq <= float(outer_radius * outer_radius):
                image.set_pixel(x, y, color)
