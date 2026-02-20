extends Control
class_name GlobalResourceUI

@export var resource_types: Array[Util.RESOURCE_TYPES]
@export var resource_ui_packed: PackedScene

var resource_data_dict = {}
var resource_ui_dict = {}


func _ready():
    for type in resource_types:
        var new_resource_ui = resource_ui_packed.instantiate()
        var new_resource_data = ResourceData.new(type, 0)

        add_child(new_resource_ui)
        new_resource_ui.resource_data = new_resource_data
        resource_data_dict[type] = new_resource_data
        resource_ui_dict[type] = new_resource_ui


    SignalBus.global_resource_changed.connect(_on_global_resource_changed)


func get_resource_icon_global_position_by_type(resource_type: Util.RESOURCE_TYPES):
    if resource_ui_dict.has(resource_type):
        return resource_ui_dict[resource_type].get_icon_global_position()









func spawn_resource(type, amount, to_node):
    Util.create_resource_changed(type, amount, true, self, to_node)


func update_all_resource_amounts():
    for resource_type in resource_data_dict.keys():
        resource_data_dict[resource_type].amount = Global.data_manager.global_resource_data.get_resource_amount_by_type(resource_type)

func _on_global_resource_changed(event_data: GlobalResourceChangedEventData):
    if resource_data_dict.has(event_data.type):
        resource_data_dict[event_data.type].amount = event_data.new_value
