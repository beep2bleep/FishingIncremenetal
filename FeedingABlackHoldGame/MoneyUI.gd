extends MarginContainer
class_name MoneyUI

const OPEN_PIT_PROGRESS_SCRIPT = preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const OPEN_PIT_XP_COLOR := Color(0.36, 0.78, 1.0, 1.0)
const OPEN_PIT_CORE_COLOR := Color(1.0, 0.18, 0.16, 1.0)

var wallet_container: HBoxContainer
var money_label: Label
var xp_label: Label
var core_label: Label

func _ready() -> void :
    money_label = get_node_or_null("%Money") as Label
    _ensure_open_pit_wallet_labels()
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    SignalBus.global_resource_changed.connect(_on_global_resource_changed)
    update_colors()
    refresh_amounts()

func _on_pallet_updated():
    update_colors()

func update_colors():
    if money_label != null:
        money_label.add_theme_color_override("font_color", Refs.pallet.money_color)
        money_label.add_theme_font_override("font", Refs.money_font)
    if xp_label != null:
        xp_label.add_theme_color_override("font_color", OPEN_PIT_XP_COLOR)
        xp_label.add_theme_font_override("font", Refs.money_font)
    if core_label != null:
        core_label.add_theme_color_override("font_color", OPEN_PIT_CORE_COLOR)
        core_label.add_theme_font_override("font", Refs.money_font)

func refresh_amounts() -> void:
    var money_amount: int = int(Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY)) if Global.global_resoruce_manager != null else 0
    _set_money_amount(money_amount)
    _refresh_open_pit_wallet_labels()

func _on_global_resource_changed(event_data: GlobalResourceChangedEventData):
    if event_data.type == Util.RESOURCE_TYPES.MONEY:
        _set_money_amount(int(event_data.new_value))
        _refresh_open_pit_wallet_labels()
        if event_data.new_value > event_data.old_value:
            animate()

func _set_money_amount(amount: int) -> void:
    if money_label == null:
        return
    money_label.text = str("$", Util.get_number_short_text(amount))

func _ensure_open_pit_wallet_labels() -> void:
    if wallet_container != null:
        return
    if money_label == null:
        return
    var center_container := money_label.get_parent()
    if center_container == null:
        return
    center_container.remove_child(money_label)
    wallet_container = HBoxContainer.new()
    wallet_container.alignment = BoxContainer.ALIGNMENT_CENTER
    wallet_container.add_theme_constant_override("separation", 26)
    center_container.add_child(wallet_container)
    wallet_container.add_child(money_label)

    xp_label = Label.new()
    xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    xp_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    xp_label.add_theme_constant_override("shadow_offset_x", 1)
    xp_label.add_theme_constant_override("shadow_offset_y", 1)
    xp_label.add_theme_constant_override("shadow_outline_size", 5)
    wallet_container.add_child(xp_label)

    core_label = Label.new()
    core_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    core_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    core_label.add_theme_constant_override("shadow_offset_x", 1)
    core_label.add_theme_constant_override("shadow_offset_y", 1)
    core_label.add_theme_constant_override("shadow_outline_size", 5)
    wallet_container.add_child(core_label)

func _refresh_open_pit_wallet_labels() -> void:
    if xp_label == null or core_label == null:
        return
    var should_show_open_pit_wallets: bool = Util.is_open_pit_game_active()
    xp_label.visible = should_show_open_pit_wallets
    core_label.visible = should_show_open_pit_wallets
    if not should_show_open_pit_wallets:
        return
    xp_label.text = tr("OPEN_PIT_XP_WALLET") % Util.get_number_short_text(OPEN_PIT_PROGRESS_SCRIPT.get_xp_wallet())
    core_label.text = tr("OPEN_PIT_ROOT_KEYS_WALLET") % Util.get_number_short_text(OPEN_PIT_PROGRESS_SCRIPT.get_core_wallet())

func get_text_location():
    if money_label == null:
        return global_position + size / 2.0
    return money_label.global_position + Vector2(money_label.size.x, money_label.size.y / 2.0)

var scale_tween: Tween
func animate():
    pivot_offset = size / 2.0
    if scale_tween and scale_tween.is_running():
        scale_tween.kill()
        scale = Vector2.ONE
    scale_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
    scale_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
    scale_tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
