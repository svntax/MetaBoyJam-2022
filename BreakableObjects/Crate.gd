extends KinematicBody2D

const CratePieceV = preload("res://BreakableObjects/CratePieceV.tscn")
#const CratePieceD = preload("res://BreakableObjects/CratePieceD.tscn")

func take_damage(damage_data: Dictionary) -> void:
	var source_obj = damage_data.get("source_object", null)
	call_deferred("spawn_broken_pieces", 3, source_obj)

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
	
	queue_free()

func spawn_broken_piece() -> RigidBody2D:
	#var choice = randi() % 2
	var choice = 0
	var debris
	if choice == 0:
		debris = CratePieceV.instance()
#	else:
#		debris = CratePieceD.instance()
	debris.global_position = global_position
	get_parent().add_child(debris)
	
	return debris
