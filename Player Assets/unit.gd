extends Node2D

@export var unit_params = { 
	unit_name = "",
	unit_type = 0,
	unit_position = "In the ship",
	strength = 1.0,
	upgrade = 0.0,
	deploying = false,
	next_available = 0.0
}

var type = {
	0 : "Troop",
	1 : "Negotiator",
	2 : "Scout",
	3 : "Colony"
}

var total_strength = 0

const COOLDOWN = {
	"Troop": 100.0, 
	"Negotiator": 120.0, 
	"Scout": 80.0, 
	"Colony": 60.0
	}

func init_unit():
	##init the stats from save.
	total_strength = unit_params["strength"] + unit_params["strength"] * unit_params["upgrade"]
	
func return_to_ship():
	unit_params["unit_position"] = "Fleet"
	unit_params["deploying"] = true
