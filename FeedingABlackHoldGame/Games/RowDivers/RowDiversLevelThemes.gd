extends RefCounted
const ROOT = "res://Games/RowDivers/Art/Levels/"
const NAMES = ["THE FORGOTTEN LINE","THE IRON CITADEL","THE WILDWOOD LINE","THE INFERNAL DESCENT"]
const ENEMY_TINTS = [Color.WHITE,Color("efdfc8"),Color("c8dfc3"),Color("efb4ac")]
const FIRE_TINTS = [Color("ffdca1"),Color("ffb66b"),Color("f39a70"),Color("ef795f")]
const WALLS = ["Wall Texture.png","Wall Texture 2.png","Wall_Boss_Texture.png"]
const FLOORS = ["Floor Texture.png","Floor Texture 2.png","boss_room_floor_texture1.png"]

static func level_name(index: int) -> String:
	return TranslationServer.translate("LEVEL %d · %s") % [index+1,TranslationServer.translate(NAMES[clampi(index,0,3)])]

static func environment_tint(index: int) -> Color:
	return [Color.WHITE,Color("f1d6af"),Color("b7cbaa"),Color("e5aaa0")][clampi(index,0,3)]

static func fire_tint(index: int, tier: int) -> Color:
	return FIRE_TINTS[clampi(index,0,3)].lerp(Color("f55a48"),clampf(tier,0,2)*.12)

static func configure_world(battle: Node3D) -> void:
	var level = int(battle.data.prestige)
	if level==0: return
	battle.world_environment.background_color = [Color.BLACK,Color("191b22"),Color("364f45"),Color("260c13")][level]
	battle.world_environment.ambient_light_color = [Color.WHITE,Color("ffe1b5"),Color("c1dbc2"),Color("eea38e")][level]
	battle.world_environment.ambient_light_energy = 1.0
	battle.world_light.light_color = [Color.WHITE,Color("ffe2b4"),Color("d5e8bb"),Color("ff9a6f")][level]
	battle.world_light.visible = level==2 or not battle.Graphics.original()
	battle.world_environment.fog_enabled = level==2
	battle.world_environment.fog_density = .035
	battle.world_environment.fog_light_color = Color("364f45")

static func apply_section(section: Node3D, battle: Node3D) -> void:
	var level = int(battle.data.prestige)
	var original: Node3D = section.get_node("OriginalHallway")
	original.set_meta("row_environment_level",level)
	var source = load("res://Games/RowDivers/RowDiversOriginalPresentation.gd")
	source.refresh_materials(original)
	var previous = section.get_node_or_null("LevelScenery")
	if previous!=null: previous.free()
	var scenery = Node3D.new()
	scenery.name = "LevelScenery"
	section.add_child(scenery)
	var width: float = battle.corridor_width
	var floor_y = .52 if battle.Graphics.original() else 0.0
	if level==2:
		section.get_node("ModernHallway").hide()
		original.hide()
		_box(scenery,Vector3(0,floor_y-.035,-10),Vector3(32,.06,20),Color.WHITE,"forest_ground.png")
		for side in [-1,1]:
			for i in range(6):
				var tree = Sprite3D.new()
				tree.texture = load(ROOT+"forest_tree.png")
				tree.pixel_size = (6.8+float((i+int(section.get_meta("section_number",1)))%3)*.8)/tree.texture.get_height()
				tree.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
				tree.shaded = false
				tree.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
				tree.modulate = Color("b6c7a7") if i%2==0 else Color("d9d3a4")
				tree.position = Vector3(side*(3.4+float(i%2)*2.8)*width,floor_y+tree.texture.get_height()*tree.pixel_size*.5,-1.2-i*3.4)
				scenery.add_child(tree)
	elif level==1:
		for z in [2.5,10.5,18.5]:
			_box(scenery,Vector3(0,2.35,-z),Vector3(3.5*width,.18,.22),Color("211c1b"))
			_box(scenery,Vector3(0,2.35,-z),Vector3(3.5*width,.14,.18),Color("453127"))
			for side in [-1,1]:
				_box(scenery,Vector3(side*1.445*width,1.85,-z),Vector3(.045,.95,.53),Color("211c1b"))
				_box(scenery,Vector3(side*1.43*width,1.85,-z),Vector3(.05,.9,.48),Color("762e3c"))
				_box(scenery,Vector3(side*1.40*width,1.85,-z),Vector3(.016,.65,.055),Color("d2a75f"))
				_box(scenery,Vector3(side*1.397*width,1.95,-z),Vector3(.016,.055,.30),Color("d2a75f"))
	elif level==3:
		for side in [-1,1]:
			var lava = _box(scenery,Vector3(side*1.40*width,floor_y+.008,-10),Vector3(.23*width,.025,20),Color.WHITE,"res://Games/RowDivers/Art/Illustrated/lava.png")
			lava.material_override.uv1_scale = Vector3(1,48,1)
			for z in [4.0,13.0]:
				var light = OmniLight3D.new()
				light.position = Vector3(side*1.3*width,1.4,-z)
				light.light_color = Color("ef673d")
				light.light_energy = .65
				light.omni_range = 3.0
				scenery.add_child(light)
	if not battle.Graphics.original() and level!=2:
		for mesh in section.get_node("ModernHallway").find_children("*","MeshInstance3D",true,false):
			if mesh.material_override is StandardMaterial3D:
				if not mesh.has_meta("row_level_base_material"):
					mesh.set_meta("row_level_base_material",mesh.get_meta("default_material",mesh.material_override).duplicate())
				var material = mesh.get_meta("row_level_base_material").duplicate()
				material.albedo_color *= environment_tint(level)
				if level==3:
					material.albedo_texture = load(ROOT+"hell_basalt.png")
					material.uv1_scale = Vector3(3,3,3)
				mesh.material_override = material
	preload("res://Games/RowDivers/RowDiversHallway.gd").apply(section)

static func _on_column(mesh: Node) -> bool:
	var node = mesh.get_parent()
	while node!=null:
		if node.get_meta("row_source_name","")=="Column": return true
		node = node.get_parent()
	return false

static func _box(root: Node3D, position: Vector3, size: Vector3, color: Color, texture = "") -> MeshInstance3D:
	var visual = MeshInstance3D.new()
	var shape = BoxMesh.new()
	shape.size = size
	visual.mesh = shape
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if not texture.is_empty():
		material.albedo_texture = load(texture if texture.begins_with("res://") else ROOT+texture)
		material.uv1_scale = Vector3(8,5,1)
	visual.material_override = material
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(visual)
	visual.position = position
	return visual
