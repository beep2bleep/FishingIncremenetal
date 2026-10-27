extends RefCounted
## Decorative, deterministic rails. No colliders or combat-RNG draws.
static func path_x(section: int, t: float, width: float) -> float:
	if section%4==0: return 0
	return sin(t/20.0*PI)*.30*width*(1 if section%2==0 else -1)

static func build(section: int, width: float) -> Node3D:
	var root = Node3D.new()
	root.name = "RailwayTracks"
	root.set_meta("track_style",section%7)
	if section%7==0: return root # Some stretches have lost their railway entirely.
	var ties: Array[Transform3D] = []
	var iron: Array[Transform3D] = []
	var highlights: Array[Transform3D] = []
	var broken = section%7 in [2,5]
	for i in range(30):
		var t = (i+.5)*20/30.0
		if broken and i in [11,12,13,21]: continue
		var tilt = .14 if section%7==5 and i%5==0 else 0.0
		ties.append(Transform3D(Basis(Vector3.UP,tilt).scaled(Vector3(1.22*width,.035,.12)),Vector3(path_x(section,t,width),.019,-t)))
	for i in range(40):
		var start = i*.5
		var finish = start+.5
		for side in [-1,1]:
			if broken and ((side==1 and i in range(14,19)) or (side==-1 and i in range(23,26))): continue
			var a = Vector3(path_x(section,start,width)+side*.46*width,.05,-start)
			var b = Vector3(path_x(section,finish,width)+side*.46*width,.05,-finish)
			var basis = Basis.looking_at((b-a).normalized())
			iron.append(Transform3D(basis.scaled(Vector3(.065,.055,a.distance_to(b))), (a+b)*.5))
			highlights.append(Transform3D(basis.scaled(Vector3(.027,.008,a.distance_to(b))), (a+b)*.5+Vector3(0,.029,0)))
	if broken:
		# A detached rail lies crooked inside the clear center lane.
		iron.append(Transform3D(Basis(Vector3.UP,.28).scaled(Vector3(.065,.055,1.15)),Vector3(.12*width,.05,-8)))
	_batch(root,"Sleepers",ties,Color("594234"))
	_batch(root,"Rails",iron,Color("252b30"))
	_batch(root,"WornEdges",highlights,Color("a3987e"))
	return root

static func _batch(root: Node3D, label: String, transforms: Array[Transform3D], color: Color) -> void:
	var mesh = BoxMesh.new()
	mesh.size = Vector3.ONE
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = .85
	# Readable alongside the unlit inked stone textures.
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	var batch = MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.mesh = mesh
	batch.instance_count = transforms.size()
	for i in range(transforms.size()): batch.set_instance_transform(i,transforms[i])
	var visual = MultiMeshInstance3D.new()
	visual.name = label
	visual.multimesh = batch
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(visual)
