extends Node3D
## Inked flame sprites, dark edges and a readable open corridor between banks.
const FLAME = preload("res://Games/RowDivers/Art/Illustrated/status_fire.png")
const SHADER = preload("res://Games/RowDivers/FireWave.gdshader")
var visuals: Dictionary = {}
var level_index = 0

func sync(waves: Array) -> void:
	var alive = {}
	for wave in waves:
		var tint: Color = preload("res://Games/RowDivers/RowDiversLevelThemes.gd").fire_tint(level_index,int(wave.get("stage",0)))
		alive[wave.id] = true
		if not visuals.has(wave.id):
			var root = Node3D.new()
			add_child(root)
			for side in [-1, 1]:
				var edge = float(wave.gap_x) + side * float(wave.gap_width) * 0.5
				var wall = side * 2.55
				var width = absf(wall - edge)
				var pieces = maxi(1, ceili(width / 0.38))
				for i in range(pieces):
					var sprite = MeshInstance3D.new()
					var plane = QuadMesh.new()
					plane.size = Vector2(0.65, 2.7 + 0.18 * sin(i * 2.0))
					sprite.mesh = plane
					sprite.position = Vector3(lerpf(edge + side * 0.12, wall, (i + 0.5) / pieces), 1.2, sin(i * 1.7) * 0.04)
					var material = ShaderMaterial.new()
					material.shader = SHADER
					material.set_shader_parameter("flame", FLAME)
					material.set_shader_parameter("phase", float(i + wave.id))
					material.set_shader_parameter("level_tint",tint)
					sprite.material_override = material
					root.add_child(sprite)
			# Small embers reinforce motion without obscuring the safe gap.
			for side in [-1, 1]:
				var glow = OmniLight3D.new()
				glow.position = Vector3(float(wave.gap_x) + side * (float(wave.gap_width) * 0.5 + 0.35), 0.7, 0)
				glow.light_color = tint
				glow.light_energy = 0.5
				glow.omni_range = 2.4
				root.add_child(glow)
			visuals[wave.id] = root
		visuals[wave.id].position.z = wave.z
	for key in visuals.keys():
		if not alive.has(key):
			visuals[key].queue_free()
			visuals.erase(key)
