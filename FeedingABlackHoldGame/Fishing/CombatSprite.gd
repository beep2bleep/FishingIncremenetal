extends Area2D
class_name CombatSprite

signal clicked(sprite: CombatSprite)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var weapon_layer: Node2D = get_node_or_null("WeaponLayer")

var is_attacking := false
var is_defeated := false
var base_sprite_scale: Vector2 = Vector2.ONE
var weapon_type: String = ""
var weapon_base_offset: Vector2 = Vector2.ZERO
var weapon_idle_offset: Vector2 = Vector2.ZERO
var weapon_float_phase: float = 0.0
var weapon_float_speed: float = 2.8
var weapon_float_amp: float = 2.2
var weapon_attack_tween: Tween = null
const WEAPON_SCALE_RATIO: float = 3.0
const WEAPON_HEIGHT_RATIO: float = -3.0

func _ensure_nodes() -> bool:
    if sprite == null:
        sprite = get_node_or_null("AnimatedSprite2D")
    if collider == null:
        collider = get_node_or_null("CollisionShape2D")
    if weapon_layer == null:
        weapon_layer = get_node_or_null("WeaponLayer")
    if weapon_layer == null:
        weapon_layer = Node2D.new()
        weapon_layer.name = "WeaponLayer"
        add_child(weapon_layer)
        weapon_layer.position = Vector2.ZERO
    return sprite != null and collider != null and weapon_layer != null

func setup(sheet: Texture2D, frame_size: Vector2i, scale_factor := 2.0, role := "") -> void:
    if not _ensure_nodes():
        push_error("CombatSprite is missing AnimatedSprite2D or CollisionShape2D.")
        return

    var frames := SpriteFrames.new()
    frames.add_animation("walk")
    frames.set_animation_loop("walk", true)
    frames.set_animation_speed("walk", 6.0)

    for i in [0, 1]:
        var atlas := AtlasTexture.new()
        atlas.atlas = sheet
        atlas.region = Rect2i(Vector2i(frame_size.x * i, 0), frame_size)
        frames.add_frame("walk", atlas)

    frames.add_animation("attack")
    frames.set_animation_loop("attack", false)
    frames.set_animation_speed("attack", 14.0)
    for i in [2, 1, 2]:
        var atk := AtlasTexture.new()
        atk.atlas = sheet
        atk.region = Rect2i(Vector2i(frame_size.x * i, 0), frame_size)
        frames.add_frame("attack", atk)

    sprite.sprite_frames = frames
    sprite.play("walk")
    sprite.scale = Vector2.ONE * scale_factor
    base_sprite_scale = sprite.scale
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

    var circle := CircleShape2D.new()
    circle.radius = max(10.0, float(frame_size.x) * 0.45 * scale_factor)
    collider.shape = circle

    weapon_type = str(role)
    var hero_size: Vector2 = Vector2(float(frame_size.x), float(frame_size.y)) * scale_factor
    weapon_base_offset = Vector2(hero_size.x * 0.12, -hero_size.y * WEAPON_HEIGHT_RATIO)
    weapon_layer.scale = Vector2.ONE * (scale_factor * WEAPON_SCALE_RATIO)
    weapon_float_amp = 2.2 * scale_factor
    _setup_weapon_visual(weapon_type, frame_size, scale_factor)
    weapon_layer.visible = weapon_layer.get_child_count() > 0
    weapon_layer.rotation = 0.0
    weapon_float_phase = randf() * TAU
    set_process(true)

func set_walking() -> void:
    if is_attacking or is_defeated:
        return
    if sprite.animation != "walk":
        sprite.play("walk")

func trigger_attack() -> void:
    if is_defeated or is_attacking:
        return
    is_attacking = true
    _play_weapon_attack_motion()
    _play_attack_telegraph()
    sprite.play("attack")
    await sprite.animation_finished
    if is_defeated:
        is_attacking = false
        _stop_weapon_tween()
        return
    is_attacking = false
    sprite.play("walk")
    sprite.scale = base_sprite_scale
    sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func set_defeated() -> void:
    if not _ensure_nodes():
        return
    is_defeated = true
    is_attacking = false
    _stop_weapon_tween()
    if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("walk"):
        sprite.play("walk")
    sprite.stop()
    if collider != null:
        collider.disabled = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        clicked.emit(self)

func _process(delta: float) -> void:
    if weapon_layer == null or weapon_layer.get_child_count() == 0:
        return
    if is_defeated:
        return
    weapon_float_phase += delta * weapon_float_speed
    var bob_y: float = sin(weapon_float_phase) * weapon_float_amp
    weapon_layer.position = weapon_base_offset + weapon_idle_offset + Vector2(0.0, bob_y)

func _setup_weapon_visual(role: String, frame_size: Vector2i, scale_factor: float) -> void:
    if weapon_layer == null:
        return
    for child in weapon_layer.get_children():
        child.queue_free()

    var lower: String = role.to_lower()
    if lower == "knight":
        _add_line(weapon_layer, [Vector2(12, -20), Vector2(28, -28)], 2.1, Color(0.88, 0.9, 0.95, 1.0))
        _add_line(weapon_layer, [Vector2(10, -18), Vector2(16, -14)], 2.1, Color(0.5, 0.35, 0.18, 1.0))
        weapon_idle_offset = Vector2(4, 2)
    elif lower == "archer":
        _add_line(weapon_layer, [Vector2(10, -24), Vector2(18, -30), Vector2(24, -24), Vector2(18, -18), Vector2(10, -24)], 1.8, Color(0.58, 0.4, 0.2, 1.0))
        _add_line(weapon_layer, [Vector2(10, -24), Vector2(24, -24)], 1.3, Color(0.92, 0.92, 0.92, 1.0))
        weapon_idle_offset = Vector2(3, 3)
    elif lower == "guardian":
        var shield: Polygon2D = Polygon2D.new()
        shield.polygon = PackedVector2Array([Vector2(12, -30), Vector2(24, -24), Vector2(24, -10), Vector2(12, -4), Vector2(0, -10), Vector2(0, -24)])
        shield.color = Color(0.34, 0.6, 0.85, 1.0)
        shield.scale = Vector2.ONE * 0.65
        weapon_layer.add_child(shield)
        _add_line(weapon_layer, [Vector2(8, -17), Vector2(16, -17)], 1.8, Color(0.85, 0.92, 0.98, 1.0))
        weapon_idle_offset = Vector2(4, 4)
    elif lower == "mage":
        _add_line(weapon_layer, [Vector2(10, -28), Vector2(22, -12)], 1.9, Color(0.58, 0.42, 0.22, 1.0))
        var orb: Polygon2D = Polygon2D.new()
        orb.polygon = PackedVector2Array([Vector2(20, -32), Vector2(24, -28), Vector2(20, -24), Vector2(16, -28)])
        orb.color = Color(0.7, 0.32, 0.95, 1.0)
        orb.scale = Vector2.ONE * 0.75
        weapon_layer.add_child(orb)
        weapon_idle_offset = Vector2(4, 2)
    else:
        weapon_idle_offset = Vector2.ZERO

func _add_line(parent: Node, points: Array[Vector2], width: float, color: Color) -> void:
    var line: Line2D = Line2D.new()
    line.width = width
    line.default_color = color
    line.antialiased = false
    line.joint_mode = Line2D.LINE_JOINT_ROUND
    line.begin_cap_mode = Line2D.LINE_CAP_ROUND
    line.end_cap_mode = Line2D.LINE_CAP_ROUND
    line.points = PackedVector2Array(points)
    parent.add_child(line)

func get_projectile_spawn_point() -> Vector2:
    # Anchor around center of the floating bow for archer projectiles.
    if weapon_layer != null and weapon_type.to_lower() == "archer" and weapon_layer.get_child_count() > 0:
        return weapon_layer.global_position + Vector2(20.0, -20.0)
    return global_position + Vector2(26.0, -12.0)

func _stop_weapon_tween() -> void:
    if weapon_attack_tween != null:
        weapon_attack_tween.kill()
        weapon_attack_tween = null
    if weapon_layer != null:
        weapon_layer.rotation = 0.0

func _play_weapon_attack_motion() -> void:
    if weapon_layer == null or weapon_layer.get_child_count() == 0:
        return
    _stop_weapon_tween()
    var lower: String = weapon_type.to_lower()
    weapon_attack_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    match lower:
        "archer":
            weapon_attack_tween.tween_property(weapon_layer, "rotation", -0.35, 0.06)
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.28, 0.08)
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.0, 0.08)
        "knight":
            weapon_attack_tween.tween_property(weapon_layer, "rotation", -0.95, 0.08)
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.45, 0.1)
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.0, 0.12)
        "guardian":
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.42, 0.08)
            weapon_attack_tween.tween_property(weapon_layer, "rotation", -0.22, 0.08)
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.0, 0.1)
        "mage":
            weapon_attack_tween.tween_property(weapon_layer, "rotation", -0.5, 0.08)
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.24, 0.09)
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.0, 0.1)
        _:
            weapon_attack_tween.tween_property(weapon_layer, "rotation", 0.0, 0.06)
    weapon_attack_tween.finished.connect(func() -> void:
        weapon_attack_tween = null
    )

func _play_attack_telegraph() -> void:
    if sprite == null:
        return
    var base_pos: Vector2 = position
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(sprite, "scale", base_sprite_scale * 1.16, 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(sprite, "modulate", Color(1.45, 1.45, 1.2, 1.0), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
    tween.chain().tween_property(sprite, "modulate", Color(0.78, 0.78, 0.78, 1.0), 0.04).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
    tween.chain().tween_property(sprite, "modulate", Color(1.25, 1.25, 1.1, 1.0), 0.04).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
    tween.chain().tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

    var shake: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    shake.tween_property(self, "position", base_pos + Vector2(3.0, 0.0), 0.025)
    shake.tween_property(self, "position", base_pos + Vector2(-3.0, 0.0), 0.03)
    shake.tween_property(self, "position", base_pos + Vector2(2.0, 0.0), 0.03)
    shake.tween_property(self, "position", base_pos + Vector2(-2.0, 0.0), 0.03)
    shake.tween_property(self, "position", base_pos, 0.03)

    tween.chain().tween_property(sprite, "scale", base_sprite_scale, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
