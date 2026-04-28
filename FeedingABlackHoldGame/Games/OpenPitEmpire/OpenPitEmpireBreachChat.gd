extends RefCounted
class_name OpenPitEmpireBreachChat

const CHAT_TITLE := "[color=#7dd6ff]BLACK CHANNEL // SUMP-9[/color]"
const WINDOW_SECONDS := 10.0

const FRIENDS := [
    {"id": "mothbit", "display": "mothbit", "color": "#86ffd1"},
    {"id": "undertow", "display": "Undertow", "color": "#7cc6ff"},
    {"id": "saintzero", "display": "saintzero", "color": "#d8d38a"},
    {"id": "taxhound", "display": "Taxhound", "color": "#ff9d78"},
    {"id": "feralroot", "display": "feralroot", "color": "#c89dff"},
    {"id": "chapelNull", "display": "chapelNull", "color": "#ff7ab6"},
]

const ENEMIES := {
    1: {"id": "GlassAudit", "display": "GlassAudit", "color": "#ff7c7c"},
    2: {"id": "PatentSaint", "display": "PatentSaint", "color": "#ff9580"},
    3: {"id": "NullMeridian", "display": "NullMeridian", "color": "#ff6f6f"},
    4: {"id": "CrownLedger", "display": "CrownLedger", "color": "#ff5252"},
}

const THREADS := [
    {
        "id": "clinic",
        "lines": [
            {"speaker": "mothbit", "text": "floodplain clinic says thanks for the dialysis filters. corporate invoiced them for rain again."},
            {"speaker": "taxhound", "text": "OmniLedger called it a weather premium. I called it a confession and moved the receipts."},
            {"speaker": "undertow", "text": "Do not say ledger baptism in front of interns. They think it is a real filing term."},
            {"speaker": "chapelNull", "text": "it is a real filing term now. the room voted while you were busy."},
            {"speaker": "saintzero", "text": "every layer we break loosens one more private lock on medicine. keep the pilot moving."},
        ],
    },
    {
        "id": "library",
        "lines": [
            {"speaker": "saintzero", "text": "library moon fund is short three servers and one very tired lawyer."},
            {"speaker": "feralroot", "text": "I got the lawyer. keep the moon. also somebody stop mothbit from buying dead mall clocks with campaign money."},
            {"speaker": "mothbit", "text": "the clocks are for morale and for the archive. same thing if you squint."},
            {"speaker": "undertow", "text": "Room ruling: dead mall clocks stay, but only if they still smell faintly electrical."},
            {"speaker": "taxhound", "text": "This breach is paying for cold storage the board wanted deleted. History is getting a second body."},
        ],
    },
    {
        "id": "ferrets",
        "lines": [
            {"speaker": "taxhound", "text": "municipal ferret union got their server back. they sent a fruit basket and one threat."},
            {"speaker": "chapelNull", "text": "respect the ferrets. they were the first group to understand escrow violence."},
            {"speaker": "saintzero", "text": "their treasurer still signs mail with soup keys forever. blessed discipline."},
            {"speaker": "mothbit", "text": "soup keys forever."},
            {"speaker": "feralroot", "text": "funny room joke aside, those payroll locks were real. your pilot is cutting loose more than mascots."},
        ],
    },
    {
        "id": "causeway",
        "lines": [
            {"speaker": "undertow", "text": "Salt caucus blocked the toll cameras for two hours. The trucks got through clean."},
            {"speaker": "feralroot", "text": "meanwhile the corporation wrote a statement about community inconvenience. real tragedy for their cameras."},
            {"speaker": "taxhound", "text": "I billed them for grief counseling and route confusion."},
            {"speaker": "chapelNull", "text": "invoice the concept of ownership next. see if it blinks."},
            {"speaker": "undertow", "text": "That is what this breach is for. We are cutting open the toll teeth, the debt teeth, the ration teeth."},
        ],
    },
    {
        "id": "water",
        "lines": [
            {"speaker": "saintzero", "text": "remember the desal cooperatives. Helix Meridian throttled them for quarterly optics."},
            {"speaker": "taxhound", "text": "Their water futures desk called thirst a market signal. I kept the memo."},
            {"speaker": "undertow", "text": "The pilot is chewing through the same ledger stack that priced whole districts out of clean taps."},
            {"speaker": "mothbit", "text": "good. let the pipes learn a new owner."},
        ],
    },
]

var rng := RandomNumberGenerator.new()
var queued_lines: Array[Dictionary] = []
var recent_attacks: Array[float] = []
var recent_money: Array[Dictionary] = []
var time_alive := 0.0
var next_generation_time := 0.0
var next_summary_time := 11.0
var next_thread_time := 24.0
var best_window_money := 0
var best_window_nodes := 0
var last_announced_money := 0
var last_announced_nodes := 0
var last_layer_depth := -1
var seen_layers: Dictionary = {}
var active_thread_id := ""
var thread_progress: Dictionary = {}
var used_threads: Dictionary = {}
var pressure_signature := ""
var final_core_exposed := false
var final_core_destroyed := false
var final_epilogue_lines: Array[String] = []
var emitted_exact_lines: Dictionary = {}
var emitted_event_signatures: Dictionary = {}
var ambient_cooldown_until := 0.0
var node_hit_counts: Dictionary = {}
var suspicion_level := 0
var hint_stage := 0
var persistent_line_counts: Dictionary = {}
var persistent_thread_counts: Dictionary = {}

func reset_for_run(depth_level: int, source_rng: RandomNumberGenerator = null, line_counts: Dictionary = {}, thread_counts: Dictionary = {}) -> void:
    rng = RandomNumberGenerator.new()
    rng.seed = source_rng.randi() if source_rng != null else Time.get_unix_time_from_system()
    queued_lines.clear()
    recent_attacks.clear()
    recent_money.clear()
    time_alive = 0.0
    next_generation_time = 6.0
    next_summary_time = 11.0
    next_thread_time = 24.0
    best_window_money = 0
    best_window_nodes = 0
    last_announced_money = 0
    last_announced_nodes = 0
    last_layer_depth = -1
    seen_layers.clear()
    active_thread_id = ""
    thread_progress.clear()
    used_threads.clear()
    pressure_signature = ""
    final_core_exposed = false
    final_core_destroyed = false
    final_epilogue_lines.clear()
    emitted_exact_lines.clear()
    emitted_event_signatures.clear()
    ambient_cooldown_until = 0.0
    node_hit_counts.clear()
    suspicion_level = 0
    hint_stage = 0
    persistent_line_counts = line_counts.duplicate(true)
    persistent_thread_counts = thread_counts.duplicate(true)
    _queue_room_intro(depth_level)

func get_persistent_line_counts() -> Dictionary:
    return persistent_line_counts.duplicate(true)

func get_persistent_thread_counts() -> Dictionary:
    return persistent_thread_counts.duplicate(true)

func get_title() -> String:
    return CHAT_TITLE

func drain_ready_lines(force_all: bool = false) -> Array[String]:
    var ready: Array[String] = []
    for idx in range(queued_lines.size() - 1, -1, -1):
        var entry: Dictionary = queued_lines[idx]
        if force_all or float(entry.get("time", 0.0)) <= time_alive:
            ready.push_front(str(entry.get("line", "")))
            queued_lines.remove_at(idx)
    return ready

func update(delta: float, snapshot: Dictionary) -> void:
    time_alive += delta
    _trim_windows()
    _react_to_snapshot(snapshot)
    if time_alive < next_generation_time:
        return
    if _try_generate_summary(snapshot):
        next_generation_time = time_alive + rng.randf_range(9.0, 16.0)
        return
    if time_alive >= next_thread_time and _should_emit_thread(snapshot) and _advance_thread():
        next_generation_time = time_alive + rng.randf_range(12.0, 22.0)
        next_thread_time = time_alive + rng.randf_range(24.0, 40.0)
        return
    if time_alive >= ambient_cooldown_until and rng.randf() < 0.1:
        _queue_ambient_line(snapshot)
        ambient_cooldown_until = time_alive + rng.randf_range(24.0, 38.0)
        next_generation_time = time_alive + rng.randf_range(14.0, 24.0)
        return
    next_generation_time = time_alive + rng.randf_range(6.0, 10.0)

func record_node_destroyed(is_core: bool = false) -> void:
    recent_attacks.append(time_alive)
    if is_core:
        recent_attacks.append(time_alive)
        recent_attacks.append(time_alive)
        suspicion_level = mini(suspicion_level + 2, 10)
    else:
        suspicion_level = mini(suspicion_level + 1, 10)

func record_money(amount: int) -> void:
    if amount <= 0:
        return
    recent_money.append({"time": time_alive, "amount": amount})

func notify_node_engaged(core_id: int, zone: int, role: String, shielded: bool = false) -> void:
    var zone_name := _zone_name(zone)
    var tier := _zone_enemy_tier(zone)
    if shielded:
        var shield_lines := [
            "[b]You are pressing against a locked node.[/b] It will not open for you.",
            "[b]That node is sealed.[/b] Keep scraping at it if you need the humiliation.",
            "[b]Access denied.[/b] You are not even speaking to the right layer yet.",
        ]
        _queue_enemy_line(
            mini(4, maxi(1, tier)),
            shield_lines[rng.randi_range(0, shield_lines.size() - 1)],
            0.0,
            "engaged_shielded_%d" % core_id
        )
        return
    var engage_lines := [
        "There you are. [b]Step away from this node.[/b]",
        "You felt that pushback, yes? [b]That is us.[/b]",
        "[b]Hands off this node.[/b] It is already fighting you.",
    ]
    var event_key := "engaged_%d" % core_id
    if role == "boss":
        engage_lines = [
            "So you finally touched a command node. [b]Bad choice.[/b]",
            "[b]You are inside live executive infrastructure now.[/b]",
            "That resistance you feel is deliberate. [b]Back off.[/b]",
        ]
        event_key = "engaged_boss_%d" % core_id
    elif role == "final":
        engage_lines = [
            "No. [b]Do not touch that node.[/b]",
            "[b]You do not get to speak to the center.[/b]",
            "That is the heart. [b]Remove your hands.[/b]",
        ]
        event_key = "engaged_final_%d" % core_id
    _queue_enemy_line(
        mini(4, maxi(1, tier)),
        engage_lines[rng.randi_range(0, engage_lines.size() - 1)],
        0.0,
        event_key
    )
    if rng.randf() < 0.6:
        _queue_unique_variant_message(_friend_id(rng.randi_range(0, FRIENDS.size() - 1)), [
            "heard that? good. the node knows you are there now.",
            "that is them pushing back through the shell. keep cutting.",
            "there it is. the node is talking because it is scared.",
        ], [], "engaged_reply_%d" % core_id, 1.0)

func notify_node_landed_hit(core_id: int, zone: int, role: String, barriers_left: int) -> void:
    var tier := _zone_enemy_tier(zone)
    var hit_count := int(node_hit_counts.get(core_id, 0)) + 1
    node_hit_counts[core_id] = hit_count
    var speak_key := ""
    var enemy_lines: Array[String] = []
    if hit_count == 1:
        speak_key = "node_hit_first_%d" % core_id
        enemy_lines = [
            "There. [b]You felt that.[/b]",
            "[b]That node just hit back.[/b] Learn from it.",
            "Yes. [b]It can hurt you.[/b]",
        ]
    elif hit_count >= 3 and hit_count < 5:
        speak_key = "node_hit_repeat_%d" % core_id
        enemy_lines = [
            "Still here? [b]It is going to keep peeling you apart.[/b]",
            "[b]You keep offering yourself to the node.[/b] Strange habit.",
            "That is not bad luck. [b]That is resistance finding you on purpose.[/b]",
        ]
    elif barriers_left <= 1:
        speak_key = "node_hit_low_%d" % core_id
        enemy_lines = [
            "[b]You are almost out of shielding.[/b] We can all hear it.",
            "One more good strike and [b]you are done.[/b]",
            "[b]You are running out of ways to stay alive.[/b]",
        ]
    if speak_key != "" and not enemy_lines.is_empty():
        _queue_enemy_line(
            mini(4, maxi(1, tier + (1 if role == "boss" or role == "final" else 0))),
            enemy_lines[rng.randi_range(0, enemy_lines.size() - 1)],
            0.0,
            speak_key
        )
    if barriers_left <= 1 and rng.randf() < 0.35:
        _queue_unique_variant_message(_friend_id(rng.randi_range(0, FRIENDS.size() - 1)), [
            "easy now. one barrier left.",
            "they clipped you. do not give them the next one.",
            "last barrier. stay colder than they are.",
        ], [], "node_hit_reply_low_%d" % core_id, 0.9)

func notify_core_destroyed(core: Dictionary) -> void:
    var core_id: int = int(core.get("id", -1))
    var role: String = str(core.get("role", "outer"))
    var zone_name := _zone_name(int(core.get("zone", 0)))
    if role == "final":
        notify_final_core_destroyed()
        return
    var speaker := _friend_id(rng.randi_range(0, FRIENDS.size() - 1))
    _queue_unique_event("core_%d" % core_id, speaker, "node %d just folded in %s. somebody put that shard where the suits cannot pray over it." % [core_id, zone_name], 0.0)
    _queue_unique_variant_message(_friend_id(rng.randi_range(0, FRIENDS.size() - 1)), [
        "nice. one more private choke point off the board.",
        "good cut. that shard pays somebody's way out.",
        "there it is. one more lock broken where it mattered.",
    ], [], "core_cheer_%d" % core_id, 0.9)
    var core_enemy_lines := [
        "You are vandalizing protected infrastructure.",
        "That node was not yours to touch.",
        "Enjoy the applause while it lasts. We can still close this around you.",
    ]
    _queue_enemy_line(
        mini(4, maxi(1, _zone_enemy_tier(int(core.get("zone", 0))))),
        core_enemy_lines[rng.randi_range(0, core_enemy_lines.size() - 1)],
        1.7,
        "core_enemy_%d" % core_id
    )
    if role == "boss":
        suspicion_level = mini(suspicion_level + 2, 10)
        _queue_unique_event("boss_%d" % core_id, "undertow", "%s oversight just lost a throat. Keep the rig moving before they remember panic procedures." % zone_name, 1.4)
        var boss_enemy_lines := [
            "[b]That core was under executive protection.[/b]",
            "[b]You have just crossed into executive retaliation territory.[/b]",
            "[b]You are done here.[/b] We are finished treating this like noise.",
        ]
        _queue_enemy_line(
            mini(4, maxi(2, _zone_enemy_tier(int(core.get("zone", 0))) + 1)),
            boss_enemy_lines[rng.randi_range(0, boss_enemy_lines.size() - 1)],
            2.1,
            "boss_enemy_%d" % core_id
        )

func notify_defense_challenge_started(core: Dictionary, defense_name: String) -> void:
    var core_id: int = int(core.get("id", -1))
    var zone_name := _zone_name(int(core.get("zone", 0)))
    _queue_enemy_line(
        mini(4, maxi(2, _zone_enemy_tier(int(core.get("zone", 0))) + 1)),
        "[b]Command node %d is pushing back.[/b] %s protocols are live." % [core_id, defense_name],
        0.0,
        "defense_start_%d" % core_id
    )
    _queue_unique_variant_message("undertow", [
        "%s command node hit zero and threw a defense screen. clear it and the node dies for real.",
        "that node is refusing death with a %s defense. rude, expensive, and beatable.",
        "%s defense just lit up. take the side fight; we will hold the breach open."
    ], [defense_name], "defense_reply_%d" % core_id, 0.9)
    _queue_unique_event("defense_zone_%d" % core_id, "taxhound", "%s oversight bought a panic room. let's repossess it." % zone_name, 1.7)

func notify_defense_challenge_failed(core_id: int, defense_name: String) -> void:
    _queue_enemy_line(
        mini(4, maxi(2, _zone_enemy_tier(OpenPitEmpirePlanetData.get_core_zone(core_id)) + 1)),
        "[b]%s held.[/b] The node has restored itself to emergency health. Try not to make this inspirational." % defense_name,
        0.0,
        "defense_fail_%d" % core_id
    )
    _queue_unique_variant_message("chapelNull", [
        "bad news: the node got half its spine back. good news: it only gets that trick once.",
        "they spent a whole countermeasure just to go back to fifty percent. deeply embarrassing budget behavior.",
        "reset to half health. fine. hit it again and make the accounting louder."
    ], [], "defense_fail_reply_%d" % core_id, 1.0)

func notify_defense_challenge_succeeded(core_id: int, defense_name: String) -> void:
    _queue_unique_event("defense_success_%d" % core_id, "mothbit", "%s cracked. command node has no second argument with physics." % defense_name, 0.0)
    _queue_enemy_line(
        mini(4, maxi(2, _zone_enemy_tier(OpenPitEmpirePlanetData.get_core_zone(core_id)) + 1)),
        "[b]Defense screen lost.[/b] This node is not authorized to die.",
        1.0,
        "defense_success_enemy_%d" % core_id
    )

func notify_final_core_exposed() -> void:
    if final_core_exposed:
        return
    final_core_exposed = true
    _queue_enemy_line(4, "No. [b]That seal was not supposed to open from the outside.[/b]", 0.0, "final_exposed_enemy")
    _queue_message("chapelNull", "center shell is open. everybody breathe once and get mean.", 1.3)
    _queue_message("saintzero", "for the clinic, the moon archive, the ferrets, all of it. finish the work.", 2.4)
    _queue_message("undertow", "You are looking at the part of the machine that turns hunger, medicine, and water into yield. End it.", 3.0)

func notify_final_core_destroyed() -> void:
    if final_core_destroyed:
        return
    final_core_destroyed = true
    _queue_enemy_line(4, "[b]You do not get to write the closing ledger.[/b]", 0.0, "final_destroyed_enemy")
    _queue_message("mothbit", "too late. the room already did.", 1.2)
    _queue_message("undertow", "Core is down. Black budgets are spilling into daylight.", 2.2)
    _queue_message("taxhound", "sending copies to every cause they laughed at. soup keys forever.", 3.1)
    final_epilogue_lines = [
        _format_summary_line("mothbit", "The room called the breach clean. Debt engines opened and their receipts started to fall."),
        _format_summary_line("CrownLedger", "Corporate channel collapse confirmed. Containment failed at the heart."),
        _format_summary_line("undertow", "Funds are moving to the floodplain clinic, the library moon fund, the desal cooperatives, and every other impossible little cause they mocked."),
    ]

func build_summary_epilogue() -> String:
    if final_epilogue_lines.is_empty():
        return ""
    return "\n\n" + "[color=#7dd6ff]Room Aftermath[/color]\n" + "\n".join(final_epilogue_lines)

func _react_to_snapshot(snapshot: Dictionary) -> void:
    var layer_depth: int = int(snapshot.get("layer_depth", 1))
    if layer_depth != last_layer_depth:
        last_layer_depth = layer_depth
        if not seen_layers.has(layer_depth):
            seen_layers[layer_depth] = true
            _queue_layer_intro(layer_depth, str(snapshot.get("layer_name", "Proxy Cache")))
    var pressure_stage: int = int(snapshot.get("core_pressure_stage", 0))
    var pressure_tier: int = int(snapshot.get("core_pressure_tier", 0))
    var pressure_zone: String = str(snapshot.get("core_pressure_zone", "surface"))
    var signature := "%d:%d:%s" % [pressure_stage, pressure_tier, pressure_zone]
    if pressure_stage > 0 and signature != pressure_signature:
        pressure_signature = signature
        _queue_pressure_exchange(pressure_stage, pressure_tier, pressure_zone)
    elif pressure_stage == 0:
        pressure_signature = ""
    _advance_identity_hunt(snapshot)
    if bool(snapshot.get("final_core_exposed", false)):
        notify_final_core_exposed()

func _advance_identity_hunt(snapshot: Dictionary) -> void:
    var layer_depth: int = int(snapshot.get("layer_depth", 1))
    if hint_stage == 0 and (recent_attacks.size() >= 5 or layer_depth >= 2):
        hint_stage = 1
        _queue_enemy_line(1, "Unknown signal in the shell. [b]Probably a scavenger.[/b] Keep logging them.", 0.0, "hunt_1")
    elif hint_stage == 1 and (suspicion_level >= 4 or layer_depth >= 3):
        hint_stage = 2
        _queue_message("taxhound", "they are skipping vanity ledgers and chewing only live extortion infrastructure. that is a person with a grudge map.", 0.7)
        _queue_enemy_line(2, "Cross-reference the breach path. [b]This intruder knows our debt lattice.[/b]", 0.0, "hunt_2")
    elif hint_stage == 2 and (suspicion_level >= 7 or layer_depth >= 4):
        hint_stage = 3
        _queue_message("undertow", "they followed the clinic throttles, the desal throttles, the ration throttles. the room sees the purpose now.", 0.6)
        _queue_enemy_line(3, "Pull civic case files, leaked audits, the floodplain injunctions. [b]Find the activist with a ship.[/b]", 0.0, "hunt_3")
    elif hint_stage == 3 and (final_core_exposed or suspicion_level >= 9):
        hint_stage = 4
        _queue_enemy_line(4, "We have you. [b]Floodplain breach survivor. Mutual-aid pilot. You came for the ration engine itself.[/b]", 0.0, "hunt_4")
        _queue_message("chapelNull", "congrats on being doxxed by panicked aristocrats. finish the breach anyway.", 0.9)

func _try_generate_summary(snapshot: Dictionary) -> bool:
    if time_alive < next_summary_time:
        return false
    var nodes: int = recent_attacks.size()
    var money := _recent_money_total()
    next_summary_time = time_alive + rng.randf_range(12.0, 22.0)
    if nodes <= 0 and money <= 0:
        return false
    var dramatic_money := money >= 600 and (money >= last_announced_money + 350 or money >= int(float(maxi(1, last_announced_money)) * 1.6))
    var dramatic_nodes := nodes >= 7 and (nodes >= last_announced_nodes + 4 or nodes >= int(float(maxi(1, last_announced_nodes)) * 1.5))
    var peak_money := money > best_window_money
    var peak_nodes := nodes > best_window_nodes
    if not dramatic_money and not dramatic_nodes and not peak_money and not peak_nodes:
        return false
    best_window_nodes = maxi(best_window_nodes, nodes)
    best_window_money = maxi(best_window_money, money)
    last_announced_money = maxi(last_announced_money, money)
    last_announced_nodes = maxi(last_announced_nodes, nodes)
    var speaker := _friend_id(rng.randi_range(0, FRIENDS.size() - 1))
    var templates := [
        "that pilot just [b]cut %d nodes[/b] and [b]dragged out %s[/b] before the smoke could settle. clinic lights stay on with numbers like that.",
        "watch the rig. [b]%d nodes went dark[/b] and [b]%s came loose[/b] like the shell forgot who owned it. that is public money again.",
        "operator moved ugly and fast there: [b]%d nodes split open[/b], [b]%s bled out[/b], nobody asked permission. archive drives get to live on this.",
        "room, look sharp. [b]%d nodes got carved loose[/b] and [b]%s hit the hold[/b] in one mean swing. that buys clean water and legal ghosts.",
    ]
    _queue_unique_variant_message(speaker, templates, [nodes, _format_money(money)], "summary_%d_%d" % [nodes, money], 0.0)
    if (nodes >= maxi(15, best_window_nodes + 1) or money >= maxi(2200, int(float(best_window_money) * 1.15))) and rng.randf() < 0.35:
        var praise_lines := [
            "that is chapel-bell pace. keep hurting them.",
            "corporate telemetry is going to wake up screaming, and the co-ops are going to eat well.",
            "room sees it. that was clean as broken glass. we are with you.",
            "even the suits heard that one hit home. push deeper.",
        ]
        _queue_unique_variant_message(_friend_id(rng.randi_range(0, FRIENDS.size() - 1)), praise_lines, [], "praise_%d_%d" % [nodes, money], 1.2)
    return true

func _advance_thread() -> bool:
    if active_thread_id == "" or bool(used_threads.get(active_thread_id, false)) and int(thread_progress.get(active_thread_id, 0)) <= 0:
        active_thread_id = _pick_thread_id()
        if active_thread_id == "":
            return false
    for thread in THREADS:
        if str(thread.get("id", "")) != active_thread_id:
            continue
        var progress: int = int(thread_progress.get(active_thread_id, 0))
        var lines: Array = thread.get("lines", [])
        if progress >= lines.size():
            used_threads[active_thread_id] = true
            active_thread_id = ""
            return false
        var entry: Dictionary = lines[progress]
        _queue_message(str(entry.get("speaker", "mothbit")), str(entry.get("text", "")), 0.0)
        thread_progress[active_thread_id] = progress + 1
        persistent_thread_counts[active_thread_id] = int(persistent_thread_counts.get(active_thread_id, 0)) + 1
        if progress + 1 >= lines.size():
            used_threads[active_thread_id] = true
            active_thread_id = ""
        return true
    return false

func _pick_thread_id() -> String:
    var available: Array[String] = []
    var best_count := 2147483647
    for thread in THREADS:
        var thread_id := str(thread.get("id", ""))
        if thread_id == "":
            continue
        if bool(used_threads.get(thread_id, false)):
            continue
        var use_count := int(persistent_thread_counts.get(thread_id, 0))
        if use_count < best_count:
            best_count = use_count
            available.clear()
        if use_count == best_count:
            available.append(thread_id)
    if available.is_empty():
        return ""
    return available[rng.randi_range(0, available.size() - 1)]

func _queue_ambient_line(snapshot: Dictionary) -> void:
    var layer_name := str(snapshot.get("layer_name", "Proxy Cache"))
    var pilot_lines := [
        {"speaker": "mothbit", "text": "pilot is ghosting through %s clean. keep them mean and invisible." % layer_name},
        {"speaker": "undertow", "text": "watch the pilot path. they are still cutting the right arteries."},
        {"speaker": "taxhound", "text": "pilot keeps skipping decoys. that is somebody breaching with receipts, not ego."},
        {"speaker": "saintzero", "text": "every calm second the pilot gets in %s is another private lock coming loose." % layer_name},
        {"speaker": "chapelNull", "text": "pilot still breathing, shell still opening. excellent arrangement."},
        {"speaker": "feralroot", "text": "if the pilot keeps this line, half the board wakes up unemployed by dawn."},
    ]
    var world_lines := [
        {"speaker": "undertow", "text": "Still rerouting pension drips out of Helix Meridian. Their board keeps labeling hunger as user churn."},
        {"speaker": "taxhound", "text": "If anybody sees the soup keys spreadsheet, do not open tab seven. It has opinions."},
        {"speaker": "feralroot", "text": "dead mall clocks are synced. when the room says noon, it means consequences."},
        {"speaker": "saintzero", "text": "library moon fund bought six more cold drives. history keeps trying to survive us."},
    ]
    var lines := pilot_lines if rng.randf() < 0.7 else world_lines
    var line: Dictionary = lines[rng.randi_range(0, lines.size() - 1)]
    _queue_message(str(line.get("speaker", "mothbit")), str(line.get("text", "")), 0.0)

func _queue_room_intro(depth_level: int) -> void:
    _queue_message("room", "SUMP-9 opened. Masks on. Quiet hands.", 0.0, "#7dd6ff")
    _queue_message("undertow", "New breach pilot on Breach Tier %d. Keep the room civil and the receipts uncivil." % depth_level, 1.0)
    _queue_message("mothbit", "civility expired three raids ago, but sure.", 2.1)
    _queue_enemy_line(1, "Unknown signal in the shell. Probably another scavenger.", 3.2, "enemy_intro_unknown")

func _queue_layer_intro(layer_depth: int, layer_name: String) -> void:
    if layer_depth <= 1:
        _queue_unique_event("layer_%d" % layer_depth, "GlassAudit", "[b]Surface shell breached.[/b] Logging intruder.", 0.0, "#ff7c7c")
        return
    _queue_unique_event("layer_%d" % layer_depth, "undertow", "%s breached. Deeper shell, meaner accounting." % layer_name, 0.0)
    _queue_unique_variant_message(_friend_id(rng.randi_range(0, FRIENDS.size() - 1)), [
        "good. you punched through.",
        "there it is. new shell open.",
        "keep the pressure on. they hate daylight in here.",
    ], [], "layer_cheer_%d" % layer_depth, 0.8)
    if layer_depth >= 4:
        _queue_unique_variant_message("saintzero", [
            "This is where the ration math starts to crack.",
            "The deeper shells hold the parts they never meant the public to see.",
            "You are close to the machinery that made whole neighborhoods disposable.",
        ], [], "layer_story_%d" % layer_depth, 0.8)
    var enemy_tier := mini(4, maxi(1, layer_depth))
    var enemy_lines := {
        2: "[b]Unauthorized penetration[/b] of %s logged. [b]Turn back[/b] and we will call this a rounding error.",
        3: "%s is [b]not public terrain[/b]. [b]Leave now[/b] before your little rig becomes a training memo.",
        4: "You kept going. Interesting. [b]Nobody reaches %s without being archived afterward.[/b]",
    }
    var enemy_text := str(enemy_lines.get(enemy_tier, "[b]New shell breach detected[/b] in %s. [b]Leave.[/b]")) % layer_name
    _queue_enemy_line(enemy_tier, enemy_text, 1.4, "layer_enemy_%d" % layer_depth)

func _queue_pressure_exchange(stage: int, tier: int, zone_name: String) -> void:
    var enemy_tier := mini(4, maxi(1, tier + stage - 1))
    var enemy_text := ""
    match stage:
        1:
            enemy_text = "Motion inside %s influence. [b]That is close enough.[/b] [b]Stop pretending you belong here.[/b]" % zone_name
        2:
            enemy_text = "You are inside counter-hack weather now. [b]Back out[/b] before the room forgets your name for you."
        3:
            enemy_text = "How are you this close to the core already? [b]Who taught that pilot to breathe underwater?[/b]"
        _:
            enemy_text = "No. Absolutely not. [b]Pull away from the center[/b] and accept being smaller than us."
    _queue_enemy_line(enemy_tier, enemy_text, 0.0, "pressure_%d_%d_%s" % [stage, tier, zone_name])
    var friendly_lines := [
        "hear that surprise. noted.",
        "the suits only sound human when scared.",
        "room note: panic in their voice registered clean.",
        "that voice was not built for fear.",
    ]
    _queue_unique_variant_message(_friend_id(rng.randi_range(0, FRIENDS.size() - 1)), friendly_lines, [], "pressure_reply_%d_%d_%s" % [stage, tier, zone_name], 1.1)

func _queue_enemy_line(enemy_tier: int, text: String, delay: float, event_key: String = "") -> void:
    var enemy: Dictionary = ENEMIES.get(enemy_tier, ENEMIES[1])
    var speaker := str(enemy.get("id", "GlassAudit"))
    if event_key == "":
        _queue_message(speaker, text, delay, str(enemy.get("color", "#ff7c7c")))
        return
    _queue_unique_event(event_key, speaker, text, delay, str(enemy.get("color", "#ff7c7c")))

func _queue_message(speaker: String, text: String, delay: float = 0.0, color_override: String = "") -> void:
    var line := _format_chat_line(speaker, text, color_override)
    if emitted_exact_lines.has(line):
        return
    emitted_exact_lines[line] = true
    persistent_line_counts[line] = int(persistent_line_counts.get(line, 0)) + 1
    queued_lines.append({
        "time": time_alive + delay,
        "line": line,
    })

func _queue_unique_event(event_key: String, speaker: String, text: String, delay: float = 0.0, color_override: String = "") -> void:
    if emitted_event_signatures.has(event_key):
        return
    emitted_event_signatures[event_key] = true
    _queue_message(speaker, text, delay, color_override)

func _queue_unique_variant_message(speaker: String, templates: Array, args: Array, event_key: String, delay: float = 0.0, color_override: String = "") -> void:
    if emitted_event_signatures.has(event_key):
        return
    var options: Array[String] = []
    var best_count := 2147483647
    for template_variant in templates:
        var template := str(template_variant)
        var text := template % args if not args.is_empty() else template
        var line := _format_chat_line(speaker, text, color_override)
        if not emitted_exact_lines.has(line):
            var use_count := int(persistent_line_counts.get(line, 0))
            if use_count < best_count:
                best_count = use_count
                options.clear()
            if use_count == best_count:
                options.append(text)
    if options.is_empty():
        return
    emitted_event_signatures[event_key] = true
    _queue_message(speaker, options[rng.randi_range(0, options.size() - 1)], delay, color_override)

func _format_chat_line(speaker: String, text: String, color_override: String = "") -> String:
    var color := color_override
    if color == "":
        color = _speaker_color(speaker)
    var body_text := _format_chat_body_text(speaker, text)
    return "[color=%s]%s[/color]  %s" % [color, _speaker_display_name(speaker), body_text]

func _should_emit_thread(snapshot: Dictionary) -> bool:
    if final_core_exposed or final_core_destroyed:
        return true
    if _recent_money_total() >= 900:
        return true
    if recent_attacks.size() >= 9:
        return true
    return int(snapshot.get("layer_depth", 1)) >= 3 and rng.randf() < 0.55

func _zone_enemy_tier(zone: int) -> int:
    match zone:
        0:
            return 1
        1:
            return 2
        2:
            return 3
        3:
            return 4
        _:
            return 4

func _format_summary_line(speaker: String, text: String) -> String:
    return "[color=%s]%s[/color]  %s" % [_speaker_color(speaker), _speaker_display_name(speaker), _format_chat_body_text(speaker, text)]

func _format_chat_body_text(speaker: String, text: String) -> String:
    if _is_enemy_speaker(speaker):
        return "[color=#ff6b6b]%s[/color]" % text
    return text

func _speaker_display_name(speaker: String) -> String:
    if speaker == "room":
        return "ROOM"
    for friend in FRIENDS:
        if str(friend.get("id", "")) == speaker:
            return str(friend.get("display", speaker))
    for enemy in ENEMIES.values():
        if str(enemy.get("id", "")) == speaker:
            return str(enemy.get("display", speaker))
    return speaker

func _is_enemy_speaker(speaker: String) -> bool:
    for enemy in ENEMIES.values():
        if str(enemy.get("id", "")) == speaker:
            return true
    return false

func _speaker_color(speaker: String) -> String:
    if speaker == "room":
        return "#7dd6ff"
    for friend in FRIENDS:
        if str(friend.get("id", "")) == speaker:
            return str(friend.get("color", "#86ffd1"))
    for enemy in ENEMIES.values():
        if str(enemy.get("id", "")) == speaker:
            return str(enemy.get("color", "#ff7c7c"))
    return "#f4f7d6"

func _friend_id(index: int) -> String:
    return str(FRIENDS[index].get("id", "mothbit"))

func _trim_windows() -> void:
    while not recent_attacks.is_empty() and time_alive - float(recent_attacks[0]) > WINDOW_SECONDS:
        recent_attacks.remove_at(0)
    while not recent_money.is_empty() and time_alive - float(recent_money[0].get("time", 0.0)) > WINDOW_SECONDS:
        recent_money.remove_at(0)

func _recent_money_total() -> int:
    var total := 0
    for entry in recent_money:
        total += int(entry.get("amount", 0))
    return total

func _format_money(amount: int) -> String:
    if amount < 1000:
        return "$%d" % amount
    if amount < 1000000:
        return "$%.1fk" % (float(amount) / 1000.0)
    return "$%.2fm" % (float(amount) / 1000000.0)

func _zone_name(zone: int) -> String:
    match zone:
        0:
            return "Proxy Cache"
        1:
            return "Cipher Depths"
        2:
            return "Ghost Sector"
        3:
            return "Root Well"
        _:
            return "Kernel Vault"
