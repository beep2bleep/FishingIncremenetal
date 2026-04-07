extends RefCounted
class_name RedSkyData

const ICON_PREFIX := "redsky://"
const META_COST_MULTIPLIER := 0.68
const META_FIRST_TIER_DISCOUNT := 0.82
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
	"starting_nukes": 2,
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
	"projectile_redirect_chance": 0.0,
	"upgrade_power_multiplier": 1.0,
	"offer_quality_bonus": 0.0,
	"offer_roll_bonus": 0,
	"level_up_choice_count": 3,
	"rare_offer_unlocks": 0,
	"unlock_towers": false,
	"unlock_drones": false,
	"unlock_tentacles": false,
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
		"summary": "Start with extra ordnance so emergencies do not end the run.",
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
]

const WAVE_UPGRADES: Array[Dictionary] = [
	{
		"id": "focused_barrels",
		"label": "Focused Barrels",
		"summary": "Main gun damage up.",
		"weight": 1.25,
		"rarity": 0,
		"max_stacks": 12,
		"requires": [],
		"effects": {"add": {"gun_damage": 3.5}, "mult": {}}
	},
	{
		"id": "cooling_jackets",
		"label": "Cooling Jackets",
		"summary": "Fire faster.",
		"weight": 1.2,
		"rarity": 0,
		"max_stacks": 10,
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
		"max_stacks": 10,
		"requires": [],
		"effects": {"add": {"base_max_health": 18.0, "repair": 24.0}, "mult": {}}
	},
	{
		"id": "shield_boost",
		"label": "Shield Boost",
		"summary": "More shield capacity right now.",
		"weight": 1.0,
		"rarity": 0,
		"max_stacks": 8,
		"requires": ["shield"],
		"effects": {"add": {"shield_max": 22.0, "shield_fill": 22.0}, "mult": {}}
	},
	{
		"id": "shield_relay_burst",
		"label": "Shield Relay",
		"summary": "Shields recover faster.",
		"weight": 0.95,
		"rarity": 1,
		"max_stacks": 8,
		"requires": ["shield"],
		"effects": {"add": {"shield_regen": 3.5}, "mult": {}}
	},
	{
		"id": "reserve_nuke_pick",
		"label": "Reserve Nuke",
		"summary": "Add one nuke to the stockpile.",
		"weight": 0.76,
		"rarity": 1,
		"max_stacks": 6,
		"requires": [],
		"effects": {"add": {"nukes": 1.0}, "mult": {}}
	},
	{
		"id": "fusion_warhead",
		"label": "Fusion Warhead",
		"summary": "Nukes hit harder.",
		"weight": 0.78,
		"rarity": 1,
		"max_stacks": 6,
		"requires": [],
		"effects": {"add": {}, "mult": {"nuke_damage": 1.18}}
	},
	{
		"id": "blast_shells",
		"label": "Blast Shells",
		"summary": "Nukes cover more ground.",
		"weight": 0.78,
		"rarity": 1,
		"max_stacks": 6,
		"requires": [],
		"effects": {"add": {}, "mult": {"nuke_radius": 1.14}}
	},
	{
		"id": "piercing_rounds",
		"label": "Piercing Rounds",
		"summary": "Shots punch through one more target.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 5,
		"requires": ["pierce"],
		"effects": {"add": {"bullet_pierce": 1.0}, "mult": {}}
	},
	{
		"id": "shrapnel_rounds",
		"label": "Shrapnel Rounds",
		"summary": "Shots gain a small blast on impact.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["blast"],
		"effects": {"add": {"bullet_blast_radius": 18.0}, "mult": {"bullet_blast_damage": 1.12}}
	},
	{
		"id": "capacitor_overdrive",
		"label": "Capacitor Overdrive",
		"summary": "Critical chance up.",
		"weight": 0.96,
		"rarity": 1,
		"max_stacks": 6,
		"requires": [],
		"effects": {"add": {"crit_chance": 0.05}, "mult": {}}
	},
	{
		"id": "critical_mass",
		"label": "Critical Mass",
		"summary": "Critical hits deal more damage.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 6,
		"requires": [],
		"effects": {"add": {}, "mult": {"crit_bonus": 1.18}}
	},
	{
		"id": "flak_turret",
		"label": "Flak Turret",
		"summary": "Add one defensive tower.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 4,
		"requires": ["tower"],
		"effects": {"add": {"tower_count": 1.0}, "mult": {}}
	},
	{
		"id": "tower_overclock",
		"label": "Tower Overclock",
		"summary": "Tower damage up.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["tower"],
		"effects": {"add": {}, "mult": {"tower_damage": 1.22}}
	},
	{
		"id": "tower_autoloader",
		"label": "Tower Autoloader",
		"summary": "Towers fire faster.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["tower"],
		"effects": {"add": {}, "mult": {"tower_fire_rate": 1.14}}
	},
	{
		"id": "interceptor_drone",
		"label": "Interceptor Drone",
		"summary": "Add one support drone.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 4,
		"requires": ["drone"],
		"effects": {"add": {"drone_count": 1.0}, "mult": {}}
	},
	{
		"id": "drone_firmware",
		"label": "Drone Firmware",
		"summary": "Drone damage up.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["drone"],
		"effects": {"add": {}, "mult": {"drone_damage": 1.18}}
	},
	{
		"id": "drone_afterburners",
		"label": "Drone Afterburners",
		"summary": "Drones move and cycle faster.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["drone"],
		"effects": {"add": {}, "mult": {"drone_fire_rate": 1.12, "drone_speed": 1.12}}
	},
	{
		"id": "tentacle_pod",
		"label": "Tentacle Pod",
		"summary": "Add one biomass guardian.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 4,
		"requires": ["tentacle"],
		"effects": {"add": {"tentacle_count": 1.0}, "mult": {}}
	},
	{
		"id": "serrated_tentacles",
		"label": "Serrated Tentacles",
		"summary": "Tentacles hit harder.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["tentacle"],
		"effects": {"add": {}, "mult": {"tentacle_damage": 1.22}}
	},
	{
		"id": "grasping_reach",
		"label": "Grasping Reach",
		"summary": "Tentacles reach farther and slow more.",
		"weight": 0.88,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["tentacle"],
		"effects": {"add": {"tentacle_slow": 0.04}, "mult": {"tentacle_range": 1.12}}
	},
	{
		"id": "reflector_pylon",
		"label": "Reflector Pylon",
		"summary": "Better odds to redirect incoming projectiles.",
		"weight": 0.72,
		"rarity": 2,
		"max_stacks": 6,
		"requires": ["reflector"],
		"effects": {"add": {"projectile_redirect_chance": 0.07}, "mult": {}}
	},
	{
		"id": "salvage_burst",
		"label": "Salvage Burst",
		"summary": "Enemies spill more scrap.",
		"weight": 0.86,
		"rarity": 1,
		"max_stacks": 8,
		"requires": ["salvage"],
		"effects": {"add": {}, "mult": {"salvage_multiplier": 1.18}}
	},
	{
		"id": "magnet_sweep",
		"label": "Magnet Sweep",
		"summary": "Pickups collect from farther away.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["salvage"],
		"effects": {"add": {"pickup_radius": 20.0}, "mult": {}}
	},
	{
		"id": "command_overclock",
		"label": "Command Overclock",
		"summary": "Future wave upgrades become slightly stronger.",
		"weight": 0.62,
		"rarity": 2,
		"max_stacks": 5,
		"requires": ["rare"],
		"effects": {"add": {}, "mult": {"upgrade_power_multiplier": 1.07}}
	},
	{
		"id": "bounty_contracts",
		"label": "Bounty Contracts",
		"summary": "Each cleared wave pays bonus scrap.",
		"weight": 0.82,
		"rarity": 1,
		"max_stacks": 6,
		"requires": ["salvage"],
		"effects": {"add": {"wave_scrap_bonus": 4.0}, "mult": {}}
	},
	{
		"id": "claim_adjusters",
		"label": "Claim Adjusters",
		"summary": "More leftover salvage auto-banks between waves.",
		"weight": 0.74,
		"rarity": 1,
		"max_stacks": 5,
		"requires": ["salvage"],
		"effects": {"add": {"wave_auto_bank_ratio": 0.06}, "mult": {}}
	},
	{
		"id": "recovery_net",
		"label": "Recovery Net",
		"summary": "Salvage lingers longer before it fades.",
		"weight": 0.72,
		"rarity": 1,
		"max_stacks": 5,
		"requires": ["salvage"],
		"effects": {"add": {"salvage_lifetime": 1.25}, "mult": {}}
	},
	{
		"id": "scavenger_grid",
		"label": "Scavenger Grid",
		"summary": "Scrap pulls harder and cashes out better.",
		"weight": 0.64,
		"rarity": 2,
		"max_stacks": 5,
		"requires": ["salvage", "rare"],
		"effects": {"add": {"pickup_radius": 14.0, "wave_auto_bank_ratio": 0.03}, "mult": {"salvage_multiplier": 1.08}}
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

	bonuses["unlock_towers"] = tower_level > 0
	bonuses["unlock_drones"] = drone_level > 0
	bonuses["unlock_tentacles"] = tentacle_level > 0
	bonuses["unlock_reflectors"] = reflector_level > 0
	bonuses["unlock_pierce"] = pierce_level > 0
	bonuses["unlock_blast"] = blast_level > 0
	bonuses["unlock_salvage"] = magnet_level > 0 or int(levels.get("salvage_bays", 0)) > 0
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
		return "Unknown Upgrade"

	var tier_def: Dictionary = get_wave_offer_tier_definition(offer_tier)
	var scaled_effects: Dictionary = get_scaled_wave_effects(upgrade_id, upgrade_power_multiplier, offer_tier)
	var subtitle := ""
	match upgrade_id:
		"focused_barrels":
			subtitle = "Gun damage +%s" % _format_amount(scaled_effects["add"].get("gun_damage", 0.0), 1)
		"cooling_jackets":
			subtitle = "Fire rate +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("fire_rate", 1.0))
		"seeker_ammo":
			subtitle = "Bullet speed +%s" % _format_amount(scaled_effects["add"].get("bullet_speed", 0.0), 0)
		"armor_patch":
			subtitle = "Hull +%s, repair %s" % [
				_format_amount(scaled_effects["add"].get("base_max_health", 0.0), 0),
				_format_amount(scaled_effects["add"].get("repair", 0.0), 0)
			]
		"shield_boost":
			subtitle = "Shield +%s" % _format_amount(scaled_effects["add"].get("shield_max", 0.0), 0)
		"shield_relay_burst":
			subtitle = "Shield regen +%s" % _format_amount(scaled_effects["add"].get("shield_regen", 0.0), 1)
		"reserve_nuke_pick":
			subtitle = "Gain +%s %s" % _format_count_with_word(scaled_effects["add"].get("nukes", 1.0), "nuke")
		"fusion_warhead":
			subtitle = "Nuke damage +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("nuke_damage", 1.0))
		"blast_shells":
			subtitle = "Nuke radius +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("nuke_radius", 1.0))
		"piercing_rounds":
			subtitle = "Pierce +%s" % _format_amount(scaled_effects["add"].get("bullet_pierce", 1.0), 0)
		"shrapnel_rounds":
			subtitle = "Impact blast +%s" % _format_amount(scaled_effects["add"].get("bullet_blast_radius", 0.0), 0)
		"capacitor_overdrive":
			subtitle = "Crit chance +%s%%" % _format_percent_from_add(scaled_effects["add"].get("crit_chance", 0.0))
		"critical_mass":
			subtitle = "Crit damage +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("crit_bonus", 1.0))
		"flak_turret":
			subtitle = "Deploy +%s %s" % _format_count_with_word(scaled_effects["add"].get("tower_count", 1.0), "tower")
		"tower_overclock":
			subtitle = "Tower damage +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("tower_damage", 1.0))
		"tower_autoloader":
			subtitle = "Tower fire rate +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("tower_fire_rate", 1.0))
		"interceptor_drone":
			subtitle = "Deploy +%s %s" % _format_count_with_word(scaled_effects["add"].get("drone_count", 1.0), "drone")
		"drone_firmware":
			subtitle = "Drone damage +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("drone_damage", 1.0))
		"drone_afterburners":
			subtitle = "Drone speed +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("drone_speed", 1.0))
		"tentacle_pod":
			subtitle = "Grow +%s %s" % _format_count_with_word(scaled_effects["add"].get("tentacle_count", 1.0), "tentacle")
		"serrated_tentacles":
			subtitle = "Tentacle damage +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("tentacle_damage", 1.0))
		"grasping_reach":
			subtitle = "Tentacle reach +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("tentacle_range", 1.0))
		"reflector_pylon":
			subtitle = "Redirect chance +%s%%" % _format_percent_from_add(scaled_effects["add"].get("projectile_redirect_chance", 0.0))
		"salvage_burst":
			subtitle = "Scrap yield +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("salvage_multiplier", 1.0))
		"magnet_sweep":
			subtitle = "Pickup radius +%s" % _format_amount(scaled_effects["add"].get("pickup_radius", 0.0), 0)
		"bounty_contracts":
			subtitle = "Wave bonus +%s x wave" % _format_amount(scaled_effects["add"].get("wave_scrap_bonus", 0.0), 0)
		"claim_adjusters":
			subtitle = "Auto-bank +%s%%" % _format_percent_from_add(scaled_effects["add"].get("wave_auto_bank_ratio", 0.0))
		"recovery_net":
			subtitle = "Salvage life +%ss" % _format_amount(scaled_effects["add"].get("salvage_lifetime", 0.0), 1)
		"scavenger_grid":
			subtitle = "Yield +%s%%, bank +%s%%" % [
				_format_percent_from_mult(scaled_effects["mult"].get("salvage_multiplier", 1.0)),
				_format_percent_from_add(scaled_effects["add"].get("wave_auto_bank_ratio", 0.0))
			]
		"command_overclock":
			subtitle = "Future picks +%s%%" % _format_percent_from_mult(scaled_effects["mult"].get("upgrade_power_multiplier", 1.0))
		_:
			subtitle = str(def.get("summary", "Battlefield bonus"))
	var summary: String = str(def.get("summary", "")).strip_edges()
	var detail_line := ""
	if summary.is_empty():
		detail_line = subtitle
	elif subtitle.is_empty():
		detail_line = summary
	else:
		detail_line = "%s %s" % [summary, subtitle]
	var lines := PackedStringArray()
	if offer_tier >= 2:
		lines.append(str(tier_def.get("label", "")))
	lines.append(str(def.get("label", upgrade_id)))
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
		"bullet_pierce",
		"tower_count",
		"drone_count",
		"tentacle_count"
	]

static func _should_round_up_additive_effect(key: String) -> bool:
	return key in [
		"nukes",
		"bullet_pierce",
		"tower_count",
		"drone_count",
		"tentacle_count"
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
	var word: String = singular_word if amount == 1 else "%ss" % singular_word
	return [str(amount), word]

static func _format_percent_from_add(value: Variant) -> String:
	return str(int(round(float(value) * 100.0)))

static func _format_percent_from_mult(value: Variant) -> String:
	return str(int(round((float(value) - 1.0) * 100.0)))
