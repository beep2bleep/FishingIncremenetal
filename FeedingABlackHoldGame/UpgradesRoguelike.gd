extends ColorRect
class_name UpgradesRoguelike

@onready var node_1: TechTreeNode = %"Node 1"
@onready var node_2: TechTreeNode = %"Node 2"
@onready var node_3: TechTreeNode = %"Node 3"

var is_active = false


var mod_configs = [
    {"mod": Util.MODS.ASTEROIDS_TO_SPAWN, "min": 20, "max": 50, "max_total": 200, "weight": 2.0, "is_int": true}, 
    {"mod": Util.MODS.CHANCE_TO_RESPAWN_ASTEROID_ON_BREAK, "min": 0.1, "max": 0.3, "max_total": 1.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.CHANCE_TO_ADD_TIME_ON_ASTEROID_DESTROYED, "min": 0.1, "max": 0.3, "max_total": 1.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.MAX_ASTEROID_SIZE, "min": 1, "max": 2, "max_total": 3, "weight": 1.0, "is_int": true}, 
    {"mod": Util.MODS.ASTEROID_DENSITY, "min": 0.25, "max": 1.0, "max_total": 7.0, "weight": 1.0, "is_int": false}, 

    {"mod": Util.MODS.RUN_TIMER_BASE, "min": 3.0, "max": 10.0, "max_total": 60.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.RUN_TIMER_AMOUNT_ON_BLACK_HOLE_GROW, "min": 1.0, "max": 10.0, "max_total": 60.0, "weight": 1.0, "is_int": false}, 

    {"mod": Util.MODS.CLICK_AOE, "min": 0.1, "max": 0.5, "max_total": 5.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.CLICK_RATE, "min": 0.05, "max": 0.25, "max_total": 3.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.BASE_DAMAGE_PER_CLICK, "min": 2.0, "max": 10.0, "max_total": 3.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.CLICKER_CRIT_CHANCE, "min": 0.1, "max": 0.25, "max_total": 1.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.CLICKER_CRIT_BONUS, "min": 0.25, "max": 0.5, "max_total": 5.0, "weight": 1.0, "is_int": false}, 

    {"mod": Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_ELECTRIC, "min": 0.1, "max": 0.1, "max_total": 0.1, "weight": 2.0, "is_int": false}, 
    {"mod": Util.MODS.ELECTRIC_CRIT_CHANCE, "min": 0.15, "max": 0.4, "max_total": 1.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.ELECTRIC_CRIT_BONUS, "min": 0.5, "max": 1.5, "max_total": 10.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_ELECTRIC_DAMAGE, "min": 1.0, "max": 5.0, "max_total": 100.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_ELECTRIC_MAX_CHAINS, "min": 1, "max": 3, "max_total": 10, "weight": 1.0, "is_int": true}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_CHANCE_TO_FORK, "min": 0.1, "max": 0.3, "max_total": 1.0, "weight": 1.0, "is_int": false}, 

    {"mod": Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_RADIOACTIVE, "min": 0.1, "max": 0.1, "max_total": 0.1, "weight": 2.0, "is_int": false}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_RADIOACTIVE_DOT, "min": 1, "max": 5, "max_total": 20, "weight": 1.0, "is_int": true}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_RADIOACTIVE_DURATION, "min": 1, "max": 2.5, "max_total": 10.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_RADIOACTIVE_AOE_SCALE, "min": 0.25, "max": 1.5, "max_total": 10.0, "weight": 1.0, "is_int": false}, 

    {"mod": Util.MODS.CHANCE_TO_SPAWN_SPECIAL_ASTEROID_GOLDEN, "min": 0.1, "max": 0.1, "max_total": 0.1, "weight": 2.0, "is_int": false}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_GOLDEN_BONUS_MONEY_SCALE, "min": 0.5, "max": 2.0, "max_total": 10.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_GOLDEN_CRIT_CHANCE, "min": 0.1, "max": 0.4, "max_total": 1.0, "weight": 1.0, "is_int": false}, 
    {"mod": Util.MODS.SPECIAL_ASTEROID_GOLDEN_CRIT_BONUS_MONEY_SCALE, "min": 0.5, "max": 3.0, "max_total": 15.0, "weight": 1.0, "is_int": false}, 
]

const WEIGHT_INCREMENT = 1.0

func _ready():
    node_1.unlocked.connect(_on_node_unlocked)
    node_2.unlocked.connect(_on_node_unlocked)
    node_3.unlocked.connect(_on_node_unlocked)

func hide_screen():
    is_active = false
    hide()

var from_node: TechTreeNode

func setup(_from_node):
    from_node = _from_node


    var upgrades = generate_unique_upgrades(3)

    node_1.setup(upgrades[0], null)
    node_1.state = TechTreeNode.STATES.AVAILABLE
    node_1.update()

    node_2.setup(upgrades[1], null)
    node_2.state = TechTreeNode.STATES.AVAILABLE
    node_2.update()

    node_3.setup(upgrades[2], null)
    node_3.state = TechTreeNode.STATES.AVAILABLE
    node_3.update()

    is_active = true
    show()

func _on_node_unlocked(unlocked_node: TechTreeNode):
    if from_node != null:
        unlocked_node.upgrade.base_cost = from_node.upgrade.base_cost
        unlocked_node.upgrade.id = from_node.upgrade.id
        unlocked_node.upgrade.cell = from_node.upgrade.cell
        from_node.upgrade = unlocked_node.upgrade
        from_node.update()

    hide_screen()
    Global.main.upgrade_screen.state = UpgradeScreen.STATES.SHOWING_TREE

func get_available_mods() -> Array:
    "Returns only mods that haven't reached their max total value"
    var available = []

    for config in mod_configs:
        var current_value = Global.mods.get_mod(config["mod"])
        if current_value < config["max_total"]:
            available.append(config)

    return available

func weighted_random_select(available: Array, count: int) -> Array:
    "Select mods using weighted random selection"
    var selected = []
    var available_copy = available.duplicate()

    for i in count:
        if available_copy.is_empty():
            break


        var total_weight = 0.0
        for config in available_copy:
            total_weight += config["weight"]


        var random_value = randf() * total_weight


        var cumulative_weight = 0.0
        var selected_config = null
        for config in available_copy:
            cumulative_weight += config["weight"]
            if random_value <= cumulative_weight:
                selected_config = config
                break

        if selected_config:
            selected.append(selected_config)

            selected_config["weight"] = 0.0

            available_copy.erase(selected_config)


    for config in available_copy:
        config["weight"] += WEIGHT_INCREMENT

    return selected

func generate_unique_upgrades(count: int) -> Array[Upgrade]:
    "Generate multiple upgrades with unique mods using weighted selection"
    var upgrades: Array[Upgrade] = []
    var available = get_available_mods()

    if available.is_empty():
        push_warning("No available mods to choose from!")
        for i in count:
            upgrades.append(Upgrade.new())
        return upgrades


    var mods_to_use = weighted_random_select(available, count)


    for config in mods_to_use:
        var upgrade = Upgrade.new()
        upgrade.id = randi() % 1000
        upgrade.mod = config["mod"]


        var rolled_value = randf_range(config["min"], config["max"])
        if config.get("is_int", false):
            upgrade.value = int(round(rolled_value))
        else:
            upgrade.value = rolled_value

        upgrade.max_tier = 1
        upgrade.cost_scale = 0
        upgrade.forced_cell = null
        upgrade.demo_locked = 0
        upgrade.section = 0
        upgrade.act = 1
        upgrade.current_tier = 0
        upgrade.type = Util.NODE_TYPES.ROGUELIKE
        upgrades.append(upgrade)


    while upgrades.size() < count:
        push_warning("Not enough unique mods available, duplicating...")
        upgrades.append(upgrades[0].duplicate())

    return upgrades
