extends Area2D

onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var pickup_sound = $PickupSound

onready var player = get_tree().get_nodes_in_group("Players")[0]
onready var heal_amount = 1
onready var picked_up = false

func _ready():
	animation_player.play("hover")
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if picked_up:
		return
	
	if body == player:
		picked_up = true
		collision_layer = 0
		collision_mask = 0
		player.heal(heal_amount)
		pickup_sound.play()
		sprite.hide()

func _on_PickupSound_finished():
	queue_free()
