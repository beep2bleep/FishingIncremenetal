extends Node3D

const TURKEY_DATA := preload("res://Games/Turkey/TurkeyData.gd")
const TURKEY_PROGRESS := preload("res://Games/Turkey/TurkeyProgress.gd")
const IN_GAME_PAUSE_MENU_SCRIPT := preload("res://Core/InGamePauseMenu.gd")
const CRT_SHADER := preload("res://Games/Mining/UI/MiningCrt.gdshader")

const FRAME_COUNT := 3
const BASE_LANE_WIDTH := 1.05
const LANE_LENGTH := 9.144
const GUTTER_WIDTH := 0.34
const LANE_SURFACE_Y := 0.0
const BALL_RADIUS := 0.109
const PIN_MASS_KG := 1.53
const HEAD_PIN_Z := 8.45
const PIN_ROW_SPACING_Z := 0.264
const PIN_ROW_SPACING_X := 0.1524
const BALL_START_Z := -0.35
const POWER_SWEEP_BOTTOM_SPEED := 1.55
const POWER_SWEEP_TOP_SPEED := 0.42
const POWER_SWEEP_CURVE := 1.45
const THROW_MIN_SPEED := 6.0
const THROW_MAX_SPEED := 8.8
const SHOT_SETTLE_TIMEOUT := 5.0
const SHOT_SETTLE_GRACE := 0.45
const SHOT_SETTLE_CONFIRM := 0.28
const STANDING_UP_DOT := 0.84
const START_POSITION_WIDEN_MULT := 1.5
const START_X_LIMIT := 0.34 * START_POSITION_WIDEN_MULT
const TARGET_X_LIMIT := 0.48 * 1.5 * 1.5
const MAX_LATERAL_SPEED := 2.1 * 1.5 * 1.5
const FAST_FINISH_PIN_LINEAR_SPEED := 0.24
const FAST_FINISH_PIN_ANGULAR_SPEED := 0.42
const FAST_FINISH_BALL_FORWARD_SPEED := 0.55
const FAST_FINISH_BALL_TOTAL_SPEED := 1.1
## Lane / gutter floor collision ends here; open pit beyond so the ball drops instead of hugging a tall backstop.
const LANE_WORLD_Z_START := -0.55
const PIT_BACK_WALL_Z := LANE_LENGTH + 0.82
const PIT_FLOOR_Y := -2.45
const PIT_HALF_WIDTH_MIN := 1.22
const CRT_LEVEL_MAX := 11
const CRT_LAYER := 2
const PIN_DECK_MINIMAP_LAYER := 10
const EDITOR_DEBUG_LAYER := 3
const PIN_DECK_MINIMAP_VIEWPORT_SIZE := Vector2i(420, 300)
const PIN_DECK_MINIMAP_DISPLAY_SIZE := Vector2(210, 150)
const PIN_DECK_MINIMAP_CAMERA_HEIGHT := 14.0
const META_PIN_KIND := "turkey_pin_kind"
const PIN_KIND_NORMAL := "normal"
const PIN_KIND_GOLD := "gold"
const OPTION_NEUTRAL_COLOR := Color(0.84, 0.82, 0.76, 1.0)
const START_LEFT_COLOR := Color(0.23, 0.78, 0.86, 1.0)
const START_RIGHT_COLOR := Color(0.95, 0.64, 0.24, 1.0)
const SPIN_LEFT_COLOR := Color(0.9, 0.3, 0.32, 1.0)
const SPIN_RIGHT_COLOR := Color(0.36, 0.58, 0.96, 1.0)
const POWER_BAR_LOW_COLOR := Color(0.58, 0.6, 0.62, 1.0)
const POWER_BAR_HIGH_COLOR := Color(0.24, 0.82, 0.36, 1.0)
const POWER_BAR_BG_COLOR := Color(0.14, 0.15, 0.16, 1.0)

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
@onready var top_ui_vbox: VBoxContainer = %TopVBox
@onready var scorecard_label: Label = %ScorecardLabel
@onready var frame_status_label: Label = %FrameStatusLabel
@onready var result_label: Label = %ResultLabel
@onready var start_location_row: HBoxContainer = %StartLocationRow
@onready var spin_row: HBoxContainer = %SpinRow
@onready var aiming_help_label: Label = %AimingHelpLabel
@onready var power_label: Label = %PowerLabel
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
var current_lane_tier_data: Dictionary = {}
var frame_records: Array[Dictionary] = []
var current_frame_index := 0
var selected_start_value := 0.0
var selected_spin_value := 0.0
var current_target_x := 0.0
var current_power_norm := 0.0
var power_direction := 1.0
var shot_elapsed := 0.0
var shot_settled_elapsed := 0.0
var standing_before_throw := 10
var current_series_pin_target := 10
var current_pin_standing_dot := STANDING_UP_DOT
var active_ball: RigidBody3D
var active_pins: Array[RigidBody3D] = []
var lane_material: StandardMaterial3D
var pin_material: StandardMaterial3D
var pin_stripe_material: StandardMaterial3D
var pin_gold_material: StandardMaterial3D
var pin_gold_stripe_material: StandardMaterial3D
var ball_material: StandardMaterial3D
var aim_line_material: StandardMaterial3D
var start_slider: HSlider
var spin_slider: HSlider
var start_value_label: Label
var spin_value_label: Label
var spin_curve_in_play := 0.0
var pause_menu
var crt_level := 0
var crt_overlay_layer: CanvasLayer
var crt_overlay_rect: ColorRect
var crt_material: ShaderMaterial
var editor_debug_layer: CanvasLayer
var editor_debug_panel: PanelContainer
var editor_debug_label: Label
var power_bar_fill_style: StyleBoxFlat
var power_bar_background_style: StyleBoxFlat
var pin_deck_minimap_layer: CanvasLayer
var pin_deck_minimap_camera: Camera3D
var pin_deck_minimap_subviewport: SubViewport
var runtime_lane_width: float = BASE_LANE_WIDTH
var gutter_finish_x: float = BASE_LANE_WIDTH * 0.5 + GUTTER_WIDTH * 0.7
var pin_deck_back_z: float = HEAD_PIN_Z + PIN_ROW_SPACING_Z * 3.0
var shot_clearance_z: float = HEAD_PIN_Z + PIN_ROW_SPACING_Z * 3.0 + 0.38
var lane_surface_back_z: float = HEAD_PIN_Z + PIN_ROW_SPACING_Z * 3.0 + 0.48
var pit_half_width_active: float = PIT_HALF_WIDTH_MIN
var current_rack_has_gold_pin := false
var selected_lane_tier: int = 0
var series_gold_pins_knocked: int = 0
var standing_gold_before_throw: int = 0
var lane_tier_option: OptionButton
var lane_tier_row: HBoxContainer

func _ready() -> void:
    rng.randomize()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    title_label.text = "TURKEY"
    end_panel.hide()
    _setup_environment()
    _setup_materials()
    _setup_lane_tier_selector()
    _load_progression()
    _setup_option_sliders()
    _connect_ui()
    _setup_pause_menu()
    _setup_crt_overlay()
    _setup_editor_debug_ui()
    _setup_power_bar_visuals()
    _configure_ui_mouse_filters()
    _setup_pin_deck_minimap()
    _begin_series()

func _process(delta: float) -> void:
    _update_editor_debug_ui()
    if _is_pause_menu_open():
        return
    if run_state == RunState.AIMING:
        _advance_power_gauge(delta)
        _update_target_from_mouse(get_viewport().get_mouse_position().x)
        _update_power_bar()
        _update_aim_line()

func _physics_process(delta: float) -> void:
    if _is_pause_menu_open():
        return
    if run_state != RunState.BALL_IN_PLAY or active_ball == null or not is_instance_valid(active_ball):
        return

    shot_elapsed += delta
    _apply_spin_force()
    _apply_ball_guidance_force()

    var settle_speed: float = max(0.45, float(player_stats.get("settle_speed_mult", 1.0)) / max(0.75, float(player_stats.get("tier_settle_mult", 1.0))))
    if shot_elapsed < SHOT_SETTLE_GRACE / settle_speed:
        return

    if _is_shot_settled():
        shot_settled_elapsed += delta
    else:
        shot_settled_elapsed = 0.0

    if _should_finish_shot_early():
        _finish_throw()
    elif shot_settled_elapsed >= SHOT_SETTLE_CONFIRM / settle_speed or shot_elapsed >= SHOT_SETTLE_TIMEOUT / settle_speed:
        _finish_throw()

func _unhandled_input(event: InputEvent) -> void:
    if _handle_crt_hotkey_input(event):
        return
    if _handle_pause_menu_input(event):
        return
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
    var sky := Sky.new()
    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color(0.02, 0.04, 0.08, 1.0)
    sky_material.sky_horizon_color = Color(0.18, 0.11, 0.03, 1.0)
    sky_material.ground_bottom_color = Color(0.01, 0.01, 0.015, 1.0)
    sky_material.ground_horizon_color = Color(0.08, 0.06, 0.05, 1.0)
    sky_material.energy_multiplier = 0.7
    sky.sky_material = sky_material
    environment.background_mode = Environment.BG_SKY
    environment.sky = sky
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.46, 0.47, 0.5, 1.0)
    environment.ambient_light_energy = 0.65
    environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
    world_environment.environment = environment
    camera_3d.look_at(Vector3(0.0, 0.55, HEAD_PIN_Z * 0.62), Vector3.UP)

func _setup_materials() -> void:
    lane_material = StandardMaterial3D.new()
    lane_material.albedo_color = Color(0.53, 0.35, 0.18, 1.0)
    lane_material.roughness = 0.18
    lane_material.metallic = 0.05

    pin_material = StandardMaterial3D.new()
    pin_material.albedo_color = Color(0.96, 0.96, 0.97, 1.0)
    pin_material.roughness = 0.22
    pin_material.specular = 0.75

    pin_stripe_material = StandardMaterial3D.new()
    pin_stripe_material.albedo_color = Color(0.78, 0.1, 0.08, 1.0)
    pin_stripe_material.roughness = 0.32
    pin_stripe_material.specular = 0.55

    pin_gold_material = StandardMaterial3D.new()
    pin_gold_material.albedo_color = Color(0.98, 0.78, 0.22, 1.0)
    pin_gold_material.metallic = 0.82
    pin_gold_material.roughness = 0.24
    pin_gold_material.specular = 0.92
    pin_gold_material.emission_enabled = true
    pin_gold_material.emission = Color(0.55, 0.35, 0.06, 1.0)
    pin_gold_material.emission_energy_multiplier = 0.45

    pin_gold_stripe_material = StandardMaterial3D.new()
    pin_gold_stripe_material.albedo_color = Color(0.42, 0.12, 0.05, 1.0)
    pin_gold_stripe_material.metallic = 0.35
    pin_gold_stripe_material.roughness = 0.38
    pin_gold_stripe_material.specular = 0.65

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

func _rebuild_lane_geometry() -> void:
    var pin_count: int = max(10, int(player_stats.get("tier_pin_count", 10)))
    var spacing_mult: float = float(player_stats.get("tier_pin_spacing_mult", 1.0))
    var head_off: float = float(player_stats.get("tier_head_pin_z_offset", 0.0))
    var widest: int = _widest_row_pin_count(pin_count)
    var half_span_x: float = float(widest - 1) * PIN_ROW_SPACING_X * spacing_mult
    var lateral_margin: float = 0.11 * TURKEY_DATA.GOLD_PIN_SCALE
    runtime_lane_width = maxf(BASE_LANE_WIDTH, 2.0 * (half_span_x + lateral_margin))
    gutter_finish_x = runtime_lane_width * 0.5 + GUTTER_WIDTH * 0.7
    var rows: int = _count_rack_rows(pin_count)
    var spacing_z: float = PIN_ROW_SPACING_Z * spacing_mult
    pin_deck_back_z = HEAD_PIN_Z + head_off + float(rows - 1) * spacing_z + spacing_z * 0.42
    shot_clearance_z = pin_deck_back_z + 0.38
    lane_surface_back_z = pin_deck_back_z + 0.48
    pit_half_width_active = maxf(PIT_HALF_WIDTH_MIN, runtime_lane_width * 0.58 + 0.62)
    _build_lane()
    _update_pin_deck_minimap_camera(pin_count, spacing_mult, head_off, rows)


func _build_lane() -> void:
    for child in lane_root.get_children():
        child.queue_free()

    var lane_z_center: float = (LANE_WORLD_Z_START + lane_surface_back_z) * 0.5
    var lane_z_size: float = lane_surface_back_z - LANE_WORLD_Z_START
    var lane_half: float = runtime_lane_width * 0.5
    var approach_width: float = maxf(1.9, runtime_lane_width + 0.85)
    var wall_out: float = lane_half + GUTTER_WIDTH + 0.385
    var ceiling_w: float = maxf(2.2, wall_out * 2.0 + 0.72)
    var back_glow_w: float = maxf(1.8, runtime_lane_width + 0.78)
    var lane_light_x: float = lane_half * 1.485
    var gutter_light_x: float = lane_half + 0.355
    var head_pin_world_z: float = HEAD_PIN_Z + float(player_stats.get("tier_head_pin_z_offset", 0.0))

    _add_box_surface("Approach", Vector3(0.0, -0.03, -1.7), Vector3(approach_width, 0.06, 4.2), Color(0.18, 0.17, 0.15, 1.0), 0.75, 0.05)
    _add_box_surface("Lane", Vector3(0.0, -0.02, lane_z_center), Vector3(runtime_lane_width, 0.04, lane_z_size), lane_material.albedo_color, 0.85, 0.02)
    _add_box_surface("LeftGutter", Vector3(-(lane_half + GUTTER_WIDTH * 0.5), -0.08, lane_z_center), Vector3(GUTTER_WIDTH, 0.08, lane_z_size), Color(0.07, 0.07, 0.075, 1.0), 0.45, 0.06)
    _add_box_surface("RightGutter", Vector3(lane_half + GUTTER_WIDTH * 0.5, -0.08, lane_z_center), Vector3(GUTTER_WIDTH, 0.08, lane_z_size), Color(0.07, 0.07, 0.075, 1.0), 0.45, 0.06)
    _add_box_surface("LeftRail", Vector3(-(lane_half + GUTTER_WIDTH), 0.18, lane_z_center), Vector3(0.05, 0.36, lane_z_size), Color(0.11, 0.11, 0.12, 1.0), 0.7, 0.04)
    _add_box_surface("RightRail", Vector3(lane_half + GUTTER_WIDTH, 0.18, lane_z_center), Vector3(0.05, 0.36, lane_z_size), Color(0.11, 0.11, 0.12, 1.0), 0.7, 0.04)
    _add_ball_return_pit()
    _add_decor_box("LeftWall", Vector3(-wall_out, 1.4, LANE_LENGTH * 0.45), Vector3(0.08, 2.8, LANE_LENGTH + 1.5), Color(0.05, 0.05, 0.06, 1.0), Color(0.03, 0.0, 0.0, 1.0))
    _add_decor_box("RightWall", Vector3(wall_out, 1.4, LANE_LENGTH * 0.45), Vector3(0.08, 2.8, LANE_LENGTH + 1.5), Color(0.05, 0.05, 0.06, 1.0), Color(0.03, 0.0, 0.0, 1.0))
    _add_decor_box("CeilingBar", Vector3(0.0, 2.4, LANE_LENGTH * 0.35), Vector3(ceiling_w, 0.12, LANE_LENGTH * 0.9), Color(0.08, 0.08, 0.09, 1.0), Color(0.25, 0.18, 0.05, 1.0))
    _add_decor_box("BackGlow", Vector3(0.0, 1.1, LANE_LENGTH + 0.35), Vector3(back_glow_w, 1.4, 0.05), Color(0.17, 0.08, 0.05, 1.0), Color(0.42, 0.2, 0.08, 1.0))
    _add_decor_box("BackSign", Vector3(0.0, 1.45, LANE_LENGTH + 0.3), Vector3(maxf(1.1, runtime_lane_width * 0.52 + 0.35), 0.28, 0.03), Color(0.2, 0.14, 0.04, 1.0), Color(0.6, 0.45, 0.1, 1.0))
    _add_decor_box("LaneLightLeft", Vector3(-lane_light_x, 1.95, LANE_LENGTH * 0.35), Vector3(0.04, 0.04, LANE_LENGTH * 0.7), Color(0.22, 0.18, 0.07, 1.0), Color(0.75, 0.62, 0.22, 1.0))
    _add_decor_box("LaneLightRight", Vector3(lane_light_x, 1.95, LANE_LENGTH * 0.35), Vector3(0.04, 0.04, LANE_LENGTH * 0.7), Color(0.22, 0.18, 0.07, 1.0), Color(0.75, 0.62, 0.22, 1.0))
    _add_accent_orb(Vector3(-(wall_out + 0.45), 1.9, LANE_LENGTH * 0.3), 0.18, Color(0.75, 0.32, 0.1, 1.0))
    _add_accent_orb(Vector3(wall_out + 0.45, 1.85, LANE_LENGTH * 0.55), 0.14, Color(0.82, 0.68, 0.18, 1.0))
    _add_omni_fill_light("LaneFillNear", Vector3(0.0, 1.7, 1.9), Color(1.0, 0.9, 0.72, 1.0), 0.95, 4.9)
    _add_omni_fill_light("LaneFillMid", Vector3(0.0, 1.8, 5.3), Color(1.0, 0.88, 0.7, 1.0), 1.05, 5.5)
    _add_omni_fill_light("LeftGutterFill", Vector3(-gutter_light_x, 0.55, 4.5), Color(0.82, 0.88, 1.0, 1.0), 1.0, 3.1)
    _add_omni_fill_light("RightGutterFill", Vector3(gutter_light_x, 0.55, 4.5), Color(0.82, 0.88, 1.0, 1.0), 1.0, 3.1)
    _add_omni_fill_light("PinDeckFill", Vector3(0.0, 1.05, head_pin_world_z + 0.5), Color(1.0, 0.82, 0.62, 1.0), 0.82, 3.3)

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

func _add_ball_return_pit() -> void:
    var pit_depth: float = maxf(0.35, PIT_BACK_WALL_Z - lane_surface_back_z)
    var pit_z_center: float = lane_surface_back_z + pit_depth * 0.5
    var pit_width: float = pit_half_width_active * 2.0
    _add_box_surface(
        "BallReturnPitFloor",
        Vector3(0.0, PIT_FLOOR_Y, pit_z_center),
        Vector3(pit_width, 0.22, pit_depth + 0.45),
        Color(0.035, 0.035, 0.038, 1.0),
        0.88,
        0.02
    )
    _add_box_surface(
        "BallReturnPitBack",
        Vector3(0.0, -0.62, PIT_BACK_WALL_Z),
        Vector3(pit_width, 1.45, 0.14),
        Color(0.1, 0.04, 0.035, 1.0),
        0.72,
        0.04
    )
    _add_box_surface(
        "BallReturnPitWallLeft",
        Vector3(-pit_half_width_active - 0.07, -1.05, pit_z_center),
        Vector3(0.14, 2.2, pit_depth + 0.55),
        Color(0.055, 0.055, 0.06, 1.0),
        0.55,
        0.05
    )
    _add_box_surface(
        "BallReturnPitWallRight",
        Vector3(pit_half_width_active + 0.07, -1.05, pit_z_center),
        Vector3(0.14, 2.2, pit_depth + 0.55),
        Color(0.055, 0.055, 0.06, 1.0),
        0.55,
        0.05
    )

func _add_decor_box(name: String, position: Vector3, size: Vector3, color: Color, emission: Color = Color(0, 0, 0, 1)) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = name
    mesh_instance.position = position
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.26
    if emission != Color(0, 0, 0, 1):
        material.emission_enabled = true
        material.emission = emission
        material.emission_energy_multiplier = 0.8
    mesh_instance.material_override = material
    lane_root.add_child(mesh_instance)

func _add_accent_orb(position: Vector3, radius: float, emission: Color) -> void:
    var orb := MeshInstance3D.new()
    orb.position = position
    var sphere := SphereMesh.new()
    sphere.radius = radius
    sphere.height = radius * 2.0
    orb.mesh = sphere
    var material := StandardMaterial3D.new()
    material.albedo_color = emission
    material.emission_enabled = true
    material.emission = emission
    material.emission_energy_multiplier = 1.3
    material.roughness = 0.15
    orb.material_override = material
    lane_root.add_child(orb)

func _add_omni_fill_light(name: String, position: Vector3, color: Color, energy: float, light_range: float) -> void:
    var light := OmniLight3D.new()
    light.name = name
    light.position = position
    light.light_color = color
    light.light_energy = energy
    light.omni_range = light_range
    light.omni_attenuation = 1.0
    light.shadow_enabled = false
    lane_root.add_child(light)


func _count_rack_rows(pin_count: int) -> int:
    var remaining: int = maxi(1, pin_count)
    var row_size := 1
    var rows := 0
    while remaining > 0:
        rows += 1
        remaining -= mini(row_size, remaining)
        row_size += 1
    return rows


func _widest_row_pin_count(pin_count: int) -> int:
    var remaining: int = maxi(1, pin_count)
    var row_size := 1
    var widest := 1
    while remaining > 0:
        var c: int = mini(row_size, remaining)
        widest = maxi(widest, c)
        remaining -= c
        row_size += 1
    return widest


func _update_pin_deck_minimap_camera(pin_count: int, spacing_mult: float, head_off: float, rows: int) -> void:
    if pin_deck_minimap_camera == null or not is_instance_valid(pin_deck_minimap_camera):
        return
    var spacing_z: float = PIN_ROW_SPACING_Z * spacing_mult
    var deck_front: float = HEAD_PIN_Z + head_off
    var deck_back: float = HEAD_PIN_Z + head_off + float(rows - 1) * spacing_z
    var center_z: float = (deck_front + deck_back) * 0.5
    var depth: float = maxf(0.55, deck_back - deck_front + spacing_z * 0.95)
    var half_w: float = maxf(
        runtime_lane_width * 0.5,
        float(_widest_row_pin_count(pin_count) - 1) * PIN_ROW_SPACING_X * spacing_mult + 0.16
    )
    var aspect: float = float(PIN_DECK_MINIMAP_VIEWPORT_SIZE.x) / float(PIN_DECK_MINIMAP_VIEWPORT_SIZE.y)
    pin_deck_minimap_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    pin_deck_minimap_camera.size = maxf(depth * 0.52, half_w / aspect + 0.1)
    pin_deck_minimap_camera.position = Vector3(0.0, PIN_DECK_MINIMAP_CAMERA_HEIGHT, center_z)
    pin_deck_minimap_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
    pin_deck_minimap_camera.current = true


func _setup_pin_deck_minimap() -> void:
    if pin_deck_minimap_layer != null and is_instance_valid(pin_deck_minimap_layer):
        return

    pin_deck_minimap_layer = CanvasLayer.new()
    pin_deck_minimap_layer.name = "PinDeckMinimapLayer"
    pin_deck_minimap_layer.layer = PIN_DECK_MINIMAP_LAYER
    add_child(pin_deck_minimap_layer)

    var panel := PanelContainer.new()
    panel.name = "PinDeckMinimapPanel"
    panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    panel.offset_left = -PIN_DECK_MINIMAP_DISPLAY_SIZE.x - 28.0
    panel.offset_top = 96.0
    panel.offset_right = -24.0
    panel.offset_bottom = 96.0 + PIN_DECK_MINIMAP_DISPLAY_SIZE.y + 44.0
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    pin_deck_minimap_layer.add_child(panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 8)
    margin.add_theme_constant_override("margin_top", 8)
    margin.add_theme_constant_override("margin_right", 8)
    margin.add_theme_constant_override("margin_bottom", 8)
    margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    margin.add_child(vbox)

    var title := Label.new()
    title.text = "Pin deck (top)"
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vbox.add_child(title)

    var viewport_container := SubViewportContainer.new()
    viewport_container.custom_minimum_size = PIN_DECK_MINIMAP_DISPLAY_SIZE
    viewport_container.stretch = true
    viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vbox.add_child(viewport_container)

    var sub_viewport := SubViewport.new()
    sub_viewport.name = "PinDeckMinimapViewport"
    sub_viewport.size = PIN_DECK_MINIMAP_VIEWPORT_SIZE
    sub_viewport.transparent_bg = true
    sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    sub_viewport.handle_input_locally = false
    viewport_container.add_child(sub_viewport)
    pin_deck_minimap_subviewport = sub_viewport

    call_deferred("_bind_pin_deck_minimap_world", sub_viewport)

    pin_deck_minimap_camera = Camera3D.new()
    pin_deck_minimap_camera.name = "PinDeckTopDownCamera"
    pin_deck_minimap_camera.current = true
    pin_deck_minimap_camera.near = 0.05
    pin_deck_minimap_camera.far = 80.0
    sub_viewport.add_child(pin_deck_minimap_camera)

func _bind_pin_deck_minimap_world(sub_viewport: SubViewport) -> void:
    if sub_viewport == null or not is_instance_valid(sub_viewport):
        return
    var vp := get_viewport()
    if vp != null:
        sub_viewport.world_3d = vp.world_3d

func _configure_ui_mouse_filters() -> void:
    _set_mouse_filter_recursive($CanvasLayer, Control.MOUSE_FILTER_IGNORE)
    if start_slider != null:
        start_slider.mouse_filter = Control.MOUSE_FILTER_STOP
    if spin_slider != null:
        spin_slider.mouse_filter = Control.MOUSE_FILTER_STOP
    if lane_tier_option != null:
        lane_tier_option.mouse_filter = Control.MOUSE_FILTER_STOP
    play_again_button.mouse_filter = Control.MOUSE_FILTER_STOP
    upgrade_button.mouse_filter = Control.MOUSE_FILTER_STOP
    menu_button.mouse_filter = Control.MOUSE_FILTER_STOP

func _set_mouse_filter_recursive(node: Node, filter: Control.MouseFilter) -> void:
    if node is BaseButton:
        return
    if node is Control:
        (node as Control).mouse_filter = filter
    for child in node.get_children():
        _set_mouse_filter_recursive(child, filter)

func _setup_option_sliders() -> void:
    _clear_option_row(start_location_row)
    _clear_option_row(spin_row)

    start_slider = _build_option_slider()
    start_slider.value_changed.connect(_on_start_slider_changed)
    start_location_row.add_child(start_slider)
    start_value_label = _build_option_value_box(start_location_row)

    spin_slider = _build_option_slider()
    spin_slider.value_changed.connect(_on_spin_slider_changed)
    spin_row.add_child(spin_slider)
    spin_value_label = _build_option_value_box(spin_row)

    _refresh_option_controls()

func _clear_option_row(row: HBoxContainer) -> void:
    for child in row.get_children():
        child.queue_free()

func _build_option_slider() -> HSlider:
    var slider := HSlider.new()
    slider.min_value = -100.0
    slider.max_value = 100.0
    slider.step = 1.0
    slider.tick_count = 5
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    slider.custom_minimum_size = Vector2(0.0, 28.0)
    return slider

func _build_option_value_box(row: HBoxContainer) -> Label:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(72.0, 0.0)
    panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    row.add_child(panel)

    var label := Label.new()
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.add_child(label)
    return label

func _connect_ui() -> void:
    play_again_button.pressed.connect(_on_play_again_pressed)
    upgrade_button.pressed.connect(_on_upgrade_button_pressed)
    menu_button.pressed.connect(_on_menu_button_pressed)

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
    crt_overlay_layer.name = "TurkeyCrtOverlay"
    crt_overlay_layer.layer = CRT_LAYER
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

func _should_show_editor_debug_ui() -> bool:
    return OS.has_feature("editor")

func _setup_editor_debug_ui() -> void:
    if not _should_show_editor_debug_ui():
        return
    if editor_debug_layer != null and is_instance_valid(editor_debug_layer):
        return

    editor_debug_layer = CanvasLayer.new()
    editor_debug_layer.name = "TurkeyEditorDebugLayer"
    editor_debug_layer.layer = EDITOR_DEBUG_LAYER
    editor_debug_layer.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(editor_debug_layer)

    editor_debug_panel = PanelContainer.new()
    editor_debug_panel.name = "TurkeyEditorDebugPanel"
    editor_debug_panel.anchor_left = 1.0
    editor_debug_panel.anchor_top = 0.0
    editor_debug_panel.anchor_right = 1.0
    editor_debug_panel.anchor_bottom = 0.0
    editor_debug_panel.offset_left = -360.0
    editor_debug_panel.offset_top = 18.0
    editor_debug_panel.offset_right = -18.0
    editor_debug_panel.offset_bottom = 190.0
    editor_debug_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    editor_debug_layer.add_child(editor_debug_panel)

    var margin := MarginContainer.new()
    margin.anchor_left = 0.0
    margin.anchor_top = 0.0
    margin.anchor_right = 1.0
    margin.anchor_bottom = 1.0
    margin.offset_left = 10.0
    margin.offset_top = 8.0
    margin.offset_right = -10.0
    margin.offset_bottom = -8.0
    margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    editor_debug_panel.add_child(margin)

    editor_debug_label = Label.new()
    editor_debug_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    editor_debug_label.autowrap_mode = TextServer.AUTOWRAP_OFF
    editor_debug_label.clip_text = true
    editor_debug_label.add_theme_font_size_override("font_size", 13)
    margin.add_child(editor_debug_label)
    _update_editor_debug_ui()

func _setup_power_bar_visuals() -> void:
    power_bar_background_style = StyleBoxFlat.new()
    power_bar_background_style.bg_color = POWER_BAR_BG_COLOR
    power_bar_background_style.corner_radius_top_left = 6
    power_bar_background_style.corner_radius_top_right = 6
    power_bar_background_style.corner_radius_bottom_right = 6
    power_bar_background_style.corner_radius_bottom_left = 6
    power_bar_background_style.border_width_left = 1
    power_bar_background_style.border_width_top = 1
    power_bar_background_style.border_width_right = 1
    power_bar_background_style.border_width_bottom = 1
    power_bar_background_style.border_color = Color(0.3, 0.31, 0.34, 1.0)

    power_bar_fill_style = StyleBoxFlat.new()
    power_bar_fill_style.corner_radius_top_left = 6
    power_bar_fill_style.corner_radius_top_right = 6
    power_bar_fill_style.corner_radius_bottom_right = 6
    power_bar_fill_style.corner_radius_bottom_left = 6

    power_bar.add_theme_stylebox_override("background", power_bar_background_style)
    power_bar.add_theme_stylebox_override("fill", power_bar_fill_style)
    _update_power_bar_visuals()

func _load_progression() -> void:
    progress_data = TURKEY_PROGRESS.load_data()
    var cap_stats: Dictionary = TURKEY_DATA.build_meta_stats(progress_data)
    var max_cap: int = int(cap_stats.get("max_selectable_lane_tier", 0))
    selected_lane_tier = clampi(int(progress_data.get("turkey_selected_lane_tier", max_cap)), 0, max_cap)
    player_stats = TURKEY_DATA.build_meta_stats(progress_data, selected_lane_tier)
    _refresh_series_settings_from_stats()
    _update_wallet_label()
    _refresh_lane_tier_option_items()


func _setup_lane_tier_selector() -> void:
    lane_tier_row = HBoxContainer.new()
    lane_tier_row.add_theme_constant_override("separation", 10)
    var tier_lbl := Label.new()
    tier_lbl.text = "Lane tier"
    tier_lbl.custom_minimum_size = Vector2(92, 0)
    lane_tier_option = OptionButton.new()
    lane_tier_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    lane_tier_option.item_selected.connect(_on_lane_tier_option_selected)
    lane_tier_row.add_child(tier_lbl)
    lane_tier_row.add_child(lane_tier_option)
    top_ui_vbox.add_child(lane_tier_row)
    top_ui_vbox.move_child(lane_tier_row, mini(wallet_label.get_index() + 1, top_ui_vbox.get_child_count() - 1))


func _refresh_lane_tier_option_items() -> void:
    if lane_tier_option == null:
        return
    lane_tier_option.set_block_signals(true)
    lane_tier_option.clear()
    var max_cap: int = int(player_stats.get("max_selectable_lane_tier", 0)) if not player_stats.is_empty() else 0
    for i in range(TURKEY_DATA.LANE_TIERS.size()):
        var td: Dictionary = TURKEY_DATA.LANE_TIERS[i]
        var line: String = "%d. %s — %d pins, %d gold (front)" % [
            i + 1,
            str(td.get("label", "?")),
            int(td.get("pin_count", 10)),
            int(td.get("gold_pin_count", 0)),
        ]
        lane_tier_option.add_item(line)
        lane_tier_option.set_item_disabled(i, i > max_cap)
    var sel: int = clampi(selected_lane_tier, 0, maxi(0, lane_tier_option.item_count - 1))
    lane_tier_option.select(sel)
    lane_tier_option.set_block_signals(false)
    _update_lane_tier_control_state()


func _can_change_lane_tier() -> bool:
    if run_state == RunState.ROUND_OVER:
        return true
    return (
        run_state == RunState.READY
        and current_frame_index == 0
        and frame_records.size() > 0
        and frame_records[0].get("throws", []).is_empty()
    )


func _should_refresh_rack_for_tier_change() -> bool:
    return (
        run_state == RunState.READY
        and current_frame_index == 0
        and frame_records.size() > 0
        and frame_records[0].get("throws", []).is_empty()
    )


func _sync_lane_tier_option_to_selection() -> void:
    if lane_tier_option == null:
        return
    lane_tier_option.set_block_signals(true)
    lane_tier_option.select(clampi(selected_lane_tier, 0, maxi(0, lane_tier_option.item_count - 1)))
    lane_tier_option.set_block_signals(false)


func _update_lane_tier_control_state() -> void:
    if lane_tier_option == null:
        return
    lane_tier_option.disabled = not _can_change_lane_tier()
    var max_cap: int = int(player_stats.get("max_selectable_lane_tier", 0))
    for i in range(lane_tier_option.item_count):
        lane_tier_option.set_item_disabled(i, i > max_cap)


func _on_lane_tier_option_selected(index: int) -> void:
    if not _can_change_lane_tier():
        _sync_lane_tier_option_to_selection()
        return
    var max_cap: int = int(player_stats.get("max_selectable_lane_tier", 0))
    selected_lane_tier = clampi(index, 0, max_cap)
    progress_data["turkey_selected_lane_tier"] = selected_lane_tier
    TURKEY_PROGRESS.save_data(progress_data)
    player_stats = TURKEY_DATA.build_meta_stats(progress_data, selected_lane_tier)
    _refresh_series_settings_from_stats()
    _refresh_lane_tier_option_items()
    if _should_refresh_rack_for_tier_change():
        _rebuild_lane_geometry()
        _spawn_full_rack()
        _prepare_for_next_shot("Frame 1. Click once to start the power swing.")
    _update_lane_tier_control_state()


func _refresh_series_settings_from_stats() -> void:
    current_lane_tier_data = TURKEY_DATA.get_lane_tier(int(player_stats.get("lane_tier", 0)))
    selected_lane_tier = int(player_stats.get("lane_tier", 0))
    current_series_pin_target = max(10, int(player_stats.get("tier_pin_count", 10)))
    current_pin_standing_dot = float(player_stats.get("tier_pin_standing_dot", STANDING_UP_DOT))

func _begin_series() -> void:
    _close_pause_menu()
    _clear_dynamic_objects()
    _refresh_series_settings_from_stats()
    _rebuild_lane_geometry()
    frame_records.clear()
    for _i in range(FRAME_COUNT):
        frame_records.append({"throws": []})
    current_frame_index = 0
    run_state = RunState.READY
    current_power_norm = 0.0
    power_direction = 1.0
    end_panel.hide()
    spin_curve_in_play = 0.0
    series_gold_pins_knocked = 0
    _spawn_full_rack()
    _prepare_for_next_shot("Frame 1. Click once to start the power swing.")
    _update_scoreboard()
    _update_lane_tier_control_state()

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
    var gold_note := ""
    if _any_gold_pin_standing():
        gold_note = " Gold pins still up in front—they need a harder hit but pay more when they fall."
    aiming_help_label.text = "Tier %d: %s. %d pins, %d gold up front (heavier, bigger payout per knock).%s Negative slider = left, positive = right." % [int(player_stats.get("lane_tier", 0)) + 1, str(player_stats.get("lane_tier_label", "Practice House")), current_series_pin_target, int(player_stats.get("tier_gold_pin_count", 0)), gold_note]
    _update_lane_tier_control_state()

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
    _update_lane_tier_control_state()
    result_label.text = "Move the mouse to pick the line. Click again when the power bar feels right."
    var gold_aim := ""
    if int(player_stats.get("tier_gold_pin_count", 0)) > 0:
        gold_aim = " Gold pins are in the front row(s)—check the rack map."
    aiming_help_label.text = "Mouse left aims left, mouse right aims right. %s is active with %d pins in the rack.%s" % [str(player_stats.get("lane_tier_label", "Practice House")), current_series_pin_target, gold_aim]

func _throw_ball() -> void:
    run_state = RunState.BALL_IN_PLAY
    aim_line.visible = false
    shot_elapsed = 0.0
    shot_settled_elapsed = 0.0
    standing_before_throw = active_pins.size()
    standing_gold_before_throw = _count_standing_gold_pins()
    spin_curve_in_play = _get_selected_spin_curve() * float(player_stats.get("spin_multiplier", 1.0))

    active_ball = _create_ball()
    var start_x: float = _get_selected_start_x()
    var target_x: float = _get_launch_target_x()
    var power_speed: float = lerpf(THROW_MIN_SPEED, THROW_MAX_SPEED + float(player_stats.get("power_bonus", 0.0)), current_power_norm)
    var max_lateral_speed: float = MAX_LATERAL_SPEED * pow(float(player_stats.get("target_range_mult", 1.0)), 0.4)
    var lateral_speed: float = clamp((target_x - start_x) * 2.15, -max_lateral_speed, max_lateral_speed)
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
    var rows: Array[Array] = _build_rack_rows(current_series_pin_target)
    var spacing_mult: float = float(player_stats.get("tier_pin_spacing_mult", 1.0))
    var head_pin_offset: float = float(player_stats.get("tier_head_pin_z_offset", 0.0))
    var total_pins: int = current_series_pin_target
    var gold_front: int = clampi(int(player_stats.get("tier_gold_pin_count", 0)), 0, total_pins)
    current_rack_has_gold_pin = gold_front > 0
    var pin_index := 0
    for row_index in range(rows.size()):
        var row_positions: Array = rows[row_index]
        for x_variant in row_positions:
            var is_gold: bool = pin_index < gold_front
            var pin := _create_pin(
                Vector3(
                    float(x_variant) * PIN_ROW_SPACING_X * spacing_mult,
                    0.19 + (_gold_pin_vertical_lift() if is_gold else 0.0),
                    HEAD_PIN_Z + head_pin_offset + float(row_index) * PIN_ROW_SPACING_Z * spacing_mult
                ),
                is_gold
            )
            active_pins.append(pin)
            pin_index += 1

func _any_gold_pin_standing() -> bool:
    for pin in active_pins:
        if not is_instance_valid(pin):
            continue
        if str(pin.get_meta(META_PIN_KIND, PIN_KIND_NORMAL)) != PIN_KIND_GOLD:
            continue
        if _is_pin_standing(pin):
            return true
    return false


func _count_standing_gold_pins() -> int:
    var n := 0
    for pin in active_pins:
        if not is_instance_valid(pin):
            continue
        if str(pin.get_meta(META_PIN_KIND, PIN_KIND_NORMAL)) != PIN_KIND_GOLD:
            continue
        if _is_pin_standing(pin):
            n += 1
    return n


func _gold_pin_vertical_lift() -> float:
    var s: float = TURKEY_DATA.GOLD_PIN_SCALE
    var half_scaled: float = 0.24 * s * 0.5 + 0.06 * s
    var half_base: float = 0.24 * 0.5 + 0.06
    return maxf(0.0, half_scaled - half_base)

func _build_rack_rows(pin_count: int) -> Array[Array]:
    var rows: Array[Array] = []
    var remaining_pins: int = max(1, pin_count)
    var row_size := 1
    while remaining_pins > 0:
        var count_this_row: int = min(row_size, remaining_pins)
        var row_positions: Array = []
        var center_offset: float = (float(count_this_row) - 1.0) * 0.5
        for index in range(count_this_row):
            row_positions.append((float(index) - center_offset) * 2.0)
        rows.append(row_positions)
        remaining_pins -= count_this_row
        row_size += 1
    return rows

func _create_pin(position: Vector3, is_gold: bool = false) -> RigidBody3D:
    var body := RigidBody3D.new()
    body.name = "PinGold" if is_gold else "Pin"
    var tier_mass: float = PIN_MASS_KG * float(player_stats.get("tier_pin_mass_mult", 1.0))
    if is_gold:
        body.set_meta(META_PIN_KIND, PIN_KIND_GOLD)
        var gold_mass_scale: float = float(player_stats.get("tier_gold_mass_scale", 1.0))
        body.mass = tier_mass * TURKEY_DATA.GOLD_PIN_MASS_MULT * gold_mass_scale
    else:
        body.set_meta(META_PIN_KIND, PIN_KIND_NORMAL)
        body.mass = tier_mass
    body.position = position
    body.linear_damp = 0.22 * float(player_stats.get("tier_settle_mult", 1.0))
    body.angular_damp = 0.28 * float(player_stats.get("tier_settle_mult", 1.0))

    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    var coll_scale: float = TURKEY_DATA.GOLD_PIN_SCALE if is_gold else 1.0
    capsule.radius = 0.06 * coll_scale
    capsule.height = 0.24 * coll_scale
    collision.shape = capsule
    body.add_child(collision)
    _add_pin_visual(body, is_gold)

    var physics_material := PhysicsMaterial.new()
    if is_gold:
        physics_material.friction = 0.66
        physics_material.bounce = 0.1
    else:
        physics_material.friction = 0.52
        physics_material.bounce = 0.18
    body.physics_material_override = physics_material

    dynamic_root.add_child(body)
    return body

func _add_pin_visual(body: RigidBody3D, is_gold: bool = false) -> void:
    var visual_root := Node3D.new()
    visual_root.name = "PinVisual"
    body.add_child(visual_root)
    if is_gold:
        var vscale: float = TURKEY_DATA.GOLD_PIN_SCALE
        visual_root.scale = Vector3(vscale, vscale, vscale)

    var body_mat: Material = pin_gold_material if is_gold else pin_material
    var stripe_mat: Material = pin_gold_stripe_material if is_gold else pin_stripe_material
    _add_pin_mesh(visual_root, _make_pin_body_mesh(), Vector3(0.0, -0.02, 0.0), body_mat)
    _add_pin_mesh(visual_root, _make_pin_base_mesh(), Vector3(0.0, -0.102, 0.0), body_mat)
    _add_pin_mesh(visual_root, _make_pin_neck_mesh(), Vector3(0.0, 0.095, 0.0), body_mat)
    _add_pin_mesh(visual_root, _make_pin_cap_mesh(), Vector3(0.0, 0.17, 0.0), body_mat)
    _add_pin_mesh(visual_root, _make_pin_ring_mesh(0.051), Vector3(0.0, 0.06, 0.0), stripe_mat)
    _add_pin_mesh(visual_root, _make_pin_ring_mesh(0.046), Vector3(0.0, 0.082, 0.0), stripe_mat)

func _add_pin_mesh(parent: Node3D, mesh: PrimitiveMesh, position: Vector3, material: Material) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.position = position
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    parent.add_child(mesh_instance)

func _make_pin_body_mesh() -> PrimitiveMesh:
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.047
    mesh.bottom_radius = 0.064
    mesh.height = 0.22
    mesh.radial_segments = 20
    mesh.rings = 4
    return mesh

func _make_pin_base_mesh() -> PrimitiveMesh:
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.068
    mesh.bottom_radius = 0.083
    mesh.height = 0.075
    mesh.radial_segments = 20
    mesh.rings = 2
    return mesh

func _make_pin_neck_mesh() -> PrimitiveMesh:
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.023
    mesh.bottom_radius = 0.037
    mesh.height = 0.115
    mesh.radial_segments = 20
    mesh.rings = 3
    return mesh

func _make_pin_cap_mesh() -> PrimitiveMesh:
    var mesh := SphereMesh.new()
    mesh.radius = 0.03
    mesh.height = 0.06
    mesh.radial_segments = 20
    mesh.rings = 10
    return mesh

func _make_pin_ring_mesh(radius: float) -> PrimitiveMesh:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = 0.012
    mesh.radial_segments = 20
    mesh.rings = 1
    return mesh

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

func _lane_assist_gutter_falloff(abs_x: float) -> float:
    var edge: float = runtime_lane_width * 0.5
    if abs_x <= edge:
        return 1.0
    var depth: float = abs_x - edge
    var span: float = maxf(0.025, gutter_finish_x - edge)
    return clampf(1.0 - depth / span, 0.0, 1.0)

func _apply_ball_guidance_force() -> void:
    if active_ball == null or not is_instance_valid(active_ball):
        return
    if active_ball.position.z < 0.5:
        return
    var abs_x_ball: float = absf(active_ball.position.x)
    var gutter_falloff: float = _lane_assist_gutter_falloff(abs_x_ball)
    var target_assist_force: float = float(player_stats.get("target_assist_force", 0.0))
    if target_assist_force > 0.0:
        var desired_x: float = clampf(current_target_x, -_get_active_target_x_limit(), _get_active_target_x_limit())
        var x_delta: float = desired_x - active_ball.position.x
        active_ball.apply_central_force(Vector3(x_delta * target_assist_force * active_ball.mass * gutter_falloff, 0.0, 0.0))

    var gutter_return_force: float = float(player_stats.get("gutter_return_force", 0.0))
    if gutter_return_force <= 0.0:
        return
    var gutter_edge: float = runtime_lane_width * 0.5
    if abs_x_ball <= gutter_edge:
        return
    var inward_direction: float = -signf(active_ball.position.x)
    var inward_force: float = (
        gutter_return_force
        * gutter_falloff
        * float(player_stats.get("tier_gutter_penalty_mult", 1.0))
        * active_ball.mass
    )
    active_ball.apply_central_force(Vector3(inward_direction * inward_force, 0.0, 0.0))

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

func _should_finish_shot_early() -> bool:
    if active_ball == null or not is_instance_valid(active_ball):
        return true
    if not _are_pins_ready_for_fast_finish():
        return false
    var ball_position: Vector3 = active_ball.position
    var ball_linear_speed: float = active_ball.linear_velocity.length()
    var ball_forward_speed: float = max(0.0, active_ball.linear_velocity.z)
    var ball_cleared_pin_deck: bool = ball_position.z >= shot_clearance_z
    var ball_hit_pit_back: bool = ball_position.z >= PIT_BACK_WALL_Z - 0.12
    var ball_past_lane_surface: bool = ball_position.z >= lane_surface_back_z - 0.03
    var ball_dropped_toward_pit: bool = ball_past_lane_surface and ball_position.y < LANE_SURFACE_Y + BALL_RADIUS * 0.45
    var ball_settled_in_pit: bool = (ball_dropped_toward_pit or ball_position.y < -0.18) and ball_linear_speed <= FAST_FINISH_BALL_TOTAL_SPEED * 1.4
    var ball_is_in_gutter: bool = absf(ball_position.x) >= gutter_finish_x and ball_forward_speed <= FAST_FINISH_BALL_FORWARD_SPEED
    var ball_has_slowed_after_deck: bool = ball_cleared_pin_deck and ball_linear_speed <= FAST_FINISH_BALL_TOTAL_SPEED
    return ball_hit_pit_back or ball_settled_in_pit or ball_is_in_gutter or ball_has_slowed_after_deck

func _are_pins_ready_for_fast_finish() -> bool:
    for pin in active_pins:
        if not is_instance_valid(pin):
            continue
        if pin.linear_velocity.length() > FAST_FINISH_PIN_LINEAR_SPEED:
            return false
        if pin.angular_velocity.length() > FAST_FINISH_PIN_ANGULAR_SPEED:
            return false
    return true

func _finish_throw() -> void:
    var standing_after: int = _count_standing_pins()
    var gold_standing_after: int = _count_standing_gold_pins()
    series_gold_pins_knocked += maxi(0, standing_gold_before_throw - gold_standing_after)
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
    _update_lane_tier_control_state()

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
    return pin.position.y > 0.06 and pin.global_transform.basis.y.dot(Vector3.UP) >= current_pin_standing_dot

func _get_frame_target(_frame_index: int) -> int:
    return current_series_pin_target

func _is_strike_roll(frame_index: int, pins: int) -> bool:
    return pins >= _get_frame_target(frame_index)

func _is_spare_roll(frame_index: int, first_ball: int, second_ball: int) -> bool:
    var frame_target: int = _get_frame_target(frame_index)
    return first_ball < frame_target and first_ball + second_ball >= frame_target

func _should_reset_full_rack_before_next_throw(frame_index: int, throws: Array) -> bool:
    var frame_target: int = _get_frame_target(frame_index)
    if frame_index != FRAME_COUNT - 1:
        return false
    if throws.is_empty():
        return false
    if throws.size() == 1:
        return _is_strike_roll(frame_index, int(throws[0]))
    if _is_strike_roll(frame_index, int(throws[0])):
        return _is_strike_roll(frame_index, int(throws[1]))
    return int(throws[0]) + int(throws[1]) >= frame_target

func _is_frame_complete(frame_index: int) -> bool:
    var throws: Array = frame_records[frame_index].get("throws", [])
    var frame_target: int = _get_frame_target(frame_index)
    if frame_index < FRAME_COUNT - 1:
        return (throws.size() >= 1 and _is_strike_roll(frame_index, int(throws[0]))) or throws.size() >= 2
    if throws.size() < 2:
        return false
    if _is_strike_roll(frame_index, int(throws[0])):
        return throws.size() >= 3
    if int(throws[0]) + int(throws[1]) >= frame_target:
        return throws.size() >= 3
    return true

func _complete_series(latest_message: String) -> void:
    run_state = RunState.ROUND_OVER
    aim_line.visible = false
    _update_power_bar()
    _update_scoreboard()

    var score_details: Dictionary = _calculate_score_details()
    var cumulative_scores: Array = score_details.get("cumulative", [])
    var final_score: int = _get_best_available_series_score(cumulative_scores)
    var pinfall_total: int = int(score_details.get("pinfall_total", 0))
    var strikes := 0
    var spares := 0
    var open_frames := 0
    var first_three_strikes := true

    for frame_index in range(FRAME_COUNT):
        var throws: Array = frame_records[frame_index].get("throws", [])
        var frame_target: int = _get_frame_target(frame_index)
        if throws.is_empty():
            first_three_strikes = false
            continue
        if frame_index < FRAME_COUNT - 1:
            if _is_strike_roll(frame_index, int(throws[0])):
                strikes += 1
            elif throws.size() >= 2 and int(throws[0]) + int(throws[1]) >= frame_target:
                spares += 1
                first_three_strikes = false
            elif throws.size() >= 2:
                open_frames += 1
                first_three_strikes = false
            else:
                first_three_strikes = false
        else:
            if _is_strike_roll(frame_index, int(throws[0])):
                strikes += 1
            elif throws.size() >= 2 and int(throws[0]) + int(throws[1]) >= frame_target:
                spares += 1
                first_three_strikes = false
            else:
                open_frames += 1
                first_three_strikes = false
        if not _is_strike_roll(frame_index, int(throws[0])):
            first_three_strikes = false

    var results := {
        "score": final_score,
        "strikes": strikes,
        "spares": spares,
        "open_frames": open_frames,
        "turkey_bonus": first_three_strikes,
        "pinfall_total": pinfall_total,
        "gold_pins_knocked": series_gold_pins_knocked,
        "lane_tier": int(player_stats.get("lane_tier", 0)),
        "lane_tier_label": str(player_stats.get("lane_tier_label", "Practice House")),
        "scorecard_text": _build_scorecard_text(true),
    }
    results["wallet_gain"] = TURKEY_DATA.calculate_meta_reward(results, progress_data)
    results["summary_text"] = _build_series_summary(final_score, int(results["wallet_gain"]), strikes, spares, open_frames, first_three_strikes, latest_message)

    progress_data = TURKEY_PROGRESS.apply_run_results(results)
    var post_cap: Dictionary = TURKEY_DATA.build_meta_stats(progress_data)
    var post_max: int = int(post_cap.get("max_selectable_lane_tier", 0))
    selected_lane_tier = clampi(int(progress_data.get("turkey_selected_lane_tier", selected_lane_tier)), 0, post_max)
    player_stats = TURKEY_DATA.build_meta_stats(progress_data, selected_lane_tier)
    _refresh_series_settings_from_stats()
    _update_wallet_label()
    frame_status_label.text = "Series complete."
    result_label.text = latest_message
    _refresh_lane_tier_option_items()

    end_title_label.text = "SERIES COMPLETE"
    end_scorecard_label.text = String(results.get("scorecard_text", ""))
    end_summary_label.text = String(results.get("summary_text", ""))
    end_panel.show()

func _build_series_summary(final_score: int, reward: int, strikes: int, spares: int, open_frames: int, turkey_bonus: bool, latest_message: String) -> String:
    var lines: Array[String] = []
    lines.append("Final score: %d" % final_score)
    lines.append("Reward: $%d" % reward)
    lines.append(
        "Tier: %s   |   Rack: %d pins   |   Gold down: %d ($%d each)"
        % [
            str(player_stats.get("lane_tier_label", "Practice House")),
            current_series_pin_target,
            series_gold_pins_knocked,
            int(player_stats.get("tier_gold_pin_value", 0.0)),
        ]
    )
    lines.append("Frames: %d strike, %d spare, %d open." % [strikes, spares, open_frames])
    lines.append(latest_message)
    if turkey_bonus:
        lines.append("Three straight opening strikes. Real turkey money.")
    elif final_score >= current_series_pin_target * 4:
        lines.append("That was a sharp little set. The upgrade lane should feel better next time.")
    else:
        lines.append("Starter gear did its job. Grab upgrades and the pocket will open up later.")
    return "\n".join(lines)

func _describe_throw_result(frame_index: int, throws: Array, knocked: int, standing_after: int) -> String:
    var frame_target: int = _get_frame_target(frame_index)
    if frame_index < FRAME_COUNT - 1:
        if throws.size() == 1:
            if _is_strike_roll(frame_index, knocked):
                return "Strike on frame %d. Cleared the %d-pin rack." % [frame_index + 1, frame_target]
            return "Frame %d ball 1: %d pins down, %d still standing." % [frame_index + 1, knocked, standing_after]
        if int(throws[0]) + int(throws[1]) >= frame_target:
            return "Spare in frame %d." % (frame_index + 1)
        return "Open frame %d: %d and %d for %d." % [frame_index + 1, int(throws[0]), int(throws[1]), int(throws[0]) + int(throws[1])]

    if throws.size() == 1:
        if _is_strike_roll(frame_index, knocked):
            return "Strike in the final frame. Two bonus balls coming."
        return "Final frame ball 1: %d pins down, %d left." % [knocked, standing_after]
    if throws.size() == 2:
        if _is_strike_roll(frame_index, int(throws[0])):
            if _is_strike_roll(frame_index, int(throws[1])):
                return "Double in the final frame. One bonus ball left."
            return "Final frame bonus ball 1: %d pins down, %d left." % [knocked, standing_after]
        if int(throws[0]) + int(throws[1]) >= frame_target:
            return "Final-frame spare. One fill ball left."
        return "Final frame closes open with %d total." % (int(throws[0]) + int(throws[1]))
    if _is_strike_roll(frame_index, int(throws[0])) and _is_strike_roll(frame_index, int(throws[1])) and _is_strike_roll(frame_index, int(throws[2])):
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
    var pinfall_total := 0
    for frame_index in range(FRAME_COUNT):
        var throws: Array = frame_records[frame_index].get("throws", [])
        var frame_score: Variant = null
        var roll_start: int = int(roll_start_indices[frame_index])
        var frame_target: int = _get_frame_target(frame_index)

        if frame_index == FRAME_COUNT - 1:
            if _is_frame_complete(frame_index):
                frame_score = 0
                for pins_variant in throws:
                    frame_score += int(pins_variant)
        elif throws.size() >= 1 and _is_strike_roll(frame_index, int(throws[0])):
            if flat_rolls.size() >= roll_start + 3:
                frame_score = frame_target + int(flat_rolls[roll_start + 1]) + int(flat_rolls[roll_start + 2])
        elif throws.size() >= 2 and int(throws[0]) + int(throws[1]) >= frame_target:
            if flat_rolls.size() >= roll_start + 3:
                frame_score = frame_target + int(flat_rolls[roll_start + 2])
        elif throws.size() >= 2:
            frame_score = int(throws[0]) + int(throws[1])

        for pins_variant in throws:
            pinfall_total += int(pins_variant)
        frame_scores.append(frame_score)
        if frame_score == null:
            cumulative_scores.append(null)
        else:
            running_total += int(frame_score)
            cumulative_scores.append(running_total)
    return {
        "frame_scores": frame_scores,
        "cumulative": cumulative_scores,
        "pinfall_total": pinfall_total,
    }

func _get_best_available_series_score(cumulative_scores: Array) -> int:
    for index in range(cumulative_scores.size() - 1, -1, -1):
        var score_variant: Variant = cumulative_scores[index]
        if score_variant != null:
            return int(score_variant)
    return 0

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
    if include_final_summary:
        lines.append("Total: %d" % _get_best_available_series_score(cumulative_scores))
    return "\n".join(lines)

func _frame_marks(frame_index: int, throws: Array) -> Array[String]:
    var marks: Array[String] = []
    var frame_target: int = _get_frame_target(frame_index)
    if throws.is_empty():
        return ["--"]

    if frame_index < FRAME_COUNT - 1:
        if _is_strike_roll(frame_index, int(throws[0])):
            return ["X"]
        marks.append(_roll_symbol(int(throws[0])))
        if throws.size() >= 2:
            if int(throws[0]) + int(throws[1]) >= frame_target:
                marks.append("/")
            else:
                marks.append(_roll_symbol(int(throws[1])))
        else:
            marks.append("-")
        return marks

    marks.append("X" if _is_strike_roll(frame_index, int(throws[0])) else _roll_symbol(int(throws[0])))
    if throws.size() >= 2:
        if _is_strike_roll(frame_index, int(throws[0])):
            marks.append("X" if _is_strike_roll(frame_index, int(throws[1])) else _roll_symbol(int(throws[1])))
        elif int(throws[0]) + int(throws[1]) >= frame_target:
            marks.append("/")
        else:
            marks.append(_roll_symbol(int(throws[1])))
    if throws.size() >= 3:
        if _is_strike_roll(frame_index, int(throws[0])):
            if int(throws[1]) < frame_target and int(throws[1]) + int(throws[2]) >= frame_target:
                marks.append("/")
            else:
                marks.append("X" if _is_strike_roll(frame_index, int(throws[2])) else _roll_symbol(int(throws[2])))
        elif int(throws[0]) + int(throws[1]) >= frame_target:
            marks.append("X" if _is_strike_roll(frame_index, int(throws[2])) else _roll_symbol(int(throws[2])))
        else:
            marks.append(_roll_symbol(int(throws[2])))
    return marks

func _roll_symbol(pins: int) -> String:
    if pins <= 0:
        return "-"
    if pins >= current_series_pin_target:
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
    wallet_label.text = "Wallet: $%d   Ball: %.1f lb   Tier: %s" % [wallet, weight_lb, str(player_stats.get("lane_tier_label", "Practice House"))]

func _update_power_bar() -> void:
    power_bar.value = current_power_norm * 100.0
    _update_power_bar_visuals()
    match run_state:
        RunState.READY:
            power_label.text = "Power Gauge: click once to begin."
        RunState.AIMING:
            power_label.text = "Power Gauge: %d%%" % int(round(power_bar.value))
        RunState.BALL_IN_PLAY:
            power_label.text = "Power Locked: %d%%" % int(round(power_bar.value))
        RunState.ROUND_OVER:
            power_label.text = "Power Gauge: series finished."

func _update_power_bar_visuals() -> void:
    if power_bar_fill_style == null:
        return
    var strength: float = clampf(current_power_norm, 0.0, 1.0)
    power_bar_fill_style.bg_color = POWER_BAR_LOW_COLOR.lerp(POWER_BAR_HIGH_COLOR, strength)

func _apply_crt_level() -> void:
    if crt_overlay_rect == null or crt_material == null:
        return
    if crt_level <= 0:
        crt_overlay_rect.visible = false
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

func _change_crt_level(delta: int) -> void:
    var new_level: int = clampi(crt_level + delta, 0, CRT_LEVEL_MAX)
    if new_level == crt_level:
        return
    crt_level = new_level
    _apply_crt_level()
    _update_editor_debug_ui()

func _handle_crt_hotkey_input(event: InputEvent) -> bool:
    if not (event is InputEventKey):
        return false
    var key_event := event as InputEventKey
    if not key_event.pressed or key_event.echo:
        return false
    if key_event.keycode == KEY_BRACKETLEFT:
        _change_crt_level(-1)
        get_viewport().set_input_as_handled()
        return true
    if key_event.keycode == KEY_BRACKETRIGHT:
        _change_crt_level(1)
        get_viewport().set_input_as_handled()
        return true
    return false

func _update_editor_debug_ui() -> void:
    if not _should_show_editor_debug_ui():
        return
    if editor_debug_label == null or not is_instance_valid(editor_debug_label):
        return
    var standing_pins: int = _count_standing_pins()
    var ball_summary := "none"
    if active_ball != null and is_instance_valid(active_ball):
        ball_summary = "x %.2f  z %.2f  v %.2f" % [active_ball.position.x, active_ball.position.z, active_ball.linear_velocity.length()]
    var lines: Array[String] = []
    lines.append("CRT %d/%d  |  %s  |  [ / ]" % [crt_level, CRT_LEVEL_MAX, "Off" if crt_level == 0 else "%d%%" % int(round(float(crt_level) / float(CRT_LEVEL_MAX) * 100.0))])
    lines.append("State: %s" % _get_run_state_name())
    lines.append("Tier: %s  |  Rack: %d pins  |  Gold rack: %s  |  Gold up: %s" % [str(player_stats.get("lane_tier_label", "Practice House")), current_series_pin_target, "yes" if current_rack_has_gold_pin else "no", "yes" if _any_gold_pin_standing() else "no"])
    lines.append("Start Slider: %+d  ->  %.2f m" % [int(round(selected_start_value)), _get_selected_start_x()])
    lines.append("Curve Slider: %+d  ->  %.2f" % [int(round(selected_spin_value)), _get_selected_spin_curve()])
    lines.append("Aim Target X: %.2f / %.2f  |  Power: %d%%" % [current_target_x, _get_active_target_x_limit(), int(round(current_power_norm * 100.0))])
    lines.append("Pins Standing: %d  |  Shot: %.2fs / %.2fs" % [standing_pins, shot_elapsed, shot_settled_elapsed])
    lines.append("Ball: %s" % ball_summary)
    editor_debug_label.text = "\n".join(lines)

func _get_run_state_name() -> String:
    match run_state:
        RunState.READY:
            return "READY"
        RunState.AIMING:
            return "AIMING"
        RunState.BALL_IN_PLAY:
            return "BALL_IN_PLAY"
        RunState.ROUND_OVER:
            return "ROUND_OVER"
    return "UNKNOWN"

func _advance_power_gauge(delta: float) -> void:
    var sweep_weight: float = pow(1.0 - current_power_norm, POWER_SWEEP_CURVE)
    var sweep_speed: float = lerpf(POWER_SWEEP_TOP_SPEED, POWER_SWEEP_BOTTOM_SPEED, sweep_weight)
    current_power_norm += power_direction * delta * sweep_speed * float(player_stats.get("power_meter_speed_mult", 1.0))
    if current_power_norm >= 1.0:
        current_power_norm = 1.0
        power_direction = -1.0
    elif current_power_norm <= 0.0:
        current_power_norm = 0.0
        power_direction = 1.0

func _update_target_from_mouse(mouse_x: float) -> void:
    var viewport_width: float = max(1.0, get_viewport().get_visible_rect().size.x)
    var normalized: float = clampf((mouse_x / viewport_width) * 2.0 - 1.0, -1.0, 1.0)
    current_target_x = -normalized * _get_active_target_x_limit()

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
    return -clampf(selected_start_value / 100.0, -1.0, 1.0) * _get_active_start_x_limit()

func _get_selected_spin_curve() -> float:
    return -clampf(selected_spin_value / 100.0, -1.0, 1.0)

func _get_launch_target_x() -> float:
    var release_error: float = float(player_stats.get("aim_error_m", 0.18))
    release_error *= 1.0 + absf(_get_selected_spin_curve()) * 0.18
    var target_limit: float = _get_active_target_x_limit()
    return clampf(current_target_x + rng.randf_range(-release_error, release_error), -target_limit, target_limit)

func _get_active_start_x_limit() -> float:
    return START_X_LIMIT * float(player_stats.get("target_range_mult", 1.0)) * (runtime_lane_width / BASE_LANE_WIDTH)

func _get_active_target_x_limit() -> float:
    return TARGET_X_LIMIT * float(player_stats.get("target_range_mult", 1.0)) * (runtime_lane_width / BASE_LANE_WIDTH)

func _refresh_option_controls() -> void:
    if start_slider != null:
        start_slider.set_value_no_signal(selected_start_value)
    if spin_slider != null:
        spin_slider.set_value_no_signal(selected_spin_value)
    _update_option_value_labels()
    _update_option_visuals()

func _update_option_value_labels() -> void:
    if start_value_label != null:
        start_value_label.text = "%+d" % int(round(selected_start_value))
    if spin_value_label != null:
        spin_value_label.text = "%+d" % int(round(selected_spin_value))

func _update_option_visuals() -> void:
    _apply_option_visuals(start_slider, start_value_label, selected_start_value, START_LEFT_COLOR, START_RIGHT_COLOR)
    _apply_option_visuals(spin_slider, spin_value_label, selected_spin_value, SPIN_LEFT_COLOR, SPIN_RIGHT_COLOR)

func _apply_option_visuals(slider: HSlider, value_label: Label, value: float, left_color: Color, right_color: Color) -> void:
    var tint_color: Color = _get_option_tint_color(value, left_color, right_color)
    if slider != null:
        slider.self_modulate = tint_color
    if value_label != null:
        value_label.add_theme_color_override("font_color", tint_color)

func _get_option_tint_color(value: float, left_color: Color, right_color: Color) -> Color:
    if absf(value) < 0.001:
        return OPTION_NEUTRAL_COLOR
    var edge_color: Color = left_color if value < 0.0 else right_color
    var strength: float = pow(clampf(absf(value) / 100.0, 0.0, 1.0), 0.78)
    return OPTION_NEUTRAL_COLOR.lerp(edge_color, strength)

func _on_start_slider_changed(value: float) -> void:
    selected_start_value = round(value)
    _update_option_value_labels()
    _update_option_visuals()
    if run_state == RunState.READY:
        current_target_x = _get_selected_start_x()
    if run_state == RunState.AIMING:
        _update_aim_line()

func _on_spin_slider_changed(value: float) -> void:
    selected_spin_value = round(value)
    _update_option_value_labels()
    _update_option_visuals()

func _on_play_again_pressed() -> void:
    _load_progression()
    _begin_series()

func _on_upgrade_button_pressed() -> void:
    _end_run_to_upgrades()

func _end_run_to_upgrades() -> void:
    SceneChanger.change_to_new_scene(Util.get_upgrade_scene_path(), null, 0.2)

func _on_menu_button_pressed() -> void:
    SceneChanger.change_to_new_scene(Util.PATH_APP_BOOTSTRAP, null, 0.2)

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
    return not end_panel.visible

func _is_pause_menu_open() -> bool:
    return pause_menu != null and pause_menu.is_open()

func _open_pause_menu() -> void:
    if pause_menu == null:
        return
    pause_menu.open_menu()

func _close_pause_menu() -> void:
    if pause_menu == null:
        return
    pause_menu.close_menu()

func _on_pause_resume_requested() -> void:
    _close_pause_menu()

func _on_pause_end_run_requested() -> void:
    _close_pause_menu()
    _end_run_to_summary()

func _end_run_to_summary() -> void:
    if end_panel.visible:
        return
    _clear_dynamic_objects()
    _complete_series("Series ended early.")
