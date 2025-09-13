extends Node

@onready var gcs = $GalaxyCFGSaver
@onready var pcs = $player_cfg_saver
@onready var ccs = $Cooldown_cfg_saver

var players = []

@export var players_loaded = 0

var is_server = false

var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)
	if is_server :
		var peer = ENetMultiplayerPeer.new()
		var result = peer.create_server(9000) # Port number
		if result != OK:
			mainScene.logging("Failed to start server")
			return
		multiplayer.multiplayer_peer = peer
		mainScene.logging("Server started on port 9000")

		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	mainScene.logging("Client connected: " + str(id))
	players.append(id)

func _on_peer_disconnected(id):
	mainScene.logging("Client disconnected: " + str(id))
	players.erase(id)

@rpc("any_peer") # clients can call this
func register_player(client_id):
	await get_tree().create_timer(1).timeout
	mainScene.logging("request to connect " + client_id)
	pcs.get_player_id(client_id)
	if pcs.player_id != null :
		var peer = multiplayer.get_remote_sender_id()
		var now = mainScene.now_server()
		mainScene.client.rpc_id(peer, "confirm_registration", now, pcs.load_all_fleet())

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
		mainScene.client.rpc_id(peer, "deploy_unit", ccs.deploy_unit_saver(player_id, unit_type, planet_name), unit_type, planet_name)

@rpc("any_peer") # clients can call this
func request_load_cooldown(player_id):
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		mainScene.logging("Loading cooldowns for " + player_id)
		mainScene.client.rpc_id(peer, "load_cooldown", ccs.load_all_cooldown(player_id))

@rpc("any_peer") # clients can call this
func request_XXX():
	if is_server :
		var peer = multiplayer.get_remote_sender_id()
		mainScene.logging("XXX")
		mainScene.client.rpc_id(peer, "XXX", pcs.check_upgrade_bool())
		
