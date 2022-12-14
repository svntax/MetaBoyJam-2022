extends KinematicBody2D

const KEYBOARD_CONTROLS = {
	"up": "move_up",
	"down": "move_down",
	"left": "move_left",
	"right": "move_right",
	"jump": "jump",
	"action": "action"
}

signal damage_taken(new_hp)
signal health_changed(new_hp)
signal max_health_increased()
signal time_added(amount)
signal max_jumps_changed(new_jump_count)

onready var input_controls

const SNAP = Vector2(0, 12)
const MAX_FALL_SPEED = 264

onready var gravity = 16
onready var speed = 164
onready var jump_speed = 320
onready var double_jump_speed = 292
onready var max_jumps = 2
onready var jump_count = 0

onready var hp = 3
onready var max_hp = 3

onready var velocity = Vector2()
onready var face_direction = 1

onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var action_player = $ActionPlayer
onready var effects_player = $EffectsPlayer
onready var body = $MainBody
onready var jump_grace_timer = $JumpGraceTimer
onready var attack_cooldown_timer = $AttackCooldownTimer
onready var damage_flash_timer = $DamageFlashTimer

onready var explode_sound = $ExplodeSound
onready var jump_sound = $JumpSound
onready var jump_02_sound = $Jump02Sound
onready var hurt_sound = $HurtSound
onready var slash_sound = $SlashSound

func _ready():
	input_controls = KEYBOARD_CONTROLS

func _physics_process(delta):
	# Movement
	if can_move():
		# TODO: do we want the player to be able to turn at any time?
		if Input.is_action_just_pressed(input_controls["left"]):
			turn_towards(-1)
		if Input.is_action_just_pressed(input_controls["right"]):
			turn_towards(1)
		body.scale.x = face_direction
		if Input.is_action_just_pressed(input_controls["action"]):
			_handle_action()
	
	# Jump
	if Input.is_action_just_pressed(input_controls["jump"]):
		if can_jump():
			jump()
	
	if not state_machine.state == state_machine.States.DEAD:
		_handle_movement(delta)

func _handle_movement(_delta):
	# Running
	velocity.x = speed * face_direction
	
	# Gravity
	velocity.y += get_gravity()
	
	if state_machine.state == state_machine.States.JUMP:
		velocity.y = move_and_slide(velocity, Vector2.UP, true).y
	else:
		velocity.y = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true).y
	
	# Flip directions on horizontal collision
	var slide_count = get_slide_count()
	for i in range(slide_count):
		var slide_collision = get_slide_collision(i)
		var normal = slide_collision.normal
		if normal.x != 0:
			turn_towards(int(sign(velocity.bounce(normal).x)))
	
	if is_on_floor() and jump_count != 0:
		jump_count = 0
	
	# Limit fall speed
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

func _handle_action() -> void:
	if can_attack():
		attack()

func turn_towards(dir: int) -> void:
	if dir != 1 and dir != -1:
		return
	
	var old_dir = face_direction
	face_direction = dir
	
	if old_dir != dir:
		# Sync double-jump animation to the correct direction
		if animation_player.is_playing() and animation_player.current_animation == "double_jump":
			play_double_jump_animation()

func attack() -> void:
	action_player.play("swing")
	slash_sound.play()
	attack_cooldown_timer.start()

func can_attack() -> bool:
	return attack_cooldown_timer.is_stopped() and state_machine.is_in_movement_state()

func can_move() -> bool:
	return state_machine.is_in_movement_state()

func can_jump() -> bool:
	if jump_count == 0:
		return can_move() and (is_on_floor() or is_jump_grace_active())
	else:
		return can_move() and jump_count < max_jumps

func jump() -> void:
	jump_count += 1
	if jump_count > 1:
		jump_02_sound.play()
		velocity.y = -get_double_jump_speed()
	else:
		jump_sound.play()
		velocity.y = -get_jump_speed()
	state_machine.set_state(state_machine.States.JUMP)

func play_double_jump_animation() -> void:
	var play_speed = 2.7
	if face_direction == -1:
		play_speed = -2.7
	animation_player.play("double_jump", -1, play_speed)

func get_gravity() -> float:
	var g = gravity
	# Floaty jump
	if not is_on_floor() and velocity.y < -32:
		g = gravity
	elif not is_on_floor() and abs(velocity.y) <= 32:
		g *= 0.7
	else:
		g *= 0.85
	
	return g

func get_speed() -> float:
	return speed

func get_jump_speed() -> float:
	return jump_speed

func get_double_jump_speed() -> float:
	return double_jump_speed

func is_on_ground() -> bool:
	return is_on_floor()

func is_jump_grace_active() -> bool:
	return not jump_grace_timer.is_stopped()

func take_damage(damage_data: Dictionary) -> void:
	if not can_take_damage():
		return
	
	#var source_obj = damage_data.get("source_object", null)
	var damage_amount = damage_data.get("damage_amount", 1)
	hp -= damage_amount
	effects_player.play("damaged", -1, 1.2)
	damage_flash_timer.start()
	hurt_sound.play()
	emit_signal("health_changed", hp)
	emit_signal("damage_taken", hp)
	
	# Death
	if hp <= 0:
		state_machine.set_state(state_machine.States.DEAD)

func can_take_damage() -> bool:
	return damage_flash_timer.is_stopped()

func heal(amount: int) -> void:
	if hp <= 0:
		# Can't heal a dead player
		return
	
	if amount <= 0:
		amount = 1
		
	hp += amount
	if hp > max_hp:
		hp = max_hp
	# TODO: heal animation
	emit_signal("health_changed", hp)

# Adds a heart container, or heals 1 if maxed out.
func add_heart() -> void:
	if max_hp >= Globals.MAX_HEALTH_CAP:
		heal(1)
	else:
		max_hp += 1
		emit_signal("max_health_increased")

# Instantly kills the player. Used by the game timer to kill the player when time runs out.
# Note: does not emit the health_changed signal
func kill() -> void:
	hp = 0
	state_machine.set_state(state_machine.States.DEAD)

func is_alive() -> bool:
	return state_machine.state != state_machine.States.DEAD

func add_time(amount: int) -> void:
	emit_signal("time_added", amount)

func add_max_jumps() -> void:
	max_jumps += 1
	emit_signal("max_jumps_changed", max_jumps)

func _on_SwordDamageArea_body_entered(other_body):
	if other_body == self:
		return
	
	if other_body.has_method("take_damage"):
		var damage_data = {
			"source_object": self,
			"damage_amount": 1
		}
		other_body.take_damage(damage_data)

func _on_SwordDamageArea_area_entered(area):
	if area.has_method("take_hit"):
		area.take_hit()

func _on_JumpGraceTimer_timeout():
	if not is_on_floor() and state_machine.state == state_machine.States.FALL:
		jump_count += 1

func _on_DamageFlashTimer_timeout():
	effects_player.play("RESET")
