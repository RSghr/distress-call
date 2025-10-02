extends Node2D

var client_id = ""

var is_server = false
var mainScene

func _ready():
	if is_server :
		pass
	else :
		mainScene = get_tree().root.get_child(0)
		var peer = ENetMultiplayerPeer.new()
		var result = peer.create_client("90.3.177.194", 9000) # IP + port
		if result != OK:
			print("Failed to connect to server")
			return
		multiplayer.multiplayer_peer = peer
		print("Connected to server", OS.get_unique_id())
		multiplayer.connected_to_server.connect(_on_connected_to_server)

func send_id(player_id) :
	client_id = player_id

func _on_connected_to_server():
	print("Connected! Sending ID: ", client_id)
	await get_tree().create_timer(1).timeout
	mainScene.server.rpc_id(1, "register_player", client_id)
	
#PLAYER-RPC
@rpc("authority")
func confirm_registration(server_offset, fleet_list, planet_list):
	if is_server:
		pass
	else :
		mainScene.player.fleet.server_offset = server_offset
		fleet_list.erase(client_id)
		mainScene.init_fleets(fleet_list)
		mainScene.update_planet_data(planet_list)
		mainScene.validate_server_call()
		print("✅ Server confirmed registration for: ", client_id)

@rpc("authority")
func update_galaxy_map(planet_list):
	if is_server:
		pass
	else :
		mainScene.update_planet_data(planet_list)

@rpc
func register_player(_player_id: String):
# On client, this will never run because it's only called on server
	if is_server:
		var peer = multiplayer.get_remote_sender_id()
		print("✅ Server registered:", _player_id, "from peer", peer)
	else:
		print("ℹ Client has register_player too") 

#FLEET-PRC
func request_load_fleet_units(fleet):
	await get_tree().create_timer(1).timeout
	mainScene.server.rpc_id(1, "request_load_fleet_units", fleet.player_id, fleet.fleet_params, fleet.scout.unit_params, fleet.troop.unit_params, fleet.negotiator.unit_params, fleet.colony.unit_params)

@rpc("authority")
func load_fleet_units(player_id, fleet_params, scout, troop, negotiator, colony):
	if is_server:
		pass
	else :
		print("✅ Server confirmed fleet loading for: ", player_id)
		mainScene.player.fleet.fleet_params = fleet_params
		
		for units in mainScene.player.fleet.unit_holder.get_children():
			if units.name == "Scout" :
				units.unit_params = scout
			elif units.name == "Troop" :
				units.unit_params = troop
			elif units.name == "Negotiator" :
				units.unit_params = negotiator
			elif units.name == "Colony" :
				units.unit_params = colony
		mainScene.validate_server_call()
		mainScene.post_server_init_player_pos()

func request_save_fleet_units(fleet):
	await get_tree().create_timer(1).timeout
	mainScene.server.rpc_id(1, "request_save_fleet_units", fleet.player_id, fleet.fleet_params, fleet.scout.unit_params, fleet.troop.unit_params, fleet.negotiator.unit_params, fleet.colony.unit_params)

@rpc("authority")
func save_fleet_units():
	if is_server :
		pass
	else :
		for unit in mainScene.player.fleet.unit_holder.get_children():
			unit.init_unit()
		print("Fleet & Units saved!")
		mainScene.validate_server_call()

#DEPLOY REQUEST
func request_deploy_unit(fleet, unit_type, planet_name):
	await get_tree().create_timer(1).timeout
	mainScene.server.rpc_id(1, "request_deploy_unit", fleet.player_id, unit_type, planet_name)

@rpc("authority")
func deploy_unit(deploy_status, unit_type, planet_name, player_wealth):
	if is_server :
		pass
	else :
		if deploy_status[0]:
			print("unit sent!")
			match unit_type:
				0 : #Troop
					mainScene.player.fleet.troop.unit_params["unit_position"] = str(planet_name)
					mainScene.player.fleet.troop.unit_params["deploying"] = false
					mainScene.player.fleet.troop.unit_params["next_available"] = deploy_status[1]
				1 : #Negotiator
					mainScene.player.fleet.negotiator.unit_params["unit_position"] = str(planet_name)
					mainScene.player.fleet.negotiator.unit_params["deploying"] = false
					mainScene.player.fleet.negotiator.unit_params["next_available"] = deploy_status[1]
				2 : #Scout
					mainScene.player.fleet.scout.unit_params["unit_position"] = str(planet_name)
					mainScene.player.fleet.scout.unit_params["deploying"] = false
					mainScene.player.fleet.scout.unit_params["next_available"] = deploy_status[1]
				3 : #Colony
					mainScene.player.fleet.colony.unit_params["unit_position"] = str(planet_name)
					mainScene.player.fleet.colony.unit_params["deploying"] = false
					mainScene.player.fleet.colony.unit_params["next_available"] = deploy_status[1]
			mainScene.fleetStatus.playerUI._update_cooldown()
			mainScene.fleetStatus.playerUI.playerGlobalResources.CoreUnit.text = str(player_wealth)
			mainScene.validate_server_call()
		else :
			print("unit still on cooldown!")
			mainScene.deny_server_call()

#COOLDOWN REQUEST
func request_load_cooldown(fleet):
	await get_tree().create_timer(1).timeout
	mainScene.server.rpc_id(1, "request_load_cooldown", fleet.player_id)

@rpc("authority")
func load_cooldown(cooldown_list):
	if is_server :
		pass
	else :
		print("loaded cooldowns")
		if cooldown_list == [-1,-1,-1,-1] :
			print("Error loading cooldowns")
		else :
			mainScene.player.fleet.troop.unit_params["next_available"] = cooldown_list[0]
			mainScene.player.fleet.negotiator.unit_params["next_available"] = cooldown_list[1]
			mainScene.player.fleet.scout.unit_params["next_available"] = cooldown_list[2]
			mainScene.player.fleet.colony.unit_params["next_available"] = cooldown_list[3]

#FTL CD REQUEST
func request_move_fleet(player_id):
	await get_tree().create_timer(1).timeout
	mainScene.server.rpc_id(1, "request_move_fleet", player_id)

func fleet_update(fleet_list):
	if is_server :
		pass
	else :
		mainScene.init_fleets(fleet_list)

@rpc("authority")
func move_fleet(ftl_result):
	if is_server :
		pass
	else :
		print("move_fleet")
		if ftl_result[0]:
			mainScene.player.fleet.fleet_params["next_available"] = ftl_result[1]
			mainScene.fleetStatus.playerUI._update_cooldown()
			mainScene.validate_server_call()
		else :
			print("unit still on cooldown!")
			mainScene.deny_server_call()

@rpc("authority")
func job_done(planet_list):
	if is_server :
		pass
	else :
		mainScene.galaxy.planet_list = planet_list
		mainScene.job_done()

@rpc("authority")
func payout(planet_list):
	if is_server :
		mainScene.start_payout_cycle()
	else :
		mainScene.galaxy.planet_list = planet_list
		request_load_fleet_units(mainScene.player.fleet)

#EXAMPLE REQUEST
func request_XXX():
	await get_tree().create_timer(1).timeout
	mainScene.server.rpc_id(1, "request_XXX")

@rpc("authority")
func XXX():
	if is_server :
		pass
	else :
		print("XXX")
