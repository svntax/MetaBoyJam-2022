extends Node2D

onready var menu = $Menu
onready var play_button = get_node("%PlayButton")
onready var controls_button = get_node("%ControlsButton")

func _ready():
	# Default size 1280x720
	OS.window_size = Vector2(1280, 720)
	# Center the window after resizing
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

	play_button.grab_focus()

func _process(_delta):
	var jump_pressed = Input.is_action_just_pressed("jump")
	if jump_pressed:
		var focus_owner = menu.get_focus_owner()
		if focus_owner == play_button:
			_on_PlayButton_pressed()
		elif focus_owner == controls_button:
			_on_ControlsButton_pressed()

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Gameplay.tscn")

func _on_ControlsButton_pressed():
	get_tree().change_scene("res://ControlsScreen.tscn")
