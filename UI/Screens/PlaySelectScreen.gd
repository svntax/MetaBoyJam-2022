extends Node2D

onready var start_button = get_node("%StartButton")
onready var practice_button = get_node("%PracticeButton")

func _ready():
	start_button.grab_focus()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.switch_to_scene("res://UI/Screens/TitleScreen.tscn", true)

func _on_StartButton_pressed():
	SceneManager.switch_to_scene("res://Gameplay.tscn")

func _on_PracticeButton_pressed():
	SceneManager.switch_to_scene("res://Maps/PracticeRoom.tscn", true)