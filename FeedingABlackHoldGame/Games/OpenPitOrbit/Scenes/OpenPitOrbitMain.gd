extends Node2D
class_name OpenPitOrbitMain

const BALANCE := preload("res://Games/OpenPitOrbit/OpenPitOrbitBalance.gd")
const PROGRESS := preload("res://Games/OpenPitOrbit/OpenPitOrbitProgress.gd")
const MINIMAP_SCRIPT := preload("res://Games/OpenPitOrbit/Scenes/OpenPitOrbitMiniMap.gd")

const GRID_COLS := 560
const LAYER_HEIGHT := 100
const TOP_BUFFER_ROWS := 24
const CELL_SIZE := 18.0
const SAFE_ZONE_COLS := 38
const BASE_RADIUS := 94.0
const SHIP_RADIUS := 12.0
const CAMERA_LERP := 6.0
const INPUT_ACCEL := 760.0
const INPUT_FRICTION := 6.4
const EXTRACTION_DELAY := 1.0
const EXTRACTION_ASCENT_TIME := 0.9
const PICKUP_DRIFT := 42.0
const MINIMAP_SAMPLE_STEP := 4
const PICKUP_UPDATE_INTERVAL := 0.05
const HUD_REFRESH_INTERVAL := 0.1
const DRAW_UPDATE_INTERVAL := 0.033
const MAX_WORLD_PICKUPS := 220
const MAX_DAMAGE_EVENTS_PER_FRAME := 40

const SPLASH_OFFSETS := [
    Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
    Vector2i(-1, 0), Vector2i(1, 0),
    Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
]

var rng := RandomNumberGenerator.new()
var persistent_data: Dictionary = {}
var upgrades: Dictionary = {}
var runtime_stats: Dictionary = {}
var world_rows := 0
var world_size := Vector2.ZERO
var base_center := Vector2.ZERO
var pit_origin_x := 0.0

var destroyed_lookup: Dictionary = {}
var damaged_cells: Dictionary = {}
var newly_destroyed_cells: Array[int] = []
var pickups: Array[Dictionary] = []
var block_info_cache: Dictionary = {}

var ship_pos := Vector2.ZERO
var ship_vel := Vector2.ZERO
var last_safe_pos := Vector2.ZERO
var camera_pos := Vector2.ZERO
var hovered_world_pos := Vector2.ZERO
var current_depth_level := 1
var current_layer_name := "Surface Ring"
var time_left := 30.0
var extraction_timer := 0.0
var extraction_ascent_timer := 0.0
var run_finished := false
var extracting := false
var cargo_units := 0
var cargo_money := 0
var nodes_mined := 0
var shields_left := 0
var boss_defeated := false
var current_combo := 0
var combo_timer := 0.0
var persistent_destroyed_count := 0
var damage_events_remaining := 0
var attack_timer := 0.0
var charged_shot_counter := 0
var last_attack_origin := Vector2.ZERO
var last_attack_target := Vector2.ZERO
var attack_flash_timer := 0.0
var drone_attack_timer := 0.0
var mega_gauge := 0
var mega_timer := 0.0
var mega_direction := Vector2.RIGHT
var overdrive_kills := 0
var overdrive_timer := 0.0
var shockwave_kills := 0
var pickup_update_timer := 0.0
var hud_refresh_timer := 0.0
var draw_update_timer := 0.0

var hud_layer: CanvasLayer
var timer_label: Label
var cargo_label: Label
var wallet_label: Label
var layer_label: Label
var status_label: Label
var system_label: Label
var extraction_label: Label
var fps_label: Label
var minimap: OpenPitOrbitMiniMap
var summary_overlay: ColorRect
var summary_label: RichTextLabel

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    Global.game_state = Util.GAME_STATES.PLAYING
    rng.randomize()
    _build_ui()
    _start_run()
    set_process(true)

func _build_ui() -> void:
    hud_layer = CanvasLayer.new()
    add_child(hud_layer)

    var panel := PanelContainer.new()
    panel.offset_left = 16.0
    panel.offset_top = 16.0
    panel.offset_right = 474.0
    panel.offset_bottom = 232.0
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
    extraction_label = Label.new()
    extraction_label.visible = false
    extraction_label.add_theme_color_override("font_color", Color(1.0, 0.76, 0.28, 1.0))

    for label in [timer_label, cargo_label, wallet_label, layer_label, status_label, system_label]:
        label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
        vbox.add_child(label)
    vbox.add_child(extraction_label)

    if OS.has_feature("editor"):
        fps_label = Label.new()
        fps_label.add_theme_color_override("font_color", Color(0.68, 0.96, 0.8, 1.0))
        vbox.add_child(fps_label)

    minimap = MINIMAP_SCRIPT.new()
    minimap.scene_ref = self
    minimap.anchor_left = 0.0
    minimap.anchor_top = 1.0
    minimap.anchor_right = 0.0
    minimap.anchor_bottom = 1.0
    minimap.offset_left = 16.0
    minimap.offset_top = -216.0
    minimap.offset_right = 216.0
    minimap.offset_bottom = -16.0
    minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud_layer.add_child(minimap)

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
    summary_panel.custom_minimum_size = Vector2(580.0, 360.0)
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
    summary_label.custom_minimum_size = Vector2(520.0, 180.0)
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
    world_rows = TOP_BUFFER_ROWS + LAYER_HEIGHT * current_depth_level
    world_size = Vector2(float(GRID_COLS) * CELL_SIZE, float(world_rows) * CELL_SIZE)
    pit_origin_x = float(SAFE_ZONE_COLS) * CELL_SIZE
    base_center = Vector2(pit_origin_x * 0.6, (float(TOP_BUFFER_ROWS) - 4.0) * CELL_SIZE)
    ship_pos = Vector2(pit_origin_x - CELL_SIZE * 1.5, float(TOP_BUFFER_ROWS) * CELL_SIZE + CELL_SIZE * 1.5)
    last_safe_pos = ship_pos
    camera_pos = Vector2(ship_pos.x + 220.0, ship_pos.y + 80.0)
    time_left = float(runtime_stats.get("run_time", 30.0))
    shields_left = int(runtime_stats.get("barriers", 0))
    boss_defeated = bool(persistent_data.get("boss_defeated", false))
    destroyed_lookup.clear()
    for cell_variant in persistent_data.get("destroyed_cells", []):
        destroyed_lookup[int(cell_variant)] = true
    persistent_destroyed_count = destroyed_lookup.size()
    if minimap != null:
        minimap.visible = bool(runtime_stats.get("minimap_enabled", false))
    _update_layer_label()
    _refresh_hud()
    queue_redraw()

func _process(delta: float) -> void:
    if run_finished:
        return
    hovered_world_pos = _screen_to_world(get_viewport().get_mouse_position())
    if hovered_world_pos.distance_to(ship_pos) > 4.0:
        mega_direction = (hovered_world_pos - ship_pos).normalized()
    damage_events_remaining = MAX_DAMAGE_EVENTS_PER_FRAME
    _update_ship(delta)
    _update_combat(delta)
    pickup_update_timer -= delta
    if pickup_update_timer <= 0.0:
        _update_pickups(max(delta, PICKUP_UPDATE_INTERVAL))
        pickup_update_timer = PICKUP_UPDATE_INTERVAL
    _update_camera(delta)
    _update_layer_label()
    hud_refresh_timer -= delta
    if hud_refresh_timer <= 0.0:
        _refresh_hud()
        hud_refresh_timer = HUD_REFRESH_INTERVAL
    draw_update_timer -= delta
    if draw_update_timer <= 0.0:
        queue_redraw()
        draw_update_timer = DRAW_UPDATE_INTERVAL

func _update_ship(delta: float) -> void:
    if extracting:
        extraction_ascent_timer += delta
        ship_pos.y -= 420.0 * delta
        if extraction_ascent_timer >= EXTRACTION_ASCENT_TIME:
            _finish_run(true, "Orbit transfer complete.")
        return
    time_left = maxf(0.0, time_left - delta)
    if time_left <= 0.0:
        _finish_run(false, "Fuel burned out before extraction.")
        return
    combo_timer -= delta
    if combo_timer <= 0.0:
        current_combo = 0
    overdrive_timer = maxf(0.0, overdrive_timer - delta)
    mega_timer = maxf(0.0, mega_timer - delta)
    var speed: float = float(runtime_stats.get("move_speed", 280.0))
    if overdrive_timer > 0.0:
        speed += float(runtime_stats.get("overdrive_speed_bonus", 300.0))
    var desired_velocity := Vector2.ZERO
    var keyboard_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if keyboard_dir == Vector2.ZERO:
        keyboard_dir = Vector2(
            Input.get_axis("move_left", "move_right"),
            Input.get_axis("move_up", "move_down")
        )
    if keyboard_dir == Vector2.ZERO:
        keyboard_dir = Vector2(
            int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
            int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
        )
    if keyboard_dir != Vector2.ZERO:
        desired_velocity = keyboard_dir.normalized() * speed
    elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var dir: Vector2 = hovered_world_pos - ship_pos
        if dir.length() > 4.0:
            desired_velocity = dir.normalized() * speed
    ship_vel = ship_vel.move_toward(desired_velocity, INPUT_ACCEL * delta)
    if desired_velocity == Vector2.ZERO:
        ship_vel = ship_vel.move_toward(Vector2.ZERO, INPUT_FRICTION * delta * 120.0)
    var candidate := ship_pos + ship_vel * delta
    var collision_index: int = _cell_index_from_world(candidate)
    if _is_cell_solid(collision_index):
        if shields_left > 0:
            shields_left -= 1
            ship_vel = -ship_vel * 0.35
            candidate = last_safe_pos
        else:
            _finish_run(false, "The rig cracked against the wall.")
            return
    else:
        last_safe_pos = candidate
    ship_pos = _clamp_ship_to_world(candidate)
    if ship_pos.distance_to(base_center) <= BASE_RADIUS and cargo_money > 0:
        extraction_timer += delta
        extraction_label.visible = true
        extraction_label.text = "Docking in %.1fs" % maxf(0.0, EXTRACTION_DELAY - extraction_timer)
        if extraction_timer >= EXTRACTION_DELAY:
            extracting = true
            extraction_ascent_timer = 0.0
    else:
        extraction_timer = 0.0
        extraction_label.visible = false

func _update_combat(delta: float) -> void:
    attack_timer -= delta
    drone_attack_timer -= delta
    attack_flash_timer = maxf(0.0, attack_flash_timer - delta)
    if mega_timer > 0.0:
        _fire_mega_beam(delta)
    var fire_mult := float(runtime_stats.get("overdrive_fire_mult", 3.0)) if overdrive_timer > 0.0 else 1.0
    var interval: float = float(runtime_stats.get("attack_interval", 0.8)) / fire_mult
    if attack_timer <= 0.0 and not extracting:
        attack_timer = interval
        var targets: Array[int] = _find_nearest_solid_cells(ship_pos, float(runtime_stats.get("attack_radius", 96.0)), int(runtime_stats.get("multi_target", 1)))
        if not targets.is_empty():
            _fire_primary_attack(targets)
    if bool(runtime_stats.get("drone_enabled", false)) and drone_attack_timer <= 0.0 and not extracting:
        drone_attack_timer = float(runtime_stats.get("drone_fire_interval", 0.9))
        _fire_drone_attacks()

func _fire_primary_attack(targets: Array[int]) -> void:
    var base_damage: float = float(runtime_stats.get("attack_damage", 8.0))
    if bool(runtime_stats.get("charged_enabled", false)):
        charged_shot_counter += 1
        if charged_shot_counter >= int(runtime_stats.get("charged_interval", 5)):
            charged_shot_counter = 0
            base_damage *= float(runtime_stats.get("charged_bonus", 3.0))
    for cell_index in targets:
        var damage: float = _compute_damage_for_cell(cell_index, base_damage)
        _damage_block(cell_index, damage)
        if bool(runtime_stats.get("aoe_enabled", false)):
            for splash_index in _get_neighbor_targets(cell_index, SPLASH_OFFSETS, 6):
                _damage_block(splash_index, damage * 0.3)
        if bool(runtime_stats.get("chain_lightning_enabled", false)):
            _fire_chain_from(cell_index, damage * 0.62, int(runtime_stats.get("chain_lightning_jumps", 3)), int(runtime_stats.get("electric_range", 2)))
    last_attack_origin = ship_pos
    last_attack_target = _cell_center(int(targets[0]))
    attack_flash_timer = 0.1

func _fire_drone_attacks() -> void:
    var drone_damage: float = float(runtime_stats.get("drone_damage", 8.0))
    if bool(runtime_stats.get("drone_sync_unlock", false)):
        drone_damage += float(runtime_stats.get("attack_damage", 8.0)) * float(runtime_stats.get("drone_sync_ratio", 0.15))
    for drone_pos in _build_drone_positions():
        var targets: Array[int] = _find_nearest_solid_cells(drone_pos, float(runtime_stats.get("attack_radius", 96.0)) * 0.9, int(runtime_stats.get("drone_pierce", 1)))
        for cell_index in targets:
            var damage := _compute_damage_for_cell(cell_index, drone_damage)
            if rng.randf() < float(runtime_stats.get("drone_crit_chance", 0.0)):
                damage *= float(runtime_stats.get("drone_crit_bonus", 3.0))
            _damage_block(cell_index, damage)

func _fire_chain_from(start_index: int, base_damage: float, jumps: int, range_cells: int) -> void:
    var current_index := start_index
    var visited := {start_index: true}
    for _jump in range(jumps):
        var next_index := _find_chain_target(current_index, visited, range_cells)
        if next_index < 0:
            break
        visited[next_index] = true
        _damage_block(next_index, base_damage)
        current_index = next_index

func _find_chain_target(from_index: int, visited: Dictionary, range_cells: int) -> int:
    var center_col: int = from_index % GRID_COLS
    var center_row: int = from_index / GRID_COLS
    var best := -1
    var best_dist := INF
    for row in range(center_row - range_cells, center_row + range_cells + 1):
        for col in range(center_col - range_cells, center_col + range_cells + 1):
            if row < TOP_BUFFER_ROWS or row >= world_rows or col < SAFE_ZONE_COLS or col >= GRID_COLS:
                continue
            var idx: int = row * GRID_COLS + col
            if visited.has(idx) or not _is_cell_solid(idx):
                continue
            var dist := Vector2(float(col - center_col), float(row - center_row)).length_squared()
            if dist < best_dist:
                best_dist = dist
                best = idx
    return best

func _fire_mega_beam(delta: float) -> void:
    var beam_damage: float = float(runtime_stats.get("attack_damage", 8.0)) * 2.0 * delta * 8.0
    last_attack_origin = ship_pos
    last_attack_target = ship_pos + mega_direction.normalized() * 380.0
    attack_flash_timer = 0.08
    for step in range(1, 24):
        var point := ship_pos + mega_direction.normalized() * float(step) * CELL_SIZE * 1.6
        var cell_index := _cell_index_from_world(point)
        if _is_cell_solid(cell_index):
            _damage_block(cell_index, _compute_damage_for_cell(cell_index, beam_damage))

func _compute_damage_for_cell(cell_index: int, base_damage: float) -> float:
    var block_info: Dictionary = _get_block_info(cell_index)
    var damage := base_damage
    damage *= BALANCE.get_damage_multiplier_for_depth(runtime_stats, int(block_info.get("layer_depth", 1)))
    if bool(runtime_stats.get("resonance_enabled", false)):
        damage *= 1.0 + _depth_ratio_for_cell(cell_index) * float(runtime_stats.get("resonance_bonus", 1.0))
    if bool(block_info.get("boss", false)) or int(block_info.get("layer_depth", 1)) >= BALANCE.MAX_DEPTH_LEVEL:
        damage *= float(runtime_stats.get("core_breaker_mult", 1.0))
    if rng.randf() < float(runtime_stats.get("crit_chance", 0.0)):
        damage *= float(runtime_stats.get("crit_bonus", 3.0))
    return damage

func _damage_block(cell_index: int, damage: float) -> void:
    if damage_events_remaining <= 0 or not _is_cell_solid(cell_index):
        return
    damage_events_remaining -= 1
    var health_after: float = _get_cell_health(cell_index) - damage
    if health_after <= 0.0:
        _destroy_cell(cell_index)
    else:
        damaged_cells[cell_index] = health_after

func _destroy_cell(cell_index: int) -> void:
    if destroyed_lookup.has(cell_index):
        return
    var block_info: Dictionary = _get_block_info(cell_index)
    destroyed_lookup[cell_index] = true
    persistent_destroyed_count += 1
    damaged_cells.erase(cell_index)
    newly_destroyed_cells.append(cell_index)
    nodes_mined += 1
    current_combo += 1
    combo_timer = 1.5
    overdrive_kills += 1
    shockwave_kills += 1
    if bool(runtime_stats.get("mega_enabled", false)):
        mega_gauge += 1
        if mega_timer <= 0.0 and mega_gauge >= int(runtime_stats.get("mega_gauge_need", 30)):
            mega_gauge = 0
            mega_timer = float(runtime_stats.get("mega_duration", 5.0))
    if bool(runtime_stats.get("overdrive_enabled", false)) and overdrive_timer <= 0.0 and overdrive_kills >= int(runtime_stats.get("overdrive_kill_need", 50)):
        overdrive_kills = 0
        overdrive_timer = float(runtime_stats.get("overdrive_duration", 3.0))
    if bool(runtime_stats.get("shockwave_enabled", false)) and shockwave_kills >= int(runtime_stats.get("shockwave_trigger_kills", 15)):
        shockwave_kills = 0
        _trigger_shockwave()
    _spawn_pickups_for_block(cell_index, block_info)
    if bool(block_info.get("electric", false)) and bool(runtime_stats.get("electric_enabled", false)):
        _fire_chain_from(cell_index, float(runtime_stats.get("attack_damage", 8.0)) * 0.7, int(runtime_stats.get("electric_chain_depth", 1)) * 2, int(runtime_stats.get("electric_range", 2)))
    if bool(block_info.get("boss", false)):
        boss_defeated = true
        _finish_run(true, "The vault core ruptured.")
    _mark_minimap_dirty()

func _trigger_shockwave() -> void:
    var center_index := _cell_index_from_world(ship_pos)
    if center_index < 0:
        return
    var radius: int = int(runtime_stats.get("shockwave_radius_cells", 6))
    var center_col: int = center_index % GRID_COLS
    var center_row: int = center_index / GRID_COLS
    for row in range(center_row - radius, center_row + radius + 1):
        for col in range(center_col - radius, center_col + radius + 1):
            if row < TOP_BUFFER_ROWS or row >= world_rows or col < SAFE_ZONE_COLS or col >= GRID_COLS:
                continue
            var idx: int = row * GRID_COLS + col
            if _is_cell_solid(idx):
                _damage_block(idx, float(runtime_stats.get("attack_damage", 8.0)) * 0.8)

func _spawn_pickups_for_block(cell_index: int, block_info: Dictionary) -> void:
    var payout: float = float(block_info.get("value", 1)) + float(runtime_stats.get("resource_flat", 0.0))
    if bool(block_info.get("gold", false)):
        payout += float(runtime_stats.get("gold_bonus_flat", 0.0))
    payout *= BALANCE.get_resource_multiplier_for_depth(runtime_stats, int(block_info.get("layer_depth", 1)))
    if bool(runtime_stats.get("combo_enabled", false)):
        payout *= 1.0 + float(runtime_stats.get("combo_bonus_per_stack", 0.0)) * float(current_combo)
    var money: int = int(round(payout))
    var cargo_cost: int = int(block_info.get("cargo_weight", 1))
    var origin := _cell_center(cell_index)
    if bool(runtime_stats.get("instant_collect", false)) or _should_auto_collect_pickup(origin, cargo_cost):
        _collect_pickup_values(money, cargo_cost)
        return
    if pickups.size() >= MAX_WORLD_PICKUPS:
        _merge_pickup_bundle(origin, money, cargo_cost)
        return
    pickups.append({"position": origin, "money": money, "cargo": cargo_cost, "drift_x": rng.randf_range(-PICKUP_DRIFT, PICKUP_DRIFT), "drift_y": rng.randf_range(-PICKUP_DRIFT, PICKUP_DRIFT)})

func _update_pickups(delta: float) -> void:
    var survivors: Array[Dictionary] = []
    var pickup_radius: float = float(runtime_stats.get("pickup_radius", 64.0))
    var drone_positions: Array[Vector2] = _build_drone_positions()
    for pickup in pickups:
        pickup["position"] = Vector2(pickup.get("position", Vector2.ZERO)) + Vector2(float(pickup.get("drift_x", 0.0)), float(pickup.get("drift_y", 0.0))) * delta
        var collect: bool = Vector2(pickup.get("position", Vector2.ZERO)).distance_to(ship_pos) <= pickup_radius
        if not collect:
            for drone_pos in drone_positions:
                if Vector2(pickup.get("position", Vector2.ZERO)).distance_to(drone_pos) <= pickup_radius:
                    collect = true
                    break
        if collect and cargo_units + int(pickup.get("cargo", 1)) <= int(runtime_stats.get("cargo_capacity", 15)):
            _collect_pickup_values(int(pickup.get("money", 0)), int(pickup.get("cargo", 1)))
        else:
            survivors.append(pickup)
    pickups = survivors

func _collect_pickup_values(money: int, cargo: int) -> void:
    if cargo_units + cargo > int(runtime_stats.get("cargo_capacity", 15)):
        return
    cargo_units += cargo
    cargo_money += money

func _finish_run(returned: bool, reason: String) -> void:
    if run_finished:
        return
    run_finished = true
    _persist_destroyed_cells(true)
    var keep_percent: float = 1.0 if returned else float(runtime_stats.get("salvage_keep", 0.0))
    var total_money: int = cargo_money + _get_stranded_pickup_totals()
    var money_award: int = int(round(float(total_money) * keep_percent))
    PROGRESS.apply_run_results({
        "money": money_award,
        "depth_level": current_depth_level,
        "nodes_broken": nodes_mined,
        "boss_defeated": boss_defeated,
        "destroyed_cells": persistent_data.get("destroyed_cells", []).duplicate(true),
        "summary_text": "%s Banked $%d." % [reason, money_award],
    })
    summary_overlay.visible = true
    summary_label.text = "[center]%s\n\nLayer %d\nBlocks mined: %d\nPersistent clear: %.1f%%\nCash banked: $%d\nCombo peak: %d\nBarriers left: %d[/center]" % [reason, current_depth_level, nodes_mined, _get_persistent_clear_percent(), money_award, current_combo, shields_left]

func _persist_destroyed_cells(mark_boss: bool) -> void:
    var saved_cells: Dictionary = {}
    for existing_variant in persistent_data.get("destroyed_cells", []):
        saved_cells[int(existing_variant)] = true
    for cell_index in newly_destroyed_cells:
        saved_cells[cell_index] = true
    var merged: Array[int] = []
    for key_variant in saved_cells.keys():
        merged.append(int(key_variant))
    merged.sort()
    persistent_data["destroyed_cells"] = merged
    if mark_boss and boss_defeated:
        persistent_data["boss_defeated"] = true
    PROGRESS.save_data(persistent_data)
    newly_destroyed_cells.clear()

func _refresh_hud() -> void:
    timer_label.text = "Fuel: %.1fs" % time_left
    cargo_label.text = "Cargo: %d / %d" % [cargo_units, int(runtime_stats.get("cargo_capacity", 15))]
    wallet_label.text = "Haul: $%d  |  Wallet: $%d" % [cargo_money, PROGRESS.get_wallet()]
    layer_label.text = "Layer %d  |  %s  |  Clear %.1f%%" % [current_depth_level, current_layer_name, _get_persistent_clear_percent()]
    status_label.text = "Barriers %d  |  Drones %d  |  Mega %d/%d" % [shields_left, int(runtime_stats.get("drone_count", 0)), mega_gauge, int(runtime_stats.get("mega_gauge_need", 30))]
    system_label.text = "Combo %d  |  Overdrive %.1fs  |  Radius %.0f  |  Move: WASD/Arrows or LMB" % [current_combo, overdrive_timer, float(runtime_stats.get("attack_radius", 96.0))]
    if fps_label != null:
        fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _update_layer_label() -> void:
    var row: int = clampi(int(ship_pos.y / CELL_SIZE), 0, max(0, world_rows - 1))
    current_layer_name = str(BALANCE.get_layer_for_depth(_layer_depth_for_row(row)).get("name", "Layer"))

func _draw() -> void:
    var viewport_size: Vector2 = get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.02, 0.03, 0.06, 1.0), true)
    for star_idx in range(80):
        draw_circle(Vector2(float((star_idx * 193) % int(viewport_size.x)), float((star_idx * 347) % int(viewport_size.y))), 1.2, Color(0.78, 0.88, 1.0, 0.65))
    draw_rect(Rect2(_world_to_screen(Vector2.ZERO), Vector2(world_size.x, float(TOP_BUFFER_ROWS) * CELL_SIZE)), Color(0.05, 0.08, 0.13, 1.0), true)
    draw_rect(Rect2(_world_to_screen(Vector2.ZERO), Vector2(pit_origin_x, world_size.y)), Color(0.04, 0.05, 0.09, 1.0), true)
    draw_line(
        _world_to_screen(Vector2(pit_origin_x, float(TOP_BUFFER_ROWS) * CELL_SIZE)),
        _world_to_screen(Vector2(pit_origin_x, world_size.y)),
        Color(0.36, 0.84, 1.0, 0.45),
        3.0
    )
    draw_line(
        _world_to_screen(Vector2(pit_origin_x, float(TOP_BUFFER_ROWS) * CELL_SIZE)),
        _world_to_screen(Vector2(world_size.x, float(TOP_BUFFER_ROWS) * CELL_SIZE)),
        Color(0.36, 0.84, 1.0, 0.28),
        2.0
    )
    var viewport_half := viewport_size * 0.5
    var start_col: int = max(0, int(floor((camera_pos.x - viewport_half.x) / CELL_SIZE)) - 1)
    var end_col: int = min(GRID_COLS - 1, int(ceil((camera_pos.x + viewport_half.x) / CELL_SIZE)) + 1)
    var start_row: int = max(0, int(floor((camera_pos.y - viewport_half.y) / CELL_SIZE)) - 1)
    var end_row: int = min(world_rows - 1, int(ceil((camera_pos.y + viewport_half.y) / CELL_SIZE)) + 1)
    for row in range(start_row, end_row + 1):
        for col in range(start_col, end_col + 1):
            if col < SAFE_ZONE_COLS:
                continue
            var index: int = row * GRID_COLS + col
            if not _is_cell_solid(index):
                continue
            var block_info: Dictionary = _get_block_info(index)
            var rect := Rect2(_world_to_screen(Vector2(float(col) * CELL_SIZE, float(row) * CELL_SIZE)), Vector2(CELL_SIZE + 1.0, CELL_SIZE + 1.0))
            draw_rect(rect, Color(block_info.get("color", Color.WHITE)), true)
            if bool(block_info.get("electric", false)):
                draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), Color(0.45, 0.96, 1.0, 0.28), false, 1.0)
            if bool(block_info.get("gold", false)):
                draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), Color(1.0, 0.86, 0.32, 0.32), false, 2.0)
        if row > end_row:
            break
    draw_circle(_world_to_screen(base_center), BASE_RADIUS, Color(0.12, 0.34, 0.62, 0.18))
    draw_arc(_world_to_screen(base_center), BASE_RADIUS, 0.0, TAU, 64, Color(0.4, 0.9, 1.0, 0.9), 3.0)
    draw_circle(_world_to_screen(ship_pos), SHIP_RADIUS, Color(0.92, 0.96, 1.0, 1.0))
    for drone_pos in _build_drone_positions():
        draw_circle(_world_to_screen(drone_pos), 6.0, Color(0.56, 0.88, 1.0, 1.0))
    draw_arc(_world_to_screen(ship_pos), float(runtime_stats.get("attack_radius", 96.0)), 0.0, TAU, 64, Color(0.34, 0.72, 1.0, 0.14), 2.0)
    draw_arc(_world_to_screen(ship_pos), float(runtime_stats.get("pickup_radius", 64.0)), 0.0, TAU, 64, Color(0.36, 1.0, 0.76, 0.14), 2.0)
    if attack_flash_timer > 0.0:
        draw_line(_world_to_screen(last_attack_origin), _world_to_screen(last_attack_target), Color(0.62, 0.92, 1.0, attack_flash_timer / 0.1), 3.0)
    if mega_timer > 0.0:
        draw_line(_world_to_screen(ship_pos), _world_to_screen(ship_pos + mega_direction.normalized() * 380.0), Color(1.0, 0.62, 0.22, 0.85), 6.0)
    for pickup in pickups:
        draw_circle(_world_to_screen(Vector2(pickup.get("position", Vector2.ZERO))), 4.0, Color(1.0, 0.82, 0.34, 1.0))

func draw_minimap_into(control: Control) -> void:
    var size: Vector2 = control.size
    control.draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.02, 0.04, 0.92), true)
    var block_w: float = size.x / float(GRID_COLS)
    var block_h: float = size.y / float(max(1, world_rows))
    for row in range(0, world_rows, MINIMAP_SAMPLE_STEP):
        for col in range(SAFE_ZONE_COLS, GRID_COLS, MINIMAP_SAMPLE_STEP):
            var index: int = row * GRID_COLS + col
            if not _is_cell_solid(index):
                continue
            var block_info: Dictionary = _get_block_info(index)
            control.draw_rect(Rect2(Vector2(float(col) * block_w, float(row) * block_h), Vector2(maxf(1.0, block_w * MINIMAP_SAMPLE_STEP), maxf(1.0, block_h * MINIMAP_SAMPLE_STEP))), Color(block_info.get("color", Color.WHITE)), true)
    control.draw_circle(Vector2(base_center.x / world_size.x * size.x, base_center.y / world_size.y * size.y), 5.0, Color(0.46, 0.96, 1.0, 1.0))
    control.draw_circle(Vector2(ship_pos.x / world_size.x * size.x, ship_pos.y / world_size.y * size.y), 3.0, Color.WHITE)

func _find_nearest_solid_cells(origin: Vector2, radius: float, limit: int) -> Array[int]:
    var found: Array[int] = []
    var center_col: int = int(floor(origin.x / CELL_SIZE))
    var center_row: int = int(floor(origin.y / CELL_SIZE))
    var radius_sq: float = radius * radius
    var max_ring: int = int(ceil(radius / CELL_SIZE))
    for ring in range(max_ring + 1):
        if ring == 0:
            _try_add_target_cell(found, center_row, center_col, origin, radius_sq, limit)
        else:
            var top: int = center_row - ring
            var bottom: int = center_row + ring
            var left: int = center_col - ring
            var right: int = center_col + ring
            for col in range(left, right + 1):
                _try_add_target_cell(found, top, col, origin, radius_sq, limit)
                _try_add_target_cell(found, bottom, col, origin, radius_sq, limit)
            for row in range(top + 1, bottom):
                _try_add_target_cell(found, row, left, origin, radius_sq, limit)
                _try_add_target_cell(found, row, right, origin, radius_sq, limit)
        if found.size() >= limit:
            break
    return found

func _try_add_target_cell(found: Array[int], row: int, col: int, origin: Vector2, radius_sq: float, limit: int) -> void:
    if found.size() >= limit or row < TOP_BUFFER_ROWS or row >= world_rows or col < SAFE_ZONE_COLS or col >= GRID_COLS:
        return
    var index: int = row * GRID_COLS + col
    if not _is_cell_solid(index):
        return
    if origin.distance_squared_to(_cell_center(index)) > radius_sq:
        return
    found.append(index)

func _is_cell_solid(cell_index: int) -> bool:
    if cell_index < 0:
        return false
    var row: int = cell_index / GRID_COLS
    var col: int = cell_index % GRID_COLS
    if row < TOP_BUFFER_ROWS or row >= world_rows or col < SAFE_ZONE_COLS or col >= GRID_COLS:
        return false
    return not destroyed_lookup.has(cell_index)

func _get_block_info(cell_index: int) -> Dictionary:
    if block_info_cache.has(cell_index):
        return block_info_cache[cell_index]
    var row: int = cell_index / GRID_COLS
    var col: int = cell_index % GRID_COLS
    var layer_depth: int = _layer_depth_for_row(row)
    var layer: Dictionary = BALANCE.get_layer_for_depth(layer_depth)
    var is_gold: bool = bool(runtime_stats.get("gold_enabled", false)) and _hash_float(row, col, 0.17) < 0.015
    var is_electric: bool = bool(runtime_stats.get("electric_enabled", false)) and _hash_float(row, col, 0.39) < 0.02
    var is_boss: bool = current_depth_level >= BALANCE.MAX_DEPTH_LEVEL and row >= world_rows - 10 and col >= GRID_COLS - 22 and col <= GRID_COLS - 14
    var value: int = int(layer.get("value", 1))
    var max_health: float = float(layer.get("health", 10.0))
    var cargo_weight := 1 + int(floor(float(layer_depth) * 0.4))
    var color: Color = layer.get("color", Color.WHITE)
    var accent: Color = layer.get("accent", Color.WHITE)
    if is_gold:
        value = int(round(float(value) * 4.5))
        max_health *= 1.35
        color = Color(0.78, 0.62, 0.14, 1.0)
        accent = Color(1.0, 0.88, 0.42, 1.0)
    if is_electric:
        value = int(round(float(value) * 1.4))
        max_health *= 1.2
        color = Color(0.1, 0.34, 0.44, 1.0)
        accent = Color(0.56, 0.94, 1.0, 1.0)
    if is_boss:
        value = 2000
        max_health = 12000.0
        cargo_weight = 0
        color = Color(0.8, 0.1, 0.14, 1.0)
        accent = Color(1.0, 0.66, 0.22, 1.0)
    var info := {"layer_depth": layer_depth, "value": value, "max_health": max_health, "cargo_weight": cargo_weight, "color": color, "accent": accent, "gold": is_gold, "electric": is_electric, "boss": is_boss}
    block_info_cache[cell_index] = info
    return info

func _get_cell_health(cell_index: int) -> float:
    if damaged_cells.has(cell_index):
        return float(damaged_cells[cell_index])
    return float(_get_block_info(cell_index).get("max_health", 1.0))

func _build_drone_positions() -> Array[Vector2]:
    var positions: Array[Vector2] = []
    var count: int = int(runtime_stats.get("drone_count", 0))
    for index in range(count):
        var angle: float = TAU * float(index) / float(max(1, count)) + float(Time.get_ticks_msec()) / 900.0
        positions.append(ship_pos + Vector2.RIGHT.rotated(angle) * 42.0)
    return positions

func _get_neighbor_targets(cell_index: int, offsets: Array, limit: int) -> Array[int]:
    var results: Array[int] = []
    var center_col: int = cell_index % GRID_COLS
    var center_row: int = cell_index / GRID_COLS
    for offset_variant in offsets:
        var offset: Vector2i = offset_variant
        var row := center_row + offset.y
        var col := center_col + offset.x
        if row < TOP_BUFFER_ROWS or row >= world_rows or col < SAFE_ZONE_COLS or col >= GRID_COLS:
            continue
        var idx := row * GRID_COLS + col
        if not _is_cell_solid(idx):
            continue
        results.append(idx)
        if results.size() >= limit:
            break
    return results

func _depth_ratio_for_cell(cell_index: int) -> float:
    var row: int = cell_index / GRID_COLS
    return clampf(float(max(0, row - TOP_BUFFER_ROWS)) / float(max(1, world_rows - TOP_BUFFER_ROWS)), 0.0, 1.0)

func _get_persistent_clear_percent() -> float:
    var mineable_rows: int = max(1, world_rows - TOP_BUFFER_ROWS)
    return 100.0 * float(persistent_destroyed_count) / float(max(1, (GRID_COLS - SAFE_ZONE_COLS) * mineable_rows))

func _get_stranded_pickup_totals() -> int:
    var total := 0
    for pickup in pickups:
        total += int(pickup.get("money", 0))
    return total

func _should_auto_collect_pickup(position: Vector2, cargo_cost: int) -> bool:
    if cargo_units + cargo_cost > int(runtime_stats.get("cargo_capacity", 15)):
        return false
    if bool(runtime_stats.get("instant_collect", false)):
        return true
    var radius: float = float(runtime_stats.get("pickup_radius", 64.0))
    if position.distance_to(ship_pos) <= radius:
        return true
    for drone_pos in _build_drone_positions():
        if position.distance_to(drone_pos) <= radius:
            return true
    return false

func _merge_pickup_bundle(position: Vector2, money: int, cargo: int) -> void:
    if pickups.is_empty():
        pickups.append({"position": position, "money": money, "cargo": cargo, "drift_x": 0.0, "drift_y": 0.0})
        return
    var pickup: Dictionary = pickups[pickups.size() - 1]
    pickup["money"] = int(pickup.get("money", 0)) + money
    pickup["cargo"] = int(pickup.get("cargo", 0)) + cargo
    pickup["position"] = (Vector2(pickup.get("position", position)) + position) * 0.5
    pickups[pickups.size() - 1] = pickup

func _update_camera(delta: float) -> void:
    camera_pos = camera_pos.lerp(ship_pos, clampf(delta * CAMERA_LERP, 0.0, 1.0))
    var viewport_size: Vector2 = get_viewport_rect().size
    camera_pos.x = clampf(camera_pos.x, viewport_size.x * 0.5, max(viewport_size.x * 0.5, world_size.x - viewport_size.x * 0.5))
    camera_pos.y = clampf(camera_pos.y, viewport_size.y * 0.5, max(viewport_size.y * 0.5, world_size.y - viewport_size.y * 0.5))

func _layer_depth_for_row(row: int) -> int:
    return clampi(1 + int(floor(float(max(0, row - TOP_BUFFER_ROWS)) / float(LAYER_HEIGHT))), 1, BALANCE.MAX_DEPTH_LEVEL)

func _cell_center(index: int) -> Vector2:
    return Vector2((float(index % GRID_COLS) + 0.5) * CELL_SIZE, (float(index / GRID_COLS) + 0.5) * CELL_SIZE)

func _cell_index_from_world(world_pos: Vector2) -> int:
    var col: int = int(floor(world_pos.x / CELL_SIZE))
    var row: int = int(floor(world_pos.y / CELL_SIZE))
    if col < 0 or col >= GRID_COLS or row < 0 or row >= world_rows:
        return -1
    return row * GRID_COLS + col

func _world_to_screen(world_pos: Vector2) -> Vector2:
    return world_pos - camera_pos + get_viewport_rect().size * 0.5

func _screen_to_world(screen_pos: Vector2) -> Vector2:
    return screen_pos + camera_pos - get_viewport_rect().size * 0.5

func _clamp_ship_to_world(pos: Vector2) -> Vector2:
    return Vector2(clampf(pos.x, SHIP_RADIUS, world_size.x - SHIP_RADIUS), clampf(pos.y, SHIP_RADIUS, world_size.y - SHIP_RADIUS))

func _hash_float(row: int, col: int, salt: float) -> float:
    var value: float = sin(float(row) * 12.9898 + float(col) * 78.233 + salt * 437.0) * 43758.5453
    return value - floor(value)

func _mark_minimap_dirty() -> void:
    if minimap != null:
        minimap.mark_dirty()

func _return_to_upgrades() -> void:
    SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)
