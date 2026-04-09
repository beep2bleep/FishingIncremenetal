extends RefCounted
class_name TurkeyData

const DEFAULT_BALL_WEIGHT_LB := 8.0
const KG_PER_LB := 0.45359237
## League Pass upgrade level required to reach each lane tier index (0..4).
const LANE_TIER_UNLOCK_LEVELS := [0, 2, 4, 6, 8]
## Completed Turkey series (runs) — parallel unlock so higher tiers are reachable without maxing League Pass.
const VETERAN_RUN_MILESTONES := [0, 2, 7, 18, 40]

## Extra mass multiplier on top of lane tier mass; multiplied per-tier by `gold_mass_scale` on gold pins.
const GOLD_PIN_MASS_MULT := 6.75
## Visual + collision scale so the gold pin reads instantly from the approach camera.
const GOLD_PIN_SCALE := 1.38

const UPGRADE_DEFINITIONS: Array[Dictionary] = [
	{
		"id": "power_training",
		"label": "Power Training",
		"summary": "Raise launch speed so the ball keeps driving through the deck.",
		"icon": "P",
		"max_tier": 8,
		"base_cost": 20,
		"cost_mult": 1.42,
		"cell": Vector2(0, -5),
		"dependency": "",
		"act": 1,
		"branch": 1,
		"step": 1,
	},
	{
		"id": "lane_reading",
		"label": "Lane Reading",
		"summary": "Reduce baseline miss so picked lines land closer to where you aimed.",
		"icon": "L",
		"max_tier": 8,
		"base_cost": 26,
		"cost_mult": 1.42,
		"cell": Vector2(-2, -4),
		"dependency": "power_training",
		"act": 1,
		"branch": 1,
		"step": 2,
	},
	{
		"id": "hook_control",
		"label": "Hook Control",
		"summary": "Increase how strongly your spin slider bends the lane.",
		"icon": "H",
		"max_tier": 8,
		"base_cost": 28,
		"cost_mult": 1.42,
		"cell": Vector2(2, -4),
		"dependency": "power_training",
		"act": 1,
		"branch": 2,
		"step": 2,
	},
	{
		"id": "ball_weight",
		"label": "Ball Weight",
		"summary": "Heavier equipment hits tougher racks hard enough to keep driving.",
		"icon": "W",
		"max_tier": 7,
		"base_cost": 32,
		"cost_mult": 1.44,
		"cell": Vector2(0, -4),
		"dependency": "power_training",
		"act": 1,
		"branch": 3,
		"step": 2,
	},
	{
		"id": "release_timing",
		"label": "Release Timing",
		"summary": "Shrink wobble further so the power lock and line choice hold up under pressure.",
		"icon": "R",
		"max_tier": 7,
		"base_cost": 38,
		"cost_mult": 1.46,
		"cell": Vector2(-4, -3),
		"dependency": "lane_reading",
		"act": 2,
		"branch": 1,
		"step": 3,
	},
	{
		"id": "approach_rhythm",
		"label": "Approach Rhythm",
		"summary": "Slow the power meter so high-power releases are easier to hit consistently.",
		"icon": "M",
		"max_tier": 6,
		"base_cost": 42,
		"cost_mult": 1.45,
		"cell": Vector2(-2, -3),
		"dependency": "lane_reading",
		"act": 2,
		"branch": 1,
		"step": 4,
	},
	{
		"id": "spare_focus",
		"label": "Spare Focus",
		"summary": "Improve accuracy and payouts on cleanup balls when pins are left standing.",
		"icon": "S",
		"max_tier": 6,
		"base_cost": 48,
		"cost_mult": 1.47,
		"cell": Vector2(-3, -2),
		"dependency": "release_timing",
		"act": 2,
		"branch": 1,
		"step": 5,
	},
	{
		"id": "rev_training",
		"label": "Rev Training",
		"summary": "Build stronger backend motion so the ball keeps finishing through the pins.",
		"icon": "V",
		"max_tier": 7,
		"base_cost": 44,
		"cost_mult": 1.45,
		"cell": Vector2(4, -3),
		"dependency": "hook_control",
		"act": 2,
		"branch": 2,
		"step": 3,
	},
	{
		"id": "target_range",
		"label": "Target Range",
		"summary": "Open the approach and aiming envelope so tougher tiers still feel playable.",
		"icon": "T",
		"max_tier": 6,
		"base_cost": 46,
		"cost_mult": 1.46,
		"cell": Vector2(2, -2),
		"dependency": "hook_control",
		"act": 2,
		"branch": 2,
		"step": 4,
	},
	{
		"id": "coverstock_resin",
		"label": "Coverstock Resin",
		"summary": "Counter slicker tier oil patterns by preserving hook deeper into the lane.",
		"icon": "C",
		"max_tier": 6,
		"base_cost": 54,
		"cost_mult": 1.48,
		"cell": Vector2(6, -2),
		"dependency": "rev_training",
		"act": 2,
		"branch": 2,
		"step": 5,
	},
	{
		"id": "core_balance",
		"label": "Core Balance",
		"summary": "Add subtle target assist so the ball self-corrects back toward your line.",
		"icon": "B",
		"max_tier": 6,
		"base_cost": 56,
		"cost_mult": 1.49,
		"cell": Vector2(1, -1),
		"dependency": "ball_weight",
		"act": 3,
		"branch": 3,
		"step": 3,
	},
	{
		"id": "impact_physics",
		"label": "Impact Physics",
		"summary": "Improve carry by making each hit transfer force more efficiently through the rack.",
		"icon": "I",
		"max_tier": 7,
		"base_cost": 60,
		"cost_mult": 1.5,
		"cell": Vector2(4, -1),
		"dependency": "ball_weight",
		"act": 3,
		"branch": 3,
		"step": 4,
	},
	{
		"id": "pocket_magnet",
		"label": "Pocket Magnet",
		"summary": "Add stronger late-lane homing so high-tier carries feel more intentional.",
		"icon": "G",
		"max_tier": 6,
		"base_cost": 72,
		"cost_mult": 1.52,
		"cell": Vector2(0, 0),
		"dependency": "core_balance",
		"act": 3,
		"branch": 4,
		"step": 4,
	},
	{
		"id": "lane_guides",
		"label": "Lane Guides",
		"summary": "Add inward correction near the gutter so good shots are not lost quite as easily.",
		"icon": "U",
		"max_tier": 5,
		"base_cost": 78,
		"cost_mult": 1.54,
		"cell": Vector2(-4, 0),
		"dependency": "spare_focus",
		"act": 3,
		"branch": 4,
		"step": 3,
	},
	{
		"id": "sweep_crew",
		"label": "Sweep Crew",
		"summary": "Speed up how quickly the game confirms the rack is finished and scores the ball.",
		"icon": "Q",
		"max_tier": 5,
		"base_cost": 82,
		"cost_mult": 1.53,
		"cell": Vector2(6, 0),
		"dependency": "impact_physics",
		"act": 3,
		"branch": 4,
		"step": 5,
	},
	{
		"id": "sponsor_patch",
		"label": "Sponsor Patch",
		"summary": "Raise the baseline payout from every short series.",
		"icon": "$",
		"max_tier": 8,
		"base_cost": 48,
		"cost_mult": 1.45,
		"cell": Vector2(-6, 1),
		"dependency": "release_timing",
		"act": 4,
		"branch": 5,
		"step": 1,
	},
	{
		"id": "crowd_favor",
		"label": "Crowd Favor",
		"summary": "Turn strong runs into better strike and spare bonuses.",
		"icon": "F",
		"max_tier": 6,
		"base_cost": 70,
		"cost_mult": 1.5,
		"cell": Vector2(-4, 2),
		"dependency": "sponsor_patch",
		"act": 4,
		"branch": 5,
		"step": 2,
	},
	{
		"id": "turkey_bonus",
		"label": "Turkey Bonus",
		"summary": "Scale the payout for strike-heavy sets so chaining wins matters more.",
		"icon": "K",
		"max_tier": 6,
		"base_cost": 76,
		"cost_mult": 1.51,
		"cell": Vector2(-2, 2),
		"dependency": "sponsor_patch",
		"act": 4,
		"branch": 5,
		"step": 3,
	},
	{
		"id": "pin_science",
		"label": "Pin Science",
		"summary": "Convert harder racks into bigger payouts by valuing total pinfall more aggressively.",
		"icon": "N",
		"max_tier": 6,
		"base_cost": 84,
		"cost_mult": 1.52,
		"cell": Vector2(4, 2),
		"dependency": "impact_physics",
		"act": 4,
		"branch": 6,
		"step": 2,
	},
	{
		"id": "kingpin_hunter",
		"label": "Kingpin Hunter",
		"summary": "Boost full clears and carry against tougher promoted racks.",
		"icon": "X",
		"max_tier": 6,
		"base_cost": 92,
		"cost_mult": 1.53,
		"cell": Vector2(6, 2),
		"dependency": "pin_science",
		"act": 4,
		"branch": 6,
		"step": 3,
	},
	{
		"id": "league_pass",
		"label": "League Pass",
		"summary": "Promote into harder lane tiers with more pins, heavier decks, and better rewards. You also unlock tiers by finishing series (see lane tier prompt).",
		"icon": "J",
		"max_tier": 8,
		"base_cost": 120,
		"cost_mult": 1.58,
		"cell": Vector2(0, 3),
		"dependency": "pocket_magnet",
		"act": 5,
		"branch": 7,
		"step": 1,
	},
	{
		"id": "challenge_notes",
		"label": "Challenge Notes",
		"summary": "Study promoted lane tiers to shave down their accuracy and hook penalties.",
		"icon": "D",
		"max_tier": 6,
		"base_cost": 140,
		"cost_mult": 1.56,
		"cell": Vector2(2, 4),
		"dependency": "league_pass",
		"act": 5,
		"branch": 7,
		"step": 2,
	},
	{
		"id": "gutter_whisper",
		"label": "Gutter Whisper",
		"summary": "Strengthen emergency gutter rescue so promoted tiers stay recoverable.",
		"icon": "Y",
		"max_tier": 5,
		"base_cost": 132,
		"cost_mult": 1.55,
		"cell": Vector2(-2, 4),
		"dependency": "league_pass",
		"act": 5,
		"branch": 7,
		"step": 3,
	},
	{
		"id": "purse_bump",
		"label": "Purse Bump",
		"summary": "Scale rewards faster as you climb into the tougher promoted tiers.",
		"icon": "+",
		"max_tier": 6,
		"base_cost": 148,
		"cost_mult": 1.57,
		"cell": Vector2(4, 4),
		"dependency": "league_pass",
		"act": 5,
		"branch": 8,
		"step": 2,
	},
	{
		"id": "house_lights",
		"label": "House Lights",
		"summary": "Improve readability and composure on harder tiers while adding a reward kicker.",
		"icon": "O",
		"max_tier": 5,
		"base_cost": 156,
		"cost_mult": 1.56,
		"cell": Vector2(-4, 5),
		"dependency": "gutter_whisper",
		"act": 6,
		"branch": 8,
		"step": 3,
	},
	{
		"id": "ball_return_ai",
		"label": "Ball Return AI",
		"summary": "Stack homing and line-correction upgrades into a much stronger high-end assist package.",
		"icon": "A",
		"max_tier": 5,
		"base_cost": 170,
		"cost_mult": 1.58,
		"cell": Vector2(0, 5),
		"dependency": "challenge_notes",
		"act": 6,
		"branch": 8,
		"step": 4,
	},
	{
		"id": "champion_purse",
		"label": "Champion Purse",
		"summary": "Late progression multiplier that keeps high-tier demo and long-session earnings moving.",
		"icon": "*",
		"max_tier": 6,
		"base_cost": 210,
		"cost_mult": 1.62,
		"cell": Vector2(4, 5),
		"dependency": "purse_bump",
		"act": 6,
		"branch": 8,
		"step": 5,
	},
]

const LANE_TIERS: Array[Dictionary] = [
	{
		"label": "Practice House",
		"pin_count": 10,
		"gold_pin_count": 0,
		"gold_mass_scale": 1.0,
		"gold_pin_value": 0,
		"pin_mass_mult": 1.0,
		"pin_standing_dot": 0.84,
		"pin_spacing_mult": 1.0,
		"head_pin_z_offset": 0.0,
		"hook_damp": 1.0,
		"aim_error_mult": 1.0,
		"reward_mult": 1.0,
		"settle_speed_mult": 1.0,
		"gutter_penalty_mult": 1.0,
	},
	{
		"label": "League Night",
		"pin_count": 15,
		"gold_pin_count": 1,
		"gold_mass_scale": 1.06,
		"gold_pin_value": 16,
		"pin_mass_mult": 1.2,
		"pin_standing_dot": 0.865,
		"pin_spacing_mult": 1.06,
		"head_pin_z_offset": 0.05,
		"hook_damp": 0.93,
		"aim_error_mult": 1.12,
		"reward_mult": 1.32,
		"settle_speed_mult": 1.1,
		"gutter_penalty_mult": 1.04,
	},
	{
		"label": "Steel Rack",
		"pin_count": 21,
		"gold_pin_count": 2,
		"gold_mass_scale": 1.14,
		"gold_pin_value": 24,
		"pin_mass_mult": 1.34,
		"pin_standing_dot": 0.88,
		"pin_spacing_mult": 1.1,
		"head_pin_z_offset": 0.09,
		"hook_damp": 0.87,
		"aim_error_mult": 1.2,
		"reward_mult": 1.68,
		"settle_speed_mult": 1.18,
		"gutter_penalty_mult": 1.07,
	},
	{
		"label": "Majors Crown",
		"pin_count": 28,
		"gold_pin_count": 3,
		"gold_mass_scale": 1.22,
		"gold_pin_value": 34,
		"pin_mass_mult": 1.5,
		"pin_standing_dot": 0.895,
		"pin_spacing_mult": 1.14,
		"head_pin_z_offset": 0.12,
		"hook_damp": 0.82,
		"aim_error_mult": 1.28,
		"reward_mult": 2.05,
		"settle_speed_mult": 1.24,
		"gutter_penalty_mult": 1.1,
	},
	{
		"label": "Chaos Finals",
		"pin_count": 36,
		"gold_pin_count": 4,
		"gold_mass_scale": 1.32,
		"gold_pin_value": 46,
		"pin_mass_mult": 1.68,
		"pin_standing_dot": 0.912,
		"pin_spacing_mult": 1.18,
		"head_pin_z_offset": 0.16,
		"hook_damp": 0.77,
		"aim_error_mult": 1.38,
		"reward_mult": 2.55,
		"settle_speed_mult": 1.32,
		"gutter_penalty_mult": 1.14,
	},
]

static func get_meta_upgrade_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for definition in UPGRADE_DEFINITIONS:
		var entry: Dictionary = definition.duplicate(true)
		entry["tier_costs"] = _build_tier_costs(int(entry.get("base_cost", 0)), int(entry.get("max_tier", 1)), float(entry.get("cost_mult", 1.4)))
		catalog.append(entry)
	return catalog

static func get_lane_tier(index: int) -> Dictionary:
	var clamped_index: int = clampi(index, 0, LANE_TIERS.size() - 1)
	return LANE_TIERS[clamped_index].duplicate(true)

static func _get_lane_tier_from_veteran_runs(runs: int) -> int:
	var tier := 0
	for index in range(VETERAN_RUN_MILESTONES.size()):
		if runs >= int(VETERAN_RUN_MILESTONES[index]):
			tier = index
	return mini(tier, LANE_TIERS.size() - 1)

## Highest lane tier index the player may select: best of League Pass unlocks and veteran (completed series) unlocks.
static func get_max_selectable_lane_tier(data: Dictionary) -> int:
	var league_pass: int = int(data.get("meta_upgrades", {}).get("league_pass", 0))
	var runs: int = int(data.get("runs", 0))
	var from_league: int = _get_lane_tier_from_league_level(league_pass)
	var from_veteran: int = _get_lane_tier_from_veteran_runs(runs)
	return mini(LANE_TIERS.size() - 1, maxi(from_league, from_veteran))

static func get_lane_tier_cap_breakdown(data: Dictionary) -> Dictionary:
	var league_pass: int = int(data.get("meta_upgrades", {}).get("league_pass", 0))
	var runs: int = int(data.get("runs", 0))
	var from_league: int = _get_lane_tier_from_league_level(league_pass)
	var from_veteran: int = _get_lane_tier_from_veteran_runs(runs)
	return {
		"max_tier": get_max_selectable_lane_tier(data),
		"tier_from_league_pass": from_league,
		"tier_from_veteran_runs": from_veteran,
		"league_pass_level": league_pass,
		"completed_series": runs,
	}

static func build_meta_stats(data: Dictionary, gameplay_lane_tier: int = -1) -> Dictionary:
	var upgrades: Dictionary = data.get("meta_upgrades", {})
	var power_training: int = int(upgrades.get("power_training", 0))
	var lane_reading: int = int(upgrades.get("lane_reading", 0))
	var hook_control: int = int(upgrades.get("hook_control", 0))
	var ball_weight: int = int(upgrades.get("ball_weight", 0))
	var release_timing: int = int(upgrades.get("release_timing", 0))
	var approach_rhythm: int = int(upgrades.get("approach_rhythm", 0))
	var spare_focus: int = int(upgrades.get("spare_focus", 0))
	var rev_training: int = int(upgrades.get("rev_training", 0))
	var target_range: int = int(upgrades.get("target_range", 0))
	var coverstock_resin: int = int(upgrades.get("coverstock_resin", 0))
	var core_balance: int = int(upgrades.get("core_balance", 0))
	var impact_physics: int = int(upgrades.get("impact_physics", 0))
	var pocket_magnet: int = int(upgrades.get("pocket_magnet", 0))
	var lane_guides: int = int(upgrades.get("lane_guides", 0))
	var sweep_crew: int = int(upgrades.get("sweep_crew", 0))
	var sponsor_patch: int = int(upgrades.get("sponsor_patch", 0))
	var crowd_favor: int = int(upgrades.get("crowd_favor", 0))
	var turkey_bonus: int = int(upgrades.get("turkey_bonus", 0))
	var pin_science: int = int(upgrades.get("pin_science", 0))
	var kingpin_hunter: int = int(upgrades.get("kingpin_hunter", 0))
	var challenge_notes: int = int(upgrades.get("challenge_notes", 0))
	var gutter_whisper: int = int(upgrades.get("gutter_whisper", 0))
	var purse_bump: int = int(upgrades.get("purse_bump", 0))
	var house_lights: int = int(upgrades.get("house_lights", 0))
	var ball_return_ai: int = int(upgrades.get("ball_return_ai", 0))
	var champion_purse: int = int(upgrades.get("champion_purse", 0))

	var league_lane_cap: int = get_max_selectable_lane_tier(data)
	var lane_tier: int = league_lane_cap
	if gameplay_lane_tier >= 0:
		lane_tier = clampi(gameplay_lane_tier, 0, league_lane_cap)
	var lane_tier_data: Dictionary = get_lane_tier(lane_tier)
	var tier_relief: float = 1.0 - (float(challenge_notes) * 0.035)
	var tier_hook_relief: float = 1.0 + float(challenge_notes) * 0.04 + float(coverstock_resin) * 0.03
	var ball_weight_lb: float = DEFAULT_BALL_WEIGHT_LB + float(ball_weight) * 1.35 + float(impact_physics) * 0.35
	var base_aim_error: float = 0.23
	base_aim_error -= float(lane_reading) * 0.015
	base_aim_error -= float(release_timing) * 0.013
	base_aim_error -= float(spare_focus) * 0.006
	base_aim_error -= float(house_lights) * 0.004
	var aim_error_m: float = max(0.026, base_aim_error * float(lane_tier_data.get("aim_error_mult", 1.0)) * max(0.72, tier_relief))
	var target_range_mult: float = 1.0 + float(target_range) * 0.05
	var reward_multiplier: float = 1.0
	reward_multiplier += float(sponsor_patch) * 0.12
	reward_multiplier += float(crowd_favor) * 0.08
	reward_multiplier += float(purse_bump) * 0.06
	reward_multiplier += float(champion_purse) * 0.1
	reward_multiplier *= float(lane_tier_data.get("reward_mult", 1.0))
	reward_multiplier *= 1.0 + float(purse_bump + champion_purse) * 0.025 * float(lane_tier)

	var gold_pin_count: int = clampi(int(lane_tier_data.get("gold_pin_count", 0)), 0, int(lane_tier_data.get("pin_count", 10)))
	return {
		"ball_weight_lb": ball_weight_lb,
		"ball_mass_kg": ball_weight_lb * KG_PER_LB,
		"power_bonus": float(power_training) * 0.58,
		"spin_multiplier": 1.0 + float(hook_control) * 0.12 + float(rev_training) * 0.08,
		"hook_force_scale": max(0.72, float(lane_tier_data.get("hook_damp", 1.0)) * tier_hook_relief) * (1.0 + float(hook_control) * 0.11 + float(rev_training) * 0.1),
		"aim_error_m": aim_error_m,
		"reward_multiplier": reward_multiplier,
		"power_meter_speed_mult": max(0.56, 1.0 - float(approach_rhythm) * 0.045),
		"target_range_mult": target_range_mult,
		"target_assist_force": float(core_balance) * 2.8 + float(pocket_magnet) * 4.1 + float(ball_return_ai) * 5.3,
		"gutter_return_force": float(lane_guides) * 1.45 + float(gutter_whisper) * 2.1,
		"settle_speed_mult": 1.0 + float(sweep_crew) * 0.18,
		"pin_break_force_mult": 1.0 + float(impact_physics) * 0.08 + float(kingpin_hunter) * 0.05,
		"pin_score_bonus": float(pin_science) * 0.1 + float(crowd_favor) * 0.04,
		"strike_reward_bonus": float(turkey_bonus) * 0.14 + float(kingpin_hunter) * 0.09,
		"spare_reward_bonus": float(spare_focus) * 0.12,
		"tier_reward_bonus": float(purse_bump) * 0.08 + float(champion_purse) * 0.12,
		"lane_tier": lane_tier,
		"max_selectable_lane_tier": league_lane_cap,
		"lane_tier_label": TranslationServer.translate(str(lane_tier_data.get("label", "Practice House"))),
		"tier_pin_count": int(lane_tier_data.get("pin_count", 10)),
		"tier_gold_pin_count": gold_pin_count,
		"tier_gold_mass_scale": float(lane_tier_data.get("gold_mass_scale", 1.0)),
		"tier_gold_pin_value": float(lane_tier_data.get("gold_pin_value", 0)),
		"tier_pin_mass_mult": float(lane_tier_data.get("pin_mass_mult", 1.0)) / max(0.75, 1.0 + float(impact_physics) * 0.035),
		"tier_pin_standing_dot": max(0.76, float(lane_tier_data.get("pin_standing_dot", 0.84)) - float(impact_physics) * 0.006 - float(kingpin_hunter) * 0.004),
		"tier_pin_spacing_mult": float(lane_tier_data.get("pin_spacing_mult", 1.0)),
		"tier_head_pin_z_offset": float(lane_tier_data.get("head_pin_z_offset", 0.0)),
		"tier_settle_mult": float(lane_tier_data.get("settle_speed_mult", 1.0)),
		"tier_gutter_penalty_mult": float(lane_tier_data.get("gutter_penalty_mult", 1.0)),
	}

static func calculate_meta_reward(results: Dictionary, data: Dictionary) -> int:
	var score: int = max(0, int(results.get("score", 0)))
	var strikes: int = max(0, int(results.get("strikes", 0)))
	var spares: int = max(0, int(results.get("spares", 0)))
	var pinfall_total: int = max(score, int(results.get("pinfall_total", score)))
	var league_lane_cap: int = get_max_selectable_lane_tier(data)
	var lane_tier: int = clampi(int(results.get("lane_tier", 0)), 0, league_lane_cap)
	var gold_pins_knocked: int = max(0, int(results.get("gold_pins_knocked", 0)))
	var turkey_cash: int = 70 if bool(results.get("turkey_bonus", false)) else 0
	var base_reward: float = 28.0
	base_reward += float(score) * 2.4
	base_reward += float(pinfall_total) * 0.9
	base_reward += float(strikes) * 22.0
	base_reward += float(spares) * 15.0
	base_reward += float(lane_tier) * 35.0
	base_reward += turkey_cash

	var meta_stats: Dictionary = build_meta_stats(data, lane_tier)
	var strike_reward_bonus: float = float(meta_stats.get("strike_reward_bonus", 0.0))
	var spare_reward_bonus: float = float(meta_stats.get("spare_reward_bonus", 0.0))
	var tier_reward_bonus: float = float(meta_stats.get("tier_reward_bonus", 0.0))
	var pin_score_bonus: float = float(meta_stats.get("pin_score_bonus", 0.0))
	base_reward += float(strikes) * 10.0 * strike_reward_bonus
	base_reward += float(spares) * 8.0 * spare_reward_bonus
	base_reward += float(pinfall_total) * pin_score_bonus
	base_reward += float(gold_pins_knocked) * float(meta_stats.get("tier_gold_pin_value", 0.0))
	base_reward *= 1.0 + tier_reward_bonus * float(lane_tier)
	base_reward *= float(meta_stats.get("reward_multiplier", 1.0))
	return max(18, int(round(base_reward)))

## Bar chart rows for the series summary: each `money` is a share of the final payout (sums to the wallet gain).
static func get_summary_wallet_chart_rows(results: Dictionary, data: Dictionary) -> Array:
	var score: int = max(0, int(results.get("score", 0)))
	var strikes: int = max(0, int(results.get("strikes", 0)))
	var spares: int = max(0, int(results.get("spares", 0)))
	var pinfall_total: int = max(score, int(results.get("pinfall_total", score)))
	var gold_pins_knocked: int = max(0, int(results.get("gold_pins_knocked", 0)))
	var league_lane_cap: int = get_max_selectable_lane_tier(data)
	var lane_tier: int = clampi(int(results.get("lane_tier", 0)), 0, league_lane_cap)
	var turkey_cash: int = 70 if bool(results.get("turkey_bonus", false)) else 0
	var meta_stats: Dictionary = build_meta_stats(data, lane_tier)
	var strike_reward_bonus: float = float(meta_stats.get("strike_reward_bonus", 0.0))
	var spare_reward_bonus: float = float(meta_stats.get("spare_reward_bonus", 0.0))
	var gold_val: float = float(meta_stats.get("tier_gold_pin_value", 0.0))

	var pinfall_base: float = 28.0 + float(score) * 2.4 + float(pinfall_total) * 0.9
	var strike_c: float = float(strikes) * 22.0 + float(strikes) * 10.0 * strike_reward_bonus
	var spare_c: float = float(spares) * 15.0 + float(spares) * 8.0 * spare_reward_bonus
	var lane_c: float = float(lane_tier) * 35.0
	var gold_c: float = float(gold_pins_knocked) * gold_val
	var turkey_c: float = float(turkey_cash)

	var weights: Array[float] = [
		maxf(0.0, pinfall_base),
		maxf(0.0, strike_c),
		maxf(0.0, spare_c),
		maxf(0.0, lane_c),
		maxf(0.0, gold_c),
		maxf(0.0, turkey_c),
	]
	var labels: Array[String] = [
		"Base & pinfall",
		"Strikes",
		"Spares",
		"Lane tier",
		"Gold pins",
		"Turkey bonus",
	]
	var colors: Array[Color] = [
		Color(0.5, 0.82, 0.98, 1.0),
		Color(0.98, 0.72, 0.38, 1.0),
		Color(0.62, 0.9, 0.58, 1.0),
		Color(0.86, 0.65, 1.0, 1.0),
		Color(0.98, 0.92, 0.4, 1.0),
		Color(0.98, 0.42, 0.55, 1.0),
	]

	var final_reward: int = calculate_meta_reward(results, data)
	var total_weight: float = 0.0
	for w in weights:
		total_weight += w

	var rows: Array[Dictionary] = []
	if total_weight <= 0.0:
		rows.append({"label": TranslationServer.translate("Series payout"), "money": float(final_reward), "color": Color(0.37, 0.86, 0.61, 1.0)})
		return rows

	var n: int = weights.size()
	var portions: Array[int] = []
	portions.resize(n)
	var acc := 0
	for i in range(n - 1):
		var p: int = 0
		if weights[i] > 0.0:
			p = int(round(float(final_reward) * weights[i] / total_weight))
		p = maxi(0, p)
		portions[i] = p
		acc += p
	portions[n - 1] = maxi(0, final_reward - acc)
	for i in range(n):
		if portions[i] > 0:
			rows.append({"label": TranslationServer.translate(labels[i]), "money": float(portions[i]), "color": colors[i]})
	if rows.is_empty():
		rows.append({"label": TranslationServer.translate("Series payout"), "money": float(final_reward), "color": Color(0.37, 0.86, 0.61, 1.0)})
	return rows

static func _build_tier_costs(base_cost: int, max_tier: int, cost_mult: float) -> Array[int]:
	var costs: Array[int] = []
	var running_cost: float = float(base_cost)
	for tier in range(max_tier):
		if tier == 0:
			costs.append(base_cost)
		else:
			running_cost *= cost_mult + float(tier) * 0.018
			costs.append(int(round(running_cost)))
	return costs

static func _get_lane_tier_from_league_level(level: int) -> int:
	var tier := 0
	for index in range(LANE_TIER_UNLOCK_LEVELS.size()):
		if level >= int(LANE_TIER_UNLOCK_LEVELS[index]):
			tier = index
	return min(tier, LANE_TIERS.size() - 1)
