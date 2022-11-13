extends KinematicBody2D

# This wall follows the y position of the player

onready var player

func _ready():
	player = get_tree().get_nodes_in_group("Players")[0]

func _physics_process(_delta):
	if player != null:
		global_position.y = player.global_position.y
