extends KinematicBody2D

const KEYBOARD_CONTROLS = {
	"up": "move_up",
	"down": "move_down",
	"left": "move_left",
	"right": "move_right",
	"jump": "jump",
	"action": "action"
}

onready var input_controls

const SNAP = Vector2(0, 12)
const MAX_FALL_SPEED = 248
onready var gravity = 16
onready var speed = 164
onready var jump_speed = 320
onready var jump_grace_timer = $JumpGraceTimer

onready var velocity = Vector2()
onready var face_direction = 1

onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var action_player = $ActionPlayer
onready var body = $MainBody
onready var attack_cooldown_timer = $AttackCooldownTimer

func _ready():
	input_controls = KEYBOARD_CONTROLS

func _physics_process(_delta):
	velocity.x = 0
	
	# Gravity
	velocity.y += get_gravity()
	
	# Movement
	if can_move():
		if Input.is_action_pressed(input_controls["left"]):
			velocity.x -= get_speed()
		if Input.is_action_pressed(input_controls["right"]):
			velocity.x += get_speed()
		if velocity.x != 0:
			face_direction = sign(velocity.x)
		body.scale.x = face_direction
		if Input.is_action_just_pressed(input_controls["action"]):
			_handle_action()
	
	# Jump
	if Input.is_action_just_pressed(input_controls["jump"]):
		if can_jump():
			jump()
	
	if state_machine.state == state_machine.States.JUMP:
		velocity.y = move_and_slide(velocity, Vector2.UP, true).y
	else:
		velocity.y = move_and_slide_with_snap(velocity, SNAP, Vector2.UP, true).y
	
	# Limit fall speed
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

func _handle_action() -> void:
	if can_attack():
		attack()

func attack() -> void:
	action_player.play("swing")
	attack_cooldown_timer.start()

func can_attack() -> bool:
	return attack_cooldown_timer.is_stopped()

func can_move() -> bool:
	return state_machine.is_in_movement_state()

func can_jump() -> bool:
	return can_move() and (is_on_floor() or is_jump_grace_active())

func jump() -> void:
	velocity.y = -get_jump_speed()
	state_machine.set_state(state_machine.States.JUMP)

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

func is_on_ground() -> bool:
	return is_on_floor()

func is_jump_grace_active() -> bool:
	return not jump_grace_timer.is_stopped()
