extends Resource
class_name GlobalResourceChangedEventData

var type: Util.RESOURCE_TYPES
var old_value: int
var new_value: int


func _init(_type: Util.RESOURCE_TYPES, _old_value: int, _new_value: int) -> void :
    type = _type
    old_value = _old_value
    new_value = _new_value
