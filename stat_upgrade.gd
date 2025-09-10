extends HBoxContainer

@onready var stat_name = $MarginContainer/Unit
@onready var stat_level = $HBoxContainer/MarginContainer3/Level
@onready var minus = $HBoxContainer/MarginContainer/Minus
@onready var plus = $HBoxContainer/MarginContainer2/Plus



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
	stat_name.text = type[stat_params["type"]] + " level"
	stat_level.text = "Lvl." + str(stat_params["upgrade"])


func _on_minus_button_down() -> void:
	mainScene.fleetStatus.playerUI.emit_signal("minus_upgrade", stat_params["type"])

func _on_plus_button_down() -> void:
	mainScene.fleetStatus.playerUI.emit_signal("plus_upgrade", stat_params["type"])

func change_upgrade(op) : #true = + // false = -
	if op :
		stat_params["upgrade"] += 1
	else :
		stat_params["upgrade"] -= 1
	_init_stat()
	mainScene._update_ship_status()
