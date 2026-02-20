extends Node2D
class_name SpaceObject


signal destroyed(object)

var is_active = false
var can_be_damaged = false

var resources_to_spawn = 1
var base_value = 1
var xp_per_resource = 1
var tier = 0
var size = 0

var linear_velocity = Vector2.ONE
var angular_velocity = 0

var collision_art
var collision_line
var bonus_speed = 1.0


var special_type:
    set(new_value):
        special_type = new_value
        on_special_type_update()

var special_type_crit = false

func on_special_type_update():
    pass

var custom_tween_component: CustomTweenComponent


var base_health = 1
var base_xp = 1
var expo_for_xp_teir = 1.0

var respawn = false:
    set(new_value):
        if disable_respawns == true:
            respawn = false
        else:
            respawn = new_value

var disable_respawns = false
var is_dying = false

const max_tier = 7

var width = 0:
    set(new_value):
        width = new_value
        radius = width / 2.0
        radius_sqrd = radius * radius

var radius = 0
var radius_sqrd = 0
var is_misc_type = false


var resource_type: Util.RESOURCE_TYPES

var object_type: Util.OBJECT_TYPES

@export var health_component: HealthComponent


func disable():
    visible = false
    is_active = false
    can_be_damaged = false

    custom_disable()

func custom_disable():
    pass


func custom_process(delta):
    pass

func get_tier_size_damage_scale():
    return max(1.0, float(tier + (size)))


var colors = [
    Refs.pallet.red, 
    Refs.pallet.orange, 
    Refs.pallet.yellow, 
    Refs.pallet.green, 
    Refs.pallet.blue, 
    Refs.pallet.indigo, 
    Refs.pallet.violet
]


func take_damage(amount, from_glob_pos = global_position, is_crit = false):
    var damage_event_data = DamageEventData.new()

    damage_event_data.object = self
    damage_event_data.object_type = object_type
    damage_event_data.damage = amount
    damage_event_data.special_effect_type = special_type


    FlairManager.create_new_floating_text(global_position, int(amount), Util.FLOATING_TEXT_TYPES.DAMAGE_CRIT if is_crit else Util.FLOATING_TEXT_TYPES.DAMAGE_CLICK, object_type)

    health_component.damage(amount)

    var max_health_percent = float(amount) / float(health_component.max_health)
    if is_dying == false:
        custom_tween_component.do_tween(max_health_percent)

    damage_event_data.special_effect_crit = special_type_crit
    damage_event_data.died = is_dying

    return damage_event_data


func take_perecent_damage(percent, based_on_current_health = true, from_glob_pos = global_position):
    var damage_event_data = DamageEventData.new()

    damage_event_data.object = self
    damage_event_data.object_type = object_type

    var amount = 0
    if based_on_current_health == true:
        amount = health_component.current_health * percent
    else:
        amount = health_component.max_health * percent

    damage_event_data.damage = amount
    damage_event_data.special_effect_type = special_type


    FlairManager.create_new_floating_text(global_position, int(amount), Util.FLOATING_TEXT_TYPES.DAMAGE_CLICK, object_type)

    health_component.damage(amount)

    var max_health_percent = float(amount) / float(health_component.max_health)
    custom_tween_component.do_tween(max_health_percent)

    damage_event_data.special_effect_crit = special_type_crit
    damage_event_data.died = is_dying

    return damage_event_data

var position_tween: Tween
func tween_animate(to_glob_pos):
    if position_tween != null:
        position_tween.kill()

    position_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
    position_tween.tween_property(self, "global_position", to_glob_pos, 0.5)
