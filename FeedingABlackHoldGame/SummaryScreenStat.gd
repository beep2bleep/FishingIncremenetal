extends PanelContainer
class_name SummaryScreenStat

@export var normal_panel: StyleBox
@export var highlight_panel: StyleBox

@onready var custom_tween_component: CustomTweenComponent = %CustomTweenComponent


var is_highlighted:
    set(new_value):
        is_highlighted = new_value
        add_theme_stylebox_override("panel", highlight_panel if is_highlighted else normal_panel)
        %ToolTip.visible = is_highlighted

func _ready():
    %ToolTip.hide()
    is_highlighted = false

func setup(value, icon: Texture2D, name: String, intify = true, is_money = false, red = false):

    if is_money:
        %"Stat Value".text = str("$", Util.get_number_short_text(value, intify))
    else:
        %"Stat Value".text = str(Util.get_number_short_text(value, intify), )
    %"State Icon".texture = icon
    %"Stat Name".text = name

    %"State Icon".modulate = Refs.pallet.text_red if red else Color.WHITE
    %"Stat Value".modulate = Refs.pallet.text_red if red else Color.WHITE


    if value <= 0:
        hide()
    else:
        show()


func _on_mouse_entered() -> void :

    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)
    is_highlighted = true

    pivot_offset = size / 2.0
    custom_tween_component.do_tween(0.5)


func _on_mouse_exited() -> void :
    is_highlighted = false
