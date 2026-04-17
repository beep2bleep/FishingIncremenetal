extends Control








const BG_COLOR: = Color(0.02, 0.02, 0.05)
const PANEL_BG: = Color(0.18, 0.19, 0.22, 0.92)
const PANEL_BORDER: = Color(0.3, 0.3, 0.35, 0.3)
const CYAN: = Color(0.2, 0.85, 1.0)
const ORANGE: = Color(1.0, 0.55, 0.15)
const WHITE: = Color(0.92, 0.92, 0.95)
const DIM: = Color(0.55, 0.55, 0.62)
const GREEN: = Color(0.3, 1.0, 0.5)
const RED: = Color(1.0, 0.25, 0.1)
const GOLD: = Color(1.0, 0.85, 0.2)
const ELECTRIC_CLR: = Color(0.4, 0.85, 1.0)
const CHAIN_CLR: = Color(0.7, 0.5, 1.0)
const MEGA_CLR: = Color(1.0, 0.6, 0.2)
const DRONE_CLR: = Color(0.3, 1.0, 0.5)



const ZONE_MAP_COLORS = {
    0: Color(0.4, 1.5, 2.0), 
    1: Color(1.4, 1.3, 0.5), 
    2: Color(1.7, 1.0, 0.3), 
    3: Color(0.4, 0.8, 2.0), 
    4: Color(2.0, 0.15, 0.05), 
}
const CORE_MAP_COLOR: = Color(2.5, 0.3, 0.08)
const ELECTRIC_MAP_COLOR: = Color(0.3, 0.8, 1.0)
const GOLD_MAP_COLOR: = Color(1.0, 0.85, 0.2)
const BLOCK_MAP_FILL: = Color(0.02, 0.02, 0.035)
const EMPTY_MAP_COLOR: = Color(0.008, 0.008, 0.02)


const ZOOM_DURATION: float = 0.5
const START_SCALE: float = 2.0
const END_MAP_SIZE: float = 350.0
const MAP_GAP: float = 16.0


var planet_minimap: TextureRect
var center_container: Control
var stats: Dictionary = {}

func _ready():
    RenderingServer.set_default_clear_color(BG_COLOR)
    stats = Global.sortie_combat_stats.duplicate() if Global.sortie_combat_stats.size() > 0 else {}
    _build_ui()
    _generate_planet_minimap()
    _start_animations()
    call_deferred("_deferred_save")



    if not Global.planet_fully_destroyed and Global.planet_data and Global.planet_data.get_total_blocks() == 0:
        Global.planet_fully_destroyed = true
        print("[🏆] planet_fully_destroyed 보정 (sortie_result에서 감지)")
    if Global.planet_fully_destroyed and not Global.epilogue_shown:
        call_deferred("_show_epilogue")

func _deferred_save():
    await get_tree().create_timer(0.5).timeout
    Global.save_game()




func _build_ui():

    planet_minimap = TextureRect.new()
    planet_minimap.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
    planet_minimap.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    planet_minimap.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    planet_minimap.size = Vector2(END_MAP_SIZE, END_MAP_SIZE)
    add_child(planet_minimap)


    center_container = VBoxContainer.new()
    center_container.add_theme_constant_override("separation", 14)
    add_child(center_container)
    center_container.modulate = Color(1, 1, 1, 0)


    var title = _make_label(tr("귀환 완료"), 32, CYAN)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center_container.add_child(title)


    var sub_hbox = HBoxContainer.new()
    sub_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    sub_hbox.add_theme_constant_override("separation", 24)
    center_container.add_child(sub_hbox)
    var sortie_lbl = _make_label(tr("SORTIE_NUM") % Global.sortie_count, 15, DIM)
    sub_hbox.add_child(sortie_lbl)
    var progress = _calc_mining_progress()
    var progress_lbl = _make_label(tr("MINING_PROGRESS") % progress, 15, GREEN)
    sub_hbox.add_child(progress_lbl)


    _build_zone_progress_panel(center_container)


    var content_hbox = HBoxContainer.new()
    content_hbox.add_theme_constant_override("separation", 14)
    content_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    center_container.add_child(content_hbox)

    _build_income_panel(content_hbox)

    var right_vbox = VBoxContainer.new()
    right_vbox.add_theme_constant_override("separation", 10)
    content_hbox.add_child(right_vbox)
    _build_damage_panel(right_vbox)
    _build_activity_panel(right_vbox)


    var btn_hbox = HBoxContainer.new()
    btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_hbox.add_theme_constant_override("separation", 20)
    center_container.add_child(btn_hbox)

    var upgrade_btn = _make_button(tr("업그레이드"))
    upgrade_btn.pressed.connect(_on_upgrade)
    btn_hbox.add_child(upgrade_btn)

    var continue_btn = _make_button(tr("계속"))
    continue_btn.pressed.connect(_on_continue)
    btn_hbox.add_child(continue_btn)




func _build_zone_progress_panel(parent: Control):
    if not Global.planet_data:
        return

    var panel = _make_panel()
    parent.add_child(panel)
    var margin = _make_panel_margin(panel)

    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 16)
    hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    margin.add_child(hbox)


    var zones = [
        {"zone": PlanetData.Zone.SPRING, "icon": "🌸", "name": tr("🌸 봄"), "color": ZONE_MAP_COLORS[0]}, 
        {"zone": PlanetData.Zone.SUMMER, "icon": "☀️", "name": tr("☀️ 여름"), "color": ZONE_MAP_COLORS[1]}, 
        {"zone": PlanetData.Zone.AUTUMN, "icon": "🍂", "name": tr("🍂 가을"), "color": ZONE_MAP_COLORS[2]}, 
        {"zone": PlanetData.Zone.WINTER, "icon": "❄️", "name": tr("❄️ 겨울"), "color": ZONE_MAP_COLORS[3]}, 
    ]

    for z in zones:
        var ratio = Global.planet_data.get_zone_destruction_ratio(z.zone)
        var percent = ratio * 100.0

        var zone_vbox = VBoxContainer.new()
        zone_vbox.add_theme_constant_override("separation", 3)
        zone_vbox.custom_minimum_size = Vector2(90, 0)
        hbox.add_child(zone_vbox)


        var name_lbl = _make_label(z.name, 13, z.color)
        name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        zone_vbox.add_child(name_lbl)


        var bar_bg = ColorRect.new()
        bar_bg.custom_minimum_size = Vector2(80, 8)
        bar_bg.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        bar_bg.color = Color(0.15, 0.15, 0.18)
        zone_vbox.add_child(bar_bg)

        var bar_fill = ColorRect.new()
        bar_fill.custom_minimum_size = Vector2(80 * ratio, 8)
        bar_fill.color = z.color
        bar_fill.position = Vector2.ZERO
        bar_bg.add_child(bar_fill)


        var pct_color = GREEN if percent >= 100.0 else (WHITE if percent > 0 else DIM)
        var pct_lbl = _make_label("%.1f%%" % percent, 12, pct_color)
        pct_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        zone_vbox.add_child(pct_lbl)


        var boost_text = _get_zone_boost_text(z.zone, ratio)
        if boost_text != "":
            var boost_lbl = _make_label(boost_text, 10, z.color.lightened(0.3))
            boost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            zone_vbox.add_child(boost_lbl)


func _get_zone_boost_text(zone: int, ratio: float) -> String:
    var dmg_parts: Array = []
    var res_parts: Array = []


    for boost in Global.season_dmg_boosts:
        if boost.zone == zone:
            var current = 1.0 + (boost.mult - 1.0) * ratio
            dmg_parts.append("⚔×%.2f" % current)


    for boost in Global.season_res_boosts:
        if boost.zone == zone:
            var current = 1.0 + (boost.mult - 1.0) * ratio
            res_parts.append("💰×%.2f" % current)

    var parts: Array = dmg_parts + res_parts
    if parts.is_empty():
        return ""
    return " ".join(parts)




func _build_income_panel(parent: Control):
    var panel = _make_panel()
    parent.add_child(panel)

    var margin = _make_panel_margin(panel)
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 7)
    margin.add_child(vbox)

    var earned = Global.sortie_resources * Global.ore_sell_rate
    _add_income_row(vbox, "💰", Global.format_number(earned), ORANGE)

    _add_income_row(vbox, "💥", tr("BLOCKS_FMT") % Global.sortie_blocks_destroyed, WHITE)
    if Global.sortie_cores_destroyed > 0:
        _add_income_row(vbox, "★", tr("CORES_FMT") % Global.sortie_cores_destroyed, RED)

    vbox.add_child(_make_separator())

    var total_row = HBoxContainer.new()
    total_row.add_theme_constant_override("separation", 10)
    vbox.add_child(total_row)
    var total_lbl = _make_label("TOTAL", 13, DIM)
    total_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    total_row.add_child(total_lbl)
    var total_earned = Global.sortie_resources * Global.ore_sell_rate
    var total_val = _make_label(Global.format_number(total_earned), 14, WHITE)
    total_row.add_child(total_val)

    var currency_lbl = _make_label(Global.format_number(Global.currency), 28, GOLD)
    currency_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(currency_lbl)

func _add_income_row(parent: Control, icon: String, value: String, color: Color):
    var row = HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    parent.add_child(row)
    var icon_lbl = _make_label(icon, 16, color)
    row.add_child(icon_lbl)
    var spacer = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(spacer)
    var val_lbl = _make_label(value, 16, WHITE)
    row.add_child(val_lbl)




func _build_damage_panel(parent: Control):
    var entries: Array = []

    entries.append({"icon": "⚔", "name": tr("STAT_LASER"), "val": _fmt(_get_stat("dmg_laser")), "color": ORANGE})
    if Global.critical_unlocked:
        entries.append({"icon": "🎯", "name": tr("STAT_CRITICAL"), "val": _fmt(_get_stat("dmg_crit_bonus")), "color": Color(1.0, 1.0, 0.3)})
    if Global.charged_shot_unlocked:
        entries.append({"icon": "🔥", "name": tr("STAT_CHARGED"), "val": _fmt(_get_stat("dmg_charged_bonus")), "color": Color(1.0, 0.6, 0.15)})
    if Global.aoe_mining_unlocked:
        entries.append({"icon": "💢", "name": tr("STAT_AOE"), "val": _fmt(_get_stat("dmg_aoe")), "color": Color(1.0, 0.7, 0.3)})
    if Global.electric_unlocked:
        entries.append({"icon": "⚡", "name": tr("STAT_ELECTRIC"), "val": _fmt(_get_stat("dmg_electric")), "color": ELECTRIC_CLR})
    if Global.chain_lightning_unlocked:
        entries.append({"icon": "⛓", "name": tr("STAT_CHAIN"), "val": _fmt(_get_stat("dmg_chain")), "color": CHAIN_CLR})
    if Global.drone_unlocked:
        entries.append({"icon": "🤖", "name": tr("STAT_DRONE"), "val": _fmt(_get_stat("dmg_drone")), "color": DRONE_CLR})
    if Global.mega_laser_unlocked:
        entries.append({"icon": "⚡", "name": tr("STAT_MEGA"), "val": _fmt(_get_stat("dmg_mega")), "color": MEGA_CLR})

    if entries.is_empty():
        return

    var panel = _make_panel()
    parent.add_child(panel)
    var margin = _make_panel_margin(panel)

    var inner = VBoxContainer.new()
    inner.add_theme_constant_override("separation", 6)
    margin.add_child(inner)

    var title = _make_label(tr("DMG_BY_WEAPON"), 12, DIM)
    inner.add_child(title)

    var grid = GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 6)
    inner.add_child(grid)

    for e in entries:
        _add_grid_cell(grid, e)




func _build_activity_panel(parent: Control):
    var entries: Array = []

    if Global.critical_unlocked:
        entries.append({"icon": "✨", "name": tr("STAT_CRITICAL"), "val": str(_get_stat_int("crits_landed")), "color": Color(1.0, 1.0, 0.3)})
    if Global.charged_shot_unlocked:
        entries.append({"icon": "🔥", "name": tr("STAT_CHARGED"), "val": str(_get_stat_int("charged_shots")), "color": Color(1.0, 0.6, 0.15)})
    if Global.electric_unlocked:
        entries.append({"icon": "⚡", "name": tr("STAT_ELECTRIC"), "val": str(_get_stat_int("kills_electric")), "color": ELECTRIC_CLR})
    if Global.drone_unlocked:
        entries.append({"icon": "🤖", "name": tr("STAT_DRONE"), "val": str(_get_stat_int("kills_drone")), "color": DRONE_CLR})
    if Global.mega_laser_unlocked:
        entries.append({"icon": "⚡", "name": tr("STAT_MEGA"), "val": str(_get_stat_int("mega_count")), "color": MEGA_CLR})
    if Global.shockwave_unlocked:
        entries.append({"icon": "🌀", "name": tr("STAT_SHOCKWAVE"), "val": str(_get_stat_int("shockwave_count")), "color": GOLD})
    if Global.overdrive_unlocked:
        entries.append({"icon": "💢", "name": tr("STAT_OVERDRIVE"), "val": str(_get_stat_int("overdrive_count")), "color": RED})
    if Global.combo_unlocked:
        entries.append({"icon": "🔥", "name": tr("STAT_MAX_COMBO"), "val": "×%d" % _get_stat_int("combo_max"), "color": Color(1.0, 0.4, 0.1)})
    var barrier_used = _get_stat_int("barriers_used")
    if barrier_used > 0:
        entries.append({"icon": "🛡", "name": tr("STAT_BARRIER"), "val": str(barrier_used), "color": CYAN})

    if entries.is_empty():
        return

    var panel = _make_panel()
    parent.add_child(panel)
    var margin = _make_panel_margin(panel)

    var inner = VBoxContainer.new()
    inner.add_theme_constant_override("separation", 6)
    margin.add_child(inner)

    var title = _make_label(tr("TRIGGER_COUNT"), 12, DIM)
    inner.add_child(title)

    var grid = GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 6)
    inner.add_child(grid)

    for e in entries:
        _add_grid_cell(grid, e)





func _add_grid_cell(grid: GridContainer, entry: Dictionary):
    var cell = HBoxContainer.new()
    cell.custom_minimum_size = Vector2(140, 0)
    cell.add_theme_constant_override("separation", 5)

    var icon_lbl = _make_label(entry.icon, 15, entry.color)
    cell.add_child(icon_lbl)

    var name_lbl = _make_label(entry.name, 11, DIM)
    cell.add_child(name_lbl)

    var spacer = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cell.add_child(spacer)

    var val_lbl = _make_label(entry.val, 16, WHITE)
    cell.add_child(val_lbl)

    grid.add_child(cell)




func _make_label(text: String, font_size: int, color: Color) -> Label:
    var lbl = Label.new()
    lbl.text = text
    lbl.add_theme_font_size_override("font_size", font_size)
    lbl.add_theme_color_override("font_color", color)
    return lbl

func _make_panel() -> PanelContainer:
    var panel = PanelContainer.new()
    var style = StyleBoxFlat.new()
    style.bg_color = PANEL_BG
    style.set_corner_radius_all(8)
    style.border_width_top = 1
    style.border_width_bottom = 1
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_color = PANEL_BORDER
    panel.add_theme_stylebox_override("panel", style)
    return panel

func _make_panel_margin(panel: PanelContainer) -> MarginContainer:
    var margin = MarginContainer.new()
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_bottom", 10)
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_right", 14)
    panel.add_child(margin)
    return margin

func _make_separator() -> HSeparator:
    var sep = HSeparator.new()
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.3, 0.3, 0.35, 0.3)
    style.content_margin_top = 1
    style.content_margin_bottom = 1
    sep.add_theme_stylebox_override("separator", style)
    return sep

func _make_button(text: String) -> Button:
    var btn = Button.new()
    btn.text = text
    btn.custom_minimum_size = Vector2(160, 42)
    btn.add_theme_font_size_override("font_size", 18)
    btn.add_theme_color_override("font_color", WHITE)
    btn.add_theme_color_override("font_hover_color", CYAN)

    var normal_style = StyleBoxFlat.new()
    normal_style.bg_color = Color(0.15, 0.16, 0.2, 0.95)
    normal_style.border_color = Color(0.3, 0.3, 0.35, 0.5)
    normal_style.set_border_width_all(1)
    normal_style.set_corner_radius_all(5)
    normal_style.content_margin_left = 14
    normal_style.content_margin_right = 14
    normal_style.content_margin_top = 8
    normal_style.content_margin_bottom = 8
    btn.add_theme_stylebox_override("normal", normal_style)

    var hover_style = normal_style.duplicate()
    hover_style.bg_color = Color(0.2, 0.22, 0.28, 0.95)
    hover_style.border_color = CYAN * 0.6
    btn.add_theme_stylebox_override("hover", hover_style)

    var pressed_style = normal_style.duplicate()
    pressed_style.bg_color = Color(0.1, 0.11, 0.14, 0.95)
    btn.add_theme_stylebox_override("pressed", pressed_style)

    return btn

func _fmt(value: float) -> String:
    return Global.format_number(value)

func _get_stat(key: String) -> float:
    return stats.get(key, 0.0) as float

func _get_stat_int(key: String) -> int:
    return int(stats.get(key, 0))




func _calc_mining_progress() -> float:
    if not Global.planet_data:
        return 0.0
    var radius = PlanetData.PLANET_RADIUS
    var total_possible: int = 0
    for x in range( - radius, radius + 1):
        for y in range( - radius, radius + 1):
            if x * x + y * y <= radius * radius:
                total_possible += 1
    var remaining = Global.planet_data.get_total_blocks()
    var destroyed = total_possible - remaining
    if total_possible == 0:
        return 0.0
    return (float(destroyed) / float(total_possible)) * 100.0




func _generate_planet_minimap():
    if not Global.planet_data:
        return
    var pd = Global.planet_data
    var radius = PlanetData.PLANET_RADIUS
    var img_size = radius * 2 + 1
    var img = Image.create(img_size, img_size, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    var radius_sq = radius * radius


    for x in range( - radius, radius + 1):
        for y in range( - radius, radius + 1):
            if x * x + y * y <= radius_sq:
                img.set_pixel(x + radius, y + radius, EMPTY_MAP_COLOR)


    for pos in pd.blocks:
        var bx = pos.x
        var by = pos.y
        if bx * bx + by * by > radius_sq:
            continue
        var block = pd.blocks[pos]
        var zone = PlanetData.get_zone(pos)
        var zone_c = ZONE_MAP_COLORS.get(zone, ZONE_MAP_COLORS[0])
        var dist = sqrt(float(bx * bx + by * by))
        var depth = dist / float(radius)


        var zone_hint = 0.08 + depth * 0.14
        var color = BLOCK_MAP_FILL.lerp(
            Color(zone_c.r * 0.12, zone_c.g * 0.12, zone_c.b * 0.12, 1.0), zone_hint)

        if block.type == PlanetData.BlockType.CORE:
            color = Color(0.8, 0.08, 0.04)

        img.set_pixel(bx + radius, by + radius, color)


    var dirs4 = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
    for pos in pd.blocks:
        var bx = pos.x
        var by = pos.y
        if bx * bx + by * by > radius_sq:
            continue
        var my_zone = PlanetData.get_zone(pos)
        var is_boundary = false
        var neighbor_zone_c = Color.BLACK
        for dir in dirs4:
            var nb = pos + dir
            if pd.blocks.has(nb):
                var nb_zone = PlanetData.get_zone(nb)
                if nb_zone != my_zone:
                    is_boundary = true
                    neighbor_zone_c = ZONE_MAP_COLORS.get(nb_zone, ZONE_MAP_COLORS[0])
                    break
        if not is_boundary:
            continue

        var my_zone_c = ZONE_MAP_COLORS.get(my_zone, ZONE_MAP_COLORS[0])

        var blend = Color(
            (my_zone_c.r + neighbor_zone_c.r) * 0.5 * 0.3, 
            (my_zone_c.g + neighbor_zone_c.g) * 0.5 * 0.3, 
            (my_zone_c.b + neighbor_zone_c.b) * 0.5 * 0.3
        )
        img.set_pixel(bx + radius, by + radius, blend)


    var dirs = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
    for pos in pd.blocks:
        var bx = pos.x
        var by = pos.y
        if bx * bx + by * by > radius_sq:
            continue


        var has_exposed = false
        for dir in dirs:
            var nb = pos + dir
            var nd2 = nb.x * nb.x + nb.y * nb.y
            if not pd.blocks.has(nb) or nd2 > radius_sq:
                has_exposed = true
                break
        if not has_exposed:
            continue


        var block = pd.blocks[pos]
        var edge_c: Color
        if block.type == PlanetData.BlockType.CORE:
            edge_c = CORE_MAP_COLOR
        else:
            var zone = PlanetData.get_zone(pos)
            edge_c = ZONE_MAP_COLORS.get(zone, ZONE_MAP_COLORS[0])


        var dist = sqrt(float(bx * bx + by * by))
        var brightness = clampf(dist / float(radius) * 1.2, 0.5, 1.0)
        edge_c = Color(edge_c.r * brightness, edge_c.g * brightness, edge_c.b * brightness)

        img.set_pixel(bx + radius, by + radius, edge_c)


    var outline_c = Color(0.15, 0.5, 0.65, 0.8)
    var r_inner = float(radius - 1.5)
    var r_outer = float(radius + 0.5)
    for x in range(img_size):
        for y in range(img_size):
            var gx = x - radius
            var gy = y - radius
            var dist = sqrt(float(gx * gx + gy * gy))
            if dist >= r_inner and dist <= r_outer:

                var has_nearby = pd.blocks.has(Vector2i(gx, gy))
                if not has_nearby and dist > 1.0:

                    var dx = - gx / dist
                    var dy = - gy / dist
                    for step in [1, 2]:
                        if pd.blocks.has(Vector2i(gx + int(round(dx * step)), gy + int(round(dy * step)))):
                            has_nearby = true
                            break
                if not has_nearby:
                    continue
                var existing = img.get_pixel(x, y)
                if existing.r + existing.g + existing.b < 0.1:
                    img.set_pixel(x, y, outline_c)

    planet_minimap.texture = ImageTexture.create_from_image(img)


    var png_bytes = img.save_png_to_buffer()
    Global.planet_snapshots.append(png_bytes)


func _get_zone_map_color(pos: Vector2i) -> Color:
    var zone = PlanetData.get_zone(pos)
    return ZONE_MAP_COLORS.get(zone, ZONE_MAP_COLORS[0])




func _start_animations():
    var vp = get_viewport_rect().size

    planet_minimap.pivot_offset = Vector2(END_MAP_SIZE, END_MAP_SIZE) * 0.5
    planet_minimap.size = Vector2(END_MAP_SIZE, END_MAP_SIZE)
    var center_pos = (vp - Vector2(END_MAP_SIZE, END_MAP_SIZE)) * 0.5
    planet_minimap.position = center_pos
    planet_minimap.scale = Vector2(START_SCALE, START_SCALE)
    planet_minimap.modulate = Color(1, 1, 1, 1)

    var zoom_tween = create_tween()
    zoom_tween.set_ease(Tween.EASE_OUT)
    zoom_tween.set_trans(Tween.TRANS_CUBIC)
    zoom_tween.tween_property(planet_minimap, "scale", Vector2.ONE, ZOOM_DURATION)

    call_deferred("_position_card_and_map")

func _position_card_and_map():
    await get_tree().process_frame
    await get_tree().process_frame

    var vp = get_viewport_rect().size
    var card_size = center_container.size

    var total_w = card_size.x + MAP_GAP + END_MAP_SIZE
    var start_x = (vp.x - total_w) * 0.5

    center_container.position = Vector2(
        maxf(20, start_x), 
        (vp.y - card_size.y) * 0.5
    )

    var map_x = center_container.position.x + card_size.x + MAP_GAP
    var map_y = (vp.y - END_MAP_SIZE) * 0.5
    var map_end_pos = Vector2(map_x, map_y)

    var map_tween = create_tween()
    map_tween.set_ease(Tween.EASE_OUT)
    map_tween.set_trans(Tween.TRANS_CUBIC)
    map_tween.tween_property(planet_minimap, "position", map_end_pos, 0.4)

    var card_tween = create_tween()
    card_tween.set_ease(Tween.EASE_OUT)
    card_tween.set_trans(Tween.TRANS_CUBIC)
    card_tween.tween_property(center_container, "modulate:a", 1.0, 0.3).set_delay(0.15)




func _on_upgrade():
    ScreenFX.transition_to("res://scenes/upgrade_menu.tscn")

func _on_continue():
    ScreenFX.transition_to("res://scenes/mining_scene.tscn")






func _is_spring_boss_dead() -> bool:
    if not Global.planet_data:
        return false
    for core in Global.planet_data.cores:
        if core.id == Global.DEMO_BOSS_CORE_ID:
            return not core.alive
    return false


func _show_demo_ending():

    var overlay = ColorRect.new()
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.color = Color(0.0, 0.0, 0.0, 0.85)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(overlay)
    overlay.modulate = Color(1, 1, 1, 0)
    var fade_tw = create_tween()
    fade_tw.tween_property(overlay, "modulate:a", 1.0, 0.5)


    var panel = PanelContainer.new()
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
    style.set_corner_radius_all(12)
    style.border_color = CYAN * 0.6
    style.set_border_width_all(2)
    panel.add_theme_stylebox_override("panel", style)
    overlay.add_child(panel)

    var margin = MarginContainer.new()
    margin.add_theme_constant_override("margin_top", 40)
    margin.add_theme_constant_override("margin_bottom", 40)
    margin.add_theme_constant_override("margin_left", 50)
    margin.add_theme_constant_override("margin_right", 50)
    panel.add_child(margin)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 20)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    margin.add_child(vbox)


    var title = _make_label(tr("DEMO_END_TITLE"), 28, CYAN)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)


    var msg = Label.new()
    msg.text = tr("DEMO_END_MSG")
    msg.add_theme_font_size_override("font_size", 16)
    msg.add_theme_color_override("font_color", WHITE)
    msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    msg.custom_minimum_size = Vector2(500, 0)
    vbox.add_child(msg)


    var wish = _make_label(tr("DEMO_END_WISHLIST"), 14, GOLD)
    wish.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(wish)


    var menu_btn = _make_button(tr("DEMO_END_MENU"))
    menu_btn.pressed.connect( func():
        ScreenFX.transition_to("res://scenes/main_menu.tscn")
    )
    var btn_center = HBoxContainer.new()
    btn_center.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_center.add_child(menu_btn)
    vbox.add_child(btn_center)


    await get_tree().process_frame
    var vp = get_viewport_rect().size
    var ps = panel.size
    panel.position = (vp - ps) * 0.5




func _show_epilogue():
    await get_tree().create_timer(1.5).timeout


    var overlay = ColorRect.new()
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.color = Color(0.0, 0.0, 0.0, 0.0)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.z_index = 50
    add_child(overlay)

    var fade_tw = create_tween()
    fade_tw.tween_property(overlay, "color:a", 0.95, 1.0)
    await fade_tw.finished

    var vp = get_viewport_rect().size


    var snapshots = Global.planet_snapshots
    if snapshots.size() > 0:

        var sortie_lbl = Label.new()
        sortie_lbl.add_theme_font_size_override("font_size", 16)
        sortie_lbl.add_theme_color_override("font_color", DIM)
        sortie_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        sortie_lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
        sortie_lbl.offset_top = 40
        sortie_lbl.offset_left = -200
        sortie_lbl.offset_right = 200
        sortie_lbl.z_index = 51
        overlay.add_child(sortie_lbl)


        var planet_img = TextureRect.new()
        planet_img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
        planet_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        planet_img.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        var display_size = min(vp.x, vp.y) * 0.55
        planet_img.size = Vector2(display_size, display_size)
        planet_img.position = (vp - Vector2(display_size, display_size)) * 0.5
        planet_img.z_index = 51
        overlay.add_child(planet_img)


        var interval = clampf(5.0 / float(snapshots.size()), 0.15, 0.5)
        for i in range(snapshots.size()):
            var img = Image.new()
            img.load_png_from_buffer(snapshots[i])
            planet_img.texture = ImageTexture.create_from_image(img)
            sortie_lbl.text = "Sortie #%d / %d" % [i + 1, snapshots.size()]
            await get_tree().create_timer(interval).timeout


        await get_tree().create_timer(1.0).timeout


        var out_tw = create_tween()
        out_tw.set_parallel(true)
        out_tw.tween_property(planet_img, "modulate:a", 0.0, 0.8)
        out_tw.tween_property(sortie_lbl, "modulate:a", 0.0, 0.8)
        await out_tw.finished
        planet_img.queue_free()
        sortie_lbl.queue_free()
    else:

        await get_tree().create_timer(1.0).timeout


    var panel = PanelContainer.new()
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.04, 0.04, 0.08, 0.95)
    style.set_corner_radius_all(16)
    style.border_color = Color(1.0, 0.85, 0.2, 0.6)
    style.set_border_width_all(2)
    panel.add_theme_stylebox_override("panel", style)
    overlay.add_child(panel)

    var margin = MarginContainer.new()
    margin.add_theme_constant_override("margin_top", 30)
    margin.add_theme_constant_override("margin_bottom", 30)
    margin.add_theme_constant_override("margin_left", 50)
    margin.add_theme_constant_override("margin_right", 50)
    panel.add_child(margin)

    var vbox2 = VBoxContainer.new()
    vbox2.add_theme_constant_override("separation", 16)
    vbox2.alignment = BoxContainer.ALIGNMENT_CENTER
    margin.add_child(vbox2)


    var clear_lbl = _make_label("100%% Clear", 36, GOLD)
    clear_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox2.add_child(clear_lbl)

    var thanks = _make_label(tr("EPILOGUE_THANKS"), 20, WHITE)
    thanks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox2.add_child(thanks)

    var sep = HSeparator.new()
    sep.add_theme_stylebox_override("separator", StyleBoxLine.new())
    vbox2.add_child(sep)


    var time_min = int(Global.total_play_time) / 60
    var time_sec = int(Global.total_play_time) % 60
    var stat_text = "%s: %d\n%s: %02d:%02d\n%s: %d\n%s: %s" % [
        tr("EPILOGUE_SORTIES"), Global.sortie_count, 
        tr("EPILOGUE_TIME"), time_min, time_sec, 
        tr("EPILOGUE_CORES"), Global.total_cores_destroyed, 
        tr("EPILOGUE_RESOURCES"), _format_number(Global.total_resources)
    ]
    var stat_lbl = Label.new()
    stat_lbl.text = stat_text
    stat_lbl.add_theme_font_size_override("font_size", 16)
    stat_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
    stat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox2.add_child(stat_lbl)


    var credit_lbl = _make_label("Developed by vibemaker1", 14, DIM)
    credit_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox2.add_child(credit_lbl)


    var cont_btn = _make_button(tr("ENDING_CONTINUE"))
    cont_btn.pressed.connect( func():
        Global.epilogue_shown = true
        Global.save_game()
        ScreenFX.transition_to("res://scenes/upgrade_menu.tscn")
    )
    var btn_c = HBoxContainer.new()
    btn_c.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_c.add_child(cont_btn)
    vbox2.add_child(btn_c)


    panel.modulate = Color(1, 1, 1, 0)
    await get_tree().process_frame
    var vp2 = get_viewport_rect().size
    var ps2 = panel.size
    panel.position = (vp2 - ps2) * 0.5
    var panel_tw = create_tween()
    panel_tw.tween_property(panel, "modulate:a", 1.0, 0.8)

func _format_number(n: float) -> String:
    if n >= 1000000000:
        return "%.1fB" % (n / 1000000000.0)
    elif n >= 1000000:
        return "%.1fM" % (n / 1000000.0)
    elif n >= 1000:
        return "%.1fK" % (n / 1000.0)
    else:
        return str(int(n))
