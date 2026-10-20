extends Node2D

@export var unit_params = { 
	unit_name = "",
	unit_type = 0,
	unit_position = "In the ship",
	strength = 1.0,
	level = 0,
	exp = 0,
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
	"Troop": 		20.0, #100
	"Negotiator": 	15.0, #120 
	"Scout": 		25.0, #80
	"Colony": 		30.0 #60
	}

func init_unit():
	##init the stats from save.
	total_strength = unit_params["strength"] + unit_params["strength"] * (unit_params["level"] * 0.1)
	
func return_to_ship():
	unit_params["unit_position"] = "Fleet"
	unit_params["deploying"] = true
