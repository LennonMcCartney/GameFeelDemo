extends Control

@onready var play_button : Button = $CenterContainer/VBoxContainer/PlayButton

func _ready():
	GameManager.pause_toggled.connect(toggle_pause)
	play_button.grab_focus()

func PlayButtonPressed():
	GameManager.toggle_pause()

func ExitButtonPressed():
	get_tree().quit()

func toggle_pause():
	visible = !visible
	if visible:
		play_button.grab_focus()
