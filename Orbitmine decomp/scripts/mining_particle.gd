extends Node2D






var fragments: Array = []


var ring_radius: float = 0.0
var ring_max_radius: float = 0.0
var ring_color: Color = Color.WHITE
var ring_active: bool = false
const RING_SPEED: float = 180.0

func setup(world_pos: Vector2, block_color: Color, count: int = 6, show_ring: bool = true):
    global_position = world_pos
    add_to_group("mining_particles")


    for i in range(count):
        var angle = randf() * TAU
        var speed = randf_range(60.0, 160.0)
        fragments.append({
            "pos": Vector2.ZERO, 
            "vel": Vector2(cos(angle), sin(angle)) * speed, 
            "color": block_color.lightened(randf_range(0.0, 0.3)), 
            "size": randf_range(1.5, 3.5), 
            "lifetime": randf_range(0.2, 0.4), 
            "timer": 0.0, 
        })


    if show_ring:
        ring_active = true
        ring_radius = 2.0
        ring_max_radius = 12.0 + count * 1.5
        ring_color = block_color

func _process(delta):
    var all_done = true
    for f in fragments:
        f.timer += delta
        if f.timer < f.lifetime:
            all_done = false
            f.vel *= 0.92
            f.pos += f.vel * delta


    if ring_active:
        ring_radius += RING_SPEED * delta
        if ring_radius >= ring_max_radius:
            ring_active = false
        else:
            all_done = false

    if all_done:
        queue_free()
        return

    queue_redraw()

func _draw():

    if ring_active and ring_radius > 0:
        var ring_progress = ring_radius / ring_max_radius
        var ring_alpha = 0.6 * (1.0 - ring_progress)
        var ring_width = 2.0 * (1.0 - ring_progress * 0.5)

        draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 24, 
            Color(ring_color.r, ring_color.g, ring_color.b, ring_alpha * 0.3), ring_width + 3.0)

        draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 24, 
            Color(ring_color.r, ring_color.g, ring_color.b, ring_alpha), ring_width)


    for f in fragments:
        if f.timer >= f.lifetime:
            continue
        var alpha = 1.0 - (f.timer / f.lifetime)
        var s = f.size * (1.0 - f.timer / f.lifetime * 0.5)
        var c = Color(f.color.r, f.color.g, f.color.b, alpha)
        draw_rect(Rect2(f.pos - Vector2(s, s) * 0.5, Vector2(s, s)), c)
