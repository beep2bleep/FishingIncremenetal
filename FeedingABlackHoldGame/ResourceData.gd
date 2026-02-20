extends Resource
class_name ResourceData

signal updated

@export var type: Util.RESOURCE_TYPES
@export_range(0, 20, 1, "or_greater") var amount: int = 0:
    set(new_amount):
        if new_amount != amount:
            amount = new_amount
            updated.emit()

func _init(_type: Util.RESOURCE_TYPES, _amount: int):
    type = _type
    amount = _amount

func clone() -> ResourceData:
    return ResourceData.new(type, amount)

func _to_string():
    return str("(", Util.RESOURCE_TYPES.keys()[type], ", ", amount, ")")
