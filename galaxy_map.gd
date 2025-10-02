extends Node2D

@onready var gcs = $GalaxyCFGSaver
const SAVE_PATH = "res://Galaxy_Saver/galaxy_saver.cfg"

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
	generate_galaxy()
	mainScene = get_tree().root.get_child(0)

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

func _draw() -> void:
	draw_circle(position, galaxy_radius + 200.0, Color.YELLOW_GREEN, false, 100.0)
	for line in connexion_line:
		if !conquered_line.has(line):
			draw_line(line[0].position, line[1].position, Color.SLATE_BLUE, 10.0)
	for line in conquered_line:
		draw_line(line[0].position, line[1].position, Color.GREEN, 10.0)

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

func job_done():
	update_galaxy_map()
	update_galaxy_map_cfg()
	mainScene._update_ship_status()
