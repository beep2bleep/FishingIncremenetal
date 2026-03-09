extends Node2D

const HERO_SCENE: PackedScene = preload("res://Fishing/CombatSprite.tscn")
const COIN_SCENE: PackedScene = preload("res://Fishing/CoinPickup.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://Settings.tscn")

const HERO_FRAME_SIZE := Vector2i(24, 24)
const ENEMY_FRAME_SIZE := Vector2i(24, 24)
const BOSS_FRAME_SIZE := Vector2i(32, 32)

const LEVEL_ENEMY_TYPE := {
    1: "goblin",
    2: "brute",
    3: "flyer",
}

const FLOOR_Y := 640.0
const HERO_START_X := -40.0
const HERO_SCROLL_ANCHOR_SCREEN_X_FACTOR := 0.2
const CONTACT_RANGE := 48.0
const SIM_STEP := 1.0 / 60.0
const EXTRA_ZOOM_IN_FACTOR := 5.0
const HERO_FORMATION_SPACING := 64.5
const ENEMY_FORMATION_SPACING := 84.0
const MAX_STACKED_CONTACT_ATTACKERS := 4
const ENEMY_OPENING_RUSH_MULT := 5.0
const ENEMY_OFFSCREEN_SPEEDUP_MAX_MULT := 10.0
const BOSS_SEGMENTS := 8
const COIN_DESPAWN_MARGIN_X := 240.0
const COIN_DESPAWN_MARGIN_Y := 220.0
const HERO_COIN_PICKUP_DELAY := 0.12
const COIN_LAUNCH_MAX_HEIGHT_SCREENS := 2.0
const COIN_LAUNCH_MIN_SPEED_RATIO := 0.16
const COIN_LAUNCH_AWAY_MAX_DEG := 65.0
const COIN_LAUNCH_TOWARD_MAX_DEG := 3.0
const COIN_LAUNCH_TOWARD_CHANCE := 0.06
const ENEMY_COIN_VALUE_MULT := 3.0
const SPLIT_REWARD_MIN_COINS := 2
const SPLIT_REWARD_MAX_COINS := 6
const COIN_COLLISION_RESTITUTION := 0.7
const INFINITE_SIM_CURSOR_COLLECT_SHARE := 0.90
const UFO_SPAWN_MIN_SECONDS := 90.0
const UFO_SPAWN_MAX_SECONDS := 180.0
const UFO_TRAVEL_SECONDS := 10.0
const UFO_REWARD_ENEMY_MULT := 4
const UFO_REWARD_MIN_ENEMY_WORTH := 3
const UFO_REWARD_MAX_ENEMY_WORTH := 6
const UFO_COIN_PATH_OFFSET := 32.0
const UFO_SPAWN_MARGIN_X := 220.0
const UFO_CLOUD_OFFSET_MIN := 28.0
const UFO_CLOUD_OFFSET_MAX := 92.0
const DEFEAT_FALL_DURATION := 1.2
const DEFEAT_FALL_ROT_SPEED := 1.8
const ARROW_KILL_GRAVITY_SCALE := 1.0 / 3.0
const BG_BASE_SKY_Y := 220.0
const BG_BASE_GROUND_Y := 1240.0
const BG_DEEP_BASE_Y := -16.0
const CLOUD_FAR_BASE_Y := 52.0
const CLOUD_MID_BASE_Y := 40.0
const CLOUD_NEAR_BASE_Y := 30.0
const BG_FAR_BASE_Y := 581.0
const BG_MID_BASE_Y := 612.0
const BG_NEAR_BASE_Y := 637.0
const GROUND_BASE_Y := 752.0
const GROUND_OVERLAY_BASE_Y := 740.0
const BG_DEBUG_STEP := 8.0
const MOUSE_LAYOUT_PROFILE := {
    "bg_base_sky": 220.0,
    "bg_base_ground": 1240.0,
    "bg_deep": -16.0,
    "cloud_far": 52.0,
    "bg_far": 581.0,
    "cloud_mid": 40.0,
    "bg_mid": 612.0,
    "cloud_near": 30.0,
    "bg_near": 637.0,
    "ground": 752.0,
    "ground_overlay": 740.0,
    "coin_landing_y": 676.0,
}
const TOUCH_LAYOUT_PROFILE := {
    "bg_base_sky": 220.0,
    "bg_base_ground": 1240.0,
    "bg_deep": -16.0,
    "cloud_far": 324.0,
    "bg_far": 581.0,
    "cloud_mid": 320.0,
    "bg_mid": 612.0,
    "cloud_near": 310.0,
    "bg_near": 637.0,
    "ground": 752.0,
    "ground_overlay": 740.0,
    "coin_landing_y": 676.0,
}
const LEVEL_3_LAYOUT_OVERRIDE := {
    "bg_base_sky": 220.0,
    "bg_base_ground": 1240.0,
    "bg_deep": -16.0,
    "bg_far": 541.0,
    "bg_mid": 572.0,
    "bg_near": 581.0,
    "ground": 696.0,
    "ground_overlay": 740.0,
    "coin_landing_y": 676.0,
}
const BASE_POWER_REGEN_PER_SEC := 7.0
const ACTIVE_CHARGE_PER_CLICK := 20.0
const UPGRADE_EFFECT_TUNE := {
    "damage": 0.3,
    "speed": 0.3,
    "walk": 0.38,
    "armor": 0.4,
    "coin": 0.42,
    "power_gain": 0.46,
    "power_cap": 0.5,
    "active_cost": 0.42,
    "active_cd": 0.42,
    "enemy_count": 0.3,
}
const PLATFORMING_PACK_SPRITES := "res://PlatformingPack/Sprites"
const PLATFORMING_BG_DEFAULT := PLATFORMING_PACK_SPRITES + "/Backgrounds/Default"
const PLATFORMING_TILES_DEFAULT := PLATFORMING_PACK_SPRITES + "/Tiles/Default"
const PLATFORMING_ENEMY_DOUBLE_DIR := PLATFORMING_PACK_SPRITES + "/Enemies/Double"
const PACK_BG_TEXTURES := {
    "background_solid_sky.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_solid_sky.png"),
    "background_fade_hills.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_fade_hills.png"),
    "background_color_hills.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_color_hills.png"),
    "background_solid_sand.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_solid_sand.png"),
    "background_fade_desert.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_fade_desert.png"),
    "background_color_desert.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_color_desert.png"),
    "background_solid_cloud.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_solid_cloud.png"),
    "background_fade_mushrooms.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_fade_mushrooms.png"),
    "background_color_mushrooms.png": preload("res://PlatformingPack/Sprites/Backgrounds/Default/background_color_mushrooms.png"),
}
const PACK_TILE_TEXTURES := {
    "hill_top.png": preload("res://PlatformingPack/Sprites/Tiles/Default/hill_top.png"),
    "bush.png": preload("res://PlatformingPack/Sprites/Tiles/Default/bush.png"),
    "grass.png": preload("res://PlatformingPack/Sprites/Tiles/Default/grass.png"),
    "cactus.png": preload("res://PlatformingPack/Sprites/Tiles/Default/cactus.png"),
    "rock.png": preload("res://PlatformingPack/Sprites/Tiles/Default/rock.png"),
    "hill.png": preload("res://PlatformingPack/Sprites/Tiles/Default/hill.png"),
    "mushroom_red.png": preload("res://PlatformingPack/Sprites/Tiles/Default/mushroom_red.png"),
    "mushroom_brown.png": preload("res://PlatformingPack/Sprites/Tiles/Default/mushroom_brown.png"),
    "hill_top_smile.png": preload("res://PlatformingPack/Sprites/Tiles/Default/hill_top_smile.png"),
    "terrain_grass_horizontal_middle.png": preload("res://PlatformingPack/Sprites/Tiles/Default/terrain_grass_horizontal_middle.png"),
    "terrain_sand_horizontal_middle.png": preload("res://PlatformingPack/Sprites/Tiles/Default/terrain_sand_horizontal_middle.png"),
    "terrain_purple_horizontal_middle.png": preload("res://PlatformingPack/Sprites/Tiles/Default/terrain_purple_horizontal_middle.png"),
    "terrain_dirt_block_center.png": preload("res://PlatformingPack/Sprites/Tiles/Default/terrain_dirt_block_center.png"),
    "terrain_sand_block_center.png": preload("res://PlatformingPack/Sprites/Tiles/Default/terrain_sand_block_center.png"),
    "terrain_purple_block_center.png": preload("res://PlatformingPack/Sprites/Tiles/Default/terrain_purple_block_center.png"),
    "grass_purple.png": preload("res://PlatformingPack/Sprites/Tiles/Default/grass_purple.png"),
}
const PACK_ENEMY_WEB_VARIANTS := [
    {
        "key": "double_bee",
        "walk_a": preload("res://PlatformingPack/Sprites/Enemies/Double/bee_a.png"),
        "walk_b": preload("res://PlatformingPack/Sprites/Enemies/Double/bee_b.png"),
        "rest": preload("res://PlatformingPack/Sprites/Enemies/Double/bee_rest.png"),
        "speed": 68.0,
        "coins": 14,
    },
    {
        "key": "double_fly",
        "walk_a": preload("res://PlatformingPack/Sprites/Enemies/Double/fly_a.png"),
        "walk_b": preload("res://PlatformingPack/Sprites/Enemies/Double/fly_b.png"),
        "rest": preload("res://PlatformingPack/Sprites/Enemies/Double/fly_rest.png"),
        "speed": 68.0,
        "coins": 14,
    },
    {
        "key": "double_mouse",
        "walk_a": preload("res://PlatformingPack/Sprites/Enemies/Double/mouse_walk_a.png"),
        "walk_b": preload("res://PlatformingPack/Sprites/Enemies/Double/mouse_walk_b.png"),
        "rest": preload("res://PlatformingPack/Sprites/Enemies/Double/mouse_rest.png"),
        "speed": 55.0,
        "coins": 12,
    },
]
const ENEMY_POOL_PER_LEVEL := 4
const ENEMY_DOUBLE_EXCLUDED_PREFIXES: Array[String] = [
    "fish_purple",
    "frog_",
    "frog",
    "block_",
    "block",
    "barnacle",
    "slime_",
]
const HERO_RENDER_SCALE := 4.0
const ELITE_ENEMY_CHANCE := 0.05
const ELITE_ENEMY_MULT := 2.0
const MULTI_SPAWN_DOUBLE_CHANCE := 0.05
const MULTI_SPAWN_TRIPLE_CHANCE := 0.05
const MULTI_SPAWN_STACK_OFFSET_X := 14.0
const STACKED_ENEMY_SPACING_MULT := 0.42
const COIN_FLOAT_TEXT_COLOR := Color(1.0, 0.843137, 0.14902, 1.0)
const FLOATING_DAMAGE_NUMBER_SETTINGS := {
    "ttl": 1.0,
    "speed_min": 30.0,
    "speed_max": 50.0,
}
const FLOATING_CURRENCY_NUMBER_SETTINGS := {
    "ttl": 1.0,
    "speed_min": 24.0,
    "speed_max": 42.0,
}

# helper to play sound effects safely; autoload AudioManager isn't considered an
# engine singleton so Engine.has_singleton() returns false.  Simply check the
# global variable instead.
func _play_sfx(type: SoundEffectSettings.SOUND_EFFECT_TYPE) -> void:
    if AudioManager != null:
        AudioManager.create_audio(type)

const ENEMY_RENDER_SCALE := 0.4
const BOSS_RENDER_SCALE := 2.9
const ENEMY_TARGET_WORLD_WIDTH := 52.0
const BOSS_TARGET_WORLD_WIDTH := 140.0
const LEVEL_BG_PACK := {
    1: {
        "sky": "background_solid_sky.png",
        "far": "background_fade_hills.png",
        "mid": "background_color_hills.png",
        "near_deco": ["hill_top.png", "bush.png", "grass.png"],
        "ground_top": "terrain_grass_horizontal_middle.png",
        "ground_fill": "terrain_dirt_block_center.png",
        "ground_deco": ["grass.png", "bush.png"],
    },
    2: {
        "sky": "background_solid_sand.png",
        "far": "background_fade_desert.png",
        "mid": "background_color_desert.png",
        "near_deco": ["cactus.png", "rock.png", "hill.png"],
        "ground_top": "terrain_sand_horizontal_middle.png",
        "ground_fill": "terrain_sand_block_center.png",
        "ground_deco": ["cactus.png", "rock.png"],
    },
    3: {
        "sky": "background_solid_cloud.png",
        "far": "background_fade_mushrooms.png",
        "mid": "background_color_mushrooms.png",
        "near_deco": ["mushroom_red.png", "mushroom_brown.png", "hill_top_smile.png"],
        "ground_top": "terrain_purple_horizontal_middle.png",
        "ground_fill": "terrain_purple_block_center.png",
        "ground_deco": ["mushroom_red.png", "mushroom_brown.png", "grass_purple.png"],
    },
}
const LEVEL_BG_THEMES := {
    1: {
        "sky_base": Color(0.08, 0.08, 0.2, 1.0),
        "sky_star_a": Color(0.92, 0.92, 0.92, 1.0),
        "sky_star_b": Color(0.4, 0.4, 0.72, 1.0),
        "far": Color(0.15, 0.18, 0.37, 1.0),
        "mid": Color(0.2, 0.31, 0.53, 1.0),
        "near": Color(0.28, 0.45, 0.64, 1.0),
        "ground_a": Color(0.55, 0.38, 0.16, 1.0),
        "ground_b": Color(0.43, 0.26, 0.12, 1.0),
        "ground_accent": Color(0.92, 0.92, 0.92, 1.0),
    },
    2: {
        "sky_base": Color(0.06, 0.1, 0.14, 1.0),
        "sky_star_a": Color(0.88, 0.96, 0.9, 1.0),
        "sky_star_b": Color(0.3, 0.62, 0.54, 1.0),
        "far": Color(0.1, 0.26, 0.21, 1.0),
        "mid": Color(0.17, 0.41, 0.32, 1.0),
        "near": Color(0.24, 0.56, 0.43, 1.0),
        "ground_a": Color(0.34, 0.3, 0.18, 1.0),
        "ground_b": Color(0.24, 0.2, 0.11, 1.0),
        "ground_accent": Color(0.85, 0.93, 0.78, 1.0),
    },
    3: {
        "sky_base": Color(0.14, 0.05, 0.13, 1.0),
        "sky_star_a": Color(0.96, 0.84, 0.94, 1.0),
        "sky_star_b": Color(0.73, 0.35, 0.67, 1.0),
        "far": Color(0.29, 0.1, 0.3, 1.0),
        "mid": Color(0.43, 0.16, 0.45, 1.0),
        "near": Color(0.58, 0.23, 0.6, 1.0),
        "ground_a": Color(0.45, 0.24, 0.26, 1.0),
        "ground_b": Color(0.31, 0.14, 0.17, 1.0),
        "ground_accent": Color(0.95, 0.82, 0.88, 1.0),
    },
}

var world: Node2D
var bg_base_sky: Sprite2D
var bg_base_ground: Sprite2D
var bg_deep: Sprite2D
var cloud_far: Sprite2D
var cloud_mid: Sprite2D
var cloud_near: Sprite2D
var bg_far: Sprite2D
var bg_mid: Sprite2D
var bg_near: Sprite2D
var ground: Sprite2D
var ground_overlay: Sprite2D
var hero_layer: Node2D
var projectile_layer: Node2D
var enemy_layer: Node2D
var coin_layer: Node2D
var damage_text_layer: Node2D
var camera_2d: Camera2D

var health_label: Label
var health_bar: ProgressBar
var experience_bar: ProgressBar
var power_bar: ProgressBar
var health_value_label: Label
var experience_value_label: Label
var power_value_label: Label
var currency_label: Label
var clock_panel: PanelContainer
var clock_label: Label
var summary_panel: Panel
var summary_label: Label
var continue_button: Button
var speed_button: Button
var infinite_sim_button: Button
var exit_battle_button: Button
var spawn_ufo_button: Button
var mute_button: Button
var settings_button: Button
var settings_panel: PanelContainer
var settings_content: Settings
var fullscreen_button: Button
var touch_input_button: Button
var level_choice_dialog: ConfirmationDialog
var level_choice_selected_level: int = 1
var level_choice_line_edit: LineEdit
var bg_debug_panel: PanelContainer
var touch_zone_debug_label: Label

var heroes: Array[CombatSprite] = []
var hero_data: Dictionary = {}
var enemies: Array[CombatSprite] = []
var enemy_data: Dictionary = {}
var coins: Array[CoinPickup] = []
var coin_ages: Dictionary = {}
var arrows: Array[Dictionary] = []

var player_health: float = 300.0
var power: float = 0.0
var shield_time: float = 0.0

var enemies_killed: int = 0
var coins_gained: int = 0
var in_infinite_simulation: bool = false
var boss_segments_broken: int = 0

var current_level: int = 1
var regular_spawned: int = 0
var regular_killed: int = 0
var boss_spawned: bool = false
var boss_alive: bool = false
var spawn_timer: float = 0.0
var spawn_group_remaining: int = 0
var spawn_group_size: int = 0
var spawn_group_spawned: int = 0
var spawn_group_anchor_x: float = 0.0
var spawn_group_spacing: float = 84.0
var next_enemy_stack_id: int = 1
var sim_accumulator: float = 0.0
var battle_completed: bool = false
var battle_victory: bool = false
var enemy_opening_rush_active: bool = true

const SPEED_STEPS: Array[float] = [1.0, 2.0, 4.0, 8.0, 16.0]
const SPEED_UNLOCK_KEY := "battle_speed_unlock"
const MAX_RELEASE_SPEED_LEVEL := 3
const ACTIVE_COOLDOWNS := {
    "knight": 13.0,
    "archer": 15.0,
    "guardian": 17.0,
    "mage": 19.0,
}
const ACTIVE_DURATIONS := {
    "knight": 2.4,
    "archer": 2.2,
    "guardian": 3.0,
    "mage": 2.6,
}
const MAGE_BASE_SPEED := 1.2
const MAGE_BASE_ATTACK_INTERVAL := 4.0
const MAGE_IDLE_STRIKE_WINDUP := 1.0
const MAGE_IDLE_STRIKE_MULT := 4.0
const MAGE_ACTIVE_TICK_DAMAGE_MULT := 0.5
const MAGE_ACTIVE_SPEED_MULT := 4.0
const MAGE_HIT_FLASH_DURATION := 0.1
const MAGE_HIT_FLASH_BLEND := 0.7
const MAGE_LIGHTNING_DURATION := 0.1
const MAGE_MARK_TINT_START := 0.5
const MAGE_MARK_TINT_END := 1.0
const ARCHER_NO_TARGET_ADVANCE_MULT := 5.0
const HERO_CLICK_RADIUS := 56.0
const TOUCH_CAMERA_ZOOM_MULT := 2.5
const LEVEL_CHOICE_DIALOG_SIZE := Vector2(1200.0, 900.0)
const LEVEL_CHOICE_DIALOG_FONT_SIZE := 32
const LEVEL_CHOICE_DIALOG_TITLE_SIZE := 48
const LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT := 96.0
const LEVEL_CHOICE_SELECTOR_FONT_SIZE := 52
const LEVEL_CHOICE_SELECTOR_BUTTON_WIDTH := 140.0
const LEVEL_CHOICE_SELECTOR_INPUT_WIDTH := 220.0
var speed_index: int = 0
var arrow_texture: Texture2D
var hero_sheets: Dictionary = {}
var enemy_defs: Dictionary = {}
var level_enemy_pools: Dictionary = {}
var using_pack_background_assets: bool = false
var active_cooldowns: Dictionary = {}
var battle_mods: Dictionary = {}
var last_sim_steps: int = 0
var last_sim_seconds: float = 0.0
var displayed_bg_level: int = -1
var floating_damage_texts: Array[Dictionary] = []
var hero_damage_accum: float = 0.0
var hero_damage_timer: float = 0.0
var hero_damage_pos: Vector2 = Vector2.ZERO
var suppress_floating_text: bool = false
var hero_glow_timers: Dictionary = {}
var post_battle_sweep_time: float = 0.0
var summary_finalized: bool = false
var defeat_anim_time: float = 0.0
var pack_texture_cache: Dictionary = {}
var coin_landing_y: float = 676.0
var run_clock_save_accum: float = 0.0
var speaker_icon_on: Texture2D
var speaker_icon_off: Texture2D
var fullscreen_icon_on: Texture2D
var fullscreen_icon_off: Texture2D
var active_ufo: UfoBonus = null
var ufo_spawn_timer: float = 0.0
var summary_panel_base_layout: Rect2 = Rect2()
var summary_label_base_layout: Rect2 = Rect2()
var continue_button_base_layout: Rect2 = Rect2()
var touch_camera_left_shift: float = 500.0
var base_fill_texture: Texture2D
var mage_pending_strikes: Array[Dictionary] = []
var enemy_mark_timers: Dictionary = {}
var guardian_glow_was_active: bool = false
var battle_scene_unadjusted_seconds: float = 0.0

func _should_show_editor_only_touch_toggle() -> bool:
    return OS.has_feature("editor")

func _ready() -> void:
    if not _bind_nodes():
        push_error("BattleScene is missing required nodes.")
        return

    SignalBus.settings_updated.connect(_on_settings_updated)
    _setup_actor_sheets()
    current_level = clamp(SaveHandler.fishing_next_battle_level, 1, _max_unlocked_level())
    _rebuild_battle_mods()
    _setup_visuals()
    _apply_background_layout_for_input_mode("Loaded %s layout" % ("touch" if SaveHandler.touch_input_mode else "mouse"))
    _spawn_heroes()
    _style_clock_ui()
    _style_battle_summary_ui()
    _cache_battle_summary_layout()
    _setup_mute_button()
    _setup_settings_controls()
    _setup_fullscreen_button()
    _setup_touch_input_button()
    _layout_battle_utility_buttons()
    _setup_background_debug_controls()
    summary_panel.hide()
    _setup_speed_controls()
    _restore_or_reset_ufo_spawn_timer()
    _update_speed_button_enabled_state()
    _refresh_fullscreen_button_icon()
    _refresh_touch_input_button()
    _update_ui()

func _layout_battle_utility_buttons() -> void:
    var viewport_width: float = get_viewport_rect().size.x
    var fullscreen_shift_x: float = viewport_width * 0.1
    if fullscreen_button != null:
        fullscreen_button.offset_left = 24.0 + fullscreen_shift_x
        fullscreen_button.offset_top = 20.0
        fullscreen_button.offset_right = 112.0 + fullscreen_shift_x
        fullscreen_button.offset_bottom = 108.0
    if exit_battle_button != null:
        exit_battle_button.offset_left = 960.0
        exit_battle_button.offset_top = 164.0
        exit_battle_button.offset_right = 1256.0
        exit_battle_button.offset_bottom = 228.0
    if bg_debug_panel != null:
        bg_debug_panel.offset_left = 960.0
        bg_debug_panel.offset_top = 244.0
        bg_debug_panel.offset_right = 1256.0
        bg_debug_panel.offset_bottom = 920.0

func _exit_tree() -> void:
    SaveHandler.save_fishing_progress()
    Engine.time_scale = 1.0

func _bind_nodes() -> bool:
    world = get_node_or_null("World")
    bg_base_sky = get_node_or_null("World/BGBaseSky")
    bg_base_ground = get_node_or_null("World/BGBaseGround")
    bg_deep = get_node_or_null("World/BGDeep")
    cloud_far = get_node_or_null("World/CloudFar")
    cloud_mid = get_node_or_null("World/CloudMid")
    cloud_near = get_node_or_null("World/CloudNear")
    bg_far = get_node_or_null("World/BGFar")
    bg_mid = get_node_or_null("World/BGMid")
    bg_near = get_node_or_null("World/BGNear")
    ground = get_node_or_null("World/Ground")
    ground_overlay = get_node_or_null("World/GroundOverlay")
    hero_layer = get_node_or_null("World/HeroLayer")
    projectile_layer = get_node_or_null("World/ProjectileLayer")
    enemy_layer = get_node_or_null("World/EnemyLayer")
    coin_layer = get_node_or_null("World/CoinLayer")
    damage_text_layer = get_node_or_null("World/DamageTextLayer")
    camera_2d = get_node_or_null("Camera2D")

    health_label = get_node_or_null("CanvasLayer/LevelLabel")
    health_bar = get_node_or_null("CanvasLayer/HealthBar")
    experience_bar = get_node_or_null("CanvasLayer/ExperienceBar")
    power_bar = get_node_or_null("CanvasLayer/PowerBar")
    health_value_label = get_node_or_null("CanvasLayer/HealthValueLabel")
    experience_value_label = get_node_or_null("CanvasLayer/ExperienceValueLabel")
    power_value_label = get_node_or_null("CanvasLayer/PowerValueLabel")
    currency_label = get_node_or_null("CanvasLayer/CurrencyLabel")
    clock_panel = get_node_or_null("CanvasLayer/ClockPanel")
    clock_label = get_node_or_null("CanvasLayer/ClockPanel/ClockLabel")
    speed_button = get_node_or_null("CanvasLayer/SpeedButton")
    infinite_sim_button = get_node_or_null("CanvasLayer/InfiniteSimButton")
    exit_battle_button = get_node_or_null("CanvasLayer/ExitBattleButton")
    spawn_ufo_button = get_node_or_null("CanvasLayer/SpawnUfoButton")
    mute_button = get_node_or_null("CanvasLayer/MuteButton")
    summary_panel = get_node_or_null("CanvasLayer/SummaryPanel")
    summary_label = get_node_or_null("CanvasLayer/SummaryPanel/SummaryLabel")
    continue_button = get_node_or_null("CanvasLayer/SummaryPanel/ContinueButton")
    level_choice_dialog = get_node_or_null("CanvasLayer/LevelChoiceDialog")
    var canvas_layer: CanvasLayer = get_node_or_null("CanvasLayer")

    if world != null:
        if bg_base_sky == null:
            bg_base_sky = Sprite2D.new()
            bg_base_sky.name = "BGBaseSky"
            world.add_child(bg_base_sky)
        if bg_base_ground == null:
            bg_base_ground = Sprite2D.new()
            bg_base_ground.name = "BGBaseGround"
            world.add_child(bg_base_ground)
        if bg_deep == null:
            bg_deep = Sprite2D.new()
            bg_deep.name = "BGDeep"
            world.add_child(bg_deep)
        if cloud_far == null:
            cloud_far = Sprite2D.new()
            cloud_far.name = "CloudFar"
            world.add_child(cloud_far)
        if cloud_mid == null:
            cloud_mid = Sprite2D.new()
            cloud_mid.name = "CloudMid"
            world.add_child(cloud_mid)
        if cloud_near == null:
            cloud_near = Sprite2D.new()
            cloud_near.name = "CloudNear"
            world.add_child(cloud_near)
        if bg_far == null:
            bg_far = Sprite2D.new()
            bg_far.name = "BGFar"
            world.add_child(bg_far)
        if bg_mid == null:
            bg_mid = Sprite2D.new()
            bg_mid.name = "BGMid"
            world.add_child(bg_mid)
        if bg_near == null:
            bg_near = Sprite2D.new()
            bg_near.name = "BGNear"
            world.add_child(bg_near)
        if ground == null:
            ground = Sprite2D.new()
            ground.name = "Ground"
            world.add_child(ground)
        if ground_overlay == null:
            ground_overlay = Sprite2D.new()
            ground_overlay.name = "GroundOverlay"
            world.add_child(ground_overlay)

        world.move_child(bg_base_sky, 0)
        world.move_child(bg_base_ground, 1)
        world.move_child(bg_deep, 2)
        world.move_child(cloud_far, 3)
        world.move_child(bg_far, 4)
        world.move_child(cloud_mid, 5)
        world.move_child(bg_mid, 6)
        world.move_child(cloud_near, 7)
        world.move_child(bg_near, 8)
        world.move_child(ground, 9)
        world.move_child(ground_overlay, 10)

        var old_bg_overlay: Node = world.get_node_or_null("BGOverlay")
        if old_bg_overlay != null:
            old_bg_overlay.queue_free()
        var old_play_overlay: Node = world.get_node_or_null("PlayAreaOverlay")
        if old_play_overlay != null:
            old_play_overlay.queue_free()

    if projectile_layer == null and world != null:
        projectile_layer = Node2D.new()
        projectile_layer.name = "ProjectileLayer"
        world.add_child(projectile_layer)
        world.move_child(projectile_layer, world.get_child_count() - 3)

    if damage_text_layer == null and world != null:
        damage_text_layer = Node2D.new()
        damage_text_layer.name = "DamageTextLayer"
        world.add_child(damage_text_layer)
        world.move_child(damage_text_layer, world.get_child_count() - 1)

    if level_choice_dialog == null and canvas_layer != null:
        level_choice_dialog = ConfirmationDialog.new()
        level_choice_dialog.name = "LevelChoiceDialog"
        level_choice_dialog.title = "Choose Battle Level"
        level_choice_dialog.dialog_text = "Choose your next battle level."
        level_choice_dialog.get_ok_button().hide()
        level_choice_dialog.get_cancel_button().hide()
        canvas_layer.add_child(level_choice_dialog)
    _style_level_choice_dialog(level_choice_dialog)
    if level_choice_dialog != null and not level_choice_dialog.custom_action.is_connected(_on_level_choice_action):
        level_choice_dialog.custom_action.connect(_on_level_choice_action)

    return world != null and bg_base_sky != null and bg_base_ground != null and bg_deep != null and cloud_far != null and cloud_mid != null and cloud_near != null and bg_far != null and bg_mid != null and bg_near != null and ground != null and ground_overlay != null and hero_layer != null and projectile_layer != null and enemy_layer != null and coin_layer != null and damage_text_layer != null and camera_2d != null and health_label != null and health_bar != null and experience_bar != null and power_bar != null and health_value_label != null and experience_value_label != null and power_value_label != null and currency_label != null and clock_panel != null and clock_label != null and speed_button != null and infinite_sim_button != null and exit_battle_button != null and mute_button != null and summary_panel != null and summary_label != null and continue_button != null and level_choice_dialog != null

func _clear_battle_entities() -> void:
    for arrow_data_variant in arrows:
        var arrow_data: Dictionary = arrow_data_variant
        var arrow_sprite: Sprite2D = arrow_data.get("sprite", null)
        if is_instance_valid(arrow_sprite):
            arrow_sprite.queue_free()
    arrows.clear()

    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.queue_free()
    enemies.clear()
    enemy_data.clear()

    for coin in coins:
        if is_instance_valid(coin):
            coin.queue_free()
    coins.clear()
    coin_ages.clear()
    if is_instance_valid(active_ufo):
        active_ufo.queue_free()
    active_ufo = null

    for item_variant in floating_damage_texts:
        var item: Dictionary = item_variant
        var damage_label: Label = item.get("label", null)
        if is_instance_valid(damage_label):
            damage_label.queue_free()
    floating_damage_texts.clear()
    hero_damage_accum = 0.0
    hero_damage_timer = 0.0
    enemy_opening_rush_active = true
    next_enemy_stack_id = 1
    mage_pending_strikes.clear()
    enemy_mark_timers.clear()
    guardian_glow_was_active = false
    if health_bar != null:
        health_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _reset_heroes_to_start() -> void:
    for i in range(heroes.size()):
        var hero: CombatSprite = heroes[i]
        if not is_instance_valid(hero):
            continue
        hero.position = Vector2(HERO_START_X + HERO_FRAME_SIZE.x * HERO_RENDER_SCALE - float(i) * HERO_FORMATION_SPACING, FLOOR_Y)
        hero.modulate = Color(1.0, 1.0, 1.0, 1.0)
        hero.set_walking()
        if hero_data.has(hero):
            var h: Dictionary = hero_data[hero]
            h["cooldown"] = 0.0
            h["active_charge"] = 0.0
            h["active_time_remaining"] = 0.0
            h["active_time_total"] = 0.0
            h["active_cooldown_total"] = 0.0
            h["mage_active_tick"] = _mage_attack_interval(h)
            h["mage_idle_mark_cd"] = _mage_attack_interval(h)
            hero_data[hero] = h

func _setup_speed_controls() -> void:
    if speed_button == null or infinite_sim_button == null:
        return
    _style_speed_controls()
    if not speed_button.gui_input.is_connected(_on_speed_button_gui_input):
        speed_button.gui_input.connect(_on_speed_button_gui_input)
    if OS.has_feature("editor"):
        speed_button.show()
        infinite_sim_button.show()
        if spawn_ufo_button != null:
            spawn_ufo_button.show()
        _apply_speed_index(SaveHandler.fishing_battle_speed_index, true)
        _update_speed_button_text()
        _update_speed_button_enabled_state()
    else:
        infinite_sim_button.hide()
        if spawn_ufo_button != null:
            spawn_ufo_button.hide()
        _apply_speed_index(SaveHandler.fishing_battle_speed_index, true)
        if _max_available_speed_index() > 0:
            speed_button.show()
            _update_speed_button_text()
        else:
            speed_button.hide()

func _setup_background_debug_controls() -> void:
    if not OS.has_feature("editor"):
        if bg_debug_panel != null:
            bg_debug_panel.hide()
        return

    var canvas_layer: CanvasLayer = get_node_or_null("CanvasLayer")
    if canvas_layer == null:
        return

    if bg_debug_panel == null:
        bg_debug_panel = PanelContainer.new()
        bg_debug_panel.name = "BackgroundDebugPanel"
        canvas_layer.add_child(bg_debug_panel)

        var root_margin := MarginContainer.new()
        root_margin.add_theme_constant_override("margin_left", 10)
        root_margin.add_theme_constant_override("margin_top", 10)
        root_margin.add_theme_constant_override("margin_right", 10)
        root_margin.add_theme_constant_override("margin_bottom", 10)
        bg_debug_panel.add_child(root_margin)

        var root_vbox := VBoxContainer.new()
        root_vbox.add_theme_constant_override("separation", 6)
        root_margin.add_child(root_vbox)

        var title := Label.new()
        title.text = "BG Y Debug"
        title.add_theme_font_size_override("font_size", 20)
        root_vbox.add_child(title)

        var step_label := Label.new()
        step_label.text = "Step %.0f px" % BG_DEBUG_STEP
        step_label.add_theme_font_size_override("font_size", 14)
        root_vbox.add_child(step_label)

        touch_zone_debug_label = Label.new()
        touch_zone_debug_label.text = "Touch Zone Enemies: 0"
        touch_zone_debug_label.add_theme_font_size_override("font_size", 14)
        root_vbox.add_child(touch_zone_debug_label)

        for target in _background_debug_targets():
            var row := HBoxContainer.new()
            row.add_theme_constant_override("separation", 6)
            root_vbox.add_child(row)

            var name_label := Label.new()
            name_label.text = str(target.get("label", "Layer"))
            name_label.custom_minimum_size = Vector2(136.0, 0.0)
            row.add_child(name_label)

            var up_button := Button.new()
            up_button.text = "Up"
            up_button.custom_minimum_size = Vector2(60.0, 36.0)
            up_button.pressed.connect(_on_background_debug_adjust_pressed.bind(str(target.get("key", "")), -BG_DEBUG_STEP))
            row.add_child(up_button)

            var down_button := Button.new()
            down_button.text = "Down"
            down_button.custom_minimum_size = Vector2(60.0, 36.0)
            down_button.pressed.connect(_on_background_debug_adjust_pressed.bind(str(target.get("key", "")), BG_DEBUG_STEP))
            row.add_child(down_button)

    bg_debug_panel.show()
    _layout_battle_utility_buttons()
    _log_background_layer_positions("Initial")

func _background_debug_targets() -> Array[Dictionary]:
    return [
        {"key": "bg_base_sky", "label": "Base Sky"},
        {"key": "bg_base_ground", "label": "Base Ground"},
        {"key": "bg_deep", "label": "BG Deep"},
        {"key": "cloud_far", "label": "Cloud Far"},
        {"key": "bg_far", "label": "BG Far"},
        {"key": "cloud_mid", "label": "Cloud Mid"},
        {"key": "bg_mid", "label": "BG Mid"},
        {"key": "cloud_near", "label": "Cloud Near"},
        {"key": "bg_near", "label": "BG Near"},
        {"key": "ground", "label": "Ground"},
        {"key": "ground_overlay", "label": "Ground Overlay"},
        {"key": "coin_landing_y", "label": "Coin Landing"},
    ]

func _background_node_for_key(key: String) -> Node2D:
    match key:
        "bg_base_sky":
            return bg_base_sky
        "bg_base_ground":
            return bg_base_ground
        "bg_deep":
            return bg_deep
        "cloud_far":
            return cloud_far
        "bg_far":
            return bg_far
        "cloud_mid":
            return cloud_mid
        "bg_mid":
            return bg_mid
        "cloud_near":
            return cloud_near
        "bg_near":
            return bg_near
        "ground":
            return ground
        "ground_overlay":
            return ground_overlay
        _:
            return null

func _on_background_debug_adjust_pressed(layer_key: String, delta_y: float) -> void:
    if layer_key == "coin_landing_y":
        coin_landing_y += delta_y
        _log_background_layer_positions("Moved %s by %.0f" % [layer_key, delta_y])
        return
    var target: Node2D = _background_node_for_key(layer_key)
    if target == null:
        push_warning("Missing background debug target: %s" % layer_key)
        return
    target.position.y += delta_y
    _log_background_layer_positions("Moved %s by %.0f" % [layer_key, delta_y])

func _log_background_layer_positions(reason: String = "") -> void:
    var lines: PackedStringArray = []
    if reason != "":
        lines.append("[Battle BG Debug] %s" % reason)
    for target in _background_debug_targets():
        var key: String = str(target.get("key", ""))
        var label: String = str(target.get("label", key))
        if key == "coin_landing_y":
            lines.append("%s: %.1f" % [label, coin_landing_y])
            continue
        var node: Node2D = _background_node_for_key(key)
        if node == null:
            lines.append("%s: <missing>" % label)
            continue
        lines.append("%s: %.1f" % [label, node.position.y])
    print("\n".join(lines))

func _update_speed_button_enabled_state() -> void:
    if speed_button == null or infinite_sim_button == null or exit_battle_button == null:
        return
    var disabled: bool = summary_panel != null and summary_panel.visible
    speed_button.disabled = disabled
    infinite_sim_button.disabled = disabled
    exit_battle_button.disabled = disabled
    if spawn_ufo_button != null:
        spawn_ufo_button.disabled = disabled or battle_completed

func _update_speed_button_text() -> void:
    if speed_button == null:
        return
    speed_button.text = "Speed x%d" % int(SPEED_STEPS[speed_index])

func _update_touch_camera_debug() -> void:
    queue_redraw()
    if touch_zone_debug_label == null:
        return
    var touch_area: Rect2 = _touch_camera_world_rect()
    var count: int = _enemy_count_in_touch_camera_area(touch_area)
    touch_zone_debug_label.text = "Touch Zone Enemies: %d" % count

func _on_speed_button_pressed() -> void:
    var max_index: int = _max_available_speed_index()
    if max_index <= 0:
        return
    var next_index: int = speed_index + 1
    if next_index > max_index:
        next_index = 0
    _apply_speed_index(next_index, true)

func _on_speed_button_gui_input(event: InputEvent) -> void:
    var mouse_event: InputEventMouseButton = event as InputEventMouseButton
    if mouse_event == null:
        return
    if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_RIGHT:
        return
    var max_index: int = _max_available_speed_index()
    if max_index <= 0:
        return
    _apply_speed_index(max(0, speed_index - 1), true)
    get_viewport().set_input_as_handled()

func _on_infinite_sim_button_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    _run_infinite_simulation()

func _on_spawn_ufo_button_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    if battle_completed or (summary_panel != null and summary_panel.visible):
        return
    _spawn_ufo(true)

func _on_exit_battle_button_pressed() -> void:
    if battle_completed or summary_finalized:
        return
    _end_battle(false)
    if not summary_finalized:
        _run_defeat_pose_instant()

func _run_infinite_simulation() -> void:
    if summary_panel.visible or battle_completed:
        return
    if speed_button != null and infinite_sim_button != null and exit_battle_button != null:
        speed_button.disabled = true
        infinite_sim_button.disabled = true
        exit_battle_button.disabled = true
        if spawn_ufo_button != null:
            spawn_ufo_button.disabled = true

    var was_world_visible: bool = world.visible
    world.visible = false
    Engine.time_scale = 1.0
    sim_accumulator = 0.0
    suppress_floating_text = true
    in_infinite_simulation = true
    active_cooldowns.clear()
    for key in ACTIVE_COOLDOWNS.keys():
        active_cooldowns[key] = 0.0

    var max_steps: int = 1_000_000
    var step_count: int = 0
    while player_health > 0.0 and not battle_completed and step_count < max_steps:
        _simulate_step(SIM_STEP, true)
        step_count += 1

    if not battle_completed and player_health <= 0.0 and not summary_panel.visible:
        _end_battle(false)
    if battle_completed and not summary_finalized:
        if battle_victory:
            _run_post_battle_sweep_instant()
        else:
            _run_defeat_pose_instant()

    last_sim_steps = step_count
    last_sim_seconds = float(step_count) * SIM_STEP
    if last_sim_seconds > 0.0:
        SaveHandler.save_fishing_progress()

    world.visible = was_world_visible
    suppress_floating_text = false
    in_infinite_simulation = false
    if speed_button != null and infinite_sim_button != null and exit_battle_button != null:
        speed_button.disabled = false
        infinite_sim_button.disabled = false
        exit_battle_button.disabled = false
        if spawn_ufo_button != null:
            spawn_ufo_button.disabled = false
    _apply_speed_index(SaveHandler.fishing_battle_speed_index, false)
    _update_ui()
    _update_speed_button_enabled_state()

func _update_active_cooldowns(delta: float) -> void:
    for key in active_cooldowns.keys():
        var prev_val: float = float(active_cooldowns[key])
        var new_val: float = max(0.0, prev_val - delta)
        active_cooldowns[key] = new_val
        # If a cooldown just finished, clear any stored player charge so
        # the player must click again to build charge (but keep sim auto-use).
        if prev_val > 0.0 and new_val <= 0.0 and not in_infinite_simulation:
            # find any hero with this name and reset their active charge
            for hero in heroes:
                if not is_instance_valid(hero):
                    continue
                var h: Dictionary = hero_data.get(hero, {})
                if str(h.get("name", "")) == str(key):
                    h["active_charge"] = 0.0
                    hero_data[hero] = h

func _auto_use_hero_actives() -> void:
    # Only auto-use abilities during infinite simulation (sim infinity).
    if not in_infinite_simulation:
        return

    if power < _active_cost():
        return

    for hero_name in ["guardian", "archer", "mage", "knight"]:
        if power < _active_cost():
            break
        if not _try_auto_cast_active(hero_name):
            continue

func _try_auto_cast_active(hero_name: String) -> bool:
    var cooldown_remaining: float = float(active_cooldowns.get(hero_name, 0.0))
    if cooldown_remaining > 0.0:
        return false

    var unlock_key: String = _active_unlock_key(hero_name)
    if unlock_key == "" or not SaveHandler.has_fishing_upgrade(unlock_key):
        return false

    var hero: CombatSprite = _get_hero_by_name(hero_name)
    if not is_instance_valid(hero):
        return false

    var active_cost: float = _active_cost()
    if power < active_cost:
        return false
    power -= active_cost
    _execute_hero_active(hero, hero_name, true)
    active_cooldowns[hero_name] = float(ACTIVE_COOLDOWNS.get(hero_name, 15.0)) * _active_cooldown_mult()
    return true

func _get_hero_by_name(hero_name: String) -> CombatSprite:
    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        var h: Dictionary = hero_data.get(hero, {})
        if str(h.get("name", "")) == hero_name:
            return hero
    return null

func _setup_visuals() -> void:
    _apply_touch_input_camera_zoom()
    camera_2d.position = Vector2(0, FLOOR_Y - 120.0)
    arrow_texture = _make_arrow_texture()
    base_fill_texture = _make_base_fill_texture()

    for sprite in [bg_base_sky, bg_base_ground, bg_deep, cloud_far, bg_far, cloud_mid, bg_mid, cloud_near, bg_near, ground, ground_overlay]:
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
        sprite.region_enabled = true
        sprite.centered = true

    bg_base_sky.texture = base_fill_texture
    bg_base_ground.texture = base_fill_texture
    bg_base_sky.region_rect = Rect2(0, 0, 80000, FLOOR_Y + 200.0)
    bg_base_ground.region_rect = Rect2(0, 0, 80000, 1200.0)
    bg_base_sky.position = Vector2(0.0, BG_BASE_SKY_Y)
    bg_base_ground.position = Vector2(0.0, BG_BASE_GROUND_Y)

    bg_deep.region_rect = Rect2(0, 0, 80000, 400)
    cloud_far.region_rect = Rect2(0, 0, 80000, 220)
    bg_far.region_rect = Rect2(0, 0, 80000, 440)
    cloud_mid.region_rect = Rect2(0, 0, 80000, 220)
    bg_mid.region_rect = Rect2(0, 0, 80000, 500)
    cloud_near.region_rect = Rect2(0, 0, 80000, 240)
    bg_near.region_rect = Rect2(0, 0, 80000, 560)
    ground.region_rect = Rect2(0, 0, 80000, 360)
    ground_overlay.region_rect = Rect2(0, 0, 80000, 220)

    _apply_level_background(current_level)
    _apply_parallax_depth_scales()

func _make_base_fill_texture() -> Texture2D:
    var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
    img.fill(Color(1.0, 1.0, 1.0, 1.0))
    return ImageTexture.create_from_image(img)

func _apply_parallax_depth_scales() -> void:
    # This scene is 2D. Depth is faked by shrinking farther layers and lifting them up.
    if using_pack_background_assets:
        bg_deep.scale = Vector2(0.18, 0.18)
        cloud_far.scale = Vector2(0.32, 0.32)
        bg_far.scale = Vector2(0.32, 0.32)
        cloud_mid.scale = Vector2(0.52, 0.52)
        bg_mid.scale = Vector2(0.52, 0.52)
        cloud_near.scale = Vector2(0.76, 0.76)
        bg_near.scale = Vector2(0.76, 0.76)
        ground.scale = Vector2(1.0, 1.0)
        ground_overlay.scale = Vector2(1.0, 1.0)
    else:
        # Fallback composition if pack textures are unavailable.
        bg_deep.scale = Vector2(1.35, 1.35)
        cloud_far.scale = Vector2(1.75, 1.75)
        bg_far.scale = Vector2(1.75, 1.75)
        cloud_mid.scale = Vector2(2.25, 2.25)
        bg_mid.scale = Vector2(2.25, 2.25)
        cloud_near.scale = Vector2(2.8, 2.8)
        bg_near.scale = Vector2(2.8, 2.8)
        ground.scale = Vector2(2.6, 1.8)
        ground_overlay.scale = Vector2(2.6, 1.8)

    _apply_background_layout_for_input_mode()

func _layout_profile_for_current_input_mode() -> Dictionary:
    var layout: Dictionary = (TOUCH_LAYOUT_PROFILE if SaveHandler.touch_input_mode else MOUSE_LAYOUT_PROFILE).duplicate(true)
    if current_level == 3:
        for key in LEVEL_3_LAYOUT_OVERRIDE.keys():
            layout[key] = LEVEL_3_LAYOUT_OVERRIDE[key]
    return layout

func _apply_background_layout_for_input_mode(log_reason: String = "") -> void:
    var layout: Dictionary = _layout_profile_for_current_input_mode()
    bg_base_sky.position.y = float(layout.get("bg_base_sky", BG_BASE_SKY_Y))
    bg_base_ground.position.y = float(layout.get("bg_base_ground", BG_BASE_GROUND_Y))
    bg_deep.position.y = float(layout.get("bg_deep", BG_DEEP_BASE_Y))
    cloud_far.position.y = float(layout.get("cloud_far", CLOUD_FAR_BASE_Y))
    bg_far.position.y = float(layout.get("bg_far", BG_FAR_BASE_Y))
    cloud_mid.position.y = float(layout.get("cloud_mid", CLOUD_MID_BASE_Y))
    bg_mid.position.y = float(layout.get("bg_mid", BG_MID_BASE_Y))
    cloud_near.position.y = float(layout.get("cloud_near", CLOUD_NEAR_BASE_Y))
    bg_near.position.y = float(layout.get("bg_near", BG_NEAR_BASE_Y))
    ground.position.y = float(layout.get("ground", GROUND_BASE_Y))
    ground_overlay.position.y = float(layout.get("ground_overlay", GROUND_OVERLAY_BASE_Y))
    coin_landing_y = float(layout.get("coin_landing_y", coin_landing_y))
    if log_reason != "":
        _log_background_layer_positions(log_reason)

func _apply_level_background(level_index: int) -> void:
    var level_key: int = max(1, level_index)
    if level_key == displayed_bg_level:
        return
    displayed_bg_level = level_key
    var t: Dictionary = _theme_for_level(level_key)
    var pack_theme: Dictionary = _pack_theme_for_level(level_key)
    if not pack_theme.is_empty():
        var sky_tex: Texture2D = _load_pack_texture(PLATFORMING_BG_DEFAULT + "/" + str(pack_theme.get("sky", "")))
        var far_tex: Texture2D = _load_pack_texture(PLATFORMING_BG_DEFAULT + "/" + str(pack_theme.get("far", "")))
        var mid_tex: Texture2D = _load_pack_texture(PLATFORMING_BG_DEFAULT + "/" + str(pack_theme.get("mid", "")))
        var near_tex: Texture2D = _make_pack_deco_strip_texture(640, 128, pack_theme.get("near_deco", []))
        var ground_tex: Texture2D = _make_pack_ground_texture(640, 144, pack_theme)
        var cloud_far_tex: Texture2D = _make_cloud_band_texture(512, 96, 6, 0.26, 0.65)
        var cloud_mid_tex: Texture2D = _make_cloud_band_texture(512, 96, 8, 0.36, 0.88)
        var cloud_near_tex: Texture2D = _make_cloud_band_texture(512, 112, 10, 0.48, 1.0)

        if sky_tex != null and far_tex != null and mid_tex != null and near_tex != null and ground_tex != null and cloud_far_tex != null and cloud_mid_tex != null and cloud_near_tex != null:
            using_pack_background_assets = true
            bg_deep.texture = sky_tex
            cloud_far.texture = cloud_far_tex
            bg_far.texture = _make_background_texture_transparent_above_ground(far_tex)
            cloud_mid.texture = cloud_mid_tex
            bg_mid.texture = _make_background_texture_transparent_above_ground(mid_tex)
            cloud_near.texture = cloud_near_tex
            bg_near.texture = near_tex
            ground.texture = ground_tex
            ground_overlay.texture = _make_ground_overlay_texture(480, 120, t)
            bg_deep.region_rect = Rect2(0, 0, 80000, float(max(64, sky_tex.get_height())))
            cloud_far.region_rect = Rect2(0, 0, 80000, float(max(64, cloud_far.texture.get_height())))
            bg_far.region_rect = Rect2(0, 0, 80000, float(max(64, bg_far.texture.get_height())))
            cloud_mid.region_rect = Rect2(0, 0, 80000, float(max(64, cloud_mid.texture.get_height())))
            bg_mid.region_rect = Rect2(0, 0, 80000, float(max(64, bg_mid.texture.get_height())))
            cloud_near.region_rect = Rect2(0, 0, 80000, float(max(64, cloud_near.texture.get_height())))
            bg_near.region_rect = Rect2(0, 0, 80000, float(max(64, near_tex.get_height())))
            ground.region_rect = Rect2(0, 0, 80000, float(max(96, ground_tex.get_height())))
            ground_overlay.region_rect = Rect2(0, 0, 80000, float(max(80, ground_overlay.texture.get_height())))
            _apply_level_layer_colors(t)
            _apply_parallax_depth_scales()
            return

    using_pack_background_assets = false
    bg_deep.texture = _make_atari_sky_texture(256, 120, t["sky_base"], t["sky_star_a"], t["sky_star_b"])
    cloud_far.texture = _make_cloud_band_texture(256, 88, 5, 0.28, 0.65)
    bg_far.texture = _make_horizon_silhouette_texture(256, 128, t["far"], t["sky_star_a"], 28, 10)
    cloud_mid.texture = _make_cloud_band_texture(256, 96, 7, 0.36, 0.85)
    bg_mid.texture = _make_horizon_silhouette_texture(256, 128, t["mid"], t["sky_star_a"], 22, 18)
    cloud_near.texture = _make_cloud_band_texture(256, 104, 9, 0.48, 1.0)
    bg_near.texture = _make_atari_horizon_texture(256, 128, t["near"], t["sky_star_a"], 18, 28)
    ground.texture = _make_atari_ground_texture(256, 96, t["ground_a"], t["ground_b"], t["ground_accent"])
    ground_overlay.texture = _make_ground_overlay_texture(256, 110, t)
    _apply_level_layer_colors(t)
    _apply_parallax_depth_scales()

func _apply_level_layer_colors(theme: Dictionary) -> void:
    if theme.is_empty():
        bg_base_sky.modulate = Color(1.0, 1.0, 1.0, 1.0)
        bg_base_ground.modulate = Color(1.0, 1.0, 1.0, 1.0)
        bg_deep.modulate = Color(1.0, 1.0, 1.0, 1.0)
        cloud_far.modulate = Color(1.0, 1.0, 1.0, 1.0)
        bg_far.modulate = Color(1.0, 1.0, 1.0, 1.0)
        cloud_mid.modulate = Color(1.0, 1.0, 1.0, 1.0)
        bg_mid.modulate = Color(1.0, 1.0, 1.0, 1.0)
        cloud_near.modulate = Color(1.0, 1.0, 1.0, 1.0)
        bg_near.modulate = Color(1.0, 1.0, 1.0, 1.0)
        ground.modulate = Color(1.0, 1.0, 1.0, 1.0)
        ground_overlay.modulate = Color(1.0, 1.0, 1.0, 1.0)
        return

    # Keep each level's hue identity, but keep values darker so white HUD text stays readable.
    bg_deep.modulate = Color(theme["sky_base"]).lerp(Color(0.08, 0.1, 0.14, 1.0), 0.22)
    cloud_far.modulate = Color(theme["sky_star_a"]).lerp(Color(1.0, 1.0, 1.0, 1.0), 0.25)
    bg_far.modulate = Color(theme["far"]).lerp(Color(0.08, 0.1, 0.14, 1.0), 0.26)
    cloud_mid.modulate = Color(theme["sky_star_a"]).lerp(Color(theme["sky_star_b"]), 0.18)
    bg_mid.modulate = Color(theme["mid"]).lerp(Color(0.08, 0.1, 0.14, 1.0), 0.28)
    cloud_near.modulate = Color(theme["sky_star_a"]).lerp(Color(theme["near"]), 0.16)
    bg_near.modulate = Color(theme["near"]).lerp(Color(0.08, 0.1, 0.14, 1.0), 0.3)
    ground.modulate = Color(theme["ground_a"]).lerp(Color(0.11, 0.09, 0.08, 1.0), 0.2)
    ground_overlay.modulate = Color(theme["ground_b"]).lerp(Color(0.06, 0.05, 0.05, 1.0), 0.5)

    # Fill any uncovered camera space: sky above heroes, ground below heroes.
    bg_base_sky.modulate = bg_deep.modulate
    bg_base_ground.modulate = ground.modulate

func _pack_theme_for_level(level_index: int) -> Dictionary:
    var keys: Array = LEVEL_BG_PACK.keys()
    if keys.is_empty():
        return {}
    keys.sort()
    var idx: int = (max(1, level_index) - 1) % keys.size()
    var key: int = int(keys[idx])
    return LEVEL_BG_PACK.get(key, {})

func _theme_for_level(level_index: int) -> Dictionary:
    var keys: Array = LEVEL_BG_THEMES.keys()
    if keys.is_empty():
        return {}
    keys.sort()
    var base_idx: int = (max(1, level_index) - 1) % keys.size()
    var base_key: int = int(keys[base_idx])
    var base_theme: Dictionary = LEVEL_BG_THEMES.get(base_key, {})
    if level_index <= keys.size():
        return base_theme.duplicate(true)

    var seed: float = float(level_index - 1)
    var out_theme: Dictionary = {}
    var color_keys: Array[String] = [
        "sky_base",
        "sky_star_a",
        "sky_star_b",
        "far",
        "mid",
        "near",
        "ground_a",
        "ground_b",
        "ground_accent",
    ]
    for i in range(color_keys.size()):
        var ck: String = color_keys[i]
        var src: Color = Color(base_theme.get(ck, Color.WHITE))
        var hue_shift: float = 0.025 * seed
        var sat_mul: float = 0.9 + 0.07 * sin(seed * 0.63 + float(i) * 0.6)
        var val_mul: float = 0.88 + 0.14 * cos(seed * 0.41 + float(i) * 0.75)
        var out_color: Color = Color.from_hsv(
            fposmod(src.h + hue_shift, 1.0),
            clamp(src.s * sat_mul, 0.14, 1.0),
            clamp(src.v * val_mul, 0.12, 1.0),
            src.a
        )
        out_theme[ck] = out_color
    return out_theme

func _enemy_tint_for_level(level_index: int) -> Color:
    var theme: Dictionary = _theme_for_level(level_index)
    var sky_color: Color = Color(theme.get("sky_base", Color(1.0, 1.0, 1.0, 1.0)))
    return Color(1.0, 1.0, 1.0, 1.0).lerp(sky_color, 0.7)

func _make_background_overlay_texture(w: int, h: int, theme: Dictionary) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    var sky: Color = Color(theme.get("sky_base", Color(0.1, 0.1, 0.2, 1.0)))
    var near: Color = Color(theme.get("near", Color(0.3, 0.4, 0.5, 1.0)))
    var line: Color = Color(theme.get("sky_star_a", Color(0.95, 0.95, 0.95, 1.0)))
    for y in range(h):
        var blend: float = float(y) / max(1.0, float(h - 1))
        var row: Color = sky.lerp(near, blend * 0.55)
        row.a = 0.08 + 0.12 * blend
        for x in range(w):
            img.set_pixel(x, y, row)
    for y in range(10, h, 20):
        for x in range(w):
            if ((x + y * 3) % 7) != 0:
                continue
            img.set_pixel(x, y, Color(line.r, line.g, line.b, 0.28))
    return ImageTexture.create_from_image(img)

func _make_horizon_silhouette_texture(w: int, h: int, base_color: Color, accent: Color, stripe_height: int, noise_step: int) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.0, 0.0, 0.0, 0.0))
    var horizon_y: int = int(h * 0.48)
    for x in range(w):
        var ridge_height: int = horizon_y + int(sin(float(x) * 0.09) * 7.0) + int(cos(float(x) * 0.03) * 12.0)
        for y in range(clamp(ridge_height, 0, h - 1), h):
            var blend: float = float(y - ridge_height) / max(1.0, float(h - ridge_height - 1))
            var row_color: Color = base_color.lerp(accent, 0.08 + blend * 0.12)
            row_color.a = 1.0
            if ((x + y) % max(2, noise_step)) == 0:
                row_color = row_color.lerp(accent, 0.12)
            if stripe_height > 0 and ((y - ridge_height) % stripe_height) == 0:
                row_color = row_color.darkened(0.08)
            img.set_pixel(x, y, row_color)
    return ImageTexture.create_from_image(img)

func _make_play_area_overlay_texture(w: int, h: int, theme: Dictionary) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    var far: Color = Color(theme.get("far", Color(0.2, 0.3, 0.4, 1.0)))
    var accent: Color = Color(theme.get("ground_accent", Color(0.95, 0.95, 0.95, 1.0)))
    img.fill(Color(far.r, far.g, far.b, 0.14))
    var top_line_y: int = 8
    var bottom_line_y: int = h - 10
    for x in range(w):
        img.set_pixel(x, top_line_y, Color(accent.r, accent.g, accent.b, 0.2))
        img.set_pixel(x, bottom_line_y, Color(accent.r, accent.g, accent.b, 0.16))
    for y in range(20, h - 14, 24):
        for x in range(w):
            if ((x + y) % 11) == 0:
                img.set_pixel(x, y, Color(accent.r, accent.g, accent.b, 0.08))
    return ImageTexture.create_from_image(img)

func _make_cloud_band_texture(w: int, h: int, cluster_count: int, alpha_strength: float, brightness: float) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.0, 0.0, 0.0, 0.0))
    var puff_color := Color(brightness, brightness, brightness, 1.0)
    for i in range(cluster_count):
        var center_x: int = int((float(i) + 0.5) * float(w) / float(cluster_count) + sin(float(i) * 1.7) * 18.0)
        var center_y: int = int(h * (0.35 + 0.2 * sin(float(i) * 0.9)))
        var puff_count: int = 3 + (i % 3)
        for puff_index in range(puff_count):
            var puff_x: int = center_x + int((puff_index - puff_count / 2.0) * 18.0)
            var puff_y: int = center_y + int(cos(float(puff_index) * 1.3 + float(i)) * 6.0)
            var radius_x: int = 18 + ((i + puff_index) % 3) * 10
            var radius_y: int = 10 + ((i + puff_index * 2) % 3) * 6
            _draw_soft_ellipse_tiled_x(img, puff_x, puff_y, radius_x, radius_y, puff_color, alpha_strength)
        _draw_soft_ellipse_tiled_x(img, center_x, center_y + 8, 42, 12, puff_color, alpha_strength * 0.72)
    return ImageTexture.create_from_image(img)

func _draw_soft_ellipse_tiled_x(img: Image, center_x: int, center_y: int, radius_x: int, radius_y: int, color: Color, alpha_strength: float) -> void:
    var min_x: int = center_x - radius_x - 1
    var max_x: int = center_x + radius_x + 1
    var min_y: int = max(0, center_y - radius_y - 1)
    var max_y: int = min(img.get_height() - 1, center_y + radius_y + 1)
    var width: int = img.get_width()
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            var dx: float = float(x - center_x) / max(1.0, float(radius_x))
            var dy: float = float(y - center_y) / max(1.0, float(radius_y))
            var dist_sq: float = dx * dx + dy * dy
            if dist_sq > 1.0:
                continue
            var alpha: float = (1.0 - dist_sq) * alpha_strength
            var wrapped_x: int = posmod(x, width)
            var prev: Color = img.get_pixel(wrapped_x, y)
            var next_alpha: float = clamp(prev.a + alpha, 0.0, 1.0)
            var next_color: Color = color
            next_color.a = next_alpha
            img.set_pixel(wrapped_x, y, next_color)

func _make_background_texture_transparent_above_ground(texture: Texture2D) -> Texture2D:
    if texture == null:
        return null
    var img: Image = texture.get_image()
    if img == null:
        return texture
    img.convert(Image.FORMAT_RGBA8)
    var key_color: Color = img.get_pixel(0, 0)
    for y in range(img.get_height()):
        for x in range(img.get_width()):
            var pixel: Color = img.get_pixel(x, y)
            if _is_near_color(pixel, key_color, 0.08):
                pixel.a = 0.0
                img.set_pixel(x, y, pixel)
    return ImageTexture.create_from_image(img)

func _is_near_color(a: Color, b: Color, tolerance: float) -> bool:
    return absf(a.r - b.r) <= tolerance and absf(a.g - b.g) <= tolerance and absf(a.b - b.b) <= tolerance

func _make_ground_overlay_texture(w: int, h: int, theme: Dictionary) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    var g1: Color = Color(theme.get("ground_a", Color(0.42, 0.3, 0.16, 1.0)))
    var g2: Color = Color(theme.get("ground_b", Color(0.26, 0.18, 0.1, 1.0)))
    var accent: Color = Color(theme.get("ground_accent", Color(0.9, 0.9, 0.9, 1.0)))
    for y in range(h):
        var blend: float = float(y) / max(1.0, float(h - 1))
        var row: Color = g1.lerp(g2, blend)
        row.a = 0.06 + blend * 0.14
        for x in range(w):
            var px: Color = row
            if y > 12 and (y % 14) == 0 and (x % 7) == 0:
                px = Color(accent.r, accent.g, accent.b, 0.08)
            img.set_pixel(x, y, px)
    return ImageTexture.create_from_image(img)

func _load_pack_texture(path: String) -> Texture2D:
    if path == "":
        return null
    if pack_texture_cache.has(path):
        return pack_texture_cache[path]
    var file_name: String = path.get_file()
    if PACK_BG_TEXTURES.has(file_name):
        var cached_bg: Texture2D = PACK_BG_TEXTURES[file_name]
        pack_texture_cache[path] = cached_bg
        return cached_bg
    var tex: Texture2D = load(path) as Texture2D
    if tex == null:
        return null
    pack_texture_cache[path] = tex
    return tex

func _load_pack_image(path: String) -> Image:
    var file_name: String = path.get_file()
    var tex: Texture2D = null
    if PACK_TILE_TEXTURES.has(file_name):
        tex = PACK_TILE_TEXTURES[file_name]
    elif PACK_BG_TEXTURES.has(file_name):
        tex = PACK_BG_TEXTURES[file_name]
    else:
        tex = load(path) as Texture2D
    if tex == null:
        return null
    var img: Image = tex.get_image()
    if img == null or img.is_empty():
        return null
    if img.get_format() != Image.FORMAT_RGBA8:
        img.convert(Image.FORMAT_RGBA8)
    return img

func _make_pack_ground_texture(w: int, h: int, theme: Dictionary) -> Texture2D:
    var top_path: String = PLATFORMING_TILES_DEFAULT + "/" + str(theme.get("ground_top", ""))
    var fill_path: String = PLATFORMING_TILES_DEFAULT + "/" + str(theme.get("ground_fill", ""))
    var top_tile: Image = _load_pack_image(top_path)
    var fill_tile: Image = _load_pack_image(fill_path)
    if top_tile == null or fill_tile == null:
        return null

    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    var tile_w: int = max(1, top_tile.get_width())
    var tile_h: int = max(1, top_tile.get_height())
    var fill_w: int = max(1, fill_tile.get_width())
    var fill_h: int = max(1, fill_tile.get_height())

    for x in range(0, w, tile_w):
        img.blit_rect(top_tile, Rect2i(0, 0, tile_w, tile_h), Vector2i(x, 0))
    for y in range(tile_h, h, fill_h):
        for x in range(0, w, fill_w):
            img.blit_rect(fill_tile, Rect2i(0, 0, fill_w, fill_h), Vector2i(x, y))

    return ImageTexture.create_from_image(img)

func _make_pack_deco_strip_texture(w: int, h: int, deco_names_variant: Variant) -> Texture2D:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    if not (deco_names_variant is Array):
        return ImageTexture.create_from_image(img)

    var deco_names: Array = deco_names_variant
    if deco_names.is_empty():
        return ImageTexture.create_from_image(img)

    for x in range(0, w, 72):
        var idx: int = int((x / 72) % deco_names.size())
        var deco_name: String = str(deco_names[idx])
        var deco_img: Image = _load_pack_image(PLATFORMING_TILES_DEFAULT + "/" + deco_name)
        if deco_img == null:
            continue
        var y_jitter: int = int((x / 24) % 3) * 2
        var px: int = clamp(x + int(randf_range(-6.0, 6.0)), 0, max(0, w - deco_img.get_width()))
        var py: int = max(0, h - deco_img.get_height() - 6 - y_jitter)
        img.blit_rect(deco_img, Rect2i(0, 0, deco_img.get_width(), deco_img.get_height()), Vector2i(px, py))

    return ImageTexture.create_from_image(img)

func _make_atari_sky_texture(w: int, h: int, base_color: Color, star_a: Color, star_b: Color) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    img.fill(base_color)
    for y in range(h):
        for x in range(w):
            if ((x + y * 7) % 41) == 0:
                img.set_pixel(x, y, star_a)
            elif ((x * 5 + y * 3) % 83) == 0:
                img.set_pixel(x, y, star_b)
    return ImageTexture.create_from_image(img)

func _make_atari_horizon_texture(w: int, h: int, body_color: Color, accent_color: Color, segment: int, peak_height: int) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    var baseline: int = int(h * 0.78)
    var safe_segment: int = max(2, segment)
    var safe_peak: int = max(4, peak_height)
    for x in range(w):
        var step: int = int((x / safe_segment) % 4)
        var top: int = baseline - int(round((float(step) / 3.0) * float(safe_peak)))
        for y in range(top, h):
            img.set_pixel(x, y, body_color)
            if y == top and (x % 3 == 0):
                img.set_pixel(x, y, accent_color)
    return ImageTexture.create_from_image(img)

func _make_atari_ground_texture(w: int, h: int, c1: Color, c2: Color, accent: Color) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    for y in range(h):
        for x in range(w):
            var base: Color = c1 if (((x / 8) + (y / 6)) % 2 == 0) else c2
            if y < h / 5:
                base = base.lightened(0.16)
            if ((x + y * 5) % 27) == 0:
                base = accent
            img.set_pixel(x, y, base)
    return ImageTexture.create_from_image(img)

func _setup_actor_sheets() -> void:
    var combat_base: String = "res://Art/CombatSprites"
    var knight_visual: Dictionary = _make_asset_actor(
        combat_base + "/hero_knight.png",
        HERO_FRAME_SIZE,
        Color(0.25, 0.74, 0.98, 1.0),
        "knight",
        HERO_RENDER_SCALE
    )
    var archer_visual: Dictionary = _make_asset_actor(
        combat_base + "/hero_archer.png",
        HERO_FRAME_SIZE,
        Color(0.99, 0.58, 0.17, 1.0),
        "archer",
        HERO_RENDER_SCALE
    )
    var guardian_visual: Dictionary = _make_asset_actor(
        combat_base + "/hero_guardian.png",
        HERO_FRAME_SIZE,
        Color(0.28, 0.86, 0.41, 1.0),
        "guardian",
        HERO_RENDER_SCALE
    )
    var mage_visual: Dictionary = _make_asset_actor(
        combat_base + "/hero_mage.png",
        HERO_FRAME_SIZE,
        Color(0.86, 0.33, 0.35, 1.0),
        "mage",
        HERO_RENDER_SCALE
    )
    hero_sheets = {
        "knight": knight_visual,
        "archer": archer_visual,
        "guardian": guardian_visual,
        "mage": mage_visual,
    }

    var goblin_visual: Dictionary = _make_asset_actor(
        combat_base + "/enemy_goblin.png",
        ENEMY_FRAME_SIZE,
        Color(0.83, 0.23, 0.23, 1.0),
        "goblin",
        ENEMY_RENDER_SCALE,
        true
    )
    var brute_visual: Dictionary = _make_asset_actor(
        combat_base + "/enemy_brute.png",
        ENEMY_FRAME_SIZE,
        Color(0.75, 0.16, 0.58, 1.0),
        "brute",
        ENEMY_RENDER_SCALE,
        true
    )
    var flyer_visual: Dictionary = _make_asset_actor(
        combat_base + "/enemy_flyer.png",
        ENEMY_FRAME_SIZE,
        Color(0.93, 0.67, 0.21, 1.0),
        "flyer",
        ENEMY_RENDER_SCALE,
        true
    )
    var boss_visual: Dictionary = _make_asset_actor(
        combat_base + "/enemy_boss.png",
        BOSS_FRAME_SIZE,
        Color(0.76, 0.27, 0.84, 1.0),
        "boss",
        BOSS_RENDER_SCALE,
        true
    )

    enemy_defs = {
        "goblin": {
            "sheet": goblin_visual["sheet"],
            "frame": goblin_visual["frame"],
            "scale": _normalized_render_scale(goblin_visual["frame"], ENEMY_RENDER_SCALE, ENEMY_TARGET_WORLD_WIDTH),
            "speed": 55.0,
            "coins": 10,
        },
        "brute": {
            "sheet": brute_visual["sheet"],
            "frame": brute_visual["frame"],
            "scale": _normalized_render_scale(brute_visual["frame"], ENEMY_RENDER_SCALE, ENEMY_TARGET_WORLD_WIDTH),
            "speed": 36.0,
            "coins": 16,
        },
        "flyer": {
            "sheet": flyer_visual["sheet"],
            "frame": flyer_visual["frame"],
            "scale": _normalized_render_scale(flyer_visual["frame"], ENEMY_RENDER_SCALE, ENEMY_TARGET_WORLD_WIDTH),
            "speed": 68.0,
            "coins": 14,
        },
        "boss": {
            "sheet": boss_visual["sheet"],
            "frame": boss_visual["frame"],
            "scale": _normalized_render_scale(boss_visual["frame"], BOSS_RENDER_SCALE, BOSS_TARGET_WORLD_WIDTH),
            "speed": 22.0,
            "coins": 120,
        },
    }
    var pack_enemy_keys: Array[String] = _append_pack_enemy_defs_from_constants()
    _assign_level_enemy_pools(pack_enemy_keys)

func _append_pack_double_enemy_defs() -> Array[String]:
    var frame_map: Dictionary = _build_pack_double_enemy_frame_map()
    if frame_map.is_empty():
        return []

    var created_keys: Array[String] = []
    var base_names: Array = frame_map.keys()
    base_names.sort()
    for base_name_variant in base_names:
        var base_name: String = str(base_name_variant)
        var entry: Dictionary = frame_map[base_name]
        var walk_a_path: String = str(entry.get("walk_a", ""))
        var walk_b_path: String = str(entry.get("walk_b", ""))
        var rest_path: String = str(entry.get("rest", ""))

        if walk_a_path == "":
            walk_a_path = rest_path if rest_path != "" else walk_b_path
        if walk_b_path == "":
            walk_b_path = rest_path if rest_path != "" else walk_a_path
        if rest_path == "":
            rest_path = walk_b_path if walk_b_path != "" else walk_a_path
        if walk_a_path == "" or walk_b_path == "" or rest_path == "":
            continue

        var visual: Dictionary = _make_pack_actor(
            walk_a_path,
            walk_b_path,
            rest_path,
            ENEMY_FRAME_SIZE,
            Color(0.83, 0.23, 0.23, 1.0),
            "goblin",
            ENEMY_RENDER_SCALE,
            true
        )
        var enemy_key: String = "double_%s" % base_name
        enemy_defs[enemy_key] = {
            "sheet": visual["sheet"],
            "frame": visual["frame"],
            "scale": _normalized_render_scale(visual["frame"], float(visual.get("scale", ENEMY_RENDER_SCALE)), ENEMY_TARGET_WORLD_WIDTH),
            "speed": _double_enemy_speed(base_name),
            "coins": _double_enemy_coins(base_name),
        }
        created_keys.append(enemy_key)

    return created_keys

func _append_pack_enemy_defs_from_constants() -> Array[String]:
    var created_keys: Array[String] = []
    for variant in PACK_ENEMY_WEB_VARIANTS:
        var visual: Dictionary = _make_pack_actor_from_textures(
            variant["walk_a"],
            variant["walk_b"],
            variant["rest"],
            ENEMY_FRAME_SIZE,
            Color(0.83, 0.23, 0.23, 1.0),
            "goblin",
            ENEMY_RENDER_SCALE,
            true
        )
        var enemy_key: String = str(variant["key"])
        enemy_defs[enemy_key] = {
            "sheet": visual["sheet"],
            "frame": visual["frame"],
            "scale": _normalized_render_scale(visual["frame"], float(visual.get("scale", ENEMY_RENDER_SCALE)), ENEMY_TARGET_WORLD_WIDTH),
            "speed": float(variant["speed"]),
            "coins": int(variant["coins"]),
        }
        created_keys.append(enemy_key)
    return created_keys

func _normalized_render_scale(frame_size: Vector2i, fallback_scale: float, target_world_width: float) -> float:
    if frame_size.x <= 0:
        return fallback_scale
    var width := frame_size.x
    return max(0.05, target_world_width / float(width))

func _build_pack_double_enemy_frame_map() -> Dictionary:
    var frame_map: Dictionary = {}
    var files: PackedStringArray = DirAccess.get_files_at(PLATFORMING_ENEMY_DOUBLE_DIR)
    if files.is_empty():
        return frame_map

    for file_name in files:
        var lower_file: String = file_name.to_lower()
        if not lower_file.ends_with(".png"):
            continue
        var stem: String = lower_file.get_basename()
        var base_name: String = _strip_pack_enemy_variant_suffix(stem)
        if base_name == "" or not _is_pack_enemy_allowed(base_name):
            continue

        var frame_kind: String = _classify_pack_enemy_frame_kind(stem)
        if frame_kind == "":
            continue

        var data: Dictionary = frame_map.get(base_name, {
            "walk_a": "",
            "walk_b": "",
            "rest": "",
        })
        if str(data.get(frame_kind, "")) == "":
            data[frame_kind] = PLATFORMING_ENEMY_DOUBLE_DIR + "/" + file_name
        frame_map[base_name] = data

    return frame_map

func _strip_pack_enemy_variant_suffix(name: String) -> String:
    var suffixes: Array[String] = [
        "_walk_a",
        "_walk_b",
        "_swim_a",
        "_swim_b",
        "_move_a",
        "_move_b",
        "_attack_rest",
        "_attack_a",
        "_attack_b",
        "_rest",
        "_idle",
        "_jump",
        "_fall",
        "_fly",
        "_flat",
        "_shell",
        "_up",
        "_down",
        "_a",
        "_b",
    ]
    for suffix in suffixes:
        if name.ends_with(suffix):
            return name.substr(0, name.length() - suffix.length())
    return name

func _classify_pack_enemy_frame_kind(name: String) -> String:
    if name.ends_with("_walk_a") or name.ends_with("_swim_a") or name.ends_with("_move_a") or name.ends_with("_attack_a") or name.ends_with("_a"):
        return "walk_a"
    if name.ends_with("_walk_b") or name.ends_with("_swim_b") or name.ends_with("_move_b") or name.ends_with("_attack_b") or name.ends_with("_b"):
        return "walk_b"
    if name.ends_with("_rest") or name.ends_with("_idle") or name.ends_with("_attack_rest") or name.ends_with("_shell") or name.ends_with("_fly") or name.ends_with("_jump") or name.ends_with("_fall") or name.ends_with("_flat") or name.ends_with("_up") or name.ends_with("_down"):
        return "rest"
    return ""

func _is_pack_enemy_allowed(base_name: String) -> bool:
    var lower: String = base_name.to_lower()
    for blocked_prefix in ENEMY_DOUBLE_EXCLUDED_PREFIXES:
        if lower.begins_with(blocked_prefix):
            return false
    return true

func _assign_level_enemy_pools(candidate_keys: Array[String]) -> void:
    var source: Array[String] = candidate_keys.duplicate()
    if source.is_empty():
        source = ["goblin", "brute", "flyer"]
    level_enemy_pools.clear()
    for level_index in [1, 2, 3]:
        level_enemy_pools[level_index] = _pick_random_enemy_subset(source, ENEMY_POOL_PER_LEVEL)

func _pick_random_enemy_subset(source: Array[String], count: int) -> Array[String]:
    var bag: Array[String] = source.duplicate()
    bag.shuffle()
    var limit: int = min(count, bag.size())
    var result: Array[String] = []
    for i in range(limit):
        result.append(str(bag[i]))
    return result

func _enemy_key_for_level(level_index: int) -> String:
    var pool_variant = level_enemy_pools.get(level_index, [])
    var pool: Array = pool_variant
    if pool.is_empty():
        return str(LEVEL_ENEMY_TYPE.get(level_index, "goblin"))
    return str(pool[randi() % pool.size()])

func _double_enemy_speed(base_name: String) -> float:
    var lower: String = base_name.to_lower()
    if lower.find("snail") >= 0 or lower.find("worm") >= 0:
        return 36.0
    if lower.find("fish") >= 0 or lower.find("bee") >= 0 or lower.find("fly") >= 0 or lower.find("ladybug") >= 0:
        return 68.0
    if lower.find("saw") >= 0:
        return 62.0
    if lower.find("mouse") >= 0:
        return 55.0
    return 55.0

func _double_enemy_coins(base_name: String) -> int:
    var lower: String = base_name.to_lower()
    if lower.find("saw") >= 0:
        return 16
    if lower.find("snail") >= 0 or lower.find("worm") >= 0:
        return 15
    if lower.find("fish") >= 0 or lower.find("bee") >= 0 or lower.find("fly") >= 0 or lower.find("ladybug") >= 0:
        return 14
    return 12

func _make_actor_sheet(frame_size: Vector2i, body_color: Color, accent_color: Color, archetype: String, facing_left: bool) -> ImageTexture:
    var img: Image = Image.create(frame_size.x * 3, frame_size.y, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))

    _draw_actor_frame(img, 0, frame_size, body_color, accent_color, archetype, facing_left, -1, false)
    _draw_actor_frame(img, frame_size.x, frame_size, body_color, accent_color, archetype, facing_left, 1, false)
    _draw_actor_frame(img, frame_size.x * 2, frame_size, body_color, accent_color, archetype, facing_left, 0, true)

    return ImageTexture.create_from_image(img)

func _draw_actor_frame(img: Image, frame_origin_x: int, frame_size: Vector2i, body_color: Color, accent_color: Color, archetype: String, facing_left: bool, step: int, attacking: bool) -> void:
    var center_x: int = frame_origin_x + frame_size.x / 2
    var direction: int = -1 if facing_left else 1
    var body_bottom: int = frame_size.y - 4
    var head_top: int = 4
    var leg_y: int = frame_size.y - 7
    var leg_w: int = 3 if frame_size.x <= 24 else 4

    _fill_rect(img, center_x - 4, head_top, 8, 5, body_color)
    _fill_rect(img, center_x - 5, head_top + 6, 10, 8, body_color)
    _fill_rect(img, center_x - 4, leg_y, leg_w, 4, body_color)
    _fill_rect(img, center_x + 1, leg_y, leg_w, 4, body_color)

    if step < 0:
        _fill_rect(img, center_x - 5, leg_y + 2, leg_w, 2, body_color)
    elif step > 0:
        _fill_rect(img, center_x + 2, leg_y + 2, leg_w, 2, body_color)

    _fill_rect(img, center_x + (direction * 2), head_top + 1, 2, 2, accent_color)

    if attacking:
        _fill_rect(img, center_x + (direction * 5), head_top + 7, 5 * direction, 2, body_color)
        _fill_rect(img, center_x + (direction * 10), head_top + 7, 2, 2, accent_color)
    else:
        _fill_rect(img, center_x + (direction * 4), head_top + 8, 3 * direction, 2, body_color)

    match archetype:
        "archer":
            _fill_rect(img, center_x + (direction * 6), head_top + 6, 1, 9, accent_color)
        "guardian":
            _fill_rect(img, center_x - (direction * 7), head_top + 8, 4, 6, accent_color)
        "mage":
            _fill_rect(img, center_x - 6, body_bottom - 7, 12, 2, accent_color)
        "goblin":
            _fill_rect(img, center_x - 5, head_top - 1, 2, 2, accent_color)
        "brute":
            _fill_rect(img, center_x - 6, head_top + 6, 12, 10, body_color)
        "flyer":
            _fill_rect(img, center_x - 10, head_top + 8, 4, 2, body_color)
            _fill_rect(img, center_x + 6, head_top + 8, 4, 2, body_color)
        "boss":
            _fill_rect(img, center_x - 8, head_top + 4, 16, 16, body_color)
            _fill_rect(img, center_x - 2, head_top + 1, 4, 2, accent_color)

func _fill_rect(img: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
    if w == 0 or h <= 0:
        return
    var x0: int = x
    var width: int = w
    if width < 0:
        x0 += width
        width = -width
    for yy in range(y, y + h):
        if yy < 0 or yy >= img.get_height():
            continue
        for xx in range(x0, x0 + width):
            if xx < 0 or xx >= img.get_width():
                continue
            img.set_pixel(xx, yy, color)

func _make_arrow_texture() -> ImageTexture:
    var img: Image = Image.create(12, 4, false, Image.FORMAT_RGBA8)
    for y in range(4):
        for x in range(12):
            img.set_pixel(x, y, Color(0, 0, 0, 0))
    for x in range(2, 10):
        img.set_pixel(x, 1, Color(0.8, 0.62, 0.24, 1.0))
        img.set_pixel(x, 2, Color(0.65, 0.45, 0.16, 1.0))
    img.set_pixel(0, 1, Color(0.9, 0.78, 0.3, 1.0))
    img.set_pixel(1, 0, Color(0.95, 0.88, 0.45, 1.0))
    img.set_pixel(1, 1, Color(0.95, 0.88, 0.45, 1.0))
    img.set_pixel(1, 2, Color(0.95, 0.88, 0.45, 1.0))
    img.set_pixel(1, 3, Color(0.95, 0.88, 0.45, 1.0))
    img.set_pixel(10, 0, Color(0.45, 0.3, 0.12, 1.0))
    img.set_pixel(10, 3, Color(0.45, 0.3, 0.12, 1.0))
    img.set_pixel(11, 1, Color(0.2, 0.2, 0.2, 1.0))
    img.set_pixel(11, 2, Color(0.2, 0.2, 0.2, 1.0))
    return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
    if OS.has_feature("editor"):
        _update_touch_camera_debug()
    _update_floating_damage_texts(delta)
    _update_hero_damage_float(delta)
    _update_hero_glow(delta)
    _update_active_visual_effects(delta)
    if battle_completed:
        if not summary_finalized:
            if battle_victory:
                _run_post_battle_sweep(delta)
            else:
                _run_defeat_pose(delta)
        _update_ui()
        return
    if summary_panel.visible:
        return

    var safe_engine_scale: float = max(0.001, Engine.time_scale)
    battle_scene_unadjusted_seconds += max(0.0, delta) / safe_engine_scale

    sim_accumulator += delta
    var sim_steps: int = 0
    while sim_accumulator >= SIM_STEP and sim_steps < 240:
        _simulate_step(SIM_STEP)
        sim_accumulator -= SIM_STEP
        sim_steps += 1

        if player_health <= 0.0:
            _end_battle(false)
            return

    if sim_accumulator > 0.0 and sim_steps == 0:
        _simulate_step(sim_accumulator)
        sim_accumulator = 0.0
        if player_health <= 0.0:
            _end_battle(false)
            return

    _update_ui()

func _draw() -> void:
    if not OS.has_feature("editor") or camera_2d == null:
        return
    var touch_area: Rect2 = _touch_camera_world_rect()
    if touch_area.size.x <= 0.0 or touch_area.size.y <= 0.0:
        return
    draw_rect(touch_area, Color(0.18, 0.9, 0.95, 0.10), true)
    draw_rect(touch_area, Color(0.18, 0.9, 0.95, 0.9), false, 4.0)

func _unhandled_input(event: InputEvent) -> void:
    if battle_completed:
        return
    if summary_panel != null and summary_panel.visible:
        return
    if _is_settings_open():
        if event.is_action_pressed("escape") or event.is_action_pressed("back"):
            _hide_settings_panel()
        return
    if SaveHandler.touch_input_mode:
        if event is InputEventScreenTouch and event.pressed:
            _try_activate_hero_from_world_pos(_screen_to_world_pos(event.position))
            get_viewport().set_input_as_handled()
        elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _try_activate_hero_from_world_pos(get_global_mouse_position())
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        _try_activate_hero_from_world_pos(get_global_mouse_position())
        get_viewport().set_input_as_handled()

func _try_activate_hero_from_world_pos(world_pos: Vector2) -> void:
    var clicked_hero: CombatSprite = _find_clicked_hero(world_pos)
    if clicked_hero == null:
        return
    var h: Dictionary = hero_data.get(clicked_hero, {})
    var hero_name: String = str(h.get("name", ""))
    if hero_name == "":
        return
    _on_hero_clicked(clicked_hero, hero_name)

func _screen_to_world_pos(screen_pos: Vector2) -> Vector2:
    return get_viewport().get_canvas_transform().affine_inverse() * screen_pos

func _find_clicked_hero(world_pos: Vector2) -> CombatSprite:
    var best: CombatSprite = null
    var best_dsq: float = HERO_CLICK_RADIUS * HERO_CLICK_RADIUS
    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        if hero.is_defeated:
            continue
        var d_sq: float = hero.global_position.distance_squared_to(world_pos)
        if d_sq <= best_dsq:
            best_dsq = d_sq
            best = hero
    return best

func _simulate_step(delta: float, skip_visual_updates: bool = false) -> void:
    _advance_run_clock(delta)
    _apply_level_background(current_level)
    _update_ufo_event(delta)
    _update_active_cooldowns(delta)
    _auto_use_hero_actives()
    _gain_power(BASE_POWER_REGEN_PER_SEC * _power_gain_mult() * delta)
    _spawn_loop(delta)
    _update_heroes(delta)
    _update_mage_pending_strikes(delta)
    _update_enemies(delta)
    _update_arrows(delta)
    _update_coins(delta)
    if not skip_visual_updates:
        _update_camera_and_parallax()

    if shield_time > 0.0:
        shield_time = max(0.0, shield_time - delta)

    var lp: Dictionary = _level_params(current_level)
    var armor_scale: float = _player_armor_scale()
    if shield_time > 0.0:
        armor_scale *= 0.4
    _apply_player_damage(float(lp["dot_dps"]) * _enemy_dot_mult() * armor_scale * delta, Vector2(_frontline_x() - 20.0, FLOOR_Y - 140.0))

func _spawn_loop(delta: float) -> void:
    if battle_completed:
        return
    spawn_timer -= delta
    if _should_spawn_boss_immediately():
        _spawn_boss_for_level(current_level)
        boss_spawned = true
        boss_alive = true
        spawn_timer = 2.0
        return
    if spawn_timer > 0.0:
        return

    var lp: Dictionary = _level_params(current_level)
    var regular_count: int = int(lp["regular_count"])

    if regular_spawned < regular_count:
        if spawn_group_remaining <= 0:
            var remaining: int = regular_count - regular_spawned
            spawn_group_size = randi_range(1, min(3, remaining))
            spawn_group_remaining = spawn_group_size
            spawn_group_spawned = 0
            spawn_group_spacing = randf_range(70.0, 104.0)
            spawn_group_anchor_x = _next_enemy_spawn_x() + randf_range(180.0, 360.0)

        var local_jitter: float = randf_range(-12.0, 12.0)
        var spawn_x: float = spawn_group_anchor_x + float(spawn_group_spawned) * spawn_group_spacing + local_jitter
        _spawn_enemy_cluster_for_level(current_level, spawn_x)
        regular_spawned += 1
        spawn_group_spawned += 1
        spawn_group_remaining -= 1
        if spawn_group_remaining > 0:
            spawn_timer = randf_range(0.2, 0.34)
        else:
            spawn_timer = randf_range(1.2, 1.9)
        return

    if not boss_spawned:
        _spawn_boss_for_level(current_level)
        boss_spawned = true
        boss_alive = true
        spawn_timer = 2.0
        return

func _should_spawn_boss_immediately() -> bool:
    if boss_spawned or battle_completed:
        return false
    var lp: Dictionary = _level_params(current_level)
    var regular_count: int = int(lp["regular_count"])
    if regular_spawned < regular_count:
        return false
    return _living_enemy_count() <= 0

func _living_enemy_count() -> int:
    var count: int = 0
    for enemy in enemies:
        if _is_enemy_targetable(enemy):
            count += 1
    return count

func _roll_multi_spawn_count() -> int:
    var roll: float = randf()
    if roll < MULTI_SPAWN_TRIPLE_CHANCE:
        return 3
    if roll < MULTI_SPAWN_TRIPLE_CHANCE + MULTI_SPAWN_DOUBLE_CHANCE:
        return 2
    return 1

func _spawn_enemy_cluster_for_level(level_index: int, spawn_x: float) -> void:
    var spawn_count: int = _roll_multi_spawn_count()
    var stack_id: int = 0
    if spawn_count > 1:
        stack_id = next_enemy_stack_id
        next_enemy_stack_id += 1
    for i in range(spawn_count):
        var stacked_x: float = spawn_x + float(i) * MULTI_SPAWN_STACK_OFFSET_X
        _spawn_enemy_for_level(level_index, stacked_x, stack_id)

func _spawn_heroes() -> void:
    var roster: Array[String] = ["knight"]
    if SaveHandler.has_fishing_upgrade("recruit_archer"):
        roster.append("archer")
    if SaveHandler.has_fishing_upgrade("recruit_guardian"):
        roster.append("guardian")
    if SaveHandler.has_fishing_upgrade("recruit_mage"):
        roster.append("mage")

    for i in range(roster.size()):
        var hero_name: String = roster[i]
        var hero: CombatSprite = HERO_SCENE.instantiate()
        hero.position = Vector2(HERO_START_X + HERO_FRAME_SIZE.x * HERO_RENDER_SCALE - float(i) * HERO_FORMATION_SPACING, FLOOR_Y)
        var hero_visual: Dictionary = hero_sheets[hero_name]
        hero.setup(hero_visual["sheet"], hero_visual["frame"], float(hero_visual.get("scale", HERO_RENDER_SCALE)), hero_name)
        hero.set_sway_range(-5.0, 5.0)
        hero.clicked.connect(_on_hero_clicked.bind(hero_name))
        hero_layer.add_child(hero)
        heroes.append(hero)

        var damage: float = 12.0 + 3.0 * float(SaveHandler.get_fishing_upgrade_level("core_%s_damage" % hero_name))
        var speed: float = 1.2 + 0.16 * float(SaveHandler.get_fishing_upgrade_level("core_%s_speed" % hero_name))
        damage *= _hero_damage_mult(hero_name)
        if hero_name == "archer":
            damage *= 0.33333334
        elif hero_name == "knight":
            damage *= 1.2
        speed *= _hero_speed_mult(hero_name)
        hero_data[hero] = {
            "name": hero_name,
            "damage": damage,
            "speed": speed,
            "range": _hero_attack_range(hero_name),
            "cooldown": 0.0,
            "walk_speed": 80.0 * _walk_speed_mult(),
            "active_charge": 0.0,
            "active_time_remaining": 0.0,
            "active_time_total": 0.0,
            "active_cooldown_total": 0.0,
            "active_bar_back": null,
            "active_bar_fill": null,
            "active_bar_width": 0.0,
            "mage_active_tick": (MAGE_BASE_ATTACK_INTERVAL * MAGE_BASE_SPEED) / max(0.1, speed),
            "mage_idle_mark_cd": (MAGE_BASE_ATTACK_INTERVAL * MAGE_BASE_SPEED) / max(0.1, speed),
        }
        _add_hero_active_bar(hero)

func _spawn_enemy_for_level(level_index: int, spawn_x_override: float = NAN, stack_id: int = 0) -> void:
    var key: String = _enemy_key_for_level(level_index)
    var lp: Dictionary = _level_params(level_index)
    var data: Dictionary = enemy_defs[key]
    var elite_mult: float = _roll_enemy_variant_multiplier()

    var enemy: CombatSprite = HERO_SCENE.instantiate()
    var spawn_x: float = spawn_x_override if not is_nan(spawn_x_override) else _next_enemy_spawn_x()
    enemy.position = Vector2(spawn_x, FLOOR_Y)
    var enemy_scale: float = float(data.get("scale", ENEMY_RENDER_SCALE)) * elite_mult
    enemy.setup(data["sheet"], data["frame"], enemy_scale)
    enemy.set_sway_range(-5.0, 5.0)
    enemy.set_sprite_tint(_enemy_tint_for_level(level_index))
    enemy_layer.add_child(enemy)
    enemies.append(enemy)

    var hp: float = float(lp["enemy_hp"]) * _enemy_hp_mult() * elite_mult
    var bar_data: Dictionary = _add_health_bar(enemy, data["frame"], enemy_scale)
    var reward_mult: float = _level_reward_mult(level_index)
    enemy_data[enemy] = {
        "type": key,
        "is_boss": false,
        "is_elite": elite_mult > 1.0,
        "stack_id": stack_id,
        "hp": hp,
        "hp_max": hp,
        "speed": float(data["speed"]),
        "contact_dps": float(lp["enemy_contact_dps"]) * _enemy_contact_mult() * elite_mult,
        "coins": max(1, int(round(float(data["coins"]) * reward_mult * ENEMY_COIN_VALUE_MULT))),
        "attack_cd": 0.0,
        "bar_back": bar_data["back"],
        "bar_fill": bar_data["fill"],
        "bar_width": bar_data["width"],
        "bar_offset": bar_data["offset"],
    }

func _spawn_boss_for_level(level_index: int) -> void:
    var lp: Dictionary = _level_params(level_index)
    var data: Dictionary = enemy_defs["boss"]

    var enemy: CombatSprite = HERO_SCENE.instantiate()
    enemy.position = Vector2(_next_enemy_spawn_x() + 120.0, FLOOR_Y)
    var boss_scale: float = float(data.get("scale", BOSS_RENDER_SCALE))
    enemy.setup(data["sheet"], data["frame"], boss_scale)
    enemy.set_sway_range(-5.0, 5.0)
    enemy.set_sprite_tint(_enemy_tint_for_level(level_index))
    enemy_layer.add_child(enemy)
    enemies.append(enemy)

    var hp: float = float(lp["boss_hp"]) * _boss_hp_mult()
    var bar_data: Dictionary = _add_health_bar(enemy, data["frame"], boss_scale)
    var reward_mult: float = _level_reward_mult(level_index)
    var boss_coin_value: int = max(1, int(round(float(data["coins"]) * reward_mult * ENEMY_COIN_VALUE_MULT)))
    enemy_data[enemy] = {
        "type": "boss",
        "is_boss": true,
        "is_elite": false,
        "stack_id": 0,
        "hp": hp,
        "hp_max": hp,
        "segments_total": BOSS_SEGMENTS,
        "segments_broken": 0,
        "segment_reward": max(1, int(round(float(boss_coin_value) / float(BOSS_SEGMENTS)))),
        "speed": float(data["speed"]),
        "contact_dps": float(lp["boss_contact_dps"]) * _enemy_contact_mult() * _boss_contact_mult(),
        "coins": boss_coin_value,
        "attack_cd": 0.0,
        "bar_back": bar_data["back"],
        "bar_fill": bar_data["fill"],
        "bar_width": bar_data["width"],
        "bar_offset": bar_data["offset"],
    }

func _roll_enemy_variant_multiplier() -> float:
    return ELITE_ENEMY_MULT if randf() < ELITE_ENEMY_CHANCE else 1.0

func _make_asset_actor(sheet_path: String, fallback_frame: Vector2i, fallback_color: Color, fallback_archetype: String, scale_factor: float, facing_left: bool = false) -> Dictionary:
    var loaded: Texture2D = load(sheet_path) as Texture2D
    if loaded != null:
        var frame_w: int = loaded.get_width() / 3
        var frame_h: int = loaded.get_height()
        if frame_w > 0 and frame_w * 3 == loaded.get_width() and frame_h > 0:
            return {
                "sheet": loaded,
                "frame": Vector2i(frame_w, frame_h),
                "scale": scale_factor,
            }
    return {
        "sheet": _make_actor_sheet(fallback_frame, fallback_color, Color(0.92, 0.92, 0.92, 1.0), fallback_archetype, facing_left),
        "frame": fallback_frame,
        "scale": scale_factor,
    }

func _make_pack_actor(walk_a_path: String, walk_b_path: String, attack_path: String, fallback_frame: Vector2i, fallback_color: Color, fallback_archetype: String, scale_factor: float, facing_left: bool = false) -> Dictionary:
    var composed: Dictionary = _compose_three_frame_sheet_from_files([walk_a_path, walk_b_path, attack_path])
    if composed.size() > 0:
        composed["scale"] = scale_factor
        return composed
    return {
        "sheet": _make_actor_sheet(fallback_frame, fallback_color, Color(0.92, 0.92, 0.92, 1.0), fallback_archetype, facing_left),
        "frame": fallback_frame,
        "scale": scale_factor,
    }

func _make_pack_actor_from_textures(walk_a_tex: Texture2D, walk_b_tex: Texture2D, attack_tex: Texture2D, fallback_frame: Vector2i, fallback_color: Color, fallback_archetype: String, scale_factor: float, facing_left: bool = false) -> Dictionary:
    var composed: Dictionary = _compose_three_frame_sheet_from_textures([walk_a_tex, walk_b_tex, attack_tex])
    if composed.size() > 0:
        composed["scale"] = scale_factor
        return composed
    return {
        "sheet": _make_actor_sheet(fallback_frame, fallback_color, Color(0.92, 0.92, 0.92, 1.0), fallback_archetype, facing_left),
        "frame": fallback_frame,
        "scale": scale_factor,
    }

func _compose_three_frame_sheet_from_files(frame_paths: Array[String]) -> Dictionary:
    if frame_paths.size() != 3:
        return {}

    var frames: Array[Image] = []
    var max_w: int = 0
    var max_h: int = 0
    for frame_path in frame_paths:
        var img: Image = _load_pack_image(str(frame_path))
        if img == null or img.is_empty():
            return {}
        frames.append(img)
        max_w = max(max_w, img.get_width())
        max_h = max(max_h, img.get_height())

    if max_w <= 0 or max_h <= 0:
        return {}

    var sheet: Image = Image.create(max_w * 3, max_h, false, Image.FORMAT_RGBA8)
    sheet.fill(Color(0, 0, 0, 0))
    for i in range(3):
        var src: Image = frames[i]
        var dx: int = i * max_w + int((max_w - src.get_width()) / 2)
        var dy: int = int((max_h - src.get_height()) / 2)
        sheet.blit_rect(src, Rect2i(0, 0, src.get_width(), src.get_height()), Vector2i(dx, dy))

    return {
        "sheet": ImageTexture.create_from_image(sheet),
        "frame": Vector2i(max_w, max_h),
    }

func _compose_three_frame_sheet_from_textures(frame_textures: Array) -> Dictionary:
    if frame_textures.size() != 3:
        return {}

    var frames: Array[Image] = []
    var max_w: int = 0
    var max_h: int = 0
    for tex_variant in frame_textures:
        var tex: Texture2D = tex_variant
        if tex == null:
            return {}
        var img: Image = tex.get_image()
        if img == null or img.is_empty():
            return {}
        if img.get_format() != Image.FORMAT_RGBA8:
            img.convert(Image.FORMAT_RGBA8)
        frames.append(img)
        max_w = max(max_w, img.get_width())
        max_h = max(max_h, img.get_height())

    if max_w <= 0 or max_h <= 0:
        return {}

    var sheet: Image = Image.create(max_w * 3, max_h, false, Image.FORMAT_RGBA8)
    sheet.fill(Color(0, 0, 0, 0))
    for i in range(3):
        var src: Image = frames[i]
        var dx: int = i * max_w + int((max_w - src.get_width()) / 2)
        var dy: int = int((max_h - src.get_height()) / 2)
        sheet.blit_rect(src, Rect2i(0, 0, src.get_width(), src.get_height()), Vector2i(dx, dy))

    return {
        "sheet": ImageTexture.create_from_image(sheet),
        "frame": Vector2i(max_w, max_h),
    }

func _add_health_bar(enemy: CombatSprite, frame_size: Vector2i, scale_factor: float) -> Dictionary:
    var bar_width: float = max(28.0, float(frame_size.x) * scale_factor * 0.82)
    var back: ColorRect = ColorRect.new()
    back.color = Color(0.1, 0.1, 0.1, 0.9)
    var bar_offset := Vector2(-bar_width * 0.5, -float(frame_size.y) * scale_factor - 24.0)
    back.position = bar_offset
    back.size = Vector2(bar_width, 10)
    back.top_level = true
    enemy.add_child(back)

    var fill: ColorRect = ColorRect.new()
    fill.color = Color(0.85, 0.2, 0.2, 1.0)
    fill.position = Vector2.ZERO
    fill.size = back.size
    back.add_child(fill)

    return {
        "back": back,
        "fill": fill,
        "width": bar_width,
        "offset": bar_offset,
    }

func _update_heroes(delta: float) -> void:
    var frontline_x: float = _frontline_x()
    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        var h: Dictionary = hero_data[hero]
        h["active_time_remaining"] = max(0.0, float(h.get("active_time_remaining", 0.0)) - delta)
        _update_hero_active_bar(hero, h)
        h["cooldown"] = max(0.0, float(h["cooldown"]) - delta)
        var hero_name: String = str(h["name"])
        var should_catch_up: bool = hero_name == "archer" and hero.position.x < frontline_x - HERO_FORMATION_SPACING

        var target: CombatSprite = _nearest_enemy(hero.position)
        if hero_name == "archer":
            target = _nearest_enemy_on_screen(hero.position)
        elif hero_name == "mage":
            target = _nearest_enemy_in_touch_camera_area(hero.position)
        if target == null:
            var no_target_mult: float = ARCHER_NO_TARGET_ADVANCE_MULT if hero_name == "archer" else 1.0
            hero.position.x += float(h["walk_speed"]) * no_target_mult * delta
            hero.set_walking()
            hero_data[hero] = h
            continue

        var dist: float = hero.position.distance_to(target.position)
        if should_catch_up:
            hero.position.x += float(h["walk_speed"]) * 1.2 * delta
            hero.set_walking()
            hero_data[hero] = h
            continue

        if hero_name == "mage":
            var active_remaining: float = float(h.get("active_time_remaining", 0.0))
            if active_remaining > 0.0:
                var mage_tick_interval: float = _mage_attack_interval(h)
                var mage_tick: float = float(h.get("mage_active_tick", mage_tick_interval)) - delta
                while mage_tick <= 0.0:
                    _damage_enemies_in_touch_camera_area(float(h.get("damage", 0.0)) * MAGE_ACTIVE_TICK_DAMAGE_MULT, true)
                    mage_tick += mage_tick_interval
                h["mage_active_tick"] = mage_tick
                if dist > float(h["range"]):
                    hero.position.x += float(h["walk_speed"]) * delta
                    hero.set_walking()
                else:
                    hero.set_walking()
            else:
                var mage_interval: float = _mage_attack_interval(h)
                var mage_idle_cd: float = max(0.0, float(h.get("mage_idle_mark_cd", mage_interval)) - delta)
                h["mage_idle_mark_cd"] = mage_idle_cd
                if mage_idle_cd <= 0.0:
                    var random_enemy: CombatSprite = _random_enemy_in_touch_camera_area()
                    if is_instance_valid(random_enemy):
                        h["mage_idle_mark_cd"] = mage_interval
                        _queue_mage_marked_strike(random_enemy, float(h.get("damage", 0.0)) * MAGE_IDLE_STRIKE_MULT)
                if dist > float(h["range"]):
                    hero.position.x += float(h["walk_speed"]) * delta
                    hero.set_walking()
                else:
                    hero.set_walking()
            hero_data[hero] = h
            continue

        if dist > float(h["range"]):
            hero.position.x += float(h["walk_speed"]) * delta
            hero.set_walking()
        elif float(h["cooldown"]) <= 0.0:
            h["cooldown"] = 1.0 / max(0.1, float(h["speed"]))
            var attack_damage: float = float(h["damage"])
            var active_remaining2: float = float(h.get("active_time_remaining", 0.0))
            if active_remaining2 > 0.0:
                match hero_name:
                    "knight":
                        attack_damage *= 1.35
                    "archer":
                        attack_damage *= 2.0
            if hero_name == "archer":
                var arrow_spawn: Vector2 = hero.position + Vector2(28.0, -8.0)
                if hero.has_method("get_projectile_spawn_point"):
                    arrow_spawn = hero.call("get_projectile_spawn_point")
                # determine whether the arrow should pierce based on the archer's active state
                var pierce_arrow: bool = active_remaining2 > 0.0
                _spawn_arrow(arrow_spawn, target, attack_damage, pierce_arrow)
            else:
                _damage_enemy(target, attack_damage)
            hero.trigger_attack()

        hero_data[hero] = h

    _enforce_hero_formation()

func _enforce_hero_formation() -> void:
    if heroes.is_empty():
        return

    var front_x: float = HERO_START_X
    var knight: CombatSprite = heroes[0]
    if is_instance_valid(knight):
        front_x = max(front_x, knight.position.x)
        knight.position.x = front_x

    for i in range(1, heroes.size()):
        var hero: CombatSprite = heroes[i]
        if not is_instance_valid(hero):
            continue
        var prev: CombatSprite = heroes[i - 1]
        if not is_instance_valid(prev):
            continue

        var max_x: float = prev.position.x - HERO_FORMATION_SPACING
        hero.position.x = min(hero.position.x, max_x)

func _spawn_arrow(from_pos: Vector2, target_enemy: CombatSprite, damage: float, pierce: bool=false) -> void:
    if projectile_layer == null or arrow_texture == null:
        return
    if not is_instance_valid(target_enemy):
        return
    var sprite: Sprite2D = Sprite2D.new()
    sprite.texture = arrow_texture
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.centered = true
    sprite.scale = Vector2.ONE * 3.0
    sprite.position = from_pos
    projectile_layer.add_child(sprite)

    var target_pos: Vector2 = target_enemy.position + Vector2(0.0, -18.0)
    var dir: Vector2 = (target_pos - from_pos).normalized()
    if dir == Vector2.ZERO:
        dir = Vector2.RIGHT
    sprite.rotation = dir.angle()

    arrows.append({
        "sprite": sprite,
        "dir": dir,
        "target_id": target_enemy.get_instance_id(),
        "target_pos": target_pos,
        "damage": damage,
        "speed": 420.0,
        # piercing arrows linger longer so they can cross the whole battlefield
        "ttl": (8.0 if pierce else 4.0),
        "pierce": pierce,
        # keep track of enemies already struck so piercing shots don't hit them multiple times
        "hit_ids": [],
    })

func _update_arrows(delta: float) -> void:
    for i in range(arrows.size() - 1, -1, -1):
        var arrow: Dictionary = arrows[i]
        var sprite: Sprite2D = arrow.get("sprite", null)
        if sprite == null or not is_instance_valid(sprite):
            arrows.remove_at(i)
            continue

        var ttl: float = float(arrow.get("ttl", 0.0)) - delta
        if ttl <= 0.0:
            sprite.queue_free()
            arrows.remove_at(i)
            continue

        var is_piercing: bool = bool(arrow.get("pierce", false))
        var dir: Vector2 = arrow.get("dir", Vector2.RIGHT)
        var speed: float = float(arrow.get("speed", 420.0))

        if not is_piercing:
            # non-piercing arrows home in on a target as before
            var target_enemy: CombatSprite = null
            var target_id: int = int(arrow.get("target_id", 0))
            if target_id > 0:
                var target_obj: Object = instance_from_id(target_id)
                if target_obj != null and is_instance_valid(target_obj):
                    target_enemy = target_obj as CombatSprite
            if not is_instance_valid(target_enemy):
                target_enemy = _nearest_enemy(sprite.position)
                if is_instance_valid(target_enemy):
                    arrow["target_id"] = target_enemy.get_instance_id()
            var target_pos: Vector2 = arrow.get("target_pos", sprite.position)
            if is_instance_valid(target_enemy):
                target_pos = target_enemy.position + Vector2(0.0, -18.0)
            elif target_pos == sprite.position:
                sprite.queue_free()
                arrows.remove_at(i)
                continue

            var to_target: Vector2 = target_pos - sprite.position
            if to_target.length() > 4.0:
                dir = to_target.normalized()
            sprite.rotation = dir.angle()
            sprite.position += dir * speed * delta

            arrow["dir"] = dir
            arrow["ttl"] = ttl
            arrows[i] = arrow

            if sprite.position.distance_to(target_pos) <= 22.0:
                if is_instance_valid(target_enemy):
                    var tid: int = target_enemy.get_instance_id()
                    var hit_ids: Array = arrow.get("hit_ids", [])
                    if not hit_ids.has(tid):
                        _damage_enemy(target_enemy, float(arrow.get("damage", 0.0)), false, "archer_arrow")
                        hit_ids.append(tid)
                        arrow["hit_ids"] = hit_ids
                # non-piercing always expire on hit
                sprite.queue_free()
                arrows.remove_at(i)
            continue
        else:
            # piercing arrow: maintain its direction and check every enemy along its path
            sprite.rotation = dir.angle()
            sprite.position += dir * speed * delta
            arrow["ttl"] = ttl
            arrows[i] = arrow

            # collision with any enemy not yet struck
            for enemy in enemies:
                if is_instance_valid(enemy):
                    var tid2: int = enemy.get_instance_id()
                    var hit_ids2: Array = arrow.get("hit_ids", [])
                    if not hit_ids2.has(tid2):
                        var enemy_pos: Vector2 = enemy.position + Vector2(0.0, -18.0)
                        if sprite.position.distance_to(enemy_pos) <= 22.0:
                            _damage_enemy(enemy, float(arrow.get("damage", 0.0)), false, "archer_pierce")
                            hit_ids2.append(tid2)
                            arrow["hit_ids"] = hit_ids2
            # continue flying until ttl expires
            continue

func _update_enemies(delta: float) -> void:
    var armor_scale: float = _player_armor_scale()
    if shield_time > 0.0:
        armor_scale *= 0.4

    var frontline_x: float = _frontline_x()
    var alive_sorted: Array[CombatSprite] = []
    for enemy in enemies:
        if _is_enemy_targetable(enemy):
            alive_sorted.append(enemy)
    alive_sorted.sort_custom(func(a: CombatSprite, b: CombatSprite): return a.position.x < b.position.x)
    var front_map: Dictionary = {}
    var behind_map: Dictionary = {}
    for i in range(alive_sorted.size() - 1):
        front_map[alive_sorted[i + 1]] = alive_sorted[i]
        behind_map[alive_sorted[i]] = alive_sorted[i + 1]

    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var e: Dictionary = enemy_data[enemy]
        if bool(e.get("defeated_falling", false)):
            var gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)) * ARROW_KILL_GRAVITY_SCALE
            e["fall_velocity_y"] = float(e.get("fall_velocity_y", 0.0)) + gravity * delta
            enemy.position.y += float(e["fall_velocity_y"]) * delta
            enemy.rotation = lerp_angle(enemy.rotation, PI * 0.5, min(1.0, delta * DEFEAT_FALL_ROT_SPEED * 2.0))
            if enemy.position.y > _character_feet_y():
                _despawn_enemy(enemy)
                continue
            enemy_data[enemy] = e
            continue
        e["attack_cd"] = max(0.0, float(e["attack_cd"]) - delta)

        var contact_front_x: float = frontline_x + _enemy_contact_reach(enemy)
        var colliding: bool = enemy.position.x <= contact_front_x
        if not colliding:
            var move_mult: float = _enemy_offscreen_speed_mult(enemy)
            if enemy_opening_rush_active:
                move_mult *= ENEMY_OPENING_RUSH_MULT
            var moved_x: float = enemy.position.x - float(e["speed"]) * move_mult * delta
            enemy.position.x = max(contact_front_x, moved_x)
            enemy.set_walking()
            if enemy_opening_rush_active and enemy.position.x <= contact_front_x:
                enemy_opening_rush_active = false
        else:
            if enemy_opening_rush_active:
                enemy_opening_rush_active = false
            if _is_leading_contact_attacker(enemy, frontline_x, front_map):
                var attackers: Array[CombatSprite] = _get_contact_attackers(enemy, behind_map)
                var total_contact_dps: float = 0.0
                for attacker in attackers:
                    var attacker_data: Dictionary = enemy_data.get(attacker, {})
                    total_contact_dps += float(attacker_data.get("contact_dps", e["contact_dps"]))
                    if float(attacker_data.get("attack_cd", 0.0)) <= 0.0:
                        attacker_data["attack_cd"] = 0.75
                        attacker.trigger_attack()
                        enemy_data[attacker] = attacker_data
                        if attacker == enemy:
                            e = attacker_data
                _apply_player_damage(total_contact_dps * armor_scale * delta, enemy.position + Vector2(0.0, -90.0))

        _update_enemy_health_bar(enemy, e)
        enemy_data[enemy] = e

    _enforce_enemy_formation()

func _enforce_enemy_formation() -> void:
    var alive: Array[CombatSprite] = []
    for enemy in enemies:
        if is_instance_valid(enemy) and _is_enemy_targetable(enemy):
            alive.append(enemy)

    if alive.size() <= 1:
        return

    alive.sort_custom(func(a: CombatSprite, b: CombatSprite): return a.position.x < b.position.x)

    for i in range(1, alive.size()):
        var lead: CombatSprite = alive[i - 1]
        var trailing: CombatSprite = alive[i]
        var min_x: float = lead.position.x + _enemy_pair_spacing(lead, trailing)
        if trailing.position.x < min_x:
            trailing.position.x = min_x

func _enemy_contact_reach(enemy: CombatSprite) -> float:
    return max(6.0, _enemy_body_width(enemy) * 0.5)

func _is_leading_contact_attacker(enemy: CombatSprite, frontline_x: float, front_map: Dictionary) -> bool:
    var front_enemy: CombatSprite = front_map.get(enemy, null)
    if not is_instance_valid(front_enemy):
        return true
    var front_contact_x: float = frontline_x + _enemy_contact_reach(front_enemy)
    if front_enemy.position.x > front_contact_x:
        return true
    return not _enemies_are_stacked_for_contact(front_enemy, enemy)

func _get_contact_attackers(front_enemy: CombatSprite, behind_map: Dictionary) -> Array[CombatSprite]:
    var attackers: Array[CombatSprite] = []
    attackers.append(front_enemy)
    var current: CombatSprite = front_enemy
    while attackers.size() < MAX_STACKED_CONTACT_ATTACKERS:
        var behind_enemy: CombatSprite = behind_map.get(current, null)
        if not is_instance_valid(behind_enemy):
            break
        if not _enemies_are_stacked_for_contact(current, behind_enemy):
            break
        attackers.append(behind_enemy)
        current = behind_enemy
    return attackers

func _enemies_are_stacked_for_contact(front_enemy: CombatSprite, back_enemy: CombatSprite) -> bool:
    if not is_instance_valid(front_enemy) or not is_instance_valid(back_enemy):
        return false
    var gap: float = back_enemy.position.x - front_enemy.position.x
    var support_gap: float = _enemy_pair_spacing(front_enemy, back_enemy)
    return gap <= support_gap * 1.05

func _enemy_pair_spacing(front_enemy: CombatSprite, back_enemy: CombatSprite) -> float:
    var front_width: float = _enemy_body_width(front_enemy)
    var back_width: float = _enemy_body_width(back_enemy)
    var base_spacing: float = max(8.0, (front_width + back_width) * 0.5)
    if enemy_data.has(front_enemy) and enemy_data.has(back_enemy):
        var front_stack_id: int = int(enemy_data[front_enemy].get("stack_id", 0))
        var back_stack_id: int = int(enemy_data[back_enemy].get("stack_id", 0))
        if front_stack_id != 0 and front_stack_id == back_stack_id:
            return max(8.0, base_spacing * STACKED_ENEMY_SPACING_MULT)
    return base_spacing

func _enemy_body_width(enemy: CombatSprite) -> float:
    if not is_instance_valid(enemy):
        return ENEMY_FORMATION_SPACING
    if enemy.collider != null and enemy.collider.shape is CircleShape2D:
        var circle: CircleShape2D = enemy.collider.shape as CircleShape2D
        if circle != null:
            return max(12.0, circle.radius * 2.0)
    if enemy.sprite != null and enemy.sprite.sprite_frames != null:
        var frame_tex: Texture2D = enemy.sprite.sprite_frames.get_frame_texture("walk", 0)
        if frame_tex != null:
            var frame_w: float = float(frame_tex.get_width())
            return max(12.0, frame_w * enemy.base_sprite_scale.x * 0.9)
    return ENEMY_FORMATION_SPACING

func _update_enemy_health_bar(enemy: CombatSprite, e: Dictionary) -> void:
    var bar_back: ColorRect = e.get("bar_back", null)
    var bar_fill: ColorRect = e.get("bar_fill", null)
    if not is_instance_valid(enemy) or not is_instance_valid(bar_back) or not is_instance_valid(bar_fill):
        return
    bar_back.global_position = enemy.global_position + e.get("bar_offset", Vector2.ZERO)
    var pct: float = clamp(float(e["hp"]) / max(1.0, float(e["hp_max"])), 0.0, 1.0)
    bar_fill.size.x = float(e.get("bar_width", 84.0)) * pct

func _update_camera_and_parallax() -> void:
    if heroes.is_empty():
        return
    var leader: CombatSprite = heroes[0]
    if not is_instance_valid(leader):
        return

    var viewport_w: float = get_viewport_rect().size.x
    var anchor_x_world: float = leader.position.x + viewport_w * (0.5 - HERO_SCROLL_ANCHOR_SCREEN_X_FACTOR)
    if SaveHandler.touch_input_mode:
        anchor_x_world -= touch_camera_left_shift
    camera_2d.position.x = anchor_x_world

    bg_deep.position.x = camera_2d.position.x * 0.08
    cloud_far.position.x = camera_2d.position.x * 0.22
    bg_far.position.x = camera_2d.position.x * 0.22
    cloud_mid.position.x = camera_2d.position.x * 0.42
    bg_mid.position.x = camera_2d.position.x * 0.42
    cloud_near.position.x = camera_2d.position.x * 0.66
    bg_near.position.x = camera_2d.position.x * 0.66
    ground.position.x = camera_2d.position.x * 0.9
    ground_overlay.position.x = camera_2d.position.x * 0.9

func _nearest_enemy(from_pos: Vector2) -> CombatSprite:
    var best: CombatSprite = null
    var best_dist: float = INF
    for enemy in enemies:
        if not _is_enemy_targetable(enemy):
            continue
        var d: float = from_pos.distance_to(enemy.position)
        if d < best_dist:
            best_dist = d
            best = enemy
    return best

func _random_enemy() -> CombatSprite:
    var alive: Array[CombatSprite] = []
    for enemy in enemies:
        if _is_enemy_targetable(enemy):
            alive.append(enemy)
    if alive.is_empty():
        return null
    return alive[randi() % alive.size()]

func _enemy_offscreen_speed_mult(enemy: CombatSprite) -> float:
    if not is_instance_valid(enemy) or camera_2d == null:
        return 1.0
    var touch_area: Rect2 = _touch_camera_world_rect()
    if touch_area.size.x <= 0.0 or touch_area.size.y <= 0.0:
        return 1.0
    var enemy_rect: Rect2 = _enemy_world_rect(enemy)
    var inside_count: int = _enemy_count_in_touch_camera_area(touch_area)
    if inside_count > 0:
        return 1.0
    return ENEMY_OFFSCREEN_SPEEDUP_MAX_MULT if not enemy_rect.intersects(touch_area) else 1.0

func _touch_camera_world_rect() -> Rect2:
    var viewport_size: Vector2 = get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return Rect2()
    var touch_zoom: Vector2 = Vector2(0.2, 0.2) * EXTRA_ZOOM_IN_FACTOR * TOUCH_CAMERA_ZOOM_MULT
    var center_x: float = camera_2d.position.x
    if SaveHandler.touch_input_mode:
        center_x = camera_2d.position.x
    else:
        center_x -= touch_camera_left_shift
    if not heroes.is_empty():
        var leader: CombatSprite = heroes[0]
        if is_instance_valid(leader):
            center_x = leader.position.x + viewport_size.x * (0.5 - HERO_SCROLL_ANCHOR_SCREEN_X_FACTOR) - touch_camera_left_shift
    var size: Vector2 = Vector2(
        viewport_size.x / max(0.001, touch_zoom.x),
        viewport_size.y / max(0.001, touch_zoom.y)
    )
    return Rect2(Vector2(center_x, camera_2d.position.y) - size * 0.5, size)

func _enemy_world_rect(enemy: CombatSprite) -> Rect2:
    var body_half_width: float = _enemy_body_width(enemy) * 0.5
    var body_half_height: float = _enemy_body_width(enemy) * 0.5
    return Rect2(
        enemy.position - Vector2(body_half_width, body_half_height),
        Vector2(body_half_width * 2.0, body_half_height * 2.0)
    )

func _enemy_count_in_touch_camera_area(touch_area: Rect2) -> int:
    if touch_area.size.x <= 0.0 or touch_area.size.y <= 0.0:
        return 0
    var count: int = 0
    for visible_enemy in enemies:
        if not _is_enemy_targetable(visible_enemy):
            continue
        if _enemy_world_rect(visible_enemy).intersects(touch_area):
            count += 1
    return count

func _is_world_pos_on_screen(world_pos: Vector2) -> bool:
    var viewport_rect: Rect2 = get_viewport_rect()
    var screen_pos: Vector2 = get_viewport().get_canvas_transform() * world_pos
    return screen_pos.x >= 0.0 and screen_pos.y >= 0.0 \
        and screen_pos.x <= viewport_rect.size.x and screen_pos.y <= viewport_rect.size.y

func _enemies_on_screen() -> Array[CombatSprite]:
    var visible: Array[CombatSprite] = []
    for enemy in enemies:
        if not _is_enemy_targetable(enemy):
            continue
        if _is_world_pos_on_screen(enemy.position):
            visible.append(enemy)
    return visible

func _nearest_enemy_on_screen(from_pos: Vector2) -> CombatSprite:
    var best: CombatSprite = null
    var best_dist: float = INF
    for enemy in enemies:
        if not _is_enemy_targetable(enemy):
            continue
        if not _is_world_pos_on_screen(enemy.position):
            continue
        var d: float = from_pos.distance_to(enemy.position)
        if d < best_dist:
            best_dist = d
            best = enemy
    return best

func _random_enemy_on_screen() -> CombatSprite:
    var visible: Array[CombatSprite] = _enemies_on_screen()
    if visible.is_empty():
        return null
    return visible[randi() % visible.size()]

func _enemies_in_touch_camera_area() -> Array[CombatSprite]:
    var visible: Array[CombatSprite] = []
    var touch_area: Rect2 = _touch_camera_world_rect()
    if touch_area.size.x <= 0.0 or touch_area.size.y <= 0.0:
        return visible
    for enemy in enemies:
        if not _is_enemy_targetable(enemy):
            continue
        if _enemy_world_rect(enemy).intersects(touch_area):
            visible.append(enemy)
    return visible

func _nearest_enemy_in_touch_camera_area(from_pos: Vector2) -> CombatSprite:
    var best: CombatSprite = null
    var best_dist: float = INF
    for enemy in _enemies_in_touch_camera_area():
        var d: float = from_pos.distance_to(enemy.position)
        if d < best_dist:
            best_dist = d
            best = enemy
    return best

func _random_enemy_in_touch_camera_area() -> CombatSprite:
    var visible: Array[CombatSprite] = _enemies_in_touch_camera_area()
    if visible.is_empty():
        return null
    return visible[randi() % visible.size()]

func _random_enemy_in_touch_camera_area_excluding(excluded_ids: Array[int]) -> CombatSprite:
    var excluded: Dictionary = {}
    for enemy_id in excluded_ids:
        excluded[int(enemy_id)] = true
    var visible: Array[CombatSprite] = []
    for enemy in _enemies_in_touch_camera_area():
        if excluded.has(enemy.get_instance_id()):
            continue
        visible.append(enemy)
    if visible.is_empty():
        return null
    return visible[randi() % visible.size()]

func _damage_all_enemies(amount: float) -> void:
    if amount <= 0.0:
        return
    var targets: Array[CombatSprite] = []
    for enemy in enemies:
        if _is_enemy_targetable(enemy):
            targets.append(enemy)
    for enemy in targets:
        _damage_enemy(enemy, amount)

func _damage_enemies_on_screen(amount: float) -> void:
    if amount <= 0.0:
        return
    var targets: Array[CombatSprite] = _enemies_on_screen()
    for enemy in targets:
        _damage_enemy(enemy, amount)

func _damage_enemies_in_touch_camera_area(amount: float, is_mage_attack: bool = false) -> void:
    if amount <= 0.0:
        return
    var targets: Array[CombatSprite] = _enemies_in_touch_camera_area()
    for enemy in targets:
        _damage_enemy(enemy, amount, is_mage_attack)

func _queue_mage_marked_strike(enemy: CombatSprite, damage: float) -> void:
    if not is_instance_valid(enemy) or damage <= 0.0:
        return
    var enemy_id: int = enemy.get_instance_id()
    var windup: float = _mage_strike_windup()
    mage_pending_strikes.append({
        "target_id": enemy_id,
        "time_left": windup,
        "damage": damage,
    })
    var existing: float = float(enemy_mark_timers.get(enemy_id, 0.0))
    enemy_mark_timers[enemy_id] = max(existing, windup)
    _trigger_mage_attack_animation(0.5)

func _queue_mage_followup_strike(excluded_ids: Array[int], damage: float) -> void:
    var next_enemy: CombatSprite = _random_enemy_in_touch_camera_area_excluding(excluded_ids)
    if is_instance_valid(next_enemy):
        _queue_mage_marked_strike(next_enemy, damage)

func _trigger_mage_attack_animation(strength: float = 1.0) -> void:
    for hero in heroes:
        if not is_instance_valid(hero) or not hero_data.has(hero):
            continue
        var h: Dictionary = hero_data[hero]
        if str(h.get("name", "")) == "mage":
            hero.trigger_attack(strength, true)
            return

func _update_mage_pending_strikes(delta: float) -> void:
    var mage_time_scale: float = _mage_attack_time_scale()
    var marked_keys: Array = enemy_mark_timers.keys().duplicate()
    for i in range(marked_keys.size() - 1, -1, -1):
        var enemy_id: int = int(marked_keys[i])
        var enemy_obj: Object = instance_from_id(enemy_id)
        if enemy_obj == null or not is_instance_valid(enemy_obj):
            enemy_mark_timers.erase(enemy_id)
            continue
        var remaining: float = max(0.0, float(enemy_mark_timers[enemy_id]) - delta * mage_time_scale)
        if remaining <= 0.0:
            enemy_mark_timers.erase(enemy_id)
        else:
            enemy_mark_timers[enemy_id] = remaining

    for i in range(mage_pending_strikes.size() - 1, -1, -1):
        var pending: Dictionary = mage_pending_strikes[i]
        var remaining_hit_time: float = float(pending.get("time_left", 0.0)) - delta * mage_time_scale
        pending["time_left"] = remaining_hit_time
        if remaining_hit_time > 0.0:
            mage_pending_strikes[i] = pending
            continue

        var target_id: int = int(pending.get("target_id", 0))
        var target_obj: Object = instance_from_id(target_id)
        if target_obj == null or not is_instance_valid(target_obj):
            mage_pending_strikes.remove_at(i)
            _queue_mage_followup_strike([target_id], float(pending.get("damage", 0.0)))
            continue

        var target_enemy: CombatSprite = target_obj as CombatSprite
        if not is_instance_valid(target_enemy) or not enemy_data.has(target_enemy):
            mage_pending_strikes.remove_at(i)
            _queue_mage_followup_strike([target_id], float(pending.get("damage", 0.0)))
            continue

        if float(enemy_mark_timers.get(target_id, 0.0)) > 0.0 and float(enemy_data.get(target_enemy, {}).get("hp", 0.0)) <= 0.0:
            mage_pending_strikes.remove_at(i)
            _queue_mage_followup_strike([target_id], float(pending.get("damage", 0.0)))
            continue

        if is_instance_valid(target_enemy):
            _trigger_mage_attack_animation(1.0)
            _damage_enemy(target_enemy, float(pending.get("damage", 0.0)), true)
        mage_pending_strikes.remove_at(i)

func _mage_attack_interval(hero_state: Dictionary) -> float:
    return ((MAGE_BASE_ATTACK_INTERVAL * MAGE_BASE_SPEED) / max(0.1, float(hero_state.get("speed", 1.0)))) / _mage_attack_time_scale(hero_state)

func _mage_strike_windup(hero_state: Dictionary = {}) -> float:
    return MAGE_IDLE_STRIKE_WINDUP / _mage_attack_time_scale(hero_state)

func _mage_attack_time_scale(hero_state: Dictionary = {}) -> float:
    if not hero_state.is_empty():
        return MAGE_ACTIVE_SPEED_MULT if float(hero_state.get("active_time_remaining", 0.0)) > 0.0 else 1.0
    return MAGE_ACTIVE_SPEED_MULT if _is_hero_active("mage") else 1.0

func _flash_enemy_red(enemy: CombatSprite) -> void:
    if not is_instance_valid(enemy):
        return
    var base_modulate: Color = enemy.self_modulate
    var flash_modulate: Color = base_modulate.lerp(Color(1.0, 0.0, 0.0, base_modulate.a), MAGE_HIT_FLASH_BLEND)
    var tween: Tween = create_tween()
    tween.tween_property(enemy, "self_modulate", flash_modulate, 0.01).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
    tween.tween_interval(MAGE_HIT_FLASH_DURATION - 0.02)
    tween.tween_property(enemy, "self_modulate", base_modulate, 0.01).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func _spawn_mage_lightning_bolt(world_pos: Vector2) -> void:
    if damage_text_layer == null:
        return
    var bolt: Node2D = Node2D.new()
    bolt.position = world_pos + Vector2(0.0, -82.0)

    var core: Line2D = Line2D.new()
    core.width = 5.0
    core.default_color = Color(1.0, 0.15, 0.15, 1.0)
    core.antialiased = false
    core.begin_cap_mode = Line2D.LINE_CAP_ROUND
    core.end_cap_mode = Line2D.LINE_CAP_ROUND
    core.points = PackedVector2Array([
        Vector2(-2.0, -14.0),
        Vector2(6.0, -5.0),
        Vector2(0.0, -5.0),
        Vector2(7.0, 8.0),
        Vector2(-7.0, 1.0),
        Vector2(-1.0, 1.0),
        Vector2(-8.0, 14.0),
    ])
    bolt.add_child(core)

    var glow: Line2D = Line2D.new()
    glow.width = 9.0
    glow.default_color = Color(1.0, 0.45, 0.45, 0.35)
    glow.antialiased = false
    glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
    glow.end_cap_mode = Line2D.LINE_CAP_ROUND
    glow.points = core.points
    bolt.add_child(glow)

    damage_text_layer.add_child(bolt)
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(bolt, "scale", Vector2.ONE * 1.1, MAGE_LIGHTNING_DURATION)
    tween.tween_property(bolt, "modulate:a", 0.0, MAGE_LIGHTNING_DURATION)
    tween.finished.connect(func() -> void:
        if is_instance_valid(bolt):
            bolt.queue_free()
    )

func _update_active_visual_effects(_delta: float) -> void:
    var guardian_active: bool = false if battle_completed else _is_hero_active("guardian")
    var pulse: float = 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.012)

    if guardian_active:
        var hero_glow_color: Color = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(0.66, 0.89, 1.32, 1.0), pulse)
        for hero in heroes:
            if is_instance_valid(hero):
                hero.modulate = hero_glow_color
        if health_bar != null:
            health_bar.modulate = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(0.58, 0.84, 1.25, 1.0), pulse)
        guardian_glow_was_active = true
    elif guardian_glow_was_active:
        for hero in heroes:
            if is_instance_valid(hero):
                hero.modulate = Color(1.0, 1.0, 1.0, 1.0)
        if health_bar != null:
            health_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)
        guardian_glow_was_active = false

    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var mark_remaining: float = max(0.0, float(enemy_mark_timers.get(enemy.get_instance_id(), 0.0)))
        var mark_intensity: float = 0.0
        var mark_windup: float = max(0.001, _mage_strike_windup())
        if mark_remaining > 0.0:
            mark_intensity = clamp(1.0 - (mark_remaining / mark_windup), 0.0, 1.0)
        if mark_intensity <= 0.0:
            enemy.modulate = Color(1.0, 1.0, 1.0, 1.0)
        else:
            var mark_tint_strength: float = lerpf(MAGE_MARK_TINT_START, MAGE_MARK_TINT_END, mark_intensity)
            var mark_color: Color = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(1.0, 0.0, 0.0, 1.0), mark_tint_strength)
            enemy.modulate = mark_color

func _is_hero_active(hero_name: String) -> bool:
    for hero in heroes:
        if not is_instance_valid(hero) or not hero_data.has(hero):
            continue
        var h: Dictionary = hero_data[hero]
        if str(h.get("name", "")) != hero_name:
            continue
        if float(h.get("active_time_remaining", 0.0)) > 0.0:
            return true
    return false

func _frontline_x() -> float:
    var x_val: float = HERO_START_X
    for hero in heroes:
        if is_instance_valid(hero):
            x_val = max(x_val, hero.position.x)
    return x_val

func _front_enemy_spawn_x() -> float:
    return _frontline_x() + 1300.0

func _next_enemy_spawn_x() -> float:
    var spawn_x: float = _front_enemy_spawn_x()
    var max_existing_x: float = -INF
    for enemy in enemies:
        if is_instance_valid(enemy):
            max_existing_x = max(max_existing_x, enemy.position.x)
    if max_existing_x > -INF:
        spawn_x = max(spawn_x, max_existing_x + ENEMY_FORMATION_SPACING)
    return spawn_x

func _damage_enemy(enemy: CombatSprite, amount: float, is_mage_attack: bool = false, kill_source: String = "") -> bool:
    if not is_instance_valid(enemy) or not enemy_data.has(enemy):
        return false
    var e: Dictionary = enemy_data[enemy]
    if bool(e.get("defeated_falling", false)):
        return false
    var prev_hp: float = float(e["hp"])
    e["hp"] = prev_hp - amount
    var dealt_damage: float = max(0.0, min(amount, prev_hp))
    if is_mage_attack and dealt_damage > 0.0:
        _flash_enemy_red(enemy)
        _spawn_mage_lightning_bolt(enemy.position)
    _apply_knight_vamp_heal(dealt_damage, enemy.position + Vector2(randf_range(-10.0, 10.0), -130.0))
    _spawn_floating_damage_text(enemy.position + Vector2(randf_range(-14.0, 14.0), -120.0), amount, Color(1.0, 0.84, 0.56, 1.0))
    if bool(e.get("is_boss", false)):
        _award_boss_segments(enemy, e, prev_hp)
    enemy_data[enemy] = e
    if float(e["hp"]) <= 0.0:
        _kill_enemy(enemy, kill_source)
        return true
    return false

func _is_knight_active() -> bool:
    for hero in heroes:
        if not is_instance_valid(hero) or not hero_data.has(hero):
            continue
        var h: Dictionary = hero_data[hero]
        if str(h.get("name", "")) != "knight":
            continue
        return float(h.get("active_time_remaining", 0.0)) > 0.0
    return false

func _apply_knight_vamp_heal(damage_dealt: float, heal_text_world_pos: Vector2) -> void:
    if damage_dealt <= 0.0 or not _is_knight_active():
        return
    var before_hp: float = player_health
    player_health = min(300.0, player_health + damage_dealt * 0.18)
    var healed: float = max(0.0, player_health - before_hp)
    if healed > 0.0:
        _spawn_floating_heal_text(heal_text_world_pos, healed)

func _award_boss_segments(enemy: CombatSprite, e: Dictionary, prev_hp: float) -> void:
    var hp_max: float = max(1.0, float(e.get("hp_max", 1.0)))
    var segments_total: int = int(e.get("segments_total", BOSS_SEGMENTS))
    var current_hp: float = max(0.0, float(e.get("hp", 0.0)))
    var prev_progress: float = clamp(1.0 - (prev_hp / hp_max), 0.0, 1.0)
    var new_progress: float = clamp(1.0 - (current_hp / hp_max), 0.0, 1.0)
    var prev_segments: int = int(floor(prev_progress * float(segments_total)))
    var new_segments: int = int(floor(new_progress * float(segments_total)))
    var newly_broken: int = max(0, new_segments - prev_segments)
    if newly_broken <= 0:
        return

    var reward_each: int = int(e.get("segment_reward", 1))
    for i in range(newly_broken):
        _spawn_scaled_coin(enemy.position + Vector2(0.0, -16.0), reward_each)
    e["segments_broken"] = int(e.get("segments_broken", 0)) + newly_broken
    boss_segments_broken += newly_broken

func _kill_enemy(enemy: CombatSprite, kill_source: String = "") -> void:
    print("DEBUG: _kill_enemy() called")
    if not enemy_data.has(enemy):
        return
    var e: Dictionary = enemy_data[enemy]
    var enemy_id: int = enemy.get_instance_id()
    if not bool(e.get("is_boss", false)):
        _spawn_split_coin_reward(enemy.position, int(e["coins"]))

    _gain_power(4.0 * _power_gain_mult())
    enemies_killed += 1

    if bool(e["is_boss"]):
        boss_alive = false
        _on_boss_defeated()
    else:
        regular_killed += 1

    enemy_mark_timers.erase(enemy_id)
    for i in range(mage_pending_strikes.size() - 1, -1, -1):
        if int(mage_pending_strikes[i].get("target_id", 0)) == enemy_id:
            mage_pending_strikes.remove_at(i)
    # Play enemy defeat / shoot SFX
    # AudioManager is available as a global autoload, not an engine singleton
    print("[AUDIO] Enemy defeated - playing BUTTON_CLICK")
    _play_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
    if kill_source == "archer_arrow" and not bool(e.get("is_boss", false)):
        _start_enemy_arrow_fall(enemy, e)
        return
    _despawn_enemy(enemy)

func _start_enemy_arrow_fall(enemy: CombatSprite, e: Dictionary) -> void:
    enemy.set_defeated()
    _clear_enemy_health_bar(e)
    e["defeated_falling"] = true
    e["fall_velocity_y"] = 0.0
    enemy_data[enemy] = e

func _clear_enemy_health_bar(e: Dictionary) -> void:
    var back: ColorRect = e.get("bar_back", null)
    var fill: ColorRect = e.get("bar_fill", null)
    if is_instance_valid(fill):
        fill.queue_free()
    if is_instance_valid(back):
        back.queue_free()
    e["bar_back"] = null
    e["bar_fill"] = null

func _despawn_enemy(enemy: CombatSprite) -> void:
    if not is_instance_valid(enemy):
        return
    enemies.erase(enemy)
    if enemy_data.has(enemy):
        var e: Dictionary = enemy_data[enemy]
        _clear_enemy_health_bar(e)
        enemy_data.erase(enemy)
    enemy.queue_free()

func _is_enemy_targetable(enemy: CombatSprite) -> bool:
    if not is_instance_valid(enemy) or not enemy_data.has(enemy):
        return false
    return not bool(enemy_data[enemy].get("defeated_falling", false))

func _combat_sprite_half_height(sprite: CombatSprite) -> float:
    if not is_instance_valid(sprite):
        return 0.0
    if sprite.collider != null and sprite.collider.shape is CircleShape2D:
        var circle: CircleShape2D = sprite.collider.shape as CircleShape2D
        if circle != null:
            return max(6.0, circle.radius)
    if sprite.sprite != null and sprite.sprite.sprite_frames != null:
        var frame_tex: Texture2D = sprite.sprite.sprite_frames.get_frame_texture("walk", 0)
        if frame_tex != null:
            return max(6.0, float(frame_tex.get_height()) * sprite.base_sprite_scale.y * 0.5)
    return 12.0

func _character_feet_y() -> float:
    var feet_y: float = FLOOR_Y
    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        feet_y = max(feet_y, hero.position.y + _combat_sprite_half_height(hero))
    return feet_y

func _spawn_scaled_coin(pos: Vector2, base_value: int) -> void:
    var scaled_value: int = max(1, int(round(float(base_value) * _coin_mult())))
    _spawn_coin(pos, scaled_value)

func _spawn_split_coin_reward(pos: Vector2, base_total_value: int) -> void:
    var total_value: int = max(1, int(round(float(base_total_value) * _coin_mult())))
    var coin_count: int = randi_range(SPLIT_REWARD_MIN_COINS, SPLIT_REWARD_MAX_COINS)
    coin_count = min(coin_count, total_value)
    var split_values: Array[int] = _split_int_value(total_value, coin_count)
    for split_value in split_values:
        _spawn_coin(pos, split_value)

func _split_int_value(total: int, count: int) -> Array[int]:
    var safe_total: int = max(1, total)
    var safe_count: int = max(1, count)
    safe_count = min(safe_count, safe_total)
    var values: Array[int] = []
    var base_value: int = safe_total / safe_count
    var remainder: int = safe_total % safe_count
    for i in range(safe_count):
        values.append(base_value)
    var indexes: Array[int] = []
    for i in range(safe_count):
        indexes.append(i)
    indexes.shuffle()
    for i in range(remainder):
        values[indexes[i]] += 1
    return values

func _spawn_coin(pos: Vector2, value: int, force_full_circle: bool = false, spawn_offset: Vector2 = Vector2.ZERO) -> void:
    var coin: CoinPickup = COIN_SCENE.instantiate()
    var spawn_jitter: Vector2 = Vector2(randf_range(-24.0, 24.0), randf_range(-26.0, 14.0))
    if force_full_circle and spawn_offset.length() > 0.0:
        # Keep UFO coin spew offset down-path so hover pickup cannot trigger instantly.
        spawn_jitter = Vector2(0.0, randf_range(-14.0, 14.0))
    coin.position = pos + spawn_offset + spawn_jitter
    var gravity: float = max(1.0, float(coin.flight_gravity))
    var screen_height: float = max(1.0, get_viewport_rect().size.y)
    var max_height_px: float = screen_height * COIN_LAUNCH_MAX_HEIGHT_SCREENS
    var max_speed: float = sqrt(2.0 * gravity * max_height_px)
    var min_speed: float = max_speed * COIN_LAUNCH_MIN_SPEED_RATIO
    var launch_speed: float = randf_range(min_speed, max_speed) * 0.5

    var launch_dir: Vector2
    if force_full_circle:
        launch_dir = Vector2.RIGHT.rotated(randf() * TAU)
    else:
        var nearest_hero_x: float = _nearest_hero_x(coin.position.x)
        var away_sign: float = sign(coin.position.x - nearest_hero_x)
        if is_zero_approx(away_sign):
            away_sign = 1.0

        var toward_roll: bool = randf() < COIN_LAUNCH_TOWARD_CHANCE
        var lateral_sign: float = away_sign if not toward_roll else -away_sign
        var deviation_deg: float = 0.0
        if toward_roll:
            deviation_deg = randf_range(0.0, COIN_LAUNCH_TOWARD_MAX_DEG)
        else:
            deviation_deg = randf_range(0.0, COIN_LAUNCH_AWAY_MAX_DEG)
        var theta: float = deg_to_rad(deviation_deg)
        launch_dir = Vector2(sin(theta) * lateral_sign, -cos(theta))
    coin.launch(launch_dir * launch_speed, coin_landing_y)
    coin.value = max(1, value)
    coin.collected.connect(_on_coin_collected)
    coin_layer.add_child(coin)
    coins.append(coin)
    coin_ages[coin] = 0.0

func _nearest_hero_x(from_x: float) -> float:
    var found: bool = false
    var nearest_x: float = from_x
    var nearest_dist: float = INF
    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        var d: float = absf(hero.position.x - from_x)
        if d < nearest_dist:
            nearest_dist = d
            nearest_x = hero.position.x
            found = true
    if found:
        return nearest_x
    return _frontline_x()

func _update_coins(delta: float) -> void:
    _resolve_coin_collisions()
    var viewport_size: Vector2 = get_viewport_rect().size
    var half_w: float = viewport_size.x * 0.5
    var half_h: float = viewport_size.y * 0.5
    var min_x: float = camera_2d.position.x - half_w - COIN_DESPAWN_MARGIN_X
    var max_x: float = camera_2d.position.x + half_w + COIN_DESPAWN_MARGIN_X
    var min_y: float = camera_2d.position.y - half_h - COIN_DESPAWN_MARGIN_Y
    var max_y: float = camera_2d.position.y + half_h + COIN_DESPAWN_MARGIN_Y
    # Iterate backwards to safely remove items
    for i in range(coins.size() - 1, -1, -1):
        var coin = coins[i]
        if not is_instance_valid(coin):
            coins.remove_at(i)
            coin_ages.erase(coin)
            continue
        var coin_age: float = float(coin_ages.get(coin, 0.0)) + max(0.0, delta)
        coin_ages[coin] = coin_age
        if coin.position.y < min_y:
            coin.position.y = min_y
            if coin.velocity.y < 0.0:
                coin.velocity.y = 0.0
        if coin.position.x < min_x or coin.position.x > max_x or coin.position.y > max_y:
            coins.remove_at(i)
            coin_ages.erase(coin)
            coin.queue_free()
            continue
        if coin_age < HERO_COIN_PICKUP_DELAY:
            continue
        for hero in heroes:
            if is_instance_valid(hero) and hero.position.distance_to(coin.position) <= 70.0:
                coin.collect_by_hero()
                break

func _resolve_coin_collisions() -> void:
    var coin_count: int = coins.size()
    if coin_count <= 1:
        return
    for i in range(coin_count):
        var coin_a: CoinPickup = coins[i]
        if not is_instance_valid(coin_a):
            continue
        for j in range(i + 1, coin_count):
            var coin_b: CoinPickup = coins[j]
            if not is_instance_valid(coin_b):
                continue
            var radius_sum: float = max(2.0, coin_a.physics_radius + coin_b.physics_radius)
            var offset: Vector2 = coin_b.position - coin_a.position
            var dist: float = offset.length()
            if dist >= radius_sum:
                continue
            var normal: Vector2 = Vector2.RIGHT
            if dist > 0.001:
                normal = offset / dist
            else:
                normal = Vector2.from_angle(randf() * TAU)
            var penetration: float = radius_sum - dist
            coin_a.position -= normal * penetration * 0.5
            coin_b.position += normal * penetration * 0.5

            var relative_velocity: Vector2 = coin_b.velocity - coin_a.velocity
            var speed_along_normal: float = relative_velocity.dot(normal)
            if speed_along_normal >= 0.0:
                continue
            var impulse: float = -(1.0 + COIN_COLLISION_RESTITUTION) * speed_along_normal * 0.5
            coin_a.velocity -= normal * impulse
            coin_b.velocity += normal * impulse

func _cursor_bonus_mult() -> float:
    var mult: float = 1.0
    if SaveHandler.has_fishing_upgrade("cursor_pickup_unlock"):
        mult += 0.5
    if SaveHandler.has_fishing_upgrade("power_harvest_unlock"):
        mult += 0.5
    if SaveHandler.has_fishing_upgrade("field_magnet"):
        mult += 0.2
    if SaveHandler.has_fishing_upgrade("supply_lenses"):
        mult += 0.2
    mult += float(battle_mods.get("cursor_bonus", 0.0))
    return mult

func _on_coin_collected(coin: CoinPickup, by_cursor: bool) -> void:
    print("DEBUG: _on_coin_collected() called")
    if not is_instance_valid(coin):
        return
    var collected_by_cursor: bool = by_cursor
    if in_infinite_simulation:
        collected_by_cursor = randf() < INFINITE_SIM_CURSOR_COLLECT_SHARE
    var amount: int = int(coin.value)
    if collected_by_cursor:
        amount = int(round(float(amount) * _cursor_bonus_mult()))

    # Play coin pickup SFX - use 2D positional audio
    print("[AUDIO] Coin collected - playing 2D audio at coin position")
    AudioManager.create_2d_audio_at_location(coin.position, SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

    SaveHandler.fishing_currency += amount
    SaveHandler.fishing_lifetime_coins += amount
    SaveHandler.save_fishing_progress()
    coins_gained += amount
    _spawn_floating_currency_text(coin.position + Vector2(randf_range(-10.0, 10.0), -20.0), amount)

    # Remove from array using indexed removal
    for i in range(coins.size()):
        if coins[i] == coin:
            coins.remove_at(i)
            break
    coin_ages.erase(coin)
    coin.queue_free()
    if battle_completed:
        _update_ui()
        _refresh_battle_summary_text()

func _restore_or_reset_ufo_spawn_timer() -> void:
    var saved_remaining: float = float(SaveHandler.fishing_ufo_spawn_timer_remaining)
    if saved_remaining > 0.0:
        ufo_spawn_timer = saved_remaining
    else:
        _reset_ufo_spawn_timer()

func _reset_ufo_spawn_timer() -> void:
    ufo_spawn_timer = randf_range(UFO_SPAWN_MIN_SECONDS, UFO_SPAWN_MAX_SECONDS)
    SaveHandler.fishing_ufo_spawn_timer_remaining = ufo_spawn_timer

func _update_ufo_event(delta: float) -> void:
    if battle_completed or summary_panel.visible:
        return
    if in_infinite_simulation:
        return
    if is_instance_valid(active_ufo):
        return
    var speed_mult: float = _speed_multiplier_for_runtime()
    var safe_engine_scale: float = max(0.001, Engine.time_scale)
    var adjusted_delta: float = (max(0.0, delta) / safe_engine_scale) * speed_mult
    ufo_spawn_timer -= adjusted_delta
    SaveHandler.fishing_ufo_spawn_timer_remaining = ufo_spawn_timer
    if ufo_spawn_timer <= 0.0:
        _spawn_ufo(false)

func _spawn_ufo(is_manual: bool) -> void:
    if is_instance_valid(active_ufo):
        return
    if world == null:
        return
    var ufo := UfoBonus.new()
    if ufo == null:
        return
    var viewport_size: Vector2 = get_viewport_rect().size
    var half_w: float = viewport_size.x * 0.5
    var half_h: float = viewport_size.y * 0.5
    var spawn_from_left: bool = randf() < 0.5
    var start_x: float = camera_2d.position.x - half_w - UFO_SPAWN_MARGIN_X
    var end_x: float = camera_2d.position.x + half_w + UFO_SPAWN_MARGIN_X
    if not spawn_from_left:
        start_x = camera_2d.position.x + half_w + UFO_SPAWN_MARGIN_X
        end_x = camera_2d.position.x - half_w - UFO_SPAWN_MARGIN_X
    var y: float = _ufo_spawn_y_for_current_layout(camera_2d.position.y - half_h)
    ufo.configure(start_x, end_x, y, UFO_TRAVEL_SECONDS, _ufo_reward_value())
    ufo.collected.connect(_on_ufo_collected)
    ufo.tree_exited.connect(_on_ufo_exited.bind(ufo))
    coin_layer.add_child(ufo)
    active_ufo = ufo
    _reset_ufo_spawn_timer()
    if is_manual:
        print("DEBUG: Manual UFO spawned.")

func _ufo_spawn_y_for_current_layout(top_of_viewport_y: float) -> float:
    var cloud_band_bottom: float = maxf(
        maxf(cloud_far.position.y if cloud_far != null else CLOUD_FAR_BASE_Y, cloud_mid.position.y if cloud_mid != null else CLOUD_MID_BASE_Y),
        cloud_near.position.y if cloud_near != null else CLOUD_NEAR_BASE_Y
    )
    var min_y: float = cloud_band_bottom + UFO_CLOUD_OFFSET_MIN
    var max_y: float = cloud_band_bottom + UFO_CLOUD_OFFSET_MAX
    var viewport_bottom_limit: float = top_of_viewport_y + get_viewport_rect().size.y * 0.42
    min_y = minf(min_y, viewport_bottom_limit)
    max_y = minf(maxf(min_y, max_y), viewport_bottom_limit)
    return randf_range(min_y, max_y)

func _speed_multiplier_for_runtime() -> float:
    var safe_idx: int = clamp(speed_index, 0, _max_available_speed_index())
    return SPEED_STEPS[safe_idx]

func _apply_speed_index(new_index: int, persist: bool) -> void:
    var clamped_index: int = clamp(new_index, 0, _max_available_speed_index())
    speed_index = clamped_index
    Engine.time_scale = SPEED_STEPS[speed_index]
    _update_speed_button_text()
    if persist and SaveHandler.fishing_battle_speed_index != speed_index:
        SaveHandler.fishing_battle_speed_index = speed_index
        SaveHandler.save_fishing_progress()

func _max_available_speed_index() -> int:
    if OS.has_feature("editor"):
        return SPEED_STEPS.size() - 1
    var speed_unlock_level: int = SaveHandler.get_fishing_upgrade_level(SPEED_UNLOCK_KEY)
    return clamp(speed_unlock_level, 0, MAX_RELEASE_SPEED_LEVEL)

func _on_ufo_collected(ufo: UfoBonus) -> void:
    if not is_instance_valid(ufo):
        return
    var worth_count: int = randi_range(UFO_REWARD_MIN_ENEMY_WORTH, UFO_REWARD_MAX_ENEMY_WORTH)
    var per_enemy_value: int = max(1, int(round(float(ufo.reward_value) / float(UFO_REWARD_ENEMY_MULT))))
    var total_amount: int = max(1, per_enemy_value * worth_count)
    var split_values: Array[int] = _split_int_value(total_amount, worth_count)
    var path_sign: float = sign(ufo.direction_sign)
    if is_zero_approx(path_sign):
        path_sign = 1.0
    var spawn_offset: Vector2 = Vector2(path_sign * UFO_COIN_PATH_OFFSET, 0.0)
    for split_value in split_values:
        _spawn_coin(ufo.position, split_value, true, spawn_offset)
    AudioManager.create_2d_audio_at_location(ufo.position, SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
    _spawn_floating_damage_text(ufo.position + Vector2(0.0, -48.0), total_amount, Color(0.55, 0.94, 1.0, 1.0), "+")
    if active_ufo == ufo:
        active_ufo = null

func _on_ufo_exited(ufo: UfoBonus) -> void:
    if active_ufo == ufo:
        active_ufo = null

func _ufo_reward_value() -> int:
    var key: String = _enemy_key_for_level(current_level)
    var data: Dictionary = enemy_defs.get(key, enemy_defs.get("goblin", {}))
    var base_enemy_value: int = max(
        1,
        int(round(float(data.get("coins", 10)) * _level_reward_mult(current_level) * ENEMY_COIN_VALUE_MULT))
    )
    var scaled_enemy_value: int = max(1, int(round(float(base_enemy_value) * _coin_mult())))
    return scaled_enemy_value * UFO_REWARD_ENEMY_MULT

func _max_power() -> float:
    var cap: float = 100.0
    cap += 10.0 * float(SaveHandler.get_fishing_upgrade_level("core_knight_active_cap"))
    cap += 10.0 * float(SaveHandler.get_fishing_upgrade_level("core_archer_active_cap"))
    cap += 10.0 * float(SaveHandler.get_fishing_upgrade_level("core_guardian_active_cap"))
    cap += 10.0 * float(SaveHandler.get_fishing_upgrade_level("core_mage_active_cap"))
    cap += float(battle_mods.get("power_cap_bonus", 0.0))
    return cap

func _on_hero_clicked(hero: CombatSprite, hero_name: String, skip_anim: bool = false) -> void:
    var unlock_key: String = _active_unlock_key(hero_name)
    if unlock_key == "" or not SaveHandler.has_fishing_upgrade(unlock_key):
        return
    if not hero_data.has(hero):
        return
    var h: Dictionary = hero_data[hero]
    var cooldown_remaining: float = float(active_cooldowns.get(hero_name, 0.0))
    if cooldown_remaining > 0.0:
        hero_data[hero] = h
        return

    var active_cost: float = _active_cost()
    var charge: float = float(h.get("active_charge", 0.0))
    var to_charge: float = min(ACTIVE_CHARGE_PER_CLICK, power, max(0.0, active_cost - charge))
    if to_charge > 0.0:
        power -= to_charge
        charge += to_charge
        h["active_charge"] = charge
        _update_hero_active_bar(hero, h)

    if charge + 0.001 < active_cost:
        hero_data[hero] = h
        return

    h["active_charge"] = max(0.0, charge - active_cost)
    h["active_cooldown_total"] = float(ACTIVE_COOLDOWNS.get(hero_name, 15.0)) * _active_cooldown_mult()
    _update_hero_active_bar(hero, h)
    hero_data[hero] = h
    _execute_hero_active(hero, hero_name, skip_anim)
    active_cooldowns[hero_name] = float(h.get("active_cooldown_total", 0.0))

func _gain_power(amount: float) -> void:
    if amount <= 0.0:
        return
    power = min(_max_power(), power + amount)

func _active_unlock_key(hero_name: String) -> String:
    return {
        "knight": "knight_vamp_unlock",
        "archer": "archer_pierce_unlock",
        "guardian": "guardian_fortify_unlock",
        "mage": "mage_storm_unlock",
    }.get(hero_name, "")

func _add_hero_active_bar(hero: CombatSprite) -> void:
    if not is_instance_valid(hero) or not hero_data.has(hero):
        return
    var bar_back: ColorRect = ColorRect.new()
    bar_back.color = Color(0.2, 0.2, 0.2, 0.85)
    var bar_offset := Vector2(-22.0, -122.0)
    bar_back.position = bar_offset
    bar_back.size = Vector2(44.0, 6.0)
    bar_back.visible = false
    bar_back.top_level = true
    hero.add_child(bar_back)

    var bar_fill: ColorRect = ColorRect.new()
    bar_fill.color = Color(0.25, 0.95, 0.45, 1.0)
    bar_fill.position = Vector2.ZERO
    bar_fill.size = bar_back.size
    bar_back.add_child(bar_fill)

    var h: Dictionary = hero_data[hero]
    h["active_bar_back"] = bar_back
    h["active_bar_fill"] = bar_fill
    h["active_bar_width"] = bar_back.size.x
    h["active_bar_offset"] = bar_offset
    hero_data[hero] = h
    _update_hero_active_bar(hero, h)

func _update_hero_active_bar(hero: CombatSprite, h: Dictionary) -> void:
    if not is_instance_valid(hero):
        return
    var hero_name: String = str(h.get("name", ""))
    var unlock_key: String = _active_unlock_key(hero_name)
    var unlocked: bool = unlock_key != "" and SaveHandler.has_fishing_upgrade(unlock_key)

    var bar_back: ColorRect = h.get("active_bar_back", null)
    var bar_fill: ColorRect = h.get("active_bar_fill", null)
    if not is_instance_valid(bar_back) or not is_instance_valid(bar_fill):
        return

    bar_back.global_position = hero.global_position + h.get("active_bar_offset", Vector2.ZERO)
    bar_back.visible = unlocked and not battle_completed
    if not unlocked:
        bar_fill.size.x = 0.0
        return

    var full_width: float = float(h.get("active_bar_width", 44.0))
    var active_remaining: float = max(0.0, float(h.get("active_time_remaining", 0.0)))
    var active_total: float = max(0.001, float(h.get("active_time_total", 0.0)))
    if active_remaining > 0.0:
        bar_fill.color = Color(0.25, 0.95, 0.45, 1.0)
        bar_fill.size.x = full_width * clamp(active_remaining / active_total, 0.0, 1.0)
        return

    var cooldown_remaining: float = float(active_cooldowns.get(hero_name, 0.0))
    if cooldown_remaining > 0.0:
        var cooldown_total: float = max(0.001, float(h.get("active_cooldown_total", cooldown_remaining)))
        var cooldown_pct: float = clamp(cooldown_remaining / cooldown_total, 0.0, 1.0)
        var pulse_t: float = 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.01)
        bar_fill.color = Color(0.05, 0.05, 0.05, 1.0).lerp(Color(1.0, 0.12, 0.72, 1.0), pulse_t)
        bar_fill.size.x = full_width * cooldown_pct
        return

    var active_cost: float = max(1.0, _active_cost())
    var charge: float = clamp(float(h.get("active_charge", 0.0)), 0.0, active_cost)
    bar_fill.color = Color(0.25, 0.95, 0.45, 1.0)
    bar_fill.size.x = full_width * (charge / active_cost)

func _execute_hero_active(hero: CombatSprite, hero_name: String, skip_anim: bool) -> void:
    _trigger_hero_glow(hero)
    # Play chime when a hero's powerup ability starts
    _play_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_POP_IN)
    if not skip_anim:
        hero.trigger_attack()

    var h: Dictionary = hero_data.get(hero, {})
    var active_duration: float = _active_duration(hero_name)
    if active_duration > 0.0 and not h.is_empty():
        h["active_time_total"] = active_duration
        h["active_time_remaining"] = active_duration
        if hero_name == "mage":
            h["mage_active_tick"] = _mage_attack_interval(h)
            h["mage_idle_mark_cd"] = _mage_attack_interval(h)
        hero_data[hero] = h

    match hero_name:
        "knight":
            pass
        "archer":
            # fire a special pierce projectile as the active ability
            var target: CombatSprite = _nearest_enemy_on_screen(hero.position)
            if target != null:
                var arrow_spawn: Vector2 = hero.position + Vector2(28.0, -8.0)
                if hero.has_method("get_projectile_spawn_point"):
                    arrow_spawn = hero.call("get_projectile_spawn_point")
                # use hero's actual damage value (with active multiplier applied during normal attacks)
                var pierce_damage: float = float(h.get("damage", 4.0))
                _spawn_arrow(arrow_spawn, target, pierce_damage, true)
        "guardian":
            shield_time = max(shield_time, active_duration)
        "mage":
            pass

func _active_duration(hero_name: String) -> float:
    var base: float = float(ACTIVE_DURATIONS.get(hero_name, 2.0))
    # As active/cadence upgrades reduce cooldown, also grant modest duration scaling.
    var cd_improvement: float = max(0.0, 1.0 - _active_cooldown_mult())
    return base + (cd_improvement * 2.2)

func _level_params(level_index: int) -> Dictionary:
    var lv: int = level_index - 1
    var regular_count: int = int(round((24 + 8 * lv) * _enemy_count_mult()))
    return {
        "regular_count": max(8, regular_count),
        "enemy_hp": 45.0 * pow(1.60, lv),
        "enemy_contact_dps": 7.0 * pow(1.45, lv),
        "dot_dps": 2.2 * pow(1.33, lv),
        "boss_hp": (45.0 * pow(1.60, lv)) * (14.0 + 2.5 * level_index),
        "boss_contact_dps": (7.0 * pow(1.45, lv)) * 2.8,
    }

func _level_reward_mult(level_index: int) -> float:
    var lv: int = max(1, level_index) - 1
    return 1.0 + 1.25 * lv + 0.15 * lv * lv

func _max_unlocked_level() -> int:
    return clamp(int(SaveHandler.fishing_max_unlocked_battle_level), 1, SaveHandler.MAX_FISHING_BATTLE_LEVEL)

func _rebuild_battle_mods() -> void:
    battle_mods = {
        "damage_mult_all": 1.0,
        "speed_mult_all": 1.0,
        "walk_speed_mult": 1.0,
        "enemy_hp_mult": 1.0,
        "enemy_contact_mult": 1.0,
        "enemy_dot_mult": 1.0,
        "boss_hp_mult": 1.0,
        "boss_contact_mult": 1.0,
        "coin_mult": 1.0,
        "cursor_bonus": 0.0,
        "power_gain_mult": 1.0,
        "power_cap_bonus": 0.0,
        "active_cost_mult": 1.0,
        "active_cd_mult": 1.0,
        "armor_bonus": 0.0,
        "enemy_count_mult": 1.0,
    }

    var unlocked: Dictionary = SaveHandler.fishing_unlocked_upgrades
    for key_variant in unlocked.keys():
        var key: String = str(key_variant)
        var level: int = int(unlocked[key_variant])
        _apply_upgrade_key_modifiers(key, level)

    # Global tuning pass to keep run-over-run gains incremental.
    battle_mods["damage_mult_all"] = 1.0 + (float(battle_mods["damage_mult_all"]) - 1.0) * float(UPGRADE_EFFECT_TUNE["damage"])
    battle_mods["speed_mult_all"] = 1.0 + (float(battle_mods["speed_mult_all"]) - 1.0) * float(UPGRADE_EFFECT_TUNE["speed"])
    battle_mods["walk_speed_mult"] = 1.0 + (float(battle_mods["walk_speed_mult"]) - 1.0) * float(UPGRADE_EFFECT_TUNE["walk"])
    battle_mods["coin_mult"] = 1.0 + (float(battle_mods["coin_mult"]) - 1.0) * float(UPGRADE_EFFECT_TUNE["coin"])
    battle_mods["power_gain_mult"] = 1.0 + (float(battle_mods["power_gain_mult"]) - 1.0) * float(UPGRADE_EFFECT_TUNE["power_gain"])
    battle_mods["power_cap_bonus"] = float(battle_mods["power_cap_bonus"]) * float(UPGRADE_EFFECT_TUNE["power_cap"])
    battle_mods["armor_bonus"] = float(battle_mods["armor_bonus"]) * float(UPGRADE_EFFECT_TUNE["armor"])
    battle_mods["enemy_count_mult"] = 1.0 + (float(battle_mods["enemy_count_mult"]) - 1.0) * float(UPGRADE_EFFECT_TUNE["enemy_count"])

    var active_cost_reduction: float = 1.0 - float(battle_mods["active_cost_mult"])
    battle_mods["active_cost_mult"] = 1.0 - active_cost_reduction * float(UPGRADE_EFFECT_TUNE["active_cost"])
    battle_mods["active_cost_mult"] = clamp(float(battle_mods["active_cost_mult"]), 0.55, 1.0)
    var active_cd_reduction: float = 1.0 - float(battle_mods["active_cd_mult"])
    battle_mods["active_cd_mult"] = 1.0 - active_cd_reduction * float(UPGRADE_EFFECT_TUNE["active_cd"])
    battle_mods["active_cd_mult"] = clamp(float(battle_mods["active_cd_mult"]), 0.65, 1.0)

func _apply_upgrade_key_modifiers(key: String, level: int) -> void:
    if level <= 0:
        return

    if key == "core_power":
        battle_mods["power_gain_mult"] = float(battle_mods["power_gain_mult"]) + 0.12 * level
        battle_mods["power_cap_bonus"] = float(battle_mods["power_cap_bonus"]) + 8.0 * level
        battle_mods["active_cost_mult"] = max(0.55, float(battle_mods["active_cost_mult"]) - 0.02 * level)
    elif key == "core_drop":
        battle_mods["coin_mult"] = float(battle_mods["coin_mult"]) + 0.08 * level
    elif key == "core_density":
        battle_mods["enemy_count_mult"] = float(battle_mods["enemy_count_mult"]) + 0.05 * level
        battle_mods["coin_mult"] = float(battle_mods["coin_mult"]) + 0.02 * level

    if key == "archer_pierce_unlock":
        battle_mods["damage_mult_all"] = float(battle_mods["damage_mult_all"]) + 0.04
    if key == "knight_vamp_unlock":
        battle_mods["armor_bonus"] = float(battle_mods["armor_bonus"]) + 0.03
    if key == "guardian_fortify_unlock":
        battle_mods["armor_bonus"] = float(battle_mods["armor_bonus"]) + 0.05
    if key == "mage_storm_unlock":
        battle_mods["damage_mult_all"] = float(battle_mods["damage_mult_all"]) + 0.05

    if key.begins_with("extra_skill_"):
        _apply_extra_skill_family_bonus(int(key.trim_prefix("extra_skill_")))
        return

    if key.find("knight") != -1 or key.find("archer") != -1 or key.find("guardian") != -1 or key.find("mage") != -1:
        battle_mods["damage_mult_all"] = float(battle_mods["damage_mult_all"]) + 0.012 * level
        battle_mods["speed_mult_all"] = float(battle_mods["speed_mult_all"]) + 0.009 * level
    if key.find("speed") != -1 or key.find("stride") != -1 or key.find("route") != -1 or key.find("march") != -1 or key.find("quick") != -1:
        battle_mods["walk_speed_mult"] = float(battle_mods["walk_speed_mult"]) + 0.012 * level
    if key.find("armor") != -1 or key.find("plate") != -1 or key.find("carapace") != -1 or key.find("shock") != -1 or key.find("hemostasis") != -1:
        battle_mods["armor_bonus"] = float(battle_mods["armor_bonus"]) + 0.008 * level
    if key.find("power") != -1 or key.find("condensed") != -1 or key.find("reservoir") != -1:
        battle_mods["power_gain_mult"] = float(battle_mods["power_gain_mult"]) + 0.025 * level
    if key.find("active") != -1 or key.find("invocation") != -1 or key.find("channel") != -1 or key.find("cadence") != -1:
        battle_mods["active_cd_mult"] = max(0.65, float(battle_mods["active_cd_mult"]) - 0.01 * level)
        battle_mods["active_cost_mult"] = max(0.55, float(battle_mods["active_cost_mult"]) - 0.008 * level)
    if key.find("drop") != -1 or key.find("salvage") != -1 or key.find("collector") != -1 or key.find("market") != -1 or key.find("scanner") != -1:
        battle_mods["coin_mult"] = float(battle_mods["coin_mult"]) + 0.03 * level
    if key.find("lens") != -1 or key.find("magnet") != -1:
        battle_mods["cursor_bonus"] = float(battle_mods["cursor_bonus"]) + 0.05 * level
    if key.find("boss") != -1:
        battle_mods["boss_hp_mult"] = max(0.5, float(battle_mods["boss_hp_mult"]) - 0.03 * level)
        battle_mods["coin_mult"] = float(battle_mods["coin_mult"]) + 0.02 * level
    if key.find("horde") != -1 or key.find("wave") != -1 or key.find("crowd") != -1 or key.find("pressure") != -1:
        battle_mods["enemy_count_mult"] = float(battle_mods["enemy_count_mult"]) + 0.02 * level
        battle_mods["coin_mult"] = float(battle_mods["coin_mult"]) + 0.01 * level

func _apply_extra_skill_family_bonus(index: int) -> void:
    if index <= 0:
        return
    var family: int = (index - 1) % 8
    match family:
        0:
            battle_mods["coin_mult"] = float(battle_mods["coin_mult"]) + 0.012
            battle_mods["cursor_bonus"] = float(battle_mods["cursor_bonus"]) + 0.01
        1:
            battle_mods["enemy_count_mult"] = float(battle_mods["enemy_count_mult"]) + 0.008
            battle_mods["coin_mult"] = float(battle_mods["coin_mult"]) + 0.006
        2:
            battle_mods["armor_bonus"] = float(battle_mods["armor_bonus"]) + 0.003
            battle_mods["enemy_contact_mult"] = max(0.6, float(battle_mods["enemy_contact_mult"]) - 0.002)
        3:
            battle_mods["walk_speed_mult"] = float(battle_mods["walk_speed_mult"]) + 0.004
        4:
            battle_mods["power_gain_mult"] = float(battle_mods["power_gain_mult"]) + 0.01
            battle_mods["power_cap_bonus"] = float(battle_mods["power_cap_bonus"]) + 0.5
        5:
            battle_mods["active_cd_mult"] = max(0.7, float(battle_mods["active_cd_mult"]) - 0.002)
            battle_mods["active_cost_mult"] = max(0.6, float(battle_mods["active_cost_mult"]) - 0.001)
        6:
            battle_mods["boss_hp_mult"] = max(0.55, float(battle_mods["boss_hp_mult"]) - 0.004)
        7:
            battle_mods["damage_mult_all"] = float(battle_mods["damage_mult_all"]) + 0.004
            battle_mods["speed_mult_all"] = float(battle_mods["speed_mult_all"]) + 0.003

func _hero_damage_mult(hero_name: String) -> float:
    var mult: float = float(battle_mods.get("damage_mult_all", 1.0))
    if hero_name == "archer" and SaveHandler.has_fishing_upgrade("archer_pierce_unlock"):
        mult += 0.08
    if hero_name == "mage" and SaveHandler.has_fishing_upgrade("mage_storm_unlock"):
        mult += 0.08
    return mult

func _hero_speed_mult(hero_name: String) -> float:
    var mult: float = float(battle_mods.get("speed_mult_all", 1.0))
    return mult

func _hero_attack_range(hero_name: String) -> float:
    if hero_name == "archer":
        return 4000.0
    if hero_name == "knight":
        return CONTACT_RANGE
    if hero_name == "guardian":
        return 200.0
    return 120.0

func _has_enemy_counter_unlock() -> bool:
    return SaveHandler.has_fishing_upgrade("auto_attack_unlock")

func _has_any_active_power_unlock() -> bool:
    return SaveHandler.has_fishing_upgrade("knight_vamp_unlock") \
        or SaveHandler.has_fishing_upgrade("archer_pierce_unlock") \
        or SaveHandler.has_fishing_upgrade("guardian_fortify_unlock") \
        or SaveHandler.has_fishing_upgrade("mage_storm_unlock")

func _walk_speed_mult() -> float:
    return float(battle_mods.get("walk_speed_mult", 1.0))

func _enemy_hp_mult() -> float:
    return float(battle_mods.get("enemy_hp_mult", 1.0))

func _enemy_contact_mult() -> float:
    return float(battle_mods.get("enemy_contact_mult", 1.0))

func _enemy_dot_mult() -> float:
    return float(battle_mods.get("enemy_dot_mult", 1.0))

func _boss_hp_mult() -> float:
    return float(battle_mods.get("boss_hp_mult", 1.0))

func _boss_contact_mult() -> float:
    return float(battle_mods.get("boss_contact_mult", 1.0))

func _coin_mult() -> float:
    return float(battle_mods.get("coin_mult", 1.0))

func _power_gain_mult() -> float:
    return float(battle_mods.get("power_gain_mult", 1.0))

func _enemy_count_mult() -> float:
    return float(battle_mods.get("enemy_count_mult", 1.0))

func _active_cost() -> float:
    return max(20.0, 60.0 * float(battle_mods.get("active_cost_mult", 1.0)))

func _active_cooldown_mult() -> float:
    return float(battle_mods.get("active_cd_mult", 1.0))

func _apply_player_damage(amount: float, world_pos: Vector2) -> void:
    if amount <= 0.0:
        return
    player_health -= amount
    if suppress_floating_text:
        return
    hero_damage_accum += amount
    hero_damage_pos = world_pos

func _update_hero_damage_float(delta: float) -> void:
    if suppress_floating_text:
        hero_damage_accum = 0.0
        hero_damage_timer = 0.0
        return
    hero_damage_timer = max(0.0, hero_damage_timer - delta)
    if hero_damage_accum <= 0.0 or hero_damage_timer > 0.0:
        return
    _spawn_floating_damage_text(hero_damage_pos + Vector2(randf_range(-10.0, 10.0), -16.0), hero_damage_accum, Color(1.0, 0.42, 0.42, 1.0))
    hero_damage_accum = 0.0
    hero_damage_timer = 0.2

func _spawn_floating_damage_text(world_pos: Vector2, amount: float, color: Color, prefix: String = "-") -> void:
    if not SaveHandler.damage_text:
        return
    _spawn_floating_number_text(world_pos, amount, color, prefix, FLOATING_DAMAGE_NUMBER_SETTINGS)

func _spawn_floating_currency_text(world_pos: Vector2, amount: float) -> void:
    if not SaveHandler.money_text:
        return
    _spawn_floating_number_text(world_pos, amount, COIN_FLOAT_TEXT_COLOR, "+", FLOATING_CURRENCY_NUMBER_SETTINGS)

func _spawn_floating_number_text(world_pos: Vector2, amount: float, color: Color, prefix: String, settings: Dictionary) -> void:
    if damage_text_layer == null or suppress_floating_text:
        return
    var value: int = max(1, int(round(amount)))
    var label: Label = Label.new()
    label.text = "%s%d" % [prefix, value]
    label.position = world_pos
    label.modulate = color
    label.z_index = 100
    label.top_level = false
    damage_text_layer.add_child(label)
    var ttl: float = max(0.05, float(settings.get("ttl", 1.0)))
    var speed_min: float = float(settings.get("speed_min", 30.0))
    var speed_max: float = float(settings.get("speed_max", 50.0))
    if speed_max < speed_min:
        var tmp: float = speed_min
        speed_min = speed_max
        speed_max = tmp
    floating_damage_texts.append({
        "label": label,
        "ttl": ttl,
        "ttl_max": ttl,
        "speed": randf_range(speed_min, speed_max),
    })

func _spawn_floating_heal_text(world_pos: Vector2, amount: float) -> void:
    _spawn_floating_damage_text(world_pos, amount, Color(0.36, 0.95, 0.46, 1.0), "+")

func _update_floating_damage_texts(delta: float) -> void:
    for i in range(floating_damage_texts.size() - 1, -1, -1):
        var item: Dictionary = floating_damage_texts[i]
        var label: Label = item.get("label", null)
        if label == null or not is_instance_valid(label):
            floating_damage_texts.remove_at(i)
            continue
        var ttl: float = float(item.get("ttl", 0.0)) - delta
        if ttl <= 0.0:
            label.queue_free()
            floating_damage_texts.remove_at(i)
            continue
        label.position.y -= float(item.get("speed", 36.0)) * delta
        var c: Color = label.modulate
        var ttl_max: float = max(0.001, float(item.get("ttl_max", 1.0)))
        c.a = clamp(ttl / ttl_max, 0.0, 1.0)
        label.modulate = c
        item["ttl"] = ttl
        floating_damage_texts[i] = item

func _player_armor_scale() -> float:
    var base: float = 1.0 - min(0.75, 0.035 * float(SaveHandler.get_fishing_upgrade_level("core_armor")))
    base *= max(0.45, 1.0 - float(battle_mods.get("armor_bonus", 0.0)))
    return base

func _update_ui() -> void:
    var max_health: float = 300.0
    var health_now: float = clamp(player_health, 0.0, max_health)
    health_label.text = "LEVEL %d" % current_level
    health_bar.max_value = max_health
    health_bar.value = health_now
    health_value_label.text = "%d / %d" % [int(round(health_now)), int(round(max_health))]

    var max_power_val: float = max(1.0, _max_power())
    var power_now: float = clamp(power, 0.0, max_power_val)
    var show_power_hud: bool = _has_any_active_power_unlock()
    power_bar.visible = show_power_hud
    power_value_label.visible = show_power_hud
    power_bar.max_value = max_power_val
    power_bar.value = power_now
    power_value_label.text = "%d / %d" % [int(round(power_now)), int(round(max_power_val))]

    var level_params: Dictionary = _level_params(current_level)
    var exp_total: int = int(level_params.get("regular_count", 0)) + BOSS_SEGMENTS
    var exp_now: int = min(exp_total, regular_killed + boss_segments_broken)
    var exp_remaining: int = max(0, exp_total - exp_now)
    var show_enemy_counter_hud: bool = _has_enemy_counter_unlock()
    experience_bar.visible = show_enemy_counter_hud
    experience_value_label.visible = show_enemy_counter_hud
    experience_bar.max_value = max(1, exp_total)
    experience_bar.value = exp_remaining
    experience_value_label.text = "Enemies Remaining: %d" % exp_remaining

    currency_label.text = "Currency: %d" % SaveHandler.fishing_currency
    clock_label.text = "Clock: %s" % Util.format_time(SaveHandler.fishing_run_clock_seconds)

func _on_boss_defeated() -> void:
    print("DEBUG: _on_boss_defeated() called")
    if battle_completed:
        return
    _track_first_boss_clear_event(current_level)
    if current_level >= int(SaveHandler.fishing_max_unlocked_battle_level) and current_level < SaveHandler.MAX_FISHING_BATTLE_LEVEL:
        SaveHandler.fishing_max_unlocked_battle_level = current_level + 1
        SaveHandler.fishing_next_battle_level = SaveHandler.fishing_max_unlocked_battle_level
    # Boss defeated sound
    print("[AUDIO] Boss defeated - playing BUTTON_CLICK")
    _play_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
    if current_level == 3:
        SaveHandler.fishing_l3_boss_clear_clock_seconds = SaveHandler.fishing_run_clock_seconds
        SaveHandler.save_fishing_progress()
    _end_battle(true)

func _track_first_boss_clear_event(level: int) -> void:
    if level <= 0:
        return
    var level_key: String = str(level)
    if bool(SaveHandler.fishing_first_boss_clear_levels.get(level_key, false)):
        return
    var app_clock_seconds: float = float(Time.get_ticks_msec()) / 1000.0
    SaveHandler.fishing_first_boss_clear_levels[level_key] = true
    _track_ga_event(
        "boss:first_clear:level_%d" % level,
        {
            "level": level,
            "game_time_seconds": SaveHandler.fishing_run_clock_seconds,
            "game_time_formatted": Util.format_time(SaveHandler.fishing_run_clock_seconds),
            "clock_time_seconds": app_clock_seconds,
            "clock_time_formatted": Util.format_time(app_clock_seconds),
            "battle_scene_unadjusted_seconds": battle_scene_unadjusted_seconds,
            "battle_scene_unadjusted_formatted": Util.format_time(battle_scene_unadjusted_seconds),
        }
    )
    SaveHandler.save_fishing_progress()

func _end_battle(victory: bool) -> void:
    print("DEBUG: _end_battle() called with victory=" + str(victory))
    if battle_completed:
        return
    battle_completed = true
    battle_victory = victory
    summary_finalized = false
    post_battle_sweep_time = 2.8
    defeat_anim_time = 0.0
    if is_instance_valid(active_ufo):
        active_ufo.queue_free()
    active_ufo = null
    _apply_battle_summary_layout(Vector2(1.5, 1.8) if _is_first_l3_boss_clear() else Vector2.ONE)
    summary_panel.show()
    continue_button.hide()
    _refresh_battle_summary_text()
    _update_speed_button_enabled_state()
    if not victory:
        # Play defeat SFX
        print("[AUDIO] Player defeated - playing BUTTON_CLICK")
        _play_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
        _start_defeat_pose()
    if suppress_floating_text:
        if battle_victory:
            _run_post_battle_sweep_instant()
        else:
            _run_defeat_pose_instant()

func _run_post_battle_sweep(delta: float) -> void:
    if summary_finalized:
        return

    var target_x: float = _frontline_x() + 320.0
    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        hero.position.x = min(hero.position.x + 420.0 * delta, target_x)
        hero.set_walking()

    var attract_target: Vector2 = Vector2(_frontline_x() + 42.0, FLOOR_Y - 48.0)
    for coin in coins:
        if is_instance_valid(coin):
            coin.attract_to(attract_target, 1800.0, delta)
    _update_coins(delta)
    _refresh_battle_summary_text()

    post_battle_sweep_time -= delta
    if coins.is_empty() or post_battle_sweep_time <= 0.0:
        _finalize_battle_summary()

func _run_post_battle_sweep_instant() -> void:
    if summary_finalized:
        return
    var steps: int = int(ceil(3.2 / SIM_STEP))
    for _i in range(steps):
        if coins.is_empty():
            break
        _run_post_battle_sweep(SIM_STEP)
    _finalize_battle_summary()

func _start_defeat_pose() -> void:
    for arrow_data_variant in arrows:
        var arrow_data: Dictionary = arrow_data_variant
        var arrow_sprite: Sprite2D = arrow_data.get("sprite", null)
        if is_instance_valid(arrow_sprite):
            arrow_sprite.queue_free()
    arrows.clear()

    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        if hero.has_method("set_defeated"):
            hero.set_defeated()
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        if enemy.has_method("set_defeated"):
            enemy.set_defeated()

func _run_defeat_pose(delta: float) -> void:
    if summary_finalized:
        return
    defeat_anim_time += delta

    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        hero.rotation = lerp_angle(hero.rotation, PI * 0.5, min(1.0, delta * DEFEAT_FALL_ROT_SPEED))

    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        enemy.rotation = lerp_angle(enemy.rotation, -PI * 0.5, min(1.0, delta * DEFEAT_FALL_ROT_SPEED))

    if defeat_anim_time >= DEFEAT_FALL_DURATION:
        _finalize_battle_summary()

func _run_defeat_pose_instant() -> void:
    if summary_finalized:
        return
    for hero in heroes:
        if is_instance_valid(hero):
            hero.rotation = PI * 0.5
    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.rotation = -PI * 0.5
    _finalize_battle_summary()

func _build_battle_summary_text(is_live: bool) -> String:
    var title: String = "VICTORY" if battle_victory else "DEFEAT"
    var summary_text: String = "BATTLE OVER  |  %s\n\nLevel: %d\nEnemies defeated: %d\nBoss segments broken: %d\nCoins gained this run: %d\nGold total: %d" % [
        title,
        current_level,
        enemies_killed,
        boss_segments_broken,
        coins_gained,
        SaveHandler.fishing_currency,
    ]
    if is_live and battle_victory and not coins.is_empty():
        summary_text += "\nCollecting remaining loot..."
    var is_first_l3_boss_clear: bool = _is_first_l3_boss_clear()
    if is_first_l3_boss_clear:
        summary_text += "\n\nThanks for playing.\nThis game was created by a single developer.\nPlease leave feedback or email to web@beep2bleep.com if you would like more content.\nCreator: Beep2Bleep."
    if battle_victory and current_level == 3 and SaveHandler.fishing_l3_boss_clear_clock_seconds >= 0.0:
        summary_text += "\n\nLevel 3 clear time: %s" % Util.format_time(SaveHandler.fishing_l3_boss_clear_clock_seconds)
    return summary_text

func _is_first_l3_boss_clear() -> bool:
    return battle_victory and current_level == 3 and not SaveHandler.fishing_l3_boss_thank_you_shown

func _rect_from_control_offsets(control: Control) -> Rect2:
    var left: float = control.offset_left
    var top: float = control.offset_top
    var right: float = control.offset_right
    var bottom: float = control.offset_bottom
    return Rect2(Vector2(left, top), Vector2(right - left, bottom - top))

func _set_control_offsets_from_rect(control: Control, rect: Rect2) -> void:
    control.offset_left = rect.position.x
    control.offset_top = rect.position.y
    control.offset_right = rect.position.x + rect.size.x
    control.offset_bottom = rect.position.y + rect.size.y

func _cache_battle_summary_layout() -> void:
    if summary_panel == null or summary_label == null or continue_button == null:
        return
    summary_panel_base_layout = _rect_from_control_offsets(summary_panel)
    summary_label_base_layout = _rect_from_control_offsets(summary_label)
    continue_button_base_layout = _rect_from_control_offsets(continue_button)

func _apply_battle_summary_layout(scale: Vector2) -> void:
    if summary_panel == null or summary_label == null or continue_button == null:
        return
    if summary_panel_base_layout.size == Vector2.ZERO:
        _cache_battle_summary_layout()
    var safe_scale := Vector2(max(0.1, scale.x), max(0.1, scale.y))

    var base_center: Vector2 = summary_panel_base_layout.position + (summary_panel_base_layout.size * 0.5)
    var scaled_panel_size: Vector2 = summary_panel_base_layout.size * safe_scale
    var scaled_panel_rect := Rect2(base_center - (scaled_panel_size * 0.5), scaled_panel_size)
    _set_control_offsets_from_rect(summary_panel, scaled_panel_rect)

    var scaled_label_rect := Rect2(summary_label_base_layout.position * safe_scale, summary_label_base_layout.size * safe_scale)
    _set_control_offsets_from_rect(summary_label, scaled_label_rect)

    var scaled_button_rect := Rect2(continue_button_base_layout.position * safe_scale, continue_button_base_layout.size * safe_scale)
    _set_control_offsets_from_rect(continue_button, scaled_button_rect)

func _style_clock_ui() -> void:
    if clock_panel == null or clock_label == null:
        return
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color(0.04, 0.05, 0.09, 0.92)
    panel_style.border_color = Color(0.8, 0.85, 1.0, 0.9)
    panel_style.border_width_left = 2
    panel_style.border_width_top = 2
    panel_style.border_width_right = 2
    panel_style.border_width_bottom = 2
    clock_panel.add_theme_stylebox_override("panel", panel_style)
    clock_panel.custom_minimum_size = Vector2(0.0, 80.0)
    clock_label.add_theme_color_override("font_color", Color(0.94, 0.94, 0.98, 1.0))
    clock_label.add_theme_font_size_override("font_size", 42)
    clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    clock_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    clock_label.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _style_speed_controls() -> void:
    if speed_button == null or infinite_sim_button == null:
        return
    speed_button.custom_minimum_size = Vector2(392.0, 88.0)
    infinite_sim_button.custom_minimum_size = Vector2(456.0, 88.0)
    speed_button.add_theme_font_size_override("font_size", 32)
    infinite_sim_button.add_theme_font_size_override("font_size", 32)

func _setup_mute_button() -> void:
    if mute_button == null:
        return
    speaker_icon_on = _make_speaker_icon_texture(false)
    speaker_icon_off = _make_speaker_icon_texture(true)
    mute_button.text = ""
    mute_button.focus_mode = Control.FOCUS_NONE
    mute_button.offset_left = 896.0
    mute_button.offset_top = 20.0
    mute_button.offset_right = 1064.0
    mute_button.offset_bottom = 152.0
    mute_button.custom_minimum_size = Vector2(168, 132)
    mute_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mute_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    mute_button.expand_icon = true
    _style_mute_button()
    _refresh_mute_button_icon()

func _style_mute_button() -> void:
    if mute_button == null:
        return
    _style_mute_like_button(mute_button)

func _style_mute_like_button(button: Button) -> void:
    if button == null:
        return
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.05, 0.14, 0.4, 0.96)
    normal.border_color = Color(0.89, 0.92, 0.99, 1.0)
    normal.border_width_left = 2
    normal.border_width_top = 2
    normal.border_width_right = 2
    normal.border_width_bottom = 2
    normal.corner_radius_top_left = 4
    normal.corner_radius_top_right = 4
    normal.corner_radius_bottom_left = 4
    normal.corner_radius_bottom_right = 4
    var hover := normal.duplicate(true)
    hover.bg_color = Color(0.08, 0.22, 0.55, 0.98)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)

func _style_utility_panel(panel: PanelContainer) -> void:
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

func _refresh_mute_button_icon() -> void:
    if mute_button == null:
        return
    mute_button.icon = speaker_icon_off if SaveHandler.audio_muted else speaker_icon_on
    mute_button.tooltip_text = "Unmute all audio" if SaveHandler.audio_muted else "Mute all audio"

func _on_mute_button_pressed() -> void:
    SaveHandler.update_audio_muted(not SaveHandler.audio_muted)
    _refresh_mute_button_icon()

func _setup_settings_controls() -> void:
    if settings_button != null and is_instance_valid(settings_button):
        return
    var canvas_layer: CanvasLayer = get_node_or_null("CanvasLayer")
    if canvas_layer == null:
        return

    settings_button = Button.new()
    settings_button.name = "SettingsButton"
    settings_button.anchor_left = 1.0
    settings_button.anchor_top = 0.0
    settings_button.anchor_right = 1.0
    settings_button.anchor_bottom = 0.0
    settings_button.offset_left = -184.0
    settings_button.offset_top = 20.0
    settings_button.offset_right = -16.0
    settings_button.offset_bottom = 108.0
    settings_button.z_index = 30
    settings_button.focus_mode = Control.FOCUS_NONE
    settings_button.text = "Settings"
    settings_button.custom_minimum_size = Vector2(168, 88)
    settings_button.add_theme_font_size_override("font_size", 26)
    settings_button.pressed.connect(_on_settings_button_pressed)
    _style_mute_like_button(settings_button)
    canvas_layer.add_child(settings_button)

    settings_panel = PanelContainer.new()
    settings_panel.name = "BattleSettingsPanel"
    settings_panel.anchor_left = 0.0
    settings_panel.anchor_top = 0.0
    settings_panel.anchor_right = 1.0
    settings_panel.anchor_bottom = 1.0
    settings_panel.offset_left = 16.0
    settings_panel.offset_top = 16.0
    settings_panel.offset_right = -16.0
    settings_panel.offset_bottom = -16.0
    settings_panel.z_index = 60
    settings_panel.visible = false
    settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _style_utility_panel(settings_panel)
    canvas_layer.add_child(settings_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 12)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_right", 12)
    margin.add_theme_constant_override("margin_bottom", 12)
    settings_panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 12)
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(vbox)

    var title := Label.new()
    title.text = "SETTINGS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 46)
    vbox.add_child(title)

    settings_content = SETTINGS_SCENE.instantiate() as Settings
    if settings_content != null:
        settings_content.name = "SettingsContent"
        settings_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        settings_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
        settings_content.scale = Vector2(1.7, 1.7)
        vbox.add_child(settings_content)

    var close_button := Button.new()
    close_button.name = "SettingsCloseButton"
    close_button.text = "BACK"
    close_button.focus_mode = Control.FOCUS_NONE
    close_button.custom_minimum_size = Vector2(0, 150)
    close_button.add_theme_font_size_override("font_size", 34)
    close_button.pressed.connect(_on_settings_close_pressed)
    _style_mute_like_button(close_button)
    vbox.add_child(close_button)

func _setup_fullscreen_button() -> void:
    if fullscreen_button != null and is_instance_valid(fullscreen_button):
        return
    var canvas_layer: CanvasLayer = get_node_or_null("CanvasLayer")
    if canvas_layer == null:
        return
    fullscreen_button = Button.new()
    fullscreen_button.name = "FullscreenButton"
    fullscreen_button.offset_left = 24.0
    fullscreen_button.offset_top = 20.0
    fullscreen_button.offset_right = 112.0
    fullscreen_button.offset_bottom = 108.0
    fullscreen_button.z_index = 30
    fullscreen_button.focus_mode = Control.FOCUS_NONE
    fullscreen_button.text = ""
    fullscreen_button.custom_minimum_size = Vector2(88, 88)
    fullscreen_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
    fullscreen_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    fullscreen_button.expand_icon = true
    fullscreen_button.pressed.connect(_on_fullscreen_button_pressed)
    _style_mute_like_button(fullscreen_button)
    canvas_layer.add_child(fullscreen_button)
    fullscreen_icon_on = _make_fullscreen_icon_texture(true)
    fullscreen_icon_off = _make_fullscreen_icon_texture(false)

func _setup_touch_input_button() -> void:
    if not _should_show_editor_only_touch_toggle():
        return
    if touch_input_button != null and is_instance_valid(touch_input_button):
        return
    var canvas_layer: CanvasLayer = get_node_or_null("CanvasLayer")
    if canvas_layer == null:
        return
    touch_input_button = Button.new()
    touch_input_button.name = "TouchInputButton"
    touch_input_button.anchor_left = 1.0
    touch_input_button.anchor_top = 0.0
    touch_input_button.anchor_right = 1.0
    touch_input_button.anchor_bottom = 0.0
    touch_input_button.offset_left = -256.0
    touch_input_button.offset_top = 244.0
    touch_input_button.offset_right = -16.0
    touch_input_button.offset_bottom = 332.0
    touch_input_button.z_index = 30
    touch_input_button.focus_mode = Control.FOCUS_NONE
    touch_input_button.custom_minimum_size = Vector2(240, 88)
    touch_input_button.add_theme_font_size_override("font_size", 26)
    touch_input_button.pressed.connect(_on_touch_input_button_pressed)
    _style_mute_like_button(touch_input_button)
    canvas_layer.add_child(touch_input_button)

func _refresh_fullscreen_button_icon() -> void:
    if fullscreen_button == null:
        return
    var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    fullscreen_button.icon = fullscreen_icon_on if is_fullscreen else fullscreen_icon_off
    fullscreen_button.tooltip_text = "Exit fullscreen" if is_fullscreen else "Enter fullscreen"

func _on_fullscreen_button_pressed() -> void:
    var is_fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
    SaveHandler.update_screen_mode(
        SaveHandler.SCREEN_MODES.WINDOWED if is_fullscreen else SaveHandler.SCREEN_MODES.FULL_SCREEN
    )
    _refresh_fullscreen_button_icon()
    if settings_content != null:
        settings_content.refresh_from_save()

func _refresh_touch_input_button() -> void:
    if touch_input_button == null:
        return
    touch_input_button.text = "Touch Input" if SaveHandler.touch_input_mode else "Mouse Input"

func _on_touch_input_button_pressed() -> void:
    SaveHandler.update_touch_input_mode(not SaveHandler.touch_input_mode)
    _refresh_touch_input_button()
    _apply_touch_input_camera_zoom()
    _apply_background_layout_for_input_mode("Switched to %s layout" % ("touch" if SaveHandler.touch_input_mode else "mouse"))
    if settings_content != null:
        settings_content.refresh_from_save()

func _is_settings_open() -> bool:
    return settings_panel != null and is_instance_valid(settings_panel) and settings_panel.visible

func _on_settings_button_pressed() -> void:
    if settings_content != null:
        settings_content.show_screen()
        settings_content.refresh_from_save()
    if settings_panel != null:
        settings_panel.show()

func _on_settings_close_pressed() -> void:
    _hide_settings_panel()

func _hide_settings_panel() -> void:
    if settings_panel != null and is_instance_valid(settings_panel):
        settings_panel.hide()

func _on_settings_updated() -> void:
    _refresh_touch_input_button()
    _refresh_fullscreen_button_icon()
    _apply_touch_input_camera_zoom()
    _apply_background_layout_for_input_mode("Applied %s layout" % ("touch" if SaveHandler.touch_input_mode else "mouse"))

func _apply_touch_input_camera_zoom() -> void:
    if camera_2d == null:
        return
    var base_zoom := Vector2(0.2, 0.2) * EXTRA_ZOOM_IN_FACTOR
    camera_2d.zoom = base_zoom * TOUCH_CAMERA_ZOOM_MULT if SaveHandler.touch_input_mode else base_zoom

func _make_fullscreen_icon_texture(is_fullscreen: bool) -> ImageTexture:
    var image := Image.create(80, 80, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))
    var line_color := Color(0.93, 0.97, 1.0, 1.0)
    if is_fullscreen:
        _draw_icon_rect(image, Rect2i(12, 12, 20, 6), line_color)
        _draw_icon_rect(image, Rect2i(12, 12, 6, 20), line_color)
        _draw_icon_rect(image, Rect2i(48, 12, 20, 6), line_color)
        _draw_icon_rect(image, Rect2i(62, 12, 6, 20), line_color)
        _draw_icon_rect(image, Rect2i(12, 62, 20, 6), line_color)
        _draw_icon_rect(image, Rect2i(12, 48, 6, 20), line_color)
        _draw_icon_rect(image, Rect2i(48, 62, 20, 6), line_color)
        _draw_icon_rect(image, Rect2i(62, 48, 6, 20), line_color)
    else:
        _draw_icon_rect(image, Rect2i(24, 12, 6, 20), line_color)
        _draw_icon_rect(image, Rect2i(12, 24, 20, 6), line_color)
        _draw_icon_rect(image, Rect2i(50, 12, 6, 20), line_color)
        _draw_icon_rect(image, Rect2i(48, 24, 20, 6), line_color)
        _draw_icon_rect(image, Rect2i(24, 48, 6, 20), line_color)
        _draw_icon_rect(image, Rect2i(12, 50, 20, 6), line_color)
        _draw_icon_rect(image, Rect2i(50, 48, 6, 20), line_color)
        _draw_icon_rect(image, Rect2i(48, 50, 20, 6), line_color)
    return ImageTexture.create_from_image(image)

func _draw_icon_rect(image: Image, rect: Rect2i, color: Color) -> void:
    for x in range(rect.position.x, rect.position.x + rect.size.x):
        for y in range(rect.position.y, rect.position.y + rect.size.y):
            image.set_pixel(x, y, color)

func _refresh_battle_summary_text() -> void:
    if summary_label == null:
        return
    summary_label.text = _build_battle_summary_text(not summary_finalized)

func _style_battle_summary_ui() -> void:
    if summary_panel == null or summary_label == null or continue_button == null:
        return

    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color(0.027, 0.047, 0.102, 0.96)
    panel_style.border_color = Color(0.129, 0.8, 1.0, 1.0)
    panel_style.border_width_left = 3
    panel_style.border_width_top = 3
    panel_style.border_width_right = 3
    panel_style.border_width_bottom = 3
    panel_style.corner_radius_top_left = 6
    panel_style.corner_radius_top_right = 6
    panel_style.corner_radius_bottom_left = 6
    panel_style.corner_radius_bottom_right = 6
    summary_panel.add_theme_stylebox_override("panel", panel_style)

    summary_label.add_theme_color_override("font_color", Color(0.92, 0.97, 1.0, 1.0))
    summary_label.add_theme_font_size_override("font_size", 32)
    summary_label.autowrap_mode = 2
    summary_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.05, 0.14, 0.4, 0.96)
    normal.border_color = Color(0.89, 0.92, 0.99, 1.0)
    normal.border_width_left = 2
    normal.border_width_top = 2
    normal.border_width_right = 2
    normal.border_width_bottom = 2
    normal.corner_radius_top_left = 4
    normal.corner_radius_top_right = 4
    normal.corner_radius_bottom_left = 4
    normal.corner_radius_bottom_right = 4
    var hover := normal.duplicate(true)
    hover.bg_color = Color(0.08, 0.22, 0.55, 0.98)

    continue_button.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0, 1.0))
    continue_button.add_theme_font_size_override("font_size", 26)
    continue_button.add_theme_stylebox_override("normal", normal)
    continue_button.add_theme_stylebox_override("hover", hover)
    continue_button.add_theme_stylebox_override("pressed", hover)

func _finalize_battle_summary() -> void:
    if summary_finalized:
        return
    summary_finalized = true
    summary_panel.show()
    continue_button.show()
    _refresh_battle_summary_text()
    if battle_victory and current_level == 3 and not SaveHandler.fishing_l3_boss_thank_you_shown:
        SaveHandler.fishing_l3_boss_thank_you_shown = true
    SaveHandler.fishing_last_battle_summary = {
        "victory": battle_victory,
        "level": current_level,
        "enemies_killed": enemies_killed,
        "boss_segments_broken": boss_segments_broken,
        "coins_gained": coins_gained,
        "run_clock_seconds": SaveHandler.fishing_run_clock_seconds,
        "l3_boss_clear_clock_seconds": SaveHandler.fishing_l3_boss_clear_clock_seconds,
    }
    SaveHandler.save_fishing_progress()
    _update_speed_button_enabled_state()

func _advance_run_clock(delta: float) -> void:
    if delta <= 0.0:
        return
    var speed_mult: float = _speed_multiplier_for_runtime()
    var safe_engine_scale: float = max(0.001, Engine.time_scale)
    var adjusted_delta: float = (delta / safe_engine_scale) * speed_mult
    SaveHandler.fishing_run_clock_seconds += adjusted_delta
    if in_infinite_simulation:
        return
    run_clock_save_accum += delta
    if run_clock_save_accum >= 1.0:
        run_clock_save_accum = 0.0
        SaveHandler.save_fishing_progress()

func _trigger_hero_glow(hero: CombatSprite) -> void:
    if not is_instance_valid(hero):
        return
    hero_glow_timers[hero] = 0.28
    hero.modulate = Color(1.45, 1.45, 1.05, 1.0)

func _update_hero_glow(delta: float) -> void:
    for hero_variant in hero_glow_timers.keys().duplicate():
        var hero: CombatSprite = hero_variant
        if not is_instance_valid(hero):
            hero_glow_timers.erase(hero_variant)
            continue
        var t: float = float(hero_glow_timers[hero_variant]) - delta
        if t <= 0.0:
            hero.modulate = Color(1.0, 1.0, 1.0, 1.0)
            hero_glow_timers.erase(hero_variant)
            continue
        hero_glow_timers[hero_variant] = t
        var pulse: float = 1.0 + 0.45 * (t / 0.28)
        hero.modulate = Color(pulse, pulse, 1.0, 1.0)

func _on_continue_button_pressed() -> void:
    print("DEBUG: _on_continue_button_pressed() called")
    if not summary_finalized:
        return
    # Play continue button click audio
    print("[AUDIO] Continue button pressed - playing BUTTON_CLICK")
    _play_sfx(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
    _set_next_battle_level_and_exit(current_level)

func _show_level_choice_dialog(max_level: int) -> void:
    if level_choice_dialog == null:
        _set_next_battle_level_and_exit(1)
        return

    level_choice_dialog.dialog_text = "You unlocked new battle levels by defeating bosses.\nChoose your next level."
    level_choice_selected_level = clamp(SaveHandler.fishing_next_battle_level, 1, max_level)
    level_choice_line_edit = null
    var existing: Control = level_choice_dialog.get_node_or_null("LevelChoiceContent")
    if existing != null:
        existing.queue_free()

    var margin := MarginContainer.new()
    margin.name = "LevelChoiceContent"
    margin.anchor_left = 0.0
    margin.anchor_top = 0.0
    margin.anchor_right = 1.0
    margin.anchor_bottom = 1.0
    margin.offset_left = 24.0
    margin.offset_top = 24.0
    margin.offset_right = -24.0
    margin.offset_bottom = -24.0
    level_choice_dialog.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.anchor_left = 0.0
    vbox.anchor_top = 0.0
    vbox.anchor_right = 1.0
    vbox.anchor_bottom = 1.0
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_theme_constant_override("separation", 16)
    margin.add_child(vbox)

    if max_level <= 4:
        for level in range(1, max_level + 1):
            var button := Button.new()
            button.name = "LevelChoiceButton%d" % level
            button.text = "Level %d" % level
            button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            button.custom_minimum_size = Vector2(0.0, LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
            button.add_theme_font_size_override("font_size", LEVEL_CHOICE_DIALOG_FONT_SIZE)
            button.pressed.connect(_on_level_choice_button_pressed.bind(level))
            vbox.add_child(button)
    else:
        var prompt := Label.new()
        prompt.text = "Select a battle level from 1 to %d." % max_level
        prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        prompt.add_theme_font_size_override("font_size", 28)
        vbox.add_child(prompt)

        var selector_row := HBoxContainer.new()
        selector_row.alignment = BoxContainer.ALIGNMENT_CENTER
        selector_row.add_theme_constant_override("separation", 18)
        selector_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        selector_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
        vbox.add_child(selector_row)

        var minus_button := Button.new()
        minus_button.text = "-"
        minus_button.custom_minimum_size = Vector2(LEVEL_CHOICE_SELECTOR_BUTTON_WIDTH, LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        minus_button.add_theme_font_size_override("font_size", LEVEL_CHOICE_SELECTOR_FONT_SIZE)
        minus_button.pressed.connect(_on_level_choice_adjust_pressed.bind(-1, max_level))
        selector_row.add_child(minus_button)

        level_choice_line_edit = LineEdit.new()
        level_choice_line_edit.name = "LevelChoiceLineEdit"
        level_choice_line_edit.text = str(level_choice_selected_level)
        level_choice_line_edit.custom_minimum_size = Vector2(LEVEL_CHOICE_SELECTOR_INPUT_WIDTH, LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        level_choice_line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
        level_choice_line_edit.max_length = len(str(max_level))
        level_choice_line_edit.add_theme_font_size_override("font_size", LEVEL_CHOICE_SELECTOR_FONT_SIZE)
        level_choice_line_edit.text_submitted.connect(_on_level_choice_text_submitted.bind(max_level))
        level_choice_line_edit.focus_exited.connect(_on_level_choice_input_focus_exited.bind(max_level))
        selector_row.add_child(level_choice_line_edit)

        var plus_button := Button.new()
        plus_button.text = "+"
        plus_button.custom_minimum_size = Vector2(LEVEL_CHOICE_SELECTOR_BUTTON_WIDTH, LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        plus_button.add_theme_font_size_override("font_size", LEVEL_CHOICE_SELECTOR_FONT_SIZE)
        plus_button.pressed.connect(_on_level_choice_adjust_pressed.bind(1, max_level))
        selector_row.add_child(plus_button)

    var cancel_button := Button.new()
    cancel_button.name = "LevelChoiceCancelButton"
    cancel_button.text = "Cancel"
    cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cancel_button.custom_minimum_size = Vector2(0.0, LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
    cancel_button.add_theme_font_size_override("font_size", LEVEL_CHOICE_DIALOG_FONT_SIZE)
    cancel_button.pressed.connect(_on_level_choice_cancel_pressed)
    vbox.add_child(cancel_button)

    if max_level > 4:
        var confirm_button := Button.new()
        confirm_button.name = "LevelChoiceConfirmButton"
        confirm_button.text = "Confirm"
        confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        confirm_button.custom_minimum_size = Vector2(0.0, LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        confirm_button.add_theme_font_size_override("font_size", LEVEL_CHOICE_DIALOG_FONT_SIZE)
        confirm_button.pressed.connect(_on_level_choice_confirm_pressed.bind(max_level))
        vbox.add_child(confirm_button)

        if level_choice_line_edit != null:
            level_choice_line_edit.grab_focus()
            level_choice_line_edit.select_all()

    _style_level_choice_dialog(level_choice_dialog)
    level_choice_dialog.popup_centered(LEVEL_CHOICE_DIALOG_SIZE)

func _on_level_choice_action(action: StringName) -> void:
    var action_text: String = str(action)
    if not action_text.begins_with("level_"):
        return
    var level: int = int(action_text.trim_prefix("level_"))
    _set_next_battle_level_and_exit(level)

func _on_level_choice_button_pressed(level: int) -> void:
    _set_next_battle_level_and_exit(level)

func _on_level_choice_adjust_pressed(delta: int, max_level: int) -> void:
    level_choice_selected_level = clamp(level_choice_selected_level + delta, 1, max_level)
    _update_level_choice_line_edit()

func _on_level_choice_text_submitted(_text: String, max_level: int) -> void:
    _sync_level_choice_from_input(max_level)

func _on_level_choice_input_focus_exited(max_level: int) -> void:
    _sync_level_choice_from_input(max_level)

func _on_level_choice_confirm_pressed(max_level: int) -> void:
    _sync_level_choice_from_input(max_level)
    _set_next_battle_level_and_exit(level_choice_selected_level)

func _on_level_choice_cancel_pressed() -> void:
    if level_choice_dialog != null:
        level_choice_dialog.hide()

func _style_level_choice_dialog(dialog: ConfirmationDialog) -> void:
    if dialog == null:
        return
    dialog.add_theme_font_size_override("font_size", LEVEL_CHOICE_DIALOG_FONT_SIZE)
    dialog.add_theme_font_size_override("title_font_size", LEVEL_CHOICE_DIALOG_TITLE_SIZE)
    dialog.min_size = LEVEL_CHOICE_DIALOG_SIZE
    for child in dialog.get_children():
        if child is Button:
            child.add_theme_font_size_override("font_size", LEVEL_CHOICE_DIALOG_FONT_SIZE)
            child.custom_minimum_size = Vector2(0.0, LEVEL_CHOICE_DIALOG_BUTTON_HEIGHT)
        elif child is Label:
            child.add_theme_font_size_override("font_size", LEVEL_CHOICE_DIALOG_FONT_SIZE)

func _set_next_battle_level_and_exit(level: int) -> void:
    SaveHandler.fishing_next_battle_level = clamp(level, 1, _max_unlocked_level())
    SaveHandler.save_fishing_progress()
    Global.ensure_default_game_mode_data()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = false
    SceneChanger.change_to_new_scene(Util.PATH_MAIN)

func _sync_level_choice_from_input(max_level: int) -> void:
    if level_choice_line_edit == null:
        return
    var raw_text: String = level_choice_line_edit.text.strip_edges()
    if raw_text == "":
        level_choice_selected_level = clamp(level_choice_selected_level, 1, max_level)
    else:
        level_choice_selected_level = clamp(int(raw_text), 1, max_level)
    _update_level_choice_line_edit()

func _update_level_choice_line_edit() -> void:
    if level_choice_line_edit == null:
        return
    level_choice_line_edit.text = str(level_choice_selected_level)
    level_choice_line_edit.caret_column = level_choice_line_edit.text.length()

func _track_ga_event(event_id: String, fields: Dictionary = {}) -> void:
    var ga_manager: Node = get_node_or_null("/root/GameAnalytics")
    if ga_manager == null:
        ga_manager = get_node_or_null("/root/GameAnalyticsManager")
    if ga_manager != null:
        ga_manager.call("track_design_event", event_id, null, fields)

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
    for i in range(steps + 1):
        var t: float = float(i) / float(steps)
        var x: int = int(round(lerpf(float(start.x), float(finish.x), t)))
        var y: int = int(round(lerpf(float(start.y), float(finish.y), t)))
        for ox in range(-thickness, thickness + 1):
            for oy in range(-thickness, thickness + 1):
                if abs(ox) + abs(oy) <= thickness + 1:
                    image.set_pixel(x + ox, y + oy, color)

func _draw_arc_ring(image: Image, center: Vector2i, inner_radius: int, outer_radius: int, start_angle: float, end_angle: float, color: Color) -> void:
    for x in range(image.get_width()):
        for y in range(image.get_height()):
            var px: float = float(x - center.x)
            var py: float = float(y - center.y)
            var angle: float = atan2(py, px)
            if angle < start_angle or angle > end_angle:
                continue
            var dist_sq: float = px * px + py * py
            if dist_sq >= float(inner_radius * inner_radius) and dist_sq <= float(outer_radius * outer_radius):
                image.set_pixel(x, y, color)
