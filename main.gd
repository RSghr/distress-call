extends Node2D

@onready var cam = $Camera2D
@onready var client = $Client
@onready var server = $Server
@onready var player = $Player
@onready var playerholder = $PlayerHolder
@onready var galaxy = $"Galaxy Map"
@onready var fleetStatus = $Fleet_Status

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
	displace_player(player.on_planet())
	player.init_player()
	_update_ship_status()
	on_fleet_units_action()
	startup = false

func displace_player(planet):
	player.position = planet.position + Vector2(0, -300)
	
func on_fleet_units_action():
	client.request_save_fleet_units(player.fleet)

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
	fleetStatus.playerUI.stationned.text = player.fleet.fleet_params["fleet_position"]
	player.calcul_curr_upgrades()
	for unit in player.fleet.get_child(0).get_children():
		fleetStatus.playerUI._update_unit_values(unit.unit_params)
		fleetStatus.playerUI._update_upgrade_values(unit.unit_params)
	fleetStatus.playerUI._update_PGR()
	fleetStatus.playerUI._update_cooldown()
	if !startup :
		client.request_save_fleet_units(player.fleet)

func _deploy_unit(unit_type, planet_name):
	client.request_deploy_unit(player.fleet, unit_type, planet_name)

func validate_server_call():
	for valid in valdiate_list:
		if valid != null :
			valid.play("Validate")

func deny_server_call():
	for valid in valdiate_list:
		if valid != null :
			valid.play("Deny")
