extends KinematicBody2D

const CratePieceV = preload("res://BreakableObjects/CratePieceV.tscn")
#const CratePieceD = preload("res://BreakableObjects/CratePieceD.tscn")

const ClockPowerup = preload("res://Powerups/ClockPowerup.tscn")
const HeartPowerup = preload("res://Powerups/HeartPowerup.tscn")

onready var break_sound = $BreakSound
onready var crate_broken = $BodyBroken
onready var crate_normal = $Sprite

onready var powerups_pool = [
	ClockPowerup,
	HeartPowerup
]

func _ready():
	crate_broken.hide()
	crate_normal.show()
	# Randomly flip the broken sprite
	if randf() < 0.5:
		crate_broken.scale.x = -1

func take_damage(damage_data: Dictionary) -> void:
	var source_obj = damage_data.get("source_object", null)
	var num_pieces = randi() % 2 + 1
	call_deferred("spawn_broken_pieces", num_pieces, source_obj)

func spawn_broken_pieces(amount: int, source_obj) -> void:
	if amount <= 0:
		amount = 1
	
	for i in range(amount):
		var debris = spawn_broken_piece()
		# Knock back in the direction away from the player
		var dir = sign(global_position.x - source_obj.global_position.x)
		var vx = rand_range(48 + (i * 32), 72 + (i * 32)) * dir
		var vy = rand_range(-48, -24)
		debris.apply_central_impulse(Vector2(vx, vy))
	
	spawn_powerup()
	crate_normal.hide()
	crate_broken.show()
	collision_layer = 0
	collision_mask = 0
	break_sound.play()

func spawn_broken_piece() -> RigidBody2D:
	#var choice = randi() % 2
	var choice = 0
	var debris
	if choice == 0:
		debris = CratePieceV.instance()
#	else:
#		debris = CratePieceD.instance()
	debris.global_position = global_position
	get_tree().current_scene.add_child(debris)
	
	return debris

func spawn_powerup() -> void:
	var choice = randi() % powerups_pool.size()
	var powerup = powerups_pool[choice].instance()
	powerup.global_position = global_position + Vector2(0, -6)
	get_tree().current_scene.add_child(powerup)
