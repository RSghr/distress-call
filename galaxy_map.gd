extends Node2D

@onready var gcs = $GalaxyCFGSaver
const SAVE_PATH = "res://Galaxy_Saver/galaxy_saver.cfg"
var unit_display = load("res://UI/unit_display.tscn")
var num_planets = 500
var galaxy_radius : float = 10000.0
var min_distance : float = 500.0
var placed_planet = []
var connexion_line = []
var conquered_line = []
var lineog
var linetar

var planet_list = {}
var mainScene

func _ready() -> void:
	mainScene = get_tree().root.get_child(0)
	generate_galaxy()

func generate_galaxy():
	for i in range(num_planets):
		var p = preload("res://Planet Assets/planet.tscn").instantiate()
		add_child(p)
		
		p.planet_params["name"] = p.name_text.planet_name_list[i]
		
		gcs.load_planet(p) #LOAD SAVE
		
		#p.position = get_valid_position() #CREATE SAVE
		placed_planet.append(p)
		p.name = p.name_text.planet_name_list[i]
		p.name_text.text = p.name_text.planet_name_list[i]
		get_connexions(p)
		get_conquered(p)		
		#gcs.save_planet(p) #CREATE SAVE
	print("planet count before : ", get_child_count())
	
	for plt in get_children() :
		if is_line_connected(plt) :
			plt.queue_free()
	print("planet count : ", get_child_count())
	num_planets = get_child_count()

func is_line_connected(plt):
	for p in connexion_line :
		if plt == p[0] or plt == p[1] :
			return false
	return true
		
func get_valid_position():
	while true:
		# Pick a random spot in disc
		var theta = randf() * TAU
		var r = sqrt(randf()) * galaxy_radius
		var pos = Vector2(cos(theta), sin(theta)) * r
		
		# Check against already placed planets
		var valid = true
		for p in placed_planet:
			if pos.distance_to(p.position) < min_distance:
				valid = false
				break
		
		if valid:
			return pos
			
func get_connexions(planet):
	for p in placed_planet :
		if p != planet :
			if p.position.distance_to(planet.position) < 1000 :
				connexion_line.append([p,planet])

func get_conquered(planet):
	for p in placed_planet :
		if p != planet :
			if p.position.distance_to(planet.position) < 1000  and p.planet_params["conquered"] and planet.planet_params["conquered"]:
				conquered_line.append([p,planet])

func get_conquered_amount():
	var conquered_list = []
	for p in placed_planet :
		if p.planet_params["conquered"] :
			conquered_list.append(p)
	return conquered_list

func _draw() -> void:
	draw_circle(position, galaxy_radius + 200.0, Color.YELLOW_GREEN, false, 100.0)
	for line in connexion_line:
		if !conquered_line.has(line):
			draw_line(line[0].position, line[1].position, Color.DARK_SLATE_BLUE, 15.0)
			draw_line(line[0].position, line[1].position, Color.SLATE_BLUE, 5.0)
	for line in conquered_line:
		draw_line(line[0].position, line[1].position, Color.DARK_GREEN, 15.0)
		draw_line(line[0].position, line[1].position, Color.GREEN, 5.0)

func update_galaxy_map():
	for planet in placed_planet :
		var planet_name = planet.name
		if planet_list.has(planet_name):
			var summary = planet_list[planet_name]
			for key in summary.keys():
				if planet.planet_params.has(key):
					planet.planet_params[key] = summary[key]
		if planet.planet_params["conquered"] :
			planet.conquered.self_modulate.a = 1
		else :
			planet.conquered.self_modulate.a = 0
		get_conquered(planet)
		planet.contains_storedCU()
	queue_redraw()

func update_galaxy_map_cfg():
	var config = ConfigFile.new()
	var currConfig = config.load(SAVE_PATH)
	
	if currConfig == OK:
		for planet in placed_planet :
			var planet_name = planet.name
			if planet_list.has(planet_name):
				var summary = planet_list[planet_name]
				for key in summary.keys():
					if planet.planet_params.has(key):
						config.set_value(planet_name, key, planet_list[planet_name][key])
		config.save(SAVE_PATH)

func job_done(player_id, planet_name, unit_type):
	update_galaxy_map()
	update_galaxy_map_cfg()
	mainScene._update_ship_status()
	unit_gone(player_id, planet_name, unit_type)

func Unit_sent(player_id, planet_name, unit_type):
	if unit_type < 4 :
		var instance = unit_display.instantiate()
		for planet in placed_planet :
			if planet_name == planet.name :
				instance.planet_name = planet_name
				instance.type = unit_type
				instance.player_id = player_id
				planet.add_child(instance)

func unit_gone(player_id, planet_name, unit_type):
	if unit_type < 4 :
		for planet in placed_planet :
			for unit in planet.get_children():
				if unit.name == player_id + "_" + str(unit_type) + "_" + planet_name :
					unit.queue_free()

func reset_storedCU(planet_name):
	if planet_list.has(planet_name):
		var claimedPlanet = planet_list[planet_name]
		claimedPlanet.planet_params["storedCU"] = 0
