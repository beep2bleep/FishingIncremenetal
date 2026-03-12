extends CanvasLayer

class_name UpgradeScreen

const SETTINGS_SCENE: PackedScene = preload("res://Settings.tscn")
const CONTROLLER_GLYPH_SCENE: PackedScene = preload("res://Controller Glyph.tscn")
const HOLD_RING_GLYPH_SCRIPT := preload("res://HoldRingGlyph.gd")
const GO_AGAIN_DISABLED_HINT := "You must unlock an upgrade before starting."
const DEMO_PROJECT_SETTING := "global/Demo"
const DEMO_WISHLIST_URL_SETTING := "global/DemoWishlistUrl"
const DEFAULT_DEMO_WISHLIST_URL := "https://Beep2Bleep.com"
const BATTLE_LEVEL_CHOICE_DIALOG_SIZE := Vector2(600.0, 450.0)
const BATTLE_LEVEL_CHOICE_DIALOG_FONT_SIZE := 24
const BATTLE_LEVEL_CHOICE_DIALOG_TITLE_SIZE := 36
const BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE := 72
const BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT := 180.0
const BATTLE_LEVEL_SELECTOR_FONT_SIZE := 52
const BATTLE_LEVEL_SELECTOR_BUTTON_WIDTH := 140.0
const BATTLE_LEVEL_SELECTOR_INPUT_WIDTH := 220.0
const BATTLE_LEVEL_X_CONFIRM_HOLD_SECONDS := 0.2
const UPGRADE_TOP_BUTTON_VERTICAL_SHIFT_RATIO := 0.05

var is_active = false
var editor_add_cash_amount: int = 1000
var editor_cash_controls: HBoxContainer
var editor_add_cash_button: Button
var editor_reset_add_button: Button
var editor_unlock_all_button: Button
var battle_level_choice_dialog: ConfirmationDialog
var battle_level_choice_selected_level: int = 1
var battle_level_choice_line_edit: LineEdit
var battle_level_choice_max_level: int = 1
var battle_level_choice_x_hold_ring: HoldRingGlyph
var reset_progress_confirm_dialog: ConfirmationDialog
var legacy_reset_dialog: ConfirmationDialog
var mute_button: Button
var settings_button: Button
var fullscreen_button: Button
var touch_input_button: Button
var settings_panel: PanelContainer
var settings_content: Settings
var reset_progress_button: Button
var go_again_button: Button
var demo_mode_label: Label
var wishlist_button: Button
var continue_locked_panel: PanelContainer
var continue_locked_label: Label
var version_label: Label
var speaker_icon_on: Texture2D
var speaker_icon_off: Texture2D
var fullscreen_icon_on: Texture2D
var fullscreen_icon_off: Texture2D
var _legacy_reset_dialog_shown := false
var _popup_prev_a_pressed := false
var _popup_prev_b_pressed := false
var _popup_prev_x_pressed := false
var _popup_prev_up_pressed := false
var _popup_prev_down_pressed := false
var _popup_x_hold_time := 0.0

func _should_show_editor_only_touch_toggle() -> bool:
    return OS.has_feature("editor")

var dragging = false
var scroll_speed = 500

var zoom

@onready var tech_tree: TechTree = %"Tech Tree"
var tree_initialized: bool = false
var prefers_simulation_tree: bool = false


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
    SignalBus.settings_updated.connect(_on_settings_updated)

    ControllerIcons.input_type_changed.connect(_on_input_type_changed)
    _bind_tech_tree(tech_tree)
    get_viewport().size_changed.connect(_on_viewport_size_changed)




    %CanvasLayer.hide()
    %CanvasLayer2.hide()

    set_process_input(false)
    set_process(false)

    update_colors()
    _setup_editor_cash_controls()
    _setup_battle_level_choice_dialog()
    _setup_reset_progress_controls()
    _setup_version_label()
    _setup_mute_button()
    _setup_settings_controls()
    _setup_fullscreen_button()
    _setup_touch_input_button()
    go_again_button = get_node_or_null("%Go Again")
    demo_mode_label = get_node_or_null("%Demo Mode Label")
    wishlist_button = get_node_or_null("%Wishlist")
    _setup_wishlist_button()
    _setup_continue_locked_dialog()
    _update_go_again_button_state()
    hide()

func _on_tech_tree_build_completed() -> void:
    if not is_active:
        return
    _sync_simulation_currency_from_save()
    update_input(ControllerIcons.get_last_input_type())
    _update_go_again_button_state()

func _bind_tech_tree(new_tree: TechTree) -> void:
    tech_tree = new_tree
    if tech_tree != null and not tech_tree.build_completed.is_connected(_on_tech_tree_build_completed):
        tech_tree.build_completed.connect(_on_tech_tree_build_completed)

func _restore_cached_tech_tree_if_available() -> void:
    if Global.cached_upgrade_tech_tree == null:
        return
    if not (Global.cached_upgrade_tech_tree is TechTree):
        Global.clear_upgrade_tree_cache()
        return

    var cached_tree: TechTree = Global.cached_upgrade_tech_tree
    Global.cached_upgrade_tech_tree = null

    if tech_tree != null and tech_tree != cached_tree and is_instance_valid(tech_tree):
        tech_tree.queue_free()

    if cached_tree.get_parent() != null:
        cached_tree.get_parent().remove_child(cached_tree)
    %CanvasLayer.add_child(cached_tree)
    cached_tree.name = "Tech Tree"
    cached_tree.visible = true
    cached_tree.set_process(true)
    cached_tree.set_process_input(true)
    cached_tree.set_process_unhandled_input(true)
    _bind_tech_tree(cached_tree)
    tree_initialized = true

func _cache_tech_tree_for_reuse() -> void:
    if not _is_simulation_upgrade_tree() or tech_tree == null or not is_instance_valid(tech_tree):
        return
    if tech_tree.get_parent() != null:
        tech_tree.get_parent().remove_child(tech_tree)
    tech_tree.visible = false
    tech_tree.set_process(false)
    tech_tree.set_process_input(false)
    tech_tree.set_process_unhandled_input(false)
    Global.add_child(tech_tree)
    Global.cached_upgrade_tech_tree = tech_tree

func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    if is_active == true:
        update_input(input_type)

func _input(event: InputEvent) -> void :
    if Global.game_state == Util.GAME_STATES.UPGRADES:
        if _is_battle_level_choice_open():
            if event.is_action_pressed("ui_accept") or event.is_action_pressed("go again"):
                if _confirm_battle_level_choice_from_controller():
                    get_viewport().set_input_as_handled()
                return
            if event.is_action_pressed("escape") or event.is_action_pressed("back"):
                _on_battle_level_choice_cancel_pressed()
                get_viewport().set_input_as_handled()
                return
            if event.is_action_pressed("up"):
                _on_battle_level_choice_adjust_pressed(1, battle_level_choice_max_level)
                get_viewport().set_input_as_handled()
                return
            if event.is_action_pressed("down"):
                _on_battle_level_choice_adjust_pressed(-1, battle_level_choice_max_level)
                get_viewport().set_input_as_handled()
                return
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
    prefers_simulation_tree = Global.start_in_upgrade_scene
    _restore_cached_tech_tree_if_available()
    if prefers_simulation_tree:
        return
    _ensure_tree_initialized()


func _on_global_resource_changed(event_data: GlobalResourceChangedEventData):
    if event_data.type == Util.RESOURCE_TYPES.MONEY:
        update()

func update():
    if tech_tree == null or not is_instance_valid(tech_tree):
        return
    tech_tree.update_active()


func _on_pallet_updated():
    update_colors()

func _on_settings_updated() -> void:
    _refresh_touch_input_button()
    _refresh_fullscreen_button_icon()
    if settings_content != null:
        settings_content.refresh_from_save()


func update_colors():
    %"Click Mask".color = Refs.pallet.background

    var color_light = Refs.pallet.background
    color_light.v *= 1.05
    %"GPUParticles2D Light".modulate = color_light

    var color_dark = Refs.pallet.background
    color_dark.v *= 0.95
    %"GPUParticles2D2 Dark".modulate = color_dark


func _process(delta: float) -> void :
    _poll_battle_level_choice_controller(delta)
    if is_active == true and state == STATES.SHOWING_TREE:

        match ControllerIcons.get_last_input_type():
            ControllerIcons.InputType.KEYBOARD_MOUSE:
                var direction = Vector2(Input.get_axis("right", "left"), Input.get_axis("down", "up")).normalized()

                if direction != Vector2.ZERO:
                    tech_tree.move_tech_tree(direction * scroll_speed * delta)

            ControllerIcons.InputType.CONTROLLER:

                if Input.is_action_just_pressed("ui_left"):
                    tech_tree.select_node_in_direction(Vector2.LEFT)
                elif Input.is_action_just_pressed("ui_right"):
                    tech_tree.select_node_in_direction(Vector2.RIGHT)
                elif Input.is_action_just_pressed("ui_up"):
                    tech_tree.select_node_in_direction(Vector2.UP)
                elif Input.is_action_just_pressed("ui_down"):
                    tech_tree.select_node_in_direction(Vector2.DOWN)






func _on_color_rect_gui_input(event: InputEvent) -> void :
    if event.is_action_pressed("Grab"):
        dragging = true
    elif event.is_action_released("Grab"):
        dragging = false

    if dragging and event is InputEventMouseMotion:
        tech_tree.move_tech_tree(event.relative)

func _poll_battle_level_choice_controller(delta: float) -> void:
    if not _is_battle_level_choice_open():
        _popup_prev_a_pressed = false
        _popup_prev_b_pressed = false
        _popup_prev_x_pressed = false
        _popup_prev_up_pressed = false
        _popup_prev_down_pressed = false
        _popup_x_hold_time = 0.0
        _refresh_battle_level_choice_x_hold_indicator()
        return
    if ControllerIcons.get_last_input_type() != ControllerIcons.InputType.CONTROLLER:
        return

    var device := _get_popup_controller_device()
    if device == -1:
        return

    var a_pressed := Input.is_joy_button_pressed(device, JOY_BUTTON_A)
    var b_pressed := Input.is_joy_button_pressed(device, JOY_BUTTON_B)
    var x_pressed := Input.is_joy_button_pressed(device, JOY_BUTTON_X)
    var up_pressed := Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP) or Input.get_joy_axis(device, JOY_AXIS_LEFT_Y) < -0.5
    var down_pressed := Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN) or Input.get_joy_axis(device, JOY_AXIS_LEFT_Y) > 0.5

    if a_pressed and not _popup_prev_a_pressed:
        _confirm_battle_level_choice_from_controller()
    elif x_pressed:
        if not _popup_prev_x_pressed:
            _popup_x_hold_time = 0.0
        else:
            _popup_x_hold_time += max(0.0, delta)
        if _popup_x_hold_time >= BATTLE_LEVEL_X_CONFIRM_HOLD_SECONDS:
            _confirm_battle_level_choice_from_controller()
            _popup_x_hold_time = -9999.0
    elif b_pressed and not _popup_prev_b_pressed:
        _on_battle_level_choice_cancel_pressed()
    elif up_pressed and not _popup_prev_up_pressed:
        _on_battle_level_choice_adjust_pressed(1, battle_level_choice_max_level)
    elif down_pressed and not _popup_prev_down_pressed:
        _on_battle_level_choice_adjust_pressed(-1, battle_level_choice_max_level)
    else:
        if not x_pressed:
            _popup_x_hold_time = 0.0

    _refresh_battle_level_choice_x_hold_indicator()

    _popup_prev_a_pressed = a_pressed
    _popup_prev_b_pressed = b_pressed
    _popup_prev_x_pressed = x_pressed
    _popup_prev_up_pressed = up_pressed
    _popup_prev_down_pressed = down_pressed

func _get_popup_controller_device() -> int:
    var connected := Input.get_connected_joypads()
    if connected.is_empty():
        return -1
    if ControllerIcons != null and ControllerIcons._last_controller in connected:
        return int(ControllerIcons._last_controller)
    return int(connected[0])

func _refresh_battle_level_choice_x_hold_indicator() -> void:
    if battle_level_choice_x_hold_ring == null:
        return
    var progress: float = 0.0
    if _popup_x_hold_time > 0.0:
        progress = clamp(_popup_x_hold_time / BATTLE_LEVEL_X_CONFIRM_HOLD_SECONDS, 0.0, 1.0)
    battle_level_choice_x_hold_ring.visible = ControllerIcons != null and ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER
    battle_level_choice_x_hold_ring.progress = progress



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
                    tech_tree.selected_node.click_mask.grab_focus()
                    _on_tech_tree_selected_node_changed(tech_tree.selected_node)



func show_screen():
    _ensure_tree_initialized()
    _sync_simulation_currency_from_save()
    is_active = true

    %CanvasLayer.show()
    %CanvasLayer2.show()
    _hide_settings_panel()
    VirtualCursor.set_scene_enabled(true)



    update_input(ControllerIcons.get_last_input_type())
    _refresh_mute_button_icon()
    _refresh_fullscreen_button_icon()
    _refresh_touch_input_button()
    _update_go_again_button_state()

    nodes_unlocked_this_session = 0

    Global.main.camera_2d.target_zoom = Global.main.camera_2d.target_zoom
    set_process_input(true)
    set_process(true)
    show()
    _show_legacy_reset_dialog_if_needed()


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
    VirtualCursor.set_scene_enabled(false)


func _on_go_again_pressed() -> void :
    if not _can_continue_to_battle():
        _show_continue_locked_dialog()
        _update_go_again_button_state()
        return
    if _is_simulation_upgrade_tree():
        var max_level: int = clamp(int(SaveHandler.fishing_max_unlocked_battle_level), 1, SaveHandler.MAX_FISHING_BATTLE_LEVEL)
        if max_level <= 1:
            _launch_battle_at_level(1)
        else:
            _show_battle_level_choice_dialog(max_level)
        return
    hide_screen()


func _on_tech_tree_selected_node_changed(new_selected_node: TechTreeNode) -> void :
    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        if new_selected_node != null:
            tech_tree.tween_to_pos( - new_selected_node.position)
        else:
            tech_tree.tween_to_pos(Vector2.ZERO)

func _is_simulation_upgrade_tree() -> bool:
    for upgrade_variant: Variant in Global.game_mode_data_manager.upgrades.values():
        if upgrade_variant is Upgrade:
            var upgrade: Upgrade = upgrade_variant
            if upgrade.sim_name != "":
                return true
    return false

func _is_simulation_upgrade_tree_requested() -> bool:
    return prefers_simulation_tree

func _ensure_tree_initialized(force_rebuild: bool = false) -> void:
    if tech_tree == null:
        return

    if force_rebuild and tree_initialized:
        _clear_tech_tree_runtime()
        tree_initialized = false

    if tree_initialized:
        return

    if _is_simulation_upgrade_tree_requested() or _is_simulation_upgrade_tree():
        FishingUpgradeTreeAdapter.apply_simulation_upgrades()
        _sync_simulation_currency_from_save()

    tech_tree.setup()
    tree_initialized = true

func _sync_simulation_currency_from_save() -> void:
    if not (_is_simulation_upgrade_tree_requested() or _is_simulation_upgrade_tree()):
        return
    if Global.global_resoruce_manager == null:
        return
    var current_money: int = int(Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY))
    var target_money: int = int(SaveHandler.fishing_currency)
    if current_money != target_money:
        Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, target_money - current_money)

func _is_demo_mode_enabled() -> bool:
    return bool(ProjectSettings.get_setting(DEMO_PROJECT_SETTING, false))

func _get_demo_wishlist_url() -> String:
    return str(ProjectSettings.get_setting(DEMO_WISHLIST_URL_SETTING, DEFAULT_DEMO_WISHLIST_URL)).strip_edges()

func _setup_wishlist_button() -> void:
    if demo_mode_label != null:
        demo_mode_label.visible = _is_demo_mode_enabled()
    if wishlist_button == null:
        return
    wishlist_button.visible = _is_demo_mode_enabled()
    wishlist_button.disabled = _get_demo_wishlist_url() == ""
    wishlist_button.tooltip_text = _get_demo_wishlist_url()
    if not wishlist_button.pressed.is_connected(_on_wishlist_button_pressed):
        wishlist_button.pressed.connect(_on_wishlist_button_pressed)
    _style_wishlist_button(wishlist_button)

func _style_wishlist_button(button: Button) -> void:
    if button == null:
        return
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.18, 0.6, 0.24, 1.0)
    normal.border_color = Color(0.78, 1.0, 0.82, 1.0)
    normal.border_width_left = 2
    normal.border_width_top = 2
    normal.border_width_right = 2
    normal.border_width_bottom = 2
    normal.corner_radius_top_left = 4
    normal.corner_radius_top_right = 4
    normal.corner_radius_bottom_left = 4
    normal.corner_radius_bottom_right = 4
    var hover := normal.duplicate(true)
    hover.bg_color = Color(0.24, 0.72, 0.3, 1.0)
    var disabled := normal.duplicate(true)
    disabled.bg_color = Color(0.26, 0.32, 0.26, 1.0)
    disabled.border_color = Color(0.5, 0.56, 0.5, 1.0)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_stylebox_override("disabled", disabled)

func _on_wishlist_button_pressed() -> void:
    var url: String = _get_demo_wishlist_url()
    if url == "":
        return
    OS.shell_open(url)

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
        battle_level_choice_dialog.get_cancel_button().hide()
        parent_layer.add_child(battle_level_choice_dialog)
    _style_battle_level_choice_dialog()
    if not battle_level_choice_dialog.custom_action.is_connected(_on_battle_level_choice_action):
        battle_level_choice_dialog.custom_action.connect(_on_battle_level_choice_action)

func _show_battle_level_choice_dialog(max_level: int) -> void:
    if battle_level_choice_dialog == null:
        _launch_battle_at_level(clamp(SaveHandler.fishing_next_battle_level, 1, max_level))
        return

    battle_level_choice_max_level = max_level
    battle_level_choice_selected_level = clamp(SaveHandler.fishing_next_battle_level, 1, max_level)
    battle_level_choice_dialog.dialog_text = ""
    _rebuild_battle_level_choice_dialog_content(max_level)
    _style_battle_level_choice_dialog()
    battle_level_choice_dialog.popup_centered(BATTLE_LEVEL_CHOICE_DIALOG_SIZE)
    _position_virtual_cursor_for_battle_level_choice(max_level)

func _on_battle_level_choice_action(action: StringName) -> void:
    var action_text: String = str(action)
    if not action_text.begins_with("level_"):
        return
    var level: int = int(action_text.trim_prefix("level_"))
    _launch_battle_at_level(level)

func _style_battle_level_choice_dialog() -> void:
    if battle_level_choice_dialog == null:
        return
    battle_level_choice_dialog.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_FONT_SIZE)
    battle_level_choice_dialog.add_theme_font_size_override("title_font_size", BATTLE_LEVEL_CHOICE_DIALOG_TITLE_SIZE)
    battle_level_choice_dialog.min_size = BATTLE_LEVEL_CHOICE_DIALOG_SIZE
    for child in battle_level_choice_dialog.get_children():
        if child is Label:
            child.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_FONT_SIZE)
            child.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _rebuild_battle_level_choice_dialog_content(max_level: int) -> void:
    if battle_level_choice_dialog == null:
        return
    battle_level_choice_line_edit = null
    battle_level_choice_x_hold_ring = null
    var existing: Control = battle_level_choice_dialog.get_node_or_null("BattleLevelChoiceContent")
    if existing != null:
        existing.queue_free()

    var margin := MarginContainer.new()
    margin.name = "BattleLevelChoiceContent"
    margin.anchor_left = 0.0
    margin.anchor_top = 0.0
    margin.anchor_right = 1.0
    margin.anchor_bottom = 1.0
    margin.offset_left = 24.0
    margin.offset_top = 24.0
    margin.offset_right = -24.0
    margin.offset_bottom = -24.0
    battle_level_choice_dialog.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.anchor_left = 0.0
    vbox.anchor_top = 0.0
    vbox.anchor_right = 1.0
    vbox.anchor_bottom = 1.0
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_theme_constant_override("separation", 16)
    margin.add_child(vbox)

    if max_level <= 4:
        for level in range(1, max_level + 1):
            var button := Button.new()
            button.name = "BattleLevelChoiceButton%d" % level
            button.text = "Level %d" % level
            button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            button.custom_minimum_size = Vector2(0.0, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
            button.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE)
            button.pressed.connect(_on_battle_level_choice_button_pressed.bind(level))
            vbox.add_child(button)
    else:
        var prompt := Label.new()
        prompt.text = "Select a battle level from 1 to %d." % max_level
        prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        prompt.add_theme_font_size_override("font_size", 28)
        vbox.add_child(prompt)

        var selector_row := HBoxContainer.new()
        selector_row.alignment = BoxContainer.ALIGNMENT_CENTER
        selector_row.add_theme_constant_override("separation", 18)
        selector_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        selector_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
        vbox.add_child(selector_row)

        var minus_button := Button.new()
        minus_button.text = "-"
        minus_button.custom_minimum_size = Vector2(BATTLE_LEVEL_SELECTOR_BUTTON_WIDTH, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        minus_button.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE)
        minus_button.pressed.connect(_on_battle_level_choice_adjust_pressed.bind(-1, max_level))
        selector_row.add_child(_wrap_control_with_glyph(minus_button, "joypad/dpad_down", false))

        battle_level_choice_line_edit = LineEdit.new()
        battle_level_choice_line_edit.name = "BattleLevelChoiceLineEdit"
        battle_level_choice_line_edit.text = str(battle_level_choice_selected_level)
        battle_level_choice_line_edit.custom_minimum_size = Vector2(BATTLE_LEVEL_SELECTOR_INPUT_WIDTH, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        battle_level_choice_line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
        battle_level_choice_line_edit.max_length = len(str(max_level))
        battle_level_choice_line_edit.add_theme_font_size_override("font_size", BATTLE_LEVEL_SELECTOR_FONT_SIZE)
        battle_level_choice_line_edit.text_submitted.connect(_on_battle_level_choice_text_submitted.bind(max_level))
        battle_level_choice_line_edit.focus_exited.connect(_on_battle_level_choice_input_focus_exited.bind(max_level))
        selector_row.add_child(battle_level_choice_line_edit)

        var plus_button := Button.new()
        plus_button.text = "+"
        plus_button.custom_minimum_size = Vector2(BATTLE_LEVEL_SELECTOR_BUTTON_WIDTH, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        plus_button.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE)
        plus_button.pressed.connect(_on_battle_level_choice_adjust_pressed.bind(1, max_level))
        selector_row.add_child(_wrap_control_with_glyph(plus_button, "joypad/dpad_up", true))

    var cancel_button := Button.new()
    cancel_button.name = "BattleLevelChoiceCancelButton"
    cancel_button.text = "Cancel"
    cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cancel_button.custom_minimum_size = Vector2(0.0, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
    cancel_button.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE)
    cancel_button.pressed.connect(_on_battle_level_choice_cancel_pressed)
    vbox.add_child(_wrap_control_with_glyph(cancel_button, "joypad/b", false))

    if max_level > 4:
        var confirm_button := Button.new()
        confirm_button.name = "BattleLevelChoiceConfirmButton"
        confirm_button.text = "Confirm"
        confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        confirm_button.custom_minimum_size = Vector2(0.0, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        confirm_button.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE)
        confirm_button.pressed.connect(_on_battle_level_choice_confirm_pressed.bind(max_level))
        var confirm_row := HBoxContainer.new()
        confirm_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        confirm_row.alignment = BoxContainer.ALIGNMENT_CENTER
        confirm_row.add_theme_constant_override("separation", 12)
        confirm_row.add_child(_make_controller_glyph("joypad/a"))
        battle_level_choice_x_hold_ring = _make_hold_ring_glyph("joypad/x")
        confirm_row.add_child(battle_level_choice_x_hold_ring)
        confirm_row.add_child(confirm_button)
        vbox.add_child(confirm_row)
        _refresh_battle_level_choice_x_hold_indicator()

        if battle_level_choice_line_edit != null:
            battle_level_choice_line_edit.select_all()

func _on_battle_level_choice_button_pressed(level: int) -> void:
    _launch_battle_at_level(level)

func _on_battle_level_choice_adjust_pressed(delta: int, max_level: int) -> void:
    battle_level_choice_selected_level = clamp(battle_level_choice_selected_level + delta, 1, max_level)
    _update_battle_level_choice_line_edit()
    _update_battle_level_choice_controller_target(max_level)

func _on_battle_level_choice_text_submitted(_text: String, max_level: int) -> void:
    _sync_battle_level_choice_from_input(max_level)

func _on_battle_level_choice_input_focus_exited(max_level: int) -> void:
    _sync_battle_level_choice_from_input(max_level)

func _on_battle_level_choice_confirm_pressed(max_level: int) -> void:
    _sync_battle_level_choice_from_input(max_level)
    _launch_battle_at_level(battle_level_choice_selected_level)

func _on_battle_level_choice_cancel_pressed() -> void:
    if battle_level_choice_dialog != null:
        battle_level_choice_dialog.hide()

func _launch_battle_at_level(level: int) -> void:
    var max_level: int = clamp(int(SaveHandler.fishing_max_unlocked_battle_level), 1, SaveHandler.MAX_FISHING_BATTLE_LEVEL)
    SaveHandler.fishing_next_battle_level = clamp(level, 1, max_level)
    SaveHandler.save_fishing_progress()
    _cache_tech_tree_for_reuse()
    SceneChanger.change_to_new_scene(Util.PATH_FISHING_BATTLE)

func _sync_battle_level_choice_from_input(max_level: int) -> void:
    if battle_level_choice_line_edit == null:
        return
    var raw_text: String = battle_level_choice_line_edit.text.strip_edges()
    if raw_text == "":
        battle_level_choice_selected_level = clamp(battle_level_choice_selected_level, 1, max_level)
    else:
        battle_level_choice_selected_level = clamp(int(raw_text), 1, max_level)
    _update_battle_level_choice_line_edit()

func _update_battle_level_choice_line_edit() -> void:
    if battle_level_choice_line_edit == null:
        return
    battle_level_choice_line_edit.text = str(battle_level_choice_selected_level)
    battle_level_choice_line_edit.caret_column = battle_level_choice_line_edit.text.length()

func _position_virtual_cursor_for_battle_level_choice(max_level: int) -> void:
    if ControllerIcons.get_last_input_type() != ControllerIcons.InputType.CONTROLLER:
        return
    VirtualCursor.activate_for_controller()
    await get_tree().process_frame
    await get_tree().process_frame
    if battle_level_choice_dialog == null or not battle_level_choice_dialog.visible:
        return
    _update_battle_level_choice_controller_target(max_level)

func _update_battle_level_choice_controller_target(max_level: int) -> void:
    if ControllerIcons.get_last_input_type() != ControllerIcons.InputType.CONTROLLER:
        return
    if battle_level_choice_dialog == null or not battle_level_choice_dialog.visible:
        return
    var target: Control = _get_primary_battle_level_choice_button(max_level)
    if target != null:
        target.grab_focus()
        VirtualCursor.move_to_control(target)

func _is_battle_level_choice_open() -> bool:
    return battle_level_choice_dialog != null and battle_level_choice_dialog.visible

func _confirm_battle_level_choice_from_controller() -> bool:
    if battle_level_choice_max_level <= 4:
        _launch_battle_at_level(battle_level_choice_selected_level)
        return true
    _on_battle_level_choice_confirm_pressed(battle_level_choice_max_level)
    return true

func _get_primary_battle_level_choice_button(max_level: int) -> Control:
    if battle_level_choice_dialog == null:
        return null
    if max_level <= 4:
        return battle_level_choice_dialog.get_node_or_null("BattleLevelChoiceContent/VBoxContainer/BattleLevelChoiceButton%d" % battle_level_choice_selected_level)
    var confirm_button: Control = battle_level_choice_dialog.get_node_or_null("BattleLevelChoiceContent/VBoxContainer/BattleLevelChoiceConfirmButton")
    if confirm_button != null:
        return confirm_button
    return battle_level_choice_dialog.get_node_or_null("BattleLevelChoiceContent/VBoxContainer/BattleLevelChoiceCancelButton")

func _wrap_control_with_glyph(control: Control, action_path: String, glyph_after_control: bool) -> HBoxContainer:
    return _wrap_control_with_glyphs(control, [action_path], glyph_after_control)

func _wrap_control_with_glyphs(control: Control, action_paths: Array[String], glyph_after_control: bool) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.add_theme_constant_override("separation", 12)

    if not glyph_after_control:
        for action_path in action_paths:
            row.add_child(_make_controller_glyph(action_path))
    row.add_child(control)
    if glyph_after_control:
        for action_path in action_paths:
            row.add_child(_make_controller_glyph(action_path))
    return row

func _make_controller_glyph(action_path: String) -> ControllerGlyph:
    var glyph := CONTROLLER_GLYPH_SCENE.instantiate() as ControllerGlyph
    var icon_texture := ControllerIconTexture.new()
    icon_texture.path = action_path
    glyph.texture = icon_texture
    glyph.custom_minimum_size = Vector2(42.0, 42.0)
    glyph.size = Vector2(42.0, 42.0)
    glyph.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    glyph.enabled = true
    return glyph

func _make_hold_ring_glyph(action_path: String) -> HoldRingGlyph:
    var ring := HOLD_RING_GLYPH_SCRIPT.new() as HoldRingGlyph
    ring.custom_minimum_size = Vector2(42.0, 42.0)
    ring.size = Vector2(42.0, 42.0)
    var glyph := _make_controller_glyph(action_path)
    glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    glyph.custom_minimum_size = Vector2.ZERO
    ring.add_child(glyph)
    return ring

func _find_battle_level_choice_control_at_cursor(root: Control, screen_position: Vector2) -> Control:
    if root == null or not is_instance_valid(root) or not root.visible:
        return null
    for child_index in range(root.get_child_count() - 1, -1, -1):
        var child := root.get_child(child_index)
        if child is Control:
            var match: Control = _find_battle_level_choice_control_at_cursor(child as Control, screen_position)
            if match != null:
                return match
    if root is BaseButton and not (root as BaseButton).disabled and root.get_global_rect().has_point(screen_position):
        return root
    return null

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

    legacy_reset_dialog = ConfirmationDialog.new()
    legacy_reset_dialog.name = "LegacyResetDialog"
    legacy_reset_dialog.title = "Progress Reset Required"
    legacy_reset_dialog.dialog_text = "Thank you for playing the previous version. We apologize, but we have to reset your progress because the upgrades have changed so drastically. We will make every effort to avoid doing this again."
    legacy_reset_dialog.confirmed.connect(_on_legacy_reset_confirmed)
    legacy_reset_dialog.canceled.connect(_on_legacy_reset_canceled)
    var continue_button: Button = legacy_reset_dialog.get_ok_button()
    if continue_button != null:
        continue_button.text = "Continue"
    var legacy_cancel_button: Button = legacy_reset_dialog.get_cancel_button()
    if legacy_cancel_button != null:
        legacy_cancel_button.hide()
    %CanvasLayer2.add_child(legacy_reset_dialog)

func _setup_version_label() -> void:
    if version_label != null and is_instance_valid(version_label):
        return
    version_label = Label.new()
    version_label.name = "VersionLabel"
    version_label.anchor_left = 1.0
    version_label.anchor_top = 0.0
    version_label.anchor_right = 1.0
    version_label.anchor_bottom = 0.0
    version_label.offset_left = -220.0
    version_label.offset_top = 72.0
    version_label.offset_right = -16.0
    version_label.offset_bottom = 110.0
    version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    version_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    version_label.text = "Version %s" % SaveHandler.FISHING_SAVE_VERSION
    %CanvasLayer2.add_child(version_label)

func _show_legacy_reset_dialog_if_needed() -> void:
    if _legacy_reset_dialog_shown:
        return
    if legacy_reset_dialog == null:
        return
    if not SaveHandler.needs_fishing_legacy_reset():
        return
    _legacy_reset_dialog_shown = true
    legacy_reset_dialog.popup_centered()

func _on_reset_progress_button_pressed() -> void:
    if reset_progress_confirm_dialog == null:
        return
    reset_progress_confirm_dialog.popup_centered()

func _on_reset_progress_confirmed() -> void:
    _perform_progress_reset()

func _on_legacy_reset_confirmed() -> void:
    _perform_progress_reset()

func _on_legacy_reset_canceled() -> void:
    if SaveHandler.needs_fishing_legacy_reset():
        legacy_reset_dialog.call_deferred("popup_centered")

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
    SaveHandler.fishing_max_unlocked_battle_level = SaveHandler.MAX_FISHING_BATTLE_LEVEL
    SaveHandler.fishing_next_battle_level = SaveHandler.MAX_FISHING_BATTLE_LEVEL
    SaveHandler.save_fishing_progress()

    _reload_simulation_upgrade_tree_from_save()
    update()

func _reload_simulation_upgrade_tree_from_save() -> void:
    if tech_tree == null:
        return
    if not _is_simulation_upgrade_tree():
        return

    _ensure_tree_initialized(true)
    tech_tree.update_active()
    _update_go_again_button_state()

func _clear_tech_tree_runtime() -> void:
    if Global.cached_upgrade_tech_tree == tech_tree:
        Global.cached_upgrade_tech_tree = null
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
    tech_tree.depth_by_cell = {}
    tech_tree.build_in_progress = false
    tech_tree.set_process(false)
    tech_tree._batched_upgrade_queue = []
    tech_tree._batched_line_cells = []
    tech_tree._batched_forced_nodes = []
    tech_tree._build_stage = ""

    var lines_container: Node = tech_tree.get_node_or_null("Pivot/Tech Lines")
    if lines_container != null:
        for child in lines_container.get_children():
            child.queue_free()

    var nodes_container: Node = tech_tree.get_node_or_null("Pivot/Tech Nodes")
    if nodes_container != null:
        for child in nodes_container.get_children():
            child.queue_free()
    tree_initialized = false

func _setup_mute_button() -> void:
    mute_button = get_node_or_null("%MuteButton")
    if mute_button == null:
        return
    speaker_icon_on = _make_speaker_icon_texture(false)
    speaker_icon_off = _make_speaker_icon_texture(true)
    mute_button.text = ""
    mute_button.focus_mode = Control.FOCUS_NONE
    mute_button.offset_left = -42.0
    mute_button.offset_right = 42.0
    mute_button.offset_top = 16.0
    mute_button.offset_bottom = 82.0
    mute_button.custom_minimum_size = Vector2(84, 66)
    mute_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mute_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    mute_button.expand_icon = true
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
    settings_button.offset_left = -184.0
    settings_button.offset_top = 16.0
    settings_button.offset_right = -16.0
    settings_button.offset_bottom = 104.0
    settings_button.z_index = 210
    settings_button.focus_mode = Control.FOCUS_NONE
    settings_button.text = "Settings"
    settings_button.custom_minimum_size = Vector2(168, 88)
    settings_button.add_theme_font_size_override("font_size", 26)
    settings_button.pressed.connect(_on_settings_button_pressed)
    _style_utility_button(settings_button)
    %CanvasLayer2.add_child(settings_button)
    _update_upgrade_top_button_positions()

    settings_panel = PanelContainer.new()
    settings_panel.name = "UpgradeSettingsPanel"
    settings_panel.anchor_left = 0.0
    settings_panel.anchor_top = 0.0
    settings_panel.anchor_right = 1.0
    settings_panel.anchor_bottom = 1.0
    settings_panel.offset_left = 16.0
    settings_panel.offset_top = 16.0
    settings_panel.offset_right = -16.0
    settings_panel.offset_bottom = -16.0
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
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(vbox)

    var title: Label = Label.new()
    title.text = "SETTINGS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 46)
    vbox.add_child(title)

    settings_content = SETTINGS_SCENE.instantiate() as Settings
    if settings_content != null:
        settings_content.name = "SettingsContent"
        settings_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        settings_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
        settings_content.scale = Vector2(1.7, 1.7)
        vbox.add_child(settings_content)

    var close_button: Button = Button.new()
    close_button.name = "SettingsCloseButton"
    close_button.text = "BACK"
    close_button.focus_mode = Control.FOCUS_NONE
    close_button.custom_minimum_size = Vector2(0, 150)
    close_button.add_theme_font_size_override("font_size", 34)
    close_button.pressed.connect(_on_settings_close_pressed)
    _style_utility_button(close_button)
    vbox.add_child(close_button)

func _setup_fullscreen_button() -> void:
    if fullscreen_button != null and is_instance_valid(fullscreen_button):
        return
    fullscreen_button = Button.new()
    fullscreen_button.name = "FullscreenButton"
    fullscreen_button.anchor_left = 0.0
    fullscreen_button.anchor_top = 0.0
    fullscreen_button.anchor_right = 0.0
    fullscreen_button.anchor_bottom = 0.0
    fullscreen_button.offset_left = 16.0
    fullscreen_button.offset_top = 72.0
    fullscreen_button.offset_right = 60.0
    fullscreen_button.offset_bottom = 116.0
    fullscreen_button.z_index = 210
    fullscreen_button.focus_mode = Control.FOCUS_NONE
    fullscreen_button.text = ""
    fullscreen_button.custom_minimum_size = Vector2(44, 44)
    fullscreen_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
    fullscreen_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    fullscreen_button.expand_icon = true
    fullscreen_button.pressed.connect(_on_fullscreen_button_pressed)
    _style_utility_button(fullscreen_button)
    %CanvasLayer2.add_child(fullscreen_button)
    fullscreen_icon_on = _make_fullscreen_icon_texture(true)
    fullscreen_icon_off = _make_fullscreen_icon_texture(false)
    _refresh_fullscreen_button_icon()

func _setup_touch_input_button() -> void:
    if not _should_show_editor_only_touch_toggle():
        return
    if touch_input_button != null and is_instance_valid(touch_input_button):
        return
    touch_input_button = Button.new()
    touch_input_button.name = "TouchInputButton"
    touch_input_button.anchor_left = 1.0
    touch_input_button.anchor_top = 0.0
    touch_input_button.anchor_right = 1.0
    touch_input_button.anchor_bottom = 0.0
    touch_input_button.offset_left = -256.0
    touch_input_button.offset_top = 112.0
    touch_input_button.offset_right = -16.0
    touch_input_button.offset_bottom = 200.0
    touch_input_button.z_index = 210
    touch_input_button.focus_mode = Control.FOCUS_NONE
    touch_input_button.custom_minimum_size = Vector2(240, 88)
    touch_input_button.add_theme_font_size_override("font_size", 26)
    touch_input_button.pressed.connect(_on_touch_input_button_pressed)
    _style_utility_button(touch_input_button)
    %CanvasLayer2.add_child(touch_input_button)
    _update_upgrade_top_button_positions()
    _refresh_touch_input_button()

func _update_upgrade_top_button_positions() -> void:
    var viewport: Viewport = get_viewport()
    if viewport == null:
        return
    var vertical_shift := viewport.get_visible_rect().size.y * UPGRADE_TOP_BUTTON_VERTICAL_SHIFT_RATIO
    if settings_button != null and is_instance_valid(settings_button):
        settings_button.offset_top = 16.0 + vertical_shift
        settings_button.offset_bottom = 104.0 + vertical_shift
    if touch_input_button != null and is_instance_valid(touch_input_button):
        touch_input_button.offset_top = 112.0 + vertical_shift
        touch_input_button.offset_bottom = 200.0 + vertical_shift

func _on_viewport_size_changed() -> void:
    _update_upgrade_top_button_positions()

func _is_settings_open() -> bool:
    return settings_panel != null and is_instance_valid(settings_panel) and settings_panel.visible

func _on_settings_button_pressed() -> void:
    if settings_content != null:
        settings_content.show_screen()
        settings_content.refresh_from_save()
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
    return SaveHandler.has_any_fishing_upgrade()

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

func _refresh_fullscreen_button_icon() -> void:
    if fullscreen_button == null:
        return
    var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    fullscreen_button.icon = fullscreen_icon_on if is_fullscreen else fullscreen_icon_off
    fullscreen_button.tooltip_text = "Exit fullscreen" if is_fullscreen else "Enter fullscreen"

func _on_fullscreen_button_pressed() -> void:
    var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    SaveHandler.update_screen_mode(
        SaveHandler.SCREEN_MODES.WINDOWED if is_fullscreen else SaveHandler.SCREEN_MODES.FULL_SCREEN
    )
    _refresh_fullscreen_button_icon()
    if settings_content != null:
        settings_content.refresh_from_save()

func _refresh_touch_input_button() -> void:
    if touch_input_button == null:
        return
    touch_input_button.text = "Confirm Upgrade Purchase: ON" if SaveHandler.confirm_upgrade_purchase else "Confirm Upgrade Purchase: OFF"

func _on_touch_input_button_pressed() -> void:
    SaveHandler.update_confirm_upgrade_purchase(not SaveHandler.confirm_upgrade_purchase)
    _refresh_touch_input_button()
    if settings_content != null:
        settings_content.refresh_from_save()

func _make_fullscreen_icon_texture(is_fullscreen: bool) -> ImageTexture:
    var image := Image.create(80, 80, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))
    var line_color := Color(0.93, 0.97, 1.0, 1.0)
    if is_fullscreen:
        _draw_rect_pixels(image, Rect2i(12, 12, 20, 6), line_color)
        _draw_rect_pixels(image, Rect2i(12, 12, 6, 20), line_color)
        _draw_rect_pixels(image, Rect2i(48, 12, 20, 6), line_color)
        _draw_rect_pixels(image, Rect2i(62, 12, 6, 20), line_color)
        _draw_rect_pixels(image, Rect2i(12, 62, 20, 6), line_color)
        _draw_rect_pixels(image, Rect2i(12, 48, 6, 20), line_color)
        _draw_rect_pixels(image, Rect2i(48, 62, 20, 6), line_color)
        _draw_rect_pixels(image, Rect2i(62, 48, 6, 20), line_color)
    else:
        _draw_rect_pixels(image, Rect2i(24, 12, 6, 20), line_color)
        _draw_rect_pixels(image, Rect2i(12, 24, 20, 6), line_color)
        _draw_rect_pixels(image, Rect2i(50, 12, 6, 20), line_color)
        _draw_rect_pixels(image, Rect2i(48, 24, 20, 6), line_color)
        _draw_rect_pixels(image, Rect2i(24, 48, 6, 20), line_color)
        _draw_rect_pixels(image, Rect2i(12, 50, 20, 6), line_color)
        _draw_rect_pixels(image, Rect2i(50, 48, 6, 20), line_color)
        _draw_rect_pixels(image, Rect2i(48, 50, 20, 6), line_color)
    return ImageTexture.create_from_image(image)

func _make_speaker_icon_texture(is_muted: bool) -> ImageTexture:
    var image := Image.create(80, 80, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))
    var speaker_color := Color(0.93, 0.97, 1.0, 1.0)
    _draw_rect_pixels(image, Rect2i(14, 28, 14, 24), speaker_color)
    _draw_triangle_right(image, Vector2i(28, 40), 22, 18, speaker_color)
    if is_muted:
        _draw_thick_line(image, Vector2i(42, 20), Vector2i(68, 60), Color(1.0, 0.2, 0.2, 1.0), 4)
        _draw_thick_line(image, Vector2i(68, 20), Vector2i(42, 60), Color(1.0, 0.2, 0.2, 1.0), 4)
    else:
        _draw_arc_ring(image, Vector2i(40, 40), 16, 22, PI * -0.42, PI * 0.42, speaker_color)
        _draw_arc_ring(image, Vector2i(40, 40), 24, 30, PI * -0.42, PI * 0.42, speaker_color)
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
