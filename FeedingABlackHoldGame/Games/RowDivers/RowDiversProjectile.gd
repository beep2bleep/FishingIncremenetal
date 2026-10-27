extends RefCounted
## Shared ink-edged projectiles. Local -Z is always the direction of flight.
static var meshes: Dictionary = {}

static func create(kind: String, hostile: bool = false) -> Node3D:
	var root = Node3D.new()
	root.name = "InkedProjectile"
	var key = kind + ("_hostile" if hostile else "_player")
	if not meshes.has(key): meshes[key] = _build(kind, hostile)
	var visual = MeshInstance3D.new()
	visual.name = "FlightVisual"
	visual.mesh = meshes[key]
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(visual)
	return root

static func _build(kind: String, hostile: bool) -> ArrayMesh:
	var ink = Color("201b25")
	var color: Color = {"Fire": Color("f6ab55"), "Cursed": Color("b99be5"), "Bat": Color("cb94ed"), "Poison": Color("a8ce70"), "LifeSteal": Color("e291ae"), "Critical": Color("f17c64")}.get(kind, Color("ead7a7"))
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var outline = SurfaceTool.new()
	outline.begin(Mesh.PRIMITIVE_TRIANGLES)
	if hostile:
		# Dark pointed shell, warm colored facets and a small bright front cap.
		_diamond(outline, Vector3.ZERO, Vector3(.145,.145,.34), ink)
		_diamond(surface, Vector3(0,0,-.015), Vector3(.115,.115,.29), color)
		_diamond(surface, Vector3(0,0,-.17), Vector3(.065,.065,.12), color.lightened(.45))
		# A flame-shaped face distinguishes incoming shots from diamond-shaped loot.
		_burst(surface, -.345, .17, ink)
		_burst(surface, -.35, .13, color)
		_burst(surface, -.355, .045, color.lightened(.6))
		_fin(surface, .075, .19, .66, color.darkened(.25))
	else:
		# A narrow shaft and clear broadhead remain readable when seen from behind.
		_diamond(outline, Vector3(0,0,.04), Vector3(.035,.035,.33), ink)
		_diamond(surface, Vector3(0,0,.035), Vector3(.022,.022,.32), Color("b98a55"))
		_diamond(outline, Vector3(0,0,-.32), Vector3(.105,.105,.18), ink)
		_diamond(surface, Vector3(0,0,-.335), Vector3(.078,.078,.14), color.lightened(.2))
		_fin(surface, .105, .14, .34, color)
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	surface.set_material(material)
	var mesh = surface.commit()
	var border = material.duplicate() as StandardMaterial3D
	border.cull_mode = BaseMaterial3D.CULL_FRONT
	outline.set_material(border)
	outline.commit(mesh)
	return mesh

static func _triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	surface.set_color(color)
	for point in [a,b,c]: surface.add_vertex(point)

static func _diamond(surface: SurfaceTool, center: Vector3, size: Vector3, color: Color) -> void:
	var ring = [Vector3(size.x,0,0), Vector3(0,size.y,0), Vector3(-size.x,0,0), Vector3(0,-size.y,0)]
	for i in range(4):
		var shade = color.lightened(.12) if i == 0 else color.darkened(.18 if i == 2 else .04)
		_triangle(surface, center + Vector3(0,0,-size.z), center + ring[i], center + ring[(i+1)%4], shade)
		_triangle(surface, center + Vector3(0,0,size.z), center + ring[(i+1)%4], center + ring[i], shade)

static func _fin(surface: SurfaceTool, width: float, front: float, back: float, color: Color) -> void:
	for axis in [Vector3.RIGHT, Vector3.UP]:
		for side in [-1,1]:
			_triangle(surface, Vector3(0,0,front), axis * width * side + Vector3(0,0,back-.06), Vector3(0,0,back), color)

static func _burst(surface: SurfaceTool, z: float, radius: float, color: Color) -> void:
	for i in range(16):
		var angle = TAU * i / 16.0
		var next = TAU * (i+1) / 16.0
		var r = radius * (1.0 if i%2 == 0 else .72)
		var r_next = radius * (.72 if i%2 == 0 else 1.0)
		_triangle(surface, Vector3(0,0,z), Vector3(cos(angle)*r,sin(angle)*r,z), Vector3(cos(next)*r_next,sin(next)*r_next,z), color)
