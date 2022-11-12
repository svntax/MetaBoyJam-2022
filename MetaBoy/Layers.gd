tool
extends Node2D

export (int, 0, 11) var frame = 0 setget set_frame

func set_frame(new_frame):
	frame = new_frame
	for sprite_layer in get_children():
		if sprite_layer is Sprite:
			sprite_layer.frame = frame
