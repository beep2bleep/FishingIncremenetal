extends RefCounted
## Original serialized scenery, with Unity's Z axis reflected into Godot space.
const ROOT = "res://Games/RowDivers/Art/Original/"
static var source: Dictionary = {}
static var materials: Dictionary = {}
static var meshes: Dictionary = {}
static var transparent_shader: Shader

static func catalog() -> Dictionary:
    if source.is_empty(): source = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "presentation.json"))
    return source

static func material(key: String) -> ShaderMaterial:
    var variant: bool = preload("res://Games/RowDivers/RowDiversGraphics.gd").illustrated()
    var cache_key := key + (":illustrated" if variant else ":original")
    if materials.has(cache_key): return materials[cache_key]
    var result := ShaderMaterial.new()
    result.shader = preload("res://Games/RowDivers/OriginalSurface.gdshader")
    if key.is_empty(): return result
    var data: Dictionary = catalog().materials[key]
    if data.transparent:
        if transparent_shader == null:
            transparent_shader = Shader.new()
            transparent_shader.code = result.shader.code.replace("shader_type spatial;", "shader_type spatial;\n#define ORIGINAL_TRANSPARENT\n")
        result.shader = transparent_shader
    result.set_shader_parameter("tint_color", Color(data.color[0], data.color[1], data.color[2], data.color[3]))
    if not data.texture.is_empty():
        var path: String = preload("res://Games/RowDivers/RowDiversIllustrated.gd").texture_path(data.texture) if variant else ""
        result.set_shader_parameter("source_texture", load(path if not path.is_empty() else ROOT + data.texture))
    var uv_scale := Vector2(data.uv_scale[0], data.uv_scale[1])
    var uv_offset := Vector2(data.uv_offset[0], data.uv_offset[1])
    # Flip only held weapons. Projectile prefabs already orient their tip-up
    # textures along the shot direction; flipping their UVs makes them fly tail-first.
    if variant and data.texture in ["1.png", "dagger.png"]:
        uv_scale.y = -uv_scale.y
        uv_offset.y = 1.0 - uv_offset.y
    result.set_shader_parameter("source_scale", uv_scale)
    result.set_shader_parameter("source_offset", uv_offset)
    result.set_shader_parameter("transparent_surface", data.transparent)
    result.set_shader_parameter("unlit_surface", data.unshaded)
    materials[cache_key] = result
    return result

static func refresh_materials(root: Node) -> void:
    for instance in root.find_children("*", "MeshInstance3D", true, false):
        if instance.has_meta("row_source_material"):
            refresh_instance(instance)

static func refresh_instance(instance: MeshInstance3D) -> void:
    var key: String = instance.get_meta("row_source_material")
    instance.material_override = material(key)
    instance.scale = Vector3.ONE
    if not preload("res://Games/RowDivers/RowDiversGraphics.gd").illustrated(): return
    var texture_name: String = catalog().materials.get(key, {}).get("texture", "")
    # The new filled diamond replaces a narrow pole, not a full-size wall panel.
    # Resize only its visual child so mount positions and gate animation stay put.
    if texture_name == "Decor2.png": instance.scale = Vector3.ONE * 0.22
    elif texture_name == "Spikes.png": instance.scale = Vector3.ONE * 0.45

static func mesh(data: Dictionary) -> Mesh:
    var key := str(data.get("mesh", data.get("primitive", "")))
    if meshes.has(key): return meshes[key]
    var result: Mesh
    if data.has("primitive"):
        match int(data.primitive):
            10202:
                result = BoxMesh.new()
            10209:
                var plane := PlaneMesh.new()
                plane.size = Vector2(10, 10)
                result = plane
            10206:
                var cylinder := CylinderMesh.new()
                cylinder.height = 2.0
                cylinder.top_radius = 0.5
                cylinder.bottom_radius = 0.5
                cylinder.radial_segments = 20
                result = cylinder
            10210:
                var quad := QuadMesh.new()
                quad.size = Vector2.ONE
                result = quad
            _:
                push_error("Unsupported original primitive: " + key)
                result = BoxMesh.new()
    else:
        var original: Dictionary = catalog().meshes[key]
        var vertices := PackedVector3Array()
        var normals := PackedVector3Array()
        var uv := PackedVector2Array()
        for v in original.vertices: vertices.append(Vector3(v[0], v[1], -v[2]))
        for v in original.normals: normals.append(Vector3(v[0], v[1], -v[2]))
        for v in original.uv: uv.append(Vector2(v[0], 1.0 - v[1]))
        var arrays := []
        arrays.resize(Mesh.ARRAY_MAX)
        arrays[Mesh.ARRAY_VERTEX] = vertices
        arrays[Mesh.ARRAY_NORMAL] = normals
        arrays[Mesh.ARRAY_TEX_UV] = uv
        arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(original.indices)
        var imported := ArrayMesh.new()
        imported.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
        result = imported
    meshes[key] = result
    return result

static func build(layout: String, corridor = true) -> Node3D:
    var root := Node3D.new()
    root.name = "OriginalHallway"
    root.position = Vector3(-2.5, 0, -28.474) if corridor else Vector3.ZERO
    var nodes: Array[Node3D] = []
    for data in catalog().layouts[layout]:
        var node := Node3D.new()
        node.name = str(data.name).replace("/", "_")
        (root if int(data.parent) < 0 else nodes[int(data.parent)]).add_child(node)
        var p: Array = data.position
        var q: Array = data.rotation
        var s: Array = data.scale
        node.transform = Transform3D(Basis(Quaternion(-q[0], -q[1], q[2], q[3])).scaled(Vector3(s[0], s[1], s[2])), Vector3(p[0], p[1], -p[2]))
        node.visible = data.active
        nodes.append(node)
        if data.has("primitive") or data.has("mesh"):
            var instance := MeshInstance3D.new()
            instance.mesh = mesh(data)
            instance.set_meta("row_source_material", data.material)
            refresh_instance(instance)
            instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
            # Static-batched Unity meshes already contain world-space vertices.
            (root if data.get("baked", false) else node).add_child(instance)
    return root

static func animate(root: Node3D, clip: String, time: float) -> void:
    for property in catalog().animations[clip]:
        for track in catalog().animations[clip][property]:
            var node := root.get_node_or_null(str(track.path)) as Node3D
            if node == null: continue
            var keys: Array = track.curve.m_Curve
            var value := Vector3.ZERO
            for axis in range(3):
                var component: String = ["x", "y", "z"][axis]
                var first: Dictionary = keys[0]
                var last: Dictionary = keys[-1]
                var sampled := float(last.value[component])
                if time <= float(first.time): sampled = float(first.value[component])
                else:
                    for index in range(keys.size() - 1):
                        var a: Dictionary = keys[index]
                        var b: Dictionary = keys[index + 1]
                        if time > float(b.time): continue
                        var duration := float(b.time) - float(a.time)
                        var t := (time - float(a.time)) / duration
                        var outgoing = a.outSlope[component]
                        var incoming = b.inSlope[component]
                        if outgoing is String or incoming is String: sampled = float(a.value[component])
                        else:
                            sampled = (2*t*t*t - 3*t*t + 1) * float(a.value[component]) + (t*t*t - 2*t*t + t) * duration * float(outgoing) + (-2*t*t*t + 3*t*t) * float(b.value[component]) + (t*t*t - t*t) * duration * float(incoming)
                        break
                value[axis] = sampled
            if property == "m_PositionCurves": node.position = Vector3(value.x, value.y, -value.z)
            else: node.scale = value
