extends Control

@onready var unit_holder = $CooldownPanel/HBoxContainer
@onready var coreUnitCount = $CoreUnitPanel/MarginContainer/HBoxContainer/CoreUnitValue
@onready var payoutTimer = $PayoutPanel/MarginContainer/AlternateTimer
@onready var payoutDisplay = $PayoutPanel/MarginContainer/PayoutValue
@onready var version = $Version

func _ready() -> void:
	version.text = "Version: " + ProjectSettings.get_setting("application/config/version")

func _process(_delta: float) -> void:
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
