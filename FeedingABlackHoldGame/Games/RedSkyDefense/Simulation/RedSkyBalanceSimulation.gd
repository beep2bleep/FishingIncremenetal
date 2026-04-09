extends SceneTree

const RED_SKY_DATA = preload("res://Games/RedSkyDefense/RedSkyData.gd")

const CAMPAIGN_SEEDS := [11, 23, 47, 89, 131, 233]

func _init() -> void:
	var pass_name: String = "pass"
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		pass_name = args[0]
	var report: Dictionary = _run_report(pass_name)
	print("BEGIN_REDSKY_REPORT")
	print(JSON.stringify(report, "\t"))
	print("END_REDSKY_REPORT")
	quit()

func _run_report(pass_name: String) -> Dictionary:
	var campaigns: Array[Dictionary] = []
	for seed in CAMPAIGN_SEEDS:
		campaigns.append(_simulate_campaign(seed))

	var demo_minutes := _average_key(campaigns, "minutes_to_demo_nodes")
	var full_minutes := _average_key(campaigns, "minutes_to_full_nodes")
	var tier_minutes := _average_key(campaigns, "minutes_to_full_tiers")
	var avg_run_minutes := _average_nested_key(campaigns, "average_run_minutes")
	var avg_run_waves := _average_nested_key(campaigns, "average_waves")
	var avg_run_score := _average_nested_key(campaigns, "average_score")
	var avg_run_reward := _average_nested_key(campaigns, "average_wallet_gain")
	var catalog: Array = RED_SKY_DATA.get_meta_upgrade_catalog()
	var full_node_target := catalog.size()
	var full_tier_target := full_node_target * 3

	var assessment := "baseline"
	if demo_minutes < 34.0:
		assessment = "demo progression too fast"
	elif demo_minutes > 48.0:
		assessment = "demo progression too slow"
	elif tier_minutes < 105.0:
		assessment = "full progression too fast"
	elif tier_minutes > 135.0:
		assessment = "full progression too slow"
	else:
		assessment = "near target"

	return {
		"pass": pass_name,
		"meta_cost_multiplier": RED_SKY_DATA.META_COST_MULTIPLIER,
		"meta_node_count": RED_SKY_DATA.get_meta_upgrade_catalog().size(),
		"wave_upgrade_count": RED_SKY_DATA.get_wave_upgrade_catalog().size(),
		"demo_target_minutes": 40,
		"full_target_minutes": 120,
		"demo_node_target": RED_SKY_DATA.count_eligible_meta_nodes_in_demo_slice(),
		"full_node_target": full_node_target,
		"full_tier_target": full_tier_target,
		"avg_minutes_to_demo_nodes": snappedf(demo_minutes, 0.1),
		"avg_minutes_to_full_nodes": snappedf(full_minutes, 0.1),
		"avg_minutes_to_full_tiers": snappedf(tier_minutes, 0.1),
		"avg_run_minutes": snappedf(avg_run_minutes, 0.1),
		"avg_run_waves": snappedf(avg_run_waves, 0.1),
		"avg_run_score": snappedf(avg_run_score, 1.0),
		"avg_run_wallet_gain": snappedf(avg_run_reward, 1.0),
		"assessment": assessment,
		"campaigns": campaigns,
	}

func _simulate_campaign(seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var catalog: Array = RED_SKY_DATA.get_meta_upgrade_catalog()
	var full_node_target := catalog.size()
	var full_tier_target := full_node_target * 3
	var meta_levels: Dictionary = {}
	var wallet := 0
	var total_minutes := 0.0
	var minutes_to_demo := -1.0
	var minutes_to_full_nodes := -1.0
	var minutes_to_full_tiers := -1.0
	var runs: Array[Dictionary] = []

	for run_index in range(24):
		var run_result: Dictionary = _simulate_run(meta_levels, rng.randi())
		runs.append(run_result)
		wallet += int(run_result.get("wallet_gain", 0))
		total_minutes += float(run_result.get("minutes", 0.0))
		wallet = _purchase_meta_upgrades(meta_levels, wallet)

		var unique_nodes: int = _count_unique_nodes(meta_levels)
		var total_tiers: int = _count_total_tiers(meta_levels)
		if minutes_to_demo < 0.0 and unique_nodes >= RED_SKY_DATA.count_eligible_meta_nodes_in_demo_slice():
			minutes_to_demo = total_minutes
		if minutes_to_full_nodes < 0.0 and unique_nodes >= full_node_target:
			minutes_to_full_nodes = total_minutes
		if minutes_to_full_tiers < 0.0 and total_tiers >= full_tier_target:
			minutes_to_full_tiers = total_minutes
		if unique_nodes >= full_node_target and total_tiers >= full_tier_target:
			break

	return {
		"seed": seed,
		"minutes_to_demo_nodes": snappedf(minutes_to_demo, 0.1),
		"minutes_to_full_nodes": snappedf(minutes_to_full_nodes, 0.1),
		"minutes_to_full_tiers": snappedf(minutes_to_full_tiers, 0.1),
		"average_run_minutes": _average_key(runs, "minutes"),
		"average_waves": _average_key(runs, "waves_cleared"),
		"average_score": _average_key(runs, "score"),
		"average_wallet_gain": _average_key(runs, "wallet_gain"),
		"ending_wallet": wallet,
		"ending_nodes": _count_unique_nodes(meta_levels),
		"ending_tiers": _count_total_tiers(meta_levels),
		"ending_meta_levels": meta_levels.duplicate(true),
	}

func _simulate_run(meta_levels: Dictionary, seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var state: Dictionary = _build_run_state(meta_levels)
	var waves_cleared := 0
	var minutes := 0.0
	var score := 0.0

	for wave in range(1, 80):
		var wave_result: Dictionary = _resolve_wave(state, wave, rng)
		minutes += float(wave_result.get("minutes", 0.0))
		if not bool(wave_result.get("cleared", false)):
			break
		waves_cleared = wave
		score += float(wave_result.get("score", 0.0))
		var cap: int = int(state.get("nuke_max", 5))
		var regen: int = maxi(int(state.get("nuke_regen_per_wave", 1)), 1)
		state["remaining_nukes"] = mini(int(state.get("remaining_nukes", 0)) + regen, cap)
		state["hull"] = min(float(state.get("base_max_health", 0.0)), float(state.get("hull", 0.0)) + float(state.get("repair_between_waves", 0.0)))
		state["shield"] = min(float(state.get("shield_max", 0.0)), float(state.get("shield", 0.0)) + float(state.get("shield_regen", 0.0)) * 2.2)
		var offers: Array[String] = _roll_wave_offers(state, wave, rng)
		if not offers.is_empty():
			var chosen_offer: String = _choose_best_wave_offer(state, offers, wave)
			_apply_wave_upgrade_to_state(state, chosen_offer)
	var wallet_gain := RED_SKY_DATA.calculate_meta_scrap_reward({
		"score": int(round(score)),
		"waves_cleared": waves_cleared
	}, {
		"meta_reward_multiplier": float(state.get("meta_reward_multiplier", 1.0))
	})
	return {
		"waves_cleared": waves_cleared,
		"minutes": minutes,
		"score": int(round(score)),
		"wallet_gain": wallet_gain,
	}

func _resolve_wave(state: Dictionary, wave: int, rng: RandomNumberGenerator) -> Dictionary:
	var offense: float = _calc_offense(state)
	var defense: float = _calc_defense(state)
	var economy: float = _calc_economy(state)
	var threat: float = 48.0 + 11.0 * float(wave) + pow(float(wave), 1.34) * 7.2
	var efficiency: float = clampf(offense / max(threat * 0.82, 1.0), 0.6, 1.24)
	var nuke_burst := 0.0
	if int(state.get("remaining_nukes", 0)) > 0 and offense < threat * 1.02:
		state["remaining_nukes"] = int(state.get("remaining_nukes", 0)) - 1
		nuke_burst = float(state.get("nuke_damage", 0.0)) * (float(state.get("nuke_radius", 0.0)) / 250.0) * 0.32
		efficiency = clampf((offense + nuke_burst) / max(threat * 0.82, 1.0), 0.7, 1.28)

	var incoming_damage: float = max(0.0, threat * 0.18 - defense * 0.095 - offense * 0.03)
	var shield: float = float(state.get("shield", 0.0))
	if shield > 0.0:
		var absorbed: float = min(shield, incoming_damage)
		state["shield"] = shield - absorbed
		incoming_damage -= absorbed
	var hull_loss: float = incoming_damage * (1.0 - float(state.get("damage_reduction", 0.0)))
	state["hull"] = float(state.get("hull", 0.0)) - hull_loss

	var score_gain: float = (18.0 + 6.5 * float(wave) + pow(float(wave), 1.22) * 4.8) * economy * efficiency
	score_gain += float(state.get("wave_scrap_bonus", 0.0)) * float(wave)
	var wave_time_seconds: float = 20.0 + float(wave) * 3.2 + pow(float(wave), 1.05) * 1.7
	wave_time_seconds -= max(0.0, float(wave - 8)) * 2.0
	var minutes: float = max(0.28, wave_time_seconds / 60.0)
	minutes *= rng.randf_range(0.94, 1.06)
	return {
		"cleared": float(state.get("hull", 0.0)) > 0.0 and (offense + nuke_burst) >= threat * 0.74,
		"score": score_gain,
		"minutes": minutes,
	}

func _roll_wave_offers(state: Dictionary, wave: int, rng: RandomNumberGenerator) -> Array[String]:
	var offers: Array[String] = []
	var candidates: Array[Dictionary] = []
	var runtime_flags := {"shield_max": state.get("shield_max", 0.0)}
	var choice_count: int = clampi(int(state.get("level_up_choice_count", 3)), 3, 6)
	for upgrade_def in RED_SKY_DATA.get_wave_upgrade_catalog():
		if RED_SKY_DATA.can_offer_wave_upgrade(upgrade_def, wave, state.get("wave_upgrades", {}), state.get("meta_bonuses", {}), runtime_flags):
			candidates.append(upgrade_def)
	while offers.size() < choice_count and offers.size() < candidates.size():
		var picked: String = _pick_weighted_offer(candidates, offers, state.get("wave_upgrades", {}), state.get("meta_bonuses", {}), rng)
		if picked.is_empty():
			break
		offers.append(picked)
	return offers

func _pick_weighted_offer(candidates: Array[Dictionary], chosen: Array[String], wave_upgrades: Dictionary, meta_bonuses: Dictionary, rng: RandomNumberGenerator) -> String:
	var total_weight := 0.0
	var weighted: Array[Dictionary] = []
	for entry in candidates:
		var upgrade_id: String = str(entry.get("id", ""))
		if chosen.has(upgrade_id):
			continue
		var weight: float = RED_SKY_DATA.get_offer_weight(entry, wave_upgrades, meta_bonuses)
		total_weight += weight
		weighted.append({"id": upgrade_id, "weight": weight})
	if total_weight <= 0.0:
		return ""
	var roll: float = rng.randf() * total_weight
	for entry in weighted:
		roll -= float(entry.get("weight", 0.0))
		if roll <= 0.0:
			return str(entry.get("id", ""))
	return str(weighted.back().get("id", ""))

func _choose_best_wave_offer(state: Dictionary, offers: Array[String], wave: int) -> String:
	var best_offer := offers[0]
	var best_score := -INF
	var baseline: float = _score_run_state(state, wave + 1)
	for offer in offers:
		var trial: Dictionary = state.duplicate(true)
		trial["wave_upgrades"] = state.get("wave_upgrades", {}).duplicate(true)
		_apply_wave_upgrade_to_state(trial, offer)
		var offer_score: float = _score_run_state(trial, wave + 1) - baseline
		if offer_score > best_score:
			best_score = offer_score
			best_offer = offer
	return best_offer

func _apply_wave_upgrade_to_state(state: Dictionary, upgrade_id: String) -> void:
	var wave_upgrades: Dictionary = state.get("wave_upgrades", {}).duplicate(true)
	wave_upgrades[upgrade_id] = int(wave_upgrades.get(upgrade_id, 0)) + 1
	state["wave_upgrades"] = wave_upgrades
	var effects: Dictionary = RED_SKY_DATA.get_scaled_wave_effects(upgrade_id, float(state.get("upgrade_power_multiplier", 1.0)))
	_apply_effect_bundle_to_state(state, effects)

func _apply_effect_bundle_to_state(state: Dictionary, bundle: Dictionary) -> void:
	for key_variant in bundle.get("add", {}).keys():
		var key: String = str(key_variant)
		var value: float = float(bundle.get("add", {})[key_variant])
		match key:
			"base_max_health":
				state["base_max_health"] = float(state.get("base_max_health", 0.0)) + value
				state["hull"] = float(state.get("hull", 0.0)) + value
			"repair":
				state["hull"] = min(float(state.get("base_max_health", 0.0)), float(state.get("hull", 0.0)) + value)
			"shield_max":
				state["shield_max"] = float(state.get("shield_max", 0.0)) + value
				state["shield"] = float(state.get("shield", 0.0)) + value
			"shield_fill":
				state["shield"] = min(float(state.get("shield_max", 0.0)), float(state.get("shield", 0.0)) + value)
			"nukes":
				state["remaining_nukes"] = int(state.get("remaining_nukes", 0)) + int(round(value))
				state["remaining_nukes"] = mini(int(state.get("remaining_nukes", 0)), int(state.get("nuke_max", 5)))
			"nuke_max":
				state["nuke_max"] = int(state.get("nuke_max", 5)) + int(round(value))
				state["remaining_nukes"] = mini(int(state.get("remaining_nukes", 0)), int(state.get("nuke_max", 5)))
			"nuke_regen_per_wave":
				state["nuke_regen_per_wave"] = maxi(int(state.get("nuke_regen_per_wave", 1)) + int(round(value)), 1)
			"bullet_pierce", "tower_count", "drone_count", "tentacle_count":
				state[key] = int(state.get(key, 0)) + int(round(value))
			_:
				state[key] = float(state.get(key, 0.0)) + value

	for key_variant in bundle.get("mult", {}).keys():
		var key: String = str(key_variant)
		var value: float = float(bundle.get("mult", {})[key_variant])
		match key:
			"fire_rate":
				state["fire_interval"] = float(state.get("fire_interval", 0.17)) / value
			"tower_fire_rate":
				state["tower_fire_interval"] = float(state.get("tower_fire_interval", 1.0)) / value
			"drone_fire_rate":
				state["drone_fire_interval"] = float(state.get("drone_fire_interval", 1.0)) / value
			_:
				state[key] = float(state.get(key, 1.0)) * value

	state["remaining_nukes"] = mini(int(state.get("remaining_nukes", 0)), int(state.get("nuke_max", 5)))

func _purchase_meta_upgrades(meta_levels: Dictionary, wallet: int) -> int:
	while true:
		var purchase: Dictionary = _pick_best_meta_purchase(meta_levels, wallet)
		if purchase.is_empty():
			return wallet
		var upgrade_id: String = str(purchase.get("id", ""))
		var cost: int = int(purchase.get("cost", 0))
		if upgrade_id.is_empty() or cost > wallet:
			return wallet
		wallet -= cost
		meta_levels[upgrade_id] = int(meta_levels.get(upgrade_id, 0)) + 1
	return wallet

func _pick_best_meta_purchase(meta_levels: Dictionary, wallet: int) -> Dictionary:
	var base_score: float = _score_run_state(_build_run_state(meta_levels), 6)
	var best_purchase: Dictionary = {}
	var best_value := -INF
	for entry in RED_SKY_DATA.get_meta_upgrade_catalog():
		var upgrade_id: String = str(entry.get("id", ""))
		var dependency: String = str(entry.get("dependency", ""))
		var current_level: int = int(meta_levels.get(upgrade_id, 0))
		if current_level >= int(entry.get("max_tier", 1)):
			continue
		if not dependency.is_empty() and int(meta_levels.get(dependency, 0)) <= 0:
			continue
		var tier_costs: Array = entry.get("tier_costs", [])
		var cost: int = int(tier_costs[current_level]) if current_level < tier_costs.size() else 999999
		if cost > wallet:
			continue
		var trial_levels: Dictionary = meta_levels.duplicate(true)
		trial_levels[upgrade_id] = current_level + 1
		var new_score: float = _score_run_state(_build_run_state(trial_levels), 6)
		var gain: float = new_score - base_score
		if current_level == 0:
			gain *= 1.48
		var value: float = gain / max(float(cost), 1.0)
		if value > best_value:
			best_value = value
			best_purchase = {"id": upgrade_id, "cost": cost}
	return best_purchase

func _build_run_state(meta_levels: Dictionary) -> Dictionary:
	var bonuses: Dictionary = RED_SKY_DATA.build_meta_bonuses(meta_levels)
	return {
		"meta_bonuses": bonuses,
		"wave_upgrades": {},
		"base_max_health": float(bonuses.get("base_health", 0.0)),
		"hull": float(bonuses.get("base_health", 0.0)),
		"shield_max": float(bonuses.get("base_shield", 0.0)),
		"shield": float(bonuses.get("base_shield", 0.0)),
		"shield_regen": float(bonuses.get("shield_regen", 0.0)),
		"damage_reduction": float(bonuses.get("damage_reduction", 0.0)),
		"repair_between_waves": float(bonuses.get("repair_between_waves", 0.0)),
		"gun_damage": float(bonuses.get("gun_damage", 0.0)),
		"fire_interval": float(bonuses.get("fire_interval", 0.17)),
		"crit_chance": float(bonuses.get("crit_chance", 0.0)),
		"crit_bonus": float(bonuses.get("crit_bonus", 1.65)),
		"bullet_pierce": int(bonuses.get("bullet_pierce", 0)),
		"bullet_blast_radius": float(bonuses.get("bullet_blast_radius", 0.0)),
		"bullet_blast_damage": float(bonuses.get("bullet_blast_damage", 1.0)),
		"nuke_damage": float(bonuses.get("nuke_damage", 0.0)),
		"nuke_radius": float(bonuses.get("nuke_radius", 0.0)),
		"nuke_max": int(bonuses.get("nuke_max", 5)),
		"nuke_regen_per_wave": maxi(int(bonuses.get("nuke_regen_per_wave", 1)), 1),
		"remaining_nukes": clampi(int(bonuses.get("starting_nukes", 1)), 0, int(bonuses.get("nuke_max", 5))),
		"tower_count": int(bonuses.get("tower_count", 0)),
		"tower_damage": float(bonuses.get("tower_damage", 0.0)),
		"tower_fire_interval": float(bonuses.get("tower_fire_interval", 1.0)),
		"tower_range": float(bonuses.get("tower_range", 0.0)),
		"drone_count": int(bonuses.get("drone_count", 0)),
		"drone_damage": float(bonuses.get("drone_damage", 0.0)),
		"drone_fire_interval": float(bonuses.get("drone_fire_interval", 1.0)),
		"drone_speed": float(bonuses.get("drone_speed", 0.0)),
		"tentacle_count": int(bonuses.get("tentacle_count", 0)),
		"tentacle_damage": float(bonuses.get("tentacle_damage", 0.0)),
		"tentacle_range": float(bonuses.get("tentacle_range", 0.0)),
		"tentacle_cooldown": float(bonuses.get("tentacle_cooldown", 1.05)),
		"tentacle_slow": float(bonuses.get("tentacle_slow", 0.0)),
		"projectile_redirect_chance": float(bonuses.get("projectile_redirect_chance", 0.0)),
		"pickup_radius": float(bonuses.get("pickup_radius", 0.0)),
		"salvage_multiplier": float(bonuses.get("salvage_multiplier", 1.0)),
		"salvage_lifetime": float(bonuses.get("salvage_lifetime", 7.4)),
		"meta_reward_multiplier": float(bonuses.get("meta_reward_multiplier", 1.0)),
		"wave_scrap_bonus": float(bonuses.get("wave_scrap_bonus", 0.0)),
		"wave_auto_bank_ratio": float(bonuses.get("wave_auto_bank_ratio", 0.68)),
		"level_up_choice_count": int(bonuses.get("level_up_choice_count", 3)),
		"upgrade_power_multiplier": float(bonuses.get("upgrade_power_multiplier", 1.0)),
	}

func _score_run_state(state: Dictionary, wave: int) -> float:
	return _calc_offense(state) * 1.15 + _calc_defense(state) * 0.95 + _calc_economy(state) * 42.0 - float(wave) * 8.5

func _calc_offense(state: Dictionary) -> float:
	var gun_dps: float = float(state.get("gun_damage", 0.0)) * (1.0 + float(state.get("crit_chance", 0.0)) * (float(state.get("crit_bonus", 1.0)) - 1.0)) / max(float(state.get("fire_interval", 0.17)), 0.04)
	gun_dps *= 1.0 + float(state.get("bullet_pierce", 0)) * 0.22
	gun_dps *= 1.0 + float(state.get("bullet_blast_radius", 0.0)) / 120.0 * 0.22 * float(state.get("bullet_blast_damage", 1.0))
	var tower_dps: float = float(state.get("tower_count", 0)) * float(state.get("tower_damage", 0.0)) / max(float(state.get("tower_fire_interval", 1.0)), 0.1)
	var drone_dps: float = float(state.get("drone_count", 0)) * float(state.get("drone_damage", 0.0)) / max(float(state.get("drone_fire_interval", 1.0)), 0.08) * 0.72
	var tentacle_dps: float = float(state.get("tentacle_count", 0)) * float(state.get("tentacle_damage", 0.0)) / max(float(state.get("tentacle_cooldown", 1.0)), 0.12) * 0.64
	return gun_dps + tower_dps * 0.9 + drone_dps + tentacle_dps

func _calc_defense(state: Dictionary) -> float:
	return float(state.get("base_max_health", 0.0)) * 0.34 \
		+ float(state.get("shield_max", 0.0)) * 0.55 \
		+ float(state.get("shield_regen", 0.0)) * 4.6 \
		+ float(state.get("damage_reduction", 0.0)) * 260.0 \
		+ float(state.get("repair_between_waves", 0.0)) * 4.0 \
		+ float(state.get("projectile_redirect_chance", 0.0)) * 180.0 \
		+ float(state.get("tentacle_slow", 0.0)) * 120.0

func _calc_economy(state: Dictionary) -> float:
	var salvage_term: float = float(state.get("salvage_multiplier", 1.0)) * (1.0 + float(state.get("pickup_radius", 0.0)) / 240.0)
	var lifetime_term: float = 1.0 + max(float(state.get("salvage_lifetime", 7.4)) - 7.4, 0.0) / 20.0
	var bank_term: float = 1.0 + (float(state.get("wave_auto_bank_ratio", 0.68)) - 0.68) * 0.55
	var wave_bonus_term: float = 1.0 + float(state.get("wave_scrap_bonus", 0.0)) / 70.0
	var payout_term: float = float(state.get("meta_reward_multiplier", 1.0))
	return salvage_term * lifetime_term * bank_term * wave_bonus_term * payout_term

func _count_unique_nodes(meta_levels: Dictionary) -> int:
	var count := 0
	for key_variant in meta_levels.keys():
		if int(meta_levels[key_variant]) > 0:
			count += 1
	return count

func _count_total_tiers(meta_levels: Dictionary) -> int:
	var total := 0
	for key_variant in meta_levels.keys():
		total += int(meta_levels[key_variant])
	return total

func _average_key(entries: Array, key: String) -> float:
	if entries.is_empty():
		return 0.0
	var total := 0.0
	var counted := 0
	for entry in entries:
		var value: float = float(entry.get(key, 0.0))
		if value < 0.0:
			continue
		total += value
		counted += 1
	return 0.0 if counted <= 0 else total / float(counted)

func _average_nested_key(entries: Array[Dictionary], key: String) -> float:
	if entries.is_empty():
		return 0.0
	var total := 0.0
	for entry in entries:
		total += float(entry.get(key, 0.0))
	return total / float(entries.size())
