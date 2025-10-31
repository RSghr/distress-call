extends Node

@onready var gcs = $GalaxyCFGSaver
@onready var pcs = $player_cfg_saver
@onready var ccs = $Cooldown_cfg_saver

const SAVE_PATH = "res://Player_Saver/Server_values.cfg"
const FEEDBACK_PATH = "res://Player_Saver/Server_values.cfg"
var port = 9000

var players = []

@export var players_loaded = 0

var is_server = false

var mainScene

func _ready():
	var config = ConfigFile.new()
	var currConfig = config.load(SAVE_PATH)
	
	if currConfig == OK:
		port = config.get_value("Server", "Port", port)
	
	mainScene = get_tree().root.get_child(0)
	if is_server :
		var peer = ENetMultiplayerPeer.new()
		var result = peer.create_server(port) # Port number
		if result != OK:
			mainScene.logging("Failed to start server")
			return
		multiplayer.multiplayer_peer = peer
		mainScene.logging("Server started on port " + str(port) + " - Version: " + ProjectSettings.get_setting("application/config/version"))

		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	mainScene.logging("Client connected: " + str(id))
	players.append(str(id))
	mainScene.display_player_list(players)

func _on_peer_disconnected(id):
	mainScene.logging("Client disconnected: " + str(id))
	players.erase(str(id))
	mainScene.display_player_list(players)

@rpc("any_peer") # clients can call this
func register_player(client_id):
	await get_tree().create_timer(1).timeout
	mainScene.logging("request to connect " + client_id)
	if pcs.get_player_id(client_id) != null :
		var peer = multiplayer.get_remote_sender_id()
		var now = mainScene.now_server()
		mainScene.client.rpc_id(peer, "confirm_registration", now, pcs.load_all_fleet(), gcs.send_main_planet_info(), mainScene.payoutTimer.time_left)

@rpc("any_peer")
func request_update_galaxy_map():
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		mainScene.client.rpc_id(peer, "update_galaxy_map", gcs.send_main_planet_info())

@rpc("any_peer")
func request_load_fleet_units(player_id, fleet_params, scout, troop, negotiator, colony):
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		pcs.load_fleet_units(player_id, fleet_params, scout, troop, negotiator, colony)
		mainScene.logging("loading data for " + player_id)
		mainScene.client.rpc_id(peer, "load_fleet_units", player_id, fleet_params, scout, troop, negotiator, colony)

@rpc("any_peer")
func request_save_fleet_units(player_id, fleet_params, scout, troop, negotiator, colony):
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		pcs.save_fleet_units(player_id, fleet_params, scout, troop, negotiator, colony)
		mainScene.logging("Saving data for " + player_id)
		mainScene.client.rpc_id(peer, "save_fleet_units")

#DEPLOY-RPC
@rpc("any_peer") # clients can call this
func request_deploy_unit(player_id, unit_type, planet_name):
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		mainScene.logging("Deploying unit : " + str(unit_type) + " for " + player_id)
		mainScene.client.rpc_id(peer, "deploy_unit", ccs.deploy_unit_saver(player_id, unit_type, planet_name), unit_type, planet_name, pcs.unit_cost(player_id, unit_type))

@rpc("any_peer") # clients can call this
func request_load_cooldown(player_id):
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		mainScene.logging("Loading cooldowns for " + player_id)
		mainScene.client.rpc_id(peer, "load_cooldown", ccs.load_all_cooldown(player_id))

@rpc("any_peer") # clients can call this
func request_move_fleet(player_id, planet_name):
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		mainScene.logging("request_move_fleet " + player_id)
		mainScene.client.rpc_id(peer, "move_fleet", ccs.move_fleet_saver(player_id, planet_name), gcs.send_player_storedCU(player_id, planet_name))
		mainScene.client.rpc("fleet_update", pcs.load_all_fleet())

func cooldown_done(player_id, planet_name, unit_type):
	if is_server :
		match unit_type:
			0 : #Troop
				gcs.troop_job_done(planet_name, player_id)
			1 : #Negotiator
				gcs.negotiator_job_done(planet_name, player_id)
			2 : #Scout
				gcs.scout_job_done(planet_name, player_id)
			3 : #Colony
				gcs.colony_job_done(planet_name, player_id)
	
	mainScene.client.rpc("job_done", gcs.send_main_planet_info(), player_id, planet_name, unit_type)

func payout():
	if is_server :
		gcs.generate_storecCU()
		mainScene.start_payout_cycle()
		mainScene.client.rpc("payout", gcs.send_main_planet_info(), mainScene.payoutTimer.time_left)

@rpc("any_peer") # clients can call this
func request_buy_item(player_id, item_id):
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		mainScene.logging("Buying " + item_id)
		mainScene.client.rpc_id(peer, "buy_item", pcs.check_upgrade_bool())

@rpc("any_peer") # clients can call this
func request_send_report(feedbacktxt):
	if is_server :
		mainScene.logging("request_send_report")
		var config = ConfigFile.new()
		var currConfig = config.load(FEEDBACK_PATH)
		var peer = multiplayer.get_remote_sender_id()
		if currConfig == OK :
			config.set(peer, feedbacktxt)

@rpc("any_peer") # clients can call this
func request_XXX():
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		mainScene.logging("XXX")
		mainScene.client.rpc_id(peer, "XXX", pcs.check_upgrade_bool())
