extends Button
class_name CustomButton

@onready var custom_tween_component: CustomTweenComponent = $CustomTweenComponent

@export var enable_on_focus = false
@export var glyph_comp: ControllerGlyph

var highlighted = false:
    set(new_value):
        if highlighted == false and new_value == true:
            AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)
            pivot_offset = size / 2.0
            custom_tween_component.do_tween(0.5)

        highlighted = new_value

func _on_pressed() -> void :
    AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)

func _on_mouse_entered() -> void :
    highlighted = true

func _on_mouse_exited() -> void :
    highlighted = false
    release_focus()

func _on_focus_entered() -> void :
    highlighted = true
    if enable_on_focus and glyph_comp != null:
        glyph_comp.enabled = true

func _on_focus_exited() -> void :
    highlighted = false
    if glyph_comp != null:
        glyph_comp.enabled = false
