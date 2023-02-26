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

var weapon_type : String

onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var action_player = $ActionPlayer
onready var effects_player = $EffectsPlayer
onready var body_root = $MainBody
onready var jump_grace_timer = $JumpGraceTimer
onready var attack_cooldown_timer = $AttackCooldownTimer
onready var damage_flash_timer = $DamageFlashTimer

# MetaBoy parts
onready var part_back = $MainBody/Back
onready var part_body = $MainBody/Body
onready var part_face = $MainBody/Face
onready var part_hat = $MainBody/Hat
onready var part_neck = $MainBody/Neck
onready var part_waist = $MainBody/Waist
onready var part_weapon = $MainBody/Weapon

# Arm sprites, used if the weapon spritesheet needs to be separated
onready var close_arm = $MainBody/CloseArm
onready var far_arm = $MainBody/FarArm

# Root nodes for specific weapon setups
onready var yatagan_root = $MainBody/YataganArmRoot
onready var bomb_root = $MainBody/BombArmRoot
onready var dynamite_root = $MainBody/DynamiteArmRoot
onready var snail_shell_root = $MainBody/SnailShellArmRoot
onready var energy_sword_root = $MainBody/EnergySwordRoot

# Projectiles
const Bomb = preload("res://MetaBoy/Projectiles/Bomb/Bomb.tscn")
onready var bomb_spawn_pos = get_node("%BombSpawn")

const Dynamite = preload("res://MetaBoy/Projectiles/Dynamite/Dynamite.tscn")
onready var dynamite_spawn_pos = get_node("%DynamiteSpawn")

const SnailShell = preload("res://MetaBoy/Projectiles/SnailShell/SnailShell.tscn")
onready var snail_shell_spawn_pos = get_node("%SnailShellSpawn")

# TODO temporary, unless we want the bazooka to shoot bombs
onready var bazooka_projectile_spawn_pos = get_node("%BazookaSpawn")

const ElderWandProjectile = preload("res://MetaBoy/Projectiles/ElderWand/ElderWandProjectile.tscn")
const ElderWandShotEffect = preload("res://MetaBoy/Projectiles/ElderWand/ElderWandShotEffect.tscn")
onready var elder_wand_projectile_spawn_pos = get_node("%ElderWandSpawn")

onready var explode_sound = $ExplodeSound
onready var jump_sound = $JumpSound
onready var jump_02_sound = $Jump02Sound
onready var hurt_sound = $HurtSound
onready var slash_sound = $SlashSound
onready var elder_wand_shoot_sound = $ElderWandShootSound

func _ready():
	init_setup_parts()
	
	input_controls = KEYBOARD_CONTROLS
	# TODO: temporary for testing purposes
	set_metaboy_attributes(MetaBoyGlobals.test_metaboy)

func init_setup_parts() -> void:
	action_player.stop()
	part_weapon.show()
	
	far_arm.hide()
	close_arm.hide()
	
	yatagan_root.hide()
	bomb_root.hide()
	dynamite_root.hide()
	snail_shell_root.hide()
	energy_sword_root.hide()
	

func set_metaboy_attributes(attributes: Dictionary) -> void:
	init_setup_parts()
	
	var path_root = "res://MetaBoy/spritesheets/"
	var show_back = false
	var show_hat = false
	var show_neck = false
	var show_waist = false
	for key in attributes.keys():
		var value = attributes.get(key)
		var path = path_root + str(key) + "/" + str(value).replace(" ", "-") + ".png"
		if ResourceLoader.exists(path):
			if key == "Back":
				part_back.texture = load(path)
				show_back = true
			elif key == "Body":
				part_body.texture = load(path)
			elif key == "Face":
				part_face.texture = load(path)
			elif key == "Hat":
				part_hat.texture = load(path)
				show_hat = true
			elif key == "Neck":
				part_neck.texture = load(path)
				show_neck = true
			elif key == "Waist":
				part_waist.texture = load(path)
				show_waist = true
			elif key == "Weapon":
				# Custom spritesheet setup for certain weapons.
				weapon_type = str(value).replace(" ", "-")
				if weapon_type == "Bomb":
					part_weapon.hide()
					bomb_root.show() # For the throwing animation
					close_arm.show() # Close arm holds the weapon
					close_arm.texture = load(path.replace("Bomb.png", "BombCloseArm.png"))
					far_arm.show() # Far arm is empty
					far_arm.texture = load(path.replace("Bomb.png", "BombFarArm.png"))
				elif weapon_type == "Dynamite-Stick":
					part_weapon.hide()
					dynamite_root.show() # For the throwing animation
					close_arm.show() # Close arm holds the weapon
					close_arm.texture = load(path.replace("Dynamite-Stick.png", "Dynamite-Stick_CloseArm.png"))
					far_arm.show() # Far arm is empty
					far_arm.texture = load(path.replace("Dynamite-Stick.png", "Dynamite-Stick_FarArm.png"))
				elif weapon_type == "Snail-Shell":
					part_weapon.hide()
					snail_shell_root.show() # For the throwing animation
					close_arm.show() # Close arm holds the weapon
					close_arm.texture = load(path.replace("Snail-Shell.png", "Snail-Shell_CloseArm.png"))
					far_arm.show() # Far arm is empty
					far_arm.texture = load(path.replace("Snail-Shell.png", "Snail-Shell_FarArm.png"))
				elif weapon_type == "Yatagan":
					part_weapon.hide()
					yatagan_root.show() # Far arm holds the weapon
					close_arm.show() # Close arm is empty
					close_arm.texture = load(path.replace("Yatagan.png", "YataganCloseArm.png"))
				elif weapon_type == "Energy-Sword":
					part_weapon.hide()
					energy_sword_root.show() # Far arm holds the weapon
					close_arm.show() # Close arm is empty
					close_arm.texture = load(path.replace("Energy-Sword.png", "Energy-Sword_CloseArm.png"))
				elif weapon_type == "Elder-Wand":
					part_weapon.texture = load(path.replace("Elder-Wand.png", "Elder-Wand_Base.png"))
				else:
					part_weapon.texture = load(path)
	
	part_back.visible = show_back
	part_hat.visible = show_hat
	part_neck.visible = show_neck
	part_waist.visible = show_waist
	
	# Check for key in case of mismints that are missing these attributes
	if attributes.has("Body") and attributes.has("Face"):
		var body_type = attributes.get("Body").replace(" ", "-")
		# Bodies with dark screens need the light version of the face
		if MetaBoyGlobals.is_dark_screen_body(body_type):
			var face_type = attributes.get("Face").replace(" ", "-")
			var face_light_version_texture = MetaBoyGlobals.get_face_light_version(face_type)
			if face_light_version_texture:
				part_face.texture = face_light_version_texture

func _process(_delta):
	# TODO: temporary for testing purposes
	if Input.is_action_just_pressed("move_down"):
		set_metaboy_attributes(MetaBoyGlobals.get_random_attributes())

func _physics_process(delta):
	# Movement
	if can_move():
		# TODO: do we want the player to be able to turn at any time?
		if Input.is_action_just_pressed(input_controls["left"]):
			turn_towards(-1)
		if Input.is_action_just_pressed(input_controls["right"]):
			turn_towards(1)
		body_root.scale.x = face_direction
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
	if weapon_type == "Yatagan":
		action_player.play("swing")
		slash_sound.play()
	elif weapon_type == "Energy-Sword":
		action_player.play("swing_energy_sword")
		slash_sound.play()
	elif weapon_type == "Bomb":
		action_player.play("throw_bomb")
		var bomb = Bomb.instance()
		get_parent().add_child(bomb)
		bomb.global_position = bomb_spawn_pos.global_position
		bomb.z_index = z_index + 1
		bomb.set_velocity(Vector2(400 * face_direction, -80))
		if face_direction == -1:
			bomb.flip_direction()
	elif weapon_type == "Dynamite-Stick":
		action_player.play("throw_dynamite")
		var dynamite = Dynamite.instance()
		get_parent().add_child(dynamite)
		dynamite.global_position = dynamite_spawn_pos.global_position
		dynamite.z_index = z_index + 1
		dynamite.set_velocity(Vector2(400 * face_direction, -80))
		if face_direction == -1:
			dynamite.flip_direction()
	elif weapon_type == "Snail-Shell":
		action_player.play("throw_snail_shell")
		var snail_shell = SnailShell.instance()
		get_parent().add_child(snail_shell)
		snail_shell.global_position = dynamite_spawn_pos.global_position
		snail_shell.z_index = z_index + 1
		snail_shell.set_velocity(Vector2(400 * face_direction, -80))
		if face_direction == -1:
			snail_shell.flip_direction()
	elif weapon_type == "Bazooka":
		var bazooka_projectile = Bomb.instance()
		get_parent().add_child(bazooka_projectile)
		bazooka_projectile.global_position = bazooka_projectile_spawn_pos.global_position
		bazooka_projectile.z_index = z_index + 1
		bazooka_projectile.set_velocity(Vector2(450 * face_direction, 0))
		if face_direction == -1:
			bazooka_projectile.flip_direction()
	elif weapon_type == "Elder-Wand":
		elder_wand_shoot_sound.play()
		var elder_wand_projectile = ElderWandProjectile.instance()
		get_parent().add_child(elder_wand_projectile)
		elder_wand_projectile.global_position = elder_wand_projectile_spawn_pos.global_position
		elder_wand_projectile.z_index = z_index + 1
		var vel = Vector2(450 * face_direction, 0).rotated(body_root.rotation)
		elder_wand_projectile.set_velocity(vel)
		elder_wand_projectile.set_direction(vel)
		
		var shot_effect = ElderWandShotEffect.instance()
		elder_wand_projectile_spawn_pos.add_child(shot_effect)
		shot_effect.global_position = elder_wand_projectile_spawn_pos.global_position
	else:
		# TODO: implement attacks for all weapons
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
