extends CanvasLayer

onready var animation_player = $AnimationPlayer

onready var next_scene = ""
onready var transition_running = false
onready var fast_transition = false

func switch_to_scene(scene_path: String, fast_switch: bool = false) -> void:
	if transition_running:
		return
	
	fast_transition = fast_switch
	if fast_switch:
		animation_player.play("fade_out", -1, 2)
	else:
		animation_player.play("fade_out")
	next_scene = scene_path
	transition_running = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene(next_scene)
		if fast_transition:
			animation_player.play("fade_in", -1, 2)
		else:
			animation_player.play("fade_in")
	elif anim_name == "fade_in":
		transition_running = false
