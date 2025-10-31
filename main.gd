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
	if player.fleet.fleet_params["fleet_position"] == "" :
		player.pcs.get_player_id()
		client.send_id(player.fleet.player_id)
		client.request_load_fleet_units(player.fleet)
		wait_server_call()

func post_server_init_player_pos():
	player.init_player()
	displace_player(player, player.on_planet(), 1)
	on_fleet_units_action()
	player.fleet.set_fleet_name()
	startup = false

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
		if fleet != player.fleet.player_id :
			var instance = fleet_obj.instantiate()
			instance.player_id = fleet
			instance.fleet_params["fleet_name"] = fleet_list[fleet][0]
			instance.fleet_params["fleet_position"] = fleet_list[fleet][1]
			if startup :
				displace_player(instance, find_planet(instance.fleet_params["fleet_position"]), 1)
			else :
				displace_player(instance, find_planet(instance.fleet_params["fleet_position"]), 10)
			fleetHolder.add_child(instance)
			instance.set_fleet_name()

func update_planet_data(planet_list):
	galaxy.planet_list = planet_list
	galaxy.update_galaxy_map()
	galaxy.update_galaxy_map_cfg()

func find_planet(planet_name):
	for planet in galaxy.placed_planet :
			if planet_name == planet.planet_params["name"] :
				return planet

func on_fleet_units_action():
	client.request_save_fleet_units(player.fleet)
	wait_server_call()
	_update_ship_status()

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

func _update_ship_status():
	fleetStatus.playerUI.ship_name.text = player.fleet.fleet_params["fleet_name"]
	fleetStatus.playerUI._init_upgrade()
	fleetStatus.playerUI._init_cooldown()
	for unit in player.fleet.get_child(0).get_children():
		fleetStatus.playerUI._update_unit_values(unit.unit_params)
		fleetStatus.playerUI._update_upgrade_values(unit.unit_params)
	fleetStatus.playerUI._update_PGR()
	fleetStatus.playerUI._update_cooldown()
	if !startup :
		client.request_save_fleet_units(player.fleet)
		wait_server_call()

func _deploy_unit(unit_type, planet_name):
	client.request_deploy_unit(player.fleet, unit_type, planet_name)
	wait_server_call()

func ftl_saver(planet_name):
	client.request_move_fleet(player.fleet.player_id, planet_name)
	wait_server_call()

func job_done(player_id, planet_name, unit_type):
	client.request_load_fleet_units(player.fleet)
	wait_server_call()
	galaxy.job_done(player_id, planet_name, unit_type)

func buy_item(item_id):
	client.request_buy_item(player.fleet.player_id, item_id)
	wait_server_call()

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
