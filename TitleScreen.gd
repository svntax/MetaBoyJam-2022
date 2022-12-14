extends Node2D

onready var menu = $Menu
onready var high_score_label = get_node("%HighScore")
onready var play_button = get_node("%PlayButton")
onready var controls_button = get_node("%ControlsButton")
onready var title_music = $TitleMusic
onready var animation_player = $AnimationPlayer

func _ready():
	# Default size 1280x720
	OS.window_size = Vector2(1280, 720)
	# Center the window after resizing
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

	high_score_label.set_text("High Score: " + str(Globals.high_score))
	title_music.play()
	play_button.grab_focus()

func _process(_delta):
	# Hacky fix for web build
	if not title_music.playing:
		title_music.play()
	
	var jump_pressed = Input.is_action_just_pressed("jump")
	if jump_pressed:
		var focus_owner = menu.get_focus_owner()
		if focus_owner == play_button:
			_on_PlayButton_pressed()
		elif focus_owner == controls_button:
			_on_ControlsButton_pressed()

func _on_PlayButton_pressed():
	animation_player.play("transition")
	SceneManager.switch_to_scene("res://Gameplay.tscn")
	#get_tree().change_scene("res://Gameplay.tscn")

func _on_ControlsButton_pressed():
	animation_player.play("transition")
	SceneManager.switch_to_scene("res://ControlsScreen.tscn", true)
	#get_tree().change_scene("res://ControlsScreen.tscn")
