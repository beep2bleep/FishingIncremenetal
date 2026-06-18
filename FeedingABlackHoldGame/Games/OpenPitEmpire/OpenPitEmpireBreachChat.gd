extends RefCounted
class_name OpenPitEmpireBreachChat

const CHAT_TITLE := "[color=#7dd6ff]BLACK CHANNEL // SUMP-9[/color]"
const WINDOW_SECONDS := 10.0

# Chat voice style notes:
# - proper: sentence-case starts and standalone I; used by Undertow, Taxhound, ROOM, and enemy channels.
# - mothbit / always_lower: everything stays casual lowercase, punctuation allowed.
# - saintzero / mixed_case: authored casing is preserved so they can drift between soft lowercase and focused proper lines.
# - feralroot / field_note: sentence-case starts and standalone I, but drops a trailing period like clipped ops notes.
# - chapelNull / lower_no_periods: lowercase, with periods converted out so the voice reads like sharp fragments.
const FRIENDS := [
    {"id": "mothbit", "display": "mothbit", "color": "#86ffd1", "text_case": "always_lower"},
    {"id": "undertow", "display": "Undertow", "color": "#7cc6ff", "text_case": "proper"},
    {"id": "saintzero", "display": "saintzero", "color": "#d8d38a", "text_case": "mixed_case"},
    {"id": "taxhound", "display": "Taxhound", "color": "#ff9d78", "text_case": "proper"},
    {"id": "feralroot", "display": "feralroot", "color": "#c89dff", "text_case": "field_note"},
    {"id": "chapelNull", "display": "chapelNull", "color": "#ff7ab6", "text_case": "lower_no_periods"},
]

const ENEMIES := {
    1: {"id": "GlassAudit", "display": "GlassAudit", "color": "#ff7c7c", "text_case": "proper"},
    2: {"id": "PatentSaint", "display": "PatentSaint", "color": "#ff9580", "text_case": "proper"},
    3: {"id": "NullMeridian", "display": "NullMeridian", "color": "#ff6f6f", "text_case": "proper"},
    4: {"id": "CrownLedger", "display": "CrownLedger", "color": "#ff5252", "text_case": "proper"},
}

const THREADS := [
    {
        "id": "clinic",
        "lines": [
            {"speaker": "saintzero", "text": "Floodplain clinic reports the dialysis filters arrived. Inventory clerk cried in the stairwell and then asked for a better manifest."},
            {"speaker": "taxhound", "text": "sending one. the supplier tried to bill them for emergency weather access. I converted the invoice into evidence."},
            {"speaker": "undertow", "text": "keep the clinic channel boring. boring means nobody is bleeding in a lobby."},
            {"speaker": "mothbit", "text": "clinic router is still on a windowsill behind a plant. i respect the plant. i do not respect the router."},
            {"speaker": "chapelNull", "text": "plant has uptime; router has vibes; this is how public health infrastructure happens now"},
            {"speaker": "feralroot", "text": "Backup uplink is taped under reception. Marked it as a copier lease so procurement ignores it"},
            {"speaker": "saintzero", "text": "doctor Vale says two patients got appointments moved up. small victory, big lungs."},
            {"speaker": "taxhound", "text": "OmniLedger legal just asked why their rain surcharge appears in six mutual-aid exhibits."},
            {"speaker": "undertow", "text": "answer: because it rained on everyone and they tried to own the sky."},
            {"speaker": "mothbit", "text": "clinic clerk wants to name the new server mercy. tasteful. ominous. approved."},
            {"speaker": "chapelNull", "text": "mercy is live; mercy has two-factor; mercy hates private equity"},
            {"speaker": "saintzero", "text": "the clinic is stable for tonight. tomorrow they need oxygen valves, not applause."},
            {"speaker": "feralroot", "text": "Oxygen vendor has a dead drop at shift change. I can make that look like ordinary shipping incompetence"},
            {"speaker": "taxhound", "text": "ordinary shipping incompetence is my second-best legal doctrine."},
            {"speaker": "undertow", "text": "clinic thread stays open. if the board cuts another line, we cut a deeper one."},
        ],
    },
    {
        "id": "library",
        "lines": [
            {"speaker": "saintzero", "text": "library moon fund is short three servers and one exhausted lawyer."},
            {"speaker": "feralroot", "text": "Lawyer found. Servers pending. Nobody let mothbit buy another dead mall clock with archive money"},
            {"speaker": "mothbit", "text": "the clock was for morale and chronological integrity."},
            {"speaker": "undertow", "text": "chronological integrity is not a budget line."},
            {"speaker": "taxhound", "text": "it is if you spell it as evidence preservation."},
            {"speaker": "chapelNull", "text": "archive intake says the deleted water hearings are readable again; ugly, but readable"},
            {"speaker": "saintzero", "text": "Mirror them twice. One polite copy for courts, one impolite copy for when courts remember who funds the carpet."},
            {"speaker": "feralroot", "text": "Cold drive one mounted. Cold drive two making a clicking sound I would call emotionally complex"},
            {"speaker": "mothbit", "text": "do not anthropomorphize storage. it gets brave and expensive."},
            {"speaker": "taxhound", "text": "the tired lawyer has become a furious lawyer. major upgrade."},
            {"speaker": "undertow", "text": "furious is good. furious reads footnotes."},
            {"speaker": "chapelNull", "text": "archive volunteers are naming folders after bus routes; extremely municipal; deeply threatening"},
            {"speaker": "saintzero", "text": "First batch is out to reporters. No hero language, just dates, signatures, and the shape of harm."},
            {"speaker": "feralroot", "text": "Server three is alive. Clock remains unauthorized but weirdly useful"},
            {"speaker": "mothbit", "text": "chronological integrity wins again."},
        ],
    },
    {
        "id": "payroll",
        "lines": [
            {"speaker": "taxhound", "text": "municipal payroll lock is still eating overtime. sanitation crew got paid in pending status again."},
            {"speaker": "chapelNull", "text": "pending status is wage theft wearing a necktie"},
            {"speaker": "feralroot", "text": "I have the contractor portal. Password policy appears to be resentment plus one digit"},
            {"speaker": "mothbit", "text": "found the escrow teeth. they call missed pay a liquidity patience event."},
            {"speaker": "undertow", "text": "beautiful phrase. put it in the complaint and then set it on fire."},
            {"speaker": "taxhound", "text": "not fire. exhibit B. exhibit B hurts longer."},
            {"speaker": "saintzero", "text": "crew lead says the worst part is apologizing to kids for a calendar they did not break."},
            {"speaker": "feralroot", "text": "Routing payroll through the emergency vendor path. It thinks this is a snowstorm"},
            {"speaker": "chapelNull", "text": "every broken system has one door labeled weather; spiritually lazy design"},
            {"speaker": "mothbit", "text": "first batch cleared. sixteen checks. nobody celebrate until rent clears."},
            {"speaker": "taxhound", "text": "rent cleared for twelve. four need manual release. I am becoming manual."},
            {"speaker": "undertow", "text": "stay on it. this is the quiet work that keeps people from disappearing."},
            {"speaker": "feralroot", "text": "Manual release complete. Contractor audit bot is politely confused"},
            {"speaker": "saintzero", "text": "Crew lead sent thank-you notes and a list of everyone still missing hazard pay."},
            {"speaker": "taxhound", "text": "excellent. gratitude with attachments."},
        ],
    },
    {
        "id": "causeway",
        "lines": [
            {"speaker": "undertow", "text": "Salt caucus blocked the toll cameras for two hours. The trucks got through clean."},
            {"speaker": "feralroot", "text": "Meanwhile the corporation wrote a statement about community inconvenience. Real tragedy for their cameras"},
            {"speaker": "taxhound", "text": "I billed them for grief counseling and route confusion."},
            {"speaker": "chapelNull", "text": "invoice the concept of ownership next; see if it blinks"},
            {"speaker": "mothbit", "text": "camera four is showing a loop of ordinary fog. camera five is offended by fog as a legal category."},
            {"speaker": "saintzero", "text": "drivers report the checkpoint stayed quiet. medicine crates made it across."},
            {"speaker": "undertow", "text": "good. the public route stays public one more night."},
            {"speaker": "feralroot", "text": "Their dispatcher is asking why every lane sensor says maintenance"},
            {"speaker": "chapelNull", "text": "because every lane sensor needs maintenance; morally, at least"},
            {"speaker": "taxhound", "text": "toll authority just filed a delay notice against itself. I want that framed."},
            {"speaker": "mothbit", "text": "fog loop retired. replacing with a city bus doing absolutely nothing suspicious."},
            {"speaker": "saintzero", "text": "last truck crossed. insulin stayed cold. driver says the bridge felt normal for once."},
            {"speaker": "undertow", "text": "normal is the most radical thing in the room some nights."},
            {"speaker": "feralroot", "text": "Cleanup complete. Left them a maintenance ticket about predatory infrastructure"},
            {"speaker": "taxhound", "text": "that is what this breach is for. toll teeth, debt teeth, ration teeth. one invoice at a time."},
        ],
    },
    {
        "id": "water",
        "lines": [
            {"speaker": "saintzero", "text": "Remember the desal cooperatives. Helix Meridian throttled them for quarterly optics."},
            {"speaker": "taxhound", "text": "Their water futures desk called thirst a market signal. I kept the memo."},
            {"speaker": "undertow", "text": "the same ledger stack priced whole districts out of clean taps."},
            {"speaker": "mothbit", "text": "found the pressure table. it reads like a ransom note with decimals."},
            {"speaker": "feralroot", "text": "Co-op valve two is manually overridden. Valve three needs someone with boots and patience"},
            {"speaker": "chapelNull", "text": "boots confirmed; patience in beta"},
            {"speaker": "saintzero", "text": "north plant reports flow for the first time in six days."},
            {"speaker": "taxhound", "text": "their futures desk is hedging against accountability. cute. late."},
            {"speaker": "undertow", "text": "keep timestamps. clean water should not need an alibi, but here we are."},
            {"speaker": "mothbit", "text": "valve three moved. sound described as expensive sadness."},
            {"speaker": "feralroot", "text": "Boot team is clear. Nobody followed them. One person did ask why a valve had a subscription plan"},
            {"speaker": "chapelNull", "text": "because civilization lost a bet"},
            {"speaker": "saintzero", "text": "Co-op says pressure is uneven but usable. Usable is a holy word when the taps have been bargaining chips."},
            {"speaker": "taxhound", "text": "memo packet sent to counsel, press, and one city auditor who still answers at midnight."},
            {"speaker": "undertow", "text": "water thread stays warm. the next lock will be hidden in maintenance language."},
        ],
    },
    {
        "id": "station",
        "lines": [
            {"speaker": "feralroot", "text": "Station team has eyes on the old transit hub. Ad boards are still serving debt relief scams to commuters"},
            {"speaker": "mothbit", "text": "ad board one now says lost card? ask a human. feels illegal. feels nice."},
            {"speaker": "chapelNull", "text": "radical transit demand: benches without facial analytics"},
            {"speaker": "taxhound", "text": "the analytics vendor calls sitting a dwell monetization event. I need five minutes alone with their glossary."},
            {"speaker": "undertow", "text": "station cameras feed into the same enforcement pool as the ration kiosks. cut the quiet links first."},
            {"speaker": "saintzero", "text": "community desk is setting up by the west stairs. people need forms, rides, and fewer screens calling them delinquent."},
            {"speaker": "feralroot", "text": "Kiosk firmware accepts municipal holiday mode. Every day is now a municipal holiday for debt collection"},
            {"speaker": "mothbit", "text": "beautiful civic calendar. no notes."},
            {"speaker": "taxhound", "text": "vendor noticed. vendor blamed procurement. procurement blamed weather. weather remains innocent."},
            {"speaker": "chapelNull", "text": "west stairs desk just fixed seven benefit renewals with a printer older than some board members"},
            {"speaker": "undertow", "text": "that is infrastructure too. not glamorous, not optional."},
            {"speaker": "saintzero", "text": "Transit hub is calmer. Fewer warnings, more people asking each other where to go."},
            {"speaker": "feralroot", "text": "Closing the station loop. Left the kiosks with a maintenance banner and a conscience they cannot parse"},
        ],
    },
    {
        "id": "safehouse",
        "lines": [
            {"speaker": "undertow", "text": "safehouse check. east room has power. south room has blankets. kitchen has an argument about labels."},
            {"speaker": "chapelNull", "text": "labels matter; powdered coffee and soup mix should not share a handwriting style"},
            {"speaker": "mothbit", "text": "inventory tablet is syncing over a hotspot named definitely not a safehouse."},
            {"speaker": "feralroot", "text": "Renamed it to Printer Setup 2. No one fears printers enough"},
            {"speaker": "saintzero", "text": "two families arriving in twenty. keep the channel practical."},
            {"speaker": "taxhound", "text": "landlord shell company owns the block and three judges' vacation photos. collecting carefully."},
            {"speaker": "undertow", "text": "collecting carefully is the whole job. nobody gets clever around sleeping people."},
            {"speaker": "chapelNull", "text": "kitchen labels fixed; morale increased by twelve percent and one quiet nod"},
            {"speaker": "mothbit", "text": "generator hiccuped. i said encouraging things to it and one threat."},
            {"speaker": "feralroot", "text": "Power stable. Hotspot boring. Printer still spiritually hostile"},
            {"speaker": "saintzero", "text": "Families are inside. Nobody on street watch saw a tail."},
            {"speaker": "taxhound", "text": "shell company packet is ready when they try eviction theater."},
            {"speaker": "undertow", "text": "safehouse quiet. that is the report we want."},
        ],
    },
    {
        "id": "student_debt",
        "lines": [
            {"speaker": "taxhound", "text": "student debt mirror is live. their forgiveness portal denied applicants for using commas in addresses."},
            {"speaker": "mothbit", "text": "commas: famously suspicious punctuation."},
            {"speaker": "chapelNull", "text": "semicolon users go straight to collections"},
            {"speaker": "saintzero", "text": "focus. public college nurses are getting dragged for loans that were supposed to vanish three years ago."},
            {"speaker": "feralroot", "text": "I found the denial rules. One branch rejects applications if the employer name is too similar to the employer registry"},
            {"speaker": "undertow", "text": "too similar means exact match, I assume."},
            {"speaker": "feralroot", "text": "Exact match, yes. The machine is afraid of accuracy"},
            {"speaker": "taxhound", "text": "exporting denial reasons. bland cruelty is still cruelty, just easier to subpoena."},
            {"speaker": "mothbit", "text": "mirror has first batch. people can see what rule broke them."},
            {"speaker": "saintzero", "text": "Nurses' union is already calling members. Keep the mirror stable and boring."},
            {"speaker": "chapelNull", "text": "boring mirror, angry people, clean spreadsheet; classic room recipe"},
            {"speaker": "undertow", "text": "debt office just switched the portal to maintenance. too late. copies are walking."},
            {"speaker": "taxhound", "text": "copies are walking to counsel, press, and one agency inbox that hates surprises."},
        ],
    },
    {
        "id": "food_kiosks",
        "lines": [
            {"speaker": "saintzero", "text": "ration kiosk complaints doubled near the south blocks. cards work at checkout, fail at staples."},
            {"speaker": "mothbit", "text": "staples classifier thinks rice is luxury if the bag has a handle."},
            {"speaker": "chapelNull", "text": "handles: gateway to decadence"},
            {"speaker": "feralroot", "text": "Kiosk vendor pushed a nutrition compliance patch. It mostly complies with shareholder anxiety"},
            {"speaker": "taxhound", "text": "found the clause. staple denial saves are booked as leakage prevention."},
            {"speaker": "undertow", "text": "leakage is people eating. write that down exactly."},
            {"speaker": "saintzero", "text": "Store volunteers are running manual overrides. Line is long but moving."},
            {"speaker": "mothbit", "text": "classifier now thinks every rice handle is a label artifact. i love education."},
            {"speaker": "feralroot", "text": "Vendor dashboard shows anomalous compassion"},
            {"speaker": "chapelNull", "text": "patch note: fixed bug where hunger persisted"},
            {"speaker": "taxhound", "text": "kiosk logs exported. this one is ugly enough for daylight."},
            {"speaker": "undertow", "text": "food thread can cool down. keep manual override notes; they will lie about intent."},
        ],
    },
]

var rng := RandomNumberGenerator.new()
var queued_lines: Array[Dictionary] = []
var recent_attacks: Array[float] = []
var recent_money: Array[Dictionary] = []
var time_alive := 0.0
var next_generation_time := 0.0
var next_summary_time := 150.0
var next_thread_time := 24.0
var best_window_money := 0
var best_window_nodes := 0
var last_announced_money := 0
var last_announced_nodes := 0
var last_layer_depth := -1
var seen_layers: Dictionary = {}
var active_thread_id := ""
var active_thread_ids: Array[String] = []
var active_thread_target_count := 2
var last_emitted_thread_id := ""
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
var early_run_tutorial_mode := false
var editor_assists_enabled := false
var persistent_line_counts: Dictionary = {}
var persistent_thread_counts: Dictionary = {}

func reset_for_run(depth_level: int, source_rng: RandomNumberGenerator = null, line_counts: Dictionary = {}, thread_counts: Dictionary = {}, event_signatures: Dictionary = {}, saved_active_thread_id: String = "", saved_active_thread_ids: Array = [], saved_active_thread_target_count: int = 2, flight_number: int = 999, assists_enabled: bool = false) -> void:
    rng = RandomNumberGenerator.new()
    rng.seed = source_rng.randi() if source_rng != null else Time.get_unix_time_from_system()
    queued_lines.clear()
    recent_attacks.clear()
    recent_money.clear()
    time_alive = 0.0
    next_generation_time = 8.0
    next_summary_time = 150.0
    next_thread_time = 36.0
    best_window_money = 0
    best_window_nodes = 0
    last_announced_money = 0
    last_announced_nodes = 0
    last_layer_depth = -1
    seen_layers.clear()
    active_thread_id = ""
    active_thread_ids.clear()
    active_thread_target_count = clampi(saved_active_thread_target_count, 2, 3)
    last_emitted_thread_id = ""
    thread_progress.clear()
    used_threads.clear()
    pressure_signature = ""
    final_core_exposed = false
    final_core_destroyed = false
    final_epilogue_lines.clear()
    emitted_exact_lines.clear()
    emitted_event_signatures = event_signatures.duplicate(true)
    ambient_cooldown_until = 0.0
    node_hit_counts.clear()
    suspicion_level = 0
    hint_stage = 0
    early_run_tutorial_mode = flight_number <= 2
    editor_assists_enabled = assists_enabled
    persistent_line_counts = line_counts.duplicate(true)
    persistent_thread_counts = thread_counts.duplicate(true)
    for line_variant in persistent_line_counts.keys():
        if int(persistent_line_counts.get(line_variant, 0)) > 0:
            emitted_exact_lines[str(line_variant)] = true
    _seed_thread_progress_from_persistent_counts()
    active_thread_ids = _validated_active_thread_ids(saved_active_thread_ids, saved_active_thread_id)
    if active_thread_ids.is_empty():
        _fill_active_threads(false)
    else:
        _fill_active_threads(false)
    active_thread_id = active_thread_ids[0] if not active_thread_ids.is_empty() else ""
    if early_run_tutorial_mode:
        _queue_tutorial_intro()
    else:
        _queue_room_intro(depth_level)

func set_editor_assists_enabled(enabled: bool) -> void:
    editor_assists_enabled = enabled

func get_persistent_line_counts() -> Dictionary:
    return persistent_line_counts.duplicate(true)

func get_persistent_thread_counts() -> Dictionary:
    return persistent_thread_counts.duplicate(true)

func get_persistent_active_thread_id() -> String:
    return active_thread_id

func get_persistent_active_thread_ids() -> Array[String]:
    return active_thread_ids.duplicate()

func get_persistent_active_thread_target_count() -> int:
    return active_thread_target_count

func get_persistent_event_signatures() -> Dictionary:
    return emitted_event_signatures.duplicate(true)

func get_title() -> String:
    return _translate(CHAT_TITLE)

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
    if early_run_tutorial_mode:
        return
    if time_alive < next_generation_time:
        return
    if time_alive >= next_thread_time and _should_emit_thread(snapshot) and _advance_thread():
        next_generation_time = time_alive + rng.randf_range(8.0, 16.0)
        next_thread_time = time_alive + rng.randf_range(52.0, 84.0)
        return
    if _try_generate_summary(snapshot):
        next_generation_time = time_alive + rng.randf_range(38.0, 62.0)
        return
    if time_alive >= ambient_cooldown_until and rng.randf() < 0.1:
        _queue_ambient_line(snapshot)
        ambient_cooldown_until = time_alive + rng.randf_range(90.0, 150.0)
        next_generation_time = time_alive + rng.randf_range(30.0, 50.0)
        return
    next_generation_time = time_alive + rng.randf_range(12.0, 24.0)

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
    if early_run_tutorial_mode and not editor_assists_enabled:
        return
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
    if early_run_tutorial_mode and not editor_assists_enabled:
        return
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
    _queue_unique_event("core_%d" % core_id, speaker, _format_translated("node %d just folded in %s. somebody put that shard where the suits cannot pray over it.", [core_id, zone_name]), 0.0)
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
        _queue_unique_event("boss_%d" % core_id, "undertow", _format_translated("%s oversight just lost a throat. Keep the rig moving before they remember panic procedures.", [zone_name]), 1.4)
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
        _format_translated("[b]Command node %d is pushing back.[/b] %s protocols are live.", [core_id, defense_name]),
        0.0,
        "defense_start_%d" % core_id
    )
    _queue_unique_variant_message("undertow", [
        "%s command node hit zero and threw a defense screen. clear it and the node dies for real.",
        "that node is refusing death with a %s defense. rude, expensive, and beatable.",
        "%s defense just lit up. take the side fight; we will hold the breach open."
    ], [defense_name], "defense_reply_%d" % core_id, 0.9)
    _queue_unique_event("defense_zone_%d" % core_id, "taxhound", _format_translated("%s oversight bought a panic room. let's repossess it.", [zone_name]), 1.7)

func notify_defense_challenge_failed(core_id: int, defense_name: String) -> void:
    _queue_enemy_line(
        mini(4, maxi(2, _zone_enemy_tier(OpenPitEmpirePlanetData.get_core_zone(core_id)) + 1)),
        _format_translated("[b]%s held.[/b] The node has restored itself to emergency health. Try not to make this inspirational.", [defense_name]),
        0.0,
        "defense_fail_%d" % core_id
    )
    _queue_unique_variant_message("chapelNull", [
        "bad news: the node got half its spine back; good news: it only gets that trick once",
        "they spent a whole countermeasure just to go back to fifty percent; deeply embarrassing budget behavior",
        "reset to half health; fine; hit it again and make the accounting louder"
    ], [], "defense_fail_reply_%d" % core_id, 1.0)

func notify_defense_challenge_succeeded(core_id: int, defense_name: String) -> void:
    _queue_unique_event("defense_success_%d" % core_id, "mothbit", _format_translated("%s cracked. command node has no second argument with physics.", [defense_name]), 0.0)
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
    _queue_message("chapelNull", "center shell is open; everybody breathe once and get mean", 1.3)
    _queue_message("saintzero", "For the clinic, the moon archive, the ferrets, all of it. Finish the work.", 2.4)
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
        _format_summary_line("mothbit", "the room called the breach clean. debt engines opened and their receipts started to fall."),
        _format_summary_line("CrownLedger", "Corporate channel collapse confirmed. Containment failed at the heart."),
        _format_summary_line("undertow", "Funds are moving to the floodplain clinic, the library moon fund, the desal cooperatives, and every other impossible little cause they mocked."),
    ]

func build_summary_epilogue() -> String:
    if final_epilogue_lines.is_empty():
        return ""
    return "\n\n" + _translate("[color=#7dd6ff]Room Aftermath[/color]") + "\n" + "\n".join(final_epilogue_lines)

func _react_to_snapshot(snapshot: Dictionary) -> void:
    if early_run_tutorial_mode:
        if bool(snapshot.get("final_core_exposed", false)):
            notify_final_core_exposed()
        return
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
    if early_run_tutorial_mode:
        return
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
        _queue_message("chapelNull", "congrats on being doxxed by panicked aristocrats; finish the breach anyway", 0.9)

func _try_generate_summary(snapshot: Dictionary) -> bool:
    if time_alive < next_summary_time:
        return false
    var nodes: int = recent_attacks.size()
    var money := _recent_money_total()
    next_summary_time = time_alive + rng.randf_range(150.0, 240.0)
    if nodes <= 0 and money <= 0:
        return false
    var dramatic_money := money >= 2200 and (money >= last_announced_money + 1800 or money >= int(float(maxi(1, last_announced_money)) * 2.2))
    var dramatic_nodes := nodes >= 18 and (nodes >= last_announced_nodes + 10 or nodes >= int(float(maxi(1, last_announced_nodes)) * 2.1))
    if not dramatic_money and not dramatic_nodes:
        return false
    best_window_nodes = maxi(best_window_nodes, nodes)
    best_window_money = maxi(best_window_money, money)
    last_announced_money = maxi(last_announced_money, money)
    last_announced_nodes = maxi(last_announced_nodes, nodes)
    var speaker := _friend_id(rng.randi_range(0, FRIENDS.size() - 1))
    var templates := [
        "quick accounting note: [b]%d nodes[/b], [b]%s[/b] recovered. routing shares to clinic, water, archive, payroll.",
        "ops ledger updated: [b]%d nodes[/b] cleared and [b]%s[/b] moved. keep side channels steady.",
        "resource desk confirms [b]%d nodes[/b] down and [b]%s[/b] loose. no speech, just routing.",
        "room bookkeeping: [b]%d nodes[/b], [b]%s[/b]. practical miracles require practical math.",
    ]
    _queue_unique_variant_message(speaker, templates, [nodes, _format_money(money)], "summary_%d_%d" % [nodes, money], 0.0)
    return true

func _advance_thread() -> bool:
    _prune_active_threads()
    _fill_active_threads(false)
    var candidates := _get_active_threads_with_lines()
    if candidates.is_empty():
        active_thread_id = ""
        return false
    var pick_candidates := candidates.duplicate()
    if pick_candidates.size() > 1 and last_emitted_thread_id in pick_candidates:
        pick_candidates.erase(last_emitted_thread_id)
    active_thread_id = pick_candidates[rng.randi_range(0, pick_candidates.size() - 1)]
    for thread in THREADS:
        if str(thread.get("id", "")) != active_thread_id:
            continue
        var progress: int = int(thread_progress.get(active_thread_id, 0))
        var lines: Array = thread.get("lines", [])
        if progress >= lines.size():
            used_threads[active_thread_id] = true
            _remove_active_thread(active_thread_id)
            _fill_active_threads(false)
            active_thread_id = active_thread_ids[0] if not active_thread_ids.is_empty() else ""
            return false
        var entry: Dictionary = lines[progress]
        _queue_message(str(entry.get("speaker", "mothbit")), str(entry.get("text", "")), 0.0)
        last_emitted_thread_id = active_thread_id
        thread_progress[active_thread_id] = progress + 1
        persistent_thread_counts[active_thread_id] = int(persistent_thread_counts.get(active_thread_id, 0)) + 1
        if progress + 1 >= lines.size():
            used_threads[active_thread_id] = true
            _remove_active_thread(active_thread_id)
            if active_thread_target_count < 3:
                active_thread_target_count = 3
            _fill_active_threads(false)
            active_thread_id = active_thread_ids[0] if not active_thread_ids.is_empty() else ""
        return true
    return false

func _seed_thread_progress_from_persistent_counts() -> void:
    for thread in THREADS:
        var thread_id := str(thread.get("id", ""))
        if thread_id == "":
            continue
        var lines: Array = thread.get("lines", [])
        var progress := clampi(int(persistent_thread_counts.get(thread_id, 0)), 0, lines.size())
        thread_progress[thread_id] = progress
        if progress >= lines.size():
            used_threads[thread_id] = true

func _validated_active_thread_ids(saved_ids: Array, fallback_thread_id: String = "") -> Array[String]:
    var validated: Array[String] = []
    for id_variant in saved_ids:
        var candidate := str(id_variant).strip_edges()
        if candidate == "" or candidate in validated:
            continue
        if _thread_has_available_line(candidate):
            validated.append(candidate)
    var fallback := fallback_thread_id.strip_edges()
    if fallback != "" and fallback not in validated and _thread_has_available_line(fallback):
        validated.append(fallback)
    while validated.size() > active_thread_target_count:
        validated.remove_at(validated.size() - 1)
    return validated

func _thread_has_available_line(thread_id: String) -> bool:
    for thread in THREADS:
        if str(thread.get("id", "")) != thread_id:
            continue
        var lines: Array = thread.get("lines", [])
        if int(thread_progress.get(thread_id, int(persistent_thread_counts.get(thread_id, 0)))) < lines.size():
            return true
        used_threads[thread_id] = true
        return false
    return false

func _fill_active_threads(_use_priority: bool) -> void:
    _prune_active_threads()
    while active_thread_ids.size() < active_thread_target_count:
        var thread_id := _pick_random_thread_id()
        if thread_id == "":
            return
        active_thread_ids.append(thread_id)
    active_thread_id = active_thread_ids[0] if not active_thread_ids.is_empty() else ""

func _pick_random_thread_id() -> String:
    var available: Array[String] = []
    for thread in THREADS:
        var thread_id := str(thread.get("id", ""))
        if thread_id == "":
            continue
        if thread_id in active_thread_ids or bool(used_threads.get(thread_id, false)):
            continue
        if _thread_has_available_line(thread_id):
            available.append(thread_id)
    if available.is_empty():
        return ""
    return available[rng.randi_range(0, available.size() - 1)]

func _get_active_threads_with_lines() -> Array[String]:
    var available: Array[String] = []
    for thread_id in active_thread_ids:
        if _thread_has_available_line(thread_id):
            available.append(thread_id)
    return available

func _prune_active_threads() -> void:
    for idx in range(active_thread_ids.size() - 1, -1, -1):
        if not _thread_has_available_line(active_thread_ids[idx]):
            active_thread_ids.remove_at(idx)

func _remove_active_thread(thread_id: String) -> void:
    while thread_id in active_thread_ids:
        active_thread_ids.erase(thread_id)

func _queue_ambient_line(snapshot: Dictionary) -> void:
    var world_lines := [
        {"speaker": "undertow", "text": "side channel check: archive stable, clinic stable, payroll watching for clawbacks."},
        {"speaker": "taxhound", "text": "If anybody sees the soup keys spreadsheet, do not open tab seven. It has opinions."},
        {"speaker": "feralroot", "text": "Dead mall clocks are synced. When the room says noon, it means consequences"},
        {"speaker": "saintzero", "text": "library fund bought six more cold drives. history keeps trying to survive us."},
        {"speaker": "chapelNull", "text": "someone labeled the safehouse extension cords by emotional risk; correct and useful"},
        {"speaker": "mothbit", "text": "ops note: do not trust a vendor portal that says delightful onboarding."},
        {"speaker": "feralroot", "text": "Transit desk needs toner, forms, and one person who can smile at angry software without becoming it"},
        {"speaker": "taxhound", "text": "midnight auditor replied with just the word interesting. legally, that is thunder."},
    ]
    var line: Dictionary = world_lines[rng.randi_range(0, world_lines.size() - 1)]
    _queue_message(str(line.get("speaker", "mothbit")), str(line.get("text", "")), 0.0)

func _queue_room_intro(depth_level: int) -> void:
    _queue_message("room", "SUMP-9 opened. Masks on. Quiet hands.", 0.0, "#7dd6ff")
    _queue_message("undertow", _format_translated("Breach Tier %d is live. Keep side operations moving and logs clean.", [depth_level]), 1.0)
    _queue_message("mothbit", "side board is up: clinic, payroll, water, archive, station. very relaxing crime calendar.", 2.1)
    _queue_enemy_line(1, "Unknown signal in the shell. Probably another scavenger.", 3.2, "enemy_intro_unknown")

func _queue_tutorial_intro() -> void:
    _queue_system_message("OPEN_PIT_CHAT_TUTORIAL_MOVE_ATTACK", 0.0)
    _queue_system_message("OPEN_PIT_CHAT_TUTORIAL_COLLECT_PAYLOAD", 1.4)
    _queue_system_message("OPEN_PIT_CHAT_TUTORIAL_RETURN_HOME", 2.8)

func _queue_layer_intro(layer_depth: int, layer_name: String) -> void:
    if layer_depth <= 1:
        _queue_unique_event("layer_%d" % layer_depth, "GlassAudit", "[b]Surface shell breached.[/b] Logging intruder.", 0.0, "#ff7c7c")
        return
    _queue_unique_event("layer_%d" % layer_depth, "undertow", _format_translated("%s breached. Deeper shell, meaner accounting.", [layer_name]), 0.0)
    _queue_unique_variant_message(_friend_id(rng.randi_range(0, FRIENDS.size() - 1)), [
        "routing table changed. watch the side jobs for retaliation.",
        "new shell means new vendor lies. log everything.",
        "deeper access is open. expect quieter alarms before the loud ones.",
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
    var enemy_text := _format_translated(str(enemy_lines.get(enemy_tier, "[b]New shell breach detected[/b] in %s. [b]Leave.[/b]")), [layer_name])
    _queue_enemy_line(enemy_tier, enemy_text, 1.4, "layer_enemy_%d" % layer_depth)

func _queue_pressure_exchange(stage: int, tier: int, zone_name: String) -> void:
    var enemy_tier := mini(4, maxi(1, tier + stage - 1))
    var enemy_text := ""
    match stage:
        1:
            enemy_text = _format_translated("Motion inside %s influence. [b]That is close enough.[/b] [b]Stop pretending you belong here.[/b]", [zone_name])
        2:
            enemy_text = _format_translated("You are inside counter-hack weather now. [b]Back out[/b] before the room forgets your name for you.", [])
        3:
            enemy_text = _format_translated("How are you this close to the core already? [b]Who taught that pilot to breathe underwater?[/b]", [])
        _:
            enemy_text = _format_translated("No. Absolutely not. [b]Pull away from the center[/b] and accept being smaller than us.", [])
    _queue_enemy_line(enemy_tier, enemy_text, 0.0, "pressure_%d_%d_%s" % [stage, tier, zone_name])
    var friendly_lines := [
        "hear that surprise. noted.",
        "the suits only sound human when scared.",
        "room note: panic in their voice registered clean.",
        "that voice was not built for fear.",
    ]
    _queue_unique_variant_message(_friend_id(rng.randi_range(0, FRIENDS.size() - 1)), friendly_lines, [], "pressure_reply_%d_%d_%s" % [stage, tier, zone_name], 1.1)

func _queue_enemy_line(enemy_tier: int, text: String, delay: float, event_key: String = "") -> void:
    if early_run_tutorial_mode and not editor_assists_enabled:
        return
    var enemy: Dictionary = ENEMIES.get(enemy_tier, ENEMIES[1])
    var speaker := str(enemy.get("id", "GlassAudit"))
    if event_key == "":
        _queue_message(speaker, text, delay, str(enemy.get("color", "#ff7c7c")))
        return
    _queue_unique_event(event_key, speaker, text, delay, str(enemy.get("color", "#ff7c7c")))

func _queue_message(speaker: String, text: String, delay: float = 0.0, color_override: String = "") -> void:
    var line := _format_chat_line(speaker, _translate(text), color_override)
    if emitted_exact_lines.has(line):
        return
    emitted_exact_lines[line] = true
    persistent_line_counts[line] = int(persistent_line_counts.get(line, 0)) + 1
    queued_lines.append({
        "time": time_alive + delay,
        "line": line,
    })

func _queue_system_message(key: String, delay: float = 0.0) -> void:
    queued_lines.append({
        "time": time_alive + delay,
        "line": _format_chat_line("system", _translate(key), "#ffd66b"),
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
        template = _translate(template)
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
    if not active_thread_ids.is_empty():
        return true
    if _has_available_thread_lines():
        return true
    if _recent_money_total() >= 900:
        return true
    if recent_attacks.size() >= 9:
        return true
    return int(snapshot.get("layer_depth", 1)) >= 3 and rng.randf() < 0.55

func _has_available_thread_lines() -> bool:
    for thread in THREADS:
        var thread_id := str(thread.get("id", ""))
        if thread_id == "":
            continue
        var lines: Array = thread.get("lines", [])
        if int(thread_progress.get(thread_id, int(persistent_thread_counts.get(thread_id, 0)))) < lines.size():
            return true
    return false

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
    return "[color=%s]%s[/color]  %s" % [_speaker_color(speaker), _speaker_display_name(speaker), _format_chat_body_text(speaker, _translate(text))]

func _format_chat_body_text(speaker: String, text: String) -> String:
    text = _apply_chat_text_style(_speaker_text_case(speaker), text)
    if _is_enemy_speaker(speaker):
        return "[color=#ff6b6b]%s[/color]" % text
    return text

func _apply_chat_text_style(text_case: String, text: String) -> String:
    match text_case:
        "proper":
            return _sentence_case_chat_text(text)
        "always_lower":
            return text.to_lower()
        "field_note":
            return _strip_final_chat_period(_sentence_case_chat_text(text))
        "lower_no_periods":
            return _remove_chat_periods(text.to_lower())
        "mixed_case":
            return text
        _:
            return text

func _strip_final_chat_period(text: String) -> String:
    var trailing_spaces := ""
    while text.ends_with(" "):
        trailing_spaces += " "
        text = text.substr(0, text.length() - 1)
    if text.ends_with("."):
        text = text.substr(0, text.length() - 1)
    return text + trailing_spaces

func _remove_chat_periods(text: String) -> String:
    var output := ""
    var in_tag := false
    var i := 0
    while i < text.length():
        var character := text.substr(i, 1)
        if character == "[":
            in_tag = true
        elif character == "]":
            in_tag = false
        if character == "." and not in_tag:
            if i < text.length() - 1 and text.substr(i + 1, 1) == " ":
                output += ";"
            i += 1
            continue
        output += character
        i += 1
    return output

func _sentence_case_chat_text(text: String) -> String:
    var output := ""
    var capitalize_next := true
    var in_tag := false
    var word_start := true
    var i := 0
    while i < text.length():
        var character := text.substr(i, 1)
        if character == "[":
            in_tag = true
            output += character
            i += 1
            continue
        if character == "]":
            in_tag = false
            output += character
            i += 1
            continue
        if in_tag:
            output += character
            i += 1
            continue

        if _is_chat_letter(character):
            if capitalize_next:
                output += character.to_upper()
                capitalize_next = false
            elif character == "i" and word_start and _is_standalone_i(text, i):
                output += "I"
            else:
                output += character
            word_start = false
        else:
            output += character
            if character in [".", "!", "?"]:
                capitalize_next = true
            word_start = not _is_chat_digit(character)
        i += 1
    return output

func _is_standalone_i(text: String, index: int) -> bool:
    var previous_is_word := index > 0 and _is_chat_word_character(text.substr(index - 1, 1))
    var next_is_word := index < text.length() - 1 and _is_chat_word_character(text.substr(index + 1, 1))
    return not previous_is_word and not next_is_word

func _is_chat_word_character(character: String) -> bool:
    return _is_chat_letter(character) or _is_chat_digit(character) or character == "_"

func _is_chat_letter(character: String) -> bool:
    return character.to_lower() != character.to_upper()

func _is_chat_digit(character: String) -> bool:
    return character >= "0" and character <= "9"

func _speaker_text_case(speaker: String) -> String:
    if speaker == "room" or speaker == "system":
        return "proper"
    for friend in FRIENDS:
        if str(friend.get("id", "")) == speaker:
            return str(friend.get("text_case", "informal"))
    for enemy in ENEMIES.values():
        if str(enemy.get("id", "")) == speaker:
            return str(enemy.get("text_case", "proper"))
    return "informal"

func _speaker_display_name(speaker: String) -> String:
    if speaker == "room":
        return "ROOM"
    if speaker == "system":
        return _translate("OPEN_PIT_CHAT_SYSTEM")
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
    if speaker == "system":
        return "#ffd66b"
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

func _format_translated(template: String, args: Array) -> String:
    return _translate(template) % args

func _zone_name(zone: int) -> String:
    match zone:
        0:
            return _translate("Proxy Cache")
        1:
            return _translate("Cipher Depths")
        2:
            return _translate("Ghost Sector")
        3:
            return _translate("Root Well")
        _:
            return _translate("Kernel Vault")

func _translate(key: String) -> String:
    return TranslationServer.translate(key)
