extends Node







const SOUNDS: Dictionary = {

    "laser_fire": {"path": "res://sounds/laser_fire.wav", "volume": -18.0, "max": 3}, 
    "block_destroy": {"path": "res://sounds/block_destroy.wav", "volume": -14.0, "max": 4}, 
    "resource_pickup": {"path": "res://sounds/resource_pickup.wav", "volume": -16.0, "max": 3}, 


    "barrier_hit": {"path": "res://sounds/barrier_hit.wav", "volume": -8.0, "max": 2}, 
    "barrier_break": {"path": "res://sounds/barrier_break.wav", "volume": -4.0, "max": 1}, 
    "critical_hit": {"path": "res://sounds/critical_hit.wav", "volume": -8.0, "max": 2}, 
    "ui_click": {"path": "res://sounds/ui_click.wav", "volume": -10.0, "max": 2}, 
    "hover_tick": {"path": "res://sounds/hover_tick.wav", "volume": -16.0, "max": 1}, 
    "purchase": {"path": "res://sounds/purchase.wav", "volume": -8.0, "max": 4}, 


    "core_destroy": {"path": "res://sounds/core_destroy.wav", "volume": -2.0, "max": 1}, 
    "mega_laser": {"path": "res://sounds/mega_laser.wav", "volume": -4.0, "max": 1}, 
    "overdrive": {"path": "res://sounds/overdrive.wav", "volume": -14.0, "max": 1}, 
    "shockwave": {"path": "res://sounds/shockwave.wav", "volume": -6.0, "max": 1}, 


    "chain_lightning": {"path": "res://sounds/chain_lightning.wav", "volume": -12.0, "max": 3}, 
    "electric_chain": {"path": "res://sounds/electric_chain.wav", "volume": -8.0, "max": 2}, 
    "warp": {"path": "res://sounds/warp.wav", "volume": -6.0, "max": 1}, 
}


const BGM_PATH: = "res://sounds/bgm.mp3"
const BGM_VOLUME_DB: float = -12.0


var _streams: Dictionary = {}


var _active: Dictionary = {}


var _bgm_player: AudioStreamPlayer = null


var bgm_volume: float = 1.0:
    set(v):
        bgm_volume = clampf(v, 0.0, 1.0)
        if _bgm_player:
            _bgm_player.volume_db = BGM_VOLUME_DB + linear_to_db(maxf(bgm_volume, 0.001))

var sfx_volume: float = 1.0:
    set(v):
        sfx_volume = clampf(v, 0.0, 1.0)


var muted: bool = false:
    set(v):
        muted = v
        if _bgm_player:
            if muted:
                _bgm_player.stop()
            elif not _bgm_player.playing:
                _bgm_player.play()

func _ready():

    for id in SOUNDS:
        var stream = load(SOUNDS[id].path)
        if stream:
            _streams[id] = stream
        else:
            push_warning("[SoundManager] 로드 실패: %s" % SOUNDS[id].path)

    print("[SoundManager] 초기화 완료: %d개 사운드 로드" % _streams.size())


    _bgm_player = AudioStreamPlayer.new()
    var bgm_stream = load(BGM_PATH)
    if bgm_stream:
        _bgm_player.stream = bgm_stream
        _bgm_player.volume_db = BGM_VOLUME_DB
        _bgm_player.autoplay = true

        add_child(_bgm_player)
        _bgm_player.finished.connect(_on_bgm_finished)
        print("[SoundManager] 🎵 BGM 재생 시작")
    else:
        push_warning("[SoundManager] BGM 로드 실패: %s" % BGM_PATH)


func _on_bgm_finished():
    if _bgm_player and not muted:
        _bgm_player.play()


func play(sound_id: String, pitch: float = 1.0):
    if muted:
        return

    if not _streams.has(sound_id):
        push_warning("[SoundManager] 없는 사운드: %s" % sound_id)
        return

    var config = SOUNDS[sound_id]


    _cleanup_finished(sound_id)
    if _active.has(sound_id) and _active[sound_id].size() >= config.max:
        return


    var player = AudioStreamPlayer.new()
    player.stream = _streams[sound_id]
    player.volume_db = config.volume + linear_to_db(maxf(sfx_volume, 0.001))
    if pitch != 1.0:
        player.pitch_scale = pitch
    player.finished.connect(_on_player_finished.bind(player, sound_id))
    add_child(player)
    player.play()


    if not _active.has(sound_id):
        _active[sound_id] = []
    _active[sound_id].append(player)


func _cleanup_finished(sound_id: String):
    if not _active.has(sound_id):
        return
    var alive: Array = []
    for p in _active[sound_id]:
        if is_instance_valid(p) and p.playing:
            alive.append(p)
        elif is_instance_valid(p):
            p.queue_free()
    _active[sound_id] = alive


func _on_player_finished(player: AudioStreamPlayer, sound_id: String):
    if is_instance_valid(player):
        player.queue_free()
    if _active.has(sound_id):
        _active[sound_id].erase(player)


func stop_all():
    for id in _active:
        for p in _active[id]:
            if is_instance_valid(p):
                p.stop()
                p.queue_free()
    _active.clear()
