extends ShotProjectile

onready var segment_collision = $SegmentCollision
onready var lightning_effects = $LightningEffects
onready var move_timer = $MoveTimer
onready var spawn_position = self
onready var can_move = true
onready var is_destroyed = false
onready var original_position = global_position
var new_start_spawn
var travel_limit = 72 * 72

func _ready():
	lightning_effects.hide()
	move_timer.start(0.15)

func set_spawn_position(pos: Node2D) -> void:
	spawn_position = pos

func _physics_process(delta):
	if alive and can_move:
		global_position += velocity * delta
		if original_position.distance_squared_to(global_position) > travel_limit:
			can_move = false
		
	if alive and spawn_position != self:
		if !lightning_effects.visible:
			lightning_effects.call_deferred("show")
		for lightning in lightning_effects.get_children():
			lightning.set_start_point(spawn_position.global_position)
			lightning.set_end_point(lightning.global_position)
			lightning.create_segments()
			lightning.generate_offsets()
			lightning.set_fluctuating(true)
	else:
		for lightning in lightning_effects.get_children():
			lightning.set_fluctuating(false)
		lightning_effects.hide()
	
	# Also update the segment collision shape
	segment_collision.shape.a = Vector2.ZERO
	segment_collision.shape.b = (spawn_position.global_position - global_position)

# Overridden to keep lightning alive even after hitting something
func _handle_object_entered(other) -> void:
	if source_shooter != null and other == source_shooter:
		return
	
	if not alive:
		return
	
	if other.is_in_group("Powerups") or other.is_in_group("Debris"):
		return
	
	if other.is_in_group("OneWayObjects") and velocity.y <= 0:
		return
	
	if other.has_method("take_damage"):
		var damage_data = {
			"source_object": self,
			"damage_amount": damage
		}
		other.take_damage(damage_data)
	if other.has_method("take_hit"):
		other.take_hit()
	
	if should_remove_on_collision(other):
		can_move = false
		set_velocity(Vector2.ZERO)

func destroy() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	collision_layer = 0
	collision_mask = 0
	if new_start_spawn != null and is_instance_valid(new_start_spawn):
		new_start_spawn.queue_free()
	.destroy()

func _on_VisibilityNotifier2D_screen_exited():
	destroy()

# Move the tail end towards the target position
func _on_MoveTimer_timeout():
	can_move = false
	self.set_velocity(Vector2())
	# Set start point to another node that will be moved
	new_start_spawn = Position2D.new()
	get_parent().add_child(new_start_spawn)
	new_start_spawn.global_position = spawn_position.global_position
	spawn_position = new_start_spawn
	
	var move_tween := get_tree().create_tween()
	move_tween.tween_property(spawn_position, "global_position", self.global_position, move_timer.wait_time*2)
	move_tween.tween_callback(self, "destroy")
