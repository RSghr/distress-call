extends Node2D

@onready var cam = $Camera2D
@onready var client = $Client
@onready var server = $Server
@onready var player = $Player
@onready var playerholder = $PlayerHolder
@onready var galaxy = $"Galaxy Map"
@onready var fleetStatus = $Fleet_Status
@onready var fleetHolder = $FleetHolder

var fleet_obj = load("res://Player Assets/fleet_Other.tscn")

var startup = true

var valdiate_list

func _ready() -> void:
	valdiate_list = get_tree().get_nodes_in_group("validate")
	_init_player_pos()
	_update_ship_status()

func _init_player_pos():
	if player.fleet.fleet_params["fleet_position"] == "" :
		player.pcs.get_player_id()
		client.send_id(player.fleet.player_id)
		client.request_load_fleet_units(player.fleet)

func post_server_init_player_pos():
	client.request_load_cooldown(player.fleet)
	player.init_player()
	displace_player(player, player.on_planet())
	on_fleet_units_action()
	startup = false

func displace_player(player_target,planet):
	player_target.position = planet.position + Vector2(0, -300)

func init_fleets(fleet_list):
	for fleet_old in fleetHolder.get_children():
		fleet_old.queue_free()
	
	for fleet in fleet_list:
		if fleet != player.fleet.player_id :
			var instance = fleet_obj.instantiate()
			instance.player_id = fleet
			instance.fleet_params["fleet_position"] = fleet_list[fleet]
			displace_player(instance, find_planet(instance.fleet_params["fleet_position"]))
			fleetHolder.add_child(instance)

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
	_update_ship_status()

func switch_to_fleet_status():
	if cam.is_current() :
		fleetStatus.make_current()
		fleetStatus.visible = true
		player.visible = false
		galaxy.visible = false
		
	else :
		cam.make_current()
		fleetStatus.visible = false
		player.visible = true
		galaxy.visible = true

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

func _deploy_unit(unit_type, planet_name):
	client.request_deploy_unit(player.fleet, unit_type, planet_name)

func ftl_saver(planet_name):
	client.request_move_fleet(player.fleet.player_id, planet_name)

func job_done():
	client.request_load_fleet_units(player.fleet)
	galaxy.job_done()
	

func validate_server_call():
	for valid in valdiate_list:
		if valid != null :
			valid.play("Validate")

func deny_server_call():
	for valid in valdiate_list:
		if valid != null :
			valid.play("Deny")
