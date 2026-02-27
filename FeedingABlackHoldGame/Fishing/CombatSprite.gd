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
    _setup_weapon_visual(weapon_type, frame_size, scale_factor)
    weapon_layer.visible = false

func set_walking() -> void:
    if is_attacking or is_defeated:
        return
    if sprite.animation != "walk":
        sprite.play("walk")

func trigger_attack() -> void:
    if is_defeated or is_attacking:
        return
    is_attacking = true
    _show_attack_weapon(true)
    _play_attack_telegraph()
    sprite.play("attack")
    await sprite.animation_finished
    if is_defeated:
        is_attacking = false
        _show_attack_weapon(false)
        return
    is_attacking = false
    _show_attack_weapon(false)
    sprite.play("walk")
    sprite.scale = base_sprite_scale
    sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func set_defeated() -> void:
    if not _ensure_nodes():
        return
    is_defeated = true
    is_attacking = false
    _show_attack_weapon(false)
    if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("walk"):
        sprite.play("walk")
    sprite.stop()
    if collider != null:
        collider.disabled = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        clicked.emit(self)

func _setup_weapon_visual(role: String, frame_size: Vector2i, scale_factor: float) -> void:
    if weapon_layer == null:
        return
    for child in weapon_layer.get_children():
        child.queue_free()

    var lower: String = role.to_lower()
    if lower == "knight":
        _add_line(weapon_layer, [Vector2(12, -20), Vector2(28, -28)], 2.1 * scale_factor, Color(0.88, 0.9, 0.95, 1.0))
        _add_line(weapon_layer, [Vector2(10, -18), Vector2(16, -14)], 2.1 * scale_factor, Color(0.5, 0.35, 0.18, 1.0))
    elif lower == "archer":
        _add_line(weapon_layer, [Vector2(10, -24), Vector2(18, -30), Vector2(24, -24), Vector2(18, -18), Vector2(10, -24)], 1.8 * scale_factor, Color(0.58, 0.4, 0.2, 1.0))
        _add_line(weapon_layer, [Vector2(10, -24), Vector2(24, -24)], 1.3 * scale_factor, Color(0.92, 0.92, 0.92, 1.0))
    elif lower == "guardian":
        var shield: Polygon2D = Polygon2D.new()
        shield.polygon = PackedVector2Array([Vector2(12, -30), Vector2(24, -24), Vector2(24, -10), Vector2(12, -4), Vector2(0, -10), Vector2(0, -24)])
        shield.color = Color(0.34, 0.6, 0.85, 1.0)
        shield.scale = Vector2.ONE * (0.65 * scale_factor)
        weapon_layer.add_child(shield)
        _add_line(weapon_layer, [Vector2(8, -17), Vector2(16, -17)], 1.8 * scale_factor, Color(0.85, 0.92, 0.98, 1.0))
    elif lower == "mage":
        _add_line(weapon_layer, [Vector2(10, -28), Vector2(22, -12)], 1.9 * scale_factor, Color(0.58, 0.42, 0.22, 1.0))
        var orb: Polygon2D = Polygon2D.new()
        orb.polygon = PackedVector2Array([Vector2(20, -32), Vector2(24, -28), Vector2(20, -24), Vector2(16, -28)])
        orb.color = Color(0.7, 0.32, 0.95, 1.0)
        orb.scale = Vector2.ONE * (0.75 * scale_factor)
        weapon_layer.add_child(orb)

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

func _show_attack_weapon(show_weapon: bool) -> void:
    if weapon_layer == null:
        return
    if weapon_layer.get_child_count() == 0:
        weapon_layer.visible = false
        return
    weapon_layer.visible = show_weapon

func _play_attack_telegraph() -> void:
    if sprite == null:
        return
    var tween: Tween = create_tween().set_parallel(true)
    tween.tween_property(sprite, "scale", base_sprite_scale * 1.16, 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(sprite, "modulate", Color(1.35, 1.35, 1.1, 1.0), 0.06).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
    tween.chain().tween_property(sprite, "scale", base_sprite_scale, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.parallel().tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
