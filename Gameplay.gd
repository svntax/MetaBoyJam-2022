extends Node2D

onready var health_ui = get_node("%HealthUI")
onready var player = $MetaBoy

func _ready():
	health_ui.connect("out_of_hp", self, "_on_death")
	player.connect("health_changed", self, "_on_player_health_changed")

func _on_player_health_changed(new_hp: int) -> void:
	health_ui.set_health(new_hp)

func _on_death() -> void:
	print("Player dead") # TODO
