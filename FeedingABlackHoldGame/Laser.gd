extends Line2D
class_name Laser

var base_width = 300
var calc_width = 300

var enable = false

var damage = 0
var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var is_crit = false

var damage_width = 0

var tween

func setup(_scaled_damage, _laser_width_scale, _laser_crit_chance, _laser_crit_bonus, _color):
    damage = _scaled_damage

    var direction_to_center = global_position.normalized().rotated(deg_to_rad((Global.rng.randi_range(10, 45))))



    var target_pos = global_position + direction_to_center * get_viewport_rect().size.x * Util.get_zoom_factor()

    if tween:
        tween.kill()

    start_pos = target_pos
    end_pos = - target_pos
    calc_width = base_width * _laser_width_scale



    is_crit = Global.rng.randf() < _laser_crit_chance
    if is_crit:
        damage *= _laser_crit_bonus

    if is_crit:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_LASER_CRIT)
    else:
        AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.ON_LASER)

    show()

    clear_points()
    add_point(start_pos)
    add_point(end_pos)

    enable = true



    modulate.a = 1.0

    default_color = _color
    width = 0

    tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(self, "width", calc_width * 0.1, 0.15)
    tween.tween_interval(0.1)
    tween.tween_callback( func():
        width = calc_width
        deal_damage()
        )
    tween.tween_interval(0.1)
    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    tween.tween_callback( func(): clean_up())





func deal_damage():
    Global.main.camera_2d.add_trauma(0.25)
    var all_objects = Global.main.object_manager.get_all_active_objects(false)
    var hit_objects = Global.main.object_manager.get_objects_in_laser(all_objects, to_global(start_pos), to_global(end_pos), width)
    for object: SpaceObject in hit_objects:
        if object.special_type == null:
            var damage_event_data = object.take_damage(damage, object.global_position, is_crit)
            Global.session_stats.laser_damage += damage_event_data.damage

func clean_up():
    hide()
    if enable:
        enable = false
        FlairManager.laser_pool.append(self)
