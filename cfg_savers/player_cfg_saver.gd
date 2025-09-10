extends Node2D

const SAVE_PATH = "user://Player_Saver/player_id.txt"
const SAVE_CFG = "user://Fleet_Saver/"

var player_id = ""

var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)
	
func get_player_id():
	if FileAccess.file_exists(SAVE_PATH):
		var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
		player_id = f.get_line()
		if player_id == "" :
			_init_uuid()
		f.close()
	else:
		_init_uuid()
	mainScene.player.fleet.player_id = player_id
	
	# Send this ID to the server when connecting
	mainScene.client.send_id(player_id)

func _init_uuid():	
	player_id = OS.get_unique_id()
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_line(player_id)
	f.close()

func save_fleet_units(fleet):
	var config = ConfigFile.new()
	var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
	var currConfig = config.load(FLEET_PATH)
	
	if currConfig != OK:
		config.save(FLEET_PATH)
	
	#Fleet params
	for param in fleet.fleet_params.keys():
		config.set_value("Fleet", param, fleet.fleet_params[param])
	
	#Unit params
	for unit in fleet.unit_holder.get_children():
		for param in unit.unit_params.keys() :
			config.set_value(unit.name, param, unit.unit_params[param])
		unit.init_unit()
	config.save(FLEET_PATH)

func load_fleet_units(fleet):
	var config = ConfigFile.new()
	var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
	var currConfig = config.load(FLEET_PATH)
	
	if currConfig == OK:
		#Fleet params
		for param in fleet.fleet_params.keys():
			fleet.fleet_params[param] = config.get_value("Fleet", param, fleet.fleet_params[param])
		
		
		#Unit params
		for unit in fleet.unit_holder.get_children():
			for param in unit.unit_params.keys() :
				unit.unit_params[param] = config.get_value(unit.name, param, unit.unit_params[param])

#SAVE FLEET ACTION ONLY
func save_fleet_only(fleet):
	var config = ConfigFile.new()
	var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
	var currConfig = config.load(FLEET_PATH)
	
	if currConfig != OK:
		config.save(FLEET_PATH)
	
	#Fleet params
	for param in fleet.fleet_params.keys():
		config.set_value("Fleet", param, fleet.fleet_params[param])
	
	config.save(FLEET_PATH)

#SAVE UNIT ACTION ONLY
func save_units_only(fleet):
	var config = ConfigFile.new()
	var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
	var currConfig = config.load(FLEET_PATH)
	
	if currConfig != OK:
		config.save(FLEET_PATH)

	#Unit params
	for unit in fleet.unit_holder.get_children():
		for param in unit.unit_params.keys() :
			config.set_value(unit.name, param, unit.unit_params[param])
		unit.init_unit()
	config.save(FLEET_PATH)
