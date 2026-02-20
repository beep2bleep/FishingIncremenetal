extends ColorRect
class_name TierSummary

var fast_screen = false
var is_shown = false

func show_screen():
    set_process_input(true)
    is_shown = true

    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        %Upgrades.grab_focus()

func _ready():
    %Title.text = Util.get_raindbow_bbcode(Util.get_wave_bbcode(str(tr("MILESTONE_REACHED"), "!")))
    set_process_input(false)

    ControllerIcons.input_type_changed.connect(_on_input_type_changed)


func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    if is_shown == true:
        if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
            %Upgrades.grab_focus()


func setup():
    %"Milestone Name".text = str("MILESTONE_", Global.black_hole.level_manager.current_tier_index + 1)

    %"Milestone Numbers".text = "{CURRENT}/{MAX}".format({
        "CURRENT": Global.black_hole.level_manager.current_tier_index + 1, 
        "MAX": Global.black_hole.level_manager.get_tiers_until_full_game(), 
    })

    var total_earned = 0
    total_earned += Global.session_stats.asteroid_money
    total_earned += Global.session_stats.planet_money
    total_earned += Global.session_stats.star_money

    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, total_earned)

    var bonus_earned = 0
    var last_tier: BlackHoleTierData = Global.black_hole.level_manager.current_black_hole_tier_data
    if last_tier.set_money_to_this_amount_on_finishing_tier != -1 and Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY) < last_tier.set_money_to_this_amount_on_finishing_tier:
        bonus_earned = max(0, last_tier.set_money_to_this_amount_on_finishing_tier - Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY))
        Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.MONEY)
        Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, last_tier.set_money_to_this_amount_on_finishing_tier)

    Global.tier_stats.total_money_earned_this_teir += bonus_earned


    if bonus_earned != 0:
        %"Reward Amount".text = str("$", Util.get_number_short_text(bonus_earned))
        %"Rewards Stuff".show()
    else:
        %"Rewards Stuff".hide()


    Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.MATTER)
    Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.PLANET)
    Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.STAR)



    update_stats()

    Global.tier_stats.reset()

    SaveHandler.save_player_last_run()


func update_stats():
    %"Damage This Milestone".setup(int(Global.tier_stats.total_damage_this_tier), load("res://Art/DAMAGE ICON.png"), "DAMAGE_THIS_MILESTONE")
    %"Objects Destroyed This Milestone".setup(int(Global.tier_stats.total_objects_destoryed_this_tier), load("res://Objects Destroyed.png"), "OBJECTS_DESTROYED_THIS_MILESTONE")
    %"Total Money This Milestone".setup(int(Global.tier_stats.total_money_earned_this_teir), load("res://Art/MONEY ICON.png"), "TOTAL_MONEY_THIS_MILESTONE", true, true)




func _input(event: InputEvent) -> void :
    if Global.game_state == Util.GAME_STATES.END_OF_TEIR:
        if event.is_action_pressed("upgrades"):
            _on_upgrades_pressed()


func do_animations():
    %"Moeny UI".modulate.a = 1.0
    %"Moeny UI".animate()
    %"TaDa Audio".play()


func _on_upgrades_pressed() -> void :
    set_process_input(false)
    is_shown = false

    %AudioStreamPlayer.stop()

    Global.game_state = Util.GAME_STATES.UPGRADES
    SceneChanger.do_transition(null, Global.main.upgrade_screen)
