extends CharacterBody2D
class_name Player

var direction = Vector2.ZERO
var speed = 200
var fuel = 10.0:
    set(new_value):
        fuel = max(0, new_value)

        if fuel <= 0:
            Global.main.upgrade_screen.show_screen()


var passive_fuel_rate = 0.5
var active_fuel_rate = 1.0

func _ready() -> void :
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    update_colors()

    Global.player = self





var target_object: Node2D:
    set(new_value):
        if target_object != new_value and target_object != null:
            target_object.destroyed.disconnect(_on_target_object_destroyed)

        target_object = new_value

        if target_object != null:
            target_object.destroyed.connect(_on_target_object_destroyed)


func _on_target_object_destroyed(object):
    if object == target_object:
        target_object = null



func reset():


    $"Shoot Timer".start(0)
    update()


func update():

    $"Shoot Timer".wait_time = 1.0 / Global.mods.get_mod(Util.MODS.CLICK_RATE)


func _on_pallet_updated():
    update_colors()

func update_colors():
    pass


func _physics_process(delta):

    if target_object == null:
        var clicker_objects = Global.main.clicker.get_overlapping_bodies()
        if clicker_objects.size() > 0:
            target_object = clicker_objects.pick_random()

    if target_object != null:


        %"Art Pivot".look_at(get_global_mouse_position())
        direction = Vector2.ZERO
        direction = Vector2(get_global_mouse_position() - global_position).normalized()
        velocity = direction * speed









    %GPUParticles2D.emitting = direction.length() != 0
    %GPUParticles2D2.emitting = direction.length() != 0

    fuel -= delta * (active_fuel_rate if direction.length() != 0 else passive_fuel_rate)

    move_and_slide()


    for area in %SuckUpArea2D.get_overlapping_areas():
        area.get_sucked_up()









func _on_suck_up_area_2d_area_entered(area: Area2D) -> void :
    area.get_sucked_up()
