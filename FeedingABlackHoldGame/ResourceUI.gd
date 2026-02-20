extends MarginContainer
class_name ResourceUI

var resource_data: ResourceData:
    set(new_resource_data):
        resource_data = new_resource_data
        resource_data.updated.connect(_on_resource_data_updated)
        %Icon.texture = Refs.get_resource_icon_by_type(resource_data.type)
        %Icon.modulate = Refs.get_resource_color_by_type(resource_data.type)

        set_text()

func _ready() -> void :
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    update_colors()

func _on_pallet_updated():
    update_colors()

func update_colors():
    %"Resource Value".add_theme_color_override("font_color", Refs.pallet.text_dark_color)
    if resource_data:
        %Icon.modulate = Refs.get_resource_color_by_type(resource_data.type)

func _on_resource_data_updated():
    set_text()
    animate()

func set_text():
    %"Resource Value".text = str(Util.get_number_short_text(resource_data.amount))

func get_icon_global_position():
    return %"Icon".global_position + %"Icon".size / 2.0

var scale_tween: Tween
func animate():
    pivot_offset = size / 2.0
    if scale_tween and scale_tween.is_running():
        scale_tween.kill()
        scale = Vector2.ONE
    scale_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
    scale_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
    scale_tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
