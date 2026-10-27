extends Node3D
## Reuse the game's painted, ink-outlined status art, including on bats.
const FIRE_ART = preload("res://Games/RowDivers/Art/Illustrated/status_fire.png")
const CURSE_ART = preload("res://Games/RowDivers/Art/Illustrated/status_curse.png")
var burning: MeshInstance3D
var cursed: MeshInstance3D
var animation_time = 0.0

func setup(boss: bool, airborne: bool) -> void:
	name = "EnemyStatusEffects"
	var size = Vector2(1.3, 1.6) * (1.35 if boss else 1.0)
	if airborne: size = Vector2(1.4, 1.0)
	position.y = 0.0 if airborne else (0.95 if boss else 0.65)
	burning = _surface("Burning", size, 0)
	cursed = _surface("Cursed", size, 1)

func _surface(label: String, size: Vector2, kind: int) -> MeshInstance3D:
	var visual = MeshInstance3D.new()
	visual.name = label
	var quad = QuadMesh.new()
	quad.size = size
	visual.mesh = quad
	var material = ShaderMaterial.new()
	material.shader = preload("res://Games/RowDivers/EnemyStatus.gdshader")
	material.set_shader_parameter("effect_kind", kind)
	material.set_shader_parameter("status_art", FIRE_ART if kind == 0 else CURSE_ART)
	visual.material_override = material
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visual.hide()
	add_child(visual)
	return visual

func set_effects(flags: Dictionary) -> void:
	burning.visible = bool(flags.get("Burning", false))
	cursed.visible = bool(flags.get("Cursed", false))

func advance(delta: float) -> void:
	if not burning.visible and not cursed.visible: return
	animation_time += delta
	for visual in [burning, cursed]:
		if visual.visible: visual.material_override.set_shader_parameter("effect_time", animation_time)
