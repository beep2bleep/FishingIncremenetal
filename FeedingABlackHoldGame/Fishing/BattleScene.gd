extends Node2D

const HERO_SCENE: PackedScene = preload("res://Fishing/CombatSprite.tscn")
const COIN_SCENE: PackedScene = preload("res://Fishing/CoinPickup.tscn")

const HERO_FRAME_SIZE := Vector2i(24, 24)
const ENEMY_FRAME_SIZE := Vector2i(24, 24)
const BOSS_FRAME_SIZE := Vector2i(32, 32)

const LEVEL_ENEMY_TYPE := {
    1: "goblin",
    2: "brute",
    3: "flyer",
}

const FLOOR_Y := 640.0
const HERO_START_X := -520.0
const HERO_SCROLL_ANCHOR_SCREEN_X_FACTOR := 0.08
const CONTACT_RANGE := 48.0
const SIM_STEP := 1.0 / 60.0
const EXTRA_ZOOM_IN_FACTOR := 5.0
const HERO_FORMATION_SPACING := 56.0
const ENEMY_FORMATION_SPACING := 84.0
const BOSS_SEGMENTS := 8
const DEFEAT_FALL_DURATION := 1.2
const DEFEAT_FALL_ROT_SPEED := 1.8
const BASE_POWER_REGEN_PER_SEC := 7.0
const ACTIVE_CHARGE_PER_CLICK := 20.0
const PLATFORMING_PACK_SPRITES := "C:/Godot Projects/FishingIncremental/PlatformingPack/Sprites"
const HERO_RENDER_SCALE := 0.72
const ENEMY_RENDER_SCALE := HERO_RENDER_SCALE
const BOSS_RENDER_SCALE := HERO_RENDER_SCALE
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
var bg_deep: Sprite2D
var bg_far: Sprite2D
var bg_mid: Sprite2D
var bg_near: Sprite2D
var ground: Sprite2D
var hero_layer: Node2D
var projectile_layer: Node2D
var enemy_layer: Node2D
var coin_layer: Node2D
var damage_text_layer: Node2D
var camera_2d: Camera2D

var health_label: Label
var currency_label: Label
var summary_panel: Panel
var summary_label: Label
var speed_button: Button
var infinite_sim_button: Button
var level_choice_dialog: ConfirmationDialog

var heroes: Array[CombatSprite] = []
var hero_data: Dictionary = {}
var enemies: Array[CombatSprite] = []
var enemy_data: Dictionary = {}
var coins: Array[CoinPickup] = []
var arrows: Array[Dictionary] = []

var player_health: float = 300.0
var power: float = 0.0
var shield_time: float = 0.0

var enemies_killed: int = 0
var coins_gained: int = 0
var boss_segments_broken: int = 0

var current_level: int = 1
var regular_spawned: int = 0
var regular_killed: int = 0
var boss_spawned: bool = false
var boss_alive: bool = false
var spawn_timer: float = 0.0
var spawn_group_remaining: int = 0
var sim_accumulator: float = 0.0
var battle_completed: bool = false
var battle_victory: bool = false

const SPEED_STEPS: Array[float] = [1.0, 2.0, 4.0, 8.0, 16.0]
const ACTIVE_COOLDOWNS := {
    "knight": 13.0,
    "archer": 15.0,
    "guardian": 17.0,
    "mage": 19.0,
}
var speed_index: int = 0
var arrow_texture: Texture2D
var hero_sheets: Dictionary = {}
var enemy_defs: Dictionary = {}
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

func _ready() -> void:
    if not _bind_nodes():
        push_error("BattleScene is missing required nodes.")
        return

    _setup_actor_sheets()
    current_level = clamp(SaveHandler.fishing_next_battle_level, 1, _max_unlocked_level())
    _rebuild_battle_mods()
    _setup_visuals()
    _spawn_heroes()
    summary_panel.hide()
    _setup_editor_speed_button()
    _update_speed_button_enabled_state()
    _update_ui()

func _exit_tree() -> void:
    if OS.has_feature("editor"):
        Engine.time_scale = 1.0

func _bind_nodes() -> bool:
    world = get_node_or_null("World")
    bg_deep = get_node_or_null("World/BGDeep")
    bg_far = get_node_or_null("World/BGFar")
    bg_mid = get_node_or_null("World/BGMid")
    bg_near = get_node_or_null("World/BGNear")
    ground = get_node_or_null("World/Ground")
    hero_layer = get_node_or_null("World/HeroLayer")
    projectile_layer = get_node_or_null("World/ProjectileLayer")
    enemy_layer = get_node_or_null("World/EnemyLayer")
    coin_layer = get_node_or_null("World/CoinLayer")
    damage_text_layer = get_node_or_null("World/DamageTextLayer")
    camera_2d = get_node_or_null("Camera2D")

    health_label = get_node_or_null("CanvasLayer/HealthLabel")
    currency_label = get_node_or_null("CanvasLayer/CurrencyLabel")
    speed_button = get_node_or_null("CanvasLayer/SpeedButton")
    infinite_sim_button = get_node_or_null("CanvasLayer/InfiniteSimButton")
    summary_panel = get_node_or_null("CanvasLayer/SummaryPanel")
    summary_label = get_node_or_null("CanvasLayer/SummaryPanel/SummaryLabel")
    level_choice_dialog = get_node_or_null("CanvasLayer/LevelChoiceDialog")
    var canvas_layer: CanvasLayer = get_node_or_null("CanvasLayer")

    if world != null:
        if bg_deep == null:
            bg_deep = Sprite2D.new()
            bg_deep.name = "BGDeep"
            world.add_child(bg_deep)
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

        world.move_child(bg_deep, 0)
        world.move_child(bg_far, 1)
        world.move_child(bg_mid, 2)
        world.move_child(bg_near, 3)
        world.move_child(ground, 4)

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
        canvas_layer.add_child(level_choice_dialog)
    if level_choice_dialog != null and not level_choice_dialog.custom_action.is_connected(_on_level_choice_action):
        level_choice_dialog.custom_action.connect(_on_level_choice_action)

    return world != null and bg_deep != null and bg_far != null and bg_mid != null and bg_near != null and ground != null and hero_layer != null and projectile_layer != null and enemy_layer != null and coin_layer != null and damage_text_layer != null and camera_2d != null and health_label != null and currency_label != null and speed_button != null and infinite_sim_button != null and summary_panel != null and summary_label != null and level_choice_dialog != null

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

    for item_variant in floating_damage_texts:
        var item: Dictionary = item_variant
        var damage_label: Label = item.get("label", null)
        if is_instance_valid(damage_label):
            damage_label.queue_free()
    floating_damage_texts.clear()
    hero_damage_accum = 0.0
    hero_damage_timer = 0.0

func _reset_heroes_to_start() -> void:
    for i in range(heroes.size()):
        var hero: CombatSprite = heroes[i]
        if not is_instance_valid(hero):
            continue
        hero.position = Vector2(HERO_START_X - float(i) * 40.0, FLOOR_Y)
        hero.modulate = Color(1.0, 1.0, 1.0, 1.0)
        hero.set_walking()
        if hero_data.has(hero):
            var h: Dictionary = hero_data[hero]
            h["cooldown"] = 0.0
            hero_data[hero] = h

func _setup_editor_speed_button() -> void:
    if speed_button == null or infinite_sim_button == null:
        return
    if OS.has_feature("editor"):
        speed_button.show()
        infinite_sim_button.show()
        speed_index = 0
        Engine.time_scale = SPEED_STEPS[speed_index]
        _update_speed_button_text()
        _update_speed_button_enabled_state()
    else:
        speed_button.hide()
        infinite_sim_button.hide()

func _update_speed_button_enabled_state() -> void:
    if speed_button == null or infinite_sim_button == null:
        return
    var disabled: bool = summary_panel != null and summary_panel.visible
    speed_button.disabled = disabled
    infinite_sim_button.disabled = disabled

func _update_speed_button_text() -> void:
    if speed_button == null:
        return
    speed_button.text = "Speed x%d" % int(SPEED_STEPS[speed_index])

func _on_speed_button_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    speed_index = (speed_index + 1) % SPEED_STEPS.size()
    Engine.time_scale = SPEED_STEPS[speed_index]
    _update_speed_button_text()

func _on_infinite_sim_button_pressed() -> void:
    if not OS.has_feature("editor"):
        return
    _run_infinite_simulation()

func _run_infinite_simulation() -> void:
    if summary_panel.visible or battle_completed:
        return
    if speed_button != null and infinite_sim_button != null:
        speed_button.disabled = true
        infinite_sim_button.disabled = true

    var was_world_visible: bool = world.visible
    world.visible = false
    Engine.time_scale = 1.0
    sim_accumulator = 0.0
    suppress_floating_text = true
    active_cooldowns.clear()
    for key in ACTIVE_COOLDOWNS.keys():
        active_cooldowns[key] = 0.0

    var max_steps: int = 1_000_000
    var step_count: int = 0
    while player_health > 0.0 and not battle_completed and step_count < max_steps:
        _update_active_cooldowns(SIM_STEP)
        _auto_use_hero_actives()
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

    world.visible = was_world_visible
    suppress_floating_text = false
    if speed_button != null and infinite_sim_button != null:
        speed_index = 0
        speed_button.disabled = false
        infinite_sim_button.disabled = false
    Engine.time_scale = SPEED_STEPS[speed_index]
    _update_speed_button_text()
    _update_ui()
    _update_speed_button_enabled_state()

func _update_active_cooldowns(delta: float) -> void:
    for key in active_cooldowns.keys():
        active_cooldowns[key] = max(0.0, float(active_cooldowns[key]) - delta)

func _auto_use_hero_actives() -> void:
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
    camera_2d.zoom = Vector2(0.2, 0.2) * EXTRA_ZOOM_IN_FACTOR
    camera_2d.position = Vector2(0, FLOOR_Y - 120.0)
    arrow_texture = _make_arrow_texture()

    for sprite in [bg_deep, bg_far, bg_mid, bg_near, ground]:
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.region_enabled = true
        sprite.centered = true

    bg_deep.region_rect = Rect2(0, 0, 80000, 400)
    bg_far.region_rect = Rect2(0, 0, 80000, 440)
    bg_mid.region_rect = Rect2(0, 0, 80000, 500)
    bg_near.region_rect = Rect2(0, 0, 80000, 560)
    ground.region_rect = Rect2(0, 0, 80000, 360)

    bg_deep.position = Vector2(0, 220)
    bg_far.position = Vector2(0, 305)
    bg_mid.position = Vector2(0, 430)
    bg_near.position = Vector2(0, 545)
    ground.position = Vector2(0, 760)
    _apply_level_background(current_level)

func _apply_level_background(level_index: int) -> void:
    var level_key: int = clamp(level_index, 1, 3)
    if level_key == displayed_bg_level:
        return
    displayed_bg_level = level_key
    var t: Dictionary = LEVEL_BG_THEMES[level_key]

    bg_deep.texture = _make_atari_sky_texture(256, 120, t["sky_base"], t["sky_star_a"], t["sky_star_b"])
    bg_far.texture = _make_atari_horizon_texture(256, 128, t["far"], t["sky_star_a"], 28)
    bg_mid.texture = _make_atari_horizon_texture(256, 128, t["mid"], t["sky_star_a"], 22)
    bg_near.texture = _make_atari_horizon_texture(256, 128, t["near"], t["sky_star_a"], 18)
    ground.texture = _make_atari_ground_texture(256, 96, t["ground_a"], t["ground_b"], t["ground_accent"])

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

func _make_atari_horizon_texture(w: int, h: int, body_color: Color, accent_color: Color, segment: int) -> ImageTexture:
    var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    var baseline: int = int(h * 0.72)
    for x in range(w):
        var step: int = int((x / max(2, segment)) % 4)
        var top: int = baseline - (step * max(2, segment / 4))
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
    var character_base: String = PLATFORMING_PACK_SPRITES + "/Characters/Default"
    var knight_visual: Dictionary = _make_pack_actor(
        character_base + "/character_beige_walk_a.png",
        character_base + "/character_beige_walk_b.png",
        character_base + "/character_beige_hit.png",
        HERO_FRAME_SIZE,
        Color(0.25, 0.74, 0.98, 1.0),
        "knight",
        HERO_RENDER_SCALE
    )
    var archer_visual: Dictionary = _make_pack_actor(
        character_base + "/character_green_walk_a.png",
        character_base + "/character_green_walk_b.png",
        character_base + "/character_green_hit.png",
        HERO_FRAME_SIZE,
        Color(0.99, 0.58, 0.17, 1.0),
        "archer",
        HERO_RENDER_SCALE
    )
    var guardian_visual: Dictionary = _make_pack_actor(
        character_base + "/character_pink_walk_a.png",
        character_base + "/character_pink_walk_b.png",
        character_base + "/character_pink_hit.png",
        HERO_FRAME_SIZE,
        Color(0.28, 0.86, 0.41, 1.0),
        "guardian",
        HERO_RENDER_SCALE
    )
    var mage_visual: Dictionary = _make_pack_actor(
        character_base + "/character_purple_walk_a.png",
        character_base + "/character_purple_walk_b.png",
        character_base + "/character_purple_hit.png",
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

    var enemy_base: String = PLATFORMING_PACK_SPRITES + "/Enemies/Default"
    var goblin_visual: Dictionary = _make_pack_actor(
        enemy_base + "/snail_walk_a.png",
        enemy_base + "/snail_walk_b.png",
        enemy_base + "/snail_shell.png",
        ENEMY_FRAME_SIZE,
        Color(0.83, 0.23, 0.23, 1.0),
        "goblin",
        ENEMY_RENDER_SCALE,
        true
    )
    var brute_visual: Dictionary = _make_pack_actor(
        enemy_base + "/slime_fire_walk_a.png",
        enemy_base + "/slime_fire_walk_b.png",
        enemy_base + "/slime_fire_flat.png",
        ENEMY_FRAME_SIZE,
        Color(0.75, 0.16, 0.58, 1.0),
        "brute",
        ENEMY_RENDER_SCALE,
        true
    )
    var flyer_visual: Dictionary = _make_pack_actor(
        enemy_base + "/bee_a.png",
        enemy_base + "/bee_b.png",
        enemy_base + "/bee_rest.png",
        ENEMY_FRAME_SIZE,
        Color(0.93, 0.67, 0.21, 1.0),
        "flyer",
        ENEMY_RENDER_SCALE,
        true
    )
    var boss_visual: Dictionary = _make_pack_actor(
        enemy_base + "/worm_ring_move_a.png",
        enemy_base + "/worm_ring_move_b.png",
        enemy_base + "/worm_ring_rest.png",
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
            "scale": ENEMY_RENDER_SCALE,
            "speed": 55.0,
            "coins": 10,
        },
        "brute": {
            "sheet": brute_visual["sheet"],
            "frame": brute_visual["frame"],
            "scale": ENEMY_RENDER_SCALE,
            "speed": 36.0,
            "coins": 16,
        },
        "flyer": {
            "sheet": flyer_visual["sheet"],
            "frame": flyer_visual["frame"],
            "scale": ENEMY_RENDER_SCALE,
            "speed": 68.0,
            "coins": 14,
        },
        "boss": {
            "sheet": boss_visual["sheet"],
            "frame": boss_visual["frame"],
            "scale": BOSS_RENDER_SCALE,
            "speed": 22.0,
            "coins": 120,
        },
    }

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
    _update_floating_damage_texts(delta)
    _update_hero_damage_float(delta)
    _update_hero_glow(delta)
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

func _simulate_step(delta: float, skip_visual_updates: bool = false) -> void:
    _apply_level_background(current_level)
    _gain_power(BASE_POWER_REGEN_PER_SEC * _power_gain_mult() * delta)
    _spawn_loop(delta)
    _update_heroes(delta)
    _update_enemies(delta)
    _update_arrows(delta)
    _update_coins()
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
    if spawn_timer > 0.0:
        return

    var lp: Dictionary = _level_params(current_level)
    var regular_count: int = int(lp["regular_count"])

    if regular_spawned < regular_count:
        if spawn_group_remaining <= 0:
            var remaining: int = regular_count - regular_spawned
            spawn_group_remaining = min(3, remaining)
        _spawn_enemy_for_level(current_level)
        regular_spawned += 1
        spawn_group_remaining -= 1
        if spawn_group_remaining > 0:
            spawn_timer = 0.2
        else:
            spawn_timer = 1.4
        return

    if not boss_spawned:
        _spawn_boss_for_level(current_level)
        boss_spawned = true
        boss_alive = true
        spawn_timer = 2.0
        return

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
        hero.position = Vector2(HERO_START_X - float(i) * 40.0, FLOOR_Y)
        var hero_visual: Dictionary = hero_sheets[hero_name]
        hero.setup(hero_visual["sheet"], hero_visual["frame"], float(hero_visual.get("scale", HERO_RENDER_SCALE)))
        hero.clicked.connect(_on_hero_clicked.bind(hero_name))
        hero_layer.add_child(hero)
        heroes.append(hero)

        var damage: float = 12.0 + 3.0 * float(SaveHandler.get_fishing_upgrade_level("core_%s_damage" % hero_name))
        var speed: float = 1.2 + 0.16 * float(SaveHandler.get_fishing_upgrade_level("core_%s_speed" % hero_name))
        damage *= _hero_damage_mult(hero_name)
        speed *= _hero_speed_mult(hero_name)
        hero_data[hero] = {
            "name": hero_name,
            "damage": damage,
            "speed": speed,
            "range": 4000.0 if hero_name == "archer" else 120.0,
            "cooldown": 0.0,
            "walk_speed": 80.0 * _walk_speed_mult(),
            "active_charge": 0.0,
            "active_bar_back": null,
            "active_bar_fill": null,
            "active_bar_width": 0.0,
        }
        _add_hero_active_bar(hero)

func _spawn_enemy_for_level(level_index: int) -> void:
    var key: String = str(LEVEL_ENEMY_TYPE.get(level_index, "goblin"))
    var lp: Dictionary = _level_params(level_index)
    var data: Dictionary = enemy_defs[key]

    var enemy: CombatSprite = HERO_SCENE.instantiate()
    enemy.position = Vector2(_next_enemy_spawn_x(), FLOOR_Y)
    var enemy_scale: float = float(data.get("scale", ENEMY_RENDER_SCALE))
    enemy.setup(data["sheet"], data["frame"], enemy_scale)
    enemy_layer.add_child(enemy)
    enemies.append(enemy)

    var hp: float = float(lp["enemy_hp"]) * _enemy_hp_mult()
    var bar_data: Dictionary = _add_health_bar(enemy, data["frame"], enemy_scale)
    var reward_mult: float = _level_reward_mult(level_index)
    enemy_data[enemy] = {
        "type": key,
        "is_boss": false,
        "hp": hp,
        "hp_max": hp,
        "speed": float(data["speed"]),
        "contact_dps": float(lp["enemy_contact_dps"]) * _enemy_contact_mult(),
        "coins": max(1, int(round(float(data["coins"]) * reward_mult))),
        "attack_cd": 0.0,
        "bar_fill": bar_data["fill"],
        "bar_width": bar_data["width"],
    }

func _spawn_boss_for_level(level_index: int) -> void:
    var lp: Dictionary = _level_params(level_index)
    var data: Dictionary = enemy_defs["boss"]

    var enemy: CombatSprite = HERO_SCENE.instantiate()
    enemy.position = Vector2(_next_enemy_spawn_x() + 120.0, FLOOR_Y)
    var boss_scale: float = float(data.get("scale", BOSS_RENDER_SCALE))
    enemy.setup(data["sheet"], data["frame"], boss_scale)
    enemy_layer.add_child(enemy)
    enemies.append(enemy)

    var hp: float = float(lp["boss_hp"]) * _boss_hp_mult()
    var bar_data: Dictionary = _add_health_bar(enemy, data["frame"], boss_scale)
    var reward_mult: float = _level_reward_mult(level_index)
    var boss_coin_value: int = max(1, int(round(float(data["coins"]) * reward_mult)))
    enemy_data[enemy] = {
        "type": "boss",
        "is_boss": true,
        "hp": hp,
        "hp_max": hp,
        "segments_total": BOSS_SEGMENTS,
        "segments_broken": 0,
        "segment_reward": max(1, int(round(float(boss_coin_value) / float(BOSS_SEGMENTS)))),
        "speed": float(data["speed"]),
        "contact_dps": float(lp["boss_contact_dps"]) * _enemy_contact_mult() * _boss_contact_mult(),
        "coins": boss_coin_value,
        "attack_cd": 0.0,
        "bar_fill": bar_data["fill"],
        "bar_width": bar_data["width"],
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

func _compose_three_frame_sheet_from_files(frame_paths: Array[String]) -> Dictionary:
    if frame_paths.size() != 3:
        return {}

    var frames: Array[Image] = []
    var max_w: int = 0
    var max_h: int = 0
    for frame_path in frame_paths:
        var img: Image = Image.new()
        if img.load(frame_path) != OK:
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

func _add_health_bar(enemy: CombatSprite, frame_size: Vector2i, scale_factor: float) -> Dictionary:
    var bar_width: float = max(28.0, float(frame_size.x) * scale_factor * 0.82)
    var back: ColorRect = ColorRect.new()
    back.color = Color(0.1, 0.1, 0.1, 0.9)
    back.position = Vector2(-bar_width * 0.5, -float(frame_size.y) * scale_factor - 24.0)
    back.size = Vector2(bar_width, 10)
    enemy.add_child(back)

    var fill: ColorRect = ColorRect.new()
    fill.color = Color(0.85, 0.2, 0.2, 1.0)
    fill.position = Vector2.ZERO
    fill.size = back.size
    back.add_child(fill)

    return {"fill": fill, "width": bar_width}

func _update_heroes(delta: float) -> void:
    var frontline_x: float = _frontline_x()
    for hero in heroes:
        if not is_instance_valid(hero):
            continue
        var h: Dictionary = hero_data[hero]
        _update_hero_active_bar(hero, h)
        h["cooldown"] = max(0.0, float(h["cooldown"]) - delta)
        var hero_name: String = str(h["name"])
        var should_catch_up: bool = hero_name == "archer" and hero.position.x < frontline_x - HERO_FORMATION_SPACING

        var target: CombatSprite = _nearest_enemy(hero.position)
        if target == null:
            hero.position.x += float(h["walk_speed"]) * delta
            hero.set_walking()
            hero_data[hero] = h
            continue

        var dist: float = hero.position.distance_to(target.position)
        if should_catch_up:
            hero.position.x += float(h["walk_speed"]) * 1.2 * delta
            hero.set_walking()
        elif dist > float(h["range"]):
            hero.position.x += float(h["walk_speed"]) * delta
            hero.set_walking()
        elif float(h["cooldown"]) <= 0.0:
            h["cooldown"] = 1.0 / max(0.1, float(h["speed"]))
            if hero_name == "archer":
                _spawn_arrow(hero.position + Vector2(28.0, -12.0), target, float(h["damage"]))
            else:
                _damage_enemy(target, float(h["damage"]))
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

func _spawn_arrow(from_pos: Vector2, target_enemy: CombatSprite, damage: float) -> void:
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
        "ttl": 4.0,
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

        var dir: Vector2 = arrow.get("dir", Vector2.RIGHT)
        var speed: float = float(arrow.get("speed", 420.0))
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
                _damage_enemy(target_enemy, float(arrow.get("damage", 0.0)))
            sprite.queue_free()
            arrows.remove_at(i)

func _update_enemies(delta: float) -> void:
    var armor_scale: float = _player_armor_scale()
    if shield_time > 0.0:
        armor_scale *= 0.4

    var frontline_x: float = _frontline_x()

    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var e: Dictionary = enemy_data[enemy]
        e["attack_cd"] = max(0.0, float(e["attack_cd"]) - delta)

        var colliding: bool = enemy.position.x <= frontline_x + CONTACT_RANGE
        if not colliding:
            enemy.position.x -= float(e["speed"]) * delta
            enemy.set_walking()
        else:
            _apply_player_damage(float(e["contact_dps"]) * armor_scale * delta, enemy.position + Vector2(0.0, -90.0))
            if float(e["attack_cd"]) <= 0.0:
                e["attack_cd"] = 0.75
                enemy.trigger_attack()

        _update_enemy_health_bar(e)
        enemy_data[enemy] = e

    _enforce_enemy_formation()

func _enforce_enemy_formation() -> void:
    var alive: Array[CombatSprite] = []
    for enemy in enemies:
        if is_instance_valid(enemy):
            alive.append(enemy)

    if alive.size() <= 1:
        return

    alive.sort_custom(func(a: CombatSprite, b: CombatSprite): return a.position.x < b.position.x)

    for i in range(1, alive.size()):
        var lead: CombatSprite = alive[i - 1]
        var trailing: CombatSprite = alive[i]
        var min_x: float = lead.position.x + ENEMY_FORMATION_SPACING
        if trailing.position.x < min_x:
            trailing.position.x = min_x

func _update_enemy_health_bar(e: Dictionary) -> void:
    var bar_fill: ColorRect = e.get("bar_fill", null)
    if bar_fill == null:
        return
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
    camera_2d.position.x = anchor_x_world

    bg_deep.position.x = camera_2d.position.x * 0.08
    bg_far.position.x = camera_2d.position.x * 0.22
    bg_mid.position.x = camera_2d.position.x * 0.42
    bg_near.position.x = camera_2d.position.x * 0.66
    ground.position.x = camera_2d.position.x * 0.9

func _nearest_enemy(from_pos: Vector2) -> CombatSprite:
    var best: CombatSprite = null
    var best_dist: float = INF
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var d: float = from_pos.distance_to(enemy.position)
        if d < best_dist:
            best_dist = d
            best = enemy
    return best

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

func _damage_enemy(enemy: CombatSprite, amount: float) -> void:
    if not is_instance_valid(enemy) or not enemy_data.has(enemy):
        return
    var e: Dictionary = enemy_data[enemy]
    var prev_hp: float = float(e["hp"])
    e["hp"] = prev_hp - amount
    _spawn_floating_damage_text(enemy.position + Vector2(randf_range(-14.0, 14.0), -120.0), amount, Color(1.0, 0.84, 0.56, 1.0))
    if bool(e.get("is_boss", false)):
        _award_boss_segments(enemy, e, prev_hp)
    enemy_data[enemy] = e
    if float(e["hp"]) <= 0.0:
        _kill_enemy(enemy)

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
        _spawn_coin(enemy.position + Vector2(0.0, -16.0), reward_each)
    e["segments_broken"] = int(e.get("segments_broken", 0)) + newly_broken
    boss_segments_broken += newly_broken

func _kill_enemy(enemy: CombatSprite) -> void:
    if not enemy_data.has(enemy):
        return
    var e: Dictionary = enemy_data[enemy]
    if not bool(e.get("is_boss", false)):
        _spawn_coin(enemy.position, int(e["coins"]))

    _gain_power(4.0 * _power_gain_mult())
    enemies_killed += 1

    if bool(e["is_boss"]):
        boss_alive = false
        _on_boss_defeated()
    else:
        regular_killed += 1

    enemies.erase(enemy)
    enemy_data.erase(enemy)
    enemy.queue_free()

func _spawn_coin(pos: Vector2, value: int) -> void:
    var coin: CoinPickup = COIN_SCENE.instantiate()
    coin.position = pos + Vector2(randf_range(-8.0, 8.0), randf_range(-10.0, 4.0))
    var launch_vx: float = randf_range(-55.0, 240.0)
    var launch_vy: float = randf_range(-360.0, -190.0)
    coin.launch(Vector2(launch_vx, launch_vy), FLOOR_Y + 12.0)
    coin.value = max(1, int(round(float(value) * _coin_mult())))
    coin.collected.connect(_on_coin_collected)
    coin_layer.add_child(coin)
    coins.append(coin)

func _update_coins() -> void:
    for coin in coins.duplicate():
        if not is_instance_valid(coin):
            coins.erase(coin)
            continue
        for hero in heroes:
            if is_instance_valid(hero) and hero.position.distance_to(coin.position) <= 70.0:
                coin.collect_by_hero()
                break

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
    if not is_instance_valid(coin):
        return
    var amount: int = int(coin.value)
    if by_cursor:
        amount = int(round(float(amount) * _cursor_bonus_mult()))

    SaveHandler.fishing_currency += amount
    SaveHandler.fishing_lifetime_coins += amount
    SaveHandler.save_fishing_progress()
    coins_gained += amount

    coins.erase(coin)
    coin.queue_free()

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
    var active_cost: float = _active_cost()
    var charge: float = float(h.get("active_charge", 0.0))
    var to_charge: float = min(ACTIVE_CHARGE_PER_CLICK, power, max(0.0, active_cost - charge))
    if to_charge > 0.0:
        power -= to_charge
        charge += to_charge
        h["active_charge"] = charge
        _update_hero_active_bar(hero, h)

    var cooldown_remaining: float = float(active_cooldowns.get(hero_name, 0.0))
    if charge + 0.001 < active_cost or cooldown_remaining > 0.0:
        hero_data[hero] = h
        return

    h["active_charge"] = max(0.0, charge - active_cost)
    _update_hero_active_bar(hero, h)
    hero_data[hero] = h
    _execute_hero_active(hero, hero_name, skip_anim)
    active_cooldowns[hero_name] = float(ACTIVE_COOLDOWNS.get(hero_name, 15.0)) * _active_cooldown_mult()

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
    bar_back.color = Color(0.08, 0.08, 0.08, 0.85)
    bar_back.position = Vector2(-22.0, -122.0)
    bar_back.size = Vector2(44.0, 6.0)
    bar_back.visible = false
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

    bar_back.visible = unlocked and not battle_completed
    if not unlocked:
        bar_fill.size.x = 0.0
        return

    var active_cost: float = max(1.0, _active_cost())
    var charge: float = clamp(float(h.get("active_charge", 0.0)), 0.0, active_cost)
    var pct: float = charge / active_cost
    var full_width: float = float(h.get("active_bar_width", 44.0))
    bar_fill.size.x = full_width * pct

func _execute_hero_active(hero: CombatSprite, hero_name: String, skip_anim: bool) -> void:
    _trigger_hero_glow(hero)
    if not skip_anim:
        hero.trigger_attack()

    match hero_name:
        "knight":
            var before_hp: float = player_health
            player_health = min(300.0, player_health + 45.0)
            var healed: float = max(0.0, player_health - before_hp)
            if healed > 0.0:
                _spawn_floating_heal_text(hero.position + Vector2(randf_range(-10.0, 10.0), -130.0), healed)
            var target: CombatSprite = _nearest_enemy(hero.position)
            if target != null:
                _damage_enemy(target, 80.0)
        "archer":
            for enemy in enemies:
                _damage_enemy(enemy, 55.0)
        "guardian":
            shield_time = 4.0
        "mage":
            for enemy in enemies:
                if is_instance_valid(enemy) and hero.position.distance_to(enemy.position) < 520.0:
                    _damage_enemy(enemy, 85.0)

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
    match clamp(level_index, 1, 3):
        1:
            return 1.0
        2:
            return 2.25
        3:
            return 4.4
    return 1.0

func _max_unlocked_level() -> int:
    return clamp(int(SaveHandler.fishing_max_unlocked_battle_level), 1, 3)

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

    if key == "auto_attack_unlock":
        battle_mods["damage_mult_all"] = float(battle_mods["damage_mult_all"]) + 0.06
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
    if hero_name == "knight" and SaveHandler.has_fishing_upgrade("auto_attack_unlock"):
        mult += 0.08
    return mult

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
    return max(24.0, 80.0 * float(battle_mods.get("active_cost_mult", 1.0)))

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
    floating_damage_texts.append({
        "label": label,
        "ttl": 1.0,
        "speed": 30.0 + randf_range(0.0, 20.0),
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
        c.a = clamp(ttl / 1.0, 0.0, 1.0)
        label.modulate = c
        item["ttl"] = ttl
        floating_damage_texts[i] = item

func _player_armor_scale() -> float:
    var base: float = 1.0 - min(0.75, 0.035 * float(SaveHandler.get_fishing_upgrade_level("core_armor")))
    base *= max(0.45, 1.0 - float(battle_mods.get("armor_bonus", 0.0)))
    return base

func _update_ui() -> void:
    health_label.text = "L%d  Health: %d   Power: %d/%d" % [current_level, int(max(0.0, player_health)), int(power), int(_max_power())]
    currency_label.text = "Currency: %d" % SaveHandler.fishing_currency

func _on_boss_defeated() -> void:
    if battle_completed:
        return
    if current_level >= int(SaveHandler.fishing_max_unlocked_battle_level) and current_level < 3:
        SaveHandler.fishing_max_unlocked_battle_level = current_level + 1
        SaveHandler.fishing_next_battle_level = SaveHandler.fishing_max_unlocked_battle_level
    _end_battle(true)

func _end_battle(victory: bool) -> void:
    if battle_completed:
        return
    battle_completed = true
    battle_victory = victory
    summary_finalized = false
    post_battle_sweep_time = 2.8
    defeat_anim_time = 0.0
    if not victory:
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
    _update_coins()

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

func _finalize_battle_summary() -> void:
    if summary_finalized:
        return
    summary_finalized = true
    summary_panel.show()
    var title: String = "Victory!" if battle_victory else "Defeated."
    summary_label.text = "%s\nLevel: %d\nEnemies killed: %d\nBoss segments: %d\nCoins gained: %d" % [title, current_level, enemies_killed, boss_segments_broken, coins_gained]
    SaveHandler.fishing_last_battle_summary = {
        "victory": battle_victory,
        "level": current_level,
        "enemies_killed": enemies_killed,
        "boss_segments_broken": boss_segments_broken,
        "coins_gained": coins_gained,
    }
    SaveHandler.save_fishing_progress()
    _update_speed_button_enabled_state()

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
    _set_next_battle_level_and_exit(current_level)

func _show_level_choice_dialog(max_level: int) -> void:
    if level_choice_dialog == null:
        _set_next_battle_level_and_exit(1)
        return

    level_choice_dialog.dialog_text = "You unlocked new battle levels by defeating bosses.\nChoose your next level."
    for child in level_choice_dialog.get_children():
        if child is Button and child.name.begins_with("LevelChoiceButton"):
            child.free()

    for level in range(1, max_level + 1):
        var button: Button = level_choice_dialog.add_button("Level %d" % level, true, "level_%d" % level)
        button.name = "LevelChoiceButton%d" % level

    level_choice_dialog.popup_centered()

func _on_level_choice_action(action: StringName) -> void:
    var action_text: String = str(action)
    if not action_text.begins_with("level_"):
        return
    var level: int = int(action_text.trim_prefix("level_"))
    _set_next_battle_level_and_exit(level)

func _set_next_battle_level_and_exit(level: int) -> void:
    SaveHandler.fishing_next_battle_level = clamp(level, 1, _max_unlocked_level())
    SaveHandler.save_fishing_progress()
    Global.ensure_default_game_mode_data()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = false
    SceneChanger.change_to_new_scene(Util.PATH_MAIN)
