extends Node2D
class_name TechTreeNode

signal state_changed
signal selected(node: TechTreeNode)
signal unlocked(node: TechTreeNode)

@onready var custom_tween_component: CustomTweenComponent = $CustomTweenComponent
@onready var tooltip_custom_tween_component: CustomTweenComponent = $"Tooltip Pivot/Tooltip CustomTweenComponent"

@export var available_can_pay_stylebox: StyleBoxFlat
@export var available_can_not_pay_stylebox: StyleBoxFlat
@export var complete_stylebox: StyleBoxFlat
@export var shadow_stylebox: StyleBoxFlat
@export var clicked_stylebox: StyleBoxFlat

@export var locked_texture: Texture2D

@onready var click_mask: Button = %"Click Mask"

var completed_index = 0

enum STATES{LOCKED, AVAILABLE, COMPLETE, SHADOW}

var upgrade: Upgrade

var hover_focus_style_box: StyleBoxFlat
var cell
var is_center_node = false

var tech_tree: TechTree

var cost

var is_highlighted: bool = false:
    set(new_value):

        if is_highlighted != new_value and new_value == true:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)

            custom_tween_component.do_tween(1.0)
            tooltip_custom_tween_component.do_tween(1.0)
            selected.emit()
        elif new_value == false:
            custom_tween_component.kill_tweens()
            custom_tween_component.reset()

        is_highlighted = new_value

        if tech_tree:
            tech_tree.selected_node = self

        if state == STATES.AVAILABLE or state == STATES.COMPLETE and upgrade != null:
            %"Tool Tip".visible = is_highlighted
            %"Tool Tip".pivot_offset = %"Tool Tip".size / 2.0







var can_pay_cost: bool = false:
    set(new_value):
        can_pay_cost = new_value



        update_panel()


func is_epilgue_node():
    return upgrade and upgrade.epilogue == 1



func do_pop_in():
    var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
    scale = Vector2.ZERO
    tween.tween_interval(0.2)
    tween.tween_callback( func(): AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_POP_IN))
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.25)
    tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
    tween.tween_property(self, "scale", Vector2.ONE, 0.05)



var is_setup = false

var state: STATES = STATES.LOCKED:
    set(new_state):
        var old_state = state

        if is_epilgue_node() and Global.main and Global.main.epilogue == false:
            return

        if state != new_state:
            if old_state == STATES.LOCKED and Global.game_state == Util.GAME_STATES.UPGRADES:
                do_pop_in()

            state = new_state
            if tech_tree:
                if state == STATES.COMPLETE:
                    completed_index = tech_tree.next_completed_index
                    tech_tree.next_completed_index += 1

                if state == STATES.AVAILABLE:
                    tech_tree.active_nodes.append(self)
                elif tech_tree.active_nodes.has(self):
                    tech_tree.active_nodes.erase(self)




            if state == STATES.AVAILABLE:

                if tech_tree:
                    tech_tree.update_connected_nodes_shadow(cell)






            if state == STATES.COMPLETE:
                if tech_tree:
                    tech_tree.update_connected_nodes_available(cell)

                unlocked.emit(self)

                if Global.game_state == Util.GAME_STATES.UPGRADES:
                    %"Visual Panel".add_theme_stylebox_override("panel", clicked_stylebox)
                    clicked_stylebox.bg_color = Refs.get_act_light_color(upgrade.act if upgrade else 1)
                    clicked_stylebox.border_color = Refs.get_act_light_color(upgrade.act if upgrade else 1)
                    %AnimationPlayer.play("On Complete")
                else:
                    on_complete_anim_finished()

            state_changed.emit(self)
            update()


var title_panel_style_box: StyleBoxFlat

func _ready():
    hover_focus_style_box = %"Click Mask".get_theme_stylebox("hover")
    title_panel_style_box = %TitlePanel.get_theme_stylebox("panel")
    SignalBus.pallet_updated.connect(update_colors)
    SignalBus.mod_changed.connect(_on_mod_changed)
    SignalBus.epilogue_started.connect(_on_epilogue_started)


    %"Tool Tip".pivot_offset = %"Tool Tip".size / 2.0

    SignalBus.settings_updated.connect(_on_settings_updated)

    %"Tool Tip".hide()

func _on_settings_updated():
    update()

func _on_epilogue_started():
    if Global.main and Global.main.epilogue == true and upgrade and upgrade.epilogue == 1 and state != STATES.COMPLETE:
        state = STATES.AVAILABLE


func _on_mod_changed(type: Util.MODS, old_value, new_value):
    if upgrade and type == upgrade.mod:
        update()


func update_panel():
    match state:
        STATES.SHADOW:
            %"Visual Panel".add_theme_stylebox_override("panel", shadow_stylebox)
        STATES.AVAILABLE:
            %Cost.add_theme_color_override("font_color", Refs.pallet.money_color if can_pay_cost else Refs.pallet.red)

            %"Visual Panel".add_theme_stylebox_override("panel", available_can_pay_stylebox if can_pay_cost else available_can_not_pay_stylebox)

            if upgrade:
                title_panel_style_box.bg_color = Refs.get_act_light_color(upgrade.act) if can_pay_cost else Refs.pallet.red

            else:
                title_panel_style_box.bg_color = Refs.pallet.act_1_light if can_pay_cost else Refs.pallet.red

        STATES.COMPLETE:
            %Icon.show()
            %"Click Mask".modulate.a = 0

            if upgrade:
                title_panel_style_box.bg_color = Refs.get_act_dark_color(upgrade.act)


func on_complete_anim_finished():
    %"Mod Icon".modulate = Refs.pallet.shadow
    %"Visual Panel".add_theme_stylebox_override("panel", complete_stylebox)
    %"Mod Icon".scale = Vector2(0.55, 0.55)

func setup(upgarde: Upgrade, _tech_tree: TechTree):
    is_setup = true
    upgrade = upgarde
    tech_tree = _tech_tree

    if upgrade != null:
        cell = upgrade.cell

    state = STATES.LOCKED


    %"Mod Icon".visible = !is_center_node
    %"Center Sprite".visible = is_center_node
    %"Visual Panel".visible = !is_center_node


    update()


func _on_pallet_state_changed():
    update_colors()



func update_colors():
    %Cost.add_theme_color_override("font_color", Refs.pallet.money_color if can_pay_cost else Refs.pallet.red)
    %Cost.add_theme_font_override("font", Refs.money_font)



    %Tier.add_theme_color_override("font_color", Refs.pallet.black_hole_dark)
    %"Is Max".add_theme_color_override("font_color", Refs.pallet.green)


    if upgrade:
        %Icon.self_modulate = Refs.get_act_light_color(upgrade.act)




func _on_click_mask_pressed() -> void :
    if state == STATES.AVAILABLE and can_pay_cost == true:

        Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, - cost)

        custom_tween_component.do_rotation = true
        custom_tween_component.do_tween(1.0)
        tooltip_custom_tween_component.do_tween(1.0)

        upgrade.current_tier += 1
        state_changed.emit(self)
        update()

        if Global.main and Global.main.upgrade_screen:
            Global.main.upgrade_screen.on_node_unlocked(self)

        SaveHandler.save_player_last_run()

func unlock_node(target_tier = 1):
    if upgrade:
        for i in range(max(0, target_tier - upgrade.current_tier)):
            upgrade.current_tier += 1
        state_changed.emit(self)
    update()



func update():
    if is_setup == false:
        return

    if is_center_node == true:
        %"Click Mask".hide()
        return

    %"Is Max".hide()
    %Tier.hide()
    %"Cost Hbox".hide()
    %HSeparator2.hide()
    %"Node Type".text = tr(Util.MODS.find_key(upgrade.mod))

    %"Shadow Icon".hide()
    %"Random Icon".hide()
    %"Mod Icon".hide()
    %TitlePanel.show()
    %"Upgrade Amount".show()

    if upgrade.type == Util.NODE_TYPES.ROGUELIKE_DUMMY:
        %Description.text = "CHOOSE AN UPGRADE"
        %"Cost Hbox".show()
        %TitlePanel.hide()
        %"Upgrade Amount".hide()
        %HSeparator2.show()

    elif upgrade.demo_locked == 1:
        %"Upgrade Amount".hide()
        %Description.text = "LOCKED FOR DEMO"
        %"Mod Icon".texture = locked_texture

    elif upgrade.is_at_max() == true:
        if upgrade.has_tiers():
            %"Is Max".show()
        state = STATES.COMPLETE
        %Description.text = str("Currently: ", Global.mods.get_mod_value(upgrade.mod, Global.mods.get_mod(upgrade.mod)))

        %"Upgrade Amount".text = str("$", Util.get_number_short_text(upgrade.get_cost()), " : ", Global.mods.get_mod_value(upgrade.mod, upgrade.get_current_teir_value(), true))
        %"Mod Icon".texture = Refs.mod_textures.get(upgrade.mod, null)
    else:

        %"Cost Hbox".show()

        %HSeparator2.show()

        if upgrade.has_tiers():
            %Tier.show()

            %Tier.text = "{CURRENT_TIER}/{MAX_TIER}".format({
                "CURRENT_TIER": str(upgrade.current_tier + 1), 
                "MAX_TIER": str(upgrade.max_tier)
            })

        %Description.text = Global.mods.get_from_to(upgrade.mod, upgrade.get_current_teir_value())
        %"Upgrade Amount".text = str(Global.mods.get_mod_value(upgrade.mod, upgrade.get_current_teir_value(), true))
        %"Mod Icon".texture = Refs.mod_textures.get(upgrade.mod, null)


    cost = upgrade.get_cost()
    %Cost.visible = cost != 0
    %Cost.text = str("$", Util.get_number_short_text(cost))
    if cost == 0:
        %HSeparator2.hide()

    update_can_pay_cost()

    if state == STATES.AVAILABLE and can_pay_cost == true:
        %"Click Mask".disabled = false
    else:
        %"Click Mask".disabled = true

    match state:
        STATES.LOCKED:
            hide()
            %Sprite2D.hide()
        STATES.SHADOW:
            show()
            %"Shadow Icon".show()
            %Sprite2D.hide()
            %"Mod Icon".hide()
        STATES.AVAILABLE:
            if upgrade and upgrade.type == Util.NODE_TYPES.ROGUELIKE_DUMMY:
                %"Random Icon".show()
            else:
                %"Mod Icon".show()
            %"Click Mask".show()
            show()
            %Sprite2D.hide()
        STATES.COMPLETE:
            %Sprite2D.show()
            %"Mod Icon".show()
            show()


    keep_tooltip_on_screen( %"Tool Tip")

    update_colors()
    update_panel()



func update_can_pay_cost():
    var check = true
    if cost > Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY):
        check = false

    if upgrade and upgrade.demo_locked == 1:
        check = false

    %Cost.add_theme_color_override("font_color", Refs.pallet.green if check else Refs.pallet.red)

    can_pay_cost = check


func keep_tooltip_on_screen(control_node: Control):
    %"Tool Tip".reset_size()

    await control_node.get_tree().process_frame


    var total_tooltip_size = Vector2( %"Tool Tip".size.x, %"Tool Tip".size.y + %TitlePanel.size.y - 22)


    %"Tool Tip".position.x = - total_tooltip_size.x / 2.0



    if Util.get_node2d_viewport_position(self, Global.main.camera_2d).y - total_tooltip_size.y - 52 < 0:
        %"Tool Tip".global_position.y = global_position.y + total_tooltip_size.y / 2.0
    else:
        %"Tool Tip".position.y = - %"Tool Tip".size.y - 52


func _on_click_mask_mouse_entered() -> void :
    is_highlighted = true
    %"Click Mask".grab_focus()


func _on_click_mask_mouse_exited() -> void :
    is_highlighted = false
    %"Click Mask".release_focus()


func _on_click_mask_focus_entered() -> void :

    is_highlighted = true


func _on_click_mask_focus_exited() -> void :
    is_highlighted = false
