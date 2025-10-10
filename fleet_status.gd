extends Camera2D

@onready var playerUI = $PlayerUI

var mainScene

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)

func _on_visibility_changed() -> void:
	if visible :
		playerUI.anim_player.play("Player UI")
