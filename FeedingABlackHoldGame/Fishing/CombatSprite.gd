extends Area2D
class_name CombatSprite

signal clicked(sprite: CombatSprite)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var is_attacking := false
var is_defeated := false

func _ensure_nodes() -> bool:
    if sprite == null:
        sprite = get_node_or_null("AnimatedSprite2D")
    if collider == null:
        collider = get_node_or_null("CollisionShape2D")
    return sprite != null and collider != null

func setup(sheet: Texture2D, frame_size: Vector2i, scale_factor := 2.0) -> void:
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
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

    var circle := CircleShape2D.new()
    circle.radius = max(10.0, float(frame_size.x) * 0.45 * scale_factor)
    collider.shape = circle

func set_walking() -> void:
    if is_attacking or is_defeated:
        return
    if sprite.animation != "walk":
        sprite.play("walk")

func trigger_attack() -> void:
    if is_defeated or is_attacking:
        return
    is_attacking = true
    sprite.play("attack")
    await sprite.animation_finished
    if is_defeated:
        is_attacking = false
        return
    is_attacking = false
    sprite.play("walk")

func set_defeated() -> void:
    if not _ensure_nodes():
        return
    is_defeated = true
    is_attacking = false
    if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("walk"):
        sprite.play("walk")
    sprite.stop()
    if collider != null:
        collider.disabled = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        clicked.emit(self)
