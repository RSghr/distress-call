extends Node2D

## Login / sign-up screen shown on top of the game until the server accepts the account.
## The server checks everything again; these checks only give quick feedback.

@onready var ui = $LoginUI
@onready var username = $LoginUI/UIGeneral/MarginContainer/VBoxContainer/Username
@onready var password = $LoginUI/UIGeneral/MarginContainer/VBoxContainer/Password
@onready var messagelog = $LoginUI/UIGeneral/MarginContainer/VBoxContainer/Message
@onready var submit = $LoginUI/UIGeneral/MarginContainer/VBoxContainer/Submit
@onready var create = $LoginUI/UIGeneral/MarginContainer/VBoxContainer/Create

const SAVE_DIR = "user://Player_Saver"
const SAVE_PATH = "user://Player_Saver/last_username.txt"
const MIN_LENGTH = 5
const MAX_USERNAME = 16

var mainScene

func _ready():
	mainScene = get_tree().root.get_child(0)
	if FileAccess.file_exists(SAVE_PATH):
		username.text = FileAccess.get_file_as_string(SAVE_PATH).strip_edges()
	password.text_submitted.connect(func(_text): _on_submit_button_down())
	set_connected(mainScene.get_node("Client").connected) # main.gd isn't ready yet here

func set_connected(is_connected: bool) -> void:
	submit.disabled = !is_connected
	create.disabled = !is_connected
	display_message("" if is_connected else "Connecting to the server...")

func show_login(message := "") -> void:
	ui.visible = true
	display_message(message)

func on_login_result(success: bool, message: String) -> void:
	if success:
		ui.visible = false
		password.text = ""
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
		var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f:
			f.store_line(username.text)
			f.close()
	else:
		display_message(message)
		submit.disabled = false
		create.disabled = false

func validate() -> bool:
	var regex = RegEx.new()
	regex.compile("^[A-Za-z0-9]{%d,%d}$" % [MIN_LENGTH, MAX_USERNAME])
	if regex.search(username.text) == null:
		display_message("Username: %d to %d letters or digits" % [MIN_LENGTH, MAX_USERNAME])
		return false
	if password.text.length() < MIN_LENGTH:
		display_message("Password: at least %d characters" % MIN_LENGTH)
		return false
	return true

func display_message(message) :
	messagelog.text = message

func _on_submit_button_down() -> void:
	if submit.disabled or not validate():
		return
	submit.disabled = true
	create.disabled = true
	display_message("Logging in...")
	mainScene.client.request_login(username.text, password.text)

func _on_create_button_down() -> void:
	if create.disabled or not validate():
		return
	submit.disabled = true
	create.disabled = true
	display_message("Creating account...")
	mainScene.client.request_create_account(username.text, password.text)
