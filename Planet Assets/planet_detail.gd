extends Control

@onready var tab_container = $TabContainer
@onready var actions_tab = $TabContainer/Actions
@onready var status_tab = $TabContainer/Status
@onready var free_tab = $TabContainer/FreeTab

@onready var negotiate = $TabContainer/Actions/MarginContainer/Negotiate
@onready var attack = $TabContainer/Actions/MarginContainer2/Attack
@onready var scout = $TabContainer/Actions/MarginContainer3/Scout
@onready var moveto = $"TabContainer/Actions/MarginContainer4/Move to"

@onready var planet_name = $TabContainer/Status/Values/MarginContainer/Planet_Name
@onready var planet_race = $TabContainer/Status/Values/MarginContainer2/Planet_Race
@onready var planet_culture = $TabContainer/Status/Values/MarginContainer3/Planet_Culture
@onready var planet_wealth = $TabContainer/Status/Values/MarginContainer4/Planet_Wealth

var planet
var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)
	mainScene.valdiate_list = get_tree().get_nodes_in_group("validate")
	
func fill_info(planet_data):
	planet = planet_data
	# Fill status tab
	planet_name.text = planet.planet_params["name"]
	planet_race.text = planet.planet_params["race"]
	planet_culture.text = planet.planet_params["culture"]
	planet_wealth.text = str(planet.planet_params["wealth"])
	
	# Fill actions tab dynamically
	attack.disabled = !planet.planet_params["inhabited"]
	negotiate.disabled = !planet.planet_params["inhabited"]
	moveto.disabled = !planet.planet_params["nearby"]

func switch_move():
	if moveto.disabled :
		moveto.disabled = false
	else :
		moveto.disabled = true

func _on_move_to_button_down() -> void:
	mainScene.player.emit_signal("move_to_planet", planet)

func _on_negotiate_button_down() -> void:
	mainScene.player.deploy_unit(1, planet.planet_params["name"])

func _on_attack_button_down() -> void:
	mainScene.player.deploy_unit(0, planet.planet_params["name"])
	
func _on_scout_button_down() -> void:
	mainScene.player.deploy_unit(2, planet.planet_params["name"])
