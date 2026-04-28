extends Node2D
class_name OpenPitEmpireMain

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const PLANET_DATA_SCRIPT := preload("res://Games/OpenPitEmpire/OpenPitEmpirePlanetData.gd")
const PLANET_RENDERER_SCRIPT := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpirePlanetRenderer.gd")
const PERF_GRAPH_SCRIPT := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpirePerfGraph.gd")
const MINIMAP_SCRIPT := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireMiniMap.gd")
const DROP_RENDERER_SCRIPT := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireDropRenderer.gd")
const SHIP_RENDERER_SCRIPT := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireShipRenderer.gd")
const BREACH_CHAT_SCRIPT := preload("res://Games/OpenPitEmpire/OpenPitEmpireBreachChat.gd")

const BLOCK_SIZE := 32.0
const PLANET_RADIUS_CELLS := 280
const SHIP_RADIUS := 10.0
const RETURN_ZONE_RADIUS := 220.0
const RETURN_ZONE_DELAY := 1.5
const RETURN_ZONE_ARM_DISTANCE_MULT := 1.15
const EXTRACTION_ASCENT_TIME := 1.1
const EXTRACTION_ASCENT_SCREEN_MARGIN := 180.0
const HIT_FLASH_DURATION := 0.15
const POWER_OVERCHARGE_PULSE_DECAY := 2.4
const POWER_BASE_GAIN := 5.0
const POWER_SPECIAL_BLOCK_MULT := 2.0
const POWER_DRAIN_PER_SECOND := 30.0
const POWER_SPEED_BONUS := 220.0
const POWER_ATTACK_DAMAGE_MULT := 2.0
const POWER_ATTACK_SPEED_MULT := 1.25
const POWER_GAIN_MULT := 0.5
const ARC_DURATION := 0.15
const CHAIN_ARC_DURATION := 0.2
const DRONE_BEAM_DURATION := 0.08
const DRONE_MISSILE_LIFETIME := 3.6
const DRONE_MINE_LIFETIME := 4.2
const MAX_ACTIVE_HIT_FLASHES := 72
const MAX_ACTIVE_ELECTRIC_ARCS := 18
const MAX_ACTIVE_CHAIN_ARCS := 18
const MAX_ACTIVE_DRONE_BEAMS := 24
const MAX_ACTIVE_DRONE_MISSILES := 6
const MAX_ACTIVE_DRONE_MINES := 4
const PICKUP_SPAWN_SOFT_CAP_PER_FRAME := 24
const BLOCK_BREAK_AUDIO_COOLDOWN_MS := 45
const CORE_BREAK_AUDIO_COOLDOWN_MS := 90
const PERF_PROBE_HISTORY_SIZE := 600
const PERF_CAPTURE_WARMUP_SECONDS := 0.5
const ATTACK_LOAD_SOFT_LIMIT := 64
const ATTACK_LOAD_HARD_LIMIT := 96
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
const PERF_DEBUG_REFRESH_INTERVAL := 0.25
const DRONE_RANGE := 230.0
const DRONE_MISSILE_RANGE := 520.0
const DRONE_FOLLOW_SPEED := 11.0
const DRONE_SPACING := 16.0
const DRONE_BEHIND_DIST := 18.0
const DRONE_SUPPORT_DROP_ATTACKS := 200
const DRONE_SUPPORT_DROP_LIFETIME := 10.0
const DRONE_SUPPORT_DROP_SPEED := 80.0
const DRONE_MISSILE_SPLASH_RADIUS_CELLS := 1
const DRONE_MINE_SPLASH_RADIUS_CELLS := 1
const DRONE_MISSILE_DAMAGE_MULT := 1.35
const DRONE_MINE_DAMAGE_MULT := 2.4
const DRONE_MISSILE_TURN_RATE := 4.0
const DRONE_MINE_TURN_RATE := 2.2
const DRONE_MISSILE_SPEED := 240.0
const DRONE_MINE_SPEED := 120.0
const SEISMIC_CHARGE_INTERVAL := 0.32
const SEISMIC_POWERUP_INTERVAL := 0.45
const SEISMIC_CHARGE_AHEAD_DISTANCE := 180.0
const SEISMIC_CHARGE_SPLASH_RADIUS_CELLS := 1
const SEISMIC_CHARGE_DAMAGE_MULT := 0.9
const SEISMIC_POWERUP_DAMAGE_MULT := 0.4
const SHOCKWAVE_DAMAGE_MULT := 0.45
const SEISMIC_CHARGE_VISUAL_DURATION := 0.42
const CAMERA_ZOOM_STOPPED := 1.2
const CAMERA_ZOOM_FULL_SPEED := 0.8
const CAMERA_ZOOM_BLEND_TIME := 0.35
const BREACH_LOG_MAX_LINES := 8
const BREACH_LOG_IDLE_INTERVAL := 2.8
const HACKER_TYPER_MAX_LINES := 4
const HACKER_TYPER_SHOT_WINDOW := 0.12
const HACKER_TYPER_IDLE_LINES := [
    "def mask_telemetry(trace):\n    trace.route = dead_mall_mirrors\n    return trace.fade_out()",
    "for watcher in audit_glass:\n    watcher.feed(decoy_noise)\n    watcher.forget(real_entry)",
    "while shell.is_sleeping():\n    reroute(lookup_pings, toward=\"salt_archive\")\n    drift.deeper()",
    "if ledger.pings_back():\n    ledger.echo_into(sacrificial_accounts)\n    sleep(0.2)",
    "with ghost_handshake() as tunnel:\n    tunnel.borrow(clean_credentials)\n    tunnel.leave_no_names()",
]
const HACKER_TYPER_ACTIVE_LINES := [
    "def reroute_clinic_ledgers(batch):\n    for ledger in batch:\n        ledger.owner = \"public\"\n        receipts.push(ledger)",
    "for cert in rotate(stolen_certs):\n    spoof(trace=cert)\n    shadow_jump(next_shell)",
    "if ration_audits.locked:\n    ration_audits.decrypt()\n    black_budget_shards.dump(to=dropbox)",
    "with ghost_tunnel(\"escrow\") as hole:\n    hole.grind(teeth=True)\n    push_receipts(hole.exfil())",
    "for injunction in civic_cache:\n    injunction.unseal()\n    archive.publish(injunction)",
    "gap = permissions.fork(warm=True)\nif gap.open:\n    rig.walk_through(gap)\n    shell.bleed()",
    "debt_index.poison(seed=feralroot_key)\nfor debtor in trapped_accounts:\n    debtor.release()",
    "while counter_hack_weather.spinning():\n    counter_hack_weather.crack()\n    drill.deeper()",
    "exec_auth.salt(level=\"panic\")\nclean_money = siphon(executive_reserve)\nreturn clean_money",
]
const HACKER_TYPER_PRESSURE_LINES := [
    "if core.handshake.wobbling():\n    pry(core.seam, wider=True)\n    keep_pressure_on()",
    "command_throat = seize(core)\nwhile command_throat.blinking():\n    hold_fast(command_throat)",
    "retaliation_loop.jam()\nif shell.opens():\n    punch_through(shell)\n    mark_exit_later()",
    "for cert in clean_room_certs:\n    cert.burn()\n    lock.peel_back(layer=1)",
    "watchdog_queue.bleed(rate=\"slow\")\nif watchdog_queue.forgets_us():\n    take_the_core()",
]
const POWERUP_TYPES := ["haste", "magnet", "seismic_charge"]
const POWERUP_DURATION := 12.0
const POWERUP_RADIUS := 18.0
const POWERUP_BASE_SPEED := 72.0
const BOTTOM_CUTSCENE_DURATION := 2.6
const SIDE_SHOT_INTERVAL := 2.4
const SIDE_SHOT_SPEED := 210.0
const SIDE_SHOT_LIFETIME := 6.0
const SIDE_SHOT_RADIUS := 12.0
const SIDE_ATTACKER_COUNT_PER_SIDE := 2
const SIDE_ATTACKER_INSET_CELLS := 5
const SIDE_ATTACKER_TRACK_SPEED := 4.5
const SIDE_ATTACKER_SHOT_INTERVAL := 1.9
const SIDE_ATTACKER_VERTICAL_SPACING := 14
const SIDE_ATTACKER_VERTICAL_SWAY := 18.0
const FUNNEL_REENTRY_SCAN_RADIUS_Y := 10
const FUNNEL_REENTRY_SCAN_COLUMNS := 14
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
const SUMMER_LASER_TRACK_SPEED := 2.4
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
const DEFAULT_STARTING_BARRIERS := 1
const SHIELD_HIT_INVULN_TIME := 1.0
const SHIELD_HIT_RECOVERY_TIME := 1.0
const SHIELD_HIT_ACCEL_START_SCALE := 0.33333334
const SHIELD_HIT_BOUNCE_DISTANCE := SHIP_RADIUS * 6.0
const SHIP_RENDER_ROTATION_STEP_DEGREES := 5.0

enum BlockType { NORMAL, CORE, ELECTRIC, GOLD, THORN }
enum OutlineMode { OFF, GROUP_EDGES, ALL_BLOCKS, ALL_BLOCKS_MASK }
enum RenderDetailMode { AUTO, FULL, HEAVY, ULTRA }
const PLANET_OUTLINE_RADIUS_MIN := 6
const PLANET_OUTLINE_RADIUS_MAX := 64
const PLANET_OUTLINE_RADIUS_STEP := 2
const PLANET_OUTLINE_RADIUS_DEFAULT := 32
const DETAIL_THRESHOLD_MIN := 64
const DETAIL_THRESHOLD_MAX := 20000
const DETAIL_THRESHOLD_STEP := 256
const DETAIL_THRESHOLD_FULL_GAP_MIN := 96
const DETAIL_THRESHOLD_ULTRA_GAP_MIN := 128
const DETAIL_THRESHOLD_FULL_DEFAULT := 288
const DETAIL_THRESHOLD_HEAVY_DEFAULT := 900
const DETAIL_THRESHOLD_ULTRA_DEFAULT := 1400

var rng := RandomNumberGenerator.new()
var persistent_data: Dictionary = {}
var upgrades: Dictionary = {}
var runtime_stats: Dictionary = {}
var planet_data
var blocks: Dictionary = {}
var exposed_edges: Dictionary = {}
var damaged_cells: Dictionary = {}
var hit_timers: Dictionary = {}
var pickups: Array[Dictionary] = []
var destroyed_cells_this_run: Dictionary = {}
var planet_outline_mode := OutlineMode.GROUP_EDGES
var planet_outline_radius_cells := PLANET_OUTLINE_RADIUS_DEFAULT
var render_detail_mode := RenderDetailMode.AUTO
var full_detail_visible_grid_cells := DETAIL_THRESHOLD_FULL_DEFAULT
var heavy_detail_visible_grid_cells := DETAIL_THRESHOLD_HEAVY_DEFAULT
var ultra_detail_visible_grid_cells := DETAIL_THRESHOLD_ULTRA_DEFAULT
var _frame_destroyed_blocks := 0

var ship_pos := Vector2.ZERO
var ship_vel := Vector2.ZERO
var spawn_position := Vector2.ZERO
var camera_pos := Vector2.ZERO
var planet_center := Vector2.ZERO
var planet_radius_cells := 0
var current_depth_level := 1
var current_layer_depth := 1
var current_layer_name := ""
var time_left := 30.0
var run_finished := false
var has_left_spawn := false
var return_zone_radius := RETURN_ZONE_RADIUS
var return_zone_timer := 0.0
var extracting := false
var extraction_timer := 0.0
var extraction_start_pos := Vector2.ZERO
var extraction_target_pos := Vector2.ZERO
var extraction_camera_anchor := Vector2.ZERO
var cargo_units := 0
var cargo_money := 0
var nodes_mined := 0
var xp_earned_this_run := 0
var barriers_left := 0
var shield_invuln_timer := 0.0
var shield_recovery_timer := 0.0
var boss_defeated := false
var current_combo := 0
var combo_timer := 0.0
var combo_peak := 0
var current_power := 0.0
var power_peak := 0.0
var power_active := false
var power_ring_overcharge := 0.0
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
var ship_render_rotation_offset_degrees := 0.0
var last_move_dir := Vector2.UP
var ship_glow_phase := 0.0
var ship_trail: Array[Dictionary] = []
var ship_trail_timer := 0.0
var hud_refresh_timer := 0.0
var perf_debug_refresh_timer := 0.0
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
var drone_missiles: Array[Dictionary] = []
var drone_mines: Array[Dictionary] = []
var drone_timers: Array[float] = []
var drone_targets: Array[Vector2] = []
var drone_attack_counter := 0
var seismic_charge_timer := 0.0
var seismic_charge_bursts: Array[Dictionary] = []
var cipher_laser_states: Dictionary = {}
var ghost_debris: Array[Dictionary] = []
var root_cross_lasers: Dictionary = {}
var ghost_debris_timers: Dictionary = {}
var hacker_typer_label: RichTextLabel
var hacker_typer_current_text := ""
var hacker_typer_revealed_chars := 0
var hacker_typer_cursor_on := true
var hacker_typer_char_timer := 0.0
var hacker_typer_hold_timer := 0.0
var hacker_typer_shot_timer := 0.0
var hacker_typer_is_attacking := false
var hacker_typer_im_in_timer := 0.0
var hacker_typer_history: Array[String] = []
var combo_milestones_hit: Dictionary = {}
var roaming_powerups: Array[Dictionary] = []
var active_powerup_timers := {"haste": 0.0, "magnet": 0.0, "seismic_charge": 0.0}
var bottom_phase_unlocked := false
var bottom_cutscene_timer := 0.0
var bottom_cutscene_anchor := Vector2.ZERO
var side_shot_timer := SIDE_SHOT_INTERVAL
var side_projectiles: Array[Dictionary] = []
var side_attackers: Array[Dictionary] = []

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
var perf_probe_label: RichTextLabel
var minimap: Control
var summary_overlay: ColorRect
var summary_label: RichTextLabel
var summary_status_label: Label
var summary_return_button: Button
var summary_save_anim_time := 0.0
var summary_save_pending := false
var summary_save_phase := "idle"
var summary_pending_saved_section_ids: Array = []
var breach_log_label: RichTextLabel
var bottom_cinematic_overlay: Control
var bottom_letterbox_top: ColorRect
var bottom_letterbox_bottom: ColorRect
var bottom_cutscene_label: RichTextLabel
var breach_log_lines: Array[String] = []
var breach_log_idle_timer := 0.0
var breach_chat
var final_core_exposed := false
var pickups_spawned_this_frame := 0
var _last_block_break_audio_ms := -100000
var _last_core_break_audio_ms := -100000
var _perf_probe_enabled := false
var _last_perf_fps_text := ""
var _last_perf_probe_text := ""
const PERF_PROBE_KEYS := [
    "process_frame",
    "update_timers",
    "update_power_state",
    "update_ship",
    "update_ship_trail",
    "update_layer_name",
    "update_camera_zoom",
    "update_breach_log",
    "refresh_hud",
    "update_combat",
    "update_pickups",
    "update_core_attacks",
    "update_perf_debug",
    "auto_fire_laser",
    "update_mega_beam",
    "damage_block",
    "renderer_draw",
    "renderer_bg",
    "renderer_fill",
    "renderer_fill_resize",
    "renderer_fill_rebuild",
    "renderer_fill_upload",
    "renderer_edge",
    "renderer_blocks",
    "renderer_power_blocks",
    "renderer_overlays",
    "perf_graph_draw",
    "ship_draw",
    "ship_draw_rings",
    "ship_draw_drones",
]
const RENDERER_PROBE_KEYS := [
    "renderer_bg",
    "renderer_fill",
    "renderer_fill_resize",
    "renderer_fill_rebuild",
    "renderer_fill_upload",
    "renderer_edge",
    "renderer_blocks",
    "renderer_power_blocks",
    "renderer_overlays",
]
var _perf_probe_history := {
    "process_frame": [],
    "update_timers": [],
    "update_power_state": [],
    "update_ship": [],
    "update_ship_trail": [],
    "update_layer_name": [],
    "update_camera_zoom": [],
    "update_breach_log": [],
    "refresh_hud": [],
    "update_combat": [],
    "update_pickups": [],
    "update_core_attacks": [],
    "update_perf_debug": [],
    "auto_fire_laser": [],
    "update_mega_beam": [],
    "damage_block": [],
    "renderer_draw": [],
    "renderer_bg": [],
    "renderer_fill": [],
    "renderer_fill_resize": [],
    "renderer_fill_rebuild": [],
    "renderer_fill_upload": [],
    "renderer_edge": [],
    "renderer_blocks": [],
    "renderer_power_blocks": [],
    "renderer_overlays": [],
    "perf_graph_draw": [],
    "ship_draw": [],
    "ship_draw_rings": [],
    "ship_draw_drones": [],
}
var _perf_probe_labels := {
    "process_frame": "_process frame",
    "update_timers": "_update_timers",
    "update_power_state": "_update_power_state",
    "update_ship": "_update_ship",
    "update_ship_trail": "_update_ship_trail",
    "update_layer_name": "_update_current_layer_name",
    "update_camera_zoom": "_update_camera_zoom",
    "update_breach_log": "_update_breach_log",
    "refresh_hud": "_refresh_hud",
    "update_combat": "_update_combat",
    "update_pickups": "_update_pickups",
    "update_core_attacks": "_update_core_attacks",
    "update_perf_debug": "_update_perf_debug",
    "auto_fire_laser": "_auto_fire_laser",
    "update_mega_beam": "_update_mega_beam",
    "damage_block": "_damage_block",
    "renderer_draw": "renderer _draw",
    "renderer_bg": "renderer bg",
    "renderer_fill": "renderer fill",
    "renderer_fill_resize": "renderer fill resize",
    "renderer_fill_rebuild": "renderer fill rebuild",
    "renderer_fill_upload": "renderer fill upload",
    "renderer_edge": "renderer edge",
    "renderer_blocks": "renderer blocks",
    "renderer_power_blocks": "renderer power blocks",
    "renderer_overlays": "renderer overlays",
    "perf_graph_draw": "perf graph _draw",
    "ship_draw": "ship _draw",
    "ship_draw_rings": "ship rings",
    "ship_draw_drones": "ship drones",
}
var _perf_probe_last_samples := {
    "process_frame": 0.0,
    "update_timers": 0.0,
    "update_power_state": 0.0,
    "update_ship": 0.0,
    "update_ship_trail": 0.0,
    "update_layer_name": 0.0,
    "update_camera_zoom": 0.0,
    "update_breach_log": 0.0,
    "refresh_hud": 0.0,
    "update_combat": 0.0,
    "update_pickups": 0.0,
    "update_core_attacks": 0.0,
    "update_perf_debug": 0.0,
    "auto_fire_laser": 0.0,
    "update_mega_beam": 0.0,
    "damage_block": 0.0,
    "renderer_draw": 0.0,
    "renderer_bg": 0.0,
    "renderer_fill": 0.0,
    "renderer_fill_resize": 0.0,
    "renderer_fill_rebuild": 0.0,
    "renderer_fill_upload": 0.0,
    "renderer_edge": 0.0,
    "renderer_blocks": 0.0,
    "renderer_power_blocks": 0.0,
    "renderer_overlays": 0.0,
    "perf_graph_draw": 0.0,
    "ship_draw": 0.0,
    "ship_draw_rings": 0.0,
    "ship_draw_drones": 0.0,
}
var _run_perf_peak_samples := {
    "process_frame": 0.0,
    "update_timers": 0.0,
    "update_power_state": 0.0,
    "update_ship": 0.0,
    "update_ship_trail": 0.0,
    "update_layer_name": 0.0,
    "update_camera_zoom": 0.0,
    "update_breach_log": 0.0,
    "refresh_hud": 0.0,
    "update_combat": 0.0,
    "update_pickups": 0.0,
    "update_core_attacks": 0.0,
    "update_perf_debug": 0.0,
    "auto_fire_laser": 0.0,
    "update_mega_beam": 0.0,
    "damage_block": 0.0,
    "renderer_draw": 0.0,
    "renderer_bg": 0.0,
    "renderer_fill": 0.0,
    "renderer_fill_resize": 0.0,
    "renderer_fill_rebuild": 0.0,
    "renderer_fill_upload": 0.0,
    "renderer_edge": 0.0,
    "renderer_blocks": 0.0,
    "renderer_power_blocks": 0.0,
    "renderer_overlays": 0.0,
    "perf_graph_draw": 0.0,
    "ship_draw": 0.0,
    "ship_draw_rings": 0.0,
    "ship_draw_drones": 0.0,
}
var _run_perf_extremes := {}
var _run_perf_worst_snapshot := {}
var _combat_perf_extremes := {}
var _combat_perf_worst_snapshot := {}
var _run_perf_capture_time := 0.0
var _target_offset_cache: Dictionary = {}
var _editor_debug_damage_mult: float = 1.0

func _can_use_editor_debug_keys() -> bool:
    return OS.has_feature("editor") or OS.is_debug_build()

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if VirtualCursor != null:
        VirtualCursor.use_open_pit_empire_cursor(true)
        VirtualCursor.set_scene_enabled(true)
    Global.game_state = Util.GAME_STATES.PLAYING
    rng.randomize()
    _build_runtime_nodes()
    _build_ui()
    _start_run()
    set_process(true)

func _exit_tree() -> void:
    if VirtualCursor != null:
        VirtualCursor.use_open_pit_empire_cursor(false)
        VirtualCursor.set_scene_enabled(false)

func _unhandled_input(event: InputEvent) -> void:
    if run_finished:
        return
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if _try_activate_power(true):
            get_viewport().set_input_as_handled()
            return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            if _try_activate_power(true):
                get_viewport().set_input_as_handled()
        elif event.keycode == KEY_M:
            cycle_render_detail_mode()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_K:
            _finish_run(false, "Debug abort (K).")
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_O:
            cycle_planet_outline_mode()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_BRACKETLEFT:
            adjust_planet_outline_radius(-PLANET_OUTLINE_RADIUS_STEP)
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_BRACKETRIGHT:
            adjust_planet_outline_radius(PLANET_OUTLINE_RADIUS_STEP)
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_5 or event.keycode == KEY_KP_5 or event.physical_keycode == KEY_5:
            ship_render_rotation_offset_degrees -= SHIP_RENDER_ROTATION_STEP_DEGREES
            if ship_renderer != null:
                ship_renderer.queue_redraw()
            print("Open Pit Empire ship render rotation offset: %.1f degrees" % ship_render_rotation_offset_degrees)
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_6 or event.keycode == KEY_KP_6 or event.physical_keycode == KEY_6:
            ship_render_rotation_offset_degrees += SHIP_RENDER_ROTATION_STEP_DEGREES
            if ship_renderer != null:
                ship_renderer.queue_redraw()
            print("Open Pit Empire ship render rotation offset: %.1f degrees" % ship_render_rotation_offset_degrees)
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_7 or event.keycode == KEY_KP_7 or event.physical_keycode == KEY_7:
            adjust_detail_thresholds(-DETAIL_THRESHOLD_STEP)
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_8 or event.keycode == KEY_KP_8 or event.physical_keycode == KEY_8:
            adjust_detail_thresholds(DETAIL_THRESHOLD_STEP)
            get_viewport().set_input_as_handled()
        elif (event.keycode == KEY_P or event.physical_keycode == KEY_P) and _can_use_editor_debug_keys():
            if _editor_debug_damage_mult < 10.0:
                _editor_debug_damage_mult = 10.0
            elif _editor_debug_damage_mult < 100.0:
                _editor_debug_damage_mult = 100.0
            elif _editor_debug_damage_mult < 1000.0:
                _editor_debug_damage_mult = 1000.0
            else:
                _editor_debug_damage_mult = 1.0
            print("Open Pit Empire editor debug damage multiplier: %.1fx" % _editor_debug_damage_mult)
            get_viewport().set_input_as_handled()

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
    camera.zoom = Vector2.ONE * CAMERA_ZOOM_STOPPED
    ship_root.add_child(camera)
    camera.make_current()

func set_planet_outline_mode(mode: int) -> void:
    planet_outline_mode = wrapi(mode, 0, 4)
    if planet_renderer != null and planet_renderer.has_method("mark_dirty"):
        planet_renderer.call("mark_dirty", false)

func cycle_planet_outline_mode() -> void:
    set_planet_outline_mode(planet_outline_mode + 1)

func adjust_planet_outline_radius(delta: int) -> void:
    var next_radius := clampi(planet_outline_radius_cells + delta, PLANET_OUTLINE_RADIUS_MIN, PLANET_OUTLINE_RADIUS_MAX)
    if next_radius == planet_outline_radius_cells:
        return
    planet_outline_radius_cells = next_radius
    print("Open Pit Empire outline radius: %d cells" % planet_outline_radius_cells)
    if planet_renderer != null and planet_renderer.has_method("mark_dirty"):
        planet_renderer.call("mark_dirty", false)

func cycle_render_detail_mode() -> void:
    render_detail_mode = wrapi(render_detail_mode + 1, 0, 4)
    print("Open Pit Empire render mode: %s" % get_render_detail_mode_name())
    print_detail_thresholds()
    if planet_renderer != null and planet_renderer.has_method("mark_dirty"):
        planet_renderer.call("mark_dirty", false)

func get_render_detail_mode_name() -> String:
    match render_detail_mode:
        RenderDetailMode.FULL:
            return "full"
        RenderDetailMode.HEAVY:
            return "heavy"
        RenderDetailMode.ULTRA:
            return "ultra"
        _:
            return "auto"

func adjust_detail_thresholds(delta: int) -> void:
    if delta == 0:
        return
    var next_full := clampi(full_detail_visible_grid_cells + delta, DETAIL_THRESHOLD_MIN, DETAIL_THRESHOLD_MAX)
    var next_heavy := clampi(
        heavy_detail_visible_grid_cells + delta,
        next_full + DETAIL_THRESHOLD_FULL_GAP_MIN,
        DETAIL_THRESHOLD_MAX
    )
    var next_ultra := clampi(
        ultra_detail_visible_grid_cells + delta,
        next_heavy + DETAIL_THRESHOLD_ULTRA_GAP_MIN,
        DETAIL_THRESHOLD_MAX
    )
    if next_full == full_detail_visible_grid_cells and next_heavy == heavy_detail_visible_grid_cells and next_ultra == ultra_detail_visible_grid_cells:
        return
    full_detail_visible_grid_cells = next_full
    heavy_detail_visible_grid_cells = next_heavy
    ultra_detail_visible_grid_cells = next_ultra
    print_detail_thresholds()
    if planet_renderer != null and planet_renderer.has_method("mark_dirty"):
        planet_renderer.call("mark_dirty", false)

func print_detail_thresholds() -> void:
    print(
        "Open Pit Empire detail thresholds: full=%d heavy=%d ultra=%d mode=%s (keys 7/8)" % [
            full_detail_visible_grid_cells,
            heavy_detail_visible_grid_cells,
            ultra_detail_visible_grid_cells,
            get_render_detail_mode_name(),
        ]
    )

func _build_ui() -> void:
    hud_layer = CanvasLayer.new()
    add_child(hud_layer)

    var panel := PanelContainer.new()
    panel.offset_left = 16.0
    panel.offset_top = 16.0
    panel.offset_right = 360.0
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
    fps_label = Label.new()
    fps_label.add_theme_color_override("font_color", Color(0.68, 0.96, 0.8, 1.0))
    vbox.add_child(fps_label)
    perf_graph = PERF_GRAPH_SCRIPT.new()
    perf_graph.scene_ref = self
    vbox.add_child(perf_graph)
    perf_probe_label = RichTextLabel.new()
    perf_probe_label.bbcode_enabled = false
    perf_probe_label.fit_content = true
    perf_probe_label.scroll_active = false
    perf_probe_label.custom_minimum_size = Vector2(235.0, 220.0)
    perf_probe_label.add_theme_font_size_override("normal_font_size", 12)
    perf_probe_label.add_theme_color_override("default_color", Color(0.84, 0.92, 1.0, 0.95))
    vbox.add_child(perf_probe_label)
    _perf_probe_enabled = true

    var breach_log_panel := PanelContainer.new()
    breach_log_panel.offset_left = -520.0
    breach_log_panel.offset_top = 16.0
    breach_log_panel.offset_right = -16.0
    breach_log_panel.offset_bottom = 360.0
    breach_log_panel.anchor_left = 1.0
    breach_log_panel.anchor_right = 1.0
    breach_log_panel.add_theme_stylebox_override("panel", panel_style.duplicate(true))
    hud_layer.add_child(breach_log_panel)

    var breach_log_margin := MarginContainer.new()
    breach_log_margin.add_theme_constant_override("margin_left", 12)
    breach_log_margin.add_theme_constant_override("margin_top", 10)
    breach_log_margin.add_theme_constant_override("margin_right", 12)
    breach_log_margin.add_theme_constant_override("margin_bottom", 10)
    breach_log_panel.add_child(breach_log_margin)

    var breach_log_vbox := VBoxContainer.new()
    breach_log_vbox.add_theme_constant_override("separation", 8)
    breach_log_margin.add_child(breach_log_vbox)

    breach_log_label = RichTextLabel.new()
    breach_log_label.bbcode_enabled = true
    breach_log_label.fit_content = true
    breach_log_label.scroll_active = false
    breach_log_label.custom_minimum_size = Vector2(480.0, 220.0)
    breach_log_label.add_theme_font_size_override("normal_font_size", 15)
    breach_log_label.add_theme_color_override("default_color", Color(0.96, 0.98, 0.86, 0.96))
    breach_log_vbox.add_child(breach_log_label)

    var hacker_typer_panel := PanelContainer.new()
    var typer_style := panel_style.duplicate(true)
    typer_style.bg_color = Color(0.01, 0.08, 0.04, 0.94)
    typer_style.border_color = Color(0.4, 1.0, 0.7, 0.55)
    hacker_typer_panel.add_theme_stylebox_override("panel", typer_style)
    breach_log_vbox.add_child(hacker_typer_panel)

    var hacker_typer_margin := MarginContainer.new()
    hacker_typer_margin.add_theme_constant_override("margin_left", 10)
    hacker_typer_margin.add_theme_constant_override("margin_top", 8)
    hacker_typer_margin.add_theme_constant_override("margin_right", 10)
    hacker_typer_margin.add_theme_constant_override("margin_bottom", 8)
    hacker_typer_panel.add_child(hacker_typer_margin)

    hacker_typer_label = RichTextLabel.new()
    hacker_typer_label.bbcode_enabled = true
    hacker_typer_label.fit_content = true
    hacker_typer_label.scroll_active = false
    hacker_typer_label.custom_minimum_size = Vector2(480.0, 92.0)
    hacker_typer_label.add_theme_font_size_override("normal_font_size", 14)
    hacker_typer_label.add_theme_color_override("default_color", Color(0.86, 1.0, 0.92, 0.94))
    hacker_typer_margin.add_child(hacker_typer_label)

    bottom_cinematic_overlay = Control.new()
    bottom_cinematic_overlay.anchor_right = 1.0
    bottom_cinematic_overlay.anchor_bottom = 1.0
    bottom_cinematic_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bottom_cinematic_overlay.visible = false
    hud_layer.add_child(bottom_cinematic_overlay)

    bottom_letterbox_top = ColorRect.new()
    bottom_letterbox_top.anchor_right = 1.0
    bottom_letterbox_top.offset_bottom = 92.0
    bottom_letterbox_top.color = Color(0.0, 0.0, 0.0, 0.88)
    bottom_cinematic_overlay.add_child(bottom_letterbox_top)

    bottom_letterbox_bottom = ColorRect.new()
    bottom_letterbox_bottom.anchor_top = 1.0
    bottom_letterbox_bottom.anchor_right = 1.0
    bottom_letterbox_bottom.anchor_bottom = 1.0
    bottom_letterbox_bottom.offset_top = -132.0
    bottom_letterbox_bottom.color = Color(0.0, 0.0, 0.0, 0.88)
    bottom_cinematic_overlay.add_child(bottom_letterbox_bottom)

    var cutscene_label_center := CenterContainer.new()
    cutscene_label_center.anchor_left = 0.2
    cutscene_label_center.anchor_top = 1.0
    cutscene_label_center.anchor_right = 0.8
    cutscene_label_center.anchor_bottom = 1.0
    cutscene_label_center.offset_top = -112.0
    cutscene_label_center.offset_bottom = -24.0
    bottom_cinematic_overlay.add_child(cutscene_label_center)

    bottom_cutscene_label = RichTextLabel.new()
    bottom_cutscene_label.bbcode_enabled = true
    bottom_cutscene_label.fit_content = true
    bottom_cutscene_label.scroll_active = false
    bottom_cutscene_label.custom_minimum_size = Vector2(560.0, 72.0)
    bottom_cutscene_label.add_theme_font_size_override("normal_font_size", 26)
    bottom_cutscene_label.add_theme_color_override("default_color", Color(0.98, 0.94, 0.82, 0.98))
    cutscene_label_center.add_child(bottom_cutscene_label)

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
    summary_panel.custom_minimum_size = Vector2(980.0, 480.0)
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
    title.text = "Open Pit Empire"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    title.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0, 1.0))
    summary_vbox.add_child(title)

    summary_label = RichTextLabel.new()
    summary_label.fit_content = true
    summary_label.scroll_active = false
    summary_label.bbcode_enabled = true
    summary_label.custom_minimum_size = Vector2(900.0, 280.0)
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
    runtime_stats = BALANCE.build_runtime_stats(upgrades, PROGRESS.get_xp_upgrade_levels(), PROGRESS.get_core_upgrade_levels())
    current_depth_level = clampi(int(persistent_data.get("selected_depth_level", 1)), 1, BALANCE.MAX_DEPTH_LEVEL)
    bottom_phase_unlocked = bool(persistent_data.get("bottom_phase_unlocked", false))
    current_layer_depth = 1
    planet_radius_cells = PLANET_RADIUS_CELLS
    time_left = float(runtime_stats.get("run_time", 30.0))
    barriers_left = DEFAULT_STARTING_BARRIERS + int(runtime_stats.get("barriers", 0)) + (1 if _has_core_upgrade("barrier_regen") else 0)
    shield_invuln_timer = 0.0
    shield_recovery_timer = 0.0
    boss_defeated = bool(persistent_data.get("boss_defeated", false))
    _build_planet()
    _setup_minimap()
    spawn_position = planet_data.get_spawn_world_position()
    if bottom_phase_unlocked and planet_data != null:
        for core_variant in planet_data.cores:
            var core: Dictionary = core_variant
            if int(core.get("id", -1)) == int(PLANET_DATA_SCRIPT.FINAL_CORE_ID):
                spawn_position = scene_to_spawn_ring(Vector2i(int(core.center.x), int(core.center.y)))
                break
    ship_pos = spawn_position
    ship_root.global_position = ship_pos
    camera_pos = ship_pos
    current_layer_name = "Proxy Cache"
    final_core_exposed = false
    return_zone_radius = RETURN_ZONE_RADIUS + (36.0 if _has_core_upgrade("return_shortcut") else 0.0)
    extracting = false
    extraction_timer = 0.0
    extraction_start_pos = ship_pos
    extraction_target_pos = ship_pos
    extraction_camera_anchor = ship_pos
    attack_timer = 0.0
    attack_visible_timer = 0.0
    charged_shot_counter = 0
    shockwave_counter = 0
    overdrive_kills = 0
    overdrive_timer = 0.0
    mega_gauge = 0
    mega_timer = 0.0
    mega_damage_timer = 0.0
    current_power = 0.0
    power_peak = 0.0
    power_active = false
    power_ring_overcharge = 0.0
    ship_trail.clear()
    ship_trail_timer = 0.0
    pickups.clear()
    cargo_units = 0
    cargo_money = 0
    nodes_mined = 0
    xp_earned_this_run = 0
    destroyed_cells_this_run.clear()
    cores_destroyed_this_run = 0
    core_currency_earned_this_run = 0
    electric_arcs.clear()
    chain_arcs.clear()
    shockwave_rings.clear()
    ghost_debris.clear()
    ghost_debris_timers.clear()
    root_cross_lasers.clear()
    drone_beams.clear()
    drone_missiles.clear()
    drone_mines.clear()
    seismic_charge_bursts.clear()
    seismic_charge_timer = 0.0
    drone_attack_counter = 0
    _reset_drone_state()
    current_combo = 0
    combo_peak = 0
    combo_milestones_hit.clear()
    if VirtualCursor != null:
        if VirtualCursor.has_method("set_open_pit_empire_cursor_power"):
            VirtualCursor.set_open_pit_empire_cursor_power(0.0, false, false)
        elif VirtualCursor.has_method("set_open_pit_empire_cursor_combo"):
            VirtualCursor.set_open_pit_empire_cursor_combo(0.0)
    hacker_typer_current_text = ""
    hacker_typer_revealed_chars = 0
    hacker_typer_im_in_timer = 0.0
    hacker_typer_hold_timer = 0.0
    hacker_typer_char_timer = 0.0
    hacker_typer_shot_timer = 0.0
    hacker_typer_is_attacking = false
    hacker_typer_history.clear()
    for key in active_powerup_timers.keys():
        active_powerup_timers[key] = 0.0
    _spawn_roaming_powerups()
    bottom_cutscene_timer = 0.0
    bottom_cutscene_anchor = ship_pos
    side_projectiles.clear()
    side_attackers.clear()
    side_shot_timer = SIDE_SHOT_INTERVAL
    core_defense_timer = DEFENSE_BLOCK_INTERVAL
    core_shockwave_timer = CORE_SHOCKWAVE_INTERVAL
    _reset_run_perf_tracking()
    breach_log_lines.clear()
    breach_log_idle_timer = 0.0
    if bottom_cinematic_overlay != null:
        bottom_cinematic_overlay.visible = false
    if bottom_cutscene_label != null:
        bottom_cutscene_label.text = ""
    breach_chat = BREACH_CHAT_SCRIPT.new()
    breach_chat.reset_for_run(
        current_depth_level,
        rng,
        persistent_data.get("chat_line_counts", {}),
        persistent_data.get("chat_thread_counts", {})
    )
    _flush_breach_chat(true)
    summary_overlay.visible = false
    ship_renderer.position = Vector2.ZERO
    perf_debug_refresh_timer = 0.0
    _last_perf_fps_text = ""
    _last_perf_probe_text = ""
    planet_renderer.mark_dirty(true, "run_start")
    _refresh_hud()

func _build_planet() -> void:
    damaged_cells.clear()
    var persistent_destroyed := {}
    var saved_planet_state: Dictionary = PROGRESS.load_planet_state(current_depth_level)
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
    if not planet_data.final_core_exposed.is_connected(_on_final_core_exposed):
        planet_data.final_core_exposed.connect(_on_final_core_exposed)
    var restored_core_positions: Array = planet_data.restore_alive_core_influence_blocks()
    blocks = planet_data.blocks
    exposed_edges = planet_data.exposed_edges
    if not restored_core_positions.is_empty() and planet_renderer != null:
        planet_renderer.mark_dirty(true, "planet_generated")
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
    var perf_start_us := perf_probe_begin()
    pickups_spawned_this_frame = 0
    _run_perf_capture_time += delta
    _frame_destroyed_blocks = 0
    var frame_block_count_before: int = blocks.size()
    if run_finished:
        _update_finish_summary(delta)
        perf_probe_end("process_frame", perf_start_us)
        return
    ship_glow_phase += delta * 3.0
    var section_start_us := perf_probe_begin()
    _update_timers(delta)
    perf_probe_end("update_timers", section_start_us)
    if run_finished:
        return
    section_start_us = perf_probe_begin()
    _update_ship(delta)
    perf_probe_end("update_ship", section_start_us)
    section_start_us = perf_probe_begin()
    _update_ship_trail(delta)
    perf_probe_end("update_ship_trail", section_start_us)
    _update_zone_return(delta)
    if not extracting:
        _update_pickups(delta)
        _update_roaming_powerups(delta)
        _update_bottom_phase(delta)
        if bottom_cutscene_timer <= 0.0:
            _update_combat(delta)
            _update_drone_visuals(delta)
            _update_core_behaviors(delta)
            _update_core_attacks(delta)
    section_start_us = perf_probe_begin()
    _update_current_layer_name()
    perf_probe_end("update_layer_name", section_start_us)
    section_start_us = perf_probe_begin()
    _update_camera_zoom(delta)
    perf_probe_end("update_camera_zoom", section_start_us)
    section_start_us = perf_probe_begin()
    _update_breach_log(delta)
    perf_probe_end("update_breach_log", section_start_us)
    _refresh_bottom_cinematic_overlay()
    hud_refresh_timer -= delta
    if hud_refresh_timer <= 0.0:
        hud_refresh_timer = HUD_REFRESH_INTERVAL
        section_start_us = perf_probe_begin()
        _refresh_hud()
        perf_probe_end("refresh_hud", section_start_us)
    if extracting:
        camera_pos = extraction_camera_anchor
        ship_root.global_position = extraction_camera_anchor
        ship_renderer.position = ship_pos - extraction_camera_anchor
    elif bottom_cutscene_timer > 0.0:
        camera_pos = bottom_cutscene_anchor
        ship_root.global_position = bottom_cutscene_anchor
        ship_renderer.position = ship_pos - bottom_cutscene_anchor
    else:
        camera_pos = ship_pos
        ship_renderer.position = Vector2.ZERO
        ship_root.global_position = ship_pos
    perf_debug_refresh_timer -= delta
    if fps_label != null and perf_debug_refresh_timer <= 0.0:
        perf_debug_refresh_timer = PERF_DEBUG_REFRESH_INTERVAL
        _update_perf_debug(delta)
    _perf_probe_last_samples["net_block_drop_in_frame"] = float(maxi(0, frame_block_count_before - blocks.size()))
    perf_probe_end("process_frame", perf_start_us)
    _capture_run_perf_snapshot()

func _update_timers(delta: float) -> void:
    bottom_cutscene_timer = maxf(0.0, bottom_cutscene_timer - delta)
    if not _is_ship_inside_return_zone() and not extracting:
        time_left = maxf(0.0, time_left - delta)
    if time_left <= 0.0:
        _finish_run(_has_core_upgrade("emergency_return"), "Fuel burned out before extraction.")
        return
    current_combo = 0
    combo_timer = 0.0
    combo_milestones_hit.clear()
    overdrive_timer = maxf(0.0, overdrive_timer - delta)
    mega_timer = maxf(0.0, mega_timer - delta)
    attack_visible_timer = maxf(0.0, attack_visible_timer - delta)
    shield_invuln_timer = maxf(0.0, shield_invuln_timer - delta)
    shield_recovery_timer = maxf(0.0, shield_recovery_timer - delta)
    for key in active_powerup_timers.keys():
        active_powerup_timers[key] = maxf(0.0, float(active_powerup_timers.get(key, 0.0)) - delta)
    _tick_timer_dict(hit_timers, delta)
    _tick_effect_array(electric_arcs, delta)
    _tick_effect_array(chain_arcs, delta)
    _tick_effect_array(drone_beams, delta)
    _tick_effect_array(seismic_charge_bursts, delta)
    _update_drone_missiles(delta)
    _update_drone_mines(delta)
    var power_perf_start_us := perf_probe_begin()
    _update_power_state(delta)
    perf_probe_end("update_power_state", power_perf_start_us)
    for idx in range(ghost_debris.size() - 1, -1, -1):
        var debris: Dictionary = ghost_debris[idx]
        debris["life"] = float(debris.get("life", AUTUMN_DEBRIS_LIFETIME)) - delta
        if float(debris.get("life", 0.0)) <= 0.0:
            ghost_debris.remove_at(idx)
            continue
        ghost_debris[idx] = debris
    for idx in range(shockwave_rings.size() - 1, -1, -1):
        var ring := shockwave_rings[idx]
        ring["radius"] = float(ring.get("radius", 0.0)) + SHOCKWAVE_RING_SPEED * delta
        var max_radius := maxf(1.0, float(ring.get("max_radius", float(runtime_stats.get("shockwave_radius_cells", 6)) * BLOCK_SIZE)))
        var progress := clampf(float(ring.get("radius", 0.0)) / max_radius, 0.0, 1.0)
        ring["alpha"] = 0.8 * (1.0 - progress)
        shockwave_rings[idx] = ring
        if float(ring.get("radius", 0.0)) >= max_radius or float(ring.get("alpha", 0.0)) <= 0.0:
            shockwave_rings.remove_at(idx)

func _update_camera_zoom(delta: float) -> void:
    if camera == null:
        return
    var move_speed := maxf(float(runtime_stats.get("move_speed", 580.0)) + (POWER_SPEED_BONUS if _is_power_active() else 0.0), 1.0)
    var speed_ratio := clampf(ship_vel.length() / move_speed, 0.0, 1.0)
    var target_zoom := lerpf(CAMERA_ZOOM_STOPPED, CAMERA_ZOOM_FULL_SPEED, speed_ratio)
    camera.zoom = camera.zoom.lerp(Vector2.ONE * target_zoom, clampf(delta / CAMERA_ZOOM_BLEND_TIME, 0.0, 1.0))

func _update_breach_log(delta: float) -> void:
    if breach_chat == null:
        return
    breach_chat.update(delta, _build_breach_chat_snapshot())
    _flush_breach_chat()
    _update_hacker_typer(delta)

func _update_hacker_typer(delta: float) -> void:
    if hacker_typer_label == null:
        return
    hacker_typer_shot_timer = maxf(0.0, hacker_typer_shot_timer - delta)
    var actively_attacking := hacker_typer_shot_timer > 0.0
    var showing_im_in := hacker_typer_im_in_timer > 0.0
    if showing_im_in:
        hacker_typer_im_in_timer = maxf(0.0, hacker_typer_im_in_timer - delta)
        if hacker_typer_current_text != "I'M IN":
            _start_hacker_typer_line("I'M IN")
    elif not actively_attacking:
        hacker_typer_cursor_on = false
        _render_hacker_typer()
        return
    elif hacker_typer_current_text == "I'M IN":
        hacker_typer_current_text = ""
        hacker_typer_revealed_chars = 0
    elif _is_hacker_typer_line_complete():
        hacker_typer_hold_timer = maxf(0.0, hacker_typer_hold_timer - delta)
        if hacker_typer_hold_timer <= 0.0:
            _commit_hacker_typer_line()
    hacker_typer_is_attacking = actively_attacking
    hacker_typer_char_timer -= delta
    if hacker_typer_char_timer <= 0.0:
        hacker_typer_char_timer = 0.025 if hacker_typer_current_text == "I'M IN" else 0.014
        if not _is_hacker_typer_line_complete():
            hacker_typer_revealed_chars += 1
        hacker_typer_cursor_on = not hacker_typer_cursor_on
    _render_hacker_typer()

func _start_hacker_typer_line(text: String) -> void:
    hacker_typer_current_text = text
    hacker_typer_revealed_chars = 0
    hacker_typer_char_timer = 0.0
    hacker_typer_hold_timer = 0.5 if text == "I'M IN" else 0.18

func _commit_hacker_typer_line() -> void:
    if hacker_typer_current_text == "" or hacker_typer_current_text == "I'M IN":
        return
    hacker_typer_history.append(_format_hacker_typer_block(hacker_typer_current_text, false))
    while hacker_typer_history.size() > HACKER_TYPER_MAX_LINES:
        hacker_typer_history.remove_at(0)
    hacker_typer_current_text = ""
    hacker_typer_revealed_chars = 0

func _pick_hacker_typer_line(actively_attacking: bool, under_pressure: bool) -> String:
    var source_lines := HACKER_TYPER_IDLE_LINES
    if under_pressure:
        source_lines = HACKER_TYPER_PRESSURE_LINES
    elif actively_attacking or ship_vel.length() > 80.0:
        source_lines = HACKER_TYPER_ACTIVE_LINES
    return source_lines[rng.randi_range(0, source_lines.size() - 1)]

func _render_hacker_typer() -> void:
    var cursor := "[color=#ff5f55]_[/color]" if hacker_typer_cursor_on else " "
    var lines := PackedStringArray()
    for line in hacker_typer_history:
        lines.append(line)
    if hacker_typer_current_text != "":
        var visible_text := hacker_typer_current_text.substr(0, mini(hacker_typer_revealed_chars, hacker_typer_current_text.length()))
        lines.append(_format_hacker_typer_block("%s%s" % [visible_text, cursor], true))
    if lines.is_empty():
        hacker_typer_label.text = "[color=#7dd6ff]BREACH CONSOLE[/color]"
    else:
        hacker_typer_label.text = "[color=#7dd6ff]BREACH CONSOLE[/color]\n%s" % "\n".join(lines)

func _format_hacker_typer_block(text: String, active: bool) -> String:
    var prompt_color := "#f2fffb" if active else "#7dffbf"
    return "[code][color=%s]>>>[/color] %s[/code]" % [prompt_color, text]

func _is_hacker_typer_line_complete() -> bool:
    return hacker_typer_current_text != "" and hacker_typer_revealed_chars >= hacker_typer_current_text.length()

func _has_live_hacker_targets() -> bool:
    if mega_timer > 0.0:
        return true
    var range_world := float(runtime_stats.get("attack_radius", 96.0))
    return not _find_nearest_attack_targets(range_world, 1).is_empty()

func _try_start_hacker_typer_attack_line() -> void:
    hacker_typer_shot_timer = HACKER_TYPER_SHOT_WINDOW
    if hacker_typer_current_text != "" or hacker_typer_im_in_timer > 0.0:
        return
    var under_pressure := int(_get_breach_chat_pressure_state().get("stage", 0)) >= 2
    _start_hacker_typer_line(_pick_hacker_typer_line(true, under_pressure))

func _update_bottom_phase(delta: float) -> void:
    if not final_core_exposed or planet_data == null:
        return
    _update_side_attackers(delta, bottom_cutscene_timer <= 0.0)
    if bottom_cutscene_timer > 0.0:
        return
    if side_attackers.is_empty():
        side_shot_timer -= delta
        if side_shot_timer <= 0.0:
            side_shot_timer = SIDE_SHOT_INTERVAL
            _spawn_side_projectiles()
    for idx in range(side_projectiles.size() - 1, -1, -1):
        var projectile := side_projectiles[idx]
        projectile["life"] = float(projectile.get("life", 0.0)) - delta
        if float(projectile.get("life", 0.0)) <= 0.0:
            side_projectiles.remove_at(idx)
            continue
        projectile["position"] = Vector2(projectile.get("position", Vector2.ZERO)) + Vector2(projectile.get("velocity", Vector2.ZERO)) * delta
        side_projectiles[idx] = projectile
        if Vector2(projectile.get("position", Vector2.ZERO)).distance_to(ship_pos) <= SIDE_SHOT_RADIUS + SHIP_RADIUS:
            _apply_ship_hazard_hit(
                Vector2(projectile.get("velocity", Vector2.ZERO)).normalized(),
                "The rig was bracketed by side-channel fire."
            )
            side_projectiles.remove_at(idx)

func _update_side_attackers(delta: float, allow_fire: bool) -> void:
    if side_attackers.is_empty() or planet_data == null:
        return
    var anchor_grid := world_to_grid(bottom_cutscene_anchor)
    var center_y: int = clampi(anchor_grid.y - 10, PLANET_DATA_SCRIPT.PIT_TOP_Y + 24, PLANET_DATA_SCRIPT.PIT_BOTTOM_Y - 12)
    for idx in range(side_attackers.size()):
        var attacker: Dictionary = side_attackers[idx]
        var side: int = int(attacker.get("side", -1))
        var slot: int = int(attacker.get("slot", 0))
        var y: int = clampi(
            center_y + (slot - 1) * SIDE_ATTACKER_VERTICAL_SPACING,
            PLANET_DATA_SCRIPT.PIT_TOP_Y + 24,
            PLANET_DATA_SCRIPT.PIT_BOTTOM_Y - 12
        )
        var side_phase: float = float(attacker.get("phase", 0.0)) + delta * (1.35 + float(slot) * 0.15)
        attacker["phase"] = side_phase
        var left_wall: int = planet_data.get_left_wall_x(y)
        var right_wall: int = planet_data.get_right_wall_x(y)
        var base_x: int = left_wall - SIDE_ATTACKER_INSET_CELLS if side < 0 else right_wall + SIDE_ATTACKER_INSET_CELLS
        var base_world := grid_to_world(Vector2i(base_x, y))
        base_world.y += sin(side_phase + float(slot) * 0.7) * SIDE_ATTACKER_VERTICAL_SWAY
        var current_pos := Vector2(attacker.get("position", base_world))
        attacker["position"] = current_pos.lerp(base_world, clampf(delta * SIDE_ATTACKER_TRACK_SPEED, 0.0, 1.0))
        var shot_timer: float = float(attacker.get("shot_timer", SIDE_ATTACKER_SHOT_INTERVAL)) - delta
        if allow_fire and shot_timer <= 0.0:
            _spawn_side_projectile_from_position(Vector2(attacker.get("position", base_world)))
            shot_timer = SIDE_ATTACKER_SHOT_INTERVAL + rng.randf_range(-0.35, 0.45)
        attacker["shot_timer"] = shot_timer
        side_attackers[idx] = attacker

func _spawn_side_attackers() -> void:
    side_attackers.clear()
    if planet_data == null:
        return
    for side in [-1, 1]:
        for slot in range(SIDE_ATTACKER_COUNT_PER_SIDE):
            side_attackers.append({
                "side": side,
                "slot": slot,
                "position": bottom_cutscene_anchor + Vector2(float(side) * 260.0, float(slot * 28 - 14)),
                "phase": rng.randf() * TAU,
                "shot_timer": 0.5 + rng.randf() * SIDE_ATTACKER_SHOT_INTERVAL,
            })

func _spawn_side_projectile_from_position(spawn_world: Vector2) -> void:
    var dir: Vector2 = (ship_pos - spawn_world).normalized()
    if dir.length() < 0.01:
        dir = Vector2.LEFT if spawn_world.x > ship_pos.x else Vector2.RIGHT
    side_projectiles.append({
        "position": spawn_world,
        "velocity": dir * SIDE_SHOT_SPEED,
        "life": SIDE_SHOT_LIFETIME,
    })

func _spawn_side_projectiles() -> void:
    if planet_data == null:
        return
    if not side_attackers.is_empty():
        for attacker_variant in side_attackers:
            var attacker: Dictionary = attacker_variant
            _spawn_side_projectile_from_position(Vector2(attacker.get("position", bottom_cutscene_anchor)))
        return
    var y: int = clampi(world_to_grid(ship_pos).y, PLANET_DATA_SCRIPT.PIT_TOP_Y + 20, PLANET_DATA_SCRIPT.PIT_BOTTOM_Y - 8)
    for side in [-1, 1]:
        var wall_x: int = planet_data.get_left_wall_x(y) if side < 0 else planet_data.get_right_wall_x(y)
        var spawn_grid := Vector2i(wall_x - 3 if side < 0 else wall_x + 3, y + rng.randi_range(-4, 4))
        var spawn_world: Vector2 = grid_to_world(spawn_grid)
        _spawn_side_projectile_from_position(spawn_world)

func _spawn_roaming_powerups() -> void:
    roaming_powerups.clear()
    if planet_data == null:
        return
    var clear_ratio := clampf(_get_persistent_clear_percent() / 100.0, 0.0, 1.0)
    var powerup_count := clampi(1 + int(floor(clear_ratio * 4.0)), 1, 4)
    for idx in range(powerup_count):
        var y: int = int(lerpf(float(PLANET_DATA_SCRIPT.PIT_TOP_Y + 36), float(PLANET_DATA_SCRIPT.PIT_BOTTOM_Y - 26), float(idx + 1) / float(powerup_count + 1)))
        var left_x: int = planet_data.get_left_wall_x(y) + PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS + 4
        var right_x: int = planet_data.get_right_wall_x(y) - PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS - 4
        var start_x: int = rng.randi_range(left_x, max(left_x, right_x))
        roaming_powerups.append({
            "position": grid_to_world(Vector2i(start_x, y)),
            "y": y,
            "dir": 1.0 if rng.randf() > 0.5 else -1.0,
            "speed": POWERUP_BASE_SPEED + clear_ratio * 70.0 + float(idx) * 8.0,
            "type": POWERUP_TYPES[idx % POWERUP_TYPES.size()],
            "phase": rng.randf() * TAU,
            "support_drop": false,
        })

func _update_roaming_powerups(delta: float) -> void:
    if planet_data == null or roaming_powerups.is_empty():
        return
    for idx in range(roaming_powerups.size() - 1, -1, -1):
        var powerup := roaming_powerups[idx]
        var pos := Vector2(powerup.get("position", Vector2.ZERO))
        if bool(powerup.get("support_drop", false)):
            powerup["life"] = float(powerup.get("life", DRONE_SUPPORT_DROP_LIFETIME)) - delta
            if float(powerup.get("life", 0.0)) <= 0.0:
                roaming_powerups.remove_at(idx)
                continue
            powerup["phase"] = float(powerup.get("phase", 0.0)) + delta * 4.0
            pos += Vector2(powerup.get("velocity", Vector2.ZERO)) * delta
            pos.y += sin(float(powerup.get("phase", 0.0))) * 8.0 * delta
        else:
            var y := int(powerup.get("y", world_to_grid(pos).y))
            var left_world := grid_to_world(Vector2i(planet_data.get_left_wall_x(y) + PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS + 4, y)).x
            var right_world := grid_to_world(Vector2i(planet_data.get_right_wall_x(y) - PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS - 4, y)).x
            pos.x += float(powerup.get("dir", 1.0)) * float(powerup.get("speed", POWERUP_BASE_SPEED)) * delta
            if pos.x <= left_world:
                pos.x = left_world
                powerup["dir"] = 1.0
            elif pos.x >= right_world:
                pos.x = right_world
                powerup["dir"] = -1.0
            powerup["phase"] = float(powerup.get("phase", 0.0)) + delta * 3.0
            pos.y = grid_to_world(Vector2i(0, y)).y + sin(float(powerup.get("phase", 0.0))) * 9.0
        powerup["position"] = pos
        roaming_powerups[idx] = powerup
        if pos.distance_to(ship_pos) <= POWERUP_RADIUS + SHIP_RADIUS:
            _collect_roaming_powerup(str(powerup.get("type", "haste")))
            roaming_powerups.remove_at(idx)
    if roaming_powerups.is_empty():
        _spawn_roaming_powerups()

func _collect_roaming_powerup(powerup_type: String) -> void:
    active_powerup_timers[powerup_type] = POWERUP_DURATION
    match powerup_type:
        "haste":
            _push_breach_log("[color=#7dffbf]BOOST[/color]  breach clock accelerates.")
        "magnet":
            _push_breach_log("[color=#7dffbf]BOOST[/color]  packet magnet spikes.")
        "seismic_charge":
            _push_breach_log("[color=#7dffbf]BOOST[/color]  seismic charges spool up.")
        _:
            _push_breach_log("[color=#7dffbf]BOOST[/color]  rogue utility captured.")

func _update_ship(delta: float) -> void:
    if extracting:
        extraction_timer = minf(extraction_timer + delta, EXTRACTION_ASCENT_TIME)
        var ascent_progress := clampf(extraction_timer / EXTRACTION_ASCENT_TIME, 0.0, 1.0)
        var eased_progress := ease(ascent_progress, -2.0)
        ship_pos = extraction_start_pos.lerp(extraction_target_pos, eased_progress)
        ship_vel = Vector2.ZERO
        last_move_dir = Vector2.UP
        visual_rotation = lerp_angle(visual_rotation, 0.0, ROTATION_SPEED * delta)
        if ascent_progress >= 1.0:
            _finish_run(true, "Orbit transfer complete.")
        return
    if bottom_cutscene_timer > 0.0:
        ship_vel = Vector2.ZERO
        last_move_dir = Vector2.UP
        visual_rotation = lerp_angle(visual_rotation, 0.0, ROTATION_SPEED * delta)
        return
    var viewport_size := get_viewport_rect().size
    var desired_velocity := Vector2.ZERO
    var keyboard_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if keyboard_dir == Vector2.ZERO:
        keyboard_dir = Vector2(
            int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
            int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
        )
    var effective_speed := float(runtime_stats.get("move_speed", 280.0)) + (POWER_SPEED_BONUS if _is_power_active() else 0.0)
    var accel_scale := 1.0
    if shield_recovery_timer > 0.0:
        var recovery_progress := 1.0 - clampf(shield_recovery_timer / SHIELD_HIT_RECOVERY_TIME, 0.0, 1.0)
        accel_scale = lerpf(SHIELD_HIT_ACCEL_START_SCALE, 1.0, recovery_progress)
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
    ship_vel = ship_vel.move_toward(desired_velocity, effective_speed * delta * 6.0 * accel_scale)
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
                "rot": get_ship_render_rotation(),
                "alpha": 0.55,
                "age": 0.0,
            })
            if ship_trail.size() > SHIP_TRAIL_MAX:
                ship_trail.remove_at(0)
    else:
        ship_trail_timer = 0.0
    for idx in range(ship_trail.size() - 1, -1, -1):
        var trail := ship_trail[idx]
        trail["alpha"] = maxf(0.0, float(trail.get("alpha", 0.0)) - delta * 2.8)
        trail["age"] = float(trail.get("age", 0.0)) + delta
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
                if not _trigger_ship_shield_hit(push_dir):
                    _finish_run(false, "The rig cracked against the shell.")
                return
    _enforce_funnel_containment()

func _enforce_funnel_containment() -> void:
    if not final_core_exposed or planet_data == null or bottom_cutscene_timer > 0.0:
        return
    var ship_grid := world_to_grid(ship_pos)
    var clamped_y: int = clampi(ship_grid.y, PLANET_DATA_SCRIPT.PIT_TOP_Y, PLANET_DATA_SCRIPT.PIT_BOTTOM_Y)
    var left_interior: int = planet_data.get_left_wall_x(clamped_y) + PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS + 1
    var right_interior: int = planet_data.get_right_wall_x(clamped_y) - PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS - 1
    if ship_grid.x >= left_interior and ship_grid.x <= right_interior:
        return
    var prefer_left: bool = ship_grid.x < left_interior
    var safe_grid := _find_funnel_reentry_grid(clamped_y, prefer_left)
    ship_pos = grid_to_world(safe_grid)
    ship_vel = Vector2.ZERO
    last_move_dir = Vector2.UP

func _find_funnel_reentry_grid(start_y: int, prefer_left: bool) -> Vector2i:
    var best_fallback := Vector2i(0, start_y)
    for y_offset in range(FUNNEL_REENTRY_SCAN_RADIUS_Y + 1):
        for dir in [-1, 1]:
            if y_offset == 0 and dir > 0:
                continue
            var y := clampi(start_y + y_offset * dir, PLANET_DATA_SCRIPT.PIT_TOP_Y, PLANET_DATA_SCRIPT.PIT_BOTTOM_Y)
            var left_interior: int = planet_data.get_left_wall_x(y) + PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS + 1
            var right_interior: int = planet_data.get_right_wall_x(y) - PLANET_DATA_SCRIPT.PIT_WALL_THICKNESS - 1
            if left_interior > right_interior:
                continue
            var anchor_x: int = left_interior if prefer_left else right_interior
            best_fallback = Vector2i(anchor_x, y)
            for x_offset in range(FUNNEL_REENTRY_SCAN_COLUMNS + 1):
                var x: int = anchor_x + x_offset if prefer_left else anchor_x - x_offset
                if x < left_interior or x > right_interior:
                    break
                var candidate := Vector2i(x, y)
                if is_grid_empty(candidate):
                    return candidate
    return best_fallback

func _update_zone_return(delta: float) -> void:
    if extracting:
        return_zone_timer = RETURN_ZONE_DELAY
        return
    var dist_to_spawn := ship_pos.distance_to(spawn_position)
    if not has_left_spawn and dist_to_spawn > _get_return_zone_arm_distance():
        has_left_spawn = true
    if has_left_spawn and dist_to_spawn < return_zone_radius:
        return_zone_timer = minf(return_zone_timer + delta, RETURN_ZONE_DELAY)
        if return_zone_timer >= RETURN_ZONE_DELAY:
            _begin_extraction()
    else:
        return_zone_timer = 0.0

func _begin_extraction() -> void:
    if extracting:
        return
    extracting = true
    extraction_timer = 0.0
    ship_vel = Vector2.ZERO
    return_zone_timer = RETURN_ZONE_DELAY
    extraction_start_pos = ship_pos
    extraction_camera_anchor = spawn_position
    var zoom_y := camera.zoom.y if camera != null else 1.0
    var half_viewport_height := get_viewport_rect().size.y * 0.5 / maxf(zoom_y, 0.001)
    extraction_target_pos = extraction_camera_anchor + Vector2.UP * (half_viewport_height + EXTRACTION_ASCENT_SCREEN_MARGIN)
    if camera != null:
        camera.reset_smoothing()

func _update_combat(delta: float) -> void:
    var perf_start_us := perf_probe_begin()
    _update_seismic_charge(delta)
    attack_timer += delta
    mega_beam_hits.clear()
    var interval := _get_effective_attack_interval()
    if attack_timer >= interval:
        attack_timer = 0.0
        _auto_fire_laser()
    if bool(runtime_stats.get("drone_enabled", false)):
        _update_drones(delta)
    _flush_pending_exposed_edges()
    perf_probe_end("update_combat", perf_start_us)

func _auto_fire_seismic_charge() -> void:
    var perf_start_us := perf_probe_begin()
    var forward := _get_forward_direction()
    var hit_count := maxi(1, _get_effective_multi_target_count())
    var any_destroyed := false
    var visuals_dirty := false
    last_attack_target = Vector2.ZERO
    multi_targets.clear()
    last_attack_is_charged = false
    last_attack_is_crit = false
    for i in range(hit_count):
        var distance_world := SEISMIC_CHARGE_AHEAD_DISTANCE + float(i) * BLOCK_SIZE * 1.2
        var target_grid := _find_forward_lane_target(forward, distance_world, 2 + mini(i, 1), 4 + i)
        if target_grid.x >= 999999:
            continue
        var burst_world := grid_to_world(target_grid)
        seismic_charge_bursts.append({
            "position": burst_world,
            "timer": SEISMIC_CHARGE_VISUAL_DURATION,
            "radius": float(SEISMIC_CHARGE_SPLASH_RADIUS_CELLS) * BLOCK_SIZE,
        })
        var splash := _apply_splash_damage(
            target_grid,
            SEISMIC_CHARGE_SPLASH_RADIUS_CELLS,
            _get_effective_attack_damage() * (SEISMIC_CHARGE_DAMAGE_MULT + 0.15)
        )
        visuals_dirty = visuals_dirty or bool(splash.get("visuals", false))
        if bool(splash.get("destroyed", false)):
            any_destroyed = true
    if visuals_dirty:
        _sync_planet_runtime_views(true, false)
    attack_visible_timer = 0.0
    _try_start_hacker_typer_attack_line()
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_LASER_CRIT)
    if any_destroyed:
        _on_combo_hit()
    perf_probe_end("auto_fire_laser", perf_start_us)

func _auto_fire_laser() -> void:
    var perf_start_us := perf_probe_begin()
    var range_world := float(runtime_stats.get("attack_radius", 96.0))
    var max_targets := _get_effective_multi_target_count()
    var candidates := _find_nearest_attack_targets(range_world, max_targets)
    if candidates.is_empty():
        last_attack_target = Vector2.ZERO
        multi_targets.clear()
        perf_probe_end("auto_fire_laser", perf_start_us)
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
        var target_core_id: int = int(target.get("core_id", int(blocks.get(pos, {}).get("core_id", -1))))
        if i == 0:
            last_attack_target = world
        else:
            multi_targets.append(world)
        _mark_hit_flash(pos)
        visuals_dirty = true
        var damage := _compute_laser_damage(pos)
        if last_attack_is_charged:
            damage += _get_effective_attack_damage() * float(runtime_stats.get("charged_bonus", 2.0))
            last_attack_is_crit = true
        if bool(runtime_stats.get("crit_chance", 0.0) > 0.0) and rng.randf() < float(runtime_stats.get("crit_chance", 0.0)):
            damage += _get_effective_attack_damage() * float(runtime_stats.get("crit_bonus", 2.0))
            last_attack_is_crit = true
        var result := _damage_block(pos, damage, true)
        if bool(result.get("destroyed", false)):
            any_destroyed = true
        if bool(runtime_stats.get("aoe_enabled", false)):
            var aoe_neighbors := _get_effective_aoe_neighbors()
            for adj_idx in range(aoe_neighbors.size()):
                var adj: Vector2i = aoe_neighbors[adj_idx]
                var adj_pos: Vector2i = pos + adj
                if not is_grid_empty(adj_pos):
                    var adj_core_id: int = int(blocks.get(adj_pos, {}).get("core_id", -1))
                    if target_core_id >= 0 and adj_core_id == target_core_id:
                        continue
                    _mark_hit_flash(adj_pos)
                    visuals_dirty = true
                    var aoe_result := _damage_block(adj_pos, damage * 0.18, true)
                    if bool(aoe_result.get("destroyed", false)):
                        any_destroyed = true
    if visuals_dirty:
        _sync_planet_runtime_views(true, false)
    attack_visible_timer = 0.08
    _try_start_hacker_typer_attack_line()
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_LASER_CRIT if last_attack_is_crit else SoundEffectSettings.SOUND_EFFECT_TYPE.ON_LASER)
    if any_destroyed:
        _on_combo_hit()
    var first_core_id: int = int(candidates[0].get("core_id", -1))
    if bool(runtime_stats.get("chain_lightning_enabled", false)) and first_core_id < 0:
        _trigger_chain_lightning(Vector2i(candidates[0].get("pos", Vector2i.ZERO)), Vector2(candidates[0].get("world", Vector2.ZERO)))
    perf_probe_end("auto_fire_laser", perf_start_us)

func _find_nearest_attack_targets(range_world: float, max_targets: int) -> Array[Dictionary]:
    if max_targets <= 0:
        return []
    var candidates: Array[Dictionary] = []
    var seen_core_ids := {}
    var range_sq := range_world * range_world
    var grid_range := int(ceil(range_world / BLOCK_SIZE)) + 1
    var my_grid := world_to_grid(ship_pos)
    var offsets: Array = _get_sorted_target_offsets(grid_range)
    for offset_variant in offsets:
        var offset: Vector2i = offset_variant
        var cell_origin_dist_sq := float(offset.x * offset.x + offset.y * offset.y) * BLOCK_SIZE * BLOCK_SIZE
        if cell_origin_dist_sq > range_sq and not candidates.is_empty():
            break
        var check := my_grid + offset
        if not blocks.has(check):
            continue
        var block: Dictionary = blocks.get(check, {})
        var core_id: int = int(block.get("core_id", -1))
        if core_id >= 0 and seen_core_ids.has(core_id):
            continue
        var block_world := grid_to_world(check)
        var dist_sq := ship_pos.distance_squared_to(block_world)
        if dist_sq >= range_sq:
            continue
        var candidate := {"pos": check, "dist_sq": dist_sq, "world": block_world, "core_id": core_id}
        var insert_idx := candidates.size()
        while insert_idx > 0 and dist_sq < float(candidates[insert_idx - 1].get("dist_sq", INF)):
            insert_idx -= 1
        if insert_idx >= max_targets and candidates.size() >= max_targets:
            continue
        candidates.insert(insert_idx, candidate)
        if core_id >= 0:
            seen_core_ids[core_id] = true
        if candidates.size() > max_targets:
            candidates.resize(max_targets)
    return candidates

func _get_sorted_target_offsets(grid_range: int) -> Array:
    if _target_offset_cache.has(grid_range):
        return _target_offset_cache[grid_range]
    var offsets: Array = []
    for dx in range(-grid_range, grid_range + 1):
        for dy in range(-grid_range, grid_range + 1):
            offsets.append(Vector2i(dx, dy))
    offsets.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
        var dist_a: int = a.x * a.x + a.y * a.y
        var dist_b: int = b.x * b.x + b.y * b.y
        if dist_a == dist_b:
            if a.x == b.x:
                return a.y < b.y
            return a.x < b.x
        return dist_a < dist_b
    )
    _target_offset_cache[grid_range] = offsets
    return offsets

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
        var swing_phase := ship_glow_phase * 2.4 + float(index) * 1.7
        target_local = target_local.rotated(0.28 * sin(swing_phase))
        drone_positions[index] = drone_positions[index].lerp(ship_pos + target_local, DRONE_FOLLOW_SPEED * delta)
        drone_timers[index] += delta
        var effective_rate := maxf(0.2, float(runtime_stats.get("drone_fire_interval", 0.9)))
        if drone_timers[index] >= effective_rate:
            drone_timers[index] = 0.0
            _fire_drone(index)

func _compute_laser_damage(pos: Vector2i) -> float:
    var block: Dictionary = blocks.get(pos, {})
    var damage := _get_effective_attack_damage()
    damage *= float(runtime_stats.get("global_damage_mult", 1.0))
    damage *= BALANCE.get_damage_multiplier_for_depth(runtime_stats, int(block.get("layer_depth", 1)))
    if bool(runtime_stats.get("resonance_enabled", false)):
        var depth_ratio := float(int(block.get("layer_depth", 1))) / float(max(1, current_depth_level))
        damage += damage * depth_ratio * float(runtime_stats.get("resonance_bonus", 1.0))
    if int(block.get("type", 0)) == BlockType.CORE:
        damage *= float(runtime_stats.get("core_damage_mult", 1.0))
        damage *= float(runtime_stats.get("core_breaker_mult", 1.0))
        if _has_core_upgrade("core_focus"):
            damage *= 1.5
    damage *= _editor_debug_damage_mult
    return damage

func _damage_block(pos: Vector2i, damage: float, defer_visual_sync: bool = false) -> Dictionary:
    var perf_start_us := perf_probe_begin()
    if is_grid_empty(pos):
        perf_probe_end("damage_block", perf_start_us)
        return {}
    var block_before: Dictionary = blocks.get(pos, {})
    var result: Dictionary = planet_data.damage_block(pos, damage, false, _core_unlocks_center())
    if breach_chat != null and int(result.get("type", BlockType.NORMAL)) == BlockType.CORE:
        var engaged_core_id := int(result.get("core_id", int(block_before.get("core_id", -1))))
        if engaged_core_id >= 0:
            breach_chat.notify_node_engaged(
                engaged_core_id,
                PLANET_DATA_SCRIPT.get_core_zone(engaged_core_id),
                PLANET_DATA_SCRIPT.get_core_role(engaged_core_id),
                bool(result.get("shielded", false))
            )
            _flush_breach_chat()
    if bool(result.get("destroyed", false)):
        _frame_destroyed_blocks += _estimate_frame_destroyed_block_count(result)
        damaged_cells.erase(pos)
        persistent_destroyed_count += 1
        destroyed_cells_this_run[pos] = true
        nodes_mined += 1
        xp_earned_this_run += _get_xp_reward_for_block(block_before)
        overdrive_kills += 1
        if breach_chat != null:
            breach_chat.record_node_destroyed(int(result.get("type", BlockType.NORMAL)) == BlockType.CORE)
        if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE:
            hacker_typer_im_in_timer = 1.8
            hacker_typer_current_text = ""
            hacker_typer_revealed_chars = 0
        _play_block_break_audio(int(result.get("type", BlockType.NORMAL)))
        var world := grid_to_world(pos)
        _gain_power(_get_power_gain_for_block(block_before))
        _spawn_pickup(world, block_before)
        if planet_renderer != null:
            if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE:
                _queue_core_fill_region(int(result.get("core_id", int(block_before.get("core_id", -1)))))
            else:
                planet_renderer.queue_fill_update(pos)
        if int(result.get("type", BlockType.NORMAL)) == BlockType.ELECTRIC and bool(runtime_stats.get("electric_enabled", false)):
            _trigger_electric_chain(pos, world, defer_visual_sync)
        if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE and bool(result.get("final_core", false)):
            boss_defeated = true
            _finish_run(true, "The final core ruptured.")
            perf_probe_end("damage_block", perf_start_us)
            return result
        if bool(runtime_stats.get("shockwave_enabled", false)):
            shockwave_counter += 1
            if not shockwave_firing and shockwave_counter >= int(runtime_stats.get("shockwave_trigger_kills", 15)):
                shockwave_counter = 0
                _trigger_shockwave()
    else:
        var remaining_hp := float(planet_data.blocks.get(pos, {}).get("hp", 1.0))
        var core_id := int(result.get("core_id", int(block_before.get("core_id", -1))))
        if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE and core_id >= 0 and planet_data != null:
            for core_variant in planet_data.cores:
                var core: Dictionary = core_variant
                if int(core.get("id", -1)) != core_id:
                    continue
                var center: Vector2i = core.get("center", Vector2i.ZERO)
                var core_size: int = int(core.get("size", 3))
                var half: int = core_size / 2
                for dx in range(-half, half + core_size % 2):
                    for dy in range(-half, half + core_size % 2):
                        var core_pos := Vector2i(center.x + dx, center.y + dy)
                        if int(planet_data.blocks.get(core_pos, {}).get("core_id", -1)) == core_id:
                            damaged_cells[core_pos] = remaining_hp
                break
        else:
            damaged_cells[pos] = remaining_hp
    if not defer_visual_sync:
        _sync_planet_runtime_views(true, false)
    perf_probe_end("damage_block", perf_start_us)
    return result

func _estimate_frame_destroyed_block_count(result: Dictionary) -> int:
    if int(result.get("type", BlockType.NORMAL)) != BlockType.CORE:
        return 1
    var core_id: int = int(result.get("core_id", -1))
    if planet_data == null or core_id < 0:
        return 1
    for core_variant in planet_data.cores:
        var core: Dictionary = core_variant
        if int(core.get("id", -1)) == core_id:
            var size: int = int(core.get("size", 3))
            return max(1, size * size)
    return 1

func _trigger_electric_chain(origin_pos: Vector2i, origin_world: Vector2, defer_visual_sync: bool = false) -> void:
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC, -8.0, -0.05)
    _on_combo_hit()
    var load_tier := _get_attack_load_tier()
    var effective_range := int(runtime_stats.get("electric_range", 2))
    var effective_depth := int(runtime_stats.get("electric_chain_depth", 1))
    if load_tier >= 2:
        effective_range = mini(effective_range, 1)
        effective_depth = mini(effective_depth, 1)
    elif load_tier >= 1:
        effective_range = mini(effective_range, 2)
        effective_depth = mini(effective_depth, 1)
    var results: Array = planet_data.electric_chain(
        origin_pos,
        _get_effective_attack_damage(),
        effective_range,
        effective_depth,
        0,
        _core_unlocks_center()
    )
    var max_results := 6
    if load_tier >= 2:
        max_results = 2
    elif load_tier >= 1:
        max_results = 4
    var destroyed_any := false
    var fill_positions: Array[Vector2i] = []
    var destroyed_core_ids := {}
    for result_idx in range(results.size()):
        var result: Dictionary = results[result_idx]
        var next_pos: Vector2i = result.get("pos", Vector2i.ZERO)
        var next_world := grid_to_world(next_pos)
        if result_idx < max_results and electric_arcs.size() < MAX_ACTIVE_ELECTRIC_ARCS:
            electric_arcs.append({"from": origin_world, "to": next_world, "timer": ARC_DURATION})
        if result_idx < max_results:
            _mark_hit_flash(next_pos)
        if bool(result.get("destroyed", false)):
            destroyed_any = true
            persistent_destroyed_count += 1
            destroyed_cells_this_run[next_pos] = true
            nodes_mined += 1
            xp_earned_this_run += _get_xp_reward_for_block({
                "type": result.get("type", BlockType.NORMAL),
                "layer_depth": result.get("layer_depth", 1),
            })
            overdrive_kills += 1
            if breach_chat != null:
                breach_chat.record_node_destroyed(int(result.get("type", BlockType.NORMAL)) == BlockType.CORE)
            if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE:
                destroyed_core_ids[int(result.get("core_id", -1))] = true
            else:
                fill_positions.append(next_pos)
            _gain_power(_get_power_gain_for_block({
                "type": result.get("type", BlockType.NORMAL),
            }))
            _spawn_pickup(next_world, {
                "resource": result.get("resource", 0.0),
                "type": result.get("type", BlockType.NORMAL),
                "layer_depth": 1
            })
            if int(result.get("type", BlockType.NORMAL)) == BlockType.CORE and bool(result.get("final_core", false)):
                boss_defeated = true
                _finish_run(true, "The final core ruptured.")
                return
    if planet_renderer != null:
        if not fill_positions.is_empty():
            planet_renderer.queue_fill_updates(fill_positions)
        for core_id_variant in destroyed_core_ids.keys():
            _queue_core_fill_region(int(core_id_variant))
    if not defer_visual_sync:
        _sync_planet_runtime_views(true, false)

func _trigger_chain_lightning(start_pos: Vector2i, start_world: Vector2) -> void:
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ELECTRIC_CRIT, -10.0, -0.04)
    var current_pos := start_pos
    var current_world := start_world
    var visited := {start_pos: true}
    var jumps := _get_effective_chain_lightning_jumps()
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
                if int(blocks.get(check, {}).get("core_id", -1)) >= 0:
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
        if chain_arcs.size() < MAX_ACTIVE_CHAIN_ARCS:
            chain_arcs.append({"from": current_world, "to": best_world, "timer": CHAIN_ARC_DURATION})
        _mark_hit_flash(best_pos)
        visuals_dirty = true
        var damage := _compute_laser_damage(best_pos) * 0.5
        var result := _damage_block(best_pos, damage, true)
        if bool(result.get("destroyed", false)):
            destroyed_any = true
        visited[best_pos] = true
        current_pos = best_pos
        current_world = best_world
    if visuals_dirty:
        _sync_planet_runtime_views(true, false)

func _trigger_shockwave() -> void:
    shockwave_firing = true
    var my_grid := world_to_grid(ship_pos)
    var radius_cells := int(runtime_stats.get("shockwave_radius_cells", 6))
    var splash := _apply_splash_damage(
        my_grid,
        radius_cells,
        _get_effective_attack_damage() * SHOCKWAVE_DAMAGE_MULT,
        0.3,
        1.15
    )
    if bool(splash.get("visuals", false)):
        _sync_planet_runtime_views(true, false)
    shockwave_firing = false
    var max_radius := float(radius_cells) * BLOCK_SIZE
    if shockwave_rings.size() >= MAX_SHOCKWAVE_RINGS:
        shockwave_rings.remove_at(0)
    shockwave_rings.append({"radius": 5.0, "max_radius": max_radius, "alpha": 0.8})
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.SUPERNOVA, -10.0, -0.1)


func _update_mega_beam(delta: float) -> void:
    var perf_start_us := perf_probe_begin()
    var mouse_world := get_global_mouse_position()
    mega_direction = (mouse_world - ship_pos).normalized() if mouse_world.distance_to(ship_pos) > 10.0 else last_move_dir
    if mega_direction.length() < 0.01:
        mega_direction = Vector2.UP
    mega_beam_hits.clear()
    var max_dist := float(runtime_stats.get("attack_radius", 96.0)) * 1.5
    mega_beam_end = ship_pos + mega_direction * max_dist
    mega_damage_timer += delta
    if mega_damage_timer < MEGA_DAMAGE_INTERVAL:
        perf_probe_end("update_mega_beam", perf_start_us)
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
        if int(blocks.get(cell, {}).get("core_id", -1)) >= 0:
            continue
        visuals_dirty = true
        var damage := _compute_laser_damage(cell)
        var result := _damage_block(cell, damage, true)
        if bool(result.get("destroyed", false)):
            destroyed_any = true
    if visuals_dirty:
        _sync_planet_runtime_views(true, false)
    perf_probe_end("update_mega_beam", perf_start_us)

func _spawn_pickup(world_pos: Vector2, block: Dictionary) -> void:
    var payout := float(block.get("resource", 1.0)) + float(runtime_stats.get("resource_flat", 0.0))
    payout *= float(runtime_stats.get("global_resource_mult", 1.0))
    payout *= BALANCE.get_resource_multiplier_for_depth(runtime_stats, int(block.get("layer_depth", 1)))
    payout *= _get_effective_payout_multiplier()
    var money := int(round(payout))
    if bool(runtime_stats.get("instant_collect", false)) or ship_pos.distance_to(world_pos) <= _get_effective_pickup_radius():
        _collect_pickup(money, 1)
        return
    if pickups.size() >= MAX_WORLD_PICKUPS or pickups_spawned_this_frame >= PICKUP_SPAWN_SOFT_CAP_PER_FRAME:
        if not pickups.is_empty():
            var closest_idx := 0
            var closest_dist := INF
            for pickup_idx in range(pickups.size()):
                var dist := Vector2(pickups[pickup_idx].get("position", Vector2.ZERO)).distance_squared_to(world_pos)
                if dist < closest_dist:
                    closest_dist = dist
                    closest_idx = pickup_idx
            pickups[closest_idx]["money"] = int(pickups[closest_idx].get("money", 0)) + money
            pickups[closest_idx]["cargo"] = int(pickups[closest_idx].get("cargo", 1)) + 1
        else:
            pickups.append({
                "position": world_pos,
                "money": money,
                "cargo": 1,
                "drift": Vector2.ZERO,
            })
        return
    pickups.append({
        "position": world_pos,
        "money": money,
        "cargo": 1,
        "drift": Vector2(rng.randf_range(-PICKUP_DRIFT, PICKUP_DRIFT), rng.randf_range(-PICKUP_DRIFT, PICKUP_DRIFT)),
    })
    pickups_spawned_this_frame += 1

func _update_pickups(delta: float) -> void:
    var perf_start_us := perf_probe_begin()
    for idx in range(pickups.size() - 1, -1, -1):
        var pickup := pickups[idx]
        pickup["position"] = Vector2(pickup.get("position", Vector2.ZERO)) + Vector2(pickup.get("drift", Vector2.ZERO)) * delta
        pickups[idx] = pickup
        var collect := Vector2(pickup.get("position", Vector2.ZERO)).distance_to(ship_pos) <= _get_effective_pickup_radius()
        if not collect:
            for drone_pos in drone_positions:
                if Vector2(pickup.get("position", Vector2.ZERO)).distance_to(drone_pos) <= _get_effective_pickup_radius():
                    collect = true
                    break
        if collect:
            _collect_pickup(int(pickup.get("money", 0)), int(pickup.get("cargo", 1)))
            pickups.remove_at(idx)
    perf_probe_end("update_pickups", perf_start_us)

func _collect_pickup(money: int, cargo: int) -> void:
    if cargo_units + cargo > int(runtime_stats.get("cargo_capacity", 15)):
        return
    cargo_units += cargo
    cargo_money += money
    if breach_chat != null:
        breach_chat.record_money(money)

func _get_effective_pickup_radius() -> float:
    var radius := float(runtime_stats.get("pickup_radius", 64.0))
    if float(active_powerup_timers.get("magnet", 0.0)) > 0.0:
        radius += 90.0
    return radius

func _get_effective_attack_interval() -> float:
    var interval := float(runtime_stats.get("attack_interval", 0.8))
    if float(active_powerup_timers.get("haste", 0.0)) > 0.0:
        interval *= 0.72
    if _is_power_active():
        interval /= POWER_ATTACK_SPEED_MULT
    return interval

func _get_effective_attack_damage() -> float:
    var damage := float(runtime_stats.get("attack_damage", 8.0))
    if _is_power_active():
        damage *= POWER_ATTACK_DAMAGE_MULT
    return damage

func _get_effective_payout_multiplier() -> float:
    return 1.0

func _get_power_capacity() -> float:
    return maxf(1.0, float(runtime_stats.get("power_capacity", 100.0)))

func _get_power_ratio() -> float:
    return clampf(current_power / _get_power_capacity(), 0.0, 1.0)

func _is_power_ready() -> bool:
    return current_power >= _get_power_capacity() - 0.001

func _is_power_active() -> bool:
    return power_active and current_power > 0.01

func _get_power_gain_for_block(block: Dictionary) -> float:
    var gain := POWER_BASE_GAIN
    if int(block.get("type", BlockType.NORMAL)) == BlockType.GOLD:
        gain *= POWER_SPECIAL_BLOCK_MULT
    gain *= float(runtime_stats.get("power_gain_mult", 1.0))
    return gain * POWER_GAIN_MULT

func _gain_power(amount: float) -> void:
    if amount <= 0.0 or _is_power_active():
        return
    var max_power := _get_power_capacity()
    var next_power := current_power + amount
    if next_power > max_power:
        power_ring_overcharge = minf(1.0, power_ring_overcharge + (next_power - max_power) / maxf(max_power * 0.35, 1.0))
    current_power = clampf(next_power, 0.0, max_power)
    power_peak = maxf(power_peak, current_power)
    if bool(runtime_stats.get("power_auto_trigger", false)) and not _is_power_active() and _is_power_ready():
        _try_activate_power(false)
    if VirtualCursor != null:
        if VirtualCursor.has_method("set_open_pit_empire_cursor_power"):
            VirtualCursor.set_open_pit_empire_cursor_power(_get_power_ratio(), _is_power_active(), _is_power_ready())
        elif VirtualCursor.has_method("set_open_pit_empire_cursor_combo"):
            VirtualCursor.set_open_pit_empire_cursor_combo(_get_power_ratio())

func _try_activate_power(manual_trigger: bool = false) -> bool:
    if run_finished or _is_power_active() or not _is_power_ready():
        return false
    power_active = true
    power_ring_overcharge = maxf(power_ring_overcharge, 0.45)
    seismic_charge_timer = 0.0
    if VirtualCursor != null:
        if VirtualCursor.has_method("set_open_pit_empire_cursor_power"):
            VirtualCursor.set_open_pit_empire_cursor_power(_get_power_ratio(), true, true)
        elif VirtualCursor.has_method("set_open_pit_empire_cursor_combo"):
            VirtualCursor.set_open_pit_empire_cursor_combo(1.0)
        if manual_trigger:
            VirtualCursor.burst_open_pit_empire_cursor_sparks(1.2)
    return true

func _update_power_state(delta: float) -> void:
    power_ring_overcharge = maxf(0.0, power_ring_overcharge - delta * POWER_OVERCHARGE_PULSE_DECAY)
    if _is_power_active():
        current_power = maxf(0.0, current_power - delta * POWER_DRAIN_PER_SECOND)
        if current_power <= 0.01:
            current_power = 0.0
            power_active = false
    else:
        power_active = false
    if VirtualCursor != null:
        if VirtualCursor.has_method("set_open_pit_empire_cursor_power"):
            VirtualCursor.set_open_pit_empire_cursor_power(_get_power_ratio(), _is_power_active(), _is_power_ready())
        elif VirtualCursor.has_method("set_open_pit_empire_cursor_combo"):
            VirtualCursor.set_open_pit_empire_cursor_combo(_get_power_ratio())

func _get_forward_direction() -> Vector2:
    var forward := last_move_dir
    if forward.length_squared() <= 0.001:
        forward = ship_vel.normalized()
    if forward.length_squared() <= 0.001:
        forward = Vector2.UP
    return forward.normalized()

func _spawn_drone_support_powerup() -> void:
    var behind := -_get_forward_direction()
    var spawn_pos := ship_pos + behind * 84.0 + Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-10.0, 10.0))
    roaming_powerups.append({
        "position": spawn_pos,
        "velocity": behind * DRONE_SUPPORT_DROP_SPEED,
        "type": "haste",
        "phase": rng.randf() * TAU,
        "life": DRONE_SUPPORT_DROP_LIFETIME,
        "support_drop": true,
    })

func _find_forward_lane_target(forward: Vector2, distance_world: float, lateral_steps: int = 2, forward_steps: int = 4) -> Vector2i:
    if planet_data == null:
        return Vector2i(999999, 999999)
    var lateral := Vector2(-forward.y, forward.x)
    var forward_step := maxf(BLOCK_SIZE * 0.85, distance_world / float(maxi(1, forward_steps)))
    for step in range(forward_steps, 0, -1):
        var base_world := ship_pos + forward * (float(step) * forward_step)
        for offset_idx in range(0, lateral_steps + 1):
            if offset_idx == 0:
                var center_grid := world_to_grid(base_world)
                if not is_grid_empty(center_grid) and int(blocks.get(center_grid, {}).get("core_id", -1)) < 0:
                    return center_grid
                continue
            var lateral_offset := lateral * BLOCK_SIZE * float(offset_idx)
            var left_grid := world_to_grid(base_world - lateral_offset)
            if not is_grid_empty(left_grid) and int(blocks.get(left_grid, {}).get("core_id", -1)) < 0:
                return left_grid
            var right_grid := world_to_grid(base_world + lateral_offset)
            if not is_grid_empty(right_grid) and int(blocks.get(right_grid, {}).get("core_id", -1)) < 0:
                return right_grid
    return Vector2i(999999, 999999)

func _apply_splash_damage(center_grid: Vector2i, radius_cells: int, base_damage: float, falloff: float = 0.3, max_hp_ratio: float = -1.0) -> Dictionary:
    if radius_cells <= 0 or planet_data == null:
        return {"visuals": false, "destroyed": false}
    var visuals_dirty := false
    var destroyed_any := false
    var radius_sq := radius_cells * radius_cells
    var splash_limit := _get_effective_splash_target_limit(radius_cells)
    var hits := 0
    for ring in range(radius_cells + 1):
        if hits >= splash_limit:
            break
        for dx in range(-ring, ring + 1):
            if hits >= splash_limit:
                break
            for dy in range(-ring, ring + 1):
                if hits >= splash_limit:
                    break
                var dist_sq := dx * dx + dy * dy
                if dist_sq > radius_sq:
                    continue
                if ring > 0 and dist_sq <= (ring - 1) * (ring - 1):
                    continue
                var pos := center_grid + Vector2i(dx, dy)
                if is_grid_empty(pos):
                    continue
                var block: Dictionary = blocks.get(pos, {})
                if int(block.get("core_id", -1)) >= 0 or bool(block.get("unbreakable", false)):
                    continue
                if max_hp_ratio > 0.0 and float(block.get("max_hp", 0.0)) > base_damage * max_hp_ratio:
                    continue
                var distance_ratio := sqrt(float(dist_sq)) / float(maxi(1, radius_cells))
                var damage_scale := lerpf(1.0, falloff, clampf(distance_ratio, 0.0, 1.0))
                _mark_hit_flash(pos)
                visuals_dirty = true
                var result := _damage_block(pos, base_damage * damage_scale, true)
                if bool(result.get("destroyed", false)):
                    destroyed_any = true
                hits += 1
    return {"visuals": visuals_dirty, "destroyed": destroyed_any}

func _update_seismic_charge(delta: float) -> void:
    if planet_data == null:
        seismic_charge_timer = 0.0
        return
    var power_active_now := _is_power_active()
    var pickup_active := float(active_powerup_timers.get("seismic_charge", 0.0)) > 0.0
    if not power_active_now and not pickup_active:
        seismic_charge_timer = 0.0
        return
    seismic_charge_timer -= delta
    if seismic_charge_timer > 0.0:
        return
    seismic_charge_timer = SEISMIC_CHARGE_INTERVAL if power_active_now else SEISMIC_POWERUP_INTERVAL
    var forward := _get_forward_direction()
    var target_grid := _find_forward_lane_target(forward, SEISMIC_CHARGE_AHEAD_DISTANCE)
    if target_grid.x >= 999999:
        return
    var burst_world := grid_to_world(target_grid)
    seismic_charge_bursts.append({
        "position": burst_world,
        "timer": SEISMIC_CHARGE_VISUAL_DURATION,
        "radius": float(SEISMIC_CHARGE_SPLASH_RADIUS_CELLS) * BLOCK_SIZE,
    })
    var splash := _apply_splash_damage(
        target_grid,
        SEISMIC_CHARGE_SPLASH_RADIUS_CELLS,
        _get_effective_attack_damage() * (SEISMIC_CHARGE_DAMAGE_MULT if power_active_now else SEISMIC_POWERUP_DAMAGE_MULT),
        0.3,
        1.35 if power_active_now else 1.0
    )
    if bool(splash.get("visuals", false)):
        _sync_planet_runtime_views(true, false)

func _roll_drone_damage() -> float:
    var damage := float(runtime_stats.get("drone_damage", 8.0))
    if bool(runtime_stats.get("drone_sync_unlock", false)):
        damage += _get_effective_attack_damage() * float(runtime_stats.get("drone_sync_ratio", 0.15))
    if rng.randf() < float(runtime_stats.get("drone_crit_chance", 0.0)):
        damage += float(runtime_stats.get("drone_damage", 8.0)) * float(runtime_stats.get("drone_crit_bonus", 2.0))
    return damage * _editor_debug_damage_mult

func _acquire_drone_target(origin: Vector2, range_world: float) -> Vector2i:
    var targets := _find_targets_near_world(origin, range_world, 1)
    if targets.is_empty():
        return Vector2i(999999, 999999)
    return Vector2i(targets[0])

func _resolve_projectile_target_world(projectile: Dictionary) -> Vector2:
    var target_grid := Vector2i(projectile.get("target_grid", Vector2i(999999, 999999)))
    if target_grid.x < 999999 and not is_grid_empty(target_grid):
        return grid_to_world(target_grid)
    return Vector2(projectile.get("target_world", projectile.get("position", Vector2.ZERO)))

func _update_drone_missiles(delta: float) -> void:
    for idx in range(drone_missiles.size() - 1, -1, -1):
        var missile: Dictionary = drone_missiles[idx]
        missile["life"] = float(missile.get("life", DRONE_MISSILE_LIFETIME)) - delta
        if float(missile.get("life", 0.0)) <= 0.0:
            drone_missiles.remove_at(idx)
            continue
        var missile_pos := Vector2(missile.get("position", Vector2.ZERO))
        var target_grid := Vector2i(missile.get("target_grid", Vector2i(999999, 999999)))
        var target_world := _resolve_projectile_target_world(missile)
        missile["target_world"] = target_world
        var desired_vel := (target_world - missile_pos).normalized() * DRONE_MISSILE_SPEED
        missile["velocity"] = Vector2(missile.get("velocity", Vector2.ZERO)).lerp(desired_vel, clampf(delta * DRONE_MISSILE_TURN_RATE, 0.0, 1.0))
        if missile_pos.distance_to(target_world) <= BLOCK_SIZE * 0.55:
            var impact_grid := target_grid if target_grid.x < 999999 and not is_grid_empty(target_grid) else world_to_grid(target_world)
            var splash := _apply_splash_damage(impact_grid, DRONE_MISSILE_SPLASH_RADIUS_CELLS, float(missile.get("damage", 0.0)), 0.45)
            if bool(splash.get("visuals", false)):
                _sync_planet_runtime_views(true, false)
            if bool(splash.get("destroyed", false)):
                _on_combo_hit()
            seismic_charge_bursts.append({"position": target_world, "timer": 0.28, "radius": float(DRONE_MISSILE_SPLASH_RADIUS_CELLS) * BLOCK_SIZE})
            drone_missiles.remove_at(idx)
            continue
        missile["position"] = missile_pos + Vector2(missile.get("velocity", Vector2.ZERO)) * delta
        drone_missiles[idx] = missile

func _update_drone_mines(delta: float) -> void:
    for idx in range(drone_mines.size() - 1, -1, -1):
        var mine: Dictionary = drone_mines[idx]
        mine["life"] = float(mine.get("life", DRONE_MINE_LIFETIME)) - delta
        if float(mine.get("life", 0.0)) <= 0.0:
            var explode_grid := world_to_grid(Vector2(mine.get("position", Vector2.ZERO)))
            var splash := _apply_splash_damage(explode_grid, DRONE_MINE_SPLASH_RADIUS_CELLS, float(mine.get("damage", 0.0)), 0.55)
            if bool(splash.get("visuals", false)):
                _sync_planet_runtime_views(true, false)
            if bool(splash.get("destroyed", false)):
                _on_combo_hit()
            seismic_charge_bursts.append({"position": Vector2(mine.get("position", Vector2.ZERO)), "timer": 0.34, "radius": float(DRONE_MINE_SPLASH_RADIUS_CELLS) * BLOCK_SIZE})
            drone_mines.remove_at(idx)
            continue
        var mine_pos := Vector2(mine.get("position", Vector2.ZERO))
        var target_grid := Vector2i(mine.get("target_grid", Vector2i(999999, 999999)))
        var target_world := _resolve_projectile_target_world(mine)
        mine["target_world"] = target_world
        var desired_vel := (target_world - mine_pos).normalized() * DRONE_MINE_SPEED
        mine["velocity"] = Vector2(mine.get("velocity", Vector2.ZERO)).lerp(desired_vel, clampf(delta * DRONE_MINE_TURN_RATE, 0.0, 1.0))
        if mine_pos.distance_to(target_world) <= BLOCK_SIZE * 0.75:
            var contact_grid := target_grid if target_grid.x < 999999 and not is_grid_empty(target_grid) else world_to_grid(target_world)
            var contact := _apply_splash_damage(contact_grid, DRONE_MINE_SPLASH_RADIUS_CELLS, float(mine.get("damage", 0.0)), 0.55)
            if bool(contact.get("visuals", false)):
                _sync_planet_runtime_views(true, false)
            if bool(contact.get("destroyed", false)):
                _on_combo_hit()
            seismic_charge_bursts.append({"position": target_world, "timer": 0.34, "radius": float(DRONE_MINE_SPLASH_RADIUS_CELLS) * BLOCK_SIZE})
            drone_mines.remove_at(idx)
            continue
        mine["blink"] = float(mine.get("blink", 0.0)) + delta * 10.0
        mine["position"] = mine_pos + Vector2(mine.get("velocity", Vector2.ZERO)) * delta
        drone_mines[idx] = mine

func _update_drone_visuals(_delta: float) -> void:
    if mega_timer <= 0.0:
        mega_beam_hits.clear()

func _sync_planet_runtime_views(mark_renderer_dirty: bool = false, rebuild_fill: bool = false, reason: String = "runtime_sync") -> void:
    blocks = planet_data.blocks
    exposed_edges = planet_data.exposed_edges
    if mark_renderer_dirty:
        planet_renderer.mark_dirty(rebuild_fill, reason)

func _queue_core_fill_region(core_id: int, padding_cells: int = 2) -> void:
    if planet_renderer == null or planet_data == null or core_id < 0:
        return
    for core_variant in planet_data.cores:
        var core: Dictionary = core_variant
        if int(core.get("id", -1)) != core_id:
            continue
        var center: Vector2i = core.get("center", Vector2i.ZERO)
        var core_size: int = int(core.get("size", 3))
        var half: int = core_size / 2
        var positions: Array[Vector2i] = []
        for x in range(center.x - half - padding_cells, center.x + half + core_size % 2 + padding_cells):
            for y in range(center.y - half - padding_cells, center.y + half + core_size % 2 + padding_cells):
                positions.append(Vector2i(x, y))
        if not positions.is_empty():
            planet_renderer.queue_fill_updates(positions)
        return

func _flush_pending_exposed_edges() -> void:
    if planet_data == null or not planet_data.has_method("flush_pending_exposed_edges"):
        return
    planet_data.call("flush_pending_exposed_edges")
    exposed_edges = planet_data.exposed_edges

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
    drone_attack_counter += 1
    if drone_attack_counter >= DRONE_SUPPORT_DROP_ATTACKS:
        drone_attack_counter = 0
        _spawn_drone_support_powerup()
    var attack_load := _get_attack_load_tier()
    var mine_chance := 0.08
    var missile_chance := 0.30
    match attack_load:
        2:
            mine_chance = 0.0
            missile_chance = 0.08
        1:
            mine_chance = 0.03
            missile_chance = 0.18
    var attack_roll := rng.randf()
    if attack_roll < mine_chance and drone_mines.size() < MAX_ACTIVE_DRONE_MINES:
        var mine_target := _acquire_drone_target(drone_world, DRONE_MISSILE_RANGE)
        if mine_target.x < 999999:
            var mine_world := grid_to_world(mine_target)
            drone_targets[drone_idx] = mine_world
            drone_mines.append({
                "position": drone_world,
                "velocity": (mine_world - drone_world).normalized() * DRONE_MINE_SPEED,
                "target_grid": mine_target,
                "target_world": mine_world,
                "damage": _roll_drone_damage() * DRONE_MINE_DAMAGE_MULT,
                "life": DRONE_MINE_LIFETIME,
                "blink": rng.randf() * TAU,
            })
            return
    if attack_roll < missile_chance and drone_missiles.size() < MAX_ACTIVE_DRONE_MISSILES:
        var missile_target := _acquire_drone_target(drone_world, DRONE_MISSILE_RANGE)
        if missile_target.x < 999999:
            var missile_world := grid_to_world(missile_target)
            drone_targets[drone_idx] = missile_world
            drone_missiles.append({
                "position": drone_world,
                "velocity": (missile_world - drone_world).normalized() * DRONE_MISSILE_SPEED,
                "target_grid": missile_target,
                "target_world": missile_world,
                "damage": _roll_drone_damage() * DRONE_MISSILE_DAMAGE_MULT,
                "life": DRONE_MISSILE_LIFETIME,
            })
            return
    var drone_pierce := int(runtime_stats.get("drone_pierce", 1))
    if attack_load >= 2:
        drone_pierce = 1
    var target_cells := _find_targets_near_world(drone_world, DRONE_RANGE, drone_pierce)
    if target_cells.is_empty():
        return
    var first_world := grid_to_world(target_cells[0])
    drone_targets[drone_idx] = first_world
    for target_grid in target_cells:
        if int(blocks.get(target_grid, {}).get("core_id", -1)) >= 0:
            continue
        var damage := _roll_drone_damage()
        var result := _damage_block(target_grid, damage)
        if bool(result.get("destroyed", false)):
            _on_combo_hit()
        if drone_beams.size() < MAX_ACTIVE_DRONE_BEAMS:
            drone_beams.append({"from": drone_world, "to": grid_to_world(target_grid), "timer": DRONE_BEAM_DURATION})

func _on_combo_hit() -> void:
    return

func _push_breach_log(message: String) -> void:
    breach_log_lines.append(message)
    while breach_log_lines.size() > BREACH_LOG_MAX_LINES:
        breach_log_lines.remove_at(0)
    _render_breach_log()

func _finish_run(returned: bool, reason: String) -> void:
    if run_finished:
        return
    extracting = false
    run_finished = true
    _flush_pending_exposed_edges()
    if planet_data != null:
        blocks = planet_data.blocks
        exposed_edges = planet_data.exposed_edges
        persistent_destroyed_count = max(0, total_planet_blocks - planet_data.get_total_blocks())
        planet_renderer.mark_dirty(true, "load_state_refresh")
    var keep_percent := 1.0 if returned else float(runtime_stats.get("salvage_keep", 0.0))
    var total_money := cargo_money
    for pickup in pickups:
        total_money += int(pickup.get("money", 0))
    var money_award := int(round(float(total_money) * keep_percent))
    summary_overlay.visible = true
    summary_save_anim_time = 0.0
    summary_save_pending = true
    summary_save_phase = "prepare"
    var epilogue := ""
    if breach_chat != null:
        _flush_breach_chat(true)
        epilogue = breach_chat.build_summary_epilogue()
    var attempt_lines: Array[String] = []
    for attempt_variant in persistent_data.get("attempt_history", []):
        var attempt: Dictionary = attempt_variant
        attempt_lines.append(
            "Tier %d :: chipped %.1f%% :: %d blocks :: $%d :: %d XP" % [
                int(attempt.get("depth_level", 1)),
                float(attempt.get("persistent_clear", 0.0)),
                int(attempt.get("nodes_broken", 0)),
                int(attempt.get("money", 0)),
                int(attempt.get("xp", 0)),
            ]
        )
        if attempt_lines.size() >= 5:
            break
    var history_text := "\n".join(attempt_lines)
    if history_text == "":
        history_text = "No previous breach attempts logged."
    summary_label.text = "[center][b]%s[/b][/center]\n\n[table=2][cell]Breach Tier[/cell][cell]%d[/cell][cell]Blocks Mined This Run[/cell][cell]%d[/cell][cell]Haul Recovered[/cell][cell]$%d[/cell][cell]Loose Value Touched[/cell][cell]$%d[/cell][cell]XP Banked[/cell][cell]%d[/cell][cell]Daemons Deleted[/cell][cell]%d[/cell][cell]Persistent Clear[/cell][cell]%.1f%%[/cell][cell]Root Keys Banked[/cell][cell]%d[/cell][cell]Power Peak[/cell][cell]%.0f[/cell][cell]Barriers Left[/cell][cell]%d[/cell][/table]\n\n[color=#7dd6ff]Previous Attempts[/color]\n%s%s" % [
        reason,
        current_depth_level,
        nodes_mined,
        money_award,
        total_money,
        xp_earned_this_run,
        cores_destroyed_this_run,
        _get_persistent_clear_percent(),
        core_currency_earned_this_run,
        power_peak,
        barriers_left,
        history_text,
        epilogue
    ]
    if summary_return_button != null:
        summary_return_button.disabled = true
        summary_return_button.text = "Saving..."
    if summary_status_label != null:
        summary_status_label.text = "Preparing save..."
    _dump_run_perf_snapshot_to_console(returned, reason, money_award)
    call_deferred("_begin_finish_save", money_award, reason)

func _save_planet_snapshot() -> void:
    if run_finished or planet_data == null:
        return
    _flush_pending_exposed_edges()
    persistent_data["boss_defeated"] = boss_defeated
    persistent_data["destroyed_cells"] = []
    PROGRESS.save_data(persistent_data)
    var snapshot: Dictionary = planet_data.build_dirty_save_data()
    snapshot["depth_level"] = current_depth_level
    var dirty_sections: Dictionary = snapshot.get("sections", {})
    if not dirty_sections.is_empty():
        if PROGRESS.save_planet_state(snapshot):
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
        if PROGRESS.was_async_planet_state_save_successful() and planet_data != null and not summary_pending_saved_section_ids.is_empty():
            planet_data.mark_saved_sections_clean(summary_pending_saved_section_ids)
        summary_pending_saved_section_ids.clear()
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
        planet_snapshot["depth_level"] = current_depth_level
        has_sector_updates = not Dictionary(planet_snapshot.get("sections", {})).is_empty()
    PROGRESS.apply_run_results({
        "money": money_award,
        "xp": xp_earned_this_run,
        "core_currency": core_currency_earned_this_run,
        "cores_destroyed": cores_destroyed_this_run,
        "depth_level": current_depth_level,
        "nodes_broken": nodes_mined,
        "boss_defeated": boss_defeated,
        "destroyed_cells": [],
        "planet_state": planet_snapshot if has_sector_updates else {},
        "defer_planet_state_save": has_sector_updates,
        "summary_text": "%s Banked $%d and %d XP." % [reason, money_award, xp_earned_this_run],
        "persistent_clear": _get_persistent_clear_percent(),
        "chat_line_counts": breach_chat.get_persistent_line_counts() if breach_chat != null else persistent_data.get("chat_line_counts", {}),
        "chat_thread_counts": breach_chat.get_persistent_thread_counts() if breach_chat != null else persistent_data.get("chat_thread_counts", {}),
        "bottom_phase_unlocked": bottom_phase_unlocked,
    })
    if has_sector_updates:
        PROGRESS.start_async_planet_state_save(planet_snapshot)
        summary_pending_saved_section_ids = Array(planet_snapshot.get("sections", {}).keys()).duplicate(true)
        summary_save_phase = "thread"
        summary_save_pending = PROGRESS.is_async_planet_state_save_pending()
    else:
        summary_save_phase = "done"
        summary_save_pending = false
        summary_pending_saved_section_ids.clear()
    var cached_planet_state: Dictionary = PROGRESS.peek_cached_planet_state()
    if not cached_planet_state.is_empty():
        var next_runtime_planet = PLANET_DATA_SCRIPT.new()
        next_runtime_planet.load_save_data(cached_planet_state)
        PROGRESS.save_runtime_planet_data(current_depth_level, next_runtime_planet)
    else:
        PROGRESS.clear_runtime_planet_data()
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
    if extracting:
        cargo_label.text = "Fuel: %.1fs  |  Extracting..." % time_left
    elif _is_return_zone_charging():
        cargo_label.text = "Fuel: %.1fs  |  Extraction %.1fs" % [time_left, maxf(0.0, RETURN_ZONE_DELAY - return_zone_timer)]
    else:
        cargo_label.text = "Fuel: %.1fs  |  Extraction Zone Standby" % time_left
    wallet_label.text = "Haul: $%d  |  Wallet: $%d  |  XP: %d" % [cargo_money, int(persistent_data.get("wallet", 0)), int(persistent_data.get("xp_currency", 0)) + xp_earned_this_run]
    layer_label.text = "Breach Tier %d  |  %s  |  Clear %.1f%%" % [current_depth_level, current_layer_name, _get_persistent_clear_percent()]
    var active_boosts: Array[String] = []
    if float(active_powerup_timers.get("haste", 0.0)) > 0.0:
        active_boosts.append("Haste %.0fs" % ceil(active_powerup_timers["haste"]))
    if float(active_powerup_timers.get("magnet", 0.0)) > 0.0:
        active_boosts.append("Magnet %.0fs" % ceil(active_powerup_timers["magnet"]))
    if float(active_powerup_timers.get("seismic_charge", 0.0)) > 0.0:
        active_boosts.append("Seismic %.0fs" % ceil(active_powerup_timers["seismic_charge"]))
    status_label.text = "Barriers %d  |  Drones %d  |  Power %.0f/%.0f  |  Alive Daemons %d/%d" % [barriers_left, int(runtime_stats.get("drone_count", 0)), current_power, _get_power_capacity(), planet_data.get_alive_cores() if planet_data != null else 0, planet_data.get_total_cores() if planet_data != null else 0]
    var power_state := "Power Active" if _is_power_active() else ("Power Ready - Click / Space" if _is_power_ready() else "Power Charging")
    system_label.text = "%s  |  Root Keys %d  |  %s" % [power_state, int(persistent_data.get("core_currency", 0)) + core_currency_earned_this_run, " / ".join(active_boosts) if not active_boosts.is_empty() else "Move: Mouse / WASD"]
    if breach_log_label != null and breach_log_label.text == "":
        _render_breach_log()

func _refresh_bottom_cinematic_overlay() -> void:
    if bottom_cinematic_overlay == null or bottom_cutscene_label == null:
        return
    var show_overlay := bottom_cutscene_timer > 0.0
    bottom_cinematic_overlay.visible = show_overlay
    if not show_overlay:
        return
    var progress := 1.0 - clampf(bottom_cutscene_timer / BOTTOM_CUTSCENE_DURATION, 0.0, 1.0)
    var top_height := lerpf(12.0, 92.0, ease(progress, 0.8))
    var bottom_height := lerpf(18.0, 132.0, ease(progress, 0.8))
    if bottom_letterbox_top != null:
        bottom_letterbox_top.offset_bottom = top_height
    if bottom_letterbox_bottom != null:
        bottom_letterbox_bottom.offset_top = -bottom_height
    bottom_cutscene_label.text = _get_bottom_cutscene_caption(progress)

func _get_bottom_cutscene_caption(progress: float) -> String:
    if progress < 0.28:
        return "[center][b]CORE VEIL COLLAPSING[/b]\nThe shaft folds inward.[/center]"
    if progress < 0.62:
        return "[center][b]THE FUNNEL TURNS UPSIDE DOWN[/b]\nEvery route points at the heart.[/center]"
    return "[center][b]SIDE SENTRIES ONLINE[/b]\nHold the lane. Burn into the core.[/center]"

func get_return_zone_progress() -> float:
    return clampf(return_zone_timer / RETURN_ZONE_DELAY, 0.0, 1.0)

func _is_return_zone_charging() -> bool:
    return not extracting and return_zone_timer > 0.0

func _is_ship_inside_return_zone() -> bool:
    return has_left_spawn and ship_pos.distance_to(spawn_position) < return_zone_radius

func _get_return_zone_arm_distance() -> float:
    return return_zone_radius * RETURN_ZONE_ARM_DISTANCE_MULT

func should_render_extraction_zone() -> bool:
    var extraction_ring_radius := return_zone_radius + 18.0
    var outline_draw_radius := maxf(1.0, float(planet_outline_radius_cells) * BLOCK_SIZE)
    var spawn_offset := spawn_position - ship_pos
    if spawn_offset.length() - extraction_ring_radius > outline_draw_radius:
        return false

    var surface_radius := float(planet_radius_cells) * BLOCK_SIZE
    if ship_pos.length() >= surface_radius:
        return true

    var ship_dir := ship_pos.normalized()
    var spawn_dir := spawn_position.normalized()
    if ship_dir.length() < 0.01 or spawn_dir.length() < 0.01:
        return false

    var same_top_segment := ship_dir.dot(spawn_dir) >= 0.72
    return same_top_segment and ship_pos.y <= 0.0

func _update_perf_debug(frame_delta: float) -> void:
    var perf_start_us := perf_probe_begin()
    if fps_label == null:
        perf_probe_end("update_perf_debug", perf_start_us)
        return
    var frame_ms := frame_delta * 1000.0 if frame_delta > 0.0 else (1000.0 / maxf(float(max(1, Engine.get_frames_per_second())), 1.0))
    var process_ms := float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0
    var physics_ms := float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) * 1000.0
    var gpu_est_ms := _estimate_gpu_frame_ms(frame_ms, process_ms, physics_ms)
    if perf_graph != null and perf_graph.has_method("push_sample"):
        perf_graph.call("push_sample", frame_ms, process_ms, physics_ms)
    var limit_hint: String = str(perf_graph.call("get_hint_text")) if perf_graph != null and perf_graph.has_method("get_hint_text") else "Unknown"
    var zone_lines: Array[String] = []
    var damage_mults: Array = runtime_stats.get("zone_damage_mults", [1.0, 1.0, 1.0, 1.0])
    var zone_labels: Array[String] = ["Proxy Cache", "Cipher Depths", "Ghost Sector", "Root Well"]
    for idx in range(mini(4, damage_mults.size())):
        var mult: float = float(damage_mults[idx])
        if mult <= 1.0:
            continue
        var zone_name: String = zone_labels[idx]
        zone_lines.append("%s %+d%%" % [zone_name, int(round((mult - 1.0) * 100.0))])
    var base_text := "FPS: %d  |  Frame %.1fms  |  CPU %.1fms\nGPU est %.1fms  |  Phys %.1fms  |  %s" % [
        Engine.get_frames_per_second(),
        frame_ms,
        process_ms,
        gpu_est_ms,
        physics_ms,
        str(limit_hint)
    ]
    var next_fps_text := base_text if zone_lines.is_empty() else "%s\nDebug Dmg: %s" % [base_text, ", ".join(zone_lines)]
    if next_fps_text != _last_perf_fps_text:
        _last_perf_fps_text = next_fps_text
        fps_label.text = next_fps_text
    if perf_probe_label != null:
        var next_probe_text := _build_perf_probe_text()
        if next_probe_text != _last_perf_probe_text:
            _last_perf_probe_text = next_probe_text
            perf_probe_label.text = next_probe_text
    perf_probe_end("update_perf_debug", perf_start_us)

func _estimate_gpu_frame_ms(frame_ms: float, process_ms: float, physics_ms: float) -> float:
    return maxf(0.0, frame_ms - minf(frame_ms, process_ms + physics_ms))

func perf_probe_begin() -> int:
    return Time.get_ticks_usec() if _perf_probe_enabled else 0

func perf_probe_end(key: String, start_us: int) -> void:
    if start_us <= 0 or not _perf_probe_enabled:
        return
    _push_perf_probe_sample(key, float(Time.get_ticks_usec() - start_us) / 1000.0)

func _push_perf_probe_sample(key: String, duration_ms: float) -> void:
    if not _perf_probe_history.has(key):
        return
    var buffer: Array = _perf_probe_history[key]
    var clamped_duration := maxf(0.0, duration_ms)
    buffer.append(clamped_duration)
    if buffer.size() > PERF_PROBE_HISTORY_SIZE:
        buffer.remove_at(0)
    _perf_probe_history[key] = buffer
    _perf_probe_last_samples[key] = clamped_duration
    _run_perf_peak_samples[key] = maxf(float(_run_perf_peak_samples.get(key, 0.0)), clamped_duration)

func clear_perf_probe_sample(key: String) -> void:
    if not _perf_probe_last_samples.has(key):
        return
    _perf_probe_last_samples[key] = 0.0

func _build_perf_probe_text() -> String:
    var lines: Array[String] = ["Hot Paths Avg | Worst 1%"]
    for key in PERF_PROBE_KEYS:
        var samples: Array = _perf_probe_history.get(key, [])
        var avg_ms := _sample_average_ms(samples)
        var p99_ms := _sample_worst_one_percent_ms(samples)
        var sample_count := samples.size()
        lines.append("%s  avg %.3fms  1%% %.3fms  n=%d" % [
            str(_perf_probe_labels.get(key, key)),
            avg_ms,
            p99_ms,
            sample_count,
        ])
    if planet_renderer != null and planet_renderer.has_method("get_perf_state_text"):
        lines.append(str(planet_renderer.call("get_perf_state_text")))
    lines.append("Pickups %d  HitFX %d  PowerFX %d  EArcs %d  CArcs %d  DBeams %d  DMiss %d  DMines %d" % [
        pickups.size(),
        hit_timers.size(),
        seismic_charge_bursts.size(),
        electric_arcs.size(),
        chain_arcs.size(),
        drone_beams.size(),
        drone_missiles.size(),
        drone_mines.size(),
    ])
    return "\n".join(lines)

func _dump_run_perf_snapshot_to_console(returned: bool, reason: String, money_award: int) -> void:
    var lines: Array[String] = []
    lines.append("=== OPEN PIT EMPIRE RUN PERF SNAPSHOT ===")
    lines.append("Result: %s" % ("returned" if returned else "failed"))
    lines.append("Reason: %s" % reason)
    lines.append("Tier: %d" % current_depth_level)
    lines.append("Blocks mined: %d  Cores destroyed: %d  Power peak: %.0f" % [nodes_mined, cores_destroyed_this_run, power_peak])
    lines.append("Money banked: %d  Cargo units: %d  Barriers left: %d" % [money_award, cargo_units, barriers_left])
    lines.append("FPS now: %d  Frame %.2fms  CPU %.2fms  Phys %.2fms" % [
        Engine.get_frames_per_second(),
        1000.0 / maxf(float(max(1, Engine.get_frames_per_second())), 1.0),
        float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0,
        float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) * 1000.0,
    ])
    lines.append(_build_run_perf_extremes_text())
    lines.append(_build_perf_probe_text())
    lines.append(_build_run_perf_peak_probe_text())
    lines.append(_build_run_perf_worst_snapshot_text())
    lines.append(_build_combat_perf_extremes_text())
    lines.append(_build_combat_perf_worst_snapshot_text())
    lines.append("Camera pos: (%.1f, %.1f)  Ship pos: (%.1f, %.1f)" % [camera_pos.x, camera_pos.y, ship_pos.x, ship_pos.y])
    lines.append("Visible blocks: %d  Total blocks: %d  Persistent clear: %.2f%%" % [blocks.size(), total_planet_blocks, _get_persistent_clear_percent()])
    lines.append("========================================")
    print("\n".join(lines))

func _reset_run_perf_tracking() -> void:
    _run_perf_capture_time = 0.0
    _run_perf_extremes = {
        "min_fps": 1000000,
        "max_frame_ms": 0.0,
        "max_cpu_ms": 0.0,
        "max_phys_ms": 0.0,
        "max_visible_cells": 0,
        "max_effect_load": 0,
        "max_pickups": 0,
        "max_hit_fx": 0,
        "max_seismic_fx": 0,
        "max_e_arcs": 0,
        "max_c_arcs": 0,
        "max_d_beams": 0,
        "max_d_missiles": 0,
        "max_d_mines": 0,
        "max_blocks_alive": 0,
        "max_blocks_cleared_in_frame": 0,
        "max_net_block_drop_in_frame": 0,
    }
    _combat_perf_extremes = {
        "min_fps": 1000000,
        "max_frame_ms": 0.0,
        "max_cpu_ms": 0.0,
        "max_phys_ms": 0.0,
        "max_visible_cells": 0,
        "max_effect_load": 0,
        "max_pickups": 0,
        "max_hit_fx": 0,
        "max_seismic_fx": 0,
        "max_e_arcs": 0,
        "max_c_arcs": 0,
        "max_d_beams": 0,
        "max_d_missiles": 0,
        "max_d_mines": 0,
        "max_blocks_alive": 0,
        "max_blocks_cleared_in_frame": 0,
        "max_net_block_drop_in_frame": 0,
    }
    _run_perf_worst_snapshot = {}
    _combat_perf_worst_snapshot = {}
    for key in _perf_probe_last_samples.keys():
        _perf_probe_last_samples[key] = 0.0
        _run_perf_peak_samples[key] = 0.0

func _capture_run_perf_snapshot() -> void:
    if _run_perf_capture_time < PERF_CAPTURE_WARMUP_SECONDS:
        return
    var fps_now: int = maxi(1, Engine.get_frames_per_second())
    var frame_ms := 1000.0 / float(fps_now)
    var cpu_ms := float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0
    var phys_ms := float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) * 1000.0
    _run_perf_extremes["min_fps"] = mini(int(_run_perf_extremes.get("min_fps", fps_now)), fps_now)
    _run_perf_extremes["max_frame_ms"] = maxf(float(_run_perf_extremes.get("max_frame_ms", 0.0)), frame_ms)
    _run_perf_extremes["max_cpu_ms"] = maxf(float(_run_perf_extremes.get("max_cpu_ms", 0.0)), cpu_ms)
    _run_perf_extremes["max_phys_ms"] = maxf(float(_run_perf_extremes.get("max_phys_ms", 0.0)), phys_ms)
    _run_perf_extremes["max_pickups"] = maxi(int(_run_perf_extremes.get("max_pickups", 0)), pickups.size())
    _run_perf_extremes["max_hit_fx"] = maxi(int(_run_perf_extremes.get("max_hit_fx", 0)), hit_timers.size())
    _run_perf_extremes["max_seismic_fx"] = maxi(int(_run_perf_extremes.get("max_seismic_fx", 0)), seismic_charge_bursts.size())
    _run_perf_extremes["max_e_arcs"] = maxi(int(_run_perf_extremes.get("max_e_arcs", 0)), electric_arcs.size())
    _run_perf_extremes["max_c_arcs"] = maxi(int(_run_perf_extremes.get("max_c_arcs", 0)), chain_arcs.size())
    _run_perf_extremes["max_d_beams"] = maxi(int(_run_perf_extremes.get("max_d_beams", 0)), drone_beams.size())
    _run_perf_extremes["max_d_missiles"] = maxi(int(_run_perf_extremes.get("max_d_missiles", 0)), drone_missiles.size())
    _run_perf_extremes["max_d_mines"] = maxi(int(_run_perf_extremes.get("max_d_mines", 0)), drone_mines.size())
    _run_perf_extremes["max_blocks_alive"] = maxi(int(_run_perf_extremes.get("max_blocks_alive", 0)), blocks.size())
    _run_perf_extremes["max_blocks_cleared_in_frame"] = maxi(int(_run_perf_extremes.get("max_blocks_cleared_in_frame", 0)), int(_frame_destroyed_blocks))
    _run_perf_extremes["max_net_block_drop_in_frame"] = maxi(int(_run_perf_extremes.get("max_net_block_drop_in_frame", 0)), int(_perf_probe_last_samples.get("net_block_drop_in_frame", 0.0)))
    if planet_renderer != null:
        _run_perf_extremes["max_visible_cells"] = maxi(int(_run_perf_extremes.get("max_visible_cells", 0)), int(planet_renderer.get("_last_visible_cell_budget")))
        _run_perf_extremes["max_effect_load"] = maxi(int(_run_perf_extremes.get("max_effect_load", 0)), int(planet_renderer.get("_last_effect_load")))
    if _should_replace_perf_snapshot(_run_perf_worst_snapshot, fps_now, cpu_ms):
        _run_perf_worst_snapshot = _make_perf_snapshot(fps_now, frame_ms, cpu_ms, phys_ms)
    if _is_combat_perf_focus_window():
        _combat_perf_extremes["min_fps"] = mini(int(_combat_perf_extremes.get("min_fps", fps_now)), fps_now)
        _combat_perf_extremes["max_frame_ms"] = maxf(float(_combat_perf_extremes.get("max_frame_ms", 0.0)), frame_ms)
        _combat_perf_extremes["max_cpu_ms"] = maxf(float(_combat_perf_extremes.get("max_cpu_ms", 0.0)), cpu_ms)
        _combat_perf_extremes["max_phys_ms"] = maxf(float(_combat_perf_extremes.get("max_phys_ms", 0.0)), phys_ms)
        _combat_perf_extremes["max_pickups"] = maxi(int(_combat_perf_extremes.get("max_pickups", 0)), pickups.size())
        _combat_perf_extremes["max_hit_fx"] = maxi(int(_combat_perf_extremes.get("max_hit_fx", 0)), hit_timers.size())
        _combat_perf_extremes["max_seismic_fx"] = maxi(int(_combat_perf_extremes.get("max_seismic_fx", 0)), seismic_charge_bursts.size())
        _combat_perf_extremes["max_e_arcs"] = maxi(int(_combat_perf_extremes.get("max_e_arcs", 0)), electric_arcs.size())
        _combat_perf_extremes["max_c_arcs"] = maxi(int(_combat_perf_extremes.get("max_c_arcs", 0)), chain_arcs.size())
        _combat_perf_extremes["max_d_beams"] = maxi(int(_combat_perf_extremes.get("max_d_beams", 0)), drone_beams.size())
        _combat_perf_extremes["max_d_missiles"] = maxi(int(_combat_perf_extremes.get("max_d_missiles", 0)), drone_missiles.size())
        _combat_perf_extremes["max_d_mines"] = maxi(int(_combat_perf_extremes.get("max_d_mines", 0)), drone_mines.size())
        _combat_perf_extremes["max_blocks_alive"] = maxi(int(_combat_perf_extremes.get("max_blocks_alive", 0)), blocks.size())
        _combat_perf_extremes["max_blocks_cleared_in_frame"] = maxi(int(_combat_perf_extremes.get("max_blocks_cleared_in_frame", 0)), int(_frame_destroyed_blocks))
        _combat_perf_extremes["max_net_block_drop_in_frame"] = maxi(int(_combat_perf_extremes.get("max_net_block_drop_in_frame", 0)), int(_perf_probe_last_samples.get("net_block_drop_in_frame", 0.0)))
        if planet_renderer != null:
            _combat_perf_extremes["max_visible_cells"] = maxi(int(_combat_perf_extremes.get("max_visible_cells", 0)), int(planet_renderer.get("_last_visible_cell_budget")))
            _combat_perf_extremes["max_effect_load"] = maxi(int(_combat_perf_extremes.get("max_effect_load", 0)), int(planet_renderer.get("_last_effect_load")))
        if _should_replace_perf_snapshot(_combat_perf_worst_snapshot, fps_now, cpu_ms):
            _combat_perf_worst_snapshot = _make_perf_snapshot(fps_now, frame_ms, cpu_ms, phys_ms)

func _build_run_perf_extremes_text() -> String:
    return "Run Peaks  min FPS %d  max Frame %.2fms  max CPU %.2fms  max Phys %.2fms  max PlanetVis %d  max Load %d" % [
        int(_run_perf_extremes.get("min_fps", 0)),
        float(_run_perf_extremes.get("max_frame_ms", 0.0)),
        float(_run_perf_extremes.get("max_cpu_ms", 0.0)),
        float(_run_perf_extremes.get("max_phys_ms", 0.0)),
        int(_run_perf_extremes.get("max_visible_cells", 0)),
        int(_run_perf_extremes.get("max_effect_load", 0)),
    ]

func _build_combat_perf_extremes_text() -> String:
    if int(_combat_perf_extremes.get("min_fps", 1000000)) == 1000000:
        return "Combat Peaks unavailable"
    return "Combat Peaks  min FPS %d  max Frame %.2fms  max CPU %.2fms  max Phys %.2fms  max PlanetVis %d  max Load %d" % [
        int(_combat_perf_extremes.get("min_fps", 0)),
        float(_combat_perf_extremes.get("max_frame_ms", 0.0)),
        float(_combat_perf_extremes.get("max_cpu_ms", 0.0)),
        float(_combat_perf_extremes.get("max_phys_ms", 0.0)),
        int(_combat_perf_extremes.get("max_visible_cells", 0)),
        int(_combat_perf_extremes.get("max_effect_load", 0)),
    ]

func _build_run_perf_peak_probe_text() -> String:
    var lines: Array[String] = ["Run Probe Peaks"]
    for key in PERF_PROBE_KEYS:
        lines.append("%s  peak %.3fms" % [
            str(_perf_probe_labels.get(key, key)),
            float(_run_perf_peak_samples.get(key, 0.0)),
        ])
    lines.append("Run Count Peaks  Pickups %d  HitFX %d  PowerFX %d  EArcs %d  CArcs %d  DBeams %d  DMiss %d  DMines %d  Blocks %d" % [
        int(_run_perf_extremes.get("max_pickups", 0)),
        int(_run_perf_extremes.get("max_hit_fx", 0)),
        int(_run_perf_extremes.get("max_seismic_fx", 0)),
        int(_run_perf_extremes.get("max_e_arcs", 0)),
        int(_run_perf_extremes.get("max_c_arcs", 0)),
        int(_run_perf_extremes.get("max_d_beams", 0)),
        int(_run_perf_extremes.get("max_d_missiles", 0)),
        int(_run_perf_extremes.get("max_d_mines", 0)),
        int(_run_perf_extremes.get("max_blocks_alive", 0)),
    ])
    lines.append("Run Block Peaks  cleared/frame %d  net drop/frame %d" % [
        int(_run_perf_extremes.get("max_blocks_cleared_in_frame", 0)),
        int(_run_perf_extremes.get("max_net_block_drop_in_frame", 0)),
    ])
    return "\n".join(lines)

func _build_run_perf_worst_snapshot_text() -> String:
    if _run_perf_worst_snapshot.is_empty():
        return "Worst Frame Snapshot unavailable"
    var lines: Array[String] = []
    lines.append("Worst Frame Snapshot  FPS %d  Frame %.2fms  CPU %.2fms  Phys %.2fms" % [
        int(_run_perf_worst_snapshot.get("fps", 0)),
        float(_run_perf_worst_snapshot.get("frame_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("cpu_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("phys_ms", 0.0)),
    ])
    lines.append("Worst Hot Paths  process %.3fms  combat %.3fms  pickups %.3fms  core %.3fms  laser %.3fms  mega %.3fms  damage %.3fms  render %.3fms  ship %.3fms" % [
        float(_run_perf_worst_snapshot.get("process_frame_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("update_combat_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("update_pickups_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("update_core_attacks_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("auto_fire_laser_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("update_mega_beam_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("damage_block_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("renderer_draw_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("ship_draw_ms", 0.0)),
    ])
    lines.append("Worst Renderer Paths  bg %.3fms  fill %.3fms  edge %.3fms  blocks %.3fms  overlays %.3fms" % [
        float(_run_perf_worst_snapshot.get("renderer_bg_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("renderer_fill_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("renderer_edge_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("renderer_blocks_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("renderer_overlays_ms", 0.0)),
    ])
    lines.append("Worst Fill Paths  resize %.3fms  rebuild %.3fms  upload %.3fms" % [
        float(_run_perf_worst_snapshot.get("renderer_fill_resize_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("renderer_fill_rebuild_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("renderer_fill_upload_ms", 0.0)),
    ])
    lines.append("Worst Debug Paths  perf %.3fms  graph %.3fms" % [
        float(_run_perf_worst_snapshot.get("update_perf_debug_ms", 0.0)),
        float(_run_perf_worst_snapshot.get("perf_graph_draw_ms", 0.0)),
    ])
    lines.append(str(_run_perf_worst_snapshot.get("planet_state", "")))
    lines.append("Worst Counts  Pickups %d  HitFX %d  PowerFX %d  EArcs %d  CArcs %d  DBeams %d  DMiss %d  DMines %d  Blocks %d  Cleared %d  NetDrop %d" % [
        int(_run_perf_worst_snapshot.get("pickups", 0)),
        int(_run_perf_worst_snapshot.get("hit_fx", 0)),
        int(_run_perf_worst_snapshot.get("seismic_fx", 0)),
        int(_run_perf_worst_snapshot.get("e_arcs", 0)),
        int(_run_perf_worst_snapshot.get("c_arcs", 0)),
        int(_run_perf_worst_snapshot.get("d_beams", 0)),
        int(_run_perf_worst_snapshot.get("d_missiles", 0)),
        int(_run_perf_worst_snapshot.get("d_mines", 0)),
        int(_run_perf_worst_snapshot.get("blocks_alive", 0)),
        int(_run_perf_worst_snapshot.get("blocks_cleared_in_frame", 0)),
        int(_run_perf_worst_snapshot.get("net_block_drop_in_frame", 0)),
    ])
    var snapshot_camera: Vector2 = _run_perf_worst_snapshot.get("camera_pos", Vector2.ZERO)
    var snapshot_ship: Vector2 = _run_perf_worst_snapshot.get("ship_pos", Vector2.ZERO)
    lines.append("Worst Pos  Camera (%.1f, %.1f)  Ship (%.1f, %.1f)" % [snapshot_camera.x, snapshot_camera.y, snapshot_ship.x, snapshot_ship.y])
    return "\n".join(lines)

func _build_combat_perf_worst_snapshot_text() -> String:
    if _combat_perf_worst_snapshot.is_empty():
        return "Combat Worst Frame Snapshot unavailable"
    var lines: Array[String] = []
    lines.append("Combat Worst Frame  FPS %d  Frame %.2fms  CPU %.2fms  Phys %.2fms" % [
        int(_combat_perf_worst_snapshot.get("fps", 0)),
        float(_combat_perf_worst_snapshot.get("frame_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("cpu_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("phys_ms", 0.0)),
    ])
    lines.append("Combat Worst Hot Paths  process %.3fms  combat %.3fms  pickups %.3fms  core %.3fms  laser %.3fms  mega %.3fms  damage %.3fms  render %.3fms  ship %.3fms" % [
        float(_combat_perf_worst_snapshot.get("process_frame_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("update_combat_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("update_pickups_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("update_core_attacks_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("auto_fire_laser_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("update_mega_beam_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("damage_block_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("renderer_draw_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("ship_draw_ms", 0.0)),
    ])
    lines.append("Combat Worst Renderer  bg %.3fms  fill %.3fms  edge %.3fms  blocks %.3fms  overlays %.3fms" % [
        float(_combat_perf_worst_snapshot.get("renderer_bg_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("renderer_fill_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("renderer_edge_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("renderer_blocks_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("renderer_overlays_ms", 0.0)),
    ])
    lines.append("Combat Worst Fill  resize %.3fms  rebuild %.3fms  upload %.3fms" % [
        float(_combat_perf_worst_snapshot.get("renderer_fill_resize_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("renderer_fill_rebuild_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("renderer_fill_upload_ms", 0.0)),
    ])
    lines.append("Combat Worst Debug  perf %.3fms  graph %.3fms" % [
        float(_combat_perf_worst_snapshot.get("update_perf_debug_ms", 0.0)),
        float(_combat_perf_worst_snapshot.get("perf_graph_draw_ms", 0.0)),
    ])
    lines.append(str(_combat_perf_worst_snapshot.get("planet_state", "")))
    lines.append("Combat Worst Counts  Pickups %d  HitFX %d  PowerFX %d  EArcs %d  CArcs %d  DBeams %d  DMiss %d  DMines %d  Blocks %d  Cleared %d  NetDrop %d" % [
        int(_combat_perf_worst_snapshot.get("pickups", 0)),
        int(_combat_perf_worst_snapshot.get("hit_fx", 0)),
        int(_combat_perf_worst_snapshot.get("seismic_fx", 0)),
        int(_combat_perf_worst_snapshot.get("e_arcs", 0)),
        int(_combat_perf_worst_snapshot.get("c_arcs", 0)),
        int(_combat_perf_worst_snapshot.get("d_beams", 0)),
        int(_combat_perf_worst_snapshot.get("d_missiles", 0)),
        int(_combat_perf_worst_snapshot.get("d_mines", 0)),
        int(_combat_perf_worst_snapshot.get("blocks_alive", 0)),
        int(_combat_perf_worst_snapshot.get("blocks_cleared_in_frame", 0)),
        int(_combat_perf_worst_snapshot.get("net_block_drop_in_frame", 0)),
    ])
    var snapshot_camera: Vector2 = _combat_perf_worst_snapshot.get("camera_pos", Vector2.ZERO)
    var snapshot_ship: Vector2 = _combat_perf_worst_snapshot.get("ship_pos", Vector2.ZERO)
    lines.append("Combat Worst Pos  Camera (%.1f, %.1f)  Ship (%.1f, %.1f)" % [snapshot_camera.x, snapshot_camera.y, snapshot_ship.x, snapshot_ship.y])
    return "\n".join(lines)

func _is_combat_perf_focus_window() -> bool:
    if not has_left_spawn and ship_pos.distance_to(spawn_position) <= _get_return_zone_arm_distance():
        return false
    if attack_visible_timer > 0.0 or _is_power_active():
        return true
    if not hit_timers.is_empty() or not seismic_charge_bursts.is_empty():
        return true
    if not electric_arcs.is_empty() or not chain_arcs.is_empty() or not drone_beams.is_empty() or not drone_missiles.is_empty() or not drone_mines.is_empty():
        return true
    var inward_progress := spawn_position.length() - ship_pos.length()
    return inward_progress >= BLOCK_SIZE * 24.0

func _should_replace_perf_snapshot(current_snapshot: Dictionary, fps_now: int, cpu_ms: float) -> bool:
    var should_replace := current_snapshot.is_empty()
    if not should_replace:
        should_replace = fps_now < int(current_snapshot.get("fps", fps_now))
        if not should_replace and fps_now <= int(current_snapshot.get("fps", fps_now)):
            should_replace = cpu_ms > float(current_snapshot.get("cpu_ms", 0.0))
        if not should_replace and cpu_ms >= float(current_snapshot.get("cpu_ms", 0.0)):
            should_replace = float(_perf_probe_last_samples.get("renderer_draw", 0.0)) > float(current_snapshot.get("renderer_draw_ms", 0.0))
    return should_replace

func _make_perf_snapshot(fps_now: int, frame_ms: float, cpu_ms: float, phys_ms: float) -> Dictionary:
    return {
        "fps": fps_now,
        "frame_ms": frame_ms,
        "cpu_ms": cpu_ms,
        "phys_ms": phys_ms,
        "process_frame_ms": float(_perf_probe_last_samples.get("process_frame", 0.0)),
        "update_combat_ms": float(_perf_probe_last_samples.get("update_combat", 0.0)),
        "update_pickups_ms": float(_perf_probe_last_samples.get("update_pickups", 0.0)),
        "update_core_attacks_ms": float(_perf_probe_last_samples.get("update_core_attacks", 0.0)),
        "update_perf_debug_ms": float(_perf_probe_last_samples.get("update_perf_debug", 0.0)),
        "auto_fire_laser_ms": float(_perf_probe_last_samples.get("auto_fire_laser", 0.0)),
        "update_mega_beam_ms": float(_perf_probe_last_samples.get("update_mega_beam", 0.0)),
        "damage_block_ms": float(_perf_probe_last_samples.get("damage_block", 0.0)),
        "renderer_draw_ms": float(_perf_probe_last_samples.get("renderer_draw", 0.0)),
        "renderer_bg_ms": float(_perf_probe_last_samples.get("renderer_bg", 0.0)),
        "renderer_fill_ms": float(_perf_probe_last_samples.get("renderer_fill", 0.0)),
        "renderer_fill_resize_ms": float(_perf_probe_last_samples.get("renderer_fill_resize", 0.0)),
        "renderer_fill_rebuild_ms": float(_perf_probe_last_samples.get("renderer_fill_rebuild", 0.0)),
        "renderer_fill_upload_ms": float(_perf_probe_last_samples.get("renderer_fill_upload", 0.0)),
        "renderer_edge_ms": float(_perf_probe_last_samples.get("renderer_edge", 0.0)),
        "renderer_blocks_ms": float(_perf_probe_last_samples.get("renderer_blocks", 0.0)),
        "renderer_power_blocks_ms": float(_perf_probe_last_samples.get("renderer_power_blocks", 0.0)),
        "renderer_overlays_ms": float(_perf_probe_last_samples.get("renderer_overlays", 0.0)),
        "perf_graph_draw_ms": float(_perf_probe_last_samples.get("perf_graph_draw", 0.0)),
        "ship_draw_ms": float(_perf_probe_last_samples.get("ship_draw", 0.0)),
        "ship_draw_rings_ms": float(_perf_probe_last_samples.get("ship_draw_rings", 0.0)),
        "ship_draw_drones_ms": float(_perf_probe_last_samples.get("ship_draw_drones", 0.0)),
        "pickups": pickups.size(),
        "hit_fx": hit_timers.size(),
        "seismic_fx": seismic_charge_bursts.size(),
        "e_arcs": electric_arcs.size(),
        "c_arcs": chain_arcs.size(),
        "d_beams": drone_beams.size(),
        "d_missiles": drone_missiles.size(),
        "d_mines": drone_mines.size(),
        "blocks_alive": blocks.size(),
        "blocks_cleared_in_frame": _frame_destroyed_blocks,
        "net_block_drop_in_frame": int(_perf_probe_last_samples.get("net_block_drop_in_frame", 0.0)),
        "camera_pos": camera_pos,
        "ship_pos": ship_pos,
        "planet_state": planet_renderer.call("get_perf_state_text") if planet_renderer != null and planet_renderer.has_method("get_perf_state_text") else "",
    }

func _sample_average_ms(samples: Array) -> float:
    if samples.is_empty():
        return 0.0
    var total := 0.0
    for sample_variant in samples:
        total += float(sample_variant)
    return total / float(samples.size())

func _sample_worst_one_percent_ms(samples: Array) -> float:
    if samples.is_empty():
        return 0.0
    var sorted_samples: Array = samples.duplicate()
    sorted_samples.sort()
    var idx := clampi(int(ceil(float(sorted_samples.size()) * 0.99)) - 1, 0, sorted_samples.size() - 1)
    return float(sorted_samples[idx])

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

func _mark_hit_flash(pos: Vector2i) -> void:
    if hit_timers.has(pos) or hit_timers.size() < MAX_ACTIVE_HIT_FLASHES:
        hit_timers[pos] = HIT_FLASH_DURATION

func _play_block_break_audio(block_type: int) -> void:
    var now_ms := Time.get_ticks_msec()
    if block_type == BlockType.CORE:
        if now_ms - _last_core_break_audio_ms < CORE_BREAK_AUDIO_COOLDOWN_MS:
            return
        _last_core_break_audio_ms = now_ms
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.PLANET_BREAK, -6.0)
        return
    if now_ms - _last_block_break_audio_ms < BLOCK_BREAK_AUDIO_COOLDOWN_MS:
        return
    _last_block_break_audio_ms = now_ms
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_ASTEROID_DESTORY, -10.0)

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
    var seen_core_ids := {}
    for dx in range(-grid_range, grid_range + 1):
        for dy in range(-grid_range, grid_range + 1):
            var check := Vector2i(center_grid.x + dx, center_grid.y + dy)
            if is_grid_empty(check):
                continue
            var core_id: int = int(blocks.get(check, {}).get("core_id", -1))
            if core_id >= 0:
                continue
            var dist_sq := world_pos.distance_squared_to(grid_to_world(check))
            if dist_sq > radius_sq:
                continue
            var insert_idx := candidates.size()
            while insert_idx > 0 and dist_sq < float(candidates[insert_idx - 1].get("dist_sq", INF)):
                insert_idx -= 1
            if insert_idx >= limit and candidates.size() >= limit:
                continue
            candidates.insert(insert_idx, {"pos": check, "dist_sq": dist_sq, "core_id": core_id})
            if candidates.size() > limit:
                candidates.resize(limit)
    for idx in range(mini(limit, candidates.size())):
        found.append(candidates[idx].get("pos", Vector2i.ZERO))
    return found

func _get_attack_load_tier() -> int:
    var load := hit_timers.size() + seismic_charge_bursts.size() + electric_arcs.size() + chain_arcs.size() + drone_beams.size() + drone_missiles.size() + drone_mines.size()
    if load >= ATTACK_LOAD_HARD_LIMIT:
        return 2
    if load >= ATTACK_LOAD_SOFT_LIMIT:
        return 1
    return 0

func _get_effective_multi_target_count() -> int:
    var max_targets := maxi(1, int(runtime_stats.get("multi_target", 1)))
    match _get_attack_load_tier():
        2:
            return 1
        1:
            return mini(max_targets, 2)
        _:
            return max_targets

func _get_effective_chain_lightning_jumps() -> int:
    var jumps := int(runtime_stats.get("chain_lightning_jumps", 3))
    match _get_attack_load_tier():
        2:
            return mini(jumps, 1)
        1:
            return mini(jumps, 2)
        _:
            return jumps

func _get_effective_aoe_neighbors() -> Array:
    match _get_attack_load_tier():
        2:
            return [Vector2i(1, 0)]
        1:
            return [Vector2i(1, 0), Vector2i(-1, 0)]
        _:
            return [Vector2i(1, 0), Vector2i(-1, 0)]

func _get_effective_splash_target_limit(radius_cells: int) -> int:
    if radius_cells <= 1:
        return 2
    match _get_attack_load_tier():
        2:
            return 2
        1:
            return 3
        _:
            return 4

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
    var core_id: int = int(block.get("core_id", -1))
    if int(block.get("type", BlockType.NORMAL)) == BlockType.CORE and core_id >= 0 and planet_data != null:
        for core_variant in planet_data.cores:
            var core: Dictionary = core_variant
            if int(core.get("id", -1)) == core_id:
                return planet_data.get_core_hp_ratio(core)
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
    var core_id: int = int(core.get("id", -1))
    cores_destroyed_this_run += 1
    core_currency_earned_this_run += 1
    cipher_laser_states.erase(core_id)
    ghost_debris_timers.erase("debris_%d" % core_id)
    root_cross_lasers.erase(core_id)
    for idx in range(ghost_debris.size() - 1, -1, -1):
        if int(ghost_debris[idx].get("core_id", -1)) == core_id:
            ghost_debris.remove_at(idx)
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.PLANET_BREAK, -2.0, -0.08)
    if breach_chat != null:
        breach_chat.notify_core_destroyed(core)
        _flush_breach_chat()
    if core_id == int(PLANET_DATA_SCRIPT.FINAL_CORE_ID):
        boss_defeated = true
        final_core_exposed = true
    if minimap != null:
        minimap.queue_redraw()

func _update_core_behaviors(delta: float) -> void:
    if planet_data == null:
        return
    var behaviors: Dictionary = planet_data.get_active_core_behaviors()
    if bool(behaviors.get("defense_blocks", false)) or bool(behaviors.get("final_lockdown", false)):
        core_defense_timer -= delta
        if core_defense_timer <= 0.0:
            core_defense_timer = DEFENSE_BLOCK_INTERVAL * (0.6 if bool(behaviors.get("final_lockdown", false)) else 1.0)
            var spawned_positions: Array[Vector2i] = planet_data.spawn_defense_blocks()
            if not spawned_positions.is_empty():
                blocks = planet_data.blocks
                exposed_edges = planet_data.exposed_edges
                if planet_renderer != null:
                    planet_renderer.queue_fill_updates(spawned_positions)
    if bool(behaviors.get("shockwave", false)) or bool(behaviors.get("final_lockdown", false)):
        core_shockwave_timer -= delta
        if core_shockwave_timer <= 0.0:
            core_shockwave_timer = CORE_SHOCKWAVE_INTERVAL * (0.5 if bool(behaviors.get("final_lockdown", false)) else 1.0)
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
    var perf_start_us := perf_probe_begin()
    if planet_data == null:
        perf_probe_end("update_core_attacks", perf_start_us)
        return
    _update_ghost_debris(delta)
    _update_root_cross_lasers(delta)
    perf_probe_end("update_core_attacks", perf_start_us)

func _is_ship_in_core_influence(core: Dictionary) -> bool:
    var radius: float = float(planet_data.get_effective_influence_radius(core)) * BLOCK_SIZE
    return ship_pos.distance_squared_to(grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))) <= radius * radius

func _update_cipher_lasers(delta: float) -> void:
    for core in planet_data.cores:
        if not bool(core.alive) or int(core.zone) != PLANET_DATA_SCRIPT.Zone.CIPHER:
            continue
        var cid: int = int(core.id)
        var is_boss: bool = str(core.role) == "boss" or str(core.role) == "final"
        if not _is_ship_in_core_influence(core):
            cipher_laser_states.erase(cid)
            continue
        var hp_ratio: float = planet_data.get_core_hp_ratio(core)
        var interval := SUMMER_LASER_INTERVAL_OUTER
        if is_boss:
            interval = SUMMER_LASER_INTERVAL_BOSS_LOW if hp_ratio <= SUMMER_LASER_BOSS_HP_THRESHOLD else SUMMER_LASER_INTERVAL_BOSS
        var state: Dictionary = cipher_laser_states.get(cid, {
            "state": "idle",
            "timer": interval,
            "warn_time": SUMMER_LASER_WARN_BOSS if is_boss else SUMMER_LASER_WARN_OUTER,
            "origin": grid_to_world(Vector2i(int(core.center.x), int(core.center.y))),
            "dir": Vector2.RIGHT,
            "interval": interval,
            "fire_duration": SUMMER_LASER_FIRE_DURATION,
            "hit_timer": 0.0,
            "core_id": cid,
            "is_boss": is_boss,
        })
        state["interval"] = interval
        state["origin"] = grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
        state["timer"] = float(state.get("timer", interval)) - delta
        var desired_dir := (ship_pos - Vector2(state["origin"])).normalized()
        if desired_dir.length() < 0.01:
            desired_dir = Vector2.RIGHT
        match str(state.get("state", "idle")):
            "idle":
                if float(state.get("timer", 0.0)) <= 0.0:
                    state["state"] = "warning"
                    state["timer"] = float(state.get("warn_time", SUMMER_LASER_WARN_OUTER))
                    state["dir"] = desired_dir
            "warning":
                var current_dir := Vector2(state.get("dir", Vector2.RIGHT))
                if current_dir.length() < 0.01:
                    current_dir = desired_dir
                state["dir"] = current_dir.slerp(desired_dir, clampf(delta * SUMMER_LASER_TRACK_SPEED, 0.0, 1.0)).normalized()
                if float(state.get("timer", 0.0)) <= 0.0:
                    state["state"] = "firing"
                    state["timer"] = float(state.get("fire_duration", SUMMER_LASER_FIRE_DURATION))
                    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_LASER, -8.0, -0.08)
            "firing":
                _check_cipher_laser_hit(state)
                if float(state.get("timer", 0.0)) <= 0.0:
                    state["state"] = "idle"
                    state["timer"] = interval
        cipher_laser_states[cid] = state

func _check_cipher_laser_hit(state: Dictionary) -> void:
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
        _apply_ship_hazard_hit(
            (ship_pos - origin).normalized(),
            "The rig was lanced by a Cipher Depths core.",
            int(state.get("core_id", -1)),
            PLANET_DATA_SCRIPT.Zone.CIPHER,
            "boss" if bool(state.get("is_boss", false)) else "outer"
        )

func _update_ghost_debris(delta: float) -> void:
    if planet_data == null:
        return
    for core in planet_data.cores:
        if not bool(core.alive) or int(core.zone) != PLANET_DATA_SCRIPT.Zone.GHOST:
            continue
        if not _is_ship_in_core_influence(core):
            continue
        var cid: int = int(core.id)
        var is_boss: bool = str(core.role) == "boss" or str(core.role) == "final"
        var hp_ratio: float = planet_data.get_core_hp_ratio(core)
        var timer_key := "debris_%d" % cid
        var timer: float = float(ghost_debris_timers.get(timer_key, 0.0)) - delta
        if timer <= 0.0 and ghost_debris.size() < AUTUMN_DEBRIS_MAX_ACTIVE:
            timer = AUTUMN_DEBRIS_INTERVAL_OUTER
            var spawn_count := AUTUMN_DEBRIS_COUNT_OUTER
            if is_boss:
                if hp_ratio <= SUMMER_LASER_BOSS_HP_THRESHOLD:
                    timer = AUTUMN_DEBRIS_INTERVAL_BOSS_LOW
                    spawn_count = AUTUMN_DEBRIS_COUNT_BOSS_LOW
                else:
                    timer = AUTUMN_DEBRIS_INTERVAL_BOSS
                    spawn_count = AUTUMN_DEBRIS_COUNT_BOSS
            _spawn_ghost_debris(core, spawn_count)
        ghost_debris_timers[timer_key] = timer
    for idx in range(ghost_debris.size() - 1, -1, -1):
        var debris: Dictionary = ghost_debris[idx]
        var pos: Vector2 = debris.get("pos", Vector2.ZERO)
        var vel: Vector2 = debris.get("vel", Vector2.ZERO)
        var desired: Vector2 = (ship_pos - pos).normalized() * AUTUMN_DEBRIS_SPEED
        vel = vel.lerp(desired, clampf(delta * AUTUMN_DEBRIS_HOMING_STRENGTH, 0.0, 1.0))
        pos += vel * delta
        debris["pos"] = pos
        debris["vel"] = vel
        ghost_debris[idx] = debris
        if pos.distance_to(ship_pos) <= AUTUMN_DEBRIS_HIT_RADIUS + SHIP_RADIUS:
            ghost_debris.remove_at(idx)
            _apply_ship_hazard_hit(
                (ship_pos - pos).normalized(),
                "The rig was shredded by Ghost Sector debris.",
                int(debris.get("core_id", -1)),
                PLANET_DATA_SCRIPT.Zone.GHOST,
                "boss" if bool(debris.get("is_boss", false)) else "outer"
            )

func _spawn_ghost_debris(core: Dictionary, count: int) -> void:
    var origin: Vector2 = grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
    for _idx in range(count):
        var angle: float = rng.randf() * TAU
        ghost_debris.append({
            "pos": origin,
            "vel": Vector2.from_angle(angle) * AUTUMN_DEBRIS_SPEED,
            "life": AUTUMN_DEBRIS_LIFETIME,
            "core_id": int(core.id),
            "is_boss": str(core.role) == "boss" or str(core.role) == "final",
        })

func _update_root_cross_lasers(delta: float) -> void:
    for core in planet_data.cores:
        if not bool(core.alive) or int(core.zone) != PLANET_DATA_SCRIPT.Zone.ROOT:
            continue
        var cid: int = int(core.id)
        if not _is_ship_in_core_influence(core):
            root_cross_lasers.erase(cid)
            continue
        var hp_ratio: float = planet_data.get_core_hp_ratio(core)
        var is_boss: bool = str(core.role) == "boss" or str(core.role) == "final"
        var speed := WINTER_CROSS_LASER_SPEED_BASE
        if hp_ratio < 1.0:
            speed = WINTER_CROSS_LASER_SPEED_BOSS_LOW if is_boss and hp_ratio <= WINTER_CROSS_LASER_BOSS_HP_THRESHOLD else WINTER_CROSS_LASER_SPEED_ATTACKED
        var beam_length: float = float(planet_data.get_effective_influence_radius(core)) * BLOCK_SIZE
        var core_pixel_radius: float = float(int(core.get("size", 3))) * 0.5 * BLOCK_SIZE
        var edge_ratio: float = clampf(core_pixel_radius / maxf(beam_length, 1.0) + 0.05, 0.1, 0.4)
        var state: Dictionary = root_cross_lasers.get(cid, {
            "angle": rng.randf() * TAU,
            "origin": grid_to_world(Vector2i(int(core.center.x), int(core.center.y))),
            "length": beam_length,
            "speed": speed,
            "hit_timer": 0.0,
            "core_edge_ratio": edge_ratio,
            "gaps": [],
            "core_id": cid,
            "is_boss": is_boss,
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
        _check_root_cross_laser_hit(state)
        root_cross_lasers[cid] = state

func _check_root_cross_laser_hit(state: Dictionary) -> void:
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
        _apply_ship_hazard_hit(
            (ship_pos - origin).normalized(),
            "The rig was caught in a Root Well cross-laser.",
            int(state.get("core_id", -1)),
            PLANET_DATA_SCRIPT.Zone.ROOT,
            "boss" if bool(state.get("is_boss", false)) else "outer"
        )
        return

func _apply_ship_hazard_hit(push_dir: Vector2, reason: String, core_id: int = -1, zone: int = -1, role: String = "outer") -> void:
    if run_finished:
        return
    var applied_dir := push_dir if push_dir.length() > 0.01 else Vector2.UP
    if _trigger_ship_shield_hit(applied_dir):
        if breach_chat != null and core_id >= 0:
            breach_chat.notify_node_landed_hit(core_id, zone, role, barriers_left)
            _flush_breach_chat()
        return
    _finish_run(false, reason)

func _trigger_ship_shield_hit(hit_dir: Vector2) -> bool:
    if shield_invuln_timer > 0.0:
        return true
    if barriers_left <= 0:
        return false
    barriers_left -= 1
    shield_invuln_timer = SHIELD_HIT_INVULN_TIME
    shield_recovery_timer = SHIELD_HIT_RECOVERY_TIME
    var move_dir := ship_vel.normalized()
    if move_dir.length() < 0.01:
        move_dir = last_move_dir.normalized()
    if move_dir.length() < 0.01:
        move_dir = hit_dir.normalized()
    if move_dir.length() < 0.01:
        move_dir = Vector2.UP
    var bounce_dir := -move_dir
    var bounced_pos := ship_pos + bounce_dir * SHIELD_HIT_BOUNCE_DISTANCE
    bounced_pos = _resolve_shield_bounce_destination(bounced_pos)
    ship_pos = bounced_pos
    ship_vel = Vector2.ZERO
    if ship_pos.length() > 0.0:
        var max_radius := (float(planet_radius_cells) + 10.0) * BLOCK_SIZE
        ship_pos = ship_pos.limit_length(max_radius)
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK, -10.0, -0.08)
    return true

func _resolve_shield_bounce_destination(target_world: Vector2) -> Vector2:
    var target_grid := world_to_grid(target_world)
    if is_grid_empty(target_grid):
        return target_world
    var fallback_world := _find_closest_empty_world_on_screen(target_world)
    if fallback_world != Vector2.INF:
        return fallback_world
    return target_world

func _find_closest_empty_world_on_screen(preferred_world: Vector2) -> Vector2:
    var zoom := camera.zoom if camera != null else Vector2.ONE
    var zoom_x := maxf(absf(zoom.x), 0.001)
    var zoom_y := maxf(absf(zoom.y), 0.001)
    var viewport_size := get_viewport_rect().size
    var half_size := Vector2(viewport_size.x * 0.5 / zoom_x, viewport_size.y * 0.5 / zoom_y)
    var visible_min_world := camera_pos - half_size
    var visible_max_world := camera_pos + half_size
    var min_grid := world_to_grid(visible_min_world - Vector2.ONE * (BLOCK_SIZE * 0.5))
    var max_grid := world_to_grid(visible_max_world + Vector2.ONE * (BLOCK_SIZE * 0.5))
    var best_world := Vector2.INF
    var best_dist_sq := INF
    for x in range(min_grid.x, max_grid.x + 1):
        for y in range(min_grid.y, max_grid.y + 1):
            var grid := Vector2i(x, y)
            if not is_grid_empty(grid):
                continue
            var world := grid_to_world(grid)
            var dist_sq := preferred_world.distance_squared_to(world)
            if dist_sq < best_dist_sq:
                best_dist_sq = dist_sq
                best_world = world
    return best_world

func _has_core_upgrade(upgrade_id: String) -> bool:
    var purchased: Array = persistent_data.get("purchased_core_upgrades", [])
    return upgrade_id in purchased

func _core_unlocks_center() -> bool:
    return bool(persistent_data.get("free_planet_mode", false)) or _has_core_upgrade("center_unlock")

func scene_to_spawn_ring(target_grid: Vector2i) -> Vector2:
    if planet_data != null:
        return planet_data.get_spawn_world_position(target_grid)
    return Vector2.ZERO

func get_visual_power() -> float:
    var damage := float(runtime_stats.get("attack_damage", 8.0))
    if damage <= 1.0:
        return 0.0
    return clampf(log(damage) / log(150.0), 0.0, 1.0)

func get_ship_render_rotation() -> float:
    return visual_rotation + deg_to_rad(ship_render_rotation_offset_degrees)

func _get_xp_reward_for_block(block: Dictionary) -> int:
    var base_xp := 1.0
    match int(block.get("type", BlockType.NORMAL)):
        BlockType.ELECTRIC, BlockType.GOLD:
            base_xp = 2.0
        BlockType.CORE:
            base_xp = 4.0
        BlockType.THORN:
            base_xp = 1.0
    base_xp += maxf(0.0, float(int(block.get("layer_depth", 1)) - 1) * 0.5)
    return maxi(1, int(round(base_xp * float(runtime_stats.get("xp_gain_mult", 1.0)))))

func _update_current_layer_name() -> void:
    var grid := world_to_grid(ship_pos)
    var layer_depth: int = planet_data.get_depth_level_for_pos(grid, current_depth_level) if planet_data != null else 1
    current_layer_depth = layer_depth
    current_layer_name = str(BALANCE.get_layer_for_depth(min(layer_depth, BALANCE.MAX_DEPTH_LEVEL)).get("name", "Proxy Cache"))

func _render_breach_log() -> void:
    if breach_log_label == null:
        return
    var title := "[color=#7dd6ff]BREACH LOG[/color]"
    if breach_chat != null:
        title = breach_chat.get_title()
    breach_log_label.text = title if breach_log_lines.is_empty() else title + "\n" + "\n".join(breach_log_lines)

func _flush_breach_chat(force_all: bool = false) -> void:
    if breach_chat == null:
        return
    for line in breach_chat.drain_ready_lines(force_all):
        _push_breach_log(line)

func _build_breach_chat_snapshot() -> Dictionary:
    var pressure := _get_breach_chat_pressure_state()
    return {
        "depth_level": current_depth_level,
        "layer_depth": current_layer_depth,
        "layer_name": current_layer_name,
        "core_pressure_stage": int(pressure.get("stage", 0)),
        "core_pressure_tier": int(pressure.get("tier", 0)),
        "core_pressure_zone": str(pressure.get("zone_name", "surface")),
        "final_core_exposed": final_core_exposed,
    }

func _get_breach_chat_pressure_state() -> Dictionary:
    if planet_data == null:
        return {"stage": 0, "tier": 0, "zone_name": "surface"}
    var best_ratio := INF
    var best_core: Dictionary = {}
    for core_variant in planet_data.cores:
        var core: Dictionary = core_variant
        if not bool(core.get("alive", false)):
            continue
        var radius := maxf(1.0, float(planet_data.get_effective_influence_radius(core)) * BLOCK_SIZE)
        var core_center: Vector2i = core.get("center", Vector2i.ZERO)
        var center := grid_to_world(core_center)
        var ratio := ship_pos.distance_to(center) / radius
        if ratio < best_ratio:
            best_ratio = ratio
            best_core = core
    if best_core.is_empty():
        return {"stage": 0, "tier": 0, "zone_name": "surface"}
    var stage := 0
    if best_ratio <= 0.35:
        stage = 4 if str(best_core.get("role", "")) == "final" else 3
    elif best_ratio <= 0.75:
        stage = 2
    elif best_ratio <= 1.15:
        stage = 1
    return {
        "stage": stage,
        "tier": PLANET_DATA_SCRIPT.get_core_tier(int(best_core.get("id", -1))),
        "zone_name": _breach_chat_zone_name(int(best_core.get("zone", PLANET_DATA_SCRIPT.Zone.CENTER))),
    }

func _breach_chat_zone_name(zone: int) -> String:
    match zone:
        PLANET_DATA_SCRIPT.Zone.PROXY:
            return "Proxy Cache"
        PLANET_DATA_SCRIPT.Zone.CIPHER:
            return "Cipher Depths"
        PLANET_DATA_SCRIPT.Zone.GHOST:
            return "Ghost Sector"
        PLANET_DATA_SCRIPT.Zone.ROOT:
            return "Root Well"
        _:
            return "Kernel Vault"

func _on_final_core_exposed() -> void:
    final_core_exposed = true
    bottom_phase_unlocked = true
    persistent_data["bottom_phase_unlocked"] = true
    bottom_cutscene_timer = BOTTOM_CUTSCENE_DURATION
    if planet_data != null:
        for core_variant in planet_data.cores:
            var core: Dictionary = core_variant
            if int(core.get("id", -1)) == int(PLANET_DATA_SCRIPT.FINAL_CORE_ID):
                bottom_cutscene_anchor = grid_to_world(Vector2i(int(core.center.x), int(core.center.y)))
                break
    side_projectiles.clear()
    _spawn_side_attackers()
    side_shot_timer = 0.8
    _push_breach_log("[color=#ff7d7d]ALERT[/color]  center shell split. side-channel guns waking up.")
    if breach_chat != null:
        breach_chat.notify_final_core_exposed()
        _flush_breach_chat()
