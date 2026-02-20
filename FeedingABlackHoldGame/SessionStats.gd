extends Node
class_name SessionStats

var time_added_during_session = 0.0

var asteroids_destroyed_during_session = 0
var planets_destroyed_during_session = 0
var stars_destroyed_during_session = 0

var breaker_damage = 0.0
var breaker_crit_damage = 0.0
var electric_damage = 0.0

var money_from_golden_asteroids = 0

var radio_active_damage = 0.0

var moons_collected = 0
var comets_collected = 0

var star_electric_damage = 0
var laser_damage = 0
var super_nova_damage = 0

var asteroid_money = 0.0
var planet_money = 0.0
var star_money = 0.0


var clicker_clicks = 0.0
var manual_clicks = 0.0

func reset():
    time_added_during_session = 0.0

    asteroids_destroyed_during_session = 0
    planets_destroyed_during_session = 0
    stars_destroyed_during_session = 0

    breaker_damage = 0.0
    breaker_crit_damage = 0.0

    electric_damage = 0.0
    money_from_golden_asteroids = 0.0
    radio_active_damage = 0.0

    moons_collected = 0
    comets_collected = 0

    asteroid_money = 0.0
    planet_money = 0.0
    star_money = 0.0

    star_electric_damage = 0
    laser_damage = 0
    super_nova_damage = 0

    clicker_clicks = 0.0
    manual_clicks = 0.0
