extends Node2D

@onready var base = $Base
@onready var land = $Base/Land
@onready var name_text = $Planet_Name
var planet_detail

var planet_details = load("res://Planet Assets/planet_detail.tscn")

var planet_params = {
	name = "",
	race = "",
	culture = "",
	wealth = 0,
	will = 0,
	inhabited = false,
	nearby = false
}

var connexion_route = []
var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)

func init_planet():
	#planet_params["name"] = generate_word("icarusinbreadanddemocracywecrust", 6)

	if randi() % 2:
		planet_params["inhabited"] = true
	else :
		planet_params["inhabited"] = false
	
	if planet_params["inhabited"] :
		planet_params["race"] = "humans"
		planet_params["culture"] = "dipshit"
		planet_params["wealth"] = randi_range(0,1000000)
		planet_params["will"] = randi_range(0,200) - 50
	else :
		planet_params["race"] = "none"
		planet_params["culture"] = "none"
		planet_params["wealth"] = 0
		planet_params["will"] = 0
	
	
	name_text.text = planet_params["name"]

func generate_word(chars, length):
	var word: String = ""
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

func init_sprite():
	base.self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0), 1.0)
	land.self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0), 1.0)
	land.position.x += randi_range(-256,256)
	land.position.y += randi_range(-256,256)
	land.rotate(deg_to_rad(randf_range(0, 180)))

func _on_details_toggled(toggled_on: bool) -> void:
	if toggled_on :
		var instance = planet_details.instantiate()
		add_child(instance)
		instance.position += Vector2(256, -1000)
		instance.fill_info($".")
		planet_detail = instance
	else :
		mainScene.valdiate_list.erase(planet_detail)
		planet_detail.queue_free()
