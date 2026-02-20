extends PanelContainer

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

func _on_mouse_entered() -> void :
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)
    is_highlighted = true

    pivot_offset = size / 2.0
    custom_tween_component.do_tween(0.5)


func _on_mouse_exited() -> void :
    is_highlighted = false
