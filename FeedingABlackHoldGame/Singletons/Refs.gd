extends Node

@export var pallet: Pallet

@export var mod_textures: Dictionary[Util.MODS, Texture2D]

@export_group("Packed Scenes")

@export var packed_asteroid: PackedScene
@export var packed_planet: PackedScene
@export var packed_star: PackedScene
@export var packed_comet: PackedScene
@export var packed_resource_changed: PackedScene



@export var packed_tech_tree_node: PackedScene
@export var packed_tech_tree_line: PackedScene


@export var packed_ufo: PackedScene
@export var roguelike_screen_packed: PackedScene


@export_group("Fonts")
@export var damage_font: Font
@export var damage_crit_font: Font
@export var money_font: Font
@export var godlen_font: Font

@export_group("Resource Shapes")

@export var texture_matter_small: Texture2D
@export var texture_planet_small: Texture2D
@export var texture_sun_small: Texture2D

@export var texture_matter: Texture2D
@export var texture_planet: Texture2D
@export var texture_star: Texture2D
@export var texture_black_hole: Texture2D

@export var texture_special_bomb: Texture2D
@export var texture_special_electric: Texture2D
@export var texture_special_radioactive: Texture2D

@export var cloud_textures: Array[Texture2D] = []
@export var lock: Texture2D

func get_act_light_color(act: int = 0):
    return pallet.act_colors_light[act - 1] if act - 1 < pallet.act_colors_light.size() else pallet.act_colors_light[0]

func get_act_dark_color(act: int = 0):
    return pallet.act_colors_dark[act - 1] if act - 1 < pallet.act_colors_dark.size() else pallet.act_colors_dark[0]

func get_resource_icon_small_by_type(resource_type: Util.RESOURCE_TYPES):
    match resource_type:
        Util.RESOURCE_TYPES.MATTER:
            return texture_matter_small
        Util.RESOURCE_TYPES.PLANET:
            return texture_planet_small
        Util.RESOURCE_TYPES.STAR:
            return texture_sun_small


func get_resource_icon_by_type(resource_type: Util.RESOURCE_TYPES):
    match resource_type:
        Util.RESOURCE_TYPES.MATTER:
            return texture_matter
        Util.RESOURCE_TYPES.PLANET:
            return texture_planet
        Util.RESOURCE_TYPES.STAR:
            return texture_star
        Util.RESOURCE_TYPES.BLACK_HOLE:
            return texture_black_hole


    return load("res://Art/icon.svg")


func get_special_icon_by_type(type: Util.SPECIAL_TYPES):
    match type:
        Util.SPECIAL_TYPES.ELECTRIC:
            return texture_special_electric
        Util.SPECIAL_TYPES.RADIOACTIVE:
            return texture_special_radioactive

    return load("res://Art/icon.svg")


func get_resource_color_by_type(resource_type: Util.RESOURCE_TYPES):
    match resource_type:
        Util.RESOURCE_TYPES.MATTER:
            return pallet.text_dark_color
        Util.RESOURCE_TYPES.PLANET:
            return pallet.text_dark_color
        Util.RESOURCE_TYPES.STAR:
            return pallet.text_dark_color
        Util.RESOURCE_TYPES.BLACK_HOLE:
            return pallet.text_dark_color

    return Color.DEEP_PINK
