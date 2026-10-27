extends Node
## Reuses the project's grow/tilt tween and UI audio for plain runtime buttons.
var button: BaseButton
var motion: CustomTweenComponent

func _ready() -> void:
	button = get_parent() as BaseButton
	motion = CustomTweenComponent.new()
	motion.base_node = button
	motion.do_scale = true
	motion.scale_amount = Vector2(1.06, 1.06)
	motion.do_rotation = not bool(button.get_meta("railway_no_hover_rotation", false))
	motion.rotation_amount = 3.0
	motion.scale_hover_to_width = true
	add_child(motion)
	button.mouse_entered.connect(_hover)
	button.focus_entered.connect(_hover)
	button.pressed.connect(_pressed)

func _hover() -> void:
	if not is_inside_tree() or not is_instance_valid(button) or not button.is_inside_tree() or button.disabled: return
	button.pivot_offset = button.size * 0.5
	motion.do_tween(0)
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.TECH_TREE_NODE_HOVER)

func _pressed() -> void:
	# The action connected before this feedback can remove the whole screen.
	if not is_inside_tree() or not is_instance_valid(button) or not button.is_inside_tree(): return
	button.pivot_offset = button.size * 0.5
	motion.do_tween(0)
	AudioManager.create_audio(SoundEffectSettings.SOUND_EFFECT_TYPE.BUTTON_CLICK)
