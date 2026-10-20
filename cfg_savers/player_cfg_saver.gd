extends Node2D

## Client side: only keeps this machine's player ID.
## All game data (fleet, Core Units, cooldowns, XP) is stored on the server.

const SAVE_DIR = "user://Player_Saver"
const SAVE_PATH = "user://Player_Saver/player_id.txt"

var player_id = ""

var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)

func get_player_id():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if FileAccess.file_exists(SAVE_PATH):
		var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
		player_id = f.get_line().strip_edges()
		f.close()
	if player_id == "" :
		_init_uuid()
	mainScene.player.fleet.player_id = player_id

	# Sent to the server when connecting
	mainScene.client.send_id(player_id)

func _init_uuid():
	player_id = OS.get_unique_id()
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_line(player_id)
	f.close()
