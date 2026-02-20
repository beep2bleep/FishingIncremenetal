@tool
extends Resource
class_name ControllerSettings

enum Devices{
    NONE = -1, 
    LUNA, 
    OUYA, 
    PS3, 
    PS4, 
    PS5, 
    STADIA, 
    STEAM, 
    SWITCH, 
    JOYCON, 
    XBOX360, 
    XBOXONE, 
    XBOXSERIES, 
    STEAM_DECK
}


@export_subgroup("General")



@export var joypad_fallback: Devices = Devices.XBOX360



@export_range(0.0, 1.0) var joypad_deadzone: float = 0.5


@export var allow_mouse_remap: bool = true



@export_range(0, 10000) var mouse_min_movement: int = 200


@export_subgroup("Custom assets")


@export_dir var custom_asset_dir: String = ""


@export var custom_mapper: Script


@export var custom_file_extension: String = ""


@export_subgroup("Text Rendering")


@export var custom_label_settings: LabelSettings
