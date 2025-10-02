extends Control

@onready var tab_container = $TabContainer
@onready var actions_tab = $TabContainer/Actions
@onready var status_tab = $TabContainer/Status
@onready var free_tab = $TabContainer/FreeTab

@onready var negotiate = $TabContainer/Actions/MarginContainer1/Negotiate
@onready var attack = $TabContainer/Actions/MarginContainer2/Attack
@onready var scout = $TabContainer/Actions/MarginContainer3/Scout
@onready var colonize = $TabContainer/Actions/MarginContainer4/Colonize
@onready var moveto = $"TabContainer/Actions/MarginContainer5/Move to"

@onready var planet_name = $TabContainer/Status/Values/MarginContainer/Planet_Name
@onready var planet_race = $TabContainer/Status/Values/MarginContainer2/Planet_Race
@onready var planet_culture = $TabContainer/Status/Values/MarginContainer3/Planet_Culture
@onready var planet_wealth = $TabContainer/Status/Values/MarginContainer4/Planet_Wealth
@onready var planet_will = $TabContainer/Status/Values/MarginContainer5/Planet_Will

@onready var unit_cost = $TabContainer/Actions/Unit_Cost
var planet
var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)
	mainScene.valdiate_list = get_tree().get_nodes_in_group("validate")
	
func fill_info(planet_data):
	planet = planet_data
	# Fill status tab
	planet_name.text = planet.planet_params["name"]
	
	if planet.planet_params["discovered"]:
		planet_race.text = planet.planet_params["race"]
		planet_culture.text = planet.planet_params["culture"]
		planet_wealth.text = str(planet.planet_params["wealth"])
		planet_will.text = str(planet.planet_params["will"]) + " / 50"
		will_status(planet.planet_params["will"])
	else :
		planet_race.text = "Unknown"
		planet_culture.text = "Unknown"
		planet_wealth.text = "Unknown"
		planet_will.text = "Unknown"
	
	attack.disabled = true
	negotiate.disabled = true
	moveto.disabled = true
	scout.disabled = true
	colonize.disabled = true
	# Fill actions tab dynamically
	if planet.planet_params["nearby"] :
		moveto.disabled = false
		if !planet.planet_params["discovered"] :
			scout.disabled = false
		else :
			if !planet.planet_params["conquered"] and planet.planet_params["inhabited"] :
					attack.disabled = false
					negotiate.disabled = false
	
	if mainScene.player.on_planet() == planet and !planet.planet_params["conquered"] : 
		colonize.disabled = false
		attack.disabled = false
		negotiate.disabled = false

func will_status(will):
	if will > 100 :
		planet_will.self_modulate = Color.RED
	elif will > 75 :
		planet_will.self_modulate = Color.ORANGE
	elif will > 50 :
		planet_will.self_modulate = Color.YELLOW
	else :
		planet_will.self_modulate = Color.GREEN
	

func switch_move():
	if moveto.disabled :
		moveto.disabled = false
	else :
		moveto.disabled = true

func _on_move_to_button_down() -> void:
	mainScene.player.move_to_planet(planet)

func _on_negotiate_button_down() -> void:
	mainScene.player.deploy_unit(1, planet.planet_params["name"])

func _on_attack_button_down() -> void:
	mainScene.player.deploy_unit(0, planet.planet_params["name"])
	
func _on_scout_button_down() -> void:
	mainScene.player.deploy_unit(2, planet.planet_params["name"])

func _on_colonize_button_down() -> void:
	mainScene.player.deploy_unit(3, planet.planet_params["name"])

#DISPLAY UNIT COST
func _on_negotiate_mouse_entered() -> void:
	unit_cost.self_modulate.a = 1
	unit_cost.text = str(int(5000 * mainScene.player.fleet.negotiator.total_strength)) + " CU"

func _on_scout_mouse_entered() -> void:
	unit_cost.self_modulate.a = 1
	unit_cost.text = str(int(25000 * mainScene.player.fleet.scout.total_strength)) + " CU"

func _on_colonize_mouse_entered() -> void:
	unit_cost.self_modulate.a = 1
	unit_cost.text = str(int(50000 * mainScene.player.fleet.colony.total_strength)) + " CU"

func _on_attack_mouse_entered() -> void:
	unit_cost.self_modulate.a = 1
	unit_cost.text = str(int(10000 * mainScene.player.fleet.troop.total_strength)) + " CU"

func _on_negotiate_mouse_exited() -> void:
	unit_cost.self_modulate.a = 0

func _on_attack_mouse_exited() -> void:
	unit_cost.self_modulate.a = 0

func _on_scout_mouse_exited() -> void:
	unit_cost.self_modulate.a = 0

func _on_colonize_mouse_exited() -> void:
	unit_cost.self_modulate.a = 0
