extends Area2D

onready var animation_player = $AnimationPlayer
onready var time_text_root = $TimeTextRoot

onready var player = get_tree().get_nodes_in_group("Players")[0]
onready var time_bonus = 5
onready var was_collected = false

func _ready():
	time_text_root.hide()
	animation_player.play("hover")
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body == player and !was_collected:
		player.add_time(time_bonus)
		animation_player.play("collect")
		was_collected = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "collect":
		queue_free()
