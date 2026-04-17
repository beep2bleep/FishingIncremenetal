extends Node2D








var planet_data: PlanetData = null
var planet_renderer: Node2D = null
var player: CharacterBody2D = null
var camera: Camera2D = null
var zone_threat: ZoneThreatSystem = null
var debug_panel: PanelContainer = null
var ui_layer: CanvasLayer = null
var screen_flash: CanvasLayer = null


var core_labels: Dictionary = {}





const TEST_CORES = [

    {"id": 1, "center": Vector2i(0, -240), "size": 3, "influence": 16, 
     "hp_mult": 1.5, "total_hp": 120, "res_mult": 1.2, "zone": PlanetData.Zone.SPRING, "role": "outer"}, 
    {"id": 12, "center": Vector2i(0, -180), "size": 5, "influence": 22, 
     "hp_mult": 3.0, "total_hp": 500, "res_mult": 2.0, "zone": PlanetData.Zone.SPRING, "role": "boss"}, 

    {"id": 4, "center": Vector2i(220, 0), "size": 3, "influence": 16, 
     "hp_mult": 3.0, "total_hp": 8000, "res_mult": 2.0, "zone": PlanetData.Zone.SUMMER, "role": "outer"}, 
    {"id": 13, "center": Vector2i(150, 0), "size": 5, "influence": 22, 
     "hp_mult": 5.0, "total_hp": 20000, "res_mult": 3.0, "zone": PlanetData.Zone.SUMMER, "role": "boss"}, 

    {"id": 7, "center": Vector2i(0, 200), "size": 3, "influence": 16, 
     "hp_mult": 5.0, "total_hp": 150000, "res_mult": 3.0, "zone": PlanetData.Zone.AUTUMN, "role": "outer"}, 
    {"id": 14, "center": Vector2i(0, 120), "size": 5, "influence": 22, 
     "hp_mult": 8.0, "total_hp": 350000, "res_mult": 4.0, "zone": PlanetData.Zone.AUTUMN, "role": "boss"}, 

    {"id": 10, "center": Vector2i(-180, 0), "size": 3, "influence": 16, 
     "hp_mult": 250.0, "total_hp": 3000000, "res_mult": 4.0, "zone": PlanetData.Zone.WINTER, "role": "outer"}, 
    {"id": 15, "center": Vector2i(-90, 0), "size": 5, "influence": 22, 
     "hp_mult": 600.0, "total_hp": 20000000, "res_mult": 6.0, "zone": PlanetData.Zone.WINTER, "role": "boss"}, 

    {"id": PlanetData.FINAL_CORE_ID, "center": Vector2i(0, 0), "size": 7, "influence": 35, 
     "hp_mult": 500.0, "total_hp": 80000000, "res_mult": 8.0, "zone": PlanetData.Zone.CENTER, "role": "final"}, 
]

var _prev_free_planet_mode: bool = false

func _ready():
    print("=== 🔬 코어 테스트 씬 시작 ===")
    RenderingServer.set_default_clear_color(Color(0.02, 0.02, 0.05))


    _prev_free_planet_mode = Global.free_planet_mode
    Global.free_planet_mode = true


    planet_data = _generate_test_planet()


    planet_renderer = $PlanetRenderer
    planet_renderer.planet_data = planet_data


    player = $MiningShip
    player.planet_data = planet_data
    player.planet_renderer = planet_renderer
    player._apply_global_stats()

    player.global_position = Vector2.ZERO
    player.spawn_protection_timer = 2.0


    camera = $MiningShip / Camera2D
    camera.zoom = Vector2(0.6, 0.6)
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 8.0


    planet_data.on_core_destroyed_callback = _on_core_destroyed_test


    zone_threat = ZoneThreatSystem.new()
    zone_threat.name = "ZoneThreatSystem"
    add_child(zone_threat)
    zone_threat.setup(planet_data, player, planet_renderer)
    planet_renderer.zone_threat = zone_threat
    zone_threat.overheat_changed.connect( func(v, m): player.overheat_ratio = v / m)


    planet_data.final_core_exposed.connect(_on_final_core_exposed)
    zone_threat.center_boss_started.connect(_on_center_boss_started)
    zone_threat.center_phase_changed.connect(_on_center_phase_changed)
    zone_threat.center_boss_defeated.connect(_on_center_boss_defeated)

    zone_threat.arena_ring_erased.connect( func(_ring_idx, positions):
        planet_renderer.register_arena_ring_flash(positions)
        planet_renderer.mark_dirty()
    )


    var zone_threat_ui = Control.new()
    zone_threat_ui.set_script(load("res://scripts/zone_threat_ui.gd"))
    $UI.add_child(zone_threat_ui)
    zone_threat_ui.setup(zone_threat)


    var frost_overlay = CanvasLayer.new()
    frost_overlay.name = "FrostOverlay"
    frost_overlay.set_script(load("res://scripts/frost_overlay.gd"))
    add_child(frost_overlay)
    zone_threat.cold_slow_changed.connect( func(amount): frost_overlay.set_cold_amount(amount))


    screen_flash = CanvasLayer.new()
    screen_flash.name = "ScreenFlash"
    screen_flash.set_script(load("res://scripts/screen_flash.gd"))
    add_child(screen_flash)


    _build_debug_ui()

    print("[CoreTest] 블록: %d개, 코어: %d개" % [planet_data.get_total_blocks(), planet_data.cores.size()])





func _generate_test_planet() -> PlanetData:
    var pd = PlanetData.new()


    for config in TEST_CORES:
        var center: Vector2i = config.center
        var core_size: int = config.size
        var dist = sqrt(float(center.x * center.x + center.y * center.y))
        var block_count = core_size * core_size


        var core_hp = float(config.total_hp)
        var base_res = pd._calc_block_resource(center)
        var core_res = base_res * config.res_mult * block_count


        pd.cores.append({
            "id": config.id, 
            "center": center, 
            "size": core_size, 
            "influence_radius": config.influence, 
            "alive": true, 
            "depth": 1.0 - (dist / PlanetData.PLANET_RADIUS) if dist > 0 else 1.0, 
            "zone": config.zone, 
            "role": config.role, 
        })


        var half = core_size / 2
        for dx in range( - half, half + core_size % 2):
            for dy in range( - half, half + core_size % 2):
                var pos = Vector2i(center.x + dx, center.y + dy)

                pd.blocks[pos] = {
                    "type": PlanetData.BlockType.CORE, 
                    "hp": core_hp, 
                    "max_hp": core_hp, 
                    "resource": core_res / float(block_count), 
                    "core_id": config.id, 
                    "zone": config.zone, 
                }



    return pd





func _build_debug_ui():
    debug_panel = PanelContainer.new()
    $UI.add_child(debug_panel)

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.03, 0.03, 0.08, 0.92)
    style.border_color = Color(0.4, 0.8, 1.0, 0.6)
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.set_content_margin_all(10)
    debug_panel.add_theme_stylebox_override("panel", style)

    debug_panel.anchor_left = 0.0
    debug_panel.anchor_right = 0.0
    debug_panel.anchor_top = 0.0
    debug_panel.anchor_bottom = 0.0
    debug_panel.offset_left = 8
    debug_panel.offset_top = 8
    debug_panel.offset_right = 310

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 3)
    debug_panel.add_child(vbox)


    var title = Label.new()
    title.text = "🔬 코어 테스트 씬"
    title.add_theme_font_size_override("font_size", 16)
    title.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
    vbox.add_child(title)

    vbox.add_child(HSeparator.new())


    var zones = [
        {"zone": PlanetData.Zone.SPRING, "name": "🌸 봄", "outer": 1, "boss": 12}, 
        {"zone": PlanetData.Zone.SUMMER, "name": "☀️ 여름", "outer": 4, "boss": 13}, 
        {"zone": PlanetData.Zone.AUTUMN, "name": "🍂 가을", "outer": 7, "boss": 14}, 
        {"zone": PlanetData.Zone.WINTER, "name": "❄️ 겨울", "outer": 10, "boss": 15}, 
    ]

    for z in zones:
        _add_zone_section(vbox, z.name, z.outer, z.boss, z.zone)
        vbox.add_child(HSeparator.new())


    _add_center_boss_section(vbox)
    vbox.add_child(HSeparator.new())


    _add_section_label(vbox, "🔧 전체")
    _add_btn(vbox, "전체 코어 부활", _on_revive_all)
    _add_btn(vbox, "전체 폭발 리셋", _on_reset_all_bursts)
    _add_btn(vbox, "원점 이동", _on_teleport_origin)

    vbox.add_child(HSeparator.new())
    _add_btn(vbox, "← 돌아가기", _on_back)

func _add_zone_section(parent: VBoxContainer, zone_name: String, outer_id: int, boss_id: int, zone: int):
    _add_section_label(parent, zone_name)
    _add_core_row(parent, "외곽#%d" % outer_id, outer_id, false)
    _add_core_row(parent, "보스#%d" % boss_id, boss_id, true)

func _add_core_row(parent: VBoxContainer, label_text: String, core_id: int, is_boss: bool):
    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 4)
    parent.add_child(hbox)


    var lbl = Label.new()
    lbl.custom_minimum_size.x = 90
    lbl.add_theme_font_size_override("font_size", 11)
    lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
    hbox.add_child(lbl)
    core_labels[core_id] = lbl


    _add_small_btn(hbox, "50%", func(): _set_core_hp_ratio(core_id, 0.5))

    _add_small_btn(hbox, "10%", func(): _set_core_hp_ratio(core_id, 0.1))

    _add_small_btn(hbox, "부활", func(): _revive_core(core_id))

    _add_small_btn(hbox, "이동", func(): _teleport_to_core(core_id))

    _add_small_btn(hbox, "리셋", func(): _reset_core(core_id))

    if is_boss:
        _add_small_btn(hbox, "폭발↩", func(): _reset_burst(core_id))

func _add_section_label(parent: VBoxContainer, text: String):
    var label = Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.4))
    parent.add_child(label)

func _add_btn(parent: VBoxContainer, text: String, callback: Callable):
    var btn = Button.new()
    btn.text = text
    btn.add_theme_font_size_override("font_size", 11)
    var s = StyleBoxFlat.new()
    s.bg_color = Color(0.1, 0.1, 0.2)
    s.border_color = Color(0.3, 0.3, 0.5)
    s.set_border_width_all(1)
    s.set_corner_radius_all(3)
    s.set_content_margin_all(3)
    btn.add_theme_stylebox_override("normal", s)
    var h = s.duplicate()
    h.bg_color = Color(0.2, 0.2, 0.35)
    h.border_color = Color(0.5, 0.5, 0.9)
    btn.add_theme_stylebox_override("hover", h)
    btn.pressed.connect(callback)
    parent.add_child(btn)

func _add_small_btn(parent: HBoxContainer, text: String, callback: Callable):
    var btn = Button.new()
    btn.text = text
    btn.add_theme_font_size_override("font_size", 10)
    btn.custom_minimum_size = Vector2(36, 0)
    var s = StyleBoxFlat.new()
    s.bg_color = Color(0.12, 0.12, 0.22)
    s.border_color = Color(0.3, 0.3, 0.5)
    s.set_border_width_all(1)
    s.set_corner_radius_all(2)
    s.set_content_margin_all(2)
    btn.add_theme_stylebox_override("normal", s)
    var h = s.duplicate()
    h.bg_color = Color(0.22, 0.22, 0.38)
    h.border_color = Color(0.5, 0.5, 0.9)
    btn.add_theme_stylebox_override("hover", h)
    btn.pressed.connect(callback)
    parent.add_child(btn)





func _process(delta):

    if zone_threat:
        zone_threat.update(delta)


    Global.update_combo(delta)


    if camera:
        camera.offset = Global.get_shake_offset()


    if planet_renderer:
        planet_renderer.queue_redraw()


    _update_core_labels()


    if camera:
        if Input.is_action_just_pressed("ui_page_up"):
            camera.zoom *= 1.2
        if Input.is_action_just_pressed("ui_page_down"):
            camera.zoom /= 1.2

func _unhandled_input(event):

    if event is InputEventMouseButton:
        var mb = event as InputEventMouseButton
        if mb.pressed:
            if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
                camera.zoom = camera.zoom.clampf(0.2, 3.0)
                camera.zoom *= 1.1
            elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                camera.zoom = camera.zoom.clampf(0.2, 3.0)
                camera.zoom /= 1.1

func _update_core_labels():
    for core in planet_data.cores:
        var lbl = core_labels.get(core.id)
        if lbl == null:
            continue
        var role_str = "외" if core.role == "outer" else ("최" if core.role == "final" else "보")
        if core.alive:
            var hp_ratio = _get_core_hp_ratio(core)
            var hp_pct = int(hp_ratio * 100)
            lbl.text = "%s#%d %d%%" % [role_str, core.id, hp_pct]

            if hp_ratio > 0.5:
                lbl.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
            elif hp_ratio > 0.2:
                lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
            else:
                lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
        else:
            lbl.text = "%s#%d 💀" % [role_str, core.id]
            lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))


    if center_phase_label and zone_threat:
        if zone_threat.center_boss_active:
            var phase = zone_threat.center_phase
            var names = ZoneThreatSystem.CENTER_PHASE_NAMES
            var pname = names[phase] if phase < names.size() else "???"
            var transition_str = " [전환중]" if zone_threat.center_transitioning else ""
            center_phase_label.text = "페이즈: %d/4 %s%s" % [phase, pname, transition_str]

            var phase_colors = {
                1: Color(0.5, 1.0, 0.5), 
                2: Color(1.0, 0.8, 0.2), 
                3: Color(1.0, 0.5, 0.1), 
                4: Color(0.3, 0.6, 1.0), 
            }
            center_phase_label.add_theme_color_override("font_color", phase_colors.get(phase, Color(1.0, 0.6, 0.2)))
        else:
            center_phase_label.text = "페이즈: 대기"
            center_phase_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))






func _get_core_hp_ratio(core: Dictionary) -> float:
    var total_hp: = 0.0
    var total_max: = 0.0
    var half: int = core.size / 2
    for dx in range( - half, half + core.size % 2):
        for dy in range( - half, half + core.size % 2):
            var pos = Vector2i(core.center.x + dx, core.center.y + dy)
            var block = planet_data.blocks.get(pos)
            if block and block.core_id == core.id:
                total_hp += block.hp
                total_max += block.max_hp
    if total_max <= 0:
        return 0.0
    return clampf(total_hp / total_max, 0.0, 1.0)


func _set_core_hp_ratio(core_id: int, ratio: float):
    var core = planet_data._get_core_by_id(core_id)
    if core == null:
        print("[CoreTest] 코어 #%d 없음" % core_id)
        return
    if not core.alive:
        print("[CoreTest] 코어 #%d 이미 파괴됨 — 먼저 부활 필요" % core_id)
        return

    var half: int = core.size / 2
    for dx in range( - half, half + core.size % 2):
        for dy in range( - half, half + core.size % 2):
            var pos = Vector2i(core.center.x + dx, core.center.y + dy)
            var block = planet_data.blocks.get(pos)
            if block and block.core_id == core_id:
                block.hp = block.max_hp * ratio
    print("[CoreTest] 코어 #%d HP → %d%%" % [core_id, int(ratio * 100)])


func _revive_core(core_id: int):
    var core = planet_data._get_core_by_id(core_id)
    if core == null:
        return


    if core.alive:
        _set_core_hp_ratio(core_id, 1.0)
        print("[CoreTest] 코어 #%d 이미 생존 → HP 풀 리셋" % core_id)
        return


    core.alive = true


    var config = _get_test_config(core_id)
    if config == null:
        return
    var center = core.center
    var core_size = core.size
    var half = core_size / 2
    var block_count = core_size * core_size
    var dist = sqrt(float(center.x * center.x + center.y * center.y))
    var base_hp = planet_data._calc_block_hp(dist)
    var core_hp = base_hp * config.hp_mult * block_count
    var base_res = planet_data._calc_block_resource(dist)
    var core_res = base_res * config.res_mult * block_count

    for dx in range( - half, half + core_size % 2):
        for dy in range( - half, half + core_size % 2):
            var pos = Vector2i(center.x + dx, center.y + dy)
            planet_data.blocks[pos] = {
                "type": PlanetData.BlockType.CORE, 
                "hp": core_hp / float(block_count), 
                "max_hp": core_hp / float(block_count), 
                "resource": core_res / float(block_count), 
                "core_id": core_id, 
                "zone": config.zone, 
            }


    print("[CoreTest] ✨ 코어 #%d 부활!" % core_id)


func _regen_influence_blocks(core: Dictionary, config: Dictionary):
    var center = core.center
    var influence = core.influence_radius
    var influence_sq = influence * influence
    var planet_r_sq = PlanetData.PLANET_RADIUS * PlanetData.PLANET_RADIUS

    for x in range(center.x - influence, center.x + influence + 1):
        for y in range(center.y - influence, center.y + influence + 1):
            var pos = Vector2i(x, y)
            if planet_data.blocks.has(pos):
                continue
            var dx_i = x - center.x
            var dy_i = y - center.y
            if dx_i * dx_i + dy_i * dy_i > influence_sq:
                continue
            if pos.x * pos.x + pos.y * pos.y > planet_r_sq:
                continue

            var block_dist = sqrt(float(pos.x * pos.x + pos.y * pos.y))
            var hp = planet_data._calc_block_hp(block_dist)
            var res = planet_data._calc_block_resource(block_dist)

            var proximity = 1.0 - (sqrt(float(dx_i * dx_i + dy_i * dy_i)) / float(influence))
            var hp_mult_bonus = maxf(0.0, config.hp_mult * config.hp_mult - 1.0)
            if hp_mult_bonus > 0:
                hp *= (1.0 + hp_mult_bonus * proximity)

            planet_data.blocks[pos] = {
                "type": PlanetData.BlockType.NORMAL, 
                "hp": hp, 
                "max_hp": hp, 
                "resource": res, 
                "core_id": -1, 
                "zone": config.zone, 
            }


func _reset_core(core_id: int):
    var core = planet_data._get_core_by_id(core_id)
    if core == null:
        return


    var center = core.center
    var radius = core.influence_radius
    var radius_sq = radius * radius
    var removed: = 0
    for x in range(center.x - radius, center.x + radius + 1):
        for y in range(center.y - radius, center.y + radius + 1):
            var pos = Vector2i(x, y)
            var dx = x - center.x
            var dy = y - center.y
            if dx * dx + dy * dy > radius_sq:
                continue
            if not planet_data.blocks.has(pos):
                continue
            if planet_data.blocks[pos].core_id == core_id:
                continue
            planet_data.blocks.erase(pos)
            removed += 1


    _revive_core(core_id)


    _reset_burst(core_id)

    print("[CoreTest] 🔄 코어 #%d 리셋! (블록 %d개 제거)" % [core_id, removed])


func _reset_burst(core_id: int):
    if zone_threat:
        zone_threat.spring_boss_burst_done.erase(core_id)

        zone_threat.thorn_wave_active.erase(core_id)
    print("[CoreTest] 코어 #%d 폭발 리셋 완료" % core_id)


func _teleport_to_core(core_id: int):
    var core = planet_data._get_core_by_id(core_id)
    if core == null:
        return

    var center_world = planet_data.grid_to_world(core.center)
    var outward = center_world.normalized()
    if outward.length() < 0.1:
        outward = Vector2(0, -1)
    var spawn_pos = center_world + outward * (core.influence_radius * PlanetData.BLOCK_SIZE * 0.8)
    player.global_position = spawn_pos
    player.velocity = Vector2.ZERO
    player.knockback_velocity = Vector2.ZERO
    player.collision_invincible_timer = 1.0
    print("[CoreTest] 코어 #%d 근처로 이동!" % core_id)


func _get_test_config(core_id: int) -> Variant:
    for c in TEST_CORES:
        if c.id == core_id:
            return c
    return null





func _on_revive_all():
    for core in planet_data.cores:
        _revive_core(core.id)
    print("[CoreTest] ✨ 전체 코어 부활!")

func _on_reset_all_bursts():
    if zone_threat:
        zone_threat.spring_boss_burst_done.clear()
        zone_threat.thorn_wave_active.clear()
    print("[CoreTest] 전체 폭발 리셋!")

func _on_teleport_origin():
    player.global_position = Vector2.ZERO
    player.velocity = Vector2.ZERO
    player.knockback_velocity = Vector2.ZERO
    player.collision_invincible_timer = 1.0
    print("[CoreTest] 원점 이동!")





var center_phase_label: Label = null


func _add_center_boss_section(parent: VBoxContainer):
    _add_section_label(parent, "💀 CENTER 최종 보스")


    var cid = PlanetData.FINAL_CORE_ID
    _add_core_row(parent, "최종#%d" % cid, cid, false)


    center_phase_label = Label.new()
    center_phase_label.text = "페이즈: 대기"
    center_phase_label.add_theme_font_size_override("font_size", 11)
    center_phase_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
    parent.add_child(center_phase_label)


    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 4)
    parent.add_child(hbox)
    _add_small_btn(hbox, "보스시작", _on_boss_start)
    _add_small_btn(hbox, "다음페이즈", _on_boss_next_phase)
    _add_small_btn(hbox, "보스중지", _on_boss_stop)
    _add_small_btn(hbox, "전체리셋", _on_boss_full_reset)


    var hbox2 = HBoxContainer.new()
    hbox2.add_theme_constant_override("separation", 4)
    parent.add_child(hbox2)
    _add_small_btn(hbox2, "💠웨이브테스트", _on_arena_wave_test)


func _on_boss_start():
    if zone_threat == null:
        return
    if zone_threat.center_boss_active:
        print("[CoreTest] 보스전 이미 진행 중!")
        return

    var fc = planet_data.get_final_core()
    if fc == null or not fc.alive:
        _revive_core(PlanetData.FINAL_CORE_ID)
    zone_threat.start_center_boss()
    print("[CoreTest] 💀 보스전 강제 시작!")


func _on_boss_next_phase():
    if zone_threat == null or not zone_threat.center_boss_active:
        print("[CoreTest] 보스전 미시작")
        return
    var cid = PlanetData.FINAL_CORE_ID

    _set_core_hp_ratio(cid, 0.01)
    print("[CoreTest] 💀 코어 HP → 1%% (다음 피격으로 페이즈 전환)")


func _on_boss_stop():
    if zone_threat == null:
        return
    zone_threat.center_boss_active = false
    zone_threat.center_phase = 0
    zone_threat.center_transitioning = false
    planet_data.final_boss_active = false
    planet_data.final_core_phase = 0
    print("[CoreTest] 💀 보스전 강제 중지")


func _on_boss_full_reset():
    _on_boss_stop()
    _revive_core(PlanetData.FINAL_CORE_ID)

    if zone_threat:
        zone_threat.laser_states.erase(PlanetData.FINAL_CORE_ID)
        zone_threat.debris_timers.erase(PlanetData.FINAL_CORE_ID)
        zone_threat.cross_laser_states.erase(PlanetData.FINAL_CORE_ID)
        zone_threat.spring_regen_timers.erase(PlanetData.FINAL_CORE_ID)
    print("[CoreTest] 💀 보스 전체 리셋 완료")


func _on_arena_wave_test():
    if zone_threat == null:
        return

    if zone_threat.arena_wave_active:
        print("[CoreTest] 웨이브 진행 중!")
        return

    if zone_threat.center_boss_active:
        _on_boss_stop()


    _revive_core(PlanetData.FINAL_CORE_ID)
    var fc = planet_data.get_final_core()
    if fc == null:
        return
    var config = _get_test_config(PlanetData.FINAL_CORE_ID)
    if config:
        _regen_influence_blocks(fc, config)
        print("[CoreTest] 💠 아레나 블록 복원 완료")
    planet_renderer.mark_dirty()


    var tween = create_tween()
    tween.tween_callback( func():
        if zone_threat:
            zone_threat.start_arena_wave_only()
    ).set_delay(0.3)





func _on_final_core_exposed():
    print("[CoreTest] 💀 최종 코어 노출 감지!")
    Global.request_shake(8.0, 1.0)
    if screen_flash:
        screen_flash.flash(Color(1.0, 0.2, 0.1), 0.5)

    var tween = create_tween()
    tween.tween_callback( func():
        if zone_threat and not zone_threat.center_boss_active:
            zone_threat.start_center_boss()
    ).set_delay(1.0)

func _on_center_boss_started():
    print("[CoreTest] 💀 CENTER 보스전 시작!")
    Global.request_shake(10.0, 1.5)
    if screen_flash:
        screen_flash.flash(Color(1.0, 0.5, 0.1), 0.8)
    planet_renderer.mark_dirty()

func _on_center_phase_changed(phase: int, phase_name: String):
    print("[CoreTest] 💀 페이즈 전환: %d - %s" % [phase, phase_name])
    Global.request_shake(6.0, 0.8)
    if screen_flash:
        var flash_colors = {
            1: Color(0.5, 1.0, 0.5), 
            2: Color(1.0, 0.8, 0.2), 
            3: Color(1.0, 0.5, 0.1), 
            4: Color(0.3, 0.6, 1.0), 
        }
        screen_flash.flash(flash_colors.get(phase, Color.WHITE), 0.6)
    planet_renderer.mark_dirty()

func _on_center_boss_defeated():
    print("[CoreTest] 💀 CENTER 보스 처치! 테스트 완료")
    Global.request_shake(12.0, 2.0)
    if screen_flash:
        screen_flash.flash(Color(1.0, 1.0, 1.0), 1.0)

func _on_back():
    ScreenFX.transition_to("res://scenes/main_menu.tscn")

func _exit_tree():

    Global.free_planet_mode = _prev_free_planet_mode





func add_resources(_amount: float, _is_core: bool = false):
    pass

func record_destroyed(_is_core: bool):
    pass

func on_ship_crashed():

    print("[CoreTest] 플레이어 사망 → 1초 후 부활")
    await get_tree().create_timer(1.0).timeout
    if player:
        player.is_dead = false
        player.visible = true
        player.global_position = Vector2.ZERO
        player.velocity = Vector2.ZERO
        player.knockback_velocity = Vector2.ZERO
        player.spawn_protection_timer = 2.0
        player.barrier_count = Global.mining_barrier_count
        print("[CoreTest] ✨ 플레이어 부활!")

func _on_core_destroyed_test(core: Dictionary):

    SoundManager.play("core_destroy")
    Global.request_shake(6.0, 0.5)
    if screen_flash:
        screen_flash.flash(Color(1.0, 0.9, 0.8), 0.3)
    var world_center = planet_data.grid_to_world(core.center)
    var particle = Node2D.new()
    particle.set_script(load("res://scripts/mining_particle.gd"))
    add_child(particle)
    particle.setup(world_center, Color(1.0, 0.3, 0.08), 20)
    print("[CoreTest] ★ 코어 #%d (%s %s) 파괴!" % [
        core.id, PlanetData.get_zone_name(core.zone), core.role
    ])
