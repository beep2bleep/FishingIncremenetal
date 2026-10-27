extends Node3D
## Native Synty rig with a looping skeletal idle; never changes combat bounds.
const ROOT = "res://Games/RowDivers/Art/Synty/Prefabs/Characters/SM_Chr_"
const SKINS = ["Skeleton_01", "Skeleton_HeavyArmor_01", "Skeleton_Flesh_01", "Skeleton_Ranger_01", "PlagueDoctor_01", "Priest_Female_01", "DarkLord_Male_01"]
const Graphics = preload("res://Games/RowDivers/RowDiversGraphics.gd")
var bat_material: ShaderMaterial
const MELEE_GROUND_OFFSET = -0.15
var enemy_kind = 0
var level_index = 0
var is_boss = false
var source_sprite: Node3D
var idle_phase = 0.0
var rig: Node3D
var idle: AnimationPlayer
var skeleton: Skeleton3D
var hit_material: StandardMaterial3D
var flash = 0.0
var charge = 0.0
var time = 0.0
var frozen = false
var playback_speed = 1.0
var rest_rotations: Dictionary = {}
var skin_meshes: Array[MeshInstance3D] = []
var status_visual: Node3D

func setup(kind: int, boss: bool, level = 0) -> void:
	level_index = clampi(level,0,3)
	enemy_kind = kind
	is_boss = boss
	status_visual = preload("res://Games/RowDivers/RowDiversEnemyStatus.gd").new()
	add_child(status_visual)
	status_visual.setup(boss, kind == 7)
	# Consume the same one phase draw for both styles, and none when switching.
	idle_phase = randf() * 3.2
	_refresh_graphics()
	SignalBus.settings_updated.connect(_refresh_graphics)

func _refresh_graphics() -> void:
	if idle != null: idle.free()
	idle = null
	skeleton = null
	source_sprite = null
	if rig != null: rig.free()
	skin_meshes.clear()
	rest_rotations.clear()
	bat_material = null
	if enemy_kind == 7:
		_build_bat()
		bat_material.set_shader_parameter("level_tint",preload("res://Games/RowDivers/RowDiversLevelThemes.gd").ENEMY_TINTS[level_index])
		return
	if Graphics.original():
		rig = preload("res://Games/RowDivers/RowDiversOriginalPresentation.gd").build("Actor_" + str(enemy_kind), false)
		add_child(rig)
		if enemy_kind in [0, 1, 2] and not is_boss: rig.position.y += MELEE_GROUND_OFFSET
		source_sprite = rig.get_child(0)
		_apply_level_tint()
		return
	var kind: int = enemy_kind
	var boss: bool = is_boss
	rig = load(ROOT + SKINS[clampi(kind, 0, 6)] + ".tscn").instantiate()
	rig.name = "Rig"
	add_child(rig)
	# Synty units are metres; original collision dimensions stay in the battle scene.
	rig.scale = Vector3.ONE * (0.94 if boss else 0.68)
	rig.position.y = -0.65 + (MELEE_GROUND_OFFSET if enemy_kind in [0, 1, 2] and not is_boss else 0.0)
	skeleton = rig.find_child("Skeleton3D", true, false) as Skeleton3D
	if skeleton != null:
		_create_idle()
	hit_material = StandardMaterial3D.new()
	hit_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hit_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hit_material.albedo_color = Color(1, 0.85, 0.55, 0)
	for mesh in rig.find_children("*", "MeshInstance3D", true, false):
		skin_meshes.append(mesh)
	_apply_level_tint()

func _apply_level_tint() -> void:
	var tint: Color = preload("res://Games/RowDivers/RowDiversLevelThemes.gd").ENEMY_TINTS[level_index]
	for mesh in rig.find_children("*","MeshInstance3D",true,false):
		var material: Material = mesh.material_override
		if material==null and mesh.mesh!=null and mesh.mesh.get_surface_count()>0: material = mesh.mesh.surface_get_material(0)
		if material is ShaderMaterial:
			var copy = material.duplicate()
			var base = copy.get_shader_parameter("tint_color")
			if base is Color:
				mesh.set_meta("row_enemy_tint",tint)
				copy.set_shader_parameter("tint_color",base*tint)
				mesh.material_override = copy
		elif material is StandardMaterial3D:
			var copy = material.duplicate()
			copy.albedo_color *= tint
			mesh.material_override = copy

func _build_bat() -> void:
	rig = Node3D.new()
	rig.name = "Bat"
	add_child(rig)
	var sprite := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(1.2, 0.8)
	quad.subdivide_width = 20
	quad.subdivide_depth = 8
	sprite.mesh = quad
	bat_material = ShaderMaterial.new()
	bat_material.shader = preload("res://Games/RowDivers/BatSprite.gdshader")
	bat_material.set_shader_parameter("bat_texture", preload("res://Games/RowDivers/Art/Illustrated/bat.png"))
	sprite.material_override = bat_material
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	rig.add_child(sprite)

func _create_idle() -> void:
	skeleton.force_update_all_bone_transforms()
	# The supplied FBX skins start in a T pose. Lower both upper arms in model
	# space before building the breathing loop, keeping each skin's bind pose.
	for bone_name in ["Shoulder_L", "Shoulder_R"]:
		var bone := skeleton.find_bone(bone_name)
		if bone < 0: continue
		var pose := skeleton.get_bone_global_pose(bone)
		var parent := skeleton.get_bone_parent(bone)
		var parent_rotation := skeleton.get_bone_global_pose(parent).basis.get_rotation_quaternion()
		var down := Quaternion(Vector3.FORWARD, signf(pose.origin.x) * 1.35)
		skeleton.set_bone_pose_rotation(bone, parent_rotation.inverse() * down * pose.basis.get_rotation_quaternion())
	idle = AnimationPlayer.new()
	idle.name = "IdleAnimation"
	add_child(idle)
	var animation := Animation.new()
	animation.length = 3.2
	animation.loop_mode = Animation.LOOP_LINEAR
	for bone_name in ["Spine_01", "Spine_02", "Neck", "Head", "Shoulder_L", "Shoulder_R", "Elbow_L", "Elbow_R"]:
		var bone: int = skeleton.find_bone(bone_name)
		if bone < 0: continue
		var base: Quaternion = skeleton.get_bone_pose_rotation(bone)
		var track := animation.add_track(Animation.TYPE_ROTATION_3D)
		animation.track_set_path(track, NodePath(str(get_path_to(skeleton)) + ":" + bone_name))
		rest_rotations[bone_name] = base
		var strength := 0.11 if "Spine" in bone_name else 0.18
		for frame in range(5):
			var phase := float(frame) / 4.0 * TAU
			animation.rotation_track_insert_key(track, float(frame) * 0.8, base * Quaternion(Vector3.FORWARD, sin(phase + (PI if bone_name.ends_with("_R") else 0.0)) * strength))
	var library := AnimationLibrary.new()
	library.add_animation("idle", animation)
	var attack := Animation.new()
	attack.length = 0.8
	for bone_name in rest_rotations:
		var track := attack.add_track(Animation.TYPE_ROTATION_3D)
		attack.track_set_path(track, NodePath(str(get_path_to(skeleton)) + ":" + bone_name))
		var base: Quaternion = rest_rotations[bone_name]
		var strength := 0.65 if "Shoulder" in bone_name else (0.4 if "Elbow" in bone_name else 0.23)
		var axis := Vector3.RIGHT if "Spine" in bone_name or bone_name == "Head" else Vector3.UP
		for frame in [[0.0, 0.0], [0.26, -0.6], [0.4, 1.0], [0.8, 0.0]]:
			attack.rotation_track_insert_key(track, frame[0], base * Quaternion(axis, frame[1] * strength))
	library.add_animation("attack", attack)
	idle.add_animation_library("", library)
	idle.animation_finished.connect(func(name):
		if name == "attack": idle.play("idle", 0.1))
	idle.play("idle")
	idle.seek(idle_phase, true)

func hit() -> void:
	flash = 0.18
	for mesh in skin_meshes: mesh.material_overlay = hit_material

func set_effects(flags: Dictionary) -> void:
	if status_visual != null: status_visual.set_effects(flags)
	if source_sprite == null: return
	for effect in {"Burning": "Burn Icon", "Cursed": "Curse Icon", "Bleeding": "Bleed Icon"}:
		var icon := source_sprite.find_child({"Burning": "Burn Icon", "Cursed": "Curse Icon", "Bleeding": "Bleed Icon"}[effect], true, false) as Node3D
		if icon != null: icon.visible = bool(flags.get(effect, false))

func windup() -> void:
	if frozen or charge > 0: return
	charge = 0.8
	if idle != null: idle.play("attack")

func _process(delta: float) -> void:
	if idle != null: idle.speed_scale = 0.0 if frozen else playback_speed
	if frozen: return
	delta *= playback_speed
	time += delta
	if status_visual != null: status_visual.advance(delta)
	var was_flashing: bool = flash > 0
	flash = maxf(0, flash - delta)
	if was_flashing and flash <= 0:
		for mesh in skin_meshes: mesh.material_overlay = null
	charge = maxf(0, charge - delta)
	if hit_material != null:
		hit_material.albedo_color.a = flash * 3.5
	if enemy_kind == 7:
		bat_material.set_shader_parameter("wing_phase", time * 11.0)
		bat_material.set_shader_parameter("hit_flash", flash * 3.5)
		return
	if source_sprite != null:
		preload("res://Games/RowDivers/RowDiversOriginalPresentation.gd").animate(source_sprite, "BossIdle" if is_boss else "EnemyIdle", fmod(time, 0.6666667))
		return
	if rig != null:
		rig.position.y = -0.65 + (MELEE_GROUND_OFFSET if enemy_kind in [0, 1, 2] and not is_boss else 0.0) + sin(time * 2.2) * 0.045
		rig.position.z = sin((0.8 - charge) / 0.8 * PI) * 0.24 if charge > 0 else 0.0
		rig.rotation.x = -sin((0.8 - charge) / 0.8 * PI) * 0.22 if charge > 0 else 0.0
		rig.rotation.z = sin(time * 1.4) * 0.035
