extends Control
class_name FloatingText

const MONEY_UPDATE_INTERVAL := 0.1
const MONEY_PHASE_INTERVAL := MONEY_UPDATE_INTERVAL * 0.5

static var next_money_phase := 0

var duration = 0.5
var value = 0
var type: Util.FLOATING_TEXT_TYPES
var enable = false
var base_shadow_size = 5
var base_shadow_offset_y = 1
var money_anim_active := false
var money_wait_time := 0.1
var money_elapsed := 0.0
var money_update_timer := 0.0
var money_phase := 0


func setup(_glob_pos: Vector2, _type: Util.FLOATING_TEXT_TYPES, _value, object_type: Util.OBJECT_TYPES):
    if tween:
        tween.kill()
        tween = null
    money_anim_active = false
    set_process(false)
    type = _type
    value = _value
    show()

    modulate.a = 1.0

    pivot_offset = size / 2.0
    scale = Vector2(0.2, 0.2)
    global_position = _glob_pos
    enable = true

    modulate.a = 0


    var scale_factor = sqrt(max(int(log(value) / log(10)) - 1, 0))

    var digit_count = max(int(log(value) / log(10)), 0)

    var game_zoom = (1.0 - Global.main.get_traget_camera_zoom().x) / 3.0 if Global.main else 0.0
    $Label.scale = (1.0 - game_zoom) * Vector2.ONE

    var font_size = 0

    match type:
        Util.FLOATING_TEXT_TYPES.DAMAGE_CLICK:
            z_index = 2 + digit_count
            font_size = (20 + digit_count)

            $Label.add_theme_color_override("font_color", Refs.pallet.damage_text_color)
            $Label.add_theme_font_override("font", Refs.damage_font)
            $Label.text = Util.get_number_short_text(value, true, false)
            create_damage_tween()
        Util.FLOATING_TEXT_TYPES.DAMAGE_CRIT:
            z_index = 3 + digit_count
            font_size = (28 + digit_count)

            $Label.add_theme_color_override("font_color", Refs.pallet.damage_crit_color)
            $Label.add_theme_font_override("font", Refs.damage_crit_font)
            $Label.text = Util.get_number_short_text(value, true, false)
            create_damage_crit_tween()
        Util.FLOATING_TEXT_TYPES.MONEY, Util.FLOATING_TEXT_TYPES.GOLDEN_MONEY:

            $Label.text = str("$", Util.get_number_short_text(value, true, false))

            var wait_time = 0.1
            if type == Util.FLOATING_TEXT_TYPES.GOLDEN_MONEY:
                z_index = 4 + digit_count
                font_size = (28 + digit_count)
                wait_time = 0.2

                $Label.add_theme_font_override("font", Refs.godlen_font)
                $Label.add_theme_color_override("font_color", Refs.pallet.golden_color)
            else:
                z_index = 3 + digit_count
                font_size = (20 + digit_count)

                $Label.add_theme_font_override("font", Refs.money_font)
                $Label.add_theme_color_override("font_color", Refs.pallet.money_color)

            match object_type:
                Util.OBJECT_TYPES.ASTEROID:
                    pass
                Util.OBJECT_TYPES.PLANET:
                    font_size *= 1.25
                Util.OBJECT_TYPES.STAR:
                    font_size *= 2.0

            create_money_animation(wait_time)
    font_size *= SaveHandler.text_scale
    $Label.add_theme_font_size_override("font_size", font_size)

var tween

func create_damage_tween():
    var to_position = Vector2(Global.rng.randi_range(-22, 22), - Global.rng.randi_range(32, 36))
    tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
    tween.tween_property(self, "global_position", global_position + to_position, 0.4)
    tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)
    tween.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
    tween.chain().tween_property(self, "scale", Vector2(1, 1), 0.05)
    tween.tween_interval(0.1)
    tween.tween_property(self, "modulate:a", 0.0, 0.33)
    tween.tween_callback(clean_up)

func create_damage_crit_tween():
    var to_position = Vector2(Global.rng.randi_range(-22, 22), - Global.rng.randi_range(32, 36))
    tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
    tween.tween_property(self, "global_position", global_position + to_position, 0.4)
    tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)
    tween.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
    tween.chain().tween_property(self, "scale", Vector2(1, 1), 0.05)
    tween.tween_interval(0.2)
    tween.tween_property(self, "modulate:a", 0.0, 0.33)
    tween.tween_callback(clean_up)



func create_money_tween(wait_time = 0.1):
    tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
    tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)
    tween.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
    tween.chain().tween_property(self, "scale", Vector2(1, 1), 0.05)

    tween.tween_interval(wait_time)
    tween.tween_property(self, "modulate:a", 0.0, 0.33)
    tween.tween_callback(clean_up)

func create_money_animation(wait_time = 0.1):
    money_anim_active = true
    money_wait_time = wait_time
    money_elapsed = 0.0
    money_phase = next_money_phase
    next_money_phase = (next_money_phase + 1) % 2
    money_update_timer = MONEY_PHASE_INTERVAL * float(money_phase)
    scale = Vector2(0.2, 0.2)
    modulate.a = 0.0
    set_process(true)

func _process(delta: float) -> void:
    if not money_anim_active:
        return
    money_update_timer -= delta
    if money_update_timer > 0.0:
        return
    while money_update_timer <= 0.0:
        money_update_timer += MONEY_UPDATE_INTERVAL
    money_elapsed += MONEY_UPDATE_INTERVAL

    var fade_in_end: float = 0.2
    var scale_peak_end: float = 0.4
    var settle_end: float = 0.45
    var fade_out_start: float = settle_end + money_wait_time
    var fade_out_duration: float = 0.33
    var total_duration: float = fade_out_start + fade_out_duration

    if money_elapsed <= scale_peak_end:
        var grow_t: float = clampf(money_elapsed / scale_peak_end, 0.0, 1.0)
        scale = Vector2(0.2, 0.2).lerp(Vector2(1.1, 1.1), grow_t)
    elif money_elapsed <= settle_end:
        var settle_t: float = clampf((money_elapsed - scale_peak_end) / maxf(0.001, settle_end - scale_peak_end), 0.0, 1.0)
        scale = Vector2(1.1, 1.1).lerp(Vector2(1.0, 1.0), settle_t)
    else:
        scale = Vector2.ONE

    if money_elapsed <= fade_in_end:
        modulate.a = clampf(money_elapsed / fade_in_end, 0.0, 1.0)
    elif money_elapsed < fade_out_start:
        modulate.a = 1.0
    else:
        var fade_t: float = clampf((money_elapsed - fade_out_start) / fade_out_duration, 0.0, 1.0)
        modulate.a = 1.0 - fade_t

    if money_elapsed >= total_duration:
        clean_up()

func clean_up():
    if tween:
        tween.kill()
        tween = null
    money_anim_active = false
    set_process(false)

    hide()
    if enable == true:
        enable = false
        FlairManager.text_pool.append(self)
