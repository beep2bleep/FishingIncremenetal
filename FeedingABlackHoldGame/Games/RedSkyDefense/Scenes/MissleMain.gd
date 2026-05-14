extends Node2D
class_name MissleMain

const RED_SKY_DATA = preload("res://Games/RedSkyDefense/RedSkyData.gd")
const RED_SKY_PROGRESS = preload("res://Games/RedSkyDefense/RedSkyProgress.gd")
const RED_SKY_ICON_FACTORY = preload("res://Games/RedSkyDefense/RedSkyIconFactory.gd")
const CROSS_GAME_BONUSES = preload("res://CrossGameBonuses.gd")
const MULTI_GAME_MODE = preload("res://MultiGameMode.gd")
const MINING_CRT_OVERLAY_SCRIPT = preload("res://Games/Mining/UI/MiningCrtOverlay.gd")
const CRT_TEXT_MIRROR_OVERLAY_SCRIPT = preload("res://Core/CrtTextMirrorOverlay.gd")
const IN_GAME_PAUSE_MENU_SCRIPT = preload("res://Core/InGamePauseMenu.gd")
const RED_SKY_DEFEAT_SOUND = preload("res://Black Hole Game Over.mp3")

func _trf(text: String, args: Array = []) -> String:
    return tr(text) % args if not args.is_empty() else tr(text)

const SKY_TOP_COLOR := Color(0.22, 0.05, 0.06, 1.0)
const SKY_BOTTOM_COLOR := Color(0.66, 0.22, 0.13, 1.0)
const SKY_TOP_NIGHT_COLOR := Color(0.03, 0.03, 0.08, 1.0)
const SKY_BOTTOM_NIGHT_COLOR := Color(0.16, 0.05, 0.08, 1.0)
const GROUND_COLOR := Color(0.15, 0.09, 0.08, 1.0)
const GROUND_NIGHT_COLOR := Color(0.08, 0.07, 0.07, 1.0)
const BASE_COLOR := Color(0.86, 0.76, 0.62, 1.0)
const BASE_DARK_COLOR := Color(0.28, 0.2, 0.16, 1.0)
const PLAYER_BULLET_COLOR := Color(1.0, 0.93, 0.56, 1.0)
const PLAYER_CRIT_BULLET_COLOR := Color(1.0, 0.62, 0.26, 1.0)
const NUKE_COLOR := Color(0.99, 0.48, 0.3, 1.0)
const EXPLOSION_COLOR := Color(1.0, 0.69, 0.34, 0.42)
const ENEMY_PROJECTILE_COLOR := Color(0.96, 0.3, 0.24, 1.0)
const DEFLECTED_PROJECTILE_COLOR := Color(0.67, 0.94, 1.0, 1.0)
const SHIELD_COLOR := Color(0.38, 0.86, 1.0, 0.62)
const TOWER_COLOR := Color(0.78, 0.9, 1.0, 1.0)
const DRONE_COLOR := Color(0.64, 0.96, 0.98, 1.0)
const TENTACLE_COLOR := Color(0.8, 0.34, 0.36, 1.0)
const SALVAGE_COLOR := Color(0.96, 0.9, 0.54, 1.0)

const GROUND_HEIGHT := 124.0
const BASE_RADIUS := 58.0
const BASE_COLLISION_RADIUS := 76.0
const BULLET_RADIUS := 5.0
const NUKE_RADIUS := 9.0
const AIM_CURSOR_RADIUS := 12.0
const BULLET_LIFETIME := 2.1
const NUKE_SPEED := 720.0
const FLOATING_TEXT_DURATION := 0.85
const TEXT_FILTER_SCALE_STEP := 0.1
const SUPPORT_EFFECT_DURATION := 0.12
const RUN_START_BANNER_HOLD_DURATION := 1.45
const RUN_START_BANNER_FADE_DURATION := 0.26
const WAVE_INTRO_MOUSE_VISIBLE_MS := 500
const DEFEAT_SEQUENCE_DURATION := 1.35
const DEFEAT_EXPLOSION_INTERVAL := 0.09
const DEFEAT_OVERLAY_MAX_ALPHA := 0.46
const ENEMY_TYPE_ORDER := ["raider", "runner", "gunship", "bomber", "brute", "skimmer", "siege", "carrier", "dronelet", "interceptor", "artillery", "destroyer", "command_ship", "dreadnought"]
const SHOOTER_FORMATION_TYPES := ["gunship", "skimmer", "siege", "bomber", "interceptor", "artillery", "destroyer", "command_ship", "dreadnought"]
const SHOOTER_FORMATION_SPACING := 70.0
const SUMMARY_CHART_ANIM_MIN_DURATION := 0.75
const SUMMARY_CHART_ANIM_MAX_DURATION := 2.85
const SUMMARY_CHART_TICK_INTERVAL := 0.085
const SUMMARY_CHART_POP_SCALE := 1.08
const SUMMARY_TEXT_MONEY_BASE_FONT_SIZE := 22
const SUMMARY_TEXT_MONEY_POP_FONT_SIZE := 30
const MAX_UPGRADE_BUTTONS := 18
const START_WAVE_BUTTON_MAX_BEFORE_DROPDOWN := 3
const POWER_WHEEL_RADIUS := 132.0
const POWER_WHEEL_INPUT_SPEED := 2.05
const POWER_WHEEL_DISPLAY_MIN := 0.0
const POWER_WHEEL_FUNCTIONAL_MIN := 0.2
const POWER_WHEEL_MAX := 3.0
const GUN_FIXED_POWER_MULTIPLIER := 1.5
const POWER_WHEEL_WARP_GROUP: StringName = &"red_sky_power_wheel_warp"
const POWER_SLOT_KEYS: Array[String] = [
    "shields",
    "hull_regen",
    "nukes",
    "homing_missiles",
    "countermeasures",
    "towers",
    "helpers",
    "tentacles",
    "construction",
    "scrap_gain",
    "scrap_collection"
]
const BOSS_TYPE := "war_barge_boss"
## Body hits used to be 0.2× (weak spots 1×), making fights several minutes if not sniping weak points.
## Tuned so sustained gunfire (~meta baseline DPS) clears wave-10 boss in about one minute without requiring perfect weak hits.
const BOSS_BODY_DAMAGE_FRACTION := 0.5
const COUNTERMEASURE_MAX_CHARGES := 3
## Per second at power wheel multiplier 1.0; scales linearly with countermeasures wheel power.
## At max wheel (~3.0) overflow fires roughly every 3.5–4.5s so a full-bias build keeps pace with boss volleys without wave upgrades.
const COUNTERMEASURE_REGEN_COEFF := 0.088
const COUNTERMEASURE_SWEEP_VISUAL_DURATION := 0.54
const COUNTERMEASURE_SWEEP_LINE_WIDTH := 14.0
const PURPLE_SHOT_COUNTERMEASURE_DELAY := 4.0
const PENETRATOR_CM_IMMINENT_DIST := 98.0
const PENETRATOR_CM_IMMINENT_TIME := 0.2
const CONSTRUCTION_BUILD_TIME_BASE := 1.05
const CONSTRUCTION_FIELD_RADIUS_BASE := BASE_RADIUS + 148.0
const CONSTRUCTION_FIELD_LAYER_SPACING := 76.0
const CONSTRUCTION_FIELD_ANGLE_STEP := deg_to_rad(7.0)
const CONSTRUCTION_FIELD_MAX_ANGLE := deg_to_rad(45.0)
const CONSTRUCTION_SHIELD_ANGLE_SPREAD_MULT := 1.55
const CONSTRUCTION_TURRET_FORWARD_Y_RATIO := 0.5
const CONSTRUCTION_TURRET_ADVANCE_SPEED := 150.0
const CONSTRUCTION_SHIELD_SHIFT_SPEED := 118.0
const CONSTRUCTION_SHIELD_INTERCEPT_RADIUS := 190.0
const CONSTRUCTION_SHIELD_SHIFT_LIMIT := 28.0
const CONSTRUCTION_ATTACK_SHIP_RADIUS := 13.0
const CONSTRUCTION_ATTACK_SHIP_BODY_LENGTH := CONSTRUCTION_ATTACK_SHIP_RADIUS * 2.0
const CONSTRUCTION_ATTACK_SHIP_STANDOFF_MULT := 3.0
const CONSTRUCTION_ATTACK_SHIP_SPEED := 248.0
const CONSTRUCTION_ATTACK_SHIP_ORBIT_BLEND := 0.62
const CONSTRUCTION_TEMP_HIT_RADIUS_TURRET := 26.0
const CONSTRUCTION_TEMP_HIT_RADIUS_SHIELD := 30.0
const CONSTRUCTION_TURRET_FIXED_RANGE_MULT := 2.23
const CM_SWEEP_COLOR := Color(0.45, 0.95, 1.0, 0.92)
const SUMMARY_TEXT_BASE_COLOR := Color(0.88, 0.94, 1.0, 0.96)
const SUMMARY_TEXT_MONEY_GREY := Color(0.62, 0.68, 0.74, 1.0)
const SUMMARY_TEXT_MONEY_HIGH := Color(0.37, 0.86, 0.61, 1.0)
const SUMMARY_PANEL_BG := Color(0.04, 0.06, 0.1, 0.97)
const SUMMARY_PANEL_BORDER := Color(0.88, 0.92, 1.0, 0.95)
const SUMMARY_CHART_PANEL_BG := Color(0.05, 0.09, 0.16, 0.94)
const SUMMARY_CHART_PANEL_BORDER := Color(0.31, 0.63, 0.89, 0.9)
const SUMMARY_METER_TRACK := Color(0.12, 0.18, 0.28, 0.96)
const SUMMARY_CHART_TITLE_COLOR := Color(0.76, 0.9, 1.0, 1.0)
const SUMMARY_CHART_MUTED_COLOR := Color(0.82, 0.88, 0.96, 0.92)
const SUMMARY_CHART_VALUE_COLOR := Color(0.82, 0.9, 1.0, 1.0)
const UPGRADE_PANEL_MARGIN := Vector2(22.0, 22.0)
const UPGRADE_PANEL_MARGIN_RATIO := Vector2(0.05, 0.06)
const UPGRADE_PANEL_MAX_SIZE := Vector2(1040.0, 700.0)

enum RUN_STATES {RUNNING, UPGRADE, DEFEAT, SUMMARY}

@onready var mode_label: Label = $CanvasLayer/HudMargin/HudPanel/HudMargin/HudVBox/ModeLabel
@onready var wave_label: Label = $CanvasLayer/HudMargin/HudPanel/HudMargin/HudVBox/WaveLabel
@onready var health_label: Label = $CanvasLayer/HudMargin/HudPanel/HudMargin/HudVBox/HealthLabel
@onready var score_label: Label = $CanvasLayer/HudMargin/HudPanel/HudMargin/HudVBox/ScoreLabel
@onready var nukes_label: Label = $CanvasLayer/HudMargin/HudPanel/HudMargin/HudVBox/NukesLabel
@onready var status_label: Label = $CanvasLayer/HudMargin/HudPanel/HudMargin/HudVBox/StatusLabel
@onready var upgrade_panel: PanelContainer = $OverlayCanvasLayer/UpgradePanel
@onready var upgrade_title_label: Label = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeTitleLabel
@onready var upgrade_desc_label: Label = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeDescLabel
@onready var upgrade_buttons_scroll: ScrollContainer = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeButtonsScroll
@onready var upgrade_buttons_grid: GridContainer = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeButtonsScroll/UpgradeButtons
@onready var damage_button: Button = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeButtonsScroll/UpgradeButtons/DamageButton
@onready var speed_button: Button = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeButtonsScroll/UpgradeButtons/SpeedButton
@onready var health_button: Button = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeButtonsScroll/UpgradeButtons/HealthButton
@onready var choice_button_4: Button = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeButtonsScroll/UpgradeButtons/ChoiceButton4
@onready var choice_button_5: Button = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeButtonsScroll/UpgradeButtons/ChoiceButton5
@onready var choice_button_6: Button = $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox/UpgradeButtonsScroll/UpgradeButtons/ChoiceButton6
@onready var summary_panel: PanelContainer = $OverlayCanvasLayer/SummaryPanel
@onready var summary_vbox: VBoxContainer = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox
@onready var summary_title_label: Label = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryTitleLabel
@onready var summary_label: RichTextLabel = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryLabel
@onready var summary_charts_row: HBoxContainer = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryChartsRow
@onready var summary_payout_chart: PanelContainer = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryChartsRow/SummaryPayoutChart
@onready var summary_combat_chart: PanelContainer = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryChartsRow/SummaryCombatChart
@onready var summary_damage_chart: PanelContainer = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryDamageChart
@onready var summary_stats_label: Label = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryStatsLabel
@onready var start_wave_section: VBoxContainer = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/StartWaveSection
@onready var start_wave_header_label: Label = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/StartWaveSection/StartWaveHeaderLabel
@onready var start_wave_info_label: Label = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/StartWaveSection/StartWaveInfoLabel
@onready var start_wave_buttons_grid: GridContainer = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/StartWaveSection/StartWaveButtons
@onready var start_wave_dropdown: OptionButton = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/StartWaveSection/StartWaveDropdown
@onready var continue_button: Button = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryButtons/ContinueButton
@onready var retry_button: Button = $OverlayCanvasLayer/SummaryPanel/SummaryMargin/SummaryVBox/SummaryButtons/RetryButton

var run_start_banner_panel: PanelContainer
var run_start_banner_title_label: Label
var run_start_banner_detail_label: Label
var run_start_banner_tween: Tween
var defeat_sound_player: AudioStreamPlayer
var pause_menu

var rng := RandomNumberGenerator.new()
var persistent_data: Dictionary = {}
var meta_bonuses: Dictionary = {}
var last_run_results: Dictionary = {}
var run_state: int = RUN_STATES.RUNNING
var aim_cursor_screen_pos := Vector2.ZERO
var combat_text_scale := 1.9
var text_node_base_sizes: Dictionary = {}
var environment_darkness := 0.0
var sun_progress := 0.0
var support_time := 0.0

var selected_start_wave := 1
var run_start_wave := 1
var pending_start_upgrade_picks := 0
var used_start_upgrade_picks := 0
var showing_pre_run_panel := false
var career_best_wave_at_run_start := 0
var _suppress_mouse_capture_until_msec: int = 0
var multi_mode_step: Dictionary = {}
var multi_mode_intro_timer := 0.0
var multi_mode_intro_overlay: ColorRect
var multi_mode_intro_countdown_label: Label
var multi_mode_intro_note_label: Label
var multi_mode_step_reported := false
var open_pit_defense_step: Dictionary = {}
var open_pit_defense_progress_snapshot: Dictionary = {}

var current_wave := 1
var waves_cleared := 0
var wave_spawn_queue: Array[Dictionary] = []
var wave_spawn_timer := 0.0
var boss_wave_stream_timer := 0.0
var boss_wave_stream_interval := 0.0
var boss_wave_stream_types: Array[String] = []
var boss_wave_stream_pick_index := 0
var boss_wave_stream_spawn_seq := 0
var offered_wave_upgrades: Array[Dictionary] = []
var wave_upgrade_levels: Dictionary = {}

var base_max_health := 0.0
var base_health := 0.0
var shield_max := 0.0
var shield_health := 0.0
var shield_regen_rate := 0.0
var shield_regen_delay := 2.6
var shield_regen_cooldown := 0.0
var damage_reduction := 0.0
var gun_damage := 0.0
var bullet_speed := 0.0
var fire_interval := 0.17
var fire_timer := 0.0
var crit_chance := 0.04
var crit_bonus := 1.65
var bullet_pierce := 0
var bullet_blast_radius := 0.0
var bullet_blast_damage_scale := 1.0
var pickup_radius := 28.0
var salvage_multiplier := 1.0
var salvage_lifetime := 7.4
var meta_reward_multiplier := 1.0
var wave_scrap_bonus := 0.0
var wave_auto_bank_ratio := 0.68
var level_up_choice_count := 3
var enemy_count_scale := 1.0
var enemy_speed_scale := 1.0
var enemy_projectile_speed_scale := 1.0
var enemy_projectile_damage_scale := 1.0
var elite_spawn_scale := 1.0
var heavy_enemy_health_scale := 1.0
var heavy_enemy_damage_scale := 1.0
var apex_enemy_health_scale := 1.0
var apex_enemy_damage_scale := 1.0
var remaining_nukes := 0
var nuke_max := 5
var nuke_regen_per_wave := 1
var nuke_regen_bank := 0.0
var last_started_wave := -1
var nuke_damage := 128.0
var nuke_blast_radius := 292.0
var repair_between_waves := 0.0
var homing_missile_level := 0
var homing_shot_cycle := 0
var countermeasures_rating := 0.2
var countermeasure_charges := 0
var countermeasure_regen_bank := 0.0
var countermeasure_sweep_visuals: Array[Dictionary] = []
var countermeasure_sweep_cooldown := 0.0
var purple_shot_countermeasure_timers: Array[float] = []
var saw_purple_shots_this_run := false
var countermeasures_hud_label: Label
var projectile_redirect_chance := 0.0
var upgrade_power_multiplier := 1.0

var tower_count := 0
var tower_damage := 15.0
var tower_range := 270.0
var tower_fire_interval := 1.18
var drone_count := 0
var drone_damage := 13.0
var drone_range := 210.0
var drone_fire_interval := 0.88
var drone_speed := 182.0
var tentacle_count := 0
var tentacle_damage := 19.0
var tentacle_range := 168.0
var tentacle_attack_cooldown := 1.05
var tentacle_slow := 0.18
var construction_drone_count := 0
var construction_build_rate := 1.0
var temporary_turret_limit := 0
var temporary_turret_damage := 11.0
var temporary_turret_range := 210.0
var temporary_turret_fire_interval := 1.05
var temporary_turret_duration := 16.0
var temporary_turret_health := 58.0
var temporary_shield_limit := 0
var temporary_shield_capacity := 54.0
var temporary_shield_regen := 4.0
var temporary_shield_duration := 16.0
var temporary_shield_health := 54.0
var helper_drone_count := 0
var helper_drone_damage := 10.0
var helper_drone_range := 260.0
var helper_drone_fire_interval := 0.76
var helper_drone_speed := 224.0
var collector_bot_count := 0
var collector_bot_speed := 176.0
var scrap_generation_per_second := 0.0
var scrap_generation_accumulator := 0.0
var max_level_up_choice_count := 9
var max_wave_upgrade_choices := MAX_UPGRADE_BUTTONS

var score := 0
var damage_dealt := 0.0
var damage_taken := 0.0
var shield_damage_absorbed := 0.0
var damage_dealt_gun := 0.0
var damage_dealt_tower := 0.0
var damage_dealt_drone := 0.0
var damage_dealt_tentacle := 0.0
var damage_dealt_nuke := 0.0
var damage_dealt_blast := 0.0
var damage_dealt_deflection := 0.0
var hull_damage_mitigated := 0.0
var intercepted_enemy_shot_damage := 0.0
var deflected_threat_damage := 0.0
var nukes_launched := 0
var enemy_projectiles_destroyed := 0
var enemy_projectiles_deflected := 0
var escape_scores := 0
var shots_fired := 0
var total_kills := 0
var tower_kills := 0
var drone_kills := 0
var tentacle_kills := 0
var salvage_collected := 0
var salvage_lost := 0
var bonus_scrap_earned := 0

var enemy_kill_counts := {
    "raider": 0,
    "runner": 0,
    "gunship": 0,
    "bomber": 0,
    "brute": 0,
    "skimmer": 0,
    "siege": 0,
    "carrier": 0,
    "dronelet": 0,
    "interceptor": 0,
    "artillery": 0,
    "destroyer": 0,
    "command_ship": 0,
    "dreadnought": 0,
    BOSS_TYPE: 0
}

var player_bullets: Array[Dictionary] = []
var nukes: Array[Dictionary] = []
var explosions: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var enemy_projectiles: Array[Dictionary] = []
var floating_texts: Array[Dictionary] = []
var salvage_pickups: Array[Dictionary] = []
var support_effects: Array[Dictionary] = []
var tower_fire_timers: Array = []
var drone_fire_timers: Array = []
var tentacle_cooldowns: Array = []
var helper_fire_timers: Array = []
var temporary_turrets: Array[Dictionary] = []
var temporary_shields: Array[Dictionary] = []
var upgrade_buttons: Array[Button] = []
var start_wave_buttons: Array[Button] = []
var power_slot_order: Array[String] = POWER_SLOT_KEYS.duplicate()
var power_bias := Vector2.ZERO
var power_multipliers: Dictionary = {}
var power_display_values: Dictionary = {}
var power_customize_panel: PanelContainer
var power_wheel_label: Label
var power_warning_label: Label
var power_customize_button: Button
var power_customize_info_label: Label
var power_customize_selection_label: Label
var power_slot_buttons: Array[Button] = []
var power_warp_text_overlay: CrtTextMirrorOverlay
var gameplay_crt_overlay: MiningCrtOverlay
var boss_warning_label: Label
var boss_warning_tween: Tween
var power_swap_source_slot := -1
var defeat_sequence_timer := 0.0
var defeat_explosion_timer := 0.0
var pending_finish_reason := ""

var summary_chart_animation_active := false
var summary_chart_animation_entries: Array[Dictionary] = []
var summary_chart_animation_session_id := 0
var summary_chart_tick_timer := 0.0
var summary_hints: Array[String] = []
var summary_hint_index := 0
var summary_hint_panel: PanelContainer
var summary_hint_title_label: Label
var summary_hint_label: Label
var summary_hint_left_button: Button
var summary_hint_right_button: Button
var summary_text_tween: Tween
var summary_text_pop_tween: Tween
var summary_text_view_model: Dictionary = {}
var summary_text_progress := 0.0
var summary_text_money_pop_progress := 0.0

const SUMMARY_POINTER_RECOVERY_FRAMES := 3
var _summary_pointer_recovery_frames_remaining := 0

func _ready() -> void:
    rng.randomize()
    multi_mode_step = MULTI_GAME_MODE.get_active_step_for_game(Util.ACTIVE_GAME_RED_SKY)
    open_pit_defense_step = _get_open_pit_defense_step()
    if not open_pit_defense_step.is_empty():
        open_pit_defense_progress_snapshot = RED_SKY_PROGRESS.load_data().duplicate(true)
    if multi_mode_step.is_empty() and not open_pit_defense_step.is_empty():
        multi_mode_step = open_pit_defense_step.duplicate(true)
    multi_mode_step_reported = false
    if ControllerIcons != null and not ControllerIcons.input_type_changed.is_connected(_on_controller_icons_input_type_changed):
        ControllerIcons.input_type_changed.connect(_on_controller_icons_input_type_changed)
    _sync_virtual_cursor_for_red_sky_ui()
    persistent_data = RED_SKY_PROGRESS.load_data()
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    _ensure_crt_overlay()
    _setup_boss_warning_ui()
    _connect_ui()
    _setup_pause_menu()
    _ensure_upgrade_button_pool()
    _setup_countermeasures_hud_label()
    _setup_text_presentation()
    _setup_power_wheel_ui()
    _ensure_power_wheel_text_overlay()
    _setup_run_start_banner()
    _setup_defeat_audio()
    _setup_summary_hint_ui()
    _apply_summary_theme()
    _refresh_upgrade_panel_layout()
    _setup_multi_mode_overlay()
    if _is_multi_mode_challenge_active():
        _begin_run()
    else:
        _show_pre_run_panel()

func _setup_multi_mode_overlay() -> void:
    if multi_mode_step.is_empty():
        return
    multi_mode_intro_timer = 2.0
    multi_mode_intro_overlay = ColorRect.new()
    multi_mode_intro_overlay.anchor_right = 1.0
    multi_mode_intro_overlay.anchor_bottom = 1.0
    multi_mode_intro_overlay.color = Color(0.0, 0.0, 0.0, 0.28)
    multi_mode_intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(multi_mode_intro_overlay)
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
    if str(challenge.get("game_id", "")) != Util.ACTIVE_GAME_RED_SKY:
        return {}
    return challenge.duplicate(true)

func _apply_open_pit_fixed_meta_bonuses() -> void:
    if not _is_open_pit_defense_challenge_active():
        return
    var fixed_config: Dictionary = RED_SKY_DATA.get_base_run_config()
    var fixed_overrides: Dictionary = open_pit_defense_step.get("fixed_meta_bonuses", {})
    fixed_config.merge(fixed_overrides, true)
    meta_bonuses = fixed_config
    for key_variant in fixed_config.keys():
        var key := str(key_variant)
        meta_bonuses[key] = fixed_config.get(key)

func _complete_open_pit_defense_challenge(success: bool, payload: Dictionary) -> void:
    var result := open_pit_defense_step.duplicate(true)
    result["success"] = success
    result["payload"] = payload.duplicate(true)
    Global.open_pit_defense_result = result
    Global.open_pit_defense_challenge = {}
    _restore_open_pit_defense_progress_snapshot()
    Util.set_active_game_id(Util.ACTIVE_GAME_OPEN_PIT)
    Util.set_high_level_mode_id(Util.HIGH_LEVEL_MODE_ALL)
    Global.start_in_upgrade_scene = false
    Global.load_saved_run = true
    SceneChanger.change_to_new_scene(Util.PATH_OPEN_PIT_MAIN, null, 0.2)

func _restore_open_pit_defense_progress_snapshot() -> void:
    if open_pit_defense_progress_snapshot.is_empty():
        return
    RED_SKY_PROGRESS.save_data(open_pit_defense_progress_snapshot.duplicate(true))
    persistent_data = open_pit_defense_progress_snapshot.duplicate(true)
    open_pit_defense_progress_snapshot.clear()

func _update_multi_mode_overlay() -> void:
    if multi_mode_intro_countdown_label == null:
        return
    multi_mode_intro_countdown_label.text = str(maxi(1, int(ceil(multi_mode_intro_timer))))

func _process_multi_mode_intro(delta: float) -> bool:
    if not _is_multi_mode_challenge_active() or multi_mode_intro_timer <= 0.0:
        return false
    multi_mode_intro_timer = maxf(0.0, multi_mode_intro_timer - delta)
    _update_multi_mode_overlay()
    if multi_mode_intro_timer <= 0.0:
        if multi_mode_intro_overlay != null:
            multi_mode_intro_overlay.queue_free()
            multi_mode_intro_overlay = null
        if showing_pre_run_panel:
            _begin_run()
    return multi_mode_intro_timer > 0.0

func _exit_tree() -> void:
    if power_warp_text_overlay != null and is_instance_valid(power_warp_text_overlay):
        power_warp_text_overlay.restore_source_text_colors()
    if ControllerIcons != null and ControllerIcons.input_type_changed.is_connected(_on_controller_icons_input_type_changed):
        ControllerIcons.input_type_changed.disconnect(_on_controller_icons_input_type_changed)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_controller_icons_input_type_changed(_input_type: ControllerIcons.InputType, _controller: int) -> void:
    _sync_virtual_cursor_for_red_sky_ui()
    _refresh_mouse_capture_state()

func _sync_virtual_cursor_for_red_sky_ui() -> void:
    if VirtualCursor == null:
        return
    var use_virtual_cursor := ControllerIcons != null \
        and ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER
    VirtualCursor.set_scene_enabled(use_virtual_cursor)

func _connect_ui() -> void:
    upgrade_buttons = [
        damage_button,
        speed_button,
        health_button,
        choice_button_4,
        choice_button_5,
        choice_button_6
    ]
    for button_index in range(upgrade_buttons.size()):
        var button: Button = upgrade_buttons[button_index]
        button.pressed.connect(_on_wave_upgrade_button_pressed.bind(button_index))
        button.custom_minimum_size = Vector2(0.0, 96.0)
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
        button.clip_text = false
        button.expand_icon = false
        button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
        button.add_theme_font_size_override("font_size", 18)
    mode_label.hide()
    status_label.hide()
    start_wave_header_label.add_theme_font_size_override("font_size", 24)
    start_wave_info_label.add_theme_font_size_override("font_size", 18)
    continue_button.pressed.connect(_on_continue_pressed)
    retry_button.pressed.connect(_on_retry_pressed)
    if start_wave_dropdown != null and not start_wave_dropdown.item_selected.is_connected(_on_start_wave_dropdown_selected):
        start_wave_dropdown.item_selected.connect(_on_start_wave_dropdown_selected)

func _ensure_upgrade_button_pool() -> void:
    var current_count: int = upgrade_buttons.size()
    while current_count < MAX_UPGRADE_BUTTONS:
        var button := Button.new()
        button.name = "ExtraChoiceButton%d" % (current_count + 1)
        button.custom_minimum_size = Vector2(0.0, 96.0)
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
        button.clip_text = false
        button.expand_icon = false
        button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
        button.add_theme_font_size_override("font_size", 18)
        button.pressed.connect(_on_wave_upgrade_button_pressed.bind(current_count))
        upgrade_buttons_grid.add_child(button)
        upgrade_buttons.append(button)
        current_count += 1

func _setup_countermeasures_hud_label() -> void:
    if countermeasures_hud_label != null:
        return
    var hud_root: VBoxContainer = $CanvasLayer/HudMargin/HudPanel/HudMargin/HudVBox as VBoxContainer
    if hud_root == null:
        return
    countermeasures_hud_label = Label.new()
    countermeasures_hud_label.name = "CountermeasuresLabel"
    countermeasures_hud_label.text = "CM 0/3"
    countermeasures_hud_label.add_theme_font_size_override("font_size", 18)
    hud_root.add_child(countermeasures_hud_label)
    if nukes_label != null:
        hud_root.move_child(countermeasures_hud_label, nukes_label.get_index() + 1)

func _setup_power_wheel_ui() -> void:
    var hud_root := $CanvasLayer/HudMargin/HudPanel/HudMargin/HudVBox
    if hud_root == null:
        return
    power_wheel_label = Label.new()
    power_wheel_label.name = "PowerWheelLabel"
    power_wheel_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    power_wheel_label.add_theme_font_size_override("font_size", 16)
    power_wheel_label.add_to_group(POWER_WHEEL_WARP_GROUP)
    hud_root.add_child(power_wheel_label)
    power_warning_label = Label.new()
    power_warning_label.name = "PowerWarningLabel"
    power_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    power_warning_label.add_theme_font_size_override("font_size", 15)
    power_warning_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.44, 1.0))
    power_warning_label.add_to_group(POWER_WHEEL_WARP_GROUP)
    hud_root.add_child(power_warning_label)

    power_customize_button = Button.new()
    power_customize_button.name = "CustomizePowerWheelButton"
    power_customize_button.text = tr("Customize Power Wheel")
    power_customize_button.pressed.connect(_toggle_power_customize_panel)
    power_customize_button.visible = false
    power_customize_button.add_to_group(POWER_WHEEL_WARP_GROUP)
    $OverlayCanvasLayer/UpgradePanel/UpgradeMargin/UpgradeVBox.add_child(power_customize_button)

    power_customize_panel = PanelContainer.new()
    power_customize_panel.name = "PowerCustomizePanel"
    power_customize_panel.visible = false
    power_customize_panel.anchor_left = 0.5
    power_customize_panel.anchor_top = 0.5
    power_customize_panel.anchor_right = 0.5
    power_customize_panel.anchor_bottom = 0.5
    power_customize_panel.offset_left = -280.0
    power_customize_panel.offset_top = -240.0
    power_customize_panel.offset_right = 280.0
    power_customize_panel.offset_bottom = 240.0
    power_customize_panel.add_to_group(POWER_WHEEL_WARP_GROUP)
    $OverlayCanvasLayer.add_child(power_customize_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 16)
    margin.add_theme_constant_override("margin_top", 16)
    margin.add_theme_constant_override("margin_right", 16)
    margin.add_theme_constant_override("margin_bottom", 16)
    power_customize_panel.add_child(margin)
    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 8)
    margin.add_child(vbox)
    var title := Label.new()
    title.text = tr("Power Wheel Layout")
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 26)
    vbox.add_child(title)
    power_customize_info_label = Label.new()
    power_customize_info_label.text = tr("Pick one slot, then pick a second slot to swap their positions on the wheel.")
    power_customize_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    power_customize_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(power_customize_info_label)
    power_customize_selection_label = Label.new()
    power_customize_selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    power_customize_selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    power_customize_selection_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.52, 1.0))
    vbox.add_child(power_customize_selection_label)
    var grid := GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    vbox.add_child(grid)
    for slot_index in range(POWER_SLOT_KEYS.size()):
        var slot_button := Button.new()
        slot_button.custom_minimum_size = Vector2(0.0, 54.0)
        slot_button.pressed.connect(_on_power_slot_button_pressed.bind(slot_index))
        grid.add_child(slot_button)
        power_slot_buttons.append(slot_button)
    var close_button := Button.new()
    close_button.text = tr("Close")
    close_button.pressed.connect(_toggle_power_customize_panel)
    vbox.add_child(close_button)
    _recalculate_power_distribution()
    _refresh_power_slot_buttons()

func _ensure_power_wheel_text_overlay() -> void:
    if power_warp_text_overlay != null and is_instance_valid(power_warp_text_overlay):
        power_warp_text_overlay.restore_source_text_colors()
        power_warp_text_overlay.visible = false

func _on_viewport_size_changed() -> void:
    _refresh_upgrade_panel_layout(offered_wave_upgrades.size())

func _setup_pause_menu() -> void:
    pause_menu = IN_GAME_PAUSE_MENU_SCRIPT.new()
    pause_menu.name = "InGamePauseMenu"
    pause_menu.resume_requested.connect(_on_pause_resume_requested)
    pause_menu.end_run_requested.connect(_on_pause_end_run_requested)
    add_child(pause_menu)

func _ensure_crt_overlay() -> void:
    var text_mirror_overlay := get_node_or_null("RedSkyTextMirrorOverlay") as CrtTextMirrorOverlay
    if text_mirror_overlay != null:
        text_mirror_overlay.restore_source_text_colors()
        text_mirror_overlay.visible = false
    var overlay := get_node_or_null("MiningCrtOverlay") as MiningCrtOverlay
    if overlay == null:
        overlay = MINING_CRT_OVERLAY_SCRIPT.new()
        overlay.name = "MiningCrtOverlay"
        add_child(overlay)
        move_child(overlay, 0)
    overlay.configure(6)
    overlay.visible = true
    gameplay_crt_overlay = overlay

func _setup_boss_warning_ui() -> void:
    if boss_warning_label != null:
        return
    boss_warning_label = Label.new()
    boss_warning_label.name = "BossWarningLabel"
    boss_warning_label.visible = false
    boss_warning_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    boss_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    boss_warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    boss_warning_label.set_anchors_preset(Control.PRESET_FULL_RECT)
    boss_warning_label.offset_left = 0.0
    boss_warning_label.offset_top = 0.0
    boss_warning_label.offset_right = 0.0
    boss_warning_label.offset_bottom = 0.0
    boss_warning_label.add_theme_font_size_override("font_size", 54)
    boss_warning_label.add_theme_color_override("font_color", Color(1.0, 0.12, 0.08, 1.0))
    boss_warning_label.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.0, 0.94))
    boss_warning_label.add_theme_constant_override("outline_size", 10)
    $OverlayCanvasLayer.add_child(boss_warning_label)
    boss_warning_label.z_index = 80

func _is_boss_wave(wave: int) -> bool:
    return wave >= 5 and wave % 5 == 0

func _estimate_typical_wave_duration_seconds() -> float:
    var w: float = maxf(1.0, float(current_wave))
    return clampf(14.0 + w * 2.35 + pow(w, 0.92) * 1.05, 18.0, 130.0)

func _show_boss_warning_flash(wave: int) -> void:
    if boss_warning_label == null:
        return
    if boss_warning_tween != null and boss_warning_tween.is_running():
        boss_warning_tween.kill()
    boss_warning_label.text = _trf("WARNING\nCLASS-A CONTACT\nWAVE %d", [wave])
    boss_warning_label.visible = true
    boss_warning_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
    boss_warning_label.scale = Vector2(1.08, 1.08)
    boss_warning_tween = create_tween()
    boss_warning_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    boss_warning_tween.tween_property(boss_warning_label, "modulate:a", 1.0, 0.12)
    boss_warning_tween.parallel().tween_property(boss_warning_label, "scale", Vector2.ONE, 0.18)
    boss_warning_tween.tween_interval(1.55)
    boss_warning_tween.tween_property(boss_warning_label, "modulate:a", 0.0, 0.35)
    boss_warning_tween.finished.connect(func() -> void:
        if boss_warning_label != null:
            boss_warning_label.visible = false
    , CONNECT_ONE_SHOT)
    _play_red_sky_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.RED_SKY_BOSS_WARNING, -1.0, rng.randf_range(-0.06, 0.04))

func _setup_text_presentation() -> void:
    var text_controls: Array[Control] = [
        wave_label, health_label, score_label, nukes_label
    ]
    if countermeasures_hud_label != null:
        text_controls.append(countermeasures_hud_label)
    for control in text_controls:
        if control == null:
            continue
        var base_size: int = control.get_theme_font_size("font_size")
        if base_size <= 0:
            base_size = 18
        text_node_base_sizes[control.get_instance_id()] = base_size
    _apply_text_filter_scale()

func _apply_text_filter_scale() -> void:
    for control_id_variant in text_node_base_sizes.keys():
        var control_id: int = int(control_id_variant)
        var control := instance_from_id(control_id) as Control
        if control == null or not is_instance_valid(control):
            continue
        var base_size: int = int(text_node_base_sizes[control_id])
        control.add_theme_font_size_override("font_size", maxi(14, int(round(float(base_size) * combat_text_scale))))

func _setup_run_start_banner() -> void:
    if run_start_banner_panel != null:
        return
    var canvas_layer := get_node_or_null("OverlayCanvasLayer") as CanvasLayer
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
    accent_line.color = Color(0.99, 0.5, 0.26, 0.95)
    vbox.add_child(accent_line)

    run_start_banner_title_label = Label.new()
    run_start_banner_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    run_start_banner_title_label.add_theme_font_size_override("font_size", 28)
    run_start_banner_title_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.82, 1.0))
    vbox.add_child(run_start_banner_title_label)

    run_start_banner_detail_label = Label.new()
    run_start_banner_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    run_start_banner_detail_label.add_theme_font_size_override("font_size", 18)
    run_start_banner_detail_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.7, 0.96))
    vbox.add_child(run_start_banner_detail_label)

func _show_run_start_banner() -> void:
    if run_start_banner_panel == null or run_start_banner_title_label == null or run_start_banner_detail_label == null:
        return
    if run_start_banner_tween != null and run_start_banner_tween.is_running():
        run_start_banner_tween.kill()

    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.11, 0.03, 0.04, 0.93)
    style.border_color = Color(0.96, 0.44, 0.25, 0.96)
    style.set_border_width_all(2)
    style.corner_radius_top_left = 7
    style.corner_radius_top_right = 7
    style.corner_radius_bottom_left = 7
    style.corner_radius_bottom_right = 7
    style.shadow_size = 10
    style.shadow_color = Color(0.0, 0.0, 0.0, 0.32)
    run_start_banner_panel.add_theme_stylebox_override("panel", style)

    var run_number: int = int(persistent_data.get("runs", 0)) + 1
    var wallet: int = int(persistent_data.get("wallet", 0))
    var best_wave: int = int(persistent_data.get("best_wave", 0))
    run_start_banner_title_label.text = _trf("RED SKY DEFENSE  |  WAVE %02d ALERT", [current_wave])
    var detail: String = _trf("Run %02d   |   Scrap reserve %d   |   Best wave %d   |   Start wave %d", [run_number, wallet, best_wave, run_start_wave])
    if int(persistent_data.get("runs", 0)) == 0:
        detail += "\n" + tr("First deployment - stay sharp, Commander.")
    var hint_lines: Array[String] = _get_run_start_hint_lines()
    if not hint_lines.is_empty():
        detail += "\n" + "\n".join(hint_lines)
    run_start_banner_detail_label.text = detail

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
        _refresh_mouse_capture_state()
    )

func _setup_summary_hint_ui() -> void:
    if summary_vbox == null or summary_hint_panel != null:
        return
    summary_hint_panel = PanelContainer.new()
    summary_hint_panel.name = "SummaryHintPanel"
    summary_hint_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    summary_vbox.add_child(summary_hint_panel)
    if start_wave_section != null:
        summary_vbox.move_child(summary_hint_panel, start_wave_section.get_index())

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 8)
    margin.add_theme_constant_override("margin_top", 4)
    margin.add_theme_constant_override("margin_right", 8)
    margin.add_theme_constant_override("margin_bottom", 4)
    summary_hint_panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 3)
    margin.add_child(vbox)

    summary_hint_title_label = Label.new()
    summary_hint_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(summary_hint_title_label)

    summary_hint_label = Label.new()
    summary_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    summary_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    summary_hint_label.custom_minimum_size = Vector2(0.0, 0.0)
    vbox.add_child(summary_hint_label)

    var nav_row := HBoxContainer.new()
    nav_row.alignment = BoxContainer.ALIGNMENT_CENTER
    nav_row.add_theme_constant_override("separation", 6)
    vbox.add_child(nav_row)

    summary_hint_left_button = Button.new()
    summary_hint_left_button.text = "<"
    summary_hint_left_button.custom_minimum_size = Vector2(36.0, 26.0)
    summary_hint_left_button.pressed.connect(_cycle_summary_hint.bind(-1))
    nav_row.add_child(summary_hint_left_button)

    summary_hint_right_button = Button.new()
    summary_hint_right_button.text = ">"
    summary_hint_right_button.custom_minimum_size = Vector2(36.0, 26.0)
    summary_hint_right_button.pressed.connect(_cycle_summary_hint.bind(1))
    nav_row.add_child(summary_hint_right_button)

    summary_hint_panel.hide()

func _setup_defeat_audio() -> void:
    if defeat_sound_player != null:
        return
    defeat_sound_player = AudioStreamPlayer.new()
    defeat_sound_player.name = "RedSkyDefeatAudio"
    defeat_sound_player.bus = "Effects"
    defeat_sound_player.stream = RED_SKY_DEFEAT_SOUND
    defeat_sound_player.volume_db = -6.0
    add_child(defeat_sound_player)

func _play_defeat_sound() -> void:
    if defeat_sound_player == null:
        return
    defeat_sound_player.stop()
    defeat_sound_player.pitch_scale = 1.0 + rng.randf_range(-0.03, 0.03)
    defeat_sound_player.play()

func _play_red_sky_sfx(effect_type: SoundEffectSettings.SOUND_EFFECT_TYPE, volume_db_offset: float = 0.0, pitch_offset: float = 0.0) -> void:
    if AudioManager == null:
        return
    AudioManager.create_audio(effect_type, volume_db_offset, pitch_offset)

func tune_text_pixel_filter(delta: float) -> void:
    combat_text_scale = clampf(combat_text_scale + delta, 1.0, 3.2)
    _apply_text_filter_scale()
    print("Red Sky text filter scale: ", snappedf(combat_text_scale, 0.01))

func _show_pre_run_panel() -> void:
    if _is_multi_mode_challenge_active():
        _begin_run()
        return
    _close_pause_menu()
    persistent_data = RED_SKY_PROGRESS.load_data()
    selected_start_wave = RED_SKY_PROGRESS.get_selected_start_wave(persistent_data)
    run_start_wave = selected_start_wave
    current_wave = selected_start_wave
    waves_cleared = max(0, run_start_wave - 1)
    meta_bonuses = RED_SKY_DATA.build_meta_bonuses(persistent_data.get("meta_upgrades", {}))
    _apply_meta_bonuses()
    _clear_runtime_entities()
    _reset_defeat_sequence_state()
    run_state = RUN_STATES.SUMMARY
    showing_pre_run_panel = true
    Global.game_state = Util.GAME_STATES.UPGRADES
    upgrade_panel.hide()
    if power_customize_button != null:
        power_customize_button.visible = false
    summary_title_label.text = tr("Red Sky Deployment")
    _reset_summary_presentation_state()
    summary_charts_row.hide()
    summary_damage_chart.hide()
    summary_label.clear()
    summary_label.append_text(_build_pre_run_summary_bbcode())
    _setup_summary_hints({})
    summary_stats_label.text = _build_pre_run_stats_text()
    continue_button.text = tr("Return to Upgrades")
    retry_button.text = tr("Deploy")
    _refresh_start_wave_selector()
    summary_panel.show()
    _reset_aim_cursor()
    _refresh_mouse_capture_state()
    _refresh_ui()

func _build_pre_run_summary_bbcode() -> String:
    return tr("[color=%s]Choose a start wave below, then press Deploy.\n\nReturn to Upgrades opens the meta tree.[/color]") % _color_to_bbcode(SUMMARY_TEXT_BASE_COLOR)

func _build_pre_run_stats_text() -> String:
    return "Towers hold fixed lanes. Drones orbit close defense. Escort drones roam outward. Collectors chase scrap."

func _build_summary_hints(view_model: Dictionary = {}) -> Array[String]:
    var hints: Array[String] = [
        tr("RED_SKY_HINT_POWER_WHEEL"),
        tr("RED_SKY_HINT_COUNTERMEASURES"),
        tr("RED_SKY_HINT_NUKES_PURPLE"),
    ]
    if bool(view_model.get("show_purple_shot_death_hint", false)):
        hints.push_front(tr("RED_SKY_HINT_PURPLE_SHOT_DEFEAT"))
    return hints

func _setup_summary_hints(view_model: Dictionary = {}) -> void:
    summary_hints = _build_summary_hints(view_model)
    summary_hint_index = 0 if summary_hints.is_empty() else randi() % summary_hints.size()
    _refresh_summary_hint()

func _refresh_summary_hint() -> void:
    if summary_hint_panel == null or summary_hint_title_label == null or summary_hint_label == null or summary_hint_left_button == null or summary_hint_right_button == null:
        return
    if summary_hints.is_empty():
        summary_hint_panel.hide()
        summary_hint_title_label.text = ""
        summary_hint_label.text = ""
        return
    summary_hint_index = wrapi(summary_hint_index, 0, summary_hints.size())
    summary_hint_panel.show()
    summary_hint_title_label.text = _trf("BATTLE_HINT_NUMBERED", [summary_hint_index + 1, summary_hints.size()])
    summary_hint_label.text = summary_hints[summary_hint_index]
    var show_navigation: bool = summary_hints.size() > 1
    summary_hint_left_button.visible = show_navigation
    summary_hint_right_button.visible = show_navigation

func _cycle_summary_hint(direction: int) -> void:
    if summary_hints.is_empty():
        return
    summary_hint_index += direction
    _refresh_summary_hint()

func _refresh_start_wave_selector() -> void:
    if start_wave_buttons_grid == null or start_wave_dropdown == null:
        return
    selected_start_wave = RED_SKY_PROGRESS.get_selected_start_wave(persistent_data)
    start_wave_header_label.text = tr("Start Wave")
    start_wave_info_label.text = _build_start_wave_info_text()
    var unlocked_start_waves: Array[int] = RED_SKY_PROGRESS.get_unlocked_start_waves(persistent_data)
    var use_dropdown: bool = unlocked_start_waves.size() > START_WAVE_BUTTON_MAX_BEFORE_DROPDOWN
    if use_dropdown:
        start_wave_buttons_grid.hide()
        for child in start_wave_buttons_grid.get_children():
            child.queue_free()
        start_wave_buttons.clear()
        start_wave_dropdown.show()
        start_wave_dropdown.set_block_signals(true)
        start_wave_dropdown.clear()
        for start_wave in unlocked_start_waves:
            start_wave_dropdown.add_item(_format_start_wave_dropdown_text(start_wave))
        var selected_index: int = unlocked_start_waves.find(selected_start_wave)
        if selected_index < 0:
            selected_index = 0
        start_wave_dropdown.select(selected_index)
        start_wave_dropdown.set_block_signals(false)
    else:
        start_wave_dropdown.hide()
        start_wave_dropdown.clear()
        for child in start_wave_buttons_grid.get_children():
            child.queue_free()
        start_wave_buttons.clear()
        start_wave_buttons_grid.show()
        start_wave_buttons_grid.columns = mini(3, maxi(1, unlocked_start_waves.size()))
        for start_wave in unlocked_start_waves:
            var button := Button.new()
            button.toggle_mode = true
            button.alignment = HORIZONTAL_ALIGNMENT_LEFT
            button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            button.size_flags_vertical = Control.SIZE_EXPAND_FILL
            button.custom_minimum_size = Vector2(0.0, 86.0 if unlocked_start_waves.size() >= 4 else 100.0)
            button.text = _format_start_wave_button_text(start_wave)
            button.set_meta("start_wave", start_wave)
            button.pressed.connect(_on_start_wave_button_pressed.bind(start_wave))
            start_wave_buttons_grid.add_child(button)
            start_wave_buttons.append(button)
        _refresh_start_wave_button_styles()

func _build_start_wave_info_text() -> String:
    var unlocked_start_waves: Array[int] = RED_SKY_PROGRESS.get_unlocked_start_waves(persistent_data)
    var highest_start_wave: int = unlocked_start_waves.back()
    var next_start_wave: int = RED_SKY_PROGRESS.FIRST_SKIP_START_WAVE if highest_start_wave <= 1 else highest_start_wave + RED_SKY_PROGRESS.START_WAVE_STEP
    var next_unlock_wave: int = RED_SKY_PROGRESS.get_required_best_wave_for_start_wave(next_start_wave)
    var info := _trf("Wave %d selected. Prep picks: %d.", [selected_start_wave, max(0, selected_start_wave - 1)])
    if next_unlock_wave > 0:
        info += _trf(" Beat wave %d to unlock Wave %d starts.", [next_unlock_wave, next_start_wave])
    return info

func _format_start_wave_button_text(start_wave: int) -> String:
    if start_wave <= 1:
        return tr("Wave 1\nFull warm-up")
    return _trf("Wave %d\nPrep picks %d", [start_wave, max(0, start_wave - 1)])

func _format_start_wave_dropdown_text(start_wave: int) -> String:
    if start_wave <= 1:
        return tr("Wave 1 — full warm-up")
    return _trf("Wave %d — prep picks %d", [start_wave, max(0, start_wave - 1)])

func _on_start_wave_dropdown_selected(index: int) -> void:
    var unlocked_start_waves: Array[int] = RED_SKY_PROGRESS.get_unlocked_start_waves(persistent_data)
    if index < 0 or index >= unlocked_start_waves.size():
        return
    _on_start_wave_button_pressed(unlocked_start_waves[index])

func _refresh_start_wave_button_styles() -> void:
    for button in start_wave_buttons:
        if button == null:
            continue
        var button_start_wave: int = int(button.get_meta("start_wave", 1))
        var is_selected: bool = button_start_wave == selected_start_wave
        button.button_pressed = is_selected
        var border_color: Color = Color(1.0, 0.78, 0.34, 1.0) if is_selected else Color(0.54, 0.56, 0.62, 1.0)
        button.add_theme_stylebox_override("normal", _make_upgrade_button_style(border_color, 0.12 if is_selected else 0.06, 4.0 if is_selected else 2.0))
        button.add_theme_stylebox_override("hover", _make_upgrade_button_style(border_color.lightened(0.08), 0.18 if is_selected else 0.10, 4.0 if is_selected else 2.0))
        button.add_theme_stylebox_override("pressed", _make_upgrade_button_style(border_color.lightened(0.14), 0.22 if is_selected else 0.12, 4.0 if is_selected else 2.0))
        button.add_theme_stylebox_override("focus", _make_upgrade_button_style(border_color.lightened(0.18), 0.2 if is_selected else 0.12, 4.0 if is_selected else 2.0))
        button.add_theme_color_override("font_color", Color(0.97, 0.96, 0.92, 1.0))
        button.add_theme_color_override("font_hover_color", Color(1.0, 0.99, 0.96, 1.0))
        button.add_theme_color_override("font_pressed_color", Color(1.0, 0.99, 0.96, 1.0))
        button.add_theme_constant_override("outline_size", 2)
        button.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.05, 0.92))

func _on_start_wave_button_pressed(start_wave: int) -> void:
    persistent_data = RED_SKY_PROGRESS.set_selected_start_wave(start_wave)
    selected_start_wave = RED_SKY_PROGRESS.get_selected_start_wave(persistent_data)
    run_start_wave = selected_start_wave
    current_wave = selected_start_wave
    waves_cleared = max(0, run_start_wave - 1)
    _refresh_start_wave_selector()
    if showing_pre_run_panel:
        summary_label.clear()
        summary_label.append_text(_build_pre_run_summary_bbcode())
        summary_stats_label.text = _build_pre_run_stats_text()
    _refresh_ui()

func _reset_boss_wave_stream_state() -> void:
    boss_wave_stream_timer = 0.0
    boss_wave_stream_interval = 0.0
    boss_wave_stream_types.clear()
    boss_wave_stream_pick_index = 0
    boss_wave_stream_spawn_seq = 0


func _prepare_boss_wave_stream(wave: int) -> void:
    var previous_wave: int = maxi(1, wave - 1)
    var previous_wave_queue: Array[Dictionary] = _build_standard_wave_spawn_list(previous_wave)
    boss_wave_stream_types.clear()
    for entry in previous_wave_queue:
        boss_wave_stream_types.append(str(entry.get("type", "raider")))
    boss_wave_stream_types.shuffle()
    if boss_wave_stream_types.is_empty():
        boss_wave_stream_types.assign(["raider", "runner", "dronelet"])
    var reinforcement_count: int = maxi(1, int(round(float(previous_wave_queue.size()) / 3.0)))
    var previous_wave_duration: float = _estimate_wave_spawn_duration_seconds(previous_wave, previous_wave_queue.size())
    var reinforcement_duration: float = max(0.3, previous_wave_duration * 3.0)
    boss_wave_stream_interval = reinforcement_duration / float(reinforcement_count)
    boss_wave_stream_pick_index = 0
    boss_wave_stream_spawn_seq = 0
    boss_wave_stream_timer = 0.12 + boss_wave_stream_interval


func _boss_is_alive() -> bool:
    for enemy in enemies:
        if str(enemy.get("type", "")) == BOSS_TYPE:
            return true
    return false


func _spawn_boss_wave_stream_enemy() -> void:
    if boss_wave_stream_types.is_empty():
        return
    var pick: String = boss_wave_stream_types[boss_wave_stream_pick_index % boss_wave_stream_types.size()]
    boss_wave_stream_pick_index += 1
    boss_wave_stream_spawn_seq += 1
    var spawned_enemy: Dictionary = _build_enemy_def(pick, current_wave, boss_wave_stream_spawn_seq)
    enemies.append(spawned_enemy)


func _clear_runtime_entities() -> void:
    wave_spawn_queue.clear()
    _reset_boss_wave_stream_state()
    player_bullets.clear()
    nukes.clear()
    explosions.clear()
    enemies.clear()
    enemy_projectiles.clear()
    floating_texts.clear()
    salvage_pickups.clear()
    support_effects.clear()
    tower_fire_timers.clear()
    drone_fire_timers.clear()
    tentacle_cooldowns.clear()
    helper_fire_timers.clear()
    temporary_turrets.clear()
    temporary_shields.clear()
    countermeasure_sweep_visuals.clear()
    purple_shot_countermeasure_timers.clear()
    saw_purple_shots_this_run = false

func _begin_run() -> void:
    _close_pause_menu()
    _summary_pointer_recovery_frames_remaining = 0
    persistent_data = RED_SKY_PROGRESS.load_data()
    meta_bonuses = RED_SKY_DATA.build_meta_bonuses(persistent_data.get("meta_upgrades", {}))
    _apply_open_pit_fixed_meta_bonuses()
    last_run_results.clear()
    selected_start_wave = RED_SKY_PROGRESS.get_selected_start_wave(persistent_data)
    if _is_multi_mode_challenge_active():
        selected_start_wave = int(multi_mode_step.get("target_wave", selected_start_wave))
    run_start_wave = selected_start_wave
    run_state = RUN_STATES.RUNNING
    showing_pre_run_panel = false
    Global.game_state = Util.GAME_STATES.PLAYING
    current_wave = run_start_wave
    waves_cleared = max(0, run_start_wave - 1)
    career_best_wave_at_run_start = int(persistent_data.get("best_wave", 0))
    RED_SKY_PROGRESS.maybe_track_first_deploy()
    RED_SKY_PROGRESS.track_run_start(run_start_wave, persistent_data)
    pending_start_upgrade_picks = 0 if _is_multi_mode_challenge_active() else max(0, run_start_wave - 1)
    used_start_upgrade_picks = 0
    wave_spawn_queue.clear()
    wave_spawn_timer = 0.0
    _reset_boss_wave_stream_state()
    fire_timer = 0.0
    support_time = 0.0
    wave_upgrade_levels.clear()
    offered_wave_upgrades.clear()
    last_started_wave = -1
    nuke_regen_bank = 0.0
    homing_shot_cycle = 0
    homing_missile_level = 0
    countermeasure_charges = 0
    countermeasure_regen_bank = 0.0
    countermeasure_sweep_cooldown = 0.0
    countermeasure_sweep_visuals.clear()
    purple_shot_countermeasure_timers.clear()
    saw_purple_shots_this_run = false
    _clear_runtime_entities()
    _reset_defeat_sequence_state()
    score = 0
    damage_dealt = 0.0
    damage_taken = 0.0
    shield_damage_absorbed = 0.0
    damage_dealt_gun = 0.0
    damage_dealt_tower = 0.0
    damage_dealt_drone = 0.0
    damage_dealt_tentacle = 0.0
    damage_dealt_nuke = 0.0
    damage_dealt_blast = 0.0
    damage_dealt_deflection = 0.0
    hull_damage_mitigated = 0.0
    intercepted_enemy_shot_damage = 0.0
    deflected_threat_damage = 0.0
    nukes_launched = 0
    enemy_projectiles_destroyed = 0
    enemy_projectiles_deflected = 0
    escape_scores = 0
    shots_fired = 0
    total_kills = 0
    tower_kills = 0
    drone_kills = 0
    tentacle_kills = 0
    salvage_collected = 0
    salvage_lost = 0
    bonus_scrap_earned = 0
    scrap_generation_accumulator = 0.0
    enemy_kill_counts.clear()
    for enemy_type in ENEMY_TYPE_ORDER:
        enemy_kill_counts[enemy_type] = 0
    enemy_kill_counts[BOSS_TYPE] = 0
    _apply_meta_bonuses()
    summary_charts_row.hide()
    summary_damage_chart.hide()
    _reset_summary_presentation_state()
    summary_panel.hide()
    upgrade_panel.hide()
    if power_customize_button != null:
        power_customize_button.visible = false
    _reset_aim_cursor()
    if pending_start_upgrade_picks > 0:
        _show_start_upgrade_panel()
    else:
        _start_wave(current_wave)
    _refresh_mouse_capture_state()
    _refresh_ui()

func _reset_defeat_sequence_state() -> void:
    defeat_sequence_timer = 0.0
    defeat_explosion_timer = 0.0
    pending_finish_reason = ""
    if defeat_sound_player != null:
        defeat_sound_player.stop()

func _apply_meta_bonuses() -> void:
    base_max_health = float(meta_bonuses.get("base_health", 154.0))
    base_health = base_max_health
    shield_max = float(meta_bonuses.get("base_shield", 0.0))
    shield_health = shield_max
    shield_regen_rate = float(meta_bonuses.get("shield_regen", 0.0))
    shield_regen_delay = float(meta_bonuses.get("shield_regen_delay", 2.6))
    shield_regen_cooldown = 0.0
    damage_reduction = float(meta_bonuses.get("damage_reduction", 0.0))
    gun_damage = float(meta_bonuses.get("gun_damage", 12.0))
    bullet_speed = float(meta_bonuses.get("bullet_speed", 930.0))
    fire_interval = float(meta_bonuses.get("fire_interval", 0.17))
    crit_chance = float(meta_bonuses.get("crit_chance", 0.04))
    crit_bonus = float(meta_bonuses.get("crit_bonus", 1.65))
    bullet_pierce = int(meta_bonuses.get("bullet_pierce", 0))
    bullet_blast_radius = float(meta_bonuses.get("bullet_blast_radius", 0.0))
    bullet_blast_damage_scale = float(meta_bonuses.get("bullet_blast_damage", 1.0))
    pickup_radius = float(meta_bonuses.get("pickup_radius", 28.0))
    salvage_multiplier = float(meta_bonuses.get("salvage_multiplier", 1.0))
    salvage_lifetime = float(meta_bonuses.get("salvage_lifetime", 7.4))
    meta_reward_multiplier = float(meta_bonuses.get("meta_reward_multiplier", 1.0))
    wave_scrap_bonus = float(meta_bonuses.get("wave_scrap_bonus", 0.0))
    wave_auto_bank_ratio = float(meta_bonuses.get("wave_auto_bank_ratio", 0.68))
    max_level_up_choice_count = maxi(3, int(meta_bonuses.get("max_level_up_choice_count", 9)))
    max_wave_upgrade_choices = maxi(max_level_up_choice_count, int(meta_bonuses.get("max_wave_upgrade_choices", MAX_UPGRADE_BUTTONS)))
    level_up_choice_count = clampi(int(meta_bonuses.get("level_up_choice_count", 3)), 3, max_level_up_choice_count)
    enemy_count_scale = float(meta_bonuses.get("enemy_count_scale", 1.0))
    enemy_speed_scale = float(meta_bonuses.get("enemy_speed_scale", 1.0))
    enemy_projectile_speed_scale = float(meta_bonuses.get("enemy_projectile_speed_scale", 1.0))
    enemy_projectile_damage_scale = float(meta_bonuses.get("enemy_projectile_damage_scale", 1.0))
    elite_spawn_scale = float(meta_bonuses.get("elite_spawn_scale", 1.0))
    heavy_enemy_health_scale = float(meta_bonuses.get("heavy_enemy_health_scale", 1.0))
    heavy_enemy_damage_scale = float(meta_bonuses.get("heavy_enemy_damage_scale", 1.0))
    apex_enemy_health_scale = float(meta_bonuses.get("apex_enemy_health_scale", 1.0))
    apex_enemy_damage_scale = float(meta_bonuses.get("apex_enemy_damage_scale", 1.0))
    nuke_max = maxi(int(meta_bonuses.get("nuke_max", 5)), 1)
    nuke_regen_per_wave = maxi(int(meta_bonuses.get("nuke_regen_per_wave", 1)), 1)
    remaining_nukes = clampi(int(meta_bonuses.get("starting_nukes", 1)), 0, nuke_max)
    nuke_damage = float(meta_bonuses.get("nuke_damage", 128.0))
    nuke_blast_radius = float(meta_bonuses.get("nuke_radius", 292.0))
    repair_between_waves = maxf(
        float(RED_SKY_DATA.MIN_REPAIR_BETWEEN_WAVES),
        float(meta_bonuses.get("repair_between_waves", RED_SKY_DATA.MIN_REPAIR_BETWEEN_WAVES))
    )
    projectile_redirect_chance = float(meta_bonuses.get("projectile_redirect_chance", 0.0))
    upgrade_power_multiplier = float(meta_bonuses.get("upgrade_power_multiplier", 1.0))
    tower_count = int(meta_bonuses.get("tower_count", 0))
    tower_damage = float(meta_bonuses.get("tower_damage", 15.0))
    tower_range = float(meta_bonuses.get("tower_range", 270.0))
    tower_fire_interval = float(meta_bonuses.get("tower_fire_interval", 1.18))
    drone_count = int(meta_bonuses.get("drone_count", 0))
    drone_damage = float(meta_bonuses.get("drone_damage", 13.0))
    drone_range = float(meta_bonuses.get("drone_range", 210.0))
    drone_fire_interval = float(meta_bonuses.get("drone_fire_interval", 0.88))
    drone_speed = float(meta_bonuses.get("drone_speed", 182.0))
    tentacle_count = int(meta_bonuses.get("tentacle_count", 0))
    tentacle_damage = float(meta_bonuses.get("tentacle_damage", 19.0))
    tentacle_range = float(meta_bonuses.get("tentacle_range", 168.0))
    tentacle_attack_cooldown = float(meta_bonuses.get("tentacle_cooldown", 1.05))
    tentacle_slow = float(meta_bonuses.get("tentacle_slow", 0.18))
    construction_drone_count = int(meta_bonuses.get("construction_drone_count", 0))
    construction_build_rate = float(meta_bonuses.get("construction_build_rate", 1.0))
    temporary_turret_limit = int(meta_bonuses.get("temporary_turret_limit", 0))
    temporary_turret_damage = float(meta_bonuses.get("temporary_turret_damage", 11.0))
    temporary_turret_range = float(meta_bonuses.get("temporary_turret_range", 210.0))
    temporary_turret_fire_interval = float(meta_bonuses.get("temporary_turret_fire_interval", 1.05))
    temporary_turret_duration = float(meta_bonuses.get("temporary_turret_duration", 16.0))
    temporary_turret_health = float(meta_bonuses.get("temporary_turret_health", 58.0))
    temporary_shield_limit = int(meta_bonuses.get("temporary_shield_limit", 0))
    temporary_shield_capacity = float(meta_bonuses.get("temporary_shield_capacity", 54.0))
    temporary_shield_regen = float(meta_bonuses.get("temporary_shield_regen", 4.0))
    temporary_shield_duration = float(meta_bonuses.get("temporary_shield_duration", 16.0))
    temporary_shield_health = float(meta_bonuses.get("temporary_shield_health", 54.0))
    helper_drone_count = int(meta_bonuses.get("helper_drone_count", 0))
    helper_drone_damage = float(meta_bonuses.get("helper_drone_damage", 10.0))
    helper_drone_range = float(meta_bonuses.get("helper_drone_range", 260.0))
    helper_drone_fire_interval = float(meta_bonuses.get("helper_drone_fire_interval", 0.76))
    helper_drone_speed = float(meta_bonuses.get("helper_drone_speed", 224.0))
    collector_bot_count = int(meta_bonuses.get("collector_bot_count", 0))
    collector_bot_speed = float(meta_bonuses.get("collector_bot_speed", 176.0))
    scrap_generation_per_second = float(meta_bonuses.get("scrap_generation_per_second", 0.0))
    countermeasures_rating = maxf(0.2, float(meta_bonuses.get("countermeasures_rating", 0.2)))
    _ensure_support_arrays()
    _rebuild_power_slot_order()
    _recalculate_power_distribution()

func _start_wave(wave: int) -> void:
    last_started_wave = wave
    current_wave = wave
    _suppress_mouse_capture_until_msec = Time.get_ticks_msec() + WAVE_INTRO_MOUSE_VISIBLE_MS
    var intro_timer := get_tree().create_timer(float(WAVE_INTRO_MOUSE_VISIBLE_MS) / 1000.0)
    intro_timer.timeout.connect(func() -> void:
        _refresh_mouse_capture_state()
    , CONNECT_ONE_SHOT)
    if _is_boss_wave(wave):
        _show_boss_warning_flash(wave)
        _prepare_boss_wave_stream(wave)
    else:
        _reset_boss_wave_stream_state()
    wave_spawn_queue = _build_wave_spawn_list(wave)
    wave_spawn_timer = 0.12
    _spawn_floating_text("WAVE %d" % wave, get_viewport_rect().size * Vector2(0.5, 0.28), Color(1.0, 0.88, 0.58, 1.0), 34)
    if current_wave == run_start_wave:
        _show_run_start_banner()

func _build_wave_spawn_list(wave: int) -> Array[Dictionary]:
    if _is_boss_wave(wave):
        return _build_boss_wave_spawn_list(wave)
    return _build_standard_wave_spawn_list(wave)

func _build_standard_wave_spawn_list(wave: int) -> Array[Dictionary]:
    var queue: Array[Dictionary] = []
    var total_spawns: int = maxi(4, int(round((6 + wave * 2 + int(pow(float(wave), 1.08))) * enemy_count_scale)))
    if wave >= 6:
        total_spawns = maxi(4, total_spawns - mini(3, int(wave / 7)))
    if wave >= 10 and wave % 5 == 0:
        total_spawns = maxi(4, int(round(float(total_spawns) * 0.82)))
    var enemy_types: Array[String] = []
    var remaining_spawns: int = total_spawns
    var dreadnought_count: int = _scaled_enemy_count(1 if wave >= 14 and wave % 6 == 0 else 0, elite_spawn_scale * 0.84)
    dreadnought_count = min(dreadnought_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= dreadnought_count
    for _i in range(dreadnought_count):
        enemy_types.append("dreadnought")
    var command_ship_count: int = _scaled_enemy_count(1 if wave >= 11 and (wave % 5 == 0 or wave >= 18) else 0, elite_spawn_scale * 0.9)
    command_ship_count = min(command_ship_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= command_ship_count
    for _i in range(command_ship_count):
        enemy_types.append("command_ship")
    var destroyer_count: int = 0 if wave < 8 else _scaled_enemy_count(min(1 + int((wave - 8) / 5), maxi(1, total_spawns / 16)), elite_spawn_scale * 0.96)
    destroyer_count = min(destroyer_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= destroyer_count
    for _i in range(destroyer_count):
        enemy_types.append("destroyer")
    var artillery_count: int = 0 if wave < 6 else _scaled_enemy_count(min(1 + int((wave - 6) / 6), maxi(1, total_spawns / 18)), elite_spawn_scale * 0.94)
    artillery_count = min(artillery_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= artillery_count
    for _i in range(artillery_count):
        enemy_types.append("artillery")
    var carrier_count: int = 0 if wave < 9 else _scaled_enemy_count(min(1 + int((wave - 9) / 8), maxi(1, total_spawns / 18)), elite_spawn_scale * 0.92)
    carrier_count = min(carrier_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= carrier_count
    for _i in range(carrier_count):
        enemy_types.append("carrier")
    var siege_count: int = 0 if wave < 7 else _scaled_enemy_count(min(1 + int((wave - 7) / 7), maxi(1, total_spawns / 14)), elite_spawn_scale)
    siege_count = min(siege_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= siege_count
    for _i in range(siege_count):
        enemy_types.append("siege")
    var brute_count: int = 0 if wave < 4 else _scaled_enemy_count(min(1 + int((wave - 4) / 4), maxi(1, total_spawns / 10)), elite_spawn_scale)
    brute_count = min(brute_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= brute_count
    for _i in range(brute_count):
        enemy_types.append("brute")
    var bomber_count: int = 0 if wave < 4 else _scaled_enemy_count(min(1 + int((wave - 4) / 4), maxi(1, total_spawns / 9)), elite_spawn_scale)
    bomber_count = min(bomber_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= bomber_count
    for _i in range(bomber_count):
        enemy_types.append("bomber")
    var gunship_count: int = 0 if wave < 2 else _scaled_enemy_count(min(1 + int((wave - 2) / 3), maxi(1, total_spawns / 8)), elite_spawn_scale)
    gunship_count = min(gunship_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= gunship_count
    for _i in range(gunship_count):
        enemy_types.append("gunship")
    var interceptor_count: int = 0 if wave < 4 else _scaled_enemy_count(min(1 + int((wave - 4) / 4), maxi(1, total_spawns / 11)), elite_spawn_scale * 0.98)
    interceptor_count = min(interceptor_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= interceptor_count
    for _i in range(interceptor_count):
        enemy_types.append("interceptor")
    var skimmer_count: int = 0 if wave < 5 else _scaled_enemy_count(min(1 + int((wave - 5) / 5), maxi(1, total_spawns / 10)), elite_spawn_scale)
    skimmer_count = min(skimmer_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= skimmer_count
    for _i in range(skimmer_count):
        enemy_types.append("skimmer")
    var runner_count: int = 1 if wave >= 2 else 0
    runner_count += int(max(wave - 3, 0) / 3)
    runner_count = min(runner_count, maxi(0, remaining_spawns - 1))
    remaining_spawns -= runner_count
    for _i in range(runner_count):
        enemy_types.append("runner")
    for _i in range(maxi(1, remaining_spawns)):
        enemy_types.append("raider")
    enemy_types.shuffle()
    for spawn_index in range(enemy_types.size()):
        queue.append(_build_enemy_def(enemy_types[spawn_index], wave, spawn_index))
    _apply_shooter_formations(queue)
    return queue

func _build_boss_wave_spawn_list(wave: int) -> Array[Dictionary]:
    var queue: Array[Dictionary] = [_build_enemy_def(BOSS_TYPE, wave, 0)]
    queue[0]["spawn_delay"] = boss_wave_stream_interval
    return queue

func _estimate_wave_spawn_duration_seconds(wave: int, spawn_count: int) -> float:
    if spawn_count <= 1:
        return 0.0
    var base_spawn_delay: float = max(0.08, 0.44 - float(wave) * 0.012)
    return base_spawn_delay * float(spawn_count - 1)

func _scaled_enemy_count(base_count: int, scale: float) -> int:
    if base_count <= 0:
        return 0
    return maxi(1, int(round(float(base_count) * maxf(0.35, scale))))

func _apply_shooter_formations(queue: Array[Dictionary]) -> void:
    if queue.is_empty():
        return
    var viewport := get_viewport_rect().size
    var shared_focus: float = rng.randf_range(-170.0, 170.0)
    for shooter_type in SHOOTER_FORMATION_TYPES:
        var indices: Array[int] = []
        for queue_index in range(queue.size()):
            if str(queue[queue_index].get("type", "")) == shooter_type:
                indices.append(queue_index)
        if indices.size() < 2:
            continue
        var pod_size: int = 3
        if shooter_type in ["destroyer", "command_ship", "dreadnought", "artillery", "siege"]:
            pod_size = 2
        for pod_start in range(0, indices.size(), pod_size):
            var pod_indices: Array[int] = indices.slice(pod_start, mini(pod_start + pod_size, indices.size()))
            var base_lane: float = shared_focus + rng.randf_range(-72.0, 72.0)
            var group_seed: float = rng.randf_range(0.0, TAU)
            var shared_standoff: float = viewport.y * rng.randf_range(0.22, 0.36)
            if shooter_type in ["skimmer", "interceptor"]:
                shared_standoff = viewport.y * rng.randf_range(0.16, 0.24)
            elif shooter_type in ["siege", "artillery", "command_ship", "dreadnought"]:
                shared_standoff = viewport.y * rng.randf_range(0.16, 0.22)
            elif shooter_type == "bomber":
                shared_standoff = viewport.y * rng.randf_range(0.38, 0.48)
            var n: int = pod_indices.size()
            var shared_orbit: float = 0.0
            for idx in pod_indices:
                shared_orbit += float(queue[idx].get("orbit_radius", 72.0))
            shared_orbit /= float(maxi(1, n))
            var volley_timer: float = rng.randf_range(0.55, 1.0)
            for formation_slot in range(n):
                var enemy: Dictionary = queue[pod_indices[formation_slot]]
                var slot_offset: float = (float(formation_slot) - float(n - 1) * 0.5) * SHOOTER_FORMATION_SPACING * 0.82
                enemy["lane_offset"] = base_lane + slot_offset
                enemy["standoff_y"] = shared_standoff
                enemy["orbit_radius"] = shared_orbit
                enemy["movement_seed"] = group_seed + float(formation_slot) * 0.09
                enemy["shoot_timer"] = volley_timer + float(formation_slot) * 0.04
                queue[pod_indices[formation_slot]] = enemy

func _build_enemy_def(enemy_type: String, wave: int, spawn_index: int) -> Dictionary:
    var viewport := get_viewport_rect().size
    var spawn_pos := _get_random_spawn_position(viewport)
    var data := {
        "type": enemy_type,
        "pos": spawn_pos,
        "vel": Vector2.ZERO,
        "shoot_timer": rng.randf_range(0.6, 1.25),
        "lifetime": 0.0,
        "wave": wave,
        "radius": 18.0,
        "health": 28.0,
        "speed": 116.0,
        "contact_damage": 12.0,
        "score_value": 12,
        "escape_score": 0,
        "mass": 3.0,
        "standoff_y": viewport.y * 0.34,
        "lane_offset": rng.randf_range(-300.0, 300.0),
        "spawn_index": spawn_index,
        "movement_seed": rng.randf_range(0.0, TAU),
        "drift_strength": rng.randf_range(40.0, 90.0),
        "orbit_radius": rng.randf_range(32.0, 76.0),
        "arc_direction": -1.0 if rng.randf() < 0.5 else 1.0,
        "slow_timer": 0.0,
        "slow_amount": 0.0,
        "spawn_timer": rng.randf_range(1.0, 1.8),
        "spawned_count": 0,
        "max_spawned": 0
    }
    data.merge(_get_enemy_archetype_stats(enemy_type, wave, viewport), true)
    data["max_health"] = float(data.get("health", 1.0))
    return data

func _get_enemy_archetype_stats(enemy_type: String, wave: int, viewport: Vector2) -> Dictionary:
    var stats := {}
    match enemy_type:
        BOSS_TYPE:
            stats = {
                "radius": 74.0,
                "health": 1880.0 + float(wave) * 165.0,
                "speed": 44.0 + float(wave) * 1.35,
                "contact_damage": 0.0,
                "score_value": 520 + wave * 42,
                "mass": 32.0,
                "standoff_y": viewport.y * rng.randf_range(0.12, 0.16),
                "orbit_radius": rng.randf_range(92.0, 124.0),
                "shoot_timer": rng.randf_range(0.55, 0.95),
                "drift_strength": rng.randf_range(10.0, 20.0),
                "boss_pattern": 0,
                "boss_burst_timer": 0.0
            }
        "runner":
            stats = {
                "radius": 14.0,
                "health": 20.0 + float(wave) * 4.5,
                "speed": 176.0 + float(wave) * 7.4,
                "contact_damage": 8.0 + float(wave) * 1.4,
                "score_value": 18 + wave * 3,
                "mass": 2.0,
                "drift_strength": rng.randf_range(90.0, 160.0)
            }
        "gunship":
            stats = {
                "radius": 22.0,
                "health": 44.0 + float(wave) * 9.0,
                "speed": 92.0 + float(wave) * 4.0,
                "contact_damage": 16.0 + float(wave) * 1.9,
                "score_value": 24 + wave * 4,
                "mass": 4.0,
                "standoff_y": viewport.y * rng.randf_range(0.24, 0.42),
                "orbit_radius": rng.randf_range(48.0, 94.0)
            }
        "bomber":
            stats = {
                "radius": 27.0,
                "health": 82.0 + float(wave) * 12.5,
                "speed": 86.0 + float(wave) * 4.0,
                "contact_damage": 28.0 + float(wave) * 2.8,
                "score_value": 34 + wave * 5,
                "mass": 7.5,
                "drift_strength": rng.randf_range(70.0, 120.0)
            }
        "brute":
            stats = {
                "radius": 32.0,
                "health": (38.0 + float(wave) * 7.8) * 4.6,
                "speed": 74.0 + float(wave) * 3.0,
                "contact_damage": 22.0 + float(wave) * 3.6,
                "score_value": 42 + wave * 6,
                "mass": 9.5,
                "drift_strength": rng.randf_range(20.0, 50.0)
            }
        "skimmer":
            stats = {
                "radius": 16.0,
                "health": 28.0 + float(wave) * 5.6,
                "speed": 154.0 + float(wave) * 6.4,
                "contact_damage": 10.0 + float(wave) * 1.9,
                "score_value": 26 + wave * 4,
                "mass": 2.6,
                "standoff_y": viewport.y * rng.randf_range(0.18, 0.28),
                "orbit_radius": rng.randf_range(96.0, 142.0),
                "drift_strength": rng.randf_range(110.0, 170.0)
            }
        "siege":
            stats = {
                "radius": 29.0,
                "health": 124.0 + float(wave) * 15.0,
                "speed": 68.0 + float(wave) * 2.6,
                "contact_damage": 26.0 + float(wave) * 3.2,
                "score_value": 58 + wave * 8,
                "mass": 11.5,
                "standoff_y": viewport.y * rng.randf_range(0.18, 0.24),
                "orbit_radius": rng.randf_range(72.0, 118.0),
                "shoot_timer": rng.randf_range(0.9, 1.45),
                "drift_strength": rng.randf_range(18.0, 42.0)
            }
        "carrier":
            stats = {
                "radius": 38.0,
                "health": 176.0 + float(wave) * 18.0,
                "speed": 58.0 + float(wave) * 1.7,
                "contact_damage": 32.0 + float(wave) * 3.9,
                "score_value": 84 + wave * 10,
                "mass": 16.0,
                "standoff_y": viewport.y * rng.randf_range(0.14, 0.20),
                "orbit_radius": rng.randf_range(104.0, 156.0),
                "shoot_timer": rng.randf_range(1.1, 1.8),
                "spawn_timer": rng.randf_range(1.0, 1.5),
                "max_spawned": 4 + int(wave / 6),
                "drift_strength": rng.randf_range(16.0, 28.0)
            }
        "interceptor":
            stats = {
                "radius": 18.0,
                "health": 34.0 + float(wave) * 6.6,
                "speed": 166.0 + float(wave) * 7.8,
                "contact_damage": 11.0 + float(wave) * 1.8,
                "score_value": 30 + wave * 4,
                "mass": 2.8,
                "standoff_y": viewport.y * rng.randf_range(0.17, 0.25),
                "orbit_radius": rng.randf_range(84.0, 132.0),
                "shoot_timer": rng.randf_range(0.55, 1.05),
                "drift_strength": rng.randf_range(120.0, 180.0)
            }
        "artillery":
            stats = {
                "radius": 30.0,
                "health": 142.0 + float(wave) * 16.0,
                "speed": 60.0 + float(wave) * 2.2,
                "contact_damage": 24.0 + float(wave) * 3.0,
                "score_value": 66 + wave * 8,
                "mass": 12.5,
                "standoff_y": viewport.y * rng.randf_range(0.16, 0.22),
                "orbit_radius": rng.randf_range(68.0, 108.0),
                "shoot_timer": rng.randf_range(1.2, 1.9),
                "drift_strength": rng.randf_range(14.0, 30.0)
            }
        "destroyer":
            stats = {
                "radius": 33.0,
                "health": 188.0 + float(wave) * 18.0,
                "speed": 76.0 + float(wave) * 2.8,
                "contact_damage": 28.0 + float(wave) * 3.4,
                "score_value": 82 + wave * 10,
                "mass": 14.0,
                "standoff_y": viewport.y * rng.randf_range(0.2, 0.27),
                "orbit_radius": rng.randf_range(72.0, 114.0),
                "shoot_timer": rng.randf_range(0.95, 1.45),
                "drift_strength": rng.randf_range(26.0, 48.0)
            }
        "command_ship":
            stats = {
                "radius": 41.0,
                "health": 254.0 + float(wave) * 22.0,
                "speed": 56.0 + float(wave) * 1.8,
                "contact_damage": 34.0 + float(wave) * 3.7,
                "score_value": 110 + wave * 12,
                "mass": 18.5,
                "standoff_y": viewport.y * rng.randf_range(0.14, 0.19),
                "orbit_radius": rng.randf_range(118.0, 164.0),
                "shoot_timer": rng.randf_range(1.15, 1.75),
                "spawn_timer": rng.randf_range(1.6, 2.4),
                "max_spawned": 2 + int(wave / 9),
                "drift_strength": rng.randf_range(14.0, 24.0)
            }
        "dreadnought":
            stats = {
                "radius": 50.0,
                "health": 420.0 + float(wave) * 30.0,
                "speed": 42.0 + float(wave) * 1.4,
                "contact_damage": 46.0 + float(wave) * 4.5,
                "score_value": 180 + wave * 16,
                "mass": 24.0,
                "standoff_y": viewport.y * rng.randf_range(0.12, 0.17),
                "orbit_radius": rng.randf_range(86.0, 128.0),
                "shoot_timer": rng.randf_range(1.45, 2.05),
                "drift_strength": rng.randf_range(10.0, 22.0)
            }
        "dronelet":
            stats = {
                "radius": 12.0,
                "health": 16.0 + float(wave) * 3.5,
                "speed": 188.0 + float(wave) * 7.2,
                "contact_damage": 7.0 + float(wave) * 1.2,
                "score_value": 12 + wave * 2,
                "mass": 1.7,
                "drift_strength": rng.randf_range(120.0, 180.0)
            }
        _:
            stats = {
                "health": 30.0 + float(wave) * 6.5,
                "speed": 116.0 + float(wave) * 5.4,
                "contact_damage": 12.0 + float(wave) * 2.2,
                "score_value": 12 + wave * 3,
                "mass": 3.2,
                "drift_strength": rng.randf_range(50.0, 95.0)
            }
    var health_scale: float = _get_enemy_health_scale(wave, enemy_type)
    var damage_scale: float = _get_enemy_damage_scale(wave, enemy_type)
    var reward_scale: float = _get_enemy_reward_scale(wave, enemy_type)
    stats["health"] = float(stats.get("health", 1.0)) * health_scale
    stats["contact_damage"] = float(stats.get("contact_damage", 1.0)) * damage_scale
    stats["score_value"] = max(1, int(round(float(stats.get("score_value", 1)) * reward_scale)))
    stats["speed"] = float(stats.get("speed", 100.0)) * _get_enemy_speed_scale(wave, enemy_type)
    return stats

func _get_enemy_health_scale(wave: int, enemy_type: String) -> float:
    var late_wave_scale: float = 1.0 + max(0.0, float(wave - 6)) * 0.075
    late_wave_scale *= 1.0 + max(0.0, float(wave - 12)) * 0.035
    if _is_heavy_enemy_type(enemy_type):
        late_wave_scale *= 1.1
        late_wave_scale *= heavy_enemy_health_scale
    if _is_apex_enemy_type(enemy_type):
        late_wave_scale *= apex_enemy_health_scale
    return late_wave_scale

func _get_enemy_damage_scale(wave: int, enemy_type: String) -> float:
    var scale: float = 1.0 + max(0.0, float(wave - 4)) * 0.045
    scale *= 1.0 + max(0.0, float(wave - 12)) * 0.018
    if _is_heavy_enemy_type(enemy_type):
        scale *= 1.06
        scale *= heavy_enemy_damage_scale
    if _is_apex_enemy_type(enemy_type):
        scale *= apex_enemy_damage_scale
    return scale

func _get_enemy_reward_scale(wave: int, enemy_type: String) -> float:
    var scale: float = 1.0 + max(0.0, float(wave - 3)) * 0.05
    if _is_heavy_enemy_type(enemy_type):
        scale *= 1.1
    if _is_apex_enemy_type(enemy_type):
        scale *= 1.18
    return scale

func _get_enemy_speed_scale(wave: int, enemy_type: String) -> float:
    var scale: float = 1.0 + max(0.0, float(wave - 8)) * 0.01
    if enemy_type == "brute":
        scale *= 0.92
    if enemy_type in ["artillery", "command_ship", "dreadnought"]:
        scale *= 0.9
    scale *= enemy_speed_scale
    return scale

func _is_heavy_enemy_type(enemy_type: String) -> bool:
    return enemy_type in ["brute", "siege", "carrier", "artillery", "destroyer", "command_ship", "dreadnought", BOSS_TYPE]

func _is_apex_enemy_type(enemy_type: String) -> bool:
    return enemy_type in ["command_ship", "dreadnought", BOSS_TYPE]

func _process(delta: float) -> void:
    if _is_pause_menu_open():
        return
    if _process_multi_mode_intro(delta):
        _refresh_ui()
        queue_redraw()
        return
    if _summary_pointer_recovery_frames_remaining > 0 and run_state == RUN_STATES.SUMMARY:
        _summary_pointer_recovery_frames_remaining -= 1
        _apply_summary_pointer_recovery()
    _update_environment(delta)
    if run_state == RUN_STATES.RUNNING:
        _process_running(delta)
    elif run_state == RUN_STATES.DEFEAT:
        _process_defeat_sequence(delta)
    elif run_state == RUN_STATES.SUMMARY and not showing_pre_run_panel:
        _process_summary_chart_animation(delta)
    _process_explosions(delta)
    _process_support_effects(delta)
    _process_floating_texts(delta)
    _refresh_ui()
    queue_redraw()

func _process_defeat_sequence(delta: float) -> void:
    defeat_sequence_timer += delta
    defeat_explosion_timer -= delta
    if defeat_explosion_timer <= 0.0:
        defeat_explosion_timer = DEFEAT_EXPLOSION_INTERVAL
        _spawn_defeat_explosion()
    if defeat_sequence_timer >= DEFEAT_SEQUENCE_DURATION:
        _finish_run(pending_finish_reason if not pending_finish_reason.is_empty() else "Base destroyed.")

func _spawn_defeat_explosion() -> void:
    var base_pos := _get_base_position()
    var angle: float = rng.randf_range(0.0, TAU)
    var distance: float = rng.randf_range(6.0, BASE_RADIUS + 34.0)
    var blast_pos := base_pos + Vector2(cos(angle), sin(angle)) * distance + Vector2(rng.randf_range(-8.0, 8.0), rng.randf_range(-8.0, 8.0))
    explosions.append({
        "pos": blast_pos,
        "radius": 18.0,
        "max_radius": rng.randf_range(52.0, 118.0),
        "age": 0.0,
        "duration": rng.randf_range(0.18, 0.34),
        "color": EXPLOSION_COLOR
    })

func _process_running(delta: float) -> void:
    support_time += delta
    _update_power_wheel_input(delta)
    fire_timer -= delta
    wave_spawn_timer -= delta
    shield_regen_cooldown = max(0.0, shield_regen_cooldown - delta)
    if shield_regen_cooldown <= 0.0 and shield_max > 0.0 and shield_health < shield_max:
        shield_health = min(_get_effective_shield_max(), shield_health + _get_effective_shield_regen() * delta)
    shield_health = min(shield_health, _get_effective_shield_max())
    if repair_between_waves > 0.0 and base_health < base_max_health:
        var hull_per_sec: float = repair_between_waves / max(20.0, _estimate_typical_wave_duration_seconds()) * _get_power_multiplier("hull_regen")
        base_health = min(base_max_health, base_health + hull_per_sec * delta)
    var nuke_rate: float = float(_get_scaled_nuke_regen_gain()) / max(20.0, _estimate_typical_wave_duration_seconds())
    nuke_regen_bank += nuke_rate * delta
    while nuke_regen_bank >= 1.0:
        if remaining_nukes < nuke_max:
            nuke_regen_bank -= 1.0
            remaining_nukes += 1
        elif not enemies.is_empty():
            nuke_regen_bank -= 1.0
            _auto_launch_nuke()
        else:
            break
    if scrap_generation_per_second > 0.0:
        scrap_generation_accumulator += _get_effective_scrap_generation_per_second() * delta
        if scrap_generation_accumulator >= 1.0:
            var generated_scrap: int = int(floor(scrap_generation_accumulator))
            score += generated_scrap
            scrap_generation_accumulator -= float(generated_scrap)
    if fire_timer <= 0.0:
        _fire_player_bullet()
        fire_timer = max(0.045, _get_effective_fire_interval())
    if wave_spawn_timer <= 0.0 and not wave_spawn_queue.is_empty():
        var spawned_enemy: Dictionary = wave_spawn_queue.pop_front()
        enemies.append(spawned_enemy)
        var queued_spawn_delay: float = float(spawned_enemy.get("spawn_delay", -1.0))
        if queued_spawn_delay >= 0.0:
            wave_spawn_timer = queued_spawn_delay
        else:
            wave_spawn_timer = max(0.08, 0.44 - float(current_wave) * 0.012 + rng.randf_range(-0.025, 0.04))
    if boss_wave_stream_interval > 0.0 and _is_boss_wave(current_wave) and _boss_is_alive():
        boss_wave_stream_timer -= delta
        if boss_wave_stream_timer <= 0.0:
            _spawn_boss_wave_stream_enemy()
            boss_wave_stream_timer += boss_wave_stream_interval
    _process_support_units(delta)
    _process_temporary_defenses(delta)
    _process_player_bullets(delta)
    _process_nukes(delta)
    _process_enemies(delta)
    _process_countermeasure_sweep_visuals(delta)
    _process_countermeasure_regen_and_auto_sweep(delta)
    _process_enemy_projectiles(delta)
    _process_salvage_pickups(delta)
    _check_wave_clear()

func _process_support_units(delta: float) -> void:
    _process_towers(delta)
    _process_drones(delta)
    _process_helper_drones(delta)
    _process_tentacles(delta)
    _process_construction_drones(delta)

func _process_towers(delta: float) -> void:
    if tower_count <= 0:
        return
    _ensure_support_arrays()
    var tower_positions: Array[Vector2] = _get_tower_positions()
    for tower_index in range(tower_count):
        tower_fire_timers[tower_index] = float(tower_fire_timers[tower_index]) - delta
        if float(tower_fire_timers[tower_index]) > 0.0:
            continue
        var tower_pos: Vector2 = tower_positions[tower_index]
        var enemy_index: int = _find_nearest_enemy_index(tower_pos, _get_effective_tower_range())
        if enemy_index == -1:
            tower_fire_timers[tower_index] = 0.15
            continue
        var enemy_pos: Vector2 = enemies[enemy_index].get("pos", Vector2.ZERO)
        tower_fire_timers[tower_index] = max(0.12, _get_effective_tower_fire_interval())
        _spawn_support_effect(tower_pos, enemy_pos, TOWER_COLOR, SUPPORT_EFFECT_DURATION)
        _damage_enemy(enemy_index, _get_effective_tower_damage(), tower_pos, "tower")

func _process_drones(delta: float) -> void:
    if drone_count <= 0:
        return
    _ensure_support_arrays()
    var drone_positions: Array[Vector2] = _get_drone_positions()
    for drone_index in range(drone_count):
        drone_fire_timers[drone_index] = float(drone_fire_timers[drone_index]) - delta
        if float(drone_fire_timers[drone_index]) > 0.0:
            continue
        var drone_pos: Vector2 = drone_positions[drone_index]
        var enemy_index: int = _find_nearest_enemy_index(drone_pos, _get_effective_drone_range())
        if enemy_index == -1:
            drone_fire_timers[drone_index] = 0.12
            continue
        var enemy_pos: Vector2 = enemies[enemy_index].get("pos", Vector2.ZERO)
        drone_fire_timers[drone_index] = max(0.08, _get_effective_drone_fire_interval())
        _spawn_support_effect(drone_pos, enemy_pos, DRONE_COLOR, SUPPORT_EFFECT_DURATION)
        _damage_enemy(enemy_index, _get_effective_drone_damage(), drone_pos, "drone")

func _process_tentacles(delta: float) -> void:
    if tentacle_count <= 0:
        return
    _ensure_support_arrays()
    var anchors: Array[Vector2] = _get_tentacle_anchor_positions()
    for tentacle_index in range(tentacle_count):
        tentacle_cooldowns[tentacle_index] = float(tentacle_cooldowns[tentacle_index]) - delta
        if float(tentacle_cooldowns[tentacle_index]) > 0.0:
            continue
        var anchor: Vector2 = anchors[tentacle_index]
        var enemy_index: int = _find_nearest_enemy_index(anchor, _get_effective_tentacle_range())
        if enemy_index == -1:
            tentacle_cooldowns[tentacle_index] = 0.15
            continue
        var enemy: Dictionary = enemies[enemy_index]
        var enemy_pos: Vector2 = enemy.get("pos", Vector2.ZERO)
        enemy["slow_timer"] = max(float(enemy.get("slow_timer", 0.0)), 1.4)
        enemy["slow_amount"] = max(float(enemy.get("slow_amount", 0.0)), tentacle_slow * _get_power_multiplier("tentacles"))
        enemies[enemy_index] = enemy
        tentacle_cooldowns[tentacle_index] = max(0.18, _get_effective_tentacle_cooldown())
        _spawn_support_effect(anchor, enemy_pos, TENTACLE_COLOR, SUPPORT_EFFECT_DURATION * 1.4)
        _damage_enemy(enemy_index, _get_effective_tentacle_damage(), anchor, "tentacle")

func _process_helper_drones(delta: float) -> void:
    if helper_drone_count <= 0:
        return
    _ensure_support_arrays()
    var positions: Array[Vector2] = _get_helper_drone_positions()
    for helper_index in range(helper_drone_count):
        helper_fire_timers[helper_index] = float(helper_fire_timers[helper_index]) - delta
        if float(helper_fire_timers[helper_index]) > 0.0:
            continue
        var helper_pos: Vector2 = positions[helper_index]
        var enemy_index: int = _find_nearest_enemy_index(helper_pos, helper_drone_range * _get_power_multiplier("helpers"))
        if enemy_index == -1:
            helper_fire_timers[helper_index] = 0.12
            continue
        var enemy_pos: Vector2 = enemies[enemy_index].get("pos", Vector2.ZERO)
        helper_fire_timers[helper_index] = max(0.08, helper_drone_fire_interval / max(_get_power_multiplier("helpers"), 0.2))
        _spawn_support_effect(helper_pos, enemy_pos, DRONE_COLOR.lightened(0.18), SUPPORT_EFFECT_DURATION)
        _damage_enemy(enemy_index, helper_drone_damage * _get_power_multiplier("helpers"), helper_pos, "drone")

func _process_construction_drones(_delta: float) -> void:
    if construction_drone_count <= 0:
        return
    var build_power: float = _get_power_multiplier("construction")
    var allowed_turrets: int = int(round(float(temporary_turret_limit) * build_power))
    var allowed_shields: int = int(round(float(temporary_shield_limit) * build_power))
    while temporary_turrets.size() > allowed_turrets:
        temporary_turrets.remove_at(temporary_turrets.size() - 1)
    while temporary_shields.size() > allowed_shields:
        temporary_shields.remove_at(temporary_shields.size() - 1)
    while temporary_turrets.size() < allowed_turrets:
        temporary_turrets.append(_make_temporary_turret())
    while temporary_shields.size() < allowed_shields:
        temporary_shields.append(_make_temporary_shield())

func _process_temporary_defenses(delta: float) -> void:
    var build_power: float = _get_power_multiplier("construction")
    var build_speed: float = construction_build_rate * maxf(0.35, build_power) / CONSTRUCTION_BUILD_TIME_BASE
    for shield_index in range(temporary_shields.size() - 1, -1, -1):
        var shield: Dictionary = temporary_shields[shield_index]
        var shield_home_pos: Vector2 = _compute_construction_field_position(shield_index, temporary_shields.size(), true)
        var shield_bp: float = float(shield.get("build_progress", 1.0))
        shield["home_pos"] = shield_home_pos
        if shield_bp < 1.0:
            shield["pos"] = shield_home_pos
            var shield_next: float = minf(1.0, shield_bp + build_speed * delta)
            if shield_bp < 1.0 and shield_next >= 1.0:
                _spawn_floating_text("NODE READY", shield_home_pos + Vector2(0.0, -16.0), SHIELD_COLOR, 17)
            shield["build_progress"] = shield_next
            temporary_shields[shield_index] = shield
            continue
        var shield_target_pos: Vector2 = _get_temporary_shield_target_position(shield_home_pos)
        var shield_pos: Vector2 = shield.get("pos", shield_home_pos)
        shield["pos"] = shield_pos.move_toward(shield_target_pos, CONSTRUCTION_SHIELD_SHIFT_SPEED * delta)
        shield["age"] = float(shield.get("age", 0.0)) + delta
        shield["health"] = min(float(shield.get("max_health", 1.0)), float(shield.get("health", 0.0)) + temporary_shield_regen * build_power * delta)
        if float(shield.get("age", 0.0)) >= temporary_shield_duration or float(shield.get("health", 0.0)) <= 0.0:
            temporary_shields.remove_at(shield_index)
        else:
            temporary_shields[shield_index] = shield
    for turret_index in range(temporary_turrets.size() - 1, -1, -1):
        var turret: Dictionary = temporary_turrets[turret_index]
        var turret_home_pos: Vector2 = _compute_construction_field_position(turret_index, temporary_turrets.size(), false)
        var turret_bp: float = float(turret.get("build_progress", 1.0))
        turret["home_pos"] = turret_home_pos
        if turret_bp < 1.0:
            turret["pos"] = turret_home_pos
            var turret_next: float = minf(1.0, turret_bp + build_speed * delta)
            if turret_bp < 1.0 and turret_next >= 1.0:
                _spawn_floating_text("SHIP READY", turret_home_pos + Vector2(0.0, -16.0), TOWER_COLOR, 17)
            turret["build_progress"] = turret_next
            temporary_turrets[turret_index] = turret
            continue
        var turret_target_pos: Vector2 = _get_temporary_turret_target_position(turret_home_pos, turret_index, temporary_turrets.size())
        var turret_pos: Vector2 = turret.get("pos", turret_home_pos)
        var turret_vel: Vector2 = turret.get("vel", Vector2.ZERO)
        var standoff_distance: float = CONSTRUCTION_ATTACK_SHIP_BODY_LENGTH * CONSTRUCTION_ATTACK_SHIP_STANDOFF_MULT
        var engage_range: float = temporary_turret_range * CONSTRUCTION_TURRET_FIXED_RANGE_MULT
        var enemy_index: int = _find_nearest_enemy_index(turret_pos, engage_range)
        var fire_target_valid := false
        if enemy_index != -1:
            var enemy_pos: Vector2 = enemies[enemy_index].get("pos", Vector2.ZERO)
            var to_enemy: Vector2 = enemy_pos - turret_pos
            var dist_to_enemy: float = to_enemy.length()
            if dist_to_enemy > 0.001:
                var enemy_dir: Vector2 = to_enemy / dist_to_enemy
                var orbit_dir: float = float(turret.get("orbit_dir", 1.0))
                var radial_sign: float = signf(dist_to_enemy - standoff_distance)
                var radial_pull: Vector2 = enemy_dir * radial_sign * CONSTRUCTION_ATTACK_SHIP_ORBIT_BLEND
                var tangent: Vector2 = Vector2(-enemy_dir.y, enemy_dir.x) * orbit_dir
                var desired_dir: Vector2 = (tangent + radial_pull).normalized()
                if dist_to_enemy > standoff_distance * 1.35:
                    desired_dir = enemy_dir
                elif dist_to_enemy < standoff_distance * 0.72:
                    desired_dir = -enemy_dir
                var move_speed: float = CONSTRUCTION_ATTACK_SHIP_SPEED * maxf(0.45, build_power)
                var desired_vel: Vector2 = desired_dir * move_speed
                turret_vel = turret_vel.lerp(desired_vel, clampf(delta * 4.2, 0.0, 1.0))
                fire_target_valid = dist_to_enemy <= standoff_distance * 1.25 and dist_to_enemy >= standoff_distance * 0.55
        if not fire_target_valid:
            var fallback_vel: Vector2 = (turret_target_pos - turret_pos).normalized() * CONSTRUCTION_TURRET_ADVANCE_SPEED
            turret_vel = turret_vel.lerp(fallback_vel, clampf(delta * 2.8, 0.0, 1.0))
        turret_pos += turret_vel * delta
        turret["pos"] = turret_pos
        turret["vel"] = turret_vel
        turret["age"] = float(turret.get("age", 0.0)) + delta
        turret["cooldown"] = max(0.0, float(turret.get("cooldown", 0.0)) - delta)
        if float(turret.get("age", 0.0)) >= temporary_turret_duration or float(turret.get("health", 0.0)) <= 0.0:
            temporary_turrets.remove_at(turret_index)
            continue
        if float(turret.get("cooldown", 0.0)) <= 0.0:
            if enemy_index != -1 and fire_target_valid:
                var enemy_pos: Vector2 = enemies[enemy_index].get("pos", Vector2.ZERO)
                _spawn_support_effect(turret_pos, enemy_pos, TOWER_COLOR.lightened(0.18), SUPPORT_EFFECT_DURATION)
                _damage_enemy(enemy_index, temporary_turret_damage * build_power, turret_pos, "tower")
                turret["cooldown"] = temporary_turret_fire_interval / max(build_power, 0.2)
        temporary_turrets[turret_index] = turret

func _process_player_bullets(delta: float) -> void:
    for bullet_index in range(player_bullets.size() - 1, -1, -1):
        var bullet: Dictionary = player_bullets[bullet_index]
        bullet["lifetime"] = float(bullet.get("lifetime", 0.0)) - delta
        if bool(bullet.get("homing", false)):
            var tidx: int = int(bullet.get("homing_target_index", -1))
            if tidx < 0 or tidx >= enemies.size():
                tidx = _find_enemy_index_near_screen_point(aim_cursor_screen_pos, AIM_CURSOR_RADIUS * 4.8)
                bullet["homing_target_index"] = tidx
            if tidx >= 0 and tidx < enemies.size():
                var epos: Vector2 = enemies[tidx].get("pos", Vector2.ZERO)
                var bpos: Vector2 = bullet.get("pos", Vector2.ZERO)
                var desired: Vector2 = (epos - bpos).normalized() * bullet_speed
                var turn: float = float(bullet.get("homing_turn", 2.4)) * delta
                bullet["vel"] = bullet.get("vel", Vector2.ZERO).lerp(desired, clampf(turn, 0.0, 1.0))
        bullet["pos"] = bullet.get("pos", Vector2.ZERO) + bullet.get("vel", Vector2.ZERO) * delta
        if float(bullet.get("lifetime", 0.0)) <= 0.0 or _is_point_far_offscreen(bullet.get("pos", Vector2.ZERO), 50.0):
            player_bullets.remove_at(bullet_index)
            continue
        if _resolve_bullet_enemy_projectile_hits(bullet):
            player_bullets.remove_at(bullet_index)
            continue
        var consumed: bool = _resolve_bullet_enemy_hits(bullet)
        if consumed:
            player_bullets.remove_at(bullet_index)
        else:
            player_bullets[bullet_index] = bullet

func _process_nukes(delta: float) -> void:
    for nuke_index in range(nukes.size() - 1, -1, -1):
        var nuke: Dictionary = nukes[nuke_index]
        var target: Vector2 = nuke.get("target", Vector2.ZERO)
        var pos: Vector2 = nuke.get("pos", Vector2.ZERO)
        var to_target: Vector2 = target - pos
        if to_target.length() <= NUKE_SPEED * delta + 12.0:
            _trigger_explosion(target, nuke_blast_radius, nuke_damage, true)
            nukes.remove_at(nuke_index)
            continue
        nuke["vel"] = to_target.normalized() * NUKE_SPEED
        nuke["pos"] = pos + nuke.get("vel", Vector2.ZERO) * delta
        if _is_point_far_offscreen(nuke.get("pos", Vector2.ZERO), 80.0):
            _trigger_explosion(nuke.get("pos", Vector2.ZERO), nuke_blast_radius, nuke_damage, true)
            nukes.remove_at(nuke_index)
        else:
            nukes[nuke_index] = nuke

func _process_countermeasure_sweep_visuals(delta: float) -> void:
    for sweep_index in range(countermeasure_sweep_visuals.size() - 1, -1, -1):
        var sweep: Dictionary = countermeasure_sweep_visuals[sweep_index]
        sweep["age"] = float(sweep.get("age", 0.0)) + delta
        if float(sweep.get("age", 0.0)) >= float(sweep.get("duration", COUNTERMEASURE_SWEEP_VISUAL_DURATION)):
            countermeasure_sweep_visuals.remove_at(sweep_index)
        else:
            countermeasure_sweep_visuals[sweep_index] = sweep

func _countermeasure_regen_per_second() -> float:
    if countermeasures_rating <= 0.0:
        return 0.0
    var cm_mult: float = _get_power_multiplier("countermeasures")
    return COUNTERMEASURE_REGEN_COEFF * cm_mult * (1.0 + countermeasures_rating * 0.55)

func _enemy_projectiles_include_penetrator() -> bool:
    for projectile in enemy_projectiles:
        if String(projectile.get("team", "enemy")) != "enemy":
            continue
        if bool(projectile.get("penetrator", false)):
            return true
    return false

func _queue_purple_shot_countermeasure() -> void:
    purple_shot_countermeasure_timers.append(PURPLE_SHOT_COUNTERMEASURE_DELAY)

func _has_pending_purple_shots() -> bool:
    return _enemy_projectiles_include_penetrator()

func _try_consume_countermeasure_charge() -> bool:
    if countermeasure_charges < 1:
        return false
    countermeasure_charges -= 1
    _fire_countermeasure_sweep_clear()
    countermeasure_sweep_cooldown = 0.34
    return true

func _process_purple_shot_countermeasure_timers(delta: float) -> bool:
    var fired := false
    for timer_index in range(purple_shot_countermeasure_timers.size() - 1, -1, -1):
        var time_left: float = float(purple_shot_countermeasure_timers[timer_index]) - delta
        if time_left > 0.0:
            purple_shot_countermeasure_timers[timer_index] = time_left
            continue
        purple_shot_countermeasure_timers.remove_at(timer_index)
        if countermeasure_sweep_cooldown > 0.0:
            continue
        if not _has_pending_purple_shots():
            continue
        if _try_consume_countermeasure_charge():
            fired = true
            break
    return fired


func _penetrator_imminent_to_base() -> bool:
    var base_pos := _get_base_position()
    for projectile in enemy_projectiles:
        if String(projectile.get("team", "enemy")) != "enemy":
            continue
        if not bool(projectile.get("penetrator", false)):
            continue
        var ppos: Vector2 = projectile.get("pos", Vector2.ZERO)
        var vel: Vector2 = projectile.get("vel", Vector2.ZERO)
        var dist: float = ppos.distance_to(base_pos)
        if dist <= PENETRATOR_CM_IMMINENT_DIST:
            return true
        var speed: float = vel.length()
        if speed > 32.0 and dist / speed <= PENETRATOR_CM_IMMINENT_TIME:
            return true
    return false

func _enemy_projectiles_threat_count() -> int:
    var count := 0
    for projectile in enemy_projectiles:
        if String(projectile.get("team", "enemy")) == "enemy":
            count += 1
    return count

func _should_auto_fire_countermeasure_overflow() -> bool:
    if _enemy_projectiles_threat_count() <= 0:
        return false
    if _is_boss_wave(current_wave):
        return _enemy_projectiles_include_penetrator()
    return true

func _fire_countermeasure_sweep_clear() -> void:
    for projectile_index in range(enemy_projectiles.size() - 1, -1, -1):
        var projectile: Dictionary = enemy_projectiles[projectile_index]
        if String(projectile.get("team", "enemy")) != "enemy":
            continue
        intercepted_enemy_shot_damage += float(projectile.get("damage", 0.0))
        enemy_projectiles_destroyed += 1
        enemy_projectiles.remove_at(projectile_index)
    _play_red_sky_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.RED_SKY_NUKE_LAUNCH, -10.0, rng.randf_range(-0.05, 0.05))
    var viewport_size: Vector2 = get_viewport_rect().size
    var base_y: float = _get_base_position().y
    countermeasure_sweep_visuals.append({
        "age": 0.0,
        "duration": COUNTERMEASURE_SWEEP_VISUAL_DURATION,
        "y_top": viewport_size.y * 0.06,
        "y_bottom": base_y - 40.0,
    })
    _spawn_floating_text("CM SWEEP", Vector2(viewport_size.x * 0.5, viewport_size.y * 0.2), CM_SWEEP_COLOR, 26)

func _process_countermeasure_regen_and_auto_sweep(delta: float) -> void:
    countermeasure_sweep_cooldown = maxf(0.0, countermeasure_sweep_cooldown - delta)
    countermeasure_regen_bank += _countermeasure_regen_per_second() * delta

    if _process_purple_shot_countermeasure_timers(delta):
        return

    var threats: bool = _enemy_projectiles_threat_count() > 0
    if _is_boss_wave(current_wave) and threats and _penetrator_imminent_to_base():
        if _try_consume_countermeasure_charge():
            return

    while countermeasure_charges < COUNTERMEASURE_MAX_CHARGES and countermeasure_regen_bank >= 1.0:
        countermeasure_regen_bank -= 1.0
        countermeasure_charges += 1

    if countermeasure_sweep_cooldown > 0.0:
        if countermeasure_charges >= COUNTERMEASURE_MAX_CHARGES:
            countermeasure_regen_bank = minf(countermeasure_regen_bank, 1.0)
        return

    if countermeasure_charges >= COUNTERMEASURE_MAX_CHARGES:
        if countermeasure_regen_bank >= 1.0 and _should_auto_fire_countermeasure_overflow():
            countermeasure_regen_bank -= 1.0
            _fire_countermeasure_sweep_clear()
            countermeasure_sweep_cooldown = 0.34
        countermeasure_regen_bank = minf(countermeasure_regen_bank, 1.0)

func _process_enemies(delta: float) -> void:
    var base_pos := _get_base_position()
    var viewport := get_viewport_rect().size
    for enemy_index in range(enemies.size() - 1, -1, -1):
        var enemy: Dictionary = enemies[enemy_index]
        enemy["lifetime"] = float(enemy.get("lifetime", 0.0)) + delta
        enemy["slow_timer"] = max(0.0, float(enemy.get("slow_timer", 0.0)) - delta)
        if float(enemy.get("slow_timer", 0.0)) <= 0.0:
            enemy["slow_amount"] = 0.0
        var pos: Vector2 = enemy.get("pos", Vector2.ZERO)
        var vel: Vector2 = enemy.get("vel", Vector2.ZERO)
        var enemy_type: String = String(enemy.get("type", "raider"))
        var desired_velocity := Vector2.ZERO
        var lifetime: float = float(enemy.get("lifetime", 0.0))
        var movement_seed: float = float(enemy.get("movement_seed", 0.0))
        var lane_offset: float = float(enemy.get("lane_offset", 0.0))
        var slow_mult: float = 1.0 - clampf(float(enemy.get("slow_amount", 0.0)), 0.0, 0.75)
        var forward_to_base: Vector2 = (base_pos - pos).normalized()
        if forward_to_base == Vector2.ZERO:
            forward_to_base = Vector2.DOWN
        var lateral: Vector2 = Vector2(-forward_to_base.y, forward_to_base.x)

        match enemy_type:
            BOSS_TYPE:
                var boss_wave: int = int(enemy.get("wave", current_wave))
                var boss_center := Vector2(
                    clampf(base_pos.x + lane_offset * 0.16 + sin(lifetime * 0.18 + movement_seed) * 118.0, 140.0, viewport.x - 140.0),
                    float(enemy.get("standoff_y", viewport.y * 0.13))
                )
                var boss_target := boss_center + Vector2(cos(lifetime * 0.42 + movement_seed), sin(lifetime * 0.42 + movement_seed) * 0.2) * float(enemy.get("orbit_radius", 96.0))
                var boss_to_target: Vector2 = boss_target - pos
                if boss_to_target.length() > 14.0:
                    desired_velocity = boss_to_target.normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["boss_burst_timer"] = float(enemy.get("boss_burst_timer", 0.0)) + delta
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    var pattern: int = int(enemy.get("boss_pattern", 0)) % 5
                    enemy["boss_pattern"] = pattern + 1
                    match pattern:
                        0:
                            _spawn_enemy_projectile_spread(pos, (base_pos - pos).normalized(), boss_wave + 11, 6, 0.58, {"radius": 17.0, "speed": 228.0 + float(boss_wave) * 7.0, "damage": 20.0 + float(boss_wave) * 2.4, "lifetime": 6.4})
                        1:
                            _spawn_enemy_projectile(
                                pos,
                                (base_pos - pos).normalized(),
                                boss_wave + 12,
                                {"radius": 22.0, "speed": 168.0 + float(boss_wave) * 5.0, "damage": 34.0 + float(boss_wave) * 3.6, "lifetime": 7.2, "penetrator": true}
                            )
                            _spawn_floating_text("PENETRATOR", pos + Vector2(0.0, -28.0), Color(1.0, 0.45, 0.82, 1.0), 20)
                        2:
                            for ring_i in range(9):
                                var ring_angle: float = float(ring_i) / 9.0 * TAU + lifetime
                                _spawn_enemy_projectile(pos, Vector2.RIGHT.rotated(ring_angle), boss_wave + 8, {"radius": 11.0, "speed": 198.0 + float(boss_wave) * 5.5, "damage": 12.0 + float(boss_wave) * 1.6, "lifetime": 5.2})
                        3:
                            _spawn_enemy_projectile_spread(pos, (base_pos - pos).normalized(), boss_wave + 10, 4, 0.22, {"radius": 14.0, "speed": 268.0 + float(boss_wave) * 8.0, "damage": 16.0 + float(boss_wave) * 2.0, "lifetime": 5.0})
                            _spawn_enemy_projectile_spread(pos, Vector2.UP.rotated(0.35), boss_wave + 9, 3, 0.5, {"radius": 13.0, "speed": 232.0 + float(boss_wave) * 7.0, "damage": 15.0 + float(boss_wave) * 1.9, "lifetime": 5.4})
                        _:
                            _spawn_enemy_projectile_spread(pos, (base_pos - pos).normalized(), boss_wave + 13, 7, 0.72, {"radius": 16.0, "speed": 252.0 + float(boss_wave) * 7.5, "damage": 18.0 + float(boss_wave) * 2.2, "lifetime": 6.0})
                            if rng.randf() < 0.42:
                                _spawn_enemy_projectile(
                                    pos + Vector2(0.0, 22.0),
                                    (base_pos - pos).normalized().rotated(rng.randf_range(-0.12, 0.12)),
                                    boss_wave + 11,
                                    {"radius": 19.0, "speed": 152.0 + float(boss_wave) * 4.0, "damage": 30.0 + float(boss_wave) * 3.2, "lifetime": 7.0, "penetrator": true}
                                )
                    enemy["shoot_timer"] = max(0.42, 1.05 - float(boss_wave) * 0.018 + rng.randf_range(0.02, 0.16))
            "carrier":
                var carrier_orbit_angle: float = lifetime * 0.85 + movement_seed * 0.65
                var carrier_center := Vector2(
                    clampf(base_pos.x + lane_offset * 0.55 + sin(lifetime * 0.42 + movement_seed) * 120.0, 90.0, viewport.x - 90.0),
                    float(enemy.get("standoff_y", viewport.y * 0.17)) + sin(lifetime * 0.75 + movement_seed) * 20.0
                )
                var carrier_target := carrier_center + Vector2(cos(carrier_orbit_angle), sin(carrier_orbit_angle) * 0.48) * float(enemy.get("orbit_radius", 132.0))
                desired_velocity = (carrier_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile(
                        pos,
                        (base_pos - pos).normalized(),
                        int(enemy.get("wave", current_wave)) + 4,
                        {"radius": 16.0, "speed": 220.0 + float(current_wave) * 10.0, "damage": 16.0 + float(current_wave) * 2.3, "lifetime": 5.8}
                    )
                    enemy["shoot_timer"] = max(1.15, 2.2 - float(enemy.get("wave", current_wave)) * 0.025 + rng.randf_range(0.0, 0.24))
                enemy["spawn_timer"] = float(enemy.get("spawn_timer", 1.0)) - delta
                if float(enemy.get("spawn_timer", 0.0)) <= 0.0 and int(enemy.get("spawned_count", 0)) < int(enemy.get("max_spawned", 0)):
                    _spawn_carrier_dronelet(enemy)
                    enemy["spawned_count"] = int(enemy.get("spawned_count", 0)) + 1
                    enemy["spawn_timer"] = rng.randf_range(0.95, 1.45)
            "command_ship":
                var command_orbit_angle: float = lifetime * 0.62 + movement_seed * 0.55
                var command_center := Vector2(
                    clampf(base_pos.x + lane_offset * 0.4 + sin(lifetime * 0.34 + movement_seed) * 108.0, 92.0, viewport.x - 92.0),
                    float(enemy.get("standoff_y", viewport.y * 0.18)) + sin(lifetime * 0.55 + movement_seed) * 16.0
                )
                var command_target := command_center + Vector2(cos(command_orbit_angle), sin(command_orbit_angle) * 0.35) * float(enemy.get("orbit_radius", 136.0))
                desired_velocity = (command_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile_spread(pos, (base_pos - pos).normalized(), int(enemy.get("wave", current_wave)) + 6, 3, 0.28, {"radius": 15.0, "speed": 250.0 + float(current_wave) * 8.0, "damage": 18.0 + float(current_wave) * 2.2, "lifetime": 6.1})
                    enemy["shoot_timer"] = max(1.05, 1.95 - float(enemy.get("wave", current_wave)) * 0.018 + rng.randf_range(0.04, 0.18))
                enemy["spawn_timer"] = float(enemy.get("spawn_timer", 1.8)) - delta
                if float(enemy.get("spawn_timer", 0.0)) <= 0.0 and int(enemy.get("spawned_count", 0)) < int(enemy.get("max_spawned", 0)):
                    _spawn_command_ship_reinforcement(enemy)
                    enemy["spawned_count"] = int(enemy.get("spawned_count", 0)) + 1
                    enemy["spawn_timer"] = rng.randf_range(1.6, 2.3)
            "dreadnought":
                var dread_center := Vector2(
                    clampf(base_pos.x + lane_offset * 0.22 + sin(lifetime * 0.22 + movement_seed) * 58.0, 110.0, viewport.x - 110.0),
                    float(enemy.get("standoff_y", viewport.y * 0.14))
                )
                var dread_target := dread_center + Vector2(cos(lifetime * 0.42 + movement_seed), sin(lifetime * 0.42 + movement_seed) * 0.18) * float(enemy.get("orbit_radius", 92.0))
                var dread_to_target: Vector2 = dread_target - pos
                if dread_to_target.length() > 12.0:
                    desired_velocity = dread_to_target.normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile_spread(pos, (base_pos - pos).normalized(), int(enemy.get("wave", current_wave)) + 9, 5, 0.46, {"radius": 20.0, "speed": 214.0 + float(current_wave) * 6.0, "damage": 24.0 + float(current_wave) * 2.8, "lifetime": 6.6})
                    enemy["shoot_timer"] = max(1.3, 2.45 - float(enemy.get("wave", current_wave)) * 0.015 + rng.randf_range(0.08, 0.24))
            "siege":
                var siege_center := Vector2(
                    clampf(base_pos.x + lane_offset * 0.35 + sin(lifetime * 0.4 + movement_seed) * 90.0, 80.0, viewport.x - 80.0),
                    float(enemy.get("standoff_y", viewport.y * 0.22))
                )
                var siege_target := siege_center + Vector2(cos(lifetime * 0.8 + movement_seed), sin(lifetime * 0.8 + movement_seed) * 0.24) * float(enemy.get("orbit_radius", 96.0))
                var siege_to_target: Vector2 = siege_target - pos
                if siege_to_target.length() > 16.0:
                    desired_velocity = siege_to_target.normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile(
                        pos,
                        (base_pos - pos).normalized(),
                        int(enemy.get("wave", current_wave)) + 5,
                        {"radius": 18.0, "speed": 198.0 + float(current_wave) * 7.0, "damage": 18.0 + float(current_wave) * 2.5, "lifetime": 6.0}
                    )
                    enemy["shoot_timer"] = max(1.25, 2.35 - float(enemy.get("wave", current_wave)) * 0.02 + rng.randf_range(0.05, 0.24))
            "artillery":
                var artillery_center := Vector2(
                    clampf(base_pos.x + lane_offset * 0.28 + sin(lifetime * 0.28 + movement_seed) * 54.0, 82.0, viewport.x - 82.0),
                    float(enemy.get("standoff_y", viewport.y * 0.2))
                )
                var artillery_target := artillery_center + Vector2(cos(lifetime * 0.56 + movement_seed), sin(lifetime * 0.56 + movement_seed) * 0.18) * float(enemy.get("orbit_radius", 86.0))
                desired_velocity = (artillery_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile_spread(pos, (base_pos - pos).normalized(), int(enemy.get("wave", current_wave)) + 5, 3, 0.34, {"radius": 16.0, "speed": 205.0 + float(current_wave) * 6.0, "damage": 17.0 + float(current_wave) * 2.2, "lifetime": 6.0})
                    enemy["shoot_timer"] = max(1.12, 2.1 - float(enemy.get("wave", current_wave)) * 0.014 + rng.randf_range(0.06, 0.2))
            "brute":
                var brute_target := base_pos + lateral * sin(lifetime * 1.25 + movement_seed) * float(enemy.get("drift_strength", 32.0))
                desired_velocity = (brute_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
            "skimmer":
                var skim_height: float = float(enemy.get("standoff_y", viewport.y * 0.24)) + sin(lifetime * 1.8 + movement_seed) * 28.0
                var skim_target := Vector2(
                    clampf(base_pos.x + lane_offset * 0.85 + sin(lifetime * 2.6 + movement_seed) * float(enemy.get("orbit_radius", 118.0)), 42.0, viewport.x - 42.0),
                    skim_height
                )
                desired_velocity = (skim_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile(
                        pos,
                        (base_pos - pos).normalized(),
                        int(enemy.get("wave", current_wave)),
                        {"radius": 10.0, "speed": 286.0 + float(current_wave) * 12.0, "damage": 7.0 + float(current_wave) * 1.4, "lifetime": 4.6}
                    )
                    enemy["shoot_timer"] = max(0.55, 1.25 - float(enemy.get("wave", current_wave)) * 0.015 + rng.randf_range(-0.02, 0.08))
            "gunship":
                var orbit_angle: float = lifetime * 1.4 + movement_seed
                var orbit_center := Vector2(
                    clampf(base_pos.x + lane_offset + sin(lifetime * 0.5 + movement_seed) * 82.0, 60.0, viewport.x - 60.0),
                    float(enemy.get("standoff_y", viewport.y * 0.32)) + sin(lifetime * 1.0 + movement_seed * 1.2) * 32.0
                )
                var target_pos := orbit_center + Vector2(cos(orbit_angle), sin(orbit_angle) * 0.66) * float(enemy.get("orbit_radius", 60.0))
                var to_target: Vector2 = target_pos - pos
                if to_target.length() > 20.0:
                    desired_velocity = to_target.normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile(pos, (base_pos - pos).normalized(), int(enemy.get("wave", current_wave)))
                    enemy["shoot_timer"] = max(0.72, 1.7 - float(enemy.get("wave", current_wave)) * 0.04 + rng.randf_range(-0.04, 0.16))
            "destroyer":
                var destroyer_orbit: float = lifetime * 0.92 + movement_seed
                var destroyer_center := Vector2(
                    clampf(base_pos.x + lane_offset * 0.5 + sin(lifetime * 0.32 + movement_seed) * 72.0, 72.0, viewport.x - 72.0),
                    float(enemy.get("standoff_y", viewport.y * 0.24)) + sin(lifetime * 0.75 + movement_seed) * 18.0
                )
                var destroyer_target := destroyer_center + Vector2(cos(destroyer_orbit), sin(destroyer_orbit) * 0.4) * float(enemy.get("orbit_radius", 92.0))
                var destroyer_to_target: Vector2 = destroyer_target - pos
                if destroyer_to_target.length() > 16.0:
                    desired_velocity = destroyer_to_target.normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile_spread(pos, (base_pos - pos).normalized(), int(enemy.get("wave", current_wave)) + 4, 3, 0.18, {"radius": 14.0, "speed": 246.0 + float(current_wave) * 8.0, "damage": 16.0 + float(current_wave) * 2.1, "lifetime": 5.8})
                    enemy["shoot_timer"] = max(0.88, 1.65 - float(enemy.get("wave", current_wave)) * 0.02 + rng.randf_range(0.02, 0.16))
            "dronelet":
                var dronelet_target := base_pos + lateral * sin(lifetime * 4.6 + movement_seed) * float(enemy.get("drift_strength", 140.0)) * 0.25
                desired_velocity = (dronelet_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
            "interceptor":
                var intercept_height: float = float(enemy.get("standoff_y", viewport.y * 0.21)) + sin(lifetime * 2.3 + movement_seed) * 18.0
                var intercept_target := Vector2(
                    clampf(base_pos.x + lane_offset * 0.74 + sin(lifetime * 3.0 + movement_seed) * float(enemy.get("orbit_radius", 112.0)), 44.0, viewport.x - 44.0),
                    intercept_height
                )
                desired_velocity = (intercept_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile_spread(pos, (base_pos - pos).normalized(), int(enemy.get("wave", current_wave)) + 1, 2, 0.16, {"radius": 9.0, "speed": 310.0 + float(current_wave) * 12.0, "damage": 8.0 + float(current_wave) * 1.5, "lifetime": 4.4})
                    enemy["shoot_timer"] = max(0.52, 1.18 - float(enemy.get("wave", current_wave)) * 0.018 + rng.randf_range(-0.02, 0.06))
            "runner":
                var escape_target := Vector2(
                    clampf(base_pos.x + lane_offset * 0.3 + sin(lifetime * 5.0 + movement_seed) * float(enemy.get("drift_strength", 120.0)), 32.0, viewport.x - 32.0),
                    viewport.y + 80.0
                )
                desired_velocity = (escape_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
            "bomber":
                var sweep_target := Vector2(
                    clampf(base_pos.x + sin(lifetime * 0.8 + movement_seed) * 220.0 * float(enemy.get("arc_direction", 1.0)), 80.0, viewport.x - 80.0),
                    viewport.y * 0.44 + cos(lifetime * 1.1 + movement_seed) * 42.0
                )
                var should_dive: bool = lifetime > 2.2 or float(enemy.get("health", 1.0)) < 0.6 * _get_enemy_max_health(enemy)
                var bomber_target := (base_pos + lateral * sin(lifetime * 2.0 + movement_seed) * 54.0) if should_dive else sweep_target
                desired_velocity = (bomber_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult
                enemy["shoot_timer"] = float(enemy.get("shoot_timer", 1.0)) - delta
                if float(enemy.get("shoot_timer", 0.0)) <= 0.0:
                    _spawn_enemy_projectile(pos, (base_pos - pos).normalized(), int(enemy.get("wave", current_wave)) + 2)
                    enemy["shoot_timer"] = max(0.95, 2.0 - float(enemy.get("wave", current_wave)) * 0.025 + rng.randf_range(0.0, 0.18))
            _:
                var raider_target := base_pos + lateral * sin(lifetime * 2.3 + movement_seed) * float(enemy.get("drift_strength", 70.0)) + Vector2(0.0, cos(lifetime * 1.5 + movement_seed) * 18.0)
                desired_velocity = (raider_target - pos).normalized() * float(enemy.get("speed", 100.0)) * slow_mult

        vel = vel.lerp(desired_velocity, clampf(delta * 1.8, 0.0, 1.0))
        pos += vel * delta
        enemy["vel"] = vel
        enemy["pos"] = pos

        if enemy_type != BOSS_TYPE and pos.distance_to(base_pos) <= BASE_COLLISION_RADIUS + float(enemy.get("radius", 18.0)):
            _damage_base(float(enemy.get("contact_damage", 8.0)), pos)
            _spawn_floating_text("HIT", pos, Color(1.0, 0.45, 0.35, 1.0), 26)
            enemies.remove_at(enemy_index)
            continue

        if enemy_type == "runner" and pos.y > viewport.y + float(enemy.get("radius", 18.0)) + 24.0:
            escape_scores += 1
            _spawn_floating_text("SLIPPED", Vector2(clampf(pos.x, 80.0, viewport.x - 80.0), viewport.y - GROUND_HEIGHT - 24.0), Color(1.0, 0.52, 0.38, 1.0), 24)
            enemies.remove_at(enemy_index)
            continue

        if _is_point_far_offscreen(pos, 120.0):
            enemies.remove_at(enemy_index)
            continue

        enemies[enemy_index] = enemy

func _get_enemy_max_health(enemy: Dictionary) -> float:
    return float(enemy.get("max_health", enemy.get("health", 1.0)))

func _try_projectile_hit_temporary_construction(projectile_index: int, projectile_pos: Vector2, projectile_radius: float) -> bool:
    var projectile: Dictionary = enemy_projectiles[projectile_index]
    if bool(projectile.get("penetrator", false)):
        return false
    for turret_index in range(temporary_turrets.size() - 1, -1, -1):
        var turret: Dictionary = temporary_turrets[turret_index]
        if float(turret.get("build_progress", 1.0)) < 1.0:
            continue
        var turret_pos: Vector2 = turret.get("pos", Vector2.ZERO)
        if projectile_pos.distance_to(turret_pos) > projectile_radius + CONSTRUCTION_TEMP_HIT_RADIUS_TURRET:
            continue
        var blast_pos: Vector2 = turret_pos + Vector2(rng.randf_range(-4.0, 4.0), rng.randf_range(-4.0, 4.0))
        explosions.append({
            "pos": blast_pos,
            "radius": 14.0,
            "max_radius": 56.0,
            "age": 0.0,
            "duration": 0.22,
            "color": EXPLOSION_COLOR
        })
        _spawn_floating_text("SHIP LOST", turret_pos + Vector2(0.0, -18.0), Color(1.0, 0.52, 0.38, 1.0), 22)
        temporary_turrets.remove_at(turret_index)
        enemy_projectiles.remove_at(projectile_index)
        return true
    for shield_index in range(temporary_shields.size() - 1, -1, -1):
        var shield: Dictionary = temporary_shields[shield_index]
        if float(shield.get("build_progress", 1.0)) < 1.0:
            continue
        var shield_pos: Vector2 = shield.get("pos", Vector2.ZERO)
        if projectile_pos.distance_to(shield_pos) > projectile_radius + CONSTRUCTION_TEMP_HIT_RADIUS_SHIELD:
            continue
        var sblast: Vector2 = shield_pos + Vector2(rng.randf_range(-3.0, 3.0), rng.randf_range(-3.0, 3.0))
        explosions.append({
            "pos": sblast,
            "radius": 12.0,
            "max_radius": 48.0,
            "age": 0.0,
            "duration": 0.2,
            "color": Color(SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, 0.55)
        })
        _spawn_floating_text("NODE LOST", shield_pos + Vector2(0.0, -20.0), SHIELD_COLOR, 22)
        temporary_shields.remove_at(shield_index)
        enemy_projectiles.remove_at(projectile_index)
        return true
    return false

func _process_enemy_projectiles(delta: float) -> void:
    var base_pos := _get_base_position()
    for projectile_index in range(enemy_projectiles.size() - 1, -1, -1):
        var projectile: Dictionary = enemy_projectiles[projectile_index]
        projectile["lifetime"] = float(projectile.get("lifetime", 0.0)) - delta
        projectile["pos"] = projectile.get("pos", Vector2.ZERO) + projectile.get("vel", Vector2.ZERO) * delta
        var projectile_pos: Vector2 = projectile.get("pos", Vector2.ZERO)
        var projectile_radius: float = float(projectile.get("radius", 10.0))
        var team: String = String(projectile.get("team", "enemy"))
        if float(projectile.get("lifetime", 0.0)) <= 0.0 or _is_point_far_offscreen(projectile_pos, 60.0):
            enemy_projectiles.remove_at(projectile_index)
            continue

        if team == "enemy" and _try_projectile_hit_temporary_construction(projectile_index, projectile_pos, projectile_radius):
            continue

        if team == "enemy" and projectile_pos.distance_to(base_pos) <= BASE_COLLISION_RADIUS + projectile_radius:
            var ignore_shields_hit: bool = bool(projectile.get("ignore_shields", false))
            var is_penetrator_hit: bool = bool(projectile.get("penetrator", false))
            if not ignore_shields_hit and not is_penetrator_hit and rng.randf() < projectile_redirect_chance:
                deflected_threat_damage += float(projectile.get("damage", 8.0))
                projectile["team"] = "player"
                projectile["vel"] = _get_reflected_projectile_direction(projectile_pos) * max(320.0, projectile.get("vel", Vector2.ZERO).length())
                projectile["damage"] = float(projectile.get("damage", 8.0)) * 0.9
                projectile["lifetime"] = 1.75
                enemy_projectiles_deflected += 1
                enemy_projectiles[projectile_index] = projectile
                _spawn_floating_text("REDIRECT", projectile_pos, DRONE_COLOR, 22)
                continue
            _damage_base(float(projectile.get("damage", 8.0)), projectile_pos, ignore_shields_hit)
            enemy_projectiles.remove_at(projectile_index)
            continue

        if team == "player":
            var hit_enemy_index := _find_enemy_hit_index(projectile_pos, projectile_radius)
            if hit_enemy_index != -1:
                _spawn_support_effect(projectile_pos, enemies[hit_enemy_index].get("pos", Vector2.ZERO), DRONE_COLOR, SUPPORT_EFFECT_DURATION)
                _damage_enemy(hit_enemy_index, float(projectile.get("damage", gun_damage)), projectile_pos, "deflection")
                enemy_projectiles.remove_at(projectile_index)
                continue

        enemy_projectiles[projectile_index] = projectile

func _resolve_bullet_enemy_projectile_hits(bullet: Dictionary) -> bool:
    var bullet_pos: Vector2 = bullet.get("pos", Vector2.ZERO)
    var bullet_radius: float = float(bullet.get("radius", BULLET_RADIUS))
    for projectile_index in range(enemy_projectiles.size() - 1, -1, -1):
        var projectile: Dictionary = enemy_projectiles[projectile_index]
        if String(projectile.get("team", "enemy")) != "enemy":
            continue
        if bool(projectile.get("penetrator", false)):
            continue
        if bullet_pos.distance_to(projectile.get("pos", Vector2.ZERO)) > bullet_radius + float(projectile.get("radius", 10.0)):
            continue
        if rng.randf() < projectile_redirect_chance:
            deflected_threat_damage += float(projectile.get("damage", 0.0))
            projectile["team"] = "player"
            projectile["vel"] = _get_reflected_projectile_direction(projectile.get("pos", Vector2.ZERO)) * max(360.0, projectile.get("vel", Vector2.ZERO).length())
            projectile["damage"] = max(float(projectile.get("damage", 0.0)), float(bullet.get("damage", gun_damage)) * 0.75)
            projectile["lifetime"] = max(0.7, float(projectile.get("lifetime", 0.0)))
            enemy_projectiles_deflected += 1
            enemy_projectiles[projectile_index] = projectile
            _spawn_floating_text("DEFLECT", bullet_pos, DRONE_COLOR, 22)
        else:
            intercepted_enemy_shot_damage += float(projectile.get("damage", 0.0))
            enemy_projectiles_destroyed += 1
            enemy_projectiles.remove_at(projectile_index)
            _spawn_floating_text("POP", bullet_pos, Color(1.0, 0.82, 0.6, 1.0), 22)
        return true
    return false

func _resolve_bullet_enemy_hits(bullet: Dictionary) -> bool:
    var bullet_pos: Vector2 = bullet.get("pos", Vector2.ZERO)
    var bullet_radius: float = float(bullet.get("radius", BULLET_RADIUS))
    for enemy_index in range(enemies.size() - 1, -1, -1):
        var enemy: Dictionary = enemies[enemy_index]
        if bullet_pos.distance_to(enemy.get("pos", Vector2.ZERO)) > bullet_radius + float(enemy.get("radius", 18.0)):
            continue
        var damage_amount: float = float(bullet.get("damage", gun_damage))
        _damage_enemy(enemy_index, damage_amount, bullet_pos, "gun")
        if float(bullet.get("blast_radius", 0.0)) > 0.0:
            _trigger_explosion(
                bullet_pos,
                float(bullet.get("blast_radius", 0.0)),
                damage_amount * 0.42 * float(bullet.get("blast_damage_scale", 1.0)),
                false
            )
        var remaining_pierce: int = int(bullet.get("pierce_remaining", 0))
        if remaining_pierce > 0:
            bullet["pierce_remaining"] = remaining_pierce - 1
            return false
        return true
    return false

func _find_enemy_hit_index(position: Vector2, radius: float) -> int:
    for enemy_index in range(enemies.size() - 1, -1, -1):
        if position.distance_to(enemies[enemy_index].get("pos", Vector2.ZERO)) <= radius + float(enemies[enemy_index].get("radius", 18.0)):
            return enemy_index
    return -1

func _find_enemy_index_near_screen_point(screen_point: Vector2, radius: float) -> int:
    var best_index := -1
    var best_distance := INF
    for enemy_index in range(enemies.size()):
        var enemy_pos: Vector2 = enemies[enemy_index].get("pos", Vector2.ZERO)
        var er: float = float(enemies[enemy_index].get("radius", 18.0))
        var distance: float = enemy_pos.distance_to(screen_point)
        if distance <= radius + er and distance < best_distance:
            best_distance = distance
            best_index = enemy_index
    return best_index

func _fire_player_bullet() -> void:
    var direction := _get_pointer_direction()
    if direction == Vector2.ZERO:
        direction = Vector2.UP
    var start_pos := _get_base_position() + direction * (BASE_RADIUS * 0.82)
    var is_crit: bool = rng.randf() < crit_chance
    var damage_amount: float = gun_damage * _get_gun_power_multiplier() * (crit_bonus if is_crit else 1.0)
    var homing := false
    var target_index := -1
    if homing_missile_level > 0:
        homing_shot_cycle += 1
        var cadence: int = maxi(2, 5 - mini(3, homing_missile_level / 2))
        if homing_shot_cycle % cadence == 0:
            homing = true
            target_index = _find_enemy_index_near_screen_point(aim_cursor_screen_pos, AIM_CURSOR_RADIUS * 4.2)
    player_bullets.append({
        "pos": start_pos,
        "vel": direction * bullet_speed,
        "radius": BULLET_RADIUS,
        "lifetime": BULLET_LIFETIME,
        "damage": damage_amount,
        "pierce_remaining": bullet_pierce,
        "blast_radius": bullet_blast_radius,
        "blast_damage_scale": bullet_blast_damage_scale,
        "crit": is_crit,
        "homing": homing,
        "homing_target_index": target_index,
        "homing_turn": (2.4 + float(homing_missile_level) * 0.55) * _get_power_multiplier("homing_missiles")
    })
    shots_fired += 1
    _play_red_sky_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.RED_SKY_GUN_FIRE)

func _spawn_enemy_projectile(origin: Vector2, direction: Vector2, wave: int, options: Dictionary = {}) -> void:
    var normalized_direction := direction.normalized()
    if normalized_direction == Vector2.ZERO:
        normalized_direction = Vector2.DOWN
    var is_penetrator: bool = bool(options.get("penetrator", false))
    enemy_projectiles.append({
        "pos": origin,
        "vel": normalized_direction * float(options.get("speed", 248.0 + float(wave) * 14.0)) * enemy_projectile_speed_scale,
        "radius": float(options.get("radius", 12.0)),
        "lifetime": float(options.get("lifetime", 5.0)),
        "damage": float(options.get("damage", 8.0 + float(wave) * 1.7)) * enemy_projectile_damage_scale,
        "mass": 2.0 + float(wave) * 0.22,
        "team": "enemy",
        "ignore_shields": bool(options.get("ignore_shields", false)),
        "penetrator": is_penetrator
    })
    if is_penetrator:
        saw_purple_shots_this_run = true
        _queue_purple_shot_countermeasure()

func _spawn_enemy_projectile_spread(origin: Vector2, direction: Vector2, wave: int, shot_count: int, spread_radians: float, options: Dictionary = {}) -> void:
    var normalized_direction := direction.normalized()
    if normalized_direction == Vector2.ZERO:
        normalized_direction = Vector2.DOWN
    var center_angle: float = normalized_direction.angle()
    var total_shots: int = maxi(1, shot_count)
    for shot_index in range(total_shots):
        var t: float = 0.0 if total_shots == 1 else float(shot_index) / float(total_shots - 1)
        var angle_offset: float = lerpf(-spread_radians * 0.5, spread_radians * 0.5, t)
        _spawn_enemy_projectile(origin, Vector2.RIGHT.rotated(center_angle + angle_offset), wave, options)

func _spawn_carrier_dronelet(carrier: Dictionary) -> void:
    var carrier_pos: Vector2 = carrier.get("pos", Vector2.ZERO)
    var spawned_enemy: Dictionary = _build_enemy_def("dronelet", int(carrier.get("wave", current_wave)), int(carrier.get("spawned_count", 0)))
    spawned_enemy["pos"] = carrier_pos + Vector2(rng.randf_range(-34.0, 34.0), rng.randf_range(-20.0, 20.0))
    spawned_enemy["vel"] = Vector2(rng.randf_range(-24.0, 24.0), rng.randf_range(8.0, 34.0))
    spawned_enemy["lane_offset"] = float(carrier.get("lane_offset", 0.0)) + rng.randf_range(-90.0, 90.0)
    enemies.append(spawned_enemy)
    _spawn_floating_text("LAUNCH", carrier_pos + Vector2(0.0, 18.0), Color(1.0, 0.74, 0.38, 1.0), 20)

func _spawn_command_ship_reinforcement(command_ship: Dictionary) -> void:
    var ship_pos: Vector2 = command_ship.get("pos", Vector2.ZERO)
    var reinforcement_type: String = "interceptor" if rng.randf() < 0.5 else "dronelet"
    var spawned_enemy: Dictionary = _build_enemy_def(reinforcement_type, int(command_ship.get("wave", current_wave)), int(command_ship.get("spawned_count", 0)))
    spawned_enemy["pos"] = ship_pos + Vector2(rng.randf_range(-48.0, 48.0), rng.randf_range(-18.0, 26.0))
    spawned_enemy["vel"] = Vector2(rng.randf_range(-22.0, 22.0), rng.randf_range(10.0, 38.0))
    spawned_enemy["lane_offset"] = float(command_ship.get("lane_offset", 0.0)) + rng.randf_range(-110.0, 110.0)
    enemies.append(spawned_enemy)
    _spawn_floating_text("ESCORT", ship_pos + Vector2(0.0, 20.0), Color(0.9, 0.82, 0.54, 1.0), 20)

func _damage_enemy(enemy_index: int, damage_amount: float, hit_position: Vector2, source: String) -> void:
    if enemy_index < 0 or enemy_index >= enemies.size():
        return
    var enemy: Dictionary = enemies[enemy_index]
    if String(enemy.get("type", "")) == BOSS_TYPE:
        var boss_pos: Vector2 = enemy.get("pos", Vector2.ZERO)
        var boss_radius: float = float(enemy.get("radius", 62.0))
        var weak_hit := false
        var spot_count := 4
        for spot_index in range(spot_count):
            var spot_angle: float = float(enemy.get("movement_seed", 0.0)) + float(enemy.get("lifetime", 0.0)) * 1.05 + float(spot_index) * TAU / float(spot_count)
            var spot_pos: Vector2 = boss_pos + Vector2.RIGHT.rotated(spot_angle) * boss_radius * 0.64
            if hit_position.distance_to(spot_pos) <= boss_radius * 0.24:
                weak_hit = true
                break
        damage_amount *= 1.0 if weak_hit else BOSS_BODY_DAMAGE_FRACTION
    var previous_health: float = float(enemy.get("health", 1.0))
    var applied: float = min(previous_health, damage_amount)
    enemy["health"] = previous_health - damage_amount
    damage_dealt += applied
    match source:
        "tower":
            damage_dealt_tower += applied
        "drone":
            damage_dealt_drone += applied
        "tentacle":
            damage_dealt_tentacle += applied
        "nuke":
            damage_dealt_nuke += applied
        "blast":
            damage_dealt_blast += applied
        "deflection":
            damage_dealt_deflection += applied
        _:
            damage_dealt_gun += applied
    var impulse_dir: Vector2 = (enemy.get("pos", Vector2.ZERO) - hit_position).normalized()
    if impulse_dir == Vector2.ZERO:
        impulse_dir = Vector2.UP
    enemy["vel"] = enemy.get("vel", Vector2.ZERO) + impulse_dir * 120.0 / max(float(enemy.get("mass", 1.0)), 0.1)
    if float(enemy.get("health", 0.0)) <= 0.0:
        _kill_enemy(enemy_index, source)
    else:
        enemies[enemy_index] = enemy

func _trigger_explosion(position: Vector2, blast_radius: float, damage_amount: float, is_nuke: bool) -> void:
    explosions.append({
        "pos": position,
        "radius": 16.0,
        "max_radius": blast_radius,
        "age": 0.0,
        "duration": 0.42 if is_nuke else 0.22,
        "color": EXPLOSION_COLOR
    })
    if is_nuke:
        _play_red_sky_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.RED_SKY_NUKE_EXPLOSION)
    for enemy_index in range(enemies.size() - 1, -1, -1):
        var enemy: Dictionary = enemies[enemy_index]
        var enemy_pos: Vector2 = enemy.get("pos", Vector2.ZERO)
        var distance: float = position.distance_to(enemy_pos)
        if distance > blast_radius + float(enemy.get("radius", 18.0)):
            continue
        var falloff: float = clampf(1.0 - distance / max(blast_radius, 1.0), 0.18, 1.0)
        _damage_enemy(enemy_index, damage_amount * falloff, position, "nuke" if is_nuke else "blast")
    for projectile_index in range(enemy_projectiles.size() - 1, -1, -1):
        var projectile: Dictionary = enemy_projectiles[projectile_index]
        if position.distance_to(projectile.get("pos", Vector2.ZERO)) <= blast_radius + float(projectile.get("radius", 10.0)):
            intercepted_enemy_shot_damage += float(projectile.get("damage", 0.0))
            enemy_projectiles_destroyed += 1
            enemy_projectiles.remove_at(projectile_index)
    _spawn_floating_text("NUKE" if is_nuke else "BLAST", position, Color(1.0, 0.82, 0.6, 1.0), 30)

func _process_explosions(delta: float) -> void:
    for explosion_index in range(explosions.size() - 1, -1, -1):
        var explosion: Dictionary = explosions[explosion_index]
        explosion["age"] = float(explosion.get("age", 0.0)) + delta
        var progress: float = clampf(float(explosion.get("age", 0.0)) / max(float(explosion.get("duration", 0.2)), 0.01), 0.0, 1.0)
        explosion["radius"] = lerpf(16.0, float(explosion.get("max_radius", 120.0)), progress)
        if progress >= 1.0:
            explosions.remove_at(explosion_index)
        else:
            explosions[explosion_index] = explosion

func _process_support_effects(delta: float) -> void:
    for effect_index in range(support_effects.size() - 1, -1, -1):
        var effect: Dictionary = support_effects[effect_index]
        effect["age"] = float(effect.get("age", 0.0)) + delta
        if float(effect.get("age", 0.0)) >= float(effect.get("duration", SUPPORT_EFFECT_DURATION)):
            support_effects.remove_at(effect_index)
        else:
            support_effects[effect_index] = effect

func _kill_enemy(enemy_index: int, source: String) -> void:
    var enemy: Dictionary = enemies[enemy_index]
    _play_red_sky_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.RED_SKY_ENEMY_KILL)
    var enemy_type: String = String(enemy.get("type", "raider"))
    total_kills += 1
    enemy_kill_counts[enemy_type] = int(enemy_kill_counts.get(enemy_type, 0)) + 1
    match source:
        "tower":
            tower_kills += 1
        "drone":
            drone_kills += 1
        "tentacle":
            tentacle_kills += 1
    var value: int = max(1, int(round(float(enemy.get("score_value", 0)) * salvage_multiplier)))
    _spawn_salvage(enemy.get("pos", Vector2.ZERO), value)
    if source == "nuke":
        explosions.append({
            "pos": enemy.get("pos", Vector2.ZERO),
            "radius": 18.0,
            "max_radius": 84.0,
            "age": 0.0,
            "duration": 0.18,
            "color": EXPLOSION_COLOR
        })
    enemies.remove_at(enemy_index)

func _damage_base(amount: float, hit_position: Vector2, ignore_shields: bool = false) -> void:
    var remaining_damage: float = amount
    if ignore_shields:
        var cm_mitigation: float = clampf(
            countermeasures_rating * 1.12 + (_get_power_multiplier("countermeasures") - POWER_WHEEL_FUNCTIONAL_MIN) * 0.48,
            0.0,
            0.82
        )
        remaining_damage *= (1.0 - cm_mitigation)
    if not ignore_shields:
        for shield_index in range(temporary_shields.size() - 1, -1, -1):
            var shield: Dictionary = temporary_shields[shield_index]
            var shield_pos: Vector2 = shield.get("pos", Vector2.ZERO)
            if hit_position.distance_to(shield_pos) > 74.0:
                continue
            var absorbed_by_node: float = min(float(shield.get("shield", 0.0)), remaining_damage)
            shield["shield"] = float(shield.get("shield", 0.0)) - absorbed_by_node
            remaining_damage -= absorbed_by_node
            if float(shield.get("shield", 0.0)) <= 0.0:
                shield["health"] = float(shield.get("health", 0.0)) - (remaining_damage * 0.5)
            if float(shield.get("health", 0.0)) <= 0.0:
                temporary_shields.remove_at(shield_index)
            else:
                temporary_shields[shield_index] = shield
            if remaining_damage <= 0.0:
                _spawn_floating_text("NODE", hit_position, SHIELD_COLOR, 20)
                return
            break
    if not ignore_shields and shield_health > 0.0:
        var absorbed: float = min(shield_health, remaining_damage)
        shield_health -= absorbed
        remaining_damage -= absorbed
        shield_damage_absorbed += absorbed
        shield_regen_cooldown = shield_regen_delay
        if absorbed > 0.0:
            _spawn_floating_text("SHIELD", hit_position, SHIELD_COLOR, 20)
    if remaining_damage <= 0.0:
        return
    hull_damage_mitigated += remaining_damage * damage_reduction
    var final_damage: float = remaining_damage * (1.0 - damage_reduction)
    base_health = max(0.0, base_health - final_damage)
    damage_taken += final_damage
    _spawn_floating_text("-%d" % int(round(final_damage)), hit_position.lerp(_get_base_position(), 0.4), Color(1.0, 0.48, 0.42, 1.0), 24)
    if base_health <= 0.0:
        _start_defeat_sequence("Base destroyed.")

func _start_defeat_sequence(reason: String) -> void:
    if run_state == RUN_STATES.DEFEAT or run_state == RUN_STATES.SUMMARY:
        return
    run_state = RUN_STATES.DEFEAT
    Global.game_state = Util.GAME_STATES.UPGRADES
    pending_finish_reason = reason
    defeat_sequence_timer = 0.0
    defeat_explosion_timer = 0.0
    wave_spawn_queue.clear()
    _reset_boss_wave_stream_state()
    player_bullets.clear()
    nukes.clear()
    countermeasure_sweep_visuals.clear()
    upgrade_panel.hide()
    _spawn_floating_text("COMMAND LOST", _get_base_position() + Vector2(0.0, -112.0), Color(1.0, 0.86, 0.72, 1.0), 34)
    _spawn_floating_text("HOLD FAILED", _get_base_position() + Vector2(0.0, -76.0), Color(1.0, 0.52, 0.44, 1.0), 24)
    for _burst_index in range(6):
        _spawn_defeat_explosion()
    _play_defeat_sound()
    _refresh_mouse_capture_state()

func _check_wave_clear() -> void:
    if run_state != RUN_STATES.RUNNING:
        return
    if not wave_spawn_queue.is_empty():
        return
    if not enemies.is_empty():
        return
    if not enemy_projectiles.is_empty():
        return
    waves_cleared = current_wave
    RED_SKY_PROGRESS.track_wave_cleared_runtime(waves_cleared, run_start_wave, career_best_wave_at_run_start, score)
    if waves_cleared > 0 and waves_cleared % 5 == 0:
        _spawn_floating_text(_trf("SECTOR %d SECURED", [waves_cleared]), get_viewport_rect().size * Vector2(0.5, 0.2), Color(0.72, 0.94, 1.0, 1.0), 30)
    if _is_multi_mode_challenge_active() and not multi_mode_step_reported and waves_cleared >= int(multi_mode_step.get("target_wave", 999999)):
        multi_mode_step_reported = true
        if _is_open_pit_defense_challenge_active():
            _complete_open_pit_defense_challenge(true, {"waves_cleared": waves_cleared, "target_wave": int(multi_mode_step.get("target_wave", 0))})
            return
        MULTI_GAME_MODE.complete_current_step(true, {"waves_cleared": waves_cleared, "target_wave": int(multi_mode_step.get("target_wave", 0))})
        return
    _show_upgrade_panel()

func _show_upgrade_panel() -> void:
    _play_red_sky_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.RED_SKY_WAVE_CLEAR, -2.0, rng.randf_range(-0.04, 0.06))
    run_state = RUN_STATES.UPGRADE
    Global.game_state = Util.GAME_STATES.UPGRADES
    _bank_remaining_salvage(wave_auto_bank_ratio)
    _award_wave_clear_bonus()
    base_health = min(base_max_health, base_health + repair_between_waves * _get_power_multiplier("hull_regen"))
    if shield_max > 0.0:
        shield_health = min(_get_effective_shield_max(), shield_health + repair_between_waves * 0.5 * _get_power_multiplier("hull_regen"))
    if _is_multi_mode_challenge_active() and bool(multi_mode_step.get("disable_wave_upgrades", false)):
        run_state = RUN_STATES.RUNNING
        Global.game_state = Util.GAME_STATES.PLAYING
        _start_wave(current_wave + 1)
        _refresh_mouse_capture_state()
        return
    _show_upgrade_offer_panel("Wave %d Cleared" % current_wave, "Pick one.")

func _show_start_upgrade_panel() -> void:
    run_state = RUN_STATES.UPGRADE
    Global.game_state = Util.GAME_STATES.UPGRADES
    var used_picks: int = used_start_upgrade_picks + 1
    var total_picks: int = max(1, max(0, run_start_wave - 1))
    _show_upgrade_offer_panel(
        tr("Command Calibration"),
        _trf("Pick prep upgrade %d/%d before wave %d.", [used_picks, total_picks, run_start_wave])
    )

func _show_upgrade_offer_panel(title: String, description: String) -> void:
    offered_wave_upgrades = _roll_wave_upgrade_offers(min(level_up_choice_count, min(max_wave_upgrade_choices, upgrade_buttons.size())))
    _update_upgrade_offer_layout(offered_wave_upgrades.size())
    upgrade_title_label.text = title
    upgrade_desc_label.text = description
    if power_customize_button != null:
        power_customize_button.visible = true
    for button_index in range(upgrade_buttons.size()):
        var button: Button = upgrade_buttons[button_index]
        if button_index >= offered_wave_upgrades.size():
            button.hide()
            button.icon = null
            _apply_upgrade_button_rarity_style(button, 1)
            continue
        var offered_upgrade: Dictionary = offered_wave_upgrades[button_index]
        var upgrade_id: String = str(offered_upgrade.get("id", ""))
        var offer_tier: int = int(offered_upgrade.get("tier", 1))
        button.show()
        button.text = RED_SKY_DATA.get_wave_upgrade_button_text(upgrade_id, upgrade_power_multiplier, offer_tier)
        button.icon = _get_upgrade_icon_texture(upgrade_id)
        _apply_upgrade_button_rarity_style(button, offer_tier)
    upgrade_panel.show()
    _refresh_upgrade_panel_layout(offered_wave_upgrades.size())
    _refresh_mouse_capture_state()

func _roll_wave_upgrade_offers(count: int) -> Array[Dictionary]:
    var candidates: Array[Dictionary] = []
    var runtime_flags := {"shield_max": shield_max}
    for upgrade_def in RED_SKY_DATA.get_wave_upgrade_catalog():
        if RED_SKY_DATA.can_offer_wave_upgrade(upgrade_def, current_wave, wave_upgrade_levels, meta_bonuses, runtime_flags):
            candidates.append(upgrade_def)
    var chosen_ids: Array[String] = []
    var offers: Array[Dictionary] = []
    var max_to_pick: int = min(count, candidates.size())
    while offers.size() < max_to_pick:
        var picked_id: String = _pick_weighted_upgrade(candidates, chosen_ids)
        if picked_id.is_empty():
            break
        offers.append({
            "id": picked_id,
            "tier": RED_SKY_DATA.roll_wave_offer_tier(RED_SKY_DATA.get_wave_upgrade_definition(picked_id), meta_bonuses, rng)
        })
        chosen_ids.append(picked_id)
    return offers

func _pick_weighted_upgrade(candidates: Array[Dictionary], chosen: Array[String]) -> String:
    var total_weight := 0.0
    var weighted_entries: Array[Dictionary] = []
    for upgrade_def in candidates:
        var upgrade_id: String = str(upgrade_def.get("id", ""))
        if chosen.has(upgrade_id):
            continue
        var weight: float = RED_SKY_DATA.get_offer_weight(upgrade_def, wave_upgrade_levels, meta_bonuses)
        total_weight += weight
        weighted_entries.append({"id": upgrade_id, "weight": weight})
    if total_weight <= 0.0:
        return ""
    var roll: float = rng.randf() * total_weight
    for entry in weighted_entries:
        roll -= float(entry.get("weight", 0.0))
        if roll <= 0.0:
            return str(entry.get("id", ""))
    return str(weighted_entries.back().get("id", ""))

func _on_wave_upgrade_button_pressed(button_index: int) -> void:
    if button_index < 0 or button_index >= offered_wave_upgrades.size():
        return
    _apply_wave_upgrade(offered_wave_upgrades[button_index])

func _apply_wave_upgrade(offered_upgrade: Dictionary) -> void:
    var upgrade_id: String = str(offered_upgrade.get("id", ""))
    var offer_tier: int = int(offered_upgrade.get("tier", 1))
    if upgrade_id.is_empty():
        return
    var next_level: int = int(wave_upgrade_levels.get(upgrade_id, 0)) + 1
    wave_upgrade_levels[upgrade_id] = next_level
    var scaled_effects: Dictionary = RED_SKY_DATA.get_scaled_wave_effects(upgrade_id, upgrade_power_multiplier, offer_tier)
    _apply_effect_bundle(scaled_effects)
    _spawn_floating_text(str(RED_SKY_DATA.get_wave_upgrade_definition(upgrade_id).get("label", "UPGRADE")).to_upper(), get_viewport_rect().size * Vector2(0.5, 0.3), Color(1.0, 0.86, 0.56, 1.0), 26)
    if pending_start_upgrade_picks > 0:
        pending_start_upgrade_picks -= 1
        used_start_upgrade_picks += 1
        if pending_start_upgrade_picks > 0:
            _show_start_upgrade_panel()
        else:
            upgrade_panel.hide()
            if power_customize_panel != null:
                power_customize_panel.hide()
            run_state = RUN_STATES.RUNNING
            Global.game_state = Util.GAME_STATES.PLAYING
            _start_wave(current_wave)
            _refresh_mouse_capture_state()
        return
    upgrade_panel.hide()
    if power_customize_panel != null:
        power_customize_panel.hide()
    run_state = RUN_STATES.RUNNING
    Global.game_state = Util.GAME_STATES.PLAYING
    _start_wave(current_wave + 1)
    _refresh_mouse_capture_state()

func _apply_effect_bundle(bundle: Dictionary) -> void:
    var add_effects: Dictionary = bundle.get("add", {})
    for key_variant in add_effects.keys():
        var key: String = str(key_variant)
        var amount: float = float(add_effects[key_variant])
        match key:
            "gun_damage":
                gun_damage += amount
            "bullet_speed":
                bullet_speed += amount
            "base_max_health":
                base_max_health += amount
                base_health += amount
            "repair":
                base_health = min(base_max_health, base_health + amount)
            "shield_max":
                shield_max += amount
                shield_health += amount
            "shield_fill":
                shield_health = min(shield_max, shield_health + amount)
            "shield_regen":
                shield_regen_rate += amount
            "nukes":
                remaining_nukes += _round_upgrade_count(amount)
                remaining_nukes = mini(remaining_nukes, nuke_max)
            "nuke_max":
                nuke_max += _round_upgrade_count(amount)
                nuke_max = maxi(nuke_max, 1)
                remaining_nukes = mini(remaining_nukes, nuke_max)
            "nuke_regen_per_wave":
                nuke_regen_per_wave += _round_upgrade_count(amount)
                nuke_regen_per_wave = maxi(nuke_regen_per_wave, 1)
            "bullet_pierce":
                bullet_pierce += _round_upgrade_count(amount)
            "bullet_blast_radius":
                bullet_blast_radius += amount
            "crit_chance":
                crit_chance += amount
            "tower_count":
                tower_count += _round_upgrade_count(amount)
            "tower_range":
                tower_range += amount
            "drone_count":
                drone_count += _round_upgrade_count(amount)
            "drone_range":
                drone_range += amount
            "tentacle_count":
                tentacle_count += _round_upgrade_count(amount)
            "tentacle_slow":
                tentacle_slow += amount
            "construction_drone_count":
                construction_drone_count += _round_upgrade_count(amount)
            "temporary_turret_limit":
                temporary_turret_limit += _round_upgrade_count(amount)
            "temporary_turret_duration":
                temporary_turret_duration += amount
            "temporary_shield_limit":
                temporary_shield_limit += _round_upgrade_count(amount)
            "temporary_shield_capacity":
                temporary_shield_capacity += amount
            "temporary_shield_duration":
                temporary_shield_duration += amount
            "helper_drone_count":
                helper_drone_count += _round_upgrade_count(amount)
            "helper_drone_range":
                helper_drone_range += amount
            "collector_bot_count":
                collector_bot_count += _round_upgrade_count(amount)
            "scrap_generation_per_second":
                scrap_generation_per_second += amount
            "projectile_redirect_chance":
                projectile_redirect_chance = min(0.85, projectile_redirect_chance + amount)
            "pickup_radius":
                pickup_radius += amount
            "salvage_lifetime":
                salvage_lifetime += amount
            "wave_scrap_bonus":
                wave_scrap_bonus += amount
            "wave_auto_bank_ratio":
                wave_auto_bank_ratio = min(1.0, wave_auto_bank_ratio + amount)
            "level_up_choice_count":
                level_up_choice_count = clampi(level_up_choice_count + _round_upgrade_count(amount), 3, max_wave_upgrade_choices)
            "homing_missile_level":
                homing_missile_level += _round_upgrade_count(amount)
            "countermeasures_rating":
                countermeasures_rating += amount
    countermeasures_rating = maxf(0.2, countermeasures_rating)
    _ensure_support_arrays()
    _rebuild_power_slot_order()

    var mult_effects: Dictionary = bundle.get("mult", {})
    for key_variant in mult_effects.keys():
        var key: String = str(key_variant)
        var multiplier: float = float(mult_effects[key_variant])
        match key:
            "fire_rate":
                fire_interval /= multiplier
            "nuke_damage":
                nuke_damage *= multiplier
            "nuke_radius":
                nuke_blast_radius *= multiplier
            "bullet_blast_damage":
                bullet_blast_damage_scale *= multiplier
            "crit_bonus":
                crit_bonus *= multiplier
            "tower_damage":
                tower_damage *= multiplier
            "tower_fire_rate":
                tower_fire_interval /= multiplier
            "drone_damage":
                drone_damage *= multiplier
            "drone_fire_rate":
                drone_fire_interval /= multiplier
            "drone_speed":
                drone_speed *= multiplier
            "tentacle_damage":
                tentacle_damage *= multiplier
            "tentacle_range":
                tentacle_range *= multiplier
            "construction_build_rate":
                construction_build_rate *= multiplier
            "temporary_turret_damage":
                temporary_turret_damage *= multiplier
            "helper_drone_damage":
                helper_drone_damage *= multiplier
            "helper_drone_fire_rate":
                helper_drone_fire_interval /= multiplier
            "helper_drone_speed":
                helper_drone_speed *= multiplier
            "collector_bot_speed":
                collector_bot_speed *= multiplier
            "salvage_multiplier":
                salvage_multiplier *= multiplier
            "enemy_count_scale":
                enemy_count_scale *= multiplier
            "enemy_speed_scale":
                enemy_speed_scale *= multiplier
            "enemy_projectile_speed_scale":
                enemy_projectile_speed_scale *= multiplier
            "enemy_projectile_damage_scale":
                enemy_projectile_damage_scale *= multiplier
            "elite_spawn_scale":
                elite_spawn_scale *= multiplier
            "heavy_enemy_health_scale":
                heavy_enemy_health_scale *= multiplier
            "heavy_enemy_damage_scale":
                heavy_enemy_damage_scale *= multiplier
            "apex_enemy_health_scale":
                apex_enemy_health_scale *= multiplier
            "apex_enemy_damage_scale":
                apex_enemy_damage_scale *= multiplier
            "upgrade_power_multiplier":
                upgrade_power_multiplier *= multiplier

    remaining_nukes = mini(remaining_nukes, nuke_max)

func _finish_run(reason: String, from_pause_end_run: bool = false) -> void:
    if run_state == RUN_STATES.SUMMARY:
        return
    if _is_multi_mode_challenge_active() and not multi_mode_step_reported:
        multi_mode_step_reported = true
        if _is_open_pit_defense_challenge_active():
            run_state = RUN_STATES.SUMMARY
            _complete_open_pit_defense_challenge(false, {"reason": reason, "waves_cleared": waves_cleared})
            return
        run_state = RUN_STATES.SUMMARY
        MULTI_GAME_MODE.complete_current_step(false, {"reason": reason, "waves_cleared": waves_cleared})
        return
    run_state = RUN_STATES.SUMMARY
    showing_pre_run_panel = false
    Global.game_state = Util.GAME_STATES.UPGRADES
    upgrade_panel.hide()
    _bank_remaining_salvage(1.0)
    last_run_results = _build_run_results(reason, from_pause_end_run)
    RED_SKY_PROGRESS.track_run_end(run_start_wave, persistent_data, waves_cleared, score, reason)
    persistent_data = RED_SKY_PROGRESS.apply_run_results(last_run_results)
    summary_title_label.text = tr("Red Sky Defense Summary")
    summary_stats_label.text = str(last_run_results.get("summary_stats_text", ""))
    continue_button.text = tr("Return to Upgrades")
    retry_button.text = tr("Run Again")
    _refresh_start_wave_selector()
    _show_post_run_summary(last_run_results)
    summary_charts_row.show()
    summary_damage_chart.show()
    summary_panel.show()
    _summary_pointer_recovery_frames_remaining = SUMMARY_POINTER_RECOVERY_FRAMES
    _refresh_mouse_capture_state()
    _apply_summary_pointer_recovery()

func _apply_summary_pointer_recovery() -> void:
    if run_state != RUN_STATES.SUMMARY:
        _summary_pointer_recovery_frames_remaining = 0
        return
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _sync_virtual_cursor_for_red_sky_ui()
    if VirtualCursor != null and ControllerIcons != null \
        and ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        VirtualCursor.activate_for_controller()
        if continue_button != null and is_instance_valid(continue_button):
            VirtualCursor.move_to_control(continue_button)

func _build_run_results(reason: String, from_pause_end_run: bool = false) -> Dictionary:
    var wallet_gain: int = RED_SKY_DATA.calculate_meta_scrap_reward({
        "score": score,
        "waves_cleared": waves_cleared,
        "meta_reward_multiplier": meta_reward_multiplier
    }, {"meta_reward_multiplier": meta_reward_multiplier})
    var wallet_bonus: int = max(0, wallet_gain - score)
    var waves_cleared_this_run: int = max(0, waves_cleared - max(run_start_wave - 1, 0))
    var previous_best_wave: int = max(0, int(persistent_data.get("best_wave", 0)))
    var projected_best_wave: int = max(previous_best_wave, waves_cleared)
    var gem_reward_count: int = CROSS_GAME_BONUSES.count_red_sky_wave_rewards_between(previous_best_wave, projected_best_wave)
    var gem_reward_line: String = CROSS_GAME_BONUSES.get_reward_summary_line(Util.ACTIVE_GAME_RED_SKY, gem_reward_count)
    var payout_chart: Array[Dictionary] = []
    payout_chart.append({
        "label": "Scrap banked (run)",
        "money": float(score),
        "color": Color(0.96, 0.78, 0.42, 1.0)
    })
    if wallet_bonus > 0:
        payout_chart.append({
            "label": "Meta multiplier bonus",
            "money": float(wallet_bonus),
            "color": Color(0.42, 0.88, 0.62, 1.0)
        })
    var combat_chart: Array[Dictionary] = [
        {"label": "Enemy kills", "money": float(total_kills), "color": Color(0.45, 0.87, 0.99, 1.0)},
        {"label": "Waves cleared (run)", "money": float(waves_cleared_this_run), "color": Color(0.83, 0.74, 1.0, 1.0)}
    ]
    var damage_dealt_breakdown: Array[Dictionary] = []
    _append_summary_chart_row_if_positive(damage_dealt_breakdown, tr("Main gun"), damage_dealt_gun, Color(1.0, 0.52, 0.36, 1.0))
    _append_summary_chart_row_if_positive(damage_dealt_breakdown, tr("Turrets"), damage_dealt_tower, Color(0.72, 0.58, 1.0, 1.0))
    _append_summary_chart_row_if_positive(damage_dealt_breakdown, tr("Drones"), damage_dealt_drone, Color(0.42, 0.88, 0.95, 1.0))
    _append_summary_chart_row_if_positive(damage_dealt_breakdown, tr("Tentacles"), damage_dealt_tentacle, Color(0.52, 0.94, 0.62, 1.0))
    _append_summary_chart_row_if_positive(damage_dealt_breakdown, tr("Nukes"), damage_dealt_nuke, Color(1.0, 0.82, 0.38, 1.0))
    _append_summary_chart_row_if_positive(damage_dealt_breakdown, tr("Splash / blast"), damage_dealt_blast, Color(1.0, 0.68, 0.48, 1.0))
    _append_summary_chart_row_if_positive(damage_dealt_breakdown, tr("Redirected shots"), damage_dealt_deflection, Color(0.55, 0.72, 1.0, 1.0))
    var damage_prevented_breakdown: Array[Dictionary] = []
    _append_summary_chart_row_if_positive(damage_prevented_breakdown, tr("Shield absorbed"), shield_damage_absorbed, Color(0.38, 0.78, 1.0, 1.0))
    _append_summary_chart_row_if_positive(damage_prevented_breakdown, tr("Armor / hull mitigation"), hull_damage_mitigated, Color(0.65, 0.7, 0.82, 1.0))
    _append_summary_chart_row_if_positive(damage_prevented_breakdown, tr("Shots destroyed"), intercepted_enemy_shot_damage, Color(0.48, 0.92, 0.88, 1.0))
    _append_summary_chart_row_if_positive(damage_prevented_breakdown, tr("Shots redirected (threat)"), deflected_threat_damage, Color(0.78, 0.92, 0.55, 1.0))
    var summary_text := _trf("%s — Cleared %d waves this run — +%d scrap to wallet", [reason, waves_cleared_this_run, wallet_gain])
    if gem_reward_line != "":
        summary_text += "\n" + gem_reward_line
    var summary_stats_text := _trf("Best score: %d    Best wave: %d    Total runs: %d    Shots fired: %d", [
        max(int(persistent_data.get("best_score", 0)), score),
        max(int(persistent_data.get("best_wave", 0)), waves_cleared),
        int(persistent_data.get("runs", 0)) + 1,
        shots_fired
    ])
    var show_purple_shot_death_hint: bool = saw_purple_shots_this_run and reason == "Base destroyed."
    var summary_view_model := {
        "reason": reason,
        "waves_cleared_this_run": waves_cleared_this_run,
        "wallet_gain": wallet_gain,
        "run_scrap": score,
        "wallet_bonus": wallet_bonus,
        "gem_reward_count": gem_reward_count,
        "gem_reward_line": gem_reward_line,
        "show_purple_shot_death_hint": show_purple_shot_death_hint,
        "show_cursor_escape_hint": from_pause_end_run
    }
    return {
        "reason": reason,
        "start_wave": run_start_wave,
        "waves_cleared_this_run": waves_cleared_this_run,
        "waves_cleared": waves_cleared,
        "final_wave": current_wave,
        "score": score,
        "wallet_bonus": wallet_bonus,
        "wallet_gain": wallet_gain,
        "gem_reward_count": gem_reward_count,
        "gem_reward_line": gem_reward_line,
        "damage_dealt": int(round(damage_dealt)),
        "damage_taken": int(round(damage_taken)),
        "shield_damage_absorbed": int(round(shield_damage_absorbed)),
        "nukes_launched": nukes_launched,
        "enemy_projectiles_destroyed": enemy_projectiles_destroyed,
        "enemy_projectiles_deflected": enemy_projectiles_deflected,
        "escape_scores": escape_scores,
        "shots_fired": shots_fired,
        "total_kills": total_kills,
        "tower_kills": tower_kills,
        "drone_kills": drone_kills,
        "tentacle_kills": tentacle_kills,
        "salvage_collected": salvage_collected,
        "salvage_lost": salvage_lost,
        "bonus_scrap_earned": bonus_scrap_earned,
        "prep_picks_used": used_start_upgrade_picks,
        "enemy_kill_counts": enemy_kill_counts.duplicate(true),
        "summary_text": summary_text,
        "summary_stats_text": summary_stats_text,
        "payout_breakdown_chart": payout_chart,
        "combat_breakdown_chart": combat_chart,
        "damage_dealt_breakdown": damage_dealt_breakdown,
        "damage_prevented_breakdown": damage_prevented_breakdown,
        "damage_dealt_gun": damage_dealt_gun,
        "damage_dealt_tower": damage_dealt_tower,
        "damage_dealt_drone": damage_dealt_drone,
        "damage_dealt_tentacle": damage_dealt_tentacle,
        "damage_dealt_nuke": damage_dealt_nuke,
        "damage_dealt_blast": damage_dealt_blast,
        "damage_dealt_deflection": damage_dealt_deflection,
        "hull_damage_mitigated": hull_damage_mitigated,
        "intercepted_enemy_shot_damage": intercepted_enemy_shot_damage,
        "deflected_threat_damage": deflected_threat_damage,
        "summary_view_model": summary_view_model
    }

func _refresh_ui() -> void:
    if run_start_wave > 1:
        wave_label.text = _trf("Wave %d  Clear %d  Start %d", [current_wave, waves_cleared, run_start_wave])
    else:
        wave_label.text = _trf("Wave %d  Clear %d", [current_wave, waves_cleared])
    if shield_max > 0.0:
        health_label.text = _trf("Hull %d/%d  Shield %d/%d", [int(round(base_health)), int(round(base_max_health)), int(round(shield_health)), int(round(_get_effective_shield_max()))])
    else:
        health_label.text = _trf("Hull %d/%d", [int(round(base_health)), int(round(base_max_health))])
    score_label.text = _trf("Scrap %s", [Util.get_number_short_text(score)])
    var nuke_per_sec: float = float(_get_scaled_nuke_regen_gain()) / max(20.0, _estimate_typical_wave_duration_seconds())
    nukes_label.text = _trf("Nukes %d/%d  (%.2f/s)", [remaining_nukes, nuke_max, nuke_per_sec])
    if countermeasures_hud_label != null:
        var cm_pct: int = int(round(countermeasure_regen_bank * 100.0))
        countermeasures_hud_label.text = _trf("CM %d/%d  burst %d%%", [countermeasure_charges, COUNTERMEASURE_MAX_CHARGES, cm_pct])
    if power_wheel_label != null:
        var lines: Array[String] = []
        for slot_key in power_slot_order:
            lines.append("%s %d%%" % [slot_key.replace("_", " ").capitalize(), int(round(float(power_display_values.get(slot_key, 1.0)) * 100.0))])
        power_wheel_label.text = "Power Wheel\n" + "\n".join(lines)
    if power_warning_label != null:
        var warnings: Array[String] = []
        for slot_key in power_slot_order:
            if float(power_display_values.get(slot_key, 1.0)) < 0.2:
                warnings.append(slot_key.replace("_", " ").capitalize())
        if run_state == RUN_STATES.RUNNING and _is_boss_wave(current_wave + 1):
            warnings.append(tr("Bias Countermeasures before boss"))
        power_warning_label.text = "" if warnings.is_empty() else "Low power: %s" % ", ".join(warnings)

func _update_upgrade_offer_layout(visible_count: int) -> void:
    if upgrade_buttons_grid == null:
        return
    var clamped_count: int = maxi(1, visible_count)
    var panel_size: Vector2 = _get_upgrade_panel_target_size()
    var available_width: float = maxf(220.0, panel_size.x - 52.0)
    if clamped_count <= 1 or available_width < 470.0:
        upgrade_buttons_grid.columns = 1
    elif clamped_count >= 13 and available_width >= 1100.0:
        upgrade_buttons_grid.columns = 4
    elif clamped_count >= 7 and available_width >= 860.0:
        upgrade_buttons_grid.columns = 3
    elif clamped_count >= 5 or available_width < 760.0:
        upgrade_buttons_grid.columns = 2
    else:
        upgrade_buttons_grid.columns = 3
    var min_height: float = 72.0
    var compact_height: float = maxf(320.0, panel_size.y)
    var font_size := 18
    match clamped_count:
        1:
            min_height = 120.0
        2:
            min_height = 88.0
        3:
            min_height = 76.0
        4:
            min_height = 68.0
        5:
            min_height = 60.0
            font_size = 17
        _:
            min_height = 56.0
            font_size = 16
    if compact_height < 520.0:
        min_height = minf(min_height, 68.0)
    if compact_height < 430.0:
        min_height = minf(min_height, 56.0)
        font_size = min(font_size, 15)
    for button in upgrade_buttons:
        if button == null:
            continue
        button.custom_minimum_size = Vector2(0.0, min_height)
        button.add_theme_font_size_override("font_size", font_size)

func _get_upgrade_panel_target_size() -> Vector2:
    var viewport_size: Vector2 = get_viewport_rect().size
    var margin := Vector2(
        maxf(UPGRADE_PANEL_MARGIN.x, viewport_size.x * UPGRADE_PANEL_MARGIN_RATIO.x),
        maxf(UPGRADE_PANEL_MARGIN.y, viewport_size.y * UPGRADE_PANEL_MARGIN_RATIO.y)
    )
    return Vector2(
        maxf(200.0, minf(UPGRADE_PANEL_MAX_SIZE.x, viewport_size.x - margin.x * 2.0)),
        maxf(220.0, minf(UPGRADE_PANEL_MAX_SIZE.y, viewport_size.y - margin.y * 2.0))
    )

func _refresh_upgrade_panel_layout(visible_count: int = 0) -> void:
    if upgrade_panel == null:
        return
    var panel_size: Vector2 = _get_upgrade_panel_target_size()
    upgrade_panel.anchor_left = 0.5
    upgrade_panel.anchor_top = 0.5
    upgrade_panel.anchor_right = 0.5
    upgrade_panel.anchor_bottom = 0.5
    upgrade_panel.offset_left = -panel_size.x * 0.5
    upgrade_panel.offset_top = -panel_size.y * 0.5
    upgrade_panel.offset_right = panel_size.x * 0.5
    upgrade_panel.offset_bottom = panel_size.y * 0.5
    if upgrade_buttons_scroll != null:
        upgrade_buttons_scroll.scroll_vertical = 0
    if visible_count > 0:
        _update_upgrade_offer_layout(visible_count)

func _apply_upgrade_button_rarity_style(button: Button, offer_tier: int) -> void:
    if button == null:
        return
    var tier_def: Dictionary = RED_SKY_DATA.get_wave_offer_tier_definition(offer_tier)
    var border_color: Color = tier_def.get("border", Color(0.94, 0.94, 0.96, 1.0))
    var intensity: float = clampf((float(offer_tier) + 1.0) / 6.0, 0.24, 1.0)
    button.add_theme_stylebox_override("normal", _make_upgrade_button_style(border_color, 0.12 + intensity * 0.08, 3.0 + float(offer_tier)))
    button.add_theme_stylebox_override("hover", _make_upgrade_button_style(border_color.lightened(0.1), 0.16 + intensity * 0.1, 4.0 + float(offer_tier)))
    button.add_theme_stylebox_override("pressed", _make_upgrade_button_style(border_color.darkened(0.08), 0.2 + intensity * 0.1, 4.0 + float(offer_tier)))
    button.add_theme_stylebox_override("focus", _make_upgrade_button_style(border_color.lightened(0.16), 0.16 + intensity * 0.12, 4.0 + float(offer_tier)))
    button.add_theme_stylebox_override("disabled", _make_upgrade_button_style(border_color.darkened(0.22), 0.08, 2.0 + float(offer_tier)))
    button.add_theme_color_override("font_color", Color(0.97, 0.96, 0.92, 1.0))
    button.add_theme_color_override("font_hover_color", Color(1.0, 0.99, 0.96, 1.0))
    button.add_theme_color_override("font_pressed_color", Color(1.0, 0.98, 0.94, 1.0))
    button.add_theme_color_override("font_focus_color", Color(1.0, 0.99, 0.96, 1.0))
    button.add_theme_color_override("font_disabled_color", Color(0.68, 0.66, 0.64, 1.0))
    button.add_theme_constant_override("outline_size", 2)
    button.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.05, 0.92))

func _make_upgrade_button_style(border_color: Color, tint_amount: float, border_size: float) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.11, 0.1, 0.12, 0.96).lerp(border_color, clampf(tint_amount, 0.0, 0.45))
    style.set_border_width_all(int(round(border_size)))
    style.border_color = border_color
    style.corner_radius_top_left = 14
    style.corner_radius_top_right = 14
    style.corner_radius_bottom_right = 14
    style.corner_radius_bottom_left = 14
    style.expand_margin_left = 2.0
    style.expand_margin_top = 2.0
    style.expand_margin_right = 2.0
    style.expand_margin_bottom = 2.0
    style.content_margin_left = 16.0
    style.content_margin_top = 14.0
    style.content_margin_right = 16.0
    style.content_margin_bottom = 14.0
    style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.18)
    style.shadow_size = 6
    style.shadow_offset = Vector2(0.0, 3.0)
    return style

func _round_upgrade_count(value: float) -> int:
    if value <= 0.0:
        return int(round(value))
    return maxi(1, int(ceil(value - 0.0001)))

func _draw() -> void:
    var viewport_size := get_viewport_rect().size
    var top_color := SKY_TOP_COLOR.lerp(SKY_TOP_NIGHT_COLOR, environment_darkness)
    var bottom_color := SKY_BOTTOM_COLOR.lerp(SKY_BOTTOM_NIGHT_COLOR, environment_darkness)
    var ground_color := GROUND_COLOR.lerp(GROUND_NIGHT_COLOR, environment_darkness)
    var sun_center := Vector2(viewport_size.x * 0.78, lerpf(viewport_size.y * 0.22, viewport_size.y * 0.72, sun_progress))
    var sun_color := Color(1.0, lerpf(0.55, 0.32, environment_darkness), lerpf(0.33, 0.2, environment_darkness), lerpf(0.18, 0.07, environment_darkness))
    draw_rect(Rect2(Vector2.ZERO, viewport_size), top_color, true)
    draw_rect(Rect2(Vector2(0.0, viewport_size.y * 0.58), Vector2(viewport_size.x, viewport_size.y * 0.42)), bottom_color, true)
    draw_circle(sun_center, 110.0, sun_color)
    draw_rect(Rect2(0.0, viewport_size.y - GROUND_HEIGHT, viewport_size.x, GROUND_HEIGHT), ground_color, true)
    _draw_base()
    _draw_support_units()
    _draw_enemies()
    _draw_player_bullets()
    _draw_nukes()
    _draw_enemy_projectiles()
    _draw_countermeasure_sweeps()
    _draw_salvage_pickups()
    _draw_support_effects()
    _draw_explosions()
    _draw_floating_texts()
    _draw_power_wheel()
    if run_state == RUN_STATES.RUNNING:
        _draw_aim_cursor()
    if run_state == RUN_STATES.DEFEAT:
        _draw_defeat_overlay()

func _draw_base() -> void:
    var base_pos := _get_base_position() + _get_base_visual_offset()
    var base_radius := BASE_RADIUS
    if run_state == RUN_STATES.DEFEAT:
        var defeat_progress := _get_defeat_progress()
        var pulse := 1.0 + sin(defeat_sequence_timer * 26.0) * 0.08 * (1.0 - defeat_progress)
        base_radius = BASE_RADIUS * (1.0 - 0.14 * defeat_progress) * pulse
        draw_circle(base_pos, base_radius + 20.0 + defeat_progress * 26.0, Color(1.0, 0.35, 0.22, 0.14 + 0.08 * (1.0 - defeat_progress)))
        draw_circle(base_pos, base_radius + 8.0, Color(0.34, 0.06, 0.07, 0.5))
        draw_arc(base_pos, base_radius + 28.0 + defeat_progress * 30.0, 0.0, TAU, 40, Color(1.0, 0.76, 0.5, 0.42 * (1.0 - defeat_progress * 0.45)), 6.0)
    draw_circle(base_pos, base_radius, BASE_COLOR.lerp(Color(0.94, 0.44, 0.34, 1.0), 0.7 if run_state == RUN_STATES.DEFEAT else 0.0))
    draw_circle(base_pos, max(base_radius - 18.0, 8.0), BASE_DARK_COLOR.lerp(Color(0.14, 0.04, 0.05, 1.0), 0.8 if run_state == RUN_STATES.DEFEAT else 0.0))
    draw_rect(Rect2(base_pos.x - 120.0, base_pos.y + 26.0, 240.0, 18.0), Color(0.25, 0.19, 0.14, 1.0), true)
    if run_state == RUN_STATES.RUNNING:
        draw_line(base_pos + Vector2(-22.0, -16.0), aim_cursor_screen_pos, Color(1.0, 0.79, 0.49, 0.12), 2.0)
    var health_ratio := clampf(base_health / max(base_max_health, 1.0), 0.0, 1.0)
    draw_rect(Rect2(base_pos.x - 84.0, base_pos.y - 92.0, 168.0, 12.0), Color(0.18, 0.09, 0.09, 0.9), true)
    draw_rect(Rect2(base_pos.x - 82.0, base_pos.y - 90.0, 164.0 * health_ratio, 8.0), Color(0.84, 0.35, 0.3, 1.0), true)
    if shield_max > 0.0:
        var shield_ratio := clampf(shield_health / max(shield_max, 1.0), 0.0, 1.0)
        draw_arc(base_pos, BASE_RADIUS + 14.0, PI * 0.12, PI * 0.88, 24, Color(SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, 0.25), 10.0)
        draw_arc(base_pos, BASE_RADIUS + 14.0, PI * 0.12, PI * (0.12 + 0.76 * shield_ratio), 24, SHIELD_COLOR, 8.0)

func _draw_support_units() -> void:
    var base_visual_pos := _get_base_position() + _get_base_visual_offset()
    for tower_pos in _get_tower_positions():
        draw_rect(Rect2(tower_pos.x - 10.0, tower_pos.y - 8.0, 20.0, 16.0), Color(0.16, 0.22, 0.28, 1.0), true)
        draw_line(tower_pos, tower_pos + Vector2(18.0, -10.0), TOWER_COLOR, 3.0)
    for drone_pos in _get_drone_positions():
        draw_circle(drone_pos, 7.0, DRONE_COLOR)
        draw_circle(drone_pos, 3.0, Color(0.12, 0.18, 0.22, 1.0))
    for anchor in _get_tentacle_anchor_positions():
        draw_line(base_visual_pos, anchor, Color(TENTACLE_COLOR.r, TENTACLE_COLOR.g, TENTACLE_COLOR.b, 0.65), 5.0)
        draw_circle(anchor, 8.0, TENTACLE_COLOR)
    for helper_pos in _get_helper_drone_positions():
        draw_circle(helper_pos, 8.0, DRONE_COLOR.lightened(0.22))
        draw_circle(helper_pos, 3.0, Color(0.1, 0.16, 0.2, 1.0))
    for collector_pos in _get_collector_bot_positions():
        draw_circle(collector_pos, 7.0, SALVAGE_COLOR)
        draw_circle(collector_pos, 3.0, Color(0.2, 0.16, 0.08, 1.0))
    for constructor_index in range(construction_drone_count):
        var constructor_pos := _get_construction_drone_anchor_pos(constructor_index)
        draw_circle(constructor_pos, 7.0, Color(0.95, 0.82, 0.58, 1.0))
        draw_line(constructor_pos + Vector2(-5.0, 0.0), constructor_pos + Vector2(5.0, 0.0), Color(0.24, 0.18, 0.08, 1.0), 2.0)
        draw_line(constructor_pos + Vector2(0.0, -5.0), constructor_pos + Vector2(0.0, 5.0), Color(0.24, 0.18, 0.08, 1.0), 2.0)
    for turret_index in range(temporary_turrets.size()):
        var temp_turret: Dictionary = temporary_turrets[turret_index]
        var turret_pos: Vector2 = temp_turret.get("pos", Vector2.ZERO)
        var turret_bp: float = float(temp_turret.get("build_progress", 1.0))
        if turret_bp < 1.0:
            var link_drone: int = turret_index % maxi(construction_drone_count, 1)
            var beam_from: Vector2 = _get_construction_drone_anchor_pos(link_drone) if construction_drone_count > 0 else base_visual_pos
            draw_line(beam_from, turret_pos, Color(1.0, 0.88, 0.52, 0.5), 2.0)
            draw_line(beam_from, turret_pos, Color(1.0, 0.96, 0.78, 0.22), 5.0)
            var pulse_a: float = 0.45 + sin(support_time * 15.0 + float(turret_index)) * 0.2
            draw_arc(turret_pos, 24.0, -PI * 0.5, -PI * 0.5 + TAU * turret_bp, maxi(8, int(24.0 * turret_bp)), Color(0.95, 0.82, 0.45, pulse_a), 4.0)
            draw_rect(Rect2(turret_pos.x - 6.0, turret_pos.y - 5.0, 12.0, 10.0), Color(0.35, 0.38, 0.42, 0.88), true)
        else:
            var turret_vel: Vector2 = temp_turret.get("vel", Vector2.UP)
            var ship_rotation: float = (turret_vel.angle() + PI * 0.5) if turret_vel.length_squared() > 0.001 else -PI * 0.5
            var ship_points := [
                Vector2(0.0, -CONSTRUCTION_ATTACK_SHIP_RADIUS * 1.16),
                Vector2(CONSTRUCTION_ATTACK_SHIP_RADIUS * 0.8, CONSTRUCTION_ATTACK_SHIP_RADIUS * 0.72),
                Vector2(0.0, CONSTRUCTION_ATTACK_SHIP_RADIUS * 0.32),
                Vector2(-CONSTRUCTION_ATTACK_SHIP_RADIUS * 0.8, CONSTRUCTION_ATTACK_SHIP_RADIUS * 0.72)
            ]
            draw_polygon(_build_rotated_points(ship_points, ship_rotation, turret_pos), [Color(0.54, 0.88, 1.0, 1.0)])
            draw_circle(turret_pos + Vector2.RIGHT.rotated(ship_rotation) * (CONSTRUCTION_ATTACK_SHIP_RADIUS * 0.1), CONSTRUCTION_ATTACK_SHIP_RADIUS * 0.24, Color(0.95, 0.98, 1.0, 1.0))
            var thruster_offset: Vector2 = Vector2.RIGHT.rotated(ship_rotation + PI) * (CONSTRUCTION_ATTACK_SHIP_RADIUS * 0.68)
            draw_line(turret_pos + thruster_offset + Vector2.LEFT.rotated(ship_rotation) * 2.0, turret_pos + thruster_offset + Vector2.LEFT.rotated(ship_rotation) * 6.0, Color(1.0, 0.82, 0.45, 0.68), 2.0)
            var tr: float = clampf(float(temp_turret.get("cooldown", 0.0)) / max(temporary_turret_fire_interval, 0.05), 0.0, 1.0)
            draw_arc(turret_pos, 16.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - tr), 12, Color(1.0, 0.86, 0.45, 0.35), 2.0)
    for shield_index in range(temporary_shields.size()):
        var temp_shield: Dictionary = temporary_shields[shield_index]
        var shield_pos: Vector2 = temp_shield.get("pos", Vector2.ZERO)
        var shield_bp: float = float(temp_shield.get("build_progress", 1.0))
        if shield_bp < 1.0:
            var s_link: int = shield_index % maxi(construction_drone_count, 1)
            var s_from: Vector2 = _get_construction_drone_anchor_pos(s_link) if construction_drone_count > 0 else base_visual_pos
            draw_line(s_from, shield_pos, Color(0.55, 0.88, 1.0, 0.48), 2.0)
            draw_line(s_from, shield_pos, Color(0.78, 0.95, 1.0, 0.2), 5.0)
            var spulse: float = 0.42 + sin(support_time * 14.0 + float(shield_index) * 0.8) * 0.18
            draw_arc(shield_pos, 22.0, -PI * 0.5, -PI * 0.5 + TAU * shield_bp, maxi(8, int(22.0 * shield_bp)), Color(SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, spulse), 4.0)
            draw_circle(shield_pos, 5.0, Color(SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, 0.55))
        else:
            draw_arc(shield_pos, 22.0, PI * 0.08, PI * 0.92, 20, Color(SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, 0.88), 5.0)
            draw_arc(shield_pos, 16.0, PI * 0.1, PI * 0.9, 16, Color(SHIELD_COLOR.r, SHIELD_COLOR.g, SHIELD_COLOR.b, 0.35), 3.0)
            draw_circle(shield_pos, 5.0, SHIELD_COLOR)
            var cap: float = float(temp_shield.get("shield", 0.0))
            var cap_max: float = maxf(temporary_shield_capacity, 1.0)
            draw_arc(shield_pos, 28.0, PI * 0.12, PI * (0.12 + 0.76 * clampf(cap / cap_max, 0.0, 1.0)), 14, Color(0.92, 0.98, 1.0, 0.55), 2.0)

func _draw_countermeasure_sweeps() -> void:
    var vp: Vector2 = get_viewport_rect().size
    for sweep in countermeasure_sweep_visuals:
        var duration: float = maxf(float(sweep.get("duration", COUNTERMEASURE_SWEEP_VISUAL_DURATION)), 0.01)
        var t: float = clampf(float(sweep.get("age", 0.0)) / duration, 0.0, 1.0)
        var y_top: float = float(sweep.get("y_top", vp.y * 0.06))
        var y_bottom: float = float(sweep.get("y_bottom", _get_base_position().y - 40.0))
        var y: float = lerpf(y_bottom, y_top, t)
        var alpha: float = (1.0 - t) * 0.88
        var half_w: float = COUNTERMEASURE_SWEEP_LINE_WIDTH * 0.5
        draw_rect(Rect2(0.0, y - half_w, vp.x, COUNTERMEASURE_SWEEP_LINE_WIDTH), Color(CM_SWEEP_COLOR.r, CM_SWEEP_COLOR.g, CM_SWEEP_COLOR.b, alpha * 0.32), true)
        draw_line(Vector2(0.0, y), Vector2(vp.x, y), Color(CM_SWEEP_COLOR.r, CM_SWEEP_COLOR.g, CM_SWEEP_COLOR.b, alpha), 5.0)
        draw_line(Vector2(0.0, y), Vector2(vp.x, y), Color(1.0, 1.0, 1.0, alpha * 0.38), 2.0)

func _draw_power_wheel() -> void:
    var center := Vector2(160.0, get_viewport_rect().size.y - 156.0)
    draw_circle(center, POWER_WHEEL_RADIUS, Color(0.04, 0.06, 0.08, 0.32))
    draw_arc(center, POWER_WHEEL_RADIUS, 0.0, TAU, 48, Color(0.82, 0.88, 0.96, 0.28), 2.0)
    for slot_index in range(power_slot_order.size()):
        var angle: float = -PI * 0.5 + TAU * float(slot_index) / float(power_slot_order.size())
        var dir := Vector2(cos(angle), sin(angle))
        var slot_key: String = power_slot_order[slot_index]
        var display_pct: int = int(round(float(power_display_values.get(slot_key, 1.0)) * 100.0))
        var ring_color := Color(0.88, 0.92, 1.0, 0.34)
        if float(power_display_values.get(slot_key, 1.0)) < 0.2:
            ring_color = Color(1.0, 0.52, 0.38, 0.82)
        draw_line(center + dir * 28.0, center + dir * POWER_WHEEL_RADIUS, ring_color, 2.0)
        draw_string(ThemeDB.fallback_font, center + dir * (POWER_WHEEL_RADIUS + 8.0), "%d%%" % display_pct, HORIZONTAL_ALIGNMENT_CENTER, 70.0, 14, ring_color)
    draw_circle(center + power_bias * (POWER_WHEEL_RADIUS - 18.0), 10.0, Color(1.0, 0.84, 0.42, 1.0))

func _draw_enemies() -> void:
    for enemy in enemies:
        var pos: Vector2 = enemy.get("pos", Vector2.ZERO)
        var radius: float = float(enemy.get("radius", 18.0))
        var enemy_type: String = String(enemy.get("type", "raider"))
        var rotation := _get_enemy_rotation(enemy)
        match enemy_type:
            BOSS_TYPE:
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 1.02), Vector2(radius * 1.18, -radius * 0.34), Vector2(radius * 1.08, radius * 0.56), Vector2(0.0, radius * 0.92), Vector2(-radius * 1.08, radius * 0.56), Vector2(-radius * 1.18, -radius * 0.34)], rotation, pos), [Color(0.5, 0.18, 0.24, 1.0)])
                draw_circle(pos, radius * 0.22, Color(0.98, 0.84, 0.58, 1.0))
                var boss_life: float = float(enemy.get("lifetime", 0.0))
                var boss_seed: float = float(enemy.get("movement_seed", 0.0))
                for spot_i in range(4):
                    var spot_ang: float = boss_seed + boss_life * 1.05 + float(spot_i) * TAU / 4.0
                    var spot_p: Vector2 = pos + Vector2.RIGHT.rotated(spot_ang) * radius * 0.64
                    draw_circle(spot_p, radius * 0.11, Color(1.0, 0.52, 0.36, 0.95))
                    draw_arc(spot_p, radius * 0.14, 0.0, TAU, 14, Color(1.0, 0.86, 0.52, 0.75), 2.0)
            "carrier":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 0.7), Vector2(radius * 1.4, -radius * 0.18), Vector2(radius * 1.08, radius * 0.54), Vector2(0.0, radius * 0.9), Vector2(-radius * 1.08, radius * 0.54), Vector2(-radius * 1.4, -radius * 0.18)], rotation, pos), [Color(0.72, 0.31, 0.26, 1.0)])
                draw_circle(pos, radius * 0.34, Color(0.96, 0.8, 0.54, 1.0))
            "command_ship":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 0.82), Vector2(radius * 1.28, -radius * 0.28), Vector2(radius * 1.08, radius * 0.48), Vector2(radius * 0.42, radius * 0.94), Vector2(-radius * 0.42, radius * 0.94), Vector2(-radius * 1.08, radius * 0.48), Vector2(-radius * 1.28, -radius * 0.28)], rotation, pos), [Color(0.62, 0.28, 0.38, 1.0)])
                draw_circle(pos, radius * 0.24, Color(0.96, 0.82, 0.56, 1.0))
            "dreadnought":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 0.96), Vector2(radius * 1.1, -radius * 0.42), Vector2(radius * 1.22, radius * 0.18), Vector2(radius * 0.72, radius * 0.98), Vector2(-radius * 0.72, radius * 0.98), Vector2(-radius * 1.22, radius * 0.18), Vector2(-radius * 1.1, -radius * 0.42)], rotation, pos), [Color(0.46, 0.2, 0.24, 1.0)])
                draw_circle(pos, radius * 0.26, Color(0.98, 0.68, 0.44, 1.0))
            "siege":
                draw_polygon(_build_rotated_points([Vector2(-radius * 0.82, -radius * 0.48), Vector2(radius * 0.82, -radius * 0.48), Vector2(radius * 1.0, radius * 0.2), Vector2(radius * 0.54, radius * 0.88), Vector2(-radius * 0.54, radius * 0.88), Vector2(-radius * 1.0, radius * 0.2)], rotation, pos), [Color(0.66, 0.4, 0.34, 1.0)])
            "artillery":
                draw_polygon(_build_rotated_points([Vector2(-radius * 0.92, -radius * 0.34), Vector2(radius * 0.92, -radius * 0.34), Vector2(radius * 0.84, radius * 0.52), Vector2(0.0, radius * 0.94), Vector2(-radius * 0.84, radius * 0.52)], rotation, pos), [Color(0.58, 0.38, 0.3, 1.0)])
                draw_line(pos, pos + Vector2.RIGHT.rotated(rotation) * radius * 1.1, Color(0.96, 0.82, 0.58, 1.0), 3.0)
            "brute":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 1.0), Vector2(radius * 0.96, -radius * 0.34), Vector2(radius * 0.82, radius * 0.78), Vector2(0.0, radius * 1.0), Vector2(-radius * 0.82, radius * 0.78), Vector2(-radius * 0.96, -radius * 0.34)], rotation, pos), [Color(0.58, 0.28, 0.24, 1.0)])
                draw_circle(pos, radius * 0.28, Color(0.95, 0.74, 0.52, 1.0))
            "skimmer":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 1.3), Vector2(radius * 0.82, radius * 0.42), Vector2(0.0, radius * 0.22), Vector2(-radius * 0.82, radius * 0.42)], rotation, pos), [Color(0.9, 0.68, 0.4, 1.0)])
            "dronelet":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 1.1), Vector2(radius * 0.7, radius * 0.8), Vector2(-radius * 0.7, radius * 0.8)], rotation, pos), [Color(0.96, 0.82, 0.48, 1.0)])
            "runner":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius - 4.0), Vector2(radius * 0.65, radius * 0.95), Vector2(0.0, radius * 0.4), Vector2(-radius * 0.65, radius * 0.95)], rotation, pos), [Color(0.98, 0.8, 0.4, 1.0)])
            "gunship":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 0.95), Vector2(radius * 1.35, -radius * 0.25), Vector2(radius * 0.9, radius * 0.5), Vector2(0.0, radius * 0.2), Vector2(-radius * 0.9, radius * 0.5), Vector2(-radius * 1.35, -radius * 0.25)], rotation, pos), [Color(0.86, 0.57, 0.44, 1.0)])
            "destroyer":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 0.92), Vector2(radius * 1.22, -radius * 0.3), Vector2(radius * 0.98, radius * 0.58), Vector2(0.0, radius * 0.82), Vector2(-radius * 0.98, radius * 0.58), Vector2(-radius * 1.22, -radius * 0.3)], rotation, pos), [Color(0.68, 0.36, 0.3, 1.0)])
                draw_circle(pos, radius * 0.18, Color(0.98, 0.78, 0.54, 1.0))
            "interceptor":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 1.18), Vector2(radius * 0.96, radius * 0.22), Vector2(0.0, radius * 0.48), Vector2(-radius * 0.96, radius * 0.22)], rotation, pos), [Color(0.94, 0.74, 0.44, 1.0)])
            "bomber":
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 1.1), Vector2(radius * 0.95, -radius * 0.45), Vector2(radius * 1.15, radius * 0.45), Vector2(0.0, radius * 0.95), Vector2(-radius * 1.15, radius * 0.45), Vector2(-radius * 0.95, -radius * 0.45)], rotation, pos), [Color(0.76, 0.33, 0.28, 1.0)])
            _:
                draw_polygon(_build_rotated_points([Vector2(0.0, -radius * 1.0), Vector2(radius * 0.8, 0.0), Vector2(0.0, radius * 0.92), Vector2(-radius * 0.8, 0.0)], rotation, pos), [Color(0.89, 0.75, 0.61, 1.0)])
        if float(enemy.get("slow_timer", 0.0)) > 0.0:
            draw_arc(pos, radius + 6.0, 0.0, TAU, 16, Color(0.6, 0.92, 1.0, 0.7), 2.0)

func _draw_player_bullets() -> void:
    for bullet in player_bullets:
        var color: Color = PLAYER_CRIT_BULLET_COLOR if bool(bullet.get("crit", false)) else PLAYER_BULLET_COLOR
        if bool(bullet.get("homing", false)):
            color = color.lerp(Color(0.52, 0.92, 1.0, 1.0), 0.55)
        draw_circle(bullet.get("pos", Vector2.ZERO), float(bullet.get("radius", BULLET_RADIUS)), color)

func _draw_nukes() -> void:
    for nuke in nukes:
        var pos: Vector2 = nuke.get("pos", Vector2.ZERO)
        var vel: Vector2 = nuke.get("vel", Vector2.UP * -1.0)
        draw_line(pos - vel.normalized() * 24.0, pos, Color(1.0, 0.8, 0.52, 0.7), 3.0)
        draw_circle(pos, NUKE_RADIUS, NUKE_COLOR)
        draw_circle(pos, NUKE_RADIUS * 0.45, Color(1.0, 0.93, 0.72, 1.0))

func _draw_enemy_projectiles() -> void:
    for projectile in enemy_projectiles:
        var color := ENEMY_PROJECTILE_COLOR if String(projectile.get("team", "enemy")) == "enemy" else DEFLECTED_PROJECTILE_COLOR
        if bool(projectile.get("penetrator", false)):
            color = Color(1.0, 0.42, 0.86, 1.0)
        draw_circle(projectile.get("pos", Vector2.ZERO), float(projectile.get("radius", 12.0)), color)

func _draw_salvage_pickups() -> void:
    for pickup in salvage_pickups:
        var pos: Vector2 = pickup.get("pos", Vector2.ZERO)
        var points := PackedVector2Array([pos + Vector2(0.0, -6.0), pos + Vector2(6.0, 0.0), pos + Vector2(0.0, 6.0), pos + Vector2(-6.0, 0.0)])
        draw_polygon(points, [SALVAGE_COLOR])

func _draw_support_effects() -> void:
    for effect in support_effects:
        var progress: float = clampf(float(effect.get("age", 0.0)) / max(float(effect.get("duration", SUPPORT_EFFECT_DURATION)), 0.01), 0.0, 1.0)
        var color: Color = effect.get("color", Color.WHITE)
        var alpha: float = 1.0 - progress
        draw_line(effect.get("start", Vector2.ZERO), effect.get("finish", Vector2.ZERO), Color(color.r, color.g, color.b, alpha), 3.0)

func _draw_explosions() -> void:
    for explosion in explosions:
        var pos: Vector2 = explosion.get("pos", Vector2.ZERO)
        var radius: float = float(explosion.get("radius", 0.0))
        var progress: float = clampf(float(explosion.get("age", 0.0)) / max(float(explosion.get("duration", 0.2)), 0.01), 0.0, 1.0)
        var alpha := 1.0 - progress
        draw_circle(pos, radius, Color(EXPLOSION_COLOR.r, EXPLOSION_COLOR.g, EXPLOSION_COLOR.b, 0.24 * alpha))
        draw_circle(pos, radius * 0.55, Color(1.0, 0.86, 0.62, 0.18 * alpha))
        draw_arc(pos, radius, 0.0, TAU, 48, Color(1.0, 0.84, 0.52, 0.65 * alpha), 4.0)

func _draw_floating_texts() -> void:
    for entry in floating_texts:
        draw_string(ThemeDB.fallback_font, entry.get("pos", Vector2.ZERO), String(entry.get("text", "")), HORIZONTAL_ALIGNMENT_CENTER, -1.0, int(entry.get("font_size", 22)), entry.get("color", Color.WHITE))

func _draw_aim_cursor() -> void:
    draw_arc(aim_cursor_screen_pos, AIM_CURSOR_RADIUS, 0.0, TAU, 32, Color(0.99, 0.86, 0.42, 0.95), 2.0)
    draw_line(aim_cursor_screen_pos + Vector2(-AIM_CURSOR_RADIUS - 5.0, 0.0), aim_cursor_screen_pos + Vector2(AIM_CURSOR_RADIUS + 5.0, 0.0), Color(0.99, 0.86, 0.42, 0.95), 2.0)
    draw_line(aim_cursor_screen_pos + Vector2(0.0, -AIM_CURSOR_RADIUS - 5.0), aim_cursor_screen_pos + Vector2(0.0, AIM_CURSOR_RADIUS + 5.0), Color(0.99, 0.86, 0.42, 0.95), 2.0)
    draw_circle(aim_cursor_screen_pos, 2.0, Color(0.16, 0.08, 0.04, 1.0))

func _draw_defeat_overlay() -> void:
    var progress := _get_defeat_progress()
    var pulse := 0.5 + 0.5 * sin(defeat_sequence_timer * 18.0)
    var alpha: float = clampf(0.18 + progress * 0.12 + pulse * 0.12 * (1.0 - progress * 0.45), 0.0, DEFEAT_OVERLAY_MAX_ALPHA)
    draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.34, 0.02, 0.02, alpha), true)

func _get_defeat_progress() -> float:
    if run_state != RUN_STATES.DEFEAT:
        return 0.0
    return clampf(defeat_sequence_timer / max(DEFEAT_SEQUENCE_DURATION, 0.01), 0.0, 1.0)

func _get_base_visual_offset() -> Vector2:
    if run_state != RUN_STATES.DEFEAT:
        return Vector2.ZERO
    var shake_strength: float = (1.0 - _get_defeat_progress()) * 10.0
    return Vector2(sin(defeat_sequence_timer * 39.0), cos(defeat_sequence_timer * 27.0)) * shake_strength

func _input(event: InputEvent) -> void:
    if _handle_pause_menu_input(event):
        return
    if event is InputEventKey:
        var key_event := event as InputEventKey
        if key_event.pressed and not key_event.echo:
            if key_event.keycode == KEY_MINUS or key_event.keycode == KEY_KP_SUBTRACT:
                tune_text_pixel_filter(-TEXT_FILTER_SCALE_STEP)
                get_viewport().set_input_as_handled()
                return
            if key_event.keycode == KEY_KP_ADD or (key_event.keycode == KEY_EQUAL and key_event.shift_pressed):
                tune_text_pixel_filter(TEXT_FILTER_SCALE_STEP)
                get_viewport().set_input_as_handled()
                return
    if event is InputEventMouseMotion:
        var motion_event := event as InputEventMouseMotion
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and run_state == RUN_STATES.RUNNING:
            aim_cursor_screen_pos = _clamp_cursor_to_viewport(aim_cursor_screen_pos + motion_event.relative)
        elif _is_power_wheel_mouse_drag_active():
            pass
        else:
            aim_cursor_screen_pos = _clamp_cursor_to_viewport(motion_event.position)
    elif event is InputEventMouseButton:
        var mouse_button_event := event as InputEventMouseButton
        if mouse_button_event.button_index == MOUSE_BUTTON_RIGHT:
            if run_state == RUN_STATES.RUNNING and Global.game_state == Util.GAME_STATES.PLAYING and not _is_pause_menu_open():
                if not mouse_button_event.pressed and not _should_keep_mouse_visible_for_wave_intro():
                    get_viewport().warp_mouse(aim_cursor_screen_pos)
                _refresh_mouse_capture_state()
        if not (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and run_state == RUN_STATES.RUNNING):
            var skip_aim_from_click := mouse_button_event.button_index == MOUSE_BUTTON_RIGHT
            if not skip_aim_from_click and run_state == RUN_STATES.RUNNING and mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
                if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
                    skip_aim_from_click = true
            if not skip_aim_from_click:
                aim_cursor_screen_pos = _clamp_cursor_to_viewport(mouse_button_event.position)
        if run_state == RUN_STATES.RUNNING and mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
            _launch_nuke()

func _launch_nuke() -> void:
    if remaining_nukes <= 0:
        return
    var base_pos := _get_base_position()
    var target := _clamp_cursor_to_viewport(aim_cursor_screen_pos)
    if target.distance_to(base_pos) <= 24.0:
        return
    remaining_nukes -= 1
    nukes_launched += 1
    nukes.append({"pos": base_pos, "target": target, "vel": (target - base_pos).normalized() * NUKE_SPEED})
    _play_red_sky_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.RED_SKY_NUKE_LAUNCH)

func _process_salvage_pickups(delta: float) -> void:
    var collectors: Array[Vector2] = [aim_cursor_screen_pos]
    collectors.append_array(_get_drone_positions())
    collectors.append_array(_get_collector_bot_positions())
    for pickup_index in range(salvage_pickups.size() - 1, -1, -1):
        var pickup: Dictionary = salvage_pickups[pickup_index]
        pickup["age"] = float(pickup.get("age", 0.0)) + delta
        var pos: Vector2 = pickup.get("pos", Vector2.ZERO)
        var vel: Vector2 = pickup.get("vel", Vector2.ZERO)
        var nearest_collector: Vector2 = aim_cursor_screen_pos
        var nearest_distance := INF
        for collector in collectors:
            var dist: float = pos.distance_to(collector)
            if dist < nearest_distance:
                nearest_distance = dist
                nearest_collector = collector
        if nearest_distance <= pickup_radius * 3.0:
            var collector_speed_mult := _get_power_multiplier("scrap_collection")
            vel += (nearest_collector - pos).normalized() * (420.0 + float(collector_bot_count) * collector_bot_speed * 0.2) * collector_speed_mult * delta
        vel *= 0.94
        pos += vel * delta
        pickup["vel"] = vel
        pickup["pos"] = pos
        if nearest_distance <= pickup_radius:
            _collect_salvage_pickup(pickup_index, 1.0)
            continue
        if float(pickup.get("age", 0.0)) >= salvage_lifetime:
            salvage_lost += int(pickup.get("value", 0))
            salvage_pickups.remove_at(pickup_index)
        else:
            salvage_pickups[pickup_index] = pickup

func _spawn_salvage(position: Vector2, total_value: int) -> void:
    var shard_count: int = clampi(1 + int(total_value / 24), 1, 4)
    var remaining_value: int = total_value
    for shard_index in range(shard_count):
        var shard_value: int = remaining_value if shard_index == shard_count - 1 else maxi(1, int(round(float(total_value) / float(shard_count))))
        remaining_value -= shard_value
        salvage_pickups.append({
            "pos": position + Vector2(rng.randf_range(-12.0, 12.0), rng.randf_range(-8.0, 8.0)),
            "vel": Vector2(rng.randf_range(-90.0, 90.0), rng.randf_range(-100.0, 10.0)),
            "value": shard_value,
            "age": 0.0
        })

func _award_wave_clear_bonus() -> void:
    if wave_scrap_bonus <= 0.0:
        return
    var bonus_value: int = max(0, int(round(wave_scrap_bonus * float(current_wave))))
    if bonus_value <= 0:
        return
    score += bonus_value
    bonus_scrap_earned += bonus_value
    _spawn_floating_text("+%d SCRAP" % bonus_value, get_viewport_rect().size * Vector2(0.5, 0.22), SALVAGE_COLOR, 26)

func _get_upgrade_icon_texture(upgrade_id: String) -> Texture2D:
    var upgrade_def: Dictionary = RED_SKY_DATA.get_wave_upgrade_definition(upgrade_id)
    var icon_id: String = str(upgrade_def.get("icon", ""))
    if icon_id.begins_with("redsky://"):
        return RED_SKY_ICON_FACTORY.get_icon(icon_id)
    if not icon_id.is_empty() and ResourceLoader.exists(icon_id):
        return load(icon_id) as Texture2D
    return null

func _collect_salvage_pickup(pickup_index: int, value_ratio: float) -> void:
    var pickup: Dictionary = salvage_pickups[pickup_index]
    var value: int = int(round(float(pickup.get("value", 0)) * value_ratio))
    score += value
    salvage_collected += value
    _spawn_floating_text("+%d" % value, pickup.get("pos", Vector2.ZERO), SALVAGE_COLOR, 22)
    var lost_amount: int = int(pickup.get("value", 0)) - value
    if lost_amount > 0:
        salvage_lost += lost_amount
    salvage_pickups.remove_at(pickup_index)

func _bank_remaining_salvage(ratio: float) -> void:
    for pickup_index in range(salvage_pickups.size() - 1, -1, -1):
        _collect_salvage_pickup(pickup_index, ratio)

func _spawn_support_effect(start_pos: Vector2, finish_pos: Vector2, color: Color, duration: float) -> void:
    support_effects.append({"start": start_pos, "finish": finish_pos, "color": color, "duration": duration, "age": 0.0})

func _get_pointer_direction() -> Vector2:
    var direction := aim_cursor_screen_pos - _get_base_position()
    if direction.length() < 8.0:
        return Vector2.ZERO
    return direction.normalized()

func _get_base_position() -> Vector2:
    var viewport := get_viewport_rect().size
    return Vector2(viewport.x * 0.5, viewport.y - GROUND_HEIGHT - 20.0)

func _get_random_spawn_position(viewport: Vector2) -> Vector2:
    var edge_roll: int = rng.randi_range(0, 2)
    if edge_roll == 0:
        return Vector2(rng.randf_range(80.0, viewport.x - 80.0), -40.0)
    if edge_roll == 1:
        return Vector2(-40.0, rng.randf_range(40.0, viewport.y * 0.26))
    return Vector2(viewport.x + 40.0, rng.randf_range(40.0, viewport.y * 0.26))

func _find_nearest_enemy_index(origin: Vector2, max_distance: float) -> int:
    var best_index := -1
    var best_distance := max_distance
    for enemy_index in range(enemies.size()):
        var distance: float = origin.distance_to(enemies[enemy_index].get("pos", Vector2.ZERO))
        if distance <= best_distance:
            best_distance = distance
            best_index = enemy_index
    return best_index

func _get_reflected_projectile_direction(projectile_pos: Vector2) -> Vector2:
    var enemy_index: int = _find_nearest_enemy_index(projectile_pos, 800.0)
    if enemy_index != -1:
        return (enemies[enemy_index].get("pos", Vector2.ZERO) - projectile_pos).normalized()
    return Vector2.UP

func _ensure_support_arrays() -> void:
    while tower_fire_timers.size() < tower_count:
        tower_fire_timers.append(rng.randf_range(0.1, tower_fire_interval))
    while tower_fire_timers.size() > tower_count:
        tower_fire_timers.remove_at(tower_fire_timers.size() - 1)
    while drone_fire_timers.size() < drone_count:
        drone_fire_timers.append(rng.randf_range(0.05, drone_fire_interval))
    while drone_fire_timers.size() > drone_count:
        drone_fire_timers.remove_at(drone_fire_timers.size() - 1)
    while tentacle_cooldowns.size() < tentacle_count:
        tentacle_cooldowns.append(rng.randf_range(0.08, tentacle_attack_cooldown))
    while tentacle_cooldowns.size() > tentacle_count:
        tentacle_cooldowns.remove_at(tentacle_cooldowns.size() - 1)
    while helper_fire_timers.size() < helper_drone_count:
        helper_fire_timers.append(rng.randf_range(0.08, helper_drone_fire_interval))
    while helper_fire_timers.size() > helper_drone_count:
        helper_fire_timers.remove_at(helper_fire_timers.size() - 1)

func _get_tower_positions() -> Array[Vector2]:
    var positions: Array[Vector2] = []
    var base_pos := _get_base_position() + _get_base_visual_offset()
    for tower_index in range(tower_count):
        var angle: float = lerpf(-0.75, -PI + 0.75, float(tower_index + 1) / float(tower_count + 1))
        positions.append(base_pos + Vector2(cos(angle), sin(angle)) * (BASE_RADIUS + 34.0))
    return positions

func _get_drone_positions() -> Array[Vector2]:
    var positions: Array[Vector2] = []
    var base_pos := _get_base_position() + _get_base_visual_offset()
    for drone_index in range(drone_count):
        var angle: float = support_time * 1.5 + float(drone_index) * TAU / max(float(drone_count), 1.0)
        positions.append(base_pos + Vector2(cos(angle), sin(angle) * 0.55) * (BASE_RADIUS + 52.0))
    return positions

func _get_helper_drone_positions() -> Array[Vector2]:
    var positions: Array[Vector2] = []
    var base_pos := _get_base_position() + _get_base_visual_offset()
    for helper_index in range(helper_drone_count):
        var angle: float = support_time * 0.85 + float(helper_index) * TAU / max(float(helper_drone_count), 1.0)
        positions.append(base_pos + Vector2(cos(angle), sin(angle) * 0.72) * (BASE_RADIUS + 110.0))
    return positions

func _get_collector_bot_positions() -> Array[Vector2]:
    var positions: Array[Vector2] = []
    var base_pos := _get_base_position() + _get_base_visual_offset()
    for collector_index in range(collector_bot_count):
        var angle: float = -support_time * 0.7 + float(collector_index) * TAU / max(float(collector_bot_count), 1.0)
        positions.append(base_pos + Vector2(cos(angle), sin(angle) * 0.4) * (BASE_RADIUS + 88.0))
    return positions

func _get_construction_field_slots_per_layer() -> int:
    return 1 + int(floor(CONSTRUCTION_FIELD_MAX_ANGLE / CONSTRUCTION_FIELD_ANGLE_STEP)) * 2

func _get_construction_field_angle(slot_in_layer: int) -> float:
    if slot_in_layer <= 0:
        return -PI * 0.5
    var step_index: int = int(ceil(float(slot_in_layer) * 0.5))
    var direction: float = 1.0 if slot_in_layer % 2 == 1 else -1.0
    return -PI * 0.5 + CONSTRUCTION_FIELD_ANGLE_STEP * float(step_index) * direction

func _get_construction_field_distance(layer_index: int, is_shield: bool) -> float:
    var base_offset: float = 18.0 if is_shield else 32.0
    return CONSTRUCTION_FIELD_RADIUS_BASE + base_offset + CONSTRUCTION_FIELD_LAYER_SPACING * float(layer_index)

func _compute_construction_field_position(structure_index: int, structure_count: int, is_shield: bool) -> Vector2:
    var base_pos := _get_base_position()
    var vp: Vector2 = get_viewport_rect().size
    var layer_slots: int = _get_construction_field_slots_per_layer()
    var safe_count: int = maxi(1, structure_count)
    var slot_index: int = clampi(structure_index, 0, safe_count - 1)
    var layer_index: int = int(slot_index / layer_slots)
    var slot_in_layer: int = slot_index % layer_slots
    var angle: float = _get_construction_field_angle(slot_in_layer)
    if is_shield:
        angle = -PI * 0.5 + (angle + PI * 0.5) * CONSTRUCTION_SHIELD_ANGLE_SPREAD_MULT
    var dist: float = _get_construction_field_distance(layer_index, is_shield)
    var pos: Vector2 = base_pos + Vector2(cos(angle), sin(angle)) * dist
    pos.x = clampf(pos.x, 76.0, vp.x - 76.0)
    pos.y = clampf(pos.y, vp.y * 0.06, base_pos.y - 102.0)
    return pos

func _get_temporary_turret_target_position(home_pos: Vector2, structure_index: int, structure_count: int) -> Vector2:
    var base_pos := _get_base_position()
    var vp: Vector2 = get_viewport_rect().size
    var safe_count: int = maxi(1, structure_count)
    var slot_index: int = clampi(structure_index, 0, safe_count - 1)
    var target_y: float = vp.y * CONSTRUCTION_TURRET_FORWARD_Y_RATIO
    var direction: Vector2 = (home_pos - base_pos).normalized()
    if direction == Vector2.ZERO:
        direction = Vector2.UP
    var travel: float = 0.0
    if direction.y < -0.001:
        travel = (target_y - base_pos.y) / direction.y
    if travel <= 0.0:
        travel = _get_construction_field_distance(int(slot_index / _get_construction_field_slots_per_layer()) + 1, false)
    var target_pos: Vector2 = base_pos + direction * travel
    target_pos.x = clampf(target_pos.x, 68.0, vp.x - 68.0)
    target_pos.y = clampf(target_pos.y, vp.y * 0.18, target_y)
    return target_pos

func _get_temporary_shield_target_position(home_pos: Vector2) -> Vector2:
    var vp: Vector2 = get_viewport_rect().size
    var best_projectile_pos: Vector2 = home_pos
    var best_score: float = INF
    for projectile in enemy_projectiles:
        if String(projectile.get("team", "enemy")) != "enemy":
            continue
        var projectile_pos: Vector2 = projectile.get("pos", Vector2.ZERO)
        var score: float = home_pos.distance_to(projectile_pos)
        if score > CONSTRUCTION_SHIELD_INTERCEPT_RADIUS:
            continue
        if projectile_pos.y > home_pos.y + 36.0:
            continue
        if score < best_score:
            best_score = score
            best_projectile_pos = projectile_pos
    if best_score == INF:
        return home_pos
    var offset: Vector2 = best_projectile_pos - home_pos
    if offset.length() > CONSTRUCTION_SHIELD_SHIFT_LIMIT:
        offset = offset.normalized() * CONSTRUCTION_SHIELD_SHIFT_LIMIT
    var target_pos: Vector2 = home_pos + offset
    target_pos.x = clampf(target_pos.x, 72.0, vp.x - 72.0)
    target_pos.y = clampf(target_pos.y, vp.y * 0.08, _get_base_position().y - 96.0)
    return target_pos

func _get_construction_drone_anchor_pos(constructor_index: int) -> Vector2:
    var base_visual_pos := _get_base_position() + _get_base_visual_offset()
    var constructor_angle: float = support_time * 1.1 + float(constructor_index) * TAU / max(float(construction_drone_count), 1.0)
    return base_visual_pos + Vector2(cos(constructor_angle), sin(constructor_angle) * 0.62) * (BASE_RADIUS + 66.0)

func _make_temporary_turret() -> Dictionary:
    var idx: int = temporary_turrets.size()
    var pos: Vector2 = _compute_construction_field_position(idx, idx + 1, false)
    return {
        "pos": pos,
        "home_pos": pos,
        "age": 0.0,
        "cooldown": temporary_turret_fire_interval + rng.randf_range(0.25, 0.75),
        "health": temporary_turret_health,
        "max_health": temporary_turret_health,
        "vel": Vector2.ZERO,
        "orbit_dir": -1.0 if rng.randf() < 0.5 else 1.0,
        "build_progress": 0.0,
    }

func _make_temporary_shield() -> Dictionary:
    var idx: int = temporary_shields.size()
    var pos: Vector2 = _compute_construction_field_position(idx, idx + 1, true)
    return {
        "pos": pos,
        "home_pos": pos,
        "age": 0.0,
        "health": temporary_shield_health,
        "max_health": temporary_shield_health,
        "shield": temporary_shield_capacity,
        "build_progress": 0.0,
    }

func _get_run_start_hint_lines() -> Array[String]:
    var hint_lines: Array[String] = []
    var completed_runs: int = int(persistent_data.get("runs", 0))
    if completed_runs < 6:
        hint_lines.append(tr("RED_SKY_HINT_POWER_WHEEL"))
    if completed_runs < 8 and countermeasures_rating > 0.0:
        hint_lines.append(tr("RED_SKY_HINT_COUNTERMEASURES"))
        hint_lines.append(tr("RED_SKY_HINT_NUKES_PURPLE"))
    return hint_lines

func _get_power_multiplier(slot_key: String) -> float:
    return max(POWER_WHEEL_FUNCTIONAL_MIN, float(power_multipliers.get(slot_key, 1.0)))

func _get_gun_power_multiplier() -> float:
    return GUN_FIXED_POWER_MULTIPLIER

func _is_power_slot_accessible(slot_key: String) -> bool:
    match slot_key:
        "shields":
            return shield_max > 0.0
        "hull_regen":
            return repair_between_waves > 0.0
        "nukes":
            return nuke_max > 0
        "homing_missiles":
            return homing_missile_level > 0
        "countermeasures":
            return countermeasures_rating > 0.0
        "towers":
            return tower_count > 0
        "helpers":
            return drone_count > 0 or helper_drone_count > 0
        "tentacles":
            return tentacle_count > 0
        "construction":
            return construction_drone_count > 0 or temporary_turret_limit > 0 or temporary_shield_limit > 0
        "scrap_gain":
            return scrap_generation_per_second > 0.0
        "scrap_collection":
            return pickup_radius > 0.0
        _:
            return false

func _rebuild_power_slot_order() -> void:
    var available_slots: Array[String] = []
    for slot_key in POWER_SLOT_KEYS:
        if _is_power_slot_accessible(slot_key):
            available_slots.append(slot_key)
    if available_slots.is_empty():
        available_slots.append("countermeasures")

    var new_order: Array[String] = []
    for slot_key in power_slot_order:
        if available_slots.has(slot_key) and not new_order.has(slot_key):
            new_order.append(slot_key)
    for slot_key in POWER_SLOT_KEYS:
        if available_slots.has(slot_key) and not new_order.has(slot_key):
            new_order.append(slot_key)
    power_slot_order = new_order
    if power_swap_source_slot >= power_slot_order.size():
        power_swap_source_slot = -1

func _recalculate_power_distribution() -> void:
    var slot_count: int = power_slot_order.size()
    if slot_count <= 0:
        return
    var weights: Array[float] = []
    var total_weight := 0.0
    for slot_index in range(slot_count):
        var angle: float = -PI * 0.5 + TAU * float(slot_index) / float(slot_count)
        var direction := Vector2(cos(angle), sin(angle))
        var weight: float = clampf(1.0 + power_bias.dot(direction) * 2.95, 0.04, POWER_WHEEL_MAX)
        weights.append(weight)
        total_weight += weight
    if total_weight <= 0.0:
        total_weight = float(slot_count)
        for slot_index in range(slot_count):
            weights[slot_index] = 1.0
    power_multipliers.clear()
    power_display_values.clear()
    for slot_index in range(slot_count):
        var normalized: float = weights[slot_index] * float(slot_count) / total_weight
        var slot_key: String = power_slot_order[slot_index]
        power_display_values[slot_key] = clampf(normalized, POWER_WHEEL_DISPLAY_MIN, POWER_WHEEL_MAX)
        power_multipliers[slot_key] = max(POWER_WHEEL_FUNCTIONAL_MIN, normalized)
    _refresh_power_slot_buttons()

func _update_power_wheel_input(delta: float) -> void:
    var input_dir := Vector2.ZERO
    input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
    input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
    if input_dir.length_squared() > 0.0:
        power_bias += input_dir.normalized() * POWER_WHEEL_INPUT_SPEED * delta
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        var viewport_center := get_viewport_rect().size * Vector2(0.5, 0.5)
        var delta_vec: Vector2 = (get_global_mouse_position() - viewport_center) / max(POWER_WHEEL_RADIUS, 1.0)
        power_bias = delta_vec.clamp(Vector2.ONE * -1.0, Vector2.ONE)
    power_bias = power_bias.limit_length(1.0)
    _recalculate_power_distribution()

func _toggle_power_customize_panel() -> void:
    if power_customize_panel == null:
        return
    power_customize_panel.visible = not power_customize_panel.visible
    if not power_customize_panel.visible:
        power_swap_source_slot = -1
    _refresh_power_slot_buttons()

func _on_power_slot_button_pressed(slot_index: int) -> void:
    if slot_index < 0 or slot_index >= power_slot_order.size():
        return
    if power_swap_source_slot == -1:
        power_swap_source_slot = slot_index
        _refresh_power_slot_buttons()
        return
    if power_swap_source_slot == slot_index:
        power_swap_source_slot = -1
        _refresh_power_slot_buttons()
        return
    var source_key: String = power_slot_order[power_swap_source_slot]
    power_slot_order[power_swap_source_slot] = power_slot_order[slot_index]
    power_slot_order[slot_index] = source_key
    power_swap_source_slot = -1
    _recalculate_power_distribution()

func _refresh_power_slot_buttons() -> void:
    for slot_index in range(power_slot_buttons.size()):
        var button := power_slot_buttons[slot_index]
        if button == null:
            continue
        if slot_index >= power_slot_order.size():
            button.visible = false
            button.disabled = true
            continue
        button.visible = true
        button.disabled = false
        var key: String = power_slot_order[slot_index]
        var label_text := "Slot %d: %s" % [slot_index + 1, key.replace("_", " ").capitalize()]
        if slot_index == power_swap_source_slot:
            label_text = "%s  [%s]" % [label_text, tr("Selected")]
        button.text = label_text
        button.modulate = Color(1.0, 0.88, 0.62, 1.0) if slot_index == power_swap_source_slot else Color.WHITE
    if power_customize_selection_label != null:
        if power_swap_source_slot == -1:
            power_customize_selection_label.text = tr("No slot selected.")
        else:
            var selected_key: String = power_slot_order[power_swap_source_slot]
            power_customize_selection_label.text = tr("Selected slot %d: %s. Pick another slot to swap.") % [
                power_swap_source_slot + 1,
                selected_key.replace("_", " ").capitalize()
            ]

func _get_effective_fire_interval() -> float:
    return fire_interval / max(_get_gun_power_multiplier(), 0.2)

func _get_effective_shield_max() -> float:
    return shield_max * _get_power_multiplier("shields")

func _get_effective_shield_regen() -> float:
    return shield_regen_rate * _get_power_multiplier("shields")

func _get_effective_tower_range() -> float:
    return tower_range * _get_power_multiplier("towers")

func _get_effective_tower_fire_interval() -> float:
    return tower_fire_interval / max(_get_power_multiplier("towers"), 0.2)

func _get_effective_tower_damage() -> float:
    return tower_damage * _get_power_multiplier("towers")

func _get_effective_drone_range() -> float:
    return drone_range * _get_power_multiplier("helpers")

func _get_effective_drone_fire_interval() -> float:
    return drone_fire_interval / max(_get_power_multiplier("helpers"), 0.2)

func _get_effective_drone_damage() -> float:
    return drone_damage * _get_power_multiplier("helpers")

func _get_effective_tentacle_range() -> float:
    return tentacle_range * _get_power_multiplier("tentacles")

func _get_effective_tentacle_cooldown() -> float:
    return tentacle_attack_cooldown / max(_get_power_multiplier("tentacles"), 0.2)

func _get_effective_tentacle_damage() -> float:
    return tentacle_damage * _get_power_multiplier("tentacles")

func _get_effective_scrap_generation_per_second() -> float:
    return scrap_generation_per_second * _get_power_multiplier("scrap_gain")

func _get_scaled_nuke_regen_gain() -> int:
    return maxi(1, int(round(float(nuke_regen_per_wave) * _get_power_multiplier("nukes"))))

func _auto_launch_nuke() -> void:
    if remaining_nukes <= 0 or enemies.is_empty():
        return
    var target_pos := _get_highest_threat_enemy_position()
    if target_pos == Vector2.ZERO:
        return
    remaining_nukes -= 1
    nukes_launched += 1
    nukes.append({"pos": _get_base_position(), "target": target_pos, "vel": (target_pos - _get_base_position()).normalized() * NUKE_SPEED})

func _get_highest_threat_enemy_position() -> Vector2:
    var best_pos := Vector2.ZERO
    var best_threat := -INF
    var base_pos := _get_base_position()
    for enemy in enemies:
        var enemy_pos: Vector2 = enemy.get("pos", Vector2.ZERO)
        var threat: float = float(enemy.get("health", 0.0)) + float(enemy.get("contact_damage", 0.0)) * 4.0
        threat += max(0.0, 800.0 - enemy_pos.distance_to(base_pos)) * 0.15
        if threat > best_threat:
            best_threat = threat
            best_pos = enemy_pos
    return best_pos

func _get_tentacle_anchor_positions() -> Array[Vector2]:
    var positions: Array[Vector2] = []
    var base_pos := _get_base_position() + _get_base_visual_offset()
    for tentacle_index in range(tentacle_count):
        var angle: float = lerpf(-PI * 0.82, -PI * 0.18, float(tentacle_index + 1) / float(tentacle_count + 1))
        positions.append(base_pos + Vector2(cos(angle), sin(angle)) * (BASE_RADIUS + 14.0))
    return positions

func _is_point_far_offscreen(point: Vector2, margin: float) -> bool:
    var viewport := get_viewport_rect().size
    return point.x < -margin or point.x > viewport.x + margin or point.y < -margin or point.y > viewport.y + margin

func _spawn_floating_text(text: String, position: Vector2, color: Color, font_size: int = 22) -> void:
    floating_texts.append({"text": text, "pos": position, "color": color, "font_size": font_size, "age": 0.0})

func _process_floating_texts(delta: float) -> void:
    for text_index in range(floating_texts.size() - 1, -1, -1):
        var entry: Dictionary = floating_texts[text_index]
        entry["age"] = float(entry.get("age", 0.0)) + delta
        entry["pos"] = entry.get("pos", Vector2.ZERO) + Vector2(0.0, -38.0) * delta
        if float(entry.get("age", 0.0)) >= FLOATING_TEXT_DURATION:
            floating_texts.remove_at(text_index)
        else:
            var alpha: float = 1.0 - float(entry.get("age", 0.0)) / FLOATING_TEXT_DURATION
            var color: Color = entry.get("color", Color.WHITE)
            entry["color"] = Color(color.r, color.g, color.b, alpha)
            floating_texts[text_index] = entry

func _get_enemy_display_name(enemy_type: String) -> String:
    match enemy_type:
        "dronelet":
            return tr("Dronelet")
        "interceptor":
            return tr("Interceptor")
        "artillery":
            return tr("Artillery")
        "brute":
            return tr("Brute")
        "skimmer":
            return tr("Skimmer")
        "siege":
            return tr("Siege Barge")
        "carrier":
            return tr("Mothership")
        "destroyer":
            return tr("Destroyer")
        "command_ship":
            return tr("Command Ship")
        "dreadnought":
            return tr("Dreadnought")
        "runner":
            return tr("Runner")
        "gunship":
            return tr("Gunship")
        "bomber":
            return tr("Bomber")
        BOSS_TYPE:
            return tr("War Barge")
        _:
            return tr("Raider")

func _reset_aim_cursor() -> void:
    aim_cursor_screen_pos = get_viewport_rect().size * 0.5

func _clamp_cursor_to_viewport(position: Vector2) -> Vector2:
    var viewport_size := get_viewport_rect().size
    return Vector2(clampf(position.x, 0.0, max(viewport_size.x - 1.0, 0.0)), clampf(position.y, 0.0, max(viewport_size.y - 1.0, 0.0)))

func _is_power_wheel_mouse_drag_active() -> bool:
    return (
        run_state == RUN_STATES.RUNNING
        and Global.game_state == Util.GAME_STATES.PLAYING
        and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
        and not _should_keep_mouse_visible_for_wave_intro()
    )

func _refresh_mouse_capture_state() -> void:
    if _is_pause_menu_open():
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        return
    var in_combat := run_state == RUN_STATES.RUNNING and Global.game_state == Util.GAME_STATES.PLAYING
    if in_combat and _should_keep_mouse_visible_for_wave_intro():
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        return
    if in_combat and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        return
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if in_combat else Input.MOUSE_MODE_VISIBLE

func _should_keep_mouse_visible_for_wave_intro() -> bool:
    if run_start_banner_panel != null and run_start_banner_panel.visible:
        return true
    return Time.get_ticks_msec() < _suppress_mouse_capture_until_msec

func _handle_pause_menu_input(event: InputEvent) -> bool:
    if event.is_action_pressed("escape") or event.is_action_pressed("back"):
        if _is_pause_menu_open():
            _close_pause_menu()
        elif _can_open_pause_menu():
            _open_pause_menu()
        get_viewport().set_input_as_handled()
        return true
    if _is_pause_menu_open():
        return true
    return false

func _can_open_pause_menu() -> bool:
    return true

func _is_pause_menu_open() -> bool:
    return pause_menu != null and pause_menu.is_open()

func _open_pause_menu() -> void:
    if pause_menu == null:
        return
    pause_menu.open_menu()
    _refresh_mouse_capture_state()

func _close_pause_menu() -> void:
    if pause_menu == null:
        return
    pause_menu.close_menu()
    _refresh_mouse_capture_state()

func _on_pause_resume_requested() -> void:
    _close_pause_menu()

func _on_pause_end_run_requested() -> void:
    _close_pause_menu()
    _end_run_to_summary()

func _end_run_to_summary() -> void:
    _suppress_mouse_capture_until_msec = 0
    _finish_run("Run ended early.", true)

func _update_environment(delta: float) -> void:
    var base_darkness := clampf(float(max(current_wave - 1, 0)) / 11.0, 0.0, 0.82)
    var target_darkness := base_darkness
    if run_state == RUN_STATES.UPGRADE:
        target_darkness = max(0.0, base_darkness - 0.2)
    elif run_state == RUN_STATES.DEFEAT:
        target_darkness = min(0.96, base_darkness + 0.22)
    elif run_state == RUN_STATES.SUMMARY:
        target_darkness = min(0.9, base_darkness + 0.08)
    environment_darkness = lerpf(environment_darkness, target_darkness, clampf(delta * 1.2, 0.0, 1.0))
    sun_progress = lerpf(sun_progress, target_darkness, clampf(delta * 0.9, 0.0, 1.0))

func _get_enemy_rotation(enemy: Dictionary) -> float:
    var velocity: Vector2 = enemy.get("vel", Vector2.ZERO)
    if velocity.length_squared() <= 0.001:
        velocity = _get_base_position() - enemy.get("pos", Vector2.ZERO)
    return velocity.angle() + PI * 0.5

func _build_rotated_points(local_points: Array, rotation: float, center: Vector2) -> PackedVector2Array:
    var points := PackedVector2Array()
    for point in local_points:
        var local_point: Vector2 = point
        points.append(center + local_point.rotated(rotation))
    return points

func _color_to_bbcode(color: Color) -> String:
    return color.to_html(false)

func _style_summary_panel_box(panel: PanelContainer, background_color: Color, border_color: Color, corner_radius: int) -> void:
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

func _apply_summary_theme() -> void:
    _style_summary_panel_box(summary_panel, SUMMARY_PANEL_BG, SUMMARY_PANEL_BORDER, 6)
    _style_summary_panel_box(summary_payout_chart, SUMMARY_CHART_PANEL_BG, SUMMARY_CHART_PANEL_BORDER, 6)
    _style_summary_panel_box(summary_combat_chart, SUMMARY_CHART_PANEL_BG, SUMMARY_CHART_PANEL_BORDER, 6)
    _style_summary_panel_box(summary_damage_chart, SUMMARY_CHART_PANEL_BG, SUMMARY_CHART_PANEL_BORDER, 6)
    if summary_title_label != null:
        summary_title_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
        summary_title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.08, 0.85))
        summary_title_label.add_theme_constant_override("outline_size", 1)
    if summary_stats_label != null:
        summary_stats_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
    if start_wave_header_label != null:
        start_wave_header_label.add_theme_color_override("font_color", Color(0.76, 0.9, 1.0, 1.0))
    if start_wave_info_label != null:
        start_wave_info_label.add_theme_color_override("font_color", Color(0.83, 0.9, 1.0, 1.0))
    if start_wave_dropdown != null:
        start_wave_dropdown.add_theme_font_size_override("font_size", 18)
        start_wave_dropdown.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0, 1.0))
        start_wave_dropdown.add_theme_color_override("font_hover_color", Color(1.0, 0.99, 0.96, 1.0))
        start_wave_dropdown.add_theme_color_override("font_pressed_color", Color(1.0, 0.98, 0.94, 1.0))
        start_wave_dropdown.add_theme_color_override("font_focus_color", Color(1.0, 0.99, 0.96, 1.0))
        start_wave_dropdown.add_theme_constant_override("outline_size", 2)
        start_wave_dropdown.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.05, 0.92))
    if summary_label != null:
        summary_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        summary_label.add_theme_font_size_override("normal_font_size", 20)
        summary_label.add_theme_color_override("default_color", SUMMARY_TEXT_BASE_COLOR)
        summary_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
        summary_label.add_theme_constant_override("shadow_offset_x", 1)
        summary_label.add_theme_constant_override("shadow_offset_y", 1)
    if summary_hint_panel != null:
        _style_summary_panel_box(summary_hint_panel, SUMMARY_CHART_PANEL_BG, SUMMARY_CHART_PANEL_BORDER, 4)
    if summary_hint_title_label != null:
        summary_hint_title_label.add_theme_color_override("font_color", SUMMARY_CHART_TITLE_COLOR)
        summary_hint_title_label.add_theme_font_size_override("font_size", 14)
    if summary_hint_label != null:
        summary_hint_label.add_theme_color_override("font_color", SUMMARY_TEXT_BASE_COLOR)
        summary_hint_label.add_theme_font_size_override("font_size", 14)
    if summary_hint_left_button != null:
        summary_hint_left_button.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0, 1.0))
    if summary_hint_right_button != null:
        summary_hint_right_button.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0, 1.0))
    if continue_button != null:
        continue_button.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0, 1.0))
    if retry_button != null:
        retry_button.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0, 1.0))

func _reset_summary_presentation_state() -> void:
    _reset_summary_chart_animation_state()
    if summary_text_tween != null and summary_text_tween.is_running():
        summary_text_tween.kill()
    if summary_text_pop_tween != null and summary_text_pop_tween.is_running():
        summary_text_pop_tween.kill()
    summary_text_view_model.clear()
    summary_text_progress = 0.0
    summary_text_money_pop_progress = 0.0
    summary_hints.clear()
    _refresh_summary_hint()

func _show_post_run_summary(results: Dictionary) -> void:
    _reset_summary_presentation_state()
    _refresh_summary_payout_chart(results)
    _refresh_summary_combat_chart(results)
    _refresh_summary_damage_chart(results)
    _start_summary_chart_animation()
    var view_model: Dictionary = results.get("summary_view_model", {})
    summary_text_view_model = view_model.duplicate(true)
    if summary_text_tween != null and summary_text_tween.is_running():
        summary_text_tween.kill()
    summary_text_progress = 0.0
    summary_text_money_pop_progress = 0.0
    _render_post_run_summary_text(view_model, 0.0)
    _setup_summary_hints(view_model)
    var wallet_gain: float = float(view_model.get("wallet_gain", 0))
    var duration: float = _get_summary_text_animation_duration(wallet_gain)
    if duration <= 0.0:
        summary_text_progress = 1.0
        _render_post_run_summary_text(view_model, 1.0)
        _play_summary_text_pop()
        return
    summary_text_tween = create_tween()
    summary_text_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    summary_text_tween.tween_method(
        func(progress: float) -> void:
            summary_text_progress = progress
            _render_post_run_summary_text(view_model, progress),
        0.0,
        1.0,
        duration
    )
    summary_text_tween.finished.connect(func() -> void:
        summary_text_progress = 1.0
        _render_post_run_summary_text(view_model, 1.0)
        _play_summary_text_pop()
    )

func _get_animated_money_value(target_value: int, progress: float) -> int:
    var eased_progress: float = 0.5 - 0.5 * cos(PI * clampf(progress, 0.0, 1.0))
    return int(round(float(target_value) * eased_progress))

func _format_summary_money_span(current_value: int, target_value: int, progress: float) -> String:
    var animated_color: Color = SUMMARY_TEXT_MONEY_GREY.lerp(SUMMARY_TEXT_MONEY_HIGH, clampf(progress, 0.0, 1.0))
    var shown_value: int = clampi(current_value, 0, max(0, target_value))
    var money_font_size: int = int(round(lerpf(
        float(SUMMARY_TEXT_MONEY_BASE_FONT_SIZE),
        float(SUMMARY_TEXT_MONEY_POP_FONT_SIZE),
        clampf(summary_text_money_pop_progress, 0.0, 1.0)
    )))
    return "[font_size=%d][color=%s]%s scrap[/color][/font_size]" % [
        money_font_size,
        _color_to_bbcode(animated_color),
        Util.get_number_short_text(shown_value)
    ]

func _render_post_run_summary_text(view_model: Dictionary, progress: float) -> void:
    var reason: String = String(view_model.get("reason", "Run complete"))
    var waves_run: int = int(view_model.get("waves_cleared_this_run", 0))
    var wallet_gain: int = int(view_model.get("wallet_gain", 0))
    var animated_wallet: int = _get_animated_money_value(wallet_gain, progress)
    var lines := PackedStringArray([
        "[color=%s]Run ended: %s[/color]" % [_color_to_bbcode(SUMMARY_TEXT_BASE_COLOR), reason],
        "",
        "[color=%s]Waves cleared this run: %d[/color]" % [_color_to_bbcode(SUMMARY_TEXT_BASE_COLOR), waves_run],
        "",
        "[color=%s]Meta scrap earned[/color]" % _color_to_bbcode(SUMMARY_TEXT_BASE_COLOR),
        "%s" % _format_summary_money_span(animated_wallet, wallet_gain, progress)
    ])
    if bool(view_model.get("show_cursor_escape_hint", false)):
        lines.append("")
        lines.append(
            "[i][color=%s]%s[/color][/i]" % [
                _color_to_bbcode(SUMMARY_TEXT_BASE_COLOR),
                tr("RED_SKY_SUMMARY_PRESS_ESCAPE_IF_CURSOR_MISSING")
            ]
        )
    summary_label.clear()
    summary_label.append_text("\n".join(lines))

func _get_summary_text_animation_duration(total_wallet: float) -> float:
    var chart_duration: float = _get_summary_chart_max_duration()
    if chart_duration > 0.0:
        return chart_duration
    if total_wallet <= 0.0:
        return 0.0
    return _summary_chart_animation_duration(total_wallet, total_wallet)

func _make_summary_chart_label(text: String, min_width: float, font_size: int, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, color: Color = Color(0.9, 0.95, 1.0, 1.0)) -> Label:
    var label := Label.new()
    label.text = text
    if min_width > 0.0:
        label.custom_minimum_size.x = min_width
    label.horizontal_alignment = align
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    return label

func _make_summary_chart_bar_bundle(max_value: float, color: Color) -> Dictionary:
    var root := HBoxContainer.new()
    root.custom_minimum_size = Vector2(200.0, 0.0)
    root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_theme_constant_override("separation", 10)
    var meter := ProgressBar.new()
    meter.custom_minimum_size = Vector2(120.0, 18.0)
    meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    meter.show_percentage = false
    meter.max_value = max(1.0, max_value)
    meter.value = 0.0
    var background := StyleBoxFlat.new()
    background.bg_color = SUMMARY_METER_TRACK
    background.corner_radius_top_left = 3
    background.corner_radius_top_right = 3
    background.corner_radius_bottom_left = 3
    background.corner_radius_bottom_right = 3
    meter.add_theme_stylebox_override("background", background)
    var fill := background.duplicate(true)
    fill.bg_color = color
    meter.add_theme_stylebox_override("fill", fill)
    root.add_child(meter)
    var value_label := _make_summary_chart_label("0", 52.0, 15, HORIZONTAL_ALIGNMENT_RIGHT, SUMMARY_CHART_VALUE_COLOR)
    root.add_child(value_label)
    return {"root": root, "meter": meter, "value_label": value_label}

func _format_summary_chart_value(value: float) -> String:
    if value >= 1000.0:
        return "%0.1fk" % (value / 1000.0)
    if value >= 100.0:
        return str(int(round(value)))
    return "%0.1f" % value if value != floor(value) else str(int(value))

func _clear_chart_children(panel: Control) -> void:
    for child in panel.get_children():
        panel.remove_child(child)
        child.queue_free()

func _append_summary_chart_row_if_positive(rows: Array, label: String, value: float, color: Color) -> void:
    if value <= 0.0001:
        return
    rows.append({"label": label, "money": value, "color": color})

func _make_chart_margin(parent: Control) -> MarginContainer:
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_bottom", 12)
    parent.add_child(margin)
    return margin

func _refresh_summary_payout_chart(results: Dictionary) -> void:
    _clear_chart_children(summary_payout_chart)
    var margin := _make_chart_margin(summary_payout_chart)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 10)
    margin.add_child(root)
    root.add_child(_make_summary_chart_label("Scrap payout", 0.0, 20, HORIZONTAL_ALIGNMENT_CENTER, SUMMARY_CHART_TITLE_COLOR))
    var rows: Array = results.get("payout_breakdown_chart", [])
    var max_money: float = 0.0
    for row_variant in rows:
        max_money = max(max_money, float(row_variant.get("money", 0.0)))
    if rows.is_empty():
        root.add_child(_make_summary_chart_label("No scrap recorded", 0.0, 16, HORIZONTAL_ALIGNMENT_CENTER, SUMMARY_CHART_MUTED_COLOR))
        return
    for row_variant in rows:
        var row_data: Dictionary = row_variant
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 10)
        root.add_child(row)
        row.add_child(_make_summary_chart_label(str(row_data.get("label", "")), 150.0, 15))
        var target_value: float = float(row_data.get("money", 0.0))
        var bar_bundle: Dictionary = _make_summary_chart_bar_bundle(max_money, row_data.get("color", Color(0.9, 0.75, 0.4, 1.0)))
        row.add_child(bar_bundle.get("root", HBoxContainer.new()))
        _register_summary_chart_animation(
            row,
            bar_bundle.get("meter", null),
            bar_bundle.get("value_label", null),
            target_value,
            _summary_chart_animation_duration(target_value, max_money)
        )

func _refresh_summary_combat_chart(results: Dictionary) -> void:
    _clear_chart_children(summary_combat_chart)
    var margin := _make_chart_margin(summary_combat_chart)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 10)
    margin.add_child(root)
    root.add_child(_make_summary_chart_label("Run performance", 0.0, 20, HORIZONTAL_ALIGNMENT_CENTER, SUMMARY_CHART_TITLE_COLOR))
    var rows: Array = results.get("combat_breakdown_chart", [])
    var max_value: float = 0.0
    for row_variant in rows:
        max_value = max(max_value, float(row_variant.get("money", 0.0)))
    if rows.is_empty():
        root.add_child(_make_summary_chart_label("No combat data", 0.0, 16, HORIZONTAL_ALIGNMENT_CENTER, SUMMARY_CHART_MUTED_COLOR))
        return
    for row_variant in rows:
        var row_data: Dictionary = row_variant
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 10)
        root.add_child(row)
        row.add_child(_make_summary_chart_label(str(row_data.get("label", "")), 150.0, 15))
        var target_value: float = float(row_data.get("money", 0.0))
        var bar_bundle: Dictionary = _make_summary_chart_bar_bundle(max_value, row_data.get("color", Color.WHITE))
        row.add_child(bar_bundle.get("root", HBoxContainer.new()))
        _register_summary_chart_animation(
            row,
            bar_bundle.get("meter", null),
            bar_bundle.get("value_label", null),
            target_value,
            _summary_chart_animation_duration(target_value, max_value)
        )

func _refresh_summary_damage_chart(results: Dictionary) -> void:
    _clear_chart_children(summary_damage_chart)
    var margin := _make_chart_margin(summary_damage_chart)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 8)
    margin.add_child(root)
    root.add_child(_make_summary_chart_label(tr("Damage dealt & prevented"), 0.0, 20, HORIZONTAL_ALIGNMENT_CENTER, SUMMARY_CHART_TITLE_COLOR))
    var dealt: Array = results.get("damage_dealt_breakdown", [])
    var prevented: Array = results.get("damage_prevented_breakdown", [])
    if dealt.is_empty() and prevented.is_empty():
        root.add_child(_make_summary_chart_label(tr("No damage data"), 0.0, 16, HORIZONTAL_ALIGNMENT_CENTER, SUMMARY_CHART_MUTED_COLOR))
        return
    var max_dealt: float = 0.0
    for row_variant in dealt:
        max_dealt = max(max_dealt, float(row_variant.get("money", 0.0)))
    var max_prevented: float = 0.0
    for row_variant in prevented:
        max_prevented = max(max_prevented, float(row_variant.get("money", 0.0)))
    if not dealt.is_empty():
        root.add_child(_make_summary_chart_label(tr("Dealt"), 0.0, 14, HORIZONTAL_ALIGNMENT_LEFT, SUMMARY_CHART_MUTED_COLOR))
        for row_variant in dealt:
            var row_data: Dictionary = row_variant
            var row := HBoxContainer.new()
            row.add_theme_constant_override("separation", 10)
            root.add_child(row)
            row.add_child(_make_summary_chart_label(str(row_data.get("label", "")), 150.0, 15))
            var target_value: float = float(row_data.get("money", 0.0))
            var bar_bundle: Dictionary = _make_summary_chart_bar_bundle(max_dealt, row_data.get("color", Color.WHITE))
            row.add_child(bar_bundle.get("root", HBoxContainer.new()))
            _register_summary_chart_animation(
                row,
                bar_bundle.get("meter", null),
                bar_bundle.get("value_label", null),
                target_value,
                _summary_chart_animation_duration(target_value, max_dealt)
            )
    if not prevented.is_empty():
        root.add_child(_make_summary_chart_label(tr("Prevented"), 0.0, 14, HORIZONTAL_ALIGNMENT_LEFT, SUMMARY_CHART_MUTED_COLOR))
        for row_variant in prevented:
            var row_data: Dictionary = row_variant
            var row := HBoxContainer.new()
            row.add_theme_constant_override("separation", 10)
            root.add_child(row)
            row.add_child(_make_summary_chart_label(str(row_data.get("label", "")), 150.0, 15))
            var target_value: float = float(row_data.get("money", 0.0))
            var bar_bundle: Dictionary = _make_summary_chart_bar_bundle(max_prevented, row_data.get("color", Color.WHITE))
            row.add_child(bar_bundle.get("root", HBoxContainer.new()))
            _register_summary_chart_animation(
                row,
                bar_bundle.get("meter", null),
                bar_bundle.get("value_label", null),
                target_value,
                _summary_chart_animation_duration(target_value, max_prevented)
            )

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

func _reset_summary_chart_animation_state() -> void:
    summary_chart_animation_active = false
    summary_chart_tick_timer = 0.0
    summary_chart_animation_entries.clear()
    summary_chart_animation_session_id += 1

func _get_summary_chart_max_duration() -> float:
    var longest_duration := 0.0
    for entry in summary_chart_animation_entries:
        longest_duration = max(longest_duration, float(entry.get("duration", 0.0)))
    return longest_duration

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
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)
    else:
        summary_chart_animation_active = false
        summary_chart_tick_timer = 0.0

func _play_summary_chart_pop(row: Control) -> void:
    if row == null:
        return
    row.scale = Vector2.ONE
    row.pivot_offset = row.size * 0.5
    var pop_tween: Tween = create_tween()
    pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    pop_tween.tween_property(row, "scale", Vector2.ONE * SUMMARY_CHART_POP_SCALE, 0.12)
    pop_tween.tween_property(row, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _play_summary_text_pop() -> void:
    if summary_label == null or summary_text_view_model.is_empty():
        return
    if summary_text_pop_tween != null and summary_text_pop_tween.is_running():
        summary_text_pop_tween.kill()
    summary_text_money_pop_progress = 0.0
    summary_text_pop_tween = create_tween()
    summary_text_pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    summary_text_pop_tween.tween_method(
        func(pop_progress: float) -> void:
            summary_text_money_pop_progress = pop_progress
            _render_post_run_summary_text(summary_text_view_model, summary_text_progress),
        0.0,
        1.0,
        0.14
    )
    summary_text_pop_tween.tween_method(
        func(pop_progress: float) -> void:
            summary_text_money_pop_progress = pop_progress
            _render_post_run_summary_text(summary_text_view_model, summary_text_progress),
        1.0,
        0.0,
        0.12
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    summary_text_pop_tween.finished.connect(func() -> void:
        summary_text_money_pop_progress = 0.0
        _render_post_run_summary_text(summary_text_view_model, summary_text_progress)
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.MINING_SUMMARY_DING)
    , CONNECT_ONE_SHOT)

func _on_continue_pressed() -> void:
    Global.start_in_upgrade_scene = true
    SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _on_retry_pressed() -> void:
    _begin_run()
