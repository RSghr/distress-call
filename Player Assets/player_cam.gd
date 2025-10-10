extends Camera2D

@export var zoom_speed: float = 0.1     # How fast zoom changes
@export var min_zoom: float = 0.1       # Farthest zoom-out
@export var max_zoom: float = 2.0       # Closest zoom-in
@export var drag_speed: float = 1.0     # Speed multiplier for drag movement

var dragging := false
var last_mouse_pos := Vector2.ZERO
var zoom_status = 1.0

var mainScene

func _ready() -> void:
	mainScene = get_tree().root.get_child(0)

func _unhandled_input(event):
	# --- Mouse wheel zoom ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_towards_mouse(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_towards_mouse(zoom_speed)
		
		# --- Mouse drag start / end ---
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				last_mouse_pos = event.position
			else:
				dragging = false
	elif event is InputEventKey:
		if !event.echo:
			match event.keycode:
				KEY_SPACE: # delete to disable keyboard centering
					if event.pressed:
						position = Vector2.ZERO
				KEY_C:
					if event.pressed:
						position = mainScene.player.position

	# --- Mouse motion while dragging ---
	elif event is InputEventMouseMotion and dragging:
		var delta = event.relative * (1/zoom_status) * drag_speed
		position -= delta


# Smooth zoom centered on the mouse pointer
func _zoom_towards_mouse(amount: float):
	var new_zoom = clamp(zoom.x + amount, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
	zoom_status = new_zoom
