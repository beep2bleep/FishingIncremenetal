extends Node3D
## Native Synty rig with a looping skeletal idle; never changes combat bounds.
const ROOT = "res://Games/RowDivers/Art/Synty/Prefabs/Characters/SM_Chr_"
const SKINS = ["Skeleton_01", "Skeleton_HeavyArmor_01", "Skeleton_Flesh_01", "Skeleton_Ranger_01", "PlagueDoctor_01", "Priest_Female_01", "DarkLord_Male_01"]
const Graphics = preload("res://Games/RowDivers/RowDiversGraphics.gd")
var enemy_kind = 0
var is_boss = false
var source_sprite: Sprite3D
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

func setup(kind: int, boss: bool) -> void:
	enemy_kind = kind
	is_boss = boss
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
	if Graphics.original():
		rig = Node3D.new()
		add_child(rig)
		source_sprite = Graphics.sprite(Graphics.ENEMIES[enemy_kind], 2.0 if is_boss else 1.4)
		rig.add_child(source_sprite)
		source_sprite.position.y = 0.65
		rig.position.y = -0.65
		return
	var kind: int = enemy_kind
	var boss: bool = is_boss
	rig = load(ROOT + SKINS[clampi(kind, 0, 6)] + ".tscn").instantiate()
	rig.name = "Rig"
	add_child(rig)
	# Synty units are metres; original collision dimensions stay in the battle scene.
	rig.scale = Vector3.ONE * (0.94 if boss else 0.68)
	rig.position.y = -0.65
	skeleton = rig.find_child("Skeleton3D", true, false) as Skeleton3D
	if skeleton != null:
		_create_idle()
	hit_material = StandardMaterial3D.new()
	hit_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hit_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hit_material.albedo_color = Color(1, 0.85, 0.55, 0)
	for mesh in rig.find_children("*", "MeshInstance3D", true, false):
		skin_meshes.append(mesh)

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

func windup() -> void:
	if frozen or charge > 0: return
	charge = 0.8
	if idle != null: idle.play("attack")

func _process(delta: float) -> void:
	if idle != null: idle.speed_scale = 0.0 if frozen else playback_speed
	if frozen: return
	delta *= playback_speed
	time += delta
	var was_flashing: bool = flash > 0
	flash = maxf(0, flash - delta)
	if was_flashing and flash <= 0:
		for mesh in skin_meshes: mesh.material_overlay = null
	charge = maxf(0, charge - delta)
	if hit_material != null:
		hit_material.albedo_color.a = flash * 3.5
	if source_sprite != null:
		source_sprite.modulate = Color(1, 0.65, 0.55) if flash > 0 else Color.WHITE
		source_sprite.scale = Vector3(1.0 + sin(time * 2.2) * 0.025, 1.0 - sin(time * 2.2) * 0.025, 1.0)
	if rig != null:
		rig.position.y = -0.65 + sin(time * 2.2) * 0.045
		rig.position.z = sin((0.8 - charge) / 0.8 * PI) * 0.24 if charge > 0 else 0.0
		rig.rotation.x = -sin((0.8 - charge) / 0.8 * PI) * 0.22 if charge > 0 else 0.0
		rig.rotation.z = sin(time * 1.4) * 0.035
