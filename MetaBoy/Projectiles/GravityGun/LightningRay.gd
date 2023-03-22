extends Node2D

onready var start_point = global_position
onready var end_point = global_position + Vector2(128, 128)

export (float) var amplitude = 6.0
export (bool) var fluctuating = false
var fluctuation_timer: float = 0.0
export (float) var fluctuation_cycle_time = 0.1
export (Color) var line_color = Color.yellow
export (float) var line_width = 1.0
export (int) var line_division_length = 8

var points: Array = []

func set_start_point(pos: Vector2) -> void:
	start_point = pos

func set_end_point(pos: Vector2) -> void:
	end_point = pos

func set_fluctuating(flag: bool) -> void:
	fluctuating = flag

func set_fluctuation_cycle_time(duration: float) -> void:
	fluctuation_cycle_time = duration

func set_amplitude(amp: float) -> void:
	amplitude = amp

func _draw():
	if end_point != null and points.empty():
		create_segments()
		generate_offsets()
	
	elif end_point != null and points.size() > 1:
		for i in range(0, points.size() - 1):
			draw_line(points[i] - global_position, points[i+1] - global_position, line_color, line_width)
			draw_line(points[points.size() - 1] - global_position, end_point - global_position, line_color, line_width)

func create_segments() -> void:
	points.clear()
	var x1 = start_point.x
	var y1 = start_point.y
	var x2 = end_point.x
	var y2 = end_point.y
	var line_length = end_point.distance_to(start_point)
	if line_length <= 0:
		line_length = 1
	var num_segments: int = line_length / line_division_length
	if num_segments <= 1:
		num_segments = 2
	points = [start_point]
	var segment_length: int = line_length / num_segments

	var slope = Vector2((x2 - x1) / line_length, (y2 - y1) / line_length);

	for i in range(1, num_segments):
		var p = Vector2(x1 + i*segment_length*slope.x, y1 + i*segment_length*slope.y);
		points.append(p)

# Offsets the vertices along the line to make the lightning bolt look like actual lightning
func generate_offsets() -> void:
	if points == null:
		return
	
	if points.size() <= 2:
		# The lightning bolt needs at least 3 vertices
		return
	# For resetting the vertices
	var x1 = start_point.x
	var y1 = start_point.y
	var x2 = end_point.x
	var y2 = end_point.y
	var line_length = start_point.distance_to(end_point)
	var num_segments: int = line_length / line_division_length
	if num_segments <= 1:
		num_segments = 2
	var segment_length = line_length / num_segments
	var slope = Vector2((x2 - x1) / line_length, (y2 - y1) / line_length)
	var normal = (end_point - start_point).rotated(deg2rad(90)).normalized()
	for i in range(1, points.size()):
		# First reset the offsets
		points[i].x = x1 + i*segment_length*slope.x
		points[i].y = y1 + i*segment_length*slope.y

		var p = Vector2(points[i].x, points[i].y)
		var offset = rand_range(-amplitude, amplitude);
		points[i] = Vector2(p.x + normal.x*offset, p.y + normal.y*offset)

func _process(delta):
	if fluctuating:
		fluctuation_timer += delta
		if fluctuation_timer > fluctuation_cycle_time:
			fluctuation_timer = 0
			generate_offsets()
	if visible:
		update()
