extends CanvasLayer






var panel: PanelContainer
var is_visible: bool = false


var godmode: bool = false
var attack_disabled: bool = false
var infinite_time: bool = false
var laser_boost: bool = false
var damage_boost: bool = false
var range_boost: bool = false
var speed_boost: bool = false

func _ready():
    layer = 100
    add_to_group("debug_menu")
    _build_ui()
    panel.visible = false


func is_mouse_over_panel() -> bool:
    if not is_visible or not panel or not panel.visible:
        return false
    return panel.get_global_rect().has_point(panel.get_global_mouse_position())

func _unhandled_input(event):
    if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
        if not OS.is_debug_build():
            return
        is_visible = not is_visible
        panel.visible = is_visible

func _build_ui():
    panel = PanelContainer.new()
    panel.z_index = 100
    add_child(panel)

    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.05, 0.05, 0.1, 0.92)
    style.border_color = Color(1.0, 0.8, 0.0, 0.8)
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    style.set_content_margin_all(12)
    panel.add_theme_stylebox_override("panel", style)

    panel.anchor_left = 1.0
    panel.anchor_right = 1.0
    panel.anchor_top = 0.0
    panel.anchor_bottom = 1.0
    panel.offset_left = -290
    panel.offset_right = -8
    panel.offset_top = 8
    panel.offset_bottom = -8
    panel.clip_contents = true
    panel.mouse_filter = Control.MOUSE_FILTER_STOP

    var scroll = ScrollContainer.new()
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.add_child(scroll)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(vbox)

    var title = Label.new()
    title.text = "🔧 디버그 메뉴 (F1)"
    title.add_theme_font_size_override("font_size", 16)
    title.add_theme_color_override("font_color", Color.GOLD)
    vbox.add_child(title)

    vbox.add_child(HSeparator.new())


    _add_section_label(vbox, "💰 재화")
    _add_button(vbox, "+1K", _on_add_1k)
    _add_button(vbox, "+1M", _on_add_1m)
    _add_button(vbox, "+1B", _on_add_1b)
    _add_button(vbox, "+1T", _on_add_1t)
    _add_button(vbox, "🗑 자원 0으로", _on_reset_currency)

    vbox.add_child(HSeparator.new())


    _add_section_label(vbox, "🔴 코어")
    _add_button(vbox, "코어 +1", _on_add_core_1)
    _add_button(vbox, "코어 +5", _on_add_core_5)

    vbox.add_child(HSeparator.new())


    _add_section_label(vbox, "⛏️ 채굴")
    _add_button(vbox, "🛡️ 무적 토글", _on_toggle_godmode)
    _add_button(vbox, "🚫 공격 중지 토글", _on_toggle_attack_disabled)
    _add_button(vbox, "레이저 ×10 토글", _on_toggle_laser_boost)
    _add_button(vbox, "데미지 ×100 토글", _on_toggle_damage_boost)
    _add_button(vbox, "사거리 ×3 토글", _on_toggle_range_boost)
    _add_button(vbox, "이속 ×5 토글", _on_toggle_speed_boost)
    _add_button(vbox, "출항 시간 무제한 토글", _on_toggle_infinite_time)
    _add_button(vbox, "데미지 +10000", _on_add_damage_10k)
    _add_button(vbox, "배리어 +5", _on_add_barrier)
    _add_button(vbox, "행성 리셋", _on_reset_planet)

    vbox.add_child(HSeparator.new())


    _add_section_label(vbox, "🌳 노드")
    _add_button(vbox, "Phase 1~2 전부 구매", _on_buy_phase12)
    _add_button(vbox, "전체 노드 구매", _on_buy_all_nodes)
    _add_button(vbox, "노드 초기화", _on_reset_nodes)

    vbox.add_child(HSeparator.new())


    _add_section_label(vbox, "🛒 일괄 구매")
    _add_button(vbox, "모든 업그레이드 구매 (엔딩 제외)", _on_buy_everything)

    vbox.add_child(HSeparator.new())


    _add_section_label(vbox, "🎬 컷신 / 엔딩")
    _add_button(vbox, "인트로 컷신 보기", _on_play_intro)
    _add_button(vbox, "(구) 엔딩 컷신 보기", _on_play_ending)
    _add_button(vbox, "🏆 엔딩 테스트", _on_test_ending)
    _add_button(vbox, "🏆 에필로그 테스트", _on_test_epilogue)
    _add_button(vbox, "💀 코어 전부 파괴", _on_kill_all_cores)
    _add_button(vbox, "💥 블록 전부 파괴", _on_kill_all_blocks)
    _add_button(vbox, "🔄 엔딩 플래그 리셋", _on_reset_ending_flags)
    _add_button(vbox, "🌑 행성지배 팝업 보기", _on_test_mastery_popup)
    _add_button(vbox, "🎬 트레일러 인트로", _on_trailer_intro)
    _add_button(vbox, "🎬 타이틀 화면", _on_title_screen)
    _add_button(vbox, "자유 행성 모드 ON", _on_free_planet)

    vbox.add_child(HSeparator.new())


    _add_section_label(vbox, "🔬 테스트")
    _add_button(vbox, "코어 테스트 씬 진입", _on_core_test_scene)

    vbox.add_child(HSeparator.new())
    _add_section_label(vbox, "📊 현재 상태")

    var status = Label.new()
    status.name = "StatusLabel"
    status.add_theme_font_size_override("font_size", 11)
    status.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
    vbox.add_child(status)

func _add_section_label(parent: VBoxContainer, text: String):
    var label = Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 13)
    label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.5))
    parent.add_child(label)

func _add_button(parent: VBoxContainer, text: String, callback: Callable):
    var btn = Button.new()
    btn.text = text
    btn.add_theme_font_size_override("font_size", 12)
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.15, 0.15, 0.25)
    style.border_color = Color(0.4, 0.4, 0.6)
    style.set_border_width_all(1)
    style.set_corner_radius_all(4)
    style.set_content_margin_all(4)
    btn.add_theme_stylebox_override("normal", style)
    var hover = style.duplicate()
    hover.bg_color = Color(0.25, 0.25, 0.4)
    hover.border_color = Color(0.6, 0.6, 1.0)
    btn.add_theme_stylebox_override("hover", hover)
    btn.pressed.connect(callback)
    parent.add_child(btn)

func _process(_delta):
    if not is_visible:
        return
    var status = panel.find_child("StatusLabel", true, false)
    if status:
        var pd = Global.planet_data
        var blocks_str = "없음"
        var cores_str = "없음"
        if pd:
            blocks_str = str(pd.get_total_blocks())
            cores_str = "%d / %d" % [pd.get_alive_cores(), pd.cores.size()]

        status.text = (
            "재화: %s | 코어: %d\n" % [Global.format_number(Global.currency), Global.core_currency] + 
            "출항: #%d\n" % Global.sortie_count + 
            "블록: %s | 코어: %s\n" % [blocks_str, cores_str] + 
            "DMG: %.1f (flat:+%.1f ×season:%.1f) | 사거리: %.0f\n" % [Global.get_effective_damage(), Global.mining_damage_flat, Global.mining_season_dmg_mult, Global.get_effective_range()] + 
            "발사간격: %.2f초 | 배리어: %d\n" % [Global.mining_fire_rate, Global.mining_barrier_count] + 
            "영구DMG: +%.1f | 영구시간: +%.1f초\n" % [Global.perm_damage_accumulated, Global.perm_time_accumulated] + 
            "레이저×10: %s | DMG×100: %s | 사거리×3: %s | 이속×5: %s\n" % [
                "ON" if laser_boost else "OFF", 
                "ON" if damage_boost else "OFF", 
                "ON" if range_boost else "OFF", 
                "ON" if speed_boost else "OFF", 
            ] + 
            "무적: %s | 공격중지: %s\n" % [
                "ON" if godmode else "OFF", 
                "ON" if attack_disabled else "OFF", 
            ] + 
            "무제한: %s | 클리어: %s | 소멸: %s" % [
                "ON" if infinite_time else "OFF", 
                "O" if Global.planet_cleared else "X", 
                "O" if Global.planet_fully_destroyed else "X", 
            ]
        )


func _on_add_1k():
    Global.currency += 1000.0
    _log("재화 +1K")

func _on_add_1m():
    Global.currency += 1000000.0
    _log("재화 +1M")

func _on_add_1b():
    Global.currency += 1000000000.0
    _log("재화 +1B")

func _on_add_1t():
    Global.currency += 1000000000000.0
    _log("재화 +1T")

func _on_reset_currency():
    Global.currency = 0
    _log("재화 0으로 초기화")


func _on_add_core_1():
    Global.core_currency += 1
    _log("코어 +1 (보유: %d)" % Global.core_currency)

func _on_add_core_5():
    Global.core_currency += 5
    _log("코어 +5 (보유: %d)" % Global.core_currency)


func _on_toggle_godmode():
    godmode = not godmode
    _log("🛡️ 무적: %s" % ("ON" if godmode else "OFF"))

func _on_toggle_attack_disabled():
    attack_disabled = not attack_disabled
    _log("🚫 공격 중지: %s" % ("ON" if attack_disabled else "OFF"))

func _on_toggle_laser_boost():
    laser_boost = not laser_boost
    var ship = get_tree().get_first_node_in_group("player")
    if ship and "laser_damage" in ship:
        if laser_boost:
            ship.laser_damage *= 10.0
        else:
            ship.laser_damage /= 10.0
    _log("레이저 ×10: %s" % ("ON" if laser_boost else "OFF"))

func _on_toggle_damage_boost():
    damage_boost = not damage_boost
    if damage_boost:
        Global.mining_damage_flat += 999.0
    else:
        Global.mining_damage_flat -= 999.0
    _log("데미지 부스트: %s (DMG: %.1f)" % [
        "ON" if damage_boost else "OFF", Global.get_effective_damage()
    ])

func _on_toggle_range_boost():
    range_boost = not range_boost
    if range_boost:
        Global.mining_range_bonus += 600.0
    else:
        Global.mining_range_bonus -= 600.0
    _log("사거리 ×3: %s (사거리: %.0f)" % [
        "ON" if range_boost else "OFF", Global.get_effective_range()
    ])

func _on_toggle_speed_boost():
    speed_boost = not speed_boost
    if speed_boost:
        Global.mining_speed_bonus += 1200.0
    else:
        Global.mining_speed_bonus -= 1200.0
    var ship = get_tree().get_first_node_in_group("player")
    if ship:
        ship.move_speed = Global.get_effective_speed()
    _log("이속 ×5: %s (속도: %.0f)" % ["ON" if speed_boost else "OFF", Global.get_effective_speed()])

func _on_toggle_infinite_time():
    infinite_time = not infinite_time
    _log("출항 무제한: %s" % ("ON" if infinite_time else "OFF"))

func _on_add_damage_10k():
    Global.mining_damage_flat += 10000.0
    _log("데미지 +10000 (DMG: %.1f)" % Global.get_effective_damage())

func _on_add_barrier():
    var ship = get_tree().get_first_node_in_group("player")
    if ship and "barrier_count" in ship:
        ship.barrier_count += 5
        _log("배리어 +5 (현재: %d)" % ship.barrier_count)
    else:
        _log("채굴 씬이 아닙니다")

func _on_reset_planet():
    Global.initialize_planet()
    _log("행성 리셋 완료")


func _on_buy_phase12():

    var phase12 = [
        "start", "dmg1", "range1", "speed1", "time1", 
        "fire_rate1", "barrier1", "resource1", 
        "electric_unlock", "multi1", "gold_unlock", 
        "dmg2", "time2", "electric_range_up", "fire_rate2", 
    ]
    var count = 0
    for node_id in phase12:
        if node_id in Global.nodes:
            var max_lv = Global.nodes[node_id].get("max_level", 1)
            if Global.get_node_level(node_id) < max_lv:
                Global.node_levels[node_id] = max_lv
                count += 1
    Global.reapply_all_nodes()
    _reapply_debug_boosts()
    _log("Phase 1~2 노드 %d개 풀업" % count)

func _on_buy_all_nodes():

    var count = 0
    for node_id in Global.nodes:
        var max_lv = Global.nodes[node_id].get("max_level", 1)
        if Global.get_node_level(node_id) < max_lv:
            Global.node_levels[node_id] = max_lv
            count += 1
    Global.reapply_all_nodes()
    _reapply_debug_boosts()
    _log("전체 노드 %d개 풀업" % count)

func _on_reset_nodes():
    Global.node_levels.clear()
    Global.node_levels["start"] = 1
    Global.reapply_all_nodes()
    _reapply_debug_boosts()
    _log("노드 전부 초기화")


func _on_buy_everything():

    var node_count = 0
    for node_id in Global.nodes:
        var max_lv = Global.nodes[node_id].get("max_level", 1)
        if Global.get_node_level(node_id) < max_lv:
            Global.node_levels[node_id] = max_lv
            node_count += 1
    Global.reapply_all_nodes()
    _reapply_debug_boosts()


    var core_count = 0
    for uid in Global.core_upgrades:
        if uid == "planet_mastery":
            continue
        if uid not in Global.purchased_core_upgrades:
            Global.purchased_core_upgrades.append(uid)
            Global.apply_core_upgrade(uid)
            core_count += 1

    _log("전체 구매 완료! 노드 %d개 + 코어 %d개 (엔딩 제외)" % [node_count, core_count])


func _on_play_intro():
    ScreenFX.transition_to("res://scenes/intro_cutscene.tscn")

func _on_play_ending():
    ScreenFX.transition_to("res://scenes/ending_cutscene.tscn")


func _on_test_ending():
    Global.ending_shown = false
    Global.planet_cleared = true
    Global.end_sortie()
    ScreenFX.transition_to("res://scenes/game_ending.tscn")


func _on_test_epilogue():
    Global.epilogue_shown = false
    Global.planet_fully_destroyed = true
    Global.end_sortie()
    ScreenFX.transition_to("res://scenes/sortie_result.tscn")


func _on_kill_all_cores():
    if not Global.planet_data:
        _log("planet_data 없음")
        return
    var killed = 0
    for core in Global.planet_data.cores:
        if core.alive:
            core.alive = false
            core.hp = 0
            Global.record_core_fully_destroyed()
            killed += 1
    _log("코어 %d개 즉사 처리! (planet_cleared=%s)" % [killed, Global.planet_cleared])


func _on_kill_all_blocks():
    if not Global.planet_data:
        _log("planet_data 없음")
        return
    var pd = Global.planet_data
    var count = pd.blocks.size()
    pd.blocks.clear()

    for zone_id in pd.zone_current_blocks:
        pd.zone_current_blocks[zone_id] = 0
    Global.planet_fully_destroyed = true
    _log("블록 %d개 전부 제거! planet_fully_destroyed=true" % count)


func _on_reset_ending_flags():
    Global.ending_shown = false
    Global.epilogue_shown = false
    Global.save_game()
    _log("ending_shown/epilogue_shown 리셋 완료")


func _on_test_mastery_popup():
    var tree = get_tree()
    var current = tree.current_scene

    if current.has_method("_show_planet_mastery_popup"):
        current._show_planet_mastery_popup()
    else:
        _log("업그레이드 메뉴 화면에서만 사용 가능")

func _on_trailer_intro():
    ScreenFX.transition_to("res://scenes/trailer_intro.tscn")

func _on_title_screen():
    ScreenFX.transition_to("res://scenes/title_screen.tscn")

func _on_core_test_scene():
    ScreenFX.transition_to("res://scenes/core_test_scene.tscn")

func _on_free_planet():

    Global.planet_cleared = true
    Global.planet_fully_destroyed = true
    Global.planet_mastery_unlocked = true
    Global.free_planet_mode = true
    if "planet_mastery" not in Global.purchased_core_upgrades:
        Global.purchased_core_upgrades.append("planet_mastery")
    Global.regenerate_planet()
    _log("자유 행성 모드 ON! 새 행성 생성 완료")


func _reapply_debug_boosts():
    if speed_boost:
        Global.mining_speed_bonus += 1200.0
    if range_boost:
        Global.mining_range_bonus += 600.0
    if damage_boost:
        Global.mining_damage_flat += 999.0
    var ship = get_tree().get_first_node_in_group("player")
    if ship:
        if laser_boost and "laser_damage" in ship:
            ship.laser_damage *= 10.0
        ship.move_speed = Global.get_effective_speed()

func _log(msg: String):
    print("[DEBUG] ", msg)
