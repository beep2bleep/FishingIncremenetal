extends Node2D
class_name MiningMain

const MINING_PROGRESS_SCRIPT = preload("res://Games/Mining/MiningProgress.gd")
const MINING_BALANCE = preload("res://Games/Mining/MiningBalance.gd")
const MINING_CRT_OVERLAY_SCRIPT = preload("res://Games/Mining/UI/MiningCrtOverlay.gd")
const CROSS_GAME_BONUSES := preload("res://CrossGameBonuses.gd")
const MULTI_GAME_MODE := preload("res://MultiGameMode.gd")
const SETTINGS_SCENE: PackedScene = preload("res://Settings.tscn")
const RUN_REASON_TIMER_EXPIRED := "MINING_REASON_TIMER_EXPIRED"
const RUN_REASON_DRILL_DEPLETED := "MINING_REASON_DRILL_DEPLETED"
const RUN_REASON_SIMULATION_STEP_CAP := "MINING_REASON_SIMULATION_STEP_CAP"
const RUN_REASON_HUNTER_CAUGHT := "MINING_REASON_HUNTER_CAUGHT"

const WORLD_SIZE := Vector2(1650.0, 1950.0)
const DEPTH_DOODAD_COUNT := 18
const DEPTH_DARK_SPOT_COUNT := 8
const DIRT_VARIATION_SPOT_COUNT := 18
const VISUAL_VARIATION_STRENGTH_MIN := 0.4
const VISUAL_VARIATION_STRENGTH_MAX := 10.0
const VISUAL_VARIATION_STRENGTH_STEP := 0.2
const VISUAL_VARIATION_STRENGTH_DEFAULT := 3.2
const DOT_VARIATION_RANDOM_MIN := 3.0
const DOT_VARIATION_RANDOM_MAX := 5.0
const MINERAL_CRACK_VARIATION_RANDOM_MIN := 2.0
const MINERAL_CRACK_VARIATION_RANDOM_MAX := 5.0
const CRACK_VARIATION_RANDOM_MIN := 3.0
const CRACK_VARIATION_RANDOM_MAX := 14.0
const EDGE_TICK_SPACING := 68.0
const EDGE_TICK_LENGTH := 28.0
const EDGE_TICK_WIDTH := 4.0
const EDGE_CORNER_LENGTH := 44.0
const EDGE_CORNER_WIDTH := 6.0
const BASE_RADIUS := 84.0
const PLAYER_RADIUS := 18.0
const DRILL_RANGE := 118.0
const NODE_RADIUS_MIN := 18.0
const NODE_RADIUS_MAX := 34.0
const MAX_WORLD_NODES := 96
const LEVEL_SIZE_GROWTH_PER_10_TIERS := 0.1
const DRONE_DELIVERY_INTERVAL := 7.0
const DRONE_DELIVERY_SPEED := 420.0
const PICKUP_DRONE_SPEED := 330.0
const PICKUP_DRONE_GRAB_RANGE := 16.0
const PICKUP_REJECT_BOUNCE_SPEED_MIN := 120.0
const PICKUP_REJECT_BOUNCE_SPEED_MAX := 185.0
const PICKUP_REJECT_PUSH_DISTANCE := 30.0
const PICKUP_REJECT_BLINK_DURATION := 0.34
const PICKUP_REJECT_RETRY_DELAY := 0.18
const PICKUP_REJECT_SOUND_INTERVAL := 0.14
const CARGO_BAR_REJECT_BLINK_DURATION := 0.38
const WARNING_BAR_BLINK_THRESHOLD := 0.2
const WARNING_BAR_BLINK_HZ := 4.0
const XP_BAR_LEVEL_UP_POP_SCALE := 1.05
const XP_BAR_LEVEL_UP_FLASH_DURATION := 0.6
const CONTACT_DRILL_PADDING := 10.0
const DRILL_AUDIO_INTERVAL := 0.3
const DONK_PITCH_VARIATION := 0.1
const INITIAL_DONK_VOLUME_DB_BOOST := 1.2
const AIM_CURSOR_SENSITIVITY := 1.0
const AIM_CURSOR_RADIUS := 12.0
const STATUS_PANEL_SCALE := 0.7
const STATUS_PANEL_VERTICAL_SHIFT_RATIO := 0.05
const DRILL_COPY_COUNT := 3
const DRILL_COPY_SPACING := 54.0
const DRILL_COPY_FOLLOW_SPEED := 10.0
const DRILL_COPY_BUMP_RETURN_SPEED := 42.0
const DRILL_COPY_BUMP_PUSH_SPEED := 130.0
const DRILL_COPY_BUMP_RADIUS := 34.0
const DRILL_COPY_BUMP_LIMIT := 30.0
const DRILL_TRAIL_SAMPLE_STEP := 8.0
const DRILL_TRAIL_MAX_SAMPLES := 56
const STRAIGHT_DRIVE_CHARGE_MAX := 4.4
const STRAIGHT_DRIVE_TURN_RESET_ANGLE := 18.0
const STRAIGHT_DRIVE_HARD_TURN_ANGLE := 55.0
const STRAIGHT_DRIVE_SPEED_BONUS_MAX := 0.62
const PLAYER_ACCELERATION := 2.2
const PLAYER_DECELERATION := 4.5
const DEFENSE_HUNTER_RADIUS := 22.0
const TUNNEL_SPEED_BONUS_MIN := 0.14
const TUNNEL_SPEED_BONUS_MAX := 0.46
const TUNNEL_BOOST_COVERAGE_THRESHOLD := 0.5
const TUNNEL_CLEAR_ALPHA_THRESHOLD := 0.12
const SUMMARY_CHART_ANIM_MIN_DURATION := 0.8
const SUMMARY_CHART_ANIM_MAX_DURATION := 3.2
const SUMMARY_CHART_TICK_INTERVAL := 0.085
const SUMMARY_CHART_POP_SCALE := 1.08
const SUMMARY_TEXT_MONEY_BASE_FONT_SIZE := 20
const SUMMARY_TEXT_MONEY_POP_FONT_SIZE := 28
const SUMMARY_TEXT_BASE_COLOR := Color(0.95, 0.98, 1.0, 1.0)
const SUMMARY_TEXT_MONEY_GREY := Color(0.62, 0.68, 0.74, 1.0)
const SUMMARY_TEXT_MONEY_GREEN := Color(0.37, 0.86, 0.61, 1.0)
const MINING_SUMMARY_HINT_HISTORY_LIMIT := 3
const RUN_ENDING_DURATION := 3.0
const RUN_ENDING_MIN_SPEED_MULT := 0.24
const RUN_ENDING_MAX_SPEED_MULT := 0.82
const RUN_ENDING_TURN_ANGLE := 0.7
const RUN_ENDING_SPARK_INTERVAL := 0.055
const RUN_ENDING_FADE_START := 0.42
const SUMMARY_RECOVER_DURATION := 4.0
const SUMMARY_GAMEPLAY_DIM_ALPHA := 0.5
const RUN_START_BANNER_HOLD_DURATION := 1.45
const RUN_START_BANNER_FADE_DURATION := 0.26
const WEB_REDRAW_INTERVAL := 1.0 / 30.0
const WEB_SHIP_VISUAL_INTERVAL := 1.0 / 30.0
const WEB_TRAIL_VISUAL_INTERVAL := 1.0 / 15.0
const WEB_EFFECT_FULL_HUD_REFRESH := 0
const WEB_EFFECT_HIGH_RES_DIRT_MASK := 1
const WEB_EFFECT_FAST_DIRT_UPDATES := 2
const WEB_EFFECT_BACKGROUND_NOISE := 3
const WEB_EFFECT_TARGET_AND_EDGE_FX := 4
const WEB_EFFECT_FULL_PICKUP_DETAIL := 5
const WEB_EFFECT_FULL_DRONE_DETAIL := 6
const WEB_EFFECT_CONTACT_SPARKS := 7
const WEB_EFFECT_DAMAGE_NUMBERS := 8
const WEB_EFFECT_FULL_SHIP_DETAIL := 9
const WEB_EFFECT_FULL_TRAIL_BUDDIES := 10
const WEB_EFFECT_FULL_NODE_DETAIL := 11
const WEB_EFFECT_FULL_REDRAW_RATE := 12
const WEB_EFFECT_BACKGROUND_DOODADS := 13
const WEB_DEFAULT_EFFECT_COUNT := WEB_EFFECT_BACKGROUND_DOODADS
const WEB_EFFECT_LABELS := [
    "Full HUD refresh",
    "High-res dirt mask",
    "Fast dirt updates",
    "Background noise",
    "Target line and edge FX",
    "Full pickup detail",
    "Full drone detail",
    "Contact sparks",
    "Damage numbers",
    "Full ship detail",
    "Full trail buddies",
    "Full node detail",
    "60 FPS redraw",
    "Background doodads"
]
const TUNNEL_COVERAGE_SAMPLE_OFFSETS := [
    Vector2.ZERO,
    Vector2(1.0, 0.0),
    Vector2(-1.0, 0.0),
    Vector2(0.0, 1.0),
    Vector2(0.0, -1.0),
    Vector2(0.72, 0.72),
    Vector2(-0.72, 0.72),
    Vector2(0.72, -0.72),
    Vector2(-0.72, -0.72)
]
const DEFAULT_MINING_SUMMARY_HINTS: Array[String] = [
    "MINING_HINT_DEFAULT_1",
    "MINING_HINT_DEFAULT_2",
    "MINING_HINT_DEFAULT_3",
    "MINING_HINT_DEFAULT_4",
    "MINING_HINT_DEFAULT_5"
]

enum RUN_STATES {RUNNING, ENDING, SUMMARY}

@onready var top_bar: MarginContainer = $CanvasLayer/TopBar
@onready var wallet_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/WalletLabel
@onready var phase_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/PhaseLabel
@onready var depth_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/DepthLabel
@onready var time_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/TimeRow/TimeValueLabel
@onready var time_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/TimeRow/TimeBar
@onready var drill_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/DrillRow/DrillValueLabel
@onready var drill_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/DrillRow/DrillBar
@onready var cargo_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/CargoRow/CargoValueLabel
@onready var cargo_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/CargoRow/CargoBar
@onready var xp_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/XpRow/XpValueLabel
@onready var xp_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/XpRow/XpBar
@onready var weapon_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/WeaponLabel
@onready var boss_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/BossLabel
@onready var top_panel: PanelContainer = $CanvasLayer/TopBar/TopPanel
@onready var shop_panel: PanelContainer = $CanvasLayer/ShopPanel
@onready var summary_label: RichTextLabel = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryBody/SummaryLeftColumn/SummaryLabel
@onready var summary_stats_panel: PanelContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryBody/SummaryLeftColumn/SummaryStatsPanel
@onready var summary_stats_label: Label = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryBody/SummaryLeftColumn/SummaryStatsPanel/SummaryStatsMargin/SummaryStatsLabel
@onready var money_chart: PanelContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryBody/SummaryRightColumn/MoneyChart
@onready var performance_chart: PanelContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryBody/SummaryRightColumn/PerformanceChart
@onready var hint_left_button: Button = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/HintHeaderRow/HintLeftButton
@onready var hint_title_label: Label = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/HintHeaderRow/HintTitleLabel
@onready var hint_right_button: Button = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/HintHeaderRow/HintRightButton
@onready var summary_hint_panel: PanelContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryHintPanel
@onready var summary_hint_label: Label = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryHintPanel/SummaryHintMargin/SummaryHintLabel
@onready var hint_panel: PanelContainer = $CanvasLayer/HintPanel
@onready var hint_label: Label = $CanvasLayer/HintPanel/HintMargin/HintLabel
@onready var dive_button: Button = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/DiveButton
@onready var reset_button: Button = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/ResetButton
@onready var checkpoint_header: Label = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/CheckpointHeader
@onready var checkpoint_list: VBoxContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/CheckpointList
@onready var loadout_header: Label = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/LoadoutHeader
@onready var loadout_list: VBoxContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/LoadoutList
@onready var upgrade_header: Label = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/UpgradeHeader
@onready var upgrade_scroll: ScrollContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/UpgradeScroll

var rng := RandomNumberGenerator.new()
var persistent_data: Dictionary = {}
var material_tiers: Array[Dictionary] = []
var run_state: int = RUN_STATES.RUNNING

var world_nodes: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var player_pos := Vector2.ZERO
var camera_pos := Vector2.ZERO
var active_depth_level := 1
var active_material: Dictionary = {}
var time_left := 0.0
var drill_health := 0.0
var cargo_used := 0
var carry_counts: Dictionary = {}
var banked_counts: Dictionary = {}
var run_xp := 0
var nodes_broken := 0
var run_status := ""
var drone_delivery_timer := DRONE_DELIVERY_INTERVAL
var target_node_id := -1
var contact_node_id := -1
var move_input_strength := 0.0
var camera_shake_strength := 0.0
var contact_sparks: Array[Dictionary] = []
var damage_numbers: Array[Dictionary] = []
var drill_audio_timer := 0.0
var pending_drill_damage_number := 0.0
var pending_drill_damage_origin := Vector2.ZERO
var last_drill_direction := Vector2.DOWN
var player_velocity := Vector2.ZERO
var trail_history: Array[Dictionary] = []
var drill_copies: Array[Dictionary] = []
var web_tail_ship_visual_cache: Array[Dictionary] = []
var web_player_ship_visual_cache: Dictionary = {}
var delivery_drone_visuals: Array[Dictionary] = []
var pickup_drone_visuals: Array[Dictionary] = []
var next_pickup_uid := 1
var pickup_reject_sound_timer := 0.0
var cargo_bar_reject_blink_timer := 0.0
var attached_node_id := -1
var attached_contact_point := Vector2.ZERO
var attached_push_direction := Vector2.DOWN
var dirt_image: Image
var dirt_texture: ImageTexture
var dirt_texture_dirty := false
var dirt_texture_flush_accumulator := 0.0
var web_redraw_accumulator := 0.0
var web_ship_visual_accumulator := 0.0
var web_trail_visual_accumulator := 0.0
var background_noise_texture: ImageTexture
var last_background_noise_depth_level := -1
var settings_button: Button
var variation_down_button: Button
var variation_up_button: Button
var variation_reroll_button: Button
var settings_panel: PanelContainer
var settings_content: Settings
var aim_cursor_screen_pos := Vector2.ZERO
var bank_trips := 0
var delivery_dump_count := 0
var simulation_elapsed := 0.0
var last_run_results: Dictionary = {}
var total_pickups_spawned := 0
var player_pickups_collected := 0
var drone_pickups_collected := 0
var mining_summary_hints: Array[String] = []
var mining_summary_hint_index := 0
var summary_chart_animation_entries: Array[Dictionary] = []
var summary_chart_animation_active := false
var summary_chart_tick_timer := 0.0
var summary_chart_pop_tween_count := 0
var summary_chart_ding_played := false
var summary_chart_animation_session_id := 0
var summary_text_tween: Tween
var summary_text_pop_tween: Tween
var summary_text_view_model: Dictionary = {}
var summary_text_progress := 0.0
var summary_text_money_pop_progress := 0.0
var simulation_mode_active := false
var simulation_commit_progress := true
var simulation_fixed_delta := 1.0 / 30.0
var simulation_seed_override := -1
var simulation_data_override: Dictionary = {}
var simulation_depth_override := -1
var autoplay_enabled := false
var autoplay_pointer_direction := Vector2.ZERO
var autoplay_current_goal := "node"
var straight_drive_charge := 0.0
var last_steer_direction := Vector2.ZERO
var tunnel_speed_boost_strength := 0.0
var hud_last_reported_level := 1
var xp_bar_pop_tween: Tween
var xp_bar_level_up_flash_timer := 0.0
var visual_variation_strength := VISUAL_VARIATION_STRENGTH_DEFAULT
var visual_style_reroll_index := 0
var run_end_reason_key := ""
var run_end_timer := 0.0
var run_end_turn_sign := 1.0
var run_end_initial_heading := Vector2.DOWN
var run_end_spark_timer := 0.0
var summary_transition_active := false
var summary_transition_timer := 0.0
var summary_transition_start_dim_alpha := 0.0
var hud_refresh_accumulator := 0.0
var web_effects_enabled_count := 0
var web_effect_last_message := "Web baseline active"
var web_effect_status_note := ""
var run_start_banner_panel: PanelContainer
var run_start_banner_title_label: Label
var run_start_banner_detail_label: Label
var run_start_banner_tween: Tween
var multi_mode_step: Dictionary = {}
var multi_mode_intro_timer := 0.0
var multi_mode_intro_overlay: ColorRect
var multi_mode_intro_countdown_label: Label
var multi_mode_intro_note_label: Label
var multi_mode_step_reported := false
var open_pit_defense_step: Dictionary = {}
var defense_hunter_active := false
var defense_hunter_spawned := false
var defense_hunter_pos := Vector2.ZERO
var defense_hunter_wake_distance := 260.0

func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        material_tiers = MINING_BALANCE.get_material_tiers()
        if active_depth_level >= 1 and active_depth_level <= material_tiers.size():
            active_material = _get_display_material_for_depth_level(active_depth_level)
        _refresh_localized_text()

func _trf(key: String, args: Array = []) -> String:
    var translated: String = tr(key)
    for index in range(args.size()):
        translated = translated.replace("{%d}" % index, str(args[index]))
    return translated

func _ready() -> void:
    Global.game_state = Util.GAME_STATES.PLAYING
    multi_mode_step = MULTI_GAME_MODE.get_active_step_for_game(Util.ACTIVE_GAME_MINING)
    open_pit_defense_step = _get_open_pit_defense_step()
    if multi_mode_step.is_empty() and not open_pit_defense_step.is_empty():
        multi_mode_step = open_pit_defense_step.duplicate(true)
    multi_mode_step_reported = false
    if simulation_seed_override >= 0:
        rng.seed = simulation_seed_override
    else:
        rng.randomize()
    material_tiers = MINING_BALANCE.get_material_tiers()
    SignalBus.settings_updated.connect(Callable(self, "_on_settings_updated"))
    _apply_hud_theme()
    _update_status_panel_layout()
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    _setup_system_controls()
    _setup_run_start_banner()
    _configure_summary_panel()
    dive_button.pressed.connect(_on_summary_return_pressed)
    reset_button.pressed.connect(_on_summary_retry_pressed)
    hint_left_button.pressed.connect(_on_summary_hint_left_button_pressed)
    hint_right_button.pressed.connect(_on_summary_hint_right_button_pressed)
    _ensure_crt_overlay()
    _setup_multi_mode_overlay()
    _begin_run()

func _setup_multi_mode_overlay() -> void:
    if multi_mode_step.is_empty():
        return
    multi_mode_intro_timer = 2.0
    multi_mode_intro_overlay = ColorRect.new()
    multi_mode_intro_overlay.anchor_right = 1.0
    multi_mode_intro_overlay.anchor_bottom = 1.0
    multi_mode_intro_overlay.color = Color(0.0, 0.0, 0.0, 0.28)
    multi_mode_intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    $CanvasLayer.add_child(multi_mode_intro_overlay)
    var center := CenterContainer.new()
    center.anchor_right = 1.0
    center.anchor_bottom = 1.0
    multi_mode_intro_overlay.add_child(center)
    var vbox := VBoxContainer.new()
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    vbox.add_theme_constant_override("separation", 8)
    center.add_child(vbox)
    multi_mode_intro_countdown_label = Label.new()
    multi_mode_intro_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    multi_mode_intro_countdown_label.add_theme_font_size_override("font_size", 84)
    multi_mode_intro_countdown_label.add_theme_color_override("font_color", Color(0.95, 0.22, 0.22, 1.0))
    vbox.add_child(multi_mode_intro_countdown_label)
    multi_mode_intro_note_label = Label.new()
    multi_mode_intro_note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    multi_mode_intro_note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    multi_mode_intro_note_label.custom_minimum_size = Vector2(760.0, 0.0)
    multi_mode_intro_note_label.add_theme_font_size_override("font_size", 24)
    multi_mode_intro_note_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.92, 1.0))
    multi_mode_intro_note_label.text = str(multi_mode_step.get("intro_text", MULTI_GAME_MODE.get_active_intro_text()))
    vbox.add_child(multi_mode_intro_note_label)
    _update_multi_mode_overlay()

func _is_multi_mode_challenge_active() -> bool:
    return not multi_mode_step.is_empty()

func _is_open_pit_defense_challenge_active() -> bool:
    return not open_pit_defense_step.is_empty()

func _get_open_pit_defense_step() -> Dictionary:
    var challenge: Dictionary = Global.open_pit_defense_challenge
    if str(challenge.get("source", "")) != "open_pit_empire":
        return {}
    if str(challenge.get("game_id", "")) != Util.ACTIVE_GAME_MINING:
        return {}
    return challenge.duplicate(true)

func _complete_open_pit_defense_challenge(success: bool, payload: Dictionary) -> void:
    var result := open_pit_defense_step.duplicate(true)
    result["success"] = success
    result["payload"] = payload.duplicate(true)
    Global.open_pit_defense_result = result
    Global.open_pit_defense_challenge = {}
    Util.set_active_game_id(Util.ACTIVE_GAME_OPEN_PIT)
    Util.set_high_level_mode_id(Util.HIGH_LEVEL_MODE_ALL)
    Global.start_in_upgrade_scene = false
    Global.load_saved_run = true
    SceneChanger.change_to_new_scene(Util.PATH_OPEN_PIT_MAIN, null, 0.2)

func _update_multi_mode_overlay() -> void:
    if multi_mode_intro_countdown_label == null:
        return
    multi_mode_intro_countdown_label.text = str(maxi(1, int(ceil(multi_mode_intro_timer))))

func _process_multi_mode_intro(delta: float) -> bool:
    if not _is_multi_mode_challenge_active() or multi_mode_intro_timer <= 0.0:
        return false
    multi_mode_intro_timer = maxf(0.0, multi_mode_intro_timer - delta)
    _update_multi_mode_overlay()
    if multi_mode_intro_timer <= 0.0 and multi_mode_intro_overlay != null:
        multi_mode_intro_overlay.queue_free()
        multi_mode_intro_overlay = null
    return multi_mode_intro_timer > 0.0

func _exit_tree() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
    if _process_multi_mode_intro(delta):
        return
    if run_state == RUN_STATES.RUNNING and not _is_settings_open():
        _update_autoplay_pointer()
        _process_running(delta)
    elif run_state == RUN_STATES.ENDING and not _is_settings_open():
        _process_run_ending(delta)
    _process_summary_chart_animation(delta)
    _process_summary_transition(delta)
    _update_web_drill_visual_cache(delta)
    if _should_refresh_hud_this_frame(delta):
        _refresh_hud()
    _flush_dirt_texture_updates(delta)
    if not simulation_mode_active and _should_queue_scene_redraw(delta):
        queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and run_state == RUN_STATES.RUNNING and not _is_settings_open():
            var motion_event := event as InputEventMouseMotion
            aim_cursor_screen_pos = _clamp_cursor_to_viewport(aim_cursor_screen_pos + motion_event.relative * AIM_CURSOR_SENSITIVITY)
        else:
            var visible_motion_event := event as InputEventMouseMotion
            aim_cursor_screen_pos = _clamp_cursor_to_viewport(visible_motion_event.position)
    elif event is InputEventMouseButton:
        var mouse_button_event := event as InputEventMouseButton
        aim_cursor_screen_pos = _clamp_cursor_to_viewport(mouse_button_event.position)

func _unhandled_input(event: InputEvent) -> void:
    if _is_web_effect_debug_available() and _handle_web_effect_shortcut(event):
        get_viewport().set_input_as_handled()
        return
    if _show_editor_variation_controls() and _handle_editor_variation_shortcut(event):
        get_viewport().set_input_as_handled()
        return
    if event.is_action_pressed("back") or event.is_action_pressed("escape"):
        _toggle_settings_panel()
        get_viewport().set_input_as_handled()
        return
    if run_state != RUN_STATES.RUNNING:
        return

func _draw() -> void:
    var web_fast_path: bool = OS.has_feature("web")
    var viewport_size := get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.07, 0.08, 0.1, 1.0), true)
    var origin := viewport_size * 0.5 - camera_pos
    var world_size: Vector2 = _get_world_size()
    var world_rect := Rect2(origin - world_size * 0.5, world_size)
    draw_rect(world_rect, _get_level_bg_color(), true)
    if not web_fast_path or _is_web_effect_enabled(WEB_EFFECT_BACKGROUND_DOODADS):
        _draw_background_doodads(world_rect)
    if dirt_texture != null:
        draw_texture_rect(dirt_texture, world_rect, false)
    if background_noise_texture != null and (not web_fast_path or _is_web_effect_enabled(WEB_EFFECT_BACKGROUND_NOISE)):
        var bg := _get_level_bg_color()
        # White noise texture (rgb=1) tinted by the current depth palette.
        draw_texture_rect(background_noise_texture, world_rect, true, Color(bg.r, bg.g, bg.b, 1.0))
    _draw_base(origin)
    _draw_nodes(origin)
    _draw_pickups(origin)
    if not web_fast_path or _is_web_effect_enabled(WEB_EFFECT_FULL_TRAIL_BUDDIES):
        _draw_tail()
    _draw_defense_hunter(origin)
    _draw_player(origin)
    if not web_fast_path or _is_web_effect_enabled(WEB_EFFECT_TARGET_AND_EDGE_FX):
        _draw_target_line(origin)
        _draw_run_end_fx()
        _draw_edge_fade(viewport_size)
    _draw_aim_cursor()

func _begin_run() -> void:
    persistent_data = simulation_data_override.duplicate(true) if not simulation_data_override.is_empty() else MINING_PROGRESS_SCRIPT.load_data()
    if _is_multi_mode_challenge_active():
        var forced_depth: int = int(multi_mode_step.get("depth_level", MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL))
        persistent_data["deepest_level_unlocked"] = max(int(persistent_data.get("deepest_level_unlocked", forced_depth)), forced_depth)
        persistent_data["selected_depth_level"] = forced_depth
    var min_depth: int = MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
    var selected_depth: int = int(persistent_data.get("selected_depth_level", min_depth))
    if simulation_depth_override > 0:
        selected_depth = simulation_depth_override
    active_depth_level = clampi(selected_depth, min_depth, int(persistent_data.get("deepest_level_unlocked", min_depth)))
    active_material = _get_display_material_for_depth_level(active_depth_level)
    hud_last_reported_level = MINING_PROGRESS_SCRIPT.get_rank(persistent_data)
    if OS.has_feature("web"):
        web_effects_enabled_count = WEB_DEFAULT_EFFECT_COUNT
        web_effect_last_message = "Default web level: %s" % _web_effect_label(WEB_DEFAULT_EFFECT_COUNT - 1)
    else:
        web_effects_enabled_count = 0
        web_effect_last_message = "Web baseline active"
    _refresh_web_effect_status_label()
    _ensure_background_noise_texture()
    player_pos = _get_base_position()
    camera_pos = player_pos
    time_left = _get_run_time_limit()
    drill_health = _get_drill_health_max()
    defense_hunter_active = bool(multi_mode_step.get("deepcore_hunter", false))
    defense_hunter_spawned = false
    defense_hunter_pos = _get_base_position()
    defense_hunter_wake_distance = float(multi_mode_step.get("hunter_trigger_distance", 260.0))
    cargo_used = 0
    carry_counts.clear()
    banked_counts.clear()
    run_xp = 0
    nodes_broken = 0
    bank_trips = 0
    delivery_dump_count = 0
    simulation_elapsed = 0.0
    last_run_results.clear()
    total_pickups_spawned = 0
    player_pickups_collected = 0
    drone_pickups_collected = 0
    mining_summary_hints.clear()
    mining_summary_hint_index = 0
    _reset_summary_chart_animation_state()
    _reset_xp_bar_level_feedback()
    world_nodes = []
    pickups = []
    target_node_id = -1
    contact_node_id = -1
    move_input_strength = 0.0
    camera_shake_strength = 0.0
    contact_sparks.clear()
    damage_numbers.clear()
    drill_audio_timer = 0.0
    pending_drill_damage_number = 0.0
    pending_drill_damage_origin = Vector2.ZERO
    last_drill_direction = Vector2.DOWN
    straight_drive_charge = 0.0
    last_steer_direction = Vector2.ZERO
    tunnel_speed_boost_strength = 0.0
    player_velocity = Vector2.ZERO
    run_end_reason_key = ""
    run_end_timer = 0.0
    run_end_turn_sign = 1.0
    run_end_initial_heading = Vector2.DOWN
    run_end_spark_timer = 0.0
    summary_transition_active = false
    summary_transition_timer = 0.0
    summary_transition_start_dim_alpha = 0.0
    hud_refresh_accumulator = 0.0
    dirt_texture_flush_accumulator = 0.0
    web_redraw_accumulator = 0.0
    web_ship_visual_accumulator = 0.0
    web_trail_visual_accumulator = 0.0
    trail_history.clear()
    drill_copies.clear()
    web_tail_ship_visual_cache.clear()
    web_player_ship_visual_cache.clear()
    delivery_drone_visuals.clear()
    pickup_drone_visuals.clear()
    next_pickup_uid = 1
    pickup_reject_sound_timer = 0.0
    cargo_bar_reject_blink_timer = 0.0
    attached_node_id = -1
    attached_contact_point = player_pos
    attached_push_direction = Vector2.DOWN
    drone_delivery_timer = _get_delivery_dispatch_window()
    run_status = tr("MINING_RUN_STATUS_START")
    run_state = RUN_STATES.RUNNING
    Global.game_state = Util.GAME_STATES.PLAYING
    if not simulation_mode_active or simulation_commit_progress:
        MINING_PROGRESS_SCRIPT.track_run_start(active_depth_level, persistent_data)
    _generate_world()
    _initialize_dirt_mask()
    _carve_dirt_circle(_get_base_position(), 92.0)
    shop_panel.hide()
    shop_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
    hint_panel.hide()
    hint_label.text = ""
    _reset_aim_cursor()
    _reset_drill_train()
    _refresh_mouse_capture_state()
    _show_run_start_banner()

func simulate_autoplay_run(options: Dictionary = {}) -> Dictionary:
    simulation_mode_active = true
    simulation_commit_progress = bool(options.get("commit_results", false))
    simulation_fixed_delta = float(options.get("fixed_delta", 1.0 / 30.0))
    simulation_seed_override = int(options.get("seed", -1))
    simulation_data_override = options.get("save_data", {}).duplicate(true)
    simulation_depth_override = int(options.get("depth_level", -1))
    autoplay_enabled = bool(options.get("autoplay", true))
    if simulation_seed_override >= 0:
        rng.seed = simulation_seed_override
    else:
        rng.randomize()
    _begin_run()
    var step_limit: int = int(options.get("step_limit", 2400))
    var step_count := 0
    while run_state == RUN_STATES.RUNNING and step_count < step_limit:
        _update_autoplay_pointer()
        _process_running(simulation_fixed_delta)
        step_count += 1
    if run_state == RUN_STATES.RUNNING:
        _finish_run(RUN_REASON_SIMULATION_STEP_CAP)
    var results: Dictionary = last_run_results.duplicate(true)
    results["depth_level"] = active_depth_level
    results["selected_goal"] = autoplay_current_goal
    results["seed"] = simulation_seed_override
    results["step_count"] = step_count
    simulation_mode_active = false
    simulation_commit_progress = true
    simulation_fixed_delta = 1.0 / 30.0
    simulation_seed_override = -1
    simulation_data_override.clear()
    simulation_depth_override = -1
    autoplay_enabled = false
    autoplay_pointer_direction = Vector2.ZERO
    return results

func _process_running(delta: float) -> void:
    simulation_elapsed += delta
    time_left = max(0.0, time_left - delta * _get_time_drain_rate())
    _process_player_movement(delta)
    _process_defense_hunter(delta)
    _process_drilling(delta)
    _process_pickup_drones(delta)
    _collect_pickups(delta)
    _bank_cargo_if_at_base()
    _process_delivery_drone(delta)
    _process_delivery_drone_visuals(delta)
    _process_contact_sparks(delta)
    _process_damage_numbers(delta)
    drill_audio_timer = max(0.0, drill_audio_timer - delta)
    pickup_reject_sound_timer = max(0.0, pickup_reject_sound_timer - delta)
    cargo_bar_reject_blink_timer = max(0.0, cargo_bar_reject_blink_timer - delta)
    xp_bar_level_up_flash_timer = max(0.0, xp_bar_level_up_flash_timer - delta)
    camera_shake_strength = max(0.0, camera_shake_strength - delta * 18.0)
    camera_pos = camera_pos.lerp(player_pos + _get_camera_shake_offset(), min(1.0, delta * 7.0))
    _update_system_button_layout()
    if time_left <= 0.0:
        _trigger_run_end(RUN_REASON_TIMER_EXPIRED)
    elif drill_health <= 0.0:
        _trigger_run_end(RUN_REASON_DRILL_DEPLETED)

func _process_run_ending(delta: float) -> void:
    run_end_timer = min(RUN_ENDING_DURATION, run_end_timer + delta)
    run_end_spark_timer = max(0.0, run_end_spark_timer - delta)
    var previous_pos: Vector2 = player_pos
    var progress: float = _get_run_end_progress()
    var heading: Vector2 = _get_run_end_heading(progress)
    var travel_speed: float = _get_move_speed() * lerpf(RUN_ENDING_MAX_SPEED_MULT, RUN_ENDING_MIN_SPEED_MULT, ease(progress, 1.7))
    player_velocity = heading * travel_speed
    player_pos += player_velocity * delta
    var world_size: Vector2 = _get_world_size()
    player_pos.x = clampf(player_pos.x, -world_size.x * 0.5 + PLAYER_RADIUS, world_size.x * 0.5 - PLAYER_RADIUS)
    player_pos.y = clampf(player_pos.y, -world_size.y * 0.5 + PLAYER_RADIUS, world_size.y * 0.5 - PLAYER_RADIUS)
    last_drill_direction = heading
    move_input_strength = max(0.0, 1.0 - progress * 0.35)
    _carve_dirt_segment(previous_pos, player_pos, 26.0)
    _update_drill_train(previous_pos, delta)
    _process_pickup_drones(delta)
    _collect_pickups(delta)
    _bank_cargo_if_at_base()
    _process_delivery_drone(delta)
    _process_delivery_drone_visuals(delta)
    _process_contact_sparks(delta)
    _process_damage_numbers(delta)
    drill_audio_timer = max(0.0, drill_audio_timer - delta)
    pickup_reject_sound_timer = max(0.0, pickup_reject_sound_timer - delta)
    cargo_bar_reject_blink_timer = max(0.0, cargo_bar_reject_blink_timer - delta)
    xp_bar_level_up_flash_timer = max(0.0, xp_bar_level_up_flash_timer - delta)
    camera_shake_strength = max(0.0, camera_shake_strength - delta * 14.0)
    camera_pos = camera_pos.lerp(player_pos + _get_camera_shake_offset(), min(1.0, delta * 5.0))
    _update_system_button_layout()
    _spawn_run_end_sparks(progress)
    if run_end_timer >= RUN_ENDING_DURATION:
        _finish_run(run_end_reason_key)

func _process_summary_transition(delta: float) -> void:
    if not summary_transition_active:
        return
    summary_transition_timer = min(SUMMARY_RECOVER_DURATION, summary_transition_timer + delta)
    var progress: float = clampf(summary_transition_timer / SUMMARY_RECOVER_DURATION, 0.0, 1.0)
    if shop_panel != null:
        shop_panel.modulate = Color(1.0, 1.0, 1.0, progress)

func _process_player_movement(delta: float) -> void:
    var previous_pos: Vector2 = player_pos
    var pointer_dir: Vector2 = _get_pointer_direction()
    move_input_strength = pointer_dir.length()
    contact_node_id = -1
    _update_straight_drive_charge(pointer_dir, delta)
    var tunnel_speed_bonus: float = _get_tunnel_speed_multiplier(player_pos.lerp(player_pos + pointer_dir * 18.0, 0.5))
    tunnel_speed_boost_strength = clampf((tunnel_speed_bonus - 1.0) / TUNNEL_SPEED_BONUS_MAX, 0.0, 1.0)
    var desired_speed: float = _get_move_speed() * _get_dirt_drag_multiplier() * _get_straight_drive_speed_multiplier() * tunnel_speed_bonus
    var desired_velocity: Vector2 = pointer_dir * desired_speed
    if pointer_dir == Vector2.ZERO:
        player_velocity = player_velocity.lerp(Vector2.ZERO, min(1.0, delta * PLAYER_DECELERATION))
    else:
        player_velocity = player_velocity.lerp(desired_velocity, min(1.0, delta * PLAYER_ACCELERATION))
    if attached_node_id != -1 and attached_node_id < world_nodes.size():
        var disengage_angle: float = abs(rad_to_deg(attached_push_direction.angle_to(pointer_dir))) if pointer_dir != Vector2.ZERO else 0.0
        if pointer_dir == Vector2.ZERO or disengage_angle < 30.0:
            player_pos = attached_contact_point
            player_velocity = Vector2.ZERO
            contact_node_id = attached_node_id
            last_drill_direction = attached_push_direction
            _update_drill_train(previous_pos, delta)
            return
        attached_node_id = -1
    var candidate: Vector2 = player_pos + player_velocity * delta
    var world_size: Vector2 = _get_world_size()
    candidate.x = clampf(candidate.x, -world_size.x * 0.5 + PLAYER_RADIUS, world_size.x * 0.5 - PLAYER_RADIUS)
    candidate.y = clampf(candidate.y, -world_size.y * 0.5 + PLAYER_RADIUS, world_size.y * 0.5 - PLAYER_RADIUS)
    var collision_index: int = _get_collision_node_index(candidate)
    if collision_index == -1:
        player_pos = candidate
        _carve_dirt_segment(previous_pos, player_pos, 28.0)
        _update_drill_train(previous_pos, delta)
        return
    contact_node_id = collision_index
    var node: Dictionary = world_nodes[collision_index]
    if _apply_impact_hit(collision_index, candidate):
        player_pos = previous_pos + player_velocity * delta
        player_pos.x = clampf(player_pos.x, -world_size.x * 0.5 + PLAYER_RADIUS, world_size.x * 0.5 - PLAYER_RADIUS)
        player_pos.y = clampf(player_pos.y, -world_size.y * 0.5 + PLAYER_RADIUS, world_size.y * 0.5 - PLAYER_RADIUS)
        _carve_dirt_segment(previous_pos, player_pos, 28.0)
        _update_drill_train(previous_pos, delta)
        return
    var node_pos: Vector2 = node.get("pos", Vector2.ZERO)
    var collision_normal: Vector2 = (candidate - node_pos).normalized()
    if collision_normal == Vector2.ZERO:
        collision_normal = (player_pos - node_pos).normalized()
    if collision_normal == Vector2.ZERO:
        collision_normal = Vector2.UP
    var intended_motion: Vector2 = candidate - player_pos
    if intended_motion.length() > 0.0:
        last_drill_direction = intended_motion.normalized()
    var slide_motion: Vector2 = intended_motion.slide(collision_normal)
    var slide_candidate: Vector2 = player_pos + slide_motion * 0.92
    var node_radius: float = float(node.get("radius", 0.0))
    if slide_motion.length() > 0.0 and slide_candidate.distance_to(node_pos) > PLAYER_RADIUS + node_radius - 3.0:
        player_pos = slide_candidate
    else:
        player_pos = node_pos + collision_normal * (PLAYER_RADIUS + node_radius + 1.0)
    attached_node_id = collision_index
    attached_contact_point = player_pos
    attached_push_direction = (node_pos - player_pos).normalized()
    if attached_push_direction == Vector2.ZERO:
        attached_push_direction = pointer_dir if pointer_dir != Vector2.ZERO else Vector2.DOWN
    player_pos.x = clampf(player_pos.x, -world_size.x * 0.5 + PLAYER_RADIUS, world_size.x * 0.5 - PLAYER_RADIUS)
    player_pos.y = clampf(player_pos.y, -world_size.y * 0.5 + PLAYER_RADIUS, world_size.y * 0.5 - PLAYER_RADIUS)
    _carve_dirt_segment(previous_pos, player_pos, 28.0)
    _update_drill_train(previous_pos, delta)

func _process_defense_hunter(delta: float) -> void:
    if not defense_hunter_active or run_state != RUN_STATES.RUNNING:
        return
    var base_pos := _get_base_position()
    if not defense_hunter_spawned:
        defense_hunter_pos = base_pos
        if player_pos.distance_to(base_pos) < defense_hunter_wake_distance:
            return
        defense_hunter_spawned = true
    var speed_mult: float = float(multi_mode_step.get("hunter_speed_mult", 0.5))
    var hunter_speed: float = _get_move_speed() * speed_mult
    defense_hunter_pos = defense_hunter_pos.move_toward(player_pos, hunter_speed * delta)
    if defense_hunter_pos.distance_to(player_pos) <= DEFENSE_HUNTER_RADIUS + PLAYER_RADIUS:
        _trigger_run_end(RUN_REASON_HUNTER_CAUGHT)

func _process_drilling(delta: float) -> void:
    target_node_id = _get_contact_drill_node_index()
    if target_node_id == -1 or move_input_strength <= 0.0:
        return
    var node: Dictionary = world_nodes[target_node_id]
    var drill_damage: float = _get_drill_dps() * (1.55 + move_input_strength * 2.15 + straight_drive_charge * 0.35) * delta
    node["health"] = max(0.0, float(node.get("health", 0.0)) - drill_damage)
    world_nodes[target_node_id] = node
    drill_health = max(0.0, drill_health - _get_drill_wear(node) * (0.58 + move_input_strength * 0.52 + straight_drive_charge * 0.09) * delta)
    var hit_pos: Vector2 = player_pos.lerp(node.get("pos", player_pos), 0.45)
    pending_drill_damage_number += drill_damage
    pending_drill_damage_origin = hit_pos
    _spawn_contact_sparks(player_pos.lerp(node.get("pos", player_pos), 0.45), node.get("material_color", Color.WHITE), 2)
    camera_shake_strength = min(8.0, camera_shake_strength + 1.8 * delta * 60.0)
    _play_drill_tick(hit_pos)
    run_status = _trf("MINING_RUN_STATUS_DRILLING", [String(node.get("material_name", tr("MINING_NODE_GENERIC")))])
    if float(node["health"]) <= 0.0:
        _break_node(target_node_id)

func _collect_pickups(delta: float) -> void:
    if pickups.is_empty():
        return
    var collect_radius: float = _get_pickup_radius()
    var remaining: Array[Dictionary] = []
    for pickup in pickups:
        var pickup_pos: Vector2 = pickup.get("pos", Vector2.ZERO)
        var pickup_vel: Vector2 = pickup.get("vel", Vector2.ZERO)
        pickup_pos += pickup_vel * delta
        pickup_vel *= 0.9
        var reject_retry_timer: float = max(0.0, float(pickup.get("reject_retry_timer", 0.0)) - delta)
        var reject_blink_timer: float = max(0.0, float(pickup.get("reject_blink_timer", 0.0)) - delta)
        pickup["pos"] = pickup_pos
        pickup["vel"] = pickup_vel
        pickup["reject_retry_timer"] = reject_retry_timer
        pickup["reject_blink_timer"] = reject_blink_timer
        var can_collect: bool = player_pos.distance_to(pickup_pos) <= collect_radius
        var material_id: String = String(pickup.get("material_id", ""))
        if can_collect and _add_cargo_material(material_id):
            player_pickups_collected += 1
            run_status = _trf("MINING_RUN_STATUS_SCOOPED", [String(pickup.get("material_name", tr("MINING_LOOT_GENERIC")))])
            continue
        if can_collect and reject_retry_timer <= 0.0:
            pickup = _apply_pickup_rejection_feedback(pickup, player_pos)
            run_status = tr("MINING_RUN_STATUS_CARGO_FULL")
        remaining.append(pickup)
    pickups = remaining

func _bank_cargo_if_at_base() -> void:
    if cargo_used <= 0:
        return
    if player_pos.distance_to(_get_base_position()) > BASE_RADIUS:
        return
    for material_id_variant in carry_counts.keys():
        var material_id: String = String(material_id_variant)
        banked_counts[material_id] = int(banked_counts.get(material_id, 0)) + int(carry_counts[material_id])
    carry_counts.clear()
    cargo_used = 0
    bank_trips += 1
    run_status = tr("MINING_RUN_STATUS_BANKED")

func _process_delivery_drone(delta: float) -> void:
    var drone_count: int = MINING_BALANCE.get_delivery_drone_count(_get_upgrade_levels())
    if drone_count <= 0 or cargo_used <= 0:
        drone_delivery_timer = _get_delivery_dispatch_window()
        return
    drone_delivery_timer = max(0.0, drone_delivery_timer - delta)
    if drone_delivery_timer > 0.0:
        return
    drone_delivery_timer = _get_delivery_dispatch_window()
    var active_drones: int = delivery_drone_visuals.size()
    var available_dispatches: int = max(0, drone_count - active_drones)
    if available_dispatches <= 0:
        return
    var dispatched: int = 0
    while dispatched < available_dispatches and cargo_used > 0:
        var dispatch_bundle: Dictionary = _take_delivery_drone_dispatch(MINING_BALANCE.get_delivery_cargo_space_per_dispatch(_get_upgrade_levels()))
        var dispatched_material_id: String = String(dispatch_bundle.get("material_id", ""))
        var cargo_count: int = int(dispatch_bundle.get("cargo_count", 0))
        if dispatched_material_id == "" or cargo_count <= 0:
            break
        _spawn_delivery_drone_visual(dispatched_material_id, _get_material_by_id(dispatched_material_id), cargo_count)
        dispatched += 1
    if dispatched > 0:
        run_status = tr("MINING_RUN_STATUS_DELIVERY_DRONE")

func _process_pickup_drones(delta: float) -> void:
    var drone_count: int = MINING_BALANCE.get_pickup_drone_count(_get_upgrade_levels())
    if drone_count <= 0:
        _clear_all_pickup_claims()
        pickup_drone_visuals.clear()
        return
    while pickup_drone_visuals.size() < drone_count:
        var drone_index: int = pickup_drone_visuals.size()
        pickup_drone_visuals.append({
            "index": drone_index,
            "pos": player_pos,
            "state": "idle",
            "target_uid": -1,
            "carry_material_id": "",
            "carry_material_name": "",
            "carry_color": Color.WHITE,
            "orbit_seed": rng.randf_range(0.0, TAU)
        })
    while pickup_drone_visuals.size() > drone_count:
        pickup_drone_visuals.pop_back()
    _sync_pickup_claims_with_drones()
    var pickup_speed: float = _get_pickup_drone_speed()
    for index in range(pickup_drone_visuals.size()):
        var drone: Dictionary = pickup_drone_visuals[index]
        var state: String = String(drone.get("state", "idle"))
        var drone_pos: Vector2 = drone.get("pos", player_pos)
        if state == "to_pickup":
            var target_pickup: Dictionary = _get_pickup_by_uid(int(drone.get("target_uid", -1)))
            if target_pickup.is_empty() or not _can_fit_material_in_cargo(String(target_pickup.get("material_id", ""))):
                _clear_pickup_claim(int(drone.get("target_uid", -1)))
                drone["state"] = "idle"
                drone["target_uid"] = -1
            else:
                var pickup_pos: Vector2 = target_pickup.get("pos", player_pos)
                drone_pos = drone_pos.move_toward(pickup_pos, pickup_speed * delta)
                if drone_pos.distance_to(pickup_pos) <= PICKUP_DRONE_GRAB_RANGE:
                    drone["carry_material_id"] = String(target_pickup.get("material_id", ""))
                    drone["carry_material_name"] = String(target_pickup.get("material_name", "loot"))
                    drone["carry_color"] = target_pickup.get("material_color", Color.WHITE)
                    drone["state"] = "to_player"
                    _remove_pickup_by_uid(int(drone.get("target_uid", -1)))
                    drone["target_uid"] = -1
        elif state == "to_player":
            drone_pos = drone_pos.move_toward(player_pos, pickup_speed * delta)
            if drone_pos.distance_to(player_pos) <= _get_pickup_radius() * 0.5 + 10.0:
                var carry_material_id: String = String(drone.get("carry_material_id", ""))
                if _add_cargo_material(carry_material_id):
                    drone_pickups_collected += 1
                    run_status = _trf("MINING_RUN_STATUS_PICKUP_DRONE", [String(drone.get("carry_material_name", tr("MINING_LOOT_GENERIC")))])
                else:
                    _spawn_rejected_pickup_from_drone(drone, drone_pos)
                    run_status = tr("MINING_RUN_STATUS_CARGO_FULL")
                drone["state"] = "idle"
                drone["carry_material_id"] = ""
                drone["carry_material_name"] = ""
                drone["carry_color"] = Color.WHITE
                drone["target_uid"] = -1
        if String(drone.get("state", "idle")) == "idle":
            if cargo_used < _get_cargo_capacity():
                var assigned_uid: int = _find_available_pickup_uid(drone_pos)
                if assigned_uid != -1:
                    _set_pickup_claimed_by(assigned_uid, int(drone.get("index", index)))
                    drone["state"] = "to_pickup"
                    drone["target_uid"] = assigned_uid
                else:
                    drone_pos = drone_pos.lerp(_get_pickup_drone_idle_position(index, drone), 0.22)
            else:
                drone_pos = drone_pos.lerp(_get_pickup_drone_idle_position(index, drone), 0.22)
        drone["pos"] = drone_pos
        pickup_drone_visuals[index] = drone
    _sync_pickup_claims_with_drones()

func _process_delivery_drone_visuals(delta: float) -> void:
    if delivery_drone_visuals.is_empty():
        return
    var remaining: Array[Dictionary] = []
    var base_pos: Vector2 = _get_base_position()
    var delivery_speed: float = _get_delivery_drone_speed()
    for drone in delivery_drone_visuals:
        var drone_state: String = String(drone.get("state", "to_base"))
        var drone_pos: Vector2 = drone.get("pos", player_pos)
        if drone_state == "to_base":
            drone_pos = drone_pos.move_toward(base_pos, delivery_speed * delta)
            drone["pos"] = drone_pos
            if drone_pos.distance_to(base_pos) > 18.0:
                remaining.append(drone)
                continue
            _bank_delivery_drone_cargo(drone)
            drone["state"] = "returning"
            drone["cargo_count"] = 0
            drone["carry_color"] = Color(0.0, 0.0, 0.0, 0.0)
            remaining.append(drone)
            continue
        var return_anchor: Vector2 = player_pos + drone.get("return_offset", Vector2.ZERO)
        drone_pos = drone_pos.move_toward(return_anchor, delivery_speed * delta)
        drone["pos"] = drone_pos
        if drone_pos.distance_to(return_anchor) > 18.0:
            remaining.append(drone)
    delivery_drone_visuals = remaining

func _spawn_delivery_drone_visual(material_id: String, material: Dictionary, cargo_count: int = 1) -> void:
    delivery_drone_visuals.append({
        "pos": player_pos,
        "state": "to_base",
        "material_id": material_id,
        "carry_color": material.get("color", Color.WHITE),
        "carry_name": String(material.get("name", material_id)),
        "cargo_count": max(1, cargo_count),
        "return_offset": Vector2(rng.randf_range(-26.0, 26.0), rng.randf_range(-22.0, 22.0))
    })

func _apply_pickup_rejection_feedback(pickup: Dictionary, source_pos: Vector2) -> Dictionary:
    var bounce_dir: Vector2 = pickup.get("pos", source_pos) - source_pos
    if bounce_dir == Vector2.ZERO:
        bounce_dir = pickup.get("vel", Vector2.ZERO)
    if bounce_dir == Vector2.ZERO:
        bounce_dir = Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU))
    bounce_dir = bounce_dir.normalized()
    pickup["pos"] = source_pos + bounce_dir * PICKUP_REJECT_PUSH_DISTANCE
    pickup["vel"] = bounce_dir * rng.randf_range(PICKUP_REJECT_BOUNCE_SPEED_MIN, PICKUP_REJECT_BOUNCE_SPEED_MAX)
    pickup["reject_retry_timer"] = PICKUP_REJECT_RETRY_DELAY
    pickup["reject_blink_timer"] = PICKUP_REJECT_BLINK_DURATION
    _play_pickup_reject_sound()
    return pickup

func _spawn_rejected_pickup_from_drone(drone: Dictionary, drone_pos: Vector2) -> void:
    var material_id: String = String(drone.get("carry_material_id", ""))
    if material_id == "":
        return
    var pickup := {
        "uid": next_pickup_uid,
        "pos": drone_pos,
        "vel": (drone_pos - player_pos).normalized() * PICKUP_REJECT_BOUNCE_SPEED_MIN,
        "material_id": material_id,
        "material_name": String(drone.get("carry_material_name", "loot")),
        "material_color": drone.get("carry_color", Color(0.8, 0.8, 0.8, 1.0)),
        "claimed_by": -1,
        "reject_retry_timer": 0.0,
        "reject_blink_timer": 0.0
    }
    next_pickup_uid += 1
    pickups.append(_apply_pickup_rejection_feedback(pickup, player_pos))

func _play_pickup_reject_sound() -> void:
    if simulation_mode_active or pickup_reject_sound_timer > 0.0:
        return
    pickup_reject_sound_timer = PICKUP_REJECT_SOUND_INTERVAL
    cargo_bar_reject_blink_timer = CARGO_BAR_REJECT_BLINK_DURATION
    _play_mining_donk(-16.0)

func _take_one_cargo_for_delivery() -> String:
    for material_id_variant in carry_counts.keys():
        var material_id: String = String(material_id_variant)
        if int(carry_counts[material_id]) <= 0:
            continue
        carry_counts[material_id] = int(carry_counts[material_id]) - 1
        if int(carry_counts[material_id]) <= 0:
            carry_counts.erase(material_id)
        cargo_used = max(0, cargo_used - _get_material_cargo_space(material_id))
        return material_id
    return ""

func _peek_next_carried_material_id() -> String:
    for material_id_variant in carry_counts.keys():
        var material_id: String = String(material_id_variant)
        if int(carry_counts.get(material_id, 0)) > 0:
            return material_id
    return ""

func _take_delivery_drone_dispatch(dispatch_space_budget: int) -> Dictionary:
    var first_material_id: String = _peek_next_carried_material_id()
    if first_material_id == "":
        return {}
    var remaining_dispatch_space: int = max(1, dispatch_space_budget)
    var cargo_count := 0
    while true:
        var next_material_id: String = _peek_next_carried_material_id()
        if next_material_id == "":
            break
        if cargo_count > 0 and next_material_id != first_material_id:
            break
        var next_space: int = _get_material_cargo_space(next_material_id)
        if cargo_count > 0 and next_space > remaining_dispatch_space:
            break
        if _take_one_cargo_for_delivery() == "":
            break
        cargo_count += 1
        remaining_dispatch_space = max(0, remaining_dispatch_space - next_space)
        if remaining_dispatch_space <= 0:
            break
    if cargo_count <= 0:
        return {}
    return {
        "material_id": first_material_id,
        "cargo_count": cargo_count
    }

func _bank_delivery_drone_cargo(drone: Dictionary) -> void:
    var material_id: String = String(drone.get("material_id", ""))
    if material_id == "":
        return
    var cargo_count: int = max(1, int(drone.get("cargo_count", 1)))
    banked_counts[material_id] = int(banked_counts.get(material_id, 0)) + cargo_count
    delivery_dump_count += cargo_count

func _bank_pending_delivery_drone_visuals() -> void:
    for drone in delivery_drone_visuals:
        if String(drone.get("state", "to_base")) == "to_base":
            _bank_delivery_drone_cargo(drone)
    delivery_drone_visuals.clear()

func _find_available_pickup_uid(origin: Vector2) -> int:
    var nearest_uid := -1
    var nearest_distance := INF
    for pickup in pickups:
        if int(pickup.get("claimed_by", -1)) != -1:
            continue
        var pickup_uid: int = int(pickup.get("uid", -1))
        if pickup_uid == -1:
            continue
        if not _can_fit_material_in_cargo(String(pickup.get("material_id", ""))):
            continue
        var distance: float = origin.distance_to(pickup.get("pos", origin))
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_uid = pickup_uid
    return nearest_uid

func _get_pickup_by_uid(pickup_uid: int) -> Dictionary:
    for pickup in pickups:
        if int(pickup.get("uid", -1)) == pickup_uid:
            return pickup
    return {}

func _set_pickup_claimed_by(pickup_uid: int, drone_index: int) -> void:
    for index in range(pickups.size()):
        var pickup: Dictionary = pickups[index]
        if int(pickup.get("uid", -1)) != pickup_uid:
            continue
        pickup["claimed_by"] = drone_index
        pickups[index] = pickup
        return

func _remove_pickup_by_uid(pickup_uid: int) -> void:
    for index in range(pickups.size() - 1, -1, -1):
        if int(pickups[index].get("uid", -1)) == pickup_uid:
            pickups.remove_at(index)
            return

func _clear_pickup_claim(pickup_uid: int) -> void:
    if pickup_uid == -1:
        return
    for index in range(pickups.size()):
        var pickup: Dictionary = pickups[index]
        if int(pickup.get("uid", -1)) != pickup_uid:
            continue
        pickup["claimed_by"] = -1
        pickups[index] = pickup
        return

func _clear_all_pickup_claims() -> void:
    for index in range(pickups.size()):
        var pickup: Dictionary = pickups[index]
        pickup["claimed_by"] = -1
        pickups[index] = pickup

func _sync_pickup_claims_with_drones() -> void:
    var claimed_uids: Dictionary = {}
    for drone in pickup_drone_visuals:
        if String(drone.get("state", "idle")) != "to_pickup":
            continue
        var target_uid: int = int(drone.get("target_uid", -1))
        if target_uid != -1:
            claimed_uids[target_uid] = int(drone.get("index", -1))
    for index in range(pickups.size()):
        var pickup: Dictionary = pickups[index]
        var pickup_uid: int = int(pickup.get("uid", -1))
        pickup["claimed_by"] = int(claimed_uids.get(pickup_uid, -1))
        pickups[index] = pickup

func _get_pickup_drone_idle_position(drone_index: int, drone: Dictionary) -> Vector2:
    var orbit_seed: float = float(drone.get("orbit_seed", 0.0))
    var angle: float = Time.get_ticks_msec() * 0.002 + orbit_seed + TAU * float(drone_index) / float(max(1, pickup_drone_visuals.size()))
    var orbit_radius: float = 38.0 + 8.0 * float(drone_index % 2)
    return player_pos + Vector2.RIGHT.rotated(angle) * orbit_radius

func _generate_world() -> void:
    var available_tiers: int = min(active_depth_level + 1, material_tiers.size())
    var material_pool_indices: Array[int] = MINING_BALANCE.get_material_pool_indices(available_tiers)
    var world_size: Vector2 = _get_world_size()
    var area_multiplier: float = _get_world_area_multiplier()
    var node_count: int = min(
        int(round(MAX_WORLD_NODES * area_multiplier)),
        int(round((28 + active_depth_level * 6) * area_multiplier))
    )
    var safety_center: Vector2 = _get_base_position()
    for node_index in range(node_count):
        var material: Dictionary = _roll_material_for_level(material_pool_indices)
        var health: float = MINING_BALANCE.get_node_health(material, active_depth_level)
        var radius: float = clampf(14.0 + sqrt(health) * 1.9, NODE_RADIUS_MIN, NODE_RADIUS_MAX)
        var pos: Vector2 = Vector2.ZERO
        var attempts: int = 0
        while attempts < 32:
            pos = Vector2(
                rng.randf_range(-world_size.x * 0.47, world_size.x * 0.47),
                rng.randf_range(-world_size.y * 0.36, world_size.y * 0.47)
            )
            if pos.distance_to(safety_center) < BASE_RADIUS + 150.0:
                attempts += 1
                continue
            if _node_overlaps_existing(pos, radius + 18.0):
                attempts += 1
                continue
            break
        var node_data: Dictionary = {
            "id": node_index,
            "pos": pos,
            "radius": radius,
            "shape_points": _build_rock_shape(radius),
            "health": health,
            "max_health": health,
            "material_id": String(material.get("id", "stone")),
            "material_name": String(material.get("name", "Stone")),
            "material_color": material.get("color", Color(0.5, 0.5, 0.5, 1.0)),
            "material_bg_color": material.get("bg", Color(0.18, 0.16, 0.14, 1.0)),
            "value": int(material.get("value", 1)),
            "xp": int(material.get("xp", 3)),
            "sparkle": float(material.get("sparkle", 0.0))
        }
        if OS.has_feature("web"):
            node_data.merge(_build_node_render_cache(node_data), true)
        world_nodes.append(node_data)

func _node_overlaps_existing(pos: Vector2, radius: float) -> bool:
    for node in world_nodes:
        if pos.distance_to(node.get("pos", Vector2.ZERO)) < radius + float(node.get("radius", 0.0)):
            return true
    return false

func _roll_material_for_level(material_pool_indices: Array[int]) -> Dictionary:
    if material_pool_indices.is_empty():
        return material_tiers[0]
    if material_pool_indices.size() == 1:
        return material_tiers[material_pool_indices[0]]
    var weights: Array[float] = MINING_BALANCE.get_material_weights_for_indices(material_pool_indices, _get_upgrade_levels())
    var total_weight: float = 0.0
    for weight in weights:
        total_weight += float(weight)
    var roll: float = rng.randf() * total_weight
    for index in range(material_pool_indices.size()):
        roll -= weights[index]
        if roll <= 0.0:
            return material_tiers[material_pool_indices[index]]
    return material_tiers[material_pool_indices[material_pool_indices.size() - 1]]

func _get_display_material_depth_level(depth_level: int) -> int:
    if material_tiers.is_empty():
        return MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL
    return clampi(depth_level + 1, MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL, material_tiers.size())

func _get_display_material_for_depth_level(depth_level: int) -> Dictionary:
    if material_tiers.is_empty():
        return {}
    return material_tiers[_get_display_material_depth_level(depth_level) - 1]

func _get_display_depth_tier_for_run_depth(depth_level: int) -> int:
    return MINING_PROGRESS_SCRIPT.get_display_depth_tier(_get_display_material_depth_level(depth_level))

func _break_node(node_index: int) -> void:
    var node: Dictionary = world_nodes[node_index]
    world_nodes.remove_at(node_index)
    _handle_removed_node_index(node_index)
    nodes_broken += 1
    if _is_multi_mode_challenge_active() and not multi_mode_step_reported and nodes_broken >= int(multi_mode_step.get("nodes_goal", 999999)):
        multi_mode_step_reported = true
        if _is_open_pit_defense_challenge_active():
            _complete_open_pit_defense_challenge(true, {
                "nodes_broken": nodes_broken,
                "depth_level": active_depth_level,
                "elapsed": maxf(0.0, _get_run_time_limit() - time_left),
                "time_remaining": maxf(0.0, time_left),
                "time_limit": _get_run_time_limit()
            })
            return
        MULTI_GAME_MODE.complete_current_step(true, {
            "nodes_broken": nodes_broken,
            "depth_level": active_depth_level,
            "elapsed": maxf(0.0, _get_run_time_limit() - time_left),
            "time_remaining": maxf(0.0, time_left),
            "time_limit": _get_run_time_limit()
        })
        return
    var xp_reward: int = int(round(int(node.get("xp", 0)) * _get_xp_multiplier()))
    run_xp += xp_reward
    var drop_count: int = MINING_BALANCE.get_drop_count_for_node(node)
    var scatter_dir: Vector2 = last_drill_direction
    if scatter_dir == Vector2.ZERO:
        scatter_dir = Vector2.DOWN
    var perpendicular: Vector2 = Vector2(-scatter_dir.y, scatter_dir.x).normalized()
    for i in range(drop_count):
        var side_sign: float = -1.0 if i % 2 == 0 else 1.0
        var spread_dir: Vector2 = (perpendicular * side_sign + scatter_dir * rng.randf_range(-0.28, 0.22)).normalized()
        if spread_dir == Vector2.ZERO:
            spread_dir = perpendicular * side_sign
        pickups.append({
            "uid": next_pickup_uid,
            "pos": node.get("pos", Vector2.ZERO) + spread_dir * rng.randf_range(12.0, 26.0),
            "vel": spread_dir * rng.randf_range(55.0, 130.0),
            "material_id": String(node.get("material_id", "stone")),
            "material_name": String(node.get("material_name", "Stone")),
            "material_color": node.get("material_color", Color(0.7, 0.7, 0.7, 1.0)),
            "claimed_by": -1,
            "reject_retry_timer": 0.0,
            "reject_blink_timer": 0.0
        })
        next_pickup_uid += 1
        total_pickups_spawned += 1
    _spawn_damage_number(node.get("pos", Vector2.ZERO), int(round(float(node.get("max_health", 0.0)))), true)
    _spawn_contact_sparks(node.get("pos", Vector2.ZERO), node.get("material_color", Color.WHITE), 10)
    camera_shake_strength = max(camera_shake_strength, 10.0)
    _carve_dirt_circle(node.get("pos", Vector2.ZERO), float(node.get("radius", 24.0)) + 16.0)
    run_status = _trf("MINING_RUN_STATUS_VEIN_CRACKED", [String(node.get("material_name", tr("MINING_MATERIAL_STONE_NAME")))])

func _handle_removed_node_index(removed_index: int) -> void:
    contact_node_id = _remap_node_index_after_removal(contact_node_id, removed_index)
    target_node_id = _remap_node_index_after_removal(target_node_id, removed_index)
    attached_node_id = _remap_node_index_after_removal(attached_node_id, removed_index)
    if attached_node_id == -1:
        attached_contact_point = player_pos
        attached_push_direction = Vector2.DOWN

func _remap_node_index_after_removal(index: int, removed_index: int) -> int:
    if index == removed_index:
        return -1
    if index > removed_index:
        return index - 1
    return index

func _build_run_results(reason_key: String) -> Dictionary:
    var reason_text: String = tr(reason_key)
    var money_breakdown: Array[String] = []
    var money_breakdown_chart: Array[Dictionary] = []
    var total_money: int = 0
    var cross_mult: float = CROSS_GAME_BONUSES.get_target_bonus_multiplier(Util.ACTIVE_GAME_MINING)
    for material_id_variant in banked_counts.keys():
        var material_id: String = String(material_id_variant)
        var count: int = int(banked_counts[material_id])
        var material: Dictionary = _get_material_by_id(material_id)
        var value_each: int = int(round(int(material.get("value", 1)) * _get_value_multiplier() * cross_mult))
        var subtotal: int = count * value_each
        total_money += subtotal
        money_breakdown.append(_trf("MINING_SUMMARY_TEXT_CARGO_LINE_CASH", [String(material.get("name", material_id)), count, subtotal]))
        money_breakdown_chart.append({
            "material_id": material_id,
            "label": String(material.get("name", material_id)),
            "count": count,
            "money": subtotal,
            "color": material.get("color", Color.WHITE)
        })

    var before_level: int = MINING_PROGRESS_SCRIPT.get_rank(persistent_data)
    var projected_xp: int = MINING_PROGRESS_SCRIPT.get_rank_xp(persistent_data) + run_xp
    var projected_level: int = MINING_PROGRESS_SCRIPT.get_rank_for_total_xp(projected_xp)
    var projected_depth_unlock: int = min(
        MINING_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL,
        1 + projected_level - 1 + _get_upgrade_level("depth_scanner")
    )
    var projected_level_data: Dictionary = _make_rank_progress_data(projected_level, projected_xp)
    var level_progress: Dictionary = MINING_PROGRESS_SCRIPT.get_rank_progress(projected_level_data)
    var level_gain: int = projected_level - before_level
    var level_bonus_gains: Dictionary = MINING_BALANCE.get_level_bonus_totals_for_range(before_level, projected_level)
    var projected_data: Dictionary = persistent_data.duplicate(true)
    projected_data["wallet"] = max(0, int(projected_data.get("wallet", 0)) + total_money)
    projected_data[MINING_PROGRESS_SCRIPT.RANK_XP_KEY] = projected_xp
    projected_data[MINING_PROGRESS_SCRIPT.RANK_LEVEL_KEY] = projected_level
    projected_data["xp"] = projected_xp
    projected_data["player_level"] = projected_level
    projected_data["last_run_summary"] = ""
    projected_data["last_run_breakdown"] = {}
    projected_data["deepest_level_unlocked"] = max(int(projected_data.get("deepest_level_unlocked", MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL)), active_depth_level)
    MINING_BALANCE.refresh_depth_unlocks(projected_data)
    projected_depth_unlock = int(projected_data.get("deepest_level_unlocked", projected_depth_unlock))
    var unlocked_depth_before_run: int = int(persistent_data.get("deepest_level_unlocked", MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL))
    var gem_reward_count: int = CROSS_GAME_BONUSES.count_mining_depth_rewards_between(unlocked_depth_before_run, projected_depth_unlock)
    var gem_reward_line: String = CROSS_GAME_BONUSES.get_reward_summary_line(Util.ACTIVE_GAME_MINING, gem_reward_count)
    var display_depth_level: int = _get_display_depth_tier_for_run_depth(active_depth_level)
    var display_depth_unlock: int = _get_display_depth_tier_for_run_depth(projected_depth_unlock)
    var level_bonus_note: String = _format_level_bonus_summary(level_bonus_gains)
    var tier_unlock_note: String = _format_depth_unlock_summary(unlocked_depth_before_run, projected_depth_unlock)
    var ore_collected: int = player_pickups_collected + drone_pickups_collected
    var ore_banked: int = _get_total_count_from_dict(banked_counts)
    var ore_left_behind: int = max(0, total_pickups_spawned - ore_collected)
    var run_seconds: float = max(0.01, simulation_elapsed)
    var time_spent: float = max(0.0, _get_run_time_limit() - time_left)
    var money_per_second: float = float(total_money) / run_seconds
    var xp_per_second: float = float(run_xp) / run_seconds
    var ore_per_second: float = float(ore_collected) / run_seconds
    var collection_rate: float = 0.0 if total_pickups_spawned <= 0 else float(ore_collected) / float(total_pickups_spawned)
    var bank_rate: float = 0.0 if ore_collected <= 0 else float(ore_banked) / float(ore_collected)
    var summary_lines := PackedStringArray()
    summary_lines.append(_trf("MINING_SUMMARY_TEXT_RUN_COMPLETE", [reason_text]))
    summary_lines.append("")
    summary_lines.append(_trf("MINING_SUMMARY_TEXT_DEPTH_TIER", [display_depth_level, String(active_material.get("name", tr("MINING_MATERIAL_STONE_NAME")))]))
    summary_lines.append(_trf("MINING_SUMMARY_TEXT_NODES_BROKEN", [nodes_broken]))
    summary_lines.append(_trf("MINING_SUMMARY_TEXT_XP_EARNED", [run_xp, " %s" % tr("MINING_SUMMARY_LEVEL_UP") if level_gain > 0 else ""]))
    summary_lines.append(_trf("MINING_SUMMARY_TEXT_MONEY_EARNED", ["$%d" % total_money]))
    summary_lines.append("")
    summary_lines.append(tr("MINING_SUMMARY_TEXT_CARGO_PAYOUT"))
    summary_lines.append(tr("MINING_SUMMARY_TEXT_NO_CARGO") if money_breakdown.is_empty() else "\n".join(money_breakdown))
    summary_lines.append("")
    summary_lines.append(_trf("MINING_SUMMARY_TEXT_LEVEL", [projected_level, int(level_progress.get("current_xp", 0)), int(level_progress.get("next_rank_xp", level_progress.get("next_level_xp", 1)))]))
    summary_lines.append(_trf("MINING_SUMMARY_TEXT_UNLOCKED_DEPTH", [display_depth_unlock]))
    if level_bonus_note != "":
        summary_lines.append(level_bonus_note)
    if tier_unlock_note != "":
        summary_lines.append(tier_unlock_note)
    if gem_reward_line != "":
        summary_lines.append(gem_reward_line)
    var summary_text: String = "\n".join(summary_lines)
    return {
        "money": total_money,
        "xp": run_xp,
        "depth_level": active_depth_level,
        "summary_view_model": {
            "reason_key": reason_key,
            "reason": reason_text,
            "depth_level": active_depth_level,
            "depth_material_name": String(active_material.get("name", tr("MINING_MATERIAL_STONE_NAME"))),
            "nodes_broken": nodes_broken,
            "xp_earned": run_xp,
            "ranked_up": level_gain > 0,
            "money_earned": total_money,
            "money_breakdown_chart": money_breakdown_chart.duplicate(true),
            "projected_rank": projected_level,
            "rank_progress_current": int(level_progress.get("current_xp", 0)),
            "rank_progress_next": int(level_progress.get("next_rank_xp", level_progress.get("next_level_xp", 1))),
            "projected_depth_unlock": projected_depth_unlock,
            "level_bonus_note": level_bonus_note,
            "tier_unlock_note": tier_unlock_note,
            "gem_reward_count": gem_reward_count,
            "gem_reward_line": gem_reward_line
        },
        "summary_text": summary_text,
        "summary_stats_text": _build_summary_stats_text({
            "ore_spawned": total_pickups_spawned,
            "ore_collected": ore_collected,
            "ore_left_behind": ore_left_behind,
            "player_pickups_collected": player_pickups_collected,
            "drone_pickups_collected": drone_pickups_collected,
            "ore_banked": ore_banked,
            "delivery_dumps": delivery_dump_count,
            "money_per_second": money_per_second,
            "xp_per_second": xp_per_second,
            "ore_per_second": ore_per_second,
            "collection_rate": collection_rate,
            "bank_rate": bank_rate,
            "time_spent": time_spent
        }),
        "money_breakdown_chart": money_breakdown_chart,
        "reason_key": reason_key,
        "reason": reason_text,
        "banked_counts": banked_counts.duplicate(true),
        "bank_trips": bank_trips,
        "delivery_dumps": delivery_dump_count,
        "nodes_broken": nodes_broken,
        "remaining_nodes": world_nodes.size(),
        "total_nodes_seen": nodes_broken + world_nodes.size(),
        "ore_spawned": total_pickups_spawned,
        "ore_collected": ore_collected,
        "ore_left_behind": ore_left_behind,
        "ore_banked": ore_banked,
        "player_pickups_collected": player_pickups_collected,
        "drone_pickups_collected": drone_pickups_collected,
        "money_per_second": money_per_second,
        "xp_per_second": xp_per_second,
        "ore_per_second": ore_per_second,
        "collection_rate": collection_rate,
        "bank_rate": bank_rate,
        "time_left": snappedf(time_left, 0.01),
        "time_limit": snappedf(_get_run_time_limit(), 0.01),
        "drill_left": snappedf(drill_health, 0.01),
        "drill_max": snappedf(_get_drill_health_max(), 0.01),
        "cargo_capacity": _get_cargo_capacity(),
        "simulated_seconds": snappedf(simulation_elapsed, 0.01),
        "projected_data": projected_data,
        "level_progress": level_progress.duplicate(true)
    }

func _trigger_run_end(reason_key: String) -> void:
    if run_state != RUN_STATES.RUNNING:
        return
    if reason_key == RUN_REASON_TIMER_EXPIRED and not simulation_mode_active:
        run_state = RUN_STATES.ENDING
        run_end_reason_key = reason_key
        run_end_timer = 0.0
        run_end_spark_timer = 0.0
        run_end_initial_heading = _get_drill_heading()
        if run_end_initial_heading == Vector2.ZERO:
            run_end_initial_heading = Vector2.DOWN
        run_end_turn_sign = -1.0 if rng.randf() < 0.5 else 1.0
        var steer_cross: float = last_steer_direction.cross(run_end_initial_heading)
        if absf(steer_cross) > 0.001:
            run_end_turn_sign = signf(steer_cross)
        move_input_strength = 0.0
        straight_drive_charge = 0.0
        attached_node_id = -1
        contact_node_id = -1
        target_node_id = -1
        run_status = tr(reason_key)
        camera_shake_strength = max(camera_shake_strength, 6.0)
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BLACK_HOLE_COLLAPSE, -14.0, -0.24)
        _play_mining_donk(-7.0)
        _refresh_mouse_capture_state()
        return
    _finish_run(reason_key)

func _finish_run(reason_key: String) -> void:
    if run_state == RUN_STATES.SUMMARY:
        return
    if _is_multi_mode_challenge_active() and not multi_mode_step_reported:
        multi_mode_step_reported = true
        if _is_open_pit_defense_challenge_active():
            _complete_open_pit_defense_challenge(false, {
                "reason": reason_key,
                "nodes_broken": nodes_broken,
                "depth_level": active_depth_level,
                "elapsed": maxf(0.0, _get_run_time_limit() - time_left),
                "time_remaining": maxf(0.0, time_left),
                "time_limit": _get_run_time_limit()
            })
            return
        run_state = RUN_STATES.SUMMARY
        MULTI_GAME_MODE.complete_current_step(false, {
            "reason": reason_key,
            "nodes_broken": nodes_broken,
            "depth_level": active_depth_level,
            "elapsed": maxf(0.0, _get_run_time_limit() - time_left),
            "time_remaining": maxf(0.0, time_left),
            "time_limit": _get_run_time_limit()
        })
        return
    var was_ending: bool = run_state == RUN_STATES.ENDING
    var ending_overlay_alpha: float = _get_run_end_overlay_alpha() if was_ending else 0.0
    _bank_cargo_if_at_base()
    _bank_pending_delivery_drone_visuals()
    for material_id_variant in carry_counts.keys():
        var material_id: String = String(material_id_variant)
        banked_counts[material_id] = int(banked_counts.get(material_id, 0)) + int(carry_counts[material_id])
    carry_counts.clear()
    cargo_used = 0

    var results: Dictionary = _build_run_results(reason_key)
    last_run_results = results.duplicate(true)
    var previous_rank: int = MINING_PROGRESS_SCRIPT.get_rank(persistent_data)
    var previous_display_tier: int = MINING_PROGRESS_SCRIPT.get_display_depth_tier(int(persistent_data.get("deepest_level_unlocked", MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL)))
    var run_seconds: float = max(0.0, float(results.get("simulated_seconds", 0.0)))
    var projected_data: Dictionary = results.get("projected_data", persistent_data)
    var projected_display_tier: int = MINING_PROGRESS_SCRIPT.get_display_depth_tier(int(projected_data.get("deepest_level_unlocked", MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL)))
    if simulation_commit_progress:
        SaveHandler.fishing_run_clock_seconds = max(0.0, SaveHandler.fishing_run_clock_seconds + run_seconds)
        persistent_data = MINING_PROGRESS_SCRIPT.apply_run_results(results)
        if previous_display_tier < 8 and projected_display_tier >= 8:
            var tier8_time_seconds: float = SaveHandler.fishing_run_clock_seconds
            var registered_time: bool = SaveHandler.register_deepcore_tier8_time(tier8_time_seconds)
            if registered_time and bool(ProjectSettings.get_setting("global/Demo", false)) and SteamHandler != null and SteamHandler.has_method("submit_deepcore_tier8_time"):
                SteamHandler.submit_deepcore_tier8_time(tier8_time_seconds)
        else:
            SaveHandler.save_fishing_progress()
    else:
        persistent_data = results.get("projected_data", persistent_data).duplicate(true)
    run_state = RUN_STATES.SUMMARY
    summary_transition_active = was_ending
    summary_transition_timer = 0.0
    summary_transition_start_dim_alpha = ending_overlay_alpha
    Global.game_state = Util.GAME_STATES.UPGRADES if simulation_commit_progress else Util.GAME_STATES.PLAYING
    run_status = tr(reason_key)
    _refresh_mouse_capture_state()
    if simulation_commit_progress and not simulation_mode_active:
        _show_summary(results)

func _show_summary(results: Dictionary) -> void:
    summary_stats_label.text = str(results.get("summary_stats_text", ""))
    dive_button.text = tr("MINING_SUMMARY_RETURN_UPGRADES")
    reset_button.text = tr("MINING_SUMMARY_RUN_AGAIN")
    _setup_summary_hints(results)
    _refresh_summary_hint()
    _refresh_summary_charts(results)
    _show_summary_text(results)
    _start_summary_chart_animation()
    shop_panel.modulate = Color(1.0, 1.0, 1.0, 0.0) if summary_transition_active else Color(1.0, 1.0, 1.0, 1.0)
    shop_panel.show()
    hint_panel.hide()
    hint_label.text = ""

func _on_summary_return_pressed() -> void:
    if run_state != RUN_STATES.SUMMARY:
        return
    Global.start_in_upgrade_scene = true
    SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _on_summary_retry_pressed() -> void:
    if run_state != RUN_STATES.SUMMARY:
        return
    _begin_run()

func _configure_summary_panel() -> void:
    shop_panel.hide()
    shop_panel.set_anchors_preset(Control.PRESET_CENTER)
    shop_panel.custom_minimum_size = Vector2(1380.0, 810.0)
    shop_panel.offset_left = -690.0
    shop_panel.offset_top = -445.0
    shop_panel.offset_right = 690.0
    shop_panel.offset_bottom = 365.0
    checkpoint_header.hide()
    checkpoint_list.hide()
    loadout_header.hide()
    loadout_list.hide()
    upgrade_header.hide()
    upgrade_scroll.hide()
    summary_label.add_theme_font_size_override("normal_font_size", 20)
    summary_label.fit_content = true
    summary_label.scroll_active = false
    summary_stats_label.add_theme_font_size_override("font_size", 19)
    dive_button.add_theme_font_size_override("font_size", 30)
    reset_button.add_theme_font_size_override("font_size", 30)
    _style_utility_button(dive_button)
    _style_utility_button(reset_button)

func _refresh_hud() -> void:
    if not _is_ui_ready():
        return
    var projected_xp: int = MINING_PROGRESS_SCRIPT.get_rank_xp(persistent_data) + run_xp
    var projected_level: int = MINING_PROGRESS_SCRIPT.get_rank_for_total_xp(projected_xp)
    var level_progress: Dictionary = MINING_PROGRESS_SCRIPT.get_rank_progress(_make_rank_progress_data(projected_level, projected_xp))
    var display_depth_level: int = _get_display_depth_tier_for_run_depth(active_depth_level)
    var display_depth_max: int = MINING_PROGRESS_SCRIPT.get_max_display_depth_tier()
    var display_depth_unlocked: int = _get_display_depth_tier_for_run_depth(int(persistent_data.get("deepest_level_unlocked", MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL)))
    var run_time_limit: float = _get_run_time_limit()
    var drill_health_max: float = _get_drill_health_max()
    var cargo_capacity: int = _get_cargo_capacity()
    var xp_current: int = int(level_progress.get("current_xp", 0))
    var xp_next: int = max(1, int(level_progress.get("next_rank_xp", level_progress.get("next_level_xp", 1))))
    wallet_label.text = _trf("MINING_HUD_WALLET", [Util.get_number_short_text(int(persistent_data.get("wallet", 0)))])
    phase_label.text = _trf("MINING_HUD_PHASE", [display_depth_level, display_depth_max, String(active_material.get("name", tr("MINING_MATERIAL_STONE_NAME")))])
    depth_label.text = _format_depth_status_text(display_depth_unlocked, projected_level)
    time_value_label.text = _trf("MINING_HUD_TIMER", [snappedf(time_left, 0.1), snappedf(run_time_limit, 0.1)])
    time_bar.max_value = run_time_limit
    time_bar.value = time_left
    drill_value_label.text = _trf("MINING_HUD_DRILL", [int(round(drill_health)), int(round(drill_health_max))])
    drill_bar.max_value = drill_health_max
    drill_bar.value = drill_health
    cargo_value_label.text = _trf("MINING_HUD_CARGO", [cargo_used, cargo_capacity, _get_total_banked_count()])
    cargo_bar.max_value = cargo_capacity
    cargo_bar.value = cargo_used
    _update_warning_meter_blinks(run_time_limit, drill_health_max)
    xp_value_label.text = _format_rank_xp_status_text(xp_current, xp_next, run_xp)
    xp_bar.max_value = xp_next
    xp_bar.value = xp_current
    _process_level_up_feedback(projected_level)
    weapon_label.text = _trf("MINING_HUD_RIG_STATS", [int(round(_get_move_speed())), int(round(_get_drill_dps())), int(round(_get_pickup_radius())), int(round((_get_straight_drive_speed_multiplier() - 1.0) * 100.0)), int(round((_get_xp_multiplier() - 1.0) * 100.0))])
    boss_label.text = _trf("MINING_HUD_STATUS", [_get_display_run_status(true)])

func _apply_hud_theme() -> void:
    _style_panel(top_panel, Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 0.0), 6)
    _style_panel(shop_panel, Color(0.04, 0.06, 0.1, 0.97), Color(0.88, 0.92, 1.0, 0.95), 6)
    _style_panel(summary_stats_panel, Color(0.05, 0.09, 0.16, 0.94), Color(0.31, 0.63, 0.89, 0.9), 6)
    _style_panel(money_chart, Color(0.05, 0.09, 0.16, 0.94), Color(0.31, 0.63, 0.89, 0.9), 6)
    _style_panel(performance_chart, Color(0.05, 0.09, 0.16, 0.94), Color(0.31, 0.63, 0.89, 0.9), 6)
    _style_panel(summary_hint_panel, Color(0.05, 0.09, 0.16, 0.94), Color(0.31, 0.63, 0.89, 0.9), 6)
    _style_panel(hint_panel, Color(0.04, 0.06, 0.1, 0.9), Color(0.88, 0.92, 1.0, 0.82), 6)
    _style_meter(time_bar, Color(0.9, 0.69, 0.2, 0.96))
    _style_meter(drill_bar, Color(0.41, 0.79, 1.0, 0.96))
    _style_meter(cargo_bar, Color(0.8, 0.57, 0.22, 0.96))
    _style_meter(xp_bar, Color(0.37, 0.82, 0.67, 0.96))
    _style_hud_label(wallet_label, 26, Color(0.96, 0.98, 1.0, 1.0))
    _style_hud_label(phase_label, 34, Color(1.0, 0.87, 0.48, 1.0))
    _style_hud_label(depth_label, 24, Color(0.83, 0.9, 1.0, 1.0))
    _style_hud_label(time_value_label, 22, Color(1.0, 0.88, 0.56, 1.0))
    _style_hud_label(drill_value_label, 22, Color(0.74, 0.91, 1.0, 1.0))
    _style_hud_label(cargo_value_label, 22, Color(0.97, 0.83, 0.61, 1.0))
    _style_hud_label(xp_value_label, 22, Color(0.76, 1.0, 0.9, 1.0))
    _style_hud_label(weapon_label, 20, Color(0.88, 0.94, 1.0, 0.96))
    _style_hud_label(boss_label, 22, Color(0.98, 0.95, 0.77, 1.0))
    _style_hud_label(hint_label, 20, Color(0.92, 0.96, 1.0, 1.0))
    _style_hud_rich_text_label(summary_label, 20, SUMMARY_TEXT_BASE_COLOR)
    _style_hud_label(summary_stats_label, 19, Color(0.9, 0.95, 1.0, 1.0))
    _style_hud_label(hint_title_label, 20, Color(0.76, 0.9, 1.0, 1.0))
    _style_hud_label(summary_hint_label, 22, Color(0.92, 0.96, 1.0, 1.0))
    _style_utility_button(hint_left_button)
    _style_utility_button(hint_right_button)

func _make_rank_progress_data(rank: int, rank_xp: int) -> Dictionary:
    return {
        MINING_PROGRESS_SCRIPT.RANK_LEVEL_KEY: rank,
        MINING_PROGRESS_SCRIPT.RANK_XP_KEY: rank_xp,
        "player_level": rank,
        "xp": rank_xp,
    }

func _format_depth_status_text(unlocked_depth: int, current_rank: int) -> String:
    return _trf("Unlocked Depth: %d   %s: %d", [unlocked_depth, MINING_BALANCE.get_rank_label(), current_rank])

func _format_rank_xp_status_text(current_xp: int, next_xp: int, run_gain: int) -> String:
    return _trf("%s %d / %d   Dive +%d", [MINING_BALANCE.get_rank_xp_label(), current_xp, next_xp, run_gain])

func _format_rank_summary_text(rank: int, current_xp: int, next_xp: int) -> String:
    return _trf("%s %d   %s %d/%d", [MINING_BALANCE.get_rank_label(), rank, MINING_BALANCE.get_rank_xp_label(), current_xp, next_xp])

func _setup_run_start_banner() -> void:
    if top_bar == null or run_start_banner_panel != null:
        return
    var canvas_layer: Node = top_bar.get_parent()
    if canvas_layer == null:
        return

    run_start_banner_panel = PanelContainer.new()
    run_start_banner_panel.name = "RunStartBanner"
    run_start_banner_panel.anchor_left = 0.5
    run_start_banner_panel.anchor_top = 0.0
    run_start_banner_panel.anchor_right = 0.5
    run_start_banner_panel.anchor_bottom = 0.0
    run_start_banner_panel.offset_left = -290.0
    run_start_banner_panel.offset_top = 34.0
    run_start_banner_panel.offset_right = 290.0
    run_start_banner_panel.offset_bottom = 162.0
    run_start_banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    run_start_banner_panel.visible = false
    run_start_banner_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
    canvas_layer.add_child(run_start_banner_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 20)
    margin.add_theme_constant_override("margin_top", 16)
    margin.add_theme_constant_override("margin_right", 20)
    margin.add_theme_constant_override("margin_bottom", 16)
    run_start_banner_panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10)
    margin.add_child(vbox)

    var accent_line := ColorRect.new()
    accent_line.custom_minimum_size = Vector2(0.0, 5.0)
    accent_line.color = Color(0.92, 0.74, 0.28, 0.95)
    vbox.add_child(accent_line)

    run_start_banner_title_label = Label.new()
    run_start_banner_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    run_start_banner_title_label.add_theme_font_size_override("font_size", 28)
    run_start_banner_title_label.add_theme_color_override("font_color", Color(0.98, 0.95, 0.84, 1.0))
    vbox.add_child(run_start_banner_title_label)

    run_start_banner_detail_label = Label.new()
    run_start_banner_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    run_start_banner_detail_label.add_theme_font_size_override("font_size", 18)
    run_start_banner_detail_label.add_theme_color_override("font_color", Color(0.82, 0.93, 1.0, 0.96))
    vbox.add_child(run_start_banner_detail_label)

func _show_run_start_banner() -> void:
    if simulation_mode_active or run_start_banner_panel == null or run_start_banner_title_label == null or run_start_banner_detail_label == null:
        return
    if run_start_banner_tween != null and run_start_banner_tween.is_running():
        run_start_banner_tween.kill()

    var accent: Color = Color(active_material.get("color", Color(0.92, 0.74, 0.28, 1.0)))
    var bg: Color = Color(active_material.get("bg", Color(0.08, 0.09, 0.12, 1.0)))
    var style := StyleBoxFlat.new()
    style.bg_color = bg.darkened(0.38)
    style.bg_color.a = 0.93
    style.border_color = accent.lightened(0.22)
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.corner_radius_top_left = 7
    style.corner_radius_top_right = 7
    style.corner_radius_bottom_left = 7
    style.corner_radius_bottom_right = 7
    style.shadow_size = 10
    style.shadow_color = Color(0.0, 0.0, 0.0, 0.32)
    run_start_banner_panel.add_theme_stylebox_override("panel", style)

    var rank: int = MINING_PROGRESS_SCRIPT.get_rank(persistent_data)
    var depth_tier: int = _get_display_depth_tier_for_run_depth(active_depth_level)
    run_start_banner_title_label.text = tr("DIVE %02d  |  %s STRATUM") % [depth_tier, String(active_material.get("name", tr("MINING_MATERIAL_STONE_NAME"))).to_upper()]
    run_start_banner_detail_label.text = tr("%s %d   |   Surface rig hot   |   Cargo lane online") % [MINING_BALANCE.get_rank_label(), rank]
    run_start_banner_title_label.add_theme_color_override("font_color", accent.lightened(0.18))

    run_start_banner_panel.visible = true
    run_start_banner_panel.scale = Vector2(0.96, 0.96)
    run_start_banner_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
    run_start_banner_tween = create_tween()
    run_start_banner_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    run_start_banner_tween.parallel().tween_property(run_start_banner_panel, "modulate:a", 1.0, 0.18)
    run_start_banner_tween.parallel().tween_property(run_start_banner_panel, "scale", Vector2.ONE, 0.18)
    run_start_banner_tween.tween_interval(RUN_START_BANNER_HOLD_DURATION)
    run_start_banner_tween.tween_property(run_start_banner_panel, "modulate:a", 0.0, RUN_START_BANNER_FADE_DURATION)
    run_start_banner_tween.finished.connect(func() -> void:
        if run_start_banner_panel != null:
            run_start_banner_panel.visible = false
    )

func _style_hud_label(label: Label, font_size: int, color: Color) -> void:
    if label == null:
        return
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)

func _style_hud_rich_text_label(label: RichTextLabel, font_size: int, color: Color) -> void:
    if label == null:
        return
    label.add_theme_font_size_override("normal_font_size", font_size)
    label.add_theme_color_override("default_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)

func _style_meter(bar: ProgressBar, fill_color: Color) -> void:
    if bar == null:
        return
    var background := StyleBoxFlat.new()
    background.bg_color = Color(0.01, 0.02, 0.05, 0.82)
    background.border_color = Color(0.84, 0.9, 1.0, 0.6)
    background.border_width_left = 2
    background.border_width_top = 2
    background.border_width_right = 2
    background.border_width_bottom = 2
    background.corner_radius_top_left = 5
    background.corner_radius_top_right = 5
    background.corner_radius_bottom_left = 5
    background.corner_radius_bottom_right = 5
    var fill := background.duplicate(true)
    fill.bg_color = fill_color
    fill.border_color = fill_color.lightened(0.12)
    bar.add_theme_stylebox_override("background", background)
    bar.add_theme_stylebox_override("fill", fill)

func _get_shared_warning_blink_phase() -> float:
    return 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * TAU * WARNING_BAR_BLINK_HZ)

func _apply_warning_meter_blink(bar: ProgressBar, base_fill: Color, blink_strength: float, accent_color: Color) -> void:
    if bar == null:
        return
    var fill := bar.get_theme_stylebox("fill") as StyleBoxFlat
    var background := bar.get_theme_stylebox("background") as StyleBoxFlat
    if fill == null or background == null:
        return
    var base_fill_border := base_fill.lightened(0.12)
    var base_background_border := Color(0.84, 0.9, 1.0, 0.6)
    var pulse: float = _get_shared_warning_blink_phase()
    var blink_boost: float = clampf(blink_strength, 0.0, 1.0) * pulse
    fill.bg_color = base_fill.lerp(accent_color, 0.95 * blink_boost)
    fill.border_color = base_fill_border.lerp(Color.WHITE, 0.95 * blink_boost)
    background.border_color = base_background_border.lerp(accent_color.lightened(0.12), 0.95 * blink_boost)
    bar.scale = Vector2.ONE.lerp(Vector2.ONE * 1.05, blink_boost)

func _get_low_meter_warning_strength(current_value: float, max_value: float) -> float:
    if max_value <= 0.0:
        return 0.0
    var ratio: float = clampf(current_value / max_value, 0.0, 1.0)
    if ratio > WARNING_BAR_BLINK_THRESHOLD:
        return 0.0
    return 1.0 - ratio / WARNING_BAR_BLINK_THRESHOLD

func _update_warning_meter_blinks(run_time_limit: float, drill_health_max: float) -> void:
    var cargo_ratio: float = clampf(cargo_bar_reject_blink_timer / CARGO_BAR_REJECT_BLINK_DURATION, 0.0, 1.0)
    _apply_warning_meter_blink(
        time_bar,
        Color(0.9, 0.69, 0.2, 0.96),
        _get_low_meter_warning_strength(time_left, run_time_limit),
        Color(1.0, 0.8, 0.34, 1.0)
    )
    _apply_warning_meter_blink(
        drill_bar,
        Color(0.41, 0.79, 1.0, 0.96),
        _get_low_meter_warning_strength(drill_health, drill_health_max),
        Color(1.0, 0.64, 0.54, 1.0)
    )
    _apply_warning_meter_blink(
        cargo_bar,
        Color(0.8, 0.57, 0.22, 0.96),
        cargo_ratio,
        Color(1.0, 0.93, 0.56, 1.0)
    )
    _update_xp_bar_level_up_flash()

func _update_xp_bar_level_up_flash() -> void:
    if xp_bar == null:
        return
    var fill := xp_bar.get_theme_stylebox("fill") as StyleBoxFlat
    var background := xp_bar.get_theme_stylebox("background") as StyleBoxFlat
    if fill == null or background == null:
        return
    var base_fill := Color(0.37, 0.82, 0.67, 0.96)
    var base_fill_border := base_fill.lightened(0.12)
    var base_background_border := Color(0.84, 0.9, 1.0, 0.6)
    var flash_ratio: float = clampf(xp_bar_level_up_flash_timer / XP_BAR_LEVEL_UP_FLASH_DURATION, 0.0, 1.0)
    var pulse: float = _get_shared_warning_blink_phase()
    var flash_boost: float = flash_ratio * (0.72 + 0.28 * pulse)
    fill.bg_color = base_fill.lerp(Color(1.0, 0.96, 0.54, 1.0), 0.95 * flash_boost)
    fill.border_color = base_fill_border.lerp(Color(1.0, 0.99, 0.9, 1.0), flash_boost)
    background.border_color = base_background_border.lerp(Color(1.0, 0.88, 0.46, 0.98), 0.9 * flash_boost)

func _reset_xp_bar_level_feedback() -> void:
    if xp_bar_pop_tween != null and xp_bar_pop_tween.is_running():
        xp_bar_pop_tween.kill()
    xp_bar_pop_tween = null
    xp_bar_level_up_flash_timer = 0.0
    if xp_bar != null:
        xp_bar.scale = Vector2.ONE
    if xp_value_label != null:
        xp_value_label.scale = Vector2.ONE

func _process_level_up_feedback(projected_level: int) -> void:
    if run_state != RUN_STATES.RUNNING:
        hud_last_reported_level = projected_level
        return
    if projected_level < hud_last_reported_level:
        hud_last_reported_level = projected_level
        _reset_xp_bar_level_feedback()
        return
    if projected_level == hud_last_reported_level:
        return
    var level_gain: int = projected_level - hud_last_reported_level
    hud_last_reported_level = projected_level
    _play_level_up_feedback(level_gain)

func _play_level_up_feedback(level_gain: int) -> void:
    if xp_bar == null:
        return
    if xp_bar_pop_tween != null and xp_bar_pop_tween.is_running():
        xp_bar_pop_tween.kill()
    xp_bar.scale = Vector2.ONE
    if xp_value_label != null:
        xp_value_label.scale = Vector2.ONE
    xp_bar_level_up_flash_timer = XP_BAR_LEVEL_UP_FLASH_DURATION
    xp_bar_pop_tween = create_tween()
    xp_bar_pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    xp_bar_pop_tween.parallel().tween_property(xp_bar, "scale", Vector2.ONE * XP_BAR_LEVEL_UP_POP_SCALE, 0.11)
    if xp_value_label != null:
        xp_bar_pop_tween.parallel().tween_property(xp_value_label, "scale", Vector2.ONE * 1.05, 0.11)
    xp_bar_pop_tween.tween_interval(0.03)
    xp_bar_pop_tween.parallel().tween_property(xp_bar, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    if xp_value_label != null:
        xp_bar_pop_tween.parallel().tween_property(xp_value_label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    if simulation_mode_active:
        return
    for _i in range(level_gain):
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.MINING_LEVEL_UP)

func _style_panel(panel: PanelContainer, background_color: Color, border_color: Color, corner_radius: int) -> void:
    if panel == null:
        return
    var box := StyleBoxFlat.new()
    box.bg_color = background_color
    box.border_color = border_color
    box.border_width_left = 2
    box.border_width_top = 2
    box.border_width_right = 2
    box.border_width_bottom = 2
    box.corner_radius_top_left = corner_radius
    box.corner_radius_top_right = corner_radius
    box.corner_radius_bottom_left = corner_radius
    box.corner_radius_bottom_right = corner_radius
    panel.add_theme_stylebox_override("panel", box)

func _build_summary_stats_text(stats: Dictionary) -> String:
    var lines := PackedStringArray()
    lines.append(_trf("MINING_SUMMARY_STATS_LINE_1", [
        "%.2f" % float(stats.get("time_spent", 0.0)),
        "%.2f" % float(stats.get("money_per_second", 0.0)),
        "%.2f" % float(stats.get("xp_per_second", 0.0)),
        "%.2f" % float(stats.get("ore_per_second", 0.0))
    ]))
    lines.append(_trf("MINING_SUMMARY_STATS_LINE_2", [
        int(stats.get("ore_spawned", 0)),
        int(stats.get("ore_collected", 0)),
        int(stats.get("ore_left_behind", 0)),
        int(stats.get("ore_banked", 0))
    ]))
    lines.append(_trf("MINING_SUMMARY_STATS_LINE_3", [
        int(stats.get("player_pickups_collected", 0)),
        int(stats.get("drone_pickups_collected", 0)),
        int(stats.get("delivery_dumps", 0)),
        bank_trips
    ]))
    lines.append(_trf("MINING_SUMMARY_STATS_LINE_4", [
        int(round(float(stats.get("collection_rate", 0.0)) * 100.0)),
        int(round(float(stats.get("bank_rate", 0.0)) * 100.0))
    ]))
    return "\n".join(lines)

func _setup_summary_hints(results: Dictionary = {}) -> void:
    var hint_data: Dictionary = _build_summary_hint_data(results)
    mining_summary_hints = hint_data.get("all_hints", [])
    if mining_summary_hints.is_empty():
        mining_summary_hints.append(tr("MINING_HINT_FALLBACK"))
    var ranked_hints: Array[String] = hint_data.get("ranked_hints", [])
    mining_summary_hint_index = _select_summary_hint_index(ranked_hints)
    _remember_displayed_summary_hint()

func _build_summary_hint_data(results: Dictionary) -> Dictionary:
    var all_hints: Array[String] = []
    var ranked_hints: Array[String] = []
    if results.is_empty():
        _append_unique_summary_hint(all_hints, tr("MINING_HINT_FALLBACK"))
        _append_unique_summary_hint(ranked_hints, tr("MINING_HINT_FALLBACK"))
        return {
            "all_hints": all_hints,
            "ranked_hints": ranked_hints,
        }

    var reason_key: String = String(results.get("reason_key", ""))
    var ore_left_behind: int = int(results.get("ore_left_behind", 0))
    var ore_spawned: int = int(results.get("ore_spawned", 0))
    var collection_rate: float = float(results.get("collection_rate", 0.0))
    var remaining_nodes: int = int(results.get("remaining_nodes", 0))
    var total_nodes_seen: int = int(results.get("total_nodes_seen", 0))
    var untouched_ratio: float = 0.0 if total_nodes_seen <= 0 else float(remaining_nodes) / float(total_nodes_seen)
    var left_many_pickups: bool = ore_left_behind >= 10 or (ore_spawned >= 12 and collection_rate <= 0.55)
    var left_many_nodes: bool = remaining_nodes >= 28 and untouched_ratio >= 0.72
    var pickup_radius_missing: bool = _get_upgrade_level("pickup_radius") <= 0
    var magnet_drone_missing: bool = _get_upgrade_level("magnet_drone") <= 0
    var delivery_drone_missing: bool = _get_upgrade_level("delivery_drone") <= 0

    var pickup_radius_context_hint := tr("MINING_HINT_CONTEXT_PICKUP_RADIUS")
    var magnet_drone_context_hint := tr("MINING_HINT_CONTEXT_MAGNET_DRONE")
    var loopback_hint := tr("MINING_HINT_CONTEXT_LOOPBACK")
    var routing_hint := tr("MINING_HINT_CONTEXT_ROUTING")
    var drill_hint := tr("MINING_HINT_CONTEXT_DRILL")
    var timer_hint := tr("MINING_HINT_CONTEXT_TIMER")
    var pickup_radius_upgrade_hint := tr("MINING_HINT_UPGRADE_PICKUP_RADIUS")
    var magnet_drone_upgrade_hint := tr("MINING_HINT_UPGRADE_MAGNET_DRONE")
    var delivery_drone_upgrade_hint := tr("MINING_HINT_UPGRADE_DELIVERY_DRONE")
    var fallback_hint := tr("MINING_HINT_FALLBACK")

    if left_many_pickups:
        if pickup_radius_missing:
            _append_unique_summary_hint(ranked_hints, pickup_radius_context_hint)
        elif magnet_drone_missing:
            _append_unique_summary_hint(ranked_hints, magnet_drone_context_hint)
        else:
            _append_unique_summary_hint(ranked_hints, loopback_hint)
    if left_many_nodes:
        _append_unique_summary_hint(ranked_hints, routing_hint)
    if reason_key == RUN_REASON_DRILL_DEPLETED:
        _append_unique_summary_hint(ranked_hints, drill_hint)
    if reason_key == RUN_REASON_TIMER_EXPIRED:
        _append_unique_summary_hint(ranked_hints, timer_hint)
    if pickup_radius_missing:
        _append_unique_summary_hint(ranked_hints, pickup_radius_upgrade_hint)
    if magnet_drone_missing:
        _append_unique_summary_hint(ranked_hints, magnet_drone_upgrade_hint)
    if delivery_drone_missing:
        _append_unique_summary_hint(ranked_hints, delivery_drone_upgrade_hint)
    for hint_key in DEFAULT_MINING_SUMMARY_HINTS:
        _append_unique_summary_hint(ranked_hints, tr(hint_key))
    _append_unique_summary_hint(ranked_hints, fallback_hint)

    if left_many_pickups:
        _append_unique_summary_hint(all_hints, pickup_radius_context_hint)
        _append_unique_summary_hint(all_hints, magnet_drone_context_hint)
        _append_unique_summary_hint(all_hints, loopback_hint)
    if left_many_nodes:
        _append_unique_summary_hint(all_hints, routing_hint)
    if reason_key == RUN_REASON_DRILL_DEPLETED:
        _append_unique_summary_hint(all_hints, drill_hint)
    if reason_key == RUN_REASON_TIMER_EXPIRED:
        _append_unique_summary_hint(all_hints, timer_hint)
    if pickup_radius_missing:
        _append_unique_summary_hint(all_hints, pickup_radius_upgrade_hint)
    if magnet_drone_missing:
        _append_unique_summary_hint(all_hints, magnet_drone_upgrade_hint)
    if delivery_drone_missing:
        _append_unique_summary_hint(all_hints, delivery_drone_upgrade_hint)
    for hint_key in DEFAULT_MINING_SUMMARY_HINTS:
        _append_unique_summary_hint(all_hints, tr(hint_key))
    _append_unique_summary_hint(all_hints, fallback_hint)
    return {
        "all_hints": all_hints,
        "ranked_hints": ranked_hints,
    }

func _append_unique_summary_hint(target: Array[String], hint: String) -> void:
    if hint.is_empty() or target.has(hint):
        return
    target.append(hint)

func _select_summary_hint_index(ranked_hints: Array[String]) -> int:
    if mining_summary_hints.is_empty():
        return 0
    var recent_history: Array[String] = _get_recent_summary_hint_history()
    var top_choices: Array[String] = []
    for hint in ranked_hints:
        if top_choices.size() >= MINING_SUMMARY_HINT_HISTORY_LIMIT:
            break
        if mining_summary_hints.has(hint):
            top_choices.append(hint)

    if top_choices.is_empty():
        return 0

    var last_hint: String = recent_history[0] if not recent_history.is_empty() else ""
    if top_choices.size() >= 3 and recent_history.size() >= 3:
        var recent_top_match := true
        for index in range(3):
            if not top_choices.has(recent_history[index]):
                recent_top_match = false
                break
        if recent_top_match:
            return randi() % mining_summary_hints.size()
    if top_choices.size() >= 2 and last_hint == top_choices[0]:
        return mining_summary_hints.find(top_choices[1])
    if top_choices.size() >= 3 and recent_history.has(top_choices[0]) and recent_history.has(top_choices[1]):
        return mining_summary_hints.find(top_choices[2])
    if top_choices.size() >= 2 and recent_history.has(top_choices[0]) and recent_history.has(top_choices[1]):
        return randi() % mining_summary_hints.size()
    return mining_summary_hints.find(top_choices[0])

func _get_recent_summary_hint_history() -> Array[String]:
    var history: Array[String] = []
    var saved_history: Variant = persistent_data.get("summary_hint_history", [])
    if saved_history is Array:
        for entry in saved_history:
            var hint_text: String = String(entry)
            if hint_text.is_empty():
                continue
            history.append(hint_text)
            if history.size() >= MINING_SUMMARY_HINT_HISTORY_LIMIT:
                break
    return history

func _remember_displayed_summary_hint() -> void:
    if mining_summary_hints.is_empty():
        return
    mining_summary_hint_index = wrapi(mining_summary_hint_index, 0, mining_summary_hints.size())
    var selected_hint: String = mining_summary_hints[mining_summary_hint_index]
    var history: Array[String] = _get_recent_summary_hint_history()
    history.erase(selected_hint)
    history.push_front(selected_hint)
    while history.size() > MINING_SUMMARY_HINT_HISTORY_LIMIT:
        history.pop_back()
    persistent_data["summary_hint_history"] = history
    MINING_PROGRESS_SCRIPT.save_data(persistent_data)

func _refresh_summary_hint() -> void:
    if mining_summary_hints.is_empty():
        hint_title_label.text = ""
        summary_hint_label.text = ""
        hint_left_button.hide()
        hint_right_button.hide()
        return
    mining_summary_hint_index = wrapi(mining_summary_hint_index, 0, mining_summary_hints.size())
    hint_title_label.text = _trf("MINING_HINT_TITLE", [mining_summary_hint_index + 1, mining_summary_hints.size()])
    summary_hint_label.text = mining_summary_hints[mining_summary_hint_index]
    var show_nav: bool = mining_summary_hints.size() > 1
    hint_left_button.visible = show_nav
    hint_right_button.visible = show_nav

func _on_summary_hint_left_button_pressed() -> void:
    mining_summary_hint_index -= 1
    _refresh_summary_hint()

func _on_summary_hint_right_button_pressed() -> void:
    mining_summary_hint_index += 1
    _refresh_summary_hint()

func _make_summary_chart_label(text: String, width: float, font_size: int, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, color: Color = Color(0.92, 0.97, 1.0, 1.0)) -> Label:
    var label := Label.new()
    label.text = text
    label.custom_minimum_size = Vector2(width, 0.0)
    label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if width > 0.0 else Control.SIZE_EXPAND_FILL
    label.horizontal_alignment = align
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.autowrap_mode = 3
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    return label

func _make_summary_chart_bar(value: float, max_value: float, color: Color) -> Control:
    var bar_bundle: Dictionary = _make_summary_chart_bar_bundle(max_value, color)
    var root: HBoxContainer = bar_bundle.get("root", HBoxContainer.new())
    var meter: ProgressBar = bar_bundle.get("meter", null)
    var value_label: Label = bar_bundle.get("value_label", null)
    if meter != null:
        meter.value = value
    if value_label != null:
        value_label.text = _format_summary_chart_value(value)
    return root

func _make_summary_chart_bar_bundle(max_value: float, color: Color) -> Dictionary:
    var root := HBoxContainer.new()
    root.custom_minimum_size = Vector2(220.0, 0.0)
    root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_theme_constant_override("separation", 8)

    var meter := ProgressBar.new()
    meter.custom_minimum_size = Vector2(140.0, 18.0)
    meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    meter.show_percentage = false
    meter.max_value = max(1.0, max_value)
    meter.value = 0.0

    var background := StyleBoxFlat.new()
    background.bg_color = Color(0.12, 0.18, 0.28, 0.96)
    background.corner_radius_top_left = 3
    background.corner_radius_top_right = 3
    background.corner_radius_bottom_left = 3
    background.corner_radius_bottom_right = 3
    meter.add_theme_stylebox_override("background", background)

    var fill := background.duplicate(true)
    fill.bg_color = color
    meter.add_theme_stylebox_override("fill", fill)
    root.add_child(meter)
    var value_label := _make_summary_chart_label("0", 58.0, 16, HORIZONTAL_ALIGNMENT_RIGHT, Color(0.82, 0.9, 1.0, 1.0))
    root.add_child(value_label)
    return {
        "root": root,
        "meter": meter,
        "value_label": value_label
    }

func _format_summary_chart_value(value: float) -> String:
    if value >= 1000.0:
        return "%0.1fk" % (value / 1000.0)
    if value >= 100.0:
        return str(int(round(value)))
    return "%0.1f" % value if value != floor(value) else str(int(value))

func _refresh_summary_charts(results: Dictionary) -> void:
    _reset_summary_chart_animation_state()
    _refresh_money_chart(results)
    _refresh_performance_chart(results)

func _refresh_money_chart(results: Dictionary) -> void:
    _clear_control_children(money_chart)
    var margin := _make_chart_margin(money_chart)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 10)
    margin.add_child(root)
    root.add_child(_make_summary_chart_label(tr("MINING_MONEY_CHART_TITLE"), 0.0, 24, HORIZONTAL_ALIGNMENT_CENTER))

    var rows: Array = results.get("money_breakdown_chart", [])
    if rows.is_empty():
        root.add_child(_make_summary_chart_label(tr("MINING_MONEY_CHART_EMPTY"), 0.0, 18, HORIZONTAL_ALIGNMENT_CENTER, Color(0.82, 0.88, 0.96, 0.92)))
        return
    var max_money: float = 0.0
    for row_variant in rows:
        var row_data: Dictionary = row_variant
        max_money = max(max_money, float(row_data.get("money", 0.0)))
    for row_variant in rows:
        var row_data: Dictionary = row_variant
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 10)
        root.add_child(row)
        row.add_child(_make_summary_chart_label(_trf("MINING_SUMMARY_TEXT_CARGO_LINE_SIMPLE", [str(row_data.get("label", tr("MINING_ORE_GENERIC"))), int(row_data.get("count", 0))]), 170.0, 17))
        var target_value: float = float(row_data.get("money", 0.0))
        var bar_bundle: Dictionary = _make_summary_chart_bar_bundle(max_money, row_data.get("color", Color(0.8, 0.8, 0.8, 1.0)))
        row.add_child(bar_bundle.get("root", HBoxContainer.new()))
        _register_summary_chart_animation(
            row,
            bar_bundle.get("meter", null),
            bar_bundle.get("value_label", null),
            target_value,
            _summary_chart_animation_duration(target_value, max_money)
        )

func _refresh_performance_chart(results: Dictionary) -> void:
    _clear_control_children(performance_chart)
    var margin := _make_chart_margin(performance_chart)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 10)
    margin.add_child(root)
    root.add_child(_make_summary_chart_label(tr("MINING_PERFORMANCE_TITLE"), 0.0, 24, HORIZONTAL_ALIGNMENT_CENTER))

    var rows: Array[Dictionary] = [
        {"label": tr("MINING_PERFORMANCE_ORE_COLLECTED"), "value": float(results.get("ore_collected", 0)), "color": Color(0.45, 0.87, 0.99, 1.0)},
        {"label": tr("MINING_PERFORMANCE_LEFT_BEHIND"), "value": float(results.get("ore_left_behind", 0)), "color": Color(0.93, 0.38, 0.35, 1.0)},
        {"label": tr("MINING_PERFORMANCE_COLLECTED_BY_DRONES"), "value": float(results.get("drone_pickups_collected", 0)), "color": Color(0.56, 0.92, 0.65, 1.0)},
        {"label": tr("MINING_PERFORMANCE_DELIVERED_BY_DRONES"), "value": float(results.get("delivery_dumps", 0)), "color": Color(1.0, 0.77, 0.31, 1.0)},
        {"label": tr("MINING_PERFORMANCE_NODES_BROKEN"), "value": float(results.get("nodes_broken", 0)), "color": Color(0.83, 0.74, 1.0, 1.0)}
    ]
    var max_value: float = 0.0
    for row_data in rows:
        max_value = max(max_value, float(row_data.get("value", 0.0)))
    for row_data in rows:
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 10)
        root.add_child(row)
        row.add_child(_make_summary_chart_label(str(row_data.get("label", "")), 190.0, 17))
        var target_value: float = float(row_data.get("value", 0.0))
        var bar_bundle: Dictionary = _make_summary_chart_bar_bundle(max_value, row_data.get("color", Color.WHITE))
        row.add_child(bar_bundle.get("root", HBoxContainer.new()))
        _register_summary_chart_animation(
            row,
            bar_bundle.get("meter", null),
            bar_bundle.get("value_label", null),
            target_value,
            _summary_chart_animation_duration(target_value, max_value)
        )

func _make_chart_margin(parent: Control) -> MarginContainer:
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_bottom", 12)
    parent.add_child(margin)
    return margin

func _clear_control_children(parent: Node) -> void:
    for child in parent.get_children():
        parent.remove_child(child)
        child.queue_free()

func _register_summary_chart_animation(row: Control, meter: ProgressBar, value_label: Label, target_value: float, duration: float) -> void:
    if row == null or meter == null or value_label == null:
        return
    row.scale = Vector2.ONE
    row.pivot_offset = row.size * 0.5
    summary_chart_animation_entries.append({
        "row": row,
        "meter": meter,
        "value_label": value_label,
        "target_value": max(0.0, target_value),
        "duration": max(0.01, duration),
        "elapsed": 0.0,
        "popped": false
    })

func _summary_chart_animation_duration(target_value: float, max_value: float) -> float:
    if max_value <= 0.0:
        return SUMMARY_CHART_ANIM_MIN_DURATION
    var normalized: float = clampf(target_value / max_value, 0.0, 1.0)
    return lerpf(SUMMARY_CHART_ANIM_MIN_DURATION, SUMMARY_CHART_ANIM_MAX_DURATION, pow(normalized, 0.58))

func _start_summary_chart_animation() -> void:
    summary_chart_animation_session_id += 1
    summary_chart_pop_tween_count = 0
    summary_chart_ding_played = false
    summary_chart_tick_timer = 0.0
    summary_chart_animation_active = not summary_chart_animation_entries.is_empty()
    for entry_index in range(summary_chart_animation_entries.size()):
        var entry: Dictionary = summary_chart_animation_entries[entry_index]
        var meter: ProgressBar = entry.get("meter", null)
        var value_label: Label = entry.get("value_label", null)
        if meter != null:
            meter.value = 0.0
        if value_label != null:
            value_label.text = "0"
        entry["elapsed"] = 0.0
        entry["popped"] = false
        summary_chart_animation_entries[entry_index] = entry
    if not summary_chart_animation_active:
        _play_summary_chart_completion_ding()

func _reset_summary_chart_animation_state() -> void:
    summary_chart_animation_active = false
    summary_chart_tick_timer = 0.0
    summary_chart_animation_entries.clear()
    summary_chart_pop_tween_count = 0
    summary_chart_ding_played = false
    summary_chart_animation_session_id += 1
    if summary_text_tween != null and summary_text_tween.is_running():
        summary_text_tween.kill()
    if summary_text_pop_tween != null and summary_text_pop_tween.is_running():
        summary_text_pop_tween.kill()
    summary_text_view_model.clear()
    summary_text_progress = 0.0
    summary_text_money_pop_progress = 0.0

func _process_summary_chart_animation(delta: float) -> void:
    if not summary_chart_animation_active:
        return
    var any_active: bool = false
    for entry_index in range(summary_chart_animation_entries.size()):
        var entry: Dictionary = summary_chart_animation_entries[entry_index]
        var meter: ProgressBar = entry.get("meter", null)
        var value_label: Label = entry.get("value_label", null)
        var row: Control = entry.get("row", null)
        var target_value: float = float(entry.get("target_value", 0.0))
        var duration: float = float(entry.get("duration", SUMMARY_CHART_ANIM_MIN_DURATION))
        var elapsed: float = min(duration, float(entry.get("elapsed", 0.0)) + delta)
        var progress: float = 1.0 if duration <= 0.0 else clampf(elapsed / duration, 0.0, 1.0)
        var eased_progress: float = 1.0 - pow(1.0 - progress, 3.0)
        var current_value: float = target_value * eased_progress
        if meter != null:
            meter.value = current_value
        if value_label != null:
            value_label.text = _format_summary_chart_value(current_value)
        if progress < 1.0:
            any_active = true
        elif not bool(entry.get("popped", false)):
            if meter != null:
                meter.value = target_value
            if value_label != null:
                value_label.text = _format_summary_chart_value(target_value)
            _play_summary_chart_pop(row)
            entry["popped"] = true
        entry["elapsed"] = elapsed
        summary_chart_animation_entries[entry_index] = entry
    if any_active:
        summary_chart_tick_timer += delta
        while summary_chart_tick_timer >= SUMMARY_CHART_TICK_INTERVAL:
            summary_chart_tick_timer -= SUMMARY_CHART_TICK_INTERVAL
            if AudioManager != null:
                AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)
    else:
        summary_chart_animation_active = false
        summary_chart_tick_timer = 0.0

func _play_summary_chart_completion_ding() -> void:
    if summary_chart_ding_played:
        return
    summary_chart_ding_played = true
    if AudioManager != null:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.MINING_SUMMARY_DING)

func _on_summary_chart_pop_tween_finished(session_id: int) -> void:
    if session_id != summary_chart_animation_session_id:
        return
    if run_state != RUN_STATES.SUMMARY:
        return
    summary_chart_pop_tween_count = max(0, summary_chart_pop_tween_count - 1)
    if not summary_chart_animation_active and summary_chart_pop_tween_count <= 0:
        _play_summary_chart_completion_ding()

func _play_summary_chart_pop(row: Control) -> void:
    if row == null:
        return
    row.scale = Vector2.ONE
    row.pivot_offset = row.size * 0.5
    summary_chart_pop_tween_count += 1
    var pop_tween: Tween = create_tween()
    pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    pop_tween.tween_property(row, "scale", Vector2.ONE * SUMMARY_CHART_POP_SCALE, 0.12)
    pop_tween.tween_property(row, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    var session_id := summary_chart_animation_session_id
    pop_tween.finished.connect(func() -> void:
        _on_summary_chart_pop_tween_finished(session_id)
    )

func _play_summary_text_pop() -> void:
    if summary_label == null or summary_text_view_model.is_empty():
        return
    if summary_text_pop_tween != null and summary_text_pop_tween.is_running():
        summary_text_pop_tween.kill()
    summary_text_money_pop_progress = 0.0
    summary_chart_pop_tween_count += 1
    summary_text_pop_tween = create_tween()
    summary_text_pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    summary_text_pop_tween.tween_method(
        func(pop_progress: float) -> void:
            summary_text_money_pop_progress = pop_progress
            _render_summary_text(summary_text_view_model, summary_text_progress),
        0.0,
        1.0,
        0.14
    )
    summary_text_pop_tween.tween_method(
        func(pop_progress: float) -> void:
            summary_text_money_pop_progress = pop_progress
            _render_summary_text(summary_text_view_model, summary_text_progress),
        1.0,
        0.0,
        0.12
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    var session_id := summary_chart_animation_session_id
    summary_text_pop_tween.finished.connect(func() -> void:
        summary_text_money_pop_progress = 0.0
        _render_summary_text(summary_text_view_model, summary_text_progress)
        _on_summary_chart_pop_tween_finished(session_id)
    )

func _get_total_count_from_dict(counts: Dictionary) -> int:
    var total := 0
    for value in counts.values():
        total += int(value)
    return total

func _get_total_banked_count() -> int:
    var total: int = 0
    for count in banked_counts.values():
        total += int(count)
    return total

func _show_summary_text(results: Dictionary) -> void:
    var summary_view_model: Dictionary = results.get("summary_view_model", {})
    if summary_view_model.is_empty():
        summary_text_view_model.clear()
        summary_text_progress = 0.0
        summary_text_money_pop_progress = 0.0
        summary_label.clear()
        summary_label.append_text(str(results.get("summary_text", tr("MINING_RUN_COMPLETE_FALLBACK"))))
        return
    if summary_text_tween != null and summary_text_tween.is_running():
        summary_text_tween.kill()
    if summary_text_pop_tween != null and summary_text_pop_tween.is_running():
        summary_text_pop_tween.kill()
    summary_text_view_model = summary_view_model.duplicate(true)
    summary_text_progress = 0.0
    summary_text_money_pop_progress = 0.0
    _render_summary_text(summary_text_view_model, 0.0)
    var total_money: float = float(summary_view_model.get("money_earned", 0))
    var duration: float = _get_summary_text_animation_duration(total_money)
    if duration <= 0.0:
        summary_text_progress = 1.0
        _render_summary_text(summary_text_view_model, 1.0)
        _play_summary_text_pop()
        return
    summary_text_tween = create_tween()
    summary_text_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    summary_text_tween.tween_method(
        func(progress: float) -> void:
            summary_text_progress = progress
            _render_summary_text(summary_text_view_model, progress),
        0.0,
        1.0,
        duration
    )
    summary_text_tween.finished.connect(func() -> void:
        summary_text_progress = 1.0
        _render_summary_text(summary_text_view_model, 1.0)
        _play_summary_text_pop()
    )

func _render_summary_text(summary_view_model: Dictionary, progress: float) -> void:
    var breakdown: Array = summary_view_model.get("money_breakdown_chart", [])
    var total_money: int = int(summary_view_model.get("money_earned", 0))
    var lines := PackedStringArray()
    lines.append(_trf("MINING_SUMMARY_TEXT_RUN_COMPLETE", [String(summary_view_model.get("reason", ""))]))
    lines.append("")
    lines.append(_trf("MINING_SUMMARY_TEXT_DEPTH_TIER", [
        _get_display_depth_tier_for_run_depth(int(summary_view_model.get("depth_level", MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL))),
        String(summary_view_model.get("depth_material_name", tr("MINING_MATERIAL_STONE_NAME")))
    ]))
    lines.append(_trf("MINING_SUMMARY_TEXT_NODES_BROKEN", [int(summary_view_model.get("nodes_broken", 0))]))
    lines.append(_trf("MINING_SUMMARY_TEXT_XP_EARNED", [
        int(summary_view_model.get("xp_earned", 0)),
        " %s" % tr("MINING_SUMMARY_LEVEL_UP") if bool(summary_view_model.get("ranked_up", false)) else ""
    ]))
    lines.append(_trf("MINING_SUMMARY_TEXT_MONEY_EARNED", [_format_summary_money_span(
        _get_animated_money_value(total_money, progress),
        total_money,
        1.0,
        progress
    )]))
    lines.append("")
    lines.append(tr("MINING_SUMMARY_TEXT_CARGO_PAYOUT"))
    if breakdown.is_empty():
        lines.append(tr("MINING_SUMMARY_TEXT_NO_CARGO"))
    else:
        for entry_variant in breakdown:
            var entry: Dictionary = entry_variant
            var subtotal: int = int(entry.get("money", 0))
            var contribution: float = 0.0 if total_money <= 0 else float(subtotal) / float(total_money)
            lines.append(_trf("MINING_SUMMARY_TEXT_CARGO_LINE", [
                String(entry.get("label", tr("MINING_ORE_GENERIC"))),
                int(entry.get("count", 0)),
                _format_summary_money_span(
                    _get_animated_money_value(subtotal, progress),
                    subtotal,
                    contribution,
                    progress
                )
            ]))
    lines.append("")
    lines.append(_trf("MINING_SUMMARY_TEXT_LEVEL", [
        int(summary_view_model.get("projected_rank", 1)),
        int(summary_view_model.get("rank_progress_current", 0)),
        int(summary_view_model.get("rank_progress_next", 1))
    ]))
    lines.append(_trf("MINING_SUMMARY_TEXT_UNLOCKED_DEPTH", [_get_display_depth_tier_for_run_depth(int(summary_view_model.get("projected_depth_unlock", MINING_PROGRESS_SCRIPT.MIN_START_DEPTH_LEVEL)))]))
    var level_bonus_note: String = String(summary_view_model.get("level_bonus_note", "")).strip_edges()
    if level_bonus_note != "":
        lines.append(level_bonus_note)
    var tier_unlock_note: String = String(summary_view_model.get("tier_unlock_note", "")).strip_edges()
    if tier_unlock_note != "":
        lines.append(tier_unlock_note)
    summary_label.clear()
    summary_label.append_text("[color=%s]%s[/color]" % [
        _color_to_bbcode(SUMMARY_TEXT_BASE_COLOR),
        "\n".join(lines)
    ])

func _get_animated_money_value(target_value: int, progress: float) -> int:
    var eased_progress: float = 0.5 - 0.5 * cos(PI * clampf(progress, 0.0, 1.0))
    return int(round(float(target_value) * eased_progress))

func _get_summary_text_animation_duration(total_money: float) -> float:
    var chart_duration: float = _get_summary_chart_max_duration()
    if chart_duration > 0.0:
        return chart_duration
    if total_money <= 0.0:
        return 0.0
    return _summary_chart_animation_duration(total_money, total_money)

func _get_summary_chart_max_duration() -> float:
    var longest_duration := 0.0
    for entry in summary_chart_animation_entries:
        longest_duration = max(longest_duration, float(entry.get("duration", 0.0)))
    return longest_duration

func _format_summary_money_span(current_value: int, target_value: int, contribution_ratio: float, progress: float) -> String:
    var contribution_color: Color = SUMMARY_TEXT_MONEY_GREY.lerp(
        SUMMARY_TEXT_MONEY_GREEN,
        clampf(contribution_ratio, 0.0, 1.0)
    )
    var animated_color: Color = SUMMARY_TEXT_MONEY_GREY.lerp(contribution_color, clampf(progress, 0.0, 1.0))
    var shown_value: int = clampi(current_value, 0, max(0, target_value))
    var money_font_size: int = int(round(lerpf(
        float(SUMMARY_TEXT_MONEY_BASE_FONT_SIZE),
        float(SUMMARY_TEXT_MONEY_POP_FONT_SIZE),
        clampf(summary_text_money_pop_progress, 0.0, 1.0)
    )))
    return "[font_size=%d][color=%s]$%s[/color][/font_size]" % [
        money_font_size,
        _color_to_bbcode(animated_color),
        Util.get_number_short_text(shown_value)
    ]

func _format_level_bonus_summary(level_bonus_gains: Dictionary) -> String:
    var bonus_parts := PackedStringArray()
    var speed_gain: float = float(level_bonus_gains.get("move_speed", 0.0))
    var drill_health_gain: float = float(level_bonus_gains.get("drill_health", 0.0))
    var time_gain: float = float(level_bonus_gains.get("run_time", 0.0))
    if speed_gain > 0.0:
        bonus_parts.append(_trf("+%d speed", [int(round(speed_gain))]))
    if drill_health_gain > 0.0:
        bonus_parts.append(_trf("+%d drill health", [int(round(drill_health_gain))]))
    if time_gain > 0.0:
        bonus_parts.append(_trf("+%.1fs timing", [snappedf(time_gain, 0.1)]))
    if bonus_parts.is_empty():
        return ""
    return _trf("Level bonus%s: %s", ["es" if bonus_parts.size() > 1 else "", ", ".join(bonus_parts)])

func _format_depth_unlock_summary(previous_depth_unlock: int, new_depth_unlock: int) -> String:
    if new_depth_unlock <= previous_depth_unlock:
        return ""
    var first_new_display_tier: int = _get_display_depth_tier_for_run_depth(previous_depth_unlock + 1)
    var latest_display_tier: int = _get_display_depth_tier_for_run_depth(new_depth_unlock)
    if first_new_display_tier == latest_display_tier:
        return _trf("New depth tier unlocked: %d", [latest_display_tier])
    return _trf("New depth tiers unlocked: %d-%d", [first_new_display_tier, latest_display_tier])

func _color_to_bbcode(color: Color) -> String:
    return color.to_html(false)

func _get_upgrade_levels() -> Dictionary:
    return persistent_data.get("upgrades", {})

func _get_level_bonus_totals() -> Dictionary:
    return MINING_BALANCE.get_level_bonus_totals_for_level(MINING_PROGRESS_SCRIPT.get_rank(persistent_data))

func _get_move_speed() -> float:
    return MINING_BALANCE.get_move_speed(_get_upgrade_levels(), _get_level_bonus_totals())

func _get_dirt_drag_multiplier() -> float:
    return MINING_BALANCE.get_dirt_drag_multiplier(active_depth_level, _get_upgrade_levels())

func _get_drill_dps() -> float:
    return MINING_BALANCE.get_drill_dps(_get_upgrade_levels()) * CROSS_GAME_BONUSES.get_target_bonus_multiplier(Util.ACTIVE_GAME_MINING)

func _get_drill_health_max() -> float:
    return MINING_BALANCE.get_drill_health_max(_get_upgrade_levels(), _get_level_bonus_totals())

func _get_run_time_limit() -> float:
    if _is_multi_mode_challenge_active():
        return float(multi_mode_step.get("time_limit", 20.0))
    return MINING_BALANCE.get_run_time_limit(_get_upgrade_levels(), _get_level_bonus_totals())

func _get_time_drain_rate() -> float:
    return MINING_BALANCE.get_time_drain_rate(active_depth_level, _get_upgrade_levels())

func _get_cargo_capacity() -> int:
    return MINING_BALANCE.get_cargo_capacity(_get_upgrade_levels())

func _get_material_cargo_space(material_id: String) -> int:
    if material_id == "":
        return 0
    return MINING_BALANCE.get_material_cargo_space(_get_material_by_id(material_id))

func _can_fit_material_in_cargo(material_id: String) -> bool:
    if material_id == "":
        return false
    return cargo_used + _get_material_cargo_space(material_id) <= _get_cargo_capacity()

func _add_cargo_material(material_id: String) -> bool:
    if not _can_fit_material_in_cargo(material_id):
        return false
    carry_counts[material_id] = int(carry_counts.get(material_id, 0)) + 1
    cargo_used += _get_material_cargo_space(material_id)
    return true

func _get_value_multiplier() -> float:
    return MINING_BALANCE.get_value_multiplier(_get_upgrade_levels())

func _get_xp_multiplier() -> float:
    return MINING_BALANCE.get_xp_multiplier(_get_upgrade_levels())

func _get_pickup_radius() -> float:
    return MINING_BALANCE.get_pickup_radius(_get_upgrade_levels())

func _get_drill_wear(node: Dictionary) -> float:
    return MINING_BALANCE.get_node_wear_per_second(node, _get_upgrade_levels())

func _get_pickup_drone_speed() -> float:
    return MINING_BALANCE.get_pickup_drone_speed(active_depth_level, _get_upgrade_levels())

func _get_delivery_drone_speed() -> float:
    return MINING_BALANCE.get_delivery_drone_speed(active_depth_level, _get_upgrade_levels())

func _get_delivery_dispatch_window() -> float:
    return MINING_BALANCE.get_delivery_dispatch_window(_get_upgrade_levels())

func _get_upgrade_level(upgrade_id: String) -> int:
    return int(_get_upgrade_levels().get(upgrade_id, 0))

func _update_straight_drive_charge(pointer_dir: Vector2, delta: float) -> void:
    if pointer_dir == Vector2.ZERO:
        straight_drive_charge = max(0.0, straight_drive_charge - delta * 1.8)
        return
    if last_steer_direction == Vector2.ZERO:
        last_steer_direction = pointer_dir
    var turn_angle: float = abs(rad_to_deg(last_steer_direction.angle_to(pointer_dir)))
    if turn_angle >= STRAIGHT_DRIVE_HARD_TURN_ANGLE:
        straight_drive_charge = max(0.0, straight_drive_charge - delta * 4.8)
    elif turn_angle >= STRAIGHT_DRIVE_TURN_RESET_ANGLE:
        straight_drive_charge = max(0.0, straight_drive_charge - delta * 2.4)
    else:
        var tunnel_bonus: float = _get_tunnel_speed_multiplier(player_pos) - 1.0
        straight_drive_charge = min(STRAIGHT_DRIVE_CHARGE_MAX, straight_drive_charge + delta * (0.72 + tunnel_bonus * 1.15))
    last_steer_direction = pointer_dir

func _get_straight_drive_speed_multiplier() -> float:
    return 1.0 + min(straight_drive_charge / STRAIGHT_DRIVE_CHARGE_MAX, 1.0) * STRAIGHT_DRIVE_SPEED_BONUS_MAX

func _get_tunnel_speed_multiplier(world_pos: Vector2) -> float:
    var cleared_ratio: float = _get_tunnel_cleared_coverage(world_pos)
    if cleared_ratio < TUNNEL_BOOST_COVERAGE_THRESHOLD:
        return 1.0
    var normalized_ratio: float = clampf((cleared_ratio - TUNNEL_BOOST_COVERAGE_THRESHOLD) / (1.0 - TUNNEL_BOOST_COVERAGE_THRESHOLD), 0.0, 1.0)
    var bonus_ratio: float = lerpf(TUNNEL_SPEED_BONUS_MIN, TUNNEL_SPEED_BONUS_MAX, normalized_ratio)
    return 1.0 + bonus_ratio

func _get_tunnel_cleared_coverage(world_pos: Vector2) -> float:
    if dirt_image == null:
        return 0.0
    var cleared_count := 0
    var sample_radius: float = PLAYER_RADIUS + 6.0
    for offset_variant in TUNNEL_COVERAGE_SAMPLE_OFFSETS:
        var offset: Vector2 = offset_variant
        var sample_pos: Vector2 = world_pos + offset * sample_radius
        if _get_dirt_alpha(sample_pos) <= TUNNEL_CLEAR_ALPHA_THRESHOLD:
            cleared_count += 1
    return float(cleared_count) / float(max(1, TUNNEL_COVERAGE_SAMPLE_OFFSETS.size()))

func _get_dirt_alpha(world_pos: Vector2) -> float:
    if dirt_image == null:
        return 1.0
    var pixel: Vector2i = _world_to_dirt_pixel(world_pos)
    return dirt_image.get_pixelv(pixel).a

func _apply_impact_hit(node_index: int, candidate_pos: Vector2) -> bool:
    if node_index < 0 or node_index >= world_nodes.size():
        return false
    var node: Dictionary = world_nodes[node_index]
    var node_health_before: float = float(node.get("health", 0.0))
    var speed_ratio: float = clampf(player_velocity.length() / max(_get_move_speed(), 1.0), 0.0, 2.0)
    var charge_ratio: float = clampf(straight_drive_charge / STRAIGHT_DRIVE_CHARGE_MAX, 0.0, 1.0)
    var impact_damage: float = _get_drill_dps() * (0.55 + speed_ratio * 0.7 + charge_ratio * 3.15)
    if impact_damage <= 0.0:
        return false
    node["health"] = max(0.0, node_health_before - impact_damage)
    world_nodes[node_index] = node
    drill_health = max(0.0, drill_health - _get_drill_wear(node) * (0.12 + charge_ratio * 0.2))
    var hit_pos: Vector2 = candidate_pos.lerp(node.get("pos", candidate_pos), 0.5)
    _spawn_damage_number(hit_pos, int(round(impact_damage)))
    _spawn_contact_sparks(hit_pos, node.get("material_color", Color.WHITE), 4 + int(round(charge_ratio * 6.0)))
    camera_shake_strength = min(11.0, camera_shake_strength + 4.0 + charge_ratio * 5.0)
    straight_drive_charge = max(0.0, straight_drive_charge - 0.8)
    _play_mining_donk(INITIAL_DONK_VOLUME_DB_BOOST)
    drill_audio_timer = DRILL_AUDIO_INTERVAL
    if float(node["health"]) <= 0.0:
        player_velocity *= _get_pass_through_speed_multiplier(impact_damage, node_health_before)
        _break_node(node_index)
        run_status = tr("MINING_RUN_STATUS_CHARGE_BREAK")
        return true
    return false

func _get_pass_through_speed_multiplier(damage_amount: float, node_health_before: float) -> float:
    if node_health_before <= 0.0:
        return 1.0
    return clampf(damage_amount / (node_health_before * 3.0), 1.0 / 3.0, 1.0)

func _get_collision_node_index(candidate: Vector2) -> int:
    var nearest_index: int = -1
    var nearest_distance: float = INF
    for index in range(world_nodes.size()):
        var node: Dictionary = world_nodes[index]
        var distance: float = candidate.distance_to(node.get("pos", Vector2.ZERO))
        if distance <= PLAYER_RADIUS + float(node.get("radius", 0.0)) + CONTACT_DRILL_PADDING:
            if distance < nearest_distance:
                nearest_distance = distance
                nearest_index = index
    return nearest_index

func _get_contact_drill_node_index() -> int:
    if contact_node_id >= 0 and contact_node_id < world_nodes.size():
        return contact_node_id
    var nearest_index: int = -1
    var nearest_distance: float = INF
    for index in range(world_nodes.size()):
        var node: Dictionary = world_nodes[index]
        var distance: float = player_pos.distance_to(node.get("pos", Vector2.ZERO))
        var allowed_distance: float = PLAYER_RADIUS + float(node.get("radius", 0.0)) + CONTACT_DRILL_PADDING
        if distance > allowed_distance:
            continue
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_index = index
    return nearest_index

func _process_contact_sparks(delta: float) -> void:
    if contact_sparks.is_empty():
        return
    var remaining: Array[Dictionary] = []
    for spark in contact_sparks:
        spark["life"] = float(spark.get("life", 0.0)) - delta
        if float(spark["life"]) <= 0.0:
            continue
        spark["pos"] = spark.get("pos", Vector2.ZERO) + spark.get("vel", Vector2.ZERO) * delta
        spark["vel"] = spark.get("vel", Vector2.ZERO) * 0.9
        remaining.append(spark)
    contact_sparks = remaining

func _process_damage_numbers(delta: float) -> void:
    if damage_numbers.is_empty():
        return
    var remaining: Array[Dictionary] = []
    for number in damage_numbers:
        number["life"] = float(number.get("life", 0.0)) - delta
        if float(number["life"]) <= 0.0:
            continue
        number["pos"] = number.get("pos", Vector2.ZERO) + number.get("vel", Vector2.ZERO) * delta
        number["vel"] = number.get("vel", Vector2.ZERO) * 0.93
        remaining.append(number)
    damage_numbers = remaining

func _spawn_contact_sparks(origin: Vector2, color: Color, count: int) -> void:
    for i in range(count):
        var angle: float = rng.randf_range(0.0, TAU)
        var speed: float = rng.randf_range(24.0, 140.0)
        contact_sparks.append({
            "pos": origin + Vector2.RIGHT.rotated(angle) * rng.randf_range(2.0, 10.0),
            "vel": Vector2.RIGHT.rotated(angle) * speed,
            "life": rng.randf_range(0.12, 0.28),
            "color": color.lightened(0.22),
            "radius": rng.randf_range(1.8, 3.8)
        })

func _spawn_run_end_sparks(progress: float) -> void:
    if run_end_spark_timer > 0.0:
        return
    run_end_spark_timer = RUN_ENDING_SPARK_INTERVAL
    var heading: Vector2 = _get_run_end_heading(progress)
    var side: Vector2 = Vector2(-heading.y, heading.x)
    var intensity: float = lerpf(1.0, 0.45, progress)
    for spark_index in range(3):
        var side_sign: float = -1.0 if spark_index % 2 == 0 else 1.0
        var launch_dir: Vector2 = (side * side_sign + heading * rng.randf_range(-0.45, -0.18)).normalized()
        if launch_dir == Vector2.ZERO:
            launch_dir = -heading
        contact_sparks.append({
            "pos": player_pos + heading * rng.randf_range(-8.0, 6.0) + side * side_sign * rng.randf_range(4.0, 11.0),
            "vel": launch_dir * rng.randf_range(55.0, 140.0) * intensity,
            "life": rng.randf_range(0.14, 0.34),
            "color": Color(1.0, 0.74, 0.34, 0.95).lerp(Color(0.72, 0.9, 1.0, 0.9), progress * 0.6),
            "radius": rng.randf_range(1.4, 2.8)
        })

func _spawn_damage_number(origin: Vector2, amount: int, emphasize: bool = false) -> void:
    damage_numbers.append({
        "pos": origin + Vector2(rng.randf_range(-6.0, 6.0), rng.randf_range(-10.0, -2.0)),
        "vel": Vector2(rng.randf_range(-12.0, 12.0), -rng.randf_range(28.0, 56.0)),
        "life": 0.45 if not emphasize else 0.72,
        "text": str(amount),
        "color": Color(0.99, 0.92, 0.6, 1.0) if not emphasize else Color(1.0, 0.75, 0.38, 1.0),
        "scale": 1.0 if not emphasize else 1.35
    })

func _play_drill_tick(origin: Vector2) -> void:
    if drill_audio_timer > 0.0:
        return
    drill_audio_timer = DRILL_AUDIO_INTERVAL
    if pending_drill_damage_number > 0.0:
        _spawn_damage_number(pending_drill_damage_origin if pending_drill_damage_origin != Vector2.ZERO else origin, int(max(1.0, round(pending_drill_damage_number))))
        pending_drill_damage_number = 0.0
        pending_drill_damage_origin = Vector2.ZERO
    _play_mining_donk()

func _play_mining_donk(volume_db_offset: float = 0.0) -> void:
    if simulation_mode_active:
        return
    AudioManager.create_audio(
        SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER,
        volume_db_offset,
        rng.randf_range(-DONK_PITCH_VARIATION, DONK_PITCH_VARIATION)
    )

func _get_pointer_direction() -> Vector2:
    if autoplay_enabled:
        return autoplay_pointer_direction
    var mouse_world: Vector2 = _screen_to_world(aim_cursor_screen_pos)
    var dir: Vector2 = mouse_world - player_pos
    if dir.length() < 8.0:
        return Vector2.ZERO
    return dir.normalized()

func _update_autoplay_pointer() -> void:
    if not autoplay_enabled:
        return
    var base_pos: Vector2 = _get_base_position()
    var cargo_capacity: int = max(1, _get_cargo_capacity())
    var nearest_node_index: int = _find_nearest_node_index(player_pos)
    var nearest_pickup_uid: int = _find_nearest_pickup_uid(player_pos)
    var should_bank: bool = false
    if cargo_used >= cargo_capacity:
        should_bank = true
    elif cargo_used > 0 and player_pos.distance_to(base_pos) <= BASE_RADIUS * 0.9:
        should_bank = true
    elif cargo_used > 0 and time_left <= _estimate_travel_time_to(base_pos) + 1.2:
        should_bank = true
    elif cargo_used > 0 and drill_health <= _estimate_autoplay_wear_buffer():
        should_bank = true

    var target_world: Vector2 = base_pos
    autoplay_current_goal = "bank"
    if not should_bank:
        var should_collect_pickup: bool = false
        if cargo_used < cargo_capacity and nearest_pickup_uid != -1:
            var nearest_pickup: Dictionary = _get_pickup_by_uid(nearest_pickup_uid)
            var pickup_pos: Vector2 = nearest_pickup.get("pos", player_pos)
            var pickup_distance: float = player_pos.distance_to(pickup_pos)
            var node_distance: float = INF
            if nearest_node_index != -1:
                node_distance = player_pos.distance_to(world_nodes[nearest_node_index].get("pos", player_pos))
            var pickup_priority_distance: float = max(72.0, _get_pickup_radius() + 32.0)
            should_collect_pickup = pickup_distance <= pickup_priority_distance or pickup_distance + 24.0 < node_distance
            if should_collect_pickup:
                target_world = pickup_pos
                autoplay_current_goal = "pickup"
        if autoplay_current_goal == "bank" and nearest_node_index != -1:
            target_world = world_nodes[nearest_node_index].get("pos", player_pos)
            autoplay_current_goal = "node"
        elif autoplay_current_goal == "bank":
            target_world = base_pos
            autoplay_current_goal = "base"
    var dir: Vector2 = target_world - player_pos
    autoplay_pointer_direction = dir.normalized() if dir.length() >= 8.0 else Vector2.ZERO
    if autoplay_enabled and not simulation_mode_active:
        aim_cursor_screen_pos = _world_to_screen(player_pos + autoplay_pointer_direction * DRILL_RANGE)

func _estimate_travel_time_to(target_pos: Vector2) -> float:
    var speed: float = max(1.0, _get_move_speed() * _get_dirt_drag_multiplier())
    return player_pos.distance_to(target_pos) / speed

func _estimate_autoplay_wear_buffer() -> float:
    if world_nodes.is_empty():
        return 8.0
    var nearest_node_index: int = _find_nearest_node_index(player_pos)
    if nearest_node_index == -1:
        return 8.0
    var node: Dictionary = world_nodes[nearest_node_index]
    var expected_contact_time: float = float(node.get("health", 1.0)) / max(1.0, _get_drill_dps() * 4.2)
    return 6.0 + _get_drill_wear(node) * max(0.4, expected_contact_time)

func _find_nearest_node_index(origin: Vector2) -> int:
    var nearest_index := -1
    var nearest_distance := INF
    for index in range(world_nodes.size()):
        var distance: float = origin.distance_to(world_nodes[index].get("pos", origin))
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_index = index
    return nearest_index

func _find_nearest_pickup_uid(origin: Vector2) -> int:
    var nearest_uid := -1
    var nearest_distance := INF
    for pickup in pickups:
        var pickup_uid: int = int(pickup.get("uid", -1))
        if pickup_uid == -1:
            continue
        if not _can_fit_material_in_cargo(String(pickup.get("material_id", ""))):
            continue
        var distance: float = origin.distance_to(pickup.get("pos", origin))
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_uid = pickup_uid
    return nearest_uid

func _draw_aim_cursor() -> void:
    if run_state != RUN_STATES.RUNNING:
        return
    var outer_color := Color(0.99, 0.86, 0.42, 0.95)
    var inner_color := Color(0.14, 0.08, 0.03, 0.92)
    draw_arc(aim_cursor_screen_pos, AIM_CURSOR_RADIUS, 0.0, TAU, 32, outer_color, 2.0)
    draw_line(
        aim_cursor_screen_pos + Vector2(-AIM_CURSOR_RADIUS - 5.0, 0.0),
        aim_cursor_screen_pos + Vector2(AIM_CURSOR_RADIUS + 5.0, 0.0),
        outer_color,
        2.0
    )
    draw_line(
        aim_cursor_screen_pos + Vector2(0.0, -AIM_CURSOR_RADIUS - 5.0),
        aim_cursor_screen_pos + Vector2(0.0, AIM_CURSOR_RADIUS + 5.0),
        outer_color,
        2.0
    )
    draw_circle(aim_cursor_screen_pos, 3.0, inner_color)
    draw_circle(aim_cursor_screen_pos, 1.5, outer_color)

func _reset_aim_cursor() -> void:
    aim_cursor_screen_pos = get_viewport_rect().size * 0.5

func _clamp_cursor_to_viewport(position: Vector2) -> Vector2:
    var viewport_size: Vector2 = get_viewport_rect().size
    return Vector2(
        clampf(position.x, 0.0, max(viewport_size.x - 1.0, 0.0)),
        clampf(position.y, 0.0, max(viewport_size.y - 1.0, 0.0))
    )

func _refresh_mouse_capture_state() -> void:
    var should_capture: bool = run_state == RUN_STATES.RUNNING and not _is_settings_open() and not autoplay_enabled and not simulation_mode_active
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if should_capture else Input.MOUSE_MODE_VISIBLE

func _is_settings_open() -> bool:
    return settings_panel != null and settings_panel.visible

func _ensure_crt_overlay() -> void:
    var overlay: CanvasLayer = get_node_or_null("MiningCrtOverlay") as CanvasLayer
    if overlay == null:
        overlay = MINING_CRT_OVERLAY_SCRIPT.new().configure(0)
        overlay.name = "MiningCrtOverlay"
        add_child(overlay)
    overlay.visible = true

func _should_refresh_hud_this_frame(delta: float) -> bool:
    if not OS.has_feature("web") or _is_web_effect_enabled(WEB_EFFECT_FULL_HUD_REFRESH):
        return true
    if run_state != RUN_STATES.RUNNING and run_state != RUN_STATES.ENDING:
        return true
    hud_refresh_accumulator += delta
    if hud_refresh_accumulator < 0.05:
        return false
    hud_refresh_accumulator = 0.0
    return true

func _should_queue_scene_redraw(delta: float) -> bool:
    if not OS.has_feature("web") or _is_web_effect_enabled(WEB_EFFECT_FULL_REDRAW_RATE):
        return true
    web_redraw_accumulator += delta
    if web_redraw_accumulator < WEB_REDRAW_INTERVAL:
        return false
    web_redraw_accumulator = 0.0
    return true

func _is_web_effect_enabled(effect_index: int) -> bool:
    if not OS.has_feature("web"):
        return true
    return effect_index >= 0 and effect_index < web_effects_enabled_count

func _is_web_effect_debug_available() -> bool:
    return OS.has_feature("web")

func _web_effect_label(effect_index: int) -> String:
    if effect_index < 0 or effect_index >= WEB_EFFECT_LABELS.size():
        return "Unknown"
    return String(WEB_EFFECT_LABELS[effect_index])

func _get_display_run_status(consume_web_effect_note: bool) -> String:
    var status_text: String = run_status
    if web_effect_status_note.is_empty():
        return status_text
    status_text += " | %s" % web_effect_status_note
    if consume_web_effect_note:
        web_effect_status_note = ""
    return status_text

func _refresh_web_effect_status_label() -> void:
    if not _is_ui_ready():
        return
    boss_label.text = _trf("MINING_HUD_STATUS", [_get_display_run_status(false)])

func _apply_web_effect_debug_state() -> void:
    if _is_web_effect_enabled(WEB_EFFECT_HIGH_RES_DIRT_MASK):
        if dirt_image != null and (dirt_image.get_width() != 512 or dirt_image.get_height() != 640):
            _refresh_dirt_visual_texture()
    else:
        if dirt_image != null and (dirt_image.get_width() != 192 or dirt_image.get_height() != 224):
            _refresh_dirt_visual_texture()
    _ensure_background_noise_texture()
    web_player_ship_visual_cache.clear()
    web_tail_ship_visual_cache.clear()
    web_ship_visual_accumulator = 0.0
    web_trail_visual_accumulator = 0.0
    _refresh_web_effect_status_label()
    queue_redraw()

func _on_web_effect_plus_button_pressed() -> void:
    if not _is_web_effect_debug_available():
        return
    if web_effects_enabled_count >= WEB_EFFECT_LABELS.size():
        web_effect_last_message = "All web effects already enabled"
        web_effect_status_note = web_effect_last_message
        _refresh_web_effect_status_label()
        return
    var effect_index: int = web_effects_enabled_count
    web_effects_enabled_count += 1
    web_effect_last_message = "Added: %s" % _web_effect_label(effect_index)
    web_effect_status_note = "Effect added: %s" % _web_effect_label(effect_index)
    print(web_effect_last_message)
    _apply_web_effect_debug_state()

func _on_web_effect_minus_button_pressed() -> void:
    if not _is_web_effect_debug_available():
        return
    if web_effects_enabled_count <= 0:
        web_effect_last_message = "Already at web baseline"
        web_effect_status_note = web_effect_last_message
        _refresh_web_effect_status_label()
        return
    web_effects_enabled_count -= 1
    web_effect_last_message = "Removed: %s" % _web_effect_label(web_effects_enabled_count)
    web_effect_status_note = "Effect removed: %s" % _web_effect_label(web_effects_enabled_count)
    print(web_effect_last_message)
    _apply_web_effect_debug_state()

func _handle_web_effect_shortcut(event: InputEvent) -> bool:
    var key_event := event as InputEventKey
    if key_event == null or not key_event.pressed or key_event.echo:
        return false
    if key_event.keycode == KEY_BRACKETLEFT:
        _on_web_effect_minus_button_pressed()
        return true
    if key_event.keycode == KEY_BRACKETRIGHT:
        _on_web_effect_plus_button_pressed()
        return true
    return false

func _get_drill_heading() -> Vector2:
    var heading: Vector2 = _get_pointer_direction()
    if heading == Vector2.ZERO:
        heading = player_velocity.normalized()
    if heading == Vector2.ZERO:
        heading = last_drill_direction
    if heading == Vector2.ZERO:
        heading = Vector2.DOWN
    return heading.normalized()

func _get_run_end_progress() -> float:
    if run_state != RUN_STATES.ENDING:
        return 0.0
    return clampf(run_end_timer / RUN_ENDING_DURATION, 0.0, 1.0)

func _get_run_end_heading(progress: float = -1.0) -> Vector2:
    if progress < 0.0:
        progress = _get_run_end_progress()
    var heading: Vector2 = run_end_initial_heading
    if heading == Vector2.ZERO:
        heading = _get_drill_heading()
    if heading == Vector2.ZERO:
        heading = Vector2.DOWN
    var turn_progress: float = ease(progress, 1.4)
    return heading.rotated(RUN_ENDING_TURN_ANGLE * run_end_turn_sign * turn_progress).normalized()

func _get_run_end_draw_alpha() -> float:
    if run_state != RUN_STATES.ENDING:
        return 1.0
    var fade_progress: float = clampf((_get_run_end_progress() - RUN_ENDING_FADE_START) / max(0.001, 1.0 - RUN_ENDING_FADE_START), 0.0, 1.0)
    return clampf(1.0 - ease(fade_progress, 1.8), 0.0, 1.0)

func _get_run_end_overlay_alpha() -> float:
    var fade_progress: float = clampf((_get_run_end_progress() - RUN_ENDING_FADE_START) / max(0.001, 1.0 - RUN_ENDING_FADE_START), 0.0, 1.0)
    return ease(fade_progress, 1.8) * 0.96

func _get_summary_dim_alpha() -> float:
    if not summary_transition_active:
        return 0.0
    var progress: float = clampf(summary_transition_timer / SUMMARY_RECOVER_DURATION, 0.0, 1.0)
    return lerpf(summary_transition_start_dim_alpha, SUMMARY_GAMEPLAY_DIM_ALPHA, progress)

func _reset_drill_train() -> void:
    trail_history.clear()
    drill_copies.clear()
    var heading: Vector2 = _get_drill_heading()
    for sample_index in range(DRILL_TRAIL_MAX_SAMPLES):
        trail_history.append({
            "pos": player_pos - heading * DRILL_TRAIL_SAMPLE_STEP * float(sample_index),
            "dir": heading
        })
    for copy_index in range(DRILL_COPY_COUNT):
        var path_distance: float = DRILL_COPY_SPACING * float(copy_index + 1)
        var sample: Dictionary = _sample_trail(path_distance)
        drill_copies.append({
            "path_distance": path_distance,
            "pos": sample.get("pos", player_pos),
            "dir": sample.get("dir", heading),
            "offset": Vector2.ZERO
        })

func _update_drill_train(previous_pos: Vector2, delta: float) -> void:
    _record_player_trail(previous_pos)
    _update_drill_copies(delta)

func _record_player_trail(previous_pos: Vector2) -> void:
    var heading: Vector2 = (player_pos - previous_pos).normalized()
    if heading == Vector2.ZERO:
        heading = _get_drill_heading()
    if trail_history.is_empty():
        trail_history.append({
            "pos": previous_pos,
            "dir": heading
        })
    var latest_pos: Vector2 = trail_history[0].get("pos", previous_pos)
    var distance_to_player: float = latest_pos.distance_to(player_pos)
    while distance_to_player >= DRILL_TRAIL_SAMPLE_STEP:
        var sample_dir: Vector2 = (player_pos - latest_pos).normalized()
        if sample_dir == Vector2.ZERO:
            sample_dir = heading
        latest_pos += sample_dir * DRILL_TRAIL_SAMPLE_STEP
        trail_history.push_front({
            "pos": latest_pos,
            "dir": sample_dir
        })
        distance_to_player = latest_pos.distance_to(player_pos)
    while trail_history.size() > DRILL_TRAIL_MAX_SAMPLES:
        trail_history.pop_back()

func _sample_trail(path_distance: float) -> Dictionary:
    var current_heading: Vector2 = _get_drill_heading()
    if trail_history.is_empty():
        return {
            "pos": player_pos,
            "dir": current_heading
        }
    var remaining_distance: float = maxf(path_distance, 0.0)
    var newer_pos: Vector2 = player_pos
    var newer_dir: Vector2 = current_heading
    for point_index in range(trail_history.size()):
        var point_sample: Dictionary = trail_history[point_index]
        var older_pos: Vector2 = point_sample.get("pos", newer_pos)
        var segment_length: float = newer_pos.distance_to(older_pos)
        if segment_length <= 0.001:
            newer_pos = older_pos
            newer_dir = point_sample.get("dir", newer_dir)
            continue
        if remaining_distance <= segment_length:
            var segment_t: float = remaining_distance / segment_length
            var travel_dir: Vector2 = (newer_pos - older_pos).normalized()
            return {
                "pos": newer_pos.lerp(older_pos, segment_t),
                "dir": travel_dir if travel_dir != Vector2.ZERO else newer_dir
            }
        remaining_distance -= segment_length
        newer_pos = older_pos
        newer_dir = point_sample.get("dir", newer_dir)
    var last_sample: Dictionary = trail_history[trail_history.size() - 1]
    return {
        "pos": last_sample.get("pos", player_pos),
        "dir": last_sample.get("dir", current_heading)
    }

func _update_drill_copies(delta: float) -> void:
    if drill_copies.is_empty():
        return
    var occupied_positions: Array[Vector2] = [player_pos]
    for copy_index in range(drill_copies.size()):
        var copy_data: Dictionary = drill_copies[copy_index]
        var sample: Dictionary = _sample_trail(float(copy_data.get("path_distance", DRILL_COPY_SPACING)))
        var target_pos: Vector2 = sample.get("pos", player_pos)
        var target_dir: Vector2 = sample.get("dir", _get_drill_heading())
        if target_dir == Vector2.ZERO:
            target_dir = _get_drill_heading()

        var offset: Vector2 = copy_data.get("offset", Vector2.ZERO)
        offset = offset.move_toward(Vector2.ZERO, delta * DRILL_COPY_BUMP_RETURN_SPEED)

        var copy_target: Vector2 = target_pos + offset
        for occupied_pos in occupied_positions:
            var separation: Vector2 = copy_target - occupied_pos
            var separation_length: float = separation.length()
            if separation_length < 0.001:
                var fallback_normal: Vector2 = Vector2.RIGHT.rotated(target_dir.angle() + PI * 0.5)
                offset += fallback_normal * delta * DRILL_COPY_BUMP_PUSH_SPEED * 0.35
                continue
            if separation_length >= DRILL_COPY_BUMP_RADIUS:
                continue
            offset += separation.normalized() * (DRILL_COPY_BUMP_RADIUS - separation_length) * delta * DRILL_COPY_BUMP_PUSH_SPEED
        if offset.length() > DRILL_COPY_BUMP_LIMIT:
            offset = offset.normalized() * DRILL_COPY_BUMP_LIMIT

        var current_pos: Vector2 = copy_data.get("pos", copy_target)
        current_pos = current_pos.lerp(target_pos + offset, min(1.0, delta * DRILL_COPY_FOLLOW_SPEED))
        var world_size: Vector2 = _get_world_size()
        current_pos.x = clampf(current_pos.x, -world_size.x * 0.5 + PLAYER_RADIUS, world_size.x * 0.5 - PLAYER_RADIUS)
        current_pos.y = clampf(current_pos.y, -world_size.y * 0.5 + PLAYER_RADIUS, world_size.y * 0.5 - PLAYER_RADIUS)

        var current_dir: Vector2 = copy_data.get("dir", target_dir)
        if current_dir == Vector2.ZERO:
            current_dir = target_dir
        current_dir = current_dir.lerp(target_dir, min(1.0, delta * 8.0))
        if current_dir != Vector2.ZERO:
            current_dir = current_dir.normalized()
        else:
            current_dir = _get_drill_heading()

        copy_data["pos"] = current_pos
        copy_data["dir"] = current_dir
        copy_data["offset"] = offset
        drill_copies[copy_index] = copy_data
        occupied_positions.append(current_pos)

func _get_camera_shake_offset() -> Vector2:
    if camera_shake_strength <= 0.0:
        return Vector2.ZERO
    return Vector2(
        rng.randf_range(-camera_shake_strength, camera_shake_strength),
        rng.randf_range(-camera_shake_strength, camera_shake_strength)
    )

func _draw_base(origin: Vector2) -> void:
    var base_screen: Vector2 = _world_to_screen(_get_base_position())
    var base_seed := float(active_depth_level) * 43.0
    var base_outer := _apply_visual_palette_variant(Color(0.27, 0.3, 0.35, 0.92), base_seed + 0.7, 0.65)
    var base_inner := _apply_visual_palette_variant(Color(0.81, 0.7, 0.36, 0.28), base_seed + 1.4, 0.9)
    var base_arc := _apply_visual_palette_variant(Color(0.95, 0.81, 0.45, 0.95), base_seed + 2.1, 0.7)
    draw_circle(base_screen, BASE_RADIUS, base_outer)
    draw_circle(base_screen, BASE_RADIUS - 12.0, base_inner)
    _draw_seeded_variation_spots(
        base_screen,
        BASE_RADIUS - 18.0,
        base_seed,
        Color(0.08, 0.09, 0.11, 0.085),
        3,
        0.46,
        0.18,
        0.3
    )
    _draw_seeded_variation_highlight(
        base_screen,
        BASE_RADIUS - 22.0,
        base_seed + 4.2,
        Color(1.0, 0.94, 0.72, 0.055),
        0.22
    )
    draw_arc(base_screen, BASE_RADIUS - 8.0, 0.0, TAU, 40, base_arc, 3.0)
    draw_rect(Rect2(base_screen + Vector2(-22.0, -58.0), Vector2(44.0, 72.0)), Color(0.22, 0.24, 0.28, 1.0), true)
    draw_rect(Rect2(base_screen + Vector2(-36.0, -16.0), Vector2(72.0, 28.0)), Color(0.42, 0.43, 0.48, 1.0), true)

func _draw_nodes(origin: Vector2) -> void:
    var web_fast_path: bool = OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_FULL_NODE_DETAIL)
    for node in world_nodes:
        var node_screen: Vector2 = _world_to_screen(node.get("pos", Vector2.ZERO))
        var node_seed := float(int(node.get("id", 0))) * 17.0 + float(active_depth_level) * 7.0
        var node_color: Color = _apply_material_color_variation(node.get("material_color", Color(0.5, 0.5, 0.5, 1.0)), node_seed + 0.9, 0.9)
        var radius: float = float(node.get("radius", 20.0))
        var hp_ratio: float = float(node.get("health", 1.0)) / max(1.0, float(node.get("max_health", 1.0)))
        var mined_progress: float = clampf(1.0 - hp_ratio, 0.0, 1.0)

        # Base rock tint; mined nodes get slightly greyer as depletion increases.
        var luma: float = node_color.r * 0.299 + node_color.g * 0.587 + node_color.b * 0.114
        var grey_color: Color = Color(luma, luma, luma, node_color.a)
        var outer_color: Color = node_color.lerp(grey_color, mined_progress * 0.18)
        if web_fast_path:
            var rock_points_web: PackedVector2Array = _get_translated_shape_points(node, node_screen)
            draw_colored_polygon(rock_points_web, outer_color)
            if mined_progress > 0.001:
                var local_points_web: PackedVector2Array = node.get("shape_points", PackedVector2Array())
                var inner_points_web: PackedVector2Array = PackedVector2Array()
                for local_point_web in local_points_web:
                    inner_points_web.append(node_screen + local_point_web * mined_progress)
                var inner_color: Color = node_color.lerp(grey_color, 0.55)
                draw_colored_polygon(inner_points_web, inner_color)
            if float(node.get("sparkle", 0.0)) > 0.0:
                draw_circle(
                    node_screen + Vector2(-radius * 0.2, -radius * 0.22),
                    maxf(2.0, radius * 0.16),
                    Color(1.0, 1.0, 1.0, 0.12)
                )
            continue
        if OS.has_feature("web"):
            _draw_cached_node_detail(node, node_screen, mined_progress, node_color, grey_color)
            continue
        var rock_points: PackedVector2Array = _get_translated_shape_points(node, node_screen)
        draw_colored_polygon(rock_points, outer_color)

        # "Fill in" mined amount using a scaled inner polygon (radial wipe).
        if mined_progress > 0.001:
            var inner_scale: float = mined_progress
            var local_points: PackedVector2Array = node.get("shape_points", PackedVector2Array())
            var inner_points: PackedVector2Array = PackedVector2Array()
            for local_point in local_points:
                inner_points.append(node_screen + local_point * inner_scale)
            var inner_color: Color = node_color.lerp(grey_color, 0.55)
            draw_colored_polygon(inner_points, inner_color)

        var node_spot_color: Color = _apply_material_color_variation(node.get("material_bg_color", outer_color.darkened(0.46)), node_seed + 3.4, 0.55)
        node_spot_color.a = 0.08 + 0.05 * (1.0 - mined_progress)
        _draw_seeded_variation_spots(node_screen, radius, node_seed, node_spot_color, 2, 0.42, 0.16, 0.27)
        _draw_seeded_variation_highlight(
            node_screen,
            radius,
            node_seed + 2.6,
            Color(1.0, 1.0, 1.0, 0.028 + float(node.get("sparkle", 0.0)) * 0.014),
            0.24
        )
        _draw_seeded_mineral_crack_lines(
            node_screen,
            radius,
            node_seed + 7.8,
            Color(0.04, 0.05, 0.06, 0.14 + mined_progress * 0.04),
            1,
            1.15
        )
        _draw_node_sparkles(node_screen, radius, float(node.get("sparkle", 0.0)))

func _draw_cached_node_detail(node: Dictionary, node_screen: Vector2, mined_progress: float, node_color: Color, grey_color: Color) -> void:
    var node_texture: Texture2D = node.get("cached_detail_texture", null)
    var node_mined_texture: Texture2D = node.get("cached_detail_mined_texture", null)
    var draw_offset: Vector2 = node.get("cached_detail_offset", Vector2.ZERO)
    var draw_size: Vector2 = node.get("cached_detail_size", Vector2.ZERO)
    if node_texture == null or node_mined_texture == null or draw_size == Vector2.ZERO:
        var rock_points: PackedVector2Array = _get_translated_shape_points(node, node_screen)
        draw_colored_polygon(rock_points, node_color)
        if mined_progress > 0.001:
            var local_points: PackedVector2Array = node.get("shape_points", PackedVector2Array())
            var inner_points: PackedVector2Array = PackedVector2Array()
            for local_point in local_points:
                inner_points.append(node_screen + local_point * mined_progress)
            var inner_color: Color = node_color.lerp(grey_color, 0.55)
            draw_colored_polygon(inner_points, inner_color)
        return
    var outer_rect: Rect2 = Rect2(node_screen - draw_offset, draw_size)
    draw_texture_rect(node_texture, outer_rect, false)
    if mined_progress > 0.001:
        var inner_size: Vector2 = draw_size * mined_progress
        var inner_rect: Rect2 = Rect2(node_screen - inner_size * 0.5, inner_size)
        draw_texture_rect(node_mined_texture, inner_rect, false)

func _draw_node_sparkles(node_screen: Vector2, radius: float, sparkle: float) -> void:
    if sparkle <= 0.0:
        return
    var sparkle_count: int = int(round(2.0 + sparkle * 4.0))
    for sparkle_index in range(sparkle_count):
        var angle: float = TAU * float(sparkle_index) / float(max(1, sparkle_count))
        var pos: Vector2 = node_screen + Vector2.RIGHT.rotated(angle) * (radius * 0.58)
        draw_circle(pos, 2.0 + sparkle, Color(1.0, 1.0, 1.0, 0.75))

func _draw_pickups(origin: Vector2) -> void:
    var web_fast_path: bool = OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_FULL_PICKUP_DETAIL)
    for pickup in pickups:
        var pickup_screen: Vector2 = _world_to_screen(pickup.get("pos", Vector2.ZERO))
        var pickup_seed := float(int(pickup.get("uid", 0))) * 13.0 + float(active_depth_level) * 5.0
        var pickup_color: Color = _apply_material_color_variation(pickup.get("material_color", Color(0.8, 0.8, 0.8, 1.0)), pickup_seed + 1.1, 0.75)
        var blink_ratio: float = clampf(float(pickup.get("reject_blink_timer", 0.0)) / PICKUP_REJECT_BLINK_DURATION, 0.0, 1.0)
        var blink_pulse: float = 0.5 + 0.5 * sin((1.0 - blink_ratio) * TAU * 4.0)
        var blink_boost: float = blink_ratio * blink_pulse
        pickup_color = pickup_color.lerp(Color.WHITE, 0.55 * blink_boost)
        if web_fast_path:
            draw_circle(pickup_screen, 6.0 + 1.2 * blink_boost, pickup_color)
            draw_circle(pickup_screen, 2.5 + 0.5 * blink_boost, Color(1.0, 1.0, 1.0, 0.78))
            continue
        draw_circle(pickup_screen, 7.0 + 1.8 * blink_boost, pickup_color)
        var pickup_spot_color := pickup_color.darkened(0.5)
        pickup_spot_color.a = 0.12 + 0.04 * blink_boost
        _draw_seeded_variation_spots(pickup_screen, 6.6 + blink_boost, pickup_seed, pickup_spot_color, 1, 0.2, 0.24, 0.28)
        _draw_seeded_variation_highlight(
            pickup_screen,
            6.6 + blink_boost,
            pickup_seed + 1.8,
            Color(1.0, 1.0, 1.0, 0.06 + 0.03 * blink_boost),
            0.18
        )
        _draw_seeded_mineral_crack_lines(
            pickup_screen,
            6.4 + blink_boost,
            pickup_seed + 5.4,
            Color(0.03, 0.04, 0.05, 0.12),
            1,
            0.95
        )
        draw_circle(pickup_screen, 3.0 + 0.8 * blink_boost, Color(1.0, 1.0, 1.0, 0.75 + 0.2 * blink_boost))
    _draw_delivery_drones()
    _draw_pickup_drones()
    _draw_contact_sparks()
    _draw_damage_numbers()

func _draw_delivery_drones() -> void:
    for index in range(delivery_drone_visuals.size()):
        var drone: Dictionary = delivery_drone_visuals[index]
        var is_returning: bool = String(drone.get("state", "to_base")) == "returning"
        var body_color := Color(0.56, 0.82, 0.88, 1.0) if is_returning else Color(0.72, 0.9, 0.98, 1.0)
        var carry_color: Color = _apply_material_color_variation(drone.get("carry_color", Color.WHITE), float(index) * 9.0 + 5.1, 0.55)
        var return_offset: Vector2 = drone.get("return_offset", Vector2.ZERO)
        var variation_seed := float(active_depth_level) * 14.0 + float(index) * 9.0 + return_offset.x * 0.17 + return_offset.y * 0.11
        _draw_drone_body(_world_to_screen(drone.get("pos", Vector2.ZERO)), _apply_visual_palette_variant(body_color, variation_seed + 1.7, 0.55), carry_color, variation_seed)

func _draw_pickup_drones() -> void:
    for index in range(pickup_drone_visuals.size()):
        var drone: Dictionary = pickup_drone_visuals[index]
        var carry_color: Color = _apply_material_color_variation(drone.get("carry_color", Color(0.94, 0.82, 0.38, 1.0)), float(index) * 8.0 + 7.3, 0.55) if String(drone.get("state", "idle")) == "to_player" else Color(0.0, 0.0, 0.0, 0.0)
        var variation_seed := float(active_depth_level) * 19.0 + float(index) * 7.0 + float(drone.get("orbit_seed", 0.0)) * 11.0
        _draw_drone_body(_world_to_screen(drone.get("pos", Vector2.ZERO)), _apply_visual_palette_variant(Color(0.92, 0.76, 0.38, 1.0), variation_seed + 2.2, 0.6), carry_color, variation_seed)

func _draw_defense_hunter(_origin: Vector2) -> void:
    if not defense_hunter_active or not defense_hunter_spawned:
        return
    var screen_pos := _world_to_screen(defense_hunter_pos)
    var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.012)
    draw_circle(screen_pos, DEFENSE_HUNTER_RADIUS + 10.0 + pulse * 4.0, Color(1.0, 0.12, 0.08, 0.14))
    draw_circle(screen_pos, DEFENSE_HUNTER_RADIUS, Color(0.16, 0.02, 0.025, 0.96))
    draw_arc(screen_pos, DEFENSE_HUNTER_RADIUS + 4.0, 0.0, TAU, 32, Color(1.0, 0.22, 0.16, 0.82), 3.0)
    draw_line(screen_pos + Vector2(-9.0, -3.0), screen_pos + Vector2(-2.0, 3.0), Color(1.0, 0.72, 0.35, 0.95), 2.0)
    draw_line(screen_pos + Vector2(9.0, -3.0), screen_pos + Vector2(2.0, 3.0), Color(1.0, 0.72, 0.35, 0.95), 2.0)

func _draw_drone_body(screen_pos: Vector2, body_color: Color, carry_color: Color, variation_seed: float) -> void:
    if OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_FULL_DRONE_DETAIL):
        draw_circle(screen_pos, 8.0, Color(0.12, 0.14, 0.17, 0.95))
        draw_circle(screen_pos, 5.0, body_color)
        if carry_color.a > 0.0:
            var cargo_pos: Vector2 = screen_pos + Vector2(0.0, 10.0)
            draw_line(screen_pos + Vector2(0.0, 3.0), cargo_pos, Color(0.94, 0.92, 0.8, 0.65), 1.2)
            draw_circle(cargo_pos, 4.0, carry_color)
        return
    draw_circle(screen_pos, 9.0, Color(0.12, 0.14, 0.17, 0.95))
    draw_circle(screen_pos, 6.0, body_color)
    _draw_seeded_variation_spots(screen_pos, 5.8, variation_seed, Color(0.05, 0.06, 0.08, 0.13), 1, 0.18, 0.28, 0.3)
    _draw_seeded_variation_highlight(screen_pos, 5.8, variation_seed + 1.2, Color(1.0, 1.0, 1.0, 0.075), 0.2)
    draw_line(screen_pos + Vector2(-11.0, -7.0), screen_pos + Vector2(11.0, -7.0), Color(0.85, 0.9, 0.95, 0.72), 2.0)
    draw_line(screen_pos + Vector2(-11.0, 7.0), screen_pos + Vector2(11.0, 7.0), Color(0.85, 0.9, 0.95, 0.72), 2.0)
    if carry_color.a > 0.0:
        var cargo_pos: Vector2 = screen_pos + Vector2(0.0, 12.0)
        draw_line(screen_pos + Vector2(0.0, 4.0), cargo_pos, Color(0.94, 0.92, 0.8, 0.7), 1.5)
        draw_circle(cargo_pos, 5.0, carry_color)
        _draw_seeded_variation_spots(cargo_pos, 4.8, variation_seed + 4.6, Color(0.04, 0.05, 0.07, 0.14), 1, 0.16, 0.28, 0.31)
        draw_circle(cargo_pos, 2.0, Color(1.0, 1.0, 1.0, 0.75))

func _draw_contact_sparks() -> void:
    if OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_CONTACT_SPARKS):
        return
    for spark in contact_sparks:
        var spark_screen: Vector2 = _world_to_screen(spark.get("pos", Vector2.ZERO))
        var spark_color: Color = spark.get("color", Color.WHITE)
        var spark_radius: float = float(spark.get("radius", 2.0)) * clampf(float(spark.get("life", 0.0)) * 4.0, 0.35, 1.0)
        draw_circle(spark_screen, spark_radius, spark_color)

func _draw_damage_numbers() -> void:
    if OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_DAMAGE_NUMBERS):
        return
    var font: Font = ThemeDB.fallback_font
    if font == null:
        return
    for number in damage_numbers:
        var number_screen: Vector2 = _world_to_screen(number.get("pos", Vector2.ZERO))
        var life_ratio: float = clampf(float(number.get("life", 0.0)) * 2.0, 0.0, 1.0)
        var font_size: int = int(round(18.0 * float(number.get("scale", 1.0))))
        var color: Color = number.get("color", Color.WHITE)
        color.a = life_ratio
        draw_string(font, number_screen, String(number.get("text", "0")), HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size, color)

func _update_web_drill_visual_cache(delta: float) -> void:
    if not OS.has_feature("web"):
        return

    web_ship_visual_accumulator += delta
    web_trail_visual_accumulator += delta

    if web_player_ship_visual_cache.is_empty() or web_ship_visual_accumulator >= WEB_SHIP_VISUAL_INTERVAL:
        web_ship_visual_accumulator = 0.0
        var aim_dir: Vector2 = _get_run_end_heading() if run_state == RUN_STATES.ENDING else _get_pointer_direction()
        if aim_dir == Vector2.ZERO:
            aim_dir = player_velocity.normalized()
        if aim_dir == Vector2.ZERO:
            aim_dir = Vector2.DOWN
        var fade_alpha: float = _get_run_end_draw_alpha()
        var boost_strength: float = 0.0 if run_state == RUN_STATES.ENDING else tunnel_speed_boost_strength
        web_player_ship_visual_cache = _build_drill_ship_visual(
            _world_to_screen(player_pos),
            aim_dir,
            1.0,
            Color(0.16, 0.17, 0.2, fade_alpha),
            Color(0.83, 0.74, 0.28, fade_alpha),
            boost_strength,
            _is_web_effect_enabled(WEB_EFFECT_FULL_SHIP_DETAIL)
        )

    var desired_tail_indices: Array[int] = []
    if not drill_copies.is_empty():
        var start_index: int = drill_copies.size() - 1
        if not _is_web_effect_enabled(WEB_EFFECT_FULL_TRAIL_BUDDIES):
            start_index = min(drill_copies.size() - 1, 1)
        for copy_index in range(start_index, -1, -1):
            desired_tail_indices.append(copy_index)

    if desired_tail_indices.is_empty():
        web_tail_ship_visual_cache.clear()
        web_trail_visual_accumulator = 0.0
        return

    if web_tail_ship_visual_cache.size() == desired_tail_indices.size() and web_trail_visual_accumulator < WEB_TRAIL_VISUAL_INTERVAL:
        return

    web_trail_visual_accumulator = 0.0
    var cached_tail_visuals: Array[Dictionary] = []
    var tail_fade_alpha: float = _get_run_end_draw_alpha()
    for copy_index in desired_tail_indices:
        var copy_data: Dictionary = drill_copies[copy_index]
        var scale: float = 0.88 - 0.08 * float(copy_index)
        var shell_color: Color = Color(0.16, 0.17, 0.2, (0.82 - 0.08 * float(copy_index)) * tail_fade_alpha)
        var body_color: Color = Color(0.83, 0.74, 0.28, (0.74 - 0.09 * float(copy_index)) * tail_fade_alpha)
        var copy_boost_strength: float = 0.0 if run_state == RUN_STATES.ENDING else tunnel_speed_boost_strength * max(0.0, 1.0 - 0.18 * float(copy_index))
        cached_tail_visuals.append(
            _build_drill_ship_visual(
                _world_to_screen(copy_data.get("pos", player_pos)),
                copy_data.get("dir", _get_drill_heading()),
                scale,
                shell_color,
                body_color,
                copy_boost_strength,
                _is_web_effect_enabled(WEB_EFFECT_FULL_SHIP_DETAIL)
            )
        )
    web_tail_ship_visual_cache = cached_tail_visuals

func _build_drill_ship_visual(screen_pos: Vector2, aim_dir: Vector2, scale: float, shell_color: Color, body_color: Color, boost_strength: float, full_detail: bool) -> Dictionary:
    var polygons: Array[Dictionary] = []
    var polylines: Array[Dictionary] = []
    var lines: Array[Dictionary] = []
    var circles: Array[Dictionary] = []
    var arcs: Array[Dictionary] = []

    if not full_detail:
        var facing_angle_web: float = aim_dir.angle() + PI * 0.5
        var boost_shell_web: Color = shell_color.lerp(Color(0.24, 0.45, 0.56, shell_color.a), boost_strength * 0.55)
        var boost_body_web: Color = body_color.lerp(Color(0.92, 0.96, 1.0, body_color.a), boost_strength * 0.45)
        var top_point_web: Vector2 = screen_pos + Vector2(0.0, -23.0).rotated(facing_angle_web) * scale
        var rear_point_web: Vector2 = screen_pos + Vector2(0.0, 18.0).rotated(facing_angle_web) * scale
        var left_point_web: Vector2 = screen_pos + Vector2(-15.0, 10.0).rotated(facing_angle_web) * scale
        var right_point_web: Vector2 = screen_pos + Vector2(15.0, 10.0).rotated(facing_angle_web) * scale
        polygons.append({"points": PackedVector2Array([left_point_web, rear_point_web, right_point_web]), "color": boost_shell_web})
        polygons.append({"points": PackedVector2Array([top_point_web, left_point_web, right_point_web]), "color": boost_body_web})
        polylines.append({
            "points": PackedVector2Array([top_point_web, left_point_web, rear_point_web, right_point_web, top_point_web]),
            "color": Color(1.0, 0.97, 0.9, 0.55 * boost_body_web.a),
            "width": maxf(1.2, 1.8 * scale)
        })
        circles.append({
            "center": screen_pos + Vector2(0.0, -4.5).rotated(facing_angle_web) * scale,
            "radius": maxf(2.5, 4.0 * scale),
            "color": Color(1.0, 0.97, 0.88, 0.35)
        })
        if boost_strength > 0.0:
            circles.append({
                "center": screen_pos,
                "radius": (PLAYER_RADIUS + 8.0 + boost_strength * 3.0) * scale,
                "color": Color(0.6, 0.92, 1.0, 0.08 + boost_strength * 0.12)
            })
            var exhaust_tip_web: Vector2 = screen_pos + Vector2(0.0, 26.0 + boost_strength * 6.0).rotated(facing_angle_web) * scale
            var exhaust_left_web: Vector2 = screen_pos + Vector2(-4.0, 10.0).rotated(facing_angle_web) * scale
            var exhaust_right_web: Vector2 = screen_pos + Vector2(4.0, 10.0).rotated(facing_angle_web) * scale
            polygons.append({
                "points": PackedVector2Array([exhaust_left_web, exhaust_tip_web, exhaust_right_web]),
                "color": Color(0.82, 0.96, 1.0, 0.16 + boost_strength * 0.16)
            })
        return {
            "polygons": polygons,
            "polylines": polylines,
            "lines": lines,
            "circles": circles,
            "arcs": arcs
        }

    var spin_angle: float = Time.get_ticks_msec() * 0.0045
    var facing_angle: float = aim_dir.angle() + PI * 0.5
    var variation_seed: float = float(active_depth_level) * 37.0 + scale * 13.0
    var roll_cos: float = cos(spin_angle)
    var roll_sin: float = sin(spin_angle)
    var roll_depth_to_screen: float = 0.35
    shell_color = _apply_visual_palette_variant(shell_color, variation_seed + 0.8, 0.55)
    body_color = _apply_visual_palette_variant(body_color, variation_seed + 1.6, 0.62)
    var boost_shell: Color = shell_color.lerp(Color(0.24, 0.45, 0.56, shell_color.a), boost_strength * 0.55)
    var boost_body: Color = body_color.lerp(Color(0.92, 0.96, 1.0, body_color.a), boost_strength * 0.45)
    if boost_strength > 0.0:
        circles.append({
            "center": screen_pos,
            "radius": (PLAYER_RADIUS + 8.0 + boost_strength * 4.0) * scale,
            "color": Color(0.6, 0.92, 1.0, 0.1 + boost_strength * 0.16)
        })
        arcs.append({
            "center": screen_pos,
            "radius": (PLAYER_RADIUS + 9.0) * scale,
            "start_angle": 0.0,
            "end_angle": TAU,
            "point_count": 32,
            "color": Color(0.82, 0.97, 1.0, 0.18 + boost_strength * 0.28),
            "width": 2.0 * scale
        })
    circles.append({
        "center": screen_pos,
        "radius": (PLAYER_RADIUS + 5.0) * scale,
        "color": boost_shell
    })

    var pyramid_rotation: float = facing_angle
    var top_point: Vector2 = screen_pos + Vector2(0.0, -24.0).rotated(pyramid_rotation) * scale
    var rear_point: Vector2 = screen_pos + Vector2(0.0, 18.0).rotated(pyramid_rotation) * scale
    var left_local: Vector2 = Vector2(-16.0, 10.0)
    var right_local: Vector2 = Vector2(16.0, 10.0)
    var left_rolled: Vector2 = Vector2(left_local.x * roll_cos, left_local.y + left_local.x * roll_sin * roll_depth_to_screen)
    var right_rolled: Vector2 = Vector2(right_local.x * roll_cos, right_local.y + right_local.x * roll_sin * roll_depth_to_screen)
    var left_point: Vector2 = screen_pos + left_rolled.rotated(pyramid_rotation) * scale
    var right_point: Vector2 = screen_pos + right_rolled.rotated(pyramid_rotation) * scale

    var highlight_color: Color = boost_body.lerp(Color(1.0, 0.98, 0.86, boost_body.a), 0.4 + boost_strength * 0.25)
    var shadow_color: Color = boost_body.lerp(boost_shell, 0.42)
    var deep_shadow_color: Color = shadow_color.lerp(Color(0.08, 0.1, 0.13, shadow_color.a), 0.35)

    polygons.append({"points": PackedVector2Array([left_point, rear_point, right_point]), "color": deep_shadow_color})
    polygons.append({"points": PackedVector2Array([top_point, rear_point, left_point]), "color": shadow_color})
    polygons.append({"points": PackedVector2Array([top_point, right_point, rear_point]), "color": boost_body})
    polygons.append({"points": PackedVector2Array([top_point, left_point, right_point]), "color": highlight_color})
    polylines.append({
        "points": PackedVector2Array([top_point, left_point, rear_point, right_point, top_point]),
        "color": Color(0.98, 0.95, 0.82, 0.55 * boost_body.a),
        "width": maxf(1.3, 2.0 * scale)
    })
    lines.append({
        "from": top_point,
        "to": rear_point,
        "color": Color(1.0, 0.97, 0.9, 0.45 * boost_body.a),
        "width": maxf(1.0, 1.4 * scale)
    })

    var engine_glow_pos: Vector2 = screen_pos + Vector2(0.0, 18.0).rotated(facing_angle) * scale
    circles.append({
        "center": engine_glow_pos,
        "radius": (4.5 + boost_strength * 2.5) * scale,
        "color": Color(1.0, 0.86, 0.42, 0.55)
    })
    if boost_strength > 0.0:
        var exhaust_tip: Vector2 = screen_pos + Vector2(0.0, 30.0 + boost_strength * 8.0).rotated(facing_angle) * scale
        var exhaust_left: Vector2 = engine_glow_pos + Vector2(-4.5, 4.0).rotated(facing_angle) * scale
        var exhaust_right: Vector2 = engine_glow_pos + Vector2(4.5, 4.0).rotated(facing_angle) * scale
        polygons.append({
            "points": PackedVector2Array([exhaust_left, exhaust_tip, exhaust_right]),
            "color": Color(0.82, 0.96, 1.0, 0.22 + boost_strength * 0.2)
        })

    return {
        "polygons": polygons,
        "polylines": polylines,
        "lines": lines,
        "circles": circles,
        "arcs": arcs
    }

func _draw_cached_drill_ship_visual(visual: Dictionary) -> void:
    for circle_variant in visual.get("circles", []):
        var circle_data: Dictionary = circle_variant
        draw_circle(
            circle_data.get("center", Vector2.ZERO),
            float(circle_data.get("radius", 0.0)),
            circle_data.get("color", Color.WHITE)
        )
    for arc_variant in visual.get("arcs", []):
        var arc_data: Dictionary = arc_variant
        draw_arc(
            arc_data.get("center", Vector2.ZERO),
            float(arc_data.get("radius", 0.0)),
            float(arc_data.get("start_angle", 0.0)),
            float(arc_data.get("end_angle", TAU)),
            int(arc_data.get("point_count", 16)),
            arc_data.get("color", Color.WHITE),
            float(arc_data.get("width", 1.0))
        )
    for polygon_variant in visual.get("polygons", []):
        var polygon_data: Dictionary = polygon_variant
        draw_colored_polygon(
            polygon_data.get("points", PackedVector2Array()),
            polygon_data.get("color", Color.WHITE)
        )
    for polyline_variant in visual.get("polylines", []):
        var polyline_data: Dictionary = polyline_variant
        draw_polyline(
            polyline_data.get("points", PackedVector2Array()),
            polyline_data.get("color", Color.WHITE),
            float(polyline_data.get("width", 1.0))
        )
    for line_variant in visual.get("lines", []):
        var line_data: Dictionary = line_variant
        draw_line(
            line_data.get("from", Vector2.ZERO),
            line_data.get("to", Vector2.ZERO),
            line_data.get("color", Color.WHITE),
            float(line_data.get("width", 1.0))
        )

func _draw_tail() -> void:
    if OS.has_feature("web"):
        if web_tail_ship_visual_cache.is_empty() and not drill_copies.is_empty():
            _update_web_drill_visual_cache(WEB_TRAIL_VISUAL_INTERVAL)
        for tail_visual_variant in web_tail_ship_visual_cache:
            var tail_visual: Dictionary = tail_visual_variant
            _draw_cached_drill_ship_visual(tail_visual)
        return
    var fade_alpha: float = _get_run_end_draw_alpha()
    var start_index: int = drill_copies.size() - 1
    var end_index: int = -1
    if OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_FULL_TRAIL_BUDDIES):
        start_index = min(drill_copies.size() - 1, 1)
    for copy_index in range(start_index, end_index, -1):
        var copy_data: Dictionary = drill_copies[copy_index]
        var scale: float = 0.88 - 0.08 * float(copy_index)
        var shell_color: Color = Color(0.16, 0.17, 0.2, (0.82 - 0.08 * float(copy_index)) * fade_alpha)
        var body_color: Color = Color(0.83, 0.74, 0.28, (0.74 - 0.09 * float(copy_index)) * fade_alpha)
        var copy_boost_strength: float = 0.0 if run_state == RUN_STATES.ENDING else tunnel_speed_boost_strength * max(0.0, 1.0 - 0.18 * float(copy_index))
        _draw_drill_ship(
            _world_to_screen(copy_data.get("pos", player_pos)),
            copy_data.get("dir", _get_drill_heading()),
            scale,
            shell_color,
            body_color,
            copy_boost_strength
        )

func _draw_player(origin: Vector2) -> void:
    if OS.has_feature("web"):
        if web_player_ship_visual_cache.is_empty():
            _update_web_drill_visual_cache(WEB_SHIP_VISUAL_INTERVAL)
        _draw_cached_drill_ship_visual(web_player_ship_visual_cache)
        return
    var aim_dir: Vector2 = _get_run_end_heading() if run_state == RUN_STATES.ENDING else _get_pointer_direction()
    if aim_dir == Vector2.ZERO:
        aim_dir = player_velocity.normalized()
    if aim_dir == Vector2.ZERO:
        aim_dir = Vector2.DOWN
    var fade_alpha: float = _get_run_end_draw_alpha()
    var boost_strength: float = 0.0 if run_state == RUN_STATES.ENDING else tunnel_speed_boost_strength
    _draw_drill_ship(_world_to_screen(player_pos), aim_dir, 1.0, Color(0.16, 0.17, 0.2, fade_alpha), Color(0.83, 0.74, 0.28, fade_alpha), boost_strength)

func _draw_drill_ship(screen_pos: Vector2, aim_dir: Vector2, scale: float, shell_color: Color, body_color: Color, boost_strength: float = 0.0) -> void:
    if OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_FULL_SHIP_DETAIL):
        var facing_angle_web: float = aim_dir.angle() + PI * 0.5
        var boost_shell_web: Color = shell_color.lerp(Color(0.24, 0.45, 0.56, shell_color.a), boost_strength * 0.55)
        var boost_body_web: Color = body_color.lerp(Color(0.92, 0.96, 1.0, body_color.a), boost_strength * 0.45)
        var top_point_web: Vector2 = screen_pos + Vector2(0.0, -23.0).rotated(facing_angle_web) * scale
        var rear_point_web: Vector2 = screen_pos + Vector2(0.0, 18.0).rotated(facing_angle_web) * scale
        var left_point_web: Vector2 = screen_pos + Vector2(-15.0, 10.0).rotated(facing_angle_web) * scale
        var right_point_web: Vector2 = screen_pos + Vector2(15.0, 10.0).rotated(facing_angle_web) * scale
        var front_facet_web: PackedVector2Array = PackedVector2Array([top_point_web, left_point_web, right_point_web])
        var body_facet_web: PackedVector2Array = PackedVector2Array([left_point_web, rear_point_web, right_point_web])
        draw_colored_polygon(body_facet_web, boost_shell_web)
        draw_colored_polygon(front_facet_web, boost_body_web)
        draw_polyline(
            PackedVector2Array([top_point_web, left_point_web, rear_point_web, right_point_web, top_point_web]),
            Color(1.0, 0.97, 0.9, 0.55 * boost_body_web.a),
            maxf(1.2, 1.8 * scale)
        )
        var cockpit_web: Vector2 = screen_pos + Vector2(0.0, -4.5).rotated(facing_angle_web) * scale
        draw_circle(cockpit_web, maxf(2.5, 4.0 * scale), Color(1.0, 0.97, 0.88, 0.35))
        if boost_strength > 0.0:
            draw_circle(screen_pos, (PLAYER_RADIUS + 8.0 + boost_strength * 3.0) * scale, Color(0.6, 0.92, 1.0, 0.08 + boost_strength * 0.12))
            var exhaust_tip_web: Vector2 = screen_pos + Vector2(0.0, 26.0 + boost_strength * 6.0).rotated(facing_angle_web) * scale
            var exhaust_left_web: Vector2 = screen_pos + Vector2(-4.0, 10.0).rotated(facing_angle_web) * scale
            var exhaust_right_web: Vector2 = screen_pos + Vector2(4.0, 10.0).rotated(facing_angle_web) * scale
            draw_colored_polygon(
                PackedVector2Array([exhaust_left_web, exhaust_tip_web, exhaust_right_web]),
                Color(0.82, 0.96, 1.0, 0.16 + boost_strength * 0.16)
            )
        return
    var spin_angle: float = Time.get_ticks_msec() * 0.0045
    var facing_angle: float = aim_dir.angle() + PI * 0.5
    var variation_seed := float(active_depth_level) * 37.0 + scale * 13.0
    # Treat `spin_angle` as a roll around the travel axis (aim_dir), not as a 2D orbit rotation.
    # This keeps the drill's forward direction stable while the side facets "twist" for a 3D-ish feel.
    var roll_cos: float = cos(spin_angle)
    var roll_sin: float = sin(spin_angle)
    var roll_depth_to_screen: float = 0.35
    shell_color = _apply_visual_palette_variant(shell_color, variation_seed + 0.8, 0.55)
    body_color = _apply_visual_palette_variant(body_color, variation_seed + 1.6, 0.62)
    var boost_shell: Color = shell_color.lerp(Color(0.24, 0.45, 0.56, shell_color.a), boost_strength * 0.55)
    var boost_body: Color = body_color.lerp(Color(0.92, 0.96, 1.0, body_color.a), boost_strength * 0.45)
    if boost_strength > 0.0:
        draw_circle(screen_pos, (PLAYER_RADIUS + 8.0 + boost_strength * 4.0) * scale, Color(0.6, 0.92, 1.0, 0.1 + boost_strength * 0.16))
        draw_arc(screen_pos, (PLAYER_RADIUS + 9.0) * scale, 0.0, TAU, 32, Color(0.82, 0.97, 1.0, 0.18 + boost_strength * 0.28), 2.0 * scale)
    draw_circle(screen_pos, (PLAYER_RADIUS + 5.0) * scale, boost_shell)
    _draw_seeded_variation_spots(
        screen_pos,
        (PLAYER_RADIUS + 3.0) * scale,
        variation_seed,
        Color(0.03, 0.04, 0.05, 0.095 * shell_color.a),
        2,
        0.3,
        0.16,
        0.24
    )

    var pyramid_rotation: float = facing_angle

    # Local model points (before projection rotation by `pyramid_rotation`).
    var top_point: Vector2 = screen_pos + Vector2(0.0, -24.0).rotated(pyramid_rotation) * scale
    var rear_point: Vector2 = screen_pos + Vector2(0.0, 18.0).rotated(pyramid_rotation) * scale

    # Roll the side points around the travel axis: change their perpendicular offset (x),
    # and add a small depth-driven y shift so the twist reads like a 3D roll.
    var left_local: Vector2 = Vector2(-16.0, 10.0)
    var right_local: Vector2 = Vector2(16.0, 10.0)
    var left_rolled: Vector2 = Vector2(left_local.x * roll_cos, left_local.y + left_local.x * roll_sin * roll_depth_to_screen)
    var right_rolled: Vector2 = Vector2(right_local.x * roll_cos, right_local.y + right_local.x * roll_sin * roll_depth_to_screen)
    var left_point: Vector2 = screen_pos + left_rolled.rotated(pyramid_rotation) * scale
    var right_point: Vector2 = screen_pos + right_rolled.rotated(pyramid_rotation) * scale

    var front_facet: PackedVector2Array = PackedVector2Array([top_point, left_point, right_point])
    var left_facet: PackedVector2Array = PackedVector2Array([top_point, rear_point, left_point])
    var right_facet: PackedVector2Array = PackedVector2Array([top_point, right_point, rear_point])
    var base_facet: PackedVector2Array = PackedVector2Array([left_point, rear_point, right_point])

    var highlight_color: Color = boost_body.lerp(Color(1.0, 0.98, 0.86, boost_body.a), 0.4 + boost_strength * 0.25)
    var shadow_color: Color = boost_body.lerp(boost_shell, 0.42)
    var deep_shadow_color: Color = shadow_color.lerp(Color(0.08, 0.1, 0.13, shadow_color.a), 0.35)

    draw_colored_polygon(base_facet, deep_shadow_color)
    draw_colored_polygon(left_facet, shadow_color)
    draw_colored_polygon(right_facet, boost_body)
    draw_colored_polygon(front_facet, highlight_color)
    _draw_seeded_variation_spots(
        screen_pos + Vector2(0.0, 4.0).rotated(facing_angle) * scale,
        PLAYER_RADIUS * 0.72 * scale,
        variation_seed + 5.4,
        Color(0.03, 0.04, 0.05, 0.075 * body_color.a),
        2,
        0.24,
        0.14,
        0.22
    )
    _draw_seeded_variation_highlight(
        screen_pos + Vector2(-2.0, -4.0).rotated(facing_angle) * scale,
        PLAYER_RADIUS * 0.78 * scale,
        variation_seed + 8.3,
        Color(1.0, 0.99, 0.9, 0.05 + boost_strength * 0.035),
        0.18
    )

    draw_polyline(PackedVector2Array([top_point, left_point, rear_point, right_point, top_point]), Color(0.98, 0.95, 0.82, 0.55 * boost_body.a), maxf(1.3, 2.0 * scale))
    draw_line(top_point, rear_point, Color(1.0, 0.97, 0.9, 0.45 * boost_body.a), maxf(1.0, 1.4 * scale))

    var engine_glow_pos: Vector2 = screen_pos + Vector2(0.0, 18.0).rotated(facing_angle) * scale
    draw_circle(engine_glow_pos, (4.5 + boost_strength * 2.5) * scale, Color(1.0, 0.86, 0.42, 0.55))
    if boost_strength > 0.0:
        var exhaust_tip: Vector2 = screen_pos + Vector2(0.0, 30.0 + boost_strength * 8.0).rotated(facing_angle) * scale
        var exhaust_left: Vector2 = engine_glow_pos + Vector2(-4.5, 4.0).rotated(facing_angle) * scale
        var exhaust_right: Vector2 = engine_glow_pos + Vector2(4.5, 4.0).rotated(facing_angle) * scale
        draw_colored_polygon(PackedVector2Array([exhaust_left, exhaust_tip, exhaust_right]), Color(0.82, 0.96, 1.0, 0.22 + boost_strength * 0.2))

func _draw_target_line(origin: Vector2) -> void:
    if run_state != RUN_STATES.RUNNING:
        return
    if target_node_id < 0 or target_node_id >= world_nodes.size():
        return
    var target_pos: Vector2 = world_nodes[target_node_id].get("pos", Vector2.ZERO)
    draw_line(_world_to_screen(player_pos), _world_to_screen(target_pos), Color(1.0, 0.9, 0.5, 0.42), 2.0)

func _draw_run_end_fx() -> void:
    if run_state != RUN_STATES.ENDING:
        return
    var progress: float = _get_run_end_progress()
    var alpha: float = _get_run_end_draw_alpha()
    if alpha <= 0.0:
        return
    var screen_pos: Vector2 = _world_to_screen(player_pos)
    var heading: Vector2 = _get_run_end_heading(progress)
    var side: Vector2 = Vector2(-heading.y, heading.x)
    var accent: Color = Color(1.0, 0.78, 0.38, 0.9 * alpha)
    var cool_accent: Color = Color(0.74, 0.92, 1.0, 0.65 * alpha)
    var rear: Vector2 = screen_pos - heading * (20.0 + 18.0 * progress)
    draw_line(rear - side * 10.0, rear + side * 10.0, accent, 2.4)
    draw_line(rear - side * 17.0, rear + side * 17.0, cool_accent, 1.6)
    for stripe_index in range(4):
        var stripe_progress: float = float(stripe_index) / 3.0
        var stripe_anchor: Vector2 = screen_pos - heading * (18.0 + 34.0 * stripe_progress + 18.0 * progress)
        var stripe_half: float = 8.0 + 9.0 * stripe_progress
        var stripe_color: Color = accent.lerp(cool_accent, stripe_progress)
        stripe_color.a *= 1.0 - stripe_progress * 0.25
        draw_line(stripe_anchor - side * stripe_half, stripe_anchor + side * stripe_half, stripe_color, 1.5 + (1.0 - stripe_progress))
    var fin_tip: Vector2 = screen_pos - heading * (28.0 + 10.0 * progress)
    draw_colored_polygon(
        PackedVector2Array([
            fin_tip,
            fin_tip - side * 13.0 - heading * 15.0,
            fin_tip + side * 13.0 - heading * 15.0
        ]),
        Color(1.0, 0.9, 0.64, 0.18 * alpha)
    )

func _draw_edge_fade(viewport_size: Vector2) -> void:
    var origin := viewport_size * 0.5 - camera_pos
    var world_size: Vector2 = _get_world_size()
    var world_rect := Rect2(origin - world_size * 0.5, world_size)

    var inside := _get_level_bg_color()
    var accent := _get_level_edge_accent_color()
    var outside := Color(0.02, 0.03, 0.05, 1.0).lerp(accent, 0.1)
    outside.a = 0.54

    var world_top := world_rect.position.y
    var world_bottom := world_rect.position.y + world_rect.size.y
    var world_left := world_rect.position.x
    var world_right := world_rect.position.x + world_rect.size.x

    # Darken anything outside the mining "world" bounds.
    if world_top > 0.0:
        draw_rect(Rect2(0.0, 0.0, viewport_size.x, world_top), outside, true)
    if world_bottom < viewport_size.y:
        draw_rect(Rect2(0.0, world_bottom, viewport_size.x, viewport_size.y - world_bottom), outside, true)
    if world_left > 0.0:
        draw_rect(Rect2(0.0, 0.0, world_left, viewport_size.y), outside, true)
    if world_right < viewport_size.x:
        draw_rect(Rect2(world_right, 0.0, viewport_size.x - world_right, viewport_size.y), outside, true)

    # Use a framed lip plus outward ticks instead of a flat black box.
    var outer_frame := accent.darkened(0.35)
    outer_frame.a = 0.95
    var inner_frame := accent.lightened(0.2)
    inner_frame.a = 0.95
    var glow := accent.lightened(0.42)
    glow.a = 0.18
    draw_rect(world_rect.grow(6.0), glow, false, 14.0)
    draw_rect(world_rect.grow(2.5), outer_frame, false, 5.0)
    draw_rect(world_rect, inner_frame, false, 2.5)

    var lip_color := inside.lerp(accent, 0.34)
    lip_color.a = 0.38
    draw_rect(world_rect.grow(-8.0), lip_color, false, 10.0)

    _draw_edge_ticks(world_rect, accent)
    _draw_edge_corner_markers(world_rect, accent)
    if run_state == RUN_STATES.ENDING:
        var fade_alpha: float = _get_run_end_overlay_alpha()
        if fade_alpha > 0.0:
            draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.01, 0.02, fade_alpha), true)
    elif run_state == RUN_STATES.SUMMARY and summary_transition_active:
        var summary_dim_alpha: float = _get_summary_dim_alpha()
        if summary_dim_alpha > 0.0:
            draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.01, 0.02, summary_dim_alpha), true)

func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, dash_length: float, gap_length: float, width: float) -> void:
    var dir := to - from
    var len := dir.length()
    if len <= 0.001:
        return
    dir /= len

    var step := dash_length + gap_length
    var dist := 0.0
    while dist < len:
        var start: Vector2 = from + dir * dist
        var end: Vector2 = from + dir * min(len, dist + dash_length)
        draw_line(start, end, color, width)
        dist += step

func _get_base_position() -> Vector2:
    var world_size: Vector2 = _get_world_size()
    return Vector2(0.0, -world_size.y * 0.5 + 120.0)

func _get_world_scale_multiplier() -> float:
    var completed_tier_bands: int = int(floor(float(active_depth_level) / 10.0))
    return 1.0 + float(completed_tier_bands) * LEVEL_SIZE_GROWTH_PER_10_TIERS

func _get_world_size() -> Vector2:
    return WORLD_SIZE * _get_world_scale_multiplier()

func _get_world_area_multiplier() -> float:
    var scale_multiplier: float = _get_world_scale_multiplier()
    return scale_multiplier * scale_multiplier

func _world_to_screen(world_pos: Vector2) -> Vector2:
    return world_pos - camera_pos + get_viewport_rect().size * 0.5

func _screen_to_world(screen_pos: Vector2) -> Vector2:
    return screen_pos + camera_pos - get_viewport_rect().size * 0.5

func _get_level_bg_color() -> Color:
    var tint: Color = Color(0.18, 0.14, 0.11, 1.0)
    var depth_factor: float = float(active_depth_level - 1) / float(max(1, material_tiers.size() - 1))
    var base := tint.lerp(active_material.get("bg", Color(0.16, 0.12, 0.1, 1.0)), clampf(depth_factor * 0.75, 0.0, 0.8))

    # Deterministic per-depth palette shift (no RNG / no dependence on run seed),
    # so `depth_level=3` always looks the same.
    var seed := float(active_depth_level - 1) + _get_visual_style_seed_offset() * 0.013
    var r_mul := 1.0 + 0.06 * sin(seed * 1.17 + 0.11)
    var g_mul := 1.0 + 0.05 * sin(seed * 0.83 + 1.72)
    var b_mul := 1.0 + 0.07 * sin(seed * 1.43 + 3.21)

    var out := Color(
        clampf(base.r * r_mul, 0.0, 1.0),
        clampf(base.g * g_mul, 0.0, 1.0),
        clampf(base.b * b_mul, 0.0, 1.0),
        1.0
    )

    # Give each depth a more distinct, still deterministic accent tint.
    var accent := _get_level_edge_accent_color()
    out = out.lerp(accent, 0.08 + 0.07 * depth_factor)

    # Subtle extra blend toward the active material background so changes feel coherent.
    var material_bg: Color = active_material.get("bg", Color(0.16, 0.12, 0.1, 1.0))
    out = out.lerp(material_bg, 0.06)
    return _apply_visual_palette_variant(out, float(active_depth_level) * 4.3 + 1.2, 0.85)

func _get_level_edge_accent_color() -> Color:
    var seed := float(active_depth_level) + _get_visual_style_seed_offset() * 0.017
    var accent := Color(
        0.4 + 0.26 * (0.5 + 0.5 * sin(seed * 0.91 + 0.4)),
        0.46 + 0.24 * (0.5 + 0.5 * sin(seed * 1.27 + 2.1)),
        0.5 + 0.28 * (0.5 + 0.5 * sin(seed * 1.53 + 4.0)),
        1.0
    )
    return _apply_visual_palette_variant(accent.lerp(active_material.get("color", Color(0.8, 0.82, 0.86, 1.0)), 0.28), float(active_depth_level) * 5.9 + 2.8, 0.92)

func _ensure_background_noise_texture() -> void:
    if background_noise_texture != null and last_background_noise_depth_level == active_depth_level:
        return
    last_background_noise_depth_level = active_depth_level
    background_noise_texture = _make_background_noise_texture(active_depth_level)

func _make_background_noise_texture(depth_level: int) -> ImageTexture:
    # Small seeded speckle texture, tiled across the world rect.
    var noise_size: int = 256
    var img: Image = Image.create(noise_size, noise_size, false, Image.FORMAT_RGBA8)
    var nrng := RandomNumberGenerator.new()
    # Deterministic seed per depth level.
    nrng.seed = 1337 + depth_level * 10007 + visual_style_reroll_index * 7919

    for y in range(noise_size):
        for x in range(noise_size):
            # Mix of "grain" and rarer "dots" for a subtle CRT-ish texture.
            var n1 := nrng.randf()
            var n2 := nrng.randf()
            var n3 := nrng.randf()
            var dot: float = maxf(0.0, n1 - 0.68) / 0.32
            dot = pow(dot, 2.2)
            var grain: float = pow(n2, 3.8)
            var cluster: float = pow(maxf(0.0, n3 - 0.8) / 0.2, 1.6)
            var alpha := clampf(0.012 + dot * 0.18 + grain * 0.045 + cluster * 0.11, 0.0, 0.28)
            img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
    return ImageTexture.create_from_image(img)

func _draw_background_doodads(world_rect: Rect2) -> void:
    var bg := _get_level_bg_color()
    var accent := _get_level_edge_accent_color()
    _draw_background_dark_spots(world_rect, bg, accent)
    var stratum_color := bg.lerp(accent, 0.18)
    stratum_color.a = 0.15
    var dot_color := accent.lightened(0.12)
    dot_color.a = 0.12
    var ring_color := accent.lightened(0.26)
    ring_color.a = 0.1
    var smudge_color := bg.darkened(0.22)
    smudge_color.a = 0.05
    var seed_base := float(active_depth_level) * 97.0 + _get_visual_style_seed_offset()
    for index in range(DEPTH_DOODAD_COUNT):
        var fi := float(index)
        var px := world_rect.position.x + world_rect.size.x * (0.08 + 0.84 * _depth_noise(seed_base, fi * 1.37 + 0.2))
        var py := world_rect.position.y + world_rect.size.y * (0.06 + 0.88 * _depth_noise(seed_base, fi * 1.91 + 3.4))
        var pos := Vector2(px, py)
        var radius := 18.0 + 34.0 * _depth_noise(seed_base, fi * 2.23 + 1.1)
        var angle := TAU * _depth_noise(seed_base, fi * 2.57 + 5.9)
        var stratum_len := radius * (1.5 + 0.9 * _depth_noise(seed_base, fi * 0.77 + 8.0))
        var dir := Vector2.RIGHT.rotated(angle)
        draw_line(pos - dir * stratum_len, pos + dir * stratum_len, stratum_color, 2.0)
        if index % 2 == 0:
            _draw_seeded_variation_spots(pos, radius, seed_base + fi * 13.0, smudge_color, 2, 0.34, 0.16, 0.22)
        draw_circle(pos, 2.0 + radius * 0.08, dot_color)
        if index % 3 == 0:
            draw_arc(pos, radius, angle - 0.7, angle + 0.7, 14, ring_color, 2.0)

func _draw_background_dark_spots(world_rect: Rect2, bg: Color, accent: Color) -> void:
    var seed_base := float(active_depth_level) * 211.0 + _get_visual_style_seed_offset()
    var outer_color := bg.darkened(0.26).lerp(accent.darkened(0.55), 0.15)
    outer_color.a = 0.17
    var inner_color := bg.darkened(0.38)
    inner_color.a = 0.11
    for index in range(DEPTH_DARK_SPOT_COUNT):
        var fi := float(index)
        var center := Vector2(
            world_rect.position.x + world_rect.size.x * (0.14 + 0.72 * _depth_noise(seed_base, fi * 1.11 + 0.8)),
            world_rect.position.y + world_rect.size.y * (0.14 + 0.72 * _depth_noise(seed_base, fi * 1.63 + 2.6))
        )
        var radius_x := 60.0 + 95.0 * _depth_noise(seed_base, fi * 2.07 + 4.9)
        var radius_y := 46.0 + 82.0 * _depth_noise(seed_base, fi * 2.43 + 1.7)
        var angle := TAU * _depth_noise(seed_base, fi * 2.81 + 5.4)
        _draw_soft_dark_spot(center, radius_x, radius_y, angle, outer_color, inner_color)

func _draw_soft_dark_spot(center: Vector2, radius_x: float, radius_y: float, angle: float, outer_color: Color, inner_color: Color) -> void:
    var ring_count: int = 4
    var point_count: int = 22
    for ring_index in range(ring_count, 0, -1):
        var t := float(ring_index) / float(ring_count)
        var ring_color := outer_color.lerp(inner_color, 1.0 - t)
        ring_color.a *= 0.55 + 0.45 * (1.0 - t)
        var points := PackedVector2Array()
        for point_index in range(point_count):
            var phase := TAU * float(point_index) / float(point_count)
            var wobble := 0.88 + 0.18 * sin(phase * 3.0 + angle * 1.7)
            var local := Vector2(cos(phase) * radius_x * t * wobble, sin(phase) * radius_y * t * wobble)
            points.append(center + local.rotated(angle))
        draw_colored_polygon(points, ring_color)

func _draw_seeded_variation_spots(center: Vector2, base_radius: float, seed_base: float, color: Color, spot_count: int = 2, spread: float = 0.38, scale_min: float = 0.18, scale_max: float = 0.28) -> void:
    if base_radius <= 0.0 or color.a <= 0.0 or spot_count <= 0:
        return
    var strength := _get_effective_dot_variation_strength()
    var effective_count: int = max(1, int(round(float(spot_count) * (0.72 + strength * 0.38))))
    var alpha_scale: float = 0.52 + strength * 0.48
    var radius_scale: float = 0.86 + strength * 0.14
    var spread_scale: float = 0.92 + strength * 0.08
    for spot_index in range(effective_count):
        var fi := float(spot_index)
        var orbit_angle := TAU * _depth_noise(seed_base, fi * 1.93 + 0.37)
        var orbit_distance := base_radius * spread * spread_scale * _depth_noise(seed_base, fi * 2.17 + 1.91)
        var spot_radius := base_radius * radius_scale * lerpf(scale_min, scale_max, _depth_noise(seed_base, fi * 2.71 + 3.11))
        var spot_center := center + Vector2.RIGHT.rotated(orbit_angle) * orbit_distance
        var outer_color := color
        outer_color.a *= alpha_scale * (0.55 + 0.35 * _depth_noise(seed_base, fi * 3.19 + 4.73))
        var inner_color := color.darkened(0.18)
        inner_color.a = outer_color.a * 0.92
        draw_circle(spot_center, spot_radius * 1.12, outer_color)
        var inner_offset := Vector2.RIGHT.rotated(orbit_angle + PI * (0.18 + 0.22 * _depth_noise(seed_base, fi * 3.73 + 2.41))) * spot_radius * 0.16
        draw_circle(spot_center + inner_offset, spot_radius * 0.72, inner_color)

func _draw_seeded_variation_highlight(center: Vector2, base_radius: float, seed_base: float, color: Color, offset_strength: float = 0.24) -> void:
    if base_radius <= 0.0 or color.a <= 0.0:
        return
    var strength := _get_effective_dot_variation_strength()
    var angle := -PI * 0.62 + (_depth_noise(seed_base, 0.61) - 0.5) * 0.75
    var offset := Vector2.RIGHT.rotated(angle) * base_radius * offset_strength
    var highlight_radius := base_radius * (0.3 + 0.08 * strength + 0.12 * _depth_noise(seed_base, 1.67))
    var highlight_color := color
    highlight_color.a *= 0.5 + strength * 0.42
    draw_circle(center + offset, highlight_radius, highlight_color)

func _draw_seeded_crack_lines_with_strength(center: Vector2, base_radius: float, seed_base: float, color: Color, strength: float, line_count: int = 2, width: float = 1.4) -> void:
    if base_radius <= 0.0 or color.a <= 0.0 or line_count <= 0:
        return
    var effective_count: int = max(1, int(round(float(line_count) * (0.65 + strength * 0.45))))
    var alpha_scale: float = 0.46 + strength * 0.34
    var width_scale: float = 0.8 + strength * 0.14
    for crack_index in range(effective_count):
        var fi := float(crack_index)
        var start_angle := TAU * _depth_noise(seed_base, fi * 1.31 + 0.17)
        var span_sign := -1.0 if int(fi) % 2 == 0 else 1.0
        var branch_angle := start_angle + span_sign * (0.28 + 0.45 * _depth_noise(seed_base, fi * 1.93 + 0.81))
        var start_radius := base_radius * (0.08 + 0.18 * _depth_noise(seed_base, fi * 2.27 + 1.43))
        var mid_radius := base_radius * (0.28 + 0.2 * _depth_noise(seed_base, fi * 2.71 + 2.19))
        var end_radius := base_radius * (0.54 + 0.24 * _depth_noise(seed_base, fi * 3.19 + 2.77))
        var start_pos := center + Vector2.RIGHT.rotated(start_angle) * start_radius
        var mid_pos := center + Vector2.RIGHT.rotated(start_angle + span_sign * 0.1) * mid_radius
        var end_pos := center + Vector2.RIGHT.rotated(branch_angle) * end_radius
        var crack_color := color
        crack_color.a *= alpha_scale * (0.64 + 0.24 * _depth_noise(seed_base, fi * 3.61 + 3.41))
        var crack_width := maxf(0.85, width * width_scale * (0.85 + 0.2 * _depth_noise(seed_base, fi * 4.07 + 4.33)))
        draw_line(start_pos, mid_pos, crack_color, crack_width)
        draw_line(mid_pos, end_pos, crack_color, crack_width * 0.9)
        var branch_len := base_radius * (0.14 + 0.12 * _depth_noise(seed_base, fi * 4.63 + 1.61))
        var branch_dir := Vector2.RIGHT.rotated(branch_angle + span_sign * (0.55 + 0.2 * _depth_noise(seed_base, fi * 5.21 + 0.94)))
        draw_line(mid_pos, mid_pos + branch_dir * branch_len, crack_color, crack_width * 0.72)

func _build_node_render_cache(node: Dictionary) -> Dictionary:
    var local_points: PackedVector2Array = node.get("shape_points", PackedVector2Array())
    if local_points.is_empty():
        return {}

    var node_seed: float = float(int(node.get("id", 0))) * 17.0 + float(active_depth_level) * 7.0
    var radius: float = float(node.get("radius", 20.0))
    var node_color: Color = _apply_material_color_variation(node.get("material_color", Color(0.5, 0.5, 0.5, 1.0)), node_seed + 0.9, 0.9)
    var luma: float = node_color.r * 0.299 + node_color.g * 0.587 + node_color.b * 0.114
    var grey_color: Color = Color(luma, luma, luma, node_color.a)
    var inner_color: Color = node_color.lerp(grey_color, 0.55)
    var sparkle: float = float(node.get("sparkle", 0.0))
    var padding: float = 14.0 + sparkle * 4.0
    var min_x: float = local_points[0].x
    var max_x: float = local_points[0].x
    var min_y: float = local_points[0].y
    var max_y: float = local_points[0].y
    for point in local_points:
        min_x = minf(min_x, point.x)
        max_x = maxf(max_x, point.x)
        min_y = minf(min_y, point.y)
        max_y = maxf(max_y, point.y)

    var draw_size: Vector2 = Vector2(
        ceil(max_x - min_x + padding * 2.0),
        ceil(max_y - min_y + padding * 2.0)
    )
    var center_in_image: Vector2 = Vector2(-min_x + padding, -min_y + padding)
    var image_points: PackedVector2Array = PackedVector2Array()
    for point in local_points:
        image_points.append(point + center_in_image)

    var detail_image: Image = Image.create(int(draw_size.x), int(draw_size.y), false, Image.FORMAT_RGBA8)
    detail_image.fill(Color(0.0, 0.0, 0.0, 0.0))
    _fill_polygon_on_image(detail_image, image_points, node_color)

    var node_spot_color: Color = _apply_material_color_variation(node.get("material_bg_color", node_color.darkened(0.46)), node_seed + 3.4, 0.55)
    node_spot_color.a = 0.13
    _paint_seeded_variation_spots_on_image(detail_image, center_in_image, radius, node_seed, node_spot_color, 2, 0.42, 0.16, 0.27)
    _paint_seeded_variation_highlight_on_image(
        detail_image,
        center_in_image,
        radius,
        node_seed + 2.6,
        Color(1.0, 1.0, 1.0, 0.028 + sparkle * 0.014),
        0.24
    )
    _paint_seeded_crack_lines_on_image(
        detail_image,
        center_in_image,
        radius,
        node_seed + 7.8,
        Color(0.04, 0.05, 0.06, 0.14),
        1,
        1.15
    )
    _paint_node_sparkles_on_image(detail_image, center_in_image, radius, sparkle)

    var mined_image: Image = Image.create(int(draw_size.x), int(draw_size.y), false, Image.FORMAT_RGBA8)
    mined_image.fill(Color(0.0, 0.0, 0.0, 0.0))
    _fill_polygon_on_image(mined_image, image_points, inner_color)

    return {
        "cached_detail_texture": ImageTexture.create_from_image(detail_image),
        "cached_detail_mined_texture": ImageTexture.create_from_image(mined_image),
        "cached_detail_offset": center_in_image,
        "cached_detail_size": draw_size
    }

func _fill_polygon_on_image(image: Image, points: PackedVector2Array, color: Color) -> void:
    if image == null or points.size() < 3:
        return
    var indices: PackedInt32Array = Geometry2D.triangulate_polygon(points)
    if indices.is_empty():
        return
    for triangle_index in range(0, indices.size(), 3):
        var a: Vector2 = points[indices[triangle_index]]
        var b: Vector2 = points[indices[triangle_index + 1]]
        var c: Vector2 = points[indices[triangle_index + 2]]
        _fill_triangle_on_image(image, a, b, c, color)

func _fill_triangle_on_image(image: Image, a: Vector2, b: Vector2, c: Vector2, color: Color) -> void:
    var min_x: int = maxi(0, int(floor(minf(a.x, minf(b.x, c.x)))))
    var max_x: int = mini(image.get_width() - 1, int(ceil(maxf(a.x, maxf(b.x, c.x)))))
    var min_y: int = maxi(0, int(floor(minf(a.y, minf(b.y, c.y)))))
    var max_y: int = mini(image.get_height() - 1, int(ceil(maxf(a.y, maxf(b.y, c.y)))))
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            var sample_point: Vector2 = Vector2(float(x) + 0.5, float(y) + 0.5)
            if _point_in_triangle(sample_point, a, b, c):
                image.set_pixel(x, y, color)

func _point_in_triangle(point: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
    var d1: float = _triangle_edge_sign(point, a, b)
    var d2: float = _triangle_edge_sign(point, b, c)
    var d3: float = _triangle_edge_sign(point, c, a)
    var has_neg: bool = d1 < 0.0 or d2 < 0.0 or d3 < 0.0
    var has_pos: bool = d1 > 0.0 or d2 > 0.0 or d3 > 0.0
    return not (has_neg and has_pos)

func _triangle_edge_sign(point: Vector2, a: Vector2, b: Vector2) -> float:
    return (point.x - b.x) * (a.y - b.y) - (a.x - b.x) * (point.y - b.y)

func _paint_seeded_variation_spots_on_image(image: Image, center: Vector2, base_radius: float, seed_base: float, color: Color, spot_count: int = 2, spread: float = 0.38, scale_min: float = 0.18, scale_max: float = 0.28) -> void:
    if image == null or base_radius <= 0.0 or color.a <= 0.0 or spot_count <= 0:
        return
    var strength: float = _get_effective_dot_variation_strength()
    var effective_count: int = max(1, int(round(float(spot_count) * (0.72 + strength * 0.38))))
    var alpha_scale: float = 0.52 + strength * 0.48
    var radius_scale: float = 0.86 + strength * 0.14
    var spread_scale: float = 0.92 + strength * 0.08
    for spot_index in range(effective_count):
        var fi: float = float(spot_index)
        var orbit_angle: float = TAU * _depth_noise(seed_base, fi * 1.93 + 0.37)
        var orbit_distance: float = base_radius * spread * spread_scale * _depth_noise(seed_base, fi * 2.17 + 1.91)
        var spot_radius: float = base_radius * radius_scale * lerpf(scale_min, scale_max, _depth_noise(seed_base, fi * 2.71 + 3.11))
        var spot_center: Vector2 = center + Vector2.RIGHT.rotated(orbit_angle) * orbit_distance
        var outer_color: Color = color
        outer_color.a *= alpha_scale * (0.55 + 0.35 * _depth_noise(seed_base, fi * 3.19 + 4.73))
        _paint_image_variation_spot(image, spot_center, spot_radius * 1.12, spot_radius * 1.12, 0.0, outer_color)
        var inner_color: Color = color.darkened(0.18)
        inner_color.a = outer_color.a * 0.92
        var inner_offset: Vector2 = Vector2.RIGHT.rotated(orbit_angle + PI * (0.18 + 0.22 * _depth_noise(seed_base, fi * 3.73 + 2.41))) * spot_radius * 0.16
        _paint_image_variation_spot(image, spot_center + inner_offset, spot_radius * 0.72, spot_radius * 0.72, 0.0, inner_color)

func _paint_seeded_variation_highlight_on_image(image: Image, center: Vector2, base_radius: float, seed_base: float, color: Color, offset_strength: float = 0.24) -> void:
    if image == null or base_radius <= 0.0 or color.a <= 0.0:
        return
    var strength: float = _get_effective_dot_variation_strength()
    var angle: float = -PI * 0.62 + (_depth_noise(seed_base, 0.61) - 0.5) * 0.75
    var offset: Vector2 = Vector2.RIGHT.rotated(angle) * base_radius * offset_strength
    var highlight_radius: float = base_radius * (0.3 + 0.08 * strength + 0.12 * _depth_noise(seed_base, 1.67))
    var highlight_color: Color = color
    highlight_color.a *= 0.5 + strength * 0.42
    _paint_image_variation_spot(image, center + offset, highlight_radius, highlight_radius, 0.0, highlight_color)

func _paint_seeded_crack_lines_on_image(image: Image, center: Vector2, base_radius: float, seed_base: float, color: Color, strength: float, line_count: int = 2, width: float = 1.4) -> void:
    if image == null or base_radius <= 0.0 or color.a <= 0.0 or line_count <= 0:
        return
    var effective_count: int = max(1, int(round(float(line_count) * (0.65 + strength * 0.45))))
    var alpha_scale: float = 0.46 + strength * 0.34
    var width_scale: float = 0.8 + strength * 0.14
    for crack_index in range(effective_count):
        var fi: float = float(crack_index)
        var start_angle: float = TAU * _depth_noise(seed_base, fi * 1.31 + 0.17)
        var span_sign: float = -1.0 if int(fi) % 2 == 0 else 1.0
        var branch_angle: float = start_angle + span_sign * (0.28 + 0.45 * _depth_noise(seed_base, fi * 1.93 + 0.81))
        var start_radius: float = base_radius * (0.08 + 0.18 * _depth_noise(seed_base, fi * 2.27 + 1.43))
        var mid_radius: float = base_radius * (0.28 + 0.2 * _depth_noise(seed_base, fi * 2.71 + 2.19))
        var end_radius: float = base_radius * (0.54 + 0.24 * _depth_noise(seed_base, fi * 3.19 + 2.77))
        var start_pos: Vector2 = center + Vector2.RIGHT.rotated(start_angle) * start_radius
        var mid_pos: Vector2 = center + Vector2.RIGHT.rotated(start_angle + span_sign * 0.1) * mid_radius
        var end_pos: Vector2 = center + Vector2.RIGHT.rotated(branch_angle) * end_radius
        var crack_color: Color = color
        crack_color.a *= alpha_scale * (0.64 + 0.24 * _depth_noise(seed_base, fi * 3.61 + 3.41))
        var crack_width: float = maxf(0.85, width * width_scale * (0.85 + 0.2 * _depth_noise(seed_base, fi * 4.07 + 4.33)))
        _paint_image_variation_crack(image, start_pos, mid_pos, crack_color, crack_width)
        _paint_image_variation_crack(image, mid_pos, end_pos, crack_color, crack_width * 0.9)
        var branch_len: float = base_radius * (0.14 + 0.12 * _depth_noise(seed_base, fi * 4.63 + 1.61))
        var branch_dir: Vector2 = Vector2.RIGHT.rotated(branch_angle + span_sign * (0.55 + 0.2 * _depth_noise(seed_base, fi * 5.21 + 0.94)))
        _paint_image_variation_crack(image, mid_pos, mid_pos + branch_dir * branch_len, crack_color, crack_width * 0.72)

func _paint_node_sparkles_on_image(image: Image, center: Vector2, radius: float, sparkle: float) -> void:
    if image == null or sparkle <= 0.0:
        return
    var sparkle_count: int = int(round(2.0 + sparkle * 4.0))
    for sparkle_index in range(sparkle_count):
        var angle: float = TAU * float(sparkle_index) / float(max(1, sparkle_count))
        var pos: Vector2 = center + Vector2.RIGHT.rotated(angle) * (radius * 0.58)
        _paint_image_variation_spot(image, pos, 2.0 + sparkle, 2.0 + sparkle, 0.0, Color(1.0, 1.0, 1.0, 0.75))

func _draw_seeded_crack_lines(center: Vector2, base_radius: float, seed_base: float, color: Color, line_count: int = 2, width: float = 1.4) -> void:
    _draw_seeded_crack_lines_with_strength(center, base_radius, seed_base, color, _get_effective_crack_variation_strength(), line_count, width)

func _draw_seeded_mineral_crack_lines(center: Vector2, base_radius: float, seed_base: float, color: Color, line_count: int = 1, width: float = 1.0) -> void:
    _draw_seeded_crack_lines_with_strength(center, base_radius, seed_base, color, _get_effective_mineral_crack_variation_strength(), line_count, width)

func _draw_edge_ticks(world_rect: Rect2, accent: Color) -> void:
    var tick_color := accent.lightened(0.3)
    tick_color.a = 0.86
    var shadow_color := accent.darkened(0.45)
    shadow_color.a = 0.5

    var x := world_rect.position.x + EDGE_TICK_SPACING * 0.5
    while x < world_rect.end.x:
        draw_line(Vector2(x, world_rect.position.y - EDGE_TICK_LENGTH), Vector2(x, world_rect.position.y - 3.0), shadow_color, EDGE_TICK_WIDTH + 1.5)
        draw_line(Vector2(x, world_rect.position.y - EDGE_TICK_LENGTH), Vector2(x, world_rect.position.y - 3.0), tick_color, EDGE_TICK_WIDTH)
        draw_line(Vector2(x, world_rect.end.y + 3.0), Vector2(x, world_rect.end.y + EDGE_TICK_LENGTH), shadow_color, EDGE_TICK_WIDTH + 1.5)
        draw_line(Vector2(x, world_rect.end.y + 3.0), Vector2(x, world_rect.end.y + EDGE_TICK_LENGTH), tick_color, EDGE_TICK_WIDTH)
        x += EDGE_TICK_SPACING

    var y := world_rect.position.y + EDGE_TICK_SPACING * 0.5
    while y < world_rect.end.y:
        draw_line(Vector2(world_rect.position.x - EDGE_TICK_LENGTH, y), Vector2(world_rect.position.x - 3.0, y), shadow_color, EDGE_TICK_WIDTH + 1.5)
        draw_line(Vector2(world_rect.position.x - EDGE_TICK_LENGTH, y), Vector2(world_rect.position.x - 3.0, y), tick_color, EDGE_TICK_WIDTH)
        draw_line(Vector2(world_rect.end.x + 3.0, y), Vector2(world_rect.end.x + EDGE_TICK_LENGTH, y), shadow_color, EDGE_TICK_WIDTH + 1.5)
        draw_line(Vector2(world_rect.end.x + 3.0, y), Vector2(world_rect.end.x + EDGE_TICK_LENGTH, y), tick_color, EDGE_TICK_WIDTH)
        y += EDGE_TICK_SPACING

func _draw_edge_corner_markers(world_rect: Rect2, accent: Color) -> void:
    var corner_color := accent.lightened(0.42)
    corner_color.a = 1.0
    var shadow_color := accent.darkened(0.55)
    shadow_color.a = 0.55

    _draw_corner_marker(world_rect.position, Vector2.RIGHT, Vector2.DOWN, corner_color, shadow_color)
    _draw_corner_marker(Vector2(world_rect.end.x, world_rect.position.y), Vector2.LEFT, Vector2.DOWN, corner_color, shadow_color)
    _draw_corner_marker(Vector2(world_rect.position.x, world_rect.end.y), Vector2.RIGHT, Vector2.UP, corner_color, shadow_color)
    _draw_corner_marker(world_rect.end, Vector2.LEFT, Vector2.UP, corner_color, shadow_color)

func _draw_corner_marker(corner: Vector2, x_dir: Vector2, y_dir: Vector2, color: Color, shadow_color: Color) -> void:
    draw_line(corner, corner + x_dir * EDGE_CORNER_LENGTH, shadow_color, EDGE_CORNER_WIDTH + 2.0)
    draw_line(corner, corner + y_dir * EDGE_CORNER_LENGTH, shadow_color, EDGE_CORNER_WIDTH + 2.0)
    draw_line(corner, corner + x_dir * EDGE_CORNER_LENGTH, color, EDGE_CORNER_WIDTH)
    draw_line(corner, corner + y_dir * EDGE_CORNER_LENGTH, color, EDGE_CORNER_WIDTH)

func _depth_noise(seed_base: float, offset: float) -> float:
    return 0.5 + 0.5 * sin(seed_base * 0.61803398875 + offset * 1.913 + sin(offset * 0.73 + seed_base * 0.17))

func _build_rock_shape(radius: float) -> PackedVector2Array:
    var points: PackedVector2Array = PackedVector2Array()
    var point_count: int = 10
    var angle_offset: float = rng.randf_range(0.0, TAU)
    for point_index in range(point_count):
        var angle: float = angle_offset + TAU * float(point_index) / float(point_count)
        var point_radius: float = radius * rng.randf_range(0.76, 1.18)
        points.append(Vector2.RIGHT.rotated(angle) * point_radius)
    return points

func _get_translated_shape_points(node: Dictionary, center: Vector2) -> PackedVector2Array:
    var translated: PackedVector2Array = PackedVector2Array()
    var local_points: PackedVector2Array = node.get("shape_points", PackedVector2Array())
    for point in local_points:
        translated.append(center + point)
    return translated

func _initialize_dirt_mask() -> void:
    var use_web_low_res: bool = OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_HIGH_RES_DIRT_MASK)
    var dirt_width: int = 192 if use_web_low_res else 512
    var dirt_height: int = 224 if use_web_low_res else 640
    dirt_image = Image.create(dirt_width, dirt_height, false, Image.FORMAT_RGBA8)
    var bg := _get_level_bg_color()
    # Dirt overlays the rock, so make it inherit the depth palette a bit.
    var depth_factor: float = float(active_depth_level - 1) / float(max(1, material_tiers.size() - 1))
    var base_dirt := Color(0.38, 0.27, 0.16, 0.96)

    # Deterministic per-depth tint wobble so levels are distinct but consistent.
    var seed := float(active_depth_level - 1) + _get_visual_style_seed_offset() * 0.015
    var r_mul := 1.0 + 0.05 * sin(seed * 1.05 + 0.3)
    var g_mul := 1.0 + 0.05 * sin(seed * 0.77 + 1.7)
    var b_mul := 1.0 + 0.05 * sin(seed * 1.27 + 2.8)
    base_dirt.r = clampf(base_dirt.r * r_mul, 0.0, 1.0)
    base_dirt.g = clampf(base_dirt.g * g_mul, 0.0, 1.0)
    base_dirt.b = clampf(base_dirt.b * b_mul, 0.0, 1.0)

    var dirt_tint_strength := 0.18 + 0.22 * clampf(depth_factor, 0.0, 1.0)
    base_dirt = base_dirt.lerp(bg, dirt_tint_strength)
    base_dirt.a = 0.96
    dirt_image.fill(base_dirt)
    _apply_dirt_variation(dirt_image)
    dirt_texture = ImageTexture.create_from_image(dirt_image)
    dirt_texture_dirty = false

func _apply_dirt_variation(image: Image) -> void:
    if image == null:
        return
    var seed_base := float(active_depth_level) * 173.0 + _get_visual_style_seed_offset()
    var strength := _get_effective_dot_variation_strength()
    var crack_strength := _get_effective_crack_variation_strength()
    var width: float = float(image.get_width())
    var height: float = float(image.get_height())
    var effective_spot_count: int = max(6, int(round(float(DIRT_VARIATION_SPOT_COUNT) * (0.68 + strength * 0.34))))
    for spot_index in range(effective_spot_count):
        var fi := float(spot_index)
        var center := Vector2(
            width * (0.08 + 0.84 * _depth_noise(seed_base, fi * 1.11 + 0.4)),
            height * (0.08 + 0.84 * _depth_noise(seed_base, fi * 1.63 + 1.8))
        )
        var radius_x := (18.0 + 44.0 * _depth_noise(seed_base, fi * 2.07 + 3.1)) * (0.82 + strength * 0.18)
        var radius_y := radius_x * lerpf(0.72, 1.24, _depth_noise(seed_base, fi * 2.41 + 4.6))
        var tint := image.get_pixel(
            clampi(int(round(center.x)), 0, image.get_width() - 1),
            clampi(int(round(center.y)), 0, image.get_height() - 1)
        ).darkened(0.22)
        tint.a = (0.05 + 0.06 * _depth_noise(seed_base, fi * 3.03 + 2.7)) * (0.55 + strength * 0.42)
        _paint_image_variation_spot(
            image,
            center,
            radius_x,
            radius_y,
            TAU * _depth_noise(seed_base, fi * 2.77 + 5.2),
            tint
        )
    var crack_count: int = max(6, int(round(4.0 + crack_strength * 4.0)))
    for crack_index in range(crack_count):
        var fi := float(crack_index)
        var start := Vector2(
            width * (0.1 + 0.8 * _depth_noise(seed_base, fi * 1.37 + 1.1)),
            height * (0.12 + 0.76 * _depth_noise(seed_base, fi * 1.91 + 0.6))
        )
        var angle := TAU * _depth_noise(seed_base, fi * 2.29 + 2.4)
        var bend := angle + (-1.0 if crack_index % 2 == 0 else 1.0) * (0.24 + 0.28 * _depth_noise(seed_base, fi * 2.73 + 4.8))
        var seg_a := start + Vector2.RIGHT.rotated(angle) * (18.0 + 24.0 * crack_strength)
        var seg_b := seg_a + Vector2.RIGHT.rotated(bend) * (16.0 + 22.0 * crack_strength)
        var crack_tint := image.get_pixel(
            clampi(int(round(start.x)), 0, image.get_width() - 1),
            clampi(int(round(start.y)), 0, image.get_height() - 1)
        ).darkened(0.35)
        crack_tint.a = 0.05 + 0.035 * crack_strength
        _paint_image_variation_crack(image, start, seg_a, crack_tint, 1.0 + crack_strength * 0.22)
        _paint_image_variation_crack(image, seg_a, seg_b, crack_tint, 0.9 + crack_strength * 0.2)

func _get_visual_style_seed_offset() -> float:
    return float(visual_style_reroll_index) * 1009.0

func _get_visual_variation_bias() -> float:
    return visual_variation_strength - VISUAL_VARIATION_STRENGTH_DEFAULT

func _get_tier_random_visual_strength(seed_offset: float, min_strength: float, max_strength: float) -> float:
    return lerpf(min_strength, max_strength, _depth_noise(float(active_depth_level) * 317.0 + _get_visual_style_seed_offset(), seed_offset))

func _get_effective_dot_variation_strength() -> float:
    return clampf(
        _get_tier_random_visual_strength(1.17, DOT_VARIATION_RANDOM_MIN, DOT_VARIATION_RANDOM_MAX) + _get_visual_variation_bias(),
        VISUAL_VARIATION_STRENGTH_MIN,
        VISUAL_VARIATION_STRENGTH_MAX
    )

func _get_effective_mineral_crack_variation_strength() -> float:
    return clampf(
        _get_tier_random_visual_strength(4.21, MINERAL_CRACK_VARIATION_RANDOM_MIN, MINERAL_CRACK_VARIATION_RANDOM_MAX) + _get_visual_variation_bias(),
        MINERAL_CRACK_VARIATION_RANDOM_MIN,
        MINERAL_CRACK_VARIATION_RANDOM_MAX
    )

func _get_effective_crack_variation_strength() -> float:
    return clampf(
        _get_tier_random_visual_strength(6.43, CRACK_VARIATION_RANDOM_MIN, CRACK_VARIATION_RANDOM_MAX) + _get_visual_variation_bias(),
        VISUAL_VARIATION_STRENGTH_MIN,
        VISUAL_VARIATION_STRENGTH_MAX
    )

func _apply_visual_palette_variant(base_color: Color, seed_base: float, amount: float = 0.7) -> Color:
    if base_color.a <= 0.0:
        return base_color
    var visual_seed := seed_base + _get_visual_style_seed_offset()
    var hue_shift := (_depth_noise(visual_seed, 0.13) - 0.5) * 0.09 * amount
    var sat_scale := 1.0 + (_depth_noise(visual_seed, 1.91) - 0.5) * 0.18 * amount
    var val_scale := 1.0 + (_depth_noise(visual_seed, 3.77) - 0.5) * 0.22 * amount
    var hsv := Color.from_hsv(
        fposmod(base_color.h + hue_shift, 1.0),
        clampf(base_color.s * sat_scale, 0.0, 1.0),
        clampf(base_color.v * val_scale, 0.0, 1.0),
        base_color.a
    )
    hsv.a = base_color.a
    return hsv

func _apply_material_color_variation(base_color: Color, seed_base: float, amount: float = 0.7) -> Color:
    if base_color.a <= 0.0:
        return base_color
    var visual_seed := seed_base + _get_visual_style_seed_offset()
    var sat_scale := 1.0 + (_depth_noise(visual_seed, 1.17) - 0.5) * 0.07 * amount
    var val_scale := 1.0 + (_depth_noise(visual_seed, 2.93) - 0.5) * 0.09 * amount
    return Color.from_hsv(
        base_color.h,
        clampf(base_color.s * sat_scale, 0.0, 1.0),
        clampf(base_color.v * val_scale, 0.0, 1.0),
        base_color.a
    )

func _paint_image_variation_spot(image: Image, center: Vector2, radius_x: float, radius_y: float, angle: float, tint: Color) -> void:
    if image == null or radius_x <= 0.0 or radius_y <= 0.0 or tint.a <= 0.0:
        return
    var reach: int = int(ceil(maxf(radius_x, radius_y))) + 2
    var min_x: int = max(0, int(floor(center.x)) - reach)
    var max_x: int = min(image.get_width() - 1, int(ceil(center.x)) + reach)
    var min_y: int = max(0, int(floor(center.y)) - reach)
    var max_y: int = min(image.get_height() - 1, int(ceil(center.y)) + reach)
    var cos_angle: float = cos(angle)
    var sin_angle: float = sin(angle)

    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            var delta := Vector2(float(x) + 0.5 - center.x, float(y) + 0.5 - center.y)
            var local_x := delta.x * cos_angle + delta.y * sin_angle
            var local_y := -delta.x * sin_angle + delta.y * cos_angle
            var normalized_distance := pow(local_x / radius_x, 2.0) + pow(local_y / radius_y, 2.0)
            if normalized_distance > 1.0:
                continue
            var blend := tint.a * pow(1.0 - normalized_distance, 1.6)
            if blend <= 0.001:
                continue
            var current: Color = image.get_pixel(x, y)
            var shaded := current.lerp(Color(tint.r, tint.g, tint.b, current.a), blend)
            shaded.a = current.a
            image.set_pixel(x, y, shaded)

func _paint_image_variation_crack(image: Image, from_pos: Vector2, to_pos: Vector2, tint: Color, thickness: float) -> void:
    if image == null or tint.a <= 0.0:
        return
    var distance: float = from_pos.distance_to(to_pos)
    if distance <= 0.001:
        return
    var steps: int = max(1, int(ceil(distance / 1.2)))
    for step in range(steps + 1):
        var t: float = float(step) / float(steps)
        var pos: Vector2 = from_pos.lerp(to_pos, t)
        var radius: float = thickness * (0.82 + 0.18 * sin(t * PI))
        var min_x: int = max(0, int(floor(pos.x - radius - 1.0)))
        var max_x: int = min(image.get_width() - 1, int(ceil(pos.x + radius + 1.0)))
        var min_y: int = max(0, int(floor(pos.y - radius - 1.0)))
        var max_y: int = min(image.get_height() - 1, int(ceil(pos.y + radius + 1.0)))
        for y in range(min_y, max_y + 1):
            for x in range(min_x, max_x + 1):
                var pixel_delta := Vector2(float(x) + 0.5 - pos.x, float(y) + 0.5 - pos.y)
                var normalized_distance := pixel_delta.length() / maxf(radius, 0.001)
                if normalized_distance > 1.0:
                    continue
                var blend := tint.a * pow(1.0 - normalized_distance, 1.9)
                var current: Color = image.get_pixel(x, y)
                var shaded := current.lerp(Color(tint.r, tint.g, tint.b, current.a), blend)
                shaded.a = current.a
                image.set_pixel(x, y, shaded)

func _world_to_dirt_pixel(world_pos: Vector2) -> Vector2i:
    var world_size: Vector2 = _get_world_size()
    var x_ratio: float = clampf((world_pos.x + world_size.x * 0.5) / world_size.x, 0.0, 1.0)
    var y_ratio: float = clampf((world_pos.y + world_size.y * 0.5) / world_size.y, 0.0, 1.0)
    return Vector2i(
        int(round(x_ratio * float(dirt_image.get_width() - 1))),
        int(round(y_ratio * float(dirt_image.get_height() - 1)))
    )

func _carve_dirt_segment(from_pos: Vector2, to_pos: Vector2, radius: float) -> void:
    if dirt_image == null or dirt_texture == null:
        return
    var distance: float = from_pos.distance_to(to_pos)
    var steps: int = max(1, int(ceil(distance / max(radius * 0.45, 1.0))))
    for step in range(steps + 1):
        var t: float = float(step) / float(max(1, steps))
        _carve_dirt_circle(from_pos.lerp(to_pos, t), radius)

func _carve_dirt_circle(world_pos: Vector2, radius: float) -> void:
    if dirt_image == null or dirt_texture == null:
        return
    var pixel_center: Vector2i = _world_to_dirt_pixel(world_pos)
    var pixel_radius: int = int(round(radius * float(dirt_image.get_width()) / _get_world_size().x))
    var changed := false
    for x in range(pixel_center.x - pixel_radius, pixel_center.x + pixel_radius + 1):
        if x < 0 or x >= dirt_image.get_width():
            continue
        for y in range(pixel_center.y - pixel_radius, pixel_center.y + pixel_radius + 1):
            if y < 0 or y >= dirt_image.get_height():
                continue
            if Vector2(float(x - pixel_center.x), float(y - pixel_center.y)).length() > float(pixel_radius):
                continue
            if dirt_image.get_pixel(x, y).a <= 0.001:
                continue
            dirt_image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
            changed = true
    if changed:
        dirt_texture_dirty = true

func _refresh_dirt_visual_texture() -> void:
    if dirt_image == null:
        return
    var previous_mask: Image = dirt_image.duplicate()
    _initialize_dirt_mask()
    if previous_mask == null:
        return
    for y in range(min(dirt_image.get_height(), previous_mask.get_height())):
        for x in range(min(dirt_image.get_width(), previous_mask.get_width())):
            var rebuilt_pixel: Color = dirt_image.get_pixel(x, y)
            rebuilt_pixel.a = previous_mask.get_pixel(x, y).a
            dirt_image.set_pixel(x, y, rebuilt_pixel)
    dirt_texture.update(dirt_image)
    dirt_texture_dirty = false
    dirt_texture_flush_accumulator = 0.0

func _flush_dirt_texture_updates(delta: float) -> void:
    if not dirt_texture_dirty or dirt_texture == null or dirt_image == null:
        dirt_texture_flush_accumulator = 0.0
        return
    if OS.has_feature("web") and not _is_web_effect_enabled(WEB_EFFECT_FAST_DIRT_UPDATES):
        dirt_texture_flush_accumulator += delta
        if dirt_texture_flush_accumulator < 0.12:
            return
    dirt_texture_flush_accumulator = 0.0
    dirt_texture.update(dirt_image)
    dirt_texture_dirty = false

func _setup_system_controls() -> void:
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
    settings_button.focus_mode = Control.FOCUS_NONE
    settings_button.custom_minimum_size = Vector2(168.0, 88.0)
    settings_button.text = tr("UI_SETTINGS")
    settings_button.add_theme_font_size_override("font_size", 26)
    settings_button.z_index = 60
    settings_button.pressed.connect(_on_settings_button_pressed)
    _style_utility_button(settings_button)
    $CanvasLayer.add_child(settings_button)
    if _show_editor_variation_controls():
        variation_down_button = Button.new()
        variation_down_button.name = "VariationDownButton"
        variation_down_button.anchor_left = 1.0
        variation_down_button.anchor_top = 0.0
        variation_down_button.anchor_right = 1.0
        variation_down_button.anchor_bottom = 0.0
        variation_down_button.focus_mode = Control.FOCUS_NONE
        variation_down_button.custom_minimum_size = Vector2(80.0, 44.0)
        variation_down_button.text = tr("MINING_VAR_DOWN")
        variation_down_button.add_theme_font_size_override("font_size", 18)
        variation_down_button.z_index = 60

        variation_up_button = Button.new()
        variation_up_button.name = "VariationUpButton"
        variation_up_button.anchor_left = 1.0
        variation_up_button.anchor_top = 0.0
        variation_up_button.anchor_right = 1.0
        variation_up_button.anchor_bottom = 0.0
        variation_up_button.focus_mode = Control.FOCUS_NONE
        variation_up_button.custom_minimum_size = Vector2(80.0, 44.0)
        variation_up_button.text = tr("MINING_VAR_UP")
        variation_up_button.add_theme_font_size_override("font_size", 18)
        variation_up_button.z_index = 60

        variation_reroll_button = Button.new()
        variation_reroll_button.name = "VariationRerollButton"
        variation_reroll_button.anchor_left = 1.0
        variation_reroll_button.anchor_top = 0.0
        variation_reroll_button.anchor_right = 1.0
        variation_reroll_button.anchor_bottom = 0.0
        variation_reroll_button.focus_mode = Control.FOCUS_NONE
        variation_reroll_button.custom_minimum_size = Vector2(168.0, 44.0)
        variation_reroll_button.text = tr("MINING_REROLL")
        variation_reroll_button.add_theme_font_size_override("font_size", 18)
        variation_reroll_button.z_index = 60

        variation_down_button.pressed.connect(_on_variation_down_button_pressed)
        variation_up_button.pressed.connect(_on_variation_up_button_pressed)
        variation_reroll_button.pressed.connect(_on_variation_reroll_button_pressed)
        _style_utility_button(variation_down_button)
        _style_utility_button(variation_up_button)
        _style_utility_button(variation_reroll_button)
        $CanvasLayer.add_child(variation_down_button)
        $CanvasLayer.add_child(variation_up_button)
        $CanvasLayer.add_child(variation_reroll_button)
        _refresh_editor_variation_controls()
    _update_system_button_layout()

    settings_panel = PanelContainer.new()
    settings_panel.name = "MiningSettingsPanel"
    settings_panel.anchor_left = 0.0
    settings_panel.anchor_top = 0.0
    settings_panel.anchor_right = 1.0
    settings_panel.anchor_bottom = 1.0
    settings_panel.offset_left = 16.0
    settings_panel.offset_top = 16.0
    settings_panel.offset_right = -16.0
    settings_panel.offset_bottom = -16.0
    settings_panel.z_index = 80
    settings_panel.visible = false
    settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _style_utility_button_panel(settings_panel)
    $CanvasLayer.add_child(settings_panel)

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

    var settings_title_label: Label = Label.new()
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

    var end_run_button: Button = Button.new()
    end_run_button.name = "EndRunButton"
    end_run_button.text = tr("MINING_END_RUN")
    end_run_button.focus_mode = Control.FOCUS_NONE
    end_run_button.custom_minimum_size = Vector2(0.0, 120.0)
    end_run_button.add_theme_font_size_override("font_size", 30)
    end_run_button.pressed.connect(_on_settings_end_run_pressed)
    _style_utility_button(end_run_button)
    vbox.add_child(end_run_button)

    var close_button: Button = Button.new()
    close_button.name = "SettingsCloseButton"
    close_button.text = tr("UI_BACK")
    close_button.focus_mode = Control.FOCUS_NONE
    close_button.custom_minimum_size = Vector2(0.0, 150.0)
    close_button.add_theme_font_size_override("font_size", 34)
    close_button.pressed.connect(_on_settings_close_pressed)
    _style_utility_button(close_button)
    vbox.add_child(close_button)

func _update_system_button_layout() -> void:
    if settings_button == null or not is_instance_valid(settings_button):
        return
    settings_button.offset_top = 16.0
    settings_button.offset_bottom = 104.0
    if variation_down_button != null and is_instance_valid(variation_down_button):
        variation_down_button.offset_left = -184.0
        variation_down_button.offset_top = 268.0
        variation_down_button.offset_right = -104.0
        variation_down_button.offset_bottom = 316.0
    if variation_up_button != null and is_instance_valid(variation_up_button):
        variation_up_button.offset_left = -96.0
        variation_up_button.offset_top = 268.0
        variation_up_button.offset_right = -16.0
        variation_up_button.offset_bottom = 316.0
    if variation_reroll_button != null and is_instance_valid(variation_reroll_button):
        variation_reroll_button.offset_left = -184.0
        variation_reroll_button.offset_top = 320.0
        variation_reroll_button.offset_right = -16.0
        variation_reroll_button.offset_bottom = 368.0

func _update_status_panel_layout() -> void:
    if top_bar == null or not is_instance_valid(top_bar):
        return
    var viewport_height: float = get_viewport_rect().size.y
    var vertical_shift: float = viewport_height * STATUS_PANEL_VERTICAL_SHIFT_RATIO
    top_bar.scale = Vector2(STATUS_PANEL_SCALE, STATUS_PANEL_SCALE)
    top_bar.offset_top = 18.0 + vertical_shift
    top_bar.offset_bottom = 478.0 + vertical_shift

func _on_viewport_size_changed() -> void:
    _update_status_panel_layout()

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

func _show_editor_variation_controls() -> bool:
    return OS.has_feature("editor") or Engine.is_editor_hint()

func _handle_editor_variation_shortcut(event: InputEvent) -> bool:
    var key_event := event as InputEventKey
    if key_event == null or not key_event.pressed or key_event.echo:
        return false
    if key_event.keycode == KEY_R:
        _reroll_visual_style_variant()
        return true
    if key_event.keycode == KEY_MINUS or key_event.keycode == KEY_KP_SUBTRACT:
        _apply_visual_variation_strength_delta(-VISUAL_VARIATION_STRENGTH_STEP)
        return true
    if key_event.keycode == KEY_KP_ADD:
        _apply_visual_variation_strength_delta(VISUAL_VARIATION_STRENGTH_STEP)
        return true
    if key_event.keycode == KEY_EQUAL and key_event.shift_pressed:
        _apply_visual_variation_strength_delta(VISUAL_VARIATION_STRENGTH_STEP)
        return true
    return false

func _refresh_editor_variation_controls() -> void:
    if variation_down_button != null and is_instance_valid(variation_down_button):
        variation_down_button.tooltip_text = _trf("MINING_VAR_DOWN_TOOLTIP", [_get_effective_dot_variation_strength(), _get_effective_mineral_crack_variation_strength(), _get_effective_crack_variation_strength()])
    if variation_up_button != null and is_instance_valid(variation_up_button):
        variation_up_button.tooltip_text = _trf("MINING_VAR_UP_TOOLTIP", [_get_effective_dot_variation_strength(), _get_effective_mineral_crack_variation_strength(), _get_effective_crack_variation_strength()])
    if variation_reroll_button != null and is_instance_valid(variation_reroll_button):
        variation_reroll_button.tooltip_text = _trf("MINING_REROLL_TOOLTIP", [_get_effective_dot_variation_strength(), _get_effective_mineral_crack_variation_strength(), _get_effective_crack_variation_strength(), visual_style_reroll_index])

func _log_visual_variation_state() -> void:
    print(
        "Mining visual variation bias: %.2f | dot: %.2f | mineral crack: %.2f | bg crack: %.2f | reroll: %d" % [
            visual_variation_strength,
            _get_effective_dot_variation_strength(),
            _get_effective_mineral_crack_variation_strength(),
            _get_effective_crack_variation_strength(),
            visual_style_reroll_index
        ]
    )

func _apply_visual_variation_strength_delta(delta: float) -> void:
    var next_value := clampf(
        snappedf(visual_variation_strength + delta, 0.05),
        VISUAL_VARIATION_STRENGTH_MIN,
        VISUAL_VARIATION_STRENGTH_MAX
    )
    if is_equal_approx(next_value, visual_variation_strength):
        _log_visual_variation_state()
        return
    visual_variation_strength = next_value
    _refresh_editor_variation_controls()
    _refresh_dirt_visual_texture()
    queue_redraw()
    _log_visual_variation_state()

func _reroll_visual_style_variant() -> void:
    visual_style_reroll_index += 1
    last_background_noise_depth_level = -1
    _ensure_background_noise_texture()
    _refresh_dirt_visual_texture()
    _refresh_editor_variation_controls()
    queue_redraw()
    _log_visual_variation_state()

func _on_variation_down_button_pressed() -> void:
    _apply_visual_variation_strength_delta(-VISUAL_VARIATION_STRENGTH_STEP)

func _on_variation_up_button_pressed() -> void:
    _apply_visual_variation_strength_delta(VISUAL_VARIATION_STRENGTH_STEP)

func _on_variation_reroll_button_pressed() -> void:
    _reroll_visual_style_variant()

func _on_settings_button_pressed() -> void:
    _toggle_settings_panel()

func _on_settings_close_pressed() -> void:
    if settings_panel != null and is_instance_valid(settings_panel):
        settings_panel.hide()
    _refresh_mouse_capture_state()

func _on_settings_end_run_pressed() -> void:
    if run_state != RUN_STATES.RUNNING:
        return
    if settings_panel != null and is_instance_valid(settings_panel):
        settings_panel.hide()
    _refresh_mouse_capture_state()
    _finish_run("MINING_REASON_SETTINGS_ENDED")

func _toggle_settings_panel() -> void:
    if settings_panel == null:
        return
    settings_panel.visible = not settings_panel.visible
    if settings_panel.visible and settings_content != null:
        settings_content.show_screen()
        settings_content.refresh_from_save()
    _refresh_mouse_capture_state()

func _on_settings_updated() -> void:
    if settings_content != null:
        settings_content.refresh_from_save()
    _refresh_localized_text()

func _refresh_localized_text() -> void:
    if not _is_ui_ready():
        return
    if run_state == RUN_STATES.RUNNING:
        _refresh_hud()
    elif not last_run_results.is_empty():
        summary_stats_label.text = _build_summary_stats_text(last_run_results)
        dive_button.text = tr("MINING_SUMMARY_RETURN_UPGRADES")
        reset_button.text = tr("MINING_SUMMARY_RUN_AGAIN")
        _refresh_summary_hint()
        _refresh_summary_charts(last_run_results)
        _show_summary_text(last_run_results)
    if settings_button != null and is_instance_valid(settings_button):
        settings_button.text = tr("UI_SETTINGS")
    if variation_down_button != null and is_instance_valid(variation_down_button):
        variation_down_button.text = tr("MINING_VAR_DOWN")
    if variation_up_button != null and is_instance_valid(variation_up_button):
        variation_up_button.text = tr("MINING_VAR_UP")
    if variation_reroll_button != null and is_instance_valid(variation_reroll_button):
        variation_reroll_button.text = tr("MINING_REROLL")
    if settings_panel != null and is_instance_valid(settings_panel):
        var end_run_button: Button = settings_panel.get_node_or_null("MarginContainer/VBoxContainer/EndRunButton")
        if end_run_button != null:
            end_run_button.text = tr("MINING_END_RUN")
        var close_button: Button = settings_panel.get_node_or_null("MarginContainer/VBoxContainer/SettingsCloseButton")
        if close_button != null:
            close_button.text = tr("UI_BACK")
    _refresh_editor_variation_controls()

func _ensure_ui_refs() -> void:
    if wallet_label == null:
        wallet_label = get_node_or_null("%WalletLabel") as Label
    if phase_label == null:
        phase_label = get_node_or_null("%PhaseLabel") as Label
    if depth_label == null:
        depth_label = get_node_or_null("%DepthLabel") as Label
    if time_value_label == null:
        time_value_label = get_node_or_null("%TimeValueLabel") as Label
    if time_bar == null:
        time_bar = get_node_or_null("%TimeBar") as ProgressBar
    if drill_value_label == null:
        drill_value_label = get_node_or_null("%DrillValueLabel") as Label
    if drill_bar == null:
        drill_bar = get_node_or_null("%DrillBar") as ProgressBar
    if cargo_value_label == null:
        cargo_value_label = get_node_or_null("%CargoValueLabel") as Label
    if cargo_bar == null:
        cargo_bar = get_node_or_null("%CargoBar") as ProgressBar
    if xp_value_label == null:
        xp_value_label = get_node_or_null("%XpValueLabel") as Label
    if xp_bar == null:
        xp_bar = get_node_or_null("%XpBar") as ProgressBar
    if weapon_label == null:
        weapon_label = get_node_or_null("%WeaponLabel") as Label
    if boss_label == null:
        boss_label = get_node_or_null("%BossLabel") as Label
    if summary_stats_label == null:
        summary_stats_label = get_node_or_null("%SummaryStatsLabel") as Label
    if dive_button == null:
        dive_button = get_node_or_null("%DiveButton") as Button
    if reset_button == null:
        reset_button = get_node_or_null("%ResetButton") as Button

func _is_ui_ready() -> bool:
    _ensure_ui_refs()
    return is_node_ready() \
        and wallet_label != null \
        and phase_label != null \
        and depth_label != null \
        and time_value_label != null \
        and time_bar != null \
        and drill_value_label != null \
        and drill_bar != null \
        and cargo_value_label != null \
        and cargo_bar != null \
        and xp_value_label != null \
        and xp_bar != null \
        and weapon_label != null \
        and boss_label != null \
        and summary_stats_label != null \
        and dive_button != null \
        and reset_button != null

func _get_material_by_id(material_id: String) -> Dictionary:
    return MINING_BALANCE.get_material_by_id(material_id)

func _build_material_tiers() -> Array[Dictionary]:
    return MINING_BALANCE.get_material_tiers()
