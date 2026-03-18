extends Node2D
class_name MiningMain

const MINING_PROGRESS_SCRIPT = preload("res://Games/Mining/MiningProgress.gd")
const WORLD_HALF_WIDTH := 500.0
const SURFACE_DEPTH := 0.0
const START_X := 0.0
const HUD_COLOR := Color(0.08, 0.1, 0.14, 0.9)
const SKY_COLOR := Color(0.58, 0.76, 0.93, 1.0)
const ROCK_COLOR := Color(0.17, 0.13, 0.1, 1.0)
const SHAFT_COLOR := Color(0.24, 0.18, 0.12, 1.0)
const HAZARD_COLOR := Color(0.93, 0.33, 0.25, 1.0)
const DRILL_COLOR := Color(0.96, 0.77, 0.33, 1.0)
const SHOT_COLOR := Color(0.98, 0.95, 0.75, 1.0)
const PUNCH_COLOR := Color(0.7, 0.95, 1.0, 1.0)
const REFINE_BANK_MULT := 0.35
const MAX_WORLD_OBJECTS := 220
const VIEW_AHEAD_DEPTH := 1300.0
const VIEW_BEHIND_DEPTH := 220.0
const BOSS_INTERVAL_METERS := 200
const FIRST_BOSS_DEPTH := 800
const MAX_TARGETS_PER_REFINE := 28

@onready var wallet_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/WalletLabel
@onready var phase_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/PhaseLabel
@onready var depth_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/DepthLabel
@onready var stat_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/StatLabel
@onready var cargo_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/CargoLabel
@onready var weapon_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/WeaponLabel
@onready var boss_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/BossLabel
@onready var shop_panel: PanelContainer = $CanvasLayer/ShopPanel
@onready var summary_label: Label = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryLabel
@onready var hint_label: Label = $CanvasLayer/HintPanel/HintMargin/HintLabel
@onready var dive_button: Button = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/DiveButton
@onready var reset_button: Button = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/ResetButton
@onready var checkpoint_list: VBoxContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/CheckpointList
@onready var loadout_list: VBoxContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/LoadoutList
@onready var upgrade_list: VBoxContainer = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/UpgradeScroll/UpgradeList

var persistent_data := {
	"wallet": 0,
	"best_depth": 0.0,
	"upgrades": {},
	"boss_unlocks": {},
	"checkpoint_owned": {},
	"selected_checkpoint": 0,
	"equipped": ["pistol", ""],
	"last_run_summary": "No mining run completed yet."
}

var upgrade_catalog: Array[Dictionary] = []
var weapon_defs := {}
var mineral_defs := {}
var checkpoint_buttons := {}
var loadout_buttons: Array[Button] = []
var upgrade_buttons := {}
var rng := RandomNumberGenerator.new()

var run_phase := "garage"
var status_message := "Build the miner, dive, and refine the haul by blasting the skeet targets."
var current_depth := 0.0
var camera_depth := 0.0
var start_depth := 0.0
var player_pos := Vector2.ZERO
var player_velocity := Vector2.ZERO
var oxygen := 0.0
var drill_durability := 0.0
var hull := 0.0
var cargo := {}
var cargo_total := 0.0
var world_nodes: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var enemy_projectiles: Array[Dictionary] = []
var refine_targets: Array[Dictionary] = []
var run_bosses_cleared := {}
var next_node_depth := 10.0
var next_boss_depth := FIRST_BOSS_DEPTH
var active_weapon_slot := 0
var weapon_runtime := {}
var punch_cooldown := 0.0
var refine_spawn_timer := 0.0
var refine_intro_timer := 0.0
var refine_spawn_queue: Array[Dictionary] = []
var boss_state: Dictionary = {}
var last_depth_gain := 0.0
var run_start_wallet := 0
var run_mined := {}
var run_refine_direct_cash := 0
var run_refine_scrap_cash := 0
var run_bosses_defeated := 0

func _ready() -> void:
	Global.game_state = Util.GAME_STATES.UPGRADES
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	rng.randomize()
	_setup_defs()
	_load_progress()
	_build_ui()
	_connect_ui()
	_refresh_ui()
	_begin_dive()

func _process(delta: float) -> void:
	_update_weapon_runtime(delta)
	punch_cooldown = max(0.0, punch_cooldown - delta)
	match run_phase:
		"descending":
			_process_descending(delta)
		"boss":
			_process_boss(delta)
		"ascending":
			_process_ascending(delta)
		"refining":
			_process_refining(delta)
	_update_projectiles(delta)
	_update_enemy_projectiles(delta)
	_cleanup_far_nodes()
	_refresh_ui()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if run_phase in ["descending", "boss", "refining"]:
		if event.is_action_pressed("back"):
			_begin_ascent("Manual recall triggered.")
			get_viewport().set_input_as_handled()
			return
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_TAB or event.keycode == KEY_Q or event.keycode == KEY_E:
				_cycle_weapon_slot()
				get_viewport().set_input_as_handled()
				return
			if event.keycode == KEY_F or event.keycode == KEY_SPACE:
				_use_punch()
				get_viewport().set_input_as_handled()
				return
	if run_phase in ["descending", "boss", "refining"] and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_fire_active_weapon()
			get_viewport().set_input_as_handled()

func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), SKY_COLOR, true)
	if run_phase == "refining" or run_phase == "garage":
		_draw_surface_scene(viewport_size)
	else:
		_draw_mine_scene(viewport_size)
	_draw_projectiles()
	_draw_enemy_projectiles()
	if run_phase == "refining":
		_draw_refine_targets()
	_draw_crosshair()

func _draw_surface_scene(viewport_size: Vector2) -> void:
	draw_rect(Rect2(0.0, viewport_size.y * 0.62, viewport_size.x, viewport_size.y * 0.38), Color(0.17, 0.16, 0.12, 1.0), true)
	draw_rect(Rect2(0.0, viewport_size.y * 0.58, viewport_size.x, 18.0), Color(0.72, 0.64, 0.42, 1.0), true)
	draw_rect(Rect2(90.0, viewport_size.y * 0.28, 180.0, 220.0), Color(0.24, 0.23, 0.25, 1.0), true)
	draw_rect(Rect2(120.0, viewport_size.y * 0.2, 120.0, 120.0), Color(0.19, 0.18, 0.2, 1.0), true)
	draw_line(Vector2(180.0, viewport_size.y * 0.58), Vector2(180.0, viewport_size.y * 0.9), Color(0.1, 0.1, 0.12, 1.0), 8.0)
	draw_line(Vector2(180.0, viewport_size.y * 0.44), Vector2(340.0, viewport_size.y * 0.36), Color(0.16, 0.16, 0.18, 1.0), 7.0)
	var rig_color := Color(0.88, 0.78, 0.48, 1.0)
	draw_circle(Vector2(180.0, viewport_size.y * 0.36), 22.0, rig_color)
	draw_line(Vector2(180.0, viewport_size.y * 0.36), Vector2(180.0, viewport_size.y * 0.56), rig_color, 4.0)
	draw_rect(Rect2(viewport_size.x * 0.48, viewport_size.y * 0.78, 48.0, 18.0), Color(0.28, 0.3, 0.36, 1.0), true)
	if run_phase == "refining":
		var turret := _get_surface_turret_position()
		draw_circle(turret, 20.0, Color(0.22, 0.27, 0.35, 1.0))
		var aim_dir := (get_viewport().get_mouse_position() - turret).normalized()
		if aim_dir == Vector2.ZERO:
			aim_dir = Vector2.RIGHT
		draw_line(turret, turret + aim_dir * 46.0, DRILL_COLOR, 6.0)

func _draw_mine_scene(viewport_size: Vector2) -> void:
	draw_rect(Rect2(0.0, 0.0, viewport_size.x, viewport_size.y), ROCK_COLOR, true)
	var shaft_left := viewport_size.x * 0.5 - WORLD_HALF_WIDTH * 0.6
	var shaft_right := viewport_size.x * 0.5 + WORLD_HALF_WIDTH * 0.6
	draw_rect(Rect2(shaft_left, 0.0, shaft_right - shaft_left, viewport_size.y), SHAFT_COLOR, true)
	for node in world_nodes:
		var screen_pos := _world_to_screen(node["pos"])
		if screen_pos.y < -80.0 or screen_pos.y > viewport_size.y + 80.0:
			continue
		var radius: float = node["radius"]
		match String(node["type"]):
			"hazard":
				_draw_hazard(screen_pos, radius)
			_:
				draw_circle(screen_pos, radius, node["color"])
				draw_arc(screen_pos, radius + 3.0, 0.0, TAU, 18, Color.WHITE * Color(1, 1, 1, 0.18), 2.0)
	_draw_depth_ruler(viewport_size)
	var miner_screen := _world_to_screen(player_pos)
	if run_phase == "ascending":
		var anchor := Vector2(miner_screen.x, -20.0)
		draw_line(anchor, miner_screen, Color(0.94, 0.94, 1.0, 0.85), 4.0)
		draw_line(anchor + Vector2(6.0, 0.0), miner_screen + Vector2(6.0, 0.0), Color(0.72, 0.91, 1.0, 0.65), 2.0)
	_draw_miner(miner_screen)
	if run_phase == "boss":
		_draw_boss(viewport_size)

func _draw_hazard(screen_pos: Vector2, radius: float) -> void:
	var pts := PackedVector2Array()
	for i in range(6):
		var ang := TAU * float(i) / 6.0
		var scale := 1.0 if i % 2 == 0 else 0.45
		pts.append(screen_pos + Vector2.RIGHT.rotated(ang) * radius * scale)
	draw_colored_polygon(pts, HAZARD_COLOR)

func _draw_miner(screen_pos: Vector2) -> void:
	draw_circle(screen_pos, 18.0, Color(0.18, 0.22, 0.28, 1.0))
	draw_line(screen_pos + Vector2(-10.0, 8.0), screen_pos + Vector2(10.0, 8.0), Color(0.45, 0.65, 0.95, 1.0), 6.0)
	draw_line(screen_pos, screen_pos + Vector2(0.0, 26.0), DRILL_COLOR, 7.0)
	draw_circle(screen_pos + Vector2(0.0, 30.0), 7.0, DRILL_COLOR)
	var aim_dir := _get_aim_direction(screen_pos)
	draw_line(screen_pos, screen_pos + aim_dir * 28.0, Color(0.93, 0.93, 0.98, 1.0), 4.0)

func _draw_boss(viewport_size: Vector2) -> void:
	if boss_state.is_empty():
		return
	var boss_pos: Vector2 = boss_state["pos"]
	var boss_screen := _world_to_screen(boss_pos)
	draw_circle(boss_screen, 28.0, Color(0.5, 0.17, 0.15, 1.0))
	draw_circle(boss_screen, 18.0, Color(0.95, 0.61, 0.33, 1.0))
	var pylons: Array = boss_state.get("pylons", [])
	for i in range(pylons.size()):
		var pylon: Dictionary = pylons[i]
		if not bool(pylon.get("alive", true)):
			continue
		var pylon_screen := _world_to_screen(pylon["pos"])
		var pylon_color := Color(0.42, 0.91, 0.98, 1.0) if i == int(boss_state.get("weak_index", 0)) else Color(0.46, 0.46, 0.52, 1.0)
		draw_circle(pylon_screen, 16.0, pylon_color)
		draw_arc(pylon_screen, 22.0, 0.0, TAU, 24, pylon_color * Color(1.0, 1.0, 1.0, 0.35), 3.0)
	var hp_ratio: float = float(boss_state.get("hp", 1.0)) / max(float(boss_state.get("max_hp", 1.0)), 1.0)
	draw_rect(Rect2(viewport_size.x * 0.5 - 170.0, 74.0, 340.0, 16.0), Color(0.12, 0.12, 0.16, 0.95), true)
	draw_rect(Rect2(viewport_size.x * 0.5 - 170.0, 74.0, 340.0 * hp_ratio, 16.0), Color(0.94, 0.42, 0.25, 1.0), true)

func _draw_depth_ruler(viewport_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var font_size := 18
	var ruler_x := 42.0
	draw_line(Vector2(ruler_x, 70.0), Vector2(ruler_x, viewport_size.y - 70.0), Color(0.94, 0.94, 0.98, 0.35), 2.0)
	var visible_top_depth := camera_depth - viewport_size.y * 0.35
	var visible_bottom_depth := camera_depth + viewport_size.y * 0.65
	var start_mark := int(floor(visible_top_depth / 100.0)) * 100
	var end_mark := int(ceil(visible_bottom_depth / 100.0)) * 100
	for mark in range(start_mark, end_mark + 1, 100):
		if mark < 0:
			continue
		var y := _depth_to_screen_y(float(mark))
		draw_line(Vector2(ruler_x - 10.0, y), Vector2(ruler_x + 10.0, y), Color(1, 1, 1, 0.5), 2.0)
		if font != null:
			draw_string(font, Vector2(56.0, y + 6.0), "%dm" % mark, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(1, 1, 1, 0.85))

func _draw_projectiles() -> void:
	for projectile in projectiles:
		draw_circle(_world_to_screen(projectile["pos"]), projectile["radius"], projectile["color"])

func _draw_enemy_projectiles() -> void:
	for projectile in enemy_projectiles:
		draw_circle(_world_to_screen(projectile["pos"]), projectile["radius"], projectile["color"])

func _draw_refine_targets() -> void:
	for target in refine_targets:
		draw_circle(target["pos"], target["radius"], target["color"])
		draw_arc(target["pos"], target["radius"] + 4.0, 0.0, TAU, 20, Color.WHITE * Color(1.0, 1.0, 1.0, 0.35), 2.0)

func _draw_crosshair() -> void:
	var mouse := get_viewport().get_mouse_position()
	draw_line(mouse + Vector2(-8.0, 0.0), mouse + Vector2(8.0, 0.0), Color.WHITE, 2.0)
	draw_line(mouse + Vector2(0.0, -8.0), mouse + Vector2(0.0, 8.0), Color.WHITE, 2.0)

func _process_descending(delta: float) -> void:
	Global.game_state = Util.GAME_STATES.PLAYING
	var move_x := Input.get_axis("left", "right")
	player_pos.x = clamp(player_pos.x + move_x * _get_horizontal_speed() * delta, -WORLD_HALF_WIDTH, WORLD_HALF_WIDTH)
	var dive_speed := _get_dive_speed()
	var launch_span := _get_launch_boost_span()
	if current_depth < start_depth + launch_span:
		dive_speed *= _get_launch_speed_mult()
		if _has_upgrade("teleport_core") and current_depth < start_depth + 45.0:
			_auto_scoop_launch_ores(delta)
	var manual_vertical := Input.get_axis("up", "down")
	dive_speed += manual_vertical * 35.0
	var prev_depth := current_depth
	current_depth += max(40.0, dive_speed) * delta
	last_depth_gain = current_depth - prev_depth
	player_pos.y = current_depth
	camera_depth = lerpf(camera_depth, current_depth, min(1.0, delta * 7.5))
	oxygen = max(0.0, oxygen - delta)
	drill_durability = max(0.0, drill_durability - delta * 1.25 - last_depth_gain * 0.018)
	_add_cargo("dirt", last_depth_gain * _get_dirt_yield())
	_spawn_world_until(current_depth + VIEW_AHEAD_DEPTH)
	_process_world_contacts(delta)
	_check_phase_failures()
	_check_boss_trigger()

func _process_boss(delta: float) -> void:
	Global.game_state = Util.GAME_STATES.PLAYING
	var input_vec := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	player_pos += input_vec * _get_horizontal_speed() * 0.8 * delta
	player_pos.x = clamp(player_pos.x, -WORLD_HALF_WIDTH * 0.92, WORLD_HALF_WIDTH * 0.92)
	player_pos.y = clamp(player_pos.y, boss_state["arena_top"], boss_state["arena_bottom"])
	camera_depth = lerpf(camera_depth, player_pos.y, min(1.0, delta * 5.0))
	oxygen = max(0.0, oxygen - delta * 0.8)
	drill_durability = max(0.0, drill_durability - delta * 0.25)
	var pylons: Array = boss_state.get("pylons", [])
	for i in range(pylons.size()):
		if not bool(pylons[i].get("alive", true)):
			continue
		var angle := float(pylons[i]["angle"]) + delta * (1.1 + 0.25 * i)
		pylons[i]["angle"] = angle
		pylons[i]["pos"] = boss_state["pos"] + Vector2.RIGHT.rotated(angle) * 95.0
	boss_state["pylons"] = pylons
	var attack_cd := float(boss_state.get("attack_cd", 0.0)) - delta
	if attack_cd <= 0.0:
		attack_cd = max(0.55, 1.3 - 0.05 * float(boss_state.get("tier", 1)))
		_fire_enemy_shot(boss_state["pos"], (player_pos - boss_state["pos"]).normalized(), 210.0 + 12.0 * float(boss_state.get("tier", 1)))
	boss_state["attack_cd"] = attack_cd
	_check_phase_failures()

func _process_ascending(delta: float) -> void:
	Global.game_state = Util.GAME_STATES.PLAYING
	var speed := _get_ascent_speed()
	current_depth = max(SURFACE_DEPTH, current_depth - speed * delta)
	player_pos.y = current_depth
	camera_depth = lerpf(camera_depth, current_depth, min(1.0, delta * 9.0))
	if current_depth <= SURFACE_DEPTH + 0.01:
		_begin_refining_phase()

func _process_refining(delta: float) -> void:
	Global.game_state = Util.GAME_STATES.PLAYING
	refine_intro_timer = max(0.0, refine_intro_timer - delta)
	refine_spawn_timer -= delta
	if refine_spawn_timer <= 0.0 and not refine_spawn_queue.is_empty():
		refine_spawn_timer = 0.16
		refine_targets.append(refine_spawn_queue.pop_front())
	for target in refine_targets:
		target["pos"] += target["vel"] * delta
		target["life"] = float(target["life"]) - delta
	var kept: Array[Dictionary] = []
	for target in refine_targets:
		if target["life"] <= 0.0 or target["pos"].x < -60.0 or target["pos"].x > get_viewport_rect().size.x + 60.0:
			_bank_refine_target(target, false)
		else:
			kept.append(target)
	refine_targets = kept
	if refine_intro_timer <= 0.0 and refine_targets.is_empty() and refine_spawn_queue.is_empty():
		_return_to_upgrade_scene()

func _update_projectiles(delta: float) -> void:
	var kept: Array[Dictionary] = []
	for projectile in projectiles:
		projectile["pos"] += projectile["vel"] * delta
		projectile["life"] = float(projectile["life"]) - delta
		if projectile["life"] <= 0.0:
			continue
		if run_phase == "refining":
			if _check_projectile_hit_refine_target(projectile):
				continue
		else:
			if _check_projectile_hit_world(projectile):
				continue
		kept.append(projectile)
	projectiles = kept

func _update_enemy_projectiles(delta: float) -> void:
	var kept: Array[Dictionary] = []
	for projectile in enemy_projectiles:
		projectile["pos"] += projectile["vel"] * delta
		projectile["life"] = float(projectile["life"]) - delta
		if projectile["life"] <= 0.0:
			continue
		if projectile["pos"].distance_to(player_pos) <= float(projectile["radius"]) + 18.0:
			hull = max(0.0, hull - float(projectile["damage"]))
			status_message = "Hull rattled. Keep moving."
			continue
		kept.append(projectile)
	enemy_projectiles = kept

func _check_projectile_hit_world(projectile: Dictionary) -> bool:
	for i in range(world_nodes.size() - 1, -1, -1):
		var node: Dictionary = world_nodes[i]
		if projectile["pos"].distance_to(node["pos"]) > float(projectile["radius"]) + float(node["radius"]):
			continue
		if String(node["type"]) == "hazard":
			world_nodes.remove_at(i)
			hull = max(0.0, hull - 3.0)
			status_message = "You clipped an explosive pocket."
			return true
		node["hp"] = float(node["hp"]) - float(projectile["damage"])
		world_nodes[i] = node
		if float(node["hp"]) <= 0.0:
			_collect_world_node(i, String(node["type"]))
		return true
	if run_phase == "boss" and not boss_state.is_empty():
		var weak_index := int(boss_state.get("weak_index", 0))
		var pylons: Array = boss_state.get("pylons", [])
		for i in range(pylons.size()):
			var pylon: Dictionary = pylons[i]
			if not bool(pylon.get("alive", true)):
				continue
			if projectile["pos"].distance_to(pylon["pos"]) <= float(projectile["radius"]) + 18.0:
				if i != weak_index:
					status_message = "The boss shield reroutes. Break the glowing pylon."
					return true
				pylon["hp"] = float(pylon["hp"]) - float(projectile["damage"])
				if float(pylon["hp"]) <= 0.0:
					pylon["alive"] = false
					boss_state["weak_index"] = _find_next_alive_pylon_index(pylons)
					status_message = "Shield node cracked. One more lock gone."
				pylons[i] = pylon
				boss_state["pylons"] = pylons
				return true
		if _all_boss_pylons_down() and projectile["pos"].distance_to(boss_state["pos"]) <= float(projectile["radius"]) + 28.0:
			boss_state["hp"] = float(boss_state["hp"]) - float(projectile["damage"])
			if float(boss_state["hp"]) <= 0.0:
				_finish_boss()
			return true
	return false

func _check_projectile_hit_refine_target(projectile: Dictionary) -> bool:
	for i in range(refine_targets.size() - 1, -1, -1):
		var target: Dictionary = refine_targets[i]
		if projectile["pos"].distance_to(target["pos"]) > float(projectile["radius"]) + float(target["radius"]):
			continue
		_bank_refine_target(target, true)
		refine_targets.remove_at(i)
		status_message = "Refined %s into cash." % String(target["label"])
		return true
	return false

func _process_world_contacts(delta: float) -> void:
	for i in range(world_nodes.size() - 1, -1, -1):
		var node: Dictionary = world_nodes[i]
		if player_pos.distance_to(node["pos"]) > float(node["radius"]) + 24.0:
			continue
		if String(node["type"]) == "hazard":
			hull = max(0.0, hull - 16.0 * delta)
			status_message = "Hazardous vein. Strafe out or blow it apart."
			continue
		node["hp"] = float(node["hp"]) - _get_drill_power() * delta
		drill_durability = max(0.0, drill_durability - delta * (0.55 + float(node.get("hardness", 1.0)) * 0.18))
		world_nodes[i] = node
		if float(node["hp"]) <= 0.0:
			_collect_world_node(i, String(node["type"]))

func _collect_world_node(index: int, node_type: String) -> void:
	if index < 0 or index >= world_nodes.size():
		return
	world_nodes.remove_at(index)
	var mineral: Dictionary = mineral_defs.get(node_type, {})
	var payout := float(mineral.get("yield", 0.0))
	_add_cargo(node_type, payout)
	status_message = "Collected %s." % String(mineral.get("label", node_type.capitalize()))

func _check_phase_failures() -> void:
	if oxygen <= 0.0:
		_begin_ascent("Oxygen dry. Emergency ascent engaged.")
		return
	if drill_durability <= 0.0:
		_begin_ascent("Drill chewed through its last bit. Winching out.")
		return
	if hull <= 0.0:
		_begin_ascent("Hull compromised. Surface recall.")

func _check_boss_trigger() -> void:
	if current_depth < float(next_boss_depth):
		return
	if bool(run_bosses_cleared.get(next_boss_depth, false)):
		next_boss_depth += BOSS_INTERVAL_METERS
		return
	_start_boss(next_boss_depth)

func _begin_dive() -> void:
	run_phase = "descending"
	Global.game_state = Util.GAME_STATES.PLAYING
	start_depth = float(int(persistent_data.get("selected_checkpoint", 0)))
	current_depth = start_depth
	camera_depth = current_depth
	player_pos = Vector2(START_X, current_depth)
	player_velocity = Vector2.ZERO
	oxygen = _get_max_oxygen()
	drill_durability = _get_max_drill()
	hull = _get_max_hull()
	cargo = {}
	cargo_total = 0.0
	world_nodes.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	refine_targets.clear()
	refine_spawn_queue.clear()
	run_bosses_cleared = {}
	next_node_depth = current_depth + 10.0
	next_boss_depth = FIRST_BOSS_DEPTH if start_depth < FIRST_BOSS_DEPTH else int(start_depth) + BOSS_INTERVAL_METERS
	weapon_runtime = {}
	_init_weapon_runtime()
	active_weapon_slot = 0
	punch_cooldown = 0.0
	boss_state.clear()
	run_start_wallet = int(persistent_data.get("wallet", 0))
	run_mined = {}
	run_refine_direct_cash = 0
	run_refine_scrap_cash = 0
	run_bosses_defeated = 0
	status_message = "Run live. Go deep, aim for richer ore, and watch oxygen, drill wear, and hull damage."
	_spawn_world_until(current_depth + VIEW_AHEAD_DEPTH)
	shop_panel.visible = false

func _begin_ascent(message: String) -> void:
	if run_phase == "ascending" or run_phase == "refining" or run_phase == "garage":
		return
	run_phase = "ascending"
	Global.game_state = Util.GAME_STATES.PLAYING
	status_message = message
	projectiles.clear()
	enemy_projectiles.clear()
	boss_state.clear()
	persistent_data["best_depth"] = max(float(persistent_data.get("best_depth", 0.0)), current_depth)
	_save_progress()

func _begin_refining_phase() -> void:
	run_phase = "refining"
	Global.game_state = Util.GAME_STATES.PLAYING
	world_nodes.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	camera_depth = 0.0
	player_pos = Vector2.ZERO
	refine_intro_timer = 0.9
	_build_refine_queue()
	status_message = "Refinery skeet online. Blast the minerals out of the haul for full value, or let misses auto-bank scraps."
	_save_progress()

func _enter_garage(message: String) -> void:
	run_phase = "garage"
	Global.game_state = Util.GAME_STATES.UPGRADES
	camera_depth = 0.0
	current_depth = 0.0
	player_pos = Vector2.ZERO
	world_nodes.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	refine_targets.clear()
	refine_spawn_queue.clear()
	boss_state.clear()
	status_message = message
	shop_panel.visible = true
	_refresh_checkpoint_buttons()
	_refresh_loadout_buttons()
	_refresh_upgrade_buttons()
	_save_progress()

func _return_to_upgrade_scene() -> void:
	persistent_data["best_depth"] = max(float(persistent_data.get("best_depth", 0.0)), current_depth)
	persistent_data["last_run_summary"] = _build_last_run_summary()
	_save_progress()
	Global.game_state = Util.GAME_STATES.UPGRADES
	SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _build_last_run_summary() -> String:
	var lines := PackedStringArray()
	lines.append("Last Mining Run")
	lines.append("Deepest depth: %dm" % int(round(current_depth)))
	lines.append("Wallet gained: $%d" % max(0, int(persistent_data.get("wallet", 0)) - run_start_wallet))
	lines.append("Direct refinery hits: $%d" % run_refine_direct_cash)
	lines.append("Auto-banked scraps: $%d" % run_refine_scrap_cash)
	lines.append("Bosses defeated: %d" % run_bosses_defeated)
	if not run_mined.is_empty():
		var parts := PackedStringArray()
		for mineral_id in run_mined.keys():
			parts.append("%s %d" % [String(mineral_id).capitalize(), int(round(float(run_mined[mineral_id])))])
		lines.append("Mined: %s" % ", ".join(parts))
	return "\n".join(lines)

func _start_boss(depth_marker: int) -> void:
	run_phase = "boss"
	status_message = "Deep-strata boss online. Break the glowing shield locks, then unload on the core."
	var tier: int = max(1, int(depth_marker / BOSS_INTERVAL_METERS))
	boss_state = {
		"depth": depth_marker,
		"tier": tier,
		"pos": Vector2(0.0, float(depth_marker) + 40.0),
		"arena_top": float(depth_marker) - 60.0,
		"arena_bottom": float(depth_marker) + 170.0,
		"hp": 70.0 + 42.0 * tier,
		"max_hp": 70.0 + 42.0 * tier,
		"attack_cd": 1.1,
		"weak_index": 0,
		"pylons": []
	}
	player_pos.y = float(depth_marker) + 120.0
	current_depth = player_pos.y
	var pylons: Array[Dictionary] = []
	for i in range(3):
		var angle := TAU * float(i) / 3.0
		pylons.append({
			"angle": angle,
			"pos": boss_state["pos"] + Vector2.RIGHT.rotated(angle) * 95.0,
			"hp": 18.0 + 12.0 * tier,
			"alive": true
		})
	boss_state["pylons"] = pylons

func _finish_boss() -> void:
	var marker := int(boss_state.get("depth", next_boss_depth))
	run_bosses_cleared[marker] = true
	persistent_data["boss_unlocks"][str(marker)] = true
	persistent_data["checkpoint_owned"][str(marker)] = true
	persistent_data["selected_checkpoint"] = max(int(persistent_data.get("selected_checkpoint", 0)), marker)
	run_bosses_defeated += 1
	status_message = "Boss crushed. %dm checkpoint locked into the shaft." % marker
	_add_wallet(40 + int(marker * 0.45))
	current_depth = float(marker) + 10.0
	player_pos.y = current_depth
	camera_depth = current_depth
	next_boss_depth = marker + BOSS_INTERVAL_METERS
	boss_state.clear()
	run_phase = "descending"
	_save_progress()

func _fire_active_weapon() -> void:
	var weapon_id := _get_active_weapon_id()
	if weapon_id.is_empty():
		_use_punch()
		return
	var runtime: Dictionary = weapon_runtime.get(weapon_id, {})
	if runtime.is_empty():
		return
	if bool(runtime.get("reloading", false)):
		status_message = "%s is still reloading." % String(weapon_defs[weapon_id]["label"])
		return
	if int(runtime.get("ammo", 0)) <= 0:
		_start_reload(weapon_id)
		if _both_weapons_reloading():
			status_message = "Both guns are reloading. Throw hands."
		return
	var def: Dictionary = weapon_defs[weapon_id]
	runtime["ammo"] = int(runtime["ammo"]) - 1
	if int(runtime["ammo"]) <= 0:
		_start_reload(weapon_id)
	weapon_runtime[weapon_id] = runtime
	var origin := _get_weapon_origin()
	var aim_dir := _get_aim_direction(origin)
	for spread_step in range(int(def["pellets"])):
		var spread_count: int = max(1, int(def["pellets"]))
		var spread_t := 0.0 if spread_count == 1 else (float(spread_step) / float(spread_count - 1) - 0.5)
		var dir := aim_dir.rotated(spread_t * float(def["spread"]))
		projectiles.append({
			"pos": _screen_to_world(origin),
			"vel": dir * float(def["speed"]),
			"damage": _get_weapon_damage(weapon_id) / float(spread_count),
			"radius": float(def["radius"]),
			"life": float(def["life"]),
			"color": def["color"]
		})
	status_message = "%s fired." % String(def["label"])

func _use_punch() -> void:
	if punch_cooldown > 0.0:
		return
	punch_cooldown = max(0.18, 0.45 - 0.02 * _get_upgrade_level("punch_damage"))
	var did_hit := false
	if run_phase == "refining":
		for i in range(refine_targets.size() - 1, -1, -1):
			if refine_targets[i]["pos"].distance_to(_get_surface_turret_position()) <= 95.0:
				_bank_refine_target(refine_targets[i], true)
				refine_targets.remove_at(i)
				did_hit = true
				break
	else:
		for i in range(world_nodes.size() - 1, -1, -1):
			if world_nodes[i]["pos"].distance_to(player_pos) > float(world_nodes[i]["radius"]) + 70.0:
				continue
			if String(world_nodes[i]["type"]) == "hazard":
				world_nodes.remove_at(i)
				did_hit = true
				break
			world_nodes[i]["hp"] = float(world_nodes[i]["hp"]) - _get_punch_damage()
			if float(world_nodes[i]["hp"]) <= 0.0:
				_collect_world_node(i, String(world_nodes[i]["type"]))
			did_hit = true
			break
		if not did_hit and run_phase == "boss" and not boss_state.is_empty():
			if player_pos.distance_to(boss_state["pos"]) <= 82.0 and _all_boss_pylons_down():
				boss_state["hp"] = float(boss_state["hp"]) - _get_punch_damage()
				if float(boss_state["hp"]) <= 0.0:
					_finish_boss()
				did_hit = true
	status_message = "Punch lands." if did_hit else "Swing missed."

func _cycle_weapon_slot() -> void:
	var ids := _get_equipped_weapons()
	if ids.is_empty():
		return
	active_weapon_slot = (active_weapon_slot + 1) % max(1, ids.size())
	status_message = "Swapped to %s." % String(weapon_defs[_get_active_weapon_id()]["label"])

func _start_reload(weapon_id: String) -> void:
	var runtime: Dictionary = weapon_runtime.get(weapon_id, {})
	if runtime.is_empty() or bool(runtime.get("reloading", false)):
		return
	runtime["reloading"] = true
	runtime["reload_timer"] = _get_weapon_reload(weapon_id)
	weapon_runtime[weapon_id] = runtime

func _update_weapon_runtime(delta: float) -> void:
	for weapon_id in weapon_runtime.keys():
		var runtime: Dictionary = weapon_runtime[weapon_id]
		if not bool(runtime.get("reloading", false)):
			continue
		runtime["reload_timer"] = float(runtime["reload_timer"]) - delta
		if float(runtime["reload_timer"]) <= 0.0:
			runtime["reloading"] = false
			runtime["ammo"] = int(weapon_defs[weapon_id]["mag"])
		weapon_runtime[weapon_id] = runtime

func _build_refine_queue() -> void:
	refine_targets.clear()
	refine_spawn_queue.clear()
	refine_spawn_timer = 0.0
	var viewport_size := get_viewport_rect().size
	var total_spawned := 0
	for mineral_id in cargo.keys():
		var amount := float(cargo[mineral_id])
		if amount <= 0.0:
			continue
		var mineral: Dictionary = mineral_defs.get(mineral_id, {})
		var count := clampi(int(round(amount / max(float(mineral.get("yield", 1.0)), 1.0))), 1, MAX_TARGETS_PER_REFINE)
		if mineral_id == "dirt":
			count = clampi(int(round(amount / 10.0)), 2, 18)
		var ore_grade_mult := 1.0 + 0.08 * _get_upgrade_level("cargo_racks")
		var base_cash_value := float(mineral.get("cash_value", 2.0))
		if mineral_id == "dirt":
			base_cash_value = 0.42
		var per_target_value: int = max(1, int(round(base_cash_value * amount * ore_grade_mult / float(count))))
		for i in range(count):
			var from_left := (i % 2) == 0
			var start_x := -40.0 if from_left else viewport_size.x + 40.0
			var velocity_x := 170.0 + 18.0 * float(i % 4)
			if not from_left:
				velocity_x *= -1.0
			refine_spawn_queue.append({
				"pos": Vector2(start_x, viewport_size.y * (0.32 + 0.3 * randf())),
				"vel": Vector2(velocity_x, -24.0 + 12.0 * sin(float(i))),
				"radius": 13.0 + float(mineral.get("radius_bonus", 0.0)) + (2.0 if mineral_id != "dirt" else 0.0),
				"life": 8.5,
				"value": per_target_value,
				"label": "Rubble" if mineral_id == "dirt" else mineral.get("label", mineral_id.capitalize()),
				"color": Color(0.68, 0.58, 0.44, 1.0) if mineral_id == "dirt" else mineral.get("color", Color.WHITE)
			})
			total_spawned += 1
	if total_spawned <= 0:
		refine_spawn_queue.append({
			"pos": Vector2(-40.0, viewport_size.y * 0.45),
			"vel": Vector2(190.0, -18.0),
			"radius": 16.0,
			"life": 7.0,
			"value": 1,
			"label": "Scrap",
			"color": Color(0.75, 0.75, 0.8, 1.0)
		})
	cargo.clear()
	cargo_total = 0.0

func _bank_refine_target(target: Dictionary, direct_hit: bool) -> void:
	var value := int(target["value"])
	if not direct_hit:
		value = max(1, int(round(float(value) * REFINE_BANK_MULT)))
		run_refine_scrap_cash += value
	else:
		run_refine_direct_cash += value
	_add_wallet(value)

func _add_wallet(amount: int) -> void:
	persistent_data["wallet"] = int(persistent_data.get("wallet", 0)) + max(0, amount)

func _add_cargo(mineral_id: String, amount: float) -> void:
	if amount <= 0.0:
		return
	cargo[mineral_id] = float(cargo.get(mineral_id, 0.0)) + amount
	cargo_total += amount
	if run_phase in ["descending", "boss"]:
		run_mined[mineral_id] = float(run_mined.get(mineral_id, 0.0)) + amount

func _spawn_world_until(target_depth: float) -> void:
	while next_node_depth <= target_depth and world_nodes.size() < MAX_WORLD_OBJECTS:
		var band_depth := next_node_depth
		next_node_depth += rng.randf_range(22.0, 40.0)
		var node_roll := rng.randf()
		if node_roll < 0.16:
			world_nodes.append(_make_world_node("hazard", band_depth))
			continue
		var table := _pick_mineral_for_depth(band_depth)
		world_nodes.append(_make_world_node(table, band_depth))
		if rng.randf() < 0.22:
			world_nodes.append(_make_world_node("dirt", band_depth + rng.randf_range(-10.0, 10.0)))

func _make_world_node(mineral_id: String, depth_value: float) -> Dictionary:
	var mineral: Dictionary = mineral_defs[mineral_id]
	var pos := Vector2(rng.randf_range(-WORLD_HALF_WIDTH * 0.92, WORLD_HALF_WIDTH * 0.92), depth_value + rng.randf_range(-12.0, 12.0))
	return {
		"type": mineral_id,
		"pos": pos,
		"radius": float(mineral["radius"]) + rng.randf_range(-3.0, 3.0),
		"hp": float(mineral["hp"]) * (1.0 + depth_value / 350.0),
		"yield": float(mineral["yield"]),
		"hardness": float(mineral["hardness"]),
		"color": mineral["color"]
	}

func _cleanup_far_nodes() -> void:
	var kept: Array[Dictionary] = []
	for node in world_nodes:
		if node["pos"].y < camera_depth - VIEW_BEHIND_DEPTH:
			continue
		if node["pos"].y > camera_depth + VIEW_AHEAD_DEPTH + 160.0:
			continue
		kept.append(node)
	world_nodes = kept

func _fire_enemy_shot(origin: Vector2, direction: Vector2, speed: float) -> void:
	enemy_projectiles.append({
		"pos": origin,
		"vel": direction.normalized() * speed,
		"damage": 11.0 + 1.5 * float(boss_state.get("tier", 1)),
		"radius": 7.0,
		"life": 5.0,
		"color": Color(1.0, 0.6, 0.3, 1.0)
	})

func _build_ui() -> void:
	for child in checkpoint_list.get_children():
		child.queue_free()
	for child in loadout_list.get_children():
		child.queue_free()
	for child in upgrade_list.get_children():
		child.queue_free()
	checkpoint_buttons.clear()
	loadout_buttons.clear()
	upgrade_buttons.clear()
	for checkpoint in range(FIRST_BOSS_DEPTH, 2001, BOSS_INTERVAL_METERS):
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_checkpoint_button_pressed.bind(checkpoint))
		checkpoint_list.add_child(button)
		checkpoint_buttons[checkpoint] = button
	for slot_index in range(2):
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_loadout_button_pressed.bind(slot_index))
		loadout_list.add_child(button)
		loadout_buttons.append(button)
	for upgrade_def in upgrade_catalog:
		var button := Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_upgrade_button_pressed.bind(String(upgrade_def["id"])))
		upgrade_list.add_child(button)
		upgrade_buttons[String(upgrade_def["id"])] = button

func _connect_ui() -> void:
	if not dive_button.pressed.is_connected(_on_dive_button_pressed):
		dive_button.pressed.connect(_on_dive_button_pressed)
	if not reset_button.pressed.is_connected(_on_reset_button_pressed):
		reset_button.pressed.connect(_on_reset_button_pressed)

func _refresh_ui() -> void:
	wallet_label.text = "Wallet: $%s" % Util.get_number_short_text(int(persistent_data.get("wallet", 0)))
	phase_label.text = "Phase: %s" % run_phase.capitalize()
	depth_label.text = "Depth: %dm  Best: %dm" % [int(round(current_depth)), int(round(float(persistent_data.get("best_depth", 0.0))))]
	stat_label.text = "O2 %d/%d   Drill %d/%d   Hull %d/%d" % [int(round(oxygen)), int(round(_get_max_oxygen())), int(round(drill_durability)), int(round(_get_max_drill())), int(round(hull)), int(round(_get_max_hull()))]
	cargo_label.text = "Cargo: %d" % int(round(cargo_total))
	weapon_label.text = _build_weapon_status_text()
	boss_label.text = "Next Deep Boss: %dm" % next_boss_depth if run_phase != "garage" else "Selected Start: %dm" % int(persistent_data.get("selected_checkpoint", 0))
	summary_label.text = _build_summary_text()
	hint_label.text = status_message
	shop_panel.visible = run_phase == "garage"
	dive_button.text = "Dive from %dm" % int(persistent_data.get("selected_checkpoint", 0))
	_refresh_checkpoint_buttons()
	_refresh_loadout_buttons()
	_refresh_upgrade_buttons()

func _build_weapon_status_text() -> String:
	var text_parts: Array[String] = []
	var equipped := _get_equipped_weapons()
	for i in range(equipped.size()):
		var weapon_id := equipped[i]
		var runtime: Dictionary = weapon_runtime.get(weapon_id, {"ammo": int(weapon_defs[weapon_id]["mag"]), "reloading": false, "reload_timer": 0.0})
		var part := "%s%s %d/%d" % ["> " if i == active_weapon_slot else "", String(weapon_defs[weapon_id]["label"]), int(runtime.get("ammo", 0)), int(weapon_defs[weapon_id]["mag"])]
		if bool(runtime.get("reloading", false)):
			part += " reloading %.1fs" % max(0.0, float(runtime.get("reload_timer", 0.0)))
		text_parts.append(part)
	text_parts.append("Punch %d" % int(round(_get_punch_damage())))
	return "   ".join(text_parts)

func _build_summary_text() -> String:
	var lines := PackedStringArray()
	lines.append("Steer into dense nodes for a bigger haul. Dirt pays little, deep crystals pay real money.")
	lines.append("Early runs are about pushing depth and surviving attrition from oxygen, drill wear, and hull damage.")
	lines.append("Deep bosses do not start until %dm, then appear every %dm." % [FIRST_BOSS_DEPTH, BOSS_INTERVAL_METERS])
	lines.append("Ascent cord speed: x%.1f    Launch speed: x%.1f for %dm" % [_get_ascent_speed() / max(_get_dive_speed(), 1.0), _get_launch_speed_mult(), int(_get_launch_boost_span())])
	lines.append("Owned skips: %s" % _get_owned_checkpoint_summary())
	return "\n".join(lines)

func _refresh_checkpoint_buttons() -> void:
	for checkpoint in checkpoint_buttons.keys():
		var button: Button = checkpoint_buttons[checkpoint]
		var owned := bool(persistent_data["checkpoint_owned"].get(str(checkpoint), false))
		var unlocked := bool(persistent_data["boss_unlocks"].get(str(checkpoint), false))
		var selected: bool = int(persistent_data.get("selected_checkpoint", 0)) == checkpoint
		var cost := _get_checkpoint_cost(checkpoint)
		if owned:
			button.text = "%dm skip%s" % [checkpoint, " (selected)" if selected else ""]
			button.disabled = false
		elif unlocked:
			button.text = "Buy %dm skip - $%d" % [checkpoint, cost]
			button.disabled = int(persistent_data.get("wallet", 0)) < cost
		else:
			button.text = "%dm skip locked (beat deep boss)" % checkpoint
			button.disabled = true

func _refresh_loadout_buttons() -> void:
	var equipped: Array = persistent_data.get("equipped", ["pistol", ""])
	for slot_index in range(loadout_buttons.size()):
		var button := loadout_buttons[slot_index]
		var weapon_id := String(equipped[slot_index])
		button.text = "Gun %d: %s" % [slot_index + 1, "Empty" if weapon_id.is_empty() else String(weapon_defs[weapon_id]["label"])]

func _refresh_upgrade_buttons() -> void:
	for upgrade_def in upgrade_catalog:
		var id := String(upgrade_def["id"])
		var button: Button = upgrade_buttons[id]
		var level := _get_upgrade_level(id)
		var max_level := int(upgrade_def["max_level"])
		var cost := _get_upgrade_cost(upgrade_def)
		var req_text := _get_upgrade_requirement_text(upgrade_def)
		button.text = "%s  Lv %d/%d  $%d\n%s%s" % [String(upgrade_def["label"]), level, max_level, cost, String(upgrade_def["summary"]), req_text]
		button.disabled = level >= max_level or int(persistent_data.get("wallet", 0)) < cost or not _meets_upgrade_requirements(upgrade_def)

func _on_dive_button_pressed() -> void:
	_begin_dive()

func _on_reset_button_pressed() -> void:
	persistent_data = MINING_PROGRESS_SCRIPT.reset_progress()
	_enter_garage("Mining progression reset. Fresh drill, fresh debt, fresh depths.")

func _on_checkpoint_button_pressed(checkpoint: int) -> void:
	var key := str(checkpoint)
	if bool(persistent_data["checkpoint_owned"].get(key, false)):
		persistent_data["selected_checkpoint"] = checkpoint
		status_message = "Start depth armed for %dm." % checkpoint
		_save_progress()
		return
	if not bool(persistent_data["boss_unlocks"].get(key, false)):
		return
	var cost := _get_checkpoint_cost(checkpoint)
	if int(persistent_data.get("wallet", 0)) < cost:
		return
	persistent_data["wallet"] = int(persistent_data.get("wallet", 0)) - cost
	persistent_data["checkpoint_owned"][key] = true
	persistent_data["selected_checkpoint"] = checkpoint
	status_message = "Skip beacon built for %dm." % checkpoint
	_save_progress()

func _on_loadout_button_pressed(slot_index: int) -> void:
	var unlocked := _get_unlocked_weapons()
	unlocked.append("")
	var equipped: Array = persistent_data.get("equipped", ["pistol", ""])
	var current := String(equipped[slot_index])
	var current_index := unlocked.find(current)
	current_index = 0 if current_index == -1 else current_index
	for step in range(1, unlocked.size() + 1):
		var next_id := String(unlocked[(current_index + step) % unlocked.size()])
		if next_id == "" and slot_index == 0:
			continue
		if next_id != "" and slot_index == 1 and next_id == String(equipped[0]):
			continue
		equipped[slot_index] = next_id
		break
	persistent_data["equipped"] = equipped
	_save_progress()

func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	var def := _get_upgrade_def(upgrade_id)
	if def.is_empty():
		return
	if not _meets_upgrade_requirements(def):
		return
	var level := _get_upgrade_level(upgrade_id)
	if level >= int(def["max_level"]):
		return
	var cost := _get_upgrade_cost(def)
	if int(persistent_data.get("wallet", 0)) < cost:
		return
	persistent_data["wallet"] = int(persistent_data.get("wallet", 0)) - cost
	persistent_data["upgrades"][upgrade_id] = level + 1
	if upgrade_id == "shotgun_unlock":
		_try_auto_equip_weapon("shotgun")
	elif upgrade_id == "rifle_unlock":
		_try_auto_equip_weapon("rifle")
	elif upgrade_id == "railgun_unlock":
		_try_auto_equip_weapon("railgun")
	status_message = "%s upgraded." % String(def["label"])
	_save_progress()

func _get_upgrade_def(upgrade_id: String) -> Dictionary:
	for upgrade_def in upgrade_catalog:
		if String(upgrade_def["id"]) == upgrade_id:
			return upgrade_def
	return {}

func _get_upgrade_level(upgrade_id: String) -> int:
	return int(persistent_data["upgrades"].get(upgrade_id, 0))

func _get_upgrade_cost(upgrade_def: Dictionary) -> int:
	var level := _get_upgrade_level(String(upgrade_def["id"]))
	return int(round(float(upgrade_def["base_cost"]) * pow(float(upgrade_def.get("cost_mult", 1.45)), level)))

func _meets_upgrade_requirements(upgrade_def: Dictionary) -> bool:
	var reqs: Dictionary = upgrade_def.get("requires", {})
	for req_id in reqs.keys():
		if _get_upgrade_level(String(req_id)) < int(reqs[req_id]):
			return false
	return true

func _get_upgrade_requirement_text(upgrade_def: Dictionary) -> String:
	if _meets_upgrade_requirements(upgrade_def):
		return ""
	var reqs: Dictionary = upgrade_def.get("requires", {})
	var parts := PackedStringArray()
	for req_id in reqs.keys():
		parts.append(" needs %s %d" % [String(_get_upgrade_def(String(req_id)).get("label", req_id)), int(reqs[req_id])])
	return "\n" + ", ".join(parts)

func _get_dive_speed() -> float:
	return 110.0 + 16.0 * _get_upgrade_level("thruster_power") + 9.0 * _get_upgrade_level("shaft_lubricant")

func _get_ascent_speed() -> float:
	return _get_dive_speed() * (8.0 + 0.9 * _get_upgrade_level("cord_winch"))

func _get_horizontal_speed() -> float:
	return 220.0 + 12.0 * _get_upgrade_level("shaft_lubricant")

func _get_max_oxygen() -> float:
	return 38.0 + 12.0 * _get_upgrade_level("oxygen_tanks")

func _get_max_drill() -> float:
	return 55.0 + 14.0 * _get_upgrade_level("drill_integrity")

func _get_drill_power() -> float:
	return 14.0 + 4.5 * _get_upgrade_level("drill_power")

func _get_max_hull() -> float:
	return 44.0 + 16.0 * _get_upgrade_level("hull_plating")

func _get_cargo_capacity() -> float:
	return 120.0 + 38.0 * _get_upgrade_level("cargo_racks")

func _get_dirt_yield() -> float:
	return 0.55 + 0.18 * _get_upgrade_level("dirt_compressor")

func _get_launch_boost_span() -> float:
	return 35.0 + 28.0 * _get_upgrade_level("launch_thrusters") + 35.0 * _get_upgrade_level("start_boost")

func _get_launch_speed_mult() -> float:
	var mult := 1.0 + 0.22 * _get_upgrade_level("launch_thrusters") + 0.32 * _get_upgrade_level("start_boost")
	if _has_upgrade("teleport_core"):
		mult += 5.5
	return mult

func _get_punch_damage() -> float:
	return 15.0 + 8.0 * _get_upgrade_level("punch_damage")

func _get_weapon_damage(weapon_id: String) -> float:
	var def: Dictionary = weapon_defs[weapon_id]
	var stat_key := String(def["damage_upgrade"])
	return float(def["damage"]) + float(def["scale"]) * _get_upgrade_level(stat_key)

func _get_weapon_reload(weapon_id: String) -> float:
	var def: Dictionary = weapon_defs[weapon_id]
	var level := _get_upgrade_level(String(def["reload_upgrade"]))
	return max(0.18, float(def["reload"]) - float(def["reload_scale"]) * level)

func _get_active_weapon_id() -> String:
	var equipped := _get_equipped_weapons()
	if equipped.is_empty():
		return ""
	active_weapon_slot = clampi(active_weapon_slot, 0, equipped.size() - 1)
	return String(equipped[active_weapon_slot])

func _get_equipped_weapons() -> Array[String]:
	var equipped_any: Array = persistent_data.get("equipped", ["pistol", ""])
	var equipped: Array[String] = []
	for weapon_id_any in equipped_any:
		var weapon_id := String(weapon_id_any)
		if weapon_id.is_empty():
			continue
		if not weapon_defs.has(weapon_id):
			continue
		if not _is_weapon_unlocked(weapon_id):
			continue
		equipped.append(weapon_id)
	if equipped.is_empty():
		equipped.append("pistol")
	return equipped

func _get_unlocked_weapons() -> Array[String]:
	var weapons: Array[String] = ["pistol"]
	if _has_upgrade("shotgun_unlock"):
		weapons.append("shotgun")
	if _has_upgrade("rifle_unlock"):
		weapons.append("rifle")
	if _has_upgrade("railgun_unlock"):
		weapons.append("railgun")
	return weapons

func _is_weapon_unlocked(weapon_id: String) -> bool:
	match weapon_id:
		"pistol":
			return true
		"shotgun":
			return _has_upgrade("shotgun_unlock")
		"rifle":
			return _has_upgrade("rifle_unlock")
		"railgun":
			return _has_upgrade("railgun_unlock")
	return false

func _both_weapons_reloading() -> bool:
	var equipped := _get_equipped_weapons()
	if equipped.size() < 2:
		return false
	for weapon_id in equipped:
		if not bool(weapon_runtime.get(weapon_id, {}).get("reloading", false)):
			return false
	return true

func _init_weapon_runtime() -> void:
	for weapon_id in _get_equipped_weapons():
		weapon_runtime[weapon_id] = {
			"ammo": int(weapon_defs[weapon_id]["mag"]),
			"reloading": false,
			"reload_timer": 0.0
		}

func _find_next_alive_pylon_index(pylons: Array) -> int:
	for i in range(pylons.size()):
		if bool(pylons[i].get("alive", true)):
			return i
	return 0

func _all_boss_pylons_down() -> bool:
	for pylon in boss_state.get("pylons", []):
		if bool(pylon.get("alive", true)):
			return false
	return true

func _get_checkpoint_cost(checkpoint: int) -> int:
	var tier: int = max(1, int(checkpoint / BOSS_INTERVAL_METERS))
	return int(round(90.0 + 68.0 * pow(float(tier), 1.35)))

func _get_owned_checkpoint_summary() -> String:
	var owned := PackedStringArray(["0m"])
	for checkpoint_key in persistent_data["checkpoint_owned"].keys():
		owned.append("%sm" % checkpoint_key)
	return ", ".join(owned)

func _has_upgrade(upgrade_id: String) -> bool:
	return _get_upgrade_level(upgrade_id) > 0

func _try_auto_equip_weapon(weapon_id: String) -> void:
	var equipped: Array = persistent_data.get("equipped", ["pistol", ""])
	if String(equipped[1]).is_empty():
		equipped[1] = weapon_id
	elif String(equipped[0]) == "pistol" and String(equipped[1]) == "shotgun" and weapon_id == "rifle":
		equipped[1] = weapon_id
	persistent_data["equipped"] = equipped

func _pick_mineral_for_depth(depth_value: float) -> String:
	var depth_factor := depth_value / 100.0
	var rare_bonus := 0.03 * _get_upgrade_level("ore_scanner")
	if depth_factor > 5.0 and rng.randf() < 0.14 + rare_bonus:
		return "plasma"
	if depth_factor > 3.0 and rng.randf() < 0.21 + rare_bonus:
		return "gold"
	if depth_factor > 1.5 and rng.randf() < 0.28 + rare_bonus:
		return "silver"
	if rng.randf() < 0.46 + rare_bonus:
		return "copper"
	return "dirt"

func _auto_scoop_launch_ores(delta: float) -> void:
	for i in range(world_nodes.size() - 1, -1, -1):
		var node: Dictionary = world_nodes[i]
		if absf(node["pos"].x - player_pos.x) > 85.0:
			continue
		if node["pos"].y > current_depth + 30.0:
			continue
		if String(node["type"]) == "hazard":
			world_nodes.remove_at(i)
			continue
		node["hp"] = float(node["hp"]) - _get_drill_power() * delta * 5.0
		world_nodes[i] = node
		if float(node["hp"]) <= 0.0:
			_collect_world_node(i, String(node["type"]))

func _world_to_screen(world_pos: Vector2) -> Vector2:
	return Vector2(get_viewport_rect().size.x * 0.5 + world_pos.x, _depth_to_screen_y(world_pos.y))

func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return Vector2(screen_pos.x - get_viewport_rect().size.x * 0.5, camera_depth + (screen_pos.y - get_viewport_rect().size.y * 0.35))

func _depth_to_screen_y(depth_value: float) -> float:
	return get_viewport_rect().size.y * 0.35 + (depth_value - camera_depth)

func _get_weapon_origin() -> Vector2:
	if run_phase == "refining":
		return _get_surface_turret_position()
	return _world_to_screen(player_pos)

func _get_surface_turret_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(viewport_size.x * 0.5 + 24.0, viewport_size.y * 0.8)

func _get_aim_direction(origin_screen: Vector2) -> Vector2:
	var mouse := get_viewport().get_mouse_position()
	var dir := (mouse - origin_screen).normalized()
	return Vector2.RIGHT if dir == Vector2.ZERO else dir

func _setup_defs() -> void:
	mineral_defs = {
		"dirt": {"label": "Dirt", "radius": 18.0, "hp": 10.0, "yield": 5.0, "cash_value": 1.0, "hardness": 0.8, "color": Color(0.52, 0.38, 0.24, 1.0)},
		"copper": {"label": "Copper", "radius": 20.0, "hp": 18.0, "yield": 10.0, "cash_value": 2.0, "hardness": 1.05, "color": Color(0.85, 0.5, 0.28, 1.0)},
		"silver": {"label": "Silver", "radius": 22.0, "hp": 28.0, "yield": 16.0, "cash_value": 4.0, "hardness": 1.2, "color": Color(0.81, 0.84, 0.9, 1.0)},
		"gold": {"label": "Gold", "radius": 24.0, "hp": 40.0, "yield": 26.0, "cash_value": 7.0, "hardness": 1.4, "color": Color(0.94, 0.82, 0.24, 1.0)},
		"plasma": {"label": "Plasma Core", "radius": 26.0, "hp": 62.0, "yield": 38.0, "cash_value": 11.0, "hardness": 1.7, "color": Color(0.42, 0.96, 0.9, 1.0), "radius_bonus": 4.0},
		"hazard": {"label": "Hazard", "radius": 17.0, "hp": 12.0, "yield": 0.0, "cash_value": 0.0, "hardness": 1.0, "color": HAZARD_COLOR}
	}
	weapon_defs = {
		"pistol": {"label": "Pistol", "damage": 18.0, "scale": 5.0, "reload": 0.95, "reload_scale": 0.08, "mag": 8, "speed": 920.0, "life": 1.2, "radius": 4.0, "pellets": 1, "spread": 0.0, "damage_upgrade": "pistol_damage", "reload_upgrade": "pistol_reload", "color": SHOT_COLOR},
		"shotgun": {"label": "Scattergun", "damage": 36.0, "scale": 8.0, "reload": 1.45, "reload_scale": 0.1, "mag": 2, "speed": 780.0, "life": 0.75, "radius": 4.0, "pellets": 6, "spread": 0.34, "damage_upgrade": "shotgun_damage", "reload_upgrade": "shotgun_reload", "color": Color(1.0, 0.8, 0.52, 1.0)},
		"rifle": {"label": "Burst Rifle", "damage": 22.0, "scale": 6.5, "reload": 1.15, "reload_scale": 0.08, "mag": 12, "speed": 1040.0, "life": 1.0, "radius": 4.0, "pellets": 1, "spread": 0.03, "damage_upgrade": "rifle_damage", "reload_upgrade": "rifle_reload", "color": Color(0.72, 0.92, 1.0, 1.0)},
		"railgun": {"label": "Railgun", "damage": 95.0, "scale": 16.0, "reload": 1.85, "reload_scale": 0.12, "mag": 1, "speed": 1320.0, "life": 0.9, "radius": 6.0, "pellets": 1, "spread": 0.0, "damage_upgrade": "railgun_damage", "reload_upgrade": "railgun_reload", "color": Color(0.55, 1.0, 0.9, 1.0)}
	}
	upgrade_catalog = MINING_PROGRESS_SCRIPT.get_upgrade_catalog()

func _load_progress() -> void:
	persistent_data = MINING_PROGRESS_SCRIPT.load_data()

func _save_progress() -> void:
	MINING_PROGRESS_SCRIPT.save_data(persistent_data)
