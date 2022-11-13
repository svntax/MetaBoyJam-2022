extends Area2D

var source_shooter = null

onready var speed = 128
onready var direction = 1

onready var body = $Sprite

func _ready():
	connect("body_entered", self, "_on_body_entered")

func set_direction(dir: int) -> void:
	var new_dir = sign(dir)
	if new_dir == 0:
		new_dir = 1
	direction = dir
	body.scale.x = direction

func _physics_process(delta):
	global_position.x += speed * delta * direction

# Different from take_damage because no damage calculations are used.
func take_hit() -> void:
	queue_free()

func _on_body_entered(body):
	if source_shooter != null and body == source_shooter:
		return
	
	if body.has_method("take_damage"):
		var damage_data = {
			"source_object": self,
			"damage_amount": 1
		}
		body.take_damage(damage_data)

	queue_free()
