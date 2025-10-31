extends Button


@export var item_id = "Item Name"
@export var tooltip = "tooltip"
@export var price = 0
@export var amount = 0


var mainScene

func _ready() -> void:
	mainScene = get_tree().root.get_child(0)
	if amount == 0:
		disabled = true

func _on_button_down() -> void:
	mainScene.buy_item(item_id)

func _on_mouse_entered() -> void:
	mainScene.fleetStatus.playerUI.display_tooltip(tooltip, true)

func _on_mouse_exited() -> void:
	mainScene.fleetStatus.playerUI.display_tooltip("", false)
