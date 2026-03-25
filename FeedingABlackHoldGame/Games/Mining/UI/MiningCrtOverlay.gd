extends CanvasLayer
class_name MiningCrtOverlay

const CRT_SHADER: Shader = preload("res://Games/Mining/UI/MiningCrt.gdshader")

func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS

	var overlay := ColorRect.new()
	overlay.name = "ScreenFx"
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(1.0, 1.0, 1.0, 1.0)

	var material := ShaderMaterial.new()
	material.shader = CRT_SHADER
	overlay.material = material
	add_child(overlay)
