extends Node
var music: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var next_effect = 0
var streams: Dictionary = {}

func _ready() -> void:
	music = AudioStreamPlayer.new()
	music.volume_db = -22
	music.bus = "Music"
	add_child(music)
	for i in range(8):
		var player = AudioStreamPlayer.new()
		player.volume_db = -13
		player.bus = "Effects"
		add_child(player)
		effects.append(player)

func play_music(battle: bool) -> void:
	var path = "res://Games/RowDivers/Audio/battle.wav" if battle else "res://Games/RowDivers/Audio/upgrades.wav"
	if ResourceLoader.exists(path):
		music.stream = load(path)
		if music.stream is AudioStreamWAV:
			music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			music.stream.loop_end = int(music.stream.get_length() * music.stream.mix_rate)
		music.play()

func sound(cue: String) -> void:
	var path = "res://Games/RowDivers/Audio/" + cue + ".wav"
	if ResourceLoader.exists(path):
		if not streams.has(cue): streams[cue] = load(path)
		var player = effects[next_effect % effects.size()]
		next_effect += 1
		player.stream = streams[cue]
		player.volume_db = -24.0 if cue == "step" else -13.0
		player.pitch_scale = randf_range(0.94, 1.06)
		player.play()
