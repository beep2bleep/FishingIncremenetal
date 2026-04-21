extends Node2D
class_name OpenPitOrbitMain

const BALANCE := preload("res://Games/OpenPitOrbit/OpenPitOrbitBalance.gd")
const PROGRESS := preload("res://Games/OpenPitOrbit/OpenPitOrbitProgress.gd")
const PLANET_DATA_SCRIPT := preload("res://Games/OpenPitOrbit/OpenPitOrbitPlanetData.gd")
const PLANET_RENDERER_SCRIPT := preload("res://Games/OpenPitOrbit/Scenes/OpenPitOrbitPlanetRenderer.gd")
const PERF_GRAPH_SCRIPT := preload("res://Games/OpenPitOrbit/Scenes/OpenPitOrbitPerfGraph.gd")
const MINIMAP_SCRIPT := preload("res://Games/OpenPitOrbit/Scenes/OpenPitOrbitMiniMap.gd")
const DROP_RENDERER_SCRIPT := preload("res://Games/OpenPitOrbit/Scenes/OpenPitOrbitDropRenderer.gd")
const SHIP_RENDERER_SCRIPT := preload("res://Games/OpenPitOrbit/Scenes/OpenPitOrbitShipRenderer.gd")

const BLOCK_SIZE := 32.0
const PLANET_RADIUS_CELLS := 280
const SHIP_RADIUS := 10.0
const RETURN_ZONE_RADIUS := 90.0
const RETURN_ZONE_DELAY := 1.5
const HIT_FLASH_DURATION := 0.15
const GOLD_CONVERT_DURATION := 0.5
const ARC_DURATION := 0.15
const CHAIN_ARC_DURATION := 0.2
const DRONE_BEAM_DURATION := 0.08
const SHOCKWAVE_RING_SPEED := 520.0
const MAX_SHOCKWAVE_RINGS := 3
const MEGA_DAMAGE_INTERVAL := 0.08
const MAX_WORLD_PICKUPS := 220
const DEAD_ZONE := 30.0
const MAX_INPUT_DIST := 350.0
const ROTATION_SPEED := 8.0
const PICKUP_DRIFT := 24.0
const CARDINAL_NEIGHBORS := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const SHIP_TRAIL_INTERVAL := 0.03
const SHIP_TRAIL_MAX := 8
const HUD_REFRESH_INTERVAL := 0.1
const DRONE_RANGE := 230.0
const DRONE_FOLLOW_SPEED := 8.0
const DRONE_SPACING := 20.0
const DRONE_BEHIND_DIST := 25.0
const DEFENSE_BLOCK_INTERVAL := 5.0
const CORE_SHOCKWAVE_INTERVAL := 7.0
const CORE_SHOCKWAVE_PUSH := 280.0
const SUMMER_LASER_INTERVAL_OUTER := 5.5
const SUMMER_LASER_INTERVAL_BOSS := 4.5
const SUMMER_LASER_INTERVAL_BOSS_LOW := 2.0
const SUMMER_LASER_WARN_OUTER := 1.5
const SUMMER_LASER_WARN_BOSS := 1.5
const SUMMER_LASER_FIRE_DURATION := 0.3
const SUMMER_LASER_WIDTH := 24.0
const SUMMER_LASER_BOSS_HP_THRESHOLD := 0.5
const AUTUMN_DEBRIS_INTERVAL_OUTER := 4.5
const AUTUMN_DEBRIS_INTERVAL_BOSS := 2.5
const AUTUMN_DEBRIS_INTERVAL_BOSS_LOW := 1.5
const AUTUMN_DEBRIS_COUNT_OUTER := 2
const AUTUMN_DEBRIS_COUNT_BOSS := 3
const AUTUMN_DEBRIS_COUNT_BOSS_LOW := 5
const AUTUMN_DEBRIS_SPEED := 175.0
const AUTUMN_DEBRIS_HOMING_STRENGTH := 1.8
const AUTUMN_DEBRIS_LIFETIME := 5.0
const AUTUMN_DEBRIS_HIT_RADIUS := 16.0
const AUTUMN_DEBRIS_MAX_ACTIVE := 20
const WINTER_CROSS_LASER_SPEED_BASE := 0.4
const WINTER_CROSS_LASER_SPEED_ATTACKED := 0.6
const WINTER_CROSS_LASER_SPEED_BOSS_LOW := 1.0
const WINTER_CROSS_LASER_WIDTH := 20.0
const WINTER_CROSS_LASER_BOSS_HP_THRESHOLD := 0.5
const WINTER_CROSS_LASER_HIT_COOLDOWN := 0.5
const WINTER_CROSS_LASER_GAP_SIZE := 0.18
const WINTER_CROSS_LASER_GAP_SLIDE_SPEED := 0.15
const WINTER_CROSS_LASER_GAP_MAX := 0.85
const CORE_HAZARD_KNOCKBACK := 500.0

enum BlockType { NORMAL, CORE, ELECTRIC, GOLD, THORN }

var rng := RandomNumberGenerator.new()
var persistent_data: Dictionary = {}
var upgrades: Dictionary = {}
var runtime_stats: Dictionary = {}
var planet_data
var blocks: Dictionary = {}
var exposed_edges: Dictionary = {}
var damaged_cells: Dictionary = {}
var hit_timers: Dictionary = {}
var gold_convert_timers: Dictionary = {}
var pickups: Array[Dictionary] = []
var destroyed_cells_this_run: Dictionary = {}

var ship_pos := Vector2.ZERO
var ship_vel := Vector2.ZERO
var spawn_position := Vector2.ZERO
var camera_pos := Vector2.ZERO
var planet_center := Vector2.ZERO
var planet_radius_cells := 0
var current_depth_level := 1
var current_layer_name := ""
var time_left := 30.0
var run_finished := false
var has_left_spawn := false
var return_zone_radius := RETURN_ZONE_RADIUS
var return_zone_timer := 0.0
var cargo_units := 0
var cargo_money := 0
var nodes_mined := 0
var barriers_left := 0
var boss_defeated := false
var current_combo := 0
var combo_timer := 0.0
var combo_peak := 0
var persistent_destroyed_count := 0
var total_planet_blocks := 0
var attack_timer := 0.0
var attack_visible_timer := 0.0
var charged_shot_counter := 0
var shockwave_counter := 0
var overdrive_kills := 0
var overdrive_timer := 0.0
var mega_gauge := 0
var mega_timer := 0.0
var mega_damage_timer := 0.0
var mega_direction := Vector2.UP
var mega_beam_end := Vector2.ZERO
var mega_beam_hits: Array[Vector2] = []
var visual_rotation := 0.0
var last_move_dir := Vector2.UP
var ship_glow_phase := 0.0
var ship_trail: Array[Dictionary] = []
var ship_trail_timer := 0.0
var hud_refresh_timer := 0.0
var core_defense_timer := DEFENSE_BLOCK_INTERVAL
var core_shockwave_timer := CORE_SHOCKWAVE_INTERVAL
var cores_destroyed_this_run := 0
var core_currency_earned_this_run := 0

var last_attack_target := Vector2.ZERO
var last_attack_is_crit := false
var last_attack_is_charged := false
var multi_targets: Array[Vector2] = []
var electric_arcs: Array[Dictionary] = []
var chain_arcs: Array[Dictionary] = []
var shockwave_rings: Array[Dictionary] = []
var shockwave_firing := false
var drone_positions: Array[Vector2] = []
var drone_beams: Array[Dictionary] = []
var drone_timers: Array[float] = []
var drone_targets: Array[Vector2] = []
var summer_laser_states: Dictionary = {}
var autumn_debris: Array[Dictionary] = []
var winter_cross_lasers: Dictionary = {}
var autumn_debris_timers: Dictionary = {}

var planet_renderer: Node2D
var drop_renderer: Node2D
var ship_root: Node2D
var ship_renderer: Node2D
var camera: Camera2D
var hud_layer: CanvasLayer
var timer_label: Label
var cargo_label: Label
var wallet_label: Label
var layer_label: Label
var status_label: Label
var system_label: Label
var fps_label: Label
var perf_graph: Control
var minimap: Control
var summary_overlay: ColorRect
var summary_label: RichTextLabel
var summary_status_label: Label
var summary_return_button: Button
var summary_save_anim_time := 0.0
var summary_save_pending := false
var summary_save_phase := "idle"

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    VirtualCursor.use_open_pit_orbit_cursor(true)
    Global.game_state = Util.GAME_STATES.PLAYING
    rng.randomize()
    _build_runtime_nodes()
    _build_ui()
    _start_run()
    set_process(true)

func _exit_tree() -> void:
    VirtualCursor.use_open_pit_orbit_cursor(false)
    _save_planet_snapshot()

func _build_runtime_nodes() -> void:
    planet_renderer = PLANET_RENDERER_SCRIPT.new()
    planet_renderer.scene_ref = self
    add_child(planet_renderer)

    drop_renderer = DROP_RENDERER_SCRIPT.new()
    drop_renderer.scene_ref = self
    add_child(drop_renderer)

    ship_root = Node2D.new()
    ship_root.name = "ShipRoot"
    add_child(ship_root)

    ship_renderer = SHIP_RENDERER_SCRIPT.new()
    ship_renderer.scene_ref = self
    ship_root.add_child(ship_renderer)

    camera = Camera2D.new()
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 8.0
    ship_root.add_child(camera)
    camera.make_current()

func _build_ui() -> void:
    hud_layer = CanvasLayer.new()
    add_child(hud_layer)

    var panel := PanelContainer.new()
    panel.offset_left = 16.0
    panel.offset_top = 16.0
    panel.offset_right = 500.0
    panel.offset_bottom = 224.0
    hud_layer.add_child(panel)

    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color(0.02, 0.04, 0.08, 0.9)
    panel_style.border_color = Color(0.32, 0.7, 1.0, 0.65)
    panel_style.set_border_width_all(2)
    panel_style.set_corner_radius_all(8)
    panel.add_theme_stylebox_override("panel", panel_style)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 10)
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_right", 10)
    margin.add_theme_constant_override("margin_bottom", 10)
    panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 4)
    margin.add_child(vbox)

    timer_label = Label.new()
    cargo_label = Label.new()
    wallet_label = Label.new()
    layer_label = Label.new()
    status_label = Label.new()
    system_label = Label.new()
    for label in [timer_label, cargo_label, wallet_label, layer_label, status_label, system_label]:
        label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
        vbox.add_child(label)
    if OS.has_feature("editor"):
        fps_label = Label.new()
        fps_label.add_theme_color_override("font_color", Color(0.68, 0.96, 0.8, 1.0))
        vbox.add_child(fps_label)
        perf_graph = PERF_GRAPH_SCRIPT.new()
        vbox.add_child(perf_graph)

    summary_overlay = ColorRect.new()
    summary_overlay.anchor_right = 1.0
    summary_overlay.anchor_bottom = 1.0
    summary_overlay.color = Color(0.0, 0.0, 0.0, 0.8)
    summary_overlay.visible = false
    hud_layer.add_child(summary_overlay)

    var summary_center := CenterContainer.new()
    summary_center.anchor_right = 1.0
    summary_center.anchor_bottom = 1.0
    summary_overlay.add_child(summary_center)

    var summary_panel := PanelContainer.new()
    summary_panel.custom_minimum_size = Vector2(620.0, 360.0)
    summary_panel.add_theme_stylebox_override("panel", panel_style.duplicate(true))
    summary_center.add_child(summary_panel)

    var summary_margin := MarginContainer.new()
    summary_margin.add_theme_constant_override("margin_left", 16)
    summary_margin.add_theme_constant_override("margin_top", 16)
    summary_margin.add_theme_constant_override("margin_right", 16)
    summary_margin.add_theme_constant_override("margin_bottom", 16)
    summary_panel.add_child(summary_margin)

    var summary_vbox := VBoxContainer.new()
    summary_vbox.add_theme_constant_override("separation", 12)
    summary_margin.add_child(summary_vbox)

    var title := Label.new()
    title.text = "Open Pit Orbit"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    title.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0, 1.0))
    summary_vbox.add_child(title)

    summary_label = RichTextLabel.new()
    summary_label.fit_content = true
    summary_label.scroll_active = false
    summary_label.bbcode_enabled = true
    summary_label.custom_minimum_size = Vector2(560.0, 180.0)
    summary_vbox.add_child(summary_label)

    summary_status_label = Label.new()
    summary_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    summary_status_label.add_theme_color_override("font_color", Color(0.78, 0.88, 1.0, 0.95))
    summary_vbox.add_child(summary_status_label)

    summary_return_button = Button.new()
    summary_return_button.text = "Return To Upgrades"
    summary_return_button.custom_minimum_size = Vector2(260.0, 74.0)
    summary_return_button.pressed.connect(_return_to_upgrades)
    summary_vbox.add_child(summary_return_button)

func _start_run() -> void:
    persistent_data = PROGRESS.load_data()
    upgrades = persistent_data.get("upgrades", {}).duplicate(true)
    runtime_stats = BALANCE.build_runtime_stats(upgrades)
    current_depth_level = clampi(int(persistent_data.get("selected_depth_level", 1)), 1, BALANCE.MAX_DEPTH_LEVEL)
    planet_radius_cells = PLANET_RADIUS_CELLS
    time_left = float(runtime_stats.get("run_time", 30.0))
    barriers_left = int(runtime_stats.get("barriers", 0)) + (1 if _has_core_upgrade("barrier_regen") else 0)
    boss_defeated = bool(persistent_data.get("boss_defeated", false))
    _build_planet()
    _setup_minimap()
    spawn_position = Vector2(0.0, -(float(planet_radius_cells) + 7.0) * BLOCK_SIZE)
    if _has_core_upgrade("spawn_direction") and planet_data != null and not planet_data.cores.is_empty():
        spawn_position = scene_to_spawn_ring(Vector2i(int(planet_data.cores[0].center.x), int(planet_data.cores[0].center.y)))
    ship_pos = spawn_position
    ship_root.global_position = ship_pos
    camera_pos = ship_pos
    current_layer_name = "Orbital Shell"
    return_zone_radius = RETURN_ZONE_RADIUS + (36.0 if _has_core_upgrade("return_shortcut") else 0.0)
    attack_timer = 0.0
    attack_visible_timer = 0.0
    charged_shot_counter = 0
    shockwave_counter = 0
    overdrive_kills = 0
    overdrive_timer = 0.0
    mega_gauge = 0
    mega_timer = 0.0
    mega_damage_timer = 0.0
    ship_trail.clear()
    ship_trail_timer = 0.0
    pickups.clear()
    destroyed_cells_this_run.clear()
    cores_destroyed_this_run = 0
    core_currency_earned_this_run = 0
    electric_arcs.clear()
    chain_arcs.clear()
    shockwave_rings.clear()
    summer_laser_states.clear()
    autumn_debris.clear()
    autumn_debris_timers.clear()
    winter_cross_lasers.clear()
    drone_beams.clear()
    _reset_drone_state()
    current_combo = 0
    combo_peak = 0
    core_defense_timer = DEFENSE_BLOCK_INTERVAL
    core_shockwave_timer = CORE_SHOCKWAVE_INTERVAL
    summary_overlay.visible = false
    planet_renderer.mark_dirty()
    _refresh_hud()

func _build_planet() -> void:
    damaged_cells.clear()
    var persistent_destroyed := {}
    var saved_planet_state: Dictionary = PROGRESS.load_planet_state()
    if saved_planet_state.is_empty():
        for saved_variant in persistent_data.get("destroyed_cells", []):
            if saved_variant is String:
                var parts := str(saved_variant).split(",")
                if parts.size() == 2:
                    persistent_destroyed[Vector2i(int(parts[0]), int(parts[1]))] = true
            elif saved_variant is Vector2i:
                persistent_destroyed[saved_variant] = true
        persistent_destroyed_count = persistent_destroyed.size()
    else:
        persistent_destroyed_count = 0
    var cached_runtime_planet = PROGRESS.load_runtime_planet_data(current_depth_level)
    if cached_runtime_planet != null:
        planet_data = cached_runtime_planet
    elif not saved_planet_state.is_empty():
        planet_data = PLANET_DATA_SCRIPT.new()
        planet_data.load_save_data(saved_planet_state)
    else:
        planet_data = PLANET_DATA_SCRIPT.new()
        planet_data.core_difficulty_mult = pow(1.5, int(persistent_data.get("total_cores_destroyed", 0)))
        planet_data.generate_sync(current_depth_level, persistent_destroyed, BALANCE, rng)
    planet_data.on_core_destroyed_callback = Callable(self, "_on_core_destroyed")
    blocks = planet_data.blocks
    exposed_edges = planet_data.exposed_edges
    total_planet_blocks = max(int(planet_data.initial_block_count), planet_data.get_total_blocks())
    persistent_destroyed_count = max(0, total_planet_blocks - planet_data.get_total_blocks())

func _setup_minimap() -> void:
    if minimap != null and is_instance_valid(minimap):
        minimap.queue_free()
        minimap = null
    if not bool(runtime_stats.get("minimap_enabled", false)) or planet_data == null:
        return
    minimap = MINIMAP_SCRIPT.new()
    hud_layer.add_child(minimap)
    minimap.setup(planet_data, self)

func _process(delta: float) -> void:
    if run_finished:
        _update_finish_summary(delta)
        return
    ship_glow_phase += delta * 3.0
    camera_pos = ship_pos
    _update_timers(delta)
    if run_finished:
        return
    _update_ship(delta)
    _update_ship_trail(delta)
    _update_pickups(delta)
    _update_combat(delta)
    _update_drone_visuals(delta)
    _update_zone_return(delta)
    _update_core_behaviors(delta)
    _update_core_attacks(delta)
    _update_current_layer_name()
    hud_refresh_timer -= delta
    if hud_refresh_timer <= 0.0:
        hud_refresh_timer = HUD_REFRESH_INTERVAL
        _refresh_hud()
    ship_root.global_position = ship_pos
    if fps_label != null:
        _update_perf_debug(delta)

func _update_timers(delta: float) -> void:
    time_left = maxf(0.0, time_left - delta)
    if time_left <= 0.0:
        _finish_run(_has_core_upgrade("emergency_return"), "Fuel burned out before extraction.")
        return
    combo_timer = maxf(0.0, combo_timer - delta)
    if combo_timer <= 0.0:
        current_combo = 0
    overdrive_timer = maxf(0.0, overdrive_timer - delta)
    mega_timer = maxf(0.0, mega_timer - delta)
    attack_visible_timer = maxf(0.0, attack_visible_timer - delta)
    _tick_timer_dict(hit_timers, delta)
    _tick_timer_dict(gold_convert_timers, delta)
    _tick_effect_array(electric_arcs, delta)
    _tick_effect_array(chain_arcs, delta)
    _tick_effect_array(drone_beams, delta)
    for core_id_variant in summer_laser_states.keys():
        var core_id: int = int(core_id_variant)
        var state: Dictionary = summer_laser_states.get(core_id, {})
        if float(state.get("hit_timer", 0.0)) > 0.0:
            state["hit_timer"] = maxf(0.0, float(state.get("hit_timer", 0.0)) - delta)
        summer_laser_states[core_id] = state
    for idx in range(autumn_debris.size() - 1, -1, -1):
        var debris: Dictionary = autumn_debris[idx]
        debris["life"] = float(debris.get("life", AUTUMN_DEBRIS_LIFETIME)) - delta
        if float(debris.get("life", 0.0)) <= 0.0:
            autumn_debris.remove_at(idx)
            continue
        autumn_debris[idx] = debris
    for idx in range(shockwave_rings.size() - 1, -1, -1):
        var ring := shockwave_rings[idx]
        ring["radius"] = float(ring.get("radius", 0.0)) + SHOCKWAVE_RING_SPEED * delta
        var max_radius := maxf(1.0, float(ring.get("max_radius", float(runtime_stats.get("shockwave_radius_cells", 6)) * BLOCK_SIZE)))
        var progress := clampf(float(ring.get("radius", 0.0)) / max_radius, 0.0, 1.0)
        ring["alpha"] = 0.8 * (1.0 - progress)
        shockwave_rings[idx] = ring
        if float(ring.get("radius", 0.0)) >= max_radius or float(ring.get("alpha", 0.0)) <= 0.0:
            shockwave_rings.remove_at(idx)

func _update_ship(delta: float) -> void:
    var viewport_size := get_viewport_rect().size
    var desired_velocity := Vector2.ZERO
    var keyboard_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if keyboard_dir == Vector2.ZERO:
        keyboard_dir = Vector2(
            int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
            int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
        )
    var effective_speed := float(runtime_stats.get("move_speed", 280.0)) + (float(runtime_stats.get("overdrive_speed_bonus", 300.0)) if overdrive_timer > 0.0 else 0.0)
    if keyboard_dir != Vector2.ZERO:
        desired_velocity = keyboard_dir.normalized() * effective_speed
    else:
        var screen_center := viewport_size * 0.5
        var mouse_screen := get_viewport().get_mouse_position()
        var offset := mouse_screen - screen_center
        var distance := offset.length()
        if distance >= DEAD_ZONE:
            var speed_ratio := clampf((distance - DEAD_ZONE) / (MAX_INPUT_DIST - DEAD_ZONE), 0.0, 1.0)
            desired_velocity = offset.normalized() * effective_speed * speed_ratio
    ship_vel = ship_vel.move_toward(desired_velocity, effective_speed * delta * 6.0)
    if desired_velocity == Vector2.ZERO:
        ship_vel = ship_vel.move_toward(Vector2.ZERO, effective_speed * delta * 2.0)
    ship_pos += ship_vel * delta
    if ship_pos.length() > 10.0:
        last_move_dir = ship_vel.normalized() if ship_vel.length() > 5.0 else ship_pos.normalized()
    if desired_velocity.length() > 5.0:
        visual_rotation = lerp_angle(visual_rotation, desired_velocity.angle() + PI * 0.5, ROTATION_SPEED * delta)
    elif last_move_dir.length() > 0.01:
        visual_rotation = lerp_angle(visual_rotation, last_move_dir.angle() + PI * 0.5, ROTATION_SPEED * delta * 0.4)
    _resolve_ship_collision()

func _update_ship_trail(delta: float) -> void:
    if ship_vel.length() > 45.0:
        ship_trail_timer += delta
        if ship_trail_timer >= SHIP_TRAIL_INTERVAL:
            ship_trail_timer = 0.0
            ship_trail.append({
                "pos": ship_pos,
                "rot": visual_rotation,
                "alpha": 0.55,
            })
            if ship_trail.size() > SHIP_TRAIL_MAX:
                ship_trail.remove_at(0)
    else:
        ship_trail_timer = 0.0
    for idx in range(ship_trail.size() - 1, -1, -1):
        var trail := ship_trail[idx]
        trail["alpha"] = maxf(0.0, float(trail.get("alpha", 0.0)) - delta * 2.8)
        ship_trail[idx] = trail
        if float(trail.get("alpha", 0.0)) <= 0.02:
            ship_trail.remove_at(idx)

func _resolve_ship_collision() -> void:
    var my_grid := world_to_grid(ship_pos)
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            var check := Vector2i(my_grid.x + dx, my_grid.y + dy)
            if is_grid_empty(check):
                continue
            var block_center := grid_to_world(check)
            var collision_dist := BLOCK_SIZE * 0.5 + SHIP_RADIUS
            if ship_pos.distance_to(block_center) < collision_dist:
                var push_dir := (ship_pos - block_center).normalized()
                if push_dir.length() < 0.1:
                    push_dir = last_move_dir if last_move_dir.length() > 0.01 else Vector2.UP
                ship_pos = block_center + push_dir * (collision_dist + 2.0)
                ship_vel = push_dir * (40.0 if _has_core_upgrade("brake") else 120.0)
                if barriers_left > 0:
                    barriers_left -= 1
                    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK, -10.0, -0.08)
                else:
                    _finish_run(false, "The rig cracked against the shell.")
                return

func _update_zone_return(delta: float) -> void:
    var dist_to_spawn := ship_pos.distance_to(spawn_position)
    if not has_left_spawn and dist_to_spawn > return_zone_radius * 2.0:
        has_left_spawn = true
    if has_left_spawn and dist_to_spawn < return_zone_radius:
        return_zone_timer += delta
        if return_zone_timer >= RETURN_ZONE_DELAY:
            _finish_run(true, "Orbit transfer complete.")
    else:
        return_zone_timer = 0.0

func _update_combat(delta: float) -> void:
    attack_timer += delta
    if mega_timer > 0.0:
        _update_mega_beam(delta)
    else:
        mega_beam_hits.clear()
    var interval := float(runtime_stats.get("attack_interval", 0.8)) / (float(runtime_stats.get("overdrive_fire_mult", 3.0)) if overdrive_timer > 0.0 else 1.0)
    if attack_timer >= interval:
        attack_timer = 0.0
        _auto_fire_laser()
    if bool(runtime_stats.get("drone_enabled", false)):
        _update_drones(delta)

func _auto_fire_laser() -> void:
    var range_world := float(runtime_stats.get("attack_radius", 96.0))
    var max_targets := maxi(1, int(runtime_stats.get("multi_target", 1)))
    var candidates := _find_nearest_attack_targets(range_world, max_targets)
    if candidates.is_empty():
        last_attack_target = Vector2.ZERO
        multi_targets.clear()
        return

    last_attack_is_charged = false
    last_attack_is_crit = false
    if bool(runtime_stats.get("charged_enabled", false)):
        charged_shot_counter += 1
        if charged_shot_counter >= int(runtime_stats.get("charged_interval", 5)):
            charged_shot_counter = 0
            last_attack_is_charged = true

    var hit_count := mini(max_targets, candidates.size())
    var any_destroyed := false
    var visuals_dirty := false
    multi_targets.clear()
    for i in range(hit_count):
        var target: Dictionary = candidates[i]
        var pos: Vector2i = target.get("pos", Vector2i.ZERO)
        var world: Vector2 = target.get("world", Vector2.ZERO)
        if i == 0:
            last_attack_target = world
        else:
            multi_targets.append(world)
        hit_timers[pos] = HIT_FLASH_DURATION
        visuals_dirty = true
        var damage := _compute_laser_damage(pos)
        if last_attack_is_charged:
            damage += float(runtime_stats.get("attack_damage", 8.0)) * float(runtime_stats.get("charged_bonus", 2.0))
            last_attack_is_crit = true
        if bool(runtime_stats.get("crit_chance", 0.0) > 0.0) and rng.randf() < float(runtime_stats.get("crit_chance", 0.0)):
            damage += float(runtime_stats.get("attack_damage", 8.0)) * float(runtime_stats.get("crit_bonus", 2.0))
            last_attack_is_crit = true
        var result := _damage_block(pos, damage, true)
        if bool(result.get("destroyed", false)):
            any_destroyed = true
        if bool(runtime_stats.get("aoe_enabled", false)):
            for adj in CARDINAL_NEIGHBORS:
                var adj_pos: Vector2i = pos + adj
                if not is_grid_empty(adj_pos):
                    hit_timers[adj_pos] = HIT_FLASH_DURATION
                    visuals_dirty = true
                    var aoe_result := _damage_block(adj_pos, damage * 0.3, true)
                    if bool(aoe_result.get("destroyed", false)):
                        any_destroyed = true
    if visuals_dirty:
        _sync_planet_runtime_views(true, any_destroyed)
    attack_visible_timer = 0.08
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_LASER_CRIT if last_attack_is_crit else SoundEffectSettings.SOUND_EFFECT_TYPE.ON_LASER)
    if any_destroyed:
        _on_combo_hit()
    if bool(runtime_stats.get("chain_lightning_enabled", false)):
        _trigger_chain_lightning(Vector2i(candidates[0].get("pos", Vector2i.ZERO)), Vector2(candidates[0].get("world", Vector2.ZERO)))

func _find_nearest_attack_targets(range_world: float, max_targets: int) -> Array[Dictionary]:
    var candidates: Array[Dictionary] = []
    var range_sq := range_world * range_world
    var grid_range := int(ceil(range_world / BLOCK_SIZE)) + 1
    var my_grid := world_to_grid(ship_pos)
    for dx in range(-grid_range, grid_range + 1):
        for dy in range(-grid_range, grid_range + 1):
            var check := Vector2i(my_grid.x + dx, my_grid.y + dy)
            if is_grid_empty(check):
                continue
            var block_world := grid_to_world(check)
            var dist_sq := ship_pos.distance_squared_to(block_world)
            if dist_sq >= range_sq:
                continue
            var candidate := {"pos": check, "dist_sq": dist_sq, "world": block_world}
            var insert_idx := candidates.size()
            while insert_idx > 0 and dist_sq < float(candidates[insert_idx - 1].get("dist_sq", INF)):
                insert_idx -= 1
            if insert_idx >= max_targets and candidates.size() >= max_targets:
                continue
            candidates.insert(insert_idx, candidate)
            if candidates.size() > max_targets:
                candidates.resize(max_targets)
    return candidates

func _update_drones(delta: float) -> void:
    _ensure_drone_state()
    var count := int(runtime_stats.get("drone_count", 0))
    if not bool(runtime_stats.get("drone_enabled", false)) or count <= 0:
        drone_positions.clear()
        drone_timers.clear()
        drone_targets.clear()
        return
    var behind_dir := -last_move_dir
    if behind_dir.length() < 0.01:
        behind_dir = Vector2.DOWN
    var side_dir := Vector2(-behind_dir.y, behind_dir.x)
    var target_offsets: Array[Vector2] = []
    if count == 1:
        target_offsets.append(behind_dir * DRONE_BEHIND_DIST)
    elif count == 2:
        target_offsets.append(behind_dir * DRONE_BEHIND_DIST + side_dir * DRONE_SPACING * 0.6)
        target_offsets.append(behind_dir * DRONE_BEHIND_DIST - side_dir * DRONE_SPACING * 0.6)
    else:
        for index in range(count):
            var row := 0
            var in_row_idx := index
            var row_size := 1
            while in_row_idx >= row_size:
                in_row_idx -= row_size
                row += 1
                row_size = row + 1
            var row_dist := DRONE_BEHIND_DIST + row * DRONE_SPACING * 0.8
            var spread := DRONE_SPACING * 0.6 * (row + 1)
            var lateral := 0.0
            if row_size > 1:
                lateral = lerpf(-spread, spread, float(in_row_idx) / float(row_size - 1))
            target_offsets.append(behind_dir * row_dist + side_dir * lateral)
    for index in range(count):
        var target_local := target_offsets[index]
        drone_positions[index] = drone_positions[index].lerp(ship_pos + target_local, DRONE_FOLLOW_SPEED * delta)
        drone_timers[index] += delta
        var effective_rate := maxf(0.2, float(runtime_stats.get("drone_fire_interval", 0.9)))
        if drone_timers[index] >= effective_rate:
            drone_timers[index] = 0.0
            _fire_drone(index)

func _compute_laser_damage(pos: Vector2i) -> float:
    var block: Dictionary = blocks.get(pos, {})
    var damage := float(runtime_stats.get("attack_damage", 8.0))
    damage *= BALANCE.get_damage_multiplier_for_depth(runtime_stats, int(block.get("layer_depth", 1)))
    if bool(runtime_stats.get("resonance_enabled", false)):
        var depth_ratio := 1.0 - clampf(Vector2(float(pos.x), float(pos.y)).length() / float(max(1, planet_radius_cells)), 0.0, 1.0)
        damage += damage * depth_ratio * float(runtime_stats.get("resonance_bonus", 1.0))
    if int(block.get("type", 0)) == BlockType.CORE:
        damage *= float(runtime_stats.get("core_breaker_mult", 1.0))
        if _has_core_upgrade("core_focus"):
            damage *= 1.5
    return damage

func _damage_block(pos: Vector2i, damage: float, defer_visual_sync: bool = false) -> Dictionary:
    if is_grid_empty(pos):
        return {}
    var block_before: Dictionary = blocks.get(pos, {})
    var result: Dictionary = planet_data.damage_block(pos, damage, false, _core_unlocks_center())
    if bool(result.get("destroyed", false)):
        damaged_cells.erase(pos)
        persistent_destroyed_count += 1
        destroyed_cells_this_run[pos] = true
        nodes_mined += 1
        overdrive_kills += 1
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.PLANET_BREAK if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE else SoundEffectSettings.SOUND_EFFECT_TYPE.ON_ASTEROID_DESTORY, -6.0 if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE else -10.0)
        var world := grid_to_world(pos)
        _spawn_pickup(world, block_before)
        if int(result.get("type", BlockType.NORMAL)) == BlockType.ELECTRIC and bool(runtime_stats.get("electric_enabled", false)):
            _trigger_electric_chain(pos, world, defer_visual_sync)
        if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE and bool(result.get("final_core", false)):
            boss_defeated = true
            _finish_run(true, "The final core ruptured.")
            return result
        if bool(runtime_stats.get("mega_enabled", false)):
            mega_gauge += 1
            if mega_timer <= 0.0 and mega_gauge >= int(runtime_stats.get("mega_gauge_need", 30)):
                mega_gauge = 0
                mega_timer = float(runtime_stats.get("mega_duration", 5.0))
                mega_damage_timer = 0.0
        if bool(runtime_stats.get("shockwave_enabled", false)):
            shockwave_counter += 1
            if not shockwave_firing and shockwave_counter >= int(runtime_stats.get("shockwave_trigger_kills", 15)):
                shockwave_counter = 0
                _trigger_shockwave()
        if bool(runtime_stats.get("overdrive_enabled", false)) and overdrive_timer <= 0.0 and overdrive_kills >= int(runtime_stats.get("overdrive_kill_need", 50)):
            overdrive_kills = 0
            overdrive_timer = float(runtime_stats.get("overdrive_duration", 3.0))
    else:
        damaged_cells[pos] = float(planet_data.blocks.get(pos, {}).get("hp", 1.0))
    if not defer_visual_sync:
        _sync_planet_runtime_views(true, bool(result.get("destroyed", false)))
    return result

func _trigger_electric_chain(origin_pos: Vector2i, origin_world: Vector2, defer_visual_sync: bool = false) -> void:
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC, -8.0, -0.05)
    _on_combo_hit()
    var results: Array = planet_data.electric_chain(
        origin_pos,
        float(runtime_stats.get("attack_damage", 8.0)),
        int(runtime_stats.get("electric_range", 2)),
        int(runtime_stats.get("electric_chain_depth", 1)),
        0,
        _core_unlocks_center()
    )
    var destroyed_any := false
    for result in results:
        var next_pos: Vector2i = result.get("pos", Vector2i.ZERO)
        var next_world := grid_to_world(next_pos)
        electric_arcs.append({"from": origin_world, "to": next_world, "timer": ARC_DURATION})
        hit_timers[next_pos] = HIT_FLASH_DURATION
        if bool(result.get("destroyed", false)):
            destroyed_any = true
            persistent_destroyed_count += 1
            destroyed_cells_this_run[next_pos] = true
            nodes_mined += 1
            overdrive_kills += 1
            _spawn_pickup(next_world, {
                "resource": result.get("resource", 0.0),
                "type": result.get("type", BlockType.NORMAL),
                "layer_depth": 1
            })
            if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE and bool(result.get("final_core", false)):
                boss_defeated = true
                _finish_run(true, "The final core ruptured.")
                return
    if not defer_visual_sync:
        _sync_planet_runtime_views(true, destroyed_any)

func _trigger_chain_lightning(start_pos: Vector2i, start_world: Vector2) -> void:
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC_CRIT, -10.0, -0.04)
    var current_pos := start_pos
    var current_world := start_world
    var visited := {start_pos: true}
    var jumps := int(runtime_stats.get("chain_lightning_jumps", 3))
    var visuals_dirty := false
    var destroyed_any := false
    for _j in range(jumps):
        var total_weight := 0
        var chosen_pos := Vector2i.ZERO
        var chosen_world := Vector2.ZERO
        for dx in range(-4, 5):
            for dy in range(-4, 5):
                var dist: int = abs(dx) + abs(dy)
                if dist > 4 or dist == 0:
                    continue
                var check := Vector2i(current_pos.x + dx, current_pos.y + dy)
                if is_grid_empty(check) or visited.has(check):
                    continue
                var weight: int = 5 - dist
                total_weight += weight
                if rng.randi_range(1, total_weight) <= weight:
                    chosen_pos = check
                    chosen_world = grid_to_world(check)
        if total_weight <= 0:
            break
        var best_pos := chosen_pos
        var best_world := chosen_world
        chain_arcs.append({"from": current_world, "to": best_world, "timer": CHAIN_ARC_DURATION})
        hit_timers[best_pos] = HIT_FLASH_DURATION
        visuals_dirty = true
        var damage := _compute_laser_damage(best_pos) * 0.5
        var result := _damage_block(best_pos, damage, true)
        if bool(result.get("destroyed", false)):
            destroyed_any = true
        visited[best_pos] = true
        current_pos = best_pos
        current_world = best_world
    if visuals_dirty:
        _sync_planet_runtime_views(true, destroyed_any)

func _trigger_shockwave() -> void:
    shockwave_firing = true
    var my_grid := world_to_grid(ship_pos)
    var radius_cells := int(runtime_stats.get("shockwave_radius_cells", 6))
    var range_sq := radius_cells * radius_cells
    var changed_any := false
    for dx in range(-radius_cells, radius_cells + 1):
        for dy in range(-radius_cells, radius_cells + 1):
            if dx * dx + dy * dy > range_sq:
                continue
            var pos := Vector2i(my_grid.x + dx, my_grid.y + dy)
            if is_grid_empty(pos):
                continue
            if rng.randf() < 0.08:
                if planet_data.convert_to_gold(pos):
                    gold_convert_timers[pos] = GOLD_CONVERT_DURATION
                    changed_any = true
    shockwave_firing = false
    var max_radius := float(radius_cells) * BLOCK_SIZE
    if shockwave_rings.size() >= MAX_SHOCKWAVE_RINGS:
        shockwave_rings.remove_at(0)
    shockwave_rings.append({"radius": 5.0, "max_radius": max_radius, "alpha": 0.8})
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.SUPERNOVA, -10.0, -0.1)
    _sync_planet_runtime_views(true, changed_any)

func _update_mega_beam(delta: float) -> void:
    var mouse_world := get_global_mouse_position()
    mega_direction = (mouse_world - ship_pos).normalized() if mouse_world.distance_to(ship_pos) > 10.0 else last_move_dir
    if mega_direction.length() < 0.01:
        mega_direction = Vector2.UP
    mega_beam_hits.clear()
    var max_dist := float(runtime_stats.get("attack_radius", 96.0)) * 1.5
    mega_beam_end = ship_pos + mega_direction * max_dist
    mega_damage_timer += delta
    if mega_damage_timer < MEGA_DAMAGE_INTERVAL:
        return
    mega_damage_timer = 0.0
    var step_size := BLOCK_SIZE * 0.4
    var steps := int(max_dist / step_size)
    var visited := {}
    var visuals_dirty := false
    var destroyed_any := false
    for step in range(steps):
        var point := ship_pos + mega_direction * (step_size * float(step + 1))
        var cell := world_to_grid(point)
        if visited.has(cell):
            continue
        visited[cell] = true
        if is_grid_empty(cell):
            continue
        visuals_dirty = true
        var damage := _compute_laser_damage(cell)
        var result := _damage_block(cell, damage, true)
        if bool(result.get("destroyed", false)):
            destroyed_any = true
    if visuals_dirty:
        _sync_planet_runtime_views(true, destroyed_any)

func _spawn_pickup(world_pos: Vector2, block: Dictionary) -> void:
    var payout := float(block.get("resource", 1.0)) + float(runtime_stats.get("resource_flat", 0.0))
    if int(block.get("type", 0)) == BlockType.GOLD:
        payout += float(runtime_stats.get("gold_bonus_flat", 0.0))
    payout *= BALANCE.get_resource_multiplier_for_depth(runtime_stats, int(block.get("layer_depth", 1)))
    if bool(runtime_stats.get("combo_enabled", false)):
        payout *= 1.0 + float(runtime_stats.get("combo_bonus_per_stack", 0.0)) * float(current_combo)
    var money := int(round(payout))
    if bool(runtime_stats.get("instant_collect", false)) or ship_pos.distance_to(world_pos) <= float(runtime_stats.get("pickup_radius", 64.0)):
        _collect_pickup(money, 1)
        return
    if pickups.size() >= MAX_WORLD_PICKUPS:
        _collect_pickup(money, 1)
        return
    pickups.append({
        "position": world_pos,
        "money": money,
        "cargo": 1,
        "drift": Vector2(rng.randf_range(-PICKUP_DRIFT, PICKUP_DRIFT), rng.randf_range(-PICKUP_DRIFT, PICKUP_DRIFT)),
    })

func _update_pickups(delta: float) -> void:
    for idx in range(pickups.size() - 1, -1, -1):
        var pickup := pickups[idx]
        pickup["position"] = Vector2(pickup.get("position", Vector2.ZERO)) + Vector2(pickup.get("drift", Vector2.ZERO)) * delta
        pickups[idx] = pickup
        var collect := Vector2(pickup.get("position", Vector2.ZERO)).distance_to(ship_pos) <= float(runtime_stats.get("pickup_radius", 64.0))
        if not collect:
            for drone_pos in drone_positions:
                if Vector2(pickup.get("position", Vector2.ZERO)).distance_to(drone_pos) <= float(runtime_stats.get("pickup_radius", 64.0)):
                    collect = true
                    break
        if collect:
            _collect_pickup(int(pickup.get("money", 0)), int(pickup.get("cargo", 1)))
            pickups.remove_at(idx)

func _collect_pickup(money: int, cargo: int) -> void:
    if cargo_units + cargo > int(runtime_stats.get("cargo_capacity", 15)):
        return
    cargo_units += cargo
    cargo_money += money

func _update_drone_visuals(_delta: float) -> void:
    if mega_timer <= 0.0:
        mega_beam_hits.clear()

func _sync_planet_runtime_views(mark_renderer_dirty: bool = false, rebuild_fill: bool = false) -> void:
    blocks = planet_data.blocks
    exposed_edges = planet_data.exposed_edges
    if mark_renderer_dirty:
        planet_renderer.mark_dirty(rebuild_fill)

func _reset_drone_state() -> void:
    drone_positions.clear()
    drone_timers.clear()
    drone_targets.clear()
    if not bool(runtime_stats.get("drone_enabled", false)):
        return
    var count := int(runtime_stats.get("drone_count", 0))
    drone_positions.resize(count)
    drone_timers.resize(count)
    drone_targets.resize(count)
    var base_interval := maxf(0.2, float(runtime_stats.get("drone_fire_interval", 0.9)))
    for index in range(count):
        drone_positions[index] = ship_pos + Vector2(0.0, DRONE_BEHIND_DIST)
        drone_timers[index] = rng.randf() * base_interval
        drone_targets[index] = Vector2.ZERO

func _ensure_drone_state() -> void:
    var count := int(runtime_stats.get("drone_count", 0))
    if drone_positions.size() == count and drone_timers.size() == count and drone_targets.size() == count:
        return
    _reset_drone_state()

func _fire_drone(drone_idx: int) -> void:
    if drone_idx < 0 or drone_idx >= drone_positions.size():
        return
    var drone_world := drone_positions[drone_idx]
    var target_cells := _find_targets_near_world(drone_world, DRONE_RANGE, int(runtime_stats.get("drone_pierce", 1)))
    if target_cells.is_empty():
        return
    var first_world := grid_to_world(target_cells[0])
    drone_targets[drone_idx] = first_world
    for target_grid in target_cells:
        var damage := float(runtime_stats.get("drone_damage", 8.0))
        if bool(runtime_stats.get("drone_sync_unlock", false)):
            damage += float(runtime_stats.get("attack_damage", 8.0)) * float(runtime_stats.get("drone_sync_ratio", 0.15))
        if rng.randf() < float(runtime_stats.get("drone_crit_chance", 0.0)):
            damage += float(runtime_stats.get("drone_damage", 8.0)) * float(runtime_stats.get("drone_crit_bonus", 2.0))
        var result := _damage_block(target_grid, damage)
        if bool(result.get("destroyed", false)):
            _on_combo_hit()
        drone_beams.append({"from": drone_world, "to": grid_to_world(target_grid), "timer": DRONE_BEAM_DURATION})

func _on_combo_hit() -> void:
    if not bool(runtime_stats.get("combo_enabled", false)):
        return
    current_combo = mini(current_combo + 1, 50)
    combo_peak = max(combo_peak, current_combo)
    combo_timer = 1.5

func _finish_run(returned: bool, reason: String) -> void:
    if run_finished:
        return
    run_finished = true
    if planet_data != null:
        planet_data.revert_converted_gold()
        blocks = planet_data.blocks
        exposed_edges = planet_data.exposed_edges
        persistent_destroyed_count = max(0, total_planet_blocks - planet_data.get_total_blocks())
        planet_renderer.mark_dirty()
    var keep_percent := 1.0 if returned else float(runtime_stats.get("salvage_keep", 0.0))
    var total_money := cargo_money
    for pickup in pickups:
        total_money += int(pickup.get("money", 0))
    var money_award := int(round(float(total_money) * keep_percent))
    summary_overlay.visible = true
    summary_save_anim_time = 0.0
    summary_save_pending = true
    summary_save_phase = "prepare"
    summary_label.text = "[center]%s\n\nOrbit Tier %d\nBlocks mined: %d\nCores destroyed: %d\nPersistent clear: %.1f%%\nCash banked: $%d\nCore shards banked: %d\nCombo peak: %d\nBarriers left: %d[/center]" % [
        reason,
        current_depth_level,
        nodes_mined,
        cores_destroyed_this_run,
        _get_persistent_clear_percent(),
        money_award,
        core_currency_earned_this_run,
        combo_peak,
        barriers_left
    ]
    if summary_return_button != null:
        summary_return_button.disabled = true
        summary_return_button.text = "Saving..."
    if summary_status_label != null:
        summary_status_label.text = "Preparing save..."
    call_deferred("_begin_finish_save", money_award, reason)

func _save_planet_snapshot() -> void:
    if run_finished or planet_data == null:
        return
    persistent_data["boss_defeated"] = boss_defeated
    persistent_data["destroyed_cells"] = []
    PROGRESS.save_data(persistent_data)
    var snapshot: Dictionary = planet_data.build_dirty_save_data()
    var dirty_sections: Dictionary = snapshot.get("sections", {})
    if not dirty_sections.is_empty():
        PROGRESS.save_planet_state(snapshot)
        planet_data.mark_saved_sections_clean(dirty_sections.keys())
    PROGRESS.save_runtime_planet_data(current_depth_level, planet_data)

func _update_finish_summary(delta: float) -> void:
    if not summary_save_pending:
        return
    summary_save_anim_time += delta
    var dots := ".".repeat(int(floor(summary_save_anim_time * 3.0)) % 4)
    if summary_status_label != null:
        if summary_save_phase == "prepare":
            summary_status_label.text = "Preparing save%s" % dots
        else:
            summary_status_label.text = "Saving planet state%s" % dots
    if summary_save_phase == "thread" and PROGRESS.update_async_planet_state_save():
        summary_save_pending = false
        summary_save_phase = "done"
        if summary_return_button != null:
            summary_return_button.disabled = false
            summary_return_button.text = "Return To Upgrades"
        if summary_status_label != null:
            summary_status_label.text = "Save complete." if PROGRESS.was_async_planet_state_save_successful() else "Save failed. Returning may lose progress."

func _begin_finish_save(money_award: int, reason: String) -> void:
    await _finish_run_save_async(money_award, reason)

func _finish_run_save_async(money_award: int, reason: String) -> void:
    var planet_snapshot: Dictionary = {}
    var has_sector_updates := false
    if planet_data != null:
        planet_snapshot = await planet_data.build_save_data_async(get_tree(), Callable(self, "_on_finish_save_progress"))
        has_sector_updates = not Dictionary(planet_snapshot.get("sections", {})).is_empty()
    PROGRESS.apply_run_results({
        "money": money_award,
        "core_currency": core_currency_earned_this_run,
        "cores_destroyed": cores_destroyed_this_run,
        "depth_level": current_depth_level,
        "nodes_broken": nodes_mined,
        "boss_defeated": boss_defeated,
        "destroyed_cells": [],
        "planet_state": planet_snapshot if has_sector_updates else {},
        "defer_planet_state_save": has_sector_updates,
        "summary_text": "%s Banked $%d." % [reason, money_award],
    })
    if has_sector_updates:
        PROGRESS.start_async_planet_state_save(planet_snapshot)
        if planet_data != null:
            planet_data.mark_saved_sections_clean(planet_snapshot.get("sections", {}).keys())
        summary_save_phase = "thread"
        summary_save_pending = PROGRESS.is_async_planet_state_save_pending()
    else:
        summary_save_phase = "done"
        summary_save_pending = false
    PROGRESS.save_runtime_planet_data(current_depth_level, planet_data)
    persistent_data = PROGRESS.load_data()
    if not summary_save_pending:
        if summary_return_button != null:
            summary_return_button.disabled = false
            summary_return_button.text = "Return To Upgrades"
        if summary_status_label != null:
            summary_status_label.text = "Save complete."

func _on_finish_save_progress(progress: float) -> void:
    if not summary_save_pending:
        return
    summary_save_phase = "prepare"
    if summary_status_label != null:
        summary_status_label.text = "Preparing save %d%%" % int(round(progress * 100.0))

func _persist_destroyed_cells() -> void:
    persistent_data["destroyed_cells"] = []
    persistent_data["boss_defeated"] = boss_defeated
    PROGRESS.save_data(persistent_data)

func _refresh_hud() -> void:
    timer_label.text = "Cargo: %d / %d" % [cargo_units, int(runtime_stats.get("cargo_capacity", 15))]
    cargo_label.text = "Fuel: %.1fs  |  Return Zone %.1fs" % [time_left, maxf(0.0, RETURN_ZONE_DELAY - return_zone_timer)]
    wallet_label.text = "Haul: $%d  |  Wallet: $%d" % [cargo_money, int(persistent_data.get("wallet", 0))]
    layer_label.text = "Orbit Tier %d  |  %s  |  Clear %.1f%%" % [current_depth_level, current_layer_name, _get_persistent_clear_percent()]
    status_label.text = "Barriers %d  |  Drones %d  |  Mega %d/%d  |  Alive Cores %d/%d" % [barriers_left, int(runtime_stats.get("drone_count", 0)), mega_gauge, int(runtime_stats.get("mega_gauge_need", 30)), planet_data.get_alive_cores() if planet_data != null else 0, planet_data.get_total_cores() if planet_data != null else 0]
    system_label.text = "Combo %d  |  Overdrive %.1fs  |  Core shards %d  |  Move: Mouse / WASD" % [current_combo, overdrive_timer, int(persistent_data.get("core_currency", 0)) + core_currency_earned_this_run]
    if fps_label != null:
        _update_perf_debug(0.0)

func _update_perf_debug(frame_delta: float) -> void:
    if fps_label == null:
        return
    var frame_ms := frame_delta * 1000.0 if frame_delta > 0.0 else (1000.0 / maxf(float(max(1, Engine.get_frames_per_second())), 1.0))
    var process_ms := float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0
    var physics_ms := float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) * 1000.0
    if perf_graph != null and perf_graph.has_method("push_sample"):
        perf_graph.call("push_sample", frame_ms, process_ms, physics_ms)
    var limit_hint: String = str(perf_graph.call("get_hint_text")) if perf_graph != null and perf_graph.has_method("get_hint_text") else "Unknown"
    var season_lines: Array[String] = []
    var damage_mults: Array = runtime_stats.get("season_damage_mults", [1.0, 1.0, 1.0, 1.0])
    var zone_labels: Array[String] = ["Spring", "Summer", "Autumn", "Winter"]
    for idx in range(mini(4, damage_mults.size())):
        var mult: float = float(damage_mults[idx])
        if mult <= 1.0:
            continue
        var zone_name: String = zone_labels[idx]
        season_lines.append("%s %+d%%" % [zone_name.left(2), int(round((mult - 1.0) * 100.0))])
    var base_text := "FPS: %d  |  Frame %.1fms  |  CPU %.1fms  |  Phys %.1fms  |  %s" % [
        Engine.get_frames_per_second(),
        frame_ms,
        process_ms,
        physics_ms,
        str(limit_hint)
    ]
    if season_lines.is_empty():
        fps_label.text = base_text
    else:
        fps_label.text = "%s  |  Debug Dmg: %s" % [base_text, ", ".join(season_lines)]

func _return_to_upgrades() -> void:
    _save_planet_snapshot()
    SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _tick_timer_dict(dict_ref: Dictionary, delta: float) -> void:
    var expired: Array = []
    for key_variant in dict_ref.keys():
        dict_ref[key_variant] = maxf(0.0, float(dict_ref[key_variant]) - delta)
        if float(dict_ref[key_variant]) <= 0.0:
            expired.append(key_variant)
    for key_variant in expired:
        dict_ref.erase(key_variant)

func _tick_effect_array(items: Array[Dictionary], delta: float) -> void:
    for idx in range(items.size() - 1, -1, -1):
        var item := items[idx]
        item["timer"] = maxf(0.0, float(item.get("timer", 0.0)) - delta)
        items[idx] = item
        if float(item.get("timer", 0.0)) <= 0.0:
            items.remove_at(idx)

func _find_targets_near_world(world_pos: Vector2, radius_world: float, limit: int) -> Array[Vector2i]:
    var found: Array[Vector2i] = []
    if limit <= 0:
        return found
    var center_grid := world_to_grid(world_pos)
    var grid_range := int(ceil(radius_world / BLOCK_SIZE)) + 1
    var radius_sq := radius_world * radius_world
    var candidates: Array[Dictionary] = []
    for dx in range(-grid_range, grid_range + 1):
        for dy in range(-grid_range, grid_range + 1):
            var check := Vector2i(center_grid.x + dx, center_grid.y + dy)
            if is_grid_empty(check):
                continue
            var dist_sq := world_pos.distance_squared_to(grid_to_world(check))
            if dist_sq > radius_sq:
                continue
            var insert_idx := candidates.size()
            while insert_idx > 0 and dist_sq < float(candidates[insert_idx - 1].get("dist_sq", INF)):
                insert_idx -= 1
            if insert_idx >= limit and candidates.size() >= limit:
                continue
            candidates.insert(insert_idx, {"pos": check, "dist_sq": dist_sq})
            if candidates.size() > limit:
                candidates.resize(limit)
    for idx in range(mini(limit, candidates.size())):
        found.append(candidates[idx].get("pos", Vector2i.ZERO))
    return found

func _find_nearest_block(origin: Vector2i, range_cells: int, visited: Dictionary) -> Vector2i:
    var best := Vector2i(999999, 999999)
    var best_dist := INF
    for row in range(origin.y - range_cells, origin.y + range_cells + 1):
        for col in range(origin.x - range_cells, origin.x + range_cells + 1):
            var check := Vector2i(col, row)
            if is_grid_empty(check) or visited.has(check):
                continue
            var dist := Vector2(float(col - origin.x), float(row - origin.y)).length_squared()
            if dist < best_dist:
                best_dist = dist
                best = check
    return best

func _block_hp_for(layer_depth: int, block_type: int) -> float:
    var layer := BALANCE.get_layer_for_depth(min(layer_depth, BALANCE.MAX_DEPTH_LEVEL))
    var hp := float(layer.get("health", 20.0))
    if block_type == BlockType.GOLD:
        hp *= 1.35
    elif block_type == BlockType.ELECTRIC:
        hp *= 1.2
    elif block_type == BlockType.CORE:
        hp *= 8.0
    return hp

func _block_resource_for(layer_depth: int, block_type: int) -> float:
    var layer := BALANCE.get_layer_for_depth(min(layer_depth, BALANCE.MAX_DEPTH_LEVEL))
    var res := float(layer.get("value", 4))
    if block_type == BlockType.GOLD:
        res *= 4.5
    elif block_type == BlockType.CORE:
        res *= 18.0
    return res

func grid_to_world(grid: Vector2i) -> Vector2:
    return planet_data.grid_to_world(grid) if planet_data != null else Vector2(float(grid.x), float(grid.y)) * BLOCK_SIZE + Vector2.ONE * (BLOCK_SIZE * 0.5)

func world_to_grid(world_pos: Vector2) -> Vector2i:
    return planet_data.world_to_grid(world_pos) if planet_data != null else Vector2i(int(floor(world_pos.x / BLOCK_SIZE)), int(floor(world_pos.y / BLOCK_SIZE)))

func is_grid_empty(grid: Vector2i) -> bool:
    return planet_data == null or not planet_data.has_block(grid)

func get_block_hp_ratio(grid: Vector2i) -> float:
    var block: Dictionary = blocks.get(grid, {})
    if block.is_empty():
        return 1.0
    var hp := float(damaged_cells.get(grid, block.get("hp", 1.0)))
    return clampf(hp / maxf(1.0, float(block.get("max_hp", 1.0))), 0.0, 1.0)

func _rebuild_exposed_edges() -> void:
    if planet_data == null:
        exposed_edges.clear()
        return
    exposed_edges = planet_data.exposed_edges

func _refresh_exposed_edges_around(center: Vector2i) -> void:
    if planet_data == null:
        return
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            var pos := Vector2i(center.x + dx, center.y + dy)
            if planet_data.has_block(pos):
                exposed_edges[pos] = planet_data.exposed_edges.get(pos, 0)
            else:
                exposed_edges.erase(pos)

func _update_exposed_edge_for(grid: Vector2i) -> void:
    if planet_data == null or not planet_data.has_block(grid):
        exposed_edges.erase(grid)
        return
    var mask := int(planet_data.exposed_edges.get(grid, 0))
    if mask == 0:
        exposed_edges.erase(grid)
    else:
        exposed_edges[grid] = mask

func _get_persistent_clear_percent() -> float:
    return 100.0 * float(persistent_destroyed_count) / float(max(1, total_planet_blocks))

func _on_core_destroyed(core: Dictionary) -> void:
    cores_destroyed_this_run += 1
    core_currency_earned_this_run += 1
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.PLANET_BREAK, -2.0, -0.08)
    planet_renderer.mark_dirty()
    if int(core.get("id", -1)) == int(PLANET_DATA_SCRIPT.FINAL_CORE_ID):
        boss_defeated = true

func _update_core_behaviors(delta: float) -> void:
    if planet_data == null:
        return
    var behaviors: Dictionary = planet_data.get_active_core_behaviors()
    if bool(behaviors.get("defense_blocks", false)) or bool(behaviors.get("final_rage", false)):
        core_defense_timer -= delta
        if core_defense_timer <= 0.0:
            core_defense_timer = DEFENSE_BLOCK_INTERVAL * (0.6 if bool(behaviors.get("final_rage", false)) else 1.0)
            if planet_data.spawn_defense_blocks() > 0:
                blocks = planet_data.blocks
                exposed_edges = planet_data.exposed_edges
                planet_renderer.mark_dirty()
    if bool(behaviors.get("shockwave", false)) or bool(behaviors.get("final_rage", false)):
        core_shockwave_timer -= delta
        if core_shockwave_timer <= 0.0:
            core_shockwave_timer = CORE_SHOCKWAVE_INTERVAL * (0.5 if bool(behaviors.get("final_rage", false)) else 1.0)
            _fire_core_shockwaves()

func _fire_core_shockwaves() -> void:
    if planet_data == null:
        return
    for core in planet_data.get_shockwave_cores():
        var world_center := grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        var push_radius := float(planet_data.get_effective_influence_radius(core)) * BLOCK_SIZE * 1.5
        if shockwave_rings.size() >= MAX_SHOCKWAVE_RINGS:
            shockwave_rings.remove_at(0)
        shockwave_rings.append({"radius": 5.0, "max_radius": push_radius, "alpha": 0.8})
        var dist := ship_pos.distance_to(world_center)
        if dist < push_radius and dist > 0.0:
            var push_dir := (ship_pos - world_center).normalized()
            ship_vel += push_dir * CORE_SHOCKWAVE_PUSH * (1.0 - dist / push_radius)

func _update_core_attacks(delta: float) -> void:
    if planet_data == null:
        return
    _update_summer_lasers(delta)
    _update_autumn_debris(delta)
    _update_winter_cross_lasers(delta)

func _is_ship_in_core_influence(core: Dictionary) -> bool:
    var radius: float = float(planet_data.get_effective_influence_radius(core)) * BLOCK_SIZE
    return ship_pos.distance_squared_to(grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))) <= radius * radius

func _update_summer_lasers(delta: float) -> void:
    for core in planet_data.cores:
        if not bool(core.alive) or int(core.zone) != PLANET_DATA_SCRIPT.Zone.SUMMER:
            continue
        var cid: int = int(core.id)
        var is_boss: bool = str(core.role) == "boss" or str(core.role) == "final"
        if not _is_ship_in_core_influence(core):
            summer_laser_states.erase(cid)
            continue
        var hp_ratio: float = planet_data.get_core_hp_ratio(core)
        var interval := SUMMER_LASER_INTERVAL_OUTER
        if is_boss:
            interval = SUMMER_LASER_INTERVAL_BOSS_LOW if hp_ratio <= SUMMER_LASER_BOSS_HP_THRESHOLD else SUMMER_LASER_INTERVAL_BOSS
        var state: Dictionary = summer_laser_states.get(cid, {
            "state": "idle",
            "timer": interval,
            "warn_time": SUMMER_LASER_WARN_BOSS if is_boss else SUMMER_LASER_WARN_OUTER,
            "origin": grid_to_world(Vector2i(int(core.center.x), int(core.center.y))),
            "dir": Vector2.RIGHT,
            "interval": interval,
            "fire_duration": SUMMER_LASER_FIRE_DURATION,
            "hit_timer": 0.0,
        })
        state["interval"] = interval
        state["origin"] = grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        state["timer"] = float(state.get("timer", interval)) - delta
        match str(state.get("state", "idle")):
            "idle":
                if float(state.get("timer", 0.0)) <= 0.0:
                    state["state"] = "warning"
                    state["timer"] = float(state.get("warn_time", SUMMER_LASER_WARN_OUTER))
                    state["dir"] = (ship_pos - Vector2(state["origin"])).normalized()
            "warning":
                if float(state.get("timer", 0.0)) <= 0.0:
                    state["state"] = "firing"
                    state["timer"] = float(state.get("fire_duration", SUMMER_LASER_FIRE_DURATION))
                    state["dir"] = (ship_pos - Vector2(state["origin"])).normalized()
            "firing":
                _check_summer_laser_hit(state)
                if float(state.get("timer", 0.0)) <= 0.0:
                    state["state"] = "idle"
                    state["timer"] = interval
        summer_laser_states[cid] = state

func _check_summer_laser_hit(state: Dictionary) -> void:
    if float(state.get("hit_timer", 0.0)) > 0.0:
        return
    var origin: Vector2 = state.get("origin", Vector2.ZERO)
    var dir: Vector2 = Vector2(state.get("dir", Vector2.RIGHT)).normalized()
    if dir.length() < 0.01:
        return
    var length: float = BLOCK_SIZE * 40.0
    var end: Vector2 = origin + dir * length
    var ab: Vector2 = end - origin
    var t: float = clampf((ship_pos - origin).dot(ab) / maxf(ab.dot(ab), 1.0), 0.0, 1.0)
    var closest: Vector2 = origin + ab * t
    if ship_pos.distance_to(closest) <= SUMMER_LASER_WIDTH * 0.5 + SHIP_RADIUS:
        state["hit_timer"] = WINTER_CROSS_LASER_HIT_COOLDOWN
        _apply_ship_hazard_hit((ship_pos - origin).normalized(), "The rig was lanced by a summer core.")

func _update_autumn_debris(delta: float) -> void:
    if planet_data == null:
        return
    for core in planet_data.cores:
        if not bool(core.alive) or int(core.zone) != PLANET_DATA_SCRIPT.Zone.AUTUMN:
            continue
        if not _is_ship_in_core_influence(core):
            continue
        var cid: int = int(core.id)
        var is_boss: bool = str(core.role) == "boss" or str(core.role) == "final"
        var hp_ratio: float = planet_data.get_core_hp_ratio(core)
        var timer_key := "debris_%d" % cid
        var timer: float = float(autumn_debris_timers.get(timer_key, 0.0)) - delta
        if timer <= 0.0 and autumn_debris.size() < AUTUMN_DEBRIS_MAX_ACTIVE:
            timer = AUTUMN_DEBRIS_INTERVAL_OUTER
            var spawn_count := AUTUMN_DEBRIS_COUNT_OUTER
            if is_boss:
                if hp_ratio <= SUMMER_LASER_BOSS_HP_THRESHOLD:
                    timer = AUTUMN_DEBRIS_INTERVAL_BOSS_LOW
                    spawn_count = AUTUMN_DEBRIS_COUNT_BOSS_LOW
                else:
                    timer = AUTUMN_DEBRIS_INTERVAL_BOSS
                    spawn_count = AUTUMN_DEBRIS_COUNT_BOSS
            _spawn_autumn_debris(core, spawn_count)
        autumn_debris_timers[timer_key] = timer
    for idx in range(autumn_debris.size() - 1, -1, -1):
        var debris: Dictionary = autumn_debris[idx]
        var pos: Vector2 = debris.get("pos", Vector2.ZERO)
        var vel: Vector2 = debris.get("vel", Vector2.ZERO)
        var desired: Vector2 = (ship_pos - pos).normalized() * AUTUMN_DEBRIS_SPEED
        vel = vel.lerp(desired, clampf(delta * AUTUMN_DEBRIS_HOMING_STRENGTH, 0.0, 1.0))
        pos += vel * delta
        debris["pos"] = pos
        debris["vel"] = vel
        autumn_debris[idx] = debris
        if pos.distance_to(ship_pos) <= AUTUMN_DEBRIS_HIT_RADIUS + SHIP_RADIUS:
            autumn_debris.remove_at(idx)
            _apply_ship_hazard_hit((ship_pos - pos).normalized(), "The rig was shredded by autumn debris.")

func _spawn_autumn_debris(core: Dictionary, count: int) -> void:
    var origin: Vector2 = grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
    for _idx in range(count):
        var angle: float = rng.randf() * TAU
        autumn_debris.append({
            "pos": origin,
            "vel": Vector2.from_angle(angle) * AUTUMN_DEBRIS_SPEED,
            "life": AUTUMN_DEBRIS_LIFETIME,
            "core_id": int(core.id),
        })

func _update_winter_cross_lasers(delta: float) -> void:
    for core in planet_data.cores:
        if not bool(core.alive) or int(core.zone) != PLANET_DATA_SCRIPT.Zone.WINTER:
            continue
        var cid: int = int(core.id)
        if not _is_ship_in_core_influence(core):
            winter_cross_lasers.erase(cid)
            continue
        var hp_ratio: float = planet_data.get_core_hp_ratio(core)
        var is_boss: bool = str(core.role) == "boss" or str(core.role) == "final"
        var speed := WINTER_CROSS_LASER_SPEED_BASE
        if hp_ratio < 1.0:
            speed = WINTER_CROSS_LASER_SPEED_BOSS_LOW if is_boss and hp_ratio <= WINTER_CROSS_LASER_BOSS_HP_THRESHOLD else WINTER_CROSS_LASER_SPEED_ATTACKED
        var beam_length: float = float(planet_data.get_effective_influence_radius(core)) * BLOCK_SIZE
        var core_pixel_radius: float = float(int(core.get("size", 3))) * 0.5 * BLOCK_SIZE
        var edge_ratio: float = clampf(core_pixel_radius / maxf(beam_length, 1.0) + 0.05, 0.1, 0.4)
        var state: Dictionary = winter_cross_lasers.get(cid, {
            "angle": rng.randf() * TAU,
            "origin": grid_to_world(Vector2i(int(core.center.x), int(core.center.y))),
            "length": beam_length,
            "speed": speed,
            "hit_timer": 0.0,
            "core_edge_ratio": edge_ratio,
            "gaps": [],
        })
        if Array(state.get("gaps", [])).is_empty():
            var gaps: Array = []
            for _arm_i in range(4):
                gaps.append({"pos": rng.randf_range(edge_ratio, WINTER_CROSS_LASER_GAP_MAX), "dir": 1.0 if rng.randf() > 0.5 else -1.0})
            state["gaps"] = gaps
        state["origin"] = grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        state["length"] = beam_length
        state["speed"] = speed
        state["core_edge_ratio"] = edge_ratio
        state["angle"] = float(state.get("angle", 0.0)) + speed * delta
        var gaps_state: Array = state.get("gaps", [])
        for gap in gaps_state:
            gap["pos"] = clampf(float(gap.get("pos", edge_ratio)) + float(gap.get("dir", 1.0)) * WINTER_CROSS_LASER_GAP_SLIDE_SPEED * delta, edge_ratio, WINTER_CROSS_LASER_GAP_MAX)
            if is_equal_approx(float(gap["pos"]), edge_ratio) or is_equal_approx(float(gap["pos"]), WINTER_CROSS_LASER_GAP_MAX):
                gap["dir"] = -float(gap.get("dir", 1.0))
        state["gaps"] = gaps_state
        _check_winter_cross_laser_hit(state)
        winter_cross_lasers[cid] = state

func _check_winter_cross_laser_hit(state: Dictionary) -> void:
    if float(state.get("hit_timer", 0.0)) > 0.0:
        return
    var origin: Vector2 = state.get("origin", Vector2.ZERO)
    var length: float = float(state.get("length", 0.0))
    var edge_ratio: float = float(state.get("core_edge_ratio", 0.1))
    var gaps: Array = state.get("gaps", [])
    for arm_i in range(4):
        var arm_angle: float = float(state.get("angle", 0.0)) + float(arm_i) * PI * 0.5
        var arm_dir := Vector2.from_angle(arm_angle)
        var end := origin + arm_dir * length
        var ab := end - origin
        var t: float = clampf((ship_pos - origin).dot(ab) / maxf(ab.dot(ab), 1.0), 0.0, 1.0)
        var closest := origin + ab * t
        if ship_pos.distance_to(closest) > WINTER_CROSS_LASER_WIDTH * 0.5 + SHIP_RADIUS:
            continue
        if t < edge_ratio:
            continue
        if arm_i < gaps.size():
            var gap: Dictionary = gaps[arm_i]
            var gap_center: float = float(gap.get("pos", edge_ratio))
            if t >= gap_center - WINTER_CROSS_LASER_GAP_SIZE * 0.5 and t <= gap_center + WINTER_CROSS_LASER_GAP_SIZE * 0.5:
                continue
        state["hit_timer"] = WINTER_CROSS_LASER_HIT_COOLDOWN
        _apply_ship_hazard_hit((ship_pos - origin).normalized(), "The rig was caught in a winter cross-laser.")
        return

func _apply_ship_hazard_hit(push_dir: Vector2, reason: String) -> void:
    if run_finished:
        return
    var applied_dir := push_dir if push_dir.length() > 0.01 else Vector2.UP
    ship_vel += applied_dir * CORE_HAZARD_KNOCKBACK
    if barriers_left > 0:
        barriers_left -= 1
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK, -10.0, -0.05)
        return
    _finish_run(false, reason)

func _has_core_upgrade(upgrade_id: String) -> bool:
    var purchased: Array = persistent_data.get("purchased_core_upgrades", [])
    return upgrade_id in purchased

func _core_unlocks_center() -> bool:
    return bool(persistent_data.get("free_planet_mode", false)) or _has_core_upgrade("center_unlock")

func scene_to_spawn_ring(target_grid: Vector2i) -> Vector2:
    var dir := grid_to_world(target_grid).normalized()
    if dir.length() < 0.01:
        dir = Vector2.UP
    return dir * (float(planet_radius_cells) + 7.0) * BLOCK_SIZE

func get_visual_power() -> float:
    var damage := float(runtime_stats.get("attack_damage", 8.0))
    if damage <= 1.0:
        return 0.0
    return clampf(log(damage) / log(150.0), 0.0, 1.0)

func _update_current_layer_name() -> void:
    var grid := world_to_grid(ship_pos)
    var radial_ratio := 1.0 - clampf(Vector2(float(grid.x), float(grid.y)).length() / float(max(1, PLANET_RADIUS_CELLS)), 0.0, 1.0)
    var layer_depth := clampi(1 + int(floor(radial_ratio * float(current_depth_level))), 1, current_depth_level)
    current_layer_name = str(BALANCE.get_layer_for_depth(min(layer_depth, BALANCE.MAX_DEPTH_LEVEL)).get("name", "Orbital Shell"))
