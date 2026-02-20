extends Resource
class_name GlobalResourceManager

var resources_dict = {}

var total_resources_spent = 0

func _init() -> void :
    for value in Util.RESOURCE_TYPES.values():
        resources_dict[value] = 0


func reset_resource_amount(type: Util.RESOURCE_TYPES):
    change_resource_by_type(type, - resources_dict[type])


func change_resource_by_type(type: Util.RESOURCE_TYPES, amount: int):
    if resources_dict.has(type) == true:
        var old_value = resources_dict[type]
        resources_dict[type] += amount
        var new_value = resources_dict[type]

        if amount < 0:
            total_resources_spent += abs(amount)

        SignalBus.global_resource_changed.emit(GlobalResourceChangedEventData.new(type, old_value, new_value))
    else:
        push_error("GlobalResourceData.change_resource_by_type setup needed for type = ", Util.RESOURCE_TYPES.keys()[type])

func get_resource_amount_by_type(type: Util.RESOURCE_TYPES):
    if resources_dict.has(type) == true:
        return resources_dict[type]
    else:
        push_error("GlobalResourceData.get_resource_amount_by_type setup needed for type = ", Util.RESOURCE_TYPES.keys()[type])


func to_dict() -> Dictionary:
    var out = {}
    var resource_data = {}

    for type in resources_dict.keys():
        var type_name = Util.RESOURCE_TYPES.keys()[type]
        resource_data[type_name] = resources_dict[type]

    out["resources_dict"] = resource_data
    out["total_resources_spent"] = total_resources_spent
    return out

func load_from_dict(data: Dictionary):
    if data.has("resources_dict"):
        for name in data["resources_dict"].keys():
            if Util.RESOURCE_TYPES.has(name):
                var type_enum = Util.RESOURCE_TYPES[name]
                resources_dict[type_enum] = int(data["resources_dict"][name])

    if data.has("total_resources_spent"):
        total_resources_spent = int(data["total_resources_spent"])
