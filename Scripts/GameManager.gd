extends Node

signal pause_toggled(is_paused : bool)

func _ready():
	get_tree().paused = true

func _input(event : InputEvent):
	if event.is_action_pressed("Pause"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	emit_signal("pause_toggled")
