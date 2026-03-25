extends Node2D
class_name MiningMain

const MINING_PROGRESS_SCRIPT = preload("res://Games/Mining/MiningProgress.gd")
const MINING_BALANCE = preload("res://Games/Mining/MiningBalance.gd")
const MINING_CRT_OVERLAY_SCRIPT = preload("res://Games/Mining/UI/MiningCrtOverlay.gd")
const SETTINGS_SCENE: PackedScene = preload("res://Settings.tscn")

const WORLD_SIZE := Vector2(1650.0, 1950.0)
const BASE_RADIUS := 84.0
const PLAYER_RADIUS := 18.0
const DRILL_RANGE := 118.0
const NODE_RADIUS_MIN := 18.0
const NODE_RADIUS_MAX := 34.0
const MAX_WORLD_NODES := 96
const DRONE_DELIVERY_INTERVAL := 7.0
const DRONE_DELIVERY_SPEED := 420.0
const PICKUP_DRONE_SPEED := 330.0
const PICKUP_DRONE_GRAB_RANGE := 16.0
const CONTACT_DRILL_PADDING := 10.0
const DRILL_AUDIO_INTERVAL := 0.3
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
const TUNNEL_SPEED_BONUS_MIN := 0.14
const TUNNEL_SPEED_BONUS_MAX := 0.46
const TUNNEL_BOOST_COVERAGE_THRESHOLD := 0.5
const TUNNEL_CLEAR_ALPHA_THRESHOLD := 0.12
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
    "Build speed through cleared tunnels before committing to a seam. Straight runs give the drill its best burst damage.",
    "Banking at the surface is safest when your cargo is full or your drill is close to breaking. Unbanked ore is a bad gamble.",
    "Salvage drones are best when you want to stay glued to rich nodes instead of weaving around for loose drops.",
    "Delivery drones shine once cargo upgrades are online. They keep rich runs flowing while you stay in the field.",
    "Depth Scanner unlocks harder layers, while Seismic Sonar helps those layers actually pay out with richer veins."
]

enum RUN_STATES {RUNNING, SUMMARY}

@onready var top_bar: MarginContainer = $CanvasLayer/TopBar
@onready var wallet_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/WalletLabel
@onready var phase_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/PhaseLabel
@onready var depth_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/DepthLabel
@onready var time_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/TimeRow/TimeValueLabel
@onready var time_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/TimeRow/TimeBar
@onready var drill_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/DrillRow/DrillValueLabel
@onready var drill_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/DrillRow/DrillBar
@onready var hull_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/HullRow/HullValueLabel
@onready var hull_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/HullRow/HullBar
@onready var cargo_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/CargoRow/CargoValueLabel
@onready var cargo_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/CargoRow/CargoBar
@onready var xp_value_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/XpRow/XpValueLabel
@onready var xp_bar: ProgressBar = $CanvasLayer/TopBar/TopPanel/TopInfo/XpRow/XpBar
@onready var weapon_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/WeaponLabel
@onready var boss_label: Label = $CanvasLayer/TopBar/TopPanel/TopInfo/BossLabel
@onready var top_panel: PanelContainer = $CanvasLayer/TopBar/TopPanel
@onready var shop_panel: PanelContainer = $CanvasLayer/ShopPanel
@onready var summary_label: Label = $CanvasLayer/ShopPanel/ShopMargin/ShopVBox/SummaryBody/SummaryLeftColumn/SummaryLabel
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
var hull_health := 100.0
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
var delivery_drone_visuals: Array[Dictionary] = []
var pickup_drone_visuals: Array[Dictionary] = []
var next_pickup_uid := 1
var attached_node_id := -1
var attached_contact_point := Vector2.ZERO
var attached_push_direction := Vector2.DOWN
var dirt_image: Image
var dirt_texture: ImageTexture
var mute_button: Button
var fullscreen_button: Button
var settings_button: Button
var settings_panel: PanelContainer
var settings_content: Settings
var speaker_icon_on: ImageTexture
var speaker_icon_off: ImageTexture
var fullscreen_icon_on: ImageTexture
var fullscreen_icon_off: ImageTexture
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

func _ready() -> void:
    Global.game_state = Util.GAME_STATES.PLAYING
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
    _configure_summary_panel()
    dive_button.pressed.connect(_on_summary_return_pressed)
    reset_button.pressed.connect(_on_summary_retry_pressed)
    hint_left_button.pressed.connect(_on_summary_hint_left_button_pressed)
    hint_right_button.pressed.connect(_on_summary_hint_right_button_pressed)
    _ensure_crt_overlay()
    _begin_run()

func _exit_tree() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
    if run_state == RUN_STATES.RUNNING and not _is_settings_open():
        _update_autoplay_pointer()
        _process_running(delta)
    _refresh_hud()
    if not simulation_mode_active:
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
    if event.is_action_pressed("toggle_mute"):
        _on_mute_button_pressed()
        get_viewport().set_input_as_handled()
        return
    if event.is_action_pressed("back") or event.is_action_pressed("escape"):
        _toggle_settings_panel()
        get_viewport().set_input_as_handled()
        return
    if run_state != RUN_STATES.RUNNING:
        return

func _draw() -> void:
    var viewport_size := get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.07, 0.08, 0.1, 1.0), true)
    var origin := viewport_size * 0.5 - camera_pos
    var world_rect := Rect2(origin - WORLD_SIZE * 0.5, WORLD_SIZE)
    draw_rect(world_rect, _get_level_bg_color(), true)
    if dirt_texture != null:
        draw_texture_rect(dirt_texture, world_rect, false)
    _draw_base(origin)
    _draw_nodes(origin)
    _draw_pickups(origin)
    _draw_tail()
    _draw_player(origin)
    _draw_target_line(origin)
    _draw_edge_fade(viewport_size)
    _draw_aim_cursor()

func _begin_run() -> void:
    persistent_data = simulation_data_override.duplicate(true) if not simulation_data_override.is_empty() else MINING_PROGRESS_SCRIPT.load_data()
    var selected_depth: int = int(persistent_data.get("selected_depth_level", 1))
    if simulation_depth_override > 0:
        selected_depth = simulation_depth_override
    active_depth_level = clampi(selected_depth, 1, int(persistent_data.get("deepest_level_unlocked", 1)))
    active_material = material_tiers[active_depth_level - 1]
    player_pos = Vector2(0.0, -WORLD_SIZE.y * 0.5 + 120.0)
    camera_pos = player_pos
    time_left = _get_run_time_limit()
    drill_health = _get_drill_health_max()
    hull_health = 100.0
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
    trail_history.clear()
    drill_copies.clear()
    delivery_drone_visuals.clear()
    pickup_drone_visuals.clear()
    next_pickup_uid = 1
    attached_node_id = -1
    attached_contact_point = player_pos
    attached_push_direction = Vector2.DOWN
    drone_delivery_timer = _get_delivery_dispatch_window()
    run_status = "Mine nodes, scoop the drops, and bank cargo at the surface rig."
    run_state = RUN_STATES.RUNNING
    Global.game_state = Util.GAME_STATES.PLAYING
    _generate_world()
    _initialize_dirt_mask()
    _carve_dirt_circle(_get_base_position(), 92.0)
    shop_panel.hide()
    hint_panel.hide()
    hint_label.text = ""
    _reset_aim_cursor()
    _reset_drill_train()
    _refresh_mouse_capture_state()

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
        _finish_run("Simulation step cap reached.")
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
    _process_drilling(delta)
    _process_pickup_drones(delta)
    _collect_pickups(delta)
    _bank_cargo_if_at_base()
    _process_delivery_drone(delta)
    _process_delivery_drone_visuals(delta)
    _process_contact_sparks(delta)
    _process_damage_numbers(delta)
    drill_audio_timer = max(0.0, drill_audio_timer - delta)
    camera_shake_strength = max(0.0, camera_shake_strength - delta * 18.0)
    camera_pos = camera_pos.lerp(player_pos + _get_camera_shake_offset(), min(1.0, delta * 7.0))
    _update_system_button_layout()
    if time_left <= 0.0:
        _finish_run("Timer expired.")
    elif drill_health <= 0.0:
        _finish_run("Drill health depleted.")

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
    candidate.x = clampf(candidate.x, -WORLD_SIZE.x * 0.5 + PLAYER_RADIUS, WORLD_SIZE.x * 0.5 - PLAYER_RADIUS)
    candidate.y = clampf(candidate.y, -WORLD_SIZE.y * 0.5 + PLAYER_RADIUS, WORLD_SIZE.y * 0.5 - PLAYER_RADIUS)
    var collision_index: int = _get_collision_node_index(candidate)
    if collision_index == -1:
        player_pos = candidate
        _carve_dirt_segment(previous_pos, player_pos, 28.0)
        _update_drill_train(previous_pos, delta)
        return
    contact_node_id = collision_index
    var node: Dictionary = world_nodes[collision_index]
    if _apply_impact_hit(collision_index, candidate):
        player_pos = candidate
        player_pos.x = clampf(player_pos.x, -WORLD_SIZE.x * 0.5 + PLAYER_RADIUS, WORLD_SIZE.x * 0.5 - PLAYER_RADIUS)
        player_pos.y = clampf(player_pos.y, -WORLD_SIZE.y * 0.5 + PLAYER_RADIUS, WORLD_SIZE.y * 0.5 - PLAYER_RADIUS)
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
    player_pos.x = clampf(player_pos.x, -WORLD_SIZE.x * 0.5 + PLAYER_RADIUS, WORLD_SIZE.x * 0.5 - PLAYER_RADIUS)
    player_pos.y = clampf(player_pos.y, -WORLD_SIZE.y * 0.5 + PLAYER_RADIUS, WORLD_SIZE.y * 0.5 - PLAYER_RADIUS)
    _carve_dirt_segment(previous_pos, player_pos, 28.0)
    _update_drill_train(previous_pos, delta)

func _process_drilling(delta: float) -> void:
    target_node_id = _get_contact_drill_node_index()
    if target_node_id == -1 or move_input_strength <= 0.0:
        return
    var node: Dictionary = world_nodes[target_node_id]
    var drill_damage: float = _get_drill_dps() * (1.95 + move_input_strength * 2.55 + straight_drive_charge * 0.42) * delta
    node["health"] = max(0.0, float(node.get("health", 0.0)) - drill_damage)
    world_nodes[target_node_id] = node
    drill_health = max(0.0, drill_health - _get_drill_wear(node) * (0.55 + move_input_strength * 0.45 + straight_drive_charge * 0.08) * delta)
    var hit_pos: Vector2 = player_pos.lerp(node.get("pos", player_pos), 0.45)
    pending_drill_damage_number += drill_damage
    pending_drill_damage_origin = hit_pos
    _spawn_contact_sparks(player_pos.lerp(node.get("pos", player_pos), 0.45), node.get("material_color", Color.WHITE), 2)
    camera_shake_strength = min(8.0, camera_shake_strength + 1.8 * delta * 60.0)
    _play_drill_tick(hit_pos)
    run_status = "Drilling %s..." % String(node.get("material_name", "node"))
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
        pickup["pos"] = pickup_pos
        pickup["vel"] = pickup_vel
        var can_collect: bool = player_pos.distance_to(pickup_pos) <= collect_radius
        if can_collect and cargo_used < _get_cargo_capacity():
            var material_id: String = String(pickup.get("material_id", ""))
            carry_counts[material_id] = int(carry_counts.get(material_id, 0)) + 1
            cargo_used += 1
            player_pickups_collected += 1
            run_status = "Scooped %s." % String(pickup.get("material_name", "loot"))
            continue
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
    run_status = "Cargo dropped off at the surface rig."

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
    var items_per_dispatch: int = MINING_BALANCE.get_delivery_items_per_dispatch(_get_upgrade_levels())
    while dispatched < available_dispatches and cargo_used > 0:
        var dispatched_material_id := ""
        var cargo_count := 0
        for item_index in range(items_per_dispatch):
            var delivered_material_id: String = _take_one_cargo_for_delivery()
            if delivered_material_id == "":
                break
            if dispatched_material_id == "":
                dispatched_material_id = delivered_material_id
            cargo_count += 1
        if dispatched_material_id == "":
            break
        _spawn_delivery_drone_visual(dispatched_material_id, _get_material_by_id(dispatched_material_id), cargo_count)
        dispatched += 1
    if dispatched > 0:
        run_status = "Dump drone hauling cargo back to the surface rig."

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
            if target_pickup.is_empty() or cargo_used >= _get_cargo_capacity():
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
                if cargo_used < _get_cargo_capacity():
                    var carry_material_id: String = String(drone.get("carry_material_id", ""))
                    carry_counts[carry_material_id] = int(carry_counts.get(carry_material_id, 0)) + 1
                    cargo_used += 1
                    drone_pickups_collected += 1
                    run_status = "Pickup drone hauled in %s." % String(drone.get("carry_material_name", "loot"))
                drone["state"] = "idle"
                drone["carry_material_id"] = ""
                drone["carry_material_name"] = ""
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

func _take_one_cargo_for_delivery() -> String:
    for material_id_variant in carry_counts.keys():
        var material_id: String = String(material_id_variant)
        if int(carry_counts[material_id]) <= 0:
            continue
        carry_counts[material_id] = int(carry_counts[material_id]) - 1
        if int(carry_counts[material_id]) <= 0:
            carry_counts.erase(material_id)
        cargo_used = max(0, cargo_used - 1)
        return material_id
    return ""

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
    var available_tiers: int = min(active_depth_level, material_tiers.size())
    var node_count: int = min(MAX_WORLD_NODES, 28 + active_depth_level * 6)
    var safety_center: Vector2 = _get_base_position()
    for node_index in range(node_count):
        var material: Dictionary = _roll_material_for_level(available_tiers)
        var health: float = MINING_BALANCE.get_node_health(material, active_depth_level)
        var radius: float = clampf(14.0 + sqrt(health) * 1.9, NODE_RADIUS_MIN, NODE_RADIUS_MAX)
        var pos: Vector2 = Vector2.ZERO
        var attempts: int = 0
        while attempts < 32:
            pos = Vector2(
                rng.randf_range(-WORLD_SIZE.x * 0.47, WORLD_SIZE.x * 0.47),
                rng.randf_range(-WORLD_SIZE.y * 0.36, WORLD_SIZE.y * 0.47)
            )
            if pos.distance_to(safety_center) < BASE_RADIUS + 150.0:
                attempts += 1
                continue
            if _node_overlaps_existing(pos, radius + 18.0):
                attempts += 1
                continue
            break
        world_nodes.append({
            "id": node_index,
            "pos": pos,
            "radius": radius,
            "shape_points": _build_rock_shape(radius),
            "health": health,
            "max_health": health,
            "material_id": String(material.get("id", "stone")),
            "material_name": String(material.get("name", "Stone")),
            "material_color": material.get("color", Color(0.5, 0.5, 0.5, 1.0)),
            "value": int(material.get("value", 1)),
            "xp": int(material.get("xp", 3)),
            "sparkle": float(material.get("sparkle", 0.0))
        })

func _node_overlaps_existing(pos: Vector2, radius: float) -> bool:
    for node in world_nodes:
        if pos.distance_to(node.get("pos", Vector2.ZERO)) < radius + float(node.get("radius", 0.0)):
            return true
    return false

func _roll_material_for_level(available_tiers: int) -> Dictionary:
    if available_tiers <= 1:
        return material_tiers[0]
    var weights: Array[float] = MINING_BALANCE.get_material_weights(available_tiers, _get_upgrade_levels())
    var total_weight: float = 0.0
    for weight in weights:
        total_weight += float(weight)
    var roll: float = rng.randf() * total_weight
    for index in range(available_tiers):
        roll -= weights[index]
        if roll <= 0.0:
            return material_tiers[index]
    return material_tiers[available_tiers - 1]

func _break_node(node_index: int) -> void:
    var node: Dictionary = world_nodes[node_index]
    world_nodes.remove_at(node_index)
    _handle_removed_node_index(node_index)
    nodes_broken += 1
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
            "claimed_by": -1
        })
        next_pickup_uid += 1
        total_pickups_spawned += 1
    _spawn_damage_number(node.get("pos", Vector2.ZERO), int(round(float(node.get("max_health", 0.0)))), true)
    _spawn_contact_sparks(node.get("pos", Vector2.ZERO), node.get("material_color", Color.WHITE), 10)
    camera_shake_strength = max(camera_shake_strength, 10.0)
    _carve_dirt_circle(node.get("pos", Vector2.ZERO), float(node.get("radius", 24.0)) + 16.0)
    run_status = "%s vein cracked open. Grab the drops." % String(node.get("material_name", "Stone"))

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

func _build_run_results(reason: String) -> Dictionary:
    var money_breakdown: Array[String] = []
    var money_breakdown_chart: Array[Dictionary] = []
    var total_money: int = 0
    for material_id_variant in banked_counts.keys():
        var material_id: String = String(material_id_variant)
        var count: int = int(banked_counts[material_id])
        var material: Dictionary = _get_material_by_id(material_id)
        var value_each: int = int(round(int(material.get("value", 1)) * _get_value_multiplier()))
        var subtotal: int = count * value_each
        total_money += subtotal
        money_breakdown.append("%s x%d -> $%d" % [String(material.get("name", material_id)), count, subtotal])
        money_breakdown_chart.append({
            "material_id": material_id,
            "label": String(material.get("name", material_id)),
            "count": count,
            "money": subtotal,
            "color": material.get("color", Color.WHITE)
        })

    var before_level: int = int(persistent_data.get("player_level", 1))
    var projected_xp: int = int(persistent_data.get("xp", 0)) + run_xp
    var projected_level: int = MINING_PROGRESS_SCRIPT.get_level_for_total_xp(projected_xp)
    var projected_depth_unlock: int = min(
        MINING_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL,
        1 + projected_level - 1 + _get_upgrade_level("depth_scanner")
    )
    var projected_level_data: Dictionary = {
        "player_level": projected_level,
        "xp": projected_xp
    }
    var level_progress: Dictionary = MINING_PROGRESS_SCRIPT.get_level_progress(projected_level_data)
    var level_gain: int = projected_level - before_level
    var projected_data: Dictionary = persistent_data.duplicate(true)
    projected_data["wallet"] = max(0, int(projected_data.get("wallet", 0)) + total_money)
    projected_data["xp"] = projected_xp
    projected_data["player_level"] = projected_level
    projected_data["last_run_summary"] = ""
    projected_data["last_run_breakdown"] = {}
    projected_data["deepest_level_unlocked"] = max(int(projected_data.get("deepest_level_unlocked", 1)), active_depth_level)
    MINING_BALANCE.refresh_depth_unlocks(projected_data)
    projected_depth_unlock = int(projected_data.get("deepest_level_unlocked", projected_depth_unlock))
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
    var summary_text: String = "Run complete: %s\n\nDepth tier %d: %s\nNodes broken: %d\nXP earned: %d%s\nMoney earned: $%d\n\nCargo payout:\n%s\n\nLevel %d  XP %d/%d\nUnlocked depth tier: %d" % [
        reason,
        active_depth_level,
        String(active_material.get("name", "Stone")),
        nodes_broken,
        run_xp,
        "  (LEVEL UP!)" if level_gain > 0 else "",
        total_money,
        "No cargo banked." if money_breakdown.is_empty() else "\n".join(money_breakdown),
        projected_level,
        int(level_progress.get("current_xp", 0)),
        int(level_progress.get("next_level_xp", 1)),
        projected_depth_unlock
    ]
    return {
        "money": total_money,
        "xp": run_xp,
        "depth_level": active_depth_level,
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
        "reason": reason,
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

func _finish_run(reason: String) -> void:
    if run_state == RUN_STATES.SUMMARY:
        return
    _bank_cargo_if_at_base()
    _bank_pending_delivery_drone_visuals()
    for material_id_variant in carry_counts.keys():
        var material_id: String = String(material_id_variant)
        banked_counts[material_id] = int(banked_counts.get(material_id, 0)) + int(carry_counts[material_id])
    carry_counts.clear()
    cargo_used = 0

    var results: Dictionary = _build_run_results(reason)
    last_run_results = results.duplicate(true)
    if simulation_commit_progress:
        persistent_data = MINING_PROGRESS_SCRIPT.apply_run_results(results)
    else:
        persistent_data = results.get("projected_data", persistent_data).duplicate(true)
    run_state = RUN_STATES.SUMMARY
    Global.game_state = Util.GAME_STATES.UPGRADES if simulation_commit_progress else Util.GAME_STATES.PLAYING
    run_status = reason
    _refresh_mouse_capture_state()
    if simulation_commit_progress and not simulation_mode_active:
        _show_summary(results)

func _show_summary(results: Dictionary) -> void:
    summary_label.text = str(results.get("summary_text", "Run complete."))
    summary_stats_label.text = str(results.get("summary_stats_text", ""))
    dive_button.text = "Return To Upgrades"
    reset_button.text = "Run Again"
    _setup_summary_hints(results)
    _refresh_summary_hint()
    _refresh_summary_charts(results)
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
    shop_panel.custom_minimum_size = Vector2(1380.0, 860.0)
    shop_panel.offset_left = -690.0
    shop_panel.offset_top = -470.0
    shop_panel.offset_right = 690.0
    shop_panel.offset_bottom = 390.0
    checkpoint_header.hide()
    checkpoint_list.hide()
    loadout_header.hide()
    loadout_list.hide()
    upgrade_header.hide()
    upgrade_scroll.hide()
    summary_label.add_theme_font_size_override("font_size", 26)
    summary_stats_label.add_theme_font_size_override("font_size", 22)
    dive_button.add_theme_font_size_override("font_size", 30)
    reset_button.add_theme_font_size_override("font_size", 30)
    _style_utility_button(dive_button)
    _style_utility_button(reset_button)

func _refresh_hud() -> void:
    var projected_xp: int = int(persistent_data.get("xp", 0)) + run_xp
    var projected_level: int = MINING_PROGRESS_SCRIPT.get_level_for_total_xp(projected_xp)
    var level_progress: Dictionary = MINING_PROGRESS_SCRIPT.get_level_progress({
        "player_level": projected_level,
        "xp": projected_xp
    })
    var run_time_limit: float = _get_run_time_limit()
    var drill_health_max: float = _get_drill_health_max()
    var cargo_capacity: int = _get_cargo_capacity()
    var xp_current: int = int(level_progress.get("current_xp", 0))
    var xp_next: int = max(1, int(level_progress.get("next_level_xp", 1)))
    wallet_label.text = "Wallet: $%s" % Util.get_number_short_text(int(persistent_data.get("wallet", 0)))
    phase_label.text = "Depth Tier %d/%d: %s" % [active_depth_level, MINING_PROGRESS_SCRIPT.MAX_DEPTH_LEVEL, String(active_material.get("name", "Stone"))]
    depth_label.text = "Unlocked Depth: %d   Current XP Level: %d" % [int(persistent_data.get("deepest_level_unlocked", 1)), int(level_progress.get("current_level", 1))]
    time_value_label.text = "Timer %.1fs / %.1fs" % [time_left, run_time_limit]
    time_bar.max_value = run_time_limit
    time_bar.value = time_left
    drill_value_label.text = "Drill Integrity %.0f / %.0f" % [drill_health, drill_health_max]
    drill_bar.max_value = drill_health_max
    drill_bar.value = drill_health
    hull_value_label.text = "Hull %.0f / 100" % [hull_health]
    hull_bar.max_value = 100.0
    hull_bar.value = hull_health
    cargo_value_label.text = "Cargo %d / %d   Banked %d" % [cargo_used, cargo_capacity, _get_total_banked_count()]
    cargo_bar.max_value = cargo_capacity
    cargo_bar.value = cargo_used
    xp_value_label.text = "XP %d / %d   Run XP +%d" % [xp_current, xp_next, run_xp]
    xp_bar.max_value = xp_next
    xp_bar.value = xp_current
    weapon_label.text = "Rig Stats   Move %.0f   Drill %.0f/s   Pickup %.0f   Charge +%d%%   XP Boost +%d%%" % [_get_move_speed(), _get_drill_dps(), _get_pickup_radius(), int(round((_get_straight_drive_speed_multiplier() - 1.0) * 100.0)), int(round((_get_xp_multiplier() - 1.0) * 100.0))]
    boss_label.text = "Status   %s" % run_status

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
    _style_meter(hull_bar, Color(0.86, 0.31, 0.33, 0.96))
    _style_meter(cargo_bar, Color(0.8, 0.57, 0.22, 0.96))
    _style_meter(xp_bar, Color(0.37, 0.82, 0.67, 0.96))
    _style_hud_label(wallet_label, 26, Color(0.96, 0.98, 1.0, 1.0))
    _style_hud_label(phase_label, 34, Color(1.0, 0.87, 0.48, 1.0))
    _style_hud_label(depth_label, 24, Color(0.83, 0.9, 1.0, 1.0))
    _style_hud_label(time_value_label, 22, Color(1.0, 0.88, 0.56, 1.0))
    _style_hud_label(drill_value_label, 22, Color(0.74, 0.91, 1.0, 1.0))
    _style_hud_label(hull_value_label, 22, Color(1.0, 0.76, 0.76, 1.0))
    _style_hud_label(cargo_value_label, 22, Color(0.97, 0.83, 0.61, 1.0))
    _style_hud_label(xp_value_label, 22, Color(0.76, 1.0, 0.9, 1.0))
    _style_hud_label(weapon_label, 20, Color(0.88, 0.94, 1.0, 0.96))
    _style_hud_label(boss_label, 22, Color(0.98, 0.95, 0.77, 1.0))
    _style_hud_label(hint_label, 20, Color(0.92, 0.96, 1.0, 1.0))
    _style_hud_label(summary_label, 26, Color(0.95, 0.98, 1.0, 1.0))
    _style_hud_label(summary_stats_label, 22, Color(0.9, 0.95, 1.0, 1.0))
    _style_hud_label(hint_title_label, 20, Color(0.76, 0.9, 1.0, 1.0))
    _style_hud_label(summary_hint_label, 22, Color(0.92, 0.96, 1.0, 1.0))
    _style_utility_button(hint_left_button)
    _style_utility_button(hint_right_button)

func _style_hud_label(label: Label, font_size: int, color: Color) -> void:
    if label == null:
        return
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
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
    return "Run time %.1fs   Money/sec $%.1f   XP/sec %.1f   Ore/sec %.2f\nOre spawned %d   Collected %d   Left behind %d   Banked %d\nManual scoops %d   Salvage drone scoops %d   Delivery drone drops %d   Surface banks %d\nCollection rate %d%%   Banking rate %d%%" % [
        float(stats.get("time_spent", 0.0)),
        float(stats.get("money_per_second", 0.0)),
        float(stats.get("xp_per_second", 0.0)),
        float(stats.get("ore_per_second", 0.0)),
        int(stats.get("ore_spawned", 0)),
        int(stats.get("ore_collected", 0)),
        int(stats.get("ore_left_behind", 0)),
        int(stats.get("ore_banked", 0)),
        int(stats.get("player_pickups_collected", 0)),
        int(stats.get("drone_pickups_collected", 0)),
        int(stats.get("delivery_dumps", 0)),
        bank_trips,
        int(round(float(stats.get("collection_rate", 0.0)) * 100.0)),
        int(round(float(stats.get("bank_rate", 0.0)) * 100.0))
    ]

func _setup_summary_hints(results: Dictionary = {}) -> void:
    mining_summary_hints = DEFAULT_MINING_SUMMARY_HINTS.duplicate()
    var contextual_hint: String = _get_contextual_summary_hint(results)
    if not contextual_hint.is_empty():
        mining_summary_hints.erase(contextual_hint)
        mining_summary_hints.push_front(contextual_hint)
    if _get_upgrade_level("pickup_radius") <= 0:
        mining_summary_hints.append("Vacuum Scoop is the fastest way to stop drops from slipping away once a vein bursts open.")
    if _get_upgrade_level("magnet_drone") <= 0:
        mining_summary_hints.append("Salvage Drone is a strong next buy if rich seams are leaving too many chunks behind.")
    if _get_upgrade_level("delivery_drone") <= 0:
        mining_summary_hints.append("Delivery Drone pays off once your cargo is filling before you can safely return to the surface.")
    if mining_summary_hints.is_empty():
        mining_summary_hints.append("Review the run, tune the rig, and go again.")
    mining_summary_hint_index = 0

func _get_contextual_summary_hint(results: Dictionary) -> String:
    if results.is_empty():
        return ""
    var reason: String = String(results.get("reason", ""))
    var ore_left_behind: int = int(results.get("ore_left_behind", 0))
    var ore_spawned: int = int(results.get("ore_spawned", 0))
    var collection_rate: float = float(results.get("collection_rate", 0.0))
    var remaining_nodes: int = int(results.get("remaining_nodes", 0))
    var total_nodes_seen: int = int(results.get("total_nodes_seen", 0))
    var untouched_ratio: float = 0.0 if total_nodes_seen <= 0 else float(remaining_nodes) / float(total_nodes_seen)
    var left_many_pickups: bool = ore_left_behind >= 10 or (ore_spawned >= 12 and collection_rate <= 0.55)
    var left_many_nodes: bool = remaining_nodes >= 28 and untouched_ratio >= 0.72

    if left_many_pickups:
        if _get_upgrade_level("pickup_radius") <= 0:
            return "You left a lot of ore drifting in the dirt that run. Vacuum Scoop will help you clean up popped veins before the loot scatters."
        if _get_upgrade_level("magnet_drone") <= 0:
            return "A lot of ore got left behind that run. Salvage Drone is a strong pickup if you want those loose chunks collected while you keep drilling."
        return "A lot of ore got left behind that run. Try looping back through cracked veins sooner so the loose drops turn into cargo instead of dead weight."

    if left_many_nodes:
        return "There were still a lot of untouched veins on the field when the run ended. A cleaner route through nearby seams can turn that map into much better payout."

    if reason == "Drill health depleted.":
        return "The run ended because your drill wore out. Upgrading drill health will buy you more time on tough veins before the rig gives out."

    if reason == "Timer expired.":
        return "The timer ran out before the route paid off. Upgrading run time will give you more room to finish a lane and bank the haul."

    if reason == "Hull depleted." or reason == "Hull integrity depleted.":
        return "The run ended when the hull gave out. Hull Plating will let you absorb more punishment before you have to call the run."

    return ""

func _refresh_summary_hint() -> void:
    if mining_summary_hints.is_empty():
        hint_title_label.text = ""
        summary_hint_label.text = ""
        hint_left_button.hide()
        hint_right_button.hide()
        return
    mining_summary_hint_index = wrapi(mining_summary_hint_index, 0, mining_summary_hints.size())
    hint_title_label.text = "Hint %d/%d" % [mining_summary_hint_index + 1, mining_summary_hints.size()]
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
    var root := HBoxContainer.new()
    root.custom_minimum_size = Vector2(220.0, 0.0)
    root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_theme_constant_override("separation", 8)

    var meter := ProgressBar.new()
    meter.custom_minimum_size = Vector2(140.0, 18.0)
    meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    meter.show_percentage = false
    meter.max_value = max(1.0, max_value)
    meter.value = value

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
    root.add_child(_make_summary_chart_label(_format_summary_chart_value(value), 58.0, 16, HORIZONTAL_ALIGNMENT_RIGHT, Color(0.82, 0.9, 1.0, 1.0)))
    return root

func _format_summary_chart_value(value: float) -> String:
    if value >= 1000.0:
        return "%0.1fk" % (value / 1000.0)
    if value >= 100.0:
        return str(int(round(value)))
    return "%0.1f" % value if value != floor(value) else str(int(value))

func _refresh_summary_charts(results: Dictionary) -> void:
    _refresh_money_chart(results)
    _refresh_performance_chart(results)

func _refresh_money_chart(results: Dictionary) -> void:
    _clear_control_children(money_chart)
    var margin := _make_chart_margin(money_chart)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 10)
    margin.add_child(root)
    root.add_child(_make_summary_chart_label("Money by mineral", 0.0, 24, HORIZONTAL_ALIGNMENT_CENTER))

    var rows: Array = results.get("money_breakdown_chart", [])
    if rows.is_empty():
        root.add_child(_make_summary_chart_label("No banked cargo this run.", 0.0, 18, HORIZONTAL_ALIGNMENT_CENTER, Color(0.82, 0.88, 0.96, 0.92)))
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
        row.add_child(_make_summary_chart_label("%s x%d" % [str(row_data.get("label", "Ore")), int(row_data.get("count", 0))], 170.0, 17))
        row.add_child(_make_summary_chart_bar(float(row_data.get("money", 0.0)), max_money, row_data.get("color", Color(0.8, 0.8, 0.8, 1.0))))

func _refresh_performance_chart(results: Dictionary) -> void:
    _clear_control_children(performance_chart)
    var margin := _make_chart_margin(performance_chart)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 10)
    margin.add_child(root)
    root.add_child(_make_summary_chart_label("Ore flow and performance", 0.0, 24, HORIZONTAL_ALIGNMENT_CENTER))

    var rows: Array[Dictionary] = [
        {"label": "Ore collected", "value": float(results.get("ore_collected", 0)), "color": Color(0.45, 0.87, 0.99, 1.0)},
        {"label": "Left behind", "value": float(results.get("ore_left_behind", 0)), "color": Color(0.93, 0.38, 0.35, 1.0)},
        {"label": "Collected by drones", "value": float(results.get("drone_pickups_collected", 0)), "color": Color(0.56, 0.92, 0.65, 1.0)},
        {"label": "Delivered by drones", "value": float(results.get("delivery_dumps", 0)), "color": Color(1.0, 0.77, 0.31, 1.0)},
        {"label": "Nodes broken", "value": float(results.get("nodes_broken", 0)), "color": Color(0.83, 0.74, 1.0, 1.0)}
    ]
    var max_value: float = 0.0
    for row_data in rows:
        max_value = max(max_value, float(row_data.get("value", 0.0)))
    for row_data in rows:
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 10)
        root.add_child(row)
        row.add_child(_make_summary_chart_label(str(row_data.get("label", "")), 190.0, 17))
        row.add_child(_make_summary_chart_bar(float(row_data.get("value", 0.0)), max_value, row_data.get("color", Color.WHITE)))

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

func _get_upgrade_levels() -> Dictionary:
    return persistent_data.get("upgrades", {})

func _get_move_speed() -> float:
    return MINING_BALANCE.get_move_speed(_get_upgrade_levels())

func _get_dirt_drag_multiplier() -> float:
    return MINING_BALANCE.get_dirt_drag_multiplier(active_depth_level, _get_upgrade_levels())

func _get_drill_dps() -> float:
    return MINING_BALANCE.get_drill_dps(_get_upgrade_levels())

func _get_drill_health_max() -> float:
    return MINING_BALANCE.get_drill_health_max(_get_upgrade_levels())

func _get_run_time_limit() -> float:
    return MINING_BALANCE.get_run_time_limit(_get_upgrade_levels())

func _get_time_drain_rate() -> float:
    return MINING_BALANCE.get_time_drain_rate(active_depth_level, _get_upgrade_levels())

func _get_cargo_capacity() -> int:
    return MINING_BALANCE.get_cargo_capacity(_get_upgrade_levels())

func _get_value_multiplier() -> float:
    return MINING_BALANCE.get_value_multiplier(_get_upgrade_levels())

func _get_xp_multiplier() -> float:
    return MINING_BALANCE.get_xp_multiplier(_get_upgrade_levels())

func _get_pickup_radius() -> float:
    return MINING_BALANCE.get_pickup_radius(_get_upgrade_levels())

func _get_drill_wear(node: Dictionary) -> float:
    return MINING_BALANCE.get_node_wear_per_second(node, _get_upgrade_levels())

func _get_pickup_drone_speed() -> float:
    return MINING_BALANCE.get_pickup_drone_speed(_get_upgrade_levels())

func _get_delivery_drone_speed() -> float:
    return MINING_BALANCE.get_delivery_drone_speed(_get_upgrade_levels())

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
    var speed_ratio: float = clampf(player_velocity.length() / max(_get_move_speed(), 1.0), 0.0, 2.0)
    var charge_ratio: float = clampf(straight_drive_charge / STRAIGHT_DRIVE_CHARGE_MAX, 0.0, 1.0)
    var impact_damage: float = _get_drill_dps() * (0.68 + speed_ratio * 0.9 + charge_ratio * 4.35)
    if impact_damage <= 0.0:
        return false
    node["health"] = max(0.0, float(node.get("health", 0.0)) - impact_damage)
    world_nodes[node_index] = node
    drill_health = max(0.0, drill_health - _get_drill_wear(node) * (0.1 + charge_ratio * 0.17))
    var hit_pos: Vector2 = candidate_pos.lerp(node.get("pos", candidate_pos), 0.5)
    _spawn_damage_number(hit_pos, int(round(impact_damage)))
    _spawn_contact_sparks(hit_pos, node.get("material_color", Color.WHITE), 4 + int(round(charge_ratio * 6.0)))
    camera_shake_strength = min(11.0, camera_shake_strength + 4.0 + charge_ratio * 5.0)
    straight_drive_charge = max(0.0, straight_drive_charge - 0.8)
    if float(node["health"]) <= 0.0:
        _break_node(node_index)
        run_status = "Charge break. Keep the line and sweep the seam."
        return true
    return false

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
    if not simulation_mode_active:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)

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

func _get_drill_heading() -> Vector2:
    var heading: Vector2 = _get_pointer_direction()
    if heading == Vector2.ZERO:
        heading = player_velocity.normalized()
    if heading == Vector2.ZERO:
        heading = last_drill_direction
    if heading == Vector2.ZERO:
        heading = Vector2.DOWN
    return heading.normalized()

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
        current_pos.x = clampf(current_pos.x, -WORLD_SIZE.x * 0.5 + PLAYER_RADIUS, WORLD_SIZE.x * 0.5 - PLAYER_RADIUS)
        current_pos.y = clampf(current_pos.y, -WORLD_SIZE.y * 0.5 + PLAYER_RADIUS, WORLD_SIZE.y * 0.5 - PLAYER_RADIUS)

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
    draw_circle(base_screen, BASE_RADIUS, Color(0.27, 0.3, 0.35, 0.92))
    draw_circle(base_screen, BASE_RADIUS - 12.0, Color(0.81, 0.7, 0.36, 0.28))
    draw_arc(base_screen, BASE_RADIUS - 8.0, 0.0, TAU, 40, Color(0.95, 0.81, 0.45, 0.95), 3.0)
    draw_rect(Rect2(base_screen + Vector2(-22.0, -58.0), Vector2(44.0, 72.0)), Color(0.22, 0.24, 0.28, 1.0), true)
    draw_rect(Rect2(base_screen + Vector2(-36.0, -16.0), Vector2(72.0, 28.0)), Color(0.42, 0.43, 0.48, 1.0), true)

func _draw_nodes(origin: Vector2) -> void:
    for node in world_nodes:
        var node_screen: Vector2 = _world_to_screen(node.get("pos", Vector2.ZERO))
        var node_color: Color = node.get("material_color", Color(0.5, 0.5, 0.5, 1.0))
        var radius: float = float(node.get("radius", 20.0))
        var rock_points: PackedVector2Array = _get_translated_shape_points(node, node_screen)
        draw_colored_polygon(rock_points, node_color)
        draw_arc(node_screen, radius + 3.0, 0.0, TAU, 28, Color(1.0, 1.0, 1.0, 0.18), 2.0)
        var hp_ratio: float = float(node.get("health", 1.0)) / max(1.0, float(node.get("max_health", 1.0)))
        draw_arc(node_screen, radius + 8.0, -PI * 0.5, -PI * 0.5 + TAU * hp_ratio, 30, Color(0.95, 0.77, 0.4, 0.95), 3.0)
        _draw_node_sparkles(node_screen, radius, float(node.get("sparkle", 0.0)))

func _draw_node_sparkles(node_screen: Vector2, radius: float, sparkle: float) -> void:
    if sparkle <= 0.0:
        return
    var sparkle_count: int = int(round(2.0 + sparkle * 4.0))
    for sparkle_index in range(sparkle_count):
        var angle: float = TAU * float(sparkle_index) / float(max(1, sparkle_count))
        var pos: Vector2 = node_screen + Vector2.RIGHT.rotated(angle) * (radius * 0.58)
        draw_circle(pos, 2.0 + sparkle, Color(1.0, 1.0, 1.0, 0.75))

func _draw_pickups(origin: Vector2) -> void:
    for pickup in pickups:
        var pickup_screen: Vector2 = _world_to_screen(pickup.get("pos", Vector2.ZERO))
        var pickup_color: Color = pickup.get("material_color", Color(0.8, 0.8, 0.8, 1.0))
        draw_circle(pickup_screen, 7.0, pickup_color)
        draw_circle(pickup_screen, 3.0, Color(1.0, 1.0, 1.0, 0.75))
    _draw_delivery_drones()
    _draw_pickup_drones()
    _draw_contact_sparks()
    _draw_damage_numbers()

func _draw_delivery_drones() -> void:
    for drone in delivery_drone_visuals:
        var is_returning: bool = String(drone.get("state", "to_base")) == "returning"
        var body_color := Color(0.56, 0.82, 0.88, 1.0) if is_returning else Color(0.72, 0.9, 0.98, 1.0)
        var carry_color: Color = drone.get("carry_color", Color.WHITE)
        _draw_drone_body(_world_to_screen(drone.get("pos", Vector2.ZERO)), body_color, carry_color)

func _draw_pickup_drones() -> void:
    for drone in pickup_drone_visuals:
        var carry_color: Color = drone.get("carry_color", Color(0.94, 0.82, 0.38, 1.0)) if String(drone.get("state", "idle")) == "to_player" else Color(0.0, 0.0, 0.0, 0.0)
        _draw_drone_body(_world_to_screen(drone.get("pos", Vector2.ZERO)), Color(0.92, 0.76, 0.38, 1.0), carry_color)

func _draw_drone_body(screen_pos: Vector2, body_color: Color, carry_color: Color) -> void:
    draw_circle(screen_pos, 9.0, Color(0.12, 0.14, 0.17, 0.95))
    draw_circle(screen_pos, 6.0, body_color)
    draw_line(screen_pos + Vector2(-11.0, -7.0), screen_pos + Vector2(11.0, -7.0), Color(0.85, 0.9, 0.95, 0.72), 2.0)
    draw_line(screen_pos + Vector2(-11.0, 7.0), screen_pos + Vector2(11.0, 7.0), Color(0.85, 0.9, 0.95, 0.72), 2.0)
    if carry_color.a > 0.0:
        var cargo_pos: Vector2 = screen_pos + Vector2(0.0, 12.0)
        draw_line(screen_pos + Vector2(0.0, 4.0), cargo_pos, Color(0.94, 0.92, 0.8, 0.7), 1.5)
        draw_circle(cargo_pos, 5.0, carry_color)
        draw_circle(cargo_pos, 2.0, Color(1.0, 1.0, 1.0, 0.75))

func _draw_contact_sparks() -> void:
    for spark in contact_sparks:
        var spark_screen: Vector2 = _world_to_screen(spark.get("pos", Vector2.ZERO))
        var spark_color: Color = spark.get("color", Color.WHITE)
        var spark_radius: float = float(spark.get("radius", 2.0)) * clampf(float(spark.get("life", 0.0)) * 4.0, 0.35, 1.0)
        draw_circle(spark_screen, spark_radius, spark_color)

func _draw_damage_numbers() -> void:
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

func _draw_tail() -> void:
    for copy_index in range(drill_copies.size() - 1, -1, -1):
        var copy_data: Dictionary = drill_copies[copy_index]
        var scale: float = 0.88 - 0.08 * float(copy_index)
        var shell_color: Color = Color(0.16, 0.17, 0.2, 0.82 - 0.08 * float(copy_index))
        var body_color: Color = Color(0.83, 0.74, 0.28, 0.74 - 0.09 * float(copy_index))
        var copy_boost_strength: float = tunnel_speed_boost_strength * max(0.0, 1.0 - 0.18 * float(copy_index))
        _draw_drill_ship(
            _world_to_screen(copy_data.get("pos", player_pos)),
            copy_data.get("dir", _get_drill_heading()),
            scale,
            shell_color,
            body_color,
            copy_boost_strength
        )

func _draw_player(origin: Vector2) -> void:
    var aim_dir: Vector2 = _get_pointer_direction()
    if aim_dir == Vector2.ZERO:
        aim_dir = player_velocity.normalized()
    if aim_dir == Vector2.ZERO:
        aim_dir = Vector2.DOWN
    _draw_drill_ship(_world_to_screen(player_pos), aim_dir, 1.0, Color(0.16, 0.17, 0.2, 1.0), Color(0.83, 0.74, 0.28, 1.0), tunnel_speed_boost_strength)

func _draw_drill_ship(screen_pos: Vector2, aim_dir: Vector2, scale: float, shell_color: Color, body_color: Color, boost_strength: float = 0.0) -> void:
    var spin_angle: float = Time.get_ticks_msec() * 0.02
    var boost_shell: Color = shell_color.lerp(Color(0.24, 0.45, 0.56, shell_color.a), boost_strength * 0.55)
    var boost_body: Color = body_color.lerp(Color(0.92, 0.96, 1.0, body_color.a), boost_strength * 0.45)
    if boost_strength > 0.0:
        draw_circle(screen_pos, (PLAYER_RADIUS + 8.0 + boost_strength * 4.0) * scale, Color(0.6, 0.92, 1.0, 0.1 + boost_strength * 0.16))
        draw_arc(screen_pos, (PLAYER_RADIUS + 9.0) * scale, 0.0, TAU, 32, Color(0.82, 0.97, 1.0, 0.18 + boost_strength * 0.28), 2.0 * scale)
    draw_circle(screen_pos, (PLAYER_RADIUS + 4.0) * scale, boost_shell)
    var body_points: PackedVector2Array = PackedVector2Array([
        screen_pos + Vector2(-14.0, 10.0).rotated(aim_dir.angle() + PI * 0.5) * scale,
        screen_pos + Vector2(0.0, -22.0).rotated(aim_dir.angle() + PI * 0.5) * scale,
        screen_pos + Vector2(14.0, 10.0).rotated(aim_dir.angle() + PI * 0.5) * scale
    ])
    draw_colored_polygon(body_points, boost_body)
    for tooth_index in range(3):
        var tooth_angle: float = spin_angle + TAU * float(tooth_index) / 3.0
        var tooth_dir: Vector2 = aim_dir.rotated(tooth_angle * 0.25)
        draw_line(screen_pos + tooth_dir * (4.0 * scale), screen_pos + tooth_dir * ((24.0 + boost_strength * 3.0) * scale), Color(0.95, 0.99, 1.0, boost_body.a), maxf(1.5, (3.0 + boost_strength) * scale))

func _draw_target_line(origin: Vector2) -> void:
    if target_node_id < 0 or target_node_id >= world_nodes.size():
        return
    var target_pos: Vector2 = world_nodes[target_node_id].get("pos", Vector2.ZERO)
    draw_line(_world_to_screen(player_pos), _world_to_screen(target_pos), Color(1.0, 0.9, 0.5, 0.42), 2.0)

func _draw_edge_fade(viewport_size: Vector2) -> void:
    draw_rect(Rect2(0.0, 0.0, viewport_size.x, 18.0), Color(0.0, 0.0, 0.0, 0.25), true)
    draw_rect(Rect2(0.0, viewport_size.y - 18.0, viewport_size.x, 18.0), Color(0.0, 0.0, 0.0, 0.25), true)

func _get_base_position() -> Vector2:
    return Vector2(0.0, -WORLD_SIZE.y * 0.5 + 120.0)

func _world_to_screen(world_pos: Vector2) -> Vector2:
    return world_pos - camera_pos + get_viewport_rect().size * 0.5

func _screen_to_world(screen_pos: Vector2) -> Vector2:
    return screen_pos + camera_pos - get_viewport_rect().size * 0.5

func _get_level_bg_color() -> Color:
    var tint: Color = Color(0.18, 0.14, 0.11, 1.0)
    var depth_factor: float = float(active_depth_level - 1) / float(max(1, material_tiers.size() - 1))
    return tint.lerp(active_material.get("bg", Color(0.16, 0.12, 0.1, 1.0)), clampf(depth_factor * 0.75, 0.0, 0.8))

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
    dirt_image = Image.create(512, 640, false, Image.FORMAT_RGBA8)
    dirt_image.fill(Color(0.38, 0.27, 0.16, 0.96))
    dirt_texture = ImageTexture.create_from_image(dirt_image)

func _world_to_dirt_pixel(world_pos: Vector2) -> Vector2i:
    var x_ratio: float = clampf((world_pos.x + WORLD_SIZE.x * 0.5) / WORLD_SIZE.x, 0.0, 1.0)
    var y_ratio: float = clampf((world_pos.y + WORLD_SIZE.y * 0.5) / WORLD_SIZE.y, 0.0, 1.0)
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
    var pixel_radius: int = int(round(radius * float(dirt_image.get_width()) / WORLD_SIZE.x))
    for x in range(pixel_center.x - pixel_radius, pixel_center.x + pixel_radius + 1):
        if x < 0 or x >= dirt_image.get_width():
            continue
        for y in range(pixel_center.y - pixel_radius, pixel_center.y + pixel_radius + 1):
            if y < 0 or y >= dirt_image.get_height():
                continue
            if Vector2(float(x - pixel_center.x), float(y - pixel_center.y)).length() > float(pixel_radius):
                continue
            dirt_image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
    dirt_texture.update(dirt_image)

func _setup_system_controls() -> void:
    mute_button = Button.new()
    mute_button.name = "MuteButton"
    mute_button.anchor_left = 0.5
    mute_button.anchor_top = 0.0
    mute_button.anchor_right = 0.5
    mute_button.anchor_bottom = 0.0
    mute_button.offset_left = -42.0
    mute_button.offset_top = 16.0
    mute_button.offset_right = 42.0
    mute_button.offset_bottom = 82.0
    mute_button.focus_mode = Control.FOCUS_NONE
    mute_button.custom_minimum_size = Vector2(84.0, 66.0)
    mute_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mute_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    mute_button.expand_icon = true
    mute_button.z_index = 60

    fullscreen_button = Button.new()
    fullscreen_button.name = "FullscreenButton"
    fullscreen_button.anchor_left = 0.0
    fullscreen_button.anchor_top = 0.0
    fullscreen_button.anchor_right = 0.0
    fullscreen_button.anchor_bottom = 0.0
    fullscreen_button.offset_left = 16.0
    fullscreen_button.offset_top = 16.0
    fullscreen_button.offset_right = 60.0
    fullscreen_button.offset_bottom = 60.0
    fullscreen_button.focus_mode = Control.FOCUS_NONE
    fullscreen_button.custom_minimum_size = Vector2(44.0, 44.0)
    fullscreen_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
    fullscreen_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    fullscreen_button.expand_icon = true
    fullscreen_button.z_index = 60

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
    mute_button.pressed.connect(_on_mute_button_pressed)
    fullscreen_button.pressed.connect(_on_fullscreen_button_pressed)
    settings_button.pressed.connect(_on_settings_button_pressed)
    _style_utility_button(mute_button)
    _style_utility_button(fullscreen_button)
    _style_utility_button(settings_button)
    $CanvasLayer.add_child(mute_button)
    $CanvasLayer.add_child(fullscreen_button)
    $CanvasLayer.add_child(settings_button)
    speaker_icon_on = _make_speaker_icon_texture(false)
    speaker_icon_off = _make_speaker_icon_texture(true)
    fullscreen_icon_on = _make_fullscreen_icon_texture(true)
    fullscreen_icon_off = _make_fullscreen_icon_texture(false)
    _refresh_system_button_icons()
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

func _refresh_system_button_icons() -> void:
    if mute_button != null:
        mute_button.text = ""
        mute_button.icon = speaker_icon_off if SaveHandler.audio_muted else speaker_icon_on
        mute_button.tooltip_text = tr("UI_UNMUTE_AUDIO") if SaveHandler.audio_muted else tr("UI_MUTE_AUDIO")
    if fullscreen_button != null:
        fullscreen_button.text = ""
        var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
        fullscreen_button.icon = fullscreen_icon_on if is_fullscreen else fullscreen_icon_off
        fullscreen_button.tooltip_text = tr("UI_EXIT_FULLSCREEN") if is_fullscreen else tr("UI_ENTER_FULLSCREEN")

func _on_mute_button_pressed() -> void:
    SaveHandler.update_audio_muted(not SaveHandler.audio_muted)
    _refresh_system_button_icons()

func _on_fullscreen_button_pressed() -> void:
    var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    SaveHandler.update_screen_mode(SaveHandler.SCREEN_MODES.WINDOWED if is_fullscreen else SaveHandler.SCREEN_MODES.FULL_SCREEN)
    _refresh_system_button_icons()
    _update_system_button_layout()
    if settings_content != null:
        settings_content.refresh_from_save()

func _on_settings_button_pressed() -> void:
    _toggle_settings_panel()

func _on_settings_close_pressed() -> void:
    if settings_panel != null and is_instance_valid(settings_panel):
        settings_panel.hide()
    _refresh_mouse_capture_state()

func _toggle_settings_panel() -> void:
    if settings_panel == null:
        return
    settings_panel.visible = not settings_panel.visible
    if settings_panel.visible and settings_content != null:
        settings_content.show_screen()
        settings_content.refresh_from_save()
    _refresh_mouse_capture_state()

func _on_settings_updated() -> void:
    _refresh_system_button_icons()
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
    for step in range(steps + 1):
        var t: float = float(step) / float(steps)
        var point := Vector2(
            lerpf(float(start.x), float(finish.x), t),
            lerpf(float(start.y), float(finish.y), t)
        )
        var radius: int = maxi(1, int(round(float(thickness) * 0.5)))
        for offset_x in range(-radius, radius + 1):
            for offset_y in range(-radius, radius + 1):
                if Vector2(offset_x, offset_y).length() > float(radius):
                    continue
                var px: int = int(round(point.x)) + offset_x
                var py: int = int(round(point.y)) + offset_y
                if px < 0 or py < 0 or px >= image.get_width() or py >= image.get_height():
                    continue
                image.set_pixel(px, py, color)

func _draw_arc_ring(image: Image, center: Vector2i, inner_radius: int, outer_radius: int, start_angle: float, end_angle: float, color: Color) -> void:
    for radius in range(inner_radius, outer_radius + 1):
        var arc_length: float = abs(end_angle - start_angle) * float(radius)
        var segments: int = maxi(12, int(ceil(arc_length)))
        for segment in range(segments + 1):
            var t: float = float(segment) / float(segments)
            var angle: float = lerpf(start_angle, end_angle, t)
            var px: int = int(round(float(center.x) + cos(angle) * float(radius)))
            var py: int = int(round(float(center.y) + sin(angle) * float(radius)))
            if px < 0 or py < 0 or px >= image.get_width() or py >= image.get_height():
                continue
            image.set_pixel(px, py, color)

func _get_material_by_id(material_id: String) -> Dictionary:
    return MINING_BALANCE.get_material_by_id(material_id)

func _build_material_tiers() -> Array[Dictionary]:
    return MINING_BALANCE.get_material_tiers()
