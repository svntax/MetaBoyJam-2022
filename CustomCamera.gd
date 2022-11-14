extends Camera2D

onready var screenshake_timer: Timer
onready var screenshake_magnitude: float = 3.0 # How far the offset should be
onready var screenshake_frequency: float = 0.2 # How long a single shake/offset takes
onready var shake_wait_time: float = 0.0
onready var original_offset = Vector2()

func _ready():
	screenshake_timer = Timer.new()
	screenshake_timer.one_shot = true
	screenshake_timer.connect("timeout", self, "_on_screenshake_timeout")
	add_child(screenshake_timer)

func _process(delta):
	if not screenshake_timer.is_stopped():
		shake_wait_time += delta
		if shake_wait_time > screenshake_frequency:
			shake_wait_time = 0
			var off_x = screenshake_magnitude
			var off_y = screenshake_magnitude
			if randf() < 0.5:
				off_x *= -1
			if randf() < 0.5:
				off_y *= -1
			self.offset = original_offset + Vector2(off_x, off_y)

func screenshake(duration: float, magnitude: float, frequency: float) -> void:
	screenshake_timer.wait_time = duration
	screenshake_magnitude = magnitude
	screenshake_frequency = frequency
	screenshake_timer.start()

func stop_screenshake() -> void:
	screenshake_timer.stop()
	self.offset = Vector2()

func _on_screenshake_timeout():
	stop_screenshake()
