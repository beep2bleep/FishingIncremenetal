extends RefCounted
## Presentation only: the shared launcher, settings and upgrade scenes remain authoritative.
const BODY = preload("res://Theme/Poppins-Regular.ttf")
const HEADING = preload("res://Theme/Exo2-Bold.ttf")
const MONO = preload("res://Theme/RobotoMono-SemiBold.ttf")
const GOLD = Color("eec782")
const INK = Color("111923")

static func panel(color = Color("182430"), border = Color("425365")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style

static func button_feedback(button: BaseButton) -> void:
	if button is CustomButton:
		var motion := button.get_node_or_null("CustomTweenComponent") as CustomTweenComponent
		if motion != null:
			motion.do_scale = true
			motion.do_rotation = true
			motion.rotation_amount = 3.0
		return
	if button.has_node("RailwayButtonFeedback"): return
	var feedback := preload("res://Games/RowDivers/RowDiversButtonFeedback.gd").new()
	feedback.name = "RailwayButtonFeedback"
	button.add_child(feedback)

static func apply_fonts(node: Node) -> void:
	if node is BaseButton: button_feedback(node)
	if node is Label or node is BaseButton or node is LineEdit or node is OptionButton:
		node.add_theme_font_override("font", HEADING if node is BaseButton else BODY)
	if node is RichTextLabel:
		node.add_theme_font_override("normal_font", BODY)
		node.add_theme_font_override("bold_font", HEADING)
	for child in node.get_children():
		apply_fonts(child)

static func style_button(button: Button) -> void:
	button_feedback(button)
	button.add_theme_font_override("font", HEADING)
	button.add_theme_font_size_override("font_size", 20)
	button.set_meta("railway_font_size", 20)
	button.add_theme_color_override("font_color", Color("f2e4ce"))
	button.add_theme_stylebox_override("normal", panel())
	button.add_theme_stylebox_override("hover", panel(Color("2c4050"), GOLD))
	button.add_theme_stylebox_override("pressed", panel(Color("3c4c55"), GOLD))
	button.add_theme_stylebox_override("focus", panel(Color(0, 0, 0, 0), GOLD))
	button.add_theme_stylebox_override("disabled", panel(Color("141b24"), Color("26313f")))

static func label(text: String, font_size = 20, heading = false) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_override("font", HEADING if heading else BODY)
	result.add_theme_font_size_override("font_size", font_size)
	result.set_meta("railway_font_size", font_size)
	result.add_theme_color_override("font_color", Color("eee5d7"))
	return result

static func scale_fonts(node: Node) -> void:
	if node is Control and node.has_meta("railway_font_size"):
		node.add_theme_font_size_override("font_size", maxi(10, roundi(float(node.get_meta("railway_font_size")) * SaveHandler.text_scale)))
	for child in node.get_children(): scale_fonts(child)

static func bar(color: Color) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = color
	result.set_corner_radius_all(4)
	return result
