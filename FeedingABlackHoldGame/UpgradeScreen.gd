extends CanvasLayer

class_name UpgradeScreen

const SETTINGS_SCENE: PackedScene = preload("res://Settings.tscn")
const CONTROLLER_GLYPH_SCENE: PackedScene = preload("res://Controller Glyph.tscn")
const MINING_PROGRESS_SCRIPT = preload("res://Games/Mining/MiningProgress.gd")
const MINING_UPGRADE_TREE_ADAPTER_SCRIPT = preload("res://Games/Mining/MiningUpgradeTreeAdapter.gd")
const OPEN_PIT_PROGRESS_SCRIPT = preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const OPEN_PIT_UPGRADE_TREE_ADAPTER_SCRIPT = preload("res://Games/OpenPitEmpire/OpenPitEmpireUpgradeTreeAdapter.gd")
var OPEN_PIT_ORBIT_PROGRESS_SCRIPT = load("res://Games/OpenPitOrbit/OpenPitOrbitProgress.gd")
var OPEN_PIT_ORBIT_UPGRADE_TREE_ADAPTER_SCRIPT = load("res://Games/OpenPitOrbit/OpenPitOrbitUpgradeTreeAdapter.gd")
const RED_SKY_PROGRESS_SCRIPT = preload("res://Games/RedSkyDefense/RedSkyProgress.gd")
const RED_SKY_UPGRADE_TREE_ADAPTER_SCRIPT = preload("res://Games/RedSkyDefense/RedSkyUpgradeTreeAdapter.gd")
const TURKEY_PROGRESS_SCRIPT = preload("res://Games/Turkey/TurkeyProgress.gd")
const TURKEY_UPGRADE_TREE_ADAPTER_SCRIPT = preload("res://Games/Turkey/TurkeyUpgradeTreeAdapter.gd")
var REEL_INTO_DARKNESS_PROGRESS_SCRIPT = load("res://Games/ReelIntoDarkness/ReelIntoDarknessProgress.gd")
var REEL_INTO_DARKNESS_DATA_SCRIPT = load("res://Games/ReelIntoDarkness/ReelIntoDarknessData.gd")
var REEL_INTO_DARKNESS_UPGRADE_TREE_ADAPTER_SCRIPT = load("res://Games/ReelIntoDarkness/ReelIntoDarknessUpgradeTreeAdapter.gd")
const MINING_CRT_OVERLAY_SCRIPT = preload("res://Games/Mining/UI/MiningCrtOverlay.gd")
const CRT_TEXT_MIRROR_OVERLAY_SCRIPT = preload("res://Core/CrtTextMirrorOverlay.gd")
const GO_AGAIN_DISABLED_HINT := "UPGRADE_GO_AGAIN_DISABLED_HINT"
const DEMO_PROJECT_SETTING := "global/Demo"
const DEMO_WISHLIST_URL_SETTING := "global/DemoWishlistUrl"
const BATTLE_LEVEL_CHOICE_DIALOG_SIZE := Vector2(600.0, 450.0)
const BATTLE_LEVEL_CHOICE_DIALOG_FONT_SIZE := 24
const BATTLE_LEVEL_CHOICE_DIALOG_TITLE_SIZE := 36
const BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE := 72
const BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT := 180.0
const BATTLE_LEVEL_SELECTOR_FONT_SIZE := 52
const BATTLE_LEVEL_SELECTOR_BUTTON_WIDTH := 140.0
const BATTLE_LEVEL_SELECTOR_INPUT_WIDTH := 220.0
const REEL_DEPTH_TIER_DIALOG_SIZE := Vector2(640.0, 520.0)
const REEL_DEPTH_TIER_BUTTON_FONT := 26
const REEL_DEPTH_TIER_BUTTON_MIN_H := 72.0
const UPGRADE_TOP_BUTTON_VERTICAL_SHIFT_RATIO := 0.05
const LEADERBOARD_PANEL_TOP_DEFAULT := 120.0
const LEADERBOARD_PANEL_TOP_MARGIN_FROM_MENU := 16.0
const SETTINGS_EXIT_MAIN_MENU_MIN_H_DEFAULT := 120.0
const SETTINGS_EXIT_QUIT_MIN_H_DEFAULT := 120.0
const SETTINGS_EXIT_BACK_MIN_H_DEFAULT := 150.0
const SETTINGS_EXIT_MAIN_MENU_FONT_DEFAULT := 30
const SETTINGS_EXIT_QUIT_FONT_DEFAULT := 30
const SETTINGS_EXIT_BACK_FONT_DEFAULT := 34
const SETTINGS_EXIT_BUTTON_MIN_H_COMPACT := 68.0
const SETTINGS_EXIT_BACK_MIN_H_COMPACT := 78.0
const SETTINGS_EXIT_BUTTON_FONT_COMPACT := 22
const SETTINGS_EXIT_BACK_FONT_COMPACT := 24
const SETTINGS_EXIT_VIEWPORT_H_EXTRA_COMPACT := 780.0
const SETTINGS_EXIT_BUTTON_MIN_H_EXTRA_COMPACT := 56.0
const SETTINGS_EXIT_BACK_MIN_H_EXTRA_COMPACT := 64.0
const SETTINGS_EXIT_BUTTON_FONT_EXTRA_COMPACT := 18
const SETTINGS_EXIT_BACK_FONT_EXTRA_COMPACT := 20
const EDITOR_SELL_MENU_ID := 1

var is_active = false
var editor_add_cash_amount: int = 1000
var editor_add_xp_amount: int = 100
var editor_add_core_amount: int = 1
var editor_cash_controls: HBoxContainer
var editor_add_cash_button: Button
var editor_add_xp_button: Button
var editor_add_core_button: Button
var editor_auto_buy_button: Button
var editor_reset_add_button: Button
var editor_unlock_all_button: Button
var editor_regenerate_planet_button: Button
var editor_crt_toggle_button: Button
var editor_demo_toggle_button: Button
var editor_exit_demo_button: Button
var editor_mode_jump_controls: HBoxContainer
var editor_data_breach_jump_button: Button
var editor_deepcore_jump_button: Button
var editor_red_sky_jump_button: Button
var editor_sell_popup_menu: PopupMenu
var editor_sell_target_node: TechTreeNode
var editor_center_offset_controls: VBoxContainer
var editor_center_offset_label: Label
var editor_center_offset_x_minus_button: Button
var editor_center_offset_x_plus_button: Button
var editor_center_offset_y_minus_button: Button
var editor_center_offset_y_plus_button: Button
var editor_center_offset_x_minus_small_button: Button
var editor_center_offset_x_plus_small_button: Button
var editor_center_offset_y_minus_small_button: Button
var editor_center_offset_y_plus_small_button: Button
var editor_center_offset_rebuild_button: Button
var editor_center_offset: Vector2 = Vector2(-960.0, -600.0)
var editor_crt_preview_enabled: bool = false
var battle_level_choice_dialog: ConfirmationDialog
var battle_level_choice_selected_level: int = 1
var battle_level_choice_line_edit: LineEdit
var battle_level_choice_max_level: int = 1
var reel_depth_tier_dialog: ConfirmationDialog
var reel_depth_tier_cache: Array = []
var _locale_tree_refresh_queued: bool = false
var _loaded_tree_locale: String = ""

func _trf(key: String, args: Array = []) -> String:
    var translated: String = tr(key)
    var used_brace_placeholders: bool = false
    for index in range(args.size()):
        var placeholder := "{%d}" % index
        if translated.contains(placeholder):
            used_brace_placeholders = true
            translated = translated.replace(placeholder, str(args[index]))
    if used_brace_placeholders or args.is_empty():
        return translated
    return translated % args
var reset_progress_confirm_dialog: ConfirmationDialog
var legacy_reset_dialog: ConfirmationDialog
var settings_button: Button
var return_to_main_menu_button: Button
var fullscreen_button: Button
var settings_panel: PanelContainer
var settings_content: Settings
var settings_title_label: Label
var settings_main_menu_button: Button
var settings_quit_button: Button
var settings_close_button: Button
var reset_progress_button: Button
var go_again_button: Button
var demo_mode_label: Label
var game_mode_label: Label
var mining_time_label: Label
var wishlist_button: Button
var web_wishlist_button: Button
var leaderboard_button: Button
var leaderboard_panel: PanelContainer
var leaderboard_title_label: Label
var leaderboard_body_label: Label
var leaderboard_submit_30m_button: Button
var leaderboard_submit_1h_button: Button
var leaderboard_submit_2h_level20_button: Button
var leaderboard_submit_3h_level20_button: Button
var leaderboard_panel_open := false
var open_pit_chat_button: Button
var open_pit_chat_panel: PanelContainer
var open_pit_chat_label: RichTextLabel
var popup_layer: CanvasLayer
var continue_locked_panel: PanelContainer
var continue_locked_label: Label
var version_label: Label
var fullscreen_icon_on: Texture2D
var fullscreen_icon_off: Texture2D
var _legacy_reset_dialog_shown := false
var _popup_prev_a_pressed := false
var _popup_prev_b_pressed := false
var _popup_prev_x_pressed := false
var _popup_prev_up_pressed := false
var _popup_prev_down_pressed := false
var _popup_x_confirm_armed := true

func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        _refresh_localized_text()
        _queue_upgrade_tree_locale_refresh()

func _refresh_localized_text() -> void:
    if settings_button != null and is_instance_valid(settings_button):
        settings_button.text = tr("UI_SETTINGS")
    if return_to_main_menu_button != null and is_instance_valid(return_to_main_menu_button):
        return_to_main_menu_button.text = tr("MAIN MENU")
    if settings_title_label != null and is_instance_valid(settings_title_label):
        settings_title_label.text = tr("UI_SETTINGS_TITLE")
    if settings_main_menu_button != null and is_instance_valid(settings_main_menu_button):
        settings_main_menu_button.text = tr("MAIN MENU")
    if settings_quit_button != null and is_instance_valid(settings_quit_button):
        settings_quit_button.text = tr("QUIT")
    if settings_close_button != null and is_instance_valid(settings_close_button):
        settings_close_button.text = tr("UI_BACK")
    if reset_progress_button != null and is_instance_valid(reset_progress_button):
        reset_progress_button.text = tr("UPGRADE_RESET_PROGRESS")
    _refresh_wishlist_button_text()
    if reset_progress_confirm_dialog != null and is_instance_valid(reset_progress_confirm_dialog):
        reset_progress_confirm_dialog.title = tr("UPGRADE_CONFIRM_RESET_TITLE")
        reset_progress_confirm_dialog.dialog_text = tr("UPGRADE_CONFIRM_RESET_BODY")
        var reset_ok_button: Button = reset_progress_confirm_dialog.get_ok_button()
        if reset_ok_button != null:
            reset_ok_button.text = tr("UI_YES")
        var reset_cancel_button: Button = reset_progress_confirm_dialog.get_cancel_button()
        if reset_cancel_button != null:
            reset_cancel_button.text = tr("UI_NO")
    if legacy_reset_dialog != null and is_instance_valid(legacy_reset_dialog):
        legacy_reset_dialog.title = tr("UPGRADE_PROGRESS_RESET_REQUIRED")
        legacy_reset_dialog.dialog_text = tr("UPGRADE_LEGACY_RESET_BODY")
        var legacy_ok_button: Button = legacy_reset_dialog.get_ok_button()
        if legacy_ok_button != null:
            legacy_ok_button.text = tr("UI_CONTINUE")
    _refresh_editor_mode_jump_buttons()
    if leaderboard_title_label != null and is_instance_valid(leaderboard_title_label):
        leaderboard_title_label.text = _get_leaderboard_panel_title()
    _refresh_leaderboard_panel()
    _refresh_open_pit_chat_panel()
    _refresh_demo_mode_label_visibility()
    _refresh_mining_time_label()
    _refresh_editor_demo_toggle_button_text()
    _refresh_editor_regenerate_planet_button()
    _update_go_again_button_state()
    if battle_level_choice_dialog != null and is_instance_valid(battle_level_choice_dialog) and battle_level_choice_dialog.visible:
        _show_battle_level_choice_dialog(battle_level_choice_max_level)
    if _is_reel_depth_tier_dialog_open():
        _rebuild_reel_depth_tier_dialog_content()

func _queue_upgrade_tree_locale_refresh() -> void:
    if _locale_tree_refresh_queued:
        return
    _locale_tree_refresh_queued = true
    call_deferred("_refresh_upgrade_tree_for_locale_change")

func _refresh_upgrade_tree_for_locale_change() -> void:
    _locale_tree_refresh_queued = false
    if tech_tree == null or not is_instance_valid(tech_tree):
        return
    if not tree_initialized:
        return
    var active_locale: String = TranslationServer.get_locale()
    if _loaded_tree_locale == active_locale:
        return

    _ensure_tree_initialized(true)
    if not tech_tree.build_in_progress:
        tech_tree.update_active()
        _update_go_again_button_state()
    _loaded_tree_locale = active_locale

func _can_use_leaderboard_ui() -> bool:
    if OS.has_feature("web"):
        return false
    return OS.has_feature("editor") or OS.has_feature("windows") or OS.has_feature("linux") or OS.has_feature("macos")

func _should_offer_leaderboards() -> bool:
    if not _can_use_leaderboard_ui():
        return false
    if Util.is_open_pit_game_active():
        var data: Dictionary = OPEN_PIT_PROGRESS_SCRIPT.load_data()
        return not Array(data.get("attempt_history", [])).is_empty()
    return true

func _should_show_leaderboards() -> bool:
    return _should_offer_leaderboards() and leaderboard_panel_open

func _should_show_deepcore_demo_leaderboard() -> bool:
    return Util.is_mining_game_active() and bool(ProjectSettings.get_setting(DEMO_PROJECT_SETTING, false))

func _get_leaderboard_panel_title() -> String:
    if Util.is_open_pit_game_active():
        return "Data Breach Leaderboards"
    if _should_show_deepcore_demo_leaderboard():
        return tr("DEEPCORE_DEMO_LEADERBOARD_TITLE")
    return tr("MINING_LEADERBOARDS_TITLE")

var dragging = false
var scroll_speed = 500

var zoom

@onready var tech_tree: TechTree = %"Tech Tree"
var tree_initialized: bool = false
var prefers_simulation_tree: bool = false
var _open_pit_startup_ready_started_msec: int = 0
var _open_pit_startup_tree_started_msec: int = 0
var _wishlist_button_setup_queued: bool = false


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
    _open_pit_startup_ready_started_msec = Time.get_ticks_msec()
    var ready_step_started_msec := _open_pit_startup_ready_started_msec
    _print_open_pit_startup("ready_begin")
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    SignalBus.global_resource_changed.connect(_on_global_resource_changed)
    SignalBus.settings_updated.connect(_on_settings_updated)

    ControllerIcons.input_type_changed.connect(_on_input_type_changed)
    _bind_tech_tree(tech_tree)
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    ready_step_started_msec = _print_open_pit_ready_step("ready_signals", ready_step_started_msec)




    %CanvasLayer.hide()
    %CanvasLayer2.hide()

    set_process_input(false)
    set_process(false)
    ready_step_started_msec = _print_open_pit_ready_step("ready_initial_visibility", ready_step_started_msec)

    update_colors()
    ready_step_started_msec = _print_open_pit_ready_step("ready_update_colors", ready_step_started_msec)
    _setup_editor_cash_controls()
    ready_step_started_msec = _print_open_pit_ready_step("ready_editor_cash_controls", ready_step_started_msec)
    _setup_editor_mode_jump_controls()
    ready_step_started_msec = _print_open_pit_ready_step("ready_editor_mode_jump_controls", ready_step_started_msec)
    _setup_editor_center_offset_controls()
    ready_step_started_msec = _print_open_pit_ready_step("ready_editor_center_offset_controls", ready_step_started_msec)
    _setup_editor_sell_popup_menu()
    ready_step_started_msec = _print_open_pit_ready_step("ready_editor_sell_popup_menu", ready_step_started_msec)
    _setup_battle_level_choice_dialog()
    ready_step_started_msec = _print_open_pit_ready_step("ready_battle_level_choice_dialog", ready_step_started_msec)
    _setup_reel_depth_tier_dialog()
    ready_step_started_msec = _print_open_pit_ready_step("ready_reel_depth_tier_dialog", ready_step_started_msec)
    _setup_reset_progress_controls()
    ready_step_started_msec = _print_open_pit_ready_step("ready_reset_progress_controls", ready_step_started_msec)
    _setup_version_label()
    ready_step_started_msec = _print_open_pit_ready_step("ready_version_label", ready_step_started_msec)
    _setup_settings_controls()
    ready_step_started_msec = _print_open_pit_ready_step("ready_settings_controls", ready_step_started_msec)
    _setup_return_to_main_menu_button()
    ready_step_started_msec = _print_open_pit_ready_step("ready_return_to_main_menu_button", ready_step_started_msec)
    _setup_fullscreen_button()
    ready_step_started_msec = _print_open_pit_ready_step("ready_fullscreen_button", ready_step_started_msec)
    go_again_button = get_node_or_null("%Go Again")
    demo_mode_label = get_node_or_null("%Demo Mode Label")
    game_mode_label = get_node_or_null("%Game Mode Label")
    _setup_editor_exit_demo_button()
    _setup_mining_time_label()
    ready_step_started_msec = _print_open_pit_ready_step("ready_mining_time_label", ready_step_started_msec)
    _setup_open_pit_chat_controls()
    ready_step_started_msec = _print_open_pit_ready_step("ready_open_pit_chat_controls", ready_step_started_msec)
    wishlist_button = get_node_or_null("%Wishlist")
    popup_layer = get_node_or_null("%Popup Layer")
    _bind_popup_layer_visibility_updates()
    ready_step_started_msec = _print_open_pit_ready_step("ready_popup_layer_bindings", ready_step_started_msec)
    _queue_wishlist_button_setup()
    ready_step_started_msec = _print_open_pit_ready_step("ready_wishlist_button", ready_step_started_msec)
    _setup_leaderboard_panel()
    ready_step_started_msec = _print_open_pit_ready_step("ready_leaderboard_panel", ready_step_started_msec)
    _setup_continue_locked_dialog()
    ready_step_started_msec = _print_open_pit_ready_step("ready_continue_locked_dialog", ready_step_started_msec)
    _update_go_again_button_state()
    ready_step_started_msec = _print_open_pit_ready_step("ready_go_again_state", ready_step_started_msec)
    _refresh_mining_crt_overlay()
    ready_step_started_msec = _print_open_pit_ready_step("ready_mining_crt_overlay", ready_step_started_msec)
    hide()
    if _is_standalone_mode_upgrade_scene() and get_tree().current_scene == self:
        setup()
        show_screen()
    _print_open_pit_startup("ready_end", Time.get_ticks_msec() - _open_pit_startup_ready_started_msec)

func _on_tech_tree_build_completed() -> void:
    if _should_profile_open_pit_upgrade_startup():
        var tree_elapsed_msec: int = Time.get_ticks_msec() - _open_pit_startup_tree_started_msec if _open_pit_startup_tree_started_msec > 0 else 0
        var total_elapsed_msec: int = Time.get_ticks_msec() - Global.open_pit_upgrade_startup_started_msec if Global.open_pit_upgrade_startup_started_msec > 0 else 0
        var node_count: int = tech_tree.node_dict.size() if tech_tree != null else 0
        var line_count: int = 0
        if tech_tree != null and is_instance_valid(tech_tree):
            var lines_container: Node = tech_tree.get_node_or_null("Pivot/Tech Lines")
            if lines_container != null:
                line_count = lines_container.get_child_count()
        print("[OpenPitUpgradeStartup] tree_build_completed %.3fms total_open_to_tree_ready %.3fms nodes=%d lines=%d" % [
            float(tree_elapsed_msec),
            float(total_elapsed_msec),
            node_count,
            line_count
        ])
    if _should_recenter_upgrade_tree_on_core():
        _recenter_tech_tree_on_core()
    elif OS.has_feature("editor"):
        _apply_editor_center_offset()
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
    if Global.cached_upgrade_tree_locale != "" and Global.cached_upgrade_tree_locale != SaveHandler.locale:
        Global.clear_upgrade_tree_cache()
        return

    var cached_tree: TechTree = Global.cached_upgrade_tech_tree
    Global.cached_upgrade_tech_tree = null
    Global.cached_upgrade_tree_locale = ""

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
    _loaded_tree_locale = SaveHandler.locale

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
    Global.cached_upgrade_tree_locale = SaveHandler.locale

func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    if is_active == true:
        update_input(input_type)

func _is_editor_return_to_launcher_shortcut(event: InputEvent) -> bool:
    if not OS.has_feature("editor"):
        return false
    if not (event is InputEventKey):
        return false
    var key_event := event as InputEventKey
    if not key_event.pressed or key_event.echo:
        return false
    var is_o_key := key_event.keycode == KEY_O or key_event.physical_keycode == KEY_O
    var is_p_key := key_event.keycode == KEY_P or key_event.physical_keycode == KEY_P
    if not is_o_key and not is_p_key:
        return false
    var o_pressed := Input.is_key_pressed(KEY_O) or Input.is_physical_key_pressed(KEY_O)
    var p_pressed := Input.is_key_pressed(KEY_P) or Input.is_physical_key_pressed(KEY_P)
    return o_pressed and p_pressed

func _return_to_game_launcher() -> void:
    _refresh_virtual_cursor_state()
    Global.clear_upgrade_tree_cache()
    SceneChanger.change_to_new_scene(Util.PATH_GAME_LAUNCHER, null, 0.2)

func _input(event: InputEvent) -> void :
    if Global.game_state == Util.GAME_STATES.UPGRADES:
        if _is_editor_return_to_launcher_shortcut(event):
            _return_to_game_launcher()
            get_viewport().set_input_as_handled()
            return
        if _should_dump_open_pit_upgrades(event):
            _print_open_pit_upgrade_dump()
            get_viewport().set_input_as_handled()
            return
        if event is InputEventMouseButton and event.pressed and not event.is_echo():
            if not _is_any_popup_visible() and state == STATES.SHOWING_TREE and tech_tree != null and is_instance_valid(tech_tree):
                var mouse_event := event as InputEventMouseButton
                if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
                    tech_tree.zoom_by(0.18, mouse_event.position)
                    get_viewport().set_input_as_handled()
                    return
                if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                    tech_tree.zoom_by(-0.18, mouse_event.position)
                    get_viewport().set_input_as_handled()
                    return
        if _is_settings_open():
            if event.is_action_pressed("escape") or event.is_action_pressed("back"):
                _hide_settings_panel()
                get_viewport().set_input_as_handled()
            return
        if event.is_action_pressed("escape") or event.is_action_pressed("back"):
            _on_settings_button_pressed()
            get_viewport().set_input_as_handled()
            return
        if _is_reel_depth_tier_dialog_open():
            return
        if _is_battle_level_choice_open():
            if event.is_action_pressed("ui_accept") or event.is_action_pressed("go again"):
                if _confirm_battle_level_choice_from_controller():
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
            return
        if _is_continue_locked_open():
            if event.is_action_pressed("ui_accept"):
                _hide_continue_locked_panel()
            return
        if event.is_action_pressed("go again"):
            _on_go_again_pressed()

func _should_dump_open_pit_upgrades(event: InputEvent) -> bool:
    if not Util.is_open_pit_game_active():
        return false
    if not (event is InputEventKey):
        return false
    if _is_any_popup_visible() or _is_settings_open() or _is_reel_depth_tier_dialog_open() or _is_battle_level_choice_open():
        return false
    var key_event := event as InputEventKey
    if not key_event.pressed or key_event.echo:
        return false
    return key_event.keycode == KEY_U or key_event.physical_keycode == KEY_U

func _print_open_pit_upgrade_dump() -> void:
    var data: Dictionary = OPEN_PIT_PROGRESS_SCRIPT.load_data()
    var visible_caps: Dictionary = _collect_open_pit_tree_caps()
    var main_levels: Dictionary = data.get("upgrades", {}).duplicate(true)
    var xp_levels: Dictionary = data.get("xp_upgrades", {}).duplicate(true)
    var core_owned: Array = data.get("purchased_core_upgrades", []).duplicate()
    core_owned.sort()

    print("=== Open Pit Empire Upgrade Dump ===")
    print("Wallets: money=%d xp=%d core=%d depth=%d/%d" % [
        int(data.get("wallet", 0)),
        int(data.get("xp_currency", 0)),
        int(data.get("core_currency", 0)),
        int(data.get("selected_depth_level", 1)),
        int(data.get("deepest_level_unlocked", 1)),
    ])
    _print_open_pit_upgrade_dump_section("Main", main_levels, visible_caps)
    _print_open_pit_upgrade_dump_section("XP", xp_levels, visible_caps)
    _print_open_pit_core_upgrade_dump_section(core_owned, visible_caps)
    print("=== End Open Pit Empire Upgrade Dump ===")

func _collect_open_pit_tree_caps() -> Dictionary:
    var caps: Dictionary = {}
    for upgrade_variant: Variant in Global.game_mode_data_manager.upgrades.values():
        if not (upgrade_variant is Upgrade):
            continue
        var upgrade: Upgrade = upgrade_variant
        if upgrade.sim_key == "":
            continue
        var max_level: int = int(upgrade.sim_level) + int(upgrade.max_tier) - 1
        var prev_level: int = int(caps.get(upgrade.sim_key, 0))
        if max_level > prev_level:
            caps[upgrade.sim_key] = max_level
    return caps

func _print_open_pit_upgrade_dump_section(section_name: String, levels: Dictionary, visible_caps: Dictionary) -> void:
    var keys: Array = levels.keys()
    keys.sort()
    print("%s Upgrades (%d owned)" % [section_name, keys.size()])
    if keys.is_empty():
        print("  (none)")
        return
    for key_variant: Variant in keys:
        var key: String = str(key_variant)
        print("  %s = %d / tree max %d" % [
            key,
            int(levels.get(key, 0)),
            int(visible_caps.get(key, 0)),
        ])

func _print_open_pit_core_upgrade_dump_section(core_owned: Array, visible_caps: Dictionary) -> void:
    print("Core Upgrades (%d owned)" % core_owned.size())
    if core_owned.is_empty():
        print("  (none)")
        return
    for key_variant: Variant in core_owned:
        var key: String = "core:%s" % str(key_variant)
        print("  %s = owned / tree max %d" % [key, int(visible_caps.get(key, 0))])











func setup():
    var setup_started_msec := Time.get_ticks_msec()
    _print_open_pit_startup("setup_begin")
    prefers_simulation_tree = Global.start_in_upgrade_scene
    if Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active():
        var cache_clear_started_msec := Time.get_ticks_msec()
        Global.clear_upgrade_tree_cache()
        _print_open_pit_startup("clear_tree_cache", Time.get_ticks_msec() - cache_clear_started_msec)
    var restore_started_msec := Time.get_ticks_msec()
    _restore_cached_tech_tree_if_available()
    _print_open_pit_startup("restore_cached_tree", Time.get_ticks_msec() - restore_started_msec)
    if prefers_simulation_tree:
        _print_open_pit_startup("setup_end_deferred_tree", Time.get_ticks_msec() - setup_started_msec)
        return
    _ensure_tree_initialized()
    _print_open_pit_startup("setup_end", Time.get_ticks_msec() - setup_started_msec)


func _on_global_resource_changed(event_data: GlobalResourceChangedEventData):
    if event_data.type == Util.RESOURCE_TYPES.MONEY:
        update()

func update():
    if tech_tree == null or not is_instance_valid(tech_tree):
        return
    _refresh_bottom_wallet_display()
    _refresh_editor_mode_jump_buttons()
    tech_tree.update_active()

func _refresh_bottom_wallet_display() -> void:
    var money_ui := get_node_or_null("%Moeny UI")
    if money_ui != null and money_ui.has_method("refresh_amounts"):
        money_ui.call("refresh_amounts")


func _on_pallet_updated():
    update_colors()

func _on_settings_updated() -> void:
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
    if Util.is_mining_game_active():
        %"Click Mask".color = Color(0.13, 0.1, 0.08, 1.0)
        %"GPUParticles2D Light".modulate = Color(0.72, 0.55, 0.22, 0.65)
        %"GPUParticles2D2 Dark".modulate = Color(0.28, 0.18, 0.1, 0.55)
    elif Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active():
        %"Click Mask".color = Color(0.03, 0.06, 0.1, 1.0)
        %"GPUParticles2D Light".modulate = Color(0.4, 0.82, 1.0, 0.58)
        %"GPUParticles2D2 Dark".modulate = Color(0.08, 0.18, 0.3, 0.56)
    elif Util.is_red_sky_game_active():
        %"Click Mask".color = Color(0.19, 0.095, 0.085, 1.0)
        %"GPUParticles2D Light".modulate = Color(0.81, 0.39, 0.24, 0.64)
        %"GPUParticles2D2 Dark".modulate = Color(0.36, 0.135, 0.095, 0.6)
    elif Util.is_turkey_game_active():
        %"Click Mask".color = Color(0.04, 0.04, 0.045, 1.0)
        %"GPUParticles2D Light".modulate = Color(0.62, 0.52, 0.28, 0.48)
        %"GPUParticles2D2 Dark".modulate = Color(0.12, 0.12, 0.13, 0.56)
    elif Util.is_reel_into_darkness_game_active():
        %"Click Mask".color = Color(0.05, 0.11, 0.16, 1.0)
        %"GPUParticles2D Light".modulate = Color(0.37, 0.7, 0.84, 0.62)
        %"GPUParticles2D2 Dark".modulate = Color(0.02, 0.07, 0.12, 0.58)


func _process(delta: float) -> void :
    _poll_battle_level_choice_controller(delta)
    _refresh_mining_time_label()
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
    if _is_reel_depth_tier_dialog_open():
        _poll_reel_depth_tier_controller(delta)
        return
    if not _is_battle_level_choice_open():
        _popup_prev_a_pressed = false
        _popup_prev_b_pressed = false
        _popup_prev_x_pressed = false
        _popup_prev_up_pressed = false
        _popup_prev_down_pressed = false
        _popup_x_confirm_armed = true
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
    elif x_pressed and not _popup_prev_x_pressed:
        if _popup_x_confirm_armed:
            _confirm_battle_level_choice_from_controller()
    elif b_pressed and not _popup_prev_b_pressed:
        _on_battle_level_choice_cancel_pressed()
    elif up_pressed and not _popup_prev_up_pressed:
        _on_battle_level_choice_adjust_pressed(1, battle_level_choice_max_level)
    elif down_pressed and not _popup_prev_down_pressed:
        _on_battle_level_choice_adjust_pressed(-1, battle_level_choice_max_level)

    if not x_pressed:
        _popup_x_confirm_armed = true

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



var nodes_unlocked_this_session = 0


func on_node_unlocked(node: TechTreeNode):
    _refresh_bottom_wallet_display()
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
        _refresh_virtual_cursor_state()
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
    var show_started_msec := Time.get_ticks_msec()
    _print_open_pit_startup("show_screen_begin")
    _ensure_tree_initialized()
    if _should_recenter_upgrade_tree_on_core():
        _recenter_tech_tree_on_core()
    elif OS.has_feature("editor"):
        _apply_editor_center_offset()
    _sync_simulation_currency_from_save()
    _refresh_bottom_wallet_display()
    is_active = true
    Global.game_state = Util.GAME_STATES.UPGRADES

    %CanvasLayer.show()
    %CanvasLayer2.show()
    _hide_settings_panel()
    VirtualCursor.use_open_pit_orbit_cursor(false)
    _refresh_virtual_cursor_state()



    update_input(ControllerIcons.get_last_input_type())
    _queue_wishlist_button_setup()
    _refresh_leaderboard_panel()
    _refresh_fullscreen_button_icon()
    _update_return_to_main_menu_button_visibility()
    _update_go_again_button_state()
    _refresh_mining_crt_overlay()

    nodes_unlocked_this_session = 0

    if Global.main != null and Global.main.camera_2d != null:
        Global.main.camera_2d.target_zoom = Global.main.camera_2d.target_zoom
    set_process_input(true)
    set_process(true)
    show()
    _show_legacy_reset_dialog_if_needed()
    _print_open_pit_startup("show_screen_end", Time.get_ticks_msec() - show_started_msec)


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
    VirtualCursor.use_open_pit_orbit_cursor(false)
    VirtualCursor.set_scene_enabled(false)

func _refresh_mining_crt_overlay() -> void:
    var overlay: CanvasLayer = get_node_or_null("EditorCrtOverlay") as CanvasLayer
    var text_mirror_overlay: CanvasLayer = get_node_or_null("EditorCrtTextMirrorOverlay") as CanvasLayer
    var should_show_overlay: bool = _should_show_editor_crt_preview()
    if should_show_overlay:
        if overlay == null:
            overlay = MINING_CRT_OVERLAY_SCRIPT.new().configure(5)
            overlay.name = "EditorCrtOverlay"
            add_child(overlay)
        if text_mirror_overlay == null:
            text_mirror_overlay = CRT_TEXT_MIRROR_OVERLAY_SCRIPT.new().configure(self, 6)
            text_mirror_overlay.name = "EditorCrtTextMirrorOverlay"
            add_child(text_mirror_overlay)
        overlay.visible = true
        text_mirror_overlay.visible = true
    else:
        if overlay != null:
            overlay.visible = false
        if text_mirror_overlay != null:
            text_mirror_overlay.visible = false

func _should_show_editor_crt_preview() -> bool:
    return OS.has_feature("editor") and Util.is_vanguard_game_active() and editor_crt_preview_enabled


func _on_go_again_pressed() -> void :
    if Util.is_mining_game_active():
        var mining_data: Dictionary = MINING_PROGRESS_SCRIPT.load_data()
        var min_depth: int = MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
        var max_depth: int = clampi(int(mining_data.get("deepest_level_unlocked", min_depth)), min_depth, MINING_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL)
        if MINING_PROGRESS_SCRIPT.get_display_depth_tier(max_depth) <= 1:
            _launch_battle_at_level(min_depth)
        else:
            _show_battle_level_choice_dialog(max_depth)
        return
    if Util.is_open_pit_game_active():
        var open_pit_min_depth: int = OPEN_PIT_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
        _launch_battle_at_level(open_pit_min_depth)
        return
    if Util.is_open_pit_orbit_game_active():
        var orbit_data: Dictionary = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.load_data()
        var orbit_min_depth: int = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
        var orbit_selected_depth: int = clampi(int(orbit_data.get("selected_depth_level", orbit_min_depth)), orbit_min_depth, int(orbit_data.get("deepest_level_unlocked", orbit_min_depth)))
        _launch_battle_at_level(orbit_selected_depth)
        return
    if Util.is_red_sky_game_active():
        _refresh_virtual_cursor_state()
        _cache_tech_tree_for_reuse()
        SceneChanger.change_to_new_scene(Util.get_main_scene_path())
        return
    if Util.is_turkey_game_active():
        _refresh_virtual_cursor_state()
        _cache_tech_tree_for_reuse()
        SceneChanger.change_to_new_scene(Util.get_main_scene_path())
        return
    if Util.is_reel_into_darkness_game_active():
        var reel_tiers: Array = REEL_INTO_DARKNESS_DATA_SCRIPT.get_reel_depth_tier_options(REEL_INTO_DARKNESS_PROGRESS_SCRIPT.get_upgrade_levels())
        if reel_tiers.size() <= 1:
            Global.reel_run_max_depth_cap = -1.0
            _launch_reel_fishing_scene()
        else:
            reel_depth_tier_cache = reel_tiers
            _show_reel_depth_tier_dialog()
        return
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

    var ensure_started_msec := Time.get_ticks_msec()
    _print_open_pit_startup("ensure_tree_begin force=%s initialized=%s" % [str(force_rebuild), str(tree_initialized)])
    if force_rebuild and tree_initialized:
        var clear_started_msec := Time.get_ticks_msec()
        _clear_tech_tree_runtime()
        tree_initialized = false
        _print_open_pit_startup("clear_tree_runtime", Time.get_ticks_msec() - clear_started_msec)

    if tree_initialized:
        _print_open_pit_startup("ensure_tree_end_already_initialized", Time.get_ticks_msec() - ensure_started_msec)
        return

    if _is_simulation_upgrade_tree_requested() or _is_simulation_upgrade_tree():
        var adapter_started_msec := Time.get_ticks_msec()
        if Util.is_mining_game_active():
            MINING_UPGRADE_TREE_ADAPTER_SCRIPT.apply_simulation_upgrades()
        elif Util.is_open_pit_game_active():
            OPEN_PIT_UPGRADE_TREE_ADAPTER_SCRIPT.apply_simulation_upgrades()
        elif Util.is_open_pit_orbit_game_active():
            OPEN_PIT_ORBIT_UPGRADE_TREE_ADAPTER_SCRIPT.apply_simulation_upgrades()
        elif Util.is_red_sky_game_active():
            RED_SKY_UPGRADE_TREE_ADAPTER_SCRIPT.apply_simulation_upgrades()
        elif Util.is_turkey_game_active():
            TURKEY_UPGRADE_TREE_ADAPTER_SCRIPT.apply_simulation_upgrades()
        elif Util.is_reel_into_darkness_game_active():
            REEL_INTO_DARKNESS_UPGRADE_TREE_ADAPTER_SCRIPT.apply_simulation_upgrades()
        else:
            FishingUpgradeTreeAdapter.apply_simulation_upgrades()
        _print_open_pit_startup("apply_simulation_upgrades", Time.get_ticks_msec() - adapter_started_msec)
        var currency_started_msec := Time.get_ticks_msec()
        _sync_simulation_currency_from_save()
        _print_open_pit_startup("sync_currency", Time.get_ticks_msec() - currency_started_msec)

    _open_pit_startup_tree_started_msec = Time.get_ticks_msec()
    var setup_started_msec := Time.get_ticks_msec()
    tech_tree.setup()
    _print_open_pit_startup("tech_tree_setup_returned build_in_progress=%s" % str(tech_tree.build_in_progress), Time.get_ticks_msec() - setup_started_msec)
    tree_initialized = true
    _loaded_tree_locale = TranslationServer.get_locale()
    _print_open_pit_startup("ensure_tree_end", Time.get_ticks_msec() - ensure_started_msec)

func _should_profile_open_pit_upgrade_startup() -> bool:
    return Util.is_open_pit_game_active()

func _print_open_pit_startup(label: String, elapsed_msec: int = -1) -> void:
    if not _should_profile_open_pit_upgrade_startup():
        return
    var since_scene_request_msec: int = Time.get_ticks_msec() - Global.open_pit_upgrade_startup_started_msec if Global.open_pit_upgrade_startup_started_msec > 0 else 0
    if elapsed_msec >= 0:
        print("[OpenPitUpgradeStartup] %s %.3fms since_request=%.3fms" % [label, float(elapsed_msec), float(since_scene_request_msec)])
    else:
        print("[OpenPitUpgradeStartup] %s since_request=%.3fms" % [label, float(since_scene_request_msec)])

func _print_open_pit_ready_step(label: String, step_started_msec: int) -> int:
    if not _should_profile_open_pit_upgrade_startup():
        return Time.get_ticks_msec()
    var now_msec := Time.get_ticks_msec()
    var elapsed_msec := now_msec - step_started_msec
    if elapsed_msec >= 8:
        _print_open_pit_startup(label, elapsed_msec)
    return now_msec

func _sync_simulation_currency_from_save() -> void:
    if not (_is_simulation_upgrade_tree_requested() or _is_simulation_upgrade_tree()):
        return
    if Global.global_resoruce_manager == null:
        return
    var current_money: int = int(Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY))
    var target_money: int = _get_upgrade_wallet_amount()
    if current_money != target_money:
        Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, target_money - current_money)

func _get_upgrade_wallet_amount() -> int:
    if Util.is_mining_game_active():
        return MINING_PROGRESS_SCRIPT.get_wallet()
    if Util.is_open_pit_game_active():
        return OPEN_PIT_PROGRESS_SCRIPT.get_wallet()
    if Util.is_open_pit_orbit_game_active():
        return OPEN_PIT_ORBIT_PROGRESS_SCRIPT.get_wallet()
    if Util.is_red_sky_game_active():
        return RED_SKY_PROGRESS_SCRIPT.get_wallet()
    if Util.is_turkey_game_active():
        return TURKEY_PROGRESS_SCRIPT.get_wallet()
    if Util.is_reel_into_darkness_game_active():
        return REEL_INTO_DARKNESS_PROGRESS_SCRIPT.get_wallet()
    return int(SaveHandler.fishing_currency)

func _is_demo_mode_enabled() -> bool:
    return bool(ProjectSettings.get_setting(DEMO_PROJECT_SETTING, false))

func _bind_demo_label_visibility_to_popup(control: Node) -> void:
    if control == null or not is_instance_valid(control):
        return
    if not control.visibility_changed.is_connected(_refresh_demo_mode_label_visibility):
        control.visibility_changed.connect(_refresh_demo_mode_label_visibility)

func _bind_popup_layer_visibility_updates() -> void:
    if popup_layer == null or not is_instance_valid(popup_layer):
        return
    if not popup_layer.child_entered_tree.is_connected(_on_popup_layer_child_entered_tree):
        popup_layer.child_entered_tree.connect(_on_popup_layer_child_entered_tree)
    if not popup_layer.child_exiting_tree.is_connected(_on_popup_layer_child_exiting_tree):
        popup_layer.child_exiting_tree.connect(_on_popup_layer_child_exiting_tree)
    for child in popup_layer.get_children():
        if child is CanvasItem:
            _bind_demo_label_visibility_to_popup(child as CanvasItem)

func _on_popup_layer_child_entered_tree(node: Node) -> void:
    if node is CanvasItem:
        _bind_demo_label_visibility_to_popup(node as CanvasItem)
    _refresh_demo_mode_label_visibility()

func _on_popup_layer_child_exiting_tree(_node: Node) -> void:
    _refresh_demo_mode_label_visibility()

func _is_any_popup_visible() -> bool:
    if _is_reel_depth_tier_dialog_open():
        return true
    if battle_level_choice_dialog != null and is_instance_valid(battle_level_choice_dialog) and battle_level_choice_dialog.visible:
        return true
    if reset_progress_confirm_dialog != null and is_instance_valid(reset_progress_confirm_dialog) and reset_progress_confirm_dialog.visible:
        return true
    if legacy_reset_dialog != null and is_instance_valid(legacy_reset_dialog) and legacy_reset_dialog.visible:
        return true
    if settings_panel != null and is_instance_valid(settings_panel) and settings_panel.visible:
        return true
    if continue_locked_panel != null and is_instance_valid(continue_locked_panel) and continue_locked_panel.visible:
        return true
    if open_pit_chat_panel != null and is_instance_valid(open_pit_chat_panel) and open_pit_chat_panel.visible:
        return true
    if leaderboard_panel != null and is_instance_valid(leaderboard_panel) and leaderboard_panel.visible:
        return true
    if popup_layer != null and is_instance_valid(popup_layer):
        for child in popup_layer.get_children():
            if child is CanvasItem and (child as CanvasItem).visible:
                return true
    return false

func _refresh_demo_mode_label_visibility() -> void:
    if demo_mode_label != null and is_instance_valid(demo_mode_label):
        demo_mode_label.visible = _is_demo_mode_enabled() and not _is_any_popup_visible()
    if game_mode_label != null and is_instance_valid(game_mode_label):
        game_mode_label.visible = not _is_any_popup_visible() and (Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active() or Util.is_red_sky_game_active() or Util.is_turkey_game_active() or Util.is_reel_into_darkness_game_active())
        if Util.is_mining_game_active():
            game_mode_label.text = ""
        elif Util.is_open_pit_game_active():
            game_mode_label.text = tr("OPEN PIT EMPIRE")
            game_mode_label.add_theme_color_override("font_color", Color(0.95, 0.76, 0.38, 1.0))
        elif Util.is_open_pit_orbit_game_active():
            game_mode_label.text = tr("OPEN_PIT_ORBIT")
            game_mode_label.add_theme_color_override("font_color", Color(0.54, 0.86, 1.0, 1.0))
        elif Util.is_red_sky_game_active():
            game_mode_label.text = tr("RED SKY MODE")
            game_mode_label.add_theme_color_override("font_color", Color(0.98, 0.62, 0.42, 1.0))
        elif Util.is_turkey_game_active():
            game_mode_label.text = tr("TURKEY MODE")
            game_mode_label.add_theme_color_override("font_color", Color(0.96, 0.84, 0.45, 1.0))
        elif Util.is_reel_into_darkness_game_active():
            game_mode_label.text = tr("REEL INTO DARKNESS")
            game_mode_label.add_theme_color_override("font_color", Color(0.56, 0.84, 0.94, 1.0))
        else:
            game_mode_label.text = ""
    _refresh_editor_exit_demo_button()
    _refresh_mining_time_label()

func _setup_mining_time_label() -> void:
    if mining_time_label != null and is_instance_valid(mining_time_label):
        return
    var parent_layer: CanvasLayer = %CanvasLayer2
    if parent_layer == null:
        return
    mining_time_label = Label.new()
    mining_time_label.name = "MiningTimeLabel"
    mining_time_label.anchor_left = 0.5
    mining_time_label.anchor_right = 0.5
    mining_time_label.offset_left = -250.0
    mining_time_label.offset_top = 114.0
    mining_time_label.offset_right = 250.0
    mining_time_label.offset_bottom = 155.0
    mining_time_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
    mining_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mining_time_label.add_theme_color_override("font_color", Color(0.76, 0.93, 0.86, 1.0))
    mining_time_label.add_theme_font_size_override("font_size", 28)
    mining_time_label.visible = false
    parent_layer.add_child(mining_time_label)

func _refresh_mining_time_label() -> void:
    if mining_time_label == null or not is_instance_valid(mining_time_label):
        return
    var show_label: bool = (Util.is_mining_game_active() or Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active()) and not _is_any_popup_visible()
    mining_time_label.visible = show_label
    if not show_label:
        return
    if Util.is_open_pit_game_active():
        var open_pit_data := OPEN_PIT_PROGRESS_SCRIPT.load_data()
        var next_flight := int(open_pit_data.get("attempt_history", []).size()) + 1
        var assist_note := ""
        if bool(open_pit_data.get("editor_assists_used", false)):
            assist_note = tr("OPEN_PIT_EDITOR_ASSISTS_DISABLED_NOTE")
        mining_time_label.text = _trf("OPEN_PIT_UPGRADE_STATUS", [next_flight, OPEN_PIT_PROGRESS_SCRIPT.get_core_wallet(), assist_note])
    elif Util.is_open_pit_orbit_game_active():
        mining_time_label.text = _trf("OPEN_PIT_ORBIT_UPGRADE_STATUS", [OPEN_PIT_ORBIT_PROGRESS_SCRIPT.get_core_wallet()])
    else:
        mining_time_label.text = _trf("BATTLE_CLOCK_LABEL", [Util.format_time(SaveHandler.fishing_run_clock_seconds)])

func _setup_open_pit_chat_controls() -> void:
    var parent_layer: CanvasLayer = %CanvasLayer2
    if parent_layer == null:
        return
    if open_pit_chat_button == null or not is_instance_valid(open_pit_chat_button):
        open_pit_chat_button = Button.new()
        open_pit_chat_button.name = "OpenPitChatButton"
        open_pit_chat_button.anchor_left = 1.0
        open_pit_chat_button.anchor_top = 0.0
        open_pit_chat_button.anchor_right = 1.0
        open_pit_chat_button.anchor_bottom = 0.0
        open_pit_chat_button.offset_left = -184.0
        open_pit_chat_button.offset_top = 112.0
        open_pit_chat_button.offset_right = -16.0
        open_pit_chat_button.offset_bottom = 172.0
        open_pit_chat_button.z_index = 210
        open_pit_chat_button.focus_mode = Control.FOCUS_NONE
        open_pit_chat_button.custom_minimum_size = Vector2(168.0, 60.0)
        open_pit_chat_button.add_theme_font_size_override("font_size", 22)
        open_pit_chat_button.text = tr("CHAT")
        open_pit_chat_button.pressed.connect(_on_open_pit_chat_button_pressed)
        _style_utility_button(open_pit_chat_button)
        parent_layer.add_child(open_pit_chat_button)
    if open_pit_chat_panel == null or not is_instance_valid(open_pit_chat_panel):
        open_pit_chat_panel = PanelContainer.new()
        open_pit_chat_panel.name = "OpenPitChatPanel"
        open_pit_chat_panel.anchor_left = 1.0
        open_pit_chat_panel.anchor_top = 0.0
        open_pit_chat_panel.anchor_right = 1.0
        open_pit_chat_panel.anchor_bottom = 0.0
        open_pit_chat_panel.offset_left = -620.0
        open_pit_chat_panel.offset_top = 180.0
        open_pit_chat_panel.offset_right = -16.0
        open_pit_chat_panel.offset_bottom = 612.0
        open_pit_chat_panel.z_index = 225
        open_pit_chat_panel.visible = false
        open_pit_chat_panel.mouse_filter = Control.MOUSE_FILTER_STOP
        _style_utility_button_panel(open_pit_chat_panel)
        _bind_demo_label_visibility_to_popup(open_pit_chat_panel)
        parent_layer.add_child(open_pit_chat_panel)

        var margin := MarginContainer.new()
        margin.add_theme_constant_override("margin_left", 14)
        margin.add_theme_constant_override("margin_top", 12)
        margin.add_theme_constant_override("margin_right", 14)
        margin.add_theme_constant_override("margin_bottom", 12)
        open_pit_chat_panel.add_child(margin)

        var vbox := VBoxContainer.new()
        vbox.add_theme_constant_override("separation", 10)
        margin.add_child(vbox)

        open_pit_chat_label = RichTextLabel.new()
        open_pit_chat_label.bbcode_enabled = true
        open_pit_chat_label.scroll_active = true
        open_pit_chat_label.fit_content = false
        open_pit_chat_label.custom_minimum_size = Vector2(570.0, 340.0)
        open_pit_chat_label.add_theme_font_size_override("normal_font_size", 18)
        open_pit_chat_label.add_theme_color_override("default_color", Color(0.92, 0.96, 0.9, 1.0))
        vbox.add_child(open_pit_chat_label)
    _update_upgrade_top_button_positions()
    _refresh_open_pit_chat_panel()

func _on_open_pit_chat_button_pressed() -> void:
    if open_pit_chat_panel == null or not is_instance_valid(open_pit_chat_panel):
        return
    _hide_settings_panel()
    _hide_continue_locked_panel()
    open_pit_chat_panel.visible = not open_pit_chat_panel.visible
    _refresh_open_pit_chat_panel()
    _refresh_demo_mode_label_visibility()
    _refresh_mining_time_label()

func _on_open_pit_chat_close_pressed() -> void:
    if open_pit_chat_panel != null and is_instance_valid(open_pit_chat_panel):
        open_pit_chat_panel.hide()
    _refresh_demo_mode_label_visibility()
    _refresh_mining_time_label()

func _refresh_open_pit_chat_panel() -> void:
    var show_controls := Util.is_open_pit_game_active()
    var chat_open := open_pit_chat_panel != null and is_instance_valid(open_pit_chat_panel) and open_pit_chat_panel.visible
    if open_pit_chat_button != null and is_instance_valid(open_pit_chat_button):
        open_pit_chat_button.visible = show_controls and (chat_open or not _is_any_popup_visible())
        open_pit_chat_button.text = tr("UPGRADE_HIDE_CHAT") if chat_open else tr("CHAT")
    if not show_controls:
        if open_pit_chat_panel != null and is_instance_valid(open_pit_chat_panel):
            open_pit_chat_panel.hide()
        return
    if open_pit_chat_label == null or not is_instance_valid(open_pit_chat_label):
        return
    var data := OPEN_PIT_PROGRESS_SCRIPT.load_data()
    var saved_lines: Array = data.get("chat_log", [])
    var lines: Array[String] = []
    var start_index := maxi(0, saved_lines.size() - 60)
    for idx in range(start_index, saved_lines.size()):
        var line := str(saved_lines[idx])
        if line.strip_edges() != "":
            lines.append(line)
    if lines.is_empty():
        open_pit_chat_label.text = _trf("OPEN_PIT_CHAT_EMPTY")
    else:
        open_pit_chat_label.text = _trf("OPEN_PIT_CHAT_BODY", ["\n".join(lines)])
    call_deferred("_scroll_open_pit_chat_to_bottom")

func _scroll_open_pit_chat_to_bottom() -> void:
    if open_pit_chat_label == null or not is_instance_valid(open_pit_chat_label):
        return
    open_pit_chat_label.scroll_to_line(open_pit_chat_label.get_line_count())

func _get_demo_wishlist_url() -> String:
    if SteamHandler != null and SteamHandler.has_method("get_demo_wishlist_url"):
        return SteamHandler.get_demo_wishlist_url()
    return str(ProjectSettings.get_setting(DEMO_WISHLIST_URL_SETTING, "")).strip_edges()

func _can_open_demo_wishlist_url() -> bool:
    var url: String = _get_demo_wishlist_url()
    return url.begins_with("http://") or url.begins_with("https://")

func _setup_wishlist_button() -> void:
    _refresh_demo_mode_label_visibility()
    var button: Button = _get_active_wishlist_button()
    if button == null:
        return
    var should_show_wishlist := _is_demo_mode_enabled()
    button.visible = should_show_wishlist
    if not should_show_wishlist:
        button.disabled = true
        return
    var wishlist_url := _get_demo_wishlist_url()
    var can_open_wishlist := wishlist_url.begins_with("http://") or wishlist_url.begins_with("https://")
    button.disabled = false if OS.has_feature("web") and can_open_wishlist else not can_open_wishlist
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.focus_mode = Control.FOCUS_ALL
    button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
    # Keep the wishlist above the bottom bar but below top-level overlays like settings.
    button.z_index = 200
    button.modulate = Color(1.0, 1.0, 1.0, 1.0)
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.tooltip_text = wishlist_url
    if not button.pressed.is_connected(_on_wishlist_button_pressed):
        button.pressed.connect(_on_wishlist_button_pressed)
    _refresh_wishlist_button_text()
    _style_wishlist_button(button)

func _queue_wishlist_button_setup() -> void:
    if _wishlist_button_setup_queued:
        return
    _wishlist_button_setup_queued = true
    call_deferred("_run_queued_wishlist_button_setup")

func _run_queued_wishlist_button_setup() -> void:
    _wishlist_button_setup_queued = false
    _setup_wishlist_button()

func _setup_leaderboard_panel() -> void:
    if not _should_offer_leaderboards():
        return
    if leaderboard_panel != null and is_instance_valid(leaderboard_panel):
        return
    var panel_host: CanvasLayer = %CanvasLayer2
    if panel_host == null:
        return
    if leaderboard_button == null or not is_instance_valid(leaderboard_button):
        leaderboard_button = Button.new()
        leaderboard_button.name = "LeaderboardButton"
        leaderboard_button.anchor_left = 0.0
        leaderboard_button.anchor_top = 0.0
        leaderboard_button.anchor_right = 0.0
        leaderboard_button.anchor_bottom = 0.0
        leaderboard_button.offset_left = 16.0
        leaderboard_button.offset_top = _get_leaderboard_button_top_offset()
        leaderboard_button.offset_right = 184.0
        leaderboard_button.offset_bottom = leaderboard_button.offset_top + 60.0
        leaderboard_button.z_index = 210
        leaderboard_button.focus_mode = Control.FOCUS_NONE
        leaderboard_button.custom_minimum_size = Vector2(168.0, 60.0)
        leaderboard_button.add_theme_font_size_override("font_size", 20)
        leaderboard_button.pressed.connect(_on_leaderboard_button_pressed)
        _style_utility_button(leaderboard_button)
        panel_host.add_child(leaderboard_button)
    leaderboard_panel = PanelContainer.new()
    leaderboard_panel.name = "LeaderboardPanel"
    leaderboard_panel.anchor_left = 0.0
    leaderboard_panel.anchor_top = 0.0
    leaderboard_panel.anchor_right = 0.0
    leaderboard_panel.anchor_bottom = 0.0
    leaderboard_panel.offset_left = 16.0
    leaderboard_panel.offset_top = _get_leaderboard_panel_top_offset()
    leaderboard_panel.offset_right = 420.0
    leaderboard_panel.offset_bottom = leaderboard_panel.offset_top + 310.0
    leaderboard_panel.custom_minimum_size = Vector2(404.0, 0.0)
    leaderboard_panel.z_index = 210
    leaderboard_panel.visible = false
    leaderboard_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color(0.05, 0.08, 0.14, 0.48)
    panel_style.border_color = Color(0.2, 0.72, 0.94, 0.7)
    panel_style.border_width_left = 2
    panel_style.border_width_top = 2
    panel_style.border_width_right = 2
    panel_style.border_width_bottom = 2
    panel_style.corner_radius_top_left = 6
    panel_style.corner_radius_top_right = 6
    panel_style.corner_radius_bottom_left = 6
    panel_style.corner_radius_bottom_right = 6
    leaderboard_panel.add_theme_stylebox_override("panel", panel_style)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_bottom", 10)
    leaderboard_panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    margin.add_child(vbox)

    leaderboard_title_label = Label.new()
    leaderboard_title_label.text = _get_leaderboard_panel_title()
    leaderboard_title_label.add_theme_font_size_override("font_size", 24)
    leaderboard_title_label.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 1.0))
    vbox.add_child(leaderboard_title_label)

    leaderboard_body_label = Label.new()
    leaderboard_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    leaderboard_body_label.add_theme_font_size_override("font_size", 18)
    leaderboard_body_label.add_theme_color_override("font_color", Color(0.84, 0.9, 0.98, 1.0))
    leaderboard_body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    vbox.add_child(leaderboard_body_label)

    if OS.has_feature("editor") and Util.is_vanguard_game_active():
        var editor_button_row := HBoxContainer.new()
        editor_button_row.add_theme_constant_override("separation", 8)
        vbox.add_child(editor_button_row)

        leaderboard_submit_30m_button = Button.new()
        leaderboard_submit_30m_button.text = tr("UPGRADE_LEADERBOARD_SUBMIT_L7_30M")
        leaderboard_submit_30m_button.mouse_filter = Control.MOUSE_FILTER_STOP
        leaderboard_submit_30m_button.pressed.connect(_on_submit_editor_level7_30m_pressed)
        editor_button_row.add_child(leaderboard_submit_30m_button)

        leaderboard_submit_1h_button = Button.new()
        leaderboard_submit_1h_button.text = tr("UPGRADE_LEADERBOARD_SUBMIT_L7_1H")
        leaderboard_submit_1h_button.mouse_filter = Control.MOUSE_FILTER_STOP
        leaderboard_submit_1h_button.pressed.connect(_on_submit_editor_level7_1h_pressed)
        editor_button_row.add_child(leaderboard_submit_1h_button)

        var editor_button_row_2 := HBoxContainer.new()
        editor_button_row_2.add_theme_constant_override("separation", 8)
        vbox.add_child(editor_button_row_2)

        leaderboard_submit_2h_level20_button = Button.new()
        leaderboard_submit_2h_level20_button.text = tr("UPGRADE_LEADERBOARD_SUBMIT_L20_2H")
        leaderboard_submit_2h_level20_button.mouse_filter = Control.MOUSE_FILTER_STOP
        leaderboard_submit_2h_level20_button.pressed.connect(_on_submit_editor_level20_2h_pressed)
        editor_button_row_2.add_child(leaderboard_submit_2h_level20_button)

        leaderboard_submit_3h_level20_button = Button.new()
        leaderboard_submit_3h_level20_button.text = tr("UPGRADE_LEADERBOARD_SUBMIT_L20_3H")
        leaderboard_submit_3h_level20_button.mouse_filter = Control.MOUSE_FILTER_STOP
        leaderboard_submit_3h_level20_button.pressed.connect(_on_submit_editor_level20_3h_pressed)
        editor_button_row_2.add_child(leaderboard_submit_3h_level20_button)

    panel_host.add_child(leaderboard_panel)
    if SteamHandler != null and SteamHandler.has_signal("leaderboard_data_updated") and not SteamHandler.leaderboard_data_updated.is_connected(_refresh_leaderboard_panel):
        SteamHandler.leaderboard_data_updated.connect(_refresh_leaderboard_panel)
    _refresh_leaderboard_panel()

func _get_leaderboard_panel_top_offset() -> float:
    var top_offset: float = maxf(LEADERBOARD_PANEL_TOP_DEFAULT, _get_leaderboard_button_top_offset() + 68.0)
    if not Util.is_all_high_level_mode_active():
        return top_offset
    var viewport: Viewport = get_viewport()
    if viewport == null:
        return top_offset
    var vertical_shift := viewport.get_visible_rect().size.y * UPGRADE_TOP_BUTTON_VERTICAL_SHIFT_RATIO
    var shifted_button_bottom := 104.0 + vertical_shift
    return max(top_offset, shifted_button_bottom + LEADERBOARD_PANEL_TOP_MARGIN_FROM_MENU)

func _get_leaderboard_button_top_offset() -> float:
    var top_offset := 132.0
    if not Util.is_all_high_level_mode_active():
        return top_offset
    var viewport: Viewport = get_viewport()
    var vertical_shift := viewport.get_visible_rect().size.y * UPGRADE_TOP_BUTTON_VERTICAL_SHIFT_RATIO if viewport != null else 0.0
    return maxf(top_offset, 112.0 + vertical_shift)

func _update_leaderboard_panel_position() -> void:
    if leaderboard_button != null and is_instance_valid(leaderboard_button):
        var button_top := _get_leaderboard_button_top_offset()
        leaderboard_button.offset_top = button_top
        leaderboard_button.offset_bottom = button_top + 60.0
    if leaderboard_panel == null or not is_instance_valid(leaderboard_panel):
        return
    var top_offset := _get_leaderboard_panel_top_offset()
    var panel_height := leaderboard_panel.offset_bottom - leaderboard_panel.offset_top
    leaderboard_panel.offset_top = top_offset
    leaderboard_panel.offset_bottom = top_offset + panel_height

func _on_leaderboard_button_pressed() -> void:
    if not _should_offer_leaderboards():
        leaderboard_panel_open = false
        _refresh_leaderboard_panel()
        return
    _hide_settings_panel()
    _hide_continue_locked_panel()
    if open_pit_chat_panel != null and is_instance_valid(open_pit_chat_panel):
        open_pit_chat_panel.hide()
    leaderboard_panel_open = not leaderboard_panel_open
    if leaderboard_panel_open and SteamHandler != null and SteamHandler.has_method("request_active_fishing_leaderboards"):
        SteamHandler.request_active_fishing_leaderboards()
    _refresh_leaderboard_panel()
    _refresh_open_pit_chat_panel()
    _refresh_demo_mode_label_visibility()
    _refresh_mining_time_label()

func _refresh_leaderboard_panel() -> void:
    var offer_leaderboards := _should_offer_leaderboards()
    var panel_open := offer_leaderboards and leaderboard_panel_open
    if leaderboard_panel == null or not is_instance_valid(leaderboard_panel):
        if leaderboard_button != null and is_instance_valid(leaderboard_button):
            leaderboard_button.visible = offer_leaderboards and not _is_any_popup_visible()
            leaderboard_button.text = tr("UPGRADE_LEADERBOARD")
        return
    if not panel_open:
        leaderboard_panel.visible = false
        if leaderboard_button != null and is_instance_valid(leaderboard_button):
            leaderboard_button.visible = offer_leaderboards and not _is_any_popup_visible()
            leaderboard_button.text = tr("UPGRADE_LEADERBOARD")
        return
    if leaderboard_button != null and is_instance_valid(leaderboard_button):
        leaderboard_button.visible = true
        leaderboard_button.text = tr("UPGRADE_HIDE_RANKS")
    var configs: Array = SteamHandler.get_active_fishing_leaderboard_configs() if SteamHandler != null and SteamHandler.has_method("get_active_fishing_leaderboard_configs") else []
    var show_panel: bool = not configs.is_empty()
    leaderboard_panel.visible = show_panel
    if not show_panel:
        return
    if leaderboard_title_label != null and is_instance_valid(leaderboard_title_label):
        leaderboard_title_label.text = _get_leaderboard_panel_title()
    var lines: Array[String] = []
    for config_variant: Variant in configs:
        if not (config_variant is Dictionary):
            continue
        var config: Dictionary = config_variant
        var level: int = int(config.get("level", -1))
        var board_id: String = str(config.get("id", ""))
        var title_key: String = str(config.get("title_key", "")).strip_edges()
        var description_key: String = str(config.get("description_key", "")).strip_edges()
        var title: String = tr(title_key) if title_key != "" else str(config.get("title", "Level %d" % level))
        lines.append(title)
        if description_key != "":
            lines.append(tr(description_key))
        elif str(config.get("description", "")).strip_edges() != "":
            lines.append(str(config.get("description", "")).strip_edges())
        var local_best: float = _get_local_leaderboard_best_time(board_id, level)
        lines.append("Your best: %s" % (_format_leaderboard_time(local_best) if local_best >= 0.0 else "--"))
        var status: String = SteamHandler.get_cached_leaderboard_status(board_id) if SteamHandler != null and SteamHandler.has_method("get_cached_leaderboard_status") else "Unavailable"
        var submitted_score_ms: int = SteamHandler.get_cached_leaderboard_last_submitted_score(board_id) if SteamHandler != null and SteamHandler.has_method("get_cached_leaderboard_last_submitted_score") else -1
        if submitted_score_ms >= 0:
            lines.append("Steam submitted: %s" % _format_leaderboard_time(float(submitted_score_ms) / 1000.0))
        var top_entries: Array = SteamHandler.get_cached_leaderboard_display_entries(board_id) if SteamHandler != null and SteamHandler.has_method("get_cached_leaderboard_display_entries") else []
        var around_entries: Array = SteamHandler.get_cached_leaderboard_around_user_display_entries(board_id) if SteamHandler != null and SteamHandler.has_method("get_cached_leaderboard_around_user_display_entries") else []
        if top_entries.is_empty():
            lines.append("Steam status: %s" % status)
        else:
            lines.append("Top 5")
            var display_rank: int = 1
            for entry_variant: Variant in top_entries:
                if not (entry_variant is Dictionary):
                    continue
                var entry: Dictionary = entry_variant
                var rank: int = SteamHandler.get_leaderboard_entry_rank(entry, display_rank) if SteamHandler != null and SteamHandler.has_method("get_leaderboard_entry_rank") else display_rank
                var score_ms: int = int(entry.get("score", 0))
                var persona: String = SteamHandler.get_leaderboard_entry_display_name(entry) if SteamHandler != null and SteamHandler.has_method("get_leaderboard_entry_display_name") else "Player"
                lines.append("#%d %s  %s" % [rank, persona, _format_leaderboard_time(float(score_ms) / 1000.0)])
                display_rank += 1
        if not around_entries.is_empty():
            lines.append("")
            lines.append("Around You")
            for entry_variant: Variant in around_entries:
                if not (entry_variant is Dictionary):
                    continue
                var entry: Dictionary = entry_variant
                var rank: int = SteamHandler.get_leaderboard_entry_rank(entry, 0) if SteamHandler != null and SteamHandler.has_method("get_leaderboard_entry_rank") else 0
                var score_ms: int = int(entry.get("score", 0))
                var persona: String = SteamHandler.get_leaderboard_entry_display_name(entry) if SteamHandler != null and SteamHandler.has_method("get_leaderboard_entry_display_name") else "Player"
                lines.append("#%d %s  %s" % [rank, persona, _format_leaderboard_time(float(score_ms) / 1000.0)])
        lines.append("")
    if not lines.is_empty() and lines[lines.size() - 1] == "":
        lines.remove_at(lines.size() - 1)
    leaderboard_body_label.text = "\n".join(lines)

func _format_leaderboard_time(seconds: float) -> String:
    if seconds < 0.0:
        return "--"
    return Util.format_time(seconds)

func _get_local_leaderboard_best_time(board_id: String, level: int) -> float:
    match board_id:
        "DeepcoreTimeToTier8":
            return SaveHandler.get_deepcore_tier8_time()
        "DataBreachIncDemoCore8Time":
            return OPEN_PIT_PROGRESS_SCRIPT.get_demo_core8_time()
        "DataBreachIncFullClearTime":
            return OPEN_PIT_PROGRESS_SCRIPT.get_full_clear_time()
        _:
            return SaveHandler.get_fishing_best_boss_clear_time(level)

func _submit_editor_leaderboard_time(level: int, time_seconds: float) -> void:
    if not OS.has_feature("editor"):
        return
    if not Util.is_vanguard_game_active():
        return
    print("EDITOR LEADERBOARD SUBMIT level=", level, " seconds=", time_seconds)
    SaveHandler.register_fishing_boss_clear_time(level, time_seconds)
    if SteamHandler == null:
        return
    if level == 20 and SteamHandler.has_method("submit_level20_clear_time"):
        SteamHandler.submit_level20_clear_time(time_seconds)
        return
    if level == 7 and SteamHandler.has_method("submit_level7_clear_time"):
        SteamHandler.submit_level7_clear_time(time_seconds)
        return
    if SteamHandler.has_method("submit_fishing_boss_clear_time"):
        SteamHandler.submit_fishing_boss_clear_time(level, time_seconds)

func _on_submit_editor_level7_30m_pressed() -> void:
    _submit_editor_leaderboard_time(7, 1800.0)

func _on_submit_editor_level7_1h_pressed() -> void:
    _submit_editor_leaderboard_time(7, 3600.0)

func _on_submit_editor_level20_2h_pressed() -> void:
    _submit_editor_leaderboard_time(20, 7200.0)

func _on_submit_editor_level20_3h_pressed() -> void:
    _submit_editor_leaderboard_time(20, 10800.0)

func _get_active_wishlist_button() -> Button:
    if OS.has_feature("web"):
        return _ensure_web_wishlist_button()
    return wishlist_button

func _ensure_web_wishlist_button() -> Button:
    if wishlist_button == null:
        return null
    if web_wishlist_button != null and is_instance_valid(web_wishlist_button):
        wishlist_button.visible = false
        return web_wishlist_button

    var parent_control := wishlist_button.get_parent()
    if parent_control == null:
        return wishlist_button

    web_wishlist_button = Button.new()
    web_wishlist_button.name = "WebWishlistButton"
    web_wishlist_button.custom_minimum_size = wishlist_button.custom_minimum_size
    web_wishlist_button.size_flags_horizontal = wishlist_button.size_flags_horizontal
    web_wishlist_button.size_flags_vertical = wishlist_button.size_flags_vertical
    web_wishlist_button.size_flags_stretch_ratio = wishlist_button.size_flags_stretch_ratio
    web_wishlist_button.theme = wishlist_button.theme
    web_wishlist_button.mouse_filter = Control.MOUSE_FILTER_STOP
    web_wishlist_button.focus_mode = Control.FOCUS_ALL
    web_wishlist_button.clip_text = true
    web_wishlist_button.flat = false
    web_wishlist_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
    web_wishlist_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    web_wishlist_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

    var wishlist_index := wishlist_button.get_index()
    wishlist_button.visible = false
    parent_control.add_child(web_wishlist_button)
    parent_control.move_child(web_wishlist_button, wishlist_index)
    return web_wishlist_button

func _refresh_wishlist_button_text() -> void:
    var button: Button = web_wishlist_button if web_wishlist_button != null and is_instance_valid(web_wishlist_button) else wishlist_button
    if button == null:
        return
    button.text = tr("UPGRADE_WISHLIST")

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
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_stylebox_override("disabled", normal.duplicate(true))
    button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
    button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
    button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
    button.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 1.0))
    button.add_theme_color_override("font_disabled_color", Color(1.0, 1.0, 1.0, 1.0))

func _on_wishlist_button_pressed() -> void:
    var url: String = _get_demo_wishlist_url()
    if not _can_open_demo_wishlist_url():
        return
    _open_external_url(url)

func _open_external_url(url: String) -> void:
    if url.strip_edges() == "":
        return
    if OS.has_feature("web"):
        var window := JavaScriptBridge.get_interface("window")
        if window != null:
            var opened = window.call("open", url, "_blank")
            if opened != null:
                return
            var location = window.get("location")
            if location != null:
                location.call("assign", url)
                return
            return
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
        battle_level_choice_dialog.title = tr("UI_CHOOSE_BATTLE_LEVEL")
        battle_level_choice_dialog.get_ok_button().hide()
        battle_level_choice_dialog.get_cancel_button().hide()
        parent_layer.add_child(battle_level_choice_dialog)
    _bind_demo_label_visibility_to_popup(battle_level_choice_dialog)
    _style_battle_level_choice_dialog()
    if not battle_level_choice_dialog.custom_action.is_connected(_on_battle_level_choice_action):
        battle_level_choice_dialog.custom_action.connect(_on_battle_level_choice_action)

func _show_battle_level_choice_dialog(max_level: int) -> void:
    if Util.is_open_pit_game_active():
        _launch_battle_at_level(OPEN_PIT_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL)
        return
    if battle_level_choice_dialog == null:
        if Util.is_mining_game_active():
            var mining_fallback_data: Dictionary = MINING_PROGRESS_SCRIPT.load_data()
            var min_depth: int = MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
            _launch_battle_at_level(clampi(int(mining_fallback_data.get("selected_depth_level", max_level)), min_depth, max_level))
        elif Util.is_open_pit_game_active():
            _launch_battle_at_level(OPEN_PIT_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL)
        elif Util.is_open_pit_orbit_game_active():
            var orbit_fallback_data: Dictionary = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.load_data()
            var orbit_min_depth: int = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
            _launch_battle_at_level(clampi(int(orbit_fallback_data.get("selected_depth_level", max_level)), orbit_min_depth, max_level))
        else:
            _launch_battle_at_level(clamp(SaveHandler.fishing_next_battle_level, 1, max_level))
        return

    battle_level_choice_max_level = max_level
    if Util.is_mining_game_active():
        var mining_data: Dictionary = MINING_PROGRESS_SCRIPT.load_data()
        var min_depth: int = MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
        battle_level_choice_selected_level = clampi(int(mining_data.get("selected_depth_level", max_level)), min_depth, max_level)
        battle_level_choice_dialog.title = tr("MINING_CHOOSE_DEPTH_TIER_TITLE")
    elif Util.is_open_pit_game_active():
        var open_pit_data: Dictionary = OPEN_PIT_PROGRESS_SCRIPT.load_data()
        var open_pit_min_depth: int = OPEN_PIT_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
        battle_level_choice_selected_level = clampi(int(open_pit_data.get("selected_depth_level", max_level)), open_pit_min_depth, max_level)
        battle_level_choice_dialog.title = tr("OPEN_PIT_CHOOSE_EMPIRE_LAYER")
    elif Util.is_open_pit_orbit_game_active():
        var orbit_data: Dictionary = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.load_data()
        var orbit_min_depth: int = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
        battle_level_choice_selected_level = clampi(int(orbit_data.get("selected_depth_level", max_level)), orbit_min_depth, max_level)
        battle_level_choice_dialog.title = tr("OPEN_PIT_ORBIT_CHOOSE_LAYER")
    else:
        battle_level_choice_selected_level = clamp(SaveHandler.fishing_next_battle_level, 1, max_level)
        battle_level_choice_dialog.title = tr("UI_CHOOSE_BATTLE_LEVEL")
    var popup_device := _get_popup_controller_device()
    _popup_x_confirm_armed = popup_device == -1 or not Input.is_joy_button_pressed(popup_device, JOY_BUTTON_X)
    battle_level_choice_dialog.dialog_text = ""
    _rebuild_battle_level_choice_dialog_content(max_level)
    _style_battle_level_choice_dialog()
    battle_level_choice_dialog.popup_centered(BATTLE_LEVEL_CHOICE_DIALOG_SIZE)
    _refresh_virtual_cursor_state()
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

    var mining_mode_active: bool = Util.is_mining_game_active()
    var min_level: int = MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL if mining_mode_active else 1
    var display_max_level: int = MINING_PROGRESS_SCRIPT.get_display_depth_tier(max_level) if mining_mode_active else max_level

    if display_max_level <= 4:
        for level in range(min_level, max_level + 1):
            var button := Button.new()
            button.name = "BattleLevelChoiceButton%d" % level
            var display_level: int = MINING_PROGRESS_SCRIPT.get_display_depth_tier(level) if mining_mode_active else level
            button.text = _trf("MINING_DEPTH_TIER_FORMAT", [display_level]) if mining_mode_active else _trf("UI_LEVEL_FORMAT", [display_level])
            button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            button.custom_minimum_size = Vector2(0.0, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
            button.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE)
            button.pressed.connect(_on_battle_level_choice_button_pressed.bind(level))
            vbox.add_child(button)
    else:
        var prompt := Label.new()
        prompt.text = _trf("MINING_SELECT_DEPTH_TIER_RANGE", [display_max_level]) if mining_mode_active else _trf("UI_SELECT_BATTLE_LEVEL_RANGE", [display_max_level])
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
        battle_level_choice_line_edit.text = str(MINING_PROGRESS_SCRIPT.get_display_depth_tier(battle_level_choice_selected_level) if mining_mode_active else battle_level_choice_selected_level)
        battle_level_choice_line_edit.custom_minimum_size = Vector2(BATTLE_LEVEL_SELECTOR_INPUT_WIDTH, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        battle_level_choice_line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
        battle_level_choice_line_edit.max_length = len(str(display_max_level))
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
    cancel_button.text = tr("UI_CANCEL")
    cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cancel_button.custom_minimum_size = Vector2(0.0, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
    cancel_button.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE)
    cancel_button.pressed.connect(_on_battle_level_choice_cancel_pressed)
    vbox.add_child(_wrap_control_with_glyph(cancel_button, "joypad/b", false))

    if display_max_level > 4:
        var confirm_button := Button.new()
        confirm_button.name = "BattleLevelChoiceConfirmButton"
        confirm_button.text = tr("UI_CONFIRM")
        confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        confirm_button.custom_minimum_size = Vector2(0.0, BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        confirm_button.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_BUTTON_FONT_SIZE)
        confirm_button.pressed.connect(_on_battle_level_choice_confirm_pressed.bind(max_level))
        vbox.add_child(_wrap_control_with_glyphs(confirm_button, ["joypad/a", "joypad/x"], false))

        if battle_level_choice_line_edit != null:
            battle_level_choice_line_edit.select_all()

func _on_battle_level_choice_button_pressed(level: int) -> void:
    _launch_battle_at_level(level)

func _on_battle_level_choice_adjust_pressed(delta: int, max_level: int) -> void:
    var min_level: int = MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL if Util.is_mining_game_active() else 1
    battle_level_choice_selected_level = clampi(battle_level_choice_selected_level + delta, min_level, max_level)
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
    _refresh_virtual_cursor_state()

func _is_reel_depth_tier_dialog_open() -> bool:
    return reel_depth_tier_dialog != null and is_instance_valid(reel_depth_tier_dialog) and reel_depth_tier_dialog.visible

func _setup_reel_depth_tier_dialog() -> void:
    var parent_layer: CanvasLayer = %CanvasLayer2
    if parent_layer == null:
        return
    reel_depth_tier_dialog = parent_layer.get_node_or_null("ReelDepthTierDialog")
    if reel_depth_tier_dialog == null:
        reel_depth_tier_dialog = ConfirmationDialog.new()
        reel_depth_tier_dialog.name = "ReelDepthTierDialog"
        reel_depth_tier_dialog.title = tr("Choose depth tier")
        reel_depth_tier_dialog.get_ok_button().hide()
        reel_depth_tier_dialog.get_cancel_button().hide()
        parent_layer.add_child(reel_depth_tier_dialog)
    _bind_demo_label_visibility_to_popup(reel_depth_tier_dialog)
    reel_depth_tier_dialog.add_theme_font_size_override("font_size", BATTLE_LEVEL_CHOICE_DIALOG_FONT_SIZE)
    reel_depth_tier_dialog.add_theme_font_size_override("title_font_size", BATTLE_LEVEL_CHOICE_DIALOG_TITLE_SIZE)
    reel_depth_tier_dialog.min_size = REEL_DEPTH_TIER_DIALOG_SIZE

func _show_reel_depth_tier_dialog() -> void:
    if reel_depth_tier_dialog == null:
        Global.reel_run_max_depth_cap = -1.0
        _launch_reel_fishing_scene()
        return
    _popup_prev_b_pressed = false
    reel_depth_tier_dialog.title = tr("Choose depth tier")
    reel_depth_tier_dialog.dialog_text = ""
    _rebuild_reel_depth_tier_dialog_content()
    reel_depth_tier_dialog.popup_centered(REEL_DEPTH_TIER_DIALOG_SIZE)
    _refresh_virtual_cursor_state()
    _position_virtual_cursor_for_reel_depth_tier()

func _rebuild_reel_depth_tier_dialog_content() -> void:
    if reel_depth_tier_dialog == null:
        return
    var existing: Control = reel_depth_tier_dialog.get_node_or_null("ReelDepthTierContent")
    if existing != null:
        existing.queue_free()
    var margin := MarginContainer.new()
    margin.name = "ReelDepthTierContent"
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    margin.offset_left = 20.0
    margin.offset_top = 16.0
    margin.offset_right = -20.0
    margin.offset_bottom = -16.0
    reel_depth_tier_dialog.add_child(margin)
    var vbox := VBoxContainer.new()
    vbox.name = "ReelDepthTierVBox"
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.add_theme_constant_override("separation", 12)
    margin.add_child(vbox)
    var hint := Label.new()
    hint.text = tr("Easier tiers cap max depth; rewards still use your full upgrades.")
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hint.add_theme_font_size_override("font_size", 22)
    vbox.add_child(hint)
    var idx := 0
    for tier_variant in reel_depth_tier_cache:
        var tier: Dictionary = tier_variant
        var cap: float = float(tier.get("max_depth_cap", 24.0))
        var btn := Button.new()
        btn.name = "ReelDepthTierButton%d" % idx
        btn.text = str(tier.get("title", "Tier"))
        btn.tooltip_text = str(tier.get("detail", ""))
        btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        btn.custom_minimum_size = Vector2(0.0, REEL_DEPTH_TIER_BUTTON_MIN_H)
        btn.add_theme_font_size_override("font_size", REEL_DEPTH_TIER_BUTTON_FONT)
        btn.pressed.connect(_on_reel_depth_tier_picked.bind(cap))
        vbox.add_child(btn)
        idx += 1
    var cancel_button := Button.new()
    cancel_button.name = "ReelDepthTierCancelButton"
    cancel_button.text = tr("UI_CANCEL")
    cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cancel_button.custom_minimum_size = Vector2(0.0, REEL_DEPTH_TIER_BUTTON_MIN_H)
    cancel_button.add_theme_font_size_override("font_size", REEL_DEPTH_TIER_BUTTON_FONT)
    cancel_button.pressed.connect(_on_reel_depth_tier_cancel_pressed)
    vbox.add_child(_wrap_control_with_glyph(cancel_button, "joypad/b", false))

func _position_virtual_cursor_for_reel_depth_tier() -> void:
    if ControllerIcons.get_last_input_type() != ControllerIcons.InputType.CONTROLLER:
        return
    VirtualCursor.activate_for_controller()
    await get_tree().process_frame
    await get_tree().process_frame
    if reel_depth_tier_dialog == null or not reel_depth_tier_dialog.visible:
        return
    var first: Control = reel_depth_tier_dialog.get_node_or_null("ReelDepthTierContent/ReelDepthTierVBox/ReelDepthTierButton0") as Control
    if first != null:
        first.grab_focus()
        VirtualCursor.move_to_control(first)

func _poll_reel_depth_tier_controller(_delta: float) -> void:
    if not _is_reel_depth_tier_dialog_open():
        return
    if ControllerIcons.get_last_input_type() != ControllerIcons.InputType.CONTROLLER:
        return
    var device := _get_popup_controller_device()
    if device == -1:
        return
    var b_pressed := Input.is_joy_button_pressed(device, JOY_BUTTON_B)
    if b_pressed and not _popup_prev_b_pressed:
        _on_reel_depth_tier_cancel_pressed()
    _popup_prev_b_pressed = b_pressed

func _on_reel_depth_tier_picked(cap: float) -> void:
    if reel_depth_tier_dialog != null:
        reel_depth_tier_dialog.hide()
    Global.reel_run_max_depth_cap = cap
    _launch_reel_fishing_scene()

func _on_reel_depth_tier_cancel_pressed() -> void:
    if reel_depth_tier_dialog != null:
        reel_depth_tier_dialog.hide()
    _refresh_virtual_cursor_state()

func _launch_reel_fishing_scene() -> void:
    _refresh_virtual_cursor_state()
    _cache_tech_tree_for_reuse()
    SceneChanger.change_to_new_scene(Util.get_main_scene_path())

func _launch_battle_at_level(level: int) -> void:
    if Util.is_mining_game_active():
        MINING_PROGRESS_SCRIPT.set_selected_depth_level(level)
        _refresh_virtual_cursor_state()
        _cache_tech_tree_for_reuse()
        SceneChanger.change_to_new_scene(Util.get_main_scene_path())
        return
    if Util.is_open_pit_game_active():
        var empire_level: int = OPEN_PIT_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
        OPEN_PIT_PROGRESS_SCRIPT.set_selected_depth_level(empire_level)
        _refresh_virtual_cursor_state()
        _cache_tech_tree_for_reuse()
        var open_pit_target_scene: String = Util.get_main_scene_path()
        if OPEN_PIT_PROGRESS_SCRIPT.load_runtime_planet_data(empire_level) == null:
            open_pit_target_scene = Util.PATH_OPEN_PIT_GENERATING
        SceneChanger.change_to_new_scene(open_pit_target_scene)
        return
    if Util.is_open_pit_orbit_game_active():
        OPEN_PIT_ORBIT_PROGRESS_SCRIPT.set_selected_depth_level(level)
        _refresh_virtual_cursor_state()
        _cache_tech_tree_for_reuse()
        var orbit_target_scene: String = Util.get_main_scene_path()
        if OPEN_PIT_ORBIT_PROGRESS_SCRIPT.load_runtime_planet_data(level) == null:
            orbit_target_scene = Util.PATH_OPEN_PIT_ORBIT_GENERATING
        SceneChanger.change_to_new_scene(orbit_target_scene)
        return
    if Util.is_red_sky_game_active():
        _refresh_virtual_cursor_state()
        _cache_tech_tree_for_reuse()
        SceneChanger.change_to_new_scene(Util.get_main_scene_path())
        return
    if Util.is_turkey_game_active():
        _refresh_virtual_cursor_state()
        _cache_tech_tree_for_reuse()
        SceneChanger.change_to_new_scene(Util.get_main_scene_path())
        return
    if Util.is_reel_into_darkness_game_active():
        _launch_reel_fishing_scene()
        return
    var max_level: int = clamp(int(SaveHandler.fishing_max_unlocked_battle_level), 1, SaveHandler.MAX_FISHING_BATTLE_LEVEL)
    SaveHandler.fishing_next_battle_level = clamp(level, 1, max_level)
    SaveHandler.save_fishing_progress()
    _refresh_virtual_cursor_state()
    _cache_tech_tree_for_reuse()
    SceneChanger.change_to_new_scene(Util.get_battle_scene_path())

func _refresh_virtual_cursor_state() -> void:
    VirtualCursor.use_open_pit_orbit_cursor(false)
    var should_enable := is_active and (
        ControllerIcons.get_last_input_type() != ControllerIcons.InputType.CONTROLLER
        or _is_battle_level_choice_open()
        or _is_reel_depth_tier_dialog_open()
    )
    VirtualCursor.set_scene_enabled(should_enable)

func _sync_battle_level_choice_from_input(max_level: int) -> void:
    if battle_level_choice_line_edit == null:
        return
    var raw_text: String = battle_level_choice_line_edit.text.strip_edges()
    var min_level: int = MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL if Util.is_mining_game_active() else 1
    if raw_text == "":
        battle_level_choice_selected_level = clampi(battle_level_choice_selected_level, min_level, max_level)
    else:
        if Util.is_mining_game_active():
            var max_display_level: int = MINING_PROGRESS_SCRIPT.get_display_depth_tier(max_level)
            var display_level: int = clampi(int(raw_text), 1, max_display_level)
            battle_level_choice_selected_level = MINING_PROGRESS_SCRIPT.get_depth_level_for_display_tier(display_level)
        else:
            battle_level_choice_selected_level = clampi(int(raw_text), min_level, max_level)
    _update_battle_level_choice_line_edit()

func _update_battle_level_choice_line_edit() -> void:
    if battle_level_choice_line_edit == null:
        return
    var display_level: int = MINING_PROGRESS_SCRIPT.get_display_depth_tier(battle_level_choice_selected_level) if Util.is_mining_game_active() else battle_level_choice_selected_level
    battle_level_choice_line_edit.text = str(display_level)
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
    var display_max_level: int = MINING_PROGRESS_SCRIPT.get_display_depth_tier(battle_level_choice_max_level) if Util.is_mining_game_active() else battle_level_choice_max_level
    if display_max_level <= 4:
        _launch_battle_at_level(battle_level_choice_selected_level)
        return true
    _on_battle_level_choice_confirm_pressed(battle_level_choice_max_level)
    return true

func _get_primary_battle_level_choice_button(max_level: int) -> Control:
    if battle_level_choice_dialog == null:
        return null
    var display_max_level: int = MINING_PROGRESS_SCRIPT.get_display_depth_tier(max_level) if Util.is_mining_game_active() else max_level
    if display_max_level <= 4:
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
    editor_cash_controls.offset_left = -1020.0
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

    editor_add_xp_button = Button.new()
    editor_add_xp_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_add_xp_button.pressed.connect(_on_editor_add_xp_pressed)
    editor_cash_controls.add_child(editor_add_xp_button)

    editor_add_core_button = Button.new()
    editor_add_core_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_add_core_button.pressed.connect(_on_editor_add_core_pressed)
    editor_cash_controls.add_child(editor_add_core_button)

    editor_auto_buy_button = Button.new()
    editor_auto_buy_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_auto_buy_button.pressed.connect(_on_editor_auto_buy_pressed)
    editor_cash_controls.add_child(editor_auto_buy_button)

    editor_reset_add_button = Button.new()
    editor_reset_add_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_reset_add_button.text = tr("UPGRADE_EDITOR_RESET_ADD")
    editor_reset_add_button.pressed.connect(_on_editor_reset_add_pressed)
    editor_cash_controls.add_child(editor_reset_add_button)

    editor_unlock_all_button = Button.new()
    editor_unlock_all_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_unlock_all_button.text = tr("UPGRADE_EDITOR_UNLOCK_ALL")
    editor_unlock_all_button.pressed.connect(_on_editor_unlock_all_pressed)
    editor_cash_controls.add_child(editor_unlock_all_button)

    editor_regenerate_planet_button = Button.new()
    editor_regenerate_planet_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_regenerate_planet_button.pressed.connect(_on_editor_regenerate_planet_pressed)
    editor_cash_controls.add_child(editor_regenerate_planet_button)

    editor_crt_toggle_button = Button.new()
    editor_crt_toggle_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_crt_toggle_button.pressed.connect(_on_editor_crt_toggle_pressed)
    editor_cash_controls.add_child(editor_crt_toggle_button)

    editor_demo_toggle_button = Button.new()
    editor_demo_toggle_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    editor_demo_toggle_button.pressed.connect(_on_editor_demo_toggle_pressed)
    editor_cash_controls.add_child(editor_demo_toggle_button)

    %CanvasLayer2.add_child(editor_cash_controls)
    _refresh_editor_cash_button_text()
    _refresh_editor_crt_button_text()
    _refresh_editor_demo_toggle_button_text()
    _refresh_editor_regenerate_planet_button()

func _setup_editor_mode_jump_controls() -> void:
    if editor_mode_jump_controls != null and is_instance_valid(editor_mode_jump_controls):
        _refresh_editor_mode_jump_buttons()
        return

    editor_mode_jump_controls = HBoxContainer.new()
    editor_mode_jump_controls.name = "EditorModeJumpControls"
    editor_mode_jump_controls.anchor_left = 1.0
    editor_mode_jump_controls.anchor_top = 0.0
    editor_mode_jump_controls.anchor_right = 1.0
    editor_mode_jump_controls.anchor_bottom = 0.0
    editor_mode_jump_controls.offset_left = -520.0
    editor_mode_jump_controls.offset_top = 62.0
    editor_mode_jump_controls.offset_right = -12.0
    editor_mode_jump_controls.offset_bottom = 106.0
    editor_mode_jump_controls.alignment = BoxContainer.ALIGNMENT_END
    editor_mode_jump_controls.z_index = 205
    editor_mode_jump_controls.mouse_filter = Control.MOUSE_FILTER_STOP

    editor_data_breach_jump_button = _build_editor_mode_jump_button("DATA BREACH", Util.ACTIVE_GAME_OPEN_PIT)
    editor_mode_jump_controls.add_child(editor_data_breach_jump_button)

    editor_deepcore_jump_button = _build_editor_mode_jump_button("DEEPCORE", Util.ACTIVE_GAME_MINING)
    editor_mode_jump_controls.add_child(editor_deepcore_jump_button)

    editor_red_sky_jump_button = _build_editor_mode_jump_button("RED SKY", Util.ACTIVE_GAME_RED_SKY)
    editor_mode_jump_controls.add_child(editor_red_sky_jump_button)

    %CanvasLayer2.add_child(editor_mode_jump_controls)
    _refresh_editor_mode_jump_buttons()

func _build_editor_mode_jump_button(label: String, game_id: String) -> Button:
    var button := Button.new()
    button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    button.text = label
    button.pressed.connect(_on_editor_mode_jump_pressed.bind(game_id))
    return button

func _refresh_editor_mode_jump_buttons() -> void:
    if editor_mode_jump_controls != null and is_instance_valid(editor_mode_jump_controls):
        editor_mode_jump_controls.visible = _should_show_countermeasure_mode_jump_controls()
    if not _should_show_countermeasure_mode_jump_controls():
        return
    var active_game_id := Util.get_active_game_id()
    if editor_data_breach_jump_button != null and is_instance_valid(editor_data_breach_jump_button):
        editor_data_breach_jump_button.text = "DATA BREACH"
        editor_data_breach_jump_button.disabled = active_game_id == Util.ACTIVE_GAME_OPEN_PIT
    if editor_deepcore_jump_button != null and is_instance_valid(editor_deepcore_jump_button):
        editor_deepcore_jump_button.text = "DEEPCORE"
        editor_deepcore_jump_button.disabled = active_game_id == Util.ACTIVE_GAME_MINING
    if editor_red_sky_jump_button != null and is_instance_valid(editor_red_sky_jump_button):
        editor_red_sky_jump_button.text = "RED SKY"
        editor_red_sky_jump_button.disabled = active_game_id == Util.ACTIVE_GAME_RED_SKY

func _on_editor_mode_jump_pressed(game_id: String) -> void:
    if not _should_show_countermeasure_mode_jump_controls():
        return
    var target_game_id := str(game_id).strip_edges().to_lower()
    if target_game_id == "":
        return
    Global.open_pit_defense_challenge = {}
    Global.open_pit_defense_result = {}
    Global.multi_game_run = {}
    Global.multi_game_step_config = {}
    Util.set_active_game_id(target_game_id)
    Util.set_high_level_mode_id(Util.HIGH_LEVEL_MODE_ALL)
    SaveHandler.load_fishing_progress()
    Global.current_game_mode_data = null
    Global.ensure_default_game_mode_data()
    Global.new_game()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = false
    _refresh_editor_mode_jump_buttons()
    SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _should_show_countermeasure_mode_jump_controls() -> bool:
    return OS.has_feature("editor") or _has_countermeasure_direct_access_unlocked()

func _has_countermeasure_direct_access_unlocked() -> bool:
    var data: Dictionary = OPEN_PIT_PROGRESS_SCRIPT.load_data()
    var purchased: Array = data.get("purchased_core_upgrades", [])
    return "countermeasure_suite" in purchased

func _setup_editor_sell_popup_menu() -> void:
    if not OS.has_feature("editor"):
        return
    if editor_sell_popup_menu != null and is_instance_valid(editor_sell_popup_menu):
        return
    editor_sell_popup_menu = PopupMenu.new()
    editor_sell_popup_menu.name = "EditorSellPopupMenu"
    editor_sell_popup_menu.id_pressed.connect(_on_editor_sell_popup_id_pressed)
    editor_sell_popup_menu.popup_hide.connect(_on_editor_sell_popup_hidden)
    %CanvasLayer2.add_child(editor_sell_popup_menu)

func request_editor_sell_for_node(node: TechTreeNode, screen_position: Vector2) -> void:
    if not OS.has_feature("editor"):
        return
    if node == null or not is_instance_valid(node):
        return
    if node.upgrade == null or node.upgrade.current_tier <= 0 or node.upgrade.sim_key == "":
        return
    if not _is_simulation_upgrade_tree():
        return
    if editor_sell_popup_menu == null or not is_instance_valid(editor_sell_popup_menu):
        return

    editor_sell_target_node = node
    var refund_amount: int = int(round(node.upgrade.get_last_purchased_cost()))
    var blocked_nodes: Array[TechTreeNode] = []
    if tech_tree != null and is_instance_valid(tech_tree) and tech_tree.has_method("get_owned_nodes_blocked_by_removal"):
        blocked_nodes = tech_tree.get_owned_nodes_blocked_by_removal(node)
    var can_sell: bool = blocked_nodes.is_empty()
    var item_text: String = _trf("MINING_SELL_FOR", [Util.get_number_short_text(refund_amount)])
    if not can_sell:
        var blocked_name: String = "dependent upgrades"
        if not blocked_nodes.is_empty() and blocked_nodes[0] != null and blocked_nodes[0].upgrade != null:
            var node_name: String = blocked_nodes[0].upgrade.sim_name.strip_edges()
            if node_name != "":
                blocked_name = node_name
        item_text = _trf("MINING_CANNOT_SELL_DEPENDS", [blocked_name])

    editor_sell_popup_menu.clear()
    editor_sell_popup_menu.add_item(item_text, EDITOR_SELL_MENU_ID)
    editor_sell_popup_menu.set_item_disabled(0, not can_sell)
    editor_sell_popup_menu.reset_size()
    editor_sell_popup_menu.popup(Rect2i(Vector2i(int(screen_position.x), int(screen_position.y)), Vector2i.ONE))

func _on_editor_sell_popup_id_pressed(id: int) -> void:
    if id != EDITOR_SELL_MENU_ID:
        return
    _perform_editor_sell()

func _on_editor_sell_popup_hidden() -> void:
    call_deferred("_clear_editor_sell_target_node")

func _clear_editor_sell_target_node() -> void:
    editor_sell_target_node = null

func _perform_editor_sell() -> void:
    if not OS.has_feature("editor"):
        return
    var node: TechTreeNode = editor_sell_target_node
    editor_sell_target_node = null
    if node == null or not is_instance_valid(node):
        return
    if node.upgrade == null or node.upgrade.current_tier <= 0 or node.upgrade.sim_key == "":
        return
    if tech_tree == null or not is_instance_valid(tech_tree):
        return
    if Global.global_resoruce_manager == null:
        return
    if tech_tree.has_method("can_remove_owned_tier") and not tech_tree.can_remove_owned_tier(node):
        return

    var refund_amount: int = int(round(node.upgrade.get_last_purchased_cost()))
    var wallet_after_sale: int
    if Util.is_open_pit_game_active() and str(node.upgrade.sim_key).begins_with("xp:"):
        wallet_after_sale = OPEN_PIT_PROGRESS_SCRIPT.get_xp_wallet() + refund_amount
    elif Util.is_open_pit_game_active() and str(node.upgrade.sim_key).begins_with("core:"):
        wallet_after_sale = OPEN_PIT_PROGRESS_SCRIPT.get_core_wallet() + refund_amount
    elif Util.is_open_pit_orbit_game_active() and str(node.upgrade.sim_key).begins_with("core:"):
        wallet_after_sale = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.get_core_wallet() + refund_amount
    else:
        var current_money: int = int(Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY))
        wallet_after_sale = current_money + refund_amount
    var new_tier: int = max(0, int(node.upgrade.current_tier) - 1)
    var new_level: int = max(0, int(node.upgrade.sim_level) + new_tier - 1)

    if Util.is_mining_game_active():
        MINING_PROGRESS_SCRIPT.apply_tree_sale(node.upgrade.sim_key, new_level, wallet_after_sale)
    elif Util.is_open_pit_game_active():
        OPEN_PIT_PROGRESS_SCRIPT.apply_tree_sale(node.upgrade.sim_key, new_level, wallet_after_sale)
    elif Util.is_open_pit_orbit_game_active():
        OPEN_PIT_ORBIT_PROGRESS_SCRIPT.apply_tree_sale(node.upgrade.sim_key, new_level, wallet_after_sale)
    elif Util.is_red_sky_game_active():
        RED_SKY_PROGRESS_SCRIPT.apply_tree_sale(node.upgrade.sim_key, new_level, wallet_after_sale)
    elif Util.is_turkey_game_active():
        TURKEY_PROGRESS_SCRIPT.apply_tree_sale(node.upgrade.sim_key, new_level, wallet_after_sale)
    elif Util.is_reel_into_darkness_game_active():
        REEL_INTO_DARKNESS_PROGRESS_SCRIPT.apply_tree_sale(node.upgrade.sim_key, new_level, wallet_after_sale)
    else:
        SaveHandler.fishing_currency = wallet_after_sale
        SaveHandler.set_fishing_upgrade_level(node.upgrade.sim_key, new_level)
        SaveHandler.save_fishing_progress()

    _reload_simulation_upgrade_tree_from_save()
    update()

func _refresh_editor_crt_button_text() -> void:
    if editor_crt_toggle_button == null:
        return
    editor_crt_toggle_button.visible = Util.is_vanguard_game_active()
    editor_crt_toggle_button.text = tr("CRT Preview: %s") % [tr("On") if editor_crt_preview_enabled else tr("Off")]

func _refresh_editor_demo_toggle_button_text() -> void:
    if editor_demo_toggle_button == null:
        return
    var demo_on: bool = bool(ProjectSettings.get_setting(DEMO_PROJECT_SETTING, false))
    editor_demo_toggle_button.text = "%s: %s" % [tr("UPGRADE_DEMO_MODE"), tr("On") if demo_on else tr("Off")]
    _refresh_editor_exit_demo_button()

func _setup_editor_exit_demo_button() -> void:
    if not OS.has_feature("editor"):
        return
    if editor_exit_demo_button != null and is_instance_valid(editor_exit_demo_button):
        _refresh_editor_exit_demo_button()
        return
    editor_exit_demo_button = Button.new()
    editor_exit_demo_button.name = "EditorExitDemoButton"
    editor_exit_demo_button.anchor_left = 0.5
    editor_exit_demo_button.anchor_top = 0.0
    editor_exit_demo_button.anchor_right = 0.5
    editor_exit_demo_button.anchor_bottom = 0.0
    editor_exit_demo_button.offset_left = 260.0
    editor_exit_demo_button.offset_top = 74.0
    editor_exit_demo_button.offset_right = 470.0
    editor_exit_demo_button.offset_bottom = 112.0
    editor_exit_demo_button.z_index = 210
    editor_exit_demo_button.mouse_filter = Control.MOUSE_FILTER_STOP
    editor_exit_demo_button.text = "EXIT DEMO MODE"
    editor_exit_demo_button.pressed.connect(_on_editor_exit_demo_pressed)
    %CanvasLayer2.add_child(editor_exit_demo_button)
    _refresh_editor_exit_demo_button()

func _refresh_editor_exit_demo_button() -> void:
    if editor_exit_demo_button == null or not is_instance_valid(editor_exit_demo_button):
        return
    editor_exit_demo_button.visible = OS.has_feature("editor") and _is_demo_mode_enabled() and not _is_any_popup_visible()

func _refresh_editor_regenerate_planet_button() -> void:
    if editor_regenerate_planet_button == null or not is_instance_valid(editor_regenerate_planet_button):
        return
    var is_orbit_mode: bool = Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active()
    editor_regenerate_planet_button.visible = is_orbit_mode
    editor_regenerate_planet_button.disabled = not is_orbit_mode
    editor_regenerate_planet_button.text = "REGENERATE PLANET"

func _on_editor_demo_toggle_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    var new_demo: bool = not bool(ProjectSettings.get_setting(DEMO_PROJECT_SETTING, false))
    _set_editor_demo_mode(new_demo)

func _on_editor_exit_demo_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    _set_editor_demo_mode(false)

func _set_editor_demo_mode(enabled: bool) -> void:
    if not OS.has_feature("editor"):
        return
    ProjectSettings.set_setting(DEMO_PROJECT_SETTING, enabled)
    _refresh_editor_demo_toggle_button_text()
    _refresh_demo_mode_label_visibility()
    _refresh_editor_exit_demo_button()
    _setup_wishlist_button()
    if tech_tree != null and is_instance_valid(tech_tree):
        _ensure_tree_initialized(true)
        tech_tree.update_active()
    _update_go_again_button_state()
    update()

func _on_editor_crt_toggle_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    editor_crt_preview_enabled = not editor_crt_preview_enabled
    _refresh_editor_crt_button_text()
    _refresh_mining_crt_overlay()

func _on_editor_regenerate_planet_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    if Util.is_open_pit_game_active():
        OPEN_PIT_PROGRESS_SCRIPT.regenerate_planet_state()
        update()
        return
    if not Util.is_open_pit_orbit_game_active():
        return
    OPEN_PIT_ORBIT_PROGRESS_SCRIPT.regenerate_planet_state()
    update()

func _setup_editor_center_offset_controls() -> void:
    if not OS.has_feature("editor"):
        return
    if editor_center_offset_controls != null and is_instance_valid(editor_center_offset_controls):
        editor_center_offset_controls.hide()
        return

    editor_center_offset_controls = VBoxContainer.new()
    editor_center_offset_controls.name = "EditorCenterOffsetControls"
    editor_center_offset_controls.anchor_left = 0.0
    editor_center_offset_controls.anchor_top = 0.0
    editor_center_offset_controls.anchor_right = 0.0
    editor_center_offset_controls.anchor_bottom = 0.0
    editor_center_offset_controls.offset_left = 16.0
    editor_center_offset_controls.offset_top = 120.0
    editor_center_offset_controls.offset_right = 240.0
    editor_center_offset_controls.offset_bottom = 260.0
    editor_center_offset_controls.z_index = 210
    editor_center_offset_controls.mouse_filter = Control.MOUSE_FILTER_STOP
    editor_center_offset_controls.visible = false

    editor_center_offset_label = Label.new()
    editor_center_offset_label.text = tr("Center Offset")
    editor_center_offset_controls.add_child(editor_center_offset_label)

    var x_row := HBoxContainer.new()
    editor_center_offset_controls.add_child(x_row)

    editor_center_offset_x_minus_button = Button.new()
    editor_center_offset_x_minus_button.text = tr("X -20")
    editor_center_offset_x_minus_button.pressed.connect(_on_editor_center_offset_pressed.bind(Vector2(-20.0, 0.0)))
    x_row.add_child(editor_center_offset_x_minus_button)

    editor_center_offset_x_plus_button = Button.new()
    editor_center_offset_x_plus_button.text = tr("X +20")
    editor_center_offset_x_plus_button.pressed.connect(_on_editor_center_offset_pressed.bind(Vector2(20.0, 0.0)))
    x_row.add_child(editor_center_offset_x_plus_button)

    var x_small_row := HBoxContainer.new()
    editor_center_offset_controls.add_child(x_small_row)

    editor_center_offset_x_minus_small_button = Button.new()
    editor_center_offset_x_minus_small_button.text = tr("X -5")
    editor_center_offset_x_minus_small_button.pressed.connect(_on_editor_center_offset_pressed.bind(Vector2(-5.0, 0.0)))
    x_small_row.add_child(editor_center_offset_x_minus_small_button)

    editor_center_offset_x_plus_small_button = Button.new()
    editor_center_offset_x_plus_small_button.text = tr("X +5")
    editor_center_offset_x_plus_small_button.pressed.connect(_on_editor_center_offset_pressed.bind(Vector2(5.0, 0.0)))
    x_small_row.add_child(editor_center_offset_x_plus_small_button)

    var y_row := HBoxContainer.new()
    editor_center_offset_controls.add_child(y_row)

    editor_center_offset_y_minus_button = Button.new()
    editor_center_offset_y_minus_button.text = tr("Y -20")
    editor_center_offset_y_minus_button.pressed.connect(_on_editor_center_offset_pressed.bind(Vector2(0.0, -20.0)))
    y_row.add_child(editor_center_offset_y_minus_button)

    editor_center_offset_y_plus_button = Button.new()
    editor_center_offset_y_plus_button.text = tr("Y +20")
    editor_center_offset_y_plus_button.pressed.connect(_on_editor_center_offset_pressed.bind(Vector2(0.0, 20.0)))
    y_row.add_child(editor_center_offset_y_plus_button)

    var y_small_row := HBoxContainer.new()
    editor_center_offset_controls.add_child(y_small_row)

    editor_center_offset_y_minus_small_button = Button.new()
    editor_center_offset_y_minus_small_button.text = tr("Y -5")
    editor_center_offset_y_minus_small_button.pressed.connect(_on_editor_center_offset_pressed.bind(Vector2(0.0, -5.0)))
    y_small_row.add_child(editor_center_offset_y_minus_small_button)

    editor_center_offset_y_plus_small_button = Button.new()
    editor_center_offset_y_plus_small_button.text = tr("Y +5")
    editor_center_offset_y_plus_small_button.pressed.connect(_on_editor_center_offset_pressed.bind(Vector2(0.0, 5.0)))
    y_small_row.add_child(editor_center_offset_y_plus_small_button)

    editor_center_offset_rebuild_button = Button.new()
    editor_center_offset_rebuild_button.text = tr("Rebuild With Offset")
    editor_center_offset_rebuild_button.pressed.connect(_on_editor_center_offset_rebuild_pressed)
    editor_center_offset_controls.add_child(editor_center_offset_rebuild_button)

    %CanvasLayer2.add_child(editor_center_offset_controls)
    _refresh_editor_center_offset_label()

func _refresh_editor_center_offset_label() -> void:
    if editor_center_offset_label == null:
        return
    editor_center_offset_label.text = tr("Center Offset  X: %d  Y: %d") % [int(editor_center_offset.x), int(editor_center_offset.y)]

func _on_editor_center_offset_pressed(offset_delta: Vector2) -> void:
    if not OS.has_feature("editor"):
        return
    editor_center_offset += offset_delta
    _apply_editor_center_offset()
    _refresh_editor_center_offset_label()
    print("Upgrade tree center offset: x=%d y=%d" % [int(editor_center_offset.x), int(editor_center_offset.y)])

func _apply_editor_center_offset() -> void:
    if tech_tree == null or not is_instance_valid(tech_tree):
        return
    if not tech_tree.has_method("set_debug_center_offset"):
        return
    tech_tree.call("set_debug_center_offset", editor_center_offset)
    if tech_tree.selected_node != null and is_instance_valid(tech_tree.selected_node):
        tech_tree.set_tech_tree_pos(-tech_tree.selected_node.position)
    else:
        tech_tree.set_tech_tree_pos(Vector2.ZERO)

func _recenter_tech_tree_on_core() -> void:
    if tech_tree == null or not is_instance_valid(tech_tree):
        return
    if (Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active()) and tech_tree.has_method("frame_all_nodes"):
        tech_tree.call("frame_all_nodes")
        return
    if tech_tree.has_method("recenter_on_core"):
        tech_tree.call("recenter_on_core")

func _should_recenter_upgrade_tree_on_core() -> bool:
    return Util.is_mining_game_active() or Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active() or Util.is_red_sky_game_active() or Util.is_turkey_game_active() or Util.is_reel_into_darkness_game_active()

func _on_editor_center_offset_rebuild_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    _apply_editor_center_offset()
    print("Rebuilding upgrade tree with offset: x=%d y=%d" % [int(editor_center_offset.x), int(editor_center_offset.y)])
    _reload_simulation_upgrade_tree_from_save()

func _refresh_editor_cash_button_text() -> void:
    if editor_add_cash_button == null:
        return
    editor_add_cash_button.text = _trf("UPGRADE_EDITOR_ADD_CASH", [editor_add_cash_amount])
    if editor_add_xp_button != null:
        editor_add_xp_button.visible = Util.is_open_pit_game_active()
        editor_add_xp_button.text = _trf("UPGRADE_EDITOR_ADD_XP", [editor_add_xp_amount])
    if editor_add_core_button != null:
        editor_add_core_button.visible = Util.is_open_pit_game_active()
        editor_add_core_button.text = _trf("UPGRADE_EDITOR_ADD_ROOT_KEYS", [editor_add_core_amount])
    if editor_auto_buy_button != null:
        editor_auto_buy_button.visible = Util.is_open_pit_game_active()
        editor_auto_buy_button.text = "AUTO BUY"

func _on_editor_add_cash_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, editor_add_cash_amount)
    editor_add_cash_amount *= 2
    _refresh_editor_cash_button_text()
    update()

func _on_editor_add_xp_pressed() -> void:
    if not OS.has_feature("editor") or not Util.is_open_pit_game_active():
        return
    var data: Dictionary = OPEN_PIT_PROGRESS_SCRIPT.load_data()
    data["xp_currency"] = max(0, int(data.get("xp_currency", 0)) + editor_add_xp_amount)
    OPEN_PIT_PROGRESS_SCRIPT.save_data(data)
    editor_add_xp_amount *= 2
    _refresh_editor_cash_button_text()
    _reload_simulation_upgrade_tree_from_save()
    update()

func _on_editor_add_core_pressed() -> void:
    if not OS.has_feature("editor") or not Util.is_open_pit_game_active():
        return
    var data: Dictionary = OPEN_PIT_PROGRESS_SCRIPT.load_data()
    data["core_currency"] = max(0, int(data.get("core_currency", 0)) + editor_add_core_amount)
    OPEN_PIT_PROGRESS_SCRIPT.save_data(data)
    editor_add_core_amount *= 2
    _refresh_editor_cash_button_text()
    _reload_simulation_upgrade_tree_from_save()
    update()

func _on_editor_auto_buy_pressed() -> void:
    if not OS.has_feature("editor") or not Util.is_open_pit_game_active():
        return
    var result: Dictionary = _open_pit_editor_auto_buy_all_affordable()
    if int(result.get("count", 0)) > 0:
        _reload_simulation_upgrade_tree_from_save()
    _refresh_editor_cash_button_text()
    _refresh_bottom_wallet_display()
    _refresh_mining_time_label()
    update()

func _open_pit_editor_auto_buy_all_affordable() -> Dictionary:
    var bought: Array[Dictionary] = []
    var data: Dictionary = OPEN_PIT_PROGRESS_SCRIPT.load_data()
    var cash_catalog: Array[Dictionary] = OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_upgrade_catalog()
    var xp_catalog: Array[Dictionary] = OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_xp_upgrade_catalog()
    var core_catalog: Array[Dictionary] = OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_core_upgrade_catalog()
    var pass_count := 0
    var bought_this_pass := true
    while bought_this_pass and pass_count < 128:
        bought_this_pass = false
        pass_count += 1
        for entry in cash_catalog:
            if _open_pit_try_buy_upgrade_in_data(data, str(entry.get("id", "")), "cash", bought):
                bought_this_pass = true
        for entry in xp_catalog:
            if _open_pit_try_buy_upgrade_in_data(data, str(entry.get("id", "")), "xp", bought):
                bought_this_pass = true
        for entry in core_catalog:
            var upgrade_id := str(entry.get("id", ""))
            if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_reward_core_upgrade(upgrade_id):
                continue
            if _open_pit_try_buy_upgrade_in_data(data, upgrade_id, "core", bought):
                bought_this_pass = true
    _open_pit_append_auto_buy_chat(data, bought)
    OPEN_PIT_PROGRESS_SCRIPT.save_data(data)
    return {"count": bought.size(), "purchases": bought}

func _open_pit_try_buy_upgrade_in_data(data: Dictionary, upgrade_id: String, currency_kind: String, bought: Array[Dictionary]) -> bool:
    if upgrade_id == "":
        return false
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_demo_upgrade_hidden(upgrade_id):
        return false
    var current_level := _open_pit_owned_level(data, upgrade_id)
    var max_level := _open_pit_max_level(upgrade_id)
    if current_level >= max_level:
        return false
    if not _open_pit_dependency_met(data, upgrade_id):
        return false
    var cost := _open_pit_cost_for(upgrade_id, current_level)
    var wallet_key := _open_pit_wallet_key(currency_kind)
    var wallet := int(data.get(wallet_key, 0))
    if wallet < cost:
        return false
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_core_upgrade(upgrade_id):
        var core_upgrade_id := upgrade_id.trim_prefix(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.CORE_PREFIX)
        var purchased: Array = data.get("purchased_core_upgrades", []).duplicate()
        if core_upgrade_id not in purchased:
            purchased.append(core_upgrade_id)
        data["purchased_core_upgrades"] = purchased
        if core_upgrade_id == "planet_mastery":
            data["planet_mastery_unlocked"] = true
            data["free_planet_mode"] = true
        elif core_upgrade_id == "center_unlock":
            data["free_planet_mode"] = false
    elif OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_xp_upgrade(upgrade_id):
        var xp_upgrades: Dictionary = data.get("xp_upgrades", {}).duplicate(true)
        xp_upgrades[upgrade_id] = current_level + 1
        data["xp_upgrades"] = xp_upgrades
    else:
        var upgrades: Dictionary = data.get("upgrades", {}).duplicate(true)
        upgrades[upgrade_id] = current_level + 1
        data["upgrades"] = upgrades
        OPEN_PIT_PROGRESS_SCRIPT.BALANCE.refresh_depth_unlocks(data)
    data[wallet_key] = max(0, wallet - cost)
    bought.append({
        "id": upgrade_id,
        "level": current_level + 1,
        "currency": currency_kind,
        "cost": cost,
    })
    return true

func _open_pit_owned_level(data: Dictionary, upgrade_id: String) -> int:
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_core_upgrade(upgrade_id):
        var trimmed := upgrade_id.trim_prefix(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.CORE_PREFIX)
        return 1 if trimmed in Array(data.get("purchased_core_upgrades", [])) else 0
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_xp_upgrade(upgrade_id):
        return int(Dictionary(data.get("xp_upgrades", {})).get(upgrade_id, 0))
    return int(Dictionary(data.get("upgrades", {})).get(upgrade_id, 0))

func _open_pit_max_level(upgrade_id: String) -> int:
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_core_upgrade(upgrade_id):
        return int(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.CORE_UPGRADES.get(upgrade_id.trim_prefix(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.CORE_PREFIX), {}).get("max_level", 1))
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_xp_upgrade(upgrade_id):
        return OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_xp_upgrade_max_level(upgrade_id)
    return OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_upgrade_max_level(upgrade_id)

func _open_pit_cost_for(upgrade_id: String, current_level: int) -> int:
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_core_upgrade(upgrade_id):
        return OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_core_upgrade_cost(upgrade_id, current_level)
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_xp_upgrade(upgrade_id):
        return OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_xp_upgrade_cost(upgrade_id, current_level)
    return OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_upgrade_cost(upgrade_id, current_level)

func _open_pit_dependency_met(data: Dictionary, upgrade_id: String) -> bool:
    var dependency := ""
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_core_upgrade(upgrade_id):
        dependency = OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_core_upgrade_dependency(upgrade_id)
    elif OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_xp_upgrade(upgrade_id):
        dependency = OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_xp_upgrade_dependency(upgrade_id)
    else:
        dependency = OPEN_PIT_PROGRESS_SCRIPT.BALANCE.get_upgrade_dependency(upgrade_id)
    if dependency == "" or dependency == "start":
        return true
    return _open_pit_owned_level(data, dependency) > 0

func _open_pit_wallet_key(currency_kind: String) -> String:
    match currency_kind:
        "xp":
            return "xp_currency"
        "core":
            return "core_currency"
        _:
            return "wallet"

func _open_pit_upgrade_label(upgrade_id: String) -> String:
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_core_upgrade(upgrade_id):
        var core_id := upgrade_id.trim_prefix(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.CORE_PREFIX)
        return str(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.CORE_UPGRADES.get(core_id, {}).get("label", core_id))
    if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_xp_upgrade(upgrade_id):
        var xp_id := upgrade_id.trim_prefix(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.XP_PREFIX)
        return str(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.XP_UPGRADES.get(xp_id, {}).get("label", xp_id))
    return str(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.RAW_NODE_DATA.get(upgrade_id, {}).get("label", upgrade_id))

func _open_pit_purchase_type_label(currency_kind: String) -> String:
    match currency_kind:
        "cash":
            return "Cash"
        "xp":
            return "XP"
        "core":
            return "Root"
        _:
            return currency_kind.capitalize()

func _open_pit_format_purchase_cost(currency_kind: String, cost: int) -> String:
    match currency_kind:
        "cash":
            return "$%d" % cost
        "xp":
            return "%d XP" % cost
        "core":
            return "%d root" % cost
        _:
            return "%d %s" % [cost, currency_kind]

func _open_pit_append_auto_buy_chat(data: Dictionary, bought: Array[Dictionary]) -> void:
    var chat_log: Array = data.get("chat_log", []).duplicate()
    if bought.is_empty():
        chat_log.append("[color=#8fdcff]AUTO BUY[/color] No affordable upgrades found.")
        data["chat_log"] = chat_log
        return
    chat_log.append("[color=#8fdcff]AUTO BUY[/color] Bought %d upgrade%s:" % [bought.size(), "" if bought.size() == 1 else "s"])
    for currency_kind in ["cash", "xp", "core"]:
        for purchase in bought:
            if str(purchase.get("currency", "")) != currency_kind:
                continue
            var upgrade_id := str(purchase.get("id", ""))
            var level := int(purchase.get("level", 0))
            var cost := int(purchase.get("cost", 0))
            chat_log.append("%s  %s  %s  Lv %d" % [
                _open_pit_purchase_type_label(currency_kind),
                _open_pit_format_purchase_cost(currency_kind, cost),
                _open_pit_upgrade_label(upgrade_id),
                level,
            ])
    data["chat_log"] = chat_log

func _on_editor_reset_add_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    editor_add_cash_amount = 1000
    editor_add_xp_amount = 100
    editor_add_core_amount = 1
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
    reset_progress_button.text = tr("UPGRADE_RESET_PROGRESS")
    reset_progress_button.pressed.connect(_on_reset_progress_button_pressed)
    %CanvasLayer2.add_child(reset_progress_button)

    reset_progress_confirm_dialog = ConfirmationDialog.new()
    reset_progress_confirm_dialog.name = "ResetProgressConfirmDialog"
    reset_progress_confirm_dialog.title = tr("UPGRADE_CONFIRM_RESET_TITLE")
    reset_progress_confirm_dialog.dialog_text = tr("UPGRADE_CONFIRM_RESET_BODY")
    reset_progress_confirm_dialog.confirmed.connect(_on_reset_progress_confirmed)
    _bind_demo_label_visibility_to_popup(reset_progress_confirm_dialog)
    var ok_button: Button = reset_progress_confirm_dialog.get_ok_button()
    if ok_button != null:
        ok_button.text = tr("UI_YES")
    var cancel_button: Button = reset_progress_confirm_dialog.get_cancel_button()
    if cancel_button != null:
        cancel_button.text = tr("UI_NO")
    %CanvasLayer2.add_child(reset_progress_confirm_dialog)

    legacy_reset_dialog = ConfirmationDialog.new()
    legacy_reset_dialog.name = "LegacyResetDialog"
    legacy_reset_dialog.title = tr("UPGRADE_PROGRESS_RESET_REQUIRED")
    legacy_reset_dialog.dialog_text = tr("UPGRADE_LEGACY_RESET_BODY")
    legacy_reset_dialog.confirmed.connect(_on_legacy_reset_confirmed)
    legacy_reset_dialog.canceled.connect(_on_legacy_reset_canceled)
    _bind_demo_label_visibility_to_popup(legacy_reset_dialog)
    var continue_button: Button = legacy_reset_dialog.get_ok_button()
    if continue_button != null:
        continue_button.text = tr("UI_CONTINUE")
    var legacy_cancel_button: Button = legacy_reset_dialog.get_cancel_button()
    if legacy_cancel_button != null:
        legacy_cancel_button.hide()
    %CanvasLayer2.add_child(legacy_reset_dialog)
    _refresh_localized_text()

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
    version_label.text = _trf("UPGRADE_VERSION_LABEL", [SaveHandler.FISHING_SAVE_VERSION])
    %CanvasLayer2.add_child(version_label)

func _show_legacy_reset_dialog_if_needed() -> void:
    if _legacy_reset_dialog_shown:
        return
    if legacy_reset_dialog == null:
        return
    if not Util.is_vanguard_game_active():
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
    if not Util.is_vanguard_game_active():
        return
    if SaveHandler.needs_fishing_legacy_reset():
        legacy_reset_dialog.call_deferred("popup_centered")

func _perform_progress_reset() -> void:
    if Util.is_mining_game_active():
        MINING_PROGRESS_SCRIPT.reset_progress()
    elif Util.is_open_pit_game_active():
        OPEN_PIT_PROGRESS_SCRIPT.reset_progress()
    elif Util.is_open_pit_orbit_game_active():
        OPEN_PIT_ORBIT_PROGRESS_SCRIPT.reset_progress()
    elif Util.is_red_sky_game_active():
        RED_SKY_PROGRESS_SCRIPT.reset_progress()
    elif Util.is_turkey_game_active():
        TURKEY_PROGRESS_SCRIPT.reset_progress()
    elif Util.is_reel_into_darkness_game_active():
        REEL_INTO_DARKNESS_PROGRESS_SCRIPT.reset_progress()
    else:
        SaveHandler.reset_fishing_progress()
        SaveHandler.save_fishing_progress()
    editor_add_cash_amount = 1000
    editor_add_xp_amount = 100
    editor_add_core_amount = 1
    _refresh_editor_cash_button_text()

    if Global.global_resoruce_manager != null:
        Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.MONEY)

    _reload_simulation_upgrade_tree_from_save()
    update()
    _update_go_again_button_state()
    _refresh_mining_time_label()
    _refresh_leaderboard_panel()

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

    if Util.is_mining_game_active():
        var data: Dictionary = MINING_PROGRESS_SCRIPT.load_data()
        data["upgrades"] = {}
        for key_variant: Variant in max_level_by_key.keys():
            var key: String = str(key_variant)
            data["upgrades"][key] = int(max_level_by_key[key])
        data["deepest_level_unlocked"] = MINING_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL
        data["selected_depth_level"] = MINING_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL
        MINING_PROGRESS_SCRIPT.save_data(data)
    elif Util.is_open_pit_game_active():
        var open_pit_data: Dictionary = OPEN_PIT_PROGRESS_SCRIPT.load_data()
        open_pit_data["upgrades"] = {}
        open_pit_data["xp_upgrades"] = {}
        open_pit_data["purchased_core_upgrades"] = []
        for key_variant: Variant in max_level_by_key.keys():
            var open_pit_key: String = str(key_variant)
            if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_demo_upgrade_hidden(open_pit_key):
                continue
            var open_pit_level: int = int(max_level_by_key[open_pit_key])
            if open_pit_key.begins_with(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.XP_PREFIX):
                open_pit_data["xp_upgrades"][open_pit_key] = open_pit_level
            elif open_pit_key.begins_with(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.CORE_PREFIX):
                if OPEN_PIT_PROGRESS_SCRIPT.BALANCE.is_reward_core_upgrade(open_pit_key):
                    continue
                var purchased_core: Array = open_pit_data.get("purchased_core_upgrades", [])
                purchased_core.append(open_pit_key.trim_prefix(OPEN_PIT_PROGRESS_SCRIPT.BALANCE.CORE_PREFIX))
                open_pit_data["purchased_core_upgrades"] = purchased_core
            else:
                open_pit_data["upgrades"][open_pit_key] = open_pit_level
        open_pit_data["core_currency"] = 999
        OPEN_PIT_PROGRESS_SCRIPT.BALANCE.refresh_depth_unlocks(open_pit_data)
        open_pit_data["selected_depth_level"] = int(open_pit_data.get("deepest_level_unlocked", OPEN_PIT_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL))
        OPEN_PIT_PROGRESS_SCRIPT.save_data(open_pit_data)
    elif Util.is_open_pit_orbit_game_active():
        var orbit_data: Dictionary = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.load_data()
        orbit_data["upgrades"] = {}
        for key_variant: Variant in max_level_by_key.keys():
            var orbit_key: String = str(key_variant)
            orbit_data["upgrades"][orbit_key] = int(max_level_by_key[orbit_key])
        orbit_data["deepest_level_unlocked"] = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL
        orbit_data["selected_depth_level"] = OPEN_PIT_ORBIT_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL
        OPEN_PIT_ORBIT_PROGRESS_SCRIPT.save_data(orbit_data)
    elif Util.is_red_sky_game_active():
        var red_sky_data: Dictionary = RED_SKY_PROGRESS_SCRIPT.load_data()
        red_sky_data["meta_upgrades"] = {}
        for key_variant: Variant in max_level_by_key.keys():
            var key: String = str(key_variant)
            red_sky_data["meta_upgrades"][key] = int(max_level_by_key[key])
        RED_SKY_PROGRESS_SCRIPT.save_data(red_sky_data)
    elif Util.is_turkey_game_active():
        var turkey_data: Dictionary = TURKEY_PROGRESS_SCRIPT.load_data()
        turkey_data["meta_upgrades"] = {}
        for key_variant: Variant in max_level_by_key.keys():
            var key: String = str(key_variant)
            turkey_data["meta_upgrades"][key] = int(max_level_by_key[key])
        TURKEY_PROGRESS_SCRIPT.save_data(turkey_data)
    elif Util.is_reel_into_darkness_game_active():
        var reel_data: Dictionary = REEL_INTO_DARKNESS_PROGRESS_SCRIPT.load_data()
        reel_data["meta_upgrades"] = {}
        for key_variant: Variant in max_level_by_key.keys():
            var key: String = str(key_variant)
            reel_data["meta_upgrades"][key] = int(max_level_by_key[key])
        REEL_INTO_DARKNESS_PROGRESS_SCRIPT.save_data(reel_data)
    else:
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
    _loaded_tree_locale = ""

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
    settings_button.text = tr("UI_SETTINGS")
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
    _bind_demo_label_visibility_to_popup(settings_panel)
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

    settings_title_label = Label.new()
    settings_title_label.text = tr("UI_SETTINGS_TITLE")
    settings_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    settings_title_label.add_theme_font_size_override("font_size", 46)
    vbox.add_child(settings_title_label)

    settings_content = SETTINGS_SCENE.instantiate() as Settings
    if settings_content != null:
        settings_content.name = "SettingsContent"
        settings_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        settings_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
        settings_content.scale = Vector2(1.7, 1.7)
        vbox.add_child(settings_content)

    settings_main_menu_button = Button.new()
    settings_main_menu_button.name = "SettingsMainMenuButton"
    settings_main_menu_button.focus_mode = Control.FOCUS_NONE
    settings_main_menu_button.custom_minimum_size = Vector2(0, 120)
    settings_main_menu_button.add_theme_font_size_override("font_size", 30)
    settings_main_menu_button.pressed.connect(_on_settings_main_menu_pressed)
    _style_utility_button(settings_main_menu_button)
    vbox.add_child(settings_main_menu_button)

    settings_quit_button = Button.new()
    settings_quit_button.name = "SettingsQuitButton"
    settings_quit_button.focus_mode = Control.FOCUS_NONE
    settings_quit_button.custom_minimum_size = Vector2(0, 120)
    settings_quit_button.add_theme_font_size_override("font_size", 30)
    settings_quit_button.pressed.connect(_on_settings_quit_pressed)
    _style_utility_button(settings_quit_button)
    vbox.add_child(settings_quit_button)

    settings_close_button = Button.new()
    settings_close_button.name = "SettingsCloseButton"
    settings_close_button.text = tr("UI_BACK")
    settings_close_button.focus_mode = Control.FOCUS_NONE
    settings_close_button.custom_minimum_size = Vector2(0, 150)
    settings_close_button.add_theme_font_size_override("font_size", 34)
    settings_close_button.pressed.connect(_on_settings_close_pressed)
    _style_utility_button(settings_close_button)
    vbox.add_child(settings_close_button)

    _refresh_localized_text()
    _update_return_to_main_menu_button_visibility()
    _update_upgrade_settings_exit_buttons_layout()

func _update_upgrade_settings_exit_buttons_layout() -> void:
    if settings_main_menu_button == null or not is_instance_valid(settings_main_menu_button):
        return
    if settings_quit_button == null or not is_instance_valid(settings_quit_button):
        return
    if settings_close_button == null or not is_instance_valid(settings_close_button):
        return
    var trio := Util.is_all_high_level_mode_active()
    if not trio:
        settings_main_menu_button.custom_minimum_size = Vector2(0.0, SETTINGS_EXIT_MAIN_MENU_MIN_H_DEFAULT)
        settings_main_menu_button.add_theme_font_size_override("font_size", SETTINGS_EXIT_MAIN_MENU_FONT_DEFAULT)
        settings_quit_button.custom_minimum_size = Vector2(0.0, SETTINGS_EXIT_QUIT_MIN_H_DEFAULT)
        settings_quit_button.add_theme_font_size_override("font_size", SETTINGS_EXIT_QUIT_FONT_DEFAULT)
        settings_close_button.custom_minimum_size = Vector2(0.0, SETTINGS_EXIT_BACK_MIN_H_DEFAULT)
        settings_close_button.add_theme_font_size_override("font_size", SETTINGS_EXIT_BACK_FONT_DEFAULT)
        return
    var viewport: Viewport = get_viewport()
    var vp_h: float = viewport.get_visible_rect().size.y if viewport != null else 1080.0
    var min_h: float = SETTINGS_EXIT_BUTTON_MIN_H_COMPACT
    var back_h: float = SETTINGS_EXIT_BACK_MIN_H_COMPACT
    var btn_font: int = SETTINGS_EXIT_BUTTON_FONT_COMPACT
    var back_font: int = SETTINGS_EXIT_BACK_FONT_COMPACT
    if vp_h < SETTINGS_EXIT_VIEWPORT_H_EXTRA_COMPACT:
        min_h = SETTINGS_EXIT_BUTTON_MIN_H_EXTRA_COMPACT
        back_h = SETTINGS_EXIT_BACK_MIN_H_EXTRA_COMPACT
        btn_font = SETTINGS_EXIT_BUTTON_FONT_EXTRA_COMPACT
        back_font = SETTINGS_EXIT_BACK_FONT_EXTRA_COMPACT
    settings_main_menu_button.custom_minimum_size = Vector2(0.0, min_h)
    settings_main_menu_button.add_theme_font_size_override("font_size", btn_font)
    settings_quit_button.custom_minimum_size = Vector2(0.0, min_h)
    settings_quit_button.add_theme_font_size_override("font_size", btn_font)
    settings_close_button.custom_minimum_size = Vector2(0.0, back_h)
    settings_close_button.add_theme_font_size_override("font_size", back_font)

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

func _update_upgrade_top_button_positions() -> void:
    var viewport: Viewport = get_viewport()
    if viewport == null:
        return
    var vertical_shift := viewport.get_visible_rect().size.y * UPGRADE_TOP_BUTTON_VERTICAL_SHIFT_RATIO
    if return_to_main_menu_button != null and is_instance_valid(return_to_main_menu_button):
        return_to_main_menu_button.offset_top = 16.0 + vertical_shift
        return_to_main_menu_button.offset_bottom = 104.0 + vertical_shift
    if settings_button != null and is_instance_valid(settings_button):
        settings_button.offset_top = 16.0 + vertical_shift
        settings_button.offset_bottom = 104.0 + vertical_shift
    if open_pit_chat_button != null and is_instance_valid(open_pit_chat_button):
        open_pit_chat_button.offset_top = 112.0 + vertical_shift
        open_pit_chat_button.offset_bottom = 172.0 + vertical_shift
    if open_pit_chat_panel != null and is_instance_valid(open_pit_chat_panel):
        open_pit_chat_panel.offset_top = 180.0 + vertical_shift
        open_pit_chat_panel.offset_bottom = 612.0 + vertical_shift
func _on_viewport_size_changed() -> void:
    _update_upgrade_top_button_positions()
    _update_leaderboard_panel_position()
    _update_upgrade_settings_exit_buttons_layout()
    if tech_tree != null and is_instance_valid(tech_tree):
        tech_tree.clamp_tech_tree_pos()

func _setup_return_to_main_menu_button() -> void:
    if return_to_main_menu_button != null and is_instance_valid(return_to_main_menu_button):
        return
    return_to_main_menu_button = Button.new()
    return_to_main_menu_button.name = "ReturnToMainMenuButton"
    return_to_main_menu_button.anchor_left = 0.0
    return_to_main_menu_button.anchor_top = 0.0
    return_to_main_menu_button.anchor_right = 0.0
    return_to_main_menu_button.anchor_bottom = 0.0
    return_to_main_menu_button.offset_left = 72.0
    return_to_main_menu_button.offset_top = 16.0
    return_to_main_menu_button.offset_right = 256.0
    return_to_main_menu_button.offset_bottom = 104.0
    return_to_main_menu_button.z_index = 210
    return_to_main_menu_button.focus_mode = Control.FOCUS_NONE
    return_to_main_menu_button.custom_minimum_size = Vector2(184, 88)
    return_to_main_menu_button.add_theme_font_size_override("font_size", 26)
    return_to_main_menu_button.pressed.connect(_on_return_to_main_menu_pressed)
    _style_utility_button(return_to_main_menu_button)
    %CanvasLayer2.add_child(return_to_main_menu_button)
    _refresh_localized_text()
    _update_return_to_main_menu_button_visibility()
    _update_upgrade_top_button_positions()

func _update_return_to_main_menu_button_visibility() -> void:
    var show_hub_main_menu := Util.is_all_high_level_mode_active()
    if return_to_main_menu_button != null and is_instance_valid(return_to_main_menu_button):
        return_to_main_menu_button.visible = show_hub_main_menu
    if settings_main_menu_button != null and is_instance_valid(settings_main_menu_button):
        settings_main_menu_button.visible = show_hub_main_menu
    _update_upgrade_settings_exit_buttons_layout()

func _on_return_to_main_menu_pressed() -> void:
    _hide_settings_panel()
    _hide_continue_locked_panel()
    if _is_reel_depth_tier_dialog_open():
        _on_reel_depth_tier_cancel_pressed()
    if _is_battle_level_choice_open():
        _on_battle_level_choice_cancel_pressed()
    _refresh_virtual_cursor_state()
    Global.clear_upgrade_tree_cache()
    SceneChanger.change_to_new_scene(Util.get_game_hub_scene_path(), null, 0.2)

func _is_settings_open() -> bool:
    return settings_panel != null and is_instance_valid(settings_panel) and settings_panel.visible

func _on_settings_button_pressed() -> void:
    if settings_content != null:
        settings_content.show_screen()
        settings_content.refresh_from_save()
    if settings_panel != null:
        settings_panel.show()
    call_deferred("_update_upgrade_settings_exit_buttons_layout")

func _on_settings_close_pressed() -> void:
    _hide_settings_panel()

func _on_settings_main_menu_pressed() -> void:
    _hide_settings_panel()
    _hide_continue_locked_panel()
    if _is_reel_depth_tier_dialog_open():
        _on_reel_depth_tier_cancel_pressed()
    if _is_battle_level_choice_open():
        _on_battle_level_choice_cancel_pressed()
    _refresh_virtual_cursor_state()
    Global.clear_upgrade_tree_cache()
    SceneChanger.change_to_new_scene(Util.get_game_hub_scene_path(), null, 0.2)

func _on_settings_quit_pressed() -> void:
    _hide_settings_panel()
    if SteamHandler != null and SteamHandler.has_method("request_app_quit"):
        SteamHandler.request_app_quit()
        return
    get_tree().quit()

func _hide_settings_panel() -> void:
    if settings_panel != null and is_instance_valid(settings_panel):
        settings_panel.hide()

func _can_continue_to_battle() -> bool:
    if Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active() or Util.is_red_sky_game_active() or Util.is_turkey_game_active() or Util.is_reel_into_darkness_game_active():
        return true
    if not _is_simulation_upgrade_tree():
        return true
    return SaveHandler.has_any_fishing_upgrade()

func _update_go_again_button_state() -> void:
    if go_again_button == null:
        return
    if Util.is_mining_game_active():
        go_again_button.disabled = false
        go_again_button.text = tr("MINING_START")
        go_again_button.tooltip_text = ""
        go_again_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
        return
    if Util.is_open_pit_game_active():
        go_again_button.disabled = false
        var open_pit_data := OPEN_PIT_PROGRESS_SCRIPT.load_data()
        go_again_button.text = _trf("OPEN_PIT_START_FLIGHT", [int(open_pit_data.get("attempt_history", []).size()) + 1])
        go_again_button.tooltip_text = ""
        go_again_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
        return
    if Util.is_open_pit_orbit_game_active():
        go_again_button.disabled = false
        go_again_button.text = tr("OPEN_PIT_ORBIT_START_SORTIE")
        go_again_button.tooltip_text = ""
        go_again_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
        return
    if Util.is_red_sky_game_active():
        go_again_button.disabled = false
        go_again_button.text = tr("START DEFENSE")
        go_again_button.tooltip_text = ""
        go_again_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
        return
    if Util.is_turkey_game_active():
        go_again_button.disabled = false
        go_again_button.text = tr("CONTINUE TO LANE")
        go_again_button.tooltip_text = ""
        go_again_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
        return
    if Util.is_reel_into_darkness_game_active():
        go_again_button.disabled = false
        go_again_button.text = tr("START FISHING")
        go_again_button.tooltip_text = ""
        go_again_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
        return
    var can_continue: bool = _can_continue_to_battle()
    go_again_button.disabled = false
    go_again_button.tooltip_text = "" if can_continue else tr(GO_AGAIN_DISABLED_HINT)
    go_again_button.modulate = Color(1.0, 1.0, 1.0, 1.0) if can_continue else Color(0.7, 0.7, 0.7, 1.0)

func _is_standalone_mode_upgrade_scene() -> bool:
    return Util.is_mining_game_active() or Util.is_open_pit_game_active() or Util.is_open_pit_orbit_game_active() or Util.is_red_sky_game_active() or Util.is_turkey_game_active() or Util.is_reel_into_darkness_game_active()

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
    _bind_demo_label_visibility_to_popup(continue_locked_panel)
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
    title.text = tr("UPGRADE_CONTINUE_LOCKED")
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    continue_locked_label = Label.new()
    continue_locked_label.text = tr(GO_AGAIN_DISABLED_HINT)
    continue_locked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    continue_locked_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    continue_locked_label.custom_minimum_size = Vector2(500, 0)
    vbox.add_child(continue_locked_label)

    var ok_button: Button = Button.new()
    ok_button.name = "ContinueLockedOkButton"
    ok_button.text = tr("UI_OK")
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

func _refresh_fullscreen_button_icon() -> void:
    if fullscreen_button == null:
        return
    var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    fullscreen_button.icon = fullscreen_icon_on if is_fullscreen else fullscreen_icon_off
    fullscreen_button.tooltip_text = tr("UI_EXIT_FULLSCREEN") if is_fullscreen else tr("UI_ENTER_FULLSCREEN")

func _on_fullscreen_button_pressed() -> void:
    var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    SaveHandler.update_screen_mode(
        SaveHandler.SCREEN_MODES.WINDOWED if is_fullscreen else SaveHandler.SCREEN_MODES.FULL_SCREEN
    )
    _refresh_fullscreen_button_icon()
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
