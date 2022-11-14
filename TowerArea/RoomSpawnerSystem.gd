extends Node2D

const RoomsList = [
	preload("res://TowerArea/Rooms/Room00.tscn"),
	preload("res://TowerArea/Rooms/Room01.tscn"),
	preload("res://TowerArea/Rooms/Room02.tscn"),
	preload("res://TowerArea/Rooms/Room03.tscn"),
	preload("res://TowerArea/Rooms/Room04.tscn"),
	preload("res://TowerArea/Rooms/Room05.tscn"),
]

export (int) var number_of_rooms = 10

# Rooms are 640 x 256 sections
onready var room_width = 640
onready var room_height = 256
onready var current_pos = Vector2(global_position.x, global_position.y)

onready var player = get_tree().get_nodes_in_group("Players")[0]

func _ready():
	for i in range(number_of_rooms):
		spawn_room()

func _process(_delta):
	if player.global_position.y < current_pos.y + room_height * 3:
		# Spawn n rooms at a time
		for i in range(6):
			spawn_room()

func spawn_room() -> void:
	var choice = randi() % RoomsList.size()
	var room_scene = RoomsList[choice]
	var new_room = room_scene.instance()
	add_child(new_room)
	new_room.global_position = current_pos
	current_pos.y -= room_height
