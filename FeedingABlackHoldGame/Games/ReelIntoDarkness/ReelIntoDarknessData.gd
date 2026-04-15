extends RefCounted
class_name ReelIntoDarknessData

const CROSS_GAME_BONUSES := preload("res://CrossGameBonuses.gd")
const MODE_TITLE := "Reel Into Darkness"
const STARTING_WALLET := 0
const ICON_PREFIX := "reel://"
## Demo: lock meta nodes past this `step` on each branch. Step 1-N stay buyable; step N+1+ show the demo lock.
const DEMO_MAX_META_STEP_DEFAULT := 3

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
    {
        "id": "gloom_tuna",
        "name": "Gloom Tuna",
        "min_depth": 106.0,
        "max_depth": 150.0,
        "stamina": 108.0,
        "value": 340,
        "size": Vector2(94.0, 30.0),
        "color": Color(0.22, 0.38, 0.5, 1.0),
        "accent": Color(0.74, 0.92, 0.98, 1.0),
        "speed": 25.0,
        "weight": 0.86,
    },
    {
        "id": "rift_ray",
        "name": "Rift Ray",
        "min_depth": 138.0,
        "max_depth": 192.0,
        "stamina": 156.0,
        "value": 520,
        "size": Vector2(108.0, 40.0),
        "color": Color(0.34, 0.2, 0.42, 1.0),
        "accent": Color(0.88, 0.74, 0.96, 1.0),
        "speed": 22.0,
        "weight": 0.68,
    },
    {
        "id": "grave_cod",
        "name": "Grave Cod",
        "min_depth": 176.0,
        "max_depth": 236.0,
        "stamina": 220.0,
        "value": 820,
        "size": Vector2(118.0, 34.0),
        "color": Color(0.24, 0.3, 0.38, 1.0),
        "accent": Color(0.72, 0.84, 0.92, 1.0),
        "speed": 20.0,
        "weight": 0.5,
    },
    {
        "id": "comet_marlin",
        "name": "Comet Marlin",
        "min_depth": 222.0,
        "max_depth": 294.0,
        "stamina": 308.0,
        "value": 1240,
        "size": Vector2(132.0, 28.0),
        "color": Color(0.12, 0.18, 0.34, 1.0),
        "accent": Color(0.98, 0.68, 0.34, 1.0),
        "speed": 30.0,
        "weight": 0.34,
    },
    {
        "id": "leviathan_idol",
        "name": "Leviathan Idol",
        "min_depth": 280.0,
        "max_depth": 362.0,
        "stamina": 430.0,
        "value": 1860,
        "size": Vector2(148.0, 48.0),
        "color": Color(0.08, 0.16, 0.28, 1.0),
        "accent": Color(0.94, 0.82, 0.52, 1.0),
        "speed": 18.0,
        "weight": 0.2,
    },
    {
        "id": "blackwater_kraken",
        "name": "Blackwater Kraken",
        "min_depth": 346.0,
        "max_depth": 430.0,
        "stamina": 580.0,
        "value": 2800,
        "size": Vector2(164.0, 56.0),
        "color": Color(0.05, 0.08, 0.14, 1.0),
        "accent": Color(0.72, 0.94, 0.98, 1.0),
        "speed": 16.0,
        "weight": 0.12,
    },
    {
        "id": "glass_krill",
        "name": "Glass Krill",
        "min_depth": 2.0,
        "max_depth": 160.0,
        "stamina": 1.0,
        "value": 3,
        "size": Vector2(14.0, 8.0),
        "color": Color(0.72, 0.88, 0.96, 0.85),
        "accent": Color(0.94, 0.98, 1.0, 1.0),
        "speed": 22.0,
        "weight": 0.35,
        "automation_only": true,
        "automation_weight": 1.35,
    },
    {
        "id": "tide_mite",
        "name": "Tide Mite",
        "min_depth": 1.0,
        "max_depth": 90.0,
        "stamina": 1.0,
        "value": 2,
        "size": Vector2(12.0, 7.0),
        "color": Color(0.55, 0.62, 0.7, 1.0),
        "accent": Color(0.88, 0.9, 0.95, 1.0),
        "speed": 18.0,
        "weight": 0.4,
        "automation_only": true,
        "automation_weight": 1.1,
    },
    {
        "id": "tin_hand_crab",
        "name": "Tin-Hand Crab",
        "min_depth": 6.0,
        "max_depth": 220.0,
        "stamina": 2.0,
        "value": 12,
        "size": Vector2(26.0, 18.0),
        "color": Color(0.42, 0.36, 0.32, 1.0),
        "accent": Color(0.92, 0.72, 0.48, 1.0),
        "speed": 12.0,
        "weight": 0.55,
        "automation_only": true,
        "automation_weight": 0.95,
    },
    {
        "id": "bloom_shrimp",
        "name": "Bloom Shrimp",
        "min_depth": 12.0,
        "max_depth": 280.0,
        "stamina": 2.0,
        "value": 9,
        "size": Vector2(22.0, 12.0),
        "color": Color(0.88, 0.52, 0.62, 1.0),
        "accent": Color(1.0, 0.86, 0.9, 1.0),
        "speed": 16.0,
        "weight": 0.5,
        "automation_only": true,
        "automation_weight": 0.85,
    },
    {
        "id": "midwater_copepod",
        "name": "Midwater Copepod",
        "min_depth": 24.0,
        "max_depth": 340.0,
        "stamina": 1.0,
        "value": 5,
        "size": Vector2(10.0, 6.0),
        "color": Color(0.58, 0.7, 0.82, 1.0),
        "accent": Color(0.9, 0.95, 1.0, 1.0),
        "speed": 20.0,
        "weight": 0.42,
        "automation_only": true,
        "automation_weight": 0.75,
    },
]

const META_UPGRADES: Array[Dictionary] = [
    {"id": "deck_clock", "label": "Deck Clock", "summary": "Adds a few extra seconds before the boat calls the line home.", "icon": "T", "act": 1, "cell": Vector2(-12, -1), "dependency": "", "branch": 1, "step": 1, "base_cost": 14, "cost_scale": 1.36, "max_tier": 6},
    {"id": "night_watch", "label": "Night Watch", "summary": "Stretches each run so you can safely finish one more fish fight.", "icon": "T", "act": 1, "cell": Vector2(-11, -2), "dependency": "deck_clock", "branch": 1, "step": 2, "base_cost": 22, "cost_scale": 1.38, "max_tier": 5},
    {"id": "tide_almanac", "label": "Tide Almanac", "summary": "Longer hunting windows and steadier late-run pressure.", "icon": "T", "act": 1, "cell": Vector2(-10, -3), "dependency": "night_watch", "branch": 1, "step": 3, "base_cost": 36, "cost_scale": 1.42, "max_tier": 5},
    {"id": "midnight_coffee", "label": "Midnight Coffee", "summary": "Keeps the crew sharp enough to squeeze another cycle out of the night.", "icon": "T", "act": 1, "cell": Vector2(-9, -4), "dependency": "tide_almanac", "branch": 1, "step": 4, "base_cost": 54, "cost_scale": 1.45, "max_tier": 5},
    {"id": "storm_glass", "label": "Storm Glass", "summary": "Reads the black water early so you can linger in the richest patches longer.", "icon": "T", "act": 1, "cell": Vector2(-8, -5), "dependency": "midnight_coffee", "branch": 1, "step": 5, "base_cost": 78, "cost_scale": 1.48, "max_tier": 4},

    {"id": "angler_grit", "label": "Angler Grit", "summary": "More personal stamina so you can survive mistakes and land tougher fish.", "icon": "S", "act": 2, "cell": Vector2(-10, 2), "dependency": "", "branch": 2, "step": 1, "base_cost": 16, "cost_scale": 1.36, "max_tier": 6},
    {"id": "shoulder_harness", "label": "Shoulder Harness", "summary": "Less strain per clean pull and more control during long fights.", "icon": "S", "act": 2, "cell": Vector2(-9, 1), "dependency": "angler_grit", "branch": 2, "step": 2, "base_cost": 26, "cost_scale": 1.4, "max_tier": 5},
    {"id": "counterweight_reel", "label": "Counterweight Reel", "summary": "Turns correct holds into much stronger upward progress.", "icon": "S", "act": 2, "cell": Vector2(-8, 0), "dependency": "shoulder_harness", "branch": 2, "step": 3, "base_cost": 42, "cost_scale": 1.44, "max_tier": 5},
    {"id": "drag_grease", "label": "Drag Grease", "summary": "Smooths reel friction so every clean beat spends less effort and gains more lift.", "icon": "S", "act": 2, "cell": Vector2(-7, -1), "dependency": "counterweight_reel", "branch": 2, "step": 4, "base_cost": 64, "cost_scale": 1.47, "max_tier": 5},
    {"id": "deck_medic", "label": "Deck Medic", "summary": "Bandages, braces, and breathing rhythm keep long fights from snowballing out of control.", "icon": "S", "act": 2, "cell": Vector2(-6, -2), "dependency": "drag_grease", "branch": 2, "step": 5, "base_cost": 92, "cost_scale": 1.5, "max_tier": 4},

    {"id": "lead_sinkers", "label": "Lead Sinkers", "summary": "Lets the line reach deeper fish before the current slows you down.", "icon": "D", "act": 3, "cell": Vector2(-5, 5), "dependency": "", "branch": 3, "step": 1, "base_cost": 18, "cost_scale": 1.38, "max_tier": 6},
    {"id": "deep_charts", "label": "Deep Charts", "summary": "Pushes your safe fishing depth into darker water bands.", "icon": "D", "act": 3, "cell": Vector2(-4, 4), "dependency": "lead_sinkers", "branch": 3, "step": 2, "base_cost": 30, "cost_scale": 1.42, "max_tier": 5},
    {"id": "abyss_permits", "label": "Abyss Permits", "summary": "Opens the brutal late-water layers where the real money hides.", "icon": "D", "act": 3, "cell": Vector2(-3, 3), "dependency": "deep_charts", "branch": 3, "step": 3, "base_cost": 52, "cost_scale": 1.46, "max_tier": 5},
    {"id": "trench_winch", "label": "Trench Winch", "summary": "Upgrades the reel drum so heavy line can still move quickly in deep water.", "icon": "D", "act": 3, "cell": Vector2(-2, 2), "dependency": "abyss_permits", "branch": 3, "step": 4, "base_cost": 80, "cost_scale": 1.5, "max_tier": 5},
    {"id": "hadal_licenses", "label": "Hadal Licenses", "summary": "Signs off on extreme-depth runs where almost nothing survives but the payout does.", "icon": "D", "act": 3, "cell": Vector2(-1, 1), "dependency": "trench_winch", "branch": 3, "step": 5, "base_cost": 118, "cost_scale": 1.53, "max_tier": 4},

    {"id": "braided_line", "label": "Braided Line", "summary": "Improves side-to-side control when the hook swings under the boat.", "icon": "L", "act": 4, "cell": Vector2(1, 3), "dependency": "", "branch": 4, "step": 1, "base_cost": 18, "cost_scale": 1.36, "max_tier": 6},
    {"id": "pendulum_guide", "label": "Pendulum Guide", "summary": "Transfers your mouse movement into cleaner hook momentum.", "icon": "L", "act": 4, "cell": Vector2(2, 2), "dependency": "braided_line", "branch": 4, "step": 2, "base_cost": 30, "cost_scale": 1.4, "max_tier": 5},
    {"id": "keel_stabilizer", "label": "Keel Stabilizer", "summary": "Shrinks the punishment on bad inputs and keeps the boat calmer.", "icon": "L", "act": 4, "cell": Vector2(3, 1), "dependency": "pendulum_guide", "branch": 4, "step": 3, "base_cost": 46, "cost_scale": 1.44, "max_tier": 5},
    {"id": "swivel_masters", "label": "Swivel Masters", "summary": "Cleans up the chain response so shoves carry further without twisting the line apart.", "icon": "L", "act": 4, "cell": Vector2(4, 0), "dependency": "keel_stabilizer", "branch": 4, "step": 4, "base_cost": 68, "cost_scale": 1.47, "max_tier": 5},
    {"id": "storm_bracing", "label": "Storm Bracing", "summary": "Locks your stance and keeps control sharp when the lure starts whipping fast.", "icon": "L", "act": 4, "cell": Vector2(5, -1), "dependency": "swivel_masters", "branch": 4, "step": 5, "base_cost": 98, "cost_scale": 1.5, "max_tier": 4},

    {"id": "chum_lantern", "label": "Chum Lantern", "summary": "Makes nearby fish commit a little harder when the hook gets close.", "icon": "B", "act": 5, "cell": Vector2(4, -3), "dependency": "", "branch": 5, "step": 1, "base_cost": 20, "cost_scale": 1.37, "max_tier": 6},
    {"id": "silver_crates", "label": "Silver Crates", "summary": "Better packing and handling means every landed fish sells for more.", "icon": "$", "act": 5, "cell": Vector2(5, -4), "dependency": "chum_lantern", "branch": 5, "step": 2, "base_cost": 34, "cost_scale": 1.42, "max_tier": 5},
    {"id": "black_market_buyer", "label": "Black Market Buyer", "summary": "The strangest deep catches start commanding serious money.", "icon": "$", "act": 5, "cell": Vector2(6, -5), "dependency": "silver_crates", "branch": 5, "step": 3, "base_cost": 54, "cost_scale": 1.46, "max_tier": 5},
    {"id": "lantern_buoys", "label": "Lantern Buoys", "summary": "Marking hot spots lets you hold fish attention longer and work cleaner routes through the dark.", "icon": "$", "act": 5, "cell": Vector2(7, -6), "dependency": "black_market_buyer", "branch": 5, "step": 4, "base_cost": 82, "cost_scale": 1.5, "max_tier": 5},
    {"id": "velvet_auction", "label": "Velvet Auction", "summary": "Private buyers start bidding hard for anything rare enough to survive the haul home.", "icon": "$", "act": 5, "cell": Vector2(8, -7), "dependency": "lantern_buoys", "branch": 5, "step": 5, "base_cost": 122, "cost_scale": 1.54, "max_tier": 4},

    {"id": "sounding_bell", "label": "Sounding Bell", "summary": "Regular depth pings make it easier to judge where richer bands begin.", "icon": "P", "act": 6, "cell": Vector2(0, -6), "dependency": "", "branch": 6, "step": 1, "base_cost": 24, "cost_scale": 1.38, "max_tier": 5},
    {"id": "pressure_map", "label": "Pressure Map", "summary": "Charts pressure pockets so you can sink faster and keep profitable routes in mind.", "icon": "P", "act": 6, "cell": Vector2(1, -7), "dependency": "sounding_bell", "branch": 6, "step": 2, "base_cost": 40, "cost_scale": 1.42, "max_tier": 5},
    {"id": "ghost_sonar", "label": "Ghost Sonar", "summary": "Paints faint returns from fish schools that would normally slip around the lure.", "icon": "P", "act": 6, "cell": Vector2(2, -8), "dependency": "pressure_map", "branch": 6, "step": 3, "base_cost": 62, "cost_scale": 1.46, "max_tier": 5},
    {"id": "trophy_tags", "label": "Trophy Tags", "summary": "Cataloging monsters pays off once buyers start recognizing named catches.", "icon": "P", "act": 6, "cell": Vector2(3, -9), "dependency": "ghost_sonar", "branch": 6, "step": 4, "base_cost": 94, "cost_scale": 1.5, "max_tier": 4},
    {"id": "moonlight_ledger", "label": "Moonlight Ledger", "summary": "Precise records turn big hauls into repeatable routes and premium contracts.", "icon": "P", "act": 6, "cell": Vector2(4, -10), "dependency": "trophy_tags", "branch": 6, "step": 5, "base_cost": 138, "cost_scale": 1.54, "max_tier": 4},

    {"id": "ice_racks", "label": "Ice Racks", "summary": "Cold storage keeps value from bleeding off during longer, heavier runs.", "icon": "C", "act": 7, "cell": Vector2(-4, -7), "dependency": "", "branch": 7, "step": 1, "base_cost": 26, "cost_scale": 1.38, "max_tier": 5},
    {"id": "night_crew", "label": "Night Crew", "summary": "Extra hands keep the deck moving so long sessions do not stall between catches.", "icon": "C", "act": 7, "cell": Vector2(-3, -8), "dependency": "ice_racks", "branch": 7, "step": 2, "base_cost": 42, "cost_scale": 1.42, "max_tier": 5},
    {"id": "hauler_motor", "label": "Hauler Motor", "summary": "A powered assist gives the line real authority once the fights get enormous.", "icon": "C", "act": 7, "cell": Vector2(-2, -9), "dependency": "night_crew", "branch": 7, "step": 3, "base_cost": 66, "cost_scale": 1.47, "max_tier": 5},
    {"id": "galley_stew", "label": "Galley Stew", "summary": "A hot meal between pulls steadies the crew and softens the punishment from slips.", "icon": "C", "act": 7, "cell": Vector2(-1, -10), "dependency": "hauler_motor", "branch": 7, "step": 4, "base_cost": 98, "cost_scale": 1.51, "max_tier": 4},
    {"id": "relief_shift", "label": "Relief Shift", "summary": "Swapping hands on the line lets marathon sessions stay efficient into the late night.", "icon": "C", "act": 7, "cell": Vector2(0, -11), "dependency": "galley_stew", "branch": 7, "step": 5, "base_cost": 144, "cost_scale": 1.55, "max_tier": 4},

    {"id": "starlit_chum", "label": "Starlit Chum", "summary": "The glow from rare bait keeps deep predators hovering near the lure for longer.", "icon": "*", "act": 8, "cell": Vector2(-8, -7), "dependency": "", "branch": 8, "step": 1, "base_cost": 34, "cost_scale": 1.4, "max_tier": 5},
    {"id": "void_braid", "label": "Void Braid", "summary": "A late-game line weave that reels smoother and wastes less force on the pull.", "icon": "*", "act": 8, "cell": Vector2(-7, -8), "dependency": "starlit_chum", "branch": 8, "step": 2, "base_cost": 56, "cost_scale": 1.45, "max_tier": 5},
    {"id": "horizon_clock", "label": "Horizon Clock", "summary": "A final timing rig that steals extra productive minutes from every launch window.", "icon": "*", "act": 8, "cell": Vector2(-6, -9), "dependency": "void_braid", "branch": 8, "step": 3, "base_cost": 86, "cost_scale": 1.5, "max_tier": 4},
    {"id": "leviathan_contracts", "label": "Leviathan Contracts", "summary": "High-risk buyers finally pay what the deepest monsters are actually worth.", "icon": "*", "act": 8, "cell": Vector2(-5, -10), "dependency": "horizon_clock", "branch": 8, "step": 4, "base_cost": 126, "cost_scale": 1.55, "max_tier": 4},
    {"id": "blackwater_crown", "label": "Blackwater Crown", "summary": "The late-run capstone: stronger control, richer hauls, and enough bite pressure to chase legends.", "icon": "*", "act": 8, "cell": Vector2(-4, -11), "dependency": "leviathan_contracts", "branch": 8, "step": 5, "base_cost": 184, "cost_scale": 1.6, "max_tier": 3},

    {"id": "auto_rod_bracket", "label": "Auto Rod Bracket", "summary": "A sprung rail rig that sets its own hook, and small fish tick in on a timer while you run the main line.", "icon": "N", "act": 9, "cell": Vector2(9, 5), "dependency": "", "branch": 9, "step": 1, "base_cost": 20, "cost_scale": 1.38, "max_tier": 6},
    {"id": "tension_servo", "label": "Tension Servo", "summary": "Keeps the bracket twitching on rhythm so passive bites land more often and nets feel snappier.", "icon": "N", "act": 9, "cell": Vector2(10, 4), "dependency": "auto_rod_bracket", "branch": 9, "step": 2, "base_cost": 32, "cost_scale": 1.4, "max_tier": 5},
    {"id": "seine_deployer", "label": "Seine Deployer", "summary": "Drops quick seine shots off the beam, and each pulse scoops extra deck fish alongside the auto rod.", "icon": "N", "act": 9, "cell": Vector2(11, 3), "dependency": "tension_servo", "branch": 9, "step": 3, "base_cost": 48, "cost_scale": 1.44, "max_tier": 5},
    {"id": "crab_pot_rack", "label": "Crab Pot Rack", "summary": "Running pots you never hand-bait. Opens krill, crabs, and other automation-only crawlies to the passive haul.", "icon": "N", "act": 9, "cell": Vector2(12, 2), "dependency": "seine_deployer", "branch": 9, "step": 4, "base_cost": 70, "cost_scale": 1.48, "max_tier": 5},
    {"id": "krill_bloom_feeder", "label": "Krill Bloom Feeder", "summary": "Lights and scent stack krill thick enough for the gear to skim serious money between your own fights.", "icon": "N", "act": 9, "cell": Vector2(13, 1), "dependency": "crab_pot_rack", "branch": 9, "step": 5, "base_cost": 96, "cost_scale": 1.52, "max_tier": 4},
    {"id": "midwater_trawl_winch", "label": "Midwater Trawl Winch", "summary": "A powered mid-layer trawl synced to your passive rig, with heavier automated payouts on every cycle.", "icon": "N", "act": 9, "cell": Vector2(14, 0), "dependency": "krill_bloom_feeder", "branch": 9, "step": 6, "base_cost": 134, "cost_scale": 1.55, "max_tier": 4},
]

static func get_meta_upgrade_catalog() -> Array[Dictionary]:
    return META_UPGRADES.duplicate(true)

static func get_demo_max_meta_step() -> int:
    return maxi(1, int(ProjectSettings.get_setting("global/reel_demo_max_meta_step", DEMO_MAX_META_STEP_DEFAULT)))

static func should_lock_meta_upgrade_in_demo(entry: Dictionary) -> bool:
    if not bool(ProjectSettings.get_setting("global/Demo", false)):
        return false
    return int(entry.get("step", 0)) > get_demo_max_meta_step()

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
        "automation_tick_interval": 999999.0,
        "automation_catch_count": 1,
        "automation_value_mult": 1.0,
        "automation_exotics_unlocked": false,
        "automation_exotic_bias": 0.0,
        "automation_seine_tier": 0,
        "automation_pot_tier": 0,
    }
    var deck_clock: int = int(upgrades.get("deck_clock", 0))
    var night_watch: int = int(upgrades.get("night_watch", 0))
    var tide_almanac: int = int(upgrades.get("tide_almanac", 0))
    var midnight_coffee: int = int(upgrades.get("midnight_coffee", 0))
    var storm_glass: int = int(upgrades.get("storm_glass", 0))
    var angler_grit: int = int(upgrades.get("angler_grit", 0))
    var shoulder_harness: int = int(upgrades.get("shoulder_harness", 0))
    var counterweight_reel: int = int(upgrades.get("counterweight_reel", 0))
    var drag_grease: int = int(upgrades.get("drag_grease", 0))
    var deck_medic: int = int(upgrades.get("deck_medic", 0))
    var lead_sinkers: int = int(upgrades.get("lead_sinkers", 0))
    var deep_charts: int = int(upgrades.get("deep_charts", 0))
    var abyss_permits: int = int(upgrades.get("abyss_permits", 0))
    var trench_winch: int = int(upgrades.get("trench_winch", 0))
    var hadal_licenses: int = int(upgrades.get("hadal_licenses", 0))
    var braided_line: int = int(upgrades.get("braided_line", 0))
    var pendulum_guide: int = int(upgrades.get("pendulum_guide", 0))
    var keel_stabilizer: int = int(upgrades.get("keel_stabilizer", 0))
    var swivel_masters: int = int(upgrades.get("swivel_masters", 0))
    var storm_bracing: int = int(upgrades.get("storm_bracing", 0))
    var chum_lantern: int = int(upgrades.get("chum_lantern", 0))
    var silver_crates: int = int(upgrades.get("silver_crates", 0))
    var black_market_buyer: int = int(upgrades.get("black_market_buyer", 0))
    var lantern_buoys: int = int(upgrades.get("lantern_buoys", 0))
    var velvet_auction: int = int(upgrades.get("velvet_auction", 0))
    var sounding_bell: int = int(upgrades.get("sounding_bell", 0))
    var pressure_map: int = int(upgrades.get("pressure_map", 0))
    var ghost_sonar: int = int(upgrades.get("ghost_sonar", 0))
    var trophy_tags: int = int(upgrades.get("trophy_tags", 0))
    var moonlight_ledger: int = int(upgrades.get("moonlight_ledger", 0))
    var ice_racks: int = int(upgrades.get("ice_racks", 0))
    var night_crew: int = int(upgrades.get("night_crew", 0))
    var hauler_motor: int = int(upgrades.get("hauler_motor", 0))
    var galley_stew: int = int(upgrades.get("galley_stew", 0))
    var relief_shift: int = int(upgrades.get("relief_shift", 0))
    var starlit_chum: int = int(upgrades.get("starlit_chum", 0))
    var void_braid: int = int(upgrades.get("void_braid", 0))
    var horizon_clock: int = int(upgrades.get("horizon_clock", 0))
    var leviathan_contracts: int = int(upgrades.get("leviathan_contracts", 0))
    var blackwater_crown: int = int(upgrades.get("blackwater_crown", 0))
    var auto_rod_bracket: int = int(upgrades.get("auto_rod_bracket", 0))
    var tension_servo: int = int(upgrades.get("tension_servo", 0))
    var seine_deployer: int = int(upgrades.get("seine_deployer", 0))
    var crab_pot_rack: int = int(upgrades.get("crab_pot_rack", 0))
    var krill_bloom_feeder: int = int(upgrades.get("krill_bloom_feeder", 0))
    var midwater_trawl_winch: int = int(upgrades.get("midwater_trawl_winch", 0))

    config["time_limit"] += (
        float(deck_clock) * 3.0
        + float(night_watch) * 2.0
        + float(tide_almanac) * 2.5
        + float(midnight_coffee) * 2.5
        + float(storm_glass) * 3.0
        + float(night_crew) * 1.5
        + float(relief_shift) * 1.5
        + float(horizon_clock) * 1.0
        + float(moonlight_ledger) * 1.0
    )
    config["player_stamina"] += (
        float(angler_grit) * 1.8
        + float(shoulder_harness) * 1.3
        + float(counterweight_reel) * 0.7
        + float(drag_grease) * 1.1
        + float(deck_medic) * 1.6
        + float(night_crew) * 0.8
        + float(galley_stew) * 0.9
        + float(blackwater_crown) * 0.6
    )
    config["fish_drain_multiplier"] += (
        float(angler_grit) * 0.04
        + float(shoulder_harness) * 0.08
        + float(counterweight_reel) * 0.12
        + float(drag_grease) * 0.10
        + float(deck_medic) * 0.08
        + float(ghost_sonar) * 0.05
        + float(leviathan_contracts) * 0.06
        + float(blackwater_crown) * 0.07
    )
    config["max_depth"] += (
        float(lead_sinkers) * 8.0
        + float(deep_charts) * 12.0
        + float(abyss_permits) * 16.0
        + float(trench_winch) * 20.0
        + float(hadal_licenses) * 24.0
        + float(pressure_map) * 6.0
        + float(ghost_sonar) * 10.0
        + float(leviathan_contracts) * 8.0
    )
    config["sink_speed"] += (
        float(lead_sinkers) * 0.7
        + float(deep_charts) * 0.6
        + float(abyss_permits) * 0.7
        + float(trench_winch) * 0.9
        + float(hadal_licenses) * 1.1
        + float(pressure_map) * 0.4
    )
    config["reel_speed"] += (
        float(shoulder_harness) * 0.5
        + float(counterweight_reel) * 1.0
        + float(drag_grease) * 0.8
        + float(hauler_motor) * 0.8
        + float(void_braid) * 0.6
        + float(blackwater_crown) * 0.5
    )
    config["auto_retract_speed"] += (
        float(counterweight_reel) * 2.0
        + float(abyss_permits) * 1.5
        + float(trench_winch) * 2.5
        + float(hauler_motor) * 3.0
        + float(horizon_clock) * 2.0
    )
    config["hook_control"] += (
        float(braided_line) * 0.14
        + float(pendulum_guide) * 0.18
        + float(keel_stabilizer) * 0.08
        + float(swivel_masters) * 0.13
        + float(storm_bracing) * 0.10
        + float(void_braid) * 0.06
        + float(blackwater_crown) * 0.04
    )
    config["mouse_impulse"] += (
        float(braided_line) * 0.05
        + float(pendulum_guide) * 0.08
        + float(swivel_masters) * 0.03
        + float(storm_bracing) * 0.04
        + float(void_braid) * 0.04
    )
    config["mistake_penalty_multiplier"] *= (
        pow(0.92, float(keel_stabilizer))
        * pow(0.95, float(storm_bracing))
        * pow(0.96, float(deck_medic))
        * pow(0.97, float(galley_stew))
    )
    config["reward_multiplier"] *= 1.0 + (
        float(silver_crates) * 0.08
        + float(black_market_buyer) * 0.11
        + float(lantern_buoys) * 0.09
        + float(velvet_auction) * 0.12
        + float(trophy_tags) * 0.06
        + float(moonlight_ledger) * 0.09
        + float(ice_racks) * 0.05
        + float(leviathan_contracts) * 0.05
        + float(blackwater_crown) * 0.08
    )
    config["attraction_radius"] += (
        float(chum_lantern) * 5.0
        + float(lantern_buoys) * 4.0
        + float(ghost_sonar) * 5.0
        + float(starlit_chum) * 4.0
    )
    config["reel_cost_multiplier"] *= (
        pow(0.95, float(shoulder_harness))
        * pow(0.96, float(drag_grease))
        * pow(0.97, float(relief_shift))
        * pow(0.97, float(void_braid))
    )
    if auto_rod_bracket <= 0:
        config["automation_tick_interval"] = 999999.0
    else:
        config["automation_tick_interval"] = maxf(
            2.5,
            14.8 - float(auto_rod_bracket) * 1.22 - float(tension_servo) * 0.32
        )
    config["automation_catch_count"] = clampi(
        1 + int(seine_deployer / 2) + int(tension_servo / 3) + int(midwater_trawl_winch / 3),
        1,
        4
    )
    config["automation_value_mult"] = 1.0 + (
        float(seine_deployer) * 0.03
        + float(midwater_trawl_winch) * 0.045
        + float(krill_bloom_feeder) * 0.035
    )
    config["automation_exotics_unlocked"] = crab_pot_rack > 0
    config["automation_exotic_bias"] = clampf(
        float(crab_pot_rack) * 0.065 + float(krill_bloom_feeder) * 0.09 + float(midwater_trawl_winch) * 0.055,
        0.0,
        0.58
    )
    config["automation_seine_tier"] = seine_deployer
    config["automation_pot_tier"] = crab_pot_rack
    var cross_mult: float = CROSS_GAME_BONUSES.get_target_bonus_multiplier(Util.ACTIVE_GAME_REEL_INTO_DARKNESS)
    config["fish_drain_multiplier"] *= cross_mult
    config["reward_multiplier"] *= cross_mult
    return config

## Depth-related meta keys in cumulative order (used for optional easier run caps).
const DEPTH_CAP_UPGRADE_KEYS: Array[String] = [
    "lead_sinkers",
    "deep_charts",
    "abyss_permits",
    "trench_winch",
    "hadal_licenses",
    "pressure_map",
    "ghost_sonar",
    "leviathan_contracts",
]

const REEL_DEPTH_TIER_LABELS: Dictionary = {
    "lead_sinkers": "Shelf waters",
    "deep_charts": "Charted depths",
    "abyss_permits": "Abyss band",
    "trench_winch": "Trench line",
    "hadal_licenses": "Hadal clearance",
    "pressure_map": "Pressure map",
    "ghost_sonar": "Ghost sonar",
    "leviathan_contracts": "Leviathan routes",
}

static func _tt(text: String) -> String:
    return TranslationServer.translate(text)

static func _reel_tier_cap_already_listed(caps_seen: Array, cap: float) -> bool:
    for c in caps_seen:
        if absf(float(c) - cap) < 0.35:
            return true
    return false

static func _push_reel_depth_tier(options: Array, caps_seen: Array, cap: float, title: String, detail: String) -> void:
    if _reel_tier_cap_already_listed(caps_seen, cap):
        return
    caps_seen.append(cap)
    options.append({"max_depth_cap": cap, "title": title, "detail": detail})

## Each entry: max_depth_cap, title, detail. Sorted shallow to deep. Used by the upgrade screen run picker.
static func get_reel_depth_tier_options(upgrades: Dictionary) -> Array:
    var options: Array = []
    var caps_seen: Array = []
    var full_config := get_run_config(upgrades)
    var full_cap: float = float(full_config.get("max_depth", 24.0))
    var u0 := upgrades.duplicate(true)
    for key in DEPTH_CAP_UPGRADE_KEYS:
        u0[key] = 0
    var base_cap: float = float(get_run_config(u0).get("max_depth", 24.0))
    _push_reel_depth_tier(
        options,
        caps_seen,
        base_cap,
        _tt("Shallows - max ~%.0f m") % base_cap,
        _tt("Easiest pool - depth-chart upgrades ignored for this launch.")
    )
    var u_step: Dictionary = u0.duplicate(true)
    for key in DEPTH_CAP_UPGRADE_KEYS:
        var lv: int = int(upgrades.get(key, 0))
        if lv <= 0:
            continue
        u_step[key] = lv
        var cap: float = float(get_run_config(u_step).get("max_depth", 24.0))
        var tier_name: String = str(REEL_DEPTH_TIER_LABELS.get(key, key))
        _push_reel_depth_tier(
            options,
            caps_seen,
            cap,
            _tt("%s - max ~%.0f m") % [tier_name, cap],
            _tt("Includes depth from your %s unlock.") % tier_name
        )
    if not _reel_tier_cap_already_listed(caps_seen, full_cap):
        _push_reel_depth_tier(
            options,
            caps_seen,
            full_cap,
            _tt("Full chart - max ~%.0f m") % full_cap,
            _tt("Every meter your unlocks allow.")
        )
    options.sort_custom(func(a, b): return float(a["max_depth_cap"]) < float(b["max_depth_cap"]))
    return options

static func get_available_fish_for_depth(max_depth: float) -> Array[Dictionary]:
    var available: Array[Dictionary] = []
    for fish_variant in FISH_CATALOG:
        var fish: Dictionary = fish_variant
        if fish.get("automation_only", false):
            continue
        if float(fish.get("min_depth", 0.0)) <= max_depth + 0.01:
            available.append(fish.duplicate(true))
    return available

static func pick_fish_for_depth(depth_meters: float, rng: RandomNumberGenerator) -> Dictionary:
    var candidates: Array[Dictionary] = []
    var total_weight := 0.0
    for fish_variant in FISH_CATALOG:
        var fish: Dictionary = fish_variant
        if fish.get("automation_only", false):
            continue
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

## Passive deck gear only scrapes the sunlit band, never main-line deep quarry.
const AUTOMATION_PASSIVE_MAX_DEPTH_M := 20.0

static func pick_automation_catch(
    max_depth_m: float,
    rng: RandomNumberGenerator,
    exotics_unlocked: bool,
    exotic_bias: float
) -> Dictionary:
    var cap_m: float = minf(max_depth_m, AUTOMATION_PASSIVE_MAX_DEPTH_M)
    var pool: Array[Dictionary] = []
    var tw := 0.0
    for fish_variant in FISH_CATALOG:
        var fish: Dictionary = fish_variant
        if not fish.get("automation_only", false):
            continue
        var min_d: float = float(fish.get("min_depth", 0.0))
        var max_d: float = float(fish.get("max_depth", 9999.0))
        if min_d > cap_m + 0.75:
            continue
        if max_d < 0.5:
            continue
        var w: float = max(0.08, float(fish.get("automation_weight", 1.0)))
        if exotics_unlocked:
            w *= 1.0 + clampf(exotic_bias, 0.0, 0.5) * 0.35
        var weighted: Dictionary = fish.duplicate(true)
        weighted["_w"] = w
        tw += w
        pool.append(weighted)
    if pool.is_empty():
        for fish_variant in FISH_CATALOG:
            var fish: Dictionary = fish_variant
            if fish.get("automation_only", false):
                return fish.duplicate(true)
        return FISH_CATALOG[0].duplicate(true)
    var roll: float = rng.randf() * tw
    for p in pool:
        roll -= float(p.get("_w", 0.0))
        if roll <= 0.0:
            p.erase("_w")
            return p
    var last: Dictionary = pool.back().duplicate(true)
    last.erase("_w")
    return last
