extends Control





const C_BG: = Color(0.02, 0.02, 0.06)
const C_CYAN: = Color(0.2, 0.85, 1.0)
const C_ORANGE: = Color(1.0, 0.5, 0.15)
const C_RED: = Color(1.0, 0.2, 0.1)
const C_GREEN: = Color(0.3, 1.0, 0.5)
const C_WHITE: = Color(0.9, 0.9, 0.95)
const C_DIM: = Color(0.5, 0.5, 0.6)
const C_YELLOW: = Color(1.0, 0.85, 0.15)


const WEAPON_KEY_MAP: Dictionary = {
    "laser": "WPN_LASER", 
    "critical": "WPN_CRITICAL", 
    "charged_shot": "WPN_CHARGED", 
    "electric": "WPN_ELECTRIC", 
    "drone": "WPN_DRONE", 
    "chain_lightning": "WPN_CHAIN", 
    "mega_laser": "WPN_MEGA", 
    "shockwave": "WPN_SHOCKWAVE", 
    "overdrive": "WPN_OVERDRIVE", 
    "core_breaker": "WPN_CORE_BREAKER", 
    "combo": "WPN_COMBO", 
}

var scroll_container: ScrollContainer
var content_vbox: VBoxContainer

func _ready():
    RenderingServer.set_default_clear_color(C_BG)
    _build_ui()

func _build_ui():

    var bg = ColorRect.new()
    bg.color = C_BG
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)


    var main_vbox = VBoxContainer.new()
    main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
    main_vbox.offset_left = 20
    main_vbox.offset_right = -20
    main_vbox.offset_top = 10
    main_vbox.offset_bottom = -10
    main_vbox.add_theme_constant_override("separation", 0)
    add_child(main_vbox)


    var top_bar = HBoxContainer.new()
    top_bar.custom_minimum_size.y = 50
    top_bar.add_theme_constant_override("separation", 20)
    main_vbox.add_child(top_bar)

    var title = Label.new()
    title.text = tr("STATS_TITLE")
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", C_CYAN)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top_bar.add_child(title)

    var back_btn = Button.new()
    back_btn.text = tr("STATS_BACK")
    back_btn.custom_minimum_size = Vector2(130, 36)
    back_btn.add_theme_font_size_override("font_size", 16)
    back_btn.pressed.connect(_on_back)
    top_bar.add_child(back_btn)


    var sep = HSeparator.new()
    sep.add_theme_constant_override("separation", 8)
    main_vbox.add_child(sep)


    scroll_container = ScrollContainer.new()
    scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    main_vbox.add_child(scroll_container)

    content_vbox = VBoxContainer.new()
    content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content_vbox.add_theme_constant_override("separation", 12)
    scroll_container.add_child(content_vbox)


    _build_summary_section()
    _add_separator()
    _build_sortie_list()





func _build_summary_section():
    var history = Global.sortie_history
    if history.is_empty():
        var empty_label = Label.new()
        empty_label.text = tr("STATS_EMPTY")
        empty_label.add_theme_font_size_override("font_size", 18)
        empty_label.add_theme_color_override("font_color", C_DIM)
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        content_vbox.add_child(empty_label)
        return


    var total_res: float = 0.0
    var total_blocks: int = 0
    var total_cores: int = 0
    var total_nodes: int = 0
    var total_time_ms: int = 0
    var best_res: float = 0.0
    var best_res_sortie: int = 0
    var best_blocks: int = 0
    var best_blocks_sortie: int = 0
    var max_dps: float = 0.0
    var max_dps_sortie: int = 0
    var max_combo: int = 0

    for rec in history:
        total_res += rec.get("resources", 0)
        total_blocks += rec.get("blocks", 0)
        total_cores += rec.get("cores", 0)
        total_nodes += rec.get("nodes_purchased", []).size()
        total_time_ms += rec.get("time_ms", 0)

        var res = rec.get("resources", 0)
        if res > best_res:
            best_res = res
            best_res_sortie = rec.get("sortie_num", 0)

        var blk = rec.get("blocks", 0)
        if blk > best_blocks:
            best_blocks = blk
            best_blocks_sortie = rec.get("sortie_num", 0)

        var dps = rec.get("dps_end", 0)
        if dps > max_dps:
            max_dps = dps
            max_dps_sortie = rec.get("sortie_num", 0)

        var cmb = rec.get("combo_max", 0)
        if cmb > max_combo:
            max_combo = cmb

    var total_time_min = total_time_ms / 60000.0


    var section_title = Label.new()
    section_title.text = tr("STATS_SUMMARY")
    section_title.add_theme_font_size_override("font_size", 22)
    section_title.add_theme_color_override("font_color", C_YELLOW)
    content_vbox.add_child(section_title)


    var grid = GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 30)
    grid.add_theme_constant_override("v_separation", 6)
    content_vbox.add_child(grid)


    var real_play_min = Global.total_play_time / 60.0
    var real_play_h = int(real_play_min / 60)
    var real_play_m = int(real_play_min) % 60
    var play_time_str = tr("TIME_HOUR_MIN_FMT") % [real_play_h, real_play_m] if real_play_h > 0 else tr("TIME_MIN_FMT") % real_play_min

    var stats = [
        [tr("STATS_TOTAL_SORTIES"), tr("STATS_COUNT_FMT") % str(history.size())], 
        [tr("STATS_TOTAL_PLAYTIME"), play_time_str], 
        [tr("STATS_TOTAL_SORTIE_TIME"), tr("TIME_MIN_FMT") % total_time_min], 
        [tr("STATS_TOTAL_RESOURCE"), Global.format_number(total_res)], 
        [tr("STATS_TOTAL_BLOCKS"), tr("STATS_BLOCKS_FMT") % Global.format_number(total_blocks)], 
        [tr("STATS_TOTAL_CORES"), tr("STATS_BLOCKS_FMT") % str(total_cores)], 
        [tr("STATS_TOTAL_NODES"), tr("STATS_BLOCKS_FMT") % str(total_nodes)], 
        ["", ""], 
        [tr("STATS_BEST_RES"), tr("STATS_RECORD_FMT") % [Global.format_number(best_res), best_res_sortie]], 
        [tr("STATS_BEST_BLOCKS"), tr("STATS_RECORD_FMT") % [str(best_blocks), best_blocks_sortie]], 
        [tr("STATS_BEST_DPS"), tr("STATS_RECORD_FMT") % [Global.format_number(max_dps), max_dps_sortie]], 
        [tr("STATS_BEST_COMBO"), "%d" % max_combo], 
    ]

    for stat in stats:
        if stat[0] == "":

            var spacer1 = Control.new()
            spacer1.custom_minimum_size.y = 4
            grid.add_child(spacer1)
            var spacer2 = Control.new()
            spacer2.custom_minimum_size.y = 4
            grid.add_child(spacer2)
            continue

        var key_label = Label.new()
        key_label.text = stat[0]
        key_label.add_theme_font_size_override("font_size", 16)
        key_label.add_theme_color_override("font_color", C_DIM)
        key_label.custom_minimum_size.x = 180
        grid.add_child(key_label)

        var val_label = Label.new()
        val_label.text = stat[1]
        val_label.add_theme_font_size_override("font_size", 16)
        val_label.add_theme_color_override("font_color", C_WHITE)
        grid.add_child(val_label)





func _build_sortie_list():
    var history = Global.sortie_history
    if history.is_empty():
        return

    var section_title = Label.new()
    section_title.text = tr("STATS_HISTORY")
    section_title.add_theme_font_size_override("font_size", 22)
    section_title.add_theme_color_override("font_color", C_YELLOW)
    content_vbox.add_child(section_title)


    for i in range(history.size() - 1, -1, -1):
        var rec = history[i]
        _create_sortie_card(rec)

func _create_sortie_card(rec: Dictionary):
    var card = PanelContainer.new()
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.04, 0.04, 0.08, 0.9)
    style.set_border_width_all(1)
    style.border_color = Color(0.15, 0.15, 0.25)
    style.set_corner_radius_all(6)
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 10
    style.content_margin_bottom = 10


    if rec.get("cores", 0) > 0:
        style.border_color = C_RED.lerp(Color.WHITE, 0.3)
        style.set_border_width_all(2)

    card.add_theme_stylebox_override("panel", style)
    content_vbox.add_child(card)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 4)
    card.add_child(vbox)


    var header = HBoxContainer.new()
    header.add_theme_constant_override("separation", 12)
    vbox.add_child(header)

    var sortie_num = rec.get("sortie_num", 0)
    var phase = rec.get("phase", 1)
    var time_ms = rec.get("time_ms", 0)
    var time_sec = time_ms / 1000.0

    var num_label = Label.new()
    num_label.text = tr("SORTIE_NUM") % sortie_num
    num_label.add_theme_font_size_override("font_size", 18)
    num_label.add_theme_color_override("font_color", C_CYAN)
    header.add_child(num_label)

    var phase_label = Label.new()
    phase_label.text = "Phase %d" % phase
    phase_label.add_theme_font_size_override("font_size", 14)
    phase_label.add_theme_color_override("font_color", _get_phase_color(phase))
    header.add_child(phase_label)

    var spacer = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(spacer)

    var time_label = Label.new()
    time_label.text = tr("STATS_TIME_FMT") % time_sec
    time_label.add_theme_font_size_override("font_size", 14)
    time_label.add_theme_color_override("font_color", C_DIM)
    header.add_child(time_label)


    var stats_row = HBoxContainer.new()
    stats_row.add_theme_constant_override("separation", 20)
    vbox.add_child(stats_row)

    var res = rec.get("resources", 0)
    var blocks = rec.get("blocks", 0)
    var cores = rec.get("cores", 0)

    _add_stat_label(stats_row, "💰 %s" % Global.format_number(res), C_ORANGE)
    _add_stat_label(stats_row, tr("STATS_BLOCKS_SHORT") % blocks, C_WHITE)
    if cores > 0:
        _add_stat_label(stats_row, tr("STATS_CORES_SHORT") % cores, C_RED)

    var combo_max = rec.get("combo_max", 0)
    if combo_max > 0:
        _add_stat_label(stats_row, tr("STATS_COMBO_SHORT") % combo_max, C_YELLOW)


    var dps_start = rec.get("dps_start", 0)
    var dps_end = rec.get("dps_end", 0)
    var dps_label = Label.new()
    dps_label.text = "DPS: %s → %s" % [Global.format_number(dps_start), Global.format_number(dps_end)]
    dps_label.add_theme_font_size_override("font_size", 13)
    if dps_end > dps_start * 1.1:
        dps_label.add_theme_color_override("font_color", C_GREEN)
    else:
        dps_label.add_theme_color_override("font_color", C_DIM)
    vbox.add_child(dps_label)


    var nodes_purchased = rec.get("nodes_purchased", [])
    if nodes_purchased.size() > 0:
        var node_text = tr("STATS_PURCHASED")
        var names: Array = []
        for np in nodes_purchased:
            var name_str = tr(np.get("name", np.get("id", "?")))
            var lv = np.get("level", 1)
            names.append("%s Lv%d" % [name_str, lv])
        node_text += ", ".join(names)

        var node_label = Label.new()
        node_label.text = node_text
        node_label.add_theme_font_size_override("font_size", 12)
        node_label.add_theme_color_override("font_color", Color(0.4, 0.7, 0.9))
        node_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vbox.add_child(node_label)


    var weapons = rec.get("weapons", [])
    if weapons.size() > 1:
        var weapon_names: Array = []
        for w in weapons:
            var key = WEAPON_KEY_MAP.get(w, "")
            weapon_names.append(tr(key) if key != "" else w)
        var weapon_label = Label.new()
        weapon_label.text = tr("STATS_WEAPONS") + " / ".join(weapon_names)
        weapon_label.add_theme_font_size_override("font_size", 11)
        weapon_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))
        weapon_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vbox.add_child(weapon_label)





func _add_stat_label(parent: Control, text: String, color: Color):
    var label = Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 15)
    label.add_theme_color_override("font_color", color)
    parent.add_child(label)

func _get_phase_color(phase: int) -> Color:
    match phase:
        1: return Color(0.5, 0.8, 1.0)
        2: return Color(1.0, 0.85, 0.3)
        3: return Color(0.3, 1.0, 0.5)
        4: return Color(0.8, 0.4, 1.0)
        5: return Color(1.0, 0.3, 0.2)
    return C_WHITE

func _add_separator():
    var sep = HSeparator.new()
    sep.add_theme_constant_override("separation", 12)
    content_vbox.add_child(sep)

func _on_back():
    ScreenFX.transition_to("res://scenes/upgrade_menu.tscn")
