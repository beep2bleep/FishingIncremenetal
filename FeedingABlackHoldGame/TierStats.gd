extends Node
class_name TierStats

var total_damage_this_tier = 0.0
var total_objects_destoryed_this_tier = 0.0
var total_money_earned_this_teir = 0.0
var session_this_tier = 0.0

func tally_session_stats():
    total_damage_this_tier += Global.session_stats.breaker_damage
    total_damage_this_tier += Global.session_stats.electric_damage
    total_damage_this_tier += Global.session_stats.star_electric_damage
    total_damage_this_tier += Global.session_stats.laser_damage
    total_damage_this_tier += Global.session_stats.super_nova_damage

    total_objects_destoryed_this_tier += Global.session_stats.asteroids_destroyed_during_session
    total_objects_destoryed_this_tier += Global.session_stats.planets_destroyed_during_session
    total_objects_destoryed_this_tier += Global.session_stats.stars_destroyed_during_session

    total_money_earned_this_teir += Global.session_stats.asteroid_money
    total_money_earned_this_teir += Global.session_stats.planet_money
    total_money_earned_this_teir += Global.session_stats.star_money

    session_this_tier += 1


func reset():
    total_damage_this_tier = 0.0
    total_objects_destoryed_this_tier = 0.0
    total_money_earned_this_teir = 0.0
    session_this_tier = 0.0
