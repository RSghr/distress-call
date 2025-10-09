extends Node2D

@onready var unit = $Unit
@onready var unit_type = $Unit/Unit_type

@export var radius = 100.0
@export var player_id = ""
@export var planet_name = ""
@export var type = 0
var speed = 1.0 
var pos_x = 0
var pos_y = 0
var angle = 0.0
var offset = 0

func _ready() -> void:
	offset = randf_range(0.5,1.5)
	unit_type.frame = type
	name = player_id + "_" + str(type) + "_" + planet_name

func _process(delta: float) -> void:
	angle += speed * delta * offset
	pos_x = unit.position.x + radius * cos(angle)
	pos_y = unit.position.y + radius * sin(angle)
	position = Vector2(pos_x, pos_y)
	if unit.rotation >= 360 :
		unit.rotation = 0
		unit_type.rotation = 0
	else :
		unit.rotation = angle
		unit_type.rotation = -angle
