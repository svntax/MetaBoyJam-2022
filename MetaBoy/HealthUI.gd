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

func add_heart() -> void:
	if max_health < Globals.MAX_HEALTH_CAP:
		max_health += 1
		var new_heart_icon = hearts_base.get_child(0).duplicate()
		hearts_base.add_child(new_heart_icon)
		var new_heart_icon2 = hearts_current.get_child(0).duplicate()
		hearts_current.add_child(new_heart_icon2)
		set_health(current_health)
