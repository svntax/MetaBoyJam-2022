extends Node2D

onready var placeholders = $Placeholders

func _ready():
	placeholders.queue_free()
