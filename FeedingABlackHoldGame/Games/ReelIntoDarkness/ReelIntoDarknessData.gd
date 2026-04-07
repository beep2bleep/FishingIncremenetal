extends RefCounted
class_name ReelIntoDarknessData

const MODE_TITLE := "Reel Into Darkness"
const STARTING_WALLET := 0
const ICON_PREFIX := "reel://"

const FISH_CATALOG: Array[Dictionary] = [
	{
		"id": "glint_sprat",
		"name": "Glint Sprat",
		"min_depth": 2.0,
		"max_depth": 10.0,
		"stamina": 4.0,
		"value": 6,
		"size": Vector2(30.0, 14.0),
		"color": Color(0.62, 0.9, 0.95, 1.0),
		"accent": Color(0.92, 0.97, 1.0, 1.0),
		"speed": 34.0,
		"weight": 6.0,
	},
	{
		"id": "lantern_koi",
		"name": "Lantern Koi",
		"min_depth": 6.0,
		"max_depth": 18.0,
		"stamina": 6.0,
		"value": 10,
		"size": Vector2(36.0, 18.0),
		"color": Color(0.98, 0.72, 0.42, 1.0),
		"accent": Color(1.0, 0.92, 0.72, 1.0),
		"speed": 30.0,
		"weight": 5.0,
	},
	{
		"id": "dusk_bass",
		"name": "Dusk Bass",
		"min_depth": 10.0,
		"max_depth": 28.0,
		"stamina": 9.0,
		"value": 16,
		"size": Vector2(44.0, 20.0),
		"color": Color(0.38, 0.58, 0.84, 1.0),
		"accent": Color(0.76, 0.86, 0.99, 1.0),
		"speed": 28.0,
		"weight": 4.5,
	},
	{
		"id": "ember_pike",
		"name": "Ember Pike",
		"min_depth": 18.0,
		"max_depth": 38.0,
		"stamina": 14.0,
		"value": 26,
		"size": Vector2(54.0, 20.0),
		"color": Color(0.86, 0.36, 0.3, 1.0),
		"accent": Color(1.0, 0.78, 0.52, 1.0),
		"speed": 34.0,
		"weight": 3.7,
	},
	{
		"id": "velvet_snapper",
		"name": "Velvet Snapper",
		"min_depth": 28.0,
		"max_depth": 52.0,
		"stamina": 20.0,
		"value": 40,
		"size": Vector2(58.0, 24.0),
		"color": Color(0.68, 0.3, 0.58, 1.0),
		"accent": Color(0.94, 0.76, 0.9, 1.0),
		"speed": 30.0,
		"weight": 3.0,
	},
	{
		"id": "moon_eel",
		"name": "Moon Eel",
		"min_depth": 40.0,
		"max_depth": 70.0,
		"stamina": 32.0,
		"value": 70,
		"size": Vector2(66.0, 14.0),
		"color": Color(0.58, 0.86, 0.92, 1.0),
		"accent": Color(0.92, 0.99, 1.0, 1.0),
		"speed": 40.0,
		"weight": 2.4,
	},
	{
		"id": "abyss_grouper",
		"name": "Abyss Grouper",
		"min_depth": 58.0,
		"max_depth": 92.0,
		"stamina": 52.0,
		"value": 120,
		"size": Vector2(72.0, 32.0),
		"color": Color(0.28, 0.42, 0.62, 1.0),
		"accent": Color(0.75, 0.88, 0.99, 1.0),
		"speed": 25.0,
		"weight": 1.8,
	},
	{
		"id": "crown_angler",
		"name": "Crown Angler",
		"min_depth": 82.0,
		"max_depth": 118.0,
		"stamina": 78.0,
		"value": 220,
		"size": Vector2(82.0, 36.0),
		"color": Color(0.18, 0.22, 0.34, 1.0),
		"accent": Color(0.96, 0.82, 0.4, 1.0),
		"speed": 23.0,
		"weight": 1.0,
	},
]

const META_UPGRADES: Array[Dictionary] = [
	{"id": "deck_clock", "label": "Deck Clock", "summary": "Adds a few extra seconds before the boat calls the line home.", "icon": "T", "act": 1, "cell": Vector2(-6, -1), "dependency": "", "branch": 1, "step": 1, "base_cost": 14, "cost_scale": 1.36, "max_tier": 6},
	{"id": "night_watch", "label": "Night Watch", "summary": "Stretches each run so you can safely finish one more fish fight.", "icon": "T", "act": 1, "cell": Vector2(-5, -2), "dependency": "deck_clock", "branch": 1, "step": 2, "base_cost": 22, "cost_scale": 1.38, "max_tier": 5},
	{"id": "tide_almanac", "label": "Tide Almanac", "summary": "Longer hunting windows and steadier late-run pressure.", "icon": "T", "act": 1, "cell": Vector2(-4, -3), "dependency": "night_watch", "branch": 1, "step": 3, "base_cost": 36, "cost_scale": 1.42, "max_tier": 5},
	{"id": "angler_grit", "label": "Angler Grit", "summary": "More personal stamina so you can survive mistakes and land tougher fish.", "icon": "S", "act": 2, "cell": Vector2(-2, 0), "dependency": "", "branch": 2, "step": 1, "base_cost": 16, "cost_scale": 1.36, "max_tier": 6},
	{"id": "shoulder_harness", "label": "Shoulder Harness", "summary": "Less strain per clean pull and more control during long fights.", "icon": "S", "act": 2, "cell": Vector2(-1, -1), "dependency": "angler_grit", "branch": 2, "step": 2, "base_cost": 26, "cost_scale": 1.4, "max_tier": 5},
	{"id": "counterweight_reel", "label": "Counterweight Reel", "summary": "Turns correct holds into much stronger upward progress.", "icon": "S", "act": 2, "cell": Vector2(0, -2), "dependency": "shoulder_harness", "branch": 2, "step": 3, "base_cost": 42, "cost_scale": 1.44, "max_tier": 5},
	{"id": "lead_sinkers", "label": "Lead Sinkers", "summary": "Lets the line reach deeper fish before the current slows you down.", "icon": "D", "act": 3, "cell": Vector2(1, 1), "dependency": "", "branch": 3, "step": 1, "base_cost": 18, "cost_scale": 1.38, "max_tier": 6},
	{"id": "deep_charts", "label": "Deep Charts", "summary": "Pushes your safe fishing depth into darker water bands.", "icon": "D", "act": 3, "cell": Vector2(2, 2), "dependency": "lead_sinkers", "branch": 3, "step": 2, "base_cost": 30, "cost_scale": 1.42, "max_tier": 5},
	{"id": "abyss_permits", "label": "Abyss Permits", "summary": "Opens the brutal late-water layers where the real money hides.", "icon": "D", "act": 3, "cell": Vector2(3, 3), "dependency": "deep_charts", "branch": 3, "step": 3, "base_cost": 52, "cost_scale": 1.46, "max_tier": 5},
	{"id": "braided_line", "label": "Braided Line", "summary": "Improves side-to-side control when the hook swings under the boat.", "icon": "L", "act": 4, "cell": Vector2(4, -1), "dependency": "", "branch": 4, "step": 1, "base_cost": 18, "cost_scale": 1.36, "max_tier": 6},
	{"id": "pendulum_guide", "label": "Pendulum Guide", "summary": "Transfers your mouse movement into cleaner hook momentum.", "icon": "L", "act": 4, "cell": Vector2(5, -2), "dependency": "braided_line", "branch": 4, "step": 2, "base_cost": 30, "cost_scale": 1.4, "max_tier": 5},
	{"id": "keel_stabilizer", "label": "Keel Stabilizer", "summary": "Shrinks the punishment on bad inputs and keeps the boat calmer.", "icon": "L", "act": 4, "cell": Vector2(6, -3), "dependency": "pendulum_guide", "branch": 4, "step": 3, "base_cost": 46, "cost_scale": 1.44, "max_tier": 5},
	{"id": "chum_lantern", "label": "Chum Lantern", "summary": "Makes nearby fish commit a little harder when the hook gets close.", "icon": "B", "act": 5, "cell": Vector2(2, -4), "dependency": "", "branch": 5, "step": 1, "base_cost": 20, "cost_scale": 1.37, "max_tier": 6},
	{"id": "silver_crates", "label": "Silver Crates", "summary": "Better packing and handling means every landed fish sells for more.", "icon": "$", "act": 5, "cell": Vector2(3, -5), "dependency": "chum_lantern", "branch": 5, "step": 2, "base_cost": 34, "cost_scale": 1.42, "max_tier": 5},
	{"id": "black_market_buyer", "label": "Black Market Buyer", "summary": "The strangest deep catches start commanding serious money.", "icon": "$", "act": 5, "cell": Vector2(4, -6), "dependency": "silver_crates", "branch": 5, "step": 3, "base_cost": 54, "cost_scale": 1.46, "max_tier": 5},
]

static func get_meta_upgrade_catalog() -> Array[Dictionary]:
	return META_UPGRADES.duplicate(true)

static func get_fish_catalog() -> Array[Dictionary]:
	return FISH_CATALOG.duplicate(true)

static func get_run_config(upgrades: Dictionary = {}) -> Dictionary:
	var config := {
		"time_limit": 30.0,
		"player_stamina": 12.0,
		"fish_drain_multiplier": 1.0,
		"max_depth": 24.0,
		"sink_speed": 15.0,
		"reel_speed": 17.0,
		"auto_retract_speed": 72.0,
		"hook_control": 1.0,
		"mouse_impulse": 0.9,
		"mistake_penalty_multiplier": 1.0,
		"reward_multiplier": 1.0,
		"attraction_radius": 34.0,
		"reel_cost_multiplier": 1.0,
	}
	var deck_clock: int = int(upgrades.get("deck_clock", 0))
	var night_watch: int = int(upgrades.get("night_watch", 0))
	var tide_almanac: int = int(upgrades.get("tide_almanac", 0))
	var angler_grit: int = int(upgrades.get("angler_grit", 0))
	var shoulder_harness: int = int(upgrades.get("shoulder_harness", 0))
	var counterweight_reel: int = int(upgrades.get("counterweight_reel", 0))
	var lead_sinkers: int = int(upgrades.get("lead_sinkers", 0))
	var deep_charts: int = int(upgrades.get("deep_charts", 0))
	var abyss_permits: int = int(upgrades.get("abyss_permits", 0))
	var braided_line: int = int(upgrades.get("braided_line", 0))
	var pendulum_guide: int = int(upgrades.get("pendulum_guide", 0))
	var keel_stabilizer: int = int(upgrades.get("keel_stabilizer", 0))
	var chum_lantern: int = int(upgrades.get("chum_lantern", 0))
	var silver_crates: int = int(upgrades.get("silver_crates", 0))
	var black_market_buyer: int = int(upgrades.get("black_market_buyer", 0))

	config["time_limit"] += float(deck_clock) * 3.0 + float(night_watch) * 2.0 + float(tide_almanac) * 2.5
	config["player_stamina"] += float(angler_grit) * 1.8 + float(shoulder_harness) * 1.3 + float(counterweight_reel) * 0.7
	config["fish_drain_multiplier"] += float(angler_grit) * 0.04 + float(shoulder_harness) * 0.08 + float(counterweight_reel) * 0.12
	config["max_depth"] += float(lead_sinkers) * 8.0 + float(deep_charts) * 12.0 + float(abyss_permits) * 16.0
	config["sink_speed"] += float(lead_sinkers) * 0.7 + float(deep_charts) * 0.6
	config["reel_speed"] += float(shoulder_harness) * 0.5 + float(counterweight_reel) * 1.0
	config["auto_retract_speed"] += float(counterweight_reel) * 2.0 + float(abyss_permits) * 1.5
	config["hook_control"] += float(braided_line) * 0.14 + float(pendulum_guide) * 0.18
	config["mouse_impulse"] += float(braided_line) * 0.05 + float(pendulum_guide) * 0.08
	config["mistake_penalty_multiplier"] *= pow(0.92, float(keel_stabilizer))
	config["reward_multiplier"] *= 1.0 + float(silver_crates) * 0.08 + float(black_market_buyer) * 0.11
	config["attraction_radius"] += float(chum_lantern) * 5.0
	config["reel_cost_multiplier"] *= pow(0.95, float(shoulder_harness))
	return config

static func get_available_fish_for_depth(max_depth: float) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for fish_variant in FISH_CATALOG:
		var fish: Dictionary = fish_variant
		if float(fish.get("min_depth", 0.0)) <= max_depth + 0.01:
			available.append(fish.duplicate(true))
	return available

static func pick_fish_for_depth(depth_meters: float, rng: RandomNumberGenerator) -> Dictionary:
	var candidates: Array[Dictionary] = []
	var total_weight := 0.0
	for fish_variant in FISH_CATALOG:
		var fish: Dictionary = fish_variant
		var min_depth: float = float(fish.get("min_depth", 0.0))
		var max_depth: float = float(fish.get("max_depth", 0.0))
		if depth_meters < min_depth or depth_meters > max_depth:
			continue
		var midpoint: float = (min_depth + max_depth) * 0.5
		var range_half: float = max(1.0, (max_depth - min_depth) * 0.5)
		var closeness: float = 1.0 - clampf(absf(depth_meters - midpoint) / range_half, 0.0, 1.0)
		var weight: float = max(0.2, float(fish.get("weight", 1.0)) * (0.55 + closeness * 0.9))
		var weighted_fish: Dictionary = fish.duplicate(true)
		weighted_fish["_weight"] = weight
		total_weight += weight
		candidates.append(weighted_fish)
	if candidates.is_empty():
		return FISH_CATALOG[0].duplicate(true)
	var roll: float = rng.randf() * total_weight
	for candidate_variant in candidates:
		var candidate: Dictionary = candidate_variant
		roll -= float(candidate.get("_weight", 0.0))
		if roll <= 0.0:
			candidate.erase("_weight")
			return candidate
	var fallback: Dictionary = candidates.back().duplicate(true)
	fallback.erase("_weight")
	return fallback
