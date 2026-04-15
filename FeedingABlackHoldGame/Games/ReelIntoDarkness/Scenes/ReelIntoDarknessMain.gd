extends Node2D
class_name ReelIntoDarknessMain

var REEL_DATA = load("res://Games/ReelIntoDarkness/ReelIntoDarknessData.gd")
var REEL_PROGRESS = load("res://Games/ReelIntoDarkness/ReelIntoDarknessProgress.gd")
const IN_GAME_PAUSE_MENU_SCRIPT := preload("res://Core/InGamePauseMenu.gd")
const CRT_SHADER := preload("res://Games/Mining/UI/MiningCrt.gdshader")
const MULTI_GAME_MODE := preload("res://MultiGameMode.gd")

const CRT_LEVEL_MAX := 11
const CRT_GAME_LAYER := 1
const CRT_UI_LAYER := 2

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
const HOOK_CAST_MIN_DURATION := 0.34
const HOOK_CAST_MAX_DURATION := 0.72
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
const FISH_DEPTH_ROAM_PX := 56.0
const FISH_COUNT_MIN := 14
const FISH_COUNT_MAX := 24
const LINE_SURFACE_REEL_NUDGE_SPEED := 36.0
const GUIDANCE_PULSE_SPEED := 6.0
const GUIDANCE_GLOW_ALPHA := 0.22
const MOON_SKY_X_START_FRAC := 0.78
## When the run timer hits zero the moon sits here: two thirds of a full-width journey from the right edge toward the left (one third from the left edge).
const MOON_SKY_X_END_FRAC := 1.0 / 3.0

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

## Horizontal anchor where the line meets the water (surface Y comes from `_water_rect()`).
var line_surface_anchor_x := 0.0
var line_surface_anchor_active := false

var automation_timer := 0.0
var automation_catch_flash := 0.0

var crt_level := 4
var crt_overlay_layer: CanvasLayer
var crt_overlay_rect: ColorRect
var crt_material: ShaderMaterial
var crt_hud_label: Label

var ambient_anim_time := 0.0

var timer_left := 0.0
var run_time_limit := 0.0
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
var last_fight_prompt_signature := ""
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
var multi_mode_step: Dictionary = {}
var multi_mode_intro_timer := 0.0
var multi_mode_step_reported := false
var multi_mode_intro_overlay: ColorRect
var multi_mode_intro_countdown_label: Label
var multi_mode_intro_note_label: Label

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
	fish_catalog = REEL_DATA.get_fish_catalog()
	multi_mode_step = MULTI_GAME_MODE.get_active_step_for_game(Util.ACTIVE_GAME_REEL_INTO_DARKNESS)
	cursor_screen_pos = get_viewport().get_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_setup_crt_overlay()
	_build_ui()
	_setup_multi_mode_overlay()
	_update_crt_hud_label()
	_setup_pause_menu()
	_begin_run()

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _build_ui() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = CRT_UI_LAYER
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

	crt_hud_label = _make_label("CRT off  O/P", 16, Color(0.62, 0.78, 0.9, 0.95))
	crt_hud_label.custom_minimum_size = Vector2(200.0, 32.0)
	top_row.add_child(crt_hud_label)

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
	summary_panel.anchor_left = 0.08
	summary_panel.anchor_top = 0.0
	summary_panel.anchor_right = 0.92
	summary_panel.anchor_bottom = 1.0
	summary_panel.offset_left = 0.0
	summary_panel.offset_top = 28.0
	summary_panel.offset_right = 0.0
	summary_panel.offset_bottom = -24.0
	summary_panel.modulate.a = 0.0
	_apply_panel_style(summary_panel, Color(0.04, 0.07, 0.11, 0.96), Color(0.28, 0.64, 0.76, 1.0))
	summary_overlay.add_child(summary_panel)

	var summary_margin := MarginContainer.new()
	summary_margin.add_theme_constant_override("margin_left", 22)
	summary_margin.add_theme_constant_override("margin_top", 18)
	summary_margin.add_theme_constant_override("margin_right", 22)
	summary_margin.add_theme_constant_override("margin_bottom", 18)
	summary_panel.add_child(summary_margin)

	var summary_scroll := ScrollContainer.new()
	summary_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	summary_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	summary_margin.add_child(summary_scroll)

	var summary_root := VBoxContainer.new()
	summary_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_root.add_theme_constant_override("separation", 12)
	summary_scroll.add_child(summary_root)

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

func _setup_multi_mode_overlay() -> void:
	if multi_mode_step.is_empty():
		return
	multi_mode_intro_timer = 2.0
	multi_mode_intro_overlay = ColorRect.new()
	multi_mode_intro_overlay.anchor_right = 1.0
	multi_mode_intro_overlay.anchor_bottom = 1.0
	multi_mode_intro_overlay.color = Color(0.0, 0.0, 0.0, 0.28)
	multi_mode_intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(multi_mode_intro_overlay)
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
	multi_mode_intro_note_label.text = MULTI_GAME_MODE.get_active_intro_text()
	vbox.add_child(multi_mode_intro_note_label)
	_update_multi_mode_overlay()

func _is_multi_mode_challenge_active() -> bool:
	return not multi_mode_step.is_empty()

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

func _setup_pause_menu() -> void:
	pause_menu = IN_GAME_PAUSE_MENU_SCRIPT.new()
	pause_menu.name = "InGamePauseMenu"
	pause_menu.resume_requested.connect(_on_pause_resume_requested)
	pause_menu.end_run_requested.connect(_on_pause_end_run_requested)
	add_child(pause_menu)

func _setup_crt_overlay() -> void:
	if crt_overlay_layer != null and is_instance_valid(crt_overlay_layer):
		return
	crt_overlay_layer = CanvasLayer.new()
	crt_overlay_layer.name = "ReelIntoDarknessCrtOverlay"
	crt_overlay_layer.layer = CRT_GAME_LAYER
	crt_overlay_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(crt_overlay_layer)
	crt_overlay_rect = ColorRect.new()
	crt_overlay_rect.name = "ScreenFx"
	crt_overlay_rect.anchor_left = 0.0
	crt_overlay_rect.anchor_top = 0.0
	crt_overlay_rect.anchor_right = 1.0
	crt_overlay_rect.anchor_bottom = 1.0
	crt_overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crt_overlay_rect.color = Color(1.0, 1.0, 1.0, 1.0)
	crt_material = ShaderMaterial.new()
	crt_material.shader = CRT_SHADER
	crt_overlay_rect.material = crt_material
	crt_overlay_layer.add_child(crt_overlay_rect)
	_apply_crt_level()

func _apply_crt_level() -> void:
	if crt_overlay_rect == null or crt_material == null:
		return
	if crt_level <= 0:
		crt_overlay_rect.visible = false
		_update_crt_hud_label()
		return
	crt_overlay_rect.visible = true
	var strength: float = float(crt_level) / float(CRT_LEVEL_MAX)
	var curved_strength: float = pow(strength, 1.12)
	crt_material.set_shader_parameter("fast_mode", false)
	crt_material.set_shader_parameter("target_vertical_resolution", lerpf(900.0, 320.0, curved_strength))
	crt_material.set_shader_parameter("barrel_distortion", lerpf(0.0, 0.055, curved_strength))
	crt_material.set_shader_parameter("scanline_strength", lerpf(0.0, 0.18, strength))
	crt_material.set_shader_parameter("grille_strength", lerpf(0.0, 0.08, strength))
	crt_material.set_shader_parameter("vignette_strength", lerpf(0.0, 0.38, curved_strength))
	crt_material.set_shader_parameter("noise_strength", lerpf(0.0, 0.02, curved_strength))
	crt_material.set_shader_parameter("chroma_offset", lerpf(0.0, 0.7, curved_strength))
	crt_material.set_shader_parameter("tint", Vector3(1.0, 0.98, 0.92))
	_update_crt_hud_label()

func _change_crt_level(delta: int) -> void:
	var new_level: int = clampi(crt_level + delta, 0, CRT_LEVEL_MAX)
	if new_level == crt_level:
		return
	crt_level = new_level
	_apply_crt_level()

func _update_crt_hud_label() -> void:
	if crt_hud_label == null:
		return
	if crt_level <= 0:
		crt_hud_label.text = "CRT off  (O −  P +)"
	else:
		var pct: int = int(round(float(crt_level) / float(CRT_LEVEL_MAX) * 100.0))
		crt_hud_label.text = "CRT %d/%d  %d%%  O/P" % [crt_level, CRT_LEVEL_MAX, pct]

func _handle_crt_hotkey_input(event: InputEvent) -> bool:
	if not (event is InputEventKey):
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return false
	if key_event.keycode == KEY_O:
		_change_crt_level(-1)
		return true
	if key_event.keycode == KEY_P:
		_change_crt_level(1)
		return true
	return false

func _begin_run() -> void:
	run_config = REEL_PROGRESS.get_run_config()
	if _is_multi_mode_challenge_active():
		var forced_upgrades: Dictionary = REEL_PROGRESS.get_upgrade_levels()
		var forced_depth_tier_index: int = max(0, int(multi_mode_step.get("depth_tier_index", 0)))
		for i in range(min(forced_depth_tier_index, REEL_DATA.DEPTH_CAP_UPGRADE_KEYS.size())):
			var upgrade_key: String = str(REEL_DATA.DEPTH_CAP_UPGRADE_KEYS[i])
			forced_upgrades[upgrade_key] = max(int(forced_upgrades.get(upgrade_key, 0)), 1)
		var depth_options: Array = REEL_DATA.get_reel_depth_tier_options(forced_upgrades)
		var depth_tier_index: int = clampi(int(multi_mode_step.get("depth_tier_index", 0)), 0, max(depth_options.size() - 1, 0))
		if depth_tier_index >= 0 and depth_tier_index < depth_options.size():
			Global.reel_run_max_depth_cap = float((depth_options[depth_tier_index] as Dictionary).get("max_depth_cap", run_config.get("max_depth", 24.0)))
	if Global.reel_run_max_depth_cap > 0.0:
		var cap: float = Global.reel_run_max_depth_cap
		run_config["max_depth"] = minf(float(run_config.get("max_depth", 24.0)), cap)
		Global.reel_repeat_depth_cap = float(run_config.get("max_depth", 24.0))
	else:
		Global.reel_repeat_depth_cap = -1.0
	Global.reel_run_max_depth_cap = -1.0
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
	run_time_limit = maxf(0.001, float(run_config.get("time_limit", 30.0)))
	if _is_multi_mode_challenge_active():
		run_time_limit = maxf(0.001, float(multi_mode_step.get("time_limit", run_time_limit)))
		run_config["time_limit"] = run_time_limit
	timer_left = run_time_limit
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
	last_fight_prompt_signature = ""
	summary_ready_for_input = false
	_clear_summary_animation()
	_clear_chart(summary_species_chart)
	_clear_chart(summary_run_chart)
	summary_overlay.visible = false
	summary_overlay.color.a = 0.0
	summary_panel.modulate.a = 0.0

	var viewport_size := get_viewport_rect().size
	boat_target_pos = Vector2(viewport_size.x * 0.8, viewport_size.y * SURFACE_RATIO - 8.0)
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
	line_surface_anchor_active = false
	line_surface_anchor_x = 0.0
	automation_timer = 0.0
	automation_catch_flash = 0.0
	run_state = RunState.INTRO
	multi_mode_step_reported = false
	_spawn_fish_population()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_update_hud()
	queue_redraw()

func _spawn_fish_population() -> void:
	fish_entities.clear()
	var max_depth: float = float(run_config.get("max_depth", 24.0))
	var fish_count: int = clampi(int(round(max_depth * 0.17)), FISH_COUNT_MIN, FISH_COUNT_MAX)
	var denom: float = float(max(fish_count - 1, 1))
	for i in range(fish_count):
		var span: float = max(0.001, max_depth - 2.0)
		var t: float = clampf((float(i) + rng.randf_range(0.12, 0.88)) / denom, 0.0, 1.0)
		var depth: float = 2.0 + t * span
		fish_entities.append(_create_fish_entity(depth))

func _create_fish_entity(depth_meters: float) -> Dictionary:
	var species: Dictionary = REEL_DATA.pick_fish_for_depth(depth_meters, rng)
	var preferred_y := _depth_to_y(depth_meters)
	var pos := Vector2(
		rng.randf_range(_water_rect().position.x + FISH_SPAWN_PADDING, _water_rect().end.x - FISH_SPAWN_PADDING),
		preferred_y
	)
	return {
		"species": species,
		"pos": pos,
		"vel": Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-10.0, 10.0)),
		"roam_target": pos,
		"preferred_depth_m": depth_meters,
		"preferred_y": preferred_y,
		"turn_timer": rng.randf_range(0.6, 1.6),
		"interest": 0.0,
		"bite_cooldown": 0.0,
		"facing": -1.0 if rng.randf() < 0.5 else 1.0,
	}

func _process(delta: float) -> void:
	if _process_multi_mode_intro(delta):
		return
	if _is_pause_menu_open():
		return
	boat_bob_time += delta
	ambient_anim_time += delta
	hook_blink_timer += delta
	if automation_catch_flash > 0.0:
		automation_catch_flash = maxf(0.0, automation_catch_flash - delta)
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
	_update_automation_passive(delta)
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
	var anchor := _line_anchor_for_hook()
	if run_state == RunState.READY:
		_snap_hook_to_anchor()
		return

	var sink_speed: float = float(run_config.get("sink_speed", 15.0)) * _pixels_per_meter()
	var reel_speed: float = float(run_config.get("reel_speed", 17.0)) * _pixels_per_meter()
	if cast_in_progress:
		_update_cast_motion(delta, _boat_anchor())
		return

	if line_surface_anchor_active and (run_state == RunState.HOOKED or run_state == RunState.LANDING):
		var pulling_line: bool = hook_reel_pull_remaining > 0.01 or hook_target_line_length < hook_line_length - 0.45
		if pulling_line:
			line_surface_anchor_x = move_toward(line_surface_anchor_x, _boat_anchor().x, LINE_SURFACE_REEL_NUDGE_SPEED * delta)
		anchor = _line_anchor_for_hook()

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
		var preferred_y: float = float(fish.get("preferred_y", pos.y))
		if float(fish.get("turn_timer", 0.0)) <= 0.0 or pos.distance_to(fish.get("roam_target", pos)) < 18.0:
			fish["turn_timer"] = rng.randf_range(0.7, 1.7)
			fish["roam_target"] = Vector2(
				rng.randf_range(water_rect.position.x + FISH_SPAWN_PADDING, water_rect.end.x - FISH_SPAWN_PADDING),
				clampf(
					preferred_y + rng.randf_range(-FISH_DEPTH_ROAM_PX, FISH_DEPTH_ROAM_PX),
					water_rect.position.y + 18.0,
					water_rect.end.y - 22.0
				)
			)
		var base_target: Vector2 = fish.get("roam_target", pos)
		var target: Vector2 = base_target
		var attraction_radius: float = float(run_config.get("attraction_radius", 34.0))
		var distance_to_hook: float = pos.distance_to(hook_pos)
		if (run_state == RunState.IDLE or run_state == RunState.DESCENDING or run_state == RunState.REELING) and distance_to_hook <= attraction_radius * 3.1:
			var seek_strength: float = clampf(1.0 - (distance_to_hook / max(attraction_radius * 3.1, 1.0)), 0.0, 1.0)
			target = Vector2(
				lerpf(base_target.x, hook_pos.x, seek_strength * 0.65),
				base_target.y
			)
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
	var species: Dictionary = fish.get("species", {})
	var vel: Vector2 = fish.get("vel", Vector2.ZERO)
	var hook_pos := _hook_position()
	var facing: float = float(fish.get("facing", 1.0))
	if desired_hold:
		facing = -1.0 if desired_side < 0 else 1.0
	elif absf(hook_velocity.x) > 0.01:
		facing = signf(hook_velocity.x)
	if is_zero_approx(facing):
		facing = 1.0
	var active_reel_in: bool = run_state == RunState.LANDING or hook_target_line_length < hook_line_length - 0.5 or hook_velocity.y < -18.0
	if active_reel_in:
		fish["facing"] = facing
		fish["pos"] = _hooked_fish_center_from_head(species, hook_pos, facing)
		fish["vel"] = Vector2.ZERO
		fish_entities[hooked_fish_index] = fish
		return
	vel = vel.move_toward(Vector2.ZERO, delta * 130.0)
	vel *= (1.0 - min(delta * 1.05, 0.7))
	fish["facing"] = facing
	fish["pos"] = _hooked_fish_center_from_head(species, hook_pos, facing)
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
	var facing: float = float(fish.get("facing", 1.0))
	if is_zero_approx(facing):
		facing = 1.0
	player_stamina_max = float(run_config.get("player_stamina", 12.0))
	player_stamina = player_stamina_max
	fish_stamina_max = float(species.get("stamina", 5.0))
	fish_stamina = fish_stamina_max
	meters_per_fish_stamina = max(0.35, hook_depth / max(fish_stamina_max, 1.0))
	hook_target_line_length = hook_line_length
	hook_reel_pull_remaining = 0.0
	fish["facing"] = facing
	fish["pos"] = _hooked_fish_center_from_head(species, _hook_position(), facing)
	fish["vel"] = Vector2.ZERO
	fish_entities[index] = fish
	total_bites += 1
	summary_results["bites"] = total_bites
	fight_feedback_text = "Fish on!"
	fight_feedback_timer = 0.8
	last_fight_prompt_signature = ""
	_roll_next_fight_phase()

func _hooked_fish_center_from_head(species: Dictionary, hook_pos: Vector2, facing: float) -> Vector2:
	var size: Vector2 = species.get("size", Vector2(36.0, 18.0))
	var hooked_body_scale := 1.06
	var head_offset := Vector2(facing * size.x * 0.4 * hooked_body_scale, 0.0)
	return hook_pos - head_offset

func _roll_next_fight_phase() -> void:
	desired_hold = rng.randf() < 0.62
	desired_side = -1 if rng.randf() < 0.5 else 1
	fight_phase_duration = rng.randf_range(FIGHT_PHASE_MIN, FIGHT_PHASE_MAX)
	fight_phase_timer = fight_phase_duration
	var prompt_signature := _current_fight_prompt_signature()
	if prompt_signature != last_fight_prompt_signature:
		last_fight_prompt_signature = prompt_signature
		_play_reel_sound(SoundEffectSettings.SOUND_EFFECT_TYPE.REEL_PROMPT_SHIFT, 0.0, rng.randf_range(-0.03, 0.03))

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
	var line_anchor := _line_anchor_for_hook()
	hook_position = line_anchor + _safe_line_direction(line_anchor) * hook_line_length
	_sync_hook_state_from_position()
	total_clean_pulls += 1
	summary_results["clean_pulls"] = total_clean_pulls
	fight_feedback_text = "Clean pull!" if desired_hold else "Tension held."
	fight_feedback_timer = 0.48
	_play_reel_sound(SoundEffectSettings.SOUND_EFFECT_TYPE.REEL_BEAT_SUCCESS, 0.0, rng.randf_range(-0.02, 0.03))
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
	_play_reel_sound(SoundEffectSettings.SOUND_EFFECT_TYPE.REEL_BEAT_FAIL, 0.0, rng.randf_range(-0.03, 0.02))
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
	last_fight_prompt_signature = ""
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
	last_fight_prompt_signature = ""
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
	if _is_multi_mode_challenge_active() and not multi_mode_step_reported:
		var fish_caught: int = int(summary_results.get("fish_caught", 0))
		if fish_caught >= int(multi_mode_step.get("fish_goal", 999999)):
			multi_mode_step_reported = true
			MULTI_GAME_MODE.complete_current_step(true, {
				"fish_caught": fish_caught,
				"max_depth": float(run_config.get("max_depth", 24.0)),
				"elapsed": maxf(0.0, run_time_limit - timer_left),
				"time_remaining": maxf(0.0, timer_left),
				"time_limit": run_time_limit
			})
			return
	fight_feedback_text = "Landed %s!" % landing_species_name
	fight_feedback_timer = 0.85
	_play_reel_sound(SoundEffectSettings.SOUND_EFFECT_TYPE.REEL_FISH_LANDED, 0.0, rng.randf_range(-0.02, 0.02))
	fish_entities[hooked_fish_index] = _create_fish_entity(rng.randf_range(2.0, float(run_config.get("max_depth", 24.0))))
	hooked_fish_index = -1
	player_stamina = 0.0
	fish_stamina = 0.0
	landing_species_name = ""
	landing_species_value = 0
	landing_catch_depth = 0.0
	last_fight_prompt_signature = ""
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
	last_fight_prompt_signature = ""
	fight_feedback_text = "Horn's up. Dragging the line home."
	fight_feedback_timer = 1.0

func _show_summary() -> void:
	if _is_multi_mode_challenge_active() and not multi_mode_step_reported:
		multi_mode_step_reported = true
		MULTI_GAME_MODE.complete_current_step(false, {
			"reason": "summary",
			"fish_caught": int(summary_results.get("fish_caught", 0)),
			"deepest_depth": float(summary_results.get("deepest_depth", 0.0)),
			"elapsed": maxf(0.0, run_time_limit - timer_left),
			"time_remaining": maxf(0.0, timer_left),
			"time_limit": run_time_limit,
		})
		return
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
	var groups: Dictionary = {}
	for entry_variant in catch_log:
		var entry: Dictionary = entry_variant
		var name: String = String(entry.get("name", "Unknown Fish"))
		var d: float = float(entry.get("depth", 0.0))
		var is_auto: bool = d < -0.5
		var key: String = name + ("|a" if is_auto else "|m")
		if not groups.has(key):
			groups[key] = {
				"name": name,
				"auto": is_auto,
				"count": 0,
				"value": 0,
				"depth_sum": 0.0,
				"depth_n": 0,
			}
		var g: Dictionary = groups[key]
		g["count"] = int(g["count"]) + 1
		g["value"] = int(g["value"]) + int(entry.get("value", 0))
		if not is_auto:
			g["depth_sum"] = float(g["depth_sum"]) + d
			g["depth_n"] = int(g["depth_n"]) + 1
	var keys: Array = groups.keys()
	keys.sort()
	var lines := PackedStringArray(["Catch Log"])
	for k in keys:
		var g: Dictionary = groups[k]
		var cnt: int = int(g["count"])
		var nm: String = String(g["name"])
		var val: int = int(g["value"])
		var label: String = nm if cnt <= 1 else "%s  x%d" % [nm, cnt]
		var depth_col: String
		if bool(g["auto"]):
			depth_col = "auto"
		else:
			var dn: int = maxi(int(g["depth_n"]), 1)
			var davg: float = float(g["depth_sum"]) / float(dn)
			depth_col = "%.1fm" % davg
		lines.append("%s  $%d  %s" % [label, val, depth_col])
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
	_update_crt_hud_label()
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
			var deck: String = ""
			if float(run_config.get("automation_tick_interval", 999999.0)) < 900000.0:
				deck = " Deck gear is also pulling passive catches."
			return "Click to cast toward the cursor. Hold after the cast to keep feeding line out.%s" % deck
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
	if _handle_crt_hotkey_input(event):
		get_viewport().set_input_as_handled()
		return
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
				var next_state := _free_line_state_for_cursor(cursor_screen_pos)
				if next_state != run_state:
					if next_state == RunState.REELING:
						_play_reel_sound(SoundEffectSettings.SOUND_EFFECT_TYPE.REEL_LINE_PULL, -2.0, rng.randf_range(-0.03, 0.04))
					elif next_state == RunState.DESCENDING:
						_play_reel_sound(SoundEffectSettings.SOUND_EFFECT_TYPE.REEL_LINE_RELEASE, 0.0, rng.randf_range(-0.04, 0.05))
				run_state = next_state
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
	_draw_sky_moon_stars(viewport_size, surface_y)
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
	_draw_water_decorations(water_rect, viewport_size, surface_y)
	draw_line(Vector2(0.0, surface_y), Vector2(viewport_size.x, surface_y), Color(0.42, 0.67, 0.78, 0.38), 2.0)
	_draw_depth_markers(water_rect)
	_draw_boat()
	_draw_automation_gear()
	_draw_automation_catch_flash(surface_y)
	_draw_fish()
	_draw_line_and_hook()
	_draw_reel_guidance_glyphs()
	_draw_cursor()

func _draw_sky_moon_stars(viewport_size: Vector2, surface_y: float) -> void:
	draw_rect(
		Rect2(Vector2.ZERO, Vector2(viewport_size.x, surface_y)),
		Color(0.03, 0.035, 0.055, 1.0),
		true
	)
	var haze_h: float = clampf(surface_y * 0.14, 16.0, 42.0)
	draw_rect(
		Rect2(Vector2(0.0, surface_y - haze_h), Vector2(viewport_size.x, haze_h)),
		Color(0.08, 0.09, 0.12, 0.18),
		true
	)
	var star_count: int = 24
	var margin_x: float = 28.0
	var star_top: float = 18.0
	var star_band_h: float = maxf(surface_y * 0.62, 36.0)
	for i in range(star_count):
		var sx: float = fposmod(sin(float(i) * 12.9898 + 3.14) * 7821.37, viewport_size.x - margin_x * 2.0) + margin_x
		var sy: float = star_top + fposmod(cos(float(i) * 78.233 + 1.618) * 5912.11, star_band_h)
		var twinkle: float = 0.5 + 0.5 * sin(ambient_anim_time * (1.3 + float(i % 5) * 0.18) + float(i) * 1.73)
		var alpha: float = lerpf(0.25, 0.9, twinkle)
		var radius: float = 0.9 + fposmod(sin(float(i) * 9.1), 1.0) * 1.2
		var star_pos := Vector2(sx, sy)
		draw_circle(star_pos, radius + 1.3, Color(0.78, 0.84, 0.96, alpha * 0.12))
		draw_circle(star_pos, radius, Color(0.88, 0.92, 1.0, alpha))
		if i % 4 == 0:
			draw_circle(star_pos, radius * (1.6 + twinkle * 0.45), Color(0.9, 0.95, 1.0, alpha * 0.08))
	var moon_x_start: float = viewport_size.x * MOON_SKY_X_START_FRAC
	var moon_x_end: float = viewport_size.x * MOON_SKY_X_END_FRAC
	var moon_travel_t: float = 1.0 - clampf(timer_left / run_time_limit, 0.0, 1.0)
	var moon_center := Vector2(lerpf(moon_x_start, moon_x_end, moon_travel_t), surface_y * 0.34)
	draw_circle(moon_center, 24.0, Color(0.72, 0.77, 0.9, 0.12))
	draw_circle(moon_center, 16.0, Color(0.94, 0.96, 1.0, 0.9))
	draw_circle(moon_center + Vector2(6.0, -2.0), 14.0, Color(0.03, 0.035, 0.055, 0.96))

func _draw_water_decorations(water_rect: Rect2, viewport_size: Vector2, surface_y: float) -> void:
	var wleft: float = water_rect.position.x
	var wright: float = water_rect.end.x
	var wbottom: float = water_rect.end.y
	for k in range(11):
		var base_x: float = lerpf(wleft + 40.0, wright - 40.0, float(k) / 10.0)
		base_x += sin(ambient_anim_time * 0.15 + float(k) * 1.7) * 6.0
		var sway: float = sin(ambient_anim_time * 0.9 + float(k)) * 4.0
		var top_y: float = lerpf(surface_y + 40.0, wbottom - 30.0, 0.35 + fposmod(sin(float(k) * 3.1), 0.45))
		var pts := PackedVector2Array()
		var segs: int = 9
		for s in range(segs + 1):
			var t: float = float(s) / float(segs)
			var px: float = base_x + sway * sin(t * PI * 1.1)
			var py: float = lerpf(top_y, wbottom - 8.0, t)
			pts.append(Vector2(px, py))
		if pts.size() >= 2:
			draw_polyline(pts, Color(0.12, 0.28, 0.22, 0.22), 3.0, true)
	for b in range(4):
		var bx: float = lerpf(wleft + 80.0, wright - 80.0, 0.2 + float(b) * 0.22)
		var by: float = lerpf(surface_y + 90.0, water_rect.position.y + water_rect.size.y * 0.55, 0.35 + float(b) * 0.1)
		var pulse: float = 0.35 + 0.35 * sin(ambient_anim_time * 2.1 + float(b) * 2.0)
		draw_circle(Vector2(bx, by), 5.0, Color(0.98, 0.92, 0.55, pulse * 0.45))
		draw_circle(Vector2(bx, by), 2.2, Color(1.0, 1.0, 0.85, pulse * 0.9))
	for p in range(42):
		var px: float = fposmod(sin(float(p) * 91.7 + 2.0) * 9123.0, viewport_size.x - 20.0) + 10.0
		var py: float = lerpf(surface_y + 30.0, wbottom - 20.0, fposmod(cos(float(p) * 55.3) * 7777.0, 1.0))
		var a: float = 0.04 + 0.06 * fposmod(sin(float(p) + ambient_anim_time * 1.3), 1.0)
		draw_circle(Vector2(px, py), 1.4, Color(0.55, 0.82, 0.95, a))

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

func _draw_automation_gear() -> void:
	if float(run_config.get("automation_tick_interval", 999999.0)) > 900000.0:
		return
	var bob_offset: float = sin(boat_bob_time * BOAT_BOB_SPEED) * BOAT_BOB_HEIGHT
	var seine: int = int(run_config.get("automation_seine_tier", 0))
	if seine > 0:
		var origin: Vector2 = boat_pos + Vector2(-boat_size.x * 0.38, 6.0 + bob_offset)
		var sweep: float = sin(boat_bob_time * 2.15) * 14.0
		draw_arc(origin + Vector2(sweep, 0.0), 20.0 + float(seine) * 3.2, 0.38 * PI, 0.72 * PI, 14, Color(0.62, 0.84, 0.96, 0.2), 2.2)
	var pots: int = int(run_config.get("automation_pot_tier", 0))
	if pots > 0:
		var po: Vector2 = boat_pos + Vector2(boat_size.x * 0.32, 12.0 + bob_offset)
		draw_circle(po, 5.0 + float(pots) * 0.35, Color(0.4, 0.36, 0.32, 0.55))
		draw_line(po + Vector2(-6.0, 2.0), po + Vector2(6.0, 2.0), Color(0.55, 0.48, 0.42, 0.5), 2.0)


func _draw_automation_catch_flash(surface_y: float) -> void:
	if automation_catch_flash <= 0.0:
		return
	var bob_offset: float = sin(boat_bob_time * BOAT_BOB_SPEED) * BOAT_BOB_HEIGHT
	var a: float = clampf(automation_catch_flash / 0.52, 0.0, 1.0)
	a = a * a * (3.0 - 2.0 * a)
	var splash_x: float = boat_pos.x - boat_size.x * 0.1 + sin(ambient_anim_time * 11.0) * 9.0
	var splash_y: float = surface_y + 5.0
	var ring_r: float = 12.0 + 24.0 * (1.0 - a)
	draw_arc(Vector2(splash_x, splash_y), ring_r, PI * 0.1, PI * 0.9, 14, Color(0.58, 0.84, 0.98, 0.52 * a), 3.0)
	for i in range(10):
		var ang: float = TAU * float(i) / 10.0 + ambient_anim_time * 2.6
		var lift: float = 30.0 * sqrt(a) * (0.3 + 0.7 * fposmod(sin(float(i) * 4.7 + 0.2), 1.0))
		var px: float = splash_x + cos(ang) * ring_r * 0.38
		var py: float = splash_y - lift
		draw_circle(Vector2(px, py), 2.0 * a + 0.7, Color(0.9, 0.96, 1.0, 0.78 * a))
	var rail: Vector2 = boat_pos + Vector2(-boat_size.x * 0.24, -boat_size.y * 0.32 + bob_offset)
	draw_circle(rail, 7.0 + 6.0 * a, Color(1.0, 0.93, 0.58, 0.55 * a))
	draw_arc(rail, 15.0 + 5.0 * a, -0.4 * PI, 0.4 * PI, 10, Color(0.68, 0.9, 1.0, 0.5 * a), 2.2)

func _update_automation_passive(delta: float) -> void:
	if run_state == RunState.INTRO or run_state == RunState.SUMMARY or run_state == RunState.RUN_END_EXIT:
		return
	var interval: float = float(run_config.get("automation_tick_interval", 999999.0))
	if interval > 900000.0:
		return
	automation_timer += delta
	if automation_timer < interval:
		return
	automation_timer -= interval
	_fire_automation_catch_burst()

func _fire_automation_catch_burst() -> void:
	var max_d: float = float(run_config.get("max_depth", 24.0))
	var exotics: bool = bool(run_config.get("automation_exotics_unlocked", false))
	var bias: float = float(run_config.get("automation_exotic_bias", 0.0))
	var n: int = clampi(int(run_config.get("automation_catch_count", 1)), 1, 10)
	var vmult: float = float(run_config.get("automation_value_mult", 1.0)) * float(run_config.get("reward_multiplier", 1.0))
	for _i in range(n):
		var species: Dictionary = REEL_DATA.pick_automation_catch(max_d, rng, exotics, bias)
		var base_val: int = int(species.get("value", 1))
		var value: int = maxi(1, int(round(float(base_val) * vmult)))
		_record_automation_catch(str(species.get("name", "Catch")), value)

func _record_automation_catch(species_name: String, value: int) -> void:
	summary_results["money_earned"] = int(summary_results.get("money_earned", 0)) + value
	summary_results["fish_caught"] = int(summary_results.get("fish_caught", 0)) + 1
	var catch_log: Array = summary_results.get("catch_log", [])
	catch_log.append({"name": species_name, "value": value, "depth": -1.0})
	summary_results["catch_log"] = catch_log
	var species_counts: Dictionary = summary_results.get("species_counts", {})
	species_counts[species_name] = int(species_counts.get(species_name, 0)) + 1
	summary_results["species_counts"] = species_counts
	var species_values: Dictionary = summary_results.get("species_values", {})
	species_values[species_name] = int(species_values.get(species_name, 0)) + value
	summary_results["species_values"] = species_values
	automation_catch_flash = minf(0.82, automation_catch_flash + 0.28)
	if run_state != RunState.HOOKED and run_state != RunState.LANDING:
		fight_feedback_text = "%s +$%d (auto)" % [species_name, value]
		fight_feedback_timer = 0.62

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
	var anchor := _line_anchor_for_hook()
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

func _line_anchor_for_hook() -> Vector2:
	var water_rect := _water_rect()
	if line_surface_anchor_active:
		return Vector2(line_surface_anchor_x, water_rect.position.y)
	return _boat_anchor()

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
	return true

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
	var max_depth: float = float(run_config.get("max_depth", 24.0))
	var depth_y := _depth_to_y(max_depth)
	var top: Vector2
	if line_surface_anchor_active:
		top = Vector2(line_surface_anchor_x, _water_rect().position.y)
	else:
		var ba := _boat_anchor()
		top = ba
	return top.distance_to(Vector2(top.x, depth_y)) + HOOK_SURFACE_THROW_HEIGHT

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
	line_surface_anchor_active = false
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
	cast_duration = clampf(anchor.distance_to(target) / 760.0, HOOK_CAST_MIN_DURATION, HOOK_CAST_MAX_DURATION)
	cast_in_progress = true
	hook_grabbed = false
	run_state = RunState.DESCENDING
	_play_reel_sound(SoundEffectSettings.SOUND_EFFECT_TYPE.REEL_CAST_THROW, 0.0, rng.randf_range(-0.04, 0.04))
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
		line_surface_anchor_x = hook_position.x
		line_surface_anchor_active = true
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
	var anchor := _line_anchor_for_hook()
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

func _current_fight_prompt_signature() -> String:
	if not desired_hold:
		return "release"
	return "hold_left" if desired_side < 0 else "hold_right"

func _play_reel_sound(type: SoundEffectSettings.SOUND_EFFECT_TYPE, volume_db_offset: float = 0.0, pitch_scale_offset: float = 0.0) -> void:
	if AudioManager == null:
		return
	AudioManager.create_audio(type, volume_db_offset, pitch_scale_offset)

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
	if Global.reel_repeat_depth_cap > 0.0:
		Global.reel_run_max_depth_cap = Global.reel_repeat_depth_cap
	else:
		Global.reel_run_max_depth_cap = -1.0
	SceneChanger.change_to_new_scene(Util.get_main_scene_path(), null, 0.2)
