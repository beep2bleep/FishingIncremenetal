extends ProgressBar
class_name HealthComponent

signal death_event
signal health_changed

var current_health = 0.0:
    set(new_value):
        current_health = new_value
        health_changed.emit()

var max_health = 1.0
var current_health_percent = 0.0

var has_died = false

func setup(_max_health):
    max_health = _max_health
    current_health = max_health

    current_health_percent = current_health / max_health

    value = current_health
    max_value = max_health

    hide()







func get_health_percent():
    return current_health / max_health

func heal(heal_value):
    set_health(current_health + heal_value)

func damage(damage_value):
    set_health(current_health - damage_value)

func set_health(new_health_value):
    current_health = clamp(new_health_value, 0.0, max_health)
    current_health_percent = current_health / max_health

    value = (max_health - current_health)
    max_value = max_health

    visible = max_health != current_health

    if current_health <= 0 and has_died == false:
        die()

func die():
    has_died = true
    death_event.emit()
