extends Node2D

signal move_to_planet

@onready var fleet = $Fleet
@onready var pcs = $player_cfg_saver
@onready var ccs = $Cooldown_cfg_saver
var mainScene

var nearby_planet = []
var current_planet

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
func _on_move_to_planet(planet) -> void:
	current_planet = planet
	fleet.fleet_params["fleet_position"] = current_planet.planet_params["name"]
	reset_route()
	possible_routes()
	enable_route()
	mainScene.on_fleet_units_action()
	mainScene.displace_player($".", planet)

func check_upgrade_bool():
	if  fleet.fleet_params["current_space"] < fleet.fleet_params["total_space"] :
		return true
	return false

func calcul_curr_upgrades():
	var curr = 0
	for unit in fleet.unit_holder.get_children():
		curr += int(unit.unit_params["upgrade"] * 10)
	fleet.fleet_params["current_space"] = curr

func minus_upgrade_space(unit_type):
	fleet.fleet_params["current_space"] -= 1
	match unit_type :
		0 : #Troop
			fleet.troop.unit_params["upgrade"] -= 0.1
		1 : #Negotiator
			fleet.negotiator.unit_params["upgrade"] -= 0.1
		2 : #Scout
			fleet.scout.unit_params["upgrade"] -= 0.1
		3 : #Colony
			fleet.colony.unit_params["upgrade"] -= 0.1

func plus_upgrade_space(unit_type):
	fleet.fleet_params["current_space"] += 1
	match unit_type :
		0 : #Troop
			fleet.troop.unit_params["upgrade"] += 0.1
		1 : #Negotiator
			fleet.negotiator.unit_params["upgrade"] += 0.1
		2 : #Scout
			fleet.scout.unit_params["upgrade"] += 0.1
		3 : #Colony
			fleet.colony.unit_params["upgrade"] += 0.1

func deploy_unit(unit_type, planet):
	mainScene._deploy_unit(unit_type,planet)
