extends RefCounted
## Original vector presentation. No gameplay random-number draws or save changes.
const ROOT = "res://Games/RowDivers/Art/Gothic/"
static var manifest: Dictionary = {}
static var textures: Dictionary = {}

static func texture_path(source: String) -> String:
	if manifest.is_empty(): manifest = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "manifest.json"))
	var file: String = manifest.textures.get(source, "")
	return ROOT + file if not file.is_empty() else ""

static func texture(source: String) -> Texture2D:
	var path := texture_path(source)
	if path.is_empty(): return null
	if not textures.has(path): textures[path] = load(path)
	return textures[path]

static func icon(entry: Dictionary) -> String:
	var text := str(entry.get("upgradeName", "")).to_lower() + str(entry.get("unlocks", {})).to_lower()
	var symbol := "skull"
	if "poison" in text or "heal" in text or "remedy" in text or "slowdown" in text: symbol = "poison"
	elif "fire" in text or "burn" in text or "damage" in text: symbol = "radiation"
	elif "armor" in text or "dagger" in text or "arrow" in text or "bow" in text or "shuriken" in text: symbol = "bones"
	elif "health" in text or "hp" in text or "bleed" in text or "vamp" in text: symbol = "heart"
	elif "harvester" in text: symbol = "skull"
	elif "curse" in text or not Dictionary(entry.get("unlocks", {})).is_empty(): symbol = "occult"
	return ROOT + "icon_" + symbol + ".svg"

static func splatter(parent: Node3D, point: Vector3, fatal: bool) -> void:
	# Deterministic geometry, separate from combat RNG; capped, self-expiring.
	var marks := parent.get_node_or_null("GothicBlood")
	if marks == null:
		marks = Node3D.new()
		marks.name = "GothicBlood"
		parent.add_child(marks)
	if marks.get_child_count() >= 32: marks.get_child(0).free()
	var group := Node3D.new()
	marks.add_child(group)
	group.position = point
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("991c37")
	for i in range(12 if fatal else 5):
		var shard := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(.035, .075, .025) * (1.7 if fatal else 1.0)
		shard.mesh = mesh
		shard.material_override = material
		group.add_child(shard)
		var angle := float(i) * 2.399
		var tween := parent.create_tween().set_parallel(true)
		tween.tween_property(shard, "position", Vector3(cos(angle)*.65, -.45 + sin(angle)*.3, sin(angle)*.45), .35)
		tween.tween_property(shard, "scale", Vector3.ZERO, .7).set_delay(.15)
	var stain := Sprite3D.new()
	stain.texture = load(ROOT + "status.svg")
	stain.pixel_size = .004 if fatal else .002
	stain.rotation_degrees.x = -90
	stain.position = Vector3(0, .535 - point.y, 0)
	stain.modulate = Color("731429")
	group.add_child(stain)
	parent.get_tree().create_timer(8.0).timeout.connect(func():
		if is_instance_valid(group): group.queue_free())

static func style_upgrade(node: Node) -> void:
	var face: TextureRect = node.get_node("%Icon")
	var symbol: Sprite2D = node.get_node("%Mod Icon")
	if not face.has_meta("gothic_base_texture"): face.set_meta("gothic_base_texture", face.texture)
	if preload("res://Games/RowDivers/RowDiversGraphics.gd").gothic() and node.upgrade != null and node.upgrade.sim_icon.begins_with(ROOT):
		face.texture = load(node.upgrade.sim_icon)
		face.self_modulate = Color("d4bfc4")
		symbol.modulate = Color("eee0cb")
		# The complete state collapses its panel; retain its badge in that state.
		face.show()
		if node.state == node.STATES.COMPLETE: symbol.hide()
	else:
		face.texture = face.get_meta("gothic_base_texture")
		symbol.modulate = Refs.pallet.shadow
