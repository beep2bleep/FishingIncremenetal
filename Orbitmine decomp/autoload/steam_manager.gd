extends Node






var is_steam_running: bool = false


const ACHIEVEMENTS = {
    "ACH_FIRST_SORTIE": "첫 출항", 
    "ACH_FIRST_CORE": "첫 코어 파괴", 
    "ACH_BOSS_SPRING": "봄 보스 격파", 
    "ACH_BOSS_SUMMER": "여름 보스 격파", 
    "ACH_BOSS_AUTUMN": "가을 보스 격파", 
    "ACH_BOSS_WINTER": "겨울 보스 격파", 
    "ACH_CLEAR_SPRING": "봄 정복", 
    "ACH_CLEAR_SUMMER": "여름 정복", 
    "ACH_CLEAR_AUTUMN": "가을 정복", 
    "ACH_CLEAR_WINTER": "겨울 정복", 
    "ACH_FINAL_BOSS": "최종 보스 격파", 
    "ACH_FULL_CLEAR": "100% 클리어", 
}

func _ready():
    _init_steam()

func _init_steam():
    if not Engine.has_singleton("Steam"):
        print("[Steam] Steam 싱글톤 없음 — 에디터 모드이거나 Steam 미실행")
        return

    var steam = Engine.get_singleton("Steam")
    var init_result = steam.steamInitEx(false, 4489770)
    print("[Steam] 초기화 결과: ", init_result)

    if init_result.status == 0:
        is_steam_running = true
        print("[Steam] ✅ Steam 연결 성공!")
    else:
        print("[Steam] ❌ Steam 연결 실패: ", init_result.verbal)

func _process(_delta):
    if is_steam_running:
        Engine.get_singleton("Steam").run_callbacks()


func unlock(achievement_id: String):
    if not is_steam_running:
        print("[Steam] 업적 해금 (오프라인): %s" % achievement_id)
        return

    var steam = Engine.get_singleton("Steam")
    var achieved = steam.getAchievement(achievement_id)
    if achieved.achieved:
        return

    steam.setAchievement(achievement_id)
    steam.storeStats()
    print("[Steam] 🏆 업적 해금: %s" % achievement_id)


func reset_all():
    if not is_steam_running:
        return
    var steam = Engine.get_singleton("Steam")
    steam.resetAllStats(true)
    print("[Steam] 업적 전부 초기화")
