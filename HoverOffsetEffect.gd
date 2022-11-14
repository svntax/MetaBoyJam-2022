extends Node2D

# Helper script to make this node hover in the y axis using sinusodial functions.

onready var original_pos = self.position
onready var t = 0

export (float) var time_offset = 0

func _process(delta):
	# Manual hovering movement
	t += delta
	if t > 360:
		t = 0
	self.position.y = original_pos.y + 3 * cos((t + time_offset) * 8)
