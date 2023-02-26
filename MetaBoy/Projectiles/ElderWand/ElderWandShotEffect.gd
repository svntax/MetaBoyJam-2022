extends Node2D

onready var animation_player = $AnimationPlayer

func _ready():
	if randf() < 0.5:
		animation_player.play("effect_diagonal", -1, 1.5)
	else:
		animation_player.play("effect_vertical", -1, 1.5)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "effect_vertical" or anim_name == "effect_diagonal":
		queue_free()
