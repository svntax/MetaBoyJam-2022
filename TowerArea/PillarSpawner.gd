extends Area2D

# Keeps spawning more pillars as the player goes up.

onready var pillar_height = 288

export (NodePath) var target_pillar_path = NodePath()
onready var target_pillar
onready var current_y

func _ready():
	connect("body_entered", self, "_on_player_entered")
	target_pillar = get_node_or_null(target_pillar_path)
	assert(target_pillar != null)
	current_y = target_pillar.global_position.y

func _on_player_entered(body):
	self.global_position.y -= pillar_height
	current_y -= pillar_height
	var pillar_copy = target_pillar.duplicate()
	pillar_copy.global_position = Vector2(target_pillar.global_position.x, current_y)
	get_parent().add_child(pillar_copy)
