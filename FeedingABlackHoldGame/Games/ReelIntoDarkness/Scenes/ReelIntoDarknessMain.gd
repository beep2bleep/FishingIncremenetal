extends Node2D
class_name ReelIntoDarknessMain

const REEL_DATA := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessData.gd")
const REEL_PROGRESS := preload("res://Games/ReelIntoDarkness/ReelIntoDarknessProgress.gd")
const IN_GAME_PAUSE_MENU_SCRIPT := preload("res://Core/InGamePauseMenu.gd")

const SURFACE_RATIO := 0.2
const WATER_SIDE_MARGIN := 96.0
const WATER_BOTTOM_MARGIN := 82.0
const BOAT_INTRO_SPEED := 520.0
const BOAT_EXIT_SPEED := 560.0
const BOAT_BOB_SPEED := 2.2
const BOAT_BOB_HEIGHT := 5.0
const HOOK_GRAVITY := 880.0
const HOOK_SWING_DAMPING := 1.8
const HOOK_WATER_DRAG := 1.45
const HOOK_GRAB_RADIUS := 36.0
const HOOK_GRAB_FORCE := 0.11
const HOOK_MAX_SPEED := 760.0
const HOOK_SURFACE_THROW_HEIGHT := 84.0
const HOOK_RETRACT_SNAP := 12.0
const HOOK_LINE_SEGMENTS := 22
const CURSOR_RING_RADIUS := 11.0
const HOOK_CAST_MIN_DURATION := 0.18
const HOOK_CAST_MAX_DURATION := 0.42
const HOOK_CAST_ARC_HEIGHT := 78.0
const BITE_DISTANCE := 34.0
const BITE_INTEREST_GAIN := 1.2
const BITE_INTEREST_LOSS := 0.65
const FIGHT_SIDE_MARGIN := 10.0
const FIGHT_PHASE_MIN := 0.55
const FIGHT_PHASE_MAX := 1.0
const LANDING_LINE_REEL_MULT := 3.6
const SUMMARY_BAR_MIN_DURATION := 0.8
const SUMMARY_BAR_MAX_DURATION := 2.6
const SUMMARY_MONEY_MIN_DURATION := 0.9
const SUMMARY_MONEY_MAX_DURATION := 2.8
const SUMMARY_MONEY_POP_SCALE := 1.12
const FISH_SPAWN_PADDING := 44.0
const FISH_COUNT_MIN := 14
const FISH_COUNT_MAX := 24
const GUIDANCE_PULSE_SPEED := 6.0
const GUIDANCE_GLOW_ALPHA := 0.22

enum RunState {
	INTRO,
	READY,
	IDLE,
	DESCENDING,
	REELING,
	HOOKED,
	LANDING,
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
var hook_depth := 0.0
var hook_horizontal_velocity := 0.0
var hook_vertical_velocity := 0.0
var hook_position := Vector2.ZERO
var hook_velocity := Vector2.ZERO
var hook_line_length := 0.0
var hook_target_line_length := 0.0
var cursor_screen_pos := Vector2.ZERO
var cursor_velocity := Vector2.ZERO
var left_mouse_down := false
var hook_hovered := false
var hook_grabbed := false
var cast_in_progress := false
var cast_start_position := Vector2.ZERO
var cast_target_position := Vector2.ZERO
var cast_control_position := Vector2.ZERO
var cast_progress := 0.0
var cast_duration := 0.0

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
var hook_reel_pull_remaining := 0.0
var desired_hold := true
var desired_side := 0
var fight_feedback_text := ""
var fight_feedback_timer := 0.0
var total_mistakes := 0
var total_bites := 0
var total_fish_lost := 0
var total_clean_pulls := 0
var landing_species_name := ""
var landing_species_value := 0
var landing_catch_depth := 0.0

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
var pause_menu

func _ready() -> void:
	Global.game_state = Util.GAME_STATES.PLAYING
	rng.randomize()
	run_config = REEL_PROGRESS.get_run_config()
	fish_catalog = REEL_DATA.get_fish_catalog()
	cursor_screen_pos = get_viewport().get_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_build_ui()
	_setup_pause_menu()
	_begin_run()

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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

func _setup_pause_menu() -> void:
	pause_menu = IN_GAME_PAUSE_MENU_SCRIPT.new()
	pause_menu.name = "InGamePauseMenu"
	pause_menu.resume_requested.connect(_on_pause_resume_requested)
	pause_menu.end_run_requested.connect(_on_pause_end_run_requested)
	add_child(pause_menu)

func _begin_run() -> void:
	run_config = REEL_PROGRESS.get_run_config()
	_close_pause_menu()
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
	hook_reel_pull_remaining = 0.0
	fight_feedback_text = ""
	fight_feedback_timer = 0.0
	total_mistakes = 0
	total_bites = 0
	total_fish_lost = 0
	total_clean_pulls = 0
	landing_species_name = ""
	landing_species_value = 0
	landing_catch_depth = 0.0
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
	hook_depth = 0.0
	hook_horizontal_velocity = 0.0
	hook_vertical_velocity = 0.0
	hook_position = _boat_anchor()
	hook_velocity = Vector2.ZERO
	hook_line_length = 0.0
	hook_target_line_length = 0.0
	cursor_velocity = Vector2.ZERO
	left_mouse_down = false
	hook_hovered = false
	hook_grabbed = false
	cast_in_progress = false
	cast_progress = 0.0
	hook_blink_timer = 0.0
	run_state = RunState.INTRO
	_spawn_fish_population()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
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

func _process(delta: float) -> void:
	if _is_pause_menu_open():
		return
	boat_bob_time += delta
	hook_blink_timer += delta
	_refresh_cursor_state(delta)
	if fight_feedback_timer > 0.0:
		fight_feedback_timer = max(0.0, fight_feedback_timer - delta)
		if fight_feedback_timer <= 0.0:
			fight_feedback_text = ""
	match run_state:
		RunState.INTRO:
			_process_intro(delta)
		RunState.READY, RunState.IDLE, RunState.DESCENDING, RunState.REELING:
			_process_active_run(delta)
		RunState.HOOKED:
			_process_hooked_run(delta)
		RunState.LANDING:
			_process_landing_run(delta)
		RunState.RUN_END_RETRACT:
			_process_run_end_retract(delta)
		RunState.RUN_END_EXIT:
			_process_run_end_exit(delta)
		RunState.SUMMARY:
			pass
	_update_hud()
	queue_redraw()

func _process_intro(delta: float) -> void:
	boat_pos.x = move_toward(boat_pos.x, boat_target_pos.x, BOAT_INTRO_SPEED * delta)
	if absf(boat_pos.x - boat_target_pos.x) <= 1.0:
		boat_pos.x = boat_target_pos.x
		run_state = RunState.READY
		_snap_hook_to_anchor()

func _process_active_run(delta: float) -> void:
	timer_left = max(0.0, timer_left - delta)
	if timer_left <= 0.0:
		_begin_run_end()
		return
	_update_hook_motion(delta)
	_update_fish(delta)
	if run_state == RunState.REELING and hook_line_length <= HOOK_RETRACT_SNAP:
		_snap_hook_to_anchor()
		run_state = RunState.READY
	deepest_depth_reached = max(deepest_depth_reached, hook_depth)
	summary_results["deepest_depth"] = deepest_depth_reached

func _process_hooked_run(delta: float) -> void:
	timer_left = max(0.0, timer_left - delta)
	if timer_left <= 0.0:
		_begin_run_end()
		return
	_update_hook_motion(delta)
	_update_hooked_fish_motion(delta)
	fight_phase_timer -= delta
	if fight_phase_timer <= 0.0:
		_resolve_fight_phase()
		if run_state == RunState.HOOKED:
			_roll_next_fight_phase()
	deepest_depth_reached = max(deepest_depth_reached, hook_depth)
	summary_results["deepest_depth"] = deepest_depth_reached

func _process_landing_run(delta: float) -> void:
	timer_left = max(0.0, timer_left - delta)
	_update_hook_motion(delta)
	_update_hooked_fish_motion(delta)
	deepest_depth_reached = max(deepest_depth_reached, hook_depth)
	summary_results["deepest_depth"] = deepest_depth_reached
	if hook_line_length <= HOOK_RETRACT_SNAP or hook_depth <= 0.15:
		_finish_landed_fish()

func _process_run_end_retract(delta: float) -> void:
	hook_grabbed = false
	cast_in_progress = false
	hook_target_line_length = 0.0
	hook_reel_pull_remaining = 0.0
	hook_line_length = move_toward(hook_line_length, hook_target_line_length, float(run_config.get("auto_retract_speed", 72.0)) * _pixels_per_meter() * delta)
	var anchor := _boat_anchor()
	var line_dir := _safe_line_direction(anchor)
	hook_position = anchor + line_dir * hook_line_length
	hook_velocity = Vector2.ZERO
	_sync_hook_state_from_position()
	if hooked_fish_index >= 0 and hooked_fish_index < fish_entities.size():
		var fish := fish_entities[hooked_fish_index]
		fish["pos"] = fish["pos"].lerp(hook_position, clampf(delta * 6.0, 0.0, 1.0))
		fish_entities[hooked_fish_index] = fish
	if hook_line_length <= 0.01 and hook_position.distance_to(anchor) <= 2.0:
		_snap_hook_to_anchor()
		run_state = RunState.RUN_END_EXIT
		_show_summary()

func _process_run_end_exit(delta: float) -> void:
	boat_pos.x += BOAT_EXIT_SPEED * delta
	summary_panel.modulate.a = min(1.0, summary_panel.modulate.a + delta * 2.6)
	summary_overlay.color.a = min(0.78, summary_overlay.color.a + delta * 0.9)
	if boat_pos.x > get_viewport_rect().size.x + boat_size.x + 40.0:
		run_state = RunState.SUMMARY
		summary_ready_for_input = true

func _update_hook_motion(delta: float) -> void:
	var anchor := _boat_anchor()
	if run_state == RunState.READY:
		_snap_hook_to_anchor()
		return

	var sink_speed: float = float(run_config.get("sink_speed", 15.0)) * _pixels_per_meter()
	var reel_speed: float = float(run_config.get("reel_speed", 17.0)) * _pixels_per_meter()
	if cast_in_progress:
		_update_cast_motion(delta, anchor)
		return

	if run_state == RunState.DESCENDING:
		hook_target_line_length = min(_max_hook_line_length(), hook_target_line_length + sink_speed * delta)
	elif run_state == RunState.REELING:
		hook_target_line_length = max(0.0, hook_target_line_length - reel_speed * delta)
	elif run_state == RunState.IDLE:
		hook_target_line_length = hook_line_length
	elif run_state == RunState.HOOKED:
		if hook_reel_pull_remaining > 0.0:
			var reel_step: float = min(hook_reel_pull_remaining, reel_speed * 1.25 * delta)
			hook_target_line_length = max(0.0, hook_target_line_length - reel_step)
			hook_reel_pull_remaining -= reel_step
		hook_target_line_length = max(0.0, min(hook_target_line_length, _max_hook_line_length()))
	elif run_state == RunState.LANDING:
		hook_target_line_length = 0.0

	var line_adjust_speed: float = sink_speed
	if run_state == RunState.REELING or run_state == RunState.HOOKED:
		line_adjust_speed = reel_speed
	elif run_state == RunState.LANDING:
		line_adjust_speed = reel_speed * LANDING_LINE_REEL_MULT
	elif run_state == RunState.IDLE:
		line_adjust_speed = sink_speed * 0.8
	hook_line_length = move_toward(hook_line_length, hook_target_line_length, max(line_adjust_speed, 1.0) * delta)

	hook_velocity += Vector2.DOWN * HOOK_GRAVITY * delta
	hook_velocity *= max(0.0, 1.0 - (HOOK_WATER_DRAG + float(run_config.get("hook_control", 1.0)) * 0.08) * delta)
	if run_state == RunState.IDLE:
		hook_velocity = hook_velocity.move_toward(Vector2.ZERO, HOOK_SWING_DAMPING * _pixels_per_meter() * delta)
	elif run_state == RunState.REELING:
		hook_velocity = hook_velocity.move_toward(Vector2.ZERO, HOOK_SWING_DAMPING * 1.35 * _pixels_per_meter() * delta)
	elif run_state == RunState.LANDING:
		hook_velocity = hook_velocity.move_toward(Vector2.ZERO, HOOK_SWING_DAMPING * 1.7 * _pixels_per_meter() * delta)

	if hook_grabbed:
		_apply_hook_grab_impulse(delta)

	hook_velocity = hook_velocity.limit_length(HOOK_MAX_SPEED)
	hook_position += hook_velocity * delta

	var line_vector := hook_position - anchor
	if line_vector.length_squared() <= 0.0001:
		line_vector = Vector2.DOWN * max(hook_line_length, 1.0)
	hook_position = anchor + line_vector.normalized() * hook_line_length

	var line_dir := _safe_line_direction(anchor)
	hook_velocity -= line_dir * hook_velocity.dot(line_dir)
	_clamp_hook_position(anchor)
	_sync_hook_state_from_position()

	if run_state != RunState.HOOKED and hook_line_length <= 0.01:
		_snap_hook_to_anchor()

func _update_fish(delta: float) -> void:
	var hook_pos := _hook_position()
	var water_rect := _water_rect()
	for i in range(fish_entities.size()):
		var fish: Dictionary = fish_entities[i]
		fish["bite_cooldown"] = max(0.0, float(fish.get("bite_cooldown", 0.0)) - delta)
		fish["turn_timer"] = float(fish.get("turn_timer", 0.0)) - delta
		var pos: Vector2 = fish.get("pos", Vector2.ZERO)
		var vel: Vector2 = fish.get("vel", Vector2.ZERO)
		var species: Dictionary = fish.get("species", {})
		if float(fish.get("turn_timer", 0.0)) <= 0.0 or pos.distance_to(fish.get("roam_target", pos)) < 18.0:
			fish["turn_timer"] = rng.randf_range(0.7, 1.7)
			fish["roam_target"] = Vector2(
				rng.randf_range(water_rect.position.x + FISH_SPAWN_PADDING, water_rect.end.x - FISH_SPAWN_PADDING),
				rng.randf_range(water_rect.position.y + 24.0, water_rect.end.y - 28.0)
			)
		var target: Vector2 = fish.get("roam_target", pos)
		var attraction_radius: float = float(run_config.get("attraction_radius", 34.0))
		var distance_to_hook: float = pos.distance_to(hook_pos)
		if (run_state == RunState.IDLE or run_state == RunState.DESCENDING or run_state == RunState.REELING) and distance_to_hook <= attraction_radius * 3.1:
			var seek_strength: float = clampf(1.0 - (distance_to_hook / max(attraction_radius * 3.1, 1.0)), 0.0, 1.0)
			target = target.lerp(hook_pos, seek_strength * 0.65)
			fish["interest"] = min(1.25, float(fish.get("interest", 0.0)) + delta * (BITE_INTEREST_GAIN + seek_strength))
		else:
			fish["interest"] = max(0.0, float(fish.get("interest", 0.0)) - delta * BITE_INTEREST_LOSS)
		var desired_velocity := (target - pos).normalized() * float(species.get("speed", 24.0))
		vel = vel.move_toward(desired_velocity, delta * 42.0)
		vel *= (1.0 - min(delta * 0.85, 0.6))
		pos += vel * delta
		if pos.x < water_rect.position.x + FISH_SPAWN_PADDING:
			pos.x = water_rect.position.x + FISH_SPAWN_PADDING
			vel.x = absf(vel.x) * 0.8
		elif pos.x > water_rect.end.x - FISH_SPAWN_PADDING:
			pos.x = water_rect.end.x - FISH_SPAWN_PADDING
			vel.x = -absf(vel.x) * 0.8
		if pos.y < water_rect.position.y + 18.0:
			pos.y = water_rect.position.y + 18.0
			vel.y = absf(vel.y) * 0.65
		elif pos.y > water_rect.end.y - 22.0:
			pos.y = water_rect.end.y - 22.0
			vel.y = -absf(vel.y) * 0.65
		if absf(vel.x) > 4.0:
			fish["facing"] = signf(vel.x)
		fish["pos"] = pos
		fish["vel"] = vel
		if run_state != RunState.HOOKED and run_state != RunState.RUN_END_RETRACT and distance_to_hook <= BITE_DISTANCE and float(fish.get("bite_cooldown", 0.0)) <= 0.0 and float(fish.get("interest", 0.0)) >= 0.95:
			_start_hooked_fish(i)
			return
		fish_entities[i] = fish

func _update_hooked_fish_motion(delta: float) -> void:
	if hooked_fish_index < 0 or hooked_fish_index >= fish_entities.size():
		return
	var fish: Dictionary = fish_entities[hooked_fish_index]
	var pos: Vector2 = fish.get("pos", _hook_position())
	var vel: Vector2 = fish.get("vel", Vector2.ZERO)
	var hook_pos := _hook_position()
	var side_target: float = 26.0 if desired_side < 0 else -26.0
	if not desired_hold:
		side_target = 18.0 if int(Time.get_ticks_msec() / 220) % 2 == 0 else -18.0
	var desired_pos := hook_pos + Vector2(side_target, sin(Time.get_ticks_msec() * 0.006) * 8.0)
	var active_reel_in: bool = run_state == RunState.LANDING or hook_target_line_length < hook_line_length - 0.5 or hook_velocity.y < -18.0
	if active_reel_in:
		fish["pos"] = hook_pos
		fish["vel"] = Vector2.ZERO
		if absf(hook_velocity.x) > 0.01:
			fish["facing"] = signf(hook_velocity.x)
		fish_entities[hooked_fish_index] = fish
		return
	var escape_strength: float = 54.0 + fish_stamina * 0.3
	var desired_velocity := (desired_pos - pos).normalized() * escape_strength
	vel = vel.move_toward(desired_velocity, delta * 130.0)
	vel *= (1.0 - min(delta * 1.05, 0.7))
	pos += vel * delta
	pos.x = clampf(pos.x, _water_rect().position.x + FISH_SPAWN_PADDING, _water_rect().end.x - FISH_SPAWN_PADDING)
	pos.y = clampf(pos.y, _water_rect().position.y + 10.0, _water_rect().end.y - 18.0)
	if absf(vel.x) > 2.0:
		fish["facing"] = signf(vel.x)
	fish["pos"] = pos
	fish["vel"] = vel
	fish_entities[hooked_fish_index] = fish

func _start_hooked_fish(index: int) -> void:
	if index < 0 or index >= fish_entities.size():
		return
	hook_grabbed = false
	run_state = RunState.HOOKED
	hooked_fish_index = index
	var fish: Dictionary = fish_entities[index]
	var species: Dictionary = fish.get("species", {})
	player_stamina_max = float(run_config.get("player_stamina", 12.0))
	player_stamina = player_stamina_max
	fish_stamina_max = float(species.get("stamina", 5.0))
	fish_stamina = fish_stamina_max
	meters_per_fish_stamina = max(0.35, hook_depth / max(fish_stamina_max, 1.0))
	hook_target_line_length = hook_line_length
	hook_reel_pull_remaining = 0.0
	total_bites += 1
	summary_results["bites"] = total_bites
	fight_feedback_text = "Fish on!"
	fight_feedback_timer = 0.8
	_roll_next_fight_phase()

func _roll_next_fight_phase() -> void:
	desired_hold = rng.randf() < 0.62
	desired_side = -1 if rng.randf() < 0.5 else 1
	fight_phase_duration = rng.randf_range(FIGHT_PHASE_MIN, FIGHT_PHASE_MAX)
	fight_phase_timer = fight_phase_duration

func _resolve_fight_phase() -> void:
	if hooked_fish_index < 0 or hooked_fish_index >= fish_entities.size():
		run_state = RunState.IDLE
		return
	var fish: Dictionary = fish_entities[hooked_fish_index]
	var fish_pos: Vector2 = fish.get("pos", _hook_position())
	var side_ok := true
	if desired_hold:
		if desired_side < 0:
			side_ok = hook_x <= fish_pos.x - FIGHT_SIDE_MARGIN
		else:
			side_ok = hook_x >= fish_pos.x + FIGHT_SIDE_MARGIN
	var is_holding: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var player_loss := 0.0
	var fish_loss := 0.0
	var beat_cost: float = 0.72 + fish_stamina_max * 0.028
	if desired_hold:
		if is_holding and side_ok:
			player_loss = beat_cost * float(run_config.get("reel_cost_multiplier", 1.0))
			fish_loss = player_loss * 7.0 * float(run_config.get("fish_drain_multiplier", 1.0))
		else:
			_apply_fight_mistake(beat_cost)
			return
	else:
		if is_holding:
			_apply_fight_mistake(beat_cost)
			return

	player_stamina = max(0.0, player_stamina - player_loss)
	fish_stamina = max(0.0, fish_stamina - fish_loss)
	hook_reel_pull_remaining += fish_loss * meters_per_fish_stamina * _pixels_per_meter()
	hook_velocity.y = min(hook_velocity.y, -float(run_config.get("reel_speed", 17.0)) * _pixels_per_meter() * 0.8)
	hook_position = _boat_anchor() + _safe_line_direction(_boat_anchor()) * hook_line_length
	_sync_hook_state_from_position()
	total_clean_pulls += 1
	summary_results["clean_pulls"] = total_clean_pulls
	fight_feedback_text = "Clean pull!" if desired_hold else "Tension held."
	fight_feedback_timer = 0.48
	if player_stamina <= 0.0:
		_lose_hooked_fish()
		return
	if fish_stamina <= 0.0 or hook_depth <= 0.2:
		_land_hooked_fish()

func _apply_fight_mistake(beat_cost: float) -> void:
	player_stamina = max(0.0, player_stamina - beat_cost * 4.0 * float(run_config.get("mistake_penalty_multiplier", 1.0)))
	fish_stamina = min(fish_stamina_max, fish_stamina + beat_cost * 0.75)
	total_mistakes += 1
	summary_results["mistakes"] = total_mistakes
	fight_feedback_text = "The fish surges!"
	fight_feedback_timer = 0.64
	if player_stamina <= 0.0:
		_lose_hooked_fish()

func _lose_hooked_fish() -> void:
	if hooked_fish_index < 0 or hooked_fish_index >= fish_entities.size():
		run_state = RunState.IDLE
		return
	var fish: Dictionary = fish_entities[hooked_fish_index]
	fish["interest"] = 0.0
	fish["bite_cooldown"] = 2.8
	fish["vel"] = Vector2(rng.randf_range(-90.0, 90.0), rng.randf_range(-42.0, 42.0))
	fish_entities[hooked_fish_index] = fish
	hooked_fish_index = -1
	player_stamina = 0.0
	fish_stamina = 0.0
	hook_reel_pull_remaining = 0.0
	hook_target_line_length = hook_line_length
	landing_species_name = ""
	landing_species_value = 0
	landing_catch_depth = 0.0
	total_fish_lost += 1
	summary_results["fish_lost"] = total_fish_lost
	fight_feedback_text = "The fish got away."
	fight_feedback_timer = 0.9
	run_state = RunState.IDLE

func _land_hooked_fish() -> void:
	if hooked_fish_index < 0 or hooked_fish_index >= fish_entities.size():
		run_state = RunState.READY
		return
	var fish: Dictionary = fish_entities[hooked_fish_index]
	var species: Dictionary = fish.get("species", {})
	landing_species_name = str(species.get("name", "Unknown Fish"))
	landing_species_value = int(round(float(species.get("value", 0)) * float(run_config.get("reward_multiplier", 1.0))))
	landing_catch_depth = max(0.0, hook_depth)
	player_stamina = 0.0
	fish_stamina = 0.0
	hook_reel_pull_remaining = 0.0
	hook_target_line_length = hook_line_length
	fight_feedback_text = "Hauling in %s!" % landing_species_name
	fight_feedback_timer = 0.85
	run_state = RunState.LANDING

func _finish_landed_fish() -> void:
	if hooked_fish_index < 0 or hooked_fish_index >= fish_entities.size():
		_snap_hook_to_anchor()
		run_state = RunState.READY
		return
	summary_results["money_earned"] = int(summary_results.get("money_earned", 0)) + landing_species_value
	summary_results["fish_caught"] = int(summary_results.get("fish_caught", 0)) + 1
	var catch_log: Array = summary_results.get("catch_log", [])
	catch_log.append({"name": landing_species_name, "value": landing_species_value, "depth": landing_catch_depth})
	summary_results["catch_log"] = catch_log
	var species_counts: Dictionary = summary_results.get("species_counts", {})
	species_counts[landing_species_name] = int(species_counts.get(landing_species_name, 0)) + 1
	summary_results["species_counts"] = species_counts
	var species_values: Dictionary = summary_results.get("species_values", {})
	species_values[landing_species_name] = int(species_values.get(landing_species_name, 0)) + landing_species_value
	summary_results["species_values"] = species_values
	fight_feedback_text = "Landed %s!" % landing_species_name
	fight_feedback_timer = 0.85
	fish_entities[hooked_fish_index] = _create_fish_entity(rng.randf_range(2.0, float(run_config.get("max_depth", 24.0))))
	hooked_fish_index = -1
	player_stamina = 0.0
	fish_stamina = 0.0
	landing_species_name = ""
	landing_species_value = 0
	landing_catch_depth = 0.0
	_snap_hook_to_anchor()
	run_state = RunState.READY

func _begin_run_end() -> void:
	run_state = RunState.RUN_END_RETRACT
	hook_grabbed = false
	hooked_fish_index = -1
	player_stamina = 0.0
	fish_stamina = 0.0
	hook_reel_pull_remaining = 0.0
	landing_species_name = ""
	landing_species_value = 0
	landing_catch_depth = 0.0
	fight_feedback_text = "Horn's up. Dragging the line home."
	fight_feedback_timer = 1.0

func _show_summary() -> void:
	var total_money: int = int(summary_results.get("money_earned", 0))
	var total_fish: int = int(summary_results.get("fish_caught", 0))
	var deepest_depth: float = float(summary_results.get("deepest_depth", 0.0))
	summary_results["summary_text"] = "Caught %d fish for $%d and reached %.1fm." % [total_fish, total_money, deepest_depth]
	REEL_PROGRESS.apply_run_results(summary_results)
	_clear_summary_animation()

	summary_title_label.text = "Night Haul"
	summary_money_target = total_money
	summary_money_value = 0
	summary_money_label.text = "$0"
	summary_money_label.scale = Vector2.ONE
	summary_stats_label.text = "\n".join([
		"Run time: %.1fs" % float(run_config.get("time_limit", 30.0)),
		"Fish caught: %d" % total_fish,
		"Bites: %d" % int(summary_results.get("bites", 0)),
		"Fish lost: %d" % int(summary_results.get("fish_lost", 0)),
		"Mistakes: %d" % int(summary_results.get("mistakes", 0)),
		"Deepest point: %.1fm" % deepest_depth,
	])
	summary_catch_log_label.text = _build_catch_log_text()
	_clear_chart(summary_species_chart)
	_clear_chart(summary_run_chart)
	_build_summary_chart(summary_species_chart, _build_species_chart_rows())
	_build_summary_chart(summary_run_chart, _build_run_chart_rows())
	summary_overlay.visible = true
	summary_overlay.color.a = 0.0
	summary_panel.modulate.a = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_play_summary_money_animation()

func _build_catch_log_text() -> String:
	var catch_log: Array = summary_results.get("catch_log", [])
	if catch_log.is_empty():
		return "No fish made it back over the rail this run."
	var lines := PackedStringArray(["Catch Log"])
	for entry_variant in catch_log:
		var entry: Dictionary = entry_variant
		lines.append("%s  $%d  %.1fm" % [
			String(entry.get("name", "Unknown Fish")),
			int(entry.get("value", 0)),
			float(entry.get("depth", 0.0)),
		])
	return "\n".join(lines)

func _build_species_chart_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var species_values: Dictionary = summary_results.get("species_values", {})
	for name_variant in species_values.keys():
		var name: String = str(name_variant)
		rows.append({
			"label": name,
			"value": float(species_values[name]),
			"color": _color_for_species(name),
		})
	if rows.is_empty():
		rows.append({"label": "No Catch", "value": 1.0, "color": Color(0.54, 0.64, 0.74, 1.0)})
	return rows

func _build_run_chart_rows() -> Array[Dictionary]:
	return [
		{"label": "Fish Caught", "value": float(summary_results.get("fish_caught", 0)), "color": Color(0.43, 0.86, 0.98, 1.0)},
		{"label": "Bites", "value": float(summary_results.get("bites", 0)), "color": Color(0.98, 0.82, 0.45, 1.0)},
		{"label": "Fish Lost", "value": float(summary_results.get("fish_lost", 0)), "color": Color(0.96, 0.42, 0.32, 1.0)},
		{"label": "Deepest m", "value": float(summary_results.get("deepest_depth", 0.0)), "color": Color(0.64, 0.74, 0.98, 1.0)},
	]

func _build_summary_chart(container: VBoxContainer, rows: Array[Dictionary]) -> void:
	var max_value := 0.0
	for row_variant in rows:
		max_value = max(max_value, float((row_variant as Dictionary).get("value", 0.0)))
	for row_variant in rows:
		var row_data: Dictionary = row_variant
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		container.add_child(row)

		var label := _make_label(str(row_data.get("label", "")), 16, Color(0.88, 0.93, 0.99, 1.0))
		label.custom_minimum_size = Vector2(150.0, 28.0)
		row.add_child(label)

		var bar := ProgressBar.new()
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.max_value = max(max_value, 1.0)
		bar.value = 0.0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0.0, 24.0)
		var fill_style := StyleBoxFlat.new()
		fill_style.bg_color = row_data.get("color", Color.WHITE)
		fill_style.corner_radius_top_left = 8
		fill_style.corner_radius_top_right = 8
		fill_style.corner_radius_bottom_right = 8
		fill_style.corner_radius_bottom_left = 8
		bar.add_theme_stylebox_override("fill", fill_style)
		var background_style := StyleBoxFlat.new()
		background_style.bg_color = Color(0.11, 0.16, 0.22, 1.0)
		background_style.corner_radius_top_left = 8
		background_style.corner_radius_top_right = 8
		background_style.corner_radius_bottom_right = 8
		background_style.corner_radius_bottom_left = 8
		bar.add_theme_stylebox_override("background", background_style)
		row.add_child(bar)

		var value_label := _make_label("0", 16, Color(0.9, 0.96, 1.0, 1.0))
		value_label.custom_minimum_size = Vector2(72.0, 28.0)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(value_label)

		var target_value: float = float(row_data.get("value", 0.0))
		var duration: float = _summary_duration_for_value(target_value, max(max_value, 1.0))
		var tween := create_tween()
		summary_chart_tweens.append(tween)
		tween.tween_method(
			func(current_value: float) -> void:
				bar.value = current_value
				value_label.text = _format_chart_value(target_value, current_value),
			0.0,
			target_value,
			duration
		)
		tween.tween_callback(func() -> void:
			var pop_tween := create_tween()
			pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			pop_tween.tween_property(row, "scale", Vector2.ONE * 1.05, 0.12)
			pop_tween.tween_property(row, "scale", Vector2.ONE, 0.1)
		)

func _clear_summary_animation() -> void:
	_clear_summary_money_animation()
	for tween in summary_chart_tweens:
		if tween != null and tween.is_running():
			tween.kill()
	summary_chart_tweens.clear()

func _play_summary_money_animation() -> void:
	_clear_summary_money_animation()
	var duration: float = clampf(float(summary_money_target) / 120.0, SUMMARY_MONEY_MIN_DURATION, SUMMARY_MONEY_MAX_DURATION)
	summary_money_tween = create_tween()
	summary_money_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	summary_money_tween.tween_method(
		func(value: float) -> void:
			summary_money_value = int(round(value))
			summary_money_label.text = "$%s" % Util.get_number_short_text(summary_money_value),
		0.0,
		float(summary_money_target),
		duration
	)
	summary_money_tween.finished.connect(func() -> void:
		summary_money_value = summary_money_target
		summary_money_label.text = "$%s" % Util.get_number_short_text(summary_money_target)
		_play_summary_money_pop()
		if AudioManager != null:
			AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.MINING_SUMMARY_DING)
	)

func _play_summary_money_pop() -> void:
	_clear_summary_money_animation()
	summary_money_label.scale = Vector2.ONE
	summary_money_pop_tween = create_tween()
	summary_money_pop_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	summary_money_pop_tween.tween_property(summary_money_label, "scale", Vector2.ONE * SUMMARY_MONEY_POP_SCALE, 0.14)
	summary_money_pop_tween.tween_property(summary_money_label, "scale", Vector2.ONE, 0.12)

func _clear_summary_money_animation() -> void:
	if summary_money_tween != null and summary_money_tween.is_running():
		summary_money_tween.kill()
	if summary_money_pop_tween != null and summary_money_pop_tween.is_running():
		summary_money_pop_tween.kill()

func _summary_duration_for_value(value: float, max_value: float) -> float:
	if max_value <= 0.0:
		return SUMMARY_BAR_MIN_DURATION
	var normalized: float = clampf(value / max_value, 0.0, 1.0)
	return lerpf(SUMMARY_BAR_MIN_DURATION, SUMMARY_BAR_MAX_DURATION, pow(normalized, 0.58))

func _format_chart_value(target_value: float, current_value: float) -> String:
	if target_value >= 100.0:
		return Util.get_number_short_text(int(round(current_value)))
	return "%.1f" % current_value if target_value != floor(target_value) else str(int(round(current_value)))

func _color_for_species(species_name: String) -> Color:
	for fish_variant in fish_catalog:
		var fish: Dictionary = fish_variant
		if String(fish.get("name", "")) == species_name:
			return fish.get("color", Color.WHITE)
	return Color(0.64, 0.82, 0.96, 1.0)

func _clear_chart(container: VBoxContainer) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _apply_panel_style(panel: PanelContainer, fill: Color, border: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	panel.add_theme_stylebox_override("panel", style)

func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _make_bar_row(title: String, fill_color: Color) -> Dictionary:
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 2)
	var label_row := HBoxContainer.new()
	root.add_child(label_row)
	var title_label := _make_label(title, 16, Color(0.82, 0.9, 0.98, 1.0))
	title_label.custom_minimum_size = Vector2(180.0, 24.0)
	label_row.add_child(title_label)
	var value_label := _make_label("0 / 0", 16, Color(0.95, 0.98, 1.0, 1.0))
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_row.add_child(value_label)
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.value = 0.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0.0, 22.0)
	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color(0.1, 0.14, 0.19, 1.0)
	background_style.corner_radius_top_left = 8
	background_style.corner_radius_top_right = 8
	background_style.corner_radius_bottom_right = 8
	background_style.corner_radius_bottom_left = 8
	bar.add_theme_stylebox_override("background", background_style)
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.corner_radius_top_left = 8
	fill_style.corner_radius_top_right = 8
	fill_style.corner_radius_bottom_right = 8
	fill_style.corner_radius_bottom_left = 8
	bar.add_theme_stylebox_override("fill", fill_style)
	root.add_child(bar)
	return {"root": root, "bar": bar, "value": value_label}

func _wrap_chart(title: String, content: VBoxContainer) -> PanelContainer:
	var panel := PanelContainer.new()
	_apply_panel_style(panel, Color(0.05, 0.09, 0.14, 0.92), Color(0.2, 0.47, 0.61, 1.0))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)
	var title_label := _make_label(title, 18, Color(0.92, 0.97, 1.0, 1.0))
	root.add_child(title_label)
	root.add_child(content)
	return panel

func _update_hud() -> void:
	timer_label.text = "Time %.1fs" % timer_left
	depth_label.text = "Depth %.1fm" % hook_depth
	wallet_label.text = "Haul $%s" % Util.get_number_short_text(int(summary_results.get("money_earned", 0)))
	var fight_hud_visible: bool = run_state == RunState.HOOKED
	player_stamina_bar.visible = fight_hud_visible
	fish_stamina_bar.visible = fight_hud_visible
	player_stamina_value_label.visible = fight_hud_visible
	fish_stamina_value_label.visible = fight_hud_visible
	if fight_hud_visible:
		player_stamina_bar.max_value = max(player_stamina_max, 1.0)
		player_stamina_bar.value = player_stamina
		player_stamina_value_label.text = "%.1f / %.1f" % [player_stamina, player_stamina_max]
		fish_stamina_bar.max_value = max(fish_stamina_max, 1.0)
		fish_stamina_bar.value = fish_stamina
		fish_stamina_value_label.text = "%.1f / %.1f" % [fish_stamina, fish_stamina_max]
	else:
		player_stamina_value_label.text = ""
		fish_stamina_value_label.text = ""
	prompt_label.text = _current_prompt_text()
	status_label.text = fight_feedback_text

func _current_prompt_text() -> String:
	match run_state:
		RunState.INTRO:
			return "The boat is chugging in from the dark..."
		RunState.READY:
			return "Click to cast toward the cursor. Hold after the cast to keep feeding line out."
		RunState.IDLE:
			return "The lure is holding still. Grab it to shove the swing, or hold above/below it to reel or feed line."
		RunState.DESCENDING:
			return "The lure is dropping. Keep holding to feed line out, or release to let it settle."
		RunState.REELING:
			return "Holding pulls line in. Release and the lure will stay put."
		RunState.HOOKED:
			if desired_hold:
				return "Hold the mouse and keep the hook %s of the fish." % ("left" if desired_side < 0 else "right")
			return "Release the mouse. Wait for the fish to stop surging."
		RunState.LANDING:
			return "The catch is on the line. Reeling it back to deck."
		RunState.RUN_END_RETRACT:
			return "Time's up. Dragging the hook back to deck."
		RunState.RUN_END_EXIT, RunState.SUMMARY:
			return "The boat is heading home."
	return ""

func _input(event: InputEvent) -> void:
	if _handle_pause_menu_input(event):
		return
	if summary_overlay.visible:
		return
	if event is InputEventMouseMotion:
		cursor_screen_pos = (event as InputEventMouseMotion).position
		return
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or mouse_event.is_echo():
		return
	cursor_screen_pos = mouse_event.position
	left_mouse_down = mouse_event.pressed
	if mouse_event.pressed:
		if _can_grab_hook() and _is_cursor_near_hook(cursor_screen_pos):
			run_state = RunState.IDLE
			hook_grabbed = true
			return
		match run_state:
			RunState.READY:
				_start_cast_to(cursor_screen_pos)
			RunState.IDLE, RunState.DESCENDING, RunState.REELING:
				hook_grabbed = false
				run_state = _free_line_state_for_cursor(cursor_screen_pos)
	else:
		hook_grabbed = false
		if cast_in_progress:
			return
		if run_state == RunState.DESCENDING or run_state == RunState.REELING:
			run_state = RunState.IDLE if hook_line_length > HOOK_RETRACT_SNAP else RunState.READY
			if run_state == RunState.READY:
				_snap_hook_to_anchor()

func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	var surface_y := viewport_size.y * SURFACE_RATIO
	var water_rect := _water_rect()
	draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, surface_y)), Color(0.03, 0.04, 0.07, 1.0), true)
	for i in range(16):
		var t: float = float(i) / 15.0
		var band_y: float = lerpf(surface_y, water_rect.end.y, t)
		var band_h: float = (water_rect.end.y - surface_y) / 15.0 + 2.0
		var band_color := Color(
			lerpf(0.04, 0.01, t),
			lerpf(0.12, 0.03, t),
			lerpf(0.18, 0.16, t),
			1.0
		)
		draw_rect(Rect2(Vector2(0.0, band_y), Vector2(viewport_size.x, band_h)), band_color, true)
	draw_line(Vector2(0.0, surface_y), Vector2(viewport_size.x, surface_y), Color(0.62, 0.85, 0.96, 0.9), 3.0)
	_draw_depth_markers(water_rect)
	_draw_boat()
	_draw_fish()
	_draw_line_and_hook()
	_draw_reel_guidance_glyphs()
	_draw_cursor()

func _draw_depth_markers(water_rect: Rect2) -> void:
	var max_depth: float = float(run_config.get("max_depth", 24.0))
	var step: float = 10.0 if max_depth <= 50.0 else 20.0
	var current: float = step
	var font: Font = ThemeDB.fallback_font
	while current < max_depth:
		var y: float = _depth_to_y(current)
		draw_line(Vector2(water_rect.position.x, y), Vector2(water_rect.end.x, y), Color(1.0, 1.0, 1.0, 0.04), 1.0)
		if font != null:
			draw_string(font, Vector2(water_rect.position.x + 8.0, y - 6.0), "%.0fm" % current, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.72, 0.8, 0.9, 0.42))
		current += step

func _draw_boat() -> void:
	var bob_offset: float = sin(boat_bob_time * BOAT_BOB_SPEED) * BOAT_BOB_HEIGHT
	var boat_origin := boat_pos + Vector2.ZERO
	var hull_rect := Rect2(boat_origin - Vector2(boat_size.x * 0.5, boat_size.y * 0.25 - bob_offset), Vector2(boat_size.x, boat_size.y * 0.42))
	draw_rect(hull_rect, Color(0.18, 0.14, 0.12, 1.0), true)
	draw_rect(Rect2(hull_rect.position + Vector2(12.0, 8.0), hull_rect.size - Vector2(24.0, 14.0)), Color(0.36, 0.24, 0.17, 1.0), true)
	var cabin_rect := Rect2(boat_origin + Vector2(-24.0, -boat_size.y * 0.85 + bob_offset), Vector2(68.0, 34.0))
	draw_rect(cabin_rect, Color(0.26, 0.32, 0.38, 1.0), true)
	draw_rect(Rect2(cabin_rect.position + Vector2(10.0, 8.0), Vector2(20.0, 12.0)), Color(0.86, 0.92, 0.98, 1.0), true)
	draw_line(boat_origin + Vector2(-8.0, -12.0 + bob_offset), boat_origin + Vector2(-8.0, -92.0 + bob_offset), Color(0.44, 0.34, 0.24, 1.0), 4.0)
	draw_line(boat_origin + Vector2(-8.0, -92.0 + bob_offset), boat_origin + Vector2(48.0, -52.0 + bob_offset), Color(0.44, 0.34, 0.24, 1.0), 3.0)
	draw_colored_polygon(PackedVector2Array([
		boat_origin + Vector2(-8.0, -88.0 + bob_offset),
		boat_origin + Vector2(-8.0, -34.0 + bob_offset),
		boat_origin + Vector2(42.0, -56.0 + bob_offset),
	]), Color(0.82, 0.86, 0.92, 0.95))

func _draw_fish() -> void:
	for i in range(fish_entities.size()):
		var fish: Dictionary = fish_entities[i]
		var species: Dictionary = fish.get("species", {})
		var pos: Vector2 = fish.get("pos", Vector2.ZERO)
		var size: Vector2 = species.get("size", Vector2(36.0, 18.0))
		var facing: float = float(fish.get("facing", 1.0))
		var body_color: Color = species.get("color", Color(0.6, 0.8, 0.95, 1.0))
		var accent_color: Color = species.get("accent", Color(0.9, 0.96, 1.0, 1.0))
		var body_scale: float = 1.06 if i == hooked_fish_index else 1.0
		var body_rect := Rect2(pos - size * 0.5 * body_scale, size * body_scale)
		draw_ellipse(body_rect.position + body_rect.size * 0.5, body_rect.size.x * 0.5, body_rect.size.y * 0.5, body_color)
		var tail_width: float = size.x * 0.24 * body_scale
		var tail_height: float = size.y * 0.46 * body_scale
		var tail_center := pos + Vector2(-facing * (size.x * 0.52 * body_scale), 0.0)
		draw_colored_polygon(PackedVector2Array([
			tail_center + Vector2(-facing * tail_width, 0.0),
			tail_center + Vector2(facing * tail_width * 0.2, -tail_height),
			tail_center + Vector2(facing * tail_width * 0.2, tail_height),
		]), accent_color)
		var fin_center := pos + Vector2(-facing * 2.0, -size.y * 0.42 * body_scale)
		draw_colored_polygon(PackedVector2Array([
			fin_center,
			fin_center + Vector2(-facing * 10.0, -10.0),
			fin_center + Vector2(facing * 6.0, -4.0),
		]), accent_color.darkened(0.08))
		draw_circle(pos + Vector2(facing * size.x * 0.18 * body_scale, -2.0), 2.4, Color(0.03, 0.05, 0.07, 1.0))

func _draw_line_and_hook() -> void:
	if run_state == RunState.RUN_END_EXIT or run_state == RunState.SUMMARY:
		return
	var anchor := _boat_anchor()
	var hook_pos := _hook_position()
	if run_state == RunState.READY or run_state == RunState.INTRO:
		hook_pos = anchor
	var points := PackedVector2Array()
	var swing_amount: float = hook_velocity.length()
	var sag: float = clampf(8.0 + hook_line_length * 0.04 + swing_amount * 0.015, 8.0, 42.0)
	for i in range(HOOK_LINE_SEGMENTS):
		var t: float = float(i) / float(HOOK_LINE_SEGMENTS - 1)
		var base_point := anchor.lerp(hook_pos, t)
		var bend: float = sin(t * PI) * sag
		var lateral: float = sin((t * 4.5) + boat_bob_time * 2.8) * hook_velocity.x * 0.005
		points.append(base_point + Vector2(lateral, bend))
	draw_polyline(points, Color(0.83, 0.91, 1.0, 0.92), 2.0, true)
	if run_state != RunState.INTRO:
		var hook_color: Color = Color(1.0, 0.9, 0.56, 1.0) if int(hook_blink_timer * 5.0) % 2 == 0 else Color(0.84, 0.92, 1.0, 1.0)
		draw_circle(hook_pos, 6.0, hook_color)
		draw_line(hook_pos, hook_pos + Vector2(8.0, 12.0), hook_color, 2.0)
		draw_arc(hook_pos + Vector2(8.0, 12.0), 8.0, -PI * 0.1, PI * 0.95, 14, hook_color, 2.0)
		if hook_hovered and run_state != RunState.HOOKED:
			var hover_color := Color(0.98, 0.84, 0.46, 0.26)
			draw_circle(hook_pos, 18.0, hover_color)
			draw_arc(hook_pos, 24.0, 0.0, TAU, 28, Color(0.98, 0.84, 0.46, 0.92), 2.0)

func _draw_reel_guidance_glyphs() -> void:
	if run_state != RunState.HOOKED:
		return
	if hooked_fish_index < 0 or hooked_fish_index >= fish_entities.size():
		return
	var fish: Dictionary = fish_entities[hooked_fish_index]
	var fish_pos: Vector2 = fish.get("pos", _hook_position())
	var pulse: float = 0.5 + 0.5 * sin(hook_blink_timer * GUIDANCE_PULSE_SPEED)
	var glow_color := Color(0.56, 0.88, 0.98, GUIDANCE_GLOW_ALPHA + pulse * 0.12)
	var accent_color := Color(0.98, 0.84, 0.46, 0.92)
	var font: Font = ThemeDB.fallback_font
	var bubble_center := Vector2(get_viewport_rect().size.x * 0.5, 126.0)

	draw_circle(bubble_center, 66.0 + pulse * 8.0, glow_color)
	draw_arc(bubble_center, 42.0 + pulse * 5.0, 0.0, TAU, 42, accent_color, 3.0)
	draw_circle(bubble_center, 28.0, Color(0.05, 0.11, 0.17, 0.92))
	if font != null:
		var action_text: String = "HOLD" if desired_hold else "RELEASE"
		var action_size: Vector2 = font.get_string_size(action_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24)
		draw_string(font, bubble_center - Vector2(action_size.x * 0.5, -8.0), action_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24, Color(0.97, 0.98, 1.0, 1.0))
		var sub_text: String = "LEFT" if desired_side < 0 else "RIGHT"
		if not desired_hold:
			sub_text = "WAIT"
		var sub_size: Vector2 = font.get_string_size(sub_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18)
		draw_string(font, bubble_center - Vector2(sub_size.x * 0.5, -34.0), sub_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(0.86, 0.93, 1.0, 0.95))

	if desired_hold:
		var marker_offset_x: float = -44.0 if desired_side < 0 else 44.0
		var marker_center := fish_pos + Vector2(marker_offset_x, 0.0)
		draw_circle(marker_center, 28.0 + pulse * 7.0, Color(0.28, 0.8, 0.96, 0.18))
		draw_arc(marker_center, 18.0 + pulse * 6.0, 0.0, TAU, 28, accent_color, 3.0)
		var arrow_sign: float = -1.0 if desired_side < 0 else 1.0
		draw_line(marker_center + Vector2(-arrow_sign * 10.0, 0.0), marker_center + Vector2(arrow_sign * 10.0, 0.0), accent_color, 3.0)
		draw_line(marker_center + Vector2(arrow_sign * 10.0, 0.0), marker_center + Vector2(arrow_sign * 2.0, -8.0), accent_color, 3.0)
		draw_line(marker_center + Vector2(arrow_sign * 10.0, 0.0), marker_center + Vector2(arrow_sign * 2.0, 8.0), accent_color, 3.0)
	else:
		draw_circle(_hook_position(), 18.0 + pulse * 5.0, Color(0.98, 0.84, 0.46, 0.18))
		draw_arc(_hook_position(), 12.0 + pulse * 5.0, 0.0, TAU, 24, accent_color, 3.0)

func _draw_cursor() -> void:
	if summary_overlay.visible or _is_pause_menu_open():
		return
	var ring_color := Color(0.58, 0.88, 0.99, 0.96)
	if hook_hovered:
		ring_color = Color(0.98, 0.84, 0.46, 0.98)
	if hook_grabbed:
		ring_color = Color(1.0, 0.95, 0.72, 1.0)
	draw_circle(cursor_screen_pos, 2.8, Color(0.96, 0.98, 1.0, 0.98))
	draw_arc(cursor_screen_pos, CURSOR_RING_RADIUS, 0.0, TAU, 24, ring_color, 2.0)
	draw_line(cursor_screen_pos + Vector2(-6.0, 0.0), cursor_screen_pos + Vector2(6.0, 0.0), ring_color, 1.5)
	draw_line(cursor_screen_pos + Vector2(0.0, -6.0), cursor_screen_pos + Vector2(0.0, 6.0), ring_color, 1.5)
	if hook_hovered and not hook_grabbed:
		var font: Font = ThemeDB.fallback_font
		if font != null:
			var hint_text := "GRAB"
			draw_string(font, cursor_screen_pos + Vector2(16.0, -12.0), hint_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.98, 0.94, 0.74, 0.96))

func _water_rect() -> Rect2:
	var viewport_size := get_viewport_rect().size
	return Rect2(
		Vector2(WATER_SIDE_MARGIN, viewport_size.y * SURFACE_RATIO),
		Vector2(viewport_size.x - WATER_SIDE_MARGIN * 2.0, viewport_size.y * (1.0 - SURFACE_RATIO) - WATER_BOTTOM_MARGIN)
	)

func _depth_to_y(depth_meters: float) -> float:
	var water_rect := _water_rect()
	var max_depth: float = max(1.0, float(run_config.get("max_depth", 24.0)))
	return lerpf(water_rect.position.y, water_rect.end.y, clampf(depth_meters / max_depth, 0.0, 1.0))

func _y_to_depth(y_pos: float) -> float:
	var water_rect := _water_rect()
	var max_depth: float = max(1.0, float(run_config.get("max_depth", 24.0)))
	var ratio: float = clampf((y_pos - water_rect.position.y) / max(water_rect.size.y, 1.0), 0.0, 1.0)
	return ratio * max_depth

func _boat_anchor() -> Vector2:
	var bob_offset: float = sin(boat_bob_time * BOAT_BOB_SPEED) * BOAT_BOB_HEIGHT
	return boat_pos + Vector2(-boat_size.x * 0.18, boat_size.y * 0.16 + bob_offset)

func _hook_position() -> Vector2:
	return hook_position

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
	return not summary_overlay.visible and run_state != RunState.RUN_END_EXIT and run_state != RunState.SUMMARY

func _is_pause_menu_open() -> bool:
	return pause_menu != null and pause_menu.is_open()

func _open_pause_menu() -> void:
	if pause_menu == null:
		return
	pause_menu.open_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	queue_redraw()

func _close_pause_menu() -> void:
	if pause_menu == null:
		return
	pause_menu.close_menu()
	if not summary_overlay.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	queue_redraw()

func _on_pause_resume_requested() -> void:
	_close_pause_menu()

func _on_pause_end_run_requested() -> void:
	_close_pause_menu()
	_end_run_to_summary()

func _end_run_to_summary() -> void:
	if summary_overlay.visible:
		return
	run_state = RunState.SUMMARY
	hook_grabbed = false
	left_mouse_down = false
	cast_in_progress = false
	hooked_fish_index = -1
	player_stamina = 0.0
	fish_stamina = 0.0
	hook_reel_pull_remaining = 0.0
	landing_species_name = ""
	landing_species_value = 0
	landing_catch_depth = 0.0
	summary_ready_for_input = true
	_show_summary()
	summary_overlay.color.a = 0.78
	summary_panel.modulate.a = 1.0

func _pixels_per_meter() -> float:
	var max_depth: float = max(1.0, float(run_config.get("max_depth", 24.0)))
	return _water_rect().size.y / max_depth

func _max_hook_line_length() -> float:
	var anchor := _boat_anchor()
	return anchor.distance_to(Vector2(anchor.x, _depth_to_y(float(run_config.get("max_depth", 24.0))))) + HOOK_SURFACE_THROW_HEIGHT

func _safe_line_direction(anchor: Vector2) -> Vector2:
	var line_vector := hook_position - anchor
	if line_vector.length_squared() <= 0.0001:
		return Vector2.DOWN
	return line_vector.normalized()

func _sync_hook_state_from_position() -> void:
	hook_x = hook_position.x
	hook_depth = max(0.0, _y_to_depth(hook_position.y))
	hook_horizontal_velocity = hook_velocity.x
	hook_vertical_velocity = hook_velocity.y / max(_pixels_per_meter(), 0.001)

func _snap_hook_to_anchor() -> void:
	var anchor := _boat_anchor()
	hook_position = anchor
	hook_velocity = Vector2.ZERO
	hook_line_length = 0.0
	hook_target_line_length = 0.0
	hook_reel_pull_remaining = 0.0
	cast_in_progress = false
	cast_progress = 0.0
	_sync_hook_state_from_position()

func _start_cast_to(screen_pos: Vector2) -> void:
	var anchor := _boat_anchor()
	var target := _clamp_cast_target(screen_pos)
	cast_start_position = anchor
	cast_target_position = target
	cast_control_position = Vector2(
		(anchor.x + target.x) * 0.5,
		min(anchor.y, target.y) - HOOK_CAST_ARC_HEIGHT - absf(target.x - anchor.x) * 0.08
	)
	cast_progress = 0.0
	cast_duration = clampf(anchor.distance_to(target) / 1180.0, HOOK_CAST_MIN_DURATION, HOOK_CAST_MAX_DURATION)
	cast_in_progress = true
	hook_grabbed = false
	run_state = RunState.DESCENDING
	hook_position = anchor
	hook_velocity = Vector2.ZERO
	hook_line_length = 0.0
	hook_target_line_length = 0.0
	_sync_hook_state_from_position()

func _update_cast_motion(delta: float, anchor: Vector2) -> void:
	var previous_position := hook_position
	cast_progress = min(1.0, cast_progress + delta / max(cast_duration, 0.001))
	var t: float = cast_progress
	var one_minus_t: float = 1.0 - t
	hook_position = one_minus_t * one_minus_t * cast_start_position \
		+ 2.0 * one_minus_t * t * cast_control_position \
		+ t * t * cast_target_position
	hook_velocity = (hook_position - previous_position) / max(delta, 0.001)
	hook_line_length = min(_max_hook_line_length(), hook_position.distance_to(anchor))
	hook_target_line_length = hook_line_length
	_sync_hook_state_from_position()
	if cast_progress >= 1.0:
		cast_in_progress = false
		hook_velocity *= 0.92
		if not left_mouse_down:
			run_state = RunState.IDLE if hook_line_length > HOOK_RETRACT_SNAP else RunState.READY
			if run_state == RunState.READY:
				_snap_hook_to_anchor()

func _clamp_cast_target(screen_pos: Vector2) -> Vector2:
	var water_rect := _water_rect()
	var min_pos := Vector2(water_rect.position.x + 16.0, water_rect.position.y - HOOK_SURFACE_THROW_HEIGHT * 0.35)
	var max_pos := Vector2(water_rect.end.x - 16.0, water_rect.end.y - 12.0)
	return screen_pos.clamp(min_pos, max_pos)

func _refresh_cursor_state(delta: float) -> void:
	var current_pos := get_viewport().get_mouse_position()
	if delta > 0.0:
		cursor_velocity = (current_pos - cursor_screen_pos) / delta
	else:
		cursor_velocity = Vector2.ZERO
	cursor_screen_pos = current_pos
	hook_hovered = _can_grab_hook() and _is_cursor_near_hook(cursor_screen_pos)

func _apply_hook_grab_impulse(delta: float) -> void:
	var anchor := _boat_anchor()
	var radial := _safe_line_direction(anchor)
	var tangent := Vector2(-radial.y, radial.x)
	var tangential_speed := tangent.dot(cursor_velocity) * HOOK_GRAB_FORCE * float(run_config.get("hook_control", 1.0))
	hook_velocity += tangent * tangential_speed * delta
	hook_velocity += (cursor_screen_pos - hook_position) * min(delta * 8.0, 0.24)

func _clamp_hook_position(anchor: Vector2) -> void:
	var water_rect := _water_rect()
	var min_pos := Vector2(water_rect.position.x + 14.0, water_rect.position.y - HOOK_SURFACE_THROW_HEIGHT)
	var max_pos := Vector2(water_rect.end.x - 14.0, water_rect.end.y - 8.0)
	var clamped := hook_position.clamp(min_pos, max_pos)
	if clamped.is_equal_approx(hook_position):
		return
	hook_position = clamped
	hook_line_length = min(hook_position.distance_to(anchor), _max_hook_line_length())
	hook_velocity *= 0.55

func _can_grab_hook() -> bool:
	return run_state == RunState.IDLE or run_state == RunState.DESCENDING or run_state == RunState.REELING

func _is_cursor_near_hook(screen_pos: Vector2) -> bool:
	return hook_line_length > HOOK_RETRACT_SNAP and screen_pos.distance_to(_hook_position()) <= HOOK_GRAB_RADIUS

func _free_line_state_for_cursor(screen_pos: Vector2) -> RunState:
	if hook_line_length <= HOOK_RETRACT_SNAP:
		return RunState.DESCENDING
	return RunState.DESCENDING if screen_pos.y >= _hook_position().y else RunState.REELING

func _on_summary_continue_pressed() -> void:
	if not summary_ready_for_input:
		return
	if AudioManager != null:
		AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _on_summary_again_pressed() -> void:
	if not summary_ready_for_input:
		return
	if AudioManager != null:
		AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
	SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)
