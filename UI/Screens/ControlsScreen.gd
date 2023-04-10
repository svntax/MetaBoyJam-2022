extends Node2D

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.switch_to_scene("res://UI/Screens/LoginScreen.tscn", true)
