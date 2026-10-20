extends HBoxContainer

## R&D level allocation. Levels now come from unit XP earned on missions
## (computed by the server), so this widget only displays the level.
## The +/- buttons are disabled until the R&D tab gets a new purpose.

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
	minus.disabled = true
	plus.disabled = true

func _init_stat():
	if unit == null:
		return
	stat_name.text = type[stat_params["type"]] + " level"
	stat_level.text = "Lvl." + str(unit.unit_params.get("level", 0))

func _on_minus_button_down() -> void:
	pass

func _on_plus_button_down() -> void:
	pass
