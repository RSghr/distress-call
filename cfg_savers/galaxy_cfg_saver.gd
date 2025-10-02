extends Node2D

const SAVE_PATH = "res://Galaxy_Saver/galaxy_saver.cfg"

var mainScene

func _ready() -> void:
	mainScene = get_tree().root.get_child(0)

func save_planet(p):
	var config = ConfigFile.new()
	var currConfig = config.load(SAVE_PATH)
	
	if currConfig == OK:
		for param in p.planet_params.keys():
			if param != "name" :
				config.set_value(p.planet_params["name"], param, p.planet_params[param])
		config.set_value(p.planet_params["name"], "position", p.position)
		config.set_value(p.planet_params["name"], "baseColor", p.base.self_modulate)
		config.set_value(p.planet_params["name"], "landColor", p.land.self_modulate)
		config.set_value(p.planet_params["name"], "landPos", p.land.position)
		config.set_value(p.planet_params["name"], "landRot", p.land.rotation)
	
	config.save(SAVE_PATH)

func load_planet(p):
	var config = ConfigFile.new()
	var currConfig = config.load(SAVE_PATH)
	
	if currConfig == OK:
		for param in p.planet_params.keys():
			if param != "name" :
				p.planet_params[param] = config.get_value(p.planet_params["name"], param, p.planet_params[param])
		p.position = config.get_value(p.planet_params["name"], "position")
		p.base.self_modulate = config.get_value(p.planet_params["name"], "baseColor")
		p.land.self_modulate =  config.get_value(p.planet_params["name"], "landColor")
		p.land.position = config.get_value(p.planet_params["name"], "landPos")
		p.land.rotation = config.get_value(p.planet_params["name"], "landRot")
