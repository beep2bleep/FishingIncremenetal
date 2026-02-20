extends SpaceObject
class_name Comet

var duration: float = 6.0




var is_cleaning_up = false
var color_highlight: Color


@onready var pivot: Node2D = %Pivot


var base_spawn_radius = 500

var comet_type: Util.COMET_TYPE

@export var rotation_curve: Curve

func _ready():
    width = 32
    bonus_speed = -12.0
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    is_misc_type = true

    object_type = Util.OBJECT_TYPES.COMET


func custom_process(delta):
    %BaseSprite.look_at(linear_velocity)
    %"Line Trail".update_trail(global_position, Time.get_ticks_msec() / 1000.0)


func setup(_comet_type: Util.COMET_TYPE):



    comet_type = _comet_type

    can_be_damaged = true












    update_colors()














func _on_pallet_updated():
    update_colors()

var rotation_speed_start = 10
var rotation_speed_end = 180



var start_radius = 0





func update_colors():
    var color_normal
    match comet_type:
        Util.COMET_TYPE.CLICKER_AOE_BUFF:
            color_normal = Refs.pallet.comet_aoe
        Util.COMET_TYPE.MONEY_BUFF:
            color_normal = Refs.pallet.comet_money
        Util.COMET_TYPE.CLICKER_CRIT_CHANCE_BUFF:
            color_normal = Refs.pallet.comet_comet_crit

    color_highlight = color_normal
    color_highlight.v *= 1.25
    var dark_color = color_normal
    dark_color.v *= 1.2

    var color_damage_line = color_normal
    color_damage_line.v *= 0.95

    %BaseSprite.modulate = color_normal


func _on_health_component_death_event() -> void :
    is_dying = true


var mod_applied = false
func die():

    if is_dying == false:


        set_process(false)
        %"Line Trail".clear_points()


        is_dying = true
        Global.session_stats.comets_collected += 1
        FlairManager.create_particles_on_object_destoryed( %Pivot.global_position, color_highlight, 1, 16)

        match comet_type:
            Util.COMET_TYPE.CLICKER_AOE_BUFF:
                Global.mods.change_mod(Util.MODS.CLICK_AOE, Global.mods.get_mod(Util.MODS.COMET_CLICKER_AOE_BUFF_AMOUNT))
                Global.main.clicker.add_object(self)
                mod_applied = true
                %"Buff Timer".wait_time = Global.mods.get_mod(Util.MODS.COMET_CLICKER_AOE_BUFF_DURATION)
                %"Buff Timer".start()
            Util.COMET_TYPE.MONEY_BUFF:
                Global.mods.change_mod(Util.MODS.BONUS_MONEY_SCALE, Global.mods.get_mod(Util.MODS.COMET_MONEY_BUFF_AMOUNT))
                Global.main.clicker.add_object(self)
                mod_applied = true
                %"Buff Timer".wait_time = Global.mods.get_mod(Util.MODS.COMET_MONEY_BUFF_DURATION)
                %"Buff Timer".start()
            Util.COMET_TYPE.CLICKER_CRIT_CHANCE_BUFF:
                Global.mods.change_mod(Util.MODS.CLICKER_CRIT_CHANCE_BUFF, Global.mods.get_mod(Util.MODS.COMET_CRIT_CHANCE_BUFF_SCALE))
                Global.mods.change_mod(Util.MODS.CLICKER_CRIT_BONUS_BUFF, Global.mods.get_mod(Util.MODS.COMET_CRIT_BONUS_DAMAGE_BUFF_SCALE))
                Global.main.clicker.add_object(self)
                mod_applied = true
                %"Buff Timer".wait_time = Global.mods.get_mod(Util.MODS.COMET_CRIT_CHANCE_BUFF_DURATION)
                %"Buff Timer".start()



    %Pivot.position = Vector2.ZERO
    %"Line Trail".hide()




func clean_up():
    if mod_applied == true:
        match comet_type:
            Util.COMET_TYPE.CLICKER_AOE_BUFF:
                Global.mods.change_mod(Util.MODS.CLICK_AOE, - Global.mods.get_mod(Util.MODS.COMET_CLICKER_AOE_BUFF_AMOUNT))
            Util.COMET_TYPE.MONEY_BUFF:
                Global.mods.change_mod(Util.MODS.BONUS_MONEY_SCALE, - Global.mods.get_mod(Util.MODS.COMET_MONEY_BUFF_AMOUNT))
            Util.COMET_TYPE.CLICKER_CRIT_CHANCE_BUFF:
                Global.mods.change_mod(Util.MODS.CLICKER_CRIT_CHANCE_BUFF, - Global.mods.get_mod(Util.MODS.COMET_CRIT_CHANCE_BUFF_SCALE))
                Global.mods.change_mod(Util.MODS.CLICKER_CRIT_BONUS_BUFF, - Global.mods.get_mod(Util.MODS.COMET_CRIT_BONUS_DAMAGE_BUFF_SCALE))




    queue_free()


func _on_buff_timer_timeout() -> void :
    clean_up()
