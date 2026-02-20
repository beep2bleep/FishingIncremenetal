extends PanelContainer
class_name GameModePanel

var game_mode_data: GameModeData

var index = 0
var base_min_size

signal selected(index)

var is_active = false:
    set(new_value):

        if is_active == false and new_value == true:
            $AudioStreamPlayer.play()

        is_active = new_value








        update()


func _on_settings_updated_changed():
    custom_minimum_size.x = base_min_size.x * SaveHandler.text_scale


func _ready() -> void :
    base_min_size = custom_minimum_size
    SignalBus.pallet_updated.connect(update_color)

    SignalBus.settings_updated.connect(_on_settings_updated_changed)
    _on_settings_updated_changed()


func setup(_game_mode_data: GameModeData):
    game_mode_data = _game_mode_data
    update()

func update_color():





    var dark_accent_color = game_mode_data.accent_color
    dark_accent_color.v *= 0.67

    %"Top PanelContainer".get_theme_stylebox("panel").bg_color = game_mode_data.accent_color
    %"Bottom PanelContainer".get_theme_stylebox("panel").bg_color = Refs.pallet.game_modes_panel_color

    %"Mode Icon".modulate = dark_accent_color
    %Name.modulate = dark_accent_color

    %"Description".modulate = Refs.pallet.game_modes_text_color
    %"Trophy Icon".modulate = game_mode_data.accent_color
    %"Best Time".modulate = Refs.pallet.game_modes_text_color
    %Circle.modulate = game_mode_data.accent_color







func update():
    update_color()



    if game_mode_data == null:
        return

    %"Coming Soon Date".hide()

    %Beta.hide()


    %"Mode Icon".texture = game_mode_data.icon
    %Name.text = game_mode_data.name_key
    %Description.text = game_mode_data.description_key

    %Completed.hide()

    %Description.show()


    if ProjectSettings.get_setting("global/Demo") == true:
        if game_mode_data.is_for_demo == false:
            %"Coming Soon Date".show()
            if game_mode_data.coming_soon == true:
                %"Coming Soon Date".text = str(tr("DEMO_LOCKED"), " \n", game_mode_data.get_coming_soon_text())
            else:
                %"Coming Soon Date".text = "DEMO_LOCKED"
            %Description.hide()
        else:
            %"Coming Soon Date".hide()

    elif game_mode_data.coming_soon == true:

        %"Coming Soon Date".show()
        %"Coming Soon Date".text = game_mode_data.get_coming_soon_text()

        if game_mode_data.is_beta == true:
            %Beta.show()
            %Description.show()
            %Description.text = "IN_BETA_TESTING"
        else:
            %Description.hide()


    elif game_mode_data.game_mode != Util.GAME_MODES.MAIN and SaveHandler.has_beated_main_mode() == false:
        %"Description".text = "COMPLETE_MAIN_MODE_TO_UNLOCK"
        %Beta.visible = game_mode_data.is_beta

    else:
        if SaveHandler.progression_data.has(game_mode_data.game_mode):
            var data = SaveHandler.progression_data[game_mode_data.game_mode]
            if data.COMPLETED == true:
                %"Best Time".text = Util.format_time(float(data.TIME))
                %Completed.show()

        %Beta.visible = game_mode_data.is_beta





func _on_resized() -> void :
    pivot_offset = Vector2(size.x / 2.0, size.y * 0.85)


func _on_button_pressed() -> void :
    selected.emit(index)
