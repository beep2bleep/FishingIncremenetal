extends RefCounted
class_name RedSkyData

const CROSS_GAME_BONUSES := preload("res://CrossGameBonuses.gd")
const ICON_PREFIX := "redsky://"
const META_COST_MULTIPLIER := 0.78
const META_FIRST_TIER_DISCOUNT := 0.92
## Demo: lock meta nodes past this `step` on each branch (`META_UPGRADES`). Step 1–N stay buyable; step N+1+ show demo lock. Override: `global/red_sky_demo_max_meta_step`.
const DEMO_MAX_META_STEP_DEFAULT := 3
## Demo: this entire `branch` stays locked regardless of step (tentacle vat line).
const DEMO_ALWAYS_LOCKED_META_BRANCH_TENTACLES := 6

static func get_demo_max_meta_step() -> int:
	return maxi(1, int(ProjectSettings.get_setting("global/red_sky_demo_max_meta_step", DEMO_MAX_META_STEP_DEFAULT)))

static func should_lock_meta_upgrade_in_demo(entry: Dictionary) -> bool:
	if not bool(ProjectSettings.get_setting("global/Demo", false)):
		return false
	if int(entry.get("branch", 0)) == DEMO_ALWAYS_LOCKED_META_BRANCH_TENTACLES:
		return true
	return int(entry.get("step", 0)) > get_demo_max_meta_step()

static func count_eligible_meta_nodes_in_demo_slice() -> int:
	var max_step: int = get_demo_max_meta_step()
	var count := 0
	for raw_entry in META_UPGRADES:
		if int(raw_entry.get("branch", 0)) == DEMO_ALWAYS_LOCKED_META_BRANCH_TENTACLES:
			continue
		if int(raw_entry.get("step", 0)) <= max_step:
			count += 1
	return maxi(1, count)

const WAVE_OFFER_TIERS := [
	{"id": "poor", "label": "Poor", "multiplier": 0.75, "border": Color(0.55, 0.56, 0.60, 1.0)},
	{"id": "common", "label": "Common", "multiplier": 1.0, "border": Color(0.94, 0.94, 0.96, 1.0)},
	{"id": "uncommon", "label": "Uncommon", "multiplier": 1.25, "border": Color(0.32, 0.82, 0.42, 1.0)},
	{"id": "rare", "label": "Rare", "multiplier": 1.5, "border": Color(0.28, 0.56, 0.96, 1.0)},
	{"id": "epic", "label": "Epic", "multiplier": 1.75, "border": Color(0.63, 0.36, 0.9, 1.0)},
	{"id": "legendary", "label": "Legendary", "multiplier": 2.0, "border": Color(1.0, 0.58, 0.18, 1.0)}
]

const BASE_RUN_CONFIG := {
	"base_health": 154.0,
	"base_shield": 0.0,
	"shield_regen": 0.0,
	"shield_regen_delay": 2.6,
	"gun_damage": 12.0,
	"bullet_speed": 930.0,
	"fire_interval": 0.17,
	"crit_chance": 0.04,
	"crit_bonus": 1.65,
	"starting_nukes": 1,
	"nuke_max": 5,
	"nuke_regen_per_wave": 1,
	"nuke_damage": 128.0,
	"nuke_radius": 292.0,
	"pickup_radius": 28.0,
	"salvage_multiplier": 1.0,
	"salvage_lifetime": 7.4,
	"meta_reward_multiplier": 1.0,
	"wave_scrap_bonus": 0.0,
	"damage_reduction": 0.0,
	"repair_between_waves": 0.0,
	"bullet_pierce": 0,
	"bullet_blast_radius": 0.0,
	"bullet_blast_damage": 1.0,
	"tower_count": 0,
	"tower_damage": 15.0,
	"tower_range": 270.0,
	"tower_fire_interval": 1.18,
	"drone_count": 0,
	"drone_damage": 13.0,
	"drone_range": 210.0,
	"drone_fire_interval": 0.88,
	"drone_speed": 182.0,
	"tentacle_count": 0,
	"tentacle_damage": 19.0,
	"tentacle_range": 168.0,
	"tentacle_cooldown": 1.05,
	"tentacle_slow": 0.18,
	"construction_drone_count": 0,
	"construction_build_rate": 1.0,
	"temporary_turret_limit": 0,
	"temporary_turret_damage": 11.0,
	"temporary_turret_range": 210.0,
	"temporary_turret_fire_interval": 1.05,
	"temporary_turret_duration": 16.0,
	"temporary_turret_health": 58.0,
	"temporary_shield_limit": 0,
	"temporary_shield_capacity": 54.0,
	"temporary_shield_regen": 4.0,
	"temporary_shield_duration": 16.0,
	"temporary_shield_health": 54.0,
	"helper_drone_count": 0,
	"helper_drone_damage": 10.0,
	"helper_drone_range": 260.0,
	"helper_drone_fire_interval": 0.76,
	"helper_drone_speed": 224.0,
	"collector_bot_count": 0,
	"collector_bot_speed": 176.0,
	"scrap_generation_per_second": 0.0,
	"projectile_redirect_chance": 0.0,
	"upgrade_power_multiplier": 1.0,
	"enemy_count_scale": 1.0,
	"enemy_speed_scale": 1.0,
	"enemy_projectile_speed_scale": 1.0,
	"enemy_projectile_damage_scale": 1.0,
	"elite_spawn_scale": 1.0,
	"heavy_enemy_health_scale": 1.0,
	"heavy_enemy_damage_scale": 1.0,
	"apex_enemy_health_scale": 1.0,
	"apex_enemy_damage_scale": 1.0,
	"offer_quality_bonus": 0.0,
	"offer_roll_bonus": 0,
	"level_up_choice_count": 3,
	"max_level_up_choice_count": 9,
	"max_wave_upgrade_choices": 18,
	"rare_offer_unlocks": 0,
	"unlock_towers": false,
	"unlock_drones": false,
	"unlock_tentacles": false,
	"unlock_construction": false,
	"unlock_helpers": false,
	"unlock_collectors": false,
	"unlock_reflectors": false,
	"unlock_pierce": false,
	"unlock_blast": false,
	"unlock_salvage": false,
	"unlock_rare": false,
	"wave_auto_bank_ratio": 0.68
}

const META_UPGRADES: Array[Dictionary] = [
	{
		"id": "command_armor",
		"label": "Command Armor",
		"summary": "More starting hull and stronger repair-based survivability.",
		"icon": ICON_PREFIX + "command_armor",
		"act": 1,
		"cell": Vector2(0, -2),
		"dependency": "",
		"branch": 1,
		"step": 1,
		"base_cost": 110,
		"cost_scale": 1.50,
		"max_tier": 5
	},
	{
		"id": "shield_array",
		"label": "Shield Array",
		"summary": "Start each run with a rechargeable energy shield.",
		"icon": ICON_PREFIX + "shield_array",
		"act": 1,
		"cell": Vector2(0, -3),
		"dependency": "command_armor",
		"branch": 1,
		"step": 2,
		"base_cost": 150,
		"cost_scale": 1.56,
		"max_tier": 5
	},
	{
		"id": "shield_relay",
		"label": "Shield Relay",
		"summary": "Increase shield recharge rate and reduce downtime after taking hits.",
		"icon": ICON_PREFIX + "shield_relay",
		"act": 1,
		"cell": Vector2(0, -4),
		"dependency": "shield_array",
		"branch": 1,
		"step": 3,
		"base_cost": 205,
		"cost_scale": 1.58,
		"max_tier": 5
	},
	{
		"id": "emergency_bulkheads",
		"label": "Emergency Bulkheads",
		"summary": "Reduce hull damage that leaks through the line.",
		"icon": ICON_PREFIX + "emergency_bulkheads",
		"act": 1,
		"cell": Vector2(-1, -5),
		"dependency": "shield_relay",
		"branch": 1,
		"step": 4,
		"base_cost": 270,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "repair_crews",
		"label": "Repair Crews",
		"summary": "Restore hull between waves so longer runs remain realistic.",
		"icon": ICON_PREFIX + "repair_crews",
		"act": 1,
		"cell": Vector2(1, -5),
		"dependency": "shield_relay",
		"branch": 1,
		"step": 5,
		"base_cost": 300,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "damage_uplink",
		"label": "Damage Uplink",
		"summary": "Increase the baseline output of the main cannon.",
		"icon": ICON_PREFIX + "damage_uplink",
		"act": 2,
		"cell": Vector2(2, -1),
		"dependency": "",
		"branch": 2,
		"step": 1,
		"base_cost": 110,
		"cost_scale": 1.50,
		"max_tier": 5
	},
	{
		"id": "rapid_loader",
		"label": "Rapid Loader",
		"summary": "Improve fire cadence so you can keep pace with swarm pressure.",
		"icon": ICON_PREFIX + "rapid_loader",
		"act": 2,
		"cell": Vector2(3, -2),
		"dependency": "damage_uplink",
		"branch": 2,
		"step": 2,
		"base_cost": 150,
		"cost_scale": 1.56,
		"max_tier": 5
	},
	{
		"id": "tracking_array",
		"label": "Tracking Array",
		"summary": "Faster rounds and cleaner interception windows against evasive targets.",
		"icon": ICON_PREFIX + "tracking_array",
		"act": 2,
		"cell": Vector2(4, -3),
		"dependency": "rapid_loader",
		"branch": 2,
		"step": 3,
		"base_cost": 205,
		"cost_scale": 1.58,
		"max_tier": 5
	},
	{
		"id": "capacitor_bank",
		"label": "Capacitor Bank",
		"summary": "Boost critical strike frequency for the main battery.",
		"icon": ICON_PREFIX + "capacitor_bank",
		"act": 2,
		"cell": Vector2(5, -4),
		"dependency": "tracking_array",
		"branch": 2,
		"step": 4,
		"base_cost": 270,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "high_energy_cells",
		"label": "High-Energy Cells",
		"summary": "Critical hits land harder and scale better into late waves.",
		"icon": ICON_PREFIX + "high_energy_cells",
		"act": 2,
		"cell": Vector2(6, -5),
		"dependency": "capacitor_bank",
		"branch": 2,
		"step": 5,
		"base_cost": 300,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "reserve_nukes",
		"label": "Reserve Nukes",
		"summary": "More starting nukes and a higher stockpile cap for wave-to-wave rearming.",
		"icon": ICON_PREFIX + "reserve_nukes",
		"act": 3,
		"cell": Vector2(2, 1),
		"dependency": "",
		"branch": 3,
		"step": 1,
		"base_cost": 120,
		"cost_scale": 1.52,
		"max_tier": 5
	},
	{
		"id": "bigger_blasts",
		"label": "Bigger Blasts",
		"summary": "Increase the radius of every nuclear detonation.",
		"icon": ICON_PREFIX + "bigger_blasts",
		"act": 3,
		"cell": Vector2(3, 2),
		"dependency": "reserve_nukes",
		"branch": 3,
		"step": 2,
		"base_cost": 165,
		"cost_scale": 1.58,
		"max_tier": 5
	},
	{
		"id": "fusion_payload",
		"label": "Fusion Payload",
		"summary": "Increase nuke damage to keep the panic button meaningful.",
		"icon": ICON_PREFIX + "fusion_payload",
		"act": 3,
		"cell": Vector2(4, 3),
		"dependency": "bigger_blasts",
		"branch": 3,
		"step": 3,
		"base_cost": 215,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "piercing_rifling",
		"label": "Piercing Rifling",
		"summary": "Unlock piercing shot offers and improve anti-lineup potential.",
		"icon": ICON_PREFIX + "piercing_rifling",
		"act": 3,
		"cell": Vector2(5, 4),
		"dependency": "fusion_payload",
		"branch": 3,
		"step": 4,
		"base_cost": 275,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "blast_chambers",
		"label": "Blast Chambers",
		"summary": "Unlock explosive round offers and improve area damage scaling.",
		"icon": ICON_PREFIX + "blast_chambers",
		"act": 3,
		"cell": Vector2(6, 5),
		"dependency": "piercing_rifling",
		"branch": 3,
		"step": 5,
		"base_cost": 320,
		"cost_scale": 1.64,
		"max_tier": 5
	},
	{
		"id": "tower_fabrication",
		"label": "Tower Fabrication",
		"summary": "Unlock flak towers as a permanent battlefield system.",
		"icon": ICON_PREFIX + "tower_fabrication",
		"act": 4,
		"cell": Vector2(0, 2),
		"dependency": "",
		"branch": 4,
		"step": 1,
		"base_cost": 130,
		"cost_scale": 1.54,
		"max_tier": 5
	},
	{
		"id": "tower_targeting",
		"label": "Tower Targeting",
		"summary": "Make defensive towers hit harder and reach sooner.",
		"icon": ICON_PREFIX + "tower_targeting",
		"act": 4,
		"cell": Vector2(0, 3),
		"dependency": "tower_fabrication",
		"branch": 4,
		"step": 2,
		"base_cost": 175,
		"cost_scale": 1.58,
		"max_tier": 5
	},
	{
		"id": "tower_cooling",
		"label": "Tower Cooling",
		"summary": "Reduce downtime between tower shots.",
		"icon": ICON_PREFIX + "tower_cooling",
		"act": 4,
		"cell": Vector2(0, 4),
		"dependency": "tower_targeting",
		"branch": 4,
		"step": 3,
		"base_cost": 225,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "reflector_grid",
		"label": "Reflector Grid",
		"summary": "Unlock projectile redirection and increase interception reliability.",
		"icon": ICON_PREFIX + "reflector_grid",
		"act": 4,
		"cell": Vector2(-1, 5),
		"dependency": "tower_cooling",
		"branch": 4,
		"step": 4,
		"base_cost": 285,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "signal_decoder",
		"label": "Signal Decoder",
		"summary": "Improve offer quality and unlock the rare battlefield options.",
		"icon": ICON_PREFIX + "signal_decoder",
		"act": 4,
		"cell": Vector2(1, 5),
		"dependency": "tower_cooling",
		"branch": 4,
		"step": 5,
		"base_cost": 320,
		"cost_scale": 1.64,
		"max_tier": 5
	},
	{
		"id": "drone_hangar",
		"label": "Drone Hangar",
		"summary": "Unlock interceptor drones for sustained coverage.",
		"icon": ICON_PREFIX + "drone_hangar",
		"act": 4,
		"cell": Vector2(-2, 1),
		"dependency": "",
		"branch": 5,
		"step": 1,
		"base_cost": 130,
		"cost_scale": 1.54,
		"max_tier": 5
	},
	{
		"id": "drone_ai",
		"label": "Drone AI",
		"summary": "Increase drone damage and target response quality.",
		"icon": ICON_PREFIX + "drone_ai",
		"act": 4,
		"cell": Vector2(-3, 2),
		"dependency": "drone_hangar",
		"branch": 5,
		"step": 2,
		"base_cost": 175,
		"cost_scale": 1.58,
		"max_tier": 5
	},
	{
		"id": "drone_flight_pack",
		"label": "Drone Flight Pack",
		"summary": "Increase drone movement and fire cadence.",
		"icon": ICON_PREFIX + "drone_flight_pack",
		"act": 4,
		"cell": Vector2(-4, 3),
		"dependency": "drone_ai",
		"branch": 5,
		"step": 3,
		"base_cost": 225,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "magnet_array",
		"label": "Magnet Array",
		"summary": "Unlock salvage-focused offers and pull pickups in faster.",
		"icon": ICON_PREFIX + "magnet_array",
		"act": 4,
		"cell": Vector2(-5, 4),
		"dependency": "drone_flight_pack",
		"branch": 5,
		"step": 4,
		"base_cost": 285,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "salvage_bays",
		"label": "Salvage Bays",
		"summary": "Increase scrap yield so meta progress keeps pace with run danger.",
		"icon": ICON_PREFIX + "salvage_bays",
		"act": 4,
		"cell": Vector2(-6, 5),
		"dependency": "magnet_array",
		"branch": 5,
		"step": 5,
		"base_cost": 320,
		"cost_scale": 1.64,
		"max_tier": 5
	},
	{
		"id": "tentacle_vat",
		"label": "Tentacle Vat",
		"summary": "Unlock close-range biomass guardians around the command base.",
		"icon": ICON_PREFIX + "tentacle_vat",
		"act": 1,
		"cell": Vector2(-2, -1),
		"dependency": "",
		"branch": 6,
		"step": 1,
		"base_cost": 125,
		"cost_scale": 1.52,
		"max_tier": 5
	},
	{
		"id": "tentacle_spines",
		"label": "Tentacle Spines",
		"summary": "Increase tentacle impact damage so they matter in mid-wave crushes.",
		"icon": ICON_PREFIX + "tentacle_spines",
		"act": 1,
		"cell": Vector2(-3, -2),
		"dependency": "tentacle_vat",
		"branch": 6,
		"step": 2,
		"base_cost": 170,
		"cost_scale": 1.58,
		"max_tier": 5
	},
	{
		"id": "tentacle_reach",
		"label": "Tentacle Reach",
		"summary": "Increase lash radius and crowd-control strength.",
		"icon": ICON_PREFIX + "tentacle_reach",
		"act": 1,
		"cell": Vector2(-4, -3),
		"dependency": "tentacle_spines",
		"branch": 6,
		"step": 3,
		"base_cost": 220,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "engineer_crew",
		"label": "Engineer Crew",
		"summary": "Improve offer variety so runs pivot into new tools more often.",
		"icon": ICON_PREFIX + "engineer_crew",
		"act": 1,
		"cell": Vector2(-5, -4),
		"dependency": "tentacle_reach",
		"branch": 6,
		"step": 4,
		"base_cost": 280,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "tactical_briefing",
		"label": "Tactical Briefing",
		"summary": "Gain more battlefield choices after each cleared wave, up to six.",
		"icon": ICON_PREFIX + "tactical_briefing",
		"act": 1,
		"cell": Vector2(-6, -4),
		"dependency": "engineer_crew",
		"branch": 6,
		"step": 5,
		"base_cost": 320,
		"cost_scale": 1.68,
		"max_tier": 3
	},
	{
		"id": "overclock_protocol",
		"label": "Overclock Protocol",
		"summary": "Increase how hard each roguelite pick pushes your run forward.",
		"icon": ICON_PREFIX + "overclock_protocol",
		"act": 1,
		"cell": Vector2(-6, -5),
		"dependency": "engineer_crew",
		"branch": 6,
		"step": 5,
		"base_cost": 325,
		"cost_scale": 1.64,
		"max_tier": 5
	},
	{
		"id": "scrap_ledgers",
		"label": "Scrap Ledgers",
		"summary": "Increase the total scrap payout from every completed run.",
		"icon": ICON_PREFIX + "scrap_ledgers",
		"act": 5,
		"cell": Vector2(-1, 7),
		"dependency": "",
		"branch": 7,
		"step": 1,
		"base_cost": 140,
		"cost_scale": 1.54,
		"max_tier": 5
	},
	{
		"id": "contract_bounties",
		"label": "Contract Bounties",
		"summary": "Earn bonus scrap every time you clear another wave.",
		"icon": ICON_PREFIX + "contract_bounties",
		"act": 5,
		"cell": Vector2(0, 8),
		"dependency": "scrap_ledgers",
		"branch": 7,
		"step": 2,
		"base_cost": 190,
		"cost_scale": 1.58,
		"max_tier": 5
	},
	{
		"id": "recovery_barges",
		"label": "Recovery Barges",
		"summary": "Bank more leftover salvage between waves and keep pickups alive longer.",
		"icon": ICON_PREFIX + "recovery_barges",
		"act": 5,
		"cell": Vector2(1, 9),
		"dependency": "contract_bounties",
		"branch": 7,
		"step": 3,
		"base_cost": 245,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "salvage_markets",
		"label": "Salvage Markets",
		"summary": "Improve the value of salvage hauled home during the run.",
		"icon": ICON_PREFIX + "salvage_markets",
		"act": 5,
		"cell": Vector2(2, 10),
		"dependency": "recovery_barges",
		"branch": 7,
		"step": 4,
		"base_cost": 310,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "sweep_drones",
		"label": "Sweep Drones",
		"summary": "Increase collection reach and reduce how much value slips away mid-run.",
		"icon": ICON_PREFIX + "sweep_drones",
		"act": 5,
		"cell": Vector2(3, 11),
		"dependency": "salvage_markets",
		"branch": 7,
		"step": 5,
		"base_cost": 370,
		"cost_scale": 1.64,
		"max_tier": 5
	},
	{
		"id": "profit_directive",
		"label": "Profit Directive",
		"summary": "Turn deep runs into much stronger campaign progression.",
		"icon": ICON_PREFIX + "profit_directive",
		"act": 5,
		"cell": Vector2(4, 12),
		"dependency": "sweep_drones",
		"branch": 7,
		"step": 6,
		"base_cost": 435,
		"cost_scale": 1.66,
		"max_tier": 5
	},
	{
		"id": "threat_analysis",
		"label": "Threat Analysis",
		"summary": "Reduce total hostile wave count so later runs can reach deeper lines.",
		"icon": ICON_PREFIX + "threat_analysis",
		"act": 6,
		"cell": Vector2(-5, 7),
		"dependency": "",
		"branch": 8,
		"step": 1,
		"base_cost": 145,
		"cost_scale": 1.52,
		"max_tier": 5
	},
	{
		"id": "gravitic_dragnet",
		"label": "Gravitic Dragnet",
		"summary": "Slow incoming formations so rushers and bombers are easier to read.",
		"icon": ICON_PREFIX + "gravitic_dragnet",
		"act": 6,
		"cell": Vector2(-6, 8),
		"dependency": "threat_analysis",
		"branch": 8,
		"step": 2,
		"base_cost": 200,
		"cost_scale": 1.56,
		"max_tier": 5
	},
	{
		"id": "signal_jammers",
		"label": "Signal Jammers",
		"summary": "Cut hostile projectile pressure by slowing and weakening incoming volleys.",
		"icon": ICON_PREFIX + "signal_jammers",
		"act": 6,
		"cell": Vector2(-7, 9),
		"dependency": "gravitic_dragnet",
		"branch": 8,
		"step": 3,
		"base_cost": 255,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "hunter_killer_doctrine",
		"label": "Hunter-Killer Doctrine",
		"summary": "Specialize command fire plans against heavy enemy hulls and late-wave bruisers.",
		"icon": ICON_PREFIX + "hunter_killer_doctrine",
		"act": 6,
		"cell": Vector2(-8, 10),
		"dependency": "signal_jammers",
		"branch": 8,
		"step": 4,
		"base_cost": 320,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "apex_countermeasures",
		"label": "Apex Countermeasures",
		"summary": "Blunt the deadliest elite and boss arrivals so solo monsters stop ending runs outright.",
		"icon": ICON_PREFIX + "apex_countermeasures",
		"act": 6,
		"cell": Vector2(-9, 11),
		"dependency": "hunter_killer_doctrine",
		"branch": 8,
		"step": 5,
		"base_cost": 390,
		"cost_scale": 1.64,
		"max_tier": 5
	},
	{
		"id": "construction_bay",
		"label": "Construction Bay",
		"summary": "Deploy invulnerable construction drones that assemble temporary defenses during combat.",
		"icon": ICON_PREFIX + "construction_bay",
		"act": 5,
		"cell": Vector2(6, 7),
		"dependency": "tower_fabrication",
		"branch": 9,
		"step": 1,
		"base_cost": 170,
		"cost_scale": 1.56,
		"max_tier": 5
	},
	{
		"id": "field_fabricators",
		"label": "Field Fabricators",
		"summary": "Construction drones build faster and keep temporary defenses online longer.",
		"icon": ICON_PREFIX + "field_fabricators",
		"act": 5,
		"cell": Vector2(7, 8),
		"dependency": "construction_bay",
		"branch": 9,
		"step": 2,
		"base_cost": 230,
		"cost_scale": 1.60,
		"max_tier": 5
	},
	{
		"id": "escort_wing",
		"label": "Escort Wing",
		"summary": "Unlock roaming helper drones that chase threats beyond the tower ring.",
		"icon": ICON_PREFIX + "escort_wing",
		"act": 5,
		"cell": Vector2(8, 9),
		"dependency": "drone_hangar",
		"branch": 9,
		"step": 3,
		"base_cost": 270,
		"cost_scale": 1.62,
		"max_tier": 5
	},
	{
		"id": "escort_doctrine",
		"label": "Escort Doctrine",
		"summary": "Helper drones hit harder, reach farther, and reposition faster.",
		"icon": ICON_PREFIX + "escort_doctrine",
		"act": 5,
		"cell": Vector2(9, 10),
		"dependency": "escort_wing",
		"branch": 9,
		"step": 4,
		"base_cost": 325,
		"cost_scale": 1.64,
		"max_tier": 5
	},
	{
		"id": "scrap_foundry",
		"label": "Scrap Foundry",
		"summary": "Generate passive scrap during waves and unlock collector bots for battlefield cleanup.",
		"icon": ICON_PREFIX + "scrap_foundry",
		"act": 5,
		"cell": Vector2(10, 11),
		"dependency": "salvage_bays",
		"branch": 9,
		"step": 5,
		"base_cost": 380,
		"cost_scale": 1.66,
		"max_tier": 5
	},
	{
		"id": "choice_matrix",
		"label": "Choice Matrix",
		"summary": "Raise the wave-upgrade choice cap all the way to nine and improve battlefield flexibility.",
		"icon": ICON_PREFIX + "choice_matrix",
		"act": 5,
		"cell": Vector2(-8, -5),
		"dependency": "tactical_briefing",
		"branch": 10,
		"step": 1,
		"base_cost": 360,
		"cost_scale": 1.68,
		"max_tier": 3
	},
]

const WAVE_UPGRADES: Array[Dictionary] = [
	{
		"id": "focused_barrels",
		"label": "Focused Barrels",
		"summary": "Main gun damage up.",
		"weight": 1.25,
		"rarity": 0,
		"max_stacks": 18,
		"requires": [],
		"effects": {"add": {"gun_damage": 3.5}, "mult": {}}
	},
	{
		"id": "cooling_jackets",
		"label": "Cooling Jackets",
		"summary": "Fire faster.",
		"weight": 1.2,
		"rarity": 0,
		"max_stacks": 16,
		"requires": [],
		"effects": {"add": {}, "mult": {"fire_rate": 1.08}}
	},
	{
		"id": "seeker_ammo",
		"label": "Seeker Ammo",
		"summary": "Bullet speed up.",
		"weight": 1.08,
		"rarity": 0,
		"max_stacks": 8,
		"requires": [],
		"effects": {"add": {"bullet_speed": 90.0}, "mult": {}}
	},
	{
		"id": "armor_patch",
		"label": "Armor Patch",
		"summary": "Increase max hull and repair some damage.",
		"weight": 1.18,
		"rarity": 0,
		"max_stacks": 14,
		"requires": [],
		"effects": {"add": {"base_max_health": 18.0, "repair": 24.0}, "mult": {}}
	},
	{
		"id": "shield_boost",
		"label": "Shield Boost",
		"summary": "More shield capacity right now.",
		"weight": 1.0,
		"rarity": 0,
		"max_stacks": 12,
		"requires": ["shield"],
		"effects": {"add": {"shield_max": 22.0, "shield_fill": 22.0}, "mult": {}}
	},
	{
		"id": "shield_relay_burst",
		"label": "Shield Relay",
		"summary": "Shields recover faster.",
		"weight": 0.95,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["shield"],
		"effects": {"add": {"shield_regen": 3.5}, "mult": {}}
	},
	{
		"id": "reserve_nuke_pick",
		"label": "Reserve Nuke",
		"summary": "Add a nuke now and expand your max stockpile.",
		"weight": 0.76,
		"rarity": 1,
		"max_stacks": 6,
		"requires": [],
		"effects": {"add": {"nuke_max": 1.0, "nukes": 1.0}, "mult": {}}
	},
	{
		"id": "fusion_warhead",
		"label": "Fusion Warhead",
		"summary": "Nukes hit harder.",
		"weight": 0.78,
		"rarity": 1,
		"max_stacks": 8,
		"requires": [],
		"effects": {"add": {}, "mult": {"nuke_damage": 1.18}}
	},
	{
		"id": "blast_shells",
		"label": "Blast Shells",
		"summary": "Nukes cover more ground.",
		"weight": 0.78,
		"rarity": 1,
		"max_stacks": 8,
		"requires": [],
		"effects": {"add": {}, "mult": {"nuke_radius": 1.14}}
	},
	{
		"id": "piercing_rounds",
		"label": "Piercing Rounds",
		"summary": "Shots punch through one more target.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 7,
		"requires": ["pierce"],
		"effects": {"add": {"bullet_pierce": 1.0}, "mult": {}}
	},
	{
		"id": "shrapnel_rounds",
		"label": "Shrapnel Rounds",
		"summary": "Shots gain a small blast on impact.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 8,
		"requires": ["blast"],
		"effects": {"add": {"bullet_blast_radius": 18.0}, "mult": {"bullet_blast_damage": 1.12}}
	},
	{
		"id": "capacitor_overdrive",
		"label": "Capacitor Overdrive",
		"summary": "Critical chance up.",
		"weight": 0.96,
		"rarity": 1,
		"max_stacks": 10,
		"requires": [],
		"effects": {"add": {"crit_chance": 0.05}, "mult": {}}
	},
	{
		"id": "critical_mass",
		"label": "Critical Mass",
		"summary": "Critical hits deal more damage.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 10,
		"requires": [],
		"effects": {"add": {}, "mult": {"crit_bonus": 1.18}}
	},
	{
		"id": "flak_turret",
		"label": "Flak Turret",
		"summary": "Add one defensive tower.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 8,
		"requires": ["tower"],
		"effects": {"add": {"tower_count": 1.0}, "mult": {}}
	},
	{
		"id": "tower_overclock",
		"label": "Tower Overclock",
		"summary": "Tower damage up.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["tower"],
		"effects": {"add": {}, "mult": {"tower_damage": 1.22}}
	},
	{
		"id": "tower_autoloader",
		"label": "Tower Autoloader",
		"summary": "Towers fire faster.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["tower"],
		"effects": {"add": {}, "mult": {"tower_fire_rate": 1.14}}
	},
	{
		"id": "interceptor_drone",
		"label": "Interceptor Drone",
		"summary": "Add one support drone.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 8,
		"requires": ["drone"],
		"effects": {"add": {"drone_count": 1.0}, "mult": {}}
	},
	{
		"id": "drone_firmware",
		"label": "Drone Firmware",
		"summary": "Drone damage up.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["drone"],
		"effects": {"add": {}, "mult": {"drone_damage": 1.18}}
	},
	{
		"id": "drone_afterburners",
		"label": "Drone Afterburners",
		"summary": "Drones move and cycle faster.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["drone"],
		"effects": {"add": {}, "mult": {"drone_fire_rate": 1.12, "drone_speed": 1.12}}
	},
	{
		"id": "tentacle_pod",
		"label": "Tentacle Pod",
		"summary": "Add one biomass guardian.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 8,
		"requires": ["tentacle"],
		"effects": {"add": {"tentacle_count": 1.0}, "mult": {}}
	},
	{
		"id": "serrated_tentacles",
		"label": "Serrated Tentacles",
		"summary": "Tentacles hit harder.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["tentacle"],
		"effects": {"add": {}, "mult": {"tentacle_damage": 1.22}}
	},
	{
		"id": "grasping_reach",
		"label": "Grasping Reach",
		"summary": "Tentacles reach farther and slow more.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["tentacle"],
		"effects": {"add": {"tentacle_slow": 0.04}, "mult": {"tentacle_range": 1.12}}
	},
	{
		"id": "reflector_pylon",
		"label": "Reflector Pylon",
		"summary": "Better odds to redirect incoming projectiles.",
		"weight": 0.72,
		"rarity": 2,
		"max_stacks": 8,
		"requires": ["reflector"],
		"effects": {"add": {"projectile_redirect_chance": 0.07}, "mult": {}}
	},
	{
		"id": "salvage_burst",
		"label": "Salvage Burst",
		"summary": "Enemies spill more scrap.",
		"weight": 0.86,
		"rarity": 1,
		"max_stacks": 12,
		"requires": ["salvage"],
		"effects": {"add": {}, "mult": {"salvage_multiplier": 1.18}}
	},
	{
		"id": "magnet_sweep",
		"label": "Magnet Sweep",
		"summary": "Pickups collect from farther away.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["salvage"],
		"effects": {"add": {"pickup_radius": 20.0}, "mult": {}}
	},
	{
		"id": "command_overclock",
		"label": "Command Overclock",
		"summary": "Future wave upgrades become slightly stronger.",
		"weight": 0.62,
		"rarity": 2,
		"max_stacks": 8,
		"requires": ["rare"],
		"effects": {"add": {}, "mult": {"upgrade_power_multiplier": 1.07}}
	},
	{
		"id": "bounty_contracts",
		"label": "Bounty Contracts",
		"summary": "Each cleared wave pays bonus scrap.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["salvage"],
		"effects": {"add": {"wave_scrap_bonus": 4.0}, "mult": {}}
	},
	{
		"id": "claim_adjusters",
		"label": "Claim Adjusters",
		"summary": "More leftover salvage auto-banks between waves.",
		"weight": 0.74,
		"rarity": 1,
		"max_stacks": 8,
		"requires": ["salvage"],
		"effects": {"add": {"wave_auto_bank_ratio": 0.06}, "mult": {}}
	},
	{
		"id": "recovery_net",
		"label": "Recovery Net",
		"summary": "Salvage lingers longer before it fades.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 8,
		"requires": ["salvage"],
		"effects": {"add": {"salvage_lifetime": 1.25}, "mult": {}}
	},
	{
		"id": "scavenger_grid",
		"label": "Scavenger Grid",
		"summary": "Scrap pulls harder and cashes out better.",
		"weight": 0.64,
		"rarity": 2,
		"max_stacks": 8,
		"requires": ["salvage", "rare"],
		"effects": {"add": {"pickup_radius": 14.0, "wave_auto_bank_ratio": 0.03}, "mult": {"salvage_multiplier": 1.08}}
	},
	{
		"id": "reinforced_plating",
		"label": "Reinforced Plating",
		"summary": "Thicken the hull for tougher late-wave holds.",
		"weight": 1.04,
		"rarity": 1,
		"max_stacks": 12,
		"requires": [],
		"effects": {"add": {"base_max_health": 28.0, "repair": 18.0}, "mult": {}}
	},
	{
		"id": "field_repairs",
		"label": "Field Repairs",
		"summary": "Recover more hull between spikes and boss dives.",
		"weight": 0.96,
		"rarity": 1,
		"max_stacks": 10,
		"requires": [],
		"effects": {"add": {"repair": 42.0}, "mult": {}}
	},
	{
		"id": "shield_capacitors",
		"label": "Shield Capacitors",
		"summary": "Wider shield banks for hard projectile waves.",
		"weight": 0.9,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["shield"],
		"effects": {"add": {"shield_max": 30.0, "shield_fill": 20.0}, "mult": {}}
	},
	{
		"id": "battery_loop",
		"label": "Battery Loop",
		"summary": "Shield systems and fire control cycle faster together.",
		"weight": 0.82,
		"rarity": 2,
		"max_stacks": 8,
		"requires": ["shield"],
		"effects": {"add": {"shield_regen": 4.5}, "mult": {"fire_rate": 1.06}}
	},
	{
		"id": "ammo_hoppers",
		"label": "Ammo Hoppers",
		"summary": "Feed the main battery harder without flooding the screen.",
		"weight": 0.98,
		"rarity": 1,
		"max_stacks": 12,
		"requires": [],
		"effects": {"add": {"gun_damage": 2.5}, "mult": {"fire_rate": 1.06}}
	},
	{
		"id": "warhead_racks",
		"label": "Warhead Racks",
		"summary": "Load a spare warhead, speed up per-wave rearming, and sharpen the payload.",
		"weight": 0.72,
		"rarity": 2,
		"max_stacks": 6,
		"requires": [],
		"effects": {"add": {"nuke_regen_per_wave": 1.0, "nukes": 1.0}, "mult": {"nuke_damage": 1.10}}
	},
	{
		"id": "nuke_silo_extension",
		"label": "Silo Extension",
		"summary": "Expand how many nukes you can hold at once.",
		"weight": 0.88,
		"rarity": 0,
		"max_stacks": 6,
		"requires": [],
		"effects": {"add": {"nuke_max": 2.0}, "mult": {}}
	},
	{
		"id": "reactor_rearm_cycle",
		"label": "Reactor Rearm",
		"summary": "Fabricate more nukes each time a wave begins.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 5,
		"requires": [],
		"effects": {"add": {"nuke_regen_per_wave": 1.0}, "mult": {}}
	},
	{
		"id": "flak_wall",
		"label": "Flak Wall",
		"summary": "Raise another tower and juice its first volleys.",
		"weight": 0.74,
		"rarity": 2,
		"max_stacks": 8,
		"requires": ["tower"],
		"effects": {"add": {"tower_count": 1.0}, "mult": {"tower_damage": 1.10}}
	},
	{
		"id": "tower_rangefinder",
		"label": "Tower Rangefinder",
		"summary": "Let towers engage earlier and cover more lanes.",
		"weight": 0.8,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["tower"],
		"effects": {"add": {"tower_range": 34.0}, "mult": {"tower_damage": 1.08}}
	},
	{
		"id": "drone_swarm",
		"label": "Drone Swarm",
		"summary": "Release another interceptor and tighten its cadence.",
		"weight": 0.74,
		"rarity": 2,
		"max_stacks": 8,
		"requires": ["drone"],
		"effects": {"add": {"drone_count": 1.0}, "mult": {"drone_fire_rate": 1.08}}
	},
	{
		"id": "hunter_link",
		"label": "Hunter Link",
		"summary": "Support drones strike farther and hit with better focus.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["drone"],
		"effects": {"add": {"drone_range": 26.0}, "mult": {"drone_damage": 1.14, "drone_speed": 1.06}}
	},
	{
		"id": "brood_nest",
		"label": "Brood Nest",
		"summary": "Grow another tentacle and keep the front line sticky.",
		"weight": 0.74,
		"rarity": 2,
		"max_stacks": 8,
		"requires": ["tentacle"],
		"effects": {"add": {"tentacle_count": 1.0}, "mult": {"tentacle_damage": 1.10}}
	},
	{
		"id": "tendon_network",
		"label": "Tendon Network",
		"summary": "Tentacles reach wider arcs and drag targets longer.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["tentacle"],
		"effects": {"add": {"tentacle_slow": 0.03}, "mult": {"tentacle_range": 1.14}}
	},
	{
		"id": "salvage_convoys",
		"label": "Salvage Convoys",
		"summary": "Late waves spill better scrap and pay more per clear.",
		"weight": 0.78,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["salvage"],
		"effects": {"add": {"wave_scrap_bonus": 3.0}, "mult": {"salvage_multiplier": 1.12}}
	},
	{
		"id": "magnetic_funnels",
		"label": "Magnetic Funnels",
		"summary": "Sweep wider arcs of salvage into the command core.",
		"weight": 0.74,
		"rarity": 1,
		"max_stacks": 10,
		"requires": ["salvage"],
		"effects": {"add": {"pickup_radius": 18.0, "wave_auto_bank_ratio": 0.03}, "mult": {}}
	},
	{
		"id": "command_node",
		"label": "Command Node",
		"summary": "Open one more choice after each future wave.",
		"weight": 0.58,
		"rarity": 2,
		"max_stacks": 3,
		"requires": ["rare"],
		"effects": {"add": {"level_up_choice_count": 1.0}, "mult": {}}
	},
	{
		"id": "refinement_protocols",
		"label": "Refinement Protocols",
		"summary": "Scale future picks and battlefield scrap together.",
		"weight": 0.56,
		"rarity": 2,
		"max_stacks": 8,
		"requires": ["rare", "salvage"],
		"effects": {"add": {}, "mult": {"upgrade_power_multiplier": 1.06, "salvage_multiplier": 1.06}}
	},
	{
		"id": "traffic_control",
		"label": "Traffic Control",
		"summary": "Future waves field fewer attackers.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 9,
		"min_wave": 3,
		"requires": [],
		"effects": {"add": {}, "mult": {"enemy_count_scale": 0.92}}
	},
	{
		"id": "gravity_well",
		"label": "Gravity Well",
		"summary": "Future enemies approach more slowly.",
		"weight": 0.8,
		"rarity": 1,
		"max_stacks": 8,
		"min_wave": 4,
		"requires": [],
		"effects": {"add": {}, "mult": {"enemy_speed_scale": 0.9}}
	},
	{
		"id": "counterbattery_jammers",
		"label": "Counterbattery Jammers",
		"summary": "Hostile volleys travel slower and hit softer.",
		"weight": 0.7,
		"rarity": 2,
		"max_stacks": 7,
		"min_wave": 5,
		"requires": ["rare"],
		"effects": {"add": {}, "mult": {"enemy_projectile_speed_scale": 0.88, "enemy_projectile_damage_scale": 0.92}}
	},
	{
		"id": "elite_kill_orders",
		"label": "Elite Kill Orders",
		"summary": "Heavy enemies enter thinner and break faster.",
		"weight": 0.66,
		"rarity": 2,
		"max_stacks": 7,
		"min_wave": 6,
		"requires": ["rare"],
		"effects": {"add": {}, "mult": {"elite_spawn_scale": 0.92, "heavy_enemy_health_scale": 0.84}}
	},
	{
		"id": "boss_breakers",
		"label": "Boss Breakers",
		"summary": "The nastiest solo monsters lose health and impact.",
		"weight": 0.58,
		"rarity": 2,
		"max_stacks": 6,
		"min_wave": 8,
		"requires": ["rare"],
		"effects": {"add": {}, "mult": {"apex_enemy_health_scale": 0.8, "apex_enemy_damage_scale": 0.88}}
	},
	{
		"id": "constructor_drone",
		"label": "Constructor Drone",
		"summary": "Add one construction drone to keep building temporary defenses.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 8,
		"min_wave": 3,
		"requires": ["construction"],
		"effects": {"add": {"construction_drone_count": 1.0}, "mult": {}}
	},
	{
		"id": "field_turret_blueprints",
		"label": "Field Turret Blueprints",
		"summary": "Let constructors assemble another temporary turret and improve its damage.",
		"weight": 0.68,
		"rarity": 1,
		"max_stacks": 8,
		"min_wave": 4,
		"requires": ["construction"],
		"effects": {"add": {"temporary_turret_limit": 1.0}, "mult": {"temporary_turret_damage": 1.12}}
	},
	{
		"id": "shield_emitter_blueprints",
		"label": "Shield Emitter Blueprints",
		"summary": "Let constructors assemble another temporary shield node and thicken its barrier.",
		"weight": 0.68,
		"rarity": 1,
		"max_stacks": 8,
		"min_wave": 4,
		"requires": ["construction"],
		"effects": {"add": {"temporary_shield_limit": 1.0, "temporary_shield_capacity": 16.0}, "mult": {}}
	},
	{
		"id": "rapid_fabrication",
		"label": "Rapid Fabrication",
		"summary": "Construction drones work faster and temporary defenses last longer.",
		"weight": 0.62,
		"rarity": 2,
		"max_stacks": 8,
		"min_wave": 5,
		"requires": ["construction", "rare"],
		"effects": {"add": {"temporary_turret_duration": 2.0, "temporary_shield_duration": 2.0}, "mult": {"construction_build_rate": 1.14}}
	},
	{
		"id": "escort_drone",
		"label": "Escort Drone",
		"summary": "Add one roaming helper drone that hunts pressure away from the base.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 8,
		"min_wave": 3,
		"requires": ["helper"],
		"effects": {"add": {"helper_drone_count": 1.0}, "mult": {}}
	},
	{
		"id": "escort_targeting",
		"label": "Escort Targeting",
		"summary": "Helper drones hit harder and cover more space.",
		"weight": 0.66,
		"rarity": 1,
		"max_stacks": 10,
		"min_wave": 4,
		"requires": ["helper"],
		"effects": {"add": {"helper_drone_range": 24.0}, "mult": {"helper_drone_damage": 1.14}}
	},
	{
		"id": "escort_thrusters",
		"label": "Escort Thrusters",
		"summary": "Helper drones move and cycle faster.",
		"weight": 0.66,
		"rarity": 1,
		"max_stacks": 10,
		"min_wave": 4,
		"requires": ["helper"],
		"effects": {"add": {}, "mult": {"helper_drone_speed": 1.14, "helper_drone_fire_rate": 1.10}}
	},
	{
		"id": "collector_bots",
		"label": "Collector Bots",
		"summary": "Deploy a scrap collector bot to scoop value that would otherwise drift away.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 8,
		"min_wave": 3,
		"requires": ["collector"],
		"effects": {"add": {"collector_bot_count": 1.0}, "mult": {}}
	},
	{
		"id": "collector_thrusters",
		"label": "Collector Thrusters",
		"summary": "Collector bots move faster and vacuum pickups from farther out.",
		"weight": 0.66,
		"rarity": 1,
		"max_stacks": 10,
		"min_wave": 4,
		"requires": ["collector"],
		"effects": {"add": {"pickup_radius": 14.0}, "mult": {"collector_bot_speed": 1.16}}
	},
	{
		"id": "scrap_printers",
		"label": "Scrap Printers",
		"summary": "Generate passive scrap while the line holds.",
		"weight": 0.58,
		"rarity": 2,
		"max_stacks": 10,
		"min_wave": 5,
		"requires": ["collector", "rare"],
		"effects": {"add": {"scrap_generation_per_second": 1.4}, "mult": {}}
	},
	{
		"id": "choice_array",
		"label": "Choice Array",
		"summary": "Open two more future wave-upgrade choices.",
		"weight": 0.42,
		"rarity": 2,
		"max_stacks": 6,
		"min_wave": 6,
		"requires": ["rare"],
		"effects": {"add": {"level_up_choice_count": 2.0}, "mult": {}}
	},
	{
		"id": "fox_seeker_salvo",
		"label": "Fox Seeker Salvo",
		"summary": "Some main-gun rounds curve toward targets near your crosshair.",
		"weight": 0.74,
		"rarity": 1,
		"max_stacks": 10,
		"min_wave": 2,
		"requires": [],
		"effects": {"add": {"homing_missile_level": 1.0}, "mult": {}}
	},
	{
		"id": "polarized_weave",
		"label": "Polarized Weave",
		"summary": "Tune the hull against unblockable penetrators when the wheel favors countermeasures.",
		"weight": 0.68,
		"rarity": 1,
		"max_stacks": 10,
		"min_wave": 3,
		"requires": [],
		"effects": {"add": {"countermeasures_rating": 0.07}, "mult": {}}
	},
]

static func get_base_run_config() -> Dictionary:
	return BASE_RUN_CONFIG.duplicate(true)

static func get_wave_offer_tier_definition(tier_index: int) -> Dictionary:
	var safe_index: int = clampi(tier_index, 0, WAVE_OFFER_TIERS.size() - 1)
	return WAVE_OFFER_TIERS[safe_index].duplicate(true)

static func roll_wave_offer_tier(upgrade_def: Dictionary, meta_bonuses: Dictionary, rng: RandomNumberGenerator) -> int:
	var quality_roll: float = rng.randf()
	quality_roll += float(meta_bonuses.get("offer_quality_bonus", 0.0)) * 0.12
	quality_roll += float(meta_bonuses.get("offer_roll_bonus", 0)) * 0.01
	quality_roll += float(upgrade_def.get("rarity", 0)) * 0.06
	quality_roll = clampf(quality_roll, 0.0, 1.35)
	if quality_roll >= 1.18:
		return 5
	if quality_roll >= 1.02:
		return 4
	if quality_roll >= 0.82:
		return 3
	if quality_roll >= 0.56:
		return 2
	if quality_roll >= 0.20:
		return 1
	return 0

static func calculate_meta_scrap_reward(results: Dictionary, bonuses: Dictionary = {}) -> int:
	var score: int = max(0, int(results.get("score", 0)))
	var payout_multiplier: float = float(
		bonuses.get("meta_reward_multiplier", results.get("meta_reward_multiplier", 1.0))
	)
	return max(0, int(round(float(score) * max(payout_multiplier, 1.0))))

static func get_meta_upgrade_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for raw_entry in META_UPGRADES:
		var entry: Dictionary = raw_entry.duplicate(true)
		entry["tier_costs"] = _build_tier_costs(
			int(entry.get("base_cost", 0)),
			float(entry.get("cost_scale", 1.5)),
			int(entry.get("max_tier", 5))
		)
		catalog.append(entry)
	return catalog

static func get_wave_upgrade_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for raw_entry in WAVE_UPGRADES:
		var entry: Dictionary = raw_entry.duplicate(true)
		if str(entry.get("icon", "")).is_empty():
			entry["icon"] = ICON_PREFIX + str(entry.get("id", ""))
		catalog.append(entry)
	return catalog

static func get_meta_upgrade_definition(upgrade_id: String) -> Dictionary:
	for entry in META_UPGRADES:
		if str(entry.get("id", "")) == upgrade_id:
			var copy: Dictionary = entry.duplicate(true)
			copy["tier_costs"] = _build_tier_costs(
				int(copy.get("base_cost", 0)),
				float(copy.get("cost_scale", 1.5)),
				int(copy.get("max_tier", 5))
			)
			return copy
	return {}

static func get_wave_upgrade_definition(upgrade_id: String) -> Dictionary:
	for entry in WAVE_UPGRADES:
		if str(entry.get("id", "")) == upgrade_id:
			var copy: Dictionary = entry.duplicate(true)
			if str(copy.get("icon", "")).is_empty():
				copy["icon"] = ICON_PREFIX + str(copy.get("id", ""))
			return copy
	return {}

static func build_meta_bonuses(meta_levels: Dictionary) -> Dictionary:
	var bonuses: Dictionary = get_base_run_config()
	var levels: Dictionary = meta_levels.duplicate(true)

	var tower_level: int = int(levels.get("tower_fabrication", 0))
	var drone_level: int = int(levels.get("drone_hangar", 0))
	var tentacle_level: int = int(levels.get("tentacle_vat", 0))
	var signal_level: int = int(levels.get("signal_decoder", 0))
	var magnet_level: int = int(levels.get("magnet_array", 0))
	var pierce_level: int = int(levels.get("piercing_rifling", 0))
	var blast_level: int = int(levels.get("blast_chambers", 0))
	var reflector_level: int = int(levels.get("reflector_grid", 0))
	var construction_level: int = int(levels.get("construction_bay", 0))
	var helper_level: int = int(levels.get("escort_wing", 0))
	var collector_level: int = int(levels.get("scrap_foundry", 0))

	bonuses["unlock_towers"] = tower_level > 0
	bonuses["unlock_drones"] = drone_level > 0
	bonuses["unlock_tentacles"] = tentacle_level > 0
	bonuses["unlock_construction"] = construction_level > 0
	bonuses["unlock_helpers"] = helper_level > 0
	bonuses["unlock_collectors"] = collector_level > 0
	bonuses["unlock_reflectors"] = reflector_level > 0
	bonuses["unlock_pierce"] = pierce_level > 0
	bonuses["unlock_blast"] = blast_level > 0
	bonuses["unlock_salvage"] = magnet_level > 0 or int(levels.get("salvage_bays", 0)) > 0 or collector_level > 0
	bonuses["unlock_rare"] = signal_level > 0
	bonuses["rare_offer_unlocks"] = signal_level

	for key_variant in levels.keys():
		var key: String = str(key_variant)
		var level: int = clampi(int(levels[key_variant]), 0, 99)
		if level <= 0:
			continue
		match key:
			"command_armor":
				bonuses["base_health"] += 18.0 * float(level)
			"shield_array":
				bonuses["base_shield"] += 20.0 * float(level)
			"shield_relay":
				bonuses["shield_regen"] += 3.8 * float(level)
				bonuses["shield_regen_delay"] = max(0.8, float(bonuses.get("shield_regen_delay", 2.6)) - 0.18 * float(level))
			"emergency_bulkheads":
				bonuses["damage_reduction"] = min(0.35, float(bonuses.get("damage_reduction", 0.0)) + 0.035 * float(level))
			"repair_crews":
				bonuses["repair_between_waves"] += 12.0 * float(level)
			"damage_uplink":
				bonuses["gun_damage"] += 1.45 * float(level)
			"rapid_loader":
				bonuses["fire_interval"] /= 1.0 + 0.06 * float(level)
			"tracking_array":
				bonuses["bullet_speed"] += 72.0 * float(level)
			"capacitor_bank":
				bonuses["crit_chance"] += 0.03 * float(level)
			"high_energy_cells":
				bonuses["crit_bonus"] += 0.18 * float(level)
			"reserve_nukes":
				bonuses["starting_nukes"] += int((level + 1) / 2)
				bonuses["nuke_max"] += 1 + int(level / 2)
				bonuses["nuke_regen_per_wave"] += int(level / 3)
			"bigger_blasts":
				bonuses["nuke_radius"] *= 1.0 + 0.055 * float(level)
			"fusion_payload":
				bonuses["nuke_damage"] *= 1.0 + 0.10 * float(level)
			"piercing_rifling":
				bonuses["bullet_pierce"] += int(level / 3)
			"blast_chambers":
				bonuses["bullet_blast_damage"] *= 1.0 + 0.10 * float(level)
			"tower_fabrication":
				bonuses["tower_count"] += int(level / 2)
			"tower_targeting":
				bonuses["tower_damage"] *= 1.0 + 0.16 * float(level)
				bonuses["tower_range"] *= 1.0 + 0.05 * float(level)
			"tower_cooling":
				bonuses["tower_fire_interval"] /= 1.0 + 0.09 * float(level)
			"reflector_grid":
				bonuses["projectile_redirect_chance"] = min(0.7, float(bonuses.get("projectile_redirect_chance", 0.0)) + 0.045 * float(level))
			"signal_decoder":
				bonuses["offer_quality_bonus"] += 0.12 * float(level)
			"drone_hangar":
				bonuses["drone_count"] += int(level / 2)
			"drone_ai":
				bonuses["drone_damage"] *= 1.0 + 0.16 * float(level)
			"drone_flight_pack":
				bonuses["drone_fire_interval"] /= 1.0 + 0.08 * float(level)
				bonuses["drone_speed"] *= 1.0 + 0.08 * float(level)
			"magnet_array":
				bonuses["pickup_radius"] += 22.0 * float(level)
			"salvage_bays":
				bonuses["salvage_multiplier"] *= 1.0 + 0.08 * float(level)
			"scrap_ledgers":
				bonuses["meta_reward_multiplier"] *= 1.0 + 0.09 * float(level)
			"contract_bounties":
				bonuses["wave_scrap_bonus"] += 4.5 * float(level)
			"recovery_barges":
				bonuses["wave_auto_bank_ratio"] = min(0.96, float(bonuses.get("wave_auto_bank_ratio", 0.68)) + 0.04 * float(level))
				bonuses["salvage_lifetime"] += 0.7 * float(level)
			"salvage_markets":
				bonuses["salvage_multiplier"] *= 1.0 + 0.06 * float(level)
			"sweep_drones":
				bonuses["pickup_radius"] += 18.0 * float(level)
				bonuses["wave_auto_bank_ratio"] = min(0.98, float(bonuses.get("wave_auto_bank_ratio", 0.68)) + 0.02 * float(level))
			"profit_directive":
				bonuses["meta_reward_multiplier"] *= 1.0 + 0.06 * float(level)
				bonuses["wave_scrap_bonus"] += 3.0 * float(level)
			"threat_analysis":
				bonuses["enemy_count_scale"] *= pow(0.95, float(level))
			"gravitic_dragnet":
				bonuses["enemy_speed_scale"] *= pow(0.955, float(level))
			"signal_jammers":
				bonuses["enemy_projectile_speed_scale"] *= pow(0.95, float(level))
				bonuses["enemy_projectile_damage_scale"] *= pow(0.955, float(level))
			"hunter_killer_doctrine":
				bonuses["heavy_enemy_health_scale"] *= pow(0.91, float(level))
				bonuses["elite_spawn_scale"] *= pow(0.96, float(level))
			"apex_countermeasures":
				bonuses["apex_enemy_health_scale"] *= pow(0.88, float(level))
				bonuses["apex_enemy_damage_scale"] *= pow(0.93, float(level))
			"tentacle_vat":
				bonuses["tentacle_count"] += int(level / 2)
			"tentacle_spines":
				bonuses["tentacle_damage"] *= 1.0 + 0.18 * float(level)
			"tentacle_reach":
				bonuses["tentacle_range"] *= 1.0 + 0.12 * float(level)
				bonuses["tentacle_slow"] += 0.03 * float(level)
			"engineer_crew":
				bonuses["offer_roll_bonus"] += level
			"tactical_briefing":
				bonuses["level_up_choice_count"] = min(6, int(bonuses.get("level_up_choice_count", 3)) + level)
			"overclock_protocol":
				bonuses["upgrade_power_multiplier"] *= 1.0 + 0.08 * float(level)
			"construction_bay":
				bonuses["construction_drone_count"] += level
				bonuses["temporary_turret_limit"] += int(ceil(float(level) * 0.5))
				bonuses["temporary_shield_limit"] += int(ceil(float(level) * 0.5))
			"field_fabricators":
				bonuses["construction_build_rate"] *= 1.0 + 0.12 * float(level)
				bonuses["temporary_turret_duration"] += 2.0 * float(level)
				bonuses["temporary_shield_duration"] += 2.0 * float(level)
			"escort_wing":
				bonuses["helper_drone_count"] += level
			"escort_doctrine":
				bonuses["helper_drone_damage"] *= 1.0 + 0.14 * float(level)
				bonuses["helper_drone_range"] += 24.0 * float(level)
				bonuses["helper_drone_speed"] *= 1.0 + 0.08 * float(level)
			"scrap_foundry":
				bonuses["collector_bot_count"] += level
				bonuses["collector_bot_speed"] *= 1.0 + 0.08 * float(level)
				bonuses["scrap_generation_per_second"] += 0.8 * float(level)
			"choice_matrix":
				bonuses["level_up_choice_count"] = min(9, int(bonuses.get("level_up_choice_count", 3)) + level)
				bonuses["max_level_up_choice_count"] = 9

	var cross_mult: float = CROSS_GAME_BONUSES.get_target_bonus_multiplier(Util.ACTIVE_GAME_RED_SKY)
	bonuses["gun_damage"] *= cross_mult
	bonuses["tower_damage"] *= cross_mult
	bonuses["drone_damage"] *= cross_mult
	bonuses["tentacle_damage"] *= cross_mult
	bonuses["helper_drone_damage"] *= cross_mult
	bonuses["salvage_multiplier"] *= cross_mult
	bonuses["meta_reward_multiplier"] *= cross_mult

	var start_nukes: int = int(bonuses.get("starting_nukes", 1))
	var cap: int = int(bonuses.get("nuke_max", 5))
	bonuses["nuke_max"] = maxi(cap, start_nukes)
	return bonuses

static func can_offer_wave_upgrade(
	upgrade_def: Dictionary,
	current_wave: int,
	wave_upgrade_levels: Dictionary,
	meta_bonuses: Dictionary,
	runtime_flags: Dictionary = {}
) -> bool:
	var upgrade_id: String = str(upgrade_def.get("id", ""))
	var max_stacks: int = max(1, int(upgrade_def.get("max_stacks", 1)))
	if int(wave_upgrade_levels.get(upgrade_id, 0)) >= max_stacks:
		return false
	if current_wave < int(upgrade_def.get("min_wave", 1)):
		return false

	var requirements: Array = upgrade_def.get("requires", [])
	for requirement_variant in requirements:
		var requirement: String = str(requirement_variant)
		match requirement:
			"shield":
				if float(runtime_flags.get("shield_max", meta_bonuses.get("base_shield", 0.0))) <= 0.0:
					return false
			"tower":
				if not bool(meta_bonuses.get("unlock_towers", false)):
					return false
			"drone":
				if not bool(meta_bonuses.get("unlock_drones", false)):
					return false
			"tentacle":
				if not bool(meta_bonuses.get("unlock_tentacles", false)):
					return false
			"construction":
				if not bool(meta_bonuses.get("unlock_construction", false)):
					return false
			"helper":
				if not bool(meta_bonuses.get("unlock_helpers", false)):
					return false
			"collector":
				if not bool(meta_bonuses.get("unlock_collectors", false)):
					return false
			"reflector":
				if not bool(meta_bonuses.get("unlock_reflectors", false)):
					return false
			"pierce":
				if not bool(meta_bonuses.get("unlock_pierce", false)):
					return false
			"blast":
				if not bool(meta_bonuses.get("unlock_blast", false)):
					return false
			"salvage":
				if not bool(meta_bonuses.get("unlock_salvage", false)):
					return false
			"rare":
				if not bool(meta_bonuses.get("unlock_rare", false)):
					return false
	return true

static func get_offer_weight(upgrade_def: Dictionary, wave_upgrade_levels: Dictionary, meta_bonuses: Dictionary) -> float:
	var weight: float = float(upgrade_def.get("weight", 1.0))
	var rarity: int = int(upgrade_def.get("rarity", 0))
	var upgrade_id: String = str(upgrade_def.get("id", ""))
	var stacks: int = int(wave_upgrade_levels.get(upgrade_id, 0))
	weight *= 1.0 / (1.0 + float(stacks) * 0.18)
	weight *= 1.0 + float(meta_bonuses.get("offer_quality_bonus", 0.0)) * float(rarity + 1) * 0.4
	if stacks == 0:
		weight *= 1.0 + float(meta_bonuses.get("offer_roll_bonus", 0)) * 0.04
	return max(weight, 0.01)

static func get_scaled_wave_effects(upgrade_id: String, upgrade_power_multiplier: float, offer_tier: int = 1) -> Dictionary:
	var upgrade_def: Dictionary = get_wave_upgrade_definition(upgrade_id)
	if upgrade_def.is_empty():
		return {"add": {}, "mult": {}}

	var tier_def: Dictionary = get_wave_offer_tier_definition(offer_tier)
	var tier_multiplier: float = float(tier_def.get("multiplier", 1.0))
	var scaled: Dictionary = {"add": {}, "mult": {}}
	var add_effects: Dictionary = upgrade_def.get("effects", {}).get("add", {})
	for key_variant in add_effects.keys():
		var key: String = str(key_variant)
		var base_value: float = float(add_effects[key_variant])
		var scaled_value: float = base_value * tier_multiplier
		if not _should_ignore_power_scaling_for_add(key):
			scaled_value *= upgrade_power_multiplier
		if _should_round_up_additive_effect(key):
			scaled_value = float(_round_up_effect_amount(scaled_value))
		scaled["add"][key] = scaled_value

	var mult_effects: Dictionary = upgrade_def.get("effects", {}).get("mult", {})
	for key_variant in mult_effects.keys():
		var key: String = str(key_variant)
		var base_mult: float = float(mult_effects[key_variant])
		if _should_ignore_power_scaling_for_mult(key):
			scaled["mult"][key] = 1.0 + (base_mult - 1.0) * tier_multiplier
		else:
			scaled["mult"][key] = 1.0 + (base_mult - 1.0) * tier_multiplier * upgrade_power_multiplier
	return scaled

static func get_wave_upgrade_button_text(upgrade_id: String, upgrade_power_multiplier: float, offer_tier: int = 1) -> String:
	var def: Dictionary = get_wave_upgrade_definition(upgrade_id)
	if def.is_empty():
		return TranslationServer.translate("Unknown Upgrade")

	var tier_def: Dictionary = get_wave_offer_tier_definition(offer_tier)
	var scaled_effects: Dictionary = get_scaled_wave_effects(upgrade_id, upgrade_power_multiplier, offer_tier)
	var subtitle := ""
	match upgrade_id:
		"focused_barrels":
			subtitle = TranslationServer.translate("Gun damage +%s") % _format_amount(scaled_effects["add"].get("gun_damage", 0.0), 1)
		"cooling_jackets":
			subtitle = TranslationServer.translate("Fire rate +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("fire_rate", 1.0))
		"seeker_ammo":
			subtitle = TranslationServer.translate("Bullet speed +%s") % _format_amount(scaled_effects["add"].get("bullet_speed", 0.0), 0)
		"armor_patch":
			subtitle = TranslationServer.translate("Hull +%s, repair %s") % [
				_format_amount(scaled_effects["add"].get("base_max_health", 0.0), 0),
				_format_amount(scaled_effects["add"].get("repair", 0.0), 0)
			]
		"shield_boost":
			subtitle = TranslationServer.translate("Shield +%s") % _format_amount(scaled_effects["add"].get("shield_max", 0.0), 0)
		"shield_relay_burst":
			subtitle = TranslationServer.translate("Shield regen +%s") % _format_amount(scaled_effects["add"].get("shield_regen", 0.0), 1)
		"reserve_nuke_pick":
			var rn: Array = _format_count_with_word(scaled_effects["add"].get("nukes", 1.0), "nuke")
			subtitle = TranslationServer.translate("Gain +%s %s, max +%s") % [rn[0], rn[1], _format_amount(scaled_effects["add"].get("nuke_max", 1.0), 0)]
		"fusion_warhead":
			subtitle = TranslationServer.translate("Nuke damage +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("nuke_damage", 1.0))
		"blast_shells":
			subtitle = TranslationServer.translate("Nuke radius +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("nuke_radius", 1.0))
		"piercing_rounds":
			subtitle = TranslationServer.translate("Pierce +%s") % _format_amount(scaled_effects["add"].get("bullet_pierce", 1.0), 0)
		"shrapnel_rounds":
			subtitle = TranslationServer.translate("Impact blast +%s") % _format_amount(scaled_effects["add"].get("bullet_blast_radius", 0.0), 0)
		"capacitor_overdrive":
			subtitle = TranslationServer.translate("Crit chance +%s%%") % _format_percent_from_add(scaled_effects["add"].get("crit_chance", 0.0))
		"critical_mass":
			subtitle = TranslationServer.translate("Crit damage +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("crit_bonus", 1.0))
		"flak_turret":
			subtitle = TranslationServer.translate("Deploy +%s %s") % _format_count_with_word(scaled_effects["add"].get("tower_count", 1.0), "tower")
		"tower_overclock":
			subtitle = TranslationServer.translate("Tower damage +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("tower_damage", 1.0))
		"tower_autoloader":
			subtitle = TranslationServer.translate("Tower fire rate +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("tower_fire_rate", 1.0))
		"interceptor_drone":
			subtitle = TranslationServer.translate("Deploy +%s %s") % _format_count_with_word(scaled_effects["add"].get("drone_count", 1.0), "drone")
		"drone_firmware":
			subtitle = TranslationServer.translate("Drone damage +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("drone_damage", 1.0))
		"drone_afterburners":
			subtitle = TranslationServer.translate("Drone speed +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("drone_speed", 1.0))
		"tentacle_pod":
			subtitle = TranslationServer.translate("Grow +%s %s") % _format_count_with_word(scaled_effects["add"].get("tentacle_count", 1.0), "tentacle")
		"serrated_tentacles":
			subtitle = TranslationServer.translate("Tentacle damage +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("tentacle_damage", 1.0))
		"grasping_reach":
			subtitle = TranslationServer.translate("Tentacle reach +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("tentacle_range", 1.0))
		"reflector_pylon":
			subtitle = TranslationServer.translate("Redirect chance +%s%%") % _format_percent_from_add(scaled_effects["add"].get("projectile_redirect_chance", 0.0))
		"salvage_burst":
			subtitle = TranslationServer.translate("Scrap yield +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("salvage_multiplier", 1.0))
		"magnet_sweep":
			subtitle = TranslationServer.translate("Pickup radius +%s") % _format_amount(scaled_effects["add"].get("pickup_radius", 0.0), 0)
		"bounty_contracts":
			subtitle = TranslationServer.translate("Wave bonus +%s x wave") % _format_amount(scaled_effects["add"].get("wave_scrap_bonus", 0.0), 0)
		"claim_adjusters":
			subtitle = TranslationServer.translate("Auto-bank +%s%%") % _format_percent_from_add(scaled_effects["add"].get("wave_auto_bank_ratio", 0.0))
		"recovery_net":
			subtitle = TranslationServer.translate("Salvage life +%ss") % _format_amount(scaled_effects["add"].get("salvage_lifetime", 0.0), 1)
		"scavenger_grid":
			subtitle = TranslationServer.translate("Yield +%s%%, bank +%s%%") % [
				_format_percent_from_mult(scaled_effects["mult"].get("salvage_multiplier", 1.0)),
				_format_percent_from_add(scaled_effects["add"].get("wave_auto_bank_ratio", 0.0))
			]
		"command_overclock":
			subtitle = TranslationServer.translate("Future picks +%s%%") % _format_percent_from_mult(scaled_effects["mult"].get("upgrade_power_multiplier", 1.0))
		"reinforced_plating":
			subtitle = TranslationServer.translate("Hull +%s, repair %s") % [
				_format_amount(scaled_effects["add"].get("base_max_health", 0.0), 0),
				_format_amount(scaled_effects["add"].get("repair", 0.0), 0)
			]
		"field_repairs":
			subtitle = TranslationServer.translate("Repair +%s") % _format_amount(scaled_effects["add"].get("repair", 0.0), 0)
		"shield_capacitors":
			subtitle = TranslationServer.translate("Shield +%s") % _format_amount(scaled_effects["add"].get("shield_max", 0.0), 0)
		"battery_loop":
			subtitle = TranslationServer.translate("Shield regen +%s, fire rate +%s%%") % [
				_format_amount(scaled_effects["add"].get("shield_regen", 0.0), 1),
				_format_percent_from_mult(scaled_effects["mult"].get("fire_rate", 1.0))
			]
		"ammo_hoppers":
			subtitle = TranslationServer.translate("Gun damage +%s, fire rate +%s%%") % [
				_format_amount(scaled_effects["add"].get("gun_damage", 0.0), 1),
				_format_percent_from_mult(scaled_effects["mult"].get("fire_rate", 1.0))
			]
		"warhead_racks":
			var wr: Array = _format_count_with_word(scaled_effects["add"].get("nukes", 1.0), "nuke")
			subtitle = TranslationServer.translate("Gain +%s %s, +%s/wave, damage +%s%%") % [
				wr[0],
				wr[1],
				_format_amount(scaled_effects["add"].get("nuke_regen_per_wave", 1.0), 0),
				_format_percent_from_mult(scaled_effects["mult"].get("nuke_damage", 1.0))
			]
		"nuke_silo_extension":
			subtitle = TranslationServer.translate("Max stockpile +%s") % _format_amount(scaled_effects["add"].get("nuke_max", 2.0), 0)
		"reactor_rearm_cycle":
			subtitle = TranslationServer.translate("Per-wave regen +%s") % _format_amount(scaled_effects["add"].get("nuke_regen_per_wave", 1.0), 0)
		"flak_wall":
			subtitle = TranslationServer.translate("Deploy +%s %s, tower damage +%s%%") % [
				_format_count_with_word(scaled_effects["add"].get("tower_count", 1.0), "tower")[0],
				_format_count_with_word(scaled_effects["add"].get("tower_count", 1.0), "tower")[1],
				_format_percent_from_mult(scaled_effects["mult"].get("tower_damage", 1.0))
			]
		"tower_rangefinder":
			subtitle = TranslationServer.translate("Tower range +%s, damage +%s%%") % [
				_format_amount(scaled_effects["add"].get("tower_range", 0.0), 0),
				_format_percent_from_mult(scaled_effects["mult"].get("tower_damage", 1.0))
			]
		"drone_swarm":
			subtitle = TranslationServer.translate("Deploy +%s %s, drone fire rate +%s%%") % [
				_format_count_with_word(scaled_effects["add"].get("drone_count", 1.0), "drone")[0],
				_format_count_with_word(scaled_effects["add"].get("drone_count", 1.0), "drone")[1],
				_format_percent_from_mult(scaled_effects["mult"].get("drone_fire_rate", 1.0))
			]
		"hunter_link":
			subtitle = TranslationServer.translate("Drone range +%s, damage +%s%%") % [
				_format_amount(scaled_effects["add"].get("drone_range", 0.0), 0),
				_format_percent_from_mult(scaled_effects["mult"].get("drone_damage", 1.0))
			]
		"brood_nest":
			subtitle = TranslationServer.translate("Grow +%s %s, tentacle damage +%s%%") % [
				_format_count_with_word(scaled_effects["add"].get("tentacle_count", 1.0), "tentacle")[0],
				_format_count_with_word(scaled_effects["add"].get("tentacle_count", 1.0), "tentacle")[1],
				_format_percent_from_mult(scaled_effects["mult"].get("tentacle_damage", 1.0))
			]
		"tendon_network":
			subtitle = TranslationServer.translate("Tentacle reach +%s%%, slow +%s%%") % [
				_format_percent_from_mult(scaled_effects["mult"].get("tentacle_range", 1.0)),
				_format_percent_from_add(scaled_effects["add"].get("tentacle_slow", 0.0))
			]
		"salvage_convoys":
			subtitle = TranslationServer.translate("Yield +%s%%, wave bonus +%s x wave") % [
				_format_percent_from_mult(scaled_effects["mult"].get("salvage_multiplier", 1.0)),
				_format_amount(scaled_effects["add"].get("wave_scrap_bonus", 0.0), 0)
			]
		"magnetic_funnels":
			subtitle = TranslationServer.translate("Pickup radius +%s, bank +%s%%") % [
				_format_amount(scaled_effects["add"].get("pickup_radius", 0.0), 0),
				_format_percent_from_add(scaled_effects["add"].get("wave_auto_bank_ratio", 0.0))
			]
		"command_node":
			subtitle = TranslationServer.translate("Future choice count +%s") % _format_amount(scaled_effects["add"].get("level_up_choice_count", 0.0), 0)
		"refinement_protocols":
			subtitle = TranslationServer.translate("Future picks +%s%%, yield +%s%%") % [
				_format_percent_from_mult(scaled_effects["mult"].get("upgrade_power_multiplier", 1.0)),
				_format_percent_from_mult(scaled_effects["mult"].get("salvage_multiplier", 1.0))
			]
		"traffic_control":
			subtitle = TranslationServer.translate("Future enemy count %s%%") % _format_percent_from_mult(scaled_effects["mult"].get("enemy_count_scale", 1.0))
		"gravity_well":
			subtitle = TranslationServer.translate("Enemy speed %s%%") % _format_percent_from_mult(scaled_effects["mult"].get("enemy_speed_scale", 1.0))
		"counterbattery_jammers":
			subtitle = TranslationServer.translate("Shot speed %s%%, shot damage %s%%") % [
				_format_percent_from_mult(scaled_effects["mult"].get("enemy_projectile_speed_scale", 1.0)),
				_format_percent_from_mult(scaled_effects["mult"].get("enemy_projectile_damage_scale", 1.0))
			]
		"elite_kill_orders":
			subtitle = TranslationServer.translate("Elite count %s%%, elite hull %s%%") % [
				_format_percent_from_mult(scaled_effects["mult"].get("elite_spawn_scale", 1.0)),
				_format_percent_from_mult(scaled_effects["mult"].get("heavy_enemy_health_scale", 1.0))
			]
		"boss_breakers":
			subtitle = TranslationServer.translate("Boss hull %s%%, boss damage %s%%") % [
				_format_percent_from_mult(scaled_effects["mult"].get("apex_enemy_health_scale", 1.0)),
				_format_percent_from_mult(scaled_effects["mult"].get("apex_enemy_damage_scale", 1.0))
			]
		"constructor_drone":
			subtitle = TranslationServer.translate("Deploy +%s %s") % _format_count_with_word(scaled_effects["add"].get("construction_drone_count", 1.0), "constructor")
		"field_turret_blueprints":
			subtitle = TranslationServer.translate("Temp turret cap +%s, damage +%s%%") % [
				_format_amount(scaled_effects["add"].get("temporary_turret_limit", 1.0), 0),
				_format_percent_from_mult(scaled_effects["mult"].get("temporary_turret_damage", 1.0))
			]
		"shield_emitter_blueprints":
			subtitle = TranslationServer.translate("Temp shield cap +%s, capacity +%s") % [
				_format_amount(scaled_effects["add"].get("temporary_shield_limit", 1.0), 0),
				_format_amount(scaled_effects["add"].get("temporary_shield_capacity", 0.0), 0)
			]
		"rapid_fabrication":
			subtitle = TranslationServer.translate("Build speed +%s%%, duration +%ss") % [
				_format_percent_from_mult(scaled_effects["mult"].get("construction_build_rate", 1.0)),
				_format_amount(scaled_effects["add"].get("temporary_turret_duration", 0.0), 1)
			]
		"escort_drone":
			subtitle = TranslationServer.translate("Deploy +%s %s") % _format_count_with_word(scaled_effects["add"].get("helper_drone_count", 1.0), "escort")
		"escort_targeting":
			subtitle = TranslationServer.translate("Helper range +%s, damage +%s%%") % [
				_format_amount(scaled_effects["add"].get("helper_drone_range", 0.0), 0),
				_format_percent_from_mult(scaled_effects["mult"].get("helper_drone_damage", 1.0))
			]
		"escort_thrusters":
			subtitle = TranslationServer.translate("Helper speed +%s%%, fire rate +%s%%") % [
				_format_percent_from_mult(scaled_effects["mult"].get("helper_drone_speed", 1.0)),
				_format_percent_from_mult(scaled_effects["mult"].get("helper_drone_fire_rate", 1.0))
			]
		"collector_bots":
			subtitle = TranslationServer.translate("Deploy +%s %s") % _format_count_with_word(scaled_effects["add"].get("collector_bot_count", 1.0), "collector")
		"collector_thrusters":
			subtitle = TranslationServer.translate("Collector speed +%s%%, pickup radius +%s") % [
				_format_percent_from_mult(scaled_effects["mult"].get("collector_bot_speed", 1.0)),
				_format_amount(scaled_effects["add"].get("pickup_radius", 0.0), 0)
			]
		"scrap_printers":
			subtitle = TranslationServer.translate("Passive scrap +%s/s") % _format_amount(scaled_effects["add"].get("scrap_generation_per_second", 0.0), 1)
		"choice_array":
			subtitle = TranslationServer.translate("Future choice count +%s") % _format_amount(scaled_effects["add"].get("level_up_choice_count", 0.0), 0)
		"fox_seeker_salvo":
			subtitle = TranslationServer.translate("Homing missile tier +%s") % _format_amount(scaled_effects["add"].get("homing_missile_level", 1.0), 0)
		"polarized_weave":
			subtitle = TranslationServer.translate("Countermeasures rating +%s") % _format_amount(scaled_effects["add"].get("countermeasures_rating", 0.07), 2)
		_:
			subtitle = TranslationServer.translate(str(def.get("summary", "Battlefield bonus")))
	var summary: String = TranslationServer.translate(str(def.get("summary", ""))).strip_edges()
	var detail_line := ""
	if summary.is_empty():
		detail_line = subtitle
	elif subtitle.is_empty():
		detail_line = summary
	else:
		detail_line = TranslationServer.translate("%s %s") % [summary, subtitle]
	var lines := PackedStringArray()
	if offer_tier >= 2:
		lines.append(TranslationServer.translate(str(tier_def.get("label", ""))))
	lines.append(TranslationServer.translate(str(def.get("label", upgrade_id))))
	if not detail_line.is_empty():
		lines.append(detail_line)
	return "\n".join(lines)

static func _build_tier_costs(base_cost: int, cost_scale: float, max_tier: int) -> Array:
	var costs: Array = []
	var running_cost: float = float(base_cost) * META_COST_MULTIPLIER
	for tier in range(max_tier):
		if tier == 0:
			running_cost = float(base_cost) * META_COST_MULTIPLIER
		else:
			running_cost *= cost_scale
		var tier_cost: float = running_cost
		if tier == 0:
			tier_cost *= META_FIRST_TIER_DISCOUNT
		costs.append(int(round(tier_cost)))
	return costs

static func _should_ignore_power_scaling_for_add(key: String) -> bool:
	return key in [
		"nukes",
		"nuke_max",
		"nuke_regen_per_wave",
		"bullet_pierce",
		"tower_count",
		"drone_count",
		"tentacle_count",
		"construction_drone_count",
		"temporary_turret_limit",
		"temporary_shield_limit",
		"helper_drone_count",
		"collector_bot_count",
		"level_up_choice_count",
		"homing_missile_level"
	]

static func _should_round_up_additive_effect(key: String) -> bool:
	return key in [
		"nukes",
		"nuke_max",
		"nuke_regen_per_wave",
		"bullet_pierce",
		"tower_count",
		"drone_count",
		"tentacle_count",
		"construction_drone_count",
		"temporary_turret_limit",
		"temporary_shield_limit",
		"helper_drone_count",
		"collector_bot_count",
		"homing_missile_level"
	]

static func _should_ignore_power_scaling_for_mult(key: String) -> bool:
	return key == "upgrade_power_multiplier"

static func _round_up_effect_amount(value: float) -> int:
	if value <= 0.0:
		return int(round(value))
	return maxi(1, int(ceil(value - 0.0001)))

static func _format_amount(value: Variant, decimals: int) -> String:
	var numeric: float = float(value)
	if decimals <= 0:
		return str(int(round(numeric)))
	return str(snappedf(numeric, 0.1))

static func _format_count_with_word(value: Variant, singular_word: String) -> Array:
	var amount: int = _round_up_effect_amount(float(value))
	var word: String = TranslationServer.translate(singular_word if amount == 1 else "%ss" % singular_word)
	return [str(amount), word]

static func _format_percent_from_add(value: Variant) -> String:
	return str(int(round(float(value) * 100.0)))

static func _format_percent_from_mult(value: Variant) -> String:
	return str(int(round((float(value) - 1.0) * 100.0)))
