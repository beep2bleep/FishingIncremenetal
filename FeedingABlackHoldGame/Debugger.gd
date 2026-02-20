extends PanelContainer
class_name Debugger

var current_section = 1
var current_act = 1

var is_screenshot_mode = false

func _input(event: InputEvent) -> void :
    if OS.is_debug_build():
        if event.is_action_pressed("Debug"):
            visible = !visible

        if event.is_action_pressed("Screen Shot"):
            is_screenshot_mode = !is_screenshot_mode
            get_tree().paused = is_screenshot_mode










func _ready():
    hide()

func _process(delta: float) -> void :
    %FPS.text = str("FPS: ", Engine.get_frames_per_second())








func _on_reset_matter_pressed() -> void :
    Global.global_resoruce_manager.reset_resource_amount(Util.RESOURCE_TYPES.MONEY)


func _on_add_matter_pressed() -> void :

    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, 100000000000)


func _on_level_up_pressed() -> void :
    Global.black_hole.level_manager.add_xp(Global.black_hole.level_manager.get_remianing_xp_needed_to_level_up())





func _on_add_10_seconds_pressed() -> void :
    Global.main.session_timer += 10


func _on_end_run_pressed() -> void :
    Global.main.session_timer = 0


func _on_game_over_pressed() -> void :
    Global.black_hole.level_manager.force_end_of_game()



func _on_spawn_comet_pressed() -> void :
    Global.main.object_manager.spawn_comet()


func _on_spawn_planet_pressed() -> void :
    Global.main.object_manager.create_planet()










func _on_unlock_next_branch_pressed() -> void :
    for tech_tree_node: TechTreeNode in Global.main.upgrade_screen.tech_tree.node_dict.values():
        if tech_tree_node.upgrade and tech_tree_node.upgrade.section <= current_section:
            tech_tree_node.unlock_node()

    current_section += 1

func _on_unlock_next_act_pressed() -> void :
    var highest_section_seen = -1

    for tech_tree_node: TechTreeNode in Global.main.upgrade_screen.tech_tree.node_dict.values():
        if tech_tree_node.upgrade and tech_tree_node.upgrade.act <= current_act:
            tech_tree_node.unlock_node()
            if tech_tree_node.upgrade.section > highest_section_seen:
                highest_section_seen = tech_tree_node.upgrade.section


    if highest_section_seen >= 0:
        current_section = highest_section_seen + 1

    current_act += 1


func _on_clicker_damage_pressed() -> void :
    Global.mods.change_mod(Util.MODS.BASE_DAMAGE_PER_CLICK, 1000)






func _on_spawn_ufo_pressed() -> void :
    Global.main.object_manager.spawn_ufo()


func _on_reset_steam_achi_pressed() -> void :
    if Steam.isSteamRunning():
        Steam.resetAllStats(true)






func _on_add_matter_2_pressed() -> void :
    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, 10000000000000000)


func _on_milestone_pressed() -> void :
    Global.black_hole.level_manager.force_finish_current_tier()
