extends CanvasLayer
class_name MiningCrtOverlay

const CRT_SHADER: Shader = preload("res://Games/Mining/UI/MiningCrt.gdshader")

var target_layer := 1

func configure(layer_index: int) -> MiningCrtOverlay:
	target_layer = layer_index
	layer = target_layer
	return self

func _ready() -> void:
	layer = target_layer
	process_mode = Node.PROCESS_MODE_ALWAYS

	var overlay := ColorRect.new()
	overlay.name = "ScreenFx"
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(1.0, 1.0, 1.0, 1.0)

	var material := ShaderMaterial.new()
	material.shader = CRT_SHADER
	overlay.material = material
	add_child(overlay)
