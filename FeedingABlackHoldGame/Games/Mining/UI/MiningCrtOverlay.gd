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
	if OS.has_feature("web"):
		# The mining scene now carries more of the web perf budget, so keep the CRT
		# close to the original look instead of forcing the single-sample fallback.
		material.set_shader_parameter("fast_mode", false)
		material.set_shader_parameter("target_vertical_resolution", 320.0)
		material.set_shader_parameter("barrel_distortion", 0.052)
		material.set_shader_parameter("scanline_strength", 0.18)
		material.set_shader_parameter("grille_strength", 0.08)
		material.set_shader_parameter("vignette_strength", 0.37)
		material.set_shader_parameter("noise_strength", 0.012)
		material.set_shader_parameter("chroma_offset", 0.52)
	overlay.material = material
	add_child(overlay)
