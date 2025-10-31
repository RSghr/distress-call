extends Panel

@onready var feedback = $FeedbackText

var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)

func _on_send_button_down() -> void:
	mainScene.client.request_send_report(feedback.text)
