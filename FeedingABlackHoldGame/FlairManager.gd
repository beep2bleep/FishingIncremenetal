extends Node2D

@export_group("Controls")


@export var disable_destroyed_particles: bool = false


@export_group("Other Stuff")
@export var object_destroyed_parts_packed: PackedScene
@export var shockwave_packed: PackedScene
@export var floating_text_packed: PackedScene
@export var explosion_packed: PackedScene
@export var electric_packed: PackedScene
@export var radioactive_packed: PackedScene
@export var moon_packed: PackedScene
@export var frozen_shard_packed: PackedScene
@export var laser_packed: PackedScene
@export var supernova_packed: PackedScene
@export var fireball_packed: PackedScene

@export var enable_damage_text: bool = false


@export var destroyed_parts_pool = []
@export var shockwave_pool = []
@export var electric_pool = []
@export var radioactive_pool = []
@export var moon_pool = []
@export var text_pool = []
@export var frozen_shard_pool = []
@export var laser_pool = []
@export var supernova_pool = []
@export var fireball_pool = []


var pre_warm_destroyed_parts = 100
var pre_warm_shockwaves = 10
var pre_warm_electric = 20
var pre_warm_radioactive = 0
var pre_warm_moon = 20
var pre_warm_floating_text = 500
var pre_warm_forzen_shard = 0
var pre_warm_laser = 20
var pre_warm_supernova = 20
var pre_warm_fireballs = 20


@export_group("Dynamic Pool Growth")
@export var enable_dynamic_growth: bool = true
@export var growth_threshold_percent: float = 0.1
@export var growth_amount: int = 10
@export var max_pool_size: int = 500


@export_group("Electric Effect Queue")
@export var max_electric_per_frame: int = 1
var electric_queue: Array = []


var growth_queue: Array = []
var prewarming_complete: bool = false


var pool_capacities = {
    "destroyed_parts": pre_warm_destroyed_parts, 
    "shockwave": pre_warm_shockwaves, 
    "electric": pre_warm_electric, 
    "radioactive": pre_warm_radioactive, 
    "moon": pre_warm_moon, 
    "text": pre_warm_floating_text, 
    "frozen_shard": pre_warm_forzen_shard, 
    "laser": pre_warm_laser, 
    "supernova": pre_warm_supernova, 
    "fireball": pre_warm_fireballs
}

var asteroid_electric_damage
var asteroid_electric_max_chains
var asteroid_electric_chain_distance
var asteroid_electric_chance_to_fork
var asteroid_electric_crit_chance
var asteroid_electric_crit_bonus

var star_electric_damage
var star_electric_max_chains
var star_electric_chain_distance
var star_electric_chance_to_fork
var star_electric_crit_chance
var star_electric_crit_bonus

var radioactive_dot
var radioactive_duration
var radioactive_scale

var moon_buff_duration
var moon_aoe_buff_scale
var moon_rate_buff_scale

var frozen_shard_damage
var frozen_shard_amount
var frozen_shard_distance_scale

var laser_damage
var laser_width_scale
var laser_crit_chance
var laser_crit_bonus

var supernova_percent_current_health
var supernova_radius_scale

var moon_limit_hard_cap
var current_active_moons = 0:
    set(new_value):
        current_active_moons = max(0, new_value)

var fireball_damage
var fireball_max_chains
var fireball_chain_distance_scale

func _ready():
    SignalBus.game_state_changed.connect(_on_game_state_changed)
    SignalBus.mod_changed.connect(_on_mod_changed)


    pool_capacities["destroyed_parts"] = pre_warm_destroyed_parts
    pool_capacities["shockwaves"] = pre_warm_shockwaves
    pool_capacities["electric"] = pre_warm_electric
    pool_capacities["radioactive"] = pre_warm_radioactive
    pool_capacities["moon"] = pre_warm_moon
    pool_capacities["text"] = pre_warm_floating_text
    pool_capacities["frozen_shard"] = pre_warm_forzen_shard
    pool_capacities["laser"] = pre_warm_laser
    pool_capacities["supernova"] = pre_warm_supernova
    pool_capacities["fireball"] = pre_warm_fireballs

func _on_mod_changed(type: Util.MODS, old_value, new_value):
    setup_mods()

func setup_mods():
    asteroid_electric_damage = Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_ELECTRIC_DAMAGE)
    asteroid_electric_max_chains = Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_ELECTRIC_MAX_CHAINS)
    asteroid_electric_chain_distance = 200 * Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_CHAIN_DISTANCE_SCALE)
    asteroid_electric_chance_to_fork = Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_CHANCE_TO_FORK)
    asteroid_electric_crit_chance = Global.mods.get_mod(Util.MODS.ELECTRIC_CRIT_CHANCE)
    asteroid_electric_crit_bonus = Global.mods.get_mod(Util.MODS.ELECTRIC_CRIT_BONUS)

    star_electric_damage = Global.mods.get_mod(Util.MODS.SPECIAL_STAR_ELECTRIC_DAMAGE)
    star_electric_max_chains = Global.mods.get_mod(Util.MODS.SPECIAL_STAR_ELECTRIC_MAX_CHAINS)
    star_electric_chain_distance = 200 * Global.mods.get_mod(Util.MODS.SPECIAL_STAR_CHAIN_DISTANCE_SCALE)
    star_electric_chance_to_fork = Global.mods.get_mod(Util.MODS.SPECIAL_STAR_CHANCE_TO_FORK)
    star_electric_crit_chance = Global.mods.get_mod(Util.MODS.SPECIAL_STAR_ELECTRIC_CRIT_CHANCE)
    star_electric_crit_bonus = Global.mods.get_mod(Util.MODS.SPECIAL_STAR_ELECTRIC_CRIT_BONUS)

    radioactive_dot = Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_RADIOACTIVE_DOT)
    radioactive_duration = Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_RADIOACTIVE_DURATION)
    radioactive_scale = Global.mods.get_mod(Util.MODS.SPECIAL_ASTEROID_RADIOACTIVE_AOE_SCALE)

    moon_buff_duration = Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_MOON_BUFF_DURATION)
    moon_rate_buff_scale = Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_MOON_CLIKCER_RATE_BUFF_SCALE)
    moon_aoe_buff_scale = Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_MOON_CLIKCER_AOE_BUFF_SCALE)

    frozen_shard_damage = Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_FROZEN_SHARD_MAX_DAMAGE)
    frozen_shard_amount = Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_FROZEN_SHARD_AMOUNT)
    frozen_shard_distance_scale = Global.mods.get_mod(Util.MODS.SPECIAL_PLANET_FROZEN_SHARD_DISTANCE_SCALE)

    laser_damage = Global.mods.get_mod(Util.MODS.LASER_DAMAGE)
    laser_width_scale = Global.mods.get_mod(Util.MODS.LASER_WIDTH_SCALE)
    laser_crit_chance = Global.mods.get_mod(Util.MODS.LASER_CRIT_CHANCE)
    laser_crit_bonus = Global.mods.get_mod(Util.MODS.LASER_CRIT_BONUS)

    supernova_percent_current_health = Global.mods.get_mod(Util.MODS.SUPERNOVA_DAMAGE_PERCENT_CURRENT_HEALTH)
    supernova_radius_scale = Global.mods.get_mod(Util.MODS.SUPERNOVA_RADIUS_SCALE)

    moon_limit_hard_cap = Global.mods.get_mod(Util.MODS.MOON_LIMIT_HARD_CAP)

    fireball_damage = Global.mods.get_mod(Util.MODS.FIREBALL_DAMAGE)
    fireball_max_chains = Global.mods.get_mod(Util.MODS.FIREBALL_MAX_CHAINS)
    fireball_chain_distance_scale = Global.mods.get_mod(Util.MODS.FIREBALL_CHAIN_DISTANCE_SCALE)

func _process(delta: float) -> void :
    var still_working = false


    if not prewarming_complete:
        if pre_warm_destroyed_parts > 0:
            pre_warm_destroyed_parts -= 1
            _prewarm(object_destroyed_parts_packed, destroyed_parts_pool)
            still_working = true

        if pre_warm_floating_text > 0:
            pre_warm_floating_text -= 1
            _prewarm(floating_text_packed, text_pool)
            still_working = true

        if pre_warm_shockwaves > 0:
            pre_warm_shockwaves -= 1
            _prewarm(shockwave_packed, shockwave_pool)
            still_working = true

        if pre_warm_electric > 0:
            pre_warm_electric -= 1
            _prewarm(electric_packed, electric_pool)
            still_working = true

        if pre_warm_radioactive > 0:
            pre_warm_radioactive -= 1
            _prewarm(radioactive_packed, radioactive_pool)
            still_working = true

        if pre_warm_moon > 0:
            pre_warm_moon -= 1
            _prewarm(moon_packed, moon_pool)
            still_working = true

        if pre_warm_forzen_shard > 0:
            pre_warm_forzen_shard -= 1
            _prewarm(frozen_shard_packed, frozen_shard_pool)
            still_working = true

        if pre_warm_laser > 0:
            pre_warm_laser -= 1
            _prewarm(laser_packed, laser_pool)
            still_working = true

        if pre_warm_supernova > 0:
            pre_warm_supernova -= 1
            _prewarm(supernova_packed, supernova_pool)
            still_working = true

        if pre_warm_fireballs > 0:
            pre_warm_fireballs -= 1
            _prewarm(fireball_packed, fireball_pool)
            still_working = true

        if not still_working:
            prewarming_complete = true


    if not electric_queue.is_empty():
        var effects_this_frame = min(max_electric_per_frame, electric_queue.size())
        for i in range(effects_this_frame):
            var queued = electric_queue.pop_front()
            _create_electric_immediate(queued.pos, queued.damage_scale, queued.object_type, queued.is_crit, queued.color)
        still_working = true


    if not growth_queue.is_empty():
        var growth_item = growth_queue.pop_front()
        _prewarm(growth_item.scene, growth_item.pool)
        still_working = true


    if not still_working:
        set_process(false)

func _prewarm(packed: PackedScene, pool: Array):
    var new_packed = packed.instantiate()

    if new_packed is FloatingText:
        %FloatingText.add_child(new_packed)
    else:
        add_child(new_packed)

    pool.append(new_packed)
    new_packed.hide()


func check_and_queue_growth(pool: Array, pool_name: String, scene: PackedScene):
    if not enable_dynamic_growth:
        return

    var capacity = pool_capacities[pool_name]
    var current_size = pool.size()
    var threshold = int(capacity * growth_threshold_percent)


    if current_size <= threshold and capacity < max_pool_size:
        var amount_to_grow = min(growth_amount, max_pool_size - capacity)


        for i in range(amount_to_grow):
            growth_queue.append({"scene": scene, "pool": pool})


        pool_capacities[pool_name] += amount_to_grow


        set_process(true)

        if OS.is_debug_build():
            print("Growing %s pool: %d -> %d (current: %d)" % [pool_name, capacity, pool_capacities[pool_name], current_size])

func _on_game_state_changed():
    match Global.game_state:
        Util.GAME_STATES.START_OF_SESSION:
            clean_up_flair()
        Util.GAME_STATES.PLAYING:
            pass
        Util.GAME_STATES.END_OF_SESSION:
            clean_up_flair()
        Util.GAME_STATES.UPGRADES:
            clean_up_flair()
        Util.GAME_STATES.END_OF_TEIR:
            clean_up_flair()
        Util.GAME_STATES.GAME_OVER:
            clean_up_flair()
        Util.GAME_STATES.MAIN_MENU:
            clean_up_flair()

func clean_up_flair():
    for child in get_children():
        if child != %FloatingText:
            child.clean_up()

    electric_queue = []

func create_particles_on_object_destoryed(glob_pos, color, cust_scale, radius):
    if disable_destroyed_particles:
        return

    check_and_queue_growth(destroyed_parts_pool, "destroyed_parts", object_destroyed_parts_packed)

    var new_parts
    if destroyed_parts_pool.is_empty():
        new_parts = object_destroyed_parts_packed.instantiate()
        add_child(new_parts)
        if OS.is_debug_build():
            print("Creating destroy parts (pool exhausted)")
    else:
        new_parts = destroyed_parts_pool.pop_back()

    new_parts.global_position = glob_pos
    new_parts.self_modulate = color
    new_parts.setup(cust_scale, radius)


func create_electric(glob_pos, damage_scale, object_type, is_crit, color):
    electric_queue.append({"pos": glob_pos, "damage_scale": damage_scale, "object_type": object_type, "is_crit": is_crit, "color": color})
    set_process(true)


func _create_electric_immediate(glob_pos, damage_scale, object_type, is_crit, color):
    check_and_queue_growth(electric_pool, "electric", electric_packed)

    var new_electric
    if electric_pool.is_empty():
        new_electric = electric_packed.instantiate()
        add_child(new_electric)
        if OS.is_debug_build():
            print("Creating electric (pool exhausted)")
    else:
        new_electric = electric_pool.pop_back()

    var scaled_damage = damage_scale * asteroid_electric_damage
    new_electric.global_position = glob_pos

    if object_type == Util.OBJECT_TYPES.ASTEROID:
        new_electric.setup(scaled_damage, asteroid_electric_max_chains, asteroid_electric_chain_distance, asteroid_electric_chance_to_fork, is_crit, asteroid_electric_crit_bonus, color, object_type)
    elif object_type == Util.OBJECT_TYPES.STAR:
        new_electric.setup(scaled_damage, star_electric_max_chains, star_electric_chain_distance, star_electric_chance_to_fork, is_crit, star_electric_crit_bonus, color, object_type)


func create_shockwave(duration, glob_pos):
    if SaveHandler.black_hole_pulse == false:
        return

    check_and_queue_growth(shockwave_pool, "shockwaves", shockwave_packed)

    var new_shockwave
    if shockwave_pool.is_empty():
        new_shockwave = shockwave_packed.instantiate()
        add_child(new_shockwave)
        if OS.is_debug_build():
            print("Creating new_shockwave (pool exhausted)")
    else:
        new_shockwave = shockwave_pool.pop_back()

    new_shockwave.setup(duration, glob_pos)

func create_radioactive(glob_pos, damage_scale):
    check_and_queue_growth(radioactive_pool, "radioactive", radioactive_packed)

    var new_radioactive
    if radioactive_pool.is_empty():
        new_radioactive = radioactive_packed.instantiate()
        add_child(new_radioactive)
        if OS.is_debug_build():
            print("Creating radioactive (pool exhausted)")
    else:
        new_radioactive = radioactive_pool.pop_back()

    var scaled_damage = damage_scale * radioactive_dot
    new_radioactive.global_position = glob_pos
    new_radioactive.setup(scaled_damage, radioactive_duration, radioactive_scale)

func has_moons():
    return current_active_moons < moon_limit_hard_cap and moon_pool.size() > 0

func get_moon():
    check_and_queue_growth(moon_pool, "moon", moon_packed)

    if has_moons():
        return moon_pool.pop_back()

func add_moon_to_clicker(moon: Moon):
    moon.setup(moon_buff_duration, moon_rate_buff_scale, moon_aoe_buff_scale)
    Global.main.clicker.add_object(moon)

func create_frozen_shards(glob_pos, damage_scale, _color):
    check_and_queue_growth(frozen_shard_pool, "frozen_shard", frozen_shard_packed)

    for i in range(frozen_shard_amount):
        var new_frozen_shard: FrozenShard
        if frozen_shard_pool.is_empty():
            new_frozen_shard = frozen_shard_packed.instantiate()
            add_child(new_frozen_shard)
            if OS.is_debug_build():
                print("Creating frozen shard (pool exhausted)")
        else:
            new_frozen_shard = frozen_shard_pool.pop_back()

        var scaled_damage = damage_scale * frozen_shard_damage
        new_frozen_shard.global_position = glob_pos
        new_frozen_shard.setup(scaled_damage, frozen_shard_distance_scale, _color)

func create_new_floating_text(_glob_pos: Vector2, value: int, _type: Util.FLOATING_TEXT_TYPES, object_type: Util.OBJECT_TYPES):
    match _type:
        Util.FLOATING_TEXT_TYPES.DAMAGE_CLICK, Util.FLOATING_TEXT_TYPES.DAMAGE_CRIT:
            if SaveHandler.damage_text == false:
                return
        Util.FLOATING_TEXT_TYPES.MONEY, Util.FLOATING_TEXT_TYPES.GOLDEN_MONEY:
            if SaveHandler.money_text == false:
                return

    check_and_queue_growth(text_pool, "text", floating_text_packed)

    var floating_text
    if text_pool.is_empty():
        floating_text = floating_text_packed.instantiate()
        %FloatingText.add_child(floating_text)
        if OS.is_debug_build():
            print("Creating floating text (pool exhausted)")
    else:
        floating_text = text_pool.pop_back()

    floating_text.setup(Util.get_glob_pos_viewport_position_relative_to_origin(_glob_pos, get_canvas_transform().origin, Global.main.camera_2d), _type, value, object_type)

func create_laser(glob_pos, damage_scale, _color):
    check_and_queue_growth(laser_pool, "laser", laser_packed)

    var new_laser
    if laser_pool.is_empty():
        new_laser = laser_packed.instantiate()
        add_child(new_laser)
        if OS.is_debug_build():
            print("Creating laser (pool exhausted)")
    else:
        new_laser = laser_pool.pop_back()

    var scaled_damage = damage_scale * laser_damage
    new_laser.global_position = glob_pos
    new_laser.setup(scaled_damage, laser_width_scale, laser_crit_chance, laser_crit_bonus, _color)

func create_supernova(glob_pos, _start_radius):
    check_and_queue_growth(supernova_pool, "supernova", supernova_packed)

    var new_supernova
    if supernova_pool.is_empty():
        new_supernova = supernova_packed.instantiate()
        add_child(new_supernova)
        if OS.is_debug_build():
            print("Creating solar flair (pool exhausted)")
    else:
        new_supernova = supernova_pool.pop_back()

    new_supernova.global_position = glob_pos
    new_supernova.setup(supernova_percent_current_health, supernova_radius_scale, _start_radius)

func create_fireball(glob_pos, damage_scale, delay = 0):
    check_and_queue_growth(fireball_pool, "fireball", fireball_packed)

    var new_fireball
    if fireball_pool.is_empty():
        new_fireball = fireball_packed.instantiate()
        add_child(new_fireball)
        if OS.is_debug_build():
            print("Creating fireball (pool exhausted)")
    else:
        new_fireball = fireball_pool.pop_back()

    var scaled_damage = damage_scale * fireball_damage
    new_fireball.global_position = glob_pos
    new_fireball.setup(scaled_damage, fireball_max_chains, fireball_chain_distance_scale, delay)
