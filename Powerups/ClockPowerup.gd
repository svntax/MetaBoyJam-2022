extends Area2D

onready var animation_player = $AnimationPlayer
onready var type_player = $TypePlayer
onready var time_text_root = $TimeTextRoot
onready var time_text_label = $TimeTextRoot/TimeLabel
onready var pickup_sound = $PickupSound

onready var player = get_tree().get_nodes_in_group("Players")[0]
onready var time_bonus = 5
onready var was_collected = false

func _ready():
	time_text_root.hide()
	time_text_label.set_text("+" + str(time_bonus))
	animation_player.play("hover")
	connect("body_entered", self, "_on_body_entered")

func set_type_small() -> void:
	time_bonus = 2
	time_text_label.set_text("+" + str(time_bonus))
	type_player.play("turn_small")

func _on_body_entered(body):
	if body == player and !was_collected:
		player.add_time(time_bonus)
		animation_player.play("collect")
		time_text_root.show()
		pickup_sound.play()
		was_collected = true
		collision_layer = 0
		collision_mask = 0

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "collect":
		queue_free()
