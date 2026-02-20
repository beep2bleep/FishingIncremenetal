extends PanelContainer
class_name ResourceGainedSummary

var money_gained = 0
var resource_gained = 0

@export var is_total: bool = false
@export var demo_locked: bool = false


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

func setup(resoruce_type: Util.RESOURCE_TYPES, _resource_gained: int, _money_gain: int):
    money_gained = _money_gain
    resource_gained = _resource_gained

    %Icon.texture = Refs.get_resource_icon_small_by_type(resoruce_type)
    %"Resource Value".text = str(Util.get_number_short_text(_resource_gained))



    %"Stat Name".text = Util.RESOURCE_TYPES.find_key(resoruce_type)
    %MONEY.text = str("$0")

    if is_total == true:

        %Icon.hide()
        %TYPE.text = "TOTAL"
        %"Stat Name".text = "MONEY_EARNED_THIS_SESSION"
        %TYPE.show()

    if demo_locked == true:

        %TYPE.text = "???"

        %MONEY.hide()
        %"Demo Locked Icon".show()




var tween
func do_animation(duration):
    if tween != null and tween.is_running():
        tween.kill()

    tween = create_tween()
    tween.tween_callback( func(): %AudioStreamPlayer.play())
    tween.set_parallel(true)
    tween.tween_method(count, 0, money_gained, duration)

    tween.set_parallel(false)
    tween.tween_callback( func(): %AudioStreamPlayer.stop())


func count(given_number):
    %MONEY.text = str("$", Util.get_number_short_text(given_number))


func _on_mouse_entered() -> void :
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)
    is_highlighted = true

    pivot_offset = size / 2.0
    custom_tween_component.do_tween(0.5)


func _on_mouse_exited() -> void :
    is_highlighted = false
