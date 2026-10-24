extends RefCounted
## Third presentation: generated inked sprites on the restored corridor geometry.
const ROOT = "res://Games/RowDivers/Art/Illustrated/"
static var manifest: Dictionary = {}
static var loaded_textures: Dictionary = {}

static func catalog() -> Dictionary:
	if manifest.is_empty(): manifest = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "manifest.json"))
	return manifest

static func texture_path(source_name: String) -> String:
	var file: String = catalog().textures.get(source_name, "")
	return ROOT + file if not file.is_empty() else ""

static func texture(source_name: String) -> Texture2D:
	var path := texture_path(source_name)
	if path.is_empty(): return null
	if not loaded_textures.has(path): loaded_textures[path] = load(path)
	return loaded_textures[path]
