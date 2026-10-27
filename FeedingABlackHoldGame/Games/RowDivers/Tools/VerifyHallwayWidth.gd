extends SceneTree
const Hallway = preload("res://Games/RowDivers/RowDiversHallway.gd")
const Tracks = preload("res://Games/RowDivers/RowDiversTracks.gd")
var checks = 0
var failures = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for distance in range(301):
		var width = Hallway.width_scale(-float(distance))
		check(width >= 1.0 and width <= 1.5, "Hallway stays within original to 150% width")
		if distance % 100 >= 80: check(is_equal_approx(width, 1.0), "Boss room retains original width")
		check(absf(width - Hallway.width_scale(-float(distance) - 0.001)) < 0.0001, "Width profile is continuous")
	check(is_equal_approx(Hallway.width_scale(-20), 1.5), "Hallway reaches 50% wider")
	for boundary in [0.0, 40.0, 80.0, 100.0, 180.0, 200.0, 280.0, 300.0]:
		check(absf(Hallway.width_scale(-boundary - 0.01) - 1.0) < 0.00001, "Hallway eases flat at transition")
	for number in [1, 5, 10, 15]:
		var section = Node3D.new()
		section.set_meta("section_number", number)
		section.position.z = -(number - 1) * 20.0
		root.add_child(section)
		var hallway = Node3D.new()
		hallway.name = "ModernHallway"
		section.add_child(hallway)
		var wall = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(4, 2, 20)
		wall.mesh = box
		wall.position = Vector3(0, 1, -10)
		hallway.add_child(wall)
		var tracks = Tracks.build(number, 1.4)
		section.add_child(tracks)
		var rail_transforms: Array[Transform3D] = []
		var rails = tracks.get_node("Rails").multimesh
		for index in range(rails.instance_count): rail_transforms.append(rails.get_instance_transform(index))
		Hallway.apply(section)
		if number % 5 == 0:
			check(wall.mesh == box and not wall.has_meta("hallway_source_mesh"), "Boss geometry remains untouched")
		else:
			check(wall.mesh != box and is_equal_approx(wall.mesh.get_aabb().size.x, 6), "Non-boss geometry widens smoothly")
			var warped = wall.mesh
			Hallway.apply(section)
			check(wall.mesh == warped, "Applying twice does not double the widening")
			Hallway.restore(section)
			check(wall.mesh == box, "Style refresh restores the source before rebuilding")
			Hallway.apply(section)
			check(wall.mesh.get_aabb() == warped.get_aabb(), "Style refresh preserves the width profile")
		for index in range(rails.instance_count): check(rail_transforms[index] == rails.get_instance_transform(index), "Railway tracks retain their original width")
		section.free()
	print("HALLWAY WIDTH %s: %d checks, %d failures" % ["PASSED" if failures == 0 else "FAILED", checks, failures])
	quit(0 if failures == 0 else 1)
