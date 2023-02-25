extends Area2D

const LaserSparks = preload("res://Enemies/LaserSparks.tscn")

# Slicing up laser shots gives you points
const SCORE_VALUE = 2

var source_shooter = null

onready var speed = 128
onready var direction = 1
onready var alive = true

onready var body = $Sprite
onready var laser_hit_sound = $LaserHit

func _ready():
	connect("body_entered", self, "_on_body_entered")

func set_direction(dir: int) -> void:
	var new_dir = sign(dir)
	if new_dir == 0:
		new_dir = 1
	direction = dir
	body.scale.x = direction

func _physics_process(delta):
	if alive:
		global_position.x += speed * delta * direction

# Different from take_damage because no damage calculations are used.
func take_hit() -> void:
	if alive:
		alive = false
		body.hide()
		spawn_sparks()
		laser_hit_sound.play()
		Globals.add_score(SCORE_VALUE)

func spawn_sparks() -> void:
	var sparks = LaserSparks.instance()
	get_parent().add_child(sparks)
	sparks.global_position = global_position
	sparks.start_particles()

func _on_body_entered(other_body):
	if source_shooter != null and other_body == source_shooter:
		return
	
	if not alive:
		return
	
	if other_body.has_method("take_damage"):
		var damage_data = {
			"source_object": self,
			"damage_amount": 1
		}
		other_body.take_damage(damage_data)

	alive = false
	body.hide()
	queue_free()

func _on_LaserHit_finished():
	queue_free()
