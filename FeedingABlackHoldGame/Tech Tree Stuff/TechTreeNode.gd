extends Node2D
class_name TechTreeNode

const PARTIAL_FILL_ALPHA: float = 0.42
const TOOLTIP_CLOSE_DELAY: float = 0.0
const COMPLETE_TOOLTIP_LIFETIME: float = 1.0
const TOOLTIP_VERTICAL_GAP: float = 0.0
const TOOLTIP_GROUP: StringName = &"tech_tree_tooltips"
static var _icon_texture_cache: Dictionary = {}

signal state_changed
signal selected(node: TechTreeNode)
signal unlocked(node: TechTreeNode)

@onready var custom_tween_component: CustomTweenComponent = $CustomTweenComponent
@onready var tooltip_custom_tween_component: CustomTweenComponent = $"Tooltip Pivot/Tooltip CustomTweenComponent"
@onready var partial_fill: Panel = %"Partial Fill"

@export var available_can_pay_stylebox: StyleBoxFlat
@export var available_can_not_pay_stylebox: StyleBoxFlat
@export var complete_stylebox: StyleBoxFlat
@export var shadow_stylebox: StyleBoxFlat
@export var clicked_stylebox: StyleBoxFlat

@export var locked_texture: Texture2D

@onready var click_mask: Button = %"Click Mask"

var completed_index = 0
var touch_buy_button: Button

enum STATES{LOCKED, AVAILABLE, COMPLETE, SHADOW}

var upgrade: Upgrade

var hover_focus_style_box: StyleBoxFlat
var cell
var is_center_node = false

var tech_tree: TechTree

var cost
var allow_complete_animation: bool = false
var is_complete_animating: bool = false

var _is_highlighted: bool = false
var is_hovering_node: bool = false
var is_hovering_tooltip: bool = false
var tooltip_close_timer: SceneTreeTimer
var complete_tooltip_timer: SceneTreeTimer
var tooltip_layout_request_id: int = 0
var tooltip_close_request_id: int = 0
var cached_node_hover_rect: Rect2 = Rect2()
var cached_tooltip_hover_rect: Rect2 = Rect2()
var node_hover_debug_overlay: ColorRect
var tooltip_hover_debug_overlay: ColorRect
var is_highlighted: bool:
    get:
        return _is_highlighted
    set(new_value):

        if _is_highlighted != new_value and new_value == true:
            _close_other_tooltips()
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)

            custom_tween_component.do_tween(1.0)
            tooltip_custom_tween_component.do_tween(1.0)
            selected.emit()
        elif new_value == false:
            custom_tween_component.kill_tweens()
            custom_tween_component.reset()

        _is_highlighted = new_value

        if tech_tree:
            tech_tree.selected_node = self
            var show_requirement_hint: bool = _is_highlighted and state == STATES.SHADOW
            tech_tree.set_requirement_hint_for(self, show_requirement_hint)

        _refresh_tooltip_visibility()







var _can_pay_cost: bool = false
var can_pay_cost: bool:
    get:
        return _can_pay_cost
    set(new_value):
        _can_pay_cost = new_value



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

var _state: STATES = STATES.LOCKED
var locked_requirement_highlighted: bool = false
var state: STATES:
    get:
        return _state
    set(new_state):
        var old_state = _state

        if is_epilgue_node() and Global.main and Global.main.epilogue == false:
            return

        if _state != new_state:
            if old_state == STATES.LOCKED and Global.game_state == Util.GAME_STATES.UPGRADES:
                do_pop_in()

            _state = new_state
            if tech_tree:
                if _state == STATES.COMPLETE:
                    completed_index = tech_tree.next_completed_index
                    tech_tree.next_completed_index += 1

                if _state == STATES.AVAILABLE:
                    tech_tree.active_nodes.append(self)
                elif tech_tree.active_nodes.has(self):
                    tech_tree.active_nodes.erase(self)




            if _state == STATES.AVAILABLE:

                if tech_tree:
                    tech_tree.call_deferred("update_connected_nodes_shadow", cell, 1)






            if _state == STATES.COMPLETE:
                if tech_tree:
                    tech_tree.call_deferred("update_connected_nodes_available", cell)

                unlocked.emit(self)

                if Global.game_state == Util.GAME_STATES.UPGRADES and allow_complete_animation:
                    is_complete_animating = true
                    %"Visual Panel".add_theme_stylebox_override("panel", clicked_stylebox)
                    clicked_stylebox.bg_color = Refs.get_act_light_color(upgrade.act if upgrade else 1)
                    clicked_stylebox.border_color = Refs.get_act_light_color(upgrade.act if upgrade else 1)
                    %"Visual Panel".scale = Vector2.ONE
                    %AnimationPlayer.play("On Complete")
                else:
                    is_complete_animating = false
                    on_complete_anim_finished()
                allow_complete_animation = false

            state_changed.emit(self)
            update()


var title_panel_style_box: StyleBoxFlat
var partial_fill_style_box: StyleBoxFlat

func _ready():
    add_to_group(TOOLTIP_GROUP)
    set_process(false)
    set_process_unhandled_input(false)
    _setup_hover_debug_overlays()
    hover_focus_style_box = %"Click Mask".get_theme_stylebox("hover")
    title_panel_style_box = %TitlePanel.get_theme_stylebox("panel")
    var base_fill_style: StyleBox = partial_fill.get_theme_stylebox("panel")
    if base_fill_style is StyleBoxFlat:
        partial_fill_style_box = (base_fill_style as StyleBoxFlat).duplicate(true)
    else:
        partial_fill_style_box = StyleBoxFlat.new()
    partial_fill_style_box.border_width_left = 0
    partial_fill_style_box.border_width_top = 0
    partial_fill_style_box.border_width_right = 0
    partial_fill_style_box.border_width_bottom = 0
    partial_fill.add_theme_stylebox_override("panel", partial_fill_style_box)
    SignalBus.pallet_updated.connect(update_colors)
    SignalBus.mod_changed.connect(_on_mod_changed)
    SignalBus.epilogue_started.connect(_on_epilogue_started)


    %"Tool Tip".pivot_offset = %"Tool Tip".size / 2.0
    _setup_touch_buy_button()

    SignalBus.settings_updated.connect(_on_settings_updated)

    %"Tool Tip".hide()

    var tooltip: Control = %"Tool Tip"
    _set_tooltip_mouse_filters(tooltip)
    if not tooltip.mouse_entered.is_connected(_on_tooltip_mouse_entered):
        tooltip.mouse_entered.connect(_on_tooltip_mouse_entered)
    if not tooltip.mouse_exited.is_connected(_on_tooltip_mouse_exited):
        tooltip.mouse_exited.connect(_on_tooltip_mouse_exited)

func _on_settings_updated():
    update()

func _process(_delta: float) -> void:
    if upgrade == null:
        return
    _update_hover_regions()
    var cursor_over_node: bool = _is_cursor_over_node_area()
    var cursor_over_tooltip: bool = _is_cursor_over_tooltip_area()
    if cursor_over_node != is_hovering_node:
        is_hovering_node = cursor_over_node
    if cursor_over_tooltip != is_hovering_tooltip:
        is_hovering_tooltip = cursor_over_tooltip
    if not %"Tool Tip".visible:
        return
    if %"Tool Tip".modulate.a < 1.0:
        return
    if not cursor_over_node and not cursor_over_tooltip:
        _force_close_tooltip()
    _refresh_runtime_tracking()

func _on_epilogue_started():
    if Global.main and Global.main.epilogue == true and upgrade and upgrade.epilogue == 1 and state != STATES.COMPLETE:
        state = STATES.AVAILABLE


func _on_mod_changed(type: Util.MODS, old_value, new_value):
    if upgrade and type == upgrade.mod:
        update()


func update_panel():
    if locked_requirement_highlighted:
        var base_style: StyleBox = %"Visual Panel".get_theme_stylebox("panel")
        var hint_style: StyleBoxFlat = StyleBoxFlat.new()
        if base_style is StyleBoxFlat:
            hint_style = (base_style as StyleBoxFlat).duplicate(true)
        hint_style.border_width_left = max(2, hint_style.border_width_left)
        hint_style.border_width_top = max(2, hint_style.border_width_top)
        hint_style.border_width_right = max(2, hint_style.border_width_right)
        hint_style.border_width_bottom = max(2, hint_style.border_width_bottom)
        hint_style.border_color = Color(1.0, 0.25, 0.25, 0.55)
        %"Visual Panel".add_theme_stylebox_override("panel", hint_style)
        return

    match state:
        STATES.SHADOW:
            %"Click Mask".modulate.a = 1.0
            %"Visual Panel".scale = Vector2.ONE
            %"Visual Panel".add_theme_stylebox_override("panel", shadow_stylebox)
        STATES.AVAILABLE:
            %"Click Mask".modulate.a = 1.0
            %"Visual Panel".scale = Vector2.ONE
            %Cost.add_theme_color_override("font_color", Refs.pallet.money_color if can_pay_cost else _get_theme_dark_color())

            %"Visual Panel".add_theme_stylebox_override("panel", available_can_pay_stylebox if can_pay_cost else available_can_not_pay_stylebox)

            if upgrade:
                title_panel_style_box.bg_color = Refs.get_act_light_color(upgrade.act) if can_pay_cost else _get_theme_dark_color()

            else:
                title_panel_style_box.bg_color = Refs.pallet.act_1_light if can_pay_cost else _get_theme_dark_color()

        STATES.COMPLETE:
            %Icon.show()
            %"Click Mask".modulate.a = 0

            if upgrade:
                title_panel_style_box.bg_color = Refs.get_act_dark_color(upgrade.act)

            if is_complete_animating:
                return

            %"Visual Panel".add_theme_stylebox_override("panel", complete_stylebox)
            %"Visual Panel".scale = Vector2.ZERO


func on_complete_anim_finished():
    is_complete_animating = false
    %"Mod Icon".modulate = Refs.pallet.shadow
    %"Visual Panel".add_theme_stylebox_override("panel", complete_stylebox)
    %"Visual Panel".scale = Vector2.ZERO
    %"Mod Icon".scale = Vector2(0.44, 0.44)

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
    %Cost.add_theme_color_override("font_color", Refs.pallet.money_color if can_pay_cost else _get_theme_dark_color())
    %Cost.add_theme_font_override("font", Refs.money_font)



    %Tier.add_theme_color_override("font_color", Refs.pallet.black_hole_dark)
    %"Is Max".add_theme_color_override("font_color", Refs.pallet.green)


    if upgrade:
        %Icon.self_modulate = Refs.get_act_light_color(upgrade.act)

    _update_partial_fill_visual()




func _on_click_mask_pressed() -> void :
    if state == STATES.AVAILABLE and can_pay_cost == true:
        if SaveHandler.touch_input_mode:
            is_highlighted = true
            %"Click Mask".grab_focus()
            update()
            return
        _purchase_upgrade()

func _purchase_upgrade() -> void:
    if state != STATES.AVAILABLE or not can_pay_cost:
        return
    Global.global_resoruce_manager.change_resource_by_type(Util.RESOURCE_TYPES.MONEY, - cost)

    custom_tween_component.do_rotation = true
    custom_tween_component.do_tween(1.0)
    tooltip_custom_tween_component.do_tween(1.0)

    upgrade.current_tier += 1
    if upgrade.sim_name != "" and upgrade.current_tier >= 1 and tech_tree:
        tech_tree.call_deferred("update_connected_nodes_available", cell)
    if upgrade.is_at_max():
        allow_complete_animation = true
        state = STATES.COMPLETE
    state_changed.emit(self)
    update()

    if Global.main and Global.main.upgrade_screen:
        Global.main.upgrade_screen.on_node_unlocked(self)

    if upgrade != null and upgrade.sim_key != "":
        var new_amount: int = int(Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY))
        SaveHandler.fishing_currency = max(0, new_amount)
        var target_level: int = int(upgrade.sim_level) + int(upgrade.current_tier) - 1
        SaveHandler.set_fishing_upgrade_level(upgrade.sim_key, max(1, target_level))
        SaveHandler.save_fishing_progress()

    SaveHandler.save_player_last_run()

func _setup_touch_buy_button() -> void:
    var container: VBoxContainer = %"Tool Tip".get_node_or_null("MarginContainer/VBoxContainer")
    if container == null:
        return
    touch_buy_button = Button.new()
    touch_buy_button.name = "TouchBuyButton"
    touch_buy_button.text = "BUY"
    touch_buy_button.focus_mode = Control.FOCUS_NONE
    touch_buy_button.custom_minimum_size = Vector2(0, 112)
    touch_buy_button.visible = false
    touch_buy_button.pressed.connect(_on_touch_buy_button_pressed)
    container.add_child(touch_buy_button)

func _on_touch_buy_button_pressed() -> void:
    _purchase_upgrade()

func set_locked_requirement_highlight(active: bool) -> void:
    locked_requirement_highlighted = active
    update_panel()

func _get_unlock_requirement_text() -> String:
    if tech_tree == null:
        return ""
    var required_node: TechTreeNode = tech_tree.get_unlock_requirement_node(cell)
    if required_node == null:
        return ""
    if required_node.upgrade == null:
        return ""
    var required_name: String = required_node.upgrade.sim_name.strip_edges()
    if required_name == "":
        required_name = "the required upgrade"
    return "LOCKED: Requires %s." % required_name

func unlock_node(target_tier = 1):
    if upgrade:
        for i in range(max(0, target_tier - upgrade.current_tier)):
            upgrade.current_tier += 1
        if upgrade.is_at_max():
            state = STATES.COMPLETE
        state_changed.emit(self)
    update()

func get_visual_progress_ratio() -> float:
    if upgrade == null:
        return 1.0 if state == STATES.COMPLETE else 0.0
    if upgrade.max_tier <= 1:
        return 1.0 if state == STATES.COMPLETE else 0.0
    if upgrade.current_tier <= 0:
        return 0.0
    if upgrade.current_tier >= upgrade.max_tier:
        return 1.0
    return clamp(
        0.5 + (0.5 * (float(upgrade.current_tier - 1) / float(upgrade.max_tier - 1))),
        0.0,
        1.0
    )

func _update_partial_fill_visual() -> void:
    if partial_fill == null:
        return

    var progress: float = get_visual_progress_ratio()
    var should_show: bool = not is_center_node \
        and state == STATES.AVAILABLE \
        and upgrade != null \
        and upgrade.max_tier > 1 \
        and not upgrade.is_at_max() \
        and progress > 0.0

    partial_fill.visible = should_show
    if not should_show:
        partial_fill.scale = Vector2.ONE
        return

    var fill_color: Color = Refs.get_act_light_color(upgrade.act)
    fill_color.a = PARTIAL_FILL_ALPHA
    partial_fill_style_box.bg_color = fill_color
    partial_fill.scale = Vector2(clamp(progress, 0.0, 1.0), 1.0)



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

    %"Shadow Icon".hide()
    %"Random Icon".hide()
    %"Mod Icon".hide()
    %TitlePanel.show()
    %"Upgrade Amount".show()

    var using_sim_display: bool = upgrade != null and upgrade.sim_name != ""
    var sim_effect_text: String = ""
    if using_sim_display:
        sim_effect_text = upgrade.sim_description.strip_edges()
        if sim_effect_text == "":
            sim_effect_text = "Upgrade effect applied on unlock."
    if using_sim_display:
        %Description.text = "%s\n%s" % [upgrade.sim_name, sim_effect_text]
        %"Node Type".text = _get_sim_icon_fallback_text()
        %"Upgrade Amount".text = "UNLOCK"
    else:
        %"Node Type".text = tr(Util.MODS.find_key(upgrade.mod))

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
        if using_sim_display:
            %Description.text = "%s\n%s" % [upgrade.sim_name, sim_effect_text]
            %"Upgrade Amount".text = "UNLOCKED"
        else:
            %Description.text = str("Currently: ", Global.mods.get_mod_value(upgrade.mod, Global.mods.get_mod(upgrade.mod)))
            %"Upgrade Amount".text = str("$", Util.get_number_short_text(upgrade.get_cost()), " : ", Global.mods.get_mod_value(upgrade.mod, upgrade.get_current_teir_value(), true))
        %"Mod Icon".texture = _get_upgrade_icon_texture()
    else:

        %"Cost Hbox".show()

        %HSeparator2.show()

        if upgrade.has_tiers():
            %Tier.show()

            %Tier.text = "{CURRENT_TIER}/{MAX_TIER}".format({
                "CURRENT_TIER": str(upgrade.current_tier + 1), 
                "MAX_TIER": str(upgrade.max_tier)
            })

        if using_sim_display:
            %Description.text = "%s\n%s" % [upgrade.sim_name, sim_effect_text]
            %"Upgrade Amount".text = "UNLOCK"
        else:
            %Description.text = Global.mods.get_from_to(upgrade.mod, upgrade.get_current_teir_value())
            %"Upgrade Amount".text = str(Global.mods.get_mod_value(upgrade.mod, upgrade.get_current_teir_value(), true))
        %"Mod Icon".texture = _get_upgrade_icon_texture()


    cost = upgrade.get_cost()
    %Cost.visible = cost != 0
    %Cost.text = str("$", Util.get_number_short_text(cost))
    if cost == 0:
        %HSeparator2.hide()

    update_can_pay_cost()

    if state == STATES.AVAILABLE and can_pay_cost == true:
        %"Click Mask".disabled = false
    elif state == STATES.SHADOW or state == STATES.COMPLETE:
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
            %"Click Mask".show()
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
            %"Click Mask".show()
            show()

    _update_touch_buy_button()
    keep_tooltip_on_screen( %"Tool Tip")

    update_colors()
    update_panel()

func _update_touch_buy_button() -> void:
    if touch_buy_button == null:
        return
    var show_touch_buy: bool = _is_highlighted \
        and state == STATES.AVAILABLE \
        and can_pay_cost \
        and upgrade != null \
        and upgrade.type != Util.NODE_TYPES.ROGUELIKE_DUMMY
    touch_buy_button.visible = show_touch_buy
    touch_buy_button.disabled = not show_touch_buy

func _refresh_tooltip_visibility() -> void:
    var tooltip: Control = %"Tool Tip"
    var should_show: bool = _can_show_tooltip()
    _cancel_complete_tooltip_expire()
    _update_touch_buy_button()
    if not should_show:
        tooltip.modulate.a = 1.0
        tooltip.hide()
        cached_tooltip_hover_rect = Rect2()
        _update_hover_regions()
        _refresh_popup_priority_locks()
        _refresh_runtime_tracking()
        return
    tooltip.show()
    _position_tooltip()
    tooltip.pivot_offset = tooltip.size / 2.0
    _refresh_hover_debug_overlays()
    tooltip.modulate.a = 1.0
    _update_hover_regions()
    _refresh_popup_priority_locks()
    _refresh_runtime_tracking()



func update_can_pay_cost():
    var check = true
    if cost > Global.global_resoruce_manager.get_resource_amount_by_type(Util.RESOURCE_TYPES.MONEY):
        check = false

    if upgrade and upgrade.demo_locked == 1:
        check = false

    %Cost.add_theme_color_override("font_color", Refs.pallet.green if check else _get_theme_dark_color())

    can_pay_cost = check

func _get_theme_dark_color() -> Color:
    if upgrade != null:
        return Refs.get_act_dark_color(upgrade.act)
    return Refs.pallet.act_1_dark

func _is_texture_icon_path(icon_value: String) -> bool:
    var trimmed: String = icon_value.strip_edges()
    if trimmed == "":
        return false
    var lower: String = trimmed.to_lower()
    return lower.begins_with("res://") \
        or lower.ends_with(".png") \
        or lower.ends_with(".svg") \
        or lower.ends_with(".webp") \
        or lower.ends_with(".jpg") \
        or lower.ends_with(".jpeg")

func _get_upgrade_icon_texture() -> Texture2D:
    if upgrade != null and upgrade.sim_icon != "":
        if _is_texture_icon_path(upgrade.sim_icon):
            if _icon_texture_cache.has(upgrade.sim_icon):
                return _icon_texture_cache[upgrade.sim_icon]
            var loaded: Resource = load(upgrade.sim_icon)
            if loaded is Texture2D:
                _icon_texture_cache[upgrade.sim_icon] = loaded
                return loaded
    return Refs.mod_textures.get(upgrade.mod, null)

func _get_sim_icon_fallback_text() -> String:
    if upgrade == null:
        return ""
    if upgrade.sim_icon != "" and !_is_texture_icon_path(upgrade.sim_icon):
        return upgrade.sim_icon.substr(0, 1)
    if upgrade.sim_name != "":
        return upgrade.sim_name.substr(0, 1)
    return ""


func keep_tooltip_on_screen(control_node: Control):
    _position_tooltip()

func _position_tooltip() -> void:
    %"Tool Tip".reset_size()

    var total_tooltip_size = Vector2( %"Tool Tip".size.x, %"Tool Tip".size.y + %TitlePanel.size.y - 22)


    %"Tool Tip".position.x = - total_tooltip_size.x / 2.0



    if Util.get_node2d_viewport_position(self, Global.main.camera_2d).y - total_tooltip_size.y - TOOLTIP_VERTICAL_GAP < 0:
        %"Tool Tip".position.y = 35.0 + TOOLTIP_VERTICAL_GAP
    else:
        %"Tool Tip".position.y = - %"Tool Tip".size.y - TOOLTIP_VERTICAL_GAP

func _queue_tooltip_close() -> void:
    if _is_cursor_over_any_tooltip_or_node():
        return
    if TOOLTIP_CLOSE_DELAY <= 0.0:
        tooltip_close_request_id += 1
        call_deferred("_close_tooltips_if_still_outside", tooltip_close_request_id)
        return
    var timer: SceneTreeTimer = get_tree().create_timer(TOOLTIP_CLOSE_DELAY)
    tooltip_close_timer = timer
    await timer.timeout
    if tooltip_close_timer != timer:
        return
    tooltip_close_timer = null
    is_hovering_tooltip = _is_cursor_over_tooltip()
    if not _is_cursor_over_any_tooltip_or_node():
        _close_all_tooltips()

func _cancel_tooltip_close() -> void:
    tooltip_close_timer = null
    tooltip_close_request_id += 1

func _close_tooltips_if_still_outside(request_id: int) -> void:
    if request_id != tooltip_close_request_id:
        return
    _update_hover_regions()
    is_hovering_node = _is_cursor_over_node_area()
    is_hovering_tooltip = _is_cursor_over_tooltip_area()
    if not is_hovering_node and not is_hovering_tooltip:
        _close_all_tooltips()

func _queue_complete_tooltip_expire() -> void:
    pass

func _cancel_complete_tooltip_expire() -> void:
    complete_tooltip_timer = null

func _can_show_tooltip() -> bool:
    if upgrade == null or not _is_highlighted:
        return false
    return state == STATES.AVAILABLE or state == STATES.COMPLETE

func _is_unlocked_node_popup() -> bool:
    return upgrade != null and upgrade.is_at_max()

func _set_tooltip_mouse_filters(root: Control) -> void:
    if root == null:
        return
    root.mouse_filter = Control.MOUSE_FILTER_STOP
    for child: Node in root.get_children():
        if child is Control:
            _set_tooltip_mouse_filters(child as Control)

func _is_cursor_over_tooltip() -> bool:
    var hovered: Control = get_viewport().gui_get_hovered_control()
    while hovered != null:
        if hovered == %"Tool Tip":
            return true
        hovered = hovered.get_parent() as Control
    return false

func _is_cursor_over_click_mask() -> bool:
    var hovered: Control = get_viewport().gui_get_hovered_control()
    while hovered != null:
        if hovered == %"Click Mask":
            return true
        hovered = hovered.get_parent() as Control
    return false

func _is_cursor_over_tooltip_area() -> bool:
    return %"Tool Tip".visible and (_is_cursor_over_tooltip() or _point_in_control_rect(%"Tool Tip", get_viewport().get_mouse_position()))

func _is_cursor_over_node_area() -> bool:
    return _is_cursor_over_click_mask() or cached_node_hover_rect.has_point(get_viewport().get_mouse_position())

func _is_any_tooltip_hovered_by_cursor() -> bool:
    return _get_tooltip_owner_at_screen_position(get_viewport().get_mouse_position()) != null

func _get_hover_locked_tooltip_owner() -> TechTreeNode:
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node is TechTreeNode:
            var tech_node: TechTreeNode = node as TechTreeNode
            if tech_node._is_highlighted and (tech_node.is_hovering_tooltip or tech_node._is_cursor_over_tooltip()):
                return tech_node
    return null

func _get_active_tooltip_owner() -> TechTreeNode:
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node is TechTreeNode:
            var tech_node: TechTreeNode = node as TechTreeNode
            if tech_node._is_highlighted and tech_node.get_node("%Tool Tip").visible:
                return tech_node
    return null

func _refresh_popup_priority_locks() -> void:
    var active_tooltip_owner: TechTreeNode = _get_active_tooltip_owner()
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node is TechTreeNode:
            var tech_node: TechTreeNode = node as TechTreeNode
            tech_node._set_popup_priority_lock(active_tooltip_owner)

func _set_popup_priority_lock(active_tooltip_owner: TechTreeNode) -> void:
    if click_mask == null:
        return
    click_mask.mouse_filter = Control.MOUSE_FILTER_STOP if active_tooltip_owner == null or active_tooltip_owner == self else Control.MOUSE_FILTER_IGNORE

func _get_tooltip_owner_at_screen_position(screen_position: Vector2) -> TechTreeNode:
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node is TechTreeNode:
            var tech_node: TechTreeNode = node as TechTreeNode
            if tech_node._is_point_inside_tooltip(screen_position):
                return tech_node
    return null

func _is_point_inside_tooltip(screen_position: Vector2) -> bool:
    return %"Tool Tip".visible and _point_in_control_rect(%"Tool Tip", screen_position)

func _is_cursor_over_any_tooltip_or_node() -> bool:
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node is TechTreeNode:
            var tech_node: TechTreeNode = node as TechTreeNode
            if tech_node._is_cursor_over_node_area() or tech_node._is_cursor_over_tooltip_area():
                return true
    return false

func _close_other_tooltips() -> void:
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node == self:
            continue
        if node is TechTreeNode:
            (node as TechTreeNode)._force_close_tooltip()

func _close_all_tooltips() -> void:
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node is TechTreeNode:
            (node as TechTreeNode)._force_close_tooltip()

func _force_close_tooltip() -> void:
    is_hovering_node = false
    is_hovering_tooltip = false
    _cancel_tooltip_close()
    _cancel_complete_tooltip_expire()
    tooltip_layout_request_id += 1
    _is_highlighted = false
    %"Tool Tip".modulate.a = 1.0
    %"Tool Tip".hide()
    _update_hover_regions()
    if tech_tree and tech_tree.selected_node == self:
        tech_tree.selected_node = null
        tech_tree.set_requirement_hint_for(self, false)
    %"Click Mask".release_focus()
    _update_touch_buy_button()
    _refresh_popup_priority_locks()
    _refresh_runtime_tracking()

func _refresh_runtime_tracking() -> void:
    var keep_tracking: bool = _is_highlighted or %"Tool Tip".visible or is_hovering_node or is_hovering_tooltip
    set_process(keep_tracking)
    set_process_unhandled_input(keep_tracking)

func _unhandled_input(event: InputEvent) -> void:
    if not _is_any_tooltip_open():
        return
    if event is InputEventMouseButton:
        var mouse_event: InputEventMouseButton = event as InputEventMouseButton
        if mouse_event.pressed:
            _close_all_tooltips_if_press_outside(mouse_event.position)
    elif event is InputEventScreenTouch:
        var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
        if touch_event.pressed:
            _close_all_tooltips_if_press_outside(touch_event.position)

func _close_all_tooltips_if_press_outside(screen_position: Vector2) -> void:
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node is TechTreeNode:
            var tech_node: TechTreeNode = node as TechTreeNode
            if tech_node._contains_screen_position(screen_position):
                return
    _close_all_tooltips()

func _contains_screen_position(screen_position: Vector2) -> bool:
    if _point_in_control_rect(%"Click Mask", screen_position):
        return true
    if %"Tool Tip".visible and _point_in_control_rect(%"Tool Tip", screen_position):
        return true
    return false

func _point_in_control_rect(control: Control, screen_position: Vector2) -> bool:
    if control == null or not is_instance_valid(control) or not control.visible:
        return false
    return control.get_global_rect().has_point(screen_position)

func _setup_hover_debug_overlays() -> void:
    node_hover_debug_overlay = ColorRect.new()
    node_hover_debug_overlay.name = "NodeHoverDebugOverlay"
    node_hover_debug_overlay.top_level = true
    node_hover_debug_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    node_hover_debug_overlay.color = Color(0.15, 0.85, 0.35, 0.18)
    node_hover_debug_overlay.visible = false
    add_child(node_hover_debug_overlay)

    tooltip_hover_debug_overlay = ColorRect.new()
    tooltip_hover_debug_overlay.name = "TooltipHoverDebugOverlay"
    tooltip_hover_debug_overlay.top_level = true
    tooltip_hover_debug_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tooltip_hover_debug_overlay.color = Color(0.2, 0.45, 1.0, 0.18)
    tooltip_hover_debug_overlay.visible = false
    add_child(tooltip_hover_debug_overlay)

func _update_hover_regions() -> void:
    if click_mask != null and is_instance_valid(click_mask) and click_mask.visible:
        cached_node_hover_rect = click_mask.get_global_rect()
    else:
        cached_node_hover_rect = Rect2()

    if %"Tool Tip".visible:
        cached_tooltip_hover_rect = %"Tool Tip".get_global_rect()
    else:
        cached_tooltip_hover_rect = Rect2()

    _refresh_hover_debug_overlays()

func _refresh_hover_debug_overlays() -> void:
    if node_hover_debug_overlay != null:
        node_hover_debug_overlay.visible = _is_highlighted
        if node_hover_debug_overlay.visible:
            node_hover_debug_overlay.global_position = cached_node_hover_rect.position
            node_hover_debug_overlay.size = cached_node_hover_rect.size

    if tooltip_hover_debug_overlay != null:
        tooltip_hover_debug_overlay.visible = %"Tool Tip".visible
        if tooltip_hover_debug_overlay.visible:
            tooltip_hover_debug_overlay.global_position = cached_tooltip_hover_rect.position
            tooltip_hover_debug_overlay.size = cached_tooltip_hover_rect.size

func _is_any_tooltip_open() -> bool:
    for node: Node in get_tree().get_nodes_in_group(TOOLTIP_GROUP):
        if node is TechTreeNode:
            var tech_node: TechTreeNode = node as TechTreeNode
            if tech_node.get_node("%Tool Tip").visible:
                return true
    return false

func _on_tooltip_mouse_entered() -> void:
    is_hovering_tooltip = true
    _cancel_tooltip_close()
    is_highlighted = true

func _on_tooltip_mouse_exited() -> void:
    is_hovering_tooltip = _is_cursor_over_tooltip()


func _on_click_mask_mouse_entered() -> void :
    if is_hovering_node and _is_highlighted:
        return
    var tooltip_owner_under_cursor: TechTreeNode = _get_tooltip_owner_at_screen_position(get_viewport().get_mouse_position())
    if tooltip_owner_under_cursor != null and tooltip_owner_under_cursor != self:
        return
    var active_tooltip_owner: TechTreeNode = _get_active_tooltip_owner()
    if active_tooltip_owner != null and active_tooltip_owner != self:
        return
    var locked_tooltip_owner: TechTreeNode = _get_hover_locked_tooltip_owner()
    if locked_tooltip_owner != null and locked_tooltip_owner != self:
        return
    is_hovering_node = true
    _cancel_tooltip_close()
    is_highlighted = true
    %"Click Mask".grab_focus()


func _on_click_mask_mouse_exited() -> void :
    if _is_cursor_over_click_mask():
        return
    is_hovering_node = false


func _on_click_mask_focus_entered() -> void :
    var tooltip_owner_under_cursor: TechTreeNode = _get_tooltip_owner_at_screen_position(get_viewport().get_mouse_position())
    if tooltip_owner_under_cursor != null and tooltip_owner_under_cursor != self:
        return
    var active_tooltip_owner: TechTreeNode = _get_active_tooltip_owner()
    if active_tooltip_owner != null and active_tooltip_owner != self:
        return
    var locked_tooltip_owner: TechTreeNode = _get_hover_locked_tooltip_owner()
    if locked_tooltip_owner != null and locked_tooltip_owner != self:
        return

    _cancel_tooltip_close()
    is_highlighted = true


func _on_click_mask_focus_exited() -> void :
    pass
