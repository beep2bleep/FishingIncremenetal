extends Node







var counter: int = 0
var active: bool = false
var timer: float = 0.0


var trail: Array = []
const TRAIL_MAX: int = 12
const TRAIL_INTERVAL: float = 0.03
var trail_timer: float = 0.0


var ship: CharacterBody2D

func _ready():
    ship = get_parent()



func update(delta: float):
    if active:
        timer -= delta
        if timer <= 0:
            _end()
        else:

            trail_timer += delta
            if trail_timer >= TRAIL_INTERVAL:
                trail_timer = 0.0
                trail.append({"pos": ship.global_position, "rot": ship.visual_rotation, "alpha": 0.6})
                if trail.size() > TRAIL_MAX:
                    trail.remove_at(0)

            for i in range(trail.size()):
                trail[i].alpha -= delta * 2.5

            trail = trail.filter( func(t): return t.alpha > 0.02)
    else:

        if trail.size() > 0:
            for i in range(trail.size()):
                trail[i].alpha -= delta * 4.0
            trail = trail.filter( func(t): return t.alpha > 0.02)



func on_block_destroyed():
    if not Global.overdrive_unlocked or active:
        return
    counter += 1
    if counter >= Global.overdrive_kill_need:
        counter = 0
        _activate()



func _activate():
    active = true
    timer = Global.overdrive_duration
    ship.sortie_stats.overdrive_count += 1
    Global.request_shake(3.0, 0.3)
    SoundManager.play("overdrive")
    ScreenFX.overdrive_activate()
    print("[Ship] 💢 오버드라이브 발동! %.1f초" % Global.overdrive_duration)



func _end():
    active = false
    timer = 0.0
    print("[Ship] 💢 오버드라이브 종료")
