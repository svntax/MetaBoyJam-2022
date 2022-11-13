extends RigidBody2D

onready var collision = $CollisionShape2D
onready var life_timer

func _ready():
	life_timer = Timer.new()
	life_timer.one_shot = true
	life_timer.wait_time = rand_range(3, 6)
	add_child(life_timer)
	life_timer.connect("timeout", self, "_on_life_timeout")
	life_timer.start()

func _on_life_timeout():
	queue_free()
