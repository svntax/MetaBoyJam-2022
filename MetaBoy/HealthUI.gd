extends Control

signal out_of_hp()

onready var max_health = 3
onready var current_health = 3

onready var hearts_base = $HeartsBase
onready var hearts_current = $Hearts

func set_health(hp: int) -> void:
	if hp > max_health:
		hp = max_health
	current_health = hp
	var visible_hearts = 0
	for heart_icon in hearts_current.get_children():
		if visible_hearts < current_health:
			heart_icon.show()
			visible_hearts += 1
		else:
			heart_icon.hide()
	
	if hp <= 0:
		hp = 0
		emit_signal("out_of_hp")
