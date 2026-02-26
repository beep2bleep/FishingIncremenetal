extends RefCounted
class_name FishingUpgradeDB

const DATA_PATH := "res://Data/FishingUpgradeData.json"
const EXTRA_FAMILY_ORDER: Array[String] = ["ECON", "DENS", "SURV", "MOVE", "POWR", "ACTV", "BOSS", "TEAM"]
const EXTRA_NAME_A: Array[String] = ["Adaptive", "Fractal", "Iron", "Solar", "Echo", "Rift", "Pulse", "Aegis", "Vector", "Nova"]
const EXTRA_NAME_B: Array[String] = ["Circuit", "Relay", "Ledger", "Spine", "Burst", "Anchor", "Lattice", "Compass", "Engine", "Matrix"]
const FAMILY_DESCRIPTIONS := {
    "ECON": "Improves income conversion and pickup efficiency.",
    "DENS": "Increases enemy pressure to raise total reward ceiling.",
    "SURV": "Improves survivability and run depth.",
    "MOVE": "Improves traversal tempo.",
    "POWR": "Improves power economy for actives.",
    "ACTV": "Improves active ability uptime.",
    "BOSS": "Improves boss phase output, safety, or rewards.",
    "TEAM": "Improves hero-specific combat synergy.",
}
const SPECIFIC_DESCRIPTIONS := {
    "cursor_pickup_unlock": "Unlocks cursor pickup bonuses so cursor-collected coins are worth more.",
    "recruit_archer": "Adds the Archer hero to your combat lineup.",
    "auto_attack_unlock": "Unlocks automatic attack support for your team.",
    "knight_vamp_unlock": "Unlocks the Knight active and improves life steal sustain.",
    "archer_pierce_unlock": "Unlocks the Archer active with piercing attack coverage.",
    "power_harvest_unlock": "Unlocks stronger power generation from combat and pickups.",
    "recruit_guardian": "Adds the Guardian hero to your combat lineup.",
    "guardian_fortify_unlock": "Unlocks the Guardian active and boosts defensive uptime.",
    "recruit_mage": "Adds the Mage hero to your combat lineup.",
    "mage_storm_unlock": "Unlocks the Mage active and improves storm damage output.",
}
const SPECIFIC_NAMES := {
    "cursor_pickup_unlock": "Cursor Pickup Unlock",
    "recruit_archer": "Recruit Archer",
    "auto_attack_unlock": "Auto Attack Unlock",
    "knight_vamp_unlock": "Knight Vampirism Unlock",
    "archer_pierce_unlock": "Archer Pierce Unlock",
    "power_harvest_unlock": "Power Harvest Unlock",
    "recruit_guardian": "Recruit Guardian",
    "guardian_fortify_unlock": "Guardian Fortify Unlock",
    "recruit_mage": "Recruit Mage",
    "mage_storm_unlock": "Mage Storm Unlock",
}

var nodes: Array[Dictionary] = []
var node_by_id: Dictionary = {}

func _init() -> void:
    var data = Util.load_json_data_from_path(DATA_PATH)
    if data == null:
        return
    var arr = data.get("upgrades", [])
    for item in arr:
        var node: Dictionary = item
        node = node.duplicate(true)
        node["icon"] = _resolve_icon(node)
        nodes.append(node)
        node_by_id[node.get("id", "")] = node

func is_owned(node: Dictionary) -> bool:
    return SaveHandler.get_fishing_upgrade_level(str(node.get("key", ""))) >= int(node.get("level", 1))

func is_dependency_met(node: Dictionary) -> bool:
    var dep_id: String = str(node.get("dependency", ""))
    if dep_id == "":
        return true
    if not node_by_id.has(dep_id):
        return true
    return is_owned(node_by_id[dep_id])

func can_buy(node: Dictionary) -> bool:
    if is_owned(node):
        return false
    if not is_dependency_met(node):
        return false
    var key: String = str(node.get("key", ""))
    var target_level: int = int(node.get("level", 1))
    var current_level: int = SaveHandler.get_fishing_upgrade_level(key)
    if target_level != current_level + 1:
        return false
    return SaveHandler.fishing_currency >= int(round(float(node.get("cost", 0.0))))

func buy(node: Dictionary) -> bool:
    if not can_buy(node):
        return false
    var cost: int = int(round(float(node.get("cost", 0.0))))
    SaveHandler.fishing_currency = max(0, SaveHandler.fishing_currency - cost)
    var key: String = str(node.get("key", ""))
    var repeatable: bool = bool(node.get("repeatable", false))
    SaveHandler.unlock_fishing_upgrade(key, repeatable)
    SaveHandler.save_fishing_progress()
    return true

func get_display_name(node: Dictionary) -> String:
    var key: String = str(node.get("key", ""))
    var level: int = int(node.get("level", 1))

    if SPECIFIC_NAMES.has(key):
        return SPECIFIC_NAMES[key]
    if key.begins_with("extra_skill_"):
        return _extra_skill_name(key)
    if key.begins_with("core_"):
        return _core_name(key)

    var clean_key: String = key
    if clean_key.ends_with("_60"):
        clean_key = clean_key.trim_suffix("_60")
    var display_name: String = _humanize_name(clean_key)
    if level > 1 and not display_name.ends_with(_roman(level)):
        display_name += " " + _roman(level)
    return display_name

func get_description(node: Dictionary) -> String:
    var explicit_description: String = str(node.get("description", "")).strip_edges()
    if explicit_description != "":
        return explicit_description

    var key: String = str(node.get("key", ""))
    if SPECIFIC_DESCRIPTIONS.has(key):
        return SPECIFIC_DESCRIPTIONS[key]

    if key.begins_with("core_"):
        return _describe_core_upgrade(key, int(node.get("level", 1)))
    if key.begins_with("extra_skill_"):
        return _describe_extra_skill(key)

    var family_desc: String = _infer_family_description(key)
    if family_desc != "":
        return family_desc

    return "Improves this upgrade path and your overall run strength."

func _describe_core_upgrade(key: String, level: int) -> String:
    if key == "core_armor":
        return "Increase armor by 1 step (up to 75% mitigation cap)."
    if key == "core_density":
        return "Increase enemy density by 1 step for higher potential rewards."
    if key == "core_drop":
        return "Increase coin drop value scaling by 1 step."
    if key == "core_power":
        return "Increase power gain and power cap by 1 step."

    if key.find("knight") != -1:
        if key.find("damage") != -1:
            return "Increase Knight damage (+3 per level)."
        if key.find("speed") != -1:
            return "Increase Knight attack speed (+0.16 attacks/sec per level)."
        if key.find("active_cap") != -1:
            return "Increase Knight active power cap (+10 cap per level)."
    if key.find("archer") != -1:
        if key.find("damage") != -1:
            return "Increase Archer damage (+3 per level)."
        if key.find("speed") != -1:
            return "Increase Archer attack speed (+0.16 attacks/sec per level)."
        if key.find("active_cap") != -1:
            return "Increase Archer active power cap (+10 cap per level)."
    if key.find("guardian") != -1:
        if key.find("damage") != -1:
            return "Increase Guardian damage (+3 per level)."
        if key.find("speed") != -1:
            return "Increase Guardian attack speed (+0.16 attacks/sec per level)."
        if key.find("active_cap") != -1:
            return "Increase Guardian active power cap (+10 cap per level)."
    if key.find("mage") != -1:
        if key.find("damage") != -1:
            return "Increase Mage damage (+3 per level)."
        if key.find("speed") != -1:
            return "Increase Mage attack speed (+0.16 attacks/sec per level)."
        if key.find("active_cap") != -1:
            return "Increase Mage active power cap (+10 cap per level)."

    return "Increase this core stat scaling (Level %d)." % level

func _describe_extra_skill(key: String) -> String:
    var family: String = _extra_skill_family(key)
    match family:
        "ECON":
            return "Improves economy stats (drop value, pickup efficiency, or reward conversion)."
        "DENS":
            return "Increases enemy pressure and spawn value to raise run income ceiling."
        "SURV":
            return "Improves survivability (armor, contact reduction, DoT reduction, or max HP)."
        "MOVE":
            return "Improves traversal and retarget tempo for faster frontline progress."
        "POWR":
            return "Improves power gain/cap/refund so actives are available more often."
        "ACTV":
            return "Improves active uptime (duration, cooldown, or cooldown tick rate)."
        "BOSS":
            return "Improves boss-phase performance (armor, damage, drops, or boss HP reduction)."
        "TEAM":
            return "Improves hero-specific stats or active caps across the team."
        _:
            return "Pattern-generated extra skill that boosts run performance."

func _extra_skill_family(key: String) -> String:
    var n: int = int(key.trim_prefix("extra_skill_"))
    if n <= 0:
        return "TEAM"
    return EXTRA_FAMILY_ORDER[(n - 1) % EXTRA_FAMILY_ORDER.size()]

func _infer_family_description(key: String) -> String:
    if key.find("boss") != -1:
        return FAMILY_DESCRIPTIONS["BOSS"]
    if key.find("active") != -1 or key.find("invocation") != -1 or key.find("channel") != -1 or key.find("cadence") != -1:
        return FAMILY_DESCRIPTIONS["ACTV"]
    if key.find("power") != -1 or key.find("condensed") != -1 or key.find("reservoir") != -1 or key.find("echo") != -1:
        return FAMILY_DESCRIPTIONS["POWR"]
    if key.find("drop") != -1 or key.find("salvage") != -1 or key.find("market") != -1 or key.find("scanner") != -1 or key.find("collector") != -1:
        return FAMILY_DESCRIPTIONS["ECON"]
    if key.find("horde") != -1 or key.find("pressure") != -1 or key.find("wave") != -1 or key.find("crowd") != -1:
        return FAMILY_DESCRIPTIONS["DENS"]
    if key.find("armor") != -1 or key.find("plate") != -1 or key.find("carapace") != -1 or key.find("shock") != -1 or key.find("hemostasis") != -1:
        return FAMILY_DESCRIPTIONS["SURV"]
    if key.find("boot") != -1 or key.find("stride") != -1 or key.find("route") != -1 or key.find("quickstep") != -1 or key.find("march") != -1 or key.find("sprint") != -1:
        return FAMILY_DESCRIPTIONS["MOVE"]
    if key.find("knight") != -1 or key.find("archer") != -1 or key.find("guardian") != -1 or key.find("mage") != -1:
        return FAMILY_DESCRIPTIONS["TEAM"]
    return ""

func _humanize_name(name_text: String) -> String:
    var text: String = name_text.strip_edges()
    if text == "":
        return "Upgrade"
    text = text.to_lower().replace("_", " ")
    var words: PackedStringArray = text.split(" ", false)
    for i in range(words.size()):
        if words[i].length() <= 0:
            continue
        words[i] = words[i].substr(0, 1).to_upper() + words[i].substr(1)
    return " ".join(words)

func _resolve_icon(node: Dictionary) -> String:
    var raw_icon: String = str(node.get("icon", "")).strip_edges()
    if raw_icon != "" and raw_icon != "?":
        return raw_icon.substr(0, 1)
    return _fallback_icon_for_key(str(node.get("key", "")))

func _fallback_icon_for_key(key: String) -> String:
    var lower: String = key.to_lower()
    if lower.begins_with("core_"):
        return "C"
    if lower.begins_with("extra_skill_"):
        var family: String = _extra_skill_family(lower)
        match family:
            "ECON":
                return "E"
            "DENS":
                return "D"
            "SURV":
                return "S"
            "MOVE":
                return "M"
            "POWR":
                return "P"
            "ACTV":
                return "A"
            "BOSS":
                return "B"
            _:
                return "T"
    if lower.begins_with("recruit_"):
        return "H"
    if lower.find("boss") != -1:
        return "B"
    if lower.find("power") != -1 or lower.find("active") != -1:
        return "P"
    if lower.find("armor") != -1 or lower.find("plate") != -1 or lower.find("fortify") != -1:
        return "S"
    if lower.find("drop") != -1 or lower.find("coin") != -1 or lower.find("salvage") != -1 or lower.find("magnet") != -1:
        return "E"
    if lower.find("damage") != -1 or lower.find("speed") != -1:
        return "D"
    var fallback: String = lower.strip_edges()
    if fallback == "":
        return "U"
    return fallback.substr(0, 1).to_upper()

func _extra_skill_name(key: String) -> String:
    var n: int = int(key.trim_prefix("extra_skill_"))
    if n <= 0:
        return "Extra Skill"
    var idx: int = (n - 1) % EXTRA_NAME_A.size()
    return "%s %s %d" % [EXTRA_NAME_A[idx], EXTRA_NAME_B[idx], n]

func _core_name(key: String) -> String:
    if key == "core_armor":
        return "Core Armor"
    if key == "core_density":
        return "Core Density"
    if key == "core_drop":
        return "Core Drop"
    if key == "core_power":
        return "Core Power"
    if key.find("knight") != -1 and key.find("damage") != -1:
        return "Core Knight Damage"
    if key.find("knight") != -1 and key.find("speed") != -1:
        return "Core Knight Speed"
    if key.find("knight") != -1 and key.find("active_cap") != -1:
        return "Core Knight Active Cap"
    if key.find("archer") != -1 and key.find("damage") != -1:
        return "Core Archer Damage"
    if key.find("archer") != -1 and key.find("speed") != -1:
        return "Core Archer Speed"
    if key.find("archer") != -1 and key.find("active_cap") != -1:
        return "Core Archer Active Cap"
    if key.find("guardian") != -1 and key.find("damage") != -1:
        return "Core Guardian Damage"
    if key.find("guardian") != -1 and key.find("speed") != -1:
        return "Core Guardian Speed"
    if key.find("guardian") != -1 and key.find("active_cap") != -1:
        return "Core Guardian Active Cap"
    if key.find("mage") != -1 and key.find("damage") != -1:
        return "Core Mage Damage"
    if key.find("mage") != -1 and key.find("speed") != -1:
        return "Core Mage Speed"
    if key.find("mage") != -1 and key.find("active_cap") != -1:
        return "Core Mage Active Cap"
    return _humanize_name(key)

func _roman(value: int) -> String:
    match value:
        1:
            return "I"
        2:
            return "II"
        3:
            return "III"
        4:
            return "IV"
        5:
            return "V"
        6:
            return "VI"
        7:
            return "VII"
        8:
            return "VIII"
        9:
            return "IX"
        10:
            return "X"
        _:
            return str(value)
