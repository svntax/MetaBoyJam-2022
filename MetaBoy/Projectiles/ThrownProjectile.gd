extends KinematicBody2D
class_name ThrownProjectile

const MAX_FALL_SPEED = 264
onready var gravity = 16
onready var velocity = Vector2()
onready var active = true

var damage_data = {
	"source_object": self,
	"damage_amount": 10
}

func set_velocity(vel: Vector2) -> void:
	velocity = vel

func _physics_process(delta):
	if not active:
		return
	
	_handle_movement(delta)

func _handle_movement(delta) -> void:
	# Gravity
	velocity.y += gravity
	# Limit fall speed
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		_on_collide(collision)

func _on_collide(_collision) -> void:
	active = false
	queue_free()

func take_damage(_damage_obj: Dictionary) -> void:
	active = false
	queue_free()

func take_hit() -> void:
	active = false
	queue_free()

