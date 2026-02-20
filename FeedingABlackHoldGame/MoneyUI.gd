extends MarginContainer
class_name MoneyUI

func _ready() -> void :
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    SignalBus.global_resource_changed.connect(_on_global_resource_changed)
    update_colors()

func _on_pallet_updated():
    update_colors()

func update_colors():

    %Money.add_theme_color_override("font_color", Refs.pallet.money_color)
    %Money.add_theme_font_override("font", Refs.money_font)

    pass








func _on_global_resource_changed(event_data: GlobalResourceChangedEventData):

    if event_data.type == Util.RESOURCE_TYPES.MONEY:
        %Money.text = str("$", Util.get_number_short_text(event_data.new_value))
        if event_data.new_value > event_data.old_value:
            animate()

func get_text_location():
    return %Money.global_position + Vector2( %Money.size.x, %Money.size.y / 2.0)

var scale_tween: Tween
func animate():
    pivot_offset = size / 2.0
    if scale_tween and scale_tween.is_running():
        scale_tween.kill()
        scale = Vector2.ONE
    scale_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
    scale_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
    scale_tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
