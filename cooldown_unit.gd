extends RichTextLabel

var unit
var mainScene
var remaining = 0
var server_offset = 0

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)
	
func _init_cd():
	if server_offset == null or unit == null:
		mainScene.fleetStatus.playerUI._init_cooldown()
	else :
		var now = Time.get_ticks_msec() / 1000.0 + server_offset
		remaining = unit.unit_params["next_available"] - now
		if remaining <= 0.0 :
			unit.return_to_ship()
	#Replace that by how much is gotten from save

func _process(_delta):
	text = "DEPLOYABLE"
	if unit.unit_params != null :
		if remaining > 0:
			_init_cd()
			text = "Back in : " + str(int(round(remaining))) + "s"
