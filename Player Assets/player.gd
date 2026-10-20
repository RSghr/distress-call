extends Node2D

@onready var fleet = $Fleet
@onready var pcs = $player_cfg_saver
@onready var ccs = $Cooldown_cfg_saver
var mainScene

var nearby_planet = []
var current_planet

const UNIT_COST = {
	0:10000,
	1:5000,
	2:25000,
	3:50000
}

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)

#Setup of the fleet position
func init_player():
	reset_route()
	current_planet = on_planet()
	possible_routes()
	enable_route()

#Gathering the possible routes
func possible_routes():
	for connexion in mainScene.galaxy.connexion_line :
		if current_planet == connexion[0]:
			nearby_planet.append(connexion[1])
		elif current_planet == connexion[1] :
			nearby_planet.append(connexion[0])

#Return the planet name
func on_planet():
	for planet in mainScene.galaxy.placed_planet :
		if fleet.fleet_params["fleet_position"] == planet.planet_params["name"] :
			return planet
	printerr("Could not find the planet")

#Enable movement to a planet
func enable_route():
	for planet in nearby_planet :
		planet.planet_params["nearby"] = true
		if planet.has_node("Planet_Detail") :
			planet.get_node("Planet_Detail").switch_move()

#Disable movement to a planet
func reset_route():
	for planet in nearby_planet :
		planet.planet_params["nearby"] = false
		if planet.has_node("Planet_Detail") :
			planet.get_node("Planet_Detail").switch_move()
	nearby_planet.clear()

#Action of moving fleet: the server checks the jump and answers with move_result
func move_to_planet(planet):
	if cd_detect(4) :
		mainScene.ftl_saver(planet.planet_params["name"])
	else :
		mainScene.deny_server_call()

#func check_upgrade_bool():
	#if  fleet.fleet_params["current_space"] < fleet.fleet_params["total_space"] :
		#return true
	#return false

#func calcul_curr_upgrades(unit_type):
	#if cd_detect(unit_type) :
		#var curr = 0
		#for unit in fleet.unit_holder.get_children():
			#curr += int(unit.unit_params["level"] * 10)
		#fleet.fleet_params["current_space"] = curr
		#return true
	#else :
		#return false

func deploy_unit(unit_type, planet):
	if cd_detect(unit_type) and cost_detect(unit_type):
		mainScene._deploy_unit(unit_type,planet)
	else :
		mainScene.deny_server_call()

func cd_detect(unit_type):
	match unit_type:
		0 : #Troop
			if !mainScene.fleetStatus.playerUI.troop_cooldown.cd_check():
				return false
		1 : #Negotiator
			if !mainScene.fleetStatus.playerUI.negotiator_cooldown.cd_check():
				return false
		2 : #Scout
			if !mainScene.fleetStatus.playerUI.scout_cooldown.cd_check():
				return false
		3 : #Colony
			if !mainScene.fleetStatus.playerUI.colony_cooldown.cd_check():
				return false
		4 : #Fleet
			if !mainScene.fleetStatus.playerUI.ftl_cooldown.cd_check():
				return false
	return true

## Quick local check so the button feels instant; the server makes the real check.
func unit_cost(unit_type):
	var unit_name = ["Troop", "Negotiator", "Scout", "Colony"][unit_type]
	if fleet.unit_costs.has(unit_name):
		return fleet.unit_costs[unit_name]
	var unit = fleet.unit_holder.get_node(unit_name)
	return int(UNIT_COST[unit_type] * unit.total_strength)

func cost_detect(unit_type):
	return fleet.fleet_params["CoreUnit"] >= unit_cost(unit_type)
