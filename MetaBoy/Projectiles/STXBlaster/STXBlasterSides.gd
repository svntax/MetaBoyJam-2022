extends Node2D

onready var animation_player = $AnimationPlayer

func play_effect() -> void:
	animation_player.play("shoot", -1, 2)
