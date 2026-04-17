extends Control






signal spawn_selected(angle: float)
signal resume_selected()

var point_count: int = 1
var point_angles: Array = []
var hover_index: int = -1
var show_resume: bool = false
var resume_btn: Button = null


const PLANET_DISPLAY_RADIUS: float = 100.0
const POINT_ORBIT_RADIUS: float = 140.0
const POINT_SIZE: float = 12.0
const POINT_HOVER_SIZE: float = 18.0


const BG_COLOR: = Color(0.02, 0.02, 0.05, 0.92)
const PLANET_COLOR: = Color(0.08, 0.1, 0.14)
const PLANET_EDGE: = Color(0.3, 1.0, 1.2, 0.4)
const POINT_NORMAL: = Color(0.3, 1.0, 1.2, 0.6)
const POINT_HOVER: = Color(0.5, 1.8, 2.0)
const POINT_GLOW: = Color(0.3, 1.5, 2.0, 0.2)
const LABEL_COLOR: = Color(0.7, 0.9, 1.0)

var center: Vector2 = Vector2.ZERO
var time: float = 0.0

func setup(count: int, has_resume: bool = false, custom_angles: Array = []):
    point_count = count
    show_resume = has_resume
    point_angles.clear()
    if custom_angles.size() > 0:

        point_angles = custom_angles.duplicate()
        point_count = point_angles.size()
    else:
        for i in range(count):
            var angle = - PI * 0.5 + (TAU / count) * i
            point_angles.append(angle)

func _ready():

    var vp_size = get_viewport().get_visible_rect().size
    position = Vector2.ZERO
    size = vp_size


    var title = Label.new()
    title.text = "🕛 스폰 지점을 선택하세요"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.position = Vector2(vp_size.x * 0.5 - 150, 60)
    title.size = Vector2(300, 40)
    title.add_theme_font_size_override("font_size", 20)
    title.add_theme_color_override("font_color", LABEL_COLOR)
    add_child(title)


    if show_resume:
        resume_btn = Button.new()
        resume_btn.text = "📌"
        var btn_size = 64
        resume_btn.custom_minimum_size = Vector2(btn_size, btn_size)
        resume_btn.position = Vector2(vp_size.x * 0.5 - btn_size * 0.5, vp_size.y * 0.5 - btn_size * 0.5)
        resume_btn.add_theme_font_size_override("font_size", 28)
        resume_btn.tooltip_text = "전 지점에서 출발"


        var style = StyleBoxFlat.new()
        style.bg_color = Color(0.12, 0.05, 0.02, 0.85)
        style.border_color = Color(1.0, 0.5, 0.15, 0.8)
        style.set_border_width_all(2)
        style.set_corner_radius_all(btn_size / 2)
        var hover_s = style.duplicate() as StyleBoxFlat
        hover_s.bg_color = Color(0.2, 0.08, 0.03, 0.95)
        hover_s.border_color = Color(1.5, 0.7, 0.2)
        resume_btn.add_theme_stylebox_override("normal", style)
        resume_btn.add_theme_stylebox_override("hover", hover_s)
        resume_btn.add_theme_stylebox_override("pressed", hover_s)
        resume_btn.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))

        resume_btn.pressed.connect(_on_resume_pressed)
        add_child(resume_btn)

func _process(delta):
    time += delta
    _update_hover()
    queue_redraw()

func _update_hover():
    var mouse = get_local_mouse_position()
    hover_index = -1
    var best_dist = INF

    for i in range(point_angles.size()):
        var angle = point_angles[i]
        var px = center.x + cos(angle) * POINT_ORBIT_RADIUS
        var py = center.y + sin(angle) * POINT_ORBIT_RADIUS
        var dist = mouse.distance_to(Vector2(px, py))
        if dist < 30.0 and dist < best_dist:
            best_dist = dist
            hover_index = i


func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if hover_index >= 0:
            spawn_selected.emit(point_angles[hover_index])
            get_viewport().set_input_as_handled()
            queue_free()

func _on_resume_pressed():
    resume_selected.emit()
    queue_free()

func _draw():
    var vp_size = get_viewport().get_visible_rect().size
    center = vp_size * 0.5


    draw_rect(Rect2(Vector2.ZERO, vp_size), BG_COLOR)


    draw_circle(center, PLANET_DISPLAY_RADIUS, PLANET_COLOR)
    draw_arc(center, PLANET_DISPLAY_RADIUS, 0, TAU, 64, PLANET_EDGE, 2.0)


    for i in range(point_angles.size()):
        var angle = point_angles[i]
        var px = center.x + cos(angle) * POINT_ORBIT_RADIUS
        var py = center.y + sin(angle) * POINT_ORBIT_RADIUS
        var pos = Vector2(px, py)

        var is_hover = (i == hover_index)
        var pulse = (sin(time * 3.0 + i * 1.5) + 1.0) * 0.5

        if is_hover:
            draw_circle(pos, POINT_HOVER_SIZE + pulse * 4.0, POINT_GLOW)
            draw_circle(pos, POINT_HOVER_SIZE, POINT_HOVER)
            var arrow_start = center + Vector2(cos(angle), sin(angle)) * (PLANET_DISPLAY_RADIUS + 8)
            var arrow_end = pos - Vector2(cos(angle), sin(angle)) * (POINT_HOVER_SIZE + 2)
            draw_line(arrow_start, arrow_end, POINT_HOVER, 2.0)
        else:
            var sz = POINT_SIZE + pulse * 2.0
            draw_circle(pos, sz + 4.0, Color(POINT_GLOW.r, POINT_GLOW.g, POINT_GLOW.b, 0.1 + pulse * 0.05))
            draw_circle(pos, sz, POINT_NORMAL)
