extends Area2D

onready var animation_player = $AnimationPlayer

onready var player = get_tree().get_nodes_in_group("Players")[0]
onready var hp_amount = 1

func _ready():
	animation_player.play("hover")
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body == player:
		player.heal(hp_amount)
		queue_free()
