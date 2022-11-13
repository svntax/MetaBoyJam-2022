extends NinePatchRect

onready var header_label = $Header
onready var score_label = $Score
onready var main_menu_button = $MainMenuButton
onready var animation_player = $AnimationPlayer

onready var menu_active = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "display":
		menu_active = true

func _process(_delta):
	var jump_pressed = Input.is_action_just_pressed("jump")
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up") or jump_pressed:
		var focus_owner = get_focus_owner()
		if !focus_owner:
			main_menu_button.grab_focus()
		elif focus_owner == main_menu_button and jump_pressed:
			_on_MainMenuButton_pressed()

func display() -> void:
	animation_player.play("RESET")

func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")
