extends Timer

var money_per_second = 0

func _ready():
    SignalBus.mod_changed.connect(_on_mod_changed)

func setup():
    money_per_second = Global.mods.get_mod(Util.MODS.PASSIVE_MONEY_PER_SECOND)

    if money_per_second > 0.0:
        start()

func _on_mod_changed(type: Util.MODS, old_value, new_value):
    if type == Util.MODS.PASSIVE_MONEY_PER_SECOND:
        money_per_second = new_value
        start()

func _on_timeout() -> void :
    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, money_per_second)
