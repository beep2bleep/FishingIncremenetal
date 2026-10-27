extends RefCounted
## A fixed spatial profile keeps adjoining sections aligned. Rails are excluded.
static func width_scale(world_z: float) -> float:
	var distance = fposmod(maxf(0, -world_z), 100.0)
	# Each fifth section is a boss room. Both its boundaries have zero slope.
	if distance >= 80.0: return 1.0
	return 1.0 + 0.5 * pow(sin(PI * distance / 40.0), 2.0)

static func restore(root: Node) -> void:
	for mesh in root.find_children("*", "MeshInstance3D", true, false):
		if mesh.has_meta("hallway_source_mesh"):
			mesh.mesh = mesh.get_meta("hallway_source_mesh")
			mesh.remove_meta("hallway_source_mesh")
	for item in root.find_children("*", "Node3D", true, false):
		if item.has_meta("hallway_source_position"):
			item.position = item.get_meta("hallway_source_position")
			item.remove_meta("hallway_source_position")

static func apply(section: Node3D) -> void:
	if int(section.get_meta("section_number", 1)) % 5 == 0: return
	for name in ["OriginalHallway", "ModernHallway", "LevelScenery"]:
		var root = section.get_node_or_null(name)
		if root == null: continue
		for mesh in root.find_children("*", "MeshInstance3D", true, false):
			if mesh.mesh != null and not mesh.has_meta("hallway_source_mesh"):
				_widen_mesh(mesh)
		for item in root.find_children("*", "Node3D", true, false):
			if (item is Light3D or item is Sprite3D) and not item.has_meta("hallway_source_position"):
				item.set_meta("hallway_source_position", item.position)
				var position: Vector3 = item.global_position
				position.x *= width_scale(position.z)
				item.global_position = position

static func _widen_mesh(instance: MeshInstance3D) -> void:
	var source: Mesh = instance.mesh
	var result = ArrayMesh.new()
	var to_world = instance.global_transform
	if absf(to_world.basis.determinant()) < 0.000001: return
	var to_local = to_world.affine_inverse()
	for surface_index in range(source.get_surface_count()):
		if source is ArrayMesh and source.surface_get_primitive_type(surface_index) != Mesh.PRIMITIVE_TRIANGLES: return
		var arrays = source.surface_get_arrays(surface_index)
		var indices = arrays[Mesh.ARRAY_INDEX]
		var count: int = indices.size() if indices != null and indices.size() > 0 else arrays[Mesh.ARRAY_VERTEX].size()
		var builder = SurfaceTool.new()
		builder.begin(Mesh.PRIMITIVE_TRIANGLES)
		for offset in range(0, count, 3):
			var triangle: Array[Dictionary] = []
			for corner in range(3):
				var index: int = indices[offset + corner] if indices != null and indices.size() > 0 else offset + corner
				var vertex = {"position": to_world * arrays[Mesh.ARRAY_VERTEX][index]}
				for pair in [["normal", Mesh.ARRAY_NORMAL], ["uv", Mesh.ARRAY_TEX_UV], ["uv2", Mesh.ARRAY_TEX_UV2], ["color", Mesh.ARRAY_COLOR]]:
					if arrays[pair[1]] != null and arrays[pair[1]].size() > index: vertex[pair[0]] = arrays[pair[1]][index]
				triangle.append(vertex)
			_emit_triangle(builder, triangle, to_world, to_local, 0)
		if arrays[Mesh.ARRAY_NORMAL] != null and arrays[Mesh.ARRAY_TEX_UV] != null:
			builder.generate_tangents()
		builder.index()
		builder.set_material(source.surface_get_material(surface_index))
		builder.commit(result)
	instance.set_meta("hallway_source_mesh", source)
	instance.mesh = result

static func _emit_triangle(builder: SurfaceTool, triangle: Array[Dictionary], to_world: Transform3D, to_local: Transform3D, depth: int) -> void:
	var longest_edge = 0
	var span = 0.0
	for edge in range(3):
		var edge_span: float = absf(triangle[edge].position.z - triangle[(edge + 1) % 3].position.z)
		if edge_span > span:
			span = edge_span
			longest_edge = edge
	# Subdivide long floor/wall triangles so the widening is smooth along them.
	if span > 2.5 and depth < 8:
		var a = triangle[longest_edge]
		var b = triangle[(longest_edge + 1) % 3]
		var c = triangle[(longest_edge + 2) % 3]
		var middle: Dictionary = {}
		for key in a: middle[key] = a[key].lerp(b[key], 0.5)
		_emit_triangle(builder, [a, middle, c], to_world, to_local, depth + 1)
		_emit_triangle(builder, [middle, b, c], to_world, to_local, depth + 1)
		return
	for vertex in triangle:
		var position: Vector3 = vertex.position
		var width = width_scale(position.z)
		if vertex.has("normal"):
			var normal: Vector3 = to_world.basis.inverse().transposed() * vertex.normal
			var slope = (width_scale(position.z + 0.01) - width_scale(position.z - 0.01)) / 0.02
			normal = Vector3(normal.x / width, normal.y, normal.z - position.x * slope * normal.x / width)
			builder.set_normal((to_world.basis.transposed() * normal).normalized())
		if vertex.has("uv"): builder.set_uv(vertex.uv)
		if vertex.has("uv2"): builder.set_uv2(vertex.uv2)
		if vertex.has("color"): builder.set_color(vertex.color)
		position.x *= width
		builder.add_vertex(to_local * position)
