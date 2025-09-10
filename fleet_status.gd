extends Camera2D

@onready var playerUI = $PlayerUI
var mainScene

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)

func _on_back_button_down() -> void:
	mainScene._update_ship_status()
	mainScene.switch_to_fleet_status()
