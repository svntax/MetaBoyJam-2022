extends Node2D

func start_particles() -> void:
	$SparksRed.emitting = true
	$SparksWhite.emitting = true

func _on_LifeTimer_timeout():
	queue_free()
