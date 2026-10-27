"""Build a rendering-free Godot model from current gameplay methods.

Only presentation, persistence and input selection are replaced. Regenerate before
every experiment so changes to the game's combat rules are not silently missed.
"""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / 'FeedingABlackHoldGame/Games/RowDivers'
source = (MODULE / 'Scenes/RowDiversBattleScene.gd').read_text(encoding='utf-8')
header, *parts = re.split(r'(?=^func )', source, flags=re.M)
functions = {p.split('(', 1)[0][5:]: p for p in parts}
keep = ['s', 'unlocked', 'active', 'walking_damage', 'regen_percent_per_second', '_update_powerups', '_simulate_step', '_dagger_target', '_dagger_hit', '_beam_hit',
        '_target', '_shoot', '_update_projectiles', '_new_projectile_state',
        '_take_projectile_state', '_return_projectile_state', '_has_effect',
        '_projectile_hit', '_effect', '_roll', '_hit', '_update_enemies',
        '_update_drops', '_award_loot', '_damage_player', '_heal', '_update_fire_waves', '_advance_horizontal_axis', '_free_aim_intersects']
header = '\n'.join(line for line in header.splitlines()
                   if not line.startswith('const ') or line.startswith(('const Progress','const FireWaves')))
header = header.replace('var audio: Node', 'var audio: Node').replace('var presentation: CanvasLayer', 'var presentation: Node')
header = header.replace('var free_aim_mode = Progress.free_aim_mode', 'var free_aim_mode = false # Offline classic assisted mode.')
header = header.replace('var audio: Node', 'var audio').replace('var shield_ring: MeshInstance3D', 'var shield_ring: Spatial').replace('Array[Node3D]', 'Array')
custom = '''
class Spatial extends RefCounted:
	var position = Vector3.ZERO
	var rotation = Vector3.ZERO
	var scale = Vector3.ONE
	var name = ""
	var visible = true
	func add_child(_node): pass
	func hide(): visible = false
	func rotate_z(angle): rotation.z += angle
	func look_at(_target): pass
	func rotate_y(angle): rotation.y += angle

class SilentActor extends RefCounted:
	var frozen = false
	func sound(_key): pass
	func hit(): pass
	func windup(): pass
	func set_effects(_effects): pass

class SilentHUD extends Node:
	var feedback = ColorRect.new()
	func toast(_text, _color = Color.WHITE): pass
	func _notification(what):
		if what == NOTIFICATION_PREDELETE: feedback.free()

class SilentLabel extends RefCounted:
	var text = ""
	var modulate = Color.WHITE
	func hide(): pass

var kill_records: Array = []
var won_run = false
var damage_dealt = 0.0
var healing_received = 0.0
var row_damage_scale = 1.0 # Counterfactual experiments only; default is exact gameplay.
var retired_nodes: Dictionary = {}

func _retire(node): retired_nodes[node.get_instance_id()] = node
func _flush_retired():
	retired_nodes.clear()

func _ready():
	persist_results = false
	set_physics_process(false)
	set_process(false)
	Progress.apply_reference_repairs(data)
	data.achievements.FirstDive = true
	health = s("MaxHP")
	armor = s("Armor")
	forward_speed = float(Progress.design().settings.movement.forwardSpeed)
	fire_mode = "Auto" if unlocked("Auto") else ("Hold" if unlocked("Hold") else "Click")
	auxiliary_fire_mode = fire_mode
	audio = SilentActor.new()
	presentation = SilentHUD.new()
	add_child(presentation)
	bow = Node3D.new()
	dagger = Node3D.new()
	shield_ring = Spatial.new()
	crosshair = Label.new()
	for node in [bow, dagger, crosshair]: add_child(node)
	for ability in Progress.design().settings.abilities:
		var key = str(Progress.design().enums.AbilityType[str(int(ability.abilityType))])
		abilities[key] = {"active": 0.0, "cooldown": 0.0, "duration": float(ability.abilityDuration), "wait": float(ability.cooldownDuration)}
	for number in range(1, 4): _build_section(number)
	horizontal_override = 0.0

func fast_combat_assist_enabled() -> bool: return true
func _read_horizontal(_delta): return 0.0
func _update_camera_presentation(): pass
func _update_dagger_presentation(): pass
func _launch_dagger(_target): pass
func _aim_pointer() -> Vector2: return Vector2.ZERO
func _aim_direction() -> Vector3: return Vector3.FORWARD
func _aim_origin() -> Vector3: return player_position
func _aim_point() -> Vector3: return Vector3.ZERO
func _bow_muzzle() -> Vector3: return Vector3.ZERO
func _update_bow_aim(): pass
func _update_hud(): pass
func _update_gates(_delta): pass
func _open_gate(_corridor): pass
func _beam_effect(_target): pass
func _floating_text(_pos, _text, _color, _currency = false): pass

func _auto_activate_abilities():
	if ended: return
	for key in abilities:
		if unlocked(key) and abilities[key].active <= 0 and abilities[key].cooldown <= 0:
			abilities[key].active = abilities[key].duration

func _box(_parent, pos, _dimensions, _color) -> Spatial:
	var node = Spatial.new()
	node.position = pos
	return node

func _weapon_mesh(_mesh, _parent, pos, _size, _prefab = "") -> Spatial:
	var node = Spatial.new()
	node.position = pos
	return node

func _flight_projectile(_kind, pos, _hostile = false) -> Spatial:
	return _box(null, pos, Vector3.ZERO, Color.WHITE)

func _ring(parent, pos, _color, _radius) -> Spatial:
	return _box(parent, pos, Vector3.ZERO, Color.WHITE)

func _source_billboard(node, _image, _height, _prefab = ""): return node

func _finish(won):
	if ended: return
	ended = true
	won_run = won
	data.runs += 1
	data.kills += run_kills
	data.best_distance = maxf(data.best_distance, distance)
'''
section = functions['_build_section']
section = section[:section.index('\tvar modern :=')] + section[section.index('\tvar layout: Array'):section.index('\tfor old in sections')]
section = section.replace('Node3D.new()', 'Spatial.new()').replace('\tadd_child(root)\n', '')
spawn = functions['_spawn_enemy']
spawn = spawn[:spawn.index('\tvar actor :=')] + '''\tvar actor = SilentActor.new()
	randf() # Actor.setup consumes an idle-phase draw; keep combat RNG aligned.
	root.add_child(actor)
	var label = SilentLabel.new()
''' + spawn[spawn.index('\tvar prestige_level'):]
spawn = spawn.replace('Node3D.new()', 'Spatial.new()').replace('\tadd_child(root)\n', '')
model = header + '\n' + custom + '\n' + section + '\n' + spawn
for name in keep:
    body = functions[name].replace('Graphics.original()', 'false').replace('Style.GOLD', 'Color.GOLD')
    if name == '_simulate_step':
        body = body.replace('\tif editor_autopilot_enabled(): _step_editor_pilot(delta)\n','')
        start = body.index('\tfootstep_timer -= delta')
        end = body.index('\tif -player_position.z >= next_section_trigger:')
        body = body[:start] + body[end:]
    if name == '_update_enemies':
        start = body.index('\t\tif enemy.effect != "":')
        end = body.index('\t\tvar offset: Vector3')
        body = body[:start] + body[end:]
        body = body.replace('\t\tif not enemy.boss and offset.z < 0 and offset.length() < 2.8:\n\t\t\tenemy.actor.windup()\n', '')
    if name == '_hit':
        body = body[:body.index('\t\tvar death :=')] + '\t\tenemy.node.queue_free()\n\n'
        body = body.replace('\tenemy.hp -= amount', '''\tdamage_dealt += minf(maxf(enemy.hp, 0.0), amount)
	if first_death and enemy.hp <= amount:
		var gap = Vector2(enemy.node.position.x - player_position.x, enemy.node.position.z - player_position.z).length()
		kill_records.append({"time": elapsed, "distance": distance, "kind": enemy.kind, "boss": enemy.boss, "range": gap, "range_fraction": gap / s("Distance_Range"), "ahead": player_position.z - enemy.node.position.z})
	enemy.hp -= amount''')
        body = body.replace('Util.get_number_short_text(amount)', 'str(amount)')
    if name == '_heal':
        body = body.replace('\thealth =', '\thealing_received += minf(amount, maxf(0.0, s("MaxHP") - health))\n\thealth =').replace('Util.get_number_short_text(amount)', 'str(amount)')
    if name == '_update_powerups':
        body = body.replace('\t\thealth =', '\t\tvar health_before_regen = health\n\t\thealth =')
        body = body.replace('\tfor state in abilities.values():', '\t\thealing_received += maxf(0, health - health_before_regen)\n\tfor state in abilities.values():')
    if name == '_damage_player':
        body = body.replace('\tif ended: return', '\tif ended: return\n\tif source == "the row": amount *= row_damage_scale')
    body = '\n'.join(line for line in body.split('\n') if not any(token in line for token in ['_floating_text(', 'enemy.label.text =', 'presentation.toast(', 'crosshair.modulate =', 'presentation.feedback.color.a =']))
    body = re.sub(r'(\w+\.node)\.queue_free\(\)', r'_retire(\1)', body)
    if name == '_simulate_step':
        body = body.rstrip() + '\n\t_flush_retired()\n'
    model += '\n' + body
out = MODULE / 'Simulation'
out.mkdir(exist_ok=True)
(out / 'GeneratedCombatModel.gd').write_text(model, encoding='utf-8')
flight = model.replace('var free_aim_mode = false # Offline classic assisted mode.', 'var free_aim_mode = true')
flight = flight.replace('func fast_combat_assist_enabled() -> bool: return true', 'func fast_combat_assist_enabled() -> bool: return false')
flight = flight.replace('\tfor number in range(1, 4): _build_section(number)',
    '\tcorridor_width = 1.4\n\tfor number in range(1, 4): _build_section(number)\n\tfire_waves.setup(int(data.prestige), randi(), Progress.design().settings.get("fire_waves", {}))')
flight = flight.replace('func _aim_direction() -> Vector3: return Vector3.FORWARD',
    'func _aim_direction() -> Vector3: return aim_override.normalized() if aim_override.is_finite() else Vector3.FORWARD')
flight = flight.replace('func _aim_origin() -> Vector3: return player_position', functions['_aim_origin'].replace('Graphics.original()', 'true'))
flight = flight.replace('func _aim_point() -> Vector3: return Vector3.ZERO', functions['_aim_point'])
flight = flight.replace('func _bow_muzzle() -> Vector3: return Vector3.ZERO', 'func _bow_muzzle() -> Vector3: return player_position + Vector3(0.18, 0.55, -0.45)')
(out / 'GeneratedFreeAimModel.gd').write_text(flight, encoding='utf-8')
(out / 'source_manifest.json').write_text(json.dumps({
    'source': 'Games/RowDivers/Scenes/RowDiversBattleScene.gd',
    'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
    'catalog_sha256': hashlib.sha256((MODULE / 'Data/row_divers.json').read_bytes()).hexdigest(),
    'progression_sha256': hashlib.sha256((MODULE / 'RowDiversProgress.gd').read_bytes()).hexdigest(),
    'methods': {name: hashlib.sha256(functions[name].encode()).hexdigest() for name in keep},
    'replacements': 'No rendering/audio, HUD, gates animation, save writes, or input polling; record damage/healing/kill distances; always enable existing assist; same spawn RNG and combat order.'
}, indent=2), encoding='utf-8')
print(out / 'GeneratedCombatModel.gd')
