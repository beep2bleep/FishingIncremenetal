extends Node3D

const TURKEY_DATA := preload("res://Games/Turkey/TurkeyData.gd")
const TURKEY_PROGRESS := preload("res://Games/Turkey/TurkeyProgress.gd")

const FRAME_COUNT := 3
const LANE_WIDTH := 1.05
const LANE_LENGTH := 18.288
const GUTTER_WIDTH := 0.34
const LANE_SURFACE_Y := 0.0
const BALL_RADIUS := 0.109
const PIN_MASS_KG := 1.53
const HEAD_PIN_Z := 17.0
const PIN_ROW_SPACING_Z := 0.264
const PIN_ROW_SPACING_X := 0.1524
const BALL_START_Z := -0.35
const POWER_SWEEP_SPEED := 1.45
const THROW_MIN_SPEED := 6.0
const THROW_MAX_SPEED := 8.8
const SHOT_SETTLE_TIMEOUT := 10.0
const SHOT_SETTLE_GRACE := 1.0
const STANDING_UP_DOT := 0.84

const START_POSITIONS := [
	{"label": "Left 2", "x": -0.34},
	{"label": "Left 1", "x": -0.18},
	{"label": "Center", "x": 0.0},
	{"label": "Right 1", "x": 0.18},
	{"label": "Right 2", "x": 0.34},
]

const SPIN_OPTIONS := [
	{"label": "Hard Left", "curve": -1.0},
	{"label": "Left", "curve": -0.55},
	{"label": "Straight", "curve": 0.0},
	{"label": "Right", "curve": 0.55},
	{"label": "Hard Right", "curve": 1.0},
]

enum RunState {
	READY,
	AIMING,
	BALL_IN_PLAY,
	ROUND_OVER,
}

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var lane_root: Node3D = %LaneRoot
@onready var dynamic_root: Node3D = %DynamicRoot
@onready var camera_3d: Camera3D = %Camera3D
@onready var aim_line: MeshInstance3D = %AimLine
@onready var title_label: Label = %TitleLabel
@onready var wallet_label: Label = %WalletLabel
@onready var scorecard_label: Label = %ScorecardLabel
@onready var frame_status_label: Label = %FrameStatusLabel
@onready var result_label: Label = %ResultLabel
@onready var start_location_row: HBoxContainer = %StartLocationRow
@onready var spin_row: HBoxContainer = %SpinRow
@onready var aiming_help_label: Label = %AimingHelpLabel
@onready var power_bar: ProgressBar = %PowerBar
@onready var end_panel: PanelContainer = %EndPanel
@onready var end_title_label: Label = %EndTitleLabel
@onready var end_scorecard_label: Label = %EndScorecardLabel
@onready var end_summary_label: Label = %EndSummaryLabel
@onready var play_again_button: Button = %PlayAgainButton
@onready var upgrade_button: Button = %UpgradeButton
@onready var menu_button: Button = %MenuButton

var rng := RandomNumberGenerator.new()
var run_state: RunState = RunState.READY
var progress_data: Dictionary = {}
var player_stats: Dictionary = {}
var frame_records: Array[Dictionary] = []
var current_frame_index := 0
var selected_start_index := 2
var selected_spin_index := 2
var current_target_x := 0.0
var current_power_norm := 0.0
var power_direction := 1.0
var shot_elapsed := 0.0
var shot_settled_elapsed := 0.0
var standing_before_throw := 10
var active_ball: RigidBody3D
var active_pins: Array[RigidBody3D] = []
var lane_material: StandardMaterial3D
var pin_material: StandardMaterial3D
var ball_material: StandardMaterial3D
var aim_line_material: StandardMaterial3D
var start_buttons: Array[Button] = []
var spin_buttons: Array[Button] = []
var spin_curve_in_play := 0.0

func _ready() -> void:
	rng.randomize()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	title_label.text = "TURKEY"
	end_panel.hide()
	_setup_environment()
	_setup_materials()
	_build_lane()
	_setup_option_buttons()
	_connect_ui()
	_load_progression()
	_begin_series()

func _process(delta: float) -> void:
	if run_state == RunState.AIMING:
		current_power_norm += power_direction * delta * POWER_SWEEP_SPEED
		if current_power_norm >= 1.0:
			current_power_norm = 1.0
			power_direction = -1.0
		elif current_power_norm <= 0.0:
			current_power_norm = 0.0
			power_direction = 1.0
		_update_target_from_mouse(get_viewport().get_mouse_position().x)
		_update_power_bar()
		_update_aim_line()

func _physics_process(delta: float) -> void:
	if run_state != RunState.BALL_IN_PLAY or active_ball == null or not is_instance_valid(active_ball):
		return

	shot_elapsed += delta
	_apply_spin_force()

	if shot_elapsed < SHOT_SETTLE_GRACE:
		return

	if _is_shot_settled():
		shot_settled_elapsed += delta
	else:
		shot_settled_elapsed = 0.0

	if shot_settled_elapsed >= 0.85 or shot_elapsed >= SHOT_SETTLE_TIMEOUT:
		_finish_throw()

func _unhandled_input(event: InputEvent) -> void:
	if end_panel.visible:
		return
	if event is InputEventMouseMotion and run_state == RunState.AIMING:
		_update_target_from_mouse((event as InputEventMouseMotion).position.x)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if run_state == RunState.READY:
			_begin_aiming()
		elif run_state == RunState.AIMING:
			_throw_ball()

func _setup_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.02, 0.025, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.46, 0.47, 0.5, 1.0)
	environment.ambient_light_energy = 0.65
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	world_environment.environment = environment
	camera_3d.look_at(Vector3(0.0, 0.5, 10.0), Vector3.UP)

func _setup_materials() -> void:
	lane_material = StandardMaterial3D.new()
	lane_material.albedo_color = Color(0.53, 0.35, 0.18, 1.0)
	lane_material.roughness = 0.18
	lane_material.metallic = 0.05

	pin_material = StandardMaterial3D.new()
	pin_material.albedo_color = Color(0.96, 0.96, 0.97, 1.0)
	pin_material.roughness = 0.38

	ball_material = StandardMaterial3D.new()
	ball_material.albedo_color = Color(0.13, 0.06, 0.08, 1.0)
	ball_material.roughness = 0.2

	aim_line_material = StandardMaterial3D.new()
	aim_line_material.albedo_color = Color(0.92, 0.86, 0.44, 0.92)
	aim_line_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	aim_line.material_override = aim_line_material
	var box := BoxMesh.new()
	box.size = Vector3(0.03, 0.01, 1.0)
	aim_line.mesh = box

func _build_lane() -> void:
	for child in lane_root.get_children():
		child.queue_free()

	_add_box_surface("Approach", Vector3(0.0, -0.03, -1.7), Vector3(1.9, 0.06, 4.2), Color(0.18, 0.17, 0.15, 1.0), 0.75, 0.05)
	_add_box_surface("Lane", Vector3(0.0, -0.02, LANE_LENGTH * 0.5), Vector3(LANE_WIDTH, 0.04, LANE_LENGTH + 1.1), lane_material.albedo_color, 0.85, 0.02)
	_add_box_surface("LeftGutter", Vector3(-(LANE_WIDTH * 0.5 + GUTTER_WIDTH * 0.5), -0.08, LANE_LENGTH * 0.5), Vector3(GUTTER_WIDTH, 0.08, LANE_LENGTH + 1.1), Color(0.07, 0.07, 0.075, 1.0), 0.45, 0.06)
	_add_box_surface("RightGutter", Vector3(LANE_WIDTH * 0.5 + GUTTER_WIDTH * 0.5, -0.08, LANE_LENGTH * 0.5), Vector3(GUTTER_WIDTH, 0.08, LANE_LENGTH + 1.1), Color(0.07, 0.07, 0.075, 1.0), 0.45, 0.06)
	_add_box_surface("LeftRail", Vector3(-(LANE_WIDTH * 0.5 + GUTTER_WIDTH), 0.18, LANE_LENGTH * 0.5), Vector3(0.05, 0.36, LANE_LENGTH + 1.1), Color(0.11, 0.11, 0.12, 1.0), 0.7, 0.04)
	_add_box_surface("RightRail", Vector3(LANE_WIDTH * 0.5 + GUTTER_WIDTH, 0.18, LANE_LENGTH * 0.5), Vector3(0.05, 0.36, LANE_LENGTH + 1.1), Color(0.11, 0.11, 0.12, 1.0), 0.7, 0.04)
	_add_box_surface("Backstop", Vector3(0.0, 0.52, LANE_LENGTH + 0.65), Vector3(2.0, 1.1, 0.08), Color(0.16, 0.06, 0.05, 1.0), 0.8, 0.1)

func _add_box_surface(name: String, position: Vector3, size: Vector3, color: Color, friction: float, bounce: float) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.position = position
	lane_root.add_child(body)

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	body.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.32
	material.metallic = 0.05
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var physics_material := PhysicsMaterial.new()
	physics_material.friction = friction
	physics_material.bounce = bounce
	body.physics_material_override = physics_material

func _setup_option_buttons() -> void:
	for entry in START_POSITIONS:
		var button := Button.new()
		button.text = str(entry.get("label", "Start"))
		button.toggle_mode = true
		button.pressed.connect(_on_start_position_pressed.bind(start_buttons.size()))
		start_location_row.add_child(button)
		start_buttons.append(button)

	for entry in SPIN_OPTIONS:
		var button := Button.new()
		button.text = str(entry.get("label", "Spin"))
		button.toggle_mode = true
		button.pressed.connect(_on_spin_pressed.bind(spin_buttons.size()))
		spin_row.add_child(button)
		spin_buttons.append(button)

	_refresh_option_buttons()

func _connect_ui() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)

func _load_progression() -> void:
	progress_data = TURKEY_PROGRESS.load_data()
	player_stats = TURKEY_DATA.build_meta_stats(progress_data)
	_update_wallet_label()

func _begin_series() -> void:
	_clear_dynamic_objects()
	frame_records.clear()
	for _i in range(FRAME_COUNT):
		frame_records.append({"throws": []})
	current_frame_index = 0
	run_state = RunState.READY
	current_power_norm = 0.0
	power_direction = 1.0
	end_panel.hide()
	spin_curve_in_play = 0.0
	_spawn_full_rack()
	_prepare_for_next_shot("Frame 1. Click once to start the power swing.")
	_update_scoreboard()

func _prepare_for_next_shot(message: String) -> void:
	run_state = RunState.READY
	current_power_norm = 0.0
	power_direction = 1.0
	current_target_x = _get_selected_start_x()
	shot_elapsed = 0.0
	shot_settled_elapsed = 0.0
	spin_curve_in_play = 0.0
	aim_line.visible = false
	_update_power_bar()
	_update_status_labels()
	result_label.text = message
	aiming_help_label.text = "Default line is center. Starter gear is weak on purpose, so a strike should feel rare."

func _begin_aiming() -> void:
	if current_frame_index >= FRAME_COUNT:
		return
	run_state = RunState.AIMING
	current_target_x = _get_selected_start_x()
	current_power_norm = 0.08
	power_direction = 1.0
	aim_line.visible = true
	_update_power_bar()
	_update_aim_line()
	_update_status_labels()
	result_label.text = "Move the mouse to pick the line. Click again when the power bar feels right."
	aiming_help_label.text = "Power is now moving. Hard spin gives more curve but also adds a little extra miss."

func _throw_ball() -> void:
	run_state = RunState.BALL_IN_PLAY
	aim_line.visible = false
	shot_elapsed = 0.0
	shot_settled_elapsed = 0.0
	standing_before_throw = active_pins.size()
	spin_curve_in_play = float(SPIN_OPTIONS[selected_spin_index].get("curve", 0.0)) * float(player_stats.get("spin_multiplier", 1.0))

	active_ball = _create_ball()
	var start_x: float = _get_selected_start_x()
	var target_x: float = _get_launch_target_x()
	var power_speed: float = lerpf(THROW_MIN_SPEED, THROW_MAX_SPEED + float(player_stats.get("power_bonus", 0.0)), current_power_norm)
	var lateral_speed: float = clamp((target_x - start_x) * 2.15, -2.1, 2.1)
	active_ball.linear_velocity = Vector3(lateral_speed, 0.0, power_speed)
	active_ball.angular_velocity = Vector3(power_speed / max(BALL_RADIUS, 0.01), spin_curve_in_play * 5.5, 0.0)
	result_label.text = "Ball away. Watching the lane..."
	aiming_help_label.text = "The ball is live. Once everything settles, the pins will be scored automatically."

func _create_ball() -> RigidBody3D:
	if active_ball != null and is_instance_valid(active_ball):
		active_ball.queue_free()

	var body := RigidBody3D.new()
	body.name = "BowlingBall"
	body.continuous_cd = true
	body.mass = float(player_stats.get("ball_mass_kg", 3.63))
	body.position = Vector3(_get_selected_start_x(), BALL_RADIUS + 0.015, BALL_START_Z)
	body.linear_damp = 0.1
	body.angular_damp = 0.08

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = BALL_RADIUS
	collision.shape = sphere
	body.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = BALL_RADIUS
	sphere_mesh.height = BALL_RADIUS * 2.0
	mesh_instance.mesh = sphere_mesh
	mesh_instance.material_override = ball_material
	body.add_child(mesh_instance)

	var physics_material := PhysicsMaterial.new()
	physics_material.friction = 0.58
	physics_material.bounce = 0.03
	body.physics_material_override = physics_material

	dynamic_root.add_child(body)
	return body

func _spawn_full_rack() -> void:
	_clear_pins()
	var rows := [
		[0.0],
		[-PIN_ROW_SPACING_X, PIN_ROW_SPACING_X],
		[-PIN_ROW_SPACING_X * 2.0, 0.0, PIN_ROW_SPACING_X * 2.0],
		[-PIN_ROW_SPACING_X * 3.0, -PIN_ROW_SPACING_X, PIN_ROW_SPACING_X, PIN_ROW_SPACING_X * 3.0],
	]
	for row_index in range(rows.size()):
		var row_positions: Array = rows[row_index]
		for x_variant in row_positions:
			var pin := _create_pin(Vector3(float(x_variant), 0.19, HEAD_PIN_Z + float(row_index) * PIN_ROW_SPACING_Z))
			active_pins.append(pin)

func _create_pin(position: Vector3) -> RigidBody3D:
	var body := RigidBody3D.new()
	body.name = "Pin"
	body.mass = PIN_MASS_KG
	body.position = position
	body.linear_damp = 0.22
	body.angular_damp = 0.28

	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.06
	capsule.height = 0.24
	collision.shape = capsule
	body.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.06
	capsule_mesh.height = 0.24
	mesh_instance.mesh = capsule_mesh
	mesh_instance.material_override = pin_material
	body.add_child(mesh_instance)

	var physics_material := PhysicsMaterial.new()
	physics_material.friction = 0.52
	physics_material.bounce = 0.18
	body.physics_material_override = physics_material

	dynamic_root.add_child(body)
	return body

func _clear_dynamic_objects() -> void:
	_clear_pins()
	if active_ball != null and is_instance_valid(active_ball):
		active_ball.queue_free()
	active_ball = null

func _clear_pins() -> void:
	for pin in active_pins:
		if is_instance_valid(pin):
			pin.queue_free()
	active_pins.clear()

func _apply_spin_force() -> void:
	if active_ball == null or not is_instance_valid(active_ball):
		return
	if absf(spin_curve_in_play) < 0.01:
		return
	if active_ball.position.z < 1.0:
		return
	var forward_speed: float = max(0.0, active_ball.linear_velocity.z)
	if forward_speed <= 0.05:
		return
	var hook_force: float = spin_curve_in_play * forward_speed * 0.82 * float(player_stats.get("hook_force_scale", 1.0)) * active_ball.mass
	active_ball.apply_central_force(Vector3(hook_force, 0.0, 0.0))

func _is_shot_settled() -> bool:
	if active_ball != null and is_instance_valid(active_ball):
		if active_ball.linear_velocity.length() > 0.18 or active_ball.angular_velocity.length() > 0.32:
			return false
	for pin in active_pins:
		if not is_instance_valid(pin):
			continue
		if pin.linear_velocity.length() > 0.14 or pin.angular_velocity.length() > 0.28:
			return false
	return true

func _finish_throw() -> void:
	var standing_after: int = _count_standing_pins()
	var knocked: int = max(0, standing_before_throw - standing_after)
	var frame_data: Dictionary = frame_records[current_frame_index]
	var throws: Array = frame_data.get("throws", [])
	throws.append(knocked)
	frame_data["throws"] = throws
	frame_records[current_frame_index] = frame_data
	_remove_ball()

	var message: String = _describe_throw_result(current_frame_index, throws, knocked, standing_after)
	if _is_frame_complete(current_frame_index):
		if current_frame_index == FRAME_COUNT - 1:
			_complete_series(message)
		else:
			current_frame_index += 1
			_spawn_full_rack()
			_prepare_for_next_shot("%s Next up: frame %d." % [message, current_frame_index + 1])
	else:
		if _should_reset_full_rack_before_next_throw(current_frame_index, throws):
			_spawn_full_rack()
		else:
			_remove_knocked_pins()
		_prepare_for_next_shot(message)

	_update_scoreboard()

func _remove_ball() -> void:
	if active_ball != null and is_instance_valid(active_ball):
		active_ball.queue_free()
	active_ball = null

func _remove_knocked_pins() -> void:
	var still_standing: Array[RigidBody3D] = []
	for pin in active_pins:
		if not is_instance_valid(pin):
			continue
		if _is_pin_standing(pin):
			still_standing.append(pin)
		else:
			pin.queue_free()
	active_pins = still_standing

func _count_standing_pins() -> int:
	var count := 0
	for pin in active_pins:
		if _is_pin_standing(pin):
			count += 1
	return count

func _is_pin_standing(pin: RigidBody3D) -> bool:
	if pin == null or not is_instance_valid(pin):
		return false
	return pin.position.y > 0.06 and pin.global_transform.basis.y.dot(Vector3.UP) >= STANDING_UP_DOT

func _should_reset_full_rack_before_next_throw(frame_index: int, throws: Array) -> bool:
	if frame_index != FRAME_COUNT - 1:
		return false
	if throws.is_empty():
		return false
	if throws.size() == 1:
		return int(throws[0]) == 10
	if int(throws[0]) == 10:
		return int(throws[1]) == 10
	return int(throws[0]) + int(throws[1]) >= 10

func _is_frame_complete(frame_index: int) -> bool:
	var throws: Array = frame_records[frame_index].get("throws", [])
	if frame_index < FRAME_COUNT - 1:
		return (throws.size() >= 1 and int(throws[0]) == 10) or throws.size() >= 2
	if throws.size() < 2:
		return false
	if int(throws[0]) == 10:
		return throws.size() >= 3
	if int(throws[0]) + int(throws[1]) == 10:
		return throws.size() >= 3
	return true

func _complete_series(latest_message: String) -> void:
	run_state = RunState.ROUND_OVER
	aim_line.visible = false
	_update_scoreboard()

	var score_details: Dictionary = _calculate_score_details()
	var cumulative_scores: Array = score_details.get("cumulative", [])
	var final_score: int = int(cumulative_scores[FRAME_COUNT - 1]) if cumulative_scores.size() >= FRAME_COUNT and cumulative_scores[FRAME_COUNT - 1] != null else 0
	var strikes := 0
	var spares := 0
	var open_frames := 0
	var first_three_strikes := true

	for frame_index in range(FRAME_COUNT):
		var throws: Array = frame_records[frame_index].get("throws", [])
		if throws.is_empty():
			first_three_strikes = false
			continue
		if frame_index < FRAME_COUNT - 1:
			if int(throws[0]) == 10:
				strikes += 1
			elif throws.size() >= 2 and int(throws[0]) + int(throws[1]) == 10:
				spares += 1
				first_three_strikes = false
			elif throws.size() >= 2:
				open_frames += 1
				first_three_strikes = false
			else:
				first_three_strikes = false
		else:
			if int(throws[0]) == 10:
				strikes += 1
			elif throws.size() >= 2 and int(throws[0]) + int(throws[1]) == 10:
				spares += 1
				first_three_strikes = false
			else:
				open_frames += 1
				first_three_strikes = false
		if int(throws[0]) != 10:
			first_three_strikes = false

	var results := {
		"score": final_score,
		"strikes": strikes,
		"spares": spares,
		"open_frames": open_frames,
		"turkey_bonus": first_three_strikes,
		"scorecard_text": _build_scorecard_text(true),
	}
	results["wallet_gain"] = TURKEY_DATA.calculate_meta_reward(results, progress_data)
	results["summary_text"] = _build_series_summary(final_score, int(results["wallet_gain"]), strikes, spares, open_frames, first_three_strikes, latest_message)

	progress_data = TURKEY_PROGRESS.apply_run_results(results)
	player_stats = TURKEY_DATA.build_meta_stats(progress_data)
	_update_wallet_label()
	frame_status_label.text = "Series complete."
	result_label.text = latest_message

	end_title_label.text = "SERIES COMPLETE"
	end_scorecard_label.text = String(results.get("scorecard_text", ""))
	end_summary_label.text = String(results.get("summary_text", ""))
	end_panel.show()

func _build_series_summary(final_score: int, reward: int, strikes: int, spares: int, open_frames: int, turkey_bonus: bool, latest_message: String) -> String:
	var lines: Array[String] = []
	lines.append("Final score: %d" % final_score)
	lines.append("Reward: $%d" % reward)
	lines.append("Frames: %d strike, %d spare, %d open." % [strikes, spares, open_frames])
	lines.append(latest_message)
	if turkey_bonus:
		lines.append("Three straight opening strikes. Real turkey money.")
	elif final_score >= 45:
		lines.append("That was a sharp little set. The upgrade lane should feel better next time.")
	else:
		lines.append("Starter gear did its job. Grab upgrades and the pocket will open up later.")
	return "\n".join(lines)

func _describe_throw_result(frame_index: int, throws: Array, knocked: int, standing_after: int) -> String:
	if frame_index < FRAME_COUNT - 1:
		if throws.size() == 1:
			if knocked == 10:
				return "Strike on frame %d." % (frame_index + 1)
			return "Frame %d ball 1: %d pins down, %d still standing." % [frame_index + 1, knocked, standing_after]
		if int(throws[0]) + int(throws[1]) == 10:
			return "Spare in frame %d." % (frame_index + 1)
		return "Open frame %d: %d and %d for %d." % [frame_index + 1, int(throws[0]), int(throws[1]), int(throws[0]) + int(throws[1])]

	if throws.size() == 1:
		if knocked == 10:
			return "Strike in the final frame. Two bonus balls coming."
		return "Final frame ball 1: %d pins down, %d left." % [knocked, standing_after]
	if throws.size() == 2:
		if int(throws[0]) == 10:
			if int(throws[1]) == 10:
				return "Double in the final frame. One bonus ball left."
			return "Final frame bonus ball 1: %d pins down, %d left." % [knocked, standing_after]
		if int(throws[0]) + int(throws[1]) == 10:
			return "Final-frame spare. One fill ball left."
		return "Final frame closes open with %d total." % (int(throws[0]) + int(throws[1]))
	if int(throws[0]) == 10 and int(throws[1]) == 10 and int(throws[2]) == 10:
		return "Triple strike finish."
	return "Final bonus ball drops %d." % knocked

func _calculate_score_details() -> Dictionary:
	var flat_rolls: Array = []
	var roll_start_indices: Array = []
	for frame_data in frame_records:
		var throws: Array = frame_data.get("throws", [])
		roll_start_indices.append(flat_rolls.size())
		for pins_variant in throws:
			flat_rolls.append(int(pins_variant))

	var frame_scores: Array = []
	var cumulative_scores: Array = []
	var running_total := 0
	for frame_index in range(FRAME_COUNT):
		var throws: Array = frame_records[frame_index].get("throws", [])
		var frame_score: Variant = null
		var roll_start: int = int(roll_start_indices[frame_index])

		if frame_index == FRAME_COUNT - 1:
			if _is_frame_complete(frame_index):
				frame_score = 0
				for pins_variant in throws:
					frame_score += int(pins_variant)
		elif throws.size() >= 1 and int(throws[0]) == 10:
			if flat_rolls.size() >= roll_start + 3:
				frame_score = 10 + int(flat_rolls[roll_start + 1]) + int(flat_rolls[roll_start + 2])
		elif throws.size() >= 2 and int(throws[0]) + int(throws[1]) == 10:
			if flat_rolls.size() >= roll_start + 3:
				frame_score = 10 + int(flat_rolls[roll_start + 2])
		elif throws.size() >= 2:
			frame_score = int(throws[0]) + int(throws[1])

		frame_scores.append(frame_score)
		if frame_score == null:
			cumulative_scores.append(null)
		else:
			running_total += int(frame_score)
			cumulative_scores.append(running_total)
	return {
		"frame_scores": frame_scores,
		"cumulative": cumulative_scores,
	}

func _build_scorecard_text(include_final_summary: bool = false) -> String:
	var score_details: Dictionary = _calculate_score_details()
	var cumulative_scores: Array = score_details.get("cumulative", [])
	var lines: Array[String] = []
	for frame_index in range(FRAME_COUNT):
		var throws: Array = frame_records[frame_index].get("throws", [])
		var marks: Array[String] = _frame_marks(frame_index, throws)
		var total_text := "--"
		if frame_index < cumulative_scores.size() and cumulative_scores[frame_index] != null:
			total_text = str(cumulative_scores[frame_index])
		lines.append("F%d: %s | %s" % [frame_index + 1, " ".join(marks), total_text])
	if include_final_summary and cumulative_scores.size() >= FRAME_COUNT and cumulative_scores[FRAME_COUNT - 1] != null:
		lines.append("Total: %d" % int(cumulative_scores[FRAME_COUNT - 1]))
	return "\n".join(lines)

func _frame_marks(frame_index: int, throws: Array) -> Array[String]:
	var marks: Array[String] = []
	if throws.is_empty():
		return ["--"]

	if frame_index < FRAME_COUNT - 1:
		if int(throws[0]) == 10:
			return ["X"]
		marks.append(_roll_symbol(int(throws[0])))
		if throws.size() >= 2:
			if int(throws[0]) + int(throws[1]) == 10:
				marks.append("/")
			else:
				marks.append(_roll_symbol(int(throws[1])))
		else:
			marks.append("-")
		return marks

	marks.append("X" if int(throws[0]) == 10 else _roll_symbol(int(throws[0])))
	if throws.size() >= 2:
		if int(throws[0]) == 10:
			marks.append("X" if int(throws[1]) == 10 else _roll_symbol(int(throws[1])))
		elif int(throws[0]) + int(throws[1]) == 10:
			marks.append("/")
		else:
			marks.append(_roll_symbol(int(throws[1])))
	if throws.size() >= 3:
		if int(throws[0]) == 10:
			if int(throws[1]) < 10 and int(throws[1]) + int(throws[2]) == 10:
				marks.append("/")
			else:
				marks.append("X" if int(throws[2]) == 10 else _roll_symbol(int(throws[2])))
		elif int(throws[0]) + int(throws[1]) == 10:
			marks.append("X" if int(throws[2]) == 10 else _roll_symbol(int(throws[2])))
		else:
			marks.append(_roll_symbol(int(throws[2])))
	return marks

func _roll_symbol(pins: int) -> String:
	if pins <= 0:
		return "-"
	if pins >= 10:
		return "X"
	return str(pins)

func _update_scoreboard() -> void:
	scorecard_label.text = _build_scorecard_text()
	_update_status_labels()

func _update_status_labels() -> void:
	if current_frame_index >= FRAME_COUNT:
		frame_status_label.text = "Series complete."
		return
	var throws: Array = frame_records[current_frame_index].get("throws", [])
	var ball_number: int = throws.size() + 1
	frame_status_label.text = "Frame %d, Ball %d" % [current_frame_index + 1, ball_number]

func _update_wallet_label() -> void:
	var wallet: int = int(progress_data.get("wallet", 0))
	var weight_lb: float = float(player_stats.get("ball_weight_lb", 8.0))
	wallet_label.text = "Wallet: $%d   Ball: %.1f lb" % [wallet, weight_lb]

func _update_power_bar() -> void:
	power_bar.value = current_power_norm * 100.0

func _update_target_from_mouse(mouse_x: float) -> void:
	var viewport_width: float = max(1.0, get_viewport().get_visible_rect().size.x)
	var normalized: float = clampf((mouse_x / viewport_width) * 2.0 - 1.0, -1.0, 1.0)
	current_target_x = normalized * (LANE_WIDTH * 0.55)

func _update_aim_line() -> void:
	var start := Vector3(_get_selected_start_x(), LANE_SURFACE_Y + 0.012, 0.0)
	var end := Vector3(current_target_x, LANE_SURFACE_Y + 0.012, HEAD_PIN_Z + 0.15)
	var midpoint: Vector3 = (start + end) * 0.5
	var line_mesh := aim_line.mesh as BoxMesh
	if line_mesh != null:
		line_mesh.size = Vector3(0.03, 0.012, start.distance_to(end))
	aim_line.global_position = midpoint
	aim_line.look_at(end, Vector3.UP)
	aim_line.rotate_y(PI)

func _get_selected_start_x() -> float:
	return float(START_POSITIONS[selected_start_index].get("x", 0.0))

func _get_launch_target_x() -> float:
	var release_error: float = float(player_stats.get("aim_error_m", 0.18))
	release_error *= 1.0 + absf(float(SPIN_OPTIONS[selected_spin_index].get("curve", 0.0))) * 0.18
	return clampf(current_target_x + rng.randf_range(-release_error, release_error), -0.48, 0.48)

func _refresh_option_buttons() -> void:
	for index in range(start_buttons.size()):
		var button := start_buttons[index]
		button.button_pressed = index == selected_start_index
	for index in range(spin_buttons.size()):
		var button := spin_buttons[index]
		button.button_pressed = index == selected_spin_index

func _on_start_position_pressed(index: int) -> void:
	selected_start_index = index
	if run_state == RunState.READY:
		current_target_x = _get_selected_start_x()
	_refresh_option_buttons()

func _on_spin_pressed(index: int) -> void:
	selected_spin_index = index
	_refresh_option_buttons()

func _on_play_again_pressed() -> void:
	_load_progression()
	_begin_series()

func _on_upgrade_button_pressed() -> void:
	SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _on_menu_button_pressed() -> void:
	SceneChanger.change_to_new_scene(Util.get_main_menu_scene_path(), null, 0.2)
