extends RefCounted
class_name TurkeyData

const CROSS_GAME_BONUSES := preload("res://CrossGameBonuses.gd")
const DEFAULT_BALL_WEIGHT_LB := 8.0
const KG_PER_LB := 0.45359237
const DEMO_LOCKED_LAYER_TAG := "demo_locked_layer"
## League Pass upgrade level required to reach each lane tier index (0..4).
const LANE_TIER_UNLOCK_LEVELS := [0, 2, 4, 6, 8]
## Completed Turkey series (runs) — parallel unlock so higher tiers are reachable without maxing League Pass.
const VETERAN_RUN_MILESTONES := [0, 2, 7, 18, 40]

## Gold pin mass vs a normal pin of the same tier (before `gold_mass_scale`).
const GOLD_PIN_MASS_MULT := 2.0
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
		"id": "power_shot",
		"label": "Power Shot",
		"summary": "Unlock a frame-limited pickup: +25% launch speed and triple ball mass for much harder pin hits.",
		"icon": ">",
		"max_tier": 1,
		"base_cost": 36,
		"cost_mult": 1.0,
		"cell": Vector2(-3, -5),
		"dependency": "power_training",
		"act": 1,
		"branch": 0,
		"step": 1,
	},
	{
		"id": "multi_shot",
		"label": "Multi Shot",
		"summary": "Unlock a frame-limited pickup: main ball is normal; four extras follow at +/-3 deg then +/-6 deg from your line.",
		"icon": "4",
		"max_tier": 1,
		"base_cost": 36,
		"cost_mult": 1.0,
		"cell": Vector2(3, -5),
		"dependency": "power_training",
		"act": 1,
		"branch": 9,
		"step": 1,
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
		"id": "approach_rhythm",
		"label": "Approach Rhythm",
		"summary": "Slow the power meter so high-power releases are easier to hit consistently.",
		"icon": "M",
		"max_tier": 6,
		"base_cost": 42,
		"cost_mult": 1.45,
		"cell": Vector2(-2, -3),
		"dependency": "power_training",
		"act": 2,
		"branch": 1,
		"step": 4,
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
		"dependency": "approach_rhythm",
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
		"dependency": "impact_physics",
		"act": 5,
		"branch": 7,
		"step": 1,
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
	{
		"id": "afterburn",
		"label": "Afterburn",
		"summary": "Power Shot finishes with extra drive so the boosted ball keeps punching through the deck.",
		"icon": "!",
		"max_tier": 5,
		"base_cost": 290,
		"cost_mult": 1.64,
		"cell": Vector2(-5, -6),
		"dependency": "power_shot",
		"act": 6,
		"branch": 0,
		"step": 6,
		"demo_locked_layer": true,
	},
	{
		"id": "release_window",
		"label": "Release Window",
		"summary": "Give the approach a calmer finish with tighter timing and cleaner launch consistency.",
		"icon": "R",
		"max_tier": 5,
		"base_cost": 232,
		"cost_mult": 1.6,
		"cell": Vector2(-2, -2),
		"dependency": "approach_rhythm",
		"act": 5,
		"branch": 1,
		"step": 6,
		"demo_locked_layer": true,
	},
	{
		"id": "deck_cracker",
		"label": "Deck Cracker",
		"summary": "Turn impact upgrades into nastier chain reactions across the full rack.",
		"icon": "D",
		"max_tier": 5,
		"base_cost": 248,
		"cost_mult": 1.61,
		"cell": Vector2(5, -2),
		"dependency": "impact_physics",
		"act": 5,
		"branch": 3,
		"step": 6,
		"demo_locked_layer": true,
	},
	{
		"id": "lane_crew",
		"label": "Lane Crew",
		"summary": "Quick cleanup crews keep frames moving and nudge guttered balls back toward the lane edge.",
		"icon": "L",
		"max_tier": 5,
		"base_cost": 276,
		"cost_mult": 1.62,
		"cell": Vector2(7, 1),
		"dependency": "sweep_crew",
		"act": 6,
		"branch": 4,
		"step": 6,
		"demo_locked_layer": true,
	},
	{
		"id": "headline_act",
		"label": "Headline Act",
		"summary": "The crowd really shows up now: strike, spare, and series payouts all climb harder.",
		"icon": "H",
		"max_tier": 5,
		"base_cost": 254,
		"cost_mult": 1.61,
		"cell": Vector2(-1, 3),
		"dependency": "turkey_bonus",
		"act": 5,
		"branch": 5,
		"step": 6,
		"demo_locked_layer": true,
	},
	{
		"id": "rack_geometry",
		"label": "Rack Geometry",
		"summary": "Fine-tune how promoted racks break so pinfall, clears, and gold conversions pay off more often.",
		"icon": "G",
		"max_tier": 5,
		"base_cost": 268,
		"cost_mult": 1.62,
		"cell": Vector2(7, 3),
		"dependency": "kingpin_hunter",
		"act": 5,
		"branch": 6,
		"step": 6,
		"demo_locked_layer": true,
	},
	{
		"id": "tour_badges",
		"label": "Tour Badges",
		"summary": "League reps smooth out hard-lane entries with better line guidance and stronger promoted-tier payouts.",
		"icon": "B",
		"max_tier": 5,
		"base_cost": 320,
		"cost_mult": 1.64,
		"cell": Vector2(0, 5),
		"dependency": "league_pass",
		"act": 6,
		"branch": 7,
		"step": 6,
		"demo_locked_layer": true,
	},
	{
		"id": "broadcast_deal",
		"label": "Broadcast Deal",
		"summary": "Big-stage coverage adds another payout layer on top of your high-tier purse scaling.",
		"icon": "@",
		"max_tier": 5,
		"base_cost": 360,
		"cost_mult": 1.66,
		"cell": Vector2(5, 6),
		"dependency": "champion_purse",
		"act": 6,
		"branch": 8,
		"step": 6,
		"demo_locked_layer": true,
	},
	{
		"id": "split_doctor",
		"label": "Split Doctor",
		"summary": "Tighten multi-ball control so angled follow-up shots rescue more ugly frames.",
		"icon": "S",
		"max_tier": 5,
		"base_cost": 290,
		"cost_mult": 1.64,
		"cell": Vector2(5, -6),
		"dependency": "multi_shot",
		"act": 6,
		"branch": 9,
		"step": 6,
		"demo_locked_layer": true,
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

static func should_lock_meta_upgrade_in_demo(entry: Dictionary) -> bool:
	if not bool(ProjectSettings.get_setting("global/Demo", false)):
		return false
	return bool(entry.get(DEMO_LOCKED_LAYER_TAG, false))

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
	var power_shot: int = int(upgrades.get("power_shot", 0))
	var multi_shot: int = int(upgrades.get("multi_shot", 0))
	var power_training: int = int(upgrades.get("power_training", 0))
	var ball_weight: int = int(upgrades.get("ball_weight", 0))
	var approach_rhythm: int = int(upgrades.get("approach_rhythm", 0))
	var impact_physics: int = int(upgrades.get("impact_physics", 0))
	var sweep_crew: int = int(upgrades.get("sweep_crew", 0))
	var sponsor_patch: int = int(upgrades.get("sponsor_patch", 0))
	var crowd_favor: int = int(upgrades.get("crowd_favor", 0))
	var turkey_bonus: int = int(upgrades.get("turkey_bonus", 0))
	var pin_science: int = int(upgrades.get("pin_science", 0))
	var kingpin_hunter: int = int(upgrades.get("kingpin_hunter", 0))
	var purse_bump: int = int(upgrades.get("purse_bump", 0))
	var champion_purse: int = int(upgrades.get("champion_purse", 0))
	var afterburn: int = int(upgrades.get("afterburn", 0))
	var release_window: int = int(upgrades.get("release_window", 0))
	var deck_cracker: int = int(upgrades.get("deck_cracker", 0))
	var lane_crew: int = int(upgrades.get("lane_crew", 0))
	var headline_act: int = int(upgrades.get("headline_act", 0))
	var rack_geometry: int = int(upgrades.get("rack_geometry", 0))
	var tour_badges: int = int(upgrades.get("tour_badges", 0))
	var broadcast_deal: int = int(upgrades.get("broadcast_deal", 0))
	var split_doctor: int = int(upgrades.get("split_doctor", 0))

	var league_lane_cap: int = get_max_selectable_lane_tier(data)
	var lane_tier: int = league_lane_cap
	if gameplay_lane_tier >= 0:
		lane_tier = clampi(gameplay_lane_tier, 0, league_lane_cap)
	var lane_tier_data: Dictionary = get_lane_tier(lane_tier)
	var ball_weight_lb: float = DEFAULT_BALL_WEIGHT_LB + float(ball_weight) * 1.35 + float(impact_physics) * 0.35 + float(deck_cracker) * 0.4
	var base_aim_error: float = 0.23
	var aim_error_m: float = max(0.02, base_aim_error * float(lane_tier_data.get("aim_error_mult", 1.0)) * (1.0 - float(release_window + split_doctor) * 0.045))
	var reward_multiplier: float = 1.0
	reward_multiplier += float(sponsor_patch) * 0.12
	reward_multiplier += float(crowd_favor) * 0.08
	reward_multiplier += float(purse_bump) * 0.06
	reward_multiplier += float(champion_purse) * 0.1
	reward_multiplier += float(headline_act) * 0.08
	reward_multiplier += float(broadcast_deal) * 0.1
	reward_multiplier *= float(lane_tier_data.get("reward_mult", 1.0))
	reward_multiplier *= 1.0 + (float(purse_bump + champion_purse) * 0.025 + float(tour_badges + broadcast_deal) * 0.02) * float(lane_tier)
	var cross_mult: float = CROSS_GAME_BONUSES.get_target_bonus_multiplier(Util.ACTIVE_GAME_TURKEY)
	ball_weight_lb *= cross_mult
	reward_multiplier *= cross_mult

	var gold_pin_count: int = clampi(int(lane_tier_data.get("gold_pin_count", 0)), 0, int(lane_tier_data.get("pin_count", 10)))
	return {
		"shot_power_shot_unlocked": power_shot > 0,
		"shot_multi_shot_unlocked": multi_shot > 0,
		"ball_weight_lb": ball_weight_lb,
		"ball_mass_kg": ball_weight_lb * KG_PER_LB,
		"power_bonus": float(power_training) * 0.58 + float(afterburn) * 0.4,
		"spin_multiplier": 1.0 + float(split_doctor) * 0.035,
		"hook_force_scale": max(0.72, float(lane_tier_data.get("hook_damp", 1.0))) * (1.0 + float(split_doctor) * 0.03),
		"aim_error_m": aim_error_m,
		"reward_multiplier": reward_multiplier,
		"power_meter_speed_mult": max(0.42, 1.0 - float(approach_rhythm) * 0.045 - float(release_window) * 0.03),
		"target_range_mult": 1.0,
		"target_assist_force": float(tour_badges) * 22.0 + float(split_doctor) * 18.0,
		"gutter_return_force": float(lane_crew) * 4.0,
		"settle_speed_mult": 1.0 + float(sweep_crew) * 0.18 + float(lane_crew) * 0.15,
		"pin_break_force_mult": 1.0 + float(impact_physics) * 0.08 + float(kingpin_hunter) * 0.05 + float(deck_cracker + afterburn) * 0.04,
		"pin_score_bonus": float(pin_science) * 0.1 + float(crowd_favor) * 0.04 + float(rack_geometry) * 0.08,
		"strike_reward_bonus": float(turkey_bonus) * 0.14 + float(kingpin_hunter) * 0.09 + float(headline_act) * 0.08,
		"spare_reward_bonus": float(headline_act) * 0.08 + float(split_doctor) * 0.06,
		"tier_reward_bonus": float(purse_bump) * 0.08 + float(champion_purse) * 0.12 + float(tour_badges) * 0.08 + float(broadcast_deal) * 0.1,
		"lane_tier": lane_tier,
		"max_selectable_lane_tier": league_lane_cap,
		"lane_tier_label": TranslationServer.translate(str(lane_tier_data.get("label", "Practice House"))),
		"tier_pin_count": int(lane_tier_data.get("pin_count", 10)),
		"tier_gold_pin_count": gold_pin_count,
		"tier_gold_mass_scale": float(lane_tier_data.get("gold_mass_scale", 1.0)),
		"tier_gold_pin_value": float(lane_tier_data.get("gold_pin_value", 0)) + float(rack_geometry) * 6.0,
		"tier_pin_mass_mult": float(lane_tier_data.get("pin_mass_mult", 1.0)) / max(0.75, 1.0 + float(impact_physics) * 0.035),
		"tier_pin_standing_dot": max(0.72, float(lane_tier_data.get("pin_standing_dot", 0.84)) - float(impact_physics) * 0.006 - float(kingpin_hunter) * 0.004 - float(rack_geometry) * 0.004),
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
