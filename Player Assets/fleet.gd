extends Node2D

@onready var  scout = $Unit_Holder/Scout
@onready var  troop = $Unit_Holder/Troop
@onready var  colony = $Unit_Holder/Colony
@onready var  negotiator = $Unit_Holder/Negotiator
@onready var unit_holder = $Unit_Holder
@onready var fleet_name = $FleetName

var player_id

@export var fleet_params = { 
	fleet_name = "",
	fleet_type = 0,
	fleet_position = "",
	current_space = 0,
	total_space = 10,
	CoreUnit = 100000,
	faction = 0,
	ftl = true,
	next_available = 0.0
}

var faction_type = {
	0 : "Self",
	1 : "Allied",
	2 : "Neutral",
	3 : "Enemy"
}

var mainScene
var server_offset = 0

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)

func _on_status_button_down() -> void:
	mainScene._update_ship_status()
	mainScene.switch_to_fleet_status()

func set_planet(planet):
	fleet_params["fleet_position"] = planet

func set_fleet_name():
	if fleet_params["fleet_name"] == "" :
		fleet_name.text = "Ally fleet"
	else :
		fleet_name.text = fleet_params["fleet_name"]
