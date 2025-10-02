extends RichTextLabel

var fleet
var mainScene
var remaining = 0
var server_offset = 0

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)
	
func _init_cd():
	if server_offset == null or fleet == null:
		mainScene.fleetStatus.playerUI._init_cooldown()
	else :
		var now = Time.get_ticks_msec() / 1000.0 + server_offset
		remaining = fleet.fleet_params["next_available"] - now
		if remaining <= 0.0 :
			fleet.fleet_params["ftl"] = true
	#Replace that by how much is gotten from save

func cd_check():
	if server_offset == null or fleet == null:
		mainScene.fleetStatus.playerUI._init_cooldown()
	var now = Time.get_ticks_msec() / 1000.0 + server_offset
	return fleet.fleet_params["next_available"] <= now

func _process(_delta):
	text = "AVAILABLE"
	if fleet.fleet_params != null :
		if remaining > 0:
			_init_cd()
			text = "Back in : " + str(int(round(remaining))) + "s"
