extends CanvasLayer

onready var sky_bg = $SkyGreen
onready var space_bg = $OuterSpace

export (NodePath) var player_path = NodePath()
onready var player

onready var start_height = -5700
onready var end_height = -6660
onready var max_dist

func _ready():
	player = get_node_or_null(player_path)
	assert(player != null)
	
	max_dist = abs(start_height - end_height)

func _process(delta):
	if player.global_position.y <= end_height:
		sky_bg.modulate.a = 0
	elif player.global_position.y > start_height:
		sky_bg.modulate.a = 1
	else:
		var dist = abs(player.global_position.y - end_height)
		sky_bg.modulate.a = dist / max_dist
