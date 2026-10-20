extends Control

@onready var unit_holder = $CooldownPanel/HBoxContainer
@onready var coreUnitCount = $CoreUnitPanel/MarginContainer/HBoxContainer/CoreUnitValue
@onready var payoutTimer = $PayoutPanel/HBoxContainer/VBoxContainer/MarginContainer/AlternateTimer
@onready var payoutDisplay = $PayoutPanel/HBoxContainer/VBoxContainer/MarginContainer/PayoutValue
@onready var payoutAmount = $PayoutPanel/HBoxContainer/PayoutAmount
@onready var version = $Version
@onready var tip_locate = $CooldownPanel/MarginContainer
@onready var planetDetail = $Planet_Container/Planet_Detail
@onready var animPlayer = $CooldownPanel/MarginContainer/AnimationPlayer
@onready var feedbackPnl = $FeedbackPnl

var player_focus = Vector2.ZERO
var tip_inc = 0
var tip_delay = 150
var mainScene

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)
	planetDetail.modulate.a = 0
	version.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	_build_module_bar()

func _process(_delta: float) -> void:
	_update_module_buttons()
	player_focus = mainScene.cam.position
	var dist = player_focus.distance_to(mainScene.player.position)
	if dist > 1000:
		tip_inc += 1
	else :
		tip_locate.visible = false
		tip_inc = 0

	if tip_inc >= tip_delay :
		tip_locate.visible = true
		
	if payoutTimer.timer_active :
		var timerleft = payoutTimer.remaining_time()
		var timerTxt = []
		if timerleft[0] / 10 < 1 :
			timerTxt.append("0" + str(int(timerleft[0])))
		else :
			timerTxt.append(str(int(timerleft[0])))
		if timerleft[1] / 10 < 1 :
			timerTxt.append("0" + str(int(timerleft[1])))
		else :
			timerTxt.append(str(int(timerleft[1])))
		payoutDisplay.text = timerTxt[0] + ":" + timerTxt[1]
	else :
		payoutDisplay.text = "--:--"

func update_payout_timer(payTime):
	payoutTimer.wait_time = int(round(payTime))  * 1000
	payoutTimer.start()

## Bonus for the largest group of linked conquered planets (applied at each payout).
func update_network(network):
	if network == null or network.get("size", 0) < 2:
		payoutAmount.text = ""
	else:
		payoutAmount.text = "Network %d\n+%d%%" % [network["size"], int(round(network["bonus"] * 100))]

func _on_feedback_button_down() -> void:
	if feedbackPnl.visible :
		feedbackPnl.hide()
	else :
		feedbackPnl.show()

#region MODULE BAR
## Equipped modules, just above the unit cooldown bar. Click to use.
var module_panel
var module_bar
var module_message
var module_buttons = {} # module id -> Button
var modules = {}        # module id -> data from the server
var module_message_serial = 0

func _build_module_bar():
	var theme_res = load("res://UI/Maintheme.tres")
	module_panel = PanelContainer.new()
	module_panel.theme = theme_res
	_anchor_bottom_center(module_panel, -131)
	module_panel.visible = false
	add_child(module_panel)
	module_bar = HBoxContainer.new()
	module_bar.add_theme_constant_override("separation", 8)
	module_panel.add_child(module_bar)

	module_message = Label.new()
	module_message.theme = theme_res
	module_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_anchor_bottom_center(module_message, -205)
	add_child(module_message)

func _anchor_bottom_center(control, bottom_offset):
	control.anchor_left = 0.5
	control.anchor_right = 0.5
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0
	control.offset_top = bottom_offset
	control.offset_bottom = bottom_offset
	control.grow_horizontal = Control.GROW_DIRECTION_BOTH
	control.grow_vertical = Control.GROW_DIRECTION_BEGIN

func update_modules(state):
	if state == null:
		return
	modules = state["modules"]
	for child in module_bar.get_children():
		child.queue_free()
	module_buttons.clear()
	for module_id in modules:
		if !modules[module_id]["equipped"]:
			continue
		var button = Button.new()
		button.custom_minimum_size = Vector2(190, 56)
		button.button_down.connect(_on_module_pressed.bind(module_id))
		button.mouse_entered.connect(_on_module_hovered.bind(module_id, true))
		button.mouse_exited.connect(_on_module_hovered.bind(module_id, false))
		module_bar.add_child(button)
		module_buttons[module_id] = button
	module_panel.visible = !module_buttons.is_empty()
	_update_module_buttons()

func server_now():
	return Time.get_ticks_msec() / 1000.0 + mainScene.player.fleet.server_offset

func _update_module_buttons():
	if module_buttons.is_empty():
		return
	var now = server_now()
	for module_id in module_buttons:
		var module = modules[module_id]
		var button = module_buttons[module_id]
		var remaining = int(module["ready_at"] - now)
		var status = "READY"
		if module["pending"]:
			status = "ACTIVE"
		elif remaining > 0:
			status = "%d:%02d" % [remaining / 60, remaining % 60]
		button.text = module["name"] + "\n" + status
		button.disabled = status != "READY"

func _on_module_pressed(module_id):
	mainScene.client.request_use_module(module_id)
	mainScene.wait_server_call()

func _on_module_hovered(module_id, hovering):
	if hovering:
		var module = modules[module_id]
		var text = module["desc"]
		if module["cu_cost"] > 0:
			text += "  (costs %d CU)" % module["cu_cost"]
		module_message.text = text
		module_message.modulate = Color.WHITE
	else:
		module_message.text = ""

func show_module_message(text, success):
	module_message_serial += 1
	var serial = module_message_serial
	module_message.text = text
	module_message.modulate = Color(0.6, 1, 0.6) if success else Color(1, 0.4, 0.4)
	await get_tree().create_timer(4.0).timeout
	if serial == module_message_serial:
		module_message.text = ""
#endregion

