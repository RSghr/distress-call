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

#Action of moving fleet
func move_to_planet(planet):
	mainScene.ftl_saver(planet.planet_params["name"])
	if mainScene.fleetStatus.playerUI.ftl_cooldown.cd_check():
		current_planet = planet
		fleet.fleet_params["fleet_position"] = current_planet.planet_params["name"]
		reset_route()
		possible_routes()
		enable_route()
		mainScene.displace_player($".", planet)

func check_upgrade_bool():
	if  fleet.fleet_params["current_space"] < fleet.fleet_params["total_space"] :
		return true
	return false

func calcul_curr_upgrades(unit_type):
	if cd_detect(unit_type) :
		var curr = 0
		for unit in fleet.unit_holder.get_children():
			curr += int(unit.unit_params["upgrade"] * 10)
		fleet.fleet_params["current_space"] = curr
		return true
	else :
		return false

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
	return true

func cost_detect(unit_type):
	var result = 0
	match unit_type:
		0 : #Troop
			result = fleet.fleet_params["CoreUnit"] - 10000 * fleet.troop.total_strength
		1 : #Negotiator
			result = fleet.fleet_params["CoreUnit"] - 5000 * fleet.negotiator.total_strength
		2 : #Scout
			result = fleet.fleet_params["CoreUnit"] - 25000 * fleet.scout.total_strength
		3 : #Colony
			result = fleet.fleet_params["CoreUnit"] - 50000 * fleet.colony.total_strength
	if result >= 0 :
		return true
	else :
		return false
