extends Node2D
class_name ReelIntoDarknessMain

const REEL_DATA := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessData.gd")
const REEL_PROGRESS := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessProgress.gd")

const SURFACE_RATIO := 0.2
const WATER_SIDE_MARGIN := 96.0
const WATER_BOTTOM_MARGIN := 82.0
const BOAT_INTRO_SPEED := 520.0
const BOAT_EXIT_SPEED := 560.0
const BOAT_BOB_SPEED := 2.2
const BOAT_BOB_HEIGHT := 5.0
const HOOK_X_SPRING := 4.2
const HOOK_X_DAMPING := 2.6
const HOOK_MOUSE_DECAY := 5.0
const HOOK_GRAVITY := 18.0
const HOOK_MAX_SWING_SPEED := 260.0
const BITE_DISTANCE := 34.0
const BITE_INTEREST_GAIN := 1.2
const BITE_INTEREST_LOSS := 0.65
const FIGHT_SIDE_MARGIN := 10.0
const FIGHT_PHASE_MIN := 0.55
const FIGHT_PHASE_MAX := 1.0
const SUMMARY_BAR_MIN_DURATION := 0.8
const SUMMARY_BAR_MAX_DURATION := 2.6
const SUMMARY_MONEY_MIN_DURATION := 0.9
const SUMMARY_MONEY_MAX_DURATION := 2.8
const SUMMARY_MONEY_POP_SCALE := 1.12
const FISH_SPAWN_PADDING := 44.0
const FISH_COUNT_MIN := 14
const FISH_COUNT_MAX := 24

enum RunState {
	INTRO,
	READY,
	DESCENDING,
	REELING,
	HOOKED,
	RUN_END_RETRACT,
	RUN_END_EXIT,
	SUMMARY,
}

var rng := RandomNumberGenerator.new()
var run_state: RunState = RunState.INTRO
var run_config: Dictionary = {}
var fish_catalog: Array[Dictionary] = []
var fish_entities: Array[Dictionary] = []

var boat_pos := Vector2.ZERO
var boat_target_pos := Vector2.ZERO
var boat_size := Vector2(190.0, 54.0)
var boat_bob_time := 0.0

var hook_x := 0.0
var hook_target_x := 0.0
var hook_depth := 0.0
var hook_horizontal_velocity := 0.0
var hook_vertical_velocity := 0.0
var mouse_sway_velocity := 0.0

var timer_left := 0.0
var deepest_depth_reached := 0.0
var hook_blink_timer := 0.0

var hooked_fish_index := -1
var player_stamina_max := 0.0
var player_stamina := 0.0
var fish_stamina_max := 0.0
var fish_stamina := 0.0
var meters_per_fish_stamina := 1.0
var fight_phase_timer := 0.0
var fight_phase_duration := 0.0
var desired_hold := true
var desired_side := 0
var fight_feedback_text := ""
var fight_feedback_timer := 0.0
var total_mistakes := 0
var total_bites := 0
var total_fish_lost := 0
var total_clean_pulls := 0

var summary_results: Dictionary = {}
var summary_money_target := 0
var summary_money_value := 0
var summary_money_tween: Tween
var summary_money_pop_tween: Tween
var summary_chart_tweens: Array[Tween] = []
var summary_ready_for_input := false

var canvas_layer: CanvasLayer
var hud_panel: PanelContainer
var timer_label: Label
var depth_label: Label
var wallet_label: Label
var prompt_label: Label
var status_label: Label
var player_stamina_bar: ProgressBar
var fish_stamina_bar: ProgressBar
var player_stamina_value_label: Label
var fish_stamina_value_label: Label

var summary_overlay: ColorRect
var summary_panel: PanelContainer
var summary_title_label: Label
var summary_money_label: Label
var summary_stats_label: Label
var summary_catch_log_label: Label
var summary_species_chart: VBoxContainer
var summary_run_chart: VBoxContainer
var summary_continue_button: Button
var summary_again_button: Button

func _ready() -> void:
	Global.game_state = Util.GAME_STATES.PLAYING
	rng.randomize()
	run_config = REEL_PROGRESS.get_run_config()
	fish_catalog = REEL_DATA.get_fish_catalog()
	_build_ui()
	_begin_run()

func _build_ui() -> void:
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

	hud_panel = PanelContainer.new()
	hud_panel.anchor_left = 0.0
	hud_panel.anchor_top = 0.0
	hud_panel.anchor_right = 0.0
	hud_panel.anchor_bottom = 0.0
	hud_panel.offset_left = 22.0
	hud_panel.offset_top = 18.0
	hud_panel.offset_right = 570.0
	hud_panel.offset_bottom = 250.0
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_panel_style(hud_panel, Color(0.04, 0.08, 0.12, 0.92), Color(0.24, 0.56, 0.68, 1.0))
	canvas_layer.add_child(hud_panel)

	var hud_margin := MarginContainer.new()
	hud_margin.add_theme_constant_override("margin_left", 16)
	hud_margin.add_theme_constant_override("margin_top", 14)
	hud_margin.add_theme_constant_override("margin_right", 16)
	hud_margin.add_theme_constant_override("margin_bottom", 14)
	hud_panel.add_child(hud_margin)

	var hud_root := VBoxContainer.new()
	hud_root.add_theme_constant_override("separation", 8)
	hud_margin.add_child(hud_root)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 12)
	hud_root.add_child(top_row)

	timer_label = _make_label("00.0s", 28, Color(0.97, 0.9, 0.6, 1.0))
	timer_label.custom_minimum_size = Vector2(140.0, 34.0)
	top_row.add_child(timer_label)

	depth_label = _make_label("Depth 0.0m", 22, Color(0.78, 0.9, 0.99, 1.0))
	depth_label.custom_minimum_size = Vector2(160.0, 32.0)
	top_row.add_child(depth_label)

	wallet_label = _make_label("Haul $0", 22, Color(0.68, 0.97, 0.77, 1.0))
	wallet_label.custom_minimum_size = Vector2(180.0, 32.0)
	top_row.add_child(wallet_label)

	prompt_label = _make_label("", 24, Color(0.95, 0.98, 1.0, 1.0))
	prompt_label.custom_minimum_size = Vector2(0.0, 70.0)
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud_root.add_child(prompt_label)

	status_label = _make_label("", 18, Color(0.73, 0.85, 0.95, 1.0))
	status_label.custom_minimum_size = Vector2(0.0, 30.0)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud_root.add_child(status_label)

	var stamina_column := VBoxContainer.new()
	stamina_column.add_theme_constant_override("separation", 6)
	hud_root.add_child(stamina_column)

	var player_row := _make_bar_row("Your Stamina", Color(0.43, 0.83, 0.97, 1.0))
	player_stamina_bar = player_row["bar"]
	player_stamina_value_label = player_row["value"]
	stamina_column.add_child(player_row["root"])

	var fish_row := _make_bar_row("Fish Stamina", Color(0.96, 0.47, 0.32, 1.0))
	fish_stamina_bar = fish_row["bar"]
	fish_stamina_value_label = fish_row["value"]
	stamina_column.add_child(fish_row["root"])

	summary_overlay = ColorRect.new()
	summary_overlay.anchor_right = 1.0
	summary_overlay.anchor_bottom = 1.0
	summary_overlay.color = Color(0.01, 0.02, 0.04, 0.0)
	summary_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	summary_overlay.visible = false
	canvas_layer.add_child(summary_overlay)

	summary_panel = PanelContainer.new()
	summary_panel.anchor_left = 0.5
	summary_panel.anchor_top = 0.5
	summary_panel.anchor_right = 0.5
	summary_panel.anchor_bottom = 0.5
	summary_panel.offset_left = -520.0
	summary_panel.offset_top = -300.0
	summary_panel.offset_right = 520.0
	summary_panel.offset_bottom = 300.0
	summary_panel.modulate.a = 0.0
	_apply_panel_style(summary_panel, Color(0.04, 0.07, 0.11, 0.96), Color(0.28, 0.64, 0.76, 1.0))
	summary_overlay.add_child(summary_panel)

	var summary_margin := MarginContainer.new()
	summary_margin.add_theme_constant_override("margin_left", 22)
	summary_margin.add_theme_constant_override("margin_top", 18)
	summary_margin.add_theme_constant_override("margin_right", 22)
	summary_margin.add_theme_constant_override("margin_bottom", 18)
	summary_panel.add_child(summary_margin)

	var summary_root := VBoxContainer.new()
	summary_root.add_theme_constant_override("separation", 12)
	summary_margin.add_child(summary_root)

	summary_title_label = _make_label("Run Summary", 34, Color(0.95, 0.98, 1.0, 1.0))
	summary_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_root.add_child(summary_title_label)

	summary_money_label = _make_label("$0", 40, Color(0.64, 0.97, 0.76, 1.0))
	summary_money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_root.add_child(summary_money_label)

	var summary_body := HBoxContainer.new()
	summary_body.add_theme_constant_override("separation", 18)
	summary_root.add_child(summary_body)

	var left_column := VBoxContainer.new()
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_theme_constant_override("separation", 10)
	summary_body.add_child(left_column)

	summary_stats_label = _make_label("", 18, Color(0.86, 0.92, 0.98, 1.0))
	summary_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_stats_label.custom_minimum_size = Vector2(430.0, 120.0)
	left_column.add_child(summary_stats_label)

	summary_catch_log_label = _make_label("", 17, Color(0.82, 0.89, 0.97, 1.0))
	summary_catch_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_catch_log_label.custom_minimum_size = Vector2(430.0, 240.0)
	left_column.add_child(summary_catch_log_label)

	var right_column := VBoxContainer.new()
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.add_theme_constant_override("separation", 12)
	summary_body.add_child(right_column)

	summary_species_chart = VBoxContainer.new()
	summary_species_chart.add_theme_constant_override("separation", 8)
	right_column.add_child(_wrap_chart("Catch Value", summary_species_chart))

	summary_run_chart = VBoxContainer.new()
	summary_run_chart.add_theme_constant_override("separation", 8)
	right_column.add_child(_wrap_chart("Run Stats", summary_run_chart))

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 16)
	summary_root.add_child(button_row)

	summary_again_button = Button.new()
	summary_again_button.text = "Fish Again"
	summary_again_button.custom_minimum_size = Vector2(180.0, 52.0)
	summary_again_button.pressed.connect(_on_summary_again_pressed)
	button_row.add_child(summary_again_button)

	summary_continue_button = Button.new()
	summary_continue_button.text = "Upgrades"
	summary_continue_button.custom_minimum_size = Vector2(180.0, 52.0)
	summary_continue_button.pressed.connect(_on_summary_continue_pressed)
	button_row.add_child(summary_continue_button)

func _begin_run() -> void:
	run_config = REEL_PROGRESS.get_run_config()
	summary_results = {
		"money_earned": 0,
		"fish_caught": 0,
		"fish_lost": 0,
		"bites": 0,
		"clean_pulls": 0,
		"mistakes": 0,
		"deepest_depth": 0.0,
		"catch_log": [],
		"species_counts": {},
		"species_values": {},
	}
	timer_left = float(run_config.get("time_limit", 30.0))
	deepest_depth_reached = 0.0
	hooked_fish_index = -1
	player_stamina_max = 0.0
	player_stamina = 0.0
	fish_stamina_max = 0.0
	fish_stamina = 0.0
	meters_per_fish_stamina = 1.0
	fight_phase_timer = 0.0
	fight_phase_duration = 0.0
	fight_feedback_text = ""
	fight_feedback_timer = 0.0
	total_mistakes = 0
	total_bites = 0
	total_fish_lost = 0
	total_clean_pulls = 0
	summary_ready_for_input = false
	_clear_summary_animation()
	_clear_chart(summary_species_chart)
	_clear_chart(summary_run_chart)
	summary_overlay.visible = false
	summary_overlay.color.a = 0.0
	summary_panel.modulate.a = 0.0

	var viewport_size := get_viewport_rect().size
	boat_target_pos = Vector2(viewport_size.x * 0.8, viewport_size.y * (SURFACE_RATIO * 0.66))
	boat_pos = Vector2(viewport_size.x + boat_size.x, boat_target_pos.y)
	boat_bob_time = 0.0
	hook_x = boat_target_pos.x - boat_size.x * 0.2
	hook_target_x = hook_x
	hook_depth = 0.0
	hook_horizontal_velocity = 0.0
	hook_vertical_velocity = 0.0
	mouse_sway_velocity = 0.0
	hook_blink_timer = 0.0
	run_state = RunState.INTRO
	_spawn_fish_population()
	_update_hud()
	queue_redraw()

func _spawn_fish_population() -> void:
	fish_entities.clear()
	var max_depth: float = float(run_config.get("max_depth", 24.0))
	var fish_count: int = clampi(int(round(max_depth * 0.17)), FISH_COUNT_MIN, FISH_COUNT_MAX)
	for i in range(fish_count):
		var depth: float = rng.randf_range(2.0, max_depth)
		fish_entities.append(_create_fish_entity(depth))

func _create_fish_entity(depth_meters: float) -> Dictionary:
	var species: Dictionary = REEL_DATA.pick_fish_for_depth(depth_meters, rng)
	var pos := Vector2(
		rng.randf_range(_water_rect().position.x + FISH_SPAWN_PADDING, _water_rect().end.x - FISH_SPAWN_PADDING),
		_depth_to_y(depth_meters)
	)
	return {
		"species": species,
		"pos": pos,
		"vel": Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-10.0, 10.0)),
		"roam_target": pos,
		"turn_timer": rng.randf_range(0.6, 1.6),
		"interest": 0.0,
		"bite_cooldown": 0.0,
		"facing": -1.0 if rng.randf() < 0.5 else 1.0,
	}
