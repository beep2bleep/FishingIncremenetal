extends RefCounted
class_name TurkeyData

const DEFAULT_BALL_WEIGHT_LB := 8.0
const KG_PER_LB := 0.45359237

const UPGRADE_CATALOG: Array[Dictionary] = [
	{
		"id": "power_training",
		"label": "Power Training",
		"summary": "Add a little more launch speed to every roll.",
		"icon": "P",
		"max_tier": 5,
		"base_cost": 20,
		"tier_costs": [20, 45, 80, 130, 200],
		"cell": Vector2(0, -2),
		"dependency": "",
		"act": 1,
		"branch": 1,
		"step": 1,
	},
	{
		"id": "ball_weight",
		"label": "Heavier Ball",
		"summary": "Increase ball mass so weak hits carry a little farther.",
		"icon": "W",
		"max_tier": 5,
		"base_cost": 30,
		"tier_costs": [30, 70, 120, 190, 280],
		"cell": Vector2(-2, -1),
		"dependency": "power_training",
		"act": 1,
		"branch": 1,
		"step": 2,
	},
	{
		"id": "hook_control",
		"label": "Hook Control",
		"summary": "Make the left and right spin buttons bend the lane a bit harder.",
		"icon": "S",
		"max_tier": 5,
		"base_cost": 30,
		"tier_costs": [30, 65, 110, 170, 245],
		"cell": Vector2(2, -1),
		"dependency": "power_training",
		"act": 2,
		"branch": 2,
		"step": 2,
	},
	{
		"id": "lane_reading",
		"label": "Lane Reading",
		"summary": "Shrink release error so your shots go closer to the line you picked.",
		"icon": "L",
		"max_tier": 5,
		"base_cost": 45,
		"tier_costs": [45, 95, 160, 245, 360],
		"cell": Vector2(0, 1),
		"dependency": "power_training",
		"act": 3,
		"branch": 3,
		"step": 1,
	},
	{
		"id": "release_timing",
		"label": "Release Timing",
		"summary": "Reduce wobble during the shot so power and target match more often.",
		"icon": "R",
		"max_tier": 5,
		"base_cost": 55,
		"tier_costs": [55, 115, 190, 295, 430],
		"cell": Vector2(-2, 2),
		"dependency": "lane_reading",
		"act": 3,
		"branch": 3,
		"step": 2,
	},
	{
		"id": "sponsor_patch",
		"label": "Sponsor Patch",
		"summary": "Boost payout from every three-frame series.",
		"icon": "$",
		"max_tier": 5,
		"base_cost": 40,
		"tier_costs": [40, 80, 135, 210, 310],
		"cell": Vector2(2, 2),
		"dependency": "lane_reading",
		"act": 4,
		"branch": 4,
		"step": 2,
	},
]

static func get_meta_upgrade_catalog() -> Array[Dictionary]:
	return UPGRADE_CATALOG.duplicate(true)

static func build_meta_stats(data: Dictionary) -> Dictionary:
	var upgrades: Dictionary = data.get("meta_upgrades", {})
	var power_training: int = int(upgrades.get("power_training", 0))
	var ball_weight: int = int(upgrades.get("ball_weight", 0))
	var hook_control: int = int(upgrades.get("hook_control", 0))
	var lane_reading: int = int(upgrades.get("lane_reading", 0))
	var release_timing: int = int(upgrades.get("release_timing", 0))
	var sponsor_patch: int = int(upgrades.get("sponsor_patch", 0))

	var ball_weight_lb: float = DEFAULT_BALL_WEIGHT_LB + float(ball_weight) * 1.5
	var aim_error_m: float = max(0.04, 0.20 - float(lane_reading) * 0.024 - float(release_timing) * 0.018)

	return {
		"ball_weight_lb": ball_weight_lb,
		"ball_mass_kg": ball_weight_lb * KG_PER_LB,
		"power_bonus": float(power_training) * 0.55,
		"spin_multiplier": 1.0 + float(hook_control) * 0.18,
		"hook_force_scale": 1.0 + float(hook_control) * 0.22,
		"aim_error_m": aim_error_m,
		"reward_multiplier": 1.0 + float(sponsor_patch) * 0.12,
	}

static func calculate_meta_reward(results: Dictionary, data: Dictionary) -> int:
	var score: int = max(0, int(results.get("score", 0)))
	var strikes: int = max(0, int(results.get("strikes", 0)))
	var spares: int = max(0, int(results.get("spares", 0)))
	var turkey_bonus: int = 40 if bool(results.get("turkey_bonus", false)) else 0
	var base_reward: int = score + strikes * 12 + spares * 7 + turkey_bonus
	var reward_multiplier: float = float(build_meta_stats(data).get("reward_multiplier", 1.0))
	return max(10, int(round(float(base_reward) * reward_multiplier)))
