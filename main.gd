extends Node2D

@onready var cam = $Camera2D
@onready var client = $Client
@onready var server = $Server
@onready var player = $Player
@onready var playerholder = $PlayerHolder
@onready var galaxy = $"Galaxy Map"
@onready var fleetStatus = $Fleet_Status
@onready var fleetHolder = $FleetHolder
@onready var audio_ost = $SpaceExplorationOst
@onready var prt = $"Player UI/PlayerResourceTracker"
@onready var login = $Login

var fleet_obj = load("res://Player Assets/fleet_Other.tscn")

var startup = true

var planet_detail_list = []

func _ready() -> void:
	_init_player_pos()
	_update_ship_status()

func _unhandled_input(event):
	if event.is_action_pressed("Increase_Volume") and audio_ost.volume_db < 5:
		audio_ost.volume_db += 10
	elif event.is_action_pressed("Decrease_Volume") and audio_ost.volume_db > -50:
		audio_ost.volume_db -= 10
	elif event.is_action_pressed("CloseAll") :
		if fleetStatus.visible :
			fleetStatus.playerUI._on_back_button_down()
		for planet in get_tree().get_nodes_in_group("Planets") :
			if !planet.viewed:
				planet._on_details_toggled(false)

func _init_player_pos():
	# The server sends the fleet once registration is confirmed (see client.gd)
	player.pcs.get_player_id()
	client.send_id(player.fleet.player_id)
	wait_server_call()

func post_server_init_player_pos():
	if !startup:
		return
	player.init_player()
	displace_player(player, player.on_planet(), 1)
	player.fleet.set_fleet_name()
	_update_ship_status()
	startup = false

## Applies the fleet data sent by the server, which is the only source of truth.
func apply_fleet_state(server_now, state):
	player.fleet.server_offset = server_now - Time.get_ticks_msec() / 1000.0
	for key in state["fleet"]:
		player.fleet.fleet_params[key] = state["fleet"][key]
	player.fleet.unit_costs = state.get("costs", {})
	for unit in player.fleet.unit_holder.get_children():
		if state["units"].has(unit.name):
			for key in state["units"][unit.name]:
				unit.unit_params[key] = state["units"][unit.name][key]
		unit.init_unit()
	player.fleet.set_fleet_name()
	_update_ship_status()
	fleetStatus.playerUI.update_investment(state.get("investment"))
	fleetStatus.playerUI.update_research(state.get("research"))

func on_investment_update(investment):
	fleetStatus.playerUI.update_investment(investment)

#Login
func on_connection_changed(is_connected):
	if !is_connected:
		login.show_login()
	login.set_connected(is_connected)

func on_login_result(success, message):
	login.on_login_result(success, message)

## The server accepted an FTL jump.
func on_fleet_moved(planet_name, _collected):
	var planet = find_planet(planet_name)
	if planet == null:
		return
	player.current_planet = planet
	player.reset_route()
	player.possible_routes()
	player.enable_route()
	displace_player(player, planet, 10)

#func displace_player(player_target,planet):
	#player_target.position = planet.position + Vector2(0, -300)

func displace_player(player_fleet, destination, duration) -> void:

	var fleet_destination = destination.position + Vector2(0, -300)
	# Create a new tween
	var tween = create_tween()
	tween.tween_property(player_fleet, "position", fleet_destination, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func init_fleets(fleet_list):
	for fleet_old in fleetHolder.get_children():
		fleet_old.queue_free()
	
	for fleet in fleet_list:
		if fleet != client.public_id :
			var destination = find_planet(fleet_list[fleet][1])
			if destination == null :
				continue
			var instance = fleet_obj.instantiate()
			instance.player_id = fleet
			instance.fleet_params["fleet_name"] = fleet_list[fleet][0]
			instance.fleet_params["fleet_position"] = fleet_list[fleet][1]
			if startup :
				displace_player(instance, destination, 1)
			else :
				displace_player(instance, destination, 10)
			fleetHolder.add_child(instance)
			instance.set_fleet_name()

func update_planet_data(planet_list):
	galaxy.planet_list = planet_list
	galaxy.update_galaxy_map()

func find_planet(planet_name):
	for planet in galaxy.placed_planet :
			if planet_name == planet.planet_params["name"] :
				return planet

func switch_to_fleet_status():
	if cam.is_current() :
		fleetStatus.make_current()
		fleetStatus.visible = true
		player.visible = false
		galaxy.visible = false
		prt.visible = false
		fleetHolder.visible = false
		
	else :
		cam.make_current()
		fleetStatus.visible = false
		player.visible = true
		galaxy.visible = true
		prt.visible = true
		fleetHolder.visible = true

## Refreshes the fleet screens from the local copy of the server state. Never saves.
func _update_ship_status():
	fleetStatus.playerUI.ship_name.text = player.fleet.fleet_params["fleet_name"]
	fleetStatus.playerUI._init_cooldown()
	for unit in player.fleet.unit_holder.get_children():
		fleetStatus.playerUI._update_unit_values(unit.unit_params)
	fleetStatus.playerUI._update_PGR()
	fleetStatus.playerUI._update_cooldown()

func rename(target, new_name):
	client.request_rename(target, new_name)
	wait_server_call()

func _deploy_unit(unit_type, planet_name):
	client.request_deploy_unit(unit_type, planet_name)
	wait_server_call()

func ftl_saver(planet_name):
	client.request_move_fleet(planet_name)
	wait_server_call()

## A mission finished (any player's). Our own fleet state arrives separately.
func job_done(player_id, planet_name, unit_type):
	galaxy.job_done(player_id, planet_name, unit_type)

#Server Comms status
func validate_server_call():
	for valid in get_tree().get_nodes_in_group("validate"):
		if valid != null :
			valid.play("Validate")

func deny_server_call():
	for valid in get_tree().get_nodes_in_group("validate"):
		if valid != null :
			valid.play("Deny")

func wait_server_call():
	for valid in get_tree().get_nodes_in_group("validate"):
		if valid != null :
			valid.play("Loading")

func _on_space_exploration_ost_finished() -> void:
	audio_ost.play()
