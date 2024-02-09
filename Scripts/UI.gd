extends Control

func _ready():
	GameManager.pause_toggled.connect(toggle_pause)

func PlayButtonPressed():
	GameManager.toggle_pause()

func ExitButtonPressed():
	get_tree().quit()

func toggle_pause():
	visible = !visible
