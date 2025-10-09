extends HBoxContainer

@onready var unit_sprite = $TextureRect
@onready var cooldown = $RichTextLabel

@export var unit_type = "Colony.png"
@export var type = 3

func _ready() -> void:
	
	var texture = load("res://UI/Units/" + unit_type)
	unit_sprite.texture = texture

func update_cooldown_text(cdtext):
	cooldown.text = cdtext
