extends Node

## Shared between the client and server projects: keep both copies identical.
## Godot matches RPCs by node path and by the list of @rpc functions, so the
## same file must exist at /root/Main/Server in both projects.
##
## Every request uses the player ID registered for the sender's connection,
## never an ID sent by the client, and every rule is checked here.

const DEFAULT_PORT := 9009
## The full galaxy (500 planets) is larger than WebSocket's default 64 KB buffer
const BUFFER_SIZE := 4 * 1024 * 1024

var is_server := false
var mainScene
var peers := {} # peer id -> player id

@onready var gcs = get_node_or_null("GalaxyCFGSaver")
@onready var pcs = get_node_or_null("player_cfg_saver")
@onready var ccs = get_node_or_null("Cooldown_cfg_saver")
@onready var scs = get_node_or_null("ShopCFGSaver")

func _ready():
	is_server = ProjectSettings.get_setting("distress_call/is_server", false)
	mainScene = get_tree().root.get_child(0)
	if not is_server:
		return

	var port: int = mainScene.get_port(DEFAULT_PORT)
	var peer := WebSocketMultiplayerPeer.new()
	peer.inbound_buffer_size = BUFFER_SIZE
	peer.outbound_buffer_size = BUFFER_SIZE
	var result := peer.create_server(port)
	if result != OK:
		mainScene.logging("Failed to start server on port " + str(port))
		return
	multiplayer.multiplayer_peer = peer
	mainScene.logging("Server started on port " + str(port) + " - Version: " + ProjectSettings.get_setting("application/config/version"))
	mainScene.logging("Local IPs:" + str(IP.get_local_addresses()))
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	mainScene.logging("Client connected: " + str(id))
	mainScene.display_player_list(_player_list())

func _on_peer_disconnected(id):
	mainScene.logging("Client disconnected: " + str(id) + " (" + str(peers.get(id, "unregistered")) + ")")
	peers.erase(id)
	mainScene.display_player_list(_player_list())

func _player_list() -> Array:
	var list := []
	for id in multiplayer.get_peers():
		list.append(str(id) + " - " + str(peers.get(id, "unregistered")))
	return list

## Player ID of the peer that sent the current RPC, or "" if it never registered.
func _sender_player() -> String:
	return peers.get(multiplayer.get_remote_sender_id(), "")

func _peer_of(player_id: String) -> int:
	for id in peers:
		if peers[id] == player_id:
			return id
	return 0

func _send_fleet_state(peer: int, player_id: String) -> void:
	mainScene.client.rpc_id(peer, "fleet_state", mainScene.now_server(), pcs.get_fleet_state(player_id))

#region Requests from clients
@rpc("any_peer", "call_remote", "reliable")
func register_player(player_id: String):
	if not is_server:
		return
	var peer := multiplayer.get_remote_sender_id()
	if not pcs.register_player(player_id):
		mainScene.logging("Refused registration for invalid id: " + player_id)
		mainScene.client.rpc_id(peer, "registration_refused", "Invalid player id")
		return
	peers[peer] = player_id
	mainScene.display_player_list(_player_list())
	mainScene.logging("Registered " + player_id + " on peer " + str(peer))
	mainScene.client.rpc_id(peer, "confirm_registration", mainScene.now_server(), pcs.get_fleet_state(player_id),
		pcs.load_all_fleet(), gcs.send_main_planet_info(), mainScene.payoutTimer.time_left)
	# The new fleet may be visible to the others
	mainScene.client.rpc("fleet_update", pcs.load_all_fleet())

@rpc("any_peer", "call_remote", "reliable")
func request_fleet_state():
	if not is_server:
		return
	var player_id := _sender_player()
	if player_id != "":
		_send_fleet_state(multiplayer.get_remote_sender_id(), player_id)

@rpc("any_peer", "call_remote", "reliable")
func request_update_galaxy_map():
	if is_server:
		mainScene.client.rpc_id(multiplayer.get_remote_sender_id(), "update_galaxy_map", gcs.send_main_planet_info())

@rpc("any_peer", "call_remote", "reliable")
func request_deploy_unit(unit_type: int, planet_name: String):
	if not is_server:
		return
	var player_id := _sender_player()
	if player_id == "":
		return
	var peer := multiplayer.get_remote_sender_id()
	var error: String = ccs.deploy_unit(player_id, unit_type, planet_name)
	_send_fleet_state(peer, player_id)
	mainScene.client.rpc_id(peer, "deploy_result", error == "", unit_type, planet_name, error)

@rpc("any_peer", "call_remote", "reliable")
func request_move_fleet(planet_name: String):
	if not is_server:
		return
	var player_id := _sender_player()
	if player_id == "":
		return
	var peer := multiplayer.get_remote_sender_id()
	var result: Dictionary = ccs.move_fleet(player_id, planet_name)
	_send_fleet_state(peer, player_id)
	mainScene.client.rpc_id(peer, "move_result", result["error"] == "", planet_name, result["collected"], result["error"])
	if result["error"] == "":
		mainScene.client.rpc("fleet_update", pcs.load_all_fleet())
		if result["collected"] > 0:
			mainScene.client.rpc("update_galaxy_map", gcs.send_main_planet_info())

@rpc("any_peer", "call_remote", "reliable")
func request_rename(target: String, new_name: String):
	if not is_server:
		return
	var player_id := _sender_player()
	if player_id == "" or not pcs.rename(player_id, target, new_name):
		return
	_send_fleet_state(multiplayer.get_remote_sender_id(), player_id)
	if target == "Fleet":
		mainScene.client.rpc("fleet_update", pcs.load_all_fleet())

@rpc("any_peer", "call_remote", "reliable")
func request_buy_item(item_id: String):
	if not is_server:
		return
	var player_id := _sender_player()
	if player_id == "":
		return
	var peer := multiplayer.get_remote_sender_id()
	var error: String = scs.buy_item(player_id, item_id)
	_send_fleet_state(peer, player_id)
	mainScene.client.rpc_id(peer, "buy_result", error == "", item_id, error)

@rpc("any_peer", "call_remote", "reliable")
func request_send_report(feedbacktxt: String):
	if is_server:
		mainScene.logging("Feedback received from " + _sender_player())
		mainScene.log_report(_sender_player(), feedbacktxt.left(2000))
#endregion

#region Server events
## A unit's mission timer ended (called by the cooldown saver).
func cooldown_done(player_id: String, planet_name: String, unit_type: int) -> void:
	if not is_server:
		return
	var strength: float = pcs.total_strength(player_id, unit_type)
	match unit_type:
		0: gcs.troop_job_done(planet_name, strength)
		1: gcs.negotiator_job_done(planet_name, strength)
		2: gcs.scout_job_done(planet_name, strength)
		3: gcs.colony_job_done(planet_name, strength)
	pcs.give_exp(player_id, unit_type)
	mainScene.logging("%s's %s finished its mission on %s" % [player_id, pcs.UNIT_SECTIONS[unit_type], planet_name])

	var peer := _peer_of(player_id)
	if peer != 0:
		_send_fleet_state(peer, player_id)
	mainScene.client.rpc("job_done", gcs.send_main_planet_info(), player_id, planet_name, unit_type)

func payout() -> void:
	if not is_server:
		return
	gcs.generate_stored_cu()
	mainScene.start_payout_cycle()
	mainScene.client.rpc("payout", gcs.send_main_planet_info(), mainScene.payoutTimer.time_left)
#endregion
