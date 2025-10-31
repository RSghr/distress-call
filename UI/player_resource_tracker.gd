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

func _process(_delta: float) -> void:
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

func _on_feedback_button_down() -> void:
	if feedbackPnl.visible :
		feedbackPnl.hide()
	else :
		feedbackPnl.show()
