extends Node2D







@onready var ship: CharacterBody2D = $MiningShip
@onready var camera: Camera2D = $MiningShip / Camera2D


const STATION_POS: = Vector2(0, 300)
const PLANET_RADIUS: = 90.0
const DOCK_TRIGGER: = 200.0
const LAND_POS_OFFSET: = Vector2(0, -105)
const EXIT_DISTANCE: = 800.0
const SHIP_START_POS: = Vector2(0, 200)
const FROM_MINING_START: = Vector2(0, -500)


const LAND_DURATION: = 0.8
const TAKEOFF_DURATION: = 0.5
const TAKEOFF_HEIGHT: = 150.0


enum State{FREE, LANDING, DOCKED, TAKEOFF}
var state: int = State.FREE
var is_transitioning: = false
var upgrade_menu: Control = null


var land_start_pos: = Vector2.ZERO
var land_target_pos: = Vector2.ZERO
var land_timer: = 0.0
var land_start_rotation: = 0.0


var takeoff_start_pos: = Vector2.ZERO
var takeoff_target_pos: = Vector2.ZERO
var takeoff_timer: = 0.0


var currency_label: Label = null
var cargo_label: Label = null
var hint_label: Label = null
var station_node: Node2D = null

func _ready():
    RenderingServer.set_default_clear_color(Color(0.01, 0.01, 0.04))


    camera.zoom = Vector2(1.0, 1.0)
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 8.0


    if not Global.has_spaceship and ship.renderer:
        ship.renderer.queue_free()
        var astro_renderer = Node2D.new()
        astro_renderer.name = "AstroRenderer"
        astro_renderer.set_script(load("res://scripts/astro_renderer.gd"))
        ship.add_child(astro_renderer)
        ship.renderer = astro_renderer
        ship.move_speed = Global.astro_speed
        camera.zoom = Vector2(1.8, 1.8)


    if Global.get_meta("from_mining", false):
        Global.remove_meta("from_mining")
        ship.global_position = FROM_MINING_START
        state = State.FREE
    else:

        ship.global_position = STATION_POS + LAND_POS_OFFSET
        ship.set_physics_process(false)
        state = State.DOCKED
        call_deferred("_on_landed")


    station_node = Node2D.new()
    station_node.set_script(load("res://scripts/base_station_renderer.gd"))
    station_node.position = STATION_POS
    add_child(station_node)


    var bg = Node2D.new()
    bg.set_script(load("res://scripts/space_background.gd"))
    bg.z_index = -10
    add_child(bg)


    _create_ui()


    ScreenFX.fade_in(0.3)
    print("[Base] 기지 씬 시작 (상태: %s)" % State.keys()[state])

func _process(delta):
    if is_transitioning:
        return
    if not ship:
        return

    match state:
        State.FREE:
            _process_free(delta)
        State.LANDING:
            _process_landing(delta)
        State.DOCKED:
            pass
        State.TAKEOFF:
            _process_takeoff(delta)

    _update_ui()


func _process_free(delta):

    var dist = ship.global_position.distance_to(STATION_POS)
    if dist < DOCK_TRIGGER:
        _start_landing()
        return


    if ship.global_position.y < - EXIT_DISTANCE:
        _transition_to_mining()


func _start_landing():
    state = State.LANDING
    land_start_pos = ship.global_position
    land_target_pos = STATION_POS + LAND_POS_OFFSET
    land_timer = 0.0
    land_start_rotation = ship.visual_rotation


    ship.set_physics_process(false)
    ship.velocity = Vector2.ZERO

    print("[Base] 착륙 시퀀스 시작")

func _process_landing(delta):
    land_timer += delta
    var t = clampf(land_timer / LAND_DURATION, 0.0, 1.0)


    var eased = 1.0 - pow(1.0 - t, 3.0)
    ship.global_position = land_start_pos.lerp(land_target_pos, eased)



    var land_end_rotation = land_start_rotation + PI
    ship.visual_rotation = lerp_angle(land_start_rotation, land_end_rotation, eased)

    if ship.has_node("ShipRenderer"):
        ship.get_node("ShipRenderer").queue_redraw()
    elif ship.renderer:
        ship.renderer.queue_redraw()

    if t >= 1.0:
        ship.global_position = land_target_pos
        state = State.DOCKED
        _on_landed()


func _on_landed():
    print("[Base] 착륙 완료!")


    if Global.sortie_resources > 0:
        Global.end_sortie()
        print("[Base] 자원 판매 완료! 화폐: %.0f" % Global.currency)


    _show_upgrade_menu()


var takeoff_start_rotation: = 0.0

func _start_takeoff():
    state = State.TAKEOFF
    takeoff_start_pos = ship.global_position
    takeoff_target_pos = STATION_POS + LAND_POS_OFFSET + Vector2(0, - TAKEOFF_HEIGHT)
    takeoff_timer = 0.0
    takeoff_start_rotation = ship.visual_rotation

    _hide_upgrade_menu()
    print("[Base] 이륙!")

func _process_takeoff(delta):
    takeoff_timer += delta
    var t = clampf(takeoff_timer / TAKEOFF_DURATION, 0.0, 1.0)


    var eased = t * t
    ship.global_position = takeoff_start_pos.lerp(takeoff_target_pos, eased)


    if t >= 1.0:
        ship.global_position = takeoff_target_pos
        state = State.FREE
        ship.set_physics_process(true)
        print("[Base] 이륙 완료! 자유 비행")


var menu_layer: CanvasLayer = null

func _show_upgrade_menu():
    if upgrade_menu != null:
        menu_layer.visible = true
        upgrade_menu.visible = true
        if upgrade_menu.has_method("_center_on_start"):
            upgrade_menu._center_on_start()
        return


    menu_layer = CanvasLayer.new()
    menu_layer.layer = 50
    add_child(menu_layer)

    var menu_scene = load("res://scenes/upgrade_menu.tscn")
    upgrade_menu = menu_scene.instantiate()
    upgrade_menu.is_embedded_in_base = true
    menu_layer.add_child(upgrade_menu)

    await get_tree().process_frame
    if upgrade_menu.has_method("_center_on_start"):
        upgrade_menu._center_on_start()

func _hide_upgrade_menu():
    if menu_layer != null:
        menu_layer.visible = false

func _is_menu_visible() -> bool:
    return upgrade_menu != null and upgrade_menu.visible and menu_layer != null and menu_layer.visible


var _prev_menu_visible: = false
func _check_menu_closed():
    var now_visible = _is_menu_visible()
    if _prev_menu_visible and not now_visible and state == State.DOCKED:

        _start_takeoff()
    _prev_menu_visible = now_visible


func _transition_to_mining():
    is_transitioning = true
    Global.start_sortie()
    Global.set_meta("from_base", true)

    if ship:
        ship.cargo_full_stop = false

    print("[Base] 채굴 씬으로 전환!")
    ScreenFX.transition_to("res://scenes/mining_scene.tscn", 0.3)


func _create_ui():
    var canvas = CanvasLayer.new()
    canvas.layer = 10
    add_child(canvas)

    currency_label = Label.new()
    currency_label.position = Vector2(16, 16)
    currency_label.add_theme_font_size_override("font_size", 18)
    currency_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
    canvas.add_child(currency_label)

    cargo_label = Label.new()
    cargo_label.position = Vector2(16, 44)
    cargo_label.add_theme_font_size_override("font_size", 14)
    cargo_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
    canvas.add_child(cargo_label)

    hint_label = Label.new()
    hint_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    hint_label.offset_top = -40
    hint_label.offset_bottom = -16
    hint_label.offset_left = -200
    hint_label.offset_right = 200
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint_label.add_theme_font_size_override("font_size", 13)
    hint_label.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9, 0.5))
    canvas.add_child(hint_label)

func _update_ui():

    _check_menu_closed()

    if currency_label:
        currency_label.text = "💰 %s" % Global.format_number(Global.currency)
    if cargo_label:
        cargo_label.text = "📦 %s / %s" % [Global.format_number(Global.sortie_resources), Global.format_number(Global.cargo_capacity)]
    if hint_label:
        match state:
            State.DOCKED:
                hint_label.text = ""
            State.LANDING:
                hint_label.text = "착륙 중..."
            State.TAKEOFF:
                hint_label.text = "이륙 중..."
            State.FREE:
                hint_label.text = "↑ 위로 이동하여 행성으로"
