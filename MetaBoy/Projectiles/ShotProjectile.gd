extends Area2D
class_name ShotProjectile

var source_shooter = null

onready var speed = 128
onready var velocity = Vector2()
onready var alive = true

export (int) var damage = 1

onready var body = $Sprite

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")

func set_velocity(vel: Vector2) -> void:
	velocity = vel

func set_direction(dir: Vector2) -> void:
	pass # If we need to rotate the projectile sprite

func _physics_process(delta):
	if alive:
		global_position += velocity * delta

func take_hit() -> void:
	if alive:
		alive = false
		body.hide()
		destroy()

func _on_body_entered(other_body):
	_handle_object_entered(other_body)

func _on_area_entered(other_area):
	_handle_object_entered(other_area)

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
		alive = false
		body.hide()
		destroy()

func destroy() -> void:
	queue_free()

func should_remove_on_collision(other) -> bool:
	return true
