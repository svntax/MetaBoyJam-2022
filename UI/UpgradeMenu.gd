extends NinePatchRect

signal menu_closed()

onready var jump_button = get_node("%JumpButton")
onready var heart_button = get_node("%HeartButton")
onready var effects_player = $EffectsPlayer
onready var heart_upgrade_sound = $HeartUpgradeSound
onready var jump_upgrade_sound = $JumpUpgradeSound

onready var menu_active = false
onready var player = get_tree().get_nodes_in_group("Players")[0]

func _ready():
	hide()

func _process(_delta):
	if not menu_active:
		return
	
	var jump_pressed = Input.is_action_just_pressed("jump")
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right") or jump_pressed:
		var focus_owner = get_focus_owner()
		if !focus_owner:
			jump_button.grab_focus()
		elif focus_owner == jump_button and jump_pressed:
			_on_JumpButton_pressed()
		elif focus_owner == heart_button and jump_pressed:
			_on_HeartButton_pressed()

func display() -> void:
	show()
	menu_active = true
	get_tree().paused = true

func _on_JumpButton_pressed():
	player.add_max_jumps()
	jump_upgrade_sound.play()
	hide_menu()

func _on_HeartButton_pressed():
	player.add_heart()
	heart_upgrade_sound.play()
	hide_menu()

func hide_menu() -> void:
	hide()
	menu_active = false
	get_tree().paused = false
	emit_signal("menu_closed")
