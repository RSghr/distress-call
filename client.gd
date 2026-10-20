extends Node2D

## Shared between the client and server projects: keep both copies identical.
## The client only sends requests; the server answers with the authoritative state.

## WebSocket address of the server.
const SERVER_URL := "ws://distresscall.ddns.net:9009"
const BUFFER_SIZE := 4 * 1024 * 1024 # Must match server.gd

var client_id = ""  # Private: only ever sent to the server
var public_id = ""  # What other players see (given by the server)
var is_server := false
var registered := false
var mainScene

func _ready():
	is_server = ProjectSettings.get_setting("distress_call/is_server", false)
	mainScene = get_tree().root.get_child(0)
	if is_server:
		return
	var peer := WebSocketMultiplayerPeer.new()
	peer.inbound_buffer_size = BUFFER_SIZE
	peer.outbound_buffer_size = BUFFER_SIZE
	var result := peer.create_client(SERVER_URL)
	if result != OK:
		print("Failed to connect to server")
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_lost)
	multiplayer.server_disconnected.connect(_on_connection_lost)

func send_id(player_id) :
	client_id = player_id

func _on_connected_to_server():
	print("Connected! Sending ID: ", client_id)
	mainScene.server.rpc_id(1, "register_player", client_id)

func _on_connection_lost():
	print("Connection to the server lost")
	registered = false
	mainScene.deny_server_call()

#region Requests to the server
func request_fleet_state():
	mainScene.server.rpc_id(1, "request_fleet_state")

func request_deploy_unit(unit_type, planet_name):
	mainScene.server.rpc_id(1, "request_deploy_unit", int(unit_type), str(planet_name))

func request_move_fleet(planet_name):
	mainScene.server.rpc_id(1, "request_move_fleet", str(planet_name))

func request_rename(target, new_name):
	mainScene.server.rpc_id(1, "request_rename", str(target), str(new_name))

func request_buy_item(item_id):
	mainScene.server.rpc_id(1, "request_buy_item", str(item_id))

func request_send_report(feedbacktxt):
	mainScene.server.rpc_id(1, "request_send_report", str(feedbacktxt))
	mainScene.validate_server_call()
#endregion

#region Answers from the server
@rpc("authority", "call_remote", "reliable")
func confirm_registration(server_now, my_public_id, fleet_state, fleet_list, planet_list, payoutTimer, missions, network):
	if is_server:
		return
	registered = true
	public_id = my_public_id
	mainScene.update_planet_data(planet_list)
	mainScene.apply_fleet_state(server_now, fleet_state)
	mainScene.post_server_init_player_pos()
	fleet_list.erase(public_id)
	mainScene.init_fleets(fleet_list)
	for mission in missions:
		mainScene.galaxy.Unit_sent(mission[0], mission[1], mission[2])
	mainScene.prt.update_payout_timer(payoutTimer)
	mainScene.prt.update_network(network)
	mainScene.validate_server_call()
	print("Server confirmed registration for: ", client_id)

@rpc("authority", "call_remote", "reliable")
func registration_refused(reason):
	if is_server:
		return
	print("Registration refused: ", reason)
	mainScene.deny_server_call()

@rpc("authority", "call_remote", "reliable")
func fleet_state(server_now, state):
	if is_server or not registered:
		return
	mainScene.apply_fleet_state(server_now, state)

@rpc("authority", "call_remote", "reliable")
func deploy_result(success, unit_type, planet_name, reason):
	if is_server:
		return
	if success:
		mainScene.validate_server_call() # The unit icon arrives with unit_sent
	else:
		print("Deploy refused: ", reason)
		mainScene.deny_server_call()

@rpc("authority", "call_remote", "reliable")
func move_result(success, planet_name, collected, reason):
	if is_server:
		return
	if success:
		mainScene.on_fleet_moved(planet_name, collected)
		mainScene.validate_server_call()
	else:
		print("Move refused: ", reason)
		mainScene.deny_server_call()

@rpc("authority", "call_remote", "reliable")
func buy_result(success, item_id, reason):
	if is_server:
		return
	if success:
		mainScene.validate_server_call()
	else:
		print("Purchase of ", item_id, " refused: ", reason)
		mainScene.deny_server_call()

## Any player's unit left for a mission.
@rpc("authority", "call_remote", "reliable")
func unit_sent(owner_id, planet_name, unit_type):
	if is_server or not registered:
		return
	mainScene.galaxy.Unit_sent(owner_id, str(planet_name), unit_type)

@rpc("authority", "call_remote", "reliable")
func update_galaxy_map(planet_list):
	if is_server or not registered:
		return
	mainScene.update_planet_data(planet_list)

@rpc("authority", "call_remote", "reliable")
func fleet_update(fleet_list):
	if is_server or not registered:
		return
	fleet_list.erase(public_id)
	mainScene.init_fleets(fleet_list)

@rpc("authority", "call_remote", "reliable")
func job_done(planet_list, player_id, planet_name, unit_type):
	if is_server or not registered:
		return
	mainScene.update_planet_data(planet_list)
	mainScene.job_done(player_id, planet_name, unit_type)

@rpc("authority", "call_remote", "reliable")
func payout(planet_list, payoutTimer, network):
	if is_server or not registered:
		return
	mainScene.update_planet_data(planet_list)
	mainScene.prt.update_payout_timer(payoutTimer)
	mainScene.prt.update_network(network)
#endregion
