extends HBoxContainer

@onready var stat_name = $MarginContainer/Unit
@onready var stat_level = $HBoxContainer/MarginContainer3/Level
@onready var minus = $HBoxContainer/MarginContainer/Minus
@onready var plus = $HBoxContainer/MarginContainer2/Plus

var unit

@export var stat_params = {
	type = 0,
	upgrade = 0
}

var type = {
	0 : "Troop",
	1 : "Negotiator",
	2 : "Scout",
	3 : "Colony"
}

var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)
	
func _init_stat():
	stat_params["upgrade"] = int(unit.unit_params["upgrade"] * 10)
	stat_name.text = type[stat_params["type"]] + " level"
	stat_level.text = "Lvl." + str(stat_params["upgrade"])

func _on_minus_button_down() -> void:
	if mainScene.player.calcul_curr_upgrades(stat_params["type"]) and stat_params["upgrade"] > 0 :
		change_upgrade(false)

func _on_plus_button_down() -> void:
	if mainScene.player.calcul_curr_upgrades(stat_params["type"]) and mainScene.player.check_upgrade_bool():
		change_upgrade(true)

func change_upgrade(op) : #true = + // false = -
	if op :
		unit.unit_params["upgrade"] += 0.1
	else :
		unit.unit_params["upgrade"] -= 0.1
	_init_stat()
	mainScene._update_ship_status()
