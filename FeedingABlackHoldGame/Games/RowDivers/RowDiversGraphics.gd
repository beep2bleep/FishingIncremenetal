extends RefCounted
## Optional original source artwork; presentation only, never combat bounds/stats.
const ROOT = "res://Games/RowDivers/Art/Original/"
const ENEMIES = ["Enemy1.png", "Enemy2.png", "Enemy3.png", "Enemy4.png", "MiniBoss.png", "MiniBoss2.png", "Boss.png"]
static var textures: Dictionary = {}
static var manifest: Dictionary = {}

static func original() -> bool:
	return SaveHandler.row_divers_original_graphics

static func illustrated() -> bool:
	return original() and SaveHandler.row_divers_illustrated_graphics

static func mode() -> int:
	return 2 if illustrated() else 1 if original() else 0

static func select_mode(index: int) -> void:
	SaveHandler.row_divers_original_graphics = index != 0
	SaveHandler.row_divers_illustrated_graphics = index == 2

static func catalog() -> Dictionary:
	if manifest.is_empty(): manifest = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "manifest.json"))
	return manifest

static func texture(name: String) -> Texture2D:
	if illustrated():
		var replacement: Texture2D = preload("res://Games/RowDivers/RowDiversIllustrated.gd").texture(name)
		if replacement != null: return replacement
	if not textures.has(name): textures[name] = load(ROOT + name)
	return textures[name]

static func sprite(name: String, height: float) -> Sprite3D:
	var image := Sprite3D.new()
	image.texture = texture(name)
	image.pixel_size = height / image.texture.get_height()
	image.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	image.shaded = false
	image.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	image.double_sided = true
	return image

static func surface(image: String, uv_scale: Vector3) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture(image)
	material.uv1_scale = uv_scale
	material.roughness = 1.0
	return material
