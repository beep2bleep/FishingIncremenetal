extends ProgressBar
class_name BlackHoleMassUI


@export var black_hole: BlackHole:
    set(new_value):
        black_hole = new_value

        if black_hole != null:
            black_hole.level_manager.updated.connect(_on_black_hole_level_manager_updadted)


var background_style_box: StyleBoxFlat
var fill_style_box: StyleBoxFlat


func _ready():
    background_style_box = get_theme_stylebox("background")
    fill_style_box = get_theme_stylebox("fill")

    SignalBus.pallet_updated.connect(_on_pallet_updated)

    _on_pallet_updated()


func _on_pallet_updated():
    background_style_box.bg_color = Refs.pallet.background
    background_style_box.border_color = Refs.pallet.black_hole_dark

    fill_style_box.bg_color = Refs.pallet.black_hole_dark


func _on_black_hole_level_manager_updadted(data: LevelManagerUpdatedData):
    max_value = data.current_level_xp

    if data.old_xp < data.new_xp:
        create_xp_changed_tween(data.new_xp)
    else:
        value = data.new_xp


var xp_changed_tween: Tween

func create_xp_changed_tween(new_value):
    if xp_changed_tween and xp_changed_tween.is_running():
        xp_changed_tween.kill()

    xp_changed_tween = create_tween()
    xp_changed_tween.tween_property(self, "value", new_value, 0.25)
