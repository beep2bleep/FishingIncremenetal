extends Node2D





@onready var planet_renderer: Node2D = $PlanetRenderer
@onready var player: CharacterBody2D = $MiningShip
@onready var camera: Camera2D = $MiningShip / Camera2D
@onready var timer_label: Label = $UI / TimerLabel
@onready var resource_label: Label = $UI / ResourceLabel
@onready var core_label: Label = $UI / CoreLabel
@onready var return_btn: Button = $UI / ReturnButton


var mega_gauge_bar: ProgressBar = null
var mega_gauge_label: Label = null


var sortie_gauges: Control = null


var spawn_position: Vector2 = Vector2.ZERO
const RETURN_ZONE_RADIUS: = 150.0
var return_zone_timer: float = 0.0
var RETURN_ZONE_DELAY: float = 3.0
var is_in_return_zone: bool = false
var has_left_spawn: bool = false


var fuel_vignette: CanvasLayer = null


var sortie_time: float = 30.0
var remaining_time: float = 30.0
var is_active: bool = true
var is_paused: bool = false


var defense_block_timer: float = 0.0
var shockwave_timer: float = 0.0
const DEFENSE_BLOCK_INTERVAL: float = 4.0
const SHOCKWAVE_INTERVAL: float = 5.0
const SHOCKWAVE_PUSH_FORCE: float = 600.0


var minimap_ref: Control = null


var zone_threat: ZoneThreatSystem = null
var zone_threat_ui: Control = null
var frost_overlay: CanvasLayer = null
var screen_flash: CanvasLayer = null

func _ready():
    print("=== 채굴 씬 시작 ===")


    RenderingServer.set_default_clear_color(Color(0.02, 0.02, 0.05))


    var planet_data = Global.planet_data
    if planet_data == null:
        push_error("행성 데이터 없음! Global.initialize_planet() 필요")
        return


    Global.start_sortie()


    if Global.return_shortcut_unlocked:
        RETURN_ZONE_DELAY = 1.5


    if not Global.cargo_full.is_connected(_on_cargo_full):
        Global.cargo_full.connect(_on_cargo_full)
    if not Global.fuel_empty.is_connected(_on_fuel_empty):
        Global.fuel_empty.connect(_on_fuel_empty)


    sortie_time = Global.get_effective_sortie_time()
    remaining_time = sortie_time


    planet_renderer.planet_data = planet_data
    player.planet_data = planet_data
    player.planet_renderer = planet_renderer


    planet_data.on_core_destroyed_callback = _on_core_fully_destroyed


    planet_data._final_core_exposed_emitted = false
    planet_data.final_boss_active = false
    planet_data.final_core_phase = 0


    zone_threat = ZoneThreatSystem.new()
    zone_threat.name = "ZoneThreatSystem"
    add_child(zone_threat)
    zone_threat.setup(planet_data, player, planet_renderer)
    planet_renderer.zone_threat = zone_threat
    zone_threat.overheat_changed.connect(_on_overheat_for_ship)


    planet_data.final_core_exposed.connect(_on_final_core_exposed)
    zone_threat.center_boss_started.connect(_on_center_boss_started)
    zone_threat.center_phase_changed.connect(_on_center_phase_changed)
    zone_threat.center_boss_defeated.connect(_on_center_boss_defeated)

    zone_threat.arena_ring_erased.connect( func(_ring_idx, positions):
        planet_renderer.register_arena_ring_flash(positions)
        planet_renderer.mark_dirty()
    )


    zone_threat_ui = Control.new()
    zone_threat_ui.set_script(load("res://scripts/zone_threat_ui.gd"))
    $UI.add_child(zone_threat_ui)
    zone_threat_ui.setup(zone_threat)


    var frost_script = load("res://scripts/frost_overlay.gd")
    print("[MiningScene] frost_overlay 스크립트 로드: %s" % str(frost_script != null))
    frost_overlay = CanvasLayer.new()
    frost_overlay.name = "FrostOverlay"
    frost_overlay.set_script(frost_script)
    add_child(frost_overlay)
    print("[MiningScene] frost_overlay 추가 완료, script=%s" % str(frost_overlay.get_script() != null))
    zone_threat.cold_slow_changed.connect( func(amount): frost_overlay.set_cold_amount(amount))


    screen_flash = CanvasLayer.new()
    screen_flash.name = "ScreenFlash"
    screen_flash.set_script(load("res://scripts/screen_flash.gd"))
    add_child(screen_flash)


    camera.zoom = Vector2(1.0, 1.0)
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 8.0


    return_btn.visible = false



    perf_label = Label.new()
    perf_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    perf_label.offset_left = -200
    perf_label.offset_right = -8
    perf_label.offset_top = 8
    perf_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    perf_label.add_theme_font_size_override("font_size", 11)
    perf_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.6))
    $UI.add_child(perf_label)


    _setup_neon_ui()




    sortie_gauges = Control.new()
    sortie_gauges.set_script(load("res://scripts/sortie_gauges.gd"))
    sortie_gauges.set_anchors_preset(Control.PRESET_FULL_RECT)
    sortie_gauges.mouse_filter = Control.MOUSE_FILTER_IGNORE
    $UI.add_child(sortie_gauges)


    fuel_vignette = CanvasLayer.new()
    fuel_vignette.layer = 90
    var vig_control = Control.new()
    vig_control.set_script(load("res://scripts/fuel_vignette_draw.gd"))
    vig_control.set_anchors_preset(Control.PRESET_FULL_RECT)
    vig_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fuel_vignette.add_child(vig_control)
    add_child(fuel_vignette)


    if Global.minimap_unlocked:
        _create_minimap(planet_data)


    _spawn_player_at_angle( - PI * 0.5)
    var has_resume = Global.resume_pos_unlocked and Global.resume_position_valid
    if Global.spawn_points_available > 1 or has_resume:
        _show_spawn_selector(has_resume)
    else:
        _start_entry_animation()

    update_ui()


    if Global.sortie_count == 1 and not Global.tutorial_shown:
        _start_ingame_tutorial()

    print("행성 블록: %d개, 코어: %d개" % [planet_data.get_total_blocks(), planet_data.get_alive_cores()])


var perf_label: Label = null
var perf_timer: float = 0.0

func _setup_neon_ui():
    var cyan = Color(0.2, 0.85, 1.0)
    var orange = Color(1.0, 0.5, 0.15)
    var red = Color(1.0, 0.2, 0.1)

    timer_label.add_theme_color_override("font_color", cyan)
    resource_label.add_theme_color_override("font_color", orange)
    core_label.add_theme_color_override("font_color", red)


    return_btn.add_theme_color_override("font_color", cyan)

var is_warping_out: bool = false

func _process(delta):

    if is_warping_out:
        camera.offset = Global.get_shake_offset()
        planet_renderer.mark_dirty()
        return

    if not is_active:
        return


    if is_paused:
        planet_renderer.mark_dirty()
        return



    if player:

        if not Global.tutorial_active:
            var exit_dist = (PlanetData.PLANET_RADIUS + 60) * PlanetData.BLOCK_SIZE
            if player.global_position.length() > exit_dist:
                _end_sortie()
                return


            var dist_to_spawn = player.global_position.distance_to(spawn_position)
            if not has_left_spawn and dist_to_spawn > RETURN_ZONE_RADIUS * 2:
                has_left_spawn = true

            if has_left_spawn and dist_to_spawn < RETURN_ZONE_RADIUS:
                if not is_in_return_zone:
                    is_in_return_zone = true
                    return_zone_timer = 0.0
                return_zone_timer += delta
                if return_zone_timer >= RETURN_ZONE_DELAY:
                    print("[🚀] 귀환 존 %.1f초 체류! 귀환" % RETURN_ZONE_DELAY)
                    _end_sortie()
                    return
            else:
                is_in_return_zone = false
                return_zone_timer = 0.0


    _update_core_behaviors(delta)


    if zone_threat:
        zone_threat.update(delta)


    if not is_in_return_zone and not Global.infinite_fuel_unlocked:
        Global.consume_fuel(delta)


    Global.update_combo(delta)


    camera.offset = Global.get_shake_offset()


    update_ui()


    perf_timer += delta
    if perf_timer >= 0.5 and perf_label:
        perf_timer = 0.0
        var fps = Engine.get_frames_per_second()
        var nodes = get_tree().get_node_count()
        var drops = get_tree().get_nodes_in_group("resource_drops").size()
        var particles = get_tree().get_nodes_in_group("mining_particles").size()
        perf_label.text = "FPS:%d  N:%d  D:%d  P:%d" % [fps, nodes, drops, particles]


func add_resources(amount: float, is_core: bool = false):
    Global.gain_mining_resource(amount, is_core)


func record_destroyed(is_core: bool):
    Global.record_block_destroyed(is_core)


func _on_return_pressed():
    if is_active:
        _end_sortie()


func _on_cargo_full():
    if is_active and player:
        print("[📦] 화물칸 FULL! 공격 중지")
        player.cargo_full_stop = true


func _on_fuel_empty():
    if is_active:
        print("[⛽] 연료 고갈! 폭발 후 강제 귀환")
        Global.apply_fuel_penalty()

        if player:
            player.is_dead = true
            player.visible = false
            player.drop_system.spawn_crash_explosion()
        ScreenFX.flash(Color(1.0, 0.2, 0.1), 0.3, 0.5)
        SoundManager.play("barrier_break")
        Global.request_shake(5.0, 0.4)

        await get_tree().create_timer(0.6).timeout
        _end_sortie()


func _on_overheat_for_ship(value: float, max_value: float):
    if player:
        player.overheat_ratio = value / max_value


func on_ship_crashed():
    if not is_active:
        return
    Global.apply_fuel_penalty()
    ScreenFX.flash(Color(1.0, 0.2, 0.1), 0.3, 0.5)
    _end_sortie()


func _on_core_fully_destroyed(core: Dictionary):

    Global.record_core_fully_destroyed()


    SoundManager.play("core_destroy")


    Global.request_shake(6.0, 0.5)
    if screen_flash:
        screen_flash.flash(Color(1.0, 0.9, 0.8), 0.3)


    var center = core.center

    var world_cx = center.x * PlanetData.BLOCK_SIZE + PlanetData.BLOCK_SIZE * 0.5
    var world_cy = center.y * PlanetData.BLOCK_SIZE + PlanetData.BLOCK_SIZE * 0.5
    var world_center = Vector2(world_cx, world_cy)


    var particle = Node2D.new()
    var script = load("res://scripts/mining_particle.gd")
    particle.set_script(script)
    add_child(particle)
    particle.setup(world_center, Color(1.0, 0.3, 0.08), 20)


    _spawn_core_ring_effect(world_center, core.influence_radius * PlanetData.BLOCK_SIZE)

    print("[MiningScene] ★ 코어 #%d 파괴 이펙트! 영향 반경: %d" % [core.id, core.influence_radius])


    var boss_ach = {
        PlanetData.ZONE_BOSS_IDS.get(PlanetData.Zone.SPRING, -1): "ACH_BOSS_SPRING", 
        PlanetData.ZONE_BOSS_IDS.get(PlanetData.Zone.SUMMER, -1): "ACH_BOSS_SUMMER", 
        PlanetData.ZONE_BOSS_IDS.get(PlanetData.Zone.AUTUMN, -1): "ACH_BOSS_AUTUMN", 
        PlanetData.ZONE_BOSS_IDS.get(PlanetData.Zone.WINTER, -1): "ACH_BOSS_WINTER", 
    }
    if boss_ach.has(core.id):
        SteamManager.unlock(boss_ach[core.id])


    if Global.planet_cleared and not Global.ending_shown:
        _trigger_ending()


func _spawn_core_ring_effect(center: Vector2, target_radius: float):
    var ring = Node2D.new()
    ring.set_script(load("res://scripts/core_ring_effect.gd"))
    add_child(ring)
    ring.setup(center, target_radius)





var center_boss_active: bool = false


func _on_final_core_exposed():
    print("[MiningScene] 💀 최종 코어 노출 감지!")

    Global.request_shake(8.0, 1.0)
    if screen_flash:
        screen_flash.flash(Color(1.0, 0.2, 0.1), 0.5)

    var tween = create_tween()
    tween.tween_callback( func():
        if zone_threat:
            zone_threat.start_center_boss()
    ).set_delay(1.0)


func _on_center_boss_started():
    center_boss_active = true
    print("[MiningScene] 💀 CENTER 보스전 시작!")

    Global.request_shake(10.0, 1.5)
    if screen_flash:
        screen_flash.flash(Color(1.0, 0.5, 0.1), 0.8)
    planet_renderer.mark_dirty()


func _on_center_phase_changed(phase: int, phase_name: String):
    print("[MiningScene] 💀 페이즈 전환: %d - %s" % [phase, phase_name])

    Global.request_shake(6.0, 0.8)
    if screen_flash:

        var flash_colors = {
            1: Color(0.5, 1.0, 0.5), 
            2: Color(1.0, 0.8, 0.2), 
            3: Color(1.0, 0.5, 0.1), 
            4: Color(0.3, 0.6, 1.0), 
        }
        var color = flash_colors.get(phase, Color.WHITE)
        screen_flash.flash(color, 0.6)
    planet_renderer.mark_dirty()


func _on_center_boss_defeated():
    center_boss_active = false
    print("[MiningScene] 💀 CENTER 보스 처치! 엔딩 준비")






func _trigger_ending():
    is_active = false
    print("[MiningScene] 🏆 엔딩 트리거! 자원 저장 후 엔딩 씬으로 전환")


    Global.end_sortie()


    await get_tree().create_timer(2.0).timeout


    ScreenFX.transition_to("res://scenes/game_ending.tscn")





func _update_core_behaviors(delta: float):
    var planet_data = Global.planet_data
    if not planet_data:
        return

    var behaviors = planet_data.get_active_core_behaviors()


    if behaviors.defense_blocks or behaviors.final_rage:
        defense_block_timer -= delta
        if defense_block_timer <= 0:
            defense_block_timer = DEFENSE_BLOCK_INTERVAL
            if behaviors.final_rage:
                defense_block_timer *= 0.6
            var spawned = planet_data.spawn_defense_blocks()
            if spawned > 0:
                print("[Core Defense] 방어 블록 %d개 생성" % spawned)


    if behaviors.shockwave or behaviors.final_rage:
        shockwave_timer -= delta
        if shockwave_timer <= 0:
            shockwave_timer = SHOCKWAVE_INTERVAL
            if behaviors.final_rage:
                shockwave_timer *= 0.5
            _fire_core_shockwaves(planet_data)

func _fire_core_shockwaves(planet_data: PlanetData):
    var sw_cores = planet_data.get_shockwave_cores()
    var bs = PlanetData.BLOCK_SIZE

    for core in sw_cores:
        var center = core.center
        var world_cx = center.x * bs + bs * 0.5
        var world_cy = center.y * bs + bs * 0.5
        var world_center = Vector2(world_cx, world_cy)
        var push_radius = core.influence_radius * bs * 1.5


        planet_renderer.register_shockwave(world_center, push_radius)


        var dist = player.global_position.distance_to(world_center)
        if dist < push_radius and dist > 0:
            var push_dir = (player.global_position - world_center).normalized()
            var strength = (1.0 - dist / push_radius)
            player.apply_knockback(push_dir * SHOCKWAVE_PUSH_FORCE * strength)
            Global.request_shake(3.0 * strength, 0.2)
            print("[Core Defense] 충격파 히트! 강도: %.1f" % strength)


func _end_sortie():
    is_active = false
    _try_save_resume_position()

    if player and player.sortie_stats:
        player.sortie_stats.combo_max = Global.combo_max_reached
        player.sortie_stats.kills_total = Global.sortie_blocks_destroyed
        Global.sortie_combat_stats = player.sortie_stats.duplicate()

    is_warping_out = true
    if not player.is_dead:
        SoundManager.play("warp")
        var cam_global = camera.global_position
        camera.top_level = true
        camera.global_position = cam_global
        camera.position_smoothing_enabled = false
        player.start_warp()
        await Global.end_sortie_async(get_tree())
        await get_tree().create_timer(player.WARP_DURATION + 0.2).timeout
    else:
        await Global.end_sortie_async(get_tree())
        await get_tree().create_timer(0.5).timeout

    ScreenFX.transition_to("res://scenes/sortie_result.tscn")


func _create_mega_gauge_ui():
    var container = VBoxContainer.new()
    container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    container.offset_left = 16
    container.offset_bottom = -16
    container.offset_top = -60
    container.offset_right = 200
    container.add_theme_constant_override("separation", 2)
    $UI.add_child(container)

    mega_gauge_label = Label.new()
    mega_gauge_label.text = tr("MEGA_LASER_LABEL")
    mega_gauge_label.add_theme_font_size_override("font_size", 13)
    mega_gauge_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.15))
    container.add_child(mega_gauge_label)

    mega_gauge_bar = ProgressBar.new()
    mega_gauge_bar.custom_minimum_size = Vector2(180, 14)
    mega_gauge_bar.max_value = Global.mega_laser_gauge_need
    mega_gauge_bar.value = 0
    mega_gauge_bar.show_percentage = false


    var bg_style = StyleBoxFlat.new()
    bg_style.bg_color = Color(0.08, 0.06, 0.02, 0.8)
    bg_style.set_corner_radius_all(3)
    bg_style.border_color = Color(1.0, 0.5, 0.1, 0.4)
    bg_style.set_border_width_all(1)
    mega_gauge_bar.add_theme_stylebox_override("background", bg_style)

    var fill_style = StyleBoxFlat.new()
    fill_style.bg_color = Color(1.0, 0.5, 0.1, 0.9)
    fill_style.set_corner_radius_all(3)
    mega_gauge_bar.add_theme_stylebox_override("fill", fill_style)

    container.add_child(mega_gauge_bar)


func _create_minimap(pd: PlanetData):
    var mm = Control.new()
    mm.set_script(load("res://scripts/mining_minimap.gd"))
    $UI.add_child(mm)
    mm.setup(pd, player)
    minimap_ref = mm


func _show_spawn_selector(has_resume: bool = false):

    player.set_physics_process(false)
    player.visible = false
    is_paused = true

    var selector = Control.new()
    selector.set_script(load("res://scripts/spawn_selector.gd"))

    var custom = [ - PI * 0.5, 0.0] if Global.spawn_direction_unlocked else []
    selector.setup(Global.spawn_points_available, has_resume, custom)
    selector.spawn_selected.connect(_on_spawn_selected)
    selector.resume_selected.connect(_on_resume_selected)
    $UI.add_child(selector)

func _on_spawn_selected(angle: float):
    _spawn_player_at_angle(angle)
    player.visible = true
    _start_entry_animation()

func _on_resume_selected():

    player.global_position = Global.resume_position
    player.spawn_protection_timer = 1.5
    player.visible = true
    _start_entry_animation()
    print("[📌] 전 지점에서 출항! (%.0f, %.0f)" % [player.global_position.x, player.global_position.y])


func _start_entry_animation():
    SoundManager.play("warp")
    is_paused = true

    var target_pos = player.global_position
    camera.top_level = true
    camera.global_position = target_pos
    camera.position_smoothing_enabled = false
    player.set_physics_process(true)
    player.start_entry()
    player.entry_finished.connect(_on_entry_finished, CONNECT_ONE_SHOT)

func _on_entry_finished():

    camera.top_level = false
    camera.position = Vector2.ZERO
    camera.position_smoothing_enabled = true
    is_paused = false


func _spawn_player_at_angle(angle: float):
    var spawn_dist = (PlanetData.PLANET_RADIUS + 8) * PlanetData.BLOCK_SIZE
    player.global_position = Vector2(
        cos(angle) * spawn_dist, 
        sin(angle) * spawn_dist
    )

    spawn_position = player.global_position
    if minimap_ref:
        minimap_ref.spawn_world_pos = spawn_position
    has_left_spawn = false
    var rz = Node2D.new()
    rz.set_script(load("res://scripts/return_zone.gd"))
    add_child(rz)
    rz.setup(spawn_position, RETURN_ZONE_RADIUS)





func _try_save_resume_position():
    if not Global.resume_pos_unlocked:
        return

    var pd = Global.planet_data
    if not pd:
        return


    var player_grid = pd.world_to_grid(player.global_position)


    for core in pd.cores:
        if not core.alive:
            continue
        var effective_r = pd.get_effective_influence_radius(core)
        var dx = abs(player_grid.x - core.center.x)
        var dy = abs(player_grid.y - core.center.y)
        if dx <= effective_r and dy <= effective_r:

            Global.resume_position_valid = false
            print("[📌] 코어 영향권 내 종료 → 위치 저장 안 함")
            return


    Global.resume_position = player.global_position
    Global.resume_position_valid = true
    print("[📌] 전 지점 저장! (%.0f, %.0f)" % [player.global_position.x, player.global_position.y])


func update_ui():

    if Global.sortie_ore_count >= Global.cargo_capacity:
        timer_label.text = tr("CARGO_FULL")
        timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
    else:
        timer_label.text = tr("CARGO_FMT") % [Global.sortie_ore_count, int(Global.cargo_capacity)]
        timer_label.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0))
    var sell_preview = Global.sortie_resources * Global.ore_sell_rate
    resource_label.text = "💰 %s" % Global.format_number(sell_preview)

    var pd = Global.planet_data
    if pd:
        core_label.text = tr("CORE_FMT") % [pd.get_alive_cores(), pd.cores.size()]


    if mega_gauge_bar != null and player != null:
        if player.mega_system and player.mega_system.active:

            mega_gauge_bar.max_value = Global.mega_laser_duration
            mega_gauge_bar.value = player.mega_system.timer
            mega_gauge_label.text = tr("MEGA_ACTIVE_FMT") % player.mega_system.timer
            mega_gauge_label.add_theme_color_override("font_color", Color(2.0, 1.0, 0.3))

            var fill = mega_gauge_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
            fill.bg_color = Color(2.0, 0.8, 0.2, 0.95)
            mega_gauge_bar.add_theme_stylebox_override("fill", fill)
        else:

            mega_gauge_bar.max_value = Global.mega_laser_gauge_need
            mega_gauge_bar.value = player.mega_system.gauge if player.mega_system else 0
            mega_gauge_label.text = tr("MEGA_GAUGE_FMT") % [player.mega_system.gauge if player.mega_system else 0, Global.mega_laser_gauge_need]
            mega_gauge_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.15))
            var fill = mega_gauge_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
            fill.bg_color = Color(1.0, 0.5, 0.1, 0.9)
            mega_gauge_bar.add_theme_stylebox_override("fill", fill)







func _start_ingame_tutorial():
    Global.tutorial_shown = true
    var tut = CanvasLayer.new()
    tut.set_script(load("res://scripts/tutorial_overlay.gd"))
    tut.setup(self)
    add_child(tut)
