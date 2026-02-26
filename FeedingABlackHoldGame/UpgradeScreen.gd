extends CanvasLayer

class_name UpgradeScreen

var is_active = false


var dragging = false
var scroll_speed = 500

var zoom

@onready var tech_tree: TechTree = %"Tech Tree"


enum STATES{SHOWING_TREE, ROGULIKE}

var state: STATES = STATES.SHOWING_TREE:
    set(new_value):
        state = new_value

        match state:
            STATES.SHOWING_TREE:
                %"Bottom Bar".show()
            STATES.ROGULIKE:
                %"Bottom Bar".hide()



func _ready() -> void :
    SignalBus.pallet_updated.connect(_on_pallet_updated)
    SignalBus.global_resource_changed.connect(_on_global_resource_changed)

    ControllerIcons.input_type_changed.connect(_on_input_type_changed)




    %CanvasLayer.hide()
    %CanvasLayer2.hide()

    set_process_input(false)
    set_process(false)

    update_colors()
    hide()

func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    if is_active == true:
        update_input(input_type)

func _input(event: InputEvent) -> void :
    if Global.game_state == Util.GAME_STATES.UPGRADES:
        if event.is_action_pressed("go again"):
            _on_go_again_pressed()











func setup():
    %"Tech Tree".setup()


func _on_global_resource_changed(event_data: GlobalResourceChangedEventData):
    if event_data.type == Util.RESOURCE_TYPES.MONEY:
        update()

func update():
    %"Tech Tree".update_active()


func _on_pallet_updated():
    update_colors()


func update_colors():
    %"Click Mask".color = Refs.pallet.background

    var color_light = Refs.pallet.background
    color_light.v *= 1.05
    %"GPUParticles2D Light".modulate = color_light

    var color_dark = Refs.pallet.background
    color_dark.v *= 0.95
    %"GPUParticles2D2 Dark".modulate = color_dark


func _process(delta: float) -> void :
    if is_active == true and state == STATES.SHOWING_TREE:

        match ControllerIcons.get_last_input_type():
            ControllerIcons.InputType.KEYBOARD_MOUSE:
                var direction = Vector2(Input.get_axis("right", "left"), Input.get_axis("down", "up")).normalized()

                if direction != Vector2.ZERO:
                    %"Tech Tree".move_tech_tree(direction * scroll_speed * delta)

            ControllerIcons.InputType.CONTROLLER:

                if Input.is_action_just_pressed("ui_left"):
                    %"Tech Tree".select_node_in_direction(Vector2.LEFT)
                elif Input.is_action_just_pressed("ui_right"):
                    %"Tech Tree".select_node_in_direction(Vector2.RIGHT)
                elif Input.is_action_just_pressed("ui_up"):
                    %"Tech Tree".select_node_in_direction(Vector2.UP)
                elif Input.is_action_just_pressed("ui_down"):
                    %"Tech Tree".select_node_in_direction(Vector2.DOWN)






func _on_color_rect_gui_input(event: InputEvent) -> void :
    if event.is_action_pressed("Grab"):
        dragging = true
    elif event.is_action_released("Grab"):
        dragging = false

    if dragging and event is InputEventMouseMotion:
        %"Tech Tree".move_tech_tree(event.relative)



var nodes_unlocked_this_session = 0


func on_node_unlocked(node: TechTreeNode):
    if Global.game_state == Util.GAME_STATES.UPGRADES:

        match nodes_unlocked_this_session:
            0:
                %AudioStreamPlayer.play()
            1:
                %AudioStreamPlayer2.play()
            2:
                %AudioStreamPlayer3.play()
            _:
                AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_CLICK)


        nodes_unlocked_this_session += 1

    if node.upgrade and node.upgrade.type == Util.NODE_TYPES.ROGUELIKE_DUMMY:
        match state:
            STATES.SHOWING_TREE:
                var new_screen: UpgradesRoguelike = Refs.roguelike_screen_packed.instantiate()
                %"Popup Layer".add_child(new_screen)
                new_screen.setup(node)

                state = STATES.ROGULIKE
            STATES.ROGULIKE:
                pass

    check_upgrade_tree_achivements()


func update_input(input_type):
    if is_active == true:
        match input_type:
            ControllerIcons.InputType.KEYBOARD_MOUSE:
                %"Pan Tree".show()
                %"Navigate DPAD".hide()
                %"Mouse Drag Tree".show()
            ControllerIcons.InputType.CONTROLLER:
                %"Pan Tree".hide()
                %"Navigate DPAD".show()
                %"Mouse Drag Tree".hide()

                if tech_tree.selected_node != null:
                    %"Tech Tree".selected_node.click_mask.grab_focus()
                    _on_tech_tree_selected_node_changed( %"Tech Tree".selected_node)



func show_screen():
    is_active = true

    %CanvasLayer.show()
    %CanvasLayer2.show()



    update_input(ControllerIcons.get_last_input_type())

    nodes_unlocked_this_session = 0

    Global.main.camera_2d.target_zoom = Global.main.camera_2d.target_zoom
    set_process_input(true)
    set_process(true)
    show()


func check_upgrade_tree_achivements():
    var send_data = false
    if Global.current_game_mode_data.game_mode != Util.GAME_MODES.MAIN:
        return

    if tech_tree.next_completed_index >= 50:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.HAVE_50_UPGRADES, false)
        if need_to_update == true:
            send_data = true

    if tech_tree.next_completed_index >= 100:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.HAVE_100_UPGRADES, false)
        if need_to_update == true:
            send_data = true

    if tech_tree.next_completed_index >= 150:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.HAVE_150_UPGRADES, false)
        if need_to_update == true:
            send_data = true

    if tech_tree.next_completed_index >= 200:
        var need_to_update = SteamHandler.set_achievement(SteamHandler.ACHIVEMENTS.HAVE_200_UPGRADES, false)
        if need_to_update == true:
            send_data = true

    if send_data == true:
        SteamHandler.store_steam_data()


func hide_screen():
    set_process_input(false)
    set_process(false)
    SceneChanger.do_transition(self, Global.main)
    is_active = false
    %CanvasLayer.hide()
    %CanvasLayer2.hide()


func _on_go_again_pressed() -> void :
    if _is_simulation_upgrade_tree():
        SceneChanger.change_to_new_scene(Util.PATH_FISHING_BATTLE)
        return
    hide_screen()


func _on_tech_tree_selected_node_changed(new_selected_node: TechTreeNode) -> void :
    if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
        if new_selected_node != null:
            %"Tech Tree".tween_to_pos( - new_selected_node.position)
        else:
            %"Tech Tree".tween_to_pos(Vector2.ZERO)

func _is_simulation_upgrade_tree() -> bool:
    for upgrade_variant: Variant in Global.game_mode_data_manager.upgrades.values():
        if upgrade_variant is Upgrade:
            var upgrade: Upgrade = upgrade_variant
            if upgrade.sim_name != "":
                return true
    return false
