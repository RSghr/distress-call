extends Node2D

const SAVE_CFG = "user://Fleet_Saver/"

func save_cooldown(fleet):
	var config = ConfigFile.new()
	var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
	var currConfig = config.load(FLEET_PATH)
	
	if currConfig != OK:
		config.save(FLEET_PATH)
		
	#Unit params
	for unit in fleet.unit_holder.get_children():
		config.set_value(unit.name, "next_available", unit.next_available)
		
	config.save(FLEET_PATH)
	
func save_cooldown_unique(fleet, unit):
	var config = ConfigFile.new()
	var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
	var currConfig = config.load(FLEET_PATH)
	
	if currConfig != OK:
		config.save(FLEET_PATH)
		
	config.set_value(unit.name, "next_available", unit.next_available)
		
	config.save(FLEET_PATH)

func load_all_cooldown(fleet): #true : deployable / false : not yet
	var config = ConfigFile.new()
	var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
	var currConfig = config.load(FLEET_PATH)
	
	if currConfig != OK:
		return false
	
	for unit in fleet.unit_holder.get_children():
		if unit.next_available > config.get_value(unit.name, "next_available", unit.next_available) :
			config.set_value(unit.name, "next_available", unit.next_available)
			save_cooldown_unique(fleet, unit)
			config.save(FLEET_PATH)
		else :
			unit.next_available = config.get_value(unit.name, "next_available")

func load_cooldown(fleet, unit): #true : deployable / false : not yet
	var config = ConfigFile.new()
	var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
	var currConfig = config.load(FLEET_PATH)
	
	if currConfig != OK:
		return false
	
	if unit.next_available > config.get_value(unit.name, "next_available", unit.next_available) :
		config.set_value(unit.name, "next_available", unit.next_available)
		save_cooldown_unique(fleet, unit)
		config.save(FLEET_PATH)
	else :
		unit.next_available = config.get_value(unit.name, "next_available")

func deploy_unit_saver(fleet, unit, planet):
	var now = Time.get_ticks_msec() / 1000.0
	
	load_cooldown(fleet, unit)
	
	if unit.next_available > now :
		print(str(unit.unit_params["unit_type"]) + " still cooling down!")
	else :
		print("Deploying " + str(unit.unit_params["unit_type"]))
		unit.next_available = now + unit.COOLDOWN[unit.name]
		unit.unit_params["unit_position"] = planet
		unit.unit_params["deployable"] = false
		save_cooldown_unique(fleet, unit)

func cooldown_done(fleet, unit):
	if !unit.unit_params["deploying"] :
		return
	else :
		var config = ConfigFile.new()
		var FLEET_PATH = SAVE_CFG + "fleet_save_" + fleet.player_id + ".cfg"
		var currConfig = config.load(FLEET_PATH)
		
		if currConfig != OK:
			config.save(FLEET_PATH)
			
		unit.unit_params["unit_position"] = "Fleet"
		unit.unit_params["deployable"] = true
		unit.next_available = 0.0
		
		save_cooldown_unique(fleet, unit)
			
		config.save(FLEET_PATH)
