extends Node2D
class_name OpenPitEmpireMain

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const MINIMAP_SCRIPT := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireMiniMap.gd")

const GRID_COLS := 640
const LAYER_HEIGHT := 120
const TOP_BUFFER_ROWS := 26
const CELL_SIZE := 18.0
const SAFE_ZONE_COLS := 42
const BASE_RADIUS := 92.0
const SHIP_RADIUS := 12.0
const ATTACK_LINE_WIDTH := 2.0
const PICKUP_RADIUS_DRAW_ALPHA := 0.1
const ATTACK_RADIUS_DRAW_ALPHA := 0.08
const CAMERA_LERP := 6.0
const INPUT_ACCEL := 720.0
const INPUT_FRICTION := 6.4
const ATTACK_FLASH_TIME := 0.1
const EXTRACTION_DELAY := 1.0
const EXTRACTION_ASCENT_TIME := 0.9
const OIL_CHANCE := 0.004
const PICKUP_DRIFT := 38.0
const SUMMARY_BUTTON_WIDTH := 260.0
const SUMMARY_BUTTON_HEIGHT := 74.0
const PERSIST_BATCH_SAVE_INTERVAL := 80
const MINIMAP_SAMPLE_STEP := 4
const PICKUP_UPDATE_INTERVAL := 0.05
const HUD_REFRESH_INTERVAL := 0.12
const DRAW_UPDATE_INTERVAL := 0.033
const COMBAT_UPDATE_INTERVAL := 0.033
const MAX_WORLD_PICKUPS := 180
const MAX_DAMAGE_EVENTS_PER_FRAME := 28
const COMPANION_ATTACK_STAGGER := 0.075
const MAX_SPLASH_TARGETS := 4
const MAX_CHAIN_TARGETS := 2

const SPLASH_OFFSETS := [
    Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
    Vector2i(-1, 0), Vector2i(1, 0),
    Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
]

const CHAIN_OFFSETS := [
    Vector2i(-2, 0), Vector2i(2, 0), Vector2i(0, -2), Vector2i(0, 2),
    Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(2, -1), Vector2i(2, 1),
    Vector2i(-1, -2), Vector2i(1, -2), Vector2i(-1, 2), Vector2i(1, 2),
]

var rng := RandomNumberGenerator.new()
var persistent_data: Dictionary = {}
var upgrades: Dictionary = {}
var world_rows: int = 0
var world_size := Vector2.ZERO
var base_center := Vector2.ZERO
var pit_origin_x := 0.0

var destroyed_lookup: Dictionary = {}
var damaged_cells: Dictionary = {}
var newly_destroyed_cells: Array[int] = []
var pickups: Array[Dictionary] = []

var ship_pos := Vector2.ZERO
var ship_vel := Vector2.ZERO
var last_safe_pos := Vector2.ZERO
var camera_pos := Vector2.ZERO
var last_attack_origin := Vector2.ZERO
var last_attack_target := Vector2.ZERO
var attack_flash_timer := 0.0
var companion_attack_cursor := 0
var companion_attack_stagger_timer := 0.0
var damage_events_remaining := 0

var current_depth_level := 1
var current_layer_name := "Topsoil"
var time_left := 30.0
var attack_timer := 0.0
var extraction_timer := 0.0
var extraction_ascent_timer := 0.0
var run_finished := false
var extracting := false
var cargo_units := 0
var cargo_money := 0
var cargo_oil := 0
var nodes_mined := 0
var boss_defeated := false
var shields_left := 0
var hovered_world_pos := Vector2.ZERO
var persist_save_counter := 0
var persistent_destroyed_count := 0
var last_companion_positions: Array[Vector2] = []
var pickup_update_timer := 0.0
var hud_refresh_timer := 0.0
var draw_update_timer := 0.0
var combat_update_timer := 0.0
var block_info_cache: Dictionary = {}

var hud_layer: CanvasLayer
var timer_label: Label
var cargo_label: Label
var wallet_label: Label
var oil_label: Label
var layer_label: Label
var status_label: Label
var extraction_label: Label
var fps_label: Label
var minimap: OpenPitEmpireMiniMap
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
    panel.offset_right = 438.0
    panel.offset_bottom = 196.0
    hud_layer.add_child(panel)

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
    oil_label = Label.new()
    layer_label = Label.new()
    status_label = Label.new()
    extraction_label = Label.new()
    extraction_label.add_theme_color_override("font_color", Color(0.98, 0.85, 0.44, 1.0))
    extraction_label.visible = false

    vbox.add_child(timer_label)
    vbox.add_child(cargo_label)
    vbox.add_child(wallet_label)
    vbox.add_child(oil_label)
    vbox.add_child(layer_label)
    vbox.add_child(status_label)
    vbox.add_child(extraction_label)

    if OS.has_feature("editor"):
        fps_label = Label.new()
        fps_label.text = "FPS: --"
        fps_label.add_theme_color_override("font_color", Color(0.72, 0.96, 0.72, 1.0))
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
    summary_overlay.color = Color(0.0, 0.0, 0.0, 0.78)
    summary_overlay.visible = false
    hud_layer.add_child(summary_overlay)

    var summary_center := CenterContainer.new()
    summary_center.anchor_right = 1.0
    summary_center.anchor_bottom = 1.0
    summary_overlay.add_child(summary_center)

    var summary_panel := PanelContainer.new()
    summary_panel.custom_minimum_size = Vector2(560.0, 340.0)
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
    title.text = "Open Pit Empire"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    summary_vbox.add_child(title)

    summary_label = RichTextLabel.new()
    summary_label.fit_content = true
    summary_label.scroll_active = false
    summary_label.bbcode_enabled = true
    summary_label.custom_minimum_size = Vector2(520.0, 180.0)
    summary_vbox.add_child(summary_label)

    var return_button := Button.new()
    return_button.text = "Return To Upgrades"
    return_button.custom_minimum_size = Vector2(SUMMARY_BUTTON_WIDTH, SUMMARY_BUTTON_HEIGHT)
    return_button.pressed.connect(_return_to_upgrades)
    summary_vbox.add_child(return_button)

func _start_run() -> void:
    persistent_data = PROGRESS.load_data()
    upgrades = persistent_data.get("upgrades", {}).duplicate(true)
    current_depth_level = clampi(int(persistent_data.get("selected_depth_level", 1)), 1, BALANCE.MAX_DEPTH_LEVEL)
    world_rows = TOP_BUFFER_ROWS + LAYER_HEIGHT * current_depth_level
    world_size = Vector2(float(GRID_COLS) * CELL_SIZE, float(world_rows) * CELL_SIZE)
    pit_origin_x = float(SAFE_ZONE_COLS) * CELL_SIZE
    base_center = Vector2(pit_origin_x * 0.34, (float(TOP_BUFFER_ROWS) - 7.0) * CELL_SIZE)
    ship_pos = base_center + Vector2(BASE_RADIUS - 20.0, 0.0)
    last_safe_pos = ship_pos
    camera_pos = ship_pos
    time_left = BALANCE.get_run_time(upgrades)
    attack_timer = 0.0
    companion_attack_cursor = 0
    companion_attack_stagger_timer = 0.0
    extraction_timer = 0.0
    extraction_ascent_timer = 0.0
    run_finished = false
    extracting = false
    cargo_units = 0
    cargo_money = 0
    cargo_oil = 0
    nodes_mined = 0
    boss_defeated = bool(persistent_data.get("boss_defeated", false))
    shields_left = BALANCE.get_shield_count(upgrades)
    damaged_cells.clear()
    pickups.clear()
    newly_destroyed_cells.clear()
    persist_save_counter = 0
    pickup_update_timer = 0.0
    hud_refresh_timer = 0.0
    draw_update_timer = 0.0
    combat_update_timer = 0.0
    block_info_cache.clear()
    _load_destroyed_lookup()
    _mark_minimap_dirty()
    status_label.text = "Launch from the left pad, carve into the pit, and extract before timeout."
    _refresh_hud()
    queue_redraw()

func _load_destroyed_lookup() -> void:
    destroyed_lookup.clear()
    for cell_variant in persistent_data.get("destroyed_cells", []):
        destroyed_lookup[int(cell_variant)] = true
    persistent_destroyed_count = destroyed_lookup.size()

func _process(delta: float) -> void:
    if run_finished:
        return
    hovered_world_pos = _screen_to_world(get_viewport().get_mouse_position())
    last_companion_positions = _build_companion_positions()
    damage_events_remaining = MAX_DAMAGE_EVENTS_PER_FRAME
    _update_ship(delta)
    pickup_update_timer -= delta
    if pickup_update_timer <= 0.0:
        _update_pickups(max(delta, PICKUP_UPDATE_INTERVAL))
        pickup_update_timer = PICKUP_UPDATE_INTERVAL
    combat_update_timer -= delta
    if combat_update_timer <= 0.0:
        _update_combat(max(delta, COMBAT_UPDATE_INTERVAL))
        combat_update_timer = COMBAT_UPDATE_INTERVAL
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
            _finish_run(true, "Extraction complete.")
        return

    time_left = maxf(0.0, time_left - delta)
    if time_left <= 0.0:
        _finish_run(false, "Time ran out before extraction.")
        return

    var desired_velocity := Vector2.ZERO
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var dir: Vector2 = hovered_world_pos - ship_pos
        if dir.length() > 4.0:
            desired_velocity = dir.normalized() * BALANCE.get_move_speed(upgrades)
    ship_vel = ship_vel.move_toward(desired_velocity, INPUT_ACCEL * delta)
    ship_vel = ship_vel.move_toward(Vector2.ZERO, INPUT_FRICTION * max(1.0, BALANCE.get_move_speed(upgrades) * 0.018) * delta)
    var candidate: Vector2 = ship_pos + ship_vel * delta
    var collision_index: int = _cell_index_from_world(candidate)
    if _is_cell_solid(collision_index):
        if shields_left > 0:
            shields_left -= 1
            ship_vel = -ship_vel * 0.35
            candidate = last_safe_pos
            status_label.text = "Shield burned on impact."
        else:
            _finish_run(false, "The rig shattered on impact.")
            return
    else:
        last_safe_pos = candidate
    ship_pos = _clamp_ship_to_world(candidate)

    if ship_pos.distance_to(base_center) <= BASE_RADIUS and (cargo_money > 0 or cargo_oil > 0):
        extraction_timer += delta
        extraction_label.visible = true
        extraction_label.text = "Extraction in %.1fs" % maxf(0.0, EXTRACTION_DELAY - extraction_timer)
        if extraction_timer >= EXTRACTION_DELAY:
            extracting = true
            extraction_ascent_timer = 0.0
            status_label.text = "Rig launched back to the surface."
    else:
        extraction_timer = 0.0
        extraction_label.visible = false

func _update_pickups(delta: float) -> void:
    if pickups.is_empty():
        return
    var pickup_radius: float = BALANCE.get_pickup_radius(upgrades)
    var capacity: int = BALANCE.get_cargo_capacity(upgrades)
    var survivors: Array[Dictionary] = []
    for pickup in pickups:
        var new_position: Vector2 = Vector2(pickup.get("position", Vector2.ZERO)) + Vector2(float(pickup.get("drift_x", 0.0)), float(pickup.get("drift_y", 0.0))) * delta
        pickup["position"] = new_position
        var collect: bool = new_position.distance_to(ship_pos) <= pickup_radius
        if not collect:
            for companion_pos in last_companion_positions:
                if new_position.distance_to(companion_pos) <= pickup_radius:
                    collect = true
                    break
        if collect and cargo_units < capacity:
            cargo_units += int(pickup.get("cargo", 1))
            cargo_money += int(pickup.get("money", 0))
            cargo_oil += int(pickup.get("oil", 0))
            continue
        survivors.append(pickup)
    pickups = survivors

func _update_combat(delta: float) -> void:
    attack_timer -= delta
    companion_attack_stagger_timer -= delta
    attack_flash_timer = maxf(0.0, attack_flash_timer - delta)
    if extracting:
        return
    var target_count: int = BALANCE.get_multi_target_count(upgrades)
    var attack_radius: float = BALANCE.get_attack_radius(upgrades)
    var base_damage: float = BALANCE.get_attack_damage(upgrades)
    if attack_timer <= 0.0:
        attack_timer = 1.0 / maxf(0.25, BALANCE.get_attack_rate(upgrades))
        var primary_targets: Array[int] = _find_nearest_solid_cells(ship_pos, attack_radius, target_count)
        if not primary_targets.is_empty():
            _fire_attack_bundle(ship_pos, primary_targets, base_damage)
    var companion_damage_value: float = BALANCE.get_companion_damage(upgrades)
    var companion_targets: int = BALANCE.get_companion_target_count(upgrades)
    if last_companion_positions.is_empty():
        return
    if companion_attack_stagger_timer > 0.0:
        return
    companion_attack_stagger_timer = COMPANION_ATTACK_STAGGER
    var companion_index: int = companion_attack_cursor % last_companion_positions.size()
    companion_attack_cursor += 1
    var companion_pos: Vector2 = last_companion_positions[companion_index]
    var targets: Array[int] = _find_nearest_solid_cells(companion_pos, attack_radius * 0.82, companion_targets)
    if targets.is_empty():
        return
    _fire_attack_bundle(companion_pos, targets, companion_damage_value)

func _fire_attack_bundle(origin: Vector2, targets: Array[int], base_damage: float) -> void:
    for cell_index in targets:
        if damage_events_remaining <= 0:
            break
        var damage: float = base_damage
        var block_info: Dictionary = _get_block_info(cell_index)
        if bool(block_info.get("boss", false)) or int(block_info.get("layer_depth", 1)) >= BALANCE.MAX_DEPTH_LEVEL:
            damage *= BALANCE.get_core_damage_multiplier(upgrades)
        if rng.randf() < BALANCE.get_crit_chance(upgrades):
            damage *= BALANCE.get_crit_multiplier(upgrades)
        _damage_block(cell_index, damage)
        if rng.randf() < BALANCE.get_explosion_chance(upgrades):
            for splash_index in _get_neighbor_targets(cell_index, SPLASH_OFFSETS, MAX_SPLASH_TARGETS):
                if damage_events_remaining <= 0:
                    break
                _damage_block(splash_index, damage * 0.48)
        if rng.randf() < BALANCE.get_chain_chance(upgrades):
            for chain_index in _get_neighbor_targets(cell_index, CHAIN_OFFSETS, MAX_CHAIN_TARGETS):
                if damage_events_remaining <= 0:
                    break
                _damage_block(chain_index, damage * 0.42)
    last_attack_origin = origin
    last_attack_target = _cell_center(int(targets[0]))
    attack_flash_timer = ATTACK_FLASH_TIME

func _damage_block(cell_index: int, damage: float) -> void:
    if damage_events_remaining <= 0:
        return
    if not _is_cell_solid(cell_index):
        return
    damage_events_remaining -= 1
    var health_before: float = _get_cell_health(cell_index)
    var health_after: float = health_before - damage
    if health_after <= 0.0:
        _destroy_cell(cell_index)
        return
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
    _spawn_pickups_for_block(cell_index, block_info)
    _mark_minimap_dirty()
    persist_save_counter += 1
    if persist_save_counter >= PERSIST_BATCH_SAVE_INTERVAL:
        _persist_destroyed_cells(false)
        persist_save_counter = 0
    if bool(block_info.get("boss", false)):
        boss_defeated = true
        _finish_run(true, "The core guardian collapsed.")

func _spawn_pickups_for_block(cell_index: int, block_info: Dictionary) -> void:
    var origin: Vector2 = _cell_center(cell_index)
    var payout: int = int(round(float(block_info.get("value", 1)) * BALANCE.get_value_multiplier(upgrades)))
    var pickup_money: int = payout
    var pickup_oil: int = 1 if bool(block_info.get("oil", false)) else 0
    var pickup_cargo: int = 1 + int(block_info.get("cargo_weight", 0))
    if _should_auto_collect_pickup(origin, pickup_cargo):
        _collect_pickup_values(pickup_money, pickup_oil, pickup_cargo)
        return
    if pickups.size() >= MAX_WORLD_PICKUPS:
        _merge_pickup_bundle(origin, pickup_money, pickup_oil, pickup_cargo)
        return
    pickups.append({
        "position": origin,
        "money": pickup_money,
        "oil": pickup_oil,
        "cargo": pickup_cargo,
        "drift_x": rng.randf_range(-PICKUP_DRIFT, PICKUP_DRIFT),
        "drift_y": rng.randf_range(-PICKUP_DRIFT, PICKUP_DRIFT),
    })

func _finish_run(returned: bool, reason: String) -> void:
    if run_finished:
        return
    run_finished = true
    extracting = false
    _persist_destroyed_cells(true)
    var keep_percent: float = 1.0 if returned else BALANCE.get_salvage_keep_percent(upgrades)
    var stranded_resources: Dictionary = _get_stranded_pickup_totals()
    var total_money: int = cargo_money + int(stranded_resources.get("money", 0))
    var total_oil: int = cargo_oil + int(stranded_resources.get("oil", 0))
    var money_award: int = int(round(float(total_money) * keep_percent))
    var oil_award: int = int(round(float(total_oil) * keep_percent))
    var results := {
        "money": money_award,
        "oil": oil_award,
        "depth_level": current_depth_level,
        "nodes_broken": nodes_mined,
        "boss_defeated": boss_defeated,
        "destroyed_cells": persistent_data.get("destroyed_cells", []).duplicate(true),
        "summary_text": "%s Banked $%d and %d oil." % [reason, money_award, oil_award],
    }
    PROGRESS.apply_run_results(results)
    summary_overlay.visible = true
    summary_label.text = "[center]%s\n\nLayer %d\nBlocks mined this run: %d\nPersistent pit clear: %.1f%%\nCash banked: $%d\nOil banked: %d\nShields left: %d[/center]" % [
        reason,
        current_depth_level,
        nodes_mined,
        _get_persistent_clear_percent(),
        money_award,
        oil_award,
        shields_left,
    ]

func _persist_destroyed_cells(mark_boss: bool) -> void:
    if newly_destroyed_cells.is_empty() and not mark_boss:
        return
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

func _return_to_upgrades() -> void:
    SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _update_camera(delta: float) -> void:
    camera_pos = camera_pos.lerp(ship_pos, clampf(delta * CAMERA_LERP, 0.0, 1.0))
    var viewport_size: Vector2 = get_viewport_rect().size
    camera_pos.x = clampf(camera_pos.x, viewport_size.x * 0.5, max(viewport_size.x * 0.5, world_size.x - viewport_size.x * 0.5))
    camera_pos.y = clampf(camera_pos.y, viewport_size.y * 0.5, max(viewport_size.y * 0.5, world_size.y - viewport_size.y * 0.5))

func _refresh_hud() -> void:
    timer_label.text = "Time: %.1fs" % time_left
    cargo_label.text = "Cargo: %d / %d" % [cargo_units, BALANCE.get_cargo_capacity(upgrades)]
    wallet_label.text = "Haul: $%d  |  Permanent Cash: $%d" % [cargo_money, PROGRESS.get_wallet()]
    oil_label.text = "Oil: %d  |  Meta Oil: %d" % [cargo_oil, PROGRESS.get_oil_wallet()]
    layer_label.text = "Target Layer %d  |  Current %s  |  Clear %.1f%%" % [current_depth_level, current_layer_name, _get_persistent_clear_percent()]
    if not run_finished and not extracting:
        status_label.text = "Shields %d  |  Wings %d  |  Radius %.0f" % [shields_left, BALANCE.get_companion_ship_count(upgrades), BALANCE.get_attack_radius(upgrades)]
    if fps_label != null:
        fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _update_layer_label() -> void:
    var row: int = clampi(int(ship_pos.y / CELL_SIZE), 0, max(0, world_rows - 1))
    current_layer_name = str(BALANCE.get_layer_for_depth(_layer_depth_for_row(row)).get("name", "Topsoil"))

func _draw() -> void:
    var viewport_size: Vector2 = get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.1, 0.08, 0.06, 1.0), true)
    draw_rect(Rect2(_world_to_screen(Vector2.ZERO), Vector2(world_size.x, float(TOP_BUFFER_ROWS) * CELL_SIZE)), Color(0.13, 0.15, 0.18, 1.0), true)
    draw_rect(Rect2(_world_to_screen(Vector2.ZERO), Vector2(pit_origin_x, world_size.y)), Color(0.14, 0.16, 0.18, 1.0), true)

    var start_col: int = max(0, int(floor((camera_pos.x - viewport_size.x * 0.5) / CELL_SIZE)) - 1)
    var end_col: int = min(GRID_COLS - 1, int(ceil((camera_pos.x + viewport_size.x * 0.5) / CELL_SIZE)) + 1)
    var start_row: int = max(0, int(floor((camera_pos.y - viewport_size.y * 0.5) / CELL_SIZE)) - 1)
    var end_row: int = min(world_rows - 1, int(ceil((camera_pos.y + viewport_size.y * 0.5) / CELL_SIZE)) + 1)
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
            if damaged_cells.has(index):
                var max_health: float = float(block_info.get("max_health", 1.0))
                var health_ratio: float = clampf(_get_cell_health(index) / maxf(1.0, max_health), 0.0, 1.0)
                draw_rect(Rect2(rect.position, Vector2(rect.size.x * health_ratio, 3.0)), Color(block_info.get("accent", Color.BLACK)), true)

    for layer_index in range(0, current_depth_level + 1):
        var world_y: float = float(TOP_BUFFER_ROWS + layer_index * LAYER_HEIGHT) * CELL_SIZE
        var line_y: float = _world_to_screen(Vector2(0.0, world_y)).y
        draw_line(Vector2(0.0, line_y), Vector2(viewport_size.x, line_y), Color(1.0, 1.0, 1.0, 0.08), 1.0)

    draw_rect(Rect2(_world_to_screen(Vector2(pit_origin_x - 4.0, float(TOP_BUFFER_ROWS) * CELL_SIZE)), Vector2(8.0, world_size.y - float(TOP_BUFFER_ROWS) * CELL_SIZE)), Color(0.26, 0.22, 0.16, 1.0), true)
    draw_circle(_world_to_screen(base_center), BASE_RADIUS, Color(0.12, 0.34, 0.18, 0.26))
    draw_arc(_world_to_screen(base_center), BASE_RADIUS, 0.0, TAU, 64, Color(0.7, 0.96, 0.72, 0.9), 3.0)

    draw_circle(_world_to_screen(ship_pos), SHIP_RADIUS, Color(0.88, 0.92, 1.0, 1.0))
    draw_arc(_world_to_screen(ship_pos), BALANCE.get_attack_radius(upgrades), 0.0, TAU, 80, Color(0.95, 0.42, 0.28, ATTACK_RADIUS_DRAW_ALPHA), 2.0)
    draw_arc(_world_to_screen(ship_pos), BALANCE.get_pickup_radius(upgrades), 0.0, TAU, 80, Color(0.3, 0.9, 0.74, PICKUP_RADIUS_DRAW_ALPHA), 2.0)
    if attack_flash_timer > 0.0:
        draw_line(_world_to_screen(last_attack_origin), _world_to_screen(last_attack_target), Color(1.0, 0.8, 0.46, attack_flash_timer / ATTACK_FLASH_TIME), ATTACK_LINE_WIDTH)

    for pickup in pickups:
        var pickup_color := Color(0.94, 0.8, 0.3, 1.0)
        if int(pickup.get("oil", 0)) > 0:
            pickup_color = Color(0.14, 0.14, 0.18, 1.0)
        draw_circle(_world_to_screen(Vector2(pickup.get("position", Vector2.ZERO))), 4.0, pickup_color)

    for companion_pos in last_companion_positions:
        draw_circle(_world_to_screen(companion_pos), 7.0, Color(0.58, 0.86, 1.0, 1.0))

func draw_minimap_into(control: Control) -> void:
    var size: Vector2 = control.size
    control.draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.03, 0.04, 0.92), true)
    var block_w: float = size.x / float(GRID_COLS)
    var block_h: float = size.y / float(max(1, world_rows))
    control.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, float(TOP_BUFFER_ROWS) * block_h)), Color(0.12, 0.14, 0.17, 1.0), true)
    for row in range(0, world_rows, MINIMAP_SAMPLE_STEP):
        for col in range(SAFE_ZONE_COLS, GRID_COLS, MINIMAP_SAMPLE_STEP):
            var index: int = row * GRID_COLS + col
            if not _is_cell_solid(index):
                continue
            var block_info: Dictionary = _get_block_info(index)
            control.draw_rect(Rect2(Vector2(float(col) * block_w, float(row) * block_h), Vector2(maxf(1.0, block_w * MINIMAP_SAMPLE_STEP), maxf(1.0, block_h * MINIMAP_SAMPLE_STEP))), Color(block_info.get("color", Color.WHITE)), true)
    var base_pos := Vector2(base_center.x / world_size.x * size.x, base_center.y / world_size.y * size.y)
    control.draw_circle(base_pos, 5.0, Color(0.54, 0.96, 0.7, 1.0))
    var ship_mini := Vector2(ship_pos.x / world_size.x * size.x, ship_pos.y / world_size.y * size.y)
    control.draw_circle(ship_mini, 3.0, Color(1.0, 1.0, 1.0, 1.0))

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
                if found.size() >= limit:
                    return found
                _try_add_target_cell(found, bottom, col, origin, radius_sq, limit)
                if found.size() >= limit:
                    return found
            for row in range(top + 1, bottom):
                _try_add_target_cell(found, row, left, origin, radius_sq, limit)
                if found.size() >= limit:
                    return found
                _try_add_target_cell(found, row, right, origin, radius_sq, limit)
                if found.size() >= limit:
                    return found
        if found.size() >= limit:
            return found
    return found

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
    var is_boss: bool = _is_boss_cell(row, col)
    var value: int = int(layer.get("value", 1))
    var max_health: float = float(layer.get("health", 10.0))
    var cargo_weight: int = int(layer.get("cargo_weight", 0))
    var color: Color = layer.get("color", Color.WHITE)
    var accent: Color = layer.get("accent", Color.BLACK)
    var has_oil: bool = layer_depth >= 2 and _hash_float(row, col, 0.19) < OIL_CHANCE
    if has_oil:
        value += int(layer_depth * 6)
        max_health *= 1.6
        cargo_weight += 1
        color = Color(0.08, 0.08, 0.1, 1.0)
        accent = Color(0.68, 0.44, 0.18, 1.0)
    if is_boss:
        value = 420
        max_health = 1800.0
        cargo_weight = 0
        color = Color(0.84, 0.16, 0.14, 1.0)
        accent = Color(1.0, 0.84, 0.4, 1.0)
    var block_info := {
        "layer_depth": layer_depth,
        "layer_name": str(layer.get("name", "Layer")),
        "color": color,
        "accent": accent,
        "value": value,
        "max_health": max_health,
        "oil": has_oil,
        "boss": is_boss,
        "cargo_weight": cargo_weight,
    }
    block_info_cache[cell_index] = block_info
    return block_info

func _get_cell_health(cell_index: int) -> float:
    if damaged_cells.has(cell_index):
        return float(damaged_cells[cell_index])
    return float(_get_block_info(cell_index).get("max_health", 1.0))

func _build_companion_positions() -> Array[Vector2]:
    var positions: Array[Vector2] = []
    var companion_count: int = BALANCE.get_companion_ship_count(upgrades)
    for index in range(companion_count):
        var angle: float = TAU * float(index) / float(max(1, companion_count)) + float(Time.get_ticks_msec()) / 780.0
        positions.append(ship_pos + Vector2.RIGHT.rotated(angle) * 42.0)
    return positions

func _get_persistent_clear_percent() -> float:
    var mineable_rows: int = max(1, world_rows - TOP_BUFFER_ROWS)
    var total_mineable: float = float(max(1, (GRID_COLS - SAFE_ZONE_COLS) * mineable_rows))
    return 100.0 * float(persistent_destroyed_count) / total_mineable

func _is_boss_cell(row: int, col: int) -> bool:
    return current_depth_level >= BALANCE.MAX_DEPTH_LEVEL and row >= world_rows - 8 and col >= GRID_COLS - 22 and col <= GRID_COLS - 14

func _hash_float(row: int, col: int, salt: float) -> float:
    var value: float = sin(float(row) * 12.9898 + float(col) * 78.233 + salt * 437.0) * 43758.5453
    return value - floor(value)

func _layer_depth_for_row(row: int) -> int:
    var adjusted_row: int = max(0, row - TOP_BUFFER_ROWS)
    return clampi(1 + int(floor(float(adjusted_row) / float(LAYER_HEIGHT))), 1, BALANCE.MAX_DEPTH_LEVEL)

func _cell_center(index: int) -> Vector2:
    var col: int = index % GRID_COLS
    var row: int = index / GRID_COLS
    return Vector2((float(col) + 0.5) * CELL_SIZE, (float(row) + 0.5) * CELL_SIZE)

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
    return Vector2(
        clampf(pos.x, SHIP_RADIUS, world_size.x - SHIP_RADIUS),
        clampf(pos.y, SHIP_RADIUS, world_size.y - SHIP_RADIUS)
    )

func _mark_minimap_dirty() -> void:
    if minimap != null:
        minimap.mark_dirty()

func _try_add_target_cell(found: Array[int], row: int, col: int, origin: Vector2, radius_sq: float, limit: int) -> void:
    if found.size() >= limit:
        return
    if row < TOP_BUFFER_ROWS or row >= world_rows or col < SAFE_ZONE_COLS or col >= GRID_COLS:
        return
    var index: int = row * GRID_COLS + col
    if not _is_cell_solid(index):
        return
    var center_x: float = (float(col) + 0.5) * CELL_SIZE
    var center_y: float = (float(row) + 0.5) * CELL_SIZE
    if origin.distance_squared_to(Vector2(center_x, center_y)) > radius_sq:
        return
    found.append(index)

func _get_neighbor_targets(cell_index: int, offsets: Array, limit: int) -> Array[int]:
    var results: Array[int] = []
    var center_col: int = cell_index % GRID_COLS
    var center_row: int = cell_index / GRID_COLS
    for offset_variant in offsets:
        var offset: Vector2i = offset_variant
        var row: int = center_row + offset.y
        var col: int = center_col + offset.x
        if row < TOP_BUFFER_ROWS or row >= world_rows or col < SAFE_ZONE_COLS or col >= GRID_COLS:
            continue
        var neighbor_index: int = row * GRID_COLS + col
        if not _is_cell_solid(neighbor_index):
            continue
        results.append(neighbor_index)
        if results.size() >= limit:
            break
    return results

func _should_auto_collect_pickup(position: Vector2, cargo_cost: int) -> bool:
    if cargo_units + cargo_cost > BALANCE.get_cargo_capacity(upgrades):
        return false
    var pickup_radius: float = BALANCE.get_pickup_radius(upgrades)
    if position.distance_to(ship_pos) <= pickup_radius:
        return true
    for companion_pos in last_companion_positions:
        if position.distance_to(companion_pos) <= pickup_radius:
            return true
    return false

func _collect_pickup_values(money: int, oil: int, cargo: int) -> void:
    var capacity: int = BALANCE.get_cargo_capacity(upgrades)
    if cargo_units + cargo > capacity:
        return
    cargo_units += cargo
    cargo_money += money
    cargo_oil += oil

func _merge_pickup_bundle(position: Vector2, money: int, oil: int, cargo: int) -> void:
    if pickups.is_empty():
        pickups.append({
            "position": position,
            "money": money,
            "oil": oil,
            "cargo": cargo,
            "drift_x": 0.0,
            "drift_y": 0.0,
        })
        return
    var pickup: Dictionary = pickups[pickups.size() - 1]
    pickup["money"] = int(pickup.get("money", 0)) + money
    pickup["oil"] = int(pickup.get("oil", 0)) + oil
    pickup["cargo"] = int(pickup.get("cargo", 0)) + cargo
    pickup["position"] = (Vector2(pickup.get("position", position)) + position) * 0.5
    pickups[pickups.size() - 1] = pickup

func _get_stranded_pickup_totals() -> Dictionary:
    var totals := {
        "money": 0,
        "oil": 0,
    }
    if pickups.is_empty():
        return totals
    for pickup in pickups:
        totals["money"] = int(totals.get("money", 0)) + int(pickup.get("money", 0))
        totals["oil"] = int(totals.get("oil", 0)) + int(pickup.get("oil", 0))
    return totals
