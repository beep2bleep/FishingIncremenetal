extends Node3D
## Native Synty rig with a looping skeletal idle; never changes combat bounds.
const ROOT = "res://Games/RowDivers/Art/Synty/Prefabs/Characters/SM_Chr_"
const SKINS = ["Skeleton_01", "Skeleton_HeavyArmor_01", "Skeleton_Flesh_01", "Skeleton_Ranger_01", "PlagueDoctor_01", "Priest_Female_01", "DarkLord_Male_01"]
var rig: Node3D
var idle: AnimationPlayer
var skeleton: Skeleton3D
var hit_material: StandardMaterial3D
var flash = 0.0
var charge = 0.0
var time = 0.0
var frozen = false
var skin_meshes: Array[MeshInstance3D] = []

func setup(kind: int, boss: bool) -> void:
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
		var down := Quaternion(Vector3.FORWARD, signf(pose.origin.x) * 1.0)
		skeleton.set_bone_pose_rotation(bone, parent_rotation.inverse() * down * pose.basis.get_rotation_quaternion())
	idle = AnimationPlayer.new()
	idle.name = "IdleAnimation"
	add_child(idle)
	var animation := Animation.new()
	animation.length = 3.2
	animation.loop_mode = Animation.LOOP_LINEAR
	for bone_name in ["Spine_01", "Spine_02", "Neck", "Head", "Shoulder_L", "Shoulder_R"]:
		var bone: int = skeleton.find_bone(bone_name)
		if bone < 0: continue
		var base: Quaternion = skeleton.get_bone_pose_rotation(bone)
		var track := animation.add_track(Animation.TYPE_ROTATION_3D)
		animation.track_set_path(track, NodePath(str(get_path_to(skeleton)) + ":" + bone_name))
		var strength := 0.018 if "Spine" in bone_name else 0.035
		for frame in range(5):
			var phase := float(frame) / 4.0 * TAU
			animation.rotation_track_insert_key(track, float(frame) * 0.8, base * Quaternion(Vector3.FORWARD, sin(phase) * strength))
	var library := AnimationLibrary.new()
	library.add_animation("idle", animation)
	idle.add_animation_library("", library)
	idle.play("idle")
	idle.seek(randf() * 3.2, true)

func hit() -> void:
	flash = 0.18
	for mesh in skin_meshes: mesh.material_overlay = hit_material

func windup() -> void:
	charge = 0.35

func _process(delta: float) -> void:
	if idle != null: idle.speed_scale = 0.0 if frozen else 1.0
	if frozen: return
	time += delta
	var was_flashing: bool = flash > 0
	flash = maxf(0, flash - delta)
	if was_flashing and flash <= 0:
		for mesh in skin_meshes: mesh.material_overlay = null
	charge = maxf(0, charge - delta)
	if hit_material != null:
		hit_material.albedo_color.a = flash * 3.5
	if rig != null:
		rig.position.y = -0.65 + sin(time * 2.2) * 0.012
		rig.rotation.x = -charge * 0.2
