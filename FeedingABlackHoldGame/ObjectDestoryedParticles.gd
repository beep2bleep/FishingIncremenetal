extends GPUParticles2D

var enable = false

var scale_min_base
var scale_max_base

func _ready():
    scale_min_base = process_material.scale_min
    scale_max_base = process_material.scale_max

func setup(cust_scale, radius):
    enable = true
    restart()
    emitting = true
    %Timer.start()
    show()



    process_material.emission_sphere_radius = radius
    process_material.scale_min = scale_min_base * cust_scale
    process_material.scale_max = scale_max_base * cust_scale







func clean_up():
    if enable == true:
        enable = false
        emitting = false
        FlairManager.destroyed_parts_pool.append(self)
        hide()


func _on_timer_timeout() -> void :
    clean_up()
