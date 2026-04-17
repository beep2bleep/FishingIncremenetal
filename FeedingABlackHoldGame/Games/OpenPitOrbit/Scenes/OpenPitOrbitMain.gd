extends Node2D
class_name OpenPitOrbitMain

const BALANCE := preload("res://Games/OpenPitOrbit/OpenPitOrbitBalance.gd")
const PROGRESS := preload("res://Games/OpenPitOrbit/OpenPitOrbitProgress.gd")
const PLANET_DATA_SCRIPT := preload("res://Games/OpenPitOrbit/OpenPitOrbitPlanetData.gd")
const PLANET_RENDERER_SCRIPT := preload("res://Games/OpenPitOrbit/Scenes/OpenPitOrbitPlanetRenderer.gd")
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
const HUD_REFRESH_INTERVAL := 0.1
const DRONE_RANGE := 230.0
const DRONE_FOLLOW_SPEED := 8.0
const DRONE_SPACING := 20.0
const DRONE_BEHIND_DIST := 25.0
const DEFENSE_BLOCK_INTERVAL := 5.0
const CORE_SHOCKWAVE_INTERVAL := 7.0
const CORE_SHOCKWAVE_PUSH := 280.0

enum BlockType { NORMAL, CORE, ELECTRIC, GOLD }

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
var minimap: Control
var summary_overlay: ColorRect
var summary_label: RichTextLabel

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    Global.game_state = Util.GAME_STATES.PLAYING
    rng.randomize()
    _build_runtime_nodes()
    _build_ui()
    _start_run()
    set_process(true)

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

    var return_button := Button.new()
    return_button.text = "Return To Upgrades"
    return_button.custom_minimum_size = Vector2(260.0, 74.0)
    return_button.pressed.connect(_return_to_upgrades)
    summary_vbox.add_child(return_button)

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
    pickups.clear()
    destroyed_cells_this_run.clear()
    cores_destroyed_this_run = 0
    core_currency_earned_this_run = 0
    electric_arcs.clear()
    chain_arcs.clear()
    shockwave_rings.clear()
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
    for saved_variant in persistent_data.get("destroyed_cells", []):
        if saved_variant is String:
            var parts := str(saved_variant).split(",")
            if parts.size() == 2:
                persistent_destroyed[Vector2i(int(parts[0]), int(parts[1]))] = true
        elif saved_variant is Vector2i:
            persistent_destroyed[saved_variant] = true
    persistent_destroyed_count = persistent_destroyed.size()
    var cached_runtime_planet = PROGRESS.load_runtime_planet_data(current_depth_level)
    if cached_runtime_planet != null:
        planet_data = cached_runtime_planet
    else:
        planet_data = PLANET_DATA_SCRIPT.new()
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
        return
    ship_glow_phase += delta * 3.0
    camera_pos = ship_pos
    _update_timers(delta)
    if run_finished:
        return
    _update_ship(delta)
    _update_pickups(delta)
    _update_combat(delta)
    _update_drone_visuals(delta)
    _update_zone_return(delta)
    _update_core_behaviors(delta)
    _update_current_layer_name()
    hud_refresh_timer -= delta
    if hud_refresh_timer <= 0.0:
        hud_refresh_timer = HUD_REFRESH_INTERVAL
        _refresh_hud()
    ship_root.global_position = ship_pos
    if fps_label != null:
        fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

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
    var candidates: Array[Dictionary] = []
    var range_world := float(runtime_stats.get("attack_radius", 96.0))
    var grid_range := int(ceil(range_world / BLOCK_SIZE)) + 1
    var my_grid := world_to_grid(ship_pos)
    for dx in range(-grid_range, grid_range + 1):
        for dy in range(-grid_range, grid_range + 1):
            var check := Vector2i(my_grid.x + dx, my_grid.y + dy)
            if is_grid_empty(check):
                continue
            var block_world := grid_to_world(check)
            var dist_sq := ship_pos.distance_squared_to(block_world)
            if dist_sq < range_world * range_world:
                candidates.append({"pos": check, "dist_sq": dist_sq, "world": block_world})
    candidates.sort_custom(func(a: Dictionary, b: Dictionary): return float(a.get("dist_sq", INF)) < float(b.get("dist_sq", INF)))
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

    var hit_count := mini(int(runtime_stats.get("multi_target", 1)), candidates.size())
    var any_destroyed := false
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
        var damage := _compute_laser_damage(pos)
        if last_attack_is_charged:
            damage += float(runtime_stats.get("attack_damage", 8.0)) * float(runtime_stats.get("charged_bonus", 2.0))
            last_attack_is_crit = true
        if bool(runtime_stats.get("crit_chance", 0.0) > 0.0) and rng.randf() < float(runtime_stats.get("crit_chance", 0.0)):
            damage += float(runtime_stats.get("attack_damage", 8.0)) * float(runtime_stats.get("crit_bonus", 2.0))
            last_attack_is_crit = true
        var result := _damage_block(pos, damage)
        if bool(result.get("destroyed", false)):
            any_destroyed = true
        if bool(runtime_stats.get("aoe_enabled", false)):
            for adj in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
                var adj_pos: Vector2i = pos + adj
                if not is_grid_empty(adj_pos):
                    hit_timers[adj_pos] = HIT_FLASH_DURATION
                    var aoe_result := _damage_block(adj_pos, damage * 0.3)
                    if bool(aoe_result.get("destroyed", false)):
                        any_destroyed = true
    attack_visible_timer = 0.08
    if any_destroyed:
        _on_combo_hit()
    if bool(runtime_stats.get("chain_lightning_enabled", false)):
        _trigger_chain_lightning(Vector2i(candidates[0].get("pos", Vector2i.ZERO)), Vector2(candidates[0].get("world", Vector2.ZERO)))

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

func _damage_block(pos: Vector2i, damage: float) -> Dictionary:
    if is_grid_empty(pos):
        return {}
    var block_before: Dictionary = blocks.get(pos, {})
    var result: Dictionary = planet_data.damage_block(pos, damage, false, _core_unlocks_center())
    blocks = planet_data.blocks
    exposed_edges = planet_data.exposed_edges
    if bool(result.get("destroyed", false)):
        damaged_cells.erase(pos)
        persistent_destroyed_count += 1
        destroyed_cells_this_run[pos] = true
        nodes_mined += 1
        overdrive_kills += 1
        var world := grid_to_world(pos)
        _spawn_pickup(world, block_before)
        if int(result.get("type", BlockType.NORMAL)) == BlockType.ELECTRIC and bool(runtime_stats.get("electric_enabled", false)):
            _trigger_electric_chain(pos, world)
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
        damaged_cells[pos] = float(blocks.get(pos, {}).get("hp", 1.0))
    planet_renderer.mark_dirty()
    return result

func _trigger_electric_chain(origin_pos: Vector2i, origin_world: Vector2) -> void:
    _on_combo_hit()
    var results: Array = planet_data.electric_chain(
        origin_pos,
        float(runtime_stats.get("attack_damage", 8.0)),
        int(runtime_stats.get("electric_range", 2)),
        int(runtime_stats.get("electric_chain_depth", 1)),
        0,
        _core_unlocks_center()
    )
    blocks = planet_data.blocks
    exposed_edges = planet_data.exposed_edges
    for result in results:
        var next_pos: Vector2i = result.get("pos", Vector2i.ZERO)
        var next_world := grid_to_world(next_pos)
        electric_arcs.append({"from": origin_world, "to": next_world, "timer": ARC_DURATION})
        hit_timers[next_pos] = HIT_FLASH_DURATION
        if bool(result.get("destroyed", false)):
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
    planet_renderer.mark_dirty()

func _trigger_chain_lightning(start_pos: Vector2i, start_world: Vector2) -> void:
    var current_pos := start_pos
    var current_world := start_world
    var visited := {start_pos: true}
    var jumps := int(runtime_stats.get("chain_lightning_jumps", 3))
    for _j in range(jumps):
        var weighted: Array[Dictionary] = []
        for dx in range(-4, 5):
            for dy in range(-4, 5):
                var dist: int = abs(dx) + abs(dy)
                if dist > 4 or dist == 0:
                    continue
                var check := Vector2i(current_pos.x + dx, current_pos.y + dy)
                if is_grid_empty(check) or visited.has(check):
                    continue
                var weight: int = 5 - dist
                for _w in range(weight):
                    weighted.append({"pos": check, "world": grid_to_world(check)})
        if weighted.is_empty():
            break
        var chosen: Dictionary = weighted[rng.randi() % weighted.size()]
        var best_pos: Vector2i = chosen.get("pos", Vector2i.ZERO)
        var best_world: Vector2 = chosen.get("world", Vector2.ZERO)
        chain_arcs.append({"from": current_world, "to": best_world, "timer": CHAIN_ARC_DURATION})
        hit_timers[best_pos] = HIT_FLASH_DURATION
        var damage := _compute_laser_damage(best_pos) * 0.5
        _damage_block(best_pos, damage)
        visited[best_pos] = true
        current_pos = best_pos
        current_world = best_world

func _trigger_shockwave() -> void:
    shockwave_firing = true
    var my_grid := world_to_grid(ship_pos)
    var radius_cells := int(runtime_stats.get("shockwave_radius_cells", 6))
    var range_sq := radius_cells * radius_cells
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
    blocks = planet_data.blocks
    shockwave_firing = false
    var max_radius := float(radius_cells) * BLOCK_SIZE
    if shockwave_rings.size() >= MAX_SHOCKWAVE_RINGS:
        shockwave_rings.remove_at(0)
    shockwave_rings.append({"radius": 5.0, "max_radius": max_radius, "alpha": 0.8})
    planet_renderer.mark_dirty()

func _update_mega_beam(delta: float) -> void:
    var mouse_world := get_global_mouse_position()
    mega_direction = (mouse_world - ship_pos).normalized() if mouse_world.distance_to(ship_pos) > 10.0 else last_move_dir
    if mega_direction.length() < 0.01:
        mega_direction = Vector2.UP
    mega_beam_hits.clear()
    var step_size := BLOCK_SIZE * 0.4
    var max_dist := float(runtime_stats.get("attack_radius", 96.0)) * 1.5
    mega_beam_end = ship_pos + mega_direction * max_dist
    var steps := int(max_dist / step_size)
    var visited := {}
    for step in range(steps):
        var point := ship_pos + mega_direction * (step_size * float(step + 1))
        var cell := world_to_grid(point)
        if visited.has(cell):
            continue
        visited[cell] = true
        if is_grid_empty(cell):
            continue
        mega_beam_hits.append(grid_to_world(cell))
    mega_damage_timer += delta
    if mega_damage_timer < MEGA_DAMAGE_INTERVAL:
        return
    mega_damage_timer = 0.0
    var damage := 0.0
    for hit_world in mega_beam_hits:
        var cell := world_to_grid(hit_world)
        if is_grid_empty(cell):
            continue
        damage = _compute_laser_damage(cell)
        _damage_block(cell, damage)

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
    _persist_destroyed_cells()
    var keep_percent := 1.0 if returned else float(runtime_stats.get("salvage_keep", 0.0))
    var total_money := cargo_money
    for pickup in pickups:
        total_money += int(pickup.get("money", 0))
    var money_award := int(round(float(total_money) * keep_percent))
    PROGRESS.apply_run_results({
        "money": money_award,
        "core_currency": core_currency_earned_this_run,
        "cores_destroyed": cores_destroyed_this_run,
        "depth_level": current_depth_level,
        "nodes_broken": nodes_mined,
        "boss_defeated": boss_defeated,
        "destroyed_cells": persistent_data.get("destroyed_cells", []).duplicate(true),
        "summary_text": "%s Banked $%d." % [reason, money_award],
    })
    PROGRESS.save_runtime_planet_data(current_depth_level, planet_data)
    summary_overlay.visible = true
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

func _persist_destroyed_cells() -> void:
    var merged := {}
    for existing_variant in persistent_data.get("destroyed_cells", []):
        if existing_variant is String:
            merged[str(existing_variant)] = true
    for key_variant in destroyed_cells_this_run.keys():
        if key_variant is Vector2i:
            var grid: Vector2i = key_variant
            merged["%d,%d" % [grid.x, grid.y]] = true
    var cells: Array[String] = []
    for key_variant in merged.keys():
        cells.append(str(key_variant))
    cells.sort()
    persistent_data["destroyed_cells"] = cells
    persistent_data["boss_defeated"] = boss_defeated
    PROGRESS.save_data(persistent_data)

func _refresh_hud() -> void:
    timer_label.text = "Cargo: %d / %d" % [cargo_units, int(runtime_stats.get("cargo_capacity", 15))]
    cargo_label.text = "Fuel: %.1fs  |  Return Zone %.1fs" % [time_left, maxf(0.0, RETURN_ZONE_DELAY - return_zone_timer)]
    wallet_label.text = "Haul: $%d  |  Wallet: $%d" % [cargo_money, PROGRESS.get_wallet()]
    layer_label.text = "Orbit Tier %d  |  %s  |  Clear %.1f%%" % [current_depth_level, current_layer_name, _get_persistent_clear_percent()]
    status_label.text = "Barriers %d  |  Drones %d  |  Mega %d/%d  |  Alive Cores %d/%d" % [barriers_left, int(runtime_stats.get("drone_count", 0)), mega_gauge, int(runtime_stats.get("mega_gauge_need", 30)), planet_data.get_alive_cores() if planet_data != null else 0, planet_data.get_total_cores() if planet_data != null else 0]
    system_label.text = "Combo %d  |  Overdrive %.1fs  |  Core shards %d  |  Move: Mouse / WASD" % [current_combo, overdrive_timer, PROGRESS.get_core_wallet() + core_currency_earned_this_run]

func _return_to_upgrades() -> void:
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
    var center_grid := world_to_grid(world_pos)
    var grid_range := int(ceil(radius_world / BLOCK_SIZE)) + 1
    var candidates: Array[Dictionary] = []
    for dx in range(-grid_range, grid_range + 1):
        for dy in range(-grid_range, grid_range + 1):
            var check := Vector2i(center_grid.x + dx, center_grid.y + dy)
            if is_grid_empty(check):
                continue
            var dist_sq := world_pos.distance_squared_to(grid_to_world(check))
            if dist_sq <= radius_world * radius_world:
                candidates.append({"pos": check, "dist_sq": dist_sq})
    candidates.sort_custom(func(a: Dictionary, b: Dictionary): return float(a.get("dist_sq", INF)) < float(b.get("dist_sq", INF)))
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
