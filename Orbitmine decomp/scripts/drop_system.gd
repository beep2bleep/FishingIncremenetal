extends Node





var ship: CharacterBody2D


const RESOURCE_DROP_SCRIPT = preload("res://scripts/resource_drop.gd")
const MINING_PARTICLE_SCRIPT = preload("res://scripts/mining_particle.gd")
const CRASH_EXPLOSION_SCRIPT = preload("res://scripts/crash_explosion.gd")


const BLOCK_COLORS = {
    1: Color(0.15, 0.55, 0.7), 
    2: Color(0.2, 0.55, 0.65), 
    3: Color(0.3, 0.55, 0.55), 
    4: Color(0.4, 0.55, 0.4), 
    5: Color(0.55, 0.5, 0.25), 
    6: Color(0.65, 0.4, 0.15), 
    7: Color(0.7, 0.35, 0.1), 
    8: Color(0.75, 0.25, 0.08), 
    9: Color(0.8, 0.15, 0.05), 
    10: Color(0.85, 0.08, 0.03), 
}


const CORE_PARTICLE_COLOR: = Color(1.0, 0.3, 0.08)
const ELECTRIC_PARTICLE_COLOR: = Color(0.3, 0.8, 1.0)
const GOLD_PARTICLE_COLOR: = Color(1.0, 0.85, 0.2)
const CRIT_FLASH: = Color(1.0, 1.0, 0.3, 0.6)


const DROP_COLOR_NORMAL: = Color(1.0, 0.85, 0.5)
const DROP_COLOR_ELECTRIC: = Color(0.4, 0.9, 1.0)
const DROP_COLOR_GOLD: = Color(1.0, 0.9, 0.2)
const DROP_COLOR_CORE: = Color(1.0, 0.4, 0.15)


const MAX_RESOURCE_DROPS: int = 80
const MAX_PARTICLES: int = 25


const CRASH_FLASH_COLOR: = Color(3.0, 2.5, 1.5)
const CRASH_DEBRIS_COLOR: = Color(0.4, 1.5, 2.0)
const CRASH_FIRE_COLOR: = Color(2.0, 0.6, 0.15)
const CRASH_SMOKE_COLOR: = Color(0.4, 0.35, 0.3, 0.6)
const CRASH_PARTICLE_COUNT: int = 24
const CRASH_FLASH_RADIUS: float = 80.0


const POPUP_MAX: int = 10
const POPUP_MERGE_DIST: float = 150.0
const POPUP_STYLES = {
    "normal": {"suffix": "", "font_size": 13, "color": Color(1.0, 0.85, 0.3, 1.0), "rise": 30.0, "duration": 0.6}, 
    "gold": {"suffix": " ★", "font_size": 17, "color": Color(1.0, 0.9, 0.3, 1.0), "rise": 40.0, "duration": 0.7}, 
    "core": {"suffix": " ◉", "font_size": 19, "color": Color(1.0, 0.35, 0.2, 1.0), "rise": 45.0, "duration": 0.8}, 
}


var shield_hit_cooldown: float = 0.0




func _ready():
    ship = get_parent()




func enforce_particle_limit():
    var dynamic_max = MAX_PARTICLES + int(ship.get_visual_power() * 10)
    var particles = get_tree().get_nodes_in_group("mining_particles")
    while particles.size() > dynamic_max:
        particles[0].queue_free()
        particles.remove_at(0)






func spawn_popup(world_pos: Vector2, amount: float, type: String = "normal"):
    var style = POPUP_STYLES[type]


    var popups = get_tree().get_nodes_in_group("resource_popups")
    for popup in popups:
        if not is_instance_valid(popup):
            continue
        if popup.has_meta("popup_type") and popup.get_meta("popup_type") == type:
            var dist = popup.position.distance_to(world_pos)
            if dist < POPUP_MERGE_DIST:
                var accumulated = popup.get_meta("popup_amount") + amount
                popup.set_meta("popup_amount", accumulated)
                popup.text = "+%s%s" % [Global.format_number(accumulated), style.suffix]
                return


    if popups.size() >= POPUP_MAX:
        for p in popups:
            if is_instance_valid(p):
                p.queue_free()
                break


    var label = Label.new()
    label.add_to_group("resource_popups")
    label.set_meta("popup_type", type)
    label.set_meta("popup_amount", amount)
    label.text = "+%s%s" % [Global.format_number(amount), style.suffix]
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.position = world_pos + Vector2(randf_range(-6, 6), -10)
    label.z_index = 100
    label.add_theme_font_size_override("font_size", style.font_size)
    label.add_theme_color_override("font_color", style.color)

    label.add_theme_constant_override("outline_size", 3)
    label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))

    ship.get_parent().add_child(label)

    var dur = style.duration
    var tween = label.create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", label.position.y - style.rise, dur)
    tween.tween_property(label, "modulate:a", 0.0, dur).set_delay(dur * 0.3)
    tween.set_parallel(false)
    tween.tween_callback(label.queue_free)


func spawn_resource_popup(world_pos: Vector2, amount: float):
    spawn_popup(world_pos, amount, "normal")

func spawn_gold_popup(world_pos: Vector2, amount: float):
    spawn_popup(world_pos, amount, "gold")

func spawn_core_popup(world_pos: Vector2, amount: float):
    spawn_popup(world_pos, amount, "core")





func spawn_resource_drop(world_pos: Vector2, raw_resource: float, block_type: int):
    if raw_resource <= 0:
        return


    if Global.instant_collect:
        SoundManager.play("resource_pickup")
        var scene = ship.get_parent()
        var is_core_drop = block_type == PlanetData.BlockType.CORE
        var is_gold_drop = block_type == PlanetData.BlockType.GOLD
        if scene.has_method("add_resources"):
            scene.add_resources(raw_resource, is_core_drop)
        var combo_add = Global.combo_flat_per_stack * Global.combo_count if Global.combo_unlocked else 0.0

        var gold_extra = Global.gold_bonus_flat if (is_gold_drop or is_core_drop) else 0.0
        var actual = (raw_resource + Global.mining_resource_flat + gold_extra + combo_add) * Global.mining_season_res_mult
        if is_gold_drop:
            spawn_gold_popup(world_pos, actual)
        elif is_core_drop:
            spawn_core_popup(world_pos, actual)
        else:
            spawn_resource_popup(world_pos, actual)
        return


    var drops = get_tree().get_nodes_in_group("resource_drops")
    if drops.size() >= MAX_RESOURCE_DROPS:
        drops[0].queue_free()


    var color = DROP_COLOR_NORMAL
    var is_gold_drop = false
    var is_core_drop = false
    match block_type:
        PlanetData.BlockType.ELECTRIC:
            color = DROP_COLOR_NORMAL
        PlanetData.BlockType.GOLD:
            color = DROP_COLOR_GOLD
            is_gold_drop = true
        PlanetData.BlockType.CORE:
            color = DROP_COLOR_CORE
            is_core_drop = true

    var drop = Node2D.new()
    drop.set_script(RESOURCE_DROP_SCRIPT)
    ship.get_parent().add_child(drop)
    drop.setup(world_pos, raw_resource, color, is_gold_drop, is_core_drop)


func collect_nearby_drops():
    var drops = get_tree().get_nodes_in_group("resource_drops")
    var range_sq = Global.pickup_range * Global.pickup_range
    var scene = ship.get_parent()

    for drop in drops:
        if not is_instance_valid(drop):
            continue
        var dist_sq = ship.global_position.distance_squared_to(drop.global_position)
        if dist_sq <= range_sq:
            var raw = drop.collect(ship)
            if raw > 0:
                SoundManager.play("resource_pickup")
                if scene.has_method("add_resources"):
                    scene.add_resources(raw, drop.is_core)
                var combo_add = Global.combo_flat_per_stack * Global.combo_count if Global.combo_unlocked else 0.0

                var gold_extra = Global.gold_bonus_flat if (drop.is_gold or drop.is_core) else 0.0
                var actual = (raw + Global.mining_resource_flat + gold_extra + combo_add) * Global.mining_season_res_mult
                if drop.is_gold:
                    spawn_gold_popup(drop.global_position, actual)
                elif drop.is_core:
                    spawn_core_popup(drop.global_position, actual)
                else:
                    spawn_resource_popup(drop.global_position, actual)






func spawn_destroy_particles(world_pos: Vector2, grid_pos: Vector2i, is_core: bool):
    enforce_particle_limit()
    var particle = Node2D.new()
    particle.set_script(MINING_PARTICLE_SCRIPT)
    ship.get_parent().add_child(particle)

    var color: Color
    var count: int
    if is_core:
        color = CORE_PARTICLE_COLOR
        count = 12
    else:
        var dist = sqrt(grid_pos.x * grid_pos.x + grid_pos.y * grid_pos.y)
        var idx = _hp_to_color_index_from_dist(dist)
        color = BLOCK_COLORS.get(idx, BLOCK_COLORS[1])
        count = ship.get_particle_count()

    var show_ring = ship.get_visual_power() < 0.7 or randf() < 0.3
    particle.setup(world_pos, color, count, show_ring)


func spawn_core_explosion(world_pos: Vector2, _grid_pos: Vector2i):
    var bs = PlanetData.BLOCK_SIZE
    for dx in range(-2, 2):
        for dy in range(-2, 2):
            var offset_pos = Vector2(
                world_pos.x + dx * bs, 
                world_pos.y + dy * bs
            )
            var particle = Node2D.new()
            particle.set_script(MINING_PARTICLE_SCRIPT)
            ship.get_parent().add_child(particle)
            particle.setup(offset_pos, CORE_PARTICLE_COLOR, 4, false)

    var flash = Node2D.new()
    flash.position = world_pos
    flash.z_index = 100
    ship.get_parent().add_child(flash)

    var tween = flash.create_tween()
    tween.tween_property(flash, "modulate:a", 0.0, 0.4)
    tween.tween_callback(flash.queue_free)


func spawn_electric_particles(world_pos: Vector2):
    enforce_particle_limit()
    var particle = Node2D.new()
    particle.set_script(MINING_PARTICLE_SCRIPT)
    ship.get_parent().add_child(particle)
    particle.setup(world_pos, ELECTRIC_PARTICLE_COLOR, 8)


func spawn_chain_destroy_particle(world_pos: Vector2):
    enforce_particle_limit()
    var particle = Node2D.new()
    particle.set_script(MINING_PARTICLE_SCRIPT)
    ship.get_parent().add_child(particle)
    particle.setup(world_pos, ELECTRIC_PARTICLE_COLOR, 4, false)


func spawn_gold_particles(world_pos: Vector2):
    enforce_particle_limit()
    var particle = Node2D.new()
    particle.set_script(MINING_PARTICLE_SCRIPT)
    ship.get_parent().add_child(particle)
    particle.setup(world_pos, GOLD_PARTICLE_COLOR, 8)


func spawn_crit_effect(world_pos: Vector2):
    enforce_particle_limit()
    var particle = Node2D.new()
    particle.set_script(MINING_PARTICLE_SCRIPT)
    ship.get_parent().add_child(particle)
    particle.setup(world_pos, CRIT_FLASH, 6)


func spawn_crash_explosion():
    var scene = ship.get_parent()
    var pos = ship.global_position


    var debris = Node2D.new()
    debris.set_script(MINING_PARTICLE_SCRIPT)
    scene.add_child(debris)
    debris.setup(pos, CRASH_DEBRIS_COLOR, 16)


    var fire = Node2D.new()
    fire.set_script(MINING_PARTICLE_SCRIPT)
    scene.add_child(fire)
    fire.setup(pos, CRASH_FIRE_COLOR, 12)


    var smoke = Node2D.new()
    smoke.set_script(MINING_PARTICLE_SCRIPT)
    scene.add_child(smoke)
    smoke.setup(pos, CRASH_SMOKE_COLOR, 8)


    var flash = Node2D.new()
    flash.set_script(CRASH_EXPLOSION_SCRIPT)
    flash.z_index = 100
    scene.add_child(flash)
    flash.setup(pos, CRASH_FLASH_RADIUS)





func on_shield_hit(world_pos: Vector2):
    if shield_hit_cooldown > 0:
        return
    shield_hit_cooldown = 0.3

    var label = Label.new()
    label.text = "🔒"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.position = world_pos + Vector2(0, -12)
    label.z_index = 100
    label.add_theme_font_size_override("font_size", 16)
    ship.get_parent().add_child(label)

    var tween = label.create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", label.position.y - 25, 0.4)
    tween.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.1)
    tween.set_parallel(false)
    tween.tween_callback(label.queue_free)


func update_cooldown(delta: float):
    if shield_hit_cooldown > 0:
        shield_hit_cooldown -= delta






func _hp_to_color_index_from_dist(dist: float) -> int:
    var depth_ratio = 1.0 - (dist / PlanetData.PLANET_RADIUS)
    var hp = 4.0 * pow(10.0, depth_ratio * 10.1)
    if hp <= 10:
        return 1
    var log_val = log(hp) / log(10.0)
    return clampi(int(log_val), 1, 10)
