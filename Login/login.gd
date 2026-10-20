extends Node2D

@onready var username = $LoginUI/UIGeneral/MarginContainer/VBoxContainer/Username
@onready var messagelog = $LoginUI/UIGeneral/MarginContainer/VBoxContainer/Message

const SAVE_PATH = "res://Player_Saver/Player_values.cfg"

var debugfleet = ""

var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)

func check_login(login):
	var config = ConfigFile.new()
	var currConfig = config.load(SAVE_PATH)
	
	if currConfig == OK:
		if config.get_value("PlayerList",login, "") != "" :
			return true
	return false

func save_login(login : String) -> void :
	var config = ConfigFile.new()
	var currConfig = config.load(SAVE_PATH)
	
	if currConfig == OK:
		if login == "":
			display_message("Enter a username")
			return
		if check_login(login):
			display_message("username already exists")
			return
		debugfleet = "fleet_save_" + generate_word(36)
		config.set_value("PlayerList", login, debugfleet)
		config.save(SAVE_PATH)
		display_message("you are in! " + username.text + " / " + debugfleet)

func generate_word(length):
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789"
	var word: String = ""
	var n_char = len(chars)
	var randchar = ''
	for i in range(length):
		randchar = chars[randi()% n_char]
		if randchar == "G" or randchar == "3" or randchar == "P" or randchar == "O" :
			randchar += "-"
		word += randchar
	if word[len(word) - 1] == "-" :
		word = word.left(-1)
	return word

func username_security(login : String):
	if login.to_lower().contains("nigger") or login.to_lower().contains("fag") or login.to_lower().contains("jew") or login.to_lower().contains(" ") or login.to_lower().contains("^") or login.to_lower().contains("ù") or login.to_lower().contains("$") or login.to_lower().contains("£") or login.to_lower().contains("*") or login.to_lower().contains("/") or login.to_lower().contains("_") or login.to_lower().contains("-") or login.to_lower().contains("+") or login.to_lower().contains("(") or login.to_lower().contains(")") or login.to_lower().contains("@") or login.to_lower().contains("{") or login.to_lower().contains("}") or login.to_lower().contains("[") or login.to_lower().contains("]") or login.to_lower().contains("|") or login.to_lower().contains("=") or login.to_lower().contains("\"") or login.to_lower().contains("\\") or login.to_lower().contains("/") or login.to_lower().contains(".") or login.to_lower().contains(",") or login.to_lower().contains("?") or login.to_lower().contains("!") or login.to_lower().contains(":") or login.to_lower().contains("<") or login.to_lower().contains(">") : 
		return false
	else:
		return true

func display_message(message) :
	messagelog.text = message

func _on_submit_button_down() -> void:
	if check_login(username.text) :
		display_message("You are logged in!")
	else :
		display_message("Username not found")

func _on_create_button_down() -> void:
	if username_security(username.text) :
		save_login(username.text)
